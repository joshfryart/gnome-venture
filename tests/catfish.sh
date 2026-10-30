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
ok "Yarn to spend shows 100 - 13 = 87" "$(grep -c 'Yarn · 87 to spend' $W/w3.html)" 1

CF0=$(dbv "SELECT yarn || '|' || meta || '|' || upgrades FROM catfish_state WHERE user_id=$UID_"); TITLE0=$(dbv "SELECT COALESCE(title,'') FROM users WHERE id=$UID_")   # restored after 4b to 4d
# 4b. Buy x10 (3 Yarn, one-off): n=10 is only honoured once unlocked, costs the sum of ten levels, all or none
dbx "UPDATE catfish_state SET yarn=100, kibble=1000000, upgrades='{}', last_tick=$(date +%s), meta='{\"extra\":2,\"ys\":0}' WHERE user_id=$UID_"
pagew3; cfreset
cfapi -d do=buy -d key=fish -d n=10 >/dev/null
ok "buy n=10 before the unlock buys one level" "$(dbv "SELECT json_extract(upgrades,'$.fish') FROM catfish_state WHERE user_id=$UID_")" 1
cfpost -d do=bulk >/dev/null
ok "Buy x10 costs 3 Yarn: ys=3" "$(mget ys)" 3
ok "Buy x10 unlocked: bulk=1" "$(mget bulk)" 1
cfpost -d do=bulk >/dev/null
ok "Buy x10 twice refused: ys stays 3" "$(mget ys)" 3
pagew3; ok "Buy x10 bar is on the page once unlocked" "$(grep -c 'id="cf-bulk"' $W/w3.html)" 1
dbx "UPDATE catfish_state SET kibble=1000000, upgrades='{}', last_tick=$(date +%s) WHERE user_id=$UID_"
cfreset; cfapi -d do=buy -d key=fish -d n=10 >/dev/null
ok "buy n=10 buys ten levels" "$(dbv "SELECT json_extract(upgrades,'$.fish') FROM catfish_state WHERE user_id=$UID_")" 10
SPENT10=$((1000000 - $(dbv "SELECT kibble FROM catfish_state WHERE user_id=$UID_")))
dbx "UPDATE catfish_state SET kibble=100, upgrades='{}', last_tick=$(date +%s) WHERE user_id=$UID_"
cfreset; cfapi -d do=buy -d key=fish -d n=10 >/dev/null
ok "buy n=10 without the Kibble for ten: nothing bought" "$(dbv "SELECT upgrades FROM catfish_state WHERE user_id=$UID_")" "{}"

# 4c. Longer naps away: 4, 8, 16 Yarn, +1 hour each, a fourth is refused
dbx "UPDATE catfish_state SET yarn=100, meta='{\"extra\":2,\"ys\":0}' WHERE user_id=$UID_"
cfpost -d do=away >/dev/null; ok "Longer naps away 1 costs 4: ys=4" "$(mget ys)" 4
cfpost -d do=away >/dev/null; ok "Longer naps away 2 costs 8: ys=12" "$(mget ys)" 12
cfpost -d do=away >/dev/null; ok "Longer naps away 3 costs 16: ys=28" "$(mget ys)" 28
cfpost -d do=away >/dev/null; ok "Longer naps away 4 refused: ys stays 28, away stays 3" "$(mget ys),$(mget away)" "28,3"
dbx "UPDATE catfish_state SET yarn=2, meta='{\"extra\":2,\"ys\":0}' WHERE user_id=$UID_"
cfpost -d do=away >/dev/null; ok "Longer naps away with 2 Yarn: refused (away stays 0)" "$(mget away)" 0

# 4d. Yarn titles: Cat Person 15, Napmaster 30; only a bought title can be picked in the Almanac
dbx "UPDATE catfish_state SET yarn=100, meta='{\"extra\":2,\"ys\":0}' WHERE user_id=$UID_"
cfpost -d do=title -d key=catperson >/dev/null; ok "Cat Person costs 15: ys=15" "$(mget ys)" 15
cfpost -d do=title -d key=catperson >/dev/null; ok "Cat Person twice refused: ys stays 15" "$(mget ys)" 15
cfpost -d do=title -d key=nonsense >/dev/null; ok "unknown title refused: ys stays 15" "$(mget ys)" 15
dbx "UPDATE users SET title=NULL WHERE id=$UID_"
curl -s -b $W/p -o /dev/null -X POST $BASE/book.php --data-urlencode "csrf=$CS" --data-urlencode "title=Napmaster"
ok "Almanac: an unbought title is refused" "$(dbv "SELECT COALESCE(title,'') FROM users WHERE id=$UID_")" ""
curl -s -b $W/p -o /dev/null -X POST $BASE/book.php --data-urlencode "csrf=$CS" --data-urlencode "title=Cat Person"
ok "Almanac: the bought title can be picked" "$(dbv "SELECT title FROM users WHERE id=$UID_")" "Cat Person"
cfpost -d do=title -d key=napmaster >/dev/null; ok "Napmaster costs 30: ys=45" "$(mget ys)" 45

cfx() { php -r 'if ($argv[1] !== "none") define("CATFISH_ART_DIR", $argv[1]); define("APP_ROOT", "/nonexistent"); define("APP_VERSION", "t"); function e($v){return htmlspecialchars((string)$v, ENT_QUOTES);} function url($p){return "/".$p;} function is_admin(){return false;} function setting($n){return "";} function hollow_date($f,$t=null){return "";} require $argv[2]; echo eval("return " . $argv[3] . ";");' "$1" "$GAME/includes/catfish.php" "$2"; }
# 4e. Hold a cat, Stakeout, Second show entry, Buddy cat, Keepsake, Yarn ball colours
TD=$(TZ=America/Halifax date +%F); TM=$(TZ=America/Halifax date -d tomorrow +%F)
CID1=$(dbv "SELECT id FROM cats WHERE user_id=$UID_ ORDER BY id LIMIT 1"); CID2=$(dbv "SELECT id FROM cats WHERE user_id=$UID_ ORDER BY id LIMIT 1 OFFSET 1"); CID3=$(dbv "SELECT id FROM cats WHERE user_id=$UID_ ORDER BY id LIMIT 1 OFFSET 2")
CID4=$(dbv "SELECT id FROM cats WHERE user_id=$UID_ ORDER BY id DESC LIMIT 1"); dbx "UPDATE cats SET user_id=0 WHERE id=$CID4"   # park the last cat so the home has room and the shelter shows (put back below)
HM='{"extra":3,"ys":0,"roll":{"day":"'$TD'","n":[1,1,1]}}'   # room for a fifth cat, and spots the gnome does not own yet
dbx "UPDATE catfish_state SET yarn=200, active_cat_id=$CID1, meta='$HM' WHERE user_id=$UID_"
pagew3; SEEDH=$(seed_of 0 $W/w3.html)
cfpost -d do=hold -d slot=0 >/dev/null
ok "Hold a cat costs 2 Yarn: ys=2" "$(mget ys)" 2
ok "Hold a cat: remembered for tomorrow, slot 0, the cat's seed" "$(mget hold.for),$(mget hold.slot),$(mget hold.seed)" "$TM,0,$SEEDH"
cfpost -d do=hold -d slot=1 >/dev/null
ok "second hold for the same day refused: ys stays 2" "$(mget ys)" 2
dbx "UPDATE catfish_state SET meta='{\"extra\":3,\"ys\":2,\"hold\":{\"for\":\"$TD\",\"seed\":12345,\"slot\":1}}' WHERE user_id=$UID_"
pagew3
ok "a cat held yesterday is back in its spot today" "$(seed_of 1 $W/w3.html)" 12345
dbx "UPDATE cats SET user_id=$UID_ WHERE id=$CID4"
dbx "UPDATE catfish_state SET meta='{\"extra\":2,\"ys\":0}' WHERE user_id=$UID_"
cfpost -d do=stake --data-urlencode pick=pattern:calico >/dev/null
ok "Stakeout costs 3 Yarn: ys=3, set for tomorrow" "$(mget ys),$(mget stake.for),$(mget stake.value)" "3,$TM,calico"
cfpost -d do=stake --data-urlencode pick=colour:ginger >/dev/null
ok "second stakeout for the same day refused: ys stays 3" "$(mget ys)" 3
dbx "UPDATE catfish_state SET meta='{\"extra\":2,\"ys\":3}' WHERE user_id=$UID_"
cfpost -d do=stake --data-urlencode pick=eyes:blue >/dev/null
ok "stakeout on eyes refused: ys stays 3" "$(mget ys)" 3
ok "stakeout finds more of the coat than a plain shelter does" "$(cfx none '(function(){ $a = 0; $b = 0; for ($d = 1; $d <= 30; $d++) { foreach (catfish_shelter(7, "2026-03-" . sprintf("%02d", $d), [], 0, ["pattern", "calico"]) as $c) if ($c["pattern"] === "calico") $a++; foreach (catfish_shelter(7, "2026-03-" . sprintf("%02d", $d)) as $c) if ($c["pattern"] === "calico") $b++; } return ($a > $b ? "more" : "no") . "," . ($b > 0 ? "base" : "none"); })()')" "more,base"

dbx "UPDATE catfish_state SET yarn=200, meta='{\"extra\":2,\"ys\":0}' WHERE user_id=$UID_"
cfpost -d do=show2 >/dev/null; ok "Second show entry costs 5 Yarn: ys=5, show2on=1" "$(mget ys),$(mget show2on)" "5,1"
WK=$(dbv "SELECT json_extract(meta,'$.show.week') FROM catfish_state WHERE user_id=$UID_")
dbx "UPDATE catfish_state SET meta=json_set(meta,'$.show',json('{\"week\":\"$(php -r 'echo "2025-W".sprintf("%02d",7);')\",\"cat\":$CID2}')) WHERE user_id=$UID_"
pagew3; cfpost -d do=show -d slot=2 -d cat=$CID1 >/dev/null
SHW=$(php -d session.save_path=/tmp -r 'require "'$GAME'/includes/bootstrap.php"; require "'$GAME'/includes/catfish.php"; echo catfish_show_week();' 2>/dev/null)
dbx "UPDATE catfish_state SET meta=json_set(meta,'$.show',json('{\"week\":\"2025-W07\",\"cat\":$CID2,\"cat2\":$CID1}')) WHERE user_id=$UID_"
dbx "DELETE FROM cat_ribbons WHERE user_id=$UID_ AND week='2025-W07'"
S1=$(dbv "SELECT seed FROM cats WHERE id=$CID1"); S2=$(dbv "SELECT seed FROM cats WHERE id=$CID2")
pagew3
BEST=$(cfx none 'max(catfish_show_judge('$UID_', "2025-W07", catfish_cat('$S1'), catfish_show_theme("2025-W07"))["score"], catfish_show_judge('$UID_', "2025-W07", catfish_cat('$S2'), catfish_show_theme("2025-W07"))["score"])')
ok "two entries: the ribbon takes the better score of the two" "$(dbv "SELECT score FROM cat_ribbons WHERE user_id=$UID_ AND week='2025-W07'")" "$BEST"
dbx "DELETE FROM cat_ribbons WHERE user_id=$UID_ AND week='2025-W07'"
dbx "UPDATE catfish_state SET yarn=2, meta='{\"extra\":2,\"ys\":0}' WHERE user_id=$UID_"
cfpost -d do=show2 >/dev/null; ok "second entry with no Yarn: refused" "$(mget show2on)" 0
dbx "UPDATE catfish_state SET yarn=200, meta='{\"extra\":2,\"ys\":0}' WHERE user_id=$UID_"
cfpost -d do=show -d slot=2 -d cat=$CID2 >/dev/null; ok "second entry before unlocking: refused" "$(mget show.cat2)" 0

dbx "UPDATE catfish_state SET yarn=200, kibble=0, active_cat_id=$CID1, meta='{\"extra\":2,\"ys\":0}' WHERE user_id=$UID_"
KB=$(cfapi -d do=tick | jp view.kph)
cfpost -d do=buddy -d cat=$CID2 >/dev/null; ok "Buddy before unlocking: refused" "$(mget buddy)" 0
cfpost -d do=buddyunlock >/dev/null; ok "Buddy cat costs 12 Yarn: ys=12, buddyon=1" "$(mget ys),$(mget buddyon)" "12,1"
cfpost -d do=buddy -d cat=$CID1 >/dev/null; ok "the playing cat cannot be its own Buddy" "$(mget buddy)" 0
cfpost -d do=buddy -d cat=$CID2 >/dev/null; ok "Buddy chosen" "$(mget buddy)" "$CID2"
cfreset; KA=$(cfapi -d do=tick | jp view.kph)
ok "a Buddy adds 10% Kibble per hour (base $KB, with Buddy $KA)" "$(php -r 'echo abs('$KA' - round('$KB' * 1.1, 1)) < 0.2 ? "y" : "n";')" y
cfpost -d do=buddy -d cat=0 >/dev/null; cfreset; ok "no Buddy: the bonus is gone" "$(cfapi -d do=tick | jp view.kph)" "$KB"

dbx "UPDATE catfish_state SET yarn=200, meta='{\"extra\":2,\"ys\":0}' WHERE user_id=$UID_"
cfpost -d do=keep >/dev/null; cfpost -d do=keep >/dev/null; cfpost -d do=keep >/dev/null
ok "Keepsake costs 10, 20, 40: ys=70, level 3" "$(mget ys),$(mget keepsake)" "70,3"
cfpost -d do=keep >/dev/null; ok "Keepsake fourth level refused: ys stays 70" "$(mget ys)" 70
dbx "UPDATE catfish_state SET meta='{\"extra\":2,\"ys\":0,\"keepsake\":2}', upgrades='{\"fish\":50,\"rug\":4}', run_kibble=32000, kibble=500, last_tick=$(date +%s) WHERE user_id=$UID_"
cfpost -d do=nap >/dev/null
ok "a Nap with Keepsake 2 keeps 2 levels of the first upgrade in each branch and drops the rest" "$(dbv "SELECT upgrades FROM catfish_state WHERE user_id=$UID_")" '{"fish":2,"string":2,"sunbeam":2,"bowl":2}'

dbx "UPDATE catfish_state SET yarn=200, meta='{\"extra\":2,\"ys\":0}' WHERE user_id=$UID_"
cfpost -d do=ballbuy -d key=rose >/dev/null; ok "a yarn ball colour costs 1 Yarn and is in use" "$(mget ys),$(mget ball)" "1,rose"
pagew3; ok "the page carries the ball colour class" "$(grep -c 'class="cfpage cfball-rose"' $W/w3.html)" 1
cfpost -d do=ballset -d key=mint >/dev/null; ok "a colour you do not own cannot be switched on" "$(mget ball)" rose
cfpost -d do=ballbuy -d key=nonsense >/dev/null; ok "unknown ball colour refused: ys stays 1" "$(mget ys)" 1
cfpost -d do=ballset -d key= >/dev/null; ok "back to the plain ball for free" "$(mget ys),$(mget ball)" "1,0"

# 4f. Yarn scarf (12 Yarn, drawn on the gnome everywhere) and Yarn bunting (1 Yarn: +3 in the festival jar, 3 a day)
dbx "UPDATE catfish_state SET yarn=200, meta='{\"extra\":2,\"ys\":0}' WHERE user_id=$UID_"
cfpost -d do=scarfset -d key=blue >/dev/null; ok "scarf colour before buying: refused" "$(mget scarf)" 0
cfpost -d do=scarfbuy >/dev/null; ok "the scarf costs 12 Yarn: ys=12, red to start" "$(mget ys),$(mget scarf)" "12,red"
PRF=$(curl -s -b $W/p "$BASE/profile.php?id=$UID_"); ok "the gnome wears the scarf on the profile" "$([ "$(echo "$PRF" | grep -c 'data-part="scarf"')" -ge 1 ] && echo y || echo n)" y
cfpost -d do=scarfset -d key=blue >/dev/null; PRF=$(curl -s -b $W/p "$BASE/profile.php?id=$UID_"); ok "scarf colour: blue" "$(mget scarf),$([ "$(echo "$PRF" | grep -c '#2f5d9e\|tint-2f5d9e')" -ge 1 ] && echo y || echo n)" "blue,y"
cfpost -d do=scarfset -d key=nonsense >/dev/null; ok "unknown scarf colour refused: still blue" "$(mget scarf)" blue
cfpost -d do=scarfset -d key= >/dev/null; PRF=$(curl -s -b $W/p "$BASE/profile.php?id=$UID_"); ok "scarf off: gone from the profile" "$(echo "$PRF" | grep -c 'data-part="scarf"')" 0
cfpost -d do=bunting >/dev/null; ok "bunting with no festival: refused, no Yarn spent" "$(mget ys)" 12
setg festivals_on 1; setg fest_opening_day_start "$TD"; setg fest_opening_day_end "$TM"
curl -s -b $W/p $BASE/festival.php >/dev/null   # the page makes the jar
for i in 1 2 3 4; do cfpost -d do=bunting >/dev/null; done
ok "bunting: 1 Yarn each, three a day (ys 12 + 3)" "$(mget ys)" 15
ok "bunting: +3 each in the festival jar (9)" "$(dbv "SELECT amount FROM hollow_goal_contrib WHERE user_id=$UID_ AND goal_id=(SELECT id FROM hollow_goals WHERE festival='opening_day')")" 9
dbx "UPDATE catfish_state SET yarn=12, meta='{\"extra\":2,\"ys\":12}' WHERE user_id=$UID_"
cfpost -d do=bunting >/dev/null; ok "bunting with no Yarn left: refused, no jar points" "$(dbv "SELECT amount FROM hollow_goal_contrib WHERE user_id=$UID_ AND goal_id=(SELECT id FROM hollow_goals WHERE festival='opening_day')")" 9
setg festivals_on 0

# 4g. Rod Tune-up, Catnip Hour, Mood Treat, Cat bio, Collar tint, Seasonal room
dbx "UPDATE catfish_state SET yarn=200, active_cat_id=$CID1, naps=3, upgrades='{\"string\":8}', meta='{\"extra\":2,\"ys\":0}' WHERE user_id=$UID_"
cfreset; ok "no tune-up yet: 8 Longer string levels have no milestone double" "$(cfapi -d do=tick | jp view.ups.4.mult)" 1
cfpost -d do=tune -d branch=rod >/dev/null
ok "Rod Tune-up costs 4 Yarn: ys=4, rod, this run" "$(mget ys),$(mget tune.branch),$(mget tune.naps)" "4,rod,3"
cfreset; ok "tuned: 8 Longer string levels double" "$(cfapi -d do=tick | jp view.ups.4.mult)" 2
cfpost -d do=tune -d branch=fish >/dev/null; ok "a second tune-up in the same run is refused: ys stays 4" "$(mget ys)" 4
cfpost -d do=tune -d branch=nonsense >/dev/null; ok "tune-up with an unknown branch refused: ys stays 4" "$(mget ys)" 4
dbx "UPDATE catfish_state SET naps=4 WHERE user_id=$UID_"
cfreset; ok "after the next Nap the tune-up is over" "$(cfapi -d do=tick | jp view.ups.4.mult)" 1
ok "tuned kph is higher than untuned kph for the same levels" "$(cfx none 'catfish_kph(["string" => 8], ["tune" => "rod"], true) > catfish_kph(["string" => 8], [], true) ? "y" : "n"')" y
cfpost -d do=tune -d branch=fish >/dev/null; ok "a new run can be tuned again: ys=8" "$(mget ys)" 8

