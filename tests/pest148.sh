#!/bin/bash
# v1.4.8: Pest Patrol. Run on a fresh walk.sh install:  bash pest148.sh GAMEDIR PORT ROUTER
# The server makes the round and re-scores the taps; this checks start, too-quick, the page machine vs pest_sim(), a perfect round and
# its charm, the butterfly with and without a net, the daily cap and parallel finishes. Files go under $T (private, set P148_TMP to change).
GAME=$1; PORT=$2; ROUTER=$3; BASE=http://127.0.0.1:$PORT
HERE=$(cd "$(dirname "$0")" && pwd); T=${P148_TMP:-/tmp/claude-0/p148}; mkdir -p $T
php -d session.save_path=/tmp -S 127.0.0.1:$PORT -t $GAME $ROUTER >$T/p148-php.log 2>&1 & PID=$!; sleep 1
trap "kill $PID 2>/dev/null" EXIT
csrf() { grep -o 'name="csrf" value="[^"]*"' "$1" | head -1 | sed 's/.*value="\([^"]*\)".*/\1/'; }
db() { php -r '$p=new PDO("sqlite:'$GAME'/data/game.sqlite"); foreach($p->query($argv[1])->fetchAll(PDO::FETCH_NUM) as $r) echo implode(" | ",$r),"\n";' "$1"; }
dbx() { php -r '$p=new PDO("sqlite:'$GAME'/data/game.sqlite"); $p->exec($argv[1]);' "$1"; }
C=$T/p148-ck; rm -f $C
curl -s -c $C -b $C $BASE/login.php > $T/p1.html; curl -s -c $C -b $C -X POST $BASE/login.php --data-urlencode "csrf=$(csrf $T/p1.html)" -d username=sprout -d 'password=TestPass123!' -o /dev/null
UID_=$(db "SELECT id FROM users WHERE username='sprout'")
gp() { local pg=$1; shift; curl -s -c $C -b $C "$BASE/$pg" > $T/p0.html; curl -s -c $C -b $C -X POST "$BASE/$pg" --data-urlencode "csrf=$(csrf $T/p0.html)" "$@" -o /dev/null; curl -s -c $C -b $C "$BASE/$pg" > $T/p1.html; }
flash() { grep -oE '<li class="ml [a-z]+ new">.{0,300}' $T/p1.html | sed 's/<small class="mlwhen">.*//; s/<[^>]*>/ /g' | head -1; }
state() { db "SELECT state FROM game_state WHERE user_id=$UID_ AND game='pest'"; }
rows() { db "SELECT COUNT(*) FROM game_scores WHERE user_id=$UID_ AND game='pest'"; }
agets() { db "SELECT COALESCE(SUM(qty),0) FROM user_items ui JOIN items i ON i.id=ui.item_id WHERE ui.user_id=$UID_ AND i.slug='$1'"; }
# edit the live round: php code with $s = the round array
edit() { php -r '$p=new PDO("sqlite:'$GAME'/data/game.sqlite"); $s=json_decode($p->query("SELECT state FROM game_state WHERE user_id='$UID_' AND game=\"pest\"")->fetchColumn(),true); '"$1"' $q=$p->prepare("UPDATE game_state SET state=? WHERE user_id='$UID_' AND game=\"pest\""); $q->execute([json_encode($s)]);'; }
aged() { edit '$s["t0"]=microtime(true)-60;'; }   # pretend the round started a minute ago
fin() { gp pest.php -d do=finish -d tok=$1 --data-urlencode "taps=$2"; }
clear_() { dbx "DELETE FROM game_scores WHERE user_id=$UID_ AND game IN ('pest','pestcharm'); DELETE FROM game_state WHERE user_id=$UID_ AND game='pest'"; }
bot() { echo "$1" > $T/round.json; php $HERE/pest148_bot.php $GAME "$2" $T/round.json; }
jq_() { php -r '$s=json_decode($argv[1],true); echo json_encode($s[$argv[2]] ?? null);' "$1" "$2"; }
setn() { dbx "INSERT OR REPLACE INTO settings (name,value) VALUES ('$1','$2')"; }

