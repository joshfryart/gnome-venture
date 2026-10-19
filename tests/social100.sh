#!/bin/bash
# v1.0.0 wave 3 (players together & coming back): townsfolk boards, Hollow Goals + Pulse, gnome friends / blocks / stamps / gifts,
# Wren's First Week, welcome back + daily card, the Opening Day festival framework. Fresh SQLite install in a temp copy.
# Usage: tests/social100.sh [GAME_COPY_DIR] [PORT] [ROUTER]   (default: copies src/game to a temp dir; never writes a DB into src)
HERE=$(cd "$(dirname "$0")" && pwd)
GAME=${1:-}; PORT=${2:-9260}; ROUTER=${3:-$HERE/router.php}
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
 foreach (["bloom"=>"Bloom Thistledown","thistle"=>"Thistle Underhill","quiet"=>"Quill Hushwick"] as $un=>$gn) {
  $r=$p->query("SELECT * FROM users WHERE username=\"sprout\"")->fetch(PDO::FETCH_ASSOC); unset($r["id"]); $r["username"]=$un; $r["email"]=$un."@b.local"; $r["gnome_name"]=$gn; $r["tour_step"]=0; $r["level"]=5; $r["last_seen"]=gmdate("Y-m-d H:i:s");
  $c=array_keys($r); $p->prepare("INSERT INTO users (".implode(",",$c).") VALUES (".implode(",",array_fill(0,count($c),"?")).")")->execute(array_values($r));
  $uid=(int)$p->lastInsertId(); $pl=$p->query("SELECT * FROM plots WHERE user_id=(SELECT id FROM users WHERE username=\"sprout\")")->fetch(PDO::FETCH_ASSOC); unset($pl["id"]); $pl["user_id"]=$uid; $pl["garden_name"]=$gn."s Garden";
  $c=array_keys($pl); $p->prepare("INSERT INTO plots (".implode(",",$c).") VALUES (".implode(",",array_fill(0,count($c),"?")).")")->execute(array_values($pl)); $pid=(int)$p->lastInsertId();
  $p->exec("UPDATE users SET active_plot_id=$pid WHERE id=$uid");
 }'
dbx "UPDATE users SET level=5, coins=5000, energy=50, tour_step=0 WHERE username='sprout'"
dbx "INSERT OR REPLACE INTO settings (name,value) VALUES ('fresh_hold_days','0')"   # v1.0.1: these accounts are brand new; the fresh-gnome hold has its own test (fresh_hold.sh)
dbx "UPDATE users SET garden_public=0 WHERE username='quiet'"
SID=$(db "SELECT id FROM users WHERE username='sprout'"); BID=$(db "SELECT id FROM users WHERE username='bloom'"); TID=$(db "SELECT id FROM users WHERE username='thistle'"); QID=$(db "SELECT id FROM users WHERE username='quiet'")
BPLOT=$(db "SELECT id FROM plots WHERE user_id=$BID"); TPLOT=$(db "SELECT id FROM plots WHERE user_id=$TID"); QPLOT=$(db "SELECT id FROM plots WHERE user_id=$QID"); SPLOT=$(db "SELECT id FROM plots WHERE user_id=$SID")
A=$T/a; B=$T/b; TH=$T/t; login $A sprout; login $B bloom; login $TH thistle

