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
foreach (trail_sight_quests() as $q) foreach (trail_sight_quest_lint($q, $all) as $p) { echo "BAD quest {$q['slug']}: $p\n"; $bad++; }
foreach (trail_sight_folk() as $slug => $list) foreach ($list as $f) {
    if (!isset($all[$slug])) { echo "BAD folk row on unknown Sight $slug\n"; $bad++; }
    $probe = ['slug' => $slug, 'verb' => 'x', 'icon' => 'x', 'energy' => 0, 'cd' => 0, 'uses' => 1, 'when' => $f['when'], 'check' => '-', 'rewards' => $f['rewards'], 'win' => 'x', 'lose' => '', 'tool' => '-', 'fail_en' => 0];
    foreach (trail_sight_lint($probe) as $p) { echo "BAD folk $slug/{$f['who']}: $p\n"; $bad++; }
    if ($f['line'] === '' || $f['who'] === '') { echo "BAD folk $slug has no villager or line\n"; $bad++; }
}
$info = trail_sight_info(); foreach (array_keys($all) as $s) if (!isset($info[$s])) { echo "BAD no name/caption row for $s in trail_sight_info.txt\n"; $bad++; }
foreach (trail_sight_items_file() as $slug => $it) if (!in_array($it[1], ['forage', 'part', 'misc', 'produce', 'flower', 'food', 'decor', 'supply', 'other', 'soil'], true)) { echo "BAD item $slug category {$it[1]}\n"; $bad++; }
echo count($all) . " rows, $bad problems\n";
exit($bad ? 1 : 0);
