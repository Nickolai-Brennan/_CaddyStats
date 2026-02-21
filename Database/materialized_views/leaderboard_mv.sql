-- leaderboard_mv.sql
-- Materialized leaderboard view: pre-computed for fast API reads.
-- Populated in Phase 2+ (Views & Performance).

CREATE MATERIALIZED VIEW IF NOT EXISTS stats.leaderboard_mv AS
SELECT
    t.id            AS tournament_id,
    t.name          AS tournament_name,
    t.season_year,
    g.id            AS golfer_id,
    g.name          AS golfer_name,
    g.country,
    hr.finish_pos,
    hr.score_to_par
FROM stats.historical_results hr
JOIN stats.tournaments t ON t.id = hr.tournament_id
JOIN stats.golfers      g ON g.id = hr.golfer_id
WITH NO DATA;

-- Unique index required for REFRESH CONCURRENTLY
CREATE UNIQUE INDEX IF NOT EXISTS leaderboard_mv_pk
    ON stats.leaderboard_mv (tournament_id, golfer_id);

-- Refresh: REFRESH MATERIALIZED VIEW CONCURRENTLY stats.leaderboard_mv;