echo "== page machine vs server pest_sim() (300 random rounds and tap lists)"
php $HERE/pest148_bot.php $GAME parity > $T/par.json; php -r 'require "'$GAME'/includes/pest.php"; echo json_encode(PEST_RULES);' > $T/rules.json
node $HERE/pest148_par.js $GAME/assets/pest.js $T/par.json $T/rules.json
echo "designs: $(php -r 'require "'$GAME'/includes/pest.php"; echo count(PEST_PLANTS), " (leaves ", min(PEST_PLANTS), "-", max(PEST_PLANTS), ")";')"

echo "== hub + rules + page wiring"
curl -s -b $C $BASE/games.php | grep -c 'pest.php' | sed 's/^/hub links to pest.php: /'
curl -s -b $C "$BASE/pest.php" | grep -oE 'Start patrol|[0-9]+ rounds? left today' | tr '\n' ';'; echo
curl -s -b $C "$BASE/pest.php?t=rules" | grep -oE 'Pest|Ladybird Lodge|Butterflies|Daily limit' | sort -u | tr '\n' ';'; echo
curl -s -b $C $BASE/pest.php | grep -q '<body[^>]* data-ajax' && echo "pest.php data-ajax" || echo "pest.php RELOADS"
echo "script tag on pest.php: $(curl -s -b $C $BASE/pest.php | grep -c 'assets/pest.js'), on spit.php: $(curl -s -b $C $BASE/spit.php | grep -c 'assets/pest.js')"
echo "settings: $(db "SELECT COUNT(*) FROM settings WHERE name LIKE 'pest_%'") stored (defaults apply when unset): plays $(php -r 'require "'$GAME'/includes/bootstrap.php"; echo setting("pest_plays_per_day"), " butterfly ", setting("pest_butterfly_pct"), "% charm ", setting("pest_charm_pct"), "% ", setting("pest_charm_per_day"), "/day";' 2>/dev/null)"

