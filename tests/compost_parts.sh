#!/bin/bash
# Creature parts phase 2 (2.7.58): parts on the compost heap, scrap_bank. ci_suites.sh installs a copy first.
HERE=$(cd "$(dirname "$0")" && pwd)
OUT=$(php -d error_reporting=-1 -d display_errors=1 -d session.save_path=/tmp "$HERE/compost_parts.php" "$1" 2>&1); RC=$?
echo "$OUT"
LAST=$(echo "$OUT" | tail -1)
case "$LAST" in ok) ;; *FAILED) ;; *) echo "FAIL compost_parts did not finish (last line: $LAST)"; exit 1;; esac
echo "$OUT" | grep -qE "^(PHP )?(Warning|Notice|Deprecated|Fatal error)" && { echo "FAIL compost_parts printed PHP warnings"; exit 1; }
exit $RC
