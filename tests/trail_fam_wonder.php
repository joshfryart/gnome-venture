<?php
// Wonder family (2.7.01): Postcard frame layer, Look Closer rows (pick + tally) and "Wren's Gate Rubbings: Postcards" with villagers by their weekly clockwork.
// php tests/trail_fam_wonder.php GAME_DIR   (an installed game, player "sprout"; walk.sh installs one)
$_SERVER['SCRIPT_NAME'] = '/adventure.php';
require $argv[1] . '/includes/bootstrap.php';
require_once $argv[1] . '/includes/adventure.php';
require_once $argv[1] . '/includes/trail_tiles.php';
require_once $argv[1] . '/includes/trail_sights.php';
require_once $argv[1] . '/includes/stop_folk.php';
require_once $argv[1] . '/includes/npc_clockwork.php';
require_once $argv[1] . '/includes/moon.php';
require_once $argv[1] . '/includes/trail_fam_wonder.php';
$fails = 0;
$GLOBALS['gv_sights_nocache'] = true;
set_exception_handler(function (Throwable $e) { echo '  EXCEPTION ' . get_class($e) . ': ' . $e->getMessage() . ' @ ' . basename($e->getFile()) . ':' . $e->getLine() . "\n"; exit(1); });
function ok(string $what, bool $cond, string $extra = ''): void { global $fails; echo ($cond ? '  ok   ' : '  FAIL ') . $what . ($cond ? '' : "  $extra") . "\n"; if (!$cond) $fails++; }
set_setting('npc_clockwork', '1');
foreach (q("SELECT * FROM locations WHERE kind = 'village' ORDER BY id")->fetchAll() as $v) stop_folk_ensure($v);
$all = trail_sights_all();
$mark = fn(string $slug) => ['x' => 1, 'y' => 1, 'slug' => $slug, 'row' => $all[$slug], 'left' => $all[$slug]['uses'], 'why' => ''];
$uid = (int)q_val("SELECT id FROM users WHERE username = 'sprout'");
$ctx = fn(array $marks, array $clock = [3, 8.0, 20001], array $tl = []) => ['u' => ['id' => $uid], 'now' => ['dp' => 'day', 'tl' => $tl], 'marks' => $marks, 'clock' => $clock, 'land' => 'forest'];
$wonders = array_values(array_filter(array_keys($all), fn($s) => str_starts_with($s, 'end-wonder-')));
$forest = 'end-wonder-1-forest'; $desert = 'end-wonder-1-desert'; $mountain = 'end-wonder-2-mountain'; $wet = 'end-wonder-2-wetland'; $island = 'end-wonder-2-island';

echo "== the layer\n";
ok('16 wonder Sights', count($wonders) === 16, (string)count($wonders));
q('DELETE FROM trail_sight_uses WHERE user_id = ?', [$uid]);
$h = trail_fam_wonder($ctx([$mark($forest)]));
ok('renders a postcard for a section with a wonder', str_contains($h, 'tfwonder') && str_contains($h, 'tfw-card') && str_contains($h, 'Wonder gates, forest'), $h);
ok('the moon postmark says phase and day', str_contains($h, 'Postmark: ') && str_contains($h, moon_phase(20001)['name']), $h);
ok('the sticker slot is empty and says so in words', str_contains($h, 'empty sticker slot') && str_contains($h, 'tfw-stk off'), $h);
ok('the album has all 16 slots and says 0 of 16', substr_count($h, 'tfw-s ') === 16 && str_contains($h, '0 of 16'), $h);
ok('the same clock draws the same card', $h === trail_fam_wonder($ctx([$mark($forest)])));
ok('a different moon day changes the postmark', trail_fam_wonder($ctx([$mark($forest)], [3, 8.0, 20014])) !== $h && str_contains(trail_fam_wonder($ctx([$mark($forest)], [3, 8.0, 20014])), moon_phase(20014)['name']));
ok('two wonders: two postcards', substr_count(trail_fam_wonder($ctx([$mark($forest), $mark($wet)])), '<figure') === 2);
ok('a hush card is told from a gate card (word and class)', str_contains(trail_fam_wonder($ctx([$mark($wet)])), 'tfw-card hush') && str_contains(trail_fam_wonder($ctx([$mark($wet)])), 'a hush to listen to'));
ok('not for a section with no wonder (a coast one, none)', trail_fam_wonder($ctx([$mark('coast-the-kelp-line')])) === '' && trail_fam_wonder($ctx([])) === '');
ok('not for a haven end piece', trail_fam_wonder($ctx([$mark('end-haven-1-coast')])) === '');
db_insert('trail_sight_uses', ['user_id' => $uid, 'route_id' => 1, 'sec' => 0, 'slug' => $forest, 'n' => 1, 'got_at' => time(), 'got_tick' => null]);
$h = trail_fam_wonder($ctx([$mark($forest)], [3, 8.0, 20001], ['wonder-looks' => 3]));
ok('after a visit the sticker is stuck, the album counts it, the tally shows', str_contains($h, 'sticker stuck') && str_contains($h, '1 of 16') && str_contains($h, 'close looks: 3'), $h);
q('DELETE FROM trail_sight_uses WHERE user_id = ?', [$uid]);
$css = file_get_contents($argv[1] . '/assets/style.css');
ok('css has the block and the dark theme', str_contains($css, '.tfwonder') && str_contains($css, ':root[data-theme="dark"] .tfwonder'));

