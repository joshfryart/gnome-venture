#!/bin/bash
# v1.4.0: Butterfly Bush and Snail Jar (build, welcome/collect, flower +1 stem, snail rescue via pest pick, gifts, crafts, upgrade).
# Run on a fresh SQLite install that walk.sh made (player "sprout", admin "admin"): animals140.sh GAME PORT ROUTER
GAME=$1; PORT=$2; ROUTER=$3; BASE=http://127.0.0.1:$PORT
php -d session.save_path=/tmp -d display_errors=1 -S 127.0.0.1:$PORT -t $GAME $ROUTER >/tmp/animals140-php.log 2>&1 & PID=$!; sleep 1
trap "kill $PID 2>/dev/null" EXIT
C=/tmp/animals140-ck; rm -f $C; CA=/tmp/animals140-ck-admin; rm -f $CA
H=/tmp/animals140.html
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
PHPB() { php -r '$_SERVER["SCRIPT_NAME"]="/gnome.php"; require "'$GAME'/includes/bootstrap.php"; require_once "'$GAME'/includes/gardens.php"; require_once "'$GAME'/includes/yard.php"; require_once "'$GAME'/includes/garden_logic.php"; require_once "'$GAME'/includes/animals140.php"; '"$1" 2>&1 | tail -3; }
page login.php; curl -s -c $C -b $C -X POST $BASE/login.php --data-urlencode "csrf=$(csrf $H)" -d username=sprout -d 'password=TestPass123!' -o /dev/null
UID_=$(db "SELECT id FROM users WHERE username='sprout'")
dbx "UPDATE users SET tour_step=0, coins=1000000, level=30, energy=60, energy_updated_at=datetime('now') WHERE id=$UID_"
P=$(db "SELECT id FROM plots WHERE user_id=$UID_ LIMIT 1")
dbx "UPDATE plots SET garden_level=12 WHERE id=$P"

echo "== upgrade step (bootstrap is not wired yet: run it once)"
php -r '$_SERVER["SCRIPT_NAME"]="/gnome.php"; require "'$GAME'/includes/bootstrap.php"; require_once "'$GAME'/includes/upgrade140.php"; echo implode(",", upgrade_140_run()), "\n";'
chk "flag set" "$(db "SELECT value FROM settings WHERE name='upg140_animals'")" 1

echo "== data (fresh install)"
chk "2 new critter kinds" "$(db "SELECT group_concat(slug) FROM (SELECT slug FROM critter_kinds WHERE slug IN ('butterfly','snail') ORDER BY slug)")" "butterfly,snail"
chk "4 new items" "$(db "SELECT COUNT(*) FROM items WHERE slug IN ('wing-scale','snail-trail-glaze','wing-scale-lantern','glazed-garden-pot') AND base_price>0")" 4
chk "2 crafts" "$(db "SELECT COUNT(*) FROM recipes WHERE slug IN ('wing-scale-lantern','glazed-garden-pot')")" 2
chk "4 Almanac pages" "$(db "SELECT COUNT(*) FROM encyclopedia_entries WHERE unlock_key IN ('critter:butterfly_bush','critter:snail_jar','item:wing-scale','item:snail-trail-glaze')")" 4
chk "item images" "$(db "SELECT COUNT(*) FROM items WHERE slug IN ('wing-scale','snail-trail-glaze') AND image IS NOT NULL")" 2
for s in butterfly snail butterfly_bush snail_jar item-wing-scale item-snail-trail-glaze; do [ -f $GAME/assets/img/animals/$s.svg ] || echo "FAIL missing svg $s"; done
chk "Snail Jar level 3, Butterfly Bush level 4" "$(PHPB 'echo BUILDINGS["snail_jar"][2], BUILDINGS["butterfly_bush"][2];')" 34

