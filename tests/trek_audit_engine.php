<?php
// Treks audit (1.9.8 engine pass): once-only payouts, caps and rest numbers, KO loss, decoupling from the gnome level, entry points blocked
// inside a trek, old / corrupt state, a removed crew row, settings at their extremes (a short fuzz walk). Run on an installed copy:
//   php tests/trek_audit_engine.php GAME_DIR      (tests/trek_audit.sh and treks.sh do)
$_SERVER['SCRIPT_NAME'] = '/trek.php';
require $argv[1] . '/includes/bootstrap.php';
require_once $argv[1] . '/includes/trek.php';
if (session_status() !== PHP_SESSION_ACTIVE) session_start();
$fails = 0;
$warn = [];
set_exception_handler(function (Throwable $e) { if (db()->inTransaction()) db()->rollBack(); echo '  EXCEPTION ' . get_class($e) . ': ' . $e->getMessage() . ' @ ' . basename($e->getFile()) . ':' . $e->getLine() . "\n"; exit(1); });
set_error_handler(function ($no, $str, $f, $l) use (&$warn) { $warn[] = basename($f) . ':' . $l . ' ' . $str; return true; });
function ok(string $what, bool $cond, string $extra = ''): void { global $fails; echo ($cond ? '  ok   ' : '  FAIL ') . $what . ($cond ? '' : "  $extra") . "\n"; if (!$cond) $fails++; }
$uid = (int)q_val("SELECT id FROM users WHERE username = 'sprout'");
$tx = fn(callable $f, bool $need = true, ?int $ch = null) => trek_tx($uid, $f, $need, $ch);
$run = fn(?int $ch = null) => trek_load(trek_run_row($uid, $ch));
$coins = fn() => (int)q_val('SELECT coins FROM users WHERE id = ?', [$uid]);
/** A clean slate: no runs, level 15, plenty of energy and Petals, chapter 1, the default numbers. */
$fresh = function (int $chapter = 1) use ($uid) {
    foreach (['trek_flags', 'trek_pack', 'trek_party', 'trek_recruits'] as $t) q("DELETE FROM $t WHERE run_id IN (SELECT id FROM trek_runs WHERE user_id = ?)", [$uid]);
    q('DELETE FROM trek_runs WHERE user_id = ?', [$uid]);
    q('DELETE FROM trek_ms WHERE user_id = ?', [$uid]);
    q('UPDATE users SET level = 15, energy = 500, coins = 1000, calling = NULL, trek_ch = ?, trek_pet_day = NULL, trek_pet_today = 0 WHERE id = ?', [$chapter, $uid]);
    foreach (['trek_open' => '1', 'trek_event_pct' => '0', 'trek_enc_percent' => '9', 'trek_base_level' => '15', 'trek_level' => '15', 'trek_entry_energy' => '10', 'trek_petals_daily' => '150',
        'trek_campkit_max' => '3', 'trek_campkit_price' => '60', 'trek_ko_loss_pct' => '45', 'trek_ambush_pct' => '0', 'trek_cold_rest_fatigue' => '25', 'trek_event_gap' => '15'] as $k => $v) set_setting($k, $v);
    setting('__reload__');
};
/** Stand the party on a spot of chapter 1 and enter. */
$at = function (string $code, int $chapter = 1) use ($uid, $tx) {
    $tx(function (&$run, $u) use ($code, $chapter) {
        $sp = trek_spots($chapter)[$code];
        $run['inside'] = 1; $run['fi'] = null; $run['x'] = $sp['x']; $run['y'] = $sp['y'];
        $run['sn'] = str_repeat("\xff", strlen($run['sn']));
        return [true, ''];
    });
};

