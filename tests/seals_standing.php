<?php
// 2.8.85 Seals and Expedition Standing (includes/seals.php): seals_open off = no change; the tier gates (GATE_NEEDS, Clovercove), grandfathering, guests,
// same-tier and down-tier roads always open (no trap), the Standing rows and their high-water marks, the Seal once at seal_threshold, the Warden text,
// the real road walk (start_expedition) and fast travel (travel_to) refusing at a closed door. Run by seals_standing.sh on a walk.sh install: php tests/seals_standing.php GAME
$_SERVER['SCRIPT_NAME'] = '/index.php';
require $argv[1] . '/includes/bootstrap.php';
require_once APP_ROOT . '/includes/seals.php';
require_once APP_ROOT . '/includes/adventure.php';
require_once APP_ROOT . '/includes/roads.php';
require_once APP_ROOT . '/includes/stops.php';
require_once APP_ROOT . '/includes/journey.php';
$fails = 0;
function ok(string $what, bool $cond, string $extra = ''): void { global $fails; echo ($cond ? 'ok   ' : 'FAIL ') . $what . ($cond ? '' : "  ($extra)") . "\n"; if (!$cond) $fails++; }
function setg(string $k, string $v): void { set_setting($k, $v); setting('__reload__'); }
$uid = (int)q_val("SELECT id FROM users WHERE username = 'sprout'");
ok('player sprout exists', $uid > 0);
$R = []; foreach (q('SELECT id, code FROM regions')->fetchAll() as $r) $R[$r['code']] = (int)$r['id'];
$u = fn() => q_one('SELECT * FROM users WHERE id = ?', [$uid]);
$clean = function () use ($uid) {
    foreach (['region_seals', 'region_standing_best', 'stop_prog', 'stop_log', 'user_quests', 'npc_friends', 'landmark_clears', 'stop_errands'] as $t) q("DELETE FROM $t WHERE user_id = ?", [$uid]);
    q('DELETE FROM stop_adoptions WHERE user_id = ? OR founder_id = ?', [$uid, $uid]);
};
$clean();
$naId = $R['NA'];
q('UPDATE users SET region_id = ?, guest = 0 WHERE id = ?', [$naId, $uid]);
q('DELETE FROM region_visits WHERE user_id = ? AND region_id <> ?', [$uid, $naId]);
q('DELETE FROM plots WHERE user_id = ? AND region_id <> ?', [$uid, $naId]);
$naTown = (int)q_val("SELECT id FROM locations WHERE region_id = ? AND kind = 'market' LIMIT 1", [$naId]);
q('UPDATE users SET location_id = ?, location = ? WHERE id = ?', [$naTown, 'The Maplewold', $uid]);
q("DELETE FROM expeditions WHERE user_id = ? AND status = 'active'", [$uid]);

echo "== the table is the master doc's\n";
ok('the Standing rows sum to 100', array_sum(array_column(STANDING_ROWS, 1)) === 100);
ok('every area has a tier', count(REGION_TIERS) === 14 && !array_diff(array_keys($R), array_keys(REGION_TIERS)), implode(',', array_keys($R)));
ok('every tier 3-5 area has a door in GATE_NEEDS', !array_diff(array_keys(array_filter(REGION_TIERS, fn($t) => $t >= 3)), array_keys(GATE_NEEDS)));

echo "== seals_open = 0: everything as before\n";
ok('setting defaults to 0 on a fresh install', setting('seals_open') === '0' && setting('seal_threshold') === '78');
setg('seals_open', '0');
$allOpen = true; foreach ($R as $c => $id) if (!region_gate_open($uid, $id)) $allOpen = false;
ok('every region is open', $allOpen);
ok('no door on CA -> CB', road_gate_open($uid, $R['CA'], $R['CB']) && seal_warden_message($uid, $R['CA'], $R['CB']) === '');
ok('no Seal is awarded while off', region_seal_check($uid, $naId) === false && !q_val('SELECT 1 FROM region_seals WHERE user_id = ?', [$uid]));
ok('standing card is not shown while off', standing_card_html($u(), $naId) === '');
ok('fast travel rule unchanged: CB not walked to = no fast travel (travel_needs_visit)', can_fast_travel($u(), $R['CB']) === (setting('travel_needs_visit') !== '1'));

