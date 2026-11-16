<?php
// Haven family (2.7.01): guest book + bedtime round strip, Bedtime Rounds rows (tally tucked, moon, tide), "The Guest Book" line with Alder, Sorrel, Posy and Tilly by their weekly clockwork.
// php tests/trail_fam_haven.php GAME_DIR   (an installed game, player "sprout"; walk.sh installs one)
$_SERVER['SCRIPT_NAME'] = '/adventure.php';
require $argv[1] . '/includes/bootstrap.php';
require_once $argv[1] . '/includes/adventure.php';
require_once $argv[1] . '/includes/trail_tiles.php';
require_once $argv[1] . '/includes/trail_sights.php';
require_once $argv[1] . '/includes/stop_folk.php';
require_once $argv[1] . '/includes/npc_clockwork.php';
require_once $argv[1] . '/includes/moon.php';
require_once $argv[1] . '/includes/trail_fam_haven.php';
$fails = 0;
$GLOBALS['gv_sights_nocache'] = true;
set_exception_handler(function (Throwable $e) { echo '  EXCEPTION ' . get_class($e) . ': ' . $e->getMessage() . ' @ ' . basename($e->getFile()) . ':' . $e->getLine() . "\n"; exit(1); });
function ok(string $what, bool $cond, string $extra = ''): void { global $fails; echo ($cond ? '  ok   ' : '  FAIL ') . $what . ($cond ? '' : "  $extra") . "\n"; if (!$cond) $fails++; }
set_setting('npc_clockwork', '1');
foreach (q("SELECT * FROM locations WHERE kind = 'village' ORDER BY id")->fetchAll() as $v) stop_folk_ensure($v);
$all = trail_sights_all();
$u = q_one("SELECT * FROM users WHERE username = 'sprout'");
$mark = fn(string $slug, bool $used = false) => ['x' => 1, 'y' => 1, 'slug' => $slug, 'row' => $all[$slug], 'left' => $used ? 0 : $all[$slug]['uses'], 'why' => ''];
$ctx = fn(array $marks, float $hour = 12.0, int $di = 20000, array $tl = []) => ['u' => $u, 'now' => ['dp' => 'day', 'tl' => $tl], 'marks' => $marks, 'clock' => [3, $hour, $di]];
$h1g = 'end-haven-1-grassland'; $h1c = 'end-haven-1-coast'; $h2c = 'end-haven-2-coast'; $h1i = 'end-haven-1-island';

echo "== the layer\n";
$h = trail_fam_haven($ctx([$mark($h1g), $mark($h1c)]));
ok('renders for a haven section', str_contains($h, 'tfhaven') && str_contains($h, 'Guest book:') && str_contains($h, 'Bedtime round'), $h);
ok('names the villagers of the havens in the book and the round', str_contains($h, 'Tilly Puddlefoot') && str_contains($h, 'Alder Barleycorn') && substr_count($h, "tfh-bed ") === 3 && substr_count($h, "tfh-sig ") === 3, $h);
ok('the moon of the day is named', preg_match('/' . preg_quote(moon_phase(20000)['name'], '/') . '/', $h) === 1);
ok('not for a section with no haven Sight', trail_fam_haven($ctx([$mark('grassland-the-clover-patch')])) === '' && trail_fam_haven($ctx([])) === '' && trail_fam_haven($ctx([$mark('end-wonder-1-coast')])) === '');
ok('tucked tally shows', str_contains(trail_fam_haven($ctx([$mark($h1g)], 12.0, 20000, ['tucked' => 4])), 'Tucked in so far: 4'));

echo "== guest book\n";
q('DELETE FROM stop_friend WHERE user_id = ?', [$u['id']]);
$h = trail_fam_haven($ctx([$mark($h1g)]));
ok('blank when the villager is not known', str_contains($h, 'Guest book: 0 of') && str_contains($h, 'tfh-sig blank') && !str_contains($h, 'tfh-sig signed'), $h);
trail_sight_befriend($u, 'Tilly Puddlefoot', 1);
$h = trail_fam_haven($ctx([$mark($h1g)]));
ok('signed once the gnome knows them, in words', str_contains($h, 'Guest book: 1 of') && preg_match('/tfh-sig signed.*Tilly Puddlefoot.*signed/s', $h) === 1 && str_contains($h, 'blank line'), $h);

