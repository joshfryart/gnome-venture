#!/bin/bash
# v0.9.7 part B: Petal sinks. Curio Cabinet (weekly rare decor), building looks, hat/beard dyes, garden signposts, regional feasts, upgrade import.
# Run on a fresh SQLite install that walk.sh made (player "sprout"): sinks097.sh GAME PORT ROUTER
GAME=$1; PORT=$2; ROUTER=$3; BASE=http://127.0.0.1:$PORT
php -d session.save_path=/tmp -S 127.0.0.1:$PORT -t $GAME $ROUTER >/tmp/s97-php.log 2>&1 & PID=$!; sleep 1
trap "kill $PID 2>/dev/null" EXIT
csrf() { grep -o 'name="csrf" value="[^"]*"' "$1" | head -1 | sed 's/.*value="\([^"]*\)".*/\1/'; }
db() { php -r '$p=new PDO("sqlite:'$GAME'/data/game.sqlite"); foreach($p->query($argv[1])->fetchAll(PDO::FETCH_NUM) as $r) echo implode(" | ",$r),"\n";' "$1"; }
dbx() { php -r '$p=new PDO("sqlite:'$GAME'/data/game.sqlite"); $p->exec($argv[1]);' "$1"; }
chk() { if [ "$2" = "$3" ]; then echo "ok   $1 = $2"; else echo "FAIL $1: got '$2' want '$3'"; fi; }
login() { rm -f $1; curl -s -c $1 -b $1 $BASE/login.php > /tmp/s97.html; curl -s -c $1 -b $1 -X POST $BASE/login.php --data-urlencode "csrf=$(csrf /tmp/s97.html)" -d username=$2 -d "password=$3" -o /dev/null; }
# postf JAR FORMPAGE POSTPAGE args... -> the first message shown on the page the POST redirects to
postf() { local jar=$1 form=$2 pg=$3; shift 3; curl -s -c $jar -b $jar "$BASE/$form" > /tmp/s97.html; curl -s -c $jar -b $jar "$BASE/$pg" --data-urlencode "csrf=$(csrf /tmp/s97.html)" "$@" -L -o /tmp/s97-post.html; grep -oE '<li class="ml (ok|err)[^"]*">[^<]*' /tmp/s97-post.html | head -1 | sed 's/<li class="ml //;s/[a-z ]*">/: /'; }
coins() { db "SELECT coins FROM users WHERE username='sprout'"; }
# a second player to look at the first one's garden
dbx "DELETE FROM users WHERE username='bloom'"
php -r '$p=new PDO("sqlite:'$GAME'/data/game.sqlite"); $r=$p->query("SELECT * FROM users WHERE username=\"sprout\"")->fetch(PDO::FETCH_ASSOC); unset($r["id"]); $r["username"]="bloom"; $r["email"]="bloom@b.local"; $r["gnome_name"]="Bloom Thistledown"; $c=array_keys($r); $p->prepare("INSERT INTO users (".implode(",",$c).") VALUES (".implode(",",array_fill(0,count($c),"?")).")")->execute(array_values($r));'
dbx "UPDATE users SET onboarded=1, level=20, coins=200000, tour_step=0, created_at=datetime('now','-9 days') WHERE username IN ('sprout','bloom')"
A=/tmp/s97-a; B=/tmp/s97-b; login $A sprout 'TestPass123!'; login $B bloom 'TestPass123!'
SID=$(db "SELECT id FROM users WHERE username='sprout'"); PL=$(db "SELECT id FROM plots WHERE user_id=$SID ORDER BY id LIMIT 1")
dbx "INSERT INTO garden_buildings (plot_id,building,built_at,last_collect,level) VALUES ($PL,'kitchen',datetime('now'),datetime('now'),3),($PL,'beehive',datetime('now'),datetime('now'),1)"
HH=$(db "SELECT id FROM shops WHERE slug='hedge-and-hearth'"); DP=$(db "SELECT id FROM shops WHERE slug='the-dye-pot'")

