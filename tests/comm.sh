GAME=$1; PORT=$2; ROUTER=$3; BASE=http://127.0.0.1:$PORT
php -d session.save_path=/tmp -S 127.0.0.1:$PORT -t $GAME $ROUTER >/tmp/cm-php.log 2>&1 & PID=$!; sleep 1
trap "kill $PID 2>/dev/null" EXIT
csrf() { grep -o 'name="csrf" value="[^"]*"' "$1" | head -1 | sed 's/.*value="\([^"]*\)".*/\1/'; }
db() { php -r '$p=new PDO("sqlite:'$GAME'/data/game.sqlite"); foreach($p->query($argv[1])->fetchAll(PDO::FETCH_NUM) as $r) echo implode(" | ",$r),"\n";' "$1"; }
dbx() { php -r '$p=new PDO("sqlite:'$GAME'/data/game.sqlite"); $p->exec($argv[1]);' "$1"; }
C=/tmp/cm-ck; rm -f $C
curl -s -c $C -b $C $BASE/login.php > /tmp/c.html; curl -s -c $C -b $C -X POST $BASE/login.php --data-urlencode "csrf=$(csrf /tmp/c.html)" -d username=sprout -d 'password=TestPass123!' -o /dev/null
cp() { curl -s -c $C -b $C "$BASE/community.php" > /tmp/c0.html; curl -s -c $C -b $C -X POST "$BASE/community.php" --data-urlencode "csrf=$(csrf /tmp/c0.html)" "$@" -o /dev/null; curl -s -c $C -b $C "$BASE/community.php" > /tmp/c.html; grep -oE 'flash (ok|err)">[^<]*' /tmp/c.html | head -2; }
UID_=$(db "SELECT id FROM users WHERE username='sprout'")
echo "== setup"; db "SELECT 'beds '||COUNT(*)||' planted '||SUM(plant_id IS NOT NULL) FROM community_beds"; db "SELECT 'store kinds '||COUNT(*)||' qty '||SUM(qty) FROM community_store"
curl -s -b $C $BASE/community.php > /tmp/c.html; echo "beds on page: $(grep -c 'class="cbed' /tmp/c.html)"
echo "-- NPC catch-up after 5 hours"; dbx "UPDATE settings SET value=datetime('now','-5 hours') WHERE name='community_npc_at'"; curl -s -b $C $BASE/community.php -o /dev/null; db "SELECT 'planted now '||SUM(plant_id IS NOT NULL) FROM community_beds"
echo "== daily take from store"; IT=$(db "SELECT item_id FROM community_store WHERE qty>0 LIMIT 1"); cp -d do=take_store -d item_id=$IT; cp -d do=take_store -d item_id=$IT
echo "-- ripe bed tomorrow"; dbx "UPDATE users SET community_day='2000-01-01' WHERE id=$UID_"; B=$(db "SELECT id FROM community_beds WHERE plant_id IS NOT NULL LIMIT 1"); dbx "UPDATE community_beds SET grown=999999 WHERE id=$B"
cp -d do=take_bed -d bed=$B; db "SELECT 'bed now '||COALESCE(plant_id,'empty') FROM community_beds WHERE id=$B"
echo "== donate"; SEED=$(db "SELECT ui.item_id FROM user_items ui JOIN items i ON i.id=ui.item_id WHERE ui.user_id=$UID_ AND i.category='seed' LIMIT 1"); cp -d do=donate -d item_id=$SEED -d qty=1; cp -d do=donate -d item_id=$SEED -d qty=999
echo "== tending without a shift"; cp -d do=tend -d act=water:$B
cp -d do=shift -d minutes=45; cp -d do=shift -d minutes=30; echo "action buttons: $(grep -c 'class="bedacts"' /tmp/c.html)"
TB=$(db "SELECT id FROM community_beds WHERE plant_id IS NOT NULL LIMIT 1 OFFSET 1"); dbx "UPDATE community_beds SET water_until=datetime('now','-1 hour'), grown=10, weeds=30 WHERE id=$TB"
C0=$(db "SELECT coins FROM users WHERE id=$UID_"); cp -d do=tend -d act=water:$TB; cp -d do=tend -d act=water:$TB; cp -d do=tend -d act=weed:$TB
EB=$(db "SELECT id FROM community_beds WHERE plant_id IS NULL LIMIT 1"); SS=$(db "SELECT s.item_id FROM community_store s JOIN plants p ON p.seed_item_id=s.item_id WHERE s.qty>0 LIMIT 1"); cp -d do=tend -d act=plant:$EB -d seed=$SS
RB=$(db "SELECT id FROM community_beds WHERE plant_id IS NOT NULL AND id<>$EB LIMIT 1 OFFSET 2"); dbx "UPDATE community_beds SET grown=999999 WHERE id=$RB"; cp -d do=tend -d act=harvest:$RB
echo "coins $C0 -> $(db "SELECT coins FROM users WHERE id=$UID_") rep $(db "SELECT community_rep FROM users WHERE id=$UID_")  board: $(grep -c 'This week’s helpers' /tmp/c.html)"
echo "== adventure blocked on shift"; RID=$(db "SELECT id FROM routes LIMIT 1"); curl -s -c $C -b $C "$BASE/adventure.php" > /tmp/c0.html; grep -o 'name="do" value="[a-z_]*"' /tmp/c0.html | sort -u | head -5
php -r '$_SERVER["SCRIPT_NAME"]="/x.php"; require "'$GAME'/includes/bootstrap.php"; require "'$GAME'/includes/garden_logic.php"; require_once "'$GAME'/includes/adventure.php"; $u=q_one("SELECT * FROM users WHERE username=\"sprout\""); $r=q_val("SELECT id FROM routes LIMIT 1"); print_r(start_expedition($u,(int)$r)[1]); echo "\n";' 2>&1 | grep -v "already defined"
cp -d do=end_shift
echo "== php errors"; grep -iE 'fatal|warning|notice|deprecated' /tmp/cm-php.log || echo "(none)"