echo "== bedtime round and the moon\n";
$full = 14; $new = 0; $quarter = 7;
ok('test days are the phases I mean', moon_phase($full)['key'] === 'full' && moon_phase($new)['key'] === 'new' && moon_phase($quarter)['key'] === 'first-quarter');
$b = fn(int $d) => trail_fam_haven_bed('Tilly Puddlefoot', $d);
ok('bedtime is 8 to 10 pm, a full moon an hour later, a new moon an hour earlier', $b($full) === $b($quarter) + 1 && $b($new) === $b($quarter) - 1 && $b($quarter) >= 20 && $b($quarter) <= 22);
$bed = $b($quarter);
ok('state by hour: up, tuck in now the hour before, asleep from bed to 6 am', trail_fam_haven_state($bed, 10.0) === 'up' && trail_fam_haven_state($bed, $bed - 0.5) === 'tuck' && trail_fam_haven_state($bed, $bed) === 'asleep' && trail_fam_haven_state($bed, 3.0) === 'asleep');
$h = trail_fam_haven($ctx([$mark($h1g)], $bed - 0.5, $quarter));
ok('the card says tuck in now', str_contains($h, 'tuck in now') && str_contains($h, 'bed at ' . hour_label($bed)), $h);
ok('full and new moon say what they do', str_contains(trail_fam_haven($ctx([$mark($h1g)], 12.0, $full)), 'an hour late') && str_contains(trail_fam_haven($ctx([$mark($h1g)], 12.0, $new)), 'an hour early'));
$round = trail_fam_haven($ctx([$mark($h1g), $mark($h1c), $mark($h1i)]));
preg_match_all('/class="tfh-nm">([^<]+)<\/span> <span class="tfh-st">bed at/', $round, $ord);
$beds = array_map(fn($n) => trail_fam_haven_bed($n, 20000), $ord[1]);
$sorted = $beds; sort($sorted);
ok('the round is first to bed first (hours never go down)', count($ord[1]) === 4 && $beds === $sorted, json_encode([$ord[1], $beds]));
$css = file_get_contents($argv[1] . '/assets/style.css');
ok('css has the block and the dark theme', str_contains($css, '.tfhaven') && str_contains($css, ':root[data-theme="dark"] .tfhaven'));

