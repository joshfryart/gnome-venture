<?php
// Trail Sights P0 spike: can the gnome stand next to every landmark? php tests/trail_sights_reach.php [GAMEDIR]
// For each section: BFS (4 directions, like tm_path) over walkable tiles from the exit '9'; a landmark (objs key lm-*) is usable when the tile it stands on or one of its 8 neighbours is reached.
$game = $argv[1] ?? dirname(__DIR__) . '/game';
function e($v): string { return htmlspecialchars((string)$v, ENT_QUOTES, 'UTF-8'); }
require_once $game . '/includes/tilemap.php';
require_once $game . '/includes/trail_art.php';
$all = trail_authored_load($game . '/includes/data');
$tot = 0; $bad = []; $dist = [0 => 0, 1 => 0];
foreach ($all as $rid => $r) foreach ($r['sections'] as $si => $s) {
    $rows = $s['rows']; $h = count($rows); $w = strlen($rows[0]);
    $walk = fn(int $x, int $y): bool => $x >= 0 && $y >= 0 && $x < $w && $y < $h && $rows[$y][$x] !== '#' && $rows[$y][$x] !== ' ';
    $start = null; foreach ($rows as $y => $row) if (($x = strpos($row, '9')) !== false) $start = [$x, $y];
    $seen = [];
    if ($start) { $q = [$start]; $seen[$start[1] * $w + $start[0]] = true; for ($i = 0; $i < count($q); $i++) { [$cx, $cy] = $q[$i]; foreach ([[1,0],[-1,0],[0,1],[0,-1]] as [$dx, $dy]) { $nx = $cx + $dx; $ny = $cy + $dy; if ($walk($nx, $ny) && !isset($seen[$ny * $w + $nx])) { $seen[$ny * $w + $nx] = true; $q[] = [$nx, $ny]; } } } }
    foreach ($s['objs'] as $ob) {
        if (strncmp((string)$ob[2], 'lm-', 3) !== 0) continue;
        $tot++; $best = null;
        for ($dy = -1; $dy <= 1; $dy++) for ($dx = -1; $dx <= 1; $dx++) { $x = $ob[0] + $dx; $y = $ob[1] + $dy; if (isset($seen[$y * $w + $x])) { $d = max(abs($dx), abs($dy)); if ($best === null || $d < $best) $best = $d; } }
        if ($best === null) $bad[] = "$rid/" . ($si + 1) . " {$ob[2]} at {$ob[0]},{$ob[1]}"; else $dist[$best]++;
    }
}
echo "landmark placements: $tot; standing on it: {$dist[0]}; beside it: {$dist[1]}; unreachable: " . count($bad) . "\n";
foreach (array_slice($bad, 0, 40) as $b) echo "  NO $b\n";
exit($bad ? 1 : 0);