echo "== decoupled from the gnome level (trek_base_level only)\n";
$fresh();
$tx(fn(&$run, $u) => trek_enter($run, $u), false);
$stat = function (int $lvl) use ($uid, $tx) {
    q('UPDATE users SET level = ? WHERE id = ?', [$lvl, $uid]);
    return $tx(function (&$run, $u) {
        $s = trek_party_stats($run, $u)[0];
        $f = trek_make_foe(trek_creature('stag-beetle-patrol'), $u, 1, false, [100, 0, 0, 0], 1);
        return [$s['max'], $s['gc']['atk'], $s['gc']['ac'], $s['gc']['dmg_die'], $s['gc']['dmg_bonus'], $f['hp'], $f['atk'], $f['def']];
    });
};
ok('the gnome at level 15 and level 90 fights the same', $stat(15) === $stat(90), json_encode([$stat(15), $stat(90)]));
q('UPDATE users SET level = 15 WHERE id = ?', [$uid]);
set_setting('trek_base_level', '1'); setting('__reload__');
$low = $tx(fn(&$run, $u) => trek_party_stats($run, $u)[0]['max']);
set_setting('trek_base_level', '100'); setting('__reload__');
$high = $tx(fn(&$run, $u) => trek_party_stats($run, $u)[0]['max']);
ok('base level 1 and 100 both give sane health (' . $low . ' < ' . $high . ')', $low > 0 && $high > $low);
set_setting('trek_base_level', '15'); setting('__reload__');

echo "== rest numbers: kit 50 / half, cold 25 / quarter, camp full\n";
$fresh();
$tx(fn(&$run, $u) => trek_enter($run, $u), false);
$r = $tx(function (&$run, $u) {
    $max = trek_party_stats($run, $u)[0]['max'];
    $run['party'][0]['hp'] = 1; $run['fatigue'] = 80; $run['campkits'] = 1; $run['x'] = 3; $run['y'] = 3;
    $a = trek_make_camp($run, $u);
    $o = ['kit' => [$run['fatigue'], $run['party'][0]['hp'], $max, $run['campkits']]];
    $run['party'][0]['hp'] = 1; $run['fatigue'] = 80;
    trek_make_camp($run, $u);
    $o['cold'] = [$run['fatigue'], $run['party'][0]['hp']];
    $run['fatigue'] = 20;
    trek_apply_rest($run, $u);
    $o['floor'] = $run['fatigue'];
    return $o;
});
ok('Camp Kit: fatigue 80 -> 30, a kit used', $r['kit'][0] === 30 && $r['kit'][3] === 0, json_encode($r['kit']));
ok('Camp Kit heals half the health (1 -> ' . $r['kit'][1] . ' of ' . $r['kit'][2] . ')', $r['kit'][1] === min($r['kit'][2], 1 + (int)ceil($r['kit'][2] / 2)), json_encode($r['kit']));
ok('cold rest: fatigue 80 -> 55', $r['cold'][0] === 55, json_encode($r['cold']));
ok('cold rest heals a quarter (not half)', $r['cold'][1] === min($r['kit'][2], 1 + (int)ceil($r['kit'][2] / 4)), json_encode($r['cold']));
ok('fatigue never below 0', $r['floor'] === 0);
set_setting('trek_cold_rest_fatigue', '0'); setting('__reload__');
$r = $tx(function (&$run, $u) { $run['fatigue'] = 60; trek_make_camp($run, $u); return $run['fatigue']; });
ok('cold rest setting 0 -> removes nothing', $r === 60, (string)$r);
set_setting('trek_cold_rest_fatigue', '25'); setting('__reload__');