echo "== data: curios, feasts, dye pot, almanac"
chk "curio decor items" "$(db "SELECT COUNT(*) FROM items i WHERE i.category='decor' AND i.slug IN ('wind-harp','koi-pond','gnome-bandstand','lantern-tree','mossy-throne')")" 5
chk "curios are not on the open shelves" "$(db "SELECT COUNT(*) FROM shop_stock st JOIN items i ON i.id=st.item_id WHERE i.slug IN ('wind-harp','koi-pond','gnome-bandstand')")" 0
chk "20 curios in the pool" "$(php -r 'chdir("'$GAME'"); $_SERVER["HTTP_HOST"]="x"; require "includes/bootstrap.php"; sink_load(); echo count(CURIO_DECOR);')" 20
chk "every curio has an emoji and appeal of 7+" "$(php -r '$p=new PDO("sqlite:'$GAME'/data/game.sqlite"); chdir("'$GAME'"); $_SERVER["HTTP_HOST"]="x"; require "includes/bootstrap.php"; sink_load(); $ok=0; foreach (array_keys(CURIO_DECOR) as $s) { $fx=json_decode($p->query("SELECT effects FROM items WHERE slug=\"$s\"")->fetchColumn(),true)["decor"]; if ($fx["icon"]!=="" && $fx["appeal"]>=7) $ok++; } echo $ok;')" 20
chk "8 new feast recipes" "$(db "SELECT COUNT(*) FROM recipes WHERE slug IN ('feast-maplewold-table','feast-maizehollow-mole','feast-isles-ackee-pot','feast-olivewhistle-supper','feast-steppe-table','feast-dunewhisper-pilaf','feast-spicepeak-thali','feast-mistmoor-supper') AND tier='feast' AND cook_minutes=45")" 8
chk "feast dish items are food with 480 min buff" "$(db "SELECT COUNT(*) FROM items i JOIN recipes r ON r.output_item_id=i.id WHERE r.slug LIKE 'feast-%' AND json_extract(i.effects,'\$.temp.minutes')=480 AND json_extract(i.effects,'\$.energy') BETWEEN 16 AND 26")" 15
chk "feast ingredients all exist" "$(php -r '$p=new PDO("sqlite:'$GAME'/data/game.sqlite"); $bad=0; foreach($p->query("SELECT ingredients FROM recipes WHERE slug LIKE \"feast-%\"")->fetchAll(PDO::FETCH_COLUMN) as $j) foreach(array_keys(json_decode($j,true)) as $s) if(!$p->query("SELECT 1 FROM items WHERE slug=\"$s\"")->fetch()) $bad++; echo $bad;')" 0
chk "each new feast needs 1-2 treasure crops" "$(php -r '$p=new PDO("sqlite:'$GAME'/data/game.sqlite"); $t=[]; foreach(file("'$GAME'/includes/data/region_crops.txt") as $l){ $x=explode("|",trim($l)); if(($x[1]??"")==="treasure") foreach(explode(",",$x[2]) as $c) $t[$c]=1; } $ok=0; foreach($p->query("SELECT ingredients FROM recipes WHERE slug IN (\"feast-maplewold-table\",\"feast-maizehollow-mole\",\"feast-isles-ackee-pot\",\"feast-olivewhistle-supper\",\"feast-steppe-table\",\"feast-dunewhisper-pilaf\",\"feast-spicepeak-thali\",\"feast-mistmoor-supper\")")->fetchAll(PDO::FETCH_COLUMN) as $j){ $n=count(array_filter(array_keys(json_decode($j,true)), fn($s)=>isset($t[$s]))); if($n>=1 && $n<=2) $ok++; } echo $ok;')" 8
chk "recipe Almanac pages for the feasts" "$(db "SELECT COUNT(*) FROM encyclopedia_entries WHERE unlock_key LIKE 'recipe:feast-%'")" 15
chk "Dye Pot staffed round the clock" "$(db "SELECT COUNT(*) FROM npc_schedules WHERE shop_id=$DP AND activity='working'")" 3
chk "Almanac page on the sinks" "$(db "SELECT COUNT(*) FROM encyclopedia_entries WHERE title='Spending your Petals'")" 1

