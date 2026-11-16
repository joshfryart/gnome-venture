<?php
// Delve family (2.7.01): torch bar strip, Torchbearer rows (tally lair-torches, moon), "The Book of Hushes: Doorways Down" (Sorrel Inkcap gives, four villagers by clockwork).
// php tests/trail_fam_lair.php GAME_DIR   (an installed game, player "sprout"; walk.sh installs one)
$_SERVER['SCRIPT_NAME'] = '/adventure.php';
require $argv[1] . '/includes/bootstrap.php';
require_once $argv[1] . '/includes/adventure.php';
require_once $argv[1] . '/includes/trail_tiles.php';
require_once $argv[1] . '/includes/trail_sights.php';
require_once $argv[1] . '/includes/stop_folk.php';
require_once $argv[1] . '/includes/npc_clockwork.php';
require_once $argv[1] . '/includes/moon.php';
require_once $argv[1] . '/includes/trail_fam_lair.php';
$fails = 0;
$GLOBALS['gv_sights_nocache'] = true;
set_exception_handler(function (Throwable $e) { echo '  EXCEPTION ' . get_class($e) . ': ' . $e->getMessage() . ' @ ' . basename($e->getFile()) . ':' . $e->getLine() . "\n"; exit(1); });
function ok(string $what, bool $cond, string $extra = ''): void { global $fails; echo ($cond ? '  ok   ' : '  FAIL ') . $what . ($cond ? '' : "  $extra") . "\n"; if (!$cond) $fails++; }
set_setting('npc_clockwork', '1');
foreach (q("SELECT * FROM locations WHERE kind = 'village' ORDER BY id")->fetchAll() as $v) stop_folk_ensure($v);
$all = trail_sights_all();
$u = q_one("SELECT * FROM users WHERE username = 'sprout'");
$mark = fn(string $slug, bool $used = false) => ['x' => 1, 'y' => 1, 'slug' => $slug, 'row' => $all[$slug], 'left' => $used ? 0 : $all[$slug]['uses'], 'why' => ''];
$ctx = fn(array $marks, string $dp = 'day', int $di = 20000, array $tl = []) => ['u' => $u, 'now' => ['dp' => $dp, 'tl' => $tl], 'marks' => $marks, 'clock' => [3, 12.0, $di]];
$l1m = 'end-lair-1-mountain'; $l1i = 'end-lair-1-island'; $l2d = 'end-lair-2-desert'; $l2f = 'end-lair-2-forest'; $l2r = 'end-lair-2-rainforest'; $l2w = 'end-lair-2-wetland'; $l2m = 'end-lair-2-mountain';

echo "== the layer\n";
$new = 0; $full = 14;
ok('test days are the phases I mean', moon_phase($new)['key'] === 'new' && moon_phase($full)['key'] === 'full');
$h = trail_fam_lair($ctx([$mark($l1m), $mark($l2f, true)], 'day', $full + 1));
ok('renders for a lair section', str_contains($h, 'tflair') && str_contains($h, 'Footprint tracker') && str_contains($h, 'Fresh tracks') && str_contains($h, '1 day since the full moon'), $h);
ok('a line per mouth, read and not read said in words', substr_count($h, 'tfl-t ') === 2 && str_contains($h, 'tfl-t read') && str_contains($h, 'tfl-t unread') && str_contains($h, '>read<') && str_contains($h, 'not read yet') && str_contains($h, 'track reading'), $h);
ok('not for other sections', trail_fam_lair($ctx([$mark('grassland-the-clover-patch')])) === '' && trail_fam_lair($ctx([])) === '' && trail_fam_lair($ctx([$mark('end-delve-1-desert')])) === '' && trail_fam_lair($ctx([$mark('end-haven-1-coast')])) === '');
ok('tally shows', str_contains(trail_fam_lair($ctx([$mark($l1m)], 'day', 20000, ['lair-looks' => 7])), 'Looks at lairs so far: 7'));

