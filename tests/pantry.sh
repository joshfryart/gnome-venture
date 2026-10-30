#!/bin/bash
# v0.9.8 part A: the Pantry (Kitchen add-on, jars with real-day timers, preserves, Fair class, gifts, Almanac, upgrade path).
# Run on a fresh SQLite install that walk.sh made (player "sprout"): pantry.sh GAME PORT ROUTER
# The HTTP flows are here; stacking, sell prices, the Fair and the upgrade are checked by pantry.php on the same world.
GAME=$1; PORT=$2; ROUTER=$3; BASE=http://127.0.0.1:$PORT; HERE=$(cd "$(dirname "$0")" && pwd)
LOG=/tmp/pantry-php.log
php -d session.save_path=/tmp -d display_errors=1 -S 127.0.0.1:$PORT -t $GAME $ROUTER >$LOG 2>&1 & PID=$!; sleep 1
trap "kill $PID 2>/dev/null" EXIT
FAILS=0
C=/tmp/pantry-ck; rm -f $C
csrf() { grep -o 'name="csrf" value="[^"]*"' "$1" | head -1 | sed 's/.*value="\([^"]*\)".*/\1/'; }
db() { php -r '$p=new PDO("sqlite:'$GAME'/data/game.sqlite"); foreach($p->query($argv[1])->fetchAll(PDO::FETCH_NUM) as $r) echo implode(" | ",$r),"\n";' "$1"; }
dbx() { php -r '$p=new PDO("sqlite:'$GAME'/data/game.sqlite"); $p->exec($argv[1]);' "$1"; }
page() { curl -s -c $C -b $C "$BASE/$1" | sed -E 's#<img class="ico pix" src="[^"]*/ico-jar\.png[^>]*>#🫙#g; s#<img class="ico pix"[^>]*> ?##g' > /tmp/pk.html; }   # v2.0.23: the game swaps emoji for icon images; put the jar emoji back (drop the other icons) so the greps below can match
post() { local pg=$1 form=$2; shift 2; page "$form"; curl -s -c $C -b $C -X POST "$BASE/$pg" --data-urlencode "csrf=$(csrf /tmp/pk.html)" "$@" -o /dev/null; page "$form"; grep -oE '<li class="ml (ok|err)[^"]*">.*</li>' /tmp/pk.html | head -1 | sed -E 's/<small class="mlwhen">.*//; s/<li class="ml //; s/<[^>]*>//g'; }   # whole message, tags stripped (messages can hold <b> now)
chk() { if [ "$2" = "$3" ]; then echo "ok   $1 = $2"; else echo "FAIL $1: got '$2' want '$3'"; FAILS=$((FAILS+1)); fi; }
has() { case "$2" in *"$1"*) echo "ok   $3";; *) echo "FAIL $3: got '$2'"; FAILS=$((FAILS+1));; esac; }
give() { dbx "INSERT OR REPLACE INTO user_items (user_id,item_id,qty) SELECT $UID_, id, $2 FROM items WHERE slug='$1'"; }
qty() { db "SELECT COALESCE((SELECT ui.qty FROM user_items ui JOIN items i ON i.id=ui.item_id WHERE ui.user_id=$UID_ AND i.slug='$1'),0)"; }
energy() { db "SELECT energy FROM users WHERE id=$UID_"; }
setE() { dbx "UPDATE users SET energy=$1, energy_updated_at=datetime('now') WHERE id=$UID_"; }
coins() { db "SELECT coins FROM users WHERE id=$UID_"; }
page login.php; curl -s -c $C -b $C -X POST $BASE/login.php --data-urlencode "csrf=$(csrf /tmp/pk.html)" -d username=sprout -d 'password=TestPass123!' -o /dev/null
UID_=$(db "SELECT id FROM users WHERE username='sprout'")
P=$(db "SELECT id FROM plots WHERE user_id=$UID_ ORDER BY id LIMIT 1")
dbx "REPLACE INTO settings (name, value) VALUES ('xp_action_scale_percent', '0')"   # base XP numbers, as cook.sh does
dbx "UPDATE users SET tour_step=0, level=20, coins=5000, calling=NULL, calling_chapter=NULL, calling_qt=0 WHERE id=$UID_"
dbx "DELETE FROM garden_buildings WHERE plot_id=$P"; dbx "DELETE FROM pantry_jars"; dbx "UPDATE plots SET garden_level=9 WHERE id=$P"
GP=garden.php; PT="inventory.php?tab=craft&c=pantry"
jars() { db "SELECT COUNT(*) FROM pantry_jars WHERE user_id=$UID_ AND collected_at IS NULL"; }
makeit() { post crafting.php "$PT" -d recipe_id=$(db "SELECT id FROM recipes WHERE slug='$1'") -d qty=$2; }
readyall() { dbx "UPDATE pantry_jars SET ready_at=datetime('now','-1 minute') WHERE collected_at IS NULL"; }
stock() { for s in $(db "SELECT key FROM recipes, json_each(recipes.ingredients) WHERE recipes.slug='$1'"); do give $s ${2:-60}; done; }
eat() { post inventory.php inventory.php -d do=eat -d item_id=$(db "SELECT id FROM items WHERE slug='$1'"); }

