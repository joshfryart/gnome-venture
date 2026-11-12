#!/bin/bash
# 2.6.74 stage C, the v1 PAGES (setting pfight_v1): flag-off parity of the old pages, the Puzzle box page (kit, belt, pals), the starter pick and the carry-over of an old box,
# the POST actions through the pages (starter, toggle, auto-use, equip, fix), the gate and the pre-fight screen, flip, the v1 fight page, the result card,
# JS syntax, the built fork (tools/build_pfboardv1.py --check), and a browser pass at 390px, light and dark, over every new screen (tests/pbox_v1_shots.js; SHOT=dir keeps the pictures).
# Usage: tests/pbox_v1.sh [GAME_COPY_DIR] [PORT] [ROUTER]   (default: copies src/game to a temp dir; never writes a DB into src)
HERE=$(cd "$(dirname "$0")" && pwd); ROOT=$(cd "$HERE/.." && pwd)
GAME=${1:-}; PORT=${2:-8797}; ROUTER=${3:-$HERE/router.php}
if [ -z "$GAME" ]; then T=$(mktemp -d); cp -r "$HERE/../game" "$T/game"; GAME=$T/game; fi
rm -f "$GAME/config.php"; rm -rf "$GAME/data"; mkdir -p "$GAME/data"
BASE=http://127.0.0.1:$PORT
LOG=$(mktemp)
php -d session.save_path=/tmp -d display_errors=1 -S 127.0.0.1:$PORT -t "$GAME" "$ROUTER" >$LOG 2>&1 & PID=$!; sleep 1
trap "kill \$PID \$PID0 2>/dev/null; [ -n \"\$T\" ] && rm -rf \"\$T\"; [ -n \"\$T0\" ] && rm -rf \"\$T0\"" EXIT
C=$(mktemp); H=$(mktemp)
csrf() { grep -o 'name="csrf" value="[^"]*"' "$1" | head -1 | sed 's/.*value="\([^"]*\)".*/\1/'; }
get() { curl -s -c $C -b $C "$BASE/$1" -o $H -w '%{http_code}'; }
post() { local page=$1; shift; curl -s -c $C -b $C -X POST "$BASE/$page" --data-urlencode "csrf=$(csrf $H)" "$@" -o $H -w '%{http_code}'; }
db() { php -r '$p=new PDO("sqlite:'$GAME'/data/game.sqlite"); foreach($p->query($argv[1])->fetchAll(PDO::FETCH_NUM) as $r) echo implode(" | ",$r),"\n";' "$1"; }
FAILS=0; ck() { if [ "$2" = "$3" ]; then echo "ok   $1"; else echo "FAIL $1 (got '$2', want '$3')"; FAILS=$((FAILS+1)); fi; }
set_() { db "INSERT OR REPLACE INTO settings (name,value) VALUES ('$1','$2')" >/dev/null; }
encq() { php -r '$p=new PDO("sqlite:'$GAME'/data/game.sqlite"); $e=json_decode($p->query("SELECT encounter FROM expeditions ORDER BY id DESC LIMIT 1")->fetchColumn(),true); $s=$e["pf"]??null; echo eval("return ".$argv[1].";");' "$1"; }
pf() { local d=$1; shift; get adventure.php >/dev/null
  local n=$(grep -o 'name="nonce" value="[0-9a-f]*"' $H | head -1 | grep -o '[0-9a-f]\{8\}') t=$(grep -o 'id="pfight" data-turn="[0-9]*"' $H | grep -o '[0-9]*')
  post adventure.php -d do=$d -d nonce=$n -d turn=$t "$@"; }
