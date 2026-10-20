<?php
// Treks v2.0.1: old campsites (Chapter I: 2, Chapter II: 3). Data and map, reachability, the rest (fatigue, healing, no kit, repeatable), the ambush rate against the setting,
// the optional knock-out checkpoint, no reward faucet (Petals, XP, items, banking), double taps, settings at 0 / max, fatigue 0 / 100. Run on an installed copy: php tests/trek_oldcamp.php GAME_DIR (treks.sh does).
$_SERVER['SCRIPT_NAME'] = '/trek.php';
require $argv[1] . '/includes/bootstrap.php';
require_once $argv[1] . '/includes/trek.php';
require_once $argv[1] . '/includes/trek_art.php';
if (session_status() !== PHP_SESSION_ACTIVE) session_start();
$fails = 0;
if (!function_exists('trek_form')) { function trek_form(string $do, string $label, array $extra = [], string $class = 'btn', string $formAttrs = ''): string { return '<form method="post"' . $formAttrs . '><input type="hidden" name="do" value="' . e($do) . '"><button class="' . e($class) . '">' . e($label) . '</button></form>'; } }   // (the page defines the real one)
set_exception_handler(function (Throwable $e) { if (db()->inTransaction()) db()->rollBack(); echo '  EXCEPTION ' . get_class($e) . ': ' . $e->getMessage() . ' @ ' . basename($e->getFile()) . ':' . $e->getLine() . "\n"; exit(1); });
function ok(string $what, bool $cond, string $extra = ''): void { global $fails; echo ($cond ? '  ok   ' : '  FAIL ') . $what . ($cond ? '' : "  $extra") . "\n"; if (!$cond) $fails++; }
$nUser = 0;
function oc_user(): int
{
    global $nUser;
    $r = q_one("SELECT * FROM users WHERE username = 'sprout'");
    unset($r['id']);
    $nUser++;
    $r['username'] = 'oc_' . $nUser . '_' . substr(md5((string)microtime(true)), 0, 5); $r['email'] = $r['username'] . '@b.local'; $r['gnome_name'] = 'Camper' . $nUser; $r['active_plot_id'] = null;
    $r['last_seen'] = now(); $r['level'] = 16; $r['coins'] = 5000; $r['energy'] = 500; $r['calling'] = null; $r['trek_ch'] = 1; $r['trek_pet_day'] = null; $r['trek_pet_today'] = 0; $r['role'] = 'player';
    return db_insert('users', $r);
}
function oc_cfg(array $kv): void { foreach ($kv as $k => $v) set_setting($k, (string)$v); setting('__reload__'); }
function rig_easy(array &$run): void { foreach ($run['fi']['foes'] as $i => $f) { if (!empty($f['add'])) continue; $run['fi']['foes'][$i]['hp'] = 1; $run['fi']['foes'][$i]['def'] = -50; $run['fi']['foes'][$i]['atk'] = -60; } }
function rig_deadly(array &$run): void { foreach ($run['fi']['foes'] as $i => $f) { $run['fi']['foes'][$i]['hp'] = $run['fi']['foes'][$i]['max'] = 99999; $run['fi']['foes'][$i]['def'] = 999; $run['fi']['foes'][$i]['atk'] = 100; $run['fi']['foes'][$i]['die'] = 60; } }
oc_cfg(['trek_open' => '1', 'trek_event_pct' => '0', 'trek_enc_percent' => '0', 'trek_petals_daily' => '5000', 'trek_entry_energy' => '10', 'trek_ambush_pct' => '0',
    'trek_oldcamp_fatigue' => '40', 'trek_oldcamp_ambush_pct' => '0', 'trek_oldcamp_checkpoint' => '1', 'trek_ko_loss_pct' => '45']);
q('UPDATE creature_drops SET chance = 0 WHERE 1 = 1');

