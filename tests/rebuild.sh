#!/bin/bash
# Landmark repairs (v0.7.77+). The old monthly Job Board rebuild was retired: includes/jobs.php ~107 gives the
# monthly 'ruins' pool no entries, so a monthly rebuild offer is never made. This script checks that, then tests the
# repair path at the place itself: take on, hand in the four stages, a bought item does not count, give up and resume
# without paying twice, finish, and the Founder plaque.
GAME=$1; PORT=$2; ROUTER=$3; BASE=http://127.0.0.1:$PORT
php -d session.save_path=/tmp -S 127.0.0.1:$PORT -t $GAME $ROUTER >/tmp/rb-php.log 2>&1 & PID=$!; sleep 1
trap "kill $PID 2>/dev/null" EXIT
csrf() { grep -o 'name="csrf" value="[^"]*"' "$1" | head -1 | sed 's/.*value="\([^"]*\)".*/\1/'; }
db() { php -r '$p=new PDO("sqlite:'$GAME'/data/game.sqlite"); foreach($p->query($argv[1])->fetchAll(PDO::FETCH_NUM) as $r) echo implode(" | ",$r),"\n";' "$1"; }
dbx() { php -r '$p=new PDO("sqlite:'$GAME'/data/game.sqlite"); $p->exec($argv[1]);' "$1"; }
C=/tmp/rb-ck; rm -f $C; curl -s -c $C -b $C $BASE/login.php > /tmp/r.html; curl -s -c $C -b $C -X POST $BASE/login.php --data-urlencode "csrf=$(csrf /tmp/r.html)" -d username=sprout -d 'password=TestPass123!' -o /dev/null
SID=$(db "SELECT id FROM users WHERE username='sprout'")
dbx "UPDATE settings SET value='100000' WHERE name='event_chance'"; dbx "UPDATE users SET level=5, coins=2000, energy=40, tour_step=0 WHERE id=$SID"
give() { dbx "INSERT OR IGNORE INTO user_items (user_id,item_id,qty) VALUES ($SID,(SELECT id FROM items WHERE slug='$1'),0)"; dbx "UPDATE user_items SET qty=qty+$2 WHERE user_id=$SID AND item_id=(SELECT id FROM items WHERE slug='$1')"; }
coins() { db "SELECT coins FROM users WHERE id=$SID"; }
page() { curl -s -b $C -c $C "$BASE/$1" > /tmp/r.html; }
# act LM_ID -d ... : POST an action to landmark.php the way the panel's forms do
act() { local lm=$1; shift; page world.php; curl -s -b $C -c $C -X POST "$BASE/landmark.php" --data-urlencode "csrf=$(csrf /tmp/r.html)" -d lm=$lm -d back=world.php "$@" -o /dev/null; }
move() { dbx "UPDATE users SET location_id=(SELECT location_id FROM landmarks WHERE id=$1) WHERE id=$SID"; }
stage_of() { db "SELECT stage FROM landmark_repairs WHERE id=$1"; }

echo "== monthly rebuild offers are retired"
dbx "UPDATE job_templates SET active=1 WHERE period='monthly' AND kind='rebuild'"
page jobs.php; echo "  offer on Job Board: $(grep -c '<h3>Rebuild' /tmp/r.html) (expect 0)"
curl -s -b $C -c $C -X POST "$BASE/jobs.php" --data-urlencode "csrf=$(csrf /tmp/r.html)" -d period=monthly -d do=take -d i=0 -o /dev/null
echo "  rebuild jobs taken: $(db "SELECT COUNT(*) FROM user_jobs WHERE user_id=$SID AND kind='rebuild'") (expect 0)"

# two ruins: the first is finished, the second is started, dropped and resumed
mapfile -t RUINS < <(db "SELECT m.id FROM landmarks m WHERE m.ruined=1 AND m.restored_at IS NULL AND m.kind IN ('haven','wonder','delve') ORDER BY m.id LIMIT 2" | cut -d' ' -f1)
LM=${RUINS[0]:-}; LM2=${RUINS[1]:-}
[ -n "$LM" ] || { echo "no ruins in the database: cannot test repairs"; exit 1; }
echo "== take on the repair: $(db "SELECT name||' ('||kind||')' FROM landmarks WHERE id=$LM")"
move $LM; page world.php; echo "  repair offered in panel: $(grep -c 'Take on the repair' /tmp/r.html)"
act $LM -d do=repair_start
RID=$(db "SELECT id FROM landmark_repairs WHERE user_id=$SID AND landmark_id=$LM AND done_at IS NULL AND dropped_at IS NULL" | tr -d ' ')
echo "  repair row: ${RID:-none} stage $(stage_of ${RID:-0})"
echo "  second start is refused: $(act $LM -d do=repair_start; db "SELECT COUNT(*) FROM landmark_repairs WHERE user_id=$SID AND landmark_id=$LM")" "(expect 1 row)"

