<?php
// 2.8.99 Sights v2 (game/includes/trail_sights_v2.php, claude/proposal-sights-rework.md slices 1 and 2): the setting, the new card, a tap on the picture, the no-fail rule,
// the result card, the rest in sleeps. Setting off = the old Sights (a miss pays nothing and a slip costs energy).
// php tests/sights_v2.php GAME_DIR   (an installed game, player "sprout"; walk.sh installs one). Model: tests/trail_sights_284.php.
$_SERVER['SCRIPT_NAME'] = '/adventure.php';
require $argv[1] . '/includes/bootstrap.php';
require_once $argv[1] . '/includes/adventure.php';
require_once $argv[1] . '/includes/trail_tiles.php';
require_once $argv[1] . '/includes/trail_sights.php';
require_once $argv[1] . '/includes/tools.php';
require_once $argv[1] . '/includes/gathering.php';
$fails = 0;
if (session_status() !== PHP_SESSION_ACTIVE) @session_start();
set_setting('npc_clockwork', '0'); set_setting('sights_walk_cap', '6');
$GLOBALS['gv_sights_nocache'] = true;
set_exception_handler(function (Throwable $e) { echo '  EXCEPTION ' . get_class($e) . ': ' . $e->getMessage() . ' @ ' . basename($e->getFile()) . ':' . $e->getLine() . "\n"; echo "FAILED\n"; exit(1); });
function t(string $what, callable $f): void { try { $r = $f(); ok($what, $r === true, is_string($r) ? $r : json_encode($r)); } catch (Throwable $e) { ok($what, false, get_class($e) . ': ' . $e->getMessage() . ' @ ' . basename($e->getFile()) . ':' . $e->getLine()); } }
function ok(string $what, bool $cond, string $extra = ''): void { global $fails; echo ($cond ? '  ok   ' : '  FAIL ') . $what . ($cond ? '' : "  $extra") . "\n"; if (!$cond) $fails++; }
$all = trail_sights_all(); $base = $all['grassland-the-clover-patch'];
$u = q_one("SELECT * FROM users WHERE username = 'sprout'");
$uid = (int)$u['id'];
$row = fn() => q_one('SELECT * FROM users WHERE id = ?', [$uid]);
$v2 = function (bool $on) { set_setting('sights_v2_open', $on ? '1' : '0'); setting('__reload__'); };

echo "== the setting\n";
t('sights_v2_open defaults to 0 (Off), with a plain label', fn() => (settings_schema()['sights_v2_open']['default'] ?? '') === '0' && str_contains(settings_schema()['sights_v2_open']['label'] ?? '', 'Off = Sights as before') ? true : setting('sights_v2_open'));

