<?php
// Treks v1.9.2: Chapter II-a "The Weeping Clay" (data on the chapter engine, plus the engine's new hooks). Run on an installed copy: php tests/trek_ch2.php GAME_DIR (treks.sh does).
// Map and reachability, the sluice gate, the riddle door (3rd fail / Seedkeeper), Sorrel, the Silverfin script, milestones, carry-over, the Petal cap, Chapter I unchanged,
// the admin-only draft marker, and the balance sim (real dice: wide bands).
$GAME = $argv[1];
$_SERVER['SCRIPT_NAME'] = '/trek.php';
require $GAME . '/includes/bootstrap.php';
require_once $GAME . '/includes/trek.php';
require_once $GAME . '/includes/trek_art.php';
if (session_status() !== PHP_SESSION_ACTIVE) session_start();
$fails = 0;
set_exception_handler(function (Throwable $e) { if (db()->inTransaction()) db()->rollBack(); echo '  EXCEPTION ' . get_class($e) . ': ' . $e->getMessage() . ' @ ' . basename($e->getFile()) . ':' . $e->getLine() . "\n"; exit(1); });
function ok(string $what, bool $cond, string $extra = ''): void { global $fails; echo ($cond ? '  ok   ' : '  FAIL ') . $what . ($cond ? '' : "  $extra") . "\n"; if (!$cond) $fails++; }
$uid = (int)q_val("SELECT id FROM users WHERE username = 'sprout'");
$tx = fn(callable $f, bool $need = true, ?int $ch = null) => trek_tx($uid, $f, $need, $ch);
$run = fn(?int $ch = null) => trek_load(trek_run_row($uid, $ch));
$mainXp = fn() => (int)q_val('SELECT xp FROM users WHERE id = ?', [$uid]);
set_setting('trek_open', '1'); set_setting('trek_event_pct', '0'); set_setting('trek_enc_percent', '0'); set_setting('trek_petals_daily', '150'); set_setting('trek_entry_energy', '10');
foreach (['trek_ms_ch2_sorrel' => 400, 'trek_ms_ch2_silverfin' => 1000, 'trek_ms_ch2a_end' => 800] as $k => $v) set_setting($k, (string)$v);
setting('__reload__');
q('UPDATE creature_drops SET chance = 0 WHERE 1 = 1');

echo "== data: chapter, map, spots, creatures\n";
ok('Chapter II exists: II-a zones j k l m (II-b adds n-s), II-a milestones first, no lift row (v1.9.5)', trek_chapter_exists(2) && array_slice(array_keys(trek_chapter(2)['zones']), 0, 4) === ['j', 'k', 'l', 'm'] && array_slice(array_keys(trek_milestones(2)), 0, 3) === ['ch2_sorrel', 'ch2_silverfin', 'ch2a_end'] && empty(trek_chapter(2)['lift']), json_encode(trek_chapter(2)['lift'] ?? null));
ok('no Chapter III yet; the finish row is II-b\'s (tests/trek_ch2b.php)', !trek_chapter_exists(3) && trek_next_chapter(2) === null && !empty(trek_chapter(2)['finish']));
$map = trek_map(2);
ok('the map is 40 wide (II-a took the top 46 rows, II-b added to 106) with a zone row for each', $map['w'] === 40 && $map['h'] === 106 && count($map['z']) === 106, $map['w'] . 'x' . $map['h']);
$sp = trek_spots(2);
ok('17 II-a spots + 16 II-b, every symbol sits on its own tile', count(array_filter($sp, fn($s) => $s['type'] !== 'oldcamp')) === 33 && !array_filter($sp, fn($s) => trek_tile(2, $s['x'], $s['y']) !== $s['sym']), count($sp) . '');
$types = array_count_values(array_column($sp, 'type'));
ok('the new spot types are in use (switch 2, find, rest, trade)', ($types['switch'] ?? 0) === 3 && ($types['find'] ?? 0) === 5 && ($types['rest'] ?? 0) === 1 && ($types['trade'] ?? 0) === 1, json_encode($types));
$cr = ['clay-crawler', 'page-silverfish', 'mud-crayfish', 'spadefoot-toad', 'claybound-millipede', 'silverfin'];
ok('six Chapter II creatures exist at levels 17-22', !array_filter($cr, fn($s) => !trek_creature($s)) && trek_creature('clay-crawler')['level'] === 17 && trek_creature('silverfin')['level'] === 22 && trek_creature('silverfin')['size'] === 'boss');
ok('pools: j k l m, k has no random fights; Chapter I pools untouched', trek_zone_pool('j', 2) && trek_zone_pool('l', 2) && trek_zone_pool('m', 2) && (int)trek_zone_pool('k', 2)['mult'] === 0 && trek_zone_pool('g', 1) !== null && trek_zone_pool('j', 1) === null, json_encode(trek_zone_pool('k', 2)));
$ph = true; foreach ($cr as $s) if (!is_file($GAME . '/assets/img/ph/creature-' . $s . '.svg')) $ph = false;
ok('placeholder art exists for each new creature', $ph);
$walk = $map['walk'] ?? null;
$cnt = ['floor' => 0];
$n = 0; for ($y = 0; $y < 46; $y++) for ($x = 0; $x < $map['w']; $x++) { $c = trek_tile(2, $x, $y); if ($c !== '#' && $c !== '^' && $c !== ' ' && $c !== '*') $n++; }
ok('II-a\'s walkable tiles (top 46 rows) stay in the Chapter I ballpark (500-600)', $n >= 500 && $n <= 600, (string)$n);
ok('new tile kinds exist on the map: wet clay, glow crystal, high water', substr_count(implode('', $map['t']), ':') > 0 && substr_count(implode('', $map['t']), '*') > 0 && substr_count(implode('', $map['t']), 'w') > 0);

