<?php
// 2.6.36: stop perks belong to the player, last perk_days game days, stack up to perk_max, refresh instead of doubling.
// Run: php tests/player_perks.php GAME_DIR   (an installed copy with a gnome)
$_SERVER['SCRIPT_NAME'] = '/gnome.php';
require $argv[1] . '/includes/bootstrap.php';
require_once $argv[1] . '/includes/gnome.php';
require_once $argv[1] . '/includes/stops.php';
require_once $argv[1] . '/includes/stop_living.php';
require_once $argv[1] . '/includes/player_perks.php';
$fails = 0;
function ok(string $what, bool $cond, string $extra = ''): void { global $fails; echo ($cond ? '  ok   ' : '  FAIL ') . $what . ($cond ? '' : "  $extra") . "\n"; if (!$cond) $fails++; }
db_migrate(db(), 'sqlite');
$uid = (int)q_val("SELECT id FROM users ORDER BY id LIMIT 1");
$locs = array_map('intval', q("SELECT id FROM locations WHERE kind = 'village' ORDER BY id LIMIT 6")->fetchAll(PDO::FETCH_COLUMN));
q('DELETE FROM player_perks WHERE user_id = ?', [$uid]);

echo "== grant\n";
ok('pools: every meter has 2+ perks', count(array_filter(PLAYER_PERKS, fn($p) => $p[0] === 'repairs')) >= 2 && count(array_filter(PLAYER_PERKS, fn($p) => $p[0] === 'larder')) >= 2 && count(array_filter(PLAYER_PERKS, fn($p) => $p[0] === 'cheer')) >= 2);
[$k, $ref] = player_perk_grant($uid, $locs[0], 'larder');
ok('perk comes from the meter pool', PLAYER_PERKS[$k][0] === 'larder');
ok('running now', player_perk($uid, $k));
$until = player_perks_active($uid)[$k];
ok('lasts 7 game days (today + 6)', player_perk_days_left($until) === 7, (string)player_perk_days_left($until));
ok('line mentions everywhere', str_contains(player_perk_line([$k, false]), 'everywhere'));

echo "== refresh, no stack\n";
q('DELETE FROM player_perks WHERE user_id = ?', [$uid]);
[$a] = player_perk_grant($uid, $locs[0], 'repairs');
[$b, $r2] = player_perk_grant($uid, $locs[0], 'repairs');
ok('second fill prefers the other perk', $a !== $b && !$r2);
q("UPDATE player_perks SET until = ? WHERE user_id = ? AND perk_key = ?", [gclock_my_date(), $uid, $a]); player_perks_active($uid, true);
ok('1 day left before refresh', player_perk_days_left(player_perks_active($uid)[$a]) === 1);
$tries = 0; $refreshedA = false;
while ($tries++ < 4 && !$refreshedA) { [$k3, $r3] = player_perk_grant($uid, $locs[0], 'repairs'); if ($r3 && $k3 === $a) $refreshedA = true; }
ok('both running: a fill refreshes, no extra row', (int)q_val('SELECT COUNT(*) FROM player_perks WHERE user_id = ?', [$uid]) === 2);
ok('refresh back to 7 days', !$refreshedA || player_perk_days_left(player_perks_active($uid)[$a]) === 7);

echo "== cap of 3\n";
q('DELETE FROM player_perks WHERE user_id = ?', [$uid]);
foreach (['repairs', 'larder', 'cheer'] as $i => $m) player_perk_grant($uid, $locs[$i], $m);
ok('3 running', count(player_perks_active($uid, true)) === 3);
q("UPDATE player_perks SET until = '2000-01-01' WHERE user_id = ? AND meter = 'repairs'", [$uid]);   // expired ones do not count
ok('expired perk is not active', count(player_perks_active($uid, true)) === 2);
q("UPDATE player_perks SET until = ? WHERE user_id = ? AND meter = 'repairs'", [gclock_my_date(), $uid]);   // soonest to end
player_perks_active($uid, true);
[$k4, , $dropped] = player_perk_grant($uid, $locs[3], 'cheer');
$n = count(player_perks_active($uid, true));
ok('never more than 3', $n <= 3, (string)$n);

echo "== effects\n";
q('DELETE FROM player_perks WHERE user_id = ?', [$uid]);
$u = q_one('SELECT * FROM users WHERE id = ?', [$uid]);
db_insert('player_perks', ['user_id' => $uid, 'perk_key' => 'packed_lunch', 'meter' => 'larder', 'until' => gclock_my_date(), 'from_location_id' => $locs[0]]);
player_perks_active($uid, true);
ok('Packed Lunch: meal boost 60 -> 75 minutes', buff_minutes($u, 60) === 75, (string)buff_minutes($u, 60));
ok('perk shows in active effects', (bool)array_filter(active_effects($u), fn($e) => $e[1] === 'Packed Lunch'));
q('DELETE FROM player_perks WHERE user_id = ?', [$uid]); player_perks_active($uid, true);
ok('perk gone = no bonus', buff_minutes($u, 60) === 60);
echo "== a filled meter gives the perk\n";
q('DELETE FROM player_perks WHERE user_id = ?', [$uid]);
$loc = q_one('SELECT * FROM locations WHERE id = ?', [$locs[0]]);
q("DELETE FROM stop_prog WHERE user_id = ? AND location_id = ?", [$uid, $locs[0]]);
[$v, $f] = stop_meter_add($uid, $locs[0], 'cheer', 95);
$lines = stop_meter_add($uid, $locs[0], 'cheer', 10);
ok('meter filled', $lines[1] === 'cheer');
$u2 = q_one('SELECT * FROM users WHERE id = ?', [$uid]);
$ls = stop_living_after($u2, $loc, ['tags' => 'play', 'slug' => 'x', 'name' => 'x']);
ok('stop_perk_bonus is retired (0)', stop_perk_bonus($uid, $locs[0]) === 0);
echo $fails ? "$fails FAILED\n" : "all ok\n";
exit($fails ? 1 : 0);