echo "== start, restart, too quick, bad token"
clear_; setn pest_butterfly_pct 0
gp pest.php -d do=start; S=$(state); TOK=$(jq_ "$S" tok | tr -d '"')
echo "round: design $(jq_ "$S" design) n $(jq_ "$S" n) dur $(jq_ "$S" dur) pests $(php -r 'echo count(json_decode($argv[1],true)["pests"]);' "$S") net $(jq_ "$S" net) bf $(jq_ "$S" bf)"
echo "game on page: $(grep -c 'class="pestgame"' $T/p1.html) data-round: $(grep -c 'data-round=' $T/p1.html) data-rules: $(grep -c 'data-rules=' $T/p1.html) t0 leaked into page: $(grep -c 't0' $T/p1.html)"
gp pest.php -d do=start; [ "$(jq_ "$(state)" tok | tr -d '"')" = "$TOK" ] && echo "start again keeps the same round: $(flash)"
echo "plays used (a live round counts): left says $(curl -s -b $C $BASE/games.php | grep -A4 'pest.php' | grep -oE '(In progress|[0-9]+ left|Done today)' | head -1)"
fin $TOK '[]'; echo "too quick: $(flash)"; echo "round still there: $(db "SELECT COUNT(*) FROM game_state WHERE user_id=$UID_ AND game='pest'") rows $(rows)"
aged; fin deadbeef '[]'; echo "old token: $(flash)"; echo "round still there: $(db "SELECT COUNT(*) FROM game_state WHERE user_id=$UID_ AND game='pest'")"

echo "== replayed scoring = server score (messy taps, junk entries, too many taps)"
S=$(state); O=$(bot "$S" perfect)
MESSY=$(php -r '$s=json_decode($argv[1],true); mt_srand(3); $t=[]; foreach($s["pests"] as $p){ $l=$p["k"]==="g"?$p["h"][0][1]:$p["l"]; $a=$p["k"]==="g"?$p["h"][0][0]:$p["t"]; if(mt_rand(0,3)) for($j=0;$j<($p["k"]==="a"?3:($p["k"]==="s"?2:1));$j++) $t[]=[$a+500+$j*150,$l]; } for($i=0;$i<6;$i++) $t[]=[mt_rand(0,$s["dur"]),mt_rand(0,$s["n"]-1)]; $t[]=[-5,0]; $t[]=[$s["dur"]+900,1]; $t[]=[100,99]; $t[]=["x",1]; $t[]=[5]; shuffle($t); echo json_encode($t);' "$S")
EXP=$(php -r 'require "'$GAME'/includes/pest.php"; $s=json_decode($argv[1],true); $t=pest_clean_taps($argv[2],$s["n"],$s["dur"]); echo pest_sim($s,$t)["score"];' "$S" "$MESSY")
C0=$(db "SELECT coins FROM users WHERE id=$UID_")
fin $TOK "$MESSY"
echo "score rows $(rows) stored $(db "SELECT score FROM game_scores WHERE user_id=$UID_ AND game='pest' ORDER BY id DESC LIMIT 1") expected $EXP; coins +$(( $(db "SELECT coins FROM users WHERE id=$UID_") - C0 )) (band $(php -r 'require "'$GAME'/includes/pest.php"; echo pest_coins((int)$argv[1]);' $EXP))"
echo "round row left: $(db "SELECT COUNT(*) FROM game_state WHERE user_id=$UID_ AND game='pest'")"
fin $TOK "$MESSY"; echo "again with the used token: $(flash); rows still $(rows)"
php -r 'require "'$GAME'/includes/pest.php"; echo "clean_taps keeps ", count(pest_clean_taps("[[1,0],[2,0],[3,0]]",9,30000)), " of 3 and caps at ", count(pest_clean_taps(json_encode(array_fill(0,500,[10,0])),9,30000)), " of 500\n";'

echo "== perfect round: no lost leaves, every pest flicked -> charm (pest_charm_pct 100, 1 a day)"
setn pest_charm_pct 100; setn pest_charm_per_day 1; clear_
dbx "DELETE FROM user_items WHERE item_id IN (SELECT id FROM items WHERE slug IN ('ladybird-charm','wing-scale'))"
gp pest.php -d do=start; S=$(state); TOK=$(jq_ "$S" tok | tr -d '"'); O=$(bot "$S" perfect)
TAPS=$(jq_ "$O" taps); SIM=$(jq_ "$O" sim); echo "bot: score $(jq_ "$SIM" score) lost $(jq_ "$SIM" lost) flicked $(jq_ "$SIM" flicked) leaves $(jq_ "$SIM" leaves) best combo $(jq_ "$SIM" best) perfect $(jq_ "$SIM" perfect)"
aged; fin $TOK "$TAPS"
echo "stored $(db "SELECT score FROM game_scores WHERE user_id=$UID_ AND game='pest' ORDER BY id DESC LIMIT 1") (sim $(jq_ "$SIM" score)); charm in satchel: $(agets ladybird-charm); charm rows today: $(db "SELECT COUNT(*) FROM game_scores WHERE user_id=$UID_ AND game='pestcharm'")"
echo "second perfect round the same day: no second charm (cap 1)"
gp pest.php -d do=start; S=$(state); TOK=$(jq_ "$S" tok | tr -d '"'); O=$(bot "$S" perfect); aged; fin $TOK "$(jq_ "$O" taps)"
echo "charms now $(agets ladybird-charm) (still 1), rows $(rows)"
echo "-- an imperfect round (no taps): leaves are eaten, no charm"
gp pest.php -d do=start; S=$(state); TOK=$(jq_ "$S" tok | tr -d '"'); O=$(bot "$S" none); echo "sim: score $(jq_ "$(jq_ "$O" sim)" score) lost $(jq_ "$(jq_ "$O" sim)" lost) perfect $(jq_ "$(jq_ "$O" sim)" perfect)"
dbx "DELETE FROM game_scores WHERE user_id=$UID_ AND game='pestcharm'"; aged; fin $TOK '[]'; echo "charms $(agets ladybird-charm) (unchanged 1)"

echo "== butterfly: with a bug net, and without (a perfect bot also taps the butterfly 1.5 s into its window)"
clear_; dbx "DELETE FROM user_items WHERE item_id IN (SELECT id FROM items WHERE slug='wing-scale')"
dbx "DELETE FROM user_items WHERE user_id=$UID_ AND item_id IN (SELECT id FROM items WHERE effects LIKE '%\"tool\":\"net\"%')"
setn pest_butterfly_pct 100; setn pest_charm_pct 0
bfround() {   # start a round; sets S TOK TAPS(with the butterfly tap) EXPNET EXPNO (server sim with / without a net)
  gp pest.php -d do=start; S=$(state); TOK=$(jq_ "$S" tok | tr -d '"'); O=$(bot "$S" perfect)
  TAPS=$(php -r '$o=json_decode($argv[1],true); $s=json_decode($argv[2],true); $t=$o["taps"]; $t[]=[$s["bf"][0]+1500,-1]; $t[]=[$s["bf"][0]+1700,-1]; usort($t,fn($a,$b)=>$a[0]<=>$b[0]); echo json_encode($t);' "$O" "$S")
  EXPNET=$(php -r 'require "'$GAME'/includes/pest.php"; $s=json_decode($argv[1],true); $s["net"]=1; echo pest_sim($s,json_decode($argv[2],true))["score"];' "$S" "$TAPS")
  EXPNO=$(php -r 'require "'$GAME'/includes/pest.php"; $s=json_decode($argv[1],true); $s["net"]=0; echo pest_sim($s,json_decode($argv[2],true))["score"];' "$S" "$TAPS")
}
last() { db "SELECT score FROM game_scores WHERE user_id=$UID_ AND game='pest' ORDER BY id DESC LIMIT 1"; }
bfround; echo "no net in satchel -> round net flag $(jq_ "$S" net), butterfly window $(jq_ "$S" bf); sim without net $EXPNO, with net $EXPNET"
aged; fin $TOK "$TAPS"
echo "no net: stored score $(last) (= $EXPNO), wing scales $(agets wing-scale); page says: $(grep -oE 'no bug net' $T/p1.html | head -1)"
NETID=$(db "SELECT id FROM items WHERE effects LIKE '%\"tool\":\"net\"%' ORDER BY id LIMIT 1")
dbx "INSERT INTO user_items (user_id,item_id,qty,got_at) VALUES ($UID_,$NETID,1,'2026-10-17 00:00:00')"
bfround; echo "bug net in satchel -> round net flag $(jq_ "$S" net)"
aged; fin $TOK "$TAPS"
echo "with net: stored score $(last) (= $EXPNET, which is $((EXPNET - EXPNO)) more than without), wing scales $(agets wing-scale) (a second tap on it does nothing)"
echo "-- butterfly tapped before its window does nothing"
bfround; EARLY=$(php -r '$s=json_decode($argv[1],true); echo $s["bf"][0]-800;' "$S"); aged; fin $TOK "[[$EARLY,-1]]"; echo "wing scales $(agets wing-scale) (still 1)"
setn pest_butterfly_pct 0

echo "== bruises: 3 bare taps drop a leaf (-15), a pest left chewing drops its leaf; the sim says so"
php -r 'require "'$GAME'/includes/pest.php"; $r=["n"=>8,"dur"=>30000,"pests"=>[],"bf"=>null,"net"=>0]; $a=pest_sim($r,[[1000,2],[1200,2],[1400,2]]); echo "3 bruises: lost ",$a["lost"]," score ",$a["score"]," (7 leaves x4 = 28, -15 => 13) bruises ",$a["bruises"],"\n"; $b=pest_sim($r,[[1000,2],[1020,2],[1200,2]]); echo "taps 20 ms apart count once: bruises ",$b["bruises"],"\n"; $r["pests"]=[["k"=>"c","t"=>1000,"l"=>3]]; $c=pest_sim($r,[]); echo "caterpillar left alone: lost ",$c["lost"]," leaves ",$c["leaves"],"\n"; $d=pest_sim($r,[[1100,3]]); echo "tap while it pops up (150 ms): ignored, still chewing; lost ",$d["lost"],"\n"; $e=pest_sim($r,[[1300,3]]); echo "flicked at 300 ms: flicked ",$e["flicked"]," lost ",$e["lost"]," score ",$e["score"],"\n"; $r["pests"]=[["k"=>"a","t"=>1000,"l"=>3]]; $f=pest_sim($r,[[1300,3],[1500,3],[1700,3]]); echo "aphids need 3 taps: flicked ",$f["flicked"]," score ",$f["score"],"\n";'

echo "== 3 a day cap (pest_plays_per_day default)"
clear_; setn pest_butterfly_pct 15; dbx "DELETE FROM settings WHERE name='pest_plays_per_day'"
for i in 1 2 3; do gp pest.php -d do=start; S=$(state); aged; fin "$(jq_ "$S" tok | tr -d '"')" '[]'; done
echo "rows $(rows) after 3 rounds"
gp pest.php -d do=start; echo "4th start: $(flash); live rounds: $(db "SELECT COUNT(*) FROM game_state WHERE user_id=$UID_ AND game='pest'"); button disabled on page: $(grep -c 'btn act" disabled' $T/p1.html)"

echo "== parallel finishes pay once"
clear_; setn pest_charm_pct 100; dbx "DELETE FROM user_items WHERE item_id IN (SELECT id FROM items WHERE slug='ladybird-charm')"; dbx "DELETE FROM settings WHERE name='pest_charm_per_day'"
gp pest.php -d do=start; S=$(state); TOK=$(jq_ "$S" tok | tr -d '"'); O=$(bot "$S" perfect); TAPS=$(jq_ "$O" taps); aged
curl -s -c $C -b $C "$BASE/pest.php" > $T/p0.html; CS=$(csrf $T/p0.html); C1=$(db "SELECT coins FROM users WHERE id=$UID_")
PIDS=""; for i in 1 2 3 4 5 6; do curl -s -b $C -X POST "$BASE/pest.php" --data-urlencode "csrf=$CS" -d do=finish -d tok=$TOK --data-urlencode "taps=$TAPS" -o /dev/null & PIDS="$PIDS $!"; done; wait $PIDS
echo "score rows $(rows) (1), coins +$(( $(db "SELECT coins FROM users WHERE id=$UID_") - C1 )) (band for $(jq_ "$(jq_ "$O" sim)" score)): $(php -r 'require "'$GAME'/includes/pest.php"; echo pest_coins((int)$argv[1]);' "$(jq_ "$(jq_ "$O" sim)" score)"), charms $(agets ladybird-charm) (1), round left $(db "SELECT COUNT(*) FROM game_state WHERE user_id=$UID_ AND game='pest'")"

echo "== lodge adds time (+1 s a level, up to +3)"
for L in 0 1 2 3 5; do
  dbx "DELETE FROM garden_buildings WHERE building='ladybird_lodge'"
  [ $L -gt 0 ] && dbx "INSERT INTO garden_buildings (plot_id, building, level, built_at) SELECT id, 'ladybird_lodge', $L, '2026-10-17 00:00:00' FROM plots WHERE user_id=$UID_"
  gp pest.php -d do=start; echo "lodge level $L -> round $(jq_ "$(state)" dur) ms"; dbx "DELETE FROM game_state WHERE user_id=$UID_ AND game='pest'"; dbx "DELETE FROM game_scores WHERE user_id=$UID_ AND game='pest'"
done
dbx "DELETE FROM garden_buildings WHERE building='ladybird_lodge'"
echo "== php errors"; grep -iE 'fatal|warning|notice|deprecated' $T/p148-php.log || echo "(none)"
