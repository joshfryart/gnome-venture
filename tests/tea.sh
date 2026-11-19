#!/bin/bash
# The Hovel tea kettle (setting tea_open; includes/tea.php, tea_view.php, assets/tea.js): tests/tea.php (rules, brewing, journal, kettles) on an
# installed copy (ci_suites.sh installs it with walk.sh first: player "sprout"), the JS twin against PHP (tests/tea_parity.js, needs node),
# then the pages: the kettle hit box in the room, the popover on Today, brewing through the form, closed = plain art.
# Usage: tests/tea.sh GAME_DIR PORT ROUTER
HERE=$(cd "$(dirname "$0")" && pwd)
GAME=$1; PORT=${2:-8987}; ROUTER=${3:-$HERE/router.php}; BASE=http://127.0.0.1:$PORT
T=$(mktemp -d); LOG=$T/php.log
OUT=$(php -d error_reporting=-1 -d display_errors=1 -d session.save_path=/tmp "$HERE/tea.php" "$GAME" "$T/parity.json" 2>&1); RC=$?
echo "$OUT"
LAST=$(echo "$OUT" | tail -1)
case "$LAST" in ok) ;; *FAILED) ;; *) echo "FAIL tea.php did not finish (last line: $LAST)"; exit 1;; esac
echo "$OUT" | grep -qE "^(PHP )?(Warning|Notice|Deprecated|Fatal error)" && { echo "FAIL tea.php printed PHP warnings"; exit 1; }
FAILS=0
echo "== the JS twin (assets/tea.js) against PHP"
if command -v node >/dev/null; then node "$HERE/tea_parity.js" "$GAME" "$T/parity.json" || FAILS=$((FAILS+1)); else echo "  FAIL node is not installed: the PHP / JS parity check did not run"; FAILS=$((FAILS+1)); fi
php -d session.save_path=$T -d display_errors=1 -S 127.0.0.1:$PORT -t $GAME $ROUTER >$LOG 2>&1 & PID=$!
for _ in $(seq 1 50); do curl -s -o /dev/null "$BASE/index.php" && break; sleep 0.2; done
trap "kill $PID 2>/dev/null; rm -rf $T" EXIT
C=$T/ck; H=$T/p.html
csrf() { grep -o 'name="csrf" value="[^"]*"' "$1" | head -1 | sed 's/.*value="\([^"]*\)".*/\1/'; }
get() { curl -s -c $C -b $C "$BASE/$1" -o $H -w '%{http_code}'; }
post() { local page=$1; shift; curl -s -c $C -b $C -X POST "$BASE/$page" --data-urlencode "csrf=$(csrf $H)" "$@" -o /dev/null -w '%{http_code} %{redirect_url}'; }
to() { curl -s -c $C -b $C "$BASE/$1" -o /dev/null -w '%{http_code} %{redirect_url}'; }
dbx() { php -r '$p=new PDO("sqlite:'$GAME'/data/game.sqlite"); $p->exec($argv[1]);' "$1"; }
dbv() { php -r '$p=new PDO("sqlite:'$GAME'/data/game.sqlite"); echo $p->query($argv[1])->fetchColumn();' "$1"; }
set_() { dbx "INSERT OR REPLACE INTO settings (name, value) VALUES ('$1', '$2')"; }
chk() { if [ "$2" = "$3" ]; then echo "  ok   $1"; else echo "  FAIL $1 (got '$2', want '$3')"; FAILS=$((FAILS+1)); fi; }
has() { if grep -q -- "$2" $H; then echo "  ok   $1"; else echo "  FAIL $1 (no '$2')"; FAILS=$((FAILS+1)); fi; }
hasnt() { if grep -q -- "$2" $H; then echo "  FAIL $1 (found '$2')"; FAILS=$((FAILS+1)); else echo "  ok   $1"; fi; }
noerr() { if grep -qiE 'fatal error|warning:|notice:|deprecated:' $H; then echo "  FAIL $1 has a PHP error"; FAILS=$((FAILS+1)); fi; }
SID=$(dbv "SELECT id FROM users WHERE username='sprout'")
dbx "UPDATE users SET tour_step = 0, tour_ask = 0, tea = NULL, tea_day = NULL, tea_name = NULL, kettle = 0, coins = 500 WHERE id = $SID; DELETE FROM user_tea_journal WHERE user_id = $SID"
for s in tea mint cardamom cinnamon ginger lemon; do dbx "DELETE FROM user_items WHERE user_id = $SID AND item_id = (SELECT id FROM items WHERE slug = '$s'); INSERT INTO user_items (user_id, item_id, qty) SELECT $SID, id, 3 FROM items WHERE slug = '$s'"; done
set_ home_slim 1; set_ game_clock_on 1
dbx "DELETE FROM settings WHERE name = 'tea_open'"
get login.php >/dev/null; post login.php -d username=sprout -d 'password=TestPass123!' >/dev/null

