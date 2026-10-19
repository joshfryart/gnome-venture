#!/bin/bash
# v0.9.5 items 8 + 9: "Add 4 beds" (cost climbs, items taken, cap, old gardens keep every bed after upgrade_095_beds) and
# building stacking (two kitchens give the stacked buff, XP and pots). Run on a fresh install made by walk.sh (player "sprout"): beds.sh GAME PORT ROUTER
GAME=$1; PORT=$2; ROUTER=$3; BASE=http://127.0.0.1:$PORT
php -d session.save_path=/tmp -S 127.0.0.1:$PORT -t $GAME $ROUTER >/tmp/beds-php.log 2>&1 & PID=$!; sleep 1
trap "kill $PID 2>/dev/null" EXIT
FAILS=0
csrf() { grep -o 'name="csrf" value="[^"]*"' "$1" | head -1 | sed 's/.*value="\([^"]*\)".*/\1/'; }
db() { php -r '$p=new PDO("sqlite:'$GAME'/data/game.sqlite"); foreach($p->query($argv[1])->fetchAll(PDO::FETCH_NUM) as $r) echo implode(" | ",$r),"\n";' "$1"; }
dbx() { php -r '$p=new PDO("sqlite:'$GAME'/data/game.sqlite"); $p->exec($argv[1]);' "$1"; }
chk() { if [ "$2" == "$3" ]; then echo "ok   $1 = $2"; else echo "FAIL $1: got '$2', wanted '$3'"; FAILS=$((FAILS+1)); fi; }
A=/tmp/beds-a; rm -f $A
curl -s -c $A -b $A $BASE/login.php > /tmp/b.html; curl -s -c $A -b $A -X POST $BASE/login.php --data-urlencode "csrf=$(csrf /tmp/b.html)" -d username=sprout -d 'password=TestPass123!' -o /dev/null
page() { curl -s -b $A -c $A "$BASE/$1" > /tmp/b.html; }
expand() { page garden.php; curl -s -b $A -c $A -X POST $BASE/garden.php --data-urlencode "csrf=$(csrf /tmp/b.html)" -d do=expand -o /dev/null; page garden.php; grep -oE 'flash (ok|err)[^>]*>[^<]*' /tmp/b.html | head -1; }
SID=$(db "SELECT id FROM users WHERE username='sprout'")
PL=$(db "SELECT id FROM plots WHERE user_id=$SID ORDER BY id LIMIT 1")
PLANK=$(db "SELECT id FROM items WHERE slug='timber-plank'")
planks() { db "SELECT COALESCE(SUM(qty),0) FROM user_items WHERE user_id=$SID AND item_id=$PLANK"; }
beds() { db "SELECT COUNT(*) FROM plot_tiles WHERE plot_id=$PL"; }
dbx "UPDATE users SET onboarded=1, level=20, coins=100000, active_plot_id=$PL WHERE id=$SID"
dbx "DELETE FROM user_items WHERE user_id=$SID AND item_id=$PLANK"; dbx "INSERT INTO user_items (user_id,item_id,qty) VALUES ($SID,$PLANK,20)"
dbx "UPDATE plots SET garden_level=8, bed_adds=NULL WHERE id=$PL"

echo "== add 4 beds: cost climbs, items taken"
page "garden.php?t=grow"; echo "  panel: $(grep -oE 'Next 4 beds cost <b>[^<]*</b>[^(]*' /tmp/b.html | sed 's/<[^>]*>//g')"; chk "old expand form gone" "$(grep -c 'Add a column' /tmp/b.html)" 0
chk "start beds" "$(beds)" 16
for want in "20 200 18" "24 300 15" "28 450 10"; do
  set -- $want; c0=$(db "SELECT coins FROM users WHERE id=$SID"); p0=$(planks); msg=$(expand)
  chk "beds after buy" "$(beds)" $1; chk "  petals spent" "$((c0 - $(db "SELECT coins FROM users WHERE id=$SID")))" $2; chk "  planks left" "$(planks)" $3
