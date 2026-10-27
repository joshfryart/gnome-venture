#!/bin/bash
# v0.9.4 cooking part 1 + part 2 (pots, timers, Brewroot III): raw food energy, scraps, dish tiers and energy, shop food, compost heap outputs, tour-free actions, energy lines.
# Run on a fresh SQLite install that walk.sh made (player "sprout"): cook.sh GAME PORT ROUTER [OLDGAME]
# OLDGAME (optional) = a COPY of an older game dir (e.g. 0.9.3.1) that walk.sh installed: new code is laid over it and the upgrade is checked.
GAME=$1; PORT=$2; ROUTER=$3; OLD=${4:-}; BASE=http://127.0.0.1:$PORT
TD=$(mktemp -d)   # private scratch files, so suites running side by side do not clobber each other
php -d session.save_path=/tmp -S 127.0.0.1:$PORT -t $GAME $ROUTER >$TD/cook-php.log 2>&1 & PID=$!; sleep 1
trap "kill $PID 2>/dev/null; rm -rf $TD" EXIT
C=$TD/cook-ck; rm -f $C
csrf() { grep -o 'name="csrf" value="[^"]*"' "$1" | head -1 | sed 's/.*value="\([^"]*\)".*/\1/'; }
db() { php -r '$p=new PDO("sqlite:'$GAME'/data/game.sqlite"); foreach($p->query($argv[1])->fetchAll(PDO::FETCH_NUM) as $r) echo implode(" | ",$r),"\n";' "$1"; }
dbx() { php -r '$p=new PDO("sqlite:'$GAME'/data/game.sqlite"); $p->exec($argv[1]);' "$1"; }
page() { curl -s -c $C -b $C "$BASE/$1" > $TD/ck.html; }
post() { local pg=$1 form=$2; shift 2; page "$form"; curl -s -c $C -b $C -X POST "$BASE/$pg" --data-urlencode "csrf=$(csrf $TD/ck.html)" "$@" -o /dev/null; page "$form"; grep -oE '<li class="ml (ok|err)[^"]*">.*' $TD/ck.html | head -1 | sed 's/<\/li>.*//; s/<li class="ml //; s/^\([a-z]*\)[^>]*">/\1 /; s/<[^>]*>//g'; }   # messages now start with an <img> icon, so strip the tags
eat() { post inventory.php inventory.php -d do=eat -d item_id=$(db "SELECT id FROM items WHERE slug='$1'"); }
give() { dbx "INSERT OR REPLACE INTO user_items (user_id,item_id,qty) SELECT $UID_, id, $2 FROM items WHERE slug='$1'"; }
qty() { db "SELECT COALESCE((SELECT ui.qty FROM user_items ui JOIN items i ON i.id=ui.item_id WHERE ui.user_id=$UID_ AND i.slug='$1'),0)"; }
energy() { db "SELECT energy FROM users WHERE id=$UID_"; }
setE() { dbx "UPDATE users SET energy=$1, energy_updated_at=datetime('now') WHERE id=$UID_"; }
chk() { if [ "$2" = "$3" ]; then echo "ok   $1 = $2"; else echo "FAIL $1: got '$2' want '$3'"; fi; }
page login.php; curl -s -c $C -b $C -X POST $BASE/login.php --data-urlencode "csrf=$(csrf $TD/ck.html)" -d username=sprout -d 'password=TestPass123!' -o /dev/null
UID_=$(db "SELECT id FROM users WHERE username='sprout'")
dbx "INSERT OR REPLACE INTO settings (name, value) VALUES ('xp_action_scale_percent', '0')"   # v0.9.7: action XP grows with level; these checks are about the base numbers (roads097.php covers the scaling)
dbx "UPDATE users SET tour_step=0 WHERE id=$UID_"
P=$(db "SELECT id FROM plots WHERE user_id=$UID_ LIMIT 1")

echo "== data: tiers, raw energy, scrap item"
db "SELECT tier||' cook_min='||cook_minutes||' batch='||batch_max||' cookE='||energy||' x'||COUNT(*) FROM recipes WHERE category='cooking' GROUP BY tier"
chk "raw energy 1 (everyday)" "$(db "SELECT json_extract(effects,'\$.energy') FROM items WHERE slug='apple'")" 1
chk "raw energy 2 (filling)" "$(db "SELECT json_extract(effects,'\$.energy') FROM items WHERE slug='sweet-potato'")" 2
chk "herb has no raw energy" "$(db "SELECT COALESCE(json_extract(effects,'\$.energy'),'none') FROM items WHERE slug='basil'")" none
chk "heavy scrap pumpkin" "$(db "SELECT json_extract(effects,'\$.scrap') FROM items WHERE slug='pumpkin'")" 3
chk "food-scrap not tradable" "$(db "SELECT category||' '||tradable FROM items WHERE slug='food-scrap'")" "supply 0"
chk "pickled radishes radish 2" "$(db "SELECT json_extract(ingredients,'\$.radish') FROM recipes WHERE slug='pickled-radishes'")" 2
chk "dish energy (soup)" "$(db "SELECT json_extract(effects,'\$.energy') FROM items WHERE slug='garden-vegetable-soup'")" 11
chk "shop soup 25% of 11 = 3" "$(db "SELECT json_extract(effects,'\$.energy') FROM items WHERE slug='bought-garden-vegetable-soup'")" 3
chk "flowers still no energy" "$(db "SELECT COUNT(*) FROM items WHERE category='flower' AND effects LIKE '%energy%'")" 0
chk "job_event takes ctx" "$(grep -c 'function job_event(int \$uid, string \$kind, string \$target, int \$n, array \$ctx = \[\])' $GAME/includes/jobs.php)" 1

