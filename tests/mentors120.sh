#!/bin/bash
# v1.2.0: player mentors. Fresh SQLite install in a temp copy.
# Usage: tests/mentors120.sh [GAME_COPY_DIR] [PORT] [ROUTER]   (default: copies src/game to a temp dir; never writes a DB into src)
HERE=$(cd "$(dirname "$0")" && pwd)
GAME=${1:-}; PORT=${2:-8750}; ROUTER=${3:-$HERE/router.php}
if [ -z "$GAME" ]; then T=$(mktemp -d); cp -r "$HERE/../game" "$T/game"; GAME=$T/game; fi
rm -f "$GAME/config.php"; rm -rf "${GAME:?}/data"; mkdir -p "$GAME/data"
BASE=http://127.0.0.1:$PORT
LOG=$(mktemp)
php -d session.save_path=/tmp -d display_errors=1 -S 127.0.0.1:$PORT -t "$GAME" "$ROUTER" >$LOG 2>&1 & PID=$!; sleep 1
trap "kill $PID 2>/dev/null" EXIT
T=$(mktemp -d); H=$T/h.html
FAILS=0
ok() { if [ "$2" = "$3" ]; then echo "  ok   $1"; else echo "  FAIL $1: got [$2] want [$3]"; FAILS=$((FAILS+1)); fi; }
has() { if grep -q -- "$3" "$2"; then echo "  ok   $1"; else echo "  FAIL $1: no [$3]"; FAILS=$((FAILS+1)); fi; }
hasnt() { if grep -q -- "$3" "$2"; then echo "  FAIL $1: found [$3]"; FAILS=$((FAILS+1)); else echo "  ok   $1"; fi; }
gt() { if [ "$2" -gt "$3" ] 2>/dev/null; then echo "  ok   $1 ($2)"; else echo "  FAIL $1: $2 not > $3"; FAILS=$((FAILS+1)); fi; }
csrf() { grep -o 'name="csrf" value="[^"]*"' "$1" | head -1 | sed 's/.*value="\([^"]*\)".*/\1/'; }
db() { php -r '$p=new PDO("sqlite:'$GAME'/data/game.sqlite"); foreach($p->query($argv[1])->fetchAll(PDO::FETCH_NUM) as $r) echo implode(" | ",$r),"\n";' "$1"; }
dbx() { php -r '$p=new PDO("sqlite:'$GAME'/data/game.sqlite"); $p->exec($argv[1]);' "$1"; }
# the game day is Halifax time (SQLite date('now') is UTC and is a day ahead from 21:00): halifax -6 = the Halifax date 6 days ago
halifax() { php -r 'date_default_timezone_set("America/Halifax"); echo date("Y-m-d", strtotime($argv[1] . " days"));' -- "$1"; }
get() { curl -s -c $1 -b $1 "$BASE/$2" -o $H -w '%{http_code}'; }                # get COOKIE path  (page in $H)
post() { local ck=$1 page=$2; shift; shift; curl -s -c $ck -b $ck -X POST "$BASE/$page" --data-urlencode "csrf=$(csrf $H)" "$@" -o $T/p.html -w '%{http_code}'; }   # needs a GET of a page with a csrf first
login() { rm -f $1; get $1 login.php >/dev/null; post $1 login.php -d username=$2 -d 'password=TestPass123!' >/dev/null; }
flashes() { grep -oE 'class="flash (ok|err)"[^>]*>[^<]*' $H | sed -E 's/^[^>]*>//' | tr '\n' '|'; }

