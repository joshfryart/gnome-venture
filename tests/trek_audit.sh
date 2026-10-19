#!/bin/bash
# Treks engine audit (1.9.8), over HTTP: who may call what (login, admin, CSRF), bad input, two logins firing the same POST at the same moment
# (real races: the built-in server runs with workers), escaping of text an admin wrote, the admin pages and the reset. Then the in-process audit
# (tests/trek_audit_engine.php: once-only payouts, caps, rest numbers, knock-out, old and damaged state, settings at the extremes).
# Usage: tests/trek_audit.sh [GAME_COPY_DIR] [PORT] [ROUTER]
HERE=$(cd "$(dirname "$0")" && pwd)
GAME=${1:-}; PORT=${2:-8795}; ROUTER=${3:-$HERE/router.php}
if [ -z "$GAME" ]; then T=$(mktemp -d); cp -r "$HERE/../game" "$T/game"; GAME=$T/game; fi
rm -f "$GAME/config.php"; rm -rf "$GAME/data"; mkdir -p "$GAME/data"
BASE=http://127.0.0.1:$PORT
LOG=$(mktemp); W=$(mktemp -d); FAILS=0
PHP_CLI_SERVER_WORKERS=8 php -d session.save_path=/tmp -d display_errors=1 -S 127.0.0.1:$PORT -t "$GAME" "$ROUTER" >$LOG 2>&1 & PID=$!; sleep 1
trap "kill $PID 2>/dev/null" EXIT
H=$W/h
ok() { if [ "$2" = 1 ]; then echo "  ok   $1"; else echo "  FAIL $1  $3"; FAILS=$((FAILS+1)); fi; }
csrf() { grep -o 'name="csrf" value="[^"]*"' "$1" | head -1 | sed 's/.*value="\([^"]*\)".*/\1/'; }
jar() { echo "$W/jar$1"; }
get() { local j=$1; shift; curl -s -c $(jar $j) -b $(jar $j) "$BASE/$1" -o $H -w '%{http_code}'; }
post() { local j=$1 page=$2; shift 2; curl -s -c $(jar $j) -b $(jar $j) -X POST "$BASE/$page" --data-urlencode "csrf=$(csrf $H)" "$@" -o $H -w '%{http_code}'; }
db() { php -r '$p=new PDO("sqlite:'$GAME'/data/game.sqlite"); foreach($p->query($argv[1])->fetchAll(PDO::FETCH_NUM) as $r) echo implode(" | ",$r),"\n";' "$1"; }
dbx() { php -r '$p=new PDO("sqlite:'$GAME'/data/game.sqlite"); $p->exec($argv[1]);' "$1"; }
login() { local j=$1 u=$2 p=$3; rm -f $(jar $j); get $j login.php >/dev/null; post $j login.php -d username=$u -d "password=$p" >/dev/null; }
# a state helper: php STATE.php GAME cmd
cat > $W/state.php <<'PHP'
<?php
$_SERVER["SCRIPT_NAME"] = "/trek.php"; require $argv[1] . "/includes/bootstrap.php"; require_once $argv[1] . "/includes/trek.php";
$uid = (int)q_val("SELECT id FROM users WHERE username = 'sprout'"); $cmd = $argv[2];
function clean($uid) { foreach (['trek_flags', 'trek_pack', 'trek_party', 'trek_recruits'] as $t) q("DELETE FROM $t WHERE run_id IN (SELECT id FROM trek_runs WHERE user_id = ?)", [$uid]); q('DELETE FROM trek_runs WHERE user_id = ?', [$uid]); q('DELETE FROM trek_ms WHERE user_id = ?', [$uid]);
  q('UPDATE users SET level = 15, energy = 500, coins = 1000, trek_ch = 1, trek_pet_day = NULL, trek_pet_today = 0, xp = 0 WHERE id = ?', [$uid]); }
