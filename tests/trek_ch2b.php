<?php
// Treks v1.9.4: Chapter II-b "Crossroads to the Drum" (data on the chapter engine, plus the engine's new hooks). Run on an installed copy: php tests/trek_ch2b.php GAME_DIR (treks.sh does).
// Map and reachability, loose clay (+) and the Wayfinder, the Signpost riddle, Tumble, Juniper, the Slide, camp-to-camp travel, the Cistern sluice and Old Pinch (starts at 80% when drained,
// grab/squeeze/Bark Skin), the Drum Door, Old Thrum (harden, crack, drum + cling, molt), the chapter finish and the interlude, the cold rest, text slots, and the balance sim (real dice: wide bands).
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
set_setting('trek_open', '1'); set_setting('trek_event_pct', '0'); set_setting('trek_enc_percent', '0'); set_setting('trek_petals_daily', '5000'); set_setting('trek_entry_energy', '10');
foreach (['trek_ms_ch2_sorrel' => 400, 'trek_ms_ch2_silverfin' => 1000, 'trek_ms_ch2a_end' => 800, 'trek_ms_ch2_tumble' => 250, 'trek_ms_ch2_juniper' => 300, 'trek_ms_ch2_pinch' => 600, 'trek_ms_ch2_thrum' => 650, 'trek_ms_ch2_chapter' => 400] as $k => $v) set_setting($k, (string)$v);
setting('__reload__');
q('UPDATE creature_drops SET chance = 0 WHERE 1 = 1');

echo "== data: zones, milestones, finish, creatures, map, spots\n";
$ch = trek_chapter(2);
ok('Chapter II has the six II-b zones n o p q r s after II-a\'s four', array_slice(array_keys($ch['zones']), 4) === ['n', 'o', 'p', 'q', 'r', 's'], json_encode(array_keys($ch['zones'])));
ok('the Hush is single + hint, the Dim is the dark style', !empty($ch['zones']['o']['single']) && !empty($ch['zones']['o']['hint']) && $ch['zones']['p']['style'] === 'd' && $ch['zones']['r']['style'] === 'u');
ok('II-b milestones: tumble 250, juniper 300, pinch 600, thrum 650, chapter 400', array_slice(array_keys(trek_milestones(2)), 3) === ['ch2_tumble', 'ch2_juniper', 'ch2_pinch', 'ch2_thrum', 'ch2_chapter']);
ok('the chapter finishes on thrum_down and pays the Drum-skin and the Brewhouse Ladle', ($ch['finish']['flag'] ?? '') === 'thrum_down' && ($ch['finish']['items'] ?? []) === ['drum-skin', 'brewhouse-ladle'] && ($ch['finish']['ms'] ?? []) === ['ch2_thrum', 'ch2_chapter']);
ok('still no Chapter III: the interlude says coming soon', !trek_chapter_exists(3) && trek_next_chapter(2) === null);
$cr = ['dimwing-moth' => 19, 'cistern-newt' => 20, 'drumming-cricket' => 21, 'old-pinch' => 23, 'old-thrum' => 24];
$bad = []; foreach ($cr as $s => $lv) { $c = trek_creature($s); if (!$c || (int)$c['level'] !== $lv) $bad[] = $s; if (!is_file($GAME . '/assets/img/ph/creature-' . $s . '.svg')) $bad[] = "$s.svg"; }
ok('five II-b creatures at levels 19, 20, 21, 23, 24, each with placeholder art', !$bad, implode(',', $bad));
ok('pools: n o p r s have fights, the Brewhouse (q) none', trek_zone_pool('n', 2) && trek_zone_pool('o', 2) && trek_zone_pool('p', 2) && trek_zone_pool('r', 2) && trek_zone_pool('s', 2) && (int)trek_zone_pool('q', 2)['mult'] === 0);
$map = trek_map(2); $sp = trek_spots(2);
ok('the map is 40 x 106 with 106 zone rows', $map['w'] === 40 && $map['h'] === 106 && count($map['z']) === 106);
$ii = array_filter($sp, fn($s) => $s['y'] >= 46);
ok('15 II-b spots, each symbol on its own tile, every one unique in the chapter', count($ii) === 15 && !array_filter($sp, fn($s) => trek_tile(2, $s['x'], $s['y']) !== $s['sym']) && count(array_unique(array_column($sp, 'sym'))) === count($sp), (string)count($ii));
$plus = []; for ($y = 0; $y < $map['h']; $y++) for ($x = 0; $x < $map['w']; $x++) if (trek_tile(2, $x, $y) === '+') $plus[] = [$x, $y];
ok('three loose clay tiles (+), one by each nook', count($plus) === 3, json_encode($plus));
ok('placed in the right zones (signpost n, slide o, rack p, juniper q, pinch r, thrum s)', $sp['signpost']['zone'] === 'n' && $sp['slide']['zone'] === 'o' && $sp['rack']['zone'] === 'p' && $sp['juniper']['zone'] === 'q' && $sp['pinch']['zone'] === 'r' && $sp['thrum']['zone'] === 's');

