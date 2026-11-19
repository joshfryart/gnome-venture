<?php
// Trail Sights engine gaps, fourth pass (game/includes/trail_sights_4.php): FOG (nxt=fog: the next stretch's finds are hidden until the gnome is next to them;
// nxt=lit: a lit path, no fog on this walk; setting trail_fog_weather), a NAMED stretch (sec=<route>.<stretch>:<effect>), PENALTIES (lose:time= lose:nxt= lose:sec=),
// a check whose difficulty depends on the conditions (sense:11?se=spring:9).
// php tests/trail_sights_282.php GAME_DIR   (an installed game, player "sprout"; walk.sh installs one). Model: tests/trail_sights_280.php.
$_SERVER['SCRIPT_NAME'] = '/adventure.php';
require $argv[1] . '/includes/bootstrap.php';
require_once $argv[1] . '/includes/adventure.php';
require_once $argv[1] . '/includes/trail_tiles.php';
require_once $argv[1] . '/includes/trail_sights.php';
require_once $argv[1] . '/includes/tools.php';
require_once $argv[1] . '/includes/stop_folk.php';
$fails = 0;
set_setting('npc_clockwork', '0'); set_setting('sights_walk_cap', '0');
$GLOBALS['gv_sights_nocache'] = true;
set_exception_handler(function (Throwable $e) { echo '  EXCEPTION ' . get_class($e) . ': ' . $e->getMessage() . ' @ ' . basename($e->getFile()) . ':' . $e->getLine() . "\n"; exit(1); });
function ok(string $what, bool $cond, string $extra = ''): void { global $fails; echo ($cond ? '  ok   ' : '  FAIL ') . $what . ($cond ? '' : "  $extra") . "\n"; if (!$cond) $fails++; }
$all = trail_sights_all(); $base = $all['grassland-the-clover-patch'];
$lintAll = fn(array $chg) => trail_sight_lint($chg + $base);
$lint = fn(array $chg, string $word) => array_values(array_filter(trail_sight_lint($chg + $base), fn($p) => str_contains($p, $word)));
$u = q_one("SELECT * FROM users WHERE username = 'sprout'");
$uid = (int)$u['id'];
$row = fn() => q_one('SELECT * FROM users WHERE id = ?', [$uid]);
$finds = fn(string $html) => substr_count($html, 'Something to find');
$logOf = fn(array $exp) => implode(' | ', (array)json_decode((string)$exp['log'], true));

echo "== lint\n";
ok('nxt=fog and nxt=lit are clean (with chance and condition)', !$lint(['rewards' => 'nxt=fog,nxt=lit@50,nxt=lit?dp=night'], 'nxt='), json_encode($lintAll(['rewards' => 'nxt=fog,nxt=lit@50,nxt=lit?dp=night'])));
ok('nxt=mist is refused', (bool)$lint(['rewards' => 'nxt=mist'], 'nxt='));
ok('sec=240.2:find / find:2 / calm / fog / quick:10 / skip are clean', !$lintAll(['rewards' => 'sec=240.2:find,sec=240.2:find:2@40,sec=240.3:calm?dp=night,sec=240.2:fog,sec=240.2:quick:10,sec=240.2:skip']), json_encode($lintAll(['rewards' => 'sec=240.2:find,sec=240.2:find:2@40,sec=240.3:calm?dp=night,sec=240.2:fog,sec=240.2:quick:10,sec=240.2:skip'])));
ok('sec= without a stretch, with peek or a bad effect is refused', count($lint(['rewards' => 'sec=240:find,sec=240.2:peek,sec=240.2:find:9,sec=240.0:find'], 'sec=')) === 4);
ok('sec= on a route that does not exist is refused', (bool)$lint(['rewards' => 'sec=9999.1:find'], 'does not exist'));
$r240 = q_one('SELECT * FROM routes WHERE id = 240'); $n240 = max(trail_sections($r240), trail_authored_count(240));
ok('sec= past the route\'s last stretch is refused (route 240 has ' . $n240 . ')', $n240 >= 6 || (bool)$lint(['rewards' => 'sec=240.' . ($n240 + 1) . ':find'], 'has only'));
ok('lose: on a row with a check is clean', !$lintAll(['check' => 'grit:10', 'lose' => 'No.', 'rewards' => 'xp=2,lose:time=20,lose:nxt=fog?we=fog,lose:sec=240.2:fog@50']), json_encode($lintAll(['check' => 'grit:10', 'lose' => 'No.', 'rewards' => 'xp=2,lose:time=20,lose:nxt=fog?we=fog,lose:sec=240.2:fog@50'])));
ok('lose: without a check is refused', (bool)$lint(['check' => '-', 'rewards' => 'xp=2,lose:time=20'], 'lose:'));
ok('lose: with a reward that is no penalty is refused', (bool)$lint(['check' => 'grit:10', 'lose' => 'No.', 'rewards' => 'lose:xp=5'], 'lose:') && (bool)$lint(['check' => 'grit:10', 'lose' => 'No.', 'rewards' => 'lose:item=acorn:1'], 'lose:'));
ok('lose: on a free pick (no wrong answer) is refused', (bool)$lint(['check' => 'pick:2:A;B', 'lose' => 'x', 'rewards' => 'choose=xp=1;xp=2,lose:time=5'], 'lose:'));
ok('time= out of range is refused, in range clean', (bool)$lint(['rewards' => 'time=900'], 'time=') && (bool)$lint(['rewards' => 'time=0'], 'time=') && !$lint(['rewards' => 'time=60'], 'time='));
ok('check sense:11?se=spring:9 and an either / or with one are clean', !$lintAll(['check' => 'sense:11?se=spring:9', 'lose' => 'No.']) && !$lintAll(['check' => 'nimble:9+sense:12?we=fog,rain/dp=night:14', 'lose' => 'No.']), json_encode($lintAll(['check' => 'nimble:9+sense:12?we=fog,rain/dp=night:14', 'lose' => 'No.'])));
ok('a check with a bad condition, stat or difficulty is refused', (bool)$lint(['check' => 'sense:11?zz=1:9', 'lose' => 'No.'], 'bad condition') && (bool)$lint(['check' => 'brawn:11?se=spring:9', 'lose' => 'No.'], 'check must') && (bool)$lint(['check' => 'sense:11?se=spring', 'lose' => 'No.'], 'check must') && (bool)$lint(['check' => 'sense:11?se=spring:40', 'lose' => 'No.'], 'check must'));
ok('a pick whose label has a ? still lints as a pick', !$lint(['check' => 'pick:2:Left?;Right', 'lose' => 'No.'], 'check'));

