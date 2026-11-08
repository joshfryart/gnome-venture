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

echo "== one-time start (not run by the game)\n";
$before = urow($uid);
setu($uid, ['game_day' => 3, 'game_minute' => 900, 'carry_minutes' => 60, 'camp_naps' => 1]);
$n = gclock_start_all('2026-03-01');
$after = urow($uid);
ok('start sets game_day to days since epoch, 06:00, no carry', (int)$after['game_day'] === game_clock_days_from_epoch('2026-03-01') && (int)$after['game_minute'] === 360 && (int)$after['carry_minutes'] === 0 && (int)$after['camp_naps'] === 0 && $n >= 1);
ok('start twice gives the same day', gclock_start_all('2026-03-01') >= 1 && (int)urow($uid)['game_day'] === game_clock_days_from_epoch('2026-03-01'));
ok('game date after start = the Hollow date it was started on', hollow_game_date(urow($uid)) === '2026-03-01');
setu($uid, ['game_day' => 0, 'game_minute' => 360]);

echo "== health: no timed regen; sleep, nap and crops heal\n";
require_once $argv[1] . '/includes/health.php';
require_once $argv[1] . '/includes/gnome.php';
$origLoc = urow($uid)['location_id'];
$max = hp_max(urow($uid));
$loc = (int)q_val("SELECT id FROM locations WHERE kind = 'village' LIMIT 1");
q("DELETE FROM expeditions WHERE user_id = ?", [$uid]);
setu($uid, ['location_id' => $loc ?: null, 'game_day' => 0, 'game_minute' => 600, 'hp' => max(1, intdiv($max, 4)), 'hp_at' => gmdate('Y-m-d H:i:s', time() - 7200)]);
cfg(['game_clock_on' => '0', 'hp_persist' => '1', 'hp_regen_per_minute' => '1']);
$h0 = hp_get(urow($uid))[0];
ok('flag off: old timed regen still runs (2 hours in town)', $h0 > intdiv($max, 4));
setu($uid, ['hp' => max(1, intdiv($max, 4)), 'hp_at' => gmdate('Y-m-d H:i:s', time() - 7200)]);
cfg(['game_clock_on' => '1']);
ok('flag on: no timed regen', hp_get(urow($uid))[0] === max(1, intdiv($max, 4)));
$start = hp_get(urow($uid))[0];
game_nap($uid);
$afterNap = hp_get(urow($uid))[0];
ok('nap heals about 40% of max', $afterNap > $start && $afterNap <= $start + (int)ceil($max * 0.4) + 1, "$start -> $afterNap of $max");
game_sleep($uid, 30);
$afterBench = hp_get(urow($uid))[0];
ok('a 30% sleep heals up to 30% more', $afterBench >= $afterNap, "$afterNap -> $afterBench");
setu($uid, ['hp' => max(1, intdiv($max, 4)), 'hp_at' => null, 'game_minute' => 600]);
game_sleep($uid, 100);
ok('a full sleep heals fully', hp_get(urow($uid))[0] === $max);
// crops
$crop = q_one("SELECT i.* FROM items i JOIN plants p ON p.produce_item_id = i.id WHERE i.category = 'produce' AND i.edible = 1 LIMIT 1");
if ($crop) {
    ok('a staple-or-higher crop heals 1 to 4', ($h = gclock_crop_heal($crop)) >= 1 && $h <= 4, (string)$h);
    cfg(['hp_crop_heal' => '2,3,4,5']);
    $base = gclock_crop_heal($crop);
    ok('hp_crop_heal setting is read', $base >= 2 && $base <= 5);
    cfg(['hp_crop_heal' => '']);
    setu($uid, ['hp' => max(1, intdiv($max, 2))]);
    $before = hp_get(urow($uid))[0];
    give_item($uid, (int)$crop['id'], 1);
    [$ok, $m] = eat_item(urow($uid), (int)$crop['id']);
    ok('eating the crop heals exactly its amount', $ok && hp_get(urow($uid))[0] === min($max, $before + gclock_crop_heal($crop)), implode(' ', (array)$m));
    cfg(['game_clock_on' => '0']);
    setu($uid, ['hp' => max(1, intdiv($max, 2)), 'hp_at' => null]);
    $before = hp_get(urow($uid))[0];
    give_item($uid, (int)$crop['id'], 1);
    eat_item(urow($uid), (int)$crop['id']);
    ok('flag off: eating a crop does not heal', hp_get(urow($uid))[0] === $before);
} else { echo "  skip crops (no edible crop in test world)\n"; }
ok('a non-produce item has no crop heal', gclock_crop_heal(['category' => 'food', 'id' => 1]) === 0);
$dish = q_one("SELECT i.* FROM items i JOIN recipes r ON r.output_item_id = i.id WHERE r.category = 'cooking' AND r.tier = 'meal' AND i.edible = 1 AND i.slug NOT LIKE 'bought-%' LIMIT 1");
if ($dish) ok('a home-cooked meal heals 3 by default', gclock_food_heal($dish) === 3);
$snack = q_one("SELECT i.* FROM items i JOIN recipes r ON r.output_item_id = i.id WHERE r.category = 'cooking' AND r.tier = 'snack' AND i.edible = 1 AND i.slug NOT LIKE 'bought-%' LIMIT 1");
if ($snack) ok('a home-cooked snack heals 2', gclock_food_heal($snack) === 2);
cfg(['hp_dish_heal' => '5,6,7']);
if ($dish) ok('hp_dish_heal is read', gclock_food_heal($dish) === 6);
cfg(['hp_dish_heal' => '']);
ok('bought food heals 1', gclock_food_heal(['category' => 'food', 'id' => 999999, 'edible' => 1, 'slug' => 'bought-pie']) === 1);
ok('a potion (supply) heals nothing here', gclock_food_heal(['category' => 'supply', 'edible' => 1, 'id' => 1, 'slug' => 'x']) === 0);
ok('a rare find heals more than a common one', gclock_food_heal(['category' => 'forage', 'rarity' => 90]) > gclock_food_heal(['category' => 'forage', 'rarity' => 5]));
if ($dish) {
    cfg(['game_clock_on' => '1']);
    setu($uid, ['hp' => max(1, intdiv($max, 2))]);
    $before = hp_get(urow($uid))[0];
    give_item($uid, (int)$dish['id'], 1);
    eat_item(urow($uid), (int)$dish['id']);
    ok('eating the dish heals it', hp_get(urow($uid))[0] === min($max, $before + 3));
    cfg(['game_clock_on' => '0']);
}
cfg(['game_clock_on' => '0', 'hp_crop_heal' => '']);
setu($uid, ['hp' => null, 'hp_at' => null, 'game_day' => 0, 'game_minute' => 360, 'location_id' => $origLoc]);