$tp = function ($code, $ch = 1) use ($uid) { trek_tx($uid, function (&$run, $u) use ($code, $ch) { $sp = trek_spots($ch)[$code]; $run['inside'] = 1; $run['fi'] = null; $run['x'] = $sp['x']; $run['y'] = $sp['y']; $run['sn'] = str_repeat("\xff", strlen($run['sn'])); return [true, '']; }, true, $ch); };
switch ($cmd) {
    case 'clean': clean($uid); break;
    case 'enter': clean($uid); trek_tx($uid, fn(&$run, $u) => trek_enter($run, $u), false); break;
    case 'camp': clean($uid); trek_tx($uid, fn(&$run, $u) => trek_enter($run, $u), false); $tp('camp'); trek_tx($uid, function (&$run, $u) { $run['campkits'] = 0; $run['camp'] = 'camp'; return [true, '']; }); break;
    case 'chest': clean($uid); trek_tx($uid, fn(&$run, $u) => trek_enter($run, $u), false); $tp('cellar'); trek_tx($uid, function (&$run, $u) { trek_pack_add((int)$run['id'], trek_item_id('cellar-key'), 1); $run['campkits'] = 0; return [true, '']; }); break;
    case 'recruit': clean($uid); trek_tx($uid, fn(&$run, $u) => trek_enter($run, $u), false); $tp('burdock'); break;
    case 'event': clean($uid); trek_tx($uid, fn(&$run, $u) => trek_enter($run, $u), false); trek_tx($uid, function (&$run, $u) { $run['st']['ev'] = ['id' => 'stash']; return [true, '']; }); break;
    case 'fight': clean($uid); trek_tx($uid, fn(&$run, $u) => trek_enter($run, $u), false); trek_tx($uid, function (&$run, $u) { $run['sn'] = str_repeat("\xff", strlen($run['sn'])); trek_flag_set($run, 'won_fight'); trek_start_random_fight($run, $u, 'g'); foreach ($run['fi']['foes'] as $i => $f) { $run['fi']['foes'][$i]['hp'] = $run['fi']['foes'][$i]['max'] = 60; $run['fi']['foes'][$i]['atk'] = -50; } return [true, '']; }); break;
    case 'hub': clean($uid); trek_tx($uid, fn(&$run, $u) => trek_enter($run, $u), false); trek_tx($uid, function (&$run, $u) { trek_recruit_crew($run, $u, 'burdock'); $run['petals_found'] = 12; trek_complete_chapter($run, $u); return [true, '']; }); q('UPDATE users SET coins = 1000, energy = 500 WHERE id = ?', [$uid]); break;
    case 'ch2done': clean($uid); trek_tx($uid, fn(&$run, $u) => trek_enter($run, $u), false); trek_tx($uid, function (&$run, $u) { trek_complete_chapter($run, $u); trek_hub_arrive($run, $u); return [true, '']; }); trek_tx($uid, function (&$run, $u) { return trek_godown($run, $u); }); trek_tx($uid, function (&$run, $u) { trek_complete_chapter($run, $u); trek_hub_arrive($run, $u); return [true, '']; }); break;
}
PHP
st() { php $W/state.php "$GAME" "$1"; }

echo "== install + players"
get 0 install.php >/dev/null
post 0 install.php -d driver=sqlite -d "site_name=Gnome Venture" -d base_url= -d admin_user=admin -d admin_email=a@b.local -d admin_pass=TestPassword123 -d admin_pass2=TestPassword123 >/dev/null
grep -q 'All planted' $H && echo installed || { echo "INSTALL FAILED"; tail -5 $LOG; exit 1; }
rm -f $(jar 0)
get 0 register.php >/dev/null; post 0 register.php -d username=sprout -d email=s@b.local -d password=TestPass123! -d password2=TestPass123! -d rules=1 -d age=1 >/dev/null
get 0 welcome.php >/dev/null; post 0 welcome.php -d do=gnome -d "gnome_name=Bramble" -d 'hat=#2e7d4f' -d 'beard=#b5651d' >/dev/null
get 0 'welcome.php?step=place' >/dev/null
RID=$(db "SELECT id FROM regions WHERE code='NA'")
VID=$(db "SELECT l.id FROM locations l WHERE l.region_id=$RID AND l.kind='village' AND EXISTS (SELECT 1 FROM routes r WHERE r.kind='road' AND (r.a_id=l.id OR r.b_id=l.id)) ORDER BY l.sort_order LIMIT 1 OFFSET 1")
post 0 welcome.php -d do=place -d village_id=$VID >/dev/null
get 0 'welcome.php?step=garden' >/dev/null; post 0 welcome.php -d do=finish -d 'garden_name=Test Patch' >/dev/null
dbx "UPDATE users SET level=15, energy=500, coins=1000, onboarded=1 WHERE username IN ('sprout','admin')"
dbx "INSERT OR REPLACE INTO settings (name, value) VALUES ('trek_open','1')"
dbx "INSERT OR REPLACE INTO settings (name, value) VALUES ('trek_event_pct','0')"
dbx "INSERT OR REPLACE INTO settings (name, value) VALUES ('trek_ambush_pct','0')"
for j in 1 2 3 4 5; do login $j sprout 'TestPass123!'; done
login 9 admin TestPassword123
UID_=$(db "SELECT id FROM users WHERE username='sprout'")