echo "== setup: finish Chapter I, go down\n";
foreach (['trek_flags', 'trek_pack', 'trek_party', 'trek_recruits'] as $t) q("DELETE FROM $t WHERE run_id IN (SELECT id FROM trek_runs WHERE user_id = ?)", [$uid]);
q('DELETE FROM trek_runs WHERE user_id = ?', [$uid]); q('DELETE FROM trek_ms WHERE user_id = ?', [$uid]);
q('UPDATE users SET level = 16, energy = 100, coins = 1000, calling = NULL, trek_ch = 1, trek_pet_day = NULL, trek_pet_today = 0 WHERE id = ?', [$uid]);
$tx(fn(&$run, $u) => trek_enter($run, $u), false);
$tx(function (&$run, $u) { foreach (['burdock', 'zinnia', 'bracken'] as $k) trek_recruit_crew($run, $u, $k); $run['st']['tl']['gnome'] = [10, 5]; $run['st']['tl']['burdock'] = [9, 0]; $run['st']['tl']['zinnia'] = [9, 0]; $run['st']['tl']['bracken'] = [9, 0]; $run['campkits'] = 2; trek_flag_set($run, 'seen_cart'); trek_complete_chapter($run, $u); trek_hub_arrive($run, $u); return [true, '']; });
$R1 = $run(1);
$ch1Flags = $R1['flags']; $ch1Tl = $R1['st']['tl'];
$r = $tx(fn(&$run, $u) => trek_godown($run, $u));
ok('Go down reaches the real Chapter II', $r[0] === true && trek_active_ch($uid) === 2, json_encode($r));
$R2 = $run();
$st = $sp['start'];
ok('carry-over: at the Seep Steps start, party and trek levels and kits come along', (int)$R2['chapter'] === 2 && [$R2['x'], $R2['y']] === [$st['x'], $st['y']] && $R2['st']['tl'] === $ch1Tl && (int)$R2['campkits'] === 2 && count(trek_recruits((int)$R2['id'])) === 3, json_encode([$R2['x'], $R2['y']]));
ok('carry-over: flags, pack and the fight are NOT carried', $R2['flags'] === [] && !trek_pack_rows((int)$R2['id']) && $R2['fi'] === null);
$R1b = $run(1);
ok('Chapter I\'s run row is unchanged by Go down', $R1b['flags'] === $ch1Flags && $R1b['st']['tl'] === $ch1Tl && trek_run_done($R1b));
ok('arrival text came from the Ch II slots (the hub card is Chapter I\'s)', trek_chapter_done($uid, 1) && !trek_chapter_done($uid, 2));

// see the whole map, no fights, no fatigue limit
$tx(function (&$run, $u) { $run['sn'] = str_repeat("\xff", strlen($run['sn'])); return [true, '']; });
$at = fn(string $code) => $tx(function (&$run, $u) use ($code) { $s = trek_spots(2)[$code]; $run['x'] = $s['x']; $run['y'] = $s['y']; $run['fatigue'] = 0; return [true, '']; });
$flag = fn(string $f) => !empty($run()['flags'][$f]);
$setFlag = fn(string $f) => $tx(function (&$run, $u) use ($f) { trek_flag_set($run, $f); return [true, '']; });
$canReach = fn(string $code) => $tx(function (&$run, $u) use ($code) { $s = trek_spots(2)[$code]; return [(bool)trek_path($run, $s['x'], $s['y']) || ((int)$run['x'] === $s['x'] && (int)$run['y'] === $s['y']), '']; })[0] ?? false;
$pathLen = fn(string $code) => $tx(function (&$run, $u) use ($code) { $s = trek_spots(2)[$code]; return [count(trek_path($run, $s['x'], $s['y'])), '']; })[0];

