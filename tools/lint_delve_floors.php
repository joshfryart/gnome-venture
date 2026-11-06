<?php
// Lints the delve floors file. Usage: php tools/lint_delve_floors.php [file]   (default game/includes/data/delve_floors.txt)
// Prints every problem per floor and a count per delve; exits 1 if any floor fails.
require dirname(__DIR__) . '/game/includes/delve_floors.php';
$path = $argv[1] ?? dirname(__DIR__) . '/game/includes/data/delve_floors.txt';
if (!is_file($path)) { fwrite(STDERR, "no such file: $path\n"); exit(2); }
$r = dv_floors_from_text((string)file_get_contents($path));
$per = [];
foreach ($r['floors'] as $f) { $per[$f['slug']]['ok'] = ($per[$f['slug']]['ok'] ?? 0) + 1; $per[$f['slug']][$f['tier']] = ($per[$f['slug']][$f['tier']] ?? 0) + 1; if ($f['sig']) $per[$f['slug']]['sig'] = ($per[$f['slug']]['sig'] ?? 0) + 1; if (in_array('boss', $f['for'], true)) $per[$f['slug']]['boss'] = ($per[$f['slug']]['boss'] ?? 0) + 1; }
foreach ($r['problems'] as $key => $list) foreach ($list as $p) echo "FAIL $key: $p\n";
ksort($per);
foreach ($per as $slug => $c) echo sprintf("%-28s ok %2d  small %d standard %d large %d  sig %d  boss %d\n", $slug, $c['ok'], $c['small'] ?? 0, $c['standard'] ?? 0, $c['large'] ?? 0, $c['sig'] ?? 0, $c['boss'] ?? 0);
echo count($r['floors']) . ' ok, ' . count($r['problems']) . " with problems\n";
exit($r['problems'] ? 1 : 0);
