<?php
// 2.8.55 dock time of day: dock_tod_band() bands (day 06:00-16:59, golden hour 17:00-19:59, night 20:00 on and before 06:00) and dock_tod() / the dock JSON on an installed game.
// php tests/dock_tod.php GAME_DIR   (an installed game with player "sprout"; walk.sh installs one)
require $argv[1] . '/includes/bootstrap.php';
require_once $argv[1] . '/includes/dock.php';
$fails = 0;
function ok(string $what, bool $cond, string $extra = ''): void { global $fails; echo ($cond ? '  ok   ' : '  FAIL ') . $what . ($cond ? '' : "  $extra") . "\n"; if (!$cond) $fails++; }

echo "== bands\n";
foreach ([0 => 'night', 359 => 'night', 360 => 'day', 660 => 'day', 1019 => 'day', 1020 => 'gold', 1199 => 'gold', 1200 => 'night', 1320 => 'night', 1439 => 'night', 1440 => 'night', 1500 => 'night', 2000 => 'night'] as $m => $want) {
    ok("minute $m is $want", dock_tod_band($m) === $want, 'got ' . dock_tod_band($m));
}

echo "== the player's game clock\n";
$u = q_one("SELECT * FROM users WHERE username = 'sprout'");
ok('sprout exists', (bool)$u);
set_setting('game_clock_on', '1'); setting('__reload__');
foreach ([600 => 'day', 1080 => 'gold', 1330 => 'night'] as $m => $want) {
    $u['game_minute'] = $m;
    ok("game clock $m gives $want", dock_tod($u) === $want, 'got ' . dock_tod($u));
}
q('UPDATE users SET game_minute = 1080 WHERE id = ?', [(int)$u['id']]);
$st = dock_status($u);
ok('dock_status carries tod', ($st['tod'] ?? '') === 'gold', json_encode($st['tod'] ?? null));

echo "== clock off: the Hollow's real hour\n";
set_setting('game_clock_on', '0'); setting('__reload__');
ok('clock is off', !gclock_on());
$want = dock_tod_band(60 * (int)hollow_date('G'));
ok('clock off follows the Hollow hour', dock_tod($u) === $want, dock_tod($u) . ' vs ' . $want);
set_setting('game_clock_on', '1'); setting('__reload__');

echo $fails ? "$fails FAILED\n" : "ok\n";
exit($fails ? 1 : 0);
