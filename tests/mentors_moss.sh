#!/bin/bash
# 2.8.99c: the calling mentors live in Mossbottom (the Mentors' Hall): tests/mentors_moss.php on an installed copy, then the real pages over HTTP.
# Usage: tests/mentors_moss.sh GAME_DIR [PORT] [ROUTER]   (an installed copy: player "sprout"; ci_suites.sh installs one with walk.sh first)
HERE=$(cd "$(dirname "$0")" && pwd)
GAME=$1; PORT=${2:-9862}; ROUTER=${3:-$HERE/router.php}
OUT=$(php -d error_reporting=-1 -d display_errors=1 -d session.save_path=/tmp "$HERE/mentors_moss.php" "$GAME" 2>&1); RC=$?
echo "$OUT"
LAST=$(echo "$OUT" | tail -1)
case "$LAST" in ok) ;; *FAILED) ;; *) echo "FAIL mentors_moss did not finish (last line: $LAST)"; exit 1;; esac
echo "$OUT" | grep -qE "^(PHP )?(Warning|Notice|Deprecated|Fatal error)" && { echo "FAIL mentors_moss printed PHP warnings"; exit 1; }
echo "== pages"
LOG=$(mktemp); C=$(mktemp); H=$(mktemp); BASE=http://127.0.0.1:$PORT
php -d session.save_path=/tmp -d display_errors=1 -S 127.0.0.1:$PORT -t "$GAME" "$ROUTER" >$LOG 2>&1 & PID=$!; sleep 1
trap "kill $PID 2>/dev/null" EXIT
db() { php -r '$p=new PDO("sqlite:'$GAME'/data/game.sqlite"); foreach($p->query($argv[1])->fetchAll(PDO::FETCH_NUM) as $r) echo implode(" | ",$r),"\n";' "$1"; }
db "UPDATE settings SET value = '1' WHERE name = 'gnav_on'" >/dev/null
# sprout stands in Mistmoor (the Captain's old lodge town, far from Burdock's), a Rootwarden with no chapter open who has been to Birchbramble Steppe (so the old free trip would move them)
db "UPDATE users SET calling = 'rootwarden', calling_qt = 0, calling_chapter = NULL, level = 40, location = 'Mistmoor', location_id = (SELECT id FROM locations WHERE kind = 'market' AND region = 'Mistmoor' ORDER BY id LIMIT 1) WHERE username = 'sprout'" >/dev/null
db "INSERT INTO region_visits (user_id, region_id, first_at) SELECT u.id, r.id, datetime('now') FROM users u, regions r WHERE u.username = 'sprout' AND r.code = 'EE' AND NOT EXISTS (SELECT 1 FROM region_visits v WHERE v.user_id = u.id AND v.region_id = r.id)" >/dev/null
db "DELETE FROM expeditions WHERE status = 'active'" >/dev/null
db "DELETE FROM user_calling_tasks WHERE user_id = (SELECT id FROM users WHERE username = 'sprout')" >/dev/null; db "DELETE FROM user_calling_chapters WHERE user_id = (SELECT id FROM users WHERE username = 'sprout')" >/dev/null   # the php part left a chapter open
csrf() { grep -o 'name="csrf" value="[^"]*"' "$1" | head -1 | sed 's/.*value="\([^"]*\)".*/\1/'; }
check() { if eval "$2"; then echo "  ok   $1"; else echo "  FAIL $1"; RC=1; fi; }
has() { grep -qE "$1" $H; }
curl -s -c $C -b $C "$BASE/login.php" -o $H
curl -s -c $C -b $C -X POST "$BASE/login.php" --data-urlencode "csrf=$(csrf $H)" -d username=sprout --data-urlencode 'password=TestPass123!' -o /dev/null
HALL=$(db "SELECT s.id FROM town_spots s WHERE s.region = 'Mossbottom' AND s.active = 1 AND EXISTS (SELECT 1 FROM town_actions a WHERE a.spot_id = s.id AND a.link LIKE 'mentor.php?m=%') LIMIT 1")
check "the hall exists ($HALL)" "[ -n '$HALL' ]"
code=$(curl -s -c $C -b $C "$BASE/here.php?hub=1" -o $H -w '%{http_code}')
check "here.php?hub=1 ($code): Mentors button and all six mentors in its card" "[ $code = 200 ] && has 'id=\"hs-mentors\"' && [ \$(grep -oE 'mentor\.php\?m=[a-z-]+' $H | sort -u | wc -l) = 6 ]"
code=$(curl -s -c $C -b $C "$BASE/town.php?hub=1&spot=$HALL" -o $H -w '%{http_code}')
check "the hall page ($code) links all six mentors" "[ $code = 200 ] && [ \$(grep -oE 'mentor\.php\?m=[a-z-]+' $H | sort -u | wc -l) = 6 ]"
code=$(curl -s -c $C -b $C -H 'X-Requested-With: fetch' "$BASE/town.php?hub=1&spot=$HALL&frag=1" -o $H -w '%{http_code}')
check "the hall card fragment ($code)" "[ $code = 200 ] && has '\"ok\":true' && has 'mentor.php'"
curl -s -c $C -b $C "$BASE/town.php?hub=1" -o $H
check "the Mossbottom square lists the hall" "has 'spot=$HALL'"
# region town: no mentor entry
curl -s -c $C -b $C "$BASE/town.php" -o $H
check "Mistmoor square: no lodge, no mentor link" "! has 'Old Watchtower|mentor\.php'"
curl -s -c $C -b $C "$BASE/here.php" -o $H
check "Mistmoor picture: no Mentor button" "! has 'id=\"hs-mentor\"|mentor\.php\?m='"
# old URLs
for slug in bb-rootcellar ma-marigold mm-watch ow-seedlib rr-hut ss-brewhouse; do
  OLD=$(db "SELECT id FROM town_spots WHERE slug = '$slug'")
  r=$(curl -s -c $C -b $C "$BASE/town.php?spot=$OLD" -o /dev/null -w '%{http_code} %{redirect_url}')
  check "old lodge link $slug (spot=$OLD) -> the hall: $r" "echo '$r' | grep -qE '^302 .*town\.php\?hub=1&spot=$HALL$'"