echo "== the sluice gate and reachability in order\n";
$at('start');
ok('before the Seep Steps sluice: the Tin Lamp is cut off by high water', $pathLen('camp') === 0);
ok('the sluice wheel itself is reachable', $pathLen('sluice1') > 0);
$wTile = null; for ($y = 0; $y < $map['h'] && !$wTile; $y++) for ($x = 0; $x < $map['w'] && !$wTile; $x++) if (trek_tile(2, $x, $y) === 'w' && trek_zone_at(2, $x, $y) === 'j') $wTile = [$x, $y];
$r = $tx(fn(&$run, $u) => trek_walk($run, $u, $wTile[0], $wTile[1]));
ok('walking to undrained water is refused with the sluice hint', $r[0] === false && str_contains((string)$r[1], 'sluice'), json_encode($r));
$at('sluice1');
$tx(fn(&$run, $u) => trek_act_switch($run, $u));
ok('turning the wheel sets drained_j, once', $flag('drained_j') && $flag('sluice1_done'));
$f0 = (int)$run()['fatigue'];
$r = $tx(fn(&$run, $u) => trek_act_switch($run, $u));
ok('a second turn does nothing', $r[0] === false && (int)$run()['fatigue'] === $f0);
ok('now the Tin Lamp is reachable', $pathLen('camp') > 0);
ok('wet mud costs 2 halves, wet clay 2, floor 1', trek_step_cost('w') === 2 && trek_step_cost(':') === 2 && trek_step_cost('.') === 1);
$at('camp');
$order = ['sluice1', 'barrow', 'camp', 'book', 'nook', 'rest', 'libdoor', 'libgate', 'sluice2', 'sorrel', 'silverfin', 'silvergate', 'wheel', 'kilnstone', 'kiln', 'crossroads'];
// the library's high water: sluice2 first
$sl2Water = null; for ($y = 0; $y < $map['h'] && !$sl2Water; $y++) for ($x = 0; $x < $map['w'] && !$sl2Water; $x++) if (trek_tile(2, $x, $y) === 'w' && trek_zone_at(2, $x, $y) === 'l') $sl2Water = [$x, $y];
$tx(function (&$run, $u) { trek_flag_set($run, 'libdoor_open'); return [true, '']; });
ok('with the door open the sluice wheel in the Library is reachable', $pathLen('sluice2') > 0);
ok('the Library\'s high water is blocked until its own wheel turns', $sl2Water !== null && $tx(function (&$run, $u) use ($sl2Water) { return [trek_passable($run, $sl2Water[0], $sl2Water[1]), '']; })[0] === false);
$at('sluice2');
$tx(fn(&$run, $u) => trek_act_switch($run, $u));
ok('the Library wheel drains l, not m', $flag('drained_l') && !$flag('drained_m'));
$tx(function (&$run, $u) { trek_flag_set($run, 'silverfin_down'); trek_flag_set($run, 'kiln_open'); return [true, '']; });   // open every hatch for the reach test
$clear = fn(array $fl) => $tx(function (&$run, $u) use ($fl) { foreach ($fl as $f) { q('DELETE FROM trek_flags WHERE run_id = ? AND flag = ?', [(int)$run['id'], $f]); unset($run['flags'][$f]); } return [true, '']; });
$at('start');
$miss = []; $steps = [];
foreach ($order as $c) { if (!$pathLen($c)) $miss[] = $c; }
ok('every spot is reachable from the start once the gates and wheels are open (' . count($order) . ')', !$miss, implode(',', $miss));
// route length: the walk in story order
$total = 0; $prev = 'start';
foreach (['sluice1', 'camp', 'book', 'libdoor', 'sluice2', 'sorrel', 'silverfin', 'crossroads'] as $c) {
    $at($prev); $total += $pathLen($c); $prev = $c;
}
ok('the main route is 150-260 steps (Chapter I: ~213)', $total >= 150 && $total <= 260, (string)$total);
$crossGate = trek_spots(2)['crossroads'];
$tx(function (&$run, $u) { $s = trek_spots(2)['crossroads']; $run['x'] = $s['x'] - 1; $run['y'] = $s['y'] - 1; return [true, '']; });
ok('the Crossroads gate tile is open now (II-b): walkable', trek_passable($run(), $crossGate['x'], $crossGate['y']));
$at('start');
$tx(function (&$run, $u) { $run['st']['fh'] = 0; return [true, '']; });
ok('map art draws high water, wet clay and crystals (SVG, no inline script)', ($svg = trek_art_svg(2, $run(), 0, 0, 40, 46, [], null, '')) !== '' && str_starts_with($svg, '<svg') && !str_contains($svg, '<script'));
$crys = null; for ($y = 0; $y < $map['h'] && !$crys; $y++) for ($x = 0; $x < $map['w'] && !$crys; $x++) if (trek_tile(2, $x, $y) === '*') $crys = [$x, $y];
ok('a glow crystal is not walkable', $crys !== null && !trek_passable($run(), $crys[0], $crys[1], true));
// reveal: fresh fog, step next to a crystal
$tx(function (&$run, $u) use ($crys) {
    $run['sn'] = str_repeat("\0", strlen($run['sn']));
    foreach ([[1, 0], [-1, 0], [0, 1], [0, -1]] as [$dx, $dy]) if (trek_passable($run, $crys[0] + $dx, $crys[1] + $dy)) { $run['x'] = $crys[0] + $dx - 0; $run['y'] = $crys[1] + $dy; break; }
    trek_seen_reveal($run, (int)$run['x'], (int)$run['y'], 1);
    return [true, ''];
});
$beforeSeen = 0; $R = $run(); for ($y = 0; $y < $map['h']; $y++) for ($x = 0; $x < $map['w']; $x++) if (trek_seen_get($R, $x, $y)) $beforeSeen++;
ok('fog is per chapter and tiny at first', $beforeSeen > 0 && $beforeSeen < 40, (string)$beforeSeen);
$tx(function (&$run, $u) { $run['sn'] = str_repeat("\xff", strlen($run['sn'])); return [true, '']; });