# a page without what differs from load to load (tokens, clocks, the version stamp on assets)
norm() { sed -e 's/name="csrf" value="[^"]*"/CSRF/g' -e 's/name="_n" value="[^"]*"/N/g' -e 's/name="nonce" value="[^"]*"/NONCE/g' -e 's/[0-9][0-9]:[0-9][0-9]/HH:MM/g' "$1"; }
install() {   # install, register sprout, onboard: on the server at $1 with the game copy $2
  local B=$BASE G=$GAME; BASE=$1; GAME=$2
  get install.php >/dev/null
  post install.php -d driver=sqlite -d "site_name=Gnome Venture" -d base_url= -d admin_user=admin -d admin_email=a@b.local -d admin_pass=TestPassword123 -d admin_pass2=TestPassword123 >/dev/null
  grep -q 'All planted' $H || { echo "INSTALL FAILED"; tail -5 $LOG; exit 1; }
  rm -f $C
  get register.php >/dev/null; post register.php -d username=sprout -d email=s@b.local -d password=TestPass123! -d password2=TestPass123! -d rules=1 -d age=1 >/dev/null
  get welcome.php >/dev/null; post welcome.php -d do=gnome -d "gnome_name=Bramble" -d 'hat=#2e7d4f' -d 'beard=#b5651d' >/dev/null
  get 'welcome.php?step=place' >/dev/null
  local RID=$(db "SELECT id FROM regions WHERE code='NA'")
  local VID=$(db "SELECT l.id FROM locations l WHERE l.region_id=$RID AND l.kind='village' AND EXISTS (SELECT 1 FROM routes r WHERE r.kind='road' AND (r.a_id=l.id OR r.b_id=l.id)) ORDER BY l.sort_order LIMIT 1 OFFSET 1")
  post welcome.php -d do=place -d village_id=$VID >/dev/null
  get 'welcome.php?step=garden' >/dev/null; post welcome.php -d do=finish -d 'garden_name=Test Patch' >/dev/null
  db "UPDATE users SET energy=100, tour_step=99 WHERE username='sprout'" >/dev/null
  db "INSERT OR REPLACE INTO settings (name,value) VALUES ('pfight_open','1')" >/dev/null; db "INSERT OR REPLACE INTO settings (name,value) VALUES ('pfight_mode','board')" >/dev/null
  BASE=$B; GAME=$G
}
echo "== static: JS syntax, the built fork, php -l"
for f in pfboardv1.js pfv1box.js pfboard.js; do ck "node --check assets/$f" "$(node --check "$ROOT/game/assets/$f" 2>&1 | wc -l | tr -d ' ')" "0"; done
ck "pfboardv1.js is what tools/build_pfboardv1.py builds from pfboard.js" "$(python3 "$ROOT/tools/build_pfboardv1.py" --check 2>&1 | wc -l | tr -d ' ')" "0"
for f in includes/pfdeck_view.php includes/pfight_game.php puzzlebox.php adventure.php gnome.php includes/layout.php; do ck "php -l $f" "$(php -l "$ROOT/game/$f" 2>&1 | grep -c 'No syntax errors')" "1"; done
ck "no inline style or script in the v1 view (CSP)" "$(grep -c 'style="\|<script>\|onclick=' "$ROOT/game/includes/pfdeck_view.php")" "0"
echo "== install + register + welcome"
install $BASE $GAME; echo installed

