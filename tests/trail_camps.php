<?php
// 2.7.00 CAMP SPOTS (includes/trail_camps.php, data/trail_camps.json): one camp tile per route; sleep, nap or wait there.
// php tests/trail_camps.php GAME_DIR   (an installed game, player "sprout"; walk.sh installs one)
$_SERVER['SCRIPT_NAME'] = '/adventure.php';
require $argv[1] . '/includes/bootstrap.php';
require_once $argv[1] . '/includes/adventure.php';
require_once $argv[1] . '/includes/trail_tiles.php';
require_once $argv[1] . '/includes/road_kinds.php';
require_once $argv[1] . '/includes/trail_camps.php';
$fails = 0;
set_exception_handler(function (Throwable $e) { echo '  EXCEPTION ' . get_class($e) . ': ' . $e->getMessage() . ' @ ' . basename($e->getFile()) . ':' . $e->getLine() . "\n"; exit(1); });
function ok(string $what, bool $cond, string $extra = ''): void { global $fails; echo ($cond ? '  ok   ' : '  FAIL ') . $what . ($cond ? '' : "  $extra") . "\n"; if (!$cond) $fails++; }

echo "== the data\n";
$all = tc_all();
ok('one camp for every authored route (246)', count($all) === 246 && trail_authored_count(228) > 0, (string)count($all));
$bad = [];
foreach ($all as $rid => $c) {
    $sec = trail_authored_section($rid, $c['sec']);
    if (!$sec) { $bad[] = "$rid: no section"; continue; }
    [$map] = trail_map_authored($sec);
    $t = tm_tile($map, $c['x'], $c['y']);
    [$sx, $sy] = $map['entry']; [$ex, $ey] = $map['spots']['9'];
    if (!in_array($t, ['.', ','], true)) $bad[] = "$rid: tile '$t'";
    elseif (abs($c['x'] - $sx) + abs($c['y'] - $sy) < 6 || abs($c['x'] - $ex) + abs($c['y'] - $ey) < 6) $bad[] = "$rid: too near the entry or the exit";
    elseif (!tm_path($map, $sx, $sy, $c['x'], $c['y'])) $bad[] = "$rid: not reachable";
}
ok('every camp tile is floor, six tiles from the way in and the way on, and reachable', !$bad, json_encode(array_slice($bad, 0, 5)));
$secs = array_map(fn($rid) => $rid, array_keys(array_filter($all, fn($c, $rid) => $c['sec'] < 0 || $c['sec'] >= trail_authored_count($rid), ARRAY_FILTER_USE_BOTH)));
ok('every camp is on a stretch the route has', !$secs);
ok('the wait chances: 25% over 30 minutes, 5% up to 30, halved on a paid toll road', tc_wait_chance(60) === 25.0 && tc_wait_chance(31) === 25.0 && tc_wait_chance(30) === 5.0 && tc_wait_chance(10) === 5.0 && tc_wait_chance(60, true) === 12.5 && tc_wait_chance(10, true) === 2.5);
ok('1 energy for every 2 minutes', tc_wait_energy(10) === 5 && tc_wait_energy(45) === 22 && tc_wait_energy(60) === 30);

set_setting('gnav_on', '1'); set_setting('gnav_tiles', '1'); set_setting('game_clock_on', '1'); setting('__reload__');
$u0 = q_one("SELECT * FROM users WHERE username = 'sprout'"); $uid = (int)$u0['id'];
$plain = (int)q_val('SELECT id FROM routes WHERE id NOT IN (' . implode(',', array_keys(rk_all())) . ") AND kind = 'road' ORDER BY id LIMIT 1");
$camp = $all[$plain];
/** a walk on the plain road, standing on the camp tile (or at its start) */
$walk = function (bool $onCamp = true, int $energy = 20) use ($uid, $plain, $camp) {
    q("UPDATE expeditions SET status = 'done' WHERE user_id = ?", [$uid]);
    $r = q_one('SELECT * FROM routes WHERE id = ?', [$plain]);
    q('UPDATE users SET location_id = ?, level = 40, energy = ?, coins = 500, ev_quickwalk = 0, game_day = 5, game_minute = 360 WHERE id = ?', [$r['a_id'], $energy, $uid]);
    $u = q_one('SELECT * FROM users WHERE id = ?', [$uid]);
    $to = q_one('SELECT * FROM locations WHERE id = ?', [$r['b_id']]);
    if ($to && !place_known($uid, $to)) unlock_entries($uid, ($to['kind'] === 'village' ? 'village:' : 'landmark:') . $to['slug']);
    [$ok, $m] = start_expedition($u, $plain);
    $exp = active_expedition($uid); $exp['encounter'] = null;
    if ($onCamp) {
        $sc = trail_scene($exp); $sc['st']['sec'] = $camp['sec']; trail_save($sc);
        $sc = trail_scene($exp); $sc['x'] = $camp['x']; $sc['y'] = $camp['y']; trail_save($sc);
    }
    return [q_one('SELECT * FROM users WHERE id = ?', [$uid]), $exp];
};
$row = fn() => q_one('SELECT energy, game_day, game_minute FROM users WHERE id = ?', [$uid]);

