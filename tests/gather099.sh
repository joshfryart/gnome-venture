#!/bin/bash
# v0.9.9 part B: gathering mini-games (flow of the original suite; updated for the 1.5.0 rework: lure/trace/chop/glint/flit/drip, see also gather150.sh). Run on a fresh SQLite install that walk.sh made (sprout): gather099.sh GAME PORT ROUTER
# Takes about 90 seconds: rounds are timed, so the "perfect" plays wait for the clock (the server rejects taps from the future).
GAME=$1; PORT=$2; ROUTER=$3; BASE=http://127.0.0.1:$PORT
php -d session.save_path=/tmp -S 127.0.0.1:$PORT -t $GAME $ROUTER >/tmp/g099-php.log 2>&1 & PID=$!; sleep 1
T=$(mktemp -d /tmp/g099.XXXXXX); trap 'kill $PID 2>/dev/null; [ -d "${T:?}" ] && rm -rf "${T:?}"' EXIT
csrf() { grep -o 'name="csrf" value="[^"]*"' "$1" | head -1 | sed 's/.*value="\([^"]*\)".*/\1/'; }
db() { php -r '$p=new PDO("sqlite:'$GAME'/data/game.sqlite"); foreach($p->query($argv[1])->fetchAll(PDO::FETCH_NUM) as $r) echo implode(" | ",$r),"\n";' "$1"; }
dbx() { php -r '$p=new PDO("sqlite:'$GAME'/data/game.sqlite"); $p->exec($argv[1]);' "$1"; }
chk() { if [ "$2" = "$3" ]; then echo "ok   $1 = $2"; else echo "FAIL $1: got '$2' want '$3'"; fi; }
C=$T/ck; curl -s -c $C -b $C $BASE/login.php > $T/l.html; curl -s -c $C -b $C -X POST $BASE/login.php --data-urlencode "csrf=$(csrf $T/l.html)" -d username=sprout -d 'password=TestPass123!' -o /dev/null
SID=$(db "SELECT id FROM users WHERE username='sprout'")
for s in foraging-knife rock-pick fine-mesh-net tide-bucket hatchet willow-fishing-rod; do dbx "INSERT OR IGNORE INTO user_items (user_id,item_id,qty) SELECT $SID,id,1 FROM items WHERE slug='$s'"; done
dbx "UPDATE users SET onboarded=1, tour_step=0, energy=100 WHERE id=$SID"; dbx "UPDATE expeditions SET status='done' WHERE user_id=$SID"
COAST=$(db "SELECT id FROM locations WHERE landscape='coast' LIMIT 1")
dbx "UPDATE users SET location_id=$COAST WHERE id=$SID"      # coast: knife, axe, rod and bucket all find something here
# The helper plays a round: php play.php MODE < round.json  ->  the gev JSON. Modes: perfect good bad miss
cat > $T/play.php <<'PHP'
<?php
$r = json_decode(stream_get_contents(STDIN), true); $mode = $argv[1]; $type = $r['type'];
$ev = [];
switch ($type) {
  case 'lure':
    $t = $r['showEnd'] + 300; $pat = $r['pat'];
    if ($mode === 'good') { $ev[] = [($pat[0] + 1) % $r['nc'], $t]; $t += $r['rep'] + $r['L'] * ($r['bl'] + $r['gap']) + 300; }   // one nibble, then the pattern again
    if ($mode === 'miss') { $ev[] = [($pat[0] + 1) % $r['nc'], $t]; $ev[] = [($pat[0] + 1) % $r['nc'], $t + $r['rep'] + $r['L'] * ($r['bl'] + $r['gap']) + 300]; break; }
    if ($mode === 'bad') { $ev = [[$pat[0], 200], [$pat[1], 500]]; break; }   // pulses while the fish is still blinking
    foreach ($pat as $c) { $ev[] = [$c, $t]; $t += 250; }
    break;
  case 'trace':
    $pts = $r['pts']; $t = 400; $n = count($pts);
    if ($mode === 'bad') { $ev = [[100, 100, 400], [900, 900, 420], [100, 900, 440]]; break; }   // teleporting
    if ($mode === 'miss') { for ($i = 0; $i < 20; $i++) $ev[] = [20 + $i * 3, 980, $t + $i * 80]; break; }   // a line along the edge
    $step = $mode === 'good' ? 2 : 3;
    for ($i = 0; $i < $n; $i += ($mode === 'good' ? 1 : 2)) { $ev[] = [(int)round($pts[$i][0] * 10 + ($i % 2 ? 6 : -6)), (int)round($pts[$i][1] * 10 + ($i % 2 ? -6 : 6)), $t]; $t += 60; }
    if ($mode === 'good') { $ev = array_slice($ev, 0, (int)($n * 0.78)); }   // lifted off before the end
    break;
  case 'chop':
    $start = $r['first'];
    for ($i = 0; $i < 3; $i++) {
      $best = null; $bd = $mode === 'miss' ? -1 : 1e9;
      for ($t = $start + 360; $t < $start + $r['wait']; $t += 2) {
        $d = abs($r['amp'] * sin(2 * M_PI * ($t - $start) / $r['per'][$i] + $r['ph'][$i]));
        if ($mode === 'miss' ? $d > $bd : $d < $bd) { $bd = $d; $best = $t; if ($mode !== 'miss' && $d < $r['p'] / 4) break; }
        if ($mode === 'miss' && $t > $start + 3000) break;
      }
      if ($mode === 'good') { for ($t = $start + 360; $t < $start + $r['wait']; $t += 2) { $d = abs($r['amp'] * sin(2 * M_PI * ($t - $start) / $r['per'][$i] + $r['ph'][$i])); if ($d > $r['p'] / 2 + 1 && $d < $r['g'] / 2 - 0.5) { $best = $t; break; } } }
      if ($mode === 'bad') $best = $start + 100;   // before the log has settled
      $ev[] = $best; $start = $best + $r['arrive'];
    }
    break;
  case 'glint':
    foreach ($r['gl'] as $k => $g) {
      if ($mode === 'good' && $k >= 6) break;
      $x = $mode === 'bad' ? fmod($g['x'] + 50, 100) : $g['x']; $y = $g['y'];
      $ev[] = [$k, $g['a'] + 300, (int)round($x * 10), (int)round($y * 10)];
    }
    if ($mode === 'miss') $ev = [];
    break;
  case 'flit':
    $t = 600; $upto = $mode === 'good' ? 3 : 5;
    if ($mode === 'miss') { for ($i = 0; $i < 10; $i++) $ev[] = [20, 20, $t + $i * 60]; break; }
    $f = function ($b, $tt) { $u = max(0, min(1, ($tt - $b['a']) / $b['life'])); $dx = $b['x1'] - $b['x0']; $dy = $b['y1'] - $b['y0']; $len = max(1, hypot($dx, $dy)); $off = $b['fa'] * sin($b['ff'] * ($tt - $b['a']) + $b['fp']); return [$b['x0'] + $dx * $u - $dy / $len * $off, $b['y0'] + $dy * $u + $dx / $len * $off]; };
    // an honest swipe: from bug to bug, one each second, keeping within a finger's speed
    $prev = null;
    for ($k = 0; $k < $upto; $k++) {
      $tk = 600 + $k * 1000; $p = $f($r['bugs'][$k], $tk);
      if ($prev) for ($q = 1; $q <= 19; $q++) $ev[] = [(int)round(($prev[0] + ($p[0] - $prev[0]) * $q / 20) * 10), (int)round(($prev[1] + ($p[1] - $prev[1]) * $q / 20) * 10), $tk - 1000 + $q * 50];
      $ev[] = [(int)round($p[0] * 10), (int)round($p[1] * 10), $tk]; $prev = $p;
    }
    if ($mode === 'bad') $ev = [[100, 100, 700], [900, 900, 750]];   // across the field in 50 ms
    break;
  case 'drip':
    $x = $mode === 'miss' ? 2.0 : 50.0; $t = 0; $dur = $r['dur'] - 400; $i = 0; $sp = 0.055;
    while ($t <= $dur) {
      if ($mode !== 'miss') {
        while ($i < $r['n'] && $r['dr'][$i]['a'] + $r['fd'] < $t - 50) $i++;
        $tgt = $i < $r['n'] ? $r['sx'][$r['dr'][$i]['s']] : $x;
        $tgt += ($x > $tgt ? 1 : -1) * $r['bw'] * 0.5;   // only as far as needed
        $x += max(-$sp * 100, min($sp * 100, $tgt - $x));
        if ($mode === 'bad') $x = $t % 200 === 0 ? 5 : 95;   // flicking across the cave
      }
      $ev[] = [(int)round($x * 10), $t]; $t += 100;
    }
    $ev[] = [(int)round($x * 10), $r['dur'] - 300];
    break;
  case 'cue': $ev = [(int)($r['T'] + $r['W'] * 0.5)]; if ($mode === 'bad') $ev = [100]; break;
}
echo json_encode($ev);
PHP
# a gather request: gather TOOL TOK EVENTS_JSON [extra curl args] -> the page after the redirect in $T/out.html
page() { curl -s -c $C -b $C "$BASE/world.php?tab=gather" > $T/w.html; }
round() { page; curl -s -c $C -b $C -X POST $BASE/gather.php --data-urlencode "csrf=$(csrf $T/w.html)" -d do=round -d tool=$1 ${2:+-d rm=$2} > $T/r-$1.json; }
field() { php -r '$j=json_decode(file_get_contents($argv[1]),true); echo $j[$argv[2]] ?? "";' "$T/r-$1.json" "$2"; }
submit() { page; curl -s -L -c $C -b $C $BASE/gather.php --data-urlencode "csrf=$(csrf $T/w.html)" -d do=gather -d tool=$1 --data-urlencode "gtok=$2" --data-urlencode "gev=$3" -d back=world.php?tab=gather > $T/out.html; }
flash1() { grep -oE '<li class="ml (ok|err)[^>]*>.*' $T/out.html | head -1 | sed 's/<\/li>.*//; s/<img[^>]*ico-target[^>]*>/🎯/g; s/<[^>]*>//g'; }   # emoji are <img> icons now: keep the 🎯 marker, drop the other tags   # this try's message: the newest line in the message log
line() { flash1 | grep -oE '🎯.*' | head -1; }
gatherN() { flash1 | grep -oE 'You gather [0-9]+' | head -1 | grep -oE '[0-9]+$'; }
TOOLS="forage axe pick rod net bucket"
want() { case $1 in forage) echo trace;; axe) echo chop;; pick) echo glint;; rod) echo lure;; net) echo flit;; bucket) echo drip;; esac; }   # 1.5.0: Stem Trace, Log Split, Glint Strike, Spore Lure, Bug Swoop, Drip Catch

