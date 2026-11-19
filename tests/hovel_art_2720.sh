#!/bin/bash
# 2.7.20 hovel room art (aseprite-source/extras-pixel/scripts/hovel-room-2720.py): tests/hovel_art_2720.php on an installed copy (ci_suites.sh installs it
# with walk.sh first: player "sprout"), then the Today page over HTTP: renders by day, at night (night window) and with each kettle tier (its overlay).
# Usage: tests/hovel_art_2720.sh GAME_DIR PORT ROUTER
HERE=$(cd "$(dirname "$0")" && pwd)
GAME=$1; PORT=${2:-8979}; ROUTER=${3:-$HERE/router.php}; BASE=http://127.0.0.1:$PORT
T=$(mktemp -d); LOG=$T/php.log
OUT=$(php -d error_reporting=-1 -d display_errors=1 -d session.save_path=/tmp "$HERE/hovel_art_2720.php" "$GAME" 2>&1); RC=$?
echo "$OUT"
LAST=$(echo "$OUT" | tail -1)
case "$LAST" in ok) ;; *FAILED) ;; *) echo "FAIL hovel_art_2720.php did not finish (last line: $LAST)"; exit 1;; esac
echo "$OUT" | grep -qE "^(PHP )?(Warning|Notice|Deprecated|Fatal error)" && { echo "FAIL hovel_art_2720.php printed PHP warnings"; exit 1; }
FAILS=0
php -d session.save_path=$T -d display_errors=1 -S 127.0.0.1:$PORT -t $GAME $ROUTER >$LOG 2>&1 & PID=$!
for _ in $(seq 1 50); do curl -s -o /dev/null "$BASE/index.php" && break; sleep 0.2; done
trap "kill $PID 2>/dev/null; rm -rf $T" EXIT
C=$T/ck; H=$T/p.html
csrf() { grep -o 'name="csrf" value="[^"]*"' "$1" | head -1 | sed 's/.*value="\([^"]*\)".*/\1/'; }
get() { curl -s -c $C -b $C "$BASE/$1" -o $H -w '%{http_code}'; }
post() { local page=$1; shift; curl -s -c $C -b $C -X POST "$BASE/$page" --data-urlencode "csrf=$(csrf $H)" "$@" -o /dev/null -w '%{http_code}'; }
dbx() { php -r '$p=new PDO("sqlite:'$GAME'/data/game.sqlite"); $p->exec($argv[1]);' "$1"; }
dbv() { php -r '$p=new PDO("sqlite:'$GAME'/data/game.sqlite"); echo $p->query($argv[1])->fetchColumn();' "$1"; }
set_() { dbx "INSERT OR REPLACE INTO settings (name, value) VALUES ('$1', '$2')"; }
chk() { if [ "$2" = "$3" ]; then echo "  ok   $1"; else echo "  FAIL $1 (got '$2', want '$3')"; FAILS=$((FAILS+1)); fi; }
has() { if grep -q -- "$2" $H; then echo "  ok   $1"; else echo "  FAIL $1 (no '$2')"; FAILS=$((FAILS+1)); fi; }
hasnt() { if grep -q -- "$2" $H; then echo "  FAIL $1 (found '$2')"; FAILS=$((FAILS+1)); else echo "  ok   $1"; fi; }
noerr() { if grep -qiE 'fatal error|warning:|notice:|deprecated:' $H; then echo "  FAIL $1 has a PHP error"; FAILS=$((FAILS+1)); fi; }
SID=$(dbv "SELECT id FROM users WHERE username='sprout'")
dbx "UPDATE users SET tour_step = 0, tour_ask = 0, location_id = home_village_id, game_minute = 600, kettle = 0 WHERE id = $SID"
set_ home_slim 1; set_ game_clock_on 1; set_ tea_open everyone
get login.php >/dev/null; post login.php -d username=sprout -d 'password=TestPass123!' >/dev/null

echo "== the Today page with the new art"
chk "by day: 200" "$(get gnome.php)" 200; noerr "by day"
has "...the big gnome" 'assets/img/sprite/gnome-home-big.png'
has "...the pixel steam" 'assets/img/fx/fx-steam-a.png'
hasnt "...the day window, not the night one" 'hovel-window-[a-z]*-night.png'
for f in sprite/gnome-home-big.png fx/fx-steam-a.png scenes/hovel-kettle-samovar.png scenes/hovel-window-plain-night.png ico/ico-kettle-tin.png; do
  chk "...$f is served as a PNG" "$(curl -s -o /dev/null -w '%{http_code} %{content_type}' "$BASE/assets/img/$f")" "200 image/png"
done
dbx "UPDATE users SET game_minute = 1380 WHERE id = $SID"
chk "at 23:00: 200" "$(get gnome.php)" 200; noerr "at night"
has "...a night room" 'class="hroom hroom-full hroom-things lamp-on dp-'
has "...the night window" 'scenes/hovel-window-[a-z]*-night.png'
dbx "UPDATE users SET game_minute = 600 WHERE id = $SID"
for t in 1:copper 2:castiron 3:samovar; do
  dbx "UPDATE users SET kettle = ${t%%:*} WHERE id = $SID"
  chk "kettle ${t%%:*}: 200" "$(get gnome.php)" 200; noerr "kettle ${t%%:*}"
  has "...the ${t#*:} overlay" "<image class=\"hr-kettle hr-kettle-${t#*:}\" href=\"/assets/img/scenes/hovel-kettle-${t#*:}.png"
  chk "...the popover's kettle icon (heading and kettle line)" "$(get 'gnome.php?tea=1' >/dev/null; grep -o "ico-kettle-${t#*:}.png" $H | wc -l | tr -d ' ')" 2
done
dbx "UPDATE users SET kettle = 0 WHERE id = $SID"
if [ $FAILS -ne 0 ] || [ $RC -ne 0 ]; then echo "$FAILS FAILED"; exit 1; fi
echo ok
