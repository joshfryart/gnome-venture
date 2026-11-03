#!/bin/bash
cd /home/user/gnome-venture/aseprite-source/v3/items/batch1
for f in "$@"; do echo "== $f"; /tmp/aseq/squashfs-root/AppRun -b --script-param out=/home/user/gnome-venture/aseprite-source/v3/items/batch1/ --script $f.lua 2>&1 | grep -v "^  distinct" | tail -3; done
