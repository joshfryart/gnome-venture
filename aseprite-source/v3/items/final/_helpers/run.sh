#!/bin/bash
# usage: run.sh folder/name ...
R=/home/user/gnome-venture/aseprite-source/v3/items/final
for f in "$@"; do d=$(dirname $f); mkdir -p $R/$d; echo "== $f"; /tmp/aseq/squashfs-root/AppRun -b --script-param out=$R/$d/ --script $R/$f.lua 2>&1 | grep -v "^  distinct" | tail -4; done
