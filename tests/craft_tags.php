<?php
// v2.3.7: every recipe of a tagged crafting area opens from at least one scene object, and every object and glob opens something.
// Pure PHP, no install: php tests/craft_tags.php [GAME_DIR]. Reads includes/data/craft_scenes.php, crafts.txt, recipes.txt.
$game = rtrim($argv[1] ?? __DIR__ . '/../game', '/');
$scenes = require $game . '/includes/data/craft_scenes.php';
$by = [];   // category => [slug]
foreach (file($game . '/includes/data/crafts.txt') as $l) {
    $l = trim($l); if ($l === '' || $l[0] === '#') continue;
    $c = explode('|', $l); if (count($c) >= 5) $by[trim($c[2])][] = trim($c[0]);
}
foreach (file($game . '/includes/data/recipes.txt') as $l) {
    $l = trim($l); if ($l === '' || $l[0] === '#') continue;
    $c = explode('|', $l); if (count($c) >= 8) $by[trim($c[7]) === 'preserve' ? 'pantry' : 'cooking'][] = trim($c[0]);
}
$by['garden'][] = 'worm-bin';   // added by includes/games.php
$fail = 0; $tagged = 0;
$m = fn(array $g, string $s) => (bool)array_filter($g, fn($x) => fnmatch($x, $s));
foreach ($scenes as $area => $sc) {
    $objs = array_filter($sc['hot'], fn($h) => is_array($h[6]));
    if (!$objs) { echo "$area: query links (not tagged)\n"; continue; }
    $tagged++;
    $slugs = $by[$area] ?? [];
    if (!$slugs) { echo "FAIL $area has no recipes in the data files\n"; $fail++; continue; }
    $cover = [];
    foreach ($objs as [$id, $label, , , , , $globs]) {
        $hit = array_values(array_filter($slugs, fn($s) => $m($globs, $s)));
        foreach ($hit as $s) $cover[$s] = true;
        $dead = array_filter($globs, fn($g) => !array_filter($slugs, fn($s) => fnmatch($g, $s)));
        printf("%-9s %-10s %3d recipes\n", $area, $id, count($hit));
        if (count($hit) < 2) { echo "FAIL $area/$id opens only " . count($hit) . " recipe(s)\n"; $fail++; }
        if ($dead) { echo "FAIL $area/$id globs match nothing: " . implode(' ', $dead) . "\n"; $fail++; }
    }
    $lost = array_diff($slugs, array_keys($cover));
    if ($lost) { echo "FAIL $area recipes on no object: " . implode(' ', $lost) . "\n"; $fail++; }
}
// 2.7.23: teas are listed by slug. The Hovel kettle's named teas (data/teas.txt), fertiliser teas and teahouse spots all end in -tea, so no glob may catch a made-up one.
foreach ($scenes as $area => $sc) foreach ($sc['hot'] as [$id, , , , , , $globs]) {
    if (!is_array($globs)) continue;
    foreach (['xyz-tea', 'feast-xyz-tea', 'xyz-iced-tea'] as $fake) if ($m($globs, $fake)) { echo "FAIL $area/$id picks up the made-up slug $fake (list teas by slug, not by a glob)\n"; $fail++; }
    foreach ($globs as $g) if (preg_match('/[*?\]]-?tea$/', $g)) { echo "FAIL $area/$id has the glob $g: it would file any new slug ending in tea here\n"; $fail++; }
}
if ($tagged < 6) { echo "FAIL only $tagged areas tagged (want 6, Potions excepted)\n"; $fail++; }
echo $fail ? "craft_tags: $fail FAIL\n" : "craft_tags: OK\n";
exit($fail ? 1 : 0);
