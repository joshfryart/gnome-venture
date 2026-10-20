<?php
// Treks v2.0.1: riddles have 2 tries, an old run with 2 misses on an opening door heals, the Bracken milestone needs the duel win,
// the daily item cap (trek_items_daily), the Crossroads gate says its "locked" text, item flavour text helpers.
// Run by treks.sh after the Chapter II audit: php tests/trek_201.php GAME_DIR  (clones of the test player "t201_*").
$_SERVER['SCRIPT_NAME'] = '/trek.php';
require $argv[1] . '/includes/bootstrap.php';
require_once $argv[1] . '/includes/trek.php';
if (session_status() !== PHP_SESSION_ACTIVE) session_start();
$fails = 0;
set_exception_handler(function (Throwable $e) { if (db()->inTransaction()) db()->rollBack(); echo '  EXCEPTION ' . get_class($e) . ': ' . $e->getMessage() . ' @ ' . basename($e->getFile()) . ':' . $e->getLine() . "\n"; exit(1); });
function ok(string $what, bool $cond, string $extra = ''): void { global $fails; echo ($cond ? '  ok   ' : '  FAIL ') . $what . ($cond ? '' : "  $extra") . "\n"; if (!$cond) $fails++; }
set_setting('trek_open', '1'); set_setting('trek_event_pct', '0'); set_setting('trek_enc_percent', '0'); set_setting('trek_ambush_pct', '0'); set_setting('trek_petals_daily', '5000'); set_setting('trek_entry_energy', '10');
setting('__reload__');
$n = 0;
function mkuser(): int
{
    global $n;
    $r = q_one("SELECT * FROM users WHERE username = 'sprout'");
    unset($r['id']);
    $n++;
    $r['username'] = 't201_' . $n . '_' . substr(md5((string)microtime(true)), 0, 5); $r['email'] = $r['username'] . '@b.local'; $r['gnome_name'] = 'Tess' . $n; $r['active_plot_id'] = null;
    $r['last_seen'] = now(); $r['level'] = 16; $r['coins'] = 5000; $r['energy'] = 500; $r['calling'] = null; $r['trek_ch'] = 1; $r['trek_pet_day'] = null; $r['trek_pet_today'] = 0; $r['role'] = 'player';
    return db_insert('users', $r);
}

echo "== riddles: 2 tries everywhere\n";
$rid = [];
foreach ([1, 2] as $ch) foreach (trek_spots($ch) as $s) if ($s['type'] === 'riddle') $rid[$ch . '.' . $s['code']] = (int)($s['data']['tries'] ?? 2);
ok('all ' . count($rid) . ' riddles (' . implode(', ', array_keys($rid)) . ') have tries=2', count($rid) >= 5 && !array_filter($rid, fn($t) => $t !== 2), json_encode($rid));
$txt = ''; foreach (q('SELECT brief, body FROM trek_texts')->fetchAll() as $r) $txt .= ' ' . $r['brief'] . ' ' . $r['body'];
ok('no trek text says "three tries" or "third wrong answer"', !preg_match('/three tries|third wrong|3 tries/i', $txt));

$uid = mkuser();
$tx = fn(callable $f, bool $need = true, ?int $ch = null) => trek_tx($uid, $f, $need, $ch);
$run = fn(?int $ch = null) => trek_load(trek_run_row($uid, $ch));
$tx(fn(&$run, $u) => trek_enter($run, $u), false);
$tx(function (&$run, $u) { $run['sn'] = str_repeat("\xff", strlen($run['sn'])); return [true, '']; });
$goto1 = fn(string $c) => $tx(function (&$run, $u) use ($c) { $s = trek_spots(1)[$c]; $run['x'] = $s['x']; $run['y'] = $s['y']; $run['fatigue'] = 0; $run['fi'] = null; return [true, '']; });
$goto1('choir');
$tx(fn(&$run, $u) => trek_act_riddle($run, $u, 1));
$r = $tx(fn(&$run, $u) => trek_act_riddle($run, $u, 3));
$R = $run();
ok('choir: two wrong answers use the tries up, not solved', $r[0] === true && (int)$R['st']['tries_choir'] === 2 && empty($R['flags']['choir_solved']));
$r = $tx(fn(&$run, $u) => trek_act_riddle($run, $u, 2));
ok('choir: a third try (even the right one) is refused', $r[0] === false && empty($run()['flags']['choir_solved']));
$goto1('bridgestone');
$tx(fn(&$run, $u) => trek_act_riddle($run, $u, 1));
$r = $tx(fn(&$run, $u) => trek_act_riddle($run, $u, 3));
ok('riddle stone: wrong then right wins on try 2', $r[0] === true && !empty($run()['flags']['stone_solved']));