echo "== admin: building select, settings"
curl -s -c $CA -b $CA $BASE/login.php > $H; curl -s -c $CA -b $CA -X POST $BASE/login.php --data-urlencode "csrf=$(csrf $H)" -d username=admin -d password=TestPassword123 -o /dev/null
curl -s -c $CA -b $CA "$BASE/admin/crud.php?r=critter_kinds&action=new" > $H
has "admin select lists Butterfly Bush" "butterfly_bush"; has "...Snail Jar" "snail_jar"
curl -s -c $CA -b $CA "$BASE/admin/settings.php" > $H
for k in animals140_on butterfly_stem_pct snail_rescue_pct; do has "setting $k" "$k"; done

echo "== build both homes"
dbx "UPDATE users SET coins=1000000 WHERE id=$UID_"
dbx "UPDATE plots SET garden_level=2 WHERE id=$P"
post garden.php garden.php -d do=build -d building=snail_jar
chk "snail_jar needs garden level 3" "$(db "SELECT COUNT(*) FROM garden_buildings WHERE plot_id=$P AND building='snail_jar'")" 0
dbx "UPDATE plots SET garden_level=3 WHERE id=$P"
post garden.php garden.php -d do=build -d building=butterfly_bush
chk "butterfly_bush needs garden level 4" "$(db "SELECT COUNT(*) FROM garden_buildings WHERE plot_id=$P AND building='butterfly_bush'")" 0
dbx "UPDATE plots SET garden_level=12 WHERE id=$P"
dbx "REPLACE INTO settings (name,value) VALUES ('animals140_on','0')"
post garden.php garden.php -d do=build -d building=snail_jar
chk "blocked while animals140_on=0" "$(db "SELECT COUNT(*) FROM garden_buildings WHERE plot_id=$P AND building='snail_jar'")" 0
dbx "REPLACE INTO settings (name,value) VALUES ('animals140_on','1')"
COINS0=$(db "SELECT coins FROM users WHERE id=$UID_")
for b in snail_jar butterfly_bush; do
  post garden.php garden.php -d do=build -d building=$b
  chk "$b built" "$(db "SELECT COUNT(*) FROM garden_buildings WHERE plot_id=$P AND building='$b'")" 1
done
chk "cost 300 + 1100" "$((COINS0 - $(db "SELECT coins FROM users WHERE id=$UID_")))" 1400
chk "building Almanac pages opened" "$(db "SELECT COUNT(*) FROM user_encyclopedia ue JOIN encyclopedia_entries e ON e.id=ue.entry_id WHERE ue.user_id=$UID_ AND e.unlock_key IN ('critter:butterfly_bush','critter:snail_jar')")" 2
page yard.php; has "yard page renders" "yard"
chk "both homes placed in the yard" "$(db "SELECT COUNT(*) FROM garden_objects WHERE plot_id=$P AND kind='building' AND ref IN ('butterfly_bush','snail_jar') AND x>=0")" 2

echo "== butterflies: welcome, no feeding, collect"
welcome() { post garden.php "garden.php?bld=$1" -d do=critter_welcome -d building=$1 -d "name=$2"; }
welcome butterfly_bush Flutter; welcome butterfly_bush Dapple; welcome butterfly_bush Third
chk "2 butterflies (level I holds 2)" "$(db "SELECT group_concat(name) FROM (SELECT name FROM garden_critters WHERE plot_id=$P AND kind='butterfly' ORDER BY id)")" "Flutter,Dapple"
page "garden.php?bld=butterfly_bush"; hasnot "no Feed button for butterflies" 'value="critter_feed"'; has "stem hint on the panel" "extra stem"
dbx "UPDATE garden_critters SET gift_at=datetime('now','-30 days') WHERE plot_id=$P"
page "garden.php?bld=butterfly_bush"
chk "wing scales waiting (cap 3 each, 30 days = 3)" "$(db "SELECT held FROM garden_critters WHERE plot_id=$P AND name='Flutter'")" 3
post garden.php "garden.php?bld=butterfly_bush" -d do=collect -d building=butterfly_bush
chk "6+ wing scales collected" "$([ $(qty wing-scale) -ge 6 ] && echo yes || echo "no:$(qty wing-scale)")" yes
chk "Wing Scale page opened by the gift" "$(db "SELECT COUNT(*) FROM user_encyclopedia ue JOIN encyclopedia_entries e ON e.id=ue.entry_id WHERE ue.user_id=$UID_ AND e.unlock_key='item:wing-scale'")" 1
post garden.php "garden.php?bld=butterfly_bush" -d do=critter_rename -d building=butterfly_bush -d critter=$(db "SELECT id FROM garden_critters WHERE name='Flutter'") -d name=Monarch
chk "rename" "$(db "SELECT COUNT(*) FROM garden_critters WHERE plot_id=$P AND name='Monarch'")" 1