dbx "UPDATE catfish_state SET yarn=200, upgrades='{\"fish\":50}', meta='{\"extra\":2,\"ys\":0}' WHERE user_id=$UID_"
cfreset; V0=$(cfapi -d do=tick | jp view.play.v)
cfpost -d do=catnip >/dev/null; ok "Catnip Hour costs 1 Yarn: ys=1" "$(mget ys)" 1
cfreset; V1=$(cfapi -d do=tick | jp view.play.v)
ok "Catnip Hour: a tap pays double (plain $V0, catnip $V1)" "$([ "$V1" -eq $((V0 * 2)) ] && echo y || echo n)" y
cfpost -d do=catnip >/dev/null; ok "a second Catnip Hour the same day is refused" "$(mget ys)" 1
dbx "UPDATE catfish_state SET meta=json_set(meta,'$.catnip.until',$(( $(date +%s) - 5 ))) WHERE user_id=$UID_"
cfreset; ok "when the hour is up, taps pay the plain value again" "$(cfapi -d do=tick | jp view.play.v)" "$V0"

dbx "UPDATE catfish_state SET yarn=200, upgrades='{\"fish\":50}', meta='{\"extra\":2,\"ys\":0}' WHERE user_id=$UID_"
cfreset; MOOD=$(cfapi -d do=tick | jp view.cat.mood); KB2=$(cfapi -d do=tick | jp view.kph)
case $MOOD in greedy) PICK=hyper;; *) PICK=greedy;; esac
cfpost -d do=treat -d mood=dreamy >/dev/null; ok "Mood Treat with Dreamy refused: ys stays 0" "$(mget ys)" 0
cfpost -d do=treat -d mood=$MOOD >/dev/null; ok "Mood Treat with the cat's own mood refused: ys stays 0" "$(mget ys)" 0
cfpost -d do=treat -d mood=$PICK >/dev/null; ok "Mood Treat costs 2 Yarn: ys=2, second mood $PICK" "$(mget ys),$(mget treat.mood)" "2,$PICK"
cfreset; KA2=$(cfapi -d do=tick | jp view.kph)
if [ "$MOOD" = lazy ] || [ "$MOOD" = sneaky ] || [ "$MOOD" = dreamy ] || [ "$MOOD" = greedy ] || [ "$MOOD" = hyper ]; then ok "a second greedy or hyper mood raises Kibble per hour (before $KB2, after $KA2)" "$(php -r 'echo '$KA2' > '$KB2' ? "y" : "n";')" y; fi
cfpost -d do=treat -d mood=lazy >/dev/null; ok "one Mood Treat a day: ys stays 2" "$(mget ys)" 2

dbx "UPDATE catfish_state SET yarn=200, meta='{\"extra\":2,\"ys\":0}' WHERE user_id=$UID_"; dbx "UPDATE cats SET bio='', collar='' WHERE user_id=$UID_"
cfpost -d do=bio -d cat=$CID1 --data-urlencode "bio=Loves boxes" >/dev/null
ok "first bio costs 1 Yarn: ys=1, saved" "$(mget ys),$(dbv "SELECT bio FROM cats WHERE id=$CID1")" "1,Loves boxes"
cfpost -d do=bio -d cat=$CID1 --data-urlencode "bio=Hates Mondays" >/dev/null
ok "changing a bio is free: ys stays 1" "$(mget ys),$(dbv "SELECT bio FROM cats WHERE id=$CID1")" "1,Hates Mondays"
cfpost -d do=bio -d cat=$CID1 --data-urlencode "bio=<b>Tiny</b> & $(printf 'x%.0s' $(seq 1 80))" >/dev/null
ok "a bio is cleaned and cut to 60 characters" "$(dbv "SELECT LENGTH(bio) FROM cats WHERE id=$CID1")$(dbv "SELECT bio LIKE '%<%' FROM cats WHERE id=$CID1")" "600"
cfpost -d do=bio -d cat=999999 --data-urlencode "bio=Not mine" >/dev/null; ok "a bio for a cat that is not yours is refused: ys stays 1" "$(mget ys)" 1
cfpost -d do=bio -d cat=$CID2 --data-urlencode "bio=Sleepy" >/dev/null; ok "the second cat's first bio costs 1 more: ys=2" "$(mget ys)" 2
pagew3; cfpost -d do=bio -d cat=$CID1 --data-urlencode "bio=Loves boxes" >/dev/null; pagew3; ok "the bio shows on the page" "$([ "$(grep -c 'Loves boxes' $W/w3.html)" -ge 1 ] && echo y || echo n)" y

dbx "UPDATE catfish_state SET yarn=200, meta='{\"extra\":2,\"ys\":0}' WHERE user_id=$UID_"
cfpost -d do=collar -d cat=$CID1 -d key=rose >/dev/null
ok "a collar costs 2 Yarn for that cat: ys=2, worn" "$(mget ys),$(dbv "SELECT collar FROM cats WHERE id=$CID1")" "2,rose"
pagew3; ok "the collar class is on the page" "$([ "$(grep -c 'cfcol-rose\|cf-collar-rose-idleA.png' $W/w3.html)" -ge 1 ] && echo y || echo n)" y
cfpost -d do=collar -d cat=$CID1 -d key= >/dev/null; ok "collar off is free" "$(mget ys),$(dbv "SELECT collar FROM cats WHERE id=$CID1")" "2,"
cfpost -d do=collar -d cat=$CID1 -d key=rose >/dev/null; ok "wearing an owned collar again is free: ys stays 2" "$(mget ys),$(dbv "SELECT collar FROM cats WHERE id=$CID1")" "2,rose"
cfpost -d do=collar -d cat=$CID1 -d key=gold >/dev/null; ok "a second colour costs 2 more: ys=4" "$(mget ys)" 4
cfpost -d do=collar -d cat=$CID2 -d key=rose >/dev/null; ok "the same colour on another cat costs again: ys=6" "$(mget ys)" 6
cfpost -d do=collar -d cat=$CID1 -d key=plaid >/dev/null; ok "unknown collar colour refused: ys stays 6" "$(mget ys)" 6

dbx "UPDATE catfish_state SET yarn=200, meta='{\"extra\":2,\"ys\":0}' WHERE user_id=$UID_"
cfpost -d do=season -d code=wi >/dev/null; ok "a season costs 3 Yarn: ys=3, owned" "$(mget ys),$(mget seasons.0)" "3,wi"
cfpost -d do=season -d code=wi >/dev/null; ok "the same season twice refused: ys stays 3" "$(mget ys)" 3
cfpost -d do=season -d code=xx >/dev/null; ok "unknown season refused: ys stays 3" "$(mget ys)" 3
dbx "UPDATE cats SET bio='', collar='' WHERE user_id=$UID_"
dbx "UPDATE users SET title=NULLIF('$TITLE0','') WHERE id=$UID_"
dbx "UPDATE catfish_state SET yarn=${CF0%%|*}, meta='$(echo "$CF0" | cut -d'|' -f2)', upgrades='$(echo "$CF0" | cut -d'|' -f3)' WHERE user_id=$UID_"

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
ok "profile: ribbon shelf shows the tier with its count and the latest cat name" "$(echo "$PR" | grep -cF "$RL ×1")$(echo "$PR" | grep -cF "Latest: $NAME")" 11
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

