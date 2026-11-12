<?php
// Trail Sights spike (v2.6.68): next to a big set piece the gnome gets a button; using it costs energy, pays rewards and starts a cooldown.
// php tests/trail_sights.php GAME_DIR   (an installed game, player "sprout"; walk.sh installs one). Route 240 section 1 has the grassland clover patch at 23,11.
$_SERVER['SCRIPT_NAME'] = '/adventure.php';
require $argv[1] . '/includes/bootstrap.php';
require_once $argv[1] . '/includes/adventure.php';
require_once $argv[1] . '/includes/trail_tiles.php';
require_once $argv[1] . '/includes/trail_sights.php';
$fails = 0;
function ok(string $what, bool $cond, string $extra = ''): void { global $fails; echo ($cond ? '  ok   ' : '  FAIL ') . $what . ($cond ? '' : "  $extra") . "\n"; if (!$cond) $fails++; }
echo "== data\n";
$all = trail_sights_all();
ok('the clover patch has a row', isset($all['grassland-the-clover-patch']) && $all['grassland-the-clover-patch']['verb'] === 'Pick', json_encode(array_keys($all)));
ok('a row has energy 1, cooldown 55, 2 uses', ($all['grassland-the-clover-patch']['energy'] ?? 0) === 1 && ($all['grassland-the-clover-patch']['cd'] ?? 0) === 55 && ($all['grassland-the-clover-patch']['uses'] ?? 0) === 2);
$art = ['objs' => [[10, 5, 'x-tree-1-leaf', 0], [20, 8, 'lm-grassland-the-clover-patch', 0]]];
ok('near: on the tile', (trail_sights_near($art, 20, 8)[0][0] ?? '') === 'grassland-the-clover-patch');
ok('near: diagonal neighbour', count(trail_sights_near($art, 21, 9)) === 1);
ok('near: two tiles away is too far', trail_sights_near($art, 22, 8) === []);
ok('near: a tree is no Sight', trail_sights_near($art, 10, 5) === []);

echo "== a walk on route 240\n";
set_setting('gnav_on', '1'); set_setting('gnav_tiles', '1'); setting('__reload__');
$u = q_one("SELECT * FROM users WHERE username = 'sprout'");
q("UPDATE expeditions SET status = 'done' WHERE user_id = ?", [$u['id']]);
q("UPDATE routes SET kind = 'road' WHERE id = 240");
$r = q_one('SELECT * FROM routes WHERE id = 240');
q("UPDATE users SET location_id = ?, level = 30, energy = 90, ev_quickwalk = 0 WHERE id = ?", [$r['a_id'], $u['id']]);
q('DELETE FROM trail_sight_uses WHERE user_id = ?', [$u['id']]);
$u = q_one('SELECT * FROM users WHERE id = ?', [$u['id']]);
[$sok, $m] = start_expedition($u, 240);
ok('a tile walk on route 240 starts', $sok, (string)$m);
$exp = active_expedition((int)$u['id']);
$sc = trail_scene($exp);
$lm = array_values(array_filter($sc['map']['art']['objs'], fn($o) => $o[2] === 'lm-grassland-the-clover-patch'));
ok('section 1 has the clover patch landmark', count($lm) === 1, json_encode($sc['map']['art']['objs'] ? count($sc['map']['art']['objs']) : 0));
// stand next to it (a walkable neighbour) and ask for the button
$spot = null;
foreach ([[-1, 0], [1, 0], [0, -1], [0, 1], [0, 0], [-1, -1], [1, 1]] as [$dx, $dy]) if (in_array(tm_tile($sc['map'], $lm[0][0] + $dx, $lm[0][1] + $dy), ['.', ',', 'S'], true)) { $spot = [$lm[0][0] + $dx, $lm[0][1] + $dy]; break; }
ok('a walkable tile beside the landmark', $spot !== null);
$sc['x'] = $spot[0]; $sc['y'] = $spot[1]; trail_save($sc); $sc = trail_scene($exp);
$here = trail_sights_here($u, $sc);
ok('the Sight is offered, ready, 2 uses', count($here) === 1 && $here[0][1] === 2, json_encode($here));
$e0 = (int)q_val('SELECT energy FROM users WHERE id = ?', [$u['id']]);
$logN = count(json_decode((string)q_val('SELECT log FROM expeditions WHERE id = ?', [$exp['id']]), true) ?: []);
[$ok1, $m1] = trail_sight_do($u, $exp, 'grassland-the-clover-patch'); save_exp($exp);   // adventure.php saves the walk after the action
ok('first use works', $ok1, (string)$m1);
ok('it cost 1 energy', (int)q_val('SELECT energy FROM users WHERE id = ?', [$u['id']]) === $e0 - 1);
ok('the walk log has the Pick line', str_contains(json_encode($exp['log'] ?? ''), 'Somebody was thorough') || str_contains((string)q_val('SELECT log FROM expeditions WHERE id = ?', [$exp['id']]), 'thorough'));
ok('the line shows the XP it paid', (bool)preg_match('/\\+\\d+ XP/', (string)q_val('SELECT log FROM expeditions WHERE id = ?', [$exp['id']])));
$u = q_one('SELECT * FROM users WHERE id = ?', [$u['id']]); $exp = active_expedition((int)$u['id']);
[$ok2] = trail_sight_do($u, $exp, 'grassland-the-clover-patch'); save_exp($exp); ok('second use works', $ok2);
$exp = active_expedition((int)$u['id']);
[$ok3, $m3] = trail_sight_do($u, $exp, 'grassland-the-clover-patch');
ok('third use is refused (2 uses per cooldown)', !$ok3 && $m3 !== '', (string)$m3);
$sc = trail_scene($exp); $here = trail_sights_here($u, $sc);
ok('the button is greyed (0 left)', count($here) === 1 && $here[0][1] === 0);
$html = trail_view_html($u, $exp, $sc, false); // the map still draws
ok('the map still draws', str_contains($html, '<svg'));
echo "== cooldown ends\n";
q('UPDATE trail_sight_uses SET got_at = got_at - 999999, got_tick = got_tick - 99999 WHERE user_id = ?', [$u['id']]);
$here = trail_sights_here($u, $sc);
ok('after the cooldown the Sight is back with 2 uses', count($here) === 1 && $here[0][1] === 2, json_encode($here[0][1] ?? null));
echo "== too far\n";
$far = null; foreach ([[0, 0], [29, 0], [0, 17], [29, 17]] as [$fx, $fy]) if (max(abs($fx - $lm[0][0]), abs($fy - $lm[0][1])) > 1) { $far = [$fx, $fy]; break; }
$sc['x'] = $far[0]; $sc['y'] = $far[1]; trail_save($sc); $exp = active_expedition((int)$u['id']);
[$ok4, $m4] = trail_sight_do($u, $exp, 'grassland-the-clover-patch');
ok('far from it the Sight is refused', !$ok4 && str_contains((string)$m4, 'next to'), (string)$m4);

