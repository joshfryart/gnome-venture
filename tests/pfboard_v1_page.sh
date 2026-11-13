#!/bin/bash
# 2.6.74 v1 board rules on the PAGE (setting pfight_v1): gating, the page data, the flip action, the lit-cell numbers, a whole fight, a fight under way keeps its rules.
# Usage: tests/clock.sh [GAME_COPY_DIR] [PORT] [ROUTER]   (default: copies src/game to a temp dir; never writes a DB into src)
HERE=$(cd "$(dirname "$0")" && pwd)
GAME=${1:-}; PORT=${2:-8794}; ROUTER=${3:-$HERE/router.php}
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
encq() { php -r '$p=new PDO("sqlite:'$GAME'/data/game.sqlite"); $e=json_decode($p->query("SELECT encounter FROM expeditions ORDER BY id DESC LIMIT 1")->fetchColumn(),true); $s=$e["pf"]??null; echo eval("return ".$argv[1].";");' "$1"; }
pf() { local d=$1; shift; get adventure.php >/dev/null
  local n=$(grep -o 'name="nonce" value="[0-9a-f]*"' $H | head -1 | grep -o '[0-9a-f]\{8\}') t=$(grep -o 'id="pfight" data-turn="[0-9]*"' $H | grep -o '[0-9]*')
  post adventure.php -d do=$d -d nonce=${NONCE_X:-$n} -d turn=${TURN_X:-$t} "$@"; }
