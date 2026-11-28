<?php
// World v2 (includes/world_v2.php; master doc sections 2 and 11): world_v2_open off = the world as before; on = band levels (never lowered),
// the zone ladder and band-top lairs, the roads CB-WCA and SA-ESA (laid and Seal-gated), the Beaverdam Fens and Cairnback Ridge with
// Cattailmere (herb) and Granitegate (tower), the named routes and their doors, the route_danger cap 57, and a boot step that is safe to repeat.
// Run by world_v2.sh on a walk.sh install: php tests/world_v2.php GAME
$_SERVER['SCRIPT_NAME'] = '/index.php';
require $argv[1] . '/includes/bootstrap.php';
require_once APP_ROOT . '/includes/adventure.php';
require_once APP_ROOT . '/includes/roads.php';
require_once APP_ROOT . '/includes/seals.php';
require_once APP_ROOT . '/includes/adventure_data.php';
$fails = 0;
function ok(string $what, bool $cond, string $extra = ''): void { global $fails; echo ($cond ? 'ok   ' : 'FAIL ') . $what . ($cond ? '' : "  ($extra)") . "\n"; if (!$cond) $fails++; }
function setg(string $k, string $v): void { set_setting($k, $v); setting('__reload__'); }
$uid = (int)q_val("SELECT id FROM users WHERE username = 'sprout'");
ok('player sprout exists', $uid > 0);
$u = fn() => q_one('SELECT * FROM users WHERE id = ?', [$uid]);
$lv = fn() => array_column(q('SELECT code, min_level FROM regions')->fetchAll(), 'min_level', 'code');
$loc = fn(string $name) => q_one("SELECT l.*, z.zone_num FROM locations l LEFT JOIN zones z ON z.id = l.zone_id WHERE l.name = ?", [$name]);
$counts = fn() => implode(',', array_map(fn($t) => (int)q_val("SELECT COUNT(*) FROM $t"), ['locations', 'routes', 'roads', 'zones', 'landmarks', 'encyclopedia_entries']));
$routeSig = fn() => md5(json_encode(q('SELECT id, a_id, b_id, steps, level, min_level, max_level, fixed, kind FROM routes ORDER BY id')->fetchAll()));
$between = fn(int $a, int $b) => q_one('SELECT * FROM routes WHERE (a_id = ? AND b_id = ?) OR (a_id = ? AND b_id = ?)', [$a, $b, $b, $a]);
$fixed = ['kind' => 'side', 'fixed' => 1, 'min_level' => 53, 'max_level' => 57, 'a_id' => 0, 'b_id' => 0];
$walkFrom = function (int $locId, int $routeId) use ($uid, $u) {
    q("DELETE FROM expeditions WHERE user_id = ? AND status = 'active'", [$uid]);
    q('UPDATE users SET location_id = ?, energy = 50 WHERE id = ?', [$locId, $uid]);
    return start_expedition($u(), $routeId);
};

echo "== world_v2_open = 0: the world as before\n";
ok('setting defaults to 0 on a fresh install', setting('world_v2_open') === '0');
ok('region levels are REGION_LEVELS', $lv() == REGION_LEVELS, json_encode($lv()));
ok('19 roads, road_pairs() = ROAD_PAIRS', (int)q_val('SELECT COUNT(*) FROM roads') === count(ROAD_PAIRS) && road_pairs() === ROAD_PAIRS);
ok('the importer skipped the world_v2 zones: no Maplewold zone 5 or 6, no Cattailmere', !q_val("SELECT 1 FROM zones z JOIN regions g ON g.id = z.region_id WHERE g.code = 'NA' AND z.zone_num > 4") && !$loc('Cattailmere') && !$loc('Granitegate'));
ok('route_danger caps a fixed route at 40', route_danger($u(), $fixed) === [40, 40, false]);
$before = $counts(); $sigBefore = $routeSig();
world_v2_boot();
ok('world_v2_boot() does nothing while off', $counts() === $before && $routeSig() === $sigBefore && setting('world_v2_done') !== '1');
$tunnelsZone = (int)$loc('Beaverdam Tunnels')['zone_num'];
ok('Beaverdam Tunnels is still in zone 2', $tunnelsZone === 2);

