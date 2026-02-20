CREATE SCHEMA IF NOT EXISTS golf_stats;

CREATE TABLE IF NOT EXISTS golf_stats.round_results (
    tournament_id        INTEGER NOT NULL
        REFERENCES golf_stats.tournaments(tournament_id)
        ON DELETE CASCADE,

    player_id            INTEGER NOT NULL
        REFERENCES golf_stats.player_basic(player_id)
        ON DELETE RESTRICT,

    round_number         SMALLINT NOT NULL
        CHECK (round_number BETWEEN 1 AND 10),

    -- Scoring
    score_strokes        SMALLINT CHECK (score_strokes IS NULL OR score_strokes BETWEEN 40 AND 120),
    score_to_par         SMALLINT,  -- negative allowed
    course_par           SMALLINT CHECK (course_par IS NULL OR course_par BETWEEN 54 AND 90),

    -- Timing / tee info
    tee_time             TIMESTAMPTZ,     -- store with timezone if known
    tee_time_local       TIMESTAMP,       -- optional: provider local time (if you ingest it)
    tee_wave             VARCHAR(20),     -- e.g. 'AM', 'PM', 'Split', 'Late', etc. (provider-defined)

    -- Status
    is_completed         BOOLEAN NOT NULL DEFAULT FALSE,
    status               VARCHAR(20),     -- e.g. 'OK', 'WD', 'DQ', 'DNS', 'CUT' (round-level)
    holes_completed      SMALLINT CHECK (holes_completed IS NULL OR holes_completed BETWEEN 0 AND 18),

    -- Optional: keep provider payload flexible without schema churn
    extras               JSONB NOT NULL DEFAULT '{}'::jsonb,

    source               VARCHAR(50),

    created_at           TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at           TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    PRIMARY KEY (tournament_id, player_id, round_number),

    -- Consistency checks
    CONSTRAINT chk_completed_holes
      CHECK (
        is_completed = FALSE
        OR holes_completed IS NULL
        OR holes_completed = 18
      )
);

-- Indexes (high read patterns)
CREATE INDEX IF NOT EXISTS idx_round_results_tournament_round
  ON golf_stats.round_results (tournament_id, round_number);

CREATE INDEX IF NOT EXISTS idx_round_results_player
  ON golf_stats.round_results (player_id, tournament_id);

CREATE INDEX IF NOT EXISTS idx_round_results_tee_time
  ON golf_stats.round_results (tournament_id, tee_time);

CREATE INDEX IF NOT EXISTS idx_round_results_status
  ON golf_stats.round_results (tournament_id, status);

-- JSONB index if you actually query extras (otherwise remove to save write cost)
CREATE INDEX IF NOT EXISTS idx_round_results_extras_gin
  ON golf_stats.round_results USING GIN (extras);

-- Optional (Recommended) FK consistency with tournament_results
ALTER TABLE golf_stats.round_results
ADD CONSTRAINT fk_round_results_to_tournament_results
FOREIGN KEY (tournament_id, player_id)
REFERENCES golf_stats.tournament_results(tournament_id, player_id)
ON DELETE CASCADE;
