#!/usr/bin/env bash
# v2.0.87 B + C: Jigsaw tournaments (kind 'still', one picture and one tier each) and Admin > Jigsaw.
# Pieces and daily tries come from the TIER only; the tournament API gates on the tournament's own kind (both ways); lifecycle soon/open/closing/settled with a mystery
# card before it opens; cups of three tiers; reserved pictures hidden then released; Places refused; cancel = no places; void; settle + tier pip; guests blocked;
# admin pages: non-admin 403, CSRF, bad tier refused, upload checks (3:2, size, EXIF stripped, thumb made), CSV.
GAME=$1; PORT=$2; ROUTER=$3; BASE=http://127.0.0.1:$PORT
php -d session.save_path=/tmp -d max_file_uploads=50 -S 127.0.0.1:$PORT -t $GAME $ROUTER >/tmp/jigt-php.log 2>&1 & PID=$!; sleep 1
W=$(mktemp -d); trap "kill $PID 2>/dev/null; rm -rf $W" EXIT
csrf() { grep -o 'name="csrf" value="[^"]*"' "$1" | head -1 | sed 's/.*value="\([^"]*\)".*/\1/'; }
dbv() { php -r '$p=new PDO("sqlite:'$GAME'/data/game.sqlite"); echo $p->query($argv[1])->fetchColumn();' "$1"; }
dbx() { php -r '$p=new PDO("sqlite:'$GAME'/data/game.sqlite"); $p->exec($argv[1]);' "$1"; }
login() { rm -f $1; curl -s -c $1 -b $1 $BASE/login.php > $W/l.html; curl -s -c $1 -b $1 -X POST $BASE/login.php --data-urlencode "csrf=$(csrf $W/l.html)" -d username=$2 --data-urlencode "password=$3" -o /dev/null; }
ok() { if [ "$2" = "$3" ]; then echo "ok   $1"; else echo "FAIL $1 (got '$2', want '$3')"; fi; }
js() { php -r '$j=json_decode(stream_get_contents(STDIN), true); echo is_array($j) ? var_export($j[$argv[1]] ?? null, true) : "nojson";' "$1"; }
setg() { dbx "INSERT OR REPLACE INTO settings (name,value) VALUES ('$1','$2')"; }
ge() { if [ "$2" -ge "$3" ] 2>/dev/null; then echo "ok   $1"; else echo "FAIL $1 (got '$2', want >= $3)"; fi; }
code() { curl -s -o /dev/null -w '%{http_code}' "$@"; }
hol() { php -r 'date_default_timezone_set("America/Halifax"); echo date("Y-m-d\TH:i", time() + (int)$argv[1]);' -- "$1"; }
utc() { php -r 'echo gmdate("Y-m-d H:i:s", time() + (int)$argv[1]);' -- "$1"; }
SPR=; API_CS=
api() { curl -s -b $W/p -X POST $BASE/puzzles_api.php --data-urlencode "csrf=$API_CS" "$@"; }
# a still tournament straight in the database: title tier pic_id starts_offset ends_offset [status] [cup]
mk() { local pcs; case $2 in easy) pcs=24;; advanced) pcs=96;; *) pcs=216;; esac
  dbx "INSERT INTO puzzle_tournaments (title,pic_id,pieces,starts_at,ends_at,status,kind,tier,cup_id,created_at) VALUES ('$1',$3,$pcs,'$(utc $4)','$(utc $5)','${6:-live}','still','$2',${7:-NULL},'$(utc 0)')"
  dbv "SELECT MAX(id) FROM puzzle_tournaments"; }
done_run() { dbx "INSERT INTO puzzle_attempts (tournament_id,user_id,token,seed,started_at,start_ms,finished_at,ms,drops,status) VALUES ($1,$2,'$(printf '%032x' $RANDOM$RANDOM$3)',1,'$(utc -600)',0,'$(utc -500)',$3,300,'done')"; }
login $W/a admin TestPassword123
login $W/p sprout 'TestPass123!'
setg puzzles_open 1; setg jigsaw_open 1; setg jigsaw_tournaments 1; setg puzzles_tournaments 0
UID_=$(dbv "SELECT id FROM users WHERE username='sprout'")
curl -s -b $W/a "$BASE/admin/jigsaw.php?tab=tournaments" > $W/t.html; T=$(csrf $W/t.html)
adm() { curl -s -b $W/a -o /dev/null -w '%{http_code}' -X POST $BASE/admin/jigsaw.php --data-urlencode "csrf=$T" "$@"; }
MAP=$(dbv "SELECT id FROM puzzle_pics WHERE slug='jig-maplewold'"); MAIZE=$(dbv "SELECT id FROM puzzle_pics WHERE slug='jig-maizehollow'"); SUN=$(dbv "SELECT id FROM puzzle_pics WHERE slug='jig-sunsprinkle'")
PLACE=$(dbv "SELECT id FROM puzzle_pics WHERE source='place' LIMIT 1")
GIFP=$(dbv "SELECT id FROM puzzle_pics WHERE slug='sunflower'")

