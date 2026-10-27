#!/bin/bash
# v2.0.67: item squares (includes/item_square.php, mockup 4). Every shop tile, Curio / Dye Pot tile and Satchel card is an .itm square with
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

echo "== the browser check (390 px, light + dark)"
if command -v node >/dev/null && NODE_PATH=${NODE_PATH:-$(npm root -g 2>/dev/null)} node -e "require('playwright')" 2>/dev/null; then
  NODE_PATH=${NODE_PATH:-$(npm root -g 2>/dev/null)} node "$HERE/itemsq_check.js" "$BASE" "$SH" "$HH" "$HERE/../claude/build/css-items.css" $SHOTS
else echo "skip: no node + playwright here"; fi

grep -hE 'PHP (Warning|Notice|Deprecated|Fatal)' /tmp/isq-php.log | head -5 | sed 's/^/FAIL php: /'