echo "== seals_open = 1: the doors\n";
setg('seals_open', '1');
foreach (['NA', 'CA', 'NWE'] as $c) ok("tier 1/2 $c is open", region_gate_open($uid, $R[$c]));
ok('tier 3 CB closed with no Seals', !region_gate_open($uid, $R['CB']));
ok('CA -> CB road closed', !road_gate_open($uid, $R['CA'], $R['CB']));
$w = seal_warden_message($uid, $R['CA'], $R['CB']);
ok('Warden names the door and both Seals', str_contains($w, 'Tier 3 door: needs the Maizehollow and Mistmoor Seals'), $w);
ok('Warden lists the Standing of Maizehollow with missing rows', (bool)preg_match('/Maizehollow \d+%: .*Places found/', $w), $w);
echo "   warden: $w\n";
$give = fn(string $c) => db_insert('region_seals', ['user_id' => $uid, 'region_id' => $R[$c], 'earned_at' => now()]);
$give('CA');
ok('one tier 2 Seal is not enough', !region_gate_open($uid, $R['CB']) && !road_gate_open($uid, $R['NWE'], $R['SE']));
$give('NWE');
foreach (['CB', 'SA', 'SE', 'EE'] as $c) ok("both tier 2 Seals open tier 3 $c", region_gate_open($uid, $R[$c]));
ok('...and the CA -> CB road', road_gate_open($uid, $R['CA'], $R['CB']) && seal_warden_message($uid, $R['CA'], $R['CB']) === '');
ok('tier 4 MENA needs the SE Seal (from SE)', !road_gate_open($uid, $R['SE'], $R['MENA']) && str_contains(seal_warden_message($uid, $R['SE'], $R['MENA']), 'Olivewhistle Shore Seal'));
ok('new road CB -> WCA needs the CB Seal', !road_gate_open($uid, $R['CB'], $R['WCA']));
ok('new road SA -> ESA needs the SA Seal', !road_gate_open($uid, $R['SA'], $R['ESA']));
ok('EE -> CSA needs the EE Seal', !road_gate_open($uid, $R['EE'], $R['CSA']));
$give('SE');
ok('with the SE Seal: SE -> MENA open', road_gate_open($uid, $R['SE'], $R['MENA']) && region_gate_open($uid, $R['MENA']));
ok('the SE Seal does not open CSA', !region_gate_open($uid, $R['CSA']));
ok('inside tier 3: CB -> SA open', road_gate_open($uid, $R['CB'], $R['SA']));
ok('inside tier 4: MENA -> WCA open (the road, once in tier 4)', road_gate_open($uid, $R['MENA'], $R['WCA']));
ok('down a tier is never closed: MENA -> SE, CSA -> EE, EA -> CSA', road_gate_open($uid, $R['MENA'], $R['SE']) && road_gate_open($uid, $R['CSA'], $R['EE']) && road_gate_open($uid, $R['EA'], $R['CSA']));
ok('tier 5 EA from CSA needs the Spicepeak Seal', !road_gate_open($uid, $R['CSA'], $R['EA']) && str_contains(seal_warden_message($uid, $R['CSA'], $R['EA']), 'Spicepeak Seal'));
ok('SA -> OC needs any one tier 4 Seal', !road_gate_open($uid, $R['SA'], $R['OC']) && str_contains(seal_warden_message($uid, $R['SA'], $R['OC']), 'needs one Seal of'));
$give('ESA');
ok('...the ESA Seal is one: SA -> OC open', road_gate_open($uid, $R['SA'], $R['OC']));
ok('Clovercove NA -> EA needs all 14 Seals', !road_gate_open($uid, $R['NA'], $R['EA']) && str_contains(seal_warden_message($uid, $R['NA'], $R['EA']), 'all 14 area Seals'));
q('DELETE FROM region_seals WHERE user_id = ?', [$uid]);

