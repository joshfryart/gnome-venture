#!/usr/bin/env bash
# v2.0.88 Puzzle Pals build step 1 (includes/puzzle_pals.php): lint tool, data/generator/art gate/schema (tests/puzzle_pals.php), and the release hooks:
# an Advanced (96) done solve releases the picture's pals once, Easy releases nothing, Expert (216) earns a trophy once, flag off / rejected / guest / art-not-ready = nothing,
# free play AND tournament both hook in. Step 2: no page finds (map mode only; the map itself is tests/puzzle_pals_map.php). Step 3: the Pal Book (counts, silhouettes, locked list, trophies, art fallback, hub card, profile shelf). Takes a walk.sh-installed copy: puzzle_pals.sh GAME PORT ROUTER.
GAME=$1; PORT=$2; ROUTER=$3; BASE=http://127.0.0.1:$PORT
HERE=$(cd "$(dirname "$0")" && pwd)
php -d session.save_path=/tmp -S 127.0.0.1:$PORT -t $GAME $ROUTER >${TMPDIR:-/tmp}/ppal-php.log 2>&1 & PID=$!; sleep 1
W=$(mktemp -d); trap "kill $PID 2>/dev/null; rm -rf $W" EXIT
csrf() { grep -o 'name="csrf" value="[^"]*"' "$1" | head -1 | sed 's/.*value="\([^"]*\)".*/\1/'; }
dbv() { php -r '$p=new PDO("sqlite:'$GAME'/data/game.sqlite"); echo $p->query($argv[1])->fetchColumn();' "$1"; }
dbx() { php -r '$p=new PDO("sqlite:'$GAME'/data/game.sqlite"); $p->exec($argv[1]);' "$1"; }
login() { rm -f $1; curl -s -c $1 -b $1 $BASE/login.php > $W/l.html; curl -s -c $1 -b $1 -X POST $BASE/login.php --data-urlencode "csrf=$(csrf $W/l.html)" -d username=$2 --data-urlencode "password=$3" -o /dev/null; }
ok() { if [ "$2" = "$3" ]; then echo "ok   $1"; else echo "FAIL $1 (got '$2', want '$3')"; fi; }
js() { php -r '$j=json_decode(stream_get_contents(STDIN), true); echo is_array($j) ? var_export($j[$argv[1]] ?? null, true) : "nojson";' "$1"; }
setg() { dbx "INSERT OR REPLACE INTO settings (name,value) VALUES ('$1','$2')"; }
utc() { php -r 'echo gmdate("Y-m-d H:i:s", time() + (int)$argv[1]);' -- "$1"; }
api() { curl -s -b $W/p -X POST $BASE/puzzles_api.php --data-urlencode "csrf=$CS" "$@"; }
rel() { dbv "SELECT COUNT(*) FROM ppal_releases WHERE user_id=$UID_ AND pic_id=$1"; }
tro() { dbv "SELECT COUNT(*) FROM ppal_trophies WHERE user_id=$UID_ AND pic_id=$1"; }
# one free-play go: pic tier -> prints the pfinish JSON ($3 = backdate ms, default enough for any tier)
go() { local pcs; case $2 in easy) pcs=24;; advanced) pcs=96;; *) pcs=216;; esac
  local tk; tk=$(api -d do=pstart -d pic=$1 -d tier=$2 | js token | tr -d "'")
  dbx "UPDATE puzzle_runs SET start_ms = start_ms - ${3:-200000} WHERE token='$tk'"
  api -d do=pfinish -d token=$tk -d drops=$((pcs - 1)); }

