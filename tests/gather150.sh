#!/bin/bash
# v2.0.67: the World > Gather satchel scene (gather_scene_html in includes/gathering.php; approved mockup claude/art-variants/mockup2) and the
# same box off the path on the adventure page. Run on a fresh SQLite install that walk.sh made (sprout): gather150.sh GAME PORT ROUTER
# Checks: markup and art of the scene, belt, felt cards and finds grid (??? until known), picked card for a sought find, no style= on the page,
# Games has no Practice tab, the reveal on the adventure page plays once, and the upgrade step drops the old gather_games_on setting.
GAME=$1; PORT=$2; ROUTER=$3; BASE=http://127.0.0.1:$PORT
T=$(mktemp -d "${TMPDIR:-/tmp}/g150.XXXXXX")
php -d session.save_path="$T" -S 127.0.0.1:$PORT -t $GAME $ROUTER >"$T/php.log" 2>&1 & PID=$!; sleep 1
trap 'kill $PID 2>/dev/null; [ -d "${T:?}" ] && rm -rf "${T:?}"' EXIT
csrf() { grep -o 'name="csrf" value="[^"]*"' "$1" | head -1 | sed 's/.*value="\([^"]*\)".*/\1/'; }
db() { php -r '$p=new PDO("sqlite:'$GAME'/data/game.sqlite"); foreach($p->query($argv[1])->fetchAll(PDO::FETCH_NUM) as $r) echo implode(" | ",$r),"\n";' "$1"; }
dbx() { php -r '$p=new PDO("sqlite:'$GAME'/data/game.sqlite"); $p->exec($argv[1]);' "$1"; }
chk() { if [ "$2" = "$3" ]; then echo "ok   $1 = $2"; else echo "FAIL $1: got '$2' want '$3'"; fi; }
has() { grep -q -- "$2" "$1" && echo "ok   $3" || echo "FAIL $3 (no '$2')"; }
hasnt() { grep -q -- "$2" "$1" && echo "FAIL $3 (found '$2')" || echo "ok   $3"; }
C=$T/ck; curl -s -c $C -b $C $BASE/login.php > $T/l.html; curl -s -c $C -b $C -X POST $BASE/login.php --data-urlencode "csrf=$(csrf $T/l.html)" -d username=sprout -d 'password=TestPass123!' -o /dev/null
SID=$(db "SELECT id FROM users WHERE username='sprout'")
[ -n "$SID" ] || { echo "FAIL no sprout user"; exit 1; }
dbx "UPDATE users SET onboarded=1, tour_step=0, energy=60, level=6, community_shift_until=NULL WHERE id=$SID"; dbx "UPDATE expeditions SET status='done' WHERE user_id=$SID"
# a Worn knife, a Sturdy net, a Worn pick; no axe, rod, bucket or basket
dbx "DELETE FROM user_items WHERE user_id=$SID AND item_id IN (SELECT id FROM items WHERE category='tool' AND (effects LIKE '%\"tool\":\"basket\"%' OR effects LIKE '%\"tool\":\"axe\"%' OR effects LIKE '%\"tool\":\"rod\"%' OR effects LIKE '%\"tool\":\"bucket\"%' OR effects LIKE '%\"tool\":\"forage\"%' OR effects LIKE '%\"tool\":\"net\"%' OR effects LIKE '%\"tool\":\"pick\"%'))"
for s in foraging-knife fine-mesh-net rock-pick; do dbx "INSERT OR IGNORE INTO user_items (user_id,item_id,qty) SELECT $SID,id,1 FROM items WHERE slug='$s'"; done
FOREST=$(db "SELECT id FROM locations WHERE landscape='forest' LIMIT 1"); dbx "UPDATE users SET location_id=$FOREST WHERE id=$SID"
W=$T/w.html; curl -s -c $C -b $C "$BASE/world.php?tab=gather" > $W

