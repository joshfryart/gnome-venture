#!/bin/bash
# Scripted playthrough of v0.7.1 on a fresh SQLite install.
set -u
GAME=$1; PORT=$2; ROUTER=$3
BASE=http://127.0.0.1:$PORT
TD="${TMPDIR:-/tmp}"   # scratch files (cookies, pages, php log): honour TMPDIR so parallel runs do not clobber each other
# MySQL variant of walk.sh: needs a MySQL/MariaDB server on 127.0.0.1:3307 (db gv, root, no password). Skip cleanly when there is none.
if ! php -r 'try { new PDO("mysql:host=127.0.0.1;port=3307;dbname=gv", "root", "", [PDO::ATTR_TIMEOUT => 3]); } catch (Throwable $e) { exit(1); }' 2>/dev/null; then
  echo "SKIP: no MySQL server on 127.0.0.1:3307 (db gv); the SQLite install path is covered by walk.sh"; exit 0
fi
php -d session.save_path=/tmp -S 127.0.0.1:$PORT -t $GAME $ROUTER >$TD/walk-php.log 2>&1 &
PID=$!; sleep 1
trap "kill $PID 2>/dev/null" EXIT
C=$TD/walk-ck; rm -f $C
csrf() { grep -o 'name="csrf" value="[^"]*"' "$1" | head -1 | sed 's/.*value="\([^"]*\)".*/\1/'; }
get() { curl -s -c $C -b $C "$BASE/$1" -o $TD/walk.html -w '%{http_code} %{redirect_url}'; }
post() { local page=$1; shift; local t; t=$(csrf $TD/walk.html); curl -s -c $C -b $C -X POST "$BASE/$page" --data-urlencode "csrf=$t" "$@" -o $TD/walk-post.html -w '%{http_code} %{redirect_url}'; }
flashes() { grep -oE 'class="flash (ok|err)">[^<]*' $TD/walk.html | sed 's/class="flash //'; }
db() { php -r '$p=new PDO("mysql:host=127.0.0.1;port=3307;dbname=gv","root",""); foreach($p->query($argv[1])->fetchAll(PDO::FETCH_NUM) as $r) echo implode(" | ",$r),"\n";' "$1"; }

echo "== install"
get install.php >/dev/null
post install.php -d driver=mysql -d host=127.0.0.1 -d port=3307 -d name=gv -d user=root -d pass= -d "site_name=Gnome Venture" -d base_url= -d admin_user=admin -d admin_email=a@b.local -d admin_pass=TestPassword123 -d admin_pass2=TestPassword123 >/dev/null
grep -q 'All planted' $TD/walk-post.html && echo "installed" || { echo "INSTALL FAILED"; grep -oE 'flash err[^<]*<[^<]*' $TD/walk-post.html; exit 1; }
db "SELECT username, onboarded, tour_step, (SELECT COUNT(*) FROM plots) FROM users"

echo "== admin is sent to the welcome flow"
get login.php >/dev/null; post login.php -d username=admin -d password=TestPassword123 >/dev/null
echo "garden.php -> $(get garden.php)"
echo "admin/index.php -> $(get admin/index.php)"
rm -f $C

echo "== register new player"
get register.php >/dev/null
echo "register -> $(post register.php -d username=sprout -d email=s@b.local -d password=TestPass123! -d password2=TestPass123! -d rules=1 -d age=1)"
echo "world.php -> $(get world.php)"
get welcome.php >/dev/null; grep -oE '<li class="now">[^/]*' $TD/walk.html | head -1

echo "== step 1: gnome (bad name, then good)"
echo "bad: $(post welcome.php -d do=gnome -d 'gnome_name=<b>x' -d 'hat=#2e7d4f' -d 'beard=#b5651d')"
grep -oE 'flash err">[^<]*' $TD/walk-post.html
get welcome.php >/dev/null
echo "good: $(post welcome.php -d do=gnome -d "gnome_name=Bramble O'Puddlefoot" -d 'hat=#2e7d4f' -d 'beard=#b5651d')"

echo "== step 2: no homeland step any more (v0.7.43), everyone starts in the start region"
echo "step=home -> $(get 'welcome.php?step=home')"; grep -oE '<li class="now">[^/]*' $TD/walk.html | head -1
RID=$(db "SELECT id FROM regions WHERE code='NA'")
NWE=$(db "SELECT id FROM regions WHERE code='NWE'")
echo "try do=home to NWE: $(post welcome.php -d do=home -d region_id=$NWE)"

echo "== step 3: village"
get 'welcome.php?step=place' >/dev/null
echo "zones shown: $(grep -c 'class="box zonecard' $TD/walk.html)  village radios: $(grep -c 'name="village_id"' $TD/walk.html)"
VID=$(db "SELECT l.id FROM locations l WHERE l.region_id=$RID AND l.kind='village' AND EXISTS (SELECT 1 FROM routes r WHERE r.kind='road' AND (r.a_id=l.id OR r.b_id=l.id)) ORDER BY l.sort_order LIMIT 1 OFFSET 1")
OTHER=$(db "SELECT id FROM locations WHERE kind='village' AND region_id<>$RID LIMIT 1")
echo "village from another region: $(post welcome.php -d do=place -d village_id=$OTHER)"; grep -oE 'flash err">[^<]*' $TD/walk-post.html
get 'welcome.php?step=place' >/dev/null
echo "pick road village ($VID): $(post welcome.php -d do=place -d village_id=$VID)"

echo "== step 4: garden + finish"
db "SELECT CONCAT('visits before finish: ',COUNT(*)) FROM region_visits"
get 'welcome.php?step=garden' >/dev/null
echo "summary chips: $(grep -o 'class="chip"' $TD/walk.html | wc -l)"
echo "finish: $(post welcome.php -d do=finish -d 'garden_name=Fernhollow Patch')"
echo "double submit: $(post welcome.php -d do=finish -d 'garden_name=Again')"
db "SELECT gnome_name, hat_color, beard_color, region_id, home_village_id, onboarded, tour_step FROM users WHERE username='sprout'"
db "SELECT garden_name, region_id, village_id, CONCAT(width,'x',height) FROM plots WHERE user_id=(SELECT id FROM users WHERE username='sprout')"
db "SELECT CONCAT('visited: ',r.code) FROM region_visits v JOIN regions r ON r.id=v.region_id WHERE v.user_id=(SELECT id FROM users WHERE username='sprout')"
db "SELECT CONCAT(code,'=',min_level) FROM regions ORDER BY min_level"
db "SELECT CONCAT(i.name,' x',ui.qty) FROM user_items ui JOIN items i ON i.id=ui.item_id WHERE ui.user_id=(SELECT id FROM users WHERE username='sprout') ORDER BY i.category, i.name"

