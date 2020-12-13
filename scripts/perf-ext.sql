SET client_min_messages TO WARNING;

CREATE EXTENSION IF NOT EXISTS pgflake;

DROP TABLE IF EXISTS simple_test;

CREATE TABLE simple_test (
    x bigint NOT NULL DEFAULT pgflake_generate(),
    y bigint
);

\timing
INSERT INTO simple_test (y) SELECT generate_series(1, :MAX_SERIAL);
\timing

DROP TABLE simple_test;
DROP EXTENSION pgflake;