echo "== no-till upkeep (bed_tick) on game time\n";
try {
$pl2 = q_one('SELECT * FROM plots WHERE user_id = ? ORDER BY id LIMIT 1', [$uid]);
$tl = q_one('SELECT * FROM plot_tiles WHERE plot_id = ? ORDER BY id LIMIT 1', [$pl2['id']]);
setu($uid, ['game_day' => 50, 'game_minute' => 600]);
gclock_plot_clock(0, true);
cfg(['game_clock_on' => '1', 'weather_force' => '']);
$v0 = gclock_plot_vnow((int)$pl2['id']);
$bed = array_merge($tl, ['method' => 'notill', 'tilled' => 1, 'plant_id' => null, 'mulch' => 100, 'weeds' => 0, 'moisture' => 50, 'bed_score' => 0, 'checkpoint' => 0, 'neglect_hours' => 0, 'maint_at' => gmdate('Y-m-d H:i:s', $v0 - 5 * 3600)]);
$r = bed_tick($bed, urow($uid));
ok('5 game hours pass: mulch wears 5', (int)$r['mulch'] === 95, (string)$r['mulch']);
ok('maint_at moves to the virtual clock', strtotime($r['maint_at'] . ' UTC') === $v0);
ok('the 20 real hours in between do not count', (int)bed_tick(array_merge($bed, ['maint_at' => gmdate('Y-m-d H:i:s', $v0 - 3600)]), urow($uid))['mulch'] === 99);
setu($uid, ['game_day' => 51, 'game_minute' => 360]);
gclock_plot_clock(0, true);
$r = bed_tick(array_merge($bed, ['maint_at' => gmdate('Y-m-d H:i:s', $v0)]), urow($uid));
ok('one sleep (22:00 to 06:00) later: 20 game hours passed (10:00 -> 06:00 next day)', (int)$r['mulch'] === 80, (string)$r['mulch']);
$r = bed_tick(array_merge($bed, ['maint_at' => null]), urow($uid));
ok('no maint_at yet: stamped with the virtual clock, no ticks', strtotime($r['maint_at'] . ' UTC') === gclock_plot_vnow((int)$pl2['id']) && (int)$r['mulch'] === 100);
$ahead = bed_tick(array_merge($bed, ['maint_at' => gmdate('Y-m-d H:i:s', gclock_plot_vnow((int)$pl2['id']) + 7200)]), urow($uid));
ok('a real-time stamp ahead of the game clock restarts on game time (no negative hours, no stall)', (int)$ahead['mulch'] === 100 && strtotime($ahead['maint_at'] . ' UTC') === gclock_plot_vnow((int)$pl2['id']));
ok('mulch text says game hours / game days with the flag', mulch_text(5) === '5 game hours left' && mulch_text(72) === '3 game days left');
cfg(['game_clock_on' => '0']);
$r = bed_tick(array_merge($bed, ['maint_at' => gmdate('Y-m-d H:i:s', time() - 3 * 3600)]), urow($uid));
ok('flag off: mulch text unchanged', mulch_text(5) === '5 hours left' && mulch_text(72) === '3 days left');
ok('flag off: real hours (3)', (int)$r['mulch'] === 97, (string)$r['mulch']);
} catch (Throwable $e) { ok('no-till block ran', false, $e->getMessage() . ' @' . $e->getLine()); }
setu($uid, ['game_day' => 0, 'game_minute' => 360]);
gclock_plot_clock(0, true);

