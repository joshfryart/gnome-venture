#!/bin/bash
# Security pass for 1.8.2 - 1.9.0 (native dialogs, aria/title changes, Treks 1.8.x): fresh SQLite install in a temp copy, then HTTP + engine tests.
# Covers: CSRF on every trek POST, AuthZ / forged slots, keys, items, tiles, whitelists, double-pay races (two logins at once), milestones after an admin
# reset, XSS (nasty gnome / item / story text on every changed page, data-replay / data-walk JSON, SVG), session one-shots, fuzzed inputs, CSP,
# admin pages, farming past the daily caps, and huge inputs.
# Usage: tests/security190.sh [GAME_COPY_DIR] [PORT] [ROUTER]      Prints "ok" / "FAIL" lines and "N FAILED" at the end (exit 1 if any).
HERE=$(cd "$(dirname "$0")" && pwd)
GAME=${1:-}; PORT=${2:-8795}; ROUTER=${3:-$HERE/router.php}
if [ -z "$GAME" ]; then T=$(mktemp -d); cp -r "$HERE/../game" "$T/game"; GAME=$T/game; fi
rm -f "$GAME/config.php"; rm -rf "$GAME/data"; mkdir -p "$GAME/data"
BASE=http://127.0.0.1:$PORT
LOG=$(mktemp); TMP=$(mktemp -d)
PHP_CLI_SERVER_WORKERS=6 php -d session.save_path=$TMP -d display_errors=1 -d error_reporting=-1 -S 127.0.0.1:$PORT -t "$GAME" "$ROUTER" >$LOG 2>&1 & PID=$!; sleep 1.5
trap "kill $PID 2>/dev/null" EXIT
echo "  diag: php $(php -r 'echo PHP_VERSION;') session: $(php -d session.save_path=$TMP -r 'foreach (["session.gc_probability","session.gc_divisor","session.gc_maxlifetime","session.use_strict_mode","session.sid_length","session.cookie_samesite","max_input_vars","output_buffering"] as $k) echo $k,"=",ini_get($k)," ";')"
H=$TMP/h.html; FAILN=0; JAR=$TMP/jar-x
ok()  { echo "  ok   $1"; }
bad() { echo "  FAIL $1${2:+  [$2]}"; FAILN=$((FAILN+1)); }
assert() { local n=$1; shift; if "$@"; then ok "$n"; else bad "$n"; fi; }
eq()  { [ "$1" = "$2" ]; }
csrf() { grep -o 'name="csrf" value="[^"]*"' "$1" | head -1 | sed 's/.*value="\([^"]*\)".*/\1/'; }
get()  { curl -s -c $JAR -b $JAR "$BASE/$1" -o $H -w '%{http_code}'; }
# a token from a page with a form that is not a trek page (trek pages hold one-shot session data)
tokof() { local t pg; for pg in account.php welcome.php; do t=$(curl -s -c $1 -b $1 "$BASE/$pg" | grep -o 'name="csrf" value="[^"]*"' | head -1 | sed 's/.*value="\([^"]*\)".*/\1/'); [ -n "$t" ] && break; done; echo "$t"; }
post() { local page=$1; shift; curl -s -c $JAR -b $JAR -X POST "$BASE/$page" --data-urlencode "csrf=$(tokof $JAR)" "$@" -o $H -w '%{http_code}'; }
postp() { local page=$1; shift; curl -s -c $JAR -b $JAR -X POST "$BASE/$page" --data-urlencode "csrf=$(csrf $H)" "$@" -o $H -w '%{http_code}'; }   # token from the page just fetched (install / register, before there is a login)
nocsrf() { local page=$1; shift; curl -s -c $JAR -b $JAR -X POST "$BASE/$page" "$@" -o $H -w '%{http_code}'; }
db()  { php -r '$p=new PDO("sqlite:'$GAME'/data/game.sqlite"); $p->exec("PRAGMA busy_timeout=20000"); foreach($p->query($argv[1])->fetchAll(PDO::FETCH_NUM) as $r) echo implode(" | ",$r),"\n";' "$1"; }
dbx() { php -r '$p=new PDO("sqlite:'$GAME'/data/game.sqlite"); $p->exec("PRAGMA busy_timeout=20000"); $p->exec($argv[1]);' "$1"; }
use() { JAR=$TMP/jar-$1; }
# diagnostics only (never fails): is the sprout login still good? Prints the cookie, whether its session file exists and how old it is, and the page code. Added to find a CI-only (PHP 8.5) lost-session problem.
diag_login() {
    local jar=$TMP/jar-sprout c v f; [ -f "$jar" ] || { echo "  diag[$1]: no sprout jar"; return 0; }
    v=$(grep garden_sess "$jar" | awk '{print $7}' | head -1); f=$TMP/sess_$v
    c=$(curl -s -b "$jar" "$BASE/account.php" -o /dev/null -w '%{http_code}')
    echo "  diag[$1]: sprout account.php=$c; cookie lines=$(grep -c garden_sess "$jar"); sid=${v:0:8}...; session file: $([ -f "$f" ] && echo "yes, $(( $(date +%s) - $(stat -c %Y "$f") ))s old, has uid: $(grep -c 'uid|' "$f")" || echo MISSING); session files in dir: $(ls $TMP | grep -c '^sess_'); elapsed ${SECONDS}s"
}
login() { JAR=$TMP/jar-$2; rm -f $JAR; curl -s -c $JAR -b $JAR "$BASE/login.php" -o $H; curl -s -c $JAR -b $JAR -X POST "$BASE/login.php" --data-urlencode "csrf=$(csrf $H)" -d username=$1 --data-urlencode "password=$3" -o /dev/null; }

