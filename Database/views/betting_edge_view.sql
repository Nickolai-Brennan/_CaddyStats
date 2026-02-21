-- betting_edge_view.sql
-- Betting edge view: compares model probability vs. implied odds probability.
-- Populated in Phase 2+ (Views & Performance).

CREATE OR REPLACE VIEW stats.betting_edge_view AS
SELECT
    p.tournament_id,
    p.golfer_id,
    g.name                          AS golfer_name,
    p.model_version,
    p.win_prob                      AS model_prob,
    bo.book,
    bo.market,
    bo.implied_prob,
    ROUND((p.win_prob - bo.implied_prob)::numeric, 4) AS edge
FROM stats.projections p
JOIN stats.betting_odds bo
    ON bo.tournament_id = p.tournament_id
   AND bo.golfer_id     = p.golfer_id
   AND bo.market        = 'win'
JOIN stats.golfers g ON g.id = p.golfer_id
WHERE p.win_prob IS NOT NULL;
