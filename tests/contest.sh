GAME=$1; PORT=$2; ROUTER=$3; BASE=http://127.0.0.1:$PORT
php -d session.save_path=/tmp -S 127.0.0.1:$PORT -t $GAME $ROUTER >/tmp/ct-php.log 2>&1 & PID=$!; sleep 1
trap "kill $PID 2>/dev/null" EXIT
csrf() { grep -o 'name="csrf" value="[^"]*"' "$1" | head -1 | sed 's/.*value="\([^"]*\)".*/\1/'; }
db() { php -r '$p=new PDO("sqlite:'$GAME'/data/game.sqlite"); foreach($p->query($argv[1])->fetchAll(PDO::FETCH_NUM) as $r) echo implode(" | ",$r),"\n";' "$1"; }
dbx() { php -r '$p=new PDO("sqlite:'$GAME'/data/game.sqlite"); $p->exec($argv[1]);' "$1"; }
login() { rm -f $1; curl -s -c $1 -b $1 $BASE/login.php > /tmp/k.html; curl -s -c $1 -b $1 -X POST $BASE/login.php --data-urlencode "csrf=$(csrf /tmp/k.html)" -d username=$2 -d "password=$3" -o /dev/null; }
A=/tmp/ka-ck; T=/tmp/kt-ck; login $A sprout 'TestPass123!'; login $T admin TestPassword123
wp() { curl -s -c $T -b $T "$BASE/$1" > /tmp/w.html; curl -s -c $T -b $T -X POST "$BASE/welcome.php" --data-urlencode "csrf=$(csrf /tmp/w.html)" "${@:2}" -o /dev/null; }
RID=$(db "SELECT id FROM regions WHERE code='NWE'"); VID=$(db "SELECT l.id FROM locations l JOIN zones z ON z.id=l.zone_id WHERE z.region_id=$RID AND z.zone_num=1 AND l.kind='village' ORDER BY l.sort_order LIMIT 1")
wp welcome.php -d do=gnome -d "gnome_name=Taker Tom" -d 'hat=#2e7d4f' -d 'beard=#b5651d'; wp 'welcome.php?step=home' -d do=home -d region_id=$RID; wp 'welcome.php?step=place' -d do=place -d village_id=$VID; wp 'welcome.php?step=garden' -d do=finish -d 'garden_name=Tom Patch'
pg() { local c=$1 page=$2; shift 2; curl -s -c $c -b $c "$BASE/$page" > /tmp/k0.html; curl -s -c $c -b $c -X POST "$BASE/$page" --data-urlencode "csrf=$(csrf /tmp/k0.html)" "$@" -o /dev/null; curl -s -c $c -b $c "$BASE/$page" > /tmp/k.html; grep -oE 'flash (ok|err)">[^<]*' /tmp/k.html | head -3; }
SP=$(db "SELECT id FROM users WHERE username='sprout'"); AD=$(db "SELECT id FROM users WHERE username='admin'"); P=$(db "SELECT id FROM plots WHERE user_id=$SP LIMIT 1")
curl -s -b $A $BASE/show.php > /tmp/k.html; CROP=$(grep -oE 'This week: [^<]*' /tmp/k.html); echo "== $CROP"
SLUG=$(php -r '$_SERVER["SCRIPT_NAME"]="/x.php"; require "'$GAME'/includes/bootstrap.php"; require "'$GAME'/includes/garden_logic.php"; require_once "'$GAME'/includes/contests.php"; echo show_crop();' 2>/dev/null | tail -1)
PL=$(db "SELECT id FROM plants WHERE slug='$SLUG'"); echo "crop slug $SLUG plant $PL"
for x in 0 1; do dbx "UPDATE plot_tiles SET tilled=1, method='till', plant_id=$PL, planted_at=datetime('now','-1 day'), growth_seconds=99999999, growth_updated_at=datetime('now'), fertility=$((40 + x*50)), soil_life=$((10 + x*60)) WHERE plot_id=$P AND x=$x AND y=0"; done
dbx "UPDATE users SET energy=100 WHERE id=$SP"
for x in 0 1; do curl -s -c $A -b $A "$BASE/garden.php?sel=$x-0" > /tmp/k0.html; curl -s -c $A -b $A -X POST "$BASE/garden.php" --data-urlencode "csrf=$(csrf /tmp/k0.html)" -d do=harvest -d x=$x -d y=0 -d reach=one -o /dev/null; curl -s -b $A "$BASE/garden.php" | grep -oE 'flash ok">🏅[^<]*'; done
db "SELECT 'entry size '||size FROM show_entries WHERE user_id=$SP"
curl -s -b $A $BASE/show.php > /tmp/k.html; echo "board rows: $(grep -c '<tr' /tmp/k.html)"
echo "-- judge an old week"; dbx "UPDATE show_entries SET week='2000-W01'"; C0=$(db "SELECT coins FROM users WHERE id=$SP")
curl -s -b $A $BASE/games.php > /tmp/k.html; db "SELECT 'placed '||placed FROM show_entries"; echo "coins $C0 -> $(db "SELECT coins FROM users WHERE id=$SP") ribbons $(db "SELECT ribbons FROM users WHERE id=$SP")"; curl -s -b $A $BASE/gnome.php | grep -oE '📬[^<]*|🎀[^<]*' | head -3
echo "== carving"; PUMP=$(db "SELECT produce_item_id FROM plants WHERE slug='pumpkin'"); dbx "INSERT OR REPLACE INTO user_items (user_id,item_id,qty) VALUES ($SP,$PUMP,2)"
pg $A carve.php -d do=carve -d 'c[0]=1' -d title=Tiny; pg $A carve.php -d do=carve -d 'c[11]=1' -d 'c[18]=1' -d 'c[62]=1' -d 'c[63]=1' -d 'c[64]=1' -d 'c[65]=1' -d 'c[999]=1' -d 'title=Grinning <Gourd>'
db "SELECT 'pattern ones '||(LENGTH(pattern)-LENGTH(REPLACE(pattern,'1','')))||' len '||LENGTH(pattern)||' title '||title FROM carvings"; echo "pumpkins left $(db "SELECT qty FROM user_items WHERE user_id=$SP AND item_id=$PUMP")"
CID=$(db "SELECT id FROM carvings LIMIT 1"); pg $A carve.php -d do=vote -d id=$CID; pg $T carve.php -d do=vote -d id=$CID; pg $T carve.php -d do=vote -d id=$CID
echo "gallery: $(grep -c 'class="box carving"' /tmp/k.html) escaped: $(grep -c 'Grinning &lt;Gourd&gt;' /tmp/k.html)"
echo "-- settle last year"; dbx "UPDATE carvings SET year=2025"; curl -s -b $A $BASE/carve.php -o /dev/null; db "SELECT 'carving placed '||placed||' votes '||votes FROM carvings"
echo "== php errors"; grep -iE 'fatal|warning|notice|deprecated' /tmp/ct-php.log || echo "(none)"
