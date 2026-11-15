#!/bin/bash
# 2.7.00 Admin > Trail decor page: fresh SQLite install in a temp copy; open the page, save a section's decor, see it listed, a bad form is refused, Back to the data removes it.
# Usage: tests/trail_decor_page.sh [GAME_COPY_DIR] [PORT] [ROUTER]
HERE=$(cd "$(dirname "$0")" && pwd)
GAME=${1:-}; PORT=${2:-9341}; ROUTER=${3:-$HERE/router.php}
if [ -z "$GAME" ]; then T=$(mktemp -d); cp -r "$HERE/../game" "$T/game"; GAME=$T/game; fi
rm -f "$GAME/config.php"; rm -rf "${GAME:?}/data"; mkdir -p "$GAME/data"
BASE=http://127.0.0.1:$PORT
LOG=$(mktemp)
php -d session.save_path=/tmp -d display_errors=1 -S 127.0.0.1:$PORT -t "$GAME" "$ROUTER" >$LOG 2>&1 & PID=$!; sleep 1
trap "kill $PID 2>/dev/null" EXIT
C=$(mktemp); H=$(mktemp)
csrf() { grep -o 'name="csrf" value="[^"]*"' "$1" | head -1 | sed 's/.*value="\([^"]*\)".*/\1/'; }
get() { curl -s -c $C -b $C "$BASE/$1" -o $H -w '%{http_code}'; }
post() { local page=$1; shift; curl -s -c $C -b $C -X POST "$BASE/$page" --data-urlencode "csrf=$(csrf $H)" "$@" -o $H -w '%{http_code}'; }
db() { php -r '$p=new PDO("sqlite:'$GAME'/data/game.sqlite"); foreach($p->query($argv[1])->fetchAll(PDO::FETCH_NUM) as $r) echo implode(" | ",$r),"\n";' "$1"; }
FAILS=0
chk() { if [ "$2" = "$3" ]; then echo "  ok   $1"; else echo "  FAIL $1 (got '$2', want '$3')"; FAILS=$((FAILS+1)); fi; }
has() { if grep -q "$2" $H; then echo "  ok   $1"; else echo "  FAIL $1 (no '$2')"; FAILS=$((FAILS+1)); fi; }
get install.php >/dev/null
post install.php -d driver=sqlite -d "site_name=Gnome Venture" -d base_url= -d admin_user=admin -d admin_email=a@b.local -d admin_pass=TestPassword123 -d admin_pass2=TestPassword123 >/dev/null
grep -q 'All planted' $H || { echo "INSTALL FAILED"; tail -5 $LOG; exit 1; }
rm -f $C; get login.php >/dev/null; post login.php -d username=admin -d password=TestPassword123 >/dev/null
echo "== the page"
chk "the page opens" "$(get admin/trail_decor.php)" 200
has "it has the route picker" 'name="route"'
chk "a section opens" "$(get 'admin/trail_decor.php?route=228&sec=0')" 200
has "it shows the section size" '30 × 18'
has "it has the looks box" 'name="looks"'
echo "== save"
chk "a good form saves (redirect)" "$(post admin/trail_decor.php -d route=228 -d sec=0 --data-urlencode 'looks=boulder 1 1 3 2' --data-urlencode 'props=haybale 5 5' -d tree=birch)" 302
chk "one row in the table" "$(db 'SELECT COUNT(*) FROM trail_decor_edits')" 1
get 'admin/trail_decor.php?route=228&sec=0' >/dev/null
has "the form shows the saved looks" 'boulder 1 1 3 2'
has "and says it is edited here" 'edited here'
get admin/trail_decor.php >/dev/null
has "the edited section is listed" 'route 228, section 0'
echo "== refused"
get 'admin/trail_decor.php?route=228&sec=0' >/dev/null
chk "a bad line is refused (redirect, nothing changed)" "$(post admin/trail_decor.php -d route=228 -d sec=0 --data-urlencode 'looks=hedge 0 0 99 99')" 302
chk "still one row, with the old looks" "$(db "SELECT COUNT(*) FROM trail_decor_edits WHERE decor LIKE '%boulder%'")" 1
echo "== back to the data"
get 'admin/trail_decor.php?route=228&sec=0' >/dev/null
chk "restore (redirect)" "$(post admin/trail_decor.php -d route=228 -d sec=0 -d restore=1)" 302
chk "no rows" "$(db 'SELECT COUNT(*) FROM trail_decor_edits')" 0
grep -qE "(PHP )?(Warning|Notice|Deprecated|Fatal error)" $LOG && { echo "  FAIL PHP warnings:"; grep -E "(PHP )?(Warning|Notice|Deprecated|Fatal error)" $LOG | head -3; FAILS=$((FAILS+1)); }
[ $FAILS -eq 0 ] && echo ok || echo "$FAILS FAILED"
exit $FAILS
