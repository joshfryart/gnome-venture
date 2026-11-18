<?php
// 2.7.08 Trail Sights engine gaps, third pass B (each needed another system): villager birthdays (bd= condition, bday= wishes, the villager card, a birthday present counts
// double), letters (letter=<key>: a satchel item with the letter's text), bottle post (bottle=1 at a coast / island Sight: a random note + its rewards), the quest beat @green
// (something done on a town's Green) and quest lines that start from the Notice Board (Q column 12 = board, or a quest=<slug> reward), seeds that really grow (seed=<slug>
// planted in the garden), keepsake tool effects (items.effects keepsake: +finds with that tool). Lint of every new token and data file.
// php tests/trail_sights_281.php GAME_DIR   (an installed game, player "sprout"; walk.sh installs one).
$_SERVER['SCRIPT_NAME'] = '/adventure.php';
require $argv[1] . '/includes/bootstrap.php';
require_once $argv[1] . '/includes/adventure.php';
require_once $argv[1] . '/includes/trail_sights.php';
require_once $argv[1] . '/includes/tools.php';
require_once $argv[1] . '/includes/gathering.php';
require_once $argv[1] . '/includes/stop_folk.php';
require_once $argv[1] . '/includes/friends.php';
require_once $argv[1] . '/includes/town.php';
require_once $argv[1] . '/includes/garden_logic.php';
$fails = 0;
set_setting('npc_clockwork', '0'); set_setting('sights_walk_cap', '0'); set_setting('game_clock_on', '1'); set_setting('season_force', ''); setting('__reload__');
$GLOBALS['gv_sights_nocache'] = true;
set_exception_handler(function (Throwable $e) { echo '  EXCEPTION ' . get_class($e) . ': ' . $e->getMessage() . ' @ ' . basename($e->getFile()) . ':' . $e->getLine() . "\n"; exit(1); });
function ok(string $what, bool $cond, string $extra = ''): void { global $fails; echo ($cond ? '  ok   ' : '  FAIL ') . $what . ($cond ? '' : "  $extra") . "\n"; if (!$cond) $fails++; }
$all = trail_sights_all(); $base = $all['grassland-the-clover-patch'];
$lint = fn(array $chg, string $word) => array_values(array_filter(trail_sight_lint($chg + $base), fn($p) => str_contains($p, $word)));
$u = q_one("SELECT * FROM users WHERE username = 'sprout'"); $uid = (int)$u['id'];
$fresh = function () use (&$u, $uid) { $u = q_one('SELECT * FROM users WHERE id = ?', [$uid]); return $u; };
$have = fn(string $slug) => (int)q_val('SELECT ui.qty FROM user_items ui JOIN items i ON i.id = ui.item_id WHERE ui.user_id = ? AND i.slug = ?', [$uid, $slug]);
$loc = q_one("SELECT * FROM locations WHERE kind = 'village' ORDER BY id LIMIT 1") + ['landscape' => 'grassland']; $loc['name'] = 'a test';
trail_sights_ensure_tables(); trail_sight_b_ensure();

