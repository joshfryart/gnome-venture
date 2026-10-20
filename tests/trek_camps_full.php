<?php
// Treks v2.0.20: every CAMP-type rest is a full rest: fatigue 0 and everyone at full health (fixed camp, Camp Kit, old campsite, rest spot). The cold rest (no kit) stays weak.
// Also: refused when nothing to mend, ambush chance kept, kits counted, banking rules, once-only rest spot, KO checkpoint, settings kept but ignored, the player-facing lines.
// Run on an installed copy: php tests/trek_camps_full.php GAME_DIR (treks.sh does).
$_SERVER['SCRIPT_NAME'] = '/trek.php';
require $argv[1] . '/includes/bootstrap.php';
require_once $argv[1] . '/includes/trek.php';
require_once $argv[1] . '/includes/trek_art.php';
if (session_status() !== PHP_SESSION_ACTIVE) session_start();
$fails = 0;
if (!function_exists('trek_form')) { function trek_form(string $do, string $label, array $extra = [], string $class = 'btn', string $formAttrs = ''): string { return '<form method="post"' . $formAttrs . '><input type="hidden" name="do" value="' . e($do) . '"><button class="' . e($class) . '">' . e($label) . '</button></form>'; } }   // (the page defines the real one)
set_exception_handler(function (Throwable $e) { if (db()->inTransaction()) db()->rollBack(); echo '  EXCEPTION ' . get_class($e) . ': ' . $e->getMessage() . ' @ ' . basename($e->getFile()) . ':' . $e->getLine() . "\n"; exit(1); });
function ok(string $what, bool $cond, string $extra = ''): void { global $fails; echo ($cond ? '  ok   ' : '  FAIL ') . $what . ($cond ? '' : "  $extra") . "\n"; if (!$cond) $fails++; }
function cf_user(): int
{
    $r = q_one("SELECT * FROM users WHERE username = 'sprout'");
    unset($r['id']);
    $r['username'] = 'cf_' . substr(md5((string)microtime(true)), 0, 6); $r['email'] = $r['username'] . '@b.local'; $r['gnome_name'] = 'Camper'; $r['active_plot_id'] = null;
    $r['last_seen'] = now(); $r['level'] = 16; $r['coins'] = 5000; $r['energy'] = 500; $r['calling'] = null; $r['trek_ch'] = 1; $r['trek_pet_day'] = null; $r['trek_pet_today'] = 0; $r['role'] = 'player';
    return db_insert('users', $r);
}
function cf_cfg(array $kv): void { foreach ($kv as $k => $v) set_setting($k, (string)$v); setting('__reload__'); }
cf_cfg(['trek_open' => '1', 'trek_event_pct' => '0', 'trek_enc_percent' => '0', 'trek_petals_daily' => '5000', 'trek_entry_energy' => '10', 'trek_ambush_pct' => '0',
    'trek_oldcamp_ambush_pct' => '0', 'trek_oldcamp_checkpoint' => '1', 'trek_ko_loss_pct' => '45', 'trek_cold_rest_fatigue' => '25', 'trek_campkit_max' => '3', 'trek_campkit_price' => '60']);
q('UPDATE creature_drops SET chance = 0 WHERE 1 = 1');
function rig_easy(array &$run): void { foreach ($run['fi']['foes'] as $i => $f) { if (!empty($f['add'])) continue; $run['fi']['foes'][$i]['hp'] = 1; $run['fi']['foes'][$i]['def'] = -50; $run['fi']['foes'][$i]['atk'] = -60; } }

