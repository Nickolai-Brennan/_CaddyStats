### Tournament Field

| Column               | Type         | Null | Description                                    |
| -------------------- | ------------ | ---: | ---------------------------------------------- |
| `tournament_id`      | INTEGER      |   No | Tournament FK                                  |
| `player_id`          | INTEGER      |   No | Player FK                                      |
| `entry_status`       | VARCHAR(20)  |   No | Field / Alternate / Withdrawn / DNS / DQ / Cut |
| `status_note`        | VARCHAR(250) |  Yes | Human/provider status detail                   |
| `starting_tee`       | VARCHAR(10)  |  Yes | 1 or 10                                        |
| `tee_time_r1`        | TIMESTAMPTZ  |  Yes | Round 1 tee time                               |
| `tee_wave_r1`        | VARCHAR(10)  |  Yes | AM / PM / Split                                |
| `group_id`           | VARCHAR(50)  |  Yes | Pairing group identifier                       |
| `group_position`     | SMALLINT     |  Yes | Position within group                          |
| `salary`             | INTEGER      |  Yes | DFS salary                                     |
| `sportsbook_odds`    | INTEGER      |  Yes | American odds (+1200 / -110)                   |
| `win_prob`           | NUMERIC(6,5) |  Yes | 0–1 probability                                |
| `top10_prob`         | NUMERIC(6,5) |  Yes | 0–1 probability                                |
| `ownership_proj_pct` | NUMERIC(5,2) |  Yes | 0–100                                          |
| `ranking_system`     | VARCHAR(50)  |  Yes | OWGR / DataGolf / etc.                         |
| `rank_at_lock`       | INTEGER      |  Yes | Rank snapshot                                  |
| `ranking_date`       | DATE         |  Yes | Snapshot date used                             |
| `source`             | VARCHAR(50)  |  Yes | Provider marker                                |
| `extras`             | JSONB        |   No | Provider-specific fields                       |
| `created_at`         | TIMESTAMPTZ  |   No | Created timestamp                              |
| `updated_at`         | TIMESTAMPTZ  |   No | Updated timestamp                              |
