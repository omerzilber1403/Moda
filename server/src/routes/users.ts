import { Router, Request, Response } from 'express';
import { z } from 'zod';
import pool from '../db';
import { authMiddleware } from '../middleware/auth';

const router = Router();

function sanitizeUser(row: any) {
  return {
    id: row.id,
    email: row.email,
    displayName: row.display_name,
    avatarUrl: row.avatar_url,
    bio: row.bio,
    city: row.city,
    preferredSizes: row.preferred_sizes || [],
    preferredCategories: row.preferred_categories || [],
    createdAt: row.created_at,
  };
}

const updateSchema = z.object({
  displayName: z.string().min(1).max(100).optional(),
  bio: z.string().max(500).optional(),
  city: z.string().max(100).optional(),
  avatarUrl: z.string().optional(),
  preferredSizes: z.array(z.string()).optional(),
  preferredCategories: z.array(z.string()).optional(),
});

// ── GET /users/me ────────────────────────────────────────────

router.get('/me', authMiddleware, async (req: Request, res: Response) => {
  try {
    const result = await pool.query('SELECT * FROM users WHERE id = $1', [req.user!.id]);
    if (result.rows.length === 0) {
      res.status(404).json({ success: false, error: 'User not found' });
      return;
    }
    res.json({ success: true, data: sanitizeUser(result.rows[0]) });
  } catch (err) {
    console.error('Get user error:', err);
    res.status(500).json({ success: false, error: 'Internal server error' });
  }
});

// ── PATCH /users/me ──────────────────────────────────────────

router.patch('/me', authMiddleware, async (req: Request, res: Response) => {
  try {
    const parsed = updateSchema.safeParse(req.body);
    if (!parsed.success) {
      res.status(400).json({ success: false, error: parsed.error.errors[0].message });
      return;
    }

    const fields = parsed.data;
    const setClauses: string[] = [];
    const values: any[] = [];
    let i = 1;

    if (fields.displayName !== undefined) { setClauses.push(`display_name = $${i++}`); values.push(fields.displayName); }
    if (fields.bio !== undefined) { setClauses.push(`bio = $${i++}`); values.push(fields.bio); }
    if (fields.city !== undefined) { setClauses.push(`city = $${i++}`); values.push(fields.city); }
    if (fields.avatarUrl !== undefined) { setClauses.push(`avatar_url = $${i++}`); values.push(fields.avatarUrl); }
    if (fields.preferredSizes !== undefined) { setClauses.push(`preferred_sizes = $${i++}`); values.push(fields.preferredSizes); }
    if (fields.preferredCategories !== undefined) { setClauses.push(`preferred_categories = $${i++}`); values.push(fields.preferredCategories); }

    if (setClauses.length === 0) {
      res.status(400).json({ success: false, error: 'No fields to update' });
      return;
    }

    setClauses.push(`updated_at = now()`);
    values.push(req.user!.id);

    const result = await pool.query(
      `UPDATE users SET ${setClauses.join(', ')} WHERE id = $${i} RETURNING *`,
      values
    );

    res.json({ success: true, data: sanitizeUser(result.rows[0]) });
  } catch (err) {
    console.error('Update user error:', err);
    res.status(500).json({ success: false, error: 'Internal server error' });
  }
});

// ── GET /users/:id ───────────────────────────────────────────

router.get('/:id', authMiddleware, async (req: Request, res: Response) => {
  try {
    const result = await pool.query('SELECT * FROM users WHERE id = $1', [req.params.id]);
    if (result.rows.length === 0) {
      res.status(404).json({ success: false, error: 'User not found' });
      return;
    }
    // Public profile: exclude email
    const row = result.rows[0];
    res.json({
      success: true,
      data: {
        id: row.id,
        displayName: row.display_name,
        avatarUrl: row.avatar_url,
        bio: row.bio,
        city: row.city,
        createdAt: row.created_at,
      },
    });
  } catch (err) {
    console.error('Get user by id error:', err);
    res.status(500).json({ success: false, error: 'Internal server error' });
  }
});

export default router;
