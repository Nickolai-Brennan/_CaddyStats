  table name - golf_stats.courses

| Column       | Type         | Null | Constraints | Description               |
| ------------ | ------------ | ---- | ----------- | ------------------------- |
| `course_id`  | SERIAL       | No   | PK          | Unique internal course ID |
| `name`       | VARCHAR(250) | No   |             | Course name               |
| `venue`      | VARCHAR(250) | Yes  |             | Venue property name       |
| `par`        | SMALLINT     | Yes  | 54–90       | 18-hole par               |
| `yards`      | INTEGER      | Yes  | 1000–12000  | Total course yardage      |
| `city`       | VARCHAR(100) | Yes  |             | City                      |
| `state`      | VARCHAR(100) | Yes  |             | State/Province            |
| `zip_code`   | VARCHAR(20)  | Yes  |             | Postal code               |
| `country`    | VARCHAR(100) | Yes  |             | Country                   |
| `time_zone`  | VARCHAR(50)  | Yes  |             | Time zone description     |
| `latitude`   | NUMERIC(9,6) | Yes  |             | Geo latitude              |
| `longitude`  | NUMERIC(9,6) | Yes  |             | Geo longitude             |
| `created_at` | TIMESTAMPTZ  | No   | default now | Created timestamp         |
| `updated_at` | TIMESTAMPTZ  | No   | default now | Updated timestamp         |