echo "== eating raw food"
setE 3; give apple 3; give pumpkin 1; give basil 1; dbx "DELETE FROM user_items WHERE item_id=(SELECT id FROM items WHERE slug='food-scrap') AND user_id=$UID_"
eat apple;   chk "apple: energy 3 -> 4" "$(energy)" 4; chk "apple: 1 scrap" "$(qty food-scrap)" 1
eat pumpkin; chk "pumpkin: +1 energy" "$(energy)" 5;   chk "pumpkin: 3 more scraps" "$(qty food-scrap)" 4
eat basil;   chk "basil: no energy" "$(energy)" 5
setE 10; eat apple; chk "apple at full energy: still eaten, no gain" "$(energy)" 10; chk "apple at full: scrap still left" "$(qty food-scrap)" 6

echo "== eating dishes (cook_energy_percent 150 for home-cooked only)"
give garden-vegetable-soup 3; give mint-tea 2; give bought-garden-vegetable-soup 1; give feast-harvest-pie 1
dbx "UPDATE users SET level=20 WHERE id=$UID_"   # a bigger energy bar, so nothing is capped
setE 0; eat garden-vegetable-soup; chk "soup 11 x 1.15 = 13 (12.65 rounded)" "$(energy)" 13   # v1.1.0: cook_energy_percent default 115
setE 0; eat mint-tea; chk "mint tea 4 x 1.15 = 5 (4.6 rounded)" "$(energy)" 5
setE 0; eat bought-garden-vegetable-soup; chk "shop-bought: 3, not scaled" "$(energy)" 3
dbx "REPLACE INTO settings (name,value) VALUES ('cook_energy_percent','100')"; php -r '1;'
setE 0; eat garden-vegetable-soup; chk "percent 100: soup = 11" "$(energy)" 11
dbx "DELETE FROM settings WHERE name='cook_energy_percent'"
chk "no scraps from dishes" "$(qty food-scrap)" 6

echo "== cooking energy by tier (snack 0, meal 1, feast 2)"
dbx "INSERT INTO garden_buildings (plot_id,building,built_at,last_collect) VALUES ($P,'kitchen',datetime('now'),datetime('now'))"
give chanterelle 2; give wheat 1; give pea 3; give onion 1
R1=$(db "SELECT id FROM recipes WHERE slug='mushroom-toast'"); R2=$(db "SELECT id FROM recipes WHERE slug='green-pea-soup'")
dbx "INSERT OR IGNORE INTO user_recipes (user_id,recipe_id,learned_at) VALUES ($UID_,$R1,datetime('now')),($UID_,$R2,datetime('now'))"
setE 6; post crafting.php "inventory.php?tab=craft&c=cooking" -d recipe_id=$R1 -d qty=1; chk "snack cost 0" "$(energy)" 6
post crafting.php "inventory.php?tab=craft&c=cooking" -d recipe_id=$R2 -d qty=1;       chk "meal cost 1" "$(energy)" 5

echo "== Food Scrap compost craft (no building)"
give food-scrap 11; RS=$(db "SELECT id FROM recipes WHERE slug='food-scrap-compost'"); C0=$(qty plain-compost)
dbx "INSERT OR IGNORE INTO user_recipes (user_id,recipe_id,learned_at) VALUES ($UID_,$RS,datetime('now'))"
post crafting.php "inventory.php?tab=craft&c=garden" -d recipe_id=$RS -d qty=1; chk "11 scraps are not enough" "$(qty plain-compost)" $C0
give food-scrap 12; post crafting.php "inventory.php?tab=craft&c=garden" -d recipe_id=$RS -d qty=1
chk "12 scraps -> 1 Plain Compost" "$(qty plain-compost)" $((C0+1)); chk "scraps used" "$(qty food-scrap)" 0