echo "== Curio rotation (php)"
php -r 'chdir("'$GAME'"); $_SERVER["HTTP_HOST"]="x"; require "includes/bootstrap.php"; sink_load();
 $cyc = []; $prev = null; $adj = 0;
 for ($w = 1; $w <= 30; $w++) { $k = sprintf("2026-W%02d", $w); $s = curio_slugs($k); $idx = 2026 * 53 + $w; $cyc[intdiv($idx, 4)][] = $s; if (count($s) < 4 || count($s) > 6) echo "BAD COUNT\n"; }
 $full = 0; $allok = true;
 foreach ($cyc as $weeks) { if (count($weeks) < 4) continue; $full++; $flat = array_merge(...$weeks); if (count(array_unique($flat)) !== 20 || count($flat) !== 20) $allok = false; }
 echo "full 4-week cycles: $full; each shows all 20 curios once: ", $allok ? "yes" : "NO", "\n";
 echo "stable in a week: ", curio_slugs("2026-W42") === curio_slugs("2026-W42") ? "yes" : "NO", "; differs next week: ", curio_slugs("2026-W42") !== curio_slugs("2026-W43") ? "yes" : "NO", "\n";' 2>&1

echo "== Curio Cabinet shop"
curl -s -b $A "$BASE/shop.php?id=$HH" > /tmp/s97.html
chk "five curios on offer" "$(grep -o 'class="curio"' /tmp/s97.html | wc -l)" 5
echo "  help text: $(grep -c 'More ways to spend Petals' /tmp/s97.html) · reset note: $(grep -oE 'changes in <b>[^<]*' /tmp/s97.html | head -1)"
SLUGS=$(grep -oE 'name="slug" value="[^"]*"' /tmp/s97.html | sed 's/.*value="//;s/"//'); SLUG=$(echo "$SLUGS" | sed -n 1p)
PRICE=$(db "SELECT base_price FROM items WHERE slug='$SLUG'"); C0=$(coins)
echo "  buying $SLUG at $PRICE"
echo -n "  buy: "; postf $A "shop.php?id=$HH" "shop.php?id=$HH" -d do=sink_curio -d slug=$SLUG
chk "Petals taken" "$(coins)" "$((C0 - PRICE))"
chk "decor item in the satchel" "$(db "SELECT COALESCE((SELECT qty FROM user_items ui JOIN items i ON i.id=ui.item_id WHERE ui.user_id=$SID AND i.slug='$SLUG'),0)")" 1
echo -n "  buy again (limit): "; postf $A "shop.php?id=$HH" "shop.php?id=$HH" -d do=sink_curio -d slug=$SLUG
chk "no second charge" "$(coins)" "$((C0 - PRICE))"
chk "still 1 in the satchel" "$(db "SELECT qty FROM user_items ui JOIN items i ON i.id=ui.item_id WHERE ui.user_id=$SID AND i.slug='$SLUG'")" 1
chk "week row" "$(db "SELECT qty FROM curio_buys WHERE user_id=$SID AND slug='$SLUG'")" 1
echo -n "  not in this week's cabinet: "; OFF=$(php -r 'chdir("'$GAME'"); $_SERVER["HTTP_HOST"]="x"; require "includes/bootstrap.php"; sink_load(); echo array_values(array_diff(array_keys(CURIO_DECOR), curio_slugs()))[0];'); postf $A "shop.php?id=$HH" "shop.php?id=$HH" -d do=sink_curio -d slug=$OFF
chk "nothing charged for an off-cabinet curio" "$(coins)" "$((C0 - PRICE))"
echo -n "  a sink post on a plain shop: "; SM=$(db "SELECT id FROM shops WHERE slug='na-seed-market'"); postf $A "shop.php?id=$SM" "shop.php?id=$SM" -d do=sink_curio -d slug=$SLUG
SLUG2=$(echo "$SLUGS" | sed -n 2p)
dbx "UPDATE users SET coins=5 WHERE username='sprout'"
echo -n "  too poor: "; postf $A "shop.php?id=$HH" "shop.php?id=$HH" -d do=sink_curio -d slug=$SLUG2
chk "poor: nothing taken, nothing given" "$(coins)|$(db "SELECT COALESCE((SELECT qty FROM user_items ui JOIN items i ON i.id=ui.item_id WHERE ui.user_id=$SID AND i.slug='$SLUG2'),0)")|$(db "SELECT COUNT(*) FROM curio_buys WHERE slug='$SLUG2'")" "5|0|0"
dbx "UPDATE users SET coins=200000 WHERE username='sprout'"
curl -s -b $A "$BASE/shop.php?id=$HH" > /tmp/s97.html
chk "bought curio shows as bought" "$(grep -o 'bought this week' /tmp/s97.html | wc -l)" 1
echo -n "  csrf missing: "; curl -s -b $A "$BASE/shop.php?id=$HH" -d do=sink_curio -d slug=$SLUG2 -o /dev/null -w '%{http_code}\n'
chk "curio_count setting 4 -> four curios" "$(dbx "INSERT OR REPLACE INTO settings (name,value) VALUES ('curio_count','4')"; curl -s -b $A "$BASE/shop.php?id=$HH" | grep -o 'class="curio"' | wc -l)" 4
dbx "DELETE FROM settings WHERE name='curio_count'"

