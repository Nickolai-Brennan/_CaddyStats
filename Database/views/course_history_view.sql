-- course_history_view.sql
-- Course history view: past tournament finishes for each golfer per course.
-- Populated in Phase 2+ (Views & Performance).

CREATE OR REPLACE VIEW stats.course_history_view AS
SELECT
    c.id            AS course_id,
    c.name          AS course_name,
    t.id            AS tournament_id,
    t.name          AS tournament_name,
    t.season_year,
    g.id            AS golfer_id,
    g.name          AS golfer_name,
    hr.finish_pos,
    hr.score_to_par
FROM stats.historical_results hr
JOIN stats.tournaments t ON t.id = hr.tournament_id
JOIN stats.courses     c ON c.id = t.course_id
JOIN stats.golfers     g ON g.id = hr.golfer_id
ORDER BY c.id, g.id, t.start_date DESC;
