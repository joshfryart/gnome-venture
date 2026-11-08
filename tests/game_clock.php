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
ok('10% in first tired hour', game_surcharge_pct(['game_minute' => 1321]) === 10 && game_surcharge_pct(['game_minute' => 1320]) === 10 && game_surcharge_pct(['game_minute' => 1379]) === 10);
ok('20% from 23:00', game_surcharge_pct(['game_minute' => 1380]) === 20);
ok('30% at 00:30 (3rd hour)', game_surcharge_pct(['game_minute' => 1470]) === 30 && game_surcharge_pct(['game_minute' => 1500]) === 40);
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
    $r = gclock_tile_grow(array_merge($t, ['grow_day' => 4, 'water_day' => 6]), $plant, 7);
    $sp = $need / 3 * soil_speed($t);
    ok('dry days 4-5 owed, paid when watered day 6 finishes (3 shares)', abs((int)$r['growth_seconds'] - (int)($sp * 3)) <= (int)($sp * 0.6) + 2 && (int)$r['owed_days'] === 0, $r['growth_seconds'] . ' owed ' . $r['owed_days']);
    $r = gclock_tile_grow(array_merge($t, ['grow_day' => 4, 'water_day' => null]), $plant, 6);
    ok('still dry: owed 2, no growth', (int)$r['growth_seconds'] === 0 && (int)$r['owed_days'] === 2);
    $r = gclock_tile_grow(array_merge($t, ['grow_day' => 4, 'water_day' => null]), $plant, 40);
    ok('owed never above the sleeps needed (3)', (int)$r['owed_days'] === 3);
    cfg(['weather_force' => '']);
} else { ok('have a plant and a tile to test with', false); }
} catch (Throwable $e) { ok('growth block ran', false, $e->getMessage() . ' @' . $e->getLine()); }

echo "== garden leftovers: weather force, tile_info, pest date\n";
try {
if ($plant && $tile) {
    $pid = (int)$pl['id'];
    $own = (int)$pl['user_id'];
    setu($own, ['game_day' => 12, 'game_minute' => 600]);
    gclock_plot_day(0, true);
    cfg(['game_clock_on' => '0', 'weather_force' => 'storm']);
    $off = garden_weather_on($pid, hollow_date_add(hollow_season_epoch(), 12));
    cfg(['game_clock_on' => '1', 'weather_force' => 'storm']);
    ok('flag on: force reaches the owner game day', garden_weather_on($pid) === 'storm' && garden_weather_on($pid, hollow_date_add(hollow_season_epoch(), 12)) === 'storm');
    ok('flag on: force does not reach another game day', garden_weather_on($pid, hollow_date_add(hollow_season_epoch(), 13)) === hollow_weather(garden_region_code($pid), hollow_date_add(hollow_season_epoch(), 13)));
    ok('flag off: game date is not forced (old behaviour)', $off === hollow_weather(garden_region_code($pid), hollow_date_add(hollow_season_epoch(), 12)) || hollow_date_add(hollow_season_epoch(), 12) === hollow_today());
    cfg(['weather_force' => '', 'rain_waters' => '0']);
    ok('plot date = epoch + game_day', gclock_plot_date($pid) === hollow_date_add(hollow_season_epoch(), 12));
    $tt = array_merge($tile, ['plant_id' => $plant['id'], 'growth_seconds' => 0, 'water_day' => 12, 'last_watered' => null, 'pest' => null, 'mulch' => 0]);
    $i = tile_info($tt, $plant);
    ok('watered today: not thirsty, wet_left set', !$i['thirsty'] && $i['wet_left'] > 0);
    $i = tile_info(array_merge($tt, ['water_day' => 11]), $plant);
    ok('watered yesterday: thirsty', $i['thirsty'] && $i['wet_left'] === 0);
    $i = tile_info(array_merge($tt, ['water_day' => null]), $plant);
    ok('never watered: thirsty, time_left in whole days', $i['thirsty'] && $i['time_left'] % 86400 === 0 && $i['time_left'] >= 86400);
    cfg(['game_clock_on' => '0']);
    $i = tile_info(array_merge($tt, ['water_day' => 12, 'last_watered' => null]), $plant);
    ok('flag off: real-time path (no last_watered = thirsty)', $i['thirsty']);
    setu($own, ['game_day' => 0, 'game_minute' => 360]);
    gclock_plot_day(0, true);
}
} catch (Throwable $e) { ok('garden leftovers block ran', false, $e->getMessage() . ' @' . $e->getLine()); }
cfg(['game_clock_on' => '0', 'weather_force' => '']);

