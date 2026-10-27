#!/bin/bash
# v2.0.46 scene banners: dummy art in a temp copy, then check the pages show it (and show nothing without it).
# Usage: tests/clock.sh [GAME_COPY_DIR] [PORT] [ROUTER]   (default: copies src/game to a temp dir; never writes a DB into src)
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
SHOP=$(db "SELECT id FROM shops ORDER BY id LIMIT 1")
echo "== no art drawn: pages unchanged"
get "town.php?hub=1" >/dev/null; echo "square banner: $(grep -c 'scene-bannerwrap' $H) (want 0)"
get "shop.php?id=$SHOP" >/dev/null; echo "shop art: $(grep -c 'class="ph-art' $H) (want 1: the shipped shop-seeds.png; v2.0.65 shop art sits in the place header)"
echo "== with dummy art"
mkdir -p "$GAME/assets/img/scenes"
python3 - "$GAME/assets/img/scenes" <<'PY'
import sys, struct, zlib
def png(path, w, h):
    raw = b''.join(b'\x00' + bytes([120, 160, 90]) * w for _ in range(h))
    def ch(t, d): return struct.pack('>I', len(d)) + t + d + struct.pack('>I', zlib.crc32(t + d) & 0xffffffff)
    open(path, 'wb').write(b'\x89PNG\r\n\x1a\n' + ch(b'IHDR', struct.pack('>IIBBBBB', w, h, 8, 2, 0, 0, 0)) + ch(b'IDAT', zlib.compress(raw)) + ch(b'IEND', b''))
d = sys.argv[1]
for k in ['market', 'village', 'haven', 'general']: png(f'{d}/banner-{k}.png' if k != 'general' else f'{d}/shop-general.png', 480, 120)
for k in ['cottage', 'burrow', 'treehouse', 'hut', 'stone', 'boat']: png(f'{d}/home-{k}.png', 480, 270)
PY
get "town.php?hub=1" >/dev/null; echo "square banner: $(grep -c scene-bannerwrap $H) (want 1)"; grep -A3 "<h1" $H | head -12 | cut -c1-200
get "shop.php?id=$SHOP" >/dev/null; echo "shop art: $(grep -c 'class="ph-art' $H) (want 1)"
NID=$(db "SELECT id FROM npcs WHERE active=1 ORDER BY id LIMIT 1")
db "INSERT OR IGNORE INTO user_npc_met (user_id,npc_id,first_at) SELECT id,$NID,datetime('now') FROM users WHERE username='sprout'" >/dev/null
for h in 0 3 12 18 23; do
  db "UPDATE settings SET value='$h' WHERE name='hollow_hour_force'" >/dev/null
done
echo "villager panel: $(curl -s -c $C -b $C -H 'X-Requested-With: fetch' "$BASE/villagers.php?id=$NID" | grep -o 'homestage\|"ok":[a-z]*' | sort -u | tr '\n' ' ')"
echo "== php errors"
grep -iE 'fatal|warning|notice|deprecated' $LOG || echo "(none)"
