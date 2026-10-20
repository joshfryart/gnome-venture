<?php
// v2.0.6 tile map core + delve/lair maps. Run by delvemap.sh.
//   php tests/delvemap.php unit GAME_DIR        pure tests (generator, path, fog, window, svg, data files); needs no database
//   php tests/delvemap.php next GAME_DIR EXP N  the tile a player would tap to get nearer to spot N (prints "x,y" and whether it is the spot itself)
//   php tests/delvemap.php scene GAME_DIR EXP   the scene of an expedition as JSON (spots, you, rooms done)
$cmd = $argv[1] ?? 'unit';
$game = $argv[2] ?? dirname(__DIR__) . '/game';
$fails = 0;
function ok(string $what, bool $cond, string $extra = ''): void { global $fails; echo ($cond ? '  ok   ' : '  FAIL ') . $what . ($cond ? '' : "  $extra") . "\n"; if (!$cond) $fails++; }

if ($cmd === 'unit') {
    require $game . '/includes/tilemap.php';
    // ---- parse + tiles
    echo "== parse\n";
    $m = tm_parse("#####\n#S.1#\n#.#.#\n#2..#\n#####");
    ok('size 5x5', $m['w'] === 5 && $m['h'] === 5);
    ok('entry found', $m['entry'] === [1, 1]);
    ok('spots found', $m['spots'] === ['1' => [3, 1], '2' => [1, 3]], json_encode($m['spots']));
    ok('tile + outside', tm_tile($m, 1, 1) === 'S' && tm_tile($m, -1, 0) === ' ' && tm_tile($m, 9, 9) === ' ');
    ok('ragged rows are padded with wall', tm_parse(["###", "#.", "###"])['t'][1] === '#.#');
    ok('walkable: floor yes, wall no, outside no', tm_walkable($m, 2, 1) && !tm_walkable($m, 0, 0) && !tm_walkable($m, 7, 7));
    ok('gate closes a tile', !tm_walkable($m, 2, 1, fn($x, $y, $t) => $x !== 2));
    // ---- path
    echo "== path\n";
    $p = tm_path($m, 1, 1, 3, 3);
    ok('shortest path length', count($p) === 4, json_encode($p));   // (1,1)->(2,1)->(3,1)->(3,2)->(3,3) = 4 steps, or the other way round the wall
    ok('path ends on the goal and starts next to the start', end($p) === [3, 3] && abs($p[0][0] - 1) + abs($p[0][1] - 1) === 1);
    $stepsOk = true;
    $prev = [1, 1];
    foreach ($p as $s) { if (abs($s[0] - $prev[0]) + abs($s[1] - $prev[1]) !== 1 || !tm_walkable($m, $s[0], $s[1])) $stepsOk = false; $prev = $s; }
    ok('every step is one tile on open ground', $stepsOk);
    ok('no path to a wall', tm_path($m, 1, 1, 0, 0) === []);
    ok('no path to where you stand', tm_path($m, 1, 1, 1, 1) === []);
    ok('a closed gate makes the long way (or none)', count(tm_path($m, 1, 1, 3, 3, fn($x, $y, $t) => !($x === 3 && $y === 2))) === 4);   // the other way: (1,2) (1,3) (2,3) (3,3) = 4
    ok('closing both ways = no path', tm_path($m, 1, 1, 3, 3, fn($x, $y, $t) => !($x === 3 && $y === 2) && !($x === 1 && $y === 2)) === []);
    $reach = tm_reach($m, 1, 1);
    ok('reach covers every open tile', count($reach) === 8 && $reach[1 * 5 + 1] === 0, (string)count($reach));
    ok('reach distances', $reach[3 * 5 + 3] === 4);
    // ---- fog
    echo "== fog\n";
    $seen = tm_seen_new(11, 11);
    ok('new fog: nothing seen', !tm_seen_get($seen, 11, 11, 5, 5) && strlen($seen) === 31);
    tm_reveal($seen, 11, 11, 5, 5, 2);
    $n = 0;
    for ($y = 0; $y < 11; $y++) for ($x = 0; $x < 11; $x++) if (tm_seen_get($seen, 11, 11, $x, $y)) $n++;
    ok('radius 2 = a 5 x 5 square', $n === 25, (string)$n);
    ok('inside seen, just outside not', tm_seen_get($seen, 11, 11, 3, 3) && tm_seen_get($seen, 11, 11, 7, 7) && !tm_seen_get($seen, 11, 11, 2, 5) && !tm_seen_get($seen, 11, 11, 5, 8));
    tm_reveal($seen, 11, 11, 0, 0, 1);
    ok('a corner reveal stays on the map (4 tiles)', tm_seen_get($seen, 11, 11, 1, 1) && tm_seen_get($seen, 11, 11, 0, 0) && !tm_seen_get($seen, 11, 11, 2, 2));
    $again = $seen;
    tm_reveal($again, 11, 11, 5, 5, 2);
    ok('revealing twice changes nothing', $again === $seen);
    ok('outside the map is never seen', !tm_seen_get($seen, 11, 11, -1, 0) && !tm_seen_get($seen, 11, 11, 11, 0) && !tm_seen_get($seen, 11, 11, 0, 11));
    ok('hex string only', (bool)preg_match('/^[0-9a-f]+$/', $seen) && strlen($seen) === 31);
    $big = tm_seen_new(13, 13);
    tm_reveal($big, 13, 13, 12, 12, 3);
    ok('13 x 13 fog: last tile works', tm_seen_get($big, 13, 13, 12, 12) && strlen($big) === 43);
    // ---- window
    echo "== window\n";
    $w = tm_window(5, 5, 9, 9);
    ok('centred', $w['x0'] === 1 && $w['y0'] === 1 && $w['cols'] === 9);
    $w = tm_window(0, 0, 9, 9);
    ok('not clamped: the player stays in the middle at a corner', $w['x0'] === -4 && $w['y0'] === -4);
    // ---- generator
    echo "== generator (500 seeds, 11 x 11 delves and 13 x 13 lairs)\n";
    $codes = ['1', '2', '3', '4', '5'];
    $bad = [];
    $maxTries = 0;
    $fallbacks = 0;
    $chestLast = 0;
    $dets = 0;
    for ($i = 0; $i < 500; $i++) {
        $seed = 'lm' . (1 + $i % 14) . '|' . (1000 + $i * 7);
        $info = null;
        $m = tm_gen($seed, 11, $codes, 1, $info);
        $maxTries = max($maxTries, $info['tries']);
        if (!empty($info['fallback'])) $fallbacks++;
        $e = tm_validate($m, $codes);
        if ($e || $m['w'] !== 11 || $m['h'] !== 11) { $bad[] = "$seed: " . implode(';', $e); continue; }
        // all 5 spots reachable in ANY order: play random orders with the real rule (an open spot is a goal; done spots become floor; the 5th only after four)
        for ($o = 0; $o < 4; $o++) {
            $rng = tm_rng($seed . 'order' . $o);
            $order = ['1', '2', '3', '4'];
            for ($k = 3; $k > 0; $k--) { $j = $rng(0, $k); [$order[$k], $order[$j]] = [$order[$j], $order[$k]]; }
            $order[] = '5';
            $done = [];
            [$px, $py] = $m['entry'];
            foreach ($order as $code) {
                [$gx, $gy] = $m['spots'][$code];
                if ($code === '5' && count($done) < 4) { $bad[] = "$seed: gate"; break; }
                $gate = fn($x, $y, $t) => !ctype_digit($t) || in_array($t, $done, true) || ($x === $gx && $y === $gy);
                $path = tm_path($m, $px, $py, $gx, $gy, $gate);
                if (!$path) { $bad[] = "$seed: spot $code not reachable after " . implode('', $done); break 2; }
                [$px, $py] = [$gx, $gy];
                $done[] = $code;
            }
        }
        // the 5th (guardian) is the room farthest from the entry among the spots
        $d = tm_reach($m, $m['entry'][0], $m['entry'][1], fn($x, $y, $t) => !ctype_digit($t));
        $dist = [];
        foreach ($m['spots'] as $c => [$sx, $sy]) { $best = 999; foreach ([[1, 0], [-1, 0], [0, 1], [0, -1]] as [$a, $b]) $best = min($best, $d[($sy + $b) * 11 + $sx + $a] ?? 999); $dist[$c] = $best; }
        if ($dist['5'] >= max($dist)) $chestLast++;
        if ($i < 30 && tm_gen($seed, 11, $codes, 1)['t'] === $m['t']) $dets++;
    }
    ok('500 delve maps valid + connected + every spot reachable in random orders + 5th gated', !$bad, implode(' | ', array_slice($bad, 0, 3)));
    ok('never needed the plain fallback', $fallbacks === 0, (string)$fallbacks);
    ok('tries stay low (max ' . $maxTries . ')', $maxTries <= 80);
    ok('the guardian is the farthest room in almost all maps (' . $chestLast . '/500)', $chestLast >= 400);
    ok('same seed = same map', $dets === 30);
    $diff = [];
    for ($i = 0; $i < 40; $i++) $diff[implode('', tm_gen('lm1|' . $i, 11, $codes, 1)['t'])] = 1;
    ok('different seeds give different maps (' . count($diff) . '/40)', count($diff) >= 30);
    $bad = [];
    $fb = 0;
    for ($i = 0; $i < 500; $i++) {
        $seed = 'lm' . (1 + $i % 14) . '|' . (5000 + $i * 11);
        $info = null;
        $m = tm_gen($seed, 13, ['1'], 3, $info);
        if (!empty($info['fallback'])) $fb++;
        $e = tm_validate($m, ['1']);
        if ($e || $m['w'] !== 13 || $m['h'] !== 13) { $bad[] = "$seed: " . implode(';', $e); continue; }
        $path = tm_path($m, $m['entry'][0], $m['entry'][1], $m['spots']['1'][0], $m['spots']['1'][1]);
        if (!$path) $bad[] = "$seed: boss not reachable";
    }
    ok('500 lair maps valid (13 x 13, boss reachable)', !$bad, implode(' | ', array_slice($bad, 0, 3)));
    ok('lairs never needed the fallback', $fb === 0, (string)$fb);
    // ---- hand-built layouts
    echo "== hand-built layouts\n";
    require $game . '/includes/delve_map.php';
    $L = dm_layouts();
    ok('three hand-built layouts load', count($L) === 3, implode(',', array_keys($L)));
    foreach ($L as $name => $rows) {
        $m = tm_parse($rows);
        ok("$name: 11 x 11, entry, spots 1-5, connected, any order", $m['w'] === 11 && $m['h'] === 11 && !tm_validate($m, $codes), implode(';', tm_validate($m, $codes)));
    }
    $uses = [];
    for ($id = 1; $id <= 60; $id++) { [$m, $key] = dm_map_for('delve', $id, 5); $uses[$key[0]] = ($uses[$key[0]] ?? 0) + 1; }
    ok('some delves take a hand-built layout, most are made from the seed (' . json_encode($uses) . ')', ($uses['h'] ?? 0) > 0 && ($uses['g'] ?? 0) > ($uses['h'] ?? 0));
    [$a, $ka] = dm_map_for('delve', 3, 100);
    [$b, $kb] = dm_map_for('delve', 3, 100);
    ok('a delve map is the same each time for the same ids', $a['t'] === $b['t'] && $ka === $kb);
    ok('a key brings the same map back', dm_map_from_key($ka)['t'] === $a['t'] && dm_map_from_key('h:gallery') !== null && dm_map_from_key('nonsense') === null && dm_map_from_key('h:../../x') === null);
    // ---- svg
    echo "== svg\n";
    $m = tm_gen('svg|1', 11, $codes, 1);
    $seen = tm_seen_new(11, 11);
    $blank = tm_render_svg($m, 'forest', ['px' => 5, 'py' => 5, 'seen' => $seen, 'x0' => 1, 'y0' => 1, 'cols' => 9, 'rows' => 9]);
    ok('nothing seen = no tile drawn (only the dark background and the walker)', !str_contains($blank, '<path') && str_contains($blank, 'class="tmme"'));
    [$ex, $ey] = $m['entry'];
    tm_reveal($seen, 11, 11, $ex, $ey, 3);
    $svg = tm_render_svg($m, 'forest', ['px' => $ex, 'py' => $ey, 'seen' => $seen, 'x0' => $ex - 4, 'y0' => $ey - 4, 'cols' => 9, 'rows' => 9, 'tokens' => [[$ex, $ey, '🚪', 'gold', false]]]);
    ok('seen tiles are drawn as paths, one svg', substr_count($svg, '<svg') === 1 && str_contains($svg, '<path') && str_contains($svg, 'viewBox="0 0 378 378"'));
    ok('no inline style attributes (the page CSP forbids them)', !str_contains($svg, 'style='));
    ok('well-formed xml', @simplexml_load_string($svg) !== false);
    ok('token drawn', str_contains($svg, 'class="tmtok"'));
    foreach (['forest', 'grassland', 'coast', 'mountain', 'desert', 'rainforest', 'wetland', 'tundra', 'island', 'cave', 'nonsense'] as $land) {
        $P = tm_palette($land);
        ok("palette $land complete", count(array_filter($P, fn($c) => preg_match('/^#[0-9a-f]{6}$/i', $c))) === count($P) && isset($P['floor'], $P['rock'], $P['bed']));
    }
    ok('landscape palettes differ', tm_palette('desert')['rock'] !== tm_palette('tundra')['rock'] && tm_palette('forest')['floor'] !== tm_palette('coast')['floor']);
    $walk = tm_render_svg($m, 'forest', ['px' => $ex, 'py' => $ey, 'seen' => $seen, 'x0' => $ex - 4, 'y0' => $ey - 4, 'cols' => 9, 'rows' => 9, 'walk' => ['p' => [[$ex, $ey], [$ex + 1, $ey], [$ex + 2, $ey]]]]);
    ok('walk footprints carry their order', str_contains($walk, 'class="tmft" data-i="0"') && str_contains($walk, 'data-i="1"'));
    echo $fails ? "\nFAILED: $fails\n" : "\nall unit tests passed\n";
    exit($fails ? 1 : 0);
}

