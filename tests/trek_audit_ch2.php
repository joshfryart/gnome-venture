<?php
// Treks v1.9.8 audit of Chapter II "The Weeping Clay" (II-a + II-b): data consistency, entry/carry-over, a real end-to-end walk, soft-lock edge cases,
// milestones, text coverage (every key the code asks for exists, orphans listed), boss sims for several parties.
// Run on an installed copy: php tests/trek_audit_ch2.php GAME_DIR  (treks.sh does, after trek_ch2b.php).
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
set_setting('trek_ch2_petals', '500'); set_setting('trek_base_level', '15');
setting('__reload__');
q('UPDATE creature_drops SET chance = 0 WHERE 1 = 1');
$sp = trek_spots(2); $map = trek_map(2);

echo "== data consistency: spots, flags, objectives, milestones, checks\n";
$syms = []; for ($y = 0; $y < $map['h']; $y++) for ($x = 0; $x < $map['w']; $x++) { $c = trek_tile(2, $x, $y); if (ctype_upper($c) || ctype_digit($c)) $syms[$c] = ($syms[$c] ?? 0) + 1; }
$bySym = array_column($sp, 'code', 'sym');
ok('every capital letter / digit on the map is a spot of the chapter, and the other way round', !array_diff_key($syms, $bySym) && !array_diff_key($bySym, $syms) && !array_filter($syms, fn($n) => $n !== 1), json_encode([array_keys(array_diff_key($syms, $bySym)), array_keys(array_diff_key($bySym, $syms))]));
$zoneBad = array_filter($sp, fn($s) => trek_zone_at(2, $s['x'], $s['y']) !== $s['zone']);
ok('each spot\'s declared zone letter is the zone the map puts it in', !$zoneBad, json_encode(array_map(fn($s) => [$s['code'], $s['zone'], trek_zone_at(2, $s['x'], $s['y'])], array_values($zoneBad))));
$undef = 0; for ($y = 0; $y < $map['h']; $y++) for ($x = 0; $x < $map['w']; $x++) if (!in_array(trek_tile(2, $x, $y), ['#', '^', ' '], true) && !isset(trek_chapter(2)['zones'][trek_zone_at(2, $x, $y)])) $undef++;
ok('every tile that is not a wall has a defined zone letter', $undef === 0, (string)$undef);
$flags = []; $dupe = [];
foreach ($sp as $s) { $f = (string)($s['data']['flag'] ?? ''); if ($f === '') continue; if (isset($flags[$f])) $dupe[] = $f; $flags[$f] = $s['code']; }
ok('no two spots share a done-flag', !$dupe, implode(',', $dupe));
$objs = array_filter(array_map(fn($s) => isset($s['data']['obj']) ? (int)$s['data']['obj'] : null, $sp));
sort($objs);
ok('story objectives are 1..' . count($objs) . ' with no gaps or repeats', $objs === range(1, count($objs)), json_encode($objs));
// everything a spot "needs" is made by something
$made = array_keys($flags);
foreach ($sp as $s) { if ($s['type'] === 'switch') $made[] = 'drained_' . $s['zone']; if (!empty($s['data']['solved'])) $made[] = $s['data']['solved']; if ($s['type'] === 'gate' && !empty($s['data']['ms'])) $made[] = 'reached_' . $s['code']; }
$items = ['kiln-key', 'cistern-pearl', 'overdue-book', 'clay-pot', 'wet-clay'];
$badNeeds = [];
foreach ($sp as $s) { foreach (['needs', 'weak'] as $k) { $n = (string)($s['data'][$k] ?? ''); if ($n !== '' && !in_array($n, $made, true) && !in_array($n, $items, true)) $badNeeds[] = $s['code'] . ':' . $n; } }
ok('every needs= / weak= names a flag or item something produces', !$badNeeds, implode(',', $badNeeds));
$badTo = array_filter($sp, fn($s) => !empty($s['data']['to']) && !isset($sp[$s['data']['to']]));
ok('every slide target is a spot', !$badTo);
$msUsed = [];
foreach ($sp as $s) if (!empty($s['data']['ms'])) $msUsed[] = $s['data']['ms'];
$msUsed = array_merge($msUsed, ['ch2_silverfin', 'ch2_pinch'], trek_chapter(2)['finish']['ms']);   // the scripts' win handlers
sort($msUsed); $all = array_keys(trek_milestones(2)); sort($all);
ok('all ' . count($all) . ' Chapter II milestones have exactly one trigger (spot ms=, a boss win, or the finish)', $msUsed === $all, json_encode([$msUsed, $all]));
ok('milestone settings exist for each and total 4,400 at full checks', array_sum(array_map(fn($m) => trek_ms_xp($m, 9, 9, 2), $all)) === 4400);
$known = ['evn', 'crew', 'all', 'flag']; $cf = [];
foreach (trek_chapter(2)['checks'] as [$label, $type, $arg, $from]) {
    if (!in_array($type, $known, true) || $from < 0 || $from >= count($all)) $cf[] = "$label bad type/from";
    if (in_array($type, ['flag', 'all'], true)) foreach (explode(',', $arg) as $f) if (!in_array($f, $made, true) && !in_array($f, ['seen_nook'], true)) $cf[] = "$label: $f never set";
}
ok('every milestone check type is known and every flag it reads can be set', !$cf, implode('; ', $cf));
$fin = trek_chapter(2)['finish'];
ok('the finish row: flag thrum_down, Petals setting exists, both reward items exist, Almanac keys exist', $fin['flag'] === 'thrum_down' && setting($fin['petals']) !== null && !array_filter($fin['items'], fn($s) => !trek_item_id($s)) && !array_filter($fin['entries'], fn($k) => !q_val('SELECT 1 FROM encyclopedia_entries WHERE unlock_key = ?', [$k])), json_encode($fin));