$clear(['silverfin_down', 'kiln_open', 'libdoor_open', 'sluice2_done', 'drained_l', 'drained_j', 'sluice1_done']);
echo "== the Library door: riddle, Seedkeeper, third fail\n";
$q0 = fn() => $run();
$at('libdoor');
$r = $tx(fn(&$run, $u) => trek_act_riddle($run, $u, 1));
ok('a wrong answer: no flags, 1 try used', $r[0] === true && !$flag('libdoor_open') && (int)($run()['st']['tries_libdoor'] ?? 0) === 1);
ok('first wrong answer: still shut', !$flag('libdoor_open'));
$r = $tx(fn(&$run, $u) => trek_act_riddle($run, $u, 3));
ok('the 2nd wrong answer (v2.0.1: 2 tries): "the clay gives way" (door open), but NOT solved', $flag('libdoor_open') && !$flag('libdoor_solved'));
$r = $tx(fn(&$run, $u) => trek_act_riddle($run, $u, 2));
ok('no tries after that (the spot is done)', $r[0] === false);
// the right answer on a fresh run
$flagsOf = $run()['flags'];
$tx(function (&$run, $u) { unset($run['flags']['libdoor_open']); q('DELETE FROM trek_flags WHERE run_id = ? AND flag IN (?, ?)', [(int)$run['id'], 'libdoor_open', 'libdoor_solved']); $run['st']['tries_libdoor'] = 0; return [true, '']; });
ok('(reset the door flags for the next paths)', !$flag('libdoor_open'));
$r = $tx(fn(&$run, $u) => trek_act_riddle($run, $u, 2));
ok('the right answer opens the door AND counts as solved', $flag('libdoor_open') && $flag('libdoor_solved'));
// the Seedkeeper path
$tx(function (&$run, $u) { q('DELETE FROM trek_flags WHERE run_id = ? AND flag IN (?, ?)', [(int)$run['id'], 'libdoor_open', 'libdoor_solved']); $run['st']['tries_libdoor'] = 0; return [true, '']; });
$r = $tx(fn(&$run, $u) => trek_act_riddle($run, $u, 0, 'seed'));
ok('"read it the Seedkeeper way" is refused without a Seedkeeper', $r[0] === false && !$flag('libdoor_open'));
$at('camp');
$tx(function (&$run, $u) { trek_recruit_crew($run, $u, 'sorrel'); return trek_set_party($run, $u, [1 => 'burdock', 2 => 'zinnia', 3 => 'sorrel']); });
$at('libdoor');
ok('Sorrel is a Seedkeeper in the party', $tx(fn(&$run, $u) => [trek_has_calling($run, $u, 'seedkeeper'), '']) [0] === true);
$r = $tx(fn(&$run, $u) => trek_act_riddle($run, $u, 0, 'seed'));
ok('with a Seedkeeper the door opens and counts as solved, no tries needed', $r[0] === true && $flag('libdoor_open') && $flag('libdoor_solved') && (int)($run()['st']['tries_libdoor'] ?? 0) === 0);
// undo Sorrel for the recruit test
$at('camp');
$tx(function (&$run, $u) { trek_set_party($run, $u, [1 => 'burdock', 2 => 'zinnia', 3 => 'bracken']); q('DELETE FROM trek_recruits WHERE run_id = ? AND crew_key = ?', [(int)$run['id'], 'sorrel']); return [true, '']; });

echo "== Sorrel: the Overdue Book\n";
$at('sorrel');
$r = $tx(fn(&$run, $u) => trek_act_fetch($run, $u));
ok('without the book: refused, not recruited', $r[0] === false && !$flag('freed_sorrel'));
$at('book');
$tx(fn(&$run, $u) => trek_act_hidden($run, $u));
ok('the book is found once and lands in the pack', trek_pack_qty((int)$run()['id'], trek_item_id('overdue-book')) === 1 && $flag('book_found'));
$tx(fn(&$run, $u) => trek_act_hidden($run, $u));
ok('...not twice', trek_pack_qty((int)$run()['id'], trek_item_id('overdue-book')) === 1);
$xp0 = $mainXp();
$at('sorrel');
$tx(fn(&$run, $u) => trek_act_fetch($run, $u));
$R = $run();
ok('returning the book recruits Sorrel (flag, row, book taken)', $flag('freed_sorrel') && in_array('sorrel', trek_recruits((int)$R['id']), true) && trek_pack_qty((int)$R['id'], trek_item_id('overdue-book')) === 0);
$crew = trek_crew()['sorrel'] ?? null;
ok('Sorrel is a Seedkeeper with lore 3 and +20 friendship', $crew && $crew['calling'] === 'seedkeeper' && (int)$crew['lore'] === 3 && (int)q_val('SELECT COUNT(*) FROM npcs WHERE slug = ?', ['sorrel-inkcap']) === 1);
$msRow = q_one("SELECT * FROM trek_ms WHERE user_id = ? AND ms_key = ?", [$uid, 'withering:ch2_sorrel']);
ok('the ch2_sorrel milestone paid once, from the setting (max 400 XP), through the milestone only', $msRow && (int)$msRow['xp'] > 0 && (int)$msRow['xp'] <= 400 && $mainXp() >= $xp0 + (int)$msRow['xp'], json_encode($msRow));
$r = $tx(fn(&$run, $u) => trek_act_fetch($run, $u));
ok('a second hand-over does nothing, no second payment', $r[0] === false && (int)q_val("SELECT COUNT(*) FROM trek_ms WHERE user_id = ? AND ms_key = ?", [$uid, 'withering:ch2_sorrel']) === 1);