echo "== who may call what"
rm -f $(jar 8)
echo "  logged out: GET trek.php -> $(get 8 trek.php) $(curl -s -o /dev/null -w '%{redirect_url}' $BASE/trek.php | sed 's#.*/##')"
c=$(curl -s -o /dev/null -w '%{http_code}' -X POST $BASE/trek.php -d do=begin -d csrf=x); ok "logged out POST is refused (got $c)" $([ "$c" = 302 ] || [ "$c" = 400 ] || [ "$c" = 403 ] && echo 1 || echo 0)
ok "...and made no run" $([ "$(db 'SELECT COUNT(*) FROM trek_runs')" = 0 ] && echo 1 || echo 0)
st enter
for pg in admin/treks.php admin/trek_text.php; do
  c=$(get 1 $pg); body=$(grep -c 'Trek story text\|Reset run' $H)
  ok "player cannot open $pg (got $c, admin text on page: $body)" $([ "$body" = 0 ] && echo 1 || echo 0)
done
get 1 admin/treks.php >/dev/null
RUNID=$(db 'SELECT id FROM trek_runs'); c=$(post 1 admin/treks.php -d run=$RUNID -d confirm=RESET)
ok "player POST to admin/treks.php does not reset (run still there: $(db 'SELECT COUNT(*) FROM trek_runs'))" $([ "$(db 'SELECT COUNT(*) FROM trek_runs')" = 1 ] && echo 1 || echo 0)
KEY=ch1.intro; B0=$(db "SELECT COALESCE(body,'') FROM trek_texts WHERE text_key='$KEY'")
c=$(post 1 admin/trek_text.php -d key=$KEY -d body=pwned -d status=done)
ok "player POST to admin/trek_text.php does not write" $([ "$(db "SELECT COALESCE(body,'') FROM trek_texts WHERE text_key='$KEY'")" = "$B0" ] && echo 1 || echo 0)
get 9 admin/treks.php >/dev/null
c=$(curl -s -c $(jar 9) -b $(jar 9) -X POST $BASE/admin/treks.php -d run=$RUNID -d confirm=RESET -o /dev/null -w '%{http_code}')
ok "admin POST without a CSRF token is refused (got $c), run kept" $([ "$c" = 400 ] || [ "$c" = 403 ] && [ "$(db 'SELECT COUNT(*) FROM trek_runs')" = 1 ] && echo 1 || echo 0)

echo "== bad input never gives a 500 and never moves anything"
st enter
get 1 trek.php >/dev/null
S0=$(db "SELECT x||','||y||','||fatigue||','||campkits||','||petals_found FROM trek_runs"); C0=$(db "SELECT coins FROM users WHERE username='sprout'")
bad() { local c; get 1 trek.php >/dev/null; c=$(post 1 trek.php "$@"); if [ "$c" -ge 500 ]; then echo "  FAIL 500 for: $*"; FAILS=$((FAILS+1)); fi; }
for a in "-d do=nonsense" "-d do[]=x" "-d do=" "-d t[]=x -d do=go" "-d do=go -d go=abc" "-d do=go -d go=99,99" "-d do=go -d go=-1,2" "-d do=go -d go=1,2,3" "-d do=go -d go[]=1,1" "-d do=go -d go=000000000001,1" \
  "-d do=go -d go=3,3;DROP" "-d do=round -d a[]=x" "-d do=round -d a[0]=zzz -d t[0]=f:9999 -d item=-5" "-d do=round -d a[9]=attack" "-d do=riddle -d ans=abc" "-d do=riddle -d ans[]=1" "-d do=riddle -d how=%00" \
  "-d do=travel -d to=../../etc/passwd" "-d do=travel -d to[]=x" "-d do=talk -d who=<script>" "-d do=party -d p1[]=x -d p2=ghost -d p3=burdock" "-d do=party -d p1=burdock -d p2=burdock -d p3=burdock" \
  "-d do=tactics -d slot=99 -d open=zzz" "-d do=tactics -d slot=-1" "-d do=tactics -d slot=0 -d open[]=x -d rule=nope -d pct=999 -d target=zzz -d snack=1" "-d do=event -d c=99" "-d do=event -d c=abc" "-d do=crew -d c=99" "-d do=cart -d how=zzz" \
  "-d do=mode -d mode=zzz" "-d do=godown" "-d do=dismiss" "-d do=msdismiss" "-d do=auto" "-d do=flee" "-d do=challenge" "-d do=recruit" "-d do=fetch" "-d do=chest" "-d do=grotto" "-d do=switch" "-d do=trade" "-d do=rest_spot" "-d do=slide" "-d do=mush" "-d t=<x>" "-d t=party"; do
  bad $a
