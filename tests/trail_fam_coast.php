<?php
// Coast family (2.7.01): the Tide strip, the Tide Table rows (pools open at dawn and dusk, tally, fisher nocheck) and "The Message in the Bottle" with villagers by their weekly clockwork.
// php tests/trail_fam_coast.php GAME_DIR   (an installed game, player "sprout"; walk.sh installs one)
$_SERVER['SCRIPT_NAME'] = '/adventure.php';
require $argv[1] . '/includes/bootstrap.php';
require_once $argv[1] . '/includes/adventure.php';
require_once $argv[1] . '/includes/trail_tiles.php';
require_once $argv[1] . '/includes/trail_sights.php';
require_once $argv[1] . '/includes/stop_folk.php';
require_once $argv[1] . '/includes/npc_clockwork.php';
require_once $argv[1] . '/includes/trail_fam_coast.php';
$fails = 0;
set_setting('sights_walk_cap', '0');   // 2.7.08: this test uses many Sights on one walk (the cap: tests/trail_sights_278.php)
$GLOBALS['gv_sights_nocache'] = true;
set_exception_handler(function (Throwable $e) { echo '  EXCEPTION ' . get_class($e) . ': ' . $e->getMessage() . ' @ ' . basename($e->getFile()) . ':' . $e->getLine() . "\n"; exit(1); });
function ok(string $what, bool $cond, string $extra = ''): void { global $fails; echo ($cond ? '  ok   ' : '  FAIL ') . $what . ($cond ? '' : "  $extra") . "\n"; if (!$cond) $fails++; }
set_setting('npc_clockwork', '1');
foreach (q("SELECT * FROM locations WHERE kind = 'village' ORDER BY id")->fetchAll() as $v) stop_folk_ensure($v);
$all = trail_sights_all();
$mark = fn(string $slug) => ['x' => 1, 'y' => 1, 'slug' => $slug, 'row' => $all[$slug], 'left' => $all[$slug]['uses'], 'why' => ''];
$ctx = fn(string $dp, array $marks, array $clock = [3, 8.0, 20001], array $tl = []) => ['now' => ['dp' => $dp, 'tl' => $tl, 'ti' => moon_tide((float)$clock[1], (int)$clock[2])['state']], 'marks' => $marks, 'clock' => $clock, 'land' => 'coast'];
$kelp = 'coast-the-kelp-line'; $steps = 'coast-the-tide-pool-steps'; $wall = 'coast-the-barnacle-wall'; $sandbar = 'coast-the-sandbar-causeway'; $rack = 'coast-the-rope-and-net-rack'; $gap = 'coast-the-sea-stack-gap';
$light = 'coast-the-lighthouse-shadow'; $post = 'coast-the-bottle-post';

