<?php
// Treks (1.8.8): trail events, the three hand-placed stops, crew moments, the whole-fight log. Run by treks.sh after tests/trek.php on the same install.
// Dice: the engine reads $GLOBALS['trek_test_roll'] / ['trek_test_d20'] when they are set (the game never sets them), so every outcome here is certain.
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
$flag = fn(string $f) => (int)q_val('SELECT COUNT(*) FROM trek_flags WHERE run_id = ? AND flag = ?', [$run()['id'], $f]) === 1;
$pack = fn(string $slug) => (int)q_val('SELECT COALESCE(SUM(qty),0) FROM trek_pack WHERE run_id = ? AND item_id = ? AND banked = 0', [$run()['id'], trek_item_id($slug)]);
$have = fn(string $slug) => (int)q_val('SELECT COALESCE(SUM(qty),0) FROM user_items WHERE user_id = ? AND item_id = ?', [$uid, trek_item_id($slug)]);
$spots = trek_spots(1);
$today = hollow_date('Y-m-d');
function rig_easy(array &$run): void { foreach ($run['fi']['foes'] as $i => $f) { if (!empty($f['add'])) continue; $run['fi']['foes'][$i]['hp'] = 1; $run['fi']['foes'][$i]['def'] = -50; $run['fi']['foes'][$i]['atk'] = -60; } }
function rig_unbeatable(array &$run): void { foreach ($run['fi']['foes'] as $i => $f) { $run['fi']['foes'][$i]['hp'] = $run['fi']['foes'][$i]['max'] = 99999; $run['fi']['foes'][$i]['def'] = 999; $run['fi']['foes'][$i]['atk'] = -60; } }
$seenCount = function (array $R): int { $n = 0; $m = trek_map(1); for ($y = 0; $y < $m['h']; $y++) for ($x = 0; $x < $m['w']; $x++) if (trek_seen_get($R, $x, $y)) $n++; return $n; };

set_setting('trek_open', '1'); set_setting('trek_enc_percent', '0'); set_setting('trek_event_pct', '0'); set_setting('trek_event_gap', '3'); setting('__reload__');
unset($GLOBALS['trek_test_roll'], $GLOBALS['trek_test_d20']);
q('UPDATE creature_drops SET chance = 0 WHERE 1 = 1');
/** A brand-new run, inside, whole map seen, first fight won, at (4,15) (a plain floor corridor of the Grubfields). */
$fresh = function () use ($uid, $tx) {
    foreach (['trek_flags', 'trek_pack', 'trek_party', 'trek_recruits'] as $t) q("DELETE FROM $t WHERE run_id IN (SELECT id FROM trek_runs WHERE user_id = ?)", [$uid]);
    q('DELETE FROM trek_runs WHERE user_id = ?', [$uid]);
    q('UPDATE users SET level = 16, energy = 100, coins = 1000, calling = NULL, trek_ch = 1, trek_pet_day = NULL, trek_pet_today = 0 WHERE id = ?', [$uid]);   // (v1.9.1: the daily Petal count is the player's, so a fresh run starts it over here)
    $tx(fn(&$run, $u) => trek_enter($run, $u), false);
    $tx(function (&$run, $u) { $run['sn'] = str_repeat("\xff", strlen($run['sn'])); trek_flag_set($run, 'won_fight'); $run['fatigue'] = 0; $run['petals_found'] = 0; $run['campkits'] = 0; $run['x'] = 4; $run['y'] = 15; return [true, '']; });
};
$at = fn(string $code) => $tx(function (&$run, $u) use ($code) { $sp = trek_spots(1)[$code]; $run['x'] = $sp['x']; $run['y'] = $sp['y']; $run['fi'] = null; return [true, '']; });
$setEv = fn(string $id) => $tx(function (&$run, $u) use ($id) { $run['st']['ev'] = ['id' => $id]; $run['fi'] = null; return [true, '']; });
$act = fn(int $c) => $tx(fn(&$run, $u) => trek_act_event($run, $u, $c));
$setPet = fn(int $n) => q('UPDATE users SET trek_pet_day = ?, trek_pet_today = ? WHERE id = ?', [hollow_date('Y-m-d'), $n, $uid]);   // v1.9.1: the daily Petal count is per player
$capPetals = fn() => $setPet((int)setting('trek_petals_daily'));
/** v1.8.9: all trek XP the party has earned (levels counted as the XP they cost), and the gnome's main XP: events give the first and never the second. */
$tlTotal = function () use ($run) { $t = 0; foreach ((array)($run()['st']['tl'] ?? []) as $v) { for ($l = 1; $l < $v[0]; $l++) $t += trek_tl_need($l); $t += $v[1]; } return $t; };
$mainXp = fn() => (int)q_val('SELECT xp FROM users WHERE id = ?', [$uid]);
$plainWalk = function (int $n) use ($tx, $run) {   // n walks along the corridor (4,15) <-> (10,15); returns the walk number at which a stop (event or crew card) happened, or 0
    for ($i = 1; $i <= $n; $i++) {
        $R = $run();
        $to = $R['x'] <= 5 ? 10 : 4;
        $tx(fn(&$run, $u) => trek_walk($run, $u, $to, 15));
        $R = $run();
        if (!empty($R['st']['cm']) || !empty($R['st']['ev'])) return $i;
    }
    return 0;
};

