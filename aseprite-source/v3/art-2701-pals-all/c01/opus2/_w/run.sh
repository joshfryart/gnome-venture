#!/bin/bash
# run.sh key... : render <key>-yard/perch.lua scripts in opus2 (args are script basenames)
D=/home/user/gnome-venture/aseprite-source/v3/art-2701-pals-all/c01/opus2
for f in "$@"; do
  /tmp/claude-0/ase/squashfs-root/AppRun -b --script-param out=$D/ --script $D/$f.lua 2>&1 | grep -v "^\s*$" | grep -iE "error|semi|black|margin|fail" | head -5
done
