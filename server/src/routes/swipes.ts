import { Router, Request, Response } from 'express';
import { z } from 'zod';
import pool from '../db';
import { authMiddleware } from '../middleware/auth';

const router = Router();

const swipeSchema = z.object({
  itemId: z.string().uuid(),
  direction: z.enum(['left', 'right']),
});

function formatSwipe(row: any) {
  return {
    id: row.id,
    swiperId: row.swiper_id,
    itemId: row.item_id,
    direction: row.direction,
    createdAt: row.created_at,
  };
}

function formatMatch(row: any) {
  return {
    id: row.id,
    user1Id: row.user1_id,
    user2Id: row.user2_id,
    item1Id: row.item1_id,
    item2Id: row.item2_id,
    status: row.status,
    createdAt: row.created_at,
  };
}

// ── POST /swipes ─────────────────────────────────────────────
// Atomic swipe + match check inside a transaction

router.post('/', authMiddleware, async (req: Request, res: Response) => {
  const client = await pool.connect();
  try {
    const parsed = swipeSchema.safeParse(req.body);
    if (!parsed.success) {
      res.status(400).json({ success: false, error: parsed.error.errors[0].message });
      return;
    }

    const { itemId, direction } = parsed.data;
    const swiperId = req.user!.id;

    await client.query('BEGIN');

    // 1. Verify item exists, is active, and not owned by swiper
    const itemResult = await client.query(
      'SELECT id, owner_id FROM clothing_items WHERE id = $1 AND is_active = true',
      [itemId]
    );
    if (itemResult.rows.length === 0) {
      await client.query('ROLLBACK');
      res.status(404).json({ success: false, error: 'Item not found or inactive' });
      return;
    }

    const itemOwnerId = itemResult.rows[0].owner_id;
    if (itemOwnerId === swiperId) {
      await client.query('ROLLBACK');
      res.status(400).json({ success: false, error: 'Cannot swipe on your own item' });
      return;
    }

    // 2. Insert swipe (idempotent)
    const swipeResult = await client.query(
      `INSERT INTO swipes (swiper_id, item_id, direction)
       VALUES ($1, $2, $3)
       ON CONFLICT (swiper_id, item_id) DO NOTHING
       RETURNING *`,
      [swiperId, itemId, direction]
    );

    // If ON CONFLICT hit, the swipe already existed — fetch it
    let swipeRow;
    if (swipeResult.rows.length > 0) {
      swipeRow = swipeResult.rows[0];
    } else {
      const existing = await client.query(
        'SELECT * FROM swipes WHERE swiper_id = $1 AND item_id = $2',
        [swiperId, itemId]
      );
      swipeRow = existing.rows[0];
    }

    // 3. If left swipe, we're done
    if (direction === 'left') {
      await client.query('COMMIT');
      res.status(201).json({ success: true, data: { swipe: formatSwipe(swipeRow), match: null } });
      return;
    }

    // 4. Check for reverse swipe: does the item owner have a RIGHT swipe
    //    on any of MY active items that doesn't already have a match?
    const reverseResult = await client.query(
      `SELECT s.id, s.item_id AS their_swiped_item_id
       FROM swipes s
       JOIN clothing_items ci ON ci.id = s.item_id
       WHERE s.swiper_id = $1
         AND s.direction = 'right'
         AND ci.owner_id = $2
         AND ci.is_active = true
         AND NOT EXISTS (
           SELECT 1 FROM matches m
           WHERE (m.item1_id = $3 AND m.item2_id = s.item_id)
              OR (m.item1_id = s.item_id AND m.item2_id = $3)
         )
       LIMIT 1`,
      [itemOwnerId, swiperId, itemId]
    );

    if (reverseResult.rows.length === 0) {
      // No mutual match
      await client.query('COMMIT');
      res.status(201).json({ success: true, data: { swipe: formatSwipe(swipeRow), match: null } });
      return;
    }

    // 5. Create match!
    // item1 = the item that the current swiper swiped right on (owned by itemOwner)
    // item2 = the item that the itemOwner swiped right on (owned by current swiper)
    const theirSwipedItemId = reverseResult.rows[0].their_swiped_item_id;

    const matchResult = await client.query(
      `INSERT INTO matches (user1_id, user2_id, item1_id, item2_id)
       VALUES ($1, $2, $3, $4)
       ON CONFLICT (item1_id, item2_id) DO NOTHING
       RETURNING *`,
      [swiperId, itemOwnerId, itemId, theirSwipedItemId]
    );

    await client.query('COMMIT');

    const match = matchResult.rows.length > 0 ? formatMatch(matchResult.rows[0]) : null;
    res.status(201).json({ success: true, data: { swipe: formatSwipe(swipeRow), match } });
  } catch (err) {
    await client.query('ROLLBACK');
    console.error('Swipe error:', err);
    res.status(500).json({ success: false, error: 'Internal server error' });
  } finally {
    client.release();
  }
});

export default router;
