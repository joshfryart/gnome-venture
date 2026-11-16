<?php
// Island family (2.7.01): the Ferry strip, the hammock palms (only by a crossing, tally) and "Pinchwell's Postcards" with villagers by their weekly clockwork and a 7th game day finale.
// php tests/trail_fam_island.php GAME_DIR   (an installed game, player "sprout"; walk.sh installs one)
$_SERVER['SCRIPT_NAME'] = '/adventure.php';
require $argv[1] . '/includes/bootstrap.php';
require_once $argv[1] . '/includes/adventure.php';
require_once $argv[1] . '/includes/trail_tiles.php';
require_once $argv[1] . '/includes/trail_sights.php';
require_once $argv[1] . '/includes/stop_folk.php';
require_once $argv[1] . '/includes/npc_clockwork.php';
require_once $argv[1] . '/includes/trail_fam_island.php';
$fails = 0;
$GLOBALS['gv_sights_nocache'] = true;
set_exception_handler(function (Throwable $e) { echo '  EXCEPTION ' . get_class($e) . ': ' . $e->getMessage() . ' @ ' . basename($e->getFile()) . ':' . $e->getLine() . "\n"; exit(1); });
function ok(string $what, bool $cond, string $extra = ''): void { global $fails; echo ($cond ? '  ok   ' : '  FAIL ') . $what . ($cond ? '' : "  $extra") . "\n"; if (!$cond) $fails++; }
set_setting('npc_clockwork', '1');
foreach (q("SELECT * FROM locations WHERE kind = 'village' ORDER BY id")->fetchAll() as $v) stop_folk_ensure($v);
$all = trail_sights_all();
$mark = fn(string $slug) => ['x' => 1, 'y' => 1, 'slug' => $slug, 'row' => $all[$slug], 'left' => $all[$slug]['uses'], 'why' => ''];
$ctx = fn(string $dp, array $marks, array $clock = [3, 8.0, 20001], array $tl = []) => ['now' => ['dp' => $dp, 'tl' => $tl], 'marks' => $marks, 'clock' => $clock, 'land' => 'island'];
$palms = 'island-the-hammock-palms'; $spit = 'island-the-sand-spit'; $bell = 'island-the-shell-bell-tree'; $cave = 'island-the-tide-cave'; $lag = 'island-the-lagoon-edge';

echo "== the ferry (pure function of the clock)
";
$a = trail_fam_island_ferry(9.0, 20000); $b = trail_fam_island_ferry(9.0, 20000);
ok('same clock, same ferry', $a === $b);
ok('docks at 6 and 18 for 2 hours, a 12 hour rhythm', trail_fam_island_ferry(6.0)['state'] === 'docked' && trail_fam_island_ferry(7.9)['state'] === 'docked' && trail_fam_island_ferry(8.0)['state'] === 'away' && trail_fam_island_ferry(18.0)['state'] === 'docked' && trail_fam_island_ferry(19.5)['state'] === 'docked' && trail_fam_island_ferry(20.0)['state'] === 'away' && trail_fam_island_ferry(12.0)['state'] === 'away');
$rh = true; for ($hh = 0.0; $hh < 12; $hh += 0.5) if (trail_fam_island_ferry($hh)['state'] !== trail_fam_island_ferry($hh + 12)['state']) $rh = false;
ok('every state repeats 12 hours later', $rh);
ok('words: docked says when it leaves, away says when it is back', trail_fam_island_ferry(6.0)['text'] === 'Ferry at the dock, leaves in 2 h' && trail_fam_island_ferry(12.0)['text'] === 'Ferry away, back in 6 h' && trail_fam_island_ferry(17.5)['text'] === 'Ferry away, back in 1 h');
ok('the boat dot sits at the dock when docked and sails out in between', trail_fam_island_ferry(7.0)['pos'] === 0.0 && trail_fam_island_ferry(13.0)['pos'] > 0.9);