echo "== flag off: the old pages, byte for byte"
OLD=ba9c416c   # the commit before stage C
if git -C "$ROOT" cat-file -e $OLD^{commit} 2>/dev/null; then
  ck "pfboard.js, pfight.js, pbox.js, pfight.css, pfparts.js are untouched since stage B" "$(git -C "$ROOT" diff --stat $OLD -- game/assets/pfboard.js game/assets/pfight.js game/assets/pbox.js game/assets/pfight.css game/assets/pfparts.js | wc -l | tr -d ' ')" "0"
  T0=$(mktemp -d); git -C "$ROOT" archive $OLD game | tar -x -C "$T0"; GAME0=$T0/game; mkdir -p "$GAME0/data"; PORT0=$((PORT+1)); BASE0=http://127.0.0.1:$PORT0
  php -d session.save_path=/tmp -d display_errors=1 -S 127.0.0.1:$PORT0 -t "$GAME0" "$ROUTER" >/dev/null 2>&1 & PID0=$!; sleep 1
  C1=$C; C=$(mktemp); install $BASE0 $GAME0; C0=$C; C=$C1
  for G in "$GAME" "$GAME0"; do php -d display_errors=1 "$HERE/advforce.php" "$G" >/dev/null 2>&1; php -r '$p=new PDO("sqlite:'$G'/data/game.sqlite"); $p->exec("UPDATE users SET energy=50, game_minute=600 WHERE username=\"sprout\""); $e=$p->query("SELECT id FROM expeditions ORDER BY id DESC LIMIT 1")->fetchColumn(); $c=$p->query("SELECT id, hp FROM creatures WHERE level <= 3 ORDER BY id LIMIT 1")->fetch(PDO::FETCH_NUM); $pf=["type"=>"creature","id"=>(int)$c[0],"lv"=>0,"sp"=>100,"hpp"=>100,"hp"=>(int)$c[1],"max"=>(int)$c[1],"bark"=>0,"poison"=>0,"used"=>false]; $p->prepare("UPDATE expeditions SET encounter=? WHERE id=?")->execute([json_encode($pf), $e]);'; done
  for pg in puzzlebox.php 'gnome.php?tab=gnome' 'gnome.php?tab=stats' book.php; do
    get "$pg" >/dev/null; norm $H > $H.new; curl -s -c $C0 -b $C0 "$BASE0/$pg" -o $H.o; norm $H.o > $H.old
    [ -n "$DEBUG" ] && diff $H.new $H.old | cut -c1-300 | head -12
    ck "flag off: $pg is the page of the commit before stage C" "$(diff $H.new $H.old | wc -l | tr -d ' ')" "0"
  done
  # the fight page: the hand is dealt at random, so both copies get the same state (the new copy's) before they draw it
  get adventure.php >/dev/null; ENC=$(php -r '$p=new PDO("sqlite:'$GAME'/data/game.sqlite"); echo $p->query("SELECT encounter FROM expeditions ORDER BY id DESC LIMIT 1")->fetchColumn();')
  php -r '$p=new PDO("sqlite:'$GAME0'/data/game.sqlite"); $p->prepare("UPDATE expeditions SET encounter=? WHERE id=(SELECT MAX(id) FROM expeditions)")->execute([$argv[1]]);' "$ENC"
  get adventure.php >/dev/null; norm $H > $H.new; curl -s -c $C0 -b $C0 "$BASE0/adventure.php" -o $H.o; norm $H.o > $H.old
  ck "flag off: the board fight page is the page of the commit before stage C (same fight state)" "$(grep -c 'id="pfb-board"' $H.new) $(diff $H.new $H.old | wc -l | tr -d ' ')" "1 0"
  db "UPDATE expeditions SET encounter=NULL" >/dev/null
else echo "skip the comparison with commit $OLD (not in this checkout)"; fi
get puzzlebox.php >/dev/null; cp $H $H.off
ck "flag unset: the old Puzzle box form, nothing of v1 on the page" "$(grep -c 'id="pbox"' $H) $(grep -c 'pfv\|pfboardv1' $H)" "1 0"
set_ pfight_v1 admin
get puzzlebox.php >/dev/null
ck "pfight_v1 = admin, a player who is not an admin: the same old page" "$(norm $H | diff - <(norm $H.off) | wc -l | tr -d ' ')" "0"
get 'gnome.php?tab=gnome' >/dev/null; ck "a player: no Puzzle box tile in the Hovel, none in the menu" "$(grep -c 'gvtl">Puzzle box\|ntl">Puzzle box' $H)" "0"
post puzzlebox.php -d do=save -d 'tile[]=swing' -d 'tile[]=dodge' -d 'tile[]=rest' -d 'tile[]=charm' -d 'tile[]=hide' -d 'tile[]=snack' -d 'tile[]=taunt' >/dev/null
ck "a player packs an old box (7 pieces, kept for the carry-over)" "$(db "SELECT COUNT(*) FROM user_pbox")" "1"

echo "== the starter pick (an admin)"
db "UPDATE users SET role='admin' WHERE username='sprout'" >/dev/null
get 'gnome.php?tab=gnome' >/dev/null; ck "an admin: the Puzzle box tile in the Hovel and in the menu" "$(grep -c 'gvtl">Puzzle box' $H) $(grep -c 'ntl">Puzzle box' $H)" "1 1"
ck "puzzlebox.php: the starter pick, 4 core pieces locked, 12 on offer, three kits" "$(get puzzlebox.php) $(grep -c 'id="pfv-starter"' $H) $(grep -o 'class="pc lock"' $H | wc -l | tr -d ' ') $(grep -o 'data-a="spick"' $H | wc -l | tr -d ' ') $(grep -o 'name="kit"' $H | wc -l | tr -d ' ')" "200 1 4 12 3"
ck "the old box's pieces that are on offer start picked (hide, snack)" "$(grep -o 'sel" data-a="spick"' $H | wc -l | tr -d ' ')" "2"
ck "starter: 5 picks are refused, nothing saved" "$(post puzzlebox.php -d do=pfd_starter -d 'pick[]=jab' -d 'pick[]=snack' -d 'pick[]=hide' -d 'pick[]=brace' -d 'pick[]=hum') $(db "SELECT COUNT(*) FROM pf_deck_pieces")" "302 0"
get puzzlebox.php >/dev/null
ck "starter: 6 picks are packed (10 rows)" "$(post puzzlebox.php -d do=pfd_starter -d 'pick[]=jab' -d 'pick[]=snack' -d 'pick[]=brace' -d 'pick[]=hum' -d 'pick[]=pierce' -d 'pick[]=swing#2') $(db "SELECT COUNT(*) FROM pf_deck_pieces WHERE starter=1")" "302 10"
ck "carry-over: the old box's Hide (owned, not picked) is switched on; Taunt is not owned without the pick" "$(db "SELECT piece_key || ':' || active FROM pf_deck_pieces WHERE starter=0 ORDER BY piece_key" | tr '\n' ' ')" "hide:1 "