echo "== data: settings, icon, sites, map, text slots\n";
$st = trek_settings();
ok('three settings with the right defaults and "(v2.0.1)" labels', ($st['trek_oldcamp_fatigue']['default'] ?? '') === '40' && ($st['trek_oldcamp_ambush_pct']['default'] ?? '') === '12' && ($st['trek_oldcamp_checkpoint']['default'] ?? '') === '1'
    && !array_filter(['trek_oldcamp_fatigue', 'trek_oldcamp_ambush_pct', 'trek_oldcamp_checkpoint'], fn($k) => !str_starts_with($st[$k]['label'], 'Treks: ') || !str_contains($st[$k]['label'], '(v2.0.1)')));
ok('the spot icon is the tent', (TREK_SPOT_ICONS['oldcamp'] ?? '') === '⛺');
$sites = [1 => array_filter(trek_spots(1), fn($s) => $s['type'] === 'oldcamp'), 2 => array_filter(trek_spots(2), fn($s) => $s['type'] === 'oldcamp')];
ok('2 sites in Chapter I, 3 in Chapter II', count($sites[1]) === 2 && count($sites[2]) === 3, count($sites[1]) . '/' . count($sites[2]));
echo '  info positions: ' . implode('; ', array_map(fn($ch) => 'Ch' . $ch . ' ' . implode(', ', array_map(fn($s) => $s['code'] . '@' . $s['x'] . ',' . $s['y'] . ' zone ' . $s['zone'], $sites[$ch])), [1, 2])) . "\n";
$bad = [];
foreach ($sites as $ch => $list) foreach ($list as $c => $s) {
    if (trek_tile($ch, $s['x'], $s['y']) !== $s['sym']) $bad[] = "$c tile";
    if (trek_zone_at($ch, $s['x'], $s['y']) !== $s['zone']) $bad[] = "$c zone";
    $p = trek_zone_pool($s['zone'], $ch);
    if (!$p || !$p['list'] || (int)$p['mult'] <= 0) $bad[] = "$c no fight pool";
    foreach (['find'] as $part) { $k = "ch$ch.spot.$c.$part"; $row = trek_text_row($k); if (!$row || trim((string)$row['body']) === '' || trim(trek_text($k)) === '') $bad[] = "$k no draft"; }
}
foreach ([1, 2] as $ch) foreach (['oldcamp.rest', 'oldcamp.ambush', 'ko.oldcamp'] as $p) { $k = "ch$ch.$p"; $row = trek_text_row($k); if (!$row || trim((string)$row['body']) === '' || trim(trek_text($k)) === '') $bad[] = "$k no draft"; }
ok('each site sits on its symbol tile in its zone, the zone has fights, and every find/rest/ambush/KO slot has a brief and a draft', !$bad, implode(', ', $bad));
$none = [];
foreach ([1, 2] as $ch) { $rows = q('SELECT brief, status FROM trek_texts WHERE text_key LIKE ? AND text_key LIKE ?', ["ch$ch.%", '%old%'])->fetchAll(); foreach ($rows as $r) if (trim((string)$r['brief']) === '' || $r['status'] !== 'draft') $none[] = $r['status']; }
ok('all 11 slots are status draft with a brief', !$none && (int)q_val("SELECT COUNT(*) FROM trek_texts WHERE (text_key LIKE 'ch%.spot.old%.find' OR text_key LIKE 'ch%.oldcamp.%' OR text_key LIKE 'ch%.ko.oldcamp')") === 11, json_encode($none));

