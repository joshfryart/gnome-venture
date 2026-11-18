<?php
// Rainforest family (2.7.01): Canopy layers + Mist Pool Tally strip, the pool rows (tally, title at 12, full-moon bonus) and "The Orchid That Opens at Night" with villagers by their weekly clockwork.
// php tests/trail_fam_rainforest.php GAME_DIR   (an installed game, player "sprout"; walk.sh installs one)
$_SERVER['SCRIPT_NAME'] = '/adventure.php';
require $argv[1] . '/includes/bootstrap.php';
require_once $argv[1] . '/includes/adventure.php';
require_once $argv[1] . '/includes/trail_tiles.php';
require_once $argv[1] . '/includes/trail_sights.php';
require_once $argv[1] . '/includes/stop_folk.php';
require_once $argv[1] . '/includes/npc_clockwork.php';
require_once $argv[1] . '/includes/moon.php';
require_once $argv[1] . '/includes/trail_fam_rainforest.php';
$fails = 0;
set_setting('sights_walk_cap', '0');   // 2.7.08: this test uses many Sights on one walk (the cap: tests/trail_sights_278.php)
$GLOBALS['gv_sights_nocache'] = true;
set_exception_handler(function (Throwable $e) { echo '  EXCEPTION ' . get_class($e) . ': ' . $e->getMessage() . ' @ ' . basename($e->getFile()) . ':' . $e->getLine() . "\n"; exit(1); });
function ok(string $what, bool $cond, string $extra = ''): void { global $fails; echo ($cond ? '  ok   ' : '  FAIL ') . $what . ($cond ? '' : "  $extra") . "\n"; if (!$cond) $fails++; }
set_setting('npc_clockwork', '1');
foreach (q("SELECT * FROM locations WHERE kind = 'village' ORDER BY id")->fetchAll() as $v) stop_folk_ensure($v);
$all = trail_sights_all();
$mark = fn(string $slug, int $left = 1) => ['x' => 1, 'y' => 1, 'slug' => $slug, 'row' => $all[$slug], 'left' => $left, 'why' => ''];
$ctx = fn(string $dp, array $marks, array $clock = [3, 22.0, 20000], array $tl = []) => ['now' => ['dp' => $dp, 'tl' => $tl], 'marks' => $marks, 'clock' => $clock, 'land' => 'rainforest'];
$fern = 'rainforest-the-giant-fern-glade'; $lantern = 'rainforest-the-lantern-fruit'; $pool = 'rainforest-the-mist-pool'; $giant = 'rainforest-the-fallen-giant'; $orchid = 'rainforest-the-orchid-tree';
$drum = 'rainforest-the-rain-drum-leaf'; $gap = 'rainforest-the-canopy-gap'; $perch = 'rainforest-the-parrot-perch';