echo "== data: the three stops, text slots, draft bodies\n";
$newCodes = ['cart', 'mushcamp', 'bridgestone'];
$taken = [];
foreach ($spots as $c => $s) { $k = $s['x'] . ',' . $s['y']; ok("spot $c has its own tile", !isset($taken[$k])); $taken[$k] = $c; }
$fresh();
$R0 = $run();
$R0['flags'] = ['won_fight' => 1, 'freed_burdock' => 1, 'freed_zinnia' => 1, 'mother_down' => 1];
$R0['x'] = $spots['start']['x']; $R0['y'] = $spots['start']['y'];
$zonesWant = ['cart' => 'w', 'mushcamp' => 'd', 'bridgestone' => 'b'];
$before = ['cart' => 'burdock', 'mushcamp' => 'zinnia', 'bridgestone' => 'bracken'];
foreach ($newCodes as $c) {
    $s = $spots[$c];
    ok("$c: path from the start", (bool)trek_path($R0, $s['x'], $s['y']));
    ok("$c: zone matches", trek_zone_at(1, $s['x'], $s['y']) === $s['zone'] && $s['zone'] === $zonesWant[$c]);
    ok("$c: walkable and not a wall", trek_passable($R0, $s['x'], $s['y']));
    $n = 0; foreach ([[1, 0], [-1, 0], [0, 1], [0, -1]] as [$dx, $dy]) if (trek_passable($R0, $s['x'] + $dx, $s['y'] + $dy)) $n++;
    ok("$c: sits on a route (two open neighbours)", $n >= 2, (string)$n);
    // "in the gap": the walk to the next crew member goes over it
    $p = trek_path($R0, $spots[$before[$c]]['x'], $spots[$before[$c]]['y']);
    $on = false;
    if ($c === 'cart') $on = in_array([$s['x'], $s['y']], $p, true);
    elseif ($c === 'mushcamp') { $R1 = $R0; $R1['x'] = $spots['camp']['x']; $R1['y'] = $spots['camp']['y']; $on = in_array([$s['x'], $s['y']], trek_path($R1, $spots['dewsign']['x'], $spots['dewsign']['y']), true); }   // the only way into the Dew Pools, which Zinnia's Clean Dew needs
    else { $R1 = $R0; $R1['x'] = $spots['zinnia']['x']; $R1['y'] = $spots['zinnia']['y']; $on = in_array([$s['x'], $s['y']], trek_path($R1, $spots['bracken']['x'], $spots['bracken']['y']), true); }
    ok("$c lies on a forced route toward " . $before[$c], $on);
}
$drafts = trek_drafts();
$texts = [];
$ch2keys = []; foreach (array_merge(file($argv[1] . '/includes/data/trek_texts_ch2.txt'), file($argv[1] . '/includes/data/trek_texts_ch2b.txt'), file($argv[1] . '/includes/data/trek_texts_oldcamp.txt')) as $ln) { $ln = rtrim($ln, "\r\n"); if ($ln === '' || $ln[0] === '#') continue; $ch2keys[explode('|', $ln)[0]] = true; }
$drafts = array_diff_key($drafts, $ch2keys);   // v1.9.2: Chapter II-a's and II-b's drafts are checked in tests/trek_ch2.php and trek_ch2b.php
foreach (file($argv[1] . '/includes/data/trek_texts.txt') as $ln) { $ln = rtrim($ln, "\r\n"); if ($ln === '' || $ln[0] === '#') continue; $texts[explode('|', $ln)[0]] = true; }
ok('at least the 55 original draft bodies shipped (2.0.0 added the rest)', count($drafts) >= 55, (string)count($drafts));
$miss = array_diff(array_keys($drafts), array_keys($texts));
ok('every draft belongs to a text slot', !$miss, implode(',', $miss));
$need = ['ch1.ev.walkon'];
foreach (array_keys(array_diff_key(TREK_EVENTS, TREK_EVENT_CH)) as $id) $need[] = "ch1.ev.$id.text";
foreach (['stash.dig', 'forager.help', 'fork.win', 'fork.fail', 'trader.buy', 'shrine.rest', 'shrine.bless', 'puddle.good', 'puddle.bad', 'beetle.patch', 'beetle.heal', 'song.hum'] as $k) $need[] = "ch1.ev.$k";
foreach (array_diff(array_keys(TREK_CREW_BEATS), ['sorrel', 'tumble', 'juniper']) as $k) { $need[] = "ch1.crew.$k.talk"; $need[] = "ch1.crew.$k.done"; }
foreach (['before', 'win', 'fail', 'work', 'after'] as $k) $need[] = "ch1.spot.cart.$k";
foreach (['before', 'short', 'done', 'after'] as $k) $need[] = "ch1.spot.mushcamp.$k";
foreach (['question', 'a1', 'a2', 'a3', 'right', 'wrong', 'out', 'after'] as $k) $need[] = "ch1.spot.bridgestone.$k";
$noRow = $noDraft = [];
foreach ($need as $k) {
    $r = q_one('SELECT body, status FROM trek_texts WHERE text_key = ?', [$k]);
    if (!$r) $noRow[] = $k; elseif (trim((string)$r['body']) === '' || $r['status'] !== 'draft') $noDraft[] = $k;
}
ok('44 slots needed by the code all exist', !$noRow && count($need) === 44, implode(',', $noRow) . ' n=' . count($need));
ok('every new slot has a draft body with status draft (players never see a blank)', !$noDraft, implode(',', $noDraft));
$allOk = true; foreach ($need as $k) if (trek_text($k) === '') $allOk = false;
ok('trek_text shows the draft to a player (not admin)', $allOk && !is_admin());
q('UPDATE trek_texts SET body = ?, status = ? WHERE text_key = ?', ['Joshua wrote this', 'done', 'ch1.ev.walkon']);
q("DELETE FROM trek_texts WHERE text_key = 'ch1.ev.song.hum'");
$again = trek_import();
ok('importer re-adds a missing slot with its draft (draft status)', (int)$again['texts'] === 1 && q_val("SELECT status FROM trek_texts WHERE text_key = 'ch1.ev.song.hum'") === 'draft' && q_val("SELECT body FROM trek_texts WHERE text_key = 'ch1.ev.song.hum'") === $drafts['ch1.ev.song.hum']);
ok('importer never overwrites a written body or status', q_val("SELECT body FROM trek_texts WHERE text_key = 'ch1.ev.walkon'") === 'Joshua wrote this' && q_val("SELECT status FROM trek_texts WHERE text_key = 'ch1.ev.walkon'") === 'done');
q('UPDATE trek_texts SET body = ?, status = ? WHERE text_key = ?', [$drafts['ch1.ev.walkon'], 'draft', 'ch1.ev.walkon']);
ok('settings exist with the agreed defaults', (trek_settings()['trek_event_pct']['default'] ?? '') === '6' && isset(trek_settings()['trek_event_gap']));

