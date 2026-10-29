#!/usr/bin/env bash
# Cat Fish (catfish.php, catfish_api.php, includes/catfish.php, profile box): gate, shelter, adoption, name cleaning, tick and away pay-out, upgrades (16 in 4 branches), naps and Yarn, Cat Book and badges, API guards, generator and shelter determinism, pure helpers.
GAME=$1; PORT=$2; ROUTER=$3; BASE=http://127.0.0.1:$PORT
php -d session.save_path=/tmp -S 127.0.0.1:$PORT -t $GAME $ROUTER >/tmp/catfish-php.log 2>&1 & PID=$!; sleep 1
W=$(mktemp -d); trap "kill $PID 2>/dev/null; rm -rf $W" EXIT
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
# the API allows 10 calls an hour per gnome (rate_limited in catfish_api.php); the suite clears that counter between groups of calls
cfreset() { dbx "DELETE FROM login_attempts WHERE username LIKE 'cfapi:%'"; }
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

# Cat Book: the adopted cat's pattern and colour go in the book, and the page shows it (derived, nothing else stored)
read PC CC <<< "$(php -r 'function is_admin(){return false;} function setting($n){return "";} require $argv[1]; $c = catfish_cat((int)$argv[2]); echo $c["pattern"], " ", $c["colour"];' "$GAME/includes/catfish.php" "$(dbv "SELECT seed FROM cats WHERE user_id=$UID_")")"
ok "cat book: adopted cat's pattern and colour recorded" "$(dbv "SELECT COUNT(*) FROM cat_book WHERE user_id=$UID_ AND pattern='$PC' AND colour='$CC'")" 1
curl -s -b $W/p $BASE/catfish.php > $W/c2.html
ok "cat book: page shows the Cat Book" "$([ "$(grep -c 'Cat Book' $W/c2.html)" -ge 1 ] && echo y || echo n)" y

# name cleaning
CID=$(dbv "SELECT id FROM cats WHERE user_id=$UID_")
cfpost -d do=rename -d cat=$CID --data-urlencode "name=<b>x</b>" >/dev/null
ok "rename: no angle brackets stored" "$(dbv "SELECT name FROM cats WHERE id=$CID" | grep -c '[<>]')" 0
ok "rename: tags reduced to letters (bxb)" "$(dbv "SELECT name FROM cats WHERE id=$CID")" bxb
cfpost -d do=rename -d cat=$CID --data-urlencode "name=abcdefghijklmnopqrstuvwxy" >/dev/null
ok "rename: over 20 chars cut to 20" "$(dbv "SELECT name FROM cats WHERE id=$CID")" abcdefghijklmnopqrst

