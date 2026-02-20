CREATE SCHEMA IF NOT EXISTS golf_stats;

CREATE TABLE IF NOT EXISTS golf_stats.player_round_stats (
    tournament_id        INTEGER NOT NULL,
    player_id            INTEGER NOT NULL,
    round_number         SMALLINT NOT NULL CHECK (round_number BETWEEN 1 AND 10),

    -- Strokes Gained (round-level)
    sg_off_tee           NUMERIC(6,3),
    sg_approach          NUMERIC(6,3),
    sg_around_green      NUMERIC(6,3),
    sg_putting           NUMERIC(6,3),
    sg_total             NUMERIC(6,3),

    -- Scoring / outcomes
    birdies              SMALLINT CHECK (birdies IS NULL OR birdies BETWEEN 0 AND 18),
    eagles               SMALLINT CHECK (eagles IS NULL OR eagles BETWEEN 0 AND 18),
    pars                 SMALLINT CHECK (pars IS NULL OR pars BETWEEN 0 AND 18),
    bogeys               SMALLINT CHECK (bogeys IS NULL OR bogeys BETWEEN 0 AND 18),
    double_bogeys_plus   SMALLINT CHECK (double_bogeys_plus IS NULL OR double_bogeys_plus BETWEEN 0 AND 18),

    -- Tee-to-green / accuracy
    driving_distance     NUMERIC(6,2) CHECK (driving_distance IS NULL OR driving_distance BETWEEN 0 AND 500), -- yards
    driving_accuracy_pct NUMERIC(5,2) CHECK (driving_accuracy_pct IS NULL OR (driving_accuracy_pct BETWEEN 0 AND 100)),
    fairways_hit         SMALLINT CHECK (fairways_hit IS NULL OR fairways_hit BETWEEN 0 AND 18),
    fairways_total       SMALLINT CHECK (fairways_total IS NULL OR fairways_total BETWEEN 0 AND 18),

    greens_in_reg        SMALLINT CHECK (greens_in_reg IS NULL OR greens_in_reg BETWEEN 0 AND 18),
    gir_pct              NUMERIC(5,2) CHECK (gir_pct IS NULL OR (gir_pct BETWEEN 0 AND 100)),

    -- Short game
    scrambling_pct       NUMERIC(5,2) CHECK (scrambling_pct IS NULL OR (scrambling_pct BETWEEN 0 AND 100)),
    sand_saves_pct       NUMERIC(5,2) CHECK (sand_saves_pct IS NULL OR (sand_saves_pct BETWEEN 0 AND 100)),

    -- Putting
    putts                SMALLINT CHECK (putts IS NULL OR putts BETWEEN 0 AND 60),
    putts_per_gir        NUMERIC(5,3) CHECK (putts_per_gir IS NULL OR putts_per_gir BETWEEN 0 AND 5),
    one_putts            SMALLINT CHECK (one_putts IS NULL OR one_putts BETWEEN 0 AND 18),
    three_putts          SMALLINT CHECK (three_putts IS NULL OR three_putts BETWEEN 0 AND 18),

    -- Proximity / approach quality (yard/feet depends on provider; document later)
    prox_to_hole_avg     NUMERIC(7,3) CHECK (prox_to_hole_avg IS NULL OR prox_to_hole_avg >= 0),

    -- Optional provider flex space (avoid schema churn)
    extras               JSONB NOT NULL DEFAULT '{}'::jsonb,
    source               VARCHAR(50),

    created_at           TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at           TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    PRIMARY KEY (tournament_id, player_id, round_number),

    -- Strong integrity: stats must correspond to an existing round result
    CONSTRAINT fk_player_round_stats_round
      FOREIGN KEY (tournament_id, player_id, round_number)
      REFERENCES golf_stats.round_results (tournament_id, player_id, round_number)
      ON DELETE CASCADE,

    -- Optional sanity: if sg_total is present, it should roughly match sum of components (tolerance)
    CONSTRAINT chk_sg_total_consistency
      CHECK (
        sg_total IS NULL
        OR (sg_off_tee IS NULL AND sg_approach IS NULL AND sg_around_green IS NULL AND sg_putting IS NULL)
        OR (ABS(
              sg_total
              - COALESCE(sg_off_tee, 0)
              - COALESCE(sg_approach, 0)
              - COALESCE(sg_around_green, 0)
              - COALESCE(sg_putting, 0)
            ) <= 0.500)
      )
);

-- Indexing
-- Pull all stats for a tournament round quickly
CREATE INDEX IF NOT EXISTS idx_prs_tournament_round
  ON golf_stats.player_round_stats (tournament_id, round_number);

-- Player history (last N rounds/tournaments)
CREATE INDEX IF NOT EXISTS idx_prs_player
  ON golf_stats.player_round_stats (player_id, tournament_id, round_number);

-- Common feature access patterns
CREATE INDEX IF NOT EXISTS idx_prs_sg_total
  ON golf_stats.player_round_stats (tournament_id, round_number, sg_total);

CREATE INDEX IF NOT EXISTS idx_prs_putts
  ON golf_stats.player_round_stats (tournament_id, round_number, putts);

-- Only keep this if you actually query extras often
CREATE INDEX IF NOT EXISTS idx_prs_extras_gin
  ON golf_stats.player_round_stats USING GIN (extras);