echo "== default (Admins only): a player sees plain art"
chk "home is 200" "$(get gnome.php)" 200; noerr home
has "the room picture (Today: the whole room with its things)" 'class="hroom hroom-full hroom-things'; has "...the other things are links" '<a class="ht ht-door"'
hasnt "no kettle hit box" 'hd-kettle'; hasnt "no popover" 'id="htea"'; hasnt "no tea script" 'assets/tea.js'; hasnt "no kettle line" 'hs-teal'
get 'gnome.php?tab=furnish' >/dev/null; hasnt "Furnish: no kettle hit box in the whole room" 'hd-kettle'
chk "?tea=1 draws nothing" "$(get 'gnome.php?tea=1' >/dev/null; grep -c 'id="htea"' $H)" 0
chk "hovel.php?t=tea is the plain hovel redirect" "$(to 'hovel.php?t=tea')" "302 $BASE/gnome.php?tab=today"
get gnome.php >/dev/null
chk "a brew POST is refused" "$(post hovel.php -d do=brew -d base=mint -d 'c[]=mint')" "302 $BASE/gnome.php"
chk "...nothing brewed, nothing spent" "$(dbv "SELECT COALESCE(tea_name, '-') || ':' || (SELECT qty FROM user_items WHERE user_id = $SID AND item_id = (SELECT id FROM items WHERE slug = 'mint')) FROM users WHERE id = $SID")" "-:3"
set_ tea_open off
get gnome.php >/dev/null; hasnt "Off: no kettle hit box" 'hd-kettle'; hasnt "...no popover" 'id="htea"'

echo "== Everyone: the kettle is a button"
set_ tea_open everyone
chk "home is 200" "$(get gnome.php)" 200; noerr home
has "the kettle link in the banner room, with the dialog hook" '<a class="hd hd-kettle" href="/gnome.php?tea=1#htea" data-hdlg="htea"'
has "...a 64 x 64 hit box" '<rect class="hd-hit" x="312" y="142" width="64" height="64"/></a>'
has "the room is a group now (the link is reachable)" 'role="group" aria-label="Your hovel'
has "the popover on Today, closed" '<dialog class="hpick htea" id="htea" aria-labelledby="htea-h"><div'
has "the tea script" 'assets/tea.js'; has "the plain link on Today" 'class="hs-newsl hs-teal"'
has "cards from the satchel" 'data-tea-ing="cardamom"'; hasnt "...only what is held" 'data-tea-ing="rooibos"'
has "Brew posts to hovel.php" 'name="do" value="brew" data-tea-brew'
has "the kettle line" 'Dented Tin Kettle'; has "the journal with hidden names" 'Tea Journal · 0 of 20 found'
chk "no inline style in the popover" "$(grep -o '<dialog class="hpick htea".*</dialog>' $H | grep -c 'style=')" 0
get 'gnome.php?tab=furnish' >/dev/null; has "Furnish: the kettle link in the whole room too" 'hd-kettle'; has "...beside the decor pickers" 'data-hdlg="hpick-rug"'
get 'gnome.php?tab=gnome' >/dev/null; has "Gnome tab: the banner kettle is a plain link to Today" 'href="/gnome.php?tea=1#htea"'; hasnt "...no popover on this tab" 'id="htea"'
chk "hovel.php?t=tea -> the popover on Today" "$(to 'hovel.php?t=tea')" "302 $BASE/gnome.php?tea=1#htea"
get 'gnome.php?tea=1' >/dev/null; has "?tea=1: the popover is drawn open in the page (no script)" 'id="htea" aria-labelledby="htea-h" open>'
echo "== a real browser (tests/tea_page.js; skipped without playwright)"
stock() { dbx "UPDATE users SET tea = NULL, tea_day = NULL, tea_name = NULL, kettle = 0, coins = 500 WHERE id = $SID; DELETE FROM user_tea_journal WHERE user_id = $SID"
  for s in tea mint cardamom cinnamon ginger lemon; do dbx "DELETE FROM user_items WHERE user_id = $SID AND item_id = (SELECT id FROM items WHERE slug = '$s'); INSERT INTO user_items (user_id, item_id, qty) SELECT $SID, id, 3 FROM items WHERE slug = '$s'"; done; }