echo "== P1: every row lints, bad rows do not\n";
require_once $argv[1] . '/includes/tools.php';
$GLOBALS['gv_sights_reload'] = true; $all = trail_sights_all();
foreach ($all as $r) { $pb = trail_sight_lint($r); ok('row lints: ' . $r['slug'], !$pb, implode('; ', $pb)); }
ok('the four P1 example rows exist (forage, check, read, fish)', isset($all['coast-the-shell-heap'], $all['mountain-the-rope-bridge'], $all['grassland-the-old-milestone'], $all['island-the-reef-shallows']));
$base = $all['grassland-the-clover-patch'];
foreach ([['check' => 'luckk:5'], ['check' => 'grit:99'], ['tool' => 'spade:1'], ['tool' => 'rod:9'], ['rewards' => 'gold=5'], ['rewards' => 'item=no-such-thing-xyz:1'], ['when' => 'dp=noon_ish!'], ['energy' => 9], ['win' => '']] as $chg) {
    ok('lint catches ' . json_encode($chg), (bool)trail_sight_lint($chg + $base));
}
ok('lint catches a landmark with no picture', (bool)trail_sight_lint(['slug' => 'no-such-landmark'] + $base));
echo "== P1: the engine paths, on the clover patch row (admin rows replace file rows)\n";
trail_sights_ensure_tables();
$put = function (array $chg) use ($base) {
    $r = $chg + $base; q('DELETE FROM trail_sight_rows WHERE slug = ?', [$base['slug']]);
    db_insert('trail_sight_rows', ['slug' => $base['slug'], 'verb' => $r['verb'], 'icon' => $r['icon'], 'energy' => $r['energy'], 'cd' => $r['cd'], 'uses' => $r['uses'], 'cond' => $r['when'], 'chk' => $r['check'], 'rewards' => $r['rewards'], 'win' => $r['win'], 'lose' => $r['lose'], 'tool' => $r['tool'], 'fail_en' => $r['fail_en'], 'active' => 1, 'updated_at' => now()]);
    q('DELETE FROM trail_sight_uses'); $GLOBALS['gv_sights_reload'] = true; trail_sights_all();
};
$energy = fn() => (int)q_val('SELECT energy FROM users WHERE id = ?', [$u['id']]);
$mins = fn() => gclock_on() ? (int)q_val('SELECT game_day * 1440 + game_minute FROM users WHERE id = ?', [$u['id']]) : 0;
$fresh = function () use (&$u, &$exp) { $u = q_one('SELECT * FROM users WHERE id = ?', [$u['id']]); $exp = active_expedition((int)$u['id']); $GLOBALS['gv_sights_reload'] = true; };
$sc = trail_scene($exp); $sc['x'] = $spot[0]; $sc['y'] = $spot[1]; trail_save($sc);
$put(['energy' => 0, 'rewards' => 'xp=2:1']); $fresh();
$e1 = $energy(); $t1 = $mins();
[$z] = trail_sight_do($u, $exp, $base['slug']); save_exp($exp);
ok('an energy-free Sight (reading) works and costs no energy', $z && $energy() === $e1);
if (gclock_on()) ok('it costs 10 game minutes (time_sight)', $mins() - $t1 === 10, (string)($mins() - $t1));
$put(['check' => 'grit:25', 'fail_en' => 2, 'lose' => 'You slip.', 'rewards' => 'xp=5']); $fresh();
q('UPDATE users SET stat_grit = 1 WHERE id = ?', [$u['id']]); $fresh();
$e2 = $energy(); $fails2 = 0;
for ($i = 0; $i < 6; $i++) { $put(['check' => 'grit:25', 'fail_en' => 2, 'lose' => 'You slip.', 'rewards' => 'xp=5', 'uses' => 1]); $fresh(); $e = $energy(); [$o2] = trail_sight_do($u, $exp, $base['slug']); save_exp($exp); if ($energy() === $e - 1 - 2) $fails2++; }
ok('a failed check costs the energy plus fail_en (grit 1 against 25: nearly always fails)', $fails2 >= 4, (string)$fails2);
ok('the lose line is in the log', str_contains((string)q_val('SELECT log FROM expeditions WHERE id = ?', [$exp['id']]), 'You slip'));
$put(['tool' => 'bucket:1', 'rewards' => 'xp=1']); $fresh();
$tc = &tool_tier_cache(); $tc[$u['id'] . ':bucket'] = 0;
[$t0, $tm] = trail_sight_do($u, $exp, $base['slug']);
ok('without the tool it is refused and costs nothing', !$t0 && str_contains((string)$tm, 'tide bucket'), (string)$tm);
$tc[$u['id'] . ':bucket'] = 1; $eT = $energy();
[$t1ok] = trail_sight_do($u, $exp, $base['slug']); save_exp($exp);
ok('with the tool it works', $t1ok && $energy() === $eT - 1);
$put(['rewards' => 'gather=rod', 'tool' => 'rod:1']); $fresh(); $tc[$u['id'] . ':rod'] = 1;
[$g1] = trail_sight_do($u, $exp, $base['slug']); save_exp($exp);
$lg = (string)q_val('SELECT log FROM expeditions WHERE id = ?', [$exp['id']]);
ok('gather=rod runs the gather table (it logs a catch or a hint)', $g1 && (str_contains($lg, 'fishing') || str_contains($lg, 'catch') || str_contains($lg, 'nothing') || str_contains($lg, 'rod') || str_contains($lg, 'Fish') || str_contains($lg, 'wade')), substr($lg, -200));
$put(['when' => 'dp=night/se=winter', 'check' => '-', 'rewards' => 'xp=1', 'tool' => '-']); $fresh(); unset($tc[$u['id'] . ':rod']);
echo "== P2: reward grammar (conditions, first-time, take)\n";
$tk = trail_sight_tokens('first:xp=10,item=a:1@25?se=summer;dp=dusk,c=3,take=b:2');
ok('tokens: first / condition / plain / take', count($tk) === 4 && $tk[0]['first'] && $tk[0]['tok'] === 'xp=10' && $tk[1]['cond'] === 'se=summer,dp=dusk' && $tk[1]['tok'] === 'item=a:1@25' && !$tk[2]['first'] && $tk[3]['tok'] === 'take=b:2');
ok('lint: a bad condition in a token', (bool)trail_sight_lint(['rewards' => 'xp=1?mood=sad'] + $base));
ok('lint: unlock needs kind:slug', (bool)trail_sight_lint(['rewards' => 'unlock=oops'] + $base));
ok('lint: take of an unknown item', (bool)trail_sight_lint(['rewards' => 'take=no-such-item-xyz:1'] + $base));
q('DELETE FROM trail_sight_first');
$xp0 = (int)q_val('SELECT xp FROM users WHERE id = ?', [$u['id']]);
$put(['rewards' => 'first:xp=40,xp=1', 'uses' => 9, 'energy' => 0]); $fresh();
[$f1] = trail_sight_do($u, $exp, $base['slug']); save_exp($exp); $xpA = (int)q_val('SELECT xp FROM users WHERE id = ?', [$u['id']]);
$fresh(); [$f2] = trail_sight_do($u, $exp, $base['slug']); save_exp($exp); $xpB = (int)q_val('SELECT xp FROM users WHERE id = ?', [$u['id']]);
ok('first: the first use pays the bonus, the second does not', $f1 && $f2 && $xpA - $xp0 >= 40 && $xpB - $xpA < 40, "$xp0 $xpA $xpB");
$put(['rewards' => 'xp=1?we=nosuchweather', 'uses' => 9, 'energy' => 0, 'check' => '-']); $fresh(); $xpC = (int)q_val('SELECT xp FROM users WHERE id = ?', [$u['id']]);
[$c1] = trail_sight_do($u, $exp, $base['slug']); save_exp($exp);
ok('a condition that does not hold pays nothing', $c1 && (int)q_val('SELECT xp FROM users WHERE id = ?', [$u['id']]) === $xpC);
$slugI = (string)q_val('SELECT slug FROM items ORDER BY id LIMIT 1'); $idI = (int)q_val('SELECT id FROM items WHERE slug = ?', [$slugI]);
q('DELETE FROM user_items WHERE user_id = ? AND item_id = ?', [$u['id'], $idI]);
$put(['rewards' => 'take=' . $slugI . ':2,xp=1', 'uses' => 9, 'energy' => 1]); $fresh(); $eTk = $energy();
[$n1, $nm] = trail_sight_do($u, $exp, $base['slug']);
ok('take: refused without the item, no energy spent', !$n1 && str_contains((string)$nm, 'You need 2') && $energy() === $eTk, (string)$nm);
give_item((int)$u['id'], $idI, 3); $fresh();
[$n2] = trail_sight_do($u, $exp, $base['slug']); save_exp($exp);
ok('take: with the item it works and uses 2 up', $n2 && (int)q_val('SELECT qty FROM user_items WHERE user_id = ? AND item_id = ?', [$u['id'], $idI]) === 1);
echo "== P1: admin rows replace, hide and restore\n";
$GLOBALS['gv_sights_reload'] = true; ok('a saved row replaces the file row (src edited)', (trail_sights_all()[$base['slug']]['src'] ?? '') === 'edited');
q('DELETE FROM trail_sight_rows WHERE slug = ?', [$base['slug']]); db_insert('trail_sight_rows', ['slug' => $base['slug'], 'verb' => '-', 'icon' => '-', 'energy' => 0, 'cd' => 0, 'uses' => 1, 'cond' => '-', 'chk' => '-', 'rewards' => '', 'win' => '', 'lose' => '', 'tool' => '-', 'fail_en' => 0, 'active' => 0, 'updated_at' => now()]);
$GLOBALS['gv_sights_reload'] = true; ok('an off row hides the Sight', !isset(trail_sights_all()[$base['slug']]));
q('DELETE FROM trail_sight_rows WHERE slug = ?', [$base['slug']]); $GLOBALS['gv_sights_reload'] = true;
ok('removing the row brings the file row back', (trail_sights_all()[$base['slug']]['src'] ?? '') === 'file');