echo "== install + sprout"
C0=$T/c0; get $C0 install.php >/dev/null
post $C0 install.php -d driver=sqlite -d "site_name=Gnome Venture" -d base_url= -d admin_user=admin -d admin_email=a@b.local -d admin_pass=TestPassword123 -d admin_pass2=TestPassword123 >/dev/null
grep -q 'All planted' $T/p.html && echo "  installed" || { echo "INSTALL FAILED"; tail -5 $LOG; exit 1; }
rm -f $C0; get $C0 register.php >/dev/null; post $C0 register.php -d username=sprout -d email=s@b.local -d password=TestPass123! -d password2=TestPass123! -d rules=1 -d age=1 >/dev/null
get $C0 welcome.php >/dev/null; post $C0 welcome.php -d do=gnome -d "gnome_name=Bramble" -d 'hat=#2e7d4f' -d 'beard=#b5651d' >/dev/null
get $C0 'welcome.php?step=place' >/dev/null
RID=$(db "SELECT id FROM regions WHERE code='NA'")
VID=$(db "SELECT l.id FROM locations l WHERE l.region_id=$RID AND l.kind='village' AND EXISTS (SELECT 1 FROM routes r WHERE r.kind='road' AND (r.a_id=l.id OR r.b_id=l.id)) ORDER BY l.sort_order LIMIT 1 OFFSET 1")
post $C0 welcome.php -d do=place -d village_id=$VID >/dev/null
get $C0 'welcome.php?step=garden' >/dev/null; post $C0 welcome.php -d do=finish -d 'garden_name=Test Patch' >/dev/null
ok "sprout onboarded" "$(db "SELECT onboarded FROM users WHERE username='sprout'")" 1
# more gnomes: clones of sprout (with their own garden); bloom has an open garden, thistle blocks people, quiet keeps a private one
php -r '$p=new PDO("sqlite:'$GAME'/data/game.sqlite"); $p->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
 foreach (["bloom"=>"Bloom Thistledown","thistle"=>"Thistle Underhill","quiet"=>"Quill Hushwick","nova"=>"Nova Brightleaf","pip"=>"Pip Mossgrove"] as $un=>$gn) {
  $r=$p->query("SELECT * FROM users WHERE username=\"sprout\"")->fetch(PDO::FETCH_ASSOC); unset($r["id"]); $r["username"]=$un; $r["email"]=$un."@b.local"; $r["gnome_name"]=$gn; $r["tour_step"]=0; $r["level"]=5; $r["last_seen"]=gmdate("Y-m-d H:i:s");
  $c=array_keys($r); $p->prepare("INSERT INTO users (".implode(",",$c).") VALUES (".implode(",",array_fill(0,count($c),"?")).")")->execute(array_values($r));
  $uid=(int)$p->lastInsertId(); $pl=$p->query("SELECT * FROM plots WHERE user_id=(SELECT id FROM users WHERE username=\"sprout\")")->fetch(PDO::FETCH_ASSOC); unset($pl["id"]); $pl["user_id"]=$uid; $pl["garden_name"]=$gn."s Garden";
  $c=array_keys($pl); $p->prepare("INSERT INTO plots (".implode(",",$c).") VALUES (".implode(",",array_fill(0,count($c),"?")).")")->execute(array_values($pl)); $pid=(int)$p->lastInsertId();
  $p->exec("UPDATE users SET active_plot_id=$pid WHERE id=$uid");
 }'
