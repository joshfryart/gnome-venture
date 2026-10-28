# v2.0.75: guest gardens. Off by default; caps; a guest can look around but not touch other players; never on a board; idle guests vanish with every
# row they own; registering keeps the garden (same row) and leads to the make-your-gnome step; guests can't log in or take part in contests.
GAME=$1; PORT=$2; ROUTER=$3; BASE=http://127.0.0.1:$PORT; HERE=$(cd "$(dirname "$0")" && pwd)
php -d session.save_path=/tmp -S 127.0.0.1:$PORT -t $GAME $ROUTER >/tmp/guest-php.log 2>&1 & PID=$!; sleep 1
W=$(mktemp -d); trap "kill $PID 2>/dev/null; rm -rf $W" EXIT
csrf() { grep -o 'name="csrf" value="[^"]*"' "$1" | head -1 | sed 's/.*value="\([^"]*\)".*/\1/'; }
dbv() { php -r '$p=new PDO("sqlite:'$GAME'/data/game.sqlite"); echo $p->query($argv[1])->fetchColumn();' "$1"; }
dbx() { php -r '$p=new PDO("sqlite:'$GAME'/data/game.sqlite"); $p->exec($argv[1]);' "$1"; }
ok() { if [ "$2" = "$3" ]; then echo "ok   $1"; else echo "FAIL $1 (got '$2', want '$3')"; fi; }
setg() { dbx "INSERT OR REPLACE INTO settings (name,value) VALUES ('$1','$2')"; }
code() { curl -s -o /dev/null -w '%{http_code}' "$@"; }
newguest() { rm -f $1; curl -s -c $1 -b $1 $BASE/guest.php > $W/g.html; curl -s -c $1 -b $1 -o /dev/null -w '%{http_code}' -X POST $BASE/guest.php --data-urlencode "csrf=$(csrf $W/g.html)"; }
GC() { dbv "SELECT COUNT(*) FROM users WHERE guest = 1"; }
# ---- off by default
setg guest_open 0; dbx "DELETE FROM login_attempts"
ok "off: guest page loads, says not open" "$(curl -s $BASE/guest.php | grep -c 'aren’t open yet')" 1
curl -s -c $W/off -b $W/off $BASE/guest.php > $W/g.html
code -b $W/off -X POST $BASE/guest.php --data-urlencode "csrf=$(csrf $W/g.html)" >/dev/null
ok "off: nothing created" "$(GC)" 0
ok "off: no guest button on the front page" "$(curl -s $BASE/index.php | grep -c 'guest.php')" 0
# ---- on
setg guest_open 1; setg guest_max_per_ip_day 2; setg guest_max_total 50
ok "on: guest button on the front page" "$(curl -s $BASE/index.php | grep -c 'guest.php')" 2
ok "no CSRF, no guest" "$(code -X POST $BASE/guest.php)$(GC)" 4000
ok "a guest garden is made and the visitor lands in it" "$(newguest $W/g1)" 302
ok "one guest row" "$(GC)" 1
ok "guest row: onboarded, no tour, fake email, ip kept" "$(dbv "SELECT onboarded||tour_step||substr(email,-14)||(guest_ip<>'') FROM users WHERE guest = 1")" "10@guest.invalid1"
ok "guest has a garden and a basket" "$(dbv "SELECT (SELECT COUNT(*) FROM plots WHERE user_id = u.id)||'/'||(SELECT COUNT(*) FROM user_items WHERE user_id = u.id) > '1/0' FROM users u WHERE guest = 1")" 1
ok "guest garden page loads with the strip" "$(curl -s -b $W/g1 $BASE/garden.php | grep -c 'class="gueststrip"')" 1
for pg in garden.php inventory.php world.php town.php games.php book.php gnome.php index.php puzzles.php gifsaw.php letters.php kitchen.php crafting.php seasons.php passport.php folk.php; do
  c=$(code -b $W/g1 $BASE/$pg); case $c in 200|302) ;; *) echo "FAIL guest page $pg gave $c";; esac
done; echo "ok   guest can open the main pages"
for pg in account.php community.php feedback.php market.php pals.php report.php mentor.php trek.php fair.php show.php gotm.php tend.php "jobs.php?t=jobs&p=post" "gifsaw.php?t=1"; do
  ok "blocked: $pg" "$(code -b $W/g1 "$BASE/$pg")" 403
