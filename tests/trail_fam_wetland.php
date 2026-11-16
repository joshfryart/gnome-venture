<?php
// Wetland family (2.7.01): Reed-line ripples + firefly row, Stepping Stones / firefly rows, "The Dragonfly Bend Count" with Fig and Pip by their weekly clockwork.
// php tests/trail_fam_wetland.php GAME_DIR   (an installed game, player "sprout"; walk.sh installs one)
$_SERVER['SCRIPT_NAME'] = '/adventure.php';
require $argv[1] . '/includes/bootstrap.php';
require_once $argv[1] . '/includes/adventure.php';
require_once $argv[1] . '/includes/trail_tiles.php';
require_once $argv[1] . '/includes/trail_sights.php';
require_once $argv[1] . '/includes/stop_folk.php';
require_once $argv[1] . '/includes/npc_clockwork.php';
require_once $argv[1] . '/includes/moon.php';
require_once $argv[1] . '/includes/trail_fam_wetland.php';
$fails = 0;
$GLOBALS['gv_sights_nocache'] = true;
set_exception_handler(function (Throwable $e) { echo '  EXCEPTION ' . get_class($e) . ': ' . $e->getMessage() . ' @ ' . basename($e->getFile()) . ':' . $e->getLine() . "\n"; exit(1); });
function ok(string $what, bool $cond, string $extra = ''): void { global $fails; echo ($cond ? '  ok   ' : '  FAIL ') . $what . ($cond ? '' : "  $extra") . "\n"; if (!$cond) $fails++; }
set_setting('npc_clockwork', '1');
foreach (q("SELECT * FROM locations WHERE kind = 'village' ORDER BY id")->fetchAll() as $v) stop_folk_ensure($v);
$all = trail_sights_all();
$mark = fn(string $slug) => ['x' => 1, 'y' => 1, 'slug' => $slug, 'row' => $all[$slug], 'left' => $all[$slug]['uses'], 'why' => ''];
$ctx = fn(string $dp, array $marks, array $clock = [3, 8.0, 20000], array $tl = []) => ['now' => ['dp' => $dp, 'tl' => $tl], 'marks' => $marks, 'clock' => $clock, 'land' => 'wetland'];
$ford = 'wetland-the-lily-pad-ford'; $bend = 'wetland-the-dragonfly-bend'; $cause = 'wetland-the-reed-causeway'; $gap = 'wetland-the-boardwalk-gap'; $flats = 'wetland-the-mud-skipper-flats';
$newD = 28 * 700; $fullD = $newD + 14;   // a new moon day and a full moon day

echo "== fireflies and the moon\n";
$fn = trail_fam_wetland_fireflies($newD, 'dusk'); $ffl = trail_fam_wetland_fireflies($fullD, 'dusk');
ok('brighter at new moon than at full moon', $fn['lit'] > $ffl['lit'] && $fn['lit'] === 8 && $ffl['lit'] === 2, json_encode([$fn['lit'], $ffl['lit']]));
ok('out at dusk and night only', $fn['out'] && trail_fam_wetland_fireflies($newD, 'night')['out'] && !trail_fam_wetland_fireflies($newD, 'day')['out'] && !trail_fam_wetland_fireflies($newD, 'dawn')['out']);
ok('same day, same fireflies', trail_fam_wetland_fireflies(123, 'dusk') === trail_fam_wetland_fireflies(123, 'dusk'));

echo "== the layer\n";
$h = trail_fam_wetland($ctx('dusk', [$mark($ford), $mark($bend), $mark($cause)], [3, 19.0, $newD]));
ok('renders for a section with wetland Sights, with the moon', str_contains($h, 'tfwetland') && str_contains($h, 'tfw-moon') && str_contains($h, moon_phase($newD)['name']), $h);
ok('ripples: one per Sight, said in words', substr_count($h, 'tfw-r ') === 3 && str_contains($h, 'rippling'), $h);
ok('fireflies lit at dusk at new moon, with words and a text alternative', str_contains($h, 'Fireflies blazing (8 of 8)') && str_contains($h, 'aria-label="Fireflies: 8 of 8 lamps lit') && substr_count($h, '<i class="on">') === 8, $h);
$hd = trail_fam_wetland($ctx('day', [$mark($ford)], [3, 12.0, $newD]));
ok('by day the fireflies are asleep', str_contains($hd, 'asleep until dusk') && !str_contains($hd, '<i class="on">'), $hd);
ok('full moon dims them', str_contains(trail_fam_wetland($ctx('dusk', [$mark($ford)], [3, 19.0, $fullD])), 'Fireflies faint (2 of 8)'));
ok('the stones tally shows', str_contains(trail_fam_wetland($ctx('dawn', [$mark($ford)], [3, 6.0, 20000], ['stones' => 4])), 'Crossings: 4'));
ok('not for a section with no wetland Sight', trail_fam_wetland($ctx('dawn', [$mark('grassland-the-clover-patch')])) === '' && trail_fam_wetland($ctx('dawn', [])) === '');
ok('not for a Maplewold-style mark list', trail_fam_wetland($ctx('dawn', [['x' => 1, 'y' => 1, 'slug' => '12-the-old-well', 'row' => $all[$ford], 'left' => 1, 'why' => '']])) === '');
$css = file_get_contents($argv[1] . '/assets/style.css');
ok('css has the block, the dark theme and reduced motion', str_contains($css, '.tfwetland') && str_contains($css, ':root[data-theme="dark"] .tfwetland') && str_contains($css, '.tfw-r.open .tfw-ring{animation:none}'));