echo "== a check whose difficulty depends on the conditions\n";
$nowS = ['se' => 'spring', 'dp' => 'day', 'we' => 'sun']; $nowW = ['se' => 'winter', 'dp' => 'night', 'we' => 'fog'];
ok('sense:11?se=spring:9 is 9 in spring, 11 in winter', sights4_check_resolve('sense:11?se=spring:9', $nowS) === 'sense:9' && sights4_check_resolve('sense:11?se=spring:9', $nowW) === 'sense:11');
ok('either / or: only the half with a condition changes', sights4_check_resolve('nimble:9+sense:12?we=fog,rain/dp=night:14', $nowW) === 'nimble:9+sense:14' && sights4_check_resolve('nimble:9+sense:12?we=fog,rain/dp=night:14', $nowS) === 'nimble:9+sense:12');
ok('a plain check and a pick are left alone', sights4_check_resolve('grit:10', $nowS) === 'grit:10' && sights4_check_resolve('pick:2:Left?;Right', $nowS) === 'pick:2:Left?;Right' && sights4_check_resolve('-', $nowS) === '-');
ok('the card note: easier / harder / nothing', sights4_check_note('sense:11?se=spring:9', $nowS) === 'easier' && sights4_check_note('sense:12?we=fog:14', $nowW) === 'harder' && sights4_check_note('sense:11?se=spring:9', $nowW) === '');