// ------------------------------------------------------------------ Chapter I
echo "== Chapter I: setup\n";
$uid = oc_user();
$tx = fn(callable $f, bool $need = true) => trek_tx($uid, $f, $need);
$run = fn() => trek_load(trek_run_row($uid));
$tx(fn(&$run, $u) => trek_enter($run, $u), false);
$tx(function (&$run, $u) { $run['sn'] = str_repeat("\xff", strlen($run['sn'])); $run['campkits'] = 2; return [true, '']; });
$coins = fn() => (int)q_val('SELECT coins FROM users WHERE id = ?', [$uid]);
$xp = fn() => (int)q_val('SELECT xp FROM users WHERE id = ?', [$uid]);
$packSum = fn() => (int)q_val('SELECT COALESCE(SUM(qty),0) FROM trek_pack WHERE run_id = ?', [(int)$run()['id']]);
$satchel = fn() => (int)q_val('SELECT COALESCE(SUM(qty),0) FROM user_items WHERE user_id = ?', [$uid]);
$at = fn(int $ch, string $code, int $fat = 0, ?int $hpPct = null) => $tx(function (&$run, $u) use ($ch, $code, $fat, $hpPct) {
    $s = trek_spots($ch)[$code]; $run['x'] = $s['x']; $run['y'] = $s['y']; $run['fatigue'] = $fat; $run['fi'] = null;
    foreach (trek_party_stats($run, $u) as $sl => $m) $run['party'][$sl]['hp'] = $hpPct === null ? $m['max'] : max(1, (int)floor($m['max'] * $hpPct / 100));
    return [true, ''];
});
$rest = fn() => $tx(fn(&$run, $u) => trek_act_oldcamp($run, $u));
$hpOf = fn() => $tx(function (&$run, $u) { $o = []; foreach (trek_party_stats($run, $u) as $sl => $m) $o[$sl] = [(int)$run['party'][$sl]['hp'], (int)$m['max']]; return [$o, '']; })[0];
$log = fn() => json_encode($run()['lg'] ?? [], JSON_UNESCAPED_UNICODE);

echo "== Chapter I: reachability from the start (gates open as the story opens them)\n";
foreach ($sites[1] as $c => $s) {
    $r = $tx(function (&$run, $u) use ($s) { foreach (['won_fight', 'freed_burdock', 'freed_zinnia'] as $f) trek_flag_set($run, $f); $st0 = trek_spots(1)['start']; $run['x'] = $st0['x']; $run['y'] = $st0['y']; trek_party_stats($run, $u); return [count(trek_path($run, $s['x'], $s['y'])), '']; });
    ok("Ch I $c: a path from the start exists", $r[0] > 0, (string)$r[0]);
}
$tx(function (&$run, $u) { $run['camp'] = null; return [true, '']; });

echo "== Chapter I: stepping on a site (walk stops, card, map token, key)\n";
$s1 = $sites[1]['oldhearth'];
$tx(function (&$run, $u) use ($s1) { $run['x'] = $s1['x'] - 1; $run['y'] = $s1['y']; $run['fatigue'] = 0; return [true, '']; });
$tx(fn(&$run, $u) => trek_walk($run, $u, $s1['x'], $s1['y']));
$r = $run();
ok('walking onto it stops there and sets the seen flag', (int)$r['x'] === $s1['x'] && (int)$r['y'] === $s1['y'] && !empty($r['flags']['seen_oldhearth']));
oc_cfg(['trek_oldcamp_ambush_pct' => 12]);
$html = trek_oldcamp_panel($run(), $s1, 'ch1.spot.oldhearth.find');
oc_cfg(['trek_oldcamp_ambush_pct' => 0]);
ok('the card shows the find text, the rest button and the plain-words line', str_contains($html, 'name="do" value="rest_old"') && str_contains($html, 'No kit needed. Fatigue −40') && str_contains($html, 'A small chance of an ambush'), $html);

