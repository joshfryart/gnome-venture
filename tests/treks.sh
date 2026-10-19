#!/bin/bash
# Treks (1.8.0): fresh SQLite install in a temp copy, tests/trek.php (engine), then page renders over HTTP.
# Usage: tests/treks.sh [GAME_COPY_DIR] [PORT] [ROUTER]
HERE=$(cd "$(dirname "$0")" && pwd)
GAME=${1:-}; PORT=${2:-8794}; ROUTER=${3:-$HERE/router.php}
if [ -z "$GAME" ]; then T=$(mktemp -d); cp -r "$HERE/../game" "$T/game"; GAME=$T/game; fi
rm -f "$GAME/config.php"; rm -rf "$GAME/data"; mkdir -p "$GAME/data"
BASE=http://127.0.0.1:$PORT
LOG=$(mktemp)
php -d session.save_path=/tmp -d display_errors=1 -S 127.0.0.1:$PORT -t "$GAME" "$ROUTER" >$LOG 2>&1 & PID=$!; sleep 1
trap "kill $PID 2>/dev/null" EXIT
C=$(mktemp); H=$(mktemp)
csrf() { grep -o 'name="csrf" value="[^"]*"' "$1" | head -1 | sed 's/.*value="\([^"]*\)".*/\1/'; }
get() { curl -s -c $C -b $C "$BASE/$1" -o $H -w '%{http_code}'; }
post() { local page=$1; shift; curl -s -c $C -b $C -X POST "$BASE/$page" --data-urlencode "csrf=$(csrf $H)" "$@" -o $H -w '%{http_code}'; }
db() { php -r '$p=new PDO("sqlite:'$GAME'/data/game.sqlite"); foreach($p->query($argv[1])->fetchAll(PDO::FETCH_NUM) as $r) echo implode(" | ",$r),"\n";' "$1"; }
dbx() { php -r '$p=new PDO("sqlite:'$GAME'/data/game.sqlite"); $p->exec($argv[1]);' "$1"; }
echo "== install + register + welcome"
get install.php >/dev/null
post install.php -d driver=sqlite -d "site_name=Gnome Venture" -d base_url= -d admin_user=admin -d admin_email=a@b.local -d admin_pass=TestPassword123 -d admin_pass2=TestPassword123 >/dev/null
grep -q 'All planted' $H && echo installed || { echo "INSTALL FAILED"; tail -5 $LOG; exit 1; }
rm -f $C
get register.php >/dev/null; post register.php -d username=sprout -d email=s@b.local -d password=TestPass123! -d password2=TestPass123! -d rules=1 -d age=1 >/dev/null
get welcome.php >/dev/null; post welcome.php -d do=gnome -d "gnome_name=Bramble" -d 'hat=#2e7d4f' -d 'beard=#b5651d' >/dev/null
get 'welcome.php?step=place' >/dev/null
RID=$(db "SELECT id FROM regions WHERE code='NA'")
VID=$(db "SELECT l.id FROM locations l WHERE l.region_id=$RID AND l.kind='village' AND EXISTS (SELECT 1 FROM routes r WHERE r.kind='road' AND (r.a_id=l.id OR r.b_id=l.id)) ORDER BY l.sort_order LIMIT 1 OFFSET 1")
post welcome.php -d do=place -d village_id=$VID >/dev/null
get 'welcome.php?step=garden' >/dev/null; post welcome.php -d do=finish -d 'garden_name=Test Patch' >/dev/null
echo "onboarded: $(db "SELECT onboarded FROM users WHERE username='sprout'")"
echo "== pages while closed / low level"
dbx "UPDATE users SET level=3, energy=100 WHERE username='sprout'"
echo "trek.php (level 3) -> $(get trek.php)"; grep -q 'open at gnome level' $H && echo "  level gate shown"
dbx "UPDATE users SET level=15 WHERE username='sprout'"
echo "trek.php (closed) -> $(get trek.php)"; grep -q 'not open yet' $H && echo "  closed message shown"
echo "begin while closed -> $(post trek.php -d do=begin)"; echo "  runs: $(db 'SELECT COUNT(*) FROM trek_runs')"
echo "== engine (tests/trek.php)"
php -d display_errors=1 -d error_reporting=-1 "$HERE/trek.php" "$GAME" 2>&1; RC=$?
echo "== tactics + Auto AI (tests/trek_tactics.php)"
php -d display_errors=1 -d error_reporting=-1 "$HERE/trek_tactics.php" "$GAME" 2>&1 | grep -v "^  ok" ; [ "${PIPESTATUS[0]}" = 0 ] || RC=1
echo "== trail events, side stops, crew moments, fight log (tests/trek_events.php)"
php -d display_errors=1 -d error_reporting=-1 "$HERE/trek_events.php" "$GAME" 2>&1 | grep -v "^  ok" ; [ "${PIPESTATUS[0]}" = 0 ] || RC=1
echo "== trek levels, milestones, migration, balance sim (tests/trek_levels.php)"
php -d display_errors=1 -d error_reporting=-1 "$HERE/trek_levels.php" "$GAME" 2>&1 | grep -v "^  ok" ; [ "${PIPESTATUS[0]}" = 0 ] || RC=1
echo "== chapters, the interlude, carry-over, boss registry, Petal cap, map loader (tests/trek_chapters.php)"
php -d display_errors=1 -d error_reporting=-1 "$HERE/trek_chapters.php" "$GAME" 2>&1 | grep -v "^  ok" ; [ "${PIPESTATUS[0]}" = 0 ] || RC=1
echo "== Chapter II-a: map, sluice, riddle door, Sorrel, Silverfin, milestones, carry-over, draft marker, balance sim (tests/trek_ch2.php)"
php -d display_errors=1 -d error_reporting=-1 "$HERE/trek_ch2.php" "$GAME" 2>&1 | grep -v "^  ok" ; [ "${PIPESTATUS[0]}" = 0 ] || RC=1
echo "== Chapter II-b: Crossroads, Tumble, Juniper, Pinch, Thrum, finish, cold rest, text slots, balance sim (tests/trek_ch2b.php)"
php -d display_errors=1 -d error_reporting=-1 "$HERE/trek_ch2b.php" "$GAME" 2>&1 | grep -v "^  ok" ; [ "${PIPESTATUS[0]}" = 0 ] || RC=1
echo "== Chapter I audit: map, text keys, every spot once-only / replay / KO / fatigue / kit edge, milestones, Petal cap, fuzz (tests/trek_audit_ch1.php)"
php -d display_errors=1 -d error_reporting=-1 "$HERE/trek_audit_ch1.php" "$GAME" 2>&1 | grep -v "^  ok" ; [ "${PIPESTATUS[0]}" = 0 ] || RC=1
echo "== Chapter II audit: data, reachability, whole walk, text keys, soft-locks, boss sims (tests/trek_audit_ch2.php)"
php -d display_errors=1 -d error_reporting=-1 "$HERE/trek_audit_ch2.php" "$GAME" 2>&1 | grep -v "^  ok" ; [ "${PIPESTATUS[0]}" = 0 ] || RC=1
dbx "UPDATE trek_texts SET body='A hush falls over the Hollow.', status='draft' WHERE text_key='ch1.intro'"
echo "== pages as player, trek open"
dbx "UPDATE users SET trek_ch=1; UPDATE trek_runs SET inside=0, fight=NULL; DELETE FROM trek_runs; DELETE FROM trek_party; DELETE FROM trek_pack; DELETE FROM trek_flags; UPDATE users SET energy=100 WHERE username='sprout'"
dbx "INSERT OR REPLACE INTO settings (name, value) VALUES ('trek_open','1')" 2>/dev/null
get trek.php >/dev/null; echo "intro -> $(get trek.php)"; grep -q 'name="do" value="begin"' $H && echo "  begin button shown"
echo "begin -> $(post trek.php -d do=begin)"
echo "map -> $(get trek.php)"; grep -q 'class="trekmap' $H && echo "  map rendered"
for t in party pack log; do echo "tab $t -> $(get "trek.php?t=$t")"; done
get 'trek.php?t=party' >/dev/null; grep -q 'Trek Lv 1' $H && echo "  ok   party tab shows Trek Lv" || echo "  FAIL party tab: no Trek Lv"; grep -q 'class="txp"' $H && echo "  ok   party tab shows the XP bar" || echo "  FAIL party tab: no XP bar"
get 'trek.php?t=log' >/dev/null; grep -q 'Milestones (0/6)' $H && echo "  ok   log tab has the Milestones fold" || echo "  FAIL log tab: no Milestones fold"
get trek.php >/dev/null; echo "walk fog tile -> $(post trek.php -d do=go -d go=39,39)"
grep -c 'TO WRITE' $H | sed 's/^/  TO WRITE boxes (player): /'
grep -q 'class="trekdraft"' $H && echo "  FAIL player sees the draft pencil" || echo "  ok   no draft pencil for a player"
echo "forged csrf -> $(curl -s -c $C -b $C -X POST $BASE/trek.php -d csrf=bad -d do=leave -o /dev/null -w '%{http_code}')"
echo "leave -> $(get trek.php >/dev/null; post trek.php -d do=leave)"; echo "  inside=$(db 'SELECT inside FROM trek_runs')"
echo "== admin pages"
dbx "UPDATE users SET onboarded=1, level=15, energy=100 WHERE username='admin'"
rm -f $C; get login.php >/dev/null; post login.php -d username=admin -d password=TestPassword123 >/dev/null
for pg in admin/treks.php admin/trek_text.php 'admin/trek_text.php?f=todo' 'admin/settings.php?g=trek_' 'book.php?ch=Treks' trek.php; do echo "$pg -> $(get "$pg")"; done
get trek.php >/dev/null; grep -c 'TO WRITE' $H | sed 's/^/  TO WRITE boxes (admin, intro): /'
grep -q 'class="trekdraft"' $H && grep -q 'admin/trek_text.php?open=ch1.intro' $H && echo "  ok   admin sees the draft pencil with a link to the slot" || echo "  FAIL admin pencil/link missing"
echo "== admin text editor: grouped, paged, save keeps you in place"
get admin/trek_text.php >/dev/null; echo "  scenes: $(grep -c 'class="trekgroup"' $H)  slots: $(grep -c 'class="trekrow' $H)  size: $(wc -c < $H) bytes"
echo "  rows open on first view: $(grep -c 'class="trekrow[^>]*" open' $H)"
get 'admin/trek_text.php' >/dev/null; KEY=ch1.spot.burdock.freed
echo "save -> $(curl -s -c $C -b $C -X POST $BASE/admin/trek_text.php --data-urlencode "csrf=$(csrf $H)" -d key=$KEY -d status=todo --data-urlencode 'body=Free at last, {gnome}! <b>x</b>' -o /dev/null -w '%{http_code} %{redirect_url}')"
echo "  status: $(db "SELECT status FROM trek_texts WHERE text_key='$KEY'") (want draft)"
get "admin/trek_text.php?open=$KEY" >/dev/null; grep -q 'class="trekrow status-draft"[^>]* open' $H && echo "  saved row opens by itself"
grep -q 'Free at last' $H && echo "  body shown in the editor"
echo "forged csrf save -> $(curl -s -c $C -b $C -X POST $BASE/admin/trek_text.php -d csrf=bad -d key=$KEY -d body=x -o /dev/null -w '%{http_code}')"
echo "unknown key -> $(post admin/trek_text.php -d key=nope.x -d body=x)"
get admin/trek_text.php?p=2 >/dev/null; echo "  page 2 scenes: $(grep -c 'class="trekgroup"' $H)"
echo "html in body is escaped for players: $(curl -s -c $C -b $C "$BASE/admin/trek_text.php?open=$KEY" | grep -c '<b>x</b>') raw tags (want 0)"
echo "== admin text editor: Chapter II tabs, filters, suggestion, restore, CSRF"
get 'admin/trek_text.php?ch=2' >/dev/null
grep -q 'trekchtabs' $H && grep -q 'Chapter II' $H && grep -q 'Interludes' $H && echo "  ok   chapter tabs" || echo "  FAIL chapter tabs"
echo "  Chapter II scenes: $(grep -c 'class="trekgroup"' $H)  slots on page 1: $(grep -c 'class="trekrow' $H)"
grep -q 'ch1\.' $H && echo "  FAIL Chapter II tab shows Chapter I slots" || echo "  ok   only Chapter II slots"
K2=ch2.intro
get "admin/trek_text.php?ch=2&open=$K2" >/dev/null
grep -q 'Claude’s suggestion' $H && echo "  ok   suggestion box shown" || echo "  FAIL no suggestion box"
grep -q 'Where it shows' $H && echo "  ok   brief shown" || echo "  FAIL no brief"
echo "  prefilled body is the draft: $(grep -o 'Under the topsoil' $H | wc -l) (want 2+: suggestion + textarea)"
echo "  ch2 draft slots: $(db "SELECT COUNT(*) FROM trek_texts WHERE chapter=2 AND status='draft'") written: $(db "SELECT COUNT(*) FROM trek_texts WHERE chapter=2 AND status='done'")"
get 'admin/trek_text.php?ch=2&status=done' >/dev/null; echo "  filter Written, none yet: rows $(grep -c 'class="trekrow' $H) (want 0)"
get 'admin/trek_text.php?ch=2&status=draft' >/dev/null; echo "  filter Draft: rows on page $(grep -c 'class="trekrow' $H) (want 20+)"
get 'admin/trek_text.php?ch=2' >/dev/null
echo "save ch2 as written -> $(curl -s -c $C -b $C -X POST $BASE/admin/trek_text.php --data-urlencode "csrf=$(csrf $H)" -d key=$K2 -d status=done --data-urlencode 'body=Joshua wrote this one.' -o /dev/null -w '%{http_code}')"
echo "  status: $(db "SELECT status FROM trek_texts WHERE text_key='$K2'") (want done)"
get 'admin/trek_text.php?ch=2&status=done' >/dev/null; grep -q 'Joshua wrote this one' $H && echo "  ok   Written filter lists it" || echo "  FAIL Written filter"
echo "forged csrf save ch2 -> $(curl -s -c $C -b $C -X POST $BASE/admin/trek_text.php -d csrf=bad -d key=$K2 -d body=x -o /dev/null -w '%{http_code}')"; echo "  body kept: $(db "SELECT body FROM trek_texts WHERE text_key='$K2'")"
echo "re-import keeps the written body: $(php -r '$_SERVER["SCRIPT_NAME"]="/trek.php"; require "'$GAME'/includes/bootstrap.php"; require "'$GAME'/includes/trek.php"; trek_import_texts(); echo q_val("SELECT body FROM trek_texts WHERE text_key=\"ch2.intro\"");')"
get 'admin/trek_text.php?ch=2' >/dev/null
echo "restore the suggestion -> $(curl -s -c $C -b $C -X POST $BASE/admin/trek_text.php --data-urlencode "csrf=$(csrf $H)" -d key=$K2 -d restore=1 -o /dev/null -w '%{http_code}')"; echo "  status: $(db "SELECT status FROM trek_texts WHERE text_key='$K2'") (want draft)"
echo "forged csrf restore -> $(curl -s -c $C -b $C -X POST $BASE/admin/trek_text.php -d csrf=bad -d key=$K2 -d restore=1 -o /dev/null -w '%{http_code}')"
get 'admin/trek_text.php?ch=i' >/dev/null; echo "  Interludes tab: rows $(grep -c 'class="trekrow' $H), Chapter II rows there: $(grep -c 'id="t-ch2-' $H) (want 0)"
echo "== fight over HTTP (player)"
rm -f $C; get login.php >/dev/null; post login.php -d username=sprout -d password=TestPass123! >/dev/null
dbx "UPDATE users SET energy=100 WHERE username='sprout'"
get trek.php >/dev/null; post trek.php -d do=enter >/dev/null
php -d display_errors=1 -r '$_SERVER["SCRIPT_NAME"]="/trek.php"; require "'$GAME'/includes/bootstrap.php"; require "'$GAME'/includes/trek.php"; $uid=(int)q_val("SELECT id FROM users WHERE username=\"sprout\""); trek_tx($uid, function(&$run,$u){ $run["fi"]=null; $run["inside"]=1; trek_start_random_fight($run,$u,"g"); return [true,""]; });' 2>&1 | head -3
echo "fight page -> $(get trek.php)"; grep -q 'name="do" value="auto"' $H && echo "  Auto button shown"; grep -q 'name="do" value="round"' $H && echo "  Round button shown"
echo "walk during fight refused: $(post trek.php -d do=go -d go=1,1)"; get trek.php >/dev/null; grep -q "in a fight" $H && echo "  message shown"
echo "auto -> $(post trek.php -d do=auto)"; echo "  fight left: $(db "SELECT COUNT(*) FROM trek_runs WHERE fight IS NOT NULL")"
echo "log tab -> $(get 'trek.php?t=log')"
echo "== every spot panel renders (player, teleported, with and without its flag)"
cat > /tmp/trek_tp.php <<'PHP'
<?php
$_SERVER["SCRIPT_NAME"]="/trek.php"; require $argv[1]."/includes/bootstrap.php"; require $argv[1]."/includes/trek.php";
$uid=(int)q_val("SELECT id FROM users WHERE username='sprout'"); [$code,$mode]=[$argv[2],$argv[3]];
trek_tx($uid, function(&$run,$u) use($code,$mode){ $sp=trek_spots(1)[$code]; $run['inside']=1; $run['fi']=null; $run['x']=$sp['x']; $run['y']=$sp['y'];
  if ($mode==='done') foreach (['won_fight','freed_burdock','freed_zinnia','mother_down'] as $f) trek_flag_set($run,$f);
  return [true,'']; });
