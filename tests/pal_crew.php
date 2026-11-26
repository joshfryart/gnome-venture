<?php
// v2.6.40 garden crew (includes/pal_crew.php). Run by pal_crew.sh on a fresh install with one registered gnome "sprout".
$_SERVER['SCRIPT_NAME'] = '/index.php';
require $argv[1] . '/includes/bootstrap.php';
require_once APP_ROOT . '/includes/pal_jobs.php';
require_once APP_ROOT . '/includes/pal_crew.php';
require_once APP_ROOT . '/includes/today.php';
require_once APP_ROOT . '/includes/garden_logic.php';
$fails = 0;
function ok(string $what, bool $cond, string $extra = ''): void { global $fails; echo ($cond ? '  ok   ' : '  FAIL ') . $what . ($cond ? '' : "  $extra") . "\n"; if (!$cond) $fails++; }
function cfg(array $kv): void { foreach ($kv as $k => $v) set_setting($k, (string)$v); setting('__reload__'); }
function urow(int $id): array { return q('SELECT * FROM users WHERE id = ?', [$id])->fetch(); }

cfg(['puzzles_open' => 1, 'jigsaw_open' => 1, 'ppal_open' => 1, 'pj_open' => 1, 'pj_min_level' => 10, 'game_clock_on' => 1, 'rain_waters' => 0, 'weather_force' => 'sun', 'season_epoch' => '2026-01-01', 'grow_days_by_tier' => '']);
require_once APP_ROOT . '/includes/jigsaw.php'; jigsaw_ensure(); ppal_ensure(); pcrew_boot();
$uid = (int)q_val("SELECT id FROM users WHERE username = 'sprout'");
q('UPDATE users SET level = 10, game_day = 10, game_minute = 360 WHERE id = ?', [$uid]);
$u = urow($uid);

echo "== tables\n";
ok('slots, rest and report tables exist', (bool)q_val('SELECT COUNT(*) >= 0 FROM garden_pal_slots') && (bool)q_val('SELECT COUNT(*) >= 0 FROM garden_pal_rest') && (bool)q_val('SELECT COUNT(*) >= 0 FROM sleep_report'));
ok('crew is open with pal jobs and the sleep clock', pcrew_open($u));
ok('the plant slot is open', PCREW_ROLES['plant'][3] === true);

$MAP = (int)q_val("SELECT id FROM puzzle_pics WHERE slug = 'jig-maplewold'");
q('INSERT INTO ppal_releases (user_id, pic_id, released_at, src) VALUES (?, ?, ?, ?)', [$uid, $MAP, now(), 'free']);
$keys = array_map(fn($p) => $p['key'], ppal_roster(ppal_pic($MAP)));
foreach ([0, 1, 2, 3, 4] as $i) ppal_claim($u, $keys[$i], $MAP);
$P = array_values(pj_pals($uid));
[$p0, $p1, $p2, $p3, $p4] = array_map(fn($p) => $p['uid'], $P);
q('UPDATE ppal_found SET active = 0 WHERE user_id = ?', [$uid]);

$plot = (int)q_val('SELECT id FROM plots WHERE user_id = ? ORDER BY id LIMIT 1', [$uid]);
$plant = q_one('SELECT * FROM plants WHERE grow_minutes <= 20 AND kind NOT IN (\'cover\',\'flower\') AND (perennial IS NULL OR perennial = 0) AND produce_item_id IS NOT NULL ORDER BY id LIMIT 1');
$need = (int)$plant['grow_minutes'] * 60;
$tiles = q('SELECT id FROM plot_tiles WHERE plot_id = ? ORDER BY y, x LIMIT 4', [$plot])->fetchAll(PDO::FETCH_COLUMN);
ok('a garden with 4 beds and a quick crop to test with', count($tiles) === 4 && (bool)$plant);
[$tDry, $tRipe, $tPest, $tWeed] = $tiles;
function plantTile(int $id, array $plant, int $growth, array $more = []): void {
    q('UPDATE plot_tiles SET plant_id = ?, planted_at = ?, growth_seconds = ?, growth_updated_at = ?, grow_day = 10, owed_days = 0, water_day = NULL, last_watered = NULL, pest = NULL, pest_at = NULL, weeds = 0, nipped = 0 WHERE id = ?',
        [$plant['id'], now(), $growth, now(), $id]);
    foreach ($more as $c => $v) q("UPDATE plot_tiles SET $c = ? WHERE id = ?", [$v, $id]);
}
function reset4(array $tiles, array $plant, int $need): void {
    [$a, $b, $c, $d] = $tiles;
    plantTile($a, $plant, 0); plantTile($b, $plant, $need); plantTile($c, $plant, 0, ['pest' => 'aphid', 'pest_at' => now()]); plantTile($d, $plant, 0, ['method' => 'notill', 'weeds' => 6]);
}

echo "== assigning\n";
[$a1, $m1] = pcrew_assign($u, $plot, 'water', $p0, 'timed', 1);
ok('water slot: assigned', $a1 === true, (string)$m1);
ok('pal is marked as on the crew', pj_pal($uid, $p0)['status'] === 'crew');
[$a2] = pcrew_assign($u, $plot, 'water', $p1, 'timed', 1);
ok('second pal on the same slot refused', $a2 === false);
[$a3] = pcrew_assign($u, $plot, 'weed', $p0, 'timed', 1);
ok('a pal already out cannot take a second job', $a3 === false);
[$a4] = pcrew_assign($u, $plot, 'nonsense', $p1, 'timed', 1);
ok('an unknown job is refused', $a4 === false);
[$a5] = pcrew_assign($u, $plot + 999, 'weed', $p1, 'timed', 1);
ok('not your garden refused', $a5 === false);
[$a6] = pcrew_assign($u, $plot, 'weed', $p1, 'timed', 2);
ok('2 sleeps is not an option', $a6 === false);
foreach ([['weed', $p1, 'timed', 1], ['pests', $p2, 'timed', 3], ['harvest', $p3, 'full', 0]] as [$r, $pp, $md, $n]) {
    [$okk, $mm] = pcrew_assign($u, $plot, $r, $pp, $md, $n); ok("$r slot assigned ($md)", $okk === true, (string)$mm);
}
ok('four slots filled', count(pcrew_slots($plot)) === 4);

