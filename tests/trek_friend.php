<?php
// Treks v2.0.20: friendship from fights. Every 20 won fights each party trailmate gets +1 friendship; at most trek_friend_daily awards per gnome per
// Hollow day; benched trailmates get nothing; a reload never pays twice. Run on an installed copy: php tests/trek_friend.php GAME_DIR (clones of "tfr_*").
$_SERVER['SCRIPT_NAME'] = '/trek.php';
require $argv[1] . '/includes/bootstrap.php';
require_once $argv[1] . '/includes/trek.php';
if (session_status() !== PHP_SESSION_ACTIVE) session_start();
$fails = 0;
set_exception_handler(function (Throwable $e) { if (db()->inTransaction()) db()->rollBack(); echo '  EXCEPTION ' . get_class($e) . ': ' . $e->getMessage() . ' @ ' . basename($e->getFile()) . ':' . $e->getLine() . "\n"; exit(1); });
function ok(string $what, bool $cond, string $extra = ''): void { global $fails; echo ($cond ? '  ok   ' : '  FAIL ') . $what . ($cond ? '' : "  $extra") . "\n"; if (!$cond) $fails++; }
set_setting('trek_open', '1'); set_setting('trek_event_pct', '0'); set_setting('trek_enc_percent', '0'); set_setting('trek_ambush_pct', '0'); set_setting('trek_petals_daily', '5000'); set_setting('trek_entry_energy', '10');
set_setting('trek_friend_daily', '3'); setting('__reload__');
$n = 0;
function tfr_mkuser(): int
{
    global $n;
    $r = q_one("SELECT * FROM users WHERE username = 'sprout'");
    unset($r['id']);
    $n++;
    $r['username'] = 'tfr_' . $n . '_' . substr(md5((string)microtime(true)), 0, 5); $r['email'] = $r['username'] . '@b.local'; $r['gnome_name'] = 'Fri' . $n; $r['active_plot_id'] = null;
    $r['last_seen'] = now(); $r['level'] = 16; $r['coins'] = 5000; $r['energy'] = 500; $r['calling'] = null; $r['trek_ch'] = 1; $r['trek_pet_day'] = null; $r['trek_pet_today'] = 0; $r['role'] = 'player';
    return db_insert('users', $r);
}
// one random fight won (every foe at 1 hp, then the win), as the round action would close it
function tfr_win(int $uid): void
{
    trek_tx($uid, function (&$run, $u) {
        $run['fi'] = null; trek_start_random_fight($run, $u, 'w');
        if (!$run['fi']) return [true, ''];
        foreach ($run['fi']['foes'] as $i => $f) $run['fi']['foes'][$i]['hp'] = 1;
        trek_fight_win($run, $u);
        $run['fi'] = null;
        return [true, ''];
    });
}
function tfr_wins(int $uid, int $k): void { for ($i = 0; $i < $k; $i++) tfr_win($uid); }
function tfr_pts(int $uid, string $crew): int { return (int)friendship($uid, (int)trek_crew_npc($crew)['id'])['points']; }
function tfr_ff(int $uid): int { return (int)(trek_load(trek_run_row($uid))['st']['ff'] ?? 0); }
function tfr_day_state(int $uid): array { return json_decode((string)q_val('SELECT state FROM game_state WHERE user_id = ? AND game = ?', [$uid, 'trek_friend']), true) ?: []; }
function tfr_reset_day(int $uid): void { q('DELETE FROM game_state WHERE user_id = ? AND game = ?', [$uid, 'trek_friend']); }
function tfr_log(int $uid): array { return array_values(array_filter(array_column(trek_load(trek_run_row($uid))['lg'], 's'), 'is_string')); }

// a Chapter I run with three trailmates in the party
$u = tfr_mkuser();
trek_tx($u, fn(&$run, $uu) => trek_enter($run, $uu), false);
trek_tx($u, function (&$run, $uu) { foreach (['burdock', 'zinnia', 'bracken'] as $k) trek_recruit_crew($run, $uu, $k); return [true, '']; });
$party = array_values(array_filter(array_column(trek_load(trek_run_row($u))['party'] ?? [], 'crew_key'), fn($c) => $c !== 'gnome'));
ok('three trailmates in the party', count($party) === 3, json_encode($party));
ok('the gnome in the party (crew key gnome) is no npc, so never gets friendship', (int)trek_crew_npc('gnome')['id'] === 0);
$p0 = ['burdock' => tfr_pts($u, 'burdock'), 'zinnia' => tfr_pts($u, 'zinnia'), 'bracken' => tfr_pts($u, 'bracken')];

