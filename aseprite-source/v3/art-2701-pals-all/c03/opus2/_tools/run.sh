#!/bin/bash
# run.sh name1 name2 ... : render <name>.lua into opus2/ and build a x5 preview sheet in scratchpad
D=/home/user/gnome-venture/aseprite-source/v3/art-2701-pals-all/c03/opus2
S=/tmp/claude-0/-home-user-gnome-venture/fb29d00c-3097-5bb1-8cb8-ae010fcc202d/scratchpad
A=/tmp/claude-0/ase/squashfs-root/AppRun
F=()
for n in "$@"; do
  $A -b --script-param out=$D/ --script $D/$n.lua 2>&1 | grep -iv "^$" | grep -i "error\|semi\|black\|margin\|bbox" | head -5
  F+=("$D/$n.png")
done
python3 $D/_tools/sheet.py $S/c03o2/v.png 6 "${F[@]}"
