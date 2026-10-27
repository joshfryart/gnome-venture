#!/bin/bash
# Fresh install vs. upgrade from an older release. Usage: tests/upgrade_check.sh OLD_SOURCE_ZIP [PORT]
# Installs the old release (its own installer, driven by walk.sh), copies this game/ over it, loads pages so the upgrade steps run,
# runs db_migrate, then checks the schema matches a fresh install of this version and that no upgrade step failed.
set -u
HERE=$(cd "$(dirname "$0")" && pwd); ZIP=${1:?old source zip}; PORT=${2:-8790}; ROUTER=$HERE/router.php
T=$(mktemp -d); trap 'rm -rf "$T"' EXIT; FAILS=0
unzip -q "$ZIP" 'game/*' -d "$T/old" || exit 2
rm -rf "$T/old/game/data" "$T/old/game/config.php"; mkdir -p "$T/old/game/data"
cp -r "$HERE/../game" "$T/fresh"; rm -rf "$T/fresh/data" "$T/fresh/config.php"; mkdir -p "$T/fresh/data"
bash "$HERE/walk.sh" "$T/old/game" "$PORT" "$ROUTER" >"$T/old.out" 2>&1
grep -q '^installed' "$T/old.out" || { echo "FAIL old release did not install"; tail -5 "$T/old.out"; exit 1; }
bash "$HERE/walk.sh" "$T/fresh" "$((PORT+1))" "$ROUTER" >"$T/fresh.out" 2>&1
grep -q '^installed' "$T/fresh.out" || { echo "FAIL fresh install failed"; tail -5 "$T/fresh.out"; exit 1; }
cp -a "$HERE/../game/." "$T/old/game/"          # the upgrade: new files over the old site (data/ and config.php stay)
php -d session.save_path="$T" -d display_errors=1 -S 127.0.0.1:$((PORT+2)) -t "$T/old/game" "$ROUTER" >"$T/srv.log" 2>&1 & PID=$!; sleep 1
for pg in index.php login.php world.php; do curl -s -o /dev/null "http://127.0.0.1:$((PORT+2))/$pg"; done
kill $PID 2>/dev/null
# the "Upgrade database" button, then the schema comparison
php -r 'chdir($argv[1]); $_SERVER["HTTP_HOST"]="x"; require "includes/bootstrap.php"; db_migrate(db(), "sqlite"); echo empty($GLOBALS["gv_migrate_errors"]) ? "ok   db_migrate on the upgraded db: no errors\n" : "FAIL db_migrate errors: ".implode("; ", $GLOBALS["gv_migrate_errors"])."\n"; $f=setting("boot_failed_steps"); echo $f ? "FAIL upgrade steps failed: $f\n" : "ok   no upgrade step failed\n";' "$T/old/game" | tee "$T/mig.out"
grep -q FAIL "$T/mig.out" && FAILS=1
php "$HERE/schema_compare.php" "$T/fresh" "$T/old/game" || FAILS=1
[ -f "$T/old/game/data/error-log.txt" ] && { echo "FAIL error log written during upgrade:"; head -20 "$T/old/game/data/error-log.txt"; FAILS=1; }
exit $FAILS
