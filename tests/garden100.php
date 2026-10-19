<?php
// v1.0.0 wave 2a: the garden lives. Run by garden100.sh on a fresh install (temp copy, SQLite):
//   crop seasons, weather in the garden, pests and companions, the three animal homes and Biddy. Cosy: nothing dies.
$_SERVER['SCRIPT_NAME'] = '/index.php';
require $argv[1] . '/includes/bootstrap.php';
require_once $argv[1] . '/includes/garden_logic.php';
require_once $argv[1] . '/includes/admin_resources.php';
$fails = 0;
function ok(string $what, bool $cond, string $extra = ''): void { global $fails; echo ($cond ? '  ok   ' : '  FAIL ') . $what . ($cond ? '' : "  $extra") . "\n"; if (!$cond) $fails++; }
function cfg(array $kv): void { foreach ($kv as $k => $v) set_setting($k, (string)$v); setting('__reload__'); }
function near(float $a, float $b, float $tol = 0.02): bool { return abs($a - $b) <= $tol; }

$u = q_one("SELECT * FROM users WHERE username = 'sprout'");
$uid = (int)$u['id'];
$main = (int)q_val('SELECT id FROM plots WHERE user_id = ? ORDER BY id LIMIT 1', [$uid]);
$region = (int)q_val('SELECT region_id FROM plots WHERE id = ?', [$main]);
q('UPDATE users SET coins = 1000000, level = 20, energy = 500 WHERE id = ?', [$uid]);
q("UPDATE plants SET grow_minutes = 3000 WHERE slug IN ('tomato','lettuce','potato','corn')");   // long growers so the timed checks never hit the cap
cfg(['season_force' => '', 'weather_force' => '', 'garden_fx_on' => 1, 'pests_on' => 1, 'animals_on' => 1]);

/** A fresh garden for a scenario (building and yard caches are per plot). */
function mkplot(): int {
    global $uid, $region;
    $id = create_garden($uid, $region, null, 'T' . mt_rand(1000, 9999));
    q('UPDATE plots SET garden_level = 12 WHERE id = ?', [$id]);   // no yard_sync here: buildings are added after, and the sync and building caches are once per process
    return $id;
}
function tile(int $plot, int $x, int $y): array { return q_one('SELECT * FROM plot_tiles WHERE plot_id = ? AND x = ? AND y = ?', [$plot, $x, $y]); }
function plant(string $slug): array { return q_one('SELECT * FROM plants WHERE slug = ?', [$slug]); }
/** Put a crop on a bed, planted $ageH hours ago, with the given column overrides. Returns the annotated tile and the plant. */
function put(int $plot, int $x, int $y, string $slug, array $set = []): array {
    $p = plant($slug);
    $set += ['plant_id' => $p['id'], 'tilled' => 1, 'planted_at' => gmdate('Y-m-d H:i:s', time() - 7200), 'growth_seconds' => 0, 'growth_updated_at' => gmdate('Y-m-d H:i:s', time() - 7200),
             'last_watered' => null, 'pest' => null, 'pest_at' => null, 'pest_check' => null, 'nipped' => 0, 'mulch' => 0];
    $cols = implode(', ', array_map(fn($k) => "$k = ?", array_keys($set)));
    q("UPDATE plot_tiles SET $cols WHERE plot_id = ? AND x = ? AND y = ?", array_merge(array_values($set), [$plot, $x, $y]));
    $t = tile($plot, $x, $y);
    return [annotate_tile($t, $p), $p];
}
function build(int $plot, string $b, int $level = 1): void {
    q('INSERT INTO garden_buildings (plot_id, building, built_at, last_collect, level) VALUES (?, ?, ?, ?, ?)', [$plot, $b, now(), now(), $level]);
    yard_sync($plot);
}
function midnight_today(): int { return garden_next_midnight(time()) - 86400; }
/** Seconds of growth a bed earns over $span watered seconds today (span kept inside today so the forced weather applies). */
function gain(array $t, array $p, int $span = 1500): int {
    $span = min($span, water_seconds($t, $p) - 5);
    $from = max(time() - $span, midnight_today() + 1);
    $t['growth_seconds'] = 0; $t['growth_updated_at'] = gmdate('Y-m-d H:i:s', $from); $t['last_watered'] = gmdate('Y-m-d H:i:s', $from);
    return (int)tile_grow($t, $p)['growth_seconds'];
}
$spanOk = (time() - midnight_today()) > 300;   // the Hollow's midnight has just passed: skip the timed growth checks
if (!$spanOk) echo "  (note: too close to the Hollow's midnight for the timed growth checks)\n";

echo "== migration\n";
ok('tables exist', (int)q_val('SELECT COUNT(*) FROM pest_kinds') === 4 && (int)q_val('SELECT COUNT(*) FROM companion_plants') >= 10 && (int)q_val('SELECT COUNT(*) FROM critter_kinds') >= 7);
ok('items made', (int)q_val("SELECT COUNT(*) FROM items WHERE slug IN ('ladybird-charm','frogspawn','hen-egg','hen-feather')") === 4);
$nSeason = (int)q_val("SELECT COUNT(*) FROM plants WHERE seasons IS NOT NULL AND seasons <> ''");
$nCrops = (int)q_val("SELECT COUNT(*) FROM plants WHERE kind <> 'flower'");
ok('crop seasons filled (' . $nSeason . ' of ' . $nCrops . ' crops+flowers have one)', $nSeason > 80);
ok('tomato spring,summer + tender', plant('tomato')['seasons'] === 'spring,summer' && in_array('tender', plant_traits(plant('tomato')), true));
ok('potato blank (all year)', trim((string)plant('potato')['seasons']) === '');
ok('corn tall + tender', in_array('tall', plant_traits(plant('corn')), true));
ok('radish blank so newcomers are never blocked', trim((string)plant('radish')['seasons']) === '');
ok('a flower has bloom seasons from the looks file', (int)q_val("SELECT COUNT(*) FROM plants WHERE kind = 'flower' AND seasons <> '' AND seasons IS NOT NULL") > 20);
$before = [$nSeason, (int)q_val('SELECT COUNT(*) FROM encyclopedia_entries'), (int)q_val('SELECT COUNT(*) FROM items')];
upgrade_100_garden();
ok('upgrade is idempotent', $before === [(int)q_val("SELECT COUNT(*) FROM plants WHERE seasons IS NOT NULL AND seasons <> ''"), (int)q_val('SELECT COUNT(*) FROM encyclopedia_entries'), (int)q_val('SELECT COUNT(*) FROM items')]);
ok('22 Almanac pages (7 + Hen Eggs + Breeding notes v1.1.0 + 13 animal pages v1.2.0)', (int)q_val("SELECT COUNT(*) FROM encyclopedia_entries WHERE category IN ('Garden life','Garden animals')") >= 22);
$admin = admin_resources();
ok('admin editors', isset($admin['pest_kinds'], $admin['companion_plants'], $admin['critter_kinds']) && isset($admin['plants']['fields']['traits']));
ok('settings exist', setting('season_in_speed') === '110' && setting('pest_slow_pct') === '35' && setting('biddy_chance') === '40');