# ---------- 2.1.04 active play: tap a dangling fish, a little extra Kibble, validated on the server (catfish_play) ----------
# One accepted tap pays max(1, floor(present kph x 5 / 3600 x tier)); tiers by Hollow day: taps 1-120 x1, 121-240 x0.5, 241-360 x0.25, then 0.
# Token bucket: 15 tokens, +1 per 2 s, accepted = min(n, whole tokens, taps left today); n must be an integer 0..40 (more = the whole batch refused); a repeated or lower seq pays 0.
setg catfish_open 1; setg ppal_open 0; setg festivals_on 0
TODAY=$(php -r 'function is_admin(){return false;} function setting($n){return "";} function hollow_date($f,$t=null){return (new DateTimeImmutable("@".($t??time())))->setTimezone(new DateTimeZone("America/Halifax"))->format($f);} require $argv[1]; echo catfish_today();' "$GAME/includes/catfish.php")
dbx "UPDATE catfish_state SET active_cat_id=(SELECT id FROM cats WHERE user_id=$UID_ ORDER BY id LIMIT 1) WHERE user_id=$UID_ AND active_cat_id IS NULL"
# pbase [UPGRADES-JSON]: no Yarn, no Kibble, upgrades as given (none by default), the idle clock at now
pbase() { local up="${1:-{\}}"; dbx "UPDATE catfish_state SET upgrades='$up', yarn=0, kibble=0, run_kibble=0, total_kibble=0, last_tick=$(date +%s) WHERE user_id=$UID_"; }
# pset PC PB AGE PQ: today's taps, tokens in the bucket, seconds since the bucket was last touched, last batch id (lifetime taps cleared)
pset() { mset '$m["pd"]="'$TODAY'"; $m["pc"]='$1'; $m["pb"]='$2'; $m["pt"]='$(( $(date +%s) - $3 ))'; $m["pq"]='$4'; unset($m["pe"]);'; }
cplay() { cfapi -d do=tick -d play="$1" -d seq="$2"; }
pm() { mjson | jp "$1"; }
KT() { dbv "SELECT kibble||'/'||run_kibble||'/'||total_kibble FROM catfish_state WHERE user_id=$UID_"; }
cfreset; pbase; pset 0 15 0 0; mset '$m["keep"]=7;'
R=$(cfapi -d do=tick)
ok "play view: a plain tick pays no play (got 0, paid 0, left 360, ever 0)" "$(echo "$R" | jp view.play.got)/$(echo "$R" | jp view.play.paid)/$(echo "$R" | jp view.play.left)/$(echo "$R" | jp view.play.ever)" "0/0/360/0"
ok "play view: at base income one tap is worth 1 Kibble (max(1, floor(kph x 5 / 3600)))" "$(echo "$R" | jp view.play.v)" 1
ok "play: a plain tick leaves the batch id alone" "$(pm pq)" 0
# n = 15 after 30 s of quiet: fully accepted, 1 Kibble each, into kibble, run_kibble and total_kibble
pbase; pset 0 0 30 0
R=$(cplay 15 100)
ok "play: 15 taps after 30 s are all accepted (bucket refilled to 15)" "$(echo "$R" | jp view.play.got)" 15
ok "play: 15 taps at tier 1 and base income pay 15" "$(echo "$R" | jp view.play.paid)" 15
ok "play: the Kibble lands in kibble, run_kibble and total_kibble together" "$(KT)" "15/15/15"
ok "play: left 345 and ever 15 afterwards; meta pc 15, pe 15, pq 100" "$(echo "$R" | jp view.play.left)/$(echo "$R" | jp view.play.ever)/$(pm pc)/$(pm pe)/$(pm pq)" "345/15/15/15/100"
ok "play: other meta keys survive" "$(pm keep)" 7
# the cap: 40 taps with a full bucket pay 15; more than 40 in one batch pays nothing; bad counts pay nothing
pbase; pset 0 15 0 0
ok "play: n=40 with a full bucket is capped at 15" "$(cplay 40 200 | jp view.play.got)" 15
pbase; pset 0 15 0 0
R=$(cplay 100 300)
ok "play: n=100 (over 40) accepts 0 and pays 0" "$(echo "$R" | jp view.play.got)/$(echo "$R" | jp view.play.paid)/$(KT)" "0/0/0/0/0"
for bad in -5 abc 3.5 1e3 ''; do pbase; pset 0 15 0 0; ok "play: n='$bad' pays 0" "$(cplay "$bad" 301 | jp view.play.got)$(KT)" "00/0/0"; done
pbase; pset 0 15 0 0
ok "play: n as an array pays 0, no error" "$(cfapi -d do=tick --data-urlencode 'play[]=5' -d seq=302 | jp view.play.got)" 0
ok "play: n=0 is an accepted empty batch" "$(cplay 0 303 | jp ok)" true
# seq: a replay pays nothing (safe retries), so does a lower one; a higher one pays
pbase; pset 0 15 0 500
ok "play: seq above the last batch pays" "$(cplay 3 501 | jp view.play.got)" 3
ok "play: the same seq again pays 0 (a retry of a lost reply)" "$(cplay 3 501 | jp view.play.got)" 0
ok "play: a lower seq pays 0" "$(cplay 3 400 | jp view.play.got)" 0
ok "play: a missing seq pays 0" "$(cfapi -d do=tick -d play=3 | jp view.play.got)" 0
ok "play: after the replays the Kibble is still just the 3 taps" "$(KT)" "3/3/3"
ok "play: the next seq pays again" "$(cplay 4 502 | jp view.play.got)" 4
# tiers by Hollow day
cfreset; pbase '{"fish":50}'; pset 119 15 0 0
KP=$(cfapi -d do=tick | jp view.kph)
V1=$(awk "BEGIN{v=int($KP*5/3600); print (v<1)?1:v}"); VH=$(awk "BEGIN{v=int($KP*5/3600*0.5); print (v<1)?1:v}"); VQ=$(awk "BEGIN{v=int($KP*5/3600*0.25); print (v<1)?1:v}")
ok "tier: with 50 Plushie fish a tap is worth more than 1, and the tiers differ" "$([ "$V1" -gt "$VH" ] && [ "$VH" -gt "$VQ" ] && [ "$VQ" -gt 1 ] && echo y || echo n)" y
R=$(cplay 5 600)
ok "tier: pc=119 plus 5 taps = 1 at full pay and 4 at half" "$(echo "$R" | jp view.play.got)/$(echo "$R" | jp view.play.paid)/$(pm pc)" "5/$(( V1 + 4 * VH ))/124"
pbase '{"fish":50}'; pset 239 15 0 0
ok "tier: pc=239 plus 2 taps = 1 half and 1 quarter" "$(cplay 2 601 | jp view.play.paid)" "$(( VH + VQ ))"
pbase '{"fish":50}'; pset 359 15 0 0
R=$(cplay 3 602)
ok "tier: pc=359 plus 3 taps: only the 360th is accepted, at a quarter; none left, next tap worth 0" "$(echo "$R" | jp view.play.got)/$(echo "$R" | jp view.play.paid)/$(pm pc)/$(echo "$R" | jp view.play.left)/$(echo "$R" | jp view.play.v)" "1/$VQ/360/0/0"
R=$(cplay 3 603)
ok "tier: after 360 taps nothing more is accepted or paid" "$(echo "$R" | jp view.play.got)/$(echo "$R" | jp view.play.paid)/$(pm pc)" "0/0/360"
ok "tier: a full day (120 full + 120 half + 120 quarter) is at most 17.5 minutes of income (+1 per tap rounding)" "$(awk "BEGIN{m=120*$V1+120*$VH+120*$VQ; print (m <= $KP*17.5/60 + 360) ? \"y\" : \"n\"}")" y
# Hollow day rollover: a new day starts the count again
pbase; pset 300 15 0 0; mset '$m["pd"]="2000-01-01";'
R=$(cplay 2 700)
ok "day rollover: an old day's count (300) is dropped: 2 accepted, pc=2, pd=today, 358 left" "$(echo "$R" | jp view.play.got)/$(pm pc)/$(pm pd)/$(echo "$R" | jp view.play.left)" "2/2/$TODAY/358"
# tokens never pile up past the cap, however long the gnome was away
pbase; pset 0 0 3600 0
ok "bucket: an hour idle still gives 15 tokens, not 1800 (n=40 -> 15)" "$(cplay 40 800 | jp view.play.got)" 15
pbase; pset 0 0 3600 0
cplay 1 801 >/dev/null
ok "bucket: after 1 tap an hour-idle bucket holds at most 14 tokens (never above 15)" "$(php -r '$m=json_decode($argv[1],true); echo ($m["pb"] <= 14.001 && $m["pb"] > 13) ? "y" : "n";' "$(mjson)")" y
pbase; pset 0 0 4 0
ok "bucket: an empty bucket after 4 s holds 2 tokens (1 per 2 s)" "$(cplay 10 802 | jp view.play.got)" 2
# no cat: nothing paid
pbase; pset 0 15 0 0; dbx "UPDATE catfish_state SET active_cat_id=NULL WHERE user_id=$UID_"
R=$(cplay 5 900)
ok "no cat yet: play accepts 0 and pays 0" "$(echo "$R" | jp view.play.got)/$(echo "$R" | jp view.play.paid)/$(KT)" "0/0/0/0/0"
dbx "UPDATE catfish_state SET active_cat_id=(SELECT id FROM cats WHERE user_id=$UID_ ORDER BY id LIMIT 1) WHERE user_id=$UID_"
# guard rails: no CSRF, guests
ok "play without csrf: 400" "$(curl -s -b $W/p -o /dev/null -w '%{http_code}' -X POST $BASE/catfish_api.php -d do=tick -d play=5 -d seq=1000)" 400
setg guest_open 1; dbx "DELETE FROM login_attempts"
curl -s -c $W/g -b $W/g $BASE/guest.php > $W/gp.html; curl -s -c $W/g -b $W/g -o /dev/null -X POST $BASE/guest.php --data-urlencode "csrf=$(csrf $W/gp.html)"
curl -s -b $W/g $BASE/games.php > $W/gp.html
ok "play as a guest: 403" "$(curl -s -b $W/g -o /dev/null -w '%{http_code}' -X POST $BASE/catfish_api.php --data-urlencode "csrf=$(csrf $W/gp.html)" -d do=tick -d play=5 -d seq=1000)" 403
setg guest_open 0; cfreset
# a Nap resets the run and base income comes back: a tap is worth the base 1 again (no Yarn exploit)
pbase '{"fish":50}'; pset 0 15 0 0; dbx "UPDATE catfish_state SET run_kibble=32000, kibble=500 WHERE user_id=$UID_"
VB=$(cfapi -d do=tick | jp view.play.v)
cfpost -d do=nap >/dev/null
VA=$(cfapi -d do=tick | jp view.play.v)
ok "nap: a tap was worth more than 1 before (50 Plushie fish) and is back to the base value after" "$([ "$VB" -gt 1 ] && echo y || echo n)/$(echo $VA | cut -c1-3)" "y/1"
# two requests at once never pay the same tokens twice (the lock): 15 tokens, three batches of 15 -> 15 accepted in all.
# php -S is one process by default; a second server on the same files with workers makes the requests really overlap.
cfreset
PW=$((PORT + 1)); PHP_CLI_SERVER_WORKERS=4 php -d session.save_path=/tmp -S 127.0.0.1:$PW -t $GAME $ROUTER >/tmp/catfish-php2.log 2>&1 & PID2=$!; sleep 1
cfapi2() { curl -s -b $W/p -X POST http://127.0.0.1:$PW/catfish_api.php --data-urlencode "csrf=$CS" "$@"; }
cfapi2 -d do=tick >/dev/null
pbase; pset 0 15 0 0
( cfapi2 -d do=tick -d play=15 -d seq=1100 -o $W/par1 & cfapi2 -d do=tick -d play=15 -d seq=1101 -o $W/par2 & cfapi2 -d do=tick -d play=15 -d seq=1102 -o $W/par3 & wait ) >/dev/null 2>&1
kill $PID2 2>/dev/null
ok "parallel: three overlapping batches of 15 on a full bucket accept 15 in all (pc=15, Kibble 15)" "$(pm pc)/$(KT | cut -d/ -f3)" "15/15"
cfreset

# 2.1.07 buy: do=buy takes play and seq like a tick and pays the taps BEFORE the cost check, in one lock (catfish_play unchanged: a replayed seq pays 0, the bucket and the daily cap hold)
cfreset; pbase; pset 0 15 0 100; dbx "UPDATE catfish_state SET kibble=140 WHERE user_id=$UID_"
R=$(cfapi -d do=buy -d key=silk)
ok "2.1.07 buy: 140 Kibble, silk costs 150, no taps sent: refused with the reason, Kibble unchanged, nothing owned" "$(echo "$R" | jp ok)/$(echo "$R" | jp message)/$(echo "$R" | jp view.kibble)/$(KT | cut -d/ -f1)/$(dbv "SELECT upgrades FROM catfish_state WHERE user_id=$UID_")" "false/Not enough Kibble./140/140/{}"
ok "2.1.07 buy: the refusal still answers with the view (rows, rate, run) and a scene key" "$(echo "$R" | jp view.ups.0.key)/$(echo "$R" | jp scene | wc -c | tr -d ' ')" "fish/12"
R=$(cfapi -d do=buy -d key=silk -d play=15 -d seq=2000); PAID=$(echo "$R" | jp view.play.paid)
ok "2.1.07 buy: the same 140 Kibble plus 15 pending taps: the taps are paid first, so the buy goes through" "$(echo "$R" | jp ok)/$(echo "$R" | jp view.play.got)/$([ "$PAID" -ge 10 ] && echo y)" "true/15/y"
ok "2.1.07 buy: Kibble = 140 + paid taps - cost (150), the run counts the taps, silk is level 1" "$(echo "$R" | jp view.kibble)/$(KT | cut -d/ -f2)/$(dbv "SELECT upgrades FROM catfish_state WHERE user_id=$UID_")" "$((140 + PAID - 150))/$PAID/{\"silk\":1}"
dbx "UPDATE catfish_state SET kibble=900 WHERE user_id=$UID_"
R=$(cfapi -d do=buy -d key=silk -d play=15 -d seq=2000)
ok "2.1.07 buy: a replayed seq pays 0 taps (the buy itself still works)" "$(echo "$R" | jp ok)/$(echo "$R" | jp view.play.got)/$(echo "$R" | jp view.play.paid)/$(echo "$R" | jp view.kibble | awk '{print ($1<900)?"spent":"no"}')" "true/0/0/spent"
pset 0 2 0 2100; dbx "UPDATE catfish_state SET kibble=900 WHERE user_id=$UID_"
R=$(cfapi -d do=buy -d key=catnip -d play=15 -d seq=2200)
ok "2.1.07 buy: the token bucket holds (2 tokens, 15 taps sent: 2 accepted)" "$(echo "$R" | jp view.play.got)" 2
pset 0 15 0 2300; dbx "UPDATE catfish_state SET kibble=900 WHERE user_id=$UID_"
R=$(cfapi -d do=buy -d key=fish -d play=ten -d seq=2400)
ok "2.1.07 buy: a bad play count pays 0 and the buy still decides on the Kibble it has" "$(echo "$R" | jp ok)/$(echo "$R" | jp view.play.got)" "true/0"
pset 0 15 0 2500; dbx "UPDATE catfish_state SET kibble=5 WHERE user_id=$UID_"
R=$(cfapi -d do=buy -d key=nosuchthing -d play=3 -d seq=2600)
ok "2.1.07 buy: unknown upgrade is refused, the taps sent with it are still paid once (3 accepted), message names the problem" "$(echo "$R" | jp ok)/$(echo "$R" | jp message)/$(echo "$R" | jp view.play.got)" "false/No such upgrade./3"
ok "2.1.07 buy: no csrf is still 400, a GET is 405" "$(curl -s -b $W/p -o /dev/null -w '%{http_code}' -X POST $BASE/catfish_api.php -d do=buy -d key=silk -d play=3 -d seq=1)/$(curl -s -b $W/p -o /dev/null -w '%{http_code}' "$BASE/catfish_api.php?do=buy")" "400/405"
ok "2.1.07 buy: the plain form post (no JS) still buys and redirects" "$(dbx "UPDATE catfish_state SET kibble=9000 WHERE user_id=$UID_"; cfpost -d do=buy -d key=sunbeam)/$(dbv "SELECT upgrades FROM catfish_state WHERE user_id=$UID_" | grep -c sunbeam)" "302/1"
cfreset

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
ok "Buy x10 price is the sum of ten single prices (give or take a second of income)" "$(php -r 'echo abs('$SPENT10' - '$(cfx none 'catfish_cost_n("fish", 0, 10)')') <= 3 ? "y" : "n";')" y
ok "offline cap: 8 hours, +1 per Longer naps away level, Lazy x1.25 on top" "$(cfx none 'catfish_offline_cap(null) . "," . catfish_offline_cap(null, 3) . "," . catfish_offline_cap(["mood" => "lazy"], 3)')" "28800,39600,49500"
ok "art coat map: all 8 coats have art, lilac included" "$(cfx none 'count(CATFISH_ART_COATS) . " " . CATFISH_ART_COATS["lilac"]')" "8 lilac"
# play scene (catfish_stage_html): one centred stage with the room stack, wand, three fish, the other cats as still frames and the active cat with all 8 frame groups
SC='[["id"=>1,"name"=>"Pip","colour"=>"ginger","pattern"=>"tabby","eyes"=>"amber","ears"=>"folded","tail"=>"bobtail","seed"=>11,"mood"=>"hyper"],["id"=>2,"name"=>"Dot","colour"=>"lilac","pattern"=>"solid","eyes"=>"odd","ears"=>"upright","tail"=>"long","seed"=>2,"mood"=>"hyper"],["id"=>3,"name"=>"Zed","colour"=>"black","pattern"=>"calico","eyes"=>"blue","ears"=>"upright","tail"=>"long","seed"=>3,"mood"=>"lazy"],["id"=>4,"name"=>"Moe","colour"=>"white","pattern"=>"spotted","eyes"=>"green","ears"=>"folded","tail"=>"long","seed"=>4,"mood"=>"dreamy"],["id"=>5,"name"=>"Fig","colour"=>"brown","pattern"=>"tuxedo","eyes"=>"hazel","ears"=>"upright","tail"=>"bobtail","seed"=>5,"mood"=>"greedy"]]'
ok "stage, no art: nothing (the page keeps the old rod box)" "$(cfx none "catfish_stage_html($SC, $SC[0], [\"rug\"=>1])")" ""
SH=$(cfx $FULL "catfish_stage_html($SC, $SC[0], [\"sunbeam\"=>1, \"rug\"=>1, \"silk\"=>1])")
ok "stage: one stage in a wrapper, room base then owned overlays only, the yarn patch (2.1.06), wand, then the fish" "$(echo "$SH" | grep -o 'class="cfstage"\|cf-room[a-z-]*.png\|cf-rod.png\|cf-fish-[0-9].png' | tr '\n' ' ')" 'class="cfstage" cf-room.png cf-room-sunbeam.png cf-room-rug.png cf-room-yarnpatch.png cf-rod.png cf-fish-1.png cf-fish-2.png cf-fish-1.png '
ok "stage: three dangling fish (sd1..sd3), each with a string, and the line from the wand" "$(echo "$SH" | grep -o 'cfsdrop sd[0-9]\|class="cfstr"\|class="cfsline"' | tr '\n' ' ')" 'class="cfsline" cfsdrop sd1 class="cfstr" cfsdrop sd2 class="cfstr" cfsdrop sd3 class="cfstr" '
ok "stage: the active cat is in the centre play zone with all 8 frame groups, starting on idleA" "$(echo "$SH" | grep -o 'class="cfactive cfpos-x128-y120 fr-idleA" data-frame="idleA"')$(echo "$SH" | sed 's/.*class="cfactive/class="cfactive/' | grep -o 'class="cfframe ff-[A-Za-z]*"' | sed 's/.*ff-//;s/"//' | tr '\n' ' ')" 'class="cfactive cfpos-x128-y120 fr-idleA" data-frame="idleA"idleA idleB wiggle stalk pounce catch nap bored '
AH=$(echo "$SH" | sed 's/.*class="cfactive/class="cfactive/;s#<script[^<]*</script>##')
ok "stage: every frame group of the folded bobtail tabby cat has body, pattern, ears, tail and eyes" "$(for f in idleA idleB wiggle stalk pounce catch nap bored; do echo "$AH" | grep -o "cf-cat-orange-$f.png\|cf-pat-tabby-orange-$f.png\|cf-ears-folded-orange-$f.png\|cf-tail-bobtail-orange-$f.png\|cf-eyes-amber-$f.png" | wc -l | tr -d ' '; done | tr '\n' ' ')" "5 5 5 5 5 5 5 5 "
ok "stage: three other cats at the side spots (a lazy cat first on the cushion as nap), frames nap, idleA, bored" "$(echo "$SH" | grep -o 'cfspot \(cfside \)\?cfpos-x[0-9]*-y[0-9]*[^>]*>\(<span class="cfframe ff-idleA" data-f="idleA">\)\?<span class="cfart cf-s64" aria-hidden="true">\(<span class="cfmk[^>]*>\)*<img src="[^"]*cf-cat-[a-z-]*-[A-Za-z]*\.png' | sed 's/cfspot \(cfside \)\?cfpos-//;s/[" ].*cf-cat-/ /;s/\.png//' | tr '\n' ',')" "x40-y98 lilac-idleA,x236-y116 white-bored,x0-y124 black-nap,"
SH2=$(cfx $FULL "catfish_stage_html(array_slice($SC, 0, 2), $SC[0], [])")
ok "stage: two cats = the active one and one at the cushion (nap frame)" "$(echo "$SH2" | grep -c 'cfpos-x0-y124')$(echo "$SH2" | grep -c 'cfpos-x40-y98')$(echo "$SH2" | grep -c 'cfpos-x236-y116')" "100"
SH3=$(cfx $FULL "catfish_stage_html([$SC[0]], $SC[0], [], true)")
ok "stage: a lone cat has no side spots; a napping one starts on the nap frame (data-nap)" "$(echo "$SH3" | grep -c 'cfspot')$(echo "$SH3" | grep -c 'fr-nap" data-frame="nap" data-seed="11" data-nap="1"')" "01"
ok "stage: no inline style, no script (besides the one JSON manifest block), no event handler; every img has an empty alt except none" "$(echo "$SH" | sed 's#<script type="application/json" id="cf-frames">[^<]*</script>##' | grep -c 'style=\|<script\|on[a-z]*=')$(echo "$SH" | grep -o '<script' | wc -l | tr -d ' ')" 01
# 2.1.04 markup: each fish is a button (a group, not an image, holds buttons), the pop, combo, hint and live line are plain classed elements
ok "stage play: each fish is a type=button with its cfsdrop/sdI/cfk-N classes, data-fish and an aria-label 'Bat the plush fish (I of 3)'" "$(echo "$SH" | grep -o '<button type="button" class="cfsdrop sd[1-3] cfk-[1-5]" data-fish="[1-3]" aria-label="Bat the plush fish ([1-3] of 3)">' | sed 's/.*sd\([1-3]\) cfk-\([1-5]\)" data-fish="\([1-3]\)" aria-label="Bat the plush fish (\([1-3]\) of 3)">/\1\2\3\4/' | tr '\n' ' ')" "1111 2222 3133 "
ok "stage play: three buttons close again, no span left for a fish" "$(echo "$SH" | grep -o '</button>' | wc -l | tr -d ' ')$(echo "$SH" | grep -c '<span class="cfsdrop')" "30"
ok "stage play: the stage is role=group with the same aria-label (not role=img), data-play-pending and data-combo for tests" "$(echo "$SH" | grep -c 'class="cfstage" role="group" aria-label="Pip plays under the toy rod at home, with 4 other cats" data-play-pending="0" data-combo="0"')$(echo "$SH" | grep -c 'role="img" aria-label="Pip')" "10"
ok "stage play: three pops p1..p3, the combo counter and a polite live line, all by class or id only" "$(echo "$SH" | grep -o 'cfpop p[1-3]"\|id="cf-combo"\|id="cf-playlive" class="cfsr" aria-live="polite"' | tr '\n' ' ')" 'cfpop p1" cfpop p2" cfpop p3" id="cf-combo" id="cf-playlive" class="cfsr" aria-live="polite" '
ok "stage play: no hint bubble by default; stage_html(..., hint) adds 'Tap a fish to play!'" "$(echo "$SH" | grep -c 'cfhint')$(cfx $FULL "catfish_stage_html($SC, $SC[0], [], false, true)" | grep -o 'class="cfhint" id="cf-hint" aria-hidden="true">Tap a fish to play!<' | wc -l | tr -d ' ')" "01"
ok "css play: button reset, focus ring, hit area, cfbounce, is-caught flip and a reduced-motion rule for .is-hit" "$(grep -c '^\.cfstage \.cfsdrop { display: block; padding: 0; margin: 0; border: 0; background: none;' $GAME/assets/catfish.css)$(grep -c '^\.cfsdrop:focus-visible { outline: 2px solid #fff; outline-offset: 1px; }' $GAME/assets/catfish.css)$(grep -c '@keyframes cfbounce' $GAME/assets/catfish.css)$(grep -c 'cursor: pointer' $GAME/assets/catfish.css)$(grep -c '\.cfsdrop\.is-caught \.cfimg { animation: cfflip 240ms' $GAME/assets/catfish.css)$(sed -n '/prefers-reduced-motion: reduce) {$/,/^}/p' $GAME/assets/catfish.css | grep -c 'is-hit')" "111212"
ok "js play: untrusted events ignored, 600 ms per-fish cooldown, pending capped at 40, sendBeacon on pagehide, cftap drives the animation, reaction at most every 700 ms" "$(grep -c 'isTrusted' $GAME/assets/catfish.js)$(grep -c 'now - cool\[f\] < 600' $GAME/assets/catfish.js)$(grep -c 'pending < 40' $GAME/assets/catfish.js)$(grep -c "addEventListener('pagehide'" $GAME/assets/catfish.js)$(grep -c 'navigator.sendBeacon(d.api' $GAME/assets/catfish.js)$(grep -c "now - lastReact < 700" $GAME/assets/catfish.js)" "211111"
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
drops = re.findall(r'<button type="button" class="cfsdrop sd(\d) cfk-(\d)" data-fish="\d" aria-label="[^"]*"><i class="cfstr"></i><img[^>]*cf-fish-(\d)\.png[^>]*></button>', html)
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

# ---------- 2.1.05 animation art: alias frames, manifest, new frames, css, js ----------
# the PHP alias map mirrors the art notes (frames-alias-s2.json, frames-alias-s3.json) and the frame lists cover every frame the art notes name
python3 -I - "aseprite-source/catfish" "$(php -r 'function is_admin(){return false;} function setting($n){return "";} function hollow_date($f,$t=null){return "";} require $argv[1]; echo json_encode(["base"=>CATFISH_FRAME_BASE,"own"=>CATFISH_FRAME_OWN,"frames"=>CATFISH_FRAMES,"extra"=>CATFISH_FRAMES_EXTRA,"lazy"=>CATFISH_FRAMES_LAZY]);' "$GAME/includes/catfish.php")" <<'P'
import sys, json, glob
d, php = sys.argv[1], json.loads(sys.argv[2])
alias, full = {}, []
for f in sorted(glob.glob(d + '/frames-alias-s*.json')):
    for k, v in json.load(open(f)).items():
        if not isinstance(v, dict): continue
        if v['kind'] == 'alias': alias[k] = v
        else: full.append(k)
bad = []
if php['base'] != {k: v['base'] for k, v in alias.items()}: bad.append('CATFISH_FRAME_BASE %s != json' % php['base'])
if php['own'] != {k: v['own'] for k, v in alias.items()}: bad.append('CATFISH_FRAME_OWN != json own lists')
if set(php['frames']) | set(php['extra']) != set(php['frames']) | set(full) | set(alias) or set(php['frames']) & set(php['extra']): bad.append('frame lists vs json: extra=%s json=%s' % (php['extra'], full + list(alias)))
if not set(php['lazy']) <= set(php['extra']) or set(php['lazy']) != {'swatA', 'swatB', 'blink', 'jump', 'happy', 'tailflick', 'eartwitch', 'yawn', 'stretch', 'washA', 'washB'}: bad.append('lazy list')
for k, v in alias.items():   # every layer an alias does not own comes from the base frame; the listed files agree with own
    for role, fn in v.get('files', {}).items():
        own = role in v['own']
        if own != fn.endswith('-%s.png' % k): bad.append('%s %s: files says %s' % (k, role, fn))
print('ok   alias map: PHP CATFISH_FRAME_BASE / CATFISH_FRAME_OWN equal frames-alias-s2/s3.json (%d aliases), frame lists match the art notes' % len(alias) if not bad else 'FAIL alias map: ' + '; '.join(bad))
P
# layer composition of alias frames (art = the recoloured set in $A): own layers by the frame's name, the rest from idleA, masks of the layer's frame
ok "alias blink: own body and eyes, tabby pattern from idleA" "$(lay $A '{"colour":"ginger","pattern":"tabby","eyes":"amber","ears":"upright","tail":"long","seed":7}' 64 blink | files)" "cf-cat-orange-blink cf-pat-tabby-orange-idleA cf-eyes-amber-blink "
ok "alias blink, folded bobtail calico: ears, tail, pattern and both masks from idleA; body and eyes own" "$(lay $A '{"colour":"cream","pattern":"calico","eyes":"green","ears":"folded","tail":"bobtail","seed":1}' 64 blink | files)" "cfmk-tail-idleA cfmk-ears-idleA cf-cat-cream-blink cf-ears-folded-cream-idleA cf-tail-bobtail-cream-idleA cfmk-tail-idleA cfmk-ears-idleA cf-pat-calico-cream-idleA cf-eyes-green-blink "
ok "alias tailflick, folded bobtail tabby: own body, tail, tail mask and tabby marks; ears and ears mask and eyes from idleA" "$(lay $A '{"colour":"brown","pattern":"tabby","eyes":"blue","ears":"folded","tail":"bobtail","seed":1}' 64 tailflick | files)" "cfmk-tail-tailflick cfmk-ears-idleA cf-cat-brown-tailflick cf-ears-folded-brown-idleA cf-tail-bobtail-brown-tailflick cfmk-tail-tailflick cfmk-ears-idleA cf-pat-tabby-brown-tailflick cf-eyes-blue-idleA "
ok "alias tailflick: tuxedo and calico come from idleA (they do not mark the tail), pointed and spotted are own" "$(for pt in tuxedo calico pointed spotted; do lay $A "{\"colour\":\"white\",\"pattern\":\"$pt\",\"eyes\":\"amber\",\"ears\":\"upright\",\"tail\":\"long\",\"seed\":1}" 64 tailflick | files | grep -o "cf-pat-[a-z]*-white-[A-Za-z]*"; done | tr '\n' ' ')" "cf-pat-tuxedo-white-idleA cf-pat-calico-white-idleA cf-pat-pointed-white-tailflick cf-pat-spotted-white-tailflick "
ok "alias eartwitch, folded bobtail calico: own body, ears, ears mask and calico marks; tail, tail mask and eyes from idleA" "$(lay $A '{"colour":"black","pattern":"calico","eyes":"hazel","ears":"folded","tail":"bobtail","seed":1}' 64 eartwitch | files)" "cfmk-tail-idleA cfmk-ears-eartwitch cf-cat-black-eartwitch cf-ears-folded-black-eartwitch cf-tail-bobtail-black-idleA cfmk-tail-idleA cfmk-ears-eartwitch cf-pat-calico-black-eartwitch cf-eyes-hazel-idleA "
ok "alias eartwitch: tuxedo and spotted from idleA, tabby and pointed own" "$(for pt in tuxedo spotted tabby pointed; do lay $A "{\"colour\":\"white\",\"pattern\":\"$pt\",\"eyes\":\"amber\",\"ears\":\"upright\",\"tail\":\"long\",\"seed\":1}" 64 eartwitch | files | grep -o "cf-pat-[a-z]*-white-[A-Za-z]*"; done | tr '\n' ' ')" "cf-pat-tuxedo-white-idleA cf-pat-spotted-white-idleA cf-pat-tabby-white-eartwitch cf-pat-pointed-white-eartwitch "
ok "alias odd-eyed: blink clips its own eyes (cfclip-*-blink), tailflick and eartwitch clip idleA's" "$(for fr in blink tailflick eartwitch; do lay $A '{"colour":"lilac","pattern":"solid","eyes":"odd","ears":"upright","tail":"long","seed":6}' 64 $fr | files | grep -o 'cfclip-[LR]-[A-Za-z]*' | tr '\n' ','; done)" "cfclip-L-blink,cfclip-R-blink,cfclip-L-idleA,cfclip-R-idleA,cfclip-L-idleA,cfclip-R-idleA,"
for f in swatA swatB jump happy yawn stretch washA washB; do
  H=$(lay $A '{"colour":"cream","pattern":"calico","eyes":"green","ears":"folded","tail":"bobtail","seed":1}' 64 $f)
  ok "layers: folded bobtail calico cat, new full frame $f: both masks, body, ears, tail, pattern, eyes" "$(echo "$H" | files)" "cfmk-tail-$f cfmk-ears-$f cf-cat-cream-$f cf-ears-folded-cream-$f cf-tail-bobtail-cream-$f cfmk-tail-$f cfmk-ears-$f cf-pat-calico-cream-$f cf-eyes-green-$f "
done
ok "alias frames render only when the base frame's art is there: no idleA files = body only for the pattern-less tabby cat" "$(mkdir -p $W/art5; cp $A/cf-cat-orange-blink.png $W/art5/; lay $W/art5 '{"colour":"ginger","pattern":"tabby","eyes":"amber","ears":"upright","tail":"long","seed":7}' 64 blink | files)" "cf-cat-orange-blink "
ok "frames: an unknown frame still falls back to idleA; the new names are accepted" "$(lay $A "$P0" 64 nonesuch | grep -c 'cf-cat-orange-idleA')$(lay $A "$P0" 64 swatB | grep -c 'cf-cat-orange-swatB')" "11"
ok "css: mask classes exist for every part and mask a frame can ask for (swatA swatB jump happy yawn stretch washA washB, eartwitch ears, tailflick tail)" "$(for f in swatA swatB jump happy yawn stretch washA washB eartwitch; do grep -c "^\.cfmk-ears-$f " $GAME/assets/catfish.css; done | tr -d '\n')$(for f in swatA swatB jump happy yawn stretch washA washB tailflick; do grep -c "^\.cfmk-tail-$f " $GAME/assets/catfish.css; done | tr -d '\n')" "111111111111111111"
ok "css: every cfmk class names the mask file of its own frame" "$(grep -o '^\.cfmk-\(ears\|tail\)-[A-Za-z]* { -webkit-mask-image: linear-gradient(#000, #000), url(img/catfish/cf-[a-z]*-mask-[A-Za-z]*\.png); mask-image: linear-gradient(#000, #000), url(img/catfish/cf-[a-z]*-mask-[A-Za-z]*\.png)' $GAME/assets/catfish.css | sed 's/^\.cfmk-\([a-z]*\)-\([A-Za-z]*\) .*url(img\/catfish\/cf-\([a-z]*\)-mask-\([A-Za-z]*\)\.png); mask-image.*url(img\/catfish\/cf-\([a-z]*\)-mask-\([A-Za-z]*\)\.png)/\1-\2=\3-\4=\5-\6/' | awk -F= '{ if ($1==$2 && $2==$3) ok++; else bad++ } END { print (bad==0 && ok>=28) ? "y" : "n" }')" y
python3 -I - "$FULL" "$GAME/assets/catfish.css" <<'P'
import sys, os, re
d, css = sys.argv[1], open(sys.argv[2]).read()
bad = []
for k in ('ears', 'tail'):
    for m in re.findall(r'^\.cfmk-%s-([A-Za-z]+) ' % k, css, re.M):
        if not os.path.exists('%s/cf-%s-mask-%s.png' % (d, k, m)): bad.append('mask file cf-%s-mask-%s.png' % (k, m))
print('ok   css: every mask class points at a mask PNG the build tool installs' if not bad else 'FAIL css masks: ' + '; '.join(bad))
P
ok "css: show rules for the new frames on .cfactive, and for idleA, idleB, stalk on .cfside" "$(for f in swatA swatB blink jump happy tailflick eartwitch yawn stretch washA washB; do grep -c "\.cfactive\.fr-$f \.ff-$f" $GAME/assets/catfish.css; done | tr -d '\n')$(for f in idleA idleB stalk; do grep -c "\.cfside\.fr-$f \.ff-$f" $GAME/assets/catfish.css; done | tr -d '\n')" "11111111111111"
ok "css: z (3 steps, 8 x 8 at 2x), sparkle (3 images, 200 ms), jump arc (0 -16 -24 -16 0 in steps) and the reduced-motion rule" "$(grep -c 'animation: cfzfloat 2400ms steps(3, end) infinite' $GAME/assets/catfish.css)$(grep -c '^@keyframes cfjump { 0% { translate: 0 0; } 20% { translate: 0 -16px; } 40% { translate: 0 -24px; } 60% { translate: 0 -16px; } 80%, 100% { translate: 0 0; } }' $GAME/assets/catfish.css)$(grep -c 'animation: cfjump 500ms steps(1, end) 1' $GAME/assets/catfish.css)$(grep -c '@keyframes cfsph[123]' $GAME/assets/catfish.css)$(grep -c 'animation: 200ms step-end 1 forwards' $GAME/assets/catfish.css)$(grep -c '\.cfz, \.cfspark, \.cfspark\.go { display: none !important; }' $GAME/assets/catfish.css)" "111311"
ok "css: the new rules use no inline-style tricks and no external url (only img/catfish)" "$(grep -o 'url([^)]*)' $GAME/assets/catfish.css | grep -vc 'url(img/catfish/\|url(#000)')" 0
# stage markup: manifest block, z, sparkle element, side-cat groups
SM=$(cfx $FULL "catfish_stage_html($SC, $SC[0], [])")
MJ=$(echo "$SM" | grep -o '<script type="application/json" id="cf-frames">[^<]*</script>' | sed 's/<[^>]*>//g')
ok "manifest: one #cf-frames JSON block in the stage, none anywhere else" "$(echo "$SM" | grep -o 'id="cf-frames"' | wc -l | tr -d ' ')" 1
python3 -I - "$MJ" "$FULL" <<'P'
import sys, json, os
m = json.loads(sys.argv[1]); d = sys.argv[2]; bad = []
if sorted(m['frames']) != sorted(['swatA', 'swatB', 'blink', 'jump', 'happy', 'tailflick', 'eartwitch', 'yawn', 'stretch', 'washA', 'washB']): bad.append('frames %s' % sorted(m['frames']))
if not m['p'].endswith('/catfish/') or not m['s'].startswith('?v='): bad.append('prefix/suffix %s %s' % (m['p'], m['s']))
for f, ls in m['frames'].items():
    for l in ls:
        if not os.path.exists(d + '/' + l[0]): bad.append(l[0] + ' missing')
    names = [l[0] for l in ls]
    if names[0] != 'cf-cat-orange-%s.png' % f: bad.append('%s body %s' % (f, names[0]))
fl = lambda f: [l[0] for l in m['frames'][f]]
# Pip: ginger tabby folded bobtail. blink: body and eyes own, the rest idleA
if fl('blink') != ['cf-cat-orange-blink.png', 'cf-ears-folded-orange-idleA.png', 'cf-tail-bobtail-orange-idleA.png', 'cf-pat-tabby-orange-idleA.png', 'cf-eyes-amber-blink.png']: bad.append('blink %s' % fl('blink'))
if fl('tailflick') != ['cf-cat-orange-tailflick.png', 'cf-ears-folded-orange-idleA.png', 'cf-tail-bobtail-orange-tailflick.png', 'cf-pat-tabby-orange-tailflick.png', 'cf-eyes-amber-idleA.png']: bad.append('tailflick %s' % fl('tailflick'))
if fl('eartwitch') != ['cf-cat-orange-eartwitch.png', 'cf-ears-folded-orange-eartwitch.png', 'cf-tail-bobtail-orange-idleA.png', 'cf-pat-tabby-orange-eartwitch.png', 'cf-eyes-amber-idleA.png']: bad.append('eartwitch %s' % fl('eartwitch'))
if m['frames']['blink'][0][1] != ['ears-idleA', 'tail-idleA'] or m['frames']['eartwitch'][0][1] != ['ears-eartwitch', 'tail-idleA'] or m['frames']['tailflick'][0][1] != ['ears-idleA', 'tail-tailflick']: bad.append('mask groups')
if m['frames']['swatB'][0][1] != ['ears-swatB', 'tail-swatB']: bad.append('swatB masks')
print('ok   manifest: 11 lazy frames, alias frames use the base layers\' files, mask groups follow the layer\'s frame, every file exists' if not bad else 'FAIL manifest: ' + '; '.join(bad))
P
ok "manifest: size stays modest (under 6 KB for a patterned folded-ear bobtail cat, 11 frames)" "$([ ${#MJ} -lt 6000 ] && echo y || echo n)" y
ok "stage: only the 8 inline frame groups are in the markup (swatA, blink, jump, happy and the rest are not inline images)" "$(echo "$SM" | sed 's#<script[^<]*</script>##' | grep -c 'cf-cat-orange-\(swatA\|swatB\|blink\|jump\|happy\|tailflick\|eartwitch\|yawn\|stretch\|washA\|washB\)')" 0
ok "stage: the awake side cat is a .cfside group with idleA, idleB and stalk, seed in data-seed; the other side cats stay single frames" "$(echo "$SM" | sed 's/<span class="cfactive.*<span class="cfspot cfpos-x0-y124"/<span class="cfspot cfpos-x0-y124"/' | grep -o 'cfspot cfside cfpos-x40-y98 fr-idleA" data-frame="idleA" data-seed="2"\|cfframe ff-\(idleA\|idleB\|stalk\)" data-f' | tr '\n' ',')$(echo "$SM" | grep -o 'class="cfspot cfpos-x[0-9]*-y[0-9]*"' | tr '\n' ',')" 'cfspot cfside cfpos-x40-y98 fr-idleA" data-frame="idleA" data-seed="2",cfframe ff-idleA" data-f,cfframe ff-idleB" data-f,cfframe ff-stalk" data-f,class="cfspot cfpos-x236-y116",class="cfspot cfpos-x0-y124",'
ok "stage: z on the cushion cat (nap spot) always; the active cat's z is off unless it starts asleep" "$(echo "$SM" | grep -c 'cfpos-x0-y124"><span class="cfart[^>]*>.*cf-cat-black-nap[^>]*>.*<img class="cfz cfz-s"')$(echo "$SM" | grep -o 'class="cfz cfz-a[^"]*"' | tr '\n' ',')$(cfx $FULL "catfish_stage_html($SC, $SC[0], [], true)" | grep -o 'class="cfz cfz-a[^"]*"' | tr '\n' ',')" '1class="cfz cfz-a",class="cfz cfz-a is-on",'
ok "stage: three sparkle images in one hidden element, no z or sparkle without their PNGs" "$(echo "$SM" | grep -o 'class="cfspark" aria-hidden="true"><img class="sp1"[^>]*cf-sparkle-1.png[^>]*><img class="sp2"[^>]*><img class="sp3"[^>]*></span>' | wc -l | tr -d ' ')$(mkdir -p $W/art6; cp $FULL/cf-room.png $FULL/cf-rod.png $FULL/cf-fish-*.png $W/art6/; cfx $W/art6 "catfish_stage_html($SC, $SC[0], [])" | grep -c 'cfz\|cfspark')" "10"
ok "stage: a cat with no art for the new frames still gets a valid manifest block (empty frames: no block)" "$(mkdir -p $W/art7; cp $FULL/cf-room.png $FULL/cf-cat-orange-idleA.png $W/art7/; cfx $W/art7 "catfish_stage_html($SC, $SC[0], [])" | grep -c 'cf-frames')" 0
ok "js: tap loop swatA 120, swatB 200, catch 600, happy 500; jump 500 ms arc; blink 120; tailflick 400; eartwitch 300; sparkles 200; side stalk 800" "$(for w in "show('swatA')" "later(120," "later(200, land)" "later(600," "later(500, finish)" "'jump'" "flick('blink', 120)" "tail ? 400 : 300" "T(function () { spark.classList.remove('go'); }, 200)" "}, 800);" "between(3000, 6000)" "between(5000, 12000)" "4000 + s.r() * 4000" "between(2400, 4200)"; do grep -c -F "$w" $GAME/assets/catfish.js | awk '{print ($1>0)?"y":"n"}'; done | tr -d '\n')" "yyyyyyyyyyyyyy"
ok "js: manifest-driven lazy layers (no inline images), preload after first interaction or 2 s, fallback frames while loading, reduced motion off" "$(for w in "getElementById('cf-frames')" "T(preload, 2000)" "'pointerdown'" "new Image().src" "var FB = {" "if (reduced()) { birdStop(); setMode(napping" "data-anim-state"; do grep -c -F "$w" $GAME/assets/catfish.js | awk '{print ($1>0)?"y":"n"}'; done | tr -d '\n')" "yyyyyyy"

# ---------- 2.1.06: idle variety, window bird, yarn roll, dust motes, rug wobble ----------
OWN4='["window"=>1,"sunbeam"=>1,"rug"=>1,"scratch"=>1]'
S6=$(cfx $FULL "catfish_stage_html($SC, $SC[0], $OWN4)")
S6N=$(cfx $FULL "catfish_stage_html($SC, $SC[0], [])")
ok "2.1.06 markup: window owned = bird sprite (3 images 24 x 20, perched f1 first) after the room base and under the cats; not owned = none" "$(echo "$S6" | grep -o '<span class="cfbird f1" aria-hidden="true"><img class="b1"[^>]*cf-bird-1.png[^>]*width="24" height="20"><img class="b2"[^>]*cf-bird-2.png[^>]*><img class="b3"[^>]*cf-bird-3.png[^>]*></span>' | wc -l | tr -d ' ')$(echo "$S6N" | grep -c 'cfbird')$(echo "$S6" | sed 's/<span class="cfactive.*//' | grep -c 'cfbird')" "101"
ok "2.1.06 markup: the window overlay keeps its robin (cf-room-window.png) as the static fallback, the layer has class cfl-window; rug layer cfl-rug" "$(echo "$S6" | grep -c 'class="cfroom-layer cfl-window" src="[^"]*cf-room-window.png')$(echo "$S6" | grep -c 'class="cfroom-layer cfl-rug"')" "11"
ok "2.1.06 markup: the yarn roll element (patch 38 x 20 and 4 rolling sprites 16 x 16) is in the stage, hidden until catfish.js rolls it" "$(echo "$S6" | grep -o '<span class="cfyarn" aria-hidden="true"><img class="yp"[^>]*cf-room-yarnpatch.png[^>]*width="38" height="20"><span class="yb"><img class="y1"[^>]*cf-yarn-1.png[^>]*width="16" height="16"><img class="y2"[^>]*><img class="y3"[^>]*><img class="y4"[^>]*cf-yarn-4.png[^>]*></span></span>' | wc -l | tr -d ' ')" 1
ok "2.1.06 markup: six dust motes only with the sunbeam upgrade" "$(echo "$S6" | grep -o '<span class="cfdust" aria-hidden="true"><i class="m1"></i><i class="m2"></i><i class="m3"></i><i class="m4"></i><i class="m5"></i><i class="m6"></i></span>' | wc -l | tr -d ' ')$(echo "$S6N" | grep -c 'cfdust')$(cfx $FULL "catfish_stage_html($SC, $SC[0], [\"window\"=>1,\"rug\"=>1])" | grep -c 'cfdust')" "100"
ok "2.1.06 markup: the room base alone (no window art files) draws no bird: the nobird overlay is transparent and is never drawn when the bird animates" "$(mkdir -p $W/art8; cp $FULL/cf-room.png $FULL/cf-room-window.png $FULL/cf-cat-orange-idleA.png $W/art8/; cfx $W/art8 "catfish_stage_html($SC, $SC[0], $OWN4)" | grep -c 'cfbird')" 0
ok "2.1.06 markup: no inline style, no event handler, scripts only the one JSON manifest block, with all four room upgrades" "$(echo "$S6" | sed 's#<script type="application/json" id="cf-frames">[^<]*</script>##' | grep -c 'style=\|<script\|on[a-z]*=')" 0
python3 -I - "$FULL" "aseprite-source/catfish/room-layout.json" "$GAME/assets/catfish.css" "$GAME/assets/catfish.js" <<'P'
import sys, json, re, numpy as np
from PIL import Image
d, lay, css, js = sys.argv[1:]
L = json.load(open(lay)); css = open(css).read(); js = open(js).read(); bad = []
im = lambda n: np.array(Image.open('%s/%s.png' % (d, n)).convert('RGBA'))
b = L['bird']; rb = im('cf-bird-1')
if b['scale'] != 2: bad.append('bird scale %s' % b['scale'])
if not re.search(r'\.cfbird \{[^}]*left: %dpx; top: %dpx; width: %dpx; height: %dpx' % (b['x'], b['y'], 12 * b['scale'], 10 * b['scale']), css): bad.append('css .cfbird box != layout bird')
# the perched sprite at 2x on the perch equals the robin of cf-room-window.png pixel for pixel (inside the room), so toggling does not shift
w = im('cf-room-window'); canvas = np.zeros((200, 320, 4), np.uint8)
big = np.repeat(np.repeat(rb, 2, 0), 2, 1)
for y in range(big.shape[0]):
    for x in range(big.shape[1]):
        X, Y = b['x'] + x, b['y'] + y
        if 0 <= X < 320 and 0 <= Y < 200: canvas[Y, X] = big[y, x]
# the overlay's robin has no outer outline ring, the sprite adds one (2 px at 2x, near black): every robin pixel must be identical, every extra sprite pixel must be dark
opq = w[..., 3] > 0
if not (canvas[opq] == w[opq]).all(): bad.append('perched sprite at 2x differs from the robin in cf-room-window.png in %d robin px' % (canvas[opq] != w[opq]).any(axis=1).sum())
extra = (canvas[..., 3] > 0) & ~opq
if (canvas[extra][:, :3].astype(int).sum(axis=1) > 150).any(): bad.append('sprite pixels beyond the robin are not dark outline')
if im('cf-room-window-nobird')[..., 3].any(): bad.append('nobird overlay is not transparent')
# yarn
y = L['yarn']; patch = im('cf-room-yarnpatch'); room = im('cf-room')
if patch.shape[:2] != (y['h'], y['w']): bad.append('patch size')
box = room[y['y']:y['y'] + y['h'], y['x']:y['x'] + y['w']]
if (box == patch).all(): bad.append('the room base has no ball under the patch box')
if (patch[..., 3] != 255).any(): bad.append('patch is not opaque')
if not re.search(r'\.cfyarn \{[^}]*left: %dpx; top: %dpx; width: %dpx; height: %dpx' % (y['x'], y['y'], y['w'], y['h']), css): bad.append('css .cfyarn box')
sx, sy = y['sprite']
if not re.search(r'\.cfyarn \.yb \{[^}]*left: %dpx; top: %d(px)?;' % (sx - y['x'], sy - y['y']), css): bad.append('css .yb offset')
for n in range(1, 5):
    if im('cf-yarn-%d' % n).shape[:2] != (16, 16): bad.append('yarn %d size' % n)
if not re.search(r'CATFISH_YARN_ROLL = true', js): bad.append('yarn roll constant')
# bird frames 2 and 3 are 12 x 10 and differ from the perched one
for n in (2, 3):
    if im('cf-bird-%d' % n).shape[:2] != (10, 12) or (im('cf-bird-%d' % n) == rb).all(): bad.append('bird %d' % n)
print('ok   2.1.06 art: perched bird at 2x on the layout perch = the robin of cf-room-window.png pixel for pixel (the redrawn sprite has no ring; a dark ring would still pass); nobird is transparent; the yarn patch box differs from the base (a ball is there); css boxes match room-layout.json' if not bad else 'FAIL 2.1.06 art: ' + '; '.join(bad))
P
ok "2.1.06 css: bird, yarn roll, rug wobble, dust motes rules; steps() only (no blur, no filter); reduced motion hides the motes and the sprite" "$(for w in '.cfstage.is-bird .cfl-window { display: none; }' '.cfyarn.is-roll .yp' '@keyframes cfyroll' '@keyframes cfrug' '.cfl-rug.is-wobble' '@keyframes cfmote' '.cfdust { display: none; }'; do grep -c -F "$w" $GAME/assets/catfish.css | awk '{print ($1>0)?"y":"n"}'; done | tr -d '\n')$(sed -n '/^\/\* 2.1.06 room life/,$p' $GAME/assets/catfish.css | grep -c 'blur\|filter')" "yyyyyyy0"
ok "2.1.06 js: idle variety yawn 900, stretch 900, wash 600 x4 every 15-30 s, bird 6-14 s (hop 150, wings 200), yarn roll 1250 ms, rug wobble, ?cffast test hook, no inline style anywhere" "$(for w in "between(15000, 30000)" "[['yawn', 900]]" "[['stretch', 900]]" "[['washA', 600], ['washB', 600], ['washA', 600], ['washB', 600]]" "(6000 + br() * 8000)" "hop ? 150 : 200" "}, 1250);" "rug.classList.add('is-wobble')" "cffast=1" "birdStop(); setMode"; do grep -c -F "$w" $GAME/assets/catfish.js | awk '{print ($1>0)?"y":"n"}'; done | tr -d '\n')$(grep -c '\.style\.\|setAttribute(.style' $GAME/assets/catfish.js)" "yyyyyyyyyy0"

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
ok "page with art: three fish buttons, role=group, and no first-visit hint once the gnome has played (lifetime taps > 0)" "$(grep -o '<button type="button" class="cfsdrop sd[123] cfk-[1-5]"' $W/art.html | wc -l | tr -d ' ')$(grep -c 'class="cfstage" role="group"' $W/art.html)$(grep -c 'class="cfhint"' $W/art.html)" "310"
mset '$m["pe"]=0;'
curl -s -b $W/p $BASE/catfish.php > $W/art2.html
ok "page with art: the hint 'Tap a fish to play!' shows while lifetime taps are 0" "$(grep -c 'class="cfhint" id="cf-hint" aria-hidden="true">Tap a fish to play!<' $W/art2.html)" 1
ok "page with art: no inline style and no inline script besides the JSON block" "$(grep -c ' style=\|<script>' $W/art.html)" 0
# 2.1.07 live scene: the buy (and a tick with a stale scene key) answers with the stage markup the page prints, only when the scene key differs
cfreset; pbase; dbx "UPDATE catfish_state SET kibble=100000, last_tick=$(date +%s) WHERE user_id=$UID_"
curl -s -b $W/p $BASE/catfish.php > $W/art3.html
SK=$(grep -o '"scene":"[^"]*"' $W/art3.html | cut -d'"' -f4)
ok "2.1.07 scene: the page carries the scene key and the active cat id in the JSON block, and the Kibble counter has its '-N' element" "$([ ${#SK} -eq 12 ] && echo y)$(grep -c '"cat":[0-9]' $W/art3.html)$(grep -c 'id="cf-spend" class="cfspend" aria-hidden="true"' $W/art3.html)" "y11"
R=$(cfapi -d do=buy -d key=sunbeam -d scene=$SK); SH=$(echo "$R" | jp stage_html)
ok "2.1.07 scene: buying the Sunbeam answers with a stage that has the sunbeam overlay and six dust motes (none before)" "$(echo "$R" | jp ok)/$(echo "$SH" | grep -c 'cfl-sunbeam')/$(echo "$SH" | grep -o '<i class="m[1-6]">' | wc -l | tr -d ' ')/$(grep -c 'cfl-sunbeam\|cfdust' $W/art3.html)" "true/1/6/0"
SK2=$(echo "$R" | jp scene)
ok "2.1.07 scene: the new scene key differs from the page's, the markup is one .cfstagewrap, same cat, no inline style or script besides the frame manifest" "$([ "$SK2" != "$SK" ] && echo y)/$(echo "$SH" | grep -c '^<div class="cfstagewrap">')/$(echo "$SH" | grep -c 'class="cfactive ')/$(echo "$SH" | sed 's#<script type="application/json" id="cf-frames">[^<]*</script>##' | grep -c 'style=\|<script\|on[a-z]*=')" "y/1/1/0"
R=$(cfapi -d do=buy -d key=sunbeam -d scene=$SK2)
ok "2.1.07 scene: a second Sunbeam level does not change the scene: the key matches, so no stage_html is sent" "$(echo "$R" | jp ok)/$(echo "$R" | jp scene)/$(echo "$R" | grep -c stage_html)" "true/$SK2/0"
R=$(cfapi -d do=buy -d key=silk -d scene=$SK2); SH=$(echo "$R" | jp stage_html)
ok "2.1.07 scene: buying Silk tail answers with a stage that shows the silk fish (kind 2) among the dangling fish" "$(echo "$SH" | grep -c 'class="cfsdrop sd[123] cfk-2"')/$(echo "$SH" | grep -o 'class="cfsdrop sd[123] cfk-[1-5]"' | wc -l | tr -d ' ')" "1/3"
SK3=$(echo "$R" | jp scene)
R=$(cfapi -d do=buy -d key=window -d scene=$SK3); SH=$(echo "$R" | jp stage_html)
ok "2.1.07 scene: buying the Window answers with the window overlay, the bird and the yarn roll element" "$(echo "$SH" | grep -c 'cfl-window')/$(echo "$SH" | grep -c 'class="cfbird f1"')/$(echo "$SH" | grep -c 'class="cfyarn"')" "1/1/1"
R=$(cfapi -d do=tick -d scene=0000)
ok "2.1.07 scene: a tick with a stale scene key answers with stage_html and the current key" "$(echo "$R" | jp scene | wc -c | tr -d ' ')/$(echo "$R" | jp stage_html | grep -c 'cfl-window')" "12/1"
CUR=$(echo "$R" | jp scene); R=$(cfapi -d do=tick -d scene=$CUR)
ok "2.1.07 scene: a tick with the current key gets no markup; a tick without a key (older page) gets none either" "$(echo "$R" | grep -c stage_html)/$(cfapi -d do=tick | grep -c stage_html)" "0/0"
R=$(cfapi -d do=buy -d key=rug)
ok "2.1.07 scene: a buy without a scene key always gets the markup (the safe default)" "$(echo "$R" | jp stage_html | grep -c 'cfl-rug')" 1
# 2.1.08: the Cat upgrades draw in the room (bowl, toy box, cat tree, cat flap) and the Rod upgrades show on the stage (classes), each buy answers with the new stage
dbx "UPDATE catfish_state SET kibble=50000000 WHERE user_id=$UID_"; R=$(cfapi -d do=tick); SKB=$(echo "$R" | jp scene)
for k in bowl toybox cattree catflap; do
  R=$(cfapi -d do=buy -d key=$k -d scene=$SKB); SH=$(echo "$R" | jp stage_html); SKB=$(echo "$R" | jp scene)
  ok "2.1.08 scene: buying $k answers with its overlay (cfl-$k, cf-room-$k.png) in the stage" "$(echo "$R" | jp ok)/$(echo "$SH" | grep -c "cfl-$k")/$(echo "$SH" | grep -c "cf-room-$k.png")" "true/1/1"
done
ok "2.1.08 scene: the overlays stack back to front window, sunbeam, rug, catflap, cattree, scratch, toybox, bowl (the stage here owns all but the scratch post)" "$(echo "$SH" | grep -o 'cfl-[a-z]*' | sort -u | tr '\n' ' ')" "cfl-bowl cfl-catflap cfl-cattree cfl-rug cfl-sunbeam cfl-toybox cfl-window "
ok "2.1.08 scene: the room markup keeps the stacking order in the page" "$(echo "$SH" | grep -o 'cfl-[a-z]*' | tr '\n' ' ')" "cfl-window cfl-sunbeam cfl-rug cfl-catflap cfl-cattree cfl-toybox cfl-bowl "
ok "2.1.08 scene: no Rod upgrade yet, so the stage has no rod classes and one wand" "$(echo "$SH" | grep -c 'class="cfstage" role="group"')/$(echo "$SH" | grep -c 'cfswand2')" "1/0"
for k in string spring motor double; do
  R=$(cfapi -d do=buy -d key=$k -d scene=$SKB); SH=$(echo "$R" | jp stage_html); SKB=$(echo "$R" | jp scene)
  ok "2.1.08 scene: buying $k answers with a new scene key and a stage that carries its rod class" "$(echo "$R" | jp ok)/$(echo "$SH" | grep -c 'class="cfstage[a-z ]* cf[a-z]*"')" "true/1"
done
ok "2.1.08 scene: with all four Rod upgrades the stage has cfrs cfrsp cfrmo cfrdb and a second wand (hidden from screen readers)" "$(echo "$SH" | grep -c 'class="cfstage cfrs cfrsp cfrmo cfrdb"')/$(echo "$SH" | grep -c 'class="cfswand cfswand2" aria-hidden="true"')" "1/1"
cfreset
cfreset
# 2.2.x art wired: gnome scarf layer, collar band, season sprites, coloured yarn balls, redrawn bird/yarn frames, Yarn panel icons, 4 upgrade tabs that fit
CSS22=$GAME/assets/catfish.css
ok "2.2.x scarf art: gnome-scarf.png is 80 x 100, alpha 0/255, grey only (tintable); gnome.php draws it with pixel_image and tints it, the red placeholder only without the PNG" "$(python3 -I - "$GAME/assets/img/gnome/gnome-scarf.png" <<'P'
import sys, numpy as np
from PIL import Image
a = np.array(Image.open(sys.argv[1]).convert('RGBA')); op = a[a[..., 3] > 0][:, :3].astype(int)
print(a.shape[:2] == (100, 80), set(np.unique(a[..., 3])) <= {0, 255}, bool((op.max(1) - op.min(1) <= 2).all()))
P
)$(grep -c "pixel_image('assets/img/gnome/gnome-scarf.png'" $GAME/includes/gnome.php)$(grep -c 'data-placeholder="1"' $GAME/includes/gnome.php)" "True True True11"
COLCAT='["colour"=>"ginger","pattern"=>"tabby","eyes"=>"amber","ears"=>"upright","tail"=>"long","seed"=>5,"collar"=>"rose"]'
H=$(cfx $FULL "catfish_cat_html($COLCAT, 64, 'idleA')")
ok "2.2.x collar art: the layered cat has the rose band layer above body and pattern and no CSS ring on the cat" "$(echo "$H" | grep -o 'cf-[a-z]*-[a-z-]*idleA.png\|cf-collar-rose-idleA.png' | sed 's/cf-eyes.*/eyes/' | tr '\n' ' ')$(echo "$H" | grep -c 'cfcol-')" "cf-cat-orange-idleA.png cf-pat-tabby-orange-idleA.png cf-collar-rose-idleA.png eyes 0"
ok "2.2.x collar art: frames pounce, catch, nap and the idleA aliases (blink) have the band; stalk (no art) has none" "$(for f in pounce catch nap blink stalk; do cfx $FULL "catfish_cat_html($COLCAT, 64, '$f')" | grep -c "cf-collar-rose-"; done | tr -d '\n')" "11110"
mkdir -p $W/art9; cp $FULL/cf-cat-orange-idleA.png $W/art9/
ok "2.2.x collar fallback: no collar PNGs = the CSS ring class stays on the cat" "$(cfx $W/art9 "catfish_cat_html($COLCAT, 64, 'idleA')" | grep -c 'cfart cf-s64 cfcol-rose')" 1
ok "2.2.x collar: the 6 colours come from catfish.css, only the 4 grey tones move (umber outline, #000000 and bell are identical in all)" "$(python3 -I - "$FULL" "$CSS22" <<'P'
import sys, re, numpy as np
from PIL import Image
d, css = sys.argv[1:]; css = open(css).read(); bad = []
grey = {}
for f in ('idleA', 'pounce', 'catch', 'nap'):
    g = np.array(Image.open('/home/user/gnome-venture/aseprite-source/catfish/art22/out/cf-collar-%s.png' % f).convert('RGBA'))
    for c in ('rose', 'mint', 'sky', 'gold', 'violet', 'red'):
        o = np.array(Image.open('%s/cf-collar-%s-%s.png' % (d, c, f)).convert('RGBA'))
        if o.shape != (64, 64, 4) or (o[..., 3] != g[..., 3]).any(): bad.append('%s %s alpha/size' % (c, f)); continue
        fixed = {(0x4a, 0x2c, 0x1a), (0x2a, 0x1a, 0x10), (0, 0, 0), (0xf5, 0xcf, 0x6a), (0xe8, 0xa3, 0x17), (0xe3, 0x81, 0x11), (0xff, 0xf1, 0xc8)}
        for y, x in zip(*np.nonzero(g[..., 3])):
            if tuple(g[y, x, :3]) in fixed and tuple(o[y, x, :3]) != tuple(g[y, x, :3]): bad.append('%s %s fixed pixel moved' % (c, f)); break
        if not (o[..., :3] != g[..., :3]).any(): bad.append('%s %s not recoloured' % (c, f))
        m = re.search(r'\.cfcol-%s \{ box-shadow: 0 0 0 2px (#[0-9a-f]{6})' % c, css)
        mk = (g[..., 0] == 0x8a) & (g[..., 1] == 0x85) & (g[..., 2] == 0x9b)
        base = '#%02x%02x%02x' % tuple(o[mk][0][:3]) if mk.any() else ''
        if not m or base != m.group(1): bad.append('%s base tone %s != css ring %s' % (c, base, m and m.group(1)))
print('ok' if not bad else ';'.join(bad[:4]))
P
)" ok
ok "2.2.x seasons: art gives class cfsart on the bits, 8 sprite files installed with their sizes, css has the sprite rules for all four seasons, reduced motion still hides them" "$(cfx $FULL 'catfish_season_art() ? 1 : 0')$(cfx $W/art9 'catfish_season_art() ? 1 : 0')$(for w in 'cf-season-petal.png' 'cf-season-petal-b.png' 'cf-season-firefly.png' 'cf-season-firefly-b.png' 'cf-season-leaf.png' 'cf-season-leaf-b.png' 'cf-season-flake.png' 'cf-season-flake-small.png' '@media (prefers-reduced-motion: reduce) { .cfseason { display: none; } }'; do grep -c -F "$w" $CSS22 | awk '{print ($1>0)?"y":"n"}'; done | tr -d '\n')$(grep -c 'style=' $CSS22)" "10yyyyyyyyy0"
ok "2.2.x yarn balls: the CSS colour filter is gone (no sepia or hue-rotate in catfish.css)" "$(grep -c 'sepia\|hue-rotate\|filter:' $CSS22)" 0
ok "2.2.x yarn balls: 4 colours x 4 rolling frames are 16 x 16 and differ from the grey frame" "$(python3 -I - "$FULL" <<'P'
import sys, numpy as np
from PIL import Image
d = sys.argv[1]; bad = []
for n in range(1, 5):
    g = np.array(Image.open('%s/cf-yarn-%d.png' % (d, n)).convert('RGBA'))
    for c in ('rose', 'mint', 'violet', 'gold'):
        o = np.array(Image.open('%s/cf-yarn-%d-%s.png' % (d, n, c)).convert('RGBA'))
        if o.shape != (16, 16, 4) or (o == g).all() or (o[..., 3] != g[..., 3]).any(): bad.append('%d %s' % (n, c))
print('ok' if not bad else ' '.join(bad))
P
)" ok
CFMETA0=$(dbv "SELECT meta FROM catfish_state WHERE user_id=$UID_")
dbx "UPDATE catfish_state SET meta='{\"extra\":2,\"ys\":0,\"ball\":\"mint\",\"balls\":[\"mint\"]}' WHERE user_id=$UID_"
pagew3; ok "2.2.x yarn balls: the mint ball rolls with cf-yarn-1..4-mint.png (4 images), none of the grey ones" "$(grep -o 'cf-yarn-[1-4]-mint.png' $W/w3.html | sort -u | wc -l | tr -d ' ')$(grep -o 'cf-yarn-[1-4].png' $W/w3.html | wc -l | tr -d ' ')" "40"
dbx "UPDATE catfish_state SET meta='{\"extra\":2,\"ys\":0}' WHERE user_id=$UID_"
pagew3; ok "2.2.x yarn balls: the plain ball keeps the grey frames" "$(grep -o 'cf-yarn-[1-4].png' $W/w3.html | sort -u | wc -l | tr -d ' ')$(grep -c 'cf-yarn-[1-4]-' $W/w3.html)" "40"
dbx "UPDATE catfish_state SET meta='$CFMETA0' WHERE user_id=$UID_"
pagew3; ok "2.2.x Yarn panel icons: cf-yi-<key>.png (48 px, same cficon cell as the upgrade rows) replace the emoji" "$(grep -o 'cf-yi-[a-z0-9]*.png' $W/w3.html | sort -u | tr '\n' ' ')" "cf-yi-balls.png cf-yi-bio.png cf-yi-buddy.png cf-yi-catnip.png cf-yi-collar.png cf-yi-keepsake.png cf-yi-scarf.png cf-yi-season.png cf-yi-show2.png cf-yi-stake.png cf-yi-titles.png cf-yi-treat.png cf-yi-tune.png "
ok "2.2.x Yarn panel icons: no icon without art keeps the emoji (cfx, no art folder)" "$(cfx none "catfish_img('yi-stake', '🔭', '', 48)")" '<span aria-hidden="true">🔭</span>'
ok "2.2.x upgrade tabs: the four tabs share the width (flex 1 1 0, no scroll) with the count pip on the corner; js passes the class" "$(grep -c '^\.cftabs4 button { flex: 1 1 0; min-width: 0;' $CSS22)$(grep -c '^\.cftabs4 { overflow: visible' $CSS22)$(grep -c "'cftabs cftabs4'" $GAME/assets/catfish.js)" 111

# the animation machine in a real browser (tests/catfish_anim.js; skipped without playwright): a home of 4 cats (patterned folded-ear bobtail active cat, lazy cat on the cushion, an awake side cat, a bored one)
if node -e "require('playwright')" 2>/dev/null; then
  dbx "DELETE FROM cats WHERE user_id=$UID_"
  for sd in 538 6 1626 160; do dbx "INSERT INTO cats (user_id, seed, name, adopted_at) VALUES ($UID_, $sd, 'Cat$sd', '2026-10-29 00:00:00')"; done
  dbx "UPDATE catfish_state SET active_cat_id=(SELECT id FROM cats WHERE user_id=$UID_ AND seed=538), upgrades='{\"glitter\":1,\"silk\":1,\"catnip\":1}', kibble=500, naps=0, run_kibble=50, last_tick=$(date +%s) WHERE user_id=$UID_"
  AOUT=$(DBFILE=$GAME/data/game.sqlite UIDX=$UID_ SQL_BUY="UPDATE catfish_state SET upgrades='{}', kibble=100000, naps=0, run_kibble=50, last_tick={NOW} WHERE user_id=$UID_" SQL_NAP="UPDATE catfish_state SET naps=1, run_kibble=0, last_tick={NOW} WHERE user_id=$UID_" SQL_AWAKE="UPDATE catfish_state SET naps=0, run_kibble=50, last_tick={NOW} WHERE user_id=$UID_" SQL_ROOM="UPDATE catfish_state SET upgrades='{\"glitter\":1,\"silk\":1,\"catnip\":1,\"window\":1,\"sunbeam\":1,\"rug\":1,\"scratch\":1}', naps=0, run_kibble=50, last_tick={NOW} WHERE user_id=$UID_" NODE_PATH=${NODE_PATH:-} node tests/catfish_anim.js $BASE 2>&1)
  echo "$AOUT"
else echo "ok   anim browser pass: skipped (no playwright)"; fi
# ===== 2.2.x pet shops: 11 shops in regions 4+, 55 room things, 8 scene slots (includes/catfish_pets.php, shop.php type pets, plan claude/plan-catfish-petshops.md) =====
# pp: run PHP against the game's own database (bootstrap + catfish.php). own: give the gnome an item without paying (the buy path has its own checks below).
pp() { php -d session.save_path=/tmp -r 'require "'$GAME'/includes/bootstrap.php"; require_once "'$GAME'/includes/catfish.php"; '"$1" 2>&1; }
own() { dbx "INSERT OR IGNORE INTO catfish_items (user_id, item_key, got_at, last_used, slotted_at) VALUES ($UID_, '$1', '2026-10-29 00:00:00', 0, 0)"; }
metaset() { php -r '$p=new PDO("sqlite:'$GAME'/data/game.sqlite"); $m=json_decode($p->query("SELECT meta FROM catfish_state WHERE user_id='$UID_'")->fetchColumn(),true) ?: []; '"$1"'; $p->prepare("UPDATE catfish_state SET meta=? WHERE user_id='$UID_'")->execute([json_encode($m)]);'; }
metaget() { php -r '$p=new PDO("sqlite:'$GAME'/data/game.sqlite"); $m=json_decode($p->query("SELECT meta FROM catfish_state WHERE user_id='$UID_'")->fetchColumn(),true) ?: []; echo eval("return " . $argv[1] . ";");' "$1"; }
shopid() { dbv "SELECT id FROM shops WHERE slug='$1-pet-shop'"; }
shopbuy() { curl -s -b $W/p "$BASE/shop.php?id=$1" > $W/shop.html; curl -s -b $W/p -c $W/p -X POST "$BASE/shop.php?id=$1" --data-urlencode "csrf=$(csrf $W/shop.html)" -d do=pet_buy -d item=$2 -o /dev/null -w '%{http_code}'; }
petsaid() { curl -s -b $W/p -c $W/p "$BASE/shop.php?id=$1" | grep -c "$2"; }   # how many page lines hold a phrase (the flash from the last POST is shown once, in the message log)
goto() { dbx "UPDATE users SET location_id=(SELECT id FROM locations WHERE slug='market-$1') WHERE id=$UID_"; }
gold() { dbx "UPDATE users SET coins=$1 WHERE id=$UID_"; }
coins() { dbv "SELECT coins FROM users WHERE id=$UID_"; }
clean_pets() { dbx "DELETE FROM catfish_items WHERE user_id=$UID_"; metaset 'unset($m["slots"], $m["slotn"], $m["pa"], $m["py"], $m["phint"], $m["rain"], $m["roll"]);'; }
PETART=aseprite-source/catfish/art22/out
OLDACT=$(dbv "SELECT active_cat_id FROM catfish_state WHERE user_id=$UID_")
cfreset; clean_pets

# --- data and shops
ok "pets data: 11 shops, 55 items, 8 slots, 5 items in every shop" "$(pp 'echo count(CATFISH_PET_SHOPS), "/", count(CATFISH_PET_ITEMS), "/", count(CATFISH_PET_SLOTS), "/", implode(",", array_count_values(array_column(CATFISH_PET_ITEMS, "shop")));')" "11/55/8/5,5,5,5,5,5,5,5,5,5,5"
ok "pets data: every item fits its own slot type, shelf things also fit the sill, and every price is in Petals above 0" "$(pp '$bad = 0; foreach (CATFISH_PET_ITEMS as $k => $i) { $keys = array_column(array_filter(CATFISH_PET_SLOTS, fn($s) => $s["type"] === $i["type"]), "key"); if ($i["type"] === "shelf") $keys = array_merge($keys, ["sill"]); sort($keys); $f = $i["fit"]; sort($f); if ($f !== $keys || $i["price"] < 1 || !isset(CATFISH_PET_SHOPS[$i["shop"]])) $bad++; } echo $bad;')" 0
ok "pets: 11 pet shops exist (shop_type pets), one beside each regional market" "$(dbv "SELECT COUNT(*) FROM shops WHERE shop_type='pets'")/$(dbv "SELECT COUNT(*) FROM shops s JOIN locations l ON l.id=s.location_id WHERE s.shop_type='pets' AND l.slug='market-' || lower(substr(s.slug, 1, instr(s.slug, '-') - 1))")" "11/11"
ok "pets: regions 1 to 3 (Maplewold, Maizehollow, Mistmoor) have no pet shop; the shop regions are REGION_LEVELS from the 4th on, in order" "$(dbv "SELECT COUNT(*) FROM shops s JOIN locations l ON l.id=s.location_id WHERE s.shop_type='pets' AND l.region_id IN (SELECT id FROM regions WHERE code IN ('NA','CA','NWE'))")/$(pp 'echo implode(",", array_slice(array_keys(REGION_LEVELS), 3)) === implode(",", array_keys(CATFISH_PET_SHOPS)) ? "same" : "differ";')" "0/same"
ok "pets: each shop has its keeper (npc slug = keeper_slug with hyphens) working round the clock" "$(pp '$n = 0; foreach (CATFISH_PET_SHOPS as $c => $s) { $sid = (int)q_val("SELECT id FROM shops WHERE slug = ?", [petshop_slug($c)]); $nid = (int)q_val("SELECT id FROM npcs WHERE slug = ?", [str_replace("_", "-", $s["keeper_slug"])]); if ($sid && $nid && q_val("SELECT 1 FROM npc_schedules WHERE npc_id = ? AND shop_id = ? AND activity = \"working\" AND start_hour = end_hour", [$nid, $sid])) $n++; } echo $n;')" 11
ok "pets: the setup is idempotent (a second run adds nothing)" "$(pp 'petshops_ensure(); echo q_val("SELECT COUNT(*) FROM shops WHERE shop_type = \"pets\""), "/", q_val("SELECT COUNT(*) FROM npc_schedules WHERE shop_id IN (SELECT id FROM shops WHERE shop_type = \"pets\")");')" "11/11"
ok "pets: no code path gives Petals (no give_petals in the pets file, no petal effect in the data)" "$(grep -c 'give_petals' $GAME/includes/catfish_pets.php)$(pp 'echo count(array_filter(CATFISH_PET_ITEMS, fn($i) => isset($i["effect"]["petals"]) || isset($i["effect"]["coins"])));')" "00"
ok "pets: the numbers are admin settings (uses a day, pop minutes, Yarn a week, slot hours, caps, price percent, shops on)" "$(for k in catfish_pet_uses_day catfish_pet_pop_min_day catfish_pet_yarn_week catfish_pet_slot_hours catfish_pet_cap_away catfish_pet_cap_show catfish_pet_cap_rare catfish_pet_cap_catnip catfish_pet_price_pct catfish_pet_shops_open; do grep -c "'$k' =>" $GAME/includes/functions.php; done | tr -d '\n')" "1111111111"

