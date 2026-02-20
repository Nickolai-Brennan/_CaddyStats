CREATE SCHEMA IF NOT EXISTS golf_stats;

CREATE TABLE IF NOT EXISTS golf_stats.player_rankings (
    ranking_id        BIGSERIAL PRIMARY KEY,

    player_id         INTEGER NOT NULL
        REFERENCES golf_stats.player_basic(player_id)
        ON DELETE RESTRICT,

    -- Snapshot date for this ranking (the effective date of the rank)
    ranking_date      DATE NOT NULL,

    -- Ranking system identity (OWGR, FedExCup, DataGolf, etc.)
    ranking_system    VARCHAR(50) NOT NULL,

    -- Optional dimensions (tour / gender / league / category)
    tour              VARCHAR(50),          -- e.g. 'PGA', 'DPWT', 'LIV', 'KFT', 'LPGA'
    category          VARCHAR(50),          -- e.g. 'Overall', 'Stroke', 'SG Total', 'Putting', etc.
    season_year       INTEGER CHECK (season_year IS NULL OR (season_year BETWEEN 1900 AND 2100)),

    -- The actual ranking values
    rank              INTEGER NOT NULL CHECK (rank >= 1),
    points            NUMERIC(12,4) CHECK (points IS NULL OR points >= 0),
    rating            NUMERIC(10,4) CHECK (rating IS NULL OR rating >= 0), -- optional: Elo-like / proprietary rating

    -- Movement (optional but super useful)
    rank_change       INTEGER,              -- +/- from previous snapshot
    points_change     NUMERIC(12,4),

    -- Provider metadata
    source            VARCHAR(50),          -- e.g. 'owgr', 'pga', 'datagolf'
    extras            JSONB NOT NULL DEFAULT '{}'::jsonb,

    created_at        TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at        TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    -- Prevent duplicates for the same snapshot
    CONSTRAINT uq_player_rankings_snapshot
      UNIQUE (player_id, ranking_date, ranking_system, COALESCE(tour,''), COALESCE(category,''), COALESCE(season_year, -1))
);

-- Indexing

-- Most common: latest rank lookups
CREATE INDEX IF NOT EXISTS idx_player_rankings_player_date
  ON golf_stats.player_rankings (player_id, ranking_date DESC);

-- Filter by system + date (leaderboards, weekly pulls)
CREATE INDEX IF NOT EXISTS idx_player_rankings_system_date
  ON golf_stats.player_rankings (ranking_system, ranking_date DESC);

-- Fast “top N” queries for a given system/date/tour
CREATE INDEX IF NOT EXISTS idx_player_rankings_topn
  ON golf_stats.player_rankings (ranking_system, ranking_date, tour, category, rank);

-- If you query extras, keep; otherwise drop to reduce write overhead
CREATE INDEX IF NOT EXISTS idx_player_rankings_extras_gin
  ON golf_stats.player_rankings USING GIN (extras);

-- Views
CREATE OR REPLACE VIEW golf_stats.v_player_rankings_latest AS
SELECT DISTINCT ON (player_id, ranking_system, COALESCE(tour,''), COALESCE(category,''), COALESCE(season_year, -1))
  ranking_id,
  player_id,
  ranking_system,
  tour,
  category,
  season_year,
  ranking_date,
  rank,
  points,
  rating,
  rank_change,
  points_change,
  source,
  extras
FROM golf_stats.player_rankings
ORDER BY
  player_id,
  ranking_system,
  COALESCE(tour,''),
  COALESCE(category,''),
  COALESCE(season_year, -1),
  ranking_date DESC,
  ranking_id DESC;
