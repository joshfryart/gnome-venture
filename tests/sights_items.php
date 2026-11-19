<?php
// Trail Sights items that needed engine work (game/includes/trail_sights_5.php): fern-drip-hat-charm keeps rain off, map-scrap marks a find, star-chart opens a season's
// Almanac page, stargazers-chalk marks the star-chart stones, message-bottle reads a bottle-post note, the optional swap (take= with the condition hv=).
// php tests/sights_items.php GAME_DIR   (an installed game, player "sprout"; ci_suites.sh installs one first). Model: tests/trail_sights_282.php.
$_SERVER['SCRIPT_NAME'] = '/adventure.php';
require $argv[1] . '/includes/bootstrap.php';
require_once $argv[1] . '/includes/adventure.php';
require_once $argv[1] . '/includes/trail_tiles.php';
require_once $argv[1] . '/includes/trail_sights.php';
require_once $argv[1] . '/includes/tools.php';
require_once $argv[1] . '/includes/stop_folk.php';
require_once $argv[1] . '/includes/shelves.php';
$fails = 0;
set_setting('npc_clockwork', '0'); set_setting('sights_walk_cap', '0');
$GLOBALS['gv_sights_nocache'] = true;
set_exception_handler(function (Throwable $e) { echo '  EXCEPTION ' . get_class($e) . ': ' . $e->getMessage() . ' @ ' . basename($e->getFile()) . ':' . $e->getLine() . "\n"; exit(1); });
function ok(string $what, bool $cond, string $extra = ''): void { global $fails; echo ($cond ? '  ok   ' : '  FAIL ') . $what . ($cond ? '' : "  $extra") . "\n"; if (!$cond) $fails++; }
$all = trail_sights_all(); $base = $all['grassland-the-clover-patch'];
$lint = fn(array $chg, string $word) => array_values(array_filter(trail_sight_lint($chg + $base), fn($p) => str_contains($p, $word)));
$u = q_one("SELECT * FROM users WHERE username = 'sprout'");
$uid = (int)$u['id'];
$row = fn() => q_one('SELECT * FROM users WHERE id = ?', [$uid]);
trail_sights_ensure_items();
$id = fn(string $s) => (int)item_id_by_slug($s);
$qty = fn(string $s) => sights5_have($uid, $s);
$setQty = function (string $s, int $n) use ($uid, $id) { q('DELETE FROM user_items WHERE user_id = ? AND item_id = ?', [$uid, $id($s)]); if ($n > 0) give_item($uid, $id($s), $n); };
$logOf = fn(array $exp) => implode(' | ', (array)json_decode((string)$exp['log'], true));

echo "== hv= (the gnome holds N of an item) and the optional swap\n";
ok('hv= and take= with it lint clean', !$lint(['rewards' => 'take=maple-sap:3?hv=maple-sap:3,item=maple-syrup:1?hv=maple-sap:3'], 'condition') && !array_filter($lint(['rewards' => 'take=wheat:2?hv=wheat:2,item=flour:1?hv=wheat:2'], 'hv'), fn($p) => true));
ok('hv= without a number is refused', (bool)$lint(['rewards' => 'item=flour:1?hv=wheat'], 'condition'));
$now = ['uid' => $uid];
$setQty('maple-sap', 2);
ok('hv=maple-sap:3 is false with 2 sap, true with 3', !trail_sight_cond_ok('hv=maple-sap:3', $now) && ($setQty('maple-sap', 3) ?? true) && trail_sight_cond_ok('hv=maple-sap:3', $now));
ok('hv= is false when the gnome is not known (a bare $now)', !trail_sight_cond_ok('hv=maple-sap:1', []));
ok('the three data rows carry the swap (311-sugarshack maple syrup, the two windmills flour)', str_contains($all['311-sugarshack']['rewards'], 'take=maple-sap:3?hv=maple-sap:3') && str_contains($all['311-sugarshack']['rewards'], 'item=maple-syrup:1?hv=maple-sap:3')
    && str_contains($all['236-windmill']['rewards'], 'take=wheat:2?hv=wheat:2') && str_contains($all['grassland-the-sleepy-windmill']['rewards'], 'take=wheat:2?hv=wheat:2') && !trail_sight_lint($all['311-sugarshack']) && !trail_sight_lint($all['grassland-the-sleepy-windmill']));

