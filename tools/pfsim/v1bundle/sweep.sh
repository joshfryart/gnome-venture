#!/bin/bash
# bash sweep.sh "BOTS" OFFSETS MULT label=json label=json ...   quick comparison of rule variants (at-level summary line per bot)
cd "$(dirname "$0")"; bots=$1; offs=$2; mult=$3; shift 3
for kv in "$@"; do lab=${kv%%=*}; cfg=${kv#*=}; bash par.sh "$lab" "$cfg" "$bots" "$offs" "$mult" > /dev/null; echo "== $lab $cfg"; php agg.php "out/$lab.jsonl" | tail -n +4; done