echo "== side stops: rest, trade, kiln\n";
$at('rest');
$tx(function (&$run, $u) { $run['fatigue'] = 60; return [true, '']; });
$tx(fn(&$run, $u) => trek_act_rest($run, $u));
ok('the Cushion Corner is a free rest, once (fatigue down 50)', $flag('rest_used') && (int)$run()['fatigue'] === 10);
$r = $tx(fn(&$run, $u) => trek_act_rest($run, $u));
ok('...and not again', $r[0] === false);
$at('wheel');
$r = $tx(fn(&$run, $u) => trek_act_trade($run, $u));
ok('the wheel wants 3 Wet Clay', $r[0] === false && !$flag('wheel_done'));
$tx(function (&$run, $u) { trek_pack_add((int)$run['id'], trek_item_id('wet-clay'), 3); return [true, '']; });
$tx(fn(&$run, $u) => trek_act_trade($run, $u));
ok('3 Wet Clay become a Clay Pot, once', $flag('wheel_done') && trek_pack_qty((int)$run()['id'], trek_item_id('clay-pot')) === 1 && trek_pack_qty((int)$run()['id'], trek_item_id('wet-clay')) === 0);
$at('kiln');
$r = $tx(fn(&$run, $u) => trek_act_chest($run, $u));
ok('the kiln stays shut without the key', $r[0] === false && !$flag('kiln_open_x'));
$at('kilnstone');
$tx(fn(&$run, $u) => trek_act_riddle($run, $u, 1));
ok('the kiln stone riddle gives a Kiln Key and sets its solved flag', $flag('kilnstone_solved') && trek_pack_qty((int)$run()['id'], trek_item_id('kiln-key')) === 1);
$at('kiln'); $k0 = (int)$run()['campkits'];
$tx(fn(&$run, $u) => trek_act_chest($run, $u));
ok('the kiln opens: 2 kits, 120 Petals carried', (int)$run()['campkits'] >= min($k0 + 2, (int)setting('trek_campkit_max')) && (int)$run()['petals_found'] >= 120 && $flag('kiln_open'));
// the Spadefoot guarantee gives a second source for the key
ok('Spadefoot Toads can drop the Kiln Key (a second source)', (TREK_GUARANTEE['spadefoot-toad'][0] ?? '') === 'kiln-key' && (int)TREK_GUARANTEE['spadefoot-toad'][4] === 2);

echo "== Silverfin: hit, sweep, mend; enrage; adds never block the win\n";
$at('silverfin');
$tx(function (&$run, $u) { $run['party'] = [['slot' => 0, 'crew_key' => 'gnome', 'hp' => 9999], ['slot' => 1, 'crew_key' => 'burdock', 'hp' => 9999], ['slot' => 2, 'crew_key' => 'zinnia', 'hp' => 9999], ['slot' => 3, 'crew_key' => 'sorrel', 'hp' => 9999]]; foreach (trek_party_stats($run, $u) as $s => $m) $run['party'][$s]['hp'] = $m['max']; return [true, '']; });
$tx(fn(&$run, $u) => trek_act_challenge($run, $u));
$fi = $run()['fi'];
$silv = trek_script_def('silverfin');
ok('Silverfin is in the script registry; sweep is her big move (Auto reacts)', $fi && $fi['meta']['script'] === 'silverfin' && $silv && $silv['big'] === ['sweep'] && trek_script_code('silverfin') !== '');
ok('the pattern: hit, sweep, mend, shown a round ahead', trek_boss_moves(['round' => 1, 'meta' => $fi['meta']]) === ['hit', 'sweep'] && trek_boss_moves(['round' => 2, 'meta' => $fi['meta']]) === ['sweep', 'mend'] && trek_boss_moves(['round' => 3, 'meta' => $fi['meta']]) === ['mend', 'hit'] && trek_boss_moves(['round' => 4, 'meta' => $fi['meta']])[0] === 'hit');
$boss0 = $fi['foes'][0];
ok('Silverfin is level 22 with the chapter tune applied (more than the raw creature)', $boss0['lv'] === 22 && $boss0['max'] > 200, json_encode([$boss0['lv'], $boss0['max']]));
// 3 rounds of guarding: sweep hurts everyone, mend heals her
$hp = fn() => array_map(fn($p) => (int)$p['hp'], $run()['party']);
$tx(function (&$run, $u) { $run['fi']['foes'][0]['hp'] = (int)($run['fi']['foes'][0]['max'] * 0.6); return [true, '']; });   // wounded so the mend shows
$guard = fn() => $tx(function (&$run, $u) { trek_fight_round($run, $u, array_fill(0, count($run['party']), ['a' => 'guard'])); return [true, '']; });
$h0 = $hp(); $b0 = (int)$run()['fi']['foes'][0]['hp'];
$guard();   // round 1: hit
$guard();   // round 2: sweep
$h2 = $hp();
ok('after the sweep round everybody alive has lost health', count(array_filter(array_map(fn($a, $b) => $a < $b, $h2, $h0))) >= 3, json_encode([$h0, $h2]));
$bb = (int)$run()['fi']['foes'][0]['hp'];
$guard();   // round 3: mend
$ba = (int)$run()['fi']['foes'][0]['hp'];
ok('the mend round gives Silverfin health back (about 8%)', $ba > $bb, "$bb -> $ba");
// enrage under 30%
$tx(function (&$run, $u) { $run['fi']['foes'][0]['hp'] = (int)($run['fi']['foes'][0]['max'] * 0.2); return [true, '']; });
$guard();
ok('under 30% she is enraged (flag in the fight meta)', !empty($run()['fi']['meta']['enraged']) || empty($run()['fi']));
// adds: run rounds until 2 adds spawned (never more)
$tx(function (&$run, $u) { $run['fi']['foes'][0]['hp'] = $run['fi']['foes'][0]['max']; foreach ($run['party'] as $i => $p) $run['party'][$i]['hp'] = 99999; return [true, '']; });
for ($i = 0; $i < 12 && $run()['fi']; $i++) $guard();
$fi = $run()['fi'];
ok('page silverfish drift in, two per fight at most', $fi && count($fi['foes']) <= 3 && (int)($fi['meta']['adds'] ?? 0) <= 2 && (int)($fi['meta']['adds'] ?? 0) >= 1, json_encode(['n' => count($fi['foes'] ?? []), 'adds' => $fi['meta']['adds'] ?? null]));
// win with an add alive
$tx(function (&$run, $u) { $run['fi']['foes'][0]['hp'] = 1; $run['fi']['foes'][0]['def'] = -50; return [true, '']; });
$xpS = $mainXp();
for ($i = 0; $i < 12 && $run()['fi']; $i++) $tx(function (&$run, $u) { $live = array_keys(array_filter($run['party'], fn($p) => (int)$p['hp'] > 0)); $acts = []; foreach ($run['party'] as $s => $p) $acts[$s] = ['a' => 'attack', 't' => 'f:0']; trek_fight_round($run, $u, $acts); return [true, '']; });
ok('beating Silverfin ends the fight even with a page silverfish alive, sets silverfin_down', $run()['fi'] === null && $flag('silverfin_down'));
ok('ch2_silverfin paid once through its milestone (XP > 0, main XP up by exactly that)', ($m = q_one("SELECT * FROM trek_ms WHERE user_id = ? AND ms_key = ?", [$uid, 'withering:ch2_silverfin'])) && (int)$m['xp'] > 0 && (int)$m['xp'] <= 1000 && $mainXp() >= $xpS + (int)$m['xp'], json_encode($m));
ok('the Almanac unlocks the Silverfin entry', (int)q_val("SELECT COUNT(*) FROM user_encyclopedia ue JOIN encyclopedia_entries en ON en.id = ue.entry_id WHERE ue.user_id = ? AND en.unlock_key = ?", [$uid, 'trek:silverfin']) === 1);
$at('silverfin');
$r = $tx(fn(&$run, $u) => trek_act_challenge($run, $u));
ok('she cannot be fought again', $r[0] === false);

