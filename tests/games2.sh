GAME=$1; PORT=$2; ROUTER=$3; BASE=http://127.0.0.1:$PORT
php -d session.save_path=/tmp -S 127.0.0.1:$PORT -t $GAME $ROUTER >/tmp/g2-php.log 2>&1 & PID=$!; sleep 1
trap "kill $PID 2>/dev/null" EXIT
csrf() { grep -o 'name="csrf" value="[^"]*"' "$1" | head -1 | sed 's/.*value="\([^"]*\)".*/\1/'; }
db() { php -r '$p=new PDO("sqlite:'$GAME'/data/game.sqlite"); foreach($p->query($argv[1])->fetchAll(PDO::FETCH_NUM) as $r) echo implode(" | ",$r),"\n";' "$1"; }
dbx() { php -r '$p=new PDO("sqlite:'$GAME'/data/game.sqlite"); $p->exec($argv[1]);' "$1"; }
C=/tmp/g2-ck; rm -f $C
curl -s -c $C -b $C $BASE/login.php > /tmp/g.html; curl -s -c $C -b $C -X POST $BASE/login.php --data-urlencode "csrf=$(csrf /tmp/g.html)" -d username=sprout -d 'password=TestPass123!' -o /dev/null
gp() { local pg=$1; shift; curl -s -c $C -b $C "$BASE/$pg" > /tmp/g0.html; curl -s -c $C -b $C -X POST "$BASE/$pg" --data-urlencode "csrf=$(csrf /tmp/g0.html)" "$@" -o /dev/null; curl -s -c $C -b $C "$BASE/$pg" > /tmp/g.html; grep -oE 'flash (ok|err)">[^<]*' /tmp/g.html | head -2; }
UID_=$(db "SELECT id FROM users WHERE username='sprout'")
echo "== memory: perfect easy game"; C0=$(db "SELECT coins FROM users WHERE id=$UID_"); gp memory.php -d do=start -d mode=easy
echo "face-down buttons: $(grep -c 'class="card down"' /tmp/g.html)  leaks: $(grep -c '🌽\|🥕\|🍅' /tmp/g.html)"
PAIRS=$(php -r '$p=new PDO("sqlite:'$GAME'/data/game.sqlite"); $s=json_decode($p->query("SELECT state FROM game_state WHERE game=\"memory\"")->fetchColumn(),true); $seen=[]; foreach($s["cards"] as $i=>$f){ if(isset($seen[$f])) echo $seen[$f]," ",$i,"\n"; else $seen[$f]=$i; }')
echo "$PAIRS" | head -7 | while read a b; do gp memory.php -d do=flip -d card=$a >/dev/null; gp memory.php -d do=flip -d card=$b >/dev/null; done
echo "-- flip a matched card:"; A1=$(echo "$PAIRS" | head -1 | cut -d' ' -f1); gp memory.php -d do=flip -d card=$A1
L=$(echo "$PAIRS" | tail -1); gp memory.php -d do=flip -d card=${L% *} >/dev/null; gp memory.php -d do=flip -d card=${L#* }
echo "coins $C0 -> $(db "SELECT coins FROM users WHERE id=$UID_")"
echo "== memory: hard with a miss"; gp memory.php -d do=start -d mode=hard >/dev/null
P2=$(php -r '$p=new PDO("sqlite:'$GAME'/data/game.sqlite"); $s=json_decode($p->query("SELECT state FROM game_state WHERE game=\"memory\"")->fetchColumn(),true); $c=$s["cards"]; for($j=1;$j<36;$j++) if($c[$j]!==$c[0]) { echo "0 $j"; break; }')
gp memory.php -d do=flip -d card=${P2% *} >/dev/null; gp memory.php -d do=flip -d card=${P2#* } >/dev/null; echo "after miss, shown cards up: $(grep -c 'card up' /tmp/g.html) miss-class: $(grep -c ' miss' /tmp/g.html)"
gp memory.php -d do=quit; gp memory.php -d do=start -d mode=easy >/dev/null; gp memory.php -d do=quit >/dev/null; gp memory.php -d do=start -d mode=easy
echo "== race"; gp race.php -d snail=9 -d amount=10; gp race.php -d snail=0 -d amount=999; C1=$(db "SELECT coins FROM users WHERE id=$UID_")
gp race.php -d snail=4 -d amount=20; gp race.php -d snail=1 -d amount=20; echo "coins $C1 -> $(db "SELECT coins FROM users WHERE id=$UID_")"
echo "-- pretend the race has run"; dbx "UPDATE snail_bets SET race='$(date -u +%Y%m%d%H)'"; RACE=$(db "SELECT race FROM snail_bets LIMIT 1")
curl -s -b $C $BASE/race.php > /tmp/g.html; db "SELECT 'bet paid='||paid||' winnings='||winnings FROM snail_bets"; grep -oE '📬[^<]*' /tmp/g.html | head -2
grep -oE '<li class="snail-[a-z]+">[^<]*' /tmp/g.html | head -1
curl -s -b $C $BASE/games.php > /tmp/g.html; echo "hub cards: $(grep -c '<a class="gtile' /tmp/g.html)"   # v0.8.2/v1.5.0: the hub has tabs (games / contests / practice); one gtile per game on the games tab
curl -s -b $C "$BASE/games.php?tab=contests" > /tmp/g.html; echo "contest cards: $(grep -c 'class="box ccard' /tmp/g.html)"
curl -s -b $C "$BASE/games.php?tab=practice" > /tmp/g.html; echo "practice tab: $(grep -c '🎯 Tool game practice' /tmp/g.html)"
echo "== php log"; grep -iE 'fatal|warning|notice|deprecated' /tmp/g2-php.log || echo "(none)"