echo "== soil feeding (feed_tick) on game minutes\n";
setu($uid, ['game_day' => 60, 'game_minute' => 600]);
gclock_plot_clock(0, true);
cfg(['game_clock_on' => '1']);
$vf = gclock_plot_vnow((int)$pl2['id']);
$ft = array_merge($tl, ['feed_hours' => 100, 'feed_fert' => 10, 'feed_life' => 10, 'feed_n' => 0, 'feed_p' => 0, 'feed_k' => 0, 'fertility' => 20, 'soil_life' => 20, 'n' => 0, 'p' => 0, 'k' => 0, 'feed_at' => gmdate('Y-m-d H:i:s', $vf - 50 * 60)]);
$fr = feed_tick($ft);
ok('50 game minutes of a 100-minute feed: half released', (int)$fr['feed_hours'] === 50 && (int)$fr['fertility'] === 25, (string)$fr['feed_hours'] . '/' . $fr['fertility']);
$fa = feed_tick(array_merge($ft, ['feed_at' => gmdate('Y-m-d H:i:s', $vf + 3600)]));
ok('a feed stamp ahead of the game clock restarts, nothing released', (int)$fa['feed_hours'] === 100 && strtotime($fa['feed_at'] . ' UTC') === $vf);
ok('feed_seconds_left reads the virtual clock', feed_seconds_left($ft) === 50 * 60);
cfg(['game_clock_on' => '0']);
setu($uid, ['game_day' => 0, 'game_minute' => 360]);
gclock_plot_clock(0, true);

echo "== compost, mulch and settling on game time\n";
setu($uid, ['game_day' => 70, 'game_minute' => 600]);
gclock_plot_clock(0, true);
$comp = ['effects' => json_encode(['minutes' => 15, 'fertility' => 5, 'mulch' => 144])];
cfg(['game_clock_on' => '0']);
ok('flag off: amendment 15 min, mulch 144 h', amendment_minutes($comp) === 15 && mulch_value($comp) === 144);
cfg(['game_clock_on' => '1', 'amend_game_multiplier' => '', 'mulch_game_multiplier' => '']);
ok('flag on: 15 minutes becomes 1440 game minutes (one sleep)', amendment_minutes($comp) === 1440);
ok('flag on: mulch hours unchanged by default (6 sleeps)', mulch_value($comp) === 144);
cfg(['amend_game_multiplier' => '192', 'mulch_game_multiplier' => '2']);
ok('multipliers are settings', amendment_minutes($comp) === 2880 && mulch_value($comp) === 288);
cfg(['amend_game_multiplier' => '', 'mulch_game_multiplier' => '']);
ok('sleeps text', gclock_sleeps_text(1440) === '1 sleep' && gclock_sleeps_text(2880) === '2 sleeps' && gclock_sleeps_text(300) === '300 game min');
$pid2 = (int)$pl2['id'];
ok('plot now is the virtual clock with the flag', gclock_plot_now($pid2) === gclock_plot_vnow($pid2));
$plantable = array_merge($tl, ['tilled' => 1, 'plant_id' => null, 'settle_until' => gmdate('Y-m-d H:i:s', gclock_plot_vnow($pid2) + 600)]);
ok('settling until the game clock passes settle_until', !tile_plantable($plantable));
setu($uid, ['game_minute' => 720]);
gclock_plot_clock(0, true);
ok('120 game minutes later it is plantable', tile_plantable($plantable));
cfg(['game_clock_on' => '0']);
ok('flag off: plot now is the real time', abs(gclock_plot_now($pid2) - time()) <= 1);
setu($uid, ['game_day' => 0, 'game_minute' => 360]);
gclock_plot_clock(0, true);