echo "== lint tool, data, generator, schema (tests/puzzle_pals.php)"
OUT=$(python3 $HERE/../tools/lint_puzzle_pals.py 2>&1); ok "lint passes on the shipped data" "$(echo "$OUT" | tail -1 | grep -c ' 0 problems')" 1
cp $GAME/includes/data/puzzle_pals.txt $W/bad.txt
echo 'maplewold|mw-acorn-nip|Acorn Nip|common|seedkeeper|9|1|1|0|1-5|corner-TT|round|-|Dupe key, big stats, apostrophe isn'"'"'t curly.' >> $W/bad.txt
echo 'nowhere|x1|Nope|rare|badcalling|1|1|1|0|20-5|corner-TT|round|-|bad picture, rarity shape, piece.' >> $W/bad.txt
echo 'a|b|c' >> $W/bad.txt
OUT=$(python3 $HERE/../tools/lint_puzzle_pals.py $W/bad.txt 2>&1); RC=$?
ok "lint fails on bad rows (exit 1)" "$RC" 1
ok "lint: duplicate key reported" "$(echo "$OUT" | grep -c 'duplicate key')" 1
ok "lint: wrong column count reported" "$(echo "$OUT" | grep -c '3 columns')" 1
ok "lint: bad piece reported" "$(echo "$OUT" | grep -c 'not col-row')" 1
ok "lint: unknown picture reported" "$(echo "$OUT" | grep -c 'unknown picture')" 1
php -d session.save_path=/tmp $HERE/puzzle_pals.php $GAME 2>&1 | tee $W/unit.out | grep -v '^ok'
ok "unit checks (puzzle_pals.php): no FAIL" "$(grep -c '^FAIL\|Fatal\|Warning' $W/unit.out)" 0
ok "unit checks ran" "$(grep -c '^ok' $W/unit.out | awk '{print ($1>30)?"many":$1}')" many

echo "== release hooks"
login $W/a admin TestPassword123
login $W/p sprout 'TestPass123!'
UID_=$(dbv "SELECT id FROM users WHERE username='sprout'")
setg puzzles_open 1; setg jigsaw_open 1; dbx "DELETE FROM settings WHERE name IN ('ppal_open','ppal_party')"
MAP=$(dbv "SELECT id FROM puzzle_pics WHERE slug='jig-maplewold'"); MAIZE=$(dbv "SELECT id FROM puzzle_pics WHERE slug='jig-maizehollow'"); SUN=$(dbv "SELECT id FROM puzzle_pics WHERE slug='jig-sunsprinkle'")
curl -s -b $W/p $BASE/jigsaw.php > $W/j.html; CS=$(grep -o '"csrf":"[^"]*"' $W/j.html | head -1 | sed 's/.*:"\(.*\)"/\1/')
# every authored roster ships real art now; the test COPY moves maizehollow's pal PNGs aside so it plays the "art not ready" picture (the repo is untouched)
mkdir -p $GAME/assets/img/puzzles/pals
for k in mw-acorn-nip mw-leaf-tuck mw-sap-drip mw-bark-badger mw-fourwind-finch mw-samara-spin ss-shell-skip ss-palm-fidget ss-tide-tuck ss-coral-cuff ss-lagoon-loop ss-cocopaddle; do
  { cat $GAME/assets/img/puzzles/pals/_placeholder.png; printf '%s' "$k"; } > $GAME/assets/img/puzzles/pals/$k.png; done