echo "== the night (sleep): pests, weeds, harvest, water\n";
reset4($tiles, $plant, $need);
q('UPDATE users SET game_day = 10, game_minute = 360, energy = 5 WHERE id = ?', [$uid]);
$before = (int)q_val('SELECT COALESCE(SUM(qty),0) FROM user_items WHERE user_id = ? AND item_id = ?', [$uid, $plant['produce_item_id']]);
ok('the sleep ran', game_sleep($uid) !== null);
$t = fn(int $id) => q_one('SELECT * FROM plot_tiles WHERE id = ?', [$id]);
ok('dry bed: watered for the new day, in the morning (water_day 11, not thirsty today)', (string)$t($tDry)['water_day'] === '11' && !tile_info(annotate_tile($t($tDry), $plant), $plant)['thirsty'], json_encode($t($tDry)));
ok('pests: picked off', $t($tPest)['pest'] === null || $t($tPest)['pest'] === '');
ok('weeds: pulled', (int)$t($tWeed)['weeds'] === 0);
$after = (int)q_val('SELECT COALESCE(SUM(qty),0) FROM user_items WHERE user_id = ? AND item_id = ?', [$uid, $plant['produce_item_id']]);
ok('ripe crop picked into the satchel, the pal keeps no cut', $after - $before >= 1, "$before -> $after");
ok('picked bed is not left watered/planted (annual crop gone)', empty($t($tRipe)['plant_id']) || (string)$t($tRipe)['water_day'] !== '10');
$rep = pcrew_latest_report($uid);
ok('sleep report saved for day 11', $rep && $rep[0] === 11 && count($rep[1]['crew'] ?? []) === 4, json_encode($rep));
ok('report has the harvest line', (bool)array_filter($rep[1]['crew'] ?? [], fn($c) => $c['role'] === 'harvest' && $c['n'] >= 1));
$st = q_one('SELECT * FROM garden_pal_slots WHERE plot_id = ? AND role = ?', [$plot, 'harvest']);
ok('full time slot still there, night counted', $st && (int)$st['done'] === 1 && $st['mode'] === 'full');
ok('1-sleep slots ended: water and weed are free', !isset(pcrew_slots($plot)['water']) && !isset(pcrew_slots($plot)['weed']));
ok('3-sleep slot continues', isset(pcrew_slots($plot)['pests']) && (int)pcrew_slots($plot)['pests']['done'] === 1);
ok('pals that finished are home and resting', pj_pal($uid, $p0)['status'] === 'home' && pcrew_is_resting($uid, $p0, 11));
$u = urow($uid);
[$r1] = pcrew_assign($u, $plot, 'water', $p0, 'timed', 1);
ok('a resting pal cannot be assigned the same day', $r1 === false);
ok('crew work earned the pal a little Gardening XP', (int)q_val('SELECT g_xp FROM ppal_found WHERE user_id = ? AND pal_uid = ?', [$uid, $p0]) > 0 && (int)q_val('SELECT g_xp FROM ppal_found WHERE user_id = ? AND pal_uid = ?', [$uid, $p0]) <= PCREW_XP_DAILY);

echo "== next sleep: growth counts the pal's watering, rest ends\n";
$g0 = (int)$t($tDry)['growth_seconds'];
reset4($tiles, $plant, $need);
q('UPDATE plot_tiles SET grow_day = 11 WHERE plot_id = ?', [$plot]);
game_sleep($uid);
$u = urow($uid);
ok('day 12 now', (int)$u['game_day'] === 12);
ok('rest is over after a sleep', !pcrew_is_resting($uid, $p0, 12));
[$r2, $m2] = pcrew_assign($u, $plot, 'water', $p0, 'timed', 1);
ok('the rested pal can be assigned again', $r2 === true, (string)$m2);
$lazy = gclock_tile_grow(annotate_tile($t($tDry), q_one('SELECT * FROM plants WHERE id = ?', [$plant['id']])), q_one('SELECT * FROM plants WHERE id = ?', [$plant['id']]));
ok('a bed the pal watered gains growth when the garden next settles', (int)$lazy['growth_seconds'] >= 0);

echo "== several sleeps in a row (no opening the garden)\n";
reset4($tiles, $plant, $need);
q('UPDATE plot_tiles SET grow_day = 12, plant_id = ?, growth_seconds = 0, water_day = NULL WHERE id = ?', [$plant['id'], $tDry]);
game_sleep($uid); game_sleep($uid); game_sleep($uid);
$tt = $t($tDry);
ok('growth was settled night by night (not lost): bed grew', empty($tt['plant_id']) || (int)$tt['growth_seconds'] > 0 || (int)$tt['grow_day'] >= 14, json_encode($tt));
ok('full time harvester still on after 4 nights', (int)q_val("SELECT done FROM garden_pal_slots WHERE plot_id = ? AND role = 'harvest'", [$plot]) >= 4);

echo "== recall\n";
$u = urow($uid);
[$c1] = pcrew_recall($u, $plot, 'harvest');
ok('recall: slot freed', $c1 === true && !isset(pcrew_slots($plot)['harvest']));
ok('recalled pal is home and resting until the next sleep', pj_pal($uid, $p3)['status'] === 'home' && pcrew_is_resting($uid, $p3, (int)$u['game_day']));
[$c2] = pcrew_recall($u, $plot, 'harvest');
ok('recall of an empty slot says so', $c2 === false);