echo "== reachability, in the intended order (the real trek_path with flags)\n";
q('UPDATE users SET level = 16, energy = 100, coins = 1000, calling = NULL, trek_ch = 1, trek_pet_day = NULL, trek_pet_today = 0 WHERE id = ?', [$uid]);
foreach (['trek_flags', 'trek_pack', 'trek_party', 'trek_recruits'] as $t) q("DELETE FROM $t WHERE run_id IN (SELECT id FROM trek_runs WHERE user_id = ?)", [$uid]);
q('DELETE FROM trek_runs WHERE user_id = ?', [$uid]); q('DELETE FROM trek_ms WHERE user_id = ?', [$uid]);
$tx(fn(&$run, $u) => trek_enter($run, $u), false);
$tx(function (&$run, $u) { foreach (['burdock', 'zinnia', 'bracken'] as $k) trek_recruit_crew($run, $u, $k); $run['st']['tl']['gnome'] = [10, 0]; trek_complete_chapter($run, $u); trek_hub_arrive($run, $u); return [true, '']; });
$r = $tx(fn(&$run, $u) => trek_godown($run, $u));
ok('setup: Chapter I done, gone down to Chapter II', $r[0] === true && trek_active_ch($uid) === 2);
$tx(function (&$run, $u) { $run['sn'] = str_repeat("\xff", strlen($run['sn'])); $run['campkits'] = 3; return [true, '']; });
$at = fn(string $code) => $tx(function (&$run, $u) use ($code) { $s = trek_spots(2)[$code]; $run['x'] = $s['x']; $run['y'] = $s['y']; $run['fatigue'] = 0; $run['fi'] = null; return [true, '']; });
$flag = fn(string $f) => !empty($run()['flags'][$f]);
$setFlag = fn(string $f) => $tx(function (&$run, $u) use ($f) { trek_flag_set($run, $f); return [true, '']; });
$clear = fn(array $fl) => $tx(function (&$run, $u) use ($fl) { foreach ($fl as $f) { q('DELETE FROM trek_flags WHERE run_id = ? AND flag = ?', [(int)$run['id'], $f]); unset($run['flags'][$f]); } return [true, '']; });
$reach = function () use ($tx, $sp) { return $tx(function (&$run, $u) use ($sp) { trek_party_stats($run, $u); $out = []; foreach ($sp as $c => $s) { if (trek_path($run, $s['x'], $s['y'])) $out[] = $c; } return [$out, '']; })[0]; };
$at('start');
$r0 = $reach();
ok('fresh: from the start only the Sinkhole Ledge area is reachable (start-side spots, the barrow, the wheel)', array_values(array_diff($r0, ['sluice1', 'barrow'])) === [], json_encode($r0));
$setFlag('drained_j'); $r1 = $reach();
ok('after the first sluice: the camp, the Library nook, rest, book and door plate; not past the door', in_array('camp', $r1, true) && in_array('libdoor', $r1, true) && in_array('book', $r1, true) && in_array('libgate', $r1, true) /* a locked gate counts as a goal */ && !in_array('sluice2', $r1, true) && !in_array('sorrel', $r1, true), json_encode($r1));
$setFlag('libdoor_open'); $r2 = $reach();
ok('door open: the Library sluice side is reachable, Sorrel and Silverfin are not (high water)', in_array('sluice2', $r2, true) && !in_array('sorrel', $r2, true) && !in_array('silverfin', $r2, true), json_encode(array_diff($r2, $r1)));
$setFlag('drained_l'); $r3 = $reach();
ok('Library drained: Sorrel and Silverfin reachable, the hatch is a goal, nothing past it', in_array('sorrel', $r3, true) && in_array('silverfin', $r3, true) && !in_array('wheel', $r3, true) && !in_array('crossroads', $r3, true), json_encode(array_diff($r3, $r2)));
$setFlag('silverfin_down'); $r4 = $reach();
ok('Silverfin down: Potter\'s Row, the Crossroads, the Brewhouse (on foot), the Cistern are reachable; Thrum is not', in_array('wheel', $r4, true) && in_array('crossroads', $r4, true) && in_array('camp2', $r4, true) && in_array('pinch', $r4, true) && in_array('drumdoor', $r4, true) && !in_array('thrum', $r4, true) && !in_array('nookA', $r4, true), json_encode(array_diff($r4, $r3)));
$setFlag('drumdoor_open'); $r5 = $reach();
ok('Drum Door open: Old Thrum is reachable', in_array('thrum', $r5, true));
// without ever draining the Cistern: still on foot
ok('without the Cistern Wheel Old Pinch and the Drum Door are still reachable (dry route)', in_array('pinch', $r4, true) && in_array('drumdoor', $r4, true) && !$flag('drained_r'));
$fresh = $tx(function (&$run, $u) { trek_party_stats($run, $u); $m = trek_map(2); $walk = 0; $iso = []; for ($y = 0; $y < $m['h']; $y++) for ($x = 0; $x < $m['w']; $x++) { $c = trek_tile(2, $x, $y); if (in_array($c, ['#', '^', ' ', '*', '+', 'w'], true)) continue; $walk++; if (!trek_path($run, $x, $y) && !($x === (int)$run['x'] && $y === (int)$run['y'])) $iso[] = $c; } return [[$walk, $iso], '']; })[0];
ok('with every gate and sluice open, every walkable tile is reachable except the three Wayfinder nooks: ' . $fresh[0] . ' tiles', $fresh[1] === ['A', 'D', '3'], json_encode($fresh[1]));
$tx(function (&$run, $u) { foreach (['drained_r', 'sluice3_done'] as $f) trek_flag_set($run, $f); return [true, '']; });
$wf = $tx(function (&$run, $u) { trek_party_stats($run, $u); $w0 = trek_has_wayfinder($run, $u); $run['wf'] = true; $n = 0; foreach (['nookA', 'nookB', 'nookC'] as $c) if (trek_path($run, trek_spots(2)[$c]['x'], trek_spots(2)[$c]['y'])) $n++; return [[$w0, $n], '']; })[0];
ok('the gnome without a calling and the Ch I trio are not Wayfinders; with one all three nooks open', $wf === [false, 3], json_encode($wf));
$clear(['drained_j', 'libdoor_open', 'drained_l', 'silverfin_down', 'drumdoor_open', 'drained_r', 'sluice3_done']);

