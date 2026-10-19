GAME=$1; PORT=$2; ROUTER=$3; BASE=http://127.0.0.1:$PORT
php -d session.save_path=/tmp -S 127.0.0.1:$PORT -t $GAME $ROUTER >/tmp/jobs-php.log 2>&1 & PID=$!; sleep 1
trap "kill $PID 2>/dev/null" EXIT
C=/tmp/jobs-ck; rm -f $C
csrf() { grep -o 'name="csrf" value="[^"]*"' "$1" | head -1 | sed 's/.*value="\([^"]*\)".*/\1/'; }
db() { php -r '$p=new PDO("sqlite:'$GAME'/data/game.sqlite"); foreach($p->query($argv[1])->fetchAll(PDO::FETCH_NUM) as $r) echo implode(" | ",$r),"\n";' "$1"; }
dbx() { php -r '$p=new PDO("sqlite:'$GAME'/data/game.sqlite"); $p->exec($argv[1]);' "$1"; }
board() { curl -s -c $C -b $C "$BASE/jobs.php" > /tmp/j.html; grep -oE 'flash (ok|err)">[^<]*' /tmp/j.html | head -6; }
jp() { curl -s -c $C -b $C "$BASE/jobs.php" > /tmp/j0.html; curl -s -c $C -b $C -X POST "$BASE/jobs.php" --data-urlencode "csrf=$(csrf /tmp/j0.html)" "$@" -o /dev/null; board; }
act() { curl -s -c $C -b $C "$BASE/garden.php?sel=$2-$3" > /tmp/g.html; curl -s -c $C -b $C -X POST "$BASE/garden.php" --data-urlencode "csrf=$(csrf /tmp/g.html)" -d do=$1 -d x=$2 -d y=$3 -d reach=one ${4:+-d item_id=$4} -o /dev/null; curl -s -c $C -b $C "$BASE/garden.php" | grep -oE 'flash (ok|err)">[^<]*' | head -6; }
curl -s -c $C -b $C $BASE/login.php > /tmp/j.html; curl -s -c $C -b $C -X POST $BASE/login.php --data-urlencode "csrf=$(csrf /tmp/j.html)" -d username=sprout -d 'password=TestPass123!' -o /dev/null
UID_=$(db "SELECT id FROM users WHERE username='sprout'")
echo "== templates"; db "SELECT period, COUNT(*) FROM job_templates GROUP BY period"
board; echo "offers shown: $(grep -c 'Take this job' /tmp/j.html)  resets: $(grep -oE 'resets in [^<]*' /tmp/j.html | tr '\n' ';')"
grep -oE '<h3>[^<]*</h3>' /tmp/j.html | head -13 | tr '\n' ' '; echo
echo "== reroll daily"; B1=$(grep -oE '<h3>[^<]*</h3>' /tmp/j.html | head -5 | tr -d '\n'); jp -d period=daily -d do=reroll; B2=$(grep -oE '<h3>[^<]*</h3>' /tmp/j.html | head -5 | tr -d '\n'); [ "$B1" != "$B2" ] && echo "offers changed" || echo "SAME offers"; jp -d period=daily -d do=reroll
echo "-- monthly reroll refused"; jp -d period=monthly -d do=reroll
echo "== take daily #0 then turn it into water x2"; jp -d period=daily -d do=take -d i=0; jp -d period=daily -d do=take -d i=1
dbx "UPDATE user_jobs SET kind='water', qty=2, progress=0, title='Thirsty weather', reward_coins=50, reward_xp=20, reward_item_id=NULL WHERE user_id=$UID_ AND period='daily'"
dbx "UPDATE users SET energy=100, job_dailies=6 WHERE id=$UID_"; C0=$(db "SELECT coins FROM users WHERE id=$UID_")
RAD=$(db "SELECT id FROM items WHERE slug='radish-seed'"); dbx "INSERT OR REPLACE INTO user_items (user_id,item_id,qty) VALUES ($UID_,$RAD,9)"
act till 1 1; act plant 1 1 $RAD; act water 1 1; act till 2 1; act plant 2 1 $RAD; act water 2 1
db "SELECT 'daily: '||progress||'/'||qty||' '||status FROM user_jobs WHERE user_id=$UID_ AND period='daily'"; echo "coins $C0 -> $(db "SELECT coins FROM users WHERE id=$UID_") dailies=$(db "SELECT job_dailies FROM users WHERE id=$UID_")"
echo "-- second daily refused"; jp -d period=daily -d do=take -d i=2
echo "== weekly deliver radish x3"; jp -d period=weekly -d do=take -d i=0
RADP=$(db "SELECT produce_item_id FROM plants WHERE slug='radish'")
dbx "UPDATE user_jobs SET kind='deliver_crop', target='radish', target_item_id=$RADP, target_name='Radish', qty=3, progress=0 WHERE user_id=$UID_ AND period='weekly'"
dbx "INSERT OR REPLACE INTO user_items (user_id,item_id,qty) VALUES ($UID_,$RADP,2)"
jp -d period=weekly -d do=deliver; db "SELECT 'weekly: '||progress||'/'||qty||' '||status FROM user_jobs WHERE user_id=$UID_ AND period='weekly'"
dbx "INSERT OR REPLACE INTO user_items (user_id,item_id,qty) VALUES ($UID_,$RADP,5)"; jp -d period=weekly -d do=deliver
db "SELECT 'weekly: '||progress||'/'||qty||' '||status FROM user_jobs WHERE user_id=$UID_ AND period='weekly'"; db "SELECT 'radish left '||qty FROM user_items WHERE user_id=$UID_ AND item_id=$RADP"
echo "== monthly staged harvest radish x4, 4 stages"; jp -d period=monthly -d do=take -d i=0
dbx "UPDATE user_jobs SET kind='harvest_crop', target='radish', qty=4, stages=4, progress=0, reward_coins=4000 WHERE user_id=$UID_ AND period='monthly'"
C1=$(db "SELECT coins FROM users WHERE id=$UID_")
dbx "UPDATE plot_tiles SET growth_seconds=999999 WHERE user_id=$UID_ AND plant_id IS NOT NULL"
act harvest 1 1; act harvest 2 1
db "SELECT 'monthly: '||progress||'/'||qty||' paid stages '||stages_paid||' '||status FROM user_jobs WHERE user_id=$UID_ AND period='monthly'"; echo "coins $C1 -> $(db "SELECT coins FROM users WHERE id=$UID_")"
echo "== expiry + abandon"; dbx "UPDATE user_jobs SET period_key='2000-01-01' WHERE user_id=$UID_ AND period='daily'"
board; db "SELECT 'old daily status: '||status FROM user_jobs WHERE user_id=$UID_ AND period='daily'"; echo "daily offers back: $(grep -c 'Take this job' /tmp/j.html)"
jp -d period=daily -d do=take -d i=0; jp -d period=daily -d do=abandon; db "SELECT GROUP_CONCAT(status) FROM user_jobs WHERE user_id=$UID_ AND period='daily'"
echo "== bad csrf / bad period"; curl -s -b $C -X POST "$BASE/jobs.php" -d csrf=x -d period=daily -d do=take -o /dev/null -w '%{http_code}\n'
echo "== php errors"; grep -iE 'fatal|warning|notice|deprecated' /tmp/jobs-php.log || echo "(none)"
