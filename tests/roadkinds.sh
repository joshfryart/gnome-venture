#!/bin/bash
# v2.0.79 road card kinds (fork, riddle, trade, chain, sketch), the Road Journal and the kind memory. Run after walk.sh has installed (player "sprout").
GAME=$1; PORT=$2; ROUTER=$3; BASE=http://127.0.0.1:$PORT
php -d session.save_path=/tmp -S 127.0.0.1:$PORT -t $GAME $ROUTER >/tmp/rk-php.log 2>&1 & PID=$!; sleep 1
trap "kill $PID 2>/dev/null" EXIT
OUT=$(php "$(dirname "$0")/roadkinds.php" "$GAME" 2>&1)
echo "$OUT"
FAILS=$(echo "$OUT" | grep -c '^  FAIL')
# the page itself: a riddle and a trade card render with their label, the shuffled order and a greyed-out price
C=/tmp/rk-ck; rm -f $C
csrf() { grep -o 'name="csrf" value="[^"]*"' "$1" | head -1 | sed 's/.*value="\([^"]*\)".*/\1/'; }
curl -s -c $C -b $C $BASE/login.php > /tmp/rk.html; curl -s -c $C -b $C -X POST $BASE/login.php --data-urlencode "csrf=$(csrf /tmp/rk.html)" -d username=sprout -d 'password=TestPass123!' -o /dev/null
chk() { if [ "$2" = 1 ]; then echo "  ok   $1"; else echo "  FAIL $1 $3"; FAILS=$((FAILS+1)); fi; }
for k in riddle trade fork chain sketch; do
  php "$(dirname "$0")/roadkinds.php" "$GAME" show $k >/dev/null 2>&1
  curl -s -b $C -c $C $BASE/adventure.php > /tmp/rk.html
  case $k in riddle) w='A riddle';; trade) w='A trade';; fork) w='A fork in the road';; chain) w='The story goes on';; sketch) w='For your road journal';; esac
  chk "adventure page shows a $k card ($w)" "$(grep -q "$w" /tmp/rk.html && echo 1)"
done
chk "no PHP warnings or fatals" "$(grep -iE 'fatal|warning|notice|deprecated|exception' /tmp/rk-php.log | grep -q . && echo 0 || echo 1)" "$(grep -iE 'fatal|warning|notice' /tmp/rk-php.log | head -3)"
php "$(dirname "$0")/roadkinds.php" "$GAME" end
curl -s -b $C -c $C "$BASE/town.php?view=passport" > /tmp/rk.html
chk "the Road Journal shows on the passport" "$(grep -q 'Road Journal' /tmp/rk.html && echo 1)"
[ $FAILS -eq 0 ] && echo "all passed" || echo "$FAILS FAILED"; [ $FAILS -eq 0 ]
