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
ok('the Maplewold is authored: its 16 routes are there (more regions may have been added)', count($all) >= 16 && isset($all['228'], $all['316']), (string)count($all));
$secs = 0; $bad = []; $badFiles = []; $bossRoutes = [];
foreach ($all as $rid => $r) {
    foreach ($r['sections'] as $si => $_) {
        $secs++;
        $art = trail_authored_section((int)$rid, $si);
        [$m, $t] = trail_map_authored($art);
        $reach = tm_reach($m, $m['entry'][0], $m['entry'][1]);
        $exit = $m['spots']['9'] ?? null;
        $bendy = isset($art['entry']);   // v2.6.38: the 30 x 18 sections (entry and exit on any edge) have their own test, tests/trail_bendy.php
        if ($bendy) { if ($m['h'] !== 18 || $m['w'] !== 30 || !$m['entry'] || !$exit || !isset($reach[$exit[1] * $m['w'] + $exit[0]]) || ($art['pic'] ?? '') !== 'r') $bad[] = "$rid#$si bendy layout"; }
        elseif ($m['h'] !== 7 || $m["w"] !== ($w0 = $si === 0 ? $m["w"] : $w0) || $m["w"] < 11 || !$m['entry'] || !$exit || $m['entry'][0] !== 0 || $exit[0] !== $m['w'] - 1 || !isset($reach[$exit[1] * $m['w'] + $exit[0]])) $bad[] = "$rid#$si layout";
        foreach ($t as [$x, $y, $k]) {
            if (!isset($reach[$y * $m['w'] + $x])) $bad[] = "$rid#$si token $x,$y unreachable";
            if ($k === 'E') $bossRoutes[$rid . '#' . $si] = $art['boss'];
        }
        if (!trail_art_ready($art)) $badFiles[] = "$rid#$si";
        if ($si > 0 && !$bendy) { $prev = trail_map_authored(trail_authored_section((int)$rid, $si - 1))[0]; if ($m['entry'][1] !== $prev['spots']['9'][1]) $bad[] = "$rid#$si entry row != previous exit row"; }
    }
}
ok('all 246 routes are authored: 665 sections (41 Maplewold hand-tuned + 624 others; v2.6.39)', count($all) === 246 && $secs === 665, count($all) . ' routes, ' . $secs . ' sections');
ok('every section (old ones: 7 rows; bendy ones: 30 x 18 with their -r picture), one width per route, entry on the left edge, exit on the right, exit reachable, tokens reachable, entry row = previous exit row', !$bad, implode('; ', $bad));
ok('every section has its baked ground picture', !$badFiles, implode(', ', $badFiles));
// Fixed fights: exactly one E per delve/lair route, on its LAST section, kind from the route list ((delve) = miniboss, (lair) = boss); none anywhere else.
$want = [];
foreach (file(dirname($game) . '/claude/route-list.md') as $ln) {
    if (preg_match('/^\|\s*(\d+)\s*\|.*\((delve|lair)\)\s*\|\s*\w+\s*\|\s*\d+\s*\|/', $ln, $mm) && isset($all[$mm[1]])) $want[$mm[1] . '#' . (count($all[$mm[1]]['sections']) - 1)] = $mm[2] === 'lair' ? 'boss' : 'miniboss';
}
ksort($want); ksort($bossRoutes);
ok('fixed fights only on the last section of a delve (miniboss) or lair (boss) route', $bossRoutes === $want && count($want) >= 2, json_encode(array_diff_assoc($bossRoutes, $want) + array_diff_assoc($want, $bossRoutes)));
[$m, $t] = trail_map_make('304|7|9|0');
ok('trail_map_make gives the authored section for an authored route', isset($m['art']) && $m['art']['feature'] !== '' && $m['w'] >= 11);
[$m2] = trail_map_make('3|7|9|0');
ok('an unauthored route keeps the random generator (11x7, no art)', isset($all['3']) || (!isset($m2['art']) && $m2['w'] === 11));
ok('a route asked for a section it does not have falls back too', !isset(trail_map_make('304|7|9|5')[0]['art']));
$fixed = 0; foreach ($t as $tk) $fixed += $tk[2] === 'E' ? 1 : 0;
ok('a normal authored section has finds but no fight marker', $fixed === 0 && count($t) >= 1);

