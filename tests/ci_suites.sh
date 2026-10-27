#!/bin/bash
# Runs the SQLite test suites the way CI does: every suite gets its own copy of game/ and its own port.
# Usage: tests/ci_suites.sh [suite.sh ...]     (no arguments = every suite in the list below)
# A suite counts as failed when it prints a line starting with "FAIL" (optionally indented), "N FAILED", a PHP fatal, or exits non-zero.
# Suites that install themselves (they call walk.sh) get a copy with no data/; the others get a copy walk.sh has installed first (player "sprout", admin "admin").
HERE=$(cd "$(dirname "$0")" && pwd)
SELF_INSTALLING="${SELF_INSTALLING:-clock calling garden100 market100 mentors120 roads097 roadlife roadtext scenes social100 stops100 treks trekshell villagers fix100 breeding110 security190 updrollback}"
LIST="${*:-$SUITES}"
[ -n "$LIST" ] || LIST="${DEFAULT_SUITES:-}"
[ -n "$LIST" ] || { echo "no suites given"; exit 2; }
PORT=${PORT_BASE:-8810}; BAD=0; N=0
for s in $LIST; do
  s=${s%.sh}; N=$((N+1)); PORT=$((PORT+1))
  T=$(mktemp -d); cp -r "$HERE/../game" "$T/game"; rm -rf "$T/game/data" "$T/game/config.php"; mkdir -p "$T/game/data"
  if ! echo " $SELF_INSTALLING " | grep -q " $s "; then
    bash "$HERE/walk.sh" "$T/game" "$PORT" "$HERE/router.php" >"$T/walk.out" 2>&1
    grep -q "^installed" "$T/walk.out" || { echo "FAIL $s: walk.sh could not install"; BAD=$((BAD+1)); rm -rf "$T"; continue; }
    PORT=$((PORT+1))
  fi
  timeout 600 bash "$HERE/$s.sh" "$T/game" "$PORT" "$HERE/router.php" >"$T/out" 2>&1; rc=$?
  if [ $rc -ne 0 ] || grep -qE '^\s*FAIL|[0-9]+ FAILED|PHP Fatal|Fatal error' "$T/out"; then
    echo "FAIL $s (exit $rc)"; grep -E '^\s*FAIL|[0-9]+ FAILED|Fatal' "$T/out" | head -8 | sed 's/^/     /'; BAD=$((BAD+1))
  else echo "ok   $s"; fi
  rm -rf "$T"
done
echo "$N suites, $BAD failed"
[ $BAD -eq 0 ]