# --- buying: needs the region (shop_reachable), Petals only, one row in catfish_items, never user_items
CBSHOP=$(shopid cb); UI0=$(dbv "SELECT COUNT(*) FROM user_items"); gold 50000
ok "pets shop page: reachable or not it lists the shop's five things, the keeper and no inline style; away from the region the buttons are off" "$(curl -s -b $W/p $BASE/shop.php?id=$CBSHOP > $W/ps.html; grep -c 'Coral Pennyfeather' $W/ps.html | tr -d '\n')/$(grep -o 'name="item" value="[a-z_]*"' $W/ps.html | wc -l | tr -d ' ')/$(grep -c 'style=' $W/ps.html)/$(grep -o 'name="item" value="[a-z_]*"[^>]*><button class="btn" type="submit" disabled' $W/ps.html | wc -l | tr -d ' ')" "1/5/0/5"
ok "buy away from the region: refused (nothing bought, no Petals taken)" "$(shopbuy $CBSHOP conch_shell)/$(dbv "SELECT COUNT(*) FROM catfish_items WHERE user_id=$UID_")/$(coins)" "302/0/50000"
shopbuy $CBSHOP conch_shell >/dev/null
ok "buy away: the keeper says the region was not reached" "$([ "$(petsaid $CBSHOP 'out this far\|beaches')" -ge 1 ] && echo y || echo n)" y
goto cb
ok "buy conch_shell at the Sunsprinkle Isles shop: one row, 400 Petals taken, no user_items row" "$(shopbuy $CBSHOP conch_shell)/$(dbv "SELECT COUNT(*) FROM catfish_items WHERE user_id=$UID_ AND item_key='conch_shell'")/$(coins)/$(dbv "SELECT COUNT(*) FROM user_items")" "302/1/49600/$UI0"
ok "buy: the message is the keeper's lines and says what it cost" "$([ "$(petsaid $CBSHOP 'Conch Shell is yours for 400 Petals')" -ge 1 ] && echo y || echo n)" y
ok "buy the same thing again: refused, charged once" "$(shopbuy $CBSHOP conch_shell)/$(dbv "SELECT COUNT(*) FROM catfish_items WHERE user_id=$UID_")/$(coins)" "302/1/49600"
ok "buy something another shop sells: refused" "$(shopbuy $CBSHOP amphora)/$(dbv "SELECT COUNT(*) FROM catfish_items WHERE user_id=$UID_ AND item_key='amphora'")/$(coins)" "302/0/49600"
gold 1700
ok "buy without enough Petals: refused, Petals untouched, keeper says so" "$(shopbuy $CBSHOP hammock_net)/$(dbv "SELECT COUNT(*) FROM catfish_items WHERE user_id=$UID_ AND item_key='hammock_net'")/$(coins)/$([ "$(petsaid $CBSHOP 'Petals yet\|Petals short')" -ge 1 ] && echo y || echo n)" "302/0/1700/y"
gold 3000
ok "buy hammock_net (1800)" "$(shopbuy $CBSHOP hammock_net)/$(coins)/$(dbv "SELECT COUNT(*) FROM catfish_items WHERE user_id=$UID_")" "302/1200/2"
ok "buy needs the CSRF token" "$(curl -s -b $W/p -o /dev/null -w '%{http_code}' -X POST "$BASE/shop.php?id=$CBSHOP" -d do=pet_buy -d item=bell_lure)/$(dbv "SELECT COUNT(*) FROM catfish_items WHERE user_id=$UID_")" "400/2"
ok "buy: a pet shop takes no other action (sell, basket buys, sink)" "$(curl -s -b $W/p -c $W/p "$BASE/shop.php?id=$CBSHOP" > $W/shop.html; curl -s -b $W/p -X POST "$BASE/shop.php?id=$CBSHOP" --data-urlencode "csrf=$(csrf $W/shop.html)" -d do=buy -d 'qty[1]=1' -o /dev/null -w '%{http_code}')/$(coins)" "302/1200"
ok "pets: shop page after buying shows the thing as yours" "$(curl -s -b $W/p $BASE/shop.php?id=$CBSHOP | grep -o 'Yours, not placed' | wc -l | tr -d ' ')" 2

