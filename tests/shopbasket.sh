#!/bin/bash
# v2.0.67: the shop basket. One post with do=buy|sell and several qty[ID]=n buys or sells them all; errors per line; the bar is only there when you can shop.
# Run on a fresh SQLite install that walk.sh made (player "sprout"): shopbasket.sh GAME PORT ROUTER
GAME=$1; PORT=$2; ROUTER=$3; BASE=http://127.0.0.1:$PORT
php -d session.save_path=/tmp -S 127.0.0.1:$PORT -t $GAME $ROUTER >/tmp/sbk-php.log 2>&1 & PID=$!; sleep 1
trap "kill $PID 2>/dev/null" EXIT
H=/tmp/sbk.html; P=/tmp/sbk-post.html; M=/tmp/sbk-msg.txt; J=/tmp/sbk-ck
csrf() { grep -o 'name="csrf" value="[^"]*"' "$1" | head -1 | sed 's/.*value="\([^"]*\)".*/\1/'; }
db() { php -r '$p=new PDO("sqlite:'$GAME'/data/game.sqlite"); foreach($p->query($argv[1])->fetchAll(PDO::FETCH_NUM) as $r) echo implode(" | ",$r),"\n";' "$1"; }
dbx() { php -r '$p=new PDO("sqlite:'$GAME'/data/game.sqlite"); $p->exec($argv[1]);' "$1"; }
chk() { if [ "$2" = "$3" ]; then echo "ok   $1 = $2"; else echo "FAIL $1: got '$2' want '$3'"; fi; }
has() { if grep -q -- "$2" "$3"; then echo "ok   $1"; else echo "FAIL $1: no '$2'"; fi; }
hasnt() { if grep -q -- "$2" "$3"; then echo "FAIL $1: found '$2'"; else echo "ok   $1"; fi; }
# post PAGE args... : load PAGE for the csrf, post to it, follow the redirect; prints the first ok/err message
post() { local pg=$1; shift; curl -s -c $J -b $J "$BASE/$pg" > $H; curl -s -c $J -b $J "$BASE/$pg" --data-urlencode "csrf=$(csrf $H)" "$@" -L -o $P
  sed 's/<img[^>]*>//g;s/<li /\n<li /g' $P | grep -oE '<li class="ml (ok|err)[a-z ]* new"> ?[^<]*' | sed -E 's/<li class="ml (ok|err)[a-z ]*"> ?/\1: /' | awk '!s[$0]++' > $M; tr '\n' ' ' < $M; }
tprice() { tr '>' '\n' < $H | grep -oE "class=\"btile stile[^\"]*\" data-cat=\"[a-z]*\" data-id=\"$1\" data-price=\"[0-9]+\"" | grep -oE '[0-9]+"$' | tr -d '"'; }
coins() { db "SELECT coins FROM users WHERE username='sprout'"; }
stock() { db "SELECT current_stock FROM shop_stock WHERE id=$1"; }
have() { db "SELECT COALESCE((SELECT qty FROM user_items WHERE user_id=$SID AND item_id=$1),0)"; }

SID=$(db "SELECT id FROM users WHERE username='sprout'")
dbx "UPDATE users SET onboarded=1, tour_step=0, coins=5000 WHERE id=$SID"
SH=$(db "SELECT s.id FROM shops s JOIN locations l ON l.id=s.location_id WHERE l.kind='hub' AND s.shop_type='seeds' LIMIT 1")   # hub shops are reachable from anywhere
FAR=$(db "SELECT s.id FROM shops s JOIN locations l ON l.id=s.location_id WHERE l.kind='market' AND s.shop_type='seeds' AND l.id<>(SELECT home_village_id FROM users WHERE id=$SID) LIMIT 1")
rm -f $J; curl -s -c $J -b $J $BASE/login.php > $H; curl -s -c $J -b $J -X POST $BASE/login.php --data-urlencode "csrf=$(csrf $H)" -d username=sprout -d 'password=TestPass123!' -o /dev/null

echo "== the bar is on the page when you can shop"
curl -s -b $J "$BASE/shop.php?id=$SH" > $H
has "basket form on the Buy tab" '<form method="post" class="basket" data-mode="buy"' $H
has "Add to basket in the sheets" 'class="btn ghost sadd"' $H
has "Buy all button" 'Buy all</button>' $H
hasnt "no inline style in the bar" 'class="basket"[^>]*style=' $H
curl -s -b $J "$BASE/shop.php?id=$SH&tab=sell" > $H
has "basket form on the Sell tab" '<form method="post" class="basket" data-mode="sell"' $H
curl -s -b $J "$BASE/shop.php?id=$FAR" > $H
hasnt "no basket at a shop in another town" 'class="basket"' $H
hasnt "no Add to basket there either" 'sadd' $H