echo "== data: 14 preserves, tier, timers, batches, items"
NPRE=$(awk -F"|" '!/^#/ && $8=="preserve"{n++} END{print n}' $GAME/includes/data/recipes.txt)   # every preserve row in recipes.txt
chk "$NPRE pantry recipes (all of recipes.txt tier preserve)" "$(db "SELECT COUNT(*) FROM recipes WHERE category='pantry' AND tier='preserve'")" $NPRE
chk "timers (minutes): jam 1440 chutney 2880 pickles 4320 kimchi 7200 sauerkraut 10080 cordial 20160" "$(db "SELECT group_concat(DISTINCT cook_minutes) FROM (SELECT cook_minutes FROM recipes WHERE category='pantry' ORDER BY cook_minutes)")" "1440,2880,4320,7200,10080,20160"
chk "jam makes 4, pickles 3" "$(db "SELECT (SELECT output_qty FROM recipes WHERE slug='plum-jam')||(SELECT output_qty FROM recipes WHERE slug='dill-pickles')")" 43
chk "jam is a food item, edible, tradable, flagged preserve" "$(db "SELECT category||edible||tradable||json_extract(effects,'\$.preserve') FROM items WHERE slug='plum-jam'")" food111
chk "Strawberry Jam has no buff" "$(db "SELECT COALESCE(json_extract(effects,'\$.temp'),'none') FROM items WHERE slug='strawberry-jam'")" none
chk "cordial buff is 24 h" "$(db "SELECT json_extract(effects,'\$.temp.minutes') FROM items WHERE slug='elderberry-cordial'")" 1440
chk "recipe Almanac pages in the Preserves section" "$(db "SELECT COUNT(*) FROM encyclopedia_entries WHERE chapter='Recipes' AND category='Preserves'")" $NPRE
chk "Pantry + Preserves how-to pages" "$(db "SELECT COUNT(*) FROM encyclopedia_entries WHERE unlock_key='pantry'")" 2
chk "pantry tab is the 2nd crafting tab" "$(php -r '$_SERVER["SCRIPT_NAME"]="/gnome.php"; require "'$GAME'/includes/bootstrap.php"; require_once "'$GAME'/includes/crafting.php"; echo implode(",", array_slice(array_keys(CRAFT_CATEGORIES),0,2));')" cooking,pantry
chk "pickled-radishes stays a cooking snack" "$(db "SELECT category||tier FROM recipes WHERE slug='pickled-radishes'")" cookingsnack
dbx "INSERT OR IGNORE INTO user_recipes (user_id,recipe_id,learned_at) SELECT $UID_, id, datetime('now') FROM recipes WHERE category='pantry'"
for r in $(db "SELECT slug FROM recipes WHERE category='pantry'"); do stock $r 60; done; give timber-plank 10

