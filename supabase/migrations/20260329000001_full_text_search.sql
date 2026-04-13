-- Add tsvector column
ALTER TABLE clothing_items ADD COLUMN IF NOT EXISTS search_vector TSVECTOR;

-- Populate existing rows
UPDATE clothing_items SET search_vector =
  to_tsvector('english',
    coalesce(title, '') || ' ' ||
    coalesce(brand, '') || ' ' ||
    coalesce(description, '') || ' ' ||
    coalesce(color, '')
  );

-- GIN index for fast search
CREATE INDEX IF NOT EXISTS clothing_items_search_idx ON clothing_items USING GIN(search_vector);

-- Auto-update trigger
CREATE OR REPLACE FUNCTION update_clothing_item_search_vector()
RETURNS TRIGGER AS $$
BEGIN
  NEW.search_vector := to_tsvector('english',
    coalesce(NEW.title, '') || ' ' ||
    coalesce(NEW.brand, '') || ' ' ||
    coalesce(NEW.description, '') || ' ' ||
    coalesce(NEW.color, '')
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS clothing_items_search_update ON clothing_items;
CREATE TRIGGER clothing_items_search_update
  BEFORE INSERT OR UPDATE OF title, brand, description, color ON clothing_items
  FOR EACH ROW EXECUTE FUNCTION update_clothing_item_search_vector();