echo "== birthdays: bd= condition, bday= wishes, the card, a present counts double\n";
$dayOf = function (string $season, int $sd) { for ($d = 0; $d < 400; $d++) { $dt = gclock_state(['game_day' => $d, 'game_minute' => 600])['date']; if (hollow_season($dt) === $season && hollow_season_day($dt) === $sd) return $d; } return -1; };
$lyraDay = $dayOf('spring', 3);
ok('Lyra Fiddlewing has a birthday row (spring 3) and that game day exists', $lyraDay >= 0 && (bool)array_filter(trail_sight_birthdays(), fn($b) => $b['slug'] === 'lyra-fiddlewing'));
q('UPDATE users SET game_day = ?, game_minute = 600 WHERE id = ?', [$lyraDay, $uid]); $fresh();
ok('on that game day it is her birthday', (bool)trail_sight_bd_of($u, 'Lyra Fiddlewing') && in_array('lyra-fiddlewing', array_column(trail_sight_bd_today($u), 'slug'), true));
$now = trail_sight_now($loc, null, $u);
ok('bd=lyra-fiddlewing and bd=any hold; bd=wren-thimblewick does not', trail_sight_cond_ok('bd=lyra-fiddlewing', $now) && trail_sight_cond_ok('bd=any', $now) && trail_sight_cond_ok('bd=nobody,lyra-fiddlewing', $now) && !trail_sight_cond_ok('bd=wren-thimblewick', $now));
ok('a {bd=...} win variant is chosen on the day', str_contains(trail_sight_line('Plain line. // {bd=lyra-fiddlewing}Birthday line.', $now), 'Birthday line'));
$lyraId = (int)q_val("SELECT id FROM npcs WHERE name = 'Lyra Fiddlewing' ORDER BY id LIMIT 1");
$p0 = $lyraId ? (int)friendship($uid, $lyraId)['points'] : 0;
$lines = trail_sight_pay($u, $loc, 'bday=2', '', $now);
ok('bday=2 wishes her a happy birthday and pays 2 friendship', $lyraId > 0 && (bool)array_filter($lines, fn($l) => str_contains($l, 'Happy birthday, Lyra Fiddlewing')) && (int)friendship($uid, $lyraId)['points'] === $p0 + 2, json_encode([$lines, $p0, $lyraId ? friendship($uid, $lyraId)['points'] : null]));
ok('the villager card says it is her birthday', str_contains(trail_sight_bd_card_note($u, 'Lyra Fiddlewing'), 'birthday today'));
ok('a present on her birthday counts double', trail_sight_bd_gift($u, 'Lyra Fiddlewing', 4)[0] === 8 && trail_sight_bd_gift($u, 'Wren Thimblewick', 4)[0] === 4);
q('UPDATE users SET game_day = ? WHERE id = ?', [$lyraDay + 1, $uid]); $fresh(); $now = trail_sight_now($loc, null, $u);
ok('the next day: no bd=lyra-fiddlewing, bday= pays nothing to her, the card says when it is', !trail_sight_cond_ok('bd=lyra-fiddlewing', $now) && !array_filter(trail_sight_pay($u, $loc, 'bday=2', '', $now), fn($l) => str_contains($l, 'Lyra')) && str_contains(trail_sight_bd_card_note($u, 'Lyra Fiddlewing'), 'the 3rd day of spring'));
ok('lint: bd= as a when / ?cond / {cond} and bday=2 are clean; bday=0 refused', !$lint(['when' => 'bd=lyra-fiddlewing', 'rewards' => 'xp=2,bday=2,c=3?bd=any', 'win' => 'x // {bd=any}y'], 'bd') && (bool)$lint(['rewards' => 'bday=0'], 'bday'));
ok('cond text: "on Lyra Fiddlewing\'s birthday"', trail_sight_cond_text('bd=lyra-fiddlewing') === "on Lyra Fiddlewing's birthday");

echo "== letters: letter=<key>\n";
q("DELETE FROM user_items WHERE user_id = ? AND item_id = (SELECT id FROM items WHERE slug = 'letter-stork-post')", [$uid]);
$l1 = trail_sight_pay($u, $loc, 'fp=1,letter=stork-post', 'Tuck Bumbleby', $now);
$desc = (string)q_val("SELECT description FROM items WHERE slug = 'letter-stork-post'");
ok('the villager hands over a letter: a satchel item with the text', $have('letter-stork-post') === 1 && str_contains($desc, 'steady hands') && (bool)array_filter($l1, fn($l) => str_contains($l, 'A letter from Tuck Bumbleby')), json_encode($l1));
trail_sight_pay($u, $loc, 'letter=stork-post', '', $now);
ok('a second time no second copy', $have('letter-stork-post') === 1);
ok('a letter cannot be sold or given (tradable 0)', (int)q_val("SELECT tradable FROM items WHERE slug = 'letter-stork-post'") === 0);
ok('lint: letter=stork-post clean, letter=no-such refused', !$lint(['rewards' => 'letter=stork-post'], 'letter') && (bool)$lint(['rewards' => 'letter=no-such'], 'letter'));

