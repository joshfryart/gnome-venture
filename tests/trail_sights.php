<?php
// Trail Sights spike (v2.6.68): next to a big set piece the gnome gets a button; using it costs energy, pays rewards and starts a cooldown.
// php tests/trail_sights.php GAME_DIR   (an installed game, player "sprout"; walk.sh installs one). Route 240 section 1 has the grassland clover patch at 23,11.
$_SERVER['SCRIPT_NAME'] = '/adventure.php';
require $argv[1] . '/includes/bootstrap.php';
require_once $argv[1] . '/includes/adventure.php';
require_once $argv[1] . '/includes/trail_tiles.php';
require_once $argv[1] . '/includes/trail_sights.php';
$fails = 0;
function ok(string $what, bool $cond, string $extra = ''): void { global $fails; echo ($cond ? '  ok   ' : '  FAIL ') . $what . ($cond ? '' : "  $extra") . "\n"; if (!$cond) $fails++; }
echo "== data\n";
$all = trail_sights_all();
ok('the clover patch has a row', isset($all['grassland-the-clover-patch']) && $all['grassland-the-clover-patch']['verb'] === 'Pick', json_encode(array_keys($all)));
ok('a row has energy 1, cooldown 55, 2 uses', ($all['grassland-the-clover-patch']['energy'] ?? 0) === 1 && ($all['grassland-the-clover-patch']['cd'] ?? 0) === 55 && ($all['grassland-the-clover-patch']['uses'] ?? 0) === 2);
$art = ['objs' => [[10, 5, 'x-tree-1-leaf', 0], [20, 8, 'lm-grassland-the-clover-patch', 0]]];
ok('near: on the tile', (trail_sights_near($art, 20, 8)[0][0] ?? '') === 'grassland-the-clover-patch');
ok('near: diagonal neighbour', count(trail_sights_near($art, 21, 9)) === 1);
ok('near: two tiles away is too far', trail_sights_near($art, 22, 8) === []);
ok('near: a tree is no Sight', trail_sights_near($art, 10, 5) === []);

echo "== a walk on route 240\n";
set_setting('gnav_on', '1'); set_setting('gnav_tiles', '1'); setting('__reload__');
$u = q_one("SELECT * FROM users WHERE username = 'sprout'");
q("UPDATE expeditions SET status = 'done' WHERE user_id = ?", [$u['id']]);
q("UPDATE routes SET kind = 'road' WHERE id = 240");
$r = q_one('SELECT * FROM routes WHERE id = 240');
q("UPDATE users SET location_id = ?, level = 30, energy = 90, ev_quickwalk = 0 WHERE id = ?", [$r['a_id'], $u['id']]);
q('DELETE FROM trail_sight_uses WHERE user_id = ?', [$u['id']]);
$u = q_one('SELECT * FROM users WHERE id = ?', [$u['id']]);
[$sok, $m] = start_expedition($u, 240);
ok('a tile walk on route 240 starts', $sok, (string)$m);
$exp = active_expedition((int)$u['id']);
$sc = trail_scene($exp);
$lm = array_values(array_filter($sc['map']['art']['objs'], fn($o) => $o[2] === 'lm-grassland-the-clover-patch'));
ok('section 1 has the clover patch landmark', count($lm) === 1, json_encode($sc['map']['art']['objs'] ? count($sc['map']['art']['objs']) : 0));
// stand next to it (a walkable neighbour) and ask for the button
$spot = null;
foreach ([[-1, 0], [1, 0], [0, -1], [0, 1], [0, 0], [-1, -1], [1, 1]] as [$dx, $dy]) if (in_array(tm_tile($sc['map'], $lm[0][0] + $dx, $lm[0][1] + $dy), ['.', ',', 'S'], true)) { $spot = [$lm[0][0] + $dx, $lm[0][1] + $dy]; break; }
ok('a walkable tile beside the landmark', $spot !== null);
$sc['x'] = $spot[0]; $sc['y'] = $spot[1]; trail_save($sc); $sc = trail_scene($exp);
$here = trail_sights_here($u, $sc);
ok('the Sight is offered, ready, 2 uses', count($here) === 1 && $here[0][1] === 2, json_encode($here));
$e0 = (int)q_val('SELECT energy FROM users WHERE id = ?', [$u['id']]);
$logN = count(json_decode((string)q_val('SELECT log FROM expeditions WHERE id = ?', [$exp['id']]), true) ?: []);
[$ok1, $m1] = trail_sight_do($u, $exp, 'grassland-the-clover-patch'); save_exp($exp);   // adventure.php saves the walk after the action
ok('first use works', $ok1, (string)$m1);
ok('it cost 1 energy', (int)q_val('SELECT energy FROM users WHERE id = ?', [$u['id']]) === $e0 - 1);
ok('the walk log has the Pick line', str_contains(json_encode($exp['log'] ?? ''), 'Somebody was thorough') || str_contains((string)q_val('SELECT log FROM expeditions WHERE id = ?', [$exp['id']]), 'thorough'));
ok('the line shows the XP it paid', (bool)preg_match('/\\+\\d+ XP/', (string)q_val('SELECT log FROM expeditions WHERE id = ?', [$exp['id']])));
$u = q_one('SELECT * FROM users WHERE id = ?', [$u['id']]); $exp = active_expedition((int)$u['id']);
[$ok2] = trail_sight_do($u, $exp, 'grassland-the-clover-patch'); save_exp($exp); ok('second use works', $ok2);
$exp = active_expedition((int)$u['id']);
[$ok3, $m3] = trail_sight_do($u, $exp, 'grassland-the-clover-patch');
ok('third use is refused (2 uses per cooldown)', !$ok3 && $m3 !== '', (string)$m3);
$sc = trail_scene($exp); $here = trail_sights_here($u, $sc);
ok('the button is greyed (0 left)', count($here) === 1 && $here[0][1] === 0);
$html = trail_view_html($u, $exp, $sc, false); // the map still draws
ok('the map still draws', str_contains($html, '<svg'));
echo "== cooldown ends\n";
q('UPDATE trail_sight_uses SET got_at = got_at - 999999, got_tick = got_tick - 99999 WHERE user_id = ?', [$u['id']]);
$here = trail_sights_here($u, $sc);
ok('after the cooldown the Sight is back with 2 uses', count($here) === 1 && $here[0][1] === 2, json_encode($here[0][1] ?? null));
echo "== too far\n";
$far = null; foreach ([[0, 0], [29, 0], [0, 17], [29, 17]] as [$fx, $fy]) if (max(abs($fx - $lm[0][0]), abs($fy - $lm[0][1])) > 1) { $far = [$fx, $fy]; break; }
$sc['x'] = $far[0]; $sc['y'] = $far[1]; trail_save($sc); $exp = active_expedition((int)$u['id']);
[$ok4, $m4] = trail_sight_do($u, $exp, 'grassland-the-clover-patch');
ok('far from it the Sight is refused', !$ok4 && str_contains((string)$m4, 'next to'), (string)$m4);
echo $fails ? "$fails FAILED\n" : "ok\n";
exit($fails ? 1 : 0);