echo "== the Puzzle box page"
php -d display_errors=1 "$HERE/pbox_v1_seed.php" "$GAME" box | tail -1
get puzzlebox.php >/dev/null
ck "the box: tabs, deck bar, Teamwork, harmony meter, cap pips, filter, auto-use switch, detail line" "$(grep -c 'id="pfv-box"' $H) $(grep -c 'class="meter"' $H) $(grep -c 'class="teamrow"' $H) $(grep -c 'class="hmeter' $H) $(grep -o 'class="capp ' $H | wc -l | tr -d ' ') $(grep -c 'id="pfv-filt"' $H) $(grep -c 'id="pfv-auto"' $H) $(grep -c 'id="pfv-info"' $H)" "1 1 1 1 2 1 1 1"
ck "the kit: packed pieces and a collection, each with art data, value and expiry pips" "$([ $(grep -o 'data-a="tog"' $H | wc -l) -ge 14 ] && echo many) $([ $(grep -o 'class="cvh" data-p=' $H | wc -l) -ge 14 ] && echo art) $(grep -c 'class="pc-x' $H | head -1 | sed 's/[1-9][0-9]*/pips/')" "many art pips"
ck "toggle through the page: Jab out (no flash for a switch), back in" "$(post puzzlebox.php -d do=pfd_toggle -d key=jab -d on=0) $(db "SELECT active FROM pf_deck_pieces WHERE piece_key='jab'") $(get puzzlebox.php >/dev/null; post puzzlebox.php -d do=pfd_toggle -d key=jab -d on=1 >/dev/null; db "SELECT active FROM pf_deck_pieces WHERE piece_key='jab'")" "302 0 1"
get 'puzzlebox.php?t=belt' >/dev/null
ck "the belt tab: tier chips, slots with durability bars, tools, repair kits, a link to Twigg's" "$(grep -c 'pfv-tier' $H) $(grep -o 'class="bslot"' $H | wc -l | tr -d ' ') $([ $(grep -o 'class="toolrow' $H | wc -l) -ge 4 ] && echo tools) $(grep -c 'repair kits: 2' $H) $(grep -c 'href="/shop.php"' $H)" "1 3 tools 1 1"
ck "a broken tool shows Fix, a worn one on the belt too" "$(grep -o 'value="pfd_fix"' $H | wc -l | tr -d ' ') $(grep -c 'toolrow t1 broken' $H)" "2 1"
ck "fix through the page: one kit used, the axe is whole again" "$(post 'puzzlebox.php' -d do=pfd_fix -d tool=axe -d t=belt) $(db "SELECT wear FROM pf_tool_wear WHERE tool_type='axe'") $(db "SELECT ui.qty FROM user_items ui JOIN items i ON i.id=ui.item_id WHERE i.slug='tool-repair-kit'")" "302 0 1"
get 'puzzlebox.php?t=belt' >/dev/null
ck "the redirect keeps the tab; take a tool off, put it back on" "$(grep -c 'class="on" aria-current="page">Belt' $H) $(post puzzlebox.php -d do=pfd_unequip -d tool=water -d t=belt) $(db "SELECT COUNT(*) FROM pf_belts WHERE tool_type='water'") $(get 'puzzlebox.php?t=belt' >/dev/null; post puzzlebox.php -d do=pfd_equip -d tool=water -d t=belt) $(db "SELECT COUNT(*) FROM pf_belts WHERE tool_type='water'")" "1 302 0 302 1"
get 'puzzlebox.php?t=pals' >/dev/null
ck "the pals tab: the party's pieces and a link to the Pal Book" "$(grep -o 'class="pc r[0-9] gear sel"' $H | wc -l | tr -d ' ') $(grep -c 'puzzlepals.php' $H | sed 's/[1-9][0-9]*/link/')" "2 link"
ck "auto-use through the page: on, and the page says so" "$(post puzzlebox.php -d do=pfd_auto -d on=1) $(db "SELECT auto_use FROM pf_decks") $(get puzzlebox.php >/dev/null; grep -c 'Auto deck is on' $H)" "302 1 1"
get puzzlebox.php >/dev/null; post puzzlebox.php -d do=pfd_auto -d on=0 >/dev/null