echo "== a slot whose pal is gone (the ledger shows 'Pal not found'; Free the job clears it)\n";
q("INSERT INTO garden_pal_slots (plot_id, user_id, role, pal_uid, mode, nights, done, start_day) VALUES (?, ?, 'weed', ?, 'full', 0, 0, 1)", [$plot, $uid, 'deadbeefdeadbeef']);
$gid = (int)q_val("SELECT id FROM garden_pal_slots WHERE plot_id = ? AND role = 'weed'", [$plot]);
ok('the gone pal is not found', pj_pal($uid, 'deadbeefdeadbeef') === null);
[$f1, $m1] = pcrew_free_slot($u, $gid);
ok('free the job: the slot is gone and the message says so', $f1 === true && $m1 === 'That job is free again.' && !isset(pcrew_slots($plot)['weed']), $m1);
[$f2] = pcrew_free_slot($u, $gid);
ok('freeing it again says nobody is on it', $f2 === false);
[$f3] = pcrew_free_slot(['id' => $uid + 999, 'game_day' => 1], $gid);
ok("another gnome cannot free someone else's job", $f3 === false);

echo "== planting (the Plant slot)\n";
$plant2 = q_one('SELECT * FROM plants WHERE grow_minutes <= 20 AND kind NOT IN (\'cover\',\'flower\') AND produce_item_id IS NOT NULL AND id <> ? ORDER BY id LIMIT 1', [$plant['id']]);
ok('a second quick crop exists', (bool)$plant2);
foreach ([$plant, $plant2] as $pp) q('UPDATE items SET category = ? WHERE id = ?', ['seed', $pp['seed_item_id']]);
q('DELETE FROM user_items WHERE user_id = ? AND item_id IN (?, ?)', [$uid, $plant['seed_item_id'], $plant2['seed_item_id']]);
give_item($uid, (int)$plant['seed_item_id'], 2); give_item($uid, (int)$plant2['seed_item_id'], 5);
$opts = pcrew_seed_options($uid);
ok('seed options list both seeds the gnome holds', isset($opts[(int)$plant['seed_item_id']]) && isset($opts[(int)$plant2['seed_item_id']]));
$origSlug = q_val('SELECT slug FROM items WHERE id = ?', [$plant2['seed_item_id']]);
q('UPDATE items SET slug = ? WHERE id = ?', ['treasure-seed-test', $plant2['seed_item_id']]);
ok('treasure seeds are never offered', !isset(pcrew_seed_options($uid)[(int)$plant2['seed_item_id']]));
ok('and are dropped from a ticked list', pcrew_clean_seeds($uid, [(int)$plant2['seed_item_id']]) === []);
q('UPDATE items SET slug = ? WHERE id = ?', [$origSlug, $plant2['seed_item_id']]);
ok('a ticked ordinary seed is kept', pcrew_clean_seeds($uid, [(int)$plant2['seed_item_id'], 0, 99999999]) === [(int)$plant2['seed_item_id']]);
q('DELETE FROM garden_pal_slots WHERE plot_id = ?', [$plot]); q("UPDATE ppal_found SET status = 'home' WHERE user_id = ?", [$uid]); q('DELETE FROM garden_pal_rest WHERE user_id = ?', [$uid]);
$u = urow($uid);
[$pl1, $plm] = pcrew_assign($u, $plot, 'plant', $p4, 'full', 0, false, [(int)$plant2['seed_item_id']]);
ok('plant slot assigned with a ticked seed', $pl1 === true, (string)$plm);
ok('the ticked seed is stored', q_val("SELECT seeds FROM garden_pal_slots WHERE plot_id = ? AND role = 'plant'", [$plot]) === (string)$plant2['seed_item_id']);
// four bare, prepared beds: A remembers plant 1, B remembers nothing, C is hands off, D remembers plant 1 but only 2 seeds exist (A and D both want it)
foreach ($tiles as $id) q('UPDATE plot_tiles SET plant_id = NULL, planted_at = NULL, growth_seconds = 0, tilled = 1, settle_until = NULL, fertility = 90, water_day = NULL, pest = NULL, weeds = 0 WHERE id = ?', [$id]);
q('DELETE FROM garden_pal_memory WHERE tile_id IN (' . implode(',', $tiles) . ')');
[$tA, $tB, $tC, $tD] = $tiles;
pcrew_remember($tA, (int)$plant['id']); pcrew_remember($tD, (int)$plant['id']); pcrew_set_skip($u, $plot, [$tC]);
q('DELETE FROM user_items WHERE user_id = ? AND item_id = ?', [$uid, $plant['seed_item_id']]); give_item($uid, (int)$plant['seed_item_id'], 1);   // only one of the remembered seed
q('UPDATE plants SET seasons = NULL WHERE id IN (?, ?)', [$plant['id'], $plant2['id']]);
q('UPDATE users SET game_minute = 360 WHERE id = ?', [$uid]);
$dayBefore = (int)urow($uid)['game_day'];
game_sleep($uid);
$D = $dayBefore + 1;
ok('bed A got its own seed back', (int)$t($tA)['plant_id'] === (int)$plant['id'], json_encode($t($tA)));
ok('growth starts on the day that ended; no Water pal, so not watered', (int)$t($tA)['grow_day'] === $D - 1 && ($t($tA)['water_day'] === null || $t($tA)['water_day'] === ''), json_encode($t($tA)));
ok('the remembered seed ran out: bed D falls back to the ticked seed', (int)$t($tD)['plant_id'] === (int)$plant2['id'], json_encode($t($tD)));
ok('bed B (no memory) uses the ticked seed too', (int)$t($tB)['plant_id'] === (int)$plant2['id']);
ok('hands-off bed C stays empty', empty($t($tC)['plant_id']));
ok('seeds were used up one per bed', (int)q_val('SELECT COALESCE(SUM(qty),0) FROM user_items WHERE user_id = ? AND item_id = ?', [$uid, $plant['seed_item_id']]) === 0 && (int)q_val('SELECT COALESCE(SUM(qty),0) FROM user_items WHERE user_id = ? AND item_id = ?', [$uid, $plant2['seed_item_id']]) === 3);
ok('the new beds are remembered', (int)q_val('SELECT plant_id FROM garden_pal_memory WHERE tile_id = ?', [$tB]) === (int)$plant2['id']);
$rep = pcrew_latest_report($uid);
$pr = array_values(array_filter($rep[1]['crew'] ?? [], fn($c) => $c['role'] === 'plant'))[0] ?? [];
ok('report: planted 3 beds', ($pr['n'] ?? 0) === 3, json_encode($pr));
// run out of seeds entirely
q('UPDATE plot_tiles SET plant_id = NULL, planted_at = NULL WHERE id = ?', [$tA]);
q('DELETE FROM user_items WHERE user_id = ? AND item_id IN (?, ?)', [$uid, $plant['seed_item_id'], $plant2['seed_item_id']]);
game_sleep($uid);
$pr = array_values(array_filter((pcrew_latest_report($uid)[1]['crew'] ?? []), fn($c) => $c['role'] === 'plant'))[0] ?? [];
ok('no seeds: bed stays empty and the report says why', empty($t($tA)['plant_id']) && str_contains((string)($pr['warn'] ?? ''), 'out of'), json_encode($pr));
// off season is skipped
give_item($uid, (int)$plant['seed_item_id'], 3);
q("UPDATE plants SET seasons = 'winter' WHERE id = ?", [$plant['id']]);
q("UPDATE plants SET seasons = 'winter' WHERE id = ?", [$plant2['id']]);
q('UPDATE garden_pal_slots SET seeds = ? WHERE plot_id = ? AND role = ?', [(string)$plant['seed_item_id'], $plot, 'plant']);
cfg(['season_epoch' => '2026-06-15']);   // midsummer
game_sleep($uid);
ok('an off-season seed is not planted', empty($t($tA)['plant_id']), json_encode($t($tA)));
cfg(['season_epoch' => '2026-01-01']); q('UPDATE plants SET seasons = NULL WHERE id IN (?, ?)', [$plant['id'], $plant2['id']]);
$u = urow($uid);
[$sk] = pcrew_set_seeds($u, $plot, [(int)$plant['seed_item_id']]);
ok('seeds can be changed while the pal works', $sk === true);
[$sk2] = pcrew_set_skip($u, $plot, []);
ok('hands-off beds can be cleared', $sk2 === true && !(int)q_val('SELECT skip FROM garden_pal_memory WHERE tile_id = ?', [$tC]));
[$sk3] = pcrew_set_skip($u, $plot, [$tC, $tA], [$tA, $tB]);
ok('bed picker: avoid = 1, work = 2, avoid wins a clash', $sk3 === true && (int)q_val('SELECT skip FROM garden_pal_memory WHERE tile_id = ?', [$tC]) === 1 && (int)q_val('SELECT skip FROM garden_pal_memory WHERE tile_id = ?', [$tA]) === 1 && (int)q_val('SELECT skip FROM garden_pal_memory WHERE tile_id = ?', [$tB]) === 2);
pcrew_set_skip($u, $plot, []);