dbx "INSERT OR REPLACE INTO settings (name,value) VALUES ('fresh_hold_days','0')"   # brand-new test accounts (fresh_hold.sh tests the hold itself)
dbx "INSERT OR REPLACE INTO settings (name,value) VALUES ('pmentor_cooldown_hours','2')"
dbx "UPDATE users SET reg_ip_hash=NULL WHERE username <> 'sprout'"
id() { db "SELECT id FROM users WHERE username='$1'"; }
SID=$(id sprout); BID=$(id bloom); TID=$(id thistle); QID=$(id quiet); NID=$(id nova); PID_=$(id pip)
# mentors: bloom, thistle, quiet at level 25; newcomers: sprout, nova, pip at level 3
for n in bloom thistle quiet; do dbx "UPDATE users SET level=25, last_seen=datetime('now') WHERE username='$n'"; done
for n in sprout nova pip; do dbx "UPDATE users SET level=3, xp=0, coins=1000, last_seen=datetime('now') WHERE username='$n'"; done
A=$T/a; B=$T/b; TH=$T/t; QU=$T/q; NV=$T/n; PP=$T/p; AD=$T/ad
login $A sprout; login $B bloom; login $TH thistle; login $QU quiet; login $NV nova; login $PP pip
act() { local ck=$1 do=$2 idv=$3; shift 3; get $ck 'pals.php?tab=mentor' >/dev/null; post $ck pals.php -d do=$do -d id=$idv -d back='pals.php?tab=mentor' "$@" >/dev/null; get $ck 'pals.php?tab=mentor' >/dev/null; }
link() { db "SELECT status FROM pmentor_links WHERE mentor_id=$1 AND newcomer_id=$2"; }
lid() { db "SELECT id FROM pmentor_links WHERE mentor_id=$1 AND newcomer_id=$2"; }
setcfg() { dbx "INSERT OR REPLACE INTO settings (name,value) VALUES ('$1','$2')"; }
x() { php $HERE/mentors120.php $GAME "$@"; }

echo "== 0. upgrade is idempotent, pages exist"
ok "upgrade twice, 2 pages" "$(x upgrade)" "pages=2"
ok "tables" "$(db "SELECT COUNT(*) FROM sqlite_master WHERE name IN ('pmentor_links','pmentor_grads','pmentor_days')")" 3
ok "columns" "$(db "SELECT COUNT(*) FROM pragma_table_info('users') WHERE name IN ('pmentor_open','reg_ip_hash')")" 2
ok "sign-up stored an ip hash" "$([ -n "$(db "SELECT reg_ip_hash FROM users WHERE username='sprout'")" ] && echo y)" y

echo "== 1. the tab, willing mentors"
get $A 'pals.php?tab=mentor' >/dev/null; has "tab shows" $H 'Willing mentors'; hasnt "nobody listed yet" $H 'Bloom Thistledown'
get $B 'pals.php?tab=mentor' >/dev/null; has "mentor sees the tick" $H 'Happy to mentor'
get $A 'pals.php' >/dev/null; has "Mentor tab link" $H '🎓 Gnome mentor'
act $B pm_open 0 -d open=1; ok "bloom ticked" "$(db "SELECT pmentor_open FROM users WHERE username='bloom'")" 1
dbx "UPDATE users SET pmentor_open=1 WHERE username IN ('thistle','quiet')"
get $A 'pals.php?tab=mentor' >/dev/null; has "bloom listed" $H 'Bloom Thistledown'
dbx "UPDATE users SET last_seen=datetime('now','-30 days') WHERE username='quiet'"
get $A 'pals.php?tab=mentor' >/dev/null; hasnt "long-gone mentor not listed" $H 'Quill Hushwick'; dbx "UPDATE users SET last_seen=datetime('now') WHERE username='quiet'"
act $A pm_open 0 -d open=1; ok "level 3 can't tick" "$(db "SELECT pmentor_open FROM users WHERE username='sprout'")" 0
get $A "profile.php?id=$BID" >/dev/null; has "profile button" $H 'Ask to be my mentor'
get $A "profile.php?id=$SID" >/dev/null; hasnt "no button on own profile" $H 'Ask to be my mentor'