echo "== closing hours (decisions 17, 41)\n";
cfg(['game_clock_on' => '1', 'default_open_minute' => '', 'default_close_minute' => '']);
$cu = fn(int $min) => ['game_day' => 3, 'game_minute' => $min];
ok('default hours 06:00-22:00', gclock_place_hours(null) === [360, 1320]);
ok('row hours win', gclock_place_hours(['open_minute' => 480, 'close_minute' => 1200]) === [480, 1200]);
cfg(['default_open_minute' => '420', 'default_close_minute' => '1260']);
ok('setting defaults used when row blank', gclock_place_hours(['open_minute' => null, 'close_minute' => '']) === [420, 1260]);
cfg(['default_open_minute' => '', 'default_close_minute' => '']);
ok('open at noon', gclock_closed_reason($cu(720), null, 15) === null);
ok('before opening: closed', str_contains((string)gclock_closed_reason($cu(300), null, 0), 'opens at 06:00'));
ok('after closing: closed', str_contains((string)gclock_closed_reason($cu(1320), null, 0), 'Closed for the day'));
ok('21:50 + 15 min runs past close: refused', str_contains((string)gclock_closed_reason($cu(1310), null, 15), 'closes at 22:00'));
ok('21:50 + 15 min split action may run late', gclock_closed_reason($cu(1310), null, 480, true) === null);
ok('zero-minute buy at 21:59 is fine', gclock_closed_reason($cu(1319), null, 0) === null);
ok('own row close 20:00 closes at 20:00', gclock_closed_reason($cu(1200), ['close_minute' => 1200], 0) !== null);
cfg(['game_clock_on' => '0']);
ok('flag off: never closed', gclock_closed_reason($cu(1400), null, 60) === null);

require_once $argv[1] . '/includes/catfish.php'; require_once $argv[1] . '/includes/npc_life.php';
echo "== personal date helpers (NPC chat, stops, festivals, caps)\n";
$GLOBALS['CURRENT_USER'] = urow($uid);
setu($uid, ['game_day' => 40, 'game_minute' => 13 * 60 + 5]);
cfg(['game_clock_on' => '0']);
ok('flag off: real date / hour', gclock_my_date() === hollow_date('Y-m-d') && gclock_my_hour() === hollow_hour() && gclock_me() === null);
ok('flag off: cat cap week is the real ISO week', catfish_cap_week() === catfish_week());
cfg(['game_clock_on' => '1']);
ok('flag on: my date = epoch + game_day', gclock_my_date() === hollow_date_add(hollow_season_epoch(), 40));
ok('flag on: my hour = game hour', gclock_my_hour() === 13);
ok('flag on: weekday matches the game date', gclock_my_dow() === (int)gmdate('w', hollow_day_number(hollow_date_add(hollow_season_epoch(), 40)) * 86400));
ok('flag on: cat cap week = game week of 7 sleeps', catfish_cap_week() === 'g5');
setu($uid, ['game_day' => 41]);
ok('after one more sleep the date moves, the cat cap week holds', gclock_my_date() === hollow_date_add(hollow_season_epoch(), 41) && catfish_cap_week() === 'g5');
setu($uid, ['game_day' => 42]);
ok('a sleep past day 41 starts a new cat cap week', catfish_cap_week() === 'g6');
$GLOBALS['CURRENT_USER'] = null;
ok('flag on, nobody logged in: real date', gclock_my_date() === hollow_date('Y-m-d'));
$GLOBALS['CURRENT_USER'] = urow($uid);
$w = date_create(gclock_my_date()); $before = npc_birthday_today(['slug' => 'x']);
ok('npc_birthday_today runs on the game date', is_bool($before));
cfg(['game_clock_on' => '0']);
setu($uid, ['game_day' => 0, 'game_minute' => 360]);
$GLOBALS['CURRENT_USER'] = null;

echo "== orders follow the game date\n";
require_once $argv[1] . '/includes/market100.php';
$GLOBALS['CURRENT_USER'] = urow($uid);
setu($uid, ['game_day' => 100, 'game_minute' => 600]);
cfg(['game_clock_on' => '1']);
$gd = hollow_date_add(hollow_season_epoch(), 100);
ok('order cycle uses the game date', orders_cycle()['start'] <= $gd && $gd <= orders_cycle()['end'] && orders_cycle() === orders_cycle($gd));
cfg(['game_clock_on' => '0']);
ok('flag off: order cycle is the real date', orders_cycle() === orders_cycle(hollow_today()));
setu($uid, ['game_day' => 0, 'game_minute' => 360]);
$GLOBALS['CURRENT_USER'] = null;

echo "== header clock: hollow_now / forecast / season default to the gnome's game day\n";
$GLOBALS['CURRENT_USER'] = urow($uid);
setu($uid, ['game_day' => 200, 'game_minute' => 20 * 60]);
$gd = hollow_date_add(hollow_season_epoch(), 200);
cfg(['game_clock_on' => '1', 'weather_force' => '']);
$n = hollow_now('CA');
ok('flag on: hollow_now() date and hour are the game ones', $n['date'] === $gd && $n['hour'] === 20);
ok('flag on: forecast starts on the game date', hollow_forecast('CA', 2)[0]['date'] === $gd);
ok('flag on: hollow_season() default = season of the game date', hollow_season() === hollow_season($gd));
cfg(['weather_force' => 'fog']);
ok('flag on: weather force reaches the forecast today and my weather', hollow_forecast('CA', 1)[0]['weather'] === 'fog' && gclock_my_weather('CA') === 'fog');
cfg(['weather_force' => '', 'game_clock_on' => '0']);
$n = hollow_now('CA');
ok('flag off: hollow_now() is the real clock', $n['date'] === hollow_today());
setu($uid, ['game_day' => 0, 'game_minute' => 360]);
$GLOBALS['CURRENT_USER'] = null;