# ---- the engine helper: php th.php <game> <user> <cmd> args... (runs inside trek_tx, like the game does)
cat > $TMP/th.php <<'PHP'
<?php
$_SERVER["SCRIPT_NAME"] = "/trek.php"; $G = $argv[1];
require "$G/includes/bootstrap.php"; require "$G/includes/trek.php";
$uid = (int)q_val("SELECT id FROM users WHERE username = ?", [$argv[2]]); $cmd = $argv[3]; $a = array_slice($argv, 4);
$out = '';
trek_tx($uid, function (&$run, $u) use ($cmd, $a, &$out) {
    $sp = fn(string $c) => trek_spots(1)[$c];
    switch ($cmd) {
        case 'tp': $s = $sp($a[0]); $run['inside'] = 1; $run['fi'] = null; $run['x'] = $s['x']; $run['y'] = $s['y']; unset($run['st']['ev'], $run['st']['cm']); break;
        case 'xy': $run['inside'] = 1; $run['fi'] = null; $run['x'] = (int)$a[0]; $run['y'] = (int)$a[1]; unset($run['st']['ev'], $run['st']['cm']); break;
        case 'flag': foreach ($a as $f) trek_flag_set($run, $f); break;
        case 'unflag': foreach ($a as $f) q('DELETE FROM trek_flags WHERE run_id = ? AND flag = ?', [$run['id'], $f]); break;
        case 'ev': $run['st']['ev'] = ['id' => $a[0]]; trek_flag_set($run, 'won_fight'); break;
        case 'recruit': trek_flag_set($run, 'freed_' . $a[0]); trek_recruit_crew($run, $u, $a[0]); break;
        case 'cm': $run['st']['cm'] = $a[0]; break;
        case 'pack': trek_pack_add((int)$run['id'], trek_item_id($a[0]), (int)$a[1]); break;
        case 'packq': $out = (string)trek_pack_qty((int)$run['id'], trek_item_id($a[0])); break;
        case 'see': $run['sn'] = str_repeat("\xff", strlen($run['sn'])); break;
        case 'set': foreach ($a as $kv) { [$k, $v] = explode('=', $kv, 2); $run[$k] = (int)$v; } break;
        case 'fight': $run['fi'] = null; trek_start_random_fight($run, $u, $a[0] ?? 'g'); break;
        case 'ms': $run['st']['ms'][$a[0]] = ['xp' => 450, 'done' => 3, 'total' => 5, 'miss' => ['Riddles solved']]; $run['st']['msc'] = [$a[0]]; break;
        case 'state': $out = json_encode($run['st']); break;
        case 'stkey': $v = $run['st']; foreach (explode('.', $a[0]) as $k) $v = is_array($v) ? ($v[$k] ?? null) : null; $out = $v === null ? 'NULL' : (is_scalar($v) ? (string)$v : json_encode($v)); break;
        case 'stunset': unset($run['st'][$a[0]]); break;
        case 'lowparty': foreach ($run['party'] as $s => $p) $run['party'][$s]['hp'] = 1; break;
        case 'complete': trek_complete_chapter($run, $u); break;
        case 'farm':   // many steps, events and fights: the daily caps must hold
            $n = (int)$a[0]; trek_flag_set($run, 'won_fight'); $run['sn'] = str_repeat("\xff", strlen($run['sn']));
            $A = [[5, 15], [9, 15]]; $k = 0; $ev = 0; $fights = 0;
            for ($i = 0; $i < $n; $i++) {
                $run['st']['turn'] = (int)($run['st']['turn'] ?? 0) + 1;
                if ($run['fi']) { trek_fight_auto($run, $u, 40); $fights++; if ($run['fi']) $run['fi'] = null; continue; }
                if (!empty($run['st']['ev'])) { trek_act_event($run, $u, 1); $ev++; continue; }
                if (!empty($run['st']['cm'])) { trek_act_crew($run, $u, 1); continue; }
                $run['fatigue'] = min((int)$run['fatigue'], 60);
                [$tx, $ty] = $A[$k++ % 2];
                trek_walk($run, $u, $tx, $ty);
            }
            $out = "events=$ev fights=$fights carried=" . (int)$run['petals_found'] . " counted_today=" . (int)($run['st']['pet_today'] ?? 0);
            break;
    }
    return [true, ''];
});
if ($out !== '') echo $out, "\n";
PHP
th() { local u=$1; shift; php -d display_errors=1 -d error_reporting=-1 $TMP/th.php "$GAME" "$u" "$@" 2>&1; }
# a fingerprint of a player's run, purse, xp, bag, flags (to prove "nothing changed")
cat > $TMP/snap.php <<'PHP'
<?php
$p = new PDO("sqlite:{$argv[1]}/data/game.sqlite"); $uid = (int)$p->query("SELECT id FROM users WHERE username='{$argv[2]}'")->fetchColumn(); $s = '';
foreach (["SELECT * FROM trek_runs WHERE user_id=$uid", "SELECT coins,xp,level,energy FROM users WHERE id=$uid", "SELECT * FROM user_items WHERE user_id=$uid ORDER BY item_id",
  "SELECT p.* FROM trek_party p JOIN trek_runs r ON r.id=p.run_id WHERE r.user_id=$uid ORDER BY p.slot", "SELECT p.* FROM trek_pack p JOIN trek_runs r ON r.id=p.run_id WHERE r.user_id=$uid ORDER BY p.item_id",
  "SELECT f.* FROM trek_flags f JOIN trek_runs r ON r.id=f.run_id WHERE r.user_id=$uid ORDER BY f.flag", "SELECT * FROM trek_ms WHERE user_id=$uid ORDER BY ms_key"] as $q) $s .= json_encode($p->query($q)->fetchAll(PDO::FETCH_ASSOC));
echo md5($s), "\n";
PHP
snap() { php $TMP/snap.php "$GAME" "$1"; }
RUNID() { db "SELECT id FROM trek_runs WHERE user_id=(SELECT id FROM users WHERE username='$1')"; }
UID_() { db "SELECT id FROM users WHERE username='$1'"; }
FLAGQ() { db "SELECT COUNT(*) FROM trek_flags WHERE run_id=$(RUNID $1) AND flag='$2'"; }
errlog() { test -s $GAME/data/error-log.txt && echo 1 || echo 0; }
# fresh player run: wipes the run, fills energy, begins over HTTP
freshrun() { local id; id=$(UID_ $1); dbx "DELETE FROM trek_party WHERE run_id IN (SELECT id FROM trek_runs WHERE user_id=$id); DELETE FROM trek_pack WHERE run_id IN (SELECT id FROM trek_runs WHERE user_id=$id); DELETE FROM trek_flags WHERE run_id IN (SELECT id FROM trek_runs WHERE user_id=$id); DELETE FROM trek_recruits WHERE run_id IN (SELECT id FROM trek_runs WHERE user_id=$id); DELETE FROM trek_runs WHERE user_id=$id; UPDATE users SET energy=100 WHERE id=$id"; use $1; post trek.php -d do=begin >/dev/null; }

echo "== install + players"
use admin; get install.php >/dev/null
IT=$(csrf $H); curl -s -c $JAR -b $JAR -X POST "$BASE/install.php" --data-urlencode "csrf=$IT" -d driver=sqlite -d "site_name=Gnome Venture" -d base_url= -d admin_user=admin -d admin_email=a@b.local -d admin_pass=TestPassword123 -d admin_pass2=TestPassword123 -o $H
grep -q 'All planted' $H && ok "installed" || { echo "INSTALL FAILED"; tail -5 $LOG; exit 1; }
mkuser() {   # name, gnome name
    JAR=$TMP/jar-$1; rm -f $JAR; get register.php >/dev/null
    postp register.php -d username=$1 -d email=$1@b.local -d password=TestPass123! -d password2=TestPass123! -d rules=1 -d age=1 >/dev/null
    get welcome.php >/dev/null; post welcome.php -d do=gnome --data-urlencode "gnome_name=$2" -d 'hat=#2e7d4f' -d 'beard=#b5651d' >/dev/null
    get 'welcome.php?step=place' >/dev/null
    local RID VID; RID=$(db "SELECT id FROM regions WHERE code='NA'")
    VID=$(db "SELECT l.id FROM locations l WHERE l.region_id=$RID AND l.kind='village' AND EXISTS (SELECT 1 FROM routes r WHERE r.kind='road' AND (r.a_id=l.id OR r.b_id=l.id)) ORDER BY l.sort_order LIMIT 1 OFFSET 1")
    post welcome.php -d do=place -d village_id=$VID >/dev/null
    get 'welcome.php?step=garden' >/dev/null; post welcome.php -d do=finish -d "garden_name=$1 Patch" >/dev/null
}
mkuser sprout Bramble; mkuser bloom Fern; mkuser mona Moss
assert "players onboarded" eq "$(db "SELECT MIN(onboarded) FROM users WHERE username IN ('sprout','bloom','mona')")" 1
dbx "UPDATE users SET level=15, energy=100, coins=500 WHERE username IN ('sprout','bloom','mona')"
dbx "INSERT OR REPLACE INTO settings (name, value) VALUES ('trek_open','1')"
dbx "UPDATE users SET role='moderator' WHERE username='mona'"
login sprout sprout2 'TestPass123!'; login admin admin 'TestPassword123'; login bloom bloom 'TestPass123!'; login mona mona 'TestPass123!'; login sprout sprout 'TestPass123!'
dbx "UPDATE users SET onboarded=1, level=15, energy=100 WHERE username='admin'"
SID=$(UID_ sprout); BID=$(UID_ bloom)

echo "== 1. CSRF: every trek action refuses a missing / forged / foreign token and changes nothing"
freshrun sprout; th sprout flag won_fight >/dev/null; freshrun bloom
use sprout; th sprout tp start >/dev/null
BEFORE=$(snap sprout)
ACTIONS="begin enter go mode makecamp rest buy_kit party recruit fetch chest riddle grotto challenge dismiss msdismiss tactics event crew cart mush round auto auto1 flee leave"
BADCODES=""
BTOK=$(tokof $TMP/jar-bloom)
for act in $ACTIONS; do
    for mode in none forged foreign; do
        case $mode in none) T="";; forged) T="csrf=forged";; foreign) T="csrf=$BTOK";; esac
        c=$(curl -s -c $JAR -b $JAR -X POST "$BASE/trek.php" ${T:+-d "$T"} -d do=$act -d go=5,5 -d slot=0 -d rule=ready -d c=1 -d how=work -d ans=2 -d p1=burdock -o /dev/null -w '%{http_code}')
        [ "$c" = 400 ] || BADCODES="$BADCODES $act/$mode=$c"
    done