PHP
for mode in fresh done; do
for code in start exit rootwall burdock boulder camp cellar dewsign zinnia elder choir capwall bracken mother grotto dengate gloomtooth cart mushcamp bridgestone; do
  php /tmp/trek_tp.php $GAME $code $mode >/dev/null 2>&1
  c=$(get trek.php); if [ "$c" != 200 ] || grep -qE 'Warning|Notice|Deprecated|Fatal' $H; then echo "  PANEL PROBLEM $mode/$code http=$c"; fi
done; done; echo "  40 panels checked"
echo "== event card, crew card, fight log box over HTTP (player)"
cat > /tmp/trek_ev.php <<'PHP'
<?php
$_SERVER["SCRIPT_NAME"]="/trek.php"; require $argv[1]."/includes/bootstrap.php"; require $argv[1]."/includes/trek.php";
$uid=(int)q_val("SELECT id FROM users WHERE username='sprout'"); $mode=$argv[2];
trek_tx($uid, function(&$run,$u) use($mode){ $run['inside']=1; $run['fi']=null; $sp=trek_spots(1)['start']; $run['x']=4; $run['y']=15; $run['petals_found']=0; $run['fatigue']=0; unset($run['st']['ev'],$run['st']['cm'],$run['st']['bless']);
  trek_flag_set($run,'won_fight'); $run['sn']=str_repeat("ÿ", strlen($run['sn']));
  if ($mode==='ev') $run['st']['ev']=['id'=>'stash'];
  if ($mode==='cm') { trek_flag_set($run,'freed_burdock'); trek_flag_set($run,'cm_burdock'); trek_recruit_crew($run,$u,'burdock'); $run['st']['cm']='burdock'; }
  if ($mode==='fight') { trek_start_random_fight($run,$u,'g'); foreach ($run['fi']['foes'] as $i=>$f) { $run['fi']['foes'][$i]['hp']=$run['fi']['foes'][$i]['max']=99999; $run['fi']['foes'][$i]['def']=999; $run['fi']['foes'][$i]['atk']=-60; } for($i=0;$i<4;$i++) trek_fight_round($run,$u,[0=>['a'=>'guard']]); }
  return [true,'']; });