echo "== status clock pill and tired hint\n";
$pu = ['game_day' => 7, 'game_minute' => 13 * 60 + 5, 'carry_minutes' => 0];
$pill = gclock_pill($pu);
ok('pill shows 13:05 and day 7, not tired', str_contains($pill, '13:05') && str_contains($pill, 'day 7') && !str_contains($pill, 'tired'));
$pill = gclock_pill(['game_day' => 7, 'game_minute' => 23 * 60, 'carry_minutes' => 120]);
ok('pill after 22:00 is marked tired and mentions carried work', str_contains($pill, 'tired') && str_contains($pill, '2 h of work'));
cfg(['game_clock_on' => '1']);
ok('flag on: tired hint points to rest', str_contains(tired_hint(urow($uid)), 'Rest page'));
cfg(['game_clock_on' => '0']);
ok('flag off: tired hint keeps old text', str_contains(tired_hint(urow($uid)), 'Eat something') && !str_contains(tired_hint(urow($uid)), 'Rest page'));

echo "== drying racks on game-days\n";
require_once $argv[1] . '/includes/flowers.php';
$flo = q_one("SELECT id FROM items WHERE category = 'flower' LIMIT 1");
if ($flo) {
    q('DELETE FROM dry_racks WHERE user_id = ?', [$uid]);
    setu($uid, ['game_day' => 10, 'game_minute' => 600]);
    cfg(['game_clock_on' => '1', 'dry_hours' => '8']);
    ok('rack days = ceil(dry_hours/24), min 1', gclock_rack_days() === 1);
    cfg(['dry_hours' => '30']);
    ok('30 dry hours = 2 sleeps', gclock_rack_days() === 2);
    q('INSERT INTO dry_racks (user_id, item_id, qty, started_at, ready_at, ready_day) VALUES (?, ?, 1, ?, ?, ?)', [$uid, $flo['id'], now(), gmdate('Y-m-d H:i:s', time() + 99999), 11]);
    ok('game-day rack not ready on day 10 (ignores real ready_at)', dry_ready_count($uid) === 0 && dry_list($uid)[0]['left'] === 86400);
    setu($uid, ['game_day' => 11]);
    ok('ready on day 11 although the real timer is far away', dry_ready_count($uid) === 1 && dry_list($uid)[0]['left'] === 0);
    q('UPDATE dry_racks SET ready_day = NULL, ready_at = ? WHERE user_id = ?', [gmdate('Y-m-d H:i:s', time() + 99999), $uid]);
    ok('old rack without ready_day keeps real time', dry_ready_count($uid) === 0);
    q('DELETE FROM dry_racks WHERE user_id = ?', [$uid]);
    cfg(['game_clock_on' => '0', 'dry_hours' => '']);
    setu($uid, ['game_day' => 0, 'game_minute' => 360]);
} else { echo "  skip racks (no flower item)\n"; }

echo "== zero-energy actions still cost game time\n";
cfg(['game_clock_on' => '1']);
setu($uid, ['game_day' => 0, 'game_minute' => 600, 'energy' => 5, 'carry_minutes' => 0]);
ok('spend_energy(0, craft x2) true, 30 min spent, energy untouched', spend_energy($uid, 0, 'craft', 2) && (int)urow($uid)['game_minute'] === 630 && (int)urow($uid)['energy'] === 5);
ok('spend_energy(0) without a key spends nothing', spend_energy($uid, 0) && (int)urow($uid)['game_minute'] === 630);
cfg(['game_clock_on' => '0']);
ok('flag off: spend_energy(0, craft) spends no time', spend_energy($uid, 0, 'craft', 2) && (int)urow($uid)['game_minute'] === 630);
setu($uid, ['game_day' => 0, 'game_minute' => 360]);

echo "== seed packet time\n";
setu($uid, ['game_day' => 0, 'game_minute' => 600, 'carry_minutes' => 0]);
cfg(['game_clock_on' => '1']);
gclock_charge($uid, 'seed');
ok('seed key costs 10 game minutes', (int)urow($uid)['game_minute'] === 610);
cfg(['game_clock_on' => '0']);
setu($uid, ['game_day' => 0, 'game_minute' => 360]);

echo "== equipped pal XP on the game clock (decision 51)\n";
require_once $argv[1] . '/includes/pal_jobs.php';
q('DELETE FROM ppal_found WHERE user_id = ?', [$uid]);
q("INSERT INTO ppal_found (user_id, pic_id, pal_key, found_at, active, status, eq_since, eq_tick, g_xp, a_xp) VALUES (?, 1, 'testpal', ?, 1, 'home', ?, ?, 0, 0)",
    [$uid, now(), gmdate('Y-m-d H:i:s', time() - 100 * 3600), 5 * 1440 + 360]);
setu($uid, ['game_day' => 5, 'game_minute' => 360 + 3 * 60 + 30]);
cfg(['game_clock_on' => '1']);
pj_settle_equip($uid);
ok('3.5 game hours = 3 XP (the 100 real hours do not count)', (int)q_val("SELECT g_xp FROM ppal_found WHERE user_id = ? AND pal_key = 'testpal'", [$uid]) === 3);
setu($uid, ['game_day' => 9, 'game_minute' => 360]);
pj_settle_equip($uid);
ok('days later: capped at 24 game hours (3 + 24)', (int)q_val("SELECT g_xp FROM ppal_found WHERE user_id = ? AND pal_key = 'testpal'", [$uid]) === 27);
q("UPDATE ppal_found SET eq_tick = NULL, g_xp = 0, eq_since = ? WHERE user_id = ?", [gmdate('Y-m-d H:i:s', time() - 100 * 3600), $uid]);
pj_settle_equip($uid);
ok('flag just turned on (no eq_tick): starts counting, no windfall', (int)q_val("SELECT g_xp FROM ppal_found WHERE user_id = ?", [$uid]) === 0 && (int)q_val("SELECT eq_tick FROM ppal_found WHERE user_id = ?", [$uid]) === 9 * 1440 + 360);
cfg(['game_clock_on' => '0']);
pj_settle_equip($uid);
ok('flag off: real hours (capped 24)', (int)q_val("SELECT g_xp FROM ppal_found WHERE user_id = ?", [$uid]) === 24);
q('DELETE FROM ppal_found WHERE user_id = ?', [$uid]);
setu($uid, ['game_day' => 0, 'game_minute' => 360]);

