#!/bin/bash
# Fight on the animated stage (setting fight_scene): off = popover as before; on = #fightscene inline, events handed over once, page runs in a browser.
# Usage: tests/fight_scene.sh [GAME_COPY_DIR] [PORT] [ROUTER]   (default: copies src/game to a temp dir; never writes a DB into src)
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
db "UPDATE users SET energy=100 WHERE username='sprout'" >/dev/null
php -d display_errors=1 "$HERE/advforce.php" "$GAME" fight 2>&1 | tail -1
php -r '$p=new PDO("sqlite:'$GAME'/data/game.sqlite"); $r=$p->query("SELECT id,encounter FROM expeditions ORDER BY id DESC LIMIT 1")->fetch(); $e=json_decode($r["encounter"],true); $e["hp"]=$e["max"]=900; $e["fhp"]=900; $p->prepare("UPDATE expeditions SET encounter=?, hp=max_hp WHERE id=?")->execute([json_encode($e),$r["id"]]);'   # a foe that survives the test's hits
get adventure.php >/dev/null
echo "off: trailpop=$(grep -c 'id="trailpop"' $H) scene=$(grep -c 'id="fightscene"' $H)"
[ "$(grep -c 'id="fightscene"' $H)" = 0 ] || echo "FAIL scene shown while off"
db "INSERT OR REPLACE INTO settings (name,value) VALUES ('fight_scene','1')" >/dev/null
get adventure.php >/dev/null
grep -q 'id="fightscene"' $H || echo "FAIL no #fightscene when on"
grep -q 'id="trailpop"' $H && echo "FAIL popover still there"
grep -q 'class="fightbtns' $H || echo "FAIL buttons missing"
grep -q 'assets/fightengine.js' $H || echo "FAIL engine script missing"
grep -q 'data-fight=' $H || echo "FAIL no data"
post adventure.php -d do=attack >/dev/null
get adventure.php >/dev/null
EV=$(grep -o 'data-fight="[^"]*"' $H | head -1 | sed 's/^data-fight="//;s/"$//' | php -r 'echo html_entity_decode(stream_get_contents(STDIN));' | php -r '$d=json_decode(stream_get_contents(STDIN),true); echo count($d["events"]??[])," ",json_encode(array_column($d["events"]??[],"move"));')
echo "events after attack: $EV"
[ "${EV%% *}" -ge 1 ] 2>/dev/null || echo "FAIL no events after attack"
get adventure.php >/dev/null
grep -o 'data-fight="[^"]*"' $H | head -1 | grep -q 'events&quot;:\[\]' || echo "FAIL events shown twice"
encj() { db "SELECT encounter FROM expeditions ORDER BY id DESC LIMIT 1" | php -r '$e=json_decode(trim(stream_get_contents(STDIN)),true); echo (int)($e["hat"]??0)," ",(int)($e["hatd"]??0);'; }
exphp() { db "SELECT hp FROM expeditions ORDER BY id DESC LIMIT 1"; }
echo "== hat"
get adventure.php >/dev/null; grep -q 'class="hatform"' $H && echo "FAIL hat form with no hat"
db "UPDATE expeditions SET hp=6 WHERE id=(SELECT MAX(id) FROM expeditions)" >/dev/null
for i in 1 2 3 4 5 6 7 8; do get adventure.php >/dev/null; post adventure.php -d do=attack >/dev/null; [ "$(encj | cut -d' ' -f1)" = 1 ] && break; done
[ "$(encj)" = "1 0" ] || echo "FAIL hat flag not set under 25% (got $(encj))"
get adventure.php >/dev/null
grep -q 'class="hatform"' $H || echo "FAIL no hat form while flagged"
grep -q 'pop&quot;:true' $H || echo "FAIL pop event missing"
db "UPDATE expeditions SET hp=10 WHERE id=(SELECT MAX(id) FROM expeditions)" >/dev/null
post adventure.php -d do=hat >/dev/null
[ "$(exphp)" = 15 ] || echo "FAIL hat heal: hp $(exphp), want 15"
[ "$(encj)" = "0 1" ] || echo "FAIL hat flag not spent ($(encj))"
post adventure.php -d do=hat >/dev/null
[ "$(exphp)" = 15 ] || echo "FAIL hat healed twice: hp $(exphp)"
if command -v node >/dev/null && [ -z "$NOBROWSER" ]; then node "$HERE/fight_scene.js" "$BASE" "$SHOT" || echo "FAIL browser"; fi
echo "== php errors"
grep -iE 'fatal|warning|notice|deprecated' $LOG && echo "FAIL php errors" || echo "(none)"
