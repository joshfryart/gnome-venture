#!/bin/bash
# usage: bash run.sh <species>   (from anywhere)
set -e
sp="${1:?species}"
AS=/home/user/gnome-venture/aseprite-source
cd "$AS"
chmod +x Aseprite_1.3.18.6-x64.AppImage
xvfb-run -a ./Aseprite_1.3.18.6-x64.AppImage --appimage-extract-and-run -b \
  --script-param species="$sp" --script-param root=npc25 --script npc25/gen_draft.lua
python3 npc25/check.py "$sp"