echo "== bottle post: bottle=1 at the coast\n";
$notes = fn() => (int)q_val("SELECT COALESCE(SUM(ui.qty), 0) FROM user_items ui JOIN items i ON i.id = ui.item_id WHERE ui.user_id = ? AND i.slug LIKE 'bottle-note-%'", [$uid]);
$n0 = $notes(); $lb = trail_sight_b_pay($u, ['landscape' => 'coast'] + $loc, 'bottle=1', $now);
ok('at a coast Sight a bottle washes up: one note, its line', $notes() === $n0 + 1 && str_contains($lb[0] ?? '', 'A bottle washes up'), json_encode($lb));
$n1 = $notes(); $lf = trail_sight_b_pay($u, ['landscape' => 'forest'] + $loc, 'bottle=1', $now);
ok('inland nothing washes up', $notes() === $n1 && !$lf);
$cpost = $all['coast-the-bottle-post'] ?? null;
ok('the coast bottle-post Sight carries bottle=1@35 and is lint-clean', $cpost && str_contains($cpost['rewards'], 'bottle=1@35') && !trail_sight_lint($cpost), $cpost ? json_encode(trail_sight_lint($cpost)) : 'no row');
ok('lint: bottle=2 refused', (bool)$lint(['rewards' => 'bottle=2'], 'bottle'));

echo "== seeds that grow: seed=<slug>\n";
$s0 = $have('lantern-fruit-seed'); $ls = trail_sight_b_pay($u, $loc, 'seed=lantern-fruit-seed:2', $now);
ok('seed=lantern-fruit-seed:2 gives two Lantern Fruit Seeds', $have('lantern-fruit-seed') === $s0 + 2 && str_contains($ls[0] ?? '', 'Lantern Fruit Seed'), json_encode($ls));
$pl = q_one("SELECT p.* FROM plants p JOIN items i ON i.id = p.seed_item_id WHERE i.slug = 'lantern-fruit-seed'");
ok('a plants row grows it into Lantern Fruit', $pl && (int)$pl['produce_item_id'] === (int)q_val("SELECT id FROM items WHERE slug = 'lantern-fruit'"));
ok('seed=<crop slug> works too (seed=lantern-fruit -> its seed)', trail_sight_b_seed_id('lantern-fruit') === (int)$pl['seed_item_id']);
$plot = active_plot_id($uid); $tile = $plot ? q_one('SELECT * FROM plot_tiles WHERE plot_id = ? ORDER BY id LIMIT 1', [$plot]) : null;
if ($tile) {
    q('UPDATE plot_tiles SET plant_id = NULL, tilled = 1, settle_until = NULL, fertility = 60 WHERE id = ?', [$tile['id']]);
    q('UPDATE users SET energy = 50 WHERE id = ?', [$uid]);
    [$pok, $pm] = garden_action($uid, 'plant', (int)$tile['x'], (int)$tile['y'], (int)$pl['seed_item_id']);
    ok('it plants in the garden like any seed', $pok && (int)q_val('SELECT plant_id FROM plot_tiles WHERE id = ?', [$tile['id']]) === (int)$pl['id'], json_encode($pm));
    q('UPDATE plot_tiles SET plant_id = NULL WHERE id = ?', [$tile['id']]);
} else ok('sprout has a garden plot', false);
ok('the picnic knoll gives the Tiny Thank-You Seed, the lantern fruit its seed (lint clean)', str_contains($all['grassland-the-picnic-knoll']['rewards'], 'seed=tiny-thank-you-seed@8') && str_contains($all['rainforest-the-lantern-fruit']['rewards'], 'seed=lantern-fruit-seed@6') && !trail_sight_lint($all['grassland-the-picnic-knoll']) && !trail_sight_lint($all['rainforest-the-lantern-fruit']));
ok('lint: seed=1 and seed=lantern-fruit-seed:2 clean, seed=no-such-seed refused', !$lint(['rewards' => 'seed=1,seed=1@8,seed=lantern-fruit-seed:2@10'], 'seed') && (bool)$lint(['rewards' => 'seed=no-such-seed'], 'seed'));

