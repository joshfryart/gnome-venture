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
get adventure.php >/dev/null
chk "what just happened rides in the one toast stack (data-gvtoast), no second fixed box over the message bar" "$(grep -q 'class="trailtoast"' $TD/here-p.html && echo 0 || (grep -q 'data-gvtoast' $TD/here-p.html && echo 1))"
if command -v node >/dev/null && [ -z "$NOBROWSER" ]; then node "$HERE/trail_pop.js" "$BASE" >$TD/trail-pop.out 2>&1 || { cat $TD/trail-pop.out; FAILS=$((FAILS+1)); }; fi
cli forceenc >/dev/null
php -r '$p=new PDO("sqlite:'$GAME'/data/game.sqlite"); $r=$p->query("SELECT id,encounter FROM expeditions ORDER BY id DESC LIMIT 1")->fetch(); $e=json_decode($r["encounter"],true); $e["hp"]=$e["max"]=900; $p->prepare("UPDATE expeditions SET encounter=?, hp=max_hp WHERE id=?")->execute([json_encode($e),$r["id"]]);'   # a foe that survives the test's hits
get adventure.php >/dev/null
chk "scene off: popover as before" "$(grep -q '<dialog class="picker hubpop trailpop"' $TD/here-p.html && ! grep -q 'id="fightscene"' $TD/here-p.html && echo 1)"
cli set fight_scene 1 >/dev/null; get adventure.php >/dev/null
chk "scene on: no popover" "$(grep -q 'trailpop' $TD/here-p.html && echo 0 || echo 1)"
chk "the stage is inside the map (tmstage), flat over it" "$(sed -n '/class="tmstage"/,/<\/form>/p' $TD/here-p.html | grep -q 'class="fightscene fs-over"' && echo 1)"
chk "over-map cells are handed over" "$(grep -o 'data-fight="[^"]*"' $TD/here-p.html | head -1 | php -r 'echo html_entity_decode(stream_get_contents(STDIN));' | grep -q '"over":{"cols":9,"rows":9' && echo 1)"
chk "the fight menu (Fight / Item / Flee column) sits over the map" "$(grep -q 'class="fsdock fsc"' $TD/here-p.html && grep -q 'class="fsc-menu"' $TD/here-p.html && echo 1)"
chk "the dock buttons are real forms (not nested in the map form)" "$([ "$(sed -n '/class=\"fsdock fsc\"/,/class=\"fsc-menu\"/p' $TD/here-p.html | grep -o '<form' | wc -l)" -ge 3 ] && echo 1)"
chk "the old button list is not repeated under the map" "$(grep -q 'class="fightbtns' $TD/here-p.html && echo 0 || echo 1)"
chk "fight buttons are there" "$(grep -q 'value="attack"' $TD/here-p.html && echo 1)"
chk "no inline style or script on the page (CSP)" "$(sed -n '/<main/,/<\/main>/p' $TD/here-p.html | grep -qE '\sstyle=|<script[^>]*>[^<]' && echo 0 || echo 1)"
echo "== end scene and stale events"
get adventure.php >/dev/null
[ "$(grep -o 'data-fight="[^"]*"' $TD/here-p.html | head -1 | php -r 'echo html_entity_decode(stream_get_contents(STDIN));' | grep -c '"events":\[\]')" = 1 ] || echo "  FAIL a fresh fight page already carries events (old events leaking)"
grep -o 'data-fight="[^"]*"' $TD/here-p.html | head -1 | php -r 'echo html_entity_decode(stream_get_contents(STDIN));' | grep -q '"pop":true' && echo "  FAIL hat pops at full health"
php -r '$p=new PDO("sqlite:'$GAME'/data/game.sqlite"); $r=$p->query("SELECT id,encounter FROM expeditions ORDER BY id DESC LIMIT 1")->fetch(); $e=json_decode($r["encounter"],true); $e["hp"]=1; $p->prepare("UPDATE expeditions SET encounter=?, hp=max_hp WHERE id=?")->execute([json_encode($e),$r["id"]]);'
FIN=0
for i in 1 2 3 4 5 6 7 8 9 10; do get adventure.php >/dev/null; post adventure.php -d do=attack >/dev/null; get adventure.php >/dev/null; if ! grep -q 'class="fsdock fsc"' $TD/here-p.html; then FIN=1; break; fi; done
chk "the killing blow leaves an end scene on the map" "$([ $FIN = 1 ] && grep -q 'class="fightscene fs-over"' $TD/here-p.html && echo 1)"
FD=$(grep -o 'data-fight="[^"]*"' $TD/here-p.html | head -1 | php -r 'echo html_entity_decode(stream_get_contents(STDIN));')
chk "...with the last blow, the end marker and the XP" "$(echo "$FD" | grep -q '"finale":1' && echo "$FD" | grep -q '"end":"win"' && echo "$FD" | grep -q '"xp":[1-9]' && echo 1)" "$(echo $FD | cut -c1-300)"
chk "no popover, no fight dock during the end scene" "$(grep -q 'trailpop' $TD/here-p.html && echo 0 || (grep -q 'class="fsdock fsc"' $TD/here-p.html && echo 0 || echo 1))"
get adventure.php >/dev/null
chk "the end scene plays once (a reload shows the plain map)" "$(grep -q 'id="fightscene"' $TD/here-p.html && echo 0 || echo 1)"
cli forceenc >/dev/null
php -r '$p=new PDO("sqlite:'$GAME'/data/game.sqlite"); $r=$p->query("SELECT id,encounter FROM expeditions ORDER BY id DESC LIMIT 1")->fetch(); $e=json_decode($r["encounter"],true); $e["hp"]=$e["max"]=900; $p->prepare("UPDATE expeditions SET encounter=?, hp=max_hp WHERE id=?")->execute([json_encode($e),$r["id"]]);'
get adventure.php >/dev/null
chk "the next fight starts clean: no old events" "$(grep -o 'data-fight="[^"]*"' $TD/here-p.html | head -1 | php -r 'echo html_entity_decode(stream_get_contents(STDIN));' | grep -q '"events":\[\]' && echo 1)"
if command -v node >/dev/null && [ -z "$NOBROWSER" ]; then node "$HERE/fight_scene.js" "$BASE" "$SHOT" >$TD/fs-browser.out 2>&1 || { cat $TD/fs-browser.out; FAILS=$((FAILS+1)); }; [ -n "$SHOT" ] && cat $TD/fs-browser.out; fi
if command -v node >/dev/null && [ -z "$NOBROWSER" ]; then
  php -r '$p=new PDO("sqlite:'$GAME'/data/game.sqlite"); $r=$p->query("SELECT id,encounter FROM expeditions ORDER BY id DESC LIMIT 1")->fetch(); $e=json_decode($r["encounter"],true); $e["hp"]=1; $p->prepare("UPDATE expeditions SET encounter=?, hp=max_hp WHERE id=?")->execute([json_encode($e),$r["id"]]);'
  node "$HERE/fight_finale.js" "$BASE" "$SHOT" >$TD/fs-fin.out 2>&1 || { cat $TD/fs-fin.out; FAILS=$((FAILS+1)); }; [ -n "$SHOT$HATLOG" ] && cat $TD/fs-fin.out
fi
echo "== end scene of a run (flee)"
cli forceenc >/dev/null
php -r '$p=new PDO("sqlite:'$GAME'/data/game.sqlite"); $r=$p->query("SELECT id,encounter FROM expeditions ORDER BY id DESC LIMIT 1")->fetch(); $e=json_decode($r["encounter"],true); $e["hp"]=$e["max"]=900; $p->prepare("UPDATE expeditions SET encounter=?, hp=?, max_hp=? WHERE id=?")->execute([json_encode($e),999,999,$r["id"]]);'
FLED=0
for i in $(seq 1 25); do get adventure.php >/dev/null; post adventure.php -d do=flee >/dev/null; get adventure.php >/dev/null; if ! grep -q 'class="fsdock fsc"' $TD/here-p.html; then FLED=1; break; fi; done
FD=$(grep -o 'data-fight="[^"]*"' $TD/here-p.html | head -1 | php -r 'echo html_entity_decode(stream_get_contents(STDIN));')
chk "running away leaves a scene on the map (the gnome runs off)" "$([ $FLED = 1 ] && grep -q 'class="fightscene fs-over"' $TD/here-p.html && echo "$FD" | grep -q '"finale":1' && echo "$FD" | grep -q '"flee"' && echo "$FD" | grep -q '"reward":null' && echo 1)" "$(echo $FD | cut -c1-200)"
get adventure.php >/dev/null
chk "...once: a reload shows the plain map" "$(grep -q 'id="fightscene"' $TD/here-p.html && echo 0 || echo 1)"
echo "== walking back (trail_prev) on the page"
cli clearenc >/dev/null
php -r '$_SERVER["SCRIPT_NAME"]="/adventure.php"; require "'$GAME'/includes/bootstrap.php"; require_once "'$GAME'/includes/adventure.php"; require_once "'$GAME'/includes/trail_tiles.php"; $u=q_one("SELECT * FROM users WHERE username=\"sprout\""); $exp=active_expedition((int)$u["id"]); $sc=trail_scene($exp); [$x,$y]=$sc["map"]["spots"]["9"]; $sc["x"]=$x; $sc["y"]=$y; $sc["st"]["phase"]="confirm"; trail_save($sc); $exp["encounter"]=null; [$ok]=trail_next($u,$exp); $exp["encounter"]=null; save_exp($exp); echo $ok?"ok":"no";' 2>/dev/null | grep -q ok
get adventure.php >/dev/null
chk "section 2 page offers the way back" "$(grep -q 'value="trail_prev"' $TD/here-p.html && grep -q 'Back to section 1' $TD/here-p.html && echo 1)"
R=$(post adventure.php -d do=trail_prev)
get adventure.php >/dev/null
chk "the way back leads to section 1, and the offer is gone" "$(grep -q 'Section 1 of' $TD/here-p.html && ! grep -q 'value="trail_prev"' $TD/here-p.html && echo 1)"
echo "== end scene of a knock-out"
cli forceenc >/dev/null
php -r '$p=new PDO("sqlite:'$GAME'/data/game.sqlite"); $r=$p->query("SELECT id,encounter FROM expeditions ORDER BY id DESC LIMIT 1")->fetch(); $e=json_decode($r["encounter"],true); $e["hp"]=$e["max"]=900; $p->prepare("UPDATE expeditions SET encounter=?, hp=?, max_hp=? WHERE id=?")->execute([json_encode($e),1,20,$r["id"]]);'
DOWN=0
for i in $(seq 1 40); do get adventure.php >/dev/null; post adventure.php -d do=attack >/dev/null; get adventure.php >/dev/null; if grep -q 'Knocked out!' $TD/here-p.html; then DOWN=1; break; fi; done
FD=$(grep -o 'data-fight="[^"]*"' $TD/here-p.html | head -1 | php -r 'echo html_entity_decode(stream_get_contents(STDIN));')
chk "a knock-out plays on the stage before the result" "$([ $DOWN = 1 ] && grep -q 'class="fightscene" id="fightscene"' $TD/here-p.html && echo "$FD" | grep -q '"finale":1' && echo "$FD" | grep -q '"end":"ko"\|"ko"' && echo "$FD" | grep -q '"reward":null' && echo 1)" "$(echo $FD | cut -c1-200)"
get adventure.php >/dev/null
chk "...once: a reload shows only the result" "$(grep -q 'id="fightscene"' $TD/here-p.html && echo 0 || echo 1)"
echo "== a fight off the Trail (wander) plays on the map behind it"
login >/dev/null
cli set gnav_on 1 >/dev/null; cli set gnav_tiles 1 >/dev/null
chk "a new tile walk starts" "$([[ $(cli tilewalk | tail -1) == ok ]] && echo 1)"
cli clearenc >/dev/null
get adventure.php >/dev/null
post adventure.php -d do=trail_wander >/dev/null
cli forceenc >/dev/null
php -r '$p=new PDO("sqlite:'$GAME'/data/game.sqlite"); $r=$p->query("SELECT id,encounter FROM expeditions ORDER BY id DESC LIMIT 1")->fetch(); $e=json_decode($r["encounter"],true); $e["hp"]=$e["max"]=900; $p->prepare("UPDATE expeditions SET encounter=?, hp=999, max_hp=999 WHERE id=?")->execute([json_encode($e),$r["id"]]);'
get adventure.php >/dev/null
chk "the wander fight is drawn over the Trail map, with the fight menu" "$(sed -n '/class="wanderbehind"/,$p' $TD/here-p.html | grep -q 'class="tilemap tm-cave tm-trail tm-fight"' && grep -q 'class="fightscene fs-over"' $TD/here-p.html && grep -q 'class="fsdock fsc"' $TD/here-p.html && echo 1)"
chk "...once only (one stage, one menu) and no popover" "$([ "$(grep -c 'id="fightscene"' $TD/here-p.html)" = 1 ] && [ "$(grep -c 'class="fsdock fsc"' $TD/here-p.html)" = 1 ] && ! grep -q 'id="trailpop"' $TD/here-p.html && echo 1)"
FLED=0
for i in $(seq 1 25); do get adventure.php >/dev/null; post adventure.php -d do=flee >/dev/null; get adventure.php >/dev/null; if ! grep -q 'class="fsdock fsc"' $TD/here-p.html; then FLED=1; break; fi; done
chk "running from a wander fight leaves its end scene on the map" "$([ $FLED = 1 ] && grep -q 'class="fightscene fs-over"' $TD/here-p.html && echo 1)"
cli set gnav_on 0 >/dev/null; cli set gnav_tiles 0 >/dev/null; cli set fight_scene 0 >/dev/null
ERR1=$(cat "$GAME/data/error-log.txt" 2>/dev/null | wc -l)
[ "$ERR1" -gt "$ERR0" ] && { echo "  FAIL php errors logged"; tail -n +$((ERR0+1)) "$GAME/data/error-log.txt" | head -5; FAILS=$((FAILS+1)); }
[ "$FAILS" -eq 0 ] && echo "ok" || echo "$FAILS FAILED"
exit $((FAILS>0))
