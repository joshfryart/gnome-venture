GAME=$1; PORT=$2; ROUTER=$3; BASE=http://127.0.0.1:$PORT
php -d session.save_path=/tmp -S 127.0.0.1:$PORT -t $GAME $ROUTER >/tmp/pj-php.log 2>&1 & PID=$!; sleep 1
trap "kill $PID 2>/dev/null" EXIT
csrf() { grep -o 'name="csrf" value="[^"]*"' "$1" | head -1 | sed 's/.*value="\([^"]*\)".*/\1/'; }
db() { php -r '$p=new PDO("sqlite:'$GAME'/data/game.sqlite"); foreach($p->query($argv[1])->fetchAll(PDO::FETCH_NUM) as $r) echo implode(" | ",$r),"\n";' "$1"; }
dbx() { php -r '$p=new PDO("sqlite:'$GAME'/data/game.sqlite"); $p->exec($argv[1]);' "$1"; }
login() { rm -f $1; curl -s -c $1 -b $1 $BASE/login.php > /tmp/p.html; curl -s -c $1 -b $1 -X POST $BASE/login.php --data-urlencode "csrf=$(csrf /tmp/p.html)" -d username=$2 -d "password=$3" -o /dev/null; }
# post as cookie $1 to page $2
post() { local c=$1 pg=$2; shift 2; curl -s -c $c -b $c "$BASE/$pg" > /tmp/p0.html; curl -s -c $c -b $c -X POST "$BASE/$pg" --data-urlencode "csrf=$(csrf /tmp/p0.html)" "$@" -o /dev/null; curl -s -c $c -b $c "$BASE/jobs.php" > /tmp/p.html; grep -oE 'flash (ok|err)">[^<]*' /tmp/p.html | head -4; }
tpost() { local c=$1; shift; curl -s -c $c -b $c "$BASE/tend.php" > /tmp/p0.html; curl -s -c $c -b $c -X POST "$BASE/tend.php" --data-urlencode "csrf=$(csrf /tmp/p0.html)" "$@" -o /dev/null; curl -s -c $c -b $c "$BASE/jobs.php" > /tmp/p.html; grep -oE 'flash (ok|err)">[^<]*' /tmp/p.html | head -4; }
SP=$(db "SELECT id FROM users WHERE username='sprout'"); AD=$(db "SELECT id FROM users WHERE username='admin'")
P=$(db "SELECT id FROM plots WHERE user_id=$SP LIMIT 1")
CAN=$(db "SELECT id FROM items WHERE slug='tin-watering-can'")
dbx "UPDATE users SET onboarded=1, gnome_name='Taker Tom', level=1, coins=500, energy=100 WHERE id=$AD"
dbx "INSERT OR REPLACE INTO user_items (user_id,item_id,qty) VALUES ($AD,$CAN,1)"
dbx "UPDATE users SET level=1, coins=1000 WHERE id=$SP"
dbx "INSERT OR REPLACE INTO settings (name,value) VALUES ('fresh_hold_days','0')"   # brand-new test accounts (fresh_hold.sh tests the hold itself)
A=/tmp/pa-ck; T=/tmp/pt-ck; login $A sprout 'TestPass123!'; login $T admin TestPassword123
echo "== level gate"; post $A jobs.php -d do=post -d kind=tend -d plot_id=$P -d days=1 -d wage=120
dbx "UPDATE users SET level=3 WHERE id IN ($SP,$AD)"
RADP=$(db "SELECT produce_item_id FROM plants WHERE slug='radish'")
echo "== posting"; post $A jobs.php -d do=post -d kind=tend -d plot_id=$P -d days=1 -d wage=10
post $A jobs.php -d do=post -d kind=tend -d plot_id=$P -d days=1 -d wage=120 -d 'note=Please <b>water</b> the radishes'
post $A jobs.php -d do=post -d kind=deliver -d item_id=$RADP -d qty=3 -d size=weekly -d wage=60
post $A jobs.php -d do=post -d kind=deliver -d item_id=$RADP -d qty=3 -d size=daily -d wage=60
db "SELECT 'poster coins '||coins FROM users WHERE id=$SP"; db "SELECT id||' '||kind||' '||status||' escrow '||escrow FROM player_jobs"
TEND=$(db "SELECT id FROM player_jobs WHERE kind='tend'"); DEL=$(db "SELECT id FROM player_jobs WHERE kind='deliver'")
echo "-- own job refused"; post $A jobs.php -d do=take_player -d id=$TEND
echo "== taker sees board"; curl -s -b $T $BASE/jobs.php > /tmp/p.html; echo "posted-by-others cards: $(grep -c 'class="job pjob"' /tmp/p.html)  note escaped: $(grep -c '&lt;b&gt;water' /tmp/p.html)"
post $T jobs.php -d do=take_player -d id=$TEND
echo "== set up sprout garden: thirsty radish 1,2, ready radish 2,2, weedy bed 3,2"
RAD=$(db "SELECT id FROM plants WHERE slug='radish'")
dbx "UPDATE plot_tiles SET tilled=1, method='till', plant_id=$RAD, planted_at=datetime('now','-1 hour'), growth_seconds=60, growth_updated_at=datetime('now'), last_watered=NULL WHERE plot_id=$P AND x=1 AND y=2"
dbx "UPDATE plot_tiles SET tilled=1, method='till', plant_id=$RAD, planted_at=datetime('now','-9 hour'), growth_seconds=999999, growth_updated_at=datetime('now') WHERE plot_id=$P AND x=2 AND y=2"
dbx "UPDATE plot_tiles SET tilled=1, method='notill', weeds=40, maint_at=datetime('now'), plant_id=NULL WHERE plot_id=$P AND x=3 AND y=2"
curl -s -b $T $BASE/tend.php > /tmp/p.html; echo "tend rows: $(grep -c '<tr><td>' /tmp/p.html)"; grep -oE '(💧 Water|🌿 Weed|🧺 Harvest) ⚡[0-9]' /tmp/p.html | tr '\n' ' '; echo
B=$(db "SELECT COALESCE((SELECT qty FROM user_items WHERE user_id=$SP AND item_id=$RADP),0)")
tpost $T -d do=water_all; tpost $T -d do=harvest_all; tpost $T -d do=weed_all
echo "-- not allowed action"; tpost $T -d do=till -d x=1 -d y=2
db "SELECT 'tend job: progress '||progress||'/'||qty||' paid '||paid||' escrow '||escrow||' '||status FROM player_jobs WHERE id=$TEND"
echo "owner radish $B -> $(db "SELECT qty FROM user_items WHERE user_id=$SP AND item_id=$RADP")  taker radish: $(db "SELECT COALESCE((SELECT qty FROM user_items WHERE user_id=$AD AND item_id=$RADP),0)")  taker coins $(db "SELECT coins FROM users WHERE id=$AD")"
echo "== deadline passes"; dbx "UPDATE player_jobs SET ends_at=datetime('now','-1 minute') WHERE id=$TEND"; curl -s -b $T $BASE/jobs.php -o /dev/null
db "SELECT 'tend job '||status||' escrow '||escrow FROM player_jobs WHERE id=$TEND"; db "SELECT 'taker card '||status FROM user_jobs WHERE player_job_id=$TEND"; db "SELECT 'poster coins '||coins FROM users WHERE id=$SP"
echo "== deliver job (weekly)"; post $T jobs.php -d do=take_player -d id=$DEL
dbx "UPDATE player_jobs SET taken_at=datetime('now','-8 days') WHERE id=$TEND"; post $T jobs.php -d do=take_player -d id=$DEL
dbx "INSERT OR REPLACE INTO user_items (user_id,item_id,qty) VALUES ($AD,$RADP,5)"
post $T jobs.php -d period=weekly -d do=deliver
db "SELECT 'deliver job '||status||' paid '||paid FROM player_jobs WHERE id=$DEL"; echo "owner radish now $(db "SELECT qty FROM user_items WHERE user_id=$SP AND item_id=$RADP"), taker coins $(db "SELECT coins FROM users WHERE id=$AD")"
echo "== cancel an open job"; post $A jobs.php -d do=post -d kind=tend -d plot_id=$P -d days=3 -d wage=200; C0=$(db "SELECT coins FROM users WHERE id=$SP"); NEW=$(db "SELECT MAX(id) FROM player_jobs")
post $A jobs.php -d do=cancel -d id=$NEW; echo "poster coins $C0 -> $(db "SELECT coins FROM users WHERE id=$SP")"
echo "-- taker can't cancel poster's job"; post $T jobs.php -d do=cancel -d id=$DEL
echo "== php errors"; grep -iE 'fatal|warning|notice|deprecated' /tmp/pj-php.log || echo "(none)"
