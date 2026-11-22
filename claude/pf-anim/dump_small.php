<?php
// Dumps every creature of one size (small|medium|large|boss, default small) with its full layered deck (pfd_foe_row, no region) as JSON. Used by build_small_anim.py.
//   php dump_small.php [repo-root] [size]
$root = $argv[1] ?? (__DIR__ . '/../..');
$size = $argv[2] ?? 'small';
if (!in_array($size, ['small', 'medium', 'large', 'boss'], true)) { fwrite(STDERR, "bad size $size\n"); exit(2); }
require_once $root . '/tests/pf_creatures_load.php';
$lands = [];
foreach (file($root . '/game/includes/data/creatures.txt', FILE_IGNORE_NEW_LINES) as $l) {
    if ($l === '' || $l[0] === '#') continue; $c = explode('|', $l); if (count($c) >= 7) $lands[$c[0]] = $c[3];
}
$R = pfd_creature_rows(); $out = [];
foreach (pt_load_creatures() as $slug => $c) {
    if ($c['size'] !== $size) continue;
    $row = pfd_foe_row($c, ''); $r = $R[$slug] ?? [];
    $ld = $r['lands'] ?? ($lands[$slug] ?? 'any'); if ($ld === null || $ld === '=') $ld = $lands[$slug] ?? 'any';
    $out[] = ['slug' => $slug, 'name' => $c['name'], 'level' => $c['level'], 'class' => $row['class'], 'lean' => $row['lean'], 'ab' => $r['ab'] ?? [], 'ai' => $r['ai'] ?? '',
        'lands' => $ld, 'regions' => $r['regions'] ?? ['*'], 'art' => $r['art'] ?? '', 'family' => $r['family'] ?? $slug, 'pieces' => $row['deck']];
}
echo json_encode($out, JSON_UNESCAPED_UNICODE);