echo "== the walk\n";
set_setting('gnav_on', '1'); set_setting('gnav_tiles', '1'); set_setting('game_clock_on', '1'); set_setting('weather_force', 'sun'); set_setting('trail_fog_weather', '0'); set_setting('stop_daypart_force', ''); setting('__reload__');
$begin = function (int $route) use ($uid, $row) {
    q("UPDATE expeditions SET status = 'done' WHERE user_id = ?", [$uid]);
    q("UPDATE routes SET kind = 'road', steps = 5 WHERE id = ?", [$route]);
    $r = q_one('SELECT * FROM routes WHERE id = ?', [$route]);
    q("UPDATE users SET location_id = ?, level = 30, energy = 90, coins = 500, ev_quickwalk = 0, game_day = 10, game_minute = 360 WHERE id = ?", [$r['a_id'], $uid]);
    q('DELETE FROM trail_sight_uses WHERE user_id = ?', [$uid]); q('DELETE FROM trail_pickups WHERE user_id = ?', [$uid]);
    [$sok] = start_expedition($row(), $route);
    return [$sok, active_expedition($uid)];
};
[$sok, $exp] = $begin(240); ok('a walk starts', $sok && $exp);
$sc = trail_scene($exp);
$lm = array_values(array_filter($sc['map']['art']['objs'], fn($o) => $o[2] === 'lm-grassland-the-clover-patch'));
$spot = null; foreach ([[-1, 0], [1, 0], [0, -1], [0, 1], [0, 0]] as [$dx, $dy]) if (in_array(tm_tile($sc['map'], $lm[0][0] + $dx, $lm[0][1] + $dy), ['.', ',', 'S'], true)) { $spot = [$lm[0][0] + $dx, $lm[0][1] + $dy]; break; }
$sc['x'] = $spot[0]; $sc['y'] = $spot[1]; trail_save($sc);
trail_sights_ensure_tables();
$put = function (array $chg) use ($base) {
    $r = $chg + $base; q('DELETE FROM trail_sight_rows WHERE slug = ?', [$base['slug']]);
    db_insert('trail_sight_rows', ['slug' => $base['slug'], 'verb' => $r['verb'], 'icon' => $r['icon'], 'energy' => $r['energy'], 'cd' => $r['cd'], 'uses' => $r['uses'], 'cond' => $r['when'], 'chk' => $r['check'], 'rewards' => $r['rewards'], 'win' => $r['win'], 'lose' => $r['lose'], 'tool' => $r['tool'], 'fail_en' => $r['fail_en'] ?? 0]);
    q('DELETE FROM trail_sight_uses'); $GLOBALS['gv_sights_reload'] = true; trail_sights_all();
};
$use = function (array $opt = []) use (&$exp, $row, $base, $uid) { [$a, $m] = trail_sight_do($row(), $exp, $base['slug'], $opt); save_exp($exp); $exp = active_expedition($uid); return [$a, $m]; };
$swap = 'xp=1,take=maple-sap:3?hv=maple-sap:3,item=maple-syrup:1?hv=maple-sap:3';

echo "== the swap on a Sight: 3 sap for 1 syrup, only for a gnome who has the sap\n";
$put(['when' => '-', 'energy' => 0, 'uses' => 9, 'check' => '-', 'rewards' => $swap]);
$setQty('maple-sap', 2); $setQty('maple-syrup', 0);
[$a] = $use();
ok('with 2 sap the Sight still works but swaps nothing: no syrup, the 2 sap stay', $a && $qty('maple-syrup') === 0 && $qty('maple-sap') === 2, $qty('maple-syrup') . '/' . $qty('maple-sap'));
$setQty('maple-sap', 3);
[$a] = $use();
ok('with 3 sap: 1 syrup, the 3 sap are used up', $a && $qty('maple-syrup') === 1 && $qty('maple-sap') === 0, $qty('maple-syrup') . '/' . $qty('maple-sap'));
$put(['when' => '-', 'energy' => 0, 'uses' => 9, 'check' => '-', 'rewards' => 'xp=1,take=wheat:2?hv=wheat:2,item=flour:1?hv=wheat:2']);
$setQty('wheat', 5); $setQty('flour', 0);
[$a] = $use();
ok('2 wheat for 1 flour (5 wheat -> 3)', $a && $qty('flour') === 1 && $qty('wheat') === 3, $qty('flour') . '/' . $qty('wheat'));

