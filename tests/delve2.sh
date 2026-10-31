#!/bin/bash
# v2.3.1 delve redo (setting delve_v2): route menu, tile floors, torch. Fresh SQLite install in a private copy, then play a whole delve.
# Usage: tests/delve2.sh [GAME_COPY_DIR] [PORT] [ROUTER]
HERE=$(cd "$(dirname "$0")" && pwd)
GAME=${1:-}; PORT=${2:-8795}; ROUTER=${3:-$HERE/router.php}
if [ -z "$GAME" ]; then T=$(mktemp -d); cp -r "$HERE/../game" "$T/game"; GAME=$T/game; fi
rm -f "$GAME/config.php"; rm -rf "$GAME/data"; mkdir -p "$GAME/data"
BASE=http://127.0.0.1:$PORT
LOG=$(mktemp)
php -d session.save_path=/tmp -d display_errors=1 -S 127.0.0.1:$PORT -t "$GAME" "$ROUTER" >$LOG 2>&1 & PID=$!; sleep 1
trap "kill $PID 2>/dev/null" EXIT
C=$(mktemp); H=$(mktemp); A=$(mktemp)
FAILS=0
chk() { if [ "$2" = 1 ]; then echo "  ok   $1"; else echo "  FAIL $1 $3"; FAILS=$((FAILS+1)); fi; }
csrf() { grep -o 'name="csrf" value="[^"]*"' "$1" | head -1 | sed 's/.*value="\([^"]*\)".*/\1/'; }
get() { curl -s -c $C -b $C "$BASE/$1" -o $H -w '%{http_code}'; }
post() { local page=$1; shift; curl -s -c $C -b $C -X POST "$BASE/$page" --data-urlencode "csrf=$(csrf $H)" "$@" -o $H -w '%{http_code}'; }
db() { php -r '$p=new PDO("sqlite:'$GAME'/data/game.sqlite"); foreach($p->query($argv[1])->fetchAll(PDO::FETCH_NUM) as $r) echo implode(" | ",$r),"\n";' "$1"; }
dbx() { php -r '$p=new PDO("sqlite:'$GAME'/data/game.sqlite"); $p->exec($argv[1]);' "$1"; }
flashes() { grep -oE 'class="flash (ok|err)">[^<]*' $H | sed 's/class="flash [a-z]*">//' | tr '\n' ' '; }

echo "== install + register + welcome"
get install.php >/dev/null
post install.php -d driver=sqlite -d "site_name=Gnome Venture" -d base_url= -d admin_user=admin -d admin_email=a@b.local -d admin_pass=TestPassword123 -d admin_pass2=TestPassword123 >/dev/null
grep -q 'All planted' $H && echo installed || { echo "INSTALL FAILED"; tail -5 $LOG; exit 1; }
rm -f $C
get register.php >/dev/null; post register.php -d username=sprout -d email=s@b.local -d password=TestPass123! -d password2=TestPass123! -d rules=1 -d age=1 >/dev/null
get welcome.php >/dev/null; post welcome.php -d do=gnome -d "gnome_name=Bramble" -d 'hat=#2e7d4f' -d 'beard=#b5651d' >/dev/null
get 'welcome.php?step=place' >/dev/null
RID=$(db "SELECT id FROM regions WHERE code='NA'")
VID=$(db "SELECT l.id FROM locations l WHERE l.region_id=$RID AND l.kind='village' AND EXISTS (SELECT 1 FROM routes r WHERE r.kind='road' AND (r.a_id=l.id OR r.b_id=l.id)) ORDER BY l.sort_order LIMIT 1 OFFSET 1")
post welcome.php -d do=place -d village_id=$VID >/dev/null
get 'welcome.php?step=garden' >/dev/null; post welcome.php -d do=finish -d 'garden_name=Test Patch' >/dev/null
SID=$(db "SELECT id FROM users WHERE username='sprout'")
echo "onboarded: $(db "SELECT onboarded FROM users WHERE username='sprout'")"
dbx "UPDATE settings SET value='100000' WHERE name='event_chance'"; dbx "INSERT OR IGNORE INTO settings (name, value) VALUES ('event_chance','100000')"
dbx "UPDATE users SET tour_step=0, level=30, stat_grit=26, stat_hardiness=26, stat_nimble=22, energy=500, coins=5000 WHERE id=$SID"
dbx "UPDATE expeditions SET status='done' WHERE user_id=$SID"