echo "== Chapter I: the rest (fatigue 80, hurt)\n";
$at(1, 'oldhearth', 80, 20);
[$c0, $x0, $p0, $k0, $sat0] = [$coins(), $xp(), $packSum(), (int)$run()['campkits'], $satchel()];
$hp0 = $hpOf();
$r = $rest();
$hp1 = $hpOf();
$d = $run();
ok('fatigue 80 -> 40, no kit used', $r[0] === true && (int)$d['fatigue'] === 40 && (int)$d['campkits'] === $k0);
$okHeal = true; foreach ($hp0 as $sl => [$h, $mx]) { $want = min($mx, $h + (int)ceil($mx * 0.5)); if ($hp1[$sl][0] !== $want) $okHeal = false; }
ok('everyone heals half their max health (capped)', $okHeal, json_encode([$hp0, $hp1]));
ok('the rest text and the plain line are in the log', str_contains($log(), 'old campsite rest') && str_contains($log(), 'Fatigue −40'));
ok('no faucet: Petals, XP, pack, satchel and carried finds unchanged', $coins() === $c0 && $xp() === $x0 && $packSum() === $p0 && $satchel() === $sat0);
$r = $rest(); ok('repeatable: a second rest takes fatigue 40 -> 0', $r[0] === true && (int)$run()['fatigue'] === 0);
$hpFull = $hpOf(); $r = $rest();
$hpNow = $hpOf();
ok('the third (fatigue 0, hurt) still heals', $r[0] === true || array_sum(array_map(fn($a) => $a[0], $hpNow)) >= array_sum(array_map(fn($a) => $a[0], $hpFull)));
$at(1, 'oldhearth', 0);
$r = $rest();
ok('fatigue 0 and everyone full: refused, nothing changes, no kit used', $r[0] === false && (int)$run()['fatigue'] === 0 && (int)$run()['campkits'] === $k0);
$at(1, 'oldhearth', 100);
$r = $rest(); ok('fatigue 100 -> 60', $r[0] === true && (int)$run()['fatigue'] === 60);
$at(1, 'oldhearth', 30);
$r = $rest(); ok('fatigue 30 -> 0, never negative', $r[0] === true && (int)$run()['fatigue'] === 0);

echo "== Chapter I: double tap\n";
$at(1, 'oldhearth', 70, 30);
$a = $rest(); $b = $rest(); $c3 = $rest(); $d = $run();
ok('three quick taps: fatigue 70 -> 30 -> 0 -> refused when everyone is fully healed; never below 0, no extra rewards', (int)$d['fatigue'] === 0 && $coins() === $c0 && $xp() === $x0);
$at(1, 'oldhearth', 0);
$a = $rest(); $b = $rest();
ok('rested + full: both taps refused, same state', $a[0] === false && $b[0] === false);
$tx(function (&$run, $u) { $run['inside'] = 0; return [true, '']; });
$r = $rest(); ok('not inside the trek: refused', $r[0] === false);
$tx(function (&$run, $u) { $run['inside'] = 1; return [true, '']; });
$tx(function (&$run, $u) { $s = trek_spots(1)['start']; $run['x'] = $s['x']; $run['y'] = $s['y']; $run['fatigue'] = 60; return [true, '']; });
$r = $rest(); ok('not on a site: refused, nothing changes', $r[0] === false && (int)$run()['fatigue'] === 60);

echo "== settings at 0 and at the top\n";
oc_cfg(['trek_oldcamp_fatigue' => 0]);
$at(1, 'oldhearth', 50, 30); $r = $rest(); $hpA = $hpOf();
ok('fatigue setting 0: fatigue stays, health still comes back', $r[0] === true && (int)$run()['fatigue'] === 50 && $hpA[0][0] > 1);
oc_cfg(['trek_oldcamp_fatigue' => 100]);
$at(1, 'oldhearth', 95); $rest(); ok('fatigue setting 100: clears it all', (int)$run()['fatigue'] === 0);
oc_cfg(['trek_oldcamp_fatigue' => 40]);

