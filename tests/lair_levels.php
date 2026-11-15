<?php
// 2.7.00 lair levels: every lair sits at region level + 4 (route level - 2 .. + 2), the Owl den stays Lv 10, the Silverback Lv 20, the OC keeper Lv 37.
// Old worlds (medium lairs Lv 16, hard lairs Lv 30) take the new level in one boot, fought or charmed ones too; a second boot changes nothing.
// php tests/lair_levels.php GAME_DIR   (an installed game, already booted)
$_SERVER['SCRIPT_NAME'] = '/adventure.php';
require $argv[1] . '/includes/bootstrap.php';
require_once $argv[1] . '/includes/roads.php';
$fails = 0;
set_exception_handler(function (Throwable $e) { echo '  EXCEPTION ' . get_class($e) . ': ' . $e->getMessage() . ' @ ' . basename($e->getFile()) . ':' . $e->getLine() . "\n"; exit(1); });
function ok(string $what, bool $cond, string $extra = ''): void { global $fails; echo ($cond ? '  ok   ' : '  FAIL ') . $what . ($cond ? '' : "  $extra") . "\n"; if (!$cond) $fails++; }
// literal on purpose: the test must not read its expected values from the constant it checks
$want = ['Smokecap Caldera' => 8, 'Barrow of the Frost Toad' => 10, 'Lair of the Hurricane Crab' => 12, 'Forge of the Cinder Wyrm' => 14,
    'Lair of the Grey Wolf King' => 18, 'Tomb of the Sand Scarab' => 21, 'Lair of the Jade Dragon-fly' => 24,
    'Temple of the Tiger Moth' => 27, 'Dragonlizard Den' => 30, 'Snowcrown Peak' => 36, 'Reef of the Box Jelly Queen' => 37,
    'Den of the Great White Owl' => 10, 'Hollow of the Silverback Spider' => 20];
$route = fn(string $n) => q_one("SELECT MAX(r.level) AS lv, MIN(r.min_level) AS mn, MAX(r.max_level) AS mx FROM routes r JOIN locations l ON (l.id = r.a_id OR l.id = r.b_id) WHERE r.kind = 'side' AND l.name = ?", [$n]);
$boss = fn(string $n) => q_one("SELECT c.level, c.hp FROM creatures c JOIN locations l ON c.slug = 'boss-' || l.slug WHERE l.name = ?", [$n]);
echo "== a fresh world\n";
foreach ($want as $n => $lv) {
    $r = $route($n);
    ok("$n route level $lv (" . ($lv - 2) . '..' . ($lv + 2) . ')', $r && (int)$r['lv'] === $lv && (int)$r['mn'] === $lv - 2 && (int)$r['mx'] === $lv + 2, json_encode($r));
    $b = $boss($n);
    ok("$n boss level $lv", $b && (int)$b['level'] === $lv, json_encode($b));
}
ok('no lair is above Lv 37', max($want) <= 37, (string)max($want));
echo "== an old world: medium Lv 16, hard Lv 30 (one lair charmed), then one boot\n";
foreach ($want as $n => $lv) {
    if ($n === 'Den of the Great White Owl' || $n === 'Hollow of the Silverback Spider') continue;
    $old = in_array($n, ['Temple of the Tiger Moth', 'Dragonlizard Den', 'Snowcrown Peak', 'Reef of the Box Jelly Queen'], true) ? 16 : 30;
    $loc = q_one('SELECT id, slug FROM locations WHERE name = ?', [$n]);
    q('UPDATE routes SET level = ?, min_level = ?, max_level = ? WHERE a_id = ? OR b_id = ?', [$old, $old - 2, $old + 2, $loc['id'], $loc['id']]);
    q('UPDATE creatures SET level = ?, hp = 1 WHERE slug = ?', [$old, 'boss-' . $loc['slug']]);
}
set_setting('db_version', '0.0.0');
$out = []; exec(escapeshellarg(PHP_BINARY) . ' -d display_errors=1 -r ' . escapeshellarg('$_SERVER["SCRIPT_NAME"]="/adventure.php"; require ' . var_export($argv[1] . '/includes/bootstrap.php', true) . '; echo "booted";') . ' 2>&1', $out);
ok('the boot ran clean', implode("\n", $out) === 'booted', implode(' | ', $out));
setting('__reload__');
foreach ($want as $n => $lv) {
    if ($n === 'Den of the Great White Owl' || $n === 'Hollow of the Silverback Spider') continue;
    $r = $route($n); $b = $boss($n);
    ok("$n: route and boss now Lv $lv", $r && (int)$r['lv'] === $lv && (int)$r['mn'] === $lv - 2 && $b && (int)$b['level'] === $lv && (int)$b['hp'] === (int)round((5 + $lv * 3) * 2.4), json_encode([$r, $b]));
}
foreach (['Den of the Great White Owl' => 10, 'Hollow of the Silverback Spider' => 20] as $n => $lv) { $r = $route($n); ok("$n stays Lv $lv", $r && (int)$r['lv'] === $lv, json_encode($r)); }
echo $fails ? "$fails FAILED\n" : "ok\n";
exit($fails ? 1 : 0);
