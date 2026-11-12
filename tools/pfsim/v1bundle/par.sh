#!/bin/bash
# bash par.sh LABEL 'V1-JSON' "bot1 bot2 ..." OFFSETS [MULT]   -> out/LABEL.jsonl (4 shards per bot, in parallel; out/ is not committed)
cd "$(dirname "$0")"; lab=$1; cfg=$2; bots=$3; offs=$4; mult=${5:-1}
mkdir -p out/parts
for b in $bots; do for i in 0 1 2 3; do echo "$b $i"; done; done | V1="$cfg" xargs -P ${JOBS:-4} -L1 bash -c 'php run.php $0 '"$offs"' $1/4 '"$mult"' > out/parts/'"$lab"'.$0.$1'
for b in $bots; do for i in 0 1 2 3; do cat "out/parts/$lab.$b.$i"; done; done > "out/$lab.jsonl"; wc -l < "out/$lab.jsonl"
