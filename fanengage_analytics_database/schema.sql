-- PostgreSQL schema for fanengage_analytics_database
-- Includes tables: poll_events_log, poll_analytics, user_presence, analytics_scheduler_history
-- Indexes are added for optimal analytics query performance.

-------------------------------
-- 1. Table: poll_events_log --
-------------------------------
CREATE TABLE IF NOT EXISTS poll_events_log (
    event_id    SERIAL PRIMARY KEY,
    poll_id     VARCHAR(64) NOT NULL,
    user_id     VARCHAR(64),
    session_id  VARCHAR(128),
    event_type  VARCHAR(32) NOT NULL, -- e.g. created, started, submitted, skipped, ended
    payload     JSONB,
    device_type VARCHAR(32),
    platform    VARCHAR(32), -- e.g. web, ios, android
    geo_location JSONB, -- {country, city, coordinates} if available
    created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_poll_events_log_poll_id    ON poll_events_log(poll_id);
CREATE INDEX IF NOT EXISTS idx_poll_events_log_event_type ON poll_events_log(event_type);
CREATE INDEX IF NOT EXISTS idx_poll_events_log_created_at ON poll_events_log(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_poll_events_log_user_id    ON poll_events_log(user_id);
CREATE INDEX IF NOT EXISTS idx_poll_events_log_session_id ON poll_events_log(session_id);

-------------------------------
-- 2. Table: poll_analytics  --
-------------------------------
CREATE TABLE IF NOT EXISTS poll_analytics (
    id              SERIAL PRIMARY KEY,
    poll_id         VARCHAR(64) NOT NULL,
    period_start    TIMESTAMPTZ NOT NULL,  -- e.g., aggregation period start (for time-series)
    period_end      TIMESTAMPTZ NOT NULL,  -- aggregation period end
    total_votes     INTEGER DEFAULT 0,
    total_skips     INTEGER DEFAULT 0,
    avg_response_time_ms INTEGER DEFAULT NULL,
    engagement_score    FLOAT DEFAULT 0.0,
    device_distribution JSONB, -- {"web": 10, "android": 5, ...}
    country_distribution JSONB, -- {"US": 10, "IN": 7, ...}
    word_cloud      JSONB, -- {"exciting": 8, "boring": 2,...} or NULL for not applicable
    rejection_reasons JSONB, -- {"too_long": 3, "not_interesting": 1,...}
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE (poll_id, period_start, period_end)
);

CREATE INDEX IF NOT EXISTS idx_poll_analytics_poll_id        ON poll_analytics(poll_id);
CREATE INDEX IF NOT EXISTS idx_poll_analytics_created_at     ON poll_analytics(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_poll_analytics_period_start   ON poll_analytics(period_start);
CREATE INDEX IF NOT EXISTS idx_poll_analytics_period_end     ON poll_analytics(period_end);

-------------------------------
-- 3. Table: user_presence   --
-------------------------------
CREATE TABLE IF NOT EXISTS user_presence (
    id              SERIAL PRIMARY KEY,
    user_id         VARCHAR(64) NOT NULL,
    session_id      VARCHAR(128),
    last_heartbeat  TIMESTAMPTZ NOT NULL,
    device_type     VARCHAR(32),
    platform        VARCHAR(32),
    geo_location    JSONB,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_user_presence_user_id        ON user_presence(user_id);
CREATE INDEX IF NOT EXISTS idx_user_presence_last_heartbeat ON user_presence(last_heartbeat DESC);
CREATE INDEX IF NOT EXISTS idx_user_presence_session_id     ON user_presence(session_id);

-----------------------------------------------
-- 4. Table: analytics_scheduler_history     --
-----------------------------------------------
CREATE TABLE IF NOT EXISTS analytics_scheduler_history (
    id                  SERIAL PRIMARY KEY,
    scheduler_type      VARCHAR(64) NOT NULL, -- "poll_event_aggregator", "poll_aggregator_retry"
    status              VARCHAR(32) NOT NULL, -- "success", "failure", "retry"
    started_at          TIMESTAMPTZ NOT NULL,
    finished_at         TIMESTAMPTZ,
    logs                TEXT,
    error_message       TEXT,
    try_count           INTEGER DEFAULT 1,
    meta                JSONB,
    created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_scheduler_history_scheduler_type  ON analytics_scheduler_history(scheduler_type);
CREATE INDEX IF NOT EXISTS idx_scheduler_history_status          ON analytics_scheduler_history(status);
CREATE INDEX IF NOT EXISTS idx_scheduler_history_started_at      ON analytics_scheduler_history(started_at DESC);
CREATE INDEX IF NOT EXISTS idx_scheduler_history_created_at      ON analytics_scheduler_history(created_at DESC);
