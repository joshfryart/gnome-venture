#!/bin/bash
GAME=$1; PORT=$2; ROUTER=$3; BASE=http://127.0.0.1:$PORT
php -d session.save_path=/tmp -S 127.0.0.1:$PORT -t $GAME $ROUTER >/tmp/yard-php.log 2>&1 & PID=$!; sleep 1
trap "kill $PID 2>/dev/null" EXIT
csrf() { grep -o 'name="csrf" value="[^"]*"' "$1" | head -1 | sed 's/.*value="\([^"]*\)".*/\1/'; }
db() { php -r '$p=new PDO("sqlite:'$GAME'/data/game.sqlite"); foreach($p->query($argv[1])->fetchAll(PDO::FETCH_NUM) as $r) echo implode(" | ",$r),"\n";' "$1"; }
dbx() { php -r '$p=new PDO("sqlite:'$GAME'/data/game.sqlite"); $p->exec($argv[1]);' "$1"; }
login() { rm -f $1; curl -s -c $1 -b $1 $BASE/login.php > /tmp/y.html; curl -s -c $1 -b $1 -X POST $BASE/login.php --data-urlencode "csrf=$(csrf /tmp/y.html)" -d username=$2 -d "password=$3" -o /dev/null -w "%{redirect_url}"; }
flash() { curl -s -b $1 "$BASE/$2" | grep -oE 'flash (ok|err)">[^<]*' | head -3 | tr '\n' ' '; echo; }
# a second player
dbx "DELETE FROM users WHERE username='bloom'"
php -r '$p=new PDO("sqlite:'$GAME'/data/game.sqlite"); $r=$p->query("SELECT * FROM users WHERE username=\"sprout\"")->fetch(PDO::FETCH_ASSOC); unset($r["id"]); $r["username"]="bloom"; $r["email"]="bloom@b.local"; $r["gnome_name"]="Bloom Thistledown"; $c=array_keys($r); $p->prepare("INSERT INTO users (".implode(",",$c).") VALUES (".implode(",",array_fill(0,count($c),"?")).")")->execute(array_values($r));'
dbx "UPDATE users SET onboarded=1, level=5, coins=5000, created_at=datetime('now','-5 days') WHERE username IN ('sprout','bloom')"
A=/tmp/y-a; B=/tmp/y-b; ADM=/tmp/y-adm; login $A sprout 'TestPass123!' >/dev/null; login $B bloom 'TestPass123!' >/dev/null; login $ADM admin TestPassword123 >/dev/null
SID=$(db "SELECT id FROM users WHERE username='sprout'"); BID=$(db "SELECT id FROM users WHERE username='bloom'")
PL=$(db "SELECT id FROM plots WHERE user_id=$SID ORDER BY id LIMIT 1")
item() { db "SELECT id FROM items WHERE slug='$1'"; }
give() { dbx "INSERT INTO user_items (user_id,item_id,qty) VALUES ($SID,$(item $1),$2)"; }
for s in birdbath:2 stone-path:5 box-hedge:2 garden-bench:1 garden-oak:1 picket-fence:3; do give ${s%%:*} ${s##*:}; done
dbx "INSERT INTO garden_buildings (plot_id,building,built_at,last_collect) VALUES ($PL,'rain_barrel',datetime('now'),datetime('now')),($PL,'beehive',datetime('now'),datetime('now'))"
echo "== garden page draws the yard"
curl -s -b $A $BASE/garden.php > /tmp/y.html
echo "  yard: $(grep -oE 'class="yard yc[0-9]+ yr[0-9]+' /tmp/y.html) · bed links: $(grep -oE 'class="tile [^"]*gx[0-9]+' /tmp/y.html | wc -l) · buildings: $(grep -oE 'class="yo bld[^"]*' /tmp/y.html | wc -l) · design button: $(grep -c 'yard.php' /tmp/y.html)"
db "SELECT kind, ref, x, y, w, h FROM garden_objects WHERE plot_id=$PL"
dbx "UPDATE garden_objects SET x=0, y=0 WHERE ref='beehive'"; dbx "UPDATE garden_objects SET x=1, y=0 WHERE ref='rain_barrel'"
echo "== designer"
curl -s -b $A -c $A $BASE/yard.php > /tmp/y.html
echo "  pieces: $(grep -o 'data-k="' /tmp/y.html | wc -l) · tray items: $(grep -c 'class="trayitem" data-item' /tmp/y.html) · no inline style: $(grep -c ' style=' /tmp/y.html)"
cur() { db "SELECT group_concat('['||id||','||x||','||y||','||rot||']') FROM garden_objects WHERE plot_id=$PL AND x>=0$1"; }
cur() { db "SELECT group_concat('['||id||','||x||','||y||','||rot||']') FROM garden_objects WHERE plot_id=$PL AND x>=0"; }
save() { curl -s -b $A -c $A $BASE/yard.php > /tmp/y.html; curl -s -b $A -c $A -X POST $BASE/yard.php --data-urlencode "csrf=$(csrf /tmp/y.html)" -d do=save --data-urlencode "layout=$1" -o /dev/null -w '%{redirect_url} '; flash $A garden.php; }
BB=$(item birdbath); SP=$(item stone-path); HE=$(item box-hedge); BE=$(item garden-bench); OAK=$(item garden-oak); FE=$(item picket-fence)
echo -n "  place things: "; save "{\"o\":[$(cur)],\"n\":[[$BB,2,1,0],[$SP,3,6,0],[$SP,4,6,0],[$SP,5,6,0],[$HE,7,3,0],[$BE,0,6,0],[$OAK,8,5,0],[$FE,0,2,90]]}"
db "SELECT o.kind, COALESCE(i.slug,o.ref), x, y, w, h, rot FROM garden_objects o LEFT JOIN items i ON i.id=o.item_id WHERE plot_id=$PL ORDER BY o.id" | tr '\n' ';'; echo
echo "  satchel now: $(db "SELECT group_concat(i.slug||'×'||ui.qty, ' ') FROM user_items ui JOIN items i ON i.id=ui.item_id WHERE ui.user_id=$SID AND i.category='decor'")"
echo "  appeal: $(db "SELECT appeal FROM plots WHERE id=$PL")"
echo -n "  overlap a bed: "; save "{\"o\":[$(cur)],\"n\":[[$BB,3,2,0]]}"
echo -n "  outside: "; save "{\"o\":[$(cur)],\"n\":[[$BB,10,7,0]]}" 
echo -n "  oak sticking out: "; OID=$(db "SELECT id FROM garden_objects WHERE item_id=$OAK"); ALL=$(db "SELECT group_concat('['||id||','||x||','||y||','||rot||']') FROM garden_objects WHERE plot_id=$PL AND id<>$OID"); save "{\"o\":[$ALL,[$OID,9,5,0]]}"
echo -n "  more than owned: "; ALL=$(db "SELECT group_concat('['||id||','||x||','||y||','||rot||']') FROM garden_objects WHERE plot_id=$PL"); save "{\"o\":[$ALL],\"n\":[[$BE,0,7,0]]}"
echo -n "  put away a building: "; NB=$(db "SELECT group_concat('['||id||','||x||','||y||','||rot||']') FROM garden_objects WHERE plot_id=$PL AND kind='decor'"); save "{\"o\":[$NB]}"
echo -n "  someone else's object: "; save "{\"o\":[$ALL,[99999,0,0,0]]}"
echo -n "  rubbish: "; save "not json"
echo -n "  rubbish rows: "; save "{\"o\":[\"x\"]}"
echo -n "  move a planted bed: "; P00=$(db "SELECT plant_id IS NOT NULL FROM plot_tiles WHERE plot_id=$PL AND x=0 AND y=0"); dbx "UPDATE plot_tiles SET plant_id=(SELECT MIN(id) FROM plants), planted_at=datetime('now') WHERE plot_id=$PL AND x=0 AND y=0"; save "{\"o\":[$ALL],\"t\":[[0,0,1,3]]}"
echo -n "  move an empty bed + rotate bench + put away a path: "; BID2=$(db "SELECT id FROM garden_objects WHERE item_id=$BE"); KEEP=$(db "SELECT group_concat('['||id||','||x||','||y||','||rot||']') FROM garden_objects WHERE plot_id=$PL AND id<>$BID2 AND id<>(SELECT MAX(id) FROM garden_objects WHERE item_id=$SP)"); save "{\"o\":[$KEEP,[$BID2,0,4,90]],\"t\":[[3,3,7,4]]}"
db "SELECT x,y,yx,yy FROM plot_tiles WHERE plot_id=$PL AND x=3 AND y=3"; db "SELECT x,y,w,h,rot FROM garden_objects WHERE id=$BID2"; echo "  stone paths in satchel: $(db "SELECT qty FROM user_items WHERE user_id=$SID AND item_id=$SP")"
echo "== bonuses (php)"
php -r 'chdir("'$GAME'"); $_SERVER["HTTP_HOST"]="x"; require "includes/bootstrap.php"; require "includes/garden_logic.php";
 foreach (q("SELECT * FROM plot_tiles WHERE plot_id = '$PL' ORDER BY yy, yx")->fetchAll() as $t) { $b = yard_tile_bonuses($t); echo "(".$t["yx"].",".$t["yy"].")".implode("+", array_keys($b))." "; } echo "\n";
 $t = q_one("SELECT * FROM plot_tiles WHERE plot_id = '$PL' AND yx = 6 AND yy = 3"); $p = q_one("SELECT * FROM plants WHERE slug = ?", ["radish"]);
 $a = annotate_tile($t, $p); echo "hedge tile flags: hedge=", (int)$a["_hedge"], " barrel=", (int)$a["_barrel"], " shade=", (int)$a["_shade"], " path=", (int)$a["_path"], " birds=", (int)$a["_birds"], " hivenear=", (int)$a["_hivenear"], "\n";
 $plain = $a; foreach (["_barrel","_shade","_rain"] as $k) $plain[$k] = false; echo "water secs plain ", water_seconds($plain, $p), " with this square bonuses ", water_seconds($a, $p), "\n";'
