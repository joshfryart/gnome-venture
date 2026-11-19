<?php
// 2.7.00 Trail Sights engine gaps: every-Nth-game-day timing (gd=M:R), choose-your-reward (choose=A;B), shop / inn discounts (disc=), tool-tier odds (@a/b/c/d), a villager's own stat check (check=).
// php tests/trail_sights_270.php GAME_DIR   (an installed game, player "sprout"; walk.sh installs one). Route 240 section 1 has the clover patch (as tests/trail_sights.php).
$_SERVER['SCRIPT_NAME'] = '/adventure.php';
require $argv[1] . '/includes/bootstrap.php';
require_once $argv[1] . '/includes/adventure.php';
require_once $argv[1] . '/includes/trail_tiles.php';
require_once $argv[1] . '/includes/trail_sights.php';
require_once $argv[1] . '/includes/tools.php';
$fails = 0;
set_setting('npc_clockwork', '0');
set_setting('sights_walk_cap', '0');   // 2.7.08: many Sight uses on one walk here (the cap: trail_sights_278.php)
$GLOBALS['gv_sights_nocache'] = true;
set_exception_handler(function (Throwable $e) { echo '  EXCEPTION ' . get_class($e) . ': ' . $e->getMessage() . ' @ ' . basename($e->getFile()) . ':' . $e->getLine() . "\n"; exit(1); });
function ok(string $what, bool $cond, string $extra = ''): void { global $fails; echo ($cond ? '  ok   ' : '  FAIL ') . $what . ($cond ? '' : "  $extra") . "\n"; if (!$cond) $fails++; }
$all = trail_sights_all(); $base = $all['grassland-the-clover-patch'];

echo "== conditions: gd = every Mth game day\n";
ok('gd=7:3 holds on day 3, 10, 24 and not on day 4', trail_sight_cond_ok('gd=7:3', ['gd' => 3]) && trail_sight_cond_ok('gd=7:3', ['gd' => 10]) && trail_sight_cond_ok('gd=7:3', ['gd' => 24]) && !trail_sight_cond_ok('gd=7:3', ['gd' => 4]));
ok('several values: any one', trail_sight_cond_ok('gd=7:0,7:3', ['gd' => 14]) && trail_sight_cond_ok('gd=7:0,7:3', ['gd' => 17]) && !trail_sight_cond_ok('gd=7:0,7:3', ['gd' => 15]));
ok('it combines with another condition', trail_sight_cond_ok('gd=7:3/dp=dusk', ['gd' => 3, 'dp' => 'dusk']) && !trail_sight_cond_ok('gd=7:3/dp=dusk', ['gd' => 3, 'dp' => 'dawn']));
ok('the card text says it', str_contains(trail_sight_cond_text('gd=7:3'), 'every 7th game day'), trail_sight_cond_text('gd=7:3'));
ok('lint takes gd and refuses a bad one', !trail_sight_lint(['when' => 'gd=7:3'] + $base) && (bool)trail_sight_lint(['when' => 'gd=7'] + $base) && (bool)trail_sight_lint(['when' => 'gd=a:b'] + $base));

echo "== lint of the new tokens\n";
$bad = fn(string $rw, array $more = []) => (bool)trail_sight_lint(['rewards' => $rw] + $more + $base);
ok('choose= needs 2 to 4 plain rewards', !$bad('choose=c=5:1;en=2') && $bad('choose=c=5:1') && $bad('choose=c=5:1;en=2;xp=3;xp=4;xp=5') && $bad('choose=c=5:1;title=Boss'));
ok('choose= cannot go with a pick check', $bad('choose=c=5:1;en=2', ['check' => 'pick:3']));
ok('disc= needs rest|shop:percent:minutes', !$bad('disc=rest:10:120') && !$bad('disc=shop:15:60') && $bad('disc=inn:10:60') && $bad('disc=rest:0:60') && $bad('disc=rest:10'));
ok('tier odds need a tool column', $bad('xp=5@5/10', ['tool' => '-']) === true && !$bad('xp=5@5/10/20/40', ['tool' => 'forage:1']) && $bad('xp=5@5/10/200', ['tool' => 'forage:1']));
ok('check= needs stat:dc', !$bad('check=grit:12') && $bad('check=grit') );

echo "== tier odds\n";
ok('a tier picks its number, none or tier 1 the first, past the end the last', trail_sight_tier_chance('item=x:1@5/15/30', 2) === 'item=x:1@15' && trail_sight_tier_chance('item=x:1@5/15/30', 0) === 'item=x:1@5' && trail_sight_tier_chance('item=x:1@5/15/30', 4) === 'item=x:1@30' && trail_sight_tier_chance('xp=3@50', 3) === 'xp=3@50');