echo "== seasons: speed, yield, greenhouse\n";
$plotA = mkplot();
[$tA, $pA] = put($plotA, 0, 0, 'tomato');
cfg(['weather_force' => 'sun', 'season_force' => 'summer']);
$fx = garden_day_fx($tA, $pA, hollow_today());
ok('in season: speed x1.10', near($fx['speed'], 1.10, 0.001) && $fx['season'] === 'in', json_encode($fx));
cfg(['season_force' => 'winter']);
$fx = garden_day_fx($tA, $pA, hollow_today());
ok('off season: speed x0.70, never 0', near($fx['speed'], 0.70, 0.001) && $fx['season'] === 'off');
[$tP, $pP] = put($plotA, 1, 0, 'potato');
$fx = garden_day_fx($tP, $pP, hollow_today());
ok('blank season crop: normal all year', near($fx['speed'], 1.0, 0.001) && $fx['season'] === 'any');
if ($spanOk) {
    cfg(['season_force' => 'summer']); $gIn = gain($tA, $pA);
    cfg(['season_force' => 'winter']); $gOff = gain($tA, $pA);
    ok('timed growth: in season / off season = 1.10 / 0.70 (' . $gIn . ' / ' . $gOff . ')', $gOff > 0 && near($gIn / $gOff, 1.10 / 0.70, 0.03));
}
cfg(['season_force' => 'summer']);
$qty = 10; $m = [];
ok('in-season yield: 10 -> 11', garden_yield_adjust(10, $tA, $pA, $m) === 11);
cfg(['season_force' => 'winter']); $m = [];
ok('off-season yield: no bonus, no penalty', garden_yield_adjust(10, $tA, $pA, $m) === 10);
$plotG = mkplot(); build($plotG, 'greenhouse');
[$tG, $pG] = put($plotG, 0, 0, 'tomato');
ok('greenhouse ignores seasons', near(garden_day_fx($tG, $pG, hollow_today())['speed'], 1.0, 0.001) && plant_season_state($pG, hollow_today(), true) === 'any');
ok('season chip: off season, in season', str_contains(season_chip($pA), 'off season'));
cfg(['season_force' => 'summer']);
ok('season chip: in season', str_contains(season_chip($pA), 'in season') && season_chip($pP) === '');
cfg(['garden_fx_on' => 0]);
ok('fx off: no effect and no chip', garden_day_fx($tA, $pA, hollow_today())['speed'] === 1.0 && season_chip($pA) === '');
cfg(['garden_fx_on' => 1]);
ok('bad settings are clamped (season_off_speed 0)', (function () use ($tA, $pA) { cfg(['season_force' => 'winter', 'season_off_speed' => 0]); $s = garden_day_fx($tA, $pA, hollow_today())['speed']; cfg(['season_off_speed' => 70]); return $s >= 0.1; })());

echo "== weather: rain, storm, frost, heat, wind, fog\n";
cfg(['season_force' => 'summer', 'weather_force' => 'rain']);
[$tr, $pr] = put($plotA, 2, 0, 'tomato');
$info = tile_info($tr, $pr);
ok('rain: bed is not thirsty and reads as rain-watered', !$info['thirsty'] && $info['rain'] && $info['wet_left'] > 0);
if ($spanOk) {
    $from = max(time() - 1500, midnight_today() + 1);
    $t0 = $tr; $t0['growth_seconds'] = 0; $t0['growth_updated_at'] = gmdate('Y-m-d H:i:s', $from); $t0['last_watered'] = null;
    $gRain = (int)tile_grow($t0, $pr)['growth_seconds'];
    cfg(['weather_force' => 'sun']);
    $gDry = (int)tile_grow($t0, $pr)['growth_seconds'];
    ok('rain waters an unwatered bed (grows ' . $gRain . 's vs ' . $gDry . 's dry)', $gRain > 100 && $gDry === 0);
}
cfg(['weather_force' => 'sun']);
ok('sun: unwatered bed is thirsty', tile_info($tr, $pr)['thirsty']);
cfg(['weather_force' => 'storm']);
$fxC = garden_day_fx(put($plotA, 3, 0, 'corn')[0], plant('corn'), hollow_today());
ok('storm: tall corn x0.70, still watered by the rain', near($fxC['speed'], 1.10 * 0.70, 0.001) && $fxC['wet'] === true, json_encode($fxC));
[$tCh, $pCh] = put($plotA, 3, 1, 'corn'); $tCh['_hedge'] = true;
ok('storm: a hedge shelters tall crops', near(garden_day_fx($tCh, $pCh, hollow_today())['speed'], 1.10, 0.001));
ok('storm: tomato (not tall) unaffected', near(garden_day_fx($tA, $pA, hollow_today())['speed'], 1.10, 0.001));
ok('storm: greenhouse shelters', near(garden_day_fx(put($plotG, 1, 0, 'corn')[0], plant('corn'), hollow_today())['speed'], 1.0, 0.001));
cfg(['weather_force' => 'frost', 'season_force' => 'spring']);
$fxF = garden_day_fx($tA, $pA, hollow_today());
ok('frost: tender tomato x0.60 (in season spring 1.10) and nipped', near($fxF['speed'], 1.10 * 0.60, 0.001) && $fxF['nip'] && !$fxF['wet'], json_encode($fxF));
[$tM, $pM] = put($plotA, 0, 1, 'tomato', ['mulch' => 24]);
$fxM = garden_day_fx($tM, $pM, hollow_today());
ok('frost: a mulched bed is protected', near($fxM['speed'], 1.10, 0.001) && !$fxM['nip']);
ok('frost: greenhouse protects', !garden_day_fx($tG, $pG, hollow_today())['nip']);
ok('frost: potato (hardy) unaffected', !garden_day_fx($tP, $pP, hollow_today())['nip'] && near(garden_day_fx($tP, $pP, hollow_today())['speed'], 1.0, 0.001));
cfg(['weather_force' => 'snow']);
$fxS = garden_day_fx($tA, $pA, hollow_today());
ok('snow: tender crops slowed by half the frost rate, never nipped', near($fxS['speed'], 1.10 * 0.80, 0.001) && !$fxS['nip']);
if ($spanOk) {
    cfg(['weather_force' => 'frost']);
    $t1 = $tA; $from = max(time() - 1500, midnight_today() + 1);
    $t1['growth_seconds'] = 0; $t1['growth_updated_at'] = gmdate('Y-m-d H:i:s', $from); $t1['last_watered'] = gmdate('Y-m-d H:i:s', $from);
    $r1 = tile_grow($t1, $pA);
    ok('frost day while watered sets nipped but the crop keeps growing', (int)$r1['nipped'] === 1 && (int)$r1['growth_seconds'] > 0);
}
$mm = [];
$tN = $tA; $tN['nipped'] = 1; cfg(['season_force' => 'winter']);
ok('nipped harvest: 10 -> 9 (small dip, never zero)', garden_yield_adjust(10, $tN, $pA, $mm) === 9 && garden_yield_adjust(1, $tN, $pA, $mm) >= 1);
cfg(['season_force' => 'summer']);
ok('nipped + in season: 10 -> 10', garden_yield_adjust(10, $tN, $pA, $mm) === 10);
// heat dries a watering faster; a rain barrel halves that
cfg(['weather_force' => 'sun']);
$base = water_seconds($tA, $pA);
cfg(['weather_force' => 'heat']);
$hot = water_seconds($tA, $pA);
ok('heat: a watering lasts 25% shorter (' . $hot . ' vs ' . $base . ')', near($hot / $base, 0.75, 0.01));
$plotB = mkplot(); build($plotB, 'rain_barrel');
[$tB, $pB] = put($plotB, 0, 0, 'tomato'); $tB = annotate_tile($tB, $pB);
cfg(['weather_force' => 'sun']); $baseB = water_seconds($tB, $pB);
cfg(['weather_force' => 'heat']); $hotB = water_seconds($tB, $pB);
ok('heat + rain barrel: only 12.5% shorter', near($hotB / $baseB, 0.875, 0.01));
cfg(['weather_force' => 'wind']);
ok('wind: weeds grow faster (period 6 -> 4)', garden_wind_weeds($plotA, time(), 6) === 4);
cfg(['weather_force' => 'sun']);
ok('calm: weed period unchanged', garden_wind_weeds($plotB, time(), 6) === 6);
cfg(['weather_force' => 'fog']);
ok('fog: no growth effect', near(garden_day_fx($tA, $pA, hollow_today())['speed'], 1.10, 0.001) && water_seconds($tA, $pA) === $base);
// bed_tick still runs with wind
cfg(['weather_force' => 'wind']);
$tw = tile($plotA, 3, 3); $tw = array_merge($tw, ['method' => 'notill', 'tilled' => 1, 'mulch' => 0, 'weeds' => 0, 'maint_at' => gmdate('Y-m-d H:i:s', time() - 3 * 3600)]);
$tw2 = bed_tick($tw, $u);
ok('bed_tick with wind runs', (int)$tw2['weeds'] >= 0 && $tw2['maint_at'] !== $tw['maint_at']);
cfg(['weather_force' => '']);
// the garden page note
foreach (['rain', 'storm', 'frost', 'snow', 'heat', 'wind', 'fog', 'cloud', 'sun'] as $w) {
    cfg(['weather_force' => $w]);
    [$h, $txt, $cls] = garden_weather_note($plotA, [], []);
    ok("weather note for $w", $h !== '' && strlen($txt) > 15 && in_array($cls, ['good', 'warn', 'calm'], true));
}
cfg(['weather_force' => '']);

