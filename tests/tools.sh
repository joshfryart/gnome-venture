GAME=$1; PORT=$2; ROUTER=$3; BASE=http://127.0.0.1:$PORT
php -d session.save_path=/tmp -S 127.0.0.1:$PORT -t $GAME $ROUTER >/tmp/tools-php.log 2>&1 & PID=$!; sleep 1
C=/tmp/tools-ck; rm -f $C
csrf() { grep -o 'name="csrf" value="[^"]*"' "$1" | head -1 | sed 's/.*value="\([^"]*\)".*/\1/'; }
db() { php -r '$p=new PDO("sqlite:'$GAME'/data/game.sqlite"); foreach($p->query($argv[1])->fetchAll(PDO::FETCH_NUM) as $r) echo implode(" | ",$r),"\n";' "$1"; }
dbx() { php -r '$p=new PDO("sqlite:'$GAME'/data/game.sqlite"); $p->exec($argv[1]);' "$1"; }
act() { curl -s -c $C -b $C "$BASE/garden.php?sel=$2-$3" > /tmp/t.html; curl -s -c $C -b $C -X POST "$BASE/garden.php" --data-urlencode "csrf=$(csrf /tmp/t.html)" -d do=$1 -d x=$2 -d y=$3 -d reach=$4 ${5:+-d item_id=$5} -o /dev/null; curl -s -c $C -b $C "$BASE/garden.php?sel=$2-$3" > /tmp/t.html; grep -oE 'flash (ok|err)">[^<]*' /tmp/t.html | head -4; }
echo "== Twigg's tool stock"; db "SELECT COUNT(*) FROM shop_stock st JOIN items i ON i.id=st.item_id WHERE i.category='tool'"
db "SELECT name||' '||effects FROM items WHERE slug IN ('worn-trowel','garden-hoe','tin-watering-can')"
curl -s -c $C -b $C $BASE/login.php > /tmp/t.html; curl -s -c $C -b $C -X POST $BASE/login.php --data-urlencode "csrf=$(csrf /tmp/t.html)" -d username=sprout -d 'password=TestPass123!' -o /dev/null
UID_=$(db "SELECT id FROM users WHERE username='sprout'")
echo "== by hand: row planting refused, reach one ok"
act till 0 2 row
echo "== give Steel Spade, Seed Drill, Copper Can, Garden Fork, Harvest Sack, Garden Snips"
for slug in steel-spade seed-drill copper-watering-can garden-fork harvest-sack garden-snips; do dbx "INSERT INTO user_items (user_id,item_id,qty) SELECT $UID_, id, 1 FROM items WHERE slug='$slug'"; done
dbx "UPDATE users SET energy=100 WHERE id=$UID_"
curl -s -c $C -b $C "$BASE/garden.php?sel=1-2" > /tmp/t.html; grep -oE 'name="reach" value="[a-z]+">[^<]*' /tmp/t.html
echo "-- till row 2"; act till 1 2 row
db "SELECT 'row2 tilled: '||SUM(tilled) FROM plot_tiles WHERE user_id=$UID_ AND y=2"; db "SELECT 'energy '||energy FROM users WHERE id=$UID_"
CP=$(db "SELECT id FROM items WHERE slug='plain-compost'"); RAD=$(db "SELECT id FROM items WHERE slug='radish-seed'")
echo "-- compost x3 (garden fork)"; act soil 1 2 three $CP
db "SELECT 'feeding squares: '||SUM(feed_hours>0) FROM plot_tiles WHERE user_id=$UID_ AND y=2"
echo "-- plant radish row"; act plant 0 2 row $RAD
db "SELECT 'planted: '||SUM(plant_id IS NOT NULL) FROM plot_tiles WHERE user_id=$UID_ AND y=2"
echo "-- water x3 (copper can)"; act water 1 2 three
echo "-- grow, harvest row"; dbx "UPDATE plot_tiles SET growth_seconds=999999 WHERE user_id=$UID_ AND plant_id IS NOT NULL"
act harvest 0 2 row
echo "-- reach cheat: ask for row with x3 can"; act water 0 2 row
echo "== satchel toolbelt"; curl -s -c $C -b $C $BASE/inventory.php | grep -oE '<td>[^<]*(Tilling|Planting|Pruning)</td>\s*<td><b>[^<]*' | head -3
kill $PID; grep -iE 'fatal|warning|notice' /tmp/tools-php.log || echo "(no php errors)"
