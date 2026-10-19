#!/bin/bash
GAME=$1; PORT=$2; ROUTER=$3; BASE=http://127.0.0.1:$PORT
php -d session.save_path=/tmp -S 127.0.0.1:$PORT -t $GAME $ROUTER >/tmp/gear-php.log 2>&1 & PID=$!; sleep 1
trap "kill $PID 2>/dev/null" EXIT
csrf() { grep -o 'name="csrf" value="[^"]*"' "$1" | head -1 | sed 's/.*value="\([^"]*\)".*/\1/'; }
db() { php -r '$p=new PDO("sqlite:'$GAME'/data/game.sqlite"); foreach($p->query($argv[1])->fetchAll(PDO::FETCH_NUM) as $r) echo implode(" | ",$r),"\n";' "$1"; }
dbx() { php -r '$p=new PDO("sqlite:'$GAME'/data/game.sqlite"); $p->exec($argv[1]);' "$1"; }
C=/tmp/gear-ck; rm -f $C; curl -s -c $C -b $C $BASE/login.php > /tmp/g.html; curl -s -c $C -b $C -X POST $BASE/login.php --data-urlencode "csrf=$(csrf /tmp/g.html)" -d username=sprout -d 'password=TestPass123!' -o /dev/null
SID=$(db "SELECT id FROM users WHERE username='sprout'"); dbx "UPDATE settings SET value='100000' WHERE name='event_chance'"; dbx "UPDATE expeditions SET status='done' WHERE user_id=$SID"
give() { dbx "INSERT OR IGNORE INTO user_items (user_id,item_id,qty) VALUES ($SID,(SELECT id FROM items WHERE slug='$1'),0)"; dbx "UPDATE user_items SET qty=qty+$2 WHERE user_id=$SID AND item_id=(SELECT id FROM items WHERE slug='$1')"; }
echo "== gear items"; db "SELECT name, base_price, substr(description, 1, 110) FROM items WHERE slug IN ('walking-stick','hiking-staff','wayfarer-s-staff','tin-lantern','miner-s-lantern','glowcap-lantern','soil-probe')"
echo "== at Twigg's: $(db "SELECT group_concat(i.name, ', ') FROM shop_stock st JOIN items i ON i.id=st.item_id WHERE i.slug IN ('walking-stick','hiking-staff','tin-lantern','soil-probe')")"
echo "== gear recipes: $(db "SELECT COUNT(*) FROM recipes WHERE slug IN ('hiking-staff','wayfarer-s-staff','miner-s-lantern','glowcap-lantern','soil-probe')")"
HOME=$(db "SELECT home_village_id FROM users WHERE id=$SID"); give wayfarer-s-staff 1
free=0; for i in $(seq 20); do dbx "UPDATE expeditions SET status='done' WHERE user_id=$SID"; dbx "UPDATE users SET location_id=$HOME, energy=30, energy_updated_at=datetime('now') WHERE id=$SID"; curl -s -b $C -c $C $BASE/world.php > /tmp/g.html; curl -s -b $C -c $C -X POST $BASE/adventure.php --data-urlencode "csrf=$(csrf /tmp/g.html)" -d do=explore -o /dev/null; [ "$(db "SELECT energy FROM users WHERE id=$SID")" = 30 ] && free=$((free+1)); done; echo "== staff (65%): $free of 20 trips off the path were free"
dbx "UPDATE expeditions SET status='done' WHERE user_id=$SID"
give tin-lantern 1; DL=$(db "SELECT lm.id||' '||lm.location_id FROM landmarks lm WHERE kind='delve' LIMIT 1"); read DID DLOC <<< "$DL"
dbx "DELETE FROM landmark_uses WHERE user_id=$SID"; dbx "UPDATE users SET location_id=$DLOC, energy=20, level=20, stat_grit=20, stat_hardiness=20 WHERE id=$SID"
curl -s -b $C -c $C $BASE/world.php > /tmp/g.html; echo "== lantern: panel says '$(grep -oE 'rooms free \(🏮\)' /tmp/g.html)'"; curl -s -b $C -c $C -X POST $BASE/landmark.php --data-urlencode "csrf=$(csrf /tmp/g.html)" -d do=delve -d lm=$DID -o /dev/null
E0=$(db "SELECT energy FROM users WHERE id=$SID"); for r in 1 2 3; do curl -s -b $C -c $C $BASE/adventure.php > /tmp/g.html; [ -n "$(grep -o 'value="next"' /tmp/g.html)" ] && curl -s -b $C -c $C -X POST $BASE/adventure.php --data-urlencode "csrf=$(csrf /tmp/g.html)" -d do=next -o /dev/null
  for k in $(seq 30); do curl -s -b $C -c $C $BASE/adventure.php > /tmp/g.html; if grep -q 'value="auto"' /tmp/g.html; then D=auto; elif grep -q 'value="attack"' /tmp/g.html; then D=attack; elif grep -q 'value="solve"' /tmp/g.html; then D="solve&option=0"; else break; fi; curl -s -b $C -c $C -X POST $BASE/adventure.php --data-urlencode "csrf=$(csrf /tmp/g.html)" -d "do=$D" -o /dev/null; done; done
echo "  energy after 3 rooms: $E0 → $(db "SELECT energy FROM users WHERE id=$SID") · depth $(db "SELECT depth||' '||status FROM expeditions WHERE user_id=$SID ORDER BY id DESC LIMIT 1")"
dbx "UPDATE expeditions SET status='done' WHERE user_id=$SID"; dbx "UPDATE users SET location_id=$HOME WHERE id=$SID"
echo "== soil probe"; give soil-probe 1; P=$(db "SELECT active_plot_id FROM users WHERE id=$SID"); T=$(db "SELECT x||'-'||y FROM plot_tiles WHERE plot_id=$P AND plant_id IS NULL LIMIT 1"); dbx "UPDATE plot_tiles SET tilled=1, method='till' WHERE plot_id=$P AND x||'-'||y='$T'"
curl -s -b $C "$BASE/garden.php?sel=$T" | grep -oE 'class="probe">.*' | sed 's/<[^>]*>//g' | head -1
echo "== php errors"; grep -iE 'fatal|warning|notice|deprecated' /tmp/gear-php.log || echo "(none)"
