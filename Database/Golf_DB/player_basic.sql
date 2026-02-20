-- Schema (recommended)
CREATE SCHEMA IF NOT EXISTS golf_stats;

-- Table
CREATE TABLE IF NOT EXISTS player_basic (
  player_id      INTEGER PRIMARY KEY,                 -- The unique ID of the golfer
  first_name     VARCHAR(50),
  last_name      VARCHAR(50),
  weight_lbs     INTEGER CHECK (weight_lbs BETWEEN 50 AND 450),
  swings         CHAR(1) CHECK (swings IN ('R','L')),
  pga_debut_year INTEGER CHECK (pga_debut_year BETWEEN 1800 AND 2100),
  country        VARCHAR(50),
  birth_date     DATE,
  birth_city     VARCHAR(50),
  birth_state    VARCHAR(50),
  college        VARCHAR(50),

  -- Useful operational fields (optional but recommended)
  created_at     TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at     TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Indexes (practical query patterns)
CREATE INDEX IF NOT EXISTS idx_player_basic_last_name  ON stats.player_basic (last_name);
CREATE INDEX IF NOT EXISTS idx_player_basic_country    ON stats.player_basic (country);
CREATE INDEX IF NOT EXISTS idx_player_basic_birth_date ON stats.player_basic (birth_date);

-- Optional: common search combo
CREATE INDEX IF NOT EXISTS idx_player_basic_name_combo
  ON golf_stats.player_basic (last_name, first_name);

