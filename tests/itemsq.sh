#!/bin/bash
# v2.0.67: item squares (includes/item_square.php, mockup 4). Every shop tile, Curio / Dye Pot tile and Satchel card is an .itm square with
# (wave 2: crafting ingredients, the gift picker on villagers.php, the garden seed / soil / mulch pickers, the town bird-seed picker, market-day basket picks)
# its hooks; no style= attribute; rarity word, kind chip, price chip, In use / Broken states; then the browser check (tests/itemsq_check.js)
# at 390 px light and dark on the real Satchel, shop Buy / Sell and Curio Cabinet when Playwright is installed.
# Run on a fresh SQLite install that walk.sh made (player "sprout"): itemsq.sh GAME PORT ROUTER [SHOT_DIR]
GAME=$1; PORT=$2; ROUTER=$3; SHOTS=$4; BASE=http://127.0.0.1:$PORT; HERE=$(cd "$(dirname "$0")" && pwd)
php -d session.save_path=/tmp -S 127.0.0.1:$PORT -t $GAME $ROUTER >/tmp/isq-php.log 2>&1 & PID=$!; sleep 1
trap "kill $PID 2>/dev/null" EXIT
H=/tmp/isq.html; J=/tmp/isq-ck
csrf() { grep -o 'name="csrf" value="[^"]*"' "$1" | head -1 | sed 's/.*value="\([^"]*\)".*/\1/'; }
db() { php -r '$p=new PDO("sqlite:'$GAME'/data/game.sqlite"); foreach($p->query($argv[1])->fetchAll(PDO::FETCH_NUM) as $r) echo implode(" | ",$r),"\n";' "$1"; }
dbx() { php -r '$p=new PDO("sqlite:'$GAME'/data/game.sqlite"); $p->exec($argv[1]);' "$1"; }
chk() { if [ "$2" = "$3" ]; then echo "ok   $1 = $2"; else echo "FAIL $1: got '$2' want '$3'"; fi; }
has() { if grep -q -- "$2" "$3"; then echo "ok   $1"; else echo "FAIL $1: no '$2'"; fi; }
hasnt() { if grep -qE -- "$2" "$3"; then echo "FAIL $1: found '$2'"; else echo "ok   $1"; fi; }
n() { grep -oE -- "$1" "$2" | wc -l | tr -d ' '; }