echo "== unit tests (no database)"
php "$HERE/delve2.php" unit "$GAME" > $A 2>&1; tail -1 $A | grep -q 'all unit tests passed' && chk "tests/delve2.php unit" 1 || { chk "tests/delve2.php unit" 0; grep FAIL $A | head; }

get login.php >/dev/null; post login.php -d username=sprout -d 'password=TestPass123!' >/dev/null
pick() { db "SELECT lm.id||' '||lm.location_id||' '||COALESCE(l.landscape,'')||' '||lm.name FROM landmarks lm JOIN locations l ON l.id=lm.location_id WHERE lm.kind='$1' ORDER BY lm.id LIMIT 1 OFFSET ${2:-0}"; }
goto() { dbx "UPDATE users SET location_id=$1 WHERE id=$SID"; }
adv() { get adventure.php >/dev/null; cp $H $A; }
lmact() { get world.php >/dev/null; post landmark.php "$@" >/dev/null; }
EXPID() { db "SELECT id FROM expeditions WHERE user_id=$SID ORDER BY id DESC LIMIT 1"; }
ESTATUS() { db "SELECT status FROM expeditions WHERE user_id=$SID ORDER BY id DESC LIMIT 1"; }
EDEPTH() { db "SELECT depth FROM expeditions WHERE user_id=$SID ORDER BY id DESC LIMIT 1"; }
SCENES() { db "SELECT COUNT(*) FROM walk_scene"; }
logline() { db "SELECT log FROM expeditions WHERE id=$1" | php -r '$l=json_decode(stream_get_contents(STDIN),true); foreach($l as $x) echo $x,"\n";'; }
resolve() { for k in $(seq 80); do get adventure.php >/dev/null
  if grep -q 'value="auto"' $H; then post adventure.php -d do=auto >/dev/null; elif grep -q 'value="attack"' $H; then post adventure.php -d do=attack >/dev/null; elif grep -q 'value="solve"' $H; then post adventure.php -d do=solve -d option=0 >/dev/null; else break; fi; done; }
tap() { php "$HERE/delve2.php" tap "$GAME" $(EXPID); }
dstate() { php "$HERE/delve2.php" state "$GAME" $(EXPID); }
jq1() { php -r '$j=json_decode(stream_get_contents(STDIN),true); echo '"$1"';'; }

echo "== flag off: the old delve is untouched"
read DID DLOC DLAND DNAME <<< "$(pick delve 0)"; echo "   $DNAME ($DLAND)"; goto $DLOC
lmact -d do=delve -d lm=$DID
EX=$(EXPID)
chk "old rules: steps_total 5, scene is not v2" "$([ "$(db "SELECT steps_total FROM expeditions WHERE id=$EX")" = 5 ] && [ "$(db "SELECT map_key FROM walk_scene WHERE exp_id=$EX")" != v2 ] && echo 1)"
adv; chk "old page: tile map with five rooms, no route menu" "$(grep -q 'class="tilemap tm-cave"' $A && ! grep -q 'dv2route' $A && echo 1)"
post adventure.php -d do=leave >/dev/null
dbx "DELETE FROM landmark_uses WHERE user_id=$SID"

echo "== flag on: a v2 delve starts at the route menu"
dbx "INSERT OR REPLACE INTO settings (name, value) VALUES ('delve_v2','1')"
lmact -d do=delve -d lm=$DID
EX=$(EXPID); chk "delve started" "$([ "$(ESTATUS)" = active ] && echo 1)"
STG=$(db "SELECT steps_total FROM expeditions WHERE id=$EX")
chk "steps_total = the stages (3 or 4), not 5 ($STG)" "$({ [ "$STG" = 3 ] || [ "$STG" = 4 ]; } && echo 1)"
chk "scene row has map_key v2" "$([ "$(db "SELECT map_key FROM walk_scene WHERE exp_id=$EX")" = v2 ] && echo 1)"
adv
chk "the route menu is shown" "$(grep -q 'class="dv2route"' $A && grep -q 'name="do" value="route"' $A && echo 1)"
chk "no tile map yet, no old room buttons" "$(! grep -q 'class="tilemap' $A && ! grep -q 'value="next"' $A && echo 1)"
chk "pick buttons only for the first row (3)" "$([ "$(grep -o 'name="pick"' $A | wc -l)" = 3 ] && echo 1)"
chk "the guardian row is shown" "$(grep -q 'The guardian' $A && echo 1)"
chk "Climb back out is there" "$(grep -q 'value="leave"' $A && echo 1)"
chk "status line says Stage 1" "$(grep -q 'Stage <b>1</b>/' $A && echo 1)"