echo "== the layer\n";
$h = trail_fam_rainforest($ctx('night', [$mark($pool), $mark($drum), $mark($gap), $mark($orchid), $mark($fern)]));
ok('renders for a section with rainforest Sights', str_contains($h, 'tfrain') && str_contains($h, 'Canopy layers'), $h);
ok('floor and canopy are two <details> in one group, no JS, the floor open', substr_count($h, '<details class="tfr-layer" name="tfr-layer"') === 2 && str_contains($h, 'name="tfr-layer" open><summary>Forest floor (3)') && str_contains($h, '<summary>Canopy (2)') && !str_contains($h, '<script') && !str_contains($h, 'onclick'), $h);
ok('the canopy Sights sit in the canopy part, the floor ones in the floor part', preg_match('/Canopy \(2\).*The canopy gap.*The orchid tree/s', $h) === 1 && preg_match('/Forest floor \(3\).*The mist-pool.*The giant fern glade.*Canopy \(2\)/s', $h) === 1, $h);
ok('ready / resting is said in words', str_contains($h, '<b>ready</b>') && str_contains(trail_fam_rainforest($ctx('night', [$mark($pool, 0)])), '<b>resting</b>'));
// 2.7.08: the moon note sits in the moon pill and starts a sentence ("A full moon tonight"), so the check ignores case
ok('the moon shows, a full moon at night says so', str_contains(trail_fam_rainforest($ctx('night', [$mark($pool)], [3, 22.0, 14])), 'Full moon') && stripos(trail_fam_rainforest($ctx('night', [$mark($pool)], [3, 22.0, 14])), 'a full moon tonight') !== false && stripos(trail_fam_rainforest($ctx('night', [$mark($pool)], [3, 22.0, 7])), 'a full moon tonight') === false && stripos(trail_fam_rainforest($ctx('day', [$mark($pool)], [3, 12.0, 14])), 'a full moon tonight') === false);
ok('the same clock draws the same strip', $h === trail_fam_rainforest($ctx('night', [$mark($pool), $mark($drum), $mark($gap), $mark($orchid), $mark($fern)])));
ok('not for a section with no rainforest Sight, nor none at all', trail_fam_rainforest($ctx('night', [$mark('grassland-the-clover-patch')])) === '' && trail_fam_rainforest($ctx('night', [])) === '' && trail_fam_rainforest($ctx('night', [$mark('coast-the-kelp-line')])) === '');
ok('not for numbered (Maplewold) slugs', trail_fam_rainforest($ctx('night', [['x' => 1, 'y' => 1, 'slug' => '12-the-old-well', 'row' => $all[$pool], 'left' => 1, 'why' => '']])) === '');
ok('a section with only floor Sights says the canopy is empty', str_contains(trail_fam_rainforest($ctx('day', [$mark($fern)])), 'Nothing in the canopy here'));
$t = trail_fam_rainforest($ctx('day', [$mark($pool), $mark($drum)], [3, 12.0, 20000], ['mist-pools' => 4]));
ok('the tally and the way to the title', str_contains($t, '4 pools filled (8 more for the title Mist Keeper)') && str_contains($t, '2 of 2 pools here are ready'), $t);
ok('earned title', str_contains(trail_fam_rainforest($ctx('day', [$mark($pool)], [3, 12.0, 20000], ['mist-pools' => 12])), 'Mist Keeper earned'));
$css = file_get_contents($argv[1] . '/assets/style.css');
ok('css has the block, the dark theme, and no new JS file is needed', str_contains($css, '.tfrain') && str_contains($css, ':root[data-theme="dark"] .tfrain'));

echo "== moon condition\n";
$full = null; for ($d = 0; $d < 28; $d++) if (moon_phase($d)['key'] === 'full') { $full = $d; break; }
$new = null; for ($d = 0; $d < 28; $d++) if (moon_phase($d)['key'] === 'new') { $new = $d; break; }
ok('mo=full holds only at full moon', trail_sight_cond_ok('dp=night/mo=full', ['dp' => 'night', 'mo' => 'full']) && !trail_sight_cond_ok('dp=night/mo=full', ['dp' => 'night', 'mo' => 'new']) && !trail_sight_cond_ok('dp=night/mo=full', ['dp' => 'day', 'mo' => 'full']));

echo "== appointment chip (next-appointment from the clockwork)\n";
$who = 'Posy Marrowby';
$GLOBALS['gv_cw_time'] = [3, 8.0, 20000];   // pin the clockwork clock: the forecast's day index must be the one the checks below set (20000 + in), not today's real date
$f = npc_cw_forecast($who, $lantern, 'dp=night');   // 2.7.06: the forecast honours the folk row's when, as the layer's chip does
ok("$who has a forecast at the lantern fruit", $f !== null);
if ($f) {
    $GLOBALS['gv_cw_time'] = [$f['dow'], $f['from'] + 0.2, 20000 + $f['in']];
    $h = trail_fam_rainforest($ctx('night', [$mark($lantern)], $GLOBALS['gv_cw_time']));
    ok('while she is there: a "here now" chip', str_contains($h, $who . ' at The lantern fruit') && str_contains($h, 'here now') && str_contains($h, 'tfr-chip now'), $h);
    $GLOBALS['gv_cw_time'] = [$f['dow'], $f['to'] + 0.5, 20000 + $f['in']];
    $h = trail_fam_rainforest($ctx('day', [$mark($lantern)], $GLOBALS['gv_cw_time']));
    ok('after she has gone: the chip says when she is next', str_contains($h, $who) && !str_contains($h, 'here now'), $h);
    unset($GLOBALS['gv_cw_time']);
}
set_setting('npc_clockwork', '0'); setting('__reload__');
ok('clockwork off: no chips, the strip stays', !str_contains(trail_fam_rainforest($ctx('night', [$mark($lantern)])), 'tfr-chip') && str_contains(trail_fam_rainforest($ctx('night', [$mark($lantern)])), 'tfrain'));
set_setting('npc_clockwork', '1'); setting('__reload__');