echo "== Compost Bin: add scraps, heap outputs"
dbx "INSERT INTO garden_buildings (plot_id,building,built_at,last_collect) VALUES ($P,'compost_bin',datetime('now'),datetime('now'))"
dbx "UPDATE garden_buildings SET last_collect=datetime('now') WHERE plot_id=$P"
GP="garden.php"
give food-scrap 5; post $GP $GP -d do=add_scraps; chk "5 scraps on the heap" "$(db "SELECT scraps FROM garden_buildings WHERE plot_id=$P AND building='compost_bin'")" 5; chk "satchel scraps used" "$(qty food-scrap)" 0
post $GP $GP -d do=add_scraps
give food-scrap 4; post $GP $GP -d do=add_scraps; chk "9 on heap (level 1 needs 8)" "$(db "SELECT scraps FROM garden_buildings WHERE plot_id=$P AND building='compost_bin'")" 9
C0=$(qty plain-compost); post $GP $GP -d do=collect -d building=compost_bin
chk "collect: 1 Plain Compost from the heap" "$(qty plain-compost)" $((C0+1)); chk "1 scrap left" "$(db "SELECT scraps FROM garden_buildings WHERE plot_id=$P AND building='compost_bin'")" 1
post $GP $GP -d do=heap_out -d out=leaf-mould; chk "level 1 cannot make Leaf Mould" "$(db "SELECT heap_out FROM garden_buildings WHERE plot_id=$P AND building='compost_bin'")" plain-compost
dbx "UPDATE garden_buildings SET level=3 WHERE plot_id=$P AND building='compost_bin'"
dbx "UPDATE garden_buildings SET scraps=24 WHERE plot_id=$P AND building='compost_bin'"
C0=$(qty plain-compost); W0=$(qty worm-castings); post $GP $GP -d do=collect -d building=compost_bin
chk "level 3: 4 Plain Compost (6 scraps each), no 4th-compost castings" "$(qty plain-compost) $(qty worm-castings)" "$((C0+4)) $W0"
post $GP $GP -d do=heap_out -d out=rich-loam; chk "level 3 heap makes Rich Loam" "$(db "SELECT heap_out FROM garden_buildings WHERE plot_id=$P AND building='compost_bin'")" rich-loam
dbx "UPDATE garden_buildings SET scraps=80 WHERE plot_id=$P AND building='compost_bin'"
L0=$(qty rich-loam); post $GP $GP -d do=collect -d building=compost_bin; chk "80 scraps -> 2 Rich Loam (40 each)" "$(qty rich-loam)" $((L0+2))
post $GP $GP -d do=heap_out -d out=worm-castings; dbx "UPDATE garden_buildings SET scraps=20 WHERE plot_id=$P AND building='compost_bin'"
W0=$(qty worm-castings); post $GP $GP -d do=collect -d building=compost_bin; chk "20 scraps -> 1 Worm Castings" "$(qty worm-castings)" $((W0+1))
post $GP $GP -d do=heap_out -d out=nonsense; chk "bad output refused" "$(db "SELECT heap_out FROM garden_buildings WHERE plot_id=$P AND building='compost_bin'")" worm-castings
page $GP; echo "bin panel: add-scraps hint present: $(grep -c 'Eat a raw crop to get Food Scraps' $TD/ck.html)  chooser options: $(grep -o '<option value="[a-z-]*"[^>]*>[A-Za-z ]* ([0-9]* scraps)' $TD/ck.html | wc -l)"