echo "== bad picks are refused"
post adventure.php -d do=route -d pick=3.0 >/dev/null; get adventure.php >/dev/null
chk "a node not in the first row is refused" "$(grep -q 'can’t go that way' $H && echo 1)"
get adventure.php >/dev/null; post adventure.php -d do=route -d pick=banana >/dev/null
get adventure.php >/dev/null
chk "garbage pick: still on the menu" "$([ "$(dstate | jq1 '$j["st"]["f"]===null ? 1 : 0')" = 1 ] && echo 1)"
post adventure.php -d do=go -d go=1,1 >/dev/null; get adventure.php >/dev/null
chk "a tap with no floor is refused" "$(grep -q 'Pick a way on first' $H && echo 1)"

echo "== play every stage: pick, light the floor, take everything, take the way down"
for iter in $(seq 400); do
  [ "$(ESTATUS)" != active ] && break
  get adventure.php >/dev/null; cp $H $A
  if grep -q 'value="auto"' $A || grep -q 'value="attack"' $A || grep -q 'value="solve"' $A; then resolve; continue; fi
  if grep -q 'value="chest"' $A; then post adventure.php -d do=chest >/dev/null; break; fi
  T=$(tap)
  case "$T" in
    menu*) ids=${T#menu }; post adventure.php -d do=route -d "pick=${ids%%,*}" >/dev/null ;;
    quick) post adventure.php -d do=quick >/dev/null ;;
    stuck) echo "STUCK on a floor"; break ;;
    *) php "$HERE/delve2.php" light "$GAME" $(EXPID); post adventure.php -d do=go -d "go=${T%% *}" >/dev/null ;;
  esac
done
chk "the delve ended (status done)" "$([ "$(ESTATUS)" = done ] && echo 1)"
chk "all $STG stages cleared (depth = steps_total)" "$([ "$(EDEPTH)" = "$STG" ] && echo 1)"
logline $EX > $A
chk "the chest opened and the delve was cleared" "$(grep -q 'Delve cleared' $A && echo 1)"
chk "a clear is recorded once" "$([ "$(db "SELECT clears FROM landmark_clears WHERE user_id=$SID AND landmark_id=$DID")" = 1 ] && echo 1)"
chk "scene row removed when the delve ends" "$([ "$(SCENES)" = 0 ] && echo 1)"
chk "log shows the way down" "$(grep -q 'way down' $A && echo 1)"

echo "== the torch burns per step; climbing out keeps loot"
dbx "DELETE FROM landmark_uses WHERE user_id=$SID"
lmact -d do=delve -d lm=$DID
EX=$(EXPID)
T=$(tap); ids=${T#menu }; adv; post adventure.php -d do=route -d "pick=${ids%%,*}" >/dev/null
adv; chk "a floor: tile map + torch + party strip" "$(grep -q 'class="tilemap tm-cave"' $A && grep -q 'dv2torch' $A && grep -q 'dv2party' $A && echo 1)"
S0=$(dstate | jq1 '$j["st"]["f"]["t"]')
php "$HERE/delve2.php" light "$GAME" $EX
T=$(tap); adv; post adventure.php -d do=go -d "go=${T%% *}" >/dev/null
S1=$(dstate | jq1 '$j["st"]["f"]["t"] ?? "gone"')
chk "torch dropped after a walk ($S0 -> $S1)" "$({ [ "$S1" = gone ] || [ "$S1" -lt "$S0" ]; } && echo 1)"
adv; post adventure.php -d do=leave >/dev/null
chk "climbing out ends the delve and drops the scene" "$([ "$(ESTATUS)" = done ] && [ "$(SCENES)" = 0 ] && echo 1)"

echo
if [ $FAILS -eq 0 ]; then echo "all delve v2 checks passed"; else echo "$FAILS FAILED"; exit 1; fi
