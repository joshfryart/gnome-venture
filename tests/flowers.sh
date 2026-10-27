#!/bin/bash
# v0.9.9 part A: flowers. Run on a fresh SQLite install that walk.sh made (admin / sprout): flowers.sh GAME PORT ROUTER
# Covers: arrange consumes stems, deterministic score, sell / gift / show entry, drying timer, seed-packet gate, volunteer limit, SVG icons.
GAME=$1; PORT=$2; ROUTER=$3; BASE=http://127.0.0.1:$PORT
php -d session.save_path=/tmp -S 127.0.0.1:$PORT -t $GAME $ROUTER >/tmp/flowers-php.log 2>&1 & PID=$!; sleep 1
T=$(mktemp -d /tmp/flowers-test.XXXXXX); trap 'kill $PID 2>/dev/null; [ -d "${T:?}" ] && rm -rf "${T:?}"' EXIT
csrf() { grep -o 'name="csrf" value="[^"]*"' "$1" | head -1 | sed 's/.*value="\([^"]*\)".*/\1/'; }
db() { php -r '$p=new PDO("sqlite:'$GAME'/data/game.sqlite"); foreach($p->query($argv[1])->fetchAll(PDO::FETCH_NUM) as $r) echo implode(" | ",$r),"\n";' "$1"; }
dbx() { php -r '$p=new PDO("sqlite:'$GAME'/data/game.sqlite"); $p->exec($argv[1]);' "$1"; }
chk() { if [ "$2" = "$3" ]; then echo "ok   $1 = $2"; else echo "FAIL $1: got '$2' want '$3'"; fi; }
S=$T/s; rm -f $S; curl -s -c $S -b $S $BASE/login.php > $T/l.html
curl -s -c $S -b $S -X POST $BASE/login.php --data-urlencode "csrf=$(csrf $T/l.html)" -d username=sprout -d 'password=TestPass123!' -o /dev/null
get() { curl -s -c $S -b $S "$BASE/$1" -o $T/p.html; }
post() { local page=$1; shift; get "$page"; curl -s -c $S -b $S -X POST "$BASE/$page" --data-urlencode "csrf=$(csrf $T/p.html)" "$@" -o $T/post.html; get "$page"; }
SID=$(db "SELECT id FROM users WHERE username='sprout'")
dbx "UPDATE users SET onboarded=1, tour_step=0, coins=5000, energy=100, level=10 WHERE id=$SID"
item() { db "SELECT id FROM items WHERE slug='$1'"; }
qty() { db "SELECT COALESCE(SUM(qty),0) FROM user_items WHERE user_id=$SID AND item_id=$1"; }
for s in damask-rose dahlia cosmos lavender chamomile bluebell dutch-tulip; do dbx "INSERT OR REPLACE INTO user_items (user_id,item_id,qty) SELECT $SID,id,4 FROM items WHERE slug='cut-$s'"; done
R=$(item cut-damask-rose); D=$(item cut-dahlia); C=$(item cut-cosmos); L=$(item cut-lavender)
FL=$(db "SELECT id FROM shops WHERE slug='petalpins-posies'")

echo "== florists exist, round the clock"
chk "two florist shops" "$(db "SELECT COUNT(*) FROM shops WHERE shop_type='florist'")" 2
chk "six florist staff" "$(db "SELECT COUNT(DISTINCT s.npc_id) FROM npc_schedules s JOIN shops h ON h.id=s.shop_id WHERE h.shop_type='florist' AND s.activity='working'")" 6
chk "four flower Almanac pages" "$(db "SELECT COUNT(*) FROM encyclopedia_entries WHERE title IN ('Arranging flowers','Dried flowers','Seed packets','The florists')")" 4

