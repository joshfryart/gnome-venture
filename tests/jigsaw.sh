#!/usr/bin/env bash
# v2.0.87: Jigsaw (jigsaw.php): gated by puzzles_open + jigsaw_open (admins always), three fixed tiers (24 / 96 / 216, never a free count),
# stills kept apart from GIFsaw, free play timed on the server (pstart / pfinish: one use, too fast rejected, pays nothing), columns added to an old database.
GAME=$1; PORT=$2; ROUTER=$3; BASE=http://127.0.0.1:$PORT
php -d session.save_path=/tmp -S 127.0.0.1:$PORT -t $GAME $ROUTER >/tmp/jig-php.log 2>&1 & PID=$!; sleep 1
W=$(mktemp -d); trap "kill $PID 2>/dev/null; rm -rf $W" EXIT
csrf() { grep -o 'name="csrf" value="[^"]*"' "$1" | head -1 | sed 's/.*value="\([^"]*\)".*/\1/'; }
dbv() { php -r '$p=new PDO("sqlite:'$GAME'/data/game.sqlite"); echo $p->query($argv[1])->fetchColumn();' "$1"; }
dbx() { php -r '$p=new PDO("sqlite:'$GAME'/data/game.sqlite"); $p->exec($argv[1]);' "$1"; }
login() { rm -f $1; curl -s -c $1 -b $1 $BASE/login.php > $W/l.html; curl -s -c $1 -b $1 -X POST $BASE/login.php --data-urlencode "csrf=$(csrf $W/l.html)" -d username=$2 --data-urlencode "password=$3" -o /dev/null; }
ok() { if [ "$2" = "$3" ]; then echo "ok   $1"; else echo "FAIL $1 (got '$2', want '$3')"; fi; }
js() { php -r '$j=json_decode(stream_get_contents(STDIN), true); echo is_array($j) ? var_export($j[$argv[1]] ?? null, true) : "nojson";' "$1"; }
setg() { dbx "INSERT OR REPLACE INTO settings (name,value) VALUES ('$1','$2')"; }
api() { curl -s -b $W/p -X POST $BASE/puzzles_api.php --data-urlencode "csrf=$CS" "$@"; }
login $W/a admin TestPassword123
login $W/p sprout 'TestPass123!'
dbx "DELETE FROM settings WHERE name IN ('puzzles_open','jigsaw_open','jigsaw_tournaments')"
ok "all off: player is sent away" "$(curl -s -b $W/p -o /dev/null -w '%{http_code}' $BASE/jigsaw.php)" 302
ok "all off: admin is not bounced by the gate (test admin is not onboarded, so welcome.php)" "$(curl -s -b $W/a -o /dev/null -w '%{redirect_url}' $BASE/jigsaw.php | sed 's#.*/##')" welcome.php
setg puzzles_open 1
ok "Puzzles on, Jigsaw off: player still sent away" "$(curl -s -b $W/p -o /dev/null -w '%{http_code}' $BASE/jigsaw.php)" 302
curl -s -b $W/p $BASE/puzzles.php > $W/h.html; ok "hub: no Jigsaw card while off" "$(grep -c 'jigsaw.php' $W/h.html)" 0
setg jigsaw_open 1
ok "Jigsaw on: player gets the page" "$(curl -s -b $W/p -o /dev/null -w '%{http_code}' $BASE/jigsaw.php)" 200
curl -s -b $W/p $BASE/puzzles.php > $W/h.html; ok "hub: Jigsaw card shows" "$(grep -c 'href="[^"]*jigsaw.php"' $W/h.html)" 1
curl -s -b $W/p $BASE/jigsaw.php > $W/j.html
ok "page: puzzles.js wired" "$(grep -c 'assets/puzzles.js' $W/j.html)" 1
ok "page: 3 built-in pictures" "$(php -r 'preg_match("#id=\"pz-data\">(.*?)</script>#s", file_get_contents($argv[1]), $m); echo count(json_decode($m[1], true));' $W/j.html)" 3
ok "page: three fixed tiers 24/96/216" "$(php -r 'preg_match("#id=\"pz-mode\">(.*?)</script>#s", file_get_contents($argv[1]), $m); echo implode(",", array_column(json_decode($m[1], true)["tiers"], "n"));' $W/j.html)" 24,96,216
ok "page: tier picker has exactly 3 options, no free counts" "$(grep -o '<option value="[0-9]*"' $W/j.html | tr -d '\n')" '<option value="24"<option value="96"<option value="216"'
ok "page: Motion button hidden" "$(grep -c 'id="anim"[^>]*hidden' $W/j.html)" 1
ok "page: next-tier button on the win card" "$(grep -c 'id="nexttier"' $W/j.html)" 1
curl -s -b $W/p $BASE/gifsaw.php > $W/g.html
ok "GIFsaw never lists the stills" "$(php -r 'preg_match("#id=\"pz-data\">(.*?)</script>#s", file_get_contents($argv[1]), $m); echo substr_count($m[1], "img/jigsaw");' $W/g.html)" 0
ok "GIFsaw still has its own pictures" "$(php -r 'preg_match("#id=\"pz-data\">(.*?)</script>#s", file_get_contents($argv[1]), $m); echo count(json_decode($m[1], true));' $W/g.html)" 7
ok "DB: stills tagged" "$(dbv "SELECT COUNT(*) FROM puzzle_pics WHERE kind='still' AND source='builtin'")/$(dbv "SELECT COUNT(*) FROM puzzle_pics WHERE kind='gif'")" 3/7
ok "every built-in picture and thumb exists" "$(for f in maplewold maizehollow sunsprinkle; do [ -s $GAME/assets/img/jigsaw/$f.jpg ] && [ -s $GAME/assets/img/jigsaw/$f-thumb.jpg ] && echo y; done | wc -l)" 3
ok "pictures are 3:2, 1800 x 1200" "$(php -r 'foreach (glob($argv[1]."/assets/img/jigsaw/*[a-z].jpg") as $f) { [$w,$h]=getimagesize($f); if (strpos($f,"thumb")===false) echo ($w==1800&&$h==1200)?"y":"n"; }' $GAME)" yyy
# free play
CS=$(grep -o '"csrf":"[^"]*"' $W/j.html | head -1 | sed 's/.*:"\(.*\)"/\1/')
ok "pstart: bad tier refused" "$(api -d do=pstart -d pic=jig-maplewold -d tier=sixty | js ok)" false
ok "pstart: a free piece count is not a tier" "$(api -d do=pstart -d pic=jig-maplewold -d tier=54 | js ok)" false
ok "pstart: unknown picture refused" "$(api -d do=pstart -d pic=nope -d tier=easy | js ok)" false
ok "pstart: a GIFsaw picture is not a jigsaw" "$(api -d do=pstart -d pic=sunflower -d tier=easy | js ok)" false
R=$(api -d do=pstart -d pic=jig-maplewold -d tier=easy); TK=$(echo "$R" | php -r '$j=json_decode(stream_get_contents(STDIN),true); echo $j["token"] ?? "";')
ok "pstart: easy go gives a token" "${#TK}" 32
ok "run row: 24 pieces, practice" "$(dbv "SELECT size||mode||game FROM puzzle_runs WHERE token='$TK'")" 24practicejigsaw
ok "pfinish: too fast is rejected" "$(api -d do=pfinish -d token=$TK -d drops=23 | js rejected)" true
ok "pfinish: a handed-in token is dead" "$(api -d do=pfinish -d token=$TK -d drops=23 | js ok)" false
TK=$(api -d do=pstart -d pic=jig-maplewold -d tier=easy | php -r '$j=json_decode(stream_get_contents(STDIN),true); echo $j["token"] ?? "";')
sleep 10
ok "pfinish: too few drops is rejected" "$(api -d do=pfinish -d token=$TK -d drops=3 | js rejected)" true
TK=$(api -d do=pstart -d pic=jig-maplewold -d tier=easy | php -r '$j=json_decode(stream_get_contents(STDIN),true); echo $j["token"] ?? "";')
sleep 10
R=$(api -d do=pfinish -d token=$TK -d drops=23)
ok "pfinish: a real go counts" "$(echo "$R" | js ok)" true
ok "pfinish: it is a new best on easy" "$(echo "$R" | js new)/$(echo "$R" | js tier)" "true/'easy'"
ok "best is stored per picture and tier" "$(dbv "SELECT COUNT(*) FROM puzzle_runs WHERE game='jigsaw' AND status='done' AND size=24")" 1
curl -s -b $W/p $BASE/jigsaw.php | grep -o '"bests":{[^}]*}[^}]*}' | head -1 > $W/b.txt
ok "library shows the best next run" "$(grep -c 'jig-maplewold' $W/b.txt)" 1
ok "free play pays nothing (no wins row)" "$(dbv "SELECT COUNT(*) FROM puzzle_wins WHERE game='jigsaw'")" 0
setg jigsaw_open 0
ok "Jigsaw off: pstart refused" "$(api -d do=pstart -d pic=jig-maplewold -d tier=easy | js ok)" false
setg jigsaw_open 1
ok "a reserved picture is hidden from the library and from play" "$(dbx "UPDATE puzzle_pics SET reserved=1 WHERE slug='jig-maizehollow'"; curl -s -b $W/p $BASE/jigsaw.php | grep -c 'maizehollow-thumb')/$(api -d do=pstart -d pic=jig-maizehollow -d tier=easy | js ok)" 0/false
dbx "UPDATE puzzle_pics SET reserved=0 WHERE slug='jig-maizehollow'"
# Places: a picture for every unique location with scene art, unlocked on the first visit
NP=$(dbv "SELECT COUNT(*) FROM puzzle_pics WHERE source='place'")
ok "places: seeded from the unique locations (more than 40)" "$([ "$NP" -gt 40 ] && echo y || echo n)" y
ok "places: every seeded picture has its scene file" "$(php -r '$p=new PDO("sqlite:'$GAME'/data/game.sqlite"); $bad=0; foreach($p->query("SELECT file FROM puzzle_pics WHERE source=\"place\"") as $r) if(!is_file("'$GAME'/assets/img/wonders/".$r[0])) $bad++; echo $bad;')" 0
ok "places: none unlocked yet, library still 3" "$(curl -s -b $W/p $BASE/jigsaw.php | php -r 'preg_match("#id=\"pz-data\">(.*?)</script>#s", stream_get_contents(STDIN), $m); echo count(json_decode($m[1], true));')" 3
curl -s -b $W/p $BASE/jigsaw.php | grep -o 'Places: <b>[0-9]*</b> of [0-9]*' > $W/pl.txt
ok "places: library line says 0 found" "$(sed 's/<[^>]*>//g' $W/pl.txt)" "Places: 0 of $NP"
UID_=$(dbv "SELECT id FROM users WHERE username='sprout'")
# the first haven whose panel is not locked behind a story chapter (the Sugar Shack is, early on)
HV=; for cand in $(dbv "SELECT group_concat(l.id) FROM (SELECT l.id FROM landmarks m JOIN locations l ON l.id=m.location_id WHERE m.kind='haven' ORDER BY m.id LIMIT 12) l" | tr ',' ' '); do
  dbx "UPDATE users SET location_id=$cand WHERE id=$UID_"
  if curl -s -b $W/p $BASE/town.php | grep -q 'class="box lmpanel'; then HV=$cand; break; fi
  dbx "DELETE FROM jigsaw_unlocks WHERE user_id=$UID_"
done
ok "places: found a haven that is open to the player" "$([ -n "$HV" ] && echo y || echo n)" y
dbx "DELETE FROM jigsaw_unlocks WHERE user_id=$UID_; DELETE FROM notices WHERE user_id=$UID_"
HVN=$(dbv "SELECT name FROM landmarks WHERE kind='haven' AND location_id=$HV")
PIC=$(dbv "SELECT slug FROM puzzle_pics WHERE source='place' AND title=\"$HVN\"")
ok "places: a locked place cannot be played" "$(api -d do=pstart -d pic=$PIC -d tier=easy | js ok)" false
curl -s -b $W/p $BASE/town.php > $W/w.html
ok "places: first visit unlocks one picture" "$(dbv "SELECT COUNT(*) FROM jigsaw_unlocks WHERE user_id=$UID_")" 1
ok "places: the place panel says so" "$(grep -c 'New jigsaw!' $W/w.html)" 1
ok "places: a notification was sent" "$(dbv "SELECT COUNT(*) FROM notices WHERE user_id=$UID_ AND text LIKE '%New jigsaw in your puzzle room%'")" 1
curl -s -b $W/p $BASE/town.php | grep -c 'New jigsaw!' > $W/w2.txt
ok "places: a second visit is quiet" "$(cat $W/w2.txt)/$(dbv "SELECT COUNT(*) FROM jigsaw_unlocks WHERE user_id=$UID_")" 0/1
curl -s -b $W/p $BASE/jigsaw.php > $W/j2.html
ok "places: library now has 4 pictures" "$(php -r 'preg_match("#id=\"pz-data\">(.*?)</script>#s", file_get_contents($argv[1]), $m); echo count(json_decode($m[1], true));' $W/j2.html)" 4
ok "places: the picture is cropped 3:2 and pixel-drawn" "$(php -r 'preg_match("#id=\"pz-data\">(.*?)</script>#s", file_get_contents($argv[1]), $m); $r=array_values(array_filter(json_decode($m[1], true), fn($x)=>strpos($x["id"],"pl-")===0))[0]; echo $r["crop"].$r["px"].(strpos($r["gif"],"img/wonders/")!==false?"w":"x");' $W/j2.html)" 11w
ok "places: library line says 1 found" "$(sed 's/<[^>]*>//g' <(grep -o 'Places: <b>[0-9]*</b> of [0-9]*' $W/j2.html))" "Places: 1 of $NP"
ok "places: an unlocked place can be played" "$(api -d do=pstart -d pic=$PIC -d tier=advanced | js ok)" true
# earlier visits (cleared before 2.0.87) are unlocked the first time Jigsaw opens
LM2=$(dbv "SELECT id FROM landmarks WHERE kind IN ('wonder','delve','lair') ORDER BY id LIMIT 1")
dbx "INSERT INTO landmark_clears (user_id, landmark_id, clears, first_at, last_at) VALUES ($UID_, $LM2, 1, datetime('now'), datetime('now'))"
curl -s -b $W/p -o /dev/null $BASE/jigsaw.php
ok "places: a place you cleared before is unlocked" "$(dbv "SELECT COUNT(*) FROM jigsaw_unlocks WHERE user_id=$UID_")" 2
# old database: the new columns are added by the first request
dbx "ALTER TABLE puzzle_runs DROP COLUMN pic_id"; dbx "ALTER TABLE puzzle_pics DROP COLUMN reserved"
curl -s -b $W/p -o /dev/null $BASE/gifsaw.php
ok "columns come back on an old database" "$(dbv "SELECT COUNT(*) FROM pragma_table_info('puzzle_pics') WHERE name='reserved'")$(dbv "SELECT COUNT(*) FROM pragma_table_info('puzzle_runs') WHERE name='pic_id'")" 11
# real browser: tier buttons open exactly 24 / 96 / 216 pieces, desktop and phone
if node -e "require('playwright')" 2>/dev/null; then
  mkdir -p ${SHOTS:-/tmp/jig-shots}
  OUT=$(node "$(dirname "$0")/jigsaw_check.js" $BASE "${SHOTS:-/tmp/jig-shots}" 2>&1); echo "$OUT" | sed 's/^/  /'
  ok "browser pass" "$(echo "$OUT" | grep -c '^FAIL')" 0
else echo "skip browser pass (no playwright)"; fi