echo "== fern-drip-hat-charm keeps rain off\n";
$setQty(SIGHTS5_CHARM, 0);
ok('no charm: not dry', !sights5_dry($uid));
$rainNow = ['we' => 'rain', 'dry' => 0]; $dryNow = ['we' => 'rain', 'dry' => 1];
ok('the weather a penalty sees: rain stays rain without the charm, becomes cloud with it; sun is sun; storm too', sights5_dry_now($rainNow)['we'] === 'rain' && sights5_dry_now($dryNow)['we'] === 'cloud' && sights5_dry_now(['we' => 'storm', 'dry' => 1])['we'] === 'cloud' && sights5_dry_now(['we' => 'sun', 'dry' => 1])['we'] === 'sun');
ok('a check that is harder in rain: sense:11?we=rain:14 is 14 in the rain, 11 with the charm', sights4_check_resolve('sense:11?we=rain:14', $rainNow) === 'sense:14' && sights4_check_resolve('sense:11?we=rain:14', $dryNow) === 'sense:11');
ok('a penalty in rain: the card says "harder" without the charm, nothing with it', sights4_check_note('sense:11?we=rain:14', $rainNow) === 'harder' && sights4_check_note('sense:11?we=rain:14', $dryNow) === '');
set_setting('weather_force', 'rain'); setting('__reload__');
$loseRow = ['when' => '-', 'energy' => 0, 'uses' => 9, 'check' => 'pick:3:Left;Middle;Right', 'lose' => 'Wrong door.', 'rewards' => 'xp=2,lose:time=20?we=rain;storm'];
$put($loseRow);
$right = trail_sight_pick_right($row(), trail_scene($exp), trail_sights_all()[$base['slug']]);
$m0 = (int)$row()['game_minute']; $use(['pick' => ($right + 1) % 3]); $wet = (int)$row()['game_minute'] - $m0;
$setQty(SIGHTS5_CHARM, 1); ok('the charm is held', sights5_dry($uid));
$put($loseRow); $right = trail_sight_pick_right($row(), trail_scene($exp), trail_sights_all()[$base['slug']]);
$m0 = (int)$row()['game_minute']; $use(['pick' => ($right + 1) % 3]); $dry = (int)$row()['game_minute'] - $m0;
ok('a lost check in rain costs 20 more game minutes (' . $wet . ' vs ' . $dry . ' with the charm: the 20 is not paid)', $wet - $dry === 20, "$wet vs $dry");
$loc0 = q_one('SELECT * FROM locations WHERE id = ?', [(int)$exp['from_id']]); $loc0['landscape'] = 'grassland';
$nn = trail_sight_now($loc0, trail_scene($exp), $row());
ok('with the charm the gnome is dry, but the weather a reward sees is still rain (we=rain holds)', (int)$nn['dry'] === 1 && $nn['we'] === 'rain' && trail_sight_cond_ok('we=rain', $nn), json_encode([$nn['dry'], $nn['we']]));
$ev = road_events()['ev']['rain-puddle-road'] ?? null;
ok('the real rain card is a weather card that only happens in rain / storm, and its lost roll costs health', $ev && $ev['kind'] === 'weather' && str_contains($ev['cond'], 'rain') && (bool)array_filter($ev['opts'], fn($o) => str_contains((string)$o['lose'], 'hp:-')));
$lost = '';
foreach ($ev['opts'] as $o) if (str_contains((string)$o['lose'], 'hp:-')) $lost = (string)$o['lose'];
[$fxDry, $note] = sights5_road_rain($ev, $lost, $uid);
ok('with the charm the lost roll on the rain card costs no health (' . $lost . ' -> "' . $fxDry . '")', !str_contains($fxDry, 'hp:') && str_contains($note, 'charm'), $fxDry);
$setQty(SIGHTS5_CHARM, 0);
[$fxWet, $note2] = sights5_road_rain($ev, $lost, $uid);
ok('without it the lost roll costs what it cost', $fxWet === $lost && $note2 === '');
$sunCard = ['kind' => 'choice', 'cond' => '-']; $setQty(SIGHTS5_CHARM, 1);
ok('a card that is not a rain card keeps its health cost even with the charm', sights5_road_rain($sunCard, 'hp:-2', $uid)[0] === 'hp:-2' && sights5_road_rain(['kind' => 'weather', 'cond' => '!we=fog'], 'hp:-2', $uid)[0] === 'hp:-2');
ok('explore_choose calls the hook (the rain card path in explore.php)', str_contains((string)file_get_contents(APP_ROOT . '/includes/explore.php'), 'sights5_road_rain($ev'));
set_setting('weather_force', 'sun'); setting('__reload__'); $setQty(SIGHTS5_CHARM, 0);