done
assert "all 26 actions x (no / forged / foreign token) answer 400" eq "$BADCODES" ""
assert "...and no state changed (run, purse, XP, bag, flags)" eq "$(snap sprout)" "$BEFORE"
curl -s -c $JAR -b $JAR "$BASE/trek.php?do=leave&go=5,5&c=1" -o /dev/null; assert "GET with ?do=leave does nothing" eq "$(snap sprout)" "$BEFORE"
c=$(curl -s -c $JAR -b $JAR -X POST "$BASE/trek.php" -d 'csrf[]=x' -d do=leave -o /dev/null -w '%{http_code}'); assert "csrf sent as an array is refused (400)" eq "$c" 400
c=$(curl -s -X POST "$BASE/trek.php" -d csrf=x -d do=leave -o /dev/null -w '%{http_code}'); assert "no session at all: refused or sent to log in (never 500)" test "$c" != 500
assert "the error log is empty" eq "$(errlog)" 0

diag_login "before section, line $LINENO"
echo "== 2. AuthZ, forged slots / keys / items / tiles, whitelists"
freshrun sprout; th sprout flag won_fight >/dev/null; th sprout see >/dev/null
use sprout; th sprout xy 4 15 >/dev/null; th sprout set fatigue=0 >/dev/null
for tile in 99,99 40,40 0,0 -1,5 5,-1 1e2,3 '5,5;6,6' '5,5 ' 'a,b' ',' '100,100' '999,1' '3,3,3' ''; do post trek.php -d do=go --data-urlencode "go=$tile" >/dev/null; done
assert "go to off-map / malformed tiles: no move, no fatigue" eq "$(db "SELECT x||','||y||','||fatigue FROM trek_runs WHERE user_id=$SID")" "4,15,0"
WALL=$(php -r 'require "'$GAME'/includes/trek_data.php"; $m=trek_map(1); foreach($m["t"] as $y=>$row) for($x=0;$x<strlen($row);$x++) if($row[$x]=="#"){echo "$x,$y";exit;}')
CHASM=$(php -r 'require "'$GAME'/includes/trek_data.php"; $m=trek_map(1); foreach($m["t"] as $y=>$row) for($x=0;$x<strlen($row);$x++) if($row[$x]=="^"){echo "$x,$y";exit;}')
post trek.php -d do=go -d "go=$WALL" >/dev/null; post trek.php -d do=go -d "go=$CHASM" >/dev/null
assert "go into a wall or a chasm: refused, position unchanged" eq "$(db "SELECT x||','||y FROM trek_runs WHERE user_id=$SID")" "4,15"
# through a locked gate: the Root Wall is shut until the first fight is won
th sprout unflag won_fight gateopen_rootwall >/dev/null; th sprout tp start >/dev/null
post trek.php -d do=go -d go=20,5 >/dev/null; post trek.php -d do=go -d go=20,6 >/dev/null
assert "a walk through the locked Root Wall stops before it (never past y=4)" test "$(db "SELECT y FROM trek_runs WHERE user_id=$SID")" -le 3
th sprout flag won_fight >/dev/null
# fog: forget the fog, ask for a far tile
th sprout tp start >/dev/null; dbx "UPDATE trek_runs SET state=json_set(state,'\$.seen','') WHERE user_id=$SID"
FAR=$(php -r 'require "'$GAME'/includes/trek_data.php"; $m=trek_map(1); for($y=$m["h"]-1;$y>=0;$y--) for($x=0;$x<$m["w"];$x++) if($m["t"][$y][$x]=="."){echo "$x,$y";exit;}')
X0=$(db "SELECT x||','||y FROM trek_runs WHERE user_id=$SID")
post trek.php -d do=go -d "go=$FAR" >/dev/null
assert "go to an unseen (fog) tile: refused" eq "$(db "SELECT x||','||y FROM trek_runs WHERE user_id=$SID")" "$X0"
th sprout see >/dev/null
# tactics: forged slots and junk values
for slot in 7 -1 99999999999999999999 1 2 3 4; do post trek.php -d do=tactics -d "slot=$slot" -d rule=ready -d open=guard >/dev/null; done
assert "tactics for places with nobody in them change nothing" eq "$(th sprout stkey tac)" NULL
post trek.php -d do=tactics -d slot=0 --data-urlencode 'rule=<script>alert(1)</script>' --data-urlencode 'open=guard"><img>' -d target=strong -d 'snack[]=1' -d pct=9999 -d shield=zzz >/dev/null
TAC=$(th sprout stkey tac.gnome)
assert "tactics keep only whitelisted words (junk -> defaults)" bash -c "echo '$TAC' | grep -q '\"target\":\"strong\"' && ! echo '$TAC' | grep -q -E 'script|img|9999|zzz'"
post trek.php -d do=tactics -d slot=0 -d 'open[]=guard' -d 'rule[a]=x' >/dev/null; post trek.php -d do=tactics -d 'slot[]=1' >/dev/null
assert "tactics with array values: no 500, nothing stored for slot[]" bash -c "[ '$(errlog)' = 0 ] && [ '$(th sprout stkey tac.burdock)' = NULL ]"
# party: not at a camp, forged keys, unrecruited, duplicates
th sprout recruit burdock >/dev/null; th sprout tp start >/dev/null
Q0=$(db "SELECT COUNT(*)||':'||group_concat(crew_key) FROM trek_party WHERE run_id=$(RUNID sprout)")
post trek.php -d do=party -d p1=zinnia -d p2=bracken -d p3=gnome >/dev/null
assert "party swap away from a camp is refused" eq "$(db "SELECT COUNT(*)||':'||group_concat(crew_key) FROM trek_party WHERE run_id=$(RUNID sprout)")" "$Q0"
th sprout tp camp >/dev/null
post trek.php -d do=party -d p1=zinnia -d p2=bracken -d p3=gnome >/dev/null
assert "party swap with unrecruited / forged keys: nobody forged joins" eq "$(db "SELECT COUNT(*) FROM trek_party WHERE run_id=$(RUNID sprout) AND crew_key NOT IN ('gnome','burdock')")" 0
post trek.php -d do=party -d p1=burdock -d p2=burdock -d p3=burdock >/dev/null
assert "the same trailmate three times: only once" eq "$(db "SELECT COUNT(*) FROM trek_party WHERE run_id=$(RUNID sprout) AND crew_key='burdock'")" 1
post trek.php -d do=party -d 'p1[]=burdock' >/dev/null; assert "party with an array: no 500" eq "$(errlog)" 0
# events / crew / riddle / cart values outside the whitelist
th sprout ev stash >/dev/null; th sprout set petals_found=0 >/dev/null
for c in 99 -5 2 1e9 3; do post trek.php -d do=event --data-urlencode "c=$c" >/dev/null; done
post trek.php -d do=event -d 'c[]=1' >/dev/null
assert "event: choices outside the list (99, -5, 2, 1e9, c[]) do nothing and keep the card" eq "$(th sprout stkey ev.id)" stash
assert "event: nothing was paid by a bad choice" eq "$(db "SELECT petals_found FROM trek_runs WHERE user_id=$SID")" 0
th sprout tp choir >/dev/null; th sprout stunset tries_choir >/dev/null
for a in 0 -1 99999999999999999999 abc 1; do post trek.php -d do=riddle --data-urlencode "ans=$a" >/dev/null; done
assert "riddle: junk answers use up the tries, never solve it" eq "$(FLAGQ sprout choir_solved)" 0
assert "riddle: tries capped at 2 (no 3rd, v2.0.1)" eq "$(th sprout stkey tries_choir)" 2
post trek.php -d do=riddle -d ans=2 >/dev/null
assert "riddle: the right answer after the tries are gone pays nothing" eq "$(th sprout packq lanternroot-seed)" 0
th sprout tp cart >/dev/null; post trek.php -d do=cart -d how=zzz >/dev/null; post trek.php -d do=cart -d 'how[]=work' >/dev/null
assert "cart: unknown 'how' does nothing" eq "$(FLAGQ sprout cart_done)" 0
# fight values: forged slots, targets, foreign / non-snack items
freshrun bloom; th bloom flag won_fight >/dev/null
dbx "INSERT OR IGNORE INTO user_items (user_id,item_id,qty) SELECT $BID, id, 5 FROM items WHERE category='food' LIMIT 3"
FOODB=$(db "SELECT item_id FROM user_items WHERE user_id=$BID AND item_id IN (SELECT id FROM items WHERE category='food') LIMIT 1")
dbx "DELETE FROM user_items WHERE user_id=$SID AND item_id=$FOODB"
use sprout; th sprout fight g >/dev/null; th sprout set fatigue=0 >/dev/null
QB0=$(db "SELECT qty FROM user_items WHERE user_id=$BID AND item_id=$FOODB")
th sprout lowparty >/dev/null
post trek.php -d do=round -d 'a[0]=snack' -d "item=$FOODB" -d 'a[9]=attack' -d 'a[-3]=guard' -d 'a[2]=ability' -d 't[0]=f:99999' -d 't[9]=a:77' -d 'a[abc]=attack' >/dev/null
assert "round: a snack with someone else's item eats nothing of theirs" eq "$(db "SELECT qty FROM user_items WHERE user_id=$BID AND item_id=$FOODB")" "$QB0"
assert "round: a snack the player does not own does not appear" eq "$(db "SELECT COALESCE(SUM(qty),0) FROM user_items WHERE user_id=$SID AND item_id=$FOODB")" 0
assert "round: forged slots and targets: no 500" eq "$(errlog)" 0
th sprout fight g >/dev/null
post trek.php -d do=round -d 'a[0]=snack' -d 'item=-1' -d 'item[]=2' -d 't[0]=f:-1' -d 't[0]=zzz' >/dev/null
post trek.php -d do=flee >/dev/null; post trek.php -d do=nonsense >/dev/null; post trek.php --data-urlencode "do=' OR 1=1 --" >/dev/null; post trek.php -d 'do[]=go' >/dev/null
# one player cannot touch another's run: bloom acts, sprout's fingerprint stays
S0=$(snap sprout); use bloom
th bloom tp start >/dev/null; post trek.php -d do=mode -d mode=sneak >/dev/null; post trek.php -d do=leave >/dev/null; post trek.php -d do=enter >/dev/null
assert "bloom's actions leave sprout's run, purse and bag untouched" eq "$(snap sprout)" "$S0"
assert "no trek form carries a run / user id (nothing to forge)" bash -c "! grep -qE 'name=\"(run|run_id|user_id|uid)\"' $GAME/trek.php"
assert "the error log is empty" eq "$(errlog)" 0