echo "== knock-out loses a share of the UNBANKED only\n";
$fresh();
$tx(fn(&$run, $u) => trek_enter($run, $u), false);
$bank = trek_item_id('beetle-shell');
$key = trek_item_id('cellar-key');
$r = $tx(function (&$run, $u) use ($bank, $key) {
    $run['camp'] = 'camp';
    trek_pack_add((int)$run['id'], $bank, 10);            // carried
    trek_pack_add((int)$run['id'], $bank, 7, 1);          // banked (the running total)
    trek_pack_add((int)$run['id'], $key, 2);              // quest item
    $run['petals_found'] = 100;
    $coins0 = (int)q_val('SELECT coins FROM users WHERE id = ?', [$u['id']]);
    $run['fi'] = ['round' => 1, 'foes' => [], 'mem' => [], 'snacks' => 0, 'meta' => ['kind' => 'random']];
    trek_ko($run, $u);
    return ['pet' => $run['petals_found'], 'car' => trek_pack_qty((int)$run['id'], $bank), 'key' => trek_pack_qty((int)$run['id'], $key),
        'bk' => (int)q_val('SELECT qty FROM trek_pack WHERE run_id = ? AND item_id = ? AND banked = 1', [$run['id'], $bank]), 'coins' => (int)q_val('SELECT coins FROM users WHERE id = ?', [$u['id']]) - $coins0, 'fat' => $run['fatigue'], 'fi' => $run['fi']];
});
ok('45% of 100 carried Petals lost (55 left)', $r['pet'] === 55, (string)$r['pet']);
ok('a stack of 10 loses 4 (6 left), the quest key and the banked total are untouched', $r['car'] === 6 && $r['key'] === 2 && $r['bk'] === 7, json_encode($r));
ok('the purse is not touched by a knock-out; fatigue 50; the fight is gone', $r['coins'] === 0 && $r['fat'] === 50 && $r['fi'] === null);
set_setting('trek_ko_loss_pct', '100'); setting('__reload__');
$r = $tx(function (&$run, $u) { $run['petals_found'] = 9; $run['fi'] = ['round' => 1, 'foes' => [], 'mem' => [], 'snacks' => 0, 'meta' => ['kind' => 'random']]; trek_ko($run, $u); return $run['petals_found']; });
ok('loss 100% takes it all', $r === 0, (string)$r);
set_setting('trek_ko_loss_pct', '0'); setting('__reload__');
$r = $tx(function (&$run, $u) { $run['petals_found'] = 9; $run['fi'] = ['round' => 1, 'foes' => [], 'mem' => [], 'snacks' => 0, 'meta' => ['kind' => 'random']]; trek_ko($run, $u); return $run['petals_found']; });
ok('loss 0% takes nothing', $r === 9, (string)$r);
set_setting('trek_ko_loss_pct', '45'); setting('__reload__');
$r = $tx(function (&$run, $u) { $run['camp'] = null; $run['petals_found'] = 50; $run['fi'] = ['round' => 1, 'foes' => [], 'mem' => [], 'snacks' => 0, 'meta' => ['kind' => 'random']]; trek_ko($run, $u); return $run['petals_found']; });
ok('before the first camp a knock-out costs nothing (tutorial)', $r === 50, (string)$r);

echo "== the daily Petal limit: per player, rolls over at the Hollow day\n";
$fresh();
$tx(fn(&$run, $u) => trek_enter($run, $u), false);
$r = $tx(function (&$run, $u) { return [trek_petals_capped($run, 100), trek_petals_capped($run, 100), trek_petals_capped($run, 10)]; });
ok('150 a day: 100, then 50, then 0', $r === [100, 50, 0], json_encode($r));
q('UPDATE users SET trek_pet_day = ? WHERE id = ?', [date('Y-m-d', strtotime(hollow_date('Y-m-d') . ' -1 day')), $uid]);
$r = $tx(fn(&$run, $u) => trek_petals_capped($run, 120));
ok('a new Hollow day starts again from 0', $r === 120, (string)$r);
set_setting('trek_petals_daily', '0'); setting('__reload__');
q('UPDATE users SET trek_pet_day = NULL, trek_pet_today = 0 WHERE id = ?', [$uid]);
$r = $tx(fn(&$run, $u) => trek_petals_capped($run, 50));
ok('limit 0 pays nothing', $r === 0, (string)$r);
set_setting('trek_petals_daily', '150'); setting('__reload__');
q('UPDATE users SET trek_pet_day = NULL, trek_pet_today = 0 WHERE id = ?', [$uid]);
$r = $tx(function (&$run, $u) { $run['fi'] = null; $before = (int)$run['petals_found']; trek_find_petals($run, 400); return (int)$run['petals_found'] - $before; });
ok('trail Petals (events, shops, side jobs) obey the same limit', $r === 150, (string)$r);
$r = $tx(function (&$run, $u) { $before = (int)$run['petals_found']; trek_find_petals($run, 10); return (int)$run['petals_found'] - $before; });
ok('...and nothing more once it is reached', $r === 0, (string)$r);

