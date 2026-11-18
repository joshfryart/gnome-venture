#!/bin/bash
# _run.sh name... : render island_palm stop scenes (480x270, native 1x) next to their scripts
cd /home/user/gnome-venture/aseprite-source/v3/art-island-stops
APP=${APP:-/tmp/aseq/squashfs-root/AppRun}
for n in "$@"; do
  "$APP" -b --script-param out=$PWD/ --script $n.lua 2>&1 | grep -v "^$" | tail -5
done
