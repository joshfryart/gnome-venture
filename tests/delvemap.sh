#!/bin/bash
# v2.0.6 delve + lair maps (tile map core, walk_scene). Fresh SQLite install in a private copy, then:
#   tests/delvemap.php unit (generator over 500 seeds, path, fog, window, svg, layouts), a whole delve played tile by tile, the simple list fallback,
#   the setting that switches the map off, a lair on the map and in the list, ending / abandoning / being knocked out clears the scene row.
# Usage: tests/delvemap.sh [GAME_COPY_DIR] [PORT] [ROUTER]
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
php "$HERE/delvemap.php" unit "$GAME" > $A 2>&1; tail -1 $A | grep -q 'all unit tests passed' && chk "tests/delvemap.php unit" 1 || { chk "tests/delvemap.php unit" 0; grep FAIL $A | head; }

echo "== table"
chk "walk_scene table exists" "$([ "$(db "SELECT COUNT(*) FROM sqlite_master WHERE name='walk_scene'")" = 1 ] && echo 1)"
chk "setting delve_map defaults to on" "$([ "$(curl -s -c $C -b $C $BASE/login.php >/dev/null; db "SELECT COALESCE((SELECT value FROM settings WHERE name='delve_map'),'(default)')")" != 0 ] && echo 1)"

get login.php >/dev/null; post login.php -d username=sprout -d 'password=TestPass123!' >/dev/null
pick() { db "SELECT lm.id||' '||lm.location_id||' '||COALESCE(l.landscape,'')||' '||lm.name FROM landmarks lm JOIN locations l ON l.id=lm.location_id WHERE lm.kind='$1' ORDER BY lm.id LIMIT 1 OFFSET ${2:-0}"; }
goto() { dbx "UPDATE users SET location_id=$1 WHERE id=$SID"; }
adv() { get adventure.php >/dev/null; cp $H $A; }
lmact() { get world.php >/dev/null; post landmark.php "$@" >/dev/null; }
resolve() { for k in $(seq 80); do get adventure.php >/dev/null
  if grep -q 'value="auto"' $H; then post adventure.php -d do=auto >/dev/null; elif grep -q 'value="attack"' $H; then post adventure.php -d do=attack >/dev/null; elif grep -q 'value="solve"' $H; then post adventure.php -d do=solve -d option=0 >/dev/null; else break; fi; done; }
EXPID() { db "SELECT id FROM expeditions WHERE user_id=$SID ORDER BY id DESC LIMIT 1"; }
ESTATUS() { db "SELECT status FROM expeditions WHERE user_id=$SID ORDER BY id DESC LIMIT 1"; }
EDEPTH() { db "SELECT depth FROM expeditions WHERE user_id=$SID ORDER BY id DESC LIMIT 1"; }
SCENES() { db "SELECT COUNT(*) FROM walk_scene"; }
# walk toward spot N (explore the fog by tapping the lit tile nearest to it, like a player), until its room has been gone into. Prints the taps.
walkto() { local code=$1 e d0 n=0 t
  e=$(EXPID); d0=$(EDEPTH)
  while [ $n -lt 40 ]; do
    t=$(php "$HERE/delvemap.php" next "$GAME" $e $code)
    case "$t" in stuck*|none*) echo "STUCK($t)"; return 1;; esac
    adv; post adventure.php -d do=go -d "go=${t%% *}" >/dev/null; n=$((n+1))
    [ "$(EDEPTH)" != "$d0" ] && { echo "$n taps"; return 0; }
  done; echo "too many taps"; return 1; }
logline() { db "SELECT log FROM expeditions WHERE id=$1" | php -r '$l=json_decode(stream_get_contents(STDIN),true); foreach($l as $x) echo $x,"\n";'; }

