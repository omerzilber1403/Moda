import { Router, Request, Response } from 'express';
import pool from '../db';
import { authMiddleware } from '../middleware/auth';

const router = Router();

// ── Helpers ──────────────────────────────────────────────────

function formatItem(row: any, prefix: string) {
  return {
    id: row[`${prefix}_id`],
    ownerId: row[`${prefix}_owner_id`],
    title: row[`${prefix}_title`],
    description: row[`${prefix}_description`],
    brand: row[`${prefix}_brand`],
    size: row[`${prefix}_size`],
    clothingType: row[`${prefix}_clothing_type`],
    categoryId: row[`${prefix}_category_id`],
    condition: row[`${prefix}_condition`],
    color: row[`${prefix}_color`],
    images: row[`${prefix}_images`] || [],
    attributes: row[`${prefix}_attributes`] || {},
    isActive: row[`${prefix}_is_active`],
    createdAt: row[`${prefix}_created_at`],
  };
}

function formatMatchDetail(row: any, userId: string) {
  const isUser1 = row.user1_id === userId;

  // item1 is owned by user2 (what user1 liked)
  // item2 is owned by user1 (what user2 liked)
  // So if I am user1: myItem = item2 (my item), theirItem = item1
  // If I am user2: myItem = item1 (my item), theirItem = item2
  const myItem = isUser1 ? formatItem(row, 'i2') : formatItem(row, 'i1');
  const theirItem = isUser1 ? formatItem(row, 'i1') : formatItem(row, 'i2');

  const otherUser = {
    id: row.other_id,
    displayName: row.other_display_name,
    avatarUrl: row.other_avatar_url,
    city: row.other_city,
  };

  const lastMessage = row.last_msg_id
    ? {
        id: row.last_msg_id,
        matchId: row.id,
        senderId: row.last_msg_sender_id,
        content: row.last_msg_content,
        type: row.last_msg_type,
        readAt: row.last_msg_read_at,
        createdAt: row.last_msg_created_at,
      }
    : null;

  return {
    match: {
      id: row.id,
      user1Id: row.user1_id,
      user2Id: row.user2_id,
      item1Id: row.item1_id,
      item2Id: row.item2_id,
      status: row.status,
      createdAt: row.created_at,
    },
    otherUser,
    myItem,
    theirItem,
    lastMessage,
    unreadCount: parseInt(row.unread_count, 10) || 0,
  };
}

// The base query for match details — selects both items, the other user,
// latest message via LATERAL, and unread count via subquery.
function buildMatchQuery(whereClause: string, paramCount: number) {
  return `
    SELECT
      m.id, m.user1_id, m.user2_id, m.item1_id, m.item2_id, m.status, m.created_at,

      -- Other user fields (CASE to pick the one who is NOT the requesting user)
      CASE WHEN m.user1_id = $1 THEN ou.id ELSE ou2.id END AS other_id,
      CASE WHEN m.user1_id = $1 THEN ou.display_name ELSE ou2.display_name END AS other_display_name,
      CASE WHEN m.user1_id = $1 THEN ou.avatar_url ELSE ou2.avatar_url END AS other_avatar_url,
      CASE WHEN m.user1_id = $1 THEN ou.city ELSE ou2.city END AS other_city,

      -- Item 1 fields (owned by user2)
      i1.id AS i1_id, i1.owner_id AS i1_owner_id, i1.title AS i1_title,
      i1.description AS i1_description, i1.brand AS i1_brand, i1.size AS i1_size,
      i1.clothing_type AS i1_clothing_type, i1.category_id AS i1_category_id,
      i1.condition AS i1_condition, i1.color AS i1_color, i1.images AS i1_images,
      i1.attributes AS i1_attributes, i1.is_active AS i1_is_active, i1.created_at AS i1_created_at,

      -- Item 2 fields (owned by user1)
      i2.id AS i2_id, i2.owner_id AS i2_owner_id, i2.title AS i2_title,
      i2.description AS i2_description, i2.brand AS i2_brand, i2.size AS i2_size,
      i2.clothing_type AS i2_clothing_type, i2.category_id AS i2_category_id,
      i2.condition AS i2_condition, i2.color AS i2_color, i2.images AS i2_images,
      i2.attributes AS i2_attributes, i2.is_active AS i2_is_active, i2.created_at AS i2_created_at,

      -- Last message via LATERAL subquery
      lm.id AS last_msg_id,
      lm.sender_id AS last_msg_sender_id,
      lm.content AS last_msg_content,
      lm.message_type AS last_msg_type,
      lm.read_at AS last_msg_read_at,
      lm.created_at AS last_msg_created_at,

      -- Unread count
      (
        SELECT COUNT(*)::int FROM messages msg
        WHERE msg.match_id = m.id
          AND msg.sender_id != $1
          AND msg.read_at IS NULL
      ) AS unread_count

    FROM matches m
    JOIN users ou ON ou.id = m.user2_id
    JOIN users ou2 ON ou2.id = m.user1_id
    JOIN clothing_items i1 ON i1.id = m.item1_id
    JOIN clothing_items i2 ON i2.id = m.item2_id
    LEFT JOIN LATERAL (
      SELECT msg.id, msg.sender_id, msg.content, msg.message_type, msg.read_at, msg.created_at
      FROM messages msg
      WHERE msg.match_id = m.id
      ORDER BY msg.created_at DESC
      LIMIT 1
    ) lm ON true
    ${whereClause}
    ORDER BY COALESCE(lm.created_at, m.created_at) DESC
  `;
}

// ── GET /matches ─────────────────────────────────────────────

router.get('/', authMiddleware, async (req: Request, res: Response) => {
  try {
    const userId = req.user!.id;

    const query = buildMatchQuery(
      'WHERE (m.user1_id = $1 OR m.user2_id = $1)',
      1
    );

    const result = await pool.query(query, [userId]);

    const matches = result.rows.map((row) => formatMatchDetail(row, userId));

    res.json({ success: true, data: matches });
  } catch (err) {
    console.error('Get matches error:', err);
    res.status(500).json({ success: false, error: 'Internal server error' });
  }
});

// ── GET /matches/:id ─────────────────────────────────────────

router.get('/:id', authMiddleware, async (req: Request, res: Response) => {
  try {
    const userId = req.user!.id;
    const matchId = req.params.id;

    const query = buildMatchQuery(
      'WHERE m.id = $2 AND (m.user1_id = $1 OR m.user2_id = $1)',
      2
    );

    const result = await pool.query(query, [userId, matchId]);

    if (result.rows.length === 0) {
      res.status(404).json({ success: false, error: 'Match not found' });
      return;
    }

    res.json({ success: true, data: formatMatchDetail(result.rows[0], userId) });
  } catch (err) {
    console.error('Get match error:', err);
    res.status(500).json({ success: false, error: 'Internal server error' });
  }
});

export default router;