NP=${NODE_PATH:-$(npm root -g 2>/dev/null)}
if command -v node >/dev/null && NODE_PATH=$NP node -e "require('playwright')" 2>/dev/null; then
  POUT=$(SHOTS=${TEASHOTS:-} NODE_PATH=$NP node "$HERE/tea_page.js" "$BASE" 2>&1); echo "$POUT"
  echo "$POUT" | grep -q '^  ok   no script errors' || { echo "  FAIL the browser pass did not finish"; FAILS=$((FAILS+1)); }
  FAILS=$((FAILS + $(echo "$POUT" | grep -c '^  FAIL')))
else echo "  ok   browser pass: skipped (no playwright)"; fi
stock
echo "== no script: Show the cup, then Brew"
chk "Show the cup -> the page with the cup in the address" "$(post hovel.php -d do=tea_preview -d base=tea -d 'c[]=tea' -d 'c[]=cardamom' -d 'c[]=cinnamon' -d 'c[]=ginger')" "302 $BASE/gnome.php?tea=1&base=tea&c=ginger%2Ccardamom%2Ccinnamon#htea"
get 'gnome.php?tea=1&base=tea&c=ginger%2Ccardamom%2Ccinnamon' >/dev/null; noerr preview
has "...the preview names the tea" '<b>Masala Chai</b> <span class="tea-stamp">named tea · +1 steep</span>'; has "...and its sum" 'Lore: steep 5 × 4 ÷ 8 = 2, cap 1'
chk "...nothing spent by looking" "$(dbv "SELECT qty FROM user_items WHERE user_id = $SID AND item_id = (SELECT id FROM items WHERE slug = 'tea')")" 3
chk "no CSRF, no brew" "$(curl -s -c $C -b $C -X POST "$BASE/hovel.php" -d do=brew -d base=mint -d 'c[]=mint' -o /dev/null -w '%{http_code}')" 400
chk "Brew" "$(post hovel.php -d do=brew -d base=tea -d 'c[]=tea' -d 'c[]=cardamom' -d 'c[]=cinnamon' -d 'c[]=ginger')" "302 $BASE/gnome.php?tea=1#htea"
chk "...the cup is in its slot" "$(dbv "SELECT tea_name || ' ' || tea || ' ' || (tea_day = CAST(game_day AS TEXT)) FROM users WHERE id = $SID")" 'Masala Chai {"lore":1,"charm":1} 1'
chk "...one of each spent" "$(dbv "SELECT GROUP_CONCAT(qty) FROM (SELECT ui.qty FROM user_items ui JOIN items i ON i.id = ui.item_id WHERE ui.user_id = $SID AND i.slug IN ('tea', 'cardamom', 'cinnamon', 'ginger') ORDER BY i.slug)")" "2,2,2,2"
chk "...stamped in the journal" "$(dbv "SELECT tea_slug || ':' || times FROM user_tea_journal WHERE user_id = $SID")" "masala-chai:1"
get 'gnome.php?tea=1' >/dev/null; noerr "after a brew"
has "today's cup shows (the side tie goes to Charm)" 'Today’s cup: Masala Chai</b> · Lore +1, Charm +1 · until you sleep'; has "...the journal has it" '<span class="tx"><b>Masala Chai</b><span>Spice first'; has "...the kettle line on Today names it" 'Today’s cup: Masala Chai · Lore +1, Charm +1'
get 'gnome.php?tab=stats&s=lore' >/dev/null; has "Stats: the tea in Active effects" '<b>Tea:</b> Lore +1, Charm +1 · until you sleep</li>'
get 'gnome.php?tea=1' >/dev/null
chk "a second brew without the confirm is refused (the cup stays in the address)" "$(post hovel.php -d do=brew -d base=mint -d 'c[]=mint')" "302 $BASE/gnome.php?tea=1&base=mint&c=#htea"
chk "...the first cup stays" "$(dbv "SELECT tea_name FROM users WHERE id = $SID")" "Masala Chai"
get 'gnome.php?tea=1' >/dev/null
chk "with the confirm it replaces the first" "$(post hovel.php -d do=brew -d base=mint -d 'c[]=mint' -d confirm=1; dbv "SELECT tea_name || ' ' || tea FROM users WHERE id = $SID")" "302 $BASE/gnome.php?tea=1#hteaMint Tea {\"sense\":1}"
echo "== the Copper Kettle, and a sleep"
get 'gnome.php?tea=1' >/dev/null
chk "buy the Copper Kettle" "$(post hovel.php -d do=kettle_buy; dbv "SELECT kettle || ':' || coins FROM users WHERE id = $SID")" "302 $BASE/gnome.php?tea=1#htea1:350"
get 'gnome.php?tea=1' >/dev/null; has "the kettle line: Copper, next Cast-Iron at 8 teas" '<p class="tea-pg"><b>Cast-Iron at 8 teas</b><span>2/8</span></p>'; has "...and the sub line" 'Copper · Cast-Iron at 8 teas (2/8)'
chk "a sleep" "$(post hovel.php -d do=home_sleep -d back=today)" "302 $BASE/gnome.php?tab=today"
get 'gnome.php?tea=1' >/dev/null; hasnt "after the sleep: no cup today" 'Today’s cup'; hasnt "...no confirm box" 'name="confirm"'; has "...the journal keeps both teas" 'Tea Journal · 2 of 20 found'
get 'gnome.php?tab=stats&s=lore' >/dev/null; hasnt "...and no tea in Active effects" '<b>Tea:</b>'
echo "== without the slim home: the kettle is a page"
set_ home_slim 0
chk "hovel.php?t=tea is a page" "$(get 'hovel.php?t=tea')" 200; noerr "the tea page"
has "...the panel" 'class="box htea-page"'; has "...its form" 'class="tea-form"'; has "...posts come back here" 'name="back" value="hovel"'
get hovel.php >/dev/null; has "the Hovel has a Tea tab" 'href="/hovel.php?t=tea"'
get 'hovel.php?t=tea' >/dev/null
chk "Brew from the page comes back to the page" "$(post hovel.php -d do=brew -d base=mint -d 'c[]=mint')" "302 $BASE/hovel.php?t=tea"
set_ game_clock_on 0
chk "the page works with the game clock off" "$(get 'hovel.php?t=tea')" 200; noerr "the tea page, clock off"
set_ tea_open off
set_ home_slim 1
get 'gnome.php' >/dev/null; hasnt "Off again: no kettle hit box" 'hd-kettle'; hasnt "...no popover" 'htea'; hasnt "...no tea script" 'assets/tea.js'
echo "== php errors"
grep -iE 'fatal|warning|notice|deprecated' $LOG && FAILS=$((FAILS+1)) || echo "(none)"
dbx "DELETE FROM settings WHERE name IN ('home_slim', 'game_clock_on', 'tea_open')"
[ "$LAST" = "ok" ] || FAILS=$((FAILS+1))
[ $FAILS -eq 0 ] && echo "tea: all ok" || echo "$FAILS FAILED"
[ $FAILS -eq 0 ]