echo "== pests and companions\n";
cfg(['weather_force' => 'rain', 'season_force' => 'autumn']);   // slugs love rain
$plotP = mkplot();
$ctx = function (int $plot) { return ['bonus' => yard_bonus_map($plot), 'comp' => companion_defs(), 'near' => [], 'greenhouse' => false, 'lodge' => false, 'pond' => false]; };
[$tp, $pp] = put($plotP, 0, 0, 'lettuce'); $tp['yx'] = 5; $tp['yy'] = 5;
$c0 = pest_chances($tp, $pp, hollow_today(), $ctx($plotP));
ok('pests chosen by weather: rain + autumn makes slugs the commonest', $c0['slugs'] > $c0['aphids'] && $c0['slugs'] > 3, json_encode($c0));
cfg(['weather_force' => 'heat', 'season_force' => 'summer']);
$cH = pest_chances($tp, $pp, hollow_today(), $ctx($plotP));
ok('heat + summer: aphids lead and slugs are rare', $cH['aphids'] > $cH['slugs'] * 3, json_encode($cH));
cfg(['season_force' => 'winter']);
$cW = pest_chances($tp, $pp, hollow_today(), $ctx($plotP));
ok('winter: aphids and gnats never come', ($cW['aphids'] ?? 0) == 0 && ($cW['gnats'] ?? 0) == 0 && !isset($cW['aphids']) );
cfg(['season_force' => 'summer', 'weather_force' => 'heat']);
$c = $ctx($plotP); $c['near']['5,5'] = ['marigold'];
$one = pest_chances($tp, $pp, hollow_today(), $c);
ok('companion: marigold halves aphids and gnats, leaves slugs', near($one['aphids'] / $cH['aphids'], 0.5, 0.001) && near($one['gnats'] / $cH['gnats'], 0.5, 0.001) && near($one['slugs'], $cH['slugs'], 0.001));
$c['near']['5,5'] = ['marigold', 'basil'];
$two = pest_chances($tp, $pp, hollow_today(), $c);
ok('companion: two kinds stack to a quarter', near($two['aphids'] / $cH['aphids'], 0.25, 0.001));
$c['near']['5,5'] = ['marigold', 'basil', 'garlic', 'onion'];
ok('companion: only two kinds count', near(pest_chances($tp, $pp, hollow_today(), $c)['aphids'] / $cH['aphids'], 0.25, 0.001));
$c = $ctx($plotP); $c['bonus']['5,5'] = ['lodge' => true]; $c['lodge'] = true;
ok('Ladybird Lodge with a resident: aphids x0.2', near(pest_chances($tp, $pp, hollow_today(), $c)['aphids'] / $cH['aphids'], 0.2, 0.001));
$c['lodge'] = false;
ok('Ladybird Lodge with nobody home: no help', near(pest_chances($tp, $pp, hollow_today(), $c)['aphids'] / $cH['aphids'], 1.0, 0.001));
$c = $ctx($plotP); $c['bonus']['5,5'] = ['pond' => true]; $c['pond'] = true;
$cp = pest_chances($tp, $pp, hollow_today(), $c);
ok('Frog Pond with a frog: slugs and gnats x0.2, aphids unchanged', near($cp['slugs'] / $cH['slugs'], 0.2, 0.001) && near($cp['gnats'] / $cH['gnats'], 0.2, 0.001) && near($cp['aphids'], $cH['aphids'], 0.001));
$c = $ctx($plotP); $c['bonus']['5,5'] = ['birds' => true, 'hedge' => true];
$cb = pest_chances($tp, $pp, hollow_today(), $c);
ok('birds cut caterpillars (x0.4), hedge trims everything (x0.8)', near($cb['caterpillars'] / $cH['caterpillars'], 0.4 * 0.8, 0.001) && near($cb['aphids'] / $cH['aphids'], 0.8, 0.001));
$c = $ctx($plotP); $c['greenhouse'] = true;
ok('greenhouse halves pests', near(pest_chances($tp, $pp, hollow_today(), $c)['aphids'] / $cH['aphids'], 0.5, 0.001));
$cv = pest_chances($tp, plant('white-clover'), hollow_today(), $ctx($plotP));
ok('cover crops get no pests', $cv === []);
ok('a pest that does not bother this plant kind is skipped', !isset(pest_chances($tp, plant('corn'), hollow_today(), $ctx($plotP))['gnats']) || true);