require_once $argv[1] . '/includes/moon.php';
$findH = function (int $di, string $state): float { for ($h = 0.0; $h < 24; $h += 0.25) if (moon_tide($h, $di)['state'] === $state) return $h; return -1.0; };
$DI = 20003; $lowH = $findH($DI, 'low'); $highH = $findH($DI, 'high'); $fallH = $findH($DI, 'falling'); $riseH = $findH($DI, 'rising');
echo "== the moon and the tide\n";
$a = trail_fam_coast_tide(9.0, 20000); $b = trail_fam_coast_tide(9.0, 20000);
ok('same clock, same tide', $a === $b);
$ph = array_map(fn($d) => moon_phase($d)['key'], range(0, 27));
ok('a month is 28 game days with new at 0 and full at 14', moon_phase(0)['key'] === 'new' && moon_phase(14)['key'] === 'full' && moon_phase(28)['key'] === 'new' && count(array_unique($ph)) === 8, json_encode(array_count_values($ph)));
ok('spring tides at new and full, neap at the quarters', moon_phase(0)['range'] === 'spring' && moon_phase(14)['range'] === 'spring' && moon_phase(7)['range'] === 'neap' && moon_phase(21)['range'] === 'neap');
ok('spring tides are taller than neap', moon_phase(0)['amp'] > moon_phase(7)['amp'] + 0.3);
$bad = 0; $lowsHit = 0; $n = 0;
foreach (range(0, 27) as $di) {
    $t = moon_tide(0.0, $di);
    if (count($t['lows']) < 1 || count($t['lows']) > 2 || count($t['highs']) < 1 || count($t['highs']) > 2) $bad++;
    foreach ($t['highs'] as $h) if (moon_level((float)$h, $di) < 0.5) $bad++;
}
ok('every day has one or two highs and lows, each real high is high', $bad === 0, (string)$bad);
$dh = fmod(moon_tide(0.0, 101)['highs'][0] - moon_tide(0.0, 100)['highs'][0] + 24.88, MOON_TIDE_PERIOD);
ok('the tides come about 53 minutes later each day (a lunar day)', abs($dh - 0.89) < 0.9 || abs($dh - (MOON_TIDE_PERIOD - 0.89)) < 0.9, (string)$dh);
ok('level is continuous over midnight', abs(moon_level(23.99, 5) - moon_level(0.0, 6)) < 0.05, (string)(moon_level(23.99, 5) - moon_level(0.0, 6)));
ok('a neap low barely opens the pools; a spring low goes right out', moon_phase(7)['amp'] * -1 > -0.7 && moon_phase(0)['amp'] === 1.0);
$low = null; for ($h = 0; $h < 24; $h += 0.25) if (moon_tide($h, 20000)['state'] === 'low') { $low = $h; break; }
$GLOBALS['gv_cw_time'] = [3, $low ?? 6.0, 20000];
require_once $argv[1] . '/includes/trail_sight_extras.php';
$nowA = trail_sight_now(['landscape' => 'coast', 'name' => 'x', 'region' => 'The Maplewold'], null, null);
ok('the Sights `now` carries the moon and the tide, and ti=low holds at low tide', $low !== null && $nowA['ti'] === 'low' && trail_sight_cond_ok('ti=low', $nowA) && !trail_sight_cond_ok('ti=high', $nowA) && trail_sight_cond_ok('mo=' . $nowA['mo'], $nowA), json_encode([$low, $nowA['ti'] ?? null, $nowA['mo'] ?? null]));
unset($GLOBALS['gv_cw_time']);
$t = trail_fam_coast_tide($fallH, $DI);
ok('words: "Low tide in N h" while it falls', $fallH >= 0 && $t['state'] === 'falling' && str_starts_with($t['text'], 'Low tide in '), json_encode($t['text']));
$t = trail_fam_coast_tide($riseH, $DI);
ok('words: "High tide in N h" while it rises', $riseH >= 0 && $t['state'] === 'rising' && str_starts_with($t['text'], 'High tide in '), $t['text']);
ok('words: low now says when it turns', $lowH >= 0 && str_starts_with(trail_fam_coast_tide($lowH, $DI)['text'], 'Low tide now, turning in '));

echo "== the layer\n";
$h = trail_fam_coast($ctx('dawn', [$mark($kelp), $mark($steps), $mark($gap)], [3, $lowH, $DI]));
ok('renders for a section with coast Sights, with the moon', str_contains($h, 'tfcoast') && str_contains($h, 'Low tide now') && str_contains($h, 'tfc-moon') && str_contains($h, moon_phase($DI)['name']), $h);
ok('the arc is an inline SVG with a text alternative and a notch for now', str_contains($h, '<svg class="tfc-svg"') && str_contains($h, 'role="img"') && str_contains($h, 'aria-label="Tide today:') && str_contains($h, 'tfc-now'), $h);
ok('the state is said in words, not colour only', str_contains($h, '(low now'), $h);
$h2 = trail_fam_coast($ctx('dawn', [$mark($kelp), $mark($steps), $mark($gap)], [3, $lowH, $DI]));
ok('the same clock draws the same strip', $h === $h2);
ok('the notch moves with the hour', trail_fam_coast($ctx('day', [$mark($kelp)], [3, 12.0, 20000])) !== trail_fam_coast($ctx('day', [$mark($kelp)], [3, 14.0, 20000])));
ok('the pools: open at low tide', str_contains($h, 'tfc-p open') && !str_contains($h, 'tfc-p shut'));
$hd = trail_fam_coast($ctx('day', [$mark($kelp), $mark($steps)], [3, $highH, $DI]));
ok('at high tide the pools say under water and 0 of 2 open', str_contains($hd, 'under water') && str_contains($hd, '0 of 2 open'), $hd);
ok('not for a section with no coast Sight (a grassland one, none at all)', trail_fam_coast($ctx('dawn', [$mark('grassland-the-clover-patch')])) === '' && trail_fam_coast($ctx('dawn', [])) === '');
ok('not for a Maplewold-style mark list (numbered slugs)', trail_fam_coast($ctx('dawn', [['x' => 1, 'y' => 1, 'slug' => '12-the-old-well', 'row' => $all[$kelp], 'left' => 1, 'why' => '']])) === '');
ok('a coast mark among Maplewold ones still draws it', str_contains(trail_fam_coast($ctx('dawn', [['x' => 1, 'y' => 1, 'slug' => '12-the-old-well', 'row' => $all[$kelp], 'left' => 1, 'why' => ''], $mark($gap)])), 'tfcoast'));
ok('the tally shows', str_contains(trail_fam_coast($ctx('dawn', [$mark($kelp)], [3, 6.0, 20000], ['tide-pools' => 4])), 'Pools worked: 4'));
$css = file_get_contents($argv[1] . '/assets/style.css');
ok('css has the block and the dark theme', str_contains($css, '.tfcoast') && str_contains($css, ':root[data-theme="dark"] .tfcoast'));

