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
echo "== data calls (almanac1114fix, Josh 2026-11-14)"
chk "1114 marker set" "$(db "SELECT value FROM settings WHERE name='almanac1114fix'")" 1
chk "Lotus Root is not a water lily" "$(db "SELECT COUNT(*) FROM encyclopedia_entries WHERE title='Lotus Root' AND body LIKE 'The rhizome of the sacred lotus%'")" 1
chk "Banana: the clump keeps giving (perennial)" "$(db "SELECT COUNT(*) FROM encyclopedia_entries WHERE title='Banana' AND body LIKE '%Each stem fruits once%' AND body NOT LIKE '%Each plant fruits once%'")" 1
chk "Cannonball Tree: born in the Amazon" "$(db "SELECT COUNT(*) FROM encyclopedia_entries WHERE title='Cannonball Tree' AND body LIKE '%Born in the Amazon%'")" 1
chk "Mossbottom Market lists all its shops" "$(db "SELECT COUNT(*) FROM encyclopedia_entries WHERE title='Mossbottom Market' AND body LIKE '%The Dye Pot%' AND body LIKE '%Petalpin%'")" 1
chk "no lair page is a bare 'Boss lair.'" "$(db "SELECT COUNT(*) FROM encyclopedia_entries WHERE body LIKE '%Boss lair.' || char(10) || '%' OR body LIKE '%Boss lair.' OR body LIKE '%Boss lair. ' || char(10) || '%'")" 0
chk "village pages are all different" "$(db "SELECT COUNT(*) - COUNT(DISTINCT body) FROM encyclopedia_entries WHERE chapter='Villages'")" 0
# an older world: put the old texts back, drop the marker, open the Almanac
dbx "UPDATE encyclopedia_entries SET body = REPLACE(body, 'The rhizome of the sacred lotus (no kin of the water lily), lacy', 'The rhizome of the water lily, lacy')"
dbx "UPDATE items SET description = REPLACE(description, 'Each stem fruits once, then a sucker from the same root takes its place, so the clump keeps giving.', 'Each plant fruits once, then new suckers take over.')"
dbx "UPDATE landmarks SET description = 'Boss lair.' WHERE name = 'Temple of the Tiger Moth'"
dbx "UPDATE encyclopedia_entries SET body = REPLACE(body, 'Boss lair. A great striped moth haunts the lamps of a jungle temple.', 'Boss lair.') WHERE title IN ('Temple of the Tiger Moth', 'Tiger Moth')"
dbx "UPDATE encyclopedia_entries SET body = substr(body, 1, instr(body, '. ') + 1) || (SELECT CASE l.landscape WHEN 'grassland' THEN 'Rolling grass taller than any gnome, and sky in every direction.' ELSE body END FROM locations l WHERE 'village:' || l.slug = encyclopedia_entries.unlock_key) WHERE chapter = 'Villages' AND unlock_key IN (SELECT 'village:' || slug FROM locations WHERE landscape = 'grassland')"
OLDV=$(db "SELECT COUNT(DISTINCT body) FROM encyclopedia_entries WHERE chapter='Villages'")
dbx "DELETE FROM settings WHERE name='almanac1114fix'"
get book.php >/dev/null
chk "upgrade: Lotus page fixed" "$(db "SELECT COUNT(*) FROM encyclopedia_entries WHERE title='Lotus Root' AND body LIKE 'The rhizome of the sacred lotus%'")" 1
chk "upgrade: Banana item fixed" "$(db "SELECT COUNT(*) FROM items WHERE slug='banana' AND description LIKE '%Each stem fruits once%'")" 1
chk "upgrade: Tiger Moth pages get their line back, once" "$(db "SELECT COUNT(*) FROM encyclopedia_entries WHERE title IN ('Temple of the Tiger Moth', 'Tiger Moth') AND body LIKE '%Boss lair. A great striped moth haunts the lamps of a jungle temple.%' AND body NOT LIKE '%temple. A great striped%'")" 2
chk "upgrade: village pages all different again (were $OLDV distinct)" "$(db "SELECT COUNT(*) - COUNT(DISTINCT body) FROM encyclopedia_entries WHERE chapter='Villages'")" 0
echo "== Silverback Spider lair at its zone level, 20 (Josh 2026-11-14)"
SB="(SELECT id FROM locations WHERE name='Hollow of the Silverback Spider')"
chk "fresh world: the lair route is Lv 20 (18-22)" "$(db "SELECT level || ' ' || min_level || '-' || max_level FROM routes WHERE a_id=$SB OR b_id=$SB")" "20 18-22"
chk "fresh world: the keeper is Lv 20" "$(db "SELECT level FROM creatures WHERE name='Silverback Spider'")" 20
chk "fresh world: its pages say level 20" "$(db "SELECT COUNT(*) FROM encyclopedia_entries WHERE (title='Silverback Spider' AND body LIKE '%[b]Level:[/b] 20%') OR (title='Hollow of the Silverback Spider' AND body LIKE '%Silverback Spider, level 20.%')")" 2
# an older world: put back the old Lv 30 values and replay the upgrade
dbx "UPDATE routes SET level=30, min_level=28, max_level=32 WHERE a_id=$SB OR b_id=$SB"
dbx "UPDATE creatures SET level=30, hp=228 WHERE name='Silverback Spider'"
dbx "UPDATE encyclopedia_entries SET body = REPLACE(REPLACE(body, '[b]Level:[/b] 20', '[b]Level:[/b] 30'), 'Silverback Spider, level 20.', 'Silverback Spider, level 30.') WHERE title IN ('Silverback Spider', 'Hollow of the Silverback Spider')"
OTHER=$(db "SELECT level FROM creatures WHERE name='Hurricane Crab'")
dbx "UPDATE settings SET value='0' WHERE name='db_version'"
get index.php >/dev/null; get book.php >/dev/null
chk "upgrade: route back to 20 (18-22)" "$(db "SELECT level || ' ' || min_level || '-' || max_level FROM routes WHERE a_id=$SB OR b_id=$SB")" "20 18-22"
chk "upgrade: keeper Lv 20 with Lv 20 stats" "$(db "SELECT level || ' ' || hp FROM creatures WHERE name='Silverback Spider'")" "20 156"
chk "upgrade: both pages say 20" "$(db "SELECT COUNT(*) FROM encyclopedia_entries WHERE (title='Silverback Spider' AND body LIKE '%[b]Level:[/b] 20%') OR (title='Hollow of the Silverback Spider' AND body LIKE '%Silverback Spider, level 20.%')")" 2
chk "upgrade: other lairs untouched" "$(db "SELECT level FROM creatures WHERE name='Hurricane Crab'")" "$OTHER"
[ $F = 0 ] && echo "all ok" || echo "FAILED"
grep -c "PHP \(Warning\|Fatal\|Notice\)" $LOG | sed 's/^/php errors: /'