echo "== too-tired text and energy lines"
dbx "UPDATE plot_tiles SET plant_id=NULL WHERE plot_id=$P"; setE 0
page "garden.php?sel=3-3"; curl -s -c $C -b $C -X POST $BASE/garden.php --data-urlencode "csrf=$(csrf $TD/ck.html)" -d do=till -d x=3 -d y=3 -o /dev/null; page garden.php
echo "message: $(grep -oE '<li class="ml err[^"]*">[^<]*' $TD/ck.html | head -1 | cut -c1-200)"
echo "strip low-energy line: $(grep -c 'class="st lowenergy"' $TD/ck.html)  strip countdown: $(grep -oE 'Next \+1 in [0-9]+:[0-9]+' $TD/ck.html | head -1)"
setE 10; page garden.php; echo "full energy: low line $(grep -c 'class="st lowenergy"' $TD/ck.html), countdown $(grep -c 'Next +1 in' $TD/ck.html)"

echo "== tour step 5 is eat; tour-free actions"
dbx "UPDATE users SET tour_step=5 WHERE id=$UID_"; setE 10; give apple 1
page inventory.php; echo "tour box: $(grep -oE '<h3>Wren’s tour[^<]*' $TD/ck.html)"
eat apple; chk "tour moved on after eating" "$(db "SELECT tour_step FROM users WHERE id=$UID_")" 6
dbx "UPDATE users SET tour_step=1 WHERE id=$UID_"; setE 0
page "garden.php?sel=2-2"; curl -s -c $C -b $C -X POST $BASE/garden.php --data-urlencode "csrf=$(csrf $TD/ck.html)" -d do=till -d x=2 -d y=2 -o /dev/null
chk "tour till with 0 energy works" "$(db "SELECT tour_step FROM users WHERE id=$UID_")" 2
dbx "UPDATE users SET tour_step=0 WHERE id=$UID_"

echo "== v0.9.4 part 2: pots and timers (kitchen_pots 2,3,4)"
has() { case "$2" in *"$1"*) echo "ok   $3";; *) echo "FAIL $3: got '$2'";; esac; }
stock() { for s in $(db "SELECT key FROM recipes, json_each(recipes.ingredients) WHERE recipes.slug='$1'"); do give $s ${2:-60}; done; }
KL() { dbx "UPDATE garden_buildings SET level=$1 WHERE plot_id=$P AND building='kitchen'"; }
potsn() { db "SELECT COUNT(*) FROM cook_pots WHERE user_id=$UID_ AND collected_at IS NULL"; }
CP="inventory.php?tab=craft&c=cooking"
cookit() { post crafting.php $CP -d recipe_id=$(db "SELECT id FROM recipes WHERE slug='$1'") -d qty=$2; }
readyall() { dbx "UPDATE cook_pots SET ready_at=datetime('now','-1 minute') WHERE collected_at IS NULL"; }
collectall() { readyall; post crafting.php $CP -d do=collect_all; }
dbx "DELETE FROM cook_pots"; dbx "INSERT OR IGNORE INTO user_recipes (user_id,recipe_id,learned_at) SELECT $UID_, id, datetime('now') FROM recipes WHERE category='cooking'"
for r in green-pea-soup feast-harvest-pie; do stock $r; done; stock mint-tea 400; give bought-garden-vegetable-soup 2
dbx "UPDATE users SET level=20, coins=1000, calling=NULL, calling_chapter=NULL, calling_qt=0 WHERE id=$UID_"; KL 1; setE 60
# a Job Board cook job and the Brewroot Journeyman chapter (task: cook 10 meals) to watch the cook event
JK=$(TZ=America/Halifax date +%F)   # v1.4.0: days turn over at Hollow midnight (1.2.2)
dbx "INSERT INTO user_jobs (user_id,period,period_key,kind,title,text,qty,progress,status,taken_at) VALUES ($UID_,'daily','$JK','cook','Cook','Cook 5 meals',5,0,'active',datetime('now'))"
CH=$(db "SELECT id FROM calling_chapters WHERE slug='brewroot-1'")
dbx "UPDATE users SET calling='brewroot', calling_chapter=$CH WHERE id=$UID_"
dbx "INSERT OR IGNORE INTO user_calling_tasks (user_id,task_id,progress) SELECT $UID_, id, 0 FROM calling_tasks WHERE chapter_id=$CH"
jobp() { db "SELECT progress FROM user_jobs WHERE user_id=$UID_ AND kind='cook'"; }
callp() { db "SELECT ut.progress FROM user_calling_tasks ut JOIN calling_tasks t ON t.id=ut.task_id WHERE ut.user_id=$UID_ AND t.chapter_id=$CH AND t.kind='cook' AND t.spec='tier=meal/feast' ORDER BY t.sort_order LIMIT 1"; }
SOUP=green-pea-soup