echo "== rewards pass (approved: 3% a level by default)\n";
ok('the default is 3 (Josh approved 2026-11-15)', (string)setting('sights_flat_pct_per_level') === '3', (string)setting('sights_flat_pct_per_level'));
set_setting('sights_flat_pct_per_level', '0'); setting('__reload__');
ok('set to 0: nothing changes', trail_sight_flat_scale('xp=10', 35) === 'xp=10');
set_setting('sights_flat_pct_per_level', '3'); setting('__reload__');
ok('on: a flat reward grows 3% a level above 1 (level 35: 10 -> 20)', trail_sight_flat_scale('xp=10', 35) === 'xp=20' && trail_sight_flat_scale('xp=10', 1) === 'xp=10' && trail_sight_flat_scale('c=20@20', 11) === 'c=26@20', trail_sight_flat_scale('xp=10', 35));
ok('a reward with a per-level part, and other tokens, are left alone', trail_sight_flat_scale('xp=3:1', 35) === 'xp=3:1' && trail_sight_flat_scale('item=x:1', 35) === 'item=x:1' && trail_sight_flat_scale('en=3', 35) === 'en=3');
set_setting('sights_flat_pct_per_level', '0'); setting('__reload__');

echo "== a walk on route 240, standing at the clover patch\n";
set_setting('gnav_on', '1'); set_setting('gnav_tiles', '1'); set_setting('game_clock_on', '1'); setting('__reload__');
$u = q_one("SELECT * FROM users WHERE username = 'sprout'");
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
$coins = fn() => (int)q_val('SELECT coins FROM users WHERE id = ?', [$u['id']]);
$xp = fn() => (int)q_val('SELECT xp FROM users WHERE id = ?', [$u['id']]);
$energy = fn() => (int)q_val('SELECT energy FROM users WHERE id = ?', [$u['id']]);

echo "== timing: gd\n";
$put(['when' => 'gd=7:3', 'energy' => 0, 'rewards' => 'xp=2:1']); $fresh();   // game day 10 = 10 mod 7 = 3
[$a] = $go(); ok('on game day 10 (10 mod 7 = 3) the Sight works', $a);
q('UPDATE users SET game_day = 11 WHERE id = ?', [$u['id']]); $put(['when' => 'gd=7:3', 'energy' => 0, 'rewards' => 'xp=2:1']); $fresh();
[$a, $m] = $go(); ok('on game day 11 it is not the right time, and says every 7th game day', !$a && str_contains((string)$m, 'every 7th game day'), (string)$m);
q('UPDATE users SET game_day = 10 WHERE id = ?', [$u['id']]);

