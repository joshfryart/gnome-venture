cd /tmp/claude-0/-home-user-gnome-venture/9c742976-d6c0-5f98-947e-a8c24c975813/scratchpad/whimsy/src
O=../out5/
for n in "$@"; do cat helpers.lua p$n.lua > b$n.lua; /tmp/aseq/squashfs-root/AppRun -b --script-param out=$O --script b$n.lua 2>&1 | tail -5; done