echo "== the walk\n";
set_setting('gnav_on', '1'); set_setting('gnav_tiles', '1'); set_setting('game_clock_on', '1'); set_setting('weather_force', 'sun'); setting('__reload__');
q("UPDATE expeditions SET status = 'done' WHERE user_id = ?", [$uid]);
q("UPDATE routes SET kind = 'road', steps = 5 WHERE id = 240");
$r240 = q_one('SELECT * FROM routes WHERE id = 240');
q("UPDATE users SET location_id = ?, level = 30, energy = 90, coins = 500, ev_quickwalk = 0, game_day = 10, game_minute = 720, stat_grit = 1, stat_nimble = 1, stat_sense = 1 WHERE id = ?", [$r240['a_id'], $uid]);
q('DELETE FROM trail_sight_uses WHERE user_id = ?', [$uid]); q('DELETE FROM trail_pickups WHERE user_id = ?', [$uid]);
[$sok] = start_expedition($row(), 240); $exp = active_expedition($uid);
ok('the walk starts', $sok && $exp);
$sc = trail_scene($exp);
$lm = array_values(array_filter($sc['map']['art']['objs'], fn($o) => $o[2] === 'lm-grassland-the-clover-patch'));
$spot = null; foreach ([[-1, 0], [1, 0], [0, -1], [0, 1], [0, 0]] as [$dx, $dy]) if (in_array(tm_tile($sc['map'], $lm[0][0] + $dx, $lm[0][1] + $dy), ['.', ',', 'S'], true)) { $spot = [$lm[0][0] + $dx, $lm[0][1] + $dy]; break; }
$start = [(int)$sc['x'], (int)$sc['y']];
trail_sights_ensure_tables();
$put = function (array $chg) use ($base) {
    $r = $chg + $base; q('DELETE FROM trail_sight_rows WHERE slug = ?', [$base['slug']]);
    db_insert('trail_sight_rows', ['slug' => $base['slug'], 'verb' => $r['verb'], 'icon' => $r['icon'], 'energy' => $r['energy'], 'cd' => $r['cd'], 'uses' => $r['uses'], 'cond' => $r['when'], 'chk' => $r['check'], 'rewards' => $r['rewards'], 'win' => $r['win'], 'lose' => $r['lose'], 'tool' => $r['tool'], 'fail_en' => $r['fail_en'], 'active' => 1]);
    q('DELETE FROM trail_sight_uses'); $GLOBALS['gv_sights_reload'] = true; trail_sights_all();
};
$place = function (array $xy) use (&$exp, $uid) { $s = trail_scene($exp); $s['x'] = $xy[0]; $s['y'] = $xy[1]; trail_save($s); $exp = active_expedition($uid); };
$place($spot);
$use = function (array $opt = []) use (&$exp, $row, $base, $uid) { [$a, $m] = trail_sight_do($row(), $exp, $base['slug'], $opt); save_exp($exp); $exp = active_expedition($uid); return [$a, $m]; };
$lastLog = function () use (&$exp) { $l = (array)json_decode((string)$exp['log'], true); return (string)end($l); };
$card = function () use (&$exp, $row, $base) { $s = trail_scene($exp); $mk = array_values(array_filter(trail_sights_marks($row(), $s), fn($m) => $m['slug'] === $base['slug'])); return sights_v2_cards_html($row(), $s, $mk, $exp); };
$std = ['when' => '-', 'energy' => 1, 'uses' => 1, 'cd' => 55, 'tool' => '-', 'fail_en' => 0, 'verb' => 'Pick'];

echo "== off: the old Sights, unchanged\n";
$v2(false);
$put(['check' => 'sense:40', 'rewards' => 'c=20', 'fail_en' => 2, 'win' => 'WINLINE', 'lose' => 'LOSELINE'] + $std);
q('UPDATE users SET energy = 50, coins = 500 WHERE id = ?', [$uid]);
[$a] = $use();
ok('off: a missed check pays nothing and the slip costs 2 energy', $a && (int)$row()['coins'] === 500 && (int)$row()['energy'] === 47 && str_contains($lastLog(), 'LOSELINE'), 'coins ' . $row()['coins'] . ' energy ' . $row()['energy'] . ' ' . $lastLog());
$s = trail_scene($exp); $html = trail_sights_cards_html($row(), $s, trail_sights_marks($row(), $s), $exp);
ok('off: the old card (no v2 card, the old cost line)', !str_contains($html, 'sgv2') && str_contains($html, 'sgdo'), substr(strip_tags($html), 0, 200));
ok('off: no picture taps on the map', !str_contains(trail_view_html($row(), $exp, trail_scene($exp), false, false), 'name="gosg"'));
$put(['check' => '-', 'tool' => 'bucket:3', 'rewards' => 'c=20'] + $std);
ok('off: sights_v2_on() is false', sights_v2_on() === false);
ok('off: the toast is never left out', !sights_v2_quiet_toast('9:4:123', true) && !sights_v2_quiet_toast('9:4:123', false));
ok('off: a tool Sight without the tool is refused', !$use()[0]);