echo "-- start: Kitchen I has 2 pots"
S0=$(qty $SOUP); m=$(cookit $SOUP 5)
has "Cooking 2 × Green Pea Soup in 2 pots" "$m" "meal x5 clamps to the 2 free pots"
chk "2 pots busy" "$(potsn)" 2; chk "energy 60 -> 58 (meal costs 1 each)" "$(energy)" 58; chk "no soup yet" "$(qty $SOUP)" $S0
chk "ingredients taken" "$(qty pea)" 54
m=$(cookit $SOUP 1); has "All your pots are busy" "$m" "third start refused"; chk "still 2 pots" "$(potsn)" 2; chk "energy unchanged" "$(energy)" 58
echo "-- timer"
m=$(post crafting.php $CP -d do=collect_all); has "No pot is ready yet" "$m" "collect all: nothing ready"
P1=$(db "SELECT id FROM cook_pots WHERE collected_at IS NULL ORDER BY id LIMIT 1")
m=$(post crafting.php $CP -d do=collect -d pot_id=$P1); has "ready yet" "$m" "single collect before time refused"; chk "pot still there" "$(potsn)" 2
page "$CP"; echo "pots strip: $(grep -c 'class="potstrip"' $TD/ck.html) strip, $(grep -c 'data-potleft' $TD/ck.html) timers, hidden Collect forms: $(grep -c 'class="potcollect" hidden' $TD/ck.html)"
dbx "UPDATE cook_pots SET ready_at=datetime('now','-1 minute') WHERE id=$P1"
page "garden.php?t=bld"; has "> 1 ready</a>" "$(grep -o '> [0-9]* ready</a>' $TD/ck.html | head -1)" "status badge: 1 ready"   # the 🍳 is now an <img> icon
echo "-- collect one"
X0=$(db "SELECT xp FROM users WHERE id=$UID_"); F0=$(qty food-scrap)
m=$(post crafting.php $CP -d do=collect -d pot_id=$P1)
has "Collected 1 × Green Pea Soup (+5 XP" "$m" "collect: dish and XP 5 (meal)"
chk "soup +1" "$(qty $SOUP)" $((S0+1)); chk "1 pot left" "$(potsn)" 1; chk "pea+pea+pea+onion = 4 items -> 1 scrap" "$(qty food-scrap)" $((F0+1))
chk "last_cooked set" "$(db "SELECT i.slug FROM users u JOIN items i ON i.id=u.last_cooked_id WHERE u.id=$UID_")" $SOUP
chk "job board cook job +1" "$(jobp)" 1; chk "calling task 'cook 10 meals' +1" "$(callp)" 1
m=$(post crafting.php $CP -d do=collect -d pot_id=$P1); has "already empty" "$m" "collecting twice refused"; chk "soup still +1" "$(qty $SOUP)" $((S0+1))
m=$(collectall); has "Collected 1 × Green Pea Soup" "$m" "collect all takes the other"
chk "soup +2" "$(qty $SOUP)" $((S0+2)); chk "pots empty" "$(potsn)" 0; chk "job +2" "$(jobp)" 2; chk "calling task +2" "$(callp)" 2
chk "recipe made count" "$(db "SELECT made FROM user_recipes ur JOIN recipes r ON r.id=ur.recipe_id WHERE ur.user_id=$UID_ AND r.slug='$SOUP'")" 2
echo "-- snack batch: one pot, up to 5 makes, no energy; snacks do not count as meals"
M0=$(qty mint-tea); setE 40; m=$(cookit mint-tea 7)
has "Cooking 7 × Mint Tea in 2 pots" "$m" "snack x7 = pots of 5 + 2"
chk "makes 5,2" "$(db "SELECT group_concat(makes) FROM (SELECT makes FROM cook_pots WHERE collected_at IS NULL ORDER BY id)")" 5,2; chk "snacks cost 0" "$(energy)" 40
m=$(cookit mint-tea 1); has "All your pots are busy" "$m" "both pots hold the batch"
m=$(collectall); has "Collected 7 × Mint Tea (+2 XP" "$m" "snack XP 1 per pot"
chk "mint tea +7" "$(qty mint-tea)" $((M0+7)); chk "job still 2 (snack is not a meal)" "$(jobp)" 2; chk "calling task still 2" "$(callp)" 2
m=$(cookit mint-tea 3); chk "snack x3 = one pot of 3" "$(db "SELECT makes FROM cook_pots WHERE collected_at IS NULL")" 3; collectall >/dev/null
echo "-- Kitchen level sets the pot count"
KL 2; setE 60; cookit $SOUP 9 >/dev/null; chk "Kitchen II: 3 pots" "$(potsn)" 3; collectall >/dev/null
KL 3; setE 60; cookit $SOUP 9 >/dev/null; chk "Kitchen III: 4 pots" "$(potsn)" 4
collectall >/dev/null
echo "-- feast: Petals fee"
C0=$(db "SELECT coins FROM users WHERE id=$UID_"); setE 10; m=$(cookit feast-harvest-pie 1)
has "Cooking 1 × Harvest Home Pie" "$m" "feast started"; chk "feast fee 50 Petals" "$(db "SELECT coins FROM users WHERE id=$UID_")" $((C0-50)); chk "feast energy 2" "$(energy)" 8
chk "feast pot takes 45 min" "$(db "SELECT CAST((julianday(ready_at)-julianday(started_at))*86400+0.5 AS INTEGER) FROM cook_pots WHERE collected_at IS NULL")" 2700
dbx "UPDATE users SET coins=30 WHERE id=$UID_"; m=$(cookit feast-harvest-pie 1); has "firewood" "$m" "feast with 30 Petals refused"; chk "nothing taken" "$(db "SELECT coins FROM users WHERE id=$UID_")" 30; chk "one pot" "$(potsn)" 1
collectall >/dev/null; has "+23 XP" "$(grep -o '+23 XP' $TD/ck.html | head -1)" "feast XP 15 x1.5 = 23 (Kitchen III)"
dbx "UPDATE users SET coins=1000 WHERE id=$UID_"
echo "-- ingredients, energy and money are all-or-nothing"
dbx "DELETE FROM user_items WHERE user_id=$UID_ AND item_id=(SELECT id FROM items WHERE slug='onion')"; setE 60
m=$(cookit $SOUP 1); has "missing" "$m" "no onion: refused"; chk "no pot" "$(potsn)" 0; chk "energy untouched" "$(energy)" 60
give onion 60; setE 0; m=$(cookit $SOUP 1); has "too tired" "$m" "no energy: refused"; chk "no pot" "$(potsn)" 0
echo "-- who sees what"
setE 60; cookit $SOUP 1 >/dev/null
PEEK=$(php -r '$_SERVER["SCRIPT_NAME"]="/gnome.php"; require "'$GAME'/includes/bootstrap.php"; require_once "'$GAME'/includes/gardens.php"; $r=building_peek(q_one("SELECT * FROM plots WHERE id='$P'"),"kitchen"); echo $r ? implode(" ", (array)$r[1]) : "none";' 2>&1)
has "bubbling away: Green Pea Soup" "$PEEK" "kitchen peek says what is cooking"
echo "bad csrf collect: $(curl -s -b $C -X POST "$BASE/crafting.php" -d csrf=x -d do=collect_all -o /dev/null -w '%{http_code}')"; collectall >/dev/null
echo "-- Brewroot III: half time, +1 pot, +20% energy, extra dish stored per pot"
dbx "UPDATE users SET level=30, calling='brewroot', calling_chapter=NULL, calling_qt=2 WHERE id=$UID_"; setE 100
m=$(cookit $SOUP 9); chk "Kitchen III + Brewroot III: 5 pots" "$(potsn)" 5
chk "meal takes 7.5 min (half of 15)" "$(db "SELECT DISTINCT CAST((julianday(ready_at)-julianday(started_at))*86400+0.5 AS INTEGER) FROM cook_pots WHERE collected_at IS NULL")" 450
chk "each pot: 1 dish, or 2 on the 40% roll" "$(db "SELECT COUNT(*) FROM cook_pots WHERE collected_at IS NULL AND dishes NOT IN (1,2)")" 0
chk "Brewroot no longer cooks free (5 meals = 5 energy)" "$(energy)" 95
collectall >/dev/null
hits=0; bad=0; for i in 1 2 3 4 5 6 7 8 9 10 11 12; do cookit mint-tea 5 >/dev/null; d=$(db "SELECT dishes FROM cook_pots WHERE collected_at IS NULL"); [ "$d" = 10 ] && hits=$((hits+1)); [ "$d" != 5 ] && [ "$d" != 10 ] && bad=$((bad+1)); collectall >/dev/null; done
chk "snack batch pot: 5 dishes, or 10 on a hit (never anything else)" "$bad" 0; echo "extra-dish hits in 12 batches: $hits (40% each)"; [ $hits -ge 1 ] && echo "ok   at least one hit" || echo "WARN no hit in 12 (0.2% chance)"
setE 0; eat garden-vegetable-soup; chk "Brewroot III soup: 11 x1.15 = 13, +20% = 3 -> 16" "$(energy)" 16
setE 0; eat mint-tea; chk "mint tea 5 + max(1, 1) = 6 (v1.1.0)" "$(energy)"  6
setE 0; eat bought-garden-vegetable-soup; chk "shop-bought: no bonus" "$(energy)" 3
dbx "UPDATE users SET level=20, calling='brewroot', calling_qt=0 WHERE id=$UID_"
echo "-- hand-ins and Job Board count Meal and Feast only"
SUP=$(php -r '$_SERVER["SCRIPT_NAME"]="/gnome.php"; require "'$GAME'/includes/bootstrap.php"; require_once "'$GAME'/includes/rebuild.php"; $s=rebuild_supply('$UID_', ["meal","",1]); echo implode(",", array_map(fn($x)=>$x["name"],$s));' 2>&1)
case "$SUP" in *"Mint Tea"*) echo "FAIL rebuild_supply counts snacks: $SUP";; *"Green Pea Soup"*|*"Vegetable Soup"*) echo "ok   rebuild_supply meal: dishes without snacks ($SUP)";; *) echo "?? $SUP";; esac
echo "-- kitchen_pots = 0: instant cooking"
dbx "REPLACE INTO settings (name,value) VALUES ('kitchen_pots','0')"; dbx "UPDATE user_jobs SET qty=50, status='active' WHERE user_id=$UID_ AND kind='cook'"; page garden.php; setE 60; J0=$(jobp); S0=$(qty $SOUP); M0=$(qty mint-tea)
m=$(cookit $SOUP 2); has "Made 2 × Green Pea Soup" "$m" "instant: made at once"
chk "soup +2 at once" "$(qty $SOUP)" $((S0+2)); chk "no pot left waiting" "$(potsn)" 0; chk "energy -2" "$(energy)" 58; chk "job +2" "$(jobp)" $((J0+2))
m=$(cookit mint-tea 7); chk "instant snack x7" "$(qty mint-tea)" $((M0+7)); chk "instant: still no pots waiting" "$(potsn)" 0
page "$CP"; chk "no pots strip when pots are off" "$(grep -c 'class="potstrip"' $TD/ck.html)" 0
dbx "DELETE FROM settings WHERE name='kitchen_pots'"
dbx "UPDATE users SET calling=NULL, calling_chapter=NULL WHERE id=$UID_"
dbx "UPDATE user_jobs SET status='done' WHERE user_id=$UID_ AND kind='cook'"