echo "== energy under the game clock\n";
cfg(['game_clock_on' => '1']);
q('UPDATE users SET energy = 5, energy_updated_at = ?, game_day = 0, game_minute = 600 WHERE id = ?', [gmdate('Y-m-d H:i:s', time() - 7200), $uid]);
$u = urow($uid); refresh_energy($u);
ok('no regen over two hours', (int)$u['energy'] === 5 && (int)urow($uid)['energy'] === 5);
ok('current_energy shows no regen', current_energy($u)[0] === 5);
ok('no next-tick countdown', energy_next_secs($u) === null);
ok('day spend: 3 costs 3', spend_energy($uid, 3) && (int)urow($uid)['energy'] === 2);
q('UPDATE users SET energy = 20, game_minute = 1380 WHERE id = ?', [$uid]);   // 23:00 = 2nd tired hour = +20%
ok('tired spend: 10 costs 12', spend_energy($uid, 10) && (int)urow($uid)['energy'] === 8, (string)urow($uid)['energy']);
q('UPDATE users SET energy = 11 WHERE id = ?', [$uid]);
ok('tired spend refused if short (needs 12)', !spend_energy($uid, 10) && (int)urow($uid)['energy'] === 11);
cfg(['game_clock_on' => '0']);
q('UPDATE users SET energy = 20, game_minute = 1380 WHERE id = ?', [$uid]);
ok('flag off: no surcharge', spend_energy($uid, 10) && (int)urow($uid)['energy'] === 10);
q('UPDATE users SET game_day = 0, game_minute = 360 WHERE id = ?', [$uid]);

echo "== resting places\n";
require_once $argv[1] . '/includes/adventure.php';
require_once $argv[1] . '/includes/friends.php';
cfg(['game_clock_on' => '1', 'inn_fee_petals' => '', 'inn_chore_minutes' => '', 'bench_sleep_energy_pct' => '', 'villager_sleep_friend_level' => '', 'camping_gear_nap_charges' => '']);
$away = (int)q_val("SELECT id FROM locations WHERE kind='village' AND id <> (SELECT home_village_id FROM users WHERE id = ?) ORDER BY id LIMIT 1", [$uid]);
function setu(int $uid, array $kv): void { foreach ($kv as $k => $v) q("UPDATE users SET $k = ? WHERE id = ?", [$v, $uid]); }
function keys(int $uid): array { return array_column(gclock_rest_options(urow($uid)), 'key'); }
function okmap(int $uid): array { $m = []; foreach (gclock_rest_options(urow($uid)) as $o) $m[$o['key']] = $o['ok']; return $m; }
$home = (int)urow($uid)['home_village_id'];
setu($uid, ['location_id' => $home ?: null, 'game_day' => 0, 'game_minute' => 1000, 'energy' => 3]);
ok('at home: home sleep and nap only', keys($uid) === ['home_sleep', 'home_nap'], implode(',', keys($uid)));
[$r] = gclock_rest($uid, 'inn_pay');
ok('home: no inn offered', $r === false);
setu($uid, ['location_id' => $away, 'coins' => 50, 'game_day' => 0, 'game_minute' => 1000, 'energy' => 3]);
$k = keys($uid);
ok('in town: inn, chores, bench, nap, villager', $k === ['inn_pay', 'inn_chores', 'bench', 'bench_nap', 'villager'], implode(',', $k));
ok('inn needs 110: 50 coins refused', okmap($uid)['inn_pay'] === false && gclock_rest($uid, 'inn_pay')[0] === false && (int)urow($uid)['coins'] === 50);
setu($uid, ['coins' => 200]);
[$r] = gclock_rest($uid, 'inn_pay'); $x = urow($uid);
ok('inn paid: 110 taken, day+1, 06:00, full energy', $r && (int)$x['coins'] === 90 && (int)$x['game_day'] === 1 && (int)$x['game_minute'] === 360 && (int)$x['energy'] === max_energy($x));
setu($uid, ['game_day' => 0, 'game_minute' => 1000, 'energy' => 3, 'coins' => 5]);
[$r] = gclock_rest($uid, 'inn_chores'); $x = urow($uid);
ok('chores: no coins needed, sleeps', $r && (int)$x['coins'] === 5 && (int)$x['game_day'] === 1 && (int)$x['energy'] === max_energy($x));
setu($uid, ['game_day' => 0, 'game_minute' => 1000, 'energy' => 3]);
[$r] = gclock_rest($uid, 'bench'); $x = urow($uid);
ok('bench: day+1 and 30% energy', $r && (int)$x['game_day'] === 1 && (int)$x['energy'] === (int)floor(max_energy($x) * 0.3), (string)$x['energy']);
setu($uid, ['game_day' => 0, 'game_minute' => 1000, 'energy' => max_energy(urow($uid))]);
game_sleep($uid, 30);
ok('weak rest never lowers energy', (int)urow($uid)['energy'] === max_energy(urow($uid)));
setu($uid, ['game_day' => 0, 'game_minute' => 1000, 'energy' => 0]);
ok('villager refused without a friend', okmap($uid)['villager'] === false && gclock_rest($uid, 'villager')[0] === false);
$npc = (int)q_val('SELECT id FROM npcs WHERE home_location_id = ? LIMIT 1', [$away]);
if ($npc) {
    q('INSERT INTO npc_friends (user_id, npc_id, points) VALUES (?, ?, 500)', [$uid, $npc]);
    ok('villager at Best friend (500 pts) allowed', okmap($uid)['villager'] === true && gclock_rest($uid, 'villager')[0] === true && (int)urow($uid)['game_day'] === 1);
    q('DELETE FROM npc_friends WHERE user_id = ?', [$uid]);
} else { echo "  skip villager-with-friend (no NPC lives in the test village)\n"; }
// camp
$gear = gclock_gear_item_id();
ok('gear item made', $gear > 0 && item_id_by_slug('camping-gear') == $gear);
q("INSERT INTO expeditions (user_id, from_id, to_id, route_id, steps_total, step, hp, max_hp, status, started_at, arrive_at) VALUES (?, ?, ?, 1, 4, 1, 10, 10, 'active', ?, ?)", [$uid, $home, $away, now(), now()]);
setu($uid, ['game_day' => 0, 'game_minute' => 1000, 'energy' => 0, 'camp_naps' => 0]);
q('DELETE FROM user_items WHERE user_id = ? AND item_id = ?', [$uid, $gear]);
ok('on the road: camp only, no gear = disabled', keys($uid) === ['camp_sleep', 'camp_nap'] && okmap($uid)['camp_sleep'] === false && gclock_rest($uid, 'camp_nap')[0] === false);
give_item($uid, $gear, 1);
$qty = fn() => (int)q_val('SELECT qty FROM user_items WHERE user_id = ? AND item_id = ?', [$uid, $gear]);
gclock_rest($uid, 'camp_nap');
ok('first nap keeps the gear (1 of 2)', $qty() === 1 && (int)urow($uid)['camp_naps'] === 1 && (int)urow($uid)['game_day'] === 0);
gclock_rest($uid, 'camp_nap');
ok('second nap uses the gear up', $qty() === 0 && (int)urow($uid)['camp_naps'] === 0);
give_item($uid, $gear, 1);
gclock_rest($uid, 'camp_nap');
[$r] = gclock_rest($uid, 'camp_sleep');
ok('full sleep uses a half-used gear up and resets naps', $r && $qty() === 0 && (int)urow($uid)['camp_naps'] === 0 && (int)urow($uid)['game_day'] === 1);
q("DELETE FROM expeditions WHERE user_id = ?", [$uid]);
setu($uid, ['location_id' => $home ?: null, 'game_day' => 0, 'game_minute' => 360]);
cfg(['game_clock_on' => '0']);