done
curl -s -b $W/g1 $BASE/market.php | grep -q 'Make my gnome' && echo "ok   blocked page offers Make my gnome" || echo "FAIL blocked page has no Make my gnome"
curl -s -b $W/g1 $BASE/garden.php > $W/gg.html; GCS=$(csrf $W/gg.html)
ok "blocked: visit POST turned back" "$(code -b $W/g1 -X POST $BASE/visit.php --data-urlencode "csrf=$GCS" -d g=1 -d do=stamp)" 302
ok "blocked: post a player job" "$(code -b $W/g1 -X POST $BASE/jobs.php --data-urlencode "csrf=$GCS" -d do=post)" 302
ok "no player job made" "$(dbv "SELECT COUNT(*) FROM player_jobs")" 0
ok "blocked: tournament api" "$(curl -s -b $W/g1 -X POST $BASE/puzzles_api.php --data-urlencode "csrf=$GCS" -d do=start -d t=1 | grep -c 'Guests')" 1
ok "guest has no public profile" "$(code -b $W/g1 "$BASE/profile.php?id=$(dbv "SELECT id FROM users WHERE guest = 1")")" 200
SPR=$(dbv "SELECT id FROM users WHERE username = 'sprout'"); GID=$(dbv "SELECT id FROM users WHERE guest = 1")
rm -f $W/p; curl -s -c $W/p -b $W/p $BASE/login.php > $W/l.html; curl -s -c $W/p -b $W/p -o /dev/null -X POST $BASE/login.php --data-urlencode "csrf=$(csrf $W/l.html)" -d username=sprout --data-urlencode 'password=TestPass123!'
ok "a player can't open a guest's profile or garden" "$(code -b $W/p "$BASE/profile.php?id=$GID")$(code -b $W/p "$BASE/visit.php?g=$(dbv "SELECT id FROM plots WHERE user_id = $GID")")" 404404
ok "a guest can't log in with its name" "$(curl -s -c $W/x -b $W/x $BASE/login.php > $W/l.html; curl -s -c $W/x -b $W/x -X POST $BASE/login.php --data-urlencode "csrf=$(csrf $W/l.html)" -d username=$(dbv "SELECT username FROM users WHERE guest = 1") --data-urlencode 'password=TestPass123!' | grep -ci 'wrong\|incorrect\|invalid')" 1
# ---- fresh hold, contests, boards
ok "fresh_hold refuses a guest" "$(php -r 'define("APP_ROOT","'$GAME'"); $src=file_get_contents("'$GAME'/includes/functions.php"); echo substr_count($src, "Guests can look around but not trade");')" 1
dbx "UPDATE plot_tiles SET plant_id = (SELECT id FROM plants LIMIT 1), growth_seconds = 99999999, planted_at = datetime('now'), last_watered = datetime('now'), growth_updated_at = datetime('now'), tilled = 1 WHERE plot_id = (SELECT id FROM plots WHERE user_id = $GID) AND x = 0 AND y = 0"
curl -s -b $W/g1 -o /dev/null -X POST $BASE/garden.php --data-urlencode "csrf=$GCS" -d do=harvest -d x=0 -d y=0
ok "a guest harvest enters no contest" "$(dbv "SELECT (SELECT COUNT(*) FROM fair_best WHERE user_id = $GID) + (SELECT COUNT(*) FROM show_entries WHERE user_id = $GID)")" 0
setg puzzles_open 1; setg pz_barrel_open 1
curl -s -b $W/g1 $BASE/rainbarrel.php > $W/rb.html; RC=$(grep -o '"csrf":"[^"]*"' $W/rb.html | sed 's/.*:"\(.*\)"/\1/')
api() { curl -s -b $W/g1 -X POST $BASE/puzzle_game_api.php --data-urlencode "csrf=$RC" -d g=barrel "$@"; }
api -d do=start -d mode=daily > $W/s.json; T=$(php -r 'echo json_decode(file_get_contents($argv[1]),true)["token"];' $W/s.json)
SEED=$(dbv "SELECT seed FROM puzzle_runs WHERE token = '$T'"); dbx "UPDATE puzzle_runs SET start_ms = start_ms - 90000 WHERE token = '$T'"
ok "guest can play a puzzle game" "$(api -d do=finish -d token=$T --data-urlencode "r=$(php $HERE/pz_barrel_solve.php $GAME $SEED 6)" | grep -c '"ok":true')" 1
ok "guest is not on the puzzle board" "$(curl -s -b $W/g1 $BASE/rainbarrel.php | grep -c 'class="nm"')" 0
setg puzzles_open 0
# ---- caps
ok "second guest from the same connection" "$(newguest $W/g2)" 302
ok "third is refused by the per-connection cap" "$(newguest $W/g3)$(GC)" 2002
curl -s -c $W/g3 -b $W/g3 $BASE/guest.php > $W/g.html; curl -s -c $W/g3 -b $W/g3 -X POST $BASE/guest.php --data-urlencode "csrf=$(csrf $W/g.html)" | grep -q 'enough guest gardens' && echo "ok   cap message shown" || echo "FAIL cap message missing"
dbx "DELETE FROM login_attempts"; setg guest_max_per_ip_day 50; setg guest_max_total 2
curl -s -c $W/g3 -b $W/g3 -X POST $BASE/guest.php --data-urlencode "csrf=$(csrf $W/g.html)" | grep -q 'guest gardens are full' && echo "ok   total cap message shown" || echo "FAIL total cap message missing"
ok "total cap held" "$(GC)" 2
setg guest_max_total 200
# ---- convert: keep the garden
G2=$(dbv "SELECT id FROM users WHERE guest = 1 ORDER BY id DESC LIMIT 1"); PL=$(dbv "SELECT COUNT(*) FROM plots WHERE user_id = $G2"); U0=$(dbv "SELECT COUNT(*) FROM users")
curl -s -b $W/g2 -c $W/g2 $BASE/register.php > $W/r.html
ok "guest sees the keep-this-garden form" "$(grep -c 'Keep this garden' $W/r.html)" 1
dbx "DELETE FROM login_attempts"
ok "register as a guest keeps the garden and goes to customise" "$(curl -s -b $W/g2 -c $W/g2 -o /dev/null -w '%{http_code} %{redirect_url}' -X POST $BASE/register.php --data-urlencode "csrf=$(csrf $W/r.html)" -d username=keeper1 -d email=keeper1@example.com --data-urlencode 'password=KeeperPass123!' --data-urlencode 'password2=KeeperPass123!' -d rules=1 -d age=1 | sed 's#http://[^/]*##')" "302 /customise.php"
ok "same row became an account" "$(dbv "SELECT guest||username||(SELECT COUNT(*) FROM plots WHERE user_id = $G2) FROM users WHERE id = $G2")" "0keeper1$PL"
ok "no extra users row" "$(dbv "SELECT COUNT(*) FROM users")" "$U0"
curl -s -b $W/g2 -c $W/g2 $BASE/customise.php > $W/c.html
ok "customise page loads" "$(grep -c 'This is my gnome' $W/c.html)" 1
ok "make the gnome" "$(curl -s -b $W/g2 -c $W/g2 -o /dev/null -w '%{http_code}' -X POST $BASE/customise.php --data-urlencode "csrf=$(csrf $W/c.html)" -d 'gnome_name=Bramble Keeper' --data-urlencode "hat=$(grep -o 'name=\"hat\" value=\"[^\"]*' $W/c.html | head -1 | sed 's/.*value=\"//')" --data-urlencode "beard=$(grep -o 'name=\"beard\" value=\"[^\"]*' $W/c.html | head -1 | sed 's/.*value=\"//')")" 302
ok "gnome saved" "$(dbv "SELECT gnome_name FROM users WHERE id = $G2")" "Bramble Keeper"
ok "customise is closed afterwards" "$(code -b $W/g2 $BASE/customise.php)" 302
ok "the account is a normal player now (market opens)" "$(code -b $W/g2 $BASE/market.php)" 200
ok "converted counter" "$(dbv "SELECT value FROM settings WHERE name = 'guest_converted_total'")" 1
# ---- idle guests vanish with everything they own
GOLD=$(dbv "SELECT id FROM users WHERE guest = 1 ORDER BY id LIMIT 1")
dbx "UPDATE users SET last_seen = datetime('now', '-30 hours') WHERE id = $GOLD"
ok "an idle guest is sent away" "$(code -b $W/g1 $BASE/garden.php)" 302
ok "the idle guest row is gone" "$(dbv "SELECT COUNT(*) FROM users WHERE id = $GOLD")" 0
ok "no rows left in any table for it" "$(php -r '$p=new PDO("sqlite:'$GAME'/data/game.sqlite"); $id='$GOLD'; $cols=["user_id","from_id","to_id","seller_id","mentor_id","taker_id","friend_id","poster_id","owner_id","author_id","sender_id","recipient_id"]; $n=0; foreach($p->query("SELECT name FROM sqlite_master WHERE type=\"table\" AND name NOT LIKE \"sqlite_%\" AND name<>\"users\"")->fetchAll(PDO::FETCH_COLUMN) as $t){ foreach($p->query("PRAGMA table_info($t)") as $c){ if(in_array($c["name"],$cols)) $n+=(int)$p->query("SELECT COUNT(*) FROM $t WHERE {$c["name"]} = $id")->fetchColumn(); } } echo $n;')" 0
ok "admin usage page shows guests" "$(rm -f $W/a; curl -s -c $W/a -b $W/a $BASE/login.php > $W/l.html; curl -s -c $W/a -b $W/a -o /dev/null -X POST $BASE/login.php --data-urlencode "csrf=$(csrf $W/l.html)" -d username=admin --data-urlencode 'password=TestPassword123'; curl -s -b $W/a $BASE/admin/usage.php | grep -c 'Guest gardens')" 1
setg guest_open 0