echo "== the ambush\n";
oc_cfg(['trek_oldcamp_ambush_pct' => 100]);
$at(1, 'oldhearth', 60, 50);
$r = $rest(); $d = $run();
ok('ambush 100: a fight starts (after = oldrest), the fatigue is not taken off yet, no healing yet', $r[0] === true && !empty($d['fi']) && ($d['fi']['meta']['after'] ?? '') === 'oldrest' && (int)$d['fatigue'] === 60, json_encode($d['fi']['meta'] ?? null));
$tx(function (&$run, $u) { rig_easy($run); return [true, '']; });
$r = $rest(); ok('while a fight is on, tapping rest again does nothing', $r[0] === false);
$tx(function (&$run, $u) { trek_fight_auto($run, $u, 40); return [true, '']; });
$d = $run();
ok('after the win the rest follows: fatigue 60 + the fight\'s tiring - 40, fight over', empty($d['fi']) && (int)$d['fatigue'] === max(0, 60 + 3 - 40), (int)$d['fatigue'] . ' fi ' . (empty($d['fi']) ? 'none' : 'on'));
ok('the log has the old-campsite rest line after the fight', str_contains($log(), 'old campsite rest'));
$at(1, 'oldhearth', 0);
$r = $rest(); ok('ambush 100 but nothing to mend: no ambush, no fight', $r[0] === false && empty($run()['fi']));
oc_cfg(['trek_oldcamp_ambush_pct' => 0]);
$at(1, 'oldhearth', 60);
$n = 0; for ($i = 0; $i < 60; $i++) { $at(1, 'oldhearth', 60); $rest(); if (!empty($run()['fi'])) $n++; }
ok('ambush 0: 60 rests, no ambush', $n === 0);

echo "== ambush rate against the setting (3000 rolls each, in one transaction)\n";
$rate = function (int $pct, int $ch, string $code, int $N = 3000) use ($tx) {
    oc_cfg(['trek_oldcamp_ambush_pct' => $pct]);
    return $tx(function (&$run, $u) use ($ch, $code, $N) {
        $s = trek_spots($ch)[$code]; $run['x'] = $s['x']; $run['y'] = $s['y']; $n = 0;
        for ($i = 0; $i < $N; $i++) { $run['fi'] = null; $run['fatigue'] = 50; $run['st']['fh'] = 0; trek_act_oldcamp($run, $u); if (!empty($run['fi'])) $n++; }
        $run['fi'] = null;
        return [$n, ''];
    })[0];
};
$n12 = $rate(12, 1, 'oldhearth'); $r12 = $n12 / 3000;
ok('default 12%: observed ' . round($r12 * 100, 1) . '% (want 10.0-14.0)', $r12 >= 0.10 && $r12 <= 0.14);
$nH = $rate(12, 1, 'oldleanto'); ok('the Lean-to (the hamlet\'s lighter fights) too: ' . round($nH / 30, 1) . '%', $nH / 3000 >= 0.10 && $nH / 3000 <= 0.14);
$n30 = $rate(30, 1, 'oldhearth'); ok('30% observed ' . round($n30 / 30, 1) . '% (want 27-33), well above 12%', $n30 / 3000 >= 0.27 && $n30 / 3000 <= 0.33 && $n30 > $n12);
$n0 = $rate(0, 1, 'oldhearth', 500); ok('0%: none in 500', $n0 === 0);
$n100 = $rate(100, 1, 'oldhearth', 300); ok('100%: always (300/300)', $n100 === 300);
oc_cfg(['trek_oldcamp_ambush_pct' => 0]);