echo "== once-only payouts: a second tap pays nothing\n";
$fresh();
$tx(fn(&$run, $u) => trek_enter($run, $u), false);
// chapter end
$c0 = $coins();
$tx(function (&$run, $u) { $run['inside'] = 1; trek_complete_chapter($run, $u); trek_complete_chapter($run, $u); return [true, '']; });
$c1 = $coins();
ok('Chapter I end pays its Petals once (' . ($c1 - $c0) . ')', $c1 - $c0 === (int)setting('trek_ch1_petals'), (string)($c1 - $c0));
$tx(function (&$run, $u) { trek_complete_chapter($run, $u); return [true, '']; });
ok('...and a third time too', $coins() === $c1);
$xp0 = (int)q_val('SELECT xp FROM users WHERE id = ?', [$uid]);
$tx(function (&$run, $u) { foreach (['burdock', 'burdock', 'zinnia', 'zinnia'] as $m) trek_ms_award($run, $u, $m); return [true, '']; });
$xp1 = (int)q_val('SELECT xp FROM users WHERE id = ?', [$uid]);
ok('milestones pay once each (' . ($xp1 - $xp0) . ' XP)', $xp1 > $xp0 && (int)q_val('SELECT COUNT(*) FROM trek_ms WHERE user_id = ?', [$uid]) >= 2);
$tx(function (&$run, $u) { trek_ms_award($run, $u, 'burdock'); return [true, '']; });
ok('a repeat pays no XP', (int)q_val('SELECT xp FROM users WHERE id = ?', [$uid]) === $xp1);
// the cellar chest
$fresh();
$tx(fn(&$run, $u) => trek_enter($run, $u), false);
$at('cellar');
$tx(function (&$run, $u) use ($key) { trek_pack_add((int)$run['id'], $key, 1); return [true, '']; });
$r = $tx(function (&$run, $u) { $a = trek_act_chest($run, $u); $kits = $run['campkits']; $pet = $run['petals_found']; $b = trek_act_chest($run, $u); return [$a[0], $b[0], $kits, $run['campkits'], $pet, $run['petals_found']]; });
ok('the chest opens once; the second tap changes nothing', $r[0] === true && $r[1] === false && $r[2] === $r[3] && $r[4] === $r[5], json_encode($r));
// riddle: the right answer twice, two prizes? only one
$at('choir');
$r = $tx(function (&$run, $u) {
    $a = trek_act_riddle($run, $u, 2); $b = trek_act_riddle($run, $u, 2);
    return [$a[0], $b[0], trek_pack_qty((int)$run['id'], trek_item_id('lanternroot-seed'))];
});
ok('the riddle prize is given once', $r === [true, false, 1], json_encode($r));
$at('cart');
$r = $tx(function (&$run, $u) { $run['campkits'] = 0; $a = trek_act_cart($run, $u, 'work'); $b = trek_act_cart($run, $u, 'work'); return [$a[0], $b[0], $run['campkits']]; });
ok('the cart gives its Camp Kit once', $r === [true, false, 1], json_encode($r));
$at('burdock');
$r = $tx(function (&$run, $u) { $a = trek_act_recruit($run, $u); $b = trek_act_recruit($run, $u); return [$a[0], $b[0], count(trek_recruits((int)$run['id'])), count($run['party'])]; });
ok('Burdock joins once (one recruit row, one party place)', $r === [true, false, 1, 2], json_encode($r));
$x1 = (int)q_val('SELECT xp FROM users WHERE id = ?', [$uid]);
$tx(function (&$run, $u) { trek_flag_set($run, 'x'); trek_flag_set($run, 'x'); return [true, '']; });
ok('setting a flag twice does not throw or duplicate', (int)q_val("SELECT COUNT(*) FROM trek_flags WHERE flag = 'x'") === 1);
$r = $tx(function (&$run, $u) { $run['st']['ev'] = ['id' => 'stash']; $a = trek_act_event($run, $u, 1); $b = trek_act_event($run, $u, 1); return [$a[0], $b[0]]; });
ok('a trail event resolves once', $r === [true, false], json_encode($r));