echo "== 2. CSRF + requests"
get $A 'pals.php?tab=mentor' >/dev/null
curl -s -c $A -b $A -X POST "$BASE/pals.php" -d do=pm_request -d id=$BID -o /dev/null
ok "POST without csrf does nothing" "$(db "SELECT COUNT(*) FROM pmentor_links")" 0
curl -s -c $A -b $A -X POST "$BASE/pals.php" -d csrf=wrong -d do=pm_request -d id=$BID -o /dev/null
ok "POST with a bad csrf does nothing" "$(db "SELECT COUNT(*) FROM pmentor_links")" 0
act $A pm_request $BID; ok "request pending" "$(link $BID $SID)" pending
has "flash" $H 'Request sent'
act $A pm_request $TID; ok "cooldown stops a second ask" "$(link $TID $SID)" ""
setcfg pmentor_cooldown_hours 0
act $A pm_request $BID; ok "duplicate ask still one row" "$(db "SELECT COUNT(*) FROM pmentor_links WHERE newcomer_id=$SID")" 1
act $A pm_request $TID; ok "second request pending" "$(link $TID $SID)" pending
act $A pm_request $QID; act $A pm_request $QID; ok "third pending ok" "$(link $QID $SID)" pending
dbx "UPDATE users SET level=20 WHERE username='nova'"; act $NV pm_request $BID; ok "a level-20 gnome can't ask" "$(link $BID $NID)" ""; dbx "UPDATE users SET level=3 WHERE username='nova'"
act $A pm_request $PID_; ok "can't ask a non-mentor (level 3)" "$(link $PID_ $SID)" ""
dbx "UPDATE users SET pmentor_open=0 WHERE username='pip'"
echo "-- cancel, then ask again"
act $A pm_cancel "$(lid $QID $SID)"; ok "taken back" "$(link $QID $SID)" cancelled
echo "-- only the mentor can answer"
act $TH pm_accept "$(lid $BID $SID)"; ok "thistle can't answer bloom's request" "$(link $BID $SID)" pending
act $A pm_accept "$(lid $BID $SID)"; ok "newcomer can't accept for the mentor" "$(link $BID $SID)" pending
echo "-- decline, then no quick re-ask"
get $B 'pals.php?tab=mentor' >/dev/null; has "mentor sees the request" $H 'Sprout\|sprout\|Bramble'
act $B pm_decline "$(lid $BID $SID)"; ok "declined" "$(link $BID $SID)" declined
act $A pm_request $BID; ok "re-ask within days refused" "$(link $BID $SID)" declined

echo "== 3. accept, one mentor only"
act $TH pm_accept "$(lid $TID $SID)"; ok "accepted" "$(link $TID $SID)" active
ok "other waiting asks withdrawn" "$(db "SELECT COUNT(*) FROM pmentor_links WHERE newcomer_id=$SID AND status='pending'")" 0
act $B pm_request $TID; get $A 'pals.php?tab=mentor' >/dev/null; has "newcomer sees mentor + progress" $H 'level 3 / 8'
act $A pm_request $QID; ok "can't ask again while linked" "$(link $QID $SID)" cancelled
get $A "profile.php?id=$QID" >/dev/null; hasnt "no ask button while linked" $H 'Ask to be my mentor'

echo "== 4. XP bonus + share + daily cap"
setcfg pmentor_daily_cap 8
R=$(x xp $SID 100); ok "newcomer +10% (100 -> 110), mentor +5" "${R% level=*}" "gain=110 mentor=5"
R=$(x xp $SID 100); ok "daily cap: mentor only gets the last 3" "${R% level=*}" "gain=110 mentor=3"
R=$(x xp $SID 40); ok "capped: mentor gets nothing more today" "${R% level=*}" "gain=44 mentor=0"
ok "share log" "$(db "SELECT xp FROM pmentor_days WHERE mentor_id=$TID")" 8
ok "link totals" "$(db "SELECT xp_given||'/'||xp_bonus FROM pmentor_links WHERE mentor_id=$TID AND newcomer_id=$SID")" "8/24"
ok "xp not shared for gnomes without a mentor" "$(x xp $NID 100 | sed "s/ level=.*//")" "gain=100 mentor=0"
setcfg pmentor_daily_cap 100