echo "== map-scrap marks a find\n";
[$sok, $exp] = $begin(240);
$sc = trail_scene($exp); $sc['st']['phase'] = 'confirm'; trail_save($sc); trail_next($row(), $exp); save_exp($exp); $exp = active_expedition($uid); q('UPDATE expeditions SET encounter = NULL WHERE id = ?', [$exp['id']]); $exp = active_expedition($uid);
$sc = trail_scene($exp);   // stretch 2 has finds
$cand = sights5_mark_candidates($sc);
ok('this stretch has an untaken find to mark (' . count($cand) . ')', count($cand) >= 1, json_encode($sc['st']['tokens']));
$setQty(SIGHTS5_SCRAP, 0);
[$a, $m] = sights5_mapscrap_use($row(), $exp);
ok('no scrap: refused', !$a && str_contains($m, 'no map scrap'), $m);
$setQty(SIGHTS5_SCRAP, 2);
$sc = trail_scene($exp); $sc['st']['fog'] = [(int)$sc['st']['sec']]; trail_save($sc); $sc = trail_scene($exp);
$far = array_values(array_filter($sc['st']['tokens'], fn($t) => $t[2] === 'F' && !$t[3] && max(abs($t[0] - $sc['x']), abs($t[1] - $sc['y'])) > 1));
$before = count(sights4_fog_view($sc)['st']['tokens']);
$foot = sights5_trailfoot_html($row(), $exp, $sc);
ok('the Trail foot offers the scrap button while a find is left to mark and scraps are held', str_contains($foot, 'trail_mapscrap') && str_contains($foot, '×2'), $foot);
[$a, $m] = sights5_mapscrap_use($row(), $exp); save_exp($exp); $exp = active_expedition($uid); $sc = trail_scene($exp);
ok('a scrap marks one find: ok, one scrap used, st.marked has one entry', $a && $qty(SIGHTS5_SCRAP) === 1 && count(sights5_marked($sc['st'])) === 1, $m . ' ' . json_encode($sc['st']['marked'] ?? null));
$mk = explode(',', explode(':', sights5_marked($sc['st'])[0])[1]);
ok('the marked tile is a find that was not taken', (bool)array_filter($sc['st']['tokens'], fn($t) => $t[2] === 'F' && !$t[3] && (int)$t[0] === (int)$mk[0] && (int)$t[1] === (int)$mk[1]) && sights5_is_marked($sc['st'], (int)$mk[0], (int)$mk[1]));
ok('in fog the marked find shows although the gnome is not next to it (finds in view ' . $before . ' -> ' . count(sights4_fog_view($sc)['st']['tokens']) . ')', count(sights4_fog_view($sc)['st']['tokens']) === $before + (max(abs($mk[0] - $sc['x']), abs($mk[1] - $sc['y'])) > 1 ? 1 : 0));
$html = trail_view_html($row(), $exp, $sc, false);
ok('the Trail page draws without error and the marked tile says so (or lies outside the 7 x 7 window)', str_contains($html, 'Something to find (marked on your map)') || max(abs($mk[0] - $sc['x']), abs($mk[1] - $sc['y'])) > 3, substr_count($html, 'Something to find'));
$sc = trail_scene($exp); $sc['st']['marked'] = []; foreach ($sc['st']['tokens'] as $i => $t) if ($t[2] === 'F') $sc['st']['tokens'][$i][3] = 1; trail_save($sc); $sc = trail_scene($exp);
[$a, $m] = sights5_mapscrap_use($row(), $exp);
ok('every find taken: refused, the scrap stays', !$a && $qty(SIGHTS5_SCRAP) === 1 && sights5_trailfoot_html($row(), $exp, $sc) === '', $m);
$post = (string)file_get_contents(APP_ROOT . '/adventure.php');
ok('adventure.php routes trail_mapscrap and trail_chalk and draws the foot', str_contains($post, "'trail_mapscrap', 'trail_chalk'") && str_contains($post, 'sights5_trailfoot_html($u, $exp, $trailSc)') && str_contains($post, 'sights5_trail_do($do'));

