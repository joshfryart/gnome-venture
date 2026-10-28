# v2.0.68: puzzle tournaments. Gated by puzzles_open + puzzles_tournaments; server-clock runs with single-use tokens; too fast / too few drops / too late
# are rejected; 10 goes a day; admin void with a reason; top-3 flag; settling gives places and cosmetic badges (results + profile).
GAME=$1; PORT=$2; ROUTER=$3; BASE=http://127.0.0.1:$PORT
php -d session.save_path=/tmp -S 127.0.0.1:$PORT -t $GAME $ROUTER >/tmp/pzt-php.log 2>&1 & PID=$!; sleep 1
W=$(mktemp -d); trap "kill $PID 2>/dev/null; rm -rf $W" EXIT
csrf() { grep -o 'name="csrf" value="[^"]*"' "$1" | head -1 | sed 's/.*value="\([^"]*\)".*/\1/'; }
dbv() { php -r '$p=new PDO("sqlite:'$GAME'/data/game.sqlite"); echo $p->query($argv[1])->fetchColumn();' "$1"; }
dbx() { php -r '$p=new PDO("sqlite:'$GAME'/data/game.sqlite"); $p->exec($argv[1]);' "$1"; }
login() { rm -f $1; curl -s -c $1 -b $1 $BASE/login.php > $W/l.html; curl -s -c $1 -b $1 -X POST $BASE/login.php --data-urlencode "csrf=$(csrf $W/l.html)" -d username=$2 --data-urlencode "password=$3" -o /dev/null; }
ok() { if [ "$2" = "$3" ]; then echo "ok   $1"; else echo "FAIL $1 (got '$2', want '$3')"; fi; }
js() { php -r '$j=json_decode(stream_get_contents(STDIN), true); echo is_array($j) ? var_export($j[$argv[1]] ?? null, true) : "nojson";' "$1"; }
setg() { dbx "INSERT OR REPLACE INTO settings (name,value) VALUES ('$1','$2')"; }
hol() { php -r 'date_default_timezone_set("America/Halifax"); echo date("Y-m-d\TH:i", time() + (int)$argv[1]);' -- "$1"; }
login $W/a admin TestPassword123
login $W/p sprout 'TestPass123!'
setg puzzles_open 1; setg puzzles_tournaments 0
curl -s -b $W/a "$BASE/admin/puzzles.php?tab=tournaments" > $W/t.html; T=$(csrf $W/t.html)
PIC=$(dbv "SELECT id FROM puzzle_pics WHERE slug='sunflower'")
curl -s -b $W/a -o /dev/null -X POST $BASE/admin/puzzles.php --data-urlencode "csrf=$T" -d do=tour_save -d id=0 -d 'title=Sunflower Sprint' -d pic_id=$PIC -d pieces=24 \
  -d "starts_at=$(hol -3600)" -d "ends_at=$(hol 3600)" -d status=live