done
chk "bed_adds counted" "$(db "SELECT bed_adds FROM plots WHERE id=$PL")" 3
chk "every bed has a yard spot, none shared" "$(db "SELECT COUNT(*)||'/'||COUNT(DISTINCT yx||','||yy) FROM plot_tiles WHERE plot_id=$PL AND yx IS NOT NULL")" "28/28"
chk "no bed outside its x,y duplicates" "$(db "SELECT COUNT(*)-COUNT(DISTINCT x||','||y) FROM plot_tiles WHERE plot_id=$PL")" 0
page garden.php; chk "yard draws all beds" "$(grep -oE 'class="tile [^"]*gx[0-9]+' /tmp/b.html | wc -l)" 28

echo "== not enough items / petals: nothing changes"
dbx "UPDATE user_items SET qty=1 WHERE user_id=$SID AND item_id=$PLANK"; c0=$(db "SELECT coins FROM users WHERE id=$SID"); echo "  $(expand)"
chk "beds unchanged (planks)" "$(beds)" 28; chk "petals unchanged (rolled back)" "$(db "SELECT coins FROM users WHERE id=$SID")" "$c0"
dbx "UPDATE user_items SET qty=50 WHERE user_id=$SID AND item_id=$PLANK; UPDATE users SET coins=10 WHERE id=$SID"; echo "  $(expand)"
chk "beds unchanged (petals)" "$(beds)" 28; chk "planks unchanged" "$(planks)" 50

echo "== garden-level cap"
dbx "UPDATE users SET coins=100000 WHERE id=$SID; UPDATE plots SET garden_level=2 WHERE id=$PL"   # side 5 = 25 beds
echo "  $(expand)"; chk "over the cap: refused" "$(beds)" 28
dbx "DELETE FROM plot_tiles WHERE plot_id=$PL AND (x>=5 OR y>=5); UPDATE plots SET width=5, height=5, bed_adds=NULL WHERE id=$PL"; chk "25-square garden" "$(beds)" "$(db "SELECT COUNT(*) FROM plot_tiles WHERE plot_id=$PL")"
dbx "DELETE FROM plot_tiles WHERE plot_id=$PL AND (x+y*5)>=20"; dbx "UPDATE plots SET bed_adds=1 WHERE id=$PL"   # 20 beds, cap 25: room for 5 -> adds 4 then 1
expand >/dev/null; chk "20 -> 24" "$(beds)" 24; echo "  $(expand)"; chk "partial add up to the cap" "$(beds)" 25
echo "  $(expand)"; chk "at the cap: refused" "$(beds)" 25
page "garden.php?t=grow"; chk "panel says cap" "$(grep -c 'higher garden level lets it hold more beds' /tmp/b.html)" 1

echo "== old garden after the upgrade keeps every bed"
dbx "DELETE FROM plot_tiles WHERE plot_id=$PL"
dbx "UPDATE plots SET width=5, height=5, bed_adds=NULL, garden_level=8 WHERE id=$PL"
for y in 0 1 2 3 4; do for x in 0 1 2 3 4; do echo "INSERT INTO plot_tiles (plot_id,user_id,x,y) VALUES ($PL,$SID,$x,$y);"; done; done > /tmp/b.sql
php -r '$p=new PDO("sqlite:'$GAME'/data/game.sqlite"); $p->exec(file_get_contents("/tmp/b.sql"));'
dbx "DELETE FROM settings WHERE name='db_version'; INSERT INTO settings (name,value) VALUES ('db_version','0.9.3'), ('plot_expand_cost','1000')"
page garden.php   # boot runs the upgrade
chk "beds kept" "$(beds)" 25; chk "size kept" "$(db "SELECT width||'x'||height FROM plots WHERE id=$PL")" 5x5
chk "migration counted 3 purchases" "$(db "SELECT bed_adds FROM plots WHERE id=$PL")" 3
chk "old setting gone" "$(db "SELECT COUNT(*) FROM settings WHERE name='plot_expand_cost'")" 0
page "garden.php?t=grow"; chk "next cost 200 x 1.5^3" "$(grep -oE 'Next 4 beds cost <b>[0-9,]*' /tmp/b.html | grep -oE '[0-9,]+$')" 675
chk "db_version restored" "$(db "SELECT value FROM settings WHERE name='db_version'")" "$(grep -oE "APP_VERSION', '[^']*" $GAME/includes/bootstrap.php | grep -oE '[0-9.]+$')"

echo "== stacking: kitchens in several gardens"
dbx "DELETE FROM garden_buildings WHERE building='kitchen'"
dbx "INSERT INTO garden_buildings (plot_id,building,level,built_at,last_collect) VALUES ($PL,'kitchen',3,datetime('now'),datetime('now'))"
page "garden.php?t=bld"; one=$(grep -oE 'All your kitchens together:.*\.' /tmp/b.html | sed 's/<[^>]*>//g' | head -1 | cut -c1-120); echo "  one III: $one"
chk "one kitchen III: buff +50%" "$(echo "$one" | grep -c '+50% longer')" 1; chk "  pots 4" "$(echo "$one" | grep -c ' 4 pots')" 1
php -r '$p=new PDO("sqlite:'$GAME'/data/game.sqlite"); $u=$argv[1]; $r=$p->query("SELECT * FROM plots WHERE id=".$argv[2])->fetch(PDO::FETCH_ASSOC); unset($r["id"]); $c=array_keys($r);
 for($i=0;$i<2;$i++){ $p->prepare("INSERT INTO plots (".implode(",",$c).") VALUES (".implode(",",array_fill(0,count($c),"?")).")")->execute(array_values($r)); }' $SID $PL
P2=$(db "SELECT id FROM plots WHERE user_id=$SID ORDER BY id LIMIT 1 OFFSET 1"); P3=$(db "SELECT id FROM plots WHERE user_id=$SID ORDER BY id LIMIT 1 OFFSET 2")
dbx "INSERT INTO garden_buildings (plot_id,building,level,built_at,last_collect) VALUES ($P2,'kitchen',3,datetime('now'),datetime('now')),($P3,'kitchen',2,datetime('now'),datetime('now'))"
page "garden.php?t=bld"; two=$(grep -oE 'All your kitchens together:.*\.' /tmp/b.html | sed 's/<[^>]*>//g' | head -1 | cut -c1-120); echo "  III + III + II: $two"
chk "buff 50 + 5 x 10 = +100% (cap)" "$(echo "$two" | grep -c '+100% longer')" 1
chk "  XP 50 + 5 x 5 = +75%" "$(echo "$two" | grep -c '+75% XP')" 1
chk "  pots 4 + 1 (other III) = 5" "$(echo "$two" | grep -c ' 5 pots')" 1
dbx "UPDATE garden_buildings SET level=2 WHERE plot_id=$P2 AND building='kitchen'"
page "garden.php?t=bld"; three=$(grep -oE 'All your kitchens together:.*\.' /tmp/b.html | sed 's/<[^>]*>//g' | head -1 | cut -c1-120)
chk "III + II + II: buff 50 + 4 x 10 = +90%" "$(echo "$three" | grep -c '+90% longer')" 1; chk "  pots stay 4" "$(echo "$three" | grep -c ' 4 pots')" 1
dbx "UPDATE garden_buildings SET level=1 WHERE building='kitchen' AND plot_id<>$PL"; dbx "UPDATE garden_buildings SET level=2 WHERE building='kitchen' AND plot_id=$PL"
page "garden.php?t=bld"; four=$(grep -oE 'All your kitchens together:.*\.' /tmp/b.html | sed 's/<[^>]*>//g' | head -1 | cut -c1-120)
chk "II + I + I: buff 25 + 2 x 10 = +45%, no feasts" "$(echo "$four" | grep -c '+45% longer')$(echo "$four" | grep -c 'feasts')" 10
echo "== php errors"; if [ -s /tmp/beds-php.log ] && grep -qiE "warning|notice|fatal|deprecated" /tmp/beds-php.log; then grep -iE "warning|notice|fatal|deprecated" /tmp/beds-php.log | head; FAILS=$((FAILS+1)); else echo "(none)"; fi
echo "failures: $FAILS"; exit $FAILS