echo "== popup (2.7.06)\n";
if (session_status() !== PHP_SESSION_ACTIVE) { @session_id('trailsights270'); @session_start(); }
unset($_SESSION['event_box']);
$put(['energy' => 0, 'rewards' => 'xp=3:1,c=7:1', 'check' => '-']); $fresh();
[$pa] = $go();
ok('a Sight that gives something also raises the event popup with its lines', $pa && !empty($_SESSION['event_box']) && !empty($_SESSION['event_box']['lines']) && (string)$_SESSION['event_box']['title'] === (string)$base['verb'], json_encode($_SESSION['event_box'] ?? null));
unset($_SESSION['event_box']);
echo "== streaks (2.7.06)\n";
$put(['when' => '-', 'energy' => 0, 'rewards' => 'streak=sk-test,xp=1:1,c=9:1?sk=sk-test:3', 'check' => '-']); $fresh();
q('DELETE FROM trail_sight_tally WHERE user_id = ?', [$u['id']]);
$cl = fn() => (int)q_val('SELECT coins FROM users WHERE id = ?', [$u['id']]);
$days = [10, 10, 11, 12, 14, 15];   // two uses on day 10, then 11, 12 (streak 3 pays), a gap, then 14, 15
$res = []; foreach ($days as $d) { q('UPDATE users SET game_day = ?, game_minute = 360 WHERE id = ?', [$d, $u['id']]); q('DELETE FROM trail_sight_uses WHERE user_id = ?', [$u['id']]); $fresh(); $c0 = $cl(); $go(); $res[] = [$d, (int)q_val("SELECT n FROM trail_sight_tally WHERE user_id = ? AND tkey = 'sk-test#streak'", [$u['id']]), $cl() - $c0 > 0]; }
ok('a streak counts consecutive game days, the same day twice changes nothing, a gap starts over', array_column($res, 1) === [1, 1, 2, 3, 1, 2], json_encode($res));
ok('the sk=key:3 reward pays only on the use that reaches 3 days in a row', array_column($res, 2) === [false, false, false, true, false, false], json_encode($res));
ok('the lint accepts sk= and streak=', !array_filter(trail_sight_lint(['rewards' => 'streak=a,xp=1:1?sk=a:3', 'lose' => 'x'] + $base), fn($p) => str_contains($p, 'streak') || str_contains($p, 'condition') || str_contains($p, 'unknown reward')), json_encode(trail_sight_lint(['rewards' => 'streak=a,xp=1:1?sk=a:3', 'lose' => 'x'] + $base)));
q('UPDATE users SET game_day = 10 WHERE id = ?', [$u['id']]); $fresh();
echo "== loans (2.7.06)\n";
$hid = (int)q_val("SELECT id FROM items WHERE slug = 'garden-honey'"); $hq = fn() => (int)q_val('SELECT COALESCE(SUM(qty),0) FROM user_items WHERE user_id = ? AND item_id = ?', [$u['id'], $hid]);
q('DELETE FROM user_items WHERE user_id = ? AND item_id = ?', [$u['id'], $hid]); give_item((int)$u['id'], $hid, 3); q('DELETE FROM trail_sight_tally WHERE user_id = ?', [$u['id']]);
$put(['when' => '-', 'energy' => 0, 'rewards' => 'lend=garden-honey:1,repay=garden-honey:2,xp=1:1', 'check' => '-']); $fresh();
$h0 = $hq(); [$l1] = $go(); $h1 = $hq(); q('DELETE FROM trail_sight_uses WHERE user_id = ?', [$u['id']]); $fresh();
[$l2] = $go(); $h2 = $hq(); q('DELETE FROM trail_sight_uses WHERE user_id = ?', [$u['id']]); $fresh();
[$l3] = $go(); $h3 = $hq();
ok('first use lends 1 honey, the next use gives 2 back, the third lends again', $l1 && $l2 && $l3 && [$h0, $h1, $h2, $h3] === [3, 2, 4, 3], json_encode([$h0, $h1, $h2, $h3]));
q('DELETE FROM user_items WHERE user_id = ? AND item_id = ?', [$u['id'], $hid]); q('DELETE FROM trail_sight_uses WHERE user_id = ?', [$u['id']]); q("DELETE FROM trail_sight_tally WHERE user_id = ? AND tkey LIKE 'lend#%'", [$u['id']]); $fresh();
[$l4, $m4] = $go(); ok('with nothing to lend the first use says what is needed', !$l4 && str_contains((string)$m4, 'to lend here'), (string)$m4);
echo "== buff until sleep (2.7.06)\n";
require_once $argv[1] . '/includes/events.php'; require_once $argv[1] . '/includes/gnome.php';
set_setting('game_clock_on', '1'); setting('__reload__');
q('UPDATE users SET game_day = 20, ev_stat = NULL, ev_amt = 0, ev_until = NULL, ev_day = NULL WHERE id = ?', [$u['id']]);
$ub = q_one('SELECT * FROM users WHERE id = ?', [$u['id']]); $base0 = eff_stat($ub, 'luck');
$bl = apply_event_effect($ub, 'buff:luck:2:sleep'); $ub = q_one('SELECT * FROM users WHERE id = ?', [$u['id']]);
ok('a buff:luck:2:sleep gives +2 now and says until you sleep', eff_stat($ub, 'luck') === $base0 + 2 && str_contains(implode(' ', $bl), 'until you sleep') && (int)$ub['ev_day'] === 20, json_encode([$bl, $ub['ev_day'], eff_stat($ub, 'luck'), $base0]));
q('UPDATE users SET game_day = 21 WHERE id = ?', [$u['id']]); $ub = q_one('SELECT * FROM users WHERE id = ?', [$u['id']]);
ok('after a sleep (next game day) the lucky moment is over', eff_stat($ub, 'luck') === $base0, (string)eff_stat($ub, 'luck'));
// next-section buff: lasts until the walk is in another Trail section
unset($GLOBALS['gv_walk_sec']); $wkNow = gnome_walk_section((int)$u['id']);
if ($wkNow !== null) {
    q('UPDATE users SET ev_stat = NULL, ev_amt = 0, ev_until = NULL, ev_day = NULL, ev_scope = NULL WHERE id = ?', [$u['id']]);
    $ub = q_one('SELECT * FROM users WHERE id = ?', [$u['id']]); $bs = apply_event_effect($ub, 'buff:luck:2:section'); $ub = q_one('SELECT * FROM users WHERE id = ?', [$u['id']]);
    ok('a section buff gives +2 in this Trail section and says until the next', eff_stat($ub, 'luck') === $base0 + 2 && str_contains(implode(' ', $bs), 'until the next section'), json_encode([$bs, eff_stat($ub, 'luck'), $base0]));
    $wrow = q_one('SELECT * FROM walk_scene WHERE user_id = ? ORDER BY id DESC LIMIT 1', [$u['id']]); $wst = json_decode((string)$wrow['state'], true); $wst['sec'] = (int)$wst['sec'] + 1;
    q('UPDATE walk_scene SET state = ? WHERE id = ?', [json_encode($wst), $wrow['id']]); unset($GLOBALS['gv_walk_sec']); $ub = q_one('SELECT * FROM users WHERE id = ?', [$u['id']]);
    ok('once the walk is in the next section the buff is over', eff_stat($ub, 'luck') === $base0, (string)eff_stat($ub, 'luck'));
    $wst['sec'] = (int)$wst['sec'] - 1; q('UPDATE walk_scene SET state = ? WHERE id = ?', [json_encode($wst), $wrow['id']]); unset($GLOBALS['gv_walk_sec']);
} else echo "  (no Trail walk here: section buff check skipped)\n";
q('UPDATE users SET ev_stat = NULL, ev_amt = 0, ev_until = NULL, ev_day = NULL, ev_scope = NULL WHERE id = ?', [$u['id']]);
// delve / lair scoped buff
q('UPDATE users SET ev_stat = NULL, ev_amt = 0, ev_until = NULL, ev_day = NULL, ev_scope = NULL, game_day = 10 WHERE id = ?', [$u['id']]);
unset($GLOBALS['gv_ev_run']);   // (the walk the later checks use is a 'walk', not a delve: it does not count)
$ub = q_one('SELECT * FROM users WHERE id = ?', [$u['id']]); $bd = apply_event_effect($ub, 'buff:luck:2:delve'); $ub = q_one('SELECT * FROM users WHERE id = ?', [$u['id']]);
ok('a delve buff says where it works and does nothing outside a run', str_contains(implode(' ', $bd), 'delves and lairs') && eff_stat($ub, 'luck') === $base0, json_encode([$bd, eff_stat($ub, 'luck'), $base0]));
$lmx = (int)q_val('SELECT id FROM locations ORDER BY id LIMIT 1');
$eid = db_insert('expeditions', ['user_id' => $u['id'], 'from_id' => $lmx, 'to_id' => $lmx, 'kind' => 'delve', 'status' => 'active', 'step' => 0, 'steps_total' => 3, 'hp' => 10, 'max_hp' => 10, 'level' => 3, 'log' => '[]', 'route_id' => 1, 'started_at' => now(), 'arrive_at' => now()]);
unset($GLOBALS['gv_ev_run']); $ub = q_one('SELECT * FROM users WHERE id = ?', [$u['id']]);
ok('while a delve run is active the buff counts (+2)', eff_stat($ub, 'luck') === $base0 + 2, (string)eff_stat($ub, 'luck'));
q("UPDATE expeditions SET status = 'done' WHERE id = ?", [$eid]); unset($GLOBALS['gv_ev_run']);
q('UPDATE users SET ev_stat = NULL, ev_amt = 0, ev_until = NULL, ev_day = NULL, ev_scope = NULL, game_day = 10 WHERE id = ?', [$u['id']]);
echo "== quest time limit (2.7.06)\n";
$qfile = $argv[1] . '/includes/data/trail_sight_quests.txt'; $qorig = file_get_contents($qfile);
$slugs = array_slice(array_keys(trail_sights_all()), 0, 3);
file_put_contents($qfile, $qorig . "\nQ|zz-limit-quest|Hurry Up|Test Giver|⌛|seq|xp=1:1|The clock starts.|Done in time.||3\nB|zz-limit-quest|{$slugs[0]}|first step|-\nB|zz-limit-quest|{$slugs[1]}|second step|-\nB|zz-limit-quest|{$slugs[2]}|third step|-\n");
$qs = trail_sight_quests(); $qq = $qs['zz-limit-quest'] ?? null;
ok('a quest row with a 11th column limit loads with limit 3', $qq && $qq['limit'] === 3 && count($qq['beats']) === 3, json_encode($qq));
q('DELETE FROM user_sight_quests WHERE user_id = ? AND quest = ?', [$u['id'], 'zz-limit-quest']); q("DELETE FROM trail_sight_tally WHERE user_id = ? AND tkey = 'qstart#zz-limit-quest'", [$u['id']]);
$locq = ['id' => (int)$u['location_id'], 'region_id' => 0, 'landscape' => 'forest', 'kind' => 'village', 'name' => 'x'];
$nowq = fn(int $gd) => ['gd' => $gd, 'dp' => 'day', 'se' => 'summer', 'we' => 'clear', 'hp' => '', 'st' => 'normal', 'pal' => '0', 'mo' => 'full', 'ti' => 'low', 'tl' => trail_sight_tallies((int)$u['id']), 'qd' => [], 'towns' => []];
$o1 = trail_sight_quest_hook($u, $slugs[0], $locq, $nowq(50));
ok('the first beat starts the quest and says how long it has', (bool)array_filter($o1, fn($x) => str_contains($x, 'A quest begins') && str_contains($x, '3 game days')), json_encode($o1));
$o2 = trail_sight_quest_hook($u, $slugs[1], $locq, $nowq(52));
ok('within the limit (day 52 of 50 + 3) the second beat counts', (bool)array_filter($o2, fn($x) => str_contains($x, 'second step')), json_encode($o2));
$o3 = trail_sight_quest_hook($u, $slugs[2], $locq, $nowq(54));
ok('past the limit (day 54 > 50 + 3) the quest times out instead of counting', (bool)array_filter($o3, fn($x) => str_contains($x, 'Time ran out')) && !q_val('SELECT 1 FROM user_sight_quests WHERE user_id = ? AND quest = ?', [$u['id'], 'zz-limit-quest']), json_encode($o3));
$o4 = trail_sight_quest_hook($u, $slugs[0], $locq, $nowq(55));
ok('the next first beat starts it again from the beginning', (bool)array_filter($o4, fn($x) => str_contains($x, 'A quest begins')), json_encode($o4));
q('DELETE FROM user_sight_quests WHERE user_id = ? AND quest = ?', [$u['id'], 'zz-limit-quest']); file_put_contents($qfile, $qorig); trail_sight_quests();
echo "== take any (2.7.06)\n";
$nuts = trail_sight_any_items('nut'); ok('take=any-nut finds the nut crops\' produce (at least two kinds)', count($nuts) >= 2, json_encode($nuts));
if (count($nuts) >= 2) {
    q('DELETE FROM user_items WHERE user_id = ? AND item_id IN (' . implode(',', $nuts) . ')', [$u['id']]);
    give_item((int)$u['id'], $nuts[0], 1);
    $put(['when' => '-', 'energy' => 0, 'rewards' => 'take=any-nut:2,xp=1:1', 'check' => '-']); $fresh();
    [$t1, $tm1] = $go(); ok('with only one nut it says what is missing', !$t1 && str_contains((string)$tm1, 'any nut'), (string)$tm1);
    give_item((int)$u['id'], $nuts[1], 1); q('DELETE FROM trail_sight_uses WHERE user_id = ?', [$u['id']]); $fresh();
    [$t2] = $go(); $left = (int)q_val('SELECT COALESCE(SUM(qty),0) FROM user_items WHERE user_id = ? AND item_id IN (' . implode(',', $nuts) . ')', [$u['id']]);
    ok('two different nuts are enough and both are used up', $t2 && $left === 0, json_encode([$t2, $left]));
    ok('the lint accepts take=any-nut:2', !array_filter(trail_sight_lint(['rewards' => 'take=any-nut:2,xp=1:1', 'lose' => 'x'] + $base), fn($p) => str_contains($p, 'no item') || str_contains($p, 'unknown')), json_encode(trail_sight_lint(['rewards' => 'take=any-nut:2,xp=1:1', 'lose' => 'x'] + $base)));
}
echo "== festival days (2.7.06)\n";
$base0 = ['dp' => 'day', 'se' => 'summer', 'we' => 'clear', 'hp' => '', 'st' => 'normal', 'pal' => '0', 'mo' => 'full', 'ti' => 'low', 'gd' => 5, 'tl' => [], 'qd' => []];
ok('fd=yes holds on a festival day, fd=<slug> only for that festival, neither without one', trail_sight_cond_ok('fd=yes', ['fd' => 'spring-fair'] + $base0) && trail_sight_cond_ok('fd=spring-fair,harvest', ['fd' => 'spring-fair'] + $base0) && !trail_sight_cond_ok('fd=harvest', ['fd' => 'spring-fair'] + $base0) && !trail_sight_cond_ok('fd=yes', ['fd' => ''] + $base0));
ok('the lint accepts fd= and the card text says festival day', preg_match(TRAIL_SIGHT_COND_RE, 'fd=yes') === 1 && preg_match(TRAIL_SIGHT_COND_RE, 'fd=spring-fair') === 1 && trail_sight_cond_text('fd=yes') === 'on a festival day');

