-- leaderboard_view.sql
-- Live leaderboard view: joins tournaments, historical_results, golfers.
-- Populated in Phase 2+ (Views & Performance).

CREATE OR REPLACE VIEW stats.leaderboard_view AS
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
ORDER BY t.start_date DESC, hr.finish_pos ASC NULLS LAST;