echo "== setup: finish Chapter I, go down\n";
foreach (['trek_flags', 'trek_pack', 'trek_party', 'trek_recruits'] as $t) q("DELETE FROM $t WHERE run_id IN (SELECT id FROM trek_runs WHERE user_id = ?)", [$uid]);
q('DELETE FROM trek_runs WHERE user_id = ?', [$uid]); q('DELETE FROM trek_ms WHERE user_id = ?', [$uid]);
q('UPDATE users SET level = 16, energy = 100, coins = 1000, calling = NULL, trek_ch = 1, trek_pet_day = NULL, trek_pet_today = 0 WHERE id = ?', [$uid]);
$tx(fn(&$run, $u) => trek_enter($run, $u), false);
$tx(function (&$run, $u) { foreach (['burdock', 'zinnia', 'bracken'] as $k) trek_recruit_crew($run, $u, $k); $run['st']['tl']['gnome'] = [10, 5]; trek_complete_chapter($run, $u); trek_hub_arrive($run, $u); return [true, '']; });
$r = $tx(fn(&$run, $u) => trek_godown($run, $u));
ok('Go down reaches Chapter II', $r[0] === true && trek_active_ch($uid) === 2);
$tx(function (&$run, $u) { $run['sn'] = str_repeat("\xff", strlen($run['sn'])); $run['campkits'] = 3; return [true, '']; });
$at = fn(string $code) => $tx(function (&$run, $u) use ($code) { $s = trek_spots(2)[$code]; $run['x'] = $s['x']; $run['y'] = $s['y']; $run['fatigue'] = 0; $run['fi'] = null; return [true, '']; });
$flag = fn(string $f) => !empty($run()['flags'][$f]);
$setFlag = fn(string $f) => $tx(function (&$run, $u) use ($f) { trek_flag_set($run, $f); return [true, '']; });
$clear = fn(array $fl) => $tx(function (&$run, $u) use ($fl) { foreach ($fl as $f) { q('DELETE FROM trek_flags WHERE run_id = ? AND flag = ?', [(int)$run['id'], $f]); unset($run['flags'][$f]); } return [true, '']; });
$pathLen = fn(string $code) => $tx(function (&$run, $u) use ($code) { trek_party_stats($run, $u); $s = trek_spots(2)[$code]; return [count(trek_path($run, $s['x'], $s['y'])), '']; })[0];
$party = function (array $keys) use ($tx, $run, $uid) {   // the party rows are written straight to the table (crew_key is only saved on insert), then full health
    $rid = (int)$run()['id']; q('DELETE FROM trek_party WHERE run_id = ? AND slot > 0', [$rid]);
    foreach (array_values($keys) as $i => $k) if ($i > 0) db_insert('trek_party', ['run_id' => $rid, 'slot' => $i, 'crew_key' => $k, 'hp' => 1]);
    $tx(function (&$run, $u) { foreach (trek_party_stats($run, $u) as $s => $m) $run['party'][$s]['hp'] = $m['max']; return [true, '']; });
};
$hpFull = fn() => $tx(function (&$run, $u) { foreach (trek_party_stats($run, $u) as $s => $m) $run['party'][$s]['hp'] = $m['max']; return [true, '']; });

echo "== the Crossroads gate: open, and II-b's first spots\n";
// II-a's gates and wheels open (a stand-in for having walked there)
$tx(function (&$run, $u) { foreach (['sluice1_done', 'drained_j', 'barrow_done', 'libdoor_open', 'libdoor_solved', 'sluice2_done', 'drained_l', 'freed_sorrel', 'silverfin_down', 'wheel_done', 'kilnstone_solved', 'kiln_open', 'rest_used'] as $f) trek_flag_set($run, $f); return [true, '']; });
$party(['gnome', 'burdock', 'zinnia', 'bracken']);
$at('crossroads');
$xp0 = $mainXp();
$tx(function (&$run, $u) { $s = trek_spots(2)['crossroads']; $run['x'] = $s['x']; $run['y'] = $s['y'] - 2; return [true, '']; });
$r = $tx(fn(&$run, $u) => trek_walk($run, $u, trek_spots(2)['signpost']['x'], trek_spots(2)['signpost']['y']));
ok('through the gate: the first pass pays ch2a_end once and sets reached_crossroads', $flag('reached_crossroads') && (int)q_val("SELECT COUNT(*) FROM trek_ms WHERE user_id = ? AND ms_key = ?", [$uid, 'withering:ch2a_end']) === 1 && $mainXp() > $xp0, json_encode($r));
$at('start');
ok('from the Seep Steps start, with the wheels turned, the Crossroads and the Signpost are reachable', $pathLen('signpost') > 0 && $pathLen('crossroads') > 0);

echo "== the Signpost riddle and Tumble\n";
$at('signpost');
$r = $tx(fn(&$run, $u) => trek_act_recruit($run, $u));
$at('tumble');
$r = $tx(fn(&$run, $u) => trek_act_recruit($run, $u));
ok('Tumble will not come until the Signpost is open (needs=sign_open)', $r[0] === false && !$flag('freed_tumble'));
$at('signpost');
$r = $tx(fn(&$run, $u) => trek_act_riddle($run, $u, 1)); $r = $tx(fn(&$run, $u) => trek_act_riddle($run, $u, 2));
ok('two wrong answers: still shut', !$flag('sign_open') && (int)($run()['st']['tries_signpost'] ?? 0) === 2);
$r = $tx(fn(&$run, $u) => trek_act_riddle($run, $u, 3));
ok('answer 3 (A signpost) solves it and opens it', $flag('sign_open') && $flag('sign_solved'));
$clear(['sign_open', 'sign_solved']); $tx(function (&$run, $u) { unset($run['st']['tries_signpost']); return [true, '']; });
foreach ([1, 2, 1] as $a) $tx(fn(&$run, $u) => trek_act_riddle($run, $u, $a));
ok('three wrong answers: the clay gives way (sign_open) but the riddle is NOT solved', $flag('sign_open') && !$flag('sign_solved'));
$clear(['sign_open', 'sign_solved']); $tx(function (&$run, $u) { unset($run['st']['tries_signpost']); return [true, '']; });
$party(['gnome', 'burdock', 'zinnia', 'bracken']); q('UPDATE users SET calling = ? WHERE id = ?', ['seedkeeper', $uid]);
$r = $tx(fn(&$run, $u) => trek_act_riddle($run, $u, 0, 'seed'));
ok('a Seedkeeper reads it: open and solved without tries', $flag('sign_open') && $flag('sign_solved'));
q('UPDATE users SET calling = NULL WHERE id = ?', [$uid]);
$at('tumble'); $xpT = $mainXp();
$r = $tx(fn(&$run, $u) => trek_act_recruit($run, $u));
ok('Tumble joins: recruit, flag, milestone, Almanac entry', $r[0] === true && $flag('freed_tumble') && in_array('tumble', trek_recruits((int)$run()['id']), true) && (int)q_val("SELECT COUNT(*) FROM trek_ms WHERE user_id = ? AND ms_key = ?", [$uid, 'withering:ch2_tumble']) === 1 && $mainXp() > $xpT);
ok('Tumble is a Wayfinder (the party can read loose clay)', (trek_crew()['tumble']['calling'] ?? '') === 'wayfinder');