echo "== the camp card and the tile\n";
[$u, $exp] = $walk(false);
$sc = trail_scene($exp);
ok('away from the camp tile there is no camp card', !tc_here($sc) && !str_contains(trail_strip_html($u, $exp, $sc), 'trail_camp'));
[$ca, $cm] = trail_camp($u, $exp, 'sleep');
ok('and Sleep is refused there', !$ca && str_contains((string)$cm, 'camp spot'), (string)$cm);
[$u, $exp] = $walk(true);
$sc = trail_scene($exp);
ok('on the camp tile: tc_here and the card shows sleep, nap and the five waits', tc_here($sc) && ($h = trail_strip_html($u, $exp, $sc)) && str_contains($h, 'value="trail_camp"') && str_contains($h, 'value="sleep"') && str_contains($h, 'value="nap"') && substr_count($h, 'value="wait:') === 5);
$view = trail_view_html($u, $exp, $sc, false);
ok('next to the camp tile the map offers it as a camp spot to walk to', (function () use ($u, $exp, $camp) { $sc = trail_scene($exp); foreach ([[1, 0], [-1, 0], [0, 1], [0, -1]] as [$dx, $dy]) if (in_array(tm_tile($sc['map'], $camp['x'] + $dx, $camp['y'] + $dy), ['.', ','], true)) { $sc['x'] = $camp['x'] + $dx; $sc['y'] = $camp['y'] + $dy; break; } return !tc_here($sc) && str_contains(trail_view_html($u, $exp, $sc, false), 'A camp spot: sleep, nap or wait'); })());

echo "== sleep and nap: free\n";
[$u, $exp] = $walk(true, 5); $b = $row();
[$sa, $sm] = trail_camp($u, $exp, 'sleep'); $a = $row();
ok('sleep: ok, a new day, energy full, no Petals taken', $sa && (int)$a['game_day'] === (int)$b['game_day'] + 1 && (int)$a['energy'] === max_energy($u) && (int)q_val('SELECT coins FROM users WHERE id = ?', [$uid]) === 500, (string)$sm . json_encode([$b, $a]));
[$u, $exp] = $walk(true, 5); $b = $row();
[$na, $nm] = trail_camp($u, $exp, 'nap'); $a = $row();
ok('nap: ok, 2 game hours later, energy up', $na && (int)$a['energy'] > (int)$b['energy'] && ((int)$a['game_day'] * 1440 + (int)$a['game_minute']) - ((int)$b['game_day'] * 1440 + (int)$b['game_minute']) === 120, (string)$nm . json_encode([$b, $a]));

echo "== wait\n";
[$u, $exp] = $walk(true, 10); $b = $row();   // (the walk itself took 1 energy)
[$wa, $wm] = trail_camp($u, $exp, 'wait', 30, fn($p) => false);
$a = $row();
ok('wait 30 with a quiet roll: 30 game minutes, +15 energy, no fight', $wa && (int)$a['energy'] === (int)$b['energy'] + 15 && ((int)$a['game_minute'] - (int)$b['game_minute']) === 30 && !$exp['encounter'], (string)$wm . json_encode([$b, $a]));
$seen = []; $r2 = trail_camp($u, $exp, 'wait', 60, function ($p) use (&$seen) { $seen[] = $p; return false; });
ok('the dice get 25 for a long wait', $seen === [25.0], json_encode($seen));
$seen = []; trail_camp($u, $exp, 'wait', 20, function ($p) use (&$seen) { $seen[] = $p; return false; });
ok('and 5 for a short one (no daily limit: three waits in a row worked)', $seen === [5.0] && $r2[0]);
[$u, $exp] = $walk(true, 10); [$fa, $fm] = trail_camp($u, $exp, 'wait', 10, fn($p) => true);
ok('a rolled fight starts a random fight', $fa && !empty($exp['encounter']) && str_contains((string)$fm, 'finds you'), (string)$fm);
[$xa, $xm] = trail_camp($u, $exp, 'wait', 10, fn($p) => false);
ok('with a fight in front of you nothing else works', !$xa);
[$u, $exp] = $walk(true, 5); $max = max_energy($u); q('UPDATE users SET energy = ? WHERE id = ?', [$max - 2, $uid]);
trail_camp($u, $exp, 'wait', 60, fn($p) => false);
ok('energy never goes over the maximum', (int)$row()['energy'] === $max, (string)$row()['energy'] . " of $max");
[$u, $exp] = $walk(true, 10);
[$ba] = trail_camp($u, $exp, 'wait', 15, fn($p) => false);
ok('only the five waits are accepted', !$ba);

echo "== a paid toll road halves the chance\n";
$toll = array_key_first(array_filter(rk_all(), fn($k) => $k['kind'] === 'toll'));
$tr = q_one('SELECT * FROM routes WHERE id = ?', [$toll]); $tc = $all[$toll];
q("UPDATE expeditions SET status = 'done' WHERE user_id = ?", [$uid]);
q('UPDATE users SET location_id = ?, level = 40, energy = 10, coins = 500, ev_quickwalk = 0, game_day = 5, game_minute = 360 WHERE id = ?', [$tr['a_id'], $uid]);
$u = q_one('SELECT * FROM users WHERE id = ?', [$uid]); $to = q_one('SELECT * FROM locations WHERE id = ?', [$tr['b_id']]);
if ($to && !place_known($uid, $to)) unlock_entries($uid, ($to['kind'] === 'village' ? 'village:' : 'landmark:') . $to['slug']);
start_expedition($u, $toll); $exp = active_expedition($uid); $exp['encounter'] = null; trail_toll($u, $exp, true);
$sc = trail_scene($exp); $sc['st']['sec'] = $tc['sec']; trail_save($sc); $sc = trail_scene($exp); $sc['x'] = $tc['x']; $sc['y'] = $tc['y']; trail_save($sc);
$seen = []; trail_camp(q_one('SELECT * FROM users WHERE id = ?', [$uid]), $exp, 'wait', 60, function ($p) use (&$seen) { $seen[] = $p; return false; });
ok('wait 60 on a paid toll road: the dice get 12.5', $seen === [12.5], json_encode($seen));

echo $fails ? "$fails FAILED\n" : "ok\n";
exit($fails ? 1 : 0);
