#!/bin/bash
# Runs the SQLite test suites the way CI does: every suite gets its own copy of game/ and its own port.
# Usage: tests/ci_suites.sh [suite.sh ...]     (no arguments = every suite in the list below)
# A suite counts as failed when it prints a line starting with "FAIL" (optionally indented), "N FAILED", a PHP fatal, or exits non-zero.
# Suites that install themselves (they call walk.sh) get a copy with no data/; the others get a copy walk.sh has installed first (player "sprout", admin "admin").
HERE=$(cd "$(dirname "$0")" && pwd)
SELF_INSTALLING="${SELF_INSTALLING:-walk clock gourmand calling garden100 market100 mentors120 roads097 roadlife roadtext scenes social100 stops100 heredo treks trekshell villagers fix100 breeding110 security190 updrollback pfight pfight_sim pfight_js pfboard_sim pf_bots pfboard_combo_set trail_fam_collapse pfboard_fixes pfv1_charm pfv1_guide pfboard_v1 pfboard_v1_page pfdeck_v1 pfdeck_reset pbox_v1 pfboard pfboard_js pfengine_js pfmap pfstage}"
LIST="${*:-$SUITES}"
[ -n "$LIST" ] || LIST="${DEFAULT_SUITES:-}"
[ -n "$LIST" ] || { echo "no suites given"; exit 2; }
# SHARD=i SHARDS=n: run only every n-th suite of the list, starting at the i-th (1-based), so CI can split the list over parallel jobs
if [ -n "${SHARDS:-}" ] && [ "$SHARDS" -gt 1 ]; then
  K=0; PICK=""; for s in $LIST; do K=$((K+1)); [ $(( (K-1) % SHARDS )) -eq $(( ${SHARD:-1} - 1 )) ] && PICK="$PICK $s"; done; LIST=$PICK
  echo "shard ${SHARD:-1} of $SHARDS"
fi
# RETRY_SUITES: browser suites (a real Chromium on a shared runner) get one more go when they fail; a retried pass is reported as "ok (retry)" and does not fail the run
RETRY_SUITES="${RETRY_SUITES:-}"
PORT=${PORT_BASE:-8810}; BAD=0; N=0
run_one() {
  local s=$1 T rc RC
  PORT=$((PORT+10))   # 10 ports a suite: some suites open a second server on PORT+1 (catfish), which must never be the next suite's port
  T=$(mktemp -d); cp -r "$HERE/../game" "$T/game"; rm -rf "$T/game/data" "$T/game/config.php"; mkdir -p "$T/game/data"
  if ! echo " $SELF_INSTALLING " | grep -q " $s "; then
    TMPDIR="$T" bash "$HERE/walk.sh" "$T/game" "$PORT" "$HERE/router.php" >"$T/walk.out" 2>&1
    grep -q "^installed" "$T/walk.out" || { echo "FAIL $s: walk.sh could not install"; rm -rf "$T"; return 1; }
    PORT=$((PORT+1))
  fi
  RC=0
  : >"$T/.start"   # walk.sh and images.sh write their scratch files under TMPDIR (= $T), so parallel runs do not share them
  TMPDIR="$T" timeout 600 bash "$HERE/$s.sh" "$T/game" "$PORT" "$HERE/router.php" >"$T/out" 2>&1; rc=$?   # TMPDIR: the suite's own mktemp logs land inside $T
  if [ $rc -ne 0 ] || grep -qE '^\s*FAIL|[0-9]+ FAILED|PHP Fatal|Fatal error' "$T/out"; then
    echo "FAIL $s (exit $rc)"; grep -E '^\s*FAIL|[0-9]+ FAILED|Fatal' "$T/out" | head -8 | sed 's/^/     /'; RC=1
    echo "   --- last 25 lines of $s output"; { grep -a "diag" "$T/out"; tail -25 "$T/out"; } | cut -c1-300 | sed 's/^/   | /'
    echo "   --- PHP Warning/Notice/Deprecated/Fatal lines in logs (suite output, php server logs, game data/)"
    { grep -hE 'PHP (Warning|Notice|Deprecated|Fatal|Parse)|^(Warning|Notice|Deprecated|Fatal error|Parse error):|Uncaught' "$T/out"
      for f in $(find "$T" /tmp -maxdepth 4 \( -name '*.log' -o -name 'error-log.txt*' -o -name 'tmp.*' \) -type f -newer "$T/.start" -not -path '/tmp/claude*' 2>/dev/null); do
        [ "$f" = "$T/out" ] && continue
        grep -hE 'PHP (Warning|Notice|Deprecated|Fatal|Parse)|Warning:|Notice:|Deprecated:|Fatal error|Parse error|Uncaught|^[A-Za-z]+(Error|Exception):' "$f" 2>/dev/null | sed "s|^|[${f##*/}] |"
      done; } | sort -u | head -40 | cut -c1-300 | sed 's/^/   ! /'
    if [ -s "$T/game/data/error-log.txt" ]; then echo "   --- game/data/error-log.txt (first 25 lines)"; head -25 "$T/game/data/error-log.txt" | cut -c1-300 | sed 's/^/   | /'; fi
  else echo "ok   $s"; RC=0; fi
  pkill -f "$T/game" 2>/dev/null   # a server (or its workers) a suite left behind must not outlive it
  rm -rf "$T"
  return $RC
}
for s in $LIST; do
  s=${s%.sh}; N=$((N+1))
  if run_one "$s"; then continue; fi
  if echo " $RETRY_SUITES " | grep -q " $s "; then
    echo "RETRY $s (failed once; running it again)"
    if run_one "$s"; then echo "ok   $s (passed on retry: flaky)"; continue; fi
  fi
  BAD=$((BAD+1))
done
echo "$N suites, $BAD failed"
[ $BAD -eq 0 ]