# --- slots: locked, wrong fit, one item one spot, free swapping
clean_pets; own conch_shell; own hammock_net
ok "slots: locked spots (frame after 3 shops, ceiling and rod charm for Yarn, floor corner after 5 shops) refuse even an empty change" "$(pp '$o = ""; foreach ([4, 5, 6, 8] as $n) $o .= catfish_pet_slot('$UID_', $n, "")[0] ? "Y" : "n"; echo $o;' | tr -d '\n')" "nnnn"
ok "slots: the free spots are shelf left, sill and floor by the bowl; shelf right opens after one shop (conch owned = 1 shop)" "$(pp '$u = '$UID_'; $m = catfish_state($u)["meta"]; $o = catfish_pet_owned($u); $r = ""; foreach (CATFISH_PET_SLOTS as $s) $r .= catfish_pet_slot_open($s, $m, $o)[0] ? "1" : "0"; echo $r;')" "11100010"
ok "slots: wrong fit refused (a hammock is a floor-left thing: not on the shelf, the sill or the floor by the bowl)" "$(pp '$u = '$UID_'; $o = ""; foreach ([1, 2, 3, 7] as $n) $o .= catfish_pet_slot($u, $n, "hammock_net")[0] ? "Y" : "n"; echo $o;')" "nnnn"
ok "slots: an item you do not own is refused" "$(pp 'echo catfish_pet_slot('$UID_', 1, "amphora")[0] ? "Y" : "n";')" n
ok "slots: a locked spot refuses even a thing that would fit (floor-left needs 5 shops, we have 1)" "$(pp 'echo catfish_pet_slot('$UID_', 6, "hammock_net")[0] ? "Y" : "n";')" n
cfreset; R=$(cfapi -d do=tick); SK0=$(echo "$R" | jp scene)
R=$(cfapi -d do=petslot -d slot=1 -d item=conch_shell -d scene=$SK0)
ok "petslot: conch in the left shelf spot, ok, the answer carries a new scene key and the stage (it holds the thing)" "$(echo "$R" | jp ok)/$([ "$(echo "$R" | jp scene)" != "$SK0" ] && echo changed)/$(echo "$R" | jp stage_html | grep -c 'cfpet cfpet-s1 cfpi-conch_shell')" "true/changed/1"
SK1=$(echo "$R" | jp scene)
ok "petslot: even without a scene key the answer carries stage_html" "$(cfapi -d do=petslot -d slot=1 -d item=conch_shell | jp stage_html | grep -c 'cfpi-conch_shell')" 1
R=$(cfapi -d do=petslot -d slot=3 -d item=conch_shell)
ok "one item, one spot: moving the conch to the sill empties the shelf spot" "$(echo "$R" | jp ok)/$(metaget 'json_encode($m["slots"])')" 'true/{"3":"conch_shell"}'
ok "swapping out: an empty choice puts it back on the shelf and clears slotted_at" "$(cfapi -d do=petslot -d slot=3 -d item= | jp ok)/$(metaget 'json_encode($m["slots"])')/$(dbv "SELECT slotted_at FROM catfish_items WHERE user_id=$UID_ AND item_key='conch_shell'")" 'true/[]/0'
ok "petslot: a wrong fit through the API answers 400 with the reason, and a locked spot too" "$(cfapi -d do=petslot -d slot=1 -d item=hammock_net | jp ok)/$(curl -s -b $W/p -o /dev/null -w '%{http_code}' -X POST $BASE/catfish_api.php --data-urlencode "csrf=$CS" -d do=petslot -d slot=6 -d item=hammock_net)" "false/400"
cfreset
ok "petslot: the scene key changes with the slot map and goes back when it is empty again" "$(R1=$(cfapi -d do=petslot -d slot=1 -d item=conch_shell | jp scene); R2=$(cfapi -d do=petslot -d slot=1 -d item= | jp scene); [ "$R1" != "$R2" ] && [ "$R2" = "$(cfapi -d do=tick | jp scene)" ] && echo y)" y
ok "scene key (pure): changes with a slot, not with an empty map, and the old key is unchanged with no room things" "$(cfx $FULL '(function () { $a = catfish_scene_key([], null, []); $b = catfish_scene_key([], null, [], ["slots" => [1 => "conch_shell"], "rain" => false]); $c = catfish_scene_key([], null, [], ["slots" => [], "rain" => false]); $d = catfish_scene_key([], null, [], ["slots" => [1 => "amphora"], "rain" => false]); return ($a === $c ? "same" : "diff") . ($a !== $b ? "/changes" : "/stuck") . ($b !== $d ? "/item" : "/blind"); })()')" "same/changes/item"
ok "no JS: the page forms place a thing (302) and the slot is set" "$(pagew3; cfpost -d do=petslot -d slot=3 -d item=conch_shell)/$(metaget 'json_encode($m["slots"])')" '302/{"3":"conch_shell"}'
pagew3
ok "Room things panel: a seventh hub panel with a form and a select for each open spot (1, 2, 3 and 7 with one shop) and a Use button only for active things" "$(grep -c 'id="cf-p-pets"' $W/w3.html)/$(grep -o 'name="do" value="petslot"' $W/w3.html | wc -l | tr -d ' ')/$(grep -o 'name="do" value="petuse"' $W/w3.html | wc -l | tr -d ' ')/$(grep -o 'id="cf-petsel-' $W/w3.html | wc -l | tr -d ' ')" "1/4/0/4"
ok "Room things panel: the locked spots say how to open them (frame and floor corner: shops; ceiling and rod charm: Yarn) and the Yarn spots have an unlock form" "$(grep -o 'different pet shop' $W/w3.html | wc -l | tr -d ' ')/$(grep -o 'Opens for 5 Yarn\|Opens for 15 Yarn' $W/w3.html | wc -l | tr -d ' ')/$(grep -o 'name="do" value="petunlock"' $W/w3.html | wc -l | tr -d ' ')" "2/2/2"
ok "Room things panel: owned things are the select options, only the ones that fit (conch: shelf and sill, not the floor by the bowl; the hammock only in the corner, which is locked)" "$(php -r '$h = file_get_contents($argv[1]); foreach ([1, 3, 7] as $n) { preg_match("#id=\"cf-petsel-$n\".*?</select>#s", $h, $m); echo substr_count($m[0] ?? "", "value=\"conch_shell\""), substr_count($m[0] ?? "", "value=\"hammock_net\""), ","; }' $W/w3.html)" "10,10,00,"
ok "Room things panel: a pet shops list with a link to each existing shop" "$(grep -c 'class="cfpshops"' $W/w3.html)/$(php -r 'preg_match("#class=\"cfpshops\".*?</ul>#s", file_get_contents($argv[1]), $m); echo substr_count($m[0] ?? "", "shop.php?id=");' $W/w3.html)" "1/11"

