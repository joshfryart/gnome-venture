<?php
// Forest family (2.7.01): the glow-moss dusk lantern row, Lantern Relay rows (tally), the "Who Lit the Wood?" line with Alder Thistledown by his weekly clockwork.
// php tests/trail_fam_forest.php GAME_DIR   (an installed game, player "sprout"; walk.sh installs one)
$_SERVER['SCRIPT_NAME'] = '/adventure.php';
require $argv[1] . '/includes/bootstrap.php';
require_once $argv[1] . '/includes/adventure.php';
require_once $argv[1] . '/includes/trail_tiles.php';
require_once $argv[1] . '/includes/trail_sights.php';
require_once $argv[1] . '/includes/stop_folk.php';
require_once $argv[1] . '/includes/npc_clockwork.php';
require_once $argv[1] . '/includes/trail_fam_forest.php';
$fails = 0;
set_setting('sights_walk_cap', '0');   // 2.7.08: this test uses many Sights on one walk (the cap: tests/trail_sights_278.php)
$GLOBALS['gv_sights_nocache'] = true;
set_exception_handler(function (Throwable $e) { echo '  EXCEPTION ' . get_class($e) . ': ' . $e->getMessage() . ' @ ' . basename($e->getFile()) . ':' . $e->getLine() . "\n"; exit(1); });
function ok(string $what, bool $cond, string $extra = ''): void { global $fails; echo ($cond ? '  ok   ' : '  FAIL ') . $what . ($cond ? '' : "  $extra") . "\n"; if (!$cond) $fails++; }
set_setting('npc_clockwork', '1');
foreach (q("SELECT * FROM locations WHERE kind = 'village' ORDER BY id")->fetchAll() as $v) stop_folk_ensure($v);
$all = trail_sights_all();
$who = 'Alder Thistledown';
$mark = fn(string $slug, bool $used = false) => ['x' => 1, 'y' => 1, 'slug' => $slug, 'row' => $all[$slug], 'left' => $used ? 0 : $all[$slug]['uses'], 'why' => ''];
$ctx = fn(string $dp, array $marks, array $tl = []) => ['now' => ['dp' => $dp, 'tl' => $tl, 'gd' => 12], 'marks' => $marks];
$branch = 'forest-the-lantern-branch'; $grotto = 'forest-the-glow-moss-grotto'; $bough = 'forest-the-owl-watch-bough';

echo "== the layer\n";
$h = trail_fam_forest($ctx('dusk', [$mark($branch, true), $mark($grotto), $mark('forest-the-fern-tunnel')]));
ok('renders at dusk for a forest section', str_contains($h, 'tfforest') && str_contains($h, 'Lantern row at dusk: 1 of 3 lit'), $h);
ok('one lantern per forest Sight, lit and unlit say so in words', substr_count($h, 'tff-l ') === 3 && str_contains($h, '>lit') && str_contains($h, '>unlit'), $h);
ok('the lit lantern has the lit class, the ready one does not', preg_match('/tff-l lit relay[^"]*"><span class="tff-ico" aria-hidden="true">🏮/', $h) === 1, $h);
ok('it renders at night too', str_contains(trail_fam_forest($ctx('night', [$mark($branch)])), 'tff-night'));
ok('not by day or dawn', trail_fam_forest($ctx('day', [$mark($branch)])) === '' && trail_fam_forest($ctx('dawn', [$mark($branch)])) === '');
ok('not for a section with no forest Sight', trail_fam_forest($ctx('dusk', [$mark('grassland-the-clover-patch')])) === '' && trail_fam_forest($ctx('dusk', [])) === '');
ok('relay line counts relay lanterns and today\'s tally (2.7.06: not the all-time 40)', str_contains($h, 'Lantern Relay: 1 of 2 relay lanterns lit') && str_contains(trail_fam_forest($ctx('dusk', [$mark($branch)], ['lanterns-lit' => 40, 'lanterns-lit@12' => 2, 'lanterns-lit@11' => 5])), '2 lit today'), $h);

