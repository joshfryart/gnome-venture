<?php
// Dock badges: game tiles carry none, the Garden tile = harvest-ready crops (empty at 0), the Hobbies sum follows. php tests/dock_badges.php GAME_DIR (installed game with player "sprout")
require $argv[1] . '/includes/bootstrap.php';
require_once $argv[1] . '/includes/dock.php';
$fails = 0;
function ok(string $what, bool $cond, string $extra = ''): void { global $fails; echo ($cond ? '  ok   ' : '  FAIL ') . $what . ($cond ? '' : "  $extra") . "\n"; if (!$cond) $fails++; }
function tiles(array $u): array { [$m] = dock_menus($u, 'gnome.php'); $o = []; foreach ($m as $x) foreach ($x['tiles'] as $t) $o[$t['label']] = $t; return $o + ['_hobby' => array_values(array_filter($m, fn($x) => $x['k'] === 'hobby'))[0]]; }
$u = q_one("SELECT * FROM users WHERE username = 'sprout'");
ok('sprout exists', (bool)$u);
$ready = "SELECT COUNT(*) FROM plot_tiles t JOIN plants p ON p.id = t.plant_id WHERE t.plot_id = ? AND p.kind <> 'cover' AND t.growth_seconds >= p.grow_minutes * 60";
$pid = (int)($u['active_plot_id'] ?? 0);
unset($_SESSION['nav_badges']);
$t = tiles($u);
ok('Garden badge equals ready count', $t['Garden']['badge'] === ((($n = (int)q_val($ready, [$pid])) > 0) ? (string)$n : ''), json_encode($t['Garden']['badge']));
// force two ready crops, then none
$plant = q_one("SELECT * FROM plants WHERE kind <> 'cover' ORDER BY id LIMIT 1");
$tiles2 = q('SELECT id FROM plot_tiles WHERE plot_id = ? ORDER BY id LIMIT 2', [$pid])->fetchAll(PDO::FETCH_ASSOC);
ok('plot has tiles and a plant exists', $plant && count($tiles2) === 2);
foreach ($tiles2 as $r) q('UPDATE plot_tiles SET plant_id = ?, growth_seconds = ? WHERE id = ?', [(int)$plant['id'], (int)$plant['grow_minutes'] * 60 + 5, (int)$r['id']]);
unset($_SESSION['nav_badges']);
$n = (int)q_val($ready, [$pid]); $t = tiles($u);
ok('ready count is at least 2', $n >= 2, (string)$n);
ok("Garden badge is $n", $t['Garden']['badge'] === (string)$n, json_encode($t['Garden']['badge']));
ok('Hobbies menu sum is the Garden count, no game badge', $t['Games']['badge'] === '' && array_sum(array_map(fn($x) => ctype_digit($x['badge']) ? (int)$x['badge'] : 0, $t['_hobby']['tiles'])) === $n);
foreach ($tiles2 as $r) q('UPDATE plot_tiles SET growth_seconds = 0 WHERE id = ?', [(int)$r['id']]);
q('UPDATE plot_tiles SET growth_seconds = 0 WHERE plot_id = ?', [$pid]);
$t = tiles($u);
ok('Garden badge empty at 0 ready', $t['Garden']['badge'] === '', json_encode($t['Garden']['badge']));
echo "== sleep-days clock: a crop that finished overnight counts before the garden page loads\n";
$fast = q_one("SELECT * FROM plants WHERE kind <> 'cover' AND grow_minutes <= 20 ORDER BY id LIMIT 1");
ok('a one-sleep plant exists', (bool)$fast);
if ($fast) {
    q("INSERT OR REPLACE INTO settings (name, value) VALUES ('game_clock_on', '1')");
    $gd = 5;
    q('UPDATE users SET game_day = ? WHERE id = ?', [$gd, (int)$u['id']]);
    $u = q_one('SELECT * FROM users WHERE id = ?', [(int)$u['id']]);
    gclock_plot_clock(0, true);   // the plot owner's day is memoised per request
    ok('clock is on', gclock_on());
    $tid = (int)$tiles2[0]['id'];
    q('UPDATE plot_tiles SET plant_id = ?, growth_seconds = 0, grow_day = ?, water_day = ?, owed_days = 0, pest = 0 WHERE id = ?', [(int)$fast['id'], $gd - 1, $gd - 1, $tid]);
    ok('stored growth is still 0 (nothing settled it)', (int)q_val('SELECT growth_seconds FROM plot_tiles WHERE id = ?', [$tid]) === 0);
    ok('dock_garden_ready counts it', dock_garden_ready($u) === 1, (string)dock_garden_ready($u));
    unset($_SESSION['nav_badges']);
    ok('menu badge (nav_groups) counts it', (function () use ($u) { nav_groups($u, 'gnome.php'); return ($_SESSION['nav_badges']['garden'] ?? -1) === 1; })());
    ok('dock Garden tile carries badge 1 and slug garden', tiles($u)['Garden']['badge'] === '1' && tiles($u)['Garden']['slug'] === 'garden');
    ok('counting wrote nothing', (int)q_val('SELECT growth_seconds FROM plot_tiles WHERE id = ?', [$tid]) === 0);
    q('UPDATE plot_tiles SET plant_id = NULL, growth_seconds = 0, grow_day = NULL, water_day = NULL WHERE id = ?', [$tid]);
    q('UPDATE users SET game_day = 0 WHERE id = ?', [(int)$u['id']]);
    q("DELETE FROM settings WHERE name = 'game_clock_on'");
}
echo "== game tiles\n";
foreach ($t as $k => $x) if ($k !== '_hobby' && in_array($x['icon'], ['games'], true)) ok("$k has no badge", $x['badge'] === '');
$_SESSION['nav_badges'] = ['at' => time(), 'garden' => 0, 'games' => 5, 'fair' => 1];
$t = tiles($u);
ok('Games tile empty even with plays left and a fair entry', $t['Games']['badge'] === '', json_encode($t['Games']['badge']));
echo $fails ? "$fails FAILED\n" : "ok\n";
exit($fails ? 1 : 0);
