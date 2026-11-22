#!/bin/bash
# 2.7.55 Creature Codex: table, note rules, sheets (met / beaten / unknown), the Codex tab renders. Installs a temp copy (player sprout).
# 2.7.57: drawn pieces (tests/pfcodex.php), the How it works tab, the intro card once (pfi_seen), and a 390 px browser check of the sheet (tests/pfcodex.js, when playwright is there).
HERE=$(cd "$(dirname "$0")" && pwd); PORT=${1:-8797}
T=$(mktemp -d); cp -r "$HERE/../game" "$T/game"; GAME=$T/game; rm -f "$GAME/config.php"; rm -rf "$GAME/data"; mkdir -p "$GAME/data"
BASE=http://127.0.0.1:$PORT; LOG=$(mktemp); C=$(mktemp); H=$(mktemp)
php -d session.save_path=/tmp -d display_errors=1 -S 127.0.0.1:$PORT -t "$GAME" "$HERE/router.php" >$LOG 2>&1 & PID=$!; sleep 1
trap "kill \$PID 2>/dev/null; rm -rf \"\$T\"" EXIT
csrf() { grep -o 'name="csrf" value="[^"]*"' "$1" | head -1 | sed 's/.*value="\([^"]*\)".*/\1/'; }
get() { curl -s -c $C -b $C "$BASE/$1" -o $H -w '%{http_code}'; }
post() { local page=$1; shift; curl -s -c $C -b $C -X POST "$BASE/$page" --data-urlencode "csrf=$(csrf $H)" "$@" -o $H -w '%{http_code}'; }
db() { php -r '$p=new PDO("sqlite:'$GAME'/data/game.sqlite"); foreach($p->query($argv[1])->fetchAll(PDO::FETCH_NUM) as $r) echo implode(" | ",$r),"\n";' "$1"; }
get install.php >/dev/null
post install.php -d driver=sqlite -d "site_name=Gnome Venture" -d base_url= -d admin_user=admin -d admin_email=a@b.local -d admin_pass=TestPassword123 -d admin_pass2=TestPassword123 >/dev/null
grep -q 'All planted' $H || { echo "INSTALL FAILED"; exit 1; }
rm -f $C; get register.php >/dev/null; post register.php -d username=sprout -d email=s@b.local -d password=TestPass123! -d password2=TestPass123! -d rules=1 -d age=1 >/dev/null
get welcome.php >/dev/null; post welcome.php -d do=gnome -d "gnome_name=Bramble" -d 'hat=#2e7d4f' -d 'beard=#b5651d' >/dev/null
get 'welcome.php?step=place' >/dev/null
RID=$(db "SELECT id FROM regions WHERE code='NA'")
VID=$(db "SELECT l.id FROM locations l WHERE l.region_id=$RID AND l.kind='village' AND EXISTS (SELECT 1 FROM routes r WHERE r.kind='road' AND (r.a_id=l.id OR r.b_id=l.id)) ORDER BY l.sort_order LIMIT 1")
post welcome.php -d do=place -d village_id=$VID >/dev/null
get 'welcome.php?step=garden' >/dev/null; post welcome.php -d do=finish -d 'garden_name=Test Patch' >/dev/null
# 2.7.57: puzzle combat is on for everyone by default (no settings written here)
FAILS=0
SL=$(php "$HERE/pfcodex.php" "$GAME" set | tail -1); A=${SL% *}
php "$HERE/pfcodex.php" "$GAME" check || FAILS=1
get 'puzzlebox.php?t=codex' >/dev/null; grep -q 'Creature Codex' $H && echo "ok   Codex tab renders" || { echo "FAIL Codex tab"; FAILS=1; }
get "puzzlebox.php?t=codex&c=$A" >/dev/null; grep -q 'Test Nip' $H && echo "ok   sheet link shows the seen piece" || { echo "FAIL sheet link"; FAILS=1; }
get 'puzzlebox.php?t=codex&z=boss' >/dev/null; grep -q 'cx-grid' $H && echo "ok   size filter renders" || { echo "FAIL filter"; FAILS=1; }
get 'puzzlebox.php?t=how' >/dev/null; grep -q 'How puzzle combat works' $H && grep -q 'id="pfi"' $H && echo "ok   How it works tab + the intro card the first time" || { echo "FAIL how tab / intro"; FAILS=1; }
post puzzlebox.php -d do=pfi_seen -d back=puzzlebox >/dev/null; get 'puzzlebox.php' >/dev/null
grep -q 'id="pfi"' $H && { echo "FAIL intro shown again after Got it"; FAILS=1; } || echo "ok   intro not shown again once seen"
[ "$(db "SELECT COUNT(*) FROM pf_intro")" = 1 ] && echo "ok   seen flag stored per player" || { echo "FAIL pf_intro row"; FAILS=1; }
if node -e "require('playwright')" 2>/dev/null; then node "$HERE/pfcodex.js" "$BASE" "$A" "${SHOTS:-}" || FAILS=1; else echo "skip browser check (no playwright)"; fi
grep -q 'Fatal\|Warning:' $LOG && { echo "FAIL php errors:"; grep 'Fatal\|Warning:' $LOG | head -3; FAILS=1; }
[ $FAILS = 0 ] && echo "pfcodex ok" || { echo "pfcodex FAILED"; exit 1; }