echo "== Mist Pool Tally rows\n";
$tokens = fn(string $s) => array_map(fn($t) => $t['tok'] . ($t['cond'] !== '' ? '?' . $t['cond'] : ''), trail_sight_tokens($all[$s]['rewards']));
foreach (TRAIL_FAM_RAINFOREST_POOLS as $s) {
    ok("$s counts a mist pool and pays the title at 12", in_array('tally=mist-pools', $tokens($s), true) && in_array('title=Mist Keeper?tn=mist-pools:12', $tokens($s), true), json_encode($tokens($s)));
    $lint = array_filter(trail_sight_lint($all[$s]), fn($p) => !str_starts_with($p, 'no landmark picture'));
    ok("$s lints clean", !$lint, json_encode(array_values($lint)));
}
ok('full moon bonuses on the night rows (pool, orchid tree, lantern fruit)', in_array('item=dew-pearl:1@20?dp=night/mo=full', $tokens($pool), true) && in_array('item=cut-moth-orchid:1@30?dp=night/mo=full', $tokens($orchid), true) && in_array('buff=sense:1:240?dp=night/mo=full', $tokens($lantern), true));
foreach ([$orchid, $lantern] as $s) { $lint = array_filter(trail_sight_lint($all[$s]), fn($p) => !str_starts_with($p, 'no landmark picture')); ok("$s lints clean", !$lint, json_encode(array_values($lint))); }

echo "== play: a pool row's tally and the title\n";
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
db_insert('trail_sight_rows', ['slug' => $base['slug'], 'verb' => $base['verb'], 'icon' => $base['icon'], 'energy' => 0, 'cd' => 55, 'uses' => 99, 'cond' => '-', 'chk' => '-', 'rewards' => $all[$pool]['rewards'], 'win' => 'x', 'lose' => '', 'tool' => '-', 'fail_en' => 0, 'active' => 1]);
$GLOBALS['gv_sights_reload'] = true; trail_sights_all();
$use = function () use (&$u, &$exp, $base) { $u = q_one('SELECT * FROM users WHERE id = ?', [$u['id']]); $exp = active_expedition((int)$u['id']); $GLOBALS['gv_sights_reload'] = true; $r = trail_sight_do($u, $exp, $base['slug']); save_exp($exp); return $r; };
$tally = fn() => (trail_sight_tallies((int)$u['id'])['mist-pools'] ?? 0);
$title = fn() => (bool)q_val("SELECT COUNT(*) FROM user_titles WHERE user_id = ? AND title = 'Mist Keeper'", [$u['id']]);
$hasT = true; try { $title(); } catch (Throwable $e) { $hasT = false; }
$GLOBALS['gv_cw_time'] = [3, 22.0, $full ?? 14];
for ($i = 1; $i <= 12; $i++) { q('DELETE FROM trail_sight_uses WHERE user_id = ?', [$u['id']]); [$a, $msg] = $use(); if (!$a) ok("pool visit $i works", false, json_encode($msg)); }
ok('twelve visits: the tally is 12', $tally() === 12, (string)$tally());
if ($hasT) ok('the twelfth visit pays the title Mist Keeper', $title());
unset($GLOBALS['gv_cw_time']);