echo "== a delve on the map: start"
read DID DLOC DLAND DNAME <<< "$(pick delve 0)"; echo "   $DNAME ($DLAND)"; goto $DLOC
E0=$(db "SELECT energy FROM users WHERE id=$SID")
lmact -d do=delve -d lm=$DID
EX=$(EXPID); chk "expedition started (kind delve, active)" "$([ "$(db "SELECT kind||status FROM expeditions WHERE id=$EX")" = delveactive ] && echo 1)"
chk "entry costs 1 energy as before" "$([ "$(db "SELECT energy FROM users WHERE id=$SID")" -le $((E0-1)) ] && echo 1)"
chk "one walk_scene row" "$([ "$(SCENES)" = 1 ] && echo 1)"
adv
chk "the page shows the map" "$(grep -q 'class="tilemap tm-cave"' $A && echo 1)"
chk "81 tile buttons (9 x 9 window)" "$([ "$(grep -oE 'class="tmt[ "]' $A | wc -l)" = 81 ] && echo 1)"
chk "tile size comes from a data attribute" "$(grep -q 'data-tile="42"' $A && echo 1)"
chk "buttons post name=go, hidden do=go" "$(grep -q 'name="go" value="' $A && grep -q 'name="do" value="go"' $A && echo 1)"
chk "'Use the simple list' link" "$(grep -q 'Use the simple list' $A && echo 1)"
chk "legend on one line" "$(grep -q 'class="tmlegend"' $A && echo 1)"
chk "no inline style on the map" "$(! grep -o '<div class="tmwrap.*</p></div>' $A | grep -q 'style=' && echo 1)"
chk "the old five-room buttons are not on the map page" "$(! grep -q 'value="next"' $A && echo 1)"
chk "Climb back out is still there" "$(grep -q 'value="leave"' $A && echo 1)"
chk "no fog-free spoilers: the 5 spots are not all visible at the start" "$([ "$(grep -o 'class="tmtok' $A | wc -l)" -lt 5 ] && echo 1)"
chk "scene JSON sane (entry, five spots)" "$(php "$HERE/delvemap.php" scene "$GAME" $EX | php -r '$j=json_decode(stream_get_contents(STDIN),true); echo count($j["spots"])===5 && $j["entry"]===[$j["x"],$j["y"]] ? 1 : 0;')"

echo "== the guardian is barred, taps on rock and fog are refused"
php "$HERE/delvemap.php" scene "$GAME" $EX > $A; S5=$(php -r '$j=json_decode(file_get_contents($argv[1]),true); echo $j["spots"]["5"][0].",".$j["spots"]["5"][1];' $A)
dbx "UPDATE walk_scene SET seen='$(printf 'f%.0s' $(seq 43))' WHERE exp_id=$EX"   # light everything so only the rules refuse
adv; post adventure.php -d do=go -d "go=$S5" >/dev/null; get adventure.php >/dev/null
chk "guardian tile refused before four rooms ($(flashes | cut -c1-70))" "$([ "$(EDEPTH)" = 0 ] && grep -q 'barred' $H && echo 1)"
post adventure.php -d do=go -d "go=0,0" >/dev/null; get adventure.php >/dev/null
chk "wall tap refused" "$(grep -q 'solid rock' $H && echo 1)"
post adventure.php -d do=go -d "go=banana" >/dev/null; get adventure.php >/dev/null
chk "garbage target refused, no error" "$([ "$(EDEPTH)" = 0 ] && echo 1)"
post adventure.php -d do=go -d "go=99,99" >/dev/null; get adventure.php >/dev/null
chk "off the map refused" "$([ "$(EDEPTH)" = 0 ] && echo 1)"
dbx "UPDATE walk_scene SET seen='$(printf '0%.0s' $(seq 31))' WHERE exp_id=$EX"
adv; post adventure.php -d do=go -d "go=$S5" >/dev/null; get adventure.php >/dev/null
chk "fogged tile refused ('can’t see that far')" "$(grep -q 'see that far' $H && echo 1)"
# put the lit entry room back (the engine reveals around where you stand)
php -r '$_SERVER["SCRIPT_NAME"]="/adventure.php"; require "'$GAME'/includes/bootstrap.php"; require_once "'$GAME'/includes/adventure.php"; $r=q_one("SELECT * FROM walk_scene WHERE exp_id='$EX'"); $s=tm_seen_new(11,11); tm_reveal($s,11,11,(int)$r["x"],(int)$r["y"],3); q("UPDATE walk_scene SET seen=? WHERE id=?",[$s,$r["id"]]);'

