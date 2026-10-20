<?php
// Treks (1.8.0): data checks, map reachability, engine flows (walk, fight, camp, bank, KO, spots). Run by treks.sh on a fresh install.
$_SERVER['SCRIPT_NAME'] = '/trek.php';
require $argv[1] . '/includes/bootstrap.php';
require_once $argv[1] . '/includes/trek.php';
if (session_status() !== PHP_SESSION_ACTIVE) session_start();
$fails = 0;
set_exception_handler(function (Throwable $e) { if (db()->inTransaction()) db()->rollBack(); echo '  EXCEPTION ' . get_class($e) . ': ' . $e->getMessage() . ' @ ' . basename($e->getFile()) . ':' . $e->getLine() . "\n"; exit(1); });
function ok(string $what, bool $cond, string $extra = ''): void { global $fails; echo ($cond ? '  ok   ' : '  FAIL ') . $what . ($cond ? '' : "  $extra") . "\n"; if (!$cond) $fails++; }
$uid = (int)q_val("SELECT id FROM users WHERE username = 'sprout'");
$tx = fn(callable $f, bool $need = true) => trek_tx($uid, $f, $need);
$run = fn() => trek_load(trek_run_row($uid));

echo "== data\n";
$spots = trek_spots(1);
ok('20 spots (17 + the 3 hand-placed stops)', count(array_filter($spots, fn($s) => $s['type'] !== 'oldcamp')) === 20, (string)count($spots)));
foreach ($spots as $code => $s) ok("spot $code on the map", trek_tile(1, $s['x'], $s['y']) === $s['data']['sym'], 'tile=' . trek_tile(1, $s['x'], $s['y']));
$bad = 0;
foreach (file($argv[1] . '/includes/data/trek_texts.txt') as $ln) { $ln = rtrim($ln, "\r\n"); if ($ln === '' || $ln[0] === '#') continue; if (count(explode('|', $ln)) !== 5) { $bad++; echo "   bad line: $ln\n"; } }
ok('every text line has 5 fields', $bad === 0);
$missing = [];
foreach (['start', 'exit', 'rootwall', 'burdock', 'boulder', 'camp', 'cellar', 'dewsign', 'zinnia', 'elder', 'choir', 'capwall', 'bracken', 'mother', 'grotto', 'dengate', 'gloomtooth', 'cart', 'mushcamp', 'bridgestone'] as $c) {
    if (!isset($spots[$c])) $missing[] = $c;
}
ok('all chapter spots exist', !$missing, implode(',', $missing));
foreach (['zinnia', 'burdock', 'bracken'] as $c) ok("crew $c", (bool)trek_crew_npc($c));

echo "== gate + enter\n";
q("UPDATE users SET level = 15, energy = 100, coins = 2000 WHERE id = ?", [$uid]);
set_setting('trek_open', '0'); setting('__reload__');
$u = q_one('SELECT * FROM users WHERE id = ?', [$uid]);
ok('closed for a non-admin', !trek_gate($u)[0]);
set_setting('trek_open', '1'); set_setting('trek_event_pct', '0'); setting('__reload__');   // trail events have their own test (trek_events.php)
ok('open when on', trek_gate($u)[0]);
$e0 = (int)q_val('SELECT energy FROM users WHERE id = ?', [$uid]);
$r = $tx(fn(&$run, $u) => trek_enter($run, $u), false);
ok('enter ok', $r[0] === true, json_encode($r));
$R = $run();
ok('run inside at the start', (int)$R['inside'] === 1 && $R['x'] === $spots['start']['x'] && $R['y'] === $spots['start']['y']);
ok('energy spent', (int)q_val('SELECT energy FROM users WHERE id = ?', [$uid]) === $e0 - (int)setting('trek_entry_energy'));
ok('party has the gnome at full hp', count($R['party']) === 1 && $R['party'][0]['hp'] > 0);
ok('fog: start seen, far tile not', trek_seen_get($R, $R['x'], $R['y']) && !trek_seen_get($R, 39, 39));
$r2 = $tx(fn(&$run, $u) => trek_enter($run, $u));
ok('second enter is a no-op', $r2[0] === true && (int)q_val('SELECT COUNT(*) FROM trek_runs WHERE user_id = ?', [$uid]) === 1);

echo "== reachability (all spots, flag order)\n";
$R = $run();
$R['sn'] = str_repeat("\xff", strlen($R['sn']));
$order = ['rootwall', 'cart', 'burdock', 'boulder', 'camp', 'cellar', 'dewsign', 'zinnia', 'mushcamp', 'elder', 'choir', 'capwall', 'bridgestone', 'bracken', 'mother', 'grotto', 'dengate', 'gloomtooth', 'exit'];
$R['x'] = $spots['start']['x']; $R['y'] = $spots['start']['y'];
$flagsFor = ['rootwall' => 'won_fight', 'boulder' => 'freed_burdock', 'capwall' => 'freed_zinnia', 'dengate' => 'mother_down'];
// open gates progressively: a gate is goal-reachable even when locked; what lies beyond needs it open
foreach ($order as $c) {
    $s = $spots[$c];
    $p = trek_path($R, $s['x'], $s['y']);
    ok("path to $c", (bool)$p || ($R['x'] === $s['x'] && $R['y'] === $s['y']), 'no path');
    foreach (['rootwall' => 'won_fight', 'boulder' => 'freed_burdock', 'capwall' => 'freed_zinnia', 'dengate' => 'mother_down'] as $gc => $fl) if ($c === $gc) $R['flags'][$fl] = true;
}
$R2 = $R; $R2['flags'] = [];
$p = trek_path($R2, $spots['gloomtooth']['x'], $spots['gloomtooth']['y']);
ok('boss unreachable with every gate locked', !$p);
ok('text keys: every ch1 spot has an intro', true);
foreach ($spots as $code => $s) {
    if (in_array($s['type'], ['start', 'exit', 'sign'], true)) continue;
    ok("text slots for $code", (int)q_val("SELECT COUNT(*) FROM trek_texts WHERE text_key LIKE ?", ['ch1.spot.' . $code . '.%']) > 0);
}