diag_login "before section, line $LINENO"
echo "== 3. Double-pay / races (two logins of one player firing at once)"
race() {   # race <user> <jar2> data...: the same POST from two sessions (three requests) at the same moment
    local u=$1 j2=$2; shift 2
    local t1 t2 p1 p2 p3; t1=$(tokof $TMP/jar-$u); t2=$(tokof $TMP/jar-$j2)
    curl -s -c $TMP/jar-$u -b $TMP/jar-$u -X POST "$BASE/trek.php" -d "csrf=$t1" "$@" -o /dev/null & p1=$!
    curl -s -c $TMP/jar-$j2 -b $TMP/jar-$j2 -X POST "$BASE/trek.php" -d "csrf=$t2" "$@" -o /dev/null & p2=$!
    curl -s -c $TMP/jar-$j2 -b $TMP/jar-$j2 -X POST "$BASE/trek.php" -d "csrf=$t2" "$@" -o /dev/null & p3=$!
    wait $p1 $p2 $p3
}
freshrun sprout; th sprout flag won_fight >/dev/null; th sprout see >/dev/null
# 3a: trail event
th sprout tp start >/dev/null; th sprout xy 4 15 >/dev/null; th sprout ev stash >/dev/null; th sprout set petals_found=0 >/dev/null; dbx "UPDATE trek_runs SET state=json_remove(state,'\$.pet_today','\$.pet_day') WHERE user_id=$SID"
race sprout sprout2 -d do=event -d c=1
P=$(db "SELECT petals_found FROM trek_runs WHERE user_id=$SID"); assert "event: 3 simultaneous taps pay once (6-14 Petals, got $P)" test "${P:-0}" -ge 6 -a "${P:-0}" -le 14
assert "event: counted once for the milestone check" eq "$(th sprout stkey evn)" 1
th sprout ev fork >/dev/null; use sprout; for i in 1 2 3 4 5 6; do get trek.php >/dev/null; get 'trek.php?t=party' >/dev/null; done
assert "a pending event survives 12 refreshes unchanged (no reroll)" eq "$(th sprout stkey ev.id)" fork
# 3b: cart (work)
th sprout tp cart >/dev/null; th sprout set campkits=0 fatigue=0 >/dev/null; th sprout unflag cart_done >/dev/null
race sprout sprout2 -d do=cart -d how=work
assert "cart: the Camp Kit is given once" eq "$(db "SELECT campkits FROM trek_runs WHERE user_id=$SID")" 1
assert "cart: tiring only once (+8)" eq "$(db "SELECT fatigue FROM trek_runs WHERE user_id=$SID")" 8
# 3c: Worm Choir riddle (right answer 2)
th sprout tp choir >/dev/null; th sprout stunset tries_choir >/dev/null; th sprout unflag choir_solved >/dev/null
race sprout sprout2 -d do=riddle -d ans=2
assert "riddle: the prize is given once" eq "$(th sprout packq lanternroot-seed)" 1
# 3d: mushroom camp
th sprout tp mushcamp >/dev/null; th sprout pack beetle-shell 6 >/dev/null; th sprout set petals_found=0 >/dev/null; th sprout unflag mush_done >/dev/null
dbx "UPDATE trek_runs SET state=json_remove(state,'\$.pet_today','\$.pet_day') WHERE user_id=$SID"
race sprout sprout2 -d do=mush
assert "mushroom camp: 2 shells taken once (6 -> 4)" eq "$(th sprout packq beetle-shell)" 4
assert "mushroom camp: honeydew given once" eq "$(th sprout packq honeydew)" 1
P=$(db "SELECT petals_found FROM trek_runs WHERE user_id=$SID"); assert "mushroom camp: Petals once (<= 30, got $P)" test "${P:-0}" -le 30
# 3e: crew moment
th sprout recruit burdock >/dev/null; th sprout tp start >/dev/null; th sprout set petals_found=0 >/dev/null; th sprout cm burdock >/dev/null
dbx "UPDATE trek_runs SET state=json_remove(state,'\$.pet_today','\$.pet_day') WHERE user_id=$SID"
race sprout sprout2 -d do=crew -d c=1
P=$(db "SELECT petals_found FROM trek_runs WHERE user_id=$SID"); assert "crew moment: paid once (10-18 Petals, got $P)" test "${P:-0}" -ge 10 -a "${P:-0}" -le 18
# 3f: cellar chest (key)
th sprout tp cellar >/dev/null; th sprout pack cellar-key 1 >/dev/null; th sprout set campkits=0 petals_found=0 >/dev/null; th sprout unflag cellar_open >/dev/null
race sprout sprout2 -d do=chest
assert "chest: kits (2) and Petals (120) given once" eq "$(db "SELECT campkits||':'||petals_found FROM trek_runs WHERE user_id=$SID")" "2:120"
# 3g: Burdock milestone XP once, then never again after an admin reset
th sprout tp burdock >/dev/null; th sprout unflag freed_burdock ms_burdock >/dev/null; dbx "DELETE FROM trek_recruits WHERE run_id=$(RUNID sprout); DELETE FROM trek_party WHERE run_id=$(RUNID sprout) AND slot>0; DELETE FROM trek_ms WHERE user_id=$SID"
XP0=$(db "SELECT xp FROM users WHERE id=$SID")
race sprout sprout2 -d do=recruit
XP1=$(db "SELECT xp FROM users WHERE id=$SID")
assert "milestone: one trek_ms row after 3 simultaneous recruits" eq "$(db "SELECT COUNT(*) FROM trek_ms WHERE user_id=$SID AND ms_key LIKE '%burdock'")" 1
PAID=$(db "SELECT xp FROM trek_ms WHERE user_id=$SID AND ms_key LIKE '%burdock'")
assert "milestone: gnome XP rose by exactly the paid amount, once ($XP0 -> $XP1, paid $PAID)" bash -c "[ -n '$PAID' ] && [ \$(( $XP1 - $XP0 )) = '$PAID' ]"
use admin; get admin/treks.php >/dev/null; RID=$(RUNID sprout)
nocsrf admin/treks.php -d "run=$RID" -d confirm=RESET >/dev/null
assert "admin reset without a token is refused (run still there)" eq "$(RUNID sprout)" "$RID"
post admin/treks.php -d "run=$RID" -d confirm=nope >/dev/null; assert "admin reset without typing RESET is refused" eq "$(RUNID sprout)" "$RID"
post admin/treks.php -d "run=$RID" -d confirm=RESET >/dev/null; assert "admin reset with token + RESET removes the run" eq "$(RUNID sprout)" ""
assert "the once-only milestone row survives the reset" eq "$(db "SELECT COUNT(*) FROM trek_ms WHERE user_id=$SID AND ms_key LIKE '%burdock'")" 1
dbx "UPDATE users SET energy=100 WHERE id=$SID"; use sprout; post trek.php -d do=begin >/dev/null
th sprout flag won_fight >/dev/null; th sprout tp burdock >/dev/null
XP2=$(db "SELECT xp FROM users WHERE id=$SID"); race sprout sprout2 -d do=recruit
assert "milestone after a reset: Burdock is freed again but pays NO XP" eq "$(db "SELECT xp FROM users WHERE id=$SID")" "$XP2"
assert "...and still one trek_ms row" eq "$(db "SELECT COUNT(*) FROM trek_ms WHERE user_id=$SID AND ms_key LIKE '%burdock'")" 1
th sprout complete >/dev/null; C1=$(db "SELECT coins FROM users WHERE id=$SID"); XPC=$(db "SELECT xp FROM users WHERE id=$SID"); th sprout complete >/dev/null; th sprout complete >/dev/null
assert "chapter reward and milestones: paid on the first completion only" bash -c "[ '$(db "SELECT coins FROM users WHERE id=$SID")' = '$C1' ] && [ '$(db "SELECT xp FROM users WHERE id=$SID")' = '$XPC' ]"
use sprout; post trek.php -d do=leave >/dev/null; dbx "UPDATE users SET energy=100 WHERE id=$SID"
race sprout sprout2 -d do=enter
E=$(db "SELECT energy FROM users WHERE id=$SID"); COST=$(db "SELECT COALESCE((SELECT value FROM settings WHERE name='trek_entry_energy'),'10')")
assert "enter x3 at once: energy spent once (100 -> $E, cost $COST)" test "${E:-0}" -ge $((100-COST-2))
assert "after the races the error log is empty" eq "$(errlog)" 0

