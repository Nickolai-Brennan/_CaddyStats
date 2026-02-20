CREATE SCHEMA IF NOT EXISTS golf_stats;

CREATE TABLE IF NOT EXISTS golf_stats.tournament_field (
    tournament_id        INTEGER NOT NULL
        REFERENCES golf_stats.tournaments(tournament_id)
        ON DELETE CASCADE,

    player_id            INTEGER NOT NULL
        REFERENCES golf_stats.player_basic(player_id)
        ON DELETE RESTRICT,

    -- Entry / status
    entry_status         VARCHAR(20) NOT NULL DEFAULT 'Field'
        CHECK (entry_status IN ('Field','Alternate','Withdrawn','DNS','DQ','Cut')),

    -- Optional: if you want a single canonical status for modeling
    status_note          VARCHAR(250),

    -- Tee/pairing info (often per round; this is “starting” info or R1 defaults)
    starting_tee         VARCHAR(10) CHECK (starting_tee IS NULL OR starting_tee IN ('1','10')),
    tee_time_r1          TIMESTAMPTZ,
    tee_wave_r1          VARCHAR(10) CHECK (tee_wave_r1 IS NULL OR tee_wave_r1 IN ('AM','PM','Split')),

    group_id             VARCHAR(50),          -- provider-defined pairing/group identifier
    group_position       SMALLINT CHECK (group_position IS NULL OR group_position BETWEEN 1 AND 5),

    -- Betting / DFS primitives (optional, but extremely useful)
    salary               INTEGER CHECK (salary IS NULL OR salary >= 0),     -- DFS salary
    sportsbook_odds      INTEGER,                 -- e.g. +1200 / -110 (American odds)
    win_prob             NUMERIC(6,5) CHECK (win_prob IS NULL OR (win_prob >= 0 AND win_prob <= 1)),
    top10_prob           NUMERIC(6,5) CHECK (top10_prob IS NULL OR (top10_prob >= 0 AND top10_prob <= 1)),
    ownership_proj_pct   NUMERIC(5,2) CHECK (ownership_proj_pct IS NULL OR (ownership_proj_pct BETWEEN 0 AND 100)),

    -- World / system rank at lock (optional snapshot fields)
    ranking_system       VARCHAR(50),            -- e.g. 'OWGR', 'DataGolf', 'FedEx'
    rank_at_lock         INTEGER CHECK (rank_at_lock IS NULL OR rank_at_lock >= 1),
    ranking_date         DATE,                   -- ranking snapshot date used

    -- Provider flexibility
    source               VARCHAR(50),
    extras               JSONB NOT NULL DEFAULT '{}'::jsonb,

    created_at           TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at           TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    PRIMARY KEY (tournament_id, player_id)
);

-- Indexing
-- Pull a tournament’s full field quickly
CREATE INDEX IF NOT EXISTS idx_tfield_tournament
  ON golf_stats.tournament_field (tournament_id);

-- Player history across tournaments
CREATE INDEX IF NOT EXISTS idx_tfield_player
  ON golf_stats.tournament_field (player_id, tournament_id);

-- Status filters (WD/DNS etc.)
CREATE INDEX IF NOT EXISTS idx_tfield_status
  ON golf_stats.tournament_field (tournament_id, entry_status);

-- Betting/model features
CREATE INDEX IF NOT EXISTS idx_tfield_salary
  ON golf_stats.tournament_field (tournament_id, salary);

CREATE INDEX IF NOT EXISTS idx_tfield_odds
  ON golf_stats.tournament_field (tournament_id, sportsbook_odds);

-- Ranking snapshot queries
CREATE INDEX IF NOT EXISTS idx_tfield_rank_snapshot
  ON golf_stats.tournament_field (ranking_system, ranking_date, rank_at_lock);

-- Only keep if you query extras
CREATE INDEX IF NOT EXISTS idx_tfield_extras_gin
  ON golf_stats.tournament_field USING GIN (extras);

