import { Router, Request, Response } from 'express';
import { z } from 'zod';
import pool from '../db';
import { authMiddleware } from '../middleware/auth';
import { upload } from '../middleware/upload';

const router = Router();

// ── Zod Schemas ──────────────────────────────────────────────

const createItemSchema = z.object({
  title: z.string().min(1).max(100),
  description: z.string().max(500).optional(),
  brand: z.string().max(100).optional(),
  size: z.string().max(10).optional(),
  clothingType: z.enum(['top', 'bottom', 'dress', 'outerwear', 'shoes', 'accessory']),
  categoryId: z.coerce.number().int().positive(),
  condition: z.enum(['new_with_tags', 'like_new', 'good', 'fair']),
  color: z.string().max(50).optional(),
  attributes: z.string().optional(), // JSON string
});

// ── Helpers ──────────────────────────────────────────────────

function formatItem(row: any) {
  return {
    id: row.id,
    ownerId: row.owner_id,
    title: row.title,
    description: row.description,
    brand: row.brand,
    size: row.size,
    clothingType: row.clothing_type,
    categoryId: row.category_id,
    condition: row.condition,
    color: row.color,
    images: row.images || [],
    attributes: row.attributes || {},
    isActive: row.is_active,
    createdAt: row.created_at,
  };
}

function formatFeedItem(row: any) {
  return {
    ...formatItem(row),
    owner: {
      id: row.owner_id,
      displayName: row.owner_display_name,
      avatarUrl: row.owner_avatar_url,
      city: row.owner_city,
    },
  };
}

// ── GET /items/feed ──────────────────────────────────────────

router.get('/feed', authMiddleware, async (req: Request, res: Response) => {
  try {
    const limit = Math.min(parseInt(req.query.limit as string) || 20, 50);
    const cursor = req.query.cursor as string | undefined;

    let query = `
      SELECT ci.*,
             u.display_name AS owner_display_name,
             u.avatar_url   AS owner_avatar_url,
             u.city         AS owner_city
      FROM clothing_items ci
      JOIN users u ON u.id = ci.owner_id
      WHERE ci.is_active = true
        AND ci.owner_id != $1
        AND ci.id NOT IN (SELECT item_id FROM swipes WHERE swiper_id = $1)
    `;
    const values: any[] = [req.user!.id];

    if (cursor) {
      query += ` AND ci.created_at < (SELECT created_at FROM clothing_items WHERE id = $${values.length + 1})`;
      values.push(cursor);
    }

    query += ` ORDER BY ci.created_at DESC LIMIT $${values.length + 1}`;
    values.push(limit + 1); // fetch one extra to check hasMore

    const result = await pool.query(query, values);
    const hasMore = result.rows.length > limit;
    const rows = hasMore ? result.rows.slice(0, limit) : result.rows;
    const nextCursor = rows.length > 0 ? rows[rows.length - 1].id : null;

    res.json({
      success: true,
      data: {
        items: rows.map(formatFeedItem),
        cursor: hasMore ? nextCursor : null,
        hasMore,
      },
    });
  } catch (err) {
    console.error('Feed error:', err);
    res.status(500).json({ success: false, error: 'Internal server error' });
  }
});

// ── POST /items ──────────────────────────────────────────────

router.post('/', authMiddleware, upload.array('images', 6), async (req: Request, res: Response) => {
  try {
    const parsed = createItemSchema.safeParse(req.body);
    if (!parsed.success) {
      res.status(400).json({ success: false, error: parsed.error.errors[0].message });
      return;
    }

    const files = req.files as Express.Multer.File[];
    if (!files || files.length === 0) {
      res.status(400).json({ success: false, error: 'At least one image is required' });
      return;
    }

    const { title, description, brand, size, clothingType, categoryId, condition, color, attributes } = parsed.data;

    // Build image URLs from uploaded files
    const images = files.map(f => `/uploads/${f.filename}`);

    let parsedAttributes = {};
    if (attributes) {
      try { parsedAttributes = JSON.parse(attributes); } catch { /* ignore */ }
    }

    const result = await pool.query(
      `INSERT INTO clothing_items (owner_id, title, description, brand, size, clothing_type, category_id, condition, color, images, attributes)
       VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11)
       RETURNING *`,
      [req.user!.id, title, description || null, brand || null, size || null, clothingType, categoryId, condition, color || null, images, parsedAttributes]
    );

    res.status(201).json({ success: true, data: formatItem(result.rows[0]) });
  } catch (err) {
    console.error('Create item error:', err);
    res.status(500).json({ success: false, error: 'Internal server error' });
  }
});

// ── GET /items/:id ───────────────────────────────────────────

router.get('/:id', authMiddleware, async (req: Request, res: Response) => {
  try {
    const result = await pool.query(
      `SELECT ci.*,
              u.display_name AS owner_display_name,
              u.avatar_url   AS owner_avatar_url,
              u.city         AS owner_city
       FROM clothing_items ci
       JOIN users u ON u.id = ci.owner_id
       WHERE ci.id = $1`,
      [req.params.id]
    );

    if (result.rows.length === 0) {
      res.status(404).json({ success: false, error: 'Item not found' });
      return;
    }

    res.json({ success: true, data: formatFeedItem(result.rows[0]) });
  } catch (err) {
    console.error('Get item error:', err);
    res.status(500).json({ success: false, error: 'Internal server error' });
  }
});

// ── DELETE /items/:id ────────────────────────────────────────

router.delete('/:id', authMiddleware, async (req: Request, res: Response) => {
  try {
    const result = await pool.query(
      'UPDATE clothing_items SET is_active = false, updated_at = now() WHERE id = $1 AND owner_id = $2 RETURNING id',
      [req.params.id, req.user!.id]
    );

    if (result.rows.length === 0) {
      res.status(404).json({ success: false, error: 'Item not found or not owned by you' });
      return;
    }

    res.json({ success: true, data: null });
  } catch (err) {
    console.error('Delete item error:', err);
    res.status(500).json({ success: false, error: 'Internal server error' });
  }
});

// ── GET /users/:userId/items ─────────────────────────────────
// Note: this is mounted at /items but handles /users/:userId/items via the main app

export default router;