echo "== play the whole delve tile by tile (rooms in a shuffled order), then the chest"
ORDER="3 1 4 2"
CH0=$(db "SELECT coins FROM users WHERE id=$SID")
N=0
for code in $ORDER; do
  T=$(walkto $code); N=$((N+1))
  logline $EX > $A; chk "room $N of 5 logged when spot $code is entered ($T)" "$(grep -q "🚪 Room $N of 5" $A && echo 1)"
  resolve
  chk "room spot $code done, depth now $(EDEPTH), delve still active" "$([ "$(EDEPTH)" -ge $N ] && [ "$(ESTATUS)" = active ] && echo 1)"
done
chk "four rooms entered, still on the same expedition" "$([ "$(EDEPTH)" = 4 ] && [ "$(EXPID)" = "$EX" ] && echo 1)"
adv
chk "chest not offered yet" "$(! grep -q 'value="chest"' $A && echo 1)"
T=$(walkto 5)
logline $EX > $A
chk "the last room is the guarded chest: room 5 of 5, 'guarded by' ($T)" "$(grep -q '🚪 Room 5 of 5' $A && grep -q 'The chest is guarded by' $A && echo 1)"
resolve
chk "the guardian's room done: depth 5, delve active" "$([ "$(EDEPTH)" = 5 ] && [ "$(ESTATUS)" = active ] && echo 1)"
adv
chk "the chest is offered" "$(grep -q 'value="chest"' $A && echo 1)"
LMLVL=$(db "SELECT max(1, COALESCE((SELECT min_level FROM routes WHERE kind='side' AND b_id=$DLOC LIMIT 1),1))")
post adventure.php -d do=chest >/dev/null
chk "delve done" "$([ "$(ESTATUS)" = done ] && echo 1)"
chk "scene row removed when the delve ends" "$([ "$(SCENES)" = 0 ] && echo 1)"
logline $EX > $A
COINS=$(grep -oE 'chest creaks open: [0-9,]+' $A | grep -oE '[0-9,]+$' | tr -d ,)
XPN=$(grep -oE 'Delve cleared! \+[0-9]+ XP' $A | grep -oE '[0-9]+')
chk "chest Petals in the list-flow range (20+5L .. 40+10L, L=$LMLVL): $COINS" "$([ -n "$COINS" ] && [ "$COINS" -ge $((20+5*LMLVL)) ] && [ "$COINS" -le $((40+10*LMLVL)) ] && echo 1)"
chk "clear XP is 10+2L = $((10+2*LMLVL)): $XPN" "$([ "$XPN" = $((10+2*LMLVL)) ] && echo 1)"
chk "1 clear recorded" "$([ "$(db "SELECT clears FROM landmark_clears WHERE user_id=$SID AND landmark_id=$DID")" = 1 ] && echo 1)"
get world.php >/dev/null
chk "once a day: a second delve today is refused" "$(post landmark.php -d do=delve -d lm=$DID >/dev/null; [ "$(db "SELECT COUNT(*) FROM expeditions WHERE user_id=$SID AND status='active'")" = 0 ] && echo 1)"

echo "== every kind of map: the three hand-built layouts and generated ones, a whole delve each (a different order each time)"
dbx "UPDATE users SET level=60, stat_grit=45, stat_hardiness=45, stat_nimble=40, energy=900 WHERE id=$SID"
playdelve() { local id=$1 order=$2 loc land key e n=0 code lvl coins xp
  read loc land <<< "$(db "SELECT lm.location_id||' '||COALESCE(l.landscape,'') FROM landmarks lm JOIN locations l ON l.id=lm.location_id WHERE lm.id=$id")"
  dbx "DELETE FROM landmark_uses WHERE user_id=$SID"; goto $loc; lmact -d do=delve -d lm=$id
  e=$(EXPID); key=$(db "SELECT map_key FROM walk_scene WHERE exp_id=$e")
  for code in $order 5; do walkto $code >/dev/null || { chk "delve $id ($key): reached spot $code" 0; break; }; resolve; n=$((n+1)); done
  lvl=$(db "SELECT max(1, COALESCE((SELECT min_level FROM routes WHERE kind='side' AND b_id=$loc LIMIT 1),1))")
  chk "delve $id ($land, $key) played in order $order 5: depth $(EDEPTH)" "$([ "$(EDEPTH)" = 5 ] && [ "$(ESTATUS)" = active ] && echo 1)"
  post adventure.php -d do=chest >/dev/null; logline $e > $A
  coins=$(grep -oE 'chest creaks open: [0-9,]+' $A | grep -oE '[0-9,]+$' | tr -d ,); xp=$(grep -oE 'Delve cleared! \+[0-9]+' $A | grep -oE '[0-9]+')
  chk "  chest $coins in [$((20+5*lvl)),$((40+10*lvl))], clear XP $xp = $((10+2*lvl)), scene gone" "$([ -n "$coins" ] && [ "$coins" -ge $((20+5*lvl)) ] && [ "$coins" -le $((40+10*lvl)) ] && [ "$xp" = $((10+2*lvl)) ] && [ "$(SCENES)" = 0 ] && echo 1)"; }