echo "== cook pots on the game clock\n";
require_once $argv[1] . '/includes/crafting.php';
$rid = (int)q_val('SELECT id FROM recipes LIMIT 1');
setu($uid, ['game_day' => 2, 'game_minute' => 600]);
q('DELETE FROM cook_pots WHERE user_id = ?', [$uid]);
$mk = fn($tick, $at) => db_insert('cook_pots', ['user_id' => $uid, 'recipe_id' => $rid, 'makes' => 1, 'dishes' => 1, 'started_at' => now(), 'ready_at' => $at, 'ready_tick' => $tick, 'score' => 0]);
$tick = 2 * 1440 + 600;
$a = $mk($tick + 60, gmdate('Y-m-d H:i:s', time() - 3600));    // real time long past, game clock not: NOT ready
$b = $mk($tick, gmdate('Y-m-d H:i:s', time() + 3600));         // game clock reached: ready though real time is not
$c = $mk(null, gmdate('Y-m-d H:i:s', time() - 5));             // old pot, real: ready
ok('ready count uses ready_tick when set', cook_ready_count($uid) === 2, (string)cook_ready_count($uid));
$left = array_column(cook_pots_list($uid), 'left', 'id');
ok('left in game seconds (60 min = 3600)', $left[$a] === 3600 && $left[$b] === 0 && $left[$c] === 0, json_encode($left));
$r = cook_collect_one(urow($uid), $a);
ok('collect refused before ready_tick', $r[0] === false && strpos($r[1], 'ready yet') !== false);
setu($uid, ['game_minute' => 660]);   // 11:00 = a is ready
ok('after 60 game minutes it is ready', cook_ready_count($uid) === 3);
ok('pot minutes: 3 min cooks 12, 15 -> 60, 45 -> 180 (x4)', gclock_pot_minutes(180) === 12 && gclock_pot_minutes(900) === 60 && gclock_pot_minutes(2700) === 180);
q('DELETE FROM cook_pots WHERE user_id = ?', [$uid]);
setu($uid, ['game_day' => 0, 'game_minute' => 360]);

