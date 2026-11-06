#!/bin/bash
# Scripted playthrough of v0.7.1 on a fresh SQLite install.
set -u
GAME=$1; PORT=$2; ROUTER=$3
BASE=http://127.0.0.1:$PORT
TD="${TMPDIR:-/tmp}"   # scratch files (cookies, pages, php log): honour TMPDIR so parallel runs do not clobber each other
php -d session.save_path=/tmp -S 127.0.0.1:$PORT -t $GAME $ROUTER >$TD/walk-php.log 2>&1 &
PID=$!; sleep 1
trap "kill $PID 2>/dev/null" EXIT
C=$TD/walk-ck; rm -f $C
csrf() { grep -o 'name="csrf" value="[^"]*"' "$1" | head -1 | sed 's/.*value="\([^"]*\)".*/\1/'; }
get() { curl -s -c $C -b $C "$BASE/$1" -o $TD/walk.html -w '%{http_code} %{redirect_url}'; }
post() { local page=$1; shift; local t; t=$(csrf $TD/walk.html); curl -s -c $C -b $C -X POST "$BASE/$page" --data-urlencode "csrf=$t" "$@" -o $TD/walk-post.html -w '%{http_code} %{redirect_url}'; }
flashes() { grep -oE 'class="flash (ok|err)">[^<]*' $TD/walk.html | sed 's/class="flash //'; }
db() { php -r '$p=new PDO("sqlite:'$GAME'/data/game.sqlite"); foreach($p->query($argv[1])->fetchAll(PDO::FETCH_NUM) as $r) echo implode(" | ",$r),"\n";' "$1"; }

echo "== install"
get install.php >/dev/null
post install.php -d driver=sqlite -d "site_name=Gnome Venture" -d base_url= -d admin_user=admin -d admin_email=a@b.local -d admin_pass=TestPassword123 -d admin_pass2=TestPassword123 >/dev/null
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
db "SELECT 'visits before finish: '||COUNT(*) FROM region_visits"
get 'welcome.php?step=garden' >/dev/null
echo "summary chips: $(grep -o 'class="chip"' $TD/walk.html | wc -l)"
echo "finish: $(post welcome.php -d do=finish -d 'garden_name=Fernhollow Patch')"
echo "double submit: $(post welcome.php -d do=finish -d 'garden_name=Again')"
db "SELECT gnome_name, hat_color, beard_color, region_id, home_village_id, onboarded, tour_step FROM users WHERE username='sprout'"
db "SELECT garden_name, region_id, village_id, width||'x'||height FROM plots WHERE user_id=(SELECT id FROM users WHERE username='sprout')"
db "SELECT 'visited: '||r.code FROM region_visits v JOIN regions r ON r.id=v.region_id WHERE v.user_id=(SELECT id FROM users WHERE username='sprout')"
db "SELECT code||'='||min_level FROM regions ORDER BY min_level"
db "SELECT i.name||' x'||ui.qty FROM user_items ui JOIN items i ON i.id=ui.item_id WHERE ui.user_id=(SELECT id FROM users WHERE username='sprout') ORDER BY i.category, i.name"

