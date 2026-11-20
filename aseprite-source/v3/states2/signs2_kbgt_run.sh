#!/bin/bash
NS=/tmp/claude-0/-home-user-gnome-venture/0379a473-bbc7-5af0-81bd-b41f5db92fbf/scratchpad/ns
for b in "$@"; do
  /tmp/ase/squashfs-root/AppRun -b --script-param out=/tmp/ase/states2/$b/ --script /tmp/ase/states2/${b}_signs2.lua || exit 1
  mkdir -p $NS/$b
  /tmp/ase/squashfs-root/AppRun -b --script-param out=$NS/$b/ --script-param noshadow=1 --script /tmp/ase/states2/${b}_signs2.lua || exit 1
done
python3 /tmp/ase/states2/signs2_kbgt_sheet.py "$@"
