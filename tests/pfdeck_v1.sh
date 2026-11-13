#!/bin/bash
# 2.6.74 stage B, the v1 DECK MODEL (setting pfight_v1): tests/pfdeck_v1.php without a database (data lint, creature layers and tags, deck building, belt, wear, harmony, flag-off parity),
# then on an installed copy: the tables, starter, toggle, belt, wear / break / fix, the fight hookup, and the Puzzle box page's POST actions and JSON helper.
# Usage: tests/pfdeck_v1.sh [GAME_COPY_DIR] [PORT] [ROUTER]   (default: copies src/game to a temp dir; never writes a DB into src)
HERE=$(cd "$(dirname "$0")" && pwd)
php -d display_errors=1 "$HERE/pfdeck_v1.php" || exit 1
GAME=${1:-}; PORT=${2:-8796}; ROUTER=${3:-$HERE/router.php}
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
FAILS=0; ck() { if [ "$2" = "$3" ]; then echo "ok   $1"; else echo "FAIL $1 (got '$2', want '$3')"; FAILS=$((FAILS+1)); fi; }
set_() { db "INSERT OR REPLACE INTO settings (name,value) VALUES ('$1','$2')" >/dev/null; }
echo "== the Puzzle box page: gating of the deck model"
set_ pfight_open 1
get 'puzzlebox.php?pfd=json' >/dev/null
ck "pfight_v1 unset: no deck JSON (the old Puzzle box page)" "$(grep -c '"pieces":\[' $H)" "0"
ck "pfight_v1 unset: a pfd_ action does nothing (no deck tables touched)" "$(post puzzlebox.php -d do=pfd_starter -d kit=bold) $(db "SELECT COUNT(*) FROM pf_decks") $(db "SELECT COUNT(*) FROM pf_deck_pieces")" "302 0 0"
ck "pfight_v1 off (2.6.74 release): no fight belt, no repair kit, no shelf, no recipe after the install" "$(db "SELECT (SELECT COUNT(*) FROM items WHERE slug IN ('stitched-fight-belt','masterwork-fight-belt','tool-repair-kit')) || ' ' || (SELECT COUNT(*) FROM recipes WHERE slug='tool-repair-kit')")" "0 0"
set_ pfight_v1 admin
get 'puzzlebox.php?pfd=json' >/dev/null
ck "pfight_v1 = admin, a player: still no deck JSON" "$(grep -c '"pieces":\[' $H)" "0"
get puzzlebox.php >/dev/null; post puzzlebox.php -d do=pfd_starter -d kit=bold >/dev/null
ck "pfight_v1 = admin, a player: a pfd_ action does nothing" "$(db "SELECT COUNT(*) FROM pf_decks")" "0"
db "UPDATE users SET role='admin' WHERE username='sprout'" >/dev/null
get 'puzzlebox.php?pfd=json' >/dev/null
ck "an admin: the deck as JSON (pieces, deck, counts, offer, belt, harmony, wear)" "$(php -r '$d=json_decode(file_get_contents($argv[1]),true); echo isset($d["pieces"],$d["deck"],$d["counts"],$d["offer"],$d["belt"],$d["harmony"],$d["wear"]) && count($d["deck"])>=10 && !$d["starter"] ? "yes" : "no";' $H)" "yes"
get puzzlebox.php >/dev/null
ck "POST do=pfd_starter kit=bold: redirect" "$(post puzzlebox.php -d do=pfd_starter -d kit=bold)" "302"
ck "the starter is saved (10 pieces, chosen)" "$(db "SELECT COUNT(*) FROM pf_deck_pieces WHERE starter=1") $(db "SELECT starter FROM pf_decks")" "10 1"
get puzzlebox.php >/dev/null; post puzzlebox.php -d do=pfd_toggle -d key=snack -d on=0 >/dev/null
ck "POST do=pfd_toggle key=snack on=0: switched off" "$(db "SELECT active FROM pf_deck_pieces WHERE piece_key='snack'")" "0"
get puzzlebox.php >/dev/null; post puzzlebox.php -d do=pfd_auto -d on=1 >/dev/null
ck "POST do=pfd_auto on=1: remembered" "$(db "SELECT auto_use FROM pf_decks")" "1"
get puzzlebox.php >/dev/null; post puzzlebox.php -d do=pfd_toggle -d key=snack -d on=1 -d csrf=wrong >/dev/null
ck "a POST without the right csrf token changes nothing" "$(db "SELECT active FROM pf_deck_pieces WHERE piece_key='snack'")" "0"
ck "stage C: the admin gets the v1 Puzzle box page (the old form is gone for them)" "$(get puzzlebox.php) $(grep -c 'id="pfv-box"' $H) $(grep -c 'id="pbox"' $H)" "200 1 0"
db "DELETE FROM pf_deck_pieces" >/dev/null; db "DELETE FROM pf_decks" >/dev/null; db "UPDATE users SET role='player' WHERE username='sprout'" >/dev/null
php -d display_errors=1 "$HERE/pfdeck_v1.php" "$GAME" 2>&1 | tee $H.db | grep -v "^ok" | cut -c1-900; cat "$GAME/data/error-log.txt" 2>/dev/null | head -5 | cut -c1-500
FAILS=$((FAILS + $(grep -c '^FAIL' $H.db)))
ck "the database checks ran to the end" "$(grep -c 'database checks: all ok' $H.db)" "1"
echo "== a fight on the page with the deck model"
set_ pfight_blank 1
php -d display_errors=1 "$HERE/advforce.php" "$GAME" fight 2>&1 | tail -1
MID=$(db "SELECT id FROM creatures WHERE slug='tunnel-mole'"); MHP=$(db "SELECT hp FROM creatures WHERE slug='tunnel-mole'")   # a level 9 creature for the level 9 gnome: a fight long enough for tool pieces to be played
db "UPDATE expeditions SET encounter='{\"type\":\"creature\",\"id\":$MID,\"lv\":0,\"sp\":100,\"hpp\":100,\"hp\":$MHP,\"max\":$MHP,\"bark\":0,\"poison\":0,\"used\":false}', hp=max_hp WHERE status='active'" >/dev/null
# stage C: with pfight_v1 on, a fight is dealt only after the starter is packed and "Let's fight" is pressed on the pre-fight screen
letsfight() { get adventure.php >/dev/null; if grep -q 'id="pfv-starter"' $H; then post adventure.php -d do=pfd_starter -d kit=steady >/dev/null; get adventure.php >/dev/null; fi; if grep -q 'id="pfv-pre"' $H; then post adventure.php -d do=pfv_go >/dev/null; fi; get adventure.php >/dev/null; }
letsfight
encq() { php -r '$p=new PDO("sqlite:'$GAME'/data/game.sqlite"); $e=json_decode($p->query("SELECT encounter FROM expeditions ORDER BY id DESC LIMIT 1")->fetchColumn(),true); $s=$e["pf"]??null; echo eval("return ".$argv[1].";");' "$1"; }
pf() { local d=$1; shift; get adventure.php >/dev/null
  local n=$(grep -o 'name="nonce" value="[0-9a-f]*"' $H | head -1 | grep -o '[0-9a-f]\{8\}') t=$(grep -o 'id="pfight" data-turn="[0-9]*"' $H | grep -o '[0-9]*')
  post adventure.php -d do=$d -d nonce=$n -d turn=$t "$@"; }
