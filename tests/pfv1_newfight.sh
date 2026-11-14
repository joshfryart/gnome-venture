#!/bin/bash
# 2.6.96: a won fight, its result card's button, then a NEW encounter and its fight, all in one document (in-place swaps): the page must show the new fight, never the old one.
# Plain adventure page, then the modal Trail dialog. See tests/pfv1_newfight.js.
# Usage: tests/pfv1_newfight.sh [GAME_COPY_DIR] [PORT] [ROUTER]   (default: copies src/game to a temp dir; SRC=dir uses another game tree)
HERE=$(cd "$(dirname "$0")" && pwd); ROOT=$(cd "$HERE/.." && pwd)
GAME=${1:-}; PORT=${2:-8867}; ROUTER=${3:-$HERE/router.php}
if [ -z "$GAME" ]; then T=$(mktemp -d); cp -r "${SRC:-$ROOT/game}" "$T/game"; GAME=$T/game; fi
rm -f "$GAME/config.php"; rm -rf "$GAME/data"; mkdir -p "$GAME/data"
BASE=http://127.0.0.1:$PORT; LOG=$(mktemp)
php -d session.save_path=/tmp -d display_errors=1 -S 127.0.0.1:$PORT -t "$GAME" "$ROUTER" >$LOG 2>&1 & PID=$!; sleep 1
C=$(mktemp); H=$(mktemp)
trap "kill \$PID 2>/dev/null; rm -f \$C \$H \$H.out \$LOG; [ -n \"\$T\" ] && rm -rf \"\$T\"" EXIT
csrf() { grep -o 'name="csrf" value="[^"]*"' "$1" | head -1 | sed 's/.*value="\([^"]*\)".*/\1/'; }
get() { curl -s -c $C -b $C "$BASE/$1" -o $H -w '%{http_code}'; }
post() { local page=$1; shift; curl -s -c $C -b $C -X POST "$BASE/$page" --data-urlencode "csrf=$(csrf $H)" "$@" -o $H -w '%{http_code}'; }
db() { php -r '$p=new PDO("sqlite:'$GAME'/data/game.sqlite"); foreach($p->query($argv[1])->fetchAll(PDO::FETCH_NUM) as $r) echo implode(" | ",$r),"\n";' "$1"; }
get install.php >/dev/null
post install.php -d driver=sqlite -d "site_name=Gnome Venture" -d base_url= -d admin_user=admin -d admin_email=a@b.local -d admin_pass=TestPassword123 -d admin_pass2=TestPassword123 >/dev/null
grep -q 'All planted' $H || { echo "INSTALL FAILED"; tail -5 $LOG; exit 1; }
rm -f $C
get register.php >/dev/null; post register.php -d username=sprout -d email=s@b.local -d password=TestPass123! -d password2=TestPass123! -d rules=1 -d age=1 >/dev/null
get welcome.php >/dev/null; post welcome.php -d do=gnome -d "gnome_name=Bramble" -d 'hat=#2e7d4f' -d 'beard=#b5651d' >/dev/null
get 'welcome.php?step=place' >/dev/null
RID=$(db "SELECT id FROM regions WHERE code='NA'")
VID=$(db "SELECT l.id FROM locations l WHERE l.region_id=$RID AND l.kind='village' AND EXISTS (SELECT 1 FROM routes r WHERE r.kind='road' AND (r.a_id=l.id OR r.b_id=l.id)) ORDER BY l.sort_order LIMIT 1 OFFSET 1")
post welcome.php -d do=place -d village_id=$VID >/dev/null
get 'welcome.php?step=garden' >/dev/null; post welcome.php -d do=finish -d 'garden_name=Test Patch' >/dev/null
db "UPDATE users SET energy=100, tour_step=99, level=12 WHERE username='sprout'" >/dev/null
for s in pfight_open pfight_v1; do db "INSERT OR REPLACE INTO settings (name,value) VALUES ('$s','1')" >/dev/null; done
db "INSERT OR REPLACE INTO settings (name,value) VALUES ('pfight_mode','board')" >/dev/null
# the first box is packed (a new encounter then opens on its pre-fight screen, as for a player past the starter pick)
get puzzlebox.php >/dev/null; post puzzlebox.php -d do=pfd_starter -d 'pick[]=jab' -d 'pick[]=snack' -d 'pick[]=brace' -d 'pick[]=hum' -d 'pick[]=pierce' -d 'pick[]=swing#2' >/dev/null
[ "$(db "SELECT COUNT(*) FROM pf_deck_pieces WHERE starter=1")" -gt 0 ] || { echo "STARTER NOT PACKED"; exit 1; }
FAILS=0
if [ -d /opt/node-tools/node_modules/playwright ] || node -e "require('playwright')" 2>/dev/null; then
  echo "== a new fight after a won one: the plain adventure page"
  NODE_PATH=${NODE_PATH:-/opt/node-tools/node_modules} node "$HERE/pfv1_newfight.js" "$BASE" "$GAME" "$HERE" plain 2>&1 | tee $H.out | cut -c1-400
  echo "== the same in the modal Trail dialog (a tile walk)"
  php "$HERE/here.php" "$GAME" cli tilewalk >/dev/null
  NODE_PATH=${NODE_PATH:-/opt/node-tools/node_modules} node "$HERE/pfv1_newfight.js" "$BASE" "$GAME" "$HERE" modal 2>&1 | tee -a $H.out | cut -c1-400
  FAILS=$(grep -c '^FAIL' $H.out); [ "$(grep -c '^newfight: done' $H.out)" = 2 ] || FAILS=$((FAILS+1))
else echo "skip (no playwright)"; fi
[ "$FAILS" -eq 0 ] && echo "pfv1_newfight ok" || echo "$FAILS FAILED"
[ "$FAILS" -eq 0 ]
