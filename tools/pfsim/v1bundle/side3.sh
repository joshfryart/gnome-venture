#!/bin/bash
# Sim 3: the main table and the side experiments. bash side3.sh > out/side3.txt   (about 45 minutes on 4 cores)
cd "$(dirname "$0")"
F='"bar":{"small":1.6,"medium":1.6,"large":1.6,"boss":1.25},"foe":{"small":1.05,"medium":0.90,"large":0.86,"boss":1.03},"nev":{"small":1,"medium":2,"large":2,"boss":2}'   # the recommended numbers (everything else is the default in mkengine.py)
bash par.sh final3 "{$F}" "random chain greedy never3 look-ge look smartn3 smart-ge smart" 0,-4,-8 1 > /dev/null
echo "-- final3"; php agg3.php out/final3.jsonl --sizes --pieces
export CUT=400
METRIC=0 bash sweep3.sh "look-g look-e smart-g smart-e" 0 1 blind3="{$F}"
SRC=built METRIC=0 bash sweep3.sh "chain look smart" 0 1 built="{$F}"
SRC=none METRIC=0 bash sweep3.sh "chain look smart" 0 1 nosrc="{$F}"
METRIC=0 bash sweep3.sh "chain look smart" 0 1 noev="{$F,\"events\":0}" noground="{$F,\"ground\":0}" noenv="{$F,\"ground\":0,\"events\":0}" lim4="{$F,\"limit\":4}" \
  sim2style="{$F,\"bar\":1,\"foe\":1.3}" evfoe1="{$F,\"ev_foe\":1}" brfoe05="{$F,\"br_foe\":0.5}" grow="{$F,\"gextra\":1}" foeup="{$F,\"foe\":{\"small\":1.2,\"medium\":1.05,\"large\":1.0,\"boss\":1.18}}"
bash sweep3.sh "chain smart" 0 1 sun15="{$F,\"sun\":1.5}" nev1="{$F,\"nev\":1}" alt7="{$F,\"dims\":{\"small\":[7,5],\"medium\":[7,5],\"large\":[7,5],\"boss\":[7,5]}}" altT="{$F,\"dims\":{\"small\":[4,4],\"medium\":[5,4],\"large\":[6,5],\"boss\":[7,5]}}"
echo SIDE_DONE