echo "== 5. max 2 per mentor, one mentor per newcomer"
act $NV pm_request $TID; act $TH pm_accept "$(lid $TID $NID)"; ok "second newcomer accepted" "$(link $TID $NID)" active
act $PP pm_request $TID; ok "full mentor refuses a new ask" "$(link $TID $PID_)" ""
act $PP pm_request $BID; ok "pip asks bloom" "$(link $BID $PID_)" pending
dbx "INSERT OR IGNORE INTO pmentor_links (mentor_id,newcomer_id,status,created_at) VALUES ($TID,$PID_,'pending',datetime('now'))"
act $TH pm_accept "$(lid $TID $PID_)"; ok "accept past the max refused" "$(link $TID $PID_)" pending
dbx "DELETE FROM pmentor_links WHERE mentor_id=$TID AND newcomer_id=$PID_"
echo "-- accepting while the newcomer already has a mentor"
dbx "INSERT OR REPLACE INTO pmentor_links (mentor_id,newcomer_id,status,created_at) VALUES ($QID,$SID,'pending',datetime('now'))"
act $QU pm_accept "$(lid $QID $SID)"; ok "newcomer already has a mentor: refused" "$(link $QID $SID)" cancelled
echo "-- alt guard"
dbx "UPDATE users SET reg_ip_hash='same' WHERE username IN ('pip','bloom')"
act $PP pm_request $BID; ok "same sign-up address: bloom's pending kept, no new link" "$(db "SELECT COUNT(*) FROM pmentor_links WHERE newcomer_id=$PID_")" 1
dbx "DELETE FROM pmentor_links WHERE newcomer_id=$PID_"; act $PP pm_request $BID; ok "same sign-up address refused" "$(link $BID $PID_)" ""
dbx "UPDATE users SET reg_ip_hash=NULL WHERE username IN ('pip','bloom')"
echo "-- fresh account is never a mentor"
dbx "INSERT OR REPLACE INTO settings (name,value) VALUES ('fresh_hold_days','3')"
act $PP pm_request $BID; ok "new account can't mentor" "$(link $BID $PID_)" ""
dbx "INSERT OR REPLACE INTO settings (name,value) VALUES ('fresh_hold_days','0')"

echo "== 6. blocks"
act $B pm_open 0 -d open=1
dbx "INSERT INTO player_blocks (blocker_id,blocked_id,created_at) VALUES ($BID,$PID_,datetime('now'))"
act $PP pm_request $BID; ok "blocked: no request" "$(link $BID $PID_)" ""
dbx "DELETE FROM player_blocks"
act $PP pm_request $BID; ok "unblocked: request goes" "$(link $BID $PID_)" pending
get $B 'pals.php' >/dev/null; post $B pals.php -d do=block -d id=$PID_ >/dev/null
ok "blocking ends the pending ask" "$(link $BID $PID_)" ended
get $B 'pals.php?tab=mentor' >/dev/null; get $PP 'pals.php?tab=mentor' >/dev/null; hasnt "blocked mentor not listed for the blocked gnome" $H "profile.php?id=$BID\""
dbx "DELETE FROM player_blocks"
echo "-- active link ended by a block"
get $TH 'pals.php' >/dev/null; post $TH pals.php -d do=block -d id=$NID >/dev/null
ok "block ended the active link" "$(link $TID $NID)" ended
dbx "DELETE FROM player_blocks"

echo "== 7. ending"
act $A pm_end "$(lid $TID $SID)"; ok "newcomer ends" "$(link $TID $SID)" ended
dbx "UPDATE pmentor_links SET status='active', closed_at=NULL WHERE mentor_id=$TID AND newcomer_id=$SID"
act $PP pm_end "$(lid $TID $SID)"; ok "a stranger can't end it" "$(link $TID $SID)" active
act $TH pm_end "$(lid $TID $SID)"; ok "mentor ends" "$(link $TID $SID)" ended
R=$(x xp $SID 100); ok "no bonus once ended" "${R% level=*}" "gain=100 mentor=0"
act $A pm_request $TID; ok "ended pair waits before asking again" "$(link $TID $SID)" ended