echo "== loose clay (+) and the Wayfinder nooks\n";
$party(['gnome', 'burdock', 'zinnia', 'bracken']);
$tx(function (&$run, $u) { $s = trek_spots(2)['signpost']; $run['x'] = $s['x']; $run['y'] = $s['y']; return [true, '']; });
ok('without a Wayfinder the three nooks are out of reach', $pathLen('nookA') === 0 && $pathLen('nookB') === 0 && $pathLen('nookC') === 0);
$p0 = $plus[0];
$r = $tx(fn(&$run, $u) => trek_walk($run, $u, $p0[0], $p0[1]));
ok('tapping loose clay is refused with a hint (no steps)', $r[0] === false && str_contains((string)$r[1], 'loose'), json_encode($r));
$party(['gnome', 'burdock', 'zinnia', 'tumble']);
ok('with Tumble in the party the nooks open up', $pathLen('nookA') > 0 && $pathLen('nookB') > 0 && $pathLen('nookC') > 0, json_encode([$pathLen('nookA'), $pathLen('nookB'), $pathLen('nookC'), $run()['party']]));
$tx(function (&$run, $u) { $run['campkits'] = 0; return [true, '']; });
foreach (['nookA' => 'glowing-bead', 'nookB' => 'camp-kit', 'nookC' => ''] as $code => $item) {
    $at($code); $k0 = (int)$run()['campkits']; $pe0 = (int)$run()['petals_found'];
    $r = $tx(fn(&$run, $u) => trek_act_hidden($run, $u));
    ok("$code: taken once ($item)", $r[0] === true && $flag($sp[$code]['data']['flag']) && ($code !== 'nookB' || (int)$run()['campkits'] > $k0) && ($code !== 'nookC' || (int)$run()['petals_found'] > $pe0) && ($code !== 'nookA' || trek_pack_qty((int)$run()['id'], trek_item_id('glowing-bead')) >= 1));
}
$r = $tx(fn(&$run, $u) => trek_act_hidden($run, $u));
ok('a nook cannot be emptied twice', $r[0] === false);
$map2 = trek_art_svg(2, $run(), 8, 44, 24, 14, [], null, '');
ok('the map art draws the loose clay (SVG, no script)', str_starts_with($map2, '<svg') && !str_contains($map2, '<script'));

echo "== the Slide, the Dim and the Brewhouse\n";
$at('slide');
$r = $tx(fn(&$run, $u) => trek_act_slide($run, $u));
$bd = $sp['brewdoor'];
ok('the slide drops the party at the Brewhouse Door, sets slide_seen, costs a little fatigue', $r[0] === true && [$run()['x'], $run()['y']] === [$bd['x'], $bd['y']] && $flag('slide_seen') && (int)$run()['fatigue'] === 3, json_encode([$run()['x'], $run()['y'], $run()['fatigue']]));
$at('start'); $viaSlide = $pathLen('slide');
ok('the slide is part of a real route (reachable from the start)', $viaSlide > 0);
$at('rack');
$r = $tx(fn(&$run, $u) => trek_act_hidden($run, $u));
ok('the Cooling Rack gives one Clay Pot (carried)', $flag('rack_found') && trek_pack_qty((int)$run()['id'], trek_item_id('clay-pot')) === 1);
$at('juniper');
$r = $tx(fn(&$run, $u) => trek_act_fetch($run, $u));
ok('Juniper wants two pots: one is not enough', $r[0] === false && !$flag('freed_juniper'));
$tx(function (&$run, $u) { trek_pack_add((int)$run['id'], trek_item_id('clay-pot'), 1); return [true, '']; });
$xpJ = $mainXp();
$r = $tx(fn(&$run, $u) => trek_act_fetch($run, $u));
ok('two Clay Pots: Juniper joins, the pots are taken, milestone paid', $r[0] === true && $flag('freed_juniper') && trek_pack_qty((int)$run()['id'], trek_item_id('clay-pot')) === 0 && in_array('juniper', trek_recruits((int)$run()['id']), true) && $mainXp() > $xpJ);
$at('camp');
$tx(fn(&$run, $u) => trek_camp_arrive($run, $u, trek_spots(2)['camp']));
ok('the Brewhouse is not on the travel list before you have been there', array_keys(trek_travel_camps($run())) === ['camp']);
$at('camp2');
$tx(fn(&$run, $u) => trek_camp_arrive($run, $u, trek_spots(2)['camp2']));
ok('arriving at the Brewhouse sets camp2_seen and unlocks its Almanac page', $flag('camp2_seen') && (int)q_val("SELECT COUNT(*) FROM user_encyclopedia ue JOIN encyclopedia_entries en ON en.id = ue.entry_id WHERE ue.user_id = ? AND en.unlock_key = ?", [$uid, 'trek:brewhouse']) === 1);
ok('both camps are now on the travel list', array_keys(trek_travel_camps($run())) === ['camp', 'camp2']);
$f0 = (int)$run()['fatigue'];
$r = $tx(fn(&$run, $u) => trek_act_travel($run, $u, 'camp'));
ok('travel Brewhouse to Tin Lamp: arrive there, fatigue +12', $r[0] === true && [$run()['x'], $run()['y']] === [$sp['camp']['x'], $sp['camp']['y']] && (int)$run()['fatigue'] === $f0 + 12, json_encode([$r, $run()['x'], $run()['y'], $run()['fatigue']]));
$r = $tx(fn(&$run, $u) => trek_act_travel($run, $u, 'camp'));
ok('cannot travel to the camp you stand on, or to a bogus one', $r[0] === false && $tx(fn(&$run, $u) => trek_act_travel($run, $u, 'nonsense'))[0] === false);
$at('rack'); $r = $tx(fn(&$run, $u) => trek_act_travel($run, $u, 'camp2'));
ok('travel only works from a camp', $r[0] === false);
$r = $tx(fn(&$run, $u) => trek_act_travel($run, $u, 'camp2'), true);

