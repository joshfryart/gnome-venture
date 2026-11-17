<?php
// Delve family (2.7.01): torch bar strip, Torchbearer rows (tally delve-torches, moon), "The Book of Hushes: Doorways Down" (Sorrel Inkcap gives, four villagers by clockwork).
// php tests/trail_fam_delve.php GAME_DIR   (an installed game, player "sprout"; walk.sh installs one)
$_SERVER['SCRIPT_NAME'] = '/adventure.php';
require $argv[1] . '/includes/bootstrap.php';
require_once $argv[1] . '/includes/adventure.php';
require_once $argv[1] . '/includes/trail_tiles.php';
require_once $argv[1] . '/includes/trail_sights.php';
require_once $argv[1] . '/includes/stop_folk.php';
require_once $argv[1] . '/includes/npc_clockwork.php';
require_once $argv[1] . '/includes/moon.php';
require_once $argv[1] . '/includes/trail_fam_delve.php';
$fails = 0;
set_setting('sights_walk_cap', '0');   // 2.7.08: this test uses many Sights on one walk (the cap: tests/trail_sights_278.php)
$GLOBALS['gv_sights_nocache'] = true;
set_exception_handler(function (Throwable $e) { echo '  EXCEPTION ' . get_class($e) . ': ' . $e->getMessage() . ' @ ' . basename($e->getFile()) . ':' . $e->getLine() . "\n"; exit(1); });
function ok(string $what, bool $cond, string $extra = ''): void { global $fails; echo ($cond ? '  ok   ' : '  FAIL ') . $what . ($cond ? '' : "  $extra") . "\n"; if (!$cond) $fails++; }
set_setting('npc_clockwork', '1');
foreach (q("SELECT * FROM locations WHERE kind = 'village' ORDER BY id")->fetchAll() as $v) stop_folk_ensure($v);
$all = trail_sights_all();
$u = q_one("SELECT * FROM users WHERE username = 'sprout'");
$mark = fn(string $slug, bool $used = false) => ['x' => 1, 'y' => 1, 'slug' => $slug, 'row' => $all[$slug], 'left' => $used ? 0 : $all[$slug]['uses'], 'why' => ''];
$ctx = fn(array $marks, string $dp = 'day', int $di = 20000, array $tl = []) => ['u' => $u, 'now' => ['dp' => $dp, 'tl' => $tl], 'marks' => $marks, 'clock' => [3, 12.0, $di]];
$d1d = 'end-delve-1-desert'; $d1m = 'end-delve-1-mountain'; $d2f = 'end-delve-2-forest'; $d2r = 'end-delve-2-rainforest'; $d2d = 'end-delve-2-desert';

echo "== the layer\n";
$h = trail_fam_delve($ctx([$mark($d1d), $mark($d2f, true)]));
ok('renders for a delve section', str_contains($h, 'tfdelve') && str_contains($h, '1 of 2 delve mouths lit') && str_contains($h, 'Torch reach'), $h);
ok('a torch per mouth, lit and unlit said in words', substr_count($h, 'tfd-t ') === 2 && str_contains($h, 'tfd-t lit') && str_contains($h, 'tfd-t unlit') && str_contains($h, '>lit ') && str_contains($h, 'unlit'), $h);
ok('the Lamplighter\'s Round counts lantern-line mouths', str_contains($h, "Round here: 1 of 1 lantern mouths lit"), $h);
ok('not for other sections', trail_fam_delve($ctx([$mark('grassland-the-clover-patch')])) === '' && trail_fam_delve($ctx([])) === '' && trail_fam_delve($ctx([$mark('end-haven-1-coast')])) === '' && trail_fam_delve($ctx([$mark('end-lair-2-tundra')])) === '');
ok('tally shows', str_contains(trail_fam_delve($ctx([$mark($d1d)], 'day', 20000, ['delve-torches' => 5])), 'Torches lit so far: 5'));

echo "== torch reach follows the moon at night\n";
$new = 0; $full = 14;
ok('test days are the phases I mean', moon_phase($new)['key'] === 'new' && moon_phase($full)['key'] === 'full');
ok('night reach: new moon 1, full moon 4, day 5, dusk 4', trail_fam_delve_reach('night', moon_phase($new)['light'], 0) === 1 && trail_fam_delve_reach('night', moon_phase($full)['light'], 0) === 4 && trail_fam_delve_reach('day', 0.0, 0) === 5 && trail_fam_delve_reach('dusk', 0.0, 0) === 4);
ok('lit mouths add a step, never past 5', trail_fam_delve_reach('night', 0.0, 2) === 3 && trail_fam_delve_reach('night', 1.0, 3) === 5);
ok('the card says it', str_contains(trail_fam_delve($ctx([$mark($d1d)], 'night', $new)), 'Torch reach 1 of 5') && str_contains(trail_fam_delve($ctx([$mark($d1d)], 'night', $full)), 'Torch reach 4 of 5') && str_contains(trail_fam_delve($ctx([$mark($d1d)], 'night', $full)), 'Full moon'));
$css = file_get_contents($argv[1] . '/assets/style.css');
ok('css has the block and the dark theme', str_contains($css, '.tfdelve') && str_contains($css, ':root[data-theme="dark"] .tfdelve'));

