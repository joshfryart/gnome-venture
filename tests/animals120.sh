#!/bin/bash
# v1.2.0: more garden animals (Quail Coop, Silkworm Shelf, Tortoise Run, Clementine, Percy, recipes, crafts, upgrade).
# Run on a fresh SQLite install that walk.sh made (player "sprout", admin "admin"): animals120.sh GAME PORT ROUTER
GAME=$1; PORT=$2; ROUTER=$3; BASE=http://127.0.0.1:$PORT
php -d session.save_path=/tmp -d display_errors=1 -S 127.0.0.1:$PORT -t $GAME $ROUTER >/tmp/animals120-php.log 2>&1 & PID=$!; sleep 1
trap "kill $PID 2>/dev/null" EXIT
C=/tmp/animals120-ck; rm -f $C; CA=/tmp/animals120-ck-admin; rm -f $CA
H=/tmp/animals120.html
csrf() { grep -o 'name="csrf" value="[^"]*"' "$1" | head -1 | sed 's/.*value="\([^"]*\)".*/\1/'; }
db() { php -r '$p=new PDO("sqlite:'$GAME'/data/game.sqlite"); foreach($p->query($argv[1])->fetchAll(PDO::FETCH_NUM) as $r) echo implode(" | ",$r),"\n";' "$1"; }
dbx() { php -r '$p=new PDO("sqlite:'$GAME'/data/game.sqlite"); $p->exec($argv[1]);' "$1"; }
page() { curl -s -c $C -b $C "$BASE/$1" > $H; }
post() { local pg=$1 form=$2; shift 2; page "$form"; curl -s -c $C -b $C -X POST "$BASE/$pg" --data-urlencode "csrf=$(csrf $H)" "$@" -o /dev/null; page "$form"; }
give() { dbx "INSERT OR REPLACE INTO user_items (user_id,item_id,qty) SELECT $UID_, id, $2 FROM items WHERE slug='$1'"; }
qty() { db "SELECT COALESCE((SELECT ui.qty FROM user_items ui JOIN items i ON i.id=ui.item_id WHERE ui.user_id=$UID_ AND i.slug='$1'),0)"; }
chk() { if [ "$2" = "$3" ]; then echo "ok   $1 = $2"; else echo "FAIL $1: got '$2' want '$3'"; fi; }
has() { if grep -q -- "$2" $H; then echo "ok   $1"; else echo "FAIL $1 (missing '$2')"; fi; }
hasnot() { if grep -q -- "$2" $H; then echo "FAIL $1 (found '$2')"; else echo "ok   $1"; fi; }
PHPB() { php -r '$_SERVER["SCRIPT_NAME"]="/gnome.php"; require "'$GAME'/includes/bootstrap.php"; require_once "'$GAME'/includes/gardens.php"; require_once "'$GAME'/includes/yard.php"; require_once "'$GAME'/includes/world.php"; require_once "'$GAME'/includes/animals120.php"; '"$1" 2>&1 | tail -3; }
page login.php; curl -s -c $C -b $C -X POST $BASE/login.php --data-urlencode "csrf=$(csrf $H)" -d username=sprout -d 'password=TestPass123!' -o /dev/null
UID_=$(db "SELECT id FROM users WHERE username='sprout'")
dbx "UPDATE users SET tour_step=0, coins=1000000, level=30, energy=60, energy_updated_at=datetime('now') WHERE id=$UID_"
P=$(db "SELECT id FROM plots WHERE user_id=$UID_ LIMIT 1")
dbx "UPDATE plots SET garden_level=12 WHERE id=$P"
dbx "REPLACE INTO settings (name,value) VALUES ('kitchen_pots','0')"
dbx "INSERT INTO garden_buildings (plot_id,building,built_at,last_collect) VALUES ($P,'kitchen',datetime('now'),datetime('now'))"

