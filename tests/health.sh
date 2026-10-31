#!/bin/bash
# v2.3.5 health that stays with the gnome (includes/health.php). Fresh SQLite install in a private copy.
# Usage: tests/health.sh [GAME_COPY_DIR] [PORT] [ROUTER]
HERE=$(cd "$(dirname "$0")" && pwd)
GAME=${1:-}; PORT=${2:-8795}; ROUTER=${3:-$HERE/router.php}
if [ -z "$GAME" ]; then T=$(mktemp -d); cp -r "$HERE/../game" "$T/game"; GAME=$T/game; fi
rm -f "$GAME/config.php"; rm -rf "$GAME/data"; mkdir -p "$GAME/data"
BASE=http://127.0.0.1:$PORT
LOG=$(mktemp)
php -d session.save_path=/tmp -d display_errors=1 -S 127.0.0.1:$PORT -t "$GAME" "$ROUTER" >$LOG 2>&1 & PID=$!; sleep 1
trap "kill $PID 2>/dev/null" EXIT
C=$(mktemp); H=$(mktemp); A=$(mktemp)
FAILS=0
chk() { if [ "$2" = 1 ]; then echo "  ok   $1"; else echo "  FAIL $1 $3"; FAILS=$((FAILS+1)); fi; }
csrf() { grep -o 'name="csrf" value="[^"]*"' "$1" | head -1 | sed 's/.*value="\([^"]*\)".*/\1/'; }
get() { curl -s -c $C -b $C "$BASE/$1" -o $H -w '%{http_code}'; }
post() { local page=$1; shift; curl -s -c $C -b $C -X POST "$BASE/$page" --data-urlencode "csrf=$(csrf $H)" "$@" -o $H -w '%{http_code}'; }
db() { php -r '$p=new PDO("sqlite:'$GAME'/data/game.sqlite"); foreach($p->query($argv[1])->fetchAll(PDO::FETCH_NUM) as $r) echo implode(" | ",$r),"\n";' "$1"; }
dbx() { php -r '$p=new PDO("sqlite:'$GAME'/data/game.sqlite"); $p->exec($argv[1]);' "$1"; }
flashes() { grep -oE 'class="flash (ok|err)">[^<]*' $H | sed 's/class="flash [a-z]*">//' | tr '\n' ' '; }

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
SID=$(db "SELECT id FROM users WHERE username='sprout'")
echo "onboarded: $(db "SELECT onboarded FROM users WHERE username='sprout'")"
dbx "UPDATE settings SET value='100000' WHERE name='event_chance'"; dbx "INSERT OR IGNORE INTO settings (name, value) VALUES ('event_chance','100000')"
dbx "UPDATE users SET tour_step=0, level=30, stat_grit=26, stat_hardiness=26, stat_nimble=22, energy=500, coins=5000 WHERE id=$SID"
dbx "UPDATE expeditions SET status='done' WHERE user_id=$SID"


pick() { db "SELECT lm.id||' '||lm.location_id||' '||COALESCE(l.landscape,'')||' '||lm.name FROM landmarks lm JOIN locations l ON l.id=lm.location_id WHERE lm.kind='$1' ORDER BY lm.id LIMIT 1 OFFSET ${2:-0}"; }
goto() { dbx "UPDATE users SET location_id=$1 WHERE id=$SID"; }
adv() { get adventure.php >/dev/null; cp $H $A; }
lmact() { get world.php >/dev/null; post landmark.php "$@" >/dev/null; }
EXPID() { db "SELECT id FROM expeditions WHERE user_id=$SID ORDER BY id DESC LIMIT 1"; }
ESTATUS() { db "SELECT status FROM expeditions WHERE user_id=$SID ORDER BY id DESC LIMIT 1"; }
EDEPTH() { db "SELECT depth FROM expeditions WHERE user_id=$SID ORDER BY id DESC LIMIT 1"; }
SCENES() { db "SELECT COUNT(*) FROM walk_scene"; }
logline() { db "SELECT log FROM expeditions WHERE id=$1" | php -r '$l=json_decode(stream_get_contents(STDIN),true); foreach($l as $x) echo $x,"\n";'; }

