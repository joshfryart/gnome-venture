#!/bin/bash
# v0.9.5.2: Admin "Fresh start" for one player. Usage: reset.sh GAME PORT tests/router.php  (GAME = copy with empty data/, no config.php)
set -u
GAME=$1; PORT=$2; ROUTER=$3
BASE=http://127.0.0.1:$PORT
LOG=/tmp/reset-php.log
php -d session.save_path=/tmp -d error_reporting=-1 -d display_errors=0 -d log_errors=1 -d error_log=$LOG -S 127.0.0.1:$PORT -t $GAME $ROUTER >/tmp/reset-srv.log 2>&1 &
PID=$!; sleep 1
trap "kill $PID 2>/dev/null" EXIT
H=/tmp/reset.html; FAILS=0
check() { if [ "$2" = "$3" ]; then echo "ok   $1"; else echo "FAIL $1 (got '$2', want '$3')"; FAILS=$((FAILS+1)); fi; }
csrf() { grep -o 'name="csrf" value="[^"]*"' "$1" | head -1 | sed 's/.*value="\([^"]*\)".*/\1/'; }
get() { curl -s -c "$CK" -b "$CK" "$BASE/$1" -o $H -w '%{http_code} %{redirect_url}'; }
post() { local page=$1; shift; local t; t=$(csrf $H); curl -s -c "$CK" -b "$CK" -X POST "$BASE/$page" --data-urlencode "csrf=$t" "$@" -o /tmp/reset-post.html -w '%{http_code} %{redirect_url}'; }
db() { php -r '$p=new PDO("sqlite:'$GAME'/data/game.sqlite"); foreach($p->query($argv[1])->fetchAll(PDO::FETCH_NUM) as $r) echo implode(" | ",$r),"\n";' "$1"; }
dbx() { php -r '$p=new PDO("sqlite:'$GAME'/data/game.sqlite"); $p->exec($argv[1]);' "$1"; }

join_player() {   # name village_id : register + full welcome flow
  CK=/tmp/reset-ck-$1; rm -f "$CK"
  get register.php >/dev/null
  post register.php -d username=$1 -d email=$1@b.local -d password=TestPass123! -d password2=TestPass123! -d rules=1 -d age=1 >/dev/null
  get welcome.php >/dev/null
  post welcome.php -d do=gnome -d "gnome_name=Gnome $1" -d 'hat=#2e7d4f' -d 'beard=#b5651d' >/dev/null
  get 'welcome.php?step=place' >/dev/null
  post welcome.php -d do=place -d village_id=$2 >/dev/null
  get 'welcome.php?step=garden' >/dev/null
  post welcome.php -d do=finish -d "garden_name=$1 Patch" >/dev/null
}

echo "== install"
CK=/tmp/reset-ck-admin; rm -f "$CK"
get install.php >/dev/null
post install.php -d driver=sqlite -d "site_name=Gnome Venture" -d base_url= -d admin_user=admin -d admin_email=a@b.local -d admin_pass=TestPassword123 -d admin_pass2=TestPassword123 >/dev/null
grep -q 'All planted' /tmp/reset-post.html && echo "installed" || { echo "INSTALL FAILED"; exit 1; }
RID=$(db "SELECT id FROM regions WHERE code='NA'")
VID=$(db "SELECT l.id FROM locations l WHERE l.region_id=$RID AND l.kind='village' AND EXISTS (SELECT 1 FROM routes r WHERE r.kind='road' AND (r.a_id=l.id OR r.b_id=l.id)) ORDER BY l.sort_order LIMIT 1 OFFSET 1")

echo "== three players: sprout (will be reset), ctrl (same start, never touched), other (bystander with dealings)"
join_player sprout $VID; join_player ctrl $VID; join_player other $VID
SID=$(db "SELECT id FROM users WHERE username='sprout'"); OID=$(db "SELECT id FROM users WHERE username='other'"); AID=$(db "SELECT id FROM users WHERE username='admin'")
CTRL_ITEMS=$(db "SELECT i.slug||':'||ui.qty FROM user_items ui JOIN items i ON i.id=ui.item_id WHERE ui.user_id=(SELECT id FROM users WHERE username='ctrl') ORDER BY i.slug")
CTRL_PLOTS=$(db "SELECT COUNT(*) FROM plots WHERE user_id=(SELECT id FROM users WHERE username='ctrl')")

