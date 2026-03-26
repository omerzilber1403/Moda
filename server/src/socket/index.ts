import http from 'http';
import { Server, Socket } from 'socket.io';
import { verifyToken } from '../middleware/auth';
import pool from '../db';

export function initSocket(server: http.Server): Server {
  const io = new Server(server, {
    cors: {
      origin: '*',
      methods: ['GET', 'POST'],
    },
  });

  // ── Authentication middleware ────────────────────────────────
  io.use((socket, next) => {
    const token = socket.handshake.auth?.token;
    if (!token) {
      return next(new Error('Authentication token required'));
    }

    const user = verifyToken(token);
    if (!user) {
      return next(new Error('Invalid or expired token'));
    }

    socket.data.userId = user.id;
    socket.data.email = user.email;
    next();
  });

  // ── Connection handler ──────────────────────────────────────
  io.on('connection', async (socket: Socket) => {
    const userId = socket.data.userId;
    console.log(`Socket connected: user=${userId} socket=${socket.id}`);

    // Auto-join all active match rooms
    try {
      const result = await pool.query(
        'SELECT id FROM matches WHERE (user1_id = $1 OR user2_id = $1) AND status = $2',
        [userId, 'active']
      );
      for (const row of result.rows) {
        socket.join(row.id);
      }
      if (result.rows.length > 0) {
        console.log(`User ${userId} auto-joined ${result.rows.length} match rooms`);
      }
    } catch (err) {
      console.error('Error auto-joining match rooms:', err);
    }

    // ── join_match ──────────────────────────────────────────
    socket.on('join_match', async (data: { matchId: string }) => {
      try {
        const { matchId } = data;
        if (!matchId) return;

        const result = await pool.query(
          'SELECT id FROM matches WHERE id = $1 AND (user1_id = $2 OR user2_id = $2)',
          [matchId, userId]
        );

        if (result.rows.length === 0) {
          socket.emit('error', { message: 'Match not found or access denied' });
          return;
        }

        socket.join(matchId);
      } catch (err) {
        console.error('join_match error:', err);
        socket.emit('error', { message: 'Failed to join match room' });
      }
    });

    // ── send_message ────────────────────────────────────────
    socket.on('send_message', async (data: { matchId: string; content: string; type?: string }) => {
      try {
        const { matchId, content, type } = data;
        if (!matchId || !content) return;

        const messageType = type || 'text';

        // Verify participation
        const matchResult = await pool.query(
          'SELECT id FROM matches WHERE id = $1 AND (user1_id = $2 OR user2_id = $2)',
          [matchId, userId]
        );

        if (matchResult.rows.length === 0) {
          socket.emit('error', { message: 'Match not found or access denied' });
          return;
        }

        // Insert message
        const msgResult = await pool.query(
          `INSERT INTO messages (match_id, sender_id, content, message_type)
           VALUES ($1, $2, $3, $4)
           RETURNING *`,
          [matchId, userId, content, messageType]
        );

        const row = msgResult.rows[0];
        const formatted = {
          id: row.id,
          matchId: row.match_id,
          senderId: row.sender_id,
          content: row.content,
          type: row.message_type,
          readAt: row.read_at,
          createdAt: row.created_at,
        };

        // Emit to entire match room (including sender)
        io.to(matchId).emit('new_message', formatted);
      } catch (err) {
        console.error('send_message error:', err);
        socket.emit('error', { message: 'Failed to send message' });
      }
    });

    // ── typing ──────────────────────────────────────────────
    socket.on('typing', (data: { matchId: string }) => {
      if (!data.matchId) return;
      socket.to(data.matchId).emit('user_typing', {
        matchId: data.matchId,
        userId,
      });
    });

    // ── stop_typing ─────────────────────────────────────────
    socket.on('stop_typing', (data: { matchId: string }) => {
      if (!data.matchId) return;
      socket.to(data.matchId).emit('user_stop_typing', {
        matchId: data.matchId,
        userId,
      });
    });

    // ── mark_read ───────────────────────────────────────────
    socket.on('mark_read', async (data: { matchId: string }) => {
      try {
        const { matchId } = data;
        if (!matchId) return;

        // Verify participation
        const matchResult = await pool.query(
          'SELECT id FROM matches WHERE id = $1 AND (user1_id = $2 OR user2_id = $2)',
          [matchId, userId]
        );

        if (matchResult.rows.length === 0) {
          socket.emit('error', { message: 'Match not found or access denied' });
          return;
        }

        const result = await pool.query(
          `UPDATE messages
           SET read_at = now()
           WHERE match_id = $1
             AND sender_id != $2
             AND read_at IS NULL`,
          [matchId, userId]
        );

        io.to(matchId).emit('messages_read', {
          matchId,
          userId,
          count: result.rowCount || 0,
        });
      } catch (err) {
        console.error('mark_read error:', err);
        socket.emit('error', { message: 'Failed to mark messages as read' });
      }
    });

    // ── disconnect ──────────────────────────────────────────
    socket.on('disconnect', (reason: string) => {
      console.log(`Socket disconnected: user=${userId} socket=${socket.id} reason=${reason}`);
    });
  });

  return io;
}