echo "== fireflies and the appointment chip\n";
$f = npc_cw_forecast($who, $branch);
ok('Alder has a forecast at the lantern branch', $f !== null, 'none');
if ($f) {
    $GLOBALS['gv_cw_time'] = [$f['dow'], $f['from'] + 0.2, 20000 + $f['in']];
    $h = trail_fam_forest($ctx('dusk', [$mark($branch)]));
    ok('while he is there: fireflies on the lantern and a "here now" chip', str_contains($h, 'tff-fly') && str_contains($h, $who . ' at ') && str_contains($h, 'here now') && str_contains($h, 'tff-chip now'), $h);
    $GLOBALS['gv_cw_time'] = [$f['dow'], $f['to'] + 0.5, 20000 + $f['in']];
    $h = trail_fam_forest($ctx('dusk', [$mark($branch)]));
    ok('after he has gone: the chip says when he is next, no fireflies', str_contains($h, $who) && !str_contains($h, 'here now') && !str_contains($h, 'tff-fly'), $h);
    unset($GLOBALS['gv_cw_time']);
}
set_setting('npc_clockwork', '0'); setting('__reload__');
ok('clockwork off: no chips, still a lantern row', !str_contains(trail_fam_forest($ctx('dusk', [$mark($branch)])), 'tff-chip'));
set_setting('npc_clockwork', '1'); setting('__reload__');
$css = file_get_contents($argv[1] . '/assets/style.css');
ok('css has the block, the dark theme and reduced motion', str_contains($css, '.tfforest') && str_contains($css, ':root[data-theme="dark"] .tfforest') && preg_match('/prefers-reduced-motion: reduce\)\{\.tff-l\.lit/', $css) === 1);

echo "== Lantern Relay rows\n";
foreach (['forest-the-lantern-branch', 'forest-the-glow-moss-grotto', 'forest-the-woodcutter-s-stump', 'forest-the-mushroom-ring'] as $s) {
    $tok = array_map(fn($t) => $t['tok'], trail_sight_tokens($all[$s]['rewards']));
    ok("$s tallies lanterns-lit and pays the relay bonus", in_array('tally=lanterns-lit', $tok, true) && (bool)preg_grep('/^c=5:1$/', $tok));
}
ok('rows lint clean', !trail_sight_lint($all[$branch]) || !array_filter(trail_sight_lint($all[$branch]), fn($p) => !str_starts_with($p, 'no landmark picture')));
// play the lantern-branch rewards on the clover-patch tile of route 240 (as tests/trail_sights_270.php does)
$base = $all['grassland-the-clover-patch'];
set_setting('gnav_on', '1'); set_setting('gnav_tiles', '1'); set_setting('game_clock_on', '1'); set_setting('stop_daypart_force', 'dusk'); setting('__reload__');   // the Sight's dusk bonus: dp comes from this setting
$u = q_one("SELECT * FROM users WHERE username = 'sprout'");
q("UPDATE expeditions SET status = 'done' WHERE user_id = ?", [$u['id']]);
q("UPDATE routes SET kind = 'road' WHERE id = 240");
$r = q_one('SELECT * FROM routes WHERE id = 240');
q("UPDATE users SET location_id = ?, level = 1, energy = 90, coins = 500, ev_quickwalk = 0, game_day = 10, game_minute = 1140 WHERE id = ?", [$r['a_id'], $u['id']]);
q('DELETE FROM trail_sight_uses WHERE user_id = ?', [$u['id']]); q('DELETE FROM trail_sight_tally WHERE user_id = ?', [$u['id']]);
$u = q_one('SELECT * FROM users WHERE id = ?', [$u['id']]);
[$sok] = start_expedition($u, 240); ok('the walk starts', $sok);
$exp = active_expedition((int)$u['id']); $sc = trail_scene($exp);
$lm = array_values(array_filter($sc['map']['art']['objs'], fn($o) => $o[2] === 'lm-grassland-the-clover-patch'));
$spot = null; foreach ([[-1, 0], [1, 0], [0, -1], [0, 1], [0, 0]] as [$dx, $dy]) if (in_array(tm_tile($sc['map'], $lm[0][0] + $dx, $lm[0][1] + $dy), ['.', ',', 'S'], true)) { $spot = [$lm[0][0] + $dx, $lm[0][1] + $dy]; break; }
$sc['x'] = $spot[0]; $sc['y'] = $spot[1]; trail_save($sc);
trail_sights_ensure_tables();
$rw = $all[$branch]['rewards'];
q('DELETE FROM trail_sight_rows WHERE slug = ?', [$base['slug']]);
db_insert('trail_sight_rows', ['slug' => $base['slug'], 'verb' => $base['verb'], 'icon' => $base['icon'], 'energy' => 0, 'cd' => 55, 'uses' => 9, 'cond' => '-', 'chk' => '-', 'rewards' => $rw, 'win' => 'x', 'lose' => '', 'tool' => '-', 'fail_en' => 0, 'active' => 1]);
$GLOBALS['gv_sights_reload'] = true; trail_sights_all();
$coins = fn() => (int)q_val('SELECT coins FROM users WHERE id = ?', [$u['id']]);
$gain = [];
for ($i = 1; $i <= 4; $i++) {
    q('UPDATE users SET game_minute = 1140 WHERE id = ?', [$u['id']]);
    $u = q_one('SELECT * FROM users WHERE id = ?', [$u['id']]); $exp = active_expedition((int)$u['id']); $GLOBALS['gv_sights_reload'] = true;
    $c0 = $coins(); [$a] = trail_sight_do($u, $exp, $base['slug']); save_exp($exp);
    ok("use $i works", $a);
    $gain[$i] = $coins() - $c0;
}
ok('the private tally counts each use', (trail_sight_tallies((int)$u['id'])['lanterns-lit'] ?? 0) === 4, json_encode(trail_sight_tallies((int)$u['id'])));
ok('the relay bonus coins pay from the third lantern at dusk, not before', $gain[1] === 0 && $gain[2] === 0 && $gain[3] >= 5 && $gain[4] >= 5, json_encode($gain));

