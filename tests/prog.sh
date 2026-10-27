#!/bin/bash
set -u
GAME=$1; PORT=$2; ROUTER=$3
BASE=http://127.0.0.1:$PORT
php -d session.save_path=/tmp -S 127.0.0.1:$PORT -t $GAME $ROUTER >/tmp/prog-php.log 2>&1 &
PID=$!; sleep 1
trap "kill $PID 2>/dev/null" EXIT
C=/tmp/prog-ck; rm -f $C
csrf() { grep -o 'name="csrf" value="[^"]*"' "$1" | head -1 | sed 's/.*value="\([^"]*\)".*/\1/'; }
get() { curl -s -c $C -b $C "$BASE/$1" -o /tmp/prog.html -w '%{http_code} %{redirect_url}'; }
post() { local page=$1; shift; local t; t=$(csrf /tmp/prog.html); curl -s -c $C -b $C -X POST "$BASE/$page" --data-urlencode "csrf=$t" "$@" -o /tmp/prog-post.html -w '%{http_code} %{redirect_url}'; }
flashes() { grep -oE '<li class="ml (ok|err)[^"]*">.*</li>' /tmp/prog.html | head -3 | sed -E 's/<small class="mlwhen">.*//; s/<li class="ml //; s/<[^>]*>//g'; }   # v2.0.x: flashes show in the message log
db() { php -r '$p=new PDO("sqlite:'$GAME'/data/game.sqlite"); foreach($p->query($argv[1])->fetchAll(PDO::FETCH_NUM) as $r) echo implode(" | ",$r),"\n";' "$1"; }
U="(SELECT id FROM users WHERE username='sprout')"
db "UPDATE users SET coins=5000, energy=40 WHERE username='sprout'"
get login.php >/dev/null; post login.php -d username=sprout -d password=TestPass123! >/dev/null
echo "== here tab"
get world.php >/dev/null; grep -oE 'Next on your journey:</b> <a[^>]*>[^<]*</a>[^.]*' /tmp/prog.html
grep -oE '<td>(🛡️|⚠️)[^<]*' /tmp/prog.html | sort | uniq -c
echo "== map"
get 'world.php?tab=map' >/dev/null
echo "Lv tags: $(grep -oE '>(🔒 )?Lv [0-9]+<' /tmp/prog.html | tr '\n' ' ')"
grep -oE 'Recommended level [0-9]+' /tmp/prog.html | head -1
CA=$(db "SELECT id FROM regions WHERE code='CA'"); NA=$(db "SELECT id FROM regions WHERE code='NA'")
get "world.php?tab=map&r=$CA" >/dev/null; grep -oE '🔒 You haven’t been here yet[^<]*' /tmp/prog.html
echo "travel to CA (locked): $(post world.php -d do=travel -d region_id=$CA)"; get world.php >/dev/null; flashes
echo "== route danger on a road into CA"
NATOWN=$(db "SELECT id FROM locations WHERE region_id=$NA AND kind='market' LIMIT 1")
php -r '
require "'$GAME'/includes/bootstrap.php"; require_once "'$GAME'/includes/adventure.php";
$u = q_one("SELECT * FROM users WHERE username = ?", ["sprout"]);
foreach (q("SELECT r.*, la.region_id AS ra, lb.region_id AS rb FROM routes r JOIN locations la ON la.id=r.a_id JOIN locations lb ON lb.id=r.b_id WHERE r.kind=\"road\" AND la.region_id<>lb.region_id LIMIT 4")->fetchAll() as $r) {
  [$a,$b,$s] = route_danger($u, $r); echo "road ", $r["ra"], "->", $r["rb"], ": $a-$b scaled=", (int)$s, "\n"; }
foreach (q("SELECT r.*, lb.region_id AS rb FROM routes r JOIN locations lb ON lb.id=r.b_id WHERE r.kind=\"side\" AND r.fixed=1 ORDER BY lb.region_id DESC LIMIT 2")->fetchAll() as $r) {
  [$a,$b,$s] = route_danger($u, $r); echo "fixed side in region ", $r["rb"], ": set ", $r["min_level"], "-", $r["max_level"], " now $a-$b\n"; }
require_once "'$GAME'/includes/explore.php";
$oc = q_val("SELECT id FROM locations WHERE region_id=(SELECT id FROM regions WHERE code=\"OC\") AND kind=\"village\" LIMIT 1");
echo "explore depth1 from NA town: ", explore_level($u, 1, ["from_id" => '$NATOWN']), "  from an OC village: ", explore_level($u, 1, ["from_id" => $oc]), "\n";
$s = next_region_suggestion($u); echo "next: ", $s["code"], " via ", $s["via"], "\n";
'
echo "== walk into CA (simulate arrive)"
php -r '
require "'$GAME'/includes/bootstrap.php"; require_once "'$GAME'/includes/adventure.php";
$u = q_one("SELECT * FROM users WHERE username = ?", ["sprout"]);
$to = q_val("SELECT id FROM locations WHERE region_id = (SELECT id FROM regions WHERE code=\"CA\") AND kind=\"market\"");
$exp = ["to_id" => $to, "route_id" => q_val("SELECT id FROM routes LIMIT 1"), "log" => "[]", "status" => "active", "level" => 1];
$xp0 = (int)$u["xp"];
arrive($u, $exp); echo implode("\n", array_column(json_decode($exp["log"] ?? "[]", true) ?: [], 1) ?: [$exp["log"]]), "\n";
echo "xp +", (int)q_val("SELECT xp FROM users WHERE id=?", [$u["id"]]) - $xp0, "\n";
' 2>&1 | tail -5
db "SELECT 'visited: '||group_concat(r.code) FROM region_visits v JOIN regions r ON r.id=v.region_id WHERE v.user_id=$U"
echo "travel home NA: $(post world.php -d do=travel -d region_id=$NA)"; get world.php >/dev/null; flashes
echo "travel to CA now: $(post world.php -d do=travel -d region_id=$CA)"; get world.php >/dev/null; flashes
NWE=$(db "SELECT id FROM regions WHERE code='NWE'")
echo "travel to NWE (locked): $(post world.php -d do=travel -d region_id=$NWE)"; get world.php >/dev/null; flashes
get 'world.php?tab=map' >/dev/null; echo "Lv tags: $(grep -oE '>(🔒 )?Lv [0-9]+<' /tmp/prog.html | head -4 | tr '\n' ' ')"
echo "== admin can turn the lock off and change start region"
db "UPDATE settings SET value='0' WHERE name='travel_needs_visit'"; db "INSERT INTO settings (name,value) SELECT 'travel_needs_visit','0' WHERE NOT EXISTS (SELECT 1 FROM settings WHERE name='travel_needs_visit')"
echo "travel to NWE (unlocked by setting): $(post world.php -d do=travel -d region_id=$NWE)"; get world.php >/dev/null; flashes
echo "php log errors:"; grep -iE "fatal|warning|notice|deprecated" /tmp/prog-php.log | head; if [ -f $GAME/data/error-log.txt ]; then grep -c . $GAME/data/error-log.txt; else echo "0 (no error log)"; fi   # no log file = no errors (grep -c on a missing file exits 2)
