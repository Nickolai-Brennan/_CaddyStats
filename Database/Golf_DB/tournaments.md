| Column          | Type          | Null | Constraints              | Description                            |
| --------------- | ------------- | ---- | ------------------------ | -------------------------------------- |
| `tournament_id` | INTEGER       | No   | PK                       | Unique tournament ID                   |
| `course_id`     | INTEGER       | No   | FK → courses             | Primary course for event               |
| `start_date`    | DATE          | No   | `start_date <= end_date` | Tournament start date                  |
| `end_date`      | DATE          | No   |                          | Tournament end date                    |
| `purse`         | NUMERIC(14,2) | Yes  | `>= 0`                   | Total prize pool                       |
| `format`        | VARCHAR(50)   | No   | Enum check               | Stroke / Match / Team / Stableford     |
| `season_year`   | INTEGER       | No   | 1900–2100                | Season identifier                      |
| 'winner_player_id| INTEGER REFERENCES | No  FK -> player_basic(player_id) | 
| `winner`        | VARCHAR(150)  | Yes  |                          | Winner name (denormalized for display) |
| `created_at`    | TIMESTAMPTZ   | No   | default now              | Created timestamp                      |
| `updated_at`    | TIMESTAMPTZ   | No   | default now              | Updated timestamp                      |

