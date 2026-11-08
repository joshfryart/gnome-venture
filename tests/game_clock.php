<?php
// Sleep-days: the personal game clock (includes/game_clock.php). Run by game_clock.sh on a fresh install.
$_SERVER['SCRIPT_NAME'] = '/index.php';
require $argv[1] . '/includes/bootstrap.php';
$fails = 0;
function ok(string $what, bool $cond, string $extra = ''): void { global $fails; echo ($cond ? '  ok   ' : '  FAIL ') . $what . ($cond ? '' : "  $extra") . "\n"; if (!$cond) $fails++; }
function cfg(array $kv): void { foreach ($kv as $k => $v) set_setting($k, (string)$v); setting('__reload__'); }
function urow(int $id): array { return q('SELECT * FROM users WHERE id = ?', [$id])->fetch(); }

echo "== columns\n";
$uid = (int)q_val("SELECT id FROM users WHERE username='sprout'");
$u = urow($uid);
ok('game_day defaults 0', (int)$u['game_day'] === 0);
ok('game_minute defaults 360', (int)$u['game_minute'] === 360);
cfg(['season_epoch' => '2026-01-01', 'tired_surcharge_pct_per_hour' => '', 'nap_minutes' => '', 'nap_energy_pct' => '']);

echo "== state\n";
$s = gclock_state(['game_day' => 14, 'game_minute' => 360]);
ok('date = epoch + 14', $s['date'] === '2026-01-15', $s['date']);
ok('hour 6, tick 14*1440+360', $s['hour'] === 6 && $s['tick'] === 14 * 1440 + 360);
ok('2026-01-15 is a Thursday (4)', $s['dow'] === 4, (string)$s['dow']);
ok('hollow_game_date', hollow_game_date(['game_day' => 0, 'game_minute' => 360]) === '2026-01-01');
ok('not tired at 21:59', !game_is_tired(['game_minute' => 1319]));
ok('tired at 22:00', game_is_tired(['game_minute' => 1320]));
ok('past midnight hour wraps', gclock_state(['game_day' => 0, 'game_minute' => 1500])['hour'] === 1);

echo "== tired surcharge (+10% per hour past 22:00, decision 34)\n";
ok('0% before 22:00', game_surcharge_pct(['game_minute' => 1319]) === 0);
ok('10% in first tired hour', game_surcharge_pct(['game_minute' => 1321]) === 10);
ok('30% at 00:30 (3rd hour)', game_surcharge_pct(['game_minute' => 1470]) === 30);
ok('cost 10 -> 11 at +10%', game_energy_cost(['game_minute' => 1330], 10) === 11);
ok('cost 3 -> 4 (rounds up)', game_energy_cost(['game_minute' => 1330], 3) === 4);
ok('cost unchanged by day', game_energy_cost(['game_minute' => 600], 5) === 5);
ok('cost 0 stays 0', game_energy_cost(['game_minute' => 1500], 0) === 0);

echo "== can spend / closing\n";
ok('open: allowed', game_can_spend(['game_minute' => 600], 60, 1320)[0] === true);
ok('closes mid-action: blocked', game_can_spend(['game_minute' => 1300], 60, 1320)[0] === false);
ok('ends exactly at close: allowed', game_can_spend(['game_minute' => 1260], 60, 1320)[0] === true);
ok('tired never blocks', game_can_spend(['game_minute' => 1400], 480)[0] === true);
ok('tired_after flagged', game_can_spend(['game_minute' => 1200], 180)[2] === true);

echo "== spend (db)\n";
$r = game_spend($uid, 15);
ok('spend 15 -> 375', $r !== null && $r['game_minute'] === 375 && (int)urow($uid)['game_minute'] === 375);
ok('closed place blocks, no change', game_spend($uid, 60, 400) === null && (int)urow($uid)['game_minute'] === 375);
q('UPDATE users SET game_minute = 1400 WHERE id = ?', [$uid]);
ok('long action past midnight allowed', game_spend($uid, 480) !== null && (int)urow($uid)['game_minute'] === 1880);

echo "== sleep\n";
q('UPDATE users SET energy = 1, game_day = 5, game_minute = 1000 WHERE id = ?', [$uid]);
$u = urow($uid);
$r = game_sleep($uid);
$u2 = urow($uid);
ok('day +1, 06:00', $r !== null && (int)$u2['game_day'] === 6 && (int)$u2['game_minute'] === 360);
ok('energy full', (int)$u2['energy'] === max_energy($u2), $u2['energy'] . ' vs ' . max_energy($u2));

echo "== nap\n";
q('UPDATE users SET energy = 0, game_day = 3, game_minute = 700 WHERE id = ?', [$uid]);
$u = urow($uid); $max = max_energy($u);
$r = game_nap($uid); $u2 = urow($uid);
ok('day unchanged, +120 min', $r !== null && (int)$u2['game_day'] === 3 && (int)$u2['game_minute'] === 820);
ok('energy +40% of max', (int)$u2['energy'] === (int)floor($max * 0.4), $u2['energy'] . ' of ' . $max);
q('UPDATE users SET energy = ? WHERE id = ?', [$max - 1, $uid]);
game_nap($uid);
ok('nap never above max', (int)urow($uid)['energy'] === $max);

