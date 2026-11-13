#!/bin/sh
# run.sh script.lua [extra params...]
cd /tmp/claude-0/-home-user-gnome-venture/5ea3a19c-b77b-53be-abcb-7211df396576/scratchpad/cf-ase2/
S=$1; shift
/tmp/aseq/squashfs-root/AppRun -b --script-param out=$PWD/final/ --script-param pass=4 "$@" --script $S 2>&1 | tail -${TAILN:-12}
