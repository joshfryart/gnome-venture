<?php
// Duplicate + weak-shape check for a chamber draft against the whole library.
// Usage: php tools/check_chamber_dups.php DRAFT_FILE   (compares with game/includes/data/delve_chambers.txt, ignoring chambers of the same slug in it)
// Reports: rotation/mirror copies (rough floor counts as floor), lone-wall noise, thin doorways (<3 edge floor tiles), >45% water.
require dirname(__DIR__) . '/game/includes/delve_stamp.php';
$draft = ds_parse((string)file_get_contents($argv[1] ?? ''))['chambers'];
$lib = ds_chambers();
$norm = function (array $rows) {
    $n = count($rows); $g = array_map('str_split', $rows); $forms = [];
    for ($f = 0; $f < 2; $f++) {
        for ($r = 0; $r < 4; $r++) {
            $forms[] = preg_replace('/,/', '.', implode('/', array_map('implode', $g)));
            $g2 = [];
            for ($y = 0; $y < $n; $y++) for ($x = 0; $x < $n; $x++) $g2[$x][$n - 1 - $y] = $g[$y][$x];
            foreach ($g2 as &$row) ksort($row);
            ksort($g2); $g = $g2;
        }
        $g = array_map('array_reverse', $g);
    }
    sort($forms); return $forms[0];
};
$seen = [];
foreach ($lib as $k => $c) { $slugs = array_map(fn($d) => $d['slug'], $draft); if (in_array($c['slug'], $slugs, true)) continue; $seen[$norm($c['rows'])] = $k; }
$bad = 0;
foreach ($draft as $k => $c) {
    $key = $norm($c['rows']);
    if (isset($seen[$key])) { echo "DUP $k == {$seen[$key]}\n"; $bad++; } else $seen[$key] = $k;
    $n = $c['size']; $f = $w = $iso = $edge = 0;
    foreach ($c['rows'] as $y => $r) for ($x = 0; $x < $n; $x++) {
        $t = $r[$x];
        if ($t !== '#') { $f++; if ($x == 0 || $y == 0 || $x == $n - 1 || $y == $n - 1) $edge++; }
        if ($t === 'W') $w++;
        if ($t === '#') { $nb = 0; foreach ([[1,0],[-1,0],[0,1],[0,-1]] as [$dx,$dy]) { $X = $x + $dx; $Y = $y + $dy; if ($X < 0 || $Y < 0 || $X >= $n || $Y >= $n || $c['rows'][$Y][$X] === '#') $nb++; } if ($nb === 0) $iso++; }
    }
    $flags = [];
    if ($iso >= 4) $flags[] = "noisy ($iso lone walls)";
    if ($edge < 3) $flags[] = "thin doorways ($edge edge floor tiles)";
    if ($f && $w / $f > .45) $flags[] = 'over 45% water';
    if ($flags) { echo "$k: " . implode(', ', $flags) . "\n"; $bad++; }
}
echo count($draft) . " chambers checked, $bad problems\n";
exit($bad ? 1 : 0);