echo "== admin page: access, menu, CSRF, validation"
ok "admin page loads" "$(code -b $W/a $BASE/admin/jigsaw.php)" 200
ok "non-admin gets 403" "$(code -b $W/p $BASE/admin/jigsaw.php)" 403
ok "non-admin POST refused" "$(code -b $W/p -X POST $BASE/admin/jigsaw.php -d csrf=x -d do=tour_save)" 403
ge "admin menu has Jigsaw" "$(curl -s -b $W/a $BASE/admin/index.php | grep -c 'admin/jigsaw.php')" 1
ok "no CSRF refused" "$(code -b $W/a -X POST $BASE/admin/jigsaw.php -d do=tour_save -d title=Nope)" 400
N0=$(dbv "SELECT COUNT(*) FROM puzzle_tournaments")
mkform() { echo --data-urlencode "title=$1" -d "pic_id=$2" -d "tier=$3" -d "starts_at=$(hol $4)" -d "ends_at=$(hol $5)" -d "status=live"; }
adm -d do=tour_save -d id=0 $(mkform Bad $MAP sixty -3600 3600) >/dev/null
adm -d do=tour_save -d id=0 $(mkform Bad $MAP 54 -3600 3600) >/dev/null
adm -d do=tour_save -d id=0 $(mkform Bad $MAP '' -3600 3600) >/dev/null
ok "bad tier / a piece count as tier / no tier: nothing made" "$(dbv "SELECT COUNT(*) FROM puzzle_tournaments")" "$N0"
adm -d do=tour_save -d id=0 $(mkform Bad $PLACE easy -3600 3600) >/dev/null
ok "a Places picture can't be a tournament" "$(dbv "SELECT COUNT(*) FROM puzzle_tournaments")" "$N0"
adm -d do=tour_save -d id=0 $(mkform Bad $GIFP easy -3600 3600) >/dev/null
ok "a GIFsaw picture can't be a Jigsaw tournament" "$(dbv "SELECT COUNT(*) FROM puzzle_tournaments")" "$N0"
adm -d do=tour_save -d id=0 $(mkform Backwards $MAP easy 3600 -3600) >/dev/null
ok "bad times refused" "$(dbv "SELECT COUNT(*) FROM puzzle_tournaments")" "$N0"
adm -d do=tour_save -d id=0 -d pieces=999 $(mkform 'PostedPieces' $MAP advanced -3600 3600) >/dev/null
ok "pieces come from the tier, a posted count is ignored (96)" "$(dbv "SELECT pieces||tier||kind FROM puzzle_tournaments WHERE title='PostedPieces'")" 96advancedstill
ok "admin_log has the save" "$(dbv "SELECT COUNT(*) FROM admin_log WHERE action='jigsaw_tourney'")" 1
curl -s -b $W/a "$BASE/admin/jigsaw.php?tab=tournaments" > $W/t.html
ok "tier radio shows the piece counts" "$(grep -c '24 pieces' $W/t.html)/$(grep -c '96 pieces' $W/t.html)/$(grep -c '216 pieces' $W/t.html)" 1/1/1
ok "GIFsaw admin page does not list the Jigsaw tournament" "$(curl -s -b $W/a "$BASE/admin/puzzles.php?tab=tournaments" | grep -c 'PostedPieces')" 0
dbx "DELETE FROM puzzle_tournaments WHERE title='Posted Pieces'"

echo "== a cup: three tiers sharing a cup_id"
# a picture reserved for it, so we can watch it come back into free play
dbx "UPDATE puzzle_pics SET reserved=1 WHERE id=$MAP"
adm -d do=tour_cup --data-urlencode "title=Spring Cup" -d "pic_id=$MAP" -d "starts_at=$(hol -3600)" -d "ends_at=$(hol 3600)" -d status=live >/dev/null
ok "cup made 3 rows with one cup_id" "$(dbv "SELECT COUNT(*)||'/'||COUNT(DISTINCT cup_id) FROM puzzle_tournaments WHERE title LIKE 'Spring Cup - %'")" 3/1
ok "cup pieces from the tiers 24/96/216" "$(dbv "SELECT group_concat(pieces) FROM (SELECT pieces FROM puzzle_tournaments WHERE title LIKE 'Spring Cup - %' ORDER BY pieces)")" 24,96,216
ok "cup titles carry the tier" "$(dbv "SELECT group_concat(title,'|') FROM (SELECT title FROM puzzle_tournaments WHERE cup_id IS NOT NULL ORDER BY pieces)")" "Spring Cup - Easy|Spring Cup - Advanced|Spring Cup - Expert"
ok "cup shares picture and times" "$(dbv "SELECT COUNT(DISTINCT pic_id||starts_at||ends_at||status) FROM puzzle_tournaments WHERE cup_id IS NOT NULL")" 1
ok "admin_log has the cup" "$(dbv "SELECT COUNT(*) FROM admin_log WHERE action='jigsaw_cup'")" 1
E=$(dbv "SELECT id FROM puzzle_tournaments WHERE tier='easy' AND cup_id IS NOT NULL"); A=$(dbv "SELECT id FROM puzzle_tournaments WHERE tier='advanced' AND cup_id IS NOT NULL"); X=$(dbv "SELECT id FROM puzzle_tournaments WHERE tier='expert' AND cup_id IS NOT NULL")
curl -s -b $W/p "$BASE/jigsaw.php?t=$E" > $W/e.html
ok "cup tabs: three, Easy is current" "$(grep -oE 'class="pzchip( on)?"' $W/e.html | wc -l)/$(grep -c "aria-current=\"page\" href=\"[^\"]*t=$E\"" $W/e.html)" 3/1
ok "cup tabs link to the siblings" "$(grep -c "jigsaw.php?t=$A\"" $W/e.html)$(grep -c "jigsaw.php?t=$X\"" $W/e.html)" 11
ok "tab labels" "$(sed -n '/pzcup/,/<\/nav>/p' $W/e.html | sed 's/<[^>]*>//g' | tr -s ' \n' ' ' | sed 's/^ //;s/ $//')" "🌱 Easy 🌿 Advanced 🌳 Expert"

echo "== the page: open phase, tier locked, data blocks"
ok "open: start button + tries left (10 for Easy)" "$(grep -c 'id="tstart"' $W/e.html)/$(grep -o '[0-9]* left today' $W/e.html)" "1/10 left today"
ok "Expert shows 5 tries" "$(curl -s -b $W/p "$BASE/jigsaw.php?t=$X" | grep -o '[0-9]* left today')" "5 left today"
ok "tier select disabled, win card says Another go / See the times" "$(grep -c 'id="count"[^>]*disabled' $W/e.html)/$(grep -c '>Another go<' $W/e.html)/$(grep -c '>See the times<' $W/e.html)" 1/1/1
ok "pz-t has the tier's pieces (24), no free-play flag" "$(php -r 'preg_match("#id=\"pz-t\">(.*?)</script>#s", file_get_contents($argv[1]), $m); preg_match("#id=\"pz-mode\">(.*?)</script>#s", file_get_contents($argv[1]), $n); $t=json_decode($m[1],true); $md=json_decode($n[1],true); echo $t["pieces"].($md["live"]?"L":"-").count($md["tiers"]);' $W/e.html)" 24-3
ge "the picture is shown while open" "$(grep -c 'maplewold-thumb.jpg' $W/e.html)" 1
ok "page is in the player library" "$(curl -s -b $W/p $BASE/jigsaw.php | grep -c "jigsaw.php?t=$E")" 1
ok "GIFsaw library does not list it" "$(curl -s -b $W/p $BASE/gifsaw.php | grep -c "t=$E\"")" 0
ok "hub shows a Tournament badge on the Jigsaw card (GIFsaw tournaments are off)" "$(curl -s -b $W/p $BASE/puzzles.php | grep -c '🏆 Tournament')" 1
ok "games tile shows Tournament" "$(curl -s -b $W/p $BASE/games.php | grep -c '🏆 Tournament')" 1

