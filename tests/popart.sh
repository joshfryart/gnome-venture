#!/bin/bash
# v2.0.82: animated art INSIDE the activity-card popover only (Tier A CSS motion, Tier B drawn strips).
# Run on a fresh SQLite install that walk.sh made (player "sprout"): popart.sh GAME PORT ROUTER [SHOT_DIR]
# Markup: the popover picture has class doart-img, the card picture (.gcard__art) does not; data-anim / data-frames only when the -anim.png exists
# and only on the popover (act art and option icons), never on a card, never in a shop-tile sheet. CSS: every new keyframe and rule sits inside
# prefers-reduced-motion: no-preference and is scoped to dialog.isheet.dosheet[open]. Browser: tests/popart_check.js (Playwright, when installed).
GAME=$1; PORT=$2; ROUTER=$3; SHOTS=${4:-}; BASE=http://127.0.0.1:$PORT; HERE=$(cd "$(dirname "$0")" && pwd)
php -d session.save_path=/tmp -S 127.0.0.1:$PORT -t $GAME $ROUTER >/tmp/pa-php.log 2>&1 & PID=$!; sleep 1
# strips already drawn for real are set aside (and put back at the end), so every check starts from "no strip on disk"
ASIDE=$(mktemp -d); for d in acts ico; do mkdir -p "$ASIDE/$d"; for f in "$GAME"/assets/img/$d/*-anim.png*; do [ -e "$f" ] && mv "$f" "$ASIDE/$d/"; done; done
trap 'for d in acts ico; do for f in "$ASIDE"/$d/*; do [ -e "$f" ] && mv "$f" "$GAME/assets/img/$d/"; done; done; kill $PID 2>/dev/null' EXIT
H=/tmp/pa.html; J=/tmp/pa-ck
csrf() { grep -o 'name="csrf" value="[^"]*"' "$1" | head -1 | sed 's/.*value="\([^"]*\)".*/\1/'; }
db() { php -r '$p=new PDO("sqlite:'$GAME'/data/game.sqlite"); foreach($p->query($argv[1])->fetchAll(PDO::FETCH_NUM) as $r) echo implode(" | ",$r),"\n";' "$1"; }
dbx() { php -r '$p=new PDO("sqlite:'$GAME'/data/game.sqlite"); $p->exec($argv[1]);' "$1"; }
chk() { if [ "$2" = "$3" ]; then echo "ok   $1 = $2"; else echo "FAIL $1: got '$2' want '$3'"; fi; }
n() { grep -oE -- "$1" "$2" | wc -l | tr -d ' '; }
page() { curl -s -b $J -c $J "$BASE/$1" > $H; }

SID=$(db "SELECT id FROM users WHERE username='sprout'")
dbx "UPDATE users SET onboarded=1, tour_step=0, energy=50, coins=2000 WHERE id=$SID"
dbx "UPDATE settings SET value='' WHERE name IN ('season_force','weather_force','stop_daypart_force')"
VIL=$(db "SELECT l.id FROM locations l WHERE l.kind='village' AND l.stop_type='jetty' ORDER BY l.id LIMIT 1")
[ -n "$VIL" ] || VIL=$(db "SELECT l.id FROM locations l WHERE l.kind='village' AND l.stop_type<>'' ORDER BY l.id LIMIT 1")
dbx "UPDATE users SET location_id=$VIL, arrived_at='2031-01-01 00:00:09' WHERE id=$SID"
rm -f $J; curl -s -c $J -b $J $BASE/login.php > $H; curl -s -c $J -b $J -X POST $BASE/login.php --data-urlencode "csrf=$(csrf $H)" -d username=sprout -d 'password=TestPass123!' -o /dev/null
page town.php; page town.php

POPIMG=$(grep -oE '<span class="sico doart" aria-hidden="true"><img [^>]*>' $H)
CARDIMG=$(grep -oE '<span class="gcard__art"><img [^>]*>' $H)
NC=$(n 'class="gcard docard"' $H)
echo "== markup (no strips drawn yet)"
if [ "$NC" -ge 1 ]; then echo "ok   $NC felt cards"; else echo "FAIL no felt cards on the Do tab"; fi
if [ "$(echo "$POPIMG" | grep -c .)" -ge 1 ]; then echo "ok   $(echo "$POPIMG" | grep -c .) popover pictures"; else echo "FAIL no popover pictures found"; fi
chk "every popover picture has doart-img" "$(echo "$POPIMG" | grep -c 'class="pix doart-img"')" "$(echo "$POPIMG" | grep -c .)"
chk "no card picture has doart-img" "$(echo "$CARDIMG" | grep -c 'doart-img')" 0
chk "card pictures unchanged (class pix, lazy)" "$(echo "$CARDIMG" | grep -c 'class="pix" src=.*loading="lazy"')" "$(echo "$CARDIMG" | grep -c .)"
chk "no data-anim anywhere without a strip" "$(n 'data-anim' $H)" 0
chk "no style= attribute (CSP)" "$(n '\sstyle=' $H)" 0