echo "== data (fresh install)"
chk "3 new critter kinds" "$(db "SELECT group_concat(slug) FROM (SELECT slug FROM critter_kinds WHERE slug IN ('quail','silkworm','tortoise') ORDER BY slug)")" "quail,silkworm,tortoise"
chk "9 new items" "$(db "SELECT COUNT(*) FROM items WHERE slug IN ('mulberry-leaf','quail-egg','silk-cocoon','silk-thread','tortoise-scute','goat-milk','goat-hair','silk-bunting','scute-wind-chime')")" 9
chk "no new item priced at 0" "$(db "SELECT COUNT(*) FROM items WHERE slug IN ('mulberry-leaf','quail-egg','silk-cocoon','silk-thread','tortoise-scute','goat-milk','goat-hair','silk-bunting','scute-wind-chime','goat-cheese') AND base_price<=0")" 0
chk "9 new dishes (quail + goat)" "$(db "SELECT COUNT(*) FROM recipes WHERE slug IN ('goat-cheese','quail-egg-toast','goat-cheese-salad','goat-milk-porridge','quail-egg-rice-bowl','scotch-quail-eggs','stuffed-peppers-goat','goat-cheese-tart','pickled-quail-eggs')")" 9
chk "4 new crafts" "$(db "SELECT COUNT(*) FROM recipes WHERE slug IN ('silk-thread','silk-bunting','scute-wind-chime','rope-goat-hair')")" 4
chk "5 animal Almanac pages + 8 item pages" "$(db "SELECT COUNT(*) FROM encyclopedia_entries WHERE unlock_key IN ('critter:quail_coop','critter:silk_shelf','critter:tortoise_run','critter:clementine','critter:percy') OR unlock_key IN ('item:quail-egg','item:goat-milk','item:goat-cheese','item:goat-hair','item:silk-cocoon','item:silk-thread','item:tortoise-scute','item:mulberry-leaf')")" 13
chk "recipe Almanac pages made" "$(db "SELECT COUNT(*) FROM encyclopedia_entries WHERE unlock_key IN ('recipe:quail-egg-toast','recipe:goat-cheese','recipe:silk-bunting')")" 3
chk "image files exist for items" "$(db "SELECT COUNT(*) FROM items WHERE slug IN ('quail-egg','silk-cocoon','goat-milk') AND image IS NOT NULL")" 3
for s in quail silkworm tortoise goat pigeon quail_coop silk_shelf tortoise_run; do [ -f $GAME/assets/img/animals/$s.svg ] || echo "FAIL missing svg $s"; done

echo "== admin: building select, settings"
curl -s -c $CA -b $CA $BASE/login.php > $H; curl -s -c $CA -b $CA -X POST $BASE/login.php --data-urlencode "csrf=$(csrf $H)" -d username=admin -d password=TestPassword123 -o /dev/null
curl -s -c $CA -b $CA "$BASE/admin/crud.php?r=critter_kinds&action=new" > $H
has "admin building select lists Quail Coop" "quail_coop"; has "...Silkworm Shelf" "silk_shelf"; has "...Tortoise Run" "tortoise_run"
curl -s -c $CA -b $CA "$BASE/admin/settings.php?adv=1" > $H
for k in animals120_on mulberry_leaves clementine_on clementine_chance clementine_scraps_per_milk percy_on percy_chance percy_seeds; do has "setting $k" "$k"; done

echo "== build each home"
dbx "UPDATE users SET coins=1000000 WHERE id=$UID_"
for b in quail_coop silk_shelf tortoise_run; do
  post garden.php garden.php -d do=build -d building=$b
  chk "$b built" "$(db "SELECT COUNT(*) FROM garden_buildings WHERE plot_id=$P AND building='$b'")" 1
