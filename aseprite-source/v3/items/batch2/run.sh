#!/bin/bash
cd /home/user/gnome-venture/aseprite-source/v3/items/batch2
for f in "$@"; do echo "== $f"; /tmp/aseq/squashfs-root/AppRun -b --script-param out=$PWD/ --script $f.lua 2>&1 | grep -v "^  distinct" | tail -3; done