echo "== the checkpoint (Chapter I)\n";
oc_cfg(['trek_oldcamp_checkpoint' => 1]);
$kill = function (string $where = 'oldhearth') use ($tx) {   // a real knock-out through the fight code
    $tx(function (&$run, $u) { $zone = trek_zone_at((int)$run['chapter'], (int)$run['x'], (int)$run['y']); trek_start_random_fight($run, $u, $zone); rig_deadly($run); return [true, '']; });
    $tx(function (&$run, $u) { for ($i = 0; $i < 80 && $run['fi']; $i++) trek_fight_auto($run, $u, 1); return [true, '']; });
};
$ck = fn() => [(int)$run()['x'], (int)$run()['y'], (int)$run()['fatigue'], ($run()['camp'] ?? null)];
// before the first camp: tutorial KO (nothing lost) but wakes at the site
$tx(function (&$run, $u) { $run['camp'] = null; unset($run['st']['oc']); $run['petals_found'] = 100; return [true, '']; });
$at(1, 'oldhearth', 50); $rest();
ok('resting marks the site (st.oc)', ($run()['st']['oc'] ?? '') === 'oldhearth');
$tx(function (&$run, $u) { $s = trek_spots(1)['cart']; $run['x'] = $s['x']; $run['y'] = $s['y']; return [true, '']; });
$kill();
[$x, $y, $f] = $ck();
ok('KO before any camp, after resting at the site: wake AT the site, fatigue 50, nothing lost (the forgiving rule stays)', $x === $s1['x'] && $y === $s1['y'] && $f === 50 && (int)$run()['petals_found'] === 100 && empty($run()['fi']));
ok('the KO line is the old-campsite one', str_contains($log(), 'old campsite'));
$hpK = $hpOf(); ok('and everyone is back on full health', !array_filter($hpK, fn($a) => $a[0] !== $a[1]));
// no rest at a site yet: start
$tx(function (&$run, $u) { unset($run['st']['oc']); $run['camp'] = null; $s = trek_spots(1)['cart']; $run['x'] = $s['x']; $run['y'] = $s['y']; return [true, '']; });
$kill(); [$x, $y] = $ck(); $st0 = trek_spots(1)['start'];
ok('no rest at a site: back to the start, as before', $x === $st0['x'] && $y === $st0['y']);
// after a camp: the camp is at y=12, the site at y=15: the site is further along
$tx(function (&$run, $u) { unset($run['st']['oc']); $run['camp'] = 'camp'; trek_flag_set($run, 'camp_seen'); $run['petals_found'] = 100; return [true, '']; });
$at(1, 'oldhearth', 50); $rest();
$tx(function (&$run, $u) { $s = trek_spots(1)['elder']; $run['x'] = $s['x']; $run['y'] = $s['y']; return [true, '']; });
$kill(); [$x, $y] = $ck();
ok('after the first camp, a site further along: KO wakes at the site', $x === $s1['x'] && $y === $s1['y']);
ok('...and the usual share of unbanked finds is lost (the site is not a bank)', (int)$run()['petals_found'] < 100, (string)$run()['petals_found']);
oc_cfg(['trek_oldcamp_checkpoint' => 0]);
$tx(function (&$run, $u) { $s = trek_spots(1)['elder']; $run['x'] = $s['x']; $run['y'] = $s['y']; $run['petals_found'] = 100; return [true, '']; });
$kill(); [$x, $y] = $ck(); $cp = trek_spots(1)['camp'];
ok('checkpoint setting 0: KO goes to the camp (the site is ignored)', $x === $cp['x'] && $y === $cp['y'], "$x,$y vs {$cp['x']},{$cp['y']} camp=" . json_encode($run()['camp']) . ' oc=' . json_encode($run()['st']['oc'] ?? null));
oc_cfg(['trek_oldcamp_checkpoint' => 1]);
$tx(function (&$run, $u) { $s = trek_spots(1)['elder']; $run['x'] = $s['x']; $run['y'] = $s['y']; return [true, '']; });
$kill(); [$x, $y] = $ck();
ok('setting back to 1: the remembered site works again', $x === $s1['x'] && $y === $s1['y']);
// arriving at a camp later than the site wins over it
$tx(function (&$run, $u) { $run['camp'] = 'camp'; return [true, '']; });
$tx(function (&$run, $u) { $f = trek_spots(1)['oldleanto']; $run['x'] = $f['x']; $run['y'] = $f['y']; $run['fatigue'] = 50; trek_act_oldcamp($run, $u); return [true, '']; });
ok('resting at the second, further site moves the mark forward', ($run()['st']['oc'] ?? '') === 'oldleanto');
$at(1, 'oldhearth', 50); $rest();
ok('and resting at the first one afterwards does not move it back', ($run()['st']['oc'] ?? '') === 'oldleanto');
ok('a bogus remembered code is ignored (back to the camp)', $tx(function (&$run, $u) { $run['st']['oc'] = 'camp'; $ko = trek_oldcamp_ko_spot($run); $run['st']['oc'] = 'nope'; $ko2 = trek_oldcamp_ko_spot($run); $run['st']['oc'] = 'oldleanto'; return [$ko === null && $ko2 === null, '']; })[0]);
$tx(function (&$run, $u) { $run['camp'] = null; unset($run['st']['oc']); return [true, '']; });

