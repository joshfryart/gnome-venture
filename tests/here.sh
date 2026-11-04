#!/bin/bash
# Graphical navigation (plan-graphical-nav.md): helpers, layouts, scene engine, the Here page. here.sh GAME PORT ROUTER. Run after walk.sh has installed (player "sprout", admin "admin").
GAME=$1; PORT=$2; ROUTER=$3
OUT=$(php "$(dirname "$0")/here.php" "$GAME" db 2>&1)
echo "$OUT"
FAILS=$(echo "$OUT" | grep -c '^  FAIL')
echo "$OUT" | grep -qE 'PHP (Fatal|Warning|Notice|Deprecated)|Fatal error' && FAILS=$((FAILS+1))
[ $FAILS -eq 0 ] && echo "all passed" || echo "$FAILS FAILED"; [ $FAILS -eq 0 ]