echo "== world_v2_open = 1: the boot step\n";
q("UPDATE regions SET min_level = 50 WHERE code = 'OC'");   // an admin raised Coralscatter above its band floor: never lowered
setg('world_v2_open', '1');
world_v2_boot();
ok('boot step done', setting('world_v2_done') === '1');
$L = $lv();
$want = REGION_LEVELS_V2; $want['OC'] = 50;
ok('region levels are the band floors (NA 1, CA/NWE 15, tier 3 25, tier 4 35, tier 5 45)', $L == $want, json_encode($L));
ok('a level above the band floor is never lowered (OC 50 stays)', (int)$L['OC'] === 50);
q("UPDATE regions SET min_level = 45 WHERE code = 'OC'");
foreach (['CB' => [1, [25, 27]], 'CA' => [4, [24, 25]], 'NA' => [5, [8, 11]], 'EA' => [2, [48, 50]]] as $c => [$z, $exp]) ok("zone ladder $c zone $z = " . implode('-', $exp), world_v2_zone_levels($c, $z) === $exp, json_encode(world_v2_zone_levels($c, $z)));

echo "== band ladder on the fixed side paths\n";
$owl = $loc('Den of the Great White Owl');
$owlRoad = q_one("SELECT rt.* FROM routes rt WHERE rt.kind = 'side' AND rt.b_id = ? AND rt.a_id IN (SELECT a_id FROM routes WHERE kind = 'road' UNION SELECT b_id FROM routes WHERE kind = 'road')", [$owl['id']]);
ok('the Owl\'s Den path from the road is Lv 13-17 (band top 15)', $owlRoad && (int)$owlRoad['level'] === 15 && (int)$owlRoad['min_level'] === 13 && (int)$owlRoad['max_level'] === 17, json_encode($owlRoad));
ok('the Great White Owl is Lv 15', (int)q_val('SELECT level FROM creatures WHERE slug = ?', ['boss-' . $owl['slug']]) === 15);
$ocLair = q_one("SELECT rt.* FROM routes rt JOIN landmarks lm ON lm.location_id = rt.b_id JOIN regions g ON g.id = lm.region_id WHERE g.code = 'OC' AND lm.kind = 'lair' AND rt.kind = 'side' LIMIT 1");
ok('a Coralscatter lair path is Lv 53-57', $ocLair && (int)$ocLair['min_level'] === 53 && (int)$ocLair['max_level'] === 57, json_encode($ocLair));
ok('route_danger lets it reach Lv 57 (cap 57 while on)', $ocLair && route_danger($u(), $ocLair) === [53, 57, false]);
$caWonder = q_one("SELECT rt.* FROM routes rt JOIN landmarks lm ON lm.location_id = rt.b_id JOIN zones z ON z.id = lm.zone_id JOIN regions g ON g.id = lm.region_id WHERE g.code = 'CA' AND lm.kind = 'wonder' AND z.zone_num = 2 AND rt.kind = 'side' LIMIT 1");
ok('a Maizehollow zone 2 wonder path is Lv 18-20', $caWonder && (int)$caWonder['min_level'] === 18 && (int)$caWonder['max_level'] === 20, json_encode($caWonder));

