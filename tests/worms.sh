GAME=$1; PORT=$2; ROUTER=$3; BASE=http://127.0.0.1:$PORT
php -d session.save_path=/tmp -S 127.0.0.1:$PORT -t $GAME $ROUTER >/tmp/wg-php.log 2>&1 & PID=$!; sleep 1
trap "kill $PID 2>/dev/null" EXIT
csrf() { grep -o 'name="csrf" value="[^"]*"' "$1" | head -1 | sed 's/.*value="\([^"]*\)".*/\1/'; }
db() { php -r '$p=new PDO("sqlite:'$GAME'/data/game.sqlite"); foreach($p->query($argv[1])->fetchAll(PDO::FETCH_NUM) as $r) echo implode(" | ",$r),"\n";' "$1"; }
dbx() { php -r '$p=new PDO("sqlite:'$GAME'/data/game.sqlite"); $p->exec($argv[1]);' "$1"; }
C=/tmp/wg-ck; rm -f $C
curl -s -c $C -b $C $BASE/login.php > /tmp/w.html; curl -s -c $C -b $C -X POST $BASE/login.php --data-urlencode "csrf=$(csrf /tmp/w.html)" -d username=sprout -d 'password=TestPass123!' -o /dev/null
wp() { curl -s -c $C -b $C "$BASE/worms.php" > /tmp/w0.html; curl -s -c $C -b $C -X POST "$BASE/worms.php" --data-urlencode "csrf=$(csrf /tmp/w0.html)" "$@" -o /dev/null; curl -s -c $C -b $C "$BASE/worms.php" > /tmp/w.html; grep -oE 'flash (ok|err)">[^<]*' /tmp/w.html | head -2; }
UID_=$(db "SELECT id FROM users WHERE username='sprout'")
echo "== items/recipe"; db "SELECT name||' '||category||' '||effects FROM items WHERE slug='earthworm'"; db "SELECT 'recipe '||name FROM recipes WHERE slug='worm-bin'"
curl -s -b $C $BASE/games.php | grep -oE 'plays? left today|Worm Hunting' | head -2
echo "== dig before start"; wp -d do=dig -d cell=3
C0=$(db "SELECT coins FROM users WHERE id=$UID_"); wp -d do=start
echo "board buttons: $(grep -c 'class="soil"' /tmp/w.html)"
STATE=$(db "SELECT state FROM game_state WHERE user_id=$UID_ AND game='worms'")
php -r '$s=json_decode($argv[1],true); echo "digs ",$s["digs"]," worms ",count(array_filter($s["cells"],fn($c)=>$c==="worm")),"\n";' "$STATE"
echo "-- page must not leak hidden cells:"; grep -c '"cells"\|data-cell' /tmp/w.html
wp -d do=dig -d cell=0; wp -d do=dig -d cell=0; wp -d do=dig -d cell=99
for i in 1 2 3 4 5 6 7 8 9 10 11 12 13 14; do wp -d do=dig -d cell=$i >/dev/null; done; grep -oE 'flash (ok|err)">[^<]*' /tmp/w.html | head -1 | cut -c1-200
db "SELECT 'score row '||score||' day '||day FROM game_scores WHERE user_id=$UID_"; echo "coins $C0 -> $(db "SELECT coins FROM users WHERE id=$UID_"), earthworms $(db "SELECT COALESCE((SELECT qty FROM user_items ui JOIN items i ON i.id=ui.item_id WHERE ui.user_id=$UID_ AND i.slug='earthworm'),0)")"
echo "-- clue check on a fresh board"; wp -d do=start >/dev/null; wp -d do=dig -d cell=14 >/dev/null
php -r '$p=new PDO("sqlite:'$GAME'/data/game.sqlite"); $s=json_decode($p->query("SELECT state FROM game_state WHERE game=\"worms\"")->fetchColumn(),true); $c=$s["cells"]; $n=0; foreach([7,8,9,13,15,19,20,21] as $j) if(in_array($c[$j],["worm","night"])) $n++; echo "clue ",$s["dug"][14]," expected ",$n,"\n";'
wp -d do=stop; wp -d do=start; wp -d do=stop; echo "-- fourth start:"; wp -d do=start
curl -s -b $C $BASE/games.php > /tmp/w.html; echo "hub top list: $(grep -c '<ol class="top">' /tmp/w.html)"
echo "== php errors"; grep -iE 'fatal|warning|notice|deprecated' /tmp/wg-php.log || echo "(none)"