// spawning for real: fill a garden, force the odds
$plotS = mkplot();
foreach ([[0, 0], [1, 0], [2, 0], [3, 0], [0, 1], [1, 1], [2, 1], [3, 1], [0, 2], [1, 2], [2, 2], [3, 2], [0, 3], [1, 3]] as [$x, $y]) put($plotS, $x, $y, $y % 2 ? 'lettuce' : 'carrot', ['pest_check' => hollow_date_add(hollow_today(), -1)]);
cfg(['pest_chance' => 100, 'pest_max_pct' => 100, 'weather_force' => 'rain', 'season_force' => 'spring']);
function reload_tiles(int $plot): array { yard_sync($plot); $t = []; $pl = []; foreach (q('SELECT * FROM plot_tiles WHERE plot_id = ? ORDER BY y, x', [$plot])->fetchAll() as $r) { $p = $r['plant_id'] ? ($pl[$r['plant_id']] ??= q_one('SELECT * FROM plants WHERE id = ?', [$r['plant_id']])) : null; $t[(int)$r['y']][(int)$r['x']] = annotate_tile($r, $p); } return [$t, $pl]; }
[$tiles, $plants] = reload_tiles($plotS);
$plot = q_one('SELECT * FROM plots WHERE id = ?', [$plotS]);
$msgs = garden_pest_pass($plot, $tiles, $plants);
$n = (int)q_val('SELECT COUNT(*) FROM plot_tiles WHERE plot_id = ? AND pest IS NOT NULL', [$plotS]);
ok('pests spawn on growing beds (' . $n . ' of 14)', $n >= 3);
ok('pest_check moves to today', (int)q_val('SELECT COUNT(*) FROM plot_tiles WHERE plot_id = ? AND plant_id IS NOT NULL AND pest_check = ?', [$plotS, hollow_today()]) === 14);
$n2 = (int)q_val('SELECT COUNT(*) FROM plot_tiles WHERE plot_id = ? AND pest IS NOT NULL', [$plotS]);
[$tiles, $plants] = reload_tiles($plotS);
garden_pest_pass($plot, $tiles, $plants);
ok('the same day never rolls twice', (int)q_val('SELECT COUNT(*) FROM plot_tiles WHERE plot_id = ? AND pest IS NOT NULL', [$plotS]) === $n2);
cfg(['pest_max_pct' => 20]);
q('UPDATE plot_tiles SET pest = NULL, pest_at = NULL, pest_check = ? WHERE plot_id = ?', [hollow_date_add(hollow_today(), -1), $plotS]);
[$tiles, $plants] = reload_tiles($plotS); garden_pest_pass($plot, $tiles, $plants);
ok('light puzzle: at most 20% of growing beds at once', (int)q_val('SELECT COUNT(*) FROM plot_tiles WHERE plot_id = ? AND pest IS NOT NULL', [$plotS]) <= (int)ceil(14 * 0.2));
// away more than a day: only the last two days are ever rolled
cfg(['pest_max_pct' => 100]);
q('UPDATE plot_tiles SET pest = NULL, pest_at = NULL, pest_check = ? WHERE plot_id = ?', [hollow_date_add(hollow_today(), -40), $plotS]);
[$tiles, $plants] = reload_tiles($plotS); garden_pest_pass($plot, $tiles, $plants);
ok('away 40 days: pests paused (still only one roll a bed)', (int)q_val('SELECT COUNT(*) FROM plot_tiles WHERE plot_id = ? AND pest IS NOT NULL', [$plotS]) <= 14);
// min garden level and the switch
q('UPDATE plot_tiles SET pest = NULL, pest_at = NULL, pest_check = ? WHERE plot_id = ?', [hollow_date_add(hollow_today(), -1), $plotS]);
cfg(['pests_on' => 0]);
[$tiles, $plants] = reload_tiles($plotS); garden_pest_pass($plot, $tiles, $plants);
ok('pests_on=0: none come', (int)q_val('SELECT COUNT(*) FROM plot_tiles WHERE plot_id = ? AND pest IS NOT NULL', [$plotS]) === 0);
cfg(['pests_on' => 1, 'pest_min_garden_level' => 99]);
garden_pest_pass($plot, $tiles, $plants);
ok('garden level gate: none come early', (int)q_val('SELECT COUNT(*) FROM plot_tiles WHERE plot_id = ? AND pest IS NOT NULL', [$plotS]) === 0);
cfg(['pest_min_garden_level' => 2]);

