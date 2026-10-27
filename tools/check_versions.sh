#!/usr/bin/env bash
# Checks that the version is defined once (game/includes/bootstrap.php) and nothing drifts from it.
# Usage: bash tools/check_versions.sh   (run from anywhere; exits 1 on drift)
cd "$(dirname "$0")/.." || exit 2
ver=$(grep -oP "define\('APP_VERSION', '\K[0-9.]+" game/includes/bootstrap.php)
[ -n "$ver" ] || { echo "FAIL: APP_VERSION not found in game/includes/bootstrap.php"; exit 1; }
rc=0
top=$(grep -m1 -oP '^## \K[0-9][0-9.]*' CHANGELOG.md)
[ "$top" = "$ver" ] || { echo "FAIL: CHANGELOG.md top entry is $top, APP_VERSION is $ver"; rc=1; }
if grep -qE "^define\('APP_VERSION', '[0-9.]+'\)" game/install.php; then
  echo "FAIL: game/install.php has a literal APP_VERSION (should read it from bootstrap.php)"; rc=1
fi
for f in README.md game/README.md; do
  if grep -nE '(^|[^0-9.])v?[0-9]+\.[0-9]+\.[0-9]+([^0-9.]|$)' "$f" | grep -vE 'PHP 8\.[0-9]|8\.1\+' | grep -iE 'version|v[0-9]+\.[0-9]+\.[0-9]+|^[0-9]+:#'; then
    echo "FAIL: $f hardcodes a version (see lines above); link to CHANGELOG.md instead"; rc=1
  fi
done
[ $rc -eq 0 ] && echo "OK: version $ver (bootstrap.php, CHANGELOG.md top entry; installer reads it; READMEs have no literals)"
exit $rc
