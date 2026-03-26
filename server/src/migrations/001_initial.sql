-- FitFlip Database Schema
-- Run: psql $DATABASE_URL -f src/migrations/001_initial.sql

CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- ============================================================
-- USERS
-- ============================================================
CREATE TABLE IF NOT EXISTS users (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  email         VARCHAR(255) NOT NULL UNIQUE,
  password_hash VARCHAR(255) NOT NULL,
  display_name  VARCHAR(100) NOT NULL,
  avatar_url    TEXT,
  bio           VARCHAR(500),
  city          VARCHAR(100),
  preferred_sizes      VARCHAR[] DEFAULT '{}',
  preferred_categories VARCHAR[] DEFAULT '{}',
  created_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at    TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);

-- ============================================================
-- CATEGORIES
-- ============================================================
CREATE TABLE IF NOT EXISTS categories (
  id   SERIAL PRIMARY KEY,
  name VARCHAR(50) NOT NULL UNIQUE,
  slug VARCHAR(50) NOT NULL UNIQUE,
  icon VARCHAR(50)
);

-- Seed default categories
INSERT INTO categories (name, slug, icon) VALUES
  ('Tops',        'tops',        '👕'),
  ('Bottoms',     'bottoms',     '👖'),
  ('Dresses',     'dresses',     '👗'),
  ('Outerwear',   'outerwear',   '🧥'),
  ('Shoes',       'shoes',       '👟'),
  ('Accessories', 'accessories', '🎒')
ON CONFLICT (slug) DO NOTHING;

-- ============================================================
-- CLOTHING ITEMS
-- ============================================================
CREATE TABLE IF NOT EXISTS clothing_items (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  owner_id      UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  title         VARCHAR(100) NOT NULL,
  description   VARCHAR(500),
  brand         VARCHAR(100),
  size          VARCHAR(10),
  clothing_type VARCHAR(20) NOT NULL DEFAULT 'top',
  category_id   INTEGER NOT NULL REFERENCES categories(id),
  condition     VARCHAR(20) NOT NULL,
  color         VARCHAR(50),
  images        TEXT[] NOT NULL DEFAULT '{}',
  attributes    JSONB NOT NULL DEFAULT '{}',
  is_active     BOOLEAN NOT NULL DEFAULT true,
  created_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at    TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_items_owner    ON clothing_items(owner_id);
CREATE INDEX IF NOT EXISTS idx_items_active   ON clothing_items(is_active);
CREATE INDEX IF NOT EXISTS idx_items_category ON clothing_items(category_id);
CREATE INDEX IF NOT EXISTS idx_items_created  ON clothing_items(created_at DESC);

-- ============================================================
-- SWIPES
-- ============================================================
CREATE TABLE IF NOT EXISTS swipes (
  id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  swiper_id  UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  item_id    UUID NOT NULL REFERENCES clothing_items(id) ON DELETE CASCADE,
  direction  VARCHAR(5) NOT NULL CHECK (direction IN ('left', 'right')),
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE(swiper_id, item_id)
);

CREATE INDEX IF NOT EXISTS idx_swipes_swiper_dir ON swipes(swiper_id, direction);
CREATE INDEX IF NOT EXISTS idx_swipes_item_dir   ON swipes(item_id, direction);

-- ============================================================
-- MATCHES
-- ============================================================
CREATE TABLE IF NOT EXISTS matches (
  id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user1_id   UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  user2_id   UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  item1_id   UUID NOT NULL REFERENCES clothing_items(id) ON DELETE CASCADE,
  item2_id   UUID NOT NULL REFERENCES clothing_items(id) ON DELETE CASCADE,
  status     VARCHAR(20) NOT NULL DEFAULT 'active',
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE(item1_id, item2_id)
);

CREATE INDEX IF NOT EXISTS idx_matches_user1  ON matches(user1_id);
CREATE INDEX IF NOT EXISTS idx_matches_user2  ON matches(user2_id);
CREATE INDEX IF NOT EXISTS idx_matches_status ON matches(status);

-- ============================================================
-- MESSAGES
-- ============================================================
CREATE TABLE IF NOT EXISTS messages (
  id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  match_id     UUID NOT NULL REFERENCES matches(id) ON DELETE CASCADE,
  sender_id    UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  content      TEXT NOT NULL,
  message_type VARCHAR(20) NOT NULL DEFAULT 'text',
  read_at      TIMESTAMPTZ,
  created_at   TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_messages_match_created ON messages(match_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_messages_sender        ON messages(sender_id);
CREATE INDEX IF NOT EXISTS idx_messages_unread        ON messages(match_id, read_at);