get login.php >/dev/null; post login.php -d username=sprout -d 'password=TestPass123!' >/dev/null
PHPR() { php -r '$_SERVER["SCRIPT_NAME"]="/adventure.php"; require "'$GAME'/includes/bootstrap.php"; require_once "'$GAME'/includes/adventure.php"; require_once "'$GAME'/includes/gnome.php"; $u = q_one("SELECT * FROM users WHERE id='$SID'"); '"$1" 2>&1 | tail -3; }
MAXHP=$(PHPR 'echo hp_max($u);'); echo "   max health $MAXHP"
HOME_LOC=$(db "SELECT location_id FROM users WHERE id=$SID")
WILD=$(db "SELECT id FROM locations WHERE kind IN ('wonder','lair') ORDER BY id LIMIT 1")
chk "start: full health is stored as NULL and reads as max" "$([ "$(PHPR 'echo hp_get($u)[0];')" = "$MAXHP" ] && [ "$(db "SELECT COALESCE(hp,'null') FROM users WHERE id=$SID")" = null ] && echo 1)"
chk "the village counts as a town (location kind $(db "SELECT kind FROM locations WHERE id=$HOME_LOC"))" "$([ "$(db "SELECT kind FROM locations WHERE id=$HOME_LOC")" = village ] && echo 1)"

echo "== 1 health a minute in town"
dbx "UPDATE users SET hp=10, hp_at=datetime('now','-5 minutes') WHERE id=$SID"
chk "10 health + 5 minutes in a town = 15" "$([ "$(PHPR 'echo hp_get($u)[0];')" = 15 ] && echo 1)"
dbx "UPDATE users SET hp=10, hp_at=datetime('now','-30 seconds') WHERE id=$SID"
chk "under a minute: nothing yet" "$([ "$(PHPR 'echo hp_get($u)[0];')" = 10 ] && echo 1)"
dbx "UPDATE users SET hp=10, hp_at=NULL WHERE id=$SID"
chk "clock stopped: reading starts it, no free health" "$([ "$(PHPR 'echo hp_get($u)[0];')" = 10 ] && [ "$(db "SELECT COUNT(*) FROM users WHERE id=$SID AND hp_at IS NOT NULL")" = 1 ] && echo 1)"
dbx "UPDATE users SET hp=10, hp_at=datetime('now','-600 minutes') WHERE id=$SID"
chk "a long wait heals up to max, then stores NULL" "$([ "$(PHPR 'echo hp_get($u)[0];')" = "$MAXHP" ] && [ "$(db "SELECT COALESCE(hp,'null') FROM users WHERE id=$SID")" = null ] && echo 1)"

echo "== no health while off the road or out adventuring"
dbx "UPDATE users SET hp=10, hp_at=datetime('now','-5 minutes'), location_id=$WILD WHERE id=$SID"
chk "at a wonder/lair (not a town): no health, clock stopped" "$([ "$(PHPR 'echo hp_get($u)[0];')" = 10 ] && [ "$(db "SELECT COUNT(*) FROM users WHERE id=$SID AND hp_at IS NOT NULL")" = 0 ] && echo 1)"
dbx "UPDATE users SET location_id=$HOME_LOC, hp=10, hp_at=datetime('now','-5 minutes') WHERE id=$SID"
RID=$(db "SELECT id FROM routes WHERE kind='road' AND (a_id=$HOME_LOC OR b_id=$HOME_LOC) ORDER BY id LIMIT 1")
R=$(PHPR '[$ok,$m]=start_expedition($u,'$RID'); echo $ok ? "started" : $m;')
chk "start a road walk hurt (it works: $R)" "$([ "$R" = started ] && echo 1)"
EXPH=$(db "SELECT hp FROM expeditions WHERE user_id=$SID ORDER BY id DESC LIMIT 1")
chk "the walk starts with the gnome's health ($EXPH of $MAXHP), not full" "$([ "$EXPH" -ge 14 ] && [ "$EXPH" -le 16 ] && echo 1)"
dbx "UPDATE users SET hp_at=datetime('now','-30 minutes') WHERE id=$SID"
chk "while adventuring the clock does not run" "$([ "$(PHPR 'echo hp_get($u)[0];')" -le 16 ] && echo 1)"

