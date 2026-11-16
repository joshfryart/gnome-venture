#!/bin/bash
# 2.7.01: the fixed starter box and the admin reset of a Puzzle box: database checks (tests/pfdeck_reset.php) on an installed copy, then the admin page admin/puzzlebox.php.
# Usage: tests/pfdeck_reset.sh [GAME_COPY_DIR] [PORT] [ROUTER]
HERE=$(cd "$(dirname "$0")" && pwd)
GAME=${1:-}; PORT=${2:-8878}; ROUTER=${3:-$HERE/router.php}
if [ -z "$GAME" ]; then T=$(mktemp -d); cp -r "$HERE/../game" "$T/game"; GAME=$T/game; fi
rm -f "$GAME/config.php"; rm -rf "$GAME/data"; mkdir -p "$GAME/data"
BASE=http://127.0.0.1:$PORT
LOG=$(mktemp)
php -d session.save_path=/tmp -d display_errors=1 -S 127.0.0.1:$PORT -t "$GAME" "$ROUTER" >$LOG 2>&1 & PID=$!; sleep 1
trap "kill \$PID 2>/dev/null; [ -n \"\$T\" ] && rm -rf \"\$T\"" EXIT
C=$(mktemp); H=$(mktemp)
csrf() { grep -o 'name="csrf" value="[^"]*"' "$1" | head -1 | sed 's/.*value="\([^"]*\)".*/\1/'; }
get() { curl -s -c $C -b $C "$BASE/$1" -o $H -w '%{http_code}'; }
post() { local page=$1; shift; curl -s -c $C -b $C -X POST "$BASE/$page" --data-urlencode "csrf=$(csrf $H)" "$@" -o $H -w '%{http_code}'; }
db() { php -r '$p=new PDO("sqlite:'$GAME'/data/game.sqlite"); foreach($p->query($argv[1])->fetchAll(PDO::FETCH_NUM) as $r) echo implode(" | ",$r),"\n";' "$1"; }
FAILS=0; ck() { if [ "$2" = "$3" ]; then echo "ok   $1"; else echo "FAIL $1 (got '$2', want '$3')"; FAILS=$((FAILS+1)); fi; }
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
db "UPDATE users SET energy=100 WHERE username='sprout'" >/dev/null

echo "== database checks"
php -d display_errors=1 "$HERE/pfdeck_reset.php" "$GAME" 2>&1 | tee $H.db | grep -v "^ok" | cut -c1-900
FAILS=$((FAILS + $(grep -c '^FAIL' $H.db)))
ck "the database checks ran to the end" "$(grep -c 'reset checks: all ok' $H.db)" "1"