echo "== the gate and the pre-fight screen"
php -d display_errors=1 "$HERE/pbox_v1_seed.php" "$GAME" fight medium | tail -1
get adventure.php >/dev/null
ck "a creature appears: the pre-fight screen, nothing dealt, the deck not locked" "$(grep -c 'id="pfv-pre"' $H) $(grep -c 'id="pfb-board"' $H) $(encq 'isset($s) ? "dealt" : "not dealt"')" "1 0 not dealt"
ck "the creature card: class, size and board, layers (base 4, region, unique 3), 8 pieces" "$(grep -c 'class="foecard"' $H) $(grep -c 'medium · 5×5' $H) $(grep -o 'class="L-[a-z]*" data-f="[0-9]"' $H | tr '\n' ' ') $(grep -o 'class="pc L-[a-z]*"' $H | wc -l | tr -d ' ')" "1 1 class=\"L-base\" data-f=\"4\" class=\"L-reg\" data-f=\"1\" class=\"L-uni\" data-f=\"3\"  8"
ck "auto off: the deck with a bench, swaps allowed (toggle on the adventure page)" "$(grep -c '>Bench <' $H) $(post adventure.php -d do=pfd_toggle -d key=hum -d on=0) $(db "SELECT active FROM pf_deck_pieces WHERE piece_key='hum'") $(encq 'isset($s) ? "dealt" : "not dealt"')" "1 302 0 not dealt"
get adventure.php >/dev/null; post adventure.php -d do=pfd_auto -d on=1 >/dev/null; get adventure.php >/dev/null
ck "auto on: the card is still shown, the deck is read-only, the note and Turn off and edit" "$(grep -c 'class="foecard"' $H) $(grep -c '>Bench <' $H) $(grep -c 'Auto deck is active' $H) $(grep -c 'Turn off and edit' $H) $(grep -o 'data-a="tog"' $H | wc -l | tr -d ' ')" "1 0 1 1 0"
post adventure.php -d do=pfd_auto -d on=0 >/dev/null; get adventure.php >/dev/null
ck "Turn off and edit: the bench is back" "$(grep -c '>Bench <' $H)" "1"
ck "Let's fight: the fight is dealt (a v1 board of the creature's size)" "$(post adventure.php -d do=pfv_go) $(get adventure.php >/dev/null; grep -c 'id="pfb-board"' $H) $(encq '$s["w"] . "x" . $s["h"] . " " . (isset($s["v1"]) ? "v1" : "old")')" "302 1 5x5 v1"
ck "once the fight has started the deck is locked (toggle on the adventure page and in the box)" "$(post adventure.php -d do=pfd_toggle -d key=hum -d on=1 >/dev/null; db "SELECT active FROM pf_deck_pieces WHERE piece_key='hum'") $(get puzzlebox.php >/dev/null; post puzzlebox.php -d do=pfd_toggle -d key=hum -d on=1 >/dev/null; db "SELECT active FROM pf_deck_pieces WHERE piece_key='hum'") $(get puzzlebox.php >/dev/null; grep -c 'data-locked="1"' $H) $(grep -o 'data-a="tog"' $H | wc -l | tr -d ' ')" "0 0 1 0"

