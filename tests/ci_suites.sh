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
  : >"$T/.start"; rm -f /tmp/img-php.log   # fixed-name php server log some suites write; clear it so only this suite's lines are shown
  TMPDIR="$T" timeout 600 bash "$HERE/$s.sh" "$T/game" "$PORT" "$HERE/router.php" >"$T/out" 2>&1; rc=$?   # TMPDIR: the suite's own mktemp logs land inside $T
  if [ $rc -ne 0 ] || grep -qE '^\s*FAIL|[0-9]+ FAILED|PHP Fatal|Fatal error' "$T/out"; then
    echo "FAIL $s (exit $rc)"; grep -E '^\s*FAIL|[0-9]+ FAILED|Fatal' "$T/out" | head -8 | sed 's/^/     /'; BAD=$((BAD+1))
    echo "   --- last 25 lines of $s output"; { grep -a "diag" "$T/out"; tail -25 "$T/out"; } | cut -c1-300 | sed 's/^/   | /'
    echo "   --- PHP Warning/Notice/Deprecated/Fatal lines in logs (suite output, php server logs, game data/)"
    { grep -hE 'PHP (Warning|Notice|Deprecated|Fatal|Parse)|^(Warning|Notice|Deprecated|Fatal error|Parse error):|Uncaught' "$T/out"
      for f in $(find "$T" /tmp -maxdepth 4 \( -name '*.log' -o -name 'error-log.txt*' -o -name 'tmp.*' \) -type f -newer "$T/.start" -not -path '/tmp/claude*' 2>/dev/null); do
        [ "$f" = "$T/out" ] && continue
        grep -hE 'PHP (Warning|Notice|Deprecated|Fatal|Parse)|Warning:|Notice:|Deprecated:|Fatal error|Parse error|Uncaught|^[A-Za-z]+(Error|Exception):' "$f" 2>/dev/null | sed "s|^|[${f##*/}] |"
      done; } | sort -u | head -40 | cut -c1-300 | sed 's/^/   ! /'
    if [ -s "$T/game/data/error-log.txt" ]; then echo "   --- game/data/error-log.txt (first 25 lines)"; head -25 "$T/game/data/error-log.txt" | cut -c1-300 | sed 's/^/   | /'; fi
  else echo "ok   $s"; fi
  rm -rf "$T"
done
echo "$N suites, $BAD failed"
[ $BAD -eq 0 ]