echo "== 8. graduation, once only"
dbx "UPDATE pmentor_links SET status='active', closed_at=NULL WHERE mentor_id=$TID AND newcomer_id=$SID"
C_S=$(db "SELECT coins FROM users WHERE id=$SID"); C_T=$(db "SELECT coins FROM users WHERE id=$TID")
dbx "UPDATE users SET level=7, xp=(SELECT 0) WHERE id=$SID"
php -r '$_SERVER["SCRIPT_NAME"]="/index.php"; require "'$GAME'/includes/bootstrap.php"; echo xp_for_level(8)," ",xp_for_level(7),"\n";' > $T/xpl.txt
NEED=$(awk '{print $1}' $T/xpl.txt); dbx "UPDATE users SET xp=$NEED-5 WHERE id=$SID"
R=$(x xp $SID 20); has_lvl=$(echo "$R" | grep -c 'level=8'); ok "reached level 8" "$has_lvl" 1
ok "link graduated" "$(link $TID $SID)" graduated
ok "newcomer got 150 Petals" "$(( $(db "SELECT coins FROM users WHERE id=$SID") - C_S ))" 150
ok "mentor got 250 Petals" "$(( $(db "SELECT coins FROM users WHERE id=$TID") - C_T ))" 250
ok "one grad row" "$(db "SELECT COUNT(*) FROM pmentor_grads WHERE newcomer_id=$SID")" 1
ok "newcomer Almanac page" "$(db "SELECT COUNT(*) FROM user_encyclopedia ue JOIN encyclopedia_entries e ON e.id=ue.entry_id WHERE ue.user_id=$SID AND e.unlock_key='pmentor:graduate'")" 1
ok "mentor Almanac page" "$(db "SELECT COUNT(*) FROM user_encyclopedia ue JOIN encyclopedia_entries e ON e.id=ue.entry_id WHERE ue.user_id=$TID AND e.unlock_key='pmentor:mentor'")" 1
echo "-- a second go (re-opened link) pays nothing"
dbx "UPDATE pmentor_links SET status='active' WHERE mentor_id=$TID AND newcomer_id=$SID"
C_S=$(db "SELECT coins FROM users WHERE id=$SID"); C_T=$(db "SELECT coins FROM users WHERE id=$TID")
ok "graduate again: link closes" "$(x grad "$(lid $TID $SID)")" "graduated=0"
ok "no second newcomer reward" "$(( $(db "SELECT coins FROM users WHERE id=$SID") - C_S ))" 0
ok "no second mentor reward" "$(( $(db "SELECT coins FROM users WHERE id=$TID") - C_T ))" 0
ok "still one grad row" "$(db "SELECT COUNT(*) FROM pmentor_grads WHERE newcomer_id=$SID")" 1
ok "graduated gnome can't ask again" "$(php -r '$_SERVER["SCRIPT_NAME"]="/index.php"; require "'$GAME'/includes/bootstrap.php"; require "'$GAME'/includes/mentors120.php"; echo mentors120_newcomer_problem(q_one("SELECT * FROM users WHERE id='$SID'")) !== "" ? "refused" : "open";')" refused
echo "-- weekly cap on the mentor reward"
setcfg pmentor_grad_week_cap 1
dbx "UPDATE users SET level=7 WHERE id=$NID"; dbx "UPDATE pmentor_links SET status='active', closed_at=NULL WHERE mentor_id=$TID AND newcomer_id=$NID"
dbx "INSERT OR REPLACE INTO pmentor_links (mentor_id,newcomer_id,status,created_at) VALUES ($TID,$NID,'active',datetime('now'))"
dbx "UPDATE users SET level=8 WHERE id=$NID"
C_N=$(db "SELECT coins FROM users WHERE id=$NID"); C_T=$(db "SELECT coins FROM users WHERE id=$TID")
ok "second graduate this week" "$(x grad "$(lid $TID $NID)")" "graduated=1"
ok "newcomer still rewarded" "$(( $(db "SELECT coins FROM users WHERE id=$NID") - C_N ))" 150
ok "mentor over the weekly cap gets no Petals" "$(( $(db "SELECT coins FROM users WHERE id=$TID") - C_T ))" 0
ok "flagged unrewarded" "$(db "SELECT mentor_rewarded FROM pmentor_grads WHERE newcomer_id=$NID")" 0
setcfg pmentor_grad_week_cap 3
echo "-- sweep: a level raised by other means graduates when the tab opens"
dbx "UPDATE users SET level=3 WHERE id=$PID_"; dbx "DELETE FROM pmentor_links WHERE newcomer_id=$PID_"
dbx "INSERT INTO pmentor_links (mentor_id,newcomer_id,status,created_at) VALUES ($QID,$PID_,'active',datetime('now'))"; dbx "UPDATE users SET level=9 WHERE id=$PID_"
get $PP 'pals.php?tab=mentor' >/dev/null; ok "swept" "$(link $QID $PID_)" graduated