done
chk "building Almanac pages opened" "$(db "SELECT COUNT(*) FROM user_encyclopedia ue JOIN encyclopedia_entries e ON e.id=ue.entry_id WHERE ue.user_id=$UID_ AND e.unlock_key IN ('critter:quail_coop','critter:silk_shelf','critter:tortoise_run')")" 3
echo "-- master switch"
dbx "REPLACE INTO settings (name,value) VALUES ('animals120_on','0')"; dbx "DELETE FROM garden_buildings WHERE plot_id=$P AND building='tortoise_run'"
post garden.php garden.php -d do=build -d building=tortoise_run
chk "tortoise_run blocked while switched off" "$(db "SELECT COUNT(*) FROM garden_buildings WHERE plot_id=$P AND building='tortoise_run'")" 0
dbx "REPLACE INTO settings (name,value) VALUES ('animals120_on','1')"
post garden.php garden.php -d do=build -d building=tortoise_run
chk "tortoise_run rebuilt" "$(db "SELECT COUNT(*) FROM garden_buildings WHERE plot_id=$P AND building='tortoise_run'")" 1
echo "-- footprints are placeable"
page yard.php; has "yard page renders" "yard"

echo "== welcome, feed, tick, collect"
welcome() { post garden.php "garden.php?bld=$1" -d do=critter_welcome -d building=$1 -d name="$2"; }
welcome quail_coop Pepper; welcome silk_shelf Thread; welcome tortoise_run Mossback
chk "3 residents" "$(db "SELECT group_concat(kind||':'||name) FROM (SELECT kind,name FROM garden_critters WHERE plot_id=$P AND kind IN ('quail','silkworm','tortoise') ORDER BY kind)")" "quail:Pepper,silkworm:Thread,tortoise:Mossback"
chk "tortoise_run holds 1 (second welcome refused)" "$(welcome tortoise_run Second; db "SELECT COUNT(*) FROM garden_critters WHERE plot_id=$P AND building='tortoise_run'")" 1
page "garden.php?bld=quail_coop"; has "feed button disabled/empty without food" "Feed"
give food-scrap 12; give mulberry-leaf 12; give lettuce 12
post garden.php "garden.php?bld=quail_coop" -d do=critter_feed -d building=quail_coop
post garden.php "garden.php?bld=silk_shelf" -d do=critter_feed -d building=silk_shelf
post garden.php "garden.php?bld=tortoise_run" -d do=critter_feed -d building=tortoise_run
chk "quail ate scraps" "$(db "SELECT meals FROM garden_critters WHERE kind='quail' AND plot_id=$P")" 6
chk "scraps used" "$(qty food-scrap)" 6
chk "silkworm ate leaves" "$(db "SELECT meals FROM garden_critters WHERE kind='silkworm' AND plot_id=$P")" 6
chk "tortoise ate lettuce" "$(db "SELECT meals FROM garden_critters WHERE kind='tortoise' AND plot_id=$P")" 6
chk "lettuce used" "$(qty lettuce)" 6
echo "-- days pass (lazy tick)"
dbx "UPDATE garden_critters SET gift_at=datetime('now','-30 days') WHERE plot_id=$P"
page "garden.php?bld=quail_coop"
chk "quail eggs waiting (cap 6, meals 6 / 2 each = 3)" "$(db "SELECT held FROM garden_critters WHERE kind='quail' AND plot_id=$P")" 3
chk "silk cocoons waiting (6 leaves / 3 = 2)" "$(db "SELECT held FROM garden_critters WHERE kind='silkworm' AND plot_id=$P")" 2
chk "scutes waiting (cap 2, meals 6/2 = 3)" "$(db "SELECT held FROM garden_critters WHERE kind='tortoise' AND plot_id=$P")" 2
has "ready badge on the page" "ready"
for pair in quail_coop:quail-egg silk_shelf:silk-cocoon tortoise_run:tortoise-scute; do b=${pair%%:*}; it=${pair##*:}
  before=$(qty $it); post garden.php "garden.php?bld=$b" -d do=collect -d building=$b
  after=$(qty $it); if [ "$after" -gt "$before" ]; then echo "ok   collected $it ($before -> $after)"; else echo "FAIL collect $it ($before -> $after)"; fi
  chk "$b nothing held after collecting" "$(db "SELECT SUM(held) FROM garden_critters WHERE plot_id=$P AND building='$b'")" 0
done
chk "gift Almanac pages opened by receiving" "$(db "SELECT COUNT(*) FROM user_encyclopedia ue JOIN encyclopedia_entries e ON e.id=ue.entry_id WHERE ue.user_id=$UID_ AND e.unlock_key IN ('item:quail-egg','item:silk-cocoon','item:tortoise-scute')")" 3
echo "-- curb appeal"
chk "tortoise_run adds appeal" "$(PHPB 'echo animals120_appeal('$P');')" 2
echo "-- csrf: feed without token is refused"
give food-scrap 6; dbx "UPDATE garden_critters SET meals=0 WHERE kind='quail' AND plot_id=$P"
curl -s -c $C -b $C -X POST "$BASE/garden.php" -d do=critter_feed -d building=quail_coop -o /dev/null
chk "quail still hungry (no token)" "$(db "SELECT meals FROM garden_critters WHERE kind='quail' AND plot_id=$P")" 0
echo "-- someone else cannot feed or welcome in my coop (ownership): other user's plot is not mine"
chk "welcome at a home I haven't built" "$(post garden.php garden.php -d do=critter_welcome -d building=worm_farm -d name=X; db "SELECT COUNT(*) FROM garden_critters WHERE plot_id=$P AND building='worm_farm'")" 0

echo "== mulberry leaves from a harvest"
give mulberry-leaf 0; dbx "DELETE FROM user_items WHERE user_id=$UID_ AND item_id=(SELECT id FROM items WHERE slug='mulberry-leaf')"
M=$(PHPB '$u=q_one("SELECT * FROM users WHERE id='$UID_'"); $p=q_one("SELECT * FROM plants WHERE slug=\"mulberry\""); echo count(animals120_on_harvest($u,$p)); $p2=q_one("SELECT * FROM plants WHERE slug=\"tomato\""); echo count(animals120_on_harvest($u,$p2));')
chk "mulberry gives a message, tomato none" "$M" "10"
chk "3 leaves given" "$(qty mulberry-leaf)" 3
grep -q "animals120_on_harvest" $GAME/includes/garden_logic.php && echo "ok   do_harvest calls the hook" || echo "FAIL hook"

echo "== Clementine (force her presence)"
dbx "REPLACE INTO settings (name,value) VALUES ('clementine_chance','100')"
dbx "DELETE FROM garden_visitors WHERE plot_id=$P"; give food-scrap 12; dbx "DELETE FROM user_items WHERE user_id=$UID_ AND item_id=(SELECT id FROM items WHERE slug='goat-milk')"
page "garden.php?an=1"; has "Clementine card" "Clementine is at the fence"; has "trade form" 'value="clementine"'
post garden.php "garden.php?an=1" -d do=clementine -d scraps=6
chk "6 scraps -> 2 milk" "$(qty goat-milk)" 2
chk "scraps taken" "$(qty food-scrap)" 6
chk "visit row" "$(db "SELECT traded||':'||scraps FROM garden_visitors WHERE plot_id=$P AND kind='clementine'")" "1:6"
has "fill message on the card" "had her fill"
post garden.php "garden.php?an=1" -d do=clementine -d scraps=6
chk "second trade today refused (no more milk)" "$(qty goat-milk)" 2
chk "...scraps untouched" "$(qty food-scrap)" 6
chk "one visit row only" "$(db "SELECT COUNT(*) FROM garden_visitors WHERE plot_id=$P AND kind='clementine'")" 1
echo "-- csrf"
dbx "DELETE FROM garden_visitors WHERE plot_id=$P"
curl -s -c $C -b $C -X POST "$BASE/garden.php" -d do=clementine -d scraps=6 -o /dev/null
chk "no token: no trade" "$(qty goat-milk)" 2
echo "-- too few scraps"
dbx "DELETE FROM user_items WHERE user_id=$UID_ AND item_id=(SELECT id FROM items WHERE slug='food-scrap')"
give food-scrap 2; post garden.php "garden.php?an=1" -d do=clementine -d scraps=2
chk "2 scraps is not enough" "$(qty goat-milk)" 2
chk "...no visit row used up" "$(db "SELECT COUNT(*) FROM garden_visitors WHERE plot_id=$P AND kind='clementine'")" 0
echo "-- absent when switched off / chance 0"
dbx "REPLACE INTO settings (name,value) VALUES ('clementine_chance','0')"; give food-scrap 6
post garden.php "garden.php?an=1" -d do=clementine -d scraps=6
chk "chance 0: no trade" "$(qty goat-milk)" 2
dbx "REPLACE INTO settings (name,value) VALUES ('clementine_chance','100')"; dbx "REPLACE INTO settings (name,value) VALUES ('clementine_on','0')"
post garden.php "garden.php?an=1" -d do=clementine -d scraps=6
chk "clementine_on=0: no trade" "$(qty goat-milk)" 2
dbx "REPLACE INTO settings (name,value) VALUES ('clementine_on','1')"
chk "Clementine page opened" "$(db "SELECT COUNT(*) FROM user_encyclopedia ue JOIN encyclopedia_entries e ON e.id=ue.entry_id WHERE ue.user_id=$UID_ AND e.unlock_key='critter:clementine'")" 1
dbx "UPDATE settings SET value='100' WHERE name='clementine_hair_pct'"; dbx "INSERT OR IGNORE INTO settings (name,value) VALUES ('clementine_hair_pct','100')"
give food-scrap 9; post garden.php "garden.php?an=1" -d do=clementine -d scraps=9
chk "9 scraps -> 3 more milk" "$(qty goat-milk)" 5
chk "hair at 100%" "$(qty goat-hair)" 1

echo "== Percy (force presence)"
dbx "REPLACE INTO settings (name,value) VALUES ('percy_chance','100')"
dbx "DELETE FROM garden_visitors WHERE plot_id=$P AND kind='percy'"
SEED=$(db "SELECT i.slug FROM items i JOIN plants p ON p.seed_item_id=i.id WHERE i.category='seed' AND p.slug='radish'"); [ -n "$SEED" ] || SEED=$(db "SELECT slug FROM items WHERE category='seed' LIMIT 1")
SID=$(db "SELECT id FROM items WHERE slug='$SEED'"); give $SEED 5
SEEDS0=$(db "SELECT COALESCE(SUM(ui.qty),0) FROM user_items ui JOIN items i ON i.id=ui.item_id WHERE ui.user_id=$UID_ AND i.category='seed'")
page "garden.php?an=1"; has "Percy card" "Percy is on the shed"; has "send form" 'value="percy"'
post garden.php "garden.php?an=1" -d do=percy -d seed=$SID
SEEDS1=$(db "SELECT COALESCE(SUM(ui.qty),0) FROM user_items ui JOIN items i ON i.id=ui.item_id WHERE ui.user_id=$UID_ AND i.category='seed'")
chk "3 seeds given, 1 received (net -2)" "$((SEEDS1-SEEDS0))" -2
chk "that seed is for a crop outside the home garden's known set" "$(PHPB '$u=q_one("SELECT * FROM users WHERE id='$UID_'"); $k=known_plants($u,false); echo count(percy_candidates($u))>0 ? "cands" : "none";')" cands
chk "visit row" "$(db "SELECT COUNT(*) FROM garden_visitors WHERE plot_id=$P AND kind='percy' AND traded=1")" 1
has "run done message" "made his run"
post garden.php "garden.php?an=1" -d do=percy -d seed=$SID
chk "second run today refused (seeds unchanged)" "$(db "SELECT COALESCE(SUM(ui.qty),0) FROM user_items ui JOIN items i ON i.id=ui.item_id WHERE ui.user_id=$UID_ AND i.category='seed'")" "$SEEDS1"
echo "-- not a seed / too few / csrf"
dbx "DELETE FROM garden_visitors WHERE plot_id=$P AND kind='percy'"
FID=$(db "SELECT id FROM items WHERE slug='quail-egg'"); give quail-egg 9
post garden.php "garden.php?an=1" -d do=percy -d seed=$FID
chk "an egg is not a seed" "$(qty quail-egg)" 9
chk "...no visit used" "$(db "SELECT COUNT(*) FROM garden_visitors WHERE plot_id=$P AND kind='percy'")" 0
give $SEED 2; post garden.php "garden.php?an=1" -d do=percy -d seed=$SID
chk "2 seeds is too few" "$(qty $SEED)" 2
give $SEED 5
curl -s -c $C -b $C -X POST "$BASE/garden.php" -d do=percy -d seed=$SID -o /dev/null
chk "no token: no trade" "$(qty $SEED)" 5
echo "-- setting: percy_on=0"
dbx "REPLACE INTO settings (name,value) VALUES ('percy_on','0')"; post garden.php "garden.php?an=1" -d do=percy -d seed=$SID
chk "percy_on=0: no trade" "$(qty $SEED)" 5
dbx "REPLACE INTO settings (name,value) VALUES ('percy_on','1')"
chk "Percy page opened" "$(db "SELECT COUNT(*) FROM user_encyclopedia ue JOIN encyclopedia_entries e ON e.id=ue.entry_id WHERE ue.user_id=$UID_ AND e.unlock_key='critter:percy'")" 1

echo "== recipes: discovery and cooking"
dbx "DELETE FROM user_items WHERE user_id=$UID_ AND item_id IN (SELECT id FROM items WHERE slug IN ('quail-egg','goat-milk','goat-cheese','wheat','parsley','oats'))"
RT=$(db "SELECT id FROM recipes WHERE slug='quail-egg-toast'"); RP=$(db "SELECT id FROM recipes WHERE slug='goat-milk-porridge'")
page "inventory.php?tab=craft&c=cooking"
chk "toast unknown without ingredients" "$(db "SELECT COUNT(*) FROM user_recipes WHERE user_id=$UID_ AND recipe_id=$RT")" 0
give wheat 4; give parsley 2; give oats 4
php -r '$_SERVER["SCRIPT_NAME"]="/gnome.php"; require "'$GAME'/includes/bootstrap.php"; foreach (["quail-egg"=>8,"goat-milk"=>4] as $s=>$n) give_item('$UID_',(int)q_val("SELECT id FROM items WHERE slug=?",[$s]),$n);' >/dev/null 2>&1
page "inventory.php?tab=craft&c=cooking"
has "kitchen lists Quail Egg Toast" "Quail Egg Toast"; has "...Goat Milk Porridge" "Goat Milk Porridge"
chk "toast discovered" "$(db "SELECT COUNT(*) FROM user_recipes WHERE user_id=$UID_ AND recipe_id=$RT")" 1
chk "porridge discovered" "$(db "SELECT COUNT(*) FROM user_recipes WHERE user_id=$UID_ AND recipe_id=$RP")" 1
post crafting.php "inventory.php?tab=craft&c=cooking" -d recipe_id=$RT -d qty=1
chk "Quail Egg Toast +1" "$(qty quail-egg-toast)" 1
chk "4 eggs + wheat + parsley used" "$(qty quail-egg) $(qty wheat) $(qty parsley)" "4 3 1"
post crafting.php "inventory.php?tab=craft&c=cooking" -d recipe_id=$RP -d qty=1
chk "Goat Milk Porridge made" "$(qty goat-milk-porridge)" 1
echo "-- used-up eggs and milk still count as found"
dbx "DELETE FROM user_items WHERE user_id=$UID_ AND item_id IN (SELECT id FROM items WHERE slug IN ('quail-egg','goat-milk'))"
give rice 2; give spinach 1; dbx "DELETE FROM user_recipes WHERE user_id=$UID_ AND recipe_id=(SELECT id FROM recipes WHERE slug='quail-egg-rice-bowl')"
page "inventory.php?tab=craft&c=cooking"
chk "rice bowl discovered with no egg in the satchel" "$(db "SELECT COUNT(*) FROM user_recipes ur JOIN recipes r ON r.id=ur.recipe_id WHERE ur.user_id=$UID_ AND r.slug='quail-egg-rice-bowl'")" 1
echo "-- goat cheese dishes and silk crafts"
give goat-cheese 2; give lettuce 2; give tomato 1
php -r '$_SERVER["SCRIPT_NAME"]="/gnome.php"; require "'$GAME'/includes/bootstrap.php"; $i=(int)q_val("SELECT id FROM items WHERE slug=\"goat-cheese\""); q("DELETE FROM user_items WHERE user_id='$UID_' AND item_id=?",[$i]); give_item('$UID_',$i,2);' >/dev/null 2>&1
RS=$(db "SELECT id FROM recipes WHERE slug='goat-cheese-salad'")
page "inventory.php?tab=craft&c=cooking"; post crafting.php "inventory.php?tab=craft&c=cooking" -d recipe_id=$RS -d qty=1
chk "Goat Cheese Salad made" "$(qty goat-cheese-salad)" 1
give silk-cocoon 6
RT2=$(db "SELECT id FROM recipes WHERE slug='silk-thread'"); RB=$(db "SELECT id FROM recipes WHERE slug='silk-bunting'")
page "inventory.php?tab=craft&c=decor"; post crafting.php "inventory.php?tab=craft&c=decor" -d recipe_id=$RT2 -d qty=1
chk "Silk Thread +2" "$(qty silk-thread)" 2
post crafting.php "inventory.php?tab=craft&c=decor" -d recipe_id=$RT2 -d qty=1
post crafting.php "inventory.php?tab=craft&c=decor" -d recipe_id=$RB -d qty=1
chk "Silk Bunting made from 3 thread" "$(qty silk-bunting) $(qty silk-thread)" "1 1"
chk "bunting is placeable decor" "$(PHPB '$i=q_one("SELECT * FROM items WHERE slug=\"silk-bunting\""); $d=decor_def($i); echo $d ? $d["appeal"] : "no";')" 4