echo "== v0.9.5 leftovers: Almanac pages, recipe editor, route highlight"
phpq() { php -r 'chdir("'$GAME'"); $_SERVER["HTTP_HOST"]="x"; require "includes/bootstrap.php"; require_once "includes/adventure.php"; '"$1"; }
chk "Pots page locked by 'pots'" "$(db "SELECT unlock_key FROM encyclopedia_entries WHERE title='Pots'")" pots
chk "Food Scraps page locked by the item" "$(db "SELECT unlock_key FROM encyclopedia_entries WHERE title='Food Scraps'")" item:food-scrap
chk "sprout collected pots: Pots page unlocked" "$(db "SELECT COUNT(*) FROM user_encyclopedia ue JOIN encyclopedia_entries e ON e.id=ue.entry_id WHERE e.title='Pots' AND ue.user_id=$UID_")" 1
chk "sprout got scraps: Food Scraps page unlocked" "$(db "SELECT COUNT(*) FROM user_encyclopedia ue JOIN encyclopedia_entries e ON e.id=ue.entry_id WHERE e.title='Food Scraps' AND ue.user_id=$UID_")" 1
dbx "DELETE FROM user_encyclopedia WHERE user_id=$UID_ AND entry_id IN (SELECT id FROM encyclopedia_entries WHERE title IN ('Pots','Food Scraps'))"
chk "pages gone after reset" "$(db "SELECT COUNT(*) FROM user_encyclopedia ue JOIN encyclopedia_entries e ON e.id=ue.entry_id WHERE e.title IN ('Pots','Food Scraps') AND ue.user_id=$UID_")" 0
phpq 'require_once "includes/jobs.php"; job_event('$UID_', "cook", "mint-tea", 1, ["tier" => "snack"]);'
chk "first pot collected opens Pots only" "$(db "SELECT group_concat(e.title) FROM user_encyclopedia ue JOIN encyclopedia_entries e ON e.id=ue.entry_id WHERE e.title IN ('Pots','Food Scraps') AND ue.user_id=$UID_")" Pots
dbx "DELETE FROM user_items WHERE user_id=$UID_ AND item_id=(SELECT id FROM items WHERE slug='food-scrap')"
phpq 'give_item('$UID_', (int)q_val("SELECT id FROM items WHERE slug = \"food-scrap\""), 1);'
chk "first scrap opens Food Scraps" "$(db "SELECT group_concat(e.title) FROM user_encyclopedia ue JOIN encyclopedia_entries e ON e.id=ue.entry_id WHERE e.title IN ('Pots','Food Scraps') AND ue.user_id=$UID_" | tr ',' '\n' | sort | tr '\n' ',')" "Food Scraps,Pots,"
page book.php; chk "Almanac lists both pages" "$(grep -c 'Food Scraps\|>Pots' $TD/ck.html | awk '{print ($1>0)?"yes":"no"}')" yes
# admin recipe editor
AD=$TD/ck-adm; rm -f $AD; curl -s -c $AD -b $AD $BASE/login.php > $TD/ck.html; curl -s -c $AD -b $AD -X POST $BASE/login.php --data-urlencode "csrf=$(csrf $TD/ck.html)" -d username=admin -d password=TestPassword123 -o /dev/null
RID=$(db "SELECT id FROM recipes WHERE slug='mint-tea'")
curl -s -b $AD "$BASE/admin/crud.php?r=recipes&action=edit&id=$RID" > $TD/ck-ed.html
chk "editor has tier/cook minutes/batch" "$(grep -o 'name="f\[\(tier\|cook_minutes\|batch_max\)\]"' $TD/ck-ed.html | sort -u | wc -l | tr -d ' ')" 3
chk "editor: no 'Not used yet', no skill_required" "$(grep -ci 'not used yet\|skill_required' $TD/ck-ed.html)" 0
chk "editor: snack option present" "$(grep -c 'value="snack"' $TD/ck-ed.html | awk '{print ($1>0)?"yes":"no"}')" yes
# route highlight and passed stops
phpq '$u = q_one("SELECT * FROM users WHERE id = '$UID_'"); $here = player_node($u); $rid = (int)$here["region_id"]; require_once "includes/destination.php";
  $town = (int)q_val("SELECT id FROM locations WHERE region_id = ? AND kind = \"market\" ORDER BY id LIMIT 1", [$rid]);
  $far = $town;
  if ($town === (int)$here["id"] || dest_path('$UID_', (int)$here["id"], $town) === null) { $far = 0; foreach (q("SELECT id FROM locations WHERE region_id = ? AND id <> ? ORDER BY id", [$rid, $here["id"]])->fetchAll(PDO::FETCH_COLUMN) as $c) if (dest_path('$UID_', (int)$here["id"], (int)$c) !== null) { $far = (int)$c; } }
  $near = (int)q_val("SELECT id FROM locations WHERE region_id = ? AND id NOT IN (?, ?) ORDER BY id LIMIT 1", [$rid, $here["id"], $far]);
  echo $here["id"], " ", $rid, " ", $far, " ", $near, "\n";' > $TD/ck-route.txt
