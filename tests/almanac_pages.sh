#!/bin/bash
# Almanac first-use pages (flowers, yard, gotm) and the 2.6.46 data fixes: fresh SQLite install, then HTTP visits.
# Usage: tests/almanac_pages.sh [GAME_COPY_DIR] [PORT] [ROUTER]   (default: copies src/game to a temp dir; never writes a DB into src)
HERE=$(cd "$(dirname "$0")" && pwd)
GAME=${1:-}; PORT=${2:-8797}; ROUTER=${3:-$HERE/router.php}
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
F=0
chk() { if [ "$2" = "$3" ]; then echo "  ok   $1"; else echo "  FAIL $1 (got '$2', want '$3')"; F=1; fi; }
get 'book.php' >/dev/null
chk "3 pages exist with the keys" "$(db "SELECT COUNT(*) FROM encyclopedia_entries WHERE unlock_key IN ('flowers','yard','gotm')")" 3
UID_=$(db "SELECT id FROM users WHERE username='sprout'")
unl() { db "SELECT COUNT(*) FROM user_encyclopedia ue JOIN encyclopedia_entries e ON e.id=ue.entry_id WHERE ue.user_id=$UID_ AND e.unlock_key='$1'"; }
chk "flowers locked before use" "$(unl flowers)" 0
get 'inventory.php?tab=arrange' >/dev/null
chk "flowers unlocked by opening Arrange" "$(unl flowers)" 1
chk "yard locked before use" "$(unl yard)" 0
get 'yard.php' >/dev/null
chk "yard unlocked by the designer" "$(unl yard)" 1
get 'inventory.php?tab=arrange' >/dev/null; get 'yard.php' >/dev/null
chk "idempotent" "$(db "SELECT COUNT(*) FROM user_encyclopedia WHERE user_id=$UID_ AND entry_id IN (SELECT id FROM encyclopedia_entries WHERE unlock_key IN ('flowers','yard'))")" 2
chk "rerun adds no duplicate pages" "$(php -r '$p=new PDO("sqlite:'$GAME'/data/game.sqlite"); echo $p->query("SELECT COUNT(*) FROM encyclopedia_entries WHERE unlock_key IN (\"flowers\",\"yard\",\"gotm\")")->fetchColumn();')" 3
echo "== data fixes (almanac2646fix)"
dbx() { php -r '$p=new PDO("sqlite:'$GAME'/data/game.sqlite"); $p->exec($argv[1]);' "$1"; }
chk "fix marker set" "$(db "SELECT value FROM settings WHERE name='almanac2646fix'")" 1
chk "Pickled Onions sentence finished" "$(db "SELECT COUNT(*) FROM encyclopedia_entries WHERE body LIKE '%incomplete without.%'")" 0
chk "Pickled Onions item finished" "$(db "SELECT COUNT(*) FROM items WHERE description LIKE '%incomplete without them.%'")" 1
chk "Coir Chips page says what it is" "$(db "SELECT COUNT(*) FROM encyclopedia_entries WHERE title='Coir Chips' AND body LIKE 'Coir Fibre cut up into Wood Chips%'")" 1
chk "no soil improver text in real minutes" "$(db "SELECT COUNT(*) FROM encyclopedia_entries WHERE (body LIKE '%over 10 minutes%' OR body LIKE '%over 15 minutes%' OR body LIKE '%within 3 minutes%') AND (body LIKE '%fertility%' OR body LIKE '%nitrogen%' OR body LIKE '%phosphorus%' OR body LIKE '%potassium%')")" 0
chk "soil items in game hours" "$(db "SELECT COUNT(*) FROM items WHERE slug IN ('plain-compost','rich-loam','shell-meal') AND description LIKE '%game hours%'")" 3
chk "Silverfin: the blight" "$(db "SELECT COUNT(*) FROM encyclopedia_entries WHERE title='Silverfin the Page-Eater' AND body LIKE '%The blight made her hungry%'")" 1
chk "no weeping-clay hunger left" "$(db "SELECT COUNT(*) FROM encyclopedia_entries WHERE body LIKE '%weeping clay made her hungry%'")" 0
BARE=$(db "SELECT COUNT(*) FROM encyclopedia_entries WHERE chapter='Landmarks' AND body LIKE '%Boss lair.%' AND body NOT LIKE '%[b]Keeper:[/b]%'")
chk "no bare lair page with a keeper" "$BARE" 0
chk "Silverback lair names its keeper and level" "$(db "SELECT COUNT(*) FROM encyclopedia_entries WHERE title='Hollow of the Silverback Spider' AND body LIKE '%[b]Keeper:[/b] Silverback Spider, level %'")" 1
K1=$(db "SELECT COUNT(*) FROM encyclopedia_entries WHERE body LIKE '%[b]Keeper:[/b]%'")
dbx "DELETE FROM settings WHERE name='almanac2646fix'"; dbx "UPDATE items SET description = REPLACE(description, 'incomplete without them.', 'incomplete without.') WHERE slug='pickled-onions'"
get book.php >/dev/null
chk "rerun: marker back, truncation fixed once more" "$(db "SELECT value FROM settings WHERE name='almanac2646fix'") $(db "SELECT COUNT(*) FROM items WHERE description LIKE '%incomplete without them.%'")" "1 1"
chk "rerun: no second Keeper line" "$(db "SELECT COUNT(*) FROM encyclopedia_entries WHERE body LIKE '%[b]Keeper:[/b]%'")" "$K1"
chk "rerun: Coir Chips not prefixed twice" "$(db "SELECT COUNT(*) FROM encyclopedia_entries WHERE title='Coir Chips' AND body LIKE 'Coir Fibre cut up into Wood Chips, for when you have no logs. Coir Fibre%'")" 0
[ $F = 0 ] && echo "all ok" || echo "FAILED"
grep -c "PHP \(Warning\|Fatal\|Notice\)" $LOG | sed 's/^/php errors: /'