done
for t in zzz 'party&x=1' '../x' 'map%00' 'log"><script>'; do c=$(get 1 "trek.php?t=$t"); [ "$c" -ge 500 ] && { echo "  FAIL 500 for ?t=$t"; FAILS=$((FAILS+1)); }; done
S1=$(db "SELECT x||','||y||','||fatigue||','||campkits||','||petals_found FROM trek_runs"); C1=$(db "SELECT coins FROM users WHERE username='sprout'")
ok "forged input changed nothing it should not (position/fatigue/kits/Petals $S0 -> $S1, purse $C0 -> $C1)" $([ "$S0" = "$S1" ] && [ "$C0" = "$C1" ] && echo 1 || echo 0)
ok "no tactics were saved from the forged posts" $([ "$(db "SELECT state FROM trek_runs" | grep -c '"tac"')" = 0 ] && echo 1 || echo 0)
get 1 trek.php >/dev/null; ok "the map still renders" $(grep -q 'class="trekmap' $H && echo 1 || echo 0)
ok "party tab, pack tab, log tab render" $([ "$(get 1 'trek.php?t=party')" = 200 ] && [ "$(get 1 'trek.php?t=pack')" = 200 ] && [ "$(get 1 'trek.php?t=log')" = 200 ] && echo 1 || echo 0)

echo "== text from the admin and from players is escaped"
dbx "UPDATE trek_texts SET body='<script>alert(1)</script> <b>{gnome}</b> \"q\" {currency}', status='done' WHERE text_key IN ('ch1.intro','ch1.tut.walk','ch1.zone.g.arrive','ch1.spot.start.arrive')"
dbx "UPDATE users SET gnome_name='<img src=x onerror=alert(2)>' WHERE username='sprout'"
st enter; get 1 trek.php >/dev/null
ok "no raw <script> or <img> on the map page" $([ "$(grep -c '<script>alert\|<img src=x onerror' $H)" = 0 ] && echo 1 || echo 0)
ok "the text is there, escaped" $(grep -q '&lt;script&gt;alert(1)&lt;/script&gt;' $H && echo 1 || echo 0)
get 1 'trek.php?t=log' >/dev/null; ok "log tab: no raw <script>" $([ "$(grep -c '<script>alert' $H)" = 0 ] && echo 1 || echo 0)
get 1 'trek.php?t=party' >/dev/null; ok "party tab: no raw gnome-name markup" $([ "$(grep -c '<img src=x onerror' $H)" = 0 ] && echo 1 || echo 0)
st fight; get 1 trek.php >/dev/null; ok "fight screen: no raw gnome-name markup" $([ "$(grep -c '<img src=x onerror\|<script>alert' $H)" = 0 ] && echo 1 || echo 0)
post 1 trek.php -d do=auto >/dev/null; get 1 trek.php >/dev/null
ok "Auto replay data: no raw markup" $([ "$(grep -c '<img src=x onerror\|<script>alert' $H)" = 0 ] && echo 1 || echo 0)
get 9 admin/trek_text.php >/dev/null; get 9 'admin/trek_text.php?open=ch1.intro' >/dev/null
ok "editor shows the body escaped (textarea cannot be closed early)" $([ "$(grep -c '<script>alert' $H)" = 0 ] && echo 1 || echo 0)
dbx "UPDATE users SET gnome_name=NULL WHERE username='sprout'"
dbx "UPDATE trek_texts SET body=NULL, status='todo' WHERE text_key IN ('ch1.intro','ch1.tut.walk','ch1.zone.g.arrive','ch1.spot.start.arrive')"

