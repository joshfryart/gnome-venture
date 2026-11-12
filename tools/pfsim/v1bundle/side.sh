#!/bin/bash
# The side experiments of the write-up (at level, 200+ fights per size). bash side.sh > out/side.txt
cd "$(dirname "$0")"; B='"foe":1.35,"fumble_on":"blocked"'
bash sweep.sh "smartn3" 0,-4,-8 1 n3="{$B}"
bash sweep.sh "chain look smart" 0 1 lim4="{$B,\"limit\":4}" lim4t='{"foe":1.7,"fumble_on":"blocked","limit":4}' lim0="{$B,\"limit\":0}" fany='{"foe":1.55}' nsf="{$B,\"spend_foe\":0}" \
  noground="{$B,\"ground\":0}" noevents="{$B,\"events\":0}" strongenv="{$B,\"sun\":2,\"bramble\":0.12,\"ev\":2}" team0="{$B,\"team\":1}" foe12='{"foe":1.2,"fumble_on":"blocked"}' foe15='{"foe":1.5,"fumble_on":"blocked"}'
SRC=thirds bash sweep.sh "chain look smart" 0 1 thirds="{$B}" thirds15="{$B,\"team\":1.5}" thirds0="{$B,\"team\":1}"
HOARD=0.05 bash sweep.sh "look smart" 0 1 hoard="{$B}"
for l in lim4 nsf thirds thirds15 strongenv noground n3; do echo "-- detail $l"; php agg.php out/$l.jsonl --detail | tail -n +9; done
echo SIDE_DONE