echo "== play a bit: sprout levels up, earns, builds, takes a calling, deals with 'other'"
CAP=$(db "SELECT id FROM items WHERE slug='radish-seed'")
dbx "UPDATE users SET level=9, xp=1234, coins=7777, energy=3, stat_grit=22, stat_points=0, calling='bloomcaller', calling_qt=2, calling_tier_seen=2, calling_free_change=0, calling_changes=2,
     title='Green Thumb', tour_step=0, buff='grit:+3', buff_until='2999-01-01 00:00:00', dest_id=$VID, dest_legs=3, dest_trail='1,2', ribbons=4, rps_wins=5, lore_read=3, community_rep=9, last_cooked_id=$CAP, sapling_count=2 WHERE id=$SID"
dbx "INSERT INTO plots (user_id,region_id,village_id,width,height,garden_name,created_at,garden_xp,garden_level,yard_xw,appeal,admired) VALUES ($SID,$RID,$VID,8,8,'Second Plot',datetime('now'),500,4,2,30,3)"
P2=$(db "SELECT MAX(id) FROM plots"); P1=$(db "SELECT MIN(id) FROM plots WHERE user_id=$SID")
dbx "INSERT INTO plot_tiles (plot_id,user_id,x,y,tilled) VALUES ($P2,$SID,0,0,1),($P2,$SID,1,0,1);
     INSERT INTO garden_buildings (plot_id,building,built_at) VALUES ($P1,'tool_shed',datetime('now')),($P2,'rain_barrel',datetime('now'));
     INSERT INTO garden_objects (plot_id,kind,ref,x,y,placed_at) VALUES ($P1,'fence','oak',1,1,datetime('now'));
     INSERT INTO yard_history (plot_id,snap,created_at) VALUES ($P1,'{}',datetime('now'));
     INSERT INTO garden_hires (plot_id,user_id,helper_id,started_at,ends_at,last_visit,paid) VALUES ($P1,$SID,1,datetime('now'),datetime('now','+1 day'),datetime('now'),50);
     INSERT INTO user_items (user_id,item_id,qty) VALUES ($SID,(SELECT id FROM items WHERE slug='carrot-seed'),99) ON CONFLICT DO NOTHING;
     UPDATE user_items SET qty=500 WHERE user_id=$SID AND item_id=$CAP;
     INSERT INTO user_plant_knowledge VALUES ($SID,(SELECT id FROM plants LIMIT 1),77);
     INSERT INTO user_milestones SELECT $SID,id,datetime('now') FROM almanac_milestones LIMIT 1;
     INSERT INTO user_quests (user_id,chapter_id,stage,started_at) SELECT $SID,id,1,datetime('now') FROM quest_chapters LIMIT 1;
     INSERT INTO xp_log VALUES ('2026-01-01',$SID,'garden',50);
     INSERT INTO game_scores (user_id,game,score,day,week,played_at) VALUES ($SID,'x',9,'2026-01-01','2026-01',datetime('now'));
     INSERT INTO region_visits (user_id,region_id,first_at) SELECT $SID,id,datetime('now') FROM regions LIMIT 3;
     INSERT INTO user_calling_chapters (user_id,chapter_id,started_at) SELECT $SID,id,datetime('now') FROM calling_chapters LIMIT 1;
     INSERT INTO npc_friends (user_id,npc_id,points) SELECT $SID,id,40 FROM npcs LIMIT 1;
     INSERT INTO cook_pots (user_id,recipe_id,started_at,ready_at) SELECT $SID,id,datetime('now'),datetime('now') FROM recipes LIMIT 1;
     INSERT INTO stall_listings (seller_id,item_id,qty,price,listed_at) VALUES ($SID,$CAP,5,10,datetime('now'));
     INSERT INTO gotm_entries (month,plot_id,user_id,votes,appeal,entered_at) VALUES ('2026-10',$P1,$SID,2,10,datetime('now'));
     INSERT INTO gotm_entries (month,plot_id,user_id,votes,appeal,entered_at) VALUES ('2026-10',(SELECT MIN(id) FROM plots WHERE user_id=$OID),$OID,5,10,datetime('now'));
     INSERT INTO gotm_votes (month,entry_id,user_id,voted_at) VALUES ('2026-10',(SELECT MAX(id) FROM gotm_entries),$SID,datetime('now'));
     INSERT INTO garden_admires (plot_id,user_id,day,admired_at) VALUES ((SELECT MIN(id) FROM plots WHERE user_id=$OID),$SID,'once',datetime('now'));
     UPDATE plots SET admired=4 WHERE user_id=$OID;
     INSERT INTO feedback (user_id,body,created_at) VALUES ($SID,'keep me',datetime('now'));
     INSERT INTO reports (reporter_id,target_id,kind,reason,created_at) VALUES ($SID,$OID,'player','keep me',datetime('now'));
     INSERT INTO news (title,body,author_id,created_at) VALUES ('Mine','b',$SID,datetime('now'));
     INSERT INTO trade_offers (from_id,to_id,give_items,give_coins,want_items,want_coins,status,created_at) VALUES ($SID,$OID,'{}',100,'{}',0,'open',datetime('now'));
     INSERT INTO trade_offers (from_id,to_id,give_items,give_coins,want_items,want_coins,status,created_at) VALUES ($OID,$SID,'{\"$CAP\":3}',250,'{}',0,'open',datetime('now'));
     INSERT INTO player_jobs (poster_id,kind,qty,wage,escrow,status,posted_at,expires_at) VALUES ($SID,'deliver',1,100,100,'open',datetime('now'),datetime('now','+1 day'));"
