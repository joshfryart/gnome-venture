#!/bin/bash
cd /tmp/claude-0/-home-user-gnome-venture/9c742976-d6c0-5f98-947e-a8c24c975813/scratchpad/doors/w4
for s in "$@"; do /tmp/aseq/squashfs-root/AppRun -b --script-param name=$s --script-param out=out/ --script gen.lua 2>&1 | grep -v "^$" | head -5; done