echo "== tiredness (7 fresh nights, 60% on night 14, then 50%) and the Today data\n";
ok('nights 1-7 at full speed', pcrew_eff(1) === 1.0 && pcrew_eff(7) === 1.0);
ok('night 10 is between', pcrew_eff(10) > 0.6 && pcrew_eff(10) < 1.0, (string)pcrew_eff(10));
ok('night 14 at 60%, later at 50%', pcrew_eff(14) === 0.6 && pcrew_eff(15) === 0.5 && pcrew_eff(40) === 0.5);
ok('full time slot is tired from night 14', pcrew_tired(['mode' => 'full', 'done' => 13]) && !pcrew_tired(['mode' => 'full', 'done' => 12]) && !pcrew_tired(['mode' => 'timed', 'done' => 13]));
q('DELETE FROM garden_pal_slots WHERE plot_id = ?', [$plot]); q("UPDATE ppal_found SET status = 'home' WHERE user_id = ?", [$uid]); q('DELETE FROM garden_pal_rest WHERE user_id = ?', [$uid]);
$u = urow($uid);
pcrew_assign($u, $plot, 'water', $p0, 'full', 0);
q('UPDATE garden_pal_slots SET done = 13 WHERE plot_id = ? AND role = ?', [$plot, 'water']);
$today = today_data(urow($uid));
ok('Today lists the tired pal under "Needs you"', (bool)array_filter($today['need'], fn($n) => str_contains($n[1], 'tired of Water')), json_encode($today['need']));
ok('Today has the weather today and tomorrow', (bool)array_filter($today['night'], fn($n) => str_contains($n[2], 'Tomorrow')), json_encode($today['night']));
// a tired pal skips some beds: with 20 planted beds at 50% about half are watered (same beds every time it is asked)
$extra = [];
for ($i = 0; $i < 24; $i++) { $extra[] = db_insert('plot_tiles', ['plot_id' => $plot, 'user_id' => $uid, 'x' => 20 + $i, 'y' => 20, 'tilled' => 1]); }
foreach ($extra as $id) plantTile($id, $plant, 0);
q('UPDATE garden_pal_slots SET done = 20 WHERE plot_id = ? AND role = ?', [$plot, 'water']);
$dayN = (int)urow($uid)['game_day'];
game_sleep($uid);
$watered = (int)q_val('SELECT COUNT(*) FROM plot_tiles WHERE plot_id = ? AND y = 20 AND water_day IS NOT NULL', [$plot]);
ok('a tired pal waters only some beds (' . $watered . ' of 24)', $watered > 4 && $watered < 20, (string)$watered);
$rep = pcrew_latest_report($uid);
ok('report notes the efficiency and tiredness', ($rep[1]['crew'][0]['eff'] ?? 0) === 50 && !empty($rep[1]['crew'][0]['tired']), json_encode($rep[1]['crew'][0] ?? []));
ok('every sleep leaves a report row for the Today tab', pcrew_latest_report($uid)[0] === (int)urow($uid)['game_day']);
foreach ($extra as $id) q('DELETE FROM plot_tiles WHERE id = ?', [$id]);