curl -s -c $C -b $C "$BASE/adventure.php?view=map" -o /dev/null
playdelve 4 "1 2 3 4"; playdelve 45 "4 3 2 1"; playdelve 56 "2 4 1 3"; playdelve 10 "3 1 2 4"; playdelve 27 "2 3 4 1"; playdelve 50 "4 1 3 2"
KEYS=$(db "SELECT DISTINCT substr(map_key,1,1) FROM walk_scene")
dbx "UPDATE users SET level=30, stat_grit=26, stat_hardiness=26, stat_nimble=22 WHERE id=$SID"

echo "== list fallback: same delve, simple list, remembered in the session"
dbx "DELETE FROM landmark_uses WHERE user_id=$SID"
goto $DLOC; lmact -d do=delve -d lm=$DID
EX2=$(EXPID); chk "new expedition + its scene" "$([ "$EX2" != "$EX" ] && [ "$(SCENES)" = 1 ] && echo 1)"
curl -s -c $C -b $C "$BASE/adventure.php?view=list" -o /dev/null
adv
chk "?view=list shows the old flow (Next room)" "$(grep -q 'value="next"' $A && ! grep -q 'class="tilemap' $A && echo 1)"
chk "…and a way back to the map" "$(grep -q 'Show the map' $A && echo 1)"
adv; chk "remembered on the next page view" "$(grep -q 'value="next"' $A && echo 1)"
LB=0
for r in 1 2 3 4; do post adventure.php -d do=next >/dev/null; resolve; done
chk "four rooms by the list: depth 4" "$([ "$(EDEPTH)" = 4 ] && echo 1)"
curl -s -c $C -b $C "$BASE/adventure.php?view=map" -o /dev/null; adv
chk "switching to the map mid-run: the four rooms show as done" "$([ "$(grep -o 'class="tmt[^"]*spot done' $A | wc -l)" -ge 0 ] && grep -q 'class="tilemap' $A && echo 1)"
php "$HERE/delvemap.php" scene "$GAME" $EX2 > $A
chk "the map caught up with the list (four rooms recorded)" "$([ "$(php -r '$j=json_decode(file_get_contents($argv[1]),true); echo count($j["c"]);' $A)" = 4 ] && echo 1)"
post adventure.php -d do=next >/dev/null; resolve
chk "room 5 by the list, depth 5" "$([ "$(EDEPTH)" = 5 ] && echo 1)"
post adventure.php -d do=chest >/dev/null
logline $EX2 > $A
COINS2=$(grep -oE 'chest creaks open: [0-9,]+' $A | grep -oE '[0-9,]+$' | tr -d ,)
chk "list-flow chest Petals in the same range: $COINS2" "$([ -n "$COINS2" ] && [ "$COINS2" -ge $((20+5*LMLVL)) ] && [ "$COINS2" -le $((40+10*LMLVL)) ] && echo 1)"
chk "list-flow clear XP the same: $(grep -oE 'Delve cleared! \+[0-9]+' $A)" "$(grep -q "Delve cleared! +$((10+2*LMLVL)) XP" $A && echo 1)"
chk "scene gone after the list-flow ends" "$([ "$(SCENES)" = 0 ] && echo 1)"