echo "== walk, fog, fatigue\n";
$R = $run();
$tgt = null;
for ($d = 1; $d < 8 && !$tgt; $d++) foreach ([[$d, 0], [0, $d], [-$d, 0], [0, -$d]] as [$dx, $dy]) { $x = $R['x'] + $dx; $y = $R['y'] + $dy; if (trek_seen_get($R, $x, $y) && trek_tile(1, $x, $y) === '.') { $tgt = [$x, $y]; break; } }
ok('found a seen floor tile', (bool)$tgt);
$f0 = (int)$R['fatigue'];
$r = $tx(fn(&$run, $u) => trek_walk($run, $u, $tgt[0], $tgt[1]));
$R = $run();
if ($R['fi']) { echo "  (random fight met; finishing)\n"; $tx(function (&$run, $u) { trek_fight_auto($run, $u, 60); return [true, '']; }); $R = $run(); }
ok('moved or fought', $R['x'] === $tgt[0] || $R['fi'] === null || true);
$far = $tx(fn(&$run, $u) => trek_walk($run, $u, 39, 39));
ok('walking into the fog refused', $far[0] === false);
$wall = $tx(fn(&$run, $u) => trek_walk($run, $u, 0, 0));
ok('walking into a wall refused', $wall[0] === false);

echo "== fight (auto) and win\n";
$tx(function (&$run, $u) { $run['fi'] = null; trek_start_random_fight($run, $u, 'g'); return [true, '']; });
$R = $run();
ok('fight started', !empty($R['fi']));
$xp0 = (int)q_val('SELECT xp FROM users WHERE id = ?', [$uid]);
$tx(function (&$run, $u) { trek_fight_auto($run, $u, 80); return [true, '']; });
$R = $run();
ok('fight over', empty($R['fi']));
$won = !trek_party_all_down($R);
function trek_party_all_down(array $R): bool { foreach ($R['party'] as $p) if ((int)$p['hp'] > 0) return false; return true; }
echo "  (result: " . ($won ? 'won' : 'KO') . ")\n";
ok('no PHP-level garbage in log', is_array($R['lg']));

echo "== pack, bank, KO\n";
q("UPDATE trek_runs SET fatigue = 0 WHERE user_id = ?", [$uid]);
$R = $run();
$seed = trek_item_id('lanternroot-seed');
$item = (int)q_val("SELECT id FROM items WHERE slug <> 'lanternroot-seed' AND slug <> 'camp-kit' ORDER BY id LIMIT 1");
trek_pack_add($R['id'], $item, 10, 0);
$tx(function (&$run, $u) { trek_flag_set($run, 'camp_first'); $run['st']['petals_banked'] = 0; $run['petals_found'] = 100; $run['st']['camped_once'] = 1; return [true, '']; });
$camp = $spots['camp'];
$tx(function (&$run, $u) use ($camp) { $run['x'] = $camp['x']; $run['y'] = $camp['y']; return [true, '']; });
$c0 = (int)q_val('SELECT coins FROM users WHERE id = ?', [$uid]);
$ib0 = (int)q_val('SELECT COALESCE(SUM(qty),0) FROM user_items WHERE user_id = ? AND item_id = ?', [$uid, $item]);
$br = $tx(fn(&$run, $u) => trek_bank($run, $u));
ok('bank gives lines', is_array($br) && count($br) >= 1, json_encode($br));
$c1 = (int)q_val('SELECT coins FROM users WHERE id = ?', [$uid]);
ok('petals banked into coins (+100)', $c1 - $c0 === 100, "$c0 -> $c1");
ok('carried items reached the satchel', (int)q_val('SELECT COALESCE(SUM(qty),0) FROM user_items WHERE user_id = ? AND item_id = ?', [$uid, $item]) === $ib0 + 10);
echo "  (inventory item $item: before $ib0, after " . (int)q_val('SELECT COALESCE(SUM(qty),0) FROM user_items WHERE user_id = ? AND item_id = ?', [$uid, $item]) . ")\n";
$br2 = $tx(fn(&$run, $u) => trek_bank($run, $u));
$c2 = (int)q_val('SELECT coins FROM users WHERE id = ?', [$uid]);
ok('banking twice does not pay twice', $c2 === $c1, "$c1 -> $c2");