echo "== tracks age from the moon\n";
ok('days since full: full 0, new moon 14, day after 1', trail_fam_lair_days($full) === 0 && trail_fam_lair_days($new) === 14 && trail_fam_lair_days($full + 1) === 1);
ok('freshest right after the full moon, old before it', trail_fam_lair_age(0)[0] === 'fresh' && trail_fam_lair_age(5)[0] === 'fresh' && trail_fam_lair_age(6)[0] === 'fading' && trail_fam_lair_age(14)[0] === 'old' && trail_fam_lair_age(27)[0] === 'old');
ok('the card says it', str_contains(trail_fam_lair($ctx([$mark($l1m)], 'day', $full)), 'Fresh tracks') && str_contains(trail_fam_lair($ctx([$mark($l1m)], 'day', $new)), 'Old tracks') && str_contains(trail_fam_lair($ctx([$mark($l1m)], 'day', $full + 8)), 'Fading tracks'));
$css = file_get_contents($argv[1] . '/assets/style.css');
ok('css has the block and the dark theme', str_contains($css, '.tflair') && str_contains($css, ':root[data-theme="dark"] .tflair'));

echo "== Sideways Tracks rows\n";
$n = 0;
foreach ($all as $slug => $row) {
    if (!str_starts_with($slug, 'end-lair-')) continue;
    $n++;
    ok("$slug rows lint clean", !array_filter(trail_sight_lint($row), fn($p) => !str_starts_with($p, 'no landmark picture')), json_encode(trail_sight_lint($row)));
}
ok('ten lair rows', $n === 10, (string)$n);
foreach ([$l1m, $l1i, $l2m] as $slug) {
    $row = $all[$slug]; $tok = array_map(fn($t) => $t['tok'], trail_sight_tokens($row['rewards']));
    ok("$slug is a track-reading pick with a true creature hint and a lose line", str_starts_with($row['check'], 'pick:3:') && in_array('hint=creature', $tok, true) && $row['lose'] !== '' && $row['lose'] !== '-', json_encode([$row['check'], $row['lose']]));
    ok("$slug pays extra when the tracks are fresh (full moon)", (bool)array_filter(trail_sight_tokens($row['rewards']), fn($t) => str_starts_with($t['tok'], 'xp=2:1') && str_contains(json_encode($t), 'mo=full')), json_encode($tok));
}
// play a pick row: right pick gives the hint line, wrong pick the lose line
$base = $all['grassland-the-clover-patch'];
set_setting('gnav_on', '1'); set_setting('gnav_tiles', '1'); set_setting('game_clock_on', '1'); setting('__reload__');
q("UPDATE expeditions SET status = 'done' WHERE user_id = ?", [$u['id']]);
q("UPDATE routes SET kind = 'road' WHERE id = 240");
$r = q_one('SELECT * FROM routes WHERE id = 240');
q("UPDATE users SET location_id = ?, level = 1, energy = 90, coins = 500, ev_quickwalk = 0, game_day = 10, game_minute = 720 WHERE id = ?", [$r['a_id'], $u['id']]);
q('DELETE FROM trail_sight_uses WHERE user_id = ?', [$u['id']]); q('DELETE FROM trail_sight_tally WHERE user_id = ?', [$u['id']]);
$u = q_one('SELECT * FROM users WHERE id = ?', [$u['id']]);
[$sok] = start_expedition($u, 240); ok('the walk starts', $sok);
$exp = active_expedition((int)$u['id']); $sc = trail_scene($exp);
$lm = array_values(array_filter($sc['map']['art']['objs'], fn($o) => $o[2] === 'lm-grassland-the-clover-patch'));
$spot = null; foreach ([[-1, 0], [1, 0], [0, -1], [0, 1], [0, 0]] as [$dx, $dy]) if (in_array(tm_tile($sc['map'], $lm[0][0] + $dx, $lm[0][1] + $dy), ['.', ',', 'S'], true)) { $spot = [$lm[0][0] + $dx, $lm[0][1] + $dy]; break; }
$sc['x'] = $spot[0]; $sc['y'] = $spot[1]; trail_save($sc);
trail_sights_ensure_tables();
q('DELETE FROM trail_sight_rows WHERE slug = ?', [$base['slug']]);
$src = $all[$l1m];
db_insert('trail_sight_rows', ['slug' => $base['slug'], 'verb' => $base['verb'], 'icon' => $base['icon'], 'energy' => 0, 'cd' => 55, 'uses' => 9, 'cond' => '-', 'chk' => $src['check'], 'rewards' => $src['rewards'], 'win' => 'WON', 'lose' => 'LOST', 'tool' => '-', 'fail_en' => 0, 'active' => 1]);
$GLOBALS['gv_sights_reload'] = true; $all2 = trail_sights_all();
$u = q_one('SELECT * FROM users WHERE id = ?', [$u['id']]); $exp = active_expedition((int)$u['id']); $sc = trail_scene($exp);
$right = trail_sight_pick_right($u, $sc, $all2[$base['slug']]); $wrong = ($right + 1) % 3;
[$a] = trail_sight_do($u, $exp, $base['slug'], ['pick' => $wrong]); $msg = (string)(json_decode((string)$exp['log'], true) ?: [''])[count(json_decode((string)$exp['log'], true) ?: ['']) - 1]; save_exp($exp);
ok('a wrong read gives the lose line', $a && str_contains($msg, 'LOST'), $msg);
ok('wrong: no creature hint in the message', !str_contains((string)$msg, '👣') , (string)$msg);
$GLOBALS['gv_sights_reload'] = true;
$u = q_one('SELECT * FROM users WHERE id = ?', [$u['id']]); $exp = active_expedition((int)$u['id']); $sc = trail_scene($exp);
$right = trail_sight_pick_right($u, $sc, trail_sights_all()[$base['slug']]);
[$a2] = trail_sight_do($u, $exp, $base['slug'], ['pick' => $right]); $lg = json_decode((string)$exp['log'], true) ?: ['']; $msg2 = (string)$lg[count($lg) - 1]; save_exp($exp);
ok('a right read works and gives the true creature hint', $a2 && str_contains((string)$msg2, '👣'), json_encode([$a2, $msg2]));

