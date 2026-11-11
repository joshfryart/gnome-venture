cd "$(dirname "$0")"
for f in a b c d; do cat common.lua $f.lua > run_$f.lua; /tmp/aseq/squashfs-root/AppRun -b --script-param out=../out4/ --script run_$f.lua 2>&1 | tail -5; done