echo "== an old run (3 tries) with 2 misses on a door that opens anyway\n";
$tx(function (&$run, $u) { $run['st']['tries_libdoor'] = 0; return [true, '']; });
$uid2 = mkuser();
$tx2 = fn(callable $f, bool $need = true, ?int $ch = null) => trek_tx($uid2, $f, $need, $ch);
$tx2(fn(&$run, $u) => trek_enter($run, $u), false);
$tx2(function (&$run, $u) { foreach (['burdock', 'zinnia', 'bracken'] as $k) trek_recruit_crew($run, $u, $k); trek_complete_chapter($run, $u); trek_hub_arrive($run, $u); return [true, '']; });
$tx2(fn(&$run, $u) => trek_godown($run, $u));
$R2 = trek_load(trek_run_row($uid2, 2));
ok('setup: Chapter II run', (int)$R2['chapter'] === 2);
$tx2(function (&$run, $u) { $run['st']['tries_libdoor'] = 2; $run['st']['tries_signpost'] = 2; return [true, '']; }, true, 2);
$R2 = trek_load(trek_run_row($uid2, 2));
ok('stuck detected: door and signpost spent 2 tries, neither open', trek_riddle_stuck($R2) === true && empty($R2['flags']['libdoor_open']) && empty($R2['flags']['sign_open']));
$tx2(function (&$run, $u) { trek_riddle_heal($run); return [true, '']; }, true, 2);
$R2 = trek_load(trek_run_row($uid2, 2));
ok('healed: both open, neither counted as solved, no longer stuck', !empty($R2['flags']['libdoor_open']) && !empty($R2['flags']['sign_open']) && empty($R2['flags']['libdoor_solved']) && empty($R2['flags']['sign_solved']) && !trek_riddle_stuck($R2));

echo "== Crossroads gate: locked until Silverfin is down; its text is asked for\n";
$cg = trek_spots(2)['crossroads'];
ok('the gate needs silverfin_down; not open on a fresh run; open with the flag', !trek_gate_open($R2, $cg) && trek_gate_open(array_merge($R2, ['flags' => ['silverfin_down' => true]]), $cg));
$xp0 = (int)q_val('SELECT xp FROM users WHERE id = ?', [$uid2]);
$tx2(function (&$run, $u) use ($cg) {
    $run['sn'] = str_repeat("\xff", strlen($run['sn']));
    // bump the locked gate: stand beside it and walk onto it
    $found = false;
    foreach ([[-1, 0], [1, 0], [0, -1], [0, 1]] as [$dx, $dy]) if (trek_passable($run, $cg['x'] + $dx, $cg['y'] + $dy, true)) { $run['x'] = $cg['x'] + $dx; $run['y'] = $cg['y'] + $dy; $found = true; break; }
    $run['lg'] = [];
    if ($found) { $run['campkits'] = 0; trek_walk($run, $u, $cg['x'], $cg['y']); }
    return [true, ''];
}, true, 2);
$R2 = trek_load(trek_run_row($uid2, 2));
$logTxt = json_encode($R2['lg'], JSON_UNESCAPED_UNICODE);
ok('walking at the locked Crossroads gate puts its locked text in the log, pays nothing', str_contains($logTxt, 'ch2.spot.crossroads.locked') && empty($R2['flags']['reached_crossroads']) && empty($R2['st']['ms']['ch2a_end']) && (int)q_val('SELECT xp FROM users WHERE id = ?', [$uid2]) === $xp0, substr($logTxt, 0, 200));

echo "== item flavour text helpers\n";
$notes = trek_item_notes(['blight-shard', 'camp-kit', 'nothing-here']);
ok('trek_item_notes shows blight-shard and camp-kit text, skips unknown slugs', str_contains($notes, 'hums softly') && str_contains($notes, 'rolled bundle') && substr_count($notes, 'tkitemnote') === 2, $notes);