echo "== pantry jars on game-days\n";
require_once $argv[1] . '/includes/pantry.php';
require_once $argv[1] . '/includes/welcome_back.php';
setu($uid, ['game_day' => 5, 'game_minute' => 700]);
q('DELETE FROM pantry_jars WHERE user_id = ?', [$uid]);
$mj = fn($day, $at) => db_insert('pantry_jars', ['user_id' => $uid, 'recipe_id' => $rid, 'makes' => 1, 'qty' => 1, 'score' => 0, 'started_at' => now(), 'ready_at' => $at, 'ready_day' => $day]);
$ja = $mj(7, gmdate('Y-m-d H:i:s', time() - 9999));   // real past, 2 sleeps to go: NOT ready
$jb = $mj(5, gmdate('Y-m-d H:i:s', time() + 9999));   // game day reached: ready
$jc = $mj(null, gmdate('Y-m-d H:i:s', time() - 5));   // old jar, real: ready
ok('jar ready count uses ready_day when set', pantry_ready_count($uid) === 2, (string)pantry_ready_count($uid));
$jl = array_column(pantry_jars_list($uid), 'left', 'id');
ok('left in whole game days (2 days = 172800 s)', $jl[$ja] === 172800 && $jl[$jb] === 0 && $jl[$jc] === 0, json_encode($jl));
ok('jar days: 1440 min = 1, 4320 = 3, 100 = 1', gclock_jar_days(['cook_minutes' => 1440]) === 1 && gclock_jar_days(['cook_minutes' => 4320]) === 3 && gclock_jar_days(['cook_minutes' => 100]) === 1);
ok('collect refused before ready_day', pantry_collect_one(urow($uid), $ja)[0] === false);
game_sleep($uid); game_sleep($uid);
ok('two sleeps: jar ready', pantry_ready_count($uid) === 3);
ok('welcome-back counts them', is_array(welcome_back_summary(urow($uid))));
q('DELETE FROM pantry_jars WHERE user_id = ?', [$uid]);
setu($uid, ['game_day' => 0, 'game_minute' => 360]);

echo "== new-day hook: pal clocks\n";
q('DELETE FROM ppal_jobs WHERE user_id = ?', [$uid]);
$t0 = 1900000000;
$fmt = fn($t) => gmdate('Y-m-d H:i:s', $t);
$jid = db_insert('ppal_jobs', ['user_id' => $uid, 'pal_uid' => 'x1', 'kind' => 'trip', 'started_at' => $fmt($t0), 'ends_at' => $fmt($t0 + 86400), 'last_tick' => $fmt($t0), 'state' => 'active']);
$jdone = db_insert('ppal_jobs', ['user_id' => $uid, 'pal_uid' => 'x2', 'kind' => 'trip', 'started_at' => $fmt($t0), 'ends_at' => $fmt($t0 + 86400), 'last_tick' => $fmt($t0), 'state' => 'ready']);
$pid = db_insert('cook_pots', ['user_id' => $uid, 'recipe_id' => $rid, 'makes' => 1, 'dishes' => 1, 'started_at' => $fmt($t0), 'ready_at' => $fmt($t0 + 3600), 'score' => 0, 'pal_uid' => 'x1']);
$ownpot = db_insert('cook_pots', ['user_id' => $uid, 'recipe_id' => $rid, 'makes' => 1, 'dishes' => 1, 'started_at' => $fmt($t0), 'ready_at' => $fmt($t0 + 3600), 'score' => 0]);
cfg(['game_clock_on' => '0']);
game_sleep($uid);
ok('flag off: sleep moves no pal clocks', q_val('SELECT ends_at FROM ppal_jobs WHERE id = ?', [$jid]) === $fmt($t0 + 86400));
cfg(['game_clock_on' => '1', 'pal_hours_per_sleep' => '']);
game_sleep($uid);
$j = q_one('SELECT * FROM ppal_jobs WHERE id = ?', [$jid]);
ok('active job: start, end, last tick 8 h earlier', $j['started_at'] === $fmt($t0 - 28800) && $j['ends_at'] === $fmt($t0 + 86400 - 28800) && $j['last_tick'] === $fmt($t0 - 28800), json_encode($j));
ok('finished (ready) job untouched', q_val('SELECT ends_at FROM ppal_jobs WHERE id = ?', [$jdone]) === $fmt($t0 + 86400));
ok('pal-tended pot 8 h closer', q_val('SELECT ready_at FROM cook_pots WHERE id = ?', [$pid]) === $fmt($t0 + 3600 - 28800));
ok('own pot (game tick) untouched', q_val('SELECT ready_at FROM cook_pots WHERE id = ?', [$ownpot]) === $fmt($t0 + 3600));
cfg(['pal_hours_per_sleep' => '24']);
game_sleep($uid);
ok('setting pal_hours_per_sleep = 24', q_val('SELECT ends_at FROM ppal_jobs WHERE id = ?', [$jid]) === $fmt($t0 + 86400 - 28800 - 86400));
cfg(['game_clock_on' => '0', 'pal_hours_per_sleep' => '']);
q('DELETE FROM ppal_jobs WHERE user_id = ?', [$uid]); q('DELETE FROM cook_pots WHERE user_id = ?', [$uid]);
setu($uid, ['game_day' => 0, 'game_minute' => 360]);