echo "== on: the card (all rows)\n";
$v2(true);
$words = SIGHTS_V2_GIVE_WORDS; $badG = [];
foreach ($all as $slug => $r) { $g = sights_v2_gives($r); if (!$g || count($g) > 3 || array_diff($g, $words)) $badG[] = $slug . ':' . implode('/', $g); }
ok('all ' . count($all) . ' rows: 1 to 3 Gives words, all from the list of seven', count($all) >= 219 && !$badG, implode(' ', array_slice($badG, 0, 8)));
$s = trail_scene($exp); $mk0 = trail_sights_marks($row(), $s)[0] ?? null; $badC = [];
$locX = q_one('SELECT * FROM locations WHERE id = ?', [(int)$exp['from_id']]) ?: [];
foreach ($all as $slug => $r) {
    $h = sights_v2_card_html($row(), $s, ['x' => $mk0['x'], 'y' => $mk0['y'], 'slug' => $slug, 'row' => $r, 'left' => 1, 'why' => ''], $locX, true, $exp);
    $info = substr_count($h, 'class="sgv2l'); $txt = strip_tags($h);
    if ($info < 2 || $info > 4 || !str_contains($h, 'Gives:') || preg_match('/again soon|\d+ min\b|step \d+ of \d+|Grows back/', $txt) || substr_count($h, '<form') > 2) $badC[] = $slug . " ($info)";
}
ok('every row: a card of 2 to 4 info lines with a Gives line, no timetable words ("again soon", "10 min", "step 4 of 7")', !$badC, implode(' ', array_slice($badC, 0, 8)));
$put(['check' => '-', 'rewards' => 'xp=2,c=7,item=white-clover-seed:1@30', 'win' => 'WINLINE', 'lose' => 'LOSELINE'] + $std);
q('DELETE FROM trail_sight_first WHERE user_id = ?', [$uid]);
$h = $card();
ok('the card: name, one line, Gives in plain words, one button with verb and noun', str_contains($h, '<h4>') && str_contains($h, 'Gives:</b> seeds, Petals, know-how') && substr_count($h, '<button') === 1 && (bool)preg_match('/Pick the [a-z]/', strip_tags($h)), strip_tags($h));
ok('first visit: the Almanac line', str_contains($h, 'First visit: a new page for Wren'), strip_tags($h));
$place($start); $h = $card(); $place($spot);
ok('not beside it: the same one button walks there (gosg), no "Walk there" second button', str_contains($h, 'name="gosg" value="' . $base['slug'] . '"') && substr_count($h, '<button') === 1, strip_tags($h));
$put(['when' => 'dp=dusk', 'check' => '-', 'rewards' => 'c=7'] + $std);
$h = $card(); ok('a Sight waiting for its time: one plain line, no button', str_contains($h, 'Comes out at dusk.') && !str_contains($h, '<button'), strip_tags($h));
t('the foot button: verb and noun beside a ready Sight', function () use (&$exp, $row, $put, $std) { $put(['check' => '-', 'rewards' => 'c=7'] + $std); $s = trail_scene($exp); $f = sights_v2_foot_html($row(), $s, trail_sights_marks($row(), $s)); return str_contains($f, 'data-pop="hubpop-tsights"') && str_contains($f, 'Pick the ') && str_contains($f, 'sgs=') ? true : $f; });
t('the map: the picture tiles carry the Sight (gosg) and say its name', function () use (&$exp, $row, $base) { $h = trail_view_html($row(), $exp, trail_scene($exp), false, false); return str_contains($h, 'name="gosg" value="' . $base['slug'] . '"') && str_contains($h, ': go and look') ? true : 'no gosg'; });
t('sights_v2_walk_target: none when beside it; a standable tile when far', function () use (&$exp, $lm, $start) { $s = trail_scene($exp); $s2 = $s; $s2['x'] = $start[0]; $s2['y'] = $start[1]; $tg = sights_v2_walk_target($s2, $lm[0][0], $lm[0][1]); return sights_v2_walk_target($s, $lm[0][0], $lm[0][1]) === null && $tg && max(abs($tg[0] - $lm[0][0]), abs($tg[1] - $lm[0][1])) <= 1 ? true : json_encode($tg); });
t('a tap on the picture from afar: the gnome walks there (trail_go)', function () use (&$exp, $row, $base, $place, $start, $lm, $uid) {
    $place($start); [$a, $m] = sights_v2_go($row(), $exp, $base['slug']); save_exp($exp); $exp = active_expedition($uid); $s = trail_scene($exp);
    $near = max(abs((int)$s['x'] - $lm[0][0]), abs((int)$s['y'] - $lm[0][1])) <= 1;
    return $a && ($near || !empty($exp['encounter'])) ? true : json_encode([$a, $m, $s['x'], $s['y']]);
});
if (!empty($exp['encounter'])) { $exp['encounter'] = null; save_exp($exp); $exp = active_expedition($uid); }
$place($spot);