PHP
php /tmp/trek_ev.php $GAME ev >/dev/null 2>&1
echo "map with an event -> $(get trek.php)"; grep -q 'class="box trekspot trekev"' $H && echo "  event card shown"; grep -q 'name="do" value="event"' $H && echo "  event form shown"
P0=$(db "SELECT petals_found FROM trek_runs LIMIT 1")
get trek.php >/dev/null; echo "take it -> $(post trek.php -d do=event -d c=1)"; P1=$(db "SELECT petals_found FROM trek_runs LIMIT 1"); echo "  Petals $P0 -> $P1 (want more)"
get trek.php >/dev/null; echo "second tap -> $(post trek.php -d do=event -d c=1)"; P2=$(db "SELECT petals_found FROM trek_runs LIMIT 1"); [ "$P1" = "$P2" ] && echo "  no second payout"
echo "forged csrf event -> $(curl -s -c $C -b $C -X POST $BASE/trek.php -d csrf=bad -d do=event -d c=1 -o /dev/null -w '%{http_code}')"
php /tmp/trek_ev.php $GAME cm >/dev/null 2>&1
echo "map with a crew moment -> $(get trek.php)"; grep -q 'trekcrew' $H && echo "  crew card shown"
echo "take the task -> $(post trek.php -d do=crew -d c=1)"; get trek.php >/dev/null; grep -q 'trekcrew' $H || echo "  crew card gone"
cat > /tmp/trek_ms.php <<'PHP'
<?php
$_SERVER["SCRIPT_NAME"]="/trek.php"; require $argv[1]."/includes/bootstrap.php"; require $argv[1]."/includes/trek.php";
$uid=(int)q_val("SELECT id FROM users WHERE username='sprout'");
trek_tx($uid, function(&$run,$u){ $run['inside']=1; $run['fi']=null; unset($run['st']['ev'],$run['st']['cm']); $run['st']['ms']['mother']=['xp'=>450,'done'=>3,'total'=>5,'miss'=>['Riddles solved','Trail events resolved']]; $run['st']['msc']=['mother']; $run['st']['tl']['gnome']=[4,20]; return [true,'']; });
PHP
php /tmp/trek_ms.php $GAME >/dev/null 2>&1
echo "map with a milestone card -> $(get trek.php)"; grep -q 'trekms' $H && echo "  ok   milestone card shown" || echo "  FAIL milestone card missing"; grep -q 'Blight Mother: 3/5 checks → 450 XP' $H && echo "  ok   card line reads right" || echo "  FAIL card line"; grep -q 'Lv 4' $H && echo "  ok   hud shows Lv 4" || echo "  FAIL hud Lv"
echo "dismiss it -> $(post trek.php -d do=msdismiss)"; get trek.php >/dev/null; grep -q 'trekms' $H && echo "  FAIL card still there" || echo "  ok   card gone"
get 'trek.php?t=log' >/dev/null; grep -q 'Milestones (1/6)' $H && grep -q '450 XP' $H && echo "  ok   Milestones fold lists it" || echo "  FAIL Milestones fold"
echo "forged csrf msdismiss -> $(curl -s -c $C -b $C -X POST $BASE/trek.php -d csrf=bad -d do=msdismiss -o /dev/null -w '%{http_code}')"
php /tmp/trek_ev.php $GAME fight >/dev/null 2>&1
echo "fight with a long log -> $(get trek.php)"; grep -q 'class="trekall"' $H && echo "  Show all shown"; grep -o 'Show all ([0-9]*)' $H | head -1 | sed 's/^/  /'
grep -c 'class="tkall"' $H | sed 's/^/  scroll boxes: /'
echo "log tab -> $(get 'trek.php?t=log')"; grep -q 'Last fight' $H && echo "  Last fight box shown"
echo "== the interlude over HTTP (player; no Chapter II files: coming soon, no way back)"
rm -f $C; get login.php >/dev/null; post login.php -d username=sprout -d password=TestPass123! >/dev/null
cat > /tmp/trek_hub.php <<'PHP'
<?php
$_SERVER["SCRIPT_NAME"]="/trek.php"; require $argv[1]."/includes/bootstrap.php"; require $argv[1]."/includes/trek.php";
$uid=(int)q_val("SELECT id FROM users WHERE username='sprout'");
foreach (['trek_flags','trek_pack','trek_party','trek_recruits'] as $t) q("DELETE FROM $t WHERE run_id IN (SELECT id FROM trek_runs WHERE user_id = ?)", [$uid]);
q('DELETE FROM trek_runs WHERE user_id = ?', [$uid]); q('UPDATE users SET trek_ch = 1, energy = 100, level = 16, coins = 500 WHERE id = ?', [$uid]);
trek_tx($uid, fn(&$run,$u)=>trek_enter($run,$u), false);
trek_tx($uid, function(&$run,$u){ trek_recruit_crew($run,$u,'burdock'); trek_recruit_crew($run,$u,'zinnia'); trek_recruit_crew($run,$u,'bracken'); $run['petals_found']=12; trek_complete_chapter($run,$u); return [true,'']; });
PHP
php /tmp/trek_hub.php $GAME >/dev/null 2>&1
echo "interlude page -> $(get trek.php)"
grep -q 'The Shard Hollow' $H && echo "  ok   rest stop shown" || echo "  FAIL rest stop missing"
grep -q 'class="trekmap' $H && echo "  FAIL map shown after completion" || echo "  ok   no map"
grep -q 'name="do" value="godown"' $H && ! grep -q 'disabled>⬇️ Chapter II' $H && echo "  ok   Go down enabled (Chapter II-a exists)" || echo "  FAIL go down button"
grep -q 'Talk to your party' $H && echo "  ok   talk list shown" || echo "  FAIL talk list"
echo "  inside after the page: $(db 'SELECT inside FROM trek_runs') carried Petals: $(db 'SELECT petals_found FROM trek_runs') (want 0 0)"
echo "walk (POST go) -> $(post trek.php -d do=go -d go=5,5)"; P1=$(db 'SELECT x||","||y FROM trek_runs'); get trek.php >/dev/null; grep -q 'behind you' $H && echo "  ok   refused with a message"; echo "  position still $P1"
E0=$(db "SELECT energy FROM users WHERE username='sprout'")
echo "enter (POST) -> $(post trek.php -d do=enter)"; get trek.php >/dev/null; echo "begin (POST) -> $(post trek.php -d do=begin)"
echo "  inside=$(db 'SELECT inside FROM trek_runs') runs=$(db 'SELECT COUNT(*) FROM trek_runs') energy $E0 -> $(db "SELECT energy FROM users WHERE username='sprout'") (want 0 1 same)"
for act in "do=makecamp" "do=leave" "do=challenge" "do=recruit"; do get trek.php >/dev/null; post trek.php -d $act >/dev/null; done; echo "  inside after makecamp/leave/challenge/recruit: $(db 'SELECT inside FROM trek_runs')"
NID=$(db "SELECT id FROM npcs WHERE slug='burdock-deepdelve'")
F0=$(db "SELECT points FROM npc_friends WHERE user_id=(SELECT id FROM users WHERE username='sprout') AND npc_id=$NID")
get trek.php >/dev/null; echo "talk to Burdock -> $(post trek.php -d do=talk -d who=burdock)"; F1=$(db "SELECT points FROM npc_friends WHERE user_id=(SELECT id FROM users WHERE username='sprout') AND npc_id=$NID")
get trek.php >/dev/null; grep -q 'Burdock' $H && grep -q 'class="trektext banter"' $H && echo "  ok   his line is shown"
post trek.php -d do=talk -d who=burdock >/dev/null; F2=$(db "SELECT points FROM npc_friends WHERE user_id=(SELECT id FROM users WHERE username='sprout') AND npc_id=$NID")
echo "  friendship $F0 -> $F1 -> $F2 (want +1 once)"
get trek.php >/dev/null; echo "talk forged crew key -> $(post trek.php -d do=talk -d who=nobody)"
echo "forged csrf godown -> $(curl -s -c $C -b $C -X POST $BASE/trek.php -d csrf=bad -d do=godown -o /dev/null -w '%{http_code}')"
BK=$(db 'SELECT campkits FROM trek_runs'); get trek.php >/dev/null; post trek.php -d do=buy_kit >/dev/null; echo "  kit bought at the rest stop: $BK -> $(db 'SELECT campkits FROM trek_runs')"
get 'trek.php?t=party' >/dev/null; grep -q 'Change the party' $H && echo "  ok   party can be changed at the rest stop"
get 'trek.php?t=log' >/dev/null; grep -q 'Milestones (' $H && echo "  ok   log tab shows Chapter I milestones"
for t in pack; do echo "tab $t -> $(get "trek.php?t=$t")"; done
get trek.php >/dev/null; echo "forged csrf godown first"; echo "Go down -> $(post trek.php -d do=godown)"; echo "  runs=$(db 'SELECT COUNT(*) FROM trek_runs') chapter=$(db 'SELECT trek_ch FROM users WHERE username="sprout"') (want 2 2)"
echo "== Chapter II panels over HTTP (player, after Go down)"
cat > /tmp/trek_tp2.php <<'PHP'
<?php
$_SERVER["SCRIPT_NAME"]="/trek.php"; require $argv[1]."/includes/bootstrap.php"; require $argv[1]."/includes/trek.php";
$uid=(int)q_val("SELECT id FROM users WHERE username='sprout'"); [$code,$mode]=[$argv[2],$argv[3]];
trek_tx($uid, function(&$run,$u) use($code,$mode){ $sp=trek_spots(2)[$code]; $run["inside"]=1; $run["fi"]=null; $run["x"]=$sp["x"]; $run["y"]=$sp["y"]; $run["sn"]=str_repeat("\xff", strlen($run["sn"]));
  if ($mode==="done") foreach (['sluice1_done','drained_j','drained_l','barrow_done','book_found','libdoor_open','libdoor_solved','freed_sorrel','silverfin_down','wheel_done','kilnstone_solved','kiln_open','rest_used','reached_crossroads'] as $f) trek_flag_set($run,$f);
  return [true,'']; });