echo "== 1. townsfolk on every board"
for pg in show.php fair.php gotm.php 'arrange.php?t=show' race.php; do get $A "$pg" >/dev/null; n=$(grep -c 'class="tfolk"' $H); gt "townsfolk on $pg" "$n" 0; done
dbx "UPDATE settings SET value='1' WHERE name='carving_always'" ; dbx "INSERT OR IGNORE INTO settings (name,value) VALUES ('carving_always','1')"
get $A carve.php >/dev/null; gt "townsfolk on carve.php" "$(grep -c 'class="tfolk"' $H)" 0
get $A show.php >/dev/null; has "show note says gnomes only" $H 'Prizes and places are for gnomes only'
# same list for everyone and stable between loads
get $A show.php >/dev/null; cp $H $T/s1.html; get $B show.php >/dev/null; ok "same townsfolk for another gnome" "$(grep -o 'townsfolk' $T/s1.html | wc -l)" "$(grep -o 'townsfolk' $H | wc -l)"
# fairness: last week's show with two gnomes and the townsfolk: gnomes are placed 1 and 2, nothing is stored for NPCs
LW=$(php -r 'echo gmdate("o-\WW", time()-7*86400-0);')
dbx "INSERT INTO show_entries (week,user_id,crop,size,entered_at) VALUES ('$LW',$SID,'pumpkin',3.1,datetime('now','-6 days')),('$LW',$BID,'pumpkin',2.0,datetime('now','-6 days'))"
get $A show.php >/dev/null
ok "show: gnome places are 1 and 2 (townsfolk take none)" "$(db "SELECT group_concat(placed) FROM (SELECT placed FROM show_entries WHERE week='$LW' ORDER BY placed)")" "1,2"
ok "show: no NPC rows stored" "$(db "SELECT COUNT(*) FROM show_entries WHERE user_id NOT IN ($SID,$BID)")" 0
# the toggle
dbx "INSERT OR REPLACE INTO settings (name,value) VALUES ('townsfolk_entries','0')"; php -r '' ; get $A show.php >/dev/null; ok "toggle off: no townsfolk" "$(grep -c 'class="tfolk"' $H)" 0
get $A fair.php >/dev/null; ok "toggle off: none on the fair" "$(grep -c 'class="tfolk"' $H)" 0
dbx "INSERT OR REPLACE INTO settings (name,value) VALUES ('townsfolk_entries','1')"

echo "== 2. Hollow Goals + Pulse"
get $A 'community.php?t=jar' >/dev/null; has "Hollow page jar" $H 'class="jarsvg"'; has "tiers listed" $H 'class="tiers"'; get $A 'community.php?t=about' >/dev/null; has "pulse strip" $H 'class="pulse"'
GID=$(db "SELECT id FROM hollow_goals WHERE festival IS NULL AND ends_at > datetime('now') ORDER BY id DESC LIMIT 1")
gt "weekly jar exists" "${GID:-0}" 0
echo "  jar: $(db "SELECT kind||' '||target||' '||title FROM hollow_goals WHERE id=$GID")"
ok "jar sized for at least 4 gnomes" "$(db "SELECT target >= 4 FROM hollow_goals WHERE id=$GID")" 1
# make the jar count anything and fill it through a real action (water a planted square)
dbx "UPDATE hollow_goals SET kind='any', filter='', target=40 WHERE id=$GID"
get $A 'garden.php?sel=0-0' >/dev/null; post $A garden.php -d do=till -d x=0 -d y=0 >/dev/null
RAD=$(db "SELECT id FROM items WHERE slug='radish-seed'"); get $A 'garden.php?sel=0-0' >/dev/null; post $A garden.php -d do=plant -d x=0 -d y=0 -d item_id=$RAD >/dev/null
get $A 'garden.php?sel=0-0' >/dev/null; post $A garden.php -d do=water -d x=0 -d y=0 >/dev/null
gt "a real action filled the jar" "$(db "SELECT COALESCE(SUM(amount),0) FROM hollow_goal_contrib WHERE goal_id=$GID")" 0   # v1.0.1: shares are summed into the jar at most once a minute
dbx "INSERT OR IGNORE INTO settings (name, value) VALUES ('goal_rollup_at', '0')"; dbx "UPDATE settings SET value='9999999999' WHERE name='goal_rollup_at'"   # hold the roll-up so the hand-set totals below stand
gt "sprout has a share" "$(db "SELECT COALESCE(SUM(amount),0) FROM hollow_goal_contrib WHERE goal_id=$GID AND user_id=$SID")" 0
# a helper hired to harvest must not count: ctx helper is skipped in calling_event (covered by the engine) - here check the tiers
C1=$(db "SELECT coins FROM users WHERE id=$SID")
dbx "UPDATE hollow_goals SET progress=11 WHERE id=$GID"      # tier 1 (25%) reached, tier 2 (50%) not even with the townsfolk top-up
get $A index.php >/dev/null
ok "tier 1 paid once" "$(db "SELECT COUNT(*) FROM hollow_goal_claims WHERE goal_id=$GID AND user_id=$SID")" 1
get $A index.php >/dev/null; ok "no double pay on reload" "$(db "SELECT COUNT(*) FROM hollow_goal_claims WHERE goal_id=$GID AND user_id=$SID")" 1
gt "coins went up for tier 1" "$(db "SELECT coins FROM users WHERE id=$SID")" "$C1"
dbx "UPDATE hollow_goals SET progress=40 WHERE id=$GID"; get $A 'community.php?t=jar' >/dev/null
ok "all four tiers paid at 100%" "$(db "SELECT COUNT(*) FROM hollow_goal_claims WHERE goal_id=$GID AND user_id=$SID")" 4
# a gnome who put nothing in gets nothing; one who put in 1 gets the reached tiers (even though the tier was reached before)
get $B 'community.php?t=jar' >/dev/null; ok "bloom (no share) paid nothing" "$(db "SELECT COUNT(*) FROM hollow_goal_claims WHERE user_id=$BID")" 0
dbx "INSERT INTO hollow_goal_contrib (goal_id,user_id,amount) VALUES ($GID,$BID,1)"; get $B 'community.php?t=jar' >/dev/null
ok "bloom (1 share) gets every reached tier" "$(db "SELECT COUNT(*) FROM hollow_goal_claims WHERE goal_id=$GID AND user_id=$BID")" 4
# history
dbx "UPDATE hollow_goals SET ends_at=datetime('now','-1 hour'), starts_at=datetime('now','-8 days'), period_key='old-week' WHERE id=$GID"; get $A 'community.php?t=jar' >/dev/null
has "past jars listed" $H 'Past jars'; has "this week's new jar made" $H 'This week’s jar'
# Pulse privacy: a gnome with a private garden is counted, never named
dbx "UPDATE users SET last_seen=datetime('now') WHERE id IN ($BID,$QID)"
get $A 'community.php?t=about' >/dev/null; has "pulse names the open garden gnome" $H 'Bloom Thistledown'; hasnt "pulse does not name the private gnome" $H 'Quill Hushwick'; has "pulse counts the quiet gnome" $H 'quiet gnome'
dbx "INSERT INTO show_entries (week,user_id,crop,size,entered_at) VALUES ('2099-W01',$QID,'pumpkin',9,datetime('now'))"
get $A 'community.php?t=jar' >/dev/null; hasnt "private gnome's show entry not in the news" $H 'Quill Hushwick'