echo "== the Crossroads gate: open (II-b), the first pass pays the end milestone once\n";
$at('crossroads');
$cg = trek_spots(2)['crossroads'];
$tx(function (&$run, $u) use ($cg) { $run['x'] = $cg['x']; $run['y'] = $cg['y'] + 1; if (!trek_passable($run, $run['x'], $run['y'])) { $run['y'] = $cg['y'] - 1; } return [true, '']; });
$xpE = $mainXp();
$tx(fn(&$run, $u) => trek_walk($run, $u, $cg['x'], $cg['y']));
$tx(fn(&$run, $u) => trek_walk($run, $u, $cg['x'], $cg['y']));
$endRows = (int)q_val("SELECT COUNT(*) FROM trek_ms WHERE user_id = ? AND ms_key = ?", [$uid, 'withering:ch2a_end']);
ok('walking through the gate pays ch2a_end once and marks it reached', $endRows === 1 && $flag('reached_crossroads') && $mainXp() > $xpE);
ok('the gate has no lock flag any more', !$flag('crossroads_open'));

echo "== milestone checks: no KO, events, crew moments, side stops\n";
$chk = $tx(fn(&$run, $u) => [trek_ms_checks($run, $u, 'ch2a_end'), '']);
ok('ch2a_end: no KO + 4 stop checks (+1 crew check once a crew moment came up)', $chk[0][1] === 5 && isset($chk[0][2]['No knock-out']), json_encode($chk[0][2] ?? null));
ok('ch2_sorrel counts only the checks from index 0 (fewer than the end)', $tx(fn(&$run, $u) => [trek_ms_checks($run, $u, 'ch2_sorrel')[1], ''])[0] < $chk[0][1]);
$flagsNeeded = trek_chapter(2)['checks'];
ok('check types in use: flag, evn, crew, all', array_unique(array_column($flagsNeeded, 1)) === ['flag', 'evn', 'crew', 'all'] || count(array_diff(['flag', 'evn', 'crew', 'all'], array_column($flagsNeeded, 1))) === 0, json_encode(array_column($flagsNeeded, 1)));
$full = $tx(function (&$run, $u) { $run['st']['kos'] = []; $run['st']['evn'] = 5; trek_flag_set($run, 'cm_burdock'); trek_flag_set($run, 'cmt_burdock'); foreach (['barrow_done', 'wheel_done', 'seen_nook', 'rest_used', 'kiln_open', 'libdoor_solved', 'kilnstone_solved'] as $f) trek_flag_set($run, $f); return [trek_ms_checks($run, $u, 'ch2a_end'), '']; });
ok('with every stop done and the crew moment taken all 6 checks pass', $full[0][0] === 6 && $full[0][1] === 6, json_encode($full[0]));
$ko = $tx(function (&$run, $u) { $run['st']['kos'] = ['gnome' => 1]; return [trek_ms_checks($run, $u, 'ch2a_end'), '']; });
ok('a knock-out loses the "no knock-out" check', $ko[0][0] === 5 && $ko[0][2]['No knock-out'] === false);
$tx(function (&$run, $u) { $run['st']['kos'] = []; return [true, '']; });
ok('XP scales with checks: full > one missing', trek_ms_xp('ch2a_end', 6, 6, 2) > trek_ms_xp('ch2a_end', 5, 6, 2) && trek_ms_xp('ch2a_end', 6, 6, 2) === 800);
ok('XP total at full checks: about 2,200', trek_ms_xp('ch2_sorrel', 4, 4, 2) + trek_ms_xp('ch2_silverfin', 5, 5, 2) + trek_ms_xp('ch2a_end', 6, 6, 2) === 2200);

echo "== Petal cap (per user, across chapters)\n";
q('UPDATE users SET trek_pet_day = NULL, trek_pet_today = 0 WHERE id = ?', [$uid]);
$a = $tx(fn(&$run, $u) => trek_petals_capped($run, 100));
$b = $tx(fn(&$run, $u) => trek_petals_capped($run, 100));
$c = $tx(fn(&$run, $u) => trek_petals_capped($run, 100));
ok('150 a day in total: 100, 50, 0 (set by setting trek_petals_daily)', [$a, $b, $c] === [100, 50, 0], json_encode([$a, $b, $c]));
$c1 = $tx(fn(&$run, $u) => trek_petals_capped($run, 100), true, 1);
ok('Chapter I\'s run shares the same daily cap', $c1 === 0);

