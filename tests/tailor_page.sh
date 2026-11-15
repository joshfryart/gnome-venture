GAME=$1; PORT=$2; ROUTER=$3; BASE=http://127.0.0.1:$PORT
# 2.7.00 the Tailor page (tailor.php) and its menu tile, on a walk.sh install (player sprout).
php -d session.save_path=/tmp -S 127.0.0.1:$PORT -t $GAME $ROUTER >/tmp/tp-php.log 2>&1 & PID=$!; sleep 1
trap "kill $PID 2>/dev/null" EXIT
csrf() { grep -o 'name="csrf" value="[^"]*"' "$1" | head -1 | sed 's/.*value="\([^"]*\)".*/\1/'; }
db() { php -r '$p=new PDO("sqlite:'$GAME'/data/game.sqlite"); foreach($p->query($argv[1])->fetchAll(PDO::FETCH_NUM) as $r) echo implode(" | ",$r),"\n";' "$1"; }
dbx() { php -r '$p=new PDO("sqlite:'$GAME'/data/game.sqlite"); $p->exec($argv[1]);' "$1"; }
A=/tmp/tp-ck; H=/tmp/tp.html; FAILS=0
chk() { if [ "$2" = "$3" ]; then echo "  ok   $1"; else echo "  FAIL $1 (got '$2', want '$3')"; FAILS=$((FAILS+1)); fi; }
has() { if grep -q "$2" $H; then echo "  ok   $1"; else echo "  FAIL $1 (no '$2')"; FAILS=$((FAILS+1)); fi; }
hasnt() { if grep -q "$2" $H; then echo "  FAIL $1 (has '$2')"; FAILS=$((FAILS+1)); else echo "  ok   $1"; fi; }
rm -f $A; curl -s -c $A -b $A $BASE/login.php > $H; curl -s -c $A -b $A -X POST $BASE/login.php --data-urlencode "csrf=$(csrf $H)" -d username=sprout -d 'password=TestPass123!' -o /dev/null
SID=$(db "SELECT id FROM users WHERE username='sprout'"); PL=$(db "SELECT id FROM plots WHERE user_id=$SID LIMIT 1")
dbx "INSERT OR REPLACE INTO settings (name,value) VALUES ('pfight_v1','1'); DELETE FROM garden_buildings WHERE building='tailor'; UPDATE users SET energy=80, level=30 WHERE id=$SID"
echo "== setting Off"
dbx "UPDATE settings SET value='0' WHERE name='pfight_v1'"
chk "the page redirects away" "$(curl -s -c $A -b $A $BASE/tailor.php -o /dev/null -w '%{http_code}')" 302
dbx "UPDATE settings SET value='1' WHERE name='pfight_v1'"
echo "== no Tailor"
chk "the page opens" "$(curl -s -c $A -b $A $BASE/tailor.php -o $H -w '%{http_code}')" 200
has "it says a Tailor is needed" 'need a <b>Tailor</b>'
chk "the Almanac page Wearables and the Tailor opens on the first visit" "$(db "SELECT COUNT(*) FROM user_encyclopedia ue JOIN encyclopedia_entries e ON e.id=ue.entry_id WHERE ue.user_id=$SID AND e.unlock_key='wearables'")" 1
hasnt "no Make list" '<h2>Make</h2>'
curl -s -c $A -b $A $BASE/garden.php -o $H; hasnt "no menu tile without a Tailor" 'href="[^"]*tailor.php"'
echo "== with a Tailor"
dbx "INSERT INTO garden_buildings (plot_id, building, built_at, level) VALUES ($PL, 'tailor', datetime('now'), 1)"
curl -s -c $A -b $A $BASE/garden.php -o $H; has "the menu tile appears" 'href="[^"]*tailor.php"'
chk "the page opens" "$(curl -s -c $A -b $A $BASE/tailor.php -o $H -w '%{http_code}')" 200
has "the Make list" '<h2>Make</h2>'
has "Flood Boots, Work Gloves and the Travel Cloak are on it" 'Travel Cloak'
has "the cut dropdown names the pieces" 'Puddle Hop'
has "Tailor power and the lining chance (38%)" '38%'
for s in coir-fibre:2 pine-resin:1 stag-beetle-shell:1; do dbx "INSERT OR REPLACE INTO user_items (user_id,item_id,qty) SELECT $SID, id, ${s##*:} FROM items WHERE slug='${s%%:*}'"; done
curl -s -c $A -b $A $BASE/tailor.php -o $H
chk "Make a pair of Work Gloves, cut a (redirect)" "$(curl -s -c $A -b $A -X POST $BASE/tailor.php --data-urlencode "csrf=$(csrf $H)" -d do=craft -d base=work-gloves -d cut=a -o /dev/null -w '%{http_code}')" 302
chk "the gloves are in the satchel" "$(db "SELECT qty FROM user_items ui JOIN items i ON i.id=ui.item_id WHERE ui.user_id=$SID AND i.slug='work-gloves'")" 1
curl -s -c $A -b $A $BASE/tailor.php -o $H
has "they are listed with their piece" 'Firm Grip'
has "with a Line it button" 'Line it'
has "and a Re-cut button" 'Re-cut to'
chk "Re-cut without a Thread is refused (nothing changes)" "$(curl -s -c $A -b $A -X POST $BASE/tailor.php --data-urlencode "csrf=$(csrf $H)" -d do=recut -d slug=work-gloves -o /dev/null -w '%{http_code}'; db "SELECT qty FROM user_items ui JOIN items i ON i.id=ui.item_id WHERE ui.user_id=$SID AND i.slug='work-gloves'" | head -1)" "3021"
grep -qE "(PHP )?(Warning|Notice|Deprecated|Fatal error)" /tmp/tp-php.log && { echo "  FAIL PHP warnings:"; grep -E "(PHP )?(Warning|Notice|Deprecated|Fatal error)" /tmp/tp-php.log | head -3; FAILS=$((FAILS+1)); }
[ $FAILS -eq 0 ] && echo ok || echo "$FAILS FAILED"
exit $FAILS