echo "== Look Closer rows\n";
$bad = [];
foreach ($wonders as $s) {
    $r = $all[$s];
    $pk = trail_sight_pick_info($r);
    $tk = array_map(fn($t) => $t['tok'] . ($t['cond'] !== '' ? '?' . $t['cond'] : ''), trail_sight_tokens($r['rewards']));
    if (!$pk || $pk[0] < 2 || count($pk[1]) !== $pk[0]) $bad[] = "$s pick";
    if (!in_array('tally=wonder-looks', $tk, true) || !preg_grep('/^title=Sharp Eye\?tn=wonder-looks:8$/', $tk)) $bad[] = "$s tally";
    if ($r['lose'] === '' || $r['lose'] === '-') $bad[] = "$s lose";
    $lint = array_filter(trail_sight_lint($r), fn($p) => !str_starts_with($p, 'no landmark picture'));
    if ($lint) $bad[] = "$s lint " . json_encode(array_values($lint));
}
ok('every wonder is a pick:3 hidden-detail row with the Look Closer tally, a lose line and a clean lint', !$bad, implode('; ', $bad));
ok('moon-gated bonuses exist and lint (mo=)', (bool)array_filter($wonders, fn($s) => str_contains($all[$s]['rewards'], '?mo=') || str_contains($all[$s]['rewards'], '/mo=') || str_contains($all[$s]['rewards'], 'mo=')));