echo "== trail events: each event, each choice\n";
$fresh();
ok('there are 8 Chapter I events (and 6 for Chapter II)', count(array_diff_key(TREK_EVENTS, TREK_EVENT_CH)) === 8 && count(TREK_EVENTS) === 14);
// stash
$setEv('stash'); $r = $act(1); $R = $run();
ok('stash: Petals found (carried) 6-14, event gone', $r[0] && $R['petals_found'] >= 6 && $R['petals_found'] <= 14 && empty($R['st']['ev']), (string)$R['petals_found']);
$p1 = $R['petals_found']; $r = $act(1);
ok('stash: a second tap pays nothing', $r[0] === false && $run()['petals_found'] === $p1);
$setEv('stash'); $capPetals(); $p0 = $run()['petals_found']; $act(1);
ok('stash: respects the daily Petal limit', $run()['petals_found'] === $p0);
$setPet(0);
// forager
$setEv('forager'); $f0 = $run()['fatigue']; $x0 = $tlTotal(); $m0 = $mainXp(); $r = $act(1); $R = $run();
ok('forager: fatigue +3 and a little trek XP', $r[0] && $R['fatigue'] === $f0 + 3 && $tlTotal() > $x0, "f={$R['fatigue']} xp={$tlTotal()}");
ok('forager: the gnome main XP is untouched', $mainXp() === $m0);
$tx(function (&$run, $u) { $run['fatigue'] = 50; return [true, '']; });
// fork
foreach ([1 => 'nimble', 2 => 'hardiness'] as $c => $st) {
    $GLOBALS['trek_test_d20'] = 20; $setEv('fork'); $tx(function (&$run, $u) { $run['fatigue'] = 50; return [true, '']; }); $act($c);
    $good = $run()['fatigue'];
    $GLOBALS['trek_test_d20'] = 1; $setEv('fork'); $tx(function (&$run, $u) { $run['fatigue'] = 50; return [true, '']; }); $act($c);
    $bad = $run()['fatigue'];
    ok("fork choice $c ($st): success -10, failure +4", $good === 40 && $bad === 54, "$good / $bad");
}
unset($GLOBALS['trek_test_d20']);
// trader
$tx(function (&$run, $u) { $run['petals_found'] = 100; $run['campkits'] = 0; return [true, '']; });
$price = trek_trader_price();
$setEv('trader'); $r = $act(1); $R = $run();
ok('trader: paid carried Petals for a Camp Kit', $r[0] && $R['campkits'] === 1 && $R['petals_found'] === 100 - $price && empty($R['st']['ev']), json_encode([$R['campkits'], $R['petals_found']]));
$r = $act(1);
ok('trader: double tap buys nothing more', $r[0] === false && $run()['campkits'] === 1 && $run()['petals_found'] === 100 - $price);
$tx(function (&$run, $u) { $run['petals_found'] = 5; $run['campkits'] = 0; return [true, '']; });
$setEv('trader'); $r = $act(1);
ok('trader: too poor is refused and the event stays', $r[0] === false && $run()['campkits'] === 0 && ($run()['st']['ev']['id'] ?? '') === 'trader');
$tx(function (&$run, $u) { $run['petals_found'] = 500; $run['campkits'] = (int)setting('trek_campkit_max'); return [true, '']; });
$r = $act(1);
ok('trader: kits full is refused', $r[0] === false && $run()['petals_found'] === 500);
$act(0);
$tx(function (&$run, $u) { $run['petals_found'] = 0; $run['campkits'] = 0; return [true, '']; });
$never = true; for ($i = 0; $i < 80; $i++) { $pick = $tx(fn(&$run, $u) => trek_ev_pick($run, $u)); if ($pick === 'trader') $never = false; }
ok('trader is never offered when the party cannot pay', $never);
// shrine
$tx(function (&$run, $u) { $run['party'][0]['hp'] = 1; return [true, '']; });
$setEv('shrine'); $act(1); $st = $tx(fn(&$run, $u) => trek_party_stats($run, $u)); $R = $run();
ok('shrine rest: heals a quarter', $R['party'][0]['hp'] === min($st[0]['max'], 1 + (int)ceil($st[0]['max'] * 0.25)), $R['party'][0]['hp'] . '/' . $st[0]['max']);
$atk0 = $tx(fn(&$run, $u) => trek_party_stats($run, $u)[0]['gc']['atk']);
$setEv('shrine'); $act(2); $R = $run();
$atk1 = $tx(fn(&$run, $u) => trek_party_stats($run, $u)[0]['gc']['atk']);
ok('shrine thanks: +1 to hit until the next fight', !empty($R['st']['bless']) && $atk1 === $atk0 + 1, "$atk0 -> $atk1");
$tx(function (&$run, $u) { trek_start_random_fight($run, $u, 'g'); rig_easy($run); trek_fight_auto($run, $u, 60); return [true, '']; });
$R = $run();
ok('shrine thanks lasts one fight', empty($R['st']['bless']) && !$R['fi']);
// puddle
$tx(function (&$run, $u) { foreach ($run['party'] as $s => $p) $run['party'][$s]['hp'] = 5; return [true, '']; });
$GLOBALS['trek_test_roll'] = 1; $setEv('puddle'); $act(1); $good = $run()['party'][0]['hp'];
$tx(function (&$run, $u) { $run['party'][0]['hp'] = 40; $run['fatigue'] = 0; return [true, '']; });
$GLOBALS['trek_test_roll'] = 100; $setEv('puddle'); $act(1); $R = $run(); $bad = $R['party'][0]['hp'];
ok('puddle: good heals, bad stings (never below 1, fatigue +2)', $good > 5 && $bad < 40 && $bad >= 1 && $R['fatigue'] === 2, "$good / $bad / {$R['fatigue']}");
$tx(function (&$run, $u) { $run['party'][0]['hp'] = 1; return [true, '']; }); $setEv('puddle'); $act(1);
ok('puddle: a sting never knocks anyone out', $run()['party'][0]['hp'] === 1);
unset($GLOBALS['trek_test_roll']);
// beetle
$tx(function (&$run, $u) { $run['fatigue'] = 10; return [true, '']; });
$setEv('beetle'); $x0 = $tlTotal(); $m0 = $mainXp(); $r = $act(2);
ok('beetle: the Bloomcaller choice is refused with no Bloomcaller', $r[0] === false && ($run()['st']['ev']['id'] ?? '') === 'beetle');
$ch = $tx(fn(&$run, $u) => trek_ev_choices($run, $u, 'beetle'));
ok('beetle: only the patch choice without a Bloomcaller', array_keys($ch) === [1]);
$act(1); $R = $run();
ok('beetle patch: fatigue +2, a little trek XP, no main XP', $R['fatigue'] === 12 && $tlTotal() > $x0 && $mainXp() === $m0);
$tx(function (&$run, $u) { $run['flags']['freed_zinnia'] = 1; trek_recruit_crew($run, $u, 'zinnia'); return [true, '']; });
$setEv('beetle'); $ch = $tx(fn(&$run, $u) => trek_ev_choices($run, $u, 'beetle'));
ok('beetle: with Zinnia a second choice appears', array_keys($ch) === [1, 2] && str_contains($ch[2][1], 'Zinnia'), json_encode($ch));
$p0 = $run()['petals_found']; $f0 = $run()['fatigue']; $x0 = $tlTotal(); $r = $act(2); $R = $run();
ok('beetle heal: Petals and trek XP, no fatigue, once', $r[0] && $R['petals_found'] > $p0 && $tlTotal() > $x0 && $R['fatigue'] === $f0 && empty($R['st']['ev']));
$p1 = $R['petals_found']; $r = $act(2); ok('beetle heal: double tap pays nothing', $r[0] === false && $run()['petals_found'] === $p1);
$setEv('beetle'); $capPetals(); $p0 = $run()['petals_found']; $x0 = $tlTotal(); $act(2);
ok('beetle heal: the daily Petal limit holds, trek XP is not capped', $run()['petals_found'] === $p0 && $tlTotal() > $x0);
$setPet(0);
// song
$tx(function (&$run, $u) { $run['fatigue'] = 50; return [true, '']; }); $setEv('song'); $act(1);
$a = $run()['fatigue'];
$tx(function (&$run, $u) { $run['fatigue'] = 5; return [true, '']; }); $setEv('song'); $act(1);
ok('song stone: fatigue -15, never below 0', $a === 35 && $run()['fatigue'] === 0, "$a / " . $run()['fatigue']);
// walk on, unknown choice, fight
foreach (array_keys(TREK_EVENTS) as $id) {
    $tx(function (&$run, $u) { $run['fatigue'] = 30; $run['petals_found'] = 100; return [true, '']; });
    $setEv($id); $r = $act(0); $R = $run();
    ok("$id: walk on changes nothing and clears the card", $r[0] && empty($R['st']['ev']) && $R['fatigue'] === 30 && $R['petals_found'] === 100);
}
$setEv('stash'); $r = $act(7); ok('a made-up choice is refused and the event stays', $r[0] === false && !empty($run()['st']['ev'])); $r = $act(-1); ok('choice -1 refused', $r[0] === false);
$tx(function (&$run, $u) { trek_start_random_fight($run, $u, 'g'); return [true, '']; });
$r = $act(1); ok('no event choice during a fight', $r[0] === false);
$tx(function (&$run, $u) { rig_easy($run); trek_fight_auto($run, $u, 60); return [true, '']; });

