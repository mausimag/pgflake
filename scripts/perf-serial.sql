SET client_min_messages TO WARNING;

DROP TABLE IF EXISTS simple_test;

CREATE SEQUENCE table_id_seq;

CREATE TABLE simple_test (
    x bigint NOT NULL DEFAULT nextval('table_id_seq'),
    y bigint
);

\timing
INSERT INTO simple_test (y) SELECT generate_series(1, :MAX_SERIAL);
\timing

DROP TABLE simple_test;
DROP SEQUENCE table_id_seq;