echo "== loader: maps for any region\n";
// Fixtures below are test data, not game data. A real region file is the same shape: {"v":1,"routes":{"<route id>":{land, art, from, to, boss, sections}}}.
$tmp = sys_get_temp_dir() . '/trail-loader-' . getmypid();
@mkdir($tmp . '/trail_maps', 0777, true);
$secOf = fn(array $rows) => ['feature' => 'fixture', 'caption' => 'c', 'objs' => [], 'rows' => $rows];
$good = ['land' => 'desert', 'art' => 'coast', 'from' => 'A', 'to' => 'B', 'boss' => '', 'sections' => [$secOf(['#####', 'S...9', '#####']), $secOf(['#####', '....9', '#####']) + ['entry' => ['side' => 'W', 'x' => 0, 'y' => 1]]]];   // v2.7: a section without an S names its entry
file_put_contents($tmp . '/trail_maps.json', json_encode(['v' => 1, 'routes' => ['900001' => $good]]));
file_put_contents($tmp . '/trail_maps/blossomreach.json', json_encode(['v' => 1, 'routes' => [
    '900002' => $good,
    'abc' => $good,
    '900003' => ['land' => 'desert', 'sections' => [$secOf(['#####', 'S..9.', '#####'])]],      // the 9 is not on the right edge
    '900004' => ['land' => 'desert', 'sections' => [$secOf(['#####', 'S...9', '####'])]],       // unequal rows
    '900005' => ['land' => 'desert', 'sections' => [$secOf(['#####', 'S...9', '#####x'])]],     // a character that is not a tile
    '900006' => ['land' => 'desert', 'sections' => []],
    '900007' => ['land' => 'desert', 'sections' => [$secOf(['#####', 'S...9', '#####']), $secOf(['#####', '....9', '#####'])]],   // no S and no entry in section 2
]]));
file_put_contents($tmp . '/trail_maps/zzz.json', json_encode(['v' => 1, 'routes' => ['900001' => ['land' => 'coast'] + $good]]));
file_put_contents($tmp . '/trail_maps/broken.json', '{not json');
$l = trail_authored_load($tmp);
ok('the merged file and the per-region files are both read', isset($l['900001'], $l['900002']), implode(',', array_keys($l)));
ok('a route in a later region file wins over the same id earlier', ($l['900001']['land'] ?? '') === 'coast');
ok('invalid entries are dropped (9 off the edge, unequal rows, odd character, bad id, no sections, no S and no entry) and a broken file is skipped', array_map('strval', array_keys($l)) === ['900001', '900002'], implode(',', array_keys($l)));
ok('a missing folder gives no routes', trail_authored_load($tmp . '/none') === []);
ok('the shipped data folder loads the same way trail_authored_all() does', trail_authored_load($game . '/includes/data') === $all);
ok('a route whose picture is missing has no baked ground (the old drawn look takes over)', !trail_art_ready(['route' => 900002, 'sec' => 0]));
$a1 = ['route' => 900001, 'sec' => 0, 'land' => 'desert', 'art' => 'coast', 'rows' => ['#####', 'S...9', '#####'], 'objs' => [], 'boss' => ''];
[$mm] = trail_map_authored($a1);
ok('any width and height parse (5x3)', $mm['w'] === 5 && $mm['h'] === 3 && $mm['entry'] === [0, 1]);
$svgA = trail_art_svg($mm, ['px' => 0, 'py' => 1, 'x0' => 0, 'y0' => 0, 'cols' => 5, 'rows' => 3, 'tokens' => [[2, 1, '✨', 'gold', false]]]);
ok('a desert route draws the find sprite of its "art" land (coast)', str_contains($svgA, 'find-coast.png') && !str_contains($svgA, 'find-desert'));
ok('the bottom edge fades (gradient layer)', str_contains($svgA, 'url(#tmfade)'));
array_map('unlink', glob($tmp . '/trail_maps/*')); @rmdir($tmp . '/trail_maps'); @unlink($tmp . '/trail_maps.json'); @rmdir($tmp);
$py = trim((string)shell_exec('command -v python3'));
if ($py !== '') {   // the baker's --check mode (no Pillow needed)
    $bt = escapeshellarg($py) . ' -I ' . escapeshellarg(dirname($game) . '/tools/bake_trail_art.py') . ' --check ';
    $okf = sys_get_temp_dir() . '/trail-check-ok-' . getmypid() . '.json'; $badf = sys_get_temp_dir() . '/trail-check-bad-' . getmypid() . '.json';
    $rt = ['route_id' => 1, 'from' => 'A', 'to' => 'B', 'land' => 'desert', 'sections' => [['feature' => 'f', 'caption' => 'c', 'tokens' => [], 'rows' => ['###########', '#.........#', 'S.......,.9', '#.........#', '###########', '###########', '###########']]]];
    file_put_contents($okf, json_encode([$rt]));
    $rt['sections'][0]['rows'][2] = 'S###.....#9';   // the entry is walled in
    file_put_contents($badf, json_encode($rt));
    exec($bt . escapeshellarg($okf) . ' 2>&1', $o1, $c1);
    exec($bt . escapeshellarg($badf) . ' 2>&1', $o2, $c2);
    exec($bt . escapeshellarg(dirname($game) . '/claude/maplewold-trail-maps/maplewold_trail_maps_22wide.json') . ' 2>&1', $o3, $c3);
    ok('bake_trail_art.py --check accepts a good map for a new land (desert)', $c1 === 0, implode(' ', $o1));
    ok('bake_trail_art.py --check refuses a map with no path to the exit', $c2 === 1 && str_contains(implode(' ', $o2), 'no path'), implode(' ', $o2));
    ok('...and the Maplewold file passes the same check', $c3 === 0, implode(' ', $o3));
    @unlink($okf); @unlink($badf);
}