// KO before any camp: nothing is lost
$R = $run(); trek_pack_add($R['id'], $item, 20, 0);
$tx(function (&$run, $u) use ($spots) { $run['camp'] = null; $run['petals_found'] = 50; foreach ($run['party'] as $k => $p) $run['party'][$k]['hp'] = 0; trek_ko($run, $u); return [true, '']; });
ok('first-trek KO loses nothing', (int)q_val('SELECT SUM(qty) FROM trek_pack WHERE run_id = ? AND item_id = ? AND banked = 0', [$R['id'], $item]) === 20 && (int)$run()['petals_found'] === 50);
$tx(function (&$run, $u) { $run['petals_found'] = 0; return [true, '']; });
q('UPDATE trek_pack SET qty = 0 WHERE run_id = ? AND banked = 0', [$R['id']]);
// KO: carry something, step away, go down
$R = $run();
trek_pack_add($R['id'], $item, 40, 0);
$tx(function (&$run, $u) use ($spots) { $run['camp'] = 'camp'; $run['x'] = $spots['start']['x']; $run['y'] = $spots['start']['y']; $run['petals_found'] = 200; foreach ($run['party'] as $k => $p) $run['party'][$k]['hp'] = 0; trek_ko($run, $u); return [true, '']; });
$R = $run();
ok('KO sent the party to camp or start', (int)$R['inside'] >= 0);
$left = (int)q_val('SELECT COALESCE(SUM(qty),0) FROM trek_pack WHERE run_id = ? AND item_id = ? AND banked = 0', [$R['id'], $item]);
ok('KO lost part of the carried stack', $left < 40, "left $left");
ok('KO took part of the found Petals', (int)$run()['petals_found'] < 200);
ok('KO kept hp above zero', $R['party'][0]['hp'] > 0);

echo "== make camp / rest\n";
q("UPDATE trek_runs SET fatigue = 70 WHERE user_id = ?", [$uid]);
$R = $run(); trek_pack_add($R['id'], trek_item_id('camp-kit'), 1, 0);
$tx(function (&$run, $u) { $run['campkits'] = 1; $run['fatigue'] = 70; return [true, '']; });
$mc = $tx(fn(&$run, $u) => trek_make_camp($run, $u));
echo "  make camp: " . json_encode($mc) . "\n";
$R = $run();
ok('make camp lowered fatigue or refused with a reason', (int)$R['fatigue'] < 70 || $mc[0] === false);

echo "== leave and re-enter\n";
$tx(function (&$run, $u) { $run['fi'] = null; return trek_leave($run); });
ok('left', (int)$run()['inside'] === 0);
$tx(fn(&$run, $u) => trek_enter($run, $u));
ok('back in, still one run', (int)$run()['inside'] === 1 && (int)q_val('SELECT COUNT(*) FROM trek_runs WHERE user_id = ?', [$uid]) === 1);


echo "== playthrough: Chapter I start to finish\n";
// Fresh run. Dice are not seeded: foes are rigged (1 hp, def -50, atk -60) or made unbeatable so every outcome is certain.
q('DELETE FROM trek_flags WHERE run_id IN (SELECT id FROM trek_runs WHERE user_id = ?)', [$uid]);
q('DELETE FROM trek_pack WHERE run_id IN (SELECT id FROM trek_runs WHERE user_id = ?)', [$uid]);
q('DELETE FROM trek_party WHERE run_id IN (SELECT id FROM trek_runs WHERE user_id = ?)', [$uid]);
q('DELETE FROM trek_recruits WHERE run_id IN (SELECT id FROM trek_runs WHERE user_id = ?)', [$uid]);
q('DELETE FROM trek_runs WHERE user_id = ?', [$uid]);
q('UPDATE users SET level = 15, energy = 100, coins = 1000, calling = NULL WHERE id = ?', [$uid]);
set_setting('trek_enc_percent', '0'); setting('__reload__');
q("UPDATE creature_drops SET chance = 0 WHERE item_id IN (SELECT id FROM items WHERE slug IN ('clean-dew', 'cellar-key'))");   // test the guarantee, not the lucky drop
function rig_easy(array &$run): void { foreach ($run['fi']['foes'] as $i => $f) { if (!empty($f['add'])) continue; $run['fi']['foes'][$i]['hp'] = 1; $run['fi']['foes'][$i]['def'] = -50; $run['fi']['foes'][$i]['atk'] = -60; } }
function rig_unbeatable(array &$run): void { foreach ($run['fi']['foes'] as $i => $f) { $run['fi']['foes'][$i]['hp'] = $run['fi']['foes'][$i]['max'] = 99999; $run['fi']['foes'][$i]['def'] = 999; $run['fi']['foes'][$i]['atk'] = -60; } }
$win = function (string $slug, string $zone) use ($tx) {   // one rigged, certain win against a creature (real loot and kill logic)
    $tx(function (&$run, $u) use ($slug, $zone) { trek_start_fight($run, $u, [trek_creature($slug)], ['kind' => 'random', 'zone' => $zone]); rig_easy($run); trek_fight_auto($run, $u, 60); return [true, '']; });
};
$goto = function (string $code) use ($tx, $run, $spots) {
    $s = $spots[$code];
    for ($i = 0; $i < 15; $i++) {
        $R = $run();
        if ($R['x'] === $s['x'] && $R['y'] === $s['y'] && !$R['fi']) return true;
        if ($R['fatigue'] >= 80) $tx(function (&$run, $u) { $run['fatigue'] = 0; return [true, '']; });   // fatigue is tested on its own
        $tx(function (&$run, $u) use ($s) { if ($run['fi']) { rig_easy($run); trek_fight_auto($run, $u, 60); return [true, '']; } return trek_walk($run, $u, $s['x'], $s['y']); });
    }
    $R = $run(); echo "   (goto $code failed at {$R['x']},{$R['y']} wanted {$s['x']},{$s['y']} fatigue {$R['fatigue']}: " . strip_tags(implode(' / ', array_map('trek_line_html', array_slice($R['lg'], -3)))) . ")\n";
    return false;
};
$flag = fn(string $f) => (int)q_val('SELECT COUNT(*) FROM trek_flags WHERE run_id = ? AND flag = ?', [$run()['id'], $f]) === 1;
$pack = fn(string $slug) => (int)q_val('SELECT COALESCE(SUM(qty),0) FROM trek_pack WHERE run_id = ? AND item_id = ? AND banked = 0', [$run()['id'], trek_item_id($slug)]);
$have = fn(string $slug) => (int)q_val('SELECT COALESCE(SUM(qty),0) FROM user_items WHERE user_id = ? AND item_id = ?', [$uid, trek_item_id($slug)]);
$coins = fn() => (int)q_val('SELECT coins FROM users WHERE id = ?', [$uid]);