echo "== escort (2.7.06)\n";
$ef = q_one("SELECT name FROM stop_folk WHERE active = 1 ORDER BY id LIMIT 1");
if ($ef && trail_escort_pic((string)$ef['name']) !== '') {
    $put(['when' => '-', 'energy' => 0, 'rewards' => 'xp=1:1,escort=' . $ef['name'], 'check' => '-']); $fresh();
    $scE = trail_scene($exp); $scE['st'] = array_diff_key($scE['st'], ['escort' => 1]); trail_save($scE);
    [$eo] = $go(); $scE = trail_scene($exp);
    ok('a Sight with escort=Name puts the villager in the walk state', $eo && ($scE['st']['escort'] ?? '') === $ef['name'], json_encode($scE['st']['escort'] ?? null));
    $html = trail_view_html($u, $exp, $scE, false);
    ok('the Trail map draws the companion beside the gnome (tmescort picture)', str_contains($html, 'tmescort'), substr($html, 0, 120));
    $scE['st'] = array_diff_key($scE['st'], ['escort' => 1]); trail_save($scE); $scE = trail_scene($exp);
    ok('without an escort nothing extra is drawn', !str_contains(trail_view_html($u, $exp, $scE, false), 'tmescort'));
} else echo "  (no villager with a picture here: escort check skipped)\n";
q('DELETE FROM trail_sight_uses WHERE user_id = ?', [$u['id']]); $fresh();
echo "== find popup (2.7.06)\n";
if (session_status() !== PHP_SESSION_ACTIVE) { @session_id('trailsights270'); @session_start(); }
unset($_SESSION['event_box']);
$fl = find_popup('🪙 You find 12 Petals glinting in the dirt.'); find_popup('✨ You find Acorn.');
ok('a wander find raises the popup and returns the line unchanged; a second find joins it', $fl === '🪙 You find 12 Petals glinting in the dirt.' && ($_SESSION['event_box']['title'] ?? '') === 'You found something!' && count($_SESSION['event_box']['lines'] ?? []) === 2, json_encode($_SESSION['event_box'] ?? null));
$_SESSION['event_box'] = ['icon' => 'x', 'title' => 'Other', 'text' => '', 'lines' => ['a']]; find_popup('🪙 You find 3 Petals.');
ok('a popup that something else raised is not overwritten or mixed into', ($_SESSION['event_box']['title'] ?? '') === 'Other' && count($_SESSION['event_box']['lines']) === 1);
unset($_SESSION['event_box']); find_popup('👀 You spot something shiny but cannot reach it.');
ok('a hint ("👀 ...") is not a find and raises nothing', empty($_SESSION['event_box']));
echo "== time= (2.7.06)\n";
q('UPDATE users SET game_day = 10, game_minute = 360 WHERE id = ?', [$u['id']]);
$put(['when' => '-', 'energy' => 0, 'rewards' => 'xp=1:1', 'check' => '-']); $fresh(); [$tA] = $go(); $mA = (int)q_val('SELECT game_minute FROM users WHERE id = ?', [$u['id']]);
q('UPDATE users SET game_day = 10, game_minute = 360 WHERE id = ?', [$u['id']]); q('DELETE FROM trail_sight_uses WHERE user_id = ?', [$u['id']]);
$put(['when' => '-', 'energy' => 0, 'rewards' => 'xp=1:1,time=90', 'check' => '-']); $fresh(); [$tB] = $go(); $mB = (int)q_val('SELECT game_minute FROM users WHERE id = ?', [$u['id']]);
ok('time=90 makes the Sight take 90 game minutes longer than the same Sight without it', $tA && $tB && $mB - $mA === 90, json_encode([$mA, $mB]));
q('UPDATE users SET game_day = 10, game_minute = 360 WHERE id = ?', [$u['id']]); q('DELETE FROM trail_sight_uses WHERE user_id = ?', [$u['id']]);
echo "== choose your reward\n";
$put(['energy' => 0, 'rewards' => 'choose=c=40:1;en=4', 'check' => '-']); $fresh();
$ci = trail_sight_choose_info(trail_sights_all()[$base['slug']]);
ok('the card gets two options with names', count($ci) === 2 && str_contains($ci[0][1], '40') && str_contains($ci[1][1], '4 energy'), json_encode($ci));
[$a, $m] = $go(); ok('using it without a choice is refused', !$a && str_contains((string)$m, 'Choose your reward'), (string)$m);
[$a, $m] = $go(['reward' => 5]); ok('a choice that is not on offer is refused', !$a);
q('UPDATE users SET energy = 50, coins = 500 WHERE id = ?', [$u['id']]); $fresh(); $c0 = $coins(); $e0 = $energy();
[$a] = $go(['reward' => 0]);
ok('choosing the Petals pays Petals and no energy', $a && $coins() > $c0 && $energy() === $e0, "coins $c0 -> " . $coins() . ", energy $e0 -> " . $energy());
$put(['energy' => 0, 'rewards' => 'choose=c=40:1;en=4']); q('UPDATE users SET energy = 50, coins = 500 WHERE id = ?', [$u['id']]); $fresh(); $c0 = $coins(); $e0 = $energy();
[$a] = $go(['reward' => 1]);
ok('choosing the energy pays energy and no Petals', $a && $energy() === $e0 + 4 && $coins() === $c0, "coins $c0 -> " . $coins() . ", energy $e0 -> " . $energy());
ok('the card form offers the options as buttons', str_contains(trail_sights_cards_html($u, trail_scene($exp), trail_sights_marks($u, trail_scene($exp))), 'name="reward"'));