echo "== art: SVG icons in the Satchel; the files are static"
get "inventory.php?cat=flower"
chk "flower icons are inline SVG" "$(grep -c 'class="flsvg flsvg-\(md\|lg\)"' $T/p.html | awk '{print ($1>5)?"yes":"no"}')" yes
chk "no script or handlers in svg files" "$(grep -il '<script\|onload\|onclick' $GAME/assets/img/flowers/*.svg | wc -l)" 0
chk "12 heads + 3 vessels + 3 sprigs + packet" "$(ls $GAME/assets/img/flowers/*.svg | wc -l)" 19
chk "168 flowers have a look" "$(grep -vc '^#' $GAME/includes/data/flower_looks.txt)" 168

echo "== preview score is deterministic and order-independent"
P1=$(curl -s -b $S "$BASE/arrange.php?t=preview&v=vase&s=0:$R,1:$D,2:$C,5:$L,6:$D")
P2=$(curl -s -b $S "$BASE/arrange.php?t=preview&v=vase&s=6:$D,5:$L,2:$C,1:$D,0:$R")
chk "same composition, same JSON" "$P1" "$P2"
echo "$P1" | grep -q '"ok":true' && echo "ok   preview: $(echo "$P1" | grep -o '"total":[0-9]*') $(echo "$P1" | grep -o '"name":"[^"]*"')" || echo "FAIL preview: $P1"
chk "too few stems refused" "$(curl -s -b $S "$BASE/arrange.php?t=preview&v=vase&s=0:$R" | grep -o '"ok":[a-z]*')" '"ok":false'

echo "== arranging consumes stems and energy, makes an item"
E0=$(db "SELECT energy FROM users WHERE id=$SID"); RQ=$(qty $R); DQ=$(qty $D)
post arrange.php -d do=arrange -d v=vase -d "slot[0]=$R" -d "slot[1]=$D" -d "slot[2]=$C" -d "slot[5]=$L" -d "slot[6]=$D"
AID=$(db "SELECT id FROM items WHERE category='arrangement' ORDER BY id DESC LIMIT 1")
chk "one arrangement item" "$(db "SELECT COUNT(*) FROM items WHERE category='arrangement'")" 1
chk "rose used 1" "$(( RQ - $(qty $R) ))" 1
chk "dahlia used 2" "$(( DQ - $(qty $D) ))" 2
chk "energy spent" "$(( E0 - $(db "SELECT energy FROM users WHERE id=$SID") ))" 2
chk "player holds it" "$(qty $AID)" 1
chk "stored score equals preview" "$(db "SELECT effects FROM items WHERE id=$AID" | grep -o '"score":[0-9]*' | head -1)" "$(echo "$P1" | grep -o '"total":[0-9]*' | sed 's/total/score/')"
get "inventory.php?cat=arrangement"
chk "arrangement draws as SVG in the satchel" "$(grep -c 'class="flsvg flsvg-\(md\|lg\)"' $T/p.html | awk '{print ($1>0)?"yes":"no"}')" yes
echo "-- refused cases use nothing"
post arrange.php -d do=arrange -d v=jar -d "slot[0]=$R" -d "slot[1]=$D"
chk "2 stems refused" "$(qty $R)" "$(( RQ - 1 ))"
dbx "UPDATE user_items SET qty=1 WHERE user_id=$SID AND item_id=$C"
post arrange.php -d do=arrange -d v=jar -d "slot[0]=$C" -d "slot[1]=$C" -d "slot[2]=$C"
chk "3 cosmos with 1 owned refused" "$(qty $C)" 1
chk "still one arrangement" "$(db "SELECT COUNT(*) FROM items WHERE category='arrangement'")" 1
dbx "UPDATE user_items SET qty=4 WHERE user_id=$SID AND item_id=$C"
post arrange.php -d do=arrange -d v=jar -d "slot[0]=$R" -d "slot[1]=$D" -d "slot[2]=$C" -d "slot[3]=$L" -d "slot[4]=$R" -d "slot[5]=$D" -d "slot[6]=$C"
chk "jar ignores spots it does not have (3 stems kept)" "$(db "SELECT COUNT(*) FROM items WHERE category='arrangement'")" 2
dbx "UPDATE users SET energy=0 WHERE id=$SID"
post arrange.php -d do=arrange -d v=vase -d "slot[0]=$R" -d "slot[1]=$D" -d "slot[2]=$C"
chk "no energy: refused" "$(db "SELECT COUNT(*) FROM items WHERE category='arrangement'")" 2
dbx "UPDATE users SET energy=100 WHERE id=$SID"

echo "== sell to a shop (60% of value, no rarity bonus)"
AV=$(db "SELECT base_price FROM items WHERE id=$AID")
C0=$(db "SELECT coins FROM users WHERE id=$SID")
post "shop.php?id=$FL&tab=sell" -d do=sell -d "qty[$AID]=1"
GOT=$(( $(db "SELECT coins FROM users WHERE id=$SID") - C0 )); LO=$(php -r "echo (int)floor($AV*0.45);"); HI=$(php -r "echo (int)ceil($AV*0.8);"); [ "$GOT" -ge "$LO" ] && [ "$GOT" -le "$HI" ] && echo "ok   sold $GOT within weekly price band $LO-$HI" || echo "FAIL sold $GOT outside $LO-$HI"
chk "arrangement gone" "$(qty $AID)" 0

echo "== gift: better than a single flower"
post arrange.php -d do=arrange -d v=vase -d "slot[0]=$R" -d "slot[1]=$D" -d "slot[2]=$C" -d "slot[5]=$L" -d "slot[6]=$D"
AID=$(db "SELECT id FROM items WHERE category='arrangement' ORDER BY id DESC LIMIT 1")
get "shop.php?id=$FL"; NPC=$(grep -o 'folk.php?id=[0-9]*' $T/p.html | head -1 | grep -o '[0-9]*$')
dbx "DELETE FROM npc_friends WHERE user_id=$SID"
post "villagers.php?id=$NPC" -d id=$NPC -d do=gift -d item_id=$AID   # v2.0.39: gifts are given on the Villagers page (folk.php only redirects GETs)
GP=$(db "SELECT points FROM npc_friends WHERE user_id=$SID AND npc_id=$NPC")
[ "${GP:-0}" -ge 15 ] && echo "ok   arrangement gift = $GP friendship (a plain liked flower is 10)" || echo "FAIL arrangement gift points '$GP'"
chk "arrangement given" "$(qty $AID)" 0

echo "== weekly show: enter, judge once"
dbx "UPDATE user_items SET qty=4 WHERE user_id=$SID AND item_id IN ($R,$D,$C,$L)"
post arrange.php -d do=arrange -d v=basket -d "slot[0]=$R" -d "slot[1]=$D" -d "slot[2]=$C" -d "slot[3]=$L" -d "slot[4]=$R" -d "slot[5]=$D"
A2=$(db "SELECT id FROM items WHERE category='arrangement' ORDER BY id DESC LIMIT 1")
post "arrange.php?t=show" -d do=enter -d item_id=$A2
chk "one entry" "$(db "SELECT COUNT(*) FROM arrangement_entries WHERE user_id=$SID")" 1
chk "entered arrangement left the satchel" "$(qty $A2)" 0
get "arrange.php?t=show"; chk "show page lists the leader" "$(grep -c 'arrleaders' $T/p.html | awk '{print ($1>0)?"yes":"no"}')" yes
dbx "UPDATE arrangement_entries SET week='2000-W01' WHERE user_id=$SID"
C1=$(db "SELECT coins FROM users WHERE id=$SID")
get "arrange.php?t=show"
chk "judged: placed 1" "$(db "SELECT placed FROM arrangement_entries WHERE user_id=$SID")" 1
chk "prize paid" "$(( $(db "SELECT coins FROM users WHERE id=$SID") - C1 ))" 800
get "arrange.php?t=show"
chk "not paid twice" "$(( $(db "SELECT coins FROM users WHERE id=$SID") - C1 ))" 800

echo "== drying rack: real timer"
dbx "UPDATE user_items SET qty=4 WHERE user_id=$SID AND item_id IN ($R,$D,$C,$L)"
RQ=$(qty $R)
post "arrange.php?t=dry" -d do=dry -d item_id=$R -d qty=2
chk "2 roses hung" "$(( RQ - $(qty $R) ))" 2
RK=$(db "SELECT id FROM dry_racks WHERE user_id=$SID AND collected_at IS NULL ORDER BY id DESC LIMIT 1")
post "arrange.php?t=dry" -d do=dry_collect -d rack=$RK
chk "not dry yet: still hanging" "$(db "SELECT COUNT(*) FROM dry_racks WHERE user_id=$SID AND collected_at IS NULL")" 1
chk "ready a day away (hours)" "$(db "SELECT ((strftime('%s', ready_at) - strftime('%s','now')) + 60) / 3600 FROM dry_racks WHERE id=$RK")" 24
dbx "UPDATE dry_racks SET ready_at=datetime('now','-1 minute') WHERE id=$RK"
post "arrange.php?t=dry" -d do=dry_collect -d rack=$RK
DR=$(item dried-damask-rose)
chk "2 dried roses" "$(qty ${DR:-0})" 2
post "arrange.php?t=dry" -d do=dry_collect -d rack=$RK
chk "double collect gives nothing more" "$(qty $DR)" 2
chk "dried sells higher than cut" "$(db "SELECT (SELECT base_price FROM items WHERE slug='dried-damask-rose') > (SELECT base_price FROM items WHERE slug='cut-damask-rose')")" 1
chk "dried can be arranged" "$(curl -s -b $S "$BASE/arrange.php?t=preview&v=vase&s=0:$DR,1:$D,2:$C" | grep -o '"ok":[a-z]*')" '"ok":true'
for i in 1 2 3 4; do dbx "INSERT INTO dry_racks (user_id,item_id,qty,started_at,ready_at) VALUES ($SID,$D,1,datetime('now'),datetime('now','+1 day'))"; done
post "arrange.php?t=dry" -d do=dry -d item_id=$C -d qty=1
chk "rack full: refused" "$(db "SELECT COUNT(*) FROM dry_racks WHERE user_id=$SID AND collected_at IS NULL")" 4
dbx "DELETE FROM dry_racks WHERE user_id=$SID"

echo "== seed packets: mastery gate"
PL=$(db "SELECT id FROM plants WHERE slug='dahlia'"); SEED=$(db "SELECT seed_item_id FROM plants WHERE slug='dahlia'")
dbx "INSERT OR REPLACE INTO user_items (user_id,item_id,qty) VALUES ($SID,$SEED,9)"
post "arrange.php?t=packets" -d do=packet -d plant_id=$PL
chk "not mastered: no packet" "$(db "SELECT COUNT(*) FROM items WHERE category='packet'")" 0
chk "seeds untouched" "$(qty $SEED)" 9
dbx "DELETE FROM user_plant_knowledge WHERE user_id=$SID AND plant_id=$PL"
dbx "INSERT INTO user_plant_knowledge (user_id,plant_id,knowledge) SELECT $SID,id,knowledge_max FROM plants WHERE id=$PL"
C2=$(db "SELECT coins FROM users WHERE id=$SID")
post "arrange.php?t=packets" -d do=packet -d plant_id=$PL
PK=$(item dahlia-packet)
chk "mastered: packet made" "$(qty ${PK:-0})" 1
chk "3 seeds used" "$(qty $SEED)" 6
chk "fee paid" "$(( C2 - $(db "SELECT coins FROM users WHERE id=$SID") ))" 20
get "inventory.php?cat=seed"; chk "packet shows as SVG" "$(grep -c 'flsvg' $T/p.html | awk '{print ($1>0)?"yes":"no"}')" yes
dbx "UPDATE flower_daily SET n=5 WHERE user_id=$SID AND kind='packet'"
post "arrange.php?t=packets" -d do=packet -d plant_id=$PL
chk "daily limit: still one packet" "$(qty $PK)" 1
post inventory.php -d do=open_packet -d item_id=$PK
chk "opened: packet gone" "$(qty $PK)" 0
chk "opened: seeds back" "$(qty $SEED)" 9

echo "== volunteer at a florist (Mossbottom: reachable from anywhere)"
dbx "UPDATE users SET energy=100 WHERE id=$SID; DELETE FROM flower_daily WHERE user_id=$SID; DELETE FROM florist_shifts WHERE user_id=$SID"
post "shop.php?id=$FL" -d do=flo_start
chk "shift started" "$(db "SELECT COUNT(*) FROM florist_shifts WHERE user_id=$SID AND collected_at IS NULL")" 1
chk "energy spent" "$(db "SELECT 100 - energy FROM users WHERE id=$SID")" 3
chk "30 minute timer" "$(db "SELECT (strftime('%s', ready_at) - strftime('%s', started_at)) / 60 FROM florist_shifts WHERE user_id=$SID")" 30
SH=$(db "SELECT id FROM florist_shifts WHERE user_id=$SID")
post "shop.php?id=$FL" -d do=flo_collect -d shift=$SH
chk "too early: nothing yet" "$(db "SELECT COUNT(*) FROM florist_shifts WHERE user_id=$SID AND collected_at IS NULL")" 1
post "shop.php?id=$FL" -d do=flo_start
chk "one shift at a time" "$(db "SELECT COUNT(*) FROM florist_shifts WHERE user_id=$SID")" 1
dbx "UPDATE florist_shifts SET ready_at=datetime('now','-1 minute') WHERE user_id=$SID"
cuts() { db "SELECT COALESCE(SUM(ui.qty),0) FROM user_items ui JOIN items i ON i.id=ui.item_id WHERE ui.user_id=$SID AND i.category='flower'"; }
CUT0=$(cuts); X0=$(db "SELECT xp FROM users WHERE id=$SID")
post "shop.php?id=$FL" -d do=flo_collect -d shift=$SH
G=$(( $(cuts) - CUT0 )); [ $G -ge 3 ] && [ $G -le 5 ] && echo "ok   bundle of $G cut flowers" || echo "FAIL bundle size $G"
[ "$(db "SELECT xp FROM users WHERE id=$SID")" -gt "$X0" ] && echo "ok   XP paid" || echo "FAIL no XP"
chk "friendship with the florist" "$(db "SELECT COUNT(*) FROM npc_friends WHERE user_id=$SID AND points>0 AND npc_id IN (SELECT npc_id FROM npc_schedules WHERE shop_id=$FL)")" 1
CUT1=$(cuts)
post "shop.php?id=$FL" -d do=flo_collect -d shift=$SH
chk "double collect pays nothing more" "$(cuts)" "$CUT1"
echo "-- daily limit (3 a day)"
for i in 1 2 3 4; do dbx "UPDATE users SET energy=100 WHERE id=$SID; UPDATE florist_shifts SET collected_at=datetime('now') WHERE user_id=$SID AND collected_at IS NULL"; post "shop.php?id=$FL" -d do=flo_start; done
chk "3 shifts a day in all, the 4th refused" "$(db "SELECT COUNT(*) FROM florist_shifts WHERE user_id=$SID")" 3

echo "== anonymous is sent to log in"
chk "arrange.php anonymous" "$(curl -s -o /dev/null -w '%{http_code}' "$BASE/arrange.php")" 302
echo "== php errors"
grep -E "Warning|Notice|Deprecated|Fatal" /tmp/flowers-php.log | head -5
echo "(nothing above = zero PHP warnings)"