echo "== butterfly bush: flowers within 2 squares"
FL=$(db "SELECT slug FROM plants WHERE kind='flower' AND produce_item_id IS NOT NULL ORDER BY id LIMIT 1")
dbx "REPLACE INTO settings (name,value) VALUES ('butterfly_stem_pct','100')"
T=$(db "SELECT x||'-'||y||'-'||COALESCE(yx,-1)||'-'||COALESCE(yy,-1) FROM plot_tiles WHERE plot_id=$P AND yx IS NOT NULL LIMIT 1")
TX=$(echo $T | cut -d- -f3); TY=$(echo $T | cut -d- -f4)
echo "tile yard pos $TX,$TY"
NEAR='$u=q_one("SELECT * FROM users WHERE id='$UID_'"); $t=q_one("SELECT * FROM plot_tiles WHERE plot_id='$P' AND yx='$TX' AND yy='$TY'"); $p=q_one("SELECT * FROM plants WHERE slug=\"'$FL'\""); $v=q_one("SELECT * FROM plants WHERE kind=\"vegetable\" AND produce_item_id IS NOT NULL LIMIT 1");'
dbx "UPDATE garden_objects SET x=$((TX+2)), y=$TY WHERE plot_id=$P AND kind='building' AND ref='butterfly_bush'"
chk "flower 2 squares away: +1 stem (chance 100)" "$(PHPB "$NEAR"'echo count(animals140_on_harvest($u,$t,$p));')" 1
chk "...chance 5 + 100 base capped" "$(PHPB "$NEAR"'echo animals140_stem_chance($t);')" 100
chk "a vegetable gets nothing" "$(PHPB "$NEAR"'echo count(animals140_on_harvest($u,$t,$v));')" 0
dbx "UPDATE garden_objects SET x=$((TX+5)), y=$TY WHERE plot_id=$P AND kind='building' AND ref='butterfly_bush'"
chk "flower 5 squares away: nothing" "$(PHPB "$NEAR"'echo animals140_stem_chance($t);')" 0
dbx "UPDATE garden_objects SET x=$((TX+1)), y=$TY WHERE plot_id=$P AND kind='building' AND ref='butterfly_bush'"
dbx "REPLACE INTO settings (name,value) VALUES ('butterfly_stem_pct','30')"
chk "level I chance = setting" "$(PHPB "$NEAR"'echo animals140_stem_chance($t);')" 30
dbx "UPDATE garden_buildings SET level=3 WHERE plot_id=$P AND building='butterfly_bush'"
chk "level III chance = setting + 10" "$(PHPB "$NEAR"'echo animals140_stem_chance($t);')" 40
dbx "UPDATE garden_buildings SET level=1 WHERE plot_id=$P AND building='butterfly_bush'"
dbx "REPLACE INTO settings (name,value) VALUES ('butterfly_stem_pct','100')"
echo "-- real do_harvest"
PLID=$(db "SELECT id FROM plants WHERE slug='$FL'")
dbx "UPDATE plot_tiles SET tilled=1, method='till', plant_id=$PLID, planted_at=datetime('now','-30 days'), growth_seconds=99999999, growth_updated_at=datetime('now'), pest=NULL WHERE plot_id=$P AND yx=$TX AND yy=$TY"
chk "do_harvest message mentions the butterfly" "$(PHPB "$NEAR"'$t=q_one("SELECT * FROM plot_tiles WHERE plot_id='$P' AND yx='$TX' AND yy='$TY'"); $m=do_harvest($u,$t,$p); echo count(array_filter($m, fn($x)=>str_contains($x,"+1 stem")));')" 1
echo "-- no residents, no bonus"
dbx "UPDATE garden_critters SET building='x_off' WHERE plot_id=$P AND building='butterfly_bush'"
chk "empty bush: nothing" "$(PHPB "$NEAR"'echo animals140_stem_chance($t);')" 0
dbx "UPDATE garden_critters SET building='butterfly_bush' WHERE plot_id=$P AND building='x_off'"
dbx "REPLACE INTO settings (name,value) VALUES ('animals140_on','0')"
chk "animals140_on=0: nothing" "$(PHPB "$NEAR"'echo animals140_stem_chance($t);')" 0
dbx "REPLACE INTO settings (name,value) VALUES ('animals140_on','1')"

