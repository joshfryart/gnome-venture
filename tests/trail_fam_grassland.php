<?php
// Grassland family (2.7.01): the Kite sky strip, the wind-day pay rows and "Mabel's Sky Letters" (5 letters, 5 weathers, Mabel by her weekly clockwork).
// php tests/trail_fam_grassland.php GAME_DIR   (an installed game, player "sprout"; walk.sh installs one)
$_SERVER['SCRIPT_NAME'] = '/adventure.php';
require $argv[1] . '/includes/bootstrap.php';
require_once $argv[1] . '/includes/adventure.php';
require_once $argv[1] . '/includes/trail_tiles.php';
require_once $argv[1] . '/includes/trail_sights.php';
require_once $argv[1] . '/includes/stop_folk.php';
require_once $argv[1] . '/includes/npc_clockwork.php';
require_once $argv[1] . '/includes/trail_fam_grassland.php';
$fails = 0;
$GLOBALS['gv_sights_nocache'] = true;
set_exception_handler(function (Throwable $e) { echo '  EXCEPTION ' . get_class($e) . ': ' . $e->getMessage() . ' @ ' . basename($e->getFile()) . ':' . $e->getLine() . "\n"; exit(1); });
function ok(string $what, bool $cond, string $extra = ''): void { global $fails; echo ($cond ? '  ok   ' : '  FAIL ') . $what . ($cond ? '' : "  $extra") . "\n"; if (!$cond) $fails++; }
set_setting('npc_clockwork', '1');
foreach (q("SELECT * FROM locations WHERE kind = 'village' ORDER BY id")->fetchAll() as $v) stop_folk_ensure($v);
$all = trail_sights_all();
$mark = fn(string $slug) => ['x' => 1, 'y' => 1, 'slug' => $slug, 'row' => $all[$slug], 'left' => $all[$slug]['uses'], 'why' => ''];
$ctx = fn(string $we, array $marks, array $clock = [3, 10.0, 20001], array $tl = []) => ['now' => ['dp' => 'day', 'we' => $we, 'tl' => $tl], 'marks' => $marks, 'clock' => $clock, 'land' => 'grassland', 'u' => []];
$meadow = 'grassland-the-wind-combed-meadow'; $drift = 'grassland-the-dandelion-drift'; $mill = 'grassland-the-sleepy-windmill'; $knoll = 'grassland-the-picnic-knoll';
$ring = 'grassland-the-daisy-ring'; $bridge = 'grassland-the-plank-footbridge'; $wall = 'grassland-the-shepherd-s-wall';

echo "== the wind\n";
$a = trail_fam_grassland_wind('wind', 10.0, 20001); $b = trail_fam_grassland_wind('wind', 10.0, 20001);
ok('same weather, same clock, same wind', $a === $b);
ok('a wind day is a kite day (fast, good)', $a['mph'] >= 22 && $a['mph'] <= 38 && $a['kite'] === 'good', json_encode($a));
ok('a sunny day is no kite day', in_array(trail_fam_grassland_wind('sun', 10.0, 20001)['kite'], ['none', 'low'], true));
ok('a storm is too wild', trail_fam_grassland_wind('storm', 10.0, 20001)['kite'] === 'wild');
$dirs = []; for ($d = 0; $d < 30; $d++) $dirs[trail_fam_grassland_wind('wind', 6.0, 20000 + $d)['dir']] = 1;
ok('the direction varies over days and is always one of 8', count($dirs) > 2 && !array_diff(array_keys($dirs), range(0, 7)));

