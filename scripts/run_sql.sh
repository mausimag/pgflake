#!/usr/bin/env bash

set -u
set -e

SCRIPT=$(realpath -s $0)
SCRIPTPATH=$(dirname $SCRIPT)
TAB=$(printf '\t')

run() {
    ret=$(sudo -i -u postgres psql -d testdb -v ON_ERROR_STOP=1 -v MAX_SERIAL=$2 -X -q -f $SCRIPTPATH/$1)
    IFS=' ' read -r -a ret <<<$ret
    echo ${ret[1]}
}

run_all() {
    echo $(run "perf-ext.sql" $1) $TAB $(run "perf-pl.sql" $1) $TAB $(run "perf-serial.sql" $1)
}

sudo -i -u postgres dropdb testdb --if-exists 2>/dev/null
sudo -i -u postgres createdb testdb

echo "tests $TAB pgflake $TAB pl $TAB serial"
echo "1K $TAB $(run_all 1000)"
echo "10K $TAB $(run_all 10000)"
echo "100K $TAB $(run_all 100000)"
echo "1M $TAB $(run_all 1000000)"

sudo -i -u postgres dropdb testdb
