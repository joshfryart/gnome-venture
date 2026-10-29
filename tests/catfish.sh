#!/usr/bin/env bash
# Cat Fish (catfish.php, catfish_api.php, includes/catfish.php): gate, shelter, adoption, name cleaning, tick and away pay-out, upgrades, API guards, generator and shelter determinism.
GAME=$1; PORT=$2; ROUTER=$3; BASE=http://127.0.0.1:$PORT
W=$(mktemp -d); trap "kill $PID 2>/dev/null; rm -rf $W" EXIT
php -d session.save_path=/tmp -S 127.0.0.1:$PORT -t $GAME $ROUTER >$W/php.log 2>&1 & PID=$!; sleep 1
csrf() { grep -o 'name="csrf" value="[^"]*"' "$1" | head -1 | sed 's/.*value="\([^"]*\)".*/\1/'; }
dbv() { php -r '$p=new PDO("sqlite:'$GAME'/data/game.sqlite"); echo $p->query($argv[1])->fetchColumn();' "$1"; }
dbx() { php -r '$p=new PDO("sqlite:'$GAME'/data/game.sqlite"); $p->exec($argv[1]);' "$1"; }
login() { rm -f $1; curl -s -c $1 -b $1 $BASE/login.php > $W/l.html; curl -s -c $1 -b $1 -X POST $BASE/login.php --data-urlencode "csrf=$(csrf $W/l.html)" -d username=$2 --data-urlencode "password=$3" -o /dev/null; }
ok() { if [ "$2" = "$3" ]; then echo "ok   $1"; else echo "FAIL $1 (got '$2', want '$3')"; fi; }
js() { php -r '$j=json_decode(stream_get_contents(STDIN), true); echo is_array($j) ? var_export($j[$argv[1]] ?? null, true) : "nojson";' "$1"; }
# jp: one value from a JSON reply by dotted path (view.cat.mood); bools as true/false
jp() { php -r '$v=json_decode(stream_get_contents(STDIN), true); foreach (explode(".", $argv[1]) as $k) { $v = is_array($v) ? ($v[$k] ?? null) : null; } echo is_bool($v) ? ($v ? "true" : "false") : (is_array($v) ? json_encode($v) : (string)$v);' "$1"; }
setg() { dbx "INSERT OR REPLACE INTO settings (name,value) VALUES ('$1','$2')"; }
cfapi() { curl -s -b $W/p -X POST $BASE/catfish_api.php --data-urlencode "csrf=$CS" "$@"; }
cfpost() { curl -s -b $W/p -o /dev/null -w '%{http_code}' -X POST $BASE/catfish.php --data-urlencode "csrf=$CS" "$@"; }
# shelter seeds for a gnome on a fixed day
shelter() { php -r 'function is_admin(){return false;} function setting($n){return "";} require $argv[1]; echo json_encode(array_column(catfish_shelter((int)$argv[2], "2026-10-29"), "seed"));' "$GAME/includes/catfish.php" "$1"; }

login $W/a admin TestPassword123
login $W/p sprout 'TestPass123!'
dbx "DELETE FROM settings WHERE name IN ('catfish_open')"