echo "== the layer\n";
$h = trail_fam_grassland($ctx('wind', [$mark($meadow), $mark($drift), $mark($mill)]));
ok('renders for grassland Sights', str_contains($h, 'tfgrass') && str_contains($h, 'Kite day') && str_contains($h, 'blowing towards the'), $h);
ok('the arrow is an inline SVG with a text alternative', str_contains($h, '<svg class="tfg-svg"') && str_contains($h, 'role="img"') && str_contains($h, 'aria-label="Wind today:'), $h);
ok('the three kite Sights say they pay more today', substr_count($h, 'pays more today') === 3, $h);
$h2 = trail_fam_grassland($ctx('sun', [$mark($meadow)]));
ok('on a calm day they pay their usual, said in words', str_contains($h2, 'pays its usual') && !str_contains($h2, 'pays more today') && !str_contains($h2, 'Kite day'), $h2);
ok('the strip changes with the weather', $h !== trail_fam_grassland($ctx('sun', [$mark($meadow), $mark($drift), $mark($mill)])));
ok('the tally shows', str_contains(trail_fam_grassland($ctx('wind', [$mark($meadow)], [3, 10.0, 20001], ['kite-string' => 4])), 'Kite string wound: 4'));
ok('not for a section with no grassland Sight', trail_fam_grassland($ctx('wind', [$mark('coast-the-kelp-line')])) === '' && trail_fam_grassland($ctx('wind', [])) === '');
ok('not for numbered Maplewold slugs', trail_fam_grassland($ctx('wind', [['x' => 1, 'y' => 1, 'slug' => '12-the-old-well', 'row' => $all[$meadow], 'left' => 1, 'why' => '']])) === '');
ok('the sky letters list shows five letters', substr_count($h, 'letter <b>') === 5, $h);
$css = file_get_contents($argv[1] . '/assets/style.css');
ok('css has the block and the dark theme', str_contains($css, '.tfgrass') && str_contains($css, ':root[data-theme="dark"] .tfgrass'));

echo "== Mabel's chip\n";
$who = 'Mabel Pennywhistle@v-na-1-2';
$GLOBALS['gv_cw_time'] = [3, 8.0, 20000];
$f = npc_cw_forecast($who, $ring);
ok('Mabel has a forecast at the daisy ring', $f !== null);
if ($f) {
    $GLOBALS['gv_cw_time'] = [$f['dow'], $f['from'] + 0.2, 20000 + $f['in']];
    $h = trail_fam_grassland($ctx('cloud', [$mark($ring)], $GLOBALS['gv_cw_time']));
    ok('while she is there: a "here now" chip', str_contains($h, 'Mabel Pennywhistle at The daisy ring') && str_contains($h, 'here now') && str_contains($h, 'tfg-chip now'), $h);
}
unset($GLOBALS['gv_cw_time']);
set_setting('npc_clockwork', '0'); setting('__reload__');
ok('clockwork off: no chips, the strip stays', !str_contains(trail_fam_grassland($ctx('wind', [$mark($ring)])), 'tfg-chip') && str_contains(trail_fam_grassland($ctx('wind', [$mark($ring)])), 'tfgrass'));
set_setting('npc_clockwork', '1'); setting('__reload__');

echo "== Kite & Wind rows\n";
$tokens = fn(string $s) => array_map(fn($t) => $t['tok'] . ($t['cond'] !== '' ? '?' . $t['cond'] : ''), trail_sight_tokens($all[$s]['rewards']));
foreach ([$meadow, $drift, $mill] as $s) {
    ok("$s pays something extra on wind days", (bool)array_filter($tokens($s), fn($t) => str_contains($t, '?we=wind') && !str_starts_with($t, 'hint=')), json_encode($tokens($s)));
    $lint = array_filter(trail_sight_lint($all[$s]), fn($p) => !str_starts_with($p, 'no landmark picture'));
    ok("$s lints clean", !$lint, json_encode(array_values($lint)));
}
ok('the meadow still tallies the kite string', in_array('tally=kite-string', $tokens($meadow), true));
$fk = trail_sight_folk();
$mab = fn(string $slug) => array_values(array_filter($fk[$slug] ?? [], fn($r) => trail_sight_split_who($r['who'])[0] === 'Mabel Pennywhistle'));
ok('Mabel joins the meadow on wind days', (bool)array_filter($mab($meadow), fn($r) => str_contains($r['when'], 'we=wind')));
ok('Mabel has rows at the daisy ring and the footbridge', (bool)$mab($ring) && (bool)$mab($bridge));

