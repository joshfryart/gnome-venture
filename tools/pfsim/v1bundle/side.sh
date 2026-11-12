#!/bin/bash
# The side experiments of "Sim results 2" (at level, 200+ fights per size). bash side.sh > out/side2.txt   (about 25 minutes on 4 cores)
cd "$(dirname "$0")"; B='"nsun":3,"nbr":3,"nmud":1,"gmin":1,"gmax":2,"nev":2,"foe":1.3'   # the recommended numbers (everything else is the default in mkengine.py)
bash sweep.sh "chain look smart" 0 1 today='{"ground":0,"events":0,"limit":0,"aim":0,"team":1,"foe":1}' \
  start='{"foe":1.35}' start13='{"foe":1.3}' noground="{$B,\"ground\":0}" noevents="{$B,\"events\":0}" noenv="{$B,\"ground\":0,\"events\":0}" \
  sun15="{$B,\"sun\":1.5}" soft="{$B,\"bramble\":0.07,\"ev_unit\":0.05,\"sun\":1.5}" ev1="{$B,\"nev\":1}" wide="{$B,\"nsun\":4,\"nbr\":4,\"nmud\":2,\"gmax\":3}" \
  foe12="{$B,\"foe\":1.2}" foe135="{$B,\"foe\":1.35}" team0="{$B,\"team\":1}" lim4="{$B,\"limit\":4}"
bash sweep.sh "look-g look-e" 0 1 blind1="{$B}"
SRC=thirds bash sweep.sh "chain look smart" 0 1 thirds="{$B}" thirds2="{$B,\"team\":2}"
SRC=pairs bash sweep.sh "chain look smart" 0 1 pairs="{$B}"
for l in today start noground noevents sun15 ev1 wide team0 thirds thirds2 pairs blind1; do echo "-- bite $l"; php agg.php out/$l.jsonl --bite | tail -n +9; done
echo SIDE_DONE
