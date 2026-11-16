<?php
// Tundra family (2.7.01): the Aurora overlay (winter night, moon), the Warm Hut Relay rows (tally) and "Ferrin's Long Night" with Ferrin Pennywhistle by his weekly clockwork.
// php tests/trail_fam_tundra.php GAME_DIR   (an installed game, player "sprout"; walk.sh installs one)
$_SERVER['SCRIPT_NAME'] = '/adventure.php';
require $argv[1] . '/includes/bootstrap.php';
require_once $argv[1] . '/includes/adventure.php';
require_once $argv[1] . '/includes/trail_tiles.php';
require_once $argv[1] . '/includes/trail_sights.php';
require_once $argv[1] . '/includes/stop_folk.php';
require_once $argv[1] . '/includes/npc_clockwork.php';
require_once $argv[1] . '/includes/moon.php';
require_once $argv[1] . '/includes/trail_fam_tundra.php';
$fails = 0;
$GLOBALS['gv_sights_nocache'] = true;
set_exception_handler(function (Throwable $e) { echo '  EXCEPTION ' . get_class($e) . ': ' . $e->getMessage() . ' @ ' . basename($e->getFile()) . ':' . $e->getLine() . "\n"; exit(1); });
function ok(string $what, bool $cond, string $extra = ''): void { global $fails; echo ($cond ? '  ok   ' : '  FAIL ') . $what . ($cond ? '' : "  $extra") . "\n"; if (!$cond) $fails++; }
set_setting('npc_clockwork', '1');
foreach (q("SELECT * FROM locations WHERE kind = 'village' ORDER BY id")->fetchAll() as $v) stop_folk_ensure($v);
$all = trail_sights_all();
$mark = fn(string $slug) => ['x' => 1, 'y' => 1, 'slug' => $slug, 'row' => $all[$slug], 'left' => $all[$slug]['uses'], 'why' => ''];
$ctx = fn(string $dp, array $marks, array $clock = [3, 23.0, 20001], array $tl = [], string $se = 'winter') => ['now' => ['dp' => $dp, 'se' => $se, 'tl' => $tl], 'marks' => $marks, 'clock' => $clock, 'land' => 'tundra'];
$fort = 'tundra-the-snow-fort'; $fir = 'tundra-the-lone-fir'; $stream = 'tundra-the-frozen-stream'; $stones = 'tundra-the-star-chart-stones'; $rise = 'tundra-the-aurora-rise';
$newDay = 28 * 700; $fullDay = 28 * 700 + 14;

echo "== the aurora (pure function of day, daypart, season)\n";
$a = trail_fam_tundra_aurora($newDay, 'night', 'winter'); $b = trail_fam_tundra_aurora($newDay, 'night', 'winter');
ok('same inputs, same sky', $a === $b);
ok('on only on a winter night', $a['on'] && !trail_fam_tundra_aurora($newDay, 'day', 'winter')['on'] && !trail_fam_tundra_aurora($newDay, 'night', 'summer')['on'] && !trail_fam_tundra_aurora($newDay, 'dusk', 'winter')['on']);
$f = trail_fam_tundra_aurora($fullDay, 'night', 'winter');
ok('brighter at new moon than at full moon', $a['bright'] > $f['bright'] && $a['bright'] === 1.0, json_encode([$a['bright'], $f['bright']]));
ok('words follow the moon', $a['word'] === 'blazing' && $f['word'] === 'faint', $a['word'] . '/' . $f['word']);
$m = true; for ($d = 0; $d < 28; $d++) { $x = trail_fam_tundra_aurora($d, 'night', 'winter')['bright']; if ($x < 0.25 || $x > 1.0) $m = false; }
ok('brightness stays in range over a month', $m);

