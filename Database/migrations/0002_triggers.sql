-- updated_at trigger (shared)
CREATE OR REPLACE FUNCTION public.set_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Soft delete helper consistency is enforced via CHECK constraints per-table.

-- Search vector trigger (for FTS)
CREATE OR REPLACE FUNCTION website_content.set_post_search_vector()
RETURNS TRIGGER AS $$
BEGIN
  NEW.search_vector :=
    setweight(to_tsvector('english', coalesce(NEW.title,'')), 'A') ||
    setweight(to_tsvector('english', coalesce(NEW.excerpt,'')), 'B');
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION website_content.set_product_search_vector()
RETURNS TRIGGER AS $$
BEGIN
  NEW.search_vector :=
    setweight(to_tsvector('english', coalesce(NEW.name,'')), 'A') ||
    setweight(to_tsvector('english', coalesce(NEW.description,'')), 'B');
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;