// ---------------- helpers that need the installed game
$_SERVER['SCRIPT_NAME'] = '/adventure.php';
require $game . '/includes/bootstrap.php';
require_once $game . '/includes/adventure.php';
$exp = (int)($argv[3] ?? 0);
$row = q_one('SELECT * FROM expeditions WHERE id = ?', [$exp]);
if (!$row) { echo "no such expedition\n"; exit(1); }
$sc = dm_scene($row);
if ($cmd === 'scene') {
    echo json_encode($sc ? ['key' => $sc['row']['map_key'], 'x' => $sc['x'], 'y' => $sc['y'], 'c' => $sc['c'], 'spots' => $sc['map']['spots'], 'entry' => $sc['map']['entry'], 'seen' => $sc['seen'], 'depth' => (int)$row['depth']] : null) . "\n";
    exit(0);
}
if ($cmd === 'next') {   // what a player would tap to get nearer to spot N: the spot itself if it can be walked to, else the reachable lit tile closest to it
    $code = (string)($argv[4] ?? '1');
    if (!$sc) { echo "none\n"; exit(0); }
    [$gx, $gy] = $sc['map']['spots'][$code];
    $map = $sc['map'];
    if ($sc['x'] === $gx && $sc['y'] === $gy) { echo "$gx,$gy spot\n"; exit(0); }
    $reach = tm_reach($map, $sc['x'], $sc['y'], dm_gate($sc));
    $best = null;
    $goalTouch = false;
    foreach ($reach as $k => $d) {
        $x = $k % $map['w'];
        $y = intdiv($k, $map['w']);
        if (!tm_seen_get($sc['seen'], $map['w'], $map['h'], $x, $y)) continue;
        if (abs($x - $gx) + abs($y - $gy) === 1 && tm_seen_get($sc['seen'], $map['w'], $map['h'], $gx, $gy)) $goalTouch = true;
        $dist = abs($x - $gx) + abs($y - $gy);
        if ($best === null || $dist < $best[0] || ($dist === $best[0] && $d < $best[3])) $best = [$dist, $x, $y, $d];
    }
    if ($goalTouch) { echo "$gx,$gy spot\n"; exit(0); }
    echo $best && ($best[1] !== $sc['x'] || $best[2] !== $sc['y']) ? $best[1] . ',' . $best[2] . " step\n" : "stuck\n";
    exit(0);
}
echo "unknown command\n";
exit(1);
