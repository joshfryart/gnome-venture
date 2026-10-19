GAME=$1; PORT=$2; ROUTER=$3; BASE=http://127.0.0.1:$PORT
php -d session.save_path=/tmp -S 127.0.0.1:$PORT -t $GAME $ROUTER >/tmp/craft-php.log 2>&1 & PID=$!; sleep 1
trap "kill $PID 2>/dev/null" EXIT
C=/tmp/craft-ck; rm -f $C
csrf() { grep -o 'name="csrf" value="[^"]*"' "$1" | head -1 | sed 's/.*value="\([^"]*\)".*/\1/'; }
db() { php -r '$p=new PDO("sqlite:'$GAME'/data/game.sqlite"); foreach($p->query($argv[1])->fetchAll(PDO::FETCH_NUM) as $r) echo implode(" | ",$r),"\n";' "$1"; }
dbx() { php -r '$p=new PDO("sqlite:'$GAME'/data/game.sqlite"); $p->exec($argv[1]);' "$1"; }
page() { curl -s -c $C -b $C "$BASE/$1" > /tmp/c.html; }
make() { page "inventory.php?tab=craft&c=$1"; curl -s -c $C -b $C -X POST "$BASE/crafting.php?c=$1" --data-urlencode "csrf=$(csrf /tmp/c.html)" -d recipe_id=$2 -o /dev/null; page "inventory.php?tab=craft&c=$1"; grep -oE '<li class="ml (ok|err)[^"]*">[^<]*' /tmp/c.html | head -1 | sed 's/<li class="ml //'; }   # newest line of the message log   # v0.9.4: crafting is a tab of the satchel; crafting.php only takes the POST
collect() { dbx "UPDATE cook_pots SET ready_at=datetime('now','-1 minute') WHERE collected_at IS NULL"; page "inventory.php?tab=craft&c=cooking"; curl -s -c $C -b $C -X POST "$BASE/crafting.php?c=cooking" --data-urlencode "csrf=$(csrf /tmp/c.html)" -d do=collect_all -o /dev/null; page "inventory.php?tab=craft&c=cooking"; grep -oE '<li class="ml (ok|err)[^"]*">[^<]*' /tmp/c.html | head -1 | sed 's/<li class="ml //'; }   # v0.9.4: cooking waits in a pot
give() { dbx "INSERT OR REPLACE INTO user_items (user_id,item_id,qty) SELECT $UID_, id, $2 FROM items WHERE slug='$1'"; }
page login.php; curl -s -c $C -b $C -X POST $BASE/login.php --data-urlencode "csrf=$(csrf /tmp/c.html)" -d username=sprout -d 'password=TestPass123!' -o /dev/null
UID_=$(db "SELECT id FROM users WHERE username='sprout'")
echo "== recipe counts by category"; db "SELECT category, COUNT(*), SUM(slug IS NULL) FROM recipes GROUP BY category"
db "SELECT 'recipe almanac pages: '||COUNT(*) FROM encyclopedia_entries WHERE chapter='Recipes'"
echo "kitchen.php -> $(curl -s -b $C -o /dev/null -w '%{http_code} %{redirect_url}' $BASE/kitchen.php)"
for c in cooking tools garden; do page "inventory.php?tab=craft&c=$c&show=unknown"; echo "$c: unknown cards=$(grep -c 'class="ccard unk"' /tmp/c.html) ready+missing chips: $(grep -oE '(Ready|Missing|Unknown|Not yet)[^<(]*\([0-9]+\)' /tmp/c.html | tr '\n' ' ')"; done
echo "== garden supplies, no building: give 3 bladderwrack"
give bladderwrack 3; dbx "UPDATE users SET energy=100 WHERE id=$UID_"
R=$(db "SELECT id FROM recipes WHERE slug='seaweed-compost'")
make garden $R
db "SELECT 'compost now '||ui.qty FROM user_items ui JOIN items i ON i.id=ui.item_id WHERE ui.user_id=$UID_ AND i.slug='plain-compost'"
db "SELECT 'bladderwrack left '||COALESCE((SELECT qty FROM user_items ui JOIN items i ON i.id=ui.item_id WHERE ui.user_id=$UID_ AND i.slug='bladderwrack'),0)"
echo "-- again with none left (still known)"; make garden $R
page "inventory.php?tab=craft&c=garden&show=missing"; echo "seaweed still known: $(grep -c 'Seaweed Compost' /tmp/c.html)"
echo "== cooking without kitchen"
give chanterelle 2; give wheat 1; R2=$(db "SELECT id FROM recipes WHERE slug='mushroom-toast'")
make cooking $R2
echo "-- build kitchen"; P=$(db "SELECT id FROM plots WHERE user_id=$UID_ LIMIT 1")
dbx "INSERT INTO garden_buildings (plot_id,building,built_at,last_collect) VALUES ($P,'kitchen',datetime('now'),datetime('now'))"
make cooking $R2
echo "-- timer not up: collect says so; then ready"; page "inventory.php?tab=craft&c=cooking"; curl -s -c $C -b $C -X POST "$BASE/crafting.php?c=cooking" --data-urlencode "csrf=$(csrf /tmp/c.html)" -d do=collect_all -o /dev/null; page "inventory.php?tab=craft&c=cooking"; grep -oE '<li class="ml (ok|err)[^"]*">[^<]*' /tmp/c.html | head -1
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
page "book.php?ch=Recipes"; echo "almanac recipes tab: $(grep -oE 'Recipes <small>[^<]*' /tmp/c.html)"
echo "== php errors"; grep -iE 'fatal|warning|notice|deprecated' /tmp/craft-php.log || echo "(none)"
