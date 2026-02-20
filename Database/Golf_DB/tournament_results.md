table name - tournament_results

| Column             | Type          | Null | Constraints       | Description                             |
| ------------------ | ------------- | ---: | ----------------- | --------------------------------------- |
| `tournament_id`    | INTEGER       |   No | FK → tournaments  | Tournament                              |
| `player_id`        | INTEGER       |   No | FK → player_basic | Player                                  |
| `finish_position`  | INTEGER       |  Yes | `>= 1`            | Numeric finish rank                     |
| `finish_text`      | VARCHAR(20)   |  Yes |                   | Display finish: `T2`, `CUT`, `WD`, etc. |
| `score_total`      | INTEGER       |  Yes |                   | Total strokes                           |
| `score_to_par`     | INTEGER       |  Yes |                   | Total vs par (negative allowed)         |
| `rounds_completed` | SMALLINT      |  Yes | `0–10`            | Completed rounds                        |
| `earnings`         | NUMERIC(14,2) |  Yes | `>= 0`            | Earnings                                |
| `fedex_points`     | NUMERIC(10,2) |  Yes | `>= 0`            | FedEx points                            |
| `is_winner`        | BOOLEAN       |   No | default false     | Winner flag                             |
| `made_cut`         | BOOLEAN       |  Yes |                   | Cut status                              |
| `is_tied`          | BOOLEAN       |  Yes |                   | Whether finish was tied                 |
| `source`           | VARCHAR(50)   |  Yes |                   | Provider marker                         |
| `created_at`       | TIMESTAMPTZ   |   No | default now       | Created                                 |
| `updated_at`       | TIMESTAMPTZ   |   No | default now       | Updated                                 |


---
### Validation

-- Any duplicate keys should be impossible due to PK, but sanity check
SELECT tournament_id, player_id, COUNT(*)
FROM golf_stats.tournament_results
GROUP BY 1,2
HAVING COUNT(*) > 1;

-- Winners per tournament (should be 1 usually; some events may have co-winners)
SELECT tournament_id, COUNT(*) AS winners
FROM golf_stats.tournament_results
WHERE is_winner = TRUE
GROUP BY tournament_id
ORDER BY winners DESC;

-- Positions that are invalid
SELECT *
FROM golf_stats.tournament_results
WHERE finish_position IS NOT NULL AND finish_position < 1;