$uid = cf_user();
$tx = fn(callable $f, bool $need = true) => trek_tx($uid, $f, $need);
$run = fn() => trek_load(trek_run_row($uid));
$tx(fn(&$run, $u) => trek_enter($run, $u), false);
$tx(function (&$run, $u) { $run['sn'] = str_repeat("\xff", strlen($run['sn'])); $run['campkits'] = 2; return [true, '']; });
$coins = fn() => (int)q_val('SELECT coins FROM users WHERE id = ?', [$uid]);
$xp = fn() => (int)q_val('SELECT xp FROM users WHERE id = ?', [$uid]);
$hpOf = fn() => $tx(function (&$run, $u) { $o = []; foreach (trek_party_stats($run, $u) as $sl => $m) $o[$sl] = [(int)$run['party'][$sl]['hp'], (int)$m['max']]; return [$o, '']; })[0];
$full = fn() => !array_filter($hpOf(), fn($a) => $a[0] < $a[1]);
$log = fn() => json_encode($run()['lg'] ?? [], JSON_UNESCAPED_UNICODE);
$at = fn(int $ch, string $code, int $fat, int $hpPct, int $kits = 2) => $tx(function (&$run, $u) use ($ch, $code, $fat, $hpPct, $kits) {
    $s = trek_spots($ch)[$code]; $run['x'] = $s['x']; $run['y'] = $s['y']; $run['fatigue'] = $fat; $run['fi'] = null; $run['campkits'] = $kits;
    foreach (trek_party_stats($run, $u) as $sl => $m) $run['party'][$sl]['hp'] = max(1, (int)floor($m['max'] * $hpPct / 100));
    return [true, ''];
});
// a trailmate or two, so "the whole party" means more than the gnome
$tx(function (&$run, $u) { foreach (['burdock', 'zinnia'] as $k) trek_recruit_crew($run, $u, $k); return [true, '']; });
ok('the party has more than one member', count($hpOf()) >= 2, json_encode($hpOf()));

echo "== fixed camp (Chapter I): full health, fatigue 0, banks finds\n";
$at(1, 'camp', 90, 20);
$tx(function (&$run, $u) { $run['petals_found'] = 40; return [true, '']; });
$r = $tx(fn(&$run, $u) => trek_camp_rest($run, $u));
ok('camp rest: fatigue 0 and everyone at full health', $r[0] === true && (int)$run()['fatigue'] === 0 && $full());
ok('camp rest banks the carried finds', (int)$run()['petals_found'] === 0);

echo "== Camp Kit (Make camp, anywhere): fatigue 0, full health, one kit used\n";
$at(1, 'start', 90, 10, 2);
$r = $tx(fn(&$run, $u) => trek_make_camp($run, $u));
ok('kit: fatigue 90 -> 0, everyone full, 2 kits -> 1', $r[0] === true && (int)$run()['fatigue'] === 0 && $full() && (int)$run()['campkits'] === 1, json_encode([$r, $run()['fatigue'], $run()['campkits']]));
ok('kit: the log says fatigue to 0 and full health, not half / -50', str_contains($log(), 'Camp Kit used. Fatigue to 0, everyone back to full health.') && !str_contains($log(), 'half') && !str_contains($log(), '−50'));
$at(1, 'start', 5, 100, 2);
$r = $tx(fn(&$run, $u) => trek_make_camp($run, $u));
ok('kit, only slightly tired and unhurt: still works (fatigue 5), uses the kit', $r[0] === true && (int)$run()['fatigue'] === 0 && (int)$run()['campkits'] === 1);
$at(1, 'start', 0, 60, 2);
$r = $tx(fn(&$run, $u) => trek_make_camp($run, $u));
ok('kit, rested but hurt: heals to full, kit used', $r[0] === true && $full() && (int)$run()['campkits'] === 1);
$at(1, 'start', 0, 100, 2);
$r = $tx(fn(&$run, $u) => trek_make_camp($run, $u));
ok('kit, fatigue 0 and everyone full: refused, kit kept', $r[0] === false && (int)$run()['campkits'] === 2);
$at(1, 'start', 70, 30, 1);
$tx(fn(&$run, $u) => trek_make_camp($run, $u)); $r = $tx(fn(&$run, $u) => trek_make_camp($run, $u));
ok('double tap: one kit gone, the second tap is refused (nothing to mend) and burns nothing', $r[0] === false && (int)$run()['campkits'] === 0);
$at(1, 'start', 80, 100, 2);
$tx(function (&$run, $u) { $m = trek_party_stats($run, $u); $run['party'][0]['hp'] = 0; return [true, '']; });
$tx(fn(&$run, $u) => trek_make_camp($run, $u));
ok('a fallen member is on their feet again at full health', $full());
$at(1, 'start', 40, 50, 2);
$tx(function (&$run, $u) { $run['petals_found'] = 33; return [true, '']; });
$tx(fn(&$run, $u) => trek_make_camp($run, $u));
ok('kit rest does not bank (carried finds stay)', (int)$run()['petals_found'] === 33);