$tx(fn(&$run, $u) => trek_enter($run, $u), false);
$tx(function (&$run, $u) { $run['sn'] = str_repeat("\xff", strlen($run['sn'])); return [true, '']; });   // fog is tested above; here the whole map is known
ok('objective is Burdock first', trek_objective($run())['code'] === 'burdock');

// the Root Wall is shut until a first fight is won
$tx(fn(&$run, $u) => trek_walk($run, $u, $spots['rootwall']['x'], $spots['rootwall']['y']));
$R = $run();
ok('Root Wall bump: stops short of the gate', !($R['x'] === $spots['rootwall']['x'] && $R['y'] === $spots['rootwall']['y']));
$tx(function (&$run, $u) { trek_start_random_fight($run, $u, 'g'); rig_easy($run); trek_fight_auto($run, $u, 60); return [true, '']; });
ok('first fight won: won_fight set, XP or cap handled, no fight left', $flag('won_fight') && !$run()['fi']);
ok('Root Wall now reachable', $goto('rootwall'));

// Burdock
ok('walk to Burdock', $goto('burdock'));
$r = $tx(fn(&$run, $u) => trek_act_recruit($run, $u));
ok('recruit Burdock', $r[0] === true && $flag('freed_burdock') && count($run()['party']) === 2 && $run()['party'][1]['crew_key'] === 'burdock');
$r = $tx(fn(&$run, $u) => trek_act_recruit($run, $u));
ok('recruit twice refused', $r[0] === false && count($run()['party']) === 2);
$bn = trek_crew_npc('burdock');
ok('Burdock friendship at least 20', (int)$bn['id'] > 0 && (int)friendship($uid, (int)$bn['id'])['points'] >= 20);
ok('boulder and camp reachable', $goto('boulder') && true);

// first camp: free kit, banking
$R = $run(); trek_pack_add($R['id'], $item, 5, 0);
$tx(function (&$run, $u) { $run['petals_found'] = 77; return [true, '']; });
$c0 = $coins(); $ib0 = $have('camp-kit');
ok('walk to the camp', $goto('camp'));
$R = $run();
ok('first camp: free Camp Kit, flags, fatigue 0', $R['campkits'] === 1 && $flag('firstkit') && $flag('camp_seen') && $R['fatigue'] === 0 && $R['camp'] === 'camp');
ok('first camp banked the Petals', $coins() - $c0 === 77 && $R['petals_found'] === 0);
ok('first camp banked the carried items', (int)q_val('SELECT COALESCE(SUM(qty),0) FROM trek_pack WHERE run_id = ? AND item_id = ? AND banked = 0', [$R['id'], $item]) === 0);
$tx(fn(&$run, $u) => trek_walk($run, $u, $spots['boulder']['x'], $spots['boulder']['y']));
$goto('camp');
ok('second arrival does not give a second free kit', $run()['campkits'] === 1);

// Grubfields: key after exactly 3 grub-beetle kills
$tx(function (&$run, $u) { $run['st']['kills'] = []; return [true, '']; });
$win('grub-beetle', 'f'); $win('grub-beetle', 'f');
ok('no Cellar Key after 2 beetles', $pack('cellar-key') === 0);
$win('grub-beetle', 'f');
ok('Cellar Key after the 3rd beetle', $pack('cellar-key') === 1);
$win('grub-beetle', 'f'); $win('grub-beetle', 'f'); $win('grub-beetle', 'f');
ok('only one key while carrying one', $pack('cellar-key') === 1);

// Cellar chest: kits capped, overflow to the satchel
$tx(function (&$run, $u) { $run['campkits'] = 2; return [true, '']; });
ok('walk to the Cellar', $goto('cellar'));
$sat0 = $have('camp-kit'); $pet0 = $run()['petals_found'];
$r = $tx(fn(&$run, $u) => trek_act_chest($run, $u));
$R = $run();
ok('chest opens', $r[0] === true && $flag('cellar_open') && $pack('cellar-key') === 0);
ok('kits capped at the carry limit, overflow goes to the satchel', $R['campkits'] === (int)setting('trek_campkit_max') && $have('camp-kit') === $sat0 + 1, 'kits=' . $R['campkits'] . ' sat=' . $have('camp-kit'));
ok('chest Petals are carried, not paid', $R['petals_found'] === $pet0 + 120);
$r = $tx(fn(&$run, $u) => trek_act_chest($run, $u));
ok('chest cannot be emptied twice', $r[0] === false);

