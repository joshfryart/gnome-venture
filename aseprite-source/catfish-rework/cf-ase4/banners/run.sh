#!/bin/bash
D=/tmp/claude-0/-home-user-gnome-venture/5ea3a19c-b77b-53be-abcb-7211df396576/scratchpad/cf-ase4/banners
cd /tmp
for f in "$@"; do /tmp/aseq/squashfs-root/AppRun -b --script-param out=$D/out/ --script $D/$f.lua 2>&1 | tail -4; done