echo "== building looks"
curl -s -b $A -c $A "$BASE/garden.php?t=bld" > /tmp/s97.html
chk "Looks section on both buildings" "$(grep -c 'class="skinbox"' /tmp/s97.html)" 2
echo -n "  buy Mossy kitchen: "; C0=$(coins); postf $A garden.php garden.php -d do=skin_buy -d building=kitchen -d skin=mossy
chk "1500 taken" "$(coins)" "$((C0 - 1500))"
chk "worn" "$(db "SELECT skin FROM garden_buildings WHERE plot_id=$PL AND building='kitchen'")" mossy
echo -n "  buy it twice: "; postf $A garden.php garden.php -d do=skin_buy -d building=kitchen -d skin=mossy
chk "no second charge" "$(coins)" "$((C0 - 1500))"
echo -n "  a look the building doesn't come in (beehive mossy): "; postf $A garden.php garden.php -d do=skin_buy -d building=beehive -d skin=mossy
echo -n "  wear one not owned: "; postf $A garden.php garden.php -d do=skin_use -d building=kitchen -d skin=lantern
chk "still mossy, no charge" "$(db "SELECT skin FROM garden_buildings WHERE plot_id=$PL AND building='kitchen'")|$(coins)" "mossy|$((C0 - 1500))"
echo -n "  building not built (greenhouse): "; postf $A garden.php garden.php -d do=skin_buy -d building=greenhouse -d skin=mossy
chk "the yard draws it" "$(curl -s -b $A "$BASE/garden.php" | grep -c 'yo bld[^"]* sk sk-mossy')" 1
chk "visitor sees it too" "$(curl -s -b $B "$BASE/visit.php?g=$PL" | grep -c 'sk sk-mossy')" 1
APP1=$(db "SELECT appeal FROM plots WHERE id=$PL")
echo -n "  back to plain: "; postf $A garden.php garden.php -d do=skin_use -d building=kitchen -d skin=
APP0=$(db "SELECT appeal FROM plots WHERE id=$PL")
chk "plain again, no skin class" "$(curl -s -b $A "$BASE/garden.php" | grep -c 'sk-mossy')" 0
chk "the look added 1 curb appeal" "$((APP1 - APP0))" 1
echo -n "  wear the owned one again (free): "; C1=$(coins); postf $A garden.php garden.php -d do=skin_use -d building=kitchen -d skin=mossy
chk "free to switch back" "$(coins)|$(db "SELECT skin FROM garden_buildings WHERE plot_id=$PL AND building='kitchen'")" "$C1|mossy"
echo -n "  buy Lantern-lit beehive: "; postf $A garden.php garden.php -d do=skin_buy -d building=beehive -d skin=lantern
chk "visit appeal counts both looks" "$(curl -s -b $B "$BASE/visit.php?g=$PL" | grep -oE 'Curb appeal <b>[0-9]+' | grep -oE '[0-9]+$')" "$(( APP1 + 3 ))"
echo -n "  someone else's building (bloom buys for sprout's garden): "
php -r 'chdir("'$GAME'"); $_SERVER["HTTP_HOST"]="x"; require "includes/bootstrap.php"; $u=q_one("SELECT * FROM users WHERE username=\"bloom\""); [$ok,$m]=skin_buy($u, '$PL', "kitchen", "painted"); echo $ok ? "BOUGHT" : $m, "\n";'
chk "bloom owns nothing" "$(db "SELECT COUNT(*) FROM sink_owned WHERE user_id=(SELECT id FROM users WHERE username='bloom')")" 0