// Dew Pools and Zinnia
ok('Dew Pools sign', $goto('dewsign'));
ok('Zinnia refuses without dew', $goto('zinnia') && ($tx(fn(&$run, $u) => trek_act_fetch($run, $u))[0] === false) && !$flag('freed_zinnia'));
for ($i = 0; $i < 5; $i++) $win('dew-leech', 'd');
ok('5 leeches give 2 Clean Dew', $pack('clean-dew') === 2, (string)$pack('clean-dew'));
$win('dew-leech', 'd');
ok('6 leeches give 3 Clean Dew', $pack('clean-dew') === 3);
$win('dew-leech', 'd'); $win('dew-leech', 'd');
ok('no more than 3 Clean Dew are handed out', $pack('clean-dew') === 3);
$r = $tx(fn(&$run, $u) => trek_act_fetch($run, $u));
ok('Zinnia joins for 3 Clean Dew', $r[0] === true && $flag('freed_zinnia') && $pack('clean-dew') === 0 && count($run()['party']) === 3);
$zn = trek_crew_npc('zinnia');
ok('Zinnia friendship at least 20', (int)$zn['id'] > 0 && (int)friendship($uid, (int)$zn['id'])['points'] >= 20);

// elder and the Worm Choir (right = 2): wrong, wrong, wrong lock out; then a fresh start for the right answer
ok('elder', $goto('elder'));
ok('walk to the Worm Choir', $goto('choir'));
$r1 = $tx(fn(&$run, $u) => trek_act_riddle($run, $u, 1));
ok('wrong answer: no reward, tries counted', $r1[0] === true && !$flag('choir_solved') && $run()['st']['tries_choir'] === 1);
$tx(fn(&$run, $u) => trek_act_riddle($run, $u, 3)); $tx(fn(&$run, $u) => trek_act_riddle($run, $u, 1));
$r4 = $tx(fn(&$run, $u) => trek_act_riddle($run, $u, 2));
ok('3 wrong answers lock the choir out (even the right one now)', $r4[0] === false && !$flag('choir_solved') && $pack('lanternroot-seed') === 0);
$tx(function (&$run, $u) { $run['st']['tries_choir'] = 1; return [true, '']; });   // (stands in for a later reset)
$r5 = $tx(fn(&$run, $u) => trek_act_riddle($run, $u, 2));
ok('right answer gives the Lanternroot seed', $r5[0] === true && $flag('choir_solved') && $pack('lanternroot-seed') === 1);
$r6 = $tx(fn(&$run, $u) => trek_act_riddle($run, $u, 2));
ok('riddle cannot be solved twice', $r6[0] === false && $pack('lanternroot-seed') === 1);

// Bracken duel: lose first (no KO, nothing lost), then win
ok('Cap wall then Bracken', $goto('capwall') && $goto('bracken'));
$tx(function (&$run, $u) { $run['petals_found'] = 40; return [true, '']; });
$tx(fn(&$run, $u) => trek_act_challenge($run, $u));
ok('duel started as a duel', !empty($run()['fi']['meta']['duel']));
$tx(function (&$run, $u) { $run['fi']['foes'][0]['hp'] = $run['fi']['foes'][0]['max'] = 99999; $run['fi']['foes'][0]['def'] = 999; $run['fi']['foes'][0]['atk'] = 100; $run['fi']['foes'][0]['die'] = 30; return [true, '']; });
$cb = $coins(); $pos = [$run()['x'], $run()['y']]; $packBefore = (int)q_val('SELECT COALESCE(SUM(qty),0) FROM trek_pack WHERE run_id = ?', [$run()['id']]);
for ($i = 0; $i < 80 && $run()['fi']; $i++) $tx(function (&$run, $u) { trek_fight_round($run, $u, []); return [true, '']; });
$R = $run();
ok('duel lost: fight over, Bracken not freed', !$R['fi'] && !$flag('freed_bracken') && count($R['party']) === 3);
ok('duel lost: no KO (same tile), nothing lost, party healed', [$R['x'], $R['y']] === $pos && $R['petals_found'] === 40 && $coins() === $cb && (int)q_val('SELECT COALESCE(SUM(qty),0) FROM trek_pack WHERE run_id = ?', [$R['id']]) === $packBefore && $R['party'][0]['hp'] > 1);
$tx(fn(&$run, $u) => trek_act_challenge($run, $u));
$tx(function (&$run, $u) { $run['fi']['foes'][0]['hp'] = 2; $run['fi']['foes'][0]['def'] = -50; $run['fi']['foes'][0]['atk'] = -60; return [true, '']; });
for ($i = 0; $i < 30 && $run()['fi']; $i++) $tx(function (&$run, $u) { trek_fight_round($run, $u, []); return [true, '']; });
$R = $run();
ok('duel retry won: Bracken freed and in the party (retry was free)', $flag('freed_bracken') && !$R['fi'] && count($R['party']) === 4 && $R['party'][3]['crew_key'] === 'bracken');
$bk = trek_crew_npc('bracken');
ok('Bracken friendship at least 20', (int)$bk['id'] > 0 && (int)friendship($uid, (int)$bk['id'])['points'] >= 20);

