cd /tmp/ase/states2; b=$1; f=$2
cat _wl/head.lua _wl/kit.lua _wl/common.lua _wl/$f > $b.lua
mkdir -p $b; /tmp/ase/squashfs-root/AppRun -b --script-param out=/tmp/ase/states2/$b/ --script /tmp/ase/states2/$b.lua 2>&1 | tail -15
python3 -W ignore _wl/sheet.py $b