echo "== snail rescue via pest pick (chance forced to 100)"
dbx "REPLACE INTO settings (name,value) VALUES ('snail_rescue_pct','100')"
VEG=$(db "SELECT id FROM plants WHERE kind='vegetable' ORDER BY id LIMIT 1")
infest() { dbx "UPDATE plot_tiles SET tilled=1, method='till', plant_id=$VEG, planted_at=datetime('now'), growth_seconds=0, growth_updated_at=datetime('now'), pest='$2', pest_at=datetime('now') WHERE plot_id=$P AND x=$1 AND y=0"; }
pick() { post garden.php garden.php -d do=pick -d x=$1 -d y=0; }
snails() { db "SELECT COUNT(*) FROM garden_critters WHERE plot_id=$P AND building='snail_jar'"; }
page garden.php
infest 0 aphids; pick 0
chk "picking aphids never rescues a snail" "$(snails)" 0
chk "...the pest was still picked" "$(db "SELECT COUNT(*) FROM plot_tiles WHERE plot_id=$P AND x=0 AND y=0 AND pest IS NOT NULL")" 0
infest 0 slugs; pick 0
chk "picking slugs rescues a snail" "$(snails)" 1
has "rescue message" "moves into the Snail Jar"
chk "snail has a name from the list" "$(db "SELECT COUNT(*) FROM garden_critters WHERE plot_id=$P AND kind='snail' AND name IN ('Gary','Turbo','Shelby','Pebble','Dewdrop','Mossy')")" 1
infest 1 slugs; pick 1; infest 2 slugs; pick 2
chk "3 snails (the most)" "$(snails)" 3
infest 3 slugs; pick 3
chk "a 4th is not taken" "$(snails)" 3
has "full jar message" "Snail Jar is full"
chk "...pest still picked" "$(db "SELECT COUNT(*) FROM plot_tiles WHERE plot_id=$P AND x=3 AND y=0 AND pest IS NOT NULL")" 0
chk "unique default names" "$(db "SELECT COUNT(DISTINCT name) FROM garden_critters WHERE plot_id=$P AND kind='snail'")" 3
echo "-- no jar / chance 0 / switched off: no rescue"
dbx "DELETE FROM garden_critters WHERE plot_id=$P AND kind='snail' AND id <> (SELECT MIN(id) FROM garden_critters WHERE plot_id=$P AND kind='snail')"
dbx "REPLACE INTO settings (name,value) VALUES ('snail_rescue_pct','0')"; infest 4 slugs; pick 4
chk "chance 0" "$(snails)" 1
dbx "REPLACE INTO settings (name,value) VALUES ('snail_rescue_pct','100')"; dbx "REPLACE INTO settings (name,value) VALUES ('animals140_on','0')"; infest 4 slugs; pick 4
chk "animals140_on=0" "$(snails)" 1
dbx "REPLACE INTO settings (name,value) VALUES ('animals140_on','1')"
echo "-- pick all"
for x in 1 2; do infest $x slugs; done; page garden.php
post garden.php garden.php -d do=pick_all
chk "pick_all can rescue too (2 slugs -> 3 snails)" "$(snails)" 3
echo "-- snails cannot be bought"
dbx "DELETE FROM garden_critters WHERE plot_id=$P AND kind='snail' AND id <> (SELECT MIN(id) FROM garden_critters WHERE plot_id=$P AND kind='snail')"
welcome snail_jar Bought
chk "welcome refused for the snail jar" "$(snails)" 1
page "garden.php?bld=snail_jar"; hasnot "no welcome form on the jar" 'value="critter_welcome"'; has "rescue hint on the jar" "Pick slugs and snails"
echo "-- without a jar built"
dbx "DELETE FROM garden_buildings WHERE plot_id=$P AND building='snail_jar'"; dbx "DELETE FROM garden_critters WHERE plot_id=$P AND kind='snail'"
infest 4 slugs; pick 4
chk "no jar: no rescue" "$(snails)" 0
dbx "INSERT INTO garden_buildings (plot_id,building,built_at,last_collect) VALUES ($P,'snail_jar',datetime('now'),datetime('now'))"
infest 4 slugs; pick 4; infest 0 slugs; pick 0
dbx "UPDATE garden_critters SET name='Shelby' WHERE id=(SELECT MIN(id) FROM garden_critters WHERE plot_id=$P AND kind='snail')"
dbx "DELETE FROM garden_critters WHERE plot_id=$P AND kind='snail' AND name <> 'Shelby'"