set_() { db "INSERT OR REPLACE INTO settings (name,value) VALUES ('$1','$2')" >/dev/null; }
# stage C: with pfight_v1 on, a fight is dealt only after the starter is packed and "Let's fight" is pressed on the pre-fight screen
letsfight() { get adventure.php >/dev/null; if grep -q 'id="pfv-starter"' $H; then post adventure.php -d do=pfd_starter -d kit=steady >/dev/null; get adventure.php >/dev/null; fi; if grep -q 'id="pfv-pre"' $H; then post adventure.php -d do=pfv_go >/dev/null; fi; get adventure.php >/dev/null; }
set_ pfight_open 1; set_ pfight_mode board
echo "== gating"
php -d display_errors=1 "$HERE/advforce.php" "$GAME" fight 2>&1 | tail -1
get adventure.php >/dev/null
ck "pfight_v1 unset: an old board fight (no v1 data in the page)" "$(grep -c '"v1":{' $H)" "0"
ck "pfight_v1 unset: the fight state has no v1 key" "$(encq 'isset($s["v1"]) ? "v1" : "old"')" "old"
set_ pfight_v1 admin
get adventure.php >/dev/null
ck "the fight under way keeps its old rules when the flag is turned on" "$(encq 'isset($s["v1"]) ? "v1" : "old"')" "old"
ck "flip is refused in an old fight" "$(pf pfb_flip -d hand=0)" "302"; ck "old fight: no piece flipped" "$(encq 'json_encode(array_filter($s["me"]["hand"], fn($t) => !empty($t["flip"])))')" "[]"
php -d display_errors=1 "$HERE/advforce.php" "$GAME" fight 2>&1 | tail -1
get adventure.php >/dev/null
ck "pfight_v1 = admin: a player who is not an admin still gets the old rules" "$(encq 'isset($s["v1"]) ? "v1" : "old"')" "old"
db "UPDATE users SET role='admin' WHERE username='sprout'" >/dev/null; set_ pfight_mode chain
php -d display_errors=1 "$HERE/advforce.php" "$GAME" fight 2>&1 | tail -1
get adventure.php >/dev/null
ck "stage C: an admin first packs a box (the starter pick), nothing is dealt" "$(grep -c 'id="pfv-starter"' $H) $(encq 'isset($s) ? "dealt" : "not dealt"')" "1 not dealt"
post adventure.php -d do=pfd_starter -d kit=steady >/dev/null; get adventure.php >/dev/null
ck "stage C: then the pre-fight screen (creature card, Let's fight), still nothing dealt" "$(grep -c 'id="pfv-pre"' $H) $(grep -c 'class="foecard"' $H) $(grep -c 'value="pfv_go"' $H) $(encq 'isset($s) ? "dealt" : "not dealt"')" "1 1 1 not dealt"
letsfight
ck "pfight_v1 = admin, an admin: a v1 fight, on the board even when pfight_mode is chain" "$(encq '(isset($s["v1"]) ? "v1" : "old") . " " . $s["mode"]')" "v1 board"
echo "== the page of a v1 fight"
ck "board page" "$(grep -c 'data-mode="board"' $H)" "1"
ck "page data: rule numbers, ground, forecast, aim, flip" "$(grep -c '"v1":{"limit":3.*"ter":.*"envs":.*"aim":.*"flip":{"on":true,"used":false}' $H)" "1"
ck "page data (2.6.75): the environment's two face-up pieces (a list), no ground cells, no forecast" "$(grep -c '"env":true.*"ter":{}.*"envs":\[\].*"env":{"next":\[{"k":"e:[a-z]*","n":"[A-Za-z]*","kind":"[a-z]*","life":[23],"e":{' $H)" "1"
ck "page (2.6.75): the legend row is the environment strip (no terrain legend)" "$(grep -c 'id="pfv-legend" role="group" aria-label="The environment: its next pieces"' $H) $(grep -c 'aria-label="Terrain legend"' $H)" "1 0"
ck "page data: the board size of the creature (small: 4x4 since 2.6.94, every size is 4x4)" "$(encq '$s["size"] . " " . $s["w"] . "x" . $s["h"]')" "small 4x4"; ck "page data carries that size" "$(grep -c '"w":4,"h":4' $H)" "1"
ck "page data: hand pieces carry life, source, flip" "$(grep -c '"life":[234],"src":"[a-z]*","flip":false,"canflip":true' $H | awk '{print ($1>=1)?"yes":"no"}')" "yes"
ck "no draw pile or seed in the page" "$(grep -c '"rng"\|"draw"' $H)" "0"
ck "opening: start piece next to the blank (centre 2,2)" "$(pf pfb_play -d moves='0,1,2')" "302"
ck "the fight started" "$(encq 'empty($s["start"]) ? "started" : "opening"')" "started"
get adventure.php >/dev/null; ck "the creature's aim is in the page" "$(grep -c '"aim":{"k":"f:' $H)" "1"
echo "== flip"
T0=$(encq '$s["turn"]')
ck "flip: redirect" "$(pf pfb_flip -d hand=0)" "302"
ck "flip: the piece is flipped, the turn has not moved" "$(encq '(!empty($s["me"]["hand"][0]["flip"]) ? "flipped" : "not") . " " . ($s["turn"] == '$T0' ? "same turn" : "moved")')" "flipped same turn"
get adventure.php >/dev/null; ck "flip: the page says the flip is never used up (2.6.95: no limit)" "$(grep -c '"flip":{"on":true,"used":false}' $H)" "1"
pf pfb_flip -d hand=1 >/dev/null; ck "flip: a second piece flips too (2.6.95: no limit)" "$(encq 'empty($s["me"]["hand"][1]["flip"]) ? "no" : "yes"')" "yes"
ENC1=$(enc); TURN_X=99 pf pfb_flip -d hand=0 >/dev/null; ck "flip: a stale turn changes nothing" "$(enc)" "$ENC1"
NONCE_X=deadbeef pf pfb_flip -d hand=0 >/dev/null; ck "flip: a wrong nonce changes nothing" "$(enc)" "$ENC1"
pf pfb_flip -d hand=0 >/dev/null; ck "flip: the same piece again flips it back" "$(encq 'empty($s["me"]["hand"][0]["flip"]) ? "back" : "flipped"')" "back"
echo "== lit-cell numbers"
ENC1=$(enc); pf pfb_cells -d i=0 >/dev/null; PV=$(cat $H)
ck "numbers answer ok, with the flipped set" "$(echo "$PV" | grep -c '"ok":true.*"flipped":')" "1"
ck "numbers: no reply number" "$(echo "$PV" | grep -c '"rp"')" "0"
ck "numbers changed nothing" "$(enc)" "$ENC1"
ck "numbers: no draw pile or seed" "$(echo "$PV" | grep -c 'rng\|"draw"\|seed')" "0"
echo "== a whole v1 fight on the page"
set_ pfight_v1 0   # the flag goes off mid-fight: this fight keeps the v1 rules
N=0; ENVN=0; PLN=0; FIN=0; OLDT=0; while [ $N -lt 60 ]; do
  [ "$(db "SELECT encounter IS NULL FROM expeditions ORDER BY id DESC LIMIT 1")" = "1" ] && break
  MV=$(php "$HERE/pfboard_move.php" "$GAME" 2>&1 | tail -1)
  if [ "$MV" = "PASS" ]; then CODE=$(pf pfb_pass); elif [ "$MV" = "NONE" ]; then break; elif [ "${MV%% *}" = "FLIP" ]; then CODE=$(pf pfb_flip -d hand="${MV##* }"); else CODE=$(pf pfb_play -d moves="$MV"); fi
  [ "$CODE" = "302" ] || { echo "FAIL play returned $CODE"; FAILS=$((FAILS+1)); break; }
  N=$((N+1))
  [ "$(encq 'isset($s["v1"]) ? 1 : 0')" = "0" ] && [ "$(db "SELECT encounter IS NULL FROM expeditions ORDER BY id DESC LIMIT 1")" != "1" ] && { echo "FAIL the fight lost its v1 rules"; FAILS=$((FAILS+1)); break; }
  get adventure.php >/dev/null; ENVN=$((ENVN + $(grep -o 'class="pf-chip env' $H | wc -l))); ENVL=$((ENVL + $(grep -o 'class="pf-chip env[^>]*aria-label="Environment: ' $H | wc -l))); ENVT=$((ENVT + $(grep -o 'class="pf-chip env[^>]*aria-label="Terrain: ' $H | wc -l))); PLN=$((PLN + $(grep -o '"env":"place","x":[0-9],"y":[0-9]' $H | wc -l))); FIN=$((FIN + $(grep -o '"env":"fire","x":[0-9],"y":[0-9][^}]*"kind":"[a-z]*","for":"[a-z]*"' $H | wc -l))); OLDT=$((OLDT + $(grep -o '"env":"\(sunbeam\|creep\|puddle\|gust\|thorn\|bramble\)"' $H | wc -l)))
  if [ "$(db "SELECT encounter LIKE '%\"won\":%' OR encounter LIKE '%\"lost\":%' FROM expeditions ORDER BY id DESC LIMIT 1")" = "1" ]; then ck "End fight (won, or 2.6.78: lost and waiting for Continue): redirect" "$(pf pf_finish)" "302"; break; fi
