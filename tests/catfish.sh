#!/usr/bin/env bash
# Cat Fish (catfish.php, catfish_api.php, includes/catfish.php, profile box): gate, shelter, adoption, name cleaning, tick and away pay-out, upgrades (16 in 4 branches), naps and Yarn, Cat Book and badges, API guards, generator and shelter determinism, pure helpers.
GAME=$1; PORT=$2; ROUTER=$3; BASE=http://127.0.0.1:$PORT
php -d session.save_path=/tmp -S 127.0.0.1:$PORT -t $GAME $ROUTER >/tmp/catfish-php.log 2>&1 & PID=$!; sleep 1
# the "no art" checks assume an empty art folder: move installed art aside for the run, restore it on exit
CFART=$GAME/assets/img/catfish; CFHOLD=$GAME/assets/img/.catfish-held
[ -d "$CFART" ] && [ ! -e "$CFHOLD" ] && mv "$CFART" "$CFHOLD"
W=$(mktemp -d); trap "kill $PID 2>/dev/null; rm -rf $W; [ -d \"$CFHOLD\" ] && { rm -rf \"$CFART\"; mv \"$CFHOLD\" \"$CFART\"; }" EXIT
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
shelter() { php -r 'function is_admin(){return false;} function setting($n){return "";} function hollow_date($f,$t=null){return (new DateTimeImmutable("@".($t??time())))->setTimezone(new DateTimeZone("America/Halifax"))->format($f);} require $argv[1]; echo json_encode(array_column(catfish_shelter((int)$argv[2], "2026-10-29"), "seed"));' "$GAME/includes/catfish.php" "$1"; }

login $W/a admin TestPassword123
login $W/p sprout 'TestPass123!'
dbx "DELETE FROM settings WHERE name IN ('catfish_open')"