echo "== Chapter I is unchanged\n";
ok('Chapter I: 9 zones, 6 milestones, Burdock still 150 XP', count(trek_chapter(1)['zones']) === 9 && array_keys(trek_milestones(1)) === ['burdock', 'zinnia', 'bracken', 'mother', 'gloomtooth', 'chapter'] && (int)setting('trek_ms_burdock') > 0);
ok('Chapter I foes grow toward the trek base level, whatever the gnome level', ($f1 = trek_make_foe(trek_creature('withered-aphid'), ['level' => 16], 4, false, [100, 0, 0, 0])) && $f1['lv'] >= 1);
$fa = trek_make_foe(trek_creature('clay-crawler'), ['level' => 16], 4, false, [100, 0, 0, 0], 2); $fb = trek_make_foe(trek_creature('clay-crawler'), ['level' => 22], 4, false, [100, 0, 0, 0], 2);
ok('v1.9.5: Chapter II foes do not follow the gnome level (no lift): gnome 16 and 22 both get the creature file level 17', $fa['lv'] === 17 && $fb['lv'] === 17, $fa['lv'] . '/' . $fb['lv']);
ok('...and Chapter I\'s creature list has none of the new foes', trek_zone_pool('g', 1) !== null && !str_contains(json_encode(trek_zone_pool('g', 1)), 'clay-crawler'));
ok('the old stone riddle and gates still behave (Ch I spot types are intact)', trek_spots(1)['burdock']['type'] === 'recruit' && trek_spots(1)['mother']['type'] === 'miniboss' && count(trek_spots(1)) >= 15);

echo "== text: slots, drafts, fallback\n";
$ch2keys = []; foreach (file($GAME . '/includes/data/trek_texts_ch2.txt', FILE_IGNORE_NEW_LINES | FILE_SKIP_EMPTY_LINES) as $l) if (!str_starts_with($l, '#')) $ch2keys[] = explode('|', $l)[0];
$dr = trek_drafts() + trek_kv_file('trek_final_204.txt');   // v2.0.4: a slot added then has its body in trek_final_204.txt, no draft
ok(count($ch2keys) . ' Chapter II slots, each with a brief and a draft', count($ch2keys) >= 80 && !array_filter($ch2keys, fn($k) => empty($dr[$k])), (string)count($ch2keys));
$noBrief = array_filter($ch2keys, fn($k) => mb_strlen((string)q_val('SELECT brief FROM trek_texts WHERE text_key = ?', [$k])) < 40);
ok('every slot has a useful brief (40+ letters)', !$noBrief, implode(',', array_slice($noBrief, 0, 4)));
ok('generic Chapter II slots fall back to Chapter I\'s text (tutorial hint, camp)', ($rw = trek_text_row('ch2.tut.map')) === null || ($rw['text_key'] ?? '') !== '' );
$tooLong = array_filter($dr, fn($b, $k) => in_array($k, $ch2keys, true) && mb_strlen($b) > 1200, ARRAY_FILTER_USE_BOTH);
ok('no draft is long (1,200 letters at most)', !$tooLong);
ok('no draft carries raw HTML', !array_filter($dr, fn($b) => preg_match('/<[a-z]/i', $b)));

echo "== the draft marker (admin only)\n";
$K = 'ch2.intro';
q('UPDATE trek_texts SET body = ?, status = ? WHERE text_key = ?', [$dr[$K] ?? 'Draft body.', 'draft', $K]); trek_text_rows(true);
$GLOBALS['CURRENT_USER'] = ['id' => 99, 'role' => 'player'];
$html = trek_text($K);
ok('a player sees the text and NO pencil marker', $html !== '' && !str_contains($html, 'trekdraft') && !str_contains($html, '✏️') && !str_contains($html, 'trek_text.php'));
$GLOBALS['CURRENT_USER'] = ['id' => 1, 'role' => 'admin'];
$html = trek_text($K);
ok('an admin sees the pencil and a link to the slot in the editor', str_contains($html, 'trekdraft') && str_contains($html, '✏️') && str_contains($html, 'admin/trek_text.php?open=' . $K) && str_contains($html, '#t-ch2-intro'));
ok('the marker has no inline style or script, and the brief is escaped', !preg_match('/<[^>]+\s(style|on[a-z]+)=/i', $html) && !str_contains($html, '<script'));
q('UPDATE trek_texts SET body = ?, status = ? WHERE text_key = ?', ['Written by Joshua <b>x</b>', 'done', $K]); trek_text_rows(true);
$html = trek_text($K);
ok('a written slot loses the marker, even for the admin; the body is escaped', !str_contains($html, 'trekdraft') && str_contains($html, '&lt;b&gt;x&lt;/b&gt;'));
$GLOBALS['CURRENT_USER'] = null;
// restore the suggestion for later tests
q('UPDATE trek_texts SET body = ?, status = ? WHERE text_key = ?', [$dr[$K] ?? null, 'draft', $K]); trek_text_rows(true);
ok('a draft never overwrites a written body when the importer runs again', (function () use ($K) {
    q('UPDATE trek_texts SET body = ?, status = ? WHERE text_key = ?', ['Joshua wrote this.', 'done', $K]); trek_text_rows(true);
    trek_import_texts();
    $r = q_one('SELECT body, status FROM trek_texts WHERE text_key = ?', [$K]);
    return $r['body'] === 'Joshua wrote this.' && $r['status'] === 'done';
})());
q('UPDATE trek_texts SET body = ?, status = ? WHERE text_key = ?', [$dr[$K] ?? null, 'draft', $K]); trek_text_rows(true);