echo "== cold rest (no kit): unchanged, still weak\n";
$at(1, 'start', 80, 10, 0);
$tx(fn(&$run, $u) => trek_make_camp($run, $u));
$d = $run(); $h0 = $hpOf();
ok('cold rest: fatigue 80 -> 55 (25 off), a quarter of the health, not full', (int)$d['fatigue'] === 55 && !$full() && $h0[0][0] >= 1, json_encode([$d['fatigue'], $h0]));
ok('cold rest: the log still says a quarter', str_contains($log(), 'A cold rest. Fatigue −25, everyone heals a quarter of their health.'));
$at(1, 'start', 80, 10, 0);
cf_cfg(['trek_cold_rest_fatigue' => 0]);
$tx(fn(&$run, $u) => trek_make_camp($run, $u));
ok('cold rest setting 0 still removes nothing (the setting still works)', (int)$run()['fatigue'] === 80);
cf_cfg(['trek_cold_rest_fatigue' => 25]);
$at(1, 'start', 0, 100, 0);
$r = $tx(fn(&$run, $u) => trek_make_camp($run, $u));
ok('cold rest with nothing to mend: refused', $r[0] === false);
cf_cfg(['trek_ambush_pct' => 100]);
$at(1, 'oldhearth', 60, 50, 0);   // an old campsite tile has a spot: no ambush there; use a plain tile instead
$tx(function (&$run, $u) {   // a walkable tile with no spot in a zone that has fights
    for ($y = 5; $y < 60; $y++) for ($x = 5; $x < 60; $x++) {
        $t = trek_tile(1, $x, $y); if ($t === '' || $t === '#' || trek_spot_at(1, $x, $y)) continue;
        $z = trek_zone_at(1, $x, $y); $p = $z ? trek_zone_pool($z, 1) : null;
        if ($p && $p['list']) { $run['x'] = $x; $run['y'] = $y; $run['fi'] = null; return [true, '']; }
    }
    return [false, 'no tile'];
});
$tx(fn(&$run, $u) => trek_make_camp($run, $u));
ok('cold rest ambush still possible (100%): a fight starts, the cold rest comes after the win', !empty($run()['fi']) && ($run()['fi']['meta']['after'] ?? '') === 'rest', json_encode($run()['fi']['meta'] ?? null));
$tx(function (&$run, $u) { rig_easy($run); return [true, '']; });
$tx(function (&$run, $u) { trek_fight_auto($run, $u, 40); return [true, '']; });
ok('...and after the win the cold rest applies (a quarter, fatigue lowered 25, not full/0)', empty($run()['fi']) && (int)$run()['fatigue'] > 0 && !$full(), json_encode([$run()['fatigue'], $hpOf()]));
$tx(function (&$run, $u) { $run['fi'] = null; return [true, '']; });
cf_cfg(['trek_ambush_pct' => 0]);

