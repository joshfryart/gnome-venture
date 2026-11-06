#!/bin/bash
# Fight scene on the Trail: the stage sits over the tile map itself (fight_scene + gnav_tiles).
# fight_scene_trail.sh GAME PORT ROUTER. Run after walk.sh has installed (player "sprout" at level 1, admin "admin"). Leaves gnav_on = 0.
GAME=$1; PORT=$2; ROUTER=$3; BASE=http://127.0.0.1:$PORT
TD="${TMPDIR:-/tmp}"
HERE=$(dirname "$0")
cli() { php "$HERE/here.php" "$GAME" cli "$@"; }
FAILS=0
ERR0=$(cat "$GAME/data/error-log.txt" 2>/dev/null | wc -l)
php -d session.save_path=/tmp -S 127.0.0.1:$PORT -t $GAME $ROUTER >$TD/here-php.log 2>&1 & PID=$!; sleep 1
trap "kill $PID 2>/dev/null; cli set gnav_on 0 >/dev/null" EXIT
chk() { if [ "$2" = 1 ]; then echo "  ok   $1"; else echo "  FAIL $1 $3"; FAILS=$((FAILS+1)); fi; }
C=$TD/here-ck
csrf() { grep -o 'name="csrf" value="[^"]*"' "$1" | head -1 | sed 's/.*value="\([^"]*\)".*/\1/'; }
login() { rm -f $C; curl -s -c $C -b $C $BASE/login.php > $TD/here-l.html; curl -s -c $C -b $C -X POST $BASE/login.php --data-urlencode "csrf=$(csrf $TD/here-l.html)" -d username=sprout -d 'password=TestPass123!' -o /dev/null -w '%{redirect_url}'; }
get() { curl -s -c $C -b $C "$BASE/$1" -o $TD/here-p.html -w '%{http_code} %{redirect_url}'; }
post() { curl -s -c $C -b $C -X POST "$BASE/$1" --data-urlencode "csrf=$(csrf $TD/here-p.html)" "${@:2}" -o $TD/here-post.html -w '%{http_code} %{redirect_url}'; }


cli set gnav_on 1 >/dev/null; cli set gnav_tiles 1 >/dev/null; cli set fight_scene 0 >/dev/null; login >/dev/null
chk "tile walk starts" "$([[ $(cli tilewalk | tail -1) == ok ]] && echo 1)"
cli forceenc >/dev/null
php -r '$p=new PDO("sqlite:'$GAME'/data/game.sqlite"); $r=$p->query("SELECT id,encounter FROM expeditions ORDER BY id DESC LIMIT 1")->fetch(); $e=json_decode($r["encounter"],true); $e["hp"]=$e["max"]=900; $p->prepare("UPDATE expeditions SET encounter=?, hp=max_hp WHERE id=?")->execute([json_encode($e),$r["id"]]);'   # a foe that survives the test's hits
get adventure.php >/dev/null
chk "scene off: popover as before" "$(grep -q '<dialog class="picker hubpop trailpop"' $TD/here-p.html && ! grep -q 'id="fightscene"' $TD/here-p.html && echo 1)"
cli set fight_scene 1 >/dev/null; get adventure.php >/dev/null
chk "scene on: no popover" "$(grep -q 'trailpop' $TD/here-p.html && echo 0 || echo 1)"
chk "the stage is inside the map (tmstage), flat over it" "$(sed -n '/class="tmstage"/,/<\/form>/p' $TD/here-p.html | grep -q 'class="fightscene fs-over"' && echo 1)"
chk "over-map cells are handed over" "$(grep -o 'data-fight="[^"]*"' $TD/here-p.html | head -1 | php -r 'echo html_entity_decode(stream_get_contents(STDIN));' | grep -q '"over":{"cols":9,"rows":9' && echo 1)"
chk "fight buttons are there" "$(grep -q 'value="attack"' $TD/here-p.html && echo 1)"
chk "no inline style or script on the page (CSP)" "$(sed -n '/<main/,/<\/main>/p' $TD/here-p.html | grep -qE '\sstyle=|<script[^>]*>[^<]' && echo 0 || echo 1)"
if command -v node >/dev/null && [ -z "$NOBROWSER" ]; then node "$HERE/fight_scene.js" "$BASE" "$SHOT" >$TD/fs-browser.out 2>&1 || { cat $TD/fs-browser.out; FAILS=$((FAILS+1)); }; [ -n "$SHOT" ] && cat $TD/fs-browser.out; fi
cli set gnav_on 0 >/dev/null; cli set gnav_tiles 0 >/dev/null; cli set fight_scene 0 >/dev/null
ERR1=$(cat "$GAME/data/error-log.txt" 2>/dev/null | wc -l)
[ "$ERR1" -gt "$ERR0" ] && { echo "  FAIL php errors logged"; tail -n +$((ERR0+1)) "$GAME/data/error-log.txt" | head -5; FAILS=$((FAILS+1)); }
[ "$FAILS" -eq 0 ] && echo "ok" || echo "$FAILS FAILED"
exit $((FAILS>0))