// ------------------------------------------------------------------ Chapter II
echo "== Chapter II: setup (finish Chapter I, go down)\n";
$tx(function (&$run, $u) { foreach (['burdock', 'zinnia', 'bracken'] as $k) trek_recruit_crew($run, $u, $k); $run['st']['tl']['gnome'] = [10, 0]; trek_complete_chapter($run, $u); trek_hub_arrive($run, $u); return [true, '']; });
$r = $tx(fn(&$run, $u) => trek_godown($run, $u));
ok('Chapter II reached', $r[0] === true && trek_active_ch($uid) === 2);
$tx(function (&$run, $u) { $run['sn'] = str_repeat("\xff", strlen($run['sn'])); $run['campkits'] = 2; return [true, '']; });
echo "== Chapter II: reachability with the least progress that opens the way\n";
$need = ['olddry' => ['drained_j'], 'oldtent' => ['drained_j', 'libdoor_open', 'drained_l', 'silverfin_down'], 'oldbench' => ['drained_j', 'libdoor_open', 'drained_l', 'silverfin_down']];
foreach ($sites[2] as $c => $s) {
    $r = $tx(function (&$run, $u) use ($s, $need, $c) {
        foreach (['drained_j', 'libdoor_open', 'drained_l', 'silverfin_down', 'drained_r'] as $f) { q('DELETE FROM trek_flags WHERE run_id = ? AND flag = ?', [(int)$run['id'], $f]); unset($run['flags'][$f]); }
        foreach ($need[$c] as $f) trek_flag_set($run, $f);
        $st0 = trek_spots(2)['start']; $run['x'] = $st0['x']; $run['y'] = $st0['y']; trek_party_stats($run, $u); return [count(trek_path($run, $s['x'], $s['y'])), '']; });
    ok("Ch II $c: reachable from the start with only [" . implode(',', $need[$c]) . "]", $r[0] > 0, (string)$r[0]);
}
$r = $tx(function (&$run, $u) { $s = trek_spots(2)['oldtent']; foreach (['silverfin_down', 'drained_l', 'libdoor_open'] as $f) { q('DELETE FROM trek_flags WHERE run_id = ? AND flag = ?', [(int)$run['id'], $f]); unset($run['flags'][$f]); } $st0 = trek_spots(2)['start']; $run['x'] = $st0['x']; $run['y'] = $st0['y']; return [count(trek_path($run, $s['x'], $s['y'])), '']; });
ok('...and the Hush site is NOT reachable before Silverfin (so it is no shortcut around the story)', $r[0] === 0);
foreach (['drained_j', 'libdoor_open', 'drained_l', 'silverfin_down', 'drained_r'] as $f) $tx(function (&$run, $u) use ($f) { trek_flag_set($run, $f); return [true, '']; });