echo "== the walk\n";
set_setting('gnav_on', '1'); set_setting('gnav_tiles', '1'); set_setting('game_clock_on', '1'); set_setting('weather_force', 'sun'); set_setting('trail_fog_weather', '0'); setting('__reload__');
$begin = function () use ($uid, $row) {
    q("UPDATE expeditions SET status = 'done' WHERE user_id = ?", [$uid]);
    q("UPDATE routes SET kind = 'road', steps = 5 WHERE id = 240");
    $r = q_one('SELECT * FROM routes WHERE id = 240');
    q("UPDATE users SET location_id = ?, level = 30, energy = 90, coins = 500, ev_quickwalk = 0, game_day = 10, game_minute = 360 WHERE id = ?", [$r['a_id'], $uid]);
    q('DELETE FROM trail_sight_uses WHERE user_id = ?', [$uid]); q('DELETE FROM trail_pickups WHERE user_id = ?', [$uid]);
    [$sok, $sm] = start_expedition($row(), 240);
    return [$sok, active_expedition($uid)];
};
[$sok, $exp] = $begin(); ok('the walk starts (5 stretches)', $sok && $exp);
$sc = trail_scene($exp);
$lm = array_values(array_filter($sc['map']['art']['objs'], fn($o) => $o[2] === 'lm-grassland-the-clover-patch'));
$spot = null; foreach ([[-1, 0], [1, 0], [0, -1], [0, 1], [0, 0]] as [$dx, $dy]) if (in_array(tm_tile($sc['map'], $lm[0][0] + $dx, $lm[0][1] + $dy), ['.', ',', 'S'], true)) { $spot = [$lm[0][0] + $dx, $lm[0][1] + $dy]; break; }
$sc['x'] = $spot[0]; $sc['y'] = $spot[1]; trail_save($sc);
trail_sights_ensure_tables();
$put = function (array $chg) use ($base) {
    $r = $chg + $base; q('DELETE FROM trail_sight_rows WHERE slug = ?', [$base['slug']]);
    db_insert('trail_sight_rows', ['slug' => $base['slug'], 'verb' => $r['verb'], 'icon' => $r['icon'], 'energy' => $r['energy'], 'cd' => $r['cd'], 'uses' => $r['uses'], 'cond' => $r['when'], 'chk' => $r['check'], 'rewards' => $r['rewards'], 'win' => $r['win'], 'lose' => $r['lose'], 'tool' => $r['tool'], 'fail_en' => $r['fail_en'], 'active' => 1]);
    q('DELETE FROM trail_sight_uses'); $GLOBALS['gv_sights_reload'] = true; trail_sights_all();
};
$use = function (array $opt = []) use (&$exp, $row, $base, $uid) { [$a, $m] = trail_sight_do($row(), $exp, $base['slug'], $opt); save_exp($exp); $exp = active_expedition($uid); return [$a, $m]; };

echo "== penalties: lose:\n";
$put(['when' => '-', 'energy' => 0, 'uses' => 9, 'check' => 'pick:3:Left;Middle;Right', 'lose' => 'Wrong door.', 'rewards' => 'xp=2']);
$right = trail_sight_pick_right($row(), trail_scene($exp), trail_sights_all()[$base['slug']]); $m0 = (int)$row()['game_minute'];
$use(['pick' => ($right + 1) % 3]); $plainCost = (int)$row()['game_minute'] - $m0;
$put(['when' => '-', 'energy' => 0, 'uses' => 9, 'check' => 'pick:3:Left;Middle;Right', 'lose' => 'Wrong door.', 'rewards' => 'xp=2,lose:time=20,lose:nxt=fog,lose:nxt=calm@0,lose:time=99?se=nosuch']);
$right = trail_sight_pick_right($row(), trail_scene($exp), trail_sights_all()[$base['slug']]); $m0 = (int)$row()['game_minute']; $xp0 = (int)$row()['xp'];
[$a] = $use(['pick' => $right]); $sc = trail_scene($exp);
ok('a win pays the win rewards and no penalty', $a && empty($sc['st']['nxt']) && (int)$row()['game_minute'] - $m0 === $plainCost && !str_contains($logOf($exp), 'lost'), json_encode([$sc['st']['nxt'] ?? null, (int)$row()['game_minute'] - $m0, $plainCost]));
$right = trail_sight_pick_right($row(), trail_scene($exp), trail_sights_all()[$base['slug']]); $m0 = (int)$row()['game_minute']; $xp1 = (int)$row()['xp'];
[$a] = $use(['pick' => ($right + 1) % 3]); $sc = trail_scene($exp);
ok('a lost check: lose:time=20 takes 20 more game minutes', $a && (int)$row()['game_minute'] - $m0 === $plainCost + 20, ((int)$row()['game_minute'] - $m0) . ' vs ' . $plainCost . ' + 20');
ok('... lose:nxt=fog waits for the next stretch; the @0 and the unmet ?cond ones do not pay', ($sc['st']['nxt'] ?? []) === ['fog'], json_encode($sc['st']['nxt'] ?? null));
ok('... no win reward, and the log says the lose line with the penalties', (int)$row()['xp'] === $xp1 && str_contains($logOf($exp), 'Wrong door. (⏱️ 20 min lost, 🌫️ Fog settles on the next stretch'), $logOf($exp));