echo "== discounts\n";
$put(['energy' => 0, 'rewards' => 'disc=rest:25:120,disc=shop:20:60']); $fresh();
[$a] = $go(); ok('the Sight gives both discounts', $a && trail_sight_disc_pct((int)$u['id'], 'rest') === 25 && trail_sight_disc_pct((int)$u['id'], 'shop') === 20);
ok('the inn room is 25% cheaper', gclock_inn_fee((int)$u['id']) === (int)round(gclock_setting_int('inn_fee_petals', 110) * 0.75), (string)gclock_inn_fee((int)$u['id']));
$p0 = shop_price(array_replace($u, ['id' => (int)$u['id']]), 100, 1, 0);
q('UPDATE users SET ev_disc = NULL WHERE id = ?', [$u['id']]); $p1 = shop_price($u, 100, 1, 0);
ok('shops charge less while it lasts (20 points off)', $p0 < $p1 && $p1 - $p0 >= 15, "$p0 vs $p1");
trail_sight_disc_set((int)$u['id'], 'shop', 20, 60); q('UPDATE users SET ev_disc = ? WHERE id = ?', [json_encode(['shop' => [20, time() - 5]]), $u['id']]);
ok('a run-out discount counts for nothing', trail_sight_disc_pct((int)$u['id'], 'shop') === 0);
trail_sight_disc_set((int)$u['id'], 'rest', 10, 60); trail_sight_disc_set((int)$u['id'], 'rest', 5, 60);
ok('a smaller discount never replaces a bigger one', trail_sight_disc_pct((int)$u['id'], 'rest') === 10);
q('UPDATE users SET ev_disc = NULL WHERE id = ?', [$u['id']]);