echo "== the same POST from several logins at the same moment"
par() { # par "page" args...  : every jar 1..5 posts the same thing at once; prints the codes
    local page=$1; shift; local j codes=""
    for j in 1 2 3 4 5; do get $j trek.php >/dev/null; cp $H $W/t$j; done
    for j in 1 2 3 4 5; do
        ( curl -s -c $(jar $j) -b $(jar $j) -X POST "$BASE/$page" --data-urlencode "csrf=$(csrf $W/t$j)" "$@" -o /dev/null -w '%{http_code}\n' > $W/c$j ) &
    done
    wait
    for j in 1 2 3 4 5; do codes="$codes $(cat $W/c$j)"; done
    echo $codes
}
no500() { case " $1 " in *" 500 "*|*" 502 "*|*" 000 "*) return 1;; esac; return 0; }
st clean
E0=$(db "SELECT energy FROM users WHERE username='sprout'")
codes=$(par trek.php -d do=begin -d t=map)
ok "5 x Begin: no error ($codes)" $(no500 "$codes" && echo 1 || echo 0)
ok "5 x Begin: one run, energy spent once ($E0 -> $(db "SELECT energy FROM users WHERE username='sprout'"))" $([ "$(db 'SELECT COUNT(*) FROM trek_runs')" = 1 ] && [ "$(db "SELECT energy FROM users WHERE username='sprout'")" = $((E0-10)) ] && echo 1 || echo 0)
ok "5 x Begin: one gnome in the party, one start" $([ "$(db 'SELECT COUNT(*) FROM trek_party')" = 1 ] && echo 1 || echo 0)

st camp
codes=$(par trek.php -d do=buy_kit -d t=map)
ok "5 x Camp Kit: no error ($codes)" $(no500 "$codes" && echo 1 || echo 0)
K=$(db 'SELECT campkits FROM trek_runs'); C=$(db "SELECT coins FROM users WHERE username='sprout'")
ok "5 x Camp Kit: 3 kits (the most), paid 3 x 60 only (kits $K, purse $C)" $([ "$K" = 3 ] && [ "$C" = 820 ] && echo 1 || echo 0)

st chest
codes=$(par trek.php -d do=chest -d t=map)
ok "5 x Open the chest: no error ($codes)" $(no500 "$codes" && echo 1 || echo 0)
ok "5 x Open the chest: 2 kits and 120 Petals once ($(db 'SELECT campkits||" kits, "||petals_found FROM trek_runs'))" $([ "$(db 'SELECT campkits||","||petals_found FROM trek_runs')" = "2,120" ] && echo 1 || echo 0)

st recruit
X0=$(db "SELECT xp FROM users WHERE username='sprout'")
codes=$(par trek.php -d do=recruit -d t=map)
ok "5 x Help Burdock: no error ($codes)" $(no500 "$codes" && echo 1 || echo 0)
ok "5 x Help Burdock: one recruit, two party places, one milestone paid" $([ "$(db 'SELECT COUNT(*) FROM trek_recruits')" = 1 ] && [ "$(db 'SELECT COUNT(*) FROM trek_party')" = 2 ] && [ "$(db 'SELECT COUNT(*) FROM trek_ms')" = 1 ] && echo 1 || echo 0)
ok "5 x Help Burdock: friendship 20 once" $([ "$(db "SELECT points FROM npc_friends WHERE user_id=$UID_ AND npc_id=(SELECT id FROM npcs WHERE slug='burdock-deepdelve')")" = 20 ] && echo 1 || echo 0)

st event
codes=$(par trek.php -d do=event -d c=1 -d t=map)
ok "5 x trail event choice: no error ($codes)" $(no500 "$codes" && echo 1 || echo 0)
P=$(db 'SELECT petals_found FROM trek_runs'); ok "5 x trail event choice: paid once (Petals $P, at most 14)" $([ "$P" -ge 6 ] && [ "$P" -le 14 ] && [ "$(db "SELECT state FROM trek_runs" | grep -o '"evn":[0-9]*')" = '"evn":1' ] && echo 1 || echo 0)