echo "== Bedtime Rounds rows\n";
foreach ($all as $slug => $row) {
    if (!str_starts_with($slug, 'end-haven-')) continue;
    $tok = array_map(fn($t) => $t['tok'], trail_sight_tokens($row['rewards']));
    ok("$slug tucks in at dusk or night and pays from the third", in_array('tally=tucked', $tok, true) && (bool)preg_grep('/^c=5:1$/', $tok) && (bool)preg_grep('/^title=Night-Light Keeper$/', $tok), json_encode($tok));
    ok("$slug rows lint clean", !array_filter(trail_sight_lint($row), fn($p) => !str_starts_with($p, 'no landmark picture')), json_encode(trail_sight_lint($row)));
}
$tk = trail_sight_tokens($all[$h2c]['rewards']);
ok('the coast havens give sea glass at low tide', (bool)array_filter($tk, fn($t) => str_starts_with($t['tok'], 'item=sea-glass')), json_encode(array_column($tk, 'tok')));
// play a haven row at night and by day on a route tile: the tally only counts at dusk or night
$base = $all['grassland-the-clover-patch'];
set_setting('gnav_on', '1'); set_setting('gnav_tiles', '1'); set_setting('game_clock_on', '1'); set_setting('stop_daypart_force', 'night'); setting('__reload__');
q("UPDATE expeditions SET status = 'done' WHERE user_id = ?", [$u['id']]);
q("UPDATE routes SET kind = 'road' WHERE id = 240");
$r = q_one('SELECT * FROM routes WHERE id = 240');
q("UPDATE users SET location_id = ?, level = 1, energy = 90, coins = 500, ev_quickwalk = 0, game_day = 10, game_minute = 1380 WHERE id = ?", [$r['a_id'], $u['id']]);
q('DELETE FROM trail_sight_uses WHERE user_id = ?', [$u['id']]); q('DELETE FROM trail_sight_tally WHERE user_id = ?', [$u['id']]);
$u = q_one('SELECT * FROM users WHERE id = ?', [$u['id']]);
[$sok] = start_expedition($u, 240); ok('the walk starts', $sok);
$exp = active_expedition((int)$u['id']); $sc = trail_scene($exp);
$lm = array_values(array_filter($sc['map']['art']['objs'], fn($o) => $o[2] === 'lm-grassland-the-clover-patch'));
$spot = null; foreach ([[-1, 0], [1, 0], [0, -1], [0, 1], [0, 0]] as [$dx, $dy]) if (in_array(tm_tile($sc['map'], $lm[0][0] + $dx, $lm[0][1] + $dy), ['.', ',', 'S'], true)) { $spot = [$lm[0][0] + $dx, $lm[0][1] + $dy]; break; }
$sc['x'] = $spot[0]; $sc['y'] = $spot[1]; trail_save($sc);
trail_sights_ensure_tables();
q('DELETE FROM trail_sight_rows WHERE slug = ?', [$base['slug']]);
db_insert('trail_sight_rows', ['slug' => $base['slug'], 'verb' => $base['verb'], 'icon' => $base['icon'], 'energy' => 0, 'cd' => 55, 'uses' => 9, 'cond' => '-', 'chk' => '-', 'rewards' => $all[$h2c]['rewards'], 'win' => 'x', 'lose' => '', 'tool' => '-', 'fail_en' => 0, 'active' => 1]);
$GLOBALS['gv_sights_reload'] = true; trail_sights_all();
$gain = [];
for ($i = 1; $i <= 4; $i++) {
    q('UPDATE users SET game_minute = 1380 WHERE id = ?', [$u['id']]);
    $u = q_one('SELECT * FROM users WHERE id = ?', [$u['id']]); $exp = active_expedition((int)$u['id']); $GLOBALS['gv_sights_reload'] = true;
    $c0 = (int)q_val('SELECT coins FROM users WHERE id = ?', [$u['id']]);
    [$a] = trail_sight_do($u, $exp, $base['slug']); save_exp($exp);
    ok("use $i works", $a);
    $gain[$i] = (int)q_val('SELECT coins FROM users WHERE id = ?', [$u['id']]) - $c0;
}
ok('each night use tucks one in', (trail_sight_tallies((int)$u['id'])['tucked'] ?? 0) === 4, json_encode(trail_sight_tallies((int)$u['id'])));
ok('coins pay from the third tuck-in, not before', $gain[1] === 0 && $gain[2] === 0 && $gain[3] >= 5 && $gain[4] >= 5, json_encode($gain));
set_setting('stop_daypart_force', 'day'); setting('__reload__');
$t0 = trail_sight_tallies((int)$u['id'])['tucked'] ?? 0;
q('UPDATE users SET game_minute = 720 WHERE id = ?', [$u['id']]); $u = q_one('SELECT * FROM users WHERE id = ?', [$u['id']]); $exp = active_expedition((int)$u['id']); $GLOBALS['gv_sights_reload'] = true;
trail_sight_do($u, $exp, $base['slug']); save_exp($exp);
ok('by day nobody is tucked in: the tally stays', (trail_sight_tallies((int)$u['id'])['tucked'] ?? 0) === $t0);
set_setting('stop_daypart_force', ''); setting('__reload__');