echo "== tool-tier odds\n";
$mk = function (int $tier) use ($u) { $slug = "sg-test-forage-$tier"; if (!item_id_by_slug($slug)) db_insert('items', ['name' => "Test forage $tier", 'slug' => $slug, 'category' => 'tool', 'rarity' => 5, 'base_price' => 1, 'description' => 't', 'edible' => 0, 'effects' => json_encode(['tool' => 'forage', 'tier' => $tier]), 'tradable' => 0]); give_item((int)$u['id'], item_id_by_slug($slug), 1); tool_cache_reset(); };
q('DELETE FROM user_items WHERE user_id = ? AND item_id IN (SELECT id FROM items WHERE effects LIKE ?)', [$u['id'], '%"tool":"forage"%']); tool_cache_reset();
$mk(1);
$put(['energy' => 0, 'tool' => 'forage:1', 'rewards' => 'xp=50:1@0/100']); $fresh(); $x0 = $xp();
[$a] = $go(); ok('with a tier 1 tool the 0% chance never pays', $a && $xp() === $x0, "xp $x0 -> " . $xp());
$mk(2); $put(['energy' => 0, 'tool' => 'forage:1', 'rewards' => 'xp=50:1@0/100']); $fresh(); $x0 = $xp();
[$a] = $go(); ok('with a tier 2 tool the 100% chance always pays', $a && $xp() > $x0, "xp $x0 -> " . $xp());