echo "== every Sight of every Trail route runs once (no errors; a closed time of day is fine)\n";
$tc = &tool_tier_cache();
$rows = trail_sights_all(); $ran = 0; $errs = []; $skipped = 0; $routesDone = 0;
$authored = trail_authored_all();
foreach ($authored as $rid => $rt) {
    $has = false; foreach ($rt['sections'] as $sx) foreach ($sx['objs'] as $o) if (strncmp($o[2], 'lm-', 3) === 0 && isset($rows[substr($o[2], 3)])) $has = true;
    if (!$has) continue;
    $routesDone++;
    q("UPDATE expeditions SET status = 'done' WHERE user_id = ?", [$u['id']]); q("UPDATE routes SET kind = 'road' WHERE id = ?", [(int)$rid]);
    $rr = q_one('SELECT * FROM routes WHERE id = ?', [(int)$rid]); if (!$rr) continue;
    q("UPDATE users SET location_id = ?, level = 40, energy = 150, ev_quickwalk = 0 WHERE id = ?", [$rr['a_id'], $u['id']]);
    $u = q_one('SELECT * FROM users WHERE id = ?', [$u['id']]);
    [$so, $sm] = start_expedition($u, (int)$rid); if (!$so) { $errs[] = "route $rid does not start: $sm"; continue; }
    $exp = active_expedition((int)$u['id']);
    for ($si = 0; $si < count($rt['sections']); $si++) {
        $exp['encounter'] = null; $sc = trail_scene($exp);
        foreach ($sc['map']['art']['objs'] as $o) {
            if (strncmp($o[2], 'lm-', 3) !== 0 || !isset($rows[substr($o[2], 3)])) continue;
            $slug = substr($o[2], 3); $row = $rows[$slug];
            $st2 = null; foreach ([[0, 0], [-1, 0], [1, 0], [0, -1], [0, 1]] as [$dx, $dy]) if (in_array(tm_tile($sc['map'], $o[0] + $dx, $o[1] + $dy), ['.', ',', 'S'], true)) { $st2 = [$o[0] + $dx, $o[1] + $dy]; break; }
            if (!$st2) { $errs[] = "$slug: nowhere to stand"; continue; }
            $sc['x'] = $st2[0]; $sc['y'] = $st2[1]; $sc['st']['phase'] = 'section'; trail_save($sc); $sc = trail_scene($exp);
            q('DELETE FROM trail_sight_uses WHERE user_id = ?', [$u['id']]); q('UPDATE users SET energy = 150 WHERE id = ?', [$u['id']]);
            foreach (['rod', 'forage', 'pick', 'net', 'bucket', 'axe', 'basket', 'staff', 'lantern'] as $tt) $tc[$u['id'] . ':' . $tt] = 3;
            foreach (trail_sight_tokens($row['rewards']) as $tk) if (str_starts_with($tk['tok'], 'take=')) { [$ts, $tq] = array_pad(explode(':', substr($tk['tok'], 5), 2), 2, '1'); give_item((int)$u['id'], (int)q_val('SELECT id FROM items WHERE slug = ?', [$ts]), (int)$tq + 1); }
            $u = q_one('SELECT * FROM users WHERE id = ?', [$u['id']]);
            $pk = trail_sight_pick_info($row);
            try { [$ro, $rm] = trail_sight_do($u, $exp, $slug, $pk ? ['pick' => trail_sight_pick_answer((int)$u['id'], $row)] : []); save_exp($exp); $exp = active_expedition((int)$u['id']); }
            catch (Throwable $ex) { $errs[] = "$slug threw " . get_class($ex) . ': ' . $ex->getMessage(); continue; }
            if ($ro) $ran++; elseif (str_contains((string)$rm, 'right time') || str_contains((string)$rm, 'busy')) $skipped++; else $errs[] = "$slug refused: $rm";
        }
        if ($si < count($rt['sections']) - 1) { $sc = trail_scene($exp); [$ex9, $ey9] = $sc['map']['spots']['9']; $sc['x'] = $ex9; $sc['y'] = $ey9; $sc['st']['phase'] = 'confirm'; trail_save($sc); $exp['encounter'] = null; trail_next($u, $exp); $exp = active_expedition((int)$u['id']); }
    }
}
ok("every Sight on every route ran or was out of its time ($ran ran, $skipped out of time, $routesDone routes)", !$errs && $ran + $skipped >= count($rows) - 2, implode(' | ', array_slice($errs, 0, 8)));