# --- Yarn spots
clean_pets; dbx "UPDATE catfish_state SET yarn=4 WHERE user_id=$UID_"; metaset '$m["ys"]=0;'; cfreset
ok "Yarn spots: 4 Yarn is not enough for the ceiling (5)" "$(cfapi -d do=petunlock -d slot=5 | jp ok)/$(metaget 'json_encode($m["slotn"] ?? [])')" "false/[]"
dbx "UPDATE catfish_state SET yarn=30 WHERE user_id=$UID_"
ok "Yarn spots: 30 Yarn opens the ceiling (5) and the rod charm (15), spends 20, and a spot opens once" "$(cfapi -d do=petunlock -d slot=5 | jp ok)/$(cfapi -d do=petunlock -d slot=8 | jp ok)/$(cfapi -d do=petunlock -d slot=5 | jp ok)/$(metaget '$m["ys"]')/$(metaget 'json_encode($m["slotn"])')" 'true/true/false/20/["ceiling","rod"]'
ok "Yarn spots: a floor spot cannot be opened with Yarn" "$(cfapi -d do=petunlock -d slot=6 | jp ok)" false

# --- passive bonuses: Kibble % adds up with no cap, away time, rare fish, Catnip, Cat Show, taps (caps are admin settings)
cfreset; clean_pets; metaset '$m["slotn"]=["ceiling","rod"];'
for k in bonsai chai_stall_sign calabash_bowl southern_cross_mobile lemon_on_a_string terracotta_catgrass hammock_net siesta_fan kilim_cushion acacia_perch koi_kite_lure seashell_lure weaver_bird_nest kite_tail_lure toucan_feather_lure coffee_bean_rattle capybara_plush kiwi_plush paddy_hat_bed; do own $k; done
dbx "UPDATE catfish_state SET last_tick=$(date +%s), upgrades='{}' WHERE user_id=$UID_"
KPH0=$(cfapi -d do=tick | jp view.kph)
cfapi -d do=petslot -d slot=3 -d item=bonsai >/dev/null; KPH1=$(cfapi -d do=tick | jp view.kph)
ok "Kibble %: a Bonsai on the sill adds 2% to the rate shown" "$(php -r 'echo abs('$KPH1' / '$KPH0' - 1.02) < 0.003 ? "y" : "n";')" y
for sp in "4 chai_stall_sign" "7 calabash_bowl" "5 southern_cross_mobile" "8 lemon_on_a_string"; do set -- $sp; cfapi -d do=petslot -d slot=$1 -d item=$2 >/dev/null; done
KPH2=$(cfapi -d do=tick | jp view.kph)
ok "Kibble %: all five Kibble spots filled = +9% in total (2+2+2+2+1), nothing caps the sum" "$(pp 'echo catfish_pet_bonus('$UID_', true)["kibble_pct"];')/$(php -r 'echo abs('$KPH2' / '$KPH0' - 1.09) < 0.004 ? "y" : "n";')" "9/y"
ok "Kibble %: a thing outside its spot (in the shop, not placed) adds nothing: terracotta owned but not placed" "$(pp 'echo catfish_pet_bonus('$UID_', true)["kibble_pct"];')" 9
cfapi -d do=petslot -d slot=4 -d item= >/dev/null
ok "Kibble %: emptying the frame drops its 2% at once" "$(pp 'echo catfish_pet_bonus('$UID_', true)["kibble_pct"];')" 7
metaset '$m["slots"]=new stdClass();'
# away time, rare fish, Catnip, Cat Show, taps
metaset '$m["slots"]=["5"=>"siesta_fan","6"=>"hammock_net"];'
ok "away: a Siesta Fan (ceiling +15) and a Hammock Net (floor corner +10) lift the away cap by 25 minutes" "$(pp '$b = catfish_pet_bonus('$UID_', true); echo $b["away_min"], "/", catfish_offline_cap(null, 0, 60 * $b["away_min"]) - catfish_offline_cap(null, 0);')" '25/1500'
metaset '$m["slots"]=["5"=>"siesta_fan","6"=>"paddy_hat_bed"];'
ok "away: a tick after a long absence pays for the longer cap (30 minutes more of 8 hours or 10 for a lazy cat, at half rate)" "$(
  metaset '$m["slots"]=new stdClass();'; dbx "UPDATE catfish_state SET kibble=0, last_tick=$(( $(date +%s) - 100000 )) WHERE user_id=$UID_"; B=$(cfapi -d do=tick | jp view.kibble)
  metaset '$m["slots"]=["5"=>"siesta_fan","6"=>"paddy_hat_bed"];'; dbx "UPDATE catfish_state SET kibble=0, last_tick=$(( $(date +%s) - 100000 )) WHERE user_id=$UID_"; A=$(cfapi -d do=tick | jp view.kibble)
  CAPB=$(pp 'echo catfish_offline_cap(catfish_active('$UID_', catfish_state('$UID_')), 0);'); php -r '$want = ('$CAPB' + 1800) / '$CAPB'; echo abs('$A' / '$B' - $want) < 0.01 ? "y" : "n:'$A'/'$B'";')" y