echo "== the layer\n";
$h = trail_fam_tundra($ctx('night', [$mark($fort), $mark($rise)], [3, 23.0, $newDay]));
ok('renders for a section with tundra Sights', str_contains($h, 'tftundra') && str_contains($h, 'Aurora blazing'), $h);
ok('winter night: ribbons drawn, brightness class', str_contains($h, 'tft-sky') && str_contains($h, 'tft-on') && str_contains($h, 'tft-b4'), $h);
ok('the moon is named in words', str_contains($h, 'New moon') && str_contains($h, 'day '), $h);
$hf = trail_fam_tundra($ctx('night', [$mark($fort)], [3, 23.0, $fullDay]));
ok('full moon: fainter class', str_contains($hf, 'tft-b1') && str_contains($hf, 'Aurora faint'), $hf);
$hd = trail_fam_tundra($ctx('day', [$mark($fort)], [3, 12.0, $newDay]));
ok('by day: no ribbons, text says it', !str_contains($hd, 'tft-sky') && str_contains($hd, 'Aurora asleep until night') && str_contains($hd, 'tft-off'), $hd);
$hs = trail_fam_tundra($ctx('night', [$mark($fort)], [3, 23.0, $newDay], [], 'summer'));
ok('summer night: no aurora, says winter only', !str_contains($hs, 'tft-sky') && str_contains($hs, 'only dances in winter'), $hs);
ok('not for other lands, Maplewold marks or no marks', trail_fam_tundra($ctx('night', [$mark('coast-the-kelp-line')])) === '' && trail_fam_tundra($ctx('night', [])) === '' && trail_fam_tundra($ctx('night', [['x' => 1, 'y' => 1, 'slug' => '12-the-old-well', 'row' => $all[$fort], 'left' => 1, 'why' => '']])) === '');
$ht = trail_fam_tundra($ctx('day', [$mark($fort), $mark($fir), $mark($stones)], [3, 12.0, $newDay], ['hut-warmth' => 2]));
ok('warm huts listed with the chain (2 of 3) in words', str_contains($ht, 'tft-hut') && str_contains($ht, 'Huts warmed: 2') && str_contains($ht, 'aria-label="Warm Hut Relay: 2 of 3 huts warmed"'), $ht);
ok('no huts: no chain', !str_contains(trail_fam_tundra($ctx('day', [$mark($stream)])), 'tft-chain'));
$css = file_get_contents($argv[1] . '/assets/style.css');
ok('css has the block and the dark theme', str_contains($css, '.tftundra') && str_contains($css, ':root[data-theme="dark"] .tftundra'));

echo "== appointment chip\n";
$who = 'Ferrin Pennywhistle';
ok("$who is a free villager (the clockwork moves him)", npc_cw_profile(npc_cw_who_key($who))['mode'] === 'free');
$GLOBALS['gv_cw_time'] = [3, 8.0, 20000];
$fc = npc_cw_forecast($who, $stream);
ok("$who has a forecast at the frozen stream", $fc !== null);
if ($fc) {
    $GLOBALS['gv_cw_time'] = [$fc['dow'], $fc['from'] + 0.2, 20000 + $fc['in']];
    $h = trail_fam_tundra($ctx('night', [$mark($stream)], $GLOBALS['gv_cw_time']));
    ok('while he is there: a "here now" chip', str_contains($h, $who . ' at ') && str_contains($h, 'here now') && str_contains($h, 'tft-chip now'), $h);
    $GLOBALS['gv_cw_time'] = [$fc['dow'], $fc['to'] + 0.5, 20000 + $fc['in']];
    $h = trail_fam_tundra($ctx('night', [$mark($stream)], $GLOBALS['gv_cw_time']));
    ok('after he has gone: the chip says when he is next', str_contains($h, $who) && !str_contains($h, 'here now'), $h);
    unset($GLOBALS['gv_cw_time']);
}
set_setting('npc_clockwork', '0'); setting('__reload__');
ok('clockwork off: no chips, the layer stays', !str_contains(trail_fam_tundra($ctx('night', [$mark($stream)])), 'tft-chip') && str_contains(trail_fam_tundra($ctx('night', [$mark($stream)])), 'tftundra'));
set_setting('npc_clockwork', '1'); setting('__reload__');