echo "== rounds: each tool starts one (JSON with a token and its type)"
dbx "UPDATE users SET location_id=(SELECT id FROM locations WHERE landscape='coast' LIMIT 1) WHERE id=$SID"
for t in forage axe rod bucket; do round $t; chk "$t type" "$(field $t type)" "$(want $t)"; [ -n "$(field $t tok)" ] && echo "ok   $t has a token" || echo "FAIL $t no token"; done
dbx "UPDATE users SET location_id=(SELECT id FROM locations WHERE landscape='wetland' LIMIT 1) WHERE id=$SID"
for t in pick net; do round $t; chk "$t type" "$(field $t type)" "$(want $t)"; done
round forage 1; chk "reduced motion: the trace still plays" "$(field forage type)" trace
round rod 1; chk "reduced motion: the lure still plays" "$(field rod type)" lure
round axe 1; chk "reduced motion gets the still cue round" "$(field axe type)" cue
round bucket 1; chk "bucket reduced motion" "$(field bucket type)" cue
echo "-- the endpoint's guards"
page; chk "round without csrf" "$(curl -s -o /dev/null -w '%{http_code}' -c $C -b $C -X POST $BASE/gather.php -d do=round -d tool=axe)" 400
round staff; echo "no game for a non-gathering tool: $(grep -o '"error"' $T/r-staff.json)"
dbx "UPDATE settings SET value='0' WHERE name='gather_games_on'"; round axe; echo "games switched off: $(grep -o '"error"' $T/r-axe.json)"; dbx "UPDATE settings SET value='1' WHERE name='gather_games_on'"

