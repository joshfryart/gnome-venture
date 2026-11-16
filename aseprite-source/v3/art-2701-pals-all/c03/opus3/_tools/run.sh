#!/bin/bash
# run.sh tag name1 name2 ... : render <name>.lua into opus3/ and build a preview sheet in scratchpad/c03o3/<tag>.png
D=/home/user/gnome-venture/aseprite-source/v3/art-2701-pals-all/c03/opus3
S=/tmp/claude-0/-home-user-gnome-venture/fb29d00c-3097-5bb1-8cb8-ae010fcc202d/scratchpad/c03o3
A=/tmp/claude-0/ase/squashfs-root/AppRun
T=$1; shift; F=()
for n in "$@"; do
  $A -b --script-param out=$D/ --script $D/$n.lua 2>&1 | grep -i "error\|semi\|black\|traceback\|attempt" | head -5
  F+=("$D/$n.png")
done
N=$S/$T-$(date +%s).png; python3 $D/_tools/sheet.py $N 6 "${F[@]}"; echo $N