echo "== Stepping Stones and firefly rows\n";
$tokens = fn(string $s) => array_map(fn($t) => $t['tok'] . ($t['cond'] !== '' ? '?' . $t['cond'] : ''), trail_sight_tokens($all[$s]['rewards']));
ok('the ford is a pick of 3 pads, a miss costs only energy (no take=, fail_en 1)', str_starts_with($all[$ford]['check'], 'pick:3') && (int)$all[$ford]['fail_en'] === 1 && !array_filter($tokens($ford), fn($t) => str_starts_with($t, 'take=')) && $all[$ford]['lose'] !== '');
ok('the ford counts stones and pays at 5 and 12', in_array('tally=stones', $tokens($ford), true) && (bool)preg_grep('/^item=cattail-root:2\?tn=stones:5$/', $tokens($ford)) && (bool)preg_grep('/^title=Stone Hopper\?tn=stones:12$/', $tokens($ford)));
ok('the boardwalk stays a nimble check (the chain)', str_starts_with($all[$gap]['check'], 'nimble:') && (bool)preg_grep('/^item=bog-iron:1\?tn=stones:5$/', $tokens($gap)) || (bool)preg_grep('/tn=stones:5/', $tokens($gap)));
$ft = $tokens($cause);
ok('fireflies: a dusk/night chance and a better one at new moon', (bool)preg_grep('/^item=firefly-light:1@15\?dp=dusk,night$/', $ft) && (bool)preg_grep('/^item=firefly-light:1@30\?dp=dusk,night\/mo=new$/', $ft), json_encode($ft));
ok('the new-moon condition works', trail_sight_cond_ok('mo=new', ['mo' => 'new']) && !trail_sight_cond_ok('mo=new', ['mo' => 'full']));
foreach ([$ford, $gap, $cause] as $s) { $lint = array_filter(trail_sight_lint($all[$s]), fn($p) => !str_starts_with($p, 'no landmark picture')); ok("$s lints clean", !$lint, json_encode(array_values($lint))); }
ok('the firefly item is defined in the family items file (the lint checks it too)', str_contains((string)file_get_contents($argv[1] . '/includes/data/trail_sight_items_fam_wetland.txt'), 'firefly-light|'));