echo "== the cold rest (no kit): fatigue is the limiter\n";
ok('setting trek_cold_rest_fatigue exists, default 25', (trek_settings()['trek_cold_rest_fatigue']['default'] ?? '') === '25' && trek_cold_rest_fatigue() === 25);
$at('slide');
$tx(function (&$run, $u) { $run['campkits'] = 0; $run['fatigue'] = 80; foreach (trek_party_stats($run, $u) as $s => $m) $run['party'][$s]['hp'] = 1; return [true, '']; });
$tx(fn(&$run, $u) => trek_make_camp($run, $u));
$h = $run()['party'][0]['hp']; $rr = $run(); $mx = trek_party_stats($rr, q_one('SELECT * FROM users WHERE id = ?', [$uid]))[0]['max'];
ok('a cold rest takes off 25 fatigue and heals a quarter', (int)$run()['fatigue'] === 55 && $h >= 1 + (int)floor($mx * 0.25) - 1 && $h < 1 + (int)ceil($mx * 0.4), json_encode([$run()['fatigue'], $h, $mx]));
$tx(function (&$run, $u) { $run['campkits'] = 2; $run['fatigue'] = 80; foreach (trek_party_stats($run, $u) as $s => $m) $run['party'][$s]['hp'] = 1; return [true, '']; });
$tx(fn(&$run, $u) => trek_make_camp($run, $u));
$h = $run()['party'][0]['hp'];
ok('a Camp Kit still takes off 50 and heals half', (int)$run()['fatigue'] === 30 && $h >= (int)floor($mx * 0.5) && (int)$run()['campkits'] === 1, json_encode([$run()['fatigue'], $h, $run()['campkits']]));

echo "== the Cistern: dry route, wheel shortcut, Old Pinch\n";
$party(['gnome', 'burdock', 'zinnia', 'juniper']);
$at('camp2');
$dry = $pathLen('pinch');
ok('Old Pinch is reachable on the dry (snake) route', $dry > 0);
$at('sluice3'); $tx(fn(&$run, $u) => trek_act_switch($run, $u));
ok('the Cistern Wheel drains r once', $flag('drained_r') && $flag('sluice3_done'));
$at('camp2'); $wet = $pathLen('pinch');
ok('draining opens a shortcut (the walk to Pinch is much shorter)', $wet > 0 && $wet < $dry - 15, "$wet vs $dry");
$sum = function (string $name) use ($run) { return $run()['fi'] ? (int)$run()['fi']['foes'][0][$name] : -1; };
$at('pinch'); $hpFull();
$tx(fn(&$run, $u) => trek_act_challenge($run, $u));
$fi = $run()['fi'];
ok('drained: Old Pinch starts at 80% health', $fi && (int)$fi['foes'][0]['hp'] === (int)ceil($fi['foes'][0]['max'] * 0.8) || ($fi && abs((int)$fi['foes'][0]['hp'] - (int)round($fi['foes'][0]['max'] * 0.8)) <= 1), json_encode([$fi['foes'][0]['hp'] ?? 0, $fi['foes'][0]['max'] ?? 0]));
$tx(function (&$run, $u) { $run['fi'] = null; return [true, '']; });
$clear(['drained_r']); $at('pinch'); $hpFull();
$tx(fn(&$run, $u) => trek_act_challenge($run, $u));
$fi = $run()['fi'];
ok('not drained: Old Pinch starts at full health', $fi && (int)$fi['foes'][0]['hp'] === (int)$fi['foes'][0]['max']);
ok('Old Pinch is in the script registry; squeeze is her big move', ($d = trek_script_def('pinch')) && $d['big'] === ['squeeze'] && ($fi['meta']['script'] ?? '') === 'pinch');
ok('pattern with nobody held: hit, grab, squeeze (after a grab), and round 3 shows a hit when nobody is held', trek_boss_moves(['round' => 1, 'meta' => ['script' => 'pinch']]) === ['hit', 'grab'] && trek_boss_moves(['round' => 2, 'meta' => ['script' => 'pinch']]) === ['grab', 'squeeze'] && trek_boss_moves(['round' => 3, 'meta' => ['script' => 'pinch']]) === ['hit', 'hit'], json_encode([trek_boss_moves(['round' => 2, 'meta' => ['script' => 'pinch']])]));
ok('pattern with someone held: the squeeze comes true', trek_boss_moves(['round' => 3, 'meta' => ['script' => 'pinch', 'held' => 1]]) === ['squeeze', 'hit']);
$tx(function (&$run, $u) { foreach ($run['party'] as $i => $p) $run['party'][$i]['hp'] = 99999; $run['fi']['foes'][0]['hp'] = $run['fi']['foes'][0]['max'] = 9999999; return [true, '']; });
$guard = fn() => $tx(function (&$run, $u) { trek_fight_round($run, $u, array_fill(0, count($run['party']), ['a' => 'guard'])); return [true, '']; });
$guard(); $guard();
$held = $run()['fi']['meta']['held'] ?? null;
ok('round 2: she grabs one of you (fight meta held)', $held !== null && isset($run()['party'][$held]));
$hp0 = (int)$run()['party'][$held]['hp'];
$guard();
ok('round 3: the squeeze lands on the one held, and the hold is over', empty($run()['fi']['meta']['held']) && (int)$run()['party'][$held]['hp'] < $hp0, json_encode([$hp0, $run()['party'][$held]['hp']]));
// Bark Skin breaks the grab
$tx(function (&$run, $u) { $run['fi'] = null; return [true, '']; });
q('UPDATE users SET calling = ? WHERE id = ?', ['rootwarden', $uid]);
$at('pinch'); $party(['gnome', 'burdock', 'zinnia', 'juniper']);
$tx(fn(&$run, $u) => trek_act_challenge($run, $u));
$tx(function (&$run, $u) { $run['fi']['foes'][0]['hp'] = $run['fi']['foes'][0]['max'] = 9999999; return [true, '']; });
$guard(); $guard();
$held = $run()['fi']['meta']['held'] ?? null;
$tx(function (&$run, $u) use ($held) { $acts = array_fill(0, count($run['party']), ['a' => 'guard']); $acts[0] = ['a' => 'ability', 't' => 'a:' . $held]; trek_fight_round($run, $u, $acts); return [true, '']; });
ok('Bark Skin on the held one breaks the grab before the squeeze (the Rootwarden gnome)', $held !== null && empty($run()['fi']['meta']['held']) && (int)$run()['fi']['mem'][$held]['bark'] > 0, json_encode($run()['fi']['meta']));
q('UPDATE users SET calling = NULL WHERE id = ?', [$uid]);
// the win: pearl, flag, Almanac, milestone
$tx(function (&$run, $u) { $run['fi']['foes'][0]['hp'] = 1; $run['fi']['foes'][0]['def'] = -50; return [true, '']; });
$xpP = $mainXp();
for ($i = 0; $i < 12 && $run()['fi']; $i++) $tx(function (&$run, $u) { $acts = []; foreach ($run['party'] as $s => $p) $acts[$s] = ['a' => 'attack', 't' => 'f:0']; trek_fight_round($run, $u, $acts); return [true, '']; });
ok('beating Pinch: the fight is over, pinch_down, the Cistern Pearl carried', $run()['fi'] === null && $flag('pinch_down') && trek_pack_qty((int)$run()['id'], trek_item_id('cistern-pearl')) === 1);
ok('ch2_pinch paid once through its milestone; Almanac page for Old Pinch', (int)q_val("SELECT COUNT(*) FROM trek_ms WHERE user_id = ? AND ms_key = ?", [$uid, 'withering:ch2_pinch']) === 1 && $mainXp() > $xpP && (int)q_val("SELECT COUNT(*) FROM user_encyclopedia ue JOIN encyclopedia_entries en ON en.id = ue.entry_id WHERE ue.user_id = ? AND en.unlock_key = ?", [$uid, 'trek:pinch']) === 1);
$at('pinch'); $r = $tx(fn(&$run, $u) => trek_act_challenge($run, $u));
ok('she cannot be fought again', $r[0] === false);