dbx "UPDATE users SET banned=0, muted_until='2999-01-01 00:00:00' WHERE id=$SID"
O_ITEM0=$(db "SELECT COALESCE(qty,0) FROM user_items WHERE user_id=$OID AND item_id=$CAP"); O_COINS0=$(db "SELECT coins FROM users WHERE id=$OID")
O_SNAP=$(db "SELECT id,level,xp,coins,gnome_name,onboarded FROM users WHERE id IN ($OID,$AID) ORDER BY id")
O_PLOTS=$(db "SELECT COUNT(*) FROM plots WHERE user_id=$OID"); O_TILES=$(db "SELECT COUNT(*) FROM plot_tiles WHERE user_id=$OID")
SPW=$(db "SELECT password_hash||role||email||created_at FROM users WHERE id=$SID")
check "sprout is built up (2 plots)" "$(db "SELECT COUNT(*) FROM plots WHERE user_id=$SID")" "2"

echo "== not for players: sprout cannot reach it"
CK=/tmp/reset-ck-sprout; rm -f "$CK"; get login.php >/dev/null; post login.php -d username=sprout -d password=TestPass123! >/dev/null
check "player GET crud -> 403" "$(get 'admin/crud.php?r=users&action=edit&id='$SID | cut -d' ' -f1)" "403"
get garden.php >/dev/null; post admin/crud.php?r=users -d do=fresh_start -d id=$SID -d confirm_name=sprout >/dev/null
check "player POST fresh_start -> still level 9" "$(db "SELECT level FROM users WHERE id=$SID")" "9"
check "no form on the player's own pages" "$(grep -c 'fresh_start' $H)" "0"

echo "== admin: form is there; no CSRF / wrong name do nothing"
CK=/tmp/reset-ck-admin; rm -f "$CK"; get login.php >/dev/null; post login.php -d username=admin -d password=TestPassword123 >/dev/null
get "admin/crud.php?r=users&action=edit&id=$SID" >/dev/null
check "fresh-start form shown" "$(grep -c 'name="do" value="fresh_start"' $H)" "1"
check "typed-confirm field + data-confirm" "$(grep -c 'name="confirm_name"' $H)/$(grep -c 'data-confirm="Wipe ALL' $H)" "1/1"
curl -s -c "$CK" -b "$CK" -X POST "$BASE/admin/crud.php?r=users" -d do=fresh_start -d id=$SID -d confirm_name=sprout -o /dev/null -w '%{http_code}\n' >/dev/null
check "POST without csrf -> still level 9" "$(db "SELECT level FROM users WHERE id=$SID")" "9"
post "admin/crud.php?r=users" -d do=fresh_start -d id=$SID -d confirm_name=Sprout >/dev/null
check "wrong name (case) -> still level 9" "$(db "SELECT level FROM users WHERE id=$SID")" "9"
check "no admin_log yet" "$(db "SELECT COUNT(*) FROM admin_log WHERE action='fresh_start'")" "0"

