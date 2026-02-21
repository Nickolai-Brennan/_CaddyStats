-- rolling_form_mv.sql
-- Materialized rolling form view: pre-computed strokes-gained rolling averages.
-- Populated in Phase 2+ (Views & Performance).

CREATE MATERIALIZED VIEW IF NOT EXISTS stats.rolling_form_mv AS
SELECT
    prs.golfer_id,
    g.name                              AS golfer_name,
    AVG(prs.sg_total)                   AS avg_sg_total,
    AVG(prs.sg_off_tee)                 AS avg_sg_off_tee,
    AVG(prs.sg_app)                     AS avg_sg_app,
    AVG(prs.sg_arg)                     AS avg_sg_arg,
    AVG(prs.sg_putt)                    AS avg_sg_putt,
    COUNT(DISTINCT prs.tournament_id)   AS events_included
FROM stats.player_round_stats prs
JOIN stats.golfers g ON g.id = prs.golfer_id
GROUP BY prs.golfer_id, g.name
WITH NO DATA;

CREATE UNIQUE INDEX IF NOT EXISTS rolling_form_mv_pk
    ON stats.rolling_form_mv (golfer_id);

-- Refresh: REFRESH MATERIALIZED VIEW CONCURRENTLY stats.rolling_form_mv;
