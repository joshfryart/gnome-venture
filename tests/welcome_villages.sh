#!/bin/bash
# Welcome village cards (2.5.49): tests/welcome_villages.php on an installed copy, then the real Welcome page of a new gnome over HTTP (every card, every picture 200, no warning).
# Usage: tests/welcome_villages.sh GAME_COPY_DIR PORT ROUTER   (ci_suites.sh installs the copy first with walk.sh)
HERE=$(cd "$(dirname "$0")" && pwd)
GAME=$1; PORT=$2; ROUTER=$3
BASE=http://127.0.0.1:$PORT
TD="${TMPDIR:-/tmp}"
echo "== every village (in-process)"
php -d display_errors=1 -d error_reporting=-1 "$HERE/welcome_villages.php" "$GAME" || exit 1
php -d session.save_path=/tmp -S 127.0.0.1:$PORT -t "$GAME" "$ROUTER" >"$TD/wv-php.log" 2>&1 & PID=$!; sleep 1
trap "kill $PID 2>/dev/null" EXIT
C=$TD/wv-ck; H=$TD/wv.html; rm -f $C
csrf() { grep -o 'name="csrf" value="[^"]*"' "$1" | head -1 | sed 's/.*value="\([^"]*\)".*/\1/'; }
get() { curl -s -c $C -b $C "$BASE/$1" -o $H -w '%{http_code}'; }
post() { local page=$1; shift; curl -s -c $C -b $C -X POST "$BASE/$page" --data-urlencode "csrf=$(csrf $H)" "$@" -o $H -w '%{http_code}'; }
FAILS=0
chk() { if [ "$2" = 1 ]; then echo "  ok   $1"; else echo "  FAIL $1 $3"; FAILS=$((FAILS+1)); fi; }
echo "== the page itself"
get register.php >/dev/null; post register.php -d username=walker -d email=w@b.local -d password=TestPass123! -d password2=TestPass123! -d rules=1 -d age=1 >/dev/null
get welcome.php >/dev/null; post welcome.php -d do=gnome -d "gnome_name=Walker" -d 'hat=#2e7d4f' -d 'beard=#b5651d' >/dev/null
R=$(get 'welcome.php?step=place')
CARDS=$(grep -o 'class="vcard"' $H | wc -l | tr -d ' ')
chk "place step loads with village cards ($CARDS)" "$([ "$R" = 200 ] && [ "$CARDS" -ge 2 ] && echo 1)" "$R/$CARDS"
IMGS=$(grep -o 'class="pxl vil" src="[^"]*"' $H | sed 's/.*src="//; s/"$//')
BAD=0; for u in $IMGS; do c=$(curl -s -o /dev/null -w '%{http_code}' "$BASE$u" 2>/dev/null); [ "$c" = 200 ] || BAD=$((BAD+1)); done
chk "every village picture on the page loads (no broken image)" "$([ "$BAD" = 0 ] && echo 1)" "$BAD broken"
FALL=$(grep -c 'class="vil vfall ' $H)
IMGN=$(echo "$IMGS" | grep -c .)
chk "each card is a picture or a fallback ($IMGN + $FALL = $CARDS)" "$([ $((IMGN + FALL)) = "$CARDS" ] && echo 1)"
chk "no PHP warning on the page" "$(! grep -qE 'Warning:|Notice:|Deprecated:|Fatal error' $H && ! grep -qE 'PHP (Warning|Notice|Deprecated|Fatal)' "$TD/wv-php.log" && echo 1)"
echo
if [ $FAILS -eq 0 ]; then echo "all welcome village checks passed"; else echo "$FAILS FAILED"; exit 1; fi