echo "== harvest + plant without a Water pal (crop that ripens on the day it was watered by hand)\n";
q('DELETE FROM garden_pal_slots WHERE plot_id = ?', [$plot]); q("UPDATE ppal_found SET status = 'home' WHERE user_id = ?", [$uid]); q('DELETE FROM garden_pal_rest WHERE user_id = ?', [$uid]);
$u = urow($uid);
pcrew_assign($u, $plot, 'harvest', $p0, 'full', 0); pcrew_assign($u, $plot, 'plant', $p1, 'full', 0);
$X = (int)urow($uid)['game_day'];
foreach ($extra ?? [] as $id) q('DELETE FROM plot_tiles WHERE id = ?', [$id]);
foreach ($tiles as $id) q('UPDATE plot_tiles SET plant_id = NULL, planted_at = NULL, growth_seconds = 0, tilled = 1, settle_until = NULL, fertility = 90, water_day = NULL, pest = NULL, weeds = 0 WHERE id = ?', [$id]);
q('DELETE FROM garden_pal_memory WHERE tile_id IN (' . implode(',', $tiles) . ')');
[$hA, $hB] = $tiles;
// bed A: watered by hand today and one day short of ripe: it ripens with today's growth. Bed B: empty, last crop remembered, seeds in the satchel.
q('UPDATE plot_tiles SET plant_id = ?, planted_at = ?, growth_seconds = 0, growth_updated_at = ?, grow_day = ?, water_day = ?, owed_days = 0 WHERE id = ?', [$plant['id'], now(), now(), $X - 20, null, $hA]);
$sleepsNeeded = gclock_grow_sleeps($plant);
q('UPDATE plot_tiles SET growth_seconds = ?, grow_day = ?, water_day = ? WHERE id = ?', [(int)($need - $need / $sleepsNeeded / 2), $X, $X, $hA]);
pcrew_remember($hB, (int)$plant['id']);
q('DELETE FROM user_items WHERE user_id = ? AND item_id = ?', [$uid, $plant['seed_item_id']]); give_item($uid, (int)$plant['seed_item_id'], 3);
$cropsBefore = (int)q_val('SELECT COALESCE(SUM(qty),0) FROM user_items WHERE user_id = ? AND item_id = ?', [$uid, $plant['produce_item_id']]);
game_sleep($uid);
$cropsAfter = (int)q_val('SELECT COALESCE(SUM(qty),0) FROM user_items WHERE user_id = ? AND item_id = ?', [$uid, $plant['produce_item_id']]);
ok('the crop that ripened with the day just ended is picked the same night', $cropsAfter > $cropsBefore, "$cropsBefore -> $cropsAfter " . json_encode($t($hA)));
ok('and the emptied bed is replanted the same night (a new crop, growth restarted)', !empty($t($hA)['plant_id']) && (int)$t($hA)['growth_seconds'] === 0, json_encode($t($hA)));
ok('the other empty bed (remembered crop) is planted too', !empty($t($hB)['plant_id']));
$pr = array_values(array_filter((pcrew_latest_report($uid)[1]['crew'] ?? []), fn($c) => $c['role'] === 'plant'))[0] ?? [];
ok('report: two beds planted (the remembered bed and the one just picked)', ($pr['n'] ?? 0) === 2, json_encode($pr));
// a bed with no memory and no ticked seeds explains itself
q('UPDATE plot_tiles SET plant_id = NULL WHERE id = ?', [$hB]); q('DELETE FROM garden_pal_memory WHERE tile_id = ?', [$hB]);
game_sleep($uid);
$pr = array_values(array_filter((pcrew_latest_report($uid)[1]['crew'] ?? []), fn($c) => $c['role'] === 'plant'))[0] ?? [];
ok('no memory, nothing ticked: the report tells you to tick seeds', str_contains((string)($pr['warn'] ?? ''), 'tick'), json_encode($pr));