ok "away: the cap on the total is an admin setting (catfish_pet_cap_away=10 with fan and bed: 10)" "$(setg catfish_pet_cap_away 10; pp 'echo catfish_pet_bonus('$UID_', true)["away_min"];'; setg catfish_pet_cap_away 30)" 10
ok "caps: the defaults are away 30, Cat Show 2, rare fish 10, Catnip 10, and 4 taps, 60 pop minutes, 1 Yarn a week, 1 hour in the spot" "$(pp 'foreach (["away" => 30, "show" => 2, "rare" => 10, "catnip" => 10] as $k => $d) echo catfish_pet_cfg("catfish_pet_cap_" . $k, 0), ","; echo catfish_pet_cfg("catfish_pet_uses_day", 0), ",", catfish_pet_cfg("catfish_pet_pop_min_day", 0), ",", catfish_pet_cfg("catfish_pet_yarn_week", 0), ",", catfish_pet_cfg("catfish_pet_slot_hours", 0);')" "30,2,10,10,4,60,1,1"
metaset '$m["slots"]=["3"=>"acacia_perch","6"=>"kilim_cushion"];'
ok "Cat Show: Acacia Perch (sill) +1 and Kilim Cushion (floor corner) +1 make +2 for any cat" "$(pp '$u = '$UID_'; echo catfish_pet_show_bonus($u, ["mood" => "greedy"]);')" 2
ok "Cat Show: the total is capped by the admin setting catfish_pet_cap_show (set to 1: 1)" "$(setg catfish_pet_cap_show 1; pp 'echo catfish_pet_show_bonus('$UID_', ["mood" => "greedy"]);'; setg catfish_pet_cap_show 2)" 1
metaset '$m["slots"]=["6"=>"capybara_plush"];'
ok "Cat Show: Capybara Plush counts only for a lazy cat (also a cat made lazy by a Mood Treat), not for a hyper one" "$(pp '$u = '$UID_'; echo catfish_pet_show_bonus($u, ["mood" => "lazy"]), catfish_pet_show_bonus($u, ["mood" => "hyper"]), catfish_pet_show_bonus($u, ["mood" => "hyper", "mood2" => "lazy"]);')" "101"
ok "Cat Show: the judge adds the bonus to the score and the ribbon tier follows, the judges' own numbers do not move (pure)" "$(cfx none '(function () { $c = catfish_cat(11); $t = catfish_show_theme("2026-W44"); $a = catfish_show_judge(7, "2026-W44", $c, $t); $b = catfish_show_judge(7, "2026-W44", $c, $t, 2); return ($b["score"] - $a["score"]) . "/" . ($b["judges"] === $a["judges"] ? "same judges" : "judges moved") . "/" . ($b["tier"] === catfish_show_tier($b["score"]) ? "tier" : "no tier"); })()')" "2/same judges/tier"
ok "taps (pure): x1.5 on the first 10 taps (Toucan lure), +25% on the first 30 (Coffee rattle), nothing after, and a 1 Kibble tap never pays less" "$(cfx none 'implode(",", [catfish_pet_tap_value(10, 5, ["n" => 10, "mult" => 1.5]), catfish_pet_tap_value(10, 11, ["n" => 10, "mult" => 1.5]), catfish_pet_tap_value(10, 30, ["n" => 30, "mult" => 1.25]), catfish_pet_tap_value(10, 31, ["n" => 30, "mult" => 1.25]), catfish_pet_tap_value(1, 1, ["n" => 10, "mult" => 1.5]), catfish_pet_tap_value(10, 1, null)])')" "15,10,12,10,1,10"
ok "taps: the Toucan lure on the rod charm changes the next tap's shown value (view.play.v) for the first taps of the day" "$(metaset '$m["slots"]=new stdClass(); unset($m["pb"],$m["pc"],$m["pd"]);'; dbx "UPDATE catfish_state SET last_tick=$(date +%s), upgrades='{}' WHERE user_id=$UID_"; V0=$(cfapi -d do=tick | jp view.play.v); metaset '$m["slots"]=["8"=>"toucan_feather_lure"];'; V1=$(cfapi -d do=tick | jp view.play.v); php -r 'echo ('$V1' >= '$V0' && '$V1' == max('$V0', floor('$V0' * 1.5))) ? "y" : "n:'$V0'/'$V1'";')" y
ok "rare fish (pure): a Sneaky cat's chance grows by the %, any other cat finds them at that % of the Sneaky rate" "$(cfx none 'implode(",", [catfish_rare_fish(600.0, 3600, 0.5), catfish_rare_fish(600.0, 3600, 0.52, 10), catfish_rare_fish(600.0, 3600, 0.04, 10, false), catfish_rare_fish(600.0, 3600, 0.06, 10, false), catfish_rare_fish(600.0, 3600, 0.01, 0, false)])')" "0,60,60,0,0"
ok "Catnip Hour: a Kite Tail Lure on the rod charm adds 10 minutes (3600 + 600 seconds)" "$(metaset '$m["slots"]=["8"=>"kite_tail_lure"]; unset($m["catnip"]);'; dbx "UPDATE catfish_state SET yarn=40 WHERE user_id=$UID_"; pp 'catfish_pet_bonus('$UID_', true); [$ok] = catfish_catnip('$UID_'); $m = catfish_state('$UID_')["meta"]; $d = $m["catnip"]["until"] - time(); echo $ok ? "ok" : "no", "/", ($d > 4190 && $d <= 4200) ? "4200" : $d;')" "ok/4200"
metaset '$m["slots"]=new stdClass(); unset($m["catnip"]);'

# --- active things
clean_pets; metaset '$m["slotn"]=["ceiling","rod"]; $m["slots"]=new stdClass();'; for k in amphora sand_timer floating_lantern matryoshka_mice steel_pan_chime tide_pool_jar maneki_neko parrot_perch mirage_mirror singing_bowl shadow_puppet_screen rain_stick tea_tray talking_drum rain_cloud_mobile; do own $k; done
for k in conch_shell hammock_net; do own $k; done; dbx "INSERT OR IGNORE INTO catfish_items (user_id,item_key,got_at,last_used,slotted_at) VALUES ($UID_,'bonsai','x',0,0),($UID_,'chai_stall_sign','x',0,0),($UID_,'koi_kite_lure','x',0,0),($UID_,'kilim_cushion','x',0,0)"
dbx "UPDATE catfish_state SET kibble=0, run_kibble=0, last_tick=$(date +%s), active_cat_id=$OLDACT WHERE user_id=$UID_"
cfreset
cfapi -d do=petslot -d slot=1 -d item=amphora >/dev/null
R=$(cfapi -d do=petuse -d slot=1)
ok "use: a tap right after placing is refused: the thing must sit in its spot for an hour first" "$(echo "$R" | jp ok)/$(echo "$R" | jp message | grep -c 'more in its spot')/$(dbv "SELECT last_used FROM catfish_items WHERE user_id=$UID_ AND item_key='amphora'")" "false/1/0"
ok "use: a passive thing says it needs no tapping; an empty spot says nothing is there" "$(cfapi -d do=petslot -d slot=3 -d item=conch_shell >/dev/null; cfapi -d do=petuse -d slot=3 | jp message | grep -c 'needs no tapping')/$(cfapi -d do=petuse -d slot=7 | jp message | grep -c 'Nothing is in that spot')" "1/1"
dbx "UPDATE catfish_items SET slotted_at=$(( $(date +%s) - 4000 )) WHERE user_id=$UID_"
dbx "UPDATE catfish_state SET last_tick=$(date +%s) WHERE user_id=$UID_"; COINS0=$(coins); KPH=$(cfapi -d do=tick | jp view.kph); K0=$(cfapi -d do=tick | jp view.kibble)
R=$(cfapi -d do=petuse -d slot=1)
ok "use: after an hour in its spot the Amphora pays 15 minutes of the current Kibble/h (a bit over, with the seconds of income in between), once" "$(echo "$R" | jp ok)/$(php -r '$want = floor('$KPH' * 15 / 60); $got = '$(echo "$R" | jp view.kibble)' - '$K0'; echo ($got >= $want - 1 && $got <= $want + 40) ? "y" : "n:$got/$want";')" "true/y"
ok "use: Petals are never touched by using a thing" "$(coins)" "$COINS0"
ok "use: the cooldown (20 h) now sits on the owned item, the day's count is 1 and 15 pop minutes are used; the answer's stage shows the thing again" "$(dbv "SELECT CASE WHEN last_used > 0 THEN 'set' ELSE 'zero' END FROM catfish_items WHERE user_id=$UID_ AND item_key='amphora'")/$(metaget '$m["pa"]["n"] . "," . $m["pa"]["kmin"]')/$(echo "$R" | jp stage_html | grep -c 'cfpi-amphora')" "set/1,15/1"
R=$(cfapi -d do=petuse -d slot=1)
ok "use: again at once is refused with the time left" "$(echo "$R" | jp ok)/$(echo "$R" | jp message | grep -c 'ready again in')" "false/1"
LU=$(dbv "SELECT last_used FROM catfish_items WHERE user_id=$UID_ AND item_key='amphora'")
cfapi -d do=petslot -d slot=2 -d item=amphora >/dev/null; cfapi -d do=petslot -d slot=1 -d item=amphora >/dev/null
ok "cooldown survives a swap: moving it to another spot and back keeps last_used" "$(dbv "SELECT last_used FROM catfish_items WHERE user_id=$UID_ AND item_key='amphora'")" "$LU"
dbx "UPDATE catfish_items SET slotted_at=$(( $(date +%s) - 4000 )) WHERE user_id=$UID_"
R=$(cfapi -d do=petuse -d slot=1)
ok "cooldown survives a swap: once the hour has passed again it is still refused, by the cooldown (not the spot)" "$(echo "$R" | jp ok)/$(echo "$R" | jp message | grep -c 'ready again in')" "false/1"
ok "cooldown: it ends on its own (last_used 21 h ago = usable again)" "$(dbx "UPDATE catfish_items SET last_used=$(( $(date +%s) - 21 * 3600 )) WHERE user_id=$UID_ AND item_key='amphora'"; cfapi -d do=petuse -d slot=1 | jp ok)" true

# daily limit: 4 uses a Hollow day across all spots
clean_pets; metaset '$m["slotn"]=["ceiling","rod"];'; for k in amphora sand_timer floating_lantern matryoshka_mice steel_pan_chime parrot_perch; do own $k; done
cfapi -d do=petslot -d slot=1 -d item=amphora >/dev/null; cfapi -d do=petslot -d slot=2 -d item=sand_timer >/dev/null; cfapi -d do=petslot -d slot=3 -d item=parrot_perch >/dev/null; cfapi -d do=petslot -d slot=5 -d item=steel_pan_chime >/dev/null
dbx "UPDATE catfish_items SET slotted_at=$(( $(date +%s) - 4000 )) WHERE user_id=$UID_"
TODAY=$(pp 'echo catfish_today();'); metaset '$m["pa"]=["day"=>"'$TODAY'", "n"=>0, "kmin"=>0];'
ok "limit: four taps in one Hollow day work (amphora, sand timer, parrot perch, chime)" "$(for s in 1 2 3 5; do cfapi -d do=petuse -d slot=$s | jp ok; echo -n ,; done)" "true,true,true,true,"
dbx "UPDATE catfish_items SET last_used=0 WHERE user_id=$UID_ AND item_key='amphora'"; R=$(cfapi -d do=petuse -d slot=1)
ok "limit: the 5th tap of the day is refused, even by a rested thing (amphora, cooldown cleared)" "$(echo "$R" | jp ok)/$(echo "$R" | jp message | grep -c '4 room things used today')" "false/1"
ok "limit: tomorrow the count starts again (day in the meta is old)" "$(metaset '$m["pa"]["day"]="2020-01-01";'; cfapi -d do=petuse -d slot=1 | jp ok)" true
ok "limit: the number is an admin setting (catfish_pet_uses_day=1: the second tap is refused)" "$(setg catfish_pet_uses_day 1; dbx "UPDATE catfish_items SET last_used=0 WHERE user_id=$UID_"; metaset '$m["pa"]=["day"=>"'$TODAY'", "n"=>1, "kmin"=>0];'; cfapi -d do=petuse -d slot=2 | jp ok; setg catfish_pet_uses_day 4)" false

# pops: at most 60 minutes of Kibble a day
clean_pets; metaset '$m["slotn"]=["ceiling","rod"];'; for k in amphora sand_timer floating_lantern; do own $k; done
cfapi -d do=petslot -d slot=1 -d item=amphora >/dev/null; cfapi -d do=petslot -d slot=2 -d item=sand_timer >/dev/null; cfapi -d do=petslot -d slot=3 -d item=floating_lantern >/dev/null
dbx "UPDATE catfish_items SET slotted_at=$(( $(date +%s) - 4000 )) WHERE user_id=$UID_"
metaset '$m["pa"]=["day"=>"'$TODAY'", "n"=>1, "kmin"=>55];'; dbx "UPDATE catfish_state SET last_tick=$(date +%s) WHERE user_id=$UID_"
KPH=$(cfapi -d do=tick | jp view.kph); K0=$(cfapi -d do=tick | jp view.kibble)
R=$(cfapi -d do=petuse -d slot=1)
ok "pops: with 55 of 60 minutes used, a 15 minute pop pays only the last 5, and the day shows 60" "$(echo "$R" | jp ok)/$(metaget '$m["pa"]["kmin"]')/$(php -r '$want = floor('$KPH' * 5 / 60); $got = '$(echo "$R" | jp view.kibble)' - '$K0'; echo ($got >= $want - 1 && $got <= $want + 40) ? "y" : "n:$got/$want";')" "true/60/y"
R=$(cfapi -d do=petuse -d slot=2)
ok "pops stop at 60 minutes: the next pop is refused (nothing paid, no cooldown spent)" "$(echo "$R" | jp ok)/$(echo "$R" | jp message | grep -c 'all the Kibble they can')/$(dbv "SELECT last_used FROM catfish_items WHERE user_id=$UID_ AND item_key='sand_timer'")/$(metaget '$m["pa"]["n"]')" "false/1/0/2"
ok "pops: the minutes are an admin setting (catfish_pet_pop_min_day=0 stops all pops)" "$(setg catfish_pet_pop_min_day 0; cfapi -d do=petuse -d slot=3 | jp ok; setg catfish_pet_pop_min_day 60)" false