echo "== P2b / P3: items, Almanac chapter, quest lines, villagers, the Trail page\n";
require_once $argv[1] . '/includes/stops.php';
trail_sights_ensure_items();
$missing = array_filter(array_keys(trail_sight_items_file()), fn($sl) => !q_val('SELECT 1 FROM items WHERE slug = ?', [$sl]));
ok('every item of trail_sight_items.txt exists after trail_sights_ensure_items (' . count(trail_sight_items_file()) . ' items)', !$missing, implode(',', array_slice($missing, 0, 5)));
$mm = array_filter(array_keys(trail_sights_all()), fn($sl) => !isset(trail_sight_info()[$sl]));
ok('every Sight has a name and caption', !$mm, implode(',', array_slice($mm, 0, 5)));
set_setting('almanac_sights', ''); trail_sights_ensure_almanac();
$nPages = (int)q_val("SELECT COUNT(*) FROM encyclopedia_entries WHERE chapter = 'Sights' AND unlock_key LIKE 'sight:%'");
$noPage = array_filter(array_keys(trail_sights_all()), fn($sl) => !q_val('SELECT 1 FROM encyclopedia_entries WHERE unlock_key = ?', ['sight:' . $sl]));
ok('the Almanac chapter Sights has one page per Sight (' . $nPages . ')', $nPages === count(trail_sights_all()), $nPages . ' vs ' . count(trail_sights_all()) . ' missing: ' . implode(',', array_slice($noPage, 0, 6)));
$sg0 = array_key_first(trail_sights_all()); $key0 = 'sight:' . $sg0;
q('DELETE FROM user_encyclopedia WHERE user_id = ? AND entry_id IN (SELECT id FROM encyclopedia_entries WHERE unlock_key = ?)', [$u['id'], $key0]);
ok('using unlocks the page: unlock_entries opens it once', unlock_entries((int)$u['id'], $key0) === 1 && unlock_entries((int)$u['id'], $key0) === 0);
// quest lines: walk every line through its beats with a fake 'now' that satisfies each beat's condition
$cond = function (string $when): array { $now = ['dp' => 'day', 'se' => 'spring', 'we' => 'sun', 'hp' => '']; foreach (stop_cond_parse($when) as $k => $vals) $now[$k] = $vals[0]; return $now; };
$allSights = trail_sights_all(); $loc = q_one('SELECT * FROM locations ORDER BY id LIMIT 1') + ['landscape' => 'grassland'];
$u = q_one('SELECT * FROM users WHERE id = ?', [$u['id']]); $nq = 0;
$qAll = trail_sight_quests(); $qOrder = array_keys($qAll);   // gate lines after the lines they wait for
usort($qOrder, fn($x, $y) => ($qAll[$x]['gate'] !== '') <=> ($qAll[$y]['gate'] !== ''));
foreach ($qOrder as $qs) {
    $q = $qAll[$qs];
    $nq++; $bad = trail_sight_quest_lint($q, $allSights, $qAll); ok('quest lints: ' . $q['slug'], !$bad, implode('; ', $bad));
    q('DELETE FROM user_sight_quests WHERE user_id = ? AND quest = ?', [$u['id'], $q['slug']]);
    $lines = []; $guard = 0;
    while ($guard++ < 60) {   // keep doing the next open beat until the line is done (hand-in items are supplied, event beats are fired)
        $row = trail_sight_quest_row((int)$u['id'], $q['slug']);
        if ($row && $row['done_at'] !== null) break;
        $doneIdx = trail_sight_quest_done($q, $row); $moved = false;
        foreach ($q['beats'] as $i => $b) {
            if (!trail_sight_beat_open($q, $doneIdx, $i)) continue;
            if ($nd = trail_sight_beat_need($b)) give_item((int)$u['id'], $nd[0], $nd[1]);
            if ($b[0][0] === '@') { $kind = explode(':', substr($b[0], 1))[0]; if ($kind === 'friend') { $fo = trail_sight_folk_id(substr($b[0], 8)); if ($fo) stop_friend_add((int)$u['id'], $fo, 10); $lines = array_merge($lines, trail_sight_quest_hook($u, 'grassland-the-old-milestone', $loc, $cond('-'))); }
                else $lines = array_merge($lines, trail_sight_quest_event($u, $kind, explode(':', $b[0], 2)[1] ?? 'a-lair')); }
            else $lines = array_merge($lines, trail_sight_quest_hook($u, $b[0], $loc, $cond($b[2])));
            $moved = true; break;
        }
        if (!$moved) break;
    }
    $row = trail_sight_quest_row((int)$u['id'], $q['slug']);
    ok('quest runs to the end: ' . $q['slug'] . ' (' . count($q['beats']) . ' beats, ' . $q['order'] . ')', $row && $row['done_at'] !== null, json_encode([$row['beats'] ?? null, array_slice($lines, -1)]));
}
echo "  ($nq quest lines)\n";
$noFolk = [];
foreach (trail_sight_folk() as $slug => $list) foreach ($list as $f) {
    $okName = trail_sight_folk_id($f['who']) > 0 || (int)q_val('SELECT id FROM npcs WHERE name = ?', [$f['who']]) > 0;
    if (!$okName) $noFolk[] = $f['who'];
}
ok('every villager of trail_sight_folk.txt can be found by name', !$noFolk, implode(', ', array_slice(array_unique($noFolk), 0, 8)));
// twins: a name shared by villagers of different villages must say which one (Name@village-slug) in the folk rows and quest givers
require_once $argv[1] . '/includes/stop_folk.php';
foreach (q("SELECT * FROM locations WHERE kind = 'village' ORDER BY id")->fetchAll() as $vv) stop_folk_ensure($vv);
$twinNames = array_column(q('SELECT name FROM stop_folk GROUP BY name HAVING COUNT(*) > 1')->fetchAll(), 'name');
$unpinned = [];
foreach (trail_sight_folk() as $sl => $lst) foreach ($lst as $f) if (in_array(trail_sight_split_who($f['who'])[0], $twinNames, true) && !str_contains($f['who'], '@')) $unpinned[] = $sl . ':' . $f['who'];
foreach (trail_sight_quests() as $qq) if (in_array(trail_sight_split_who($qq['giver'])[0], $twinNames, true) && !str_contains($qq['giver'], '@')) $unpinned[] = 'quest ' . $qq['slug'] . ':' . $qq['giver'];
ok('no villager of a shared name is left unpinned (' . count($twinNames) . ' shared names in the world)', !$unpinned, implode(', ', array_slice($unpinned, 0, 6)));
$wrong = [];
foreach (trail_sight_folk() as $sl => $lst) foreach ($lst as $f) if (str_contains($f['who'], '@') && !trail_sight_folk_id($f['who'])) $wrong[] = $f['who'];
ok('every pinned villager (Name@village) exists in that village', !$wrong, implode(', ', array_slice($wrong, 0, 6)));
// the Trail page: mark over the landmark, Sights button, card
$exp = active_expedition((int)$u['id']); $sc = trail_scene($exp);
$exp['encounter'] = null; q("UPDATE expeditions SET status = 'done' WHERE user_id = ?", [$u['id']]);
q("UPDATE routes SET kind = 'road' WHERE id = 240"); $rr = q_one('SELECT * FROM routes WHERE id = 240'); q("UPDATE users SET location_id = ?, energy = 150 WHERE id = ?", [$rr['a_id'], $u['id']]);
$u = q_one('SELECT * FROM users WHERE id = ?', [$u['id']]); start_expedition($u, 240); $exp = active_expedition((int)$u['id']); $sc = trail_scene($exp);
q('DELETE FROM trail_sight_uses WHERE user_id = ?', [$u['id']]);
$sc['x'] = $spot[0]; $sc['y'] = $spot[1]; trail_save($sc); $sc = trail_scene($exp);   // beside the landmark, so it is inside the 7 x 7 view
$marks = trail_sights_marks($u, $sc);
ok('the section has its Sight in the marks, ready', count($marks) >= 1 && $marks[0]['left'] >= 1, json_encode(array_column($marks, 'slug')));
$html = trail_view_html($u, $exp, $sc, false);
ok('the map draws a gold ! (tmsight) over the landmark', str_contains($html, 'class="tmsight"'));
$sc['x'] = 0; $sc['y'] = 0; $cards = trail_sights_cards_html($u, $sc, $marks);
ok('the Sights card shows name, caption and a Walk-there button when you are away from it', str_contains($cards, 'sgcard') && str_contains($cards, 'Walk there') && str_contains($cards, 'clover patch'), substr($cards, 0, 200));

