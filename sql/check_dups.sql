CREATE EXTENSION IF NOT EXISTS pgflake;

CREATE TABLE simple_test (x bigint, y bigint NOT NULL DEFAULT pgflake_generate());

INSERT INTO simple_test (x) SELECT generate_series(1, 100000);

SELECT COUNT(y), y
FROM simple_test 
GROUP BY y
HAVING count(y) > 1
ORDER BY COUNT(y);

DROP TABLE simple_test;

DROP EXTENSION pgflake;
