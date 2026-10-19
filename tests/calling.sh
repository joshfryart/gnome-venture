#!/bin/bash
# Calling questlines (0.9.4): fresh SQLite install in a temp copy, then tests/calling.php, then page renders.
# Usage: tests/calling.sh [GAME_COPY_DIR] [PORT] [ROUTER]   (default: copies src/game to a temp dir; never writes a DB into src)
HERE=$(cd "$(dirname "$0")" && pwd)
GAME=${1:-}; PORT=${2:-8793}; ROUTER=${3:-$HERE/router.php}
if [ -z "$GAME" ]; then T=$(mktemp -d); cp -r "$HERE/../game" "$T/game"; GAME=$T/game; fi
rm -f "$GAME/config.php"; rm -rf "$GAME/data"; mkdir -p "$GAME/data"
BASE=http://127.0.0.1:$PORT
LOG=$(mktemp)
php -d session.save_path=/tmp -d display_errors=1 -S 127.0.0.1:$PORT -t "$GAME" "$ROUTER" >$LOG 2>&1 & PID=$!; sleep 1
trap "kill $PID 2>/dev/null" EXIT
C=$(mktemp); H=$(mktemp)
csrf() { grep -o 'name="csrf" value="[^"]*"' "$1" | head -1 | sed 's/.*value="\([^"]*\)".*/\1/'; }
get() { curl -s -c $C -b $C "$BASE/$1" -o $H -w '%{http_code}'; }
post() { local page=$1; shift; curl -s -c $C -b $C -X POST "$BASE/$page" --data-urlencode "csrf=$(csrf $H)" "$@" -o $H -w '%{http_code}'; }
db() { php -r '$p=new PDO("sqlite:'$GAME'/data/game.sqlite"); foreach($p->query($argv[1])->fetchAll(PDO::FETCH_NUM) as $r) echo implode(" | ",$r),"\n";' "$1"; }
echo "== install + register + welcome"
get install.php >/dev/null
post install.php -d driver=sqlite -d "site_name=Gnome Venture" -d base_url= -d admin_user=admin -d admin_email=a@b.local -d admin_pass=TestPassword123 -d admin_pass2=TestPassword123 >/dev/null
grep -q 'All planted' $H && echo installed || { echo "INSTALL FAILED"; grep -oE "flash err[^<]*<[^<]*" $H; tail -5 $LOG; exit 1; }
rm -f $C
get register.php >/dev/null; post register.php -d username=sprout -d email=s@b.local -d password=TestPass123! -d password2=TestPass123! -d rules=1 -d age=1 >/dev/null
get welcome.php >/dev/null; post welcome.php -d do=gnome -d "gnome_name=Bramble" -d 'hat=#2e7d4f' -d 'beard=#b5651d' >/dev/null
get 'welcome.php?step=place' >/dev/null
RID=$(db "SELECT id FROM regions WHERE code='NA'")
VID=$(db "SELECT l.id FROM locations l WHERE l.region_id=$RID AND l.kind='village' AND EXISTS (SELECT 1 FROM routes r WHERE r.kind='road' AND (r.a_id=l.id OR r.b_id=l.id)) ORDER BY l.sort_order LIMIT 1 OFFSET 1")
post welcome.php -d do=place -d village_id=$VID >/dev/null
get 'welcome.php?step=garden' >/dev/null; post welcome.php -d do=finish -d 'garden_name=Test Patch' >/dev/null
echo "onboarded: $(db "SELECT onboarded FROM users WHERE username='sprout'")"
echo "== engine + hooks (tests/calling.php)"
php -d display_errors=1 -d error_reporting=-1 "$HERE/calling.php" "$GAME" 2>&1; RC=$?
echo "== pages with an open chapter"
php -r '$p=new PDO("sqlite:'$GAME'/data/game.sqlite"); $p->exec("UPDATE users SET level=15, calling=\"rootwarden\", calling_qt=0 WHERE username=\"sprout\"");'
for pg in gnome.php 'book.php?ch=Callings' 'book.php?ch=Milestones' garden.php town.php profile.php?u=sprout jobs.php index.php; do echo "$pg -> $(get "$pg")"; done
grep -o 'Journeyman[^<]*chapter[^<]*' $H | head -1
get gnome.php >/dev/null; grep -oE 'Journeyman \(level 15 and a chapter\)' $H | head -1; grep -oE 'Your calling grows stronger[^<]*' $H | head -1
echo "== mentor page over HTTP (own test chapter, rootwarden, in Birchbramble Steppe)"
php -r '$p=new PDO("sqlite:'$GAME'/data/game.sqlite");
$p->exec("UPDATE calling_chapters SET active=0 WHERE calling=\"rootwarden\"");
$p->exec("INSERT INTO calling_chapters (slug,calling,tier,title,mentor_slug,reward_coins,reward_xp,reward_title,intro,outro,active) VALUES (\"t-http\",\"rootwarden\",2,\"HTTP Test Chapter\",\"burdock-deepdelve\",300,100,\"Test Title\",\"Hello there.\",\"Well done.\",1)");
$id=$p->lastInsertId();
$p->exec("INSERT INTO calling_tasks (chapter_id,sort_order,mode,kind,spec,qty,label) VALUES ($id,1,\"event\",\"gather\",\"\",1,\"Gather one thing\")");
$p->exec("INSERT INTO calling_tasks (chapter_id,sort_order,mode,kind,spec,qty,label) VALUES ($id,2,\"give\",\"give\",\"coins:10\",1,\"Bring 10 Petals\")");
$p->exec("UPDATE users SET level=15, calling=\"rootwarden\", calling_qt=0, calling_chapter=NULL, coins=500, calling_tier_seen=1, location=\"Birchbramble Steppe\", location_id=(SELECT id FROM locations WHERE kind=\"market\" AND region=\"Birchbramble Steppe\"), energy=100 WHERE username=\"sprout\"");'
echo "mentor.php -> $(get 'mentor.php?m=burdock-deepdelve')"; grep -q 'Burdock Deepdelve' $H && echo "  page names the mentor"; grep -q 'Take on this chapter' $H && echo "  start button shown"; grep -q 'here now' $H && echo "  mentor here now"
echo "mentor.php (no m, uses my calling) -> $(get mentor.php)"
SPOT=$(db "SELECT id FROM town_spots WHERE slug='bb-rootcellar'")
echo "lodge in town square -> $(get "town.php?spot=$SPOT")"; grep -q 'mentor.php?m=burdock-deepdelve' $H && echo "  lodge links to the mentor page"
get 'mentor.php?m=burdock-deepdelve' >/dev/null; echo "talk -> $(post mentor.php -d do=talk -d m=burdock-deepdelve)"
CID=$(db "SELECT id FROM calling_chapters WHERE slug='t-http'")
get 'mentor.php?m=burdock-deepdelve' >/dev/null; post mentor.php -d do=start -d "ch=$CID" -d m=burdock-deepdelve >/dev/null
echo "started: chapter=$(db "SELECT calling_chapter FROM users WHERE username='sprout'") (want $CID)"
get 'mentor.php?m=burdock-deepdelve' >/dev/null; grep -q 'Gather one thing' $H && echo "  task listed"
post mentor.php -d do=hand_in -d "ch=$CID" -d m=burdock-deepdelve >/dev/null; echo "early hand-in refused: coins=$(db "SELECT coins FROM users WHERE username='sprout'") (want 500)"
php -r '$p=new PDO("sqlite:'$GAME'/data/game.sqlite"); $p->exec("UPDATE user_calling_tasks SET progress=1, done_at=datetime(\"now\") WHERE task_id IN (SELECT id FROM calling_tasks WHERE kind=\"gather\" AND chapter_id='$CID')");'
get 'mentor.php?m=burdock-deepdelve' >/dev/null; grep -q 'Hand in' $H && echo "  hand-in button shown"
post mentor.php -d do=finish -d "ch=$CID" -d m=burdock-deepdelve >/dev/null; echo "finish before hand-in refused: qt=$(db "SELECT calling_qt FROM users WHERE username='sprout'") (want 0)"
get 'mentor.php?m=burdock-deepdelve' >/dev/null; post mentor.php -d do=hand_in -d "ch=$CID" -d m=burdock-deepdelve >/dev/null
echo "handed in: coins=$(db "SELECT coins FROM users WHERE username='sprout'") (want 490)"
get 'mentor.php?m=burdock-deepdelve' >/dev/null; grep -q 'Finish the chapter' $H && echo "  finish button shown"
post mentor.php -d do=finish -d "ch=$CID" -d m=burdock-deepdelve >/dev/null
echo "finished: qt=$(db "SELECT calling_qt FROM users WHERE username='sprout'") (want 1) chapter=$(db "SELECT COALESCE(calling_chapter,'none') FROM users WHERE username='sprout'") coins=$(db "SELECT coins FROM users WHERE username='sprout'") (want 790) done=$(db "SELECT COUNT(*) FROM user_calling_chapters WHERE done_at IS NOT NULL")"
echo "mentor.php after finish -> $(get 'mentor.php?m=burdock-deepdelve')"; grep -q 'Well done' $H && echo "  outro shown"
echo "elsewhere: mentor away -> $(php -r '$p=new PDO("sqlite:'$GAME'/data/game.sqlite"); $p->exec("UPDATE users SET location=\"Mistmoor\" WHERE username=\"sprout\"");' ; get 'mentor.php?m=burdock-deepdelve')"; grep -q 'need to be in their town' $H && echo "  away note shown"
echo "other mentors + pages -> $(for m in zinnia-fuzzbottom bracken-spurwing sorrel-inkcap tumble-waymarsh juniper-kettleby; do get "mentor.php?m=$m"; echo -n ' '; done) $(get 'mentor.php?m=nobody') $(get admin/callings.php)"
echo "== admin page (as admin)"
rm -f $C; get login.php >/dev/null; post login.php -d username=admin -d password=TestPassword123 >/dev/null
echo "admin/callings.php -> $(get admin/callings.php)"; grep -q 'Thorn Master' $H && echo "  lists chapters"; grep -q 'Import calling quests' $H && echo "  import button"
post admin/callings.php -d do=import >/dev/null; echo "import again -> $(get admin/callings.php)"
echo "== php warnings / errors"
if grep -iE 'warning|notice|deprecated|fatal|exception' $LOG; then RC=1; else echo "(none)"; fi
[ -s "$GAME/data/error-log.txt" ] && { echo "error-log.txt:"; head -20 "$GAME/data/error-log.txt"; RC=1; }
exit $RC