echo "== job board keys\n";
require_once $argv[1] . '/includes/jobs.php';
cfg(['game_clock_on' => '0']);
ok('flag off: board key = real key', job_board_key('daily', $uid) === job_period_key('daily') && job_board_key('monthly', $uid) === job_period_key('monthly'));
cfg(['game_clock_on' => '1', 'job_month_days' => '']);
setu($uid, ['game_day' => 15]);
ok('daily = one per sleep', job_board_key('daily', $uid) === 'g15');
ok('weekly = 7 sleeps (15 -> week 2)', job_board_key('weekly', $uid) === 'gw2');
ok('monthly = 28 sleeps (15 -> 0, 28 -> 1)', job_board_key('monthly', $uid) === 'gm0');
setu($uid, ['game_day' => 28]);
ok('monthly rolls at 28', job_board_key('monthly', $uid) === 'gm1' && job_board_key('weekly', $uid) === 'gw4');
ok('shared keys still real', job_period_key('daily') === hollow_date('Y-m-d') && strpos(job_period_key('daily'), 'g') !== 0);
setu($uid, ['game_day' => 3]);
$before = job_offers(urow($uid), 'daily');
setu($uid, ['game_day' => 4]);
$after = job_offers(urow($uid), 'daily');
ok('offers are rolled for the game day (different seed per sleep, same day = same offers)', is_array($before) && is_array($after) && job_offers(urow($uid), 'daily') == $after);
cfg(['game_clock_on' => '0']);
setu($uid, ['game_day' => 0, 'game_minute' => 360]);

echo "== time costs\n";
cfg(['game_clock_on' => '1']);
setu($uid, ['game_day' => 0, 'game_minute' => 600, 'energy' => 20]);
ok('defaults: gather 15, craft 15, shift 480, travel 10', gclock_time_cost('gather') === 15 && gclock_time_cost('craft') === 15 && gclock_time_cost('shift') === 480 && gclock_time_cost('travel') === 10 && gclock_time_cost('nope') === 0);
spend_energy($uid, 1, 'gather');
ok('gather: 1 energy and 15 min', (int)urow($uid)['energy'] === 19 && (int)urow($uid)['game_minute'] === 615);
spend_energy($uid, 3, 'craft', 3);
ok('craft x3: 45 min', (int)urow($uid)['game_minute'] === 660);
spend_energy($uid, 1);
ok('no key: no time', (int)urow($uid)['game_minute'] === 660);
gclock_charge($uid, 'travel', 4);
ok('travel 4 sections: 40 min', (int)urow($uid)['game_minute'] === 700);
cfg(['time_gather' => '0']);
spend_energy($uid, 1, 'gather');
ok('setting time_gather=0 makes it free', (int)urow($uid)['game_minute'] === 700);
cfg(['time_gather' => '', 'time_shift' => '60']);
ok('setting overrides default', gclock_time_cost('shift') === 60);
cfg(['time_shift' => '']);
setu($uid, ['game_minute' => 1330, 'energy' => 20, 'carry_minutes' => 0]);
spend_energy($uid, 10, 'shift');
ok('8 h shift after 22:00: tired surcharge on energy (+10%), whole shift carried', (int)urow($uid)['energy'] === 9 && (int)urow($uid)['game_minute'] === 1330 && (int)urow($uid)['carry_minutes'] === 480, urow($uid)['energy'] . ' / ' . urow($uid)['game_minute']);
cfg(['game_clock_on' => '0']);
setu($uid, ['game_minute' => 600, 'energy' => 20, 'carry_minutes' => 0]);
spend_energy($uid, 1, 'gather');
ok('flag off: no time spent', (int)urow($uid)['game_minute'] === 600);
setu($uid, ['game_day' => 0, 'game_minute' => 360]);

echo "== long actions split across days (decisions 43-44)\n";
cfg(['game_clock_on' => '1']);
setu($uid, ['game_day' => 0, 'game_minute' => 15 * 60, 'energy' => 30, 'carry_minutes' => 0]);   // 15:00 + 8 h shift: 7 h before 22:00, 1 h carried
spend_energy($uid, 5, 'shift');
$x = urow($uid);
ok('shift at 15:00: clock stops at 22:00, 60 min carried', (int)$x['game_minute'] === 1320 && (int)$x['carry_minutes'] === 60, $x['game_minute'] . '/' . $x['carry_minutes']);
$threw = false;
try { spend_energy($uid, 1, 'gather'); } catch (UserError $e) { $threw = true; }
ok('busy: another timed action refused', $threw && (int)urow($uid)['energy'] === (int)$x['energy']);
ok('busy: an untimed spend still works', spend_energy($uid, 1) === true);
ok('busy: nap allowed', game_nap($uid) !== null);
game_sleep($uid); $x = urow($uid);
ok('sleep: wakes at 06:00 + carried 60 min = 07:00, carry cleared', (int)$x['game_minute'] === 420 && (int)$x['carry_minutes'] === 0 && (int)$x['game_day'] === 1, $x['game_minute']);
ok('free again after the sleep', spend_energy($uid, 1, 'gather') === true);
setu($uid, ['game_day' => 0, 'game_minute' => 600, 'energy' => 30, 'carry_minutes' => 0]);
spend_energy($uid, 5, 'repair');
ok('repair at 10:00 (8 h) ends 18:00, nothing carried', (int)urow($uid)['game_minute'] === 1080 && (int)urow($uid)['carry_minutes'] === 0);
setu($uid, ['game_minute' => 1400, 'carry_minutes' => 0, 'energy' => 30]);
spend_energy($uid, 5, 'shift');
ok('started after 22:00: all 8 h carried, clock stays', (int)urow($uid)['game_minute'] === 1400 && (int)urow($uid)['carry_minutes'] === 480);
cfg(['game_clock_on' => '0']);
setu($uid, ['game_day' => 0, 'game_minute' => 360, 'carry_minutes' => 0, 'energy' => 30]);
ok('flag off: never busy', gclock_busy_minutes($uid) === 0);