echo "== the Drum Door and the gate\n";
$dd = $sp['drumdoor']; $dg = $sp['drumgate'];
$tx(function (&$run, $u) use ($dd) { q('DELETE FROM trek_pack WHERE run_id = ?', [(int)$run['id']]); return [true, '']; });
$at('drumdoor'); $r = $tx(fn(&$run, $u) => trek_act_chest($run, $u));
ok('without the pearl the Drum Door stays shut', $r[0] === false && !$flag('drumdoor_open'));
$at('start');
ok('the Drum Chamber gate is not walkable until the door is open', !$tx(fn(&$run, $u) => [trek_passable($run, $dg['x'], $dg['y']), ''])[0]);
$tx(function (&$run, $u) { trek_pack_add((int)$run['id'], trek_item_id('cistern-pearl'), 1); return [true, '']; });
$at('drumdoor'); $k0 = (int)$run()['campkits'];
$r = $tx(fn(&$run, $u) => trek_act_chest($run, $u));
ok('with the Cistern Pearl: the door opens, a kit and Petals come out, the pearl is spent', $r[0] === true && $flag('drumdoor_open') && (int)$run()['campkits'] > $k0 && trek_pack_qty((int)$run()['id'], trek_item_id('cistern-pearl')) === 0);
ok('now the gate is walkable and Old Thrum is reachable from the Cistern side', $tx(fn(&$run, $u) => [trek_passable($run, $dg['x'], $dg['y']), ''])[0] && $pathLen('thrum') > 0);

