# v2.0.61: Puzzles smoke test: locked for players, open when puzzles_open=1, every picture and its still exist, page wires the JS.
GAME=$1; PORT=$2; ROUTER=$3; BASE=http://127.0.0.1:$PORT
php -d session.save_path=/tmp -S 127.0.0.1:$PORT -t $GAME $ROUTER >/tmp/pz-php.log 2>&1 & PID=$!; sleep 1
trap "kill $PID 2>/dev/null" EXIT
csrf() { grep -o 'name="csrf" value="[^"]*"' "$1" | head -1 | sed 's/.*value="\([^"]*\)".*/\1/'; }
dbx() { php -r '$p=new PDO("sqlite:'$GAME'/data/game.sqlite"); $p->exec($argv[1]);' "$1"; }
login() { rm -f $1; curl -s -c $1 -b $1 $BASE/login.php > /tmp/pz.html; curl -s -c $1 -b $1 -X POST $BASE/login.php --data-urlencode "csrf=$(csrf /tmp/pz.html)" -d username=$2 --data-urlencode "password=$3" -o /dev/null; }
ok() { if [ "$2" = "$3" ]; then echo "ok   $1"; else echo "FAIL $1 (got '$2', want '$3')"; fi; }
login /tmp/pz-p 'sprout' 'TestPass123!'
dbx "DELETE FROM settings WHERE name='puzzles_open'"
ok "locked: player is redirected" "$(curl -s -b /tmp/pz-p -o /dev/null -w '%{http_code}' $BASE/gifsaw.php)" 302
curl -s -b /tmp/pz-p $BASE/games.php > /tmp/pz.html; ok "locked: no Puzzles tile" "$(grep -c 'puzzles.php' /tmp/pz.html)" 0
dbx "INSERT OR REPLACE INTO settings (name,value) VALUES ('puzzles_open','1')"
curl -s -b /tmp/pz-p $BASE/gifsaw.php > /tmp/pz.html
ok "open: page loads for a player" "$(grep -c 'id="pz-data"' /tmp/pz.html)" 1
ok "open: puzzles.js wired" "$(grep -c 'assets/puzzles.js' /tmp/pz.html)" 1
# v2.0.69: hub + redirects
ok "hub: player redirect when closed handled above; hub loads" "$(curl -s -b /tmp/pz-p -o /dev/null -w '%{http_code}' $BASE/puzzles.php)" 200
curl -s -b /tmp/pz-p $BASE/puzzles.php > /tmp/pz.html
ok "hub: puzzlehub.js wired, puzzles.js not" "$(grep -c 'assets/puzzlehub.js' /tmp/pz.html)$(grep -c 'assets/puzzles.js' /tmp/pz.html)" 10
ok "hub: links GIFsaw + 3 coming soon" "$(grep -c 'gifsaw.php' /tmp/pz.html)$(grep -c 'Coming soon' /tmp/pz.html)" 13
ok "old ?t link redirects to gifsaw" "$(curl -s -b /tmp/pz-p -o /dev/null -w '%{http_code} %{redirect_url}' "$BASE/puzzles.php?t=5&seed=9&x=1" | sed 's#http://[^/]*##')" "302 /gifsaw.php?t=5&seed=9"
curl -s -b /tmp/pz-p $BASE/gifsaw.php > /tmp/pz.html
ok "open: Motion button" "$(grep -c 'id="anim"' /tmp/pz.html)" 1
N=0; for f in $(php -r '$j=preg_match("#id=\"pz-data\">(.*?)</script>#s", file_get_contents("/tmp/pz.html"), $m) ? json_decode($m[1], true) : []; foreach ($j as $p) echo basename(strtok($p["gif"], "?")), " ", basename(strtok($p["still"], "?")), "\n";' | tr ' ' '\n'); do
  N=$((N+1)); [ -s "$GAME/assets/img/puzzles/$f" ] || echo "FAIL missing picture file: $f"
done
ok "pictures listed (7 gifs + 7 stills)" "$N" 14
# v2.0.68: the cast. Every cast picture exists (a -dark twin is optional), and the page shows the host and the hint/scatter faces
for c in jeff-host tile-puzzles puzzles-banner jeff-cheer win-scene jeff-think ffej-scatter wizard-hint empty-box tourney-banner trophy-gold badge-silver badge-bronze badge-entered wizard-hourglass ffej-caught; do
  [ -s "$GAME/assets/img/puzzles/cast/$c.png" ] || echo "FAIL missing cast art: cast/$c.png"
done
ok "Jeff hosts the library" "$(grep -c 'Jeff:</b>' /tmp/pz.html)" 1
ok "pictures come from puzzle_pics" "$(php -r '$p=new PDO("sqlite:'$GAME'/data/game.sqlite"); echo $p->query("SELECT COUNT(*) FROM puzzle_pics WHERE source=\"builtin\" AND active=1")->fetchColumn();')" 7
dbx "UPDATE puzzle_pics SET active=0 WHERE slug='pig'"
curl -s -b /tmp/pz-p $BASE/gifsaw.php > /tmp/pz.html
ok "a switched-off picture leaves the library" "$(grep -c 'pig.gif' /tmp/pz.html)" 0
dbx "UPDATE puzzle_pics SET active=1 WHERE slug='pig'"
ok "seeded scramble (mulberry32, ?seed=)" "$(grep -c 'function mulberry32' $GAME/assets/puzzles.js)$(grep -c 'seed=(' $GAME/assets/puzzles.js)" 11
ok "no Math.random left in the layout" "$(grep -cE 'rnd\(a,b\)\{ return a\+Math.random|Math.random\(\)<\.5|Math.random\(\)\*\(i\+1\)' $GAME/assets/puzzles.js)" 0
dbx "DELETE FROM settings WHERE name='puzzles_open'"
echo "== php log"; grep -iE 'fatal|warning|notice|deprecated' /tmp/pz-php.log || echo "(none)"