echo "== entry points blocked inside a trek (road walk, explore, fast travel, delve, lair)\n";
$fresh();
$tx(fn(&$run, $u) => trek_enter($run, $u), false);
require_once $argv[1] . '/includes/adventure.php';
require_once $argv[1] . '/includes/explore.php';
require_once $argv[1] . '/includes/world.php';
require_once $argv[1] . '/includes/landmarks.php';
$U = fn() => q_one('SELECT * FROM users WHERE id = ?', [$uid]);
$has = fn($r) => is_array($r) && $r[0] === false && str_contains((string)$r[1], 'trek');
$route = (int)q_val('SELECT id FROM routes ORDER BY id LIMIT 1');
$region = (int)q_val('SELECT id FROM regions ORDER BY id LIMIT 1');
ok('start_expedition refuses', $has(start_expedition($U(), $route)));
ok('explore_start refuses', $has(explore_start($U())));
ok('travel_to refuses (fast travel)', $has(travel_to($U(), $region)));
$dl = q_one("SELECT * FROM landmarks WHERE kind = 'delve' LIMIT 1");
$lr = q_one("SELECT * FROM landmarks WHERE kind = 'lair' LIMIT 1");
foreach ([['delve', $dl, 'delve_start'], ['lair', $lr, 'lair_start']] as [$kind, $lm, $fn]) {
    if (!$lm || !$lm['location_id']) { echo "  skip $kind (none in this world)\n"; continue; }
    q('UPDATE users SET location_id = ? WHERE id = ?', [$lm['location_id'], $uid]);
    $res = $fn($U(), (int)$lm['id']);
    ok("$kind refuses while inside", $has($res), json_encode($res));
}
ok('inside, with Treks open: trek_inside is true', trek_inside($uid));
set_setting('trek_open', '0'); setting('__reload__');
ok('Treks switched off while they are inside: the closed trek page cannot hold them (trek_inside false, the road is free)', !trek_inside($uid));
$res = travel_to($U(), $region);
ok('...so fast travel is not blocked by the trek', !($res[0] === false && str_contains((string)$res[1], 'trek')), json_encode($res));
set_setting('trek_open', '1'); set_setting('trek_level', '40'); setting('__reload__');
ok('the level needed raised above theirs: not held either', !trek_inside($uid));
set_setting('trek_level', '15'); setting('__reload__');
ok('...and held again once they qualify', trek_inside($uid));
$tx(function (&$run, $u) { trek_leave($run); return [true, '']; });
ok('trek_inside is false once they leave', !trek_inside($uid));
$res = travel_to($U(), $region);
ok('after leaving, fast travel is not blocked by the trek', !($res[0] === false && str_contains((string)$res[1], 'trek')), json_encode($res));
$res = start_expedition($U(), $route);
ok('after leaving, the road is not blocked by the trek', !($res[0] === false && str_contains((string)$res[1], 'trek')), json_encode($res));
q('UPDATE expeditions SET status = ? WHERE user_id = ?', ['done', $uid]);
$tx(fn(&$run, $u) => trek_enter($run, $u));
ok('gathering is not on the blocked list (world.php, gather.php do not ask trek_inside)', !preg_match('/trek_inside/', (string)@file_get_contents($argv[1] . '/gather.php')) && !preg_match('/trek_inside/', (string)@file_get_contents($argv[1] . '/includes/gathering.php')));
$tx(function (&$run, $u) { trek_leave($run); return [true, '']; });