echo "== Bracken: the milestone and its reward need the duel win\n";
$uid3 = mkuser();
$tx3 = fn(callable $f) => trek_tx($uid3, $f, true);
$xp = fn() => (int)q_val('SELECT xp FROM users WHERE id = ?', [$uid3]);
$rows = fn() => (int)q_val("SELECT COUNT(*) FROM trek_ms WHERE user_id = ? AND ms_key LIKE '%bracken'", [$uid3]);
trek_tx($uid3, fn(&$run, $u) => trek_enter($run, $u), false);
$b0 = $xp();
$sp = trek_spots(1)['bracken'];
$tx3(function (&$run, $u) use ($sp) { $run['sn'] = str_repeat("\xff", strlen($run['sn'])); $run['x'] = $sp['x']; $run['y'] = $sp['y']; return [true, '']; });
$r = $tx3(fn(&$run, $u) => trek_act_recruit($run, $u));
ok('the Help button at Bracken (a duel spot) does not free him or pay', empty(trek_load(trek_run_row($uid3))['flags']['freed_bracken']) && $xp() === $b0 && $rows() === 0);
$tx3(fn(&$run, $u) => trek_act_challenge($run, $u));
ok('Challenge starts the duel', !empty(trek_load(trek_run_row($uid3))['fi']['meta']['duel']));
$tx3(function (&$run, $u) { trek_fight_end($run, $u, false); return [true, '']; });
$R3 = trek_load(trek_run_row($uid3));
ok('duel LOST: no flag, no milestone, no trek_ms row, no gnome XP, not in the party', empty($R3['flags']['freed_bracken']) && empty($R3['flags']['ms_bracken']) && $rows() === 0 && $xp() === $b0 && !in_array('bracken', trek_recruits((int)$R3['id']), true));
$tx3(fn(&$run, $u) => trek_act_challenge($run, $u));
$tx3(function (&$run, $u) { trek_fight_end($run, $u, true); return [true, '']; });
$R3 = trek_load(trek_run_row($uid3));
ok('duel WON: freed, in the party, milestone paid once (a trek_ms row, XP up)', !empty($R3['flags']['freed_bracken']) && !empty($R3['flags']['ms_bracken']) && $rows() === 1 && $xp() > $b0 && in_array('bracken', trek_recruits((int)$R3['id']), true));
$b1 = $xp();
$tx3(function (&$run, $u) { trek_ms_award($run, $u, 'bracken'); return [true, '']; });
ok('asking again pays nothing more', $xp() === $b1 && $rows() === 1);

echo "== v2.0.7: a 4th trailmate with all 3 places taken is benched and the caller is told\n";
$uid7 = mkuser();
$tx7 = fn(callable $f) => trek_tx($uid7, $f, true);
trek_tx($uid7, fn(&$run, $u) => trek_enter($run, $u), false);
$got = [];
$tx7(function (&$run, $u) use (&$got) { foreach (['burdock', 'zinnia', 'bracken'] as $k) $got[$k] = trek_recruit_crew($run, $u, $k); $got['sorrel'] = trek_recruit_crew($run, $u, 'sorrel'); $got['dup'] = trek_recruit_crew($run, $u, 'sorrel'); return [true, '']; });
$R7 = trek_load(trek_run_row($uid7));
ok('the first three are placed (true)', $got['burdock'] === true && $got['zinnia'] === true && $got['bracken'] === true);
ok('the 4th returns false: recruited but no place', $got['sorrel'] === false && in_array('sorrel', trek_recruits((int)$R7['id']), true) && !in_array('sorrel', array_column($R7['party'], 'crew_key'), true));
ok('asking for the same trailmate again returns true (nothing to say)', $got['dup'] === true);
ok('the note names the trailmate and says the party is full', strpos(trek_benched_line('Sorrel Inkcap'), 'Sorrel') !== false && strpos(trek_benched_line('Sorrel Inkcap'), 'party is full') !== false);

$uid4 = mkuser();
$tx4 = fn(callable $f) => trek_tx($uid4, $f, true);
trek_tx($uid4, fn(&$run, $u) => trek_enter($run, $u), false);
$tx4(function (&$run, $u) { trek_recruit_crew($run, $u, 'bracken'); return [true, '']; });   // in the party WITHOUT the duel (a bug, a hand edit)
$c0 = (int)q_val('SELECT xp FROM users WHERE id = ?', [$uid4]);
$tx4(function (&$run, $u) { unset($run['st']['tl']); trek_tl_migrate($run, $u); return [true, '']; });   // the only place that treats "in the party" as passed
$R4 = trek_load(trek_run_row($uid4));
ok('migration marks the milestone passed but pays NO XP and gives no reward', !empty($R4['flags']['ms_bracken']) && (int)q_val('SELECT xp FROM users WHERE id = ?', [$uid4]) === $c0 && (int)q_val("SELECT xp FROM trek_ms WHERE user_id = ? AND ms_key LIKE '%bracken'", [$uid4]) === 0);
$tx4(function (&$run, $u) { trek_ms_award($run, $u, 'bracken'); return [true, '']; });
ok('and nothing pays it later', (int)q_val('SELECT xp FROM users WHERE id = ?', [$uid4]) === $c0);