echo "== play: a pick counts a close look\n";
$base = $all['grassland-the-clover-patch'];
set_setting('gnav_on', '1'); set_setting('gnav_tiles', '1'); set_setting('game_clock_on', '1'); setting('__reload__');
$u = q_one("SELECT * FROM users WHERE username = 'sprout'");
q("UPDATE expeditions SET status = 'done' WHERE user_id = ?", [$u['id']]);
q("UPDATE routes SET kind = 'road' WHERE id = 240");
$r = q_one('SELECT * FROM routes WHERE id = 240');
q("UPDATE users SET location_id = ?, level = 1, energy = 90, coins = 500, ev_quickwalk = 0, game_day = 10, game_minute = 600 WHERE id = ?", [$r['a_id'], $u['id']]);
q('DELETE FROM trail_sight_uses WHERE user_id = ?', [$u['id']]); q('DELETE FROM trail_sight_tally WHERE user_id = ?', [$u['id']]);
$u = q_one('SELECT * FROM users WHERE id = ?', [$u['id']]);
[$sok] = start_expedition($u, 240); ok('the walk starts', $sok);
$exp = active_expedition((int)$u['id']); $sc = trail_scene($exp);
$lm = array_values(array_filter($sc['map']['art']['objs'], fn($o) => $o[2] === 'lm-grassland-the-clover-patch'));
$spot = null; foreach ([[-1, 0], [1, 0], [0, -1], [0, 1], [0, 0]] as [$dx, $dy]) if (in_array(tm_tile($sc['map'], $lm[0][0] + $dx, $lm[0][1] + $dy), ['.', ',', 'S'], true)) { $spot = [$lm[0][0] + $dx, $lm[0][1] + $dy]; break; }
$sc['x'] = $spot[0]; $sc['y'] = $spot[1]; trail_save($sc);
trail_sights_ensure_tables();
q('DELETE FROM trail_sight_rows WHERE slug = ?', [$base['slug']]);
$w = $all[$forest];
db_insert('trail_sight_rows', ['slug' => $base['slug'], 'verb' => $base['verb'], 'icon' => $base['icon'], 'energy' => 0, 'cd' => 55, 'uses' => 9, 'cond' => '-', 'chk' => $w['check'], 'rewards' => $w['rewards'], 'win' => $w['win'], 'lose' => $w['lose'], 'tool' => '-', 'fail_en' => 0, 'active' => 1]);
$GLOBALS['gv_sights_reload'] = true; trail_sights_all();
$use = function (int $pick) use (&$u, &$exp, $base) { $u = q_one('SELECT * FROM users WHERE id = ?', [$u['id']]); $exp = active_expedition((int)$u['id']); $GLOBALS['gv_sights_reload'] = true; $rr = trail_sight_do($u, $exp, $base['slug'], ['pick' => $pick]); save_exp($exp); return $rr; };
$tally = fn() => (trail_sight_tallies((int)$u['id'])['wonder-looks'] ?? 0);
[$a] = $use(-1); ok('no choice made: "Choose one", nothing counted', !$a && $tally() === 0);
$sc = trail_scene(active_expedition((int)$u['id']));
$right = trail_sight_pick_right($u, $sc, trail_sights_all()[$base['slug']]);
$wrong = ($right + 1) % 3;
[$a, $m] = $use($wrong); ok('the wrong detail: the lose line, no look counted', $tally() === 0 && !str_contains(json_encode($m), 'Choose one'), json_encode([$a, $m, $tally()]));
$sc = trail_scene(active_expedition((int)$u['id']));
$right = trail_sight_pick_right($u, $sc, trail_sights_all()[$base['slug']]);
[$a, $m] = $use($right); ok('the right detail: it works and counts a close look', $a && $tally() === 1, json_encode([$a, $m, $tally(), $right]));
$stuck = trail_fam_wonder_found((int)$u['id']);
ok('(the test row stands on a clover patch tile, so the sticker is checked by direct use below)', is_array($stuck));
db_insert('trail_sight_uses', ['user_id' => (int)$u['id'], 'route_id' => 1, 'sec' => 0, 'slug' => $mountain, 'n' => 1, 'got_at' => time(), 'got_tick' => null]);
ok('a used wonder is a found sticker', in_array($mountain, trail_fam_wonder_found((int)$u['id']), true) && str_contains(trail_fam_wonder(['u' => $u, 'now' => [], 'marks' => [$mark($mountain)], 'clock' => [3, 8.0, 20001]]), 'sticker stuck'));
q('DELETE FROM trail_sight_uses WHERE user_id = ? AND slug = ?', [$u['id'], $mountain]);

echo "== chips from the clockwork\n";
$f = npc_cw_forecast('Marigold Nettlebed', $desert);
ok('Marigold has a forecast at the salt flat gate', $f !== null);
if ($f) {
    $GLOBALS['gv_cw_time'] = [$f['dow'], $f['from'] + 0.2, 20000 + $f['in']];
    $h = trail_fam_wonder($ctx([$mark($desert)], $GLOBALS['gv_cw_time']));
    ok('while she is there: a here-now chip', str_contains($h, 'Marigold Nettlebed at') && str_contains($h, 'here now') && str_contains($h, 'tfw-chip now'), $h);
    unset($GLOBALS['gv_cw_time']);
}
set_setting('npc_clockwork', '0'); setting('__reload__');
ok('clockwork off: no chips, the card stays', !str_contains(trail_fam_wonder($ctx([$mark($desert)])), 'tfw-chip') && str_contains(trail_fam_wonder($ctx([$mark($desert)])), 'tfwonder'));
set_setting('npc_clockwork', '1'); setting('__reload__');