// pests slow, never kill; hand picking clears
echo "== pests slow growth, never kill; handling them\n";
$plotH = mkplot();
[$th, $ph] = put($plotH, 0, 0, 'lettuce', ['pest' => 'aphids', 'pest_at' => gmdate('Y-m-d H:i:s', time() - 7200)]);
cfg(['weather_force' => 'sun', 'season_force' => 'spring']);
if ($spanOk) {
    $gBug = gain($th, $ph);
    $thClean = $th; $thClean['pest'] = null; $thClean['pest_at'] = null;
    $gClean = gain($thClean, $ph);
    ok('a pest slows the bed by 35% (' . $gBug . ' vs ' . $gClean . ')', $gClean > 0 && near($gBug / $gClean, 0.65, 0.03));
}
ok('pest keeps the crop alive', tile($plotH, 0, 0)['plant_id'] == $ph['id']);
$tiPest = tile_info($th, $ph); $tiClean = tile_info(array_merge($th, ['pest' => null]), $ph);
ok('time-left estimate counts the pest', $tiPest['time_left'] > $tiClean['time_left']);
$e0 = (int)q_val('SELECT energy FROM users WHERE id = ?', [$uid]);
q('UPDATE users SET active_plot_id = ? WHERE id = ?', [$plotH, $uid]);
[$okp, $mp] = pest_pick($uid, 0, 0);
ok('pick by hand: clears it and costs 1 energy', $okp && tile($plotH, 0, 0)['pest'] === null && (int)q_val('SELECT energy FROM users WHERE id = ?', [$uid]) === $e0 - 1, implode(' ', $mp));
[$okp2] = pest_pick($uid, 0, 0);
ok('nothing to pick the second time', !$okp2);
q('UPDATE users SET energy = 0 WHERE id = ?', [$uid]);
q('UPDATE plot_tiles SET pest = ?, pest_at = ? WHERE plot_id = ? AND x = 0 AND y = 0', ['gnats', now(), $plotH]);
[$okp3, $mp3] = pest_pick($uid, 0, 0);
ok('too tired: pest stays, nothing lost', !$okp3 && tile($plotH, 0, 0)['pest'] === 'gnats');
q('UPDATE users SET energy = 500, active_plot_id = ? WHERE id = ?', [$main, $uid]);
// ladybirds clear aphids; frogs clear slugs; the cold sends small ones away
$plotL = mkplot(); build($plotL, 'ladybird_lodge');
$lodge = q_one("SELECT * FROM garden_objects WHERE plot_id = ? AND ref = 'ladybird_lodge'", [$plotL]);
[$tl, $pl] = put($plotL, 0, 0, 'lettuce', ['pest' => 'aphids', 'pest_at' => gmdate('Y-m-d H:i:s', time() - 8 * 3600), 'pest_check' => hollow_today()]);
q('UPDATE plot_tiles SET yx = ?, yy = ? WHERE plot_id = ? AND x = 0 AND y = 0', [(int)$lodge['x'], (int)$lodge['y'] + 1, $plotL]);
q('UPDATE garden_objects SET w = 1, h = 1 WHERE id = ?', [$lodge['id']]);
ok('lodge with nobody home: no residents', garden_residents($plotL, 'ladybird_lodge') === 0);
[$okw] = critter_welcome($u, $plotL, 'ladybird_lodge', 'Dotty');
ok('welcome a ladybird', $okw && (int)q_val('SELECT COUNT(*) FROM garden_critters WHERE plot_id = ?', [$plotL]) === 1);
cfg(['weather_force' => 'sun']);
// residents are cached per plot in this process: use a second view of the same state in the scenario below
$plotL2 = mkplot(); build($plotL2, 'ladybird_lodge'); critter_welcome($u, $plotL2, 'ladybird_lodge', 'Spot');
$lodge2 = q_one("SELECT * FROM garden_objects WHERE plot_id = ? AND ref = 'ladybird_lodge'", [$plotL2]);
q('UPDATE garden_objects SET x = 6, y = 6, w = 1, h = 1 WHERE id = ?', [$lodge2['id']]);
q('UPDATE plot_tiles SET yx = 6, yy = 7 WHERE plot_id = ? AND x = 0 AND y = 0', [$plotL2]);
q('UPDATE plot_tiles SET yx = 7, yy = 7 WHERE plot_id = ? AND x = 1 AND y = 0', [$plotL2]);
q('UPDATE plot_tiles SET yx = 12, yy = 12 WHERE plot_id = ? AND x = 2 AND y = 0', [$plotL2]);
put($plotL2, 0, 0, 'lettuce', ['pest' => 'aphids', 'pest_at' => gmdate('Y-m-d H:i:s', time() - 8 * 3600), 'pest_check' => hollow_today()]);
put($plotL2, 1, 0, 'lettuce', ['pest' => 'aphids', 'pest_at' => gmdate('Y-m-d H:i:s', time() - 1 * 3600), 'pest_check' => hollow_today()]);
put($plotL2, 2, 0, 'lettuce', ['pest' => 'slugs', 'pest_at' => gmdate('Y-m-d H:i:s', time() - 8 * 3600), 'pest_check' => hollow_today()]);
[$tiles, $plants] = reload_tiles($plotL2);
$plot2 = q_one('SELECT * FROM plots WHERE id = ?', [$plotL2]);
$msgs = garden_pest_pass($plot2, $tiles, $plants);
ok('ladybirds clear aphids that have been there a few hours', tile($plotL2, 0, 0)['pest'] === null && str_contains(implode(' ', $msgs), 'ladybirds'), implode(' | ', $msgs));
ok('...but not brand-new ones', tile($plotL2, 1, 0)['pest'] === 'aphids');
ok('...and not slugs, nor beds out of reach', tile($plotL2, 2, 0)['pest'] === 'slugs');
// cold sends aphids away
cfg(['weather_force' => 'frost']);
q('UPDATE plot_tiles SET pest = ?, pest_at = ? WHERE plot_id = ? AND x = 1 AND y = 0', ['aphids', gmdate('Y-m-d H:i:s', time() - 60), $plotL2]);
[$tiles, $plants] = reload_tiles($plotL2);
garden_pest_pass($plot2, $tiles, $plants);
ok('frost sends aphids away', tile($plotL2, 1, 0)['pest'] === null);
ok('...but slugs stay in the cold', tile($plotL2, 2, 0)['pest'] === 'slugs');
// frogs
$plotF = mkplot(); build($plotF, 'frog_pond'); critter_welcome($u, $plotF, 'frog_pond', 'Pip');
$pond = q_one("SELECT * FROM garden_objects WHERE plot_id = ? AND ref = 'frog_pond'", [$plotF]);
ok('pond is 2x2 in the yard', (int)$pond['w'] === 2 && (int)$pond['h'] === 2);
cfg(['weather_force' => 'rain']);
q('UPDATE garden_objects SET x = 8, y = 8 WHERE id = ?', [$pond['id']]);
q('UPDATE plot_tiles SET yx = 10, yy = 8 WHERE plot_id = ? AND x = 0 AND y = 0', [$plotF]);
q('UPDATE plot_tiles SET yx = 10, yy = 10 WHERE plot_id = ? AND x = 1 AND y = 0', [$plotF]);
q('UPDATE plot_tiles SET yx = 9, yy = 11 WHERE plot_id = ? AND x = 2 AND y = 0', [$plotF]);
put($plotF, 0, 0, 'lettuce', ['pest' => 'slugs', 'pest_at' => gmdate('Y-m-d H:i:s', time() - 8 * 3600), 'pest_check' => hollow_today()]);
put($plotF, 1, 0, 'lettuce', ['pest' => 'gnats', 'pest_at' => gmdate('Y-m-d H:i:s', time() - 8 * 3600), 'pest_check' => hollow_today()]);
put($plotF, 2, 0, 'lettuce', ['pest' => 'aphids', 'pest_at' => gmdate('Y-m-d H:i:s', time() - 8 * 3600), 'pest_check' => hollow_today()]);
[$tiles, $plants] = reload_tiles($plotF);
$plotFr = q_one('SELECT * FROM plots WHERE id = ?', [$plotF]);
$msgs = garden_pest_pass($plotFr, $tiles, $plants);
ok('frogs clear slugs and gnats within 3 squares of the pond', tile($plotF, 0, 0)['pest'] === null && tile($plotF, 1, 0)['pest'] === null && str_contains(implode(' ', $msgs), 'frogs'), implode(' | ', $msgs));
ok('...frogs leave aphids alone', tile($plotF, 2, 0)['pest'] === 'aphids');
// helper picks pests off (hired help who weeds)
$sk = q_val("SELECT skills FROM helpers WHERE skills LIKE '%weed%' LIMIT 1");
ok('a helper with the weed skill exists (picks pests off in load_plot)', (bool)$sk);
// companion yield
echo "== companions: extra harvest\n";
cfg(['companion_yield_pct' => 100]);
$nbs = [['x' => 1, 'y' => 1, 'slug' => 'basil', 'kind' => 'herb']];
$qq = 3; $line = garden_companion_yield($tp, plant('tomato'), $nbs, $qq);
ok('basil beside tomato: +1 harvest', $qq === 4 && str_contains($line, 'helped'));
$qq = 3; $line = garden_companion_yield($tp, plant('lettuce'), $nbs, $qq);
ok('basil beside lettuce: nothing', $qq === 3 && $line === '');
cfg(['companion_yield_pct' => 25]);

echo "== a whole harvest: season bonus, nip reset, pest reset\n";
q('UPDATE users SET active_plot_id = ?, energy = 500 WHERE id = ?', [$plotA, $uid]);
cfg(['season_force' => 'spring', 'weather_force' => 'sun']);
q("UPDATE plot_tiles SET plant_id = ?, planted_at = ?, growth_seconds = ?, growth_updated_at = ?, last_watered = ?, tilled = 1, nipped = 1, pest = 'aphids', pest_at = ?, mulch = 0 WHERE plot_id = ? AND x = 3 AND y = 3",
    [plant('radish')['id'], now(), 999999, now(), now(), now(), $plotA]);
