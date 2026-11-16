#!/bin/bash
# 2.7.01 creature pass: tests/pfboard_v1_ai.php (no DB, no server). Prints FAIL lines and exits 1 if any.
OUT=$(php "$(cd "$(dirname "$0")" && pwd)/pfboard_v1_ai.php" 2>&1); RC=$?
echo "$OUT"
[ $RC -eq 0 ] && ! echo "$OUT" | grep -qE '^\s*FAIL'