echo "== the layer
";
$h = trail_fam_island($ctx('dawn', [$mark($palms), $mark($spit)], [3, 6.5, 20001]));
ok('renders for a section with island Sights', str_contains($h, 'tfisland') && str_contains($h, 'Ferry at the dock'), $h);
ok('the lane is an inline SVG with a text alternative and a boat dot', str_contains($h, '<svg class="tfi-svg"') && str_contains($h, 'role="img"') && str_contains($h, 'aria-label="Ferry timetable:') && str_contains($h, 'tfi-boat'), $h);
ok('the state is said in words, not colour only', str_contains($h, '(docked now'), $h);
ok('the palms are open while the boat is in', str_contains($h, 'tfi-p open') && str_contains($h, 'the boat is in'), $h);
$hd = trail_fam_island($ctx('day', [$mark($palms)], [3, 12.0, 20001]));
ok('midday the ferry is away and the palms say no boat', str_contains($hd, 'Ferry away') && str_contains($hd, 'no boat now') && str_contains($hd, 'tfi-p shut'), $hd);
ok('the boat dot moves with the hour', trail_fam_island($ctx('day', [$mark($spit)], [3, 10.0, 20001])) !== trail_fam_island($ctx('day', [$mark($spit)], [3, 14.0, 20001])));
ok('not for a section with no island Sight', trail_fam_island($ctx('dawn', [$mark('coast-the-kelp-line')])) === '' && trail_fam_island($ctx('dawn', [])) === '' && trail_fam_island($ctx('dawn', [$mark('grassland-the-clover-patch')])) === '');
ok('not for numbered Maplewold marks', trail_fam_island($ctx('dawn', [['x' => 1, 'y' => 1, 'slug' => '12-the-old-well', 'row' => $all[$palms], 'left' => 1, 'why' => '']])) === '');
ok('the tally shows', str_contains(trail_fam_island($ctx('dawn', [$mark($palms)], [3, 6.0, 20001], ['crossings' => 4])), 'Crossings made: 4'));
$css = file_get_contents($argv[1] . '/assets/style.css');
ok('css has the block and the dark theme', str_contains($css, '.tfisland') && str_contains($css, ':root[data-theme="dark"] .tfisland'));

echo "== appointment chip
";
$who = 'Tansy Thistledown';
$f = npc_cw_forecast($who, $spit);
ok("$who has a forecast at the sand spit", $f !== null);
if ($f) {
    $GLOBALS['gv_cw_time'] = [$f['dow'], $f['from'] + 0.2, 20000 + $f['in']];
    $h = trail_fam_island($ctx('dawn', [$mark($spit)], $GLOBALS['gv_cw_time']));
    ok('while she is there: a "here now" chip', str_contains($h, $who . ' at ') && str_contains($h, 'here now') && str_contains($h, 'tfi-chip now'), $h);
    $GLOBALS['gv_cw_time'] = [$f['dow'], $f['to'] + 0.5, 20000 + $f['in']];
    $h = trail_fam_island($ctx('day', [$mark($spit)], $GLOBALS['gv_cw_time']));
    ok('after she has gone: the chip says when she is next', str_contains($h, $who) && !str_contains($h, 'here now'), $h);
    unset($GLOBALS['gv_cw_time']);
}
set_setting('npc_clockwork', '0'); setting('__reload__');
ok('clockwork off: no chips, the strip stays', !str_contains(trail_fam_island($ctx('dawn', [$mark($spit)])), 'tfi-chip') && str_contains(trail_fam_island($ctx('dawn', [$mark($spit)])), 'tfisland'));
set_setting('npc_clockwork', '1'); setting('__reload__');

echo "== hammock palms rows
";
$tokens = fn(string $s) => array_map(fn($t) => $t['tok'] . ($t['cond'] !== '' ? '?' . $t['cond'] : ''), trail_sight_tokens($all[$s]['rewards']));
ok('the palms open on the dawn and dusk crossings only', $all[$palms]['when'] === 'dp=dawn,dusk' && trail_sight_cond_ok($all[$palms]['when'], ['dp' => 'dawn']) && trail_sight_cond_ok($all[$palms]['when'], ['dp' => 'dusk']) && !trail_sight_cond_ok($all[$palms]['when'], ['dp' => 'day']) && !trail_sight_cond_ok($all[$palms]['when'], ['dp' => 'night']));
ok('the palms count a crossing and pay at 5 and 12', in_array('tally=crossings', $tokens($palms), true) && (bool)preg_grep('/^item=cowrie-shell:1\?tn=crossings:5$/', $tokens($palms)) && (bool)preg_grep('/^title=Ferry Regular\?tn=crossings:12$/', $tokens($palms)));
$lint = array_filter(trail_sight_lint($all[$palms]), fn($p) => !str_starts_with($p, 'no landmark picture'));
ok('the palms lint clean', !$lint, json_encode(array_values($lint)));
$fk = trail_sight_folk();
ok('Pinchwell comes on the crossings (dp=dawn,dusk)', (bool)array_filter($fk[$palms], fn($r) => str_starts_with($r['who'], 'Pinchwell') && str_contains($r['when'], 'dp=dawn,dusk')));
ok('Pinchwell has a sure row on the 7th game day (gd=7:0)', (bool)array_filter($fk[$palms], fn($r) => str_starts_with($r['who'], 'Pinchwell') && str_contains($r['when'], 'gd=7:0')));