mkdir -p $W/mh-aside; for k in $(grep '^maizehollow|' $GAME/includes/data/puzzle_pals.txt | cut -d'|' -f2); do mv $GAME/assets/img/puzzles/pals/$k.png $W/mh-aside/ 2>/dev/null; done
R=$(go jig-maplewold advanced)
ok "ppal_open off: an Advanced solve counts but releases nothing" "$(echo "$R" | js ok)/$(rel $MAP)/$(echo "$R" | js ppal)" "true/0/NULL"
setg ppal_open 1
R=$(go jig-maplewold easy)
ok "Easy done: no release, no trophy" "$(echo "$R" | js ok)/$(rel $MAP)/$(tro $MAP)" "true/0/0"
R=$(go jig-maplewold advanced 1000)
ok "Advanced too fast: rejected, no release" "$(echo "$R" | js rejected)/$(rel $MAP)" "true/0"
R=$(go jig-maplewold advanced)
ok "Advanced done (free play): 1 release row" "$(echo "$R" | js ok)/$(rel $MAP)" "true/1"
ok "...the win response says so (title, 6 pals, no trophy)" "$(echo "$R" | php -r '$j=json_decode(stream_get_contents(STDIN),true); $p=$j["ppal"]??[]; echo ($p["title"]??"").",".($p["released"]??"").",".var_export($p["trophy"]??null,true);')" "The Maplewold,6,false"
ok "...row says src free" "$(dbv "SELECT src FROM ppal_releases WHERE user_id=$UID_ AND pic_id=$MAP")" free
ok "...and the gnome is told (notice)" "$(dbv "SELECT COUNT(*) FROM notices WHERE user_id=$UID_ AND text LIKE '%Puzzle Pals from The Maplewold%'")" 1
R=$(go jig-maplewold advanced)
ok "Advanced again: still 1 release, nothing new in the response" "$(rel $MAP)/$(echo "$R" | js ppal)" "1/NULL"
R=$(go jig-maizehollow advanced)
ok "Advanced on a picture whose art is not ready: nothing released for a player" "$(echo "$R" | js ok)/$(rel $MAIZE)" "true/0"
R=$(go jig-maplewold expert)
ok "Expert done: a trophy, no new release" "$(tro $MAP)/$(rel $MAP)/$(echo "$R" | php -r '$j=json_decode(stream_get_contents(STDIN),true); echo var_export($j["ppal"]["trophy"]??null,true);')" "1/1/true"
R=$(go jig-maplewold expert)
ok "Expert again: still one trophy" "$(tro $MAP)/$(echo "$R" | js ppal)" "1/NULL"
R=$(go jig-sunsprinkle expert 1000)
ok "Expert too fast: rejected, no trophy" "$(echo "$R" | js rejected)/$(tro $SUN)" "true/0"
R=$(go jig-sunsprinkle expert)
ok "Expert without a release: trophy only" "$(tro $SUN)/$(rel $SUN)" "1/0"
ok "trophy row is per user and picture (UNIQUE)" "$(dbv "SELECT COUNT(*) FROM (SELECT user_id,pic_id FROM ppal_trophies GROUP BY 1,2 HAVING COUNT(*)>1)")" 0
ok "ppal_party off: no trophy unit" "$(php -r '$_SERVER["SCRIPT_NAME"]="/index.php"; require $argv[1]."/includes/bootstrap.php"; require APP_ROOT."/includes/puzzle_pals.php"; echo ppal_trophy_unit((int)$argv[2], (int)$argv[3]);' $GAME $UID_ $MAP)" 0
setg ppal_party 1
ok "ppal_party on: the trophy is worth +4 to that picture, 0 to another" "$(php -r '$_SERVER["SCRIPT_NAME"]="/index.php"; require $argv[1]."/includes/bootstrap.php"; require APP_ROOT."/includes/puzzle_pals.php"; echo ppal_trophy_unit((int)$argv[2], (int)$argv[3]).ppal_trophy_unit((int)$argv[2], (int)$argv[4]);' $GAME $UID_ $MAP $MAIZE)" 40
setg ppal_party 0

echo "== tournament hook"
setg jigsaw_tournaments 1
mk() { local pcs; case $2 in advanced) pcs=96;; *) pcs=216;; esac
  dbx "INSERT INTO puzzle_tournaments (title,pic_id,pieces,starts_at,ends_at,status,kind,tier,created_at) VALUES ('$1',$3,$pcs,'$(utc -3600)','$(utc 86400)','live','still','$2','$(utc -3600)')"
  dbv "SELECT MAX(id) FROM puzzle_tournaments"; }
tgo() { local pcs; case $2 in advanced) pcs=96;; *) pcs=216;; esac
  local tk; tk=$(api -d do=start -d t=$1 | js token | tr -d "'")
  dbx "UPDATE puzzle_attempts SET start_ms = start_ms - ${3:-200000} WHERE token='$tk'"
  api -d do=finish -d token=$tk -d drops=$((pcs - 1)); }