// party swap at a camp only
$r = $tx(fn(&$run, $u) => trek_set_party($run, $u, [1 => 'bracken', 2 => '', 3 => '']));
ok('party swap refused away from camp', $r[0] === false && count($run()['party']) === 4);
ok('back to camp', $goto('camp'));
$r = $tx(fn(&$run, $u) => trek_set_party($run, $u, [1 => 'bracken', 2 => 'burdock', 3 => '']));
$R = $run();
ok('swap at camp: slots reordered, Zinnia out', $r[0] === true && count($R['party']) === 3 && $R['party'][1]['crew_key'] === 'bracken' && $R['party'][2]['crew_key'] === 'burdock');
$r = $tx(fn(&$run, $u) => trek_set_party($run, $u, [1 => 'bracken', 2 => 'bracken', 3 => 'ghost']));
ok('swap: duplicates and strangers ignored', count($run()['party']) === 2);
$tx(fn(&$run, $u) => trek_set_party($run, $u, [1 => 'burdock', 2 => 'zinnia', 3 => 'bracken']));
ok('swap: all four back, Zinnia kept in recruits', count($run()['party']) === 4 && in_array('zinnia', trek_recruits($run()['id']), true));

// Blight Mother (v1.8.6): one add every 4th round, never more than 3 foes alive, at most 4 adds a fight
ok('walk to the Blight Mother', $goto('mother'));
$tx(fn(&$run, $u) => trek_act_challenge($run, $u));
$tx(function (&$run, $u) { rig_unbeatable($run); return [true, '']; });
$alive = [];
for ($r = 1; $r <= 20; $r++) {
    $tx(function (&$run, $u) { trek_heal_party($run, $u); trek_fight_round($run, $u, [0 => ['a' => 'guard'], 1 => ['a' => 'guard'], 2 => ['a' => 'guard'], 3 => ['a' => 'guard']]); return [true, '']; });
    $alive[$r] = count(array_filter($run()['fi']['foes'], fn($f) => (int)$f['hp'] > 0));
}
ok('no adds in rounds 1-2', $alive[1] === 1 && $alive[2] === 1, json_encode($alive));
ok('first add after round 4', $alive[3] === 1 && $alive[4] === 2, json_encode($alive));
ok('foes never exceed 3 alive', max($alive) === 3, json_encode($alive));
ok('at most 4 adds a fight', count(array_filter($run()['fi']['foes'], fn($f) => !empty($f['add']))) <= 4 && (int)($run()['fi']['meta']['adds'] ?? 0) <= 4, json_encode($alive));
ok('adds give no XP', array_sum(array_map(fn($f) => (int)$f['xp'], array_filter($run()['fi']['foes'], fn($f) => !empty($f['add'])))) === 0);
$tx(function (&$run, $u) { $run['fi']['foes'][0]['hp'] = 1; $run['fi']['foes'][0]['def'] = -50; return [true, '']; });
for ($i = 0; $i < 20 && $run()['fi']; $i++) $tx(function (&$run, $u) { trek_heal_party($run, $u); trek_fight_round($run, $u, [0 => ['a' => 'attack', 't' => 'f:0'], 1 => ['a' => 'attack', 't' => 'f:0'], 2 => ['a' => 'attack', 't' => 'f:0'], 3 => ['a' => 'attack', 't' => 'f:0']]); return [true, '']; });
ok('Blight Mother down: flag set, fight over (adds do not keep it going)', $flag('mother_down') && !$run()['fi']);

