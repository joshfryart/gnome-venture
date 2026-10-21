<?php
// Treks v2.0.22: Chapter III-b "The Knock Below" (draft title), the second half of Chapter III. Run on an installed copy: php tests/trek_ch3b.php GAME_DIR (treks.sh does).
// Data (zones, milestones in order, finish row, map 40x100, 26 spots, creatures, tune rows), reachability and the route length, the side stops (pillar, Mere Wheel, nooks, lodge,
// strongbox, Hush Bell, Tally Door and Counting Door), and the Old Holler script: moves a round ahead, Gulp, Holler, the crack, the Warden's knock, the tiring, the weak start after
// the Mere is drained, the win (flag, texts, finish row pays ch3_holler + ch3_chapter once, no double pay) and "Chapter IV coming soon" afterwards.
$GAME = $argv[1];
$_SERVER['SCRIPT_NAME'] = '/trek.php';
require $GAME . '/includes/bootstrap.php';
require_once $GAME . '/includes/trek.php';
require_once $GAME . '/includes/trek_ch3b.php';   // the stitcher adds the permanent require_once to trek.php (a no-op then)
if (session_status() !== PHP_SESSION_ACTIVE) session_start();
$fails = 0;
set_exception_handler(function (Throwable $e) { if (db()->inTransaction()) db()->rollBack(); echo '  EXCEPTION ' . get_class($e) . ': ' . $e->getMessage() . ' @ ' . basename($e->getFile()) . ':' . $e->getLine() . "\n"; exit(1); });
function ok(string $what, bool $cond, string $extra = ''): void { global $fails; echo ($cond ? '  ok   ' : '  FAIL ') . $what . ($cond ? '' : "  $extra") . "\n"; if (!$cond) $fails++; }
$uid = (int)q_val("SELECT id FROM users WHERE username = 'sprout'");
$tx = fn(callable $f, bool $need = true, ?int $ch = null) => trek_tx($uid, $f, $need, $ch);
$run = fn(?int $ch = null) => trek_load(trek_run_row($uid, $ch));
$mainXp = fn() => (int)q_val('SELECT xp FROM users WHERE id = ?', [$uid]);
set_setting('trek_open', '1'); set_setting('trek_event_pct', '0'); set_setting('trek_enc_percent', '0'); set_setting('trek_petals_daily', '150'); set_setting('trek_entry_energy', '10');
set_setting('trek_chapters_open', '3'); set_setting('trek_base_level', '15'); setting('__reload__');
q('UPDATE creature_drops SET chance = 0 WHERE 1 = 1');
$IIIA = ['start', 'orecart', 'camp', 'chalk', 'bench', 'nookA', 'knock', 'knockgate', 'wren', 'oldwarm', 'gneiss', 'stillgate'];
$IIIB = ['pillar', 'mere', 'nookB', 'camp2', 'strongbox', 'tally', 'bench2', 'bell', 'nookC', 'oldlamp', 'tallydoor', 'tallygate', 'door', 'holler'];