echo "== 19 won fights pay nothing, the 20th pays once\n";
tfr_wins($u, 19);
ok('19 wins: no friendship moves', tfr_pts($u, 'burdock') === $p0['burdock'] && tfr_pts($u, 'zinnia') === $p0['zinnia'] && tfr_pts($u, 'bracken') === $p0['bracken']);
ok('19 wins: counter at 19', tfr_ff($u) === 19, (string)tfr_ff($u));
tfr_wins($u, 1);
ok('20th win: each party trailmate +1', tfr_pts($u, 'burdock') === $p0['burdock'] + 1 && tfr_pts($u, 'zinnia') === $p0['zinnia'] + 1 && tfr_pts($u, 'bracken') === $p0['bracken'] + 1);
ok('20th win: counter reset to 0', tfr_ff($u) === 0);
$name = (string)trek_crew_npc('burdock')['name'];
ok('20th win: one plain log line per trailmate', in_array($name . ' likes you a little more.', tfr_log($u), true), json_encode(array_slice(tfr_log($u), -4)));
ok('one award is one day count (n=1)', (int)(tfr_day_state($u)['n'] ?? 0) === 1, json_encode(tfr_day_state($u)));

echo "== reload does not pay again\n";
$before = tfr_pts($u, 'burdock');
trek_tx($u, fn(&$run, $uu) => [true, '']);   // a reload: the run is read and saved, no fight closes
ok('plain reload: no new award, counter still 0', tfr_pts($u, 'burdock') === $before && tfr_ff($u) === 0);

echo "== daily cap\n";
set_setting('trek_friend_daily', '1'); setting('__reload__');
tfr_wins($u, 40);
ok('cap 1, one award already today: 40 more wins pay nothing', tfr_pts($u, 'burdock') === $before, (string)tfr_pts($u, 'burdock'));
ok('daily count stays at 1', (int)(tfr_day_state($u)['n'] ?? 0) === 1);
set_setting('trek_friend_daily', '0'); setting('__reload__');
$cur = tfr_pts($u, 'burdock');
tfr_wins($u, 20);
ok('setting 0 = off: 20 wins pay nothing', tfr_pts($u, 'burdock') === $cur);

echo "== next Hollow day resumes\n";
set_setting('trek_friend_daily', '1'); setting('__reload__');
$yesterday = gmdate('Y-m-d', strtotime(hollow_date('Y-m-d')) - 86400);
q('UPDATE game_state SET state = ? WHERE user_id = ? AND game = ?', [json_encode(['day' => $yesterday, 'n' => 1]), $u, 'trek_friend']);
tfr_wins($u, 20);
ok('new day: the 20th win pays again', tfr_pts($u, 'burdock') === $cur + 1, (string)tfr_pts($u, 'burdock'));
ok('new day: count is 1 for today', (int)(tfr_day_state($u)['n'] ?? 0) === 1 && tfr_day_state($u)['day'] === hollow_date('Y-m-d'), json_encode(tfr_day_state($u)));

echo "== setting parse\n";
set_setting('trek_friend_daily', 'abc'); setting('__reload__');
ok('a non-number falls back to 3', trek_friend_daily_cap() === 3);
set_setting('trek_friend_daily', '99'); setting('__reload__');
ok('above 20 clamps to 20', trek_friend_daily_cap() === 20);
set_setting('trek_friend_daily', '-4'); setting('__reload__');
ok('below 0 clamps to 0 (off)', trek_friend_daily_cap() === 0);
set_setting('trek_friend_daily', '3'); setting('__reload__');

echo "== benched trailmates get nothing\n";
$b = tfr_mkuser();
trek_tx($b, fn(&$run, $uu) => trek_enter($run, $uu), false);
trek_tx($b, function (&$run, $uu) { foreach (['burdock', 'zinnia', 'bracken'] as $k) trek_recruit_crew($run, $uu, $k); return [true, '']; });
tfr_reset_day($b);
$bz = tfr_pts($b, 'zinnia'); $bb = tfr_pts($b, 'burdock');
trek_tx($b, function (&$run, $uu) {   // bench Zinnia: out of the party, still a recruit
    foreach ($run['party'] as $slot => $p) if (($p['crew_key'] ?? '') === 'zinnia') { unset($run['party'][$slot]); q('DELETE FROM trek_party WHERE run_id = ? AND slot = ?', [(int)$run['id'], $slot]); }
    return [true, ''];
});
tfr_wins($b, 20);
ok('benched Zinnia gains nothing', tfr_pts($b, 'zinnia') === $bz);
ok('party trailmate Burdock gains +1', tfr_pts($b, 'burdock') === $bb + 1, (string)tfr_pts($b, 'burdock'));

echo "\n" . ($fails ? "FAILED: $fails\n" : "all ok\n");
exit($fails ? 1 : 0);
