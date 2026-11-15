#!/bin/bash
# _run.sh name... : render opus3 scenes
cd /home/user/gnome-venture/aseprite-source/v3/art-2701-batch3/stops/opus3
for n in "$@"; do
  /tmp/claude-0/ase/squashfs-root/AppRun -b --script-param out=$PWD/ --script $n.lua 2>&1 | grep -v "^$" | tail -5
done