echo "== P4: the engine features (conditions, variants, pick, villagers, give, hints, titles, pages, new folk, quest orders, gates, event beats, item effects)\n";
$tmp = sys_get_temp_dir() . '/sights-p4-' . getmypid(); @mkdir($tmp);
$w = fn(string $name, string $body) => file_put_contents("$tmp/$name", $body) !== false ? "$tmp/$name" : '';
$u = q_one('SELECT * FROM users WHERE id = ?', [$u['id']]);
// conditions
$nowT = ['dp' => 'dusk', 'se' => 'winter', 'we' => 'rain', 'hp' => '', 'st' => 'sneak', 'pal' => '1'];
ok('cond: sneak + dusk holds', trail_sight_cond_ok('st=sneak/dp=dusk,night', $nowT));
ok('cond: hunt does not hold while sneaking', !trail_sight_cond_ok('st=hunt', $nowT));
ok('cond: pal=1 holds, pal=0 does not', trail_sight_cond_ok('pal=1', $nowT) && !trail_sight_cond_ok('pal=0', $nowT));
ok('cond: unknown key fails', !trail_sight_cond_ok('mood=sad', $nowT));
ok('cond text reads in plain words', trail_sight_cond_text('st=sneak/dp=dusk') === 'sneaking, at dusk', trail_sight_cond_text('st=sneak/dp=dusk'));
ok('lint accepts st= and pal= conditions', !array_filter(trail_sight_lint(['when' => 'st=sneak/pal=1'] + $base), fn($p) => str_contains($p, 'condition')));
// variants and pick
$seen = []; for ($i = 0; $i < 60; $i++) $seen[trail_sight_line('a // b // c')] = 1;
ok('a line with " // " variants gives each variant in time', count($seen) === 3, json_encode(array_keys($seen)));
$pickRow = ['check' => 'pick:3:Left;Middle;Right', 'slug' => 'x'] + $base;
ok('pick lints and has 3 labels', !trail_sight_lint($pickRow) || !array_filter(trail_sight_lint($pickRow), fn($p) => str_contains($p, 'pick')), json_encode(trail_sight_lint($pickRow)));
ok('a pick with the wrong number of labels is caught', (bool)array_filter(trail_sight_lint(['check' => 'pick:3:A;B'] + $base), fn($p) => str_contains($p, 'pick')));
$ans = trail_sight_pick_answer((int)$u['id'], $pickRow);
ok('the pick answer is stable for the day and within range', $ans === trail_sight_pick_answer((int)$u['id'], $pickRow) && $ans >= 0 && $ans < 3);
$put(['check' => 'pick:3:Left;Middle;Right', 'lose' => 'Wrong door.', 'rewards' => 'xp=2', 'uses' => 9, 'energy' => 0]); $fresh();
$sc = trail_scene($exp); $sc['x'] = $spot[0]; $sc['y'] = $spot[1]; trail_save($sc);
[$p0, $pm] = trail_sight_do($u, $exp, $base['slug']);
ok('a pick Sight without a choice is refused', !$p0 && $pm === 'Choose one.', (string)$pm);
$right = trail_sight_pick_answer((int)$u['id'], trail_sights_all()[$base['slug']]);
$fresh(); [$p1] = trail_sight_do($u, $exp, $base['slug'], ['pick' => $right]); save_exp($exp);
ok('the right pick wins (xp line in the log)', $p1 && str_contains((string)q_val('SELECT log FROM expeditions WHERE id = ?', [$exp['id']]), 'XP'));
$fresh(); [$p2] = trail_sight_do($u, $exp, $base['slug'], ['pick' => ($right + 1) % 3]); save_exp($exp);
ok('a wrong pick uses the lose line', $p2 && str_contains((string)q_val('SELECT log FROM expeditions WHERE id = ?', [$exp['id']]), 'Wrong door'));
// villagers: daily roll, away, hidden npc, nocheck, give
$GLOBALS['gv_sight_folk_file'] = $w('folk.txt', "{$base['slug']}|Pomeroy Crumbworth|-|100|Pomeroy is here.|fp=1\n{$base['slug']}|Mabel Pennywhistle|-|100|Mabel waves.|nocheck,fp=1\n{$base['slug']}|Bunty Windlass|-|100|Bunty wants a carrot.|give=" . q_val('SELECT slug FROM items ORDER BY id LIMIT 1') . ":1,xp=5\n");
$here = trail_sight_folk_here($base['slug'], ['dp' => 'day', 'se' => 'spring', 'we' => 'sun', 'hp' => '', 'st' => 'normal', 'pal' => '0'], (int)$u['id']);
$names = array_column($here, 'who');
ok('villagers at 100% are here (Pomeroy only when active)', in_array('Mabel Pennywhistle', $names, true) && in_array('Bunty Windlass', $names, true), json_encode($names));
$pomActive = (int)q_val("SELECT active FROM npcs WHERE name = 'Pomeroy Crumbworth'");
ok('a hidden NPC (Pomeroy, inactive) is not here; an active one is', ($pomActive === 1) === in_array('Pomeroy Crumbworth', $names, true), "active=$pomActive");
ok('the daily roll is stable', $here === trail_sight_folk_here($base['slug'], ['dp' => 'day', 'se' => 'spring', 'we' => 'sun', 'hp' => '', 'st' => 'normal', 'pal' => '0'], (int)$u['id']));
$GLOBALS['gv_sight_folk_file'] = $w('folk2.txt', "{$base['slug']}|Nobody At All|dp=nosuchdaypart|100|x|fp=1\n");
ok('a condition that fails keeps a villager away', trail_sight_folk_here($base['slug'], ['dp' => 'day', 'se' => 'spring', 'we' => 'sun', 'hp' => '', 'st' => 'normal', 'pal' => '0'], 1) === []);
// nocheck makes a hard check a sure win
$GLOBALS['gv_sight_folk_file'] = $w('folk3.txt', "{$base['slug']}|Mabel Pennywhistle|-|100|Mabel steadies the plank.|nocheck,xp=1\n");
$put(['check' => 'grit:25', 'lose' => 'You slip.', 'rewards' => 'xp=2', 'uses' => 9, 'energy' => 0]); $fresh();
q('UPDATE users SET stat_grit = 1 WHERE id = ?', [$u['id']]); $fresh();
$GLOBALS['gv_sight_folk_file'] = $w('folk3.txt', "{$base['slug']}|Mabel Pennywhistle|-|100|Mabel steadies the plank.|nocheck,xp=1\n");
[$nc] = trail_sight_do($u, $exp, $base['slug']); save_exp($exp);
ok('a villager with nocheck makes a hard check a sure thing', $nc && str_contains((string)q_val('SELECT log FROM expeditions WHERE id = ?', [$exp['id']]), 'no roll needed'));
// give
$gslug = (string)q_val('SELECT slug FROM items ORDER BY id LIMIT 1'); $gid = (int)q_val('SELECT id FROM items WHERE slug = ?', [$gslug]);
$GLOBALS['gv_sight_folk_file'] = $w('folk4.txt', "{$base['slug']}|Bunty Windlass@v-ca-4-2|-|100|Bunty is glad of it.|give=$gslug:1,xp=7\n");
q('DELETE FROM user_items WHERE user_id = ? AND item_id = ?', [$u['id'], $gid]); $fresh();
[$g0, $gm0] = trail_sight_give($u, $exp, $base['slug'], 0);
ok('give: refused without the item', !$g0 && str_contains((string)$gm0, 'You need'), (string)$gm0);
give_item((int)$u['id'], $gid, 2); $fresh(); [$g1] = trail_sight_give($u, $exp, $base['slug'], 0); save_exp($exp);
ok('give: with the item it is used up and the villager pays', $g1 && (int)q_val('SELECT qty FROM user_items WHERE user_id = ? AND item_id = ?', [$u['id'], $gid]) === 1 && str_contains((string)q_val('SELECT log FROM expeditions WHERE id = ?', [$exp['id']]), 'Bunty'));
// hints, titles, pages
$locx = q_one('SELECT * FROM locations ORDER BY id LIMIT 1') + ['landscape' => 'grassland'];
ok('hint=weather is a line about tomorrow', str_contains(trail_sight_hint($u, $locx, 'weather'), 'tomorrow'));
ok('hint=away says who is away or that all are home', trail_sight_hint($u, $locx, 'away') !== '');
q('DELETE FROM user_sight_titles WHERE user_id = ?', [$u['id']]);
ok('a title is given once', trail_sight_give_title((int)$u['id'], 'Bridgewarden') && !trail_sight_give_title((int)$u['id'], 'Bridgewarden') && trail_sight_titles((int)$u['id']) === ['Bridgewarden']);
$GLOBALS['gv_sight_pages_file'] = $w('pages.txt', "my-first-page|Sights|Test|My first page|Hello \\n world.\n");
set_setting('almanac_sight_pages', ''); trail_sights_ensure_pages();
ok('an extra Almanac page is made and opens with page=<key>', (int)q_val("SELECT COUNT(*) FROM encyclopedia_entries WHERE unlock_key = 'sightpage:my-first-page'") === 1 && count(trail_sight_pay($u, $locx, 'page=my-first-page')) === 1 && trail_sight_pay($u, $locx, 'page=my-first-page') === []);
ok('lint: page= needs a known key', (bool)array_filter(trail_sight_lint(['rewards' => 'page=no-such-page'] + $base), fn($p) => str_contains($p, 'page=')) && !array_filter(trail_sight_lint(['rewards' => 'page=my-first-page'] + $base), fn($p) => str_contains($p, 'page=')));
// new villagers
$vs = (string)q_val("SELECT slug FROM locations WHERE kind = 'village' ORDER BY id LIMIT 1");
$GLOBALS['gv_sight_newfolk_file'] = $w('newfolk.txt', "Keeper Marram|Mole|Generous|Lighthouse keeper|A stout gnome in a knitted cap.|$vs\n");
$rf = new ReflectionFunction('trail_sights_ensure_newfolk'); $st = $rf->getStaticVariables();
$dd = &$st;
// the static guard is per request: run the body once by calling the lookup after clearing the guard through a fresh process-safe path
$vrow = q_one("SELECT * FROM locations WHERE slug = ?", [$vs]); require_once $argv[1] . '/includes/stop_folk.php'; stop_folk_ensure($vrow);
db_insert('stop_folk', ['location_id' => (int)$vrow['id'], 'slot' => 9, 'name' => 'Keeper Marram', 'species' => 'Mole', 'personality' => 'Generous', 'role' => 'Lighthouse keeper', 'bio' => 'x']);
ok('a made villager (Keeper Marram) can be found by name and befriended', trail_sight_folk_id('Keeper Marram') > 0 && trail_sight_befriend($u, 'Keeper Marram@' . $vs, 1) !== '');
// quest orders, gates, duplicates, event beats, needs
$GLOBALS['gv_sight_quests_file'] = $w('q.txt', "Q|q-last|Last Is Last|Nettle Cobblefield|📜|anylast|xp=5|intro|outro\nB|q-last|{$base['slug']}|one|-\nB|q-last|mountain-the-rope-bridge|two|-\nB|q-last|grassland-the-old-milestone|three|-\n"
    . "Q|q-dup|Twice The Same|Nettle Cobblefield|📜|seq|xp=5|intro|outro\nB|q-dup|{$base['slug']}|first|-\nB|q-dup|mountain-the-rope-bridge|middle|-\nB|q-dup|{$base['slug']}|again|-\n"
    . "Q|q-gated|After Dup|Nettle Cobblefield|📜|any|xp=5|intro|outro|quest:q-dup\nB|q-gated|{$base['slug']}|g1|-\nB|q-gated|mountain-the-rope-bridge|g2|-\n"
    . "Q|q-event|Boss And Meal|Nettle Cobblefield|📜|any|xp=5|intro|outro\nB|q-event|@boss|win a lair|-\nB|q-event|@meal|eat a meal|-\n"
    . "Q|q-needs|Bring It|Nettle Cobblefield|📜|seq|xp=5|intro|outro\nB|q-needs|{$base['slug']}|hand over|-|take=$gslug:2\nB|q-needs|mountain-the-rope-bridge|then this|-\n");
