\echo Use "CREATE EXTENSION pgflake" to load this file. \quit

CREATE FUNCTION pgflake_generate() 
RETURNS bigint 
AS 'MODULE_PATHNAME', 'pgflake_generate'
STRICT LANGUAGE C PARALLEL SAFE;

CREATE FUNCTION pgflake_extract_time(bigint) 
RETURNS bigint 
AS 'MODULE_PATHNAME', 'pgflake_extract_time'
STRICT LANGUAGE C PARALLEL SAFE;

CREATE FUNCTION pgflake_extract_instance(bigint) 
RETURNS smallint 
AS 'MODULE_PATHNAME', 'pgflake_extract_instance'
STRICT LANGUAGE C PARALLEL SAFE;

CREATE FUNCTION pgflake_extract_sequence(bigint) 
RETURNS smallint 
AS 'MODULE_PATHNAME', 'pgflake_extract_sequence'
STRICT LANGUAGE C PARALLEL SAFE;