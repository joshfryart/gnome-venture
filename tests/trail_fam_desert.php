<?php
// Desert family (2.7.01): Caravan Stop strip (heat/shade by day, moon by night), Tobias at the tent poles (traveller, no npc=), cool-night moon bonuses and the dusk quest line.
// php tests/trail_fam_desert.php GAME_DIR   (an installed game, player "sprout")
$_SERVER['SCRIPT_NAME'] = '/adventure.php';
require $argv[1] . '/includes/bootstrap.php';
require_once $argv[1] . '/includes/adventure.php';
require_once $argv[1] . '/includes/trail_sights.php';
require_once $argv[1] . '/includes/stop_folk.php';
require_once $argv[1] . '/includes/npc_clockwork.php';
require_once $argv[1] . '/includes/moon.php';
require_once $argv[1] . '/includes/trail_fam_desert.php';
$fails = 0;
$GLOBALS['gv_sights_nocache'] = true;
set_exception_handler(function (Throwable $e) { echo '  EXCEPTION ' . get_class($e) . ': ' . $e->getMessage() . ' @ ' . basename($e->getFile()) . ':' . $e->getLine() . "\n"; exit(1); });
function ok(string $what, bool $cond, string $extra = ''): void { global $fails; echo ($cond ? '  ok   ' : '  FAIL ') . $what . ($cond ? '' : "  $extra") . "\n"; if (!$cond) $fails++; }
set_setting('npc_clockwork', '1');
foreach (q("SELECT * FROM locations WHERE kind = 'village' ORDER BY id")->fetchAll() as $v) stop_folk_ensure($v);
$all = trail_sights_all();
$mark = fn(string $slug) => ['x' => 1, 'y' => 1, 'slug' => $slug, 'row' => $all[$slug], 'left' => $all[$slug]['uses'], 'why' => ''];
$ctx = fn(string $dp, array $marks, array $clock = [3, 12.0, 20000], array $extra = []) => ['now' => $extra + ['dp' => $dp, 'tl' => [], 'gd' => 14], 'marks' => $marks, 'clock' => $clock, 'land' => 'desert'];
$poles = 'desert-the-trader-s-tent-poles'; $arch = 'desert-the-red-rock-arch'; $ripple = 'desert-the-sand-ripple-lane'; $well = 'desert-the-well-and-its-rope';
$bones = 'desert-the-sun-bleached-bones'; $pool = 'desert-the-mirage-pool'; $awn = 'desert-the-shade-awning';

echo "== the layer by day\n";
$h = trail_fam_desert($ctx('day', [$mark($awn), $mark($well), $mark($poles)]));
ok('renders for a section with desert Sights', str_contains($h, 'tfdesert') && str_contains($h, 'tfd-hot') && str_contains($h, 'Fierce sun'), $h);
ok('the water gauge says its value in words and aria-label', str_contains($h, 'Water gauge: 1 of 5') && str_contains($h, '1 of 5'), $h);
ok('shade pips list the shady Sights', str_contains($h, 'tfd-sh') && str_contains($h, 'awning') && str_contains($h, 'well'));
ok('shimmer class at high sun, none at 7am', str_contains($h, 'tfd-shimmer') && !str_contains(trail_fam_desert($ctx('day', [$mark($awn)], [3, 7.0, 20000])), 'tfd-shimmer'));
ok('heat weather adds one sun', trail_fam_desert_sun(12.0, 'heat') === 5 && trail_fam_desert_sun(12.0, '') === 4 && trail_fam_desert_sun(23.0, 'heat') === 0);
ok('the Caravan Stop line shows at the tent poles and says the seventh day', str_contains($h, 'Caravan Stop') && str_contains($h, 'seventh day, Tobias'), $h);
ok('not at the poles, no caravan line', !str_contains(trail_fam_desert($ctx('day', [$mark($awn)])), 'Caravan Stop'));
ok('not for other land Sights, or none', trail_fam_desert($ctx('day', [$mark('grassland-the-clover-patch')])) === '' && trail_fam_desert($ctx('day', [])) === '');
$css = file_get_contents($argv[1] . '/assets/style.css');
ok('css has the block and the dark theme', str_contains($css, '.tfdesert') && str_contains($css, ':root[data-theme="dark"] .tfdesert'));

echo "== the layer by night: the moon\n";
$full = 14; $newd = 0;
$hn = trail_fam_desert($ctx('night', [$mark($bones), $mark($pool)], [3, 22.0, $full]));
ok('night shows the cool strip with the moon name', str_contains($hn, 'tfd-cool') && str_contains($hn, 'Cool night') && str_contains($hn, 'Full moon') && !str_contains($hn, 'Water gauge'), $hn);
ok('full moon: both bonus Sights say bonus tonight', substr_count($hn, 'cool-night bonus tonight') === 2, $hn);
$hn2 = trail_fam_desert($ctx('night', [$mark($bones), $mark($pool)], [3, 22.0, $newd]));
ok('new moon: no bonus tonight', str_contains($hn2, 'New moon') && substr_count($hn2, 'no bonus tonight') === 2, $hn2);
ok('gibbous: the bones pay, the pool does not', substr_count(trail_fam_desert($ctx('night', [$mark($bones), $mark($pool)], [3, 22.0, 11])), 'cool-night bonus tonight') === 1);