echo "== old campsite (Chapter I): fatigue 0, full health, no banking, ambush kept\n";
$at(1, 'oldhearth', 95, 5);
$tx(function (&$run, $u) { $run['petals_found'] = 50; return [true, '']; });
[$c0, $x0] = [$coins(), $xp()];
$r = $tx(fn(&$run, $u) => trek_act_oldcamp($run, $u));
ok('old camp: fatigue 95 -> 0, everyone full, no kit used', $r[0] === true && (int)$run()['fatigue'] === 0 && $full() && (int)$run()['campkits'] === 2);
ok('old camp: finds are NOT banked, no Petals / XP', (int)$run()['petals_found'] === 50 && $coins() === $c0 && $xp() === $x0);
ok('old camp: log says fatigue to 0 and full health', str_contains($log(), 'An old campsite rest. Fatigue to 0, everyone back to full health.'));
$r = $tx(fn(&$run, $u) => trek_act_oldcamp($run, $u));
ok('old camp: nothing to mend -> refused', $r[0] === false && (int)$run()['fatigue'] === 0);
cf_cfg(['trek_oldcamp_ambush_pct' => 100]);
$at(1, 'oldhearth', 60, 50);
$r = $tx(fn(&$run, $u) => trek_act_oldcamp($run, $u));
ok('old camp ambush (100%) still happens first: fight, nothing healed yet, fatigue untouched', $r[0] === true && !empty($run()['fi']) && ($run()['fi']['meta']['after'] ?? '') === 'oldrest' && (int)$run()['fatigue'] === 60 && !$full());
$tx(function (&$run, $u) { rig_easy($run); return [true, '']; });
$tx(function (&$run, $u) { trek_fight_auto($run, $u, 40); return [true, '']; });
ok('...and after the win the rest follows: fatigue 0, full health', empty($run()['fi']) && (int)$run()['fatigue'] === 0 && $full());
cf_cfg(['trek_oldcamp_ambush_pct' => 0]);
$at(1, 'oldhearth', 95, 50); $o = $tx(fn(&$run, $u) => trek_act_oldcamp($run, $u));
ok('old camp still marks the knock-out checkpoint', ($run()['st']['oc'] ?? '') === 'oldhearth');
foreach ([0, 5, 100] as $v) {
    cf_cfg(['trek_oldcamp_fatigue' => $v]);
    $at(1, 'oldhearth', 77, 40); $tx(fn(&$run, $u) => trek_act_oldcamp($run, $u));
    ok("trek_oldcamp_fatigue = $v has no effect (fatigue 0, full health)", (int)$run()['fatigue'] === 0 && $full());
}
cf_cfg(['trek_oldcamp_fatigue' => 40]);
$st = trek_settings();
ok('trek_oldcamp_fatigue is kept and relabelled "(no longer used since v2.0.20)"', isset($st['trek_oldcamp_fatigue']) && str_contains($st['trek_oldcamp_fatigue']['label'], '(no longer used since v2.0.20)'));
ok('trek_cold_rest_fatigue label unchanged and in use', str_contains($st['trek_cold_rest_fatigue']['label'], 'cold rest'));

echo "== old campsite card + pop-over texts\n";
$s1 = trek_spots(1)['oldhearth'];
$html = trek_oldcamp_panel($run(), $s1, 'ch1.spot.oldhearth.find');
ok('card line: fatigue to 0, everyone back to full health; no "half" / "−40"', str_contains($html, 'Fatigue to 0, everyone back to full health') && !str_contains($html, 'half') && !str_contains($html, '−40'));
$src = file_get_contents($argv[1] . '/includes/trek_camp_ui.php') . file_get_contents($argv[1] . '/includes/trek_oldcamp.php') . file_get_contents($argv[1] . '/includes/trek.php');
ok('no PHP string still says "heals half" or "Fatigue −50" / "−40"', !preg_match('/heals half|Fatigue −50|Fatigue −\' \. trek_oldcamp|−40/u', $src));