read HERE REG FAR NEAR < $TD/ck-route.txt
dbx "UPDATE users SET dest_id=NULL, dest_trail=NULL WHERE id=$UID_"
page "world.php?tab=map&r=$REG"; chk "map: no highlight without a route" "$(grep -cE 'class="(mroute|mrouteing|gps|onroute)"' $TD/ck.html | awk '{print ($1>0)?"lit":"none"}')" none
dbx "UPDATE users SET dest_id=$FAR WHERE id=$UID_"
page "world.php?tab=map&r=$REG"; chk "map: route lit (path + ringed stops)" "$(grep -oE 'class="(mroute|gps)"' $TD/ck.html | wc -l | awk '{print ($1>0)?"lit":"none"}')" lit
chk "map: ringed stops" "$(grep -oE 'class="(mrouteing|onroute)"' $TD/ck.html | wc -l | awk '{print ($1>0)?"yes":"no"}')" yes
page world.php; chk "panel: nothing passed yet" "$(grep -c 'class="rp done"' $TD/ck.html)" 0
dbx "UPDATE users SET dest_trail='$NEAR'"
page world.php; echo "  panel with a passed stop: done rows $(grep -o 'class="rp done"' $TD/ck.html | wc -l) · ticks $(grep -o '✅' $TD/ck.html | wc -l)"
dbx "UPDATE users SET dest_id=NULL, dest_trail=NULL WHERE id=$UID_"