diag_login "before section, line $LINENO"
echo "== 4. XSS: nasty names / item names / story text on every changed page"
P1='"><img src=x onerror=alert(1)>'; P2='</script><svg onload=alert(2)>'
RJ=$TMP/jar-evil; rm -f $RJ; JAR=$RJ; get register.php >/dev/null; postp register.php -d username=evil -d email=e@b.local -d password=TestPass123! -d password2=TestPass123! -d rules=1 -d age=1 >/dev/null
get welcome.php >/dev/null; post welcome.php -d do=gnome --data-urlencode "gnome_name=$P1" -d 'hat=#2e7d4f' -d 'beard=#b5651d' >/dev/null
assert "the real gnome-name form refuses <, > and quotes" eq "$(db "SELECT COALESCE(gnome_name,'') FROM users WHERE username='evil'")" ""
get welcome.php >/dev/null; post welcome.php -d do=gnome --data-urlencode "gnome_name=$P2" -d 'hat=#2e7d4f' -d 'beard=#b5651d' >/dev/null
assert "...also the </script> form" eq "$(db "SELECT COALESCE(gnome_name,'') FROM users WHERE username='evil'")" ""
# defence in depth: even if a name got in (admin editor, old data), every page escapes it
use sprout; freshrun sprout; th sprout flag won_fight >/dev/null; th sprout see >/dev/null; th sprout recruit burdock >/dev/null
php -r '$p=new PDO("sqlite:'$GAME'/data/game.sqlite"); $s=$p->prepare("UPDATE users SET gnome_name=?, hat_color=? WHERE username=\"sprout\""); $s->execute([$argv[1], "#fff\"><script>alert(4)</script>"]); $s=$p->prepare("UPDATE items SET name=? WHERE slug=\"beetle-shell\""); $s->execute(["<img src=x onerror=alert(3)>"]);' "$P1"
dbx "UPDATE trek_texts SET body='<script>alert(5)</script> {gnome} \"><img src=x onerror=alert(6)>', status='draft' WHERE text_key IN ('ch1.ev.stash.text','ch1.ev.stash.dig','ch1.tut.walk','ch1.intro','ch1.spot.start.arrive','ch1.spot.camp.arrive','ch1.spot.cart.before','ch1.crew.burdock.talk')"
RAW='<script>alert|<svg onload|<svg/onload|<img src=x'
scan() {   # scan <label> : the page in $H must not hold the raw payload
    if grep -qE "$RAW" $H; then bad "XSS: raw payload on $1" "$(grep -oE "$RAW" $H | head -2 | tr '\n' ' ')"; else ok "no raw payload on $1"; fi
}
th sprout pack beetle-shell 3 >/dev/null; th sprout tp start >/dev/null; th sprout set fatigue=0 >/dev/null
use sprout; get trek.php >/dev/null; scan "trek map (start)"; assert "...and the escaped form of the name is there" grep -q '&quot;&gt;&lt;img' $H
for t in party pack log; do get "trek.php?t=$t" >/dev/null; scan "trek tab $t"; done
th sprout ev stash >/dev/null; get trek.php >/dev/null; scan "event card"; post trek.php -d do=event -d c=1 >/dev/null; get trek.php >/dev/null; scan "map after the event"
th sprout cm burdock >/dev/null; get trek.php >/dev/null; scan "crew card"; post trek.php -d do=crew -d c=1 >/dev/null
th sprout ms mother >/dev/null; get trek.php >/dev/null; scan "milestone card"; get 'trek.php?t=log' >/dev/null; scan "log tab (milestones, journal)"
th sprout tp camp >/dev/null; get trek.php >/dev/null; scan "camp panel"
th sprout tp cart >/dev/null; get trek.php >/dev/null; scan "cart panel"
th sprout tp start >/dev/null
th sprout fight g >/dev/null; get trek.php >/dev/null; scan "fight screen"; post trek.php -d do=round >/dev/null; get trek.php >/dev/null; scan "fight after a round (log lines hold the name)"
replay_check() { php -r '$h=file_get_contents($argv[1]); if(!preg_match("/data-replay=\"([^\"]*)\"/",$h,$m)){echo "NONE";exit;} $j=json_decode(html_entity_decode($m[1],ENT_QUOTES),true); if(!is_array($j)){echo "BADJSON";exit;} $bad=0;$n=0; foreach(($j["r"]??[]) as $rd) foreach(($rd["l"]??[]) as $v){ $n++; $w=is_string($v)?preg_replace("/<img class=\"ico pix\" src=\"[^\"<>]*\" alt=\"[^\"<>]*\" width=\"16\" height=\"16\" loading=\"lazy\" decoding=\"async\">/","",$v):$v; if(!is_string($v) || preg_match("/<\s*(img|svg|script)/i",$w)){$bad++; fwrite(STDERR,"RAWSTR: ".substr((string)$v,0,120)."\n");} } echo $bad?"RAW:$bad":"CLEAN:$n:".strlen($m[1]);' "$1"; }
th sprout fight g >/dev/null; th sprout lowparty >/dev/null
post trek.php -d do=auto >/dev/null; get trek.php >/dev/null; scan "map right after Auto (replay stage)"; cp $H $TMP/replay.html
REPJ=$(replay_check $TMP/replay.html)
case $REPJ in CLEAN:*) ok "data-replay: valid JSON inside a safe attribute, every log line escaped, only our own emoji icons as markup ($REPJ); names in the snapshot go in with textContent"; SZ=${REPJ##*:}; assert "data-replay is size-capped (<400 KB, got $SZ)" test "$SZ" -lt 400000;; NONE) bad "data-replay: no replay recorded to inspect";; *) bad "data-replay: $REPJ";; esac
th sprout xy 4 15 >/dev/null; th sprout set fatigue=0 >/dev/null; W=""
for tgt in 8,15 4,17 6,16; do post trek.php -d do=go -d "go=$tgt" >/dev/null; get trek.php >/dev/null; W=$(grep -o 'data-walk="[^"]*"' $H | head -1); [ -n "$W" ] && break; th sprout xy 4 15 >/dev/null; done
assert "a walk produces data-walk" test -n "$W"
assert "data-walk holds only digits, commas and semicolons" bash -c "echo '$W' | grep -qE '^data-walk=\"[0-9,;]+\"$'"
assert "data-walk has at most 41 points" bash -c "[ \$(echo '$W' | tr ';' '\n' | wc -l) -le 41 ]"
scan "map after a walk (data-walk, SVG)"
SVGTXT=$(grep -oE '<text[^>]*>[^<]*</text>' $H | sed -E 's/<[^>]*>//g' | tr -d '[:space:]')
assert "the map SVG text holds only the fixed icons (no letters)" bash -c "! echo '$SVGTXT' | grep -qE '[A-Za-z]'"
for pg in index.php garden.php book.php community.php folk.php inventory.php shop.php town.php world.php worms.php marrow.php marketday.php gnome.php account.php yard.php market.php 'inventory.php?tab=craft&c=cooking' 'world.php?tab=gather' mushroom.php; do
    c=$(get "$pg"); if [ "$c" = 200 ] || [ "$c" = 302 ]; then scan "$pg ($c)"; else bad "$pg answered $c"; fi
done
freshrun sprout; get trek.php >/dev/null; scan "trek intro with an admin draft containing <script>"
assert "trek intro: the draft shows as escaped text" grep -q '&lt;script&gt;alert(5)' $H
use admin; for pg in admin/treks.php admin/trek_text.php 'admin/trek_text.php?f=todo'; do get "$pg" >/dev/null; scan "$pg"; done
dbx "UPDATE users SET gnome_name='Bramble', hat_color='#2e7d4f' WHERE username='sprout'; UPDATE items SET name='Beetle Shell' WHERE slug='beetle-shell'"
dbx "UPDATE trek_texts SET body=NULL, status='todo' WHERE body LIKE '%alert(5)%'"

diag_login "before section, line $LINENO"
echo "== 5. Session one-shots (trek_replay, trek_walk): same user + run, fresh, capped, cannot be injected"
freshrun sprout; th sprout flag won_fight >/dev/null; th sprout see >/dev/null; use sprout
RID=$(RUNID sprout)
curl -s -c $JAR -b $JAR "$BASE/trek.php?trek_replay[run]=$RID&trek_replay[t]=$(date +%s)&trek_replay[r][]=1&trek_walk[p][0][0]=1" -o $H; assert "client params named trek_replay / trek_walk are ignored" bash -c "! grep -q 'data-replay\|data-walk' $H"
curl -s -c $JAR -b $JAR -X POST "$BASE/trek.php" -d "csrf=$(tokof $JAR)" -d 'trek_replay[run]=1' -d do=mode -d mode=hunt -o /dev/null; get trek.php >/dev/null; assert "...also as POST fields" bash -c "! grep -q 'data-replay' $H"
curl -s -c $JAR -b $JAR "$BASE/trek.php" -H 'Cookie: trek_replay=1; trek_walk=1' -o $H; assert "...and as cookies" bash -c "! grep -q 'data-replay\|data-walk' $H"
th sprout fight g >/dev/null; th sprout lowparty >/dev/null; post trek.php -d do=auto >/dev/null
SF=$(grep garden_sess $JAR | awk '{print $7}' | head -1)
assert "the session file exists" test -f $TMP/sess_$SF
if grep -q 'trek_replay' $TMP/sess_$SF; then
    cp $TMP/sess_$SF $TMP/sess_backup
    php -r '$f=$argv[1]; $s=file_get_contents($f); $s=preg_replace("/(trek_replay\|a:\d+:\{s:3:\"run\";)i:\d+;/","\${1}i:99999;",$s); file_put_contents($f,$s);' $TMP/sess_$SF
    get trek.php >/dev/null; assert "a replay of another run id is dropped" bash -c "! grep -q 'data-replay' $H"
    cp $TMP/sess_backup $TMP/sess_$SF
    php -r '$f=$argv[1]; $s=file_get_contents($f); $s=preg_replace("/(trek_replay\|a:\d+:\{s:3:\"run\";i:\d+;s:1:\"t\";)i:\d+;/","\${1}i:1000;",$s,1); file_put_contents($f,$s);' $TMP/sess_$SF
    get trek.php >/dev/null; assert "a replay older than 30 s is dropped" bash -c "! grep -q 'data-replay' $H"
    cp $TMP/sess_backup $TMP/sess_$SF; get 'trek.php?t=party' >/dev/null; get trek.php >/dev/null
    assert "a replay is consumed by the first page view (no second showing)" bash -c "! grep -q 'data-replay' $H"
else
    bad "no trek_replay in the session after Auto (cannot test the one-shot)" "session: $(head -c 400 $TMP/sess_$SF | tr '\n' ' '); error log: $(head -c 400 $GAME/data/error-log.txt 2>/dev/null | tr '\n' ' '); server log: $(grep -E 'Warning|Deprecated|Fatal|Notice' $LOG | head -3 | tr '\n' ' ')"
fi
th sprout xy 4 15 >/dev/null; th sprout set fatigue=0 >/dev/null
SID_=$(grep garden_sess $JAR | awk '{print $7}' | head -1)
php -r 'session_save_path($argv[1]); session_id($argv[2]); session_start(); $_SESSION["trek_walk"]=["run"=>(int)$argv[3],"t"=>time(),"p"=>[["4\"><x","15"],["4","15\" onmouseover=\"a"],[4,15]],"d"=>["x\"y",1]]; session_write_close();' $TMP $SID_ $(RUNID sprout)
get trek.php >/dev/null; WK=$(grep -o 'data-walk="[^"]*"' $H | head -1)
assert "trek_walk with strings in the session: output is ints only" bash -c "[ -z '$WK' ] || echo '$WK' | grep -qE '^data-walk=\"[0-9,;]+\"$'"
assert "...and no attribute injection" bash -c "! grep -q 'onmouseover' $H"
assert "the error log is empty after the session tests" eq "$(errlog)" 0

diag_login "before section, line $LINENO"
echo "== 6. SQL: bound parameters, portable SQL, fuzzed inputs"
BAD=$(grep -nE "q(_one|_val)?\(\s*['\"][^'\"]*\\\$|q(_one|_val)?\(\s*['\"][^'\"]*['\"]\s*\.\s*\\\$" $GAME/trek.php $GAME/includes/trek*.php $GAME/admin/treks.php | grep -v 'DELETE FROM \$t' | grep -vE "ENGINE|CREATE")
assert "no trek query builds SQL from variables (except the whitelisted DELETE table list)" eq "$BAD" ""
assert "the admin reset table list is a fixed array" grep -q "foreach (\['trek_party', 'trek_pack', 'trek_flags', 'trek_recruits'\] as \$t)" $GAME/admin/treks.php
assert "no MySQL-only or SQLite-only SQL in the trek code (INSERT OR, IFNULL, json_, NOW(), ON DUPLICATE)" bash -c "! grep -nE \"INSERT OR |REPLACE INTO|IFNULL\(|json_extract|NOW\(\)|ON DUPLICATE\" $GAME/trek.php $GAME/includes/trek*.php $GAME/admin/treks.php"
freshrun sprout; th sprout flag won_fight >/dev/null; use sprout
NASTY=("' OR 1=1 --" "1; DROP TABLE trek_runs; --" '" onfocus=alert(1) x="' '%00' '../../etc/passwd' '{{7*7}}' '${7*7}' '9999999999999999999999' '-1' '0x1F' "$(printf 'A%.0s' $(seq 1 3000))")
TK=$(tokof $JAR); N=0
for v in "${NASTY[@]}"; do for k in go slot c how ans p1 rule open target mode t item; do c=$(curl -s -c $JAR -b $JAR -X POST "$BASE/trek.php" -d "csrf=$TK" --data-urlencode "$k=$v" -d do=mode -o /dev/null -w '%{http_code}'); N=$((N+1)); [ "$c" = 500 ] && bad "500 for $k=${v:0:20}"; done; for dov in rest go tactics event riddle party; do c=$(curl -s -c $JAR -b $JAR -X POST "$BASE/trek.php" -d "csrf=$TK" -d "do=$dov" --data-urlencode "go=$v" --data-urlencode "c=$v" --data-urlencode "ans=$v" --data-urlencode "slot=$v" --data-urlencode "p1=$v" -o /dev/null -w '%{http_code}'); N=$((N+1)); [ "$c" = 500 ] && bad "500 for do=$dov v=${v:0:20}"; done; done
assert "$N fuzzed POSTs: all trek tables intact" eq "$(db "SELECT COUNT(*) FROM sqlite_master WHERE name IN ('trek_runs','trek_party','trek_pack','trek_flags','trek_ms','trek_texts')")" 6
assert "...the run is intact and the error log empty" bash -c "[ '$(errlog)' = 0 ] && [ -n '$(RUNID sprout)' ]" || echo "     diag: run id '$(RUNID sprout)'; error log: $(head -c 600 $GAME/data/error-log.txt 2>/dev/null | tr '\n' ' ')"

diag_login "before section, line $LINENO"
echo "== 7. CSP and inline code"
for pg in trek.php 'trek.php?t=party' 'trek.php?t=pack' 'trek.php?t=log' garden.php admin/treks.php; do
    if [ "$pg" = admin/treks.php ]; then use admin; else use sprout; fi
    curl -s -D $TMP/hdr -c $JAR -b $JAR "$BASE/$pg" -o $H
    assert "$pg: CSP keeps style-src 'self' and script-src 'self', no unsafe-inline / unsafe-eval" bash -c "grep -i '^content-security-policy' $TMP/hdr | grep -q \"style-src 'self'\" && grep -i '^content-security-policy' $TMP/hdr | grep -q \"script-src 'self'\" && ! grep -i '^content-security-policy' $TMP/hdr | grep -qE 'unsafe-(inline|eval)'"
done
use sprout
for state in plain fight event crew milestone walk; do
    case $state in
        plain) th sprout tp start >/dev/null;;
        fight) th sprout fight g >/dev/null;;
        event) th sprout tp start >/dev/null; th sprout ev stash >/dev/null;;
        crew) th sprout tp start >/dev/null; th sprout cm burdock >/dev/null;;
        milestone) th sprout tp start >/dev/null; th sprout ms mother >/dev/null;;
        walk) th sprout tp start >/dev/null; th sprout xy 4 15 >/dev/null; post trek.php -d do=go -d go=8,15 >/dev/null;;
    esac
    get trek.php >/dev/null
    assert "trek map ($state): no style=\"\", no on*= handlers, no javascript: URLs, no <style>; every <script> has src" bash -c "! grep -qiE ' style=\"|<style| on[a-z]+=\"|javascript:' $H && [ \$(grep -c '<script' $H) = \$(grep -c '<script[^>]* src=' $H) ]"