echo "== Who Lit the Wood?\n";
$qs = trail_sight_quests()['who-lit-the-wood'] ?? null;
ok('the line exists: 5 beats, at least 2 with npc=', $qs && count($qs['beats']) === 5 && count(array_filter($qs['beats'], fn($b) => str_starts_with($b[3], 'npc='))) >= 2);
ok('it is not a mentor', !in_array($who, npc_cw_fixed_names(), true) && npc_cw_profile(npc_cw_who_key($who))['mode'] === 'free');
$sights3 = array_unique(array_column(array_filter($qs['beats'], fn($b) => str_starts_with($b[3], 'npc=')), 0));
ok('he is met at 3 different forest Sights', count($sights3) === 3 && !array_filter($sights3, fn($s) => !str_starts_with($s, 'forest-')), json_encode($sights3));
foreach ([[20000, 0], [20003, 2], [20009, 5], [20015, 6]] as [$di, $dow]) {   // forecasts exist whatever day the player starts
    $GLOBALS['gv_cw_time'] = [$dow, 8.0, $di];
    foreach ($sights3 as $s) { $fc = npc_cw_forecast($who, $s); ok("forecast at $s from day $di", $fc && $fc['to'] > $fc['from'], json_encode($fc)); }
}
$u = q_one('SELECT * FROM users WHERE id = ?', [$u['id']]);
q('DELETE FROM user_sight_quests WHERE user_id = ?', [$u['id']]);
$loc = q_one('SELECT * FROM locations WHERE id = ?', [(int)$r['a_id']]);
$dpnow = ['dusk' => ['dp' => 'dusk', 'tl' => []], 'night' => ['dp' => 'night', 'tl' => []]];
$hook = function (string $slug, string $dp) use (&$u, $loc, $dpnow) { $u = q_one('SELECT * FROM users WHERE id = ?', [$u['id']]); return implode(' | ', trail_sight_quest_hook($u, $slug, $loc, $dpnow[$dp])); };
$GLOBALS['gv_cw_time'] = [3, 8.0, 20000];
$o = $hook('forest-the-mossy-stair', 'dusk');
ok('beat 1 (no villager): the line begins', str_contains($o, 'A quest begins') && str_contains($o, '1 of 5'), $o);
$beats = [[$branch, 'dusk'], [$bough, 'night'], [$grotto, 'night'], [$branch, 'dusk']];
$base_t = [3, 8.0, 20000]; $nth = 1;
foreach ($beats as [$slug, $dp]) {
    $nth++;
    // too early: he is not there, the card says when he is next, nothing counts, no penalty
    $GLOBALS['gv_cw_time'] = $base_t;
    $f = npc_cw_forecast($who, $slug);
    ok("beat $nth: forecast at $slug", (bool)$f, 'none');
    if (!$f) break;
    if (empty($f['now'])) {
        $o = $hook($slug, $dp);
        ok("beat $nth: he is not there yet, it says when he is next and does not count", str_contains($o, 'is not here now. Next: ') && !str_contains($o, ' of 5)'), $o);
    }
    $GLOBALS['gv_cw_time'] = [$f['dow'], $f['from'] + 0.2, $base_t[2] + $f['in']];
    $o = $hook($slug, $dp);
    ok("beat $nth at $slug: he is there, it counts", str_contains($o, "($nth of 5)") || ($nth === 5 && str_contains($o, 'is done')), $o);
    $base_t = [$f['dow'], $f['to'] + 0.5, $base_t[2] + $f['in']];
}
ok('the line is finished, paid once', (bool)q_val('SELECT done_at FROM user_sight_quests WHERE user_id = ? AND quest = ?', [$u['id'], 'who-lit-the-wood']));
$GLOBALS['gv_cw_time'] = $base_t;
$o = $hook($branch, 'dusk');
ok('nothing more counts afterwards', $o === '', $o);
unset($GLOBALS['gv_cw_time']);
echo $fails ? "$fails FAILED\n" : "ok\n";
exit($fails ? 1 : 0);
