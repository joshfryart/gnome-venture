#!/bin/bash
# v1.1.0: egg dishes (discovery, Almanac, cooking) and the cook_energy_percent 150 -> 115 upgrade step.
# Run on a fresh SQLite install that walk.sh made (player "sprout"): eggs110.sh GAME PORT ROUTER
GAME=$1; PORT=$2; ROUTER=$3; BASE=http://127.0.0.1:$PORT
php -d session.save_path=/tmp -S 127.0.0.1:$PORT -t $GAME $ROUTER >/tmp/eggs110-php.log 2>&1 & PID=$!; sleep 1
trap "kill $PID 2>/dev/null" EXIT
C=/tmp/eggs110-ck; rm -f $C
csrf() { grep -o 'name="csrf" value="[^"]*"' "$1" | head -1 | sed 's/.*value="\([^"]*\)".*/\1/'; }
db() { php -r '$p=new PDO("sqlite:'$GAME'/data/game.sqlite"); foreach($p->query($argv[1])->fetchAll(PDO::FETCH_NUM) as $r) echo implode(" | ",$r),"\n";' "$1"; }
dbx() { php -r '$p=new PDO("sqlite:'$GAME'/data/game.sqlite"); $p->exec($argv[1]);' "$1"; }
page() { curl -s -c $C -b $C "$BASE/$1" > /tmp/eggs110.html; }
post() { local pg=$1 form=$2; shift 2; page "$form"; curl -s -c $C -b $C -X POST "$BASE/$pg" --data-urlencode "csrf=$(csrf /tmp/eggs110.html)" "$@" -o /dev/null; page "$form"; }
give() { dbx "INSERT OR REPLACE INTO user_items (user_id,item_id,qty) SELECT $UID_, id, $2 FROM items WHERE slug='$1'"; }
qty() { db "SELECT COALESCE((SELECT ui.qty FROM user_items ui JOIN items i ON i.id=ui.item_id WHERE ui.user_id=$UID_ AND i.slug='$1'),0)"; }
chk() { if [ "$2" = "$3" ]; then echo "ok   $1 = $2"; else echo "FAIL $1: got '$2' want '$3'"; fi; }
has() { if grep -q -- "$2" /tmp/eggs110.html; then echo "ok   $1"; else echo "FAIL $1 (missing '$2')"; fi; }
page login.php; curl -s -c $C -b $C -X POST $BASE/login.php --data-urlencode "csrf=$(csrf /tmp/eggs110.html)" -d username=sprout -d 'password=TestPass123!' -o /dev/null
UID_=$(db "SELECT id FROM users WHERE username='sprout'")
dbx "UPDATE users SET tour_step=0, energy=60, energy_updated_at=datetime('now') WHERE id=$UID_"
dbx "REPLACE INTO settings (name,value) VALUES ('kitchen_pots','0')"   # instant cooking
P=$(db "SELECT id FROM plots WHERE user_id=$UID_ LIMIT 1")
dbx "INSERT INTO garden_buildings (plot_id,building,built_at,last_collect) VALUES ($P,'kitchen',datetime('now'),datetime('now'))"

echo "== data"
chk "hen-egg item exists" "$(db "SELECT COUNT(*) FROM items WHERE slug='hen-egg'")" 1
chk "14 egg recipes (11 + the Pantry's Lemon Curd, Passion Fruit Curd and Salted Eggs)" "$(db "SELECT COUNT(*) FROM recipes WHERE ingredients LIKE '%hen-egg%'")" 14
chk "no egg dish priced at 0" "$(db "SELECT COUNT(*) FROM items i JOIN recipes r ON r.output_item_id=i.id WHERE r.ingredients LIKE '%hen-egg%' AND i.base_price<=0")" 0
chk "tiers snack/meal/feast/preserve" "$(db "SELECT group_concat(t||':'||n) FROM (SELECT tier t, COUNT(*) n FROM recipes WHERE ingredients LIKE '%hen-egg%' GROUP BY tier ORDER BY tier)")" "feast:1,meal:6,preserve:4,snack:3"
chk "egg Almanac page" "$(db "SELECT COUNT(*) FROM encyclopedia_entries WHERE unlock_key='item:hen-egg'")" 1
chk "recipe Almanac pages for eggs" "$(db "SELECT COUNT(*) FROM encyclopedia_entries WHERE unlock_key IN ('recipe:scrambled-eggs','recipe:spanish-tortilla','recipe:pickled-eggs','recipe:feast-egg-pie')")" 4
chk "cook_energy_percent default is 115" "$(php -r '$_SERVER["SCRIPT_NAME"]="/gnome.php"; require "'$GAME'/includes/bootstrap.php"; echo setting("cook_energy_percent");' 2>&1 | tail -1)" 115

echo "== discovery: not known without an egg"
give parsley 2; give wheat 4; give spinach 4
RS=$(db "SELECT id FROM recipes WHERE slug='scrambled-eggs'"); RP=$(db "SELECT id FROM recipes WHERE slug='spinach-quiche'")
page "inventory.php?tab=craft&c=cooking"
chk "scrambled eggs not yet known" "$(db "SELECT COUNT(*) FROM user_recipes WHERE user_id=$UID_ AND recipe_id=$RS")" 0