SID=$(db "SELECT id FROM users WHERE username='sprout'")
dbx "UPDATE users SET onboarded=1, tour_step=0, coins=2480 WHERE id=$SID"
# the longest real names, every rarity, a tool in use, a spare, a broken one, a big count
for spec in tomato:9999 goat-cheese-tart:12 feast-mistmoor-supper:1 masterwork-stirrup-hoe:1 stirrup-hoe:1 broken-masterwork-harvest-cart:1 morpho-scales:4 seed-pearl:1 geode:1 potato:27; do
  s=${spec%%:*}; q=${spec##*:}
  dbx "DELETE FROM user_items WHERE user_id=$SID AND item_id=(SELECT id FROM items WHERE slug='$s')"
  dbx "INSERT INTO user_items (user_id,item_id,qty,got_at) SELECT $SID, id, $q, datetime('now','-2 days') FROM items WHERE slug='$s'"
done
dbx "INSERT INTO user_items (user_id,item_id,qty,got_at) SELECT $SID, id, 1, datetime('now') FROM items WHERE name='Gardening Guide: The Sunsprinkle Isles' AND id NOT IN (SELECT item_id FROM user_items WHERE user_id=$SID)"
SH=$(db "SELECT s.id FROM shops s JOIN locations l ON l.id=s.location_id WHERE l.kind='hub' AND s.shop_type='seeds' LIMIT 1")
HH=$(db "SELECT id FROM shops WHERE slug='hedge-and-hearth'"); DP=$(db "SELECT id FROM shops WHERE slug='the-dye-pot'")
rm -f $J; curl -s -c $J -b $J $BASE/login.php > $H; curl -s -c $J -b $J -X POST $BASE/login.php --data-urlencode "csrf=$(csrf $H)" -d username=sprout -d 'password=TestPass123!' -o /dev/null

echo "== Satchel"
curl -s -b $J "$BASE/inventory.php" > $H
N=$(db "SELECT COUNT(*) FROM user_items WHERE user_id=$SID AND qty>0")
chk "one card per item" "$(n '<details class="itile itmcell" id="i[0-9]+"' $H)" "$N"
chk "every card is a square summary" "$(n '<summary class="itm itm--[culr]' $H)" "$N"
chk "every square has a window, ribbon and foot" "$(n 'class="itm__rib"><span class="itm__name">' $H)" "$N"
has "grouped by type" 'class="itm-h"' $H
has "count corner up to x9,999" '×9,999</b>' $H
has "kind words lifted into a chip" 'class="itm__kind">Seeds<span class="vh">' $H
has "long name keeps its own words" '<span class="itm__name">Goat Cheese and Quail Egg Tart</span>' $H
has "long-name face step" 'itm--xlong' $H
has "rarity word" 'class="itm__rar">\(Uncommon\|Rare\|Legendary\)<' $H
has "tool in use" 'class="itm__use">In use</span>' $H
has "spare tool" 'class="itm__note">Spare</span>' $H
has "broken tool on stone felt" 'itm--[culr][a-z -]* is-off"[^>]*><span class="itm__win">' $H
has "Broken lifted into a chip" 'class="itm__kind">Broken<span class="vh"> (Broken Masterwork Harvest Cart)' $H
has "Guide lifted into a chip" 'class="itm__kind">Guide<span class="vh">' $H
hasnt "no style= attribute" '\sstyle=' $H
hasnt "old tile markup gone" 'class="(iicon|iname|iqty)"' $H
curl -s -b $J "$BASE/inventory.php?open=$(db "SELECT id FROM items WHERE slug='geode'")" > $H
has "?open= opens that card" '<details class="itile itmcell" id="i[0-9]*" open>' $H
curl -s -b $J "$BASE/inventory.php?sort=az" > $H
chk "other sorts: one grid" "$(n 'class="itms"' $H)" 1

echo "== shop Buy / Sell"
curl -s -b $J "$BASE/shop.php?id=$SH" > $H
T=$(n 'class="btile stile' $H)
echo "  buy tiles: $T"; [ "$T" -ge 5 ] || echo "FAIL too few buy tiles ($T)"
chk "every tile is an item square button with its sheet hook" "$(n '<button class="itm itm--[culr][^"]* spick" type="button" data-sheet aria-haspopup="dialog">' $H)" "$T"
chk "every tile has its sheet" "$(n '<dialog class="isheet"' $H)" "$T"
chk "every tile has a price chip" "$(n 'class="itm__price">' $H)" "$T"
chk "every tile has the basket chip" "$(n '<span class="itm__inb" hidden></span>' $H)" "$T"
has "petal mark in the price" 'class="itm__pet" aria-hidden="true"></i><span class="vh"> Petals</span>' $H
has "hooks kept" 'class="btile stile itmcell" data-cat="[a-z]*" data-id="[0-9]*" data-price="[0-9]*" data-max="[0-9]*" data-name="' $H
has "basket bar" '<form method="post" class="basket" data-mode="buy"' $H
hasnt "no style= attribute" '\sstyle=' $H
hasnt "no old tile markup" 'class="(spick|iicon|iname|sprice|smini)"' $H
dbx "UPDATE users SET coins=1 WHERE id=$SID"; curl -s -b $J "$BASE/shop.php?id=$SH" > $H
has "too dear: stone felt and Short" 'class="itm__short">Short [0-9,]*<span class="vh"> Petals</span>' $H
dbx "UPDATE users SET coins=2480 WHERE id=$SID"
curl -s -b $J "$BASE/shop.php?id=$SH&tab=sell" > $H
T=$(n 'class="btile stile' $H)
echo "  sell tiles: $T"; [ "$T" -ge 5 ] || echo "FAIL too few sell tiles ($T)"
chk "sell: every tile is a square" "$(n 'class="itm itm--[culr][^"]* spick"' $H)" "$T"
has "sell: rarity word" 'class="itm__rar">\(Uncommon\|Rare\|Legendary\)<' $H
has "sell: count is what you have" '<span class="vh">You have </span>×9,999' $H
has "sell basket bar" '<form method="post" class="basket" data-mode="sell"' $H
hasnt "sell: no style= attribute" '\sstyle=' $H

echo "== Curio Cabinet, Dye Pot"
curl -s -b $J "$BASE/shop.php?id=$HH" > $H
C=$(tr '\n' ' ' < $H | grep -o 'id="curios".*' | sed 's/<\/section>.*//' | grep -o 'class="itm itm--[culr][^"]* spick"' | wc -l)
chk "curio tiles are squares" "$C" "$(tr '\n' ' ' < $H | grep -o 'id="curios".*' | sed 's/<\/section>.*//' | grep -o 'class="btile stile' | wc -l)"
[ "$C" -ge 3 ] || echo "FAIL only $C curio squares"
hasnt "curio: no style= attribute" '\sstyle=' $H
curl -s -b $J "$BASE/shop.php?id=$DP" > $H
chk "dye pots: 21 squares with a swatch" "$(n '<span class="itm__emo" aria-hidden="true"><svg width="48"' $H)" 21
hasnt "dye pot: no style= attribute" '\sstyle=' $H

echo "== wave 2 setup: crafting (the tart ready, the feast short), a villager whose tastes are found, soil and mulch, market day"
for spec in goat-cheese:3 quail-egg:14 wheat:2 onion:9999 cloudberry:1 hazelnut:4 leek:2 barley:1 thyme:1 worm-castings:9999 leaf-mould:3; do
  s=${spec%%:*}; q=${spec##*:}
  dbx "DELETE FROM user_items WHERE user_id=$SID AND item_id=(SELECT id FROM items WHERE slug='$s')"
  dbx "INSERT INTO user_items (user_id,item_id,qty,got_at) SELECT $SID, id, $q, datetime('now','-2 days') FROM items WHERE slug='$s'"
done
P=$(db "SELECT id FROM plots WHERE user_id=$SID LIMIT 1")
dbx "INSERT INTO garden_buildings (plot_id,building,built_at,last_collect) SELECT $P,'kitchen',datetime('now'),datetime('now') WHERE NOT EXISTS (SELECT 1 FROM garden_buildings WHERE plot_id=$P AND building='kitchen')"
dbx "UPDATE users SET energy=100 WHERE id=$SID"
TW=$(db "SELECT id FROM shops WHERE slug='twigg-s-seed-emporium'")
NID=$(db "SELECT npc_id FROM npc_schedules WHERE shop_id=$TW LIMIT 1"); dbx "UPDATE npc_schedules SET start_hour=0, end_hour=24, days='all' WHERE npc_id=$NID AND shop_id=$TW"
read LOVED LIKECAT DIS <<< "$(php $HERE/npctaste.php $GAME $NID 2>/dev/null | tail -1)"
DISCAT=$(db "SELECT category FROM items WHERE id=$DIS")
for id in $LOVED $DIS; do dbx "INSERT OR REPLACE INTO user_items (user_id,item_id,qty) VALUES ($SID,$id,5)"; done
dbx "INSERT OR REPLACE INTO user_items (user_id,item_id,qty) SELECT $SID, id, 3 FROM items WHERE category='$LIKECAT' AND tradable=1 ORDER BY id LIMIT 2"
dbx "INSERT OR REPLACE INTO npc_friends (user_id,npc_id,points,known,last_gift) VALUES ($SID,$NID,10,'[\"loved\",\"like:$LIKECAT\",\"dislike:$DISCAT\"]','2000-01-01')"
dbx "UPDATE settings SET value='$(date -u +%w)' WHERE name='market_day'"; dbx "INSERT OR IGNORE INTO settings (name,value) VALUES ('market_day','$(date -u +%w)')"
GREEN=$(db "SELECT id FROM town_spots WHERE slug='hub-green'")

echo "== crafting ingredients (inventory.php?tab=craft)"
curl -s -b $J "$BASE/inventory.php?tab=craft&c=cooking&show=ready" > $H
I=$(n 'class="itm itm--[culr][^"]* ccing"' $H)
echo "  ingredient squares: $I"; [ "$I" -ge 4 ] || echo "FAIL too few ingredient squares ($I)"
chk "every ingredient square says uses / short" "$(n 'class="itm__(ok|short)">' $H)" "$I"
chk "every ingredient square counts what you have" "$(n '<b class="itm__n"><span class="vh">You have </span>' $H)" "$I"
has "uses N chip (the tick may be drawn as an icon)" 'class="itm__ok">\(✔\|<img [^>]*>\) uses 3</span>' $H
has "have count in the corner" '<span class="vh">You have </span>×14</b>' $H
has "have / need words for screen readers" '<span class="vh">enough: you have 14, the recipe needs 3</span>' $H
has "ingredients in an item grid" '<div class="itmwrap"><div class="itms itms--flush ccings">' $H
has "make forms kept" 'class="ccbtns"><input type="hidden" name="csrf"' $H
hasnt "no style= attribute" '\sstyle=' $H
hasnt "old chips gone" 'class="ccchip' $H
curl -s -b $J "$BASE/inventory.php?tab=craft&c=cooking&show=missing" > $H
has "missing: short N chip" 'class="itm__short">\(✖\|<img [^>]*>\) short 2</span>' $H
has "missing: not enough words" '<span class="vh">not enough: you have 1, the recipe needs 3</span>' $H
hasnt "missing: no style= attribute" '\sstyle=' $H
curl -s -b $J "$BASE/inventory.php?tab=craft&c=cooking&show=unknown" > $H
has "to discover: found ingredient ticked" 'is-done ccing"' $H
has "to discover: unfound on stone felt, no picture" 'is-off ccing"><span class="itm__win"><span class="itm__emo" aria-hidden="true">' $H
hasnt "to discover: no style= attribute" '\sstyle=' $H

echo "== gift picker (villagers.php)"
curl -s -b $J "$BASE/villagers.php?id=$NID" > $H
G=$(db "SELECT COUNT(*) FROM user_items ui JOIN items i ON i.id=ui.item_id WHERE ui.user_id=$SID AND ui.qty>0 AND i.tradable=1 AND i.category<>'tool'")
chk "one square per giftable item, hooks kept" "$(n '<button class="itm itm--[culr][^"]* pcard gcard" type="button" aria-pressed="false" data-id="[0-9]+" data-score="[0-3]" data-cat="[a-z_]+" data-name="' $H)" "$G"
has "picker dialog with the item grid" '<dialog class="picker giftpick" aria-label="Choose a gift">.*<div class="itmwrap"><div class="itms pickgrid">' $H
has "Loved chip" 'Loved</span>' $H
has "Liked chip" 'Liked</span>' $H
has "Disliked chip" 'Disliked</span>' $H
has "loved scores highest" 'data-id="'$LOVED'" data-score="3"' $H
has "give form posts in place" 'class="giftgo" data-vform="1" hidden><input type="hidden" name="csrf"' $H
has "open button" 'data-giftopen="1">' $H
hasnt "no style= attribute" '\sstyle=' $H

echo "== garden pickers (garden.php)"
curl -s -b $J "$BASE/garden.php" > $H
pk() { tr '\n' ' ' < $H | grep -o "<dialog class=\"picker\" data-kind=\"$1\".*" | sed 's/<\/dialog>.*//'; }
for k in seed soil mulch; do
  c=$(pk $k | grep -oE 'class="itm itm--[culr][^"]* pcard" type="button" aria-pressed="false" data-id="[0-9]+" data-qty="[0-9]+"' | wc -l | tr -d ' ')
  echo "  $k squares: $c"; [ "$c" -ge 1 ] || echo "FAIL no $k squares"
  chk "$k: every square has its counter" "$(pk $k | grep -o '<span class="pccount" hidden></span>' | wc -l | tr -d ' ')" "$c"
  pk $k | grep -q '<div class="itmwrap"><div class="itms pickgrid">' && echo "ok   $k: item grid" || echo "FAIL $k: no item grid"
done
chk "soil: one square per soil improver" "$(pk soil | grep -o 'pcard" type="button"' | wc -l | tr -d ' ')" "$(db "SELECT COUNT(*) FROM user_items ui JOIN items i ON i.id=ui.item_id WHERE ui.user_id=$SID AND ui.qty>0 AND i.category='soil'")"
chk "seed: step buttons on every seed" "$(pk seed | grep -o '<span class="pcbtns" hidden><i data-step="-1" role="button"' | wc -l | tr -d ' ')" "$(pk seed | grep -o 'pcard" type="button"' | wc -l | tr -d ' ')"
pk soil | grep -q 'class="itm__note">' && echo "ok   soil: what it does as a note" || echo "FAIL soil: no note chip"
pk seed | grep -q 'class="itm__kind">Seeds' && echo "ok   seed: Seeds lifted into a chip" || echo "FAIL seed: no Seeds chip"
hasnt "no style= attribute" '\sstyle=' $H

echo "== town picker (bird seed / picnic) and market-day basket"
curl -s -b $J "$BASE/town.php?hub=1&spot=$GREEN" > $H
has "bird-seed picker squares" '<dialog class="picker townpick" data-kind="anyseed".*<div class="itms pickgrid"><button class="itm itm--[culr][^"]* pcard" type="button" data-id="[0-9]*">' $H
hasnt "town: no style= attribute" '\sstyle=' $H
curl -s -b $J "$BASE/marketday.php" > $H
B=$(n '<label class="mkopt itmcell"><input type="checkbox" name="items\[\]" value="[0-9]+"><span class="itm itm--[culr]' $H)
MK=0; if [ "$B" -ge 1 ]; then MK=1; echo "ok   basket picks are squares ($B)"; else echo "  (no basket form today: $(grep -o 'The market is open today\|Next market day[^<]*' $H | head -1))"; fi
hasnt "market day: no style= attribute" '\sstyle=' $H
hasnt "market day: old rows gone" 'class="mkopt"' $H

echo "== the browser check (390 px, light + dark)"
if command -v node >/dev/null && NODE_PATH=${NODE_PATH:-$(npm root -g 2>/dev/null)} node -e "require('playwright')" 2>/dev/null; then
  ISQ_CSS2="$HERE/../claude/build/css-items2.css" ISQ_NPC=$NID ISQ_SPOT=$GREEN ISQ_MARKET=$MK NODE_PATH=${NODE_PATH:-$(npm root -g 2>/dev/null)} node "$HERE/itemsq_check.js" "$BASE" "$SH" "$HH" "$HERE/../claude/build/css-items.css" $SHOTS
else echo "skip: no node + playwright here"; fi

grep -hE 'PHP (Warning|Notice|Deprecated|Fatal)' /tmp/isq-php.log | head -5 | sed 's/^/FAIL php: /'