PHP
get trek.php >/dev/null
for mode in fresh done; do
for code in start sluice1 barrow camp book nook rest libdoor libgate sluice2 sorrel silverfin silvergate wheel kilnstone kiln crossroads; do
  php /tmp/trek_tp2.php $GAME $code $mode >/dev/null 2>&1
  c=$(get trek.php); if [ "$c" != 200 ] || grep -qE 'Warning|Notice|Deprecated|Fatal' $H; then echo "  PANEL PROBLEM ch2 $mode/$code http=$c"; fi
done; done; echo "  34 Chapter II panels checked"
echo "== Chapter II-b panels over HTTP (player; the loose clay legend, the travel button, the slide, locked recruit)"
cat > /tmp/trek_tp3.php <<'PHP'
<?php
$_SERVER["SCRIPT_NAME"]="/trek.php"; require $argv[1]."/includes/bootstrap.php"; require $argv[1]."/includes/trek.php";
$uid=(int)q_val("SELECT id FROM users WHERE username='sprout'"); [$code,$mode]=[$argv[2],$argv[3]];
trek_tx($uid, function(&$run,$u) use($code,$mode){ $sp=trek_spots(2)[$code]; $run["inside"]=1; $run["fi"]=null; $run["x"]=$sp["x"]; $run["y"]=$sp["y"]; $run["sn"]=str_repeat("\xff", strlen($run["sn"]));
  if ($mode==="done") foreach (['sign_open','sign_solved','freed_tumble','nookA_found','nookB_found','nookC_found','slide_seen','rack_found','camp2_seen','freed_juniper','sluice3_done','drained_r','pinch_down','drumdoor_open','thrum_down','reached_crossroads'] as $f) trek_flag_set($run,$f);
  if ($mode==="camps") { trek_flag_set($run,'camp_seen'); trek_flag_set($run,'camp2_seen'); }
  return [true,'']; });
