#!/bin/bash
# v1.4.0: Seed Spitting (physics round, server re-scores) and Worm Hunting (layers, wandering worms). Run on a fresh walk.sh install.
GAME=$1; PORT=$2; ROUTER=$3; BASE=http://127.0.0.1:$PORT
php -d session.save_path=/tmp -S 127.0.0.1:$PORT -t $GAME $ROUTER >/tmp/g140-php.log 2>&1 & PID=$!; sleep 1
trap "kill $PID 2>/dev/null" EXIT
csrf() { grep -o 'name="csrf" value="[^"]*"' "$1" | head -1 | sed 's/.*value="\([^"]*\)".*/\1/'; }
db() { php -r '$p=new PDO("sqlite:'$GAME'/data/game.sqlite"); foreach($p->query($argv[1])->fetchAll(PDO::FETCH_NUM) as $r) echo implode(" | ",$r),"\n";' "$1"; }
dbx() { php -r '$p=new PDO("sqlite:'$GAME'/data/game.sqlite"); $p->exec($argv[1]);' "$1"; }
C=/tmp/g140-ck; rm -f $C
curl -s -c $C -b $C $BASE/login.php > /tmp/g1.html; curl -s -c $C -b $C -X POST $BASE/login.php --data-urlencode "csrf=$(csrf /tmp/g1.html)" -d username=sprout -d 'password=TestPass123!' -o /dev/null
UID_=$(db "SELECT id FROM users WHERE username='sprout'")
# post to a page; print the newest message-log entries (text only)
gp() { local pg=$1; shift; curl -s -c $C -b $C "$BASE/$pg" > /tmp/g0.html; curl -s -c $C -b $C -X POST "$BASE/$pg" --data-urlencode "csrf=$(csrf /tmp/g0.html)" "$@" -o /dev/null; curl -s -c $C -b $C "$BASE/$pg" > /tmp/g1.html; grep -oE '<li class="ml [a-z]+ new">.{0,260}' /tmp/g1.html | sed 's/<small class="mlwhen">.*//; s/<[^>]*>/ /g' | head -${LINES_:-2}; }
state() { db "SELECT state FROM game_state WHERE user_id=$UID_ AND game='$1'"; }
jq_() { php -r '$s=json_decode($argv[1],true); echo json_encode($s[$argv[2]] ?? null);' "$1" "$2"; }

echo "== PHP/JS physics parity (200 random shots)"
php -r 'require "'$GAME'/includes/games.php"; mt_srand(7); $o=[]; for($i=0;$i<200;$i++){ $a=mt_rand(5,85);$p=mt_rand(0,100);$w=mt_rand(-90,90);$g=mt_rand(0,6);$n=mt_rand(0,6); $o[]=[$a,$p,$w,$g,$n,spit_sim($a,$p,$w,$g,$n)[0]]; } echo json_encode(["P"=>SPIT_PHYS,"c"=>$o]);' > /tmp/g140-par.json
cat > /tmp/g140-par.js <<'JSEOF'
const fs=require('fs'); const src=fs.readFileSync(process.argv[2],'utf8'); const d=JSON.parse(fs.readFileSync('/tmp/g140-par.json','utf8'));
const m=src.match(/function clamp[\s\S]*?\n  function init/); const code=m[0].replace(/function init$/,'');
const f=new Function(code+';return sim;')(); let bad=0;
for(const [a,p,w,g,n,mm] of d.c){ const r=f(d.P,a,p,w,g,n,false).mm; if(r!==mm){bad++; if(bad<4)console.log('MISMATCH',a,p,w,g,n,mm,r);} }
console.log('mismatches:',bad,'of',d.c.length);
JSEOF
node /tmp/g140-par.js $GAME/assets/spit.js