echo "== on: no fail\n";
$put(['check' => '-', 'rewards' => 'c=20,xp=10', 'win' => 'WINLINE', 'lose' => 'LOSELINE'] + $std);
q('UPDATE users SET energy = 50, coins = 500 WHERE id = ?', [$uid]);
[$a] = $use(); $full = (int)$row()['coins'] - 500;
ok('no check: full pay, energy = the cost', $a && $full > 0 && (int)$row()['energy'] === 49 && str_contains($lastLog(), 'WINLINE'), "full $full");
$put(['check' => 'sense:40', 'rewards' => 'c=20,xp=10', 'fail_en' => 2, 'win' => 'WINLINE', 'lose' => 'LOSELINE // LOSELINE'] + $std);
$_SESSION['sight_v2_res'] = null; q('UPDATE users SET energy = 50, coins = 500 WHERE id = ?', [$uid]);
[$a] = $use(); $half = (int)$row()['coins'] - 500;
ok('a miss never blocks, pays half (not 0) and costs only the energy cost (no slip)', $a && $half > 0 && abs($half * 2 - $full) <= 1 && (int)$row()['energy'] === 49, "half $half full $full energy " . $row()['energy']);
ok('... the miss says the old lose line', str_contains($lastLog(), 'LOSELINE'), $lastLog());
$res = $_SESSION['sight_v2_res'] ?? [];
ok('... the result: not lucky, half a share; resting 6 sleeps (cooldown 55)', str_contains((string)($res['lucky'] ?? ''), 'half a share') && ($res['rest'] ?? '') === 'Resting now. Back in 6 sleeps.', json_encode($res));
$rh = sights_v2_result_html();
ok('the result card: story, chips, lucky line, resting line, one Lovely button', str_contains($rh, 'LOSELINE') && str_contains($rh, 'sgchip') && substr_count($rh, 'sgchip') <= 4 && str_contains($rh, 'Back in 6 sleeps.') && substr_count($rh, '>Lovely<') === 1 && str_contains($rh, 'sginline'), strip_tags($rh));
ok('... shown once', sights_v2_result_html() === '');
ok('the toast of the same log line is left out (with the card, and on a later page); another line still toasts', sights_v2_quiet_toast('9:4:123', true) && sights_v2_quiet_toast('9:4:123', false) && !sights_v2_quiet_toast('9:5:77', false));
$h = $card(); ok('a resting Sight says "Resting. Back in 6 sleeps." and has no button', str_contains($h, 'Resting. Back in 6 sleeps.') && !str_contains($h, '<button') && !str_contains($h, 'again soon'), strip_tags($h));
t('two sleeps later it says 4 sleeps', function () use ($uid, $card) { q('UPDATE trail_sight_uses SET got_tick = got_tick - 2880 WHERE user_id = ?', [$uid]); $h = $card(); return str_contains($h, 'Back in 4 sleeps.') ? true : strip_tags($h); });
$put(['check' => 'sense:1', 'rewards' => 'c=20,xp=10', 'win' => 'WINLINE', 'lose' => 'LOSELINE'] + $std);
$_SESSION['sight_v2_res'] = null; q('UPDATE users SET energy = 50, coins = 500 WHERE id = ?', [$uid]);
[$a] = $use(); ok('a pass: full pay and the lucky line', $a && (int)$row()['coins'] - 500 === $full && str_contains((string)($_SESSION['sight_v2_res']['lucky'] ?? ''), 'Lucky'), 'coins ' . ((int)$row()['coins'] - 500));
$_SESSION['sight_v2_res'] = null;
$put(['check' => 'pick:3:Left;Middle;Right', 'uses' => 9, 'rewards' => 'c=20,xp=10', 'win' => 'WINLINE', 'lose' => 'LOSELINE'] + $std);
$h = $card(); ok('a pick: still three buttons', substr_count($h, 'name="pick"') === 3, strip_tags($h));
$s = trail_scene($exp); $right = trail_sight_pick_right($row(), $s, trail_sights_all()[$base['slug']]); $wrong = ($right + 1) % 3;
q('UPDATE users SET coins = 500 WHERE id = ?', [$uid]); [$a] = $use(['pick' => $wrong]);
ok('every pick pays: the other one at half', $a && (int)$row()['coins'] - 500 === $half, 'got ' . ((int)$row()['coins'] - 500));
$s = trail_scene($exp); $right = trail_sight_pick_right($row(), $s, trail_sights_all()[$base['slug']]);
q('UPDATE users SET coins = 500 WHERE id = ?', [$uid]); [$a] = $use(['pick' => $right]);
ok('the right one is the lucky one: full', $a && (int)$row()['coins'] - 500 === $full, 'got ' . ((int)$row()['coins'] - 500));
$_SESSION['sight_v2_res'] = null;
q("DELETE FROM user_items WHERE user_id = ? AND item_id IN (SELECT id FROM items WHERE effects LIKE '%\"tool\":\"bucket\"%')", [$uid]); $tc = &tool_tier_cache(); $tc = [];
$put(['check' => '-', 'tool' => 'bucket:1', 'uses' => 9, 'rewards' => 'c=20,xp=10'] + $std);
q('UPDATE users SET coins = 500 WHERE id = ?', [$uid]); [$a, $m] = $use();
ok('a tool never locks: without it, half pay and the tip line', $a && (int)$row()['coins'] - 500 === $half && ($_SESSION['sight_v2_res']['hint'] ?? '') === 'A tide bucket would get more here.', json_encode([$a, $m, (int)$row()['coins'] - 500, $_SESSION['sight_v2_res']['hint'] ?? null]));
t('sights_v2_half_tok: things at half the chance, Petals and XP left to the scale', fn() => sights_v2_half_tok('item=x:2') === 'item=x:2@50' && sights_v2_half_tok('item=x:1@30') === 'item=x:1@15' && sights_v2_half_tok('item=x:1@5', false) === 'item=x:1@2' && sights_v2_half_tok('item=x:1@5', true) === 'item=x:1@3' && sights_v2_half_tok('item=x:1@1', false) === '' && sights_v2_half_tok('c=7') === 'c=7' && sights_v2_half_tok('en=1') === '' && sights_v2_half_tok('en=4') === 'en=2' && sights_v2_half_tok('fp=1') === 'fp=1');
t('no cap of Sights per walk while v2 is on (cap 1, three uses)', function () use ($put, $std, $use) { set_setting('sights_walk_cap', '1'); setting('__reload__'); $put(['check' => '-', 'uses' => 9, 'rewards' => 'xp=1'] + $std); $r = [$use()[0], $use()[0], $use()[0]]; set_setting('sights_walk_cap', '6'); setting('__reload__'); return $r === [true, true, true] ? true : json_encode($r); });
t('a use never lowers energy by more than its cost (a missed check with fail_en 3)', function () use ($put, $std, $use, $row, $uid) { $put(['check' => 'sense:40', 'fail_en' => 3, 'energy' => 1, 'uses' => 9, 'rewards' => 'xp=1', 'lose' => 'L'] + $std); q('UPDATE users SET energy = 30 WHERE id = ?', [$uid]); $use(); return (int)$row()['energy'] === 29 ? true : 'energy ' . $row()['energy']; });

$v2(false);
q('DELETE FROM trail_sight_rows WHERE slug = ?', [$base['slug']]);
echo $fails ? "$fails FAILED\n" : "ok\n";
exit($fails ? 1 : 0);