# tick and away pay-out. Base is 600 Kibble/h, so every bound comes from the view's kph:
# a greedy cat is x1.10, a hyper cat x1.15 only while present (view and present ticks), and away pays half.
cfreset
R=$(cfapi -d do=tick)
ok "tick: ok true" "$(echo "$R" | jp ok)" true
ok "tick: view.kibble is numeric" "$([[ $(echo "$R" | jp view.kibble) =~ ^[0-9]+$ ]] && echo y || echo n)" y
KPH=$(echo "$R" | jp view.kph); MOOD=$(echo "$R" | jp view.cat.mood)
case $MOOD in greedy) WANT=660;; hyper) WANT=690;; *) WANT=600;; esac
ok "fresh cat, no upgrades: view.kph is 600 x mood factor" "$KPH" "$WANT"
# away: a hyper cat is not present, so no x1.15 on the away rate
AK=$KPH; [ "$MOOD" = hyper ] && AK=600
SNEAKY=0; [ "$MOOD" = sneaky ] && SNEAKY=$(( AK / 20 ))   # a sneaky cat's one rare-fish roll is floor(eff/10) with eff = AK/2
dbx "UPDATE catfish_state SET last_tick=$(( $(date +%s) - 3600 )) WHERE user_id=$UID_"
G=$(cfapi -d do=tick | jp view.gained)
ok "away 1 h: gained more than 0" "$([ "$G" -gt 0 ] && echo y || echo n)" y
ok "away 1 h: gained at least half of the base rate" "$([ "$G" -ge $(( AK / 2 )) ] && echo y || echo n)" y
ok "away 1 h: gained at most half of the base rate (plus a sneaky rare fish)" "$([ "$G" -le $(( AK / 2 + SNEAKY )) ] && echo y || echo n)" y
dbx "UPDATE catfish_state SET last_tick=$(( $(date +%s) - 100000 )) WHERE user_id=$UID_"
R=$(cfapi -d do=tick); G=$(echo "$R" | jp view.gained); MOOD=$(echo "$R" | jp view.cat.mood)
# bound = cap hours x half the rate; a lazy cat has a 10 h cap (catfish_offline_cap), the rest 8 h
CAPH=8; [ "$MOOD" = lazy ] && CAPH=10
ok "away 100000 s: gain capped (8 h at half rate, 10 h for lazy)" "$([ "$G" -gt 0 ] && [ "$G" -le $(( CAPH * AK / 2 + SNEAKY )) ] && echo y || echo n)" y
G2=$(cfapi -d do=tick | jp view.gained)
ok "immediate second tick gains about 0" "$([ "$G2" -le 1 ] && echo y || echo n)" y
# a tick worth less than one whole Kibble pays nothing and leaves last_tick alone, so the part-earned fraction is kept
NOW=$(date +%s); G0=$(awk "BEGIN{print int(3600/$KPH)-2}")
dbx "UPDATE catfish_state SET kibble=0, last_tick=$(( NOW - G0 )) WHERE user_id=$UID_"
G=$(cfapi -d do=tick | jp view.gained); LT=$(dbv "SELECT last_tick FROM catfish_state WHERE user_id=$UID_")
ok "sub-Kibble tick ($G0 s): nothing whole earned" "$G" 0
ok "sub-Kibble tick: last_tick not moved" "$LT" "$(( NOW - G0 ))"
# a tick of about 2.5 Kibble's worth pays 2 and moves last_tick only by the seconds those 2 cost; the rest stays owed
NOW=$(date +%s); G1=$(awk "BEGIN{print int(9000/$KPH + 0.5)}")
E=$(awk "BEGIN{print int($KPH*$G1/3600)}"); M=$(awk "BEGIN{x=$E*3600/$KPH; print (x==int(x))?x:int(x)+1}")
dbx "UPDATE catfish_state SET kibble=0, last_tick=$(( NOW - G1 )) WHERE user_id=$UID_"
G=$(cfapi -d do=tick | jp view.gained); LT=$(dbv "SELECT last_tick FROM catfish_state WHERE user_id=$UID_")
ok "$G1 s tick: pays $E whole Kibble" "$G" "$E"
ok "$G1 s tick: last_tick moved only by the $M s paid" "$LT" "$(( NOW - G1 + M ))"

# upgrades: 16 in four branches
cfreset
curl -s -b $W/p $BASE/catfish.php > $W/c1.html
ok "page: 16 upgrade forms" "$(grep -c 'name="do" value="buy"' $W/c1.html)" 16
for b in Fish Rod Room Cat; do ok "page: $b branch heading" "$(grep -c "> $b</h3>" $W/c1.html)" 1; done
UPS=$(cfapi -d do=tick | php -r '$v=json_decode(stream_get_contents(STDIN),true); $b=["fish","rod","room","cat"]; $n=0; $bad=0; foreach (($v["view"]["ups"] ?? []) as $u) { $n++; if (!in_array($u["branch"] ?? "", $b, true)) $bad++; } echo $n, " ", $bad;')
ok "api view.ups: 16 entries" "${UPS% *}" 16
ok "api view.ups: every entry has one of the four branches" "${UPS#* }" 0
dbx "UPDATE catfish_state SET kibble=1000, last_tick=$(date +%s) WHERE user_id=$UID_"
R=$(cfapi -d do=buy -d key=fish)
ok "buy fish: ok true" "$(echo "$R" | jp ok)" true
ok "buy fish: 10 Kibble spent (1000 -> 990)" "$(dbv "SELECT kibble FROM catfish_state WHERE user_id=$UID_")" 990
ok "buy fish: upgrades say fish=1" "$(dbv "SELECT upgrades FROM catfish_state WHERE user_id=$UID_" | grep -o '"fish":[0-9]*')" '"fish":1'
R=$(cfapi -d do=buy -d key=fish)
ok "second fish costs 12 (ceil 10 x 1.18)" "$(dbv "SELECT kibble FROM catfish_state WHERE user_id=$UID_")" 978
ok "second fish: fish=2" "$(dbv "SELECT upgrades FROM catfish_state WHERE user_id=$UID_" | grep -o '"fish":[0-9]*')" '"fish":2'
dbx "UPDATE catfish_state SET kibble=0 WHERE user_id=$UID_"
R=$(cfapi -d do=buy -d key=fish)
ok "buy with 0 Kibble: ok false" "$(echo "$R" | jp ok)" false
ok "buy with 0 Kibble: level unchanged" "$(dbv "SELECT upgrades FROM catfish_state WHERE user_id=$UID_" | grep -o '"fish":[0-9]*')" '"fish":2'
dbx "UPDATE catfish_state SET kibble=1000, last_tick=$(date +%s) WHERE user_id=$UID_"
R=$(cfapi -d do=buy -d key=nope)
ok "unknown upgrade key: ok false" "$(echo "$R" | jp ok)" false

