# 2.6.41: logged-out front page: the landing card and How to play (includes/landing_view.php), every picture served, no inline styles,
# the page words come from Admin > Page text, the puzzle demo still wired. (v2.0.73's Jeff tour with screenshots is retired; tests/landing_home.sh checks the data.)
GAME=$1; PORT=$2; ROUTER=$3; BASE=http://127.0.0.1:$PORT; HERE=$(cd "$(dirname "$0")" && pwd)
php -d session.save_path=/tmp -S 127.0.0.1:$PORT -t $GAME $ROUTER >/tmp/lp-php.log 2>&1 & PID=$!; sleep 1
W=$(mktemp -d); trap "kill $PID 2>/dev/null; rm -rf $W" EXIT
ok() { if [ "$2" = "$3" ]; then echo "ok   $1"; else echo "FAIL $1 (got '$2', want '$3')"; fi; }
dbx() { php -r '$p=new PDO("sqlite:'$GAME'/data/game.sqlite"); $p->exec($argv[1]);' "$1"; }
ok "front page loads" "$(curl -s -o $W/i.html -w '%{http_code}' $BASE/index.php)" 200
ok "landing card" "$(grep -c 'class="lh-hero"' $W/i.html)" 1
ok "How to play with its anchor" "$(grep -c 'id="howto"' $W/i.html)" 1
ok "5 How to play cards (Jigsaw and Puzzle Pals closed on a fresh install)" "$(grep -o '<article class="lh-card' $W/i.html | wc -l | tr -d ' ')" 5
ok "the page script and styles are loaded" "$(grep -c 'assets/landing.js?v=' $W/i.html)$(grep -c 'assets/landing.css?v=' $W/i.html)" 11
bad=0; for u in $(grep -o 'assets/img/[A-Za-z0-9_./-]*\.\(png\|jpg\)' $W/i.html | sort -u); do [ "$(curl -s -o /dev/null -w '%{http_code}' $BASE/$u)" = 200 ] || { echo "FAIL not served: $u"; bad=1; }; done
[ $bad = 0 ] && echo "ok   every picture named in the page is served"
ok "the gnome strip is served to a visitor" "$(curl -s -o /dev/null -w '%{http_code}' "$BASE/gnome_sprite.php?v=side")" 200
ok "Jeff still closes the page" "$(grep -c 'src="[^"]*puzzles/cast/jeff-key[a-z-]*.png' $W/i.html | sed 's/^[1-9][0-9]*$/yes/')" yes
ok "no inline style attributes (CSP)" "$(grep -c ' style=' $W/i.html)" 0
ok "old landing tiles and the screenshot tour are gone" "$(grep -c 'class="lp-card"' $W/i.html)$(grep -c 'class="lp-stop"' $W/i.html)" 00
ok "How to play link + sign-up button" "$(grep -c 'href="#howto"' $W/i.html)$(grep -c 'register.php' $W/i.html | sed 's/^[1-9][0-9]*$/yes/')" 1yes
ok "puzzle demo still on the page" "$(grep -c 'id="pz-data"' $W/i.html)" 1
dbx "INSERT OR REPLACE INTO site_texts (skey, body) VALUES ('home.sub', 'Edited line from the admin')"
ok "edited text shows" "$(curl -s $BASE/index.php | grep -c 'Edited line from the admin')" 1
dbx "DELETE FROM site_texts WHERE skey = 'home.sub'"
ok "page text table ok" "$(curl -s $BASE/index.php | grep -c 'It plays in your browser')" 1