echo "== Chapter II: rest spot (once), Cushion Corner\n";
$tx(function (&$run, $u) { foreach (['burdock', 'zinnia', 'bracken'] as $k) trek_recruit_crew($run, $u, $k); $run['st']['tl']['gnome'] = [10, 0]; trek_complete_chapter($run, $u); trek_hub_arrive($run, $u); return [true, '']; });
$r = $tx(fn(&$run, $u) => trek_godown($run, $u));
ok('Chapter II reached', $r[0] === true && trek_active_ch($uid) === 2);
$tx(function (&$run, $u) { $run['sn'] = str_repeat("\xff", strlen($run['sn'])); return [true, '']; });
$at(2, 'rest', 88, 15, 1);
$tx(function (&$run, $u) { $run['petals_found'] = 25; return [true, '']; });
$r = $tx(fn(&$run, $u) => trek_act_rest($run, $u));
ok('rest spot: fatigue 88 -> 0, everyone full, kit untouched, no banking', $r[0] === true && (int)$run()['fatigue'] === 0 && $full() && (int)$run()['campkits'] === 1 && (int)$run()['petals_found'] === 25);
ok('rest spot log line: fatigue to 0 and full health', str_contains($log(), 'A good sit. Fatigue to 0, everyone back to full health.'));
$tx(function (&$run, $u) { $run['fatigue'] = 50; foreach ($run['party'] as $i => $p) $run['party'][$i]['hp'] = 1; return [true, '']; });
$r = $tx(fn(&$run, $u) => trek_act_rest($run, $u));
ok('rest spot is once-only: the second sit is refused', $r[0] === false && (int)$run()['fatigue'] === 50);

echo "== Chapter II old campsites + kit + fixed camp\n";
foreach (['olddry', 'oldtent', 'oldbench'] as $c) {
    $at(2, $c, 66, 20); $r = $tx(fn(&$run, $u) => trek_act_oldcamp($run, $u));
    ok("Ch II $c: fatigue 0, full health", $r[0] === true && (int)$run()['fatigue'] === 0 && $full());
}
$at(2, 'olddry', 0, 100); $r = $tx(fn(&$run, $u) => trek_act_oldcamp($run, $u));
ok('Ch II old camp, nothing to mend: refused', $r[0] === false);
$at(2, 'camp', 70, 30);
$r = $tx(fn(&$run, $u) => trek_camp_rest($run, $u));
ok('Ch II fixed camp: fatigue 0, full health', $r[0] === true && (int)$run()['fatigue'] === 0 && $full());
$tx(function (&$run, $u) { $s = trek_spots(2)['start']; $run['x'] = $s['x']; $run['y'] = $s['y']; $run['fatigue'] = 60; $run['campkits'] = 2; foreach ($run['party'] as $i => $p) $run['party'][$i]['hp'] = 1; return [true, '']; });
$r = $tx(fn(&$run, $u) => trek_make_camp($run, $u));
ok('Ch II kit: fatigue 0, full health, one kit used', $r[0] === true && (int)$run()['fatigue'] === 0 && $full() && (int)$run()['campkits'] === 1);

echo "== the camp pop-over lines\n";
$ui = file_get_contents($argv[1] . '/includes/trek_camp_ui.php');
ok('pop-over: kit, old camp and rest spot lines say fatigue to 0 / full health; cold rest still says a quarter',
    substr_count($ui, 'Fatigue to 0, everyone back to full health') >= 3 && str_contains($ui, 'heal a quarter'));

echo "== text slots: no live slot body or brief says half / -50 / -40 for a camp rest\n";
$bad = [];
foreach (q("SELECT text_key, body FROM trek_texts WHERE text_key LIKE '%camp.makecamp' OR text_key LIKE '%oldcamp.rest' OR text_key IN ('ch2.spot.rest.done', 'ch3.spot.bench.done')")->fetchAll() as $r) {
    if (preg_match('/half|−50|-50|−40|-40|a little|much better|short/i', (string)$r['body'])) $bad[] = $r['text_key'];
}
ok('rest slot bodies read as a full rest', !$bad, implode(', ', $bad));

$fails ? print("\n$fails FAILED\n") : print("\nall ok\n");
exit($fails ? 1 : 0);