echo "== grandfathering, guests, no trap\n";
db_insert('region_visits', ['user_id' => $uid, 'region_id' => $R['MENA'], 'first_at' => now()]);
ok('a region walked to before stays open', region_gate_open($uid, $R['MENA']) && road_gate_open($uid, $R['SE'], $R['MENA']));
ok('...and stays in accessible_regions (Puzzle Pals)', in_array($R['MENA'], accessible_regions($uid), true));
ok('...and its tier 4 sibling WCA opens by the inside road', region_gate_open($uid, $R['WCA']));
q('DELETE FROM region_visits WHERE user_id = ? AND region_id = ?', [$uid, $R['MENA']]);
ok('a region not walked to: closed again', !region_gate_open($uid, $R['MENA']));
q('UPDATE users SET region_id = ? WHERE id = ?', [$R['CB'], $uid]);
ok('the home region is always open', region_gate_open($uid, $R['CB']));
q('UPDATE users SET region_id = ? WHERE id = ?', [$naId, $uid]);
$plotDone = false;
if (q_val('SELECT 1 FROM plots WHERE user_id = ?', [$uid])) { $pl = (int)q_val('SELECT id FROM plots WHERE user_id = ? LIMIT 1', [$uid]); $old = (int)q_val('SELECT region_id FROM plots WHERE id = ?', [$pl]);
    q('UPDATE plots SET region_id = ? WHERE id = ?', [$R['SE'], $pl]); ok('a region with a garden is open', region_gate_open($uid, $R['SE'])); q('UPDATE plots SET region_id = ? WHERE id = ?', [$old, $pl]); $plotDone = true; }
if (!$plotDone) echo "skip garden grandfather check (sprout has no plot)\n";
q('UPDATE users SET guest = 1 WHERE id = ?', [$uid]);
ok('a guest is never gated', region_gate_open($uid, $R['CB']) && road_gate_open($uid, $R['CA'], $R['CB']));
q('UPDATE users SET guest = 0 WHERE id = ?', [$uid]);
$cbTown = (int)q_val("SELECT id FROM locations WHERE region_id = ? AND kind = 'market' LIMIT 1", [$R['CB']]);
q('UPDATE users SET location_id = ? WHERE id = ?', [$cbTown, $uid]);
ok('a gnome standing in a closed region (moved by admin): it counts as reached', region_gate_open($uid, $R['CB']));
ok('...and the way back CB -> CA is open', road_gate_open($uid, $R['CB'], $R['CA']));
q('UPDATE users SET location_id = ? WHERE id = ?', [$naTown, $uid]);

echo "== the real road walk and fast travel\n";
$cross = null;   // a road leg from a CA place into a CB place
foreach (q("SELECT r.*, la.region_id AS ra, lb.region_id AS rb FROM routes r JOIN locations la ON la.id = r.a_id JOIN locations lb ON lb.id = r.b_id WHERE r.kind = 'road'")->fetchAll() as $rt) {
    if ((int)$rt['ra'] === $R['CA'] && (int)$rt['rb'] === $R['CB']) { $cross = [(int)$rt['id'], (int)$rt['a_id']]; break; }
    if ((int)$rt['rb'] === $R['CA'] && (int)$rt['ra'] === $R['CB']) { $cross = [(int)$rt['id'], (int)$rt['b_id']]; break; }
}
if ($cross) {
    [$routeId, $caEnd] = $cross;
    q('UPDATE users SET location_id = ?, location = ?, energy = 50 WHERE id = ?', [$caEnd, 'Maizehollow', $uid]);
    [$okW, $msgW] = start_expedition($u(), $routeId);
    ok('start_expedition over the CA -> CB border is refused by the Warden', !$okW && str_contains($msgW, 'Warden'), $msgW);
    $routes = visible_routes($u(), $caEnd);
    $gated = array_values(array_filter($routes, fn($r) => (int)$r['id'] === $routeId));
    ok('the route list marks that road as a Seal door', $gated && $gated[0]['gate'] !== '');
    ok('the route list leaves the other roads unmarked', !array_filter($routes, fn($r) => (int)$r['id'] !== $routeId && $r['gate'] !== ''));
    setg('seals_open', '0');
    [$okW2, $msgW2] = start_expedition($u(), $routeId);
    ok('with seals_open = 0 the same walk starts', $okW2, $msgW2);
    ok('...and the route list has no Seal door', !array_filter(visible_routes($u(), $caEnd), fn($r) => $r['gate'] !== ''));
    q("DELETE FROM expeditions WHERE user_id = ? AND status = 'active'", [$uid]); q("DELETE FROM walk_scene WHERE user_id = ?", [$uid]);
    setg('seals_open', '1');
} else echo "skip road walk check (no CA-CB road leg in this world)\n";
q('UPDATE users SET location_id = ?, location = ?, coins = 100000, energy = 50 WHERE id = ?', [$naTown, 'The Maplewold', $uid]);
setg('travel_needs_visit', '0');
[$okT, $msgT] = travel_to($u(), $R['CB']);
ok('fast travel to a closed tier 3 region is refused by the Warden', !$okT && str_contains($msgT, 'Tier 3 door'), $msgT);
ok('can_fast_travel says no too (map, seek, calling trips)', !can_fast_travel($u(), $R['CB']));
ok('...while CA (tier 2) is fine', can_fast_travel($u(), $R['CA']));
setg('travel_needs_visit', '1');
$nx = next_region_suggestion($u());
ok('the next-region hint never points at a closed door', !$nx || region_gate_open($uid, (int)$nx['id']), json_encode($nx['code'] ?? null));