echo "== snails: feed, tick, collect"
page "garden.php?bld=snail_jar"; has "feed button" "Feed"
give food-scrap 10; give lettuce 0
post garden.php "garden.php?bld=snail_jar" -d do=critter_feed -d building=snail_jar
chk "snail ate scraps (cap 6)" "$(db "SELECT meals FROM garden_critters WHERE plot_id=$P AND kind='snail'")" 6
chk "scraps used" "$(qty food-scrap)" 4
dbx "UPDATE garden_critters SET gift_at=datetime('now','-30 days') WHERE plot_id=$P AND kind='snail'"
page "garden.php?bld=snail_jar"
chk "glaze waiting (6 meals / 2 = 3, cap 3)" "$(db "SELECT held FROM garden_critters WHERE plot_id=$P AND kind='snail'")" 3
post garden.php "garden.php?bld=snail_jar" -d do=collect -d building=snail_jar
chk "glaze collected" "$([ $(qty snail-trail-glaze) -ge 3 ] && echo yes || echo no)" yes
chk "nothing held after" "$(db "SELECT SUM(held) FROM garden_critters WHERE plot_id=$P AND kind='snail'")" 0
echo "-- eats lettuce too"
dbx "DELETE FROM user_items WHERE user_id=$UID_ AND item_id=(SELECT id FROM items WHERE slug='food-scrap')"; give lettuce 4; dbx "UPDATE garden_critters SET meals=0 WHERE plot_id=$P AND kind='snail'"
post garden.php "garden.php?bld=snail_jar" -d do=critter_feed -d building=snail_jar
chk "lettuce eaten" "$(db "SELECT meals FROM garden_critters WHERE plot_id=$P AND kind='snail'")" 4
echo "-- csrf"
curl -s -c $C -b $C -X POST "$BASE/garden.php" -d do=critter_feed -d building=snail_jar -o /dev/null
chk "no token: feeder unchanged" "$(db "SELECT meals FROM garden_critters WHERE plot_id=$P AND kind='snail'")" 4