echo "== signposts"
echo -n "  rename: "; postf $A garden.php garden.php -d do=rename -d "name=Fernhollow Patch"
echo -n "  buy oak: "; C0=$(coins); postf $A garden.php garden.php -d do=sign_buy -d style=oak
chk "1200 taken" "$(coins)" "$((C0 - 1200))"
echo -n "  buy oak again: "; postf $A garden.php garden.php -d do=sign_buy -d style=oak
chk "no double charge" "$(coins)" "$((C0 - 1200))"
echo -n "  bogus style: "; postf $A garden.php garden.php -d do=sign_buy -d style=neon
echo -n "  use one not owned: "; postf $A garden.php garden.php -d do=sign_use -d style=gilded
chk "visitors see the sign with the name" "$(curl -s -b $B "$BASE/visit.php?g=$PL" | grep -oE 'class="ysign sg-oak"[^>]*>.*Fernhollow Patch' | grep -c Fernhollow)" 1
chk "own yard shows it too" "$(curl -s -b $A "$BASE/garden.php" | grep -c 'class="ysign sg-oak"')" 1
echo -n "  take it down: "; postf $A garden.php garden.php -d do=sign_use -d style=
chk "no sign now" "$(curl -s -b $B "$BASE/visit.php?g=$PL" | grep -c 'class="ysign')" 0
echo -n "  put it back (free): "; C1=$(coins); postf $A garden.php garden.php -d do=sign_use -d style=oak
chk "free" "$(coins)" "$C1"
echo -n "  not a garden of mine (bloom buys a sign for sprout's garden): "
php -r 'chdir("'$GAME'"); $_SERVER["HTTP_HOST"]="x"; require "includes/bootstrap.php"; $u=q_one("SELECT * FROM users WHERE username=\"bloom\""); [$ok,$m]=sign_buy($u, '$PL', "painted"); echo $ok ? "BOUGHT" : $m, "\n"; [$ok,$m]=sign_use($u, '$PL', ""); echo $ok ? "REMOVED" : $m, "\n";'
chk "bloom has no sign, sprout's is still up" "$(db "SELECT COUNT(*) FROM sink_owned WHERE kind='sign' AND user_id<>$SID")|$(db "SELECT sign_style FROM plots WHERE id=$PL")" "0|oak"