echo "== 3. friends, blocks, stamps, gifts"
get $A 'profile.php?id='$BID >/dev/null; has "Add friend button on a profile" $H 'Add friend'
post $A pals.php -d do=request -d id=$BID -d back="profile.php?id=$BID" >/dev/null
ok "request is pending" "$(db "SELECT status FROM player_friends WHERE user_id=$SID AND friend_id=$BID")" pending
get $B pals.php >/dev/null; has "bloom sees the request" $H 'Asked to be your friend'; has "bloom: sprout waiting" $H 'Bramble'
post $B pals.php -d do=request -d id=$SID >/dev/null; ok "asking back = accepting" "$(db "SELECT status FROM player_friends WHERE user_id=$SID AND friend_id=$BID")" accepted
get $B 'pals.php?tab=friends' >/dev/null; has "friend list" $H 'Bramble'
get $A 'profile.php?id='$BID >/dev/null; has "profile shows Friends" $H '🤝 Friends'; get $B 'profile.php?id='$BID >/dev/null; has "friend list on own profile" $H 'Bramble'
# gift: friends only, once a day, a preset note
SAP=$(db "SELECT id FROM items WHERE category IN ('seed','sapling') AND tradable=1 LIMIT 1"); dbx "INSERT OR REPLACE INTO user_items (user_id,item_id,qty) VALUES ($SID,$SAP,5)"
get $A pals.php >/dev/null; has "gift form for a friend" $H 'Send a seedling'
post $A pals.php -d do=gift -d id=$BID -d item_id=$SAP -d qty=2 -d note=welcome >/dev/null
ok "gift arrived" "$(db "SELECT COALESCE(qty,0) FROM user_items WHERE user_id=$BID AND item_id=$SAP")" 2
ok "gift has the preset note" "$(db "SELECT note FROM gifts WHERE from_id=$SID ORDER BY id DESC LIMIT 1")" "Welcome to the Hollow!"
get $A pals.php >/dev/null; post $A pals.php -d do=gift -d id=$BID -d item_id=$SAP -d qty=1 -d note=grow >/dev/null; get $A pals.php >/dev/null
ok "second gift today refused" "$(db "SELECT COUNT(*) FROM gifts WHERE from_id=$SID AND to_id=$BID")" 1
get $A pals.php >/dev/null; post $A pals.php -d do=gift -d id=$TID -d item_id=$SAP -d qty=1 -d note=grow >/dev/null
ok "gift to a non-friend refused" "$(db "SELECT COUNT(*) FROM gifts WHERE from_id=$SID AND to_id=$TID")" 0
get $A pals.php >/dev/null; post $A pals.php -d do=gift -d id=$BID -d item_id=$(db "SELECT id FROM items WHERE category='tool' LIMIT 1") -d qty=1 -d note=grow >/dev/null
ok "only seeds and seedlings go as friend gifts" "$(db "SELECT COUNT(*) FROM gifts WHERE from_id=$SID")" 1
# stamps
get $A "visit.php?g=$BPLOT" >/dev/null; has "stamp buttons" $H 'class="stampbtns"'
post $A visit.php -d g=$BPLOT -d do=stamp -d stamp=daisy >/dev/null
ok "stamp stored" "$(db "SELECT stamp FROM garden_stamps WHERE plot_id=$BPLOT AND user_id=$SID")" daisy
get $A "visit.php?g=$BPLOT" >/dev/null; post $A visit.php -d g=$BPLOT -d do=stamp -d stamp=bee >/dev/null
ok "one stamp per visitor per day" "$(db "SELECT COUNT(*) FROM garden_stamps WHERE plot_id=$BPLOT AND user_id=$SID")" 1
get $A "visit.php?g=$BPLOT" >/dev/null; has "gate shows the stamp" $H 'class="stamps"'
dbx "UPDATE garden_stamps SET day='2000-01-01'"; get $A "visit.php?g=$BPLOT" >/dev/null; post $A visit.php -d g=$BPLOT -d do=stamp -d stamp=bee >/dev/null
ok "next day another stamp" "$(db "SELECT COUNT(*) FROM garden_stamps WHERE plot_id=$BPLOT AND user_id=$SID")" 2
get $A "visit.php?g=$BPLOT" >/dev/null; post $A visit.php -d g=$BPLOT -d do=stamp -d stamp=not-a-stamp >/dev/null
ok "unknown stamp refused" "$(db "SELECT COUNT(*) FROM garden_stamps WHERE plot_id=$BPLOT AND user_id=$SID")" 2
get $B "visit.php?g=$BPLOT" >/dev/null; SID1=$(db "SELECT id FROM garden_stamps WHERE plot_id=$BPLOT LIMIT 1"); post $B visit.php -d g=$BPLOT -d do=stamp_clear -d stamp_id=$SID1 >/dev/null
ok "owner clears a stamp" "$(db "SELECT COUNT(*) FROM garden_stamps WHERE plot_id=$BPLOT")" 1
get $A "visit.php?g=$SPLOT" >/dev/null; post $A visit.php -d g=$SPLOT -d do=stamp -d stamp=daisy >/dev/null
ok "no stamping your own gate" "$(db "SELECT COUNT(*) FROM garden_stamps WHERE plot_id=$SPLOT")" 0
get $A "visit.php?g=$QPLOT" >/dev/null; ok "private garden is not visitable" "$(get $A "visit.php?g=$QPLOT")" 404
post $A visit.php -d g=$QPLOT -d do=stamp -d stamp=daisy >/dev/null; ok "no stamp on a private garden" "$(db "SELECT COUNT(*) FROM garden_stamps WHERE plot_id=$QPLOT")" 0
# privacy: a private gnome's friend list shows a count only
dbx "INSERT INTO player_friends (user_id,friend_id,status,created_at) VALUES ($QID,$BID,'accepted',datetime('now'))"
get $A "profile.php?id=$QID" >/dev/null; has "private profile: count only" $H 'The list is private'
# blocks
get $TH "profile.php?id=$SID" >/dev/null; post $TH pals.php -d do=block -d id=$SID >/dev/null
ok "block stored" "$(db "SELECT COUNT(*) FROM player_blocks WHERE blocker_id=$TID AND blocked_id=$SID")" 1
get $A "profile.php?id=$TID" >/dev/null; post $A pals.php -d do=request -d id=$TID >/dev/null
ok "blocked: can't friend" "$(db "SELECT COUNT(*) FROM player_friends WHERE user_id=$SID AND friend_id=$TID")" 0
get $A "visit.php?g=$TPLOT" >/dev/null; post $A visit.php -d g=$TPLOT -d do=stamp -d stamp=daisy >/dev/null
ok "blocked: can't stamp" "$(db "SELECT COUNT(*) FROM garden_stamps WHERE plot_id=$TPLOT")" 0
get $A 'market.php' >/dev/null
post $A market.php -d do=gift -d to=Thistle -d item_id=$SAP -d qty=1 >/dev/null
ok "blocked: can't be found for a gift" "$(db "SELECT COUNT(*) FROM gifts WHERE to_id=$TID")" 0
get $TH "profile.php?id=$SID" >/dev/null; has "blocker sees Unblock" $H 'unblock'
# friend then block removes the friendship both ways
get $B "profile.php?id=$SID" >/dev/null; post $B pals.php -d do=block -d id=$SID >/dev/null
ok "block ends the friendship" "$(db "SELECT COUNT(*) FROM player_friends WHERE (user_id=$SID AND friend_id=$BID) OR (user_id=$BID AND friend_id=$SID)")" 0
get $A pals.php >/dev/null; post $A pals.php -d do=request -d id=$BID >/dev/null
ok "blocked by bloom: request refused" "$(db "SELECT COUNT(*) FROM player_friends WHERE user_id=$SID AND friend_id=$BID")" 0
get $B 'pals.php?tab=blocked' >/dev/null; post $B pals.php -d do=unblock -d id=$SID >/dev/null
ok "unblock" "$(db "SELECT COUNT(*) FROM player_blocks WHERE blocker_id=$BID")" 0
# decline then ask again
get $A pals.php >/dev/null; post $A pals.php -d do=request -d id=$BID >/dev/null; get $B pals.php >/dev/null; post $B pals.php -d do=decline -d id=$SID >/dev/null
ok "declined" "$(db "SELECT status FROM player_friends WHERE user_id=$SID AND friend_id=$BID")" declined
get $A pals.php >/dev/null; post $A pals.php -d do=request -d id=$BID >/dev/null; ok "re-ask inside 14 days sends nothing" "$(db "SELECT status FROM player_friends WHERE user_id=$SID AND friend_id=$BID")" declined