ck "the page fight is a v1 fight with a layered creature (base, unique layers) and deck-model pieces" "$(encq '(isset($s["v1"]) ? "v1" : "old") . " " . count(array_filter(array_merge($s["foe"]["hand"], $s["foe"]["draw"]), fn($t) => in_array($t["layer"] ?? "", ["base", "uni"], true))) . " " . (count(array_filter(array_merge($s["me"]["hand"], $s["me"]["draw"]), fn($t) => isset($t["rank"], $t["src"])) ) >= 10 ? "deck" : "no deck")')" "v1 7 deck"
ck "page data: status and wear" "$(grep -c "\"status\":{\"poison\":0" $H) $(grep -c "\"wear\":" $H)" "1 1"
W0=$(db "SELECT COALESCE(SUM(wear),0) FROM pf_tool_wear")
N=0; TOOLP=0; while [ $N -lt 70 ]; do
  [ "$(db "SELECT encounter IS NULL FROM expeditions ORDER BY id DESC LIMIT 1")" = "1" ] && break
  MV=$(php "$HERE/pfboard_move.php" "$GAME" 2>&1 | tail -1)
  if [ "$MV" = "PASS" ]; then CODE=$(pf pfb_pass); elif [ "$MV" = "NONE" ]; then break; elif [ "${MV%% *}" = "FLIP" ]; then CODE=$(pf pfb_flip -d hand="${MV##* }"); else CODE=$(pf pfb_play -d moves="$MV"); fi
  [ "$CODE" = "302" ] || { echo "FAIL play returned $CODE"; FAILS=$((FAILS+1)); break; }
  N=$((N+1)); WF=$(encq 'array_sum($s["wear"] ?? [])'); [ -n "$WF" ] && [ "$WF" != "0" ] && TOOLP=$WF
  if [ "$(db "SELECT encounter LIKE '%\"won\":%' OR encounter LIKE '%\"lost\":%' FROM expeditions ORDER BY id DESC LIMIT 1")" = "1" ]; then ck "End fight (won, or 2.6.78: lost and waiting for Continue): redirect" "$(pf pf_finish)" "302"; break; fi
done
ck "the fight ended" "$(db "SELECT encounter IS NULL FROM expeditions ORDER BY id DESC LIMIT 1")" "1"
ck "tool pieces were played in the fight (wear counted)" "$([ "$TOOLP" -ge 2 ] && echo yes || echo "no: $TOOLP")" "yes"
ck "the tool wear of the fight ($TOOLP) was saved once, at its end" "$(( $(db "SELECT COALESCE(SUM(wear),0) FROM pf_tool_wear") - W0 ))" "$TOOLP"
ck "no errors in the game error log" "$(cat "$GAME/data/error-log.txt" 2>/dev/null | wc -c | tr -d ' ')" "0"
grep -E "PHP (Warning|Notice|Deprecated|Fatal)" $LOG | head -3 | cut -c1-260
ck "no PHP warnings in server log" "$(grep -cE 'PHP (Warning|Notice|Deprecated|Fatal)' $LOG)" "0"
echo "actions played: $N"
[ $FAILS -eq 0 ] && echo "pfdeck_v1 ok" || echo "$FAILS FAILED"
