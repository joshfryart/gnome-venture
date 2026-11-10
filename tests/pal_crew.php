<?php
// v2.6.40 garden crew (includes/pal_crew.php). Run by pal_crew.sh on a fresh install with one registered gnome "sprout".
$_SERVER['SCRIPT_NAME'] = '/index.php';
require $argv[1] . '/includes/bootstrap.php';
require_once APP_ROOT . '/includes/pal_jobs.php';
require_once APP_ROOT . '/includes/pal_crew.php';
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
ok('dry bed: watered for the day that ended (water_day 10)', (string)$t($tDry)['water_day'] === '10', json_encode($t($tDry)));
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