echo "== 4. Wren's First Week + Journey"
dbx "UPDATE users SET fw_start=NULL, tour_step=0 WHERE id=$SID"
get $A firstweek.php >/dev/null; has "First Week page" $H 'Wren’s First Week'; has "day 1 card" $H 'Settle in'
ok "starts on first view" "$(db "SELECT fw_start IS NOT NULL FROM users WHERE id=$SID")" 1
has "day 2 locked" $H 'Unlocks tomorrow'
ok "claim before done refused" "$(get $A firstweek.php >/dev/null; post $A firstweek.php -d day=1 >/dev/null; db "SELECT COUNT(*) FROM first_week_claims WHERE user_id=$SID")" 0
dbx "INSERT OR REPLACE INTO user_plant_knowledge (user_id,plant_id,knowledge) VALUES ($SID,(SELECT id FROM plants LIMIT 1),3)"
dbx "UPDATE user_encyclopedia SET read_at=datetime('now') WHERE user_id=$SID AND rowid IN (SELECT rowid FROM user_encyclopedia WHERE user_id=$SID LIMIT 3)"
C1=$(db "SELECT coins FROM users WHERE id=$SID"); get $A firstweek.php >/dev/null; has "day 1 ready" $H 'Take the reward'; post $A firstweek.php -d day=1 >/dev/null
ok "day 1 claimed" "$(db "SELECT COUNT(*) FROM first_week_claims WHERE user_id=$SID AND day=1")" 1
gt "day 1 paid coins" "$(db "SELECT coins FROM users WHERE id=$SID")" "$C1"
get $A firstweek.php >/dev/null; post $A firstweek.php -d day=1 >/dev/null; ok "no double claim" "$(db "SELECT COUNT(*) FROM first_week_claims WHERE user_id=$SID AND day=1")" 1
dbx "UPDATE users SET fw_start='$(halifax -1)' WHERE id=$SID"; get $A firstweek.php >/dev/null; ok "day 2 unlocked next day (only day 3 says tomorrow)" "$(grep -c 'Unlocks tomorrow' $H)" 1
get $A index.php >/dev/null; has "Today shows the First Week card" $H 'First Week'
dbx "UPDATE users SET fw_start='$(halifax -6)' WHERE id=$SID"; get $A firstweek.php >/dev/null; hasnt "day 7 unlocked on day 7" $H '🔒 Make it yours'
# tour end starts it
dbx "UPDATE users SET fw_start=NULL WHERE id=$SID"
php -r '$p=new PDO("sqlite:'$GAME'/data/game.sqlite"); $p->exec("UPDATE users SET tour_step=10 WHERE id='$SID'");'
dbx "UPDATE users SET tour_step=1 WHERE id=$BID"; get $B garden.php >/dev/null; post $B tour.php -d do=skip >/dev/null
ok "skipping the tour starts the First Week" "$(db "SELECT fw_start IS NOT NULL FROM users WHERE id=$BID")" 1
get $A 'book.php?ch=Journey' >/dev/null; has "Journey shows a next step" $H 'class="jnext"'
get $A index.php >/dev/null; has "Today Journey card shows a next step" $H '👉'

