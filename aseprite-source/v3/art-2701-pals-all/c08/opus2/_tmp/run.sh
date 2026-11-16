#!/bin/bash
# run.sh key... : render <key>-yard and -perch into this folder, then a 6x/4x preview sheet in _tmp
D=$(cd "$(dirname "$0")/.." && pwd)
S=/tmp/claude-0/-home-user-gnome-venture/fb29d00c-3097-5bb1-8cb8-ae010fcc202d/scratchpad/c08
for k in "$@"; do for v in yard perch; do
  [ -f $D/$k-$v.lua ] || continue
  /tmp/claude-0/ase/squashfs-root/AppRun -b --script-param out=$D/ --script $D/$k-$v.lua 2>&1 | grep -iv "^$" | grep -i "error\|margin\|semi\|black\|traceback\|lua" | head -8
done; python3 $S/sheet.py $S/o-$k.png 5 $D/$k-yard.png $D/$k-perch.png; done