st fight
codes=$(par trek.php -d do=auto -d t=map)
ok "5 x Auto: no error ($codes)" $(no500 "$codes" && echo 1 || echo 0)
ok "5 x Auto: the fight is over once; the daily Petal count is within the limit" $([ "$(db 'SELECT COUNT(*) FROM trek_runs WHERE fight IS NOT NULL')" = 0 ] && [ "$(db "SELECT trek_pet_today FROM users WHERE username='sprout'")" -le 150 ] && echo 1 || echo 0)
st fight
codes=$(par trek.php -d do=round -d 'a[0]=attack' -d t=map)
ok "5 x Fight round: no error ($codes), each round played on top of the last" $(no500 "$codes" && echo 1 || echo 0)

st enter
codes=$(par trek.php -d do=go -d go=5,15 -d t=map)
ok "5 x walk to the same tile: no error ($codes)" $(no500 "$codes" && echo 1 || echo 0)
codes=$(par trek.php -d do=tactics -d slot=0 -d open=guard -d target=strong -d t=party)
ok "5 x save tactics: no error ($codes)" $(no500 "$codes" && echo 1 || echo 0)
codes=$(par trek.php -d do=mode -d mode=sneak -d t=map)
ok "5 x Sneak: no error ($codes)" $(no500 "$codes" && echo 1 || echo 0)

st hub
E0=$(db "SELECT energy FROM users WHERE username='sprout'"); C0=$(db "SELECT coins FROM users WHERE username='sprout'")
codes=$(par trek.php -d do=godown -d t=map)
ok "5 x Go down: no error ($codes)" $(no500 "$codes" && echo 1 || echo 0)
ok "5 x Go down: Chapter II made once, energy spent once ($E0 -> $(db "SELECT energy FROM users WHERE username='sprout'"))" $([ "$(db 'SELECT COUNT(*) FROM trek_runs')" = 2 ] && [ "$(db "SELECT energy FROM users WHERE username='sprout'")" = $((E0-10)) ] && [ "$(db "SELECT trek_ch FROM users WHERE username='sprout'")" = 2 ] && echo 1 || echo 0)
ok "5 x Go down: the party came along once (2 places)" $([ "$(db 'SELECT COUNT(*) FROM trek_party WHERE run_id=(SELECT id FROM trek_runs WHERE chapter=2)')" = 2 ] && echo 1 || echo 0)

st hub
C0=$(db "SELECT coins FROM users WHERE username='sprout'")
codes=$(par trek.php -d do=rest -d t=map)
ok "5 x Rest and bank at the interlude: no error ($codes)" $(no500 "$codes" && echo 1 || echo 0)
ok "...banked once (carried Petals 12 are in the purse once: $C0 -> $(db "SELECT coins FROM users WHERE username='sprout'"))" $([ "$(db "SELECT coins FROM users WHERE username='sprout'")" -le $((C0+12)) ] && echo 1 || echo 0)

echo "== the admin pages"
for q in "" "?ch=1" "?ch=2&status=draft" "?ch=i" "?ch=abc" "?ch=-5" "?ch=99999999999999999999" "?kind=zzz" "?status=zzz" "?p=0" "?p=999" "?p=abc" "?only=1&ch=2" "?open=nope.x" "?open=ch2.intro&ch=2" "?ch[]=1" "?kind[]=x"; do
  c=$(get 9 "admin/trek_text.php$q"); if [ "$c" -ge 500 ] || grep -qE 'Warning:|Notice:|Deprecated:|Fatal' $H; then echo "  FAIL admin/trek_text.php$q -> $c"; FAILS=$((FAILS+1)); fi
