### Player Rankings
Table Name - player_rankings

| Column           | Type          | Null | Description                         |
| ---------------- | ------------- | ---: | ----------------------------------- |
| `ranking_id`     | BIGSERIAL     |   No | Internal PK                         |
| `player_id`      | INTEGER       |   No | FK to `player_basic`                |
| `ranking_date`   | DATE          |   No | Effective date of ranking snapshot  |
| `ranking_system` | VARCHAR(50)   |   No | OWGR / FedEx / DataGolf / etc.      |
| `tour`           | VARCHAR(50)   |  Yes | PGA/DPWT/LIV/LPGA/etc.              |
| `category`       | VARCHAR(50)   |  Yes | Overall / SG Total / Putting / etc. |
| `season_year`    | INTEGER       |  Yes | Season tag                          |
| `rank`           | INTEGER       |   No | Rank position                       |
| `points`         | NUMERIC(12,4) |  Yes | Points (if system uses it)          |
| `rating`         | NUMERIC(10,4) |  Yes | Rating/Elo-like metric              |
| `rank_change`    | INTEGER       |  Yes | +/- movement                        |
| `points_change`  | NUMERIC(12,4) |  Yes | points delta                        |
| `source`         | VARCHAR(50)   |  Yes | provider marker                     |
| `extras`         | JSONB         |   No | provider-specific fields            |
| `created_at`     | TIMESTAMPTZ   |   No | created                             |
| `updated_at`     | TIMESTAMPTZ   |   No | updated                             |
