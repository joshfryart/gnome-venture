#!/bin/bash
# v2.0.4 road text editor. Usage: tests/roadtext.sh GAME_COPY PORT [ROUTER]   (GAME_COPY with no data/: it is installed here by walk.sh)
HERE=$(cd "$(dirname "$0")" && pwd)
GAME=$1; PORT=${2:-8851}; ROUTER=${3:-$HERE/router.php}; BASE=http://127.0.0.1:$PORT
bash "$HERE/walk.sh" "$GAME" "$PORT" "$ROUTER" >/dev/null 2>&1
php -d session.save_path=/tmp -S 127.0.0.1:$PORT -t "$GAME" "$ROUTER" >/tmp/roadtext-php-$PORT.log 2>&1 & PID=$!; sleep 1
trap "kill $PID 2>/dev/null" EXIT
C=/tmp/roadtext-ck-$PORT; rm -f $C; H=/tmp/roadtext-$PORT.html
csrf() { grep -o 'name="csrf" value="[^"]*"' "$1" | head -1 | sed 's/.*value="\([^"]*\)".*/\1/'; }
fails=0; ok() { if [ "$2" = 1 ]; then echo "  ok   $1"; else echo "  FAIL $1"; fails=$((fails+1)); fi; }
curl -s -c $C -b $C $BASE/login.php -o $H; curl -s -c $C -b $C -X POST $BASE/login.php --data-urlencode "csrf=$(csrf $H)" -d username=admin -d password=TestPassword123 -o /dev/null
echo "== page"
code=$(curl -s -c $C -b $C "$BASE/admin/road_text.php" -o $H -w '%{http_code}'); ok "admin page 200" $([ "$code" = 200 ] && echo 1 || echo 0)
ok "lists counts" $(grep -q 'Road lines:' $H && echo 1 || echo 0)
ok "no php notices in page" $(grep -qiE 'Warning:|Notice:|Fatal|Deprecated' $H && echo 0 || echo 1)
curl -s -c $C -b $C "$BASE/admin/road_text.php?kind=line" -o $H
ok "lists lines" $(grep -q 'road.line.' $H && echo 1 || echo 0)
KEY=$(grep -o 'road\.line\.[0-9a-f]\{10\}' $H | head -1)
T=$(csrf $H)
echo "== csrf"
code=$(curl -s -c $C -b $C -X POST "$BASE/admin/road_text.php" -d "key=$KEY" -d 'body=hacked' -o /dev/null -w '%{http_code}'); ok "POST without csrf refused ($code)" $([ "$code" != 302 ] || [ "$(php -r '$p=new PDO("sqlite:'$GAME'/data/game.sqlite");echo $p->query("SELECT COUNT(*) FROM road_texts WHERE body IS NOT NULL")->fetchColumn();')" = 0 ] && echo 1 || echo 0)
ok "nothing written by it" $([ "$(php -r '$p=new PDO("sqlite:'$GAME'/data/game.sqlite");echo $p->query("SELECT COUNT(*) FROM road_texts WHERE body IS NOT NULL")->fetchColumn();')" = 0 ] && echo 1 || echo 0)
echo "== save / bad input"
post() { curl -s -c $C -b $C -X POST "$BASE/admin/road_text.php" --data-urlencode "csrf=$T" "$@" -o /dev/null -w '%{redirect_url}'; }
post -d "key=$KEY" -d 'body=<b>x</b>' -d status=done >/dev/null; curl -s -b $C -c $C "$BASE/admin/road_text.php?kind=line" -o $H
ok "HTML rejected" $(grep -q 'No HTML' $H && echo 1 || echo 0)
post -d "key=$KEY" --data-urlencode "body=$(printf 'x%.0s' $(seq 400))" -d status=done >/dev/null; curl -s -b $C -c $C "$BASE/admin/road_text.php?kind=line" -o $H
ok "too long rejected" $(grep -q 'Too long' $H && echo 1 || echo 0)
post -d "key=nope" -d 'body=a' >/dev/null
post -d "key=$KEY" --data-urlencode 'body=A brand new road line from the editor.' -d status=done >/dev/null
cat > /tmp/roadtext-$PORT.php <<PHP
<?php
\$_SERVER['SCRIPT_NAME'] = '/gnome.php';
require \$argv[1] . '/includes/bootstrap.php';
require_once \$argv[1] . '/includes/road_life.php';
\$k = \$argv[2]; \$mode = \$argv[3];
road_text_overrides(true);
\$n = 0; foreach (road_lines(true) as \$r) if (\$r['text'] === 'A brand new road line from the editor.') \$n++;
echo \$mode . ':' . \$n . ':' . count(road_lines()) . ':' . count(road_events(true)['ev']) . "\n";
PHP
OUT=$(php /tmp/roadtext-$PORT.php "$GAME" "$KEY" saved); echo "  $OUT"
ok "override shows in road_lines" $([[ "$OUT" == saved:1:* ]] && echo 1 || echo 0)
echo "== draft still shown, todo off, restore"
post -d "key=$KEY" --data-urlencode 'body=A brand new road line from the editor.' -d status=draft >/dev/null
ok "draft shown" $([[ "$(php /tmp/roadtext-$PORT.php "$GAME" "$KEY" d)" == d:1:* ]] && echo 1 || echo 0)
post -d "key=$KEY" --data-urlencode 'body=A brand new road line from the editor.' -d status=todo >/dev/null
ok "todo = file text" $([[ "$(php /tmp/roadtext-$PORT.php "$GAME" "$KEY" t)" == t:0:* ]] && echo 1 || echo 0)
post -d "key=$KEY" --data-urlencode 'body=A brand new road line from the editor.' -d status=done >/dev/null
post -d "key=$KEY" -d restore=1 >/dev/null
ok "restore clears" $([[ "$(php /tmp/roadtext-$PORT.php "$GAME" "$KEY" r)" == r:0:* ]] && echo 1 || echo 0)
echo "== events: only words change, counts equal"
EK=$(php -r '$_SERVER["SCRIPT_NAME"]="/gnome.php"; require $argv[1]."/includes/bootstrap.php"; require_once $argv[1]."/includes/road_life.php"; foreach (road_text_catalog() as $k=>$v) if (str_starts_with($k,"road.event.") && substr_count($k,".")==2) { echo $k; break; }' "$GAME")
curl -s -b $C -c $C "$BASE/admin/road_text.php?kind=event&open=$EK" -o $H
BEFORE=$(php -r '$_SERVER["SCRIPT_NAME"]="/gnome.php"; require $argv[1]."/includes/bootstrap.php"; require_once $argv[1]."/includes/road_life.php"; echo md5(json_encode(array_map(fn($e)=>[$e["cond"],$e["lands"],$e["region"],array_map(fn($o)=>[$o["stat"],$o["dc"],$o["win"],$o["lose"]],$e["opts"])],road_events()["ev"])));' "$GAME")
curl -s -b $C -c $C "$BASE/admin/road_text.php?kind=event" -o $H; T=$(csrf $H)
post -d "key=$EK" --data-urlencode 'body=Edited scene text.' -d status=done >/dev/null
AFTER=$(php -r '$_SERVER["SCRIPT_NAME"]="/gnome.php"; require $argv[1]."/includes/bootstrap.php"; require_once $argv[1]."/includes/road_life.php"; $e=road_events(true)["ev"]; echo md5(json_encode(array_map(fn($e)=>[$e["cond"],$e["lands"],$e["region"],array_map(fn($o)=>[$o["stat"],$o["dc"],$o["win"],$o["lose"]],$e["opts"])],$e))), " ", str_contains(json_encode($e), "Edited scene text.") ? 1 : 0;' "$GAME")
ok "event override applied, cond/stat/dc/effects identical" $([ "$AFTER" = "$BEFORE 1" ] && echo 1 || echo 0)
echo "== hooks (wonder, delve) and defensive loads"
OUT=$(php -r '$_SERVER["SCRIPT_NAME"]="/gnome.php"; require $argv[1]."/includes/bootstrap.php"; require_once $argv[1]."/includes/road_life.php";
 q("UPDATE road_texts SET body = ?, status = ? WHERE text_key LIKE ?", ["W intro.", "done", "road.wonder.%.intro"]); road_text_overrides(true);
 $r = road_text_wonder_apply(["any-wonder" => ["i","s","f"], "*easy" => ["m"]]); echo json_encode($r), "|", json_encode(road_text_delve_apply([["text"=>"Zed","cond"=>"-"]]));' "$GAME"); echo "  $OUT"
ok "hooks run without error" $([[ "$OUT" == *any-wonder* ]] && echo 1 || echo 0)
echo "== logs"
ok "php server log has no errors" $(grep -qiE 'warning|notice|fatal|deprecated' /tmp/roadtext-php-$PORT.log && echo 0 || echo 1)
ok "error log empty" $([ ! -s "$GAME/data/error-log.txt" ] && echo 1 || echo 0)
echo "fails: $fails"