echo "== crafts"
give wing-scale 3; give silk-thread 1; give snail-trail-glaze 2; give river-clay 2
RL=$(db "SELECT id FROM recipes WHERE slug='wing-scale-lantern'"); RG=$(db "SELECT id FROM recipes WHERE slug='glazed-garden-pot'")
page "inventory.php?tab=craft&c=decor"
chk "lantern discovered" "$(db "SELECT COUNT(*) FROM user_recipes WHERE user_id=$UID_ AND recipe_id=$RL")" 1
chk "pot discovered" "$(db "SELECT COUNT(*) FROM user_recipes WHERE user_id=$UID_ AND recipe_id=$RG")" 1
post crafting.php "inventory.php?tab=craft&c=decor" -d recipe_id=$RL -d qty=1
chk "Wing Scale Lantern made, scales + thread used" "$(qty wing-scale-lantern) $(qty wing-scale) $(qty silk-thread)" "1 0 0"
post crafting.php "inventory.php?tab=craft&c=decor" -d recipe_id=$RG -d qty=1
chk "Glazed Garden Pot made, glaze + clay used" "$(qty glazed-garden-pot) $(qty snail-trail-glaze) $(qty river-clay)" "1 0 0"
chk "lantern is placeable decor (light)" "$(PHPB '$i=q_one("SELECT * FROM items WHERE slug=\"wing-scale-lantern\""); $d=decor_def($i); echo $d ? $d["type"].$d["appeal"] : "no";')" light4
chk "pot is placeable decor" "$(PHPB '$i=q_one("SELECT * FROM items WHERE slug=\"glazed-garden-pot\""); $d=decor_def($i); echo $d ? $d["appeal"] : "no";')" 4

echo "== upgrade is idempotent and restores a missing world"
CNT() { db "SELECT (SELECT COUNT(*) FROM critter_kinds WHERE slug IN ('butterfly','snail'))||'/'||(SELECT COUNT(*) FROM items WHERE slug IN ('wing-scale','snail-trail-glaze','wing-scale-lantern','glazed-garden-pot'))||'/'||(SELECT COUNT(*) FROM recipes WHERE slug IN ('wing-scale-lantern','glazed-garden-pot'))||'/'||(SELECT COUNT(*) FROM encyclopedia_entries WHERE unlock_key IN ('critter:butterfly_bush','critter:snail_jar','item:wing-scale','item:snail-trail-glaze'))"; }
PHPB 'animals140_upgrade(); animals140_upgrade();' >/dev/null
chk "twice: nothing duplicated" "$(CNT)" "2/4/2/4"
dbx "DELETE FROM critter_kinds WHERE slug IN ('butterfly','snail')"; dbx "DELETE FROM recipes WHERE slug IN ('wing-scale-lantern','glazed-garden-pot')"; dbx "DELETE FROM items WHERE slug IN ('wing-scale-lantern','glazed-garden-pot')"; dbx "DELETE FROM encyclopedia_entries WHERE unlock_key IN ('critter:snail_jar','item:wing-scale')"
dbx "DELETE FROM settings WHERE name='upg140_animals'"
php -r '$_SERVER["SCRIPT_NAME"]="/gnome.php"; require "'$GAME'/includes/bootstrap.php"; require_once "'$GAME'/includes/upgrade140.php"; upgrade_140_run(); upgrade_140_run();'
chk "restored through upgrade_140_run" "$(CNT)" "2/4/2/4"
chk "no duplicate recipes by slug" "$(db "SELECT COUNT(*) FROM (SELECT slug FROM recipes GROUP BY slug HAVING COUNT(*)>1)")" 0
page "garden.php?t=bld"; has "garden page still renders" "Tap a building for details"   # v1.4.0: buildings have their own tab
echo "php log errors: $(grep -ciE 'fatal|warning|notice|deprecated' /tmp/animals140-php.log)  error-log: $(cat $GAME/data/error-log.txt 2>/dev/null | wc -l)"