done
ck "the fight ended" "$(db "SELECT encounter IS NULL FROM expeditions ORDER BY id DESC LIMIT 1")" "1"
ck "2.6.75: environment history chips say Environment, never Terrain" "$([ $ENVL -ge 1 ] && echo yes || echo no) $ENVT" "yes 0"
ck "the environment's turn showed as history chips" "$([ $ENVN -ge 1 ] && echo yes || echo no)" "yes"
ck "2.6.75: the replay carries the environment's placements (env place, cell) and its pieces firing in chains (env fire, kind, for)" "$([ $PLN -ge 1 ] && [ $FIN -ge 1 ] && echo yes || echo "no ($PLN placed, $FIN fired)")" "yes"
ck "2.6.75: no 2.6.74 terrain event in a new fight" "$OLDT" "0"
php -d display_errors=1 "$HERE/advforce.php" "$GAME" fight 2>&1 | tail -1
get adventure.php >/dev/null
ck "flag off again: the next fight is an old one (pfight_mode chain: the strip)" "$(encq '(isset($s["v1"]) ? "v1" : "old") . " " . ($s["mode"] ?? "strip")')" "old strip"
ck "no errors in the game error log" "$(cat "$GAME/data/error-log.txt" 2>/dev/null | wc -c | tr -d ' ')" "0"
grep -E "PHP (Warning|Notice|Deprecated|Fatal)" $LOG | head -3 | cut -c1-260
ck "no PHP warnings in server log" "$(grep -cE 'PHP (Warning|Notice|Deprecated|Fatal)' $LOG)" "0"
echo "actions played: $N"
[ $FAILS -eq 0 ] && echo "pfboard_v1_page ok" || echo "$FAILS FAILED"