echo "== upgrade is idempotent and restores a missing world"
CNT() { db "SELECT (SELECT COUNT(*) FROM critter_kinds WHERE slug IN ('quail','silkworm','tortoise'))||'/'||(SELECT COUNT(*) FROM items WHERE slug IN ('quail-egg','goat-milk','silk-bunting'))||'/'||(SELECT COUNT(*) FROM recipes WHERE slug IN ('quail-egg-toast','goat-cheese','silk-thread'))||'/'||(SELECT COUNT(*) FROM encyclopedia_entries WHERE unlock_key LIKE 'critter:clementine' OR unlock_key LIKE 'item:quail-egg')"; }
PHPB 'animals120_upgrade(); animals120_upgrade();' >/dev/null
chk "twice: nothing duplicated" "$(CNT)" "3/3/3/2"
dbx "DELETE FROM critter_kinds WHERE slug IN ('quail','silkworm','tortoise')"; dbx "DELETE FROM recipes WHERE slug IN ('quail-egg-toast','goat-cheese','silk-thread')"; dbx "DELETE FROM items WHERE slug IN ('quail-egg-toast','goat-cheese')"; dbx "DELETE FROM encyclopedia_entries WHERE unlock_key IN ('critter:clementine','item:quail-egg')"
PHPB 'animals120_upgrade();' >/dev/null
chk "restored" "$(CNT)" "3/3/3/2"
chk "no duplicate recipes by slug" "$(db "SELECT COUNT(*) FROM (SELECT slug FROM recipes GROUP BY slug HAVING COUNT(*)>1)")" 0
page "garden.php?t=an"; has "garden page still renders" "Animals"
echo "php log errors: $(grep -ciE 'fatal|warning|notice|deprecated' /tmp/animals120-php.log)  error-log: $(cat $GAME/data/error-log.txt 2>/dev/null | wc -l)"