echo "== fog\n";
ok('peek cannot see into a foggy stretch', str_contains(sights3a_nxt_add($row(), 'peek'), 'lies in fog'));
$html0 = trail_view_html($row(), $exp, trail_scene($exp), false);
ok('the stretch you stand in is not foggy yet', !str_contains($html0, 'Fog: finds show'));
$sc = trail_scene($exp); $sc['st']['phase'] = 'confirm'; trail_save($sc);
[$nok, $nm] = trail_next($row(), $exp); save_exp($exp); $exp = active_expedition($uid); $sc = trail_scene($exp);
ok('on to stretch 2: it is in fog, the pending effect is used up', $nok && ($sc['st']['fog'] ?? []) === [1] && empty($sc['st']['nxt']) && sights4_fog_on($sc['st']), json_encode([$nm, $sc['st']['fog'] ?? null, $sc['st']['nxt'] ?? null]));
ok('the log says so', str_contains($logOf($exp), 'Fog lies on this stretch'), $logOf($exp));
$exp['encounter'] = null; q('UPDATE expeditions SET encounter = NULL WHERE id = ?', [$exp['id']]); $exp = active_expedition($uid);
$fl = array_values(array_filter($sc['st']['tokens'], fn($t) => $t[2] === 'F' && (int)$t[3] === 0));
$far = array_values(array_filter($fl, fn($t) => max(abs($t[0] - $sc['x']), abs($t[1] - $sc['y'])) > 1));
ok('stretch 2 has finds away from the way in (' . count($far) . ' of ' . count($fl) . ')', count($far) >= 1, json_encode($sc['st']['tokens']));
// the page draws a 7 x 7 window round the gnome: stand two tiles from a find (in the window, not next to it) and count the find buttons
$expect = function (array $scx, bool $fog) use ($fl) {
    $win = tm_window_clamped($scx['x'], $scx['y'], DM_VIEW, DM_VIEW, (int)$scx['map']['w'], (int)$scx['map']['h']);
    return count(array_filter($fl, fn($t) => $t[0] >= $win['x0'] && $t[0] < $win['x0'] + DM_VIEW && $t[1] >= $win['y0'] && $t[1] < $win['y0'] + DM_VIEW && !($t[0] === $scx['x'] && $t[1] === $scx['y'])
        && (!$fog || max(abs($t[0] - $scx['x']), abs($t[1] - $scx['y'])) <= 1)));
};
$f = $far[0]; $two = null; $nb = null;
for ($dy = -2; $dy <= 2; $dy++) for ($dx = -2; $dx <= 2; $dx++) {
    $x = $f[0] + $dx; $y = $f[1] + $dy; $d = max(abs($dx), abs($dy));
    if ($d < 1 || !in_array(tm_tile($sc['map'], $x, $y), ['.', ',', 'S'], true) || trail_token_at($sc, $x, $y) >= 0) continue;
    if ($d === 2 && !$two && !array_filter($fl, fn($t) => max(abs($t[0] - $x), abs($t[1] - $y)) <= 1)) $two = [$x, $y];
    if ($d === 1 && !$nb) $nb = [$x, $y];
}
ok('there is floor two tiles from a find and floor beside it', $two && $nb, json_encode([$f, $two, $nb]));
$scTwo = $sc; [$scTwo['x'], $scTwo['y']] = $two; $scClear = $scTwo; unset($scClear['st']['fog']);
$htmlFog = trail_view_html($row(), $exp, $scTwo, false); $htmlClear = trail_view_html($row(), $exp, $scClear, false);
ok('without fog the map marks the finds in view (' . $finds($htmlClear) . ')', $finds($htmlClear) === $expect($scClear, false) && $finds($htmlClear) >= 1, $finds($htmlClear) . ' vs ' . $expect($scClear, false));
ok('in fog a find two tiles away is not marked (' . $finds($htmlFog) . ' show)', $finds($htmlFog) === 0 && $expect($scTwo, true) === 0, $finds($htmlFog) . ' vs ' . $expect($scTwo, true));
$drawn = fn(string $h) => preg_match_all('~(find-[a-z]+\.png|>✨<)~u', $h);   // the baked look draws a find picture, the plain look a ✨ text mark
ok('... and not drawn in the picture either', $drawn($htmlFog) < $drawn($htmlClear), $drawn($htmlFog) . ' vs ' . $drawn($htmlClear));
ok('the legend explains the fog', str_contains($htmlFog, 'Fog: finds show when you are next to them') && !str_contains($htmlClear, 'Fog: finds show'));
$scNb = $sc; [$scNb['x'], $scNb['y']] = $nb;
ok('standing next to a hidden find shows it', $finds(trail_view_html($row(), $exp, $scNb, false)) === $expect($scNb, true) && $expect($scNb, true) >= 1, $finds(trail_view_html($row(), $exp, $scNb, false)) . ' vs ' . $expect($scNb, true));
$saved = count(array_filter(trail_scene($exp)['st']['tokens'], fn($t) => $t[2] === 'F' && (int)$t[3] === 0));
ok('the saved walk still has every find (the fog only hides them)', $saved === count($fl));
$path = tm_path($sc['map'], $sc['x'], $sc['y'], (int)$f[0], (int)$f[1], trail_gate($sc, (int)$f[0], (int)$f[1]));
if ($path) {
    [$gok, $gm] = trail_go($row(), $exp, (int)$f[0], (int)$f[1]); save_exp($exp); $exp = active_expedition($uid); $sc = trail_scene($exp);
    $at = trail_token_at($sc, $sc['x'], $sc['y']);
    ok('walking onto a hidden find still picks it up', $gok && ($sc['x'] !== (int)$f[0] || $sc['y'] !== (int)$f[1] || ($at >= 0 && (int)$sc['st']['tokens'][$at][3] === 1)), json_encode([$gm, $sc['x'], $sc['y'], $f]));
    q('UPDATE expeditions SET encounter = NULL WHERE id = ?', [$exp['id']]); $exp = active_expedition($uid);
} else ok('a way to the hidden find', false, json_encode($f));
$sc = trail_scene($exp); $sc['x'] = (int)$sc['map']['entry'][0]; $sc['y'] = (int)$sc['map']['entry'][1]; $sc['st']['phase'] = 'section'; trail_save($sc);
[$pok] = trail_prev($row(), $exp); save_exp($exp); $exp = active_expedition($uid); $sc = trail_scene($exp);
ok('walking back: stretch 1 is clear, the walk remembers stretch 2 is foggy', $pok && ($sc['st']['fog'] ?? []) === [1] && !sights4_fog_on($sc['st']), json_encode($sc['st']['fog'] ?? null));
[$nok] = trail_next($row(), $exp); save_exp($exp); $exp = active_expedition($uid); $sc = trail_scene($exp);
ok('... and it is still foggy when you come back to it', $nok && sights4_fog_on($sc['st']));
q('UPDATE expeditions SET encounter = NULL WHERE id = ?', [$exp['id']]); $exp = active_expedition($uid);
$line = sights3a_nxt_add($row(), 'lit'); $sc = trail_scene($exp);
ok('nxt=lit: the fog on this stretch lifts', str_contains($line, 'The path is lit') && str_contains($line, 'draws back') && !sights4_fog_on($sc['st']) && !empty($sc['st']['lit']), $line);
ok('... the map shows every find again', count(sights4_fog_view($sc)['st']['tokens']) === count($sc['st']['tokens']) && !str_contains(trail_view_html($row(), $exp, $sc, false), 'Fog: finds show'));
$line = sights3a_nxt_add($row(), 'fog'); $sc = trail_scene($exp);
ok('a new fog cannot settle on a lit path', str_contains($line, 'lit path keeps it off') && empty($sc['st']['nxt']), $line);
$sc['st']['phase'] = 'confirm'; trail_save($sc); [$nok] = trail_next($row(), $exp); save_exp($exp); $exp = active_expedition($uid); $sc = trail_scene($exp);
ok('the lit path walks on into stretch 3', $nok && (int)$sc['st']['sec'] === 2 && !empty($sc['st']['lit']) && !sights4_fog_on($sc['st']));
q('UPDATE expeditions SET encounter = NULL WHERE id = ?', [$exp['id']]); $exp = active_expedition($uid);