echo "== Torchbearer rows\n";
$n = 0;
foreach ($all as $slug => $row) {
    if (!str_starts_with($slug, 'end-delve-')) continue;
    $n++;
    $tk = trail_sight_tokens($row['rewards']);
    $tok = array_map(fn($t) => $t['tok'], $tk);
    ok("$slug tallies delve-torches, pays from the 3rd, titles at 12", in_array('tally=delve-torches', $tok, true) && (bool)preg_grep('/^c=5:1$/', $tok) && (bool)preg_grep('/^title=Torchbearer$/', $tok), json_encode($tok));
    ok("$slug gives a sense buff only on dark moons at night", (bool)array_filter($tk, fn($t) => str_starts_with($t['tok'], 'buff=sense:1:60@35') && str_contains(json_encode($t), 'mo=new')), json_encode($tk));
    ok("$slug rows lint clean", !array_filter(trail_sight_lint($row), fn($p) => !str_starts_with($p, 'no landmark picture')), json_encode(trail_sight_lint($row)));
}
ok('nine delve rows', $n === 9, (string)$n);
// play a delve row three times on a route tile: coins start with the third torch
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
db_insert('trail_sight_rows', ['slug' => $base['slug'], 'verb' => $base['verb'], 'icon' => $base['icon'], 'energy' => 0, 'cd' => 55, 'uses' => 9, 'cond' => '-', 'chk' => '-', 'rewards' => $all[$d1d]['rewards'], 'win' => 'x', 'lose' => '', 'tool' => '-', 'fail_en' => 0, 'active' => 1]);
$GLOBALS['gv_sights_reload'] = true; trail_sights_all();
$gain = [];
for ($i = 1; $i <= 4; $i++) {
    $u = q_one('SELECT * FROM users WHERE id = ?', [$u['id']]); $exp = active_expedition((int)$u['id']); $GLOBALS['gv_sights_reload'] = true;
    $c0 = (int)q_val('SELECT coins FROM users WHERE id = ?', [$u['id']]);
    [$a] = trail_sight_do($u, $exp, $base['slug']); save_exp($exp);
    ok("use $i works", $a);
    $gain[$i] = (int)q_val('SELECT coins FROM users WHERE id = ?', [$u['id']]) - $c0;
}
ok('each use lights a torch', (trail_sight_tallies((int)$u['id'])['delve-torches'] ?? 0) === 4, json_encode(trail_sight_tallies((int)$u['id'])));
ok('coins pay from the third torch, not before', $gain[1] === 0 && $gain[2] === 0 && $gain[3] >= 5 && $gain[4] >= 5, json_encode($gain));

echo "== The Book of Hushes: Doorways Down\n";
$who = ['Mabel Tumblethorn', 'Ulric Acorncap', 'Ferrin Sedgemoor', 'Juniper Windlass'];
$qs = trail_sight_quests()['delve-hushes'] ?? null;
ok('the line exists: 5 beats, 4 with npc=, giver Sorrel Inkcap', $qs && count($qs['beats']) === 5 && count(array_filter($qs['beats'], fn($b) => str_starts_with($b[3], 'npc='))) === 4 && $qs['giver'] === 'Sorrel Inkcap', json_encode($qs));
ok('Sorrel Inkcap is a mentor, never a beat', in_array('Sorrel Inkcap', npc_cw_fixed_names(), true) && !array_filter($qs['beats'], fn($b) => str_contains($b[3], 'Sorrel')));
ok('every beat is at a delve Sight', !array_filter($qs['beats'], fn($b) => !str_starts_with($b[0], 'end-delve-')));
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
$o = $hook($d1m, 'day');
ok('beat 1 (no villager): the line begins', str_contains($o, 'A quest begins') && str_contains($o, '1 of 5'), $o);
$beats = [[$d1d, 'dawn', 'Mabel Tumblethorn'], [$d2f, 'dusk', 'Ulric Acorncap'], [$d2r, 'night', 'Ferrin Sedgemoor'], [$d2d, 'dusk', 'Juniper Windlass']];
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
ok('the line is finished, paid once', (bool)q_val('SELECT done_at FROM user_sight_quests WHERE user_id = ? AND quest = ?', [$u['id'], 'delve-hushes']));
$GLOBALS['gv_cw_time'] = $base_t;
ok('nothing more counts afterwards', !str_contains($hook($d2d, 'dusk'), 'Doorways Down'));
unset($GLOBALS['gv_cw_time']);
echo $fails ? "$fails FAILED\n" : "ok\n";
exit($fails ? 1 : 0);