echo "== API: tier decides pieces and tries; run checks"
API_CS=$(php -r 'preg_match("#id=\"pz-t\">(.*?)</script>#s", file_get_contents($argv[1]), $m); echo json_decode($m[1], true)["csrf"] ?? "";' $W/e.html)
R=$(api -d do=start -d t=$E)
TK=$(echo "$R" | js token | tr -d "'")
ok "start (Easy): token, pieces 24, fixed seed" "$(echo $TK | grep -cE '^[a-f0-9]{32}$')/$(echo "$R" | js pieces)/$(echo "$R" | js seed)" "1/24/$(php -r 'echo crc32("pzt|'$E'") & 0x7fffffff;')"
dbx "UPDATE puzzle_attempts SET start_ms = start_ms - 5000 WHERE token='$TK'"
R=$(api -d do=finish -d token=$TK -d drops=23)
ok "5 s for 24 pieces is too fast (min 9.6 s)" "$(echo "$R" | js rejected)/$(echo "$R" | js tier)/$(echo "$R" | js kind)" "true/'easy'/'still'"
TK=$(api -d do=start -d t=$E | js token | tr -d "'"); dbx "UPDATE puzzle_attempts SET start_ms = start_ms - 12000 WHERE token='$TK'"
R=$(api -d do=finish -d token=$TK -d drops=22)
ok "too few drops (22 < 23) rejected" "$(echo "$R" | js error | grep -c 'too few pieces')" 1
TK=$(api -d do=start -d t=$E | js token | tr -d "'"); dbx "UPDATE puzzle_attempts SET start_ms = start_ms - 12000 WHERE token='$TK'"
R=$(api -d do=finish -d token=$TK -d drops=30)
ok "12 s with 30 drops is a fair Easy run; rank 1; tier + kind returned" "$(echo "$R" | js ok)/$(echo "$R" | js rank)/$(echo "$R" | js tier)/$(echo "$R" | js kind)" "true/1/'easy'/'still'"
TK=$(api -d do=start -d t=$A | js token | tr -d "'"); dbx "UPDATE puzzle_attempts SET start_ms = start_ms - 30000 WHERE token='$TK'"
ok "Advanced: 30 s for 96 pieces is too fast (min 38.4 s)" "$(api -d do=finish -d token=$TK -d drops=96 | js rejected)" true
TK=$(api -d do=start -d t=$X | js token | tr -d "'"); dbx "UPDATE puzzle_attempts SET start_ms = start_ms - 80000 WHERE token='$TK'"
ok "Expert: 80 s for 216 pieces is too fast (min 86.4 s)" "$(api -d do=finish -d token=$TK -d drops=216 | js rejected)" true
ok "no free-play run rows from a tournament" "$(dbv "SELECT COUNT(*) FROM puzzle_runs WHERE game='jigsaw'")" 0
# tries per day: 10 / 10 / 5, setting overrides
fill() { dbx "DELETE FROM puzzle_attempts WHERE tournament_id=$1 AND user_id=$UID_"; for k in $(seq 1 $2); do dbx "INSERT INTO puzzle_attempts (tournament_id,user_id,token,seed,started_at,start_ms,status) VALUES ($1,$UID_,'$(printf '%032d' $(($1 * 1000 + k)))',1,'$(utc 0)',0,'void')"; done; }
fill $E 9;  ok "Easy: 9 used, a 10th is allowed" "$(api -d do=start -d t=$E | js ok)" true
fill $E 10; ok "Easy: 10 used, refused (10 tries)" "$(api -d do=start -d t=$E | js error | grep -c '10 tries today')" 1
fill $A 10; ok "Advanced: 10 used, refused" "$(api -d do=start -d t=$A | js error | grep -c '10 tries today')" 1
fill $X 4;  ok "Expert: 4 used, a 5th is allowed" "$(api -d do=start -d t=$X | js ok)" true
fill $X 5;  ok "Expert: 5 used, refused (5 tries)" "$(api -d do=start -d t=$X | js error | grep -c '5 tries today')" 1
ok "page says 0 left for Expert" "$(curl -s -b $W/p "$BASE/jigsaw.php?t=$X" | grep -o '[0-9]* left today')" "0 left today"
setg jigsaw_tries_expert 7; fill $X 5; ok "setting jigsaw_tries_expert=7: a 6th is allowed" "$(api -d do=start -d t=$X | js ok)" true
fill $X 7; ok "...and 7 used is refused (7 tries)" "$(api -d do=start -d t=$X | js error | grep -c '7 tries today')" 1
dbx "DELETE FROM settings WHERE name='jigsaw_tries_expert'"
fill $X 5; ok "setting removed: Expert is back to 5 a day" "$(api -d do=start -d t=$X | js error | grep -c '5 tries today')" 1
dbx "DELETE FROM puzzle_attempts WHERE user_id=$UID_"

