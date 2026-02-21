-- 0002_triggers.sql
-- Reusable updated_at trigger function for all website_content tables

CREATE OR REPLACE FUNCTION website_content.set_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
