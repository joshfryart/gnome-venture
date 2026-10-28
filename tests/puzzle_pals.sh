#!/usr/bin/env bash
# v2.0.88 Puzzle Pals build step 1 (includes/puzzle_pals.php): lint tool, data/generator/art gate/schema (tests/puzzle_pals.php), and the release hooks:
# an Advanced (96) done solve releases the picture's pals once, Easy releases nothing, Expert (216) earns a trophy once, flag off / rejected / guest / art-not-ready = nothing,
# free play AND tournament both hook in. Takes a walk.sh-installed copy: puzzle_pals.sh GAME PORT ROUTER.
GAME=$1; PORT=$2; ROUTER=$3; BASE=http://127.0.0.1:$PORT
HERE=$(cd "$(dirname "$0")" && pwd)
php -d session.save_path=/tmp -S 127.0.0.1:$PORT -t $GAME $ROUTER >/tmp/ppal-php.log 2>&1 & PID=$!; sleep 1
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
# real (non-placeholder) art for maplewold and sunsprinkle only; maizehollow stays without art
mkdir -p $GAME/assets/img/puzzles/pals
for k in mw-acorn-nip mw-leaf-tuck mw-sap-drip mw-bark-badger mw-fourwind-finch mw-samara-spin ss-shell-skip ss-palm-fidget ss-tide-tuck ss-coral-cuff ss-lagoon-loop ss-cocopaddle; do
  { cat $GAME/assets/img/puzzles/pals/_placeholder.png; printf '%s' "$k"; } > $GAME/assets/img/puzzles/pals/$k.png; done
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
ok "ppal_party on: the trophy is worth +1 to that picture, 0 to another" "$(php -r '$_SERVER["SCRIPT_NAME"]="/index.php"; require $argv[1]."/includes/bootstrap.php"; require APP_ROOT."/includes/puzzle_pals.php"; echo ppal_trophy_unit((int)$argv[2], (int)$argv[3]).ppal_trophy_unit((int)$argv[2], (int)$argv[4]);' $GAME $UID_ $MAP $MAIZE)" 10
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
ok "admin is not blocked by missing art (rosters are previewable)" "$(php -r '$_SERVER["SCRIPT_NAME"]="/index.php"; require $argv[1]."/includes/bootstrap.php"; require APP_ROOT."/includes/puzzle_pals.php"; $GLOBALS["CURRENT_USER"]=q_one("SELECT * FROM users WHERE username=\"admin\""); echo count(ppal_on_solve((int)$GLOBALS["CURRENT_USER"]["id"], (int)$argv[2], "advanced", "free"));' $GAME $MAIZE)" 3
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
ok "PHP log has no warnings" "$(grep -c 'Warning\|Notice\|Fatal\|Deprecated' /tmp/ppal-php.log)" 0
