#!/bin/bash
# bash sweep3.sh "BOTS" OFFSETS MULT label=json ...   sim 3: compare rule variants (per-size lines). METRIC=0 skips the best-move measure (faster).
cd "$(dirname "$0")"; bots=$1; offs=$2; mult=$3; shift 3
for kv in "$@"; do lab=${kv%%=*}; cfg=${kv#*=}; bash par.sh "$lab" "$cfg" "$bots" "$offs" "$mult" > /dev/null; echo "== $lab $cfg"; php agg3.php "out/$lab.jsonl" --sizes | cut -c1-${CUT:-46}; done
