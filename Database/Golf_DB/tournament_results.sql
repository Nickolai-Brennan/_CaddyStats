CREATE SCHEMA IF NOT EXISTS golf_stats;

CREATE TABLE IF NOT EXISTS golf_stats.tournament_results (
    tournament_id        INTEGER NOT NULL
        REFERENCES golf_stats.tournaments(tournament_id)
        ON DELETE CASCADE,

    player_id            INTEGER NOT NULL
        REFERENCES golf_stats.player_basic(player_id)
        ON DELETE RESTRICT,

    -- Leaderboard outputs
    finish_position      INTEGER CHECK (finish_position IS NULL OR finish_position >= 1),
    finish_text          VARCHAR(20),  -- e.g. '1', 'T2', 'CUT', 'WD', 'DQ', 'DNS'

    score_total          INTEGER,      -- total strokes (if you ingest it)
    score_to_par         INTEGER,      -- e.g. -12 stored as -12
    rounds_completed     SMALLINT CHECK (rounds_completed IS NULL OR rounds_completed BETWEEN 0 AND 10),

    -- Earnings / points (optional but very common)
    earnings             NUMERIC(14,2) CHECK (earnings IS NULL OR earnings >= 0),
    fedex_points         NUMERIC(10,2) CHECK (fedex_points IS NULL OR fedex_points >= 0),

    -- Status flags
    is_winner            BOOLEAN NOT NULL DEFAULT FALSE,
    made_cut             BOOLEAN,      -- NULL if event has no cut or unknown
    is_tied              BOOLEAN,      -- indicates T-positions (optional convenience)

    -- Metadata
    source               VARCHAR(50),  -- data provider identifier if needed
    created_at           TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at           TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    PRIMARY KEY (tournament_id, player_id),

    -- Winner consistency: if flagged winner, must be position 1 unless finish_text indicates otherwise
    CONSTRAINT chk_winner_position
      CHECK (
        is_winner = FALSE
        OR finish_position IS NULL
        OR finish_position = 1
      )
);

-- Indexeing Performance Focused

-- Fast leaderboard pulls by tournament
CREATE INDEX IF NOT EXISTS idx_tr_results_tournament_position
  ON golf_stats.tournament_results (tournament_id, finish_position);

-- Player history queries (last N tournaments, etc.)
CREATE INDEX IF NOT EXISTS idx_tr_results_player_tournament
  ON golf_stats.tournament_results (player_id, tournament_id);

-- “Winners by season” style queries (join tournaments)
CREATE INDEX IF NOT EXISTS idx_tr_results_is_winner
  ON golf_stats.tournament_results (is_winner)
  WHERE is_winner = TRUE;

-- Common filters for cuts / withdrawals
CREATE INDEX IF NOT EXISTS idx_tr_results_finish_text
  ON golf_stats.tournament_results (finish_text);

CREATE INDEX IF NOT EXISTS idx_tr_results_made_cut
  ON golf_stats.tournament_results (tournament_id, made_cut);