TID=$(dbv "SELECT id FROM puzzle_tournaments WHERE title='Sunflower Sprint'")
ok "admin made a live tournament" "$(dbv "SELECT status FROM puzzle_tournaments WHERE id=$TID")" live
ok "bad times refused" "$(curl -s -b $W/a -o /dev/null -w '%{http_code}' -X POST $BASE/admin/puzzles.php --data-urlencode "csrf=$T" -d do=tour_save -d id=0 -d title=Backwards -d pic_id=$PIC -d pieces=24 -d "starts_at=$(hol 3600)" -d "ends_at=$(hol -3600)" -d status=live; dbv "SELECT COUNT(*) FROM puzzle_tournaments WHERE title='Backwards'")" 3020
ok "setting off: page redirects" "$(curl -s -b $W/p -o /dev/null -w '%{http_code}' "$BASE/puzzles.php?t=$TID")" 302
setg puzzles_open 0; setg puzzles_tournaments 1
ok "puzzles closed: page redirects" "$(curl -s -b $W/p -o /dev/null -w '%{http_code}' "$BASE/puzzles.php?t=$TID")" 302
setg puzzles_open 1
curl -s -b $W/p "$BASE/puzzles.php?t=$TID" > $W/pt.html
ok "player sees the tournament card" "$(grep -c 'id="tstart"' $W/pt.html)" 1
ok "library lists it" "$(curl -s -b $W/p $BASE/puzzles.php | grep -c "puzzles.php?t=$TID")" 1
ok "tournament banner art" "$(grep -c 'cast/tourney-banner.png' $W/pt.html)" 1
C=$(php -r 'preg_match("#id=\"pz-t\">(.*?)</script>#s", file_get_contents($argv[1]), $m); echo json_decode($m[1], true)["csrf"] ?? "";' $W/pt.html)
api() { curl -s -b $W/p -X POST $BASE/puzzles_api.php --data-urlencode "csrf=$C" "$@"; }
ok "GET refused" "$(curl -s -b $W/p -o /dev/null -w '%{http_code}' $BASE/puzzles_api.php)" 405
ok "no CSRF refused" "$(curl -s -b $W/p -o /dev/null -w '%{http_code}' -X POST $BASE/puzzles_api.php -d do=start -d t=$TID)" 400
R=$(api -d do=start -d t=$TID); TK=$(echo "$R" | js token | tr -d "'")
ok "start gives a token" "$(echo $TK | grep -cE '^[a-f0-9]{32}$')" 1
ok "start gives the fixed seed" "$(echo "$R" | js seed)" "$(php -r 'echo crc32("pzt|'$TID'") & 0x7fffffff;')"
TOTAL=$(php -r 'define("APP_ROOT","'$GAME'"); require "'$GAME'/includes/puzzles.php"; $p=new PDO("sqlite:'$GAME'/data/game.sqlite"); $r=$p->query("SELECT w,h FROM puzzle_pics WHERE slug=\"sunflower\"")->fetch(); echo puzzle_grid_total(24,(int)$r[0],(int)$r[1]);')
R=$(api -d do=finish -d token=$TK -d drops=$TOTAL)
ok "instant finish rejected (too fast)" "$(echo "$R" | js rejected)" true
ok "stored as rejected" "$(dbv "SELECT status FROM puzzle_attempts WHERE token='$TK'")" rejected
ok "token is single-use" "$(api -d do=finish -d token=$TK -d drops=$TOTAL | js error | grep -c 'already handed in')" 1
TK=$(api -d do=start -d t=$TID | js token | tr -d "'"); dbx "UPDATE puzzle_attempts SET start_ms = start_ms - 90000 WHERE token='$TK'"
ok "too few drops rejected" "$(api -d do=finish -d token=$TK -d drops=$((TOTAL-2)) | js error | grep -c 'too few pieces')" 1
TK=$(api -d do=start -d t=$TID | js token | tr -d "'"); dbx "UPDATE puzzle_attempts SET start_ms = start_ms - 90000 WHERE token='$TK'"
R=$(api -d do=finish -d token=$TK -d drops=$((TOTAL+5)))
ok "a fair run counts" "$(echo "$R" | js ok)" true
ok "rank 1" "$(echo "$R" | js rank)" 1
ok "time is the server's (~90 s)" "$(dbv "SELECT ms BETWEEN 90000 AND 95000 FROM puzzle_attempts WHERE token='$TK'")" 1
TK2=$(api -d do=start -d t=$TID | js token | tr -d "'"); TK3=$(api -d do=start -d t=$TID | js token | tr -d "'")
ok "a new start voids the open one" "$(dbv "SELECT status || reason FROM puzzle_attempts WHERE token='$TK2'")" voidrestarted
ok "leaderboard shows the best" "$(curl -s -b $W/p "$BASE/puzzles.php?t=$TID" | grep -c '1:3[0-9]\.')" 2
# other gnomes, slower: sprout's 1:30 is under a third of the median, so the admin sees a flag
for k in 1 2 3 4; do
  dbx "INSERT INTO users (username,email,password_hash,created_at,gnome_name) VALUES ('pzbot$k','pz$k@b.local','x','2026-01-01 00:00:00','Bot $k')"
  U=$(dbv "SELECT id FROM users WHERE username='pzbot$k'")
  dbx "INSERT INTO puzzle_attempts (tournament_id,user_id,token,seed,started_at,start_ms,finished_at,ms,drops,status) VALUES ($TID,$U,'$(printf '%032d' $k)',1,'2026-01-01 00:00:00',0,'2026-01-01 00:10:00',$((600000+k*10000)),40,'done')"