echo "== Old Thrum: harden, crack, drum + cling, molt\n";
$party(['gnome', 'burdock', 'zinnia', 'juniper']); $at('thrum');
$tx(fn(&$run, $u) => trek_act_challenge($run, $u));
$fi = $run()['fi'];
ok('Old Thrum is in the registry (big move: hit), level 24 with the chapter tune', ($d = trek_script_def('thrum')) && $d['big'] === ['hit'] && $fi && $fi['foes'][0]['lv'] === 24, json_encode($fi['foes'][0]['lv'] ?? null));
$mv = fn(int $tp, array $meta = []) => trek_boss_moves(['round' => 1, 'meta' => ['script' => 'thrum', 'tp' => $tp] + $meta]);
ok('pattern: hit, drum, harden, crack (shown a round ahead); after a crack comes the stunned round', $mv(0) === ['hit', 'drum'] && $mv(1) === ['drum', 'harden'] && $mv(2) === ['harden', 'crack'] && $mv(3) === ['crack', 'stunned'] && $mv(4) === ['hit', 'drum']);
ok('molted: hit, crack, drum, still one action a round', $mv(0, ['molt' => 1]) === ['hit', 'crack'] && $mv(1, ['molt' => 1]) === ['crack', 'stunned'] && $mv(2, ['molt' => 1]) === ['drum', 'hit']);
$tx(function (&$run, $u) { foreach ($run['party'] as $i => $p) $run['party'][$i]['hp'] = 99999; $run['fi']['foes'][0]['hp'] = $run['fi']['foes'][0]['max'] = 9999999; return [true, '']; });
$guard();   // round 1: hit
$guard();   // round 2: drum
ok('after a drum round the cling flag is cleared and he moved on (tp 2)', (int)$run()['fi']['meta']['tp'] === 2 && empty($run()['fi']['meta']['cling']));
$guard();   // round 3: harden
ok('after harden: his damage taken is halved for the next party round (dm 50)', (int)($run()['fi']['foes'][0]['dm'] ?? 0) === 50);
$guard();   // round 4: crack
ok('after crack: +50% damage to him (dm 150) and he is stunned', (int)($run()['fi']['foes'][0]['dm'] ?? 0) === 150 && !empty($run()['fi']['meta']['stun']));
$guard();   // round 5: stunned, no action
ok('the stunned round: no action, the pattern does not advance, the bonus is over', empty($run()['fi']['meta']['stun']) && (int)$run()['fi']['meta']['tp'] === 4 && empty($run()['fi']['foes'][0]['dm']));
// the damage multiplier itself
$tx(function (&$run, $u) { $run['fi']['foes'][0]['dm'] = 50; return [true, '']; });
$dmgOf = function (int $dm) { $fi = ['foes' => [['hp' => 5000, 'max' => 5000] + ($dm ? ['dm' => $dm] : [])], 'meta' => []]; trek_hurt_foe($fi, 0, 1000); return 5000 - $fi['foes'][0]['hp']; };
$d50 = $dmgOf(50); $d100 = $dmgOf(0); $d150 = $dmgOf(150);
ok('trek_hurt_foe: dm 50 = half, dm 150 = +50% of the plain hit', $d100 > 0 && abs($d50 - $d100 * 0.5) <= 1 && abs($d150 - $d100 * 1.5) <= 1, json_encode([$d50, $d100, $d150]));
// cling: after a drum a tired ability stays tired a round longer
$tx(function (&$run, $u) { $run['fi']['meta']['tp'] = 1; $run['fi']['meta']['cling'] = 0; unset($run['fi']['meta']['stun']); $run['fi']['mem'][1]['cd'] = 3; $run['fi']['mem'][2]['cd'] = 0; return [true, '']; });
$guard();   // tp 1 = drum
$m1 = (int)$run()['fi']['mem'][1]['cd']; $m2 = (int)$run()['fi']['mem'][2]['cd'];
ok('Cling: the drum round leaves a tired ability at 3 (+1 for the beat, -1 for the round), an idle one at 0', $m1 === 3 && $m2 === 0, json_encode([$m1, $m2]));
// the molt at 30%
$tx(function (&$run, $u) { $run['fi']['foes'][0]['hp'] = (int)floor($run['fi']['foes'][0]['max'] * 0.25); $run['fi']['meta']['tp'] = 0; unset($run['fi']['meta']['stun']); return [true, '']; });
$guard();
ok('under 30% he molts: molt flag, pattern restarts, and he is not stunned', !empty($run()['fi']['meta']['molt']) && (int)$run()['fi']['meta']['tp'] === 0 && empty($run()['fi']['meta']['stun']));
ok('molted pattern shows hit then crack', trek_boss_moves($run()['fi']) === ['hit', 'crack']);
// win: finish, interlude
$tx(function (&$run, $u) { $run['fi']['foes'][0]['hp'] = 1; $run['fi']['foes'][0]['def'] = -50; return [true, '']; });
$xpTh = $mainXp(); $coins0 = (int)q_val('SELECT coins FROM users WHERE id = ?', [$uid]);
for ($i = 0; $i < 12 && $run()['fi']; $i++) $tx(function (&$run, $u) { $acts = []; foreach ($run['party'] as $s => $p) $acts[$s] = ['a' => 'attack', 't' => 'f:0']; trek_fight_round($run, $u, $acts); return [true, '']; });
$R = $run();
ok('beating Thrum ends the fight and finishes Chapter II', $R['fi'] === null && $flag('thrum_down') && trek_run_done($R) && trek_chapter_done($uid, 2) && $flag('ch2_done'));
ok('ch2_thrum and ch2_chapter are each paid once; XP went up', (int)q_val("SELECT COUNT(*) FROM trek_ms WHERE user_id = ? AND ms_key IN ('withering:ch2_thrum', 'withering:ch2_chapter')", [$uid]) === 2 && $mainXp() > $xpTh);
$rw = $R['st']['rewards'] ?? ['petals' => 0, 'items' => []];
ok('the finish paid the Petals setting and two items (Drum-skin, Brewhouse Ladle) once', (int)q_val('SELECT coins FROM users WHERE id = ?', [$uid]) - $coins0 === (int)setting('trek_ch2_petals') && (int)$rw['petals'] === (int)setting('trek_ch2_petals') && count($rw['items']) === 2, json_encode($rw));
ok('the Almanac unlocks Old Thrum and the Crossroads', (int)q_val("SELECT COUNT(*) FROM user_encyclopedia ue JOIN encyclopedia_entries en ON en.id = ue.entry_id WHERE ue.user_id = ? AND en.unlock_key IN ('trek:thrum', 'trek:crossroads')", [$uid]) === 2);
ok('the run is finished and waiting to be brought to the Hollow', trek_hub_pending($R));
$tx(function (&$run, $u) { trek_hub_arrive($run, $u); return [true, '']; });
ok('at the Shard Hollow after Chapter II: trek_ch stays 2, the run is outside', (int)q_val('SELECT trek_ch FROM users WHERE id = ?', [$uid]) === 2 && (int)$run()['inside'] === 0);

