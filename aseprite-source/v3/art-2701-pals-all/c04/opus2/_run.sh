#!/bin/bash
# usage: _run.sh name [name...]   renders <name>.lua into this folder, then a 4x/6x preview sheet in scratch
D=$(cd "$(dirname "$0")" && pwd)
S=/tmp/claude-0/-home-user-gnome-venture/fb29d00c-3097-5bb1-8cb8-ae010fcc202d/scratchpad
pngs=()
for n in "$@"; do
  /tmp/claude-0/ase/squashfs-root/AppRun -b --script-param out="$D/" --script "$D/$n.lua" 2>&1 | grep -v "^$" | tail -4
  pngs+=("$D/$n.png")
done
python3 "$D/_sheet.py" "$S/view.png" ${SC:-6} "${pngs[@]}"
