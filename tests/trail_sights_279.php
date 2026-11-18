<?php
// 2.7.08 Trail Sights engine gaps, second pass: buff=all (+N to every stat), fpall= (every villager of the start place), a free pick (pick:N + choose= with N
// options: every label right, label i pays reward i), quest order firstlast (first beat first, last beat last), a beat's gift (7th beat column), qd= (a quest line is done).
// php tests/trail_sights_279.php GAME_DIR   (an installed game, player "sprout"; walk.sh installs one). Route 240 section 1 has the clover patch (as trail_sights_278.php).
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
$lint = fn(array $chg, string $word) => array_values(array_filter(trail_sight_lint($chg + $base), fn($p) => str_contains($p, $word)));
$u = q_one("SELECT * FROM users WHERE username = 'sprout'");

echo "== buff=all: +N to every stat\n";
q('UPDATE users SET ev_stat = NULL, ev_amt = 0, ev_until = NULL, ev_day = NULL, ev_scope = NULL WHERE id = ?', [$u['id']]);
$u0 = q_one('SELECT * FROM users WHERE id = ?', [$u['id']]); $before = array_map(fn($s) => eff_stat($u0, $s), array_keys(GNOME_STATS));
$res = apply_event_effect($u0, 'buff:all:1:60'); $u1 = q_one('SELECT * FROM users WHERE id = ?', [$u['id']]);
$after = array_map(fn($s) => eff_stat($u1, $s), array_keys(GNOME_STATS));
ok('every stat is one higher', $after === array_map(fn($v) => $v + 1, $before), json_encode([$before, $after]));
ok('the line says every stat', str_contains(implode(' ', $res), '+1 every stat for 60 minutes'), json_encode($res));
ok('the effects list shows it', (bool)array_filter(active_effects($u1), fn($e) => $e[2] === 'Every stat +1'), json_encode(active_effects($u1)));
ok('lint: buff=all:1:60 is clean; a bad stat or shape is refused', !$lint(['rewards' => 'buff=all:1:60,buff=luck:2:sleep'], 'buff=') && (bool)$lint(['rewards' => 'buff=strength:1:60'], 'buff=') && (bool)$lint(['rewards' => 'buff=luck'], 'buff='));
q('UPDATE users SET ev_stat = NULL, ev_amt = 0, ev_until = NULL, ev_day = NULL, ev_scope = NULL WHERE id = ?', [$u['id']]);

echo "== fpall=: every villager of the start place\n";
$vil = q_one("SELECT * FROM locations WHERE kind = 'village' ORDER BY id LIMIT 1");
$folk = stop_folk_of($vil); $ids = array_map(fn($f) => (int)$f['id'], $folk);
$pts = fn() => array_map(fn($id) => stop_friend_points((int)$u['id'], $id), $ids);
$p0 = $pts(); $lines = trail_sight_pay($u, ['name' => 'a verb'] + $vil, 'fpall=2');
ok('each of the ' . count($ids) . ' villagers gets 2 points', count($ids) >= 2 && $pts() === array_map(fn($v) => $v + 2, $p0), json_encode([$p0, $pts()]));
ok('the line names the place (not the Sight verb)', (bool)array_filter($lines, fn($l) => str_contains($l, 'Everyone at ' . $vil['name'])), json_encode($lines));
ok('lint: fpall=2 is clean, fpall=0 / fpall=x refused', !$lint(['rewards' => 'fpall=2'], 'fpall') && (bool)$lint(['rewards' => 'fpall=0'], 'fpall') && (bool)$lint(['rewards' => 'fpall=x'], 'fpall'));

echo "== a free pick (pick:N + choose= with N options)\n";
$fp = ['check' => 'pick:3:dragon;chair;sofa', 'rewards' => 'choose=xp=5;c=4;en=2', 'lose' => 'No.'];
ok('trail_sight_free_pick: only when the counts match', trail_sight_free_pick($fp + $base) && !trail_sight_free_pick(['rewards' => 'choose=xp=5;c=4'] + $fp + $base) && !trail_sight_free_pick(['check' => '-'] + $fp + $base));
ok('lint: a matching choose= on a pick is clean; a mismatch is refused', !$lint($fp, 'choose=') && (bool)$lint(['rewards' => 'choose=xp=5;c=4'] + $fp, 'choose='));

