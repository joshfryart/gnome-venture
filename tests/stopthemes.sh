#!/bin/bash
# v2.0.77 themed stop upgrades: data lint (all 12 kinds x 4 tiers x 14 regions resolve to real items), imports, the themed activities
# replace the plain ones, and a stop is adopted and built up through tier 1 with its themed needs. Run after walk.sh has installed.
GAME=$1; PORT=$2; ROUTER=$3
FAILS=0
chk() { if [ "$2" = 1 ]; then echo "  ok   $1"; else echo "  FAIL $1 $3"; FAILS=$((FAILS+1)); fi; }
db() { php -r '$p=new PDO("sqlite:'$GAME'/data/game.sqlite"); foreach($p->query($argv[1])->fetchAll(PDO::FETCH_NUM) as $r) echo implode(" | ",$r),"\n";' "$1"; }
dbx() { php -r '$p=new PDO("sqlite:'$GAME'/data/game.sqlite"); $p->exec($argv[1]);' "$1"; }
phpx() { php -r '$_SERVER["SCRIPT_NAME"]="/gnome.php"; require "'$GAME'/includes/bootstrap.php"; require_once "'$GAME'/includes/stops.php"; require_once "'$GAME'/includes/stop_adopt.php"; '"$1"; }

echo "== data"
chk "48 themed tiers imported" "$([ "$(db "SELECT COUNT(*) FROM stop_tier_themes" | tr -d ' ')" = 48 ] && echo 1)"
chk "every kind of stop has tiers 1-4" "$([ -z "$(db "SELECT t.slug FROM stop_types t WHERE (SELECT COUNT(*) FROM stop_tier_themes m WHERE m.stop_type=t.slug) <> 4")" ] && echo 1)" "$(db "SELECT t.slug FROM stop_types t WHERE (SELECT COUNT(*) FROM stop_tier_themes m WHERE m.stop_type=t.slug) <> 4")"
chk "48 themed activities, none plain" "$([ "$(db "SELECT COUNT(*) FROM stop_acts WHERE slug LIKE 'tt\_%' ESCAPE '\\' AND active=1" | tr -d ' ')" = 48 ] && echo 1)"
chk "plain bench/stall/well/table switched off" "$([ "$(db "SELECT COUNT(*) FROM stop_acts WHERE slug IN ('bench_rest','trader_stall','wishing_well','long_table') AND active=1" | tr -d ' ')" = 0 ] && echo 1)"
chk "lantern post stays" "$([ "$(db "SELECT active FROM stop_acts WHERE slug='lantern_post'" | tr -d ' ')" = 1 ] && echo 1)"
BAD=$(phpx '$bad=[]; $regs=array_column(q("SELECT code FROM regions")->fetchAll(),"code");
  foreach ($regs as $code) { [$a,$b]=region_locals($code); foreach ([$a,$b] as $s) if (!q_val("SELECT 1 FROM items WHERE slug=?",[$s])) $bad[]="$code local $s missing"; }
  foreach (q("SELECT * FROM stop_tier_themes")->fetchAll() as $r) {
    foreach (array_filter(explode(",",$r["needs"])) as $n) { [$k]=explode(":",$n); if (in_array($k,["coins","meal","fine"],true)) continue; if ($k[0]==="{") continue; if (!q_val("SELECT 1 FROM items WHERE slug=?",[$k])) $bad[]=$r["stop_type"].$r["tier"]." item $k"; }
    if (!q_val("SELECT 1 FROM stop_acts WHERE slug=?",["tt_".$r["stop_type"]."_".$r["tier"]])) $bad[]="no act for ".$r["stop_type"].$r["tier"];
    if (str_contains($r["needs"],"{a}")===false && $r["tier"]==1) $bad[]="tier 1 has no local";
  }
  echo $bad ? "BAD: ".implode("; ",$bad) : "clean";')
chk "every need and local material is a real item" "$([ "$BAD" = clean ] && echo 1)" "$BAD"

echo "== a themed stop (a mill in Maizehollow)"
LOC=$(db "SELECT l.id FROM locations l JOIN regions r ON r.id=l.region_id WHERE l.kind='village' AND r.code='CA' ORDER BY l.id LIMIT 1" | tr -d ' ')
dbx "UPDATE locations SET stop_type='mill' WHERE id=$LOC"
SID=$(db "SELECT id FROM users WHERE username='sprout'" | tr -d ' ')
dbx "UPDATE users SET level=10, coins=5000 WHERE id=$SID"; dbx "INSERT OR IGNORE INTO stop_stamps (user_id, location_id, first_at) VALUES ($SID, $LOC, datetime('now'))"
dbx "DELETE FROM stop_adoptions WHERE location_id=$LOC"
OUT=$(phpx '$loc=q_one("SELECT * FROM locations WHERE id='$LOC'"); $u=q_one("SELECT * FROM users WHERE id='$SID'");
  $t=stop_tiers_for($loc);
  echo "tier1=", $t[1]["name"], "|needs=", $t[1]["needs"], "\n";
  [$ok,$m]=stop_adopt($u,$loc); echo "adopt=", $ok?1:0, "\n";
  foreach (stop_tier_needs($t[1]) as [$k,$q]) { if ($k!=="coins") { $it=(int)q_val("SELECT id FROM items WHERE slug=?",[$k]); give_item('$SID',$it,$q); } [$ok,$m]=stop_contribute(q_one("SELECT * FROM users WHERE id='$SID'"),$loc,$k,$q); echo "give $k=", $ok?1:0, "\n"; }
  echo "tier=", stop_tier((int)$loc["id"]), "\n";
  echo "plaque=", strip_tags(stop_plaque($loc)), "\n";
  $pool=stop_pool($loc); echo "acts=", implode(",", array_column($pool["offer"],"slug")), "\n";')
echo "$OUT" | sed 's/^/  /'
chk "tier 1 is the Sack hoist and asks for Maizehollow's own ochre" "$(echo "$OUT" | grep -q 'tier1=Sack hoist|needs=timber-plank:4,rope:4,red-ochre:3,coins:200' && echo 1)"
chk "adopted" "$(echo "$OUT" | grep -q '^adopt=1' && echo 1)"
chk "no failed hand-in" "$(echo "$OUT" | grep -q '=0$' && echo 0 || echo 1)"
chk "stop reached tier 1" "$(echo "$OUT" | grep -q '^tier=1' && echo 1)"
chk "plaque names the themed upgrade" "$(echo "$OUT" | grep -q 'Sack hoist' && echo 1)"
chk "the themed tier-1 rest is on offer, the plain bench is not" "$(echo "$OUT" | grep '^acts=' | grep -q 'tt_mill_1' && ! echo "$OUT" | grep '^acts=' | grep -q 'bench_rest' && echo 1)"
chk "the plaque shows the tier picture (placeholder art until drawn)" "$(echo "$OUT" | grep -q . && phpx '$l=q_one("SELECT * FROM locations WHERE id='$LOC'"); echo str_contains(stop_plaque($l), "stoptiers/mill-1.png") ? 1 : 0;' | grep -q 1 && echo 1)"
chk "a market in the same region has a different tier 1" "$([ "$(phpx '$l=q_one("SELECT * FROM locations WHERE id='$LOC'"); $l["stop_type"]="market"; echo stop_tiers_for($l)[1]["name"];')" = "Striped awning" ] && echo 1)"
echo "== upgrade from 2.0.75 (themes missing, plain acts on)"
dbx "DELETE FROM stop_tier_themes"; dbx "DELETE FROM stop_acts WHERE slug LIKE 'tt\_%' ESCAPE '\\'"; dbx "DELETE FROM settings WHERE name='stop_themes_v1'"
dbx "UPDATE stop_acts SET active=1 WHERE slug IN ('bench_rest','trader_stall','wishing_well','long_table')"; dbx "UPDATE settings SET value='2.0.75' WHERE name='db_version'"
php -d session.save_path=/tmp -S 127.0.0.1:$PORT -t $GAME $ROUTER >/tmp/st-php.log 2>&1 & PID=$!; sleep 1; trap "kill $PID 2>/dev/null" EXIT
curl -s "http://127.0.0.1:$PORT/login.php" -o /dev/null
chk "themes imported again on the first request" "$([ "$(db "SELECT COUNT(*) FROM stop_tier_themes" | tr -d ' ')" = 48 ] && echo 1)"
chk "themed activities back, plain ones off" "$([ "$(db "SELECT COUNT(*) FROM stop_acts WHERE slug LIKE 'tt\_%' ESCAPE '\\' AND active=1" | tr -d ' ')" = 48 ] && [ "$(db "SELECT COUNT(*) FROM stop_acts WHERE slug='bench_rest' AND active=1" | tr -d ' ')" = 0 ] && echo 1)"
chk "no PHP warnings or fatals" "$(grep -iE 'fatal|warning|notice|deprecated|exception' /tmp/st-php.log | grep -q . && echo 0 || echo 1)" "$(grep -iE 'fatal|warning|notice' /tmp/st-php.log | head -3)"
[ $FAILS -eq 0 ] && echo "all passed" || echo "$FAILS FAILED"; [ $FAILS -eq 0 ]
