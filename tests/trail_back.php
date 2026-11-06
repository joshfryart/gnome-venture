<?php
// Walking back the way you came on the Trail (trail_prev): from where a stretch begins to the end of the one before it.
// php tests/trail_back.php GAME_DIR      (an installed game, player "sprout"; walk.sh installs one)
$_SERVER['SCRIPT_NAME'] = '/adventure.php';
require $argv[1] . '/includes/bootstrap.php';
require_once $argv[1] . '/includes/adventure.php';
require_once $argv[1] . '/includes/trail_tiles.php';
$fails = 0;
function ok(string $what, bool $cond, string $extra = ''): void { global $fails; echo ($cond ? '  ok   ' : '  FAIL ') . $what . ($cond ? '' : "  $extra") . "\n"; if (!$cond) $fails++; }
set_setting('gnav_on', '1'); set_setting('gnav_tiles', '1'); setting('__reload__');
$u = q_one("SELECT * FROM users WHERE username = 'sprout'");
q("UPDATE expeditions SET status = 'done' WHERE user_id = ?", [$u['id']]);
$mk = (int)q_val("SELECT id FROM locations WHERE kind = 'market' ORDER BY id LIMIT 1");
q("UPDATE users SET location_id = ?, level = 20, energy = 90, ev_quickwalk = 0 WHERE id = ?", [$mk, $u['id']]);
$u = q_one('SELECT * FROM users WHERE id = ?', [$u['id']]);
[$sok, $m] = start_expedition($u, (int)visible_routes($u, $mk)[0]['id']);
ok('a tile walk starts', $sok, (string)$m);
$exp = active_expedition((int)$u['id']);
$sc = trail_scene($exp);
ok('it has more than one section', $sc && (int)$sc['st']['S'] > 1, json_encode($sc['st'] ?? null));
if (!$sc || (int)$sc['st']['S'] < 2) exit(1);
$exp['encounter'] = null;   // no random fight in the way of the test
[$ok1, $m1] = trail_prev($u, $exp);
ok('section 1 has no way back', !$ok1);
// mark a find in section 1 as done, walk to the exit and on
$sc = trail_scene($exp);
foreach ($sc['st']['tokens'] as $i => $t) { $sc['st']['tokens'][$i][3] = 1; }
[$ex, $ey] = $sc['map']['spots']['9'];
$sc['x'] = $ex; $sc['y'] = $ey; $sc['st']['phase'] = 'confirm';
trail_save($sc);
$tok0 = $sc['st']['tokens'];
trail_stance($u, $exp, 'sneak');
$sc = trail_scene($exp); $sc['st']['phase'] = 'confirm'; trail_save($sc);
$exp['encounter'] = null;
[$ok2, $m2] = trail_next($u, $exp);
ok('Continue goes on to section 2', $ok2, (string)$m2);
$sc2 = trail_scene($exp);
ok('now in section 2, standing at its start', (int)$sc2['st']['sec'] === 1 && $sc2['x'] === (int)$sc2['map']['entry'][0] && $sc2['y'] === (int)$sc2['map']['entry'][1]);
$exp['encounter'] = null;
// away from the start: no way back from there
$sc2b = $sc2; $sc2b['x'] = (int)$sc2['map']['spots']['9'][0]; $sc2b['y'] = (int)$sc2['map']['spots']['9'][1]; $keep = $sc2b; trail_save($sc2b);
[$ok3, $m3] = trail_prev($u, $exp);
ok('away from where the stretch begins the way back is refused', !$ok3);
$sc2c = trail_scene($exp); $sc2c['x'] = (int)$sc2c['map']['entry'][0]; $sc2c['y'] = (int)$sc2c['map']['entry'][1]; trail_save($sc2c);
[$ok4, $m4] = trail_prev($u, $exp);
ok('from the start of section 2 you can walk back', $ok4, (string)$m4);
$sc3 = trail_scene($exp);
ok('back in section 1, on its exit tile', (int)$sc3['st']['sec'] === 0 && $sc3['x'] === $ex && $sc3['y'] === $ey && $sc3['st']['phase'] === 'confirm');
ok('what was done in section 1 is still done', json_encode($sc3['st']['tokens']) === json_encode($tok0));
ok('the exp step follows', (int)$exp['step'] === 0);
ok('Sneak/Hunt holds across Continue and the way back', ($sc3['st']['stance'] ?? '') === 'sneak', json_encode($sc3['st']['stance'] ?? null));
[$okS, $mS] = trail_stay($u, $exp);
ok('Not yet leaves the exit and lets you walk about', $okS && trail_scene($exp)['st']['phase'] === 'section', (string)$mS);
[$okT, $mT] = trail_go($u, $exp, $ex, $ey);
ok('tapping the exit you stand on asks about going on again', $okT && trail_scene($exp)['st']['phase'] === 'confirm', (string)$mT);
[$okS2] = trail_stay($u, $exp); [$okS3] = trail_stay($u, $exp);
ok('Not yet with nothing to leave is refused', $okS2 && !$okS3);
$exp['encounter'] = null;
$sc3 = trail_scene($exp); $sc3['st']['phase'] = 'confirm'; trail_save($sc3);
$logBefore = (string)$exp['log'];
[$ok5, $m5] = trail_next($u, $exp);
$sc4 = trail_scene($exp);
ok('going on again returns to section 2 (same map)', $ok5 && (int)$sc4['st']['sec'] === 1 && json_encode($sc4['map']['entry']) === json_encode($sc2['map']['entry']));
ok('no new surprise rolled at a door you have walked through', $exp['encounter'] === null);

// the camera stays inside the map (v2.6.05): the 7 x 7 the phone crops to never reaches past an edge
foreach ([[0, 0], [21, 8], [10, 4], [1, 1], [20, 2]] as [$cx, $cy]) {
    $wn = tm_window_clamped($cx, $cy, 9, 9, 22, 11);
    $vx0 = $wn['x0'] + 1; $vy0 = $wn['y0'] + 1;   // the inner 7 x 7
    ok("camera at $cx,$cy keeps the 7 x 7 inside a 22 x 11 map and the gnome in it", $vx0 >= 0 && $vy0 >= 0 && $vx0 + 7 <= 22 && $vy0 + 7 <= 11 && $cx >= $vx0 && $cx < $vx0 + 7 && $cy >= $vy0 && $cy < $vy0 + 7, json_encode($wn));
}
$mid = tm_window_clamped(10, 5, 9, 9, 22, 11);
ok('in the middle the gnome is still centred (as before)', $mid['x0'] === 6 && $mid['y0'] === 1, json_encode($mid));
$small = tm_window_clamped(2, 2, 9, 9, 5, 5);
ok('a map smaller than the window stays centred', $small['x0'] === -2, json_encode($small));
echo $fails ? "$fails FAILED\n" : "ok\n";
exit($fails ? 1 : 0);