echo "== play: the palms by the boat
";
$base = $all['grassland-the-clover-patch'];
set_setting('gnav_on', '1'); set_setting('gnav_tiles', '1'); set_setting('game_clock_on', '1'); setting('__reload__');
$u = q_one("SELECT * FROM users WHERE username = 'sprout'");
q("UPDATE expeditions SET status = 'done' WHERE user_id = ?", [$u['id']]);
q("UPDATE routes SET kind = 'road' WHERE id = 240");
$r = q_one('SELECT * FROM routes WHERE id = 240');
q("UPDATE users SET location_id = ?, level = 1, energy = 90, coins = 500, ev_quickwalk = 0, game_day = 10, game_minute = 390 WHERE id = ?", [$r['a_id'], $u['id']]);
q('DELETE FROM trail_sight_uses WHERE user_id = ?', [$u['id']]); q('DELETE FROM trail_sight_tally WHERE user_id = ?', [$u['id']]);
$u = q_one('SELECT * FROM users WHERE id = ?', [$u['id']]);
[$sok] = start_expedition($u, 240); ok('the walk starts', $sok);
$exp = active_expedition((int)$u['id']); $sc = trail_scene($exp);
$lm = array_values(array_filter($sc['map']['art']['objs'], fn($o) => $o[2] === 'lm-grassland-the-clover-patch'));
$spot = null; foreach ([[-1, 0], [1, 0], [0, -1], [0, 1], [0, 0]] as [$dx, $dy]) if (in_array(tm_tile($sc['map'], $lm[0][0] + $dx, $lm[0][1] + $dy), ['.', ',', 'S'], true)) { $spot = [$lm[0][0] + $dx, $lm[0][1] + $dy]; break; }
$sc['x'] = $spot[0]; $sc['y'] = $spot[1]; trail_save($sc);
trail_sights_ensure_tables();
q('DELETE FROM trail_sight_rows WHERE slug = ?', [$base['slug']]);
db_insert('trail_sight_rows', ['slug' => $base['slug'], 'verb' => $base['verb'], 'icon' => $base['icon'], 'energy' => 0, 'cd' => 0, 'uses' => 99, 'cond' => $all[$palms]['when'], 'chk' => '-', 'rewards' => $all[$palms]['rewards'], 'win' => 'x', 'lose' => '', 'tool' => '-', 'fail_en' => 0, 'active' => 1]);
$GLOBALS['gv_sights_reload'] = true; trail_sights_all();
$use = function (float $hr) use (&$u, &$exp, $base) { $GLOBALS['gv_cw_time'] = [3, $hr, 20003]; set_setting('stop_daypart_force', $hr < 8 ? 'dawn' : 'day'); setting('__reload__'); $u = q_one('SELECT * FROM users WHERE id = ?', [$u['id']]); $exp = active_expedition((int)$u['id']); $GLOBALS['gv_sights_reload'] = true; $r = trail_sight_do($u, $exp, $base['slug']); save_exp($exp); return $r; };
[$a] = $use(12.0);
ok('with the ferry away (midday) the palms will not work', !$a);
$tally = fn() => (trail_sight_tallies((int)$u['id'])['crossings'] ?? 0);
ok('and count nothing', $tally() === 0);
for ($i = 1; $i <= 5; $i++) { q('DELETE FROM trail_sight_uses WHERE user_id = ?', [$u['id']]); [$a, $msg] = $use(6.5); ok("crossing $i (the dawn boat) works", $a, json_encode($msg)); }
ok('five crossings: the tally is 5', $tally() === 5, (string)$tally());
unset($GLOBALS['gv_cw_time']);

