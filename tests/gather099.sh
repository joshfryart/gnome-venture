#!/bin/bash
# v2.0.67: gathering rules after the tool mini-games were removed (World > Gather, gather.php). Run on a fresh SQLite install that walk.sh made (sprout):
#   gather099.sh GAME PORT ROUTER
# Checks: a try costs exactly 1 energy and gives exactly 1 find (no basket, Sense, rainbow or calling perk), the tool wears every time,
# a weak tool or no tool costs nothing, CSRF and the back-URL guard, the reveal plays once, and nothing of the mini-game is left in game/.
GAME=$1; PORT=$2; ROUTER=$3; BASE=http://127.0.0.1:$PORT
T=$(mktemp -d "${TMPDIR:-/tmp}/g099.XXXXXX")
php -d session.save_path="$T" -S 127.0.0.1:$PORT -t $GAME $ROUTER >"$T/php.log" 2>&1 & PID=$!; sleep 1
trap 'kill $PID 2>/dev/null; [ -d "${T:?}" ] && rm -rf "${T:?}"' EXIT
csrf() { grep -o 'name="csrf" value="[^"]*"' "$1" | head -1 | sed 's/.*value="\([^"]*\)".*/\1/'; }
db() { php -r '$p=new PDO("sqlite:'$GAME'/data/game.sqlite"); foreach($p->query($argv[1])->fetchAll(PDO::FETCH_NUM) as $r) echo implode(" | ",$r),"\n";' "$1"; }
dbx() { php -r '$p=new PDO("sqlite:'$GAME'/data/game.sqlite"); $p->exec($argv[1]);' "$1"; }
chk() { if [ "$2" = "$3" ]; then echo "ok   $1 = $2"; else echo "FAIL $1: got '$2' want '$3'"; fi; }
yes_() { if [ "$2" = 1 ]; then echo "ok   $1"; else echo "FAIL $1"; fi; }
C=$T/ck; curl -s -c $C -b $C $BASE/login.php > $T/l.html; curl -s -c $C -b $C -X POST $BASE/login.php --data-urlencode "csrf=$(csrf $T/l.html)" -d username=sprout -d 'password=TestPass123!' -o /dev/null
SID=$(db "SELECT id FROM users WHERE username='sprout'")
[ -n "$SID" ] || { echo "FAIL no sprout user"; exit 1; }
# one Worn foraging knife only: no basket (its +1), Sense 10 (no +1), no rainbow, no calling (no free tries)
dbx "DELETE FROM user_items WHERE user_id=$SID AND item_id IN (SELECT id FROM items WHERE category='tool' AND effects LIKE '%\"tool\":\"basket\"%')"
dbx "INSERT OR IGNORE INTO user_items (user_id,item_id,qty) SELECT $SID,id,1 FROM items WHERE slug='foraging-knife'"
dbx "UPDATE users SET onboarded=1, tour_step=0, energy=50, stat_sense=10, stat_luck=10, ev_gather_until=NULL, calling=NULL, buff=NULL, buff2=NULL, ev_stat=NULL, town_stat=NULL, community_shift_until=NULL WHERE id=$SID"
dbx "UPDATE expeditions SET status='done' WHERE user_id=$SID"
FOREST=$(db "SELECT id FROM locations WHERE landscape='forest' LIMIT 1")
dbx "UPDATE users SET location_id=$FOREST WHERE id=$SID"
page() { curl -s -c $C -b $C "$BASE/world.php?tab=gather" > $T/w.html; }
post() { page; curl -s -c $C -b $C -o $T/out.html -D $T/h.txt -X POST $BASE/gather.php --data-urlencode "csrf=$(csrf $T/w.html)" -d do=gather "$@"; }
energy() { db "SELECT energy FROM users WHERE id=$SID"; }
finds() { db "SELECT COALESCE(SUM(ui.qty),0) FROM user_items ui JOIN gatherables g ON g.item_id=ui.item_id WHERE ui.user_id=$SID"; }
wear() { db "SELECT COALESCE(MAX(ui.wear),0) FROM user_items ui JOIN items i ON i.id=ui.item_id WHERE ui.user_id=$SID AND i.slug='foraging-knife'"; }
location() { grep -i '^location:' $T/h.txt | head -1 | tr -d '\r' | sed 's/^[Ll]ocation: *//'; }

echo "== a try costs exactly 1 energy and gives exactly 1 find; the tool wears every time"
dbx "DELETE FROM settings WHERE name='tool_wear_on'"   # the default: tools wear
for i in 1 2 3; do
  E0=$(energy); F0=$(finds); W0=$(wear)
  post -d tool=forage -d back=world.php?tab=gather
  chk "try $i energy spent" "$((E0 - $(energy)))" 1
  chk "try $i finds gained" "$(( $(finds) - F0 ))" 1
  chk "try $i knife wear +1" "$(( $(wear) - W0 ))" 1
done
curl -s -c $C -b $C "$BASE/world.php?tab=gather" > $T/w1.html
grep -q 'You gather 1 ×' $T/w1.html && echo "ok   flash says You gather 1 ×" || echo "FAIL flash lacks 'You gather 1 ×'"