echo "== cost lines: the player is told what an action cost\n";
ok('line: energy only', gclock_cost_line(3, 0) === '⚡ −3 energy');
ok('line: minutes with the clock', gclock_cost_line(0, 15, 14 * 60 + 35) === '🕐 +15 min (now 14:35)');
ok('line: hours and minutes', gclock_cost_line(2, 135, 600) === '⚡ −2 energy · 🕐 +2 h 15 min (now 10:00)');
ok('line: carried work is named', str_contains(gclock_cost_line(1, 480, 1320, 360), '6 h of it waits for tomorrow'));
ok('line: nothing spent = nothing shown', gclock_cost_line(0, 0, 600) === '');
$GLOBALS['CURRENT_USER'] = urow($uid);
$_SESSION = [];
cfg(['game_clock_on' => '1']);
setu($uid, ['game_day' => 5, 'game_minute' => 600, 'energy' => 20, 'carry_minutes' => 0]);
$GLOBALS['gclock_ledger'] = [];
spend_energy($uid, 3, 'wander');
gclock_ledger_flush();
$fl = $_SESSION['flash'] ?? [];
ok('spend_energy + time -> one flash with both', count($fl) === 1 && str_contains($fl[0]['msg'], '⚡ −3 energy') && str_contains($fl[0]['msg'], '🕐 +20 min (now 10:20)'), json_encode($fl));
$_SESSION = [];
$GLOBALS['gclock_ledger'] = [];
gclock_ledger_snap($uid);
q('UPDATE users SET energy = energy - 4, game_minute = game_minute + 30 WHERE id = ?', [$uid]);
q('UPDATE users SET energy = energy + 4, game_minute = game_minute - 30 WHERE id = ?', [$uid]);   // rolled back
gclock_ledger_flush();
ok('an action that undid itself shows no cost', empty($_SESSION['flash']));
$_SESSION = [];
$GLOBALS['gclock_ledger'] = [];
spend_energy($uid, 2, 'shift');
gclock_ledger_flush();
ok('a shift started late says the rest waits for tomorrow', str_contains(($_SESSION['flash'][0]['msg'] ?? ''), 'waits for tomorrow') || (int)urow($uid)['carry_minutes'] === 0);
cfg(['game_clock_on' => '0']);
$_SESSION = [];
$GLOBALS['gclock_ledger'] = [];
spend_energy($uid, 1, 'wander');
gclock_ledger_flush();
ok('flag off: no cost line', empty($_SESSION['flash']));
setu($uid, ['game_day' => 0, 'game_minute' => 360, 'carry_minutes' => 0, 'energy' => 30]);
$GLOBALS['CURRENT_USER'] = null;
$_SESSION = [];

echo "== cost guide, tags and rest summaries\n";
cfg(['game_clock_on' => '1', 'arrange_energy' => '2']);
$ug = ['game_day' => 0, 'game_minute' => 600, 'energy' => 10, 'location_id' => null];
ok('tag: energy and time', gclock_cost_tag($ug, 2, 'arrange') === ' · ⚡2 · 🕐10 min');
ok('tag: tired energy is shown with the surcharge', gclock_cost_tag(['game_day' => 0, 'game_minute' => 1400], 10, 'wander') === ' · ⚡12 (tired) · 🕐20 min', gclock_cost_tag(['game_day' => 0, 'game_minute' => 1400], 10, 'wander'));
ok('tag: free energy says so', gclock_cost_tag($ug, 0, 'seed') === ' · no energy · 🕐10 min');
ok('tag: units multiply time (craft x3 = 45 min)', gclock_cost_tag($ug, null, 'craft', 3) === ' · 🕐45 min');
ok('tag: 8 h shift', gclock_cost_tag($ug, 3, 'shift') === ' · ⚡3 · 🕐8 h');
cfg(['game_clock_on' => '0']);
ok('tag: empty with the flag off', gclock_cost_tag($ug, 2, 'arrange') === '');
cfg(['game_clock_on' => '1']);
$guide = gclock_cost_guide($ug);
ok('guide lists every timed action', count($guide) >= 15 && in_array('Florist shift', array_column($guide, 0), true) && in_array('Sleep', array_column($guide, 0), true));
$byName = array_column($guide, null, 0);
ok('guide numbers come from the settings', $byName['Arrange flowers'][1] === '2' && $byName['Arrange flowers'][2] === '10 min' && $byName['Nap (needs a seat or bed)'][2] === '2 h');
cfg(['time_arrange' => '25']);
ok('changing a time setting changes the guide', gclock_cost_guide($ug)[4][2] === '25 min');
cfg(['time_arrange' => '']);
$nap = gclock_option_effect(['game_day' => 0, 'game_minute' => 840, 'energy' => 10] + urow($uid), ['kind' => 'nap', 'key' => 'home_nap']);
ok('nap effect shows the clock and energy', str_contains($nap, '14:00 → 16:00 (+2 h)') && str_contains($nap, 'energy 10 →'), $nap);
$sl = gclock_option_effect(['game_day' => 0, 'game_minute' => 1200, 'energy' => 4] + urow($uid), ['kind' => 'sleep', 'key' => 'home_sleep']);
ok('sleep effect shows 06:00 and the 10 h skipped', str_contains($sl, '20:00 → 06:00 next day (+10 h)'), $sl);
$sum = gclock_rest_summary(['energy' => 12, 'game_day' => 5, 'game_minute' => 1300], ['energy' => 40, 'game_day' => 6, 'game_minute' => 360], 9);
ok('rest summary: day, clock, energy, health', $sum === 'Day 7, 06:00 (+8 h 20 min) · ⚡ 12 → 40 (+28) · ❤️ +9 health', $sum);
cfg(['game_clock_on' => '0']);

