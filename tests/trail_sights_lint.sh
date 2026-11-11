#!/bin/bash
# Lint all Trail Sights rows against a scratch install (made once, kept in /tmp/sights-lint): bash tests/trail_sights_lint.sh
HERE=$(cd "$(dirname "$0")" && pwd); D=${SIGHTS_LINT_DIR:-/tmp/sights-lint}
if [ ! -f "$D/game/config.php" ]; then
  rm -rf "$D"; mkdir -p "$D"; cp -r "$HERE/../game" "$D/game"; rm -rf "$D/game/data" "$D/game/config.php"; mkdir -p "$D/game/data"
  TMPDIR="$D" bash "$HERE/walk.sh" "$D/game" 8990 "$HERE/router.php" >"$D/walk.out" 2>&1; grep -q "^installed" "$D/walk.out" || { echo "install failed"; tail -5 "$D/walk.out"; exit 2; }
fi
rsync -a --exclude data --exclude config.php "$HERE/../game/" "$D/game/" 2>/dev/null || cp -r "$HERE/../game/includes" "$D/game/"
cp "$HERE/../game/includes/data/"trail_sights*.txt "$D/game/includes/data/" 2>/dev/null
php -d session.save_path=/tmp "$HERE/trail_sights_lint.php" "$D/game"