echo "== the reveal plays once, then clears"
yes_ "first view after a gather: banner" "$(grep -c 'class="gx-banner gx-banner--' $T/w1.html | sed 's/^[1-9][0-9]*$/1/')"
yes_ "first view: the find sits in the satchel (gx-find + gx-item)" "$(grep -q 'class="gx-find"' $T/w1.html && grep -q 'gx-item' $T/w1.html && echo 1)"
yes_ "first view: Into your satchel" "$(grep -q 'Into your satchel' $T/w1.html && echo 1)"
page; yes_ "second view: no banner" "$(grep -q 'gx-banner' $T/w.html || echo 1)"
yes_ "second view: no find in the satchel" "$(grep -q 'class="gx-find"' $T/w.html || echo 1)"
yes_ "second view: the scene is still there" "$(grep -q 'class="gx-scene' $T/w.html && grep -q 'class="gx-front' $T/w.html && echo 1)"

echo "== a weak tool costs no energy (the knife is Worn; every forage find is made Uncommon+ for this check)"
dbx "CREATE TABLE g_keep AS SELECT item_id, rarity FROM gatherables WHERE tool='forage'"; dbx "UPDATE gatherables SET rarity='uncommon' WHERE tool='forage' AND rarity='common'"
E0=$(energy); F0=$(finds)
post -d tool=forage -d back=world.php?tab=gather
chk "weak tool: energy unchanged" "$(energy)" "$E0"; chk "weak tool: no find" "$(finds)" "$F0"
curl -s -c $C -b $C "$BASE/world.php?tab=gather" > $T/w2.html
grep -q 'isn’t good enough' $T/w2.html && echo "ok   weak tool says why" || echo "FAIL weak tool message missing"
yes_ "weak tool card is locked (aria-disabled, type=button, Needs Sturdy)" "$(grep -q 'type="button" class="gcard" aria-disabled="true" aria-describedby="gx-why-forage"' $T/w2.html && grep -q 'id="gx-why-forage">Needs Sturdy' $T/w2.html && echo 1)"
yes_ "no reveal after a refused try" "$(grep -q 'gx-banner' $T/w2.html || echo 1)"

echo "== no tool costs no energy"
dbx "UPDATE gatherables SET rarity=(SELECT k.rarity FROM g_keep k WHERE k.item_id=gatherables.item_id) WHERE tool='forage'"; dbx "DROP TABLE g_keep"
dbx "DELETE FROM user_items WHERE user_id=$SID AND item_id IN (SELECT id FROM items WHERE category='tool' AND effects LIKE '%\"tool\":\"forage\"%')"
E0=$(energy); post -d tool=forage -d back=world.php?tab=gather
chk "no tool: energy unchanged" "$(energy)" "$E0"
curl -s -c $C -b $C "$BASE/world.php?tab=gather" > $T/w3.html
grep -q 'You need a foraging knife' $T/w3.html && echo "ok   no tool says why" || echo "FAIL no tool message missing"
yes_ "no tool: card says Needs a foraging knife" "$(grep -q 'id="gx-why-forage">Needs a foraging knife' $T/w3.html && echo 1)"
dbx "INSERT OR IGNORE INTO user_items (user_id,item_id,qty) SELECT $SID,id,1 FROM items WHERE slug='foraging-knife'"
E0=$(energy); post -d tool=staff -d back=world.php?tab=gather
chk "a non-gathering tool: energy unchanged" "$(energy)" "$E0"

echo "== out of energy: refused, nothing found"
dbx "UPDATE users SET energy=0, energy_updated_at=datetime('now') WHERE id=$SID"
F0=$(finds); post -d tool=forage -d back=world.php?tab=gather
chk "no energy: no find" "$(finds)" "$F0"
dbx "UPDATE users SET energy=50 WHERE id=$SID"

echo "== CSRF and the back URL"
chk "gather without csrf" "$(curl -s -o /dev/null -w '%{http_code}' -c $C -b $C -X POST $BASE/gather.php -d do=gather -d tool=forage)" 400
chk "GET gather.php sends you to the World page" "$(curl -s -o /dev/null -w '%{redirect_url}' -c $C -b $C $BASE/gather.php | sed 's#.*/##')" world.php
post -d tool=forage -d back=town.php?tab=square; chk "a town page is a fine back" "$(location | sed 's#^.*/##')" 'town.php?tab=square'
for bad in 'https://evil.example/world.php' '//evil.example/world.php' 'world.php?x=//evil.example' 'admin/index.php' 'javascript:alert(1)' '../world.php' 'world.php extra'; do
  post -d tool=forage --data-urlencode "back=$bad"; L=$(location)
  case "$L" in */world.php) echo "ok   bad back '$bad' -> world.php";; *) echo "FAIL bad back '$bad' -> '$L'";; esac
done

echo "== nothing of the mini-game is left in game/"
N=$(grep -rlE 'gather_round|gather_game_|gather_practice|gather_games_on|gquick|mgform|mgfold|gather-games' "$GAME" --include=*.php --include=*.js --include=*.css | grep -v 'includes/bootstrap.php' | wc -l)
chk "files naming gather_round / gather_game_ / gquick / mgfold / gather-games (bootstrap's clean-up step aside)" "$N" 0
[ -e "$GAME/includes/gather_game.php" ] && echo "FAIL includes/gather_game.php still there" || echo "ok   includes/gather_game.php is gone"
[ -e "$GAME/assets/gather-games.js" ] && echo "FAIL assets/gather-games.js still there" || echo "ok   assets/gather-games.js is gone"
chk "gather_games_on setting row (dropped by upgrade_2067)" "$(db "SELECT COUNT(*) FROM settings WHERE name='gather_games_on'")" 0
echo "== php log"; grep -iE 'fatal|warning|notice|deprecated' "$T/php.log" || echo "(none)"