echo "== random encounters\n";
$flat = tm_parse(["#########", "S.......9", "#########"]);
$path = [[1, 1], [2, 1], [3, 1], [4, 1], [5, 1], [6, 1], [7, 1], [8, 1]];
$asked = [];
[$i, $q, $f] = trail_encounter_index($flat, $path, 0, 0, function (float $p) use (&$asked): bool { $asked[] = $p; return false; }, '', 3.0);
ok('no roll in the first 3 tiles or within 2 of the exit', $i === null && count($asked) === 3, json_encode($asked));
ok('flat chance: base 3% every tile (no pity ramp)', $asked === [3.0, 3.0, 3.0], json_encode($asked));
ok('quiet tiles are counted', $q === 3 && $f === 0);
[$i, $q, $f] = trail_encounter_index($flat, $path, 0, 0, fn(float $p): bool => true, '', 3.0);
ok('a hit stops the walk on that tile and counts a fight', $i === 2 && $q === 0 && $f === 1, "$i/$q/$f");
[$i] = trail_encounter_index($flat, $path, 0, 5, fn(float $p): bool => true, '', 3.0);
ok('no cap per section', $i === 2);
$asked = []; trail_encounter_index($flat, $path, 0, 0, function (float $p) use (&$asked): bool { $asked[] = $p; return false; }, 'sneak', 3.0);
ok('Sneak rolls 40% of the base', abs($asked[0] - 1.2) < 1e-9, json_encode($asked));
$asked = []; trail_encounter_index($flat, $path, 0, 0, function (float $p) use (&$asked): bool { $asked[] = $p; return false; }, 'hunt', 3.0);
ok('Hunt rolls 250% of the base', abs($asked[0] - 7.5) < 1e-9, json_encode($asked));
$asked = []; trail_encounter_index($flat, $path, 0, 0, function (float $p) use (&$asked): bool { $asked[] = $p; return false; }, '', 0.0);
ok('base 0 = no fights', $asked[0] === 0.0);
$rough = tm_parse(["#########", "S...,...9", "#########"]);
$asked = []; trail_encounter_index($rough, $path, 0, 0, function (float $p) use (&$asked): bool { $asked[] = $p; return false; }, '', 3.0);
ok('rough floor rolls 2.5x the base', $asked === [3.0, 7.5, 3.0], json_encode($asked));
$hits = 0; $runs = 20000;
for ($n = 0; $n < $runs; $n++) { [$i] = trail_encounter_index($flat, $path, 0, 0, null, '', 3.0); $hits += $i === null ? 0 : 1; }
ok('3 rolled tiles of floor at 3% bring a fight about 1 time in 11 (rolled for real)', $hits / $runs > .065 && $hits / $runs < .11, (string)round($hits / $runs, 3));

echo "== a bendy section installed in the game (v2.6.38)\n";
$b = trail_authored_section(228, 1);
[$bm] = trail_map_authored($b);
$bs = trail_art_svg($bm, ['px' => (int)$bm['entry'][0], 'py' => (int)$bm['entry'][1], 'x0' => 0, 'y0' => 0, 'cols' => 30, 'rows' => 18, 'tokens' => []]);
ok('228 section 2 is 30 x 18 and its picture 228-2-r.png is on disk', $bm['w'] === 30 && $bm['h'] === 18 && trail_art_ready($b) && str_contains($bs, 'ground/228-2-r.png'));
$missing = [];
foreach (trail_authored_all() as $rid => $r) foreach ($r['sections'] as $s) foreach ($s['objs'] ?? [] as $o) if (!is_file($game . '/assets/img/trail/obj/' . $o[2] . '.png')) $missing[$o[2]] = 1;
ok('every raised sprite named in the maps is on disk', !$missing, implode(' ', array_slice(array_keys($missing), 0, 8)));
$jy = null; foreach ($b['objs'] as $o) if (($o[4] ?? 0) !== 0 && str_starts_with($o[2], 'x-')) { $jy = $o; break; }
ok('a sprite with a shift down (5th value) is drawn that many picture pixels lower', $jy && str_contains($bs, 'y="' . tm_n(($jy[1] * TRAIL_ART_PX - 29 + $jy[4]) * (TM_UNIT / TRAIL_ART_PX)) . '"'), json_encode($jy));
ok('the old 22 x 7 picture name is used for a section without pic r', trail_art_sfx(['pic' => 'x']) === '' && trail_art_sfx($b) === '-r');
ok('228 section 2 has water to fish by', trail_water_near($b, 12, 7) && !trail_water_near(trail_authored_section(228, 0), 5, 5));