echo "== the v1 fight page"
get adventure.php >/dev/null
ck "the page: v1 class, rows, legend, Flip button and form, the v1 script and style, not the old script" "$(grep -c 'pf-boardmode.* pf-v1"' $H) $(grep -c 'id="pfv-row"' $H) $(grep -c 'id="pfv-legend"' $H) $(grep -c 'id="pf-flip"' $H) $(grep -c 'id="pf-fform"' $H) $(grep -c 'assets/pfboardv1.js' $H) $(grep -c 'assets/pfv1.css' $H) $(grep -c 'assets/pfboard.js' $H)" "1 1 1 1 1 1 1 0"
ck "page data for the script: tools, the box link, the turn cap; no prev state before the first turn" "$(grep -c '"tools":{' $H) $(grep -c '"box":"' $H) $(grep -c '"turncap":' $H) $(grep -c '"prev":null' $H)" "1 1 1 1"
ck "opening: start piece next to the blank" "$(pf pfb_play -d moves='0,1,2')" "302"
T0=$(encq '$s["turn"]'); pf pfb_flip -d hand=0 >/dev/null
ck "flip through the page: the piece is flipped, the turn has not moved" "$(encq '!empty($s["me"]["hand"][0]["flip"]) ? "flipped" : "not"') $([ "$(encq '$s["turn"]')" = "$T0" ] && echo same turn)" "flipped same turn"
pf pfb_flip -d hand=0 >/dev/null
php -d display_errors=1 "$HERE/pbox_v1_seed.php" "$GAME" midfight 8 3 | tail -1
get adventure.php >/dev/null
ck "after a turn: the state before it (ground, forecast, aim) is in the page for the replay; terrain events carry where they landed" "$(grep -c '"prev":{"ter":{' $H) $(grep -c '"env":"[a-z]*","x":' $H)" "1 1"
ck "terrain chips have no piece-type icon" "$(grep -o '<li class="pf-chip env[^>]*>.\{0,90\}' $H | grep -c 'pfh-ico\|❔')" "0"

echo "== the result card"
php -d display_errors=1 "$HERE/pbox_v1_seed.php" "$GAME" win | tail -1 | cut -c1-60
get adventure.php >/dev/null
ck "a win: the result card with the tool wear rows, a link to the box and the reward button" "$(grep -c 'id="pfv-res"' $H) $(grep -c 'badge-win\|badge-charm' $H) $([ $(grep -o 'class="toolrow' $H | wc -l) -ge 2 ] && echo wear) $(grep -c 'puzzlebox.php?t=belt' $H) $(grep -c 'value="pf_finish"' $H)" "1 1 wear 1 1"
ck "Collect the reward ends the fight" "$(pf pf_finish) $(db "SELECT encounter IS NULL FROM expeditions ORDER BY id DESC LIMIT 1")" "302 1"
php -d display_errors=1 "$HERE/pbox_v1_seed.php" "$GAME" fight medium >/dev/null; get adventure.php >/dev/null; post adventure.php -d do=pfv_go >/dev/null
ck "a run through the page: the result card (lost) is shown on the next page, once" "$(pf pfb_play -d moves='0,1,2' >/dev/null; pf pf_run) $(get adventure.php >/dev/null; grep -c 'id="pfv-res"' $H) $(grep -c 'You walked away' $H) $(get adventure.php >/dev/null; grep -c 'id="pfv-res"' $H)" "302 1 1 0"

echo "== the browser pass (390px, light and dark)"
if node -e "require('playwright')" 2>/dev/null || [ -d /opt/node-tools/node_modules/playwright ]; then
  OUT=${SHOT:-$(mktemp -d)}; mkdir -p "$OUT"
  NODE_PATH=${NODE_PATH:-/opt/node-tools/node_modules} node "$HERE/pbox_v1_shots.js" "$BASE" "$OUT" "$GAME" "$HERE" 2>&1 | tee $H.shots | cut -c1-300
  FAILS=$((FAILS + $(grep -c '^FAIL' $H.shots)))
  ck "the browser pass ran to the end" "$(grep -c '^shots: done' $H.shots)" "1"
  echo "screenshots: $OUT"
else echo "skip (no playwright)"; fi
ck "no errors in the game error log" "$(cat "$GAME/data/error-log.txt" 2>/dev/null | wc -c | tr -d ' ')" "0"
grep -E "PHP (Warning|Notice|Deprecated|Fatal)" $LOG | head -3 | cut -c1-260
ck "no PHP warnings in server log" "$(grep -cE 'PHP (Warning|Notice|Deprecated|Fatal)' $LOG)" "0"
[ -n "$KEEP" ] && cp $H.new $H.old /tmp/ 2>/dev/null; [ $FAILS -eq 0 ] && echo "pbox_v1 ok" || echo "$FAILS FAILED"