echo "== trail events: when they happen\n";
$fresh();
$GLOBALS['trek_test_roll'] = 1;
set_setting('trek_event_pct', '100'); set_setting('trek_event_gap', '3'); setting('__reload__');
$tx(function (&$run, $u) { $run['st']['ev_steps'] = 0; return [true, '']; });
$tx(fn(&$run, $u) => trek_walk($run, $u, 10, 15)); $R = $run();
ok('an event stops the walk on a plain tile, after the gap (3 steps)', !empty($R['st']['ev']['id']) && isset(TREK_EVENTS[$R['st']['ev']['id']]) && $R['x'] === 7, json_encode([$R['x'], $R['st']['ev'] ?? null]));
$id1 = $R['st']['ev']['id'];
$R2 = $run();
ok('a refresh (re-reading the run) shows the same event, no reroll', ($R2['st']['ev']['id'] ?? '') === $id1);
$tx(fn(&$run, $u) => trek_walk($run, $u, 10, 15)); $R = $run();
ok('walking on drops the old card; no second event straight away', ($R['st']['ev']['id'] ?? '') !== $id1 || $R['x'] === 10);
$tx(function (&$run, $u) { unset($run['st']['ev']); $run['fatigue'] = 0; return [true, '']; });
$hits = []; $tx(function (&$run, $u) use (&$hits) { $run['st']['ev_steps'] = 0; $run['st']['ev_last'] = ''; for ($i = 1; $i <= 60; $i++) { if (trek_step_extras($run, $u, 'f')) { $hits[] = $i; unset($run['st']['ev']); } } return [true, '']; });
$gapOk = true; for ($i = 1; $i < count($hits); $i++) if ($hits[$i] - $hits[$i - 1] < 3) $gapOk = false;
ok('over 60 plain steps: events happen, never closer than the gap', count($hits) >= 10 && $gapOk && ($hits[0] ?? 0) >= 3, json_encode($hits));
$twice = false; $tx(function (&$run, $u) use (&$twice) { $run['st']['ev_steps'] = 99; $run['st']['ev_last'] = ''; $a = trek_ev_pick($run, $u); $run['st']['ev_last'] = $a; for ($i = 0; $i < 40; $i++) if (trek_ev_pick($run, $u) === $a) $twice = true; return [true, '']; });
ok('never the same event twice in a row', !$twice);
set_setting('trek_event_pct', '0'); setting('__reload__');
$none = 0; $tx(function (&$run, $u) use (&$none) { $run['st']['ev_steps'] = 99; for ($i = 0; $i < 40; $i++) if (trek_step_extras($run, $u, 'f')) $none++; return [true, '']; });
ok('trail event chance 0 = no events', $none === 0);
set_setting('trek_event_pct', '100'); setting('__reload__');
$tx(function (&$run, $u) { $run['st']['ev_steps'] = 99; unset($run['st']['ev']); return [true, '']; });
$none = 0; $tx(function (&$run, $u) use (&$none) { trek_start_random_fight($run, $u, 'g'); for ($i = 0; $i < 20; $i++) if (trek_step_extras($run, $u, 'g')) $none++; rig_easy($run); trek_fight_auto($run, $u, 60); return [true, '']; });
ok('no events inside a fight', $none === 0);
$flagRow = (int)q_val('SELECT id FROM trek_flags WHERE run_id = ? AND flag = ?', [$run()['id'], 'won_fight']);
q('DELETE FROM trek_flags WHERE id = ?', [$flagRow]);
$none = 0; $tx(function (&$run, $u) use (&$none) { unset($run['flags']['won_fight']); $run['st']['ev_steps'] = 99; for ($i = 0; $i < 20; $i++) if (trek_step_extras($run, $u, 'g')) $none++; return [true, '']; });
ok('no events before the first fight is won', $none === 0);
$fresh(); $GLOBALS['trek_test_roll'] = 1;
$sg = $spots['dewsign'];
$tx(function (&$run, $u) use ($sg) { $run['x'] = $sg['x'] + 1; $run['y'] = $sg['y']; $run['st']['ev_steps'] = 99; unset($run['st']['ev']); return [true, '']; });
$tx(fn(&$run, $u) => trek_walk($run, $u, $sg['x'], $sg['y']));
ok('no event on a spot tile', empty($run()['st']['ev']) && $run()['x'] === $sg['x']);
unset($GLOBALS['trek_test_roll']);
set_setting('trek_event_pct', '0'); setting('__reload__');