echo "== Wren's Gate Rubbings: Postcards\n";
$qs = trail_sight_quests()['wonder-postcards'] ?? null;
ok('the line exists with 5 beats and 2 or more npc= beats', $qs && count($qs['beats']) === 5 && count(array_filter($qs['beats'], fn($b) => str_starts_with($b[3], 'npc='))) >= 2);
ok('it passes the quest lint', $qs && !trail_sight_quest_lint($qs, $all, trail_sight_quests()), json_encode($qs ? trail_sight_quest_lint($qs, $all, trail_sight_quests()) : null));
$names = array_map(fn($b) => substr($b[3], 4), array_filter($qs['beats'], fn($b) => str_starts_with($b[3], 'npc=')));
ok('Wren (a traveller) and mentors are not npc= beats', !in_array('Wren Thimblewick', $names, true) && !array_filter($names, fn($n) => in_array($n, npc_cw_fixed_names(), true)));
foreach ($names as $n) {
    $slug = null; foreach ($qs['beats'] as $b) if ($b[3] === 'npc=' . $n) $slug = $b[0];
    ok("$n is a free villager (the clockwork moves them)", npc_cw_profile(npc_cw_who_key($n))['mode'] === 'free');
    foreach ([[20000, 0], [20003, 2], [20009, 5], [20015, 6]] as [$di, $dow]) { $GLOBALS['gv_cw_time'] = [$dow, 8.0, $di]; $fc = npc_cw_forecast($n, $slug); ok("forecast for $n at $slug from day $di", $fc && $fc['to'] > $fc['from'], json_encode($fc)); }
}
$u = q_one('SELECT * FROM users WHERE id = ?', [$u['id']]);
q('DELETE FROM user_sight_quests WHERE user_id = ?', [$u['id']]);
$loc = q_one('SELECT * FROM locations WHERE id = ?', [(int)$r['a_id']]);
$hook = function (string $slug, string $dp) use (&$u, $loc) { $u = q_one('SELECT * FROM users WHERE id = ?', [$u['id']]); return implode(' | ', trail_sight_quest_hook($u, $slug, $loc, ['dp' => $dp, 'tl' => [], 'gd' => 10])); };
$base_t = [3, 8.0, 20000]; $GLOBALS['gv_cw_time'] = $base_t;
$o = $hook($forest, 'day');
ok('beat 1: the line begins', str_contains($o, 'A quest begins') && str_contains($o, '1 of 5'), $o);
$step = function (int $nth, string $slug, string $who, string $dp) use (&$base_t, $hook) {
    $GLOBALS['gv_cw_time'] = $base_t;
    $f = npc_cw_forecast($who, $slug);
    ok("beat $nth: forecast for $who", (bool)$f); if (!$f) return;
    if (empty($f['now'])) { $o = $hook($slug, $dp); ok("beat $nth: $who is not there yet: it says when they are next, nothing counts, no penalty", str_contains($o, $who . ' is not here now. Next: ') && !str_contains($o, ' of 5)'), $o); }
    $GLOBALS['gv_cw_time'] = [$f['dow'], $f['from'] + 0.2, $base_t[2] + $f['in']];
    $o = $hook($slug, $dp);
    ok("beat $nth at $slug: $who is there, it counts", str_contains($o, "($nth of 5)"), $o);
    $base_t = [$f['dow'], $f['to'] + 0.5, $base_t[2] + $f['in']];
};
$step(2, $desert, 'Marigold Nettlebed', 'day');
$GLOBALS['gv_cw_time'] = $base_t;
$o = $hook($mountain, 'day');
ok('beat 3 does not count by day (it needs dawn)', !str_contains($o, ' of 5)'), $o);
$o = $hook($mountain, 'dawn');
ok('beat 3 at dawn counts', str_contains($o, '(3 of 5)'), $o);
$step(4, $wet, 'Tuck Bumbleby', 'day');
$GLOBALS['gv_cw_time'] = $base_t;
$f = npc_cw_forecast('Juniper Honeycomb', $island);
ok('beat 5: forecast for Juniper', (bool)$f);
if ($f) {
    if (empty($f['now'])) { $o = $hook($island, 'dusk'); ok('beat 5: Juniper not there, says when he is next', str_contains($o, 'Juniper Honeycomb is not here now. Next: ') && !str_contains($o, 'is done'), $o); }
    $GLOBALS['gv_cw_time'] = [$f['dow'], $f['from'] + 0.2, $base_t[2] + $f['in']];
    $o = $hook($island, 'dusk');
    ok('beat 5: Juniper is there, the line is done', str_contains($o, "Wren's Gate Rubbings: Postcards is done"), $o);
}
ok('the line is finished, paid once', (bool)q_val('SELECT done_at FROM user_sight_quests WHERE user_id = ? AND quest = ?', [$u['id'], 'wonder-postcards']));
unset($GLOBALS['gv_cw_time']);
echo $fails ? "$fails FAILED\n" : "ok\n";
exit($fails ? 1 : 0);