echo "== walking home keeps the damage; a knock-out wakes at half"
PHPR '$exp = active_expedition((int)$u["id"]); $exp["hp"] = 7; save_exp($exp);' >/dev/null
chk "saving the adventure stores its health on the gnome (7)" "$([ "$(db "SELECT hp FROM users WHERE id=$SID")" = 7 ] && [ "$(db "SELECT COUNT(*) FROM users WHERE id=$SID AND hp_at IS NULL")" = 1 ] && echo 1)"
PHPR '$exp = active_expedition((int)$u["id"]); $exp["hp"] = 0; knock_out($u, $exp, ["name"=>"Barn Rat","slug"=>"barn-rat"]); save_exp($exp);' >/dev/null
KO=$(db "SELECT hp FROM users WHERE id=$SID")
chk "knocked out: wakes with half ($KO of $MAXHP)" "$([ "$KO" = "$(( (MAXHP + 1) / 2 ))" ] && [ "$(db "SELECT status FROM expeditions WHERE user_id=$SID ORDER BY id DESC LIMIT 1")" = ko ] && echo 1)"
chk "the clock runs again once it is over" "$([ "$(db "SELECT COUNT(*) FROM users WHERE id=$SID AND hp_at IS NOT NULL")" = 1 ] && echo 1)"

echo "== other healing: level up, potion, snack, rest"
dbx "UPDATE users SET hp=5, hp_at=NULL WHERE id=$SID"
PHPR 'add_xp((int)$u["id"], 1000000);' >/dev/null
chk "a level up heals fully" "$([ "$(db "SELECT COALESCE(hp,'null') FROM users WHERE id=$SID")" = null ] && echo 1)"
MAXHP=$(PHPR 'echo hp_max($u);'); echo "   max health after the level up: $MAXHP"
POT=$(PHPR 'require_once "'$GAME'/includes/pal_jobs.php"; echo pj_potion_id();')
dbx "UPDATE users SET hp=5, hp_at=NULL WHERE id=$SID"
PHPR 'require_once "'$GAME'/includes/pal_jobs.php"; give_item((int)$u["id"], pj_potion_id(), 2);' >/dev/null
get gnome.php >/dev/null
chk "My Gnome shows the Health box with the potion button" "$(grep -q 'class="box hpcard"' $H && grep -q 'name="what" value="potion"' $H && echo 1)"
post gnome.php -d do=heal -d what=potion -d item=$POT >/dev/null
HP2=$(PHPR 'echo hp_get($u)[0];')
chk "a Healing Potion heals half of max ($HP2 of $MAXHP)" "$([ "$HP2" -ge $((5 + MAXHP / 2 - 1)) ] && [ "$(db "SELECT qty FROM user_items WHERE user_id=$SID AND item_id=$POT")" = 1 ] && echo 1)"
dbx "UPDATE users SET hp=NULL, hp_at=NULL WHERE id=$SID"
get gnome.php >/dev/null; post gnome.php -d do=heal -d what=potion -d item=$POT >/dev/null
chk "unhurt: the potion is not wasted" "$([ "$(db "SELECT qty FROM user_items WHERE user_id=$SID AND item_id=$POT")" = 1 ] && echo 1)"
dbx "UPDATE users SET hp=3, hp_at=NULL WHERE id=$SID"
N=$(PHPR 'echo hp_heal_pct($u, 50);')
chk "a rest heals half of max (+$N)" "$([ "$N" = "$(( (MAXHP + 1) / 2 ))" ] || [ "$N" = "$((MAXHP / 2))" ] && echo 1)"
N2=$(PHPR 'echo hp_heal_pct($u, 100);')
chk "a night's sleep heals the rest (+$N2), and full is stored as NULL" "$([ "$(db "SELECT COALESCE(hp,'null') FROM users WHERE id=$SID")" = null ] && echo 1)"

echo "== the old rule when switched off"
dbx "INSERT OR REPLACE INTO settings (name, value) VALUES ('hp_persist','0')"
dbx "UPDATE users SET hp=4, hp_at=NULL WHERE id=$SID"
chk "hp_persist off: adventures start at full health again" "$([ "$(PHPR 'echo hp_start($u, 99);')" = 99 ] && echo 1)"

echo
if [ $FAILS -eq 0 ]; then echo "all health checks passed"; else echo "$FAILS FAILED"; exit 1; fi