echo "== Warm Hut Relay rows\n";
$tokens = fn(string $s) => array_map(fn($t) => $t['tok'] . ($t['cond'] !== '' ? '?' . $t['cond'] : ''), trail_sight_tokens($all[$s]['rewards']));
foreach (TRAIL_FAM_TUNDRA_HUTS as $hut) {
    ok("$hut: warmth buff, tally, title at 3", (bool)preg_grep('/^buff=hardiness:1:90$/', $tokens($hut)) && in_array('tally=hut-warmth', $tokens($hut), true) && in_array('title=Warm Hand?tn=hut-warmth:3', $tokens($hut), true));
    $lint = array_filter(trail_sight_lint($all[$hut]), fn($p) => !str_starts_with($p, 'no landmark picture'));
    ok("$hut lints clean", !$lint, json_encode(array_values($lint)));
}
ok('the aurora rise pays a bonus ribbon on a winter night near the new moon', (bool)preg_grep('/^item=aurora-ribbon:1@30\?se=winter\/dp=night\/mo=new,waxing-crescent,waning-crescent$/', $tokens($rise)), json_encode($tokens($rise)));
ok('that condition holds at a new-moon winter night and not at full moon', trail_sight_cond_ok('se=winter/dp=night/mo=new,waxing-crescent,waning-crescent', ['se' => 'winter', 'dp' => 'night', 'mo' => 'new']) && !trail_sight_cond_ok('se=winter/dp=night/mo=new,waxing-crescent,waning-crescent', ['se' => 'winter', 'dp' => 'night', 'mo' => 'full']));
$lint = array_filter(trail_sight_lint($all[$rise]), fn($p) => !str_starts_with($p, 'no landmark picture'));
ok('the aurora rise lints clean', !$lint, json_encode(array_values($lint)));

echo "== play: three huts, three warm minutes\n";
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
$GLOBALS['gv_cw_time'] = [3, 12.0, 20003];
foreach ([$fort, $fir, $stones] as $i => $hut) {
    q('DELETE FROM trail_sight_rows WHERE slug = ?', [$base['slug']]);
    db_insert('trail_sight_rows', ['slug' => $base['slug'], 'verb' => $base['verb'], 'icon' => $base['icon'], 'energy' => 0, 'cd' => 0, 'uses' => 99, 'cond' => '-', 'chk' => '-', 'rewards' => $all[$hut]['rewards'], 'win' => 'x', 'lose' => '', 'tool' => '-', 'fail_en' => 0, 'active' => 1]);
    $GLOBALS['gv_sights_reload'] = true; trail_sights_all();
    q('DELETE FROM trail_sight_uses WHERE user_id = ?', [$u['id']]);
    $u = q_one('SELECT * FROM users WHERE id = ?', [$u['id']]); $exp = active_expedition((int)$u['id']);
    [$a, $msg] = trail_sight_do($u, $exp, $base['slug']); save_exp($exp);
    ok('hut ' . ($i + 1) . ' (' . $hut . ') works', $a, json_encode($msg));
    ok('the warmth chain is ' . ($i + 1), (trail_sight_tallies((int)$u['id'])['hut-warmth'] ?? 0) === $i + 1);
}
unset($GLOBALS['gv_cw_time']);