echo "== API gate follows the tournament's own kind"
dbx "INSERT INTO puzzle_tournaments (title,pic_id,pieces,starts_at,ends_at,status,kind,created_at) VALUES ('Sunflower Gate',$GIFP,24,'$(utc -3600)','$(utc 3600)','live','gif','$(utc 0)')"; GT=$(dbv "SELECT id FROM puzzle_tournaments WHERE title='Sunflower Gate'")
dbx "DELETE FROM login_attempts"
setg puzzles_tournaments 0; setg jigsaw_tournaments 1
ok "only Jigsaw tournaments on: a GIFsaw start is refused (403)" "$(code -b $W/p -X POST $BASE/puzzles_api.php --data-urlencode "csrf=$API_CS" -d do=start -d t=$GT)" 403
ok "...and its error says Puzzle tournaments" "$(api -d do=start -d t=$GT | js error | grep -c 'Puzzle tournaments')" 1
ok "...a Jigsaw start still works" "$(api -d do=start -d t=$E | js ok)" true
TKG=$(dbv "SELECT token FROM puzzle_attempts WHERE tournament_id=$E AND user_id=$UID_ AND status='open'")
setg puzzles_tournaments 1; setg jigsaw_tournaments 0
ok "only GIFsaw tournaments on: a Jigsaw start is refused (403)" "$(code -b $W/p -X POST $BASE/puzzles_api.php --data-urlencode "csrf=$API_CS" -d do=start -d t=$E)" 403
ok "...and its error says Jigsaw tournaments" "$(api -d do=start -d t=$E | js error | grep -c 'Jigsaw tournaments')" 1
ok "...finishing a Jigsaw run is refused too" "$(code -b $W/p -X POST $BASE/puzzles_api.php --data-urlencode "csrf=$API_CS" -d do=finish -d token=$TKG -d drops=30)" 403
ok "...a GIFsaw start works" "$(api -d do=start -d t=$GT | js ok)" true
TKS=$(dbv "SELECT token FROM puzzle_attempts WHERE tournament_id=$GT AND user_id=$UID_ AND status='open'")
setg puzzles_tournaments 0; setg jigsaw_tournaments 1
ok "...and finishing a GIFsaw run is refused when only Jigsaw is on" "$(code -b $W/p -X POST $BASE/puzzles_api.php --data-urlencode "csrf=$API_CS" -d do=finish -d token=$TKS -d drops=30)" 403
setg puzzles_tournaments 0; setg jigsaw_tournaments 0
ok "both off: refused" "$(code -b $W/p -X POST $BASE/puzzles_api.php --data-urlencode "csrf=$API_CS" -d do=start -d t=$E)" 403
setg jigsaw_tournaments 1
dbx "DELETE FROM puzzle_attempts WHERE user_id=$UID_"

echo "== cross-kind links, guests"
setg puzzles_tournaments 1
ok "jigsaw.php?t= of a GIFsaw tournament goes to gifsaw.php" "$(curl -s -b $W/p -o /dev/null -w '%{redirect_url}' "$BASE/jigsaw.php?t=$GT" | sed 's#.*/##')" "gifsaw.php?t=$GT"
ok "gifsaw.php?t= of a Jigsaw tournament goes to jigsaw.php" "$(curl -s -b $W/p -o /dev/null -w '%{redirect_url}' "$BASE/gifsaw.php?t=$E" | sed 's#.*/##')" "jigsaw.php?t=$E"
ok "unknown tournament goes back to the library" "$(curl -s -b $W/p -o /dev/null -w '%{redirect_url}' "$BASE/jigsaw.php?t=99999" | sed 's#.*/##')" jigsaw.php
setg guest_open 1; dbx "DELETE FROM login_attempts"
curl -s -c $W/g -b $W/g $BASE/guest.php > $W/g.html; curl -s -c $W/g -b $W/g -o /dev/null -X POST $BASE/guest.php --data-urlencode "csrf=$(csrf $W/g.html)"
ok "guest can open the Jigsaw library" "$(code -b $W/g $BASE/jigsaw.php)" 200
ok "guest cannot open a Jigsaw tournament" "$(code -b $W/g "$BASE/jigsaw.php?t=$E")" 403
GCS=$(curl -s -b $W/g $BASE/jigsaw.php | grep -o '"csrf":"[^"]*"' | head -1 | sed 's/.*:"\(.*\)"/\1/')
ok "guest cannot call the tournament API" "$(code -b $W/g -X POST $BASE/puzzles_api.php --data-urlencode "csrf=$GCS" -d do=start -d t=$E)" 403

echo "== lifecycle: soon / open / closing / settled, mystery card"
dbx "UPDATE puzzle_pics SET title='Zorbaloon Vista' WHERE id=$MAIZE"
S=$(mk 'Hidden Cup' advanced $MAIZE 3600 90000)
curl -s -b $W/p "$BASE/jigsaw.php?t=$S" > $W/s.html
ge "soon: mystery card shown" "$(grep -c 'Mystery picture' $W/s.html)" 1
ok "soon: the picture file and thumb are not printed anywhere" "$(grep -c 'maizehollow' $W/s.html)" 0
ok "soon: the picture's title is not printed" "$(grep -c 'Zorbaloon' $W/s.html)" 0
ok "soon: pz-data is empty" "$(php -r 'preg_match("#id=\"pz-data\">(.*?)</script>#s", file_get_contents($argv[1]), $m); echo $m[1];' $W/s.html)" '[]'
ok "soon: no start button; Old Wizard says it opens" "$(grep -c 'id="tstart"' $W/s.html)/$(grep -c 'Patience, young one' $W/s.html)" 0/1
ok "soon: the library's tournament list says mystery, not the picture" "$(curl -s -b $W/p $BASE/jigsaw.php | sed -n '/class="pztours"/,/<\/ul>/p' | grep -c 'Zorbaloon')/$(curl -s -b $W/p $BASE/jigsaw.php | sed -n '/class="pztours"/,/<\/ul>/p' | grep -c 'Mystery picture')" 0/1
ok "soon: API refuses to start (not started)" "$(api -d do=start -d t=$S | js error | grep -c 'hasn’t started')" 1
dbx "UPDATE puzzle_tournaments SET starts_at='$(utc -60)' WHERE id=$S"
curl -s -b $W/p "$BASE/jigsaw.php?t=$S" > $W/s.html
ok "open: picture shown, start button, 96 pieces" "$([ $(grep -c 'maizehollow-thumb.jpg' $W/s.html) -ge 1 ] && echo y)/$(grep -c 'id="tstart"' $W/s.html)/$([ $(grep -c '96 pieces' $W/s.html) -ge 1 ] && echo y)" y/1/y
dbx "UPDATE puzzle_tournaments SET ends_at='$(utc -300)' WHERE id=$S"
curl -s -b $W/p "$BASE/jigsaw.php?t=$S" > $W/s.html
ok "closing: no start button, 'Time's up' line, not settled" "$(grep -c 'id="tstart"' $W/s.html)/$(grep -c 'Time’s up for starting' $W/s.html)/$(dbv "SELECT status FROM puzzle_tournaments WHERE id=$S")" 0/1/live
ok "closing: API says closed" "$(api -d do=start -d t=$S | js error | grep -c 'closed')" 1
dbx "UPDATE puzzle_tournaments SET ends_at='$(utc -700)' WHERE id=$S"
curl -s -b $W/p "$BASE/jigsaw.php?t=$S" > $W/s.html
ok "past the grace: settled by a page view" "$(dbv "SELECT status FROM puzzle_tournaments WHERE id=$S")" settled
ok "settled page text" "$(grep -c 'sands have run out' $W/s.html)" 1
ok "settled page lists it in the library" "$(curl -s -b $W/p $BASE/jigsaw.php | grep -c "jigsaw.php?t=$S")" 1
DR=$(mk 'Draft One' easy $SUN 0 3600 draft)
ok "a draft is not found" "$(curl -s -b $W/p -o /dev/null -w '%{redirect_url}' "$BASE/jigsaw.php?t=$DR" | sed 's#.*/##')" jigsaw.php
dbx "DELETE FROM puzzle_tournaments WHERE id=$DR"; dbx "DELETE FROM login_attempts"