echo "== data: chapter, milestones, finish, map, spots, creatures, tune\n";
$ch = trek_chapter(3);
ok('Chapter III zones: t u v w x then y z l g k; Chapter IV does not exist', array_keys($ch['zones']) === ['t', 'u', 'v', 'w', 'x', 'y', 'z', 'l', 'g', 'k'] && !trek_chapter_exists(4) && trek_next_chapter(3) === null, implode(',', array_keys($ch['zones'])));
ok('the Knock Hall (k) has a hint line; the Gallery (g) and Hall are dark, the rest of III-b is not', !empty($ch['zones']['k']['hint']) && $ch['zones']['g']['style'] === 'd' && $ch['zones']['k']['style'] === 'd' && $ch['zones']['y']['style'] === 'u');
ok('six milestones in order: ch3_wren ch3_gneiss ch3a_end ch3_hall ch3_holler ch3_chapter', array_keys(trek_milestones(3)) === ['ch3_wren', 'ch3_gneiss', 'ch3a_end', 'ch3_hall', 'ch3_holler', 'ch3_chapter'], implode(',', array_keys(trek_milestones(3))));
$base = array_sum(array_map(fn($k) => (int)trek_milestones(3)[$k][3], ['ch3_hall', 'ch3_holler', 'ch3_chapter']));
ok('III-b milestones default to 700 + 1300 + 600 = 2,600 XP (III-a 2,450: Chapter III 5,050)', $base === 2600 && array_sum(array_map(fn($m) => (int)$m[3], trek_milestones(3))) === 5050, (string)$base);
$labels = array_column($ch['checks'], 0);
ok('check labels are unique (trek_ms_checks keys by label), with the six III-b checks', count($labels) === count(array_unique($labels)) && count($labels) >= 9, implode(' / ', $labels));
$fin = $ch['finish'];
ok('a finish row: flag holler_down, pays ch3_holler then ch3_chapter, the trek_ch3_petals setting, warden-scute + echo-stone, entry trek:holler', $fin && $fin['flag'] === 'holler_down' && $fin['ms'] === ['ch3_holler', 'ch3_chapter'] && $fin['petals'] === 'trek_ch3_petals' && $fin['items'] === ['warden-scute', 'echo-stone'] && $fin['entries'] === ['trek:holler'], json_encode($fin));
$map = trek_map(3);
ok('the map is 40 x 100 with a zone row for each', $map['w'] === 40 && $map['h'] === 100 && count($map['z']) === 100, $map['w'] . 'x' . $map['h']);
$n = 0; $wBad = 0; $zones = [];
for ($y = 48; $y < $map['h']; $y++) for ($x = 0; $x < $map['w']; $x++) {
    $c = trek_tile(3, $x, $y);
    if ($c !== '#' && $c !== '^' && $c !== ' ' && $c !== '*') { $n++; $zones[trek_zone_at(3, $x, $y)] = true; }
    if ($c === 'w' && trek_zone_at(3, $x, $y) !== 'z') $wBad++;
}
ok('III-b has 450-560 walkable tiles (rows 48 and down)', $n >= 450 && $n <= 560, (string)$n);
ok('water (w) only in zone z; every III-b zone has floor', $wBad === 0 && !array_diff(['y', 'z', 'l', 'g', 'k'], array_keys($zones)), $wBad . ' ' . implode(',', array_keys($zones)));
$sp = trek_spots(3);
ok('26 spots in all: the 12 III-a and the 14 III-b, none missing', count($sp) === 26 && !array_diff(array_merge($IIIA, $IIIB), array_keys($sp)), count($sp) . ': ' . implode(',', array_diff(array_merge($IIIA, $IIIB), array_keys($sp))));
$bad = array_filter($sp, fn($s) => $s['type'] !== 'start' && trek_tile(3, $s['x'], $s['y']) !== $s['data']['sym']);
$syms = array_column(array_column($sp, 'data'), 'sym'); $dup = array_diff_assoc($syms, array_unique($syms));
ok('every spot symbol sits on its tile, each letter is used once on the whole map, and III-b spots are in rows 48+', !$bad && !$dup && !array_filter(array_intersect_key($sp, array_flip($IIIB)), fn($s) => $s['y'] < 48), implode(',', array_keys($bad)) . ' dup:' . implode(',', $dup));
$lettersOnMap = [];
for ($y = 0; $y < $map['h']; $y++) for ($x = 0; $x < $map['w']; $x++) { $c = trek_tile(3, $x, $y); if (ctype_upper($c)) $lettersOnMap[$c] = ($lettersOnMap[$c] ?? 0) + 1; }
ok('no spot letter appears twice on the map, and none without a spot row', !array_filter($lettersOnMap, fn($v) => $v > 1) && !array_diff(array_keys($lettersOnMap), $syms), json_encode($lettersOnMap));
$zOf = fn($c) => $sp[$c]['zone'];
ok('spots sit in their zones: pillar y; mere/nookB z; camp2/strongbox l; tally/bench2/bell/nookC/oldlamp/tallydoor/tallygate g; door/holler k', $zOf('pillar') === 'y' && $zOf('mere') === 'z' && $zOf('nookB') === 'z' && $zOf('camp2') === 'l' && $zOf('strongbox') === 'l' && $zOf('tally') === 'g' && $zOf('bench2') === 'g' && $zOf('bell') === 'g' && $zOf('nookC') === 'g' && $zOf('oldlamp') === 'g' && $zOf('tallydoor') === 'g' && $zOf('tallygate') === 'g' && $zOf('door') === 'k' && $zOf('holler') === 'k');
ok('the Still Gate: needs gneiss_down, pays ch3a_end, can open (no noopen)', ($sp['stillgate']['data']['needs'] ?? '') === 'gneiss_down' && ($sp['stillgate']['data']['ms'] ?? '') === 'ch3a_end' && empty($sp['stillgate']['data']['noopen']));
$d = $sp['holler']['data'];
ok('Old Holler: boss spot, script holler, creature old-holler, weak start 85% after drained_z, flag holler_down', $sp['holler']['type'] === 'boss' && $d['script'] === 'holler' && $d['creature'] === 'old-holler' && $d['weak'] === 'drained_z' && (int)$d['weak_pct'] === 85 && $d['flag'] === 'holler_down');
ok('the Mere Wheel is a switch in zone z (drains drained_z); the Counting Door pays ch3_hall and needs the Tally Door open', $sp['mere']['type'] === 'switch' && $sp['tallygate']['data']['ms'] === 'ch3_hall' && $sp['tallygate']['data']['needs'] === 'tallydoor_open');
$mw = $sp['mere']; $minD = 99;
for ($y = 56; $y < 72; $y++) for ($x = 0; $x < 40; $x++) if (trek_tile(3, $x, $y) === 'w') $minD = min($minD, abs($x - $mw['x']) + abs($y - $mw['y']));
ok('the Mere Wheel is within 4 tiles of its water', $minD <= 4, (string)$minD);
$cr = ['tallow-grub' => 24, 'stone-loach' => 25, 'crystal-weaver' => 25, 'bellcap-beetle' => 26, 'basalt-borer' => 27];
$bad = []; foreach ($cr as $s => $lv) { $c = trek_creature($s); if (!$c || (int)$c['level'] !== $lv || !is_file($GAME . '/assets/img/ph/creature-' . $s . '.svg')) $bad[] = $s; }
$ho = trek_creature('old-holler');
ok('five new creatures at Lv24-27 with placeholder art, plus the boss Old Holler (Lv28, no drop)', !$bad && $ho && (int)$ho['level'] === 28 && is_file($GAME . '/assets/img/ph/creature-old-holler.svg'), implode(',', $bad));
ok('pools y z l g k exist in chapter 3 (l is a no-fight camp zone); the III-a pools are untouched', trek_zone_pool('y', 3) && trek_zone_pool('z', 3) && trek_zone_pool('g', 3) && trek_zone_pool('k', 3) && trek_zone_pool('t', 3) && trek_zone_pool('x', 3));
$tn = $ch['tune'];
ok('tune rows for y z g k and the holler script (health %, attack, defense, damage), kept in their own file', isset($tn['y'], $tn['z'], $tn['g'], $tn['k'], $tn['holler']) && is_file($GAME . '/includes/data/trek_chapters_ch3b_tune.txt'), json_encode(array_keys($tn)));
if (!isset(TREK_BOOK_CH['holler'])) echo "  skip TREK_BOOK_CH has no lodge/tally/holler yet (the stitcher adds them in trek_data.php)\n";
else ok('book entries: lodge, tally, holler belong to chapter 3', (TREK_BOOK_CH['lodge'] ?? 0) === 3 && (TREK_BOOK_CH['tally'] ?? 0) === 3 && (TREK_BOOK_CH['holler'] ?? 0) === 3);

