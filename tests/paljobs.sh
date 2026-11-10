#!/bin/bash
# v2.3.0 pal jobs: fresh SQLite install in a temp copy, tests/paljobs.php (logic), then the page (gate, forms, collect).
# Usage: tests/paljobs.sh [GAME_COPY_DIR] [PORT] [ROUTER]
HERE=$(cd "$(dirname "$0")" && pwd)
GAME=${1:-}; PORT=${2:-8797}; ROUTER=${3:-$HERE/router.php}
if [ -z "$GAME" ]; then T=$(mktemp -d); cp -r "$HERE/../game" "$T/game"; GAME=$T/game; fi
rm -f "$GAME/config.php"; rm -rf "$GAME/data"; mkdir -p "$GAME/data"
BASE=http://127.0.0.1:$PORT
LOG=$(mktemp); OUT=$(mktemp)
php -d session.save_path=/tmp -d display_errors=1 -S 127.0.0.1:$PORT -t "$GAME" "$ROUTER" >$LOG 2>&1 & PID=$!; sleep 1
trap "kill $PID 2>/dev/null" EXIT
C=$(mktemp); H=$(mktemp)
csrf() { grep -o 'name="csrf" value="[^"]*"' "$1" | head -1 | sed 's/.*value="\([^"]*\)".*/\1/'; }
get() { curl -s -c $C -b $C "$BASE/$1" -o $H -w '%{http_code}'; }
post() { local page=$1; shift; curl -s -c $C -b $C -X POST "$BASE/$page" --data-urlencode "csrf=$(csrf $H)" "$@" -o $H -w '%{http_code}'; }
db() { php -r '$p=new PDO("sqlite:'$GAME'/data/game.sqlite"); foreach($p->query($argv[1])->fetchAll(PDO::FETCH_NUM) as $r) echo implode(" | ",$r),"\n";' "$1"; }
dbx() { php -r '$p=new PDO("sqlite:'$GAME'/data/game.sqlite"); $p->exec($argv[1]);' "$1"; }
FAILS=0
chk() { if [ "$2" = "$3" ]; then echo "  ok   $1"; else echo "  FAIL $1 (got '$2', want '$3')"; FAILS=$((FAILS+1)); fi; }
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
echo "== logic (tests/paljobs.php)"
php -d display_errors=1 -d error_reporting=-1 "$HERE/paljobs.php" "$GAME" 2>&1 | tee $OUT; RC=${PIPESTATUS[0]}
chk "paljobs.php exit code" "$RC" 0
chk "no PHP warnings in the unit run" "$(grep -c "Warning\\|Notice\\|Deprecated\\|Fatal" $OUT)" 0
echo "== the page"
rm -f $C; get login.php >/dev/null; post login.php -d username=sprout --data-urlencode 'password=TestPass123!' >/dev/null
dbx "UPDATE users SET level = 9 WHERE username='sprout'"
chk "level 9: bounced to the book" "$(get paljobs.php)" 302
dbx "UPDATE users SET level = 10 WHERE username='sprout'"
chk "level 10: page renders" "$(get paljobs.php)" 200
chk "page lists pals" "$(grep -c 'class="pjrow pjpal' $H | awk '{print ($1>0)?"yes":"no"}')" yes
chk "page has the send forms" "$(grep -c 'name="do" value="send_trip"' $H | awk '{print ($1>0)?"yes":"no"}')" yes
chk "no inline style attributes" "$(grep -c ' style=' $H)" 0
dbx "DELETE FROM ppal_jobs WHERE kind IN ('delve','trip')"; dbx "UPDATE ppal_found SET a_xp=0, status='home', hp=-1"
get paljobs.php >/dev/null
chk "v2.3.3: delve post tags low-Adventuring pals Risky" "$(grep -c 'class="pjrisky">Risky' $H | awk '{print ($1>0)?"yes":"no"}')" yes
chk "v2.3.3: delve form carries the risky warning (shown by CSS when a risky pal is picked)" "$(grep -c 'class="pjriskwarn"' $H)" 1
chk "v2.3.3: risky pals are still sendable (not disabled)" "$(grep -o '<input type="checkbox" name="pals\[\]"[^>]*data-pj-risky="1"[^>]*>' $H | grep -c disabled)" 0
chk "v2.3.3: garden post no longer gates tasks by level" "$(grep -c 'weeds from 3\|harvests at 9' $H)" 0
dbx "UPDATE ppal_found SET a_xp=400"
get paljobs.php >/dev/null
chk "v2.3.3: Adventuring 5+ pals are not marked risky" "$(grep -c 'class="pjrisky"' $H)" 0
chk "no raw row ids in the forms (pal id is the 16-hex hash)" "$(grep -o 'name="pals\[\]" value="[^"]*"' $H | grep -vc 'value="[0-9a-f]\{16\}"')" 0
get paljobs.php >/dev/null
PAL=$(grep -o 'name="pals\[\]" value="[0-9a-f]\{16\}"' $H | head -1 | sed 's/.*value="\(.*\)"/\1/')
dbx "UPDATE ppal_found SET status='home', hp=-1"; dbx "DELETE FROM ppal_jobs"
get paljobs.php >/dev/null
PLOT=$(db "SELECT id FROM plots LIMIT 1")
chk "POST send_garden redirects" "$(post paljobs.php -d do=send_garden -d pal=$PAL -d plot=$PLOT -d days=1)" 302
chk "garden job via the page is refused (crew replaces it, v2.6.40)" "$(db "SELECT COUNT(*) FROM ppal_jobs WHERE kind='garden' AND state='active'")" 0
chk "a bad hash is refused (no job)" "$(get paljobs.php >/dev/null; post paljobs.php -d do=send_garden -d pal=ffffffffffffffff -d plot=$PLOT -d days=1 >/dev/null; db "SELECT COUNT(*) FROM ppal_jobs")" 0
chk "POST without csrf is refused" "$(curl -s -c $C -b $C -X POST "$BASE/paljobs.php" -d do=recall -d job=1 -o /dev/null -w "%{http_code}")" 400
echo "== v2.3.3: pals home with loot (home page: TODAY and MY GNOME tabs) + Collect receipt"
SID=$(db "SELECT id FROM users WHERE username='sprout'")
PAL2=$(db "SELECT pal_uid FROM ppal_found WHERE user_id=$SID AND status='home' ORDER BY id DESC LIMIT 1")
dbx "UPDATE ppal_found SET status='trip' WHERE pal_uid='$PAL2'"
dbx "INSERT INTO ppal_jobs (user_id, pal_uid, kind, target, day, tool, started_at, ends_at, last_tick, potions, tasks, state, result) VALUES ($SID, '$PAL2', 'trip', 'forest', '', 'forage', datetime('now','-2 hours'), datetime('now','-1 minutes'), datetime('now'), 0, 0, 'active', '{\"rounds\":2,\"items\":[],\"hp\":5,\"potions_used\":0,\"potions_back\":0,\"fainted\":false}')"
JOB=$(db "SELECT MAX(id) FROM ppal_jobs")
get gnome.php >/dev/null
chk "home (TODAY tab): the notice links to the jobs page" "$(grep -c 'class="pjhome"><a href="[^"]*paljobs.php">.* 1 pal home with loot' $H)" 1
chk "home (TODAY tab): the notice is drawn once (no double render)" "$(grep -o 'class="pjhome"' $H | wc -l | tr -d ' ')" 1
chk "home (TODAY tab): no inline style attributes" "$(grep -c ' style=' $H)" 0
get 'gnome.php?tab=gnome' >/dev/null
chk "home (MY GNOME tab): the notice is drawn once" "$(grep -o 'class="pjhome"' $H | wc -l | tr -d ' ')" 1
get paljobs.php >/dev/null
chk "POST collect redirects" "$(post paljobs.php -d do=collect -d job=$JOB)" 302
get paljobs.php >/dev/null
chk "receipt head says where the pal came back from" "$(grep -c '<b>[^<]* is back from the forest\.</b>' $H)" 1
get gnome.php >/dev/null
chk "home: notice gone once collected" "$(grep -c 'class="pjhome"' $H)" 0
echo "== v2.3.95: several pals at once, Collect all"
chk "v2.3.95: page CSS keys on the pals[] checkboxes (a stale name=pal selector hid the options and Send)" "$(grep -c 'input\[name="pal"\]' $GAME/assets/puzzles.css)" 0
get paljobs.php >/dev/null
chk "v2.3.99: tool options carry the lands they work in" "$(grep -c 'data-pj-gtool' $H | awk '{print ($1>0)?"yes":"no"}')" yes
chk "v2.3.95: each pal can carry its own place/tool (over[..])" "$(grep -c 'name="over\[' $H | awk '{print ($1>0)?"yes":"no"}')" yes
dbx "DELETE FROM ppal_jobs"; dbx "UPDATE ppal_found SET status='home', hp=20"
PALS=$(db "SELECT pal_uid FROM ppal_found WHERE user_id=$SID AND status='home' ORDER BY id LIMIT 3")
P1=$(echo "$PALS" | sed -n 1p); P2=$(echo "$PALS" | sed -n 2p); P3=$(echo "$PALS" | sed -n 3p)
get paljobs.php >/dev/null
chk "two pals to one garden: both refused (garden stays are retired, crew replaces them)" "$(post paljobs.php -d do=send_garden -d "pals[]=$P1" -d "pals[]=$P2" -d plot=$PLOT -d days=1 >/dev/null; db "SELECT COUNT(*) FROM ppal_jobs WHERE kind='garden' AND state='active'")" 0
chk "pal jobs page: garden post puts a pal on a crew slot, full time" "$(get paljobs.php >/dev/null; post paljobs.php -d do=send_garden -d "pal=$P1" -d plot=$PLOT -d role=water -d days=full >/dev/null; db "SELECT mode FROM garden_pal_slots WHERE role='water' AND plot_id=$PLOT")" full
dbx "DELETE FROM ppal_jobs"; dbx "UPDATE ppal_found SET status='home'"
for PX in $P1 $P2; do
dbx "UPDATE ppal_found SET status='trip' WHERE pal_uid='$PX'"
dbx "INSERT INTO ppal_jobs (user_id, pal_uid, kind, target, day, tool, started_at, ends_at, last_tick, potions, tasks, state, result) VALUES ($SID, '$PX', 'trip', 'forest', '', 'forage', datetime('now','-2 hours'), datetime('now','-1 minutes'), datetime('now'), 0, 0, 'active', '{\"rounds\":2,\"items\":[],\"hp\":5,\"potions_used\":0,\"potions_back\":0,\"fainted\":false}')"
done
get paljobs.php >/dev/null
chk "Collect all button shows with 2 ready jobs" "$(grep -c 'value="collect_all"' $H)" 1
chk "POST collect_all redirects" "$(post paljobs.php -d do=collect_all)" 302
chk "both jobs collected" "$(db "SELECT COUNT(*) FROM ppal_jobs WHERE state='done'")" 2
get paljobs.php >/dev/null
chk "one receipt for both" "$(grep -c 'Collected 2 jobs' $H)" 1
chk "PHP log clean" "$(grep -c 'Warning\|Fatal\|Notice\|Deprecated' $LOG)" 0
[ $FAILS = 0 ] && echo "all pal job page tests passed" || echo "$FAILS FAILED"
exit $FAILS