# nap: a run of 100 Kibble is too short; a run of 32000 gives 4 Yarn (cube root of 64, dreamy 4.4 still 4) and resets Kibble and upgrades
cfreset
dbx "UPDATE catfish_state SET run_kibble=100, kibble=0, last_tick=$(date +%s) WHERE user_id=$UID_"
cfpost -d do=nap >/dev/null
ok "nap with 100 run Kibble: refused (naps stays 0)" "$(dbv "SELECT naps FROM catfish_state WHERE user_id=$UID_")" 0
ok "nap with 100 run Kibble: refused (yarn stays 0)" "$(dbv "SELECT yarn FROM catfish_state WHERE user_id=$UID_")" 0
MOOD=$(cfapi -d do=tick | jp view.cat.mood)
Y=4
CATS0=$(dbv "SELECT COUNT(*) FROM cats WHERE user_id=$UID_")
dbx "UPDATE catfish_state SET run_kibble=32000, kibble=777, upgrades='{\"fish\":3}', last_tick=$(date +%s) WHERE user_id=$UID_"
cfpost -d do=nap >/dev/null
ok "nap: naps=1" "$(dbv "SELECT naps FROM catfish_state WHERE user_id=$UID_")" 1
ok "nap: yarn=$Y (cube root of run / 500)" "$(dbv "SELECT yarn FROM catfish_state WHERE user_id=$UID_")" "$Y"
ok "nap: kibble back to 0" "$(dbv "SELECT kibble FROM catfish_state WHERE user_id=$UID_")" 0
ok "nap: run_kibble back to 0" "$(dbv "SELECT run_kibble FROM catfish_state WHERE user_id=$UID_")" 0
ok "nap: upgrades back to {}" "$(dbv "SELECT upgrades FROM catfish_state WHERE user_id=$UID_")" '{}'
ok "nap: cats table row count unchanged" "$(dbv "SELECT COUNT(*) FROM cats WHERE user_id=$UID_")" "$CATS0"
# after the nap the cat earns (1 + 0.10 x Yarn) more, times its mood factor (greedy x1.10, hyper x1.15 while present)
NK=$(cfapi -d do=tick | jp view.kph)
MF=1; case $MOOD in greedy) MF=1.1;; hyper) MF=1.15;; esac
WANT=$(awk "BEGIN{printf \"%.1f\", 600*(1+0.1*($Y^0.6))*$MF}")
ok "after the nap: view.kph = 600 x (1 + 0.10 x Yarn^0.6) x mood (within rounding)" "$(awk "BEGIN{d=$NK-$WANT; print (d<0?-d:d)<=0.11 ? \"y\" : \"n\"}")" y
# a tick adds the same Kibble to the run and to the lifetime total
dbx "UPDATE catfish_state SET last_tick=$(( $(date +%s) - 3600 )) WHERE user_id=$UID_"
K0=$(dbv "SELECT kibble FROM catfish_state WHERE user_id=$UID_"); RU0=$(dbv "SELECT run_kibble FROM catfish_state WHERE user_id=$UID_"); T0=$(dbv "SELECT total_kibble FROM catfish_state WHERE user_id=$UID_")
G=$(cfapi -d do=tick | jp view.gained)
K1=$(dbv "SELECT kibble FROM catfish_state WHERE user_id=$UID_"); RU1=$(dbv "SELECT run_kibble FROM catfish_state WHERE user_id=$UID_"); T1=$(dbv "SELECT total_kibble FROM catfish_state WHERE user_id=$UID_")
ok "tick after a nap: gained more than 0" "$([ "$G" -gt 0 ] && echo y || echo n)" y
ok "tick: kibble rises by gained" "$(( K1 - K0 ))" "$G"
ok "tick: run_kibble rises by the same amount as kibble" "$(( RU1 - RU0 ))" "$(( K1 - K0 ))"
ok "tick: total_kibble rises by the same amount as kibble" "$(( T1 - T0 ))" "$(( K1 - K0 ))"