done
ok "admin sees the flag" "$(curl -s -b $W/a "$BASE/admin/puzzles.php?tab=tournaments&id=$TID" | grep -c 'under a third of the median')" 1
AID=$(dbv "SELECT id FROM puzzle_attempts WHERE token='$TK'")
curl -s -b $W/a -o /dev/null -X POST $BASE/admin/puzzles.php --data-urlencode "csrf=$T" -d do=void -d attempt=$AID -d reason=
ok "void needs a reason" "$(dbv "SELECT status FROM puzzle_attempts WHERE id=$AID")" done
curl -s -b $W/a -o /dev/null -X POST $BASE/admin/puzzles.php --data-urlencode "csrf=$T" -d do=void -d attempt=$AID -d 'reason=test void'
ok "admin voids with a reason" "$(dbv "SELECT status || ':' || reason FROM puzzle_attempts WHERE id=$AID")" "void:admin: test void"
ok "admin log has the void" "$(dbv "SELECT COUNT(*) FROM admin_log WHERE action='puzzle_void'")" 1
# daily cap
N=$(dbv "SELECT COUNT(*) FROM puzzle_attempts WHERE tournament_id=$TID AND user_id=(SELECT id FROM users WHERE username='sprout')")
for k in $(seq $((N+1)) 10); do api -d do=start -d t=$TID >/dev/null; done
ok "10 goes a day" "$(api -d do=start -d t=$TID | js error | grep -c 'tries today')" 1
# late finish: open run, tournament ended over 10 minutes ago
TK=$(dbv "SELECT token FROM puzzle_attempts WHERE tournament_id=$TID AND status='open' LIMIT 1")
dbx "UPDATE puzzle_attempts SET start_ms = start_ms - 90000 WHERE token='$TK'"
dbx "UPDATE puzzle_tournaments SET ends_at='$(php -r 'echo gmdate("Y-m-d H:i:s", time() - 660);')' WHERE id=$TID"
ok "late finish rejected" "$(api -d do=finish -d token=$TK -d drops=$TOTAL | js error | grep -c 'closed')" 1
# settling (any puzzles page settles): places and badges
curl -s -b $W/p "$BASE/puzzles.php?t=$TID" > $W/res.html
ok "settled" "$(dbv "SELECT status FROM puzzle_tournaments WHERE id=$TID")" settled
ok "places 1-4" "$(dbv "SELECT GROUP_CONCAT(place, ',') FROM (SELECT place FROM puzzle_attempts WHERE tournament_id=$TID AND place IS NOT NULL ORDER BY place)")" "1,2,3,4"
ok "voided run got no place" "$(dbv "SELECT COUNT(*) FROM puzzle_attempts WHERE tournament_id=$TID AND place IS NOT NULL AND user_id=(SELECT id FROM users WHERE username='sprout')")" 0
ok "results show the gold trophy" "$(grep -c 'cast/trophy-gold.png' $W/res.html)" 1
ok "no Start once settled" "$(grep -c 'id="tstart"' $W/res.html)" 0
ok "winner notified" "$(dbv "SELECT COUNT(*) FROM notices WHERE user_id=(SELECT id FROM users WHERE username='pzbot1') AND text LIKE '%placed #1%'")" 1
U1=$(dbv "SELECT id FROM users WHERE username='pzbot1'")
ok "profile shows the trophy" "$(curl -s -b $W/p "$BASE/profile.php?id=$U1&tab=awards" | grep -c 'cast/trophy-gold.png')" 1
ok "settled tournament can't be edited" "$(curl -s -b $W/a -o /dev/null -X POST $BASE/admin/puzzles.php --data-urlencode "csrf=$T" -d do=tour_save -d id=$TID -d title=Changed -d pic_id=$PIC -d pieces=24 -d "starts_at=$(hol -3600)" -d "ends_at=$(hol 3600)" -d status=live; dbv "SELECT title FROM puzzle_tournaments WHERE id=$TID")" "Sunflower Sprint"
setg puzzles_open 0; setg puzzles_tournaments 0
echo "== php log"; grep -iE 'fatal|warning|notice|deprecated' /tmp/pzt-php.log || echo "(none)"