echo "== strips drawn: data-anim only on the popover, only when the file exists"
php -r '$im=imagecreatetruecolor(144*3,108); imagepng($im,$argv[1]."/assets/img/acts/act-any-anim.png");' "$GAME"
ICO=$(php -r '$h=file_get_contents($argv[1]); preg_match_all("~<dialog class=\"isheet dosheet\".*?</dialog>~s",$h,$d); foreach($d[0] as $x){ if(preg_match("~<img class=\"ico pix\" src=\"[^\"]*?/ico/([a-z0-9-]+)\.(?:png|svg)~",$x,$m)){echo $m[1];break;} }' $H)
echo "  option icon inside a popover: ${ICO:-none}"
if [ -n "$ICO" ]; then php -r '$im=imagecreatetruecolor(16*4,16); imagepng($im,$argv[1]."/assets/img/ico/".$argv[2]."-anim.png");' "$GAME" "$ICO"; fi
page town.php
chk "every popover picture now has data-anim + 3 frames" "$(grep -oE '<span class="sico doart" aria-hidden="true"><img [^>]*data-anim="[^"]*act-any-anim.png[^"]*" data-frames="3" data-fps="6">' $H | wc -l | tr -d ' ')" "$(n 'class="isheet dosheet"' $H)"
chk "no card picture has data-anim" "$(grep -oE '<span class="gcard__art"><img [^>]*>' $H | grep -c data-anim)" 0
chk "data-anim only on popover pictures and option icons" "$(grep -oE '<img [^>]*data-anim=' $H | grep -vc 'doart-img\|class="ico pix"')" 0
if [ -n "$ICO" ]; then
  A=$(grep -oE "<img class=\"ico pix\" src=\"[^\"]*/ico/$ICO\.[a-z]+[^\"]*\"[^>]*data-anim=\"[^\"]*$ICO-anim.png[^\"]*\" data-frames=\"4\"" $H | wc -l | tr -d ' ')
  if [ "$A" -ge 1 ]; then echo "ok   option icon in the popover has data-anim, 4 frames ($A)"; else echo "FAIL option icon in the popover has no data-anim"; fi
  OUT=$(php -r '$h=file_get_contents($argv[1]); $o=preg_replace("~<dialog class=\"isheet dosheet\".*?</dialog>~s","",$h); echo substr_count($o,"ico/".$argv[2]."-anim")+substr_count(preg_replace("~<span class=\"sico doart\".*?</span>~s","",$o),"data-anim");' $H "$ICO")
  chk "outside a popover: no data-anim" "$OUT" 0
fi
rm -f "$GAME/assets/img/acts/act-any-anim.png"; [ -n "$ICO" ] && rm -f "$GAME/assets/img/ico/$ICO-anim.png"
page town.php
chk "strips removed: data-anim gone again" "$(n 'data-anim' $H)" 0

echo "== shop-tile sheets do not animate"
SH=$(db "SELECT s.id FROM shops s JOIN locations l ON l.id=s.location_id WHERE l.kind='hub' AND s.shop_type='seeds' LIMIT 1")
page "shop.php?id=$SH"
chk "shop tile sheets are not dosheet" "$(n 'class="isheet dosheet"' $H)" 0

echo "== CSS (assets/style.css)"
php -r '
$css = file_get_contents($argv[1] . "/assets/style.css"); $fail = 0;
$ok = function ($w, $c) use (&$fail) { echo ($c ? "ok   " : "FAIL ") . $w . "\n"; if (!$c) $fail++; };
$s = strpos($css, "popover art motion"); $ok("popover art motion block exists", $s !== false);
$blk = substr($css, (int)$s);
$head = "@media (prefers-reduced-motion: no-preference) {";
$m = strpos($blk, $head); $ok("block opens a reduced-motion no-preference media query", $m !== false);
$i = $m + strlen($head); $d = 1; $L = strlen($blk);
while ($i < $L && $d > 0) { $c = $blk[$i++]; if ($c === "{") $d++; elseif ($c === "}") $d--; }
$media = substr($blk, $m, $i - $m); $outside = substr($css, 0, (int)$s) . substr($blk, $i);
preg_match_all("/@keyframes\s+(gv-pop-[a-z-]+)/", $css, $mm); $names = array_unique($mm[1]);
$ok("keyframes gv-pop-* exist (" . count($names) . ")", count($names) >= 3);
foreach ($names as $nm) $ok("keyframes $nm sits inside the media query", substr_count($media, "@keyframes $nm") === 1 && substr_count($css, "@keyframes $nm") === 1);
$ok("no gv-pop animation outside the media query", !preg_match("/animation[^;]*gv-pop/", $outside));
preg_match_all("/([^{}@;]+)\{[^{}]*animation:[^}]*\}/", $media, $rules);
$bad = 0; foreach ($rules[1] as $sel) foreach (explode(",", $sel) as $one) if (strpos($one, "dialog.isheet.dosheet[open]") === false) $bad++;
$ok(count($rules[1]) . " animated rules, every selector scoped to dialog.isheet.dosheet[open] (bad: $bad)", count($rules[1]) >= 4 && $bad === 0);
$ok("transform only: no filter inside the gv-pop keyframes", !preg_match("/@keyframes\s+gv-pop[^{]*\{(?:[^{}]*\{[^{}]*\})*[^{}]*filter/", $css));
$ok("animations use steps()", substr_count($media, "steps(") >= 6);
$ok("bob is off for an element playing a drawn strip", strpos($media, ":not([data-animating])") !== false);
exit($fail ? 1 : 0);' "$GAME" || echo "FAIL css checks"
grep -q "function gvAnimArt" $GAME/assets/site.js && echo "ok   site.js has gvAnimArt" || echo "FAIL site.js has no gvAnimArt"
sed -n '/function gvAnimArt/,/^}/p' $GAME/assets/site.js | grep -q "prefers-reduced-motion: reduce" && echo "ok   gvAnimArt skips under reduced motion" || echo "FAIL gvAnimArt ignores reduced motion"

echo "== browser"
if command -v node >/dev/null && node -e "require('playwright')" 2>/dev/null; then
  mkdir -p "${SHOTS:-/tmp/pa-shots}"
  node "$HERE/popart_check.js" $BASE "$GAME" "${SHOTS:-/tmp/pa-shots}" "$ICO"
else
  echo "  (Playwright not installed: browser check skipped)"
fi