echo "== all six games, played for real: start every round together, wait for the clock, hand each in"
# (a tool only gathers where there is something to find: coast for knife, axe, rod, bucket; wetland for pick, net: play() moves the gnome)
start_all() { for t in $TOOLS; do round $t; done; }
play() { # play TOOL MODE : hand in the round started above (location is set to where that tool gathers)
  case $1 in pick|net) dbx "UPDATE users SET location_id=(SELECT id FROM locations WHERE landscape='wetland' LIMIT 1) WHERE id=$SID";; *) dbx "UPDATE users SET location_id=(SELECT id FROM locations WHERE landscape='coast' LIMIT 1) WHERE id=$SID";; esac
  dbx "UPDATE users SET energy=100 WHERE id=$SID"; GEV=$(php $T/play.php $2 < $T/r-$1.json); submit $1 "$(field $1 tok)" "$GEV"; }
start_all
echo "-- from the future: the knife's perfect taps, handed in at once, don't count"
play forage perfect; echo "   $(line)"; [ -z "$(line)" ] && echo "ok   too-early hand-in is a plain find" || echo "FAIL early hand-in scored"
round forage; cp $T/r-forage.json $T/r-forage-keep.json
echo "-- waiting 17 s for the clock..."; sleep 17
for t in $TOOLS; do play $t perfect; L=$(line); echo "$t perfect -> $L"; if [ $t = bucket ]; then echo "$L" | grep -qE 'doesn’t wear|good bucketful' && echo "ok   bucket honest play = perfect or good (it depends on the drips)" || echo "FAIL bucket band"; else echo "$L" | grep -q 'doesn’t wear' && echo "ok   $t perfect band (+1, no wear)" || echo "FAIL $t perfect band"; fi; [ "$(gatherN)" -ge 2 ] && echo "ok   $t gave $(gatherN) items" || echo "FAIL $t qty $(gatherN)"; done
echo "-- replay: the same round and taps again are a plain find"
GEV=$(php $T/play.php perfect < $T/r-forage-keep.json); submit forage "$(field forage tok)" "$GEV"; [ -z "$(line)" ] && echo "ok   replay refused (no 🎯 line)" || echo "FAIL replay scored: $(line)"
echo "-- a token that was never issued, and none at all"
submit axe deadbeefdeadbeef '[500]'; [ -z "$(line)" ] && echo "ok   forged token refused" || echo "FAIL forged token"
submit axe '' '[500]'; [ -z "$(line)" ] && echo "ok   no token = plain find" || echo "FAIL no token scored"