echo "== the three side stops\n";
$fresh();
$at('cart');
$r = $tx(fn(&$run, $u) => trek_act_cart($run, $u, 'heave' . 'x')); ok('cart: an unknown way is refused', $r[0] === false && !$flag('cart_done'));
$GLOBALS['trek_test_d20'] = 1; $r = $tx(fn(&$run, $u) => trek_act_cart($run, $u, 'heave')); $R = $run();
ok('cart: a failed heave costs fatigue +3 and leaves it stuck', $r[0] === true && !$flag('cart_done') && $R['fatigue'] === 3 && $R['campkits'] === 0);
$GLOBALS['trek_test_d20'] = 20; $r = $tx(fn(&$run, $u) => trek_act_cart($run, $u, 'heave')); $R = $run();
ok('cart: a good heave frees it, one Camp Kit, no fatigue', $flag('cart_done') && $R['campkits'] === 1 && $R['fatigue'] === 3);
$r = $tx(fn(&$run, $u) => trek_act_cart($run, $u, 'heave')); $r2 = $tx(fn(&$run, $u) => trek_act_cart($run, $u, 'work'));
ok('cart: once only (heave or work again pays nothing)', $r[0] === false && $r2[0] === false && $run()['campkits'] === 1);
unset($GLOBALS['trek_test_d20']);
$fresh(); $at('cart'); $tx(function (&$run, $u) { $run['campkits'] = (int)setting('trek_campkit_max'); return [true, '']; }); $sat0 = $have('camp-kit');
$tx(fn(&$run, $u) => trek_act_cart($run, $u, 'work')); $R = $run();
ok('cart: digging it out costs fatigue +8, always works, kit overflow goes to the satchel', $flag('cart_done') && $R['fatigue'] === 8 && $have('camp-kit') === $sat0 + 1);
$fresh(); $r = $tx(fn(&$run, $u) => trek_act_cart($run, $u, 'work')); ok('cart: refused away from the cart', $r[0] === false && !$flag('cart_done'));
// mush camp
$fresh(); $at('mushcamp'); $shell = trek_item_id('beetle-shell'); ok('Beetle Shell and Honeydew items exist', $shell > 0 && trek_item_id('honeydew') > 0);
$r = $tx(fn(&$run, $u) => trek_act_mush($run, $u)); ok('mush camp: refused with no shells', $r[0] === false && !$flag('mush_done'));
$tx(function (&$run, $u) use ($shell) { trek_pack_add((int)$run['id'], $shell, 1); return [true, '']; });
$r = $tx(fn(&$run, $u) => trek_act_mush($run, $u)); ok('mush camp: one shell is not enough and is kept', $r[0] === false && $pack('beetle-shell') === 1 && !$flag('mush_done'));
$tx(function (&$run, $u) use ($shell) { trek_pack_add((int)$run['id'], $shell, 2); return [true, '']; });
$r = $tx(fn(&$run, $u) => trek_act_mush($run, $u)); $R = $run();
ok('mush camp: 2 shells taken, 30 Petals carried, honeydew, flag', $r[0] && $pack('beetle-shell') === 1 && $R['petals_found'] === 30 && $pack('honeydew') === 1 && $flag('mush_done'), json_encode([$pack('beetle-shell'), $R['petals_found']]));
$r = $tx(fn(&$run, $u) => trek_act_mush($run, $u)); ok('mush camp: once only', $r[0] === false && $run()['petals_found'] === 30 && $pack('honeydew') === 1);
$fresh(); $at('mushcamp'); $capPetals(); $tx(function (&$run, $u) use ($shell) { trek_pack_add((int)$run['id'], $shell, 2); return [true, '']; });
$tx(fn(&$run, $u) => trek_act_mush($run, $u));
ok('mush camp: the daily Petal limit holds (the job is still done)', $run()['petals_found'] === 0 && $flag('mush_done') && $pack('beetle-shell') === 0);
// riddle stone (the existing riddle code)
$fresh(); $at('bridgestone');
$r = $tx(fn(&$run, $u) => trek_act_riddle($run, $u, 1)); ok('stone: a wrong answer, no reward, tries 1', $r[0] === true && !$flag('stone_solved') && $run()['st']['tries_bridgestone'] === 1);
$r = $tx(fn(&$run, $u) => trek_act_riddle($run, $u, 3)); ok('stone: the right answer (3) gives a Singing Pebble', $r[0] === true && $flag('stone_solved') && $pack('singing-pebble') === 1);
$r = $tx(fn(&$run, $u) => trek_act_riddle($run, $u, 3)); ok('stone: once only', $r[0] === false && $pack('singing-pebble') === 1);
$fresh(); $at('bridgestone'); foreach ([1, 2] as $a) $tx(fn(&$run, $u) => trek_act_riddle($run, $u, $a));
$r = $tx(fn(&$run, $u) => trek_act_riddle($run, $u, 3)); ok('stone: two wrong answers lock it (v2.0.1: 2 tries)', $r[0] === false && $pack('singing-pebble') === 0);
// pass=1: the walk stops once
foreach ([['cart', 20, 5, 14, 5], ['mushcamp', 8, 19, 8, 23], ['bridgestone', 28, 32, 16, 32]] as [$code, $x1, $y1, $x2, $y2]) {
    $fresh(); $sp = $spots[$code];
    $tx(function (&$run, $u) use ($x1, $y1) { $run['x'] = $x1; $run['y'] = $y1; return [true, '']; });
    $tx(fn(&$run, $u) => trek_walk($run, $u, $x2, $y2)); $R = $run();
    $stopped = $R['x'] === $sp['x'] && $R['y'] === $sp['y'];
    $tx(fn(&$run, $u) => trek_walk($run, $u, $x2, $y2)); $R = $run();
    $through = $R['x'] === $x2 && $R['y'] === $y2;
    $tx(function (&$run, $u) use ($x1, $y1) { $run['x'] = $x1; $run['y'] = $y1; return [true, '']; });
    $tx(fn(&$run, $u) => trek_walk($run, $u, $x2, $y2)); $R = $run();
    ok("$code: the walk stops there the first time only", $stopped && $through && $R['x'] === $x2, json_encode([$stopped, $through, $R['x'], $R['y']]));
}

