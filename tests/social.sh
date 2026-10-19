#!/bin/bash
GAME=$1; PORT=$2; ROUTER=$3; BASE=http://127.0.0.1:$PORT
php -d session.save_path=/tmp -S 127.0.0.1:$PORT -t $GAME $ROUTER >/tmp/soc-php.log 2>&1 & PID=$!; sleep 1
trap "kill $PID 2>/dev/null" EXIT
csrf() { grep -o 'name="csrf" value="[^"]*"' "$1" | head -1 | sed 's/.*value="\([^"]*\)".*/\1/'; }
db() { php -r '$p=new PDO("sqlite:'$GAME'/data/game.sqlite"); foreach($p->query($argv[1])->fetchAll(PDO::FETCH_NUM) as $r) echo implode(" | ",$r),"\n";' "$1"; }
dbx() { php -r '$p=new PDO("sqlite:'$GAME'/data/game.sqlite"); $p->exec($argv[1]);' "$1"; }
dbx "DELETE FROM users WHERE username='bloom'"
php -r '$p=new PDO("sqlite:'$GAME'/data/game.sqlite"); $r=$p->query("SELECT * FROM users WHERE username=\"sprout\"")->fetch(PDO::FETCH_ASSOC); unset($r["id"]); $r["username"]="bloom"; $r["email"]="bloom@b.local"; $r["gnome_name"]="Bloom Thistledown"; $c=array_keys($r); $p->prepare("INSERT INTO users (".implode(",",$c).") VALUES (".implode(",",array_fill(0,count($c),"?")).")")->execute(array_values($r));'
dbx "UPDATE users SET location_id=(SELECT l.id FROM locations l WHERE l.kind='market' AND l.region_id=users.region_id LIMIT 1)"; dbx "UPDATE users SET energy=50, coins=1000, level=5, town_hidden=0, rps_wins=0 WHERE username IN ('sprout','bloom')"; dbx "UPDATE settings SET value='100000' WHERE name='event_chance'"
login() { rm -f $1; curl -s -c $1 -b $1 $BASE/login.php > /tmp/s.html; curl -s -c $1 -b $1 -X POST $BASE/login.php --data-urlencode "csrf=$(csrf /tmp/s.html)" -d username=$2 -d 'password=TestPass123!' -o /dev/null; }
A=/tmp/soc-a; B=/tmp/soc-b; login $A sprout; login $B bloom
HERE=$(db "SELECT location FROM users WHERE username='sprout'"); GREEN=$(db "SELECT id FROM town_spots WHERE region='$HERE' AND kind='green'"); BOARD=$(db "SELECT id FROM town_spots WHERE region='$HERE' AND kind='board'")
SID=$(db "SELECT id FROM users WHERE username='sprout'"); BID=$(db "SELECT id FROM users WHERE username='bloom'")
out() { grep -oE 'class="(pztitle|pzbig)">[^<]*|flash (ok|err)">[^<]*|class="notice[^"]*">[^<]*' /tmp/s.html | sed 's/.*">//' | tr '\n' ' ' | cut -c1-200; grep -oE '<li>[^<]*' /tmp/s.html | sed 's/<li>//' | tr '\n' ',' | cut -c1-120; echo; }
do_() { local ck=$1; shift; curl -s -b $ck -c $ck "$BASE/town.php?spot=$GREEN" > /tmp/s.html; curl -s -b $ck -c $ck -X POST $BASE/town.php --data-urlencode "csrf=$(csrf /tmp/s.html)" -d spot=$GREEN "$@" -o /dev/null; curl -s -b $ck -c $ck "$BASE/town.php?spot=$GREEN" > /tmp/s.html; out; }
echo "== both on the Green"; curl -s -b $A -c $A "$BASE/town.php?spot=$GREEN" -o /dev/null; curl -s -b $B -c $B "$BASE/town.php?spot=$GREEN" > /tmp/s.html; echo "bloom sees: $(grep -oE 'class="gnomerow">.{0,400}' /tmp/s.html | grep -oE '<b>[^<]*</b>' | head -2 | tr '\n' ' ')"
curl -s -b $B "$BASE/town.php" | grep -oE 'gcount">[^<]*'
echo "== wave"; echo -n "  first: "; do_ $B -d do=wave -d to=$SID; echo -n "  again: "; do_ $B -d do=wave -d to=$SID
curl -s -b $A -c $A "$BASE/index.php" > /tmp/s.html; echo "  sprout's notice: $(grep -oE '👋[^<]*' /tmp/s.html | head -1)"
echo "== bench"; echo -n "  bloom: "; do_ $B -d do=bench -d to=$SID; echo "  energy: $(db "SELECT username, energy FROM users WHERE username IN ('sprout','bloom')" | tr '\n' ' ')"; echo -n "  sprout: "; do_ $A -d do=bench -d to=$BID
echo "== snack"; FOOD=$(db "SELECT id FROM items WHERE category='food' AND tradable=1 LIMIT 1"); dbx "INSERT INTO user_items (user_id,item_id,qty) VALUES ($BID,$FOOD,2)"
dbx "UPDATE users SET level=1 WHERE id=$BID"; echo -n "  level 1: "; do_ $B -d do=snack -d to=$SID -d item_id=$FOOD; dbx "UPDATE users SET level=5 WHERE id=$BID"
echo -n "  level 5: "; do_ $B -d do=snack -d to=$SID -d item_id=$FOOD; echo "  sprout has: $(db "SELECT qty FROM user_items WHERE user_id=$SID AND item_id=$FOOD")"
echo -n "  again: "; do_ $B -d do=snack -d to=$SID -d item_id=$FOOD
echo "== rock-paper-trowel"; echo -n "  challenge: "; do_ $B -d do=rps -d to=$SID -d move=rock; echo -n "  second: "; do_ $B -d do=rps -d to=$SID -d move=paper
curl -s -b $A -c $A "$BASE/town.php?spot=$GREEN" > /tmp/s.html; echo "  sprout sees: $(grep -oE 'evtitle">[^<]*' /tmp/s.html)"; G=$(grep -o 'name="game" value="[0-9]*"' /tmp/s.html | head -1 | sed 's/.*value="//; s/"//')
curl -s -b $A -c $A -X POST $BASE/town.php --data-urlencode "csrf=$(csrf /tmp/s.html)" -d do=rps_play -d game=$G -d move=paper -d spot=$GREEN -o /dev/null; curl -s -b $A -c $A "$BASE/town.php?spot=$GREEN" > /tmp/s.html; echo -n "  result: "; out
echo "  wins: $(db "SELECT username, rps_wins FROM users WHERE username IN ('sprout','bloom')" | tr '\n' ' ')"; echo -n "  replay: "; curl -s -b $A -c $A -X POST $BASE/town.php --data-urlencode "csrf=$(csrf /tmp/s.html)" -d do=rps_play -d game=$G -d move=rock -d spot=$GREEN -o /dev/null; curl -s -b $A -c $A "$BASE/town.php?spot=$GREEN" > /tmp/s.html; out
echo "== wandered off"; dbx "UPDATE users SET town_seen = datetime('now','-30 minutes') WHERE id=$SID"; echo -n "  "; do_ $B -d do=wave -d to=$SID
echo "== hidden"; curl -s -b $A -c $A "$BASE/account.php" > /tmp/s.html; curl -s -b $A -c $A -X POST $BASE/account.php --data-urlencode "csrf=$(csrf /tmp/s.html)" -d do=privacy -d town_hidden=1 -o /dev/null; echo "  flag: $(db "SELECT town_hidden FROM users WHERE id=$SID")"
curl -s -b $A -c $A "$BASE/town.php?spot=$GREEN" -o /dev/null; curl -s -b $B -c $B "$BASE/town.php?spot=$GREEN" > /tmp/s.html; echo "  bloom sees sprout: $(grep -c 'Bramble' /tmp/s.html)"; echo -n "  wave: "; do_ $B -d do=wave -d to=$SID
echo "== other town's place"; OTHER=$(db "SELECT id FROM town_spots WHERE region<>'$HERE' AND region<>'Mossbottom' AND kind='green' LIMIT 1"); dbx "UPDATE users SET town_hidden=0 WHERE id=$SID"
curl -s -b $B -c $B -X POST $BASE/town.php --data-urlencode "csrf=$(csrf /tmp/s.html)" -d do=wave -d to=$SID -d spot=$OTHER -o /dev/null; curl -s -b $B "$BASE/town.php" | grep -oE 'flash err">[^<]*'
echo "== favours"; curl -s -b $A -c $A "$BASE/town.php?spot=$BOARD" > /tmp/s.html; echo "  before: $(grep -oE 'favours">.{0,0}|Nothing for you yet' /tmp/s.html | head -1)"
NPC=$(db "SELECT n.id FROM npcs n JOIN town_spots t ON t.id=n.fav_spot_id WHERE t.region='$HERE' LIMIT 1"); dbx "INSERT OR REPLACE INTO npc_friends (user_id,npc_id,points,talks,gifts,known) VALUES ($SID,$NPC,25,0,0,'[]')"
curl -s -b $A -c $A "$BASE/town.php?spot=$BOARD" > /tmp/s.html; ASK=$(grep -oE 'Could you bring me [0-9]+ × [^?]*' /tmp/s.html | head -1); echo "  ask: $ASK"
QTY=$(echo "$ASK" | grep -oE '[0-9]+' | head -1); NAME=$(echo "$ASK" | sed 's/.*× //'); IID=$(db "SELECT id FROM items WHERE name='$NAME'"); echo -n "  without items: "
curl -s -b $A -c $A -X POST $BASE/town.php --data-urlencode "csrf=$(csrf /tmp/s.html)" -d do=favour -d npc=$NPC -d spot=$BOARD -o /dev/null; curl -s -b $A -c $A "$BASE/town.php?spot=$BOARD" > /tmp/s.html; out
dbx "INSERT OR IGNORE INTO user_items (user_id,item_id,qty) VALUES ($SID,$IID,0)"; dbx "UPDATE user_items SET qty=$QTY WHERE user_id=$SID AND item_id=$IID"; echo -n "  with items: "
curl -s -b $A -c $A -X POST $BASE/town.php --data-urlencode "csrf=$(csrf /tmp/s.html)" -d do=favour -d npc=$NPC -d spot=$BOARD -o /dev/null; curl -s -b $A -c $A "$BASE/town.php?spot=$BOARD" > /tmp/s.html; out; echo "  board says: $(grep -oE 'Done this week' /tmp/s.html | head -1)"
dbx "UPDATE user_items SET qty=qty+$QTY WHERE user_id=$SID AND item_id=$IID"; echo -n "  again: "; curl -s -b $A -c $A -X POST $BASE/town.php --data-urlencode "csrf=$(csrf /tmp/s.html)" -d do=favour -d npc=$NPC -d spot=$BOARD -o /dev/null; curl -s -b $A -c $A "$BASE/town.php?spot=$BOARD" > /tmp/s.html; out
echo "== php errors"; grep -iE 'fatal|warning|notice|deprecated' /tmp/soc-php.log || echo "(none)"