echo "== a villager's own stat check\n";
$loc = q_one('SELECT * FROM locations WHERE id = ?', [(int)$exp['from_id']]) ?: []; $loc['landscape'] = 'grassland';
$x0 = $xp(); $lines = trail_sight_pay($u, $loc, 'check=grit:99,xp=40:1', 'Someone');
ok('a check they cannot pass pays nothing and says so', $xp() === $x0 && str_contains(implode(' ', $lines), 'ask more of you'), implode(' | ', $lines));
$x0 = $xp(); $lines = trail_sight_pay($u, $loc, 'check=grit:0,xp=40:1', 'Someone');
ok('a check of difficulty 0 pays', $xp() > $x0, implode(' | ', $lines));
echo "== 2.7.01 wearables as Sight rewards\n";
require_once $argv[1] . '/includes/wearables.php'; wear_ensure_items();
ok('lint accepts a wearable as an item reward', !trail_sight_lint(['rewards' => 'item=flood-boots:1@100'] + $base));
$put(['energy' => 0, 'tool' => '-', 'rewards' => 'item=flood-boots:1@100']); $fresh(); set_setting('wear_open', '0'); setting('__reload__'); $w0 = wear_qty((int)$u['id'], 'flood-boots');
[$a] = $go(); ok('with wearables shut (setting wear_open 0; since 2.7.15 they no longer follow pfight_v1) a wearable does not drop', $a && wear_qty((int)$u['id'], 'flood-boots') === $w0, 'qty ' . wear_qty((int)$u['id'], 'flood-boots'));
$put(['energy' => 0, 'tool' => '-', 'rewards' => 'item=flood-boots:1@100']); $fresh(); set_setting('wear_open', '1'); setting('__reload__');
[$a] = $go(); ok('with wearables open (wear_open, 2.7.15) it drops', $a && wear_qty((int)$u['id'], 'flood-boots') === $w0 + 1, 'qty ' . wear_qty((int)$u['id'], 'flood-boots'));
$ncl = fn(string $chk) => array_values(array_filter(trail_sight_lint(['check' => $chk, 'lose' => 'x'] + $base), fn($p) => str_contains($p, 'check')));
if (!$ncl('nimble:9+grit:11') && !$ncl('grit:12') && $ncl('nimble:9+bogus:3') && $ncl('nimble:9+grit:99')) echo "  ok   2.7.06 either / or check: nimble:9+grit:11 lints clean, a bad half is refused\n"; else { echo "  FAIL 2.7.06 either / or check lint " . json_encode([$ncl('nimble:9+grit:11'), $ncl('nimble:9+bogus:3')]) . "\n"; $fails++; }
$t0 = 'hint=old-ruin@0'; $t100 = 'title=Lantern Runner@100'; $tn = 'page=the-stump';
$n0 = 0; for ($i = 0; $i < 200; $i++) { $x = $t0; if (trail_sight_chance_pass($x)) $n0++; }
$x100 = $t100; $x1 = $tn; $r100 = trail_sight_chance_pass($x100); $r1 = trail_sight_chance_pass($x1);
$n50 = 0; for ($i = 0; $i < 1000; $i++) { $x = 'fpto=Pip:5@50'; if (trail_sight_chance_pass($x)) $n50++; }
if ($n0 === 0 && $r100 && $x100 === 'title=Lantern Runner' && $r1 && $x1 === $tn && $n50 > 400 && $n50 < 600) echo "  ok   2.7.06 @chance on hint / title / page / fpto: 0 never, 100 always, none = always, 50 about half, the @N is stripped\n"; else { echo "  FAIL 2.7.06 @chance on hint/title/page/fpto " . json_encode([$n0, $r100, $x100, $r1, $n50]) . "\n"; $fails++; }
set_setting('pfight_v1', '0'); setting('__reload__');
q('DELETE FROM trail_sight_rows WHERE slug = ?', [$base['slug']]);
echo $fails ? "$fails FAILED\n" : "ok\n";
exit($fails ? 1 : 0);