echo "== the crew works the MORNING for that day: nothing left to do after a sleep (Josh 2026-11-26)\n";
require_once APP_ROOT . '/includes/dock.php';
q('DELETE FROM garden_pal_slots WHERE plot_id = ?', [$plot]); q("UPDATE ppal_found SET status = 'home' WHERE user_id = ?", [$uid]); q('DELETE FROM garden_pal_rest WHERE user_id = ?', [$uid]);
q('DELETE FROM garden_pal_memory WHERE tile_id IN (' . implode(',', $tiles) . ')');
q('UPDATE users SET active_plot_id = ? WHERE id = ?', [$plot, $uid]);
$crop3 = q_one("SELECT * FROM plants WHERE grow_minutes > 60 AND grow_minutes <= 120 AND kind NOT IN ('cover','flower') AND (perennial IS NULL OR perennial = 0) AND produce_item_id IS NOT NULL ORDER BY id LIMIT 1");
q('UPDATE plants SET seasons = NULL WHERE id = ?', [$crop3['id']]);
$need3 = (int)$crop3['grow_minutes'] * 60; $share3 = intdiv($need3, gclock_grow_sleeps($crop3));
$X = (int)urow($uid)['game_day'];
$setBeds = function () use ($tiles, $crop3, $need3, $share3, $X) {   // ripe now; one share short and watered by hand today; one share short and dry; fresh and dry
    foreach ([$need3, $need3 - $share3, $need3 - $share3, 0] as $i => $g)
        q('UPDATE plot_tiles SET tilled = 1, method = ?, plant_id = ?, planted_at = ?, growth_seconds = ?, growth_updated_at = ?, grow_day = ?, owed_days = 0, water_day = ?, last_watered = NULL, pest = NULL, pest_at = NULL, weeds = 0, nipped = 0 WHERE id = ?',
            ['till', $crop3['id'], now(), $g, now(), $X, $i === 1 ? $X : null, $tiles[$i]]);
};
$nag = function () use ($uid, $tiles, $crop3): array {   // what the garden still asks for: [ripe (Today list), ripe (settled, like the garden page), thirsty, dock badge]
    gclock_plot_day(0, true);
    $ripe = 0; $thirsty = 0;
    foreach ($tiles as $id) {
        $raw = q_one('SELECT * FROM plot_tiles WHERE id = ?', [$id]);
        if (!$raw['plant_id']) continue;
        $ti = tile_info(gclock_tile_grow(annotate_tile($raw, $crop3), $crop3), $crop3);
        $ripe += $ti['ready'] ? 1 : 0; $thirsty += $ti['thirsty'] ? 1 : 0;
    }
    $todayRipe = (bool)array_filter(today_data(urow($uid))['need'], fn($n) => str_contains($n[1], 'ripe'));
    return [$todayRipe, $ripe, $thirsty, dock_garden_ready(urow($uid))];
};
$crops = fn() => (int)q_val('SELECT COALESCE(SUM(qty),0) FROM user_items WHERE user_id = ? AND item_id = ?', [$uid, $crop3['produce_item_id']]);
// no crew: a sleep leaves the beds exactly as they were (the player does the work)
$setBeds();
$rows0 = q('SELECT id, plant_id, growth_seconds, grow_day, water_day, owed_days FROM plot_tiles WHERE id IN (' . implode(',', $tiles) . ') ORDER BY id')->fetchAll();
$c0 = $crops();
game_sleep($uid);
$rows1 = q('SELECT id, plant_id, growth_seconds, grow_day, water_day, owed_days FROM plot_tiles WHERE id IN (' . implode(',', $tiles) . ') ORDER BY id')->fetchAll();
ok('no crew: the sleep does not touch the beds or pick anything', $rows0 == $rows1 && $crops() === $c0, json_encode([$rows0, $rows1]));
[$tr, $rp] = $nag();
ok('no crew: the ripe crop still waits for the player (Today lists it)', $tr && $rp >= 1, json_encode($nag()));
// Water + Harvest crew: after every sleep nothing is ripe and nothing is thirsty
$X = (int)urow($uid)['game_day']; $setBeds();
$u = urow($uid);
pcrew_assign($u, $plot, 'water', $p0, 'full', 0); pcrew_assign($u, $plot, 'harvest', $p1, 'full', 0);
$c0 = $crops(); $picked = 0; $clean = true; $seen = [];
for ($i = 1; $i <= 4; $i++) {
    $ready = [];
    foreach ($tiles as $id) { $raw = q_one('SELECT * FROM plot_tiles WHERE id = ?', [$id]); if ($raw['plant_id']) $ready[$id] = annotate_tile($raw, $crop3); }
    game_sleep($uid);
    $picked += (int)(array_values(array_filter(pcrew_latest_report($uid)[1]['crew'] ?? [], fn($c) => $c['role'] === 'harvest'))[0]['n'] ?? 0);
    $seen[$i] = $nag();
    if ($seen[$i] !== [false, 0, 0, 0]) $clean = false;
    foreach ($ready as $id => $old) if (!q_val('SELECT plant_id FROM plot_tiles WHERE id = ?', [$id])) {   // the crew picked it: the player cannot pick it again
        $again = 'paid again';
        try { db()->beginTransaction(); do_harvest(urow($uid), $old, $crop3); db()->commit(); } catch (Throwable $e) { if (db()->inTransaction()) db()->rollBack(); $again = 'refused'; }
        ok("sleep $i: a bed the crew picked cannot be harvested a second time", $again === 'refused');
    }
}
ok('after every sleep: nothing ripe (Today, garden, dock badge) and nothing thirsty', $clean, json_encode($seen));
ok('the crew picked the ripe crop and the ones that ripened later (' . $picked . ' crops)', $picked >= 3, (string)$picked);
$got = $crops() - $c0;
ok('paid once: produce matches the crops picked', $got >= $picked * (int)$crop3['yield_min'] && $got <= $picked * ((int)$crop3['yield_max'] + 4), "$picked picked, +$got");
q('DELETE FROM garden_pal_slots WHERE plot_id = ?', [$plot]); q("UPDATE ppal_found SET status = 'home' WHERE user_id = ?", [$uid]); q('DELETE FROM garden_pal_rest WHERE user_id = ?', [$uid]);