echo "== XP: the chapter totals 4,400 at full checks\n";
$full = 0;
foreach (['ch2_tumble', 'ch2_juniper', 'ch2_pinch', 'ch2_thrum', 'ch2_chapter'] as $k) $full += trek_ms_xp($k, 5, 5, 2);
ok('II-b alone is 2,200 XP at full checks', $full === 2200, (string)$full);
$all = 0; foreach (array_keys(trek_milestones(2)) as $k) $all += trek_ms_xp($k, 9, 9, 2);
ok('II-a + II-b = 4,400', $all === 4400, (string)$all);

echo "== text: every II-b slot has a brief and a draft; the code needs nothing else\n";
$keys = []; foreach (file($GAME . '/includes/data/trek_texts_ch2b.txt', FILE_IGNORE_NEW_LINES | FILE_SKIP_EMPTY_LINES) as $l) if (!str_starts_with($l, '#')) $keys[] = explode('|', $l)[0];
$dr = trek_drafts();
ok(count($keys) . ' II-b slots, each with a draft body', count($keys) >= 90 && !array_filter($keys, fn($k) => empty($dr[$k])), implode(',', array_filter($keys, fn($k) => empty($dr[$k]))));
$noBrief = array_filter($keys, fn($k) => mb_strlen((string)q_val('SELECT brief FROM trek_texts WHERE text_key = ?', [$k])) < 60);
$briefs = []; foreach (file($GAME . '/includes/data/trek_texts_ch2b.txt', FILE_IGNORE_NEW_LINES | FILE_SKIP_EMPTY_LINES) as $l) if (!str_starts_with($l, '#')) { $f = explode('|', $l, 5); $briefs[$f[0]] = $f[4] ?? ''; }
$badFmt = array_filter($briefs, fn($b) => !preg_match('/^Shows: .* • .*Mood: .* • Must cover: .* • Must not: .* • Length: /', $b));
ok('every brief is in the spec format (Shows, Mood, Must cover, Must not, Length), and is stored as bullets', !$noBrief && !$badFmt && str_starts_with((string)q_val("SELECT brief FROM trek_texts WHERE text_key = 'ch2.zone.n.arrive'"), '• Shows:'), implode(',', $noBrief) . ' / ' . implode(',', array_slice(array_keys($badFmt), 0, 3)));
ok('every II-b draft is a draft slot (status draft) and none runs over 1,200 letters; speech is 300 or less', !array_filter($keys, fn($k) => q_val('SELECT status FROM trek_texts WHERE text_key = ?', [$k]) !== 'draft' || mb_strlen($dr[$k]) > 1200) && !array_filter($keys, fn($k) => q_val('SELECT kind FROM trek_texts WHERE text_key = ?', [$k]) === 'speech' && mb_strlen($dr[$k]) > 300));
ok('no draft carries raw HTML', !array_filter($dr, fn($b) => preg_match('/<[a-z]/i', $b)));
// every key the code can ask for in II-b
$need = ['ch2.ui.loose', 'ch2.outro', 'ch2.hook', 'interlude.2.intro', 'ch2.zone.o.hint'];
foreach (['n', 'o', 'p', 'q', 'r', 's'] as $z) $need[] = "ch2.zone.$z.arrive";
foreach (['question', 'a1', 'a2', 'a3', 'right', 'wrong', 'out', 'seed', 'after'] as $p) $need[] = "ch2.spot.signpost.$p";
foreach (['before', 'locked', 'freed'] as $p) $need[] = "ch2.spot.tumble.$p";
foreach (['before', 'need', 'join'] as $p) $need[] = "ch2.spot.juniper.$p";
foreach (['nookA', 'nookB', 'nookC', 'rack'] as $c) { $need[] = "ch2.spot.$c.arrive"; $need[] = "ch2.spot.$c.find"; }
foreach (['before', 'done'] as $p) $need[] = "ch2.spot.slide.$p";
foreach (['before', 'done', 'after'] as $p) $need[] = "ch2.spot.sluice3.$p";
foreach (['intro', 'hit', 'grab', 'squeeze', 'break', 'defeat'] as $p) $need[] = "ch2.spot.pinch.$p";
foreach (['intro', 'hit', 'drum', 'harden', 'crack', 'molt', 'defeat'] as $p) $need[] = "ch2.spot.thrum.$p";
foreach (['locked', 'open', 'after'] as $p) $need[] = "ch2.spot.drumdoor.$p";
foreach (['locked', 'open'] as $p) $need[] = "ch2.spot.drumgate.$p";
$need[] = 'ch2.spot.brewdoor.arrive'; $need[] = 'ch2.spot.camp2.arrive';
foreach (['greet', 'shop', 'rest'] as $p) $need[] = "ch2.camp.cook.$p";
foreach (['tumble', 'juniper'] as $w) { $need[] = "ch2.banter.$w.1"; $need[] = "ch2.banter.$w.2"; $need[] = "ch2.crew.$w.talk"; $need[] = "ch2.crew.$w.done"; }
foreach (['burdock', 'zinnia', 'bracken', 'sorrel', 'tumble', 'juniper'] as $w) $need[] = "interlude.2.$w";
foreach (['echo' => ['text', 'whisper'], 'moth' => ['text', 'follow'], 'kettle' => ['text', 'sip'], 'drumbeat' => ['text', 'listen', 'miss']] as $e => $ps) foreach ($ps as $p) $need[] = "ch2.ev.$e.$p";
foreach (['ch2_tumble', 'ch2_juniper', 'ch2_pinch', 'ch2_thrum', 'ch2_chapter'] as $m) $need[] = "ch2.ms.$m";
foreach (['crossroads', 'brewhouse', 'pinch', 'thrum'] as $b) $need[] = "book.$b";
$missing = array_values(array_filter($need, fn($k) => !q_one('SELECT id FROM trek_texts WHERE text_key = ?', [$k])));
ok(count($need) . ' slots the II-b code asks for all exist', !$missing, implode(',', $missing));
$blank = array_values(array_filter($need, fn($k) => trim(trek_text($k)) === ''));
ok('trek_text shows something for each (the draft; players never see a blank)', !$blank, implode(',', $blank));