echo "== the scene (forest, nothing gathered yet)"
has $W '<section class="gx gatherbox" aria-label="Gather here">' "the satchel section"
has $W 'class="gx-scene pix" src="/assets/img/gather/scene.png?v=' "scene art, same origin, versioned"
has $W 'class="gx-front pix" src="/assets/img/gather/satchel-front.png?v=' "satchel front art"
hasnt $W 'class="gx-banner' "no banner before a gather"
has $W 'class="gx-chip">' "land and energy chips"
grep -q 'class="gx-chip">⚡ 60 / [0-9]' $W || grep -q 'class="gx-chip"><img[^>]*ico-[a-z-]*[^>]*> 60 / [0-9]' $W && echo "ok   energy chip shows 60 / max" || echo "FAIL energy chip: $(grep -o 'class="gx-chip">[^<]*' $W | tr '\n' ' ')"
echo "== the tool belt: 7 slots, owned first, locked slots for the rest"
chk "belt slots" "$(grep -o 'class="belt__slot' $W | wc -l)" 7
chk "locked slots (axe, rod, bucket, pouch)" "$(grep -o 'class="belt__slot is-missing"' $W | wc -l)" 4
chk "one slot in use" "$(grep -o 'belt__slot is-active' $W | wc -l)" 1
has $W 'slot-forage.png' "knife slot art"; has $W 'slot-locked.png' "locked slot art"
has $W 'Fine-mesh Net, Sturdy' "net slot names the tool and its tier"
chk "pips lit (Worn 1 + Sturdy 2 + Worn 1)" "$(grep -o 'belt__pip on' $W | wc -l)" 4
has $W 'class="belt__now"><b>' "the tool in use under the belt"
echo "== felt cards: one per tool that finds something in the forest"
chk "cards" "$(grep -o 'class="gcard"' $W | wc -l)" "$(db "SELECT COUNT(DISTINCT tool) FROM gatherables WHERE active=1 AND (landscapes='any' OR ','||REPLACE(landscapes,' ','')||',' LIKE '%,forest,%')")"
has $W '<button type="submit" class="gcard" name="tool" value="forage"' "knife card submits tool=forage"
has $W 'class="gcard__ribbon"><span class="gcard__label">Foraging</span>' "ribbon label"
has $W 'vig-forage.png' "card art"
if grep -q 'value="axe"\|gx-why-axe' $W; then has $W 'id="gx-why-axe">Needs a' "no hatchet: the axe card is locked and says why"; fi
grep -q '<form method="post" action="/gather.php" class="gx-form"><input type="hidden" name="csrf"' $W && echo "ok   cards post to gather.php with csrf" || echo "FAIL gather form"
has $W 'name="back" value="world.php?tab=gather"' "back field"
echo "== what's here: every forest find, ??? until known"
N=$(db "SELECT COUNT(*) FROM gatherables WHERE active=1 AND (landscapes='any' OR ','||REPLACE(landscapes,' ','')||',' LIKE '%,forest,%')")
chk "find tiles" "$(grep -o '<li class="find' $W | wc -l)" "$N"
K=$(db "SELECT COUNT(*) FROM user_encyclopedia ue JOIN encyclopedia_entries en ON en.id=ue.entry_id JOIN items i ON 'gather:'||i.slug=en.unlock_key JOIN gatherables g ON g.item_id=i.id WHERE ue.user_id=$SID AND g.active=1 AND (g.landscapes='any' OR ','||REPLACE(g.landscapes,' ','')||',' LIKE '%,forest,%')")
chk "unknown tiles (???)" "$(grep -o '<li class="find is-unknown">' $W | wc -l)" "$((N - K))"
chk "??? names" "$(grep -o 'class="find__name">???<' $W | wc -l)" "$((N - K))"
UNK=$(db "SELECT i.name FROM gatherables g JOIN items i ON i.id=g.item_id WHERE g.active=1 AND (g.landscapes='any' OR ','||REPLACE(g.landscapes,' ','')||',' LIKE '%,forest,%') AND NOT EXISTS (SELECT 1 FROM user_encyclopedia ue JOIN encyclopedia_entries en ON en.id=ue.entry_id WHERE ue.user_id=$SID AND en.unlock_key='gather:'||i.slug) LIMIT 1")
[ -n "$UNK" ] && { sed -n '/<ul class="finds">/,/<\/ul>/p' $W | grep -qF "$UNK" && echo "FAIL unknown find '$UNK' named in the grid" || echo "ok   an unknown find ($UNK) is not named"; }
echo "== the page itself"
chk "style= on the Gather tab" "$(grep -c 'style=' $W)" 0
hasnt $W 'gather-games' "no mini-game script"
hasnt $W 'mgfold' "no mini-game panel"
for f in $(grep -o '/assets/img/gather/[a-z0-9-]*\.png' $W | sort -u); do chk "art $f" "$(curl -s -o /dev/null -w '%{http_code}' $BASE$f)" 200; done
for f in felt-idle felt-sel felt-off ribbon-idle ribbon-sel ribbon-off badge-sel badge-done badge-lock flourish-common flourish-uncommon flourish-rare flourish-legendary; do [ -s $GAME/assets/img/gather/$f.png ] && echo "ok   css art $f.png" || echo "FAIL css art $f.png missing"; done