echo "== admin presses Fresh start"
get "admin/crud.php?r=users&action=edit&id=$SID" >/dev/null
echo "post: $(post 'admin/crud.php?r=users' -d do=fresh_start -d id=$SID -d confirm_name=sprout)"
get "admin/crud.php?r=users&action=edit&id=$SID" >/dev/null; grep -oE 'class="flash (ok|err)">[^<]*' $H
check "admin_log entry" "$(db "SELECT COUNT(*) FROM admin_log WHERE action='fresh_start' AND target='users#$SID' AND user_id=$AID")" "1"
echo "log: $(db "SELECT details FROM admin_log WHERE action='fresh_start'" | cut -c1-160)"

echo "== guard: every users column is either kept or reset (a future column must be decided)"
UNDECIDED=$(php -r 'require "'$GAME'/includes/fresh_start.php"; function setting($k){return "1";} $p=new PDO("sqlite:'$GAME'/data/game.sqlite"); $known=array_merge(FRESH_KEEP_COLS,array_keys(fresh_start_columns())); foreach($p->query("PRAGMA table_info(users)") as $c) if(!in_array($c["name"],$known,true)) echo $c["name"]," ";')
check "no undecided users columns" "$UNDECIDED" ""
echo "== sprout is brand new"
fresh="$(db "SELECT level,xp,coins,energy,stat_grit,stat_points,COALESCE(calling,'-'),calling_qt,calling_tier_seen,calling_free_change,calling_changes,COALESCE(title,'-'),COALESCE(gnome_name,'-'),onboarded,tour_step,COALESCE(buff,'-'),COALESCE(dest_id,'-'),dest_legs,COALESCE(dest_trail,'-'),ribbons,rps_wins,lore_read,community_rep,COALESCE(location_id,'-'),COALESCE(home_village_id,'-'),COALESCE(active_plot_id,'-'),COALESCE(region_id,'-'),sapling_count FROM users WHERE id=$SID")"
MAXE=$(db "SELECT value FROM settings WHERE name='max_energy'"); SC=$(db "SELECT value FROM settings WHERE name='starting_coins'")
check "user columns" "$fresh" "1 | 0 | ${SC:-500} | ${MAXE:-10} | 10 | 4 | - | 0 | 0 | 1 | 0 | - | - | 0 | 0 | - | - | 0 | - | 0 | 0 | 0 | 0 | - | - | - | - | 0"
check "identity untouched (hash+role+email+created_at)" "$(db "SELECT password_hash||role||email||created_at FROM users WHERE id=$SID")" "$SPW"
check "moderation state kept (muted)" "$(db "SELECT muted_until FROM users WHERE id=$SID")" "2999-01-01 00:00:00"
check "0 plots / tiles / buildings / objects / hires / yard" "$(db "SELECT (SELECT COUNT(*) FROM plots WHERE user_id=$SID)||'/'||(SELECT COUNT(*) FROM plot_tiles WHERE plot_id IN ($P1,$P2))||'/'||(SELECT COUNT(*) FROM garden_buildings WHERE plot_id IN ($P1,$P2))||'/'||(SELECT COUNT(*) FROM garden_objects WHERE plot_id IN ($P1,$P2))||'/'||(SELECT COUNT(*) FROM garden_hires WHERE plot_id IN ($P1,$P2))||'/'||(SELECT COUNT(*) FROM yard_history WHERE plot_id IN ($P1,$P2))")" "0/0/0/0/0/0"
for T in user_items user_recipes user_encyclopedia user_milestones user_plant_knowledge user_guides user_quests user_jobs user_calling_chapters user_calling_tasks user_food_bonus user_tasted user_npc_met npc_friends npc_favours expeditions region_visits landmark_clears xp_log game_scores cook_pots cellar_plants stall_listings gotm_entries gotm_votes notices; do
  COL=user_id; [ $T = stall_listings ] && COL=seller_id
  N=$(db "SELECT COUNT(*) FROM $T WHERE $COL=$SID"); [ "$N" = 0 ] || { echo "FAIL $T still has $N"; FAILS=$((FAILS+1)); }
