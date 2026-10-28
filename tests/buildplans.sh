#!/bin/bash
# v2.0.76 build plans (data/build_plans.txt, includes/rebuild.php). Run after walk.sh has installed (player "sprout").
#   data lint: every plan names a real landmark, has 4 stages, valid verbs, real item slugs, clear stages are days-only
#   play a planned place (Cenote of Echoes): gather, clear on two different days (same day refused), haul, gather+Petals, restore
#   a repair begun on the old stages keeps them; a place with no plan uses the old stages
GAME=$1; PORT=$2; ROUTER=$3; BASE=http://127.0.0.1:$PORT
php -d session.save_path=/tmp -S 127.0.0.1:$PORT -t $GAME $ROUTER >/tmp/bp-php.log 2>&1 & PID=$!; sleep 1
trap "kill $PID 2>/dev/null" EXIT
FAILS=0
chk() { if [ "$2" = 1 ]; then echo "  ok   $1"; else echo "  FAIL $1 $3"; FAILS=$((FAILS+1)); fi; }
csrf() { grep -o 'name="csrf" value="[^"]*"' "$1" | head -1 | sed 's/.*value="\([^"]*\)".*/\1/'; }
db() { php -r '$p=new PDO("sqlite:'$GAME'/data/game.sqlite"); foreach($p->query($argv[1])->fetchAll(PDO::FETCH_NUM) as $r) echo implode(" | ",$r),"\n";' "$1"; }
dbx() { php -r '$p=new PDO("sqlite:'$GAME'/data/game.sqlite"); $p->exec($argv[1]);' "$1"; }
C=/tmp/bp-ck; rm -f $C; curl -s -c $C -b $C $BASE/login.php > /tmp/bp.html; curl -s -c $C -b $C -X POST $BASE/login.php --data-urlencode "csrf=$(csrf /tmp/bp.html)" -d username=sprout -d 'password=TestPass123!' -o /dev/null
SID=$(db "SELECT id FROM users WHERE username='sprout'")
dbx "UPDATE settings SET value='100000' WHERE name='event_chance'"; dbx "UPDATE users SET level=5, coins=5000, energy=100, tour_step=0 WHERE id=$SID"
give() { dbx "INSERT OR IGNORE INTO user_items (user_id,item_id,qty) VALUES ($SID,(SELECT id FROM items WHERE slug='$1'),0)"; dbx "UPDATE user_items SET qty=qty+$2 WHERE user_id=$SID AND item_id=(SELECT id FROM items WHERE slug='$1')"; }
page() { curl -s -b $C -c $C "$BASE/$1" > /tmp/bp.html; }
act() { local lm=$1; shift; page world.php; curl -s -b $C -c $C -X POST "$BASE/landmark.php" --data-urlencode "csrf=$(csrf /tmp/bp.html)" -d lm=$lm -d back=world.php "$@" -o /dev/null; }
move() { dbx "UPDATE users SET location_id=(SELECT location_id FROM landmarks WHERE id=$1) WHERE id=$SID"; }
stage_of() { db "SELECT stage FROM landmark_repairs WHERE id=$1" | tr -d ' '; }