echo "== the add-on: Kitchen first, then Petals + planks"
m=$(post $GP $GP -d do=pantry_buy); has "Kitchen" "$m" "no Kitchen: refused"; chk "no pantry yet" "$(db "SELECT COUNT(*) FROM garden_buildings WHERE plot_id=$P")" 0
page "$PT"; has "need a" "$(grep -o 'You need a <b>[^<]*</b>' /tmp/pk.html | head -1)" "tab says a Kitchen is needed"
dbx "INSERT INTO garden_buildings (plot_id,building,built_at,last_collect) VALUES ($P,'kitchen',datetime('now'),datetime('now'))"
page "$PT"; has "Pantry" "$(grep -o 'You need a <b>[^<]*Pantry</b>' /tmp/pk.html | head -1)" "tab says a Pantry is needed"; chk "no jar strip yet" "$(grep -c 'jarstrip' /tmp/pk.html)" 0
page "$GP?t=bld"; has "Add a Pantry" "$(grep -o 'Add a Pantry · [0-9,]* Petals' /tmp/pk.html | head -1)" "Kitchen tile offers the add-on with its price"
dbx "UPDATE users SET coins=100 WHERE id=$UID_"; m=$(post $GP $GP -d do=pantry_buy); has "costs" "$m" "100 Petals: refused"; chk "pantry still 0" "$(db "SELECT pantry FROM garden_buildings WHERE plot_id=$P")" 0; chk "planks untouched (rolled back)" "$(qty timber-plank)" 10
dbx "UPDATE users SET coins=5000 WHERE id=$UID_"; give timber-plank 2; m=$(post $GP $GP -d do=pantry_buy); has "Timber Plank" "$m" "2 planks: refused"; chk "pantry still 0" "$(db "SELECT pantry FROM garden_buildings WHERE plot_id=$P")" 0; chk "Petals untouched (rolled back)" "$(coins)" 5000
give timber-plank 10; m=$(post $GP $GP -d do=pantry_buy); has "You fit a Pantry" "$m" "bought"
chk "pantry = 1" "$(db "SELECT pantry FROM garden_buildings WHERE plot_id=$P")" 1; chk "-600 Petals" "$(coins)" 4400; chk "-4 planks" "$(qty timber-plank)" 6
m=$(post $GP $GP -d do=pantry_buy); has "already has" "$m" "second purchase refused"; chk "no double charge" "$(coins)" 4400
chk "Almanac: both pages unlocked" "$(db "SELECT COUNT(*) FROM user_encyclopedia ue JOIN encyclopedia_entries e ON e.id=ue.entry_id WHERE ue.user_id=$UID_ AND e.unlock_key='pantry'")" 2
dbx "DELETE FROM garden_buildings WHERE plot_id=$P AND building='kitchen'"; dbx "INSERT INTO garden_buildings (plot_id,building,built_at,last_collect,pantry) VALUES ($P,'kitchen',datetime('now'),datetime('now'),1)"
page "$GP?t=bld"; has "0/5 jars in use" "$(grep -o '[0-9]*/[0-9]* jars in use' /tmp/pk.html | head -1)" "Kitchen tile: Pantry with 5 jars"; has "2 pots" "$(grep -o '2 pots · 🫙 5' /tmp/pk.html | head -1)" "tile status shows pots and jars"
echo "bad csrf buy: $(curl -s -b $C -X POST "$BASE/garden.php" -d csrf=x -d do=pantry_buy -o /dev/null -w '%{http_code}')"