# Yarn: 1-in-N chance, seeded roll for the test, at most one a week from all things
ok "yarn odds (pure): 1-in-50 hits at about 2% over 200000 seeded rolls; a roll of 0 always hits, 0.99 never; odds 0 never" "$(cfx none '(function () { $r = catfish_rng(20261029); $h = 0; for ($i = 0; $i < 200000; $i++) if (catfish_pet_yarn_hit(50, $r())) $h++; $p = $h / 200000; return (abs($p - 0.02) < 0.002 ? "2pct" : "off:$p") . "/" . (catfish_pet_yarn_hit(50, 0.0) ? "hit" : "miss") . "/" . (catfish_pet_yarn_hit(50, 0.99) ? "hit" : "miss") . "/" . (catfish_pet_yarn_hit(0, 0.0) ? "hit" : "miss"); })()')" "2pct/hit/miss/miss"
clean_pets; metaset '$m["slotn"]=["ceiling","rod"];'; for k in matryoshka_mice maneki_neko tide_pool_jar; do own $k; done
cfapi -d do=petslot -d slot=1 -d item=matryoshka_mice >/dev/null; cfapi -d do=petslot -d slot=2 -d item=maneki_neko >/dev/null; cfapi -d do=petslot -d slot=3 -d item=tide_pool_jar >/dev/null
dbx "UPDATE catfish_items SET slotted_at=$(( $(date +%s) - 4000 )) WHERE user_id=$UID_"; dbx "UPDATE catfish_state SET yarn=0 WHERE user_id=$UID_"
ok "yarn: a winning roll gives 1 Yarn (matryoshka mice), and counts in the week" "$(pp 'echo json_encode(catfish_pet_use('$UID_', 1, [], 0.0)[2]);' | grep -o '"yarn":[01]')/$(dbv "SELECT yarn FROM catfish_state WHERE user_id=$UID_")/$(metaget '$m["py"]["n"]')" '"yarn":1/1/1'
ok "yarn weekly cap: a second winning roll in the same ISO week (another thing) pays no Yarn" "$(pp 'echo json_encode(catfish_pet_use('$UID_', 2, [], 0.0)[2]);' | grep -o '"yarn":[01]')/$(dbv "SELECT yarn FROM catfish_state WHERE user_id=$UID_")/$(metaget '$m["py"]["n"]')" '"yarn":0/1/1'
ok "yarn: a losing roll gives nothing" "$(pp 'echo json_encode(catfish_pet_use('$UID_', 3, [], 0.99)[2]);' | grep -o '"yarn":[01]')/$(dbv "SELECT yarn FROM catfish_state WHERE user_id=$UID_")" '"yarn":0/1'
ok "yarn weekly cap: next ISO week it can pay again" "$(metaset '$m["py"]=["week"=>"2020-W01","n"=>1];'; dbx "UPDATE catfish_items SET last_used=0 WHERE user_id=$UID_"; dbx "UPDATE catfish_state SET meta=json_set(meta, '\$.pa', json('{}')) WHERE user_id=$UID_"; pp 'echo json_encode(catfish_pet_use('$UID_', 2, [], 0.0)[2]);' | grep -o '"yarn":[01]')/$(dbv "SELECT yarn FROM catfish_state WHERE user_id=$UID_")" '"yarn":1/2'
ok "yarn: the API never takes a roll (no 'roll' parameter is read)" "$(grep -c 'POST\[.roll.\]' $GAME/catfish_api.php $GAME/catfish.php | tr '\n' ' ')" "$GAME/catfish_api.php:0 $GAME/catfish.php:0 "

# hints: text only, and they never write cat_book (book12 / book_half pay Petals from those rows)
clean_pets; metaset '$m["slotn"]=["ceiling","rod"];'; for k in parrot_perch mirage_mirror singing_bowl shadow_puppet_screen; do own $k; done
dbx "INSERT OR IGNORE INTO catfish_items (user_id,item_key,got_at,last_used,slotted_at) SELECT $UID_, k, 'x', 0, 0 FROM (SELECT 'conch_shell' AS k UNION SELECT 'driftwood_board' UNION SELECT 'bell_lure' UNION SELECT 'bonsai' UNION SELECT 'hammock_net') "
cfapi -d do=petslot -d slot=1 -d item=singing_bowl >/dev/null; cfapi -d do=petslot -d slot=3 -d item=parrot_perch >/dev/null; cfapi -d do=petslot -d slot=4 -d item=mirage_mirror >/dev/null
dbx "UPDATE catfish_items SET slotted_at=$(( $(date +%s) - 4000 )) WHERE user_id=$UID_"
metaset '$m["pa"]=["day"=>"'$TODAY'", "n"=>0, "kmin"=>0];'
BOOK0=$(dbv "SELECT COUNT(*) FROM cat_book WHERE user_id=$UID_"); COINS0=$(coins)
R=$(cfapi -d do=petuse -d slot=1); HB="$(echo "$R" | jp ok):$(echo "$R" | jp hint)"
R=$(cfapi -d do=petuse -d slot=3); HP="$(echo "$R" | jp ok):$(echo "$R" | jp hint)"
R=$(cfapi -d do=petuse -d slot=4); HM="$(echo "$R" | jp ok):$(echo "$R" | jp hint)"
cfapi -d do=petslot -d slot=3 -d item=shadow_puppet_screen >/dev/null; dbx "UPDATE catfish_items SET slotted_at=$(( $(date +%s) - 4000 )) WHERE user_id=$UID_ AND item_key='shadow_puppet_screen'"
R=$(cfapi -d do=petuse -d slot=3); HS="$(echo "$R" | jp ok):$(echo "$R" | jp hint)"
echo "     hint texts: $HB | $HP | $HM | $HS"
ok "hints: Singing Bowl previews this week's score for the theme, with the ribbon it would earn" "$(echo "$HB" | grep -c '^true:.* would score [0-9]* for ".*" right now: .*\.$')" 1
ok "hints: Parrot Perch names one coat of tomorrow's shelter" "$(echo "$HP" | grep -c '^true:The parrot whispers: tomorrow the shelter has a [a-z]* [a-z]* cat\.$')" 1
ok "hints: Mirage Mirror says whether tomorrow's shelter has an uncommon cat or better" "$(echo "$HM" | grep -c "^true:The mirror .*tomorrow's shelter")" 1
ok "hints: Shadow-puppet Screen names one coat you have never seen" "$(echo "$HS" | grep -c '^true:The shadows show a coat you have never seen: [a-z]* [a-z]*\.$')" 1
ok "hints: none of the four wrote a cat_book row, and Petals are unchanged" "$(dbv "SELECT COUNT(*) FROM cat_book WHERE user_id=$UID_")/$(coins)" "$BOOK0/$COINS0"
ok "hints: each is a use of the day (4 of 4) and sets its own cooldown" "$(metaget '$m["pa"]["n"]')/$(dbv "SELECT COUNT(*) FROM catfish_items WHERE user_id=$UID_ AND last_used > 0")" "4/4"
ok "hints: the last hint of each placed thing is kept for the panel (bowl, mirror and screen; the parrot was taken off the sill)" "$(pagew3; grep -o 'class="cfpethint"' $W/w3.html | wc -l | tr -d ' ')" 3
ok "hints (pure text): the unseen coat is one the Cat Book lacks, tomorrow's coat is one of tomorrow's three" "$(pp '$u = '$UID_'; $m = catfish_state($u)["meta"]; $t = catfish_pet_hint($u, "unseen_coat", $m, null); preg_match("/never seen: (\w+) (\w+)\./", $t, $x); $seen = false; foreach (catfish_book($u) as $b) if ($b[0] === $x[2] && $b[1] === $x[1]) $seen = true; $tm = catfish_pet_hint($u, "tomorrow_coat", $m, null); preg_match("/has a (\w+) (\w+) cat\./", $tm, $y); $in = false; foreach (catfish_pet_tomorrow($u, $m) as $c) if ($c["colour"] === $y[1] && $c["pattern"] === $y[2]) $in = true; echo ($seen ? "SEEN" : "unseen"), "/", ($in ? "tomorrow" : "NOT");')" "unseen/tomorrow"

# special effects: rain, happy cats, the talking drum's free shelter reroll (counts toward the daily cap)
clean_pets; metaset '$m["slotn"]=["ceiling","rod"];'; dbx "INSERT OR IGNORE INTO catfish_items (user_id,item_key,got_at,last_used,slotted_at) VALUES ($UID_,'rain_stick','x',0,0),($UID_,'tea_tray','x',0,0),($UID_,'talking_drum','x',0,0),($UID_,'hammock_net','x',0,0),($UID_,'bonsai','x',0,0),($UID_,'chai_stall_sign','x',0,0),($UID_,'calabash_bowl','x',0,0),($UID_,'koi_kite_lure','x',0,0),($UID_,'brass_lantern','x',0,0)"
metaset '$m["slots"]=["3"=>"rain_stick","7"=>"tea_tray","6"=>"talking_drum"]; $m["pa"]=["day"=>"'$TODAY'", "n"=>0, "kmin"=>0]; unset($m["rain"], $m["roll"]);'
dbx "UPDATE catfish_items SET slotted_at=$(( $(date +%s) - 4000 )) WHERE user_id=$UID_"; dbx "UPDATE catfish_state SET last_tick=$(date +%s) WHERE user_id=$UID_"
R=$(cfapi -d do=petuse -d slot=3)
ok "rain: the Rain Stick pays a pop and starts an hour of rain (a rain span on the window, a new scene key)" "$(echo "$R" | jp ok)/$(echo "$R" | jp stage_html | grep -c 'class="cfrain"')/$(metaget '(int)($m["rain"] > time() + 3000 && $m["rain"] <= time() + 3601)')" "true/1/1"
R=$(cfapi -d do=petuse -d slot=7)
ok "happy cats: the Tea Tray answers happy=true (catfish.js hops every cat) and pays a pop" "$(echo "$R" | jp ok)/$(echo "$R" | jp happy)" "true/true"
dbx "UPDATE catfish_items SET last_used=0 WHERE user_id=$UID_"; metaset '$m["pa"]["n"]=0; $m["pa"]["kmin"]=0;'
SH0=$(pp 'echo json_encode(array_map(fn($c) => $c["colour"] . " " . $c["pattern"], catfish_shelter_now('$UID_')));')
R=$(cfapi -d do=petuse -d slot=6 -d shelter=1)
ok "talking drum: a free reroll of the chosen shelter spot (only that spot changes), counted toward the 3 a day" "$(echo "$R" | jp ok)/$(metaget '$m["roll"]["n"][1]')/$(pp 'echo json_encode(array_map(fn($c) => $c["colour"] . " " . $c["pattern"], catfish_shelter_now('$UID_')));' | php -r '$a = json_decode(file_get_contents("php://stdin"), true); $b = json_decode($argv[1], true); echo ($a[0] === $b[0] && $a[2] === $b[2]) ? "others same" : "moved";' "$SH0")" "true/1/others same"
dbx "UPDATE catfish_items SET last_used=0 WHERE user_id=$UID_"; metaset '$m["pa"]["n"]=0; $m["roll"]["n"]=[0,3,0];'
ok "talking drum: a spot that has had its 3 rerolls today is refused" "$(cfapi -d do=petuse -d slot=6 -d shelter=1 | jp ok)" false

# the scene: depth order, sprites or placeholders, no inline style, positions = room-layout.json
cp $PETART/cf-pet-conch_shell.png $GAME/assets/img/catfish/ 2>/dev/null
PETS='["slots" => [1 => "conch_shell", 2 => "amphora", 3 => "bonsai", 4 => "chai_stall_sign", 5 => "steel_pan_chime", 6 => "hammock_net", 7 => "calabash_bowl", 8 => "lemon_on_a_string"], "ready" => [2 => true, 5 => false], "rain" => true, "bird_x" => 2]'
SC='[["id"=>1,"name"=>"Pip","colour"=>"ginger","pattern"=>"tabby","eyes"=>"amber","ears"=>"folded","tail"=>"bobtail","seed"=>11,"mood"=>"hyper"],["id"=>2,"name"=>"Dot","colour"=>"lilac","pattern"=>"solid","eyes"=>"odd","ears"=>"upright","tail"=>"long","seed"=>12,"mood"=>"lazy"],["id"=>3,"name"=>"Bo","colour"=>"black","pattern"=>"calico","eyes"=>"blue","ears"=>"upright","tail"=>"long","seed"=>13,"mood"=>"hyper"]]'
SH=$(cfx $FULL "catfish_stage_html($SC, $SC[0], [], false, false, $PETS)")
ok "stage: all eight things are on the stage, in their spot classes (shelf, shelf, sill, frame, ceiling, floor, floor, rod charm)" "$(echo "$SH" | grep -o 'cfpet cfpet-s[1-8] cfpi-[a-z_]*' | sed 's/cfpet cfpet-//;s/ cfpi-/=/' | tr '\n' ' ')" "s6=hammock_net s7=calabash_bowl s1=conch_shell s2=amphora s3=bonsai s4=chai_stall_sign s5=steel_pan_chime s8=lemon_on_a_string "
ok "stage: a passive thing is a plain span, an active one a button with data-slot and a ready/not-ready label (is-ready / is-wait)" "$(echo "$SH" | grep -o '<button type="button" class="cfpet cfpet-s2 cfpi-amphora is-ready" data-slot="2" data-item="amphora" aria-label="Amphora: ready, tap to use">\|<button type="button" class="cfpet cfpet-s5 cfpi-steel_pan_chime is-wait" data-slot="5" data-item="steel_pan_chime" aria-label="Steel-pan Chime: not ready yet">' | wc -l | tr -d ' ')/$(echo "$SH" | grep -o '<span class="cfpet cfpet-s1 cfpi-conch_shell cfpc-cats_listen" data-item="conch_shell" aria-hidden="true">' | wc -l | tr -d ' ')/$(echo "$SH" | grep -o '<button' | wc -l | tr -d ' ')" "2/1/5"
ok "stage: floor things come before every cat in the markup (cats stay in front), wall things before the wand and the fish; the rod charm after the rod line" "$(php -r '$h = file_get_contents("php://stdin"); $p = fn($n) => strpos($h, $n); echo ($p("cfpet-s6") < $p("cfspot") && $p("cfpet-s7") < $p("cfactive") && $p("cfpet-s5") < $p("cfswand") && $p("cfpet-s1") < $p("cfsdrop") && $p("cfsline") < $p("cfpet-s8") && $p("cfpet-s8") < $p("cfsdrop")) ? "ordered" : "WRONG";' <<< "$SH")" ordered
mkdir -p $W/art10; cp $FULL/cf-room.png $W/art10/; cp $PETART/cf-pet-conch_shell.png $W/art10/
SH10=$(cfx $W/art10 "catfish_stage_html($SC, $SC[0], [], false, false, $PETS)")
ok "stage: no PNG yet = a red-outlined placeholder with an emoji (all 8 here); the one PNG that exists is an image at its slot size (20 x 24 for the conch) and the other 7 stay placeholders" "$(echo "$SH" | grep -o 'class="cfpetph"' | wc -l | tr -d ' ')/$(echo "$SH10" | grep -o 'class="cfpetph"' | wc -l | tr -d ' ')/$(echo "$SH10" | grep -o '<img class="cfimg cfpetimg" src="[^"]*cf-pet-conch_shell.png[^"]*" alt="" width="20" height="24">' | wc -l | tr -d ' ')" "8/7/1"
ok "stage: no inline style, rain span and the Weaver-bird class are there, nothing is scaled" "$(echo "$SH" | sed 's#<script type="application/json" id="cf-frames">[^<]*</script>##' | grep -c 'style=')/$(echo "$SH" | grep -c 'class="cfrain"')/$(echo "$SH" | grep -c 'cfstage cfpr-rain cfpr-birdx2')" "0/1/1"
ok "stage: with no room things the stage markup is exactly what it was (byte for byte)" "$(cfx $FULL "catfish_stage_html($SC, $SC[0], [], false, false, [])" | md5sum | cut -c1-12)" "$(cfx $FULL "catfish_stage_html($SC, $SC[0], [])" | md5sum | cut -c1-12)"
python3 -I - "aseprite-source/catfish/room-layout.json" "$GAME/assets/catfish.css" "$GAME/includes/data/catfish_pets.php" <<'P'
import sys, json, re
j = json.load(open(sys.argv[1])); css = open(sys.argv[2]).read(); data = open(sys.argv[3]).read()
bad = []
slots = j['pet_slots']['slots']
if [s['no'] for s in slots] != list(range(1, 9)): bad.append('slot numbers')
def prop(body, p):
    m = re.search(r'(?:^|[ ;])' + p + r': (-?\d+)(?:px)?[ ;]', body + ' ')
    return int(m.group(1)) if m else None
for s in slots:
    m = re.search(r'\.cfpet-s%d \{([^}]*)\}' % s['no'], css)
    if not m: bad.append('no css for slot %d' % s['no']); continue
    got = (prop(m.group(1), 'left'), prop(m.group(1), 'top'), prop(m.group(1), 'width'), prop(m.group(1), 'height'))
    if got != (s['x'], s['y'], s['w'], s['h']): bad.append('slot %d css %s != json %s' % (s['no'], got, (s['x'], s['y'], s['w'], s['h'])))
    d = re.search(r"\['no' => %d, 'key' => '([a-z-]+)'.*?'w' => (\d+), 'h' => (\d+)\]" % s['no'], data)
    if not d or d.group(1) != s['key'] or (int(d.group(2)), int(d.group(3))) != (s['w'], s['h']): bad.append('slot %d data %s' % (s['no'], d and d.groups()))
    if s['x'] < 0 or s['y'] < 0 or s['x'] + s['w'] > 320 or s['y'] + s['h'] > 200: bad.append('slot %d off the room' % s['no'])
# the ceiling thing sits between the fish strings (x 118 and 170); the floor things are out of the play zone's cats (cats are drawn over them)
c = [s for s in slots if s['key'] == 'ceiling'][0]
if not (c['x'] > 118 and c['x'] + c['w'] <= 170): bad.append('ceiling not between the fish strings')
print('ok   pet_slots in room-layout.json = the .cfpet-sN CSS rectangles = the slot sizes in the data file' if not bad else 'FAIL pet_slots: ' + '; '.join(bad))
P

# --- the room things in a real browser (tests/catfish_pets.js; skipped without playwright): all 8 spots filled with the real sprites, a ready Chime tapped on the stage, the Room things panel in the hub
if node -e "require('playwright')" 2>/dev/null; then
  clean_pets; cp $PETART/cf-pet-*.png $GAME/assets/img/catfish/
  for k in amphora conch_shell bonsai chai_stall_sign steel_pan_chime hammock_net calabash_bowl lemon_on_a_string; do own $k; done
  metaset '$m["slotn"]=["ceiling","rod"]; $m["slots"]=["1"=>"amphora","2"=>"conch_shell","3"=>"bonsai","4"=>"chai_stall_sign","5"=>"steel_pan_chime","6"=>"hammock_net","7"=>"calabash_bowl","8"=>"lemon_on_a_string"];'
  dbx "UPDATE catfish_items SET slotted_at=$(( $(date +%s) - 7200 )) WHERE user_id=$UID_"; dbx "UPDATE catfish_state SET last_tick=$(date +%s) WHERE user_id=$UID_"
  PETOUT=$(SHOTS=${PETSHOTS:-} NODE_PATH=${NODE_PATH:-} node tests/catfish_pets.js $BASE 2>&1); echo "$PETOUT"
else echo "ok   pets browser pass: skipped (no playwright)"; fi
dbx "DELETE FROM settings WHERE name LIKE 'catfish_pet_%'"

# --- migration: the table and the shops are made on demand
dbx "DROP TABLE catfish_items"; curl -s -b $W/p -o /dev/null -w '' $BASE/catfish.php
ok "migration: a world without the catfish_items table gets it on the next Cat Fish page view" "$(dbv "SELECT COUNT(*) FROM catfish_items")" 0
dbx "DELETE FROM shops WHERE slug='oc-pet-shop'"; dbx "DELETE FROM settings WHERE name='petshops220'"; curl -s -b $W/p -o /dev/null $BASE/games.php
ok "migration: a missing pet shop is made again by the next page view, the flag is set, and nothing is doubled" "$(dbv "SELECT COUNT(*) FROM shops WHERE shop_type='pets'")/$(dbv "SELECT value FROM settings WHERE name='petshops220'")/$(dbv "SELECT COUNT(*) FROM npcs WHERE slug='captain-pipi-shellback'")" "11/1/1"
rm -rf "${GAME:?}/assets/img/catfish"
curl -s -b $W/p $BASE/catfish.php > $W/noart.html
ok "page without art: emoji heading, emoji rod, no room, no icons, no book heads" "$(grep -c '<h1>🐱 Cat Fish</h1>' $W/noart.html)$(grep -c 'class="cfrod" ' $W/noart.html)$(grep -c 'class="cfroom"\|cf-ico-\|cf-bookhead-\|cfbanner\|cfrod-art\|cfstage\|cfactive' $W/noart.html)" "110"

# cleanup
dbx "DELETE FROM settings WHERE name IN ('catfish_open')"
