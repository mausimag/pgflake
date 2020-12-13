SET client_min_messages TO WARNING;

DROP TABLE IF EXISTS simple_test;

CREATE SEQUENCE table_id_seq;

CREATE OR REPLACE FUNCTION next_id(OUT result bigint) AS $$
DECLARE
    our_epoch bigint := 1314220021721;
    seq_id bigint;
    now_millis bigint;
    shard_id int := 5;
BEGIN
    SELECT nextval('table_id_seq') % 1024 INTO seq_id;
    SELECT FLOOR(EXTRACT(EPOCH FROM clock_timestamp()) * 1000) INTO now_millis;
    result := (now_millis - our_epoch) << 23;
    result := result | (shard_id <<10);
    result := result | (seq_id);
END;
    $$ LANGUAGE PLPGSQL;


CREATE TABLE simple_test (
    x bigint NOT NULL DEFAULT next_id(),
    y bigint
);

\timing
INSERT INTO simple_test (y) SELECT generate_series(1, :MAX_SERIAL);
\timing

DROP TABLE simple_test;
DROP FUNCTION next_id;
DROP SEQUENCE table_id_seq;

