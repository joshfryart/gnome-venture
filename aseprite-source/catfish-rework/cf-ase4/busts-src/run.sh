#!/bin/bash
D=/tmp/claude-0/-home-user-gnome-venture/5ea3a19c-b77b-53be-abcb-7211df396576/scratchpad/cf-ase4
cd /tmp
for f in "$@"; do /tmp/aseq/squashfs-root/AppRun -b --script-param out=$D/banners/out/ --script $D/busts-src/$f.lua 2>&1 | tail -4; done