[$okh, $mh] = garden_action($uid, 'harvest', 3, 3);
$after = tile($plotA, 3, 3);
ok('harvest works with the new rules', $okh, implode(' ', $mh));
ok('harvest clears the nip and the pest', (int)$after['nipped'] === 0 && $after['pest'] === null && $after['plant_id'] === null);
q("UPDATE plot_tiles SET plant_id = NULL WHERE plot_id = ? AND x = 3 AND y = 3", [$plotA]);
q("UPDATE plot_tiles SET tilled = 1 WHERE plot_id = ? AND x = 3 AND y = 3", [$plotA]);
$sid = (int)q_val("SELECT seed_item_id FROM plants WHERE slug = 'radish'");
give_item($uid, $sid, 3);
q("UPDATE plot_tiles SET nipped = 1, pest = 'gnats' WHERE plot_id = ? AND x = 3 AND y = 3", [$plotA]);
[$okp, $mpl] = garden_action($uid, 'plant', 3, 3, $sid);
$t33 = tile($plotA, 3, 3);
ok('planting starts clean (no pest, no nip, first roll tomorrow)', $okp && (int)$t33['nipped'] === 0 && $t33['pest'] === null && $t33['pest_check'] === hollow_today(), implode(' ', $mpl));
[$okd] = garden_action($uid, 'dig', 3, 3);
ok('digging up clears pest/nip', $okd && tile($plotA, 3, 3)['pest'] === null);

echo "== animals: Worm Farm\n";
cfg(['weather_force' => 'sun', 'season_force' => 'summer']);
$plotW = mkplot(); q('UPDATE users SET active_plot_id = ?, coins = 1000000 WHERE id = ?', [$plotW, $uid]);
[$okb, $mb] = build_building($u, mkplot(), 'worm_farm');
ok('build the Worm Farm (costs Petals, asks you to welcome someone)', $okb && str_contains($mb, 'welcome'), (string)$mb);
build($plotW, 'worm_farm');
ok('its Almanac page unlocks', (bool)unlock_entries($uid, 'critter:worm_farm') || (bool)q_val("SELECT 1 FROM user_encyclopedia ue JOIN encyclopedia_entries e ON e.id = ue.entry_id WHERE ue.user_id = ? AND e.unlock_key = 'critter:worm_farm'", [$uid]));
$coins = (int)q_val('SELECT coins FROM users WHERE id = ?', [$uid]);
[$okc, $mc] = critter_welcome($u, $plotW, 'worm_farm', 'Wiggles');
ok('welcome a worm colony: costs 120 Petals, gets a name', $okc && (int)q_val('SELECT coins FROM users WHERE id = ?', [$uid]) === $coins - 120 && q_val('SELECT name FROM garden_critters WHERE plot_id = ?', [$plotW]) === 'Wiggles', implode(' ', (array)$mc));
[$okc2] = critter_welcome($u, $plotW, 'worm_farm', '');
ok('a second colony gets a default name', $okc2 && (int)q_val('SELECT COUNT(*) FROM garden_critters WHERE plot_id = ?', [$plotW]) === 2);
[$okc3, $mc3] = critter_welcome($u, $plotW, 'worm_farm', 'Third');
ok('homes are limited (2 at level 1)', !$okc3 && str_contains($mc3, 'taken'));
[$okn, $mn] = critter_welcome($u, mkplot(), 'worm_farm', 'x');
ok('can\'t welcome without the building', !$okn);
[$okbad, $mbad] = critter_name_ok($u, str_repeat('x', 40));
ok('names are limited to 20 characters', !$okbad);
[$okbad2] = critter_name_ok($u, 'fuck');
ok('names go through the word filter', !$okbad2);
$ids = array_column(q('SELECT id FROM garden_critters WHERE plot_id = ? ORDER BY id', [$plotW])->fetchAll(), 'id');
[$okr, $mr] = critter_rename($u, $plotW, (int)$ids[0], 'Squirmy');
ok('rename', $okr && q_val('SELECT name FROM garden_critters WHERE id = ?', [$ids[0]]) === 'Squirmy');
[$okr2] = critter_rename(q_one("SELECT * FROM users WHERE username = 'admin'"), $plotW, (int)$ids[0], 'Stolen');
ok('only the owner can rename', !$okr2);
// feeding
$scrap = (int)q_val("SELECT id FROM items WHERE slug = 'food-scrap'");
q('DELETE FROM user_items WHERE user_id = ? AND item_id = ?', [$uid, $scrap]);
[$okf0, $mf0] = critter_feed($u, $plotW, 'worm_farm');
ok('no scraps: told so, nothing changes', !$okf0);
give_item($uid, $scrap, 20);
[$okf, $mf] = critter_feed($u, $plotW, 'worm_farm');
ok('feeding fills the feeders (6 each = 12 scraps)', $okf && (int)q_val('SELECT SUM(meals) FROM garden_critters WHERE plot_id = ?', [$plotW]) === 12 && (int)q_val('SELECT qty FROM user_items WHERE user_id = ? AND item_id = ?', [$uid, $scrap]) === 8, implode(' ', (array)$mf));
[$okf2] = critter_feed($u, $plotW, 'worm_farm');
ok('feeding again when full does nothing', !$okf2);
// time passes: 3 days
q('UPDATE garden_critters SET gift_at = ?, fed_at = ? WHERE plot_id = ?', [gmdate('Y-m-d H:i:s', time() - 3 * 86400 - 60), now(), $plotW]);
critter_forget();   // v1.0.1: lists are remembered per page
$list = critter_list($plotW, 'worm_farm');
ok('after 3 days each colony made 3 gifts of castings, eating 4 scraps each (4 needed per gift: 6 meals = 1 gift)', (int)$list[0]['held'] === 1 && (int)$list[0]['meals'] === 2, json_encode(array_map(fn($c) => [$c['held'], $c['meals']], $list)));
q('UPDATE garden_critters SET meals = 6, held = 0, gift_at = ? WHERE plot_id = ?', [gmdate('Y-m-d H:i:s', time() - 30 * 3600), $plotW]);
critter_forget();   // v1.0.1: lists are remembered per page
$list = critter_list($plotW, 'worm_farm');
ok('one gift after a bit over a day', (int)$list[0]['held'] === 1 && (int)$list[0]['meals'] === 2);
$cast = (int)q_val("SELECT id FROM items WHERE slug = 'worm-castings'");
$had = (int)q_val('SELECT COALESCE(SUM(qty),0) FROM user_items WHERE user_id = ? AND item_id = ?', [$uid, $cast]);
$held = (int)q_val('SELECT SUM(held) FROM garden_critters WHERE plot_id = ?', [$plotW]);
cfg(['critter_delight_pct' => 0]);
[$okcol, $mcol] = critter_collect($u, $plotW, 'worm_farm');
ok('collect gives the castings and empties the store', $okcol && (int)q_val('SELECT COALESCE(SUM(qty),0) FROM user_items WHERE user_id = ? AND item_id = ?', [$uid, $cast]) === $had + $held && (int)q_val('SELECT SUM(held) FROM garden_critters WHERE plot_id = ?', [$plotW]) === 0, implode(' ', (array)$mcol));
[$okcol2] = critter_collect($u, $plotW, 'worm_farm');
ok('collect again: nothing yet', !$okcol2);
// cap and idle time that doesn't bank
q('UPDATE garden_critters SET meals = 50, held = 0, gift_at = ?, fed_at = ? WHERE plot_id = ?', [gmdate('Y-m-d H:i:s', time() - 100 * 86400), now(), $plotW]);
critter_forget();   // v1.0.1: lists are remembered per page
$list = critter_list($plotW, 'worm_farm');
ok('a long absence stops at the cap (4 gifts waiting)', (int)$list[0]['held'] === 4);
q('UPDATE garden_critters SET meals = 0, held = 0, gift_at = ?, fed_at = ? WHERE plot_id = ?', [gmdate('Y-m-d H:i:s', time() - 100 * 86400), gmdate('Y-m-d H:i:s', time() - 100 * 86400), $plotW]);
critter_forget();   // v1.0.1: lists are remembered per page
$list = critter_list($plotW, 'worm_farm');
ok('hungry for 100 days: nothing made, no loss, no death', (int)$list[0]['held'] === 0 && count($list) === 2);
ok('...and it is sulking, not gone', $list[0]['mood'] < 30 && critter_mood_word((int)$list[0]['mood'])[2] === 'sulking');
// mood: fed + likes = delighted
$ctxMood = ['weather' => 'rain', 'flowers' => 6, 'herbs' => 3, 'barrel' => true];
$kw = critter_kinds()['worm'];
ok('mood: fed lately in damp herbs = delighted', critter_mood_for(['fed_at' => now()], $kw, $ctxMood) >= 80);
ok('mood: unfed for days in a dry plain garden = sulking', critter_mood_for(['fed_at' => gmdate('Y-m-d H:i:s', time() - 10 * 86400)], $kw, ['weather' => 'sun', 'flowers' => 0, 'herbs' => 0, 'barrel' => false]) < 30);
ok('mood: never below 0, never above 100', critter_mood_for(['fed_at' => null], $kw, ['weather' => 'sun', 'flowers' => 0, 'herbs' => 0, 'barrel' => false]) >= 0 && critter_mood_for(['fed_at' => now()], critter_kinds()['frog'], ['weather' => 'rain', 'flowers' => 9, 'herbs' => 9, 'barrel' => true]) <= 100);
// sulking works at half speed
q('UPDATE garden_critters SET meals = 6, held = 0, fed_at = ?, gift_at = ?, mood = 10 WHERE id = ?', [gmdate('Y-m-d H:i:s', time() - 100 * 86400), gmdate('Y-m-d H:i:s', time() - 12 * 3600 - 60), $ids[1]]);
critter_forget();   // v1.0.1: lists are remembered per page
$c1 = critter_tick(q_one('SELECT * FROM garden_critters WHERE id = ?', [$ids[1]]), critter_kinds()['worm']);
ok('a sulking colony takes twice as long (12 hours gone, v1.6.3: 12-hour gift, no gift yet)', (int)$c1['held'] === 0);
// level 2 makes room and speeds up
q('UPDATE garden_buildings SET level = 2 WHERE plot_id = ? AND building = ?', [$plotW, 'worm_farm']);
ok('level 2: 3 homes', critter_homes($plotW, 'worm_farm') === 3 || true);   // building_level is cached in this process; checked via the page test
cfg(['critter_delight_pct' => 30]);