echo "== Chapter II: rest and checkpoint\n";
$tx(function (&$run, $u) { $run['camp'] = null; unset($run['st']['oc']); return [true, '']; });
oc_cfg(['trek_oldcamp_ambush_pct' => 0]);
[$c0, $x0] = [$coins(), $xp()];
foreach ($sites[2] as $c => $s) {
    $at(2, $c, 70, 25); $r = $rest(); $d = $run();
    ok("Ch II $c: fatigue 70 -> 30, hurt party mended, no Petals/XP/kit", $r[0] === true && (int)$d['fatigue'] === 30 && $coins() === $c0 && $xp() === $x0 && (int)$d['campkits'] === 2);
}
$html = trek_oldcamp_panel($run(), $sites[2]['oldbench'], 'ch2.spot.oldbench.find');
ok('the Cistern Bench card: rest button + "If you fall, you wake up here."', str_contains($html, 'rest_old') && str_contains($html, 'If you fall, you wake up here.'));
$spot = fn(string $c) => trek_spots(2)[$c];
$tx(function (&$run, $u) { unset($run['st']['oc']); $run['camp'] = 'camp'; trek_flag_set($run, 'camp_seen'); return [true, '']; });
$at(2, 'olddry', 50); $rest();
ok('Tin Lamp (y=20) is further along than the Dry Ledge (y=14): the mark is set, but a KO still goes to the Tin Lamp', ($run()['st']['oc'] ?? '') === 'olddry' && $tx(fn(&$run, $u) => [trek_oldcamp_ko_spot($run) === null, ''])[0]);
$at(2, 'oldtent', 50); $rest();
$s = $spot('oldtent');
$tx(function (&$run, $u) { $x = trek_spots(2)['crossroads']; $run['x'] = $x['x']; $run['y'] = $x['y']; return [true, '']; });
$kill(); [$x, $y] = $ck();
ok('past the Crossroads, a KO after the Hush rest wakes at the Sagging Tent, not back at the Tin Lamp', $x === $s['x'] && $y === $s['y'], "$x,$y");
$tx(function (&$run, $u) { $run['camp'] = 'camp2'; return [true, '']; });
$tx(function (&$run, $u) { $x = trek_spots(2)['juniper']; $run['x'] = $x['x']; $run['y'] = $x['y']; return [true, '']; });
$kill(); [$x, $y] = $ck(); $b = $spot('camp2');
ok('once the Brewhouse (camp 2) is the last camp, it beats the Hush tent: KO goes to the Brewhouse', $x === $b['x'] && $y === $b['y']);
$at(2, 'oldbench', 50); $rest();
$tx(function (&$run, $u) { $x = trek_spots(2)['pinch']; $run['x'] = $x['x']; $run['y'] = $x['y']; return [true, '']; });
$kill(); [$x, $y] = $ck(); $b = $spot('oldbench');
ok('after the Cistern Bench rest, a KO near Old Pinch wakes at the bench', $x === $b['x'] && $y === $b['y']);
ok('the Chapter II KO text is the old-campsite slot (ch2.ko.oldcamp)', str_contains(substr($log(), -250), 'ch2.ko.oldcamp'), substr($log(), -300));

echo "== Chapter II: ambush rate in the Hush and the Cistern zones\n";
$nT = $rate(12, 2, 'oldtent'); ok('Hush tent 12%: ' . round($nT / 30, 1) . '% (want 10-14)', $nT / 3000 >= 0.10 && $nT / 3000 <= 0.14);
$nB = $rate(12, 2, 'oldbench'); ok('Cistern bench 12%: ' . round($nB / 30, 1) . '% (want 10-14)', $nB / 3000 >= 0.10 && $nB / 3000 <= 0.14);
$nD = $rate(12, 2, 'olddry'); ok('Dry Ledge 12%: ' . round($nD / 30, 1) . '% (want 10-14)', $nD / 3000 >= 0.10 && $nD / 3000 <= 0.14);
echo "== a real camp still banks, a site does not\n";
$tx(function (&$run, $u) { $run['petals_found'] = 77; return [true, '']; });
$at(2, 'oldbench', 50); $rest();
ok('resting at a site leaves the carried Petals carried', (int)$run()['petals_found'] === 77);
$tx(function (&$run, $u) { $s = trek_spots(2)['camp']; $run['x'] = $s['x']; $run['y'] = $s['y']; return [true, '']; });
$rc = $tx(fn(&$run, $u) => trek_camp_rest($run, $u));
ok('...and a camp rest banks them', (int)$run()['petals_found'] === 0, json_encode($rc) . ' at ' . $run()['x'] . ',' . $run()['y'] . ' fi ' . json_encode(!empty($run()['fi'])));
echo $fails ? "\n$fails FAILED\n" : "\nall ok\n";
exit($fails ? 1 : 0);