echo "== a run from before trek levels (1.8.8) is migrated once, with no XP\n";
$fresh();
$tx(fn(&$run, $u) => trek_enter($run, $u), false);
$xpA = (int)q_val('SELECT xp FROM users WHERE id = ?', [$uid]);
$rid = (int)q_val('SELECT id FROM trek_runs WHERE user_id = ?', [$uid]);
foreach (['freed_burdock', 'freed_zinnia', 'mother_down'] as $f) q('INSERT INTO trek_flags (run_id, flag) VALUES (?, ?)', [$rid, $f]);
q("UPDATE trek_runs SET state = ? WHERE id = ?", [json_encode(['turn' => 40, 'seen' => bin2hex(str_repeat("\xff", 100))]), $rid]);   // no st.tl: how 1.8.8 saved it
$R = $tx(fn(&$run, $u) => [$run['st']['tl'], array_keys($run['st']['ms'] ?? [])]);
ok('levels given from progress (3 milestones passed -> level 6)', ($R[0]['gnome'][0] ?? 0) === 6, json_encode($R));
ok('those milestones are marked paid without XP', count($R[1]) === 3 && (int)q_val('SELECT xp FROM users WHERE id = ?', [$uid]) === $xpA, json_encode($R[1]));
$R2 = $tx(fn(&$run, $u) => $run['st']['tl']);
ok('a second load does not migrate again', $R2 === $R[0]);

echo "== corrupt or missing state\n";
$fresh();
$tx(fn(&$run, $u) => trek_enter($run, $u), false);
$rid = (int)q_val('SELECT id FROM trek_runs WHERE user_id = ?', [$uid]);
foreach (['', 'null', 'garbage{', '[]', '{"seen":"zz","tl":5}', '{"seen":123,"turn":"x"}', '"just a string"', '7'] as $st) {
    q('UPDATE trek_runs SET state = ?, log = ?, fight = ? WHERE id = ?', [$st, $st === '7' ? '"x"' : '{bad', $st === '"just a string"' ? '"no"' : null, $rid]);
    $warn = [];
    try {
        $o = $tx(function (&$run, $u) { trek_walk($run, $u, (int)$run['x'] + 1, (int)$run['y']); trek_make_camp($run, $u); trek_latest_html($run); trek_flog_html($run); return trek_party_stats($run, $u); });
        ok('state ' . json_encode($st) . ' loads and plays on', is_array($o) && isset($o[0]) && !$warn, json_encode($warn));
    } catch (Throwable $e) {
        ok('state ' . json_encode($st) . ' loads and plays on', false, get_class($e) . ': ' . $e->getMessage());
        if (db()->inTransaction()) db()->rollBack();
    }
}
foreach (['{}', 'junk', '{"round":1}', '{"round":2,"foes":[],"meta":{}}', '[]', '"x"'] as $fj) {
    q('UPDATE trek_runs SET state = ?, log = ?, fight = ? WHERE id = ?', ['{}', '[]', $fj, $rid]);
    $warn = [];
    try {
        $o = $tx(function (&$run, $u) { $f = $run['fi']; if ($run['fi']) trek_fight_round($run, $u, []); return [true, $f === null]; });
        ok('a broken fight ' . json_encode($fj) . ' is dropped or played without a crash', is_array($o), json_encode($warn));
    } catch (Throwable $e) {
        ok('a broken fight ' . json_encode($fj) . ' is dropped or played without a crash', false, get_class($e) . ': ' . $e->getMessage());
        if (db()->inTransaction()) db()->rollBack();
    }
}
q('UPDATE trek_runs SET state = ?, log = ?, fight = NULL WHERE id = ?', ['{}', '[]', $rid]);

echo "== a trailmate whose crew row is gone\n";
$fresh();
$tx(fn(&$run, $u) => trek_enter($run, $u), false);
$warn = [];
$o = $tx(function (&$run, $u) {
    db_insert('trek_recruits', ['run_id' => $run['id'], 'crew_key' => 'ghost']);
    db_insert('trek_party', ['run_id' => $run['id'], 'slot' => 1, 'crew_key' => 'ghost', 'hp' => 5]);
    $run['party'][1] = ['crew_key' => 'ghost', 'hp' => 5];
    $s = trek_party_stats($run, $u);
    trek_heal_party($run, $u);
    trek_start_random_fight($run, $u, 'g');
    $acts = trek_fight_ai($run, $u);
    trek_fight_round($run, $u, $acts);
    return [count($s), $s[1]['max'] > 0];
});
ok('the party still plays with an unknown crew key', $o[0] === 2 && $o[1] === true, json_encode($o));
ok('...and without a single PHP warning', !$warn, json_encode(array_slice($warn, 0, 3)));
$tx(function (&$run, $u) { $run['fi'] = null; q('DELETE FROM trek_party WHERE run_id = ? AND slot > 0', [$run['id']]); q('DELETE FROM trek_recruits WHERE run_id = ?', [$run['id']]); unset($run['party'][1]); return [true, '']; });