# gate (default is On since 2.1.00: close it explicitly first)
ok "default: no stored row means open" "$(curl -s -b $W/p -o /dev/null -w '%{http_code}' $BASE/catfish.php)" 200
setg catfish_open 0
ok "gate off: player is sent away" "$(curl -s -b $W/p -o /dev/null -w '%{http_code}' $BASE/catfish.php)" 302
curl -s -b $W/p $BASE/games.php > $W/h.html; ok "hub: no Cat Fish link while off" "$(grep -c 'href="[^"]*catfish.php"' $W/h.html)" 0
setg festivals_on 0   # a running festival doubles Yarn from a Nap; keep the checks date-independent
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
ok "adopt slot 0: the cat is the shelter's slot 0" "$(dbv "SELECT seed FROM cats WHERE user_id=$UID_")" "$(php -r 'function is_admin(){return false;} function setting($n){return "";} function hollow_date($f,$t=null){return (new DateTimeImmutable("@".($t??time())))->setTimezone(new DateTimeZone("America/Halifax"))->format($f);} require $argv[1]; echo catfish_shelter((int)$argv[2])[0]["seed"];' "$GAME/includes/catfish.php" "$UID_")"
cfpost -d do=adopt -d slot=0 --data-urlencode name=Again >/dev/null
ok "adopt the same cat again is refused (still one row)" "$(dbv "SELECT COUNT(*) FROM cats WHERE user_id=$UID_")" 1
dbx "UPDATE catfish_state SET kibble=0 WHERE user_id=$UID_"
cfpost -d do=adopt -d slot=1 --data-urlencode name=Second >/dev/null
ok "adopt slot 1 with 0 Kibble is refused (still one row)" "$(dbv "SELECT COUNT(*) FROM cats WHERE user_id=$UID_")" 1

# Cat Book: the adopted cat's pattern and colour go in the book, and the page shows it (derived, nothing else stored)
read PC CC <<< "$(php -r 'function is_admin(){return false;} function setting($n){return "";} function hollow_date($f,$t=null){return (new DateTimeImmutable("@".($t??time())))->setTimezone(new DateTimeZone("America/Halifax"))->format($f);} require $argv[1]; $c = catfish_cat((int)$argv[2]); echo $c["pattern"], " ", $c["colour"];' "$GAME/includes/catfish.php" "$(dbv "SELECT seed FROM cats WHERE user_id=$UID_")")"
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
PURE=$(php -r 'function is_admin(){return false;} function setting($n){return "";} function hollow_date($f,$t=null){return (new DateTimeImmutable("@".($t??time())))->setTimezone(new DateTimeZone("America/Halifax"))->format($f);} require $argv[1];
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
GEN=$(php -r 'function is_admin(){return false;} function setting($n){return "";} function hollow_date($f,$t=null){return (new DateTimeImmutable("@".($t??time())))->setTimezone(new DateTimeZone("America/Halifax"))->format($f);} require $argv[1]; mt_srand(7);
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
PUREW3=$(php -r 'function is_admin(){return false;} function setting($n){return "";} function hollow_date($f,$t=null){return (new DateTimeImmutable("@".($t??time())))->setTimezone(new DateTimeZone("America/Halifax"))->format($f);} require $argv[1];
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

# ---------- week 4: Cat Show (pure), entering, settling, profile and garden, Puzzle Pals bonus, festival ----------
setg catfish_open 1; setg festivals_on 0; cfreset
# pure: weeks, theme and judging (stubs for is_admin and setting, no database)
PUR4=$(php -r 'function is_admin(){return false;} function setting($n){return "";} function hollow_date($f,$t=null){return (new DateTimeImmutable("@".($t??time())))->setTimezone(new DateTimeZone("America/Halifax"))->format($f);} require $argv[1];
echo "wk44=", catfish_show_week(strtotime("2026-10-26 12:00 UTC")), "\n";
echo "wk44_end=", catfish_show_week(strtotime("2026-11-02 03:59 UTC")), "\n";
echo "wk44_utc_midnight=", catfish_show_week(strtotime("2026-11-02 00:00 UTC")), "\n";
echo "wk45_start=", catfish_show_week(strtotime("2026-11-02 04:00 UTC")), "\n";
echo "wk53=", catfish_show_week(strtotime("2027-01-01 12:00 UTC")), "\n";
$same = 0; $banned = 0;
for ($w = 1; $w <= 53; $w++) { $wk = sprintf("2026-W%02d", $w); $a = catfish_show_theme($wk); if ($a === catfish_show_theme($wk)) $same++; if (in_array($a["value"], ["silver", "lilac", "odd", "spotted"], true)) $banned++; }
echo "theme_same=", $same, "\n";
echo "theme_banned=", $banned, "\n";
$th = catfish_show_theme("2026-W44"); $c = catfish_cat(1);
$j1 = catfish_show_judge(7, "2026-W44", $c, $th); $j2 = catfish_show_judge(7, "2026-W44", $c, $th);
echo "judge_same=", ($j1 === $j2 ? "y" : "n"), "\n";
$m = $c; $m[$th["trait"]] = $th["value"];
$o = null; foreach (array_keys(CATFISH_TRAITS[$th["trait"]]) as $v) if ($v !== $th["value"]) { $o = $v; break; }
$n = $c; $n[$th["trait"]] = $o;
echo "match_diff=", catfish_show_judge(7, "2026-W44", $m, $th)["score"] - catfish_show_judge(7, "2026-W44", $n, $th)["score"], "\n";' "$GAME/includes/catfish.php")
pw4() { echo "$PUR4" | grep "^$1=" | cut -d= -f2-; }
ok "show week: 2026-10-26 is 2026-W44" "$(pw4 wk44)" 2026-W44
ok "show week: Sunday 23:59 Halifax (2026-11-02 03:59 UTC) is still 2026-W44" "$(pw4 wk44_end)" 2026-W44
ok "show week: Monday 00:00 UTC is still W44 in Halifax (the week turns at local midnight)" "$(pw4 wk44_utc_midnight)" 2026-W44
ok "show week: Monday 00:00 Halifax (2026-11-02 04:00 UTC) is 2026-W45" "$(pw4 wk45_start)" 2026-W45
ok "show week: 2027-01-01 is 2026-W53" "$(pw4 wk53)" 2026-W53
ok "show theme: same week, same theme (all 53 weeks of 2026)" "$(pw4 theme_same)" 53
ok "show theme: never silver, lilac, odd or spotted (2026-W01..W53)" "$(pw4 theme_banned)" 0
ok "show judge: same inputs, same result (no re-roll)" "$(pw4 judge_same)" y
ok "show judge: matching cat scores exactly 12 more than the same cat off-theme" "$(pw4 match_diff)" 12

# entering: owned cats (the gnome needs two; slots are opened with a bigger home first)
WEEK=$(php -r 'function is_admin(){return false;} function setting($n){return "";} function hollow_date($f,$t=null){return (new DateTimeImmutable("@".($t??time())))->setTimezone(new DateTimeZone("America/Halifax"))->format($f);} require $argv[1]; echo catfish_show_week();' "$GAME/includes/catfish.php")
# mset CODE: edits $m (the decoded meta) with CODE. eval is safe here: CODE is a literal written in this test, never player input.
mset() { local n; n=$(php -r '$m=json_decode($argv[1],true); if(!is_array($m)) $m=[]; eval($argv[2]); echo json_encode($m);' "$(dbv "SELECT meta FROM catfish_state WHERE user_id=$UID_")" "$1"); dbx "UPDATE catfish_state SET meta='$n' WHERE user_id=$UID_"; }
mshowv() { dbv "SELECT meta FROM catfish_state WHERE user_id=$UID_" | jp "$1"; }
mjson() { dbv "SELECT meta FROM catfish_state WHERE user_id=$UID_"; }
noshow() { php -r '$m=json_decode($argv[1],true); unset($m["show"]); echo json_encode($m);' "$1"; }
rib_wk() { dbv "SELECT COUNT(*) FROM cat_ribbons WHERE user_id=$UID_ AND week='$1'"; }
rib_all() { dbv "SELECT COUNT(*) FROM cat_ribbons WHERE user_id=$UID_"; }
dbx "UPDATE catfish_state SET kibble=1000000, last_tick=$(date +%s) WHERE user_id=$UID_"
mset '$m["extra"]=3;'
i=0; while [ "$(ncats)" -lt 2 ] && [ $i -lt 4 ]; do pagew3; S=$(seed_of $i $W/w3.html); [ -n "$S" ] && cfpost -d do=adopt -d slot=$i -d seed=$S --data-urlencode name=Two$i >/dev/null; i=$((i+1)); done
A=$(dbv "SELECT id FROM cats WHERE user_id=$UID_ ORDER BY id LIMIT 1"); B=$(dbv "SELECT id FROM cats WHERE user_id=$UID_ ORDER BY id DESC LIMIT 1")
ok "show: the gnome owns two different cats" "$([ "$(ncats)" -ge 2 ] && [ -n "$A" ] && [ "$A" != "$B" ] && echo y || echo n)" y
dbx "DELETE FROM cat_ribbons WHERE user_id=$UID_"; mset 'unset($m["show"]);'
# a stranger's cat (the admin's), for the refusal check
ADM=$(dbv "SELECT id FROM users WHERE username='admin'")
dbx "INSERT OR IGNORE INTO cats (user_id, seed, name, adopted_at) VALUES ($ADM, 4242, 'Stranger', '2026-01-01 00:00:00')"
X=$(dbv "SELECT id FROM cats WHERE user_id=$ADM AND seed=4242")
pagew3
cfpost -d do=show -d cat=$A >/dev/null
ok "enter: show.week is this week" "$(mshowv show.week)" "$WEEK"
ok "enter: show.cat is the cat entered" "$(mshowv show.cat)" "$A"
ok "enter: no cat_ribbons row yet" "$(rib_all)" 0
M0=$(mjson)
cfpost -d do=show -d cat=$X >/dev/null
ok "enter another gnome's cat: refused (meta unchanged)" "$([ "$(mjson)" = "$M0" ] && echo y || echo n)" y
cfpost -d do=show -d cat=999999 >/dev/null
ok "enter a cat that does not exist: refused (meta unchanged)" "$([ "$(mjson)" = "$M0" ] && echo y || echo n)" y
cfpost -d do=show -d cat=$B >/dev/null
ok "swap to the second cat: show.cat updated" "$(mshowv show.cat)" "$B"
ok "swap: still this week" "$(mshowv show.week)" "$WEEK"
dbx "DELETE FROM cats WHERE id=$X"

# settling: an entry from a finished week gets its ribbon on the next page load, once
dbx "DELETE FROM cat_ribbons WHERE user_id=$UID_"
mset "\$m['show']=['week'=>'2025-W01','cat'=>$B];"
MB=$(mjson)
curl -s -b $W/p $BASE/catfish.php -o /dev/null
ok "settle: one ribbon row for 2025-W01" "$(rib_wk 2025-W01)" 1
TIER=$(dbv "SELECT tier FROM cat_ribbons WHERE user_id=$UID_ AND week='2025-W01'")
ok "settle: tier is best, blue, red, white or part" "$(echo " best blue red white part " | grep -c " $TIER ")" 1
NAME=$(dbv "SELECT name FROM cats WHERE id=$B")
ok "settle: the ribbon names the cat" "$(dbv "SELECT cat_name FROM cat_ribbons WHERE user_id=$UID_ AND week='2025-W01'")" "$NAME"
ok "settle: meta show is gone" "$(mshowv show)" ""
ok "settle: other meta keys kept" "$(noshow "$(mjson)")" "$(noshow "$MB")"
curl -s -b $W/p $BASE/catfish.php -o /dev/null
ok "settle: a second page load adds no second row" "$(rib_wk 2025-W01)" 1
# this week's entry is not settled early
mset "\$m['show']=['week'=>'$WEEK','cat'=>$A];"
curl -s -b $W/p $BASE/catfish.php -o /dev/null
ok "this week's entry: not settled (no ribbon for this week)" "$(rib_wk $WEEK)" 0
ok "this week's entry: stays in meta" "$(mshowv show.week)" "$WEEK"
# an entry whose cat no longer exists: no ribbon, entry cleared
mset "\$m['show']=['week'=>'2025-W02','cat'=>999999];"
curl -s -b $W/p $BASE/catfish.php -o /dev/null
ok "missing cat: no ribbon" "$(rib_wk 2025-W02)" 0
ok "missing cat: entry cleared" "$(mshowv show)" ""

# profile: the ribbon text and the cat name (awards tab), and nothing while Cat Fish is closed
case $TIER in best) RL="Best in Show";; blue) RL="Blue ribbon";; red) RL="Red ribbon";; white) RL="White ribbon";; *) RL="Took part";; esac
PR=$(curl -s -b $W/p "$BASE/profile.php?id=$UID_&tab=awards")
ok "profile: ribbon text for the tier and the cat name" "$(echo "$PR" | grep -cF "$RL: $NAME")" 1
setg catfish_open 0
PR=$(curl -s -b $W/p "$BASE/profile.php?id=$UID_&tab=awards")
ok "profile: no Cat Fish ribbon while closed" "$(echo "$PR" | grep -cF "$RL: $NAME")" 0
ok "profile: no Cat Fish box while closed (ribbons)" "$(echo "$PR" | grep -c 'cfribbon')" 0
setg catfish_open 1