done
code=$(curl -s -c $C -b $C "$BASE/mentor.php?m=burdock-deepdelve" -o $H -w '%{http_code}')
check "mentor.php?m=burdock-deepdelve ($code): here now, in Mossbottom, Take on button, no trip button" "[ $code = 200 ] && has 'here now' && has 'Mossbottom' && has 'Take on this chapter' && ! has 'value=\"trip\"'"
check "the mentor page links back to the hall" "has 'spot=$HALL'"
for m in zinnia-fuzzbottom bracken-spurwing sorrel-inkcap tumble-waymarsh juniper-kettleby; do
  code=$(curl -s -c $C -b $C "$BASE/mentor.php?m=$m" -o $H -w '%{http_code}'); check "mentor.php?m=$m ($code) here now" "[ $code = 200 ] && has 'here now'"
done
r=$(curl -s -c $C -b $C "$BASE/mentor.php?m=nobody" -o /dev/null -w '%{http_code} %{redirect_url}')
check "an unknown mentor goes to the hall: $r" "echo '$r' | grep -q 'spot=$HALL'"
# a stale free-trip form never moves the gnome; take-on works from Birchbramble Steppe
LOC0=$(db "SELECT location_id FROM users WHERE username = 'sprout'")
CH=$(db "SELECT id FROM calling_chapters WHERE calling = 'rootwarden' AND tier = 2 AND active = 1 ORDER BY id LIMIT 1")
curl -s -c $C -b $C "$BASE/mentor.php?m=burdock-deepdelve" -o $H
curl -s -c $C -b $C -X POST "$BASE/mentor.php" --data-urlencode "csrf=$(csrf $H)" -d do=trip -d ch=$CH -d m=burdock-deepdelve -o /dev/null
check "old trip form: the gnome stays put" "[ \"\$(db \"SELECT location_id FROM users WHERE username = 'sprout'\")\" = '$LOC0' ]"
curl -s -c $C -b $C "$BASE/mentor.php?m=burdock-deepdelve" -o $H
curl -s -c $C -b $C -X POST "$BASE/mentor.php" --data-urlencode "csrf=$(csrf $H)" -d do=start -d ch=$CH -d m=burdock-deepdelve -o /dev/null
check "take on the chapter from Mistmoor" "[ \"\$(db \"SELECT calling_chapter FROM users WHERE username = 'sprout'\")\" = '$CH' ]"
grep -E 'PHP (Warning|Notice|Fatal|Deprecated)' $LOG && { echo "  FAIL PHP warnings in the server log"; RC=1; }
exit $RC