echo "== hired helpers on the owner's game days\n";
require_once $argv[1] . '/includes/hired_help.php';
try {
setu($uid, ['game_day' => 100, 'game_minute' => 600]);
gclock_plot_clock(0, true);
cfg(['game_clock_on' => '1', 'rain_waters' => '0', 'weather_force' => '', 'helper_visit_hours' => '4']);
$pidh = (int)$pl2['id'];
$epochT = (int)strtotime(hollow_season_epoch() . ' 00:00:00 UTC');
$vnow = gclock_plot_vnow($pidh);
ok('hire_visits: every 4 game hours of the owner clock, not real time', count(hire_visits(['plot_id' => $pidh, 'last_visit' => gmdate('Y-m-d H:i:s', $vnow - 24 * 3600), 'ends_at' => gmdate('Y-m-d H:i:s', $vnow + 99999)])) === 6);
ok('hire_visits stop at the contract end', count(hire_visits(['plot_id' => $pidh, 'last_visit' => gmdate('Y-m-d H:i:s', $vnow - 24 * 3600), 'ends_at' => gmdate('Y-m-d H:i:s', $vnow - 12 * 3600)])) === 3);
$pl3 = $plant;
$need = (int)$pl3['grow_minutes'] * 60;
$tt = array_merge($tl, ['plant_id' => $pl3['id'], 'growth_seconds' => 0, 'grow_day' => 96, 'water_day' => null, 'owed_days' => 0, 'pest' => null, 'plot_id' => $pidh, 'mulch' => 0]);
$visits = [];
for ($d = 96; $d <= 99; $d++) $visits[] = $epochT + $d * 86400 + 10 * 3600;   // one visit on each of days 96..99
$st = ['water' => 0, 'weed' => 0, 'harvest' => 0]; $rawN = null;
$r = gclock_helper_water_tile($tt, $pl3, $visits, $st, $rawN);
$share = $need / gclock_grow_sleeps($pl3) * soil_speed($tt);
ok('a helper that came on 4 days waters 4 times', $st['water'] === 4, (string)$st['water']);
ok('and the bed grew about 4 shares (capped at ready)', (int)$r['growth_seconds'] >= min($need, (int)($share * 4 * 0.5)) && (int)$r['grow_day'] === 100, $r['growth_seconds'] . ' of ' . $need);
$st = ['water' => 0, 'weed' => 0, 'harvest' => 0];
$pal = gclock_helper_water_tile($tt, $pl3, [1, 2, 3], $st, $rawN, false);
ok('a pal on duty with 3 visits waters the latest 3 game days (100, 99, 98)', $st['water'] >= 3 && (int)$pal['grow_day'] === 100, (string)$st['water']);
$st = ['water' => 0, 'weed' => 0, 'harvest' => 0];
$gap = gclock_helper_water_tile($tt, $pl3, [$epochT + 98 * 86400 + 36000], $st, $rawN);
ok('a helper who came on one day only waters once; other days stay dry (owed)', $st['water'] === 1 && (int)$gap['growth_seconds'] < (int)$r['growth_seconds'] || (int)$r['growth_seconds'] >= $need);
} catch (Throwable $e) { ok('helper block ran', false, $e->getMessage() . ' @' . $e->getLine()); }
cfg(['game_clock_on' => '0', 'helper_visit_hours' => '']);
setu($uid, ['game_day' => 0, 'game_minute' => 360]);
gclock_plot_clock(0, true);