echo "== spit: start / early fire / bad token / valid fire"
db "SELECT 'plays used '||COUNT(*) FROM game_scores WHERE user_id=$UID_ AND game='spit'"
curl -s -b $C $BASE/spit.php | grep -oE 'Load a seed|Quick spit \(no aiming\)' | tr '\n' ';'; echo
LINES_=1 gp spit.php -d do=fire -d tok=x -d angle=40 -d power=70
LINES_=1 gp spit.php -d do=start
S=$(state spit); TOK=$(jq_ "$S" tok | tr -d '"'); WIND=$(jq_ "$S" wind); echo "round: wind $WIND gritmod $(jq_ "$S" grit) nimmod $(jq_ "$S" nim) keys: $(php -r 'echo implode(",",array_keys(json_decode($argv[1],true)));' "$S")"
echo "page shows game: $(grep -c 'class="spitgame"' /tmp/g1.html) data-phys: $(grep -c 'data-phys=' /tmp/g1.html)"
echo "-- starting again keeps the same round:"; LINES_=1 gp spit.php -d do=start; [ "$(jq_ "$(state spit)" tok | tr -d '"')" = "$TOK" ] && echo same-token
echo "-- too quick:"; LINES_=1 gp spit.php -d do=fire -d tok=$TOK -d angle=40 -d power=70
db "SELECT 'round still there: '||COUNT(*) FROM game_state WHERE user_id=$UID_ AND game='spit'"
echo "-- old token:"; LINES_=1 gp spit.php -d do=fire -d tok=deadbeef -d angle=40 -d power=70
sleep 1.2
C0=$(db "SELECT coins FROM users WHERE id=$UID_")
echo "-- 5 parallel fires with the same token (one may score):"
curl -s -c $C -b $C "$BASE/spit.php" > /tmp/g0.html; T=$(csrf /tmp/g0.html)
PIDS=""; for i in 1 2 3 4 5; do curl -s -b $C -X POST "$BASE/spit.php" --data-urlencode "csrf=$T" -d do=fire -d tok=$TOK -d angle=38 -d power=95 -o /dev/null & PIDS="$PIDS $!"; done; wait $PIDS; PIDS=""
echo "score rows: $(db "SELECT COUNT(*) FROM game_scores WHERE user_id=$UID_ AND game='spit'")"
SC=$(db "SELECT score FROM game_scores WHERE user_id=$UID_ AND game='spit' ORDER BY id DESC LIMIT 1")
EXP=$(php -r 'require "'$GAME'/includes/games.php"; echo spit_sim(38,95,(int)$argv[1],(int)$argv[2],(int)$argv[3])[0];' -- $WIND $(jq_ "$S" grit) $(jq_ "$S" nim))
echo "score $SC expected(server formula) $EXP"
CM=$(php -r 'echo $argv[1]/10;' $SC); WANT=$(php -r '$c=$argv[1]/10; echo $c>=60?30:($c>=45?15:($c>=30?5:0));' $SC)
echo "coins +$(( $(db "SELECT coins FROM users WHERE id=$UID_") - C0 )) (expected +$WANT for $CM cm)"
db "SELECT 'round row left: '||COUNT(*) FROM game_state WHERE user_id=$UID_ AND game='spit'"
echo "-- fire again with the used token:"; LINES_=1 gp spit.php -d do=fire -d tok=$TOK -d angle=38 -d power=95
echo "score rows still: $(db "SELECT COUNT(*) FROM game_scores WHERE user_id=$UID_ AND game='spit'")"

echo "== spit: second round fires, third is the quick spit taking over a loaded seed, fourth refused"
LINES_=1 gp spit.php -d do=start >/dev/null; S=$(state spit); TOK=$(jq_ "$S" tok | tr -d '"'); sleep 1.2
LINES_=1 gp spit.php -d do=fire -d tok=$TOK -d angle=45 -d power=100 >/dev/null; echo "rows: $(db "SELECT COUNT(*) FROM game_scores WHERE user_id=$UID_ AND game='spit'")"
LINES_=1 gp spit.php -d do=start >/dev/null; echo "loaded: $(db "SELECT COUNT(*) FROM game_state WHERE user_id=$UID_ AND game='spit'")"
echo "-- 4th start while loaded one is live? plays left: $(grep -oE '[0-9]+ go(es)? left' /tmp/g1.html | head -1)"
gp spit.php >/dev/null; LINES_=1 gp spit.php; echo "(bare POST = quick spit takes over the loaded seed)"
echo "rows: $(db "SELECT COUNT(*) FROM game_scores WHERE user_id=$UID_ AND game='spit'") live: $(db "SELECT COUNT(*) FROM game_state WHERE user_id=$UID_ AND game='spit'")"
echo "-- fourth:"; LINES_=1 gp spit.php -d do=start; LINES_=1 gp spit.php
echo "rows: $(db "SELECT COUNT(*) FROM game_scores WHERE user_id=$UID_ AND game='spit'") (cap 3)"

echo "== worms: layers"
dbx "DELETE FROM game_scores WHERE user_id=$UID_ AND game='worms'; DELETE FROM game_state WHERE user_id=$UID_ AND game='worms'"
mkboard() { php -r '$c=array_fill(0,36,"empty"); foreach(json_decode($argv[1],true) as $k=>$v) $c[(int)$k]=$v; echo json_encode(["cells"=>$c,"dug"=>new stdClass,"digs"=>(int)$argv[2],"score"=>0,"found"=>new stdClass,"seed"=>12345,"step"=>0,"loose"=>new stdClass,"shiver"=>null,"last"=>null]);' "$1" "$2"; }
setboard() { dbx "DELETE FROM game_state WHERE user_id=$UID_ AND game='worms'"; dbx "INSERT INTO game_state (user_id,game,state,updated_at) VALUES ($UID_,'worms','$(mkboard "$1" "$2")','2026-10-16 00:00:00')"; }
setboard '{"0":"gem","5":"worm"}' 5
LINES_=1 gp worms.php -d do=dig -d cell=0
S=$(state worms); echo "after tap 1: digs $(jq_ "$S" digs) loose $(jq_ "$S" loose) dug $(jq_ "$S" dug) score $(jq_ "$S" score)  loose button: $(grep -c 'class="soil loose' /tmp/g1.html)"
LINES_=1 gp worms.php -d do=dig -d cell=0
S=$(state worms); echo "after tap 2: digs $(jq_ "$S" digs) dug $(jq_ "$S" dug) score $(jq_ "$S" score) found $(jq_ "$S" found)"
echo "-- a deep find on the LAST dig is just collected:"
setboard '{"0":"gem"}' 1; LINES_=1 gp worms.php -d do=dig -d cell=0 | cut -c1-80
echo "score rows $(db "SELECT COUNT(*) FROM game_scores WHERE user_id=$UID_ AND game='worms'") last score $(db "SELECT score FROM game_scores WHERE user_id=$UID_ AND game='worms' ORDER BY id DESC LIMIT 1") (gem = 8)"

echo "== worms: wandering (worm_wander=100, one worm with room)"
dbx "INSERT OR REPLACE INTO settings (name,value) VALUES ('worm_wander','100')"
run_wander() { setboard '{"14":"worm"}' 9; gp worms.php -d do=dig -d cell=0 >/dev/null; gp worms.php -d do=dig -d cell=35 >/dev/null; S=$(state worms); php -r '$s=json_decode($argv[1],true); $w=array_keys($s["cells"],"worm"); echo "worm at ",implode(",",$w)," shiver ",json_encode($s["shiver"])," step ",$s["step"],"\n";' "$S"; echo "shivering button: $(grep -c 'soil shiver' /tmp/g1.html)"; }
run_wander; run_wander
echo "(identical lines above = deterministic from the board seed)"
dbx "INSERT OR REPLACE INTO settings (name,value) VALUES ('worm_wander','0')"
setboard '{"14":"worm"}' 9; gp worms.php -d do=dig -d cell=0 >/dev/null; gp worms.php -d do=dig -d cell=35 >/dev/null; echo "wander off: worm stays at $(php -r '$s=json_decode($argv[1],true); echo implode(",",array_keys($s["cells"],"worm"));' "$(state worms)")"
dbx "DELETE FROM settings WHERE name='worm_wander'"

echo "== worms: 5 parallel climb-outs pay once"
setboard '{"1":"worm","2":"worm"}' 9; gp worms.php -d do=dig -d cell=1 >/dev/null; gp worms.php -d do=dig -d cell=2 >/dev/null
curl -s -c $C -b $C "$BASE/worms.php" > /tmp/g0.html; T=$(csrf /tmp/g0.html); R0=$(db "SELECT COUNT(*) FROM game_scores WHERE user_id=$UID_ AND game='worms'"); CO=$(db "SELECT coins FROM users WHERE id=$UID_")
PIDS=""; for i in 1 2 3 4 5; do curl -s -b $C -X POST "$BASE/worms.php" --data-urlencode "csrf=$T" -d do=stop -o /dev/null & PIDS="$PIDS $!"; done; wait $PIDS; PIDS=""
echo "new score rows: $(( $(db "SELECT COUNT(*) FROM game_scores WHERE user_id=$UID_ AND game='worms'") - R0 )) coins +$(( $(db "SELECT coins FROM users WHERE id=$UID_") - CO )) (2 worms x 3 = 6)"

echo "== in-place pages"
for p in mushroom letters fair worms memory spit; do curl -s -b $C $BASE/$p.php | grep -q '<body[^>]* data-ajax' && echo "$p.php data-ajax" || echo "$p.php RELOADS"; done
curl -s -b $C $BASE/spit.php | grep -c 'assets/spit.js'; curl -s -b $C $BASE/worms.php | grep -c 'assets/worms.js'; curl -s -b $C $BASE/memory.php | grep -c 'assets/spit.js'
echo "== php errors"; grep -iE 'fatal|warning|notice|deprecated' /tmp/g140-php.log || echo "(none)"
