#!/bin/bash
# usage: run30.sh name...   (runs ph/<name>.lua)
D=/home/user/gnome-venture/aseprite-source/v3/items/final/ph
for f in "$@"; do echo "== $f"; /tmp/aseq/squashfs-root/AppRun -b --script-param out=$D/ --script $D/$f.lua 2>&1 | grep -v "^  distinct" | tail -4; done