echo "== a whole Chapter II on foot (real walks, real spot actions), collecting every text key the log asks for\n";
$asked = [];
$harvest = function () use (&$asked, $run) { $R = $run(); foreach (array_merge($R['lg'], (array)($R['st']['flog'] ?? [])) as $l) if (isset($l['k'])) $asked[$l['k']] = true; return $R; };
$T = function (callable $f) use ($tx, $harvest) { $r = $tx($f); $harvest(); return $r; };
$party = function (array $keys) use ($run, $tx) {
    $rid = (int)$run()['id']; q('DELETE FROM trek_party WHERE run_id = ? AND slot > 0', [$rid]);
    foreach (array_values($keys) as $i => $k) if ($i > 0) db_insert('trek_party', ['run_id' => $rid, 'slot' => $i, 'crew_key' => $k, 'hp' => 1]);
    $tx(function (&$run, $u) { foreach (trek_party_stats($run, $u) as $s => $m) $run['party'][$s]['hp'] = $m['max']; return [true, '']; });
};
$here = fn() => [$run()['x'], $run()['y']];
$goto = function (string $code, int $max = 40) use ($T, $run, $sp) {
    $s = $sp[$code]; $n = 0;
    while ($n++ < $max) {
        $R = $run(); if ((int)$R['x'] === $s['x'] && (int)$R['y'] === $s['y']) return true;
        if ($R['fi']) return false;
        $r = $T(function (&$run, $u) use ($s) { if ((int)$run['fatigue'] >= 90) { $run['campkits'] = 3; trek_make_camp($run, $u); } return trek_walk($run, $u, $s['x'], $s['y']); });
        if ($r[0] === false) return false;
    }
    return false;
};
$win = function (int $bossHp = 1) use ($T, $run) {   // finish the current fight: foe nearly dead
    $T(function (&$run, $u) use ($bossHp) { foreach ($run['fi']['foes'] as $i => $f) { $run['fi']['foes'][$i]['hp'] = min($f['hp'], $bossHp); $run['fi']['foes'][$i]['def'] = -50; } return [true, '']; });
    for ($i = 0; $i < 15 && $run()['fi']; $i++) $T(function (&$run, $u) { $acts = []; foreach ($run['party'] as $s => $p) $acts[$s] = ['a' => 'attack', 't' => '']; trek_fight_round($run, $u, $acts); return [true, '']; });
    return $run()['fi'] === null;
};
$give = fn(string $slug, int $n) => $T(function (&$run, $u) use ($slug, $n) { trek_pack_add((int)$run['id'], trek_item_id($slug), $n); return [true, '']; });
$act = fn(string $fn, ...$a) => $T(function (&$run, $u) use ($fn, $a) { return $fn($run, $u, ...$a); });
$pack = fn(string $slug) => trek_pack_qty((int)$run()['id'], trek_item_id($slug));
$tx(function (&$run, $u) { $s = trek_spots(2)['start']; $run['x'] = $s['x']; $run['y'] = $s['y']; $run['fatigue'] = 0; $run['fi'] = null; $run['sn'] = str_repeat("\0", strlen($run['sn'])); trek_seen_reveal($run, $s['x'], $s['y'], 3); foreach (['zone_j','zone_k','zone_l','zone_m','zone_n','zone_o','zone_p','zone_q','zone_r','zone_s'] as $f) q('DELETE FROM trek_flags WHERE run_id = ? AND flag = ?', [(int)$run['id'], $f]); return [true, '']; });
$clear(['zone_j', 'zone_k']);
// the fog: walking only works onto tiles you can see; make the next step visible the way the game does (lit tiles around you). Here: light a path as we go.
$lightAll = fn() => $tx(function (&$run, $u) { $run['sn'] = str_repeat("\xff", strlen($run['sn'])); return [true, '']; });
$lightAll();
$r = $goto('sluice1');
ok('walk: Sinkhole Ledge to the Sluice Wheel (the barrow is on the way and stops the walk, so more taps)', $r === true, json_encode($here()));
$r = $act('trek_act_switch');
ok('the wheel drains the Seep Steps water', $r[0] === true && $flag('drained_j'));
ok('walk: on to the Tin Lamp', $goto('camp') === true && $run()['camp'] === 'camp' && $flag('camp_seen'));
$party(['gnome', 'burdock', 'zinnia', 'bracken']);
ok('walk: to the Overdue Book, then pick it up', $goto('book') === true && ($r = $act('trek_act_hidden'))[0] === true && $pack('overdue-book') === 1);
ok('walk: to the door plate; one wrong answer, then the right one', $goto('libdoor') === true && $act('trek_act_riddle', 1)[0] === true && !$flag('libdoor_open') && $act('trek_act_riddle', 2)[0] === true && $flag('libdoor_open') && $flag('libdoor_solved'));
ok('walk: through the Library Door (open text once), to the Library sluice', $goto('libgate') === true && $goto('sluice2') === true && $act('trek_act_switch')[0] === true && $flag('drained_l'));
$xp0 = $mainXp();
ok('walk: to Sorrel, who takes the book and joins; milestone paid', $goto('sorrel') === true && $act('trek_act_fetch')[0] === true && $flag('freed_sorrel') && $pack('overdue-book') === 0 && $mainXp() > $xp0);
ok('walk: to Silverfin, face her, win', $goto('silverfin') === true && $act('trek_act_challenge')[0] === true && $win() && $flag('silverfin_down'));
ok('walk: through the hatch to Potter\'s Row and the Crossroads (first pass pays ch2a_end)', $goto('silvergate') === true && $goto('wheel') === true && $goto('crossroads') === true && $flag('reached_crossroads'));
ok('walk: to the Signpost, wrong answer ×2: the clay gives way (open, not solved)', $goto('signpost') === true && $act('trek_act_riddle', 1)[0] && $act('trek_act_riddle', 2)[0] && $flag('sign_open') && !$flag('sign_solved'));
ok('walk: Tumble joins', $goto('tumble') === true && $act('trek_act_recruit')[0] === true && $flag('freed_tumble'));
$party(['gnome', 'burdock', 'zinnia', 'tumble']);
ok('walk: Wayfinder nooks A, B, C open and can be emptied by walking there', $goto('nookA') === true && $act('trek_act_hidden')[0] && $goto('nookB') === true && $act('trek_act_hidden')[0] && $flag('nookA_found') && $flag('nookB_found'));
$party(['gnome', 'burdock', 'zinnia', 'bracken']); $at('signpost'); $lightAll();   // (the party can only be changed at a camp: a Wayfinder never gets locked inside a nook, so this test steps out)
ok('walk: the cooling rack (on foot, through the Dim) gives the second pot', $goto('rack') === true && $act('trek_act_hidden')[0] && $pack('clay-pot') === 1);
ok('walk: Brewhouse door, camp 2 (Almanac, travel list), Juniper', $goto('brewdoor') === true && $goto('camp2') === true && $flag('camp2_seen') && $goto('juniper') === true);
$r = $act('trek_act_fetch');
ok('Juniper with ONE pot (the wheel was skipped): refused, nothing taken, text shown', $r[0] === false && $pack('clay-pot') === 1 && !$flag('freed_juniper'));
// go back for the second pot: Brewhouse -> Tin Lamp by the tunnel (+12), walk to the wheel with 3 wet clay
$f0 = (int)$run()['fatigue'];
$r = $act('trek_act_travel', 'camp');
ok('travel Brewhouse -> Tin Lamp works from the Brewhouse camp tile (+12 fatigue, camp becomes the Tin Lamp)', $goto('camp2') === true && ($r = $act('trek_act_travel', 'camp'))[0] === true && $run()['camp'] === 'camp' && (int)$run()['fatigue'] >= 12, json_encode($r));
$r = $goto('wheel');
$r2 = $act('trek_act_trade');
ok('the wheel with no clay: refused, nothing happens', $r === true && $r2[0] === false && !$flag('wheel_done'));
$give('wet-clay', 2); $r2 = $act('trek_act_trade');
ok('the wheel with 2 wet clay: still refused (needs 3), clay kept', $r2[0] === false && $pack('wet-clay') === 2);
$give('wet-clay', 1); $xpW = (int)q_val('SELECT COUNT(*) FROM trek_ms WHERE user_id = ?', [$uid]);
$r2 = $act('trek_act_trade');
ok('3 wet clay -> 1 Clay Pot, wheel_done, clay used', $r2[0] === true && $pack('clay-pot') === 2 && $pack('wet-clay') === 0 && $flag('wheel_done'));
$r2 = $act('trek_act_trade'); $give('wet-clay', 3); $r3 = $act('trek_act_trade');
ok('the wheel works once only (a second try, even with clay, makes no second pot)', $r2[0] === false && $r3[0] === false && $pack('clay-pot') === 2);
$tx(function (&$run, $u) { q('DELETE FROM trek_pack WHERE run_id = ? AND item_id = ?', [(int)$run['id'], trek_item_id('wet-clay')]); return [true, '']; });
// a KO must not take the pots (quest items) and not send the party past a closed door
$tx(function (&$run, $u) { $run['petals_found'] = 100; trek_pack_add((int)$run['id'], trek_item_id('glowing-bead'), 4); return [true, '']; });
$T(function (&$run, $u) { trek_ko($run, $u); return [true, '']; });
ok('knocked out far from camp: back at the last camp (the Tin Lamp), the two Clay Pots are kept, ordinary finds may be lost', $here() === [$sp['camp']['x'], $sp['camp']['y']] && $pack('clay-pot') === 2 && (int)$run()['fatigue'] === 50);
$r = $goto('camp2');
ok('and from the Tin Lamp the party can walk back down to the Brewhouse on foot', $r === true, json_encode($here()));
$xpJ = $mainXp();
$r = $goto('juniper'); $r = $act('trek_act_fetch');
ok('Juniper with the two pots: joins, both pots taken, milestone paid', $r[0] === true && $pack('clay-pot') === 0 && $flag('freed_juniper') && $mainXp() > $xpJ);
$r = $goto('camp2'); $T(fn(&$run, $u) => trek_camp_arrive($run, $u, trek_spots(2)['camp2']));
$party(['gnome', 'burdock', 'zinnia', 'juniper']);
ok('walk: the Cistern wheel drains the water, Old Pinch is faced at 80%', $goto('sluice3') === true && $act('trek_act_switch')[0] && $flag('drained_r') && $goto('pinch') === true && $act('trek_act_challenge')[0] && abs((int)$run()['fi']['foes'][0]['hp'] - (int)round($run()['fi']['foes'][0]['max'] * 0.8)) <= 1);
$win();
ok('Old Pinch down: pearl carried, ch2_pinch paid', $flag('pinch_down') && $pack('cistern-pearl') === 1);
$r = $goto('drumgate');
ok('the Drum Chamber gate stops the party until the Drum Door is open', $r === false && !$flag('drumdoor_open'));
ok('walk: the Drum Door with the pearl, then through the gate to Old Thrum', $goto('drumdoor') === true && $act('trek_act_chest')[0] && $flag('drumdoor_open') && $pack('cistern-pearl') === 0 && $goto('drumgate') === true && $goto('thrum') === true);
$coins0 = (int)q_val('SELECT coins FROM users WHERE id = ?', [$uid]); $kits0 = 0;
ok('Old Thrum: face him, win -> the chapter ends', $act('trek_act_challenge')[0] && $win() && trek_run_done($run()) && $flag('ch2_done') && $flag('ch2_rewarded'));
$coins1 = (int)q_val('SELECT coins FROM users WHERE id = ?', [$uid]);
$R = $run();
ok('the finish paid the 500 Petals once (plus whatever the party banks at the hub)', $coins1 - $coins0 >= 500 && (int)($R['st']['rewards']['petals'] ?? 0) === 500 && count($R['st']['rewards']['items'] ?? []) === 2);
$T(function (&$run, $u) { trek_complete_chapter($run, $u); return [true, '']; });
$T(function (&$run, $u) { trek_complete_chapter($run, $u); return [true, '']; });
ok('finishing the chapter again (a replayed win, double tap) pays nothing more', (int)q_val('SELECT coins FROM users WHERE id = ?', [$uid]) === $coins1 && (int)q_val("SELECT COUNT(*) FROM trek_ms WHERE user_id = ? AND ms_key LIKE 'withering:ch2%'", [$uid]) === 8, (string)q_val("SELECT COUNT(*) FROM trek_ms WHERE user_id = ? AND ms_key LIKE 'withering:ch2%'", [$uid]));
$T(function (&$run, $u) { trek_hub_arrive($run, $u); return [true, '']; });
ok('hub: the party is outside, healed, rested; quest items stay in the closed run', (int)$run()['inside'] === 0 && (int)$run()['fatigue'] === 0 && trek_in_hub($run()));
$gd = $tx(fn(&$run, $u) => trek_godown($run, $u));
ok('no Chapter III: Go down refuses, spends no energy', $gd[0] === false && str_contains($gd[1], 'coming soon') && trek_active_ch($uid) === 2);
$paid = q('SELECT ms_key, xp, done, total FROM trek_ms WHERE user_id = ? ORDER BY paid_at, ms_key', [$uid])->fetchAll();
echo '  info milestones paid: ' . implode(', ', array_map(fn($m) => str_replace('withering:', '', $m['ms_key']) . ' ' . $m['xp'] . ' (' . $m['done'] . '/' . $m['total'] . ')', $paid)) . "\n";