T1=$(mk 'Sun Advanced' advanced $SUN)
R=$(tgo $T1 advanced 1000)
ok "tournament Advanced too fast: rejected, nothing released" "$(echo "$R" | js rejected)/$(rel $SUN)" "true/0"
R=$(tgo $T1 advanced)
ok "tournament Advanced done: releases the picture (src tourney)" "$(echo "$R" | js ok)/$(rel $SUN)/$(dbv "SELECT src FROM ppal_releases WHERE user_id=$UID_ AND pic_id=$SUN")" "true/1/tourney"
T2=$(mk 'Maize Expert' expert $MAIZE)
R=$(tgo $T2 expert)
ok "tournament Expert done: a trophy (src tourney), no release" "$(tro $MAIZE)/$(rel $MAIZE)/$(dbv "SELECT src FROM ppal_trophies WHERE user_id=$UID_ AND pic_id=$MAIZE")" "1/0/tourney"
T3=$(mk 'Maize Advanced' advanced $MAIZE)
R=$(tgo $T3 advanced)
ok "tournament Advanced without art: no release for a player" "$(rel $MAIZE)" 0

echo "== admin, guest, flag off"
dbx "DELETE FROM ppal_releases; DELETE FROM ppal_trophies"
ok "admin is not blocked by missing art (rosters are previewable)" "$(php -r '$_SERVER["SCRIPT_NAME"]="/index.php"; require $argv[1]."/includes/bootstrap.php"; require APP_ROOT."/includes/puzzle_pals.php"; $GLOBALS["CURRENT_USER"]=q_one("SELECT * FROM users WHERE username=\"admin\""); echo count(ppal_on_solve((int)$GLOBALS["CURRENT_USER"]["id"], (int)$argv[2], "advanced", "free"));' $GAME $MAIZE)" 4
setg guest_open 1; dbx "DELETE FROM login_attempts"
curl -s -c $W/g -b $W/g $BASE/guest.php > $W/g.html; curl -s -c $W/g -b $W/g -o /dev/null -X POST $BASE/guest.php --data-urlencode "csrf=$(csrf $W/g.html)"
GID=$(dbv "SELECT id FROM users WHERE guest=1 ORDER BY id DESC LIMIT 1")
ok "a guest gnome exists for the test" "$([ -n "$GID" ] && echo y)" y
ok "ppal_on_solve skips a guest (no rows)" "$(php -r '$_SERVER["SCRIPT_NAME"]="/index.php"; require $argv[1]."/includes/bootstrap.php"; require APP_ROOT."/includes/puzzle_pals.php"; ppal_on_solve((int)$argv[2], (int)$argv[3], "advanced", "free"); ppal_on_solve((int)$argv[2], (int)$argv[3], "expert", "free"); echo count(ppal_on_solve((int)$argv[2], (int)$argv[3], "advanced", "free"));' $GAME $GID $MAP)/$(dbv "SELECT COUNT(*) FROM ppal_releases WHERE user_id=$GID")/$(dbv "SELECT COUNT(*) FROM ppal_trophies WHERE user_id=$GID")" "0/0/0"
dbx "INSERT INTO ppal_releases (user_id,pic_id,released_at,src) VALUES ($GID,$MAP,'$(utc 0)','free'); INSERT INTO ppal_found (user_id,pal_key,pic_id,found_at) VALUES ($GID,'mw-acorn-nip',$MAP,'$(utc 0)'); INSERT INTO ppal_trophies (user_id,pic_id,earned_at) VALUES ($GID,$MAP,'$(utc 0)')"
ok "guest purge deletes every ppal row of the guest" "$(php -r '$_SERVER["SCRIPT_NAME"]="/index.php"; require $argv[1]."/includes/bootstrap.php"; require APP_ROOT."/includes/guest.php"; q("UPDATE users SET last_seen=\"2000-01-01 00:00:00\", created_at=\"2000-01-01 00:00:00\" WHERE id=".(int)$argv[2]); guest_purge(true);' $GAME $GID; dbv "SELECT (SELECT COUNT(*) FROM ppal_releases WHERE user_id=$GID)+(SELECT COUNT(*) FROM ppal_found WHERE user_id=$GID)+(SELECT COUNT(*) FROM ppal_trophies WHERE user_id=$GID)+(SELECT COUNT(*) FROM users WHERE id=$GID)")" 0
setg ppal_open 0;
R=$(go jig-maplewold advanced)
ok "flag off again: nothing released" "$(rel $MAP)" 0
echo "== step 2: finds are on the map only (page mode and its find lane were removed)"
dbx "DELETE FROM ppal_releases; DELETE FROM ppal_found; DELETE FROM ppal_trophies"
setg ppal_open 1; setg event_chance 5000; dbx "DELETE FROM settings WHERE name IN ('ppal_find_mode','ppal_chance','ppal_cooldown_minutes','ppal_daily_max')"
dbx "INSERT OR IGNORE INTO ppal_releases (user_id,pic_id,released_at,src) VALUES ($UID_,$MAP,'$(utc 0)','free')"
PF=0; for i in $(seq 30); do curl -s -b $W/p -c $W/p $BASE/garden.php | grep -q 'eventbox waiting' && PF=$((PF+1)); done
ok "released pictures: 30 page views never show a find card" "$PF" 0
ok "...and no found row comes from a page view" "$(dbv "SELECT COUNT(*) FROM ppal_found WHERE user_id=$UID_")" 0
ok "the removed settings are gone from Admin > Settings" "$(curl -s -b $W/a $BASE/admin/settings.php | grep -c 'ppal_find_mode\|ppal_chance\|ppal_cooldown_minutes\|ppal_daily_max')" 0
setg ppal_open 0
ok "flag off: the book is a 302" "$(curl -s -o /dev/null -w '%{http_code}' -b $W/p $BASE/puzzlepals.php)" 302
ok "flag off: the Puzzles hub has no Puzzle Pals link" "$(curl -s -b $W/p $BASE/puzzles.php | grep -c 'puzzlepals.php')" 0
setg ppal_open 1; dbx "DELETE FROM login_attempts"
curl -s -c $W/g -b $W/g $BASE/guest.php > $W/g.html; curl -s -c $W/g -b $W/g -o /dev/null -X POST $BASE/guest.php --data-urlencode "csrf=$(csrf $W/g.html)"
ok "guest: the book is a 302" "$(curl -s -o /dev/null -w '%{http_code}' -b $W/g $BASE/puzzlepals.php)" 302

