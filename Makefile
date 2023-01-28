MODULE_big = pgflake

PG_CPPFLAGS = --std=c99
OBJS = pgflake.o

EXTENSION = pgflake
DATA = pgflake--0.0.1.sql
PGFILEDESC = "pgflake - generate unique ID numbers"

REGRESS = pgflake

UNAME_S := $(shell uname -s)
ifeq ($(UNAME_S),Darwin)
	PG_CPPFLAGS += -I/usr/local/include
endif

PG_CONFIG = pg_config
PGXS := $(shell $(PG_CONFIG) --pgxs)
include $(PGXS)

regress:
	/usr/lib/postgresql/13/lib/pgxs/src/test/regress/pg_regress --schedule=test_schedule

perf:
	./scripts/run_sql.sh > ./scripts/plot.tsv
	gnuplot -p ./scripts/plot.gnu < ./scripts/plot.tsv