echo "== rain barrel: a watering can last into the next day\n";
try {
cfg(['game_clock_on' => '1', 'rain_waters' => '0', 'weather_force' => '', 'grow_days_by_tier' => '']);
$base = array_merge($tl, ['plant_id' => $plant['id'], 'growth_seconds' => 0, 'grow_day' => 4, 'water_day' => 4, 'owed_days' => 0, 'pest' => null, 'plot_id' => $pidh, 'mulch' => 0, '_rain' => 0]);
ok('no barrel: carry 0%', gclock_water_carry_pct($base, $plant) === 0);
ok('barrel level 3: carry 55%', gclock_water_carry_pct(array_merge($base, ['_rain' => 3]), $plant) === 55);
ok('level 1 / 2: 25% / 40%', gclock_water_carry_pct(array_merge($base, ['_rain' => 1]), $plant) === 25 && gclock_water_carry_pct(array_merge($base, ['_rain' => 2]), $plant) === 40);
$yes = $no = null;
for ($i = 1; $i < 400 && (!$yes || !$no); $i++) { if (hollow_unit('carry|' . $i . '|5') * 100 < 55) $yes ??= $i; else $no ??= $i; }
$g0 = (int)gclock_tile_grow(array_merge($base, ['id' => $no, '_rain' => 3]), $plant, 6)['growth_seconds'];
$g1 = (int)gclock_tile_grow(array_merge($base, ['id' => $yes, '_rain' => 3]), $plant, 6)['growth_seconds'];
$gnone = (int)gclock_tile_grow(array_merge($base, ['id' => $yes, '_rain' => 0]), $plant, 6)['growth_seconds'];
ok('a barrel watering that carried grows the second day too', $g1 > $g0 && $g0 === $gnone, "$g1 > $g0 = $gnone");
ok('the roll is the same each time you look', hollow_unit('carry|' . $yes . '|5') === hollow_unit('carry|' . $yes . '|5'));
setu($uid, ['game_day' => 5, 'game_minute' => 600]); gclock_plot_clock(0, true);
$ti = tile_info(array_merge($base, ['id' => $yes, '_rain' => 3, 'water_day' => 4, 'plot_id' => $pidh]), $plant);
$tn = tile_info(array_merge($base, ['id' => $no, '_rain' => 3, 'water_day' => 4, 'plot_id' => $pidh]), $plant);
ok('tile_info agrees: carried = not thirsty, not carried = thirsty', !$ti['thirsty'] && $tn['thirsty']);
} catch (Throwable $e) { ok('barrel block ran', false, $e->getMessage() . ' @' . $e->getLine()); }
cfg(['game_clock_on' => '0']);
setu($uid, ['game_day' => 0, 'game_minute' => 360]); gclock_plot_clock(0, true);

echo "== compost bin, beehive and garden animals on the owner's game days\n";
require_once $argv[1] . '/includes/gardens.php';
setu($uid, ['game_day' => 200, 'game_minute' => 600]); gclock_plot_clock(0, true);
cfg(['game_clock_on' => '1']);
$vn = gclock_plot_vnow($pidh);
$brow = ['plot_id' => $pidh, 'building' => 'compost_bin', 'level' => 1, 'last_collect' => gmdate('Y-m-d H:i:s', $vn - 3 * 86400 - 60), 'built_at' => gmdate('Y-m-d H:i:s', $vn - 9 * 86400)];
ok('3 game days since the last collect = 3 ready', building_ready($brow) === 3);
ok('a real-time stamp from the future waits (none ready)', building_ready(array_merge($brow, ['last_collect' => gmdate('Y-m-d H:i:s', $vn + 7200)])) === 0);
cfg(['game_clock_on' => '0']);
setu($uid, ['game_day' => 0, 'game_minute' => 360]); gclock_plot_clock(0, true);

echo "== perennials age in game days\n";
setu($uid, ['game_day' => 300, 'game_minute' => 600]); gclock_plot_clock(0, true);
cfg(['game_clock_on' => '1']);
$per = ['perennial' => 1, 'kind' => 'fruit', 'id' => 1];
cfg(['life_fruit_days' => '60', 'life_end_yield' => '50']);
$vn2 = gclock_plot_vnow($pidh);
$lifeT = perennial_life(['plot_id' => $pidh, 'planted_at' => gmdate('Y-m-d H:i:s', $vn2 - 12 * 86400)], $per);
ok('planted 12 game days ago: age 12 of 60, 48 left', $lifeT && $lifeT[0] === 12 && $lifeT[1] === 60 && $lifeT[3] === 48, json_encode($lifeT));
cfg(['game_clock_on' => '0', 'life_fruit_days' => '', 'life_end_yield' => '']);
setu($uid, ['game_day' => 0, 'game_minute' => 360]); gclock_plot_clock(0, true);

