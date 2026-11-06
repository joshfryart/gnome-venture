<?php
// Lints the delve chamber library. Usage: php tools/lint_delve_chambers.php [file]   (default game/includes/data/delve_chambers.txt)
require dirname(__DIR__) . '/game/includes/delve_stamp.php';
$path = $argv[1] ?? dirname(__DIR__) . '/game/includes/data/delve_chambers.txt';
if (!is_file($path)) { fwrite(STDERR, "no such file: $path\n"); exit(2); }
$p = ds_parse((string)file_get_contents($path));
$bad = 0;
foreach ($p['errors'] as $e) { echo "FAIL (file): $e\n"; $bad++; }
$per = [];
foreach ($p['chambers'] as $k => $c) {
    $b = ds_lint($c);
    foreach ($b as $x) { echo "FAIL $k: $x\n"; $bad++; }
    if (!$b) $per[$c['slug']][$c['size']] = ($per[$c['slug']][$c['size']] ?? 0) + 1;
}
ksort($per);
foreach ($per as $slug => $sz) { ksort($sz); echo sprintf("%-28s", $slug) . implode('  ', array_map(fn($n, $c) => "{$n}x{$n}: $c", array_keys($sz), $sz)) . "\n"; }
echo count($p['chambers']) . ' chambers, ' . $bad . " problems\n";
exit($bad ? 1 : 0);