echo "== text: every key Chapter II's code asks for exists and reads; slots nobody asks for are listed\n";
// the boss moves, played out for real (a huge party so the pattern runs its course): Silverfin, Pinch, Thrum
$bossRun = function (string $spotCode, int $rounds, ?callable $mid = null) use ($T, $tx, $run, $at, $party, $sp, $harvest) {
    $at($spotCode); $party(['gnome', 'burdock', 'zinnia', 'bracken']);
    $T(fn(&$run, $u) => trek_act_challenge($run, $u));
    $T(function (&$run, $u) { foreach ($run['party'] as $i => $p) $run['party'][$i]['hp'] = 99999; $run['fi']['foes'][0]['hp'] = $run['fi']['foes'][0]['max'] = 9999999; return [true, '']; });
    for ($i = 1; $i <= $rounds && $run()['fi']; $i++) {
        if ($mid) $mid($i);
        $T(function (&$run, $u) { trek_fight_round($run, $u, array_fill(0, count($run['party']), ['a' => 'guard'])); foreach ($run['party'] as $k => $p) $run['party'][$k]['hp'] = 99999; return [true, '']; });
    }
    return $run()['fi'] !== null;
};
$clear(['silverfin_down', 'pinch_down', 'thrum_down', 'ch2_done', 'ch2_rewarded']);
$tx(function (&$run, $u) { $run['finished'] = null; $run['inside'] = 1; return [true, '']; });
$setFlag('drumdoor_open');
foreach (['silverfin' => 10, 'pinch' => 7, 'thrum' => 10] as $code => $n) {
    $bossRun($code, $n);
    $T(function (&$run, $u) { $run['fi']['foes'][0]['hp'] = (int)floor($run['fi']['foes'][0]['max'] * 0.2); return [true, '']; });   // under 30%: Silverfin enrages, Thrum molts
    for ($i = 0; $i < 4 && $run()['fi']; $i++) $T(function (&$run, $u) { trek_fight_round($run, $u, array_fill(0, count($run['party']), ['a' => 'guard'])); foreach ($run['party'] as $k => $p) $run['party'][$k]['hp'] = 99999; return [true, '']; });
    $T(function (&$run, $u) { $run['fi'] = null; return [true, '']; });
}
$clear(['silverfin_down', 'pinch_down', 'thrum_down', 'ch2_done', 'ch2_rewarded', 'drumdoor_open']);
$tx(function (&$run, $u) { $run['inside'] = 0; return [true, '']; });
$asked['ch2.spot.pinch.break'] = true;   // Bark Skin on the held one: covered by tests/trek_ch2b.php
$asked['ch2.spot.silverfin.spawn'] = true;   // a page silverfish drifts in every 4th round: covered by tests/trek_ch2.php
$asked['ch2.spot.thrum.stunned'] = true;   // the stunned round also asks ch2.spot.thrum.stunned
// what the page asks for per spot type (trek.php trek_spot_panel(), read by hand; the HTTP admin check in treks.sh proves each is a real slot)
$panel = ['start' => ['arrive'], 'exit' => ['arrive'], 'camp' => ['arrive'], 'recruit' => ['locked', 'before', 'freed'], 'fetch' => ['before', 'need', 'join'], 'chest' => ['locked', 'open', 'after'], 'sign' => ['arrive'],
    'riddle' => ['question', 'a1', 'a2', 'a3', 'right', 'wrong', 'out', 'seed', 'after'], 'cart' => ['before', 'win', 'fail', 'work', 'after'], 'hidden' => ['arrive', 'find'], 'find' => ['arrive', 'find'],
    'slide' => ['before', 'done'], 'switch' => ['before', 'done', 'after'], 'rest' => ['before', 'done', 'after'], 'trade' => ['before', 'short', 'done', 'after'], 'boss' => ['intro'], 'miniboss' => ['intro'], 'gate' => ['locked', 'open']];