echo "== impossible plays are plain finds (each needs a fresh round)"
dbx "UPDATE users SET location_id=(SELECT id FROM locations WHERE landscape='coast' LIMIT 1) WHERE id=$SID"
for t in forage axe rod bucket; do round $t; done
dbx "UPDATE users SET location_id=(SELECT id FROM locations WHERE landscape='wetland' LIMIT 1) WHERE id=$SID"
for t in pick net; do round $t; done
echo "-- waiting 17 s so only the checks (not the clock) can refuse these..."; sleep 17
for t in $TOOLS; do play $t bad; [ -z "$(line)" ] && echo "ok   $t: impossible taps refused" || echo "FAIL $t: scored '$(line)'"; done
round axe; submit axe "$(field axe tok)" '[-1,-1,-1,-1]'; [ -z "$(line)" ] && echo "ok   wrong number of strikes refused" || echo "FAIL wrong strikes"
round axe; submit axe "$(field axe tok)" '"not json"'; [ -z "$(line)" ] && echo "ok   junk events refused" || echo "FAIL junk events"
round axe; submit axe "$(field axe tok)" "$(php -r 'echo json_encode(array_fill(0,500,1));')"; [ -z "$(line)" ] && echo "ok   500 events refused" || echo "FAIL 500 events"

echo "== bands: good, miss, quick gather"
dbx "UPDATE users SET location_id=(SELECT id FROM locations WHERE landscape='coast' LIMIT 1) WHERE id=$SID"
round forage; round axe; round bucket
sleep 17
play forage good; L=$(line); echo "trace lifted early -> $L"; echo "$L" | grep -qE 'mostly steady|wandered' && echo "ok   good band (trace 78% = good or miss)" || echo "FAIL good band: $L"; [ "$(gatherN)" -ge 1 ] && echo "ok   good gather gave $(gatherN) items" || echo "FAIL good qty"
play axe miss; L=$(line); echo "axe wrong moments -> $L"; echo "$L" | grep -q 'glances off' && echo "ok   miss band is a plain find" || echo "FAIL miss band"; [ "$(gatherN)" -le 2 ] && echo "ok   miss gives a plain find (1, +1 Sense/basket luck)" || echo "FAIL miss qty $(gatherN)"
play bucket miss; L=$(line); echo "bucket never moved -> $L"; echo "$L" | grep -q 'Mostly puddle' && echo "ok   still bucket = miss" || echo "FAIL still bucket: $L"
echo "-- Quick gather"
dbx "UPDATE users SET energy=100 WHERE id=$SID"; page
curl -s -L -c $C -b $C $BASE/gather.php --data-urlencode "csrf=$(csrf $T/w.html)" -d do=gather -d tool=forage -d gquick=1 -d back=world.php?tab=gather > $T/out.html
L=$(line); echo "quick -> $L"; echo "$L" | [ -z "$L" ] && echo "ok   quick gather = plain find" || echo "FAIL quick gather scored"
chk "quick gather cost ⚡1" "$(db "SELECT energy FROM users WHERE id=$SID")" 99
echo "-- the panel has the game, the chips and Quick gather"
page; for k in 'class="mgfold"' 'mgstart' 'mgquick' 'name="gev"' 'data-round=' 'class="gpad"'; do grep -q "$k" $T/w.html && echo "ok   panel has $k" || echo "FAIL panel lacks $k"; done
for f in rod-bg rod-fish rod-lure knife-bg knife-blade axe-bg axe-head axe-log pick-bg pick-glint pick-pick net-bg net-bug net-net calm-bg calm-stalac calm-drop calm-bucket-back calm-bucket-front calm-pool; do [ -s $GAME/assets/img/gather/$f.svg ] && echo "ok   art $f.svg" || echo "FAIL art $f.svg missing"; done
[ -s $GAME/assets/gather-games.js ] && echo "ok   gather-games.js" || echo "FAIL gather-games.js"
echo "== php log"; grep -iE 'fatal|warning|notice|deprecated' /tmp/g099-php.log || echo "(none)"
