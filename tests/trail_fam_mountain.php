<?php
// Mountain family (2.7.01): the Echo Chain strip, the echo wall pick: rhythm row and "The Goat Ledge Census" with Hazel Dewdrop by her weekly clockwork.
// php tests/trail_fam_mountain.php GAME_DIR   (an installed game, player "sprout"; walk.sh installs one)
$_SERVER['SCRIPT_NAME'] = '/adventure.php';
require $argv[1] . '/includes/bootstrap.php';
require_once $argv[1] . '/includes/adventure.php';
require_once $argv[1] . '/includes/trail_tiles.php';
require_once $argv[1] . '/includes/trail_sights.php';
require_once $argv[1] . '/includes/stop_folk.php';
require_once $argv[1] . '/includes/npc_clockwork.php';
require_once $argv[1] . '/includes/moon.php';
require_once $argv[1] . '/includes/trail_fam_mountain.php';
$fails = 0;
set_setting('sights_walk_cap', '0');   // 2.7.08: this test uses many Sights on one walk (the cap: tests/trail_sights_278.php)
$GLOBALS['gv_sights_nocache'] = true;
set_exception_handler(function (Throwable $e) { echo '  EXCEPTION ' . get_class($e) . ': ' . $e->getMessage() . ' @ ' . basename($e->getFile()) . ':' . $e->getLine() . "\n"; exit(1); });
function ok(string $what, bool $cond, string $extra = ''): void { global $fails; echo ($cond ? '  ok   ' : '  FAIL ') . $what . ($cond ? '' : "  $extra") . "\n"; if (!$cond) $fails++; }
set_setting('npc_clockwork', '1');
foreach (q("SELECT * FROM locations WHERE kind = 'village' ORDER BY id")->fetchAll() as $v) stop_folk_ensure($v);
$all = trail_sights_all();
$mark = fn(string $slug, int $x = 1, int $y = 1) => ['x' => $x, 'y' => $y, 'slug' => $slug, 'row' => $all[$slug], 'left' => $all[$slug]['uses'], 'why' => ''];
$ctx = fn(array $marks, array $clock = [3, 8.0, 20000], array $now = []) => ['now' => $now + ['dp' => 'day', 'tl' => []], 'marks' => $marks, 'clock' => $clock, 'land' => 'mountain'];
$wall = 'mountain-the-echo-wall'; $goat = 'mountain-the-goat-ledge'; $pine = 'mountain-the-pine-shelf'; $eagle = 'mountain-the-eagle-s-rest'; $scree = 'mountain-the-scree-slope'; $notch = 'mountain-the-wind-notch';

echo "== the layer\n";
$h = trail_fam_mountain($ctx([$mark($wall, 2, 2), $mark($goat, 5, 2), $mark($eagle, 14, 2)]));
ok('renders for a section with mountain Sights', str_contains($h, 'tfmountain') && str_contains($h, 'Echo chain'), $h);
ok('the rings are an inline SVG with a text alternative', str_contains($h, '<svg class="tfm-svg"') && str_contains($h, 'role="img"') && str_contains($h, 'aria-label="Echo rings:') && str_contains($h, 'tfm-ring'), $h);
$rep = trail_fam_mountain_replies([$mark($wall, 2, 2), $mark($goat, 5, 2), $mark($eagle, 14, 2)]);
ok('the farther Sight answers later', count($rep) === 2 && $rep[0]['slug'] === $goat && $rep[1]['beats'] > $rep[0]['beats'], json_encode($rep));
ok('the delays are said in words', str_contains($h, 'after 1 beat') && str_contains($h, ' beats'), $h);
ok('the moon is shown', str_contains($h, moon_phase(20000)['name']), $h);
ok('same input, same strip', $h === trail_fam_mountain($ctx([$mark($wall, 2, 2), $mark($goat, 5, 2), $mark($eagle, 14, 2)])));
ok('altitude rises with more Sights', trail_fam_mountain_altitude(1, [])['lvl'] === 0 && trail_fam_mountain_altitude(7, [])['lvl'] === 3);
ok('mist at dawn and in fog, said in words', trail_fam_mountain_altitude(2, ['dp' => 'dawn'])['mist'] && str_contains(trail_fam_mountain_altitude(2, ['we' => 'fog'])['text'], 'misty') && !trail_fam_mountain_altitude(2, ['dp' => 'day'])['mist']);
ok('a wall-less stretch has no rings text but still the strip', ($x = trail_fam_mountain($ctx([$mark($goat)]))) !== '' && !str_contains($x, 'Echo wall:'));
$full = 20000 - (20000 % 28) + 14; $new = 20000 - (20000 % 28);
$note = fn(int $di) => preg_match('#<p class="tfm-note">(.*?)</p>#', trail_fam_mountain($ctx([$mark($wall)], [3, 8.0, $di])), $m) ? $m[1] : '';   // 2.7.08: the moon pill always explains the rule; the promise is in the echo-wall note
ok('full or new moon: the note promises a second pebble; a quarter does not', str_contains($note($full), 'second pebble') && str_contains($note($new), 'second pebble') && $note($new + 7) !== '' && !str_contains($note($new + 7), 'second pebble'), $note($full) . ' / ' . $note($new + 7));
ok('the tally shows', str_contains(trail_fam_mountain($ctx([$mark($wall)], [3, 8.0, 20000], ['tl' => ['echo-cheeks' => 2]])), 'Cheeky echoes: 2'));
ok('not for other lands or an empty section', trail_fam_mountain($ctx([$mark('coast-the-kelp-line')])) === '' && trail_fam_mountain($ctx([])) === '' && trail_fam_mountain($ctx([$mark('grassland-the-clover-patch')])) === '');
ok('a mountain mark among Maplewold ones still draws it', str_contains(trail_fam_mountain($ctx([['x' => 1, 'y' => 1, 'slug' => '12-the-old-well', 'row' => $all[$wall], 'left' => 1, 'why' => ''], $mark($goat)])), 'tfmountain'));
$css = file_get_contents($argv[1] . '/assets/style.css');
ok('css has the block and the dark theme', str_contains($css, '.tfmountain') && str_contains($css, ':root[data-theme="dark"] .tfmountain'));