echo "== jars: 5 to start, a jar per batch, energy 1 a batch"
page "$PT"; chk "jar strip" "$(grep -c 'class="p2jars jarstrip"' /tmp/pk.html)" 1; chk "5 free jars" "$(grep -o '+5 free' /tmp/pk.html | wc -l)" 1; has "0/5" "$(grep -o '[0-9]*/[0-9]* jars in use' /tmp/pk.html | head -1)" "0/5 in use"
chk "$NPRE recipe rows on the tab" "$(grep -o 'class="p2row' /tmp/pk.html | wc -l)" $NPRE; chk "selected recipe tagged preserve" "$(grep -o '🫙 preserve' /tmp/pk.html | wc -l)" 1
setE 60; S0=$(qty strawberry); m=$(makeit strawberry-jam 3)
has "Preserving 3 batches of Strawberry Jam" "$m" "3 batches started"; chk "3 jars busy" "$(jars)" 3; chk "energy 60 -> 57" "$(energy)" 57; chk "strawberries taken (5 each)" "$(qty strawberry)" $((S0-15))
chk "each jar holds 4 jam, ready in exactly 1 day" "$(db "SELECT DISTINCT qty||'/'||CAST((julianday(ready_at)-julianday(started_at))*86400+0.5 AS INTEGER) FROM pantry_jars")" "4/86400"
chk "quality scores 0-100" "$(db "SELECT COUNT(*) FROM pantry_jars WHERE score < 1 OR score > 100")" 0
m=$(makeit plum-jam 5); has "Only 2 fit" "$m" "5 asked, 2 free jars: clamped"; chk "5 jars busy" "$(jars)" 5; chk "energy -2" "$(energy)" 55
m=$(makeit plum-jam 1); has "All your jars are full" "$m" "6th jar refused"; chk "still 5" "$(jars)" 5; chk "energy untouched" "$(energy)" 55
page "$PT"; has "5/5 jars" "$(grep -o '[0-9]*/[0-9]* jars in use' /tmp/pk.html | head -1)" "strip: 5/5"; has "All jars are full" "$(grep -o 'All jars are full' /tmp/pk.html | head -1)" "cards say all jars are full"
chk "jar timers shown" "$(grep -o 'data-jarleft' /tmp/pk.html | wc -l)" 5; chk "Collect forms hidden until ready" "$(grep -o 'class="potcollect" hidden' /tmp/pk.html | wc -l)" 5

echo "== lazy timers: nothing before the time, collect after"
m=$(post crafting.php "$PT" -d do=jar_collect_all); has "No jar is ready" "$m" "collect all: nothing ready"
J1=$(db "SELECT id FROM pantry_jars WHERE collected_at IS NULL ORDER BY id LIMIT 1")
m=$(post crafting.php "$PT" -d do=jar_collect -d jar_id=$J1); has "ready yet" "$m" "single collect early refused"; chk "jar kept" "$(jars)" 5
dbx "UPDATE pantry_jars SET ready_at=datetime('now','-1 minute') WHERE recipe_id=(SELECT id FROM recipes WHERE slug='strawberry-jam')"
page "garden.php?t=bld"; has "🫙 3 ready" "$(grep -o '🫙 [0-9]* ready' /tmp/pk.html | head -1)" "status strip: 3 jars ready"
JB=$(db "SELECT id FROM user_jobs LIMIT 1"); dbx "DELETE FROM user_jobs WHERE user_id=$UID_"
JK=$(TZ=America/Halifax date +%F)   # v1.4.0: days turn over at Hollow midnight (1.2.2)
dbx "INSERT INTO user_jobs (user_id,period,period_key,kind,title,text,qty,progress,status,taken_at) VALUES ($UID_,'daily','$JK','cook','Cook','Cook 5 meals',5,0,'active',datetime('now')),($UID_,'daily','$JK','craft','Craft','Craft 5 things',5,0,'active',datetime('now'))"
CH=$(db "SELECT id FROM calling_chapters WHERE slug='brewroot-1'"); dbx "UPDATE users SET calling='brewroot', calling_chapter=$CH WHERE id=$UID_"
dbx "INSERT OR IGNORE INTO user_calling_tasks (user_id,task_id,progress) SELECT $UID_, id, 0 FROM calling_tasks WHERE chapter_id=$CH"
callp() { db "SELECT COALESCE(SUM(ut.progress),0) FROM user_calling_tasks ut JOIN calling_tasks t ON t.id=ut.task_id WHERE ut.user_id=$UID_ AND t.chapter_id=$CH AND t.kind='cook'"; }
jobp() { db "SELECT progress FROM user_jobs WHERE user_id=$UID_ AND kind='$1'"; }
X0=$(db "SELECT xp FROM users WHERE id=$UID_"); F0=$(qty food-scrap); N0=$(qty strawberry-jam)
m=$(post crafting.php "$PT" -d do=jar_collect -d jar_id=$J1)
has "Collected 4 × Strawberry Jam (+3 XP" "$m" "collect: 4 jam, XP 2 + 1 day"; chk "jam +4" "$(qty strawberry-jam)" $((N0+4)); chk "jar emptied" "$(jars)" 4
chk "5 ingredients -> 1 Food Scrap" "$(qty food-scrap)" $((F0+1)); chk "recipe made +1" "$(db "SELECT made FROM user_recipes ur JOIN recipes r ON r.id=ur.recipe_id WHERE ur.user_id=$UID_ AND r.slug='strawberry-jam'")" 1
chk "Job Board 'cook meals' NOT moved by a preserve" "$(jobp cook)" 0; chk "...but it counts as a craft" "$(jobp craft)" 1; chk "calling 'cook meals' task NOT moved" "$(callp)" 0
chk "Pots Almanac page not opened by a jar" "$(db "SELECT COUNT(*) FROM user_encyclopedia ue JOIN encyclopedia_entries e ON e.id=ue.entry_id WHERE ue.user_id=$UID_ AND e.unlock_key='pots'")" 0
chk "recipe page unlocked" "$(db "SELECT COUNT(*) FROM user_encyclopedia ue JOIN encyclopedia_entries e ON e.id=ue.entry_id WHERE ue.user_id=$UID_ AND e.unlock_key='recipe:strawberry-jam'")" 1
chk "Fair: best Preserves jar kept this month" "$(db "SELECT label FROM fair_best WHERE user_id=$UID_ AND cat='preserve'")" "Strawberry Jam"
m=$(post crafting.php "$PT" -d do=jar_collect -d jar_id=$J1); has "already empty" "$m" "second collect refused"; chk "jam not doubled" "$(qty strawberry-jam)" $((N0+4))
m=$(post crafting.php "$PT" -d do=jar_collect_all); has "Collected 8 × Strawberry Jam" "$m" "collect all takes the other two"; chk "jam +12 in all" "$(qty strawberry-jam)" $((N0+12)); chk "plum jars still waiting" "$(jars)" 2
chk "craft job +3 in all" "$(jobp craft)" 3; chk "cook job still 0" "$(jobp cook)" 0
page "$PT"; has "2/5" "$(grep -o '[0-9]*/[0-9]* jars in use' /tmp/pk.html | head -1)" "strip: 2/5 now"