echo "== a walk on route 240, standing at the clover patch\n";
set_setting('gnav_on', '1'); set_setting('gnav_tiles', '1'); set_setting('game_clock_on', '1'); setting('__reload__');
q("UPDATE expeditions SET status = 'done' WHERE user_id = ?", [$u['id']]);
q("UPDATE routes SET kind = 'road' WHERE id = 240");
$r = q_one('SELECT * FROM routes WHERE id = 240');
q("UPDATE users SET location_id = ?, level = 30, energy = 90, coins = 500, ev_quickwalk = 0, game_day = 10, game_minute = 360 WHERE id = ?", [$r['a_id'], $u['id']]);
q('DELETE FROM trail_sight_uses WHERE user_id = ?', [$u['id']]);
$u = q_one('SELECT * FROM users WHERE id = ?', [$u['id']]);
[$sok] = start_expedition($u, 240); ok('the walk starts', $sok);
$exp = active_expedition((int)$u['id']); $sc = trail_scene($exp);
$lm = array_values(array_filter($sc['map']['art']['objs'], fn($o) => $o[2] === 'lm-grassland-the-clover-patch'));
$spot = null; foreach ([[-1, 0], [1, 0], [0, -1], [0, 1], [0, 0]] as [$dx, $dy]) if (in_array(tm_tile($sc['map'], $lm[0][0] + $dx, $lm[0][1] + $dy), ['.', ',', 'S'], true)) { $spot = [$lm[0][0] + $dx, $lm[0][1] + $dy]; break; }
$sc['x'] = $spot[0]; $sc['y'] = $spot[1]; trail_save($sc);
trail_sights_ensure_tables();
$put = function (array $chg) use ($base) {
    $r = $chg + $base; q('DELETE FROM trail_sight_rows WHERE slug = ?', [$base['slug']]);
    db_insert('trail_sight_rows', ['slug' => $base['slug'], 'verb' => $r['verb'], 'icon' => $r['icon'], 'energy' => $r['energy'], 'cd' => $r['cd'], 'uses' => $r['uses'], 'cond' => $r['when'], 'chk' => $r['check'], 'rewards' => $r['rewards'], 'win' => $r['win'], 'lose' => $r['lose'], 'tool' => $r['tool'], 'fail_en' => $r['fail_en'], 'active' => 1]);
    q('DELETE FROM trail_sight_uses'); $GLOBALS['gv_sights_reload'] = true; trail_sights_all();
};
$fresh = function () use (&$u, &$exp) { $u = q_one('SELECT * FROM users WHERE id = ?', [$u['id']]); $exp = active_expedition((int)$u['id']); $GLOBALS['gv_sights_reload'] = true; };
$go = function (array $opt = []) use (&$u, &$exp, $base) { $x = trail_sight_do($u, $exp, $base['slug'], $opt); save_exp($exp); return $x; };
$put(['when' => '-', 'energy' => 0, 'uses' => 9] + $fp); $fresh();
[$a, $m] = $go(); ok('a free pick without a choice is refused', !$a, (string)$m);
$res = [];
foreach ([0, 1, 2] as $i) { $fresh(); $xp0 = (int)$u['xp']; $c0 = (int)$u['coins']; $e0 = (int)$u['energy']; [$a] = $go(['pick' => $i]); $fresh(); $res[] = [$a, (int)$u['xp'] > $xp0, (int)$u['coins'] > $c0, (int)$u['energy'] > $e0]; }
ok('every label wins and pays its own reward (xp / Petals / energy)', $res === [[true, true, false, false], [true, false, true, false], [true, false, false, true]], json_encode($res));
$fresh(); $c0 = (int)$u['coins']; [$a] = $go(['reward' => 1]); $fresh();
ok('the card\'s reward button (reward=i) works the same', $a && (int)$u['coins'] > $c0);
$sc = trail_scene($exp); $marks = trail_sights_marks_build($u, $sc);
$html = trail_sights_cards_html($u, $sc, array_values(array_filter($marks, fn($mk) => $mk['slug'] === $base['slug'])), $exp);
ok('the card shows one button per label with its reward', str_contains($html, 'each gives its own reward') && str_contains($html, 'dragon: ') && str_contains($html, 'sofa: '), substr(strip_tags($html), 0, 300));
q('DELETE FROM trail_sight_rows WHERE slug = ?', [$base['slug']]);