hand() { act $LM -d do=repair_hand -d repair=$RID; }
echo "== stage 1: dressed stone x6 + 150 Petals"
c0=$(coins); echo -n "  without materials: "; hand; echo "stage $(stage_of $RID) (expect 0)"
give building-stone 6; hand; echo "  with materials: stage $(stage_of $RID) (expect 1), Petals $c0 -> $(coins)"
echo "== stage 2: timber plank x6 + rope x3"
give timber-plank 6; give rope 3; hand; echo "  stage $(stage_of $RID) (expect 2)"
echo "== stage 3: 4 home-cooked meals (shop food does not count)"
give bought-garden-vegetable-soup 4; hand; echo "  shop food only: stage $(stage_of $RID) (expect 2)"
MEAL=$(db "SELECT i.slug FROM items i WHERE i.category='food' AND i.slug NOT LIKE 'bought-%' AND i.id IN (SELECT output_item_id FROM recipes WHERE category='cooking' AND tier IN ('meal','feast')) ORDER BY i.id LIMIT 1" | tr -d ' ')
give "$MEAL" 4; hand; echo "  with $MEAL x4: stage $(stage_of $RID) (expect 3)"
echo "== stage 4: 2 uncommon/rare finds + 300 Petals"
FINE=$(db "SELECT i.slug FROM items i JOIN gatherables g ON g.item_id=i.id WHERE g.rarity IN ('uncommon','rare') ORDER BY i.id LIMIT 1" | tr -d ' ')
give "$FINE" 2; c0=$(coins); hand; echo "  $FINE x2: stage $(stage_of $RID) (expect 4), Petals $c0 -> $(coins)"
echo "  repair: $(db "SELECT 'done='||(done_at IS NOT NULL)||' stage='||stage FROM landmark_repairs WHERE id=$RID")"
echo "  landmark: $(db "SELECT name||' | restored='||(restored_at IS NOT NULL)||' by '||COALESCE(restored_by,'-') FROM landmarks WHERE id=$LM")"
echo "  this gnome's rebuild row: $(db "SELECT COUNT(*) FROM landmark_rebuilds WHERE landmark_id=$LM AND user_id=$SID") (expect 1)"
page world.php; echo "  panel: $(grep -oE 'class="restored">[^<]*' /tmp/r.html | sed 's/.*">//' | cut -c1-90)"
echo "  offered again: $(grep -c 'Take on the repair' /tmp/r.html) (expect 0)"
act $LM -d do=repair_start; echo "  restart after finishing: $(db "SELECT COUNT(*) FROM landmark_repairs WHERE user_id=$SID AND landmark_id=$LM") row(s) (expect 1)"

if [ -n "$LM2" ]; then
  echo "== give up and resume: $(db "SELECT name FROM landmarks WHERE id=$LM2")"
  move $LM2; act $LM2 -d do=repair_start
  R2=$(db "SELECT id FROM landmark_repairs WHERE user_id=$SID AND landmark_id=$LM2" | tr -d ' ')
  give building-stone 6
  act $LM2 -d do=repair_hand -d repair=$R2; echo "  stage 1 handed in: stage $(stage_of $R2) (expect 1)"
  act $LM2 -d do=repair_drop -d repair=$R2; echo "  dropped: $(db "SELECT 'dropped='||(dropped_at IS NOT NULL)||' stage='||stage FROM landmark_repairs WHERE id=$R2")"
  c0=$(coins); act $LM2 -d do=repair_start
  echo "  resumed: rows $(db "SELECT COUNT(*) FROM landmark_repairs WHERE user_id=$SID AND landmark_id=$LM2") (expect 1), stage $(stage_of $R2) (expect 1), Petals $c0 -> $(coins) (expect no pay)"
fi

echo "  other ruins left in the database: $(db "SELECT COUNT(*) FROM landmarks WHERE kind IN ('haven','wonder','delve') AND ruined=1 AND restored_at IS NULL")"
dbx "UPDATE job_templates SET active=1"
echo "== php errors"; grep -iE 'fatal|warning|notice|deprecated|exception' /tmp/rb-php.log || echo "(none)"