echo "== foggy weather (setting trail_fog_weather)\n";
set_setting('weather_force', 'fog'); setting('__reload__');
[$sok, $exp] = $begin(); $sc = trail_scene($exp);
ok('setting off (the default): foggy weather leaves the Trail clear', $sok && !sights4_fog_on($sc['st']) && (settings_schema()['trail_fog_weather']['default'] ?? '') === '0', json_encode($sc['st']['fog'] ?? null));
set_setting('trail_fog_weather', '1'); setting('__reload__');
[$sok, $exp] = $begin(); $sc = trail_scene($exp);
ok('setting on: the first stretch of a walk in foggy weather is in fog, and the log says so', $sok && sights4_fog_on($sc['st']) && str_contains($logOf($exp), 'Fog lies on the Trail today'), json_encode([$sc['st']['fog'] ?? null, $logOf($exp)]));
$sc['st']['phase'] = 'confirm'; trail_save($sc); [$nok] = trail_next($row(), $exp); save_exp($exp); $exp = active_expedition($uid); $sc = trail_scene($exp);
ok('... and so is the next one', $nok && ($sc['st']['fog'] ?? []) === [0, 1] && sights4_fog_on($sc['st']), json_encode($sc['st']['fog'] ?? null));
q('UPDATE expeditions SET encounter = NULL WHERE id = ?', [$exp['id']]); $exp = active_expedition($uid);
sights3a_nxt_add($row(), 'lit'); $sc = trail_scene($exp); $sc['st']['phase'] = 'confirm'; trail_save($sc);
[$nok] = trail_next($row(), $exp); save_exp($exp); $exp = active_expedition($uid); $sc = trail_scene($exp);
ok('a lit path keeps the weather\'s fog off the stretches after it', $nok && (int)$sc['st']['sec'] === 2 && !sights4_fog_on($sc['st']) && ($sc['st']['fog'] ?? []) === [0, 1], json_encode($sc['st']['fog'] ?? null));
set_setting('weather_force', 'sun'); set_setting('trail_fog_weather', '0'); setting('__reload__');

