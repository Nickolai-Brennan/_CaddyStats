CREATE SCHEMA IF NOT EXISTS golf_stats;

CREATE TABLE IF NOT EXISTS golf_stats.tournaments (
    tournament_id   INTEGER PRIMARY KEY,   -- external/source tournament ID

    course_id       INTEGER NOT NULL
        REFERENCES golf_stats.courses(course_id)
        ON DELETE RESTRICT,

    start_date      DATE NOT NULL,
    end_date        DATE NOT NULL,

    purse           NUMERIC(14,2)
        CHECK (purse IS NULL OR purse >= 0),

    format          VARCHAR(50) NOT NULL
        CHECK (format IN ('Stroke','Match','Team','Stableford')),

    season_year     INTEGER NOT NULL
        CHECK (season_year BETWEEN 1900 AND 2100),

    winner          VARCHAR(150),          -- winner display name (can normalize later)

    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT chk_tournament_dates
        CHECK (start_date <= end_date)
);
