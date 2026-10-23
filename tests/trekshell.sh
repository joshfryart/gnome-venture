#!/bin/bash
# v2.0.40 Trek stage + drawers: install, enter a trek, check the page and take screenshots (needs playwright).
# Usage: tests/clock.sh [GAME_COPY_DIR] [PORT] [ROUTER]   (default: copies src/game to a temp dir; never writes a DB into src)
HERE=$(cd "$(dirname "$0")" && pwd)
GAME=${1:-}; PORT=${2:-8793}; ROUTER=${3:-$HERE/router.php}
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
db "UPDATE users SET role='admin', level=40, energy=100 WHERE username='sprout'" >/dev/null
db "UPDATE settings SET value='1' WHERE name='trek_open'" >/dev/null
get trek.php >/dev/null
post trek.php -d do=begin -d t=map >/dev/null
echo "trek page: $(get trek.php) stage=$(grep -c 'id="trekstage"' $H) script=$(grep -c 'trekshell.js' $H) tabs=$(grep -c 'nav class="tabs"' $H)"
grep -o 'data-stage="[^"]\{0,160\}' $H | head -1
if [ -n "$SHOT" ]; then
  COOKIE=$(grep -oE 'PHPSESSID\s+\S+' $C | awk '{print $2}')
  node "$HERE/trekshell_shot.js" "$BASE" "$COOKIE" "$SHOT"
fi
php -d display_errors=1 "$HERE/trekfight_force.php" "$GAME" 2>&1 | tail -2
echo "fight page: $(get trek.php) foes=$(grep -c '"side":"f"' $H) hpstage=$(grep -c trekfight $H)"
if [ -n "$SHOT" ]; then node "$HERE/trekshell_shot.js" "$BASE" x "$SHOT" fight; fi
echo "== php errors"
grep -iE 'fatal|warning|notice|deprecated' $LOG || echo "(none)"