echo "== a named stretch: sec=\n";
q("DELETE FROM trail_sight_tally WHERE user_id = ? AND tkey LIKE 'sec#%'", [$uid]);
[$sok, $exp] = $begin(); $sc = trail_scene($exp);
$sc['x'] = $spot[0]; $sc['y'] = $spot[1]; trail_save($sc);
$put(['when' => '-', 'energy' => 0, 'uses' => 9, 'check' => '-', 'rewards' => 'sec=240.3:find:2,sec=240.3:fog,sec=240.1:find,sec=240.2:calm@0']);
[$a, $m] = $use(); $t = trail_sight_tallies($uid);
ok('the Sight is used and the effects wait for their stretches', $a && ($t['sec#240#3#find'] ?? 0) === 2 && ($t['sec#240#3#fog'] ?? 0) === 1 && ($t['sec#240#1#find'] ?? 0) === 1 && !isset($t['sec#240#2#calm']), json_encode([$m, array_filter($t, fn($k) => str_starts_with((string)$k, 'sec#'), ARRAY_FILTER_USE_KEY)]));
$rn = sights4_route_name(240);
ok('the log names the stretch and the Trail', $rn !== '' && str_contains($logOf($exp), '2 finds wait on stretch 3 of ' . $rn) && str_contains($logOf($exp), 'Fog is settling on stretch 3 of ' . $rn), $logOf($exp));
ok('a smaller find count does not replace a bigger one', sights4_sec_add($row(), '240.3:find') !== '' && (trail_sight_tallies($uid)['sec#240#3#find'] ?? 0) === 2);
[, $tk1] = trail_map_make(trail_seed(240, $uid, (int)($sc['st']['sx'] ?? $exp['id']), 1, $sc['st'])); $base1 = count(array_filter($tk1, fn($t) => $t[2] === 'F'));
[, $tk2] = trail_map_make(trail_seed(240, $uid, (int)($sc['st']['sx'] ?? $exp['id']), 2, $sc['st'])); $base2 = count(array_filter($tk2, fn($t) => $t[2] === 'F'));
$sc = trail_scene($exp); $sc['st']['phase'] = 'confirm'; trail_save($sc); [$nok] = trail_next($row(), $exp); save_exp($exp); $exp = active_expedition($uid); $sc = trail_scene($exp);
ok('stretch 2 is not the named one: nothing happens there', $nok && count(array_filter($sc['st']['tokens'], fn($t) => $t[2] === 'F')) === $base1 && !sights4_fog_on($sc['st']) && (trail_sight_tallies($uid)['sec#240#3#find'] ?? 0) === 2);
q('UPDATE expeditions SET encounter = NULL WHERE id = ?', [$exp['id']]); $exp = active_expedition($uid);
$sc['st']['phase'] = 'confirm'; trail_save($sc); [$nok] = trail_next($row(), $exp); save_exp($exp); $exp = active_expedition($uid); $sc = trail_scene($exp);
ok('stretch 3, the named one: 2 more finds and fog', $nok && (int)$sc['st']['sec'] === 2 && count(array_filter($sc['st']['tokens'], fn($t) => $t[2] === 'F')) === $base2 + 2 && sights4_fog_on($sc['st']), json_encode([$base2, $sc['st']['tokens'], $sc['st']['fog'] ?? null]));
$t = trail_sight_tallies($uid);
ok('used up there; the one for stretch 1 still waits', !isset($t['sec#240#3#find']) && !isset($t['sec#240#3#fog']) && ($t['sec#240#1#find'] ?? 0) === 1, json_encode(array_filter($t, fn($k) => str_starts_with((string)$k, 'sec#'), ARRAY_FILTER_USE_KEY)));
[$sok, $exp] = $begin(); $sc = trail_scene($exp);
[, $tk0] = trail_map_make(trail_seed(240, $uid, (int)($sc['st']['sx'] ?? $exp['id']), 0, $sc['st'])); $base0 = count(array_filter($tk0, fn($t) => $t[2] === 'F'));
ok('the NEXT walk of that route starts with the find on its first stretch, told in the log', $sok && count(array_filter($sc['st']['tokens'], fn($t) => $t[2] === 'F')) === $base0 + 1 && str_contains($logOf($exp), 'A find waits on this stretch, as you were told') && !isset(trail_sight_tallies($uid)['sec#240#1#find']), json_encode([$base0, $sc['st']['tokens'], $logOf($exp)]));
sights4_sec_add($row(), '240.1:skip'); [$sok, $exp] = $begin();
ok('skip / calm / quick aimed at a walk\'s first stretch wait for a walk that comes into it from another stretch', (trail_sight_tallies($uid)['sec#240#1#skip'] ?? 0) === 1 && trail_scene($exp)['st']['phase'] === 'section');
ok('a route that does not exist says nothing and keeps nothing', sights4_sec_add($row(), '9999.1:find') === '' && !isset(trail_sight_tallies($uid)['sec#9999#1#find']));