done
for t in party pack log; do get "trek.php?t=$t" >/dev/null; assert "trek tab $t: no inline style / handlers / scripts" bash -c "! grep -qiE ' style=\"|<style| on[a-z]+=\"|javascript:' $H && [ \$(grep -c '<script' $H) = \$(grep -c '<script[^>]* src=' $H) ]"; done
assert "the new JS never writes a style attribute, eval, new Function, document.write or insertAdjacentHTML" bash -c "! grep -nE \"setAttribute\\('style'|cssText|eval\\(|new Function|document\\.write|insertAdjacentHTML\" $GAME/assets/trekfight.js $GAME/assets/trekmap.js $GAME/assets/chest.js"
INNER=$(grep -n 'innerHTML' $GAME/assets/trekfight.js $GAME/assets/trekmap.js $GAME/assets/chest.js | grep -vE 'escaped by the server|CHEST')
assert "innerHTML in the new JS only takes server-escaped log lines or the fixed chest art" eq "$INNER" ""
assert "gvAsk / gvSay put the message in with textContent (no innerHTML in the dialog helpers)" bash -c "grep -q 'st.p.textContent = String(msg)' $GAME/assets/site.js && ! sed -n '1,60p' $GAME/assets/site.js | grep -qE 'innerHTML *[+]?='"
assert "no <dialog> is printed with an inline style or handler" bash -c "! grep -nE '<dialog[^>]* style=|<dialog[^>]* on[a-z]+=' $GAME/*.php $GAME/includes/*.php"
for f in assets/site.js assets/chest.js assets/trekfight.js assets/trekmap.js; do c=$(curl -s -o /dev/null -w '%{http_code}' "$BASE/$f"); assert "$f is served (200)" eq "$c" 200; done