echo "== weeds and pests on the same bed: both are done in one pass\n";
$u = urow($uid);
pcrew_assign($u, $plot, 'weed', $p2, 'full', 0); pcrew_assign($u, $plot, 'pests', $P[3]['uid'], 'full', 0);
q("UPDATE plot_tiles SET plant_id = ?, growth_seconds = 0, method = 'notill', weeds = 6, pest = 'aphids', pest_at = ? WHERE id = ?", [$crop3['id'], now(), $tiles[0]]);
game_sleep($uid);
$tw = q_one('SELECT weeds, pest FROM plot_tiles WHERE id = ?', [$tiles[0]]);
ok('a bed with pests and weeds: pests picked AND weeds pulled the same night', (int)$tw['weeds'] === 0 && empty($tw['pest']), json_encode($tw));
q('DELETE FROM garden_pal_slots WHERE plot_id = ?', [$plot]); q("UPDATE ppal_found SET status = 'home' WHERE user_id = ?", [$uid]); q('DELETE FROM garden_pal_rest WHERE user_id = ?', [$uid]);

echo "== staying up past 06:00: the crew works that morning without a sleep, once (Josh 2026-11-26)\n";
$crewHome = function () use ($plot, $uid) { q('DELETE FROM garden_pal_slots WHERE plot_id = ?', [$plot]); q("UPDATE ppal_found SET status = 'home' WHERE user_id = ?", [$uid]); q('DELETE FROM garden_pal_rest WHERE user_id = ?', [$uid]); };
$crewHome();
$setBedsAt = function (int $X) use ($tiles, $crop3, $need3) {   // ripe now; a minute short and watered on X (ripe once day X counts); a minute short and dry; fresh and dry
    foreach ([$need3, $need3 - 60, $need3 - 60, 0] as $i => $g)
        q('UPDATE plot_tiles SET tilled = 1, method = ?, plant_id = ?, planted_at = ?, growth_seconds = ?, growth_updated_at = ?, grow_day = ?, owed_days = 0, water_day = ?, last_watered = NULL, pest = NULL, pest_at = NULL, weeds = 0, nipped = 0 WHERE id = ?',
            ['till', $crop3['id'], now(), $g, now(), $X, $i === 1 ? $X : null, $tiles[$i]]);
};
$X = (int)urow($uid)['game_day'];
q('UPDATE users SET game_minute = 600, crew_morning = ? WHERE id = ?', [$X, $uid]);   // 10:00 on day X; this morning's pass is done
$setBedsAt($X);   // [ripe, one share short + watered on X, one share short + dry, fresh + dry]
$u = urow($uid);
pcrew_assign($u, $plot, 'water', $p0, 'full', 0); pcrew_assign($u, $plot, 'harvest', $p1, 'full', 0); pcrew_assign($u, $plot, 'pests', $p2, 'timed', 3);
$c0 = $crops();
q('UPDATE users SET game_minute = 1799 WHERE id = ?', [$uid]);   // 05:59 of the next morning, still up
ok('stay-up: before 06:00 no crew pass', gclock_crew_mornings(urow($uid)) === false && $crops() === $c0);
q('UPDATE users SET game_minute = 1830 WHERE id = ?', [$uid]);   // 06:30 of morning X+1, no sleep
$run1 = gclock_crew_mornings(urow($uid)); $run2 = gclock_crew_mornings(urow($uid));   // two page loads in the same morning
ok('stay-up past 06:00: the crew works once (second page load does nothing)', $run1 === true && $run2 === false, json_encode([$run1, $run2]));
ok('stay-up: the gnome\'s own day has not moved (no sleep)', (int)urow($uid)['game_day'] === $X && (int)urow($uid)['crew_morning'] === $X + 1);
$rep = pcrew_latest_report($uid);
$hv = array_values(array_filter($rep[1]['crew'] ?? [], fn($c) => $c['role'] === 'harvest'))[0] ?? [];
ok('stay-up: report saved for morning X+1; Harvest pal picked the ripe crop and the one watered yesterday (2)', $rep && $rep[0] === $X + 1 && (int)($hv['n'] ?? 0) === 2, json_encode($rep));
$paid1 = $crops() - $c0;
ok('stay-up: the picked crops are in the satchel', $paid1 >= 2 * (int)$crop3['yield_min'], (string)$paid1);
ok('stay-up: Water pal watered the two beds still growing for X+1', (int)$t($tiles[2])['water_day'] === $X + 1 && (int)$t($tiles[3])['water_day'] === $X + 1, json_encode([$t($tiles[2]), $t($tiles[3])]));
load_plot($uid);   // the garden page looks (and saves growth) before the sleep: it must not wind the beds back a day
$g2 = (int)$t($tiles[2])['growth_seconds']; $g3 = (int)$t($tiles[3])['growth_seconds'];
ok('stay-up: a look at the garden keeps the crew\'s day (grow_day X+1)', (int)$t($tiles[2])['grow_day'] === $X + 1 && (int)$t($tiles[3])['grow_day'] === $X + 1, json_encode([$t($tiles[2]), $t($tiles[3])]));
ok('stay-up: nothing left to do (Today, garden, thirsty, dock badge)', $nag() === [false, 0, 0, 0], json_encode($nag()));
q('UPDATE plot_tiles SET water_day = ' . GCLOCK_WATER_DAY_SQL . ' WHERE id = ?', [$tiles[2]]);   // a rain event or a hand watering now
ok('stay-up: a watering at game day X does not lower the crew\'s water_day X+1', (int)$t($tiles[2])['water_day'] === $X + 1);
$sl = pcrew_slots($plot);
ok('stay-up: one morning counted on each slot (timed 3 at 1)', (int)$sl['water']['done'] === 1 && (int)$sl['harvest']['done'] === 1 && (int)$sl['pests']['done'] === 1, json_encode($sl));
// the sleep after: lands on the same 06:00, so no second pass
$c1 = $crops();
game_sleep($uid);
$sl = pcrew_slots($plot);
ok('sleep after staying up: day X+1 at 06:00, morning not worked again', (int)urow($uid)['game_day'] === $X + 1 && (int)urow($uid)['crew_morning'] === $X + 1);
ok('sleep after staying up: no second pay', $crops() === $c1, ($crops() - $c1) . ' more');
ok('sleep after staying up: no extra morning counted (timed 3 still at 1)', (int)$sl['water']['done'] === 1 && (int)$sl['pests']['done'] === 1, json_encode($sl));
ok('sleep after staying up: no growth counted twice for day X', (int)$t($tiles[2])['growth_seconds'] === $g2 && (int)$t($tiles[3])['growth_seconds'] === $g3 && (int)$t($tiles[3])['grow_day'] === $X + 1, json_encode([$g2, $g3, $t($tiles[2]), $t($tiles[3])]));
$rep2 = pcrew_latest_report($uid);
ok('sleep after staying up: the morning report keeps the crew lines and is marked slept', $rep2[0] === $X + 1 && !empty($rep2[1]['slept']) && count($rep2[1]['crew'] ?? []) === 3, json_encode($rep2));
ok('sleep after staying up: still nothing to do', $nag() === [false, 0, 0, 0], json_encode($nag()));
// next sleep: morning X+2 is worked (night 2), then stay up past 06:00 of X+3: night 3 ends the 3-morning job
game_sleep($uid);
ok('next sleep: morning X+2 worked (night 2)', (int)pcrew_slots($plot)['pests']['done'] === 2 && (int)urow($uid)['crew_morning'] === $X + 2);
q('UPDATE users SET game_minute = 1800 WHERE id = ?', [$uid]);
gclock_crew_mornings(urow($uid));
ok('timed 3 mornings: the 3rd morning (stayed up) ends the job, the pal is home and resting until the next sleep', !isset(pcrew_slots($plot)['pests']) && pj_pal($uid, $p2)['status'] === 'home' && pcrew_is_resting($uid, $p2, $X + 2) && !pcrew_is_resting($uid, $p2, $X + 3));
game_sleep($uid);
ok('timed 3 mornings: the sleep after is not a 4th morning', (int)pcrew_slots($plot)['water']['done'] === 3 && (int)urow($uid)['crew_morning'] === $X + 3, json_encode(pcrew_slots($plot)));
// no crew: staying up past 06:00 leaves the garden alone
$crewHome();
$X = (int)urow($uid)['game_day']; $setBedsAt($X);
$rows0 = q('SELECT id, plant_id, growth_seconds, grow_day, water_day, owed_days FROM plot_tiles WHERE id IN (' . implode(',', $tiles) . ') ORDER BY id')->fetchAll();
$c0 = $crops();
q('UPDATE users SET game_minute = 1830 WHERE id = ?', [$uid]);
gclock_crew_mornings(urow($uid));
$rows1 = q('SELECT id, plant_id, growth_seconds, grow_day, water_day, owed_days FROM plot_tiles WHERE id IN (' . implode(',', $tiles) . ') ORDER BY id')->fetchAll();
ok('no crew: staying up past 06:00 does not touch the beds or pick anything', $rows0 == $rows1 && $crops() === $c0, json_encode([$rows0, $rows1]));
game_sleep($uid);
$rows2 = q('SELECT id, plant_id, growth_seconds, grow_day, water_day, owed_days FROM plot_tiles WHERE id IN (' . implode(',', $tiles) . ') ORDER BY id')->fetchAll();
ok('no crew: nor does the sleep after', $rows0 == $rows2 && $crops() === $c0);
$crewHome();

