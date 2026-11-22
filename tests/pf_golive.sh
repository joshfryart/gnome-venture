#!/bin/bash
# 2.7.57 puzzle combat live for everyone: a fresh install has pfight_open / pfight_v1 on (no setting written by the test), a normal player (not admin) gets the Puzzle box,
# the boot step pfight_live_2757 turns both on once on an upgraded world and keeps a later admin Off, and a real browser plays a road fight to its end (tests/pf_golive.js).
# Usage: tests/pf_golive.sh [GAME_COPY_DIR] [PORT] [ROUTER]
HERE=$(cd "$(dirname "$0")" && pwd)
GAME=${1:-}; PORT=${2:-8903}; ROUTER=${3:-$HERE/router.php}
if [ -z "$GAME" ]; then T=$(mktemp -d); cp -r "$HERE/../game" "$T/game"; GAME=$T/game; fi
rm -f "$GAME/config.php"; rm -rf "$GAME/data"; mkdir -p "$GAME/data"
BASE=http://127.0.0.1:$PORT; LOG=$(mktemp)
php -d session.save_path=/tmp -d display_errors=1 -S 127.0.0.1:$PORT -t "$GAME" "$ROUTER" >$LOG 2>&1 & PID=$!; sleep 1
trap "kill \$PID 2>/dev/null; [ -n \"\$T\" ] && rm -rf \"\$T\"" EXIT
C=$(mktemp); H=$(mktemp)
csrf() { grep -o 'name="csrf" value="[^"]*"' "$1" | head -1 | sed 's/.*value="\([^"]*\)".*/\1/'; }
get() { curl -s -c $C -b $C "$BASE/$1" -o $H -w '%{http_code}'; }
post() { local page=$1; shift; curl -s -c $C -b $C -X POST "$BASE/$page" --data-urlencode "csrf=$(csrf $H)" "$@" -o $H -w '%{http_code}'; }
db() { php -r '$p=new PDO("sqlite:'$GAME'/data/game.sqlite"); foreach($p->query($argv[1])->fetchAll(PDO::FETCH_NUM) as $r) echo implode(" | ",$r),"\n";' "$1"; }
get install.php >/dev/null
post install.php -d driver=sqlite -d "site_name=Gnome Venture" -d base_url= -d admin_user=admin -d admin_email=a@b.local -d admin_pass=TestPassword123 -d admin_pass2=TestPassword123 >/dev/null
grep -q 'All planted' $H && echo installed || { echo "INSTALL FAILED"; exit 1; }
rm -f $C
get register.php >/dev/null; post register.php -d username=sprout -d email=s@b.local -d password=TestPass123! -d password2=TestPass123! -d rules=1 -d age=1 >/dev/null
get welcome.php >/dev/null; post welcome.php -d do=gnome -d "gnome_name=Bramble" -d 'hat=#2e7d4f' -d 'beard=#b5651d' >/dev/null
get 'welcome.php?step=place' >/dev/null
RID=$(db "SELECT id FROM regions WHERE code='NA'")
VID=$(db "SELECT l.id FROM locations l WHERE l.region_id=$RID AND l.kind='village' AND EXISTS (SELECT 1 FROM routes r WHERE r.kind='road' AND (r.a_id=l.id OR r.b_id=l.id)) ORDER BY l.sort_order LIMIT 1")
post welcome.php -d do=place -d village_id=$VID >/dev/null
get 'welcome.php?step=garden' >/dev/null; post welcome.php -d do=finish -d 'garden_name=Test Patch' >/dev/null
FAILS=0
[ "$(db "SELECT role FROM users WHERE username='sprout'")" = player ] && echo "ok   sprout is a normal player" || { echo "FAIL sprout role"; FAILS=$((FAILS+1)); }
[ "$(db "SELECT value FROM settings WHERE name='pfight_open'")|$(db "SELECT value FROM settings WHERE name='pfight_v1'")" = "1|1" ] && echo "ok   fresh install: pfight_open = 1, pfight_v1 = 1" || { echo "FAIL fresh install defaults"; FAILS=$((FAILS+1)); }
get puzzlebox.php >/dev/null; grep -q 'pfv-box\|pfv-start' $H && echo "ok   the Puzzle box opens for sprout" || { echo "FAIL Puzzle box"; FAILS=$((FAILS+1)); }
echo "== boot step on an upgraded world (from 2.7.56, both Off): turns both on once; an admin Off afterwards is kept"
php -r '$_SERVER["SCRIPT_NAME"]="/index.php"; require $argv[1]."/includes/bootstrap.php"; q("DELETE FROM settings WHERE name = ?", ["pfight_live_2757"]); set_setting("pfight_open","0"); set_setting("pfight_v1","admin"); set_setting("db_version","2.7.56");' "$GAME" 2>&1 | head -3
get index.php >/dev/null
[ "$(db "SELECT value FROM settings WHERE name='pfight_open'")|$(db "SELECT value FROM settings WHERE name='pfight_v1'")|$(db "SELECT value FROM settings WHERE name='pfight_live_2757'")" = "1|1|1" ] && echo "ok   upgrade: both on, marker set" || { echo "FAIL upgrade step: $(db "SELECT name||'='||value FROM settings WHERE name IN ('pfight_open','pfight_v1','pfight_live_2757','db_version','boot_failed_steps')" | tr '\n' ' ')"; FAILS=$((FAILS+1)); }
[ -n "$(db "SELECT id FROM items WHERE slug='tool-repair-kit'")$(db "SELECT value FROM settings WHERE name='pfd_content'")" ] && echo "ok   upgrade: the belt / repair kit content is made" || echo "note pfd content not made at upgrade (made on first fight)"
php -r '$_SERVER["SCRIPT_NAME"]="/index.php"; require $argv[1]."/includes/bootstrap.php"; set_setting("pfight_open","0"); set_setting("db_version","2.7.56");' "$GAME" 2>&1 | head -3
get index.php >/dev/null
[ "$(db "SELECT value FROM settings WHERE name='pfight_open'")" = 0 ] && echo "ok   a later upgrade keeps the admin's Off" || { echo "FAIL admin Off undone"; FAILS=$((FAILS+1)); }
db "UPDATE settings SET value='1' WHERE name='pfight_open'" >/dev/null
echo "== a road fight in the browser"
for k in problem choice find; do db "INSERT OR REPLACE INTO settings (name,value) VALUES ('road_roll_$k','0')" >/dev/null; done   # test only: every road space is a creature
db "INSERT OR REPLACE INTO settings (name,value) VALUES ('road_roll_creature','100')" >/dev/null
db "UPDATE users SET tour_step=99 WHERE username='sprout'" >/dev/null
if node -e "require('playwright')" 2>/dev/null; then node "$HERE/pf_golive.js" "$BASE" "${SHOTS:-}" >$H.out 2>&1; RC=$?; grep -av $'\x1b' $H.out | cut -c1-300; [ $RC = 0 ] || FAILS=$((FAILS+1)); else echo "skip browser (no playwright)"; fi
grep -q 'Fatal\|Warning:' $LOG && { echo "FAIL php errors:"; grep 'Fatal\|Warning:' $LOG | head -3; FAILS=$((FAILS+1)); }
[ $FAILS = 0 ] && echo "pf_golive ok" || { echo "$FAILS FAILED"; exit 1; }
