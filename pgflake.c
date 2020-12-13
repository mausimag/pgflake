#include "postgres.h"
#include "fmgr.h"
#include "c.h"
#include "common/int.h"
#include "utils/guc.h"
#include "storage/spin.h"

#include <time.h>
#include <limits.h>
#include <inttypes.h>

#define TIMESTAMP_BITS 41L
#define INSTANCE_BITS 10L
#define SEQUENCE_BITS 12L

#define MAX_INSTANCE_ID ((1L << INSTANCE_BITS) - 1L)

#define INSTANCE_SHIFT SEQUENCE_BITS
#define TIMESTAMP_SHIFT (SEQUENCE_BITS + INSTANCE_BITS)

#define SEQUENCE_MASK ((1L << SEQUENCE_BITS) - 1L)
#define INSTANCE_MASK ((1L << INSTANCE_BITS) - 1L)
#define TIMESTAMP_MASK ((1L << TIMESTAMP_BITS) - 1L)

/* declarations for dynamic loading */
PG_MODULE_MAGIC;

static uint16_t pgflake_instance_id; /* Postgres instance # */
static uint64_t pgflake_start_epoch; /* Epoch start time */

static uint64_t last_time = 0L;
static uint16_t sequence = 0L;
static slock_t mutex;

/* SQL functions */
PG_FUNCTION_INFO_V1(pgflake_generate);
PG_FUNCTION_INFO_V1(pgflake_extract_time);
PG_FUNCTION_INFO_V1(pgflake_extract_instance);
PG_FUNCTION_INFO_V1(pgflake_extract_sequence);

void _PG_init(void);
static uint64_t time_get_curr_unix_msec();
static uint64_t wait_time(uint64_t last_time);
static uint64_t generate_id();
Datum pgflake_extract_time(PG_FUNCTION_ARGS);
Datum pgflake_extract_instance(PG_FUNCTION_ARGS);
Datum pgflake_extract_sequence(PG_FUNCTION_ARGS);
Datum pgflake_generate(PG_FUNCTION_ARGS);

void _PG_init(void)
{
    char *tmp_string_start_epoch;

    DefineCustomIntVariable("pgflake.instance_id",
                            "Sets the id of current intance. It must be unique between instances.",
                            NULL,
                            &pgflake_instance_id,
                            1,
                            1,
                            MAX_INSTANCE_ID,
                            PGC_S_GLOBAL,
                            0,
                            NULL,
                            NULL,
                            NULL);

    DefineCustomStringVariable("pgflake.start_epoch",
                               "Sets the start epoch of current intance.",
                               NULL,
                               &tmp_string_start_epoch,
                               "1314220021721",
                               PGC_S_GLOBAL,
                               0,
                               NULL,
                               NULL,
                               NULL);

    sscanf(tmp_string_start_epoch, "%" SCNu64, &pgflake_start_epoch);

    SpinLockInit(&mutex);
}

static uint64_t
time_get_curr_unix_msec()
{
    struct timespec spec;
    clock_gettime(CLOCK_REALTIME, &spec);
    return (uint64_t)(spec.tv_sec * 1000 + spec.tv_nsec / 1000);
}

static uint64_t
wait_time(uint64_t last_time)
{
    uint64_t tmst = time_get_curr_unix_msec();

    while (tmst <= last_time)
        tmst = time_get_curr_unix_msec();

    return tmst;
}

static uint64_t
generate_id()
{
    uint64_t curr_time = 0;
    uint64_t result = 0;

    curr_time = time_get_curr_unix_msec();

    if (curr_time < last_time)
    {
        ereport(ERROR,
                (errcode(ERRCODE_EXTERNAL_ROUTINE_EXCEPTION),
                 errmsg("clock is moving backwards, rejecting requests until %" PRIu64 " and refusing to generate id for %" PRIu64,
                        last_time,
                        last_time - curr_time)));
    }

    SpinLockAcquire(&mutex);

    if (last_time == curr_time)
    {
        sequence = (sequence + 1) & SEQUENCE_MASK;

        if (sequence == 0)
            curr_time = wait_time(last_time);
    }
    else
        sequence = 0;

    last_time = curr_time;

    SpinLockRelease(&mutex);

    return ((curr_time - pgflake_start_epoch) << TIMESTAMP_SHIFT) |
           ((uint64_t)pgflake_instance_id << INSTANCE_SHIFT) |
           sequence;
}

Datum pgflake_extract_time(PG_FUNCTION_ARGS)
{
    int64 pgfk_id = PG_GETARG_INT64(0);
    PG_RETURN_INT64((pgfk_id >> TIMESTAMP_SHIFT) & TIMESTAMP_MASK);
}

Datum pgflake_extract_instance(PG_FUNCTION_ARGS)
{
    int64 pgfk_id = PG_GETARG_INT64(0);
    PG_RETURN_INT16((pgfk_id >> INSTANCE_SHIFT) & INSTANCE_MASK);
}

Datum pgflake_extract_sequence(PG_FUNCTION_ARGS)
{
    int64 pgfk_id = PG_GETARG_INT64(0);
    PG_RETURN_INT16(pgfk_id & SEQUENCE_MASK);
}

Datum pgflake_generate(PG_FUNCTION_ARGS)
{
    PG_RETURN_INT64(generate_id());
}