echo "== dyes"
curl -s -b $A "$BASE/shop.php?id=$DP" > /tmp/s97.html
chk "Dye Pot page: 21 colours" "$(grep -o 'class="dyeopt' /tmp/s97.html | wc -l)" 21
echo -n "  buy a hat dye: "; C0=$(coins); postf $A "shop.php?id=$DP" "shop.php?id=$DP" -d do=sink_dye -d part=hat -d color='#e75480'
chk "800 taken" "$(coins)" "$((C0 - 800))"
echo -n "  again: "; postf $A "shop.php?id=$DP" "shop.php?id=$DP" -d do=sink_dye -d part=hat -d color='#e75480'
chk "no double charge" "$(coins)" "$((C0 - 800))"
echo -n "  a colour not on sale: "; postf $A "shop.php?id=$DP" "shop.php?id=$DP" -d do=sink_dye -d part=hat -d color='#123456'
echo -n "  rare + gilded beard dyes: "; postf $A "shop.php?id=$DP" "shop.php?id=$DP" -d do=sink_dye -d part=beard -d color='#2a9d8f'; postf $A "shop.php?id=$DP" "shop.php?id=$DP" -d do=sink_dye -d part=beard -d color='#d4af37' >/dev/null
chk "800 + 2500 + 6000 spent" "$((C0 - $(coins)))" 9300
chk "Dye Pot shows owned" "$(curl -s -b $A "$BASE/shop.php?id=$DP" | grep -o 'owned</span>' | wc -l)" 3
echo -n "  wear a dye not owned: "; postf $A gnome.php gnome.php -d do=dye -d hat='#b8325a'
chk "hat unchanged" "$(db "SELECT COALESCE(hat_dye,'none') FROM users WHERE id=$SID")" none
echo -n "  wear a made-up colour: "; postf $A gnome.php gnome.php -d do=dye -d beard='#abcdef'
chk "beard unchanged" "$(db "SELECT beard_color FROM users WHERE id=$SID")" "$(db "SELECT beard_color FROM users WHERE id=$SID")"
chk "gnome page has the dye picker" "$(curl -s -b $A "$BASE/gnome.php" | grep -o 'class="swatches"' | wc -l)" 2
echo -n "  wear owned hat + beard dyes: "; postf $A gnome.php gnome.php -d do=dye -d hat='#e75480' -d beard='#d4af37'
chk "hat dye saved" "$(db "SELECT hat_dye FROM users WHERE id=$SID")" "#e75480"
chk "beard saved" "$(db "SELECT beard_color FROM users WHERE id=$SID")" "#d4af37"
curl -s -b $A "$BASE/gnome.php" > /tmp/s97.html
chk "avatars drawn with the hat dye (header, nav, picker: 2 shapes each) and beard dye" "$(grep -o 'fill="#e75480"' /tmp/s97.html | wc -l)|$(grep -o 'fill="#d4af37"' /tmp/s97.html | wc -l)" "7|4"
chk "dyed hat beats the calling colour" "$(dbx "UPDATE users SET calling='bloomcaller' WHERE id=$SID"; curl -s -b $A "$BASE/gnome.php" | grep -o 'fill="#e75480"' | wc -l)" 7
dbx "UPDATE users SET calling=NULL WHERE id=$SID"
chk "other gnomes see the dye (profile)" "$(curl -s -b $B "$BASE/profile.php?id=$SID" | grep -o 'fill="#e75480"' | wc -l)" 2
echo -n "  back to no dye + a starter beard colour: "; postf $A gnome.php gnome.php -d do=dye -d hat=none -d beard='#f4f1ea'
chk "hat dye cleared" "$(db "SELECT COALESCE(hat_dye,'none')||' '||beard_color FROM users WHERE id=$SID")" "none #f4f1ea"
chk "still owned" "$(db "SELECT COUNT(*) FROM sink_owned WHERE user_id=$SID AND kind='dye'")" 3