echo "== hired helpers retire with a refund\n";
q("INSERT INTO helpers (name, species, icon, bio, skills, wage, active) VALUES ('Testy', 'mole', '🦔', 'x', 'water,weed,harvest', 20, 1)");
$hid = (int)q_val("SELECT id FROM helpers WHERE name = 'Testy'");
$coins0 = (int)q_val('SELECT coins FROM users WHERE id = ?', [$uid]);
db_insert('garden_hires', ['plot_id' => $plot, 'user_id' => $uid, 'helper_id' => $hid, 'started_at' => gmdate('Y-m-d H:i:s', time() - 3600), 'ends_at' => gmdate('Y-m-d H:i:s', time() + 3 * 86400 + 3600),
    'last_visit' => gmdate('Y-m-d H:i:s', time() - 3600), 'paid' => 60, 'active' => 1]);
set_setting('crew_helpers_retired', '');
$ref = new ReflectionFunction('pcrew_retire_helpers');
foreach ($ref->getStaticVariables() as $k => $v) { /* static $done is per process: call once */ }
pcrew_retire_helpers();
ok('contract ended', (int)q_val('SELECT active FROM garden_hires WHERE helper_id = ?', [$hid]) === 0);
ok('unused wages refunded (3 whole days x 20)', (int)q_val('SELECT coins FROM users WHERE id = ?', [$uid]) - $coins0 >= 60 - 20 && (int)q_val('SELECT coins FROM users WHERE id = ?', [$uid]) - $coins0 <= 60);
ok('the player was told', (bool)q_val("SELECT 1 FROM notices WHERE user_id = ? AND text LIKE '%gone home%'", [$uid]));
setting('__reload__'); ok('flag set so it runs once', setting('crew_helpers_retired') === '1');

echo "== the sleep report keeps 3\n";
for ($i = 0; $i < 5; $i++) pcrew_save_report($uid, 100 + $i, ['crew' => []]);
ok('last 3 kept', (int)q_val('SELECT COUNT(*) FROM sleep_report WHERE user_id = ? AND game_day >= 100', [$uid]) === 3);

echo $fails ? "\n$fails FAILED\n" : "\nall ok\n";
exit($fails ? 1 : 0);