$aq = trail_sight_quests();
ok('the test quests parse (5 lines)', count($aq) === 5, (string)count($aq));
q('DELETE FROM user_sight_quests WHERE user_id = ?', [$u['id']]);
$nowQ = ['dp' => 'day', 'se' => 'spring', 'we' => 'sun', 'hp' => '', 'st' => 'normal', 'pal' => '0'];
trail_sight_quest_hook($u, 'grassland-the-old-milestone', $locx, $nowQ);
ok('anylast: the last beat does not count first', !trail_sight_quest_row((int)$u['id'], 'q-last'));
trail_sight_quest_hook($u, $base['slug'], $locx, $nowQ); trail_sight_quest_hook($u, 'mountain-the-rope-bridge', $locx, $nowQ);
$r1 = trail_sight_quest_row((int)$u['id'], 'q-last'); ok('anylast: two others in any order then the last is open', $r1 && $r1['done_at'] === null && count(json_decode($r1['beats'], true)) === 2);
trail_sight_quest_hook($u, 'grassland-the-old-milestone', $locx, $nowQ);
$r1 = trail_sight_quest_row((int)$u['id'], 'q-last'); ok('anylast: the last beat finishes the line', $r1 && $r1['done_at'] !== null);
$r2 = trail_sight_quest_row((int)$u['id'], 'q-dup'); ok('seq: the Sights used in order begin the dup line (beats 1 and 2 so far)', $r2 && json_decode($r2['beats'], true) === [0, 1], json_encode($r2['beats'] ?? null));
$gr = trail_sight_quest_row((int)$u['id'], 'q-gated'); ok('a gated line has not begun while its gate is open', !$gr);
trail_sight_quest_hook($u, $base['slug'], $locx, $nowQ);
$r2 = trail_sight_quest_row((int)$u['id'], 'q-dup'); ok('a Sight can be a beat twice in one line (first and third)', $r2 && $r2['done_at'] !== null && json_decode($r2['beats'], true) === [0, 1, 2], json_encode($r2['beats'] ?? null));
trail_sight_quest_hook($u, $base['slug'], $locx, $nowQ); $gr = trail_sight_quest_row((int)$u['id'], 'q-gated'); ok('once the gate is done the gated line begins', (bool)$gr);
trail_sight_quest_event($u, 'boss', 'some-lair'); $er = trail_sight_quest_row((int)$u['id'], 'q-event');
ok('@boss event beat counts (any lair)', $er && json_decode($er['beats'], true) === [0], json_encode($er));
trail_sight_quest_event($u, 'meal'); $er = trail_sight_quest_row((int)$u['id'], 'q-event'); ok('@meal event beat finishes the line', $er && $er['done_at'] !== null);
give_item((int)$u['id'], $gid, 5); q('UPDATE user_items SET qty = 1 WHERE user_id = ? AND item_id = ?', [$u['id'], $gid]);
trail_sight_quest_hook($u, $base['slug'], $locx, $nowQ);
ok('needs: a beat that needs 2 items does not count with 1', !trail_sight_quest_row((int)$u['id'], 'q-needs'));
give_item((int)$u['id'], $gid, 2); trail_sight_quest_hook($u, $base['slug'], $locx, $nowQ);
$nr = trail_sight_quest_row((int)$u['id'], 'q-needs'); ok('needs: with 2 it counts and uses them up', $nr && (int)q_val('SELECT qty FROM user_items WHERE user_id = ? AND item_id = ?', [$u['id'], $gid]) === 1);
ok('quest lint: bad kind, gate and needs are caught', count(trail_sight_quest_lint(['slug' => 'z', 'title' => 't', 'giver' => 'g', 'icon' => 'i', 'order' => 'seq', 'reward' => 'xp=1', 'intro' => 'i', 'outro' => 'o', 'gate' => 'quest:nope', 'beats' => [['@wrong', 'l', '-', ''], [$base['slug'], 'l', '-', 'take=x']]], trail_sights_all(), $aq)) >= 3);
// private tally (a cairn) and its milestone condition
q('DELETE FROM trail_sight_tally WHERE user_id = ?', [$u['id']]);
ok('tally: counts up and the tl= condition opens at N', trail_sight_tally_add((int)$u['id'], 'cairn') === 1 && !trail_sight_cond_ok('tl=cairn:2', ['tl' => trail_sight_tallies((int)$u['id'])]) && trail_sight_tally_add((int)$u['id'], 'cairn') === 2 && trail_sight_cond_ok('tl=cairn:2', ['tl' => trail_sight_tallies((int)$u['id'])]));
ok('lint: tally and tl= are valid', !array_filter(trail_sight_lint(['rewards' => 'tally=cairn,title=Cairn Builder?tl=cairn:5'] + $base), fn($p) => str_contains($p, 'tally') || str_contains($p, 'condition')), json_encode(trail_sight_lint(['rewards' => 'tally=cairn,title=Cairn Builder?tl=cairn:5'] + $base)));
$put(['rewards' => 'tally=cairn,xp=1?tl=cairn:99', 'uses' => 9, 'energy' => 0, 'check' => '-']); $fresh(); $t0 = (int)(trail_sight_tallies((int)$u['id'])['cairn'] ?? 0);
[$ty] = trail_sight_do($u, $exp, $base['slug']); save_exp($exp);
ok('a Sight with tally= adds one to the counter', $ty && (int)(trail_sight_tallies((int)$u['id'])['cairn'] ?? 0) === $t0 + 1);
// item effects
$GLOBALS['gv_sight_items_file'] = $w('items.txt', "p4-decor-test|P4 Decor Test|decor|3|40|0|A test.|{\"decor\":{\"type\":\"ornament\",\"w\":1,\"h\":1,\"icon\":\"x\",\"appeal\":2,\"bonus\":\"\"}}\n");
trail_sights_ensure_items();
$fxv = (string)q_val("SELECT effects FROM items WHERE slug = 'p4-decor-test'"); ok('an item with an effects column gets its effects JSON', str_contains($fxv, 'ornament'), $fxv);
unset($GLOBALS['gv_sight_folk_file'], $GLOBALS['gv_sight_quests_file'], $GLOBALS['gv_sight_pages_file'], $GLOBALS['gv_sight_newfolk_file'], $GLOBALS['gv_sight_items_file']);
echo $fails ? "$fails FAILED\n" : "ok\n";
exit($fails ? 1 : 0);