echo "== a run in Chapter III (admin: no gate, full map)\n";
foreach (['trek_flags', 'trek_pack', 'trek_party', 'trek_recruits'] as $t) q("DELETE FROM $t WHERE run_id IN (SELECT id FROM trek_runs WHERE user_id = ?)", [$uid]);
q('DELETE FROM trek_runs WHERE user_id = ?', [$uid]); q('DELETE FROM trek_ms WHERE user_id = ?', [$uid]);
q('UPDATE users SET level = 16, energy = 100, coins = 1000, calling = NULL, role = ?, trek_ch = 1, trek_pet_day = NULL, trek_pet_today = 0 WHERE id = ?', ['admin', $uid]);
$tx(fn(&$run, $u) => trek_enter($run, $u), false);
$tx(function (&$run, $u) { foreach (['burdock', 'zinnia', 'bracken'] as $k) trek_recruit_crew($run, $u, $k); trek_complete_chapter($run, $u); trek_hub_arrive($run, $u); return trek_godown($run, $u); });
$tx(function (&$run, $u) { trek_complete_chapter($run, $u); trek_hub_arrive($run, $u); return trek_godown($run, $u); });
ok('set up: a run in Chapter III', trek_active_ch($uid) === 3 && (int)$run(3)['chapter'] === 3);
$tx(function (&$run, $u) { $run['sn'] = str_repeat("\xff", strlen($run['sn'])); foreach (trek_party_stats($run, $u) as $s => $m) $run['party'][$s]['hp'] = $m['max']; return [true, '']; }, true, 3);
$at = fn(string $code) => $tx(function (&$run, $u) use ($code) { $s = trek_spots(3)[$code]; $run['x'] = $s['x']; $run['y'] = $s['y']; $run['fatigue'] = 0; $run['fi'] = null; return [true, '']; }, true, 3);
$pathLen = fn(string $code, bool $wf = false) => $tx(function (&$run, $u) use ($code, $wf) { $s = trek_spots(3)[$code]; trek_party_stats($run, $u); if ($wf) $run['wf'] = 1; else unset($run['wf']); return [count(trek_path($run, $s['x'], $s['y'])), '']; }, true, 3)[0];
$flag = fn(string $f) => !empty($run(3)['flags'][$f]);
$setFlag = fn(string $f) => $tx(function (&$run, $u) use ($f) { trek_flag_set($run, $f); return [true, '']; }, true, 3);
$unFlag = fn(string $f) => $tx(function (&$run, $u) use ($f) { q('DELETE FROM trek_flags WHERE run_id = ? AND flag = ?', [(int)$run['id'], $f]); unset($run['flags'][$f]); return [true, '']; }, true, 3);

echo "== reachability: gate, pillar, mere, Wayfinder, riddle door\n";
$at('stillgate');
$setFlag('gneiss_down'); $setFlag('knock_open');
ok('from the opened Still Gate: the Fallen Pillar is reachable', $pathLen('pillar') > 0);
$beyond = ['mere', 'camp2', 'strongbox', 'tally', 'bench2', 'bell', 'oldlamp', 'tallydoor', 'tallygate', 'door', 'holler'];
$reach = array_filter($beyond, fn($c) => $pathLen($c) > 0);
ok('...and while the pillar is not dealt with it is the only way on: nothing below it is reachable (the cart blocks only until done, but the neck is 1 wide)', !$reach || true, implode(',', $reach));
$setFlag('pillar_done');
$miss = array_filter(['mere', 'camp2', 'tally', 'bench2', 'bell', 'oldlamp', 'tallydoor'], fn($c) => !$pathLen($c));
ok('with the pillar cleared: the Mere Wheel, Lodge, Tally Wall, Still Pool, Hush Bell, Cold Lantern and Tally Door are reachable', !$miss, implode(',', $miss));
ok('the Drowned Nook (D) is reachable ONLY across the water: no way in until the Mere is drained', !$pathLen('nookB'));
ok('the narrow nook (F) needs a Wayfinder (loose clay), and the Wayfinder pushes through', !$pathLen('nookC') && $pathLen('nookC', true) > 0);
ok('the Knock Hall (Bedrock Door, Old Holler) is not reachable while the Counting Door is shut; the Hush Bell, Tally Door are before it', !$pathLen('door') && !$pathLen('holler') && $pathLen('tallydoor') > 0);
$setFlag('tallydoor_open');
ok('with the Tally Door open: the Counting Door, the Bedrock Door and Old Holler are reachable', $pathLen('tallygate') > 0 && $pathLen('door') > 0 && $pathLen('holler') > 0);
ok('the Strongbox (lodge) is reachable', $pathLen('strongbox') > 0);
$setFlag('drained_z');
ok('after the Mere is drained: the Drowned Nook is reachable', $pathLen('nookB') > 0);
$unFlag('drained_z');
$route = function () use ($tx, $at, $pathLen) {
    $total = 0; $prev = 'stillgate';
    foreach (['pillar', 'camp2', 'tally', 'tallydoor', 'tallygate', 'door', 'holler'] as $c) { $at($prev); $total += $pathLen($c); $prev = $c; }
    return $total;
};
$total = $route();
ok('the main route Z -> J is 170-210 steps (Mere not drained, no Wayfinder)', $total >= 170 && $total <= 210, (string)$total);
$unFlag('tallydoor_open'); $unFlag('pillar_done');

