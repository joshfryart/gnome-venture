GAME=$1; PORT=$2; ROUTER=$3; BASE=http://127.0.0.1:$PORT
php -d session.save_path=/tmp -S 127.0.0.1:$PORT -t $GAME $ROUTER >/tmp/help-php.log 2>&1 & PID=$!; sleep 1
trap "kill $PID 2>/dev/null" EXIT
C=/tmp/help-ck; rm -f $C
csrf() { grep -o 'name="csrf" value="[^"]*"' "$1" | head -1 | sed 's/.*value="\([^"]*\)".*/\1/'; }
db() { php -r '$p=new PDO("sqlite:'$GAME'/data/game.sqlite"); foreach($p->query($argv[1])->fetchAll(PDO::FETCH_NUM) as $r) echo implode(" | ",$r),"\n";' "$1"; }
dbx() { php -r '$p=new PDO("sqlite:'$GAME'/data/game.sqlite"); $p->exec($argv[1]);' "$1"; }
page() { curl -s -c $C -b $C "$BASE/$1" > /tmp/h.html; grep -oE 'flash (ok|err)">[^<]*' /tmp/h.html | head -6; }
post() { curl -s -c $C -b $C "$BASE/garden.php" > /tmp/h.html; curl -s -c $C -b $C -X POST "$BASE/garden.php" --data-urlencode "csrf=$(csrf /tmp/h.html)" "$@" -o /dev/null; page garden.php; }
act() { curl -s -c $C -b $C "$BASE/garden.php?sel=$2-$3" > /tmp/h.html; curl -s -c $C -b $C -X POST "$BASE/garden.php" --data-urlencode "csrf=$(csrf /tmp/h.html)" -d do=$1 -d x=$2 -d y=$3 -d reach=one ${4:+-d item_id=$4} -o /dev/null; }
curl -s -c $C -b $C $BASE/login.php > /tmp/h.html; curl -s -c $C -b $C -X POST $BASE/login.php --data-urlencode "csrf=$(csrf /tmp/h.html)" -d username=sprout -d 'password=TestPass123!' -o /dev/null
UID_=$(db "SELECT id FROM users WHERE username='sprout'"); P=$(db "SELECT id FROM plots WHERE user_id=$UID_ LIMIT 1")
echo "== roster"; db "SELECT icon||' '||name||' '||skills||' '||wage FROM helpers"
db "SELECT 'hired-help page for sprout: '||COUNT(*) FROM user_encyclopedia ue JOIN encyclopedia_entries e ON e.id=ue.entry_id WHERE ue.user_id=$UID_ AND e.title='Hired help'"
BURROW=$(db "SELECT id FROM helpers WHERE name='Old Burrow'"); PIP=$(db "SELECT id FROM helpers WHERE name='Pip Dewfoot'")
page "garden.php?t=help" >/dev/null; echo "no shed text: $(grep -c 'build a <b>🧰 Tool Shed' /tmp/h.html)"
echo "-- hire without shed"; post -d do=hire -d helper_id=$BURROW -d days=1
dbx "INSERT INTO garden_buildings (plot_id,building,built_at,last_collect) VALUES ($P,'tool_shed',datetime('now'),datetime('now'))"
dbx "UPDATE users SET coins=1000, energy=100 WHERE id=$UID_"
echo "-- bad days"; post -d do=hire -d helper_id=$BURROW -d days=2
echo "-- hire Old Burrow 1 day"; post -d do=hire -d helper_id=$BURROW -d days=1; db "SELECT 'coins '||coins FROM users WHERE id=$UID_"
echo "-- second hire refused"; post -d do=hire -d helper_id=$PIP -d days=1
echo "== set up: radish thirsty at 2,0; ready radish at 3,0; weedy no-till bed at 2,1"
RAD=$(db "SELECT id FROM items WHERE slug='radish-seed'"); dbx "INSERT OR REPLACE INTO user_items (user_id,item_id,qty) VALUES ($UID_,$RAD,5)"
act till 2 0; act plant 2 0 $RAD; act till 3 0; act plant 3 0 $RAD
dbx "UPDATE plot_tiles SET planted_at=datetime('now','-9 hours'), growth_updated_at=datetime('now','-9 hours'), last_watered=NULL, growth_seconds=0 WHERE plot_id=$P AND x=2 AND y=0"
dbx "UPDATE plot_tiles SET growth_seconds=999999 WHERE plot_id=$P AND x=3 AND y=0"
dbx "UPDATE plot_tiles SET tilled=1, method='notill', weeds=30, maint_at=datetime('now') WHERE plot_id=$P AND x=2 AND y=1"
dbx "UPDATE garden_hires SET last_visit=datetime('now','-9 hours'), started_at=datetime('now','-9 hours') WHERE plot_id=$P"
RADP=$(db "SELECT produce_item_id FROM plants WHERE slug='radish'"); B=$(db "SELECT COALESCE((SELECT qty FROM user_items WHERE user_id=$UID_ AND item_id=$RADP),0)")
echo "-- load garden (2 visits due)"; page garden.php
db "SELECT 'thirsty tile: growth='||growth_seconds||' last_watered='||last_watered FROM plot_tiles WHERE plot_id=$P AND x=2 AND y=0"
db "SELECT 'ready tile now: plant='||COALESCE(plant_id,'none') FROM plot_tiles WHERE plot_id=$P AND x=3 AND y=0"
db "SELECT 'weeds='||weeds FROM plot_tiles WHERE plot_id=$P AND x=2 AND y=1"
echo "radishes $B -> $(db "SELECT qty FROM user_items WHERE user_id=$UID_ AND item_id=$RADP")"
db "SELECT 'hire: visits='||visits||' w='||waterings||' weed='||weedings||' h='||harvests||' active='||active FROM garden_hires WHERE plot_id=$P"
echo "-- reload: nothing new"; page garden.php
echo "panel: $(grep -oE 'is staying in your Tool Shed' /tmp/h.html)"
echo "== contract ends"; dbx "UPDATE garden_hires SET ends_at=datetime('now','-1 minute') WHERE plot_id=$P AND active=1"; page garden.php
db "SELECT 'active now '||active FROM garden_hires WHERE plot_id=$P"
echo "== hire Pip 3 days, dismiss -> refund"; dbx "UPDATE users SET coins=1000 WHERE id=$UID_"; post -d do=hire -d helper_id=$PIP -d days=3 >/dev/null; db "SELECT 'coins '||coins FROM users WHERE id=$UID_"
post -d do=dismiss; db "SELECT 'coins '||coins FROM users WHERE id=$UID_"
echo "== php errors"; grep -iE 'fatal|warning|notice|deprecated' /tmp/help-php.log || echo "(none)"