echo "== reserved picture: hidden, then released once ALL its tournaments are settled"
ok "Maplewold is reserved (the cup runs) and not in the library data" "$(dbv "SELECT reserved FROM puzzle_pics WHERE id=$MAP")/$(curl -s -b $W/p $BASE/jigsaw.php | grep -c 'maplewold-thumb')" 1/0
ok "...and free play refuses it" "$(api -d do=pstart -d pic=jig-maplewold -d tier=easy | js ok)" false
for tid in $E $A; do dbx "UPDATE puzzle_tournaments SET ends_at='$(utc -700)' WHERE id=$tid"; done
curl -s -b $W/p -o /dev/null "$BASE/jigsaw.php"
ok "two of three settled: still reserved" "$(dbv "SELECT reserved FROM puzzle_pics WHERE id=$MAP")" 1
dbx "UPDATE puzzle_tournaments SET ends_at='$(utc -700)' WHERE id=$X"
curl -s -b $W/p -o /dev/null "$BASE/jigsaw.php"
ok "all three settled: released into free play" "$(dbv "SELECT reserved FROM puzzle_pics WHERE id=$MAP")" 0
ok "...and now in the library" "$(curl -s -b $W/p $BASE/jigsaw.php | grep -c 'maplewold-thumb')" 1
# jigsaw_reserve_days
dbx "UPDATE puzzle_pics SET reserved=1 WHERE id=$SUN"
setg jigsaw_reserve_days 3
R1=$(mk 'Wait Cup' easy $SUN -7200 -700)
curl -s -b $W/p -o /dev/null "$BASE/jigsaw.php"
ok "reserve_days=3: settled, but the picture waits" "$(dbv "SELECT status FROM puzzle_tournaments WHERE id=$R1")/$(dbv "SELECT reserved FROM puzzle_pics WHERE id=$SUN")" settled/1
dbx "UPDATE puzzle_tournaments SET settled_at='$(utc -$((4*86400)))' WHERE id=$R1"
curl -s -b $W/p -o /dev/null "$BASE/jigsaw.php"
ok "...after 3 days it is released" "$(dbv "SELECT reserved FROM puzzle_pics WHERE id=$SUN")" 0
dbx "DELETE FROM settings WHERE name='jigsaw_reserve_days'"

echo "== settle: places, note text, badge with a tier pip"
setg puzzles_tournaments 1
SE=$(mk 'Settle Me' expert $SUN -7200 -700)
dbx "UPDATE puzzle_tournaments SET status='live', settled_at=NULL WHERE id=$SE"
for k in 1 2 3; do
  dbx "INSERT INTO users (username,email,password_hash,created_at,gnome_name) VALUES ('jigbot$k','jb$k@b.local','x','2026-01-01 00:00:00','Jig Bot $k')"
  done_run $SE $(dbv "SELECT id FROM users WHERE username='jigbot$k'") $((100000+k*10000))
done
done_run $SE $UID_ 400000
curl -s -b $W/p -o /dev/null "$BASE/jigsaw.php?t=$SE"
ok "settled with places 1,2,3,4" "$(dbv "SELECT group_concat(place) FROM (SELECT place FROM puzzle_attempts WHERE tournament_id=$SE AND place IS NOT NULL ORDER BY place)")" 1,2,3,4
U1=$(dbv "SELECT id FROM users WHERE username='jigbot1'")
ok "winner notified with the Jigsaw text and tier" "$(dbv "SELECT COUNT(*) FROM notices WHERE user_id=$U1 AND text LIKE '🧩 Jigsaw Settle Me (Expert): you placed #1 %'")" 1
ok "sprout notified #4" "$(dbv "SELECT COUNT(*) FROM notices WHERE user_id=$UID_ AND text LIKE '🧩 Jigsaw Settle Me (Expert): you placed #4 %'")" 1
curl -s -b $W/p "$BASE/profile.php?id=$U1&tab=awards" > $W/pr.html
ok "profile: gold trophy, Expert pip, Jigsaw label" "$(grep -c 'cast/trophy-gold.png' $W/pr.html)/$(grep -c 'class="pzpip" title="Expert">🌳' $W/pr.html)/$(grep -c 'Jigsaw Settle Me (Expert)' $W/pr.html)" 1/1/1
ok "results page shows the gold trophy to the winner's board" "$(curl -s -b $W/p "$BASE/jigsaw.php?t=$SE" | grep -c 'cast/trophy-gold.png')" 1
dbx "INSERT INTO puzzle_attempts (tournament_id,user_id,token,seed,started_at,start_ms,finished_at,ms,drops,status,place) VALUES ($GT,$U1,'$(printf '%032d' 7)',1,'$(utc -600)',0,'$(utc -500)',99000,300,'done',2)"
curl -s -b $W/p "$BASE/profile.php?id=$U1&tab=awards" > $W/pr.html
ok "a GIFsaw badge has no pip and no Jigsaw label (one pip in all)" "$(grep -c 'Sunflower Gate' $W/pr.html)/$(grep -o 'class="pzpip"' $W/pr.html | wc -l)/$(grep -c 'Jigsaw Sunflower' $W/pr.html)" 1/1/0