echo "== tour + soil"
get garden.php >/dev/null; flashes; grep -oE '<h3>Wren’s tour[^<]*' $TD/walk.html
get 'garden.php?sel=0-0' >/dev/null
echo "till: $(post garden.php -d do=till -d x=0 -d y=0)"
get 'garden.php?sel=0-0' >/dev/null; grep -oE '<h3>Wren’s tour[^<]*' $TD/walk.html
COMPOST=$(db "SELECT id FROM items WHERE slug='plain-compost'")
F0=$(db "SELECT fertility FROM plot_tiles WHERE x=0 AND y=0 AND user_id=(SELECT id FROM users WHERE username='sprout')")
echo "compost 1: $(post garden.php -d do=soil -d x=0 -d y=0 -d item_id=$COMPOST)"
get 'garden.php?sel=0-0' >/dev/null; flashes; grep -oE 'class="feeding">[^<]*<?[^<]*' $TD/walk.html | head -1
echo "compost 2 (should refuse): $(post garden.php -d do=soil -d x=0 -d y=0 -d item_id=$COMPOST)"
get 'garden.php?sel=0-0' >/dev/null; flashes
db "SELECT 'fert before='||$F0||' now='||fertility||' pool='||feed_fert||'/'||feed_life||' hours='||feed_hours FROM plot_tiles WHERE x=0 AND y=0 AND user_id=(SELECT id FROM users WHERE username='sprout')"
echo "-- pretend 10 hours pass"
php -r '$p=new PDO("sqlite:'$GAME'/data/game.sqlite"); $p->exec("UPDATE plot_tiles SET feed_at=datetime(feed_at, \"-10 hours\") WHERE x=0 AND y=0 AND feed_hours>0");'
get 'garden.php?sel=0-0' >/dev/null
db "SELECT 'after 10h: fert='||fertility||' life='||soil_life||' pool='||feed_fert||'/'||feed_life||' hours='||feed_hours FROM plot_tiles WHERE x=0 AND y=0 AND user_id=(SELECT id FROM users WHERE username='sprout')"
echo "-- pretend the rest passes"
php -r '$p=new PDO("sqlite:'$GAME'/data/game.sqlite"); $p->exec("UPDATE plot_tiles SET feed_at=datetime(feed_at, \"-20 hours\") WHERE x=0 AND y=0 AND feed_hours>0");'
get 'garden.php?sel=0-0' >/dev/null
db "SELECT 'done: fert='||fertility||' life='||soil_life||' pool='||feed_fert||'/'||feed_life||' hours='||feed_hours FROM plot_tiles WHERE x=0 AND y=0 AND user_id=(SELECT id FROM users WHERE username='sprout')"
RADISH=$(db "SELECT id FROM items WHERE slug='radish-seed'")
echo "plant: $(post garden.php -d do=plant -d x=0 -d y=0 -d item_id=$RADISH)"
get 'garden.php?sel=0-0' >/dev/null
echo "water: $(post garden.php -d do=water -d x=0 -d y=0)"
db "SELECT 'energy after the free tour actions (till, soil, plant, water): '||energy FROM users WHERE username='sprout'"   # v0.9.4: tour actions are free
get inventory.php >/dev/null; echo "satchel -> $(grep -oE '<h3>Wren’s tour[^<]*' $TD/walk.html)"
APPLE=$(db "SELECT id FROM items WHERE slug='apple'")
echo "eat apple (tour step 5, v0.9.4): $(post inventory.php -d do=eat -d item_id=$APPLE)"
db "SELECT 'tour_step='||tour_step||' scraps='||COALESCE((SELECT qty FROM user_items ui JOIN items i ON i.id=ui.item_id WHERE ui.user_id=users.id AND i.slug='food-scrap'),0) FROM users WHERE username='sprout'"
for p in book.php gnome.php world.php; do get $p >/dev/null; echo "$p -> $(grep -oE '<h3>Wren’s tour[^<]*' $TD/walk.html)"; done
SHOP=$(db "SELECT id FROM shops LIMIT 1"); get "shop.php?id=$SHOP" >/dev/null; echo "shop -> $(grep -oE '<h3>Wren’s tour[^<]*' $TD/walk.html)"
echo "-- grow the radish"
php -r '$p=new PDO("sqlite:'$GAME'/data/game.sqlite"); $p->exec("UPDATE plot_tiles SET growth_seconds=999999 WHERE plant_id IS NOT NULL");'
get 'garden.php?sel=0-0' >/dev/null
COINS0=$(db "SELECT coins FROM users WHERE username='sprout'")
echo "harvest: $(post garden.php -d do=harvest -d x=0 -d y=0)"
get garden.php >/dev/null; flashes
db "SELECT 'tour_step='||tour_step||' coins '||$COINS0||' -> '||coins FROM users WHERE username='sprout'"
echo "tour box gone: $(grep -c 'class="tourbox"' $TD/walk.html)"
echo "sidebar gnome card: $(grep -c 'class="gnomecard"' $TD/walk.html)  name in bar: $(grep -oE '<strong>[^<]*</strong>' $TD/walk.html | head -1)"
echo "== php errors"
grep -iE 'fatal|warning|notice|deprecated' $TD/walk-php.log || echo "(none)"