# a complete, valid admin/settings.php form body (every field as the page has it) with one value changed
cat > $TMP/sb.php <<'PHP'
<?php
$d = new DOMDocument(); @$d->loadHTML('<?xml encoding="utf-8"?>' . file_get_contents($argv[1])); $x = new DOMXPath($d); $o = [];
foreach ($x->query('//form//input[@name]') as $i) { $n = $i->getAttribute('name'); $t = $i->getAttribute('type');
    if ($t === 'checkbox') { if ($i->hasAttribute('checked')) $o[] = [$n, $i->getAttribute('value') ?: '1']; } elseif ($t === 'radio') { if ($i->hasAttribute('checked')) $o[] = [$n, $i->getAttribute('value')]; } elseif ($n !== 'csrf') $o[] = [$n, $i->getAttribute('value')]; }
foreach ($x->query('//form//select[@name]') as $s) { $v = null; foreach ($x->query('.//option', $s) as $op) { if ($v === null || $op->hasAttribute('selected')) $v = $op->getAttribute('value'); } $o[] = [$s->getAttribute('name'), (string)$v]; }
foreach ($x->query('//form//textarea[@name]') as $t) $o[] = [$t->getAttribute('name'), $t->textContent];
$k = 's[' . $argv[2] . ']'; $set = false; foreach ($o as &$p) if ($p[0] === $k) { $p[1] = $argv[3]; $set = true; } unset($p); if (!$set) $o[] = [$k, $argv[3]];
echo implode('&', array_map(fn($p) => rawurlencode($p[0]) . '=' . rawurlencode($p[1]), $o));
PHP
settings_post() {   # settings_post KEY VALUE: as the current login, with the admin's page as the template
    curl -s -c $TMP/jar-admin -b $TMP/jar-admin "$BASE/admin/settings.php?adv=1" -o $TMP/set.html
    php $TMP/sb.php $TMP/set.html "$1" "$2" > $TMP/set.body
    curl -s -c $JAR -b $JAR -X POST "$BASE/admin/settings.php" --data-binary @$TMP/set.body --data-urlencode "csrf=$(tokof $JAR)" -o /dev/null -w '%{http_code}'
}

diag_login "before section, line $LINENO"
echo "== 8. Admin: who may reach / change the Treks pages and settings"
for who in anon bloom mona; do
    case $who in anon) JAR=$TMP/jar-anon; rm -f $JAR;; *) use $who;; esac
    for pg in admin/treks.php admin/trek_text.php 'admin/settings.php'; do
        c=$(curl -s -c $JAR -b $JAR "$BASE/$pg" -o $H -w '%{http_code}'); if [ "$c" = 200 ] && ! grep -q 'Admins only' $H && [ "$(wc -c < $H)" -gt 400 ]; then bad "$who can read $pg"; else ok "$who cannot read $pg ($c)"; fi
    done
done
RIDS=$(RUNID sprout)
for who in bloom mona; do use $who; post admin/treks.php -d "run=$RIDS" -d confirm=RESET >/dev/null; post admin/trek_text.php -d key=ch1.intro --data-urlencode 'body=HACKED' -d status=draft >/dev/null; settings_post trek_ms_burdock 9999999 >/dev/null; done
assert "players / moderators cannot reset a run" eq "$(RUNID sprout)" "$RIDS"
assert "players / moderators cannot edit story text" eq "$(db "SELECT COUNT(*) FROM trek_texts WHERE body='HACKED'")" 0
assert "players / moderators cannot change Trek settings (full valid form, own token)" bash -c "[ '$(db "SELECT COALESCE((SELECT value FROM settings WHERE name='trek_ms_burdock'),'')")' != 9999999 ]"
use admin
curl -s -c $JAR -b $JAR "$BASE/admin/settings.php?adv=1" -o $TMP/set.html; php $TMP/sb.php $TMP/set.html trek_ms_burdock 7777777 > $TMP/set.body
curl -s -c $JAR -b $JAR -X POST "$BASE/admin/settings.php" --data-binary @$TMP/set.body -o /dev/null
nocsrf admin/trek_text.php -d key=ch1.intro -d body=HACKED2 -d status=draft >/dev/null; curl -s -c $JAR -b $JAR -X POST $BASE/admin/treks.php -d "run=$RIDS" -d confirm=RESET -d csrf=bad -o /dev/null
assert "admin posts with no / bad token change nothing (settings, story text, reset)" bash -c "[ '$(db "SELECT COALESCE((SELECT value FROM settings WHERE name='trek_ms_burdock'),'')")' != 7777777 ] && [ '$(db "SELECT COUNT(*) FROM trek_texts WHERE body='HACKED2'")' = 0 ] && [ '$(RUNID sprout)' = '$RIDS' ]"
for bad_id in "x" "-1" "0" "99999999999999999999" "1e3"; do post admin/treks.php --data-urlencode "run=$bad_id" -d confirm=RESET >/dev/null; done
post admin/treks.php -d 'run[]=1' -d confirm=RESET >/dev/null
assert "reset with junk run ids: nothing deleted, no 500" bash -c "[ '$(RUNID sprout)' = '$RIDS' ] && [ '$(errlog)' = 0 ]"
settings_post trek_ms_burdock 151 >/dev/null
assert "admin with a token can change a Trek setting (control)" eq "$(db "SELECT value FROM settings WHERE name='trek_ms_burdock'")" 151
settings_post trek_ms_burdock 99999999999 >/dev/null; settings_post trek_event_pct 101 >/dev/null; settings_post trek_event_gap 0 >/dev/null; settings_post trek_ms_burdock 12ab >/dev/null
assert "admin: out-of-range / junk Trek settings are refused (kept at 151)" eq "$(db "SELECT value FROM settings WHERE name='trek_ms_burdock'")" 151

