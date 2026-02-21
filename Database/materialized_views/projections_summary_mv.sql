-- projections_summary_mv.sql
-- Materialized projections summary: pre-computed per tournament + model version.
-- Populated in Phase 2+ (Views & Performance).

CREATE MATERIALIZED VIEW IF NOT EXISTS stats.projections_summary_mv AS
SELECT
    p.tournament_id,
    p.model_version,
    p.golfer_id,
    g.name          AS golfer_name,
    p.proj_score,
    p.win_prob,
    p.top10_prob,
    p.make_cut_prob,
    p.edge_score
FROM stats.projections p
JOIN stats.golfers g ON g.id = p.golfer_id
WITH NO DATA;

CREATE UNIQUE INDEX IF NOT EXISTS projections_summary_mv_pk
    ON stats.projections_summary_mv (tournament_id, model_version, golfer_id);

-- Refresh: REFRESH MATERIALIZED VIEW CONCURRENTLY stats.projections_summary_mv;