# garden: the active cat shows under the header; a closed Cat Fish shows nothing
dbx "UPDATE catfish_state SET active_cat_id=$B WHERE user_id=$UID_"
G=$(curl -s -b $W/p $BASE/garden.php)
ok "garden: cfgarden line with the active cat" "$(echo "$G" | grep -c 'class="cfgarden"')" 1
ok "garden: the active cat's name is on the line" "$(echo "$G" | grep -c "$NAME is ")" 1
ok "garden: catfish.css is linked" "$(echo "$G" | grep -c 'catfish.css')" 1
setg catfish_open 0
G=$(curl -s -b $W/p $BASE/garden.php)
ok "garden: no cfgarden line while closed" "$(echo "$G" | grep -c 'class="cfgarden"')" 0
ok "garden: catfish.css not linked while closed" "$(echo "$G" | grep -c 'catfish.css')" 0
setg catfish_open 1
# a gnome who never opened Cat Fish gets no catfish_state row from a garden visit (the admin, who has never opened it)
ok "admin never opened Cat Fish: no catfish_state row before" "$(dbv "SELECT COUNT(*) FROM catfish_state WHERE user_id=$ADM")" 0
curl -s -b $W/a -o /dev/null $BASE/garden.php
ok "garden visit by a fresh gnome: no catfish_state row created" "$(dbv "SELECT COUNT(*) FROM catfish_state WHERE user_id=$ADM")" 0

# Puzzle Pals bonus through view.kph: 2% per pal, 10 pals max (+20%), ppal_open and gnome level PPAL_PARTY_LEVEL (1) or more
LV=$(dbv "SELECT level FROM users WHERE id=$UID_")
setg puzzles_open 1; setg jigsaw_open 1; setg ppal_open 1
dbx "UPDATE users SET level=1 WHERE id=$UID_"
cfreset; cfapi -d do=tick >/dev/null   # the first Puzzle Pals read creates its tables
ppal_fill() { dbx "DELETE FROM ppal_found WHERE user_id=$UID_; $(for i in $(seq 1 $1); do printf "INSERT INTO ppal_found (user_id,pal_key,pic_id,found_at) VALUES ($UID_,'t-pal-$i',1,'%s');" "$(date -u +'%Y-%m-%d %H:%M:%S')"; done)"; }
kp() { cfreset; cfapi -d do=tick | jp view.kph; }
kp_eq() { awk "BEGIN{d=$1-$2; if (d<0) d=-d; print (d<=0.2) ? \"y\" : \"n\"}"; }
setg ppal_open 0; ppal_fill 0; KA=$(kp)
ppal_fill 5; KB=$(kp)
ok "ppal_open off: 5 found pals leave view.kph unchanged" "$(kp_eq $KB $KA)" y
setg ppal_open 1
KC=$(kp)
ok "ppal_open on, 5 pals: view.kph is x1.10 (within 0.2)" "$(kp_eq $KC $(awk "BEGIN{print $KA*1.10}"))" y
ppal_fill 15; KD=$(kp)
ok "ppal_open on, 15 pals: view.kph is capped at x1.20 (within 0.2)" "$(kp_eq $KD $(awk "BEGIN{print $KA*1.20}"))" y
dbx "UPDATE users SET level=0 WHERE id=$UID_"; KE=$(kp)
ok "the Pals bonus needs no gnome level (level 0 still x1.20, within 0.2)" "$(kp_eq $KE $(awk "BEGIN{print $KA*1.20}"))" y
dbx "UPDATE users SET level=$LV WHERE id=$UID_; DELETE FROM ppal_found WHERE user_id=$UID_"
setg ppal_open 0; dbx "DELETE FROM settings WHERE name IN ('ppal_open','puzzles_open','jigsaw_open')"

# festival: the page still loads while a festival is running (no numbers asserted)
setg festivals_on 1
ok "festival on: the Cat Fish page loads" "$(curl -s -b $W/p -o /dev/null -w '%{http_code}' $BASE/catfish.php)" 200
setg festivals_on 0

# ribbon tiers by score
TIERS=$(php -r 'function is_admin(){return false;} function setting($n){return "";} function hollow_date($f,$t=null){return (new DateTimeImmutable("@".($t??time())))->setTimezone(new DateTimeZone("America/Halifax"))->format($f);} require "'$GAME'/includes/catfish.php"; foreach ([0,17,18,24,25,31,32,39,40,60] as $x) echo catfish_show_tier($x), " ";')
ok "ribbon tiers: 0 17 18 24 25 31 32 39 40 60" "$TIERS" "part part white white red red blue blue best best "

# art swap: a real PNG replaces the emoji, and only for a safe name
setg catfish_open 1
curl -s -b $W/p $BASE/games.php > $W/g.html
ok "hub tile: emoji while there is no cf-tile.png" "$(grep -c 'cf-tile.png' $W/g.html)" 0
mkdir -p $GAME/assets/img/catfish && cp $GAME/assets/img/icon-32.png $GAME/assets/img/catfish/cf-tile.png
curl -s -b $W/p $BASE/games.php > $W/g.html
ok "hub tile: cf-tile.png used when it exists" "$(grep -c 'img/catfish/cf-tile.png' $W/g.html)" 1
rm -f $GAME/assets/img/catfish/cf-tile.png; rmdir $GAME/assets/img/catfish 2>/dev/null

