#!/bin/bash
# Sleep-days game clock: fresh SQLite install in a temp copy, then tests/game_clock.php.
# Usage: tests/clock.sh [GAME_COPY_DIR] [PORT] [ROUTER]   (default: copies src/game to a temp dir; never writes a DB into src)
HERE=$(cd "$(dirname "$0")" && pwd)
GAME=${1:-}; PORT=${2:-8794}; ROUTER=${3:-$HERE/router.php}
if [ -z "$GAME" ]; then T=$(mktemp -d); cp -r "$HERE/../game" "$T/game"; GAME=$T/game; fi
rm -f "$GAME/config.php"; rm -rf "$GAME/data"; mkdir -p "$GAME/data"
BASE=http://127.0.0.1:$PORT
LOG=$(mktemp)
php -d session.save_path=/tmp -d display_errors=1 -S 127.0.0.1:$PORT -t "$GAME" "$ROUTER" >$LOG 2>&1 & PID=$!; sleep 1
trap "kill $PID 2>/dev/null" EXIT
C=$(mktemp); H=$(mktemp)
csrf() { grep -o 'name="csrf" value="[^"]*"' "$1" | head -1 | sed 's/.*value="\([^"]*\)".*/\1/'; }
get() { curl -s -c $C -b $C "$BASE/$1" -o $H -w '%{http_code}'; }
post() { local page=$1; shift; curl -s -c $C -b $C -X POST "$BASE/$page" --data-urlencode "csrf=$(csrf $H)" "$@" -o $H -w '%{http_code}'; }
db() { php -r '$p=new PDO("sqlite:'$GAME'/data/game.sqlite"); foreach($p->query($argv[1])->fetchAll(PDO::FETCH_NUM) as $r) echo implode(" | ",$r),"\n";' "$1"; }
echo "== install + register + welcome"
get install.php >/dev/null
post install.php -d driver=sqlite -d "site_name=Gnome Venture" -d base_url= -d admin_user=admin -d admin_email=a@b.local -d admin_pass=TestPassword123 -d admin_pass2=TestPassword123 >/dev/null
grep -q 'All planted' $H && echo installed || { echo "INSTALL FAILED"; grep -oE "flash err[^<]*<[^<]*" $H; tail -5 $LOG; exit 1; }
rm -f $C
get register.php >/dev/null; post register.php -d username=sprout -d email=s@b.local -d password=TestPass123! -d password2=TestPass123! -d rules=1 -d age=1 >/dev/null
get welcome.php >/dev/null; post welcome.php -d do=gnome -d "gnome_name=Bramble" -d 'hat=#2e7d4f' -d 'beard=#b5651d' >/dev/null
get 'welcome.php?step=place' >/dev/null
RID=$(db "SELECT id FROM regions WHERE code='NA'")
VID=$(db "SELECT l.id FROM locations l WHERE l.region_id=$RID AND l.kind='village' AND EXISTS (SELECT 1 FROM routes r WHERE r.kind='road' AND (r.a_id=l.id OR r.b_id=l.id)) ORDER BY l.sort_order LIMIT 1 OFFSET 1")
post welcome.php -d do=place -d village_id=$VID >/dev/null
get 'welcome.php?step=garden' >/dev/null; post welcome.php -d do=finish -d 'garden_name=Test Patch' >/dev/null
echo "onboarded: $(db "SELECT onboarded FROM users WHERE username='sprout'")"
echo "== news tabs"
db "INSERT INTO news (title, body, published, kind, created_at) VALUES ('Plain news post', 'x', 1, 'news', datetime('now'))" >/dev/null
get 'index.php?news=all' >/dev/null; grep -q 'Plain news post' $H && echo "news tab: news ok" || echo "news tab: FAIL news"; grep -q 'Release notes' $H && echo "tabs shown" || echo "FAIL tabs"
get 'index.php?news=all&tab=notes' >/dev/null; grep -q 'Plain news post' $H && echo "FAIL notes shows news" || echo "notes tab: separate ok"
get gnome.php >/dev/null; grep -q 'tntabbar' $H && grep -q 'Plain news post' $H && echo "today card tabs ok" || echo "FAIL today card tabs"
get 'world.php?tab=markets' >/dev/null; grep -q 'hubshops' $H && grep -q 'shopcard' $H && echo "markets tab ok" || echo "FAIL markets tab"
echo "notes rows: $(db "SELECT COUNT(*) FROM news WHERE kind='notes'" | head -1)"
echo "== hovel page"
echo "flag off -> $(get hovel.php) (redirect expected 200 after follow? shows gnome page)"; grep -q 'still being built' $H && echo "  off: closed message" || echo "  off: (no message, check)"
php -r '$p=new PDO("sqlite:'$GAME'/data/game.sqlite"); $p->exec("INSERT OR REPLACE INTO settings (name,value) VALUES (\"game_clock_on\",\"1\")");'
get hovel.php >/dev/null; grep -q 'Sleep in your hovel' $H && echo "  on: hovel shows" || { echo "  FAIL hovel missing"; }
post hovel.php -d do=home_nap >/dev/null; echo "  after nap: $(db "SELECT game_day, game_minute FROM users WHERE username='sprout'")"
get hovel.php >/dev/null; post hovel.php -d do=home_sleep >/dev/null; echo "  after sleep: $(db "SELECT game_day, game_minute FROM users WHERE username='sprout'")"
php -r '$p=new PDO("sqlite:'$GAME'/data/game.sqlite"); $p->exec("UPDATE users SET game_day=0, game_minute=360"); $p->exec("DELETE FROM settings WHERE name=\"game_clock_on\"");'
echo "== game clock (tests/game_clock.php)"
php -d display_errors=1 -d error_reporting=-1 "$HERE/game_clock.php" "$GAME" 2>&1; RC=$?
echo "== php errors"
grep -iE 'fatal|warning|notice|deprecated' $LOG || echo "(none)"
exit $RC
