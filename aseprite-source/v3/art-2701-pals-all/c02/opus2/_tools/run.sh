#!/bin/bash
# usage: run.sh name [name...]  (runs <name>.lua in the opus2 folder, writes outputs there)
D=/home/user/gnome-venture/aseprite-source/v3/art-2701-pals-all/c02/opus2
for n in "$@"; do
  /tmp/claude-0/ase/squashfs-root/AppRun -b --script-param out=$D/ --script $D/$n.lua 2>&1 | grep -v "^$" | tail -4
done