# one clock: Cat Fish days and weeks follow the Hollow time zone (America/Halifax), never UTC
CLK=$(php -r 'function is_admin(){return false;} function setting($n){return "";} function hollow_date($f,$t=null){return (new DateTimeImmutable("@".($t??time())))->setTimezone(new DateTimeZone("America/Halifax"))->format($f);} require $argv[1];
echo catfish_today(strtotime("2026-10-29 02:30 UTC")), " ", catfish_today(strtotime("2026-10-29 03:30 UTC")), " ", catfish_yesterday("2026-11-02"), " ", catfish_yesterday("2026-03-09"), " ", catfish_yesterday("2027-01-01");' "$GAME/includes/catfish.php")
ok "clock: 23:30 Halifax on Oct 28 (02:30 UTC Oct 29) is still Oct 28; 00:30 Halifax is Oct 29; yesterday is plain calendar maths across DST and year ends" "$CLK" "2026-10-28 2026-10-29 2026-11-01 2026-03-08 2026-12-31"
ok "clock: the only gmdate left in includes/catfish.php is the calendar arithmetic in catfish_yesterday" "$(grep -c 'gmdate' $GAME/includes/catfish.php)" 1
ok "clock: catfish.php and catfish_api.php use no gmdate or UTC day maths" "$(grep -c 'gmdate\|% 86400' $GAME/catfish.php $GAME/catfish_api.php | awk -F: '{s+=$2} END{print s}')" 0

# layered cat renderer (catfish_cat_html): layers generated by tools/catfish_recolor.py into a temp art dir (CATFISH_ART_DIR); never touches game/assets
mkdir -p $W/art; PYTHONDONTWRITEBYTECODE=1 python3 tools/catfish_recolor.py --out $W/art >/dev/null 2>&1; rm -rf tools/__pycache__
# lay: HTML of one cat. args: artdir(or none) json-cat size frame. prints the html
lay() { php -r 'if ($argv[1] !== "none") define("CATFISH_ART_DIR", $argv[1]); define("APP_ROOT", "/nonexistent"); define("APP_VERSION", "t"); function e($v){return htmlspecialchars((string)$v, ENT_QUOTES);} function url($p){return "/".$p;} function is_admin(){return false;} function setting($n){return "";} function hollow_date($f,$t=null){return "";} require $argv[2]; echo catfish_cat_html(json_decode($argv[3], true), (int)$argv[4], $argv[5]);' "$1" "$GAME/includes/catfish.php" "$2" "$3" "$4"; }
# files: the layer file names in stack order, with mask groups as [ears]/[tail] markers
files() { grep -o 'cfmk-[a-z]*-[A-Za-z]*\|cf-[a-z]*-[A-Za-z0-9-]*\.png\|cfclip-[LR]-[A-Za-z]*' | sed 's/\.png//' | tr '\n' ' '; }
A=$W/art
P0='{"colour":"ginger","pattern":"solid","eyes":"amber","ears":"upright","tail":"long","seed":7}'
H=$(lay $A "$P0" 64 idleA)
ok "layers: plain cat = body then eyes" "$(echo "$H" | files)" "cf-cat-orange-idleA cf-eyes-amber-idleA "
ok "layers: wrapper has the size class" "$(echo "$H" | grep -c 'class="cfart cf-s64"')" 1
ok "layers: size snaps to integer scales (100 -> cf-s64, 130 -> cf-s128, 400 -> cf-s192)" "$(for z in 100 130 400; do lay $A "$P0" $z idleA | grep -o 'cf-s[0-9]*'; done | tr '\n' ' ')" "cf-s64 cf-s128 cf-s192 "
H=$(lay $A '{"colour":"white","pattern":"tabby","eyes":"green","ears":"upright","tail":"long","seed":7}' 64 pounce)
ok "layers: patterned cat = body, pattern, eyes" "$(echo "$H" | files)" "cf-cat-white-pounce cf-pat-tabby-white-pounce cf-eyes-green-pounce "
H=$(lay $A '{"colour":"black","pattern":"solid","eyes":"odd","ears":"upright","tail":"long","seed":6}' 64 idleA)
ok "layers: odd-eyed = two eye layers in left and right clip groups, different colours" "$(echo "$H" | files)" "cf-cat-black-idleA cfclip-L-idleA cf-eyes-blue-idleA cfclip-R-idleA cf-eyes-amber-idleA "
H=$(lay $A '{"colour":"grey","pattern":"calico","eyes":"blue","ears":"folded","tail":"long","seed":1}' 64 nap)
ok "layers: folded ears = masked body, ears part, masked pattern, eyes" "$(echo "$H" | files)" "cfmk-ears-nap cf-cat-grey-nap cf-ears-folded-grey-nap cfmk-ears-nap cf-pat-calico-grey-nap cf-eyes-blue-nap "
H=$(lay $A '{"colour":"cream","pattern":"pointed","eyes":"hazel","ears":"folded","tail":"bobtail","seed":1}' 64 catch)
ok "layers: folded ears and bobtail = both masks, both parts, pattern, eyes" "$(echo "$H" | files)" "cfmk-tail-catch cfmk-ears-catch cf-cat-cream-catch cf-ears-folded-cream-catch cf-tail-bobtail-cream-catch cfmk-tail-catch cfmk-ears-catch cf-pat-pointed-cream-catch cf-eyes-hazel-catch "
mkdir -p $W/art2; cp $A/cf-cat-brown-wiggle.png $A/cf-pat-spotted-brown-idleA.png $A/cf-ears-folded-brown-idleA.png $W/art2/   # a body for a frame whose pattern, eyes, mask and part files are missing
H=$(lay $W/art2 '{"colour":"brown","pattern":"spotted","eyes":"amber","ears":"folded","tail":"bobtail","seed":1}' 64 wiggle)
ok "layers: a frame with no overlay files: the body only, no half-drawn parts" "$(echo "$H" | files)" "cf-cat-brown-wiggle "
ok "frames: CATFISH_PATTERN_FRAMES is all 8 frames, idleB, wiggle and bored included" "$(php -r 'function is_admin(){return false;} function setting($n){return "";} function hollow_date($f,$t=null){return "";} require $argv[1]; echo implode(" ", CATFISH_PATTERN_FRAMES), "|", CATFISH_PATTERN_FRAMES === CATFISH_FRAMES ? "same" : "differ";' "$GAME/includes/catfish.php")" "idleA idleB wiggle stalk pounce catch nap bored|same"
# a patterned folded-ear bobtail cat on every one of the 8 frames: body, pattern, ears, tail, eyes (both masks) - a missing layer on any frame is a bug
FRAMES8="idleA idleB wiggle stalk pounce catch nap bored"
for f in $FRAMES8; do
  H=$(lay $A '{"colour":"cream","pattern":"calico","eyes":"green","ears":"folded","tail":"bobtail","seed":1}' 64 $f)
  ok "layers: folded bobtail calico cat, frame $f: both masks, body, ears, tail, pattern, eyes" "$(echo "$H" | files)" "cfmk-tail-$f cfmk-ears-$f cf-cat-cream-$f cf-ears-folded-cream-$f cf-tail-bobtail-cream-$f cfmk-tail-$f cfmk-ears-$f cf-pat-calico-cream-$f cf-eyes-green-$f "
done
ok "layers: no inline style, no script, all images empty alt" "$(for f in idleA nap; do lay $A '{"colour":"ginger","pattern":"tabby","eyes":"odd","ears":"folded","tail":"bobtail","seed":3}' 128 $f; done | grep -c 'style=\|<script\|on[a-z]*=')" 0
ok "layers: bad frame name falls back to idleA" "$(lay $A "$P0" 64 '../x' | grep -c 'cf-cat-orange-idleA')" 1
ok "css: mask, clip and size classes exist for every frame the renderer can emit" "$(for c in cf-s64 cf-s128 cf-s192 cfmk-ears-idleA cfmk-tail-pounce cfclip-L-stalk cfclip-R-nap cfmk-ears-idleB cfmk-ears-wiggle cfmk-ears-bored cfmk-tail-idleB cfmk-tail-wiggle cfmk-tail-bored; do grep -c "\.$c " $GAME/assets/catfish.css; done | tr '\n' ' ')" "1 1 1 1 1 1 1 1 1 1 1 1 1 "
ok "css: no art, no change: every png has image-rendering pixelated" "$(grep -c 'image-rendering: pixelated' $GAME/assets/catfish.css | awk '{print ($1>=3)?"y":"n"}')" y
OLD='<span class="cfcat c-ginger p-tabby e-amber" aria-hidden="true">🐱</span>'
ok "no art folder: the old emoji block renders unchanged" "$(lay none '{"colour":"ginger","pattern":"tabby","eyes":"amber","ears":"folded","tail":"bobtail","seed":3}' 64 idleA)" "$OLD"
ok "lilac now has art: layered like any coat" "$(lay $A '{"colour":"lilac","pattern":"tabby","eyes":"amber","ears":"upright","tail":"long","seed":3}' 64 idleA | files)" "cf-cat-lilac-idleA cf-pat-tabby-lilac-idleA cf-eyes-amber-idleA "
ok "no art for this coat (unknown colour): emoji block" "$(lay $A '{"colour":"mauve","pattern":"tabby","eyes":"amber","ears":"upright","tail":"long","seed":3}' 64 idleA)" '<span class="cfcat c-mauve p-tabby e-amber" aria-hidden="true">🐱</span>'
ok "no body png for the frame (empty dir): emoji block" "$(lay $W/nonesuch '{"colour":"ginger","pattern":"tabby","eyes":"amber","ears":"upright","tail":"long","seed":3}' 64 idleA)" "$OLD"
ok "page without art: shelter and cat cards are the emoji blocks (no cfart)" "$(curl -s -b $W/p $BASE/catfish.php | grep -c 'class="cfart')" 0
ok "page without art: cards still show the emoji cat" "$([ "$(curl -s -b $W/p $BASE/catfish.php | grep -c 'class="cfcat c-')" -ge 3 ] && echo y || echo n)" y

# art wiring beyond the cat: rod and fish, kibble and yarn icons, room stack, Cat Book heads, banner. Art = the full set built by tools/catfish_build_art.py into a temp dir.
FULL=$W/full; PYTHONDONTWRITEBYTECODE=1 python3 tools/catfish_build_art.py --out $FULL --check >/dev/null 2>&1 || echo "FAIL build art set"; rm -rf tools/__pycache__
# cfx: result of a PHP expression. args: artdir(or none) expression
cfx() { php -r 'if ($argv[1] !== "none") define("CATFISH_ART_DIR", $argv[1]); define("APP_ROOT", "/nonexistent"); define("APP_VERSION", "t"); function e($v){return htmlspecialchars((string)$v, ENT_QUOTES);} function url($p){return "/".$p;} function is_admin(){return false;} function setting($n){return "";} function hollow_date($f,$t=null){return "";} require $argv[2]; echo eval("return " . $argv[3] . ";");' "$1" "$GAME/includes/catfish.php" "$2"; }
OLDROD='<div class="cfrod" aria-hidden="true"><span class="cfwand">🎣</span><span class="cffish f1">🐟</span><span class="cffish f2">🐠</span><span class="cffish f3">🐡</span></div>'
ok "fish kinds: plain only = 1 1 1" "$(cfx none 'implode(" ", catfish_fish_kinds([]))')" "1 1 1"
ok "fish kinds: silk = 1 2 1; silk and catnip = 1 2 3" "$(cfx none 'implode(" ", catfish_fish_kinds(["silk"=>2])) . "|" . implode(" ", catfish_fish_kinds(["silk"=>1,"catnip"=>1]))')" "1 2 1|1 2 3"
ok "fish kinds: everything and a Sneaky cat = the newest three, 3 4 5" "$(cfx none 'implode(" ", catfish_fish_kinds(["silk"=>1,"catnip"=>1,"glitter"=>1], ["mood"=>"sneaky"]))')" "3 4 5"
ok "rod, no art: today's emoji markup, byte for byte" "$(cfx none 'catfish_rod_html([])')" "$OLDROD"
H=$(cfx $FULL 'catfish_rod_html(["silk"=>1,"glitter"=>1], ["mood"=>"lazy"])')
ok "rod, art: the wand and three fish (1, 2, 4), strings are CSS" "$(echo "$H" | grep -o 'cf-rod.png\|cf-fish-[0-9].png\|class="cfstr"' | tr '\n' ' ')" 'cf-rod.png class="cfstr" cf-fish-1.png class="cfstr" cf-fish-2.png class="cfstr" cf-fish-4.png '
ok "rod, art: no inline style, wand is 48 x 64" "$(echo "$H" | grep -c 'style=')$(echo "$H" | grep -c 'width="48" height="64"')" "01"
mkdir -p $W/art3; cp $FULL/cf-fish-1.png $W/art3/
H=$(cfx $W/art3 'catfish_rod_html(["silk"=>1])')
ok "rod, only a fish PNG: wand keeps its emoji, fish is art, the other fish keep theirs" "$(echo "$H" | grep -c '🎣')$(echo "$H" | grep -c 'cf-fish-1.png')$(echo "$H" | grep -c '🐠')" "111"
ok "icons, no art: nothing at all" "$(cfx none 'catfish_ico("ico-kibble") . catfish_ico("ico-yarn", 24)')" ""
ok "icons, art: the PNG and a space" "$(cfx $FULL 'catfish_ico("ico-kibble")' | grep -o 'cf-ico-kibble.png.*width="32" height="32"')" 'cf-ico-kibble.png?v=t" alt="" width="32" height="32"'
ok "catfish_img: art folder honoured, bad name falls back" "$(cfx $FULL 'catfish_img("fish-5", "F", "gold", 48) . catfish_img("../x", "Z")' | grep -o 'cf-fish-5.png\|alt="gold"\|<span aria-hidden="true">Z</span>' | tr '\n' ' ')" 'cf-fish-5.png alt="gold" <span aria-hidden="true">Z</span> '
ok "catfish_img: banner is 480 x 120" "$(cfx $FULL 'catfish_img("banner", "", "Cat Fish", 480, 120)' | grep -c 'width="480" height="120"')" 1
CATS3='[["colour"=>"ginger","pattern"=>"solid","eyes"=>"amber","ears"=>"upright","tail"=>"long","seed"=>1],["colour"=>"lilac","pattern"=>"tabby","eyes"=>"odd","ears"=>"folded","tail"=>"bobtail","seed"=>2],["colour"=>"black","pattern"=>"calico","eyes"=>"blue","ears"=>"upright","tail"=>"long","seed"=>3]]'
ok "room, no art: nothing (no room on the page)" "$(cfx none "catfish_room_html($CATS3, [\"rug\"=>1])")" ""
H=$(cfx $FULL "catfish_room_html($CATS3, [\"sunbeam\"=>2, \"rug\"=>1, \"window\"=>0])")
ok "room, art: base then owned overlays only (sunbeam, rug), in stacking order" "$(echo "$H" | grep -o 'cf-room[a-z-]*.png' | tr '\n' ' ')" "cf-room.png cf-room-sunbeam.png cf-room-rug.png "
ok "room, art: three cats in three position classes, layered art, no inline style" "$(echo "$H" | grep -o 'cfrc n3 i[0-9]' | tr '\n' ',')$(echo "$H" | grep -o 'class="cfart' | wc -l | tr -d ' ')$(echo "$H" | grep -c 'style=')" "cfrc n3 i1,cfrc n3 i2,cfrc n3 i3,30"
ok "room, art: the lilac folded-ear bobtail cat is layered (lilac body, ears, tail)" "$(echo "$H" | grep -o 'cf-cat-lilac-idleA\|cf-ears-folded-lilac-idleA\|cf-tail-bobtail-lilac-idleA' | tr '\n' ' ')" "cf-cat-lilac-idleA cf-ears-folded-lilac-idleA cf-tail-bobtail-lilac-idleA "
ok "room, art, no cats yet: the room and no cat" "$(cfx $FULL 'catfish_room_html([], [])' | grep -c 'cfrc')" 0
ok "room: six cats show four" "$(cfx $FULL "catfish_room_html(array_merge($CATS3, $CATS3), [])" | grep -o 'cfrc n4' | wc -l | tr -d ' ')" 4
ok "css: 10 room position rules (1 + 2 + 3 + 4 cats)" "$(grep -o '\.cfrc\.n[1-4]\.i[1-4] {' $GAME/assets/catfish.css | wc -l | tr -d ' ')" 10
ok "book cell, no art: today's circle, adopted shows the emoji" "$(cfx none 'catfish_book_cell("ginger", 1, "Ginger tabby, adopted") . catfish_book_cell("black", -1, "Black tabby, not seen yet")')" '<span class="cfbcell got c-ginger" role="img" aria-label="Ginger tabby, adopted" title="Ginger tabby, adopted">🐱</span><span class="cfbcell none" role="img" aria-label="Black tabby, not seen yet" title="Black tabby, not seen yet"></span>'
ok "book cell, art: found coats use their head (ginger -> orange, lilac), unknown uses the question head" "$(cfx $FULL 'catfish_book_cell("ginger", 1, "a") . catfish_book_cell("lilac", 0, "b") . catfish_book_cell("white", -1, "c")' | grep -o 'cf-bookhead-[a-z-]*.png\|got adopted\|got seen\|cfbcell art none' | tr '\n' ' ')" "got adopted cf-bookhead-orange.png got seen cf-bookhead-lilac.png cfbcell art none cf-bookhead-unknown.png "
mkdir -p $W/art4; cp $FULL/cf-bookhead-unknown.png $W/art4/
ok "book cell, art for unknown only: a found coat keeps today's circle" "$(cfx $W/art4 'catfish_book_cell("ginger", 0, "a") . catfish_book_cell("ginger", -1, "b")' | grep -o 'cfbcell got c-ginger\|cf-bookhead-unknown.png' | tr '\n' ' ')" "cfbcell got c-ginger cf-bookhead-unknown.png "
ok "art coat map: all 8 coats have art, lilac included" "$(cfx none 'count(CATFISH_ART_COATS) . " " . CATFISH_ART_COATS["lilac"]')" "8 lilac"
# play scene (catfish_stage_html): one centred stage with the room stack, wand, three fish, the other cats as still frames and the active cat with all 8 frame groups
SC='[["id"=>1,"name"=>"Pip","colour"=>"ginger","pattern"=>"tabby","eyes"=>"amber","ears"=>"folded","tail"=>"bobtail","seed"=>11,"mood"=>"hyper"],["id"=>2,"name"=>"Dot","colour"=>"lilac","pattern"=>"solid","eyes"=>"odd","ears"=>"upright","tail"=>"long","seed"=>2,"mood"=>"hyper"],["id"=>3,"name"=>"Zed","colour"=>"black","pattern"=>"calico","eyes"=>"blue","ears"=>"upright","tail"=>"long","seed"=>3,"mood"=>"lazy"],["id"=>4,"name"=>"Moe","colour"=>"white","pattern"=>"spotted","eyes"=>"green","ears"=>"folded","tail"=>"long","seed"=>4,"mood"=>"dreamy"],["id"=>5,"name"=>"Fig","colour"=>"brown","pattern"=>"tuxedo","eyes"=>"hazel","ears"=>"upright","tail"=>"bobtail","seed"=>5,"mood"=>"greedy"]]'
ok "stage, no art: nothing (the page keeps the old rod box)" "$(cfx none "catfish_stage_html($SC, $SC[0], [\"rug\"=>1])")" ""
SH=$(cfx $FULL "catfish_stage_html($SC, $SC[0], [\"sunbeam\"=>1, \"rug\"=>1, \"silk\"=>1])")
ok "stage: one stage in a wrapper, room base then owned overlays only, wand, then the fish" "$(echo "$SH" | grep -o 'class="cfstage"\|cf-room[a-z-]*.png\|cf-rod.png\|cf-fish-[0-9].png' | tr '\n' ' ')" 'class="cfstage" cf-room.png cf-room-sunbeam.png cf-room-rug.png cf-rod.png cf-fish-1.png cf-fish-2.png cf-fish-1.png '
ok "stage: three dangling fish (sd1..sd3), each with a string, and the line from the wand" "$(echo "$SH" | grep -o 'cfsdrop sd[0-9]\|class="cfstr"\|class="cfsline"' | tr '\n' ' ')" 'class="cfsline" cfsdrop sd1 class="cfstr" cfsdrop sd2 class="cfstr" cfsdrop sd3 class="cfstr" '
ok "stage: the active cat is in the centre play zone with all 8 frame groups, starting on idleA" "$(echo "$SH" | grep -o 'class="cfactive cfpos-x128-y120 fr-idleA" data-frame="idleA"')$(echo "$SH" | grep -o 'class="cfframe ff-[A-Za-z]*"' | sed 's/.*ff-//;s/"//' | tr '\n' ' ')" 'class="cfactive cfpos-x128-y120 fr-idleA" data-frame="idleA"idleA idleB wiggle stalk pounce catch nap bored '
AH=$(echo "$SH" | sed 's/.*class="cfactive/class="cfactive/')
ok "stage: every frame group of the folded bobtail tabby cat has body, pattern, ears, tail and eyes" "$(for f in idleA idleB wiggle stalk pounce catch nap bored; do echo "$AH" | grep -o "cf-cat-orange-$f.png\|cf-pat-tabby-orange-$f.png\|cf-ears-folded-orange-$f.png\|cf-tail-bobtail-orange-$f.png\|cf-eyes-amber-$f.png" | wc -l | tr -d ' '; done | tr '\n' ' ')" "5 5 5 5 5 5 5 5 "
ok "stage: three other cats at the side spots (a lazy cat first on the cushion as nap), frames nap, idleA, bored" "$(echo "$SH" | grep -o 'cfspot cfpos-x[0-9]*-y[0-9]*"><span class="cfart cf-s64" aria-hidden="true">\(<span class="cfmk[^>]*>\)*<img src="[^"]*cf-cat-[a-z-]*-[A-Za-z]*\.png' | sed 's/cfspot cfpos-//;s/".*cf-cat-/ /;s/\.png//' | tr '\n' ',')" "x40-y98 lilac-idleA,x236-y116 white-bored,x0-y124 black-nap,"
SH2=$(cfx $FULL "catfish_stage_html(array_slice($SC, 0, 2), $SC[0], [])")
ok "stage: two cats = the active one and one at the cushion (nap frame)" "$(echo "$SH2" | grep -c 'cfpos-x0-y124')$(echo "$SH2" | grep -c 'cfpos-x40-y98')$(echo "$SH2" | grep -c 'cfpos-x236-y116')" "100"
SH3=$(cfx $FULL "catfish_stage_html([$SC[0]], $SC[0], [], true)")
ok "stage: a lone cat has no side spots; a napping one starts on the nap frame (data-nap)" "$(echo "$SH3" | grep -c 'cfspot')$(echo "$SH3" | grep -c 'fr-nap" data-frame="nap" data-seed="11" data-nap="1"')" "01"
ok "stage: no inline style, no script, no event handler; every img has an empty alt except none" "$(echo "$SH" | grep -c 'style=\|<script\|on[a-z]*=')" 0
ok "stage: the page's catfish_room_html is unchanged (still its own markup)" "$(cfx $FULL "catfish_room_html($CATS3, [])" | grep -c 'class="cfroom"')" 1
# positions and sizes in catfish.css come from room-layout.json; the PHP spots too
python3 -I - "aseprite-source/catfish/room-layout.json" "$GAME/assets/catfish.css" "$GAME/includes/catfish.php" <<'P'
import sys, json, re
j = json.load(open(sys.argv[1])); css = open(sys.argv[2]).read(); php = open(sys.argv[3]).read()
bad = []
def rule(sel):
    m = re.search(re.escape(sel) + r' \{([^}]*)\}', css)
    return m.group(1) if m else ''
def px(body, prop):
    m = re.search(r'(?:^|[ ;])' + prop + r': (-?\d+)(?:px)?[ ;]', body + ' ')
    return int(m.group(1)) if m else None
for c in j['cats']:
    b = rule('.cfpos-x%d-y%d' % (c['x'], c['y']))
    if px(b, 'left') != c['x'] or px(b, 'top') != c['y']: bad.append('cat position class x%d y%d' % (c['x'], c['y']))
side = [(c['frame'], c['x'], c['y']) for c in j['cats'] if c['role'] == 'side']
m = re.search(r"CATFISH_STAGE_SPOTS = \[(.*?)\];", php).group(1)
spots = [(f, int(x), int(y)) for f, x, y in re.findall(r"\['(\w+)', (\d+), (\d+)\]", m)]
if spots != side: bad.append('PHP CATFISH_STAGE_SPOTS %s != layout %s' % (spots, side))
act = [c for c in j['cats'] if c['role'] == 'active'][0]
if re.search(r"CATFISH_STAGE_ACTIVE = \[(\d+), (\d+)\]", php).groups() != (str(act['x']), str(act['y'])): bad.append('PHP CATFISH_STAGE_ACTIVE')
w = rule('.cfswand')
if (px(w, 'left'), px(w, 'top')) != (j['wand']['img_x'], j['wand']['img_y']): bad.append('wand position')
ln = rule('.cfsline')
if (px(ln, 'left'), px(ln, 'top') + px(ln, 'height') // 2) != tuple(j['wand']['tip']): bad.append('line start at the wand tip')
if px(ln, 'left') + px(ln, 'width') < max(d['x'] for d in j['strings']['drops']): bad.append('line does not reach the last string')
for i, d in enumerate(j['strings']['drops'], 1):
    b = re.search(r'\.cfsdrop\.sd%d \{([^}]*)\}' % i, css).group(1)
    if px(b, 'left') != d['x'] - 24 or px(b, '--cfl') != d['fish_y'] - d['top']: bad.append('fish drop %d' % i)
if px(rule('.cfsdrop'), 'top') != j['strings']['drops'][0]['top']: bad.append('drop top')
print('ok   stage css/PHP coordinates match room-layout.json' if not bad else 'FAIL stage coordinates: ' + '; '.join(bad))
P

# fishing line meets the fish: --cfn per fish kind (catfish.css .cfk-N) == first opaque row of cf-fish-N.png in the string columns (23, 24, as .cfstr left/width); each drop carries cfk-N of its fish
python3 -I - "$FULL" "$GAME/assets/catfish.css" "$SH" <<'P'
import sys, re
from PIL import Image
d, css, html = sys.argv[1:]
css = open(css).read(); bad = []
m = re.search(r'\.cfsdrop \.cfstr \{([^}]*)\}', css).group(1)
if not re.search(r'left: 23px', m) or not re.search(r'width: 2px', m) or 'calc(var(--cfl, 20px) + var(--cfn, 0px))' not in m: bad.append('cfstr rule')
for n in range(1, 6):
    im = Image.open('%s/cf-fish-%d.png' % (d, n)).convert('RGBA')
    tops = []
    for x in (23, 24):
        ys = [y for y in range(im.height) if im.getpixel((x, y))[3] > 0]
        tops.append(ys[0] if ys else None)
    r = re.search(r'\.cfk-%d \{ --cfn: (\d+)px; \}' % n, css)
    if not r: bad.append('fish %d: no --cfn' % n); continue
    if tops[0] is None or tops[0] != tops[1] or int(r.group(1)) != tops[0]: bad.append('fish %d: css %s, art %s' % (n, r.group(1), tops))
drops = re.findall(r'class="cfsdrop sd(\d) cfk-(\d)"><i class="cfstr"></i><img[^>]*cf-fish-(\d)\.png', html)
if len(drops) != 3 or any(k != f for _, k, f in drops): bad.append('drop classes %s' % drops)
print('ok   fishing lines: --cfn of fish 1-5 equals the first opaque string row of each PNG, and every drop carries its fish kind (cfk-N)' if not bad else 'FAIL fishing lines: ' + '; '.join(bad))
P
ok "css: stage is 320 x 200, centred in a flex wrapper, pixelated, with a reduced-motion rule for the sway" "$(grep -c '^\.cfstage { position: relative; flex: none; width: 320px; height: 200px' $GAME/assets/catfish.css)$(grep -c '^\.cfstagewrap { display: flex; justify-content: center' $GAME/assets/catfish.css)$(grep -c 'prefers-reduced-motion: reduce) { .cfsdrop' $GAME/assets/catfish.css)" 111
# frame names in the css (one show-rule each) and in the JS state machine
ok "css: each of the 8 frames has a show rule on .cfactive" "$(for f in idleA idleB wiggle stalk pounce catch nap bored; do grep -c "\.cfactive\.fr-$f \.ff-$f" $GAME/assets/catfish.css; done | tr '\n' ' ')" "1 1 1 1 1 1 1 1 "
ok "js: state machine frames (wiggle, stalk, pounce, catch, bored, nap, idleB) and reduced-motion are in catfish.js" "$(for w in "'wiggle', 600" "'stalk', 800" "'pounce', 400" "'catch', 1200" "'bored'" "'nap'" "'idleB'" "prefers-reduced-motion" "data-frame"; do grep -c -F "$w" $GAME/assets/catfish.js | awk '{print ($1>0)?"y":"n"}'; done | tr -d '\n')" "yyyyyyyyy"
ok "js: no inline script or style needed (catfish.js is the only script, loaded from layout.php)" "$(grep -c 'eval(\|innerHTML\|document.write' $GAME/assets/catfish.js)" 0

# odd-eyed split columns: recomputed from the PNGs (the midpoint between the two eye clusters of cf-eyes-ring-<frame>.png), compared with catfish.css and tools/catfish_recolor.py
python3 -I - "aseprite-source/catfish/test" "$GAME/assets/catfish.css" <<'P'
import sys, os, re, numpy as np
from PIL import Image
sys.dont_write_bytecode = True; sys.path.insert(0, 'tools')
import catfish_recolor as R
d, css = sys.argv[1:]
css = open(css).read()
if not any(os.path.exists('%s/cf-eyes-ring-%s.png' % (d, f)) for f in R.EYE_SPLIT): print('ok   odd-eyed split: skipped (no eye PNGs in %s)' % d); sys.exit(0)
bad = []; n = 0
for f, want in R.EYE_SPLIT.items():
    m = re.search(r'\.cfclip-L-%s \{ clip-path: inset\(0 ([0-9.]+)%% 0 0\); \} \.cfclip-R-%s \{ clip-path: inset\(0 0 0 ([0-9.]+)%%\); \}' % (f, f), css)
    if not m: bad.append(f + ': no css rule'); continue
    if abs(float(m.group(2)) - want / 64 * 100) > 1e-3 or abs(float(m.group(1)) - (100 - want / 64 * 100)) > 1e-3: bad.append('%s: css split != %d' % (f, want))
    p = '%s/cf-eyes-ring-%s.png' % (d, f)
    got = R.eye_split(p) if os.path.exists(p) else None
    if got is None: continue   # closed eyes (catch, nap): no eye pixels, nothing to split
    n += 1
    a = np.array(Image.open(p).convert('RGBA'))[..., 3] > 0
    if got != want: bad.append('%s: EYE_SPLIT %d but the art says %d' % (f, want, got))
    if a[:, :got].sum() != a[:, got:].sum() or not a[:, :got].any(): bad.append('%s: split %d does not halve the eyes' % (f, got))
print(('ok   odd-eyed split: %d frames recomputed from the ring PNGs match EYE_SPLIT and catfish.css' % n) if not bad else 'FAIL odd-eyed split: ' + '; '.join(bad))
P
ok "css: the guessed split of idleB, wiggle and bored is gone (each differs from idleA's 39.0625%)" "$(grep -o 'cfclip-R-\(idleB\|wiggle\|bored\) { clip-path: inset(0 0 0 [0-9.]*%' $GAME/assets/catfish.css | grep -vc '39.0625')" 3

# the real page with the full art set installed in this suite's own copy of game/ (removed after): banner, rod, icons, room, Cat Book heads
mkdir -p $GAME/assets/img/catfish; cp $FULL/cf-*.png $GAME/assets/img/catfish/
curl -s -b $W/p $BASE/catfish.php > $W/art.html
ok "page with art: banner is the heading (img with alt text, no emoji heading)" "$(grep -c '<h1 class="cfbanner"><img class="cfimg" src="[^"]*cf-banner.png[^"]*" alt="Cat Fish" width="480" height="120">' $W/art.html)$(grep -c '<h1>🐱 Cat Fish</h1>' $W/art.html)" "10"
ok "page with art: rod art and 3 fish" "$(grep -c 'cf-rod.png' $W/art.html)$(grep -o 'cf-fish-[0-9].png' $W/art.html | wc -l | tr -d ' ')" "13"
ok "page with art: kibble icon by the count, yarn icon in the Nap and Home summaries" "$(grep -o 'cf-ico-kibble.png' $W/art.html | wc -l | tr -d ' ')$(grep -o 'cf-ico-yarn.png' $W/art.html | wc -l | tr -d ' ')" "12"
NCATS=$(dbv "SELECT COUNT(*) FROM cats WHERE user_id=$UID_"); NSIDE=$(( NCATS - 1 )); [ $NSIDE -gt 3 ] && NSIDE=3
ok "page with art: one stage with the room, wand, 3 fish; the old rod box and the separate room are gone" "$(grep -c 'class="cfstage"' $W/art.html)$(grep -c 'cf-room.png' $W/art.html)$(grep -c 'class="cfrod\|class="cfroom"\|class="cfrc ' $W/art.html)" "110"
ok "page with art: the active cat has 8 frame groups and data-frame, the other cats stand at the side spots" "$(grep -o 'class="cfframe ff-' $W/art.html | wc -l | tr -d ' ')$(grep -c 'data-frame="idleA"\|data-frame="nap"' $W/art.html)$(grep -o 'class="cfspot ' $W/art.html | wc -l | tr -d ' ')" "81$NSIDE"
ok "page with art: the cat card (name, traits, Kibble) sits under the stage and has no second sprite" "$(grep -c 'class="cfscene cfcard box"' $W/art.html)$(awk '/class="cfscene cfcard box"/{f=1} f&&/id="cf-kibble"/{print "k"; exit}' $W/art.html)$(sed -n '/class="cfscene cfcard box"/,$p' $W/art.html | sed '1s/.*class="cfscene cfcard box"//' | awk '/id="cf-kibble"/{exit} /class="cfart/{print "x"; exit}' | wc -c | tr -d ' ')" "1k0"
ok "page with art: the page is wrapped in .cfpage (centred headings) and stays one script block plus the json" "$(grep -c 'class="cfpage"' $W/art.html)$(grep -c 'type="application/json" id="cf-data"' $W/art.html)" "11"
ok "page with art: Cat Book cells use heads, unknown cells use the question head" "$([ "$(grep -c 'cf-bookhead-' $W/art.html)" -ge 1 ] && echo y)$([ "$(grep -o 'cf-bookhead-unknown.png' $W/art.html | wc -l)" -ge 10 ] && echo y)" "yy"
ok "page with art: no inline style and no inline script besides the JSON block" "$(grep -c ' style=\|<script>' $W/art.html)" 0
rm -rf "${GAME:?}/assets/img/catfish"
curl -s -b $W/p $BASE/catfish.php > $W/noart.html
ok "page without art: emoji heading, emoji rod, no room, no icons, no book heads" "$(grep -c '<h1>🐱 Cat Fish</h1>' $W/noart.html)$(grep -c 'class="cfrod" ' $W/noart.html)$(grep -c 'class="cfroom"\|cf-ico-\|cf-bookhead-\|cfbanner\|cfrod-art\|cfstage\|cfactive' $W/noart.html)" "110"

# cleanup
dbx "DELETE FROM settings WHERE name IN ('catfish_open')"