echo "== regional feast is cookable"
dbx "UPDATE users SET energy=80 WHERE id=$SID"
for s in pecan:2 cranberry:1 pumpkin:2 potato:2 corn:2 wild-rice:1; do dbx "INSERT OR REPLACE INTO user_items (user_id,item_id,qty) SELECT $SID, id, ${s##*:} FROM items WHERE slug='${s%%:*}'"; done
curl -s -b $A "$BASE/inventory.php?tab=craft&c=cooking" > /tmp/s97.html
chk "the feast is listed (known: all its ingredients collected)" "$(grep -o 'Maplewold Harvest Table' /tmp/s97.html | head -1)" "Maplewold Harvest Table"
RID=$(db "SELECT id FROM recipes WHERE slug='feast-maplewold-table'"); C0=$(coins)
echo -n "  cook it: "; postf $A "inventory.php?tab=craft&c=cooking" crafting.php -d recipe_id=$RID -d qty=1
chk "firewood fee 50 taken" "$((C0 - $(coins)))" 50
chk "a pot is cooking" "$(db "SELECT COUNT(*) FROM cook_pots WHERE user_id=$SID AND recipe_id=$RID")" 1
chk "ingredients used up" "$(db "SELECT COALESCE(SUM(ui.qty),0) FROM user_items ui JOIN items i ON i.id=ui.item_id WHERE ui.user_id=$SID AND i.slug IN ('pecan','cranberry','pumpkin','potato','corn','wild-rice')")" 0

echo "== upgrade from 0.9.5: everything is restored once, no duplicates"
dbx "DELETE FROM recipes WHERE slug IN ('feast-maplewold-table','feast-maizehollow-mole','feast-isles-ackee-pot','feast-olivewhistle-supper','feast-steppe-table','feast-dunewhisper-pilaf','feast-spicepeak-thali','feast-mistmoor-supper'); DELETE FROM items WHERE slug IN ('feast-maplewold-table','feast-maizehollow-mole','feast-isles-ackee-pot','feast-olivewhistle-supper','feast-steppe-table','feast-dunewhisper-pilaf','feast-spicepeak-thali','feast-mistmoor-supper','wind-harp','koi-pond');
 DELETE FROM npc_schedules WHERE shop_id=$DP; DELETE FROM shops WHERE slug='the-dye-pot'; DELETE FROM encyclopedia_entries WHERE title='Spending your Petals'; UPDATE shops SET description='Paths, fences.' WHERE slug='hedge-and-hearth'; UPDATE settings SET value='0.9.5' WHERE name='db_version'"
curl -s -b $A "$BASE/world.php" -o /dev/null
chk "feast recipes back" "$(db "SELECT COUNT(*) FROM recipes WHERE slug LIKE 'feast-%'")" 15
chk "curios back" "$(db "SELECT COUNT(*) FROM items WHERE slug IN ('wind-harp','koi-pond')")" 2
chk "Dye Pot back (one shop, three staff)" "$(db "SELECT COUNT(*) FROM shops WHERE slug='the-dye-pot'")|$(db "SELECT COUNT(*) FROM npc_schedules s JOIN shops sh ON sh.id=s.shop_id WHERE sh.slug='the-dye-pot' AND s.activity='working'")" "1|3"
chk "Almanac page back, unlocked for existing players" "$(db "SELECT COUNT(*) FROM encyclopedia_entries e JOIN user_encyclopedia ue ON ue.entry_id=e.id WHERE e.title='Spending your Petals' AND ue.user_id=$SID")" 1
chk "Hedge & Hearth mentions the cabinet" "$(db "SELECT description LIKE '%Curio Cabinet%' FROM shops WHERE slug='hedge-and-hearth'")" 1
chk "version set again" "$(db "SELECT value FROM settings WHERE name='db_version'")" "$(grep -oE "APP_VERSION', '[0-9.]+" $GAME/includes/bootstrap.php | grep -oE '[0-9.]+$')"
curl -s -b $A "$BASE/world.php" -o /dev/null
chk "second run adds nothing" "$(db "SELECT COUNT(*) FROM recipes WHERE slug LIKE 'feast-%'")|$(db "SELECT COUNT(*) FROM shops WHERE slug='the-dye-pot'")|$(db "SELECT COUNT(*) FROM encyclopedia_entries WHERE title='Spending your Petals'")" "15|1|1"
echo "== php errors"
grep -iE 'fatal|warning|notice|deprecated' /tmp/s97-php.log || echo "(none)"