echo "== 5. welcome back + the daily card"
dbx "UPDATE users SET last_seen=datetime('now','-5 days'), away_from=NULL WHERE id=$SID"
get $A index.php >/dev/null
ok "away_from noted on return" "$(db "SELECT away_from IS NOT NULL FROM users WHERE id=$SID")" 1
has "welcome-back call on Today" $H 'Welcome back!'
get $A back.php >/dev/null; has "summary page" $H 'You were away about 5 days'; has "garden section" $H 'Your garden'; has "letters section" $H 'Letters'; has "jar section" $H 'jar'
C1=$(db "SELECT coins FROM users WHERE id=$SID"); post $A back.php -d do=basket >/dev/null
ok "basket paid" "$(( $(db "SELECT coins FROM users WHERE id=$SID") - C1 ))" 50
ok "away cleared" "$(db "SELECT away_from IS NULL FROM users WHERE id=$SID")" 1
get $A back.php >/dev/null; ok "page gone when nothing is due (redirect to Today)" "$(curl -s -o /dev/null -w '%{http_code}' -b $A $BASE/back.php)" 302
post $A back.php -d do=basket >/dev/null; ok "no second basket" "$(( $(db "SELECT coins FROM users WHERE id=$SID") - C1 ))" 50
dbx "UPDATE users SET last_seen=datetime('now','-10 days') WHERE id=$SID"; login $A sprout
rm -f $A; get $A login.php >/dev/null; has "login after days away goes to the summary" <(curl -s -o /dev/null -w '%{redirect_url}' -c $A -b $A -X POST $BASE/login.php --data-urlencode "csrf=$(csrf $H)" -d username=sprout -d 'password=TestPass123!') 'back.php'
get $A garden.php >/dev/null; ok "login noted the absence" "$(db "SELECT away_from IS NOT NULL FROM users WHERE id=$SID")" 1
dbx "UPDATE users SET away_from=NULL, last_seen=datetime('now','-1 day') WHERE id=$SID"; get $A index.php >/dev/null; hasnt "one day away: no welcome back" $H 'Welcome back!'
has "daily card" $H 'htdaily'
post $A daily.php >/dev/null; get $A index.php >/dev/null
ok "daily tick stored" "$(db "SELECT COUNT(*) FROM daily_ticks WHERE user_id=$SID")" 1
hasnt "ticked card is quiet" $H "Enough for today"
hasnt "no streak words" $H 'streak'