echo "== the two new roads\n";
ok('road_pairs() has 21 roads', count(road_pairs()) === 21);
$cross = [];
foreach (ROAD_PAIRS_V2 as [$a, $b]) {
    $ra = q_one('SELECT * FROM regions WHERE code = ?', [$a]); $rb = q_one('SELECT * FROM regions WHERE code = ?', [$b]);
    $road = q_one('SELECT * FROM roads WHERE name = ?', [$ra['gnomish_name'] . ' – ' . $rb['gnomish_name']]);
    $nodes = $road ? array_map('intval', json_decode($road['nodes'], true)) : [];
    $kinds = array_map(fn($id) => (string)q_val('SELECT kind FROM locations WHERE id = ?', [$id]), $nodes);
    ok("road $a-$b: town, 3 villages, town", $kinds === ['market', 'village', 'village', 'village', 'market'] && (int)q_val('SELECT region_id FROM locations WHERE id = ?', [$nodes[0]]) === (int)$ra['id'] && (int)q_val('SELECT region_id FROM locations WHERE id = ?', [$nodes[4]]) === (int)$rb['id'], json_encode($kinds));
    ok("road $a-$b: 4 road stretches of " . ROAD_STEPS . ' steps', (int)q_val("SELECT COUNT(*) FROM routes WHERE kind = 'road' AND road_id = ? AND steps = ?", [$road['id'] ?? 0, ROAD_STEPS]) === 4);
    ok("road $a-$b: its villages lost their old side path", !q_val("SELECT 1 FROM routes WHERE kind = 'side' AND b_id IN (?, ?, ?)", array_slice($nodes, 1, 3)));
    foreach (q("SELECT rt.* FROM routes rt JOIN locations x ON x.id = rt.a_id JOIN locations y ON y.id = rt.b_id WHERE rt.road_id = ? AND x.region_id <> y.region_id", [$road['id'] ?? 0])->fetchAll() as $rt) {
        $aRegion = (int)q_val('SELECT region_id FROM locations WHERE id = ?', [$rt['a_id']]);
        $cross[$a] = [$aRegion === (int)$ra['id'] ? (int)$rt['a_id'] : (int)$rt['b_id'], (int)$rt['id'], (int)$rb['id']];
    }
}
ok('next_region_suggestion still works', next_region_suggestion($u()) === null || isset(next_region_suggestion($u())['code']));
setg('seals_open', '1');
q('DELETE FROM region_seals WHERE user_id = ?', [$uid]);
q("UPDATE users SET guest = 0 WHERE id = ?", [$uid]);
foreach ($cross as $a => [$from, $routeId, $toRegion]) {
    q('DELETE FROM region_visits WHERE user_id = ? AND region_id = ?', [$uid, $toRegion]);
    q('DELETE FROM plots WHERE user_id = ? AND region_id = ?', [$uid, $toRegion]);
    [$okW, $msg] = $walkFrom($from, $routeId);
    ok("the border of road $a is a Seal door (walk refused without the Seal)", !$okW && str_contains($msg, 'Seal'), $msg);
}
setg('seals_open', '0');