echo "== Standing rows\n";
$st0 = region_standing($uid, $naId);
ok('a fresh gnome is low in the Maplewold (< 30)', $st0['total'] < 30, (string)$st0['total']);
ok('the Seed Bed row is a TODO row at 0', $st0['rows']['seedbed']['todo'] && $st0['rows']['seedbed']['pts'] == 0);
// fill every row that has data, as a real gnome would
$villages = q("SELECT * FROM locations WHERE region_id = ? AND kind = 'village'", [$naId])->fetchAll();
$road = array_values(array_filter($villages, fn($v) => on_road((int)$v['id'])));
ok('the Maplewold has road villages to adopt', count($road) > 0, (string)count($road));
foreach ($road as $i => $v) {
    q('DELETE FROM stop_adoptions WHERE location_id = ?', [$v['id']]);
    db_insert('stop_adoptions', ['location_id' => $v['id'], 'user_id' => $i === 0 ? $uid : null, 'founder_id' => $uid, 'tier' => $i === 0 ? 4 : 1, 'pool' => '{}', 'adopted_at' => now()]);
    for ($k = 0; $k < 3; $k++) db_insert('stop_log', ['user_id' => $uid, 'location_id' => $v['id'], 'visit_key' => 'v' . $k, 'day' => '2026-01-0' . ($k + 1), 'act' => 'chat', 'kind' => 'check', 'at' => now()]);
}
$ch = q_one('SELECT * FROM quest_chapters WHERE region_id = ? AND active = 1 LIMIT 1', [$naId]);
if ($ch) db_insert('user_quests', ['user_id' => $uid, 'chapter_id' => $ch['id'], 'stage' => 9, 'started_at' => now(), 'done_at' => now()]);
foreach (q("SELECT * FROM locations WHERE region_id = ? AND kind NOT IN ('market','hub')", [$naId])->fetchAll() as $l) unlock_entries($uid, ($l['kind'] === 'village' ? 'village:' : 'landmark:') . $l['slug']);
foreach (q('SELECT DISTINCT plant_id FROM plant_regions WHERE region_id = ?', [$naId])->fetchAll(PDO::FETCH_COLUMN) as $pid) {
    q('DELETE FROM user_plant_knowledge WHERE user_id = ? AND plant_id = ?', [$uid, $pid]);
    db_insert('user_plant_knowledge', ['user_id' => $uid, 'plant_id' => $pid, 'knowledge' => 20]);
    unlock_entries($uid, 'plant:' . q_val('SELECT slug FROM plants WHERE id = ?', [$pid]));
}
$npc = (int)q_val('SELECT n.id FROM npcs n JOIN town_spots s ON s.id = n.fav_spot_id WHERE s.region = ? LIMIT 1', ['The Maplewold']);
if ($npc) db_insert('npc_friends', ['user_id' => $uid, 'npc_id' => $npc, 'points' => 120]);
$th = array_slice(stop_threads(), 0, 3, true);
foreach ($th as $tid => $t) db_insert('stop_prog', ['user_id' => $uid, 'location_id' => $road[0]['id'], 'k' => 'thread:' . $tid, 'n' => count($t['beats']), 'data' => '{}', 'updated_at' => now()]);
$folk = (int)q_val('SELECT f.id FROM stop_folk f JOIN locations l ON l.id = f.location_id WHERE l.region_id = ? LIMIT 1', [$naId]);
if ($folk) for ($k = 0; $k < 5; $k++) db_insert('stop_errands', ['user_id' => $uid, 'folk_id' => $folk, 'kind' => 'fetch', 'status' => 'done', 'offered_day' => '2026-01-0' . ($k + 1), 'expires_day' => '2026-01-0' . ($k + 1), 'done_at' => now(), 'created_at' => now()]);
foreach (['delve', 'lair'] as $kind) { $lm = (int)q_val('SELECT id FROM landmarks WHERE region_id = ? AND kind = ? LIMIT 1', [$naId, $kind]); if ($lm) landmark_record_clear($uid, $lm); }
$st = region_standing($uid, $naId);
$show = []; foreach ($st['rows'] as $k => $r) $show[] = "$k " . $r['pts'] . '/' . $r['max'];
echo '   rows: ' . implode(', ', $show) . "\n";
foreach ($st['rows'] as $k => $r) if (!$r['todo']) ok("row $k reaches full marks from the game's own data", abs($r['pts'] - $r['max']) < 0.01, $r['pts'] . '/' . $r['max']);
$maxLive = 100 - array_sum(array_map(fn($k) => STANDING_ROWS[$k][1], STANDING_TODO_ROWS));
ok("total = everything but the TODO rows ($maxLive)", abs($st['total'] - $maxLive) < 0.05, (string)$st['total']);
ok('a gnome who never fights (no delve, no lair) still clears 80', $st['total'] - 10 >= 80, (string)($st['total'] - 10));