echo "== admin: settle now, cancel, void, duplicate, CSV"
SN=$(mk 'Settle Now' easy $SUN -7200 7200)
for k in 1 2; do done_run $SN $(dbv "SELECT id FROM users WHERE username='jigbot$k'") $((50000+k*1000)); done
ok "settle now: only a live tournament" "$(adm -d do=tour_settle -d id=$(mk 'Draft Two' easy $SUN 0 3600 draft) >/dev/null; dbv "SELECT status FROM puzzle_tournaments WHERE title='Draft Two'")" draft
adm -d do=tour_settle -d id=$SN >/dev/null
ok "settle now: settled with places 1,2" "$(dbv "SELECT status FROM puzzle_tournaments WHERE id=$SN")/$(dbv "SELECT group_concat(place) FROM (SELECT place FROM puzzle_attempts WHERE tournament_id=$SN AND place IS NOT NULL ORDER BY place)")" settled/1,2
ok "settle now: admin_log" "$(dbv "SELECT COUNT(*) FROM admin_log WHERE action='jigsaw_settle'")" 1
CN=$(mk 'Cancel Me' advanced $MAIZE -7200 7200)
dbx "UPDATE puzzle_pics SET reserved=1 WHERE id=$MAIZE"
for k in 1 2; do done_run $CN $(dbv "SELECT id FROM users WHERE username='jigbot$k'") $((60000+k*1000)); done
NB=$(dbv "SELECT COUNT(*) FROM notices")
adm -d do=tour_cancel -d id=$CN >/dev/null
ok "cancel: settled, all runs void, no places" "$(dbv "SELECT status FROM puzzle_tournaments WHERE id=$CN")/$(dbv "SELECT COUNT(*) FROM puzzle_attempts WHERE tournament_id=$CN AND status<>'void'")/$(dbv "SELECT COUNT(*) FROM puzzle_attempts WHERE tournament_id=$CN AND place IS NOT NULL")" settled/0/0
ok "cancel: nobody was notified" "$(dbv "SELECT COUNT(*) FROM notices")" "$NB"
curl -s -b $W/p -o /dev/null "$BASE/jigsaw.php?t=$CN"
ok "cancel: a later page view does not hand out places" "$(dbv "SELECT COUNT(*) FROM puzzle_attempts WHERE tournament_id=$CN AND place IS NOT NULL")" 0
ok "cancel: the board is empty (all void)" "$(curl -s -b $W/p "$BASE/jigsaw.php?t=$CN" | grep -c 'No finished times yet')" 1
ok "cancel: the reserved picture is released" "$(dbv "SELECT reserved FROM puzzle_pics WHERE id=$MAIZE")" 0
ok "cancel: admin_log" "$(dbv "SELECT COUNT(*) FROM admin_log WHERE action='jigsaw_cancel'")" 1
ok "cancel again is refused" "$(adm -d do=tour_cancel -d id=$CN >/dev/null; dbv "SELECT COUNT(*) FROM admin_log WHERE action='jigsaw_cancel'")" 1
VT=$(mk 'Void Cup' easy $SUN -3600 3600)
done_run $VT $UID_ 70000
AID=$(dbv "SELECT id FROM puzzle_attempts WHERE tournament_id=$VT")
adm -d do=void -d attempt=$AID -d reason= >/dev/null
ok "void needs a reason" "$(dbv "SELECT status FROM puzzle_attempts WHERE id=$AID")" done
curl -s -b $W/a -o /dev/null -X POST $BASE/admin/puzzles.php --data-urlencode "csrf=$T" -d do=void -d attempt=$AID -d 'reason=wrong page'
ok "the GIFsaw admin page can't void a Jigsaw run" "$(dbv "SELECT status FROM puzzle_attempts WHERE id=$AID")" done
curl -s -b $W/a "$BASE/admin/jigsaw.php?tab=tournaments&id=$VT" > $W/v.html
ok "detail: leaderboard, runs, Void form, Settle/Cancel/Duplicate, CSV link" "$(grep -c '<h2>Leaderboard' $W/v.html)$(grep -c 'value="void"' $W/v.html)$(grep -c 'value="tour_settle"' $W/v.html)$(grep -c 'value="tour_cancel"' $W/v.html)$(grep -c 'value="tour_dup"' $W/v.html)$(grep -c 'csv=1' $W/v.html)" 111111
adm -d do=void -d attempt=$AID -d 'reason=test void' >/dev/null
ok "admin voids with a reason" "$(dbv "SELECT status||':'||reason FROM puzzle_attempts WHERE id=$AID")" "void:admin: test void"
ok "admin_log has the void" "$(dbv "SELECT COUNT(*) FROM admin_log WHERE action='puzzle_void'")" 1
ND=$(dbv "SELECT COUNT(*) FROM puzzle_tournaments")
adm -d do=tour_dup -d id=$VT >/dev/null
ok "duplicate: a draft copy, same picture and tier" "$(dbv "SELECT status||tier||pieces FROM puzzle_tournaments WHERE title='Void Cup (copy)'")/$(dbv "SELECT COUNT(*) FROM puzzle_tournaments")" "drafteasy24/$((ND+1))"
CSV=$(curl -s -b $W/a "$BASE/admin/jigsaw.php?tab=tournaments&id=$SE&csv=1")
ok "CSV: header and 4 rows, winner first" "$(echo "$CSV" | wc -l)/$(echo "$CSV" | sed -n 2p | cut -d, -f1,2)" '5/1,"Jig Bot 1"'
ok "CSV: non-admin refused" "$(code -b $W/p "$BASE/admin/jigsaw.php?tab=tournaments&id=$SE&csv=1")" 403
ok "filters: tier=expert lists Settle Me, not Cancel Me" "$(curl -s -b $W/a "$BASE/admin/jigsaw.php?tab=tournaments&tier=expert" | grep -c 'Settle Me')/$(curl -s -b $W/a "$BASE/admin/jigsaw.php?tab=tournaments&tier=expert" | grep -c 'Cancel Me')" 1/0
ok "editing: a tier can't change once players have had goes" "$(adm -d do=tour_save -d id=$VT --data-urlencode title='Void Cup' -d pic_id=$SUN -d tier=expert -d "starts_at=$(hol -3600)" -d "ends_at=$(hol 3600)" -d status=live >/dev/null; dbv "SELECT tier FROM puzzle_tournaments WHERE id=$VT")" easy
ok "a settled tournament can't be edited" "$(adm -d do=tour_save -d id=$SE --data-urlencode title=Changed -d pic_id=$SUN -d tier=expert -d "starts_at=$(hol -3600)" -d "ends_at=$(hol 3600)" -d status=live >/dev/null; dbv "SELECT title FROM puzzle_tournaments WHERE id=$SE")" "Settle Me"