$expect = [];
foreach ($sp as $c => $s) {
    foreach ($panel[$s['type']] ?? [] as $p) {
        if ($p === 'locked' && $s['type'] === 'recruit' && empty($s['data']['needs'])) continue;
        if ($p === 'seed' && empty($s['data']['seedkeeper'])) continue;
        if ($p === 'after' && $s['type'] === 'riddle' && !isset(trek_text_rows()['ch2.spot.' . $c . '.after'])) continue;   // optional ("Solved." if missing)
        if ($p === 'locked' && $s['type'] === 'gate' && empty($s['data']['needs'])) continue;   // a gate that is never locked (the Crossroads, since II-b)
        if (in_array($p, ['a1', 'a2', 'a3', 'question', 'right', 'wrong', 'out'], true) && $s['type'] === 'riddle' && !empty($s['data']['failopen']) && $p === 'out') { /* still asked */ }
        $expect["ch2.spot.$c.$p"] = 'panel';
    }
}
foreach (trek_chapter(2)['zones'] as $z => $zi) { $expect["ch2.zone.$z.arrive"] = 'zone'; if (!empty($zi['hint'])) $expect["ch2.zone.$z.hint"] = 'zone'; }
foreach (array_keys(trek_milestones(2)) as $m) $expect["ch2.ms.$m"] = 'milestone';
foreach (['intro' => 'page', 'outro' => 'page', 'hook' => 'page'] as $p => $w) $expect["ch2.$p"] = $w;
$expect['interlude.2.intro'] = 'hub';
foreach (array_keys(trek_crew()) as $k) { $expect["interlude.2.$k"] = 'hub'; }
foreach (['burdock', 'zinnia', 'bracken', 'sorrel', 'tumble', 'juniper'] as $k) { $expect["ch2.crew.$k.talk"] = 'crew'; $expect["ch2.crew.$k.done"] = 'crew'; $expect["ch2.banter.$k.1"] = 'banter'; $expect["ch2.banter.$k.2"] = 'banter'; }
foreach (['pinch' => ['hit', 'grab', 'squeeze', 'break', 'defeat'], 'thrum' => ['hit', 'drum', 'harden', 'crack', 'stunned', 'molt', 'defeat'], 'silverfin' => ['hit', 'sweep', 'mend', 'enrage', 'spawn', 'defeat']] as $b => $ps) foreach ($ps as $p) $expect["ch2.spot.$b.$p"] = 'boss';
foreach (['handprints' => ['text', 'press', 'trace'], 'pot' => ['text', 'catch', 'miss'], 'echo' => ['text', 'whisper'], 'moth' => ['text', 'follow'], 'kettle' => ['text', 'sip'], 'drumbeat' => ['text', 'listen', 'miss']] as $e => $ps) foreach ($ps as $p) $expect["ch2.ev.$e.$p"] = 'event';
foreach (['ch2', 'claybound', 'silverfin', 'crossroads', 'brewhouse', 'pinch', 'thrum'] as $b) $expect["book.$b"] = 'book';
foreach (['greet', 'shop', 'rest'] as $p) { $expect["ch2.camp.innkeeper.$p"] = 'camp'; $expect["ch2.camp.cook.$p"] = 'camp'; }
$expect['ch2.ko.tutorial'] = 'ko'; unset($expect['ch2.spot.crossroads.open']);   // the Crossroads gate was never locked: no "it opens" line (v1.9.8 audit)
ok('the never-locked Crossroads gate says no "it opens" line when you walk through (the milestone card does)', !isset($asked['ch2.spot.crossroads.open'])); $expect['ch2.ui.loose'] = 'ui';
foreach (array_keys($asked) as $k) if (str_starts_with($k, 'ch2.') || str_starts_with($k, 'interlude.2.')) $expect[$k] = $expect[$k] ?? 'log';
$rows = trek_text_rows(true); $rows = trek_text_rows();
$missing = array_values(array_filter(array_keys($expect), fn($k) => trek_text_row($k) === null));   // (a generic key may fall back to Chapter I's slot)
foreach (['olddry.find', 'oldtent.find', 'oldbench.find'] as $p) $expect['ch2.spot.' . $p] = 'oldcamp'; foreach (['oldcamp.rest', 'oldcamp.ambush', 'ko.oldcamp'] as $p) $expect['ch2.' . $p] = 'oldcamp';   // v2.0.1: old campsites
ok(count($expect) . ' keys the Chapter II code can ask for: every one is a slot', !$missing, implode(', ', $missing));
$blank = array_values(array_filter(array_keys($expect), fn($k) => isset($rows[$k]) && trim(trek_text($k)) === ''));
ok('...and each of Chapter II\'s own slots reads something (draft or written) for a player', !$blank, implode(', ', $blank));
// keys the log asked for that are not Chapter II's own: they must fall back to Chapter I's and read something
$gen = array_values(array_filter(array_keys($asked), fn($k) => trek_text_row($k) === null));
ok('every key the played-out chapter put in the log has a slot (its own, or Chapter I\'s for the generic ones)', !$gen, implode(', ', $gen));
$fb = ['ch2.tut.walk', 'ch2.tut.party', 'ch2.tut.firstfight', 'ch2.tut.treklevel', 'ch2.ko.camp', 'ch2.ui.tired', 'ch2.ui.wornout', 'ch2.camp.makecamp', 'ch2.camp.makecamp.free', 'ch2.camp.ambush', 'ch2.camp.innkeeper.full', 'ch2.camp.innkeeper.nofunds', 'ch2.ev.walkon'];
foreach (['stash', 'forager', 'fork', 'trader', 'shrine', 'puddle', 'beetle', 'song'] as $e) $fb[] = "ch2.ev.$e.text";
echo '  info the generic Chapter II keys that fall back to Chapter I slots (unwritten there = nothing shown to players): ' . count(array_filter($fb, fn($k) => trim(trek_text($k)) === '')) . '/' . count($fb) . " are blank right now\n";
$orph = [];
foreach (q("SELECT text_key FROM trek_texts WHERE chapter = 2 ORDER BY sort_order")->fetchAll(PDO::FETCH_COLUMN) as $k) if (!isset($expect[$k])) $orph[] = $k;
echo '  info slots of Chapter II that no code path asks for (orphans): ' . ($orph ? implode(', ', $orph) : 'none') . "\n";
$KNOWN_ORPHANS = ['ch2.spot.crossroads.locked'];   // the Crossroads gate is open from II-b on (never locked)
ok('no unexpected orphan slots (known: ' . implode(', ', $KNOWN_ORPHANS) . ')', !array_diff($orph, $KNOWN_ORPHANS), implode(', ', array_diff($orph, $KNOWN_ORPHANS)));


