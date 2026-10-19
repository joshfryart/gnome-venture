GAME=$1; PORT=$2; ROUTER=$3; BASE=http://127.0.0.1:$PORT
php -d session.save_path=/tmp -S 127.0.0.1:$PORT -t $GAME $ROUTER >/tmp/fr-php.log 2>&1 & PID=$!; sleep 1
trap "kill $PID 2>/dev/null" EXIT
csrf() { grep -o 'name="csrf" value="[^"]*"' "$1" | head -1 | sed 's/.*value="\([^"]*\)".*/\1/'; }
db() { php -r '$p=new PDO("sqlite:'$GAME'/data/game.sqlite"); foreach($p->query($argv[1])->fetchAll(PDO::FETCH_NUM) as $r) echo implode(" | ",$r),"\n";' "$1"; }
dbx() { php -r '$p=new PDO("sqlite:'$GAME'/data/game.sqlite"); $p->exec($argv[1]);' "$1"; }
C=/tmp/fr-ck; rm -f $C
curl -s -c $C -b $C $BASE/login.php > /tmp/f.html; curl -s -c $C -b $C -X POST $BASE/login.php --data-urlencode "csrf=$(csrf /tmp/f.html)" -d username=sprout -d 'password=TestPass123!' -o /dev/null
# v0.9.8 markup: flashes are <div class="flash ok" role="status">msg</div>
np() { local id=$1; shift; curl -s -c $C -b $C "$BASE/folk.php?id=$id" > /tmp/f0.html; curl -s -c $C -b $C -X POST "$BASE/folk.php?id=$id" --data-urlencode "csrf=$(csrf /tmp/f0.html)" "$@" -o /dev/null; curl -s -c $C -b $C "$BASE/folk.php?id=$id" > /tmp/f.html; grep -oE 'class="flash (ok|err)"[^>]*>[^<]*' /tmp/f.html | sed -E 's/^[^>]*>//' | head -2; }
UID_=$(db "SELECT id FROM users WHERE username='sprout'")
TW=$(db "SELECT id FROM shops WHERE slug='twigg-s-seed-emporium'")
# make sure someone is on duty at Twigg's all day for the test
NID=$(db "SELECT npc_id FROM npc_schedules WHERE shop_id=$TW LIMIT 1"); dbx "UPDATE npc_schedules SET start_hour=0, end_hour=24, days='all' WHERE npc_id=$NID AND shop_id=$TW"
ST=$(curl -s -b $C "$BASE/shop.php?id=$TW" | grep -oE 'data-id="[0-9]+" data-price="[0-9]+"' | head -1 | grep -oE '[0-9]+' | head -1)   # first tile on the Buy tab
price() { curl -s -b $C "$BASE/shop.php?id=$TW" | grep -oE "data-id=\"$ST\" data-price=\"[0-9]+\"" | grep -oE '[0-9]+"$' | tr -d '"'; }
curl -s -b $C "$BASE/shop.php?id=$TW" > /tmp/f.html; echo "staff links on shop page: $(grep -c 'folk.php?id=' /tmp/f.html)"
P0=$(price)
echo "== talk to $(db "SELECT name||' ('||personality||')' FROM npcs WHERE id=$NID")"; np $NID -d do=talk | cut -c1-200; np $NID -d do=talk
read LOVED LIKECAT DIS <<< "$(php $(dirname $0)/npctaste.php $GAME $NID 2>/dev/null | tail -1)"
echo "== gifts (loved item $LOVED)"; dbx "INSERT OR REPLACE INTO user_items (user_id,item_id,qty) VALUES ($UID_,$LOVED,2)"
np $NID -d do=gift -d item_id=$LOVED; np $NID -d do=gift -d item_id=$LOVED
db "SELECT 'friendship '||points||' talks '||talks||' gifts '||gifts||' known '||known FROM npc_friends WHERE user_id=$UID_"
curl -s -b $C "$BASE/folk.php?id=$NID&tab=tastes" > /tmp/f.html
echo "tastes tab shows loved: $(grep -c '💛 Loves' /tmp/f.html)"
echo "-- gift a disliked thing next day"; dbx "UPDATE npc_friends SET last_gift='2000-01-01'"; dbx "INSERT OR REPLACE INTO user_items (user_id,item_id,qty) VALUES ($UID_,$DIS,1)"; np $NID -d do=gift -d item_id=$DIS
curl -s -b $C "$BASE/folk.php?id=$NID&tab=tastes" > /tmp/f.html; echo "tastes tab shows dislike: $(grep -c 'Not keen on' /tmp/f.html)"
echo "== discount"; dbx "UPDATE npc_friends SET points=100"; P1=$(price); echo "first price $P0 -> $P1 ; friends tag: $(curl -s -b $C "$BASE/shop.php?id=$TW" | grep -c 'Prices include your friends discount')"
PR=$(db "SELECT current_price FROM shop_stock WHERE id=$ST"); C0=$(db "SELECT coins FROM users WHERE id=$UID_")
curl -s -c $C -b $C "$BASE/shop.php?id=$TW" > /tmp/f0.html; curl -s -c $C -b $C -X POST "$BASE/shop.php?id=$TW" --data-urlencode "csrf=$(csrf /tmp/f0.html)" -d do=buy --data-urlencode "qty[$ST]=1" -o /dev/null
echo "list price $PR, shown price $P1, paid $((C0 - $(db "SELECT coins FROM users WHERE id=$UID_")))"
echo "== someone not around"; FAR=$(db "SELECT s.npc_id FROM npc_schedules s JOIN shops sh ON sh.id=s.shop_id JOIN locations l ON l.id=sh.location_id WHERE l.region <> 'Mossbottom' AND l.region <> (SELECT r.gnomish_name FROM regions r JOIN users u ON u.region_id=r.id WHERE u.id=$UID_) LIMIT 1")
np $FAR -d do=talk; echo "notice shown: $(grep -c 'Not anywhere you can reach' /tmp/f.html)"
curl -s -b $C $BASE/gnome.php > /tmp/f.html; echo "gnome friends rows: $(grep -c 'folk.php?id=' /tmp/f.html)"
curl -s -b $C $BASE/world.php > /tmp/f.html; echo "world folk links: $(grep -c 'href="[^"]*folk.php"' /tmp/f.html)"
echo "== php errors"; grep -iE 'fatal|warning|notice|deprecated' /tmp/fr-php.log || echo "(none)"