echo "== data lint (every plan in build_plans.txt)"
LINT=$(php -r '$_SERVER["SCRIPT_NAME"]="/gnome.php"; require "'$GAME'/includes/bootstrap.php"; require_once "'$GAME'/includes/rebuild.php";
  $bad = []; $n = 0;
  foreach (build_plans(true) as $key => $st) {
    $n++;
    $lm = q_one("SELECT * FROM landmarks WHERE lower(name) = ?", [$key]);
    if (!$lm) { $bad[] = "no landmark named $key"; continue; }
    if (!in_array($lm["kind"], ["haven","wonder","delve"], true)) $bad[] = "$key is a " . $lm["kind"] . " (only haven/wonder/delve can be in ruins)";
    foreach ($st as $i => $d) {
      if (!isset(BUILD_VERBS[$d["verb"]])) $bad[] = "$key $i bad verb";
      if (($d["needs"][0][0] ?? "") === "days" && count($d["needs"]) !== 1) $bad[] = "$key $i clear stage has other needs";
      if ($d["verb"] === "clear" && ($d["needs"][0][0] ?? "") !== "days") $bad[] = "$key $i clear verb without days";
      if ($d["verb"] !== "clear" && ($d["needs"][0][0] ?? "") === "days") $bad[] = "$key $i days need on a $d[verb] stage";
      foreach ($d["needs"] as $need) if ($need[0] === "item" && !q_val("SELECT 1 FROM items WHERE slug = ?", [$need[1]])) $bad[] = "$key $i unknown item $need[1]";
      if (str_contains($d["text"], "|")) $bad[] = "$key $i text has a pipe";
    }
  }
  echo $n, " plans", $bad ? " BAD: " . implode("; ", $bad) : "", "\n";')
echo "  $LINT"
chk "plans load and every one is clean" "$(echo "$LINT" | grep -q 'BAD' && echo 0 || echo 1)" "$LINT"
chk "at least 9 plans (the Maizehollow + Sunsprinkle pilot)" "$([ "$(echo "$LINT" | cut -d' ' -f1)" -ge 9 ] && echo 1)"

echo "== a planned place: Cenote of Echoes"
LM=$(db "SELECT id FROM landmarks WHERE name='Cenote of Echoes'" | tr -d ' ')
dbx "UPDATE landmarks SET ruined=1, restored_at=NULL, restored_by=NULL WHERE id=$LM"; dbx "DELETE FROM landmark_rebuilds WHERE landmark_id=$LM"; dbx "DELETE FROM landmark_repairs WHERE landmark_id=$LM"
move $LM; act $LM -d do=repair_start
RID=$(db "SELECT id FROM landmark_repairs WHERE user_id=$SID AND landmark_id=$LM" | tr -d ' ')
chk "repair began on plan v1" "$([ "$(db "SELECT plan FROM landmark_repairs WHERE id=$RID" | tr -d ' ')" = v1 ] && echo 1)"
page world.php
chk "panel shows stage 1 title 'Rig the descent'" "$(grep -q 'Rig the descent' /tmp/bp.html && echo 1)"
chk "panel shows the placeholder verb picture" "$(grep -q 'img/steps/stage-gather' /tmp/bp.html && echo 1)"
chk "no 'Dressed Stone' asked on stage 1" "$(grep -q 'Dressed Stone' /tmp/bp.html && echo 0 || echo 1)"
act $LM -d do=repair_hand -d repair=$RID; chk "stage 1 refused without materials" "$([ "$(stage_of $RID)" = 0 ] && echo 1)"
give rope 4; give coir-fibre 4; act $LM -d do=repair_hand -d repair=$RID
chk "stage 1 (rope + coir) handed in" "$([ "$(stage_of $RID)" = 1 ] && echo 1)"
echo "  -- stage 2: clear, 2 days, 4 energy each"
page world.php
chk "panel shows 'Work here today'" "$(grep -q 'Work here today' /tmp/bp.html && echo 1)"
act $LM -d do=repair_hand -d repair=$RID; chk "a clear stage cannot be handed in" "$([ "$(stage_of $RID)" = 1 ] && echo 1)"
e0=$(db "SELECT energy FROM users WHERE id=$SID" | tr -d ' ')
act $LM -d do=repair_work -d repair=$RID
chk "day 1 counted, stage not done" "$([ "$(db "SELECT prog FROM landmark_repairs WHERE id=$RID" | tr -d ' ')" = 1 ] && [ "$(stage_of $RID)" = 1 ] && echo 1)"
e1=$(db "SELECT energy FROM users WHERE id=$SID" | tr -d ' ')
chk "day 1 cost 4 energy" "$([ $((e0 - e1)) -ge 3 ] && [ $((e0 - e1)) -le 4 ] && echo 1)" "($e0 -> $e1)"
act $LM -d do=repair_work -d repair=$RID
chk "same day twice is refused" "$([ "$(db "SELECT prog FROM landmark_repairs WHERE id=$RID" | tr -d ' ')" = 1 ] && echo 1)"
dbx "UPDATE landmark_repairs SET prog_day='2000-01-01' WHERE id=$RID"
act $LM -d do=repair_work -d repair=$RID
chk "day 2 finishes the stage by itself" "$([ "$(stage_of $RID)" = 2 ] && [ "$(db "SELECT prog FROM landmark_repairs WHERE id=$RID" | tr -d ' ')" = 0 ] && echo 1)"
echo "  -- stage 3: haul planks, stage 4: fine finds + Petals"
give timber-plank 6; act $LM -d do=repair_hand -d repair=$RID; chk "stage 3 handed in" "$([ "$(stage_of $RID)" = 3 ] && echo 1)"
FINE=$(db "SELECT i.slug FROM items i JOIN gatherables g ON g.item_id=i.id WHERE g.rarity IN ('uncommon','rare') ORDER BY i.id LIMIT 1" | tr -d ' ')
give "$FINE" 2; c0=$(db "SELECT coins FROM users WHERE id=$SID" | tr -d ' ')
act $LM -d do=repair_hand -d repair=$RID
chk "stage 4 done, repair finished" "$([ "$(db "SELECT done_at IS NOT NULL FROM landmark_repairs WHERE id=$RID" | tr -d ' ')" = 1 ] && echo 1)"
chk "place restored for this gnome" "$([ "$(db "SELECT COUNT(*) FROM landmark_rebuilds WHERE landmark_id=$LM AND user_id=$SID" | tr -d ' ')" = 1 ] && echo 1)"
c1=$(db "SELECT coins FROM users WHERE id=$SID" | tr -d ' ')
chk "stage 4 took 300 Petals and paid its reward (net change is not -300)" "$([ $c1 -gt $((c0-300)) ] && echo 1)" "($c0 -> $c1)"

echo "== a repair begun on the old stages keeps them"
dbx "DELETE FROM landmark_rebuilds WHERE landmark_id=$LM"; dbx "DELETE FROM landmark_repairs WHERE landmark_id=$LM"; dbx "UPDATE landmarks SET restored_at=NULL, restored_by=NULL WHERE id=$LM"
dbx "INSERT INTO landmark_repairs (user_id, landmark_id, stage, started_at) VALUES ($SID, $LM, 0, datetime('now'))"
RID=$(db "SELECT id FROM landmark_repairs WHERE user_id=$SID AND landmark_id=$LM" | tr -d ' ')
page world.php
chk "old repair asks for Dressed Stone" "$(grep -q 'Dressed Stone' /tmp/bp.html && echo 1)"
give building-stone 6; act $LM -d do=repair_hand -d repair=$RID
chk "old stage 1 (6 stone + 150) handed in" "$([ "$(stage_of $RID)" = 1 ] && echo 1)"

echo "== a place with no plan uses the old stages"
NP=$(db "SELECT m.id FROM landmarks m WHERE m.kind IN ('haven','wonder','delve') AND m.region_id=(SELECT id FROM regions WHERE code='MENA') ORDER BY m.id LIMIT 1" | tr -d ' ')
dbx "UPDATE landmarks SET ruined=1, restored_at=NULL WHERE id=$NP"; dbx "DELETE FROM landmark_repairs WHERE landmark_id=$NP"; dbx "DELETE FROM landmark_rebuilds WHERE landmark_id=$NP"
move $NP; act $NP -d do=repair_start
chk "unplanned repair has no plan stamp" "$([ -z "$(db "SELECT COALESCE(plan,'') FROM landmark_repairs WHERE landmark_id=$NP AND user_id=$SID" | tr -d ' ')" ] && echo 1)"
page world.php; chk "unplanned panel asks for Dressed Stone" "$(grep -q 'Dressed Stone' /tmp/bp.html && echo 1)"

echo "== php errors"
chk "no PHP warnings or fatals" "$(grep -iE 'fatal|warning|notice|deprecated|exception' /tmp/bp-php.log | grep -q . && echo 0 || echo 1)" "$(grep -iE 'fatal|warning|notice|deprecated|exception' /tmp/bp-php.log | head -3)"
[ $FAILS -eq 0 ] && echo "all passed" || echo "$FAILS FAILED"; [ $FAILS -eq 0 ]