PHP
for mode in fresh done; do
for code in signpost tumble nookA nookB nookC slide rack brewdoor camp2 juniper sluice3 pinch drumdoor drumgate thrum; do
  php /tmp/trek_tp3.php $GAME $code $mode >/dev/null 2>&1
  c=$(get trek.php); if [ "$c" != 200 ] || grep -qE 'Warning|Notice|Deprecated|Fatal' $H; then echo "  PANEL PROBLEM ch2b $mode/$code http=$c"; fi
done; done; echo "  30 Chapter II-b panels checked"
php /tmp/trek_tp3.php $GAME camp2 camps >/dev/null 2>&1; get trek.php >/dev/null
grep -q 'name="do" value="travel"' $H && echo "  ok   the Brewhouse card has a travel button to the Tin Lamp" || echo "  FAIL no travel button at the Brewhouse"
php /tmp/trek_tp3.php $GAME tumble fresh >/dev/null 2>&1; get trek.php >/dev/null
grep -q 'name="do" value="recruit"' $H && echo "  FAIL Tumble can be helped before the Signpost is open" || echo "  ok   Tumble waits for the Signpost (no help button)"
php /tmp/trek_tp3.php $GAME slide fresh >/dev/null 2>&1; get trek.php >/dev/null
grep -q 'name="do" value="slide"' $H && echo "  ok   the slide card has its button" || echo "  FAIL no slide button"
echo "forged csrf travel -> $(curl -s -c $C -b $C -X POST $BASE/trek.php -d csrf=bad -d do=travel -d to=camp -o /dev/null -w '%{http_code}')"
echo "== the interlude after Chapter II over HTTP (finish the run; knock hook; no Chapter III)"
cat > /tmp/trek_hub2.php <<'PHP'
<?php
$_SERVER["SCRIPT_NAME"]="/trek.php"; require $argv[1]."/includes/bootstrap.php"; require $argv[1]."/includes/trek.php";
$uid=(int)q_val("SELECT id FROM users WHERE username='sprout'");
trek_tx($uid, function(&$run,$u){ $run["inside"]=1; $run["fi"]=null; foreach (['tumble','juniper'] as $k) if (!in_array($k, trek_recruits((int)$run["id"]), true)) trek_recruit_crew($run,$u,$k); $run["petals_found"]=7; trek_complete_chapter($run,$u); return [true,'']; });
PHP
php /tmp/trek_hub2.php $GAME >/dev/null 2>&1
echo "interlude page -> $(get trek.php)"
grep -q 'The Shard Hollow' $H && echo "  ok   rest stop shown" || echo "  FAIL rest stop missing"
grep -q 'Chapter II complete' $H && echo "  ok   Chapter II complete card" || echo "  FAIL no complete card"
grep -q 'something knocks' $H && echo "  ok   the knock hook is on the card" || echo "  FAIL no knock hook"
grep -q 'Chapter III is coming soon' $H && echo "  ok   Chapter III: coming soon" || echo "  FAIL no coming soon"
grep -q 'class="trekmap' $H && echo "  FAIL map shown after the finish" || echo "  ok   no map"
post trek.php -d do=talk -d who=tumble >/dev/null; get trek.php >/dev/null; grep -q 'come down' $H && echo "  ok   Tumble talks at the rest stop" || echo "  FAIL no Tumble line"
echo "  map key shown: $(grep -c 'class="tklegend"' $H)  inline style attrs on the page: $(grep -o ' style="' $H | wc -l)"
echo "== engine audit (tests/trek_audit.sh: who may call what, bad input, simultaneous POSTs, escaping, admin pages, damaged state, settings extremes)"
bash "$HERE/trek_audit.sh" "" $((PORT+1)) "$ROUTER" 2>&1 | grep -v "^  ok" ; [ "${PIPESTATUS[0]}" = 0 ] || RC=1
echo "== error log"
test -s $GAME/data/error-log.txt && { echo "  ERROR LOG HAS ENTRIES:"; head -8 $GAME/data/error-log.txt; } || echo "  error log empty"
echo "== log checks"
grep -E 'Warning|Notice|Deprecated|Fatal|Parse error' $LOG | head -5 | sed 's/^/  PHP: /'
echo "done (rc=$RC)"
exit $RC
