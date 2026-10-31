GAME=$1; PORT=$2; ROUTER=$3; BASE=http://127.0.0.1:$PORT
T=${TMPDIR:-/tmp}   # v2.3.7: scratch files under TMPDIR so parallel runs do not share /tmp/c.html
php -d session.save_path=$T -S 127.0.0.1:$PORT -t $GAME $ROUTER >$T/craft-php.log 2>&1 & PID=$!; sleep 1
trap "kill $PID 2>/dev/null" EXIT
C=$T/craft-ck; rm -f $C
csrf() { grep -o 'name="csrf" value="[^"]*"' "$1" | head -1 | sed 's/.*value="\([^"]*\)".*/\1/'; }
db() { php -r '$p=new PDO("sqlite:'$GAME'/data/game.sqlite"); foreach($p->query($argv[1])->fetchAll(PDO::FETCH_NUM) as $r) echo implode(" | ",$r),"\n";' "$1"; }
dbx() { php -r '$p=new PDO("sqlite:'$GAME'/data/game.sqlite"); $p->exec($argv[1]);' "$1"; }
page() { curl -s -c $C -b $C "$BASE/$1" > $T/c.html; }
make() { page "inventory.php?tab=craft&c=$1"; curl -s -c $C -b $C -X POST "$BASE/crafting.php?c=$1" --data-urlencode "csrf=$(csrf $T/c.html)" -d recipe_id=$2 -o /dev/null; page "inventory.php?tab=craft&c=$1"; grep -oE '<li class="ml (ok|err)[^"]*">[^<]*' $T/c.html | head -1 | sed 's/<li class="ml //'; }   # newest line of the message log   # v0.9.4: crafting is a tab of the satchel; crafting.php only takes the POST
collect() { dbx "UPDATE cook_pots SET ready_at=datetime('now','-1 minute') WHERE collected_at IS NULL"; page "inventory.php?tab=craft&c=cooking"; curl -s -c $C -b $C -X POST "$BASE/crafting.php?c=cooking" --data-urlencode "csrf=$(csrf $T/c.html)" -d do=collect_all -o /dev/null; page "inventory.php?tab=craft&c=cooking"; grep -oE '<li class="ml (ok|err)[^"]*">[^<]*' $T/c.html | head -1 | sed 's/<li class="ml //'; }   # v0.9.4: cooking waits in a pot
give() { dbx "INSERT OR REPLACE INTO user_items (user_id,item_id,qty) SELECT $UID_, id, $2 FROM items WHERE slug='$1'"; }
page login.php; curl -s -c $C -b $C -X POST $BASE/login.php --data-urlencode "csrf=$(csrf $T/c.html)" -d username=sprout -d 'password=TestPass123!' -o /dev/null
UID_=$(db "SELECT id FROM users WHERE username='sprout'")
echo "== recipe counts by category"; db "SELECT category, COUNT(*), SUM(slug IS NULL) FROM recipes GROUP BY category"
db "SELECT 'recipe almanac pages: '||COUNT(*) FROM encyclopedia_entries WHERE chapter='Recipes'"
echo "kitchen.php -> $(curl -s -b $C -o /dev/null -w '%{http_code} %{redirect_url}' $BASE/kitchen.php)"
for c in cooking tools garden; do page "inventory.php?tab=craft&c=$c&show=unknown"; echo "$c: unknown cards=$(grep -c 'class="shpill unk' $T/c.html) ready+missing chips: $(grep -oE '(Ready|Missing|Unknown|Not yet)[^<(]*\([0-9]+\)' $T/c.html | tr '\n' ' ')"; done
echo "== garden supplies, no building: give 3 bladderwrack"
give bladderwrack 3; dbx "UPDATE users SET energy=100 WHERE id=$UID_"
R=$(db "SELECT id FROM recipes WHERE slug='seaweed-compost'")
make garden $R
db "SELECT 'compost now '||ui.qty FROM user_items ui JOIN items i ON i.id=ui.item_id WHERE ui.user_id=$UID_ AND i.slug='plain-compost'"
db "SELECT 'bladderwrack left '||COALESCE((SELECT qty FROM user_items ui JOIN items i ON i.id=ui.item_id WHERE ui.user_id=$UID_ AND i.slug='bladderwrack'),0)"
echo "-- again with none left (still known)"; make garden $R
page "inventory.php?tab=craft&c=garden&show=missing"; echo "seaweed still known: $(grep -c 'Seaweed Compost' $T/c.html)"
echo "== cooking without kitchen"
give chanterelle 2; give wheat 1; R2=$(db "SELECT id FROM recipes WHERE slug='mushroom-toast'")
make cooking $R2
echo "-- build kitchen"; P=$(db "SELECT id FROM plots WHERE user_id=$UID_ LIMIT 1")
dbx "INSERT INTO garden_buildings (plot_id,building,built_at,last_collect) VALUES ($P,'kitchen',datetime('now'),datetime('now'))"
make cooking $R2
echo "-- timer not up: collect says so; then ready"; page "inventory.php?tab=craft&c=cooking"; curl -s -c $C -b $C -X POST "$BASE/crafting.php?c=cooking" --data-urlencode "csrf=$(csrf $T/c.html)" -d do=collect_all -o /dev/null; page "inventory.php?tab=craft&c=cooking"; grep -oE '<li class="ml (ok|err)[^"]*">[^<]*' $T/c.html | head -1
collect
db "SELECT 'toast: '||ui.qty FROM user_items ui JOIN items i ON i.id=ui.item_id WHERE ui.user_id=$UID_ AND i.slug='mushroom-toast'"
echo "== masterwork tool"
give steel-spade 1; give bog-iron 2; give flint 4; R3=$(db "SELECT id FROM recipes WHERE slug='masterwork-wheel-hoe'")
make tools $R3
dbx "INSERT INTO garden_buildings (plot_id,building,built_at,last_collect) VALUES ($P,'tool_shed',datetime('now'),datetime('now'))"
make tools $R3
db "SELECT 'wheel hoe: '||COALESCE((SELECT qty FROM user_items ui JOIN items i ON i.id=ui.item_id WHERE ui.user_id=$UID_ AND i.slug='masterwork-wheel-hoe'),0)||'  spade: '||COALESCE((SELECT qty FROM user_items ui JOIN items i ON i.id=ui.item_id WHERE ui.user_id=$UID_ AND i.slug='steel-spade'),0)"
echo "== unknown recipe refused"; R4=$(db "SELECT id FROM recipes WHERE slug='morel-risotto'"); make cooking $R4
echo "== bad csrf"; curl -s -b $C -X POST "$BASE/crafting.php" -d csrf=x -d recipe_id=$R -o /dev/null -w '%{http_code}\n'
db "SELECT 'user_recipes: '||COUNT(*)||' made '||SUM(made) FROM user_recipes WHERE user_id=$UID_"
page "book.php?ch=Recipes"; echo "almanac recipes tab: $(grep -oE 'Recipes <small>[^<]*' $T/c.html)"
echo "== area map (2.3.3)"
page "inventory.php?tab=craft"; N=$(grep -c 'class="cmap-card' $T/c.html); echo "landing cards: $N"; [ "$N" = 7 ] || echo "FAIL landing shows $N of 7 area cards"
for k in cooking pantry tools garden potions building decor; do grep -q "href=\"[^\"]*tab=craft&amp;c=$k\"" $T/c.html || echo "FAIL no link to area $k"; done
for k in cooking pantry tools garden potions building decor; do page "inventory.php?tab=craft&c=$k"; H=$(grep -c 'class="cmap-hs ' $T/c.html); [ "$H" = 5 ] || echo "FAIL $k scene has $H of 5 tappable objects"; grep -q 'aria-current="page"' $T/c.html || echo "FAIL $k strip has no current area"; grep -q 'All areas' $T/c.html || echo "FAIL $k has no All areas link"; grep -q 'name="c" data-autosubmit' $T/c.html && echo "FAIL $k still has the category select"; done
page "inventory.php?tab=craft&c=cooking&q=soup"; echo "soup search: $(grep -c 'shpill' $T/c.html) pills"
echo "-- 2.3.7 per-object recipe tags (coverage: tests/craft_tags.php)"; php "$(dirname "$0")/craft_tags.php" "$GAME" | tail -1
pills() { grep -o 'class="shpill[ "]' $T/c.html | wc -l; }
page "inventory.php?tab=craft&c=garden"; grep -q 'href="[^"]*c=garden&amp;o=seeds#shelves"' $T/c.html || echo "FAIL garden seed trays do not link to ?o=seeds"; grep -q 'q=meal' $T/c.html && echo "FAIL garden still searches meal"
for x in garden:seeds:6 tools:anvil:7 building:stones:3 decor:path:4 cooking:oven:15; do IFS=: read a o want <<<"$x"; page "inventory.php?tab=craft&c=$a&o=$o"; n=$(pills); grep -q 'class="cmap-on"' $T/c.html || echo "FAIL $a/$o has no Showing line"; grep -q 'aria-current="true"' $T/c.html || echo "FAIL $a/$o hotspot not marked current"; [ "$n" = "$want" ] && echo "$a/$o: $n recipes" || echo "FAIL $a/$o shows $n recipes, want $want"; done
page "inventory.php?tab=craft&c=garden&o=nope"; grep -q 'class="cmap-on"' $T/c.html && echo "FAIL unknown object still filters"
page "inventory.php?tab=craft&c=pantry&o=cheese"; n=$(grep -o 'class="p2row ' $T/c.html | wc -l); grep -q 'Hanging cheese' $T/c.html && grep -q 'class="cmap-on"' $T/c.html && [ "$n" = 13 ] && echo "pantry/cheese: $n preserves" || echo "FAIL pantry/cheese shows $n preserves, want 13"
page "inventory.php?tab=craft&c=pantry&o=kraut"; grep -q 'Sauerkraut\|???' $T/c.html && echo "pantry/kraut: $(grep -o 'class="p2row ' $T/c.html | wc -l) preserves" || echo "FAIL pantry/kraut empty"
echo "-- landing badges: one recipe pass"; give bladderwrack 6; page "inventory.php?tab=craft"; grep -oE 'cmap-badge[^>]*>[^<]*ready' $T/c.html | head -3 | sed 's/.*>/badge: /'; grep -q 'ready</span>' $T/c.html || grep -q '[0-9] ready' $T/c.html || echo "FAIL no ready badge with 6 bladderwrack"
echo "== Alchemy Table potions"
N=$(db "SELECT COUNT(*) FROM recipes WHERE category='potions'"); echo "potion recipes: $N"; [ "$N" = 8 ] || echo "FAIL $N of 8 potion recipes"
give healing-potion 2; give pine-resin 1; R6=$(db "SELECT id FROM recipes WHERE slug='strong-healing-potion'")
page "inventory.php?tab=craft&c=potions"   # discovers it
echo "strong potion: $(make potions $R6)"
S=$(db "SELECT COALESCE((SELECT qty FROM user_items ui JOIN items i ON i.id=ui.item_id WHERE ui.user_id=$UID_ AND i.slug='strong-healing-potion'),0)||'/'||COALESCE((SELECT qty FROM user_items ui JOIN items i ON i.id=ui.item_id WHERE ui.user_id=$UID_ AND i.slug='healing-potion'),0)")
[ "$S" = "1/0" ] || echo "FAIL strong/healing after make: $S (want 1/0)"
give bladderwrack 2; give meadowsweet 1; give sphagnum 1; R7=$(db "SELECT id FROM recipes WHERE slug='garden-tonic'"); page "inventory.php?tab=craft&c=potions"; make potions $R7 >/dev/null
TQ=$(db "SELECT COALESCE((SELECT qty FROM user_items ui JOIN items i ON i.id=ui.item_id WHERE ui.user_id=$UID_ AND i.slug='garden-tonic'),0)"); [ "$TQ" = 2 ] || echo "FAIL garden tonic makes $TQ (want 2)"
page "inventory.php?tab=craft&c=potions"; for w in draught tonic healing elixir brew; do grep -q "c=potions&amp;q=$w#shelves" $T/c.html || echo "FAIL potions scene has no q=$w object"; done
page "inventory.php?tab=craft&c=potions&q=healing"; echo "healing search: $(grep -c 'shpill' $T/c.html) pills"
echo "-- player uses: Satchel Drink for a healing tier, My Gnome Potions box, tonic pointer"
dbx "UPDATE users SET hp=1, hp_at=datetime('now') WHERE id=$UID_"
page "inventory.php"; grep -q 'Drink (+75% health)' $T/c.html || echo "FAIL satchel has no Drink for the Strong Healing Potion"
grep -q 'Pour on a garden square' $T/c.html || echo "FAIL satchel has no Garden Tonic pointer"
SID=$(db "SELECT id FROM items WHERE slug='strong-healing-potion'")
curl -s -c $C -b $C -X POST "$BASE/inventory.php" --data-urlencode "csrf=$(csrf $T/c.html)" -d do=drink_heal -d item_id=$SID -o /dev/null
HP=$(db "SELECT COALESCE(hp,'full') FROM users WHERE id=$UID_"); [ "$HP" != 1 ] && echo "satchel drink healed: hp $HP" || echo "FAIL satchel Drink did not heal (hp $HP)"
give lucky-draught 1; page "gnome.php"; grep -q 'aria-label="Potions"' $T/c.html || echo "FAIL My Gnome has no Potions box ($(grep -o '<title>[^<]*' $T/c.html), $(grep -c hpcard $T/c.html) cards, $(wc -c < $T/c.html) bytes)"
LID=$(db "SELECT id FROM items WHERE slug='lucky-draught'")
curl -s -c $C -b $C -X POST "$BASE/gnome.php" --data-urlencode "csrf=$(csrf $T/c.html)" -d do=drink -d item=$LID -o /dev/null
B=$(db "SELECT buff FROM users WHERE id=$UID_"); [ "$B" = '{"luck":6}' ] && echo "My Gnome drink: buff $B" || echo "FAIL My Gnome drink buff: $B"
php "$(dirname "$0")/alchemy.php" "$GAME" || echo "FAIL alchemy.php"
echo "== php errors"; grep -iE 'fatal|warning|notice|deprecated' $T/craft-php.log || echo "(none)"