echo "== stargazers-chalk marks the star-chart stones\n";
[$sok, $exp] = $begin(363); ok('route 363 (Larkden to the Frost Toad barrow) starts', $sok && $exp);
$sc = trail_scene($exp);
for ($i = 0; $i < 3; $i++) { $sc = trail_scene($exp); $sc['st']['phase'] = 'confirm'; trail_save($sc); trail_next($row(), $exp); save_exp($exp); $exp = active_expedition($uid); $exp['encounter'] = null; q('UPDATE expeditions SET encounter = NULL WHERE id = ?', [$exp['id']]); $exp = active_expedition($uid); }
$sc = trail_scene($exp);
$st = array_values(array_filter($sc['map']['art']['objs'] ?? [], fn($o) => $o[2] === 'lm-' . SIGHTS5_STONES));
ok('stretch 4 of route 363 has the star-chart stones', (bool)$st, (string)$sc['st']['sec']);
if ($st) {
    $spot = null; foreach ([[-1, 0], [1, 0], [0, -1], [0, 1]] as [$dx, $dy]) if (in_array(tm_tile($sc['map'], $st[0][0] + $dx, $st[0][1] + $dy), ['.', ',', 'S'], true) && trail_token_at($sc, $st[0][0] + $dx, $st[0][1] + $dy) < 0) { $spot = [$st[0][0] + $dx, $st[0][1] + $dy]; break; }
    $sc['x'] = $spot[0]; $sc['y'] = $spot[1]; $sc['st']['phase'] = 'section'; trail_save($sc); $sc = trail_scene($exp);
    $setQty(SIGHTS5_CHALK, 2); q("UPDATE users SET game_minute = 780 WHERE id = ?", [$uid]); set_setting('stop_daypart_force', 'day'); setting('__reload__');
    ok('next to the stones, with chalk: the Trail foot offers it', str_contains(sights5_trailfoot_html($row(), $exp, $sc), 'trail_chalk'));
    [$a, $m] = sights5_chalk_use($row(), $exp);
    ok('by day: refused, the chalk stays', !$a && str_contains($m, 'night') && $qty(SIGHTS5_CHALK) === 2, $m);
    set_setting('stop_daypart_force', 'night'); setting('__reload__'); $xp0 = (int)$row()['xp'];
    [$a, $m] = sights5_chalk_use($row(), $exp);
    ok('at night: a mark, one chalk used, mark number 1, +4 XP', $a && $qty(SIGHTS5_CHALK) === 1 && (int)(trail_sight_tallies($uid)['chalk-marks'] ?? 0) === 1 && (int)$row()['xp'] > $xp0, $m);
    [$a, $m] = sights5_chalk_use($row(), $exp);
    ok('a second mark is number 2', $a && (int)(trail_sight_tallies($uid)['chalk-marks'] ?? 0) === 2 && $qty(SIGHTS5_CHALK) === 0, $m);
    [$a, $m] = sights5_chalk_use($row(), $exp);
    ok('no chalk left: refused', !$a);
    $sc = trail_scene($exp); $sc['x'] = $sc['map']['spots']['9'][0]; $sc['y'] = $sc['map']['spots']['9'][1]; trail_save($sc); $sc = trail_scene($exp); $setQty(SIGHTS5_CHALK, 1);
    ok('away from the stones the foot offers no chalk', !str_contains(sights5_trailfoot_html($row(), $exp, $sc), 'trail_chalk'));
    set_setting('stop_daypart_force', ''); setting('__reload__');
}

