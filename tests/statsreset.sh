#!/bin/bash
# v2.4.94: admin "Start counting again" on XP sources, Usage and Retention. Fresh SQLite install in a private copy.
# Usage: tests/statsreset.sh [GAME_COPY_DIR] [PORT] [ROUTER]
HERE=$(cd "$(dirname "$0")" && pwd)
GAME=${1:-}; PORT=${2:-8796}; ROUTER=${3:-$HERE/router.php}
if [ -z "$GAME" ]; then T=$(mktemp -d); cp -r "$HERE/../game" "$T/game"; GAME=$T/game; fi
rm -f "$GAME/config.php"; rm -rf "$GAME/data"; mkdir -p "$GAME/data"
BASE=http://127.0.0.1:$PORT
LOG=$(mktemp)
php -d session.save_path=/tmp -d display_errors=1 -S 127.0.0.1:$PORT -t "$GAME" "$ROUTER" >$LOG 2>&1 & PID=$!; sleep 1
trap "kill $PID 2>/dev/null" EXIT
C=$(mktemp); H=$(mktemp); FAILS=0
chk() { if [ "$2" = 1 ]; then echo "  ok   $1"; else echo "  FAIL $1 $3"; FAILS=$((FAILS+1)); fi; }
csrf() { grep -o 'name="csrf" value="[^"]*"' "$1" | head -1 | sed 's/.*value="\([^"]*\)".*/\1/'; }
get() { curl -s -c $C -b $C "$BASE/$1" -o $H -w '%{http_code}'; }
post() { local page=$1; shift; curl -s -L -c $C -b $C -X POST "$BASE/$page" --data-urlencode "csrf=$(csrf $H)" "$@" -o $H -w '%{http_code}'; }
db() { php -r '$p=new PDO("sqlite:'$GAME'/data/game.sqlite"); foreach($p->query($argv[1])->fetchAll(PDO::FETCH_NUM) as $r) echo implode(" | ",$r),"\n";' "$1"; }
dbx() { php -r '$p=new PDO("sqlite:'$GAME'/data/game.sqlite"); $p->exec($argv[1]);' "$1"; }

get install.php >/dev/null
post install.php -d driver=sqlite -d "site_name=Gnome Venture" -d base_url= -d admin_user=admin -d admin_email=a@b.local -d admin_pass=TestPassword123 -d admin_pass2=TestPassword123 >/dev/null
grep -q 'All planted' $H || { echo "INSTALL FAILED"; tail -5 $LOG; exit 1; }
rm -f $C
get register.php >/dev/null; post register.php -d username=sprout -d email=s@b.local -d password=TestPass123! -d password2=TestPass123! -d rules=1 -d age=1 >/dev/null
SID=$(db "SELECT id FROM users WHERE username='sprout'")
dbx "INSERT INTO xp_log (day, user_id, source, xp) VALUES (date('now'), $SID, 'Harvesting', 500)"
dbx "INSERT INTO user_jobs (user_id, job_id) SELECT $SID, 1" 2>/dev/null
rm -f $C; get login.php >/dev/null; post login.php -d username=admin -d password=TestPassword123 >/dev/null

echo "== the pages show the reset box"
for pg in xp usage retention; do get admin/$pg.php >/dev/null; chk "$pg.php has the reset box" "$(grep -q 'Start counting again' $H && echo 1)"; done
get admin/xp.php >/dev/null; chk "xp shows 500 before" "$(grep -q '500' $H && echo 1)"

echo "== reset"
post admin/xp.php -d do=stats_reset >/dev/null
chk "xp_log is empty" "$([ "$(db 'SELECT COUNT(*) FROM xp_log')" = 0 ] && echo 1)"
chk "player XP untouched" "$([ -n "$(db "SELECT xp FROM users WHERE id=$SID")" ] && echo 1)"
get admin/usage.php >/dev/null; post admin/usage.php -d do=stats_reset >/dev/null
chk "usage baseline stored" "$([ -n "$(db "SELECT value FROM settings WHERE name='stats_reset_usage'")" ] && echo 1)"
get admin/usage.php >/dev/null; chk "usage page says counting since" "$(grep -q 'Counting since' $H && echo 1)"
get admin/retention.php >/dev/null; post admin/retention.php -d do=stats_reset >/dev/null
get admin/retention.php >/dev/null
chk "retention baseline stored" "$([ -n "$(db "SELECT value FROM settings WHERE name='stats_reset_retention'")" ] && echo 1)"
chk "retention: 'Since reset' cohort, no signups counted" "$(grep -q 'Since reset' $H && echo 1)"
chk "no PHP errors in the log" "$(grep -qi 'fatal\|warning\|notice' $LOG || echo 1)" "$(grep -i 'fatal\|warning\|notice' $LOG | head -3)"
chk "xp curve defaults 20 / 6" "$([ "$(db "SELECT value FROM settings WHERE name IN ('xp_steep_percent','xp_action_scale_percent') ORDER BY name" | tr '\n' ' ')" = "6 20 " ] || [ -z "$(db "SELECT value FROM settings WHERE name='xp_steep_percent'")" ] && echo 1)"
echo
if [ $FAILS -eq 0 ]; then echo "all stats-reset checks passed"; else echo "$FAILS FAILED"; exit 1; fi