done; echo "ok   per-user progress tables empty (checked 26)"
check "feedback/report/news kept" "$(db "SELECT (SELECT COUNT(*) FROM feedback WHERE user_id=$SID)||(SELECT COUNT(*) FROM reports WHERE reporter_id=$SID)||(SELECT COUNT(*) FROM news WHERE author_id=$SID)")" "111"
check "own open offer cancelled" "$(db "SELECT status FROM trade_offers WHERE from_id=$SID")" "cancelled"
check "other's offer to sprout cancelled" "$(db "SELECT status FROM trade_offers WHERE to_id=$SID")" "cancelled"
check "other got items + 250 coins back" "$(db "SELECT ((SELECT qty FROM user_items WHERE user_id=$OID AND item_id=$CAP)-$O_ITEM0)||'/'||((SELECT coins FROM users WHERE id=$OID)-$O_COINS0)")" "3/250"
check "sprout's posted job gone" "$(db "SELECT COUNT(*) FROM player_jobs WHERE poster_id=$SID")" "0"
check "other's plots/tiles untouched" "$(db "SELECT (SELECT COUNT(*) FROM plots WHERE user_id=$OID)||'/'||(SELECT COUNT(*) FROM plot_tiles WHERE user_id=$OID)")" "$O_PLOTS/$O_TILES"
check "other's gotm entry lost sprout's vote (5->4), garden admire 4->3" "$(db "SELECT (SELECT votes FROM gotm_entries WHERE user_id=$OID)||'/'||(SELECT admired FROM plots WHERE user_id=$OID)")" "4/3"
check "admin + other rows untouched" "$(db "SELECT id,level,xp,coins,gnome_name,onboarded FROM users WHERE id IN ($OID,$AID) ORDER BY id" | sed "s/ | $((O_COINS0))/ | $((O_COINS0))/")" "$(echo "$O_SNAP" | sed -E "s/^($OID \| [0-9]+ \| [0-9]+ \| )[0-9]+/\1$((O_COINS0+250))/")"
check "admin still admin" "$(db "SELECT role FROM users WHERE id=$AID")" "admin"
check "ctrl player untouched" "$(db "SELECT COUNT(*) FROM plots WHERE user_id=(SELECT id FROM users WHERE username='ctrl')")" "$CTRL_PLOTS"

echo "== sprout logs in and replays the welcome flow"
CK=/tmp/reset-ck-sprout; rm -f "$CK"; get login.php >/dev/null; post login.php -d username=sprout -d password=TestPass123! >/dev/null
RED=$(get world.php); echo "world.php -> $RED"; case "$RED" in *welcome.php*) echo "ok   sent to welcome flow";; *) echo "FAIL not sent to welcome"; FAILS=$((FAILS+1));; esac
get welcome.php >/dev/null; check "welcome page shows (step 1)" "$(grep -c 'class="box form gnomemaker"' $H)" "1"
post welcome.php -d do=gnome -d "gnome_name=Sprout Again" -d 'hat=#2e7d4f' -d 'beard=#b5651d' >/dev/null
get 'welcome.php?step=place' >/dev/null; post welcome.php -d do=place -d village_id=$VID >/dev/null
get 'welcome.php?step=garden' >/dev/null; post welcome.php -d do=finish -d 'garden_name=Fresh Patch' >/dev/null
check "onboarded again" "$(db "SELECT onboarded FROM users WHERE id=$SID")" "1"
check "exactly 1 plot, 4x4 starter size" "$(db "SELECT COUNT(*)||' '||MIN(width)||'x'||MIN(height) FROM plots WHERE user_id=$SID")" "1 4x4"
check "16 tiles, level 1, xp 0" "$(db "SELECT (SELECT COUNT(*) FROM plot_tiles WHERE user_id=$SID)||' '||level||' '||xp FROM users WHERE id=$SID")" "16 1 0"
check "satchel == a brand-new player's (starter + seeds + village pack)" "$(db "SELECT i.slug||':'||ui.qty FROM user_items ui JOIN items i ON i.id=ui.item_id WHERE ui.user_id=$SID ORDER BY i.slug")" "$CTRL_ITEMS"
check "garden page loads" "$(get garden.php | cut -d' ' -f1)" "200"

echo "== php errors"
if grep -iE 'fatal|warning|notice|deprecated' $LOG 2>/dev/null; then FAILS=$((FAILS+1)); echo "FAIL php messages above"; else echo "ok   (none)"; fi
echo "== RESULT: $FAILS failure(s)"; [ $FAILS = 0 ]