echo "== game rows\n";
$tk = fn(string $s) => array_map(fn($t) => $t['tok'] . ($t['cond'] !== '' ? '?' . $t['cond'] : ''), trail_sight_tokens($all[$s]['rewards']));
ok('bones: cool-night energy by moon', (bool)preg_grep('/^en=1\?dp=night\/mo=full,waxing-gibbous,waning-gibbous$/', $tk($bones)), json_encode($tk($bones)));
ok('mirage pool: full-moon night marble', (bool)preg_grep('/^item=mirage-marble:1@20\?dp=night\/mo=full$/', $tk($pool)));
ok('the well gives a flask of well water', in_array('item=well-water:1', $tk($well), true));
foreach ([$bones, $pool, $well] as $s) { $lint = array_filter(trail_sight_lint($all[$s]), fn($p) => !str_starts_with($p, 'no landmark picture')); ok("$s lints clean", !$lint, json_encode(array_values($lint))); }
ok('moon conditions work in cond_ok', trail_sight_cond_ok('dp=night/mo=full,waxing-gibbous', ['dp' => 'night', 'mo' => 'full']) && !trail_sight_cond_ok('dp=night/mo=full', ['dp' => 'night', 'mo' => 'new']));
$fk = trail_sight_folk();
$tob = array_values(array_filter($fk[$poles] ?? [], fn($r) => $r['who'] === 'Tobias Trundle'));
ok('Tobias has a tent-pole row on the 7th day, trading well water for a seed', $tob && $tob[0]['when'] === 'gd=7:0' && str_contains($tob[0]['rewards'], 'give=well-water:1') && str_contains($tob[0]['rewards'], 'seed=1'), json_encode($tob));
ok('Tobias is a traveller: not clockwork-managed (no npc= for him)', npc_cw_who_key('Tobias Trundle') === '');
trail_sights_ensure_items();
ok('item well-water exists', (bool)q_val("SELECT id FROM items WHERE slug = 'well-water'"));

echo "== appointment chip\n";
$f = npc_cw_forecast('Ivy Brambleby', $arch);
ok('Ivy has a forecast at the arch', $f !== null);
if ($f) {
    $GLOBALS['gv_cw_time'] = [$f['dow'], $f['from'] + 0.2, 20000 + $f['in']];
    $h = trail_fam_desert($ctx('dusk', [$mark($arch)], $GLOBALS['gv_cw_time']));
    ok('while she is there: a here-now chip', str_contains($h, 'Ivy Brambleby at') && str_contains($h, 'here now') && str_contains($h, 'tfd-chip now'), $h);
    unset($GLOBALS['gv_cw_time']);
}
set_setting('npc_clockwork', '0'); setting('__reload__');
ok('clockwork off: no chips, the strip stays', !str_contains(trail_fam_desert($ctx('dusk', [$mark($arch)])), 'tfd-chip') && str_contains(trail_fam_desert($ctx('dusk', [$mark($arch)])), 'tfdesert'));
set_setting('npc_clockwork', '1'); setting('__reload__');

