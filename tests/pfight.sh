#!/bin/bash
# Puzzle combat page test: flag, hand, chain POST, stale turn, run to the end.
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
db "UPDATE users SET energy=100 WHERE username='sprout'" >/dev/null
php -d display_errors=1 "$HERE/advforce.php" "$GAME" 2>&1 | tail -2
FAILS=0; ck() { if [ "$2" = "$3" ]; then echo "ok   $1"; else echo "FAIL $1 (got '$2', want '$3')"; FAILS=$((FAILS+1)); fi; }
db "UPDATE settings SET value='0' WHERE name='pfight_open'" >/dev/null; db "INSERT OR IGNORE INTO settings (name,value) VALUES ('pfight_open','0')" >/dev/null
php -d display_errors=1 "$HERE/advforce.php" "$GAME" fight 2>&1 | tail -1
get adventure.php >/dev/null
ck "flag off: old fight card" "$(grep -c 'id="pfight"' $H)" "0"
ck "flag off: attack button" "$( [ $(grep -c 'value="attack"' $H) -ge 1 ] && echo yes)" "yes"
db "UPDATE settings SET value='1' WHERE name='pfight_open'" >/dev/null
get adventure.php >/dev/null
ck "flag on: puzzle card" "$(grep -c 'id="pfight"' $H)" "1"
ck "flag on: no old attack button" "$(grep -c 'value="attack"' $H)" "0"
ck "hand has tiles" "$( [ $(grep -o 'data-i="' $H | wc -l) -ge 5 ] && echo yes)" "yes"
ck "no draw pile leak" "$(grep -c '"draw"' $H)" "0"
if [ -n "$SHOT" ]; then node "$HERE/pfightshot.js" "$BASE" "$SHOT" || { echo "FAIL browser check"; FAILS=$((FAILS+1)); }; fi
ENC1=$(db "SELECT encounter FROM expeditions ORDER BY id DESC LIMIT 1" | md5sum)
get adventure.php >/dev/null
ENC2=$(db "SELECT encounter FROM expeditions ORDER BY id DESC LIMIT 1" | md5sum)
ck "reload keeps the same fight state" "$ENC1" "$ENC2"
post adventure.php -d do=attack >/dev/null
ck "old attack ignored" "$(db "SELECT encounter FROM expeditions ORDER BY id DESC LIMIT 1" | md5sum)" "$ENC1"
enc() { db "SELECT encounter FROM expeditions ORDER BY id DESC LIMIT 1" | md5sum; }
# pf DO [post args]: loads the page (fresh csrf, nonce, turn) then posts; NONCE_X / TURN_X override what the page said. Prints the HTTP status.
pf() { local d=$1; shift; get adventure.php >/dev/null
  local n=$(grep -o 'name="nonce" value="[0-9a-f]*"' $H | head -1 | grep -o '[0-9a-f]\{8\}') t=$(grep -o 'id="pfight" data-turn="[0-9]*"' $H | grep -o '[0-9]*')
  post adventure.php -d do=$d -d nonce=${NONCE_X:-$n} -d turn=${TURN_X:-$t} "$@"; }
get adventure.php >/dev/null
ck "no Snack tile when there is nothing to eat" "$(grep -c 'data-t="item"' $H)" "0"
ENC1=$(enc)
ck "stale turn: redirect" "$(TURN_X=99 pf pf_play -d chain=0)" "302"; ck "stale turn ignored" "$(enc)" "$ENC1"
ck "duplicate tile: redirect" "$(pf pf_play -d chain=0,0)" "302"; ck "duplicate tile refused" "$(enc)" "$ENC1"
ck "wrong nonce: redirect" "$(NONCE_X=deadbeef pf pf_play -d chain=0)" "302"; ck "wrong nonce ignored" "$(enc)" "$ENC1"
ck "empty chain refused" "$(pf pf_play -d chain=)" "302"; ck "empty chain ignored" "$(enc)" "$ENC1"
ck "redraw with no Luck: no change" "$(pf pf_redraw -d card=0)" "302"; ck "redraw ignored" "$(enc)" "$ENC1"
N=0; while [ $N -lt 40 ]; do
  get adventure.php >/dev/null
  [ "$(db "SELECT encounter IS NULL FROM expeditions ORDER BY id DESC LIMIT 1")" = "1" ] && break
  CH=$(grep -o 'data-i="[0-9]*" data-hole="[a-z]*" data-knob="[a-z]*" data-t="[a-z]*"' $H | grep -v 'data-t="item"' | grep -o 'data-i="[0-9]*"' | grep -o '[0-9]*' | head -2 | paste -sd,)
  CODE=$(pf pf_play -d chain=$CH); [ "$CODE" = "302" ] || { echo "FAIL play returned $CODE"; FAILS=$((FAILS+1)); break; }
  N=$((N+1))
done
ck "fight ended" "$(db "SELECT encounter IS NULL FROM expeditions ORDER BY id DESC LIMIT 1")" "1"
get adventure.php >/dev/null
ck "page after fight has no card" "$(grep -c 'id="pfight"' $H)" "0"
ck "a finished fight cannot be played again" "$(post adventure.php -d do=pf_play -d turn=1 -d nonce=deadbeef -d chain=0)" "302"
ck "Almanac pages were created once" "$(db "SELECT COUNT(*) FROM encyclopedia_entries WHERE title = 'Puzzle fights'")" "1"
php -d display_errors=1 "$HERE/advforce.php" "$GAME" fight 2>&1 | tail -1
ck "run: redirect" "$(pf pf_run)" "302"
ck "run ends the fight" "$(db "SELECT encounter IS NULL FROM expeditions ORDER BY id DESC LIMIT 1")" "1"
ck "no errors in the game error log" "$(cat "$GAME/data/error-log.txt" 2>/dev/null | wc -c | tr -d ' ')" "0"
ck "no PHP warnings in server log" "$(grep -cE 'PHP (Warning|Notice|Deprecated|Fatal)' $LOG)" "0"
echo "turns played: $N"
[ $FAILS -eq 0 ] && echo "pfight ok" || echo "$FAILS FAILED"