# gate
ok "gate off: player is sent away" "$(curl -s -b $W/p -o /dev/null -w '%{http_code}' $BASE/catfish.php)" 302
curl -s -b $W/p $BASE/games.php > $W/h.html; ok "hub: no Cat Fish link while off" "$(grep -c 'href="[^"]*catfish.php"' $W/h.html)" 0
setg catfish_open 1
ok "gate on: player gets the page" "$(curl -s -b $W/p -o /dev/null -w '%{http_code}' $BASE/catfish.php)" 200
curl -s -b $W/p $BASE/games.php > $W/h.html; ok "hub: Cat Fish link shows" "$(grep -c 'href="[^"]*catfish.php"' $W/h.html)" 1

# shelter page, no cat yet
curl -s -b $W/p $BASE/catfish.php > $W/c0.html
CS=$(csrf $W/c0.html)
ok "no cat: 3 shelter forms" "$(grep -c 'name="do" value="adopt"' $W/c0.html)" 3
UID_=$(dbv "SELECT id FROM users WHERE username='sprout'")
ok "shelter: same gnome, same day, same cats" "$(shelter $UID_)" "$(shelter $UID_)"
ok "shelter: two gnomes get different cats" "$([ "$(shelter $UID_)" != "$(shelter $((UID_+1)))" ] && echo y || echo n)" y

# adoption
ok "adopt slot 0 (first cat is free): redirect" "$(cfpost -d do=adopt -d slot=0 --data-urlencode name=Biscuit2)" 302
ok "adopt slot 0: one cat in the database" "$(dbv "SELECT COUNT(*) FROM cats WHERE user_id=$UID_")" 1
ok "adopt slot 0: active cat set" "$(dbv "SELECT CASE WHEN active_cat_id IS NULL THEN 'n' ELSE 'y' END FROM catfish_state WHERE user_id=$UID_")" y
ok "adopt slot 0: named Biscuit2" "$(dbv "SELECT name FROM cats WHERE user_id=$UID_")" Biscuit2
ok "adopt slot 0: the cat is the shelter's slot 0" "$(dbv "SELECT seed FROM cats WHERE user_id=$UID_")" "$(php -r 'function is_admin(){return false;} function setting($n){return "";} require $argv[1]; echo catfish_shelter((int)$argv[2])[0]["seed"];' "$GAME/includes/catfish.php" "$UID_")"
cfpost -d do=adopt -d slot=0 --data-urlencode name=Again >/dev/null
ok "adopt the same cat again is refused (still one row)" "$(dbv "SELECT COUNT(*) FROM cats WHERE user_id=$UID_")" 1
dbx "UPDATE catfish_state SET kibble=0 WHERE user_id=$UID_"
cfpost -d do=adopt -d slot=1 --data-urlencode name=Second >/dev/null
ok "adopt slot 1 with 0 Kibble is refused (still one row)" "$(dbv "SELECT COUNT(*) FROM cats WHERE user_id=$UID_")" 1

# name cleaning
CID=$(dbv "SELECT id FROM cats WHERE user_id=$UID_")
cfpost -d do=rename -d cat=$CID --data-urlencode "name=<b>x</b>" >/dev/null
ok "rename: no angle brackets stored" "$(dbv "SELECT name FROM cats WHERE id=$CID" | grep -c '[<>]')" 0
ok "rename: tags reduced to letters (bxb)" "$(dbv "SELECT name FROM cats WHERE id=$CID")" bxb
cfpost -d do=rename -d cat=$CID --data-urlencode "name=abcdefghijklmnopqrstuvwxy" >/dev/null
ok "rename: over 20 chars cut to 20" "$(dbv "SELECT name FROM cats WHERE id=$CID")" abcdefghijklmnopqrst

# tick and away pay-out
R=$(cfapi -d do=tick)
ok "tick: ok true" "$(echo "$R" | jp ok)" true
ok "tick: view.kibble is numeric" "$([[ $(echo "$R" | jp view.kibble) =~ ^[0-9]+$ ]] && echo y || echo n)" y
dbx "UPDATE catfish_state SET last_tick=$(( $(date +%s) - 3600 )) WHERE user_id=$UID_"
G=$(cfapi -d do=tick | jp view.gained)
ok "away 1 h: gained more than 0" "$([ "$G" -gt 0 ] && echo y || echo n)" y
ok "away 1 h: gained at most 60 (half of base 60/h)" "$([ "$G" -le 60 ] && echo y || echo n)" y
dbx "UPDATE catfish_state SET last_tick=$(( $(date +%s) - 100000 )) WHERE user_id=$UID_"
R=$(cfapi -d do=tick); G=$(echo "$R" | jp view.gained); MOOD=$(echo "$R" | jp view.cat.mood)
# bound = cap hours * half rate * kph; a lazy cat has a 10 h cap (catfish_offline_cap), a greedy one earns 10% more
KPH=60; CAPH=8; [ "$MOOD" = greedy ] && KPH=66; [ "$MOOD" = lazy ] && CAPH=10
ok "away 100000 s: gain capped (8 h at half rate, 10 h for lazy)" "$([ "$G" -gt 0 ] && [ "$G" -le $(( CAPH * KPH / 2 )) ] && echo y || echo n)" y
G2=$(cfapi -d do=tick | jp view.gained)
ok "immediate second tick gains about 0" "$([ "$G2" -le 1 ] && echo y || echo n)" y

# upgrades
dbx "UPDATE catfish_state SET kibble=1000 WHERE user_id=$UID_"
R=$(cfapi -d do=buy -d key=fish)
ok "buy fish: ok true" "$(echo "$R" | jp ok)" true
ok "buy fish: 10 Kibble spent (1000 -> 990)" "$(dbv "SELECT kibble FROM catfish_state WHERE user_id=$UID_")" 990
ok "buy fish: upgrades say fish=1" "$(dbv "SELECT upgrades FROM catfish_state WHERE user_id=$UID_" | grep -o '"fish":[0-9]*')" '"fish":1'
R=$(cfapi -d do=buy -d key=fish)
ok "second fish costs 12 (ceil 10 x 1.15)" "$(dbv "SELECT kibble FROM catfish_state WHERE user_id=$UID_")" 978
ok "second fish: fish=2" "$(dbv "SELECT upgrades FROM catfish_state WHERE user_id=$UID_" | grep -o '"fish":[0-9]*')" '"fish":2'
dbx "UPDATE catfish_state SET kibble=0 WHERE user_id=$UID_"
R=$(cfapi -d do=buy -d key=fish)
ok "buy with 0 Kibble: ok false" "$(echo "$R" | jp ok)" false
ok "buy with 0 Kibble: level unchanged" "$(dbv "SELECT upgrades FROM catfish_state WHERE user_id=$UID_" | grep -o '"fish":[0-9]*')" '"fish":2'
dbx "UPDATE catfish_state SET kibble=1000 WHERE user_id=$UID_"
R=$(cfapi -d do=buy -d key=nope)
ok "unknown upgrade key: ok false" "$(echo "$R" | jp ok)" false

# API guards
ok "api without csrf: 400" "$(curl -s -b $W/p -o /dev/null -w '%{http_code}' -X POST $BASE/catfish_api.php -d do=tick)" 400
ok "api GET: 405" "$(curl -s -b $W/p -o /dev/null -w '%{http_code}' $BASE/catfish_api.php)" 405

# generator: same seed, same cat; rarity bands over 20000 random seeds
GEN=$(php -r 'function is_admin(){return false;} function setting($n){return "";} require $argv[1]; mt_srand(7);
$same = catfish_cat(12345) == catfish_cat(12345);
$n = 20000; $r = [];
for ($i = 0; $i < $n; $i++) { $c = catfish_cat(mt_rand()); $r[$c["rarity"]] = ($r[$c["rarity"]] ?? 0) + 1; }
$leg = 100 * ($r["legendary"] ?? 0) / $n; $com = 100 * ($r["common"] ?? 0) / $n;
echo $same ? "y" : "n", "\n", ($leg >= 0.5 && $leg <= 3) ? "y" : "n", "\n", ($com >= 40 && $com <= 60) ? "y" : "n", "\n";' "$GAME/includes/catfish.php")
ok "generator: catfish_cat(12345) is always the same cat" "$(echo "$GEN" | sed -n 1p)" y
ok "generator: legendary between 0.5% and 3% of 20000 seeds" "$(echo "$GEN" | sed -n 2p)" y
ok "generator: common between 40% and 60% of 20000 seeds" "$(echo "$GEN" | sed -n 3p)" y

# cleanup
dbx "DELETE FROM settings WHERE name IN ('catfish_open')"
