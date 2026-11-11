<?php
// Lint every Trail Sights row (all data/trail_sights*.txt, the admin rows laid over): php tests/trail_sights_lint.php GAME_DIR   (an installed game, so item slugs can be checked)
// Also: rows that do not parse (wrong column count) and duplicate verbs. Exit 1 on any problem.
$_SERVER['SCRIPT_NAME'] = '/adventure.php';
require $argv[1] . '/includes/bootstrap.php';
require_once $argv[1] . '/includes/tools.php';
require_once $argv[1] . '/includes/gathering.php';
require_once $argv[1] . '/includes/trail_sights.php';
$bad = 0;
foreach (glob($argv[1] . '/includes/data/trail_sights*.txt') as $f) foreach (file($f, FILE_IGNORE_NEW_LINES) as $i => $line) {
    $line = trim($line); if ($line === '' || $line[0] === '#') continue;
    $n = count(explode('|', $line));
    if ($n < 11 || $n > 13) { echo "BAD " . basename($f) . ':' . ($i + 1) . " has $n columns (11 to 13)\n"; $bad++; }
}
$all = trail_sights_file(); $verbs = [];
foreach ($all as $r) {
    foreach (trail_sight_lint($r) as $p) { echo "BAD {$r['slug']}: $p\n"; $bad++; }
    $verbs[mb_strtolower($r['verb'])][] = $r['slug'];
}
foreach ($verbs as $v => $s) if (count($s) > 1) { echo "BAD verb '$v' used by " . implode(', ', $s) . "\n"; $bad++; }
echo count($all) . " rows, $bad problems\n";
exit($bad ? 1 : 0);