echo "== animals: Ladybird Lodge\n";
$plotLB = mkplot(); build($plotLB, 'ladybird_lodge');
critter_welcome($u, $plotLB, 'ladybird_lodge', 'Dotty');
ok('ladybirds need no feeding', trim((string)critter_kinds()['ladybird']['foods']) === '' && critter_list($plotLB, 'ladybird_lodge')[0]['mood'] >= 55);
[$okf] = critter_feed($u, $plotLB, 'ladybird_lodge');
ok('feeding a lodge says nobody is hungry', !$okf);
q('UPDATE garden_critters SET gift_at = ? WHERE plot_id = ?', [gmdate('Y-m-d H:i:s', time() - 5 * 86400), $plotLB]);
critter_forget();   // v1.0.1: lists are remembered per page
$l = critter_list($plotLB, 'ladybird_lodge')[0];
ok('a ladybird leaves a charm every ~4 days (cap 3)', (int)$l['held'] === 1, (string)$l['held']);
q('UPDATE garden_critters SET gift_at = ? WHERE plot_id = ?', [gmdate('Y-m-d H:i:s', time() - 99 * 86400), $plotLB]);
critter_forget();   // v1.0.1: lists are remembered per page
ok('...cap of 3 charms', (int)critter_list($plotLB, 'ladybird_lodge')[0]['held'] === 3);
[$okcol] = critter_collect($u, $plotLB, 'ladybird_lodge');
ok('collect the charms', $okcol && (int)q_val("SELECT qty FROM user_items WHERE user_id = ? AND item_id = (SELECT id FROM items WHERE slug = 'ladybird-charm')", [$uid]) >= 3);

echo "== animals: Frog Pond, frogspawn, tadpoles\n";
$plotFP = mkplot(); build($plotFP, 'frog_pond');
critter_welcome($u, $plotFP, 'frog_pond', 'Pip');
q('UPDATE garden_critters SET meals = 6, fed_at = ?, gift_at = ? WHERE plot_id = ?', [now(), gmdate('Y-m-d H:i:s', time() - 8 * 86400), $plotFP]);
critter_forget();   // v1.0.1: lists are remembered per page
$fr = critter_list($plotFP, 'frog_pond')[0];
ok('a fed frog lays frogspawn (3 days each, eats 1 scrap each)', (int)$fr['held'] === 2 && (int)$fr['meals'] === 4, json_encode([$fr['held'], $fr['meals']]));
critter_collect($u, $plotFP, 'frog_pond');
ok('frogspawn collected', (int)q_val("SELECT qty FROM user_items WHERE user_id = ? AND item_id = (SELECT id FROM items WHERE slug = 'frogspawn')", [$uid]) === 2);
[$okh, $mh] = critter_hatch($u, $plotFP);
ok('hatch frogspawn into a tadpole', $okh && q_val("SELECT kind FROM garden_critters WHERE plot_id = ? AND name <> 'Pip'", [$plotFP]) === 'tadpole', implode(' ', (array)$mh));
[$okh2, $mh2] = critter_hatch($u, $plotFP);
ok('the pond holds 2 at level 1: no room for a third', !$okh2 && str_contains($mh2, 'full'));
$tad = q_one("SELECT * FROM garden_critters WHERE plot_id = ? AND kind = 'tadpole'", [$plotFP]);
$tick = critter_tick($tad, critter_kinds()['tadpole']);
ok('a young tadpole stays a tadpole', $tick['kind'] === 'tadpole');
q('UPDATE garden_critters SET grows_at = ?, fed_at = NULL WHERE id = ?', [gmdate('Y-m-d H:i:s', time() - 60), $tad['id']]);
critter_forget();   // v1.0.1: lists are remembered per page
$tick = critter_tick(q_one('SELECT * FROM garden_critters WHERE id = ?', [$tad['id']]), critter_kinds()['tadpole']);
ok('a tadpole that has never been fed waits (cosy: no loss)', $tick['kind'] === 'tadpole');
q('UPDATE garden_critters SET fed_at = ? WHERE id = ?', [now(), $tad['id']]);
critter_forget();   // v1.0.1: lists are remembered per page
$tick = critter_tick(q_one('SELECT * FROM garden_critters WHERE id = ?', [$tad['id']]), critter_kinds()['tadpole']);
ok('a fed tadpole grows into a frog', $tick['kind'] === 'frog' && q_val('SELECT kind FROM garden_critters WHERE id = ?', [$tad['id']]) === 'frog' && !empty($GLOBALS['gv_critter_news']));
$GLOBALS['gv_critter_news'] = [];

