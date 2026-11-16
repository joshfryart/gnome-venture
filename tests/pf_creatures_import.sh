#!/bin/bash
# 2.7.01 creature pass, game side: importer, drop gates, Petals, exp, region pass (tests/pf_creatures_import.php). Runs on an installed game copy (tests/ci_suites.sh).
GAME=$1
php -d display_errors=1 "$(cd "$(dirname "$0")" && pwd)/pf_creatures_import.php" "$GAME"
