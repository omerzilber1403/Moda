import { Router, Request, Response } from 'express';
import bcrypt from 'bcrypt';
import { z } from 'zod';
import pool from '../db';
import { generateToken } from '../middleware/auth';

const router = Router();

// ── Zod Schemas ──────────────────────────────────────────────

const registerSchema = z.object({
  email: z.string().email(),
  password: z.string().min(6).max(100),
  displayName: z.string().min(1).max(100),
  city: z.string().max(100).optional(),
});

const loginSchema = z.object({
  email: z.string().email(),
  password: z.string().min(1),
});

// ── Helpers ──────────────────────────────────────────────────

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

// ── POST /auth/register ──────────────────────────────────────

router.post('/register', async (req: Request, res: Response) => {
  try {
    const parsed = registerSchema.safeParse(req.body);
    if (!parsed.success) {
      res.status(400).json({ success: false, error: parsed.error.errors[0].message });
      return;
    }

    const { email, password, displayName, city } = parsed.data;

    // Check duplicate email
    const existing = await pool.query('SELECT id FROM users WHERE email = $1', [email]);
    if (existing.rows.length > 0) {
      res.status(409).json({ success: false, error: 'Email already registered' });
      return;
    }

    const passwordHash = await bcrypt.hash(password, 12);
    const result = await pool.query(
      `INSERT INTO users (email, password_hash, display_name, city)
       VALUES ($1, $2, $3, $4)
       RETURNING *`,
      [email, passwordHash, displayName, city || null]
    );

    const user = sanitizeUser(result.rows[0]);
    const token = generateToken({ id: user.id, email: user.email });

    res.status(201).json({ success: true, data: { token, user } });
  } catch (err: any) {
    console.error('Register error:', err);
    res.status(500).json({ success: false, error: 'Internal server error' });
  }
});

// ── POST /auth/login ─────────────────────────────────────────

router.post('/login', async (req: Request, res: Response) => {
  try {
    const parsed = loginSchema.safeParse(req.body);
    if (!parsed.success) {
      res.status(400).json({ success: false, error: parsed.error.errors[0].message });
      return;
    }

    const { email, password } = parsed.data;

    const result = await pool.query('SELECT * FROM users WHERE email = $1', [email]);
    if (result.rows.length === 0) {
      res.status(401).json({ success: false, error: 'Invalid email or password' });
      return;
    }

    const row = result.rows[0];
    const valid = await bcrypt.compare(password, row.password_hash);
    if (!valid) {
      res.status(401).json({ success: false, error: 'Invalid email or password' });
      return;
    }

    const user = sanitizeUser(row);
    const token = generateToken({ id: user.id, email: user.email });

    res.json({ success: true, data: { token, user } });
  } catch (err: any) {
    console.error('Login error:', err);
    res.status(500).json({ success: false, error: 'Internal server error' });
  }
});

export default router;
