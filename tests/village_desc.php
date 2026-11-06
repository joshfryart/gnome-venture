<?php
// v2.5.71: every generated village reads differently. php tests/village_desc.php [GAME_DIR] [--find]  (--find searches for a salt that has no clashes)
$game = (isset($argv[1]) && $argv[1][0] !== '-') ? $argv[1] : dirname(__DIR__) . '/game';
$find = false;
if (getenv("VILLAGE_SALT") !== false) define("VILLAGE_BLURB_SALT", getenv("VILLAGE_SALT"));   // to search for a clash-free salt: for i in $(seq 1 2000); do VILLAGE_SALT=s$i php tests/village_desc.php && echo s$i && break; done
require_once $game . '/includes/adventure_data.php';
$slugs = [];
foreach (file($game . '/includes/data/zones.txt', FILE_IGNORE_NEW_LINES) as $l) {
    if ($l === '' || $l[0] === '#') continue;
    $f = array_map('trim', explode('|', $l));
    if (count($f) < 6) continue;
    for ($i = 1; $i <= max(1, min(5, (int)$f[5])); $i++) $slugs[] = ['v-' . strtolower($f[0]) . '-' . (int)$f[1] . '-' . $i, $f[2]];
}
function clashes(array $slugs): array
{
    $seen = []; $dups = [];
    foreach ($slugs as [$slug, $land]) {
        $d = village_blurb(['kind' => 'village', 'slug' => $slug, 'landscape' => $land, 'description' => LANDSCAPES[$land][2]]);
        if (isset($seen[$d])) $dups[] = "$slug = {$seen[$d]}"; else $seen[$d] = $slug;
    }
    return $dups;
}
$dups = clashes($slugs);
echo count($slugs) . " villages, " . count($dups) . " clashes " . implode(', ', array_slice($dups, 0, 5)) . "\n";
exit($dups ? 1 : 0);
