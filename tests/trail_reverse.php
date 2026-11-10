<?php
// Walking a route from its b end (2.6.41): the stretches come in the opposite order and each is entered where the a-to-b walk leaves it.
// php tests/trail_reverse.php GAME_DIR      (an installed game, player "sprout"; walk.sh installs one)
$_SERVER['SCRIPT_NAME'] = '/adventure.php';
require $argv[1] . '/includes/bootstrap.php';
require_once $argv[1] . '/includes/adventure.php';
require_once $argv[1] . '/includes/trail_tiles.php';
$fails = 0;
function ok(string $what, bool $cond, string $extra = ''): void { global $fails; echo ($cond ? '  ok   ' : '  FAIL ') . $what . ($cond ? '' : "  $extra") . "\n"; if (!$cond) $fails++; }
set_setting('gnav_on', '1'); set_setting('gnav_tiles', '1'); setting('__reload__');

// pure: a flipped map is the same ground with entry and way on swapped
[$f0, $ft] = trail_map_make('232|7|9|0');
[$r0, $rt] = trail_map_make('232|7|9|0|r');
ok('the flipped stretch enters where the plain one leaves', $r0['entry'] === $f0['spots']['9'] && $r0['spots']['9'] === $f0['entry'], json_encode([$r0['entry'], $f0['spots']['9']]));
ok('the tiles say so too', tm_tile($r0, $r0['entry'][0], $r0['entry'][1]) === 'S' && tm_tile($r0, $r0['spots']['9'][0], $r0['spots']['9'][1]) === '9');
ok('same finds, same picture', json_encode($ft) === json_encode($rt) && ($r0['art']['sec'] ?? -1) === 0);
$n232 = trail_authored_count(232);
ok('stretch as drawn: forwards unchanged, backwards counted from the far end', trail_phys_sec(232, 0, []) === 0 && trail_phys_sec(232, 0, ['rev' => 1, 'S' => $n232]) === $n232 - 1 && trail_phys_sec(232, $n232 - 1, ['rev' => 1]) === 0);
ok('a route that is not authored uses the walk\'s own count', trail_phys_sec(3, 0, ['rev' => 1, 'S' => 4]) === 3);
[$g0] = trail_map_make('seed-x'); ok('other seeds are untouched', $g0['entry'] !== null);

// a real walk each way on one authored route with 2 or more stretches
$u = q_one("SELECT * FROM users WHERE username = 'sprout'");
$route = null;
foreach (q('SELECT * FROM routes ORDER BY id')->fetchAll() as $r) if (trail_authored_count((int)$r['id']) >= 2 && trail_sections($r) === trail_authored_count((int)$r['id']) && ($r['kind'] ?? 'road') === 'road') { $route = $r; break; }
ok('an authored road with 2+ stretches exists', (bool)$route);
if (!$route) { echo "1 FAILED\n"; exit(1); }
$rid = (int)$route['id']; $N = trail_authored_count($rid);
$walk = function (int $from) use (&$u, $rid) {
    q("UPDATE expeditions SET status = 'done' WHERE user_id = ?", [$u['id']]);
    q('DELETE FROM walk_scene WHERE user_id = ?', [$u['id']]);
    q('UPDATE users SET location_id = ?, level = 20, energy = 90, ev_quickwalk = 0 WHERE id = ?', [$from, $u['id']]);
    $u = q_one('SELECT * FROM users WHERE id = ?', [$u['id']]);
    [$ok, $m] = start_expedition($u, $rid);
    ok('a walk starts from location ' . $from, $ok, (string)$m);
    return active_expedition((int)$u['id']);
};
$exp = $walk((int)$route['a_id']);
$fa = trail_scene($exp);
ok('from the a end: not reversed, first stretch as drawn', empty($fa['st']['rev']) && (int)$fa['map']['art']['sec'] === 0);
$aEntry = $fa['map']['entry'];
$fwd = [];
for ($i = 0; $i < $N; $i++) { [$m] = trail_map_make($rid . '|1|1|' . $i); $fwd[$i] = [$m['entry'], $m['spots']['9']]; }

$exp = $walk((int)$route['b_id']);
$rb = trail_scene($exp);
ok('from the b end: the walk is marked reversed', !empty($rb['st']['rev']), json_encode($rb['st']));
ok('it starts on the LAST stretch as drawn', (int)$rb['map']['art']['sec'] === $N - 1, (string)$rb['map']['art']['sec']);
ok('standing where the a-to-b walk leaves that stretch', [$rb['x'], $rb['y']] === $fwd[$N - 1][1], json_encode([[$rb['x'], $rb['y']], $fwd[$N - 1][1]]));
ok('the way on is where the a-to-b walk enters it', $rb['map']['spots']['9'] === $fwd[$N - 1][0]);
ok('still called section 1', (int)$rb['st']['sec'] === 0 && (int)$exp['step'] === 0);
$exp['encounter'] = null;
[$ex, $ey] = $rb['map']['spots']['9'];
$rb['x'] = $ex; $rb['y'] = $ey; $rb['st']['phase'] = 'confirm'; trail_save($rb);
[$okN, $mN] = trail_next($u, $exp);
$r2 = trail_scene($exp);
ok('Continue goes to the stretch before it as drawn', $okN && (int)$r2['map']['art']['sec'] === $N - 2 && (int)$r2['st']['sec'] === 1, (string)$mN);
ok('entered at its far end, and still reversed', [$r2['x'], $r2['y']] === $fwd[$N - 2][1] && !empty($r2['st']['rev']));
$exp['encounter'] = null;
[$okP, $mP] = trail_prev($u, $exp);
$r3 = trail_scene($exp);
ok('walking back returns to the first stretch walked, on its way on, still reversed', $okP && (int)$r3['map']['art']['sec'] === $N - 1 && [$r3['x'], $r3['y']] === $fwd[$N - 1][0] && !empty($r3['st']['rev']), (string)$mP);
if ($N === 2) {
    $exp['encounter'] = null; $r3['st']['phase'] = 'confirm'; trail_save($r3);
    trail_next($u, $exp); $r4 = trail_scene($exp);
    ok('the last stretch walked ends at the a end\'s first tile', $r4['map']['spots']['9'] === $aEntry, json_encode([$r4['map']['spots']['9'], $aEntry]));
}
// finds taken are remembered by the stretch as drawn
q('DELETE FROM trail_pickups WHERE user_id = ?', [$u['id']]);
trail_pickup_note((int)$u['id'], $rid, trail_phys_sec($rid, 0, ['rev' => 1]));
ok('a find taken on the way back is noted on the drawn stretch', (int)q_val('SELECT sec FROM trail_pickups WHERE user_id = ? AND route_id = ?', [$u['id'], $rid]) === $N - 1);
q('DELETE FROM trail_pickups WHERE user_id = ?', [$u['id']]);
q("UPDATE expeditions SET status = 'done' WHERE user_id = ?", [$u['id']]);
echo $fails ? "$fails FAILED\n" : "ok\n";
exit($fails ? 1 : 0);