echo "== high-water marks\n";
q('DELETE FROM stop_adoptions WHERE founder_id = ?', [$uid]);
q('DELETE FROM npc_friends WHERE user_id = ?', [$uid]);
$st2 = region_standing($uid, $naId);
ok('lit, raised, Hearth and Friend keep their best after the stops are lost', $st2['rows']['lit']['pts'] == 14 && $st2['rows']['raised']['pts'] == 10 && $st2['rows']['hearth']['pts'] == 6 && $st2['rows']['friend']['pts'] == 5);
ok('...while the live value shows 0', $st2['rows']['lit']['live'] == 0 && $st2['rows']['friend']['live'] == 0);
ok('the total does not go down', abs($st2['total'] - $st['total']) < 0.01);

echo "== the Seal\n";
q('DELETE FROM notices WHERE user_id = ?', [$uid]);
setg('seals_open', '0');
ok('no Seal while off, even at ' . $st['total'] . '%', !region_seal_check($uid, $naId));
setg('seals_open', '1');
setg('seal_threshold', '95');
ok('seal_threshold 95: not yet', !region_seal_check($uid, $naId) && !seal_held($uid, $naId));
setg('seal_threshold', '78');
ok('at the default 80: the Seal is awarded', region_seal_check($uid, $naId) && seal_held($uid, $naId));
ok('...only once (idempotent)', !region_seal_check($uid, $naId) && (int)q_val('SELECT COUNT(*) FROM region_seals WHERE user_id = ? AND region_id = ?', [$uid, $naId]) === 1);
ok('...with one notice', (int)q_val("SELECT COUNT(*) FROM notices WHERE user_id = ? AND text LIKE '%Maplewold Seal is yours%'", [$uid]) === 1);
ok('the Almanac line says so', str_contains(seal_almanac_line($uid, $naId), 'Maplewold Seal: bound by Wren'));
$card = standing_card_html($u(), $naId);
ok('the Standing card shows the bar, the rows and the Seal', str_contains($card, 'Expedition Standing') && str_contains($card, '<progress') && str_contains($card, 'Seal is yours') && substr_count($card, '<tr') === count(STANDING_ROWS) + 1);
ok('the Standing card for an unsealed area shows what is left', str_contains(standing_card_html($u(), $R['CA']), 'points to go'));
ok('a road door checks the Seal on the way (CA earned at the door)', (function () use ($uid, $R) {
    q('DELETE FROM region_standing_best WHERE user_id = ? AND region_id = ?', [$uid, $R['CA']]);
    foreach (array_keys(STANDING_ROWS) as $k) db_insert('region_standing_best', ['user_id' => $uid, 'region_id' => $R['CA'], 'row_key' => $k, 'pts100' => STANDING_ROWS[$k][1] * 100, 'updated_at' => now()]);
    road_gate_open($uid, $R['CA'], $R['CB']);   // needs CA and NWE: CA's Standing is full (high-water rows) -> awarded here
    return seal_held($uid, $R['CA']) && !seal_held($uid, $R['NWE']) && !road_gate_open($uid, $R['CA'], $R['CB']);
})());

$clean();
q('DELETE FROM notices WHERE user_id = ?', [$uid]);
setg('seals_open', '0');
echo $fails ? "$fails FAILED\n" : "all ok\n";
exit($fails ? 1 : 0);