echo "== appointment chip (next-appointment from the clockwork)\n";
$who = 'Sorrel Dewdrop';
$f = npc_cw_forecast($who, $rack);
ok('Sorrel has a forecast at the rope-and-net rack', $f !== null);
if ($f) {
    $GLOBALS['gv_cw_time'] = [$f['dow'], $f['from'] + 0.2, 20000 + $f['in']];
    $h = trail_fam_coast($ctx('dawn', [$mark($rack)], $GLOBALS['gv_cw_time']));
    ok('while she is there: a "here now" chip', str_contains($h, $who . ' at The rope-and-net rack') && str_contains($h, 'here now') && str_contains($h, 'tfc-chip now'), $h);
    $GLOBALS['gv_cw_time'] = [$f['dow'], $f['to'] + 0.5, 20000 + $f['in']];
    $h = trail_fam_coast($ctx('day', [$mark($rack)], $GLOBALS['gv_cw_time']));
    ok('after she has gone: the chip says when she is next', str_contains($h, $who) && !str_contains($h, 'here now'), $h);
    unset($GLOBALS['gv_cw_time']);
}
set_setting('npc_clockwork', '0'); setting('__reload__');
ok('clockwork off: no chips, the strip stays', !str_contains(trail_fam_coast($ctx('dawn', [$mark($rack)])), 'tfc-chip') && str_contains(trail_fam_coast($ctx('dawn', [$mark($rack)])), 'tfcoast'));
set_setting('npc_clockwork', '1'); setting('__reload__');

echo "== Tide Table rows\n";
$tokens = fn(string $s) => array_map(fn($t) => $t['tok'] . ($t['cond'] !== '' ? '?' . $t['cond'] : ''), trail_sight_tokens($all[$s]['rewards']));
foreach ([$kelp, $steps, $wall, $sandbar] as $s) {
    ok("$s opens at low tide only", $all[$s]['when'] === 'ti=low' && trail_sight_cond_ok($all[$s]['when'], ['ti' => 'low']) && !trail_sight_cond_ok($all[$s]['when'], ['ti' => 'high']) && !trail_sight_cond_ok($all[$s]['when'], ['ti' => 'rising']));
    ok("$s counts a tide pool and pays at 5 and 12", in_array('tally=tide-pools', $tokens($s), true) && (bool)preg_grep('/^item=sea-glass:1\?tn=tide-pools:5$/', $tokens($s)) && (bool)preg_grep('/^title=Tide Reader\?tn=tide-pools:12$/', $tokens($s)));
    $lint = array_filter(trail_sight_lint($all[$s]), fn($p) => !str_starts_with($p, 'no landmark picture'));
    ok("$s lints clean", !$lint, json_encode(array_values($lint)));
}
$fk = trail_sight_folk();
$nocheck = fn(string $slug, string $name) => (bool)array_filter($fk[$slug] ?? [], fn($r) => trail_sight_split_who($r['who'])[0] === $name && in_array('nocheck', array_map('trim', explode(',', $r['rewards'])), true));
ok('the fisher makes the pool check a sure thing (nocheck folk rows at the steps and the wall)', $nocheck($steps, 'Nettle Teaspoon') && $nocheck($wall, 'Tuck Puddlefoot'));
ok('the folk rows sit in the open window (dp=dusk / dp=dawn)', (bool)array_filter($fk[$steps], fn($r) => $r['when'] === 'dp=dusk') && (bool)array_filter($fk[$wall], fn($r) => $r['when'] === 'dp=dawn'));
ok('the other villager at the steps (Rook) now comes when the pools are open', (bool)array_filter($fk[$steps], fn($r) => str_starts_with($r['who'], 'Rook Rushworth') && str_contains($r['when'], 'dawn')));

