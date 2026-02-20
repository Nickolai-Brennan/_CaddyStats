### Round Results
'table name - round_results'

| Column            | Type        | Null | Constraints       | Description                           |
| ----------------- | ----------- | ---: | ----------------- | ------------------------------------- |
| `tournament_id`   | INTEGER     |   No | FK → tournaments  | Tournament                            |
| `player_id`       | INTEGER     |   No | FK → player_basic | Player                                |
| `round_number`    | SMALLINT    |   No | `1–10`            | Round number                          |
| `score_strokes`   | SMALLINT    |  Yes | `40–120`          | Round strokes                         |
| `score_to_par`    | SMALLINT    |  Yes |                   | Round vs par (neg allowed)            |
| `course_par`      | SMALLINT    |  Yes | `54–90`           | Par for the course setup that round   |
| `tee_time`        | TIMESTAMPTZ |  Yes |                   | Tee time (timezone-aware if known)    |
| `tee_time_local`  | TIMESTAMP   |  Yes |                   | Tee time local (if provider gives it) |
| `tee_wave`        | VARCHAR(20) |  Yes |                   | AM/PM wave label (provider-defined)   |
| `is_completed`    | BOOLEAN     |   No | default false     | Whether round finished                |
| `status`          | VARCHAR(20) |  Yes |                   | Round status (WD/DQ/etc.)             |
| `holes_completed` | SMALLINT    |  Yes | `0–18`            | Holes completed                       |
| `extras`          | JSONB       |   No | default `{}`      | Provider-specific extra fields        |
| `source`          | VARCHAR(50) |  Yes |                   | Data provider marker                  |
| `created_at`      | TIMESTAMPTZ |   No | default now       | Created timestamp                     |
| `updated_at`      | TIMESTAMPTZ |   No | default now       | Updated timestamp                     |

