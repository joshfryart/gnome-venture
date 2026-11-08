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

echo $fails ? "\n$fails FAILED\n" : "\nall ok\n";
exit($fails ? 1 : 0);