echo "== the Maplewold: Beaverdam Fens and Cairnback Ridge\n";
foreach ([5 => ['Beaverdam Fens', 'wetland'], 6 => ['Cairnback Ridge', 'mountain']] as $zn => [$name, $land]) {
    $z = world_v2_zone('NA', $zn);
    ok("zone $zn $name ($land)", $z && $z['name'] === $name && $z['landscape'] === $land);
}
$honey = $loc('Honeybrook'); $poppy = $loc('Poppyburrow');
foreach (['Cattailmere' => ['herb', 'wetland', 5, $honey, 8, 11], 'Granitegate' => ['tower', 'mountain', 6, $poppy, 12, 15]] as $name => [$type, $land, $zn, $anchor, $min, $max]) {
    $v = $loc($name);
    ok("$name: village, $type, $land, zone $zn", $v && $v['kind'] === 'village' && $v['stop_type'] === $type && $v['landscape'] === $land && (int)$v['zone_num'] === $zn, json_encode($v));
    ok("$name is off the road", $v && !on_road((int)$v['id']));
    $leg = $v && $anchor ? $between((int)$anchor['id'], (int)$v['id']) : null;
    ok("$name: leg 1 from {$anchor['name']}, 2 sections, Lv $min-$max", $leg && $leg['kind'] === 'side' && (int)$leg['steps'] === 2 && (int)$leg['min_level'] === $min && (int)$leg['max_level'] === $max, json_encode($leg));
    ok("$name has its own blurb and an Almanac page", $v && village_blurb($v) === $v['description'] && q_val('SELECT 1 FROM encyclopedia_entries WHERE unlock_key = ?', ['village:' . $v['slug']]));
}
$catt = $loc('Cattailmere'); $gran = $loc('Granitegate');
foreach (['Heron Stilt Village' => [5, 'haven'], 'The Dam Debt' => [5, 'wonder'], 'Cairn Keeper\'s Hut' => [6, 'haven'], 'Cairnback Pass' => [6, 'wonder'], 'Hollow Peak' => [6, 'delve'], 'Ferry Landing' => [3, 'haven']] as $name => [$zn, $kind]) {
    $p = $loc($name);
    ok("$name: $kind in zone $zn with its Almanac page", $p && (int)$p['zone_num'] === $zn && q_val('SELECT kind FROM landmarks WHERE location_id = ?', [$p['id']]) === $kind && q_val('SELECT 1 FROM encyclopedia_entries WHERE unlock_key = ?', ['landmark:' . $p['slug']]));
}
$tun = $loc('Beaverdam Tunnels');
ok('Beaverdam Tunnels moved to the Fens: zone 5, a path from Cattailmere, the old path from Poppyburrow kept', (int)$tun['zone_num'] === 5 && $between((int)$catt['id'], (int)$tun['id']) && $between((int)$poppy['id'], (int)$tun['id']));
ok('the Fen Path loops to Pebblestead', (bool)$between((int)$catt['id'], (int)$loc('Pebblestead')['id']));
ok('the Aurora Road joins Aurora Camp and the Den', (bool)$between((int)$loc('Aurora Camp')['id'], (int)$owl['id']));
ok('the Tide Track: Lighthouse to Ferry Landing', (bool)$between((int)$loc('Lighthouse of the Lost Lantern')['id'], (int)$loc('Ferry Landing')['id']));