echo "== race: stale read cannot double-spend\n";
q('UPDATE users SET game_day = 0, game_minute = 360 WHERE id = ?', [$uid]);
$stale = urow($uid);
game_spend($uid, 30);
$n = q('UPDATE users SET game_minute = game_minute + ? WHERE id = ? AND game_day = ? AND game_minute = ?', [30, $uid, (int)$stale['game_day'], (int)$stale['game_minute']])->rowCount();
ok('second tab with old state loses', $n === 0 && (int)urow($uid)['game_minute'] === 390);

echo "== start value\n";
ok('days from epoch', game_clock_days_from_epoch('2026-01-15') === 14);
ok('before epoch -> 0', game_clock_days_from_epoch('2025-12-01') === 0);

echo "== hollow_now with a game state\n";
cfg(['season_mode' => 'game', 'season_days' => 14, 'season_force' => '', 'weather_force' => '']);
$st = gclock_state(['game_day' => 14, 'game_minute' => 1380]);
$n = hollow_now('NA', null, $st);
ok('date from game clock', $n['date'] === '2026-01-15', $n['date']);
ok('hour from game clock (23)', $n['hour'] === 23);
ok('season summer d1', $n['season'] === 'summer' && $n['season_day'] === 1);
ok('night daypart at 23:00', $n['daypart'] === 'night');
$st2 = gclock_state(['game_day' => 14, 'game_minute' => 400]);
ok('same date, same weather for two players', hollow_now('NA', null, $st2)['weather'] === $n['weather']);
ok('null state = real clock', hollow_now('NA')['date'] === hollow_today());
cfg(['weather_force' => 'storm']);
ok('weather force applies to a game date', hollow_now('NA', null, $st)['weather'] === 'storm');
cfg(['weather_force' => '']);

echo "== garden growth on game-days (decisions 52-53)\n";
require_once $argv[1] . '/includes/garden_logic.php';
try {
$pl = q_one('SELECT * FROM plots WHERE user_id = ? ORDER BY id LIMIT 1', [$uid]);
$tile = q_one('SELECT * FROM plot_tiles WHERE plot_id = ? ORDER BY id LIMIT 1', [$pl['id']]);
$plant = q_one('SELECT * FROM plants WHERE grow_minutes = 90 LIMIT 1');
$plant1 = q_one('SELECT * FROM plants WHERE grow_minutes <= 20 LIMIT 1');
cfg(['grow_days_by_tier' => '', 'rain_waters' => '0', 'weather_force' => '']);
ok('tier sleeps 1/2/3/5/7/10', gclock_grow_sleeps(['grow_minutes' => 15]) === 1 && gclock_grow_sleeps(['grow_minutes' => 40]) === 2 && gclock_grow_sleeps(['grow_minutes' => 90]) === 3 && gclock_grow_sleeps(['grow_minutes' => 180]) === 5 && gclock_grow_sleeps(['grow_minutes' => 360]) === 7 && gclock_grow_sleeps(['grow_minutes' => 720]) === 10);
if ($plant && $tile) {
    $t = array_merge($tile, ['plant_id' => $plant['id'], 'growth_seconds' => 0, 'grow_day' => 4, 'water_day' => null, 'pest' => null]);
    $need = (int)$plant['grow_minutes'] * 60;
    $r = gclock_tile_grow($t, $plant, 4);
    ok('same day: no growth, grow_day kept', (int)$r['growth_seconds'] === 0 && (int)$r['grow_day'] === 4);
    $r = gclock_tile_grow($t, $plant, 5);
    ok('slept but unwatered, no rain: no growth', (int)$r['growth_seconds'] === 0 && (int)$r['grow_day'] === 5);
    $w = array_merge($t, ['water_day' => 4]);
    $r = gclock_tile_grow($w, $plant, 5);
    $one = $need / 3 * soil_speed($w) * garden_day_fx($w, $plant, hollow_date_add(hollow_season_epoch(), 4))['speed'];
    ok('watered day 4, slept once: one share', abs((int)$r['growth_seconds'] - (int)$one) <= 1, $r['growth_seconds'] . ' vs ' . (int)$one);
    $r = gclock_tile_grow(array_merge($t, ['water_day' => 9]), $plant, 5);
    ok('watered on a later day than any slept: no growth', (int)$r['growth_seconds'] === 0);
    $r = gclock_tile_grow(array_merge($w, ['growth_seconds' => $need - 1]), $plant, 8);
    ok('growth capped at grow_minutes*60', (int)$r['growth_seconds'] <= $need);
    $r = gclock_tile_grow(array_merge($t, ['grow_day' => null]), $plant, 10);
    ok('no grow_day yet: starts today, no back-growth', (int)$r['growth_seconds'] === 0 && (int)$r['grow_day'] === 10);
    cfg(['weather_force' => '']);
} else { ok('have a plant and a tile to test with', false); }
} catch (Throwable $e) { ok('growth block ran', false, $e->getMessage() . ' @' . $e->getLine()); }

echo $fails ? "\n$fails FAILED\n" : "\nall ok\n";
exit($fails ? 1 : 0);