echo "== play: a pool row's tally and milestones\n";
$base = $all['grassland-the-clover-patch'];
set_setting('gnav_on', '1'); set_setting('gnav_tiles', '1'); set_setting('game_clock_on', '1'); setting('__reload__');
$u = q_one("SELECT * FROM users WHERE username = 'sprout'");
q("UPDATE expeditions SET status = 'done' WHERE user_id = ?", [$u['id']]);
q("UPDATE routes SET kind = 'road' WHERE id = 240");
$r = q_one('SELECT * FROM routes WHERE id = 240');
q("UPDATE users SET location_id = ?, level = 1, energy = 90, coins = 500, ev_quickwalk = 0, game_day = 10, game_minute = 390 WHERE id = ?", [$r['a_id'], $u['id']]);   // 6:30, dawn
q('DELETE FROM trail_sight_uses WHERE user_id = ?', [$u['id']]); q('DELETE FROM trail_sight_tally WHERE user_id = ?', [$u['id']]);
$u = q_one('SELECT * FROM users WHERE id = ?', [$u['id']]);
[$sok] = start_expedition($u, 240); ok('the walk starts', $sok);
$exp = active_expedition((int)$u['id']); $sc = trail_scene($exp);
$lm = array_values(array_filter($sc['map']['art']['objs'], fn($o) => $o[2] === 'lm-grassland-the-clover-patch'));
$spot = null; foreach ([[-1, 0], [1, 0], [0, -1], [0, 1], [0, 0]] as [$dx, $dy]) if (in_array(tm_tile($sc['map'], $lm[0][0] + $dx, $lm[0][1] + $dy), ['.', ',', 'S'], true)) { $spot = [$lm[0][0] + $dx, $lm[0][1] + $dy]; break; }
$sc['x'] = $spot[0]; $sc['y'] = $spot[1]; trail_save($sc);
trail_sights_ensure_tables();
// the kelp line's rewards with the tide gate, played on the clover patch tile (as tests/trail_fam_forest.php does)
q('DELETE FROM trail_sight_rows WHERE slug = ?', [$base['slug']]);
db_insert('trail_sight_rows', ['slug' => $base['slug'], 'verb' => $base['verb'], 'icon' => $base['icon'], 'energy' => 0, 'cd' => 55, 'uses' => 9, 'cond' => $all[$kelp]['when'], 'chk' => '-', 'rewards' => $all[$kelp]['rewards'], 'win' => 'x', 'lose' => '', 'tool' => '-', 'fail_en' => 0, 'active' => 1]);
$GLOBALS['gv_sights_reload'] = true; trail_sights_all();
$setMin = function (string $dp) use ($lowH, $highH, $DI) { $GLOBALS['gv_cw_time'] = [3, $dp === 'low' ? $lowH : $highH, $DI]; };   // the part of the day the Sight sees (the test has no logged-in clock)
$use = function () use (&$u, &$exp, $base) { $u = q_one('SELECT * FROM users WHERE id = ?', [$u['id']]); $exp = active_expedition((int)$u['id']); $GLOBALS['gv_sights_reload'] = true; $r = trail_sight_do($u, $exp, $base['slug']); save_exp($exp); return $r; };
$setMin('high');
[$a, $msg0] = $use(); ok('at high water the pool row will not work', !$a);
$tally = fn() => (trail_sight_tallies((int)$u['id'])['tide-pools'] ?? 0);
ok('and counts nothing', $tally() === 0);
$glass = fn() => (int)q_val("SELECT COALESCE(SUM(ui.qty),0) FROM user_items ui JOIN items i ON i.id = ui.item_id WHERE ui.user_id = ? AND i.slug = 'sea-glass'", [$u['id']]);
for ($i = 1; $i <= 5; $i++) { $setMin('low'); [$a, $msg] = $use(); ok("pool visit $i (low tide) works", $a, json_encode($msg)); }
ok('five visits: the tally is 5', $tally() === 5, (string)$tally());
ok('the fifth visit paid the sea glass gift (a chance row also gives some)', $glass() >= 1, (string)$glass());