echo "== eating a preserve: energy like a meal, long small buff"
give sauerkraut 3; give strawberry-jam 3; dbx "UPDATE users SET calling=NULL, calling_chapter=NULL, level=20, buff=NULL, buff_until=NULL, buff2=NULL, buff2_until=NULL WHERE id=$UID_"
setE 0; eat sauerkraut; chk "sauerkraut 5 x1.15 = 6 energy (home-cooked scaling, v1.1.0)" "$(energy)" 6
chk "buff: hardiness+grit" "$(db "SELECT buff FROM users WHERE id=$UID_")" '{"hardiness":1,"grit":1}'
chk "buff lasts 18 h (Kitchen I adds nothing)" "$(db "SELECT CAST((julianday(buff_until)-julianday('now'))*1440+0.5 AS INTEGER) FROM users WHERE id=$UID_")" 1080
dbx "UPDATE users SET buff=NULL, buff_until=NULL WHERE id=$UID_"; setE 0; eat strawberry-jam; chk "jam 3 x1.15 = 3 (3.45 rounds down, v1.1.0)" "$(energy)" 3; chk "plain jam: no buff" "$(db "SELECT COALESCE(buff,'none') FROM users WHERE id=$UID_")" none
chk "first taste noted for both" "$(db "SELECT COUNT(*) FROM user_tasted t JOIN items i ON i.id=t.item_id WHERE t.user_id=$UID_ AND i.slug IN ('sauerkraut','strawberry-jam')")" 2

echo "== sell price (see pantry.php for every recipe) and a gift"
page inventory.php; echo "satchel shows jam: $(grep -c 'Strawberry Jam' /tmp/pk.html)"