diag_login "before section, line $LINENO"
echo "== 9. Abuse: loops of cheap POSTs and long walks cannot beat the caps"
freshrun sprout; use sprout; th sprout flag won_fight >/dev/null; th sprout see >/dev/null
dbx "UPDATE users SET coins=500 WHERE id=$SID"
XPA=$(db "SELECT xp||':'||level FROM users WHERE id=$SID"); CA=$(db "SELECT coins FROM users WHERE id=$SID")
th sprout tp camp >/dev/null
for i in $(seq 1 20); do for act in mode rest makecamp buy_kit party dismiss msdismiss tactics leave enter; do post trek.php -d do=$act -d mode=sneak -d slot=0 -d p1=burdock >/dev/null; done; dbx "UPDATE users SET energy=100 WHERE id=$SID"; done
dbx "DELETE FROM login_attempts WHERE username='trek:$SID'"   # v2.0.19: the tap brake (400 per 5 min) is tested below; start clean
CB=$(db "SELECT coins FROM users WHERE id=$SID")
assert "200 cheap POSTs (rest / camp / mode / leave / enter ...): XP and level unchanged" eq "$(db "SELECT xp||':'||level FROM users WHERE id=$SID")" "$XPA"
assert "...Petals only ever went down (kits bought), never up ($CA -> $CB)" test "$CB" -le "$CA"
assert "...no errors" eq "$(errlog)" 0
dbx "INSERT OR REPLACE INTO settings (name,value) VALUES ('trek_event_pct','40'),('trek_event_gap','1'),('trek_enc_percent','60')"
CAP=$(db "SELECT COALESCE((SELECT value FROM settings WHERE name='trek_petals_daily'),'150')")
dbx "UPDATE users SET coins=0, energy=100 WHERE id=$SID"; th sprout tp start >/dev/null; th sprout xy 5 15 >/dev/null
OUT=$(th sprout farm 600); echo "    $OUT"
th sprout tp camp >/dev/null; post trek.php -d do=rest >/dev/null
GAIN=$(db "SELECT coins - COALESCE((SELECT SUM(m.reward_coins) FROM user_milestones um JOIN almanac_milestones m ON m.id=um.milestone_id WHERE um.user_id=$SID),0) FROM users WHERE id=$SID")   # minus the one-time Almanac page rewards (a separate, once-per-player system)
assert "farming 600 walks / events / fights: trek Petals banked ($GAIN) <= the daily cap ($CAP)" test "$GAIN" -le "$CAP"
assert "...gnome XP and level unchanged (trek XP never becomes main XP)" eq "$(db "SELECT xp||':'||level FROM users WHERE id=$SID")" "$XPA"
dbx "DELETE FROM settings WHERE name IN ('trek_event_pct','trek_event_gap','trek_enc_percent')"
assert "the farm left the error log empty" eq "$(errlog)" 0

echo "== 10. Huge inputs"
freshrun sprout; use sprout; th sprout flag won_fight >/dev/null; th sprout fight g >/dev/null
TK=$(tokof $JAR)
ARGS=(); for i in $(seq 1 600); do ARGS+=(-d "a[$i]=attack" -d "t[$i]=f:$i"); done
c=$(curl -s -c $JAR -b $JAR -X POST "$BASE/trek.php" -d "csrf=$TK" -d do=round "${ARGS[@]}" -o /dev/null -w '%{http_code}'); assert "round with 1200 a[] / t[] keys: no 500 ($c)" test "$c" != 500
PLAN=$(th sprout stkey plan | wc -c)
assert "...the saved fight plan keeps only party places (plan $PLAN bytes, want < 600)" test "$PLAN" -lt 600
head -c 300000 /dev/zero | tr '\0' 'Z' > $TMP/big.txt
c=$(curl -s -c $JAR -b $JAR -X POST "$BASE/trek.php" -d "csrf=$TK" -d do=tactics -d slot=0 --data-urlencode "rule@$TMP/big.txt" --data-urlencode "open@$TMP/big.txt" -o /dev/null -w '%{http_code}'); assert "300 KB values: no 500 ($c)" test "$c" != 500
assert "...nothing from it stored (state stays small)" bash -c "[ \$(php $TMP/th.php $GAME sprout state | wc -c) -lt 30000 ]"
# v2.0.19: tap brake. 405 cheap POSTs in a row: the flash says "Easy there", and after clearing the log the page works again.
dbx "DELETE FROM login_attempts WHERE username='trek:$SID'"
dbx "INSERT INTO login_attempts (ip, username, attempted_at) SELECT '127.0.0.1', 'trek:$SID', datetime('now') FROM (WITH RECURSIVE n(i) AS (SELECT 1 UNION ALL SELECT i+1 FROM n WHERE i<400) SELECT i FROM n)"
post trek.php -d do=dismiss -d t=map >/dev/null; get trek.php >/dev/null
assert "tap brake: the 401st trek POST in 5 minutes is refused" grep -q 'Easy there' $H
dbx "DELETE FROM login_attempts WHERE username='trek:$SID'"
post trek.php -d do=enter -d mode=gentle >/dev/null
DEEP=""; for i in $(seq 1 60); do DEEP="$DEEP[x]"; done
c=$(curl -s -c $JAR -b $JAR -X POST "$BASE/trek.php" -d "csrf=$TK" -d do=round --data-urlencode "a$DEEP=attack" --data-urlencode "t$DEEP=f:1" -d "slot$DEEP=1" -o /dev/null -w '%{http_code}'); assert "60-deep nested arrays: no 500 ($c)" test "$c" != 500
for i in 1 2 3; do c=$(curl -s -c $JAR -b $JAR -X POST "$BASE/trek.php" -d "csrf=$TK" -d do=go --data-urlencode "go@$TMP/big.txt" -o /dev/null -w '%{http_code}'); [ "$c" = 500 ] && bad "go with a 300 KB value gave 500"; done
c=$(curl -s -c $JAR -b $JAR -X POST "$BASE/admin/treks.php" -d "csrf=$TK" --data-urlencode "run@$TMP/big.txt" --data-urlencode "confirm@$TMP/big.txt" -o /dev/null -w '%{http_code}'); assert "admin reset with a huge run id (as a player): no 500 ($c)" test "$c" != 500
assert "error log empty after the huge inputs" eq "$(errlog)" 0
get trek.php >/dev/null; assert "the trek page still renders after all of it" grep -q 'class="trekfight\|class="trekmap' $H

echo "== PHP warnings in the server log"
W=$(grep -E 'Warning|Notice|Deprecated|Fatal|Parse error' $LOG | grep -v 'Input variables exceeded' | head -8)
if [ -n "$W" ]; then echo "$W" | sed 's/^/  PHP: /'; bad "PHP warnings / notices were logged"; else ok "no PHP warnings or notices"; fi
echo
if [ "$FAILN" = 0 ]; then echo "ALL PASSED (no failures)"; else echo "$FAILN FAILED"; fi
exit $((FAILN>0))