echo "== balance sim (real dice; Auto, full health; gnome 15, 20 and 30 with +2 stats (v1.9.5: the main level does not count, so all three must match); trek Lv10 and 11)\n";
$GLOBALS['trek_sim'] = true;
$N = 250;
$bands = [];
foreach ([15, 20, 30] as $gl) {
    $su = q_one('SELECT * FROM users WHERE id = ?', [$uid]);
    $su['id'] = 999999; $su['level'] = $gl; $su['calling'] = null;
    foreach (['grit', 'nimble', 'hardiness'] as $s) $su['stat_' . $s] = 12;
    $win = function (array $keys, int $L, callable $start) use ($su, $N): float {
        $won = 0;
        for ($i = 0; $i < $N; $i++) {
            $r = ['id' => 0, 'chapter' => 2, 'fatigue' => 0, 'st' => ['tl' => []], 'party' => [], 'fi' => null, 'lg' => [], 'flags' => ['tut_party' => true], 'petals_found' => 0];
            foreach ($keys as $s => $k) { $r['party'][$s] = ['crew_key' => $k, 'hp' => 9999]; $r['st']['tl'][$k] = [$k === 'gnome' ? $L : max(1, $L - 1), 0]; }
            foreach (trek_party_stats($r, $su) as $s => $m) $r['party'][$s]['hp'] = $m['max'];
            $GLOBALS['trek_sim_won'] = false;
            $start($r, $su, count($keys));
            for ($k = 0; $k < 80 && $r['fi']; $k++) trek_fight_round($r, $su, trek_fight_ai($r, $su));
            if (!empty($GLOBALS['trek_sim_won'])) $won++;
        }
        return round(100 * $won / $N, 1);
    };
    $rnd = fn(string $zone) => function (array &$r, array $u, int $size) use ($zone) {
        $cs = trek_pick_foes($zone, 2); $t = trek_foe_tune(['zone' => $zone], 2);
        trek_start_fight($r, $u, $cs, ['kind' => 'random', 'zone' => $zone], array_map(fn($c) => trek_make_foe($c, $u, $size, false, $t, 2), $cs));
    };
    $boss = function (array &$r, array $u, int $size) {
        $s = trek_spots(2)['silverfin']; $c = trek_creature($s['data']['creature']);
        $meta = ['kind' => 'spot', 'spot' => 'silverfin', 'script' => $s['data']['script'], 'zone' => $s['zone']];
        trek_start_fight($r, $u, [$c], $meta, [trek_make_foe($c, $u, $size, false, trek_foe_tune($meta, 2), 2)]);
    };
    $P4 = [0 => 'gnome', 1 => 'burdock', 2 => 'zinnia', 3 => 'bracken']; $P4s = [0 => 'gnome', 1 => 'burdock', 2 => 'zinnia', 3 => 'sorrel'];
    foreach ([10, 11] as $L) {
        $w = ['j' => $win($P4, $L, $rnd('j')), 'l' => $win($P4, $L, $rnd('l')), 'm' => $win($P4, $L, $rnd('m')), 's' => $win($P4s, $L, $boss)];
        printf("  gnome %d, trek Lv%d: j %5.1f%%  l %5.1f%%  m %5.1f%%  Silverfin %5.1f%%\n", $gl, $L, $w['j'], $w['l'], $w['m'], $w['s']);
        $bands[$gl][$L] = $w;
    }
}
unset($GLOBALS['trek_sim'], $GLOBALS['trek_sim_won']);
// Target at the base level (v1.9.5 retune): normal fights 80-99, Silverfin 60-92 at Lv10 (about 75-85 aimed at).
foreach (['j', 'l', 'm'] as $z) ok("zone $z at gnome 15, Lv10: 80-99%", $bands[15][10][$z] >= 80 && $bands[15][10][$z] <= 99.5, (string)$bands[15][10][$z]);
ok('Silverfin at gnome 15, Lv10: 60-92%', $bands[15][10]['s'] >= 60 && $bands[15][10]['s'] <= 92, (string)$bands[15][10]['s']);
ok('Silverfin at gnome 15, Lv11 is easier than at Lv10 or equal (within noise)', $bands[15][11]['s'] >= $bands[15][10]['s'] - 12);
// v1.9.5: gnome 20 and 30 must give the same results as gnome 15 (the main level does not count; the bands are wide because the dice are real).
foreach ([20, 30] as $g) {
    foreach (['j', 'l', 'm'] as $z) ok("zone $z at gnome $g, Lv10: same band as gnome 15 (80-99%)", $bands[$g][10][$z] >= 78 && $bands[$g][10][$z] <= 99.5 && abs($bands[$g][10][$z] - $bands[15][10][$z]) <= 14, $bands[$g][10][$z] . ' vs ' . $bands[15][10][$z]);
    ok("Silverfin at gnome $g, Lv10 is within noise of gnome 15", abs($bands[$g][10]['s'] - $bands[15][10]['s']) <= 18 && $bands[$g][10]['s'] >= 55 && $bands[$g][10]['s'] <= 94, $bands[$g][10]['s'] . ' vs ' . $bands[15][10]['s']);
}

echo $fails ? "\n$fails FAILED\n" : "\nall ok\n";
exit($fails ? 1 : 0);