echo "== Kitchen III: +2 jars"
dbx "UPDATE garden_buildings SET level=3 WHERE plot_id=$P AND building='kitchen'"; setE 60
page "$PT"; has "2/7" "$(grep -o '[0-9]*/[0-9]* jars in use' /tmp/pk.html | head -1)" "strip: 2/7 at Kitchen III"
m=$(makeit tomato-chutney 6); has "Only 5 fit" "$m" "7 jars - 2 busy = 5 free"; chk "7 busy" "$(jars)" 7
m=$(makeit tomato-chutney 1); has "All your jars are full" "$m" "8th refused"
chk "chutney takes 2 days" "$(db "SELECT DISTINCT CAST((julianday(ready_at)-julianday(started_at))*86400+0.5 AS INTEGER) FROM pantry_jars j JOIN recipes r ON r.id=j.recipe_id WHERE r.slug='tomato-chutney'")" 172800
readyall; m=$(post crafting.php "$PT" -d do=jar_collect_all); has "Collected" "$m" "collected the lot"; chk "all jars empty" "$(jars)" 0
page "$PT"; chk "7 free jars shown" "$(grep -o '+7 free' /tmp/pk.html | wc -l)" 1

echo "== Harvest Fair Preserves class (page)"
page fair.php; has "Preserves" "$(grep -o '<h2>🫙 Preserves</h2>' /tmp/pk.html | head -1 | sed 's/<[^>]*>//g')" "Fair page has the class"; has "$(db "SELECT label FROM fair_best WHERE user_id=$UID_ AND cat='preserve'")" "$(grep -o 'Your best: <b>[^<]*' /tmp/pk.html | tail -1)" "your best is a jar"
m=$(post fair.php fair.php -d do=enter -d cat=preserve); has "Entered in the Preserves class" "$m" "entered"
chk "entry has a label, no plant" "$(db "SELECT label||'/'||plant_id FROM fair_entries WHERE user_id=$UID_ AND cat='preserve'")" "$(db "SELECT label FROM fair_best WHERE user_id=$UID_ AND cat='preserve'")/0"

echo "== a gift: every townsfolk likes a jar, even one who dislikes food"
TW=$(db "SELECT id FROM shops WHERE slug='twigg-s-seed-emporium'")
NID=$(php "$HERE/pantry.php" "$GAME" npc 2>/dev/null | tail -1)
dbx "INSERT INTO npc_schedules (npc_id,location_id,shop_id,activity,start_hour,end_hour,days) SELECT $NID, id, NULL, 'working', 0, 24, 'all' FROM locations WHERE kind='hub' ORDER BY id LIMIT 1"
dbx "DELETE FROM npc_friends WHERE user_id=$UID_"
np() { curl -s -c $C -b $C "$BASE/villagers.php?id=$NID" > /tmp/pk0.html; curl -s -c $C -b $C -X POST "$BASE/folk.php?id=$NID" --data-urlencode "csrf=$(csrf /tmp/pk0.html)" "$@" -o /dev/null; curl -s -c $C -b $C "$BASE/villagers.php?id=$NID" > /tmp/pk.html; grep -oE '<li class="ml (ok|err)[^"]*">.*</li>' /tmp/pk.html | head -1 | sed -E 's/<small class="mlwhen">.*//; s/<li class="ml //; s/<[^>]*>//g'; }   # whole message, tags stripped (messages can hold <b> now)
echo "npc $NID: $(db "SELECT name FROM npcs WHERE id=$NID")"
give dill-pickles 2
m=$(np -d do=gift -d item_id=$(db "SELECT id FROM items WHERE slug='dill-pickles'"))
has "preserves" "$m" "gift reaction: likes preserves"; has "+10 friendship" "$m" "+10 friendship (liked)"
chk "jar given away" "$(qty dill-pickles)" 1

echo "== pantry.php: stacking, prices, Fair judging, jobs, upgrade path"
php -d display_errors=1 "$HERE/pantry.php" "$GAME" 2>&1 | tee /tmp/pantry-cli.out
FAILS=$((FAILS + $(grep -c '^  FAIL' /tmp/pantry-cli.out)))
grep -q '^all ok' /tmp/pantry-cli.out || { echo "FAIL pantry.php did not finish"; FAILS=$((FAILS+1)); }

echo "== php errors"
if grep -qiE 'warning|notice|deprecated|fatal' $LOG; then echo "FAIL PHP messages:"; grep -iE 'warning|notice|deprecated|fatal' $LOG | head; FAILS=$((FAILS+1)); else echo "(none)"; fi
echo "== $FAILS failure(s)"
[ $FAILS -eq 0 ]
