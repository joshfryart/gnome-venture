#!/bin/bash
# v1.9.3 upgrade test: install the PREVIOUS release (a git archive dir given as OLD_GAME), copy this game/ over it, bump the version in the copy, load pages.
# Usage: tests/upgrade193.sh OLD_GAME_DIR PORT ROUTER      (OLD_GAME_DIR has no data/ yet; the new files are copied over it)
HERE=$(cd "$(dirname "$0")" && pwd)
GAME=${1:?}; PORT=${2:-8794}; ROUTER=${3:-$HERE/router.php}
bash "$HERE/walk.sh" "$GAME" "$PORT" "$ROUTER" >/dev/null 2>&1
php -r '$p=new PDO("sqlite:'$GAME'/data/game.sqlite"); echo "before: db_version=",$p->query("select value from settings where name=\"db_version\"")->fetchColumn()," problems=",$p->query("select count(*) from problems")->fetchColumn(),"\n";'
cp -a "$HERE/../game/." "$GAME/"
V=$(grep -o "define('APP_VERSION', '[^']*')" "$GAME/includes/bootstrap.php" | grep -o "'[0-9.]*'" | tail -1 | tr -d "'")
sed -i "s/define('APP_VERSION', '$V')/define('APP_VERSION', '1.9.3')/" "$GAME/includes/bootstrap.php"
php -d session.save_path=/tmp -d display_errors=1 -d error_reporting=-1 -S 127.0.0.1:$PORT -t "$GAME" "$ROUTER" >/tmp/upg193-php.log 2>&1 & PID=$!; sleep 1
trap "kill $PID 2>/dev/null" EXIT
BASE=http://127.0.0.1:$PORT; C=/tmp/upg193-ck; rm -f $C
csrf() { grep -o 'name="csrf" value="[^"]*"' "$1" | head -1 | sed 's/.*value="\([^"]*\)".*/\1/'; }
curl -s -c $C -b $C $BASE/login.php > /tmp/upg193.html; curl -s -c $C -b $C -X POST $BASE/login.php --data-urlencode "csrf=$(csrf /tmp/upg193.html)" -d username=sprout -d 'password=TestPass123!' -o /dev/null
for pg in index.php world.php garden.php adventure.php town.php inventory.php book.php; do echo "$pg -> $(curl -s -c $C -b $C -o /dev/null -w '%{http_code}' $BASE/$pg)"; done
# a wander, to use the new code on an old world
SID=$(php -r '$p=new PDO("sqlite:'$GAME'/data/game.sqlite"); echo $p->query("select id from users where username=\"sprout\"")->fetchColumn();')
php -r '$p=new PDO("sqlite:'$GAME'/data/game.sqlite"); $p->exec("UPDATE users SET energy=40, tour_step=0 WHERE id='$SID'");'
curl -s -b $C -c $C $BASE/world.php > /tmp/upg193.html
curl -s -b $C -c $C -X POST $BASE/adventure.php --data-urlencode "csrf=$(csrf /tmp/upg193.html)" -d do=explore -o /dev/null
for i in 1 2 3; do curl -s -b $C -c $C $BASE/adventure.php > /tmp/upg193.html; curl -s -b $C -c $C -X POST $BASE/adventure.php --data-urlencode "csrf=$(csrf /tmp/upg193.html)" -d do=deeper -o /dev/null
  for k in 1 2 3 4 5 6 7 8; do curl -s -b $C -c $C $BASE/adventure.php > /tmp/upg193.html; t=$(csrf /tmp/upg193.html)
    if grep -q 'value="auto"' /tmp/upg193.html; then d=auto; elif grep -q 'value="attack"' /tmp/upg193.html; then d=attack; elif grep -q 'value="solve"' /tmp/upg193.html; then d=solve; elif grep -q 'value="choose"' /tmp/upg193.html; then d=choose; else break; fi
    curl -s -b $C -c $C -X POST $BASE/adventure.php --data-urlencode "csrf=$t" -d do=$d -d option=0 -o /dev/null; done; done
php -r '$p=new PDO("sqlite:'$GAME'/data/game.sqlite"); $q=fn($s)=>$p->query($s)->fetchColumn();
echo "after: db_version=",$q("select value from settings where name=\"db_version\"")," boot_failed_steps=[",$q("select value from settings where name=\"boot_failed_steps\""),"] flag=",$q("select value from settings where name=\"upg193_road_cond\""),"\n";
echo "problems=",$q("select count(*) from problems")," tagged problems=",$q("select count(*) from problems where cond<>\"\""),"/creatures=",$q("select count(*) from creatures where cond<>\"\""),"/gatherables=",$q("select count(*) from gatherables where cond<>\"\""),"\n";
echo "road_recent after a wander: ",$q("select road_recent from users where id='$SID'"),"\n";'
echo "error log: $( [ -f "$GAME/data/error-log.txt" ] && cat "$GAME/data/error-log.txt" || echo '(none)')"
echo "php log: $(grep -iE 'fatal|warning|notice|deprecated' /tmp/upg193-php.log | head -3 || true)"
kill $PID 2>/dev/null; trap - EXIT
php -d display_errors=1 "$HERE/roadlife.php" "$GAME" | grep -E "FAIL|passed|FAILED"