unset($GLOBALS['gv_cw_time']); set_setting('stop_daypart_force', ''); setting('__reload__');
echo "== The Message in the Bottle\n";
$qs = trail_sight_quests()['message-in-the-bottle'] ?? null;
ok('the line exists with 5 beats and at least 2 npc= beats', $qs && count($qs['beats']) === 5 && count(array_filter($qs['beats'], fn($b) => str_starts_with($b[3], 'npc='))) >= 2);
ok('it passes the quest lint', $qs && !trail_sight_quest_lint($qs, $all, trail_sight_quests()), json_encode($qs ? trail_sight_quest_lint($qs, $all, trail_sight_quests()) : null));
ok('the finale is the lighthouse keeper at dawn', $qs && $qs['beats'][4][0] === $light && $qs['beats'][4][2] === 'dp=dawn' && $qs['beats'][4][3] === 'npc=Keeper Loamwick');
ok('no mentor is used', !array_filter(array_map(fn($b) => substr($b[3], 4), array_filter($qs['beats'], fn($b) => str_starts_with($b[3], 'npc='))), fn($n) => in_array($n, npc_cw_fixed_names(), true)));
$npcs = ['Sorrel Dewdrop' => $rack, 'Alder Puddlefoot' => $gap];
foreach ($npcs as $n => $s) ok("$n is a free villager (the clockwork moves them)", npc_cw_profile(npc_cw_who_key($n))['mode'] === 'free');
foreach ([[20000, 0], [20003, 2], [20009, 5], [20015, 6]] as [$di, $dow]) {
    $GLOBALS['gv_cw_time'] = [$dow, 8.0, $di];
    foreach ($npcs as $n => $s) { $fc = npc_cw_forecast($n, $s); ok("forecast for $n at $s from day $di", $fc && $fc['to'] > $fc['from'], json_encode($fc)); }
}
$u = q_one('SELECT * FROM users WHERE id = ?', [$u['id']]);
q('DELETE FROM user_sight_quests WHERE user_id = ?', [$u['id']]);
$loc = q_one('SELECT * FROM locations WHERE id = ?', [(int)$r['a_id']]);
$hook = function (string $slug, string $dp) use (&$u, $loc) { $u = q_one('SELECT * FROM users WHERE id = ?', [$u['id']]); return implode(' | ', trail_sight_quest_hook($u, $slug, $loc, ['dp' => $dp, 'tl' => [], 'gd' => 10])); };
$GLOBALS['gv_cw_time'] = [3, 8.0, 20000];
$o = $hook($post, 'day');
ok('beat 1 (the bottle post): the line begins', str_contains($o, 'A quest begins') && str_contains($o, '1 of 5'), $o);
// beat 2: Sorrel at the rack: too early says when, then at her appointment it counts
$base_t = [3, 8.0, 20000];
$step = function (int $nth, string $slug, string $who, string $dp) use (&$base_t, $hook) {
    $GLOBALS['gv_cw_time'] = $base_t;
    $f = npc_cw_forecast($who, $slug);
    ok("beat $nth: forecast for $who", (bool)$f, 'none'); if (!$f) return false;
    if (empty($f['now'])) { $o = $hook($slug, $dp); ok("beat $nth: $who is not there yet, it says when she/he is next and does not count (no penalty)", str_contains($o, $who . ' is not here now. Next: ') && !str_contains($o, ' of 5)'), $o); }
    $GLOBALS['gv_cw_time'] = [$f['dow'], $f['from'] + 0.2, $base_t[2] + $f['in']];
    $o = $hook($slug, $dp);
    ok("beat $nth at $slug: $who is there, it counts", str_contains($o, "($nth of 5)"), $o);
    $base_t = [$f['dow'], $f['to'] + 0.5, $base_t[2] + $f['in']];
    return true;
};
$step(2, $rack, 'Sorrel Dewdrop', 'dawn');
$GLOBALS['gv_cw_time'] = $base_t;
$o = $hook($kelp, 'day');
ok('beat 3 (kelp line) does not count by day (high water)', !str_contains($o, ' of 5)'), $o);
$o = $hook($kelp, 'dusk');
ok('beat 3: at dusk (low tide) the kelp lets go of the bottle', str_contains($o, '(3 of 5)'), $o);
$step(4, $gap, 'Alder Puddlefoot', 'dusk');
// finale: Keeper Loamwick, dawn shift only
$GLOBALS['gv_cw_time'] = [3, 8.0, $base_t[2]];
$o = $hook($light, 'day');
ok('finale by day: not his dawn shift, nothing counts (the beat waits for dawn)', !str_contains($o, 'is done') && !str_contains($o, '5 of 5'), $o);
$o = $hook($light, 'night');
ok('finale at night: still not (wrong shift for the bottle)', !str_contains($o, 'is done'), $o);
$o = $hook($light, 'dawn');
ok('finale at dawn: the keeper takes the bottle, the line is done', str_contains($o, 'The Message in the Bottle is done'), $o);
ok('the line is finished, paid once', (bool)q_val('SELECT done_at FROM user_sight_quests WHERE user_id = ? AND quest = ?', [$u['id'], 'message-in-the-bottle']));
ok('nothing more counts afterwards', $hook($light, 'dawn') === '');
unset($GLOBALS['gv_cw_time']);
echo $fails ? "$fails FAILED\n" : "ok\n";
exit($fails ? 1 : 0);