echo "== entry, exits and soft-lock probes (a fresh Chapter II run)\n";
$fresh2 = function (int $energy = 100) use ($uid, $tx, $run) {
    foreach (['trek_flags', 'trek_pack', 'trek_party', 'trek_recruits'] as $t) q("DELETE FROM $t WHERE run_id IN (SELECT id FROM trek_runs WHERE user_id = ?)", [$uid]);
    q('DELETE FROM trek_runs WHERE user_id = ?', [$uid]);
    q('UPDATE users SET level = 16, energy = ?, coins = 1000, calling = NULL, trek_ch = 1, trek_pet_day = NULL, trek_pet_today = 0 WHERE id = ?', [$energy, $uid]);
    $tx(fn(&$run, $u) => trek_enter($run, $u), false);
    $tx(function (&$run, $u) { foreach (['burdock', 'zinnia', 'bracken'] as $k) trek_recruit_crew($run, $u, $k); $run['st']['tl']['gnome'] = [12, 0]; $run['st']['tac']['burdock'] = ['open' => 'guard']; $run['campkits'] = 2; return [true, '']; });
};
$fresh2();
$r = $tx(fn(&$run, $u) => trek_godown($run, $u));
ok('Go down refuses before Chapter I is finished (the run is not done)', $r[0] === false && trek_active_ch($uid) === 1 && !trek_run_row($uid, 2));
$tx(function (&$run, $u) { trek_complete_chapter($run, $u); trek_hub_arrive($run, $u); return [true, '']; });
q('UPDATE users SET energy = 4 WHERE id = ?', [$uid]);
$r = $tx(fn(&$run, $u) => trek_godown($run, $u));
ok('Go down with 4 energy (costs 10): refused, nothing changes, no Chapter II row, still in the Chapter I interlude', $r[0] === false && trek_active_ch($uid) === 1 && !trek_run_row($uid, 2) && (int)q_val('SELECT energy FROM users WHERE id = ?', [$uid]) === 4);
q('UPDATE users SET energy = 100 WHERE id = ?', [$uid]);
$tx(function (&$run, $u) { $r = trek_set_party($run, $u, [1 => 'zinnia']); return $r; });
$r = $tx(fn(&$run, $u) => trek_godown($run, $u));
$R2 = $run(); $R1 = $run(1);
ok('Go down: Chapter II run made, energy −10, the party carried (Zinnia in slot 1; Burdock and Bracken waiting), levels, tactics and kits too', $r[0] === true && (int)$R2['chapter'] === 2 && (int)q_val('SELECT energy FROM users WHERE id = ?', [$uid]) === 90 && ($R2['party'][1]['crew_key'] ?? '') === 'zinnia' && count($R2['party']) === 2 && count(trek_recruits((int)$R2['id'])) === 3 && $R2['st']['tl']['gnome'] === [12, 0] && ($R2['st']['tac']['burdock']['open'] ?? '') === 'guard' && (int)$R2['campkits'] === 2);
ok('the new run starts at the Sinkhole Ledge, inside, full health, no fatigue, no flags', [$R2['x'], $R2['y'], (int)$R2['inside'], (int)$R2['fatigue']] === [$sp['start']['x'], $sp['start']['y'], 1, 0] && !$R2['flags'] && $R2['party'][0]['hp'] === trek_party_stats($R2, q_one('SELECT * FROM users WHERE id = ?', [$uid]))[0]['max']);
ok('Chapter I\'s run is left read-only: still done, not inside, same flags and levels', trek_run_done($R1) && (int)$R1['inside'] === 0 && !empty($R1['flags']['ch1_done']));
ok('with the gnome in Chapter II nothing can act on the Chapter I run (the active chapter is 2): inside only counts Chapter II', trek_active_ch($uid) === 2 && trek_inside($uid));
// an Almanac page for the chapter is unlocked at the start
ok('the Chapter II Almanac page (trek:ch2) unlocks on arrival', (int)q_val("SELECT COUNT(*) FROM user_encyclopedia ue JOIN encyclopedia_entries en ON en.id = ue.entry_id WHERE ue.user_id = ? AND en.unlock_key = ?", [$uid, 'trek:ch2']) === 1);
// leave and come back
$tx(function (&$run, $u) { $s = trek_spots(2)['sluice1']; $run['x'] = $s['x']; $run['y'] = $s['y']; $run['sn'] = str_repeat("\xff", strlen($run['sn'])); trek_flag_set($run, 'sluice1_done'); trek_flag_set($run, 'drained_j'); return [true, '']; });
$r = $tx(fn(&$run, $u) => trek_leave($run));
$e0 = (int)q_val('SELECT energy FROM users WHERE id = ?', [$uid]); $pos = [$run()['x'], $run()['y']];
$r2 = $tx(fn(&$run, $u) => trek_enter($run, $u));
ok('leave mid-chapter, come back: same spot, flags and fog kept, one entry fee', $r[0] === true && $r2[0] === true && (int)$run()['inside'] === 1 && [$run()['x'], $run()['y']] === $pos && $flag('drained_j') && (int)q_val('SELECT energy FROM users WHERE id = ?', [$uid]) === $e0 - 10);
$r3 = $tx(fn(&$run, $u) => trek_enter($run, $u)); $e1 = (int)q_val('SELECT energy FROM users WHERE id = ?', [$uid]);
ok('"Enter" while already inside costs nothing', $r3[0] === true && $e1 === $e0 - 10);
$tx(function (&$run, $u) { $s = trek_spots(2)['start']; $run['x'] = $s['x']; $run['y'] = $s['y']; trek_start_random_fight($run, $u, 'j'); return [true, '']; });
$r = $tx(fn(&$run, $u) => trek_leave($run));
ok('cannot leave mid-fight', $r[0] === false && (int)$run()['inside'] === 1 && $run()['fi'] !== null);
$tx(function (&$run, $u) { $run['fi'] = null; return [true, '']; });
// KO before the first camp: the tutorial KO, nothing lost
$tx(function (&$run, $u) { $run['petals_found'] = 50; trek_pack_add((int)$run['id'], trek_item_id('glowing-bead'), 3); $s = trek_spots(2)['barrow']; $run['x'] = $s['x']; $run['y'] = $s['y']; $run['camp'] = null; $run['fatigue'] = 80; trek_ko($run, $u); return [true, '']; });
$R = $run();
ok('knocked out before the Tin Lamp: back at the Sinkhole Ledge, fatigue 50, Petals and finds all kept', [$R['x'], $R['y']] === [$sp['start']['x'], $sp['start']['y']] && (int)$R['fatigue'] === 50 && (int)$R['petals_found'] === 50 && trek_pack_qty((int)$R['id'], trek_item_id('glowing-bead')) === 3);
ok('...and the drained water stays drained (the way on is open from the start)', $flag('drained_j') && $tx(function (&$run, $u) { trek_party_stats($run, $u); return [trek_path($run, trek_spots(2)['camp']['x'], trek_spots(2)['camp']['y']) !== [], '']; })[0]);
// quest items: every item the chapter asks the player to find is a quest item (never banked, never lost to a knock-out)
$qi = [];
foreach ($sp as $s) { foreach (['need', 'needs'] as $k) { $v = explode(':', (string)($s['data'][$k] ?? ''))[0]; if ($v !== '' && trek_item_id($v) && !in_array($v, ['camp-kit'], true)) $qi[$v] = true; } if (!empty($s['data']['item'])) { $v = explode(':', $s['data']['item'])[0]; if (in_array($v, ['kiln-key', 'cistern-pearl', 'clay-pot', 'overdue-book', 'wet-clay'], true)) $qi[$v] = true; } }
$qi['cistern-pearl'] = true;
$notQuest = array_filter(array_keys($qi), fn($v) => !trek_is_quest_item(trek_item_id($v)));
ok('every item a spot needs (' . implode(', ', array_keys($qi)) . ') is a quest item: banking and knock-outs cannot take it', !$notQuest, implode(',', $notQuest));
$tx(function (&$run, $u) { foreach (['wet-clay', 'clay-pot', 'overdue-book', 'kiln-key', 'cistern-pearl'] as $s) trek_pack_add((int)$run['id'], trek_item_id($s), 2); trek_pack_add((int)$run['id'], trek_item_id('glowing-bead'), 40); $run['camp'] = 'camp'; trek_ko($run, $u); trek_bank($run, $u); return [true, '']; });
ok('knock-out then banking leaves all five quest items in the pack, untouched', (function () use ($pack) { foreach (['wet-clay', 'clay-pot', 'overdue-book', 'kiln-key', 'cistern-pearl'] as $s) if ($pack($s) !== 2) return false; return true; })());
// the riddle door in every combination
$at('libdoor'); $tx(function (&$run, $u) { foreach (['libdoor_open', 'libdoor_solved'] as $f) { q('DELETE FROM trek_flags WHERE run_id = ? AND flag = ?', [(int)$run['id'], $f]); unset($run['flags'][$f]); } unset($run['st']['tries_libdoor']); return [true, '']; });
$r = $act('trek_act_riddle', 1);
ok('door plate: one wrong answer leaves one try and the door shut', $flag('libdoor_open') === false && (int)$run()['st']['tries_libdoor'] === 1);
$party(['gnome', 'burdock', 'zinnia', 'sorrel']);
$r = $act('trek_act_riddle', 0, 'seed');
ok('...a Seedkeeper in the party can still open it after wrong tries (open and solved)', $r[0] === true && $flag('libdoor_open') && $flag('libdoor_solved'));
$r = $act('trek_act_riddle', 2); $r2 = $act('trek_act_riddle', 0, 'seed');
ok('...and once open it cannot be answered again (no second prize, no error)', $r[0] === false && $r2[0] === false);
$clear(['libdoor_open', 'libdoor_solved']); $tx(function (&$run, $u) { unset($run['st']['tries_libdoor']); return [true, '']; });
$party(['gnome', 'burdock', 'zinnia', 'bracken']);
$r = $act('trek_act_riddle', 0, 'seed');
ok('no Seedkeeper in the party: "read it the Seedkeeper\'s way" is refused', $r[0] === false && !$flag('libdoor_open'));
foreach ([1, 3] as $a) $act('trek_act_riddle', $a);
ok('door plate: two wrong answers — the clay gives way, the door is open, but NOT counted as solved (no check credit)', $flag('libdoor_open') && !$flag('libdoor_solved'));
$r = $act('trek_act_riddle', 2);
ok('...the next tap does nothing', $r[0] === false);
// the Kiln: key from the riddle or from three toad kills, and the chest takes it
$at('kilnstone'); $clear(['kilnstone_solved', 'kiln_open']); $tx(function (&$run, $u) { unset($run['st']['tries_kilnstone'], $run['st']['kills']); q('DELETE FROM trek_pack WHERE run_id = ?', [(int)$run['id']]); return [true, '']; });
foreach ([2, 3, 2] as $a) $act('trek_act_riddle', $a);
$r = $act('trek_act_riddle', 1);
ok('kiln stone: three wrong answers close the riddle for good, no key', $r[0] === false && $pack('kiln-key') === 0 && !$flag('kilnstone_solved'));
$wins = 0;
for ($i = 0; $i < 4 && $pack('kiln-key') === 0; $i++) {
    $T(function (&$run, $u) { trek_start_fight($run, $u, [trek_creature('spadefoot-toad')], ['kind' => 'random', 'zone' => 'm'], [trek_make_foe(trek_creature('spadefoot-toad'), $u, 1)]); return [true, '']; });
    $win(); $wins++;
}
ok('...three Spadefoot Toad kills in Potter\'s Row always drop the Kiln Key (guarantee)', $pack('kiln-key') === 1 && $wins === 3, "wins $wins key " . $pack('kiln-key'));
for ($i = 0; $i < 3; $i++) { $T(function (&$run, $u) { trek_start_fight($run, $u, [trek_creature('spadefoot-toad')], ['kind' => 'random', 'zone' => 'm'], [trek_make_foe(trek_creature('spadefoot-toad'), $u, 1)]); return [true, '']; }); $win(); }
ok('...further kills do not pile up keys while you hold one', $pack('kiln-key') === 1);
$at('kiln'); $k0 = (int)$run()['campkits']; $pe = (int)$run()['petals_found'];
$r = $act('trek_act_chest');
ok('the Sealed Kiln takes the key, gives a kit and 120 Petals (carried) once', $r[0] === true && $flag('kiln_open') && $pack('kiln-key') === 0 && (int)$run()['petals_found'] === $pe + 120 && (int)$run()['campkits'] >= $k0);
for ($i = 0; $i < 3; $i++) { $T(function (&$run, $u) { trek_start_fight($run, $u, [trek_creature('spadefoot-toad')], ['kind' => 'random', 'zone' => 'm'], [trek_make_foe(trek_creature('spadefoot-toad'), $u, 1)]); return [true, '']; }); $win(); }
ok('after the kiln is open the toads stop dropping keys', $pack('kiln-key') === 0);
$tx(function (&$run, $u) { unset($run['st']['tries_kilnstone']); q('DELETE FROM trek_flags WHERE run_id = ? AND flag IN (?, ?)', [(int)$run['id'], 'kilnstone_solved', 'kiln_open']); unset($run['flags']['kilnstone_solved'], $run['flags']['kiln_open']); q('DELETE FROM trek_pack WHERE run_id = ?', [(int)$run['id']]); return [true, '']; });
$at('kilnstone'); $r = $act('trek_act_riddle', 1);
ok('kiln stone right answer (1): Kiln Key as a carried prize, solved flag', $r[0] === true && $pack('kiln-key') === 1 && $flag('kilnstone_solved'));
// Silverfin: adds never exceed two and never block the win; a knock-out resets the fight
$fresh2(); $tx(function (&$run, $u) { trek_complete_chapter($run, $u); trek_hub_arrive($run, $u); return [true, '']; }); $tx(fn(&$run, $u) => trek_godown($run, $u));
$tx(function (&$run, $u) { $run['sn'] = str_repeat("\xff", strlen($run['sn'])); trek_flag_set($run, 'camp_seen'); $run['camp'] = 'camp'; return [true, '']; });
$bossRun('silverfin', 20);
$adds = count(array_filter($run()['fi']['foes'] ?? [], fn($f) => !empty($f['add'])));
ok('Silverfin (20 rounds): at most two page silverfish were ever called (a third never joins)', $adds <= 2 && $adds >= 1, (string)$adds);
$T(function (&$run, $u) { $run['fi']['foes'][0]['hp'] = 1; $run['fi']['foes'][0]['def'] = -50; return [true, '']; });
for ($i = 0; $i < 12 && $run()['fi']; $i++) $T(function (&$run, $u) { $acts = []; foreach ($run['party'] as $s => $p) $acts[$s] = ['a' => 'attack', 't' => 'f:0']; trek_fight_round($run, $u, $acts); return [true, '']; });
ok('...killing Silverfin ends the fight even with the little ones still alive', $run()['fi'] === null && $flag('silverfin_down'));
$clear(['silverfin_down']);
$at('silverfin'); $T(fn(&$run, $u) => trek_act_challenge($run, $u));
$T(function (&$run, $u) { foreach ($run['party'] as $i => $p) $run['party'][$i]['hp'] = 0; $run['fi']['foes'][0]['atk'] = 99; trek_fight_round($run, $u, [0 => ['a' => 'guard']]); return [true, '']; });
$R = $run();
ok('knocked out by Silverfin: back at the Tin Lamp, no fight left, she can be faced again from full health', $R['fi'] === null && [$R['x'], $R['y']] === [$sp['camp']['x'], $sp['camp']['y']] && !$flag('silverfin_down'));
$at('silverfin'); $r = $act('trek_act_challenge');
ok('...the second challenge starts clean (no adds, round 1)', $r[0] === true && count($run()['fi']['foes']) === 1 && (int)$run()['fi']['round'] === 1);
$T(function (&$run, $u) { $run['fi'] = null; return [true, '']; });
// the chapter is done: every run action is the interlude's. Slide, travel, switches are refused
$tx(function (&$run, $u) { trek_flag_set($run, 'thrum_down'); trek_complete_chapter($run, $u); trek_hub_arrive($run, $u); return [true, '']; });
$R = $run();
ok('interlude 2: trek_in_hub, not inside, and trek_inside() says the gnome is free to walk the roads again', trek_in_hub($R) && !trek_inside($uid));
// admin reset of the chapter run: back to the Chapter I interlude; milestones are not paid twice
$xpBefore = $mainXp(); $msN = (int)q_val("SELECT COUNT(*) FROM trek_ms WHERE user_id = ?", [$uid]);
$rid = (int)$R['id'];
foreach (['trek_flags', 'trek_pack', 'trek_party', 'trek_recruits'] as $t) q("DELETE FROM $t WHERE run_id = ?", [$rid]);
q('DELETE FROM trek_runs WHERE id = ?', [$rid]); q('UPDATE users SET trek_ch = 1 WHERE id = ?', [$uid]);
$r = $tx(fn(&$run, $u) => trek_godown($run, $u));
$tx(function (&$run, $u) { foreach (['ch2_sorrel', 'ch2_silverfin', 'ch2a_end', 'ch2_tumble'] as $m) trek_ms_award($run, $u, $m); return [true, '']; });
ok('after an admin reset of Chapter II you go down again with your party, and a milestone already paid pays no XP the second time', $r[0] === true && trek_active_ch($uid) === 2 && $mainXp() === $xpBefore && (int)q_val("SELECT COUNT(*) FROM trek_ms WHERE user_id = ?", [$uid]) === $msN);