echo "== trek_items_daily\n";
q('UPDATE creature_drops SET chance = 100');
$uid5 = mkuser();
$tx5 = fn(callable $f) => trek_tx($uid5, $f, true);
trek_tx($uid5, fn(&$run, $u) => trek_enter($run, $u), false);
$tx5(function (&$run, $u) { $run['sn'] = str_repeat("\xff", strlen($run['sn'])); return [true, '']; });
$carried = fn() => (int)q_val('SELECT COALESCE(SUM(qty),0) FROM trek_pack WHERE run_id = (SELECT id FROM trek_runs WHERE user_id = ?) AND banked = 0', [$uid5]);
$win = function () use ($tx5) {
    $tx5(function (&$run, $u) {
        $run['fi'] = null; trek_start_random_fight($run, $u, 'w');
        foreach ($run['fi']['foes'] as $i => $f) { $run['fi']['foes'][$i]['hp'] = 1; }
        trek_fight_win($run, $u);
        $run['fi'] = null;
        return [true, ''];
    });
};
set_setting('trek_items_daily', '0'); setting('__reload__');
for ($i = 0; $i < 4; $i++) $win();
$off = $carried();
ok('cap OFF (0): every fight keeps leaving items (' . $off . ' carried after 4 wins)', $off >= 4);
ok('cap OFF: nothing is counted on the users row', q_val('SELECT trek_item_today FROM users WHERE id = ?', [$uid5]) === null || (int)q_val('SELECT trek_item_today FROM users WHERE id = ?', [$uid5]) === 0);
$tx5(function (&$run, $u) { q('DELETE FROM trek_pack WHERE run_id = ?', [(int)$run['id']]); return [true, '']; });
set_setting('trek_items_daily', '3'); setting('__reload__');
for ($i = 0; $i < 6; $i++) $win();
$on = $carried();
ok('cap ON (3): exactly 3 items carried after 6 wins with 100% drops', $on === 3, (string)$on);
ok('the count is on the users row for today', (int)q_val('SELECT trek_item_today FROM users WHERE id = ?', [$uid5]) === 3 && q_val('SELECT trek_item_day FROM users WHERE id = ?', [$uid5]) === hollow_date('Y-m-d'));
$lg = json_encode(trek_load(trek_run_row($uid5))['lg'], JSON_UNESCAPED_UNICODE);
ok('the log says you cannot carry more today', str_contains($lg, 'all you can carry today'));
q('UPDATE users SET trek_item_day = ? WHERE id = ?', ['2000-01-01', $uid5]);
$win();
ok('a new Hollow day resets the count', (int)q_val('SELECT trek_item_today FROM users WHERE id = ?', [$uid5]) >= 1 && $carried() > $on);
// quest items never capped
q('UPDATE users SET trek_item_day = ?, trek_item_today = 99 WHERE id = ?', [hollow_date('Y-m-d'), $uid5]);
$tx5(function (&$run, $u) { $run['st']['kills'] = []; trek_pack_add((int)$run['id'], trek_item_id('cellar-key'), 1); return [true, '']; });
ok('quest items still go into the pack at the cap (pack_add is not gated)', (int)q_val('SELECT COALESCE(SUM(qty),0) FROM trek_pack WHERE run_id = (SELECT id FROM trek_runs WHERE user_id = ?) AND item_id = ?', [$uid5, trek_item_id('cellar-key')]) === 1);
$q = trek_item_id('cellar-key');
q('UPDATE creature_drops SET item_id = ?, chance = 100', [$q]);
$before = (int)q_val('SELECT COALESCE(SUM(qty),0) FROM trek_pack WHERE run_id = (SELECT id FROM trek_runs WHERE user_id = ?) AND item_id = ?', [$uid5, $q]);
for ($i = 0; $i < 3; $i++) $win();
ok('a quest item DROP is not capped even at the limit (every drop made a cellar-key at 100%)', (int)q_val('SELECT COALESCE(SUM(qty),0) FROM trek_pack WHERE run_id = (SELECT id FROM trek_runs WHERE user_id = ?) AND item_id = ?', [$uid5, $q]) > $before);
set_setting('trek_items_daily', '0'); setting('__reload__');
echo $fails ? "$fails FAILED\n" : "all ok\n";
exit($fails ? 1 : 0);