if [ -n "$OLD" ]; then
  echo "== upgrade from an older install ($OLD)"
  kill $PID 2>/dev/null; sleep 1
  OLDDB=$OLD/data/game.sqlite
  odb() { php -r '$p=new PDO("sqlite:'$OLDDB'"); foreach($p->query($argv[1])->fetchAll(PDO::FETCH_NUM) as $r) echo implode(" | ",$r),"\n";' "$1"; }
  odbx() { php -r '$p=new PDO("sqlite:'$OLDDB'"); $p->exec($argv[1]);' "$1"; }
  # admin edits that must survive: one dish energy, one raw item energy
  odbx "UPDATE items SET effects=json_set(effects,'\$.energy',9) WHERE slug='berry-tart'"
  echo "old soup energy: $(odb "SELECT json_extract(effects,'\$.energy') FROM items WHERE slug='garden-vegetable-soup'"), old apple: $(odb "SELECT COALESCE(json_extract(effects,'\$.energy'),'none') FROM items WHERE slug='apple'")"
  rsync -a --exclude data --exclude uploads $GAME/ $OLD/ 2>/dev/null || cp -r $GAME/includes $GAME/*.php $GAME/assets $OLD/
  sed -i "s/define('APP_VERSION', '[^']*')/define('APP_VERSION', '0.9.4')/" $OLD/includes/bootstrap.php
  php -d session.save_path=/tmp -S 127.0.0.1:$((PORT+1)) -t $OLD $ROUTER >$TD/cook-old.log 2>&1 & PID2=$!; sleep 1
  curl -s -o /dev/null -w 'first request: %{http_code}\n' http://127.0.0.1:$((PORT+1))/login.php
  kill $PID2 2>/dev/null
  echo "db_version: $(odb "SELECT value FROM settings WHERE name='db_version'")"
  chk "soup 4 -> 11" "$(odb "SELECT json_extract(effects,'\$.energy') FROM items WHERE slug='garden-vegetable-soup'")" 11
  chk "admin-edited berry tart (9) survives" "$(odb "SELECT json_extract(effects,'\$.energy') FROM items WHERE slug='berry-tart'")" 9
  chk "apple now 1" "$(odb "SELECT json_extract(effects,'\$.energy') FROM items WHERE slug='apple'")" 1
  chk "feast tier columns" "$(odb "SELECT tier||cook_minutes||'/'||energy FROM recipes WHERE slug='feast-harvest-pie'")" feast45/2
  chk "snack batch" "$(odb "SELECT tier||batch_max||'/'||energy FROM recipes WHERE slug='mint-tea'")" snack5/0
  chk "shop soup 3" "$(odb "SELECT json_extract(effects,'\$.energy') FROM items WHERE slug='bought-garden-vegetable-soup'")" 3
  chk "radish trim" "$(odb "SELECT json_extract(ingredients,'\$.radish') FROM recipes WHERE slug='pickled-radishes'")" 2
  chk "scrap compost craft added" "$(odb "SELECT COUNT(*) FROM recipes WHERE slug='food-scrap-compost'")" 1
  chk "bins keep heap_out default" "$(odb "SELECT COUNT(*) FROM pragma_table_info('garden_buildings') WHERE name='heap_out'")" 1
  echo "-- run the migration again (must change nothing)"
  odbx "DELETE FROM settings WHERE name='db_version'"
  php -d session.save_path=/tmp -S 127.0.0.1:$((PORT+1)) -t $OLD $ROUTER >>$TD/cook-old.log 2>&1 & PID2=$!; sleep 1
  curl -s -o /dev/null http://127.0.0.1:$((PORT+1))/login.php; kill $PID2 2>/dev/null
  chk "soup still 11" "$(odb "SELECT json_extract(effects,'\$.energy') FROM items WHERE slug='garden-vegetable-soup'")" 11
  chk "berry tart still 9" "$(odb "SELECT json_extract(effects,'\$.energy') FROM items WHERE slug='berry-tart'")" 9
  grep -iE 'fatal|warning|notice|deprecated' $TD/cook-old.log || echo "(no PHP errors on upgrade)"
fi
echo "== php errors"; grep -iE 'fatal|warning|notice|deprecated' $TD/cook-php.log || echo "(none)"
[ -s $GAME/data/error-log.txt ] && { echo "FAIL game error log:"; tail -8 $GAME/data/error-log.txt; } || echo "(game error log empty)"