echo "== appointment chip\n";
$f = npc_cw_forecast('Hazel Dewdrop', $pine, 'dp=dawn');   // 2.7.06: the forecast honours the folk row's when (dp=dawn), as the layer's chip does
ok('Hazel has a forecast at the pine shelf', $f !== null);
if ($f) {
    $GLOBALS['gv_cw_time'] = [$f['dow'], $f['from'] + 0.2, 20000 + $f['in']];
    $h = trail_fam_mountain($ctx([$mark($pine)], $GLOBALS['gv_cw_time'], ['dp' => 'dawn']));
    ok('while she is there: a "here now" chip', str_contains($h, 'Hazel Dewdrop at ') && str_contains($h, 'here now') && str_contains($h, 'tfm-chip now'), $h);
    $GLOBALS['gv_cw_time'] = [$f['dow'], $f['to'] + 0.5, 20000 + $f['in']];
    $h = trail_fam_mountain($ctx([$mark($pine)], $GLOBALS['gv_cw_time']));
    ok('after she has gone: the chip says when she is next', str_contains($h, 'Hazel Dewdrop') && !str_contains($h, 'here now'), $h);
    unset($GLOBALS['gv_cw_time']);
}
set_setting('npc_clockwork', '0'); setting('__reload__');
ok('clockwork off: no chips, the strip stays', !str_contains(trail_fam_mountain($ctx([$mark($pine)])), 'tfm-chip') && str_contains(trail_fam_mountain($ctx([$mark($pine)])), 'tfmountain'));
set_setting('npc_clockwork', '1'); setting('__reload__');

echo "== echo wall row\n";
$tokens = fn(string $s) => array_map(fn($t) => $t['tok'] . ($t['cond'] !== '' ? '?' . $t['cond'] : ''), trail_sight_tokens($all[$s]['rewards']));
ok('the echo wall is a pick: rhythm check with three rhythms and a lose line', str_starts_with($all[$wall]['check'], 'pick:3:') && substr_count($all[$wall]['check'], ';') === 2 && $all[$wall]['lose'] !== '');
ok('it counts the cheeky echo and pays a second pebble at new or full moon', in_array('tally=echo-cheeks', $tokens($wall), true) && in_array('item=echo-pebble:1@30?mo=full', $tokens($wall), true) && in_array('item=echo-pebble:1@30?mo=new', $tokens($wall), true), json_encode($tokens($wall)));
ok('the moon condition holds at full and new, not at a quarter', trail_sight_cond_ok('mo=full', ['mo' => 'full']) && trail_sight_cond_ok('mo=new', ['mo' => 'new']) && !trail_sight_cond_ok('mo=full', ['mo' => 'last-quarter']));
$lint = array_filter(trail_sight_lint($all[$wall]), fn($p) => !str_starts_with($p, 'no landmark picture'));
ok('the echo wall lints clean', !$lint, json_encode(array_values($lint)));
$fk = trail_sight_folk();
ok('Hazel has dawn rows at the goat ledge and the pine shelf', (bool)array_filter($fk[$goat] ?? [], fn($r) => str_starts_with($r['who'], 'Hazel Dewdrop') && $r['when'] === 'dp=dawn') && (bool)array_filter($fk[$pine] ?? [], fn($r) => str_starts_with($r['who'], 'Hazel Dewdrop') && $r['when'] === 'dp=dawn'));

