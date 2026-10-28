#!/bin/bash
# v2.0.78 new rest-stop activity kinds (craft, collect, tend, contest), regional activities, kind diversity. Run after walk.sh has installed.
GAME=$1; PORT=$2; ROUTER=$3
FAILS=0
chk() { if [ "$2" = 1 ]; then echo "  ok   $1"; else echo "  FAIL $1 $3"; FAILS=$((FAILS+1)); fi; }
db() { php -r '$p=new PDO("sqlite:'$GAME'/data/game.sqlite"); foreach($p->query($argv[1])->fetchAll(PDO::FETCH_NUM) as $r) echo implode(" | ",$r),"\n";' "$1"; }
dbx() { php -r '$p=new PDO("sqlite:'$GAME'/data/game.sqlite"); $p->exec($argv[1]);' "$1"; }
phpx() { php -r '$_SERVER["SCRIPT_NAME"]="/gnome.php"; require "'$GAME'/includes/bootstrap.php"; require_once "'$GAME'/includes/stops.php"; require_once "'$GAME'/includes/stop_adopt.php"; require_once "'$GAME'/includes/stop_folk.php"; require_once "'$GAME'/includes/local.php"; '"$1"; }

echo "== data"
chk "14 regional activities imported" "$([ "$(db "SELECT COUNT(*) FROM stop_acts WHERE region IS NOT NULL AND region <> ''" | tr -d ' ')" = 14 ] && echo 1)"
BAD=$(phpx '$bad=[]; foreach (q("SELECT * FROM stop_acts WHERE region IS NOT NULL AND region <> \"\"")->fetchAll() as $a) {
    if (!in_array($a["kind"], ["craft","collect","tend","contest","check","pick"], true)) $bad[]=$a["slug"]." kind";
    foreach (array_filter(explode(",", $a["types"])) as $t) if ($t !== "any" && !q_val("SELECT 1 FROM stop_types WHERE slug=?", [$t])) $bad[]=$a["slug"]." type $t";
    foreach (array_filter(explode(",", $a["region"])) as $r) if (!q_val("SELECT 1 FROM regions WHERE code=?", [$r])) $bad[]=$a["slug"]." region $r";
    if ($a["kind"]==="craft") { [$ins,[$os]]=stop_craft_parts($a["spec"]); foreach (array_merge(array_column($ins,0),[$os]) as $sl) if (!q_val("SELECT 1 FROM items WHERE slug=?",[$sl])) $bad[]=$a["slug"]." item $sl"; }
    if ($a["kind"]==="collect") { [$set,,$e,$n,$d]=stop_collect_parts($a["spec"]); if (count($e)<4 || $d==="") $bad[]=$a["slug"]." collect spec"; }
    if ($a["kind"]==="contest" && count(explode("/", stop_spec_params($a["spec"])["moves"] ?? ""))!==3) $bad[]=$a["slug"]." moves";
    if (stop_act_art($a["kind"], $a["slug"]) === "") $bad[]=$a["slug"]." no art";
  } echo $bad ? "BAD: ".implode("; ",$bad) : "clean";')
chk "every regional activity is well formed (types, regions, items, specs, art)" "$([ "$BAD" = clean ] && echo 1)" "$BAD"
chk "placeholder art for the four new kinds exists" "$([ -f $GAME/assets/img/acts/act-craft.png ] && [ -f $GAME/assets/img/acts/act-collect.png ] && [ -f $GAME/assets/img/acts/act-tend.png ] && [ -f $GAME/assets/img/acts/act-contest.png ] && echo 1)"

