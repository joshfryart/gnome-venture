<?php
// Compares the table/column/index layout of two installed games (fresh install vs. upgraded from an older release).
// Usage: php tests/schema_compare.php FRESH_GAME_DIR UPGRADED_GAME_DIR      (SQLite installs; exit 1 on any difference)
function layout(string $dir): array {
    $p = new PDO('sqlite:' . $dir . '/data/game.sqlite');
    $out = [];
    foreach ($p->query("SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%' ORDER BY name")->fetchAll(PDO::FETCH_COLUMN) as $t) {
        $out["table $t"] = true;
        foreach ($p->query("PRAGMA table_info($t)")->fetchAll() as $c) $out["col $t.{$c['name']}"] = true;
        foreach ($p->query("PRAGMA index_list($t)")->fetchAll() as $i) if (strpos($i['name'], 'sqlite_autoindex') !== 0) $out["index $t.{$i['name']}"] = true;
    }
    return $out;
}
$a = layout($argv[1]); $b = layout($argv[2]); $bad = 0;
foreach (array_diff_key($a, $b) as $k => $_) { echo "FAIL missing after upgrade: $k\n"; $bad++; }
foreach (array_diff_key($b, $a) as $k => $_) { echo "note: only in upgraded db (left over from the old release): $k\n"; }
echo $bad ? "$bad FAILED\n" : "ok   upgraded schema has everything a fresh install has (" . count($a) . " objects)\n";
exit($bad ? 1 : 0);