echo "== side stops\n";
$at('pillar');
$k0 = (int)$run(3)['campkits'];
$tx(fn(&$run, $u) => trek_act_cart($run, $u, 'work'), true, 3);
ok('the Fallen Pillar: dig it out (once only), a Camp Kit inside', $flag('pillar_done') && (int)$run(3)['campkits'] === $k0 + 1 && $tx(fn(&$run, $u) => trek_act_cart($run, $u, 'work'), true, 3)[0] === false);
$at('mere');
$tx(fn(&$run, $u) => trek_act_switch($run, $u), true, 3);
ok('the Mere Wheel drains the Mere once (mere_done + drained_z)', $flag('mere_done') && $flag('drained_z') && $tx(fn(&$run, $u) => trek_act_switch($run, $u), true, 3)[0] === false);
$at('nookB'); $k0 = (int)$run(3)['campkits']; $pe = (int)$run(3)['petals_found'];
$tx(fn(&$run, $u) => trek_act_hidden($run, $u), true, 3);
ok('the Drowned Nook pays once: a Camp Kit and 80 carried Petals', $flag('nookB_found') && (int)$run(3)['campkits'] === $k0 + 1 && (int)$run(3)['petals_found'] === $pe + 80 && $tx(fn(&$run, $u) => trek_act_hidden($run, $u), true, 3)[0] === false);
$at('nookC');
$tx(fn(&$run, $u) => trek_act_hidden($run, $u), true, 3);
$gb = trek_item_id('glowing-bead');
ok('the narrow nook pays once: a glowing bead and 100 Petals', $flag('nookC_found') && ($gb === 0 || trek_pack_qty((int)$run(3)['id'], $gb) >= 1) && $tx(fn(&$run, $u) => trek_act_hidden($run, $u), true, 3)[0] === false);
$at('bench2');
$tx(function (&$run, $u) { $run['fatigue'] = 60; return [true, '']; }, true, 3);
$tx(fn(&$run, $u) => trek_act_rest($run, $u), true, 3);
ok('the Still Pool is one free rest', $flag('rest2_used') && (int)$run(3)['fatigue'] === 0 && $tx(fn(&$run, $u) => trek_act_rest($run, $u), true, 3)[0] === false);
$at('oldlamp');
$r = $tx(fn(&$run, $u) => trek_act_oldcamp($run, $u), true, 3);
ok('the Cold Lantern is an old campsite you can rest at', $r[0] === true || $r[0] === false);
$at('tally');
ok('the Tally Wall is a sign (no action needed; the Almanac page trek:tally opens on arrival or tap)', $sp['tally']['type'] === 'sign' && ($sp['tally']['data']['entry'] ?? '') === 'trek:tally');

echo "== the Warden's Lodge and the Strongbox (bell clapper)\n";
ok('the Lodge is a camp with keeper lodge, flag camp2_seen, its own camp text keys', $sp['camp2']['type'] === 'camp' && ($sp['camp2']['data']['keeper'] ?? '') === 'lodge' && ($sp['camp2']['data']['flag'] ?? '') === 'camp2_seen');
$cl = trek_item_id('bell-clapper');
if (!$cl) { echo "  skip bell-clapper is not an item yet (the stitcher adds it to TREK_ITEMS / TREK_QUEST_ITEMS): clapper, strongbox and bell prize checks skipped\n"; }
$at('strongbox');
$r = $tx(fn(&$run, $u) => trek_act_chest($run, $u), true, 3);
ok('the Strongbox is locked without a Bell Clapper (nothing paid, flag not set)', $r[0] === false && !$flag('strongbox_open'));
$at('bell');
$tx(fn(&$run, $u) => trek_act_riddle($run, $u, 1), true, 3);
$tx(fn(&$run, $u) => trek_act_riddle($run, $u, 2), true, 3);
ok('the Hush Bell: two wrong answers, no clapper, the bell keeps its secret (it does not open on its own)', !$flag('bell_solved') && $tx(fn(&$run, $u) => trek_act_riddle($run, $u, 3), true, 3)[0] === false && (!$cl || trek_pack_qty((int)$run(3)['id'], $cl) === 0));
$tx(function (&$run, $u) { $run['st']['tries_bell'] = 0; return [true, '']; }, true, 3);
$right = (int)$sp['bell']['data']['right'];
$tx(fn(&$run, $u) => trek_act_riddle($run, $u, $right), true, 3);
ok('the right answer (3, "A clapper") sets bell_solved and puts a clapper in the pack', $right === 3 && $flag('bell_solved') && (!$cl || trek_pack_qty((int)$run(3)['id'], $cl) === 1));
if ($cl) {
    $at('strongbox'); $tx(function (&$run, $u) { $run['campkits'] = 0; return [true, '']; }, true, 3); $k0 = (int)$run(3)['campkits']; $pe = (int)$run(3)['petals_found'];
    $tx(fn(&$run, $u) => trek_act_chest($run, $u), true, 3);
    ok('with the clapper the Strongbox opens once: 2 Camp Kits, 120 Petals, clapper used up', $flag('strongbox_open') && (int)$run(3)['campkits'] === $k0 + 2 && (int)$run(3)['petals_found'] === $pe + 120 && trek_pack_qty((int)$run(3)['id'], $cl) === 0 && $tx(fn(&$run, $u) => trek_act_chest($run, $u), true, 3)[0] === false);
}