echo "== star-chart opens the Almanac page of the current season\n";
trail_sights_ensure_pages();
$pages = trail_sight_pages();
ok('four pages in data/trail_sight_pages_items.txt, one per season', count(array_filter(array_keys($pages), fn($k) => str_starts_with($k, 'star-chart-'))) === 4 && !array_diff(array_map(fn($s) => 'star-chart-' . $s, SIGHTS5_SEASONS), array_keys($pages)));
ok('the pages exist in the Almanac, locked', (int)q_val("SELECT COUNT(*) FROM encyclopedia_entries WHERE unlock_key LIKE 'sightpage:star-chart-%'") === 4);
q("DELETE FROM user_encyclopedia WHERE user_id = ? AND entry_id IN (SELECT id FROM encyclopedia_entries WHERE unlock_key LIKE 'sightpage:star-chart-%')", [$uid]);
$chartId = $id(SIGHTS5_CHART); $setQty(SIGHTS5_CHART, 3);
$have = fn(string $s) => (bool)q_val('SELECT 1 FROM user_encyclopedia ue JOIN encyclopedia_entries e ON e.id = ue.entry_id WHERE ue.user_id = ? AND e.unlock_key = ?', [$uid, 'sightpage:star-chart-' . $s]);
foreach (SIGHTS5_SEASONS as $s) {
    set_setting('season_force', $s); setting('__reload__');
    [$a, $m] = sights5_use_item($row(), $chartId);
    ok("in $s: the chart is filed, the $s page opens", $a && $have($s) && str_contains($m, $s), $m);
    if ($s === 'spring') {
        ok('only that season\'s page opened, one chart used', !$have('summer') && !$have('autumn') && !$have('winter') && $qty(SIGHTS5_CHART) === 2);
        [$a2, $m2] = sights5_use_item($row(), $chartId);
        ok('spring again: refused, the chart stays (2 left)', !$a2 && $qty(SIGHTS5_CHART) === 2 && str_contains($m2, 'already'), $m2);
        $setQty(SIGHTS5_CHART, 3);
    }
}
ok('all four seasons are filed', $have('spring') && $have('summer') && $have('autumn') && $have('winter'));
set_setting('season_force', ''); setting('__reload__');
$hid = '<input type="hidden" name="cat" value="all">';
ok('the Satchel offers "File in your Almanac" on the chart and "Open the bottle" on the bottle, nothing on a plain item', str_contains(implode('', sights5_satchel_acts(['slug' => SIGHTS5_CHART, 'id' => $chartId], $hid)), 'File in your Almanac') && str_contains(implode('', sights5_satchel_acts(['slug' => SIGHTS5_BOTTLE, 'id' => $id(SIGHTS5_BOTTLE)], $hid)), 'Open the bottle') && !sights5_satchel_acts(['slug' => 'acorn', 'id' => $id('acorn')], $hid));
ok('inventory.php routes do=sight_item', str_contains((string)file_get_contents(APP_ROOT . '/inventory.php'), "'sight_item'") && str_contains((string)file_get_contents(APP_ROOT . '/inventory.php'), 'sights5_use_item'));

echo "== message-bottle reads a note from the bottle post\n";
$setQty(SIGHTS5_BOTTLE, 2);
$bid = $id(SIGHTS5_BOTTLE);
$notesBefore = (int)q_val("SELECT COALESCE(SUM(ui.qty), 0) FROM user_items ui JOIN items i ON i.id = ui.item_id WHERE ui.user_id = ? AND i.slug LIKE 'bottle-note-%'", [$uid]);
[$a, $m] = sights5_use_item($row(), $bid);
$notesAfter = (int)q_val("SELECT COALESCE(SUM(ui.qty), 0) FROM user_items ui JOIN items i ON i.id = ui.item_id WHERE ui.user_id = ? AND i.slug LIKE 'bottle-note-%'", [$uid]);
ok('opening it: one bottle used, a bottle-note item in the satchel, the note read out', $a && $qty(SIGHTS5_BOTTLE) === 1 && $notesAfter === $notesBefore + 1 && str_contains($m, 'The note inside says'), $m);
ok('the text is not "washes up" (it is already in your hand)', !str_contains($m, 'washes up') && str_contains($m, 'pull the cork'));
[$a, $m] = sights5_use_item($row(), $bid); $setQty(SIGHTS5_BOTTLE, 0);
[$a3] = sights5_use_item($row(), $bid);
ok('a second bottle opens too; with none left it is refused', $a && !$a3);
ok('sights5_use_item refuses an item that has no use here', !sights5_use_item($row(), $id('acorn'))[0]);

echo "== page and files\n";
ok('lint of all Sights rows is clean after the data edits (the swap rows, hv=)', (function () { $bad = 0; foreach (trail_sights_all() as $r) if (trail_sight_lint($r)) $bad++; return $bad === 0; })());

echo $fails ? "$fails FAILED\n" : "ok\n";
exit($fails ? 1 : 0);