echo "== the doors on the paths out of the Maplewold\n";
$out = fn(array $from, string $code) => q_one("SELECT rt.* FROM routes rt JOIN locations l ON l.id = (CASE WHEN rt.a_id = ? THEN rt.b_id ELSE rt.a_id END) JOIN regions g ON g.id = l.region_id WHERE (rt.a_id = ? OR rt.b_id = ?) AND g.code = ?", [$from['id'], $from['id'], $from['id'], $code]);
$visible = fn(array $from, int $routeId) => array_values(array_filter(visible_routes($u(), (int)$from['id']), fn($r) => (int)$r['id'] === $routeId))[0] ?? null;
$rim = $out($owl, 'NWE');
ok('the Northern Rim Pass leads from the Den into Mistmoor, Lv 15-18', $rim && (int)$rim['min_level'] === 15 && (int)$rim['max_level'] === 18);
q('DELETE FROM landmark_clears WHERE user_id = ?', [$uid]);
$vr = $rim ? $visible($owl, (int)$rim['id']) : null;
ok('...signposted from the Den, closed until the Owl is beaten', $vr && str_contains($vr['gate'], 'Owl'), json_encode($vr['gate'] ?? null));
[$okR, $msgR] = $walkFrom((int)$owl['id'], (int)$rim['id']);
ok('...and the walk is refused', !$okR && str_contains($msgR, 'Owl'), $msgR);
db_insert('landmark_clears', ['user_id' => $uid, 'landmark_id' => (int)q_val('SELECT id FROM landmarks WHERE location_id = ?', [$owl['id']]), 'clears' => 1, 'first_at' => now(), 'last_at' => now()]);
ok('...open once the Owl is beaten', world_v2_door_refusal($uid, $owl, $loc(q_val('SELECT name FROM locations WHERE id = ?', [(int)$rim['a_id'] === (int)$owl['id'] ? $rim['b_id'] : $rim['a_id']])) ?: []) === '' && $visible($owl, (int)$rim['id'])['gate'] === '');
$high = $out($gran, 'CA');
ok('the Cairnback Climb high road leads from Granitegate into Maizehollow', (bool)$high);
$caEnd = q_one('SELECT * FROM locations WHERE id = ?', [(int)$high['a_id'] === (int)$gran['id'] ? $high['b_id'] : $high['a_id']]);
ok('...closed without the Maplewold Seal', str_contains(world_v2_door_refusal($uid, $gran, $caEnd), 'Maplewold Seal'));
ok('...the way back from Maizehollow is never closed', world_v2_door_refusal($uid, $caEnd, $gran) === '');
setg('seals_open', '1');
db_insert('region_seals', ['user_id' => $uid, 'region_id' => (int)$gran['region_id'], 'earned_at' => now()]);
ok('...open with the Maplewold Seal', world_v2_door_refusal($uid, $gran, $caEnd) === '');
$ferryLanding = $loc('Ferry Landing');
$ferry = $out($ferryLanding, 'CB');
$cbTown = q_one('SELECT * FROM locations WHERE id = ?', [(int)$ferry['a_id'] === (int)$ferryLanding['id'] ? $ferry['b_id'] : $ferry['a_id']]);
q('DELETE FROM region_visits WHERE user_id = ? AND region_id = ?', [$uid, $cbTown['region_id']]);
[$okF, $msgF] = $walkFrom((int)$ferryLanding['id'], (int)$ferry['id']);
ok('the Tide Track ferry to Sunsprinkle: with Seals on, the tier 3 Warden stops it without both tier 2 Seals', !$okF && str_contains($msgF, 'Seal'), $msgF);
setg('seals_open', '0');
ok('...with Seals off it is tide-locked', str_contains(world_v2_door_refusal($uid, $ferryLanding, $cbTown), 'tide'));
q('DELETE FROM region_seals WHERE user_id = ?', [$uid]);
q('DELETE FROM landmark_clears WHERE user_id = ?', [$uid]);

echo "== finding places along the Fen Path\n";
q("DELETE FROM user_encyclopedia WHERE user_id = ? AND entry_id = (SELECT id FROM encyclopedia_entries WHERE unlock_key = ?)", [$uid, 'village:' . $catt['slug']]);
ok('an unknown Cattailmere adds nothing to where a wander finds places', world_v2_discover_near($uid, [(int)$honey['id']]) === [(int)$honey['id']]);
unlock_entries($uid, 'village:' . $catt['slug']);
ok('once Cattailmere is known, wandering from Honeybrook can find what lies beyond it', in_array((int)$catt['id'], world_v2_discover_near($uid, [(int)$honey['id']]), true));
ok('a known Cattailmere shows on Honeybrook\'s routes', (bool)array_filter(visible_routes($u(), (int)$honey['id']), fn($r) => (int)$r['to']['id'] === (int)$catt['id']));

echo "== idempotent\n";
$after = $counts(); $sigAfter = $routeSig(); $lvAfter = $lv();
setg('world_v2_done', '0');
world_v2_boot();
ok('a second run adds and changes nothing', $counts() === $after && $routeSig() === $sigAfter && $lv() == $lvAfter, $after . ' / ' . $counts());
foreach (ROAD_PAIRS_V2 as [$a, $b]) ok("world_v2_lay_road($a, $b) again: the same road", world_v2_lay_road($a, $b) > 0 && $counts() === $after);

q("DELETE FROM expeditions WHERE user_id = ? AND status = 'active'", [$uid]);
echo $fails ? "$fails FAILED\n" : "all ok\n";
exit($fails ? 1 : 0);
