SET pgflake.instance_id TO 5;

CREATE EXTENSION IF NOT EXISTS pgflake;

CREATE TABLE simple_test (x bigint, y bigint NOT NULL DEFAULT pgflake_generate());

INSERT INTO simple_test (x) SELECT generate_series(1, 10);

SELECT COUNT(1) FROM simple_test WHERE pgflake_extract_instance(y) = 5;

SELECT pgflake_extract_sequence(y) FROM simple_test LIMIT 1;

DROP TABLE simple_test;

DROP EXTENSION pgflake;
