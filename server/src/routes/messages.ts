import { Router, Request, Response } from 'express';
import { z } from 'zod';
import pool from '../db';
import { authMiddleware } from '../middleware/auth';

const router = Router({ mergeParams: true });

// ── Zod Schemas ──────────────────────────────────────────────

const sendMessageSchema = z.object({
  content: z.string().min(1).max(2000),
  type: z.enum(['text', 'image', 'system']).default('text'),
});

// ── Helpers ──────────────────────────────────────────────────

function formatMessage(row: any) {
  return {
    id: row.id,
    matchId: row.match_id,
    senderId: row.sender_id,
    content: row.content,
    type: row.message_type,
    readAt: row.read_at,
    createdAt: row.created_at,
  };
}

/** Verify the requesting user is a participant in the match. Returns null if not found. */
async function verifyParticipation(matchId: string, userId: string) {
  const result = await pool.query(
    'SELECT id, user1_id, user2_id FROM matches WHERE id = $1 AND (user1_id = $2 OR user2_id = $2)',
    [matchId, userId]
  );
  return result.rows.length > 0 ? result.rows[0] : null;
}

// ── GET / — list messages (cursor-paginated) ─────────────────

router.get('/', authMiddleware, async (req: Request, res: Response) => {
  try {
    const userId = req.user!.id;
    const matchId = req.params.matchId;

    const match = await verifyParticipation(matchId, userId);
    if (!match) {
      res.status(404).json({ success: false, error: 'Match not found' });
      return;
    }

    const limit = Math.min(parseInt(req.query.limit as string) || 50, 100);
    const cursor = req.query.cursor as string | undefined;

    let query = `
      SELECT * FROM messages
      WHERE match_id = $1
    `;
    const values: any[] = [matchId];

    if (cursor) {
      query += ` AND created_at < (SELECT created_at FROM messages WHERE id = $${values.length + 1})`;
      values.push(cursor);
    }

    query += ` ORDER BY created_at DESC LIMIT $${values.length + 1}`;
    values.push(limit + 1);

    const result = await pool.query(query, values);
    const hasMore = result.rows.length > limit;
    const rows = hasMore ? result.rows.slice(0, limit) : result.rows;
    const nextCursor = rows.length > 0 ? rows[rows.length - 1].id : null;

    res.json({
      success: true,
      data: {
        messages: rows.map(formatMessage),
        cursor: hasMore ? nextCursor : null,
        hasMore,
      },
    });
  } catch (err) {
    console.error('Get messages error:', err);
    res.status(500).json({ success: false, error: 'Internal server error' });
  }
});

// ── POST / — send a message ──────────────────────────────────

router.post('/', authMiddleware, async (req: Request, res: Response) => {
  try {
    const userId = req.user!.id;
    const matchId = req.params.matchId;

    const parsed = sendMessageSchema.safeParse(req.body);
    if (!parsed.success) {
      res.status(400).json({ success: false, error: parsed.error.errors[0].message });
      return;
    }

    const match = await verifyParticipation(matchId, userId);
    if (!match) {
      res.status(404).json({ success: false, error: 'Match not found' });
      return;
    }

    const { content, type } = parsed.data;

    const result = await pool.query(
      `INSERT INTO messages (match_id, sender_id, content, message_type)
       VALUES ($1, $2, $3, $4)
       RETURNING *`,
      [matchId, userId, content, type]
    );

    const formatted = formatMessage(result.rows[0]);

    // Emit via Socket.IO to the match room
    const io = req.app.get('io');
    if (io) {
      io.to(matchId).emit('new_message', formatted);
    }

    res.status(201).json({ success: true, data: formatted });
  } catch (err) {
    console.error('Send message error:', err);
    res.status(500).json({ success: false, error: 'Internal server error' });
  }
});

// ── PATCH /read — mark messages as read ──────────────────────

router.patch('/read', authMiddleware, async (req: Request, res: Response) => {
  try {
    const userId = req.user!.id;
    const matchId = req.params.matchId;

    const match = await verifyParticipation(matchId, userId);
    if (!match) {
      res.status(404).json({ success: false, error: 'Match not found' });
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

    const count = result.rowCount || 0;

    // Emit via Socket.IO to the match room
    const io = req.app.get('io');
    if (io) {
      io.to(matchId).emit('messages_read', { matchId, userId, count });
    }

    res.json({ success: true, data: { count } });
  } catch (err) {
    console.error('Mark read error:', err);
    res.status(500).json({ success: false, error: 'Internal server error' });
  }
});

export default router;