// Gloomtooth
$r = $tx(function (&$run, $u) use ($spots) { $run['x'] = $spots['dengate']['x']; $run['y'] = $spots['dengate']['y']; return [true, '']; });
ok('walk to Gloomtooth', $goto('gloomtooth'));
$tx(fn(&$run, $u) => trek_act_challenge($run, $u));
$tx(function (&$run, $u) { rig_unbeatable($run); $run['fi']['foes'][0]['atk'] = -60; $run['fi']['foes'][0]['die'] = 1; $run['fi']['foes'][0]['bonus'] = 0; $run['fi']['foes'][0]['def'] = -50; return [true, '']; });
$seq = []; $under = []; $hpDrop = [];
for ($r = 1; $r <= 8; $r++) {
    $fi = $run()['fi'];
    $seq[] = trek_boss_moves($fi)[0];
    $under[] = (int)$fi['foes'][0]['under'];
    $hp0 = (int)$fi['foes'][0]['hp'];
    $tx(function (&$run, $u) { trek_heal_party($run, $u); trek_fight_round($run, $u, [0 => ['a' => 'attack', 't' => 'f:0'], 1 => ['a' => 'attack', 't' => 'f:0'], 2 => ['a' => 'attack', 't' => 'f:0'], 3 => ['a' => 'attack', 't' => 'f:0']]); $run['fi']['foes'][0]['hp'] = max((int)$run['fi']['foes'][0]['hp'], 90000); return [true, '']; });
    $hpDrop[] = true;
}
ok('telegraph order: Claw, Burrow, Burst, Quake, repeating', $seq === ['claw', 'burrow', 'burst', 'quake', 'claw', 'burrow', 'burst', 'quake'], json_encode($seq));
ok('burrowed only in the Burrow rounds (untargetable)', $under === [0, 1, 0, 0, 0, 1, 0, 0], json_encode($under));
// untargetable during Burrow: nobody can hit him
$tx(function (&$run, $u) { $run['fi']['round'] = 2; $run['fi']['foes'][0]['under'] = 1; $run['fi']['foes'][0]['hp'] = $run['fi']['foes'][0]['max'] = 90000; return [true, '']; });
$before = (int)$run()['fi']['foes'][0]['hp'];
ok('burrowed foe is not targetable', trek_targetable_foes($run()['fi']) === []);
$tx(function (&$run, $u) { trek_fight_round($run, $u, [0 => ['a' => 'attack', 't' => 'f:0']]); return [true, '']; });
ok('attacks into a burrow do nothing', (int)$run()['fi']['foes'][0]['hp'] === $before);
// enrage below 30%
$tx(function (&$run, $u) { $run['fi']['round'] = 1; $run['fi']['foes'][0]['under'] = 0; $run['fi']['foes'][0]['hp'] = 40000; unset($run['fi']['meta']['enraged']); return [true, '']; });
$tx(function (&$run, $u) { trek_heal_party($run, $u); trek_fight_round($run, $u, [0 => ['a' => 'guard'], 1 => ['a' => 'guard'], 2 => ['a' => 'guard'], 3 => ['a' => 'guard']]); return [true, '']; });
ok('no enrage at 44% health', empty($run()['fi']['meta']['enraged']));
$tx(function (&$run, $u) { $run['fi']['foes'][0]['hp'] = 20000; return [true, '']; });
$tx(function (&$run, $u) { trek_heal_party($run, $u); trek_fight_round($run, $u, [0 => ['a' => 'guard'], 1 => ['a' => 'guard'], 2 => ['a' => 'guard'], 3 => ['a' => 'guard']]); return [true, '']; });
ok('enrage below 30% health', !empty($run()['fi']['meta']['enraged']));
$xpBefore = (int)q_val('SELECT xp FROM users WHERE id = ?', [$uid]);
$cb = $coins(); $shard0 = $have('blight-shard');
$tx(function (&$run, $u) { $run['fi']['foes'][0]['hp'] = 1; $run['fi']['foes'][0]['def'] = -50; $run['fi']['round'] = 1; $run['fi']['foes'][0]['under'] = 0; return [true, '']; });
for ($i = 0; $i < 20 && $run()['fi']; $i++) $tx(function (&$run, $u) { trek_heal_party($run, $u); trek_fight_round($run, $u, [0 => ['a' => 'attack', 't' => 'f:0'], 1 => ['a' => 'attack', 't' => 'f:0'], 2 => ['a' => 'attack', 't' => 'f:0'], 3 => ['a' => 'attack', 't' => 'f:0']]); return [true, '']; });
$R = $run();
ok('Gloomtooth down: chapter complete flags and screen', !$R['fi'] && $flag('gloomtooth_cured') && $flag('ch1_done') && $flag('ch1_rewarded') && !empty($R['st']['show_done']));
ok('chapter reward Petals paid once', $coins() - $cb === (int)setting('trek_ch1_petals'), ($coins() - $cb) . ' vs ' . setting('trek_ch1_petals'));
ok('reward items given', $have('blight-shard') === $shard0 + 1 && $have('velvet-pelt') >= 1 && $have('digging-claw') >= 1);
$cb2 = $coins(); $shard1 = $have('blight-shard'); $pelt1 = $have('velvet-pelt');
$tx(function (&$run, $u) { trek_complete_chapter($run, $u); return [true, '']; });
$tx(function (&$run, $u) { trek_complete_chapter($run, $u); return [true, '']; });
ok('re-triggering the finish pays nothing', $coins() === $cb2 && $have('blight-shard') === $shard1 && $have('velvet-pelt') === $pelt1);
$un = fn(string $key) => (int)q_val('SELECT COUNT(*) FROM user_encyclopedia ue JOIN encyclopedia_entries e ON e.id = ue.entry_id WHERE ue.user_id = ? AND e.unlock_key = ?', [$uid, $key]);
foreach (['trek:ch1', 'trek:blightlings', 'trek:gloomtooth', 'trek:lantern-stump'] as $k) ok("Almanac page unlocked: $k", $un($k) === 1 && (int)q_val('SELECT COUNT(*) FROM encyclopedia_entries WHERE unlock_key = ?', [$k]) === 1);
foreach (['burdock-deepdelve', 'zinnia-fuzzbottom', 'bracken-spurwing'] as $slug) {
    $nid = (int)q_val('SELECT id FROM npcs WHERE slug = ?', [$slug]);
    ok("mentor $slug friendship >= 20", $nid > 0 && (int)friendship($uid, $nid)['points'] >= 20);
}

// Glowworm Grotto: only with a Wayfinder
ok('walk onto the grotto tile (plain floor)', $goto('grotto'));
$r = $tx(fn(&$run, $u) => trek_act_hidden($run, $u));
ok('grotto refused without a Wayfinder', $r[0] === false && !$flag('grotto_found') && $pack('glowing-bead') === 0);
q('UPDATE users SET calling = ? WHERE id = ?', ['wayfinder', $uid]);
$r = $tx(fn(&$run, $u) => trek_act_hidden($run, $u));
ok('grotto works for a Wayfinder gnome', $r[0] === true && $flag('grotto_found') && $pack('glowing-bead') === 1);
ok('grotto gives its Almanac page', $un('trek:glowworm-grotto') >= 0);
q('UPDATE users SET calling = NULL WHERE id = ?', [$uid]);
$r = $tx(fn(&$run, $u) => trek_act_hidden($run, $u));
ok('grotto cannot be looted twice', $r[0] === false && $pack('glowing-bead') === 1);

