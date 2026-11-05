<?php
// Authored Trail maps + random encounters (pure; no database).  php tests/trail_authored.php [GAMEDIR]
// Needs game/includes/data/trail_maps.json (python3 tools/bake_trail_art.py) and the baked pictures under assets/img/trail.
$game = $argv[1] ?? dirname(__DIR__) . '/game';
$fails = 0;
function ok(string $what, bool $cond, string $extra = ''): void { global $fails; echo ($cond ? '  ok   ' : '  FAIL ') . $what . ($cond ? '' : "  $extra") . "\n"; if (!$cond) $fails++; }
function e($v): string { return htmlspecialchars((string)$v, ENT_QUOTES, 'UTF-8'); }
require_once $game . '/includes/tilemap.php';
require_once $game . '/includes/trail_art.php';
require_once $game . '/includes/trail_tiles.php';   // trail_map_make (its includes only define functions)

echo "== authored maps\n";
$all = trail_authored_all();
ok('the Maplewold is authored: 16 routes', count($all) === 16, (string)count($all));
$secs = 0; $bad = []; $badFiles = []; $bossRoutes = [];
foreach ($all as $rid => $r) {
    foreach ($r['sections'] as $si => $_) {
        $secs++;
        $art = trail_authored_section((int)$rid, $si);
        [$m, $t] = trail_map_authored($art);
        $reach = tm_reach($m, $m['entry'][0], $m['entry'][1]);
        $exit = $m['spots']['9'] ?? null;
        if ($m['w'] !== 22 || $m['h'] !== 7 || !$m['entry'] || !$exit || $m['entry'][0] !== 0 || $exit[0] !== 21 || !isset($reach[$exit[1] * $m['w'] + $exit[0]])) $bad[] = "$rid#$si layout";
        foreach ($t as [$x, $y, $k]) {
            if (!isset($reach[$y * $m['w'] + $x])) $bad[] = "$rid#$si token $x,$y unreachable";
            if ($k === 'E') $bossRoutes[$rid . '#' . $si] = $art['boss'];
        }
        if (!trail_art_ready($art)) $badFiles[] = "$rid#$si";
        if ($si > 0) { $prev = trail_map_authored(trail_authored_section((int)$rid, $si - 1))[0]; if ($m['entry'][1] !== $prev['spots']['9'][1]) $bad[] = "$rid#$si entry row != previous exit row"; }
    }
}
ok('41 sections', $secs === 41, (string)$secs);
ok('every section: 22x7, entry on the left edge, exit on the right, exit reachable, tokens reachable, entry row = previous exit row', !$bad, implode('; ', $bad));
ok('every section has its baked ground picture', !$badFiles, implode(', ', $badFiles));
ok('fixed fights only where a delve (313) or lair (315) ends', $bossRoutes === ['313#2' => 'miniboss', '315#4' => 'boss'], json_encode($bossRoutes));
[$m, $t] = trail_map_make('304|7|9|0');
ok('trail_map_make gives the authored section for an authored route', isset($m['art']) && $m['art']['feature'] !== '' && $m['w'] === 22);
[$m2] = trail_map_make('3|7|9|0');
ok('an unauthored route keeps the random generator (11x7, no art)', !isset($m2['art']) && $m2['w'] === 11);
ok('a route asked for a section it does not have falls back too', !isset(trail_map_make('304|7|9|5')[0]['art']));
$fixed = 0; foreach ($t as $tk) $fixed += $tk[2] === 'E' ? 1 : 0;
ok('a normal authored section has finds but no fight marker', $fixed === 0 && count($t) >= 1);