echo "== an admin reset in the middle of a run\n";
$fresh();
$tx(fn(&$run, $u) => trek_enter($run, $u), false);
$tx(function (&$run, $u) { trek_ms_award($run, $u, 'burdock'); $run['petals_found'] = 20; trek_pack_add((int)$run['id'], trek_item_id('beetle-shell'), 3); return [true, '']; });
$rid = (int)q_val('SELECT id FROM trek_runs WHERE user_id = ?', [$uid]);
foreach (['trek_party', 'trek_pack', 'trek_flags', 'trek_recruits'] as $t) q("DELETE FROM $t WHERE run_id = ?", [$rid]);   // what admin/treks.php does
q('DELETE FROM trek_runs WHERE id = ?', [$rid]);
ok('a POST right after the reset says "begin first" (null), no crash', $tx(fn(&$run, $u) => [true, '']) === null);
ok('the player is not inside a trek any more', !trek_inside($uid));
$xp0 = (int)q_val('SELECT xp FROM users WHERE id = ?', [$uid]);
$tx(fn(&$run, $u) => trek_enter($run, $u), false);
$tx(function (&$run, $u) { trek_ms_award($run, $u, 'burdock'); return [true, '']; });
ok('milestone XP is not paid a second time after a reset', (int)q_val('SELECT xp FROM users WHERE id = ?', [$uid]) === $xp0);
ok('no orphan rows are left by the reset', (int)q_val('SELECT COUNT(*) FROM trek_flags WHERE run_id = ?', [$rid]) === 0 && (int)q_val('SELECT COUNT(*) FROM trek_pack WHERE run_id = ?', [$rid]) === 0);

echo "== one-shot session data: stale, foreign, or gone\n";
$fresh();
$tx(fn(&$run, $u) => trek_enter($run, $u), false);
require_once $argv[1] . '/includes/trek_art.php';
$rr = $run();
$_SESSION['trek_walk'] = ['run' => (int)$rr['id'], 't' => time() - 120, 'p' => [[$rr['x'], $rr['y']], [$rr['x'] + 1, $rr['y']]], 'd' => [1, 1]];
ok('a walk older than 30 s is not played', trek_walk_take($rr) === null);
$_SESSION['trek_walk'] = ['run' => (int)$rr['id'] + 99, 't' => time(), 'p' => [[$rr['x'], $rr['y']], [$rr['x'], $rr['y']]], 'd' => [1, 1]];
ok('a walk of another run is not played', trek_walk_take($rr) === null);
$_SESSION['trek_walk'] = ['run' => (int)$rr['id'], 't' => time(), 'p' => [[0, 0], [1, 0]], 'd' => [1, 1]];
ok('a walk that does not end where the party is, is not played', trek_walk_take($rr) === null);
$_SESSION['trek_walk'] = 'junk';
ok('junk in the session is ignored', trek_walk_take($rr) === null);
unset($_SESSION['trek_walk']);
ok('no session data is fine', trek_walk_take($rr) === null);