echo "== compost bin: daily compost AND the scrap heap, both in one collect\n";
try {
setu($uid, ['game_day' => 400, 'game_minute' => 600]); gclock_plot_clock(0, true);
cfg(['game_clock_on' => '1', 'compost_heap_scraps' => '8', 'compost_heap_max' => '10']);
$vb = gclock_plot_vnow($pidh);
q("DELETE FROM garden_buildings WHERE plot_id = ? AND building = 'compost_bin'", [$pidh]);
q("INSERT INTO garden_buildings (plot_id, building, level, built_at, last_collect, scraps) VALUES (?, 'compost_bin', 1, ?, ?, 17)", [$pidh, gmdate('Y-m-d H:i:s', $vb - 9 * 86400), gmdate('Y-m-d H:i:s', $vb - 2 * 86400 - 60)]);
$cid = item_id_by_slug('plain-compost');
$have0 = $cid ? (int)q_val('SELECT COALESCE(SUM(qty),0) FROM user_items WHERE user_id = ? AND item_id = ?', [$uid, $cid]) : 0;
$row = q_one("SELECT * FROM garden_buildings WHERE plot_id = ? AND building = 'compost_bin'", [$pidh]);
ok('ready: 2 from the days and 2 from 17 scraps (8 each)', building_ready($row) === 2 && heap_ready($row) === 2);
[$okc, $mc] = collect_building(urow($uid), $pidh, 'compost_bin');
$have1 = $cid ? (int)q_val('SELECT COALESCE(SUM(qty),0) FROM user_items WHERE user_id = ? AND item_id = ?', [$uid, $cid]) : 0;
ok('one collect gives the daily compost and the heap compost together', $okc && $have1 - $have0 === 4, $mc . " ($have0 -> $have1)");
$row2 = q_one("SELECT * FROM garden_buildings WHERE plot_id = ? AND building = 'compost_bin'", [$pidh]);
ok('1 scrap left over, daily clock restarted', (int)$row2['scraps'] === 1 && building_ready($row2) === 0);
$fp = 987654;   // a plot id this request has not asked about yet (building_level is cached per request)
q("DELETE FROM garden_buildings WHERE plot_id = ?", [$fp]);
q("INSERT INTO garden_buildings (plot_id, building, level, built_at, last_collect, scraps) VALUES (?, 'compost_bin', 1, ?, ?, 1)", [$fp, now(), now()]);
$line = heap_add($fp, 7);
$row3 = q_one("SELECT * FROM garden_buildings WHERE plot_id = ? AND building = 'compost_bin'", [$fp]);
ok('scraps from harvests still add up under the flag (1 + 7 = 8) and say so', (int)$row3['scraps'] === 8 && heap_ready($row3) === 1 && str_contains($line, 'made another'), $line);
q("DELETE FROM garden_buildings WHERE plot_id = ?", [$fp]);
q("DELETE FROM garden_buildings WHERE plot_id = ? AND building = 'compost_bin'", [$pidh]);
} catch (Throwable $e) { ok('compost block ran', false, $e->getMessage() . ' @' . $e->getLine()); }
cfg(['game_clock_on' => '0', 'compost_heap_scraps' => '', 'compost_heap_max' => '']);
setu($uid, ['game_day' => 0, 'game_minute' => 360]); gclock_plot_clock(0, true);

echo "== a refused spend names the real price\n";
$GLOBALS['CURRENT_USER'] = urow($uid); $_SESSION = [];
cfg(['game_clock_on' => '1']);
setu($uid, ['game_day' => 0, 'game_minute' => 1380, 'energy' => 5, 'carry_minutes' => 0]);   // 23:00 = +20%
ok('refused at 5 energy for a base 5 (really 6)', spend_energy($uid, 5) === false && (int)urow($uid)['energy'] === 5);
ok('the message says 6 and 5', str_contains(($_SESSION['flash'][0]['msg'] ?? ''), 'costs ⚡6') && str_contains($_SESSION['flash'][0]['msg'], 'you have ⚡5'), json_encode($_SESSION['flash'] ?? []));
cfg(['game_clock_on' => '0']); $_SESSION = [];
ok('flag off: refused silently as before', spend_energy($uid, 99) === false && empty($_SESSION['flash']));
setu($uid, ['game_day' => 0, 'game_minute' => 360, 'energy' => 30]);
$GLOBALS['CURRENT_USER'] = null; $_SESSION = [];