echo "== keepsake tool effects\n";
$fx = json_decode((string)q_val("SELECT effects FROM items WHERE slug = 'teeny-axe'"), true);
ok('the Teeny Axe has a keepsake effect in its effects JSON', ($fx['keepsake']['gather'] ?? '') === 'axe' && (int)$fx['keepsake']['qty'] === 1, json_encode($fx));
$axeId = (int)q_val("SELECT id FROM items WHERE slug = 'teeny-axe'");
q('DELETE FROM user_items WHERE user_id = ? AND item_id = ?', [$uid, $axeId]);
ok('not carried: no bonus', trail_sight_keepsake_bonus($uid, 'axe')[0] === 0);
give_item($uid, $axeId, 1);
ok('carried: +1 with the axe, nothing with the net', trail_sight_keepsake_bonus($uid, 'axe') === [1, ['Teeny Axe']] && trail_sight_keepsake_bonus($uid, 'net')[0] === 0);
ok('the keepsake is not a tool (tool_tier unchanged)', tool_tier($uid, 'axe') === (int)q_val("SELECT 0"));   // sprout has no axe
$tool = q_one("SELECT * FROM items WHERE effects LIKE '%\"tool\":\"axe\"%' AND effects NOT LIKE '%keepsake%' ORDER BY id LIMIT 1");
if ($tool) {
    give_item($uid, (int)$tool['id'], 1); tool_cache_reset();
    $gl = gather_on_walk($fresh(), 'forest', 'axe', true);
    ok('a gather with the axe says the keepsake helped', is_string($gl) && str_contains($gl, 'Teeny Axe helped: +1'), (string)$gl);
    give_item($uid, (int)$tool['id'], -1); tool_cache_reset();
} else ok('an axe tool exists', false);
q('DELETE FROM user_items WHERE user_id = ? AND item_id = ?', [$uid, $axeId]);