echo "== Ferrin's Long Night\n";
$qs = trail_sight_quests()['ferrins-long-night'] ?? null;
ok('the line exists with 5 beats and at least 2 npc= beats', $qs && count($qs['beats']) === 5 && count(array_filter($qs['beats'], fn($b) => str_starts_with($b[3], 'npc='))) >= 2);
ok('it passes the quest lint', $qs && !trail_sight_quest_lint($qs, $all, trail_sight_quests()), json_encode($qs ? trail_sight_quest_lint($qs, $all, trail_sight_quests()) : null));
ok('five tundra Sights in order, the last on a winter night', $qs && array_column($qs['beats'], 0) === [$fort, $fir, $stream, $stones, $rise] && $qs['beats'][4][2] === 'se=winter/dp=night');
ok('no mentor is used', !array_filter(array_map(fn($b) => substr($b[3], 4), array_filter($qs['beats'], fn($b) => str_starts_with($b[3], 'npc='))), fn($n) => in_array($n, npc_cw_fixed_names(), true)));
foreach ([[20000, 0], [20003, 2], [20009, 5], [20015, 6]] as [$di, $dow]) {
    $GLOBALS['gv_cw_time'] = [$dow, 8.0, $di];
    foreach ([$fort, $stream, $rise] as $s) { $fc = npc_cw_forecast($who, $s); ok("forecast for $who at $s from day $di", $fc && $fc['to'] > $fc['from'], json_encode($fc)); }
}
$u = q_one('SELECT * FROM users WHERE id = ?', [$u['id']]);
q('DELETE FROM user_sight_quests WHERE user_id = ?', [$u['id']]);
$loc = q_one('SELECT * FROM locations WHERE id = ?', [(int)$r['a_id']]);
$hook = function (string $slug, array $now) use (&$u, $loc) { $u = q_one('SELECT * FROM users WHERE id = ?', [$u['id']]); return implode(' | ', trail_sight_quest_hook($u, $slug, $loc, $now + ['tl' => [], 'gd' => 10])); };
$base_t = [3, 8.0, 20000];
$step = function (int $nth, string $slug, string $dp, string $we, string $se) use (&$base_t, $hook, $who) {
    $GLOBALS['gv_cw_time'] = $base_t;
    $f = npc_cw_forecast($who, $slug);
    ok("beat $nth: forecast for $who", (bool)$f, 'none'); if (!$f) return;
    $now = ['dp' => $dp, 'we' => $we, 'se' => $se];
    if (empty($f['now'])) { $o = $hook($slug, $now); ok("beat $nth: $who is not there yet, it says when he is next and does not count (no penalty)", str_contains($o, $who . ' is not here now. Next: ') && !str_contains($o, ' of 5)'), $o); }
    $GLOBALS['gv_cw_time'] = [$f['dow'], $f['from'] + 0.2, $base_t[2] + $f['in']];
    $o = $hook($slug, $now);
    ok("beat $nth at $slug: $who is there, it counts", str_contains($o, "($nth of 5)"), $o);
    $base_t = [$f['dow'], $f['to'] + 0.5, $base_t[2] + $f['in']];
};
$step(1, $fort, 'day', 'snow', 'winter');
$GLOBALS['gv_cw_time'] = $base_t;
$o = $hook($fir, ['dp' => 'day', 'we' => 'sun', 'se' => 'winter']); ok('beat 2 does not count without snow', !str_contains($o, ' of 5)'), $o);
$o = $hook($fir, ['dp' => 'day', 'we' => 'snow', 'se' => 'winter']); ok('beat 2: in the snow the fir counts', str_contains($o, '(2 of 5)'), $o);
$step(3, $stream, 'day', 'snow', 'winter');
$GLOBALS['gv_cw_time'] = $base_t;
$o = $hook($stones, ['dp' => 'day', 'we' => 'snow', 'se' => 'winter']); ok('beat 4 does not count by day', !str_contains($o, "Long Night:"), $o);
$o = $hook($stones, ['dp' => 'night', 'we' => 'snow', 'se' => 'summer']); ok('beat 4 does not count out of winter', !str_contains($o, "Long Night:"), $o);
$o = $hook($stones, ['dp' => 'night', 'we' => 'snow', 'se' => 'winter']); ok('beat 4: winter night, the stars line up', (bool)preg_match('/Long Night: .*\(4 of 5\)/', $o), $o);
$GLOBALS['gv_cw_time'] = $base_t;
$fr = npc_cw_forecast($who, $rise);
ok('the finale: Ferrin has a window at the aurora rise', (bool)$fr, 'none');
if ($fr) {
    $o = $hook($rise, ['dp' => 'night', 'se' => 'summer']); ok('finale out of winter: no count', !str_contains($o, 'is done'), $o);
    $GLOBALS['gv_cw_time'] = [$fr['dow'], $fr['from'] + 0.2, $base_t[2] + $fr['in']];
    $o = $hook($rise, ['dp' => 'day', 'se' => 'winter']); ok('finale by day: no count', !str_contains($o, 'is done'), $o);
    $o = $hook($rise, ['dp' => 'night', 'se' => 'winter']); ok("finale on a winter night with Ferrin: Ferrin's Long Night is done", str_contains($o, "Ferrin's Long Night is done"), $o);
    ok('the line is finished, paid once', (bool)q_val('SELECT done_at FROM user_sight_quests WHERE user_id = ? AND quest = ?', [$u['id'], 'ferrins-long-night']));
    ok('nothing more counts afterwards', $hook($rise, ['dp' => 'night', 'se' => 'winter']) === '');
}
unset($GLOBALS['gv_cw_time']);
echo $fails ? "$fails FAILED\n" : "ok\n";
exit($fails ? 1 : 0);