echo "== play: wind pays more\n";
$base = $all[$knoll];
set_setting('gnav_on', '1'); set_setting('gnav_tiles', '1'); set_setting('game_clock_on', '1'); setting('__reload__');
$u = q_one("SELECT * FROM users WHERE username = 'sprout'");
q("UPDATE expeditions SET status = 'done' WHERE user_id = ?", [$u['id']]);
q("UPDATE routes SET kind = 'road' WHERE id = 240");
$r = q_one('SELECT * FROM routes WHERE id = 240');
q("UPDATE users SET location_id = ?, level = 1, energy = 90, coins = 0, ev_quickwalk = 0, game_day = 10, game_minute = 600 WHERE id = ?", [$r['a_id'], $u['id']]);
q('DELETE FROM trail_sight_uses WHERE user_id = ?', [$u['id']]); q('DELETE FROM trail_sight_tally WHERE user_id = ?', [$u['id']]);
$u = q_one('SELECT * FROM users WHERE id = ?', [$u['id']]);
[$sok] = start_expedition($u, 240); ok('the walk starts', $sok);
$exp = active_expedition((int)$u['id']); $sc = trail_scene($exp);
$lm = array_values(array_filter($sc['map']['art']['objs'], fn($o) => $o[2] === 'lm-grassland-the-clover-patch'));
$spot = null; foreach ([[-1, 0], [1, 0], [0, -1], [0, 1], [0, 0]] as [$dx, $dy]) if (in_array(tm_tile($sc['map'], $lm[0][0] + $dx, $lm[0][1] + $dy), ['.', ',', 'S'], true)) { $spot = [$lm[0][0] + $dx, $lm[0][1] + $dy]; break; }
$sc['x'] = $spot[0]; $sc['y'] = $spot[1]; trail_save($sc);
trail_sights_ensure_tables();
$slug = 'grassland-the-clover-patch';
$put = function (string $rewards) use ($slug, $base) { q('DELETE FROM trail_sight_rows WHERE slug = ?', [$slug]); db_insert('trail_sight_rows', ['slug' => $slug, 'verb' => $base['verb'], 'icon' => $base['icon'], 'energy' => 0, 'cd' => 55, 'uses' => 9, 'cond' => '-', 'chk' => '-', 'rewards' => $rewards, 'win' => 'x', 'lose' => '', 'tool' => '-', 'fail_en' => 0, 'active' => 1]); $GLOBALS['gv_sights_reload'] = true; trail_sights_all(); };
$put($all[$meadow]['rewards']);
$coins = fn() => (int)q_val('SELECT coins FROM users WHERE id = ?', [$u['id']]);
$use = function () use (&$u, &$exp, $slug) { $u = q_one('SELECT * FROM users WHERE id = ?', [$u['id']]); $exp = active_expedition((int)$u['id']); $GLOBALS['gv_sights_reload'] = true; $r = trail_sight_do($u, $exp, $slug); save_exp($exp); return $r; };
$GLOBALS['gv_weather_probe'] = 1;
$put('c=6:1?we=wind'); setting('__reload__');
$c0 = $coins(); $now = trail_sight_now(['landscape' => 'grassland', 'name' => 'x', 'region' => 'The Maplewold'], null, null);
ok('the Sights `now` carries a weather the rows can read', isset($now['we']) && $now['we'] !== '');
ok('the wind coin row is conditional on we=wind (cond holds only in wind)', trail_sight_cond_ok('we=wind', ['we' => 'wind']) && !trail_sight_cond_ok('we=wind', ['we' => 'sun']));