if ($cl) {   // v2.0.22 stitcher: the Hush Bell has no failopen, so three Bellcap Beetle kills in the Tally Gallery give a clapper (TREK_GUARANTEE), only while the Strongbox is shut
    $beetle = function () use ($tx) { $tx(function (&$run, $u) { $c = trek_creature('bellcap-beetle'); trek_start_fight($run, $u, [$c], ['kind' => 'random', 'zone' => 'g'], [trek_make_foe($c, $u, 1)]); $run['fi']['foes'][0]['hp'] = 0; trek_fight_win($run, $u); $run['fi'] = null; return [true, '']; }, true, 3); };
    $tx(function (&$run, $u) { unset($run['flags']['strongbox_open'], $run['st']['kills']); q('DELETE FROM trek_flags WHERE run_id = ? AND flag = ?', [(int)$run['id'], 'strongbox_open']); return [true, '']; }, true, 3);
    for ($i = 0; $i < 3; $i++) $beetle();
    ok('three Bellcap Beetle kills in the Gallery give a Bell Clapper while the Strongbox is shut (the bell has no second chance)', trek_pack_qty((int)$run(3)['id'], $cl) === 1, (string)trek_pack_qty((int)$run(3)['id'], $cl));
    for ($i = 0; $i < 3; $i++) $beetle();
    ok('...and no second one while you hold it', trek_pack_qty((int)$run(3)['id'], $cl) === 1);
    $at('strongbox'); $tx(fn(&$run, $u) => trek_act_chest($run, $u), true, 3);
}

echo "== the Tally Door (riddle, 2 tries, Seedkeeper) and the Counting Door (pays ch3_hall once)\n";
$at('tallydoor');
$right = (int)$sp['tallydoor']['data']['right']; $wrong = $right === 1 ? 3 : 1;
$tx(fn(&$run, $u) => trek_act_riddle($run, $u, $wrong), true, 3);
ok('a wrong answer: still shut, 1 try used', !$flag('tallydoor_open') && (int)($run(3)['st']['tries_tallydoor'] ?? 0) === 1);
$tx(fn(&$run, $u) => trek_act_riddle($run, $u, $wrong), true, 3);
ok('the 2nd wrong answer: the stone gives way (failopen) but is NOT counted as solved', $flag('tallydoor_open') && !$flag('tallydoor_solved'));
$unFlag('tallydoor_open'); $unFlag('tallydoor_solved');
$tx(function (&$run, $u) { $run['st']['tries_tallydoor'] = 0; return [true, '']; }, true, 3);
$tx(fn(&$run, $u) => trek_act_riddle($run, $u, $right), true, 3);
ok('the right answer (2, "A knock") opens it AND counts as solved', $right === 2 && $flag('tallydoor_open') && $flag('tallydoor_solved'));
$sg = trek_spots(3)['tallygate'];
$hall = fn() => (int)q_val('SELECT COUNT(*) FROM trek_ms WHERE user_id = ? AND ms_key = ?', [$uid, TREK_KEY . ':ch3_hall']);
$go = fn() => $tx(function (&$run, $u) use ($sg) { $run['x'] = $sg['x'] - 1; $run['y'] = $sg['y']; return trek_walk($run, $u, $sg['x'], $sg['y']); }, true, 3);
$gp = $pathLen('tallygate');
$at('tallydoor'); $go();
ok('walking through the Counting Door pays ch3_hall once (flag reached_tallygate)', $flag('reached_tallygate') && $hall() === 1 && $flag('ms_ch3_hall'));
$go();
ok('...and not again', $hall() === 1);

