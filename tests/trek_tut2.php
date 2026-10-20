<?php
// Treks v2.0.20: the first-won-fight lesson per chapter. Chapter II gets ch2.tut.firstfight on its first win when its own slot is written;
// a chapter with an empty own slot never falls back to Chapter I's Snack/Auto lesson; Chapter I is unchanged; the lesson logs once per run.
// Run on an installed copy: php tests/trek_tut2.php GAME_DIR  (clones of the test player "tut2_*", the sprout row).
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
function tut2_mkuser(): int
{
    global $n;
    $r = q_one("SELECT * FROM users WHERE username = 'sprout'");
    unset($r['id']);
    $n++;
    $r['username'] = 'tut2_' . $n . '_' . substr(md5((string)microtime(true)), 0, 5); $r['email'] = $r['username'] . '@b.local'; $r['gnome_name'] = 'Tut' . $n; $r['active_plot_id'] = null;
    $r['last_seen'] = now(); $r['level'] = 16; $r['coins'] = 5000; $r['energy'] = 500; $r['calling'] = null; $r['trek_ch'] = 1; $r['trek_pet_day'] = null; $r['trek_pet_today'] = 0; $r['role'] = 'player';
    return db_insert('users', $r);
}
// one random fight in a zone, every foe at 1 hp, then the win; the fight is cleared after
function tut2_win_fight(int $uid, ?int $ch, string $zone): bool
{
    $started = false;
    trek_tx($uid, function (&$run, $u) use ($zone, &$started) {
        $run['fi'] = null; trek_start_random_fight($run, $u, $zone);
        if (!$run['fi']) return [true, ''];
        $started = true;
        foreach ($run['fi']['foes'] as $i => $f) $run['fi']['foes'][$i]['hp'] = 1;
        trek_fight_win($run, $u);
        $run['fi'] = null;
        return [true, ''];
    }, true, $ch);
    return $started;
}
// the keys of the run log lines (lesson lines are logged with their slot key)
function tut2_log_keys(int $uid, ?int $ch): array
{
    return array_values(array_filter(array_column(trek_load(trek_run_row($uid, $ch))['lg'], 'k'), 'is_string'));
}
function tut2_count_key(array $keys, string $k): int { return count(array_filter($keys, fn($x) => $x === $k)); }

echo "== data: the Chapter II slot and the trap\n";
$saved2 = (string)q_val("SELECT body FROM trek_texts WHERE text_key = 'ch2.tut.firstfight'");
ok('ch2.tut.firstfight row exists and has a written body', $saved2 !== '', json_encode($saved2));
ok('body is at most 200 chars', mb_strlen($saved2) <= 200, (string)mb_strlen($saved2));
ok('body has no Snack / Auto lesson', !preg_match('/snack|auto/i', $saved2));

echo "== Chapter I unchanged\n";
$u1 = tut2_mkuser();
trek_tx($u1, fn(&$run, $u) => trek_enter($run, $u), false);
$started = tut2_win_fight($u1, 1, 'w');
ok('a Chapter I fight starts', $started);
$k1 = tut2_log_keys($u1, 1);
ok('Chapter I first win logs ch1.tut.firstfight once', tut2_count_key($k1, 'ch1.tut.firstfight') === 1, json_encode($k1));
tut2_win_fight($u1, 1, 'w');
ok('Chapter I second win does not log it again', tut2_count_key(tut2_log_keys($u1, 1), 'ch1.tut.firstfight') === 1);
ok('Chapter I never logs a ch2 lesson', tut2_count_key(tut2_log_keys($u1, 1), 'ch2.tut.firstfight') === 0);

echo "== Chapter II: first win shows its own lesson\n";
// the same walk into Chapter II as trek_ch2.php: finish Chapter I, then go down
function tut2_to_ch2(int $uid): void
{
    q('UPDATE users SET level = 16, energy = 100, coins = 1000, calling = NULL, trek_ch = 1, trek_pet_day = NULL, trek_pet_today = 0 WHERE id = ?', [$uid]);
    trek_tx($uid, fn(&$run, $u) => trek_enter($run, $u), false);
    trek_tx($uid, function (&$run, $u) {
        foreach (['burdock', 'zinnia', 'bracken'] as $k) trek_recruit_crew($run, $u, $k);
        $run['st']['tl']['gnome'] = [10, 5]; $run['st']['tl']['burdock'] = [9, 0]; $run['st']['tl']['zinnia'] = [9, 0]; $run['st']['tl']['bracken'] = [9, 0];
        $run['campkits'] = 2; trek_flag_set($run, 'seen_cart'); trek_complete_chapter($run, $u); trek_hub_arrive($run, $u);
        return [true, ''];
    });
    trek_tx($uid, fn(&$run, $u) => trek_godown($run, $u));
}
$u2 = tut2_mkuser();
tut2_to_ch2($u2);
ok('the run is Chapter II', trek_active_ch($u2) === 2, (string)trek_active_ch($u2));
$started = tut2_win_fight($u2, 2, 'j');
ok('a Chapter II fight starts', $started);
$k2 = tut2_log_keys($u2, 2);
ok('Chapter II first win logs ch2.tut.firstfight once', tut2_count_key($k2, 'ch2.tut.firstfight') === 1, json_encode($k2));
ok('and no Chapter I lesson line in Chapter II', tut2_count_key($k2, 'ch1.tut.firstfight') === 0);
tut2_win_fight($u2, 2, 'j');
ok('Chapter II second win does not log it again', tut2_count_key(tut2_log_keys($u2, 2), 'ch2.tut.firstfight') === 1);

echo "== Chapter II: empty own slot, no Chapter I fallback\n";
// the engine's text row falls back to Chapter I when the Chapter II body is empty; the lesson must not use that row
q("UPDATE trek_texts SET body = '' WHERE text_key = 'ch2.tut.firstfight'"); trek_text_rows(true);
$fb = trek_text_row('ch2.tut.firstfight');
ok('the generic row would fall back to Chapter I (why the own-slot check exists)', ($fb['text_key'] ?? '') === 'ch1.tut.firstfight', json_encode($fb['text_key'] ?? null));
$u3 = tut2_mkuser();
tut2_to_ch2($u3);
tut2_win_fight($u3, 2, 'j');
$k3 = tut2_log_keys($u3, 2);
ok('empty ch2 slot: first win logs no ch2 lesson', tut2_count_key($k3, 'ch2.tut.firstfight') === 0, json_encode($k3));
ok('empty ch2 slot: first win logs no Chapter I lesson', tut2_count_key($k3, 'ch1.tut.firstfight') === 0, json_encode($k3));
q("UPDATE trek_texts SET body = ? WHERE text_key = 'ch2.tut.firstfight'", [$saved2]); trek_text_rows(true);
ok('row restored', trim((string)q_val("SELECT body FROM trek_texts WHERE text_key = 'ch2.tut.firstfight'")) === trim($saved2));

echo "\n" . ($fails ? "FAILED: $fails\n" : "all ok\n");
exit($fails ? 1 : 0);
