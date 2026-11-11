#!/bin/bash
# usage: par.sh jobsfile
cd "$(dirname "$0")"
while IFS='|' read -r lab env args; do echo "$lab|$env|$args"; done < "$1" | xargs -P 4 -I{} bash -c 'IFS="|" read -r lab env args <<< "{}"; env $env php ${SCRIPT:-run.php} $args > out2/$lab.txt 2>&1'