echo "== Field Notes: Sideways Tracks\n";
$who = ['Basil Barleycorn', 'Gorse Oakenpot', 'Pip Pinchkin', 'Dozy Driftmoss'];
$qs = trail_sight_quests()['lair-field-notes'] ?? null;
ok('the line exists: 5 beats, 4 with npc=, giver Captain Bracken Spurwing', $qs && count($qs['beats']) === 5 && count(array_filter($qs['beats'], fn($b) => str_starts_with($b[3], 'npc='))) === 4 && $qs['giver'] === 'Captain Bracken Spurwing', json_encode($qs));
ok('Captain Spurwing is a mentor, never a beat', in_array('Captain Bracken Spurwing', npc_cw_fixed_names(), true) && !array_filter($qs['beats'], fn($b) => str_contains($b[3], 'Bracken')));
ok('every beat is at a lair Sight', !array_filter($qs['beats'], fn($b) => !str_starts_with($b[0], 'end-lair-')));
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
$o = $hook($l1m, 'day');
ok('beat 1 (no villager): the line begins', str_contains($o, 'A quest begins') && str_contains($o, '1 of 5'), $o);
$beats = [[$l2d, 'day', 'Basil Barleycorn'], [$l2r, 'dawn', 'Gorse Oakenpot'], [$l2w, 'dawn', 'Pip Pinchkin'], [$l1i, 'day', 'Dozy Driftmoss']];
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
ok('the line is finished, paid once', (bool)q_val('SELECT done_at FROM user_sight_quests WHERE user_id = ? AND quest = ?', [$u['id'], 'lair-field-notes']));
$GLOBALS['gv_cw_time'] = $base_t;
ok('nothing more counts afterwards', !str_contains($hook($l1i, 'day'), 'Sideways Tracks'));
unset($GLOBALS['gv_cw_time']);
echo $fails ? "$fails FAILED\n" : "ok\n";
exit($fails ? 1 : 0);