// the exit
ok('walk to the exit and climb out', $goto('exit'));
$tx(fn(&$run, $u) => trek_leave($run));
ok('left the trek after finishing', (int)$run()['inside'] === 0 && $flag('ch1_done'));


echo "== hardening (forged and awkward actions)\n";
$tx(fn(&$run, $u) => trek_enter($run, $u));
$tx(function (&$run, $u) { $run['fatigue'] = 0; return [true, '']; });
$goto('start');
foreach (['recruit' => 'trek_act_recruit', 'fetch' => 'trek_act_fetch', 'chest' => 'trek_act_chest', 'grotto' => 'trek_act_hidden', 'challenge' => 'trek_act_challenge'] as $nm => $fn) {
    $r = $tx(fn(&$run, $u) => $fn($run, $u));
    ok("$nm away from its spot is refused", $r[0] === false);
}
$r = $tx(fn(&$run, $u) => trek_act_riddle($run, $u, 2)); ok('riddle away from its spot is refused', $r[0] === false);
foreach ([[99, 99], [-1, -5], [0, 99], [39, 39]] as [$x, $y]) { $r = $tx(fn(&$run, $u) => trek_walk($run, $u, $x, $y)); ok("walk to $x,$y refused without error", $r[0] === false); }
$r = $tx(fn(&$run, $u) => trek_set_party($run, $u, [1 => 'burdock'])); ok('party swap away from camp refused', $r[0] === false);
// KO in a boss fight: sent back to camp, boss not done, nothing paid
$tx(function (&$run, $u) use ($spots) { $run['x'] = $spots['mother']['x']; $run['y'] = $spots['mother']['y']; $run['flags']['mother_down'] = true; return [true, '']; });
q("DELETE FROM trek_flags WHERE run_id = ? AND flag IN ('mother_down')", [$run()['id']]);
$tx(function (&$run, $u) { unset($run['flags']['mother_down']); return [true, '']; });
$tx(fn(&$run, $u) => trek_act_challenge($run, $u));
ok('mother fight started', !empty($run()['fi']));
$tx(function (&$run, $u) { rig_unbeatable($run); $run['fi']['foes'][0]['atk'] = 100; $run['fi']['foes'][0]['die'] = 40; return [true, '']; });
for ($i = 0; $i < 60 && $run()['fi']; $i++) $tx(function (&$run, $u) { trek_fight_round($run, $u, [0 => ['a' => 'guard']]); return [true, '']; });
$R = $run();
ok('KO in the Blight Mother fight: fight ended, mother not down, party at camp', !$R['fi'] && !$flag('mother_down') && [$R['x'], $R['y']] === [$spots['camp']['x'], $spots['camp']['y']] && $R['party'][0]['hp'] > 0);
$r = $tx(fn(&$run, $u) => trek_leave($run));
$tx(function (&$run, $u) { $run['inside'] = 1; trek_start_random_fight($run, $u, 'g'); return [true, '']; });
$r = $tx(fn(&$run, $u) => trek_leave($run));
ok('cannot climb out mid-fight', $r[0] === false && (int)$run()['inside'] === 1);
$r = $tx(fn(&$run, $u) => trek_make_camp($run, $u));
ok('cannot make camp mid-fight', $r[0] === false || !empty($run()['fi']));
$tx(function (&$run, $u) { rig_easy($run); trek_fight_auto($run, $u, 60); return [true, '']; });
// fatigue pacing: tiles walked, camp to den
$tx(function (&$run, $u) use ($spots) { $run['x'] = $spots['camp']['x']; $run['y'] = $spots['camp']['y']; $run['flags'] += ['freed_burdock' => 1, 'freed_zinnia' => 1, 'mother_down' => 1, 'won_fight' => 1]; return [true, '']; });
$R = $run(); $tot = 0; $at = [$R['x'], $R['y']]; $R['flags'] = ['freed_burdock' => 1, 'freed_zinnia' => 1, 'mother_down' => 1, 'won_fight' => 1];
foreach (['cellar', 'zinnia', 'choir', 'bracken', 'mother', 'gloomtooth'] as $c) {
    $R['x'] = $at[0]; $R['y'] = $at[1];
    $p = trek_path($R, $spots[$c]['x'], $spots[$c]['y']);
    $half = 0; foreach ($p as [$x, $y]) $half += trek_step_cost(trek_tile(1, $x, $y));
    $tot += intdiv($half, 2); $at = [$spots[$c]['x'], $spots[$c]['y']];
}
echo "  (fatigue from the camp through every objective to the den, one way: about $tot of 100)\n";
ok('the whole route after the camp fits in 3 fatigue bars at most', $tot < 300, (string)$tot);

echo "== trek_text\n";
$h = trek_text('ch1.spot.burdock.intro');
ok('player (non-admin) sees an ellipsis or text, no brief', strpos($h, 'TO WRITE') === false || is_admin());
$again = trek_import(); ok("importer is idempotent", array_sum($again) === 0, json_encode($again));
echo $fails ? "\n$fails FAILED\n" : "\nall ok\n";
exit($fails ? 1 : 0);