echo "== Pinchwell's Postcards
";
$qs = trail_sight_quests()['pinchwells-postcards'] ?? null;
ok('the line exists with 5 beats and at least 2 npc= beats', $qs && count($qs['beats']) === 5 && count(array_filter($qs['beats'], fn($b) => str_starts_with($b[3], 'npc='))) >= 2);
ok('it passes the quest lint', $qs && !trail_sight_quest_lint($qs, $all, trail_sight_quests()), json_encode($qs ? trail_sight_quest_lint($qs, $all, trail_sight_quests()) : null));
ok('four islands in order then the palms on a 7th game day', $qs && array_column($qs['beats'], 0) === [$spit, $cave, $bell, $lag, $palms] && str_contains($qs['beats'][4][2], 'gd=7:0'));
ok('no mentor is used', !array_filter(array_map(fn($b) => substr($b[3], 4), array_filter($qs['beats'], fn($b) => str_starts_with($b[3], 'npc='))), fn($n) => in_array($n, npc_cw_fixed_names(), true)));
$npcs = ['Tansy Thistledown' => $spit, 'Willa Thistledown' => $cave, 'Fennel Mossgrove' => $lag];
foreach ($npcs as $n => $s) ok("$n is a free villager (the clockwork moves them)", npc_cw_profile(npc_cw_who_key($n))['mode'] === 'free');
foreach ([[20000, 0], [20003, 2], [20009, 5], [20015, 6]] as [$di, $dow]) {
    $GLOBALS['gv_cw_time'] = [$dow, 8.0, $di];
    foreach ($npcs as $n => $s) { $fc = npc_cw_forecast($n, $s); ok("forecast for $n at $s from day $di", $fc && $fc['to'] > $fc['from'], json_encode($fc)); }
}
$u = q_one('SELECT * FROM users WHERE id = ?', [$u['id']]);
q('DELETE FROM user_sight_quests WHERE user_id = ?', [$u['id']]);
$loc = q_one('SELECT * FROM locations WHERE id = ?', [(int)$r['a_id']]);
$gd = 10;
$hook = function (string $slug, string $dp) use (&$u, $loc, &$gd) { $u = q_one('SELECT * FROM users WHERE id = ?', [$u['id']]); return implode(' | ', trail_sight_quest_hook($u, $slug, $loc, ['dp' => $dp, 'tl' => [], 'gd' => $gd])); };
$base_t = [3, 8.0, 20000];
$step = function (int $nth, string $slug, string $who, string $dp) use (&$base_t, $hook) {
    $GLOBALS['gv_cw_time'] = $base_t;
    $f = npc_cw_forecast($who, $slug);
    ok("beat $nth: forecast for $who", (bool)$f, 'none'); if (!$f) return false;
    if (empty($f['now'])) { $o = $hook($slug, $dp); ok("beat $nth: $who is not there yet, it says when they are next and does not count (no penalty)", str_contains($o, $who . ' is not here now. Next: ') && !str_contains($o, ' of 5)'), $o); }
    $GLOBALS['gv_cw_time'] = [$f['dow'], $f['from'] + 0.2, $base_t[2] + $f['in']];
    $o = $hook($slug, $dp);
    ok("beat $nth at $slug: $who is there, it counts", str_contains($o, "($nth of 5)") || ($nth === 1 && str_contains($o, '1 of 5')), $o);
    $base_t = [$f['dow'], $f['to'] + 0.5, $base_t[2] + $f['in']];
    return true;
};
$step(1, $spit, 'Tansy Thistledown', 'dawn');
$step(2, $cave, 'Willa Thistledown', 'dawn');
$GLOBALS['gv_cw_time'] = $base_t;
$o = $hook($bell, 'day'); ok('beat 3 (shell-bell tree) does not count by day', !str_contains($o, ' of 5)'), $o);
$o = $hook($bell, 'dusk'); ok('beat 3: at dusk the postcard chimes down', str_contains($o, '(3 of 5)'), $o);
$step(4, $lag, 'Fennel Mossgrove', 'dawn');
$GLOBALS['gv_cw_time'] = $base_t;
$o = $hook($palms, 'dawn'); ok('finale on game day 10 (not a 7th day): the ferry brings nothing, no count', !str_contains($o, 'is done') && !str_contains($o, '5 of 5'), $o);
$gd = 14;
$o = $hook($palms, 'day'); ok('finale on day 14 but with the ferry away (day): no count', !str_contains($o, 'is done'), $o);
$o = $hook($palms, 'dusk'); ok("finale on game day 14 on the dusk crossing: Pinchwell's Postcards is done", str_contains($o, "Pinchwell's Postcards is done"), $o);
ok('the line is finished, paid once', (bool)q_val('SELECT done_at FROM user_sight_quests WHERE user_id = ? AND quest = ?', [$u['id'], 'pinchwells-postcards']));
ok('nothing more counts afterwards', $hook($palms, 'dusk') === '');
unset($GLOBALS['gv_cw_time']);
echo $fails ? "$fails FAILED
" : "ok
";
exit($fails ? 1 : 0);