echo "== receiving an egg (as Biddy's trade does) discovers the dishes"
give hen-egg 5
php -r '$_SERVER["SCRIPT_NAME"]="/gnome.php"; require "'$GAME'/includes/bootstrap.php"; $id=(int)q_val("SELECT id FROM items WHERE slug=\"hen-egg\""); q("DELETE FROM user_items WHERE user_id='$UID_' AND item_id=?",[$id]); give_item('$UID_',$id,5);' >/dev/null 2>&1
chk "egg page unlocked by receiving" "$(db "SELECT COUNT(*) FROM user_encyclopedia ue JOIN encyclopedia_entries e ON e.id=ue.entry_id WHERE ue.user_id=$UID_ AND e.unlock_key='item:hen-egg'")" 1
page "inventory.php?tab=craft&c=cooking"
chk "scrambled eggs known" "$(db "SELECT COUNT(*) FROM user_recipes WHERE user_id=$UID_ AND recipe_id=$RS")" 1
has "kitchen lists Scrambled Eggs" "Scrambled Eggs"
has "kitchen lists Spinach Quiche (egg+wheat+spinach all collected)" "Spinach Quiche"
chk "quiche known" "$(db "SELECT COUNT(*) FROM user_recipes WHERE user_id=$UID_ AND recipe_id=$RP")" 1
chk "tortilla not known (no potato yet)" "$(db "SELECT COUNT(*) FROM user_recipes ur JOIN recipes r ON r.id=ur.recipe_id WHERE ur.user_id=$UID_ AND r.slug='spanish-tortilla'")" 0

echo "== cook one"
E0=$(db "SELECT energy FROM users WHERE id=$UID_"); S0=$(qty scrambled-eggs)
post crafting.php "inventory.php?tab=craft&c=cooking" -d recipe_id=$RS -d qty=1
chk "Scrambled Eggs +1" "$(qty scrambled-eggs)" $((S0+1))
chk "2 eggs + 1 parsley used" "$(qty hen-egg) $(qty parsley)" "3 1"
post crafting.php "inventory.php?tab=craft&c=cooking" -d recipe_id=$RP -d qty=1
chk "Quiche made (meal)" "$(qty spinach-quiche)" 1
chk "eggs 3 -> 1" "$(qty hen-egg)" 1
echo "-- used-up eggs still count as found"
dbx "DELETE FROM user_items WHERE user_id=$UID_ AND item_id=(SELECT id FROM items WHERE slug='hen-egg')"
give potato 3; give onion 1; give hen-egg 0; dbx "DELETE FROM user_items WHERE user_id=$UID_ AND item_id=(SELECT id FROM items WHERE slug='hen-egg')"
page "inventory.php?tab=craft&c=cooking"
chk "tortilla discovered with no egg in the satchel" "$(db "SELECT COUNT(*) FROM user_recipes ur JOIN recipes r ON r.id=ur.recipe_id WHERE ur.user_id=$UID_ AND r.slug='spanish-tortilla'")" 1
echo "-- eating it: energy x115%"
dbx "UPDATE users SET energy=0, energy_updated_at=datetime('now') WHERE id=$UID_"
post inventory.php inventory.php -d do=eat -d item_id=$(db "SELECT id FROM items WHERE slug='scrambled-eggs'")
chk "scrambled eggs energy = round(7 x 1.15) = 8" "$(db "SELECT energy FROM users WHERE id=$UID_")" 8

echo "== the Almanac shows the recipe page after cooking"
chk "recipe page unlocked" "$(db "SELECT COUNT(*) FROM user_encyclopedia ue JOIN encyclopedia_entries e ON e.id=ue.entry_id WHERE ue.user_id=$UID_ AND e.unlock_key='recipe:scrambled-eggs'")" 1

echo "== upgrade step: cook_energy_percent 150 -> 115, other values left alone, safe twice"
UP() { php -r '$_SERVER["SCRIPT_NAME"]="/gnome.php"; require "'$GAME'/includes/bootstrap.php"; require_once "'$GAME'/includes/upgrade110.php"; echo implode(",", upgrade_110_run());' 2>&1 | tail -1; }
dbx "DELETE FROM settings WHERE name LIKE 'upg110_%'"; dbx "REPLACE INTO settings (name,value) VALUES ('cook_energy_percent','150')"
UP >/dev/null; chk "150 became 115" "$(db "SELECT value FROM settings WHERE name='cook_energy_percent'")" 115
dbx "DELETE FROM settings WHERE name LIKE 'upg110_%'"; dbx "REPLACE INTO settings (name,value) VALUES ('cook_energy_percent','200')"
chk "run reports every step" "$(UP)" "cook,eggs,hybrids,orders"   # v1.1.0: + hybrids, orders
chk "200 untouched" "$(db "SELECT value FROM settings WHERE name='cook_energy_percent'")" 200
chk "flags set" "$(db "SELECT COUNT(*) FROM settings WHERE name IN ('upg110_cook','upg110_eggs') AND value='1'")" 2
dbx "REPLACE INTO settings (name,value) VALUES ('cook_energy_percent','150')"; UP >/dev/null
chk "flag stops a second change (runs once)" "$(db "SELECT value FROM settings WHERE name='cook_energy_percent'")" 150
dbx "DELETE FROM settings WHERE name LIKE 'upg110_%'"; UP >/dev/null; UP >/dev/null
chk "twice more: no duplicate recipes" "$(db "SELECT COUNT(*) FROM recipes WHERE slug IN ('scrambled-eggs','pancakes','pickled-eggs')")" 3
chk "no duplicate egg page" "$(db "SELECT COUNT(*) FROM encyclopedia_entries WHERE unlock_key='item:hen-egg'")" 1
dbx "DELETE FROM settings WHERE name='kitchen_pots'"
echo "php log errors: $(grep -ciE 'fatal|warning|notice|deprecated' /tmp/eggs110-php.log)  error-log: $(cat $GAME/data/error-log.txt 2>/dev/null | wc -l)"