echo "== balance sim (real dice; Auto, full health; gnome 15, 20 and 30 with +2 stats (v1.9.5: the main level does not count, so all three must match); trek levels at the expected point: n 11, o 12, p 12, r 13, s 13, Pinch 13, Thrum 14)\n";
$GLOBALS['trek_sim'] = true;
$N = 200;
$bands = [];
$PA = [0 => 'gnome', 1 => 'burdock', 2 => 'zinnia', 3 => 'bracken']; $PD = [0 => 'gnome', 1 => 'burdock', 2 => 'zinnia', 3 => 'juniper']; $PN = [0 => 'gnome', 1 => 'burdock', 2 => 'bracken', 3 => 'juniper'];   // $PN: no healer
foreach ([15, 20, 30] as $gl) {
    $su = q_one('SELECT * FROM users WHERE id = ?', [$uid]);
    $su['id'] = 999999; $su['level'] = $gl; $su['calling'] = null;
    foreach (['grit', 'nimble', 'hardiness'] as $st) $su['stat_' . $st] = 12;
    $win = function (array $keys, int $L, callable $start) use ($su, $N): float {
        $won = 0;
        for ($i = 0; $i < $N; $i++) {
            $r = ['id' => 0, 'chapter' => 2, 'fatigue' => 0, 'st' => ['tl' => []], 'party' => [], 'fi' => null, 'lg' => [], 'flags' => ['tut_party' => true], 'petals_found' => 0];
            foreach ($keys as $sl => $k) { $r['party'][$sl] = ['crew_key' => $k, 'hp' => 9999]; $r['st']['tl'][$k] = [$k === 'gnome' ? $L : max(1, $L - 1), 0]; }
            foreach (trek_party_stats($r, $su) as $sl => $m) $r['party'][$sl]['hp'] = $m['max'];
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
    $boss = fn(string $spot, bool $drained = false) => function (array &$r, array $u, int $size) use ($spot, $drained) {
        $s = trek_spots(2)[$spot]; $c = trek_creature($s['data']['creature']);
        $meta = ['kind' => 'spot', 'spot' => $spot, 'script' => $s['data']['script'], 'zone' => $s['zone']];
        $f = trek_make_foe($c, $u, $size, false, trek_foe_tune($meta, 2), 2);
        if ($drained) $f['hp'] = (int)ceil($f['max'] * 0.8);
        trek_start_fight($r, $u, [$c], $meta, [$f]);
    };
    $w = ['n' => $win($PA, 11, $rnd('n')), 'o' => $win($PA, 12, $rnd('o')), 'p' => $win($PD, 12, $rnd('p')), 'r' => $win($PA, 13, $rnd('r')), 's' => $win($PD, 13, $rnd('s')),
          'thrum_nh' => $win($PN, 14, $boss('thrum')), 'pinch' => $win($PD, 13, $boss('pinch')), 'pinch80' => $win($PD, 13, $boss('pinch', true)), 'thrum' => $win($PD, 14, $boss('thrum'))];
    printf("  gnome %d: n %5.1f%%  o %5.1f%%  p %5.1f%%  r %5.1f%%  s %5.1f%%  | Old Pinch %5.1f%% (cistern drained, 80%% start: %5.1f%%)  Old Thrum %5.1f%% (no healer %5.1f%%)\n", $gl, $w['n'], $w['o'], $w['p'], $w['r'], $w['s'], $w['pinch'], $w['pinch80'], $w['thrum'], $w['thrum_nh']);
    $bands[$gl] = $w;
}
unset($GLOBALS['trek_sim'], $GLOBALS['trek_sim_won']);
foreach (['n', 'o', 'p', 'r', 's'] as $z) ok("zone $z at gnome 15: 78-98% (normal fights should be wins, not walks)", $bands[15][$z] >= 78 && $bands[15][$z] <= 98.5, (string)$bands[15][$z]);
ok('Old Pinch at gnome 15, trek Lv13: 64-95%', $bands[15]['pinch'] >= 64 && $bands[15]['pinch'] <= 95, (string)$bands[15]['pinch']);
ok('draining the cistern helps: Pinch from 80% wins more often', $bands[15]['pinch80'] >= $bands[15]['pinch'] - 3 && $bands[15]['pinch80'] >= 85, json_encode([$bands[15]['pinch80'], $bands[15]['pinch']]));
ok('Old Thrum at gnome 15, trek Lv14: 64-95%', $bands[15]['thrum'] >= 64 && $bands[15]['thrum'] <= 95, (string)$bands[15]['thrum']);
ok('Old Thrum with no healer (Zinnia out), trek Lv14: at least 50% (aimed at 60+) and the healer party stays under 94%', $bands[15]['thrum_nh'] >= 50 && $bands[15]['thrum'] <= 94, json_encode([$bands[15]['thrum_nh'], $bands[15]['thrum']]));
// v1.9.5: gnome 20 and 30 must give the same results as gnome 15 (the main level does not count; wide bands, real dice).
foreach ([20, 30] as $g) {
    foreach (['n', 'o', 'p', 'r', 's'] as $z) ok("zone $z at gnome $g: same band as gnome 15", $bands[$g][$z] >= 76 && $bands[$g][$z] <= 99 && abs($bands[$g][$z] - $bands[15][$z]) <= 16, $bands[$g][$z] . ' vs ' . $bands[15][$z]);
    foreach (['pinch', 'thrum', 'thrum_nh'] as $z) ok("$z at gnome $g within noise of gnome 15", abs($bands[$g][$z] - $bands[15][$z]) <= 18, $bands[$g][$z] . ' vs ' . $bands[15][$z]);
}

echo $fails ? "\n$fails FAILED\n" : "\nall ok\n";
exit($fails ? 1 : 0);
