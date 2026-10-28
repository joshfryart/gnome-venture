# v2.0.73: logged-out front page: Jeff's tour. 6 stops with a light + dark screenshot each (served), Jeff art, no inline styles, old tiles gone,
# the page words come from Admin > Page text, the puzzle demo still wired; screenshots fresh (tests/shots_stale.sh).
GAME=$1; PORT=$2; ROUTER=$3; BASE=http://127.0.0.1:$PORT; HERE=$(cd "$(dirname "$0")" && pwd)
php -d session.save_path=/tmp -S 127.0.0.1:$PORT -t $GAME $ROUTER >/tmp/lp-php.log 2>&1 & PID=$!; sleep 1
W=$(mktemp -d); trap "kill $PID 2>/dev/null; rm -rf $W" EXIT
ok() { if [ "$2" = "$3" ]; then echo "ok   $1"; else echo "FAIL $1 (got '$2', want '$3')"; fi; }
dbx() { php -r '$p=new PDO("sqlite:'$GAME'/data/game.sqlite"); $p->exec($argv[1]);' "$1"; }
ok "front page loads" "$(curl -s -o $W/i.html -w '%{http_code}' $BASE/index.php)" 200
ok "6 tour stops" "$(grep -c 'class="lp-stop"' $W/i.html)" 6
ok "12 screenshots in the page (light + dark)" "$(grep -o 'assets/img/landing/shot-[a-z]*\(-dark\)\?\.png' $W/i.html | sort -u | wc -l | tr -d ' ')" 12
bad=0; for u in $(grep -o 'assets/img/landing/shot-[a-z]*\(-dark\)\?\.png' $W/i.html | sort -u); do [ "$(curl -s -o /dev/null -w '%{http_code}' $BASE/$u)" = 200 ] || { echo "FAIL not served: $u"; bad=1; }; done
[ $bad = 0 ] && echo "ok   every screenshot is served"
ok "Jeff greets (hero + tour + closing card)" "$(grep -c 'src="[^"]*puzzles/cast/jeff-[a-z]*.png' $W/i.html | sed 's/^[0-9]\{1,\}$/many/')" many
ok "Jeff's hello is the editable text" "$(grep -c 'Hi, I’m Jeff, the Puzzler' $W/i.html)" 1
ok "no inline style attributes (CSP)" "$(grep -c ' style=' $W/i.html)" 0
ok "old landing tiles are gone" "$(grep -c 'class="lp-card"' $W/i.html)" 0
ok "tour button + sign-up button" "$(grep -c 'href="#tour"' $W/i.html)$(grep -c 'register.php' $W/i.html | sed 's/^[1-9][0-9]*$/yes/')" 1yes
ok "puzzle demo still on the page" "$(grep -c 'id="pz-data"' $W/i.html)" 1
dbx "INSERT OR REPLACE INTO site_texts (skey, body) VALUES ('home.jeff', 'Edited hello from the admin')"
ok "edited text shows" "$(curl -s $BASE/index.php | grep -c 'Edited hello from the admin')" 1
dbx "DELETE FROM site_texts WHERE skey = 'home.jeff'"
ok "page text table ok" "$(curl -s $BASE/index.php | grep -c 'Hi, I’m Jeff, the Puzzler')" 1
bash "$HERE/shots_stale.sh" | sed 's/^FAIL/FAIL shots:/'
