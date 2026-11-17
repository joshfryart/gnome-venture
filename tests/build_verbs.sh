#!/bin/bash
# Build verbs carry / decorate / wait / vigil (2.7.06): tests/build_verbs.php on an installed copy (ci_suites.sh installs it with walk.sh first).
HERE=$(cd "$(dirname "$0")" && pwd)
OUT=$(php -d error_reporting=-1 -d display_errors=1 -d session.save_path=/tmp "$HERE/build_verbs.php" "$1" 2>&1); RC=$?
echo "$OUT"
LAST=$(echo "$OUT" | tail -1)
case "$LAST" in ok) ;; *FAILED) ;; *) echo "FAIL build_verbs did not finish (last line: $LAST)"; exit 1;; esac
echo "$OUT" | grep -qE "^(PHP )?(Warning|Notice|Deprecated|Fatal error)" && { echo "FAIL build_verbs printed PHP warnings"; exit 1; }
exit $RC