echo "== a condition check in use\n";
$se = hollow_season(); $other = $se === 'spring' ? 'summer' : 'spring';
$sc = trail_scene($exp); $sc['x'] = $spot[0]; $sc['y'] = $spot[1]; trail_save($sc);
$put(['when' => '-', 'energy' => 0, 'uses' => 9, 'check' => 'luck:25?se=' . $se . ':0', 'lose' => 'It slips away.', 'rewards' => 'xp=2']);
$n0 = substr_count($logOf($exp), 'It slips away');
for ($i = 0; $i < 6; $i++) $use();
ok('luck:25?se=<this season>:0 is a sure thing this season (6 of 6 wins)', substr_count($logOf($exp), 'It slips away') === $n0, $logOf($exp));
$cards = trail_sights_cards_html($row(), trail_scene($exp), trail_sights_marks($row(), trail_scene($exp)), $exp);
ok('the card says the check is easier right now', str_contains($cards, 'Luck (easier right now)'), substr(strip_tags($cards), 0, 300));
$put(['when' => '-', 'energy' => 0, 'uses' => 9, 'check' => 'luck:11?se=' . $other . ':0', 'lose' => 'It slips away.', 'rewards' => 'xp=2']);
$cards = trail_sights_cards_html($row(), trail_scene($exp), trail_sights_marks($row(), trail_scene($exp)), $exp);
ok('in another season the card shows the plain check', str_contains($cards, '🎲 Luck') && !str_contains($cards, 'right now'), substr(strip_tags($cards), 0, 300));

echo "== a shortcut never passes a waiting fight; a peek with nothing ahead says nothing\n";
$sc = trail_scene($exp); $mp = $sc['map'];
$old = ['st' => ['nxt' => ['skip']]]; $new = ['st' => ['sec' => 1, 'S' => 5, 'sx' => 1, 'phase' => 'section', 'tokens' => [[3, 3, 'E', 0]]], 'x' => 1, 'y' => 1, 'seen' => tm_seen_new($mp['w'], $mp['h'])];
$done = sights3a_nxt_prepare($old, $new, $mp, false);
ok('nxt=skip onto a stretch with a fight that waits: no skip', $done === ['skip:blocked'] && $new['st']['phase'] === 'section' && $new['x'] === 1, json_encode([$done, $new['st']['phase'], $new['x']]));
$lg = ['log' => '[]']; sights3a_nxt_finish($row(), $lg, $done);
ok('... and the log says why', str_contains((string)$lg['log'], 'a fight waits on this stretch'), (string)$lg['log']);
$new = ['st' => ['sec' => 1, 'S' => 5, 'sx' => 1, 'phase' => 'section', 'tokens' => [[3, 3, 'E', 1]]], 'x' => 1, 'y' => 1, 'seen' => tm_seen_new($mp['w'], $mp['h'])];
$done = sights3a_nxt_prepare($old, $new, $mp, false);
ok('once the fight is done the shortcut works', $done === ['skip'] && $new['st']['phase'] === 'confirm');
$sc['st']['sec'] = (int)$sc['st']['S'] - 1; trail_save($sc);
ok('nxt=peek on the last stretch says nothing; nxt=find still says no stretch is left', sights3a_nxt_add($row(), 'peek') === '' && str_contains(sights3a_nxt_add($row(), 'find'), 'No stretch is left'));