echo "== buy all: one post, several items"
curl -s -b $J "$BASE/shop.php?id=$SH" > $H   # restocks first
read A B C <<<"$(db "SELECT st.id FROM shop_stock st JOIN items i ON i.id=st.item_id WHERE st.shop_id=$SH AND st.current_stock>=3 AND i.category='seed' ORDER BY st.id LIMIT 3" | tr '\n' ' ')"
IA=$(db "SELECT item_id FROM shop_stock WHERE id=$A"); IB=$(db "SELECT item_id FROM shop_stock WHERE id=$B"); IC=$(db "SELECT item_id FROM shop_stock WHERE id=$C")
PA=$(tprice $A); PB=$(tprice $B); PC=$(tprice $C)
SA=$(stock $A); SB=$(stock $B); SC=$(stock $C); HA=$(have $IA); HB=$(have $IB); HC=$(have $IC); C0=$(coins)
echo "  stock ids $A $B $C at $PA $PB $PC"
echo "  -> $(post "shop.php?id=$SH" -d do=buy -d "qty[$A]=2" -d "qty[$B]=1" -d "qty[$C]=3")"
has "one message for all three" '^ok: You buy 2 × ' $M
chk "Petals taken" "$(coins)" "$((C0 - 2*PA - PB - 3*PC))"
chk "stock A" "$(stock $A)" "$((SA - 2))"; chk "stock B" "$(stock $B)" "$((SB - 1))"; chk "stock C" "$(stock $C)" "$((SC - 3))"
chk "satchel A" "$(have $IA)" "$((HA + 2))"; chk "satchel B" "$(have $IB)" "$((HB + 1))"; chk "satchel C" "$(have $IC)" "$((HC + 3))"

echo "== too many of one: that line fails, the rest go through"
SA=$(stock $A); SB=$(stock $B); C0=$(coins); PB=$(tprice $B)
echo "  -> $(post "shop.php?id=$SH" -d do=buy -d "qty[$A]=999" -d "qty[$B]=1")"
has "over-stock error" '^err: There aren’t 999' $M
chk "stock A untouched" "$(stock $A)" "$SA"; chk "stock B bought" "$(stock $B)" "$((SB - 1))"; chk "Petals for B only" "$(coins)" "$((C0 - PB))"

echo "== not enough Petals: stops at the line you can't afford"
dbx "UPDATE users SET coins=1 WHERE id=$SID"; SA=$(stock $A)
echo "  -> $(post "shop.php?id=$SH" -d do=buy -d "qty[$A]=1" -d "qty[$B]=1")"
has "can't afford error" '^err: You can’t afford' $M
chk "Petals unchanged" "$(coins)" 1; chk "stock unchanged" "$(stock $A)" "$SA"
dbx "UPDATE users SET coins=5000 WHERE id=$SID"

echo "== stock from another shop is refused, empty basket is refused"
OTHER=$(db "SELECT id FROM shop_stock WHERE shop_id<>$SH AND current_stock>0 LIMIT 1"); SO=$(stock $OTHER); C0=$(coins)
echo "  -> $(post "shop.php?id=$SH" -d do=buy -d "qty[$OTHER]=1")"
has "not sold here" 'isn’t sold here' $M
chk "other shop's stock untouched" "$(stock $OTHER)" "$SO"; chk "no Petals taken" "$(coins)" "$C0"
echo "  -> $(post "shop.php?id=$SH" -d do=buy -d "qty[$A]=0")"
has "empty basket message" 'Your basket is empty' $M

echo "== sell all"
T=$(db "SELECT id FROM items WHERE slug='tomato'"); Q=$(db "SELECT id FROM items WHERE slug='potato'")
dbx "DELETE FROM user_items WHERE user_id=$SID AND item_id IN ($T,$Q)"; dbx "INSERT INTO user_items (user_id,item_id,qty) VALUES ($SID,$T,10),($SID,$Q,5)"
curl -s -b $J "$BASE/shop.php?id=$SH&tab=sell" > $H; PT=$(tprice $T); PQ=$(tprice $Q); C0=$(coins)
echo "  prices tomato $PT potato $PQ -> $(post "shop.php?id=$SH&tab=sell" -d do=sell -d "qty[$T]=4" -d "qty[$Q]=5")"
has "one message for both" '^ok: You sell 4 × Tomato, 5 × Potato' $M
chk "Petals paid" "$(coins)" "$((C0 + 4*PT + 5*PQ))"
chk "tomatoes left" "$(have $T)" 6; chk "potatoes left" "$(have $Q)" 0
echo "  -> $(post "shop.php?id=$SH&tab=sell" -d do=sell -d "qty[$T]=50")"
has "can't sell more than you have" '^err: You don’t have 50' $M
chk "tomatoes still 6" "$(have $T)" 6

echo "== a shop in another town: nothing happens"
FS=$(db "SELECT id FROM shop_stock WHERE shop_id=$FAR AND current_stock>0 LIMIT 1"); SF=$(stock $FS); C0=$(coins)
echo "  -> $(post "shop.php?id=$FAR" -d do=buy -d "qty[$FS]=1")"
has "need to be there" 'You need to be in' $M
chk "stock untouched" "$(stock $FS)" "$SF"; chk "Petals untouched" "$(coins)" "$C0"

grep -hE 'PHP (Warning|Notice|Deprecated|Fatal)' /tmp/sbk-php.log | head -5 | sed 's/^/FAIL php: /'