echo "== admin Library tab"
curl -s -b $W/a "$BASE/admin/jigsaw.php" > $W/lib.html
ge "library: gallery rows with a reserved box each" "$(grep -c 'name="reserved"' $W/lib.html)" 3
NPL=$(dbv "SELECT COUNT(*) FROM puzzle_pics WHERE source='place'")
ok "library: Places listed in their own group (read-only rows)" "$(grep -c 'value="place_active"' $W/lib.html)" "$NPL"
ok "library: Places rows have no title input" "$(sed -n '/id="places"/,$p' $W/lib.html | grep -c 'name="title"')" 0
curl -s -b $W/a -o /dev/null -X POST $BASE/admin/jigsaw.php --data-urlencode "csrf=$T" -d do=pic_save -d id=$MAIZE --data-urlencode 'title=Maizehollow Vista' -d cat=Seasons -d sort=5 -d active=1 -d reserved=1
ok "pic_save: title, category, order, active, reserved" "$(dbv "SELECT title||'|'||cat||'|'||sort||'|'||active||'|'||reserved FROM puzzle_pics WHERE id=$MAIZE")" "Maizehollow Vista|Seasons|5|1|1"
curl -s -b $W/a -o /dev/null -X POST $BASE/admin/jigsaw.php --data-urlencode "csrf=$T" -d do=pic_save -d id=$MAIZE --data-urlencode 'title=X' -d cat=Bogus
ok "pic_save: an unknown category is refused" "$(dbv "SELECT title FROM puzzle_pics WHERE id=$MAIZE")" "Maizehollow Vista"
curl -s -b $W/a -o /dev/null -X POST $BASE/admin/jigsaw.php --data-urlencode "csrf=$T" -d do=pic_save -d id=$PLACE --data-urlencode 'title=Hacked'
ok "pic_save: a Places picture can't be edited" "$(dbv "SELECT title='Hacked' FROM puzzle_pics WHERE id=$PLACE")" 0
curl -s -b $W/a -o /dev/null -X POST $BASE/admin/jigsaw.php --data-urlencode "csrf=$T" -d do=place_active -d id=$PLACE
ok "place_active: off" "$(dbv "SELECT active FROM puzzle_pics WHERE id=$PLACE")" 0
curl -s -b $W/a -o /dev/null -X POST $BASE/admin/jigsaw.php --data-urlencode "csrf=$T" -d do=place_active -d id=$PLACE -d active=1
ok "place_active: on again" "$(dbv "SELECT active FROM puzzle_pics WHERE id=$PLACE")" 1
dbx "UPDATE puzzle_pics SET reserved=0 WHERE id=$MAIZE"

echo "== admin Upload tab"
dbx "DELETE FROM login_attempts"
php -r '
$d = $argv[1];
$jpg = function ($w, $h, $file, $q = 80, $noise = false) { $i = imagecreatetruecolor($w, $h);
  for ($y = 0; $y < $h; $y += 40) for ($x = 0; $x < $w; $x += 40) { $c = imagecolorallocate($i, ($x * 255 / $w) | 0, ($y * 255 / $h) | 0, (($x + $y) % 200) + 20); imagefilledrectangle($i, $x, $y, $x + 39, $y + 39, $c); }
  if ($noise) for ($k = 0; $k < 600000; $k++) imagesetpixel($i, mt_rand(0, $w - 1), mt_rand(0, $h - 1), mt_rand(0, 0xFFFFFF));
  imagejpeg($i, $file, $q); };