echo "== a gather: the find goes into the satchel, its card is picked, its rarity colours the banner"
curl -s -c $C -b $C -o /dev/null -X POST $BASE/gather.php --data-urlencode "csrf=$(csrf $W)" -d do=gather -d tool=forage -d back=world.php?tab=gather
curl -s -c $C -b $C "$BASE/world.php?tab=gather" > $T/w1.html
grep -qE 'class="gx-banner gx-banner--(common|uncommon|rare)" role="status"' $T/w1.html && echo "ok   rarity banner" || echo "FAIL rarity banner"
grep -qE 'class="gx-tag gx-tag--rar">(●|◆|★)' $T/w1.html || grep -qE 'class="gx-tag gx-tag--rar"><img[^>]*> ' $T/w1.html && echo "ok   rarity word with its mark" || echo "FAIL rarity mark: $(grep -o 'gx-tag--rar">[^<]*' $T/w1.html)"
has $T/w1.html 'class="gx-spark gx-spark--' "rarity flourish behind the item"
has $T/w1.html 'value="forage" aria-pressed="true"' "the knife card is picked"
chk "style= after a gather" "$(grep -c 'style=' $T/w1.html)" 0
curl -s -c $C -b $C "$BASE/world.php?tab=gather" > $T/w2.html; hasnt $T/w2.html 'gx-banner' "the reveal shows once"

echo "== seeking a find marks its tool's card as picked"
SLUG=$(db "SELECT i.slug FROM gatherables g JOIN items i ON i.id=g.item_id WHERE g.tool IN ('net','pick') AND g.active=1 AND g.rarity IN ('common','uncommon') AND (g.landscapes='any' OR ','||REPLACE(g.landscapes,' ','')||',' LIKE '%,forest,%') ORDER BY g.tool LIMIT 1")
STOOL=$(db "SELECT g.tool FROM gatherables g JOIN items i ON i.id=g.item_id WHERE i.slug='$SLUG'")
if [ -n "$SLUG" ]; then curl -s -c $C -b $C "$BASE/world.php?tab=gather&seek=$SLUG" > $T/s.html; has $T/s.html "value=\"$STOOL\" aria-pressed=\"true\"" "sought $STOOL find ($SLUG): its card is picked"; has $T/s.html 'Seek elsewhere' "seek box"; else echo "FAIL no net/pick find in the forest to seek"; fi

echo "== Games: no Practice tab"
curl -s -c $C -b $C "$BASE/games.php" > $T/g.html; hasnt $T/g.html 'tab=practice' "no Practice tab link"
curl -s -c $C -b $C "$BASE/games.php?tab=practice" > $T/gp.html; hasnt $T/gp.html 'Tool game practice' "old Practice URL shows the games"; has $T/gp.html 'class="gtile' "games tiles on the old URL"

