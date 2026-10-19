GAME=$1; PORT=$2; ROUTER=$3; BASE=http://127.0.0.1:$PORT
php -d session.save_path=/tmp -S 127.0.0.1:$PORT -t $GAME $ROUTER >/tmp/tr-php.log 2>&1 & PID=$!; sleep 1
trap "kill $PID 2>/dev/null" EXIT
csrf() { grep -o 'name="csrf" value="[^"]*"' "$1" | head -1 | sed 's/.*value="\([^"]*\)".*/\1/'; }
db() { php -r '$p=new PDO("sqlite:'$GAME'/data/game.sqlite"); foreach($p->query($argv[1])->fetchAll(PDO::FETCH_NUM) as $r) echo implode(" | ",$r),"\n";' "$1"; }
dbx() { php -r '$p=new PDO("sqlite:'$GAME'/data/game.sqlite"); $p->exec($argv[1]);' "$1"; }
login() { rm -f $1; curl -s -c $1 -b $1 $BASE/login.php > /tmp/t.html; curl -s -c $1 -b $1 -X POST $BASE/login.php --data-urlencode "csrf=$(csrf /tmp/t.html)" -d username=$2 -d "password=$3" -o /dev/null; }
mp() { local c=$1 tab=$2; shift 2; curl -s -c $c -b $c "$BASE/market.php?t=$tab" > /tmp/t0.html; curl -s -c $c -b $c -X POST "$BASE/market.php?t=$tab" --data-urlencode "csrf=$(csrf /tmp/t0.html)" "$@" -o /dev/null; curl -s -c $c -b $c "$BASE/market.php?t=$tab" > /tmp/t.html; grep -oE 'class="ml (ok|err) new">[^<]*' /tmp/t.html | awk '!s[$0]++' | head -4; }
peek() { curl -s -c $1 -b $1 "$BASE/$2" > /tmp/t.html; grep -oE 'class="ml (ok|err) new">[^<]*' /tmp/t.html | awk '!s[$0]++' | head -4; }
qty() { db "SELECT COALESCE((SELECT qty FROM user_items WHERE user_id=$1 AND item_id=$2),0)"; }
coins() { db "SELECT coins FROM users WHERE id=$1"; }
SP=$(db "SELECT id FROM users WHERE username='sprout'"); AD=$(db "SELECT id FROM users WHERE username='admin'")
A=/tmp/ta-ck; T=/tmp/tt-ck; login $T admin TestPassword123
wp() { curl -s -c $T -b $T "$BASE/$1" > /tmp/w.html; curl -s -c $T -b $T -X POST "$BASE/welcome.php" --data-urlencode "csrf=$(csrf /tmp/w.html)" "${@:2}" -o /dev/null; }
RID=$(db "SELECT id FROM regions WHERE code='NA'"); VID=$(db "SELECT l.id FROM locations l WHERE l.region_id=$RID AND l.kind='village' AND EXISTS (SELECT 1 FROM routes r WHERE r.kind='road' AND (r.a_id=l.id OR r.b_id=l.id)) ORDER BY l.sort_order LIMIT 1 OFFSET 1")   # v1.2.3: one-region welcome flow
wp welcome.php -d do=gnome -d "gnome_name=Taker Tom" -d 'hat=#2e7d4f' -d 'beard=#b5651d'
wp 'welcome.php?step=place' -d do=place -d village_id=$VID; wp 'welcome.php?step=garden' -d do=finish -d 'garden_name=Tom Patch'
dbx "UPDATE users SET gnome_name='Taker Tom', onboarded=1 WHERE id=$AD AND onboarded=0"   # v1.0.1: the welcome steps above predate the one-region start, so finish Tom directly
echo "Tom onboarded: $(db "SELECT onboarded||' plots '||(SELECT COUNT(*) FROM plots WHERE user_id=$AD) FROM users WHERE id=$AD")"
dbx "UPDATE users SET level=3, coins=1000, energy=100 WHERE id=$AD"
dbx "UPDATE users SET level=3, coins=1000, energy=100 WHERE id=$SP"
dbx "INSERT OR REPLACE INTO settings (name,value) VALUES ('fresh_hold_days','0')"   # v1.0.1: these accounts are brand new; the fresh-gnome hold has its own test (fresh_hold.sh)
RADP=$(db "SELECT produce_item_id FROM plants WHERE slug='radish'"); CAN=$(db "SELECT id FROM items WHERE slug='tin-watering-can'")
dbx "INSERT OR REPLACE INTO user_items (user_id,item_id,qty) VALUES ($SP,$RADP,10)"; dbx "INSERT OR REPLACE INTO user_items (user_id,item_id,qty) VALUES ($AD,$CAN,1)"
login $A sprout 'TestPass123!'
echo "== gifts"; mp $A gifts -d do=gift -d to=Nobody -d item_id=$RADP -d qty=1
mp $A gifts -d do=gift -d to=sprout -d item_id=$RADP -d qty=1
mp $A gifts -d do=gift -d "to=taker tom" -d item_id=$RADP -d qty=3 -d coins=50 -d 'note=enjoy <3'
echo "taker radish $(qty $AD $RADP) coins $(coins $AD)"; echo "-- taker sees notice:"; peek $T garden.php; peek $T garden.php | head -1; echo "(second load should be empty above)"
echo "-- gifts-per-day cap (v1.2.2): cap 3, one already sent, so 2 more land and the 4th is refused"
dbx "INSERT OR REPLACE INTO settings (name,value) VALUES ('gifts_per_day','3')"; G0=$(db "SELECT COUNT(*) FROM gifts WHERE from_id=$SP")
mp $A gifts -d do=gift -d "to=taker tom" -d item_id=$RADP -d qty=1; mp $A gifts -d do=gift -d "to=taker tom" -d item_id=$RADP -d qty=1; mp $A gifts -d do=gift -d "to=taker tom" -d item_id=$RADP -d qty=1
echo "gifts sent $G0 -> $(db "SELECT COUNT(*) FROM gifts WHERE from_id=$SP") (expect 3), radish left $(qty $SP $RADP) (expect 5)"
dbx "INSERT OR REPLACE INTO settings (name,value) VALUES ('gifts_per_day','10')"
echo "== stall"; mp $A stall -d do=list -d item_id=$RADP -d qty=4 -d price=100; echo "sprout radish now $(qty $SP $RADP)"
LID=$(db "SELECT id FROM stall_listings LIMIT 1")
curl -s -b $T "$BASE/market.php?t=buy&q=RAD" > /tmp/t.html; echo "search hits: $(grep -c '>Buy</button>' /tmp/t.html)"
mp $A buy -d do=buy -d id=$LID -d qty=1
C0=$(coins $SP); mp $T buy -d do=buy -d id=$LID -d qty=2; echo "seller coins $C0 -> $(coins $SP) (expect +190), buyer radish $(qty $AD $RADP), taker coins $(coins $AD)"
mp $T buy -d do=buy -d id=$LID -d qty=9; echo "left on listing: $(db "SELECT qty FROM stall_listings WHERE id=$LID")"
mp $A stall -d do=unlist -d id=$LID; echo "sprout radish back $(qty $SP $RADP)"
echo "-- seller notices:"; peek $A garden.php
echo "== trade: sprout offers 1 radish + 10 for Tom's watering can"
mp $A trades -d do=offer -d to_id=$AD -d 'give_id[]='$RADP -d 'give_qty[]=1' -d give_coins=10 -d 'want_id[]='$CAN -d 'want_qty[]=1'
OID=$(db "SELECT MAX(id) FROM trade_offers"); echo "sprout radish held: $(qty $SP $RADP) coins $(coins $SP)"
echo "-- Tom sees offer:"; peek $T market.php?t=trades; grep -c 'value="accept"' /tmp/t.html
mp $T trades -d do=answer -d id=$OID -d answer=accept; echo "sprout can $(qty $SP $CAN), Tom can $(qty $AD $CAN), Tom coins $(coins $AD)"
echo "-- accept twice"; mp $T trades -d do=answer -d id=$OID -d answer=accept
echo "-- offer Tom can't fulfil, then decline"; mp $A trades -d do=offer -d to_id=$AD -d 'give_id[]='$RADP -d 'give_qty[]=2' -d 'want_id[]='$CAN -d 'want_qty[]=1'
O2=$(db "SELECT MAX(id) FROM trade_offers"); mp $T trades -d do=answer -d id=$O2 -d answer=accept; db "SELECT 'offer2 '||status FROM trade_offers WHERE id=$O2"
mp $T trades -d do=answer -d id=$O2 -d answer=decline; echo "sprout radish after decline $(qty $SP $RADP)"
echo "-- expiry"; mp $A trades -d do=offer -d to_id=$AD -d give_coins=25 -d 'want_id[]='$RADP -d 'want_qty[]=1'; O3=$(db "SELECT MAX(id) FROM trade_offers"); C1=$(coins $SP)
dbx "UPDATE trade_offers SET created_at=datetime('now','-9 days') WHERE id=$O3"; peek $T market.php >/dev/null; db "SELECT 'offer3 '||status FROM trade_offers WHERE id=$O3"; echo "sprout coins $C1 -> $(coins $SP)"
echo "== saplings"; DUR=$(db "SELECT id FROM plants WHERE slug='tomato'"); DSEED=$(db "SELECT seed_item_id FROM plants WHERE slug='tomato'")
dbx "INSERT OR REPLACE INTO user_plant_knowledge (user_id,plant_id,knowledge) SELECT $SP, id, knowledge_max FROM plants WHERE slug='tomato'"
dbx "INSERT OR REPLACE INTO user_items (user_id,item_id,qty) VALUES ($SP,$DSEED,5)"
mp $A saplings -d do=sapling -d plant_id=$DUR; mp $A saplings -d do=sapling -d plant_id=$DUR; mp $A saplings -d do=sapling -d plant_id=$DUR; mp $A saplings -d do=sapling -d plant_id=$DUR
echo "sapling_count today: $(db "SELECT sapling_count FROM users WHERE id=$SP") (expect 3, the 4th was refused), tomato seeds left $(qty $SP $DSEED) (expect 2)"
SAP=$(db "SELECT id FROM items WHERE slug='tomato-sapling'"); echo "saplings $(qty $SP $SAP), item: $(db "SELECT name||' / '||category FROM items WHERE id=$SAP")"
echo "-- not mastered"; RAD=$(db "SELECT id FROM plants WHERE slug='radish'"); mp $A saplings -d do=sapling -d plant_id=$RAD
P=$(db "SELECT id FROM plots WHERE user_id=$SP LIMIT 1"); dbx "UPDATE plot_tiles SET tilled=1, method='till', plant_id=NULL, fertility=90, settle_until=NULL WHERE plot_id=$P AND x=0 AND y=3"
curl -s -c $A -b $A "$BASE/garden.php?sel=0-3" > /tmp/g.html; echo "sapling in plant list: $(grep -c 'Tomato Seedling' /tmp/g.html)"
curl -s -c $A -b $A -X POST "$BASE/garden.php" --data-urlencode "csrf=$(csrf /tmp/g.html)" -d do=plant -d x=0 -d y=3 -d reach=one -d item_id=$SAP -o /dev/null; peek $A garden.php
db "SELECT 'planted growth '||t.growth_seconds||' of '||(p.grow_minutes*60) FROM plot_tiles t JOIN plants p ON p.id=t.plant_id WHERE t.plot_id=$P AND t.x=0 AND t.y=3"
echo "== php errors"; grep -iE 'fatal|warning|notice|deprecated' /tmp/tr-php.log || echo "(none)"
