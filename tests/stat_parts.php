<?php
// 2.8.90: eff_stat_parts() (the base + named boosts on the Gnome page) must always add up to eff_stat(). Usage: php tests/stat_parts.php GAME_DIR
$game = $argv[1] ?? __DIR__ . '/../game';
chdir($game);
require $game . '/includes/bootstrap.php';
$fail = 0;
$ok = function (string $n, bool $c) use (&$fail) { echo ($c ? 'ok   ' : 'FAIL ') . $n . "\n"; if (!$c) $fail++; };
$u = q_one("SELECT * FROM users ORDER BY id LIMIT 1");
$until = date('Y-m-d H:i:s', time() + 3600);
$cases = [
    'plain' => [],
    'meal' => ['buff' => json_encode(['nimble' => 2]), 'buff_until' => $until],
    'two meals' => ['buff' => json_encode(['nimble' => 2]), 'buff_until' => $until, 'buff2' => json_encode(['nimble' => 1]), 'buff2_until' => $until],
    'town' => ['town_stat' => 'nimble', 'town_amt' => 3, 'town_until' => $until],
    'lucky' => ['ev_stat' => 'all', 'ev_amt' => 1, 'ev_until' => $until, 'ev_scope' => '', 'ev_day' => null],
];
foreach ($cases as $name => $over) {
    $x = $over + $u;
    foreach (array_keys(GNOME_STATS) as $k) {
        $p = eff_stat_parts($x, $k);
        if ($p['total'] !== eff_stat($x, $k) || $p['base'] !== (int)$x['stat_' . $k]) { $ok("$name / $k adds up", false); continue 2; }
    }
    $ok("$name: every stat adds up", true);
}
$x = $cases['meal'] + $u; $p = eff_stat_parts($x, 'nimble');
$ok('a meal shows as a named part', $p['parts'] === [['Meal', 2]]);
exit($fail ? 1 : 0);