echo "== The Dragonfly Bend Count\n";
$qs = trail_sight_quests()['dragonfly-bend-count'] ?? null;
ok('the line exists with 5 beats, 3 se= beats and 2 npc= beats', $qs && count($qs['beats']) === 5 && count(array_filter($qs['beats'], fn($b) => str_starts_with($b[2], 'se='))) === 3 && count(array_filter($qs['beats'], fn($b) => str_starts_with($b[3], 'npc='))) === 2);
ok('it passes the quest lint', $qs && !trail_sight_quest_lint($qs, $all, trail_sight_quests()), json_encode($qs ? trail_sight_quest_lint($qs, $all, trail_sight_quests()) : null));
ok('the finale is Pip at dusk', $qs && $qs['beats'][4][0] === $bend && $qs['beats'][4][2] === 'dp=dusk' && $qs['beats'][4][3] === 'npc=Pip Oakenpot');
ok('no mentor is used', !array_filter(array_map(fn($b) => substr($b[3], 4), array_filter($qs['beats'], fn($b) => str_starts_with($b[3], 'npc='))), fn($n) => in_array($n, npc_cw_fixed_names(), true)));
$npcs = ['Fig Hollowell' => $cause, 'Pip Oakenpot' => $bend];
foreach ($npcs as $n => $s) ok("$n is a free villager", npc_cw_profile(npc_cw_who_key($n))['mode'] === 'free');
foreach ([[20000, 0], [20003, 2], [20009, 5], [20015, 6]] as [$di, $dow]) {
    $GLOBALS['gv_cw_time'] = [$dow, 8.0, $di];
    foreach ($npcs as $n => $s) { $fc = npc_cw_forecast($n, $s); ok("forecast for $n at $s from day $di", $fc && $fc['to'] > $fc['from'], json_encode($fc)); }
}
$u = q_one("SELECT * FROM users WHERE username = 'sprout'");
q('DELETE FROM user_sight_quests WHERE user_id = ?', [$u['id']]);
$loc = q_one("SELECT * FROM locations WHERE kind = 'village' ORDER BY id LIMIT 1");
$hook = function (string $slug, array $now) use (&$u, $loc) { $u = q_one('SELECT * FROM users WHERE id = ?', [$u['id']]); return implode(' | ', trail_sight_quest_hook($u, $slug, $loc, $now + ['dp' => 'day', 'tl' => [], 'gd' => 10])); };
$GLOBALS['gv_cw_time'] = [3, 8.0, 20000];
$o = $hook($bend, ['se' => 'spring']);
ok('spring beat: the line begins and counts', str_contains($o, 'A quest begins') && str_contains($o, '1 of 5'), $o);
$o = $hook($bend, ['se' => 'spring']);
ok('spring again does not count twice', !str_contains($o, '2 of 5'), $o);
$o = $hook($bend, ['se' => 'winter']);
ok('winter counts nothing (no winter beat, no penalty)', !str_contains($o, ' of 5)'), $o);
$o = $hook($bend, ['se' => 'summer']); ok('summer beat counts', str_contains($o, '(2 of 5)'), $o);
$o = $hook($bend, ['se' => 'autumn']); ok('autumn beat counts', str_contains($o, '(3 of 5)'), $o);
// Fig at the causeway
$base_t = [3, 8.0, 20000];
$GLOBALS['gv_cw_time'] = $base_t;
$f = npc_cw_forecast('Fig Hollowell', $cause);
ok('beat 4: forecast for Fig', (bool)$f);
if ($f) {
    if (empty($f['now'])) { $o = $hook($cause, []); ok('Fig not there yet: it says when she is next and does not count', str_contains($o, 'Fig Hollowell is not here now. Next: ') && !str_contains($o, '(4 of 5)'), $o); }
    $GLOBALS['gv_cw_time'] = [$f['dow'], $f['from'] + 0.2, $base_t[2] + $f['in']];
    $o = $hook($cause, []); ok('Fig is there: it counts', str_contains($o, '(4 of 5)'), $o);
    $base_t = [$f['dow'], $f['to'] + 0.5, $base_t[2] + $f['in']];
}
// the finale: Pip at dusk only
$GLOBALS['gv_cw_time'] = $base_t;
$f = npc_cw_forecast('Pip Oakenpot', $bend);
ok('finale: forecast for Pip', (bool)$f);
if ($f) {
    $o = $hook($bend, ['dp' => 'day']);
    ok('by day it is not the finale (Pip rates at dusk only)', !str_contains($o, 'is done') && !str_contains($o, '(5 of 5)'), $o);
    if (empty($f['now'])) { $GLOBALS['gv_cw_time'] = $base_t; $o = $hook($bend, ['dp' => 'dusk']); ok('dusk but Pip is away: says when he is next, nothing counts', str_contains($o, 'Pip Oakenpot is not here now. Next: ') && !str_contains($o, 'is done'), $o); }
    $GLOBALS['gv_cw_time'] = [$f['dow'], $f['from'] + 0.2, $base_t[2] + $f['in']];
    $o = $hook($bend, ['dp' => 'dusk']);
    ok('dusk with Pip there: the count is rated, the line is done', str_contains($o, 'The Dragonfly Bend Count is done'), $o);
    ok('the line is finished, paid once', (bool)q_val('SELECT done_at FROM user_sight_quests WHERE user_id = ? AND quest = ?', [$u['id'], 'dragonfly-bend-count']));
    ok('nothing more counts afterwards', $hook($bend, ['dp' => 'dusk']) === '');
}
unset($GLOBALS['gv_cw_time']);
echo $fails ? "$fails FAILED\n" : "ok\n";
exit($fails ? 1 : 0);