# API guards
ok "api without csrf: 400" "$(curl -s -b $W/p -o /dev/null -w '%{http_code}' -X POST $BASE/catfish_api.php -d do=tick)" 400
ok "api GET: 405" "$(curl -s -b $W/p -o /dev/null -w '%{http_code}' $BASE/catfish_api.php)" 405

# profile box (the viewer is the player): shows while Cat Fish is open, with First adoption and First nap; gone when closed
PR=$(curl -s -b $W/p "$BASE/profile.php?id=$UID_&tab=awards")
ok "profile: Cat Fish box while open" "$(echo "$PR" | grep -c '🐱 Cat Fish</h3>')" 1
ok "profile: 'First adoption' badge" "$(echo "$PR" | grep -c 'First adoption')" 1
ok "profile: 'First nap' badge after the nap" "$(echo "$PR" | grep -c 'First nap')" 1

# pure helpers, loaded without the game (stubs for is_admin and setting)
PURE=$(php -r 'function is_admin(){return false;} function setting($n){return "";} require $argv[1];
$r = [];
$r["rare_hit"] = catfish_rare_fish(600.0, 3600, 0.1);
$r["rare_miss"] = catfish_rare_fish(600.0, 3600, 0.6);
$r["yarn_499"] = catfish_nap_yarn(499, null);
$r["yarn_500"] = catfish_nap_yarn(500, null);
$r["yarn_2000"] = catfish_nap_yarn(2000, null); $r["yarn_big"] = catfish_nap_yarn(389500, null); $r["yarn_big_dreamy"] = catfish_nap_yarn(389500, ["mood" => "dreamy"]);
$r["yarn_dreamy"] = catfish_nap_yarn(2000, ["mood" => "dreamy"]);
$g = catfish_rng(123456); $r["rng"] = sprintf("%.6f %.6f %.6f", $g(), $g(), $g());
$r["kph"] = var_export(catfish_kph([], null, false, 0), true);
foreach ([9, 10, 25, 50] as $n) $r["mult_$n"] = catfish_milestone_mult($n);
foreach ($r as $k => $v) echo $k, "=", $v, "\n";' "$GAME/includes/catfish.php")
pv() { echo "$PURE" | grep "^$1=" | cut -d= -f2-; }
ok "rare fish: 60 on a hit (chance 0.5 per hour)" "$(pv rare_hit)" 60
ok "rare fish: 0 on a miss" "$(pv rare_miss)" 0
ok "nap yarn: 499 Kibble -> 0" "$(pv yarn_499)" 0
ok "nap yarn: 500 Kibble -> 1" "$(pv yarn_500)" 1
ok "nap yarn: 2000 Kibble -> 1 (cube root)" "$(pv yarn_2000)" 1
ok "nap yarn: 2000 Kibble, dreamy -> 1 (1.74 rounds down)" "$(pv yarn_dreamy)" 1
ok "nap yarn: 389500 Kibble -> 9" "$(pv yarn_big)" 9
ok "nap yarn: 389500 Kibble, dreamy -> 10 (10% before rounding)" "$(pv yarn_big_dreamy)" 10
ok "rng: seed 123456, first three values" "$(pv rng)" "0.382333 0.797263 0.996530"
ok "kph: nothing bought, no cat -> 600.0" "$(pv kph)" "600.0"
ok "milestone: 9 owned -> x1" "$(pv mult_9)" 1
ok "milestone: 10 owned -> x2" "$(pv mult_10)" 2
ok "milestone: 25 owned -> x4" "$(pv mult_25)" 4
ok "milestone: 50 owned -> x8" "$(pv mult_50)" 8

# closed again: the profile box goes, and the cat is still kept
setg catfish_open 0
PR=$(curl -s -b $W/p "$BASE/profile.php?id=$UID_&tab=awards")
ok "profile: no Cat Fish box while closed" "$(echo "$PR" | grep -c '🐱 Cat Fish</h3>')" 0

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

setg catfish_open 1
# no replay: hammering tick at a high rate never pays more than the time that passed (ceil on the clock)
cfreset
T0=$(date +%s); dbx "UPDATE catfish_state SET kibble=0, yarn=1000, last_tick=$T0 WHERE user_id=$UID_"
KP=$(cfapi -d do=tick | jp view.kph)
for i in $(seq 1 30); do cfapi -d do=tick >/dev/null; done
T1=$(date +%s); GOT=$(dbv "SELECT kibble FROM catfish_state WHERE user_id=$UID_")
ok "30 rapid ticks at $KP/h pay no more than the elapsed time allows" "$(awk "BEGIN{print ($GOT <= $KP*($T1-$T0+1)/3600 + 2) ? \"y\" : \"n\"}")" y
dbx "UPDATE catfish_state SET yarn=0 WHERE user_id=$UID_"
# the Cat Book also records cats only seen at the shelter
ok "Cat Book: shelter cats seen are recorded" "$([ "$(dbv "SELECT COUNT(*) FROM cat_book WHERE user_id=$UID_")" -ge 3 ] && echo y || echo n)" y

# ---------- week 3: shelter rerolls, Rare Shelter, Yarn spending, bigger home, adoption guards, Petal milestones ----------
setg catfish_open 1
cfreset
w3reset() { dbx "DELETE FROM cats WHERE user_id=$UID_; DELETE FROM cat_book WHERE user_id=$UID_; UPDATE catfish_state SET active_cat_id=NULL, kibble=0, upgrades='{}', naps=0, run_kibble=0, yarn=0, meta='{}', last_tick=$(date +%s) WHERE user_id=$UID_"; }
mget() { local v; v=$(dbv "SELECT meta FROM catfish_state WHERE user_id=$UID_" | jp "$1"); echo "${v:-0}"; }   # one value out of catfish_state.meta (0 when absent)
ncats() { dbv "SELECT COUNT(*) FROM cats WHERE user_id=$UID_"; }
pagew3() { curl -s -b $W/p $BASE/catfish.php > $W/w3.html; CS=$(csrf $W/w3.html); }
# the seed in the hidden input of shelter slot $1, read from page file $2
seed_of() { grep -o "name=\"slot\" value=\"$1\"><input type=\"hidden\" name=\"seed\" value=\"[0-9]*\"" "$2" | grep -o '[0-9]*"$' | tr -d '"'; }

# pure: rolls and Rare Shelter (stubs for is_admin and setting, no database)
PUREW3=$(php -r 'function is_admin(){return false;} function setting($n){return "";} require $argv[1];
$base = catfish_shelter(7, "2026-01-01"); $same = catfish_shelter(7, "2026-01-01", [], 0); $roll = catfish_shelter(7, "2026-01-01", [1,0,0], 0);
$r0 = catfish_shelter(7, "2026-01-01", [], 0); $r2 = catfish_shelter(7, "2026-01-01", [], 2);
echo json_encode($base) === json_encode($same) ? "y" : "n", "\n";
echo ($base[0]["seed"] !== $roll[0]["seed"] && $base[1]["seed"] === $roll[1]["seed"] && $base[2]["seed"] === $roll[2]["seed"]) ? "y" : "n", "\n";
$up = true; for ($i = 0; $i < 3; $i++) if ($r2[$i]["score"] < $r0[$i]["score"]) $up = false;
echo $up ? "y" : "n", "\n";' "$GAME/includes/catfish.php")
pw3() { echo "$PUREW3" | sed -n "$1p"; }
ok "pure: no rolls and no Rare Shelter = the default shelter" "$(pw3 1)" y
ok "pure: a roll on slot 0 changes slot 0 only" "$(pw3 2)" y
ok "pure: Rare Shelter 2 never scores a slot below its plain cat" "$(pw3 3)" y

# 2. shelter rerolls: 1 Yarn each, 3 per slot per day
w3reset; pagew3
dbx "UPDATE catfish_state SET yarn=0 WHERE user_id=$UID_"
cfpost -d do=reroll -d slot=0 >/dev/null
ok "reroll with 0 Yarn: refused (ys stays 0)" "$(mget ys)" 0
dbx "UPDATE catfish_state SET yarn=5 WHERE user_id=$UID_"
pagew3; SA=$(seed_of 0 $W/w3.html)
ok "page: slot 0 has a seed" "$([ -n "$SA" ] && echo y || echo n)" y
cfpost -d do=reroll -d slot=0 >/dev/null
ok "reroll 1: ys=1" "$(mget ys)" 1
ok "reroll 1: roll.n[0]=1" "$(mget roll.n.0)" 1
pagew3; SB=$(seed_of 0 $W/w3.html)
ok "reroll 1: slot 0 shows a new seed" "$([ -n "$SB" ] && [ "$SA" != "$SB" ] && echo y || echo n)" y
cfpost -d do=reroll -d slot=0 >/dev/null; cfpost -d do=reroll -d slot=0 >/dev/null
ok "reroll 3: ys=3" "$(mget ys)" 3
ok "reroll 3: roll.n[0]=3" "$(mget roll.n.0)" 3
cfpost -d do=reroll -d slot=0 >/dev/null
ok "fourth reroll refused: ys stays 3" "$(mget ys)" 3
ok "fourth reroll refused: roll.n[0] stays 3" "$(mget roll.n.0)" 3

# 3. bigger home: 5 Yarn, then 20; a third is refused; the home holds 4 cats at most
dbx "UPDATE catfish_state SET yarn=4, meta='{}' WHERE user_id=$UID_"
cfpost -d do=bigger >/dev/null
ok "bigger home with 4 Yarn: refused (extra stays 0)" "$(mget extra)" 0
ok "bigger home with 4 Yarn: ys stays 0" "$(mget ys)" 0
dbx "UPDATE catfish_state SET yarn=5 WHERE user_id=$UID_"
cfpost -d do=bigger >/dev/null
ok "bigger home with 5 Yarn: extra=1" "$(mget extra)" 1
ok "bigger home with 5 Yarn: ys=5" "$(mget ys)" 5
dbx "UPDATE catfish_state SET kibble=1000000, last_tick=$(date +%s) WHERE user_id=$UID_"
pagew3; SA=$(seed_of 0 $W/w3.html); SB=$(seed_of 1 $W/w3.html); SC=$(seed_of 2 $W/w3.html)
ok "page: slots 0-2 have seeds" "$([ -n "$SA$SB$SC" ] && [ -n "$SC" ] && echo y || echo n)" y
cfpost -d do=adopt -d slot=0 -d seed=$SA --data-urlencode name=Alpha >/dev/null
cfpost -d do=adopt -d slot=1 -d seed=$SB --data-urlencode name=Beta >/dev/null
cfpost -d do=adopt -d slot=2 -d seed=$SC --data-urlencode name=Gamma >/dev/null
ok "one bigger home: a 3rd cat is allowed (3 cats)" "$(ncats)" 3
dbx "UPDATE catfish_state SET yarn=30, meta='{\"extra\":1,\"ys\":0}' WHERE user_id=$UID_"
cfpost -d do=bigger >/dev/null
ok "second bigger home: extra=2" "$(mget extra)" 2
ok "second bigger home costs 20: ys=20" "$(mget ys)" 20
cfpost -d do=bigger >/dev/null
ok "third bigger home refused: extra stays 2" "$(mget extra)" 2
ok "third bigger home refused: ys stays 20" "$(mget ys)" 20
dbx "UPDATE catfish_state SET kibble=1000000, last_tick=$(date +%s) WHERE user_id=$UID_"
cfpost -d do=reroll -d slot=0 >/dev/null
pagew3; S4=$(seed_of 0 $W/w3.html)
cfpost -d do=adopt -d slot=0 -d seed=$S4 --data-urlencode name=Delta >/dev/null
ok "4 places: a 4th cat adopts" "$(ncats)" 4
cfpost -d do=adopt -d slot=1 --data-urlencode name=Epsilon >/dev/null
ok "5th cat refused: home full (still 4)" "$(ncats)" 4

# 4. Rare Shelter: 3 Yarn, then 10; a third is refused; ys follows
dbx "UPDATE catfish_state SET yarn=100, meta='{\"extra\":2,\"ys\":0}' WHERE user_id=$UID_"
cfpost -d do=rare >/dev/null
ok "Rare Shelter 1 costs 3: ys=3" "$(mget ys)" 3
ok "Rare Shelter 1: rare=1" "$(mget rare)" 1
cfpost -d do=rare >/dev/null
ok "Rare Shelter 2 costs 10: ys=13" "$(mget ys)" 13
ok "Rare Shelter 2: rare=2" "$(mget rare)" 2
cfpost -d do=rare >/dev/null
ok "Rare Shelter third refused: ys stays 13" "$(mget ys)" 13
ok "Rare Shelter third refused: rare stays 2" "$(mget rare)" 2
pagew3
ok "Yarn to spend shows 100 - 13 = 87" "$(grep -c 'Home and shelter · 87 Yarn to spend' $W/w3.html)" 1

# 5. adopt with a stale seed is refused; the seed from the page works (a cat freed for it first)
dbx "DELETE FROM cats WHERE user_id=$UID_ AND name='Delta'"
dbx "UPDATE catfish_state SET kibble=1000000, last_tick=$(date +%s) WHERE user_id=$UID_"
pagew3; S5=$(seed_of 0 $W/w3.html)
ok "page: slot 0 has a seed to adopt" "$([ -n "$S5" ] && echo y || echo n)" y
cfpost -d do=adopt -d slot=0 -d seed=1 --data-urlencode name=Wrong >/dev/null
ok "stale seed (1): refused, cats unchanged" "$(ncats)" 3
cfpost -d do=adopt -d slot=0 -d seed=$S5 --data-urlencode name=Right >/dev/null
ok "seed from the page: adopted (4 cats)" "$(ncats)" 4

# 6. spending Yarn never lowers Kibble per hour
cfreset
dbx "UPDATE catfish_state SET yarn=100, meta='{\"extra\":0,\"ys\":0}', last_tick=$(date +%s) WHERE user_id=$UID_"
KA=$(cfapi -d do=tick | jp view.kph)
cfpost -d do=bigger >/dev/null
KB=$(cfapi -d do=tick | jp view.kph)
ok "bigger home bought with 5 Yarn: ys=5" "$(mget ys)" 5
ok "view.kph unchanged after spending Yarn" "$KB" "$KA"
ok "view.kph with 100 Yarn is above 600" "$(awk "BEGIN{print ($KA > 600) ? \"y\" : \"n\"}")" y

# 7. Petal milestones: paid on page load, once each, inside the weekly cap (catfish_petal_cap)
setg catfish_petal_cap 100
PCT=$(dbv "SELECT value FROM settings WHERE name='games_petals_percent'"); PCT=${PCT:-60}
P20=$(php -r 'echo max(1, (int)round(20 * (int)$argv[1] / 100));' "$PCT")
P40=$(php -r 'echo max(1, (int)round(40 * (int)$argv[1] / 100));' "$PCT")
cfreset
w3reset; pagew3; S1=$(seed_of 0 $W/w3.html)
dbx "UPDATE catfish_state SET kibble=1000000, last_tick=$(date +%s) WHERE user_id=$UID_"
cfpost -d do=adopt -d slot=0 -d seed=$S1 --data-urlencode name=Pebble >/dev/null
ok "petals: one cat adopted" "$(ncats)" 1
dbx "UPDATE users SET coins=0 WHERE id=$UID_; UPDATE catfish_state SET meta='{}' WHERE user_id=$UID_"
curl -s -b $W/p $BASE/catfish.php > $W/pm.html
ok "first page load pays adopt1 ($P20 Petals at 60%)" "$(dbv "SELECT coins FROM users WHERE id=$UID_")" "$P20"
ok "adopt1 recorded in meta.ms" "$(dbv "SELECT meta FROM catfish_state WHERE user_id=$UID_" | grep -c '"adopt1"')" 1
curl -s -b $W/p $BASE/catfish.php > $W/pm.html
ok "second page load pays nothing more" "$(dbv "SELECT coins FROM users WHERE id=$UID_")" "$P20"
dbx "UPDATE catfish_state SET naps=1 WHERE user_id=$UID_"
C0=$(dbv "SELECT coins FROM users WHERE id=$UID_")
curl -s -b $W/p $BASE/catfish.php > $W/pm.html
ok "nap1 pays $P40 Petals on the next page load" "$(( $(dbv "SELECT coins FROM users WHERE id=$UID_") - C0 ))" "$P40"
ok "nap1 recorded in meta.ms" "$(dbv "SELECT meta FROM catfish_state WHERE user_id=$UID_" | grep -c '"nap1"')" 1
# weekly cap 30 with 5 naps: adopt1 (12) fits; nap1 (24) would take it to 36 and waits; nap5 waits too
setg catfish_petal_cap 30
dbx "UPDATE users SET coins=0 WHERE id=$UID_; UPDATE catfish_state SET meta='{}', naps=5 WHERE user_id=$UID_"
curl -s -b $W/p $BASE/catfish.php > $W/pm.html
CAPC=$(dbv "SELECT coins FROM users WHERE id=$UID_")
ok "weekly cap 30: at most 30 Petals paid in one load" "$([ "$CAPC" -le 30 ] && echo y || echo n)" y
ok "weekly cap 30: only adopt1 fits ($P20)" "$CAPC" "$P20"
ok "weekly cap 30: pw.paid counts the one paid" "$(mget pw.paid)" "$P20"
ok "weekly cap 30: nap1 does not fit, stays unpaid" "$(dbv "SELECT meta FROM catfish_state WHERE user_id=$UID_" | grep -c '"nap1"')" 0
ok "weekly cap 30: nap5 does not fit, stays unpaid" "$(dbv "SELECT meta FROM catfish_state WHERE user_id=$UID_" | grep -c '"nap5"')" 0
curl -s -b $W/p $BASE/catfish.php > $W/pm.html
ok "weekly cap 30: a second load pays nothing more" "$(dbv "SELECT coins FROM users WHERE id=$UID_")" "$CAPC"
# cap 0: nothing paid
setg catfish_petal_cap 0
dbx "UPDATE users SET coins=0 WHERE id=$UID_; UPDATE catfish_state SET meta='{}' WHERE user_id=$UID_"
curl -s -b $W/p $BASE/catfish.php > $W/pm.html
ok "cap 0: nothing paid" "$(dbv "SELECT coins FROM users WHERE id=$UID_")" 0
ok "cap 0: no milestone recorded" "$(dbv "SELECT meta FROM catfish_state WHERE user_id=$UID_" | grep -c '"adopt1"')" 0
setg catfish_petal_cap 100

# 8. gate: the reroll POST through the page redirects while Cat Fish is closed
pagew3
setg catfish_open 0
ok "gate off: do=reroll via the page redirects (302)" "$(cfpost -d do=reroll -d slot=0)" 302
setg catfish_open 1

# a milestone worth more than the whole weekly cap still pays (capped), then nothing more that week
setg catfish_open 1; setg catfish_petal_cap 5
dbx "UPDATE catfish_state SET meta='{}' WHERE user_id=$UID_"; dbx "UPDATE users SET coins=0 WHERE id=$UID_"
curl -s -b $W/p $BASE/catfish.php -o /dev/null
ok "cap 5: first milestone pays exactly the cap" "$(dbv "SELECT coins FROM users WHERE id=$UID_")" 5
curl -s -b $W/p $BASE/catfish.php -o /dev/null
ok "cap 5: a second page load pays nothing more" "$(dbv "SELECT coins FROM users WHERE id=$UID_")" 5
setg catfish_petal_cap 100

# cleanup
dbx "DELETE FROM settings WHERE name IN ('catfish_open')"