$jpg(1800, 1200, "$d/good.jpg");
$jpg(2400, 1600, "$d/good2.jpg");
$jpg(1920, 1080, "$d/wide.jpg");
$jpg(1800, 1350, "$d/four3.jpg");
$jpg(600, 400, "$d/tiny.jpg");
$jpg(3300, 2200, "$d/huge.jpg");
$jpg(3000, 2000, "$d/heavy.jpg", 100, true);
$jpg(1800, 1200, "$d/exif.jpg");
$jpg(1500, 1000, "$d/min.jpg", 20);
$b = file_get_contents("$d/exif.jpg");
$app1 = "Exif\0\0" . str_repeat("SECRETGPS-51.5N-0.1W-", 20);
file_put_contents("$d/exif.jpg", substr($b, 0, 2) . "\xFF\xE1" . pack("n", strlen($app1) + 2) . $app1 . substr($b, 2));
$p = imagecreatetruecolor(1800, 1200); imagefilledrectangle($p, 0, 0, 900, 600, 0x3366cc); imagepng($p, "$d/good.png");
file_put_contents("$d/not.jpg", "<?php echo 1;");
' $W
ok "test EXIF marker is really in the source file" "$(grep -c 'SECRETGPS' $W/exif.jpg)" 1
curl -s -b $W/a "$BASE/admin/jigsaw.php?tab=upload" > $W/up.html
ok "upload tab: multi-file field, category, reserve box" "$(grep -c 'name="pics\[\]"[^>]*multiple' $W/up.html)/$(grep -c 'name="reserved"' $W/up.html)/$(grep -c 'name="cat"' $W/up.html)" 1/1/1
up() { curl -s -b $W/a -o /dev/null -w '%{http_code}' -X POST $BASE/admin/jigsaw.php -F "csrf=$T" -F do=upload "$@"; }
flash() { curl -s -b $W/a "$BASE/admin/jigsaw.php?tab=upload" | grep -o 'class="flash[^>]*>[^<]*' | sed 's/class="flash [a-z]*">//'; }
N0=$(dbv "SELECT COUNT(*) FROM puzzle_pics")
ok "upload: player refused" "$(curl -s -b $W/p -o /dev/null -w '%{http_code}' -X POST $BASE/admin/jigsaw.php -F csrf=x -F do=upload -F "pics[]=@$W/good.jpg")" 403
ok "upload: no CSRF refused" "$(curl -s -b $W/a -o /dev/null -w '%{http_code}' -X POST $BASE/admin/jigsaw.php -F do=upload -F "pics[]=@$W/good.jpg")" 400
up -F "pics[]=@$W/wide.jpg" >/dev/null;  ok "16:9 refused, with its numbers" "$(flash | grep -c '3:2.*1920 × 1080')" 1
up -F "pics[]=@$W/four3.jpg" >/dev/null; ok "4:3 refused" "$(flash | grep -c '1800 × 1350')" 1
up -F "pics[]=@$W/tiny.jpg" >/dev/null;  ok "tiny refused, with its numbers" "$(flash | grep -c '600 × 400.*1500 × 1000')" 1
up -F "pics[]=@$W/huge.jpg" >/dev/null;  ok "too big (3300 × 2200) refused" "$(flash | grep -c '3300 × 2200.*3000 × 2000')" 1
up -F "pics[]=@$W/heavy.jpg" >/dev/null; ok "over 3 MB refused" "$(flash | grep -c '3 MB')" 1
up -F "pics[]=@$W/not.jpg;type=image/jpeg" >/dev/null; ok "a non-picture refused" "$(flash | grep -c 'isn’t a JPEG')" 1
ok "refused uploads saved nothing" "$(dbv "SELECT COUNT(*) FROM puzzle_pics")" "$N0"
ok "good 3:2 upload redirects" "$(up -F "pics[]=@$W/good.jpg" -F 'title=Test Meadow' -F cat=Seasons -F reserved=1)" 302
ok "one new picture" "$(dbv "SELECT COUNT(*) FROM puzzle_pics")" "$((N0+1))"
ok "row: still / upload / off / reserved / category / 1800x1200 / jig- slug" "$(dbv "SELECT kind||source||active||reserved||cat||w||'x'||h||slug FROM puzzle_pics WHERE title='Test Meadow'")" "stillupload01Seasons1800x1200jig-test-meadow"
F=$(dbv "SELECT file FROM puzzle_pics WHERE title='Test Meadow'"); TH=$(dbv "SELECT thumb FROM puzzle_pics WHERE title='Test Meadow'")
ok "files are uploads/jigsaw/{hex}.jpg and -thumb.jpg" "$(echo $F | grep -cE '^[a-f0-9]{24}\.jpg$')$(echo $TH | grep -cE '^[a-f0-9]{24}-thumb\.jpg$')" 11
ok "saved picture is a 1800 x 1200 JPEG" "$(php -r '$i=getimagesize($argv[1]); echo $i[0]."x".$i[1].$i["mime"];' $GAME/uploads/jigsaw/$F)" "1800x1200image/jpeg"
ok "thumb is a 450 x 300 JPEG" "$(php -r '$i=getimagesize($argv[1]); echo $i[0]."x".$i[1].$i["mime"];' $GAME/uploads/jigsaw/$TH)" "450x300image/jpeg"
ok "both are served" "$(code $BASE/uploads/jigsaw/$F)$(code $BASE/uploads/jigsaw/$TH)" 200200
setg jigsaw_reserve_days 2
ok "off by default: not in the player library" "$(curl -s -b $W/p $BASE/jigsaw.php | grep -c "$TH")" 0
ok "a reserved picture with no tournament yet stays reserved (even with a sweep)" "$(dbv "SELECT reserved FROM puzzle_pics WHERE id=$(dbv "SELECT id FROM puzzle_pics WHERE title='Test Meadow'")")" 1
dbx "DELETE FROM settings WHERE name='jigsaw_reserve_days'"
ok "admin_log has the upload" "$(dbv "SELECT COUNT(*) FROM admin_log WHERE action='jigsaw_upload'")" 1
# 2 files at once, one with EXIF; PNG accepted; a 2400 x 1600 is scaled down
N1=$(dbv "SELECT COUNT(*) FROM puzzle_pics")
up -F "pics[]=@$W/exif.jpg" -F "pics[]=@$W/good2.jpg" -F "pics[]=@$W/good.png" -F 'title=Ignored When Several' >/dev/null
ok "three files in one go made three pictures" "$(dbv "SELECT COUNT(*) FROM puzzle_pics")" "$((N1+3))"
ok "titles from the file names when several" "$(dbv "SELECT group_concat(title) FROM (SELECT title FROM puzzle_pics WHERE source='upload' ORDER BY id DESC LIMIT 3)" | tr ',' '\n' | sort | tr '\n' ',')" "Exif,Good,Good2,"
EXF=$(dbv "SELECT file FROM puzzle_pics WHERE title='Exif'")
ok "EXIF stripped (no marker, no APP1 segment)" "$(grep -c 'SECRETGPS' $GAME/uploads/jigsaw/$EXF)/$(php -r 'echo strpos(file_get_contents($argv[1]), "Exif") === false ? "none" : "found";' $GAME/uploads/jigsaw/$EXF)" "0/none"
ok "2400 x 1600 re-encoded to 1800 x 1200" "$(php -r '$i=getimagesize($argv[1]); echo $i[0]."x".$i[1];' $GAME/uploads/jigsaw/$(dbv "SELECT file FROM puzzle_pics WHERE title='Good2'"))" 1800x1200
ok "slugs are unique (two 'good' names get -2)" "$(dbv "SELECT COUNT(DISTINCT slug)=COUNT(*) FROM puzzle_pics")" 1
ok "26 files refused (max 25)" "$(args=(); for k in $(seq 1 26); do args+=(-F "pics[]=@$W/min.jpg"); done; up "${args[@]}" >/dev/null; flash | grep -c 'Up to 25')" 1
ok "the Library shows the new pictures with their thumbs" "$(curl -s -b $W/a "$BASE/admin/jigsaw.php" | grep -c "uploads/jigsaw/$TH")" 1
# the uploaded picture works as a tournament picture
UPID=$(dbv "SELECT id FROM puzzle_pics WHERE title='Test Meadow'")
adm -d do=tour_save -d id=0 $(mkform MeadowSprint $UPID expert -3600 3600) >/dev/null
ok "an uploaded picture can host a tournament (Expert, 216)" "$(dbv "SELECT tier||pieces FROM puzzle_tournaments WHERE title='MeadowSprint'")" expert216

echo "== settings card, php log"
ge "settings tab lists the jigsaw settings" "$(curl -s -b $W/a "$BASE/admin/jigsaw.php?tab=settings" | grep -c 'jigsaw_reserve_days')" 1
ge "jigsaw_reserve_days is in Admin > Settings" "$(curl -s -b $W/a "$BASE/admin/settings.php" | grep -c 'jigsaw_reserve_days')" 1
echo "== php log"; grep -iE 'fatal|warning|notice|deprecated' /tmp/jigt-php.log || echo "(none)"