echo "== step 3: the Pal Book"
dbx "DELETE FROM ppal_found; DELETE FROM ppal_releases WHERE user_id=$UID_; DELETE FROM ppal_trophies"
B() { curl -s -b $W/p $BASE/puzzlepals.php; }
B > $W/b.html
ok "book, nothing released: empty state, 0 of 0" "$(grep -c 'No pals yet' $W/b.html)/$(grep -c '<b>0</b> of 0 pals found' $W/b.html)" "1/1"
dbx "INSERT INTO ppal_releases (user_id,pic_id,released_at,src) VALUES ($UID_,$MAP,'$(utc 0)','free'),($UID_,$SUN,'$(utc 0)','free')"
for k in mw-acorn-nip mw-sap-drip mw-samara-spin; do dbx "INSERT INTO ppal_found (user_id,pal_key,pic_id,found_at,times) VALUES ($UID_,'$k',$MAP,'$(utc 0)',$([ $k = mw-sap-drip ] && echo 3 || echo 1))"; done
B > $W/b.html
ok "book: 200 and header counts 3 of 12, 2 pictures" "$(grep -c '<b>3</b> of 12 pals found' $W/b.html)/$(grep -c '<b>2</b> pictures released' $W/b.html)" "1/1"
ok "book: 12 slots, 3 found stickers, 9 silhouettes with a ?" "$(grep -c 'class="ppalslot' $W/b.html)/$(grep -c 'ppalslot ppr-[a-z]* got' $W/b.html)/$(grep -c 'ppalslot ppr-[a-z]* miss' $W/b.html)/$(grep -c 'class="ppalart ppsil"' $W/b.html)" "12/3/9/9"
ok "book: section counts '3 of 6 found' and '0 of 6 found'" "$(grep -c '<b>3</b> of 6 found' $W/b.html)/$(grep -c '<b>0</b> of 6 found' $W/b.html)" "1/1"
ok "book: a found pal shows name, rarity, date and 'met 3×'" "$(grep -o 'Sap Drip</b>' $W/b.html | wc -l | tr -d ' ')/$(grep -c 'met 3×' $W/b.html)/$(grep -c 'found [0-9]* [A-Z][a-z][a-z] 20' $W/b.html)" "1/1/3"
ok "book: a missing pal's name is hidden" "$(grep -v 'ppalwaiting' $W/b.html | grep -c 'Bark Badger')" 0
ok "book: piece chip crops use classes only (no inline style anywhere)" "$(grep -c 'ppiece pcx[0-9]* pcy[0-9]* ppchip' $W/b.html)/$(grep -c ' style=' $W/b.html)" "3/0"
ok "book: every pal image resolves (no broken images)" "$(grep -o 'src="[^"]*"' $W/b.html | sed 's/src="//; s/"$//' | grep -E 'puzzles/pals|jigsaw' | while read u; do curl -s -o /dev/null -w '%{http_code}\n' "$BASE$u"; done | grep -vc 200)" 0
ok "book: not locked-listed while unready (Maize has no art)" "$(grep -c 'Solve Maize' $W/b.html)" 0
for k in $(grep '^maizehollow|' $GAME/includes/data/puzzle_pals.txt | cut -d'|' -f2); do { cat $GAME/assets/img/puzzles/pals/_placeholder.png; printf '%s' "$k"; } > $GAME/assets/img/puzzles/pals/$k.png; done
dbx "INSERT INTO ppal_trophies (user_id,pic_id,earned_at) VALUES ($UID_,$MAP,'$(utc 0)'),($UID_,$MAIZE,'$(utc 0)')"
B > $W/b.html
ok "book: an unreleased art-ready picture is listed 'Solve ... at Advanced to release its pals'" "$(grep -c 'Solve Maizehollow at Advanced to release its pals' $W/b.html)/$(grep -c 'Still locked' $W/b.html)" "1/1"
ok "book: Expert trophy shows on the released picture AND on the locked one" "$(grep -c 'ppaltrophychip' $W/b.html)" 2
echo "-- art fallback"
rm -f $GAME/assets/img/puzzles/pals/mw-acorn-nip.png
B > $W/b.html
ok "found pal with no art: shows its piece crop, no img to the missing file" "$(grep -c 'mw-acorn-nip.png' $W/b.html)/$(grep -c 'ppiece pcx[0-9]* pcy[0-9]* ppbig' $W/b.html)" "0/1"
{ cat $GAME/assets/img/puzzles/pals/_placeholder.png; printf 'mw-acorn-nip'; } > $GAME/assets/img/puzzles/pals/mw-acorn-nip.png
ok "pixel pictures crop hard-edged, gallery ones smooth (ppal_piece_html)" "$(php -r '$_SERVER["SCRIPT_NAME"]="/index.php"; require $argv[1]."/includes/bootstrap.php"; require APP_ROOT."/includes/puzzle_pals.php"; $pl=q_one("SELECT * FROM puzzle_pics WHERE source=\"place\" LIMIT 1"); $g=q_one("SELECT * FROM puzzle_pics WHERE slug=\"jig-maplewold\""); echo (strpos(ppal_piece_html($pl,"7-3"),"ppiece pcx7 pcy3 px")!==false?"px":"no"),"/",(strpos(ppal_piece_html($g,"7-3"),"px")===false?"smooth":"no"),"/",var_export(ppal_piece_html($g,"12-3")==="" && ppal_piece_html($g,"x")==="",true);' $GAME)" "px/smooth/true"
echo "-- hub card, Jigsaw pip, profile shelf, win card"
curl -s -b $W/p $BASE/puzzles.php > $W/h.html
ok "hub: Puzzle Pals card + Jigsaw pip 'pals 3/12'" "$(grep -c 'pzhubcard" href="[^"]*puzzlepals.php"' $W/h.html)/$(grep -c 'pals 3/12' $W/h.html)" "1/1"
curl -s -b $W/p $BASE/jigsaw.php > $W/j.html
ok "jigsaw page data carries the pips for released pictures" "$(grep -c '"pals":{' $W/j.html)" 1
ok "puzzles.js: win card line and library pip are wired" "$(grep -c 'The magic of the jigsaw is loose' $GAME/assets/puzzles.js)/$(grep -c 'MODE.pals' $GAME/assets/puzzles.js)" "1/2"
curl -s -b $W/p "$BASE/profile.php?id=$UID_&tab=awards" > $W/pr.html
ok "profile: an incomplete roster has no frame, the trophy shows" "$(grep -c 'ppalframe' $W/pr.html)/$(grep -o 'class="ppaltrophy"' $W/pr.html | wc -l | tr -d ' ')" "0/2"
for k in mw-leaf-tuck mw-bark-badger mw-fourwind-finch; do dbx "INSERT INTO ppal_found (user_id,pal_key,pic_id,found_at) VALUES ($UID_,'$k',$MAP,'$(utc 0)')"; done
curl -s -b $W/p "$BASE/profile.php?id=$UID_&tab=awards" > $W/pr.html
ok "profile: a complete roster gets a frame badge" "$(grep -c 'class="ppalframe"' $W/pr.html)" 1
B > $W/b.html
ok "book: a complete roster is marked (full) and counts 6 of 6" "$(grep -c 'ppalsec full' $W/b.html)/$(grep -c 'roster complete' $W/b.html)" "1/1"
setg ppal_open 0
ok "flag off: profile shelf hidden" "$(curl -s -b $W/p "$BASE/profile.php?id=$UID_&tab=awards" | grep -c 'ppalbadges')" 0
setg ppal_open 1
echo "== step 4: take along, perks, avatar companions"
setg ppal_open 1; dbx "DELETE FROM settings WHERE name IN ('ppal_party','ppal_party_max')"; dbx "UPDATE users SET level=15 WHERE id=$UID_; UPDATE ppal_found SET active=0 WHERE user_id=$UID_"
act() { dbv "SELECT COUNT(*) FROM ppal_found WHERE user_id=$UID_ AND active=1"; }
take() { curl -s -b $W/p -c $W/p -o /dev/null -w '%{http_code}' -X POST $BASE/puzzlepals.php --data-urlencode "csrf=$(B | grep -o 'name="csrf" value="[^"]*"' | head -1 | sed 's/.*value="\([^"]*\)".*/\1/')" -d pal=$1 -d do=$2 "${@:3}"; }
B > $W/b.html
ok "ppal_party off: no party strip, no Take along button, no companions" "$(grep -c 'ppalparty\|Take along' $W/b.html)/$(curl -s -b $W/p $BASE/gnome.php | grep -c 'class="gpw')" "0/0"
ok "ppal_party off: a POST is ignored (nothing equipped)" "$(take mw-acorn-nip on)/$(act)" "200/0"
setg ppal_party 1
B > $W/b.html
ok "ppal_party on, level 15: party strip with 2 empty slots and a Take along button on each found pal" "$(grep -c 'Room for a pal' $W/b.html)/$(grep -c '>Take along<' $W/b.html)" "2/6"
ok "...and no inline styles" "$(grep -c ' style=' $W/b.html)" 0
ok "Take along #1 and #2 (redirects back)" "$(take mw-acorn-nip on)/$(take mw-leaf-tuck on)/$(act)" "302/302/2"
B > $W/b.html
ok "party full: the strip shows both pals with their perk lines (the Expert trophy's +4 counted), the other pals offer Swap" "$(grep -c 'ppalpslot got' $W/b.html)/$(grep -o 'Brings +12% XP from games' $W/b.html | wc -l | tr -d ' ')/$(grep -c '>Swap with' $W/b.html)/$(grep -c '>Send home<' $W/b.html)" "2/3/4/2"
ok "a third POST is refused (still 2)" "$(take mw-sap-drip on)/$(act)" "302/2"
GP=$(curl -s -b $W/p $BASE/gnome.php | grep -o 'class="gpal gpal-[lr]"' | wc -l | tr -d ' ')
ok "the gnome page shows the 2 companions wherever the gnome shows (nav + page + drawer twin: pairs)" "$([ $GP -ge 2 ] && [ $((GP % 2)) -eq 0 ] && echo pairs || echo $GP)" pairs
ok "the profile (public) shows them too" "$(curl -s -b $W/p "$BASE/profile.php?id=$UID_" | grep -c 'class="gpal gpal-')" 2
ok "Swap: one goes home, the new one comes along" "$(take mw-sap-drip swap -d out=mw-acorn-nip)/$(act)/$(dbv "SELECT active FROM ppal_found WHERE user_id=$UID_ AND pal_key='mw-acorn-nip'")/$(dbv "SELECT active FROM ppal_found WHERE user_id=$UID_ AND pal_key='mw-sap-drip'")" "302/2/0/1"
ok "Send home" "$(take mw-sap-drip off)/$(act)" "302/1"
ok "a wrong csrf token is refused (400)" "$(curl -s -b $W/p -o /dev/null -w '%{http_code}' -X POST $BASE/puzzlepals.php -d csrf=bad -d pal=mw-acorn-nip -d do=on)" 400
dbx "UPDATE users SET level=2 WHERE id=$UID_"
B > $W/b.html
ok "level 2: no level gate (2.0.91): Take along buttons and companions show" "$(grep -c '>Take along<\|>Swap with' $W/b.html | awk '{print ($1>0)?1:0}')/$(curl -s -b $W/p $BASE/gnome.php | grep -c 'class="gpw' | awk '{print ($1>0)?1:0}')" "1/1"
dbx "UPDATE users SET level=15 WHERE id=$UID_"
setg ppal_party 0
ok "back to ppal_party 0: companions gone from the gnome page" "$(curl -s -b $W/p $BASE/gnome.php | grep -c 'class="gpw')" 0
dbx "UPDATE ppal_found SET active=0 WHERE user_id=$UID_"
echo "-- perk maths, gates, avatar (tests/puzzle_pals_party.php)"
php -d session.save_path=/tmp $HERE/puzzle_pals_party.php $GAME 2>&1 | tee $W/party.out | grep -v '^ok'
ok "party checks: no FAIL, ends all ok" "$(grep -c "^FAIL\|Fatal\|Warning" $W/party.out)/$(tail -1 $W/party.out)" "0/all ok"
ok "party checks ran" "$(grep -c '^ok' $W/party.out | awk '{print ($1>35)?"many":$1}')" many
setg ppal_open 1
echo "-- pals on the map (tests/puzzle_pals_map.php)"
php -d session.save_path=/tmp $HERE/puzzle_pals_map.php $GAME 2>&1 | tee $W/map.out | grep -v '^ok'
ok "map checks: no FAIL, ends all ok" "$(grep -c "^FAIL\|Fatal\|Warning" $W/map.out)/$(tail -1 $W/map.out)" "0/all ok"
ok "map checks ran" "$(grep -c '^ok' $W/map.out | awk '{print ($1>20)?"many":$1}')" many
setg ppal_open 1
echo "-- admin tool"
ok "admin tools page has the 'Test a pal find' button" "$(curl -s -b $W/a $BASE/admin/tools.php | grep -c 'value="test_ppal"')" 1
ok "...and posting it is accepted (302)" "$(curl -s -b $W/a -c $W/a -o /dev/null -w '%{http_code}' -X POST $BASE/admin/tools.php --data-urlencode "csrf=$(curl -s -b $W/a $BASE/admin/tools.php | grep -o 'name="csrf" value="[^"]*"' | head -1 | sed 's/.*value="\([^"]*\)".*/\1/')" -d do=test_ppal)" 302
ok "lint still passes" "$(python3 $HERE/../tools/lint_puzzle_pals.py 2>&1 | tail -1 | grep -c ' 0 problems')" 1
setg ppal_open 0
ok "PHP log has no warnings" "$(grep -c 'Warning\|Notice\|Fatal\|Deprecated' ${TMPDIR:-/tmp}/ppal-php.log)" 0