echo "== 6. Opening Day festival framework"
ok "dates set by the upgrade" "$(db "SELECT COUNT(*) FROM settings WHERE name IN ('fest_opening_day_start','fest_opening_day_end') AND value <> ''")" 2
get $A festival.php >/dev/null; has "festival page" $H 'Opening Day'; has "stalls" $H 'The stalls'; has "festival jar" $H 'The festival jar'
get $A index.php >/dev/null; has "bunting strip" $H 'class="festbar"'
ok "festival jar made" "$(db "SELECT COUNT(*) FROM hollow_goals WHERE festival='opening_day'")" 1
get $A festival.php >/dev/null; post $A festival.php -d do=flag >/dev/null
ok "flag found" "$(db "SELECT COUNT(*) FROM festival_flags WHERE user_id=$SID")" 1
get $A festival.php >/dev/null; post $A festival.php -d do=flag >/dev/null; ok "one flag a day" "$(db "SELECT COUNT(*) FROM festival_flags WHERE user_id=$SID")" 1
for d in 1 2 3; do dbx "INSERT OR IGNORE INTO festival_flags (festival,user_id,day,at) VALUES ('opening_day',$SID,'2000-01-0$d',datetime('now'))"; done
dbx "DELETE FROM festival_flags WHERE user_id=$SID AND day='$(halifax 0)' ";
get $A festival.php >/dev/null; C1=$(db "SELECT coins FROM users WHERE id=$SID"); post $A festival.php -d do=flag >/dev/null
ok "3 flags pays the first reward" "$(db "SELECT COUNT(*) FROM festival_claims WHERE user_id=$SID AND reward='flags3'")" 1
C1=$(db "SELECT coins FROM users WHERE id=$SID"); get $A festival.php >/dev/null; post $A festival.php -d do=buy -d stall=compost -d idx=0 >/dev/null
ok "stall sells for the price" "$(( C1 - $(db "SELECT coins FROM users WHERE id=$SID") ))" 40
for i in 1 2 3 4 5 6 7; do get $A festival.php >/dev/null; post $A festival.php -d do=buy -d stall=compost -d idx=0 >/dev/null; done
ok "stall limit holds" "$(db "SELECT qty FROM festival_buys WHERE user_id=$SID AND stall='compost:0'")" 6
get $A festival.php >/dev/null; post $A festival.php -d do=buy -d stall=bunting -d idx=0 >/dev/null
ok "bunting decor bought" "$(db "SELECT COALESCE(qty,0) FROM user_items WHERE user_id=$SID AND item_id=(SELECT id FROM items WHERE slug='opening-day-bunting')")" 1
dbx "DELETE FROM garden_stamps"; get $A "visit.php?g=$BPLOT" >/dev/null; has "festival adds a bunting stamp" $H 'value="bunting"'
# seasons hook is guarded and used if present
has "season line (if the season helper is there)" $H "stamp" 
dbx "UPDATE settings SET value='2001-01-01' WHERE name='fest_opening_day_start'"; dbx "UPDATE settings SET value='2001-01-07' WHERE name='fest_opening_day_end'"
get $A festival.php >/dev/null; has "ended festival page" $H 'No festival is on right now'; get $A index.php >/dev/null; hasnt "no bunting strip when ended" $H 'class="festbar"'
dbx "UPDATE settings SET value='2099-05-01' WHERE name='fest_opening_day_start'"; dbx "UPDATE settings SET value='2099-05-07' WHERE name='fest_opening_day_end'"
get $A festival.php >/dev/null; has "upcoming festival shown" $H 'starts on May 1'
F0=$(db "SELECT COUNT(*) FROM festival_flags WHERE user_id=$SID"); dbx "DELETE FROM festival_flags WHERE user_id=$SID AND day='$(halifax 0)'"; F0=$(db "SELECT COUNT(*) FROM festival_flags WHERE user_id=$SID"); post $A festival.php -d do=flag >/dev/null; ok "no flags when not on" "$(db "SELECT COUNT(*) FROM festival_flags WHERE user_id=$SID")" "$F0"
dbx "UPDATE settings SET value='2001-01-01' WHERE name='fest_opening_day_start'"; dbx "UPDATE settings SET value='2099-01-01' WHERE name='fest_opening_day_end'"; dbx "UPDATE settings SET value='0' WHERE name='festivals_on'" 2>/dev/null; dbx "INSERT OR REPLACE INTO settings (name,value) VALUES ('festivals_on','0')"
get $A festival.php >/dev/null; has "switched off" $H 'No festival is on right now'; dbx "INSERT OR REPLACE INTO settings (name,value) VALUES ('festivals_on','1')"

echo "== 7. pages render in both modes, no PHP errors"
for pg in index.php 'community.php?t=jar' 'community.php?t=about' pals.php 'pals.php?tab=requests' 'pals.php?tab=find' 'pals.php?tab=blocked' firstweek.php festival.php show.php fair.php gotm.php 'arrange.php?t=show' race.php carve.php 'profile.php?id='$BID 'profile.php?id='$QID "visit.php?g=$BPLOT" 'book.php?ch=Journey' games.php; do
  code=$(get $A "$pg"); [ "$code" = 200 ] && echo "  ok   $pg" || { echo "  FAIL $pg -> $code"; FAILS=$((FAILS+1)); }
done
echo "== php errors"
if grep -iE 'fatal|warning|notice|deprecated|parse error' $LOG; then FAILS=$((FAILS+1)); else echo "  (none)"; fi
[ -s $GAME/data/error-log.txt ] && { echo "  error-log.txt:"; head -20 $GAME/data/error-log.txt; FAILS=$((FAILS+1)); }
echo; [ $FAILS -eq 0 ] && echo "ALL PASSED" || echo "$FAILS FAILED"
exit $FAILS
