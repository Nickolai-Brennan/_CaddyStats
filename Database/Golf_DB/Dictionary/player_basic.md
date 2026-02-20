### Table Documentation (Data Dictionary)
### "player_basic"

| Column           | Type        | Null | Constraints    | Description                                                                                |
| ---------------- | ----------- | ---: | -------------- | ------------------------------------------------------------------------------------------ |
| `player_id`      | INTEGER     |   No | PK             | The unique ID of the golfer                                                                |
| `first_name`     | VARCHAR(50) |  Yes |                | The first name of the golfer                                                               |
| `last_name`      | VARCHAR(50) |  Yes |                | The last name of the golfer                                                                |
| `weight_lbs`     | INTEGER     |  Yes | `50–450`       | The golfer's weight (in pounds)                                                            |
| `swings`         | CHAR(1)     |  Yes | `IN ('R','L')` | Indicates whether this golfer swings right-handed (R) or left-handed (L)                   |
| `pga_debut_year` | INTEGER     |  Yes | `1800–2100`    | The year that this golfer made his PGA debut                                               |
| `country`        | VARCHAR(50) |  Yes |                | The country where this golfer is from                                                      |
| `birth_date`     | DATE        |  Yes |                | The golfer's date of birth                                                                 |
| `birth_city`     | VARCHAR(50) |  Yes |                | The city where this golfer was born                                                        |
| `birth_state`    | VARCHAR(50) |  Yes |                | The state where this golfer was born (null if born outside US/Canada/Australia per source) |
| `college`        | VARCHAR(50) |  Yes |                | The college that this golfer attended                                                      |
| `created_at`     | TIMESTAMPTZ |   No | default now    | Row created timestamp                                                                      |
| `updated_at`     | TIMESTAMPTZ |   No | default now    | Row updated timestamp                                                                      |