echo "== The Orchid That Opens at Night\n";
$qs = trail_sight_quests()['orchid-that-opens-at-night'] ?? null;
ok('the line exists with 5 beats, every beat at night, at least 2 npc= beats', $qs && count($qs['beats']) === 5 && count(array_filter($qs['beats'], fn($b) => $b[2] === 'dp=night')) === 5 && count(array_filter($qs['beats'], fn($b) => str_starts_with($b[3], 'npc='))) >= 2);
ok('it passes the quest lint', $qs && !trail_sight_quest_lint($qs, $all, trail_sight_quests()), json_encode($qs ? trail_sight_quest_lint($qs, $all, trail_sight_quests()) : null));
ok('no mentor is used', !array_filter(array_map(fn($b) => substr($b[3], 4), array_filter($qs['beats'], fn($b) => str_starts_with($b[3], 'npc='))), fn($n) => in_array($n, npc_cw_fixed_names(), true)));
$npcs = ['Posy Marrowby' => $lantern, 'Juniper Puddlefoot' => $giant, 'Quill Thistledown' => $orchid];
foreach ($npcs as $n => $s) ok("$n is a free villager (the clockwork moves them)", npc_cw_profile(npc_cw_who_key($n))['mode'] === 'free');
foreach ([[20000, 0], [20003, 2], [20009, 5], [20015, 6]] as [$di, $dow]) {
    $GLOBALS['gv_cw_time'] = [$dow, 8.0, $di];
    foreach ($npcs as $n => $s) { $fc = npc_cw_forecast($n, $s); ok("forecast for $n at $s from day $di", $fc && $fc['to'] > $fc['from'], json_encode($fc)); }
}
$u = q_one('SELECT * FROM users WHERE id = ?', [$u['id']]);
q('DELETE FROM user_sight_quests WHERE user_id = ?', [$u['id']]);
$loc = q_one('SELECT * FROM locations WHERE id = ?', [(int)$r['a_id']]);
$hook = function (string $slug, string $dp) use (&$u, $loc) { $u = q_one('SELECT * FROM users WHERE id = ?', [$u['id']]); return implode(' | ', trail_sight_quest_hook($u, $slug, $loc, ['dp' => $dp, 'tl' => [], 'gd' => 10])); };
$base_t = [3, 8.0, 20000];
$GLOBALS['gv_cw_time'] = $base_t;
$o = $hook($fern, 'day');
ok('beat 1 by day does not start the line (it is a night line)', !str_contains($o, 'A quest begins'), $o);
$o = $hook($fern, 'night');
ok('beat 1 (fern glade) at night: the line begins', str_contains($o, 'A quest begins') && str_contains($o, '1 of 5'), $o);
$step = function (int $nth, string $slug, string $who, string $mark = '') use (&$base_t, $hook) {
    $GLOBALS['gv_cw_time'] = $base_t;
    $f = npc_cw_forecast($who, $slug);
    ok("beat $nth: forecast for $who", (bool)$f, 'none'); if (!$f) return false;
    if (empty($f['now'])) { $o = $hook($slug, 'night'); ok("beat $nth: $who is not there, it says when they are next and does not count (no penalty)", str_contains($o, $who . ' is not here now. Next: ') && !str_contains($o, "($nth of 5)"), $o); }
    $GLOBALS['gv_cw_time'] = [$f['dow'], $f['from'] + 0.2, $base_t[2] + $f['in']];
    $o = $hook($slug, 'day');
    ok("beat $nth by day: $who there but it is not night, nothing counts", !str_contains($o, "($nth of 5)") && !str_contains($o, 'is done'), $o);
    $o = $hook($slug, 'night');
    ok("beat $nth at $slug: $who is there at night, it counts", str_contains($o, $mark !== '' ? $mark : "($nth of 5)"), $o);
    $base_t = [$f['dow'], $f['to'] + 0.5, $base_t[2] + $f['in']];
    return true;
};
$step(2, $lantern, 'Posy Marrowby');
$GLOBALS['gv_cw_time'] = $base_t;
$o = $hook($pool, 'day');
ok('beat 3 (mist pool) does not count by day', !str_contains($o, '(3 of 5)'), $o);
$o = $hook($pool, 'night');
ok('beat 3: at night the bud shows in the mist', str_contains($o, '(3 of 5)'), $o);
$step(4, $giant, 'Juniper Puddlefoot');
$step(5, $orchid, 'Quill Thistledown', 'The Orchid That Opens at Night is done');
ok('the finale paid: the line is done', (bool)q_val('SELECT done_at FROM user_sight_quests WHERE user_id = ? AND quest = ?', [$u['id'], 'orchid-that-opens-at-night']));
ok('nothing more counts afterwards', $hook($orchid, 'night') === '');
unset($GLOBALS['gv_cw_time']);
echo $fails ? "$fails FAILED\n" : "ok\n";
exit($fails ? 1 : 0);