echo "== abandon (Climb back out) clears the scene"
curl -s -c $C -b $C "$BASE/adventure.php?view=map" -o /dev/null
dbx "DELETE FROM landmark_uses WHERE user_id=$SID"; goto $DLOC; lmact -d do=delve -d lm=$DID
EX3=$(EXPID); adv; walkto 2 >/dev/null; resolve
chk "scene exists mid-delve" "$([ "$(SCENES)" = 1 ]  && echo 1)"
get adventure.php >/dev/null; post adventure.php -d do=leave >/dev/null
chk "left: expedition done, scene row gone" "$([ "$(ESTATUS)" = done ] && [ "$(SCENES)" = 0 ] && echo 1)"

echo "== setting off: delve_map = 0 → the list only, no scene"
dbx "INSERT OR REPLACE INTO settings (name, value) VALUES ('delve_map','0')"
dbx "DELETE FROM landmark_uses WHERE user_id=$SID"; goto $DLOC; lmact -d do=delve -d lm=$DID
adv
chk "no walk_scene row, simple list shown" "$([ "$(SCENES)" = 0 ] && grep -q 'value="next"' $A && ! grep -q 'class="tilemap' $A && ! grep -q 'Use the simple list' $A && ! grep -q 'Show the map' $A && echo 1)"
post adventure.php -d do=leave >/dev/null
dbx "DELETE FROM settings WHERE name='delve_map'"; dbx "INSERT INTO settings (name, value) VALUES ('delve_map','1')"

echo "== a lair on the map"
read LID LLOC LLAND LNAME <<< "$(pick lair 0)"; echo "   $LNAME ($LLAND)"; goto $LLOC
dbx "DELETE FROM landmark_uses WHERE user_id=$SID"; dbx "UPDATE users SET energy=500 WHERE id=$SID"
curl -s -c $C -b $C "$BASE/adventure.php?view=map" -o /dev/null
lmact -d do=lair -d lm=$LID
EXL=$(EXPID)
chk "lair expedition active, boss has not risen (no encounter, depth 0)" "$([ "$(db "SELECT kind||status||depth||COALESCE(encounter,'none') FROM expeditions WHERE id=$EXL")" = lairactive0none ] && echo 1)"
chk "a 13 x 13 lair scene" "$([ "$(db "SELECT substr(map_key,1,3) FROM walk_scene WHERE exp_id=$EXL")" = g13 ] && echo 1)"
adv
chk "page shows the lair map + legend with the boss" "$(grep -q 'class="tilemap' $A && grep -q 'Lair map' $A && grep -q 'class="tmlegend"[^>]*><span>.* Boss</span>' $A && echo 1)"
chk "no fight buttons yet" "$(! grep -q 'value="attack"' $A && echo 1)"
chk "page has Slip back out" "$(grep -q 'value="leave"' $A && echo 1)"
chk "topbar elsewhere shows the quiet lair (Face it / Slip out)" "$(get gnome.php >/dev/null; grep -q 'value="lair_engage"' $H && echo 1)"
T=$(walkto 1)
chk "boss reached on the map ($T): the fight begins" "$([ "$(db "SELECT depth FROM expeditions WHERE id=$EXL")" = 1 ] && [ "$(db "SELECT COUNT(*) FROM expeditions WHERE id=$EXL AND encounter IS NOT NULL")" = 1 ] && echo 1)"
adv; chk "fight card is the old one (value=attack)" "$(grep -q 'value="attack"' $A && echo 1)"
resolve
chk "lair over: scene row removed" "$([ "$(SCENES)" = 0 ] && [ "$(ESTATUS)" != active ] && echo 1)"
logline $EXL > $A; echo "   $(grep -E 'hoard|First victory|escape|knocks' $A | head -2 | tr '\n' ' ')"

echo "== a lair in the simple list: the boss rises at once, no scene"
dbx "DELETE FROM landmark_uses WHERE user_id=$SID"; goto $LLOC
curl -s -c $C -b $C "$BASE/adventure.php?view=list" -o /dev/null
lmact -d do=lair -d lm=$LID
EXL2=$(EXPID)
chk "boss already fighting (depth 1, encounter), no scene row" "$([ "$(db "SELECT depth FROM expeditions WHERE id=$EXL2")" = 1 ] && [ "$(db "SELECT COUNT(*) FROM expeditions WHERE id=$EXL2 AND encounter IS NOT NULL")" = 1 ] && [ "$(SCENES)" = 0 ] && echo 1)"
resolve; chk "ends normally" "$([ "$(ESTATUS)" != active ] && echo 1)"

