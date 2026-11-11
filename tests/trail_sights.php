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

echo "== P1: every row lints, bad rows do not\n";
require_once $argv[1] . '/includes/tools.php';
$GLOBALS['gv_sights_reload'] = true; $all = trail_sights_all();
foreach ($all as $r) { $pb = trail_sight_lint($r); ok('row lints: ' . $r['slug'], !$pb, implode('; ', $pb)); }
ok('the four P1 example rows exist (forage, check, read, fish)', isset($all['coast-the-shell-heap'], $all['mountain-the-rope-bridge'], $all['grassland-the-old-milestone'], $all['island-the-reef-shallows']));
$base = $all['grassland-the-clover-patch'];
foreach ([['check' => 'luckk:5'], ['check' => 'grit:99'], ['tool' => 'spade:1'], ['tool' => 'rod:9'], ['rewards' => 'gold=5'], ['rewards' => 'item=no-such-thing-xyz:1'], ['when' => 'dp=noon_ish!'], ['energy' => 9], ['win' => '']] as $chg) {
    ok('lint catches ' . json_encode($chg), (bool)trail_sight_lint($chg + $base));
}
ok('lint catches a landmark with no picture', (bool)trail_sight_lint(['slug' => 'no-such-landmark'] + $base));
echo "== P1: the engine paths, on the clover patch row (admin rows replace file rows)\n";
trail_sights_ensure_tables();
$put = function (array $chg) use ($base) {
    $r = $chg + $base; q('DELETE FROM trail_sight_rows WHERE slug = ?', [$base['slug']]);
    db_insert('trail_sight_rows', ['slug' => $base['slug'], 'verb' => $r['verb'], 'icon' => $r['icon'], 'energy' => $r['energy'], 'cd' => $r['cd'], 'uses' => $r['uses'], 'cond' => $r['when'], 'chk' => $r['check'], 'rewards' => $r['rewards'], 'win' => $r['win'], 'lose' => $r['lose'], 'tool' => $r['tool'], 'fail_en' => $r['fail_en'], 'active' => 1, 'updated_at' => now()]);
    q('DELETE FROM trail_sight_uses'); $GLOBALS['gv_sights_reload'] = true; trail_sights_all();
};
$energy = fn() => (int)q_val('SELECT energy FROM users WHERE id = ?', [$u['id']]);
$mins = fn() => gclock_on() ? (int)q_val('SELECT game_day * 1440 + game_minute FROM users WHERE id = ?', [$u['id']]) : 0;
$fresh = function () use (&$u, &$exp) { $u = q_one('SELECT * FROM users WHERE id = ?', [$u['id']]); $exp = active_expedition((int)$u['id']); $GLOBALS['gv_sights_reload'] = true; };
$sc = trail_scene($exp); $sc['x'] = $spot[0]; $sc['y'] = $spot[1]; trail_save($sc);
$put(['energy' => 0, 'rewards' => 'xp=2:1']); $fresh();
$e1 = $energy(); $t1 = $mins();
[$z] = trail_sight_do($u, $exp, $base['slug']); save_exp($exp);
ok('an energy-free Sight (reading) works and costs no energy', $z && $energy() === $e1);
if (gclock_on()) ok('it costs 10 game minutes (time_sight)', $mins() - $t1 === 10, (string)($mins() - $t1));
$put(['check' => 'grit:25', 'fail_en' => 2, 'lose' => 'You slip.', 'rewards' => 'xp=5']); $fresh();
q('UPDATE users SET stat_grit = 1 WHERE id = ?', [$u['id']]); $fresh();
$e2 = $energy(); $fails2 = 0;
for ($i = 0; $i < 6; $i++) { $put(['check' => 'grit:25', 'fail_en' => 2, 'lose' => 'You slip.', 'rewards' => 'xp=5', 'uses' => 1]); $fresh(); $e = $energy(); [$o2] = trail_sight_do($u, $exp, $base['slug']); save_exp($exp); if ($energy() === $e - 1 - 2) $fails2++; }
ok('a failed check costs the energy plus fail_en (grit 1 against 25: nearly always fails)', $fails2 >= 4, (string)$fails2);
ok('the lose line is in the log', str_contains((string)q_val('SELECT log FROM expeditions WHERE id = ?', [$exp['id']]), 'You slip'));
$put(['tool' => 'bucket:1', 'rewards' => 'xp=1']); $fresh();
$tc = &tool_tier_cache(); $tc[$u['id'] . ':bucket'] = 0;
[$t0, $tm] = trail_sight_do($u, $exp, $base['slug']);
ok('without the tool it is refused and costs nothing', !$t0 && str_contains((string)$tm, 'tide bucket'), (string)$tm);
$tc[$u['id'] . ':bucket'] = 1; $eT = $energy();
[$t1ok] = trail_sight_do($u, $exp, $base['slug']); save_exp($exp);
ok('with the tool it works', $t1ok && $energy() === $eT - 1);
$put(['rewards' => 'gather=rod', 'tool' => 'rod:1']); $fresh(); $tc[$u['id'] . ':rod'] = 1;
[$g1] = trail_sight_do($u, $exp, $base['slug']); save_exp($exp);
$lg = (string)q_val('SELECT log FROM expeditions WHERE id = ?', [$exp['id']]);
ok('gather=rod runs the gather table (it logs a catch or a hint)', $g1 && (str_contains($lg, 'fishing') || str_contains($lg, 'catch') || str_contains($lg, 'nothing') || str_contains($lg, 'rod') || str_contains($lg, 'Fish') || str_contains($lg, 'wade')), substr($lg, -200));
$put(['when' => 'dp=night/se=winter', 'check' => '-', 'rewards' => 'xp=1', 'tool' => '-']); $fresh(); unset($tc[$u['id'] . ':rod']);
echo "== P1: admin rows replace, hide and restore\n";
$GLOBALS['gv_sights_reload'] = true; ok('a saved row replaces the file row (src edited)', (trail_sights_all()[$base['slug']]['src'] ?? '') === 'edited');
q('DELETE FROM trail_sight_rows WHERE slug = ?', [$base['slug']]); db_insert('trail_sight_rows', ['slug' => $base['slug'], 'verb' => '-', 'icon' => '-', 'energy' => 0, 'cd' => 0, 'uses' => 1, 'cond' => '-', 'chk' => '-', 'rewards' => '', 'win' => '', 'lose' => '', 'tool' => '-', 'fail_en' => 0, 'active' => 0, 'updated_at' => now()]);
$GLOBALS['gv_sights_reload'] = true; ok('an off row hides the Sight', !isset(trail_sights_all()[$base['slug']]));
q('DELETE FROM trail_sight_rows WHERE slug = ?', [$base['slug']]); $GLOBALS['gv_sights_reload'] = true;
ok('removing the row brings the file row back', (trail_sights_all()[$base['slug']]['src'] ?? '') === 'file');
echo $fails ? "$fails FAILED\n" : "ok\n";
exit($fails ? 1 : 0);