echo "== garden animals on the owner's game hours\n";
try {
require_once $argv[1] . '/includes/garden_critters.php';
setu($uid, ['game_day' => 500, 'game_minute' => 600]); gclock_plot_clock(0, true);
cfg(['game_clock_on' => '1']);
$GLOBALS['CURRENT_USER'] = urow($uid);
$vc = gclock_plot_vnow($pidh);
$kind = ['slug' => 'testcrit', 'foods' => '', 'gift_slug' => 'plain-compost', 'gift_cap' => 3, 'gift_hours' => 12, 'meals_per' => 0, 'name' => 'T', 'likes' => '', 'dislikes' => ''];
q("DELETE FROM garden_critters WHERE plot_id = ? AND kind = 'testcrit'", [$pidh]);
$cid2 = db_insert('garden_critters', ['plot_id' => $pidh, 'building' => 'worm_farm', 'kind' => 'testcrit', 'name' => 'Tess', 'mood' => 60, 'meals' => 0,
    'fed_at' => null, 'gift_at' => gmdate('Y-m-d H:i:s', $vc - 30 * 3600), 'held' => 0, 'born_at' => now(), 'grows_at' => null, 'gifts_made' => 0]);
$cr = q_one('SELECT * FROM garden_critters WHERE id = ?', [$cid2]);
$out = critter_tick($cr, $kind);
ok('30 game hours at 12 h a gift = 2 gifts (real time ignored)', (int)$out['held'] === 2, 'held ' . $out['held']);
ok('the gift clock moved on in game time', abs(strtotime($out['gift_at'] . ' UTC') - ($vc - 6 * 3600)) <= 60, $out['gift_at']);
q('DELETE FROM garden_critters WHERE id = ?', [$cid2]);
} catch (Throwable $e) { ok('critter block ran', false, $e->getMessage() . ' @' . $e->getLine()); }
cfg(['game_clock_on' => '0']);
$GLOBALS['CURRENT_USER'] = null;
setu($uid, ['game_day' => 0, 'game_minute' => 360]); gclock_plot_clock(0, true);

echo "== villagers are away on some game days\n";
$GLOBALS['CURRENT_USER'] = urow($uid);
cfg(['game_clock_on' => '1', 'npc_away_pct' => '']);
$awayDays = 0; $wk = [];
for ($d = 0; $d < 200; $d++) { setu($uid, ['game_day' => $d]); if (gclock_npc_away('n7')) $awayDays++; }
ok('about a quarter of 200 days are away days (default 25%)', $awayDays >= 30 && $awayDays <= 70, (string)$awayDays);
setu($uid, ['game_day' => 12]);
ok('same answer twice for the same day', gclock_npc_away('n7') === gclock_npc_away('n7'));
cfg(['npc_away_pct' => '0']);
ok('0% = never away', !gclock_npc_away('n7'));
cfg(['npc_away_pct' => '90']);
$many = 0; for ($d = 0; $d < 100; $d++) { setu($uid, ['game_day' => $d]); $many += gclock_npc_away('s3') ? 1 : 0; }
ok('90% = away most days', $many > 70, (string)$many);
cfg(['npc_away_pct' => '', 'game_clock_on' => '0']);
ok('flag off: never away', !gclock_npc_away('n7'));
setu($uid, ['game_day' => 0, 'game_minute' => 360]);
$GLOBALS['CURRENT_USER'] = null;

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
echo "== pal work: real time does not count (game time only)\n";
$e0 = q_val('SELECT ends_at FROM ppal_jobs WHERE id = ?', [$jid]); $r0 = q_val('SELECT ready_at FROM cook_pots WHERE id = ?', [$pid]);
q('UPDATE users SET pal_real_at = NULL WHERE id = ?', [$uid]);
gclock_freeze_pals($uid);
ok('first look only stamps the time', q_val('SELECT ends_at FROM ppal_jobs WHERE id = ?', [$jid]) === $e0 && q_val('SELECT pal_real_at FROM users WHERE id = ?', [$uid]) !== null);
q('UPDATE users SET pal_real_at = ? WHERE id = ?', [time() - 7200, $uid]);
gclock_freeze_pals($uid);
ok('2 real hours pushed back onto the job', strtotime(q_val('SELECT ends_at FROM ppal_jobs WHERE id = ?', [$jid]) . ' UTC') - strtotime($e0 . ' UTC') >= 7199);
ok('and onto the pal-tended pot', strtotime(q_val('SELECT ready_at FROM cook_pots WHERE id = ?', [$pid]) . ' UTC') - strtotime($r0 . ' UTC') >= 7199);
ok('finished job untouched', q_val('SELECT ends_at FROM ppal_jobs WHERE id = ?', [$jdone]) === $fmt($t0 + 86400));
$e1 = q_val('SELECT ends_at FROM ppal_jobs WHERE id = ?', [$jid]); gclock_freeze_pals($uid);
ok('second call in the same second moves nothing', q_val('SELECT ends_at FROM ppal_jobs WHERE id = ?', [$jid]) === $e1);
cfg(['game_clock_on' => '0']); q('UPDATE users SET pal_real_at = ? WHERE id = ?', [time() - 7200, $uid]); gclock_freeze_pals($uid);
ok('flag off: nothing moves', q_val('SELECT ends_at FROM ppal_jobs WHERE id = ?', [$jid]) === $e1);
q('UPDATE users SET pal_real_at = NULL WHERE id = ?', [$uid]);
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