echo "== random encounters\n";
$flat = tm_parse(["#########", "S.......9", "#########"]);
$path = [[1, 1], [2, 1], [3, 1], [4, 1], [5, 1], [6, 1], [7, 1], [8, 1]];
$asked = [];
[$i, $q, $f] = trail_encounter_index($flat, $path, 0, 0, function (int $p) use (&$asked): bool { $asked[] = $p; return false; });
ok('no roll in the first 3 tiles or within 2 of the exit', $i === null && count($asked) === 3, json_encode($asked));
ok('the pity counter climbs +1 per quiet tile (2%, 3%, 4%)', $asked === [2, 3, 4], json_encode($asked));
ok('quiet tiles are counted back out', $q === 3 && $f === 0);
[$i, $q, $f] = trail_encounter_index($flat, $path, 0, 0, fn(int $p): bool => true);
ok('a hit stops the walk on that tile, resets quiet, counts a fight', $i === 2 && $q === 0 && $f === 1, "$i/$q/$f");
[$i] = trail_encounter_index($flat, $path, 0, 2, fn(int $p): bool => true);
ok('at most 2 random fights a section', $i === null);
$rough = tm_parse(["#########", "S...,...9", "#########"]);
$asked = []; trail_encounter_index($rough, $path, 0, 0, function (int $p) use (&$asked): bool { $asked[] = $p; return false; });
ok('rough floor rolls 8% (+ pity), floor 2% (+ pity)', $asked === [2, 9, 4], json_encode($asked));
$hits = 0; $runs = 20000;
for ($n = 0; $n < $runs; $n++) { [$i] = trail_encounter_index($flat, $path, 0, 0); $hits += $i === null ? 0 : 1; }
ok('a plain 6-tile stretch of floor brings a fight about 1 time in 15 (rolled for real)', $hits / $runs > .04 && $hits / $runs < .10, (string)round($hits / $runs, 3));

echo "== the picture\n";
$art = trail_authored_section(304, 0);
[$m] = trail_map_authored($art);
$svg = trail_art_svg($m, ['px' => 3, 'py' => 2, 'x0' => -1, 'y0' => -1, 'cols' => 9, 'rows' => 9, 'tokens' => [[6, 2, '✨', 'gold', false], [5, 3, '🚪', 'gold', false]], 'walk' => ['p' => [[2, 2], [3, 2]]]]);
ok('ground picture, walker, a find, an exit mark, footprints', str_contains($svg, 'ground/304-1.png') && str_contains($svg, 'class="tmme"') && str_contains($svg, 'find-forest.png') && str_contains($svg, '#e02020') && str_contains($svg, 'tmft'));
ok('the find turns into its searched sprite when done', str_contains(trail_art_svg($m, ['px' => 3, 'py' => 2, 'x0' => -1, 'y0' => -1, 'cols' => 9, 'rows' => 9, 'tokens' => [[6, 2, '✨', 'gold', true]]]), 'find-forest-done.png'));
$win = ['px' => 3, 'py' => 2, 'x0' => -1, 'y0' => -1, 'cols' => 9, 'rows' => 9, 'tokens' => []];
$svg2 = trail_art_svg($m, $win);
$gp = strpos($svg2, 'class="tmme"');
$k = TM_UNIT / TRAIL_ART_PX;
$posOf = function (array $o) use ($k, $svg2) {   // where this object's <image> sits in the markup (the href may carry a cache-busting suffix)
    $re = '~obj/' . preg_quote($o[2], '~') . '\.png[^"]*" x="' . preg_quote(tm_n(($o[0] + 1) * TM_UNIT + $o[3] * $k), '~') . '" y="' . preg_quote(tm_n((($o[1] + 1) * TRAIL_ART_PX - 29) * $k), '~') . '"~';
    return preg_match($re, $svg2, $mm, PREG_OFFSET_CAPTURE) ? $mm[0][1] : false;
};
$south = null; $north = null;
foreach ($art['objs'] as $o) { if ($o[0] >= 0 && $o[0] <= 6) { if ($o[1] > 2) $south ??= $o; if ($o[1] < 2) $north ??= $o; } }
ok('depth order: a tree on a row south of the walker is drawn after it (in front), one to the north before it (behind)', $south && $north
    && ($ps = $posOf($south)) !== false && ($pn = $posOf($north)) !== false && $ps > $gp && $pn < $gp, json_encode([$south, $north]));
$expect = 0; foreach ($art['objs'] as $o) { $X = ($o[0] - 12) * TM_UNIT + $o[3] * $k; if ($X + 64 * $k > 0 && $X < 9 * TM_UNIT) $expect++; }
$far = trail_art_svg($m, ['x0' => 12] + $win);
ok('only the things in the window are drawn', substr_count($far, '<image href="') - 2 === $expect && $expect < count($art['objs']), substr_count($far, '<image href="') . " vs $expect of " . count($art['objs']));
exit($fails ? 1 : 0);