echo "== boss sims at the plan's trek levels, every party the player can pick (Auto, full health, 300 fights each; real dice)\n";
$GLOBALS['trek_sim'] = true;
$N = (int)(getenv('AUDIT_N') ?: 300);
$su = q_one('SELECT * FROM users WHERE id = ?', [$uid]); $su['id'] = 999999; $su['level'] = 15; $su['calling'] = null;
foreach (['grit', 'nimble', 'hardiness'] as $st) $su['stat_' . $st] = 12;
$simWin = function (array $keys, int $L, string $boss, int $mateLv, bool $drained = false) use ($su, $N): float {
    $won = 0; $s = trek_spots(2)[$boss];
    for ($i = 0; $i < $N; $i++) {
        $r = ['id' => 0, 'chapter' => 2, 'fatigue' => 0, 'st' => ['tl' => []], 'party' => [], 'fi' => null, 'lg' => [], 'flags' => ['tut_party' => true], 'petals_found' => 0];
        $keys2 = array_merge(['gnome'], $keys);
        foreach ($keys2 as $sl => $k) { $r['party'][$sl] = ['crew_key' => $k, 'hp' => 9999]; $r['st']['tl'][$k] = [$k === 'gnome' ? $L : $mateLv, 0]; }
        foreach (trek_party_stats($r, $su) as $sl => $m) $r['party'][$sl]['hp'] = $m['max'];
        $GLOBALS['trek_sim_won'] = false;
        $c = trek_creature($s['data']['creature']); $meta = ['kind' => 'spot', 'spot' => $boss, 'script' => $s['data']['script'], 'zone' => $s['zone']];
        $f = trek_make_foe($c, $su, count($keys2), false, trek_foe_tune($meta, 2), 2);
        if ($drained) $f['hp'] = (int)ceil($f['max'] * 0.8);
        trek_start_fight($r, $su, [$c], $meta, [$f]);
        for ($k = 0; $k < 80 && $r['fi']; $k++) trek_fight_round($r, $su, trek_fight_ai($r, $su));
        if (!empty($GLOBALS['trek_sim_won'])) $won++;
    }
    return round(100 * $won / $N, 1);
};
$combos = function (array $pool, int $n) use (&$combos): array { if ($n === 0) return [[]]; $out = []; foreach ($pool as $i => $k) foreach ($combos(array_slice($pool, $i + 1), $n - 1) as $rest) $out[] = array_merge([$k], $rest); return $out; };
$abbr = ['burdock' => 'Bu', 'zinnia' => 'Zi', 'bracken' => 'Br', 'sorrel' => 'So', 'tumble' => 'Tu', 'juniper' => 'Ju'];
$nm = fn(array $c) => implode('+', array_map(fn($k) => $abbr[$k], $c));
$simRes = [];
// Silverfin: Burdock, Zinnia, Bracken and (if the book was found) Sorrel; trek Lv10 and 11
foreach ([10, 11] as $L) {
    $line = "  Silverfin Lv$L:";
    foreach ($combos(['burdock', 'zinnia', 'bracken', 'sorrel'], 3) as $c) { $w = $simWin($c, $L, 'silverfin', $L - 1); $simRes['silverfin'][$L][$nm($c)] = $w; $line .= ' ' . $nm($c) . ' ' . $w . '%'; }
    echo $line . "\n";
}
// Old Pinch Lv13 (cistern NOT drained, and drained) and Old Thrum Lv14, all 20 parties of three
foreach (['pinch' => 13, 'thrum' => 14] as $boss => $L) {
    foreach ($combos(['burdock', 'zinnia', 'bracken', 'sorrel', 'tumble', 'juniper'], 3) as $c) { $simRes[$boss][$nm($c)] = $simWin($c, $L, $boss, $L - 1); }
    asort($simRes[$boss]);
    echo "  " . ucfirst($boss) . " Lv$L, all 20 parties (mates at Lv" . ($L - 1) . "):\n    " . implode('  ', array_map(fn($k, $v) => "$k $v%", array_keys($simRes[$boss]), $simRes[$boss])) . "\n";
}
foreach (['thrum' => 14] as $boss => $L) {   // mates a level lower (late recruits: average minus 2)
    $low = [];
    foreach ($combos(['burdock', 'zinnia', 'bracken', 'sorrel', 'tumble', 'juniper'], 3) as $c) $low[$nm($c)] = $simWin($c, $L, $boss, $L - 2);
    asort($low); $simRes[$boss . '_low'] = $low;
    echo "  " . ucfirst($boss) . " Lv$L with every mate one level lower:\n    " . implode('  ', array_map(fn($k, $v) => "$k $v%", array_keys($low), $low)) . "\n";
}
$P = $simRes['pinch']; $Th = $simRes['thrum'];
echo '  info Thrum: worst party ' . array_key_first($Th) . ' ' . reset($Th) . '%, best ' . array_key_last($Th) . ' ' . end($Th) . '%; parties without Burdock: ' . implode(', ', array_map(fn($k) => "$k {$Th[$k]}%", array_filter(array_keys($Th), fn($k) => !str_contains($k, 'Bu')))) . "\n";
ok('the Chapter I trio (Bu+Zi+Br) beats Old Thrum at Lv14 at least half the time', ($Th['Bu+Zi+Br'] ?? 0) >= 50, (string)($Th['Bu+Zi+Br'] ?? 'n/a'));
ok('the Chapter I trio (Bu+Zi+Br) beats Old Pinch at Lv13 at least 60%', ($P['Bu+Zi+Br'] ?? 0) >= 60, (string)($P['Bu+Zi+Br'] ?? 'n/a'));
$pMin = min($P); $tMin = min($Th); $lowMin = min($simRes['thrum_low']);
ok('v2.0.1 party wall: every one of the 20 parties wins Old Pinch at least 70% (worst ' . array_search($pMin, $P) . ' ' . $pMin . '%) and Old Thrum at least 70% (worst ' . array_search($tMin, $Th) . ' ' . $tMin . '%)', $pMin >= 70 && $tMin >= 70, json_encode([$pMin, $tMin]));
ok('v2.0.1 party wall: with every mate a level lower, every party still wins Old Thrum 55%+ (worst ' . $lowMin . '%)', $lowMin >= 55, (string)$lowMin);
ok('v2.0.1 no mandatory trailmate: parties without Burdock and parties without Zinnia both average within 8 points of the rest on Pinch and Thrum', (function () use ($P, $Th) {
    foreach ([$P, $Th] as $res) foreach (['Bu', 'Zi'] as $k) {
        $with = array_filter($res, fn($v, $n) => str_contains($n, $k), ARRAY_FILTER_USE_BOTH); $without = array_diff_key($res, $with);
        if (abs(array_sum($with) / count($with) - array_sum($without) / count($without)) > 8) return false;
    }
    return true;
})());
ok('Silverfin is no wall for any of the four-mate parties: at Lv10 every party wins 65%+, at Lv11 85%+', min($simRes['silverfin'][10]) >= 65 && min($simRes['silverfin'][11]) >= 85, json_encode([min($simRes['silverfin'][10]), min($simRes['silverfin'][11])]));
unset($GLOBALS['trek_sim'], $GLOBALS['trek_sim_won']);