echo "== Mabel's Sky Letters\n";
$qs = trail_sight_quests()['mabels-sky-letters'] ?? null;
ok('the line exists with 5 beats and at least 2 npc= beats', $qs && count($qs['beats']) === 5 && count(array_filter($qs['beats'], fn($b) => str_starts_with($b[3], 'npc='))) >= 2);
ok('it passes the quest lint', $qs && !trail_sight_quest_lint($qs, $all, trail_sight_quests()), json_encode($qs ? trail_sight_quest_lint($qs, $all, trail_sight_quests()) : null));
$wes = $qs ? array_map(fn($b) => preg_match('/we=([a-z]+)/', $b[2], $m) ? $m[1] : '', $qs['beats']) : [];
sort($wes);
ok('the five letters need five different weathers: sun, cloud, wind, rain, fog', $wes === ['cloud', 'fog', 'rain', 'sun', 'wind'], json_encode($wes));
ok('no mentor is used', !array_filter(array_map(fn($b) => trail_sight_split_who(substr($b[3], 4))[0], array_filter($qs['beats'], fn($b) => str_starts_with($b[3], 'npc='))), fn($n) => in_array($n, npc_cw_fixed_names(), true)));
ok('Mabel is a free villager (the clockwork moves her)', ($k = npc_cw_who_key($who)) !== '' && npc_cw_profile($k)['mode'] === 'free');
foreach ([[20000, 0], [20003, 2], [20009, 5], [20015, 6]] as [$di, $dow]) {
    $GLOBALS['gv_cw_time'] = [$dow, 8.0, $di];
    foreach ([$ring, $bridge] as $s) { $fc = npc_cw_forecast($who, $s); ok("forecast for Mabel at $s from day $di", $fc && $fc['to'] > $fc['from'], json_encode($fc)); }
}
$u = q_one('SELECT * FROM users WHERE id = ?', [$u['id']]);
q('DELETE FROM user_sight_quests WHERE user_id = ?', [$u['id']]);
$loc = q_one('SELECT * FROM locations WHERE id = ?', [(int)$r['a_id']]);
$hook = function (string $slug, string $we) use (&$u, $loc) { $u = q_one('SELECT * FROM users WHERE id = ?', [$u['id']]); return implode(' | ', array_filter(trail_sight_quest_hook($u, $slug, $loc, ['dp' => 'day', 'we' => $we, 'tl' => [], 'gd' => 10]), fn($l) => str_contains($l, "Sky Letters"))); };   // only my line (other families' quests share these Sights)
$GLOBALS['gv_cw_time'] = [3, 8.0, 20000];
$o = $hook($knoll, 'rain');
ok('the wrong weather does not count (sun letter in rain)', !str_contains($o, ' of 5)') && !str_contains($o, 'A quest begins'), $o);
$o = $hook($knoll, 'sun');
ok('the sun letter: the line begins (1 of 5)', str_contains($o, 'A quest begins') && str_contains($o, '(1 of 5)'), $o);
$o = $hook($knoll, 'sun');
ok('the sun letter counts once', !str_contains($o, ' of 5)'), $o);
$o = $hook($meadow, 'sun');
ok('the wind letter needs wind', !str_contains($o, ' of 5)'), $o);
$o = $hook($meadow, 'wind');
ok('the wind letter on a wind day (2 of 5)', str_contains($o, '(2 of 5)'), $o);
$o = $hook($wall, 'fog');
ok('the fog letter in fog (3 of 5)', str_contains($o, '(3 of 5)'), $o);
$base_t = [3, 8.0, 20000];
$step = function (int $nth, string $slug, string $we) use (&$base_t, $hook, $who) {
    $GLOBALS['gv_cw_time'] = $base_t;
    $f = npc_cw_forecast($who, $slug);
    ok("letter $nth: forecast for Mabel at $slug", (bool)$f, 'none'); if (!$f) return;
    if (empty($f['now'])) { $o = $hook($slug, $we); ok("letter $nth: Mabel is not there yet, it says when she is next and does not count (no penalty)", str_contains($o, 'Mabel Pennywhistle is not here now. Next: ') && !str_contains($o, ' of 5)'), $o); }
    $GLOBALS['gv_cw_time'] = [$f['dow'], $f['from'] + 0.2, $base_t[2] + $f['in']];
    $o = $hook($slug, 'sun');
    ok("letter $nth: Mabel is there but it is the wrong weather: no count, no penalty", !str_contains($o, ' of 5)'), $o);
    $o = $hook($slug, $we);
    ok("letter $nth at $slug in $we with Mabel there: counts ($nth of 5)", str_contains($o, "($nth of 5)") || ($nth === 5 && str_contains($o, 'is done')), $o);
    $base_t = [$f['dow'], $f['to'] + 0.5, $base_t[2] + $f['in']];
};
$step(4, $ring, 'cloud');
$step(5, $bridge, 'rain');
ok('the line is finished, paid once', (bool)q_val('SELECT done_at FROM user_sight_quests WHERE user_id = ? AND quest = ?', [$u['id'], 'mabels-sky-letters']));
ok('nothing more counts afterwards', $hook($knoll, 'sun') === '');
unset($GLOBALS['gv_cw_time']);
echo $fails ? "$fails FAILED\n" : "ok\n";
exit($fails ? 1 : 0);