echo "== 9. admin page, switch off"
rm -f $AD; get $AD login.php >/dev/null; post $AD login.php -d username=admin -d password=TestPassword123 >/dev/null
get $AD admin/mentors.php >/dev/null; has "admin list" $H 'Player mentors'
get $A admin/mentors.php >/dev/null; hasnt "players can't open it" $H 'Player mentors'
dbx "INSERT OR REPLACE INTO pmentor_links (mentor_id,newcomer_id,status,created_at) VALUES ($QID,$NID,'active',datetime('now'))"
LQ=$(lid $QID $NID); get $AD admin/mentors.php >/dev/null; post $AD admin/mentors.php -d do=end -d id=$LQ >/dev/null; ok "admin ends a link" "$(link $QID $NID)" ended
get $A admin/mentors.php >/dev/null; curl -s -c $A -b $A -X POST "$BASE/admin/mentors.php" -d do=toggle -o /dev/null; ok "player can't toggle" "$(db "SELECT COALESCE((SELECT value FROM settings WHERE name='pmentor_on'),'1')")" 1
get $AD admin/mentors.php >/dev/null; curl -s -c $AD -b $AD -X POST "$BASE/admin/mentors.php" -d do=end -d id=$LQ -o /dev/null
get $AD admin/mentors.php >/dev/null; post $AD admin/mentors.php -d do=toggle >/dev/null
ok "admin switched it off" "$(db "SELECT value FROM settings WHERE name='pmentor_on'")" 0
dbx "UPDATE pmentor_links SET status='active' WHERE mentor_id=$QID AND newcomer_id=$NID"
ok "off: no XP bonus" "$(x xp $NID 100 | sed "s/ level=.*//")" "gain=100 mentor=0"
dbx "UPDATE users SET level=3 WHERE id=$PID_"; dbx "DELETE FROM pmentor_grads WHERE newcomer_id=$PID_"
act $PP pm_request $BID; ok "off: no new requests" "$(link $BID $PID_)" ""
get $A 'pals.php?tab=mentor' >/dev/null; has "tab says resting" $H 'resting'
get $A "profile.php?id=$BID" >/dev/null; hasnt "off: no profile button" $H 'Ask to be my mentor'
get $AD admin/mentors.php >/dev/null; post $AD admin/mentors.php -d do=toggle -d on=1 >/dev/null; ok "admin switched it back on" "$(db "SELECT value FROM settings WHERE name='pmentor_on'")" 1

echo "== 10. pages still fine, error log"
for pg in pals.php 'pals.php?tab=friends' 'pals.php?tab=mentor' garden.php 'community.php?t=jar'; do ok "GET $pg" "$(get $A "$pg")" 200; done
get $A 'community.php?t=about' >/dev/null; has "pulse line wraps in one block" $H 'pulsetxt'
echo "== php errors"; if grep -iE 'fatal|warning|notice|deprecated' $LOG; then FAILS=$((FAILS+1)); else echo "(none)"; fi
echo; [ $FAILS -eq 0 ] && echo "ALL PASSED" || echo "$FAILS FAILED"
exit $FAILS