echo "== the picture\n";
// v2.6.39: every route is 30 x 18 now, so the old 22 x 7 path is tested on route 260 as the OLD file data/trail_maps.json still holds it (loaded alone from a scratch folder).
$oldDir = sys_get_temp_dir() . '/trail-old22-' . getmypid(); @mkdir($oldDir);
copy($game . '/includes/data/trail_maps.json', $oldDir . '/trail_maps.json');
$oldR = trail_authored_load($oldDir)['260'] ?? null;
@unlink($oldDir . '/trail_maps.json'); @rmdir($oldDir);
ok('the old 22 x 7 file still has route 260 (the reference for the old picture path)', $oldR !== null && strlen($oldR['sections'][0]['rows'][0]) === 22 && count($oldR['sections'][0]['rows']) === 7);
$art = $oldR['sections'][0] + ['land' => (string)$oldR['land'], 'art' => (string)($oldR['art'] ?? ''), 'route' => 260, 'sec' => 0, 'boss' => ''];
[$m] = trail_map_authored($art);
$svg = trail_art_svg($m, ['px' => 3, 'py' => 2, 'x0' => -1, 'y0' => -1, 'cols' => 9, 'rows' => 9, 'tokens' => [[6, 2, '✨', 'gold', false], [5, 3, '🚪', 'gold', false]], 'walk' => ['p' => [[2, 2], [3, 2]]]]);
ok('ground picture, walker, a find, an exit mark, footprints', str_contains($svg, 'ground/260-1.png') && str_contains($svg, 'class="tmme"') && str_contains($svg, 'find-forest.png') && str_contains($svg, '#e02020') && str_contains($svg, 'tmft'));
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
echo "== pals beside the walker (v2.5.93)\n";
$withPals = trail_art_svg($m, ['x0' => 0] + $win + ['pals' => ['/p/a.png', '/p/b.png']]);
$noPals = trail_art_svg($m, ['x0' => 0] + $win);
ok('two pals taken along: two pal pictures, inside the walker group', substr_count($withPals, 'class="tmpal"') === 2 && preg_match('~<g class="tmme"[^>]*>(?:(?!</g>).)*class="tmpal"~s', $withPals) === 1, (string)substr_count($withPals, 'class="tmpal"'));
ok('no pals: none drawn', substr_count($noPals, 'class="tmpal"') === 0);
ok('at most three pals are drawn', substr_count(trail_art_svg($m, ['x0' => 0] + $win + ['pals' => ['a', 'b', 'c', 'd']]), 'class="tmpal"') === 3);
echo "== ground picture lookup (Admin > Images uploads win over the shipped ones)\n";
$sc = sys_get_temp_dir() . '/gv-trail-' . bin2hex(random_bytes(4));
mkdir($sc . '/assets/img/trail/ground', 0777, true); mkdir($sc . '/uploads/trail/ground', 0777, true);
ok('no picture anywhere: null', trail_ground_file(256, 1, $sc) === null);
file_put_contents($sc . '/assets/img/trail/ground/256-1.png', 'x');
ok('only the shipped picture: that one', trail_ground_file(256, 1, $sc) === $sc . '/assets/img/trail/ground/256-1.png');
file_put_contents($sc . '/uploads/trail/ground/256-1.png', 'x');
ok('an uploaded picture beats the shipped one', trail_ground_file(256, 1, $sc) === $sc . '/uploads/trail/ground/256-1.png');
ok('another section is still null', trail_ground_file(256, 2, $sc) === null);
array_map('unlink', [$sc . '/assets/img/trail/ground/256-1.png', $sc . '/uploads/trail/ground/256-1.png']);
foreach (['/assets/img/trail/ground', '/assets/img/trail', '/assets/img', '/assets', '/uploads/trail/ground', '/uploads/trail', '/uploads', ''] as $d) @rmdir($sc . $d);
exit($fails ? 1 : 0);
