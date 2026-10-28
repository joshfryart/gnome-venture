# v2.0.71: puzzle games (Rain Barrel): gates, dealt by the server (no answer sent), wrong answer / reused token / too fast refused, a double finish pays once,
# practice pays nothing, hints capped, daily reward paid once a day.
GAME=$1; PORT=$2; ROUTER=$3; BASE=http://127.0.0.1:$PORT; HERE=$(cd "$(dirname "$0")" && pwd)
php -d session.save_path=/tmp -S 127.0.0.1:$PORT -t $GAME $ROUTER >/tmp/pzd-php.log 2>&1 & PID=$!; sleep 1
W=$(mktemp -d); trap "kill $PID 2>/dev/null; rm -rf $W" EXIT
csrf() { grep -o 'name="csrf" value="[^"]*"' "$1" | head -1 | sed 's/.*value="\([^"]*\)".*/\1/'; }
dbv() { php -r '$p=new PDO("sqlite:'$GAME'/data/game.sqlite"); echo $p->query($argv[1])->fetchColumn();' "$1"; }
dbx() { php -r '$p=new PDO("sqlite:'$GAME'/data/game.sqlite"); $p->exec($argv[1]);' "$1"; }
login() { rm -f $1; curl -s -c $1 -b $1 $BASE/login.php > $W/l.html; curl -s -c $1 -b $1 -X POST $BASE/login.php --data-urlencode "csrf=$(csrf $W/l.html)" -d username=$2 --data-urlencode "password=$3" -o /dev/null; }
ok() { if [ "$2" = "$3" ]; then echo "ok   $1"; else echo "FAIL $1 (got '$2', want '$3')"; fi; }
js() { php -r '$j=json_decode(stream_get_contents(STDIN), true); echo is_array($j) ? var_export($j[$argv[1]] ?? null, true) : "nojson";' "$1"; }
setg() { dbx "INSERT OR REPLACE INTO settings (name,value) VALUES ('$1','$2')"; }
php "$HERE/pz_barrel.php" $GAME   # generator: 1095 puzzles valid, trees, same seed same puzzle
login $W/p sprout 'TestPass123!'
curl -s -b $W/p $BASE/index.php > $W/i.html; C=$(csrf $W/i.html); [ -n "$C" ] || { curl -s -b $W/p $BASE/games.php > $W/i.html; C=$(csrf $W/i.html); }
api() { curl -s -b $W/p -X POST $BASE/puzzle_game_api.php --data-urlencode "csrf=$C" -d g=barrel "$@"; }
setg puzzles_open 0; setg pz_barrel_open 0
ok "closed: page redirects" "$(curl -s -b $W/p -o /dev/null -w '%{http_code}' $BASE/rainbarrel.php)" 302
ok "closed: api refuses" "$(api -d do=start -d mode=daily | js ok)" false
setg puzzles_open 1
ok "puzzles open, game off: still closed" "$(curl -s -b $W/p -o /dev/null -w '%{http_code}' $BASE/rainbarrel.php)" 302
setg pz_barrel_open 1
ok "open: page loads" "$(curl -s -b $W/p -o /dev/null -w '%{http_code}' $BASE/rainbarrel.php)" 200
curl -s -b $W/p $BASE/rainbarrel.php > $W/rb.html
ok "open: rainbarrel.js wired" "$(grep -c 'assets/rainbarrel.js' $W/rb.html)" 1
ok "hub lists the game" "$(curl -s -b $W/p $BASE/puzzles.php | grep -c 'rainbarrel.php')" 1
ok "GET refused" "$(curl -s -b $W/p -o /dev/null -w '%{http_code}' $BASE/puzzle_game_api.php)" 405
ok "no CSRF refused" "$(curl -s -b $W/p -o /dev/null -w '%{http_code}' -X POST $BASE/puzzle_game_api.php -d g=barrel -d do=start)" 400
ok "unknown game refused" "$(curl -s -b $W/p -X POST $BASE/puzzle_game_api.php --data-urlencode "csrf=$C" -d g=nope -d do=start | js ok)" false
dbx "UPDATE users SET coins = 1000 WHERE username = 'sprout'"
coins() { dbv "SELECT coins FROM users WHERE username = 'sprout'"; }
ZERO=$(php -r 'echo json_encode(array_fill(0,36,0));')
# start the daily
api -d do=start -d mode=daily > $W/s1.json
T1=$(js token < $W/s1.json | tr -d "'")
ok "daily start ok" "$(js ok < $W/s1.json)" true
ok "6x6 dealt, 36 tiles" "$(php -r '$j=json_decode(file_get_contents($argv[1]),true); echo count($j["tiles"]);' $W/s1.json)" 36
ok "the answer is not sent" "$(grep -c '"sol"' $W/s1.json)" 0
SEED=$(dbv "SELECT seed FROM puzzle_runs WHERE token = '$T1'")
ok "daily seed is the day's seed (same for everyone)" "$(php -r 'echo crc32("pz|barrel|".$argv[1]."|6") & 0xffffffff;' "$(php -r 'date_default_timezone_set("America/Halifax"); echo date("Y-m-d");')")" "$SEED"
SOLVE=$(php "$HERE/pz_barrel_solve.php" $GAME $SEED 6)
ok "a wrong answer is refused" "$(api -d do=finish -d token=$T1 --data-urlencode "r=$ZERO" | js retry)" true
ok "wrong answer leaves the run open" "$(dbv "SELECT status FROM puzzle_runs WHERE token = '$T1'")" open
ok "too fast is refused" "$(api -d do=finish -d token=$T1 --data-urlencode "r=$SOLVE" | js rejected)" true
ok "too fast run is marked" "$(dbv "SELECT status FROM puzzle_runs WHERE token = '$T1'")" reject
ok "no reward for a rejected run" "$(coins)" 1000
ok "a rejected run can't be handed in again" "$(api -d do=finish -d token=$T1 --data-urlencode "r=$SOLVE" | js ok)" false
# a real run: backdate the start
api -d do=start -d mode=daily > $W/s2.json; T2=$(js token < $W/s2.json | tr -d "'")
ok "a new start voids the open one" "$(dbv "SELECT COUNT(*) FROM puzzle_runs WHERE status = 'open'")" 1
dbx "UPDATE puzzle_runs SET start_ms = start_ms - 90000 WHERE token = '$T2'"
ok "bad r (wrong length) refused" "$(api -d do=finish -d token=$T2 --data-urlencode 'r=[0,1]' | js ok)" false
ok "bad r (value 9) refused" "$(api -d do=finish -d token=$T2 --data-urlencode "r=$(php -r 'echo json_encode(array_fill(0,36,9));')" | js ok)" false
api -d do=finish -d token=$T2 --data-urlencode "r=$SOLVE" > $W/f2.json
ok "solved: counts" "$(js ok < $W/f2.json)" true
ok "daily reward paid" "$([ $(coins) -gt 1000 ] && echo yes)" yes
C1=$(coins)
ok "one daily win row" "$(dbv "SELECT COUNT(*) FROM puzzle_wins WHERE game = 'barrel'")" 1
ok "reused token refused" "$(api -d do=finish -d token=$T2 --data-urlencode "r=$SOLVE" | js ok)" false
ok "coins unchanged by the retry" "$(coins)" $C1
# a second daily go: no second reward
api -d do=start -d mode=daily > $W/s3.json; T3=$(js token < $W/s3.json | tr -d "'")
dbx "UPDATE puzzle_runs SET start_ms = start_ms - 90000 WHERE token = '$T3'"
api -d do=finish -d token=$T3 --data-urlencode "r=$SOLVE" > $W/f3.json
ok "second daily go counts" "$(js ok < $W/f3.json)" true
ok "no second reward" "$(coins)" $C1
ok "still one win row" "$(dbv "SELECT COUNT(*) FROM puzzle_wins WHERE game = 'barrel'")" 1
ok "page shows done today" "$(curl -s -b $W/p $BASE/rainbarrel.php | grep -c 'Today: done')" 1
# double finish in parallel: pays at most once (use a fresh day row so a reward is possible)
dbx "DELETE FROM puzzle_wins"
api -d do=start -d mode=daily > $W/s4.json; T4=$(js token < $W/s4.json | tr -d "'")
dbx "UPDATE puzzle_runs SET start_ms = start_ms - 90000 WHERE token = '$T4'"
C2=$(coins)
PIDS=""; for i in 1 2 3; do api -d do=finish -d token=$T4 --data-urlencode "r=$SOLVE" > $W/par$i.json & PIDS="$PIDS $!"; done; wait $PIDS
ok "parallel finish: exactly one succeeds" "$(cat $W/par*.json | grep -c '"ok":true')" 1
ok "parallel finish: paid once" "$(dbv "SELECT COUNT(*) FROM puzzle_wins WHERE game = 'barrel'")" 1
# practice pays nothing
C3=$(coins)
api -d do=start -d mode=practice -d size=5 > $W/s5.json; T5=$(js token < $W/s5.json | tr -d "'")
ok "practice 5x5 dealt" "$(php -r '$j=json_decode(file_get_contents($argv[1]),true); echo count($j["tiles"]);' $W/s5.json)" 25
S5=$(dbv "SELECT seed FROM puzzle_runs WHERE token = '$T5'")
dbx "UPDATE puzzle_runs SET start_ms = start_ms - 90000 WHERE token = '$T5'"
ok "practice solved" "$(api -d do=finish -d token=$T5 --data-urlencode "r=$(php $HERE/pz_barrel_solve.php $GAME $S5 5)" | js ok)" true
ok "practice pays nothing" "$(coins)" $C3
ok "practice leaves wins alone" "$(dbv "SELECT COUNT(*) FROM puzzle_wins WHERE game = 'barrel'")" 1
# hints
api -d do=start -d mode=daily > $W/s6.json; T6=$(js token < $W/s6.json | tr -d "'")
for i in 1 2 3; do api -d do=hint -d token=$T6 --data-urlencode "r=$ZERO" > $W/h$i.json; done
ok "hint gives a tile" "$(js cell < $W/h1.json | grep -c '^[0-9]')" 1
ok "three hints counted" "$(dbv "SELECT hints FROM puzzle_runs WHERE token = '$T6'")" 3
ok "fourth hint refused" "$(api -d do=hint -d token=$T6 --data-urlencode "r=$ZERO" | js ok)" false
ok "someone else's token refused" "$(curl -s -b $W/p -X POST $BASE/puzzle_game_api.php --data-urlencode "csrf=$C" -d g=barrel -d do=finish -d token=00000000000000000000000000000000 --data-urlencode "r=$SOLVE" | js ok)" false
# caps
dbx "UPDATE puzzle_runs SET day = day"  # no-op keeps sqlite happy
for i in $(seq 1 20); do api -d do=start -d mode=daily >/dev/null; done
ok "daily starts are capped" "$(api -d do=start -d mode=daily | js ok)" false
setg puzzles_open 0; setg pz_barrel_open 0