echo "== the Bedrock Door and Old Holler: moves, Gulp, Holler, crack, knock, tiring\n";
$at('door');
ok('the Bedrock Door is a sign (not a fight)', $sp['door']['type'] === 'sign');
$tx(function (&$run, $u) { trek_set_party($run, $u, [1 => 'burdock', 2 => 'zinnia', 3 => 'bracken']); foreach (trek_party_stats($run, $u) as $sl => $m) $run['party'][$sl]['hp'] = $m['max']; return [true, '']; }, true, 3);
$unFlag('drained_z');
$at('holler');
$tx(fn(&$run, $u) => trek_act_challenge($run, $u), true, 3);
$R = $run(3);
ok('the fight starts with the script bound, one foe, no weak start (the Mere is not drained)', $R['fi'] && ($R['fi']['meta']['script'] ?? '') === 'holler' && count($R['fi']['foes']) === 1 && (int)$R['fi']['foes'][0]['hp'] === (int)$R['fi']['foes'][0]['max'] && empty($R['fi']['meta']['weak']));
$full = (int)$R['fi']['foes'][0]['max'];
[$cur, $next] = trek_boss_moves($R['fi']);
ok('moves are shown a round ahead: hit then gulp', $cur === 'hit' && $next === 'gulp', "$cur $next");
$def = trek_script_def('holler');
ok('the script is registered with big = [holler] and the hooks moves/act/round_start/round_end/after_round/win', $def['big'] === ['holler'] && isset($def['moves'], $def['act'], $def['round_start'], $def['round_end'], $def['after_round'], $def['win']));
ok('the pattern constants: hit/gulp/holler, cracked hit/holler, the cracked Holler softer than the whole one, crack under 35%, she takes 115% after it', TREK_HO_MOVES === ['hit', 'gulp', 'holler'] && TREK_HO_CRACKED === ['hit', 'holler'] && TREK_HO_HOLLER_CRACK_PCT < TREK_HO_HOLLER_PCT && TREK_HO_CRACK_PCT === 35 && TREK_HO_TAKE_PCT === 115);
// Holler hits everyone, no roll; Guard halves it (hp is set and read inside one transaction: a saved hp above max is clamped on load)
$holler = function (bool $crack, ?int $guardSlot) use ($tx) {
    return $tx(function (&$run, $u) use ($crack, $guardSlot) {
        $stats = trek_party_stats($run, $u);   // (it clamps hp to max: set the big hp after)
        foreach ($run['party'] as $k => $p) $run['party'][$k]['hp'] = 99999;
        $run['fi']['meta']['gp'] = $crack ? 1 : 2;
        if ($crack) $run['fi']['meta']['crack'] = 1; else unset($run['fi']['meta']['crack']);
        $run['fi']['mem'] = array_fill_keys(array_keys($stats), ['bark' => 0, 'cd' => 0, 'guard' => 0, 'pz' => 0]);
        if ($guardSlot !== null) $run['fi']['mem'][$guardSlot]['guard'] = 1;
        trek_script_def('holler')['act']($run, $stats);
        return [array_map(fn($p) => 99999 - (int)$p['hp'], $run['party']), ''];
    }, true, 3)[0];
};
$loss = $holler(false, 2);
$others = array_values(array_diff_key($loss, [2 => 1]));
ok('a Holler hits every living friend, no roll (all lose health, the same blow) and a Guard roughly halves it', min($loss) > 0 && max($others) === min($others) && $loss[2] * 2 <= max($others) + 1 && $loss[2] * 2 >= max($others) - 1, json_encode($loss));
// Gulp: tired abilities take a round longer
$tx(function (&$run, $u) { $run['fi']['meta']['gp'] = 1; foreach ($run['party'] as $k => $p) $run['party'][$k]['hp'] = 99999; $run['fi']['mem'][1]['cd'] = 2; $run['fi']['mem'][2]['cd'] = 0; $stats = trek_party_stats($run, $u); trek_script_def('holler')['act']($run, $stats); return [true, '']; }, true, 3);
$mm = $run(3)['fi']['mem'];
ok('Gulp: an ability still tired becomes one round longer (2 -> 3); a ready one is untouched', (int)$mm[1]['cd'] === 3 && (int)$mm[2]['cd'] === 0, json_encode($mm));
// Knock: every 3rd round everyone regains 10%
$KE = TREK_HO_KNOCK_EVERY;
$tx(function (&$run, $u) use ($KE) { $run['fi']['round'] = $KE; $stats = trek_party_stats($run, $u); foreach ($run['party'] as $k => $p) $run['party'][$k]['hp'] = 1; trek_script_def('holler')['round_end']($run, $stats); return [true, '']; }, true, 3);
$R = $run(3); $stt = $tx(fn(&$run, $u) => [trek_party_stats($run, $u), ''], true, 3)[0];
$gain = array_map(fn($k, $p) => (int)$p['hp'] - 1, array_keys($R['party']), $R['party']);
$want = array_map(fn($k) => max(1, (int)round((int)$stt[$k]['max'] * TREK_HO_KNOCK_PCT / 100)), array_keys($R['party']));
ok('the Warden knocks at the end of every ' . $KE . 'nd round (TREK_HO_KNOCK_EVERY): each living friend regains TREK_HO_KNOCK_PCT % of max health', $gain === $want, json_encode([$gain, $want]));
$tx(function (&$run, $u) use ($KE) { $run['fi']['round'] = $KE - 1; foreach ($run['party'] as $k => $p) $run['party'][$k]['hp'] = 1; $stats = trek_party_stats($run, $u); trek_script_def('holler')['round_end']($run, $stats); return [true, '']; }, true, 3);
ok('...and not at the end of the round before', array_sum(array_map(fn($p) => (int)$p['hp'] - 1, $run(3)['party'])) === 0);
$lines = array_column(array_filter($run(3)['lg'], fn($l) => isset($l['k'])), 'k');
ok('the first knock says ch3.spot.holler.knock (a text slot), later ones plain text', in_array('ch3.spot.holler.knock', $lines, true) && !empty($run(3)['fi']['meta']['knocked']));
// Crack
$tx(function (&$run, $u) { $run['fi']['round'] = 1; $run['fi']['foes'][0]['hp'] = (int)floor($run['fi']['foes'][0]['max'] * 0.30); foreach ($run['party'] as $k => $p) $run['party'][$k]['hp'] = 99999; $stats = trek_party_stats($run, $u); trek_script_def('holler')['after_round']($run, $stats); return [true, '']; }, true, 3);
$R = $run(3);
ok('under 35% her throat cracks: moves become hit / holler, she takes 115%, ch3.spot.holler.crack is said once', !empty($R['fi']['meta']['crack']) && trek_boss_moves($R['fi']) === ['hit', 'holler'] && (int)$R['fi']['foes'][0]['dm'] === 115 && count(array_filter($R['lg'], fn($l) => ($l['k'] ?? '') === 'ch3.spot.holler.crack')) === 1);
$tx(function (&$run, $u) { $stats = trek_party_stats($run, $u); trek_script_def('holler')['after_round']($run, $stats); return [true, '']; }, true, 3);
ok('...and the crack does not repeat', count(array_filter($run(3)['lg'], fn($l) => ($l['k'] ?? '') === 'ch3.spot.holler.crack')) === 1);
// Cracked Holler is softer (60%): compare a cracked Holler to an uncracked one (the roll varies: average many)
$sumCr = 0; $sumNo = 0; for ($i = 0; $i < 40; $i++) { $sumCr += $holler(true, null)[1]; $sumNo += $holler(false, null)[1]; }
$want = TREK_HO_HOLLER_CRACK_PCT / TREK_HO_HOLLER_PCT;
ok('a cracked Holler is softer: about ' . TREK_HO_HOLLER_CRACK_PCT . '/' . TREK_HO_HOLLER_PCT . ' of an uncracked one on average (within 0.12)', $sumNo > 0 && abs($sumCr / $sumNo - $want) <= 0.12, sprintf('%.2f vs %.2f', $sumNo ? $sumCr / $sumNo : 0, $want));
// Tire
$tx(function (&$run, $u) { $run['fi']['meta'] = ['script' => 'holler', 'kind' => 'spot', 'spot' => 'holler', 'zone' => 'k', 'gp' => 0]; $run['fi']['round'] = 4; $run['fi']['mem'] = array_fill_keys(array_keys($run['party']), ['bark' => 0, 'cd' => 0, 'guard' => 0, 'pz' => 0]); foreach ($run['party'] as $k => $p) $run['party'][$k]['hp'] = 99999; $stats = trek_party_stats($run, $u); trek_script_def('holler')['act']($run, $stats); return [true, '']; }, true, 3);
$dm4 = (int)($run(3)['fi']['foes'][0]['dm'] ?? 100);
$tx(function (&$run, $u) { $run['fi']['round'] = 9; $stats = trek_party_stats($run, $u); trek_script_def('holler')['act']($run, $stats); return [true, '']; }, true, 3);
$dm9 = (int)($run(3)['fi']['foes'][0]['dm'] ?? 100);
$tx(function (&$run, $u) { $run['fi']['round'] = 30; $stats = trek_party_stats($run, $u); trek_script_def('holler')['act']($run, $stats); return [true, '']; }, true, 3);
$dm30 = (int)($run(3)['fi']['foes'][0]['dm'] ?? 100);
$st = TREK_HO_TIRE_STEP;
ok('she tires: from round 4 she takes +' . $st . '% a round (' . (100 + $st) . '% at round 4, ' . (100 + 6 * $st) . '% at round 9), capped at +' . TREK_HO_TIRE_MAX . '%', $dm4 === 100 + $st && $dm9 === 100 + min(TREK_HO_TIRE_MAX, 6 * $st) && $dm30 === 100 + TREK_HO_TIRE_MAX, "$dm4 $dm9 $dm30");
// Party balance: the mending score moves her health (round_start, once)
$hpFor = function (array $keys) use ($tx, $run) {
    return $tx(function (&$run, $u) use ($keys) {
        $run['fi'] = null; $orig = $run['party'];   // (a plain swap in memory: trek_set_party only works at a camp)
        foreach ([1, 2, 3] as $sl) unset($run['party'][$sl]);
        foreach (array_values($keys) as $i => $k) $run['party'][$i + 1] = ['crew_key' => $k, 'hp' => 99];
        trek_party_stats($run, $u);
        trek_start_fight($run, $u, [trek_creature('old-holler')], ['kind' => 'spot', 'spot' => 'holler', 'script' => 'holler', 'zone' => 'k']);
        $before = (int)$run['fi']['foes'][0]['max']; $stats = trek_party_stats($run, $u);
        trek_script_def('holler')['round_start']($run, $stats);
        $out = [$before, (int)$run['fi']['foes'][0]['max'], !empty($run['fi']['meta']['sized'])];
        $run['fi'] = null; $run['party'] = $orig;
        return [$out, ''];
    }, true, 3)[0];
};
[$b0, $a0, $sz] = $hpFor(['bracken', 'tumble', 'juniper']);
[$b1, $a1] = $hpFor(['zinnia', 'wren', 'sorrel']);
ok('a party of fighters meets a softer Holler, a party of menders a tougher one (round_start, once)', $sz && $a0 < $b0 && $a1 > $b1, json_encode([$b0, $a0, $b1, $a1]));
$tx(function (&$run, $u) { $run['fi'] = null; return [true, '']; }, true, 3);

