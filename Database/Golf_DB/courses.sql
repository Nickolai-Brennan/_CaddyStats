-- Create schema
CREATE SCHEMA IF NOT EXISTS golf_stats;

-- Courses table
CREATE TABLE IF NOT EXISTS golf_stats.courses (
    course_id      SERIAL PRIMARY KEY,

    name           VARCHAR(250) NOT NULL,         -- Course name
    venue          VARCHAR(250),                  -- Venue name (if different)
    
    par            SMALLINT CHECK (par BETWEEN 54 AND 90),
    yards          INTEGER CHECK (yards BETWEEN 1000 AND 12000),

    city           VARCHAR(100),
    state          VARCHAR(100),
    zip_code       VARCHAR(20),
    country        VARCHAR(100),

    time_zone      VARCHAR(50),                   -- Recommend IANA TZ in future

    latitude       NUMERIC(9,6),                  -- Optional future geospatial
    longitude      NUMERIC(9,6),

    created_at     TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at     TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT uq_courses_name_location
        UNIQUE (name, city, state, country)
);

-- Indexes for common query patterns
CREATE INDEX IF NOT EXISTS idx_courses_name
    ON golf_stats.courses (name);

CREATE INDEX IF NOT EXISTS idx_courses_country
    ON golf_stats.courses (country);

CREATE INDEX IF NOT EXISTS idx_courses_city_state
    ON golf_stats.courses (city, state);