echo "== the data rows that use this pass and the older tokens the todo lists named\n";
$GLOBALS['gv_sights_reload'] = true; q('DELETE FROM trail_sight_rows WHERE slug = ?', [$base['slug']]); $file = trail_sights_file();
$has = fn(string $slug, string $tok) => isset($file[$slug]) && in_array($tok, array_map(fn($t) => ($t['lose'] ? 'lose:' : '') . $t['tok'] . ($t['cond'] !== '' ? '?' . $t['cond'] : ''), trail_sight_tokens($file[$slug]['rewards'])), true);
ok('the Lantern Path: the lantern fruit lights the path at night', $has('rainforest-the-lantern-fruit', 'nxt=lit?dp=night'));
ok('named stretches: the shell hollow, the star stones, the birch tunnel', $has('307-shellhollow', 'sec=314.2:find@50?dp=night') && $has('316-starstones', 'sec=309.2:find?dp=night/se=winter') && $has('305-birchtunnel', 'sec=305.2:find@40') && $has('305-birchtunnel', 'sec=312.1:find@40?we=fog'));
ok('the bluebells are easier to hear in spring', $file['forest-the-bluebell-glade']['check'] === 'sense:11?se=spring:9');
ok('game time: hay nap 60, stone hut 60, awning 120, causeway 20, windmill 30 without wind, a storm headwind 15', $has('haybales', 'time=60') && $has('mountain-the-stone-hut', 'time=60') && $has('desert-the-shade-awning', 'time=120') && $has('314-causeway', 'time=20') && $has('236-windmill', 'time=30?we=sun,cloud,rain,fog,frost,heat,snow') && $has('mountain-the-wind-notch', 'time=15?we=storm'));
ok('next-stretch effects: dandelions find, toad steps peek, drift pass and stick gate quicker, rowboat hop, first star', $has('236-dandelions', 'nxt=find@40') && $has('306-toadsteps', 'nxt=peek') && $has('310-driftpass', 'nxt=quick:10') && $has('313-stickgate', 'nxt=quick:15') && $has('coast-the-stranded-rowboat', 'nxt=skip?dp=dawn/ti=high') && $has('end-wonder-2-island', 'nxt=quick:10'));
ok('buffs: toad ring +1 to every stat, lantern rocks a second buff in fog, the delve lantern line lasts for the delve', $has('312-toadring', 'buff=all:1:10') && $has('314-lanternrocks', 'buff2=luck:1:120?we=fog') && $has('end-delve-2-forest', 'buff=sense:1:delve') && $has('end-delve-2-wetland', 'buff=luck:1:delve') && $has('end-delve-2-rainforest', 'buff=sense:1:delve'));
ok('any-kind takes, after-quest forecast, inn discounts', $has('312-larder', 'take=any-nut:1') && $has('315-cairns', 'take=any-feather:1') && $has('grassland-the-wind-combed-meadow', 'hint=weather?qd=runaway-kite') && $has('end-haven-1-grassland', 'disc=rest:10:180') && $has('end-haven-1-island', 'disc=rest:25:180'));
$folk = trail_sight_folk(); $frow = fn(string $slug, string $who, string $tok) => (bool)array_filter($folk[$slug] ?? [], fn($f) => str_starts_with($f['who'], $who) && str_contains(',' . $f['rewards'] . ',', ',' . $tok . ','));
ok('villagers: Tobias 10% off, Bunty an inn voucher, Mabel a hay-ride, the boat gnome a short hop, Marrowby weekly after his line', $frow('232-crossroads', 'Tobias Trundle', 'disc=shop:10:60') && $frow('307-sandcastle', 'Bunty Brambleby', 'disc=rest:25:240') && $frow('grassland-the-hay-cart-ruts', 'Mabel Mossgrove', 'nxt=quick:10') && $frow('end-haven-1-wetland', 'Bramwick Pennywhistle', 'nxt=skip')
    && (bool)array_filter($folk['desert-the-trader-s-tent-poles'] ?? [], fn($f) => $f['when'] === 'gd=7:0/qd=trader-went-home'));

q('DELETE FROM trail_sight_rows WHERE slug = ?', [$base['slug']]);
q("DELETE FROM trail_sight_tally WHERE user_id = ? AND tkey LIKE 'sec#%'", [$uid]);
q("UPDATE expeditions SET status = 'done' WHERE user_id = ?", [$uid]);
echo $fails ? "$fails FAILED\n" : "ok\n";
exit($fails ? 1 : 0);