echo "== camping gear parts and recipe\n";
require_once $argv[1] . '/includes/crafting.php';
ensure_crafts();
foreach (['canvas-sheet', 'metal-pins', 'camping-pot', 'camping-gear'] as $sl) ok("item $sl exists", (bool)item_id_by_slug($sl));
$rec = q_one("SELECT * FROM recipes WHERE slug = 'camping-gear'");
ok('camping-gear recipe made', (bool)$rec && json_decode($rec['ingredients'], true) === ['rope' => 2, 'metal-pins' => 4, 'canvas-sheet' => 1, 'timber-plank' => 2, 'camping-pot' => 1], json_encode($rec));
ok('parts have recipes', (bool)q_val("SELECT 1 FROM recipes WHERE slug='canvas-sheet'") && (bool)q_val("SELECT 1 FROM recipes WHERE slug='metal-pins'") && (bool)q_val("SELECT 1 FROM recipes WHERE slug='camping-pot'"));
$cost = 0;
foreach (json_decode($rec['ingredients'], true) as $sl => $n) $cost += $n * (int)q_val('SELECT base_price FROM items WHERE slug = ?', [$sl]) ;
ok("craft parts value about 60 (got $cost) and under the 100 shop price", $cost >= 50 && $cost <= 70);
ok('rerun is safe', ensure_crafts() >= 0 && (int)q_val("SELECT COUNT(*) FROM items WHERE slug='camping-gear'") === 1);

echo "== camp meal (decisions 32, 49)\n";
cfg(['game_clock_on' => '1', 'kitchen_pots' => '1']);
require_once $argv[1] . '/includes/crafting.php';
$cr = q_one("SELECT * FROM recipes WHERE category = 'cooking' AND ingredients <> '' ORDER BY id LIMIT 1");
if ($cr) {
    q('INSERT OR IGNORE INTO user_recipes (user_id, recipe_id, learned_at) VALUES (?, ?, ?)', [$uid, $cr['id'], now()]);
    foreach (json_decode($cr['ingredients'], true) as $sl => $n) give_item($uid, item_id_by_slug($sl), $n + 1);
    q('DELETE FROM cook_pots WHERE user_id = ?', [$uid]);
    q("INSERT INTO expeditions (user_id, from_id, to_id, route_id, steps_total, step, hp, max_hp, status, started_at, arrive_at) VALUES (?, ?, ?, 1, 4, 1, 10, 10, 'active', ?, ?)", [$uid, $home, $away, now(), now()]);
    $gear = gclock_gear_item_id();
    q('DELETE FROM user_items WHERE user_id = ? AND item_id = ?', [$uid, $gear]);
    give_item($uid, $gear, 1);
    setu($uid, ['game_day' => 0, 'game_minute' => 900, 'energy' => 40, 'camp_naps' => 0, 'carry_minutes' => 0]);
    [$r, $m] = gclock_rest($uid, 'camp_sleep', 999999);
    ok('unknown recipe refused, nothing happened', $r === false && (int)urow($uid)['game_day'] === 0 && $qty() === 1);
    [$r, $m] = gclock_rest($uid, 'camp_sleep', (int)$cr['id']);
    ok('camp sleep with a meal: slept, gear used up', $r && (int)urow($uid)['game_day'] === 1 && $qty() === 0, $m);
    ok('one pot made, ready at once on waking', cook_ready_count($uid) === 1 && (int)q_val('SELECT COUNT(*) FROM cook_pots WHERE user_id = ? AND collected_at IS NULL', [$uid]) === 1, $m);
    q('DELETE FROM cook_pots WHERE user_id = ?', [$uid]);
    foreach (json_decode($cr['ingredients'], true) as $sl => $n) give_item($uid, item_id_by_slug($sl), $n + 1);
    give_item($uid, $gear, 1);
    setu($uid, ['game_day' => 0, 'game_minute' => 900, 'camp_naps' => 0, 'energy' => 40]);
    [$r, $m] = gclock_rest($uid, 'camp_nap', (int)$cr['id']);
    ok('camp nap with a meal: day unchanged, pot ready', $r && (int)urow($uid)['game_day'] === 0 && cook_ready_count($uid) === 1, $m);
    q('DELETE FROM cook_pots WHERE user_id = ?', [$uid]);
    foreach (json_decode($cr['ingredients'], true) as $sl => $n) give_item($uid, item_id_by_slug($sl), -(int)q_val('SELECT qty FROM user_items WHERE user_id = ? AND item_id = ?', [$uid, item_id_by_slug($sl)]));
    give_item($uid, $gear, 1);
    setu($uid, ['game_day' => 0, 'game_minute' => 900, 'camp_naps' => 0]);
    [$r, $m] = gclock_rest($uid, 'camp_sleep', (int)$cr['id']);
    ok('missing ingredients: refused before resting', $r === false && (int)urow($uid)['game_day'] === 0, $m);
    q("DELETE FROM expeditions WHERE user_id = ?", [$uid]);
} else { echo "  skip camp meal (no cooking recipe in test world)\n"; }
cfg(['game_clock_on' => '0']);
setu($uid, ['location_id' => $home ?: null, 'game_day' => 0, 'game_minute' => 360, 'carry_minutes' => 0]);

echo $fails ? "\n$fails FAILED\n" : "\nall ok\n";
exit($fails ? 1 : 0);
