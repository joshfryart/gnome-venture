#!/bin/bash
# Puzzle combat BOARD mode page test: setting, board render, planned moves posted once, stale/nonce/bad moves, fight to the end, pass.
# Usage: tests/clock.sh [GAME_COPY_DIR] [PORT] [ROUTER]   (default: copies src/game to a temp dir; never writes a DB into src)
HERE=$(cd "$(dirname "$0")" && pwd)
GAME=${1:-}; PORT=${2:-8793}; ROUTER=${3:-$HERE/router.php}
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
enc() { db "SELECT encounter FROM expeditions ORDER BY id DESC LIMIT 1" | md5sum; }
pf() { local d=$1; shift; get adventure.php >/dev/null
  local n=$(grep -o 'name="nonce" value="[0-9a-f]*"' $H | head -1 | grep -o '[0-9a-f]\{8\}') t=$(grep -o 'id="pfight" data-turn="[0-9]*"' $H | grep -o '[0-9]*')
  post adventure.php -d do=$d -d nonce=${NONCE_X:-$n} -d turn=${TURN_X:-$t} "$@"; }
db "INSERT OR REPLACE INTO settings (name,value) VALUES ('pfight_open','1')" >/dev/null; db "INSERT OR REPLACE INTO settings (name,value) VALUES ('pfight_mode','board')" >/dev/null
php -d display_errors=1 "$HERE/advforce.php" "$GAME" fight 2>&1 | tail -1
get adventure.php >/dev/null
ck "board page" "$(grep -c 'data-mode="board"' $H)" "1"
ck "board grid is there" "$(grep -c 'id="pfb-board"' $H)" "1"
ck "no old attack button" "$(grep -c 'value="attack"' $H)" "0"
ck "hand pieces" "$( [ $(grep -o 'class="pf-tile pf-h pf-bp' $H | wc -l) -ge 5 ] && echo yes)" "yes"
ck "the board starts with a creature piece" "$(grep -o '"by":"foe"' $H | wc -l | awk '{print ($1>=1)?"yes":"no"}')" "yes"
ck "no draw pile or seed in the page" "$(grep -c '"rng"\|"draw"' $H)" "0"
ENC1=$(enc)
ck "bad moves: redirect" "$(pf pfb_play -d moves='0,0,0')" "302"; ck "off-board / no-contact move ignored" "$(enc)" "$ENC1"
ck "garbage moves: redirect" "$(pf pfb_play -d moves='a,b,c')" "302"; ck "garbage ignored" "$(enc)" "$ENC1"
ck "stale turn: redirect" "$(TURN_X=99 pf pfb_play -d moves='0,2,2')" "302"; ck "stale turn ignored" "$(enc)" "$ENC1"
# the live preview: read only, public things only
MV0=$(php "$HERE/pfboard_move.php" "$GAME" 2>&1 | tail -1)
if [ "$MV0" != "PASS" ] && [ "$MV0" != "NONE" ]; then
  pf pfb_preview -d moves="$MV0" >/dev/null; PV=$(cat $H)
  ck "preview answers ok" "$(echo "$PV" | grep -c '"ok":true')" "1"
  ck "preview lists what happens" "$(echo "$PV" | grep -c '"lines":\["')" "1"
  ck "preview changed nothing" "$(enc)" "$ENC1"
  ck "preview does not show the draw pile or seed" "$(echo "$PV" | grep -c 'rng\|"draw"\|seed')" "0"
fi
pf pfb_preview -d moves='0,0,0' >/dev/null; ck "preview of an impossible move says no" "$(grep -c '"ok":false' $H)" "1"
NONCE_X=deadbeef pf pfb_preview -d moves='0,2,2' >/dev/null; ck "preview with a wrong nonce says no" "$(grep -c '"ok":false' $H)" "1"; ck "still unchanged" "$(enc)" "$ENC1"
ck "wrong nonce: redirect" "$(NONCE_X=deadbeef pf pfb_play -d moves='0,2,2')" "302"; ck "wrong nonce ignored" "$(enc)" "$ENC1"
ck "a strip play on a board fight is refused" "$(pf pf_play -d chain=0)" "302"; ck "strip play ignored" "$(enc)" "$ENC1"
ck "pass with pieces that fit is refused" "$(pf pfb_pass)" "302"; ck "pass ignored" "$(enc)" "$ENC1"
# set pieces aside (Connect), play the group; the page refuses a second group and a bad group spot
JM=$(php "$HERE/pfboard_move.php" "$GAME" join 2>&1 | tail -1)
if [ "$JM" != "NONE" ]; then
  ck "connect: redirect" "$(pf pfb_play -d moves="$JM")" "302"
  ck "connect set two pieces aside" "$(db "SELECT encounter LIKE '%\"held\":{%' FROM expeditions ORDER BY id DESC LIMIT 1")" "1"
  get adventure.php >/dev/null; ck "the page shows the set-aside group" "$(grep -c 'id="pf-held"' $H)" "1"
  ENC2=$(enc); pf pfb_play -d moves="$JM" >/dev/null; ck "a second group is refused" "$(enc)" "$ENC2"
  AM=$(php "$HERE/pfboard_move.php" "$GAME" add 2>&1 | tail -1)
  if [ "$AM" != "NONE" ]; then ck "add a third piece" "$(pf pfb_play -d moves="$AM")" "302"; fi
  GM=$(php "$HERE/pfboard_move.php" "$GAME" group 2>&1 | tail -1)
  ck "a group put off the board is refused" "$(pf pfb_play -d moves='c,99,99' >/dev/null; db "SELECT encounter LIKE '%\"held\":null%' FROM expeditions ORDER BY id DESC LIMIT 1")" "0"
  if [ "$GM" != "NONE" ]; then ck "play the group" "$(pf pfb_play -d moves="$GM")" "302"; ck "the group left the set-aside area" "$(db "SELECT encounter LIKE '%\"held\":null%' FROM expeditions ORDER BY id DESC LIMIT 1")" "1"; fi
else echo "note: no joinable pair in this hand (connect not exercised)"; fi
N=0; while [ $N -lt 40 ]; do
  [ "$(db "SELECT encounter IS NULL FROM expeditions ORDER BY id DESC LIMIT 1")" = "1" ] && break
  MV=$(php "$HERE/pfboard_move.php" "$GAME" 2>&1 | tail -1)
  if [ "$MV" = "PASS" ]; then CODE=$(pf pfb_pass); elif [ "$MV" = "NONE" ]; then break; else CODE=$(pf pfb_play -d moves="$MV"); fi
  [ "$CODE" = "302" ] || { echo "FAIL play returned $CODE"; FAILS=$((FAILS+1)); break; }
  N=$((N+1))
done
ck "fight ended" "$(db "SELECT encounter IS NULL FROM expeditions ORDER BY id DESC LIMIT 1")" "1"
get adventure.php >/dev/null
ck "page after fight has no board" "$(grep -c 'id="pfb-board"' $H)" "0"
ck "no errors in the game error log" "$(cat "$GAME/data/error-log.txt" 2>/dev/null | wc -c | tr -d ' ')" "0"
grep -E "PHP (Warning|Notice|Deprecated|Fatal)" $LOG | head -3 | cut -c1-260
ck "no PHP warnings in server log" "$(grep -cE 'PHP (Warning|Notice|Deprecated|Fatal)' $LOG)" "0"
echo "turns played: $N"
[ $FAILS -eq 0 ] && echo "pfboard ok" || echo "$FAILS FAILED"