echo "== Lanterns for the Long Way Home\n";
$qs = trail_sight_quests()['trader-dusk-lanterns'] ?? null;
ok('the line exists with 5 beats, 3 npc= beats, all dusk', $qs && count($qs['beats']) === 5 && count(array_filter($qs['beats'], fn($b) => str_starts_with($b[3], 'npc='))) === 3 && count(array_filter($qs['beats'], fn($b) => str_contains($b[2], 'dp=dusk'))) === 5);
ok('it passes the quest lint', $qs && !trail_sight_quest_lint($qs, $all, trail_sight_quests()), json_encode($qs ? trail_sight_quest_lint($qs, $all, trail_sight_quests()) : null));
ok('it follows trader-went-home and the finale is the 7th day at the poles', $qs && ($qs['gate'] ?? '') === 'quest:trader-went-home' && $qs['beats'][4][0] === $poles && str_contains($qs['beats'][4][2], 'gd=7:0') && $qs['beats'][4][3] === '');
ok('no npc= beat names a traveller or mentor', !array_filter(array_map(fn($b) => substr($b[3], 4), array_filter($qs['beats'], fn($b) => str_starts_with($b[3], 'npc='))), fn($n) => npc_cw_who_key($n) === '' || in_array($n, npc_cw_fixed_names(), true)));
$npcs = ['Ivy Brambleby' => $arch, 'Yarrow Lanternby' => $ripple, 'Orla Teaspoon' => $well];
foreach ($npcs as $n => $s) ok("$n is a free villager", npc_cw_profile(npc_cw_who_key($n))['mode'] === 'free');
foreach ([[20000, 0], [20003, 2], [20009, 5], [20015, 6]] as [$di, $dow]) {
    $GLOBALS['gv_cw_time'] = [$dow, 8.0, $di];
    foreach ($npcs as $n => $s) { $fc = npc_cw_forecast($n, $s); ok("forecast for $n at $s from day $di", $fc && $fc['to'] > $fc['from'], json_encode($fc)); }
}
$dusk = hollow_daypart_hours()[2];
foreach ($npcs as $n => $s) { $fc = npc_cw_forecast($n, $s); ok("$n's window is at dusk (starts at $dusk or after)", $fc && $fc['from'] >= $dusk - 1 && $fc['from'] <= $dusk + 2, json_encode($fc)); }
$u = q_one("SELECT * FROM users WHERE username = 'sprout'");
q('DELETE FROM user_sight_quests WHERE user_id = ?', [$u['id']]);
$loc = q_one("SELECT * FROM locations WHERE kind = 'village' ORDER BY id LIMIT 1");
$gd = 14;
$hook = function (string $slug, string $dp, int $g = 14) use (&$u, $loc) { $u = q_one('SELECT * FROM users WHERE id = ?', [$u['id']]); return implode(' | ', trail_sight_quest_hook($u, $slug, $loc, ['dp' => $dp, 'tl' => [], 'gd' => $g])); };
// the gate: the line cannot begin until the first one is done
$GLOBALS['gv_cw_time'] = [3, 19.0, 20000];
$o = $hook($poles, 'dusk');
ok('gated: before The Trader Who Went Home is done the lantern does not start this line', !str_contains($o, 'Lanterns for the Long Way Home'), $o);
q('DELETE FROM user_sight_quests WHERE user_id = ?', [$u['id']]);
db_insert('user_sight_quests', ['user_id' => $u['id'], 'quest' => 'trader-went-home', 'beats' => '[]', 'started_at' => now(), 'done_at' => now()]);
$o = $hook($poles, 'day');
ok('by day the lantern beat does nothing (dusk only)', !str_contains($o, 'Lanterns for the Long Way Home'), $o);
$o = $hook($poles, 'dusk');
ok('beat 1 at dusk: the line begins', str_contains($o, 'A quest begins: Lanterns') && str_contains($o, '1 of 5'), $o);
$base_t = [3, 8.0, 20000];
$step = function (int $nth, string $slug, string $who) use (&$base_t, $hook) {
    $GLOBALS['gv_cw_time'] = $base_t;
    $f = npc_cw_forecast($who, $slug);
    ok("beat $nth: forecast for $who", (bool)$f); if (!$f) return;
    if (empty($f['now'])) { $o = $hook($slug, 'dusk'); ok("beat $nth: $who not there yet, it says when they are next and nothing is lost", str_contains($o, $who . ' is not here now. Next: ') && !str_contains($o, ' of 5)'), $o); }
    $GLOBALS['gv_cw_time'] = [$f['dow'], $f['from'] + 0.2, $base_t[2] + $f['in']];
    $o = $hook($slug, 'day'); ok("beat $nth by day does not count", !str_contains($o, "($nth of 5)"), $o);
    $o = $hook($slug, 'dusk'); ok("beat $nth at $slug: $who is there at dusk, it counts", str_contains($o, "($nth of 5)"), $o);
    $base_t = [$f['dow'], $f['to'] + 0.5, $base_t[2] + $f['in']];
};
$step(2, $arch, 'Ivy Brambleby');
$step(3, $ripple, 'Yarrow Lanternby');
$step(4, $well, 'Orla Teaspoon');
$GLOBALS['gv_cw_time'] = [3, 19.0, $base_t[2]];
$o = $hook($poles, 'dusk', 15);
ok('finale: not the seventh day, nothing counts', !str_contains($o, 'is done'), $o);
$o = $hook($poles, 'day', 14);
ok('finale: the seventh day but by day, nothing counts', !str_contains($o, 'is done'), $o);
$o = $hook($poles, 'dusk', 14);
ok('finale: seventh day at dusk, the line is done', str_contains($o, 'Lanterns for the Long Way Home is done'), $o);
ok('paid once, finished', (bool)q_val('SELECT done_at FROM user_sight_quests WHERE user_id = ? AND quest = ?', [$u['id'], 'trader-dusk-lanterns']));
ok('nothing more counts afterwards', $hook($poles, 'dusk', 14) === '');
unset($GLOBALS['gv_cw_time']);
echo $fails ? "$fails FAILED\n" : "ok\n";
exit($fails ? 1 : 0);