echo "== yard row area action uses yard rows"
php -r 'chdir("'$GAME'"); $_SERVER["HTTP_HOST"]="x"; require "includes/bootstrap.php"; require "includes/garden_logic.php"; foreach (q("SELECT x,y,yx,yy FROM plot_tiles WHERE plot_id='$PL' AND yy=(SELECT yy FROM plot_tiles WHERE plot_id='$PL' AND x=0 AND y=1) ORDER BY yx")->fetchAll() as $r) echo $r["x"],",",$r["y"],"@",$r["yx"]," "; echo "\n";'
echo "== visiting"
echo "  bloom visits: $(curl -s -b $B $BASE/visit.php?g=$PL -o /tmp/v.html -w '%{http_code}') · tiles shown: $(grep -oE 'class="tile [^"]*' /tmp/v.html | wc -l) · links into tending: $(grep -c 'garden.php?sel' /tmp/v.html) · soil numbers: $(grep -c 'Fertility' /tmp/v.html) · report links: $(grep -c reportlink /tmp/v.html)"
adm() { curl -s -b $B -c $B $BASE/visit.php?g=$PL > /tmp/y.html; curl -s -b $B -c $B -X POST $BASE/visit.php --data-urlencode "csrf=$(csrf /tmp/y.html)" -d g=$PL -d do=$1 -d entry=$2 -o /dev/null; flash $B visit.php?g=$PL; }
echo -n "  admire: "; adm admire; echo -n "  again: "; adm admire
echo "  sprout notified: $(db "SELECT COUNT(*) FROM notices WHERE user_id=$SID AND text LIKE '%admired%'") · admired count $(db "SELECT admired FROM plots WHERE id=$PL")"
echo "  profile: $(curl -s -b $B $BASE/profile.php?id=$SID -o /tmp/p.html -w '%{http_code}') gardens: $(grep -c 'class="box gardencard"' /tmp/p.html) mini yards: $(grep -c 'yard yc[0-9]* yr[0-9]* mini' /tmp/p.html)"
echo "  bad profile id: $(curl -s -b $B $BASE/profile.php?id=99999 -o /dev/null -w '%{http_code}') · bad garden: $(curl -s -b $B $BASE/visit.php?g=99999 -o /dev/null -w '%{http_code}')"
dbx "UPDATE users SET garden_public=0 WHERE id=$SID"
echo "  private: visit $(curl -s -b $B $BASE/visit.php?g=$PL -o /dev/null -w '%{http_code}') · profile says private: $(curl -s -b $B $BASE/profile.php?id=$SID | grep -c 'keeps their gardens private') · owner still sees it: $(curl -s -b $A $BASE/visit.php?g=$PL -o /dev/null -w '%{http_code}') · admin: $(curl -s -b $ADM $BASE/visit.php?g=$PL -o /dev/null -w '%{http_code}')"
dbx "UPDATE users SET garden_public=1 WHERE id=$SID"
echo "== Garden of the Month"
gm() { curl -s -b $1 -c $1 $BASE/gotm.php > /tmp/y.html; curl -s -b $1 -c $1 -X POST $BASE/gotm.php --data-urlencode "csrf=$(csrf /tmp/y.html)" -d do=$2 -d plot_id=$3 -d entry=$4 -o /dev/null; flash $1 gotm.php; }
BPL=$(db "SELECT id FROM plots WHERE user_id=$BID LIMIT 1"); [ -z "$BPL" ] && echo "  (bloom has no garden)"
echo -n "  bloom enters a plain garden: "; gm $B enter ${BPL:-0} 0
echo -n "  sprout enters: "; gm $A enter $PL 0
echo -n "  sprout enters again: "; gm $A enter $PL 0
E=$(db "SELECT id FROM gotm_entries WHERE plot_id=$PL")
echo -n "  sprout votes own: "; gm $A vote 0 $E
echo -n "  bloom votes: "; gm $B vote 0 $E; echo -n "  twice: "; gm $B vote 0 $E
dbx "UPDATE users SET level=1 WHERE id=$BID"; dbx "DELETE FROM gotm_votes"; dbx "UPDATE gotm_entries SET votes=0"; echo -n "  level 1 votes: "; gm $B vote 0 $E; dbx "UPDATE users SET level=5 WHERE id=$BID"; gm $B vote 0 $E >/dev/null
echo "  page lists: $(curl -s -b $B $BASE/gotm.php | grep -c 'class="box gardencard"') · games link: $(curl -s -b $B $BASE/games.php | grep -c 'gotm.php')"
C0=$(db "SELECT coins||'/'||ribbons FROM users WHERE id=$SID"); dbx "UPDATE gotm_entries SET month='2026-01'"; dbx "UPDATE gotm_votes SET month='2026-01'"
curl -s -b $B $BASE/gotm.php > /dev/null; echo "  settled: $(db "SELECT placed, votes FROM gotm_entries WHERE plot_id=$PL") · sprout coins/ribbons $C0 -> $(db "SELECT coins||'/'||ribbons FROM users WHERE id=$SID") · notice: $(db "SELECT COUNT(*) FROM notices WHERE user_id=$SID AND text LIKE '%Garden of the Month%'")"
curl -s -b $B $BASE/gotm.php > /dev/null; echo "  paid once: $(db "SELECT coins FROM users WHERE id=$SID")"
echo "  winners on profile: $(curl -s -b $B $BASE/profile.php?id=$SID | grep -c '1st in 2026-01')"
echo "== report a yard, moderator clears it"
curl -s -b $B -c $B "$BASE/report.php?u=$SID&k=yard&r=$PL" > /tmp/y.html; echo "  report page: $(grep -oE 'The yard of[^<]*' /tmp/y.html)"
curl -s -b $B -c $B -X POST $BASE/report.php --data-urlencode "csrf=$(csrf /tmp/y.html)" -d u=$SID -d k=yard -d r=$PL -d reason=rude -o /dev/null
R=$(db "SELECT id FROM reports WHERE kind='yard'"); curl -s -b $ADM -c $ADM $BASE/modtools.php > /tmp/y.html; echo "  queue has look link: $(grep -c 'visit.php?g=' /tmp/y.html) · clear label: $(grep -c 'Clear the yard' /tmp/y.html)"
D0=$(db "SELECT COUNT(*) FROM garden_objects WHERE plot_id=$PL AND kind='decor'"); curl -s -b $ADM -c $ADM -X POST $BASE/modtools.php --data-urlencode "csrf=$(csrf /tmp/y.html)" -d do=clear -d report=$R -o /dev/null
echo "  decor placed $D0 -> $(db "SELECT COUNT(*) FROM garden_objects WHERE plot_id=$PL AND kind='decor'") · buildings left $(db "SELECT COUNT(*) FROM garden_objects WHERE plot_id=$PL AND kind='building'") · satchel decor: $(db "SELECT SUM(ui.qty) FROM user_items ui JOIN items i ON i.id=ui.item_id WHERE ui.user_id=$SID AND i.category='decor'")"
echo "== expand plot and yard"
dbx "UPDATE plots SET garden_level=10 WHERE id=$PL"
ex() { curl -s -b $A -c $A $BASE/$1 > /tmp/y.html; curl -s -b $A -c $A -X POST $BASE/$1 --data-urlencode "csrf=$(csrf /tmp/y.html)" -d do=$2 -d dir=$3 -o /dev/null; flash $A $1; }
dbx "UPDATE users SET coins=coins+1000 WHERE id=$SID"; dbx "INSERT INTO user_items (user_id,item_id,qty) VALUES ($SID,$(item timber-plank),5)"   # v0.9.5: Add 4 beds needs planks
echo -n "  add 4 beds: "; ex garden.php expand; curl -s -b $A $BASE/garden.php >/dev/null
echo "  new beds: $(db "SELECT group_concat(x||','||y||'@'||yx||','||yy, ' ') FROM plot_tiles WHERE plot_id=$PL AND id>(SELECT MIN(id)+15 FROM plot_tiles WHERE plot_id=$PL)")"
echo -n "  extend yard: "; ex yard.php extend w; echo "  yard now: $(curl -s -b $A $BASE/garden.php | grep -oE 'class="yard yc[0-9]+ yr[0-9]+')"
echo "== fences, walls, hedges join (v0.9.5)"
phpq() { php -r 'chdir("'$GAME'"); $_SERVER["HTTP_HOST"]="x"; require "includes/bootstrap.php"; require_once "includes/garden_logic.php"; require_once "includes/yard.php"; '"$1"; }
# every arm pattern of a lone centre piece: shape + mask, and the families that do/don't join
phpq '$mk = fn($id, $x, $y, $look, $type = "fence", $rot = 0, $shape = "") => ["id" => $id, "kind" => "decor", "x" => $x, "y" => $y, "bw" => 1, "bh" => 1, "w" => 1, "h" => 1, "look" => $look, "type" => $type, "rot" => $rot, "shape" => $shape];
 $dirs = [1 => [0, -1], 2 => [1, 0], 4 => [0, 1], 8 => [-1, 0]]; $out = [];
 for ($m = 0; $m < 16; $m++) { $o = [$mk(1, 5, 5, "picket-fence")]; foreach ($dirs as $b => [$dx, $dy]) if ($m & $b) $o[] = $mk(10 + $b, 5 + $dx, 5 + $dy, "wattle-fence");
   $i = yard_join_info($o)[1]; $out[] = $m . "=" . $i["shape"] . "/" . $i["mask"]; } echo "  arms: ", implode(" ", $out), "\n";
 $r = fn($o) => implode(",", array_map(fn($i) => $i["fam"] . ":" . $i["shape"], yard_join_info($o)));
 echo "  fence+hedge do not join: ", $r([$mk(1, 1, 1, "picket-fence"), $mk(2, 2, 1, "box-hedge", "hedge")]), "\n";
 echo "  fence+wall do not join: ", $r([$mk(1, 1, 1, "picket-fence"), $mk(2, 2, 1, "stone-wall")]), "\n";
 echo "  gate joins fence and wall: ", $r([$mk(1, 1, 1, "picket-fence"), $mk(2, 2, 1, "garden-gate"), $mk(3, 3, 1, "stone-wall")]), "\n";
 echo "  lone turns with rotation: ", $r([$mk(1, 1, 1, "picket-fence", "fence", 0)]), " ", yard_join_info([$mk(1, 1, 1, "picket-fence", "fence", 0)])[1]["mask"], "/", yard_join_info([$mk(1, 1, 1, "picket-fence", "fence", 90)])[1]["mask"], "\n";
 $ov = []; foreach (["end", "straight", "corner", "tee", "cross"] as $sh) foreach ([0, 90, 180, 270] as $rot) $ov[] = $sh . $rot . "=" . yard_join_info([$mk(1, 1, 1, "picket-fence", "fence", $rot, $sh)])[1]["mask"];
 echo "  override shape+rotation masks: ", implode(" ", $ov), "\n";
 echo "  neighbours ignored when overridden: ", yard_join_info([$mk(1, 1, 1, "picket-fence", "fence", 0, "corner"), $mk(2, 2, 1, "picket-fence")])[1]["shape"], "\n";
 echo "  unplaced and 2x1 pieces skipped: ", count(yard_join_info([$mk(1, -1, -1, "picket-fence"), array_merge($mk(2, 3, 3, "picket-fence"), ["bw" => 2])])), "\n";
 echo "  svg: ", preg_match("~^<svg class=\"fz fz-hedge\".*<circle~", yard_join_svg("hedge", 3)) ? "ok" : "BAD", " gate: ", substr_count(yard_join_svg("gate", 10), "class=\"gt\""), "\n";
 echo "  image path: ", yard_image("assets/fence-{shape}.png"), " | ", yard_image("../x.png") === "" ? "dotdot refused" : "BAD", " | ", yard_image("javascript:x") === "" ? "script refused" : "BAD", "\n";'
GATE=$(item garden-gate); SW=$(item stone-wall); [ -z "$GATE" ] && echo "  (garden gate item missing)"
dbx "DELETE FROM user_items WHERE user_id=$SID AND item_id IN ($FE,$GATE,$SW,$HE)"
dbx "INSERT INTO user_items (user_id,item_id,qty) VALUES ($SID,$FE,12),($SID,$GATE,2),($SID,$SW,2),($SID,$HE,2)"
dbx "UPDATE plots SET yard_xw=2, yard_xh=2 WHERE id=$PL"
free() { phpq '$plot = q_one("SELECT * FROM plots WHERE id='$PL'"); yard_sync('$PL'); [$yw, $yh] = yard_size($plot); $g = [];
  foreach (q("SELECT yx, yy FROM plot_tiles WHERE plot_id='$PL'")->fetchAll() as $t) yard_mark($g, (int)$t["yx"], (int)$t["yy"], 1, 1);
  foreach (q("SELECT x, y, w, h FROM garden_objects WHERE plot_id='$PL' AND x >= 0")->fetchAll() as $o) yard_mark($g, (int)$o["x"], (int)$o["y"], (int)$o["w"], (int)$o["h"]);
  $s = yard_free_spot($g, $yw, $yh, '$1', '$2'); echo $s ? $s[0] . " " . $s[1] : "none";'; }
read FX FY <<< "$(free 4 4)"; echo "  free 4x4 block at $FX,$FY"
cur() { db "SELECT group_concat('['||id||','||x||','||y||','||rot||','||COALESCE('\"'||shape||'\"','\"\"')||']') FROM garden_objects WHERE plot_id=$PL AND x>=0"; }
shp() { db "SELECT group_concat(COALESCE(shape,'-'), ',') FROM (SELECT shape FROM garden_objects WHERE plot_id=$PL AND kind='decor' ORDER BY id)"; }
save2() { curl -s -b $A -c $A $BASE/yard.php > /tmp/y.html; curl -s -b $A -c $A -X POST $BASE/yard.php --data-urlencode "csrf=$(csrf /tmp/y.html)" -d do=save --data-urlencode "layout=$1" -o /dev/null -w '%{redirect_url} '; flash $A ${2:-garden.php}; }
H0=$(db "SELECT COUNT(*) FROM yard_history WHERE plot_id=$PL")
# a plus sign of fences with a gate in the arm, a hedge pair, and an overridden corner
PX=$((FX+1)); PY=$((FY+1))
N="[$FE,$PX,$PY,0,\"\"],[$FE,$((PX+1)),$PY,0,\"\"],[$FE,$((PX-1)),$PY,0,\"\"],[$FE,$PX,$((PY-1)),0,\"\"],[$GATE,$PX,$((PY+1)),0,\"\"],[$HE,$((FX+3)),$FY,0,\"\"],[$HE,$((FX+3)),$((FY+1)),0,\"bogus\"],[$FE,$((FX+3)),$((FY+3)),90,\"tee\"],[$BB,$((FX+2)),$((FY+3)),0,\"cross\"]"
echo -n "  place cross+gate+hedges+override: "; save2 "{\"o\":[$(cur)],\"n\":[$N]}"
echo "  stored shapes (bogus and non-joining dropped): $(shp)"
phpq 'foreach (yard_join_info(yard_objects('$PL')) as $id => $i) echo $i["fam"], ":", $i["shape"], ($i["chosen"] ? "*" : ""), "/", $i["mask"], " "; echo "\n";' | sed 's/^/  joined: /'
curl -s -b $A $BASE/yard.php > /tmp/y.html
echo "  designer markup: joined pieces $(grep -o 'class="yo dec [^"]* fj' /tmp/y.html | wc -l) · svg arms $(grep -o 'class="rl"' /tmp/y.html | wc -l) · gate leaf $(grep -o 'class="gt"' /tmp/y.html | wc -l) · data-fam $(grep -o 'data-fam="[a-z]\+"' /tmp/y.html | sort | uniq -c | tr -s ' ' | tr '\n' ' ') · tools: shape $(grep -c 'data-act="shape"' /tmp/y.html) grid $(grep -c 'data-act="grid"' /tmp/y.html) snap $(grep -c 'data-act="snap"' /tmp/y.html) rotate $(grep -c 'data-act="rotate"' /tmp/y.html)"
echo "  garden page (view mode) joined pieces: $(curl -s -b $A $BASE/garden.php | grep -o 'class="yo dec [^"]* fj' | wc -l)"
echo "  no inline style on yard pages: $(grep -c ' style=' /tmp/y.html)"
echo -n "  rotate lone piece 90 + clear override: "; ID1=$(db "SELECT id FROM garden_objects WHERE plot_id=$PL AND shape='tee'"); ROWS=$(db "SELECT group_concat('['||id||','||x||','||y||','||CASE WHEN id=$ID1 THEN 180 ELSE rot END||','||CASE WHEN id=$ID1 THEN '\"\"' ELSE COALESCE('\"'||shape||'\"','\"\"') END||']') FROM garden_objects WHERE plot_id=$PL AND x>=0"); save2 "{\"o\":[$ROWS]}"
db "SELECT rot, COALESCE(shape,'auto'), w, h FROM garden_objects WHERE id=$ID1"
echo -n "  rotate a gate (stays 1x1, rot stored): "; GID=$(db "SELECT o.id FROM garden_objects o JOIN items i ON i.id=o.item_id WHERE o.plot_id=$PL AND i.slug='garden-gate'"); ROWS=$(db "SELECT group_concat('['||id||','||x||','||y||','||CASE WHEN id=$GID THEN 90 ELSE rot END||','||COALESCE('\"'||shape||'\"','\"\"')||']') FROM garden_objects WHERE plot_id=$PL AND x>=0"); save2 "{\"o\":[$ROWS]}"; db "SELECT rot,w,h FROM garden_objects WHERE id=$GID"
echo "== undo history (server side)"
H1=$(db "SELECT COUNT(*) FROM yard_history WHERE plot_id=$PL"); echo "  history rows: $H0 -> $H1 (a save that changes something adds one)"
echo -n "  save with no change adds none: "; save2 "{\"o\":[$(cur)]}" >/dev/null; echo "$(db "SELECT COUNT(*) FROM yard_history WHERE plot_id=$PL") rows"
curl -s -b $A $BASE/yard.php > /tmp/y.html; echo "  undo button: $(grep -oE 'Undo last save \([0-9]+\)' /tmp/y.html)"
undo() { curl -s -b $A -c $A $BASE/yard.php > /tmp/y.html; curl -s -b $A -c $A -X POST $BASE/yard.php --data-urlencode "csrf=$(csrf /tmp/y.html)" -d do=undo -o /dev/null -w '%{redirect_url} '; flash $A yard.php; }
echo -n "  undo with no csrf is refused: "; curl -s -b $A -X POST $BASE/yard.php -d do=undo -o /dev/null -w '%{http_code}'; echo " (rows still $(db "SELECT COUNT(*) FROM yard_history WHERE plot_id=$PL"))"
echo "  before undo: decor placed $(db "SELECT COUNT(*) FROM garden_objects WHERE plot_id=$PL AND kind='decor'") · gate rot $(db "SELECT rot FROM garden_objects WHERE id=$GID") · fences in satchel $(db "SELECT qty FROM user_items WHERE user_id=$SID AND item_id=$FE")"
echo -n "  undo 1 (gate rotation): "; undo; echo "    gate rot $(db "SELECT rot FROM garden_objects WHERE id=$GID")"
echo -n "  undo 2 (tee piece rotation): "; undo; echo "    tee piece rot/shape $(db "SELECT rot||'/'||COALESCE(shape,'auto') FROM garden_objects WHERE id=$ID1")"
echo -n "  undo 3 (the big placement): "; undo; echo "    decor placed $(db "SELECT COUNT(*) FROM garden_objects WHERE plot_id=$PL AND kind='decor'") · fences in satchel $(db "SELECT qty FROM user_items WHERE user_id=$SID AND item_id=$FE") · gates $(db "SELECT qty FROM user_items WHERE user_id=$SID AND item_id=$GATE")"
echo "  appeal after undo: $(db "SELECT appeal FROM plots WHERE id=$PL")"
# put things back, then check undo of a "put away"
rows() { db "SELECT group_concat('['||id||','||x||','||y||','||rot||',\"\"]') FROM garden_objects WHERE plot_id=$PL AND x>=0$1"; }
echo -n "  place 2 fences, then put one away: "; save2 "{\"o\":[$(cur)],\"n\":[[$FE,$FX,$FY,0,\"\"],[$FE,$((FX+1)),$FY,0,\"\"]]}" >/dev/null; F1=$(db "SELECT MIN(id) FROM garden_objects WHERE plot_id=$PL AND item_id=$FE"); F2=$(db "SELECT MAX(id) FROM garden_objects WHERE plot_id=$PL AND item_id=$FE")
save2 "{\"o\":[$(rows " AND id<>$F2")]}" >/dev/null; echo "placed $(db "SELECT COUNT(*) FROM garden_objects WHERE item_id=$FE")"
echo -n "  undo brings the put-away fence back out of the satchel: "; undo >/dev/null; echo "placed $(db "SELECT COUNT(*) FROM garden_objects WHERE item_id=$FE") · satchel $(db "SELECT qty FROM user_items WHERE user_id=$SID AND item_id=$FE")"
F1=$(db "SELECT MIN(id) FROM garden_objects WHERE plot_id=$PL AND item_id=$FE"); F2=$(db "SELECT MAX(id) FROM garden_objects WHERE plot_id=$PL AND item_id=$FE")
save2 "{\"o\":[$(rows " AND id<>$F2")]}" >/dev/null; dbx "UPDATE user_items SET qty=0 WHERE user_id=$SID AND item_id=$FE"; HB=$(db "SELECT COUNT(*) FROM yard_history WHERE plot_id=$PL")
undo >/dev/null; echo "  undo needing a fence you no longer own is refused: placed $(db "SELECT COUNT(*) FROM garden_objects WHERE item_id=$FE") (was 1) · history rows $HB -> $(db "SELECT COUNT(*) FROM yard_history WHERE plot_id=$PL")"
dbx "UPDATE user_items SET qty=5 WHERE user_id=$SID AND item_id=$FE"
echo -n "  undo that no longer fits is refused (a bed moved into its spot): "; F2=$(db "SELECT MAX(id) FROM garden_objects WHERE plot_id=$PL AND item_id=$FE"); XY=$(db "SELECT x||','||y FROM garden_objects WHERE id=$F2"); save2 "{\"o\":[$(rows " AND id<>$F2")]}" >/dev/null
dbx "UPDATE plot_tiles SET yx=${XY%,*}, yy=${XY#*,} WHERE plot_id=$PL AND x=0 AND y=0 AND plant_id IS NULL"; undo >/dev/null; echo "placed $(db "SELECT COUNT(*) FROM garden_objects WHERE item_id=$FE")"
F1=$(db "SELECT MIN(id) FROM garden_objects WHERE plot_id=$PL AND item_id=$FE"); dbx "DELETE FROM login_attempts WHERE username LIKE 'yard:%'"   # (saving and undoing are rate limited: 40 per 10 minutes)
echo "  history is capped: $(for i in 1 2 3 4 5 6 7 8 9 10 11 12 13; do R=$((i%2)); save2 "{\"o\":[$(db "SELECT group_concat('['||id||','||x||','||y||','||CASE WHEN id=$F1 THEN $((R*90)) ELSE rot END||',\"\"]') FROM garden_objects WHERE plot_id=$PL AND x>=0")]}" >/dev/null; done; db "SELECT COUNT(*) FROM yard_history WHERE plot_id=$PL") rows (keep 10)"
echo "  other gnome can't undo my yard: $(curl -s -b $B $BASE/yard.php -o /dev/null -w '%{http_code}') · history rows are per plot: $(db "SELECT COUNT(DISTINCT plot_id) FROM yard_history")"
echo "  upgrade_095_yard (idempotent, gate on sale, almanac): $(phpq 'upgrade_095_yard(); upgrade_095_yard(); echo (int)q_val("SELECT COUNT(*) FROM shop_stock s JOIN items i ON i.id=s.item_id WHERE i.slug=\"garden-gate\""), " gate stock rows, almanac mentions shape: ", (int)str_contains((string)q_val("SELECT body FROM encyclopedia_entries WHERE title=\"Designing your yard\""), "Shape"), " once: ", substr_count((string)q_val("SELECT body FROM encyclopedia_entries WHERE title=\"Designing your yard\""), "Fences, walls and hedges[/b] join");')"
echo "== crafting tab and satchel"
echo "  crafting decor tab: $(curl -s -b $A "$BASE/crafting.php?t=decor" | grep -c 'Yard &amp; decor')"
echo "  satchel decor chip: $(curl -s -b $A "$BASE/inventory.php" | grep -c 'Decor')"
echo "  shop: $(curl -s -b $A "$BASE/shop.php?id=$(db "SELECT id FROM shops WHERE slug='hedge-and-hearth'")" -o /dev/null -w '%{http_code}')"
echo "== php errors"; grep -iE 'fatal|warning|notice|deprecated' /tmp/yard-php.log || echo "(none)"