echo "== off the path (adventure page): the same box, the reveal once"
for s in fine-foraging-knife silk-net fine-rock-hammer fine-felling-axe fine-fly-rod divers-creel; do dbx "INSERT OR IGNORE INTO user_items (user_id,item_id,qty) SELECT $SID,id,1 FROM items WHERE slug='$s'"; done
HOME_=$(db "SELECT COALESCE(NULLIF(home_village_id,0), location_id) FROM users WHERE id=$SID"); dbx "UPDATE users SET location_id=$HOME_, energy=60, energy_updated_at=datetime('now') WHERE id=$SID"
curl -s -c $C -b $C $BASE/world.php > $T/x.html
curl -s -c $C -b $C -o /dev/null -X POST $BASE/adventure.php --data-urlencode "csrf=$(csrf $T/x.html)" -d do=explore
dbx "UPDATE expeditions SET depth=1, encounter=NULL WHERE user_id=$SID AND status='active'"
curl -s -c $C -b $C $BASE/adventure.php > $T/a.html
if grep -q 'class="gx gatherbox"' $T/a.html; then
  echo "ok   the satchel box is on the adventure page"
  TOOL=$(grep -o '<button type="submit" class="gcard" name="tool" value="[a-z]*"' $T/a.html | head -1 | grep -o 'value="[a-z]*"' | cut -d'"' -f2)
  grep -q '<form method="post" action="/adventure.php" class="gx-form">' $T/a.html && echo "ok   it posts to adventure.php" || echo "FAIL adventure form action"
  E0=$(db "SELECT energy FROM users WHERE id=$SID")
  curl -s -c $C -b $C -o /dev/null -X POST $BASE/adventure.php --data-urlencode "csrf=$(csrf $T/a.html)" -d do=gather -d tool=$TOOL
  chk "off-path gather ($TOOL) cost" "$((E0 - $(db "SELECT energy FROM users WHERE id=$SID")))" 1
  db "SELECT log FROM expeditions WHERE user_id=$SID AND status='active'" | grep -q 'You gather [0-9]' && echo "ok   journal has the find" || echo "FAIL journal lacks the find"
  curl -s -c $C -b $C $BASE/adventure.php > $T/a1.html; has $T/a1.html 'class="gx-banner gx-banner--' "reveal on the adventure page"
  chk "style= on the adventure page" "$(grep -c 'style=' $T/a1.html)" 0
  curl -s -c $C -b $C $BASE/adventure.php > $T/a2.html; hasnt $T/a2.html 'gx-banner' "and only once"
  curl -s -c $C -b $C -o /dev/null -X POST $BASE/adventure.php --data-urlencode "csrf=$(csrf $T/a2.html)" -d do=return
else
  echo "FAIL no satchel box on the adventure page (expedition: $(db "SELECT kind, depth, status FROM expeditions WHERE user_id=$SID ORDER BY id DESC LIMIT 1"))"
fi

echo "== upgrade step: an old install's gather_games_on row is dropped"
dbx "INSERT INTO settings (name, value) VALUES ('gather_games_on', '1')"; OLDV=$(db "SELECT value FROM settings WHERE name='db_version'")
dbx "UPDATE settings SET value='2.0.66' WHERE name='db_version'"; dbx "DELETE FROM settings WHERE name='boot_failed_steps'"
if [ "$OLDV" = "2.0.66" ]; then dbx "UPDATE settings SET value='2.0.60' WHERE name='db_version'"; fi   # this build is still 2.0.66: start from an older one so the upgrade runs
curl -s -c $C -b $C "$BASE/world.php?tab=gather" -o /dev/null
chk "gather_games_on rows after the upgrade" "$(db "SELECT COUNT(*) FROM settings WHERE name='gather_games_on'")" 0
chk "boot_failed_steps" "$(db "SELECT COALESCE(MAX(value),'') FROM settings WHERE name='boot_failed_steps'")" ""
echo "== php log"; grep -iE 'fatal|warning|notice|deprecated' "$T/php.log" || echo "(none)"