echo "== quest order firstlast, a beat's gift, qd=\n";
$qfile = $argv[1] . '/includes/data/trail_sight_quests.txt'; $qorig = file_get_contents($qfile);
$slugs = array_slice(array_keys(trail_sights_all()), 0, 4);
file_put_contents($qfile, $qorig . "\nQ|zz-fl-quest|First and Last|Test Giver|🧭|firstlast|xp=1:1|Begin at the start.|All done.\nB|zz-fl-quest|{$slugs[0]}|start|-\nB|zz-fl-quest|{$slugs[1]}|middle a|-||item=garden-honey:1\nB|zz-fl-quest|{$slugs[2]}|middle b|-\nB|zz-fl-quest|{$slugs[3]}|finish|-\n");
$qs = trail_sight_quests(); $qq = $qs['zz-fl-quest'] ?? null;
ok('firstlast loads, the 7th beat column is the gift', $qq && $qq['order'] === 'firstlast' && $qq['beats'][1][4] === 'item=garden-honey:1', json_encode($qq));
ok('quest lint: the line is clean; a bad gift is refused', $qq && !trail_sight_quest_lint($qq, trail_sights_all(), $qs) && (bool)trail_sight_quest_lint(['beats' => [[$slugs[0], 'a', '-', '', 'take=garden-honey:1'], [$slugs[1], 'b', '-', '', 'item=no-such-thing:1']]] + $qq, trail_sights_all(), $qs), json_encode($qq ? trail_sight_quest_lint($qq, trail_sights_all(), $qs) : null));
ok('beat_open: only the first beat at the start', $qq && trail_sight_beat_open($qq, [], 0) && !trail_sight_beat_open($qq, [], 1) && !trail_sight_beat_open($qq, [], 3));
ok('beat_open: after the first, the middle ones in any order, not the last', $qq && trail_sight_beat_open($qq, [0], 2) && trail_sight_beat_open($qq, [0], 1) && !trail_sight_beat_open($qq, [0], 3) && !trail_sight_beat_open($qq, [0, 2], 3) && trail_sight_beat_open($qq, [0, 2, 1], 3));
q('DELETE FROM user_sight_quests WHERE user_id = ? AND quest = ?', [$u['id'], 'zz-fl-quest']);
$hid = (int)q_val("SELECT id FROM items WHERE slug = 'garden-honey'"); q('DELETE FROM user_items WHERE user_id = ? AND item_id = ?', [$u['id'], $hid]);
$locq = ['id' => (int)$u['location_id'], 'region_id' => 0, 'landscape' => 'forest', 'kind' => 'village', 'name' => 'x'];
$nowq = fn() => ['gd' => 10, 'dp' => 'day', 'se' => 'summer', 'we' => 'clear', 'hp' => '', 'st' => 'normal', 'pal' => '0', 'mo' => 'full', 'ti' => 'low', 'tl' => trail_sight_tallies((int)$u['id']), 'qd' => [], 'towns' => []];
$o = trail_sight_quest_hook($u, $slugs[3], $locq, $nowq());
ok('the last beat does not start the line', !array_filter($o, fn($x) => str_contains($x, 'First and Last')), json_encode($o));
$o = trail_sight_quest_hook($u, $slugs[1], $locq, $nowq());
ok('a middle beat does not start it either', !array_filter($o, fn($x) => str_contains($x, 'First and Last')), json_encode($o));
$o = trail_sight_quest_hook($u, $slugs[0], $locq, $nowq());
ok('the first beat starts it', (bool)array_filter($o, fn($x) => str_contains($x, 'A quest begins: First and Last')), json_encode($o));
$o = trail_sight_quest_hook($u, $slugs[1], $locq, $nowq());
ok('the gift beat counts and hands its item over', (bool)array_filter($o, fn($x) => str_contains($x, 'middle a') && str_contains($x, 'Garden Honey')) && (int)q_val('SELECT qty FROM user_items WHERE user_id = ? AND item_id = ?', [$u['id'], $hid]) === 1, json_encode($o));
ok('qd= is false before the line is done', !trail_sight_cond_ok('qd=zz-fl-quest', trail_sight_now($locq, null, $u)));
trail_sight_quest_hook($u, $slugs[2], $locq, $nowq()); $o = trail_sight_quest_hook($u, $slugs[3], $locq, $nowq());
ok('the last beat finishes it', (bool)array_filter($o, fn($x) => str_contains($x, 'First and Last is done')), json_encode($o));
ok('qd= is true once the line is done (any one of a list)', trail_sight_cond_ok('qd=zz-fl-quest', trail_sight_now($locq, null, $u)) && trail_sight_cond_ok('qd=nope,zz-fl-quest', trail_sight_now($locq, null, $u)) && !trail_sight_cond_ok('qd=nope', trail_sight_now($locq, null, $u)));
q('DELETE FROM user_sight_quests WHERE user_id = ? AND quest = ?', [$u['id'], 'zz-fl-quest']); q('DELETE FROM user_items WHERE user_id = ? AND item_id = ?', [$u['id'], $hid]);
file_put_contents($qfile, $qorig); trail_sight_quests();

echo $fails ? "$fails FAILED\n" : "ok\n";
exit($fails ? 1 : 0);
