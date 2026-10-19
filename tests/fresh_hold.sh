# v1.0.1: fresh gnome hold. Usage: bash tests/fresh_hold.sh <walked copy> <port> tests/router.php
GAME=$1; PORT=$2; ROUTER=$3; BASE=http://127.0.0.1:$PORT
php -d session.save_path=/tmp -S 127.0.0.1:$PORT -t $GAME $ROUTER >/tmp/fh-php.log 2>&1 & PID=$!; sleep 1
trap "kill $PID 2>/dev/null" EXIT
csrf() { grep -o 'name="csrf" value="[^"]*"' "$1" | head -1 | sed 's/.*value="\([^"]*\)".*/\1/'; }
db() { php -r '$p=new PDO("sqlite:'$GAME'/data/game.sqlite"); foreach($p->query($argv[1])->fetchAll(PDO::FETCH_NUM) as $r) echo implode(" | ",$r),"\n";' "$1"; }
dbx() { php -r '$p=new PDO("sqlite:'$GAME'/data/game.sqlite"); $p->exec($argv[1]);' "$1"; }
set_s() { dbx "INSERT OR REPLACE INTO settings (name,value) VALUES ('$1','$2')"; }
A=/tmp/fh-ck; rm -f $A; curl -s -c $A -b $A $BASE/login.php > /tmp/fh.html
curl -s -c $A -b $A -X POST $BASE/login.php --data-urlencode "csrf=$(csrf /tmp/fh.html)" -d username=sprout -d 'password=TestPass123!' -o /dev/null
mp() { local tab=$1; shift; curl -s -c $A -b $A "$BASE/account.php" > /tmp/fh0.html; curl -s -c $A -b $A -X POST "$BASE/market.php?t=$tab" --data-urlencode "csrf=$(csrf /tmp/fh0.html)" "$@" -o /dev/null; curl -s -c $A -b $A "$BASE/market.php?t=$tab" > /tmp/fh.html; grep -oE 'flash (ok|err)" role="[a-z]+">[^<]*' /tmp/fh.html | head -1; }
SP=$(db "SELECT id FROM users WHERE username='sprout'"); AD=$(db "SELECT id FROM users WHERE username='admin'")
dbx "UPDATE users SET gnome_name='Taker Tom', onboarded=1 WHERE id=$AD"
RAD=$(db "SELECT produce_item_id FROM plants WHERE slug='radish'"); CAN=$(db "SELECT id FROM items WHERE slug='tin-watering-can'")
dbx "UPDATE users SET level=3, coins=1000, energy=100 WHERE id=$SP"; dbx "INSERT OR REPLACE INTO user_items (user_id,item_id,qty) VALUES ($SP,$RAD,10)"
q() { db "$1"; }
coins() { db "SELECT coins FROM users WHERE id=$1"; }
FAIL=0; ok() { if [ "$2" = "$3" ]; then echo "  ok   $1"; else echo "  FAIL $1: got [$2] want [$3]"; FAIL=$((FAIL+1)); fi; }
gift() { mp gifts -d do=gift -d "to=taker tom" -d item_id=$RAD -d qty=1 -d coins=${1:-0}; }
echo "== held by account age (default 3 days, level 3 ok)"; set_s fresh_hold_days 3; set_s fresh_hold_level 3
gift 50 >/dev/null; ok "gift refused: Petals kept" "$(coins $SP)" 1000; ok "gift refused: nothing arrived" "$(q "SELECT COALESCE(SUM(qty),0) FROM user_items WHERE user_id=$AD AND item_id=$RAD")" 0
echo "  msg: $(grep -oE 'New gnomes[^<]*' /tmp/fh.html | head -1)"
mp stall -d do=list -d item_id=$RAD -d qty=1 -d price=5 >/dev/null; ok "stall listing refused" "$(q "SELECT COUNT(*) FROM stall_listings")" 0
mp trades -d do=offer -d to_id=$AD -d "give_id[]=$RAD" -d 'give_qty[]=1' -d give_coins=0 >/dev/null; ok "offer refused" "$(q "SELECT COUNT(*) FROM trade_offers")" 0
echo "== held by level"; dbx "UPDATE users SET created_at=datetime('now','-10 days') WHERE id=$SP"; set_s fresh_hold_level 5
gift 0 >/dev/null; ok "gift refused by level (3 < 5)" "$(q "SELECT COALESCE(SUM(qty),0) FROM user_items WHERE user_id=$AD AND item_id=$RAD")" 0
echo "== old enough and high enough"; set_s fresh_hold_level 3
gift 0 >/dev/null; ok "Tom got the radish" "$(db "SELECT qty FROM user_items WHERE user_id=$AD AND item_id=$RAD")" 1
echo "== accepting an offer that asks for Petals (accepter held)"
dbx "UPDATE users SET created_at=datetime('now'), level=3, coins=500, role='player' WHERE id=$AD"; dbx "UPDATE users SET password_hash=(SELECT password_hash FROM users WHERE id=$SP) WHERE id=$AD"
dbx "INSERT INTO trade_offers (from_id,to_id,give_items,give_coins,want_items,want_coins,status,created_at) VALUES ($SP,$AD,'{}',0,'{}',10,'open',datetime('now'))"
OID=$(db "SELECT MAX(id) FROM trade_offers")
B=/tmp/fh-ck2; rm -f $B; curl -s -c $B -b $B $BASE/login.php > /tmp/fh.html
curl -s -c $B -b $B -X POST $BASE/login.php --data-urlencode "csrf=$(csrf /tmp/fh.html)" -d username=admin -d 'password=TestPass123!' -o /dev/null
curl -s -c $B -b $B "$BASE/account.php" > /tmp/fh0.html; curl -s -c $B -b $B -X POST "$BASE/market.php?t=trades" --data-urlencode "csrf=$(csrf /tmp/fh0.html)" -d do=answer -d id=$OID -d answer=accept -o /dev/null
curl -s -c $B -b $B "$BASE/market.php?t=trades" > /tmp/fh.html
ok "accept refused: offer still open" "$(db "SELECT status FROM trade_offers WHERE id=$OID")" open
echo "== staff exempt"; dbx "UPDATE users SET created_at=datetime('now'), level=3, role='admin' WHERE id=$SP"
dbx "UPDATE user_items SET qty=0 WHERE user_id=$AD"; gift 0 >/dev/null; ok "admin gift goes" "$(q "SELECT COALESCE(SUM(qty),0) FROM user_items WHERE user_id=$AD AND item_id=$RAD")" 1
echo; [ $FAIL = 0 ] && echo "ALL PASSED" || echo "$FAIL FAILED"