echo "== the admin page admin/puzzlebox.php"
SP=$(db "SELECT id FROM users WHERE username='sprout'")
state() { echo "$(db "SELECT GROUP_CONCAT(piece_key || ':' || active, ',') FROM (SELECT piece_key, active FROM pf_deck_pieces WHERE user_id=$SP ORDER BY pos, piece_key)") $(db "SELECT COUNT(*) FROM pf_belts WHERE user_id=$SP") $(db "SELECT starter || auto_use || belt_set FROM pf_decks WHERE user_id=$SP")"; }
FIXED="swing:1,dodge:1,rest:1,charm:1,jab:1,swing#2:1,pierce:1,snack:1,brace:1,soothe:1"
php -d display_errors=1 "$HERE/pfdeck_reset.php" "$GAME" dirty | tail -1
DIRTY=$(state)
ck "sprout's box is changed before the page is used (pieces switched, a belt set, auto on)" "$([ "${DIRTY%% *}" != "$FIXED" ] && echo changed) ${DIRTY##* }" "changed 111"
# a player may not open it
rm -f $C; get login.php >/dev/null; post login.php -d username=sprout -d password=TestPass123! >/dev/null
ck "a player: the page is refused (403), no form" "$(get admin/puzzlebox.php) $(grep -c 'name="confirm"' $H)" "403 0"
ck "a player: a POST is refused too, nothing changes" "$(post admin/puzzlebox.php -d username=sprout -d confirm=1) $([ "$(state)" = "$DIRTY" ] && echo same)" "403 same"
# the admin
rm -f $C; get login.php >/dev/null; post login.php -d username=admin -d password=TestPassword123 >/dev/null
ck "an admin: the page opens with the form (username, confirm box, csrf) and the menu links to it" "$(get admin/puzzlebox.php) $(grep -c 'name="username"' $H) $(grep -c 'name="confirm"' $H) $(grep -A1 '<form method="post" class="form box">' $H | grep -c 'name="csrf"') $(get admin/index.php >/dev/null; grep -c 'href="[^"]*admin/puzzlebox.php"' $H | sed 's/[1-9][0-9]*/linked/')" "200 1 1 1 linked"
get 'admin/puzzlebox.php?user=sprout' >/dev/null
ck "?user= prefills the username" "$(grep -c 'name="username" value="sprout"' $H)" "1"
ck "a POST with a wrong csrf token is refused (400), nothing changes" "$(curl -s -c $C -b $C -X POST "$BASE/admin/puzzlebox.php" -d csrf=wrong -d username=sprout -d confirm=1 -o /dev/null -w '%{http_code}') $([ "$(state)" = "$DIRTY" ] && echo same)" "400 same"
get admin/puzzlebox.php >/dev/null
ck "an unknown player: an error flash, nothing changes" "$(post admin/puzzlebox.php -d username=nobody-here -d confirm=1) $(get 'admin/puzzlebox.php?user=nobody-here' >/dev/null; grep -c 'flash err.*No player called &quot;nobody-here&quot;' $H) $([ "$(state)" = "$DIRTY" ] && echo same)" "302 1 same"
ck "the confirm box not ticked: an error flash, nothing changes" "$(post admin/puzzlebox.php -d username=sprout) $(get 'admin/puzzlebox.php?user=sprout' >/dev/null; grep -c 'flash err.*Tick the box to confirm the reset' $H) $([ "$(state)" = "$DIRTY" ] && echo same)" "302 1 same"
LOGN=$(db "SELECT COUNT(*) FROM admin_log WHERE action='pbox_reset'")
ck "the reset: a success flash, the box is the fixed starter, no saved belt, auto off; logged once" "$(post admin/puzzlebox.php -d username=sprout -d confirm=1) $(get 'admin/puzzlebox.php?user=sprout' >/dev/null; grep -c 'flash ok.*Puzzle box is back to the starter box' $H) $(state) $(( $(db "SELECT COUNT(*) FROM admin_log WHERE action='pbox_reset' AND target='users#$SP'") - LOGN ))" "302 1 $FIXED 0 100 1"
# in a fight: refused with the reason
php -d display_errors=1 "$HERE/pfdeck_reset.php" "$GAME" dirty | tail -1; DIRTY=$(state)
db "UPDATE expeditions SET status='active', encounter='{\"type\":\"creature\",\"id\":1,\"pf\":{\"over\":\"\",\"turn\":1}}' WHERE id=(SELECT MAX(id) FROM expeditions WHERE user_id=$SP)" >/dev/null
get admin/puzzlebox.php >/dev/null
ck "a player in a fight: refused with the reason, nothing changes" "$(post admin/puzzlebox.php -d username=sprout -d confirm=1) $(get 'admin/puzzlebox.php?user=sprout' >/dev/null; grep -c 'flash err.*in a fight' $H) $([ "$(state)" = "$DIRTY" ] && echo same)" "302 1 same"
db "UPDATE expeditions SET encounter=NULL WHERE user_id=$SP" >/dev/null

ck "no errors in the game error log" "$(cat "$GAME/data/error-log.txt" 2>/dev/null | wc -c | tr -d ' ')" "0"
grep -E "PHP (Warning|Notice|Deprecated|Fatal)" $LOG | head -3 | cut -c1-260
ck "no PHP warnings in server log" "$(grep -cE 'PHP (Warning|Notice|Deprecated|Fatal)' $LOG)" "0"
[ $FAILS -eq 0 ] && echo "pfdeck_reset ok" || echo "$FAILS FAILED"
[ $FAILS -eq 0 ]
