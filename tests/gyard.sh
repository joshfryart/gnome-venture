#!/bin/bash
# 2.7.33: the Garden Yard picture (garden.php?t=pic, includes/gyard.php, assets/gyard.css, assets/gardenyard.js).
# Run on a fresh SQLite install that walk.sh made (player "sprout"): gyard.sh GAME PORT ROUTER
GAME=$1; PORT=$2; ROUTER=$3; BASE=http://127.0.0.1:$PORT
php -d session.save_path=/tmp -d display_errors=1 -S 127.0.0.1:$PORT -t $GAME $ROUTER >/tmp/gyard-php.log 2>&1 & PID=$!; sleep 1
trap "kill $PID 2>/dev/null" EXIT
C=/tmp/gyard-ck; rm -f $C; H=/tmp/gyard.html
csrf() { grep -o 'name="csrf" value="[^"]*"' "$1" | head -1 | sed 's/.*value="\([^"]*\)".*/\1/'; }
db() { php -r '$p=new PDO("sqlite:'$GAME'/data/game.sqlite"); foreach($p->query($argv[1])->fetchAll(PDO::FETCH_NUM) as $r) echo implode(" | ",$r),"\n";' "$1"; }
dbx() { php -r '$p=new PDO("sqlite:'$GAME'/data/game.sqlite"); $p->exec($argv[1]);' "$1"; }
page() { curl -s -c $C -b $C "$BASE/$1" > $H; }
post() { local form=$1; shift; page "$form"; curl -s -c $C -b $C -X POST "$BASE/garden.php" --data-urlencode "csrf=$(csrf $H)" "$@" -o /dev/null -w '%{redirect_url}'; }
chk() { if [ "$2" = "$3" ]; then echo "ok   $1 = $2"; else echo "FAIL $1: got '$2' want '$3'"; fi; }
has() { if grep -q -- "$2" $H; then echo "ok   $1"; else echo "FAIL $1 (missing '$2')"; fi; }
hasnot() { if grep -q -- "$2" $H; then echo "FAIL $1 (found '$2')"; else echo "ok   $1"; fi; }
page login.php; curl -s -c $C -b $C -X POST $BASE/login.php --data-urlencode "csrf=$(csrf $H)" -d username=sprout -d 'password=TestPass123!' -o /dev/null
UID_=$(db "SELECT id FROM users WHERE username='sprout'")
dbx "UPDATE users SET tour_step=0, coins=1000000, level=30, energy=60, energy_updated_at=datetime('now') WHERE id=$UID_"
P=$(db "SELECT id FROM plots WHERE user_id=$UID_ LIMIT 1")
dbx "UPDATE plots SET garden_level=12 WHERE id=$P"
dbx "INSERT OR REPLACE INTO settings (name,value) VALUES ('upgrade_materials_2',''),('upgrade_materials_3','')"   # upgrades cost Petals only here

echo "== flag off: no Yard tab, ?t=pic falls back to the beds"
dbx "INSERT OR REPLACE INTO settings (name,value) VALUES ('gnav_on','1'),('gnav_garden','0')"
page "garden.php?t=pic"; hasnot "no Yard tab" 'href="[^"]*garden.php?t=pic"'; hasnot "no picture" 'id="gyard"'
echo "== flag on"
dbx "INSERT OR REPLACE INTO settings (name,value) VALUES ('gnav_garden','1')"
page "garden.php"; has "Yard tab" 'href="[^"]*garden.php?t=pic"'
page "garden.php?t=pic"
has "picture" 'id="gyard"'; has "ground" 'img/gyard/ground.png'; has "script" 'assets/gardenyard.js'
has "kitchen plot is for sale (empty art)" 'gy-h-kitchen-e'; has "its card has a Build button" 'value="build"'
has "the Buildings tab stays as the list version" 'List version'
hasnot "nothing is ready yet" 'gy-bg-beehive-r1'
echo "== build and upgrade from the picture (the action returns to the Yard tab)"
R=$(post "garden.php?t=pic" -d do=build -d building=kitchen -d t=pic); echo "$R" | grep -q 't=pic' && echo "ok   build returns to the Yard" || echo "FAIL build redirect '$R'"
page "garden.php?t=pic"; has "kitchen is level 1" 'gy-h-kitchen-l1'; has "level 1 art" 'kitchen-l1.png'
R=$(post "garden.php?t=pic" -d do=upgrade -d building=kitchen -d t=pic); echo "$R" | grep -q 't=pic' && echo "ok   upgrade returns to the Yard" || echo "FAIL upgrade redirect '$R'"
page "garden.php?t=pic"; has "kitchen is level 2" 'gy-h-kitchen-l2'; has "level 2 art" 'kitchen-l2.png'
echo "== ready animation"
post "garden.php?t=pic" -d do=build -d building=beehive -d t=pic >/dev/null
OLD=$(php -r '$_SERVER["SCRIPT_NAME"]="/gnome.php"; require "'$GAME'/includes/bootstrap.php"; require_once "'$GAME'/includes/gardens.php"; echo gmdate("Y-m-d H:i:s", gclock_plot_now('$P') - 30*86400);')   # 30 days ago on the plot's own clock
dbx "UPDATE garden_buildings SET built_at='$OLD', last_collect=NULL WHERE plot_id=$P AND building='beehive'"
page "garden.php?t=pic"; has "beehive loops its ready animation" 'gy-bg-beehive-r1'; has "a ready chip" 'hubchip'; has "card has Collect" 'Collect'
R=$(post "garden.php?t=pic" -d do=collect -d building=beehive -d t=pic); echo "$R" | grep -q 't=pic' && echo "ok   collect returns to the Yard" || echo "FAIL collect redirect '$R'"
NOW=$(php -r '$_SERVER["SCRIPT_NAME"]="/gnome.php"; require "'$GAME'/includes/bootstrap.php"; require_once "'$GAME'/includes/gardens.php"; echo gmdate("Y-m-d H:i:s", gclock_plot_now('$P'));')
dbx "UPDATE garden_buildings SET last_collect='$NOW' WHERE plot_id=$P AND building='beehive'"   # the honey was taken
page "garden.php?t=pic"; hasnot "ready animation stops once nothing is waiting" 'gy-bg-beehive-r1'
echo "== a card opens without script (?o=)"
page "garden.php?t=pic&o=kitchen"; has "kitchen card open" '<dialog class="picker hubpop gycard" id="gypop-kitchen"[^>]* open'
echo "== the Buildings tab and old links are unchanged"
page "garden.php?t=bld"; has "Buildings tab" 'id="buildings"'; page "garden.php?bld=kitchen"; has "?bld= still lands on Buildings" 'id="buildings"'
echo "== assets: every class the page uses is defined and every image exists"
page "garden.php?t=pic"
for cls in $(grep -o 'gy-h-[a-z_]*-[a-z0-9]*' $H | sort -u) $(grep -o 'gy-bg-[a-z_]*-[a-z0-9]*' $H | sort -u); do grep -q "\.$cls{" $GAME/assets/gyard.css || echo "FAIL css missing $cls"; done
for f in $(grep -o 'url(img/gyard/[a-z0-9_.-]*)' $GAME/assets/gyard.css | sed 's/url(\(.*\))/\1/' | sort -u); do [ -f $GAME/assets/$f ] || echo "FAIL missing image $f"; done
chk "no inline style attributes in the picture" "$(sed -n '/id="gyard"/,/<\/dialog>/p' $H | grep -c ' style=')" 0
echo "== php errors"; grep -E "Fatal|Warning|Notice|Deprecated" /tmp/gyard-php.log | head -5 || true; echo "(done)"