echo "== playing the kinds (a Maplewold stop)"
SID=$(db "SELECT id FROM users WHERE username='sprout'" | tr -d ' ')
LOC=$(db "SELECT l.id FROM locations l JOIN regions r ON r.id=l.region_id WHERE l.kind='village' AND r.code='NA' ORDER BY l.id LIMIT 1" | tr -d ' ')
dbx "UPDATE users SET level=8, energy=60, coins=1000, location_id=$LOC WHERE id=$SID"
OUT=$(phpx '$SID=(int)'$SID'; $u0=q_one("SELECT * FROM users WHERE id='$SID'"); $loc=q_one("SELECT * FROM locations WHERE id='$LOC'");
  $try = function(string $slug, array $in) use ($SID, $loc) {
    // a fresh visit each time: clear this stop log, then force the act on offer by calling stop_do directly
    q("DELETE FROM stop_log WHERE user_id=?", [$SID]);
    $u = q_one("SELECT * FROM users WHERE id=?", [$SID]); $_SESSION["stop_visit"] = null;
    [$ok,$m] = stop_do($u, $loc, $slug, $in); return [$ok, $m]; };
  // make every regional act offered: put them all in the pool by clearing conditions, and open enough slots
  q("UPDATE stop_acts SET cond=\"-\", types=\"any\" WHERE region IS NOT NULL AND region <> \"\"");
  stop_acts(true); set_setting("stop_slots", "9"); set_setting("stop_daily_cap", "99"); set_setting("stop_core", "20"); setting("__reload__");
  $iid = fn($s) => (int)q_val("SELECT id FROM items WHERE slug=?", [$s]);
  q("DELETE FROM stop_prog WHERE user_id=?", [$SID]);
  // craft
  [$ok,$m] = $try("na_birch_planks", []); echo "craft without logs=", $ok?1:0, "\n";
  give_item($SID, $iid("birch-log"), 2); $pl0=(int)q_val("SELECT COALESCE(SUM(qty),0) FROM user_items WHERE user_id=? AND item_id=?", [$SID, $iid("timber-plank")]);
  [$ok,$m] = $try("na_birch_planks", []); $pl1=(int)q_val("SELECT COALESCE(SUM(qty),0) FROM user_items WHERE user_id=? AND item_id=?", [$SID, $iid("timber-plank")]);
  echo "craft=", $ok?1:0, " planks+", $pl1-$pl0, " logs left=", (int)q_val("SELECT COALESCE(SUM(qty),0) FROM user_items WHERE user_id=? AND item_id=?", [$SID, $iid("birch-log")]), "\n";
  // collect: 8 entries, loop until the set is done
  [$ok,$m] = $try("na_prairie_birds", ["pick"=>9]); echo "collect bad spot=", $ok?1:0, "\n";
  for ($i=0; $i<80; $i++) { [$ok,$m] = $try("na_prairie_birds", ["pick"=>1]); if (str_contains($m, "whole set")) break; }
  [$n,$d] = stop_prog_get($SID, 0, "set:maple-birds");
  echo "collect found=$n done=", $d["done"] ?? 0, " rounds=$i\n";
  [$ok,$m] = $try("na_prairie_birds", ["pick"=>1]); echo "collect again ok=", $ok?1:0, " noSecondSetPrize=", str_contains($m, "whole set") ? 0 : 1, "\n";
  // tend: 3 visits
  for ($i=1; $i<=3; $i++) { [$ok,$m] = $try("na_beaver_dam", []); [$n] = stop_prog_get($SID, (int)$loc["id"], "tend:na_beaver_dam"); echo "tend$i ok=", $ok?1:0, " n=$n\n"; }
  // contest: all three moves, many times: win/draw/lose all show up, never an error
  $res=[]; for ($i=0; $i<60; $i++) { [$ok,$m] = $try("na_pumpkin_roll", ["move"=>$i%3]); $res[$ok ? (str_contains($m,"draw") ? "draw" : "played") : "ERR"] = 1; if (!$ok) echo "contest err: $m\n"; }
  echo "contest outcomes=", implode(",", array_keys($res)), "\n";
  [$ok,$m] = $try("na_pumpkin_roll", ["move"=>7]); echo "contest bad move=", $ok?1:0, "\n";
')
echo "$OUT" | sed 's/^/  /'
chk "craft refused without the logs" "$(echo "$OUT" | grep -q 'craft without logs=0' && echo 1)"
chk "craft made a plank from 2 logs" "$(echo "$OUT" | grep -q 'craft=1 planks+1 logs left=0' && echo 1)"
chk "collect: a bad spot is refused" "$(echo "$OUT" | grep -q 'collect bad spot=0' && echo 1)"
chk "collect: the whole set of 8 is found and the prize paid once" "$(echo "$OUT" | grep -q 'collect found=8 done=1' && echo 1)"
chk "collect: a repeat visit is fine and pays no second set prize" "$(echo "$OUT" | grep -q 'collect again ok=1 noSecondSetPrize=1' && echo 1)"
chk "tend: step 1 and 2 count, the third pays and resets" "$(echo "$OUT" | grep -q 'tend1 ok=1 n=1' && echo "$OUT" | grep -q 'tend2 ok=1 n=2' && echo "$OUT" | grep -q 'tend3 ok=1 n=0' && echo 1)"
chk "contest plays out with no error and a bad move is refused" "$(echo "$OUT" | grep -q 'contest bad move=0' && ! echo "$OUT" | grep -q 'contest err' && echo 1)"

echo "== regions and variety"
OUT=$(phpx '$na=q_one("SELECT * FROM locations WHERE id='$LOC'"); $ca=q_one("SELECT l.* FROM locations l JOIN regions r ON r.id=l.region_id WHERE l.kind=\"village\" AND r.code=\"CA\" ORDER BY l.id LIMIT 1");
  q("UPDATE stop_acts SET cond=\"-\" WHERE region IS NOT NULL AND region <> \"\""); stop_acts(true);
  $slugs = fn($loc) => array_column(stop_pool($loc)["offer"], "slug");
  echo "NA has na_=", count(array_filter($slugs($na), fn($s)=>str_starts_with($s,"na_"))), " ca_=", count(array_filter($slugs($na), fn($s)=>str_starts_with($s,"ca_"))), "\n";
  echo "CA has na_=", count(array_filter($slugs($ca), fn($s)=>str_starts_with($s,"na_"))), "\n";')
echo "$OUT" | sed 's/^/  /'
chk "no Maizehollow activity shows at a Maplewold stop" "$(echo "$OUT" | grep -q 'ca_=0' && echo 1)"
chk "no Maplewold activity shows at a Maizehollow stop" "$(echo "$OUT" | grep -q 'CA has na_=0' && echo 1)"
DIV=$(phpx 'foreach ([["a",["x","y"]]] as $_) {} $l=[["slug"=>"1","kind"=>"check"],["slug"=>"2","kind"=>"check"],["slug"=>"3","kind"=>"pick"],["slug"=>"4","kind"=>"check"],["slug"=>"5","kind"=>"craft"]];
  $o=stop_diverse($l,3,[]); echo implode(",", array_column($o,"slug")), "|", implode(",", array_column(stop_diverse($l,5,[]),"slug")), "|", implode(",", array_column(stop_diverse($l,2,["check"]),"slug"));')
chk "diversity: three picks take three different kinds in order, then fill" "$([ "$DIV" = "1,3,5|1,3,5,2,4|3,5" ] && echo 1)" "$DIV"
[ $FAILS -eq 0 ] && echo "all passed" || echo "$FAILS FAILED"; [ $FAILS -eq 0 ]