echo "== crew moments\n";
$fresh();
$tx(function (&$run, $u) { trek_flag_set($run, 'freed_burdock'); trek_recruit_crew($run, $u, 'burdock'); return [true, '']; });
$w = $plainWalk(6);
$R = $run();
ok('Burdock: a moment shows on the 2nd to 4th walk after he joined', $w >= 2 && $w <= 4 && ($R['st']['cm'] ?? '') === 'burdock' && $flag('cm_burdock'), "walk $w");
$more = $plainWalk(8);
ok('Burdock: the card waits (does not repeat or vanish) while untaken', ($run()['st']['cm'] ?? '') === 'burdock');
$p0 = $run()['petals_found']; $r = $tx(fn(&$run, $u) => trek_act_crew($run, $u, 1)); $R = $run();
ok('Burdock: the cache pays 10-18 Petals (carried) and clears the card', $r[0] && $R['petals_found'] - $p0 >= 10 && $R['petals_found'] - $p0 <= 18 && empty($R['st']['cm']), (string)($R['petals_found'] - $p0));
$p1 = $R['petals_found']; $r = $tx(fn(&$run, $u) => trek_act_crew($run, $u, 1));
ok('Burdock: a second tap pays nothing', $r[0] === false && $run()['petals_found'] === $p1);
$plainWalk(10);
ok('Burdock: the moment never comes again this run', empty($run()['st']['cm']) && $flag('cm_burdock'));
$fresh(); $tx(function (&$run, $u) { trek_flag_set($run, 'freed_burdock'); trek_recruit_crew($run, $u, 'burdock'); $run['st']['cm'] = 'burdock'; trek_flag_set($run, 'cm_burdock'); return [true, '']; }); $capPetals();
$tx(fn(&$run, $u) => trek_act_crew($run, $u, 1));
ok('Burdock: the daily Petal limit holds', $run()['petals_found'] === 0 && empty($run()['st']['cm']));
// Zinnia: heals 20%
$fresh();
$tx(function (&$run, $u) { trek_flag_set($run, 'freed_zinnia'); trek_recruit_crew($run, $u, 'zinnia'); return [true, '']; });
$w = $plainWalk(6); $R = $run();
ok('Zinnia: her moment shows on the 2nd to 4th walk', $w >= 2 && $w <= 4 && ($R['st']['cm'] ?? '') === 'zinnia' && $flag('cm_zinnia'), "walk $w");
$st = $tx(fn(&$run, $u) => trek_party_stats($run, $u));
$tx(function (&$run, $u) { foreach ($run['party'] as $s => $p) $run['party'][$s]['hp'] = 1; return [true, '']; });
q('DELETE FROM trek_party WHERE run_id = ? AND slot = 1', [$run()['id']]);   // Zinnia steps out of the party (still recruited)
$r = $tx(fn(&$run, $u) => trek_act_crew($run, $u, 1));
ok('Zinnia: only while she is in the party (refused, card kept)', $r[0] === false && ($run()['st']['cm'] ?? '') === 'zinnia');
db_insert('trek_party', ['run_id' => $run()['id'], 'slot' => 1, 'crew_key' => 'zinnia', 'hp' => 1]);
$r = $tx(fn(&$run, $u) => trek_act_crew($run, $u, 1)); $R = $run();
ok('Zinnia: heals the party by a fifth', $r[0] && $R['party'][0]['hp'] === min($st[0]['max'], 1 + (int)ceil($st[0]['max'] * 0.20)) && empty($R['st']['cm']), $R['party'][0]['hp'] . '/' . $st[0]['max']);
// Bracken: reveals fog + points to the next goal
$fresh();
$tx(function (&$run, $u) { trek_flag_set($run, 'freed_bracken'); trek_recruit_crew($run, $u, 'bracken'); return [true, '']; });
$w = $plainWalk(6); $R = $run();
ok('Bracken: his moment shows on the 2nd to 4th walk', $w >= 2 && $w <= 4 && ($R['st']['cm'] ?? '') === 'bracken' && $flag('cm_bracken'), "walk $w");
$tx(function (&$run, $u) { $run['sn'] = str_repeat("\0", strlen($run['sn'])); trek_seen_reveal($run, (int)$run['x'], (int)$run['y'], 1); return [true, '']; });
$s0 = $seenCount($run());
$r = $tx(fn(&$run, $u) => trek_act_crew($run, $u, 1)); $R = $run();
ok('Bracken: lights up the fog nearby and clears the card', $r[0] && $seenCount($R) > $s0 + 20 && empty($R['st']['cm']), "$s0 -> " . $seenCount($R));
ok('Bracken: the log points toward the next goal', str_contains(strip_tags(implode(' ', array_map('trek_line_html', array_slice($R['lg'], -3)))), 'steps away'));
// skipping
$fresh();
$tx(function (&$run, $u) { trek_flag_set($run, 'freed_zinnia'); trek_recruit_crew($run, $u, 'zinnia'); return [true, '']; });
$plainWalk(6); $hp0 = $run()['party'][0]['hp'];
$tx(function (&$run, $u) { $run['party'][0]['hp'] = 3; return [true, '']; });
$r = $tx(fn(&$run, $u) => trek_act_crew($run, $u, 0));
ok('Not now: clears the card, pays nothing, and it does not come back', $r[0] && empty($run()['st']['cm']) && $run()['party'][0]['hp'] === 3);
$plainWalk(10); ok('...never again', empty($run()['st']['cm']));