echo "== The Guest Book\n";
$who = ['Alder Barleycorn', 'Sorrel Acorncap', 'Posy Oakenpot', 'Tilly Puddlefoot'];
$qs = trail_sight_quests()['haven-guestbook'] ?? null;
ok('the line exists: 5 beats, 4 with npc=, gated on Rest Here, Repainted', $qs && count($qs['beats']) === 5 && count(array_filter($qs['beats'], fn($b) => str_starts_with($b[3], 'npc='))) === 4 && $qs['gate'] === 'quest:rest-here-repainted', json_encode($qs['gate'] ?? null));
ok('Tobias is not an npc= beat', !array_filter($qs['beats'], fn($b) => $b[3] === 'npc=Tobias Trundle'));
foreach ($who as $w) ok("$w is a free villager, not a mentor", !in_array($w, npc_cw_fixed_names(), true) && npc_cw_profile(npc_cw_who_key($w))['mode'] === 'free');
foreach ([[20000, 0], [20003, 2], [20009, 5], [20015, 6]] as [$di, $dow]) {
    $GLOBALS['gv_cw_time'] = [$dow, 8.0, $di];
    foreach ($qs['beats'] as $b) if (str_starts_with($b[3], 'npc=')) { $fc = npc_cw_forecast(substr($b[3], 4), $b[0]); ok(substr($b[3], 4) . " has a window at {$b[0]} from day $di", $fc && $fc['to'] > $fc['from'], json_encode($fc)); }
}
$u = q_one('SELECT * FROM users WHERE id = ?', [$u['id']]);
q('DELETE FROM user_sight_quests WHERE user_id = ?', [$u['id']]);
$loc = q_one('SELECT * FROM locations WHERE id = ?', [(int)$r['a_id']]);
$dpnow = ['dawn' => ['dp' => 'dawn', 'tl' => []], 'dusk' => ['dp' => 'dusk', 'tl' => []], 'night' => ['dp' => 'night', 'tl' => []], 'day' => ['dp' => 'day', 'tl' => []]];
$hook = function (string $slug, string $dp) use (&$u, $loc, $dpnow) { $u = q_one('SELECT * FROM users WHERE id = ?', [$u['id']]); return implode(' | ', trail_sight_quest_hook($u, $slug, $loc, $dpnow[$dp])); };
$GLOBALS['gv_cw_time'] = [3, 8.0, 20000];
ok('before Rest Here, Repainted is done the line does not begin', $hook('end-haven-2-grassland', 'day') !== '' ? !str_contains($hook('end-haven-2-grassland', 'day'), 'The Guest Book') : true);
db_insert('user_sight_quests', ['user_id' => $u['id'], 'quest' => 'rest-here-repainted', 'beats' => '[0,1,2,3]', 'started_at' => now(), 'done_at' => now()]);
$o = $hook('end-haven-2-grassland', 'day');
ok('beat 1 (no villager): the line begins', str_contains($o, 'A quest begins') && str_contains($o, '1 of 5'), $o);
$beats = [['end-haven-1-coast', 'dawn', 'Alder Barleycorn'], ['end-haven-2-coast', 'dawn', 'Sorrel Acorncap'], ['end-haven-1-island', 'night', 'Posy Oakenpot'], ['end-haven-1-grassland', 'dusk', 'Tilly Puddlefoot']];
$base_t = [3, 8.0, 20000]; $nth = 1;
foreach ($beats as [$slug, $dp, $nm]) {
    $nth++;
    $GLOBALS['gv_cw_time'] = $base_t;
    $f = npc_cw_forecast($nm, $slug);
    ok("beat $nth: forecast for $nm", (bool)$f, 'none');
    if (!$f) break;
    if (empty($f['now'])) {
        $o = $hook($slug, $dp);
        ok("beat $nth: $nm is not there yet, it says when they are next and does not count", str_contains($o, "$nm is not here now. Next: ") && !str_contains($o, ' of 5)'), $o);
    }
    $GLOBALS['gv_cw_time'] = [$f['dow'], $f['from'] + 0.2, $base_t[2] + $f['in']];
    $o = $hook($slug, $dp);
    ok("beat $nth at $slug: $nm is there, it counts", str_contains($o, "($nth of 5)") || ($nth === 5 && str_contains($o, 'is done')), $o);
    $base_t = [$f['dow'], $f['to'] + 0.5, $base_t[2] + $f['in']];
}
ok('the line is finished, paid once', (bool)q_val('SELECT done_at FROM user_sight_quests WHERE user_id = ? AND quest = ?', [$u['id'], 'haven-guestbook']));
$GLOBALS['gv_cw_time'] = $base_t;
ok('nothing more counts afterwards', $hook('end-haven-1-grassland', 'dusk') === '');
unset($GLOBALS['gv_cw_time']);
echo $fails ? "$fails FAILED\n" : "ok\n";
exit($fails ? 1 : 0);
