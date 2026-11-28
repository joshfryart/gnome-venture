#!/bin/bash
# 2.8.90: the Gnome page's "base + boosts" breakdown adds up to eff_stat(). ci_suites.sh installs a copy first.
HERE=$(cd "$(dirname "$0")" && pwd)
OUT=$(php -d error_reporting=-1 -d display_errors=1 -d session.save_path=/tmp "$HERE/stat_parts.php" "$1" 2>&1); RC=$?
echo "$OUT"
exit $RC