done
ok "the editor takes odd filters without errors" 1
get 9 admin/trek_text.php >/dev/null
c=$(post 9 admin/trek_text.php -d key=ch1.intro -d "body=$(head -c 4100 /dev/zero | tr '\0' 'x')" -d status=done)
ok "a body over 4000 letters is refused" $([ "$(db "SELECT length(COALESCE(body,'')) FROM trek_texts WHERE text_key='ch1.intro'")" -le 4000 ] && echo 1 || echo 0)
get 9 admin/trek_text.php >/dev/null
post 9 admin/trek_text.php -d key=ch1.intro -d 'body=Hello {gnome}.' -d status=bogus >/dev/null
ok "an unknown status falls back to the old one (saved as draft/todo, not bogus): $(db "SELECT status FROM trek_texts WHERE text_key='ch1.intro'")" $([ "$(db "SELECT status FROM trek_texts WHERE text_key='ch1.intro'")" != bogus ] && echo 1 || echo 0)
get 9 admin/trek_text.php >/dev/null
post 9 admin/trek_text.php -d key=ch1.intro -d body= -d status=done >/dev/null
ok "an empty body turns the slot back to to-do" $([ "$(db "SELECT status FROM trek_texts WHERE text_key='ch1.intro'")" = todo ] && echo 1 || echo 0)
get 9 admin/trek_text.php >/dev/null
c=$(post 9 admin/trek_text.php -d key=ch1.intro -d restore=1)
ok "Restore on a slot with a suggestion works / a slot without one says so (no 500: $c)" $([ "$c" -lt 500 ] && echo 1 || echo 0)
get 9 admin/trek_text.php >/dev/null; c=$(post 9 admin/trek_text.php -d "key[]=x" -d body=y)
ok "key sent as an array: no 500 ($c)" $([ "$c" -lt 500 ] && echo 1 || echo 0)

echo "== admin run list and reset"
st ch2done
get 9 admin/treks.php >/dev/null; ok "the runs list shows both chapters" $([ "$(grep -c 'Reset run' $H)" = 2 ] && grep -q 'Chapter II' $H && echo 1 || echo 0)
R2=$(db "SELECT id FROM trek_runs WHERE chapter=2"); R1=$(db "SELECT id FROM trek_runs WHERE chapter=1")
c=$(post 9 admin/treks.php -d run=$R2 -d confirm=reset)
ok "reset needs RESET in capitals (lower case refused), run kept" $([ "$(db "SELECT COUNT(*) FROM trek_runs WHERE id=$R2")" = 1 ] && echo 1 || echo 0)
get 9 admin/treks.php >/dev/null; c=$(post 9 admin/treks.php -d run=$R2 -d confirm=RESET)
ok "reset of Chapter II removes only that run and its rows" $([ "$(db "SELECT COUNT(*) FROM trek_runs WHERE id=$R2")" = 0 ] && [ "$(db "SELECT COUNT(*) FROM trek_party WHERE run_id=$R2")" = 0 ] && [ "$(db "SELECT COUNT(*) FROM trek_flags WHERE run_id=$R2")" = 0 ] && [ "$(db "SELECT COUNT(*) FROM trek_runs WHERE id=$R1")" = 1 ] && echo 1 || echo 0)
ok "...and puts the gnome back in the Chapter I interlude" $([ "$(db "SELECT trek_ch FROM users WHERE username='sprout'")" = 1 ] && echo 1 || echo 0)
get 1 trek.php >/dev/null; ok "...where the player sees the rest stop and Go down" $(grep -q 'name="do" value="godown"' $H && echo 1 || echo 0)
get 9 admin/treks.php >/dev/null; c=$(post 9 admin/treks.php -d run=999999 -d confirm=RESET); ok "reset of a run that is gone: no 500 ($c)" $([ "$c" -lt 500 ] && echo 1 || echo 0)
get 9 admin/treks.php >/dev/null; c=$(post 9 admin/treks.php -d "run[]=1" -d confirm=RESET); ok "run sent as an array: no 500 ($c)" $([ "$c" -lt 500 ] && echo 1 || echo 0)

echo "== the in-process audit"
php -d display_errors=1 -d error_reporting=-1 "$HERE/trek_audit_engine.php" "$GAME" 2>&1 | grep -v "^  ok"; [ "${PIPESTATUS[0]}" = 0 ] || FAILS=$((FAILS+1))

echo "== error log and server log"
test -s $GAME/data/error-log.txt && { echo "  ERROR LOG HAS ENTRIES:"; head -8 $GAME/data/error-log.txt; FAILS=$((FAILS+1)); } || echo "  error log empty"
grep -E 'Warning|Notice|Deprecated|Fatal|Parse error' $LOG | head -5 | sed 's/^/  PHP: /'
echo "done ($FAILS failed)"
[ "$FAILS" = 0 ]