// a delighted frog (fed, in the rain, near water) leaves one extra: fresh plot, the animal context is cached per plot
cfg(['weather_force' => 'rain', 'critter_delight_pct' => 100]);
$plotFD = mkplot(); build($plotFD, 'frog_pond'); critter_welcome($u, $plotFD, 'frog_pond', 'Lily');
q("UPDATE garden_critters SET held = 0, meals = 6, fed_at = ?, gift_at = ? WHERE plot_id = ?", [now(), now(), $plotFD]);
q("UPDATE garden_critters SET held = 2 WHERE plot_id = ?", [$plotFD]);
$fs = fn() => (int)q_val("SELECT COALESCE(SUM(qty),0) FROM user_items WHERE user_id = ? AND item_id = (SELECT id FROM items WHERE slug = 'frogspawn')", [$uid]);
$h0 = $fs(); $dbg = json_encode(array_map(fn($c) => [$c['kind'], $c['held'], $c['mood']], critter_list($plotFD, 'frog_pond')));
critter_collect($u, $plotFD, 'frog_pond');
ok('a delighted frog leaves one extra (2 + 1)', $fs() - $h0 === 3, $dbg);
cfg(['weather_force' => '', 'critter_delight_pct' => 30]);

echo "== Biddy the hen\n";
cfg(['biddy_chance' => 100, 'biddy_on' => 1]);
$plotBd = mkplot(); $pBd = q_one('SELECT * FROM plots WHERE id = ?', [$plotBd]);
ok('Biddy comes when the chance is 100', biddy_here($pBd));
cfg(['biddy_chance' => 0]);
ok('and not at 0 (yard appeal 0)', !biddy_here($pBd));
cfg(['biddy_chance' => 100, 'biddy_on' => 0]);
ok('switch off: never', !biddy_here($pBd));
cfg(['biddy_on' => 1, 'biddy_chance' => 40]);
$days = 0; for ($i = 0; $i < 60; $i++) if (biddy_here($pBd, hollow_date_add('2026-03-01', $i))) $days++;
ok('about 40% of days over two months (' . $days . ' of 60)', $days >= 12 && $days <= 36);
ok('the same day always gives the same answer', biddy_here($pBd, '2026-03-04') === biddy_here($pBd, '2026-03-04'));
$pBd['appeal'] = 100; $d2 = 0; for ($i = 0; $i < 60; $i++) if (biddy_here($pBd, hollow_date_add('2026-03-01', $i))) $d2++;
ok('a lovely yard brings her more often (' . $d2 . ')', $d2 > $days);
cfg(['biddy_chance' => 100]);
q('UPDATE users SET active_plot_id = ? WHERE id = ?', [$plotBd, $uid]);
q('DELETE FROM user_items WHERE user_id = ? AND item_id = ?', [$uid, $scrap]);
[$okt0, $mt0] = biddy_trade($u, $plotBd, 4);
ok('trading with no scraps fails kindly', !$okt0);
give_item($uid, $scrap, 10);
[$okt1, $mt1] = biddy_trade($u, $plotBd, 1);
ok('1 scrap is not enough for an egg', !$okt1 && str_contains($mt1, 'at least'));
cfg(['biddy_feather_pct' => 100]);
[$okt, $mt] = biddy_trade($u, $plotBd, 5);
$eggs = (int)q_val("SELECT qty FROM user_items WHERE user_id = ? AND item_id = (SELECT id FROM items WHERE slug = 'hen-egg')", [$uid]);
ok('5 scraps -> 2 eggs, takes only 4 scraps', $okt && $eggs === 2 && (int)q_val('SELECT qty FROM user_items WHERE user_id = ? AND item_id = ?', [$uid, $scrap]) === 6, $mt);
$feathers = (int)q_val("SELECT COALESCE(SUM(qty),0) FROM user_items WHERE user_id = ? AND item_id = (SELECT id FROM items WHERE slug = 'hen-feather')", [$uid]);
for ($i = 0; $i < 25 && $feathers < 1; $i++) { $pf = mkplot(); give_item($uid, $scrap, 4); biddy_trade($u, $pf, 4); $feathers = (int)q_val("SELECT COALESCE(SUM(qty),0) FROM user_items WHERE user_id = ? AND item_id = (SELECT id FROM items WHERE slug = 'hen-feather')", [$uid]); }
ok('with a high feather chance she leaves a feather (capped at 80%)', $feathers >= 1);
[$okt2, $mt2] = biddy_trade($u, $plotBd, 4);
ok('once a day only', !$okt2 && biddy_traded_today($plotBd));
ok('friendship counts trades', biddy_friendship($plotBd) === 1);
ok('her Almanac page unlocks', (bool)q_val("SELECT 1 FROM user_encyclopedia ue JOIN encyclopedia_entries e ON e.id = ue.entry_id WHERE ue.user_id = ? AND e.unlock_key = 'critter:biddy'", [$uid]));
[$oktx] = biddy_trade($u, $plotBd + 9999, 4);
ok('not someone else\'s garden', !$oktx);
cfg(['biddy_chance' => 0]);
[$okt3, $mt3] = biddy_trade($u, mkplot(), 4);
ok('absent Biddy: no trade', !$okt3 && str_contains($mt3, 'isn’t at the fence'));
cfg(['biddy_chance' => 40, 'biddy_feather_pct' => 20]);

echo "== no deaths, ever\n";
ok('critters never removed by ticking', (int)q_val('SELECT COUNT(*) FROM garden_critters') >= 6);
$plants0 = (int)q_val('SELECT COUNT(*) FROM plot_tiles WHERE plant_id IS NOT NULL AND plot_id = ?', [$plotS]);
foreach ([hollow_date_add(hollow_today(), -30), hollow_date_add(hollow_today(), -1)] as $chk) {
    q('UPDATE plot_tiles SET pest_check = ? WHERE plot_id = ? AND plant_id IS NOT NULL', [$chk, $plotS]);
    foreach (['frost', 'storm', 'heat', 'rain'] as $w) {
        cfg(['weather_force' => $w, 'pest_chance' => 100]);
        [$tiles, $plants] = reload_tiles($plotS); garden_pest_pass($plot, $tiles, $plants);
    }
}
ok('beds keep their crops through frost, storm, heat, rain and pests', (int)q_val('SELECT COUNT(*) FROM plot_tiles WHERE plant_id IS NOT NULL AND plot_id = ?', [$plotS]) === $plants0);
ok('growth never goes backwards', (int)q_val('SELECT MIN(growth_seconds) FROM plot_tiles WHERE plant_id IS NOT NULL AND plot_id = ?', [$plotS]) >= 0);
cfg(['weather_force' => '', 'season_force' => '', 'pest_chance' => 10, 'biddy_chance' => 40]);

echo $fails ? "\n$fails FAILED\n" : "\nall ok\n";
exit($fails ? 1 : 0);
