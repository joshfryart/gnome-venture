#!/bin/bash
# Before/after of staged rigs IN THE REAL FIGHT SCENE (adventure.php -> includes/fight_scene.php -> assets/fightscene.js -> fightengine.js).
# Copies game/ to a scratch dir (the repo's game/ is never written), installs it like tests/fight_scene.sh, starts a fight against each
# creature (tests/advforce.php ... fight <slug>) and runs preview.js, which swaps in art-review/rigs/out/rig-<slug>.png by Playwright
# route interception and screenshots the assembled foe at rest and mid-attack, on light and dark.
# Usage: art-review/rigs/preview.sh [OUT.png] [slug ...]     (default: the 8 pilot rigs -> art-review/rigs/before_after_pilot.png)
set -u
HERE=$(cd "$(dirname "$0")" && pwd); ROOT=$(cd "$HERE/../.." && pwd)
OUT=${1:-$HERE/before_after_pilot.png}; shift || true
SLUGS=${*:-bog-pike will-o-wisp cloud-leopard clam-lurker crew-wren ptarmigan-flock bullfrog giant-bumblebee}
PORT=${PORT:-8797}
T=$(mktemp -d); GAME=$T/game
cp -r "$ROOT/game" "$GAME"; rm -rf "$GAME/data" "$GAME/config.php"; mkdir -p "$GAME/data"
BASE=http://127.0.0.1:$PORT
php -d session.save_path=$T -S 127.0.0.1:$PORT -t "$GAME" "$ROOT/tests/router.php" >$T/php.log 2>&1 & PID=$!
trap "kill $PID 2>/dev/null; rm -rf $T" EXIT
for _ in $(seq 1 50); do curl -s -o /dev/null "$BASE/install.php" && break; sleep 0.2; done
C=$T/ck; H=$T/h.html
csrf() { grep -o 'name="csrf" value="[^"]*"' "$1" | head -1 | sed 's/.*value="\([^"]*\)".*/\1/'; }
get() { curl -s -c $C -b $C "$BASE/$1" -o $H; }
post() { local page=$1; shift; curl -s -c $C -b $C -X POST "$BASE/$page" --data-urlencode "csrf=$(csrf $H)" "$@" -o $H; }
db() { php -r '$p=new PDO("sqlite:'$GAME'/data/game.sqlite"); foreach($p->query($argv[1])->fetchAll(PDO::FETCH_NUM) as $r) echo implode(" | ",$r),"\n";' "$1"; }
get install.php
post install.php -d driver=sqlite -d "site_name=Gnome Venture" -d base_url= -d admin_user=admin -d admin_email=a@b.local -d admin_pass=TestPassword123 -d admin_pass2=TestPassword123
grep -q 'All planted' $H || { echo "INSTALL FAILED"; exit 1; }
rm -f $C
get register.php; post register.php -d username=sprout -d email=s@b.local -d password=TestPass123! -d password2=TestPass123! -d rules=1 -d age=1
get welcome.php; post welcome.php -d do=gnome -d "gnome_name=Bramble" -d 'hat=#2e7d4f' -d 'beard=#b5651d'
get 'welcome.php?step=place'
RID=$(db "SELECT id FROM regions WHERE code='NA'")
VID=$(db "SELECT l.id FROM locations l WHERE l.region_id=$RID AND l.kind='village' AND EXISTS (SELECT 1 FROM routes r WHERE r.kind='road' AND (r.a_id=l.id OR r.b_id=l.id)) ORDER BY l.sort_order LIMIT 1 OFFSET 1")
post welcome.php -d do=place -d village_id=$VID
get 'welcome.php?step=garden'; post welcome.php -d do=finish -d 'garden_name=Test Patch'
db "UPDATE users SET energy=100, tour_step=99 WHERE username='sprout'" >/dev/null 2>&1 || db "UPDATE users SET energy=100 WHERE username='sprout'" >/dev/null
db "INSERT OR REPLACE INTO settings (name,value) VALUES ('pfight_open','0')" >/dev/null
db "INSERT OR REPLACE INTO settings (name,value) VALUES ('fight_scene','1')" >/dev/null
# preview.js calls back into this to set up each fight: a creature row when there is one, otherwise (the Trek crew) a stand-in fight whose slug it rewrites
export GV_GAME=$GAME GV_ADVFORCE=$ROOT/tests/advforce.php
cd "$HERE" && node preview.js "$BASE" "$OUT" $SLUGS
grep -iE 'fatal|warning' $T/php.log | head -5