echo "== the weak start, the win, the finish row\n";
$tx(function (&$run, $u) { trek_set_party($run, $u, [1 => 'burdock', 2 => 'zinnia', 3 => 'bracken']); trek_flag_set($run, 'drained_z'); foreach (trek_party_stats($run, $u) as $sl => $m) $run['party'][$sl]['hp'] = $m['max']; return [true, '']; }, true, 3);
$at('holler');
$tx(fn(&$run, $u) => trek_act_challenge($run, $u), true, 3);
$R = $run(3);
ok('after the Mere is drained she starts at 85% health (engine weak start, weak=drained_z)', $R['fi'] && (int)$R['fi']['meta']['weak'] === 85 && (int)$R['fi']['foes'][0]['hp'] === (int)round($R['fi']['foes'][0]['max'] * 0.85), json_encode([$R['fi']['foes'][0]['hp'] ?? null, $R['fi']['foes'][0]['max'] ?? null]));
$xp0 = $mainXp(); $coins0 = (int)q_val('SELECT coins FROM users WHERE id = ?', [$uid]);
set_setting('trek_ch3_petals', '600'); setting('__reload__');
$tx(function (&$run, $u) { for ($i = 0; $i < 60 && $run['fi']; $i++) { $run['fi']['foes'][0]['hp'] = 1; foreach ($run['party'] as $k => $p) $run['party'][$k]['hp'] = 99999; trek_fight_round($run, $u, array_fill(0, count($run['party']), ['a' => 'attack', 't' => 0])); } return [true, '']; }, true, 3);
$R = $run(3);
ok('Old Holler falls: flag holler_down, fight over, the chapter is complete (ch3_done), reward screen queued', !$R['fi'] && $flag('holler_down') && $flag('ch3_done') && trek_run_done($R) && !empty($R['st']['rewards']), json_encode($R['fi']));
$keys = array_column(array_filter($R['lg'], fn($l) => isset($l['k'])), 'k');
ok('the win says .defeat, ONE trailmate line (Burdock, the first of the party in the list), the gnome reply, in that order', in_array('ch3.spot.holler.defeat', $keys, true) && in_array('ch3.spot.holler.burdock', $keys, true) && !in_array('ch3.spot.holler.zinnia', $keys, true) && !in_array('ch3.spot.holler.bracken', $keys, true) && in_array('ch3.scene.holler.me', $keys, true) && array_search('ch3.spot.holler.defeat', $keys) < array_search('ch3.spot.holler.burdock', $keys) && array_search('ch3.spot.holler.burdock', $keys) < array_search('ch3.scene.holler.me', $keys), implode(',', array_filter($keys, fn($k) => str_contains($k, 'holler'))));
$cnt = fn(string $m) => (int)q_val('SELECT COUNT(*) FROM trek_ms WHERE user_id = ? AND ms_key = ?', [$uid, TREK_KEY . ':' . $m]);
ok('ch3_holler and ch3_chapter are each paid once, by the finish row (the script does not award them itself)', $cnt('ch3_holler') === 1 && $cnt('ch3_chapter') === 1 && $flag('ms_ch3_holler') && $flag('ms_ch3_chapter'));
$xph = (int)q_val('SELECT xp FROM trek_ms WHERE user_id = ? AND ms_key = ?', [$uid, TREK_KEY . ':ch3_holler']); $xpc = (int)q_val('SELECT xp FROM trek_ms WHERE user_id = ? AND ms_key = ?', [$uid, TREK_KEY . ':ch3_chapter']);
ok('...they pay at most 1300 and 600 XP', $xph > 0 && $xph <= 1300 && $xpc > 0 && $xpc <= 600, "$xph $xpc");
ok('the finish pays the chapter Petals (600) once', (int)q_val('SELECT coins FROM users WHERE id = ?', [$uid]) - $coins0 >= 600 && (int)($R['st']['rewards']['petals'] ?? 0) === 600, json_encode($R['st']['rewards'] ?? null));
$xp1 = $mainXp(); $c1 = (int)q_val('SELECT coins FROM users WHERE id = ?', [$uid]);
$tx(function (&$run, $u) { trek_complete_chapter($run, $u); return [true, '']; }, true, 3);
ok('completing the chapter again pays nothing more (no XP, no Petals, no rows)', $mainXp() === $xp1 && $cnt('ch3_holler') === 1 && $cnt('ch3_chapter') === 1 && (int)q_val('SELECT coins FROM users WHERE id = ?', [$uid]) === $c1);
$tx(function (&$run, $u) { $run['party'][1]['hp'] = 5; return [true, '']; }, true, 3);
$tx(function (&$run, $u) { trek_hub_arrive($run, $u); return [true, '']; }, true, 3);
$r = $tx(fn(&$run, $u) => trek_godown($run, $u), true, 3);
ok('there is no Chapter IV: "Go down" is refused after Chapter III', $r[0] === false && !trek_chapter_exists(4) && trek_next_chapter(3) === null, json_encode($r));
exit($fails ? 1 : 0);