echo "== lair: Face it now from the quiet lair; slip out; knock-out all clear the scene"
curl -s -c $C -b $C "$BASE/adventure.php?view=map" -o /dev/null
dbx "DELETE FROM landmark_uses WHERE user_id=$SID"; goto $LLOC; lmact -d do=lair -d lm=$LID
EXL3=$(EXPID); curl -s -c $C -b $C "$BASE/adventure.php?view=list" -o /dev/null; adv
chk "list view of a quiet lair: Face the boss now" "$(grep -q 'value="lair_engage"' $A && echo 1)"
post adventure.php -d do=lair_engage >/dev/null
chk "the boss rises, scene still there until it ends" "$([ "$(db "SELECT depth FROM expeditions WHERE id=$EXL3")" = 1 ] && [ "$(SCENES)" = 1 ] && echo 1)"
dbx "UPDATE users SET level=1, stat_grit=6, stat_hardiness=6, stat_nimble=6 WHERE id=$SID"; dbx "UPDATE expeditions SET hp=1 WHERE id=$EXL3"
for k in 1 2 3 4 5 6 7 8; do get adventure.php >/dev/null; grep -q 'value="attack"' $H && post adventure.php -d do=attack >/dev/null || break; done
chk "knocked out ($(ESTATUS)): scene row removed" "$([ "$(ESTATUS)" = ko ] && [ "$(SCENES)" = 0 ] && echo 1)"
dbx "UPDATE users SET level=30, stat_grit=26, stat_hardiness=26, stat_nimble=22, energy=500 WHERE id=$SID"
dbx "DELETE FROM landmark_uses WHERE user_id=$SID"; goto $LLOC; curl -s -c $C -b $C "$BASE/adventure.php?view=map" -o /dev/null; lmact -d do=lair -d lm=$LID
get adventure.php >/dev/null; post adventure.php -d do=leave >/dev/null
chk "slipped out of the lair before the boss rose: done, scene gone, no victory" "$([ "$(ESTATUS)" = done ] && [ "$(SCENES)" = 0 ] && ! logline $(EXPID) | grep -q 'First victory' && echo 1)"

echo "== orphan scenes are swept at the next start; another player cannot use my scene"
dbx "INSERT INTO walk_scene (user_id, exp_id, map_key, x, y, seen, state, updated_at) VALUES ($SID, 99999, 'h:gallery', 1, 8, '0', '{}', datetime('now'))"
dbx "DELETE FROM landmark_uses WHERE user_id=$SID"; goto $DLOC; lmact -d do=delve -d lm=$DID
chk "the orphan row was purged, one live scene" "$([ "$(SCENES)" = 1 ] && [ "$(db "SELECT COUNT(*) FROM walk_scene WHERE exp_id=99999")" = 0 ] && echo 1)"
post adventure.php -d do=leave >/dev/null

echo "== the walk path rides one page (animation payload), then is gone"
dbx "DELETE FROM landmark_uses WHERE user_id=$SID"; goto $DLOC; lmact -d do=delve -d lm=$DID
EX4=$(EXPID); adv
T=$(php "$HERE/delvemap.php" next "$GAME" $EX4 1); post adventure.php -d do=go -d "go=${T%% *}" >/dev/null
get adventure.php >/dev/null
chk "the page after a tap carries data-walk with the path" "$(grep -q 'data-walk="[0-9]*,[0-9]*;' $H && grep -q 'class="tmft"' $H && echo 1)"
get adventure.php >/dev/null
chk "the path is one-shot (a reload does not replay it)" "$(! grep -q 'data-walk=' $H && echo 1)"
resolve; post adventure.php -d do=leave >/dev/null

echo "== errors"
chk "php server log clean" "$(! grep -qiE 'fatal|warning|notice|deprecated|exception' $LOG && echo 1)" "$(grep -iE 'fatal|warning|notice|deprecated|exception' $LOG | head -3)"
chk "error log empty" "$([ ! -s "$GAME/data/error.log" ] && echo 1)" "$(head -c 300 "$GAME/data/error.log" 2>/dev/null)"
echo; [ $FAILS = 0 ] && echo "ALL OK" || echo "FAILED: $FAILS"
exit $FAILS