echo "== the whole-fight log\n";
$fresh();
$tx(function (&$run, $u) { trek_start_random_fight($run, $u, 'g'); rig_unbeatable($run); for ($i = 0; $i < 30; $i++) trek_fight_round($run, $u, [0 => ["a" => "guard"]]); return [true, '']; });
$R = $run(); $n = count(trek_flog_html($R));
ok('the fight log keeps every line while the run log keeps only the last 30', $n > count($R['lg']) && $n > 30 && !empty($R['st']['flog_on']), "flog $n, lg " . count($R['lg']));
ok('...from the very first line', str_contains(strip_tags(trek_flog_html($R)[0]), 'block'), strip_tags(trek_flog_html($R)[0]));
$tx(function (&$run, $u) { rig_easy($run); $run['fi']['foes'][0]['hp'] = 1; trek_fight_auto($run, $u, 60); return [true, '']; });
$R = $run(); $n2 = count(trek_flog_html($R));
ok('the finished fight keeps its log (win lines included)', !$R['fi'] && $n2 > $n && str_contains(strip_tags(implode(' ', trek_flog_html($R))), 'Defeated'));
$tx(function (&$run, $u) { unset($run['st']['flog_on']); trek_say($run, 'after the fight'); return [true, '']; });
ok('after the next action begins it stops recording', count(trek_flog_html($run())) === $n2);
$tx(function (&$run, $u) { trek_start_random_fight($run, $u, 'g'); rig_easy($run); trek_fight_auto($run, $u, 60); return [true, '']; });
$R = $run(); $l = trek_flog_html($R);
ok('a new fight starts a new log', count($l) < $n2 && str_contains(strip_tags($l[0]), 'block'));
$tx(function (&$run, $u) { trek_start_random_fight($run, $u, 'g'); for ($i = 0; $i < 250; $i++) trek_say($run, 'line ' . $i); rig_easy($run); trek_fight_auto($run, $u, 60); return [true, '']; });
ok('the log is capped (' . TREK_FLOG_KEEP . ' lines)', count($run()['st']['flog']) <= TREK_FLOG_KEEP);

set_setting('trek_event_pct', '12'); set_setting('trek_event_gap', '6'); setting('__reload__');
unset($GLOBALS['trek_test_roll'], $GLOBALS['trek_test_d20']);
echo $fails ? "\n$fails FAILED\n" : "\nall ok\n";
exit($fails ? 1 : 0);