echo "== settings at their extremes: a short random walk, no crash, numbers stay sane\n";
$combos = [
    ['trek_enc_percent' => '0', 'trek_campkit_max' => '0', 'trek_base_level' => '1', 'trek_event_pct' => '0'],
    ['trek_enc_percent' => '100', 'trek_campkit_max' => '99', 'trek_base_level' => '100', 'trek_event_pct' => '100', 'trek_event_gap' => '1'],
    ['trek_enc_percent' => '50', 'trek_campkit_max' => '3', 'trek_base_level' => '15', 'trek_event_pct' => '50', 'trek_event_gap' => '1', 'trek_petals_daily' => '0', 'trek_ko_loss_pct' => '100', 'trek_ambush_pct' => '100', 'trek_entry_energy' => '0', 'trek_campkit_price' => '0'],
];
mt_srand(11);
foreach ([1, 2] as $chap) foreach ($combos as $ci => $cmb) {
    $fresh($chap);
    foreach ($cmb as $k => $v) set_setting($k, $v);
    setting('__reload__');
    $tx(fn(&$run, $u) => trek_enter($run, $u), false);
    if ($chap === 2) $tx(function (&$run, $u) { trek_recruit_crew($run, $u, 'sorrel'); return [true, '']; });
    $bad = []; $warn = [];
    for ($i = 0; $i < 300; $i++) {
        $r = mt_rand(0, 99);
        try {
            $tx(function (&$run, $u) use ($r, &$bad) {
                $run['sn'] = str_repeat("\xff", strlen($run['sn']));
                if (!(int)$run['inside']) { trek_enter($run, $u); return [true, '']; }
                if (!empty($run['st']['ev'])) { trek_act_event($run, $u, mt_rand(0, 2)); return [true, '']; }
                if (!empty($run['st']['cm'])) { trek_act_crew($run, $u, mt_rand(0, 1)); return [true, '']; }
                if ($run['fi']) {
                    $c = mt_rand(0, 3);
                    if ($c === 0) trek_fight_auto($run, $u, 40, true); elseif ($c === 1) trek_fight_auto($run, $u, 1);
                    elseif ($c === 2) trek_fight_round($run, $u, [0 => ['a' => 'attack'], 1 => ['a' => 'ability'], 2 => ['a' => 'ability', 't' => 'a:0'], 3 => ['a' => 'snack']]);
                    else trek_fight_flee($run, $u);
                } elseif ($r < 60) {
                    $m = trek_map((int)$run['chapter']); trek_party_stats($run, $u);
                    for ($t = 0; $t < 40; $t++) { $tx_ = mt_rand(0, $m['w'] - 1); $ty = mt_rand(0, $m['h'] - 1); if (trek_path($run, $tx_, $ty)) { trek_walk($run, $u, $tx_, $ty); break; } }
                } elseif ($r < 68) trek_make_camp($run, $u);
                elseif ($r < 72) trek_camp_rest($run, $u);
                elseif ($r < 76) trek_buy_kit($run, $u);
                elseif ($r < 79) trek_leave($run);
                elseif ($r < 88) { if (trek_here($run, $u)) foreach (['trek_act_challenge', 'trek_act_recruit', 'trek_act_fetch', 'trek_act_chest', 'trek_act_hidden', 'trek_act_switch', 'trek_act_rest', 'trek_act_trade', 'trek_act_slide', 'trek_act_mush'] as $f) $f($run, $u); }
                elseif ($r < 92) trek_act_riddle($run, $u, mt_rand(1, 3));
                elseif ($r < 95) { $camps = array_keys(trek_travel_camps($run)); if ($camps) trek_act_travel($run, $u, $camps[0]); }
                else trek_set_party($run, $u, [1 => 'burdock', 2 => 'sorrel', 3 => 'zinnia']);
                if ($run['fatigue'] < 0 || $run['fatigue'] > 100) $bad[] = 'fatigue ' . $run['fatigue'];
                if ($run['petals_found'] < 0) $bad[] = 'petals ' . $run['petals_found'];
                foreach ($run['party'] as $p) if ($p['hp'] < 0) $bad[] = 'hp';
                return [true, ''];
            });
        } catch (Throwable $e) {
            $bad[] = get_class($e) . ': ' . $e->getMessage() . ' @ ' . basename($e->getFile()) . ':' . $e->getLine();
            if (db()->inTransaction()) db()->rollBack();
            break;
        }
    }
    ok("chapter $chap settings set " . ($ci + 1) . ': 300 random actions, nothing odd', !$bad && !$warn, json_encode(array_slice(array_merge($bad, $warn), 0, 3)));
    ok("   coins never negative", $coins() >= 0);
}
$fresh();

echo $fails ? "\n$fails FAILED\n" : "\nall ok\n";
exit($fails ? 1 : 0);