echo "== quest lines: Notice Board starts, the @green beat, quest=\n";
$qfile = $argv[1] . '/includes/data/trail_sight_quests.txt'; $qorig = file_get_contents($qfile);
$sl = array_slice(array_keys($all), 0, 2);
file_put_contents($qfile, $qorig . "\nQ|zz-board|Board Test|Lyra Fiddlewing|📋|anylast|xp=1|A request from the board.|All done.|||board\nB|zz-board|{$sl[0]}|a Sight|-\nB|zz-board|@green|play on a green|-||letter=lyra-thanks\nQ|zz-q2|Quest Token Test|Lyra Fiddlewing|📋|seq|xp=1|Begun by a token.|Done.|||board\nB|zz-q2|{$sl[1]}|one|-\nB|zz-q2|@green:NoSuchTown|two|-\n");
$qs = trail_sight_quests(); $qq = $qs['zz-board'] ?? null;
ok('column 12 board loads; @green is a clean beat kind', $qq && $qq['start'] === 'board' && !trail_sight_quest_lint($qq, $all, $qs) && !array_filter(trail_sight_b_data_lint(), fn($p) => str_contains($p, 'zz-')), $qq ? json_encode(trail_sight_quest_lint($qq, $all, $qs)) : 'no line');
q("DELETE FROM user_sight_quests WHERE user_id = ? AND quest IN ('zz-board', 'zz-q2')", [$uid]);
$nowq = trail_sight_now($loc, null, $u);
$o = trail_sight_quest_hook($u, $sl[0], $loc, $nowq);
ok('a board line does not begin at its beat', !trail_sight_quest_row($uid, 'zz-board') && !array_filter($o, fn($x) => str_contains($x, 'Board Test')), json_encode($o));
ok('the Sight card says "not yet" for it', (bool)array_filter(trail_sight_quest_notes($uid, $sl[0]), fn($n) => $n[0] === 'Board Test' && $n[3] === 'locked'));
ensure_towns(); $board = q_one("SELECT * FROM town_spots WHERE kind = 'board' AND active = 1 ORDER BY id LIMIT 1"); $green = q_one("SELECT * FROM town_spots WHERE kind = 'green' AND active = 1 ORDER BY id LIMIT 1");
$bh = trail_sight_board_html($u, (int)($board['id'] ?? 0), false);
ok('the Notice Board lists it with a Take button', $board && str_contains($bh, 'Board Test') && str_contains($bh, 'name="do" value="sightquest"'), substr(strip_tags($bh), 0, 200));
[$tok, $tm] = trail_sight_board_take($u, 'zz-board');
ok('taking it begins the line', $tok && str_contains($tm, 'A quest begins: Board Test') && trail_sight_quest_row($uid, 'zz-board'), $tm);
ok('then it is off the board, and a second take is refused', !str_contains(trail_sight_board_html($u, 1, false), 'Board Test') && !trail_sight_board_take($u, 'zz-board')[0]);
$o = trail_sight_quest_hook($u, $sl[0], $loc, $nowq);
ok('now its Sight beat counts', (bool)array_filter($o, fn($x) => str_contains($x, 'Board Test: a Sight')), json_encode($o));
q("DELETE FROM user_items WHERE user_id = ? AND item_id = (SELECT id FROM items WHERE slug = 'letter-lyra-thanks')", [$uid]);
ok('something done at the board is no @green beat', trail_sight_green_visit($u, (int)$board['id'], 0) === '' || !str_contains(trail_sight_green_visit($u, (int)$board['id'], 0), 'Board Test'));
$gl = trail_sight_green_visit($u, (int)$green['id'], 0);
ok('something done on a Green is the @green beat: the line finishes, the beat gift letter is handed over', str_contains($gl, 'Board Test is done') && $have('letter-lyra-thanks') === 1, $gl);
$act = q_one('SELECT * FROM town_actions WHERE spot_id = ? ORDER BY id LIMIT 1', [(int)$green['id']]);
$o = trail_sight_pay($u, $loc, 'quest=zz-q2', '', $nowq);
ok('quest=zz-q2 (a Sight reward) begins a board line', (bool)array_filter($o, fn($x) => str_contains($x, 'A quest begins: Quest Token Test')) && trail_sight_quest_row($uid, 'zz-q2'), json_encode($o));
trail_sight_quest_hook($u, $sl[1], $loc, $nowq);
ok('@green:<Town> counts only on that town\'s Green', !str_contains($act ? trail_sight_green_visit($u, 0, (int)$act['id']) : '', 'Quest Token Test is done') && trail_sight_quest_row($uid, 'zz-q2')['done_at'] === null);
ok('lint: quest=zz-board clean, quest=nope refused; start column must be board; a bad beat kind refused', !$lint(['rewards' => 'quest=zz-board'], 'quest') && (bool)$lint(['rewards' => 'quest=nope'], 'quest') && (bool)trail_sight_quest_lint(['beats' => [['@greenx', 'a', '-', ''], [$sl[0], 'b', '-', '']]] + $qq, $all, $qs));
file_put_contents($qfile, $qorig . "\nQ|zz-bad|Bad|Lyra Fiddlewing|📋|seq|xp=1|a|b|||boardx\nB|zz-bad|{$sl[0]}|a|-\nB|zz-bad|{$sl[1]}|b|-\n"); touch($qfile, time() + 5); clearstatcache();
ok('data lint: start=boardx refused', (bool)array_filter(trail_sight_b_data_lint(), fn($p) => str_contains($p, 'zz-bad')));
q("DELETE FROM user_sight_quests WHERE user_id = ? AND quest IN ('zz-board', 'zz-q2')", [$uid]);
file_put_contents($qfile, $qorig); touch($qfile, time() + 10); clearstatcache(); trail_sight_quests();
$big = trail_sight_quests()['big-friends-lullaby'] ?? null; $wc = trail_sight_quests()['woodland-census'] ?? null;
ok('data: the lullaby finale is @green (last), Wren\'s census starts from the board', $big && end($big['beats'])[0] === '@green' && $wc && $wc['start'] === 'board');

echo "== the data files lint clean\n";
$dl = trail_sight_b_data_lint();
ok('birthdays, letters, bottles, seeds, keepsakes: no problems', !$dl, json_encode($dl));
$bfile = $argv[1] . '/includes/data/trail_sight_birthdays.txt'; $borig = file_get_contents($bfile);
file_put_contents($bfile, $borig . "Nobody Atall|spring|3|x\nLyra Fiddlewing|midsummer|40|x\n"); clearstatcache();
$dl = trail_sight_b_data_lint(); file_put_contents($bfile, $borig);
ok('data lint: an unknown villager, a bad season and a second row are refused', (bool)array_filter($dl, fn($p) => str_contains($p, 'Nobody Atall')) && (bool)array_filter($dl, fn($p) => str_contains($p, 'season')) && (bool)array_filter($dl, fn($p) => str_contains($p, 'two rows')), json_encode($dl));

echo $fails ? "$fails FAILED\n" : "ok\n";
exit($fails ? 1 : 0);