echo "== play: the echo wall pick\n";
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
db_insert('trail_sight_rows', ['slug' => $base['slug'], 'verb' => $base['verb'], 'icon' => $base['icon'], 'energy' => 0, 'cd' => 0, 'uses' => 99, 'cond' => '-', 'chk' => $all[$wall]['check'], 'rewards' => $all[$wall]['rewards'], 'win' => 'x', 'lose' => 'y', 'tool' => '-', 'fail_en' => 0, 'active' => 1]);
$GLOBALS['gv_sights_reload'] = true; trail_sights_all();
$tally = fn() => (trail_sight_tallies((int)$u['id'])['echo-cheeks'] ?? 0);
$wins = 0; $losses = 0;
for ($i = 0; $i < 8; $i++) {
    $u = q_one('SELECT * FROM users WHERE id = ?', [$u['id']]); $exp = active_expedition((int)$u['id']); $GLOBALS['gv_sights_reload'] = true;
    $row = trail_sights_all()[$base['slug']];
    $right = trail_sight_pick_right($u, trail_scene($exp), $row);
    $before = $tally();
    $pickN = $i % 2 === 0 ? $right : ($right + 1) % 3;
    $a = trail_sight_do($u, $exp, $base['slug'], ['pick' => $pickN]); save_exp($exp);
    $after = $tally();
    if ($i % 2 === 0) { $wins += $after === $before + 1 ? 1 : 0; } else { $losses += $after === $before ? 1 : 0; }
}
ok('the right rhythm counts a cheeky echo (4 of 4)', $wins === 4, (string)$wins);
ok('a wrong rhythm counts nothing (4 of 4)', $losses === 4, (string)$losses);
unset($GLOBALS['gv_cw_time']);

echo "== The Goat Ledge Census\n";
$qs = trail_sight_quests()['goat-ledge-census'] ?? null;
ok('the line exists with 5 beats and at least 2 npc= beats', $qs && count($qs['beats']) === 5 && count(array_filter($qs['beats'], fn($b) => str_starts_with($b[3], 'npc='))) >= 2);
ok('three ledge counts of the one goat', $qs && $qs['beats'][0][0] === $goat && $qs['beats'][2][0] === $eagle && $qs['beats'][4][0] === $goat);
ok('it passes the quest lint', $qs && !trail_sight_quest_lint($qs, $all, trail_sight_quests()), json_encode($qs ? trail_sight_quest_lint($qs, $all, trail_sight_quests()) : null));
ok('Hazel is a free villager and no mentor is used', npc_cw_profile(npc_cw_who_key('Hazel Dewdrop'))['mode'] === 'free' && !in_array('Hazel Dewdrop', npc_cw_fixed_names(), true));
foreach ([[20000, 0], [20003, 2], [20009, 5], [20015, 6]] as [$di, $dow]) {
    $GLOBALS['gv_cw_time'] = [$dow, 8.0, $di];
    foreach ([$pine, $goat] as $s) { $fc = npc_cw_forecast('Hazel Dewdrop', $s); ok("forecast for Hazel at $s from day $di", $fc && $fc['to'] > $fc['from'], json_encode($fc)); }
}
$u = q_one('SELECT * FROM users WHERE id = ?', [$u['id']]);
q('DELETE FROM user_sight_quests WHERE user_id = ?', [$u['id']]);
$loc = q_one('SELECT * FROM locations WHERE id = ?', [(int)$r['a_id']]);
$hook = function (string $slug, string $dp) use (&$u, $loc) { $u = q_one('SELECT * FROM users WHERE id = ?', [$u['id']]); return implode(' | ', trail_sight_quest_hook($u, $slug, $loc, ['dp' => $dp, 'tl' => [], 'gd' => 10])); };
$GLOBALS['gv_cw_time'] = [3, 8.0, 20000];
$o = $hook($goat, 'day'); ok('beat 1 (goat ledge): the line begins', str_contains($o, 'A quest begins') && str_contains($o, '1 of 5'), $o);
$o = $hook($wall, 'day'); ok('beat 2 (echo wall) counts', str_contains($o, '(2 of 5)'), $o);
$o = $hook($eagle, 'day'); ok('beat 3 (eagle ledge) counts', str_contains($o, '(3 of 5)'), $o);
$base_t = [3, 8.0, 20000];
$step = function (int $nth, string $slug, string $who) use (&$base_t, $hook) {
    $GLOBALS['gv_cw_time'] = $base_t;
    $f = npc_cw_forecast($who, $slug);
    ok("beat $nth: forecast for $who", (bool)$f, 'none'); if (!$f) return;
    if (empty($f['now'])) { $o = $hook($slug, 'dawn'); ok("beat $nth: $who is not there yet, it says when she is next and does not count (no penalty)", str_contains($o, $who . ' is not here now. Next: ') && !str_contains($o, ' of 5)'), $o); }
    $GLOBALS['gv_cw_time'] = [$f['dow'], $f['from'] + 0.2, $base_t[2] + $f['in']];
    $o = $hook($slug, 'dawn');
    ok("beat $nth at $slug: $who is there, it counts", str_contains($o, $nth === 5 ? 'The Goat Ledge Census is done' : "($nth of 5)"), $o);
    $base_t = [$f['dow'], $f['to'] + 0.5, $base_t[2] + $f['in']];
};
$step(4, $pine, 'Hazel Dewdrop');
$step(5, $goat, 'Hazel Dewdrop');
ok('the line is finished, paid once', (bool)q_val('SELECT done_at FROM user_sight_quests WHERE user_id = ? AND quest = ?', [$u['id'], 'goat-ledge-census']));
unset($GLOBALS['gv_cw_time']);
echo $fails ? "$fails FAILED\n" : "ok\n";
exit($fails ? 1 : 0);
