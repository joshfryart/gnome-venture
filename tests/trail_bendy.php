<?php
// v2.7 bendy Trail maps (30 x 18 sections, entry and exit on any edge, tool gates). Pure, no database.  php tests/trail_bendy.php [GAMEDIR]
// Data: claude/maplewold-bendy-maps/trail_maps_maplewold_30x18.json (python3 tools/bendy_to_trail_maps.py). Not game data yet (no ground pictures at 30 x 18).
$game = $argv[1] ?? dirname(__DIR__) . '/game';
$fails = 0;
function ok(string $what, bool $cond, string $extra = ''): void { global $fails; echo ($cond ? '  ok   ' : '  FAIL ') . $what . ($cond ? '' : "  $extra") . "\n"; if (!$cond) $fails++; }
function e($v): string { return htmlspecialchars((string)$v, ENT_QUOTES, 'UTF-8'); }
require_once $game . '/includes/tilemap.php';
require_once $game . '/includes/trail_art.php';
require_once $game . '/includes/trail_tiles.php';
$src = dirname($game) . '/claude/maplewold-bendy-maps/trail_maps_maplewold_30x18.json';
if (!is_file($src)) { echo "no $src (python3 tools/bendy_to_trail_maps.py)\n"; exit(1); }
$tmp = sys_get_temp_dir() . '/trail-bendy-' . getmypid();
@mkdir($tmp . '/trail_maps', 0777, true);
copy($src, $tmp . '/trail_maps/maplewold.json');

echo "== loading\n";
$all = trail_authored_load($tmp);
ok('all 16 Maplewold routes are valid for the loader', count($all) === 16, (string)count($all));
$art = function (string $rid, int $si) use ($all): array {
    $r = $all[$rid]; $s = $r['sections'][$si];
    return $s + ['land' => (string)$r['land'], 'art' => (string)$r['art'], 'route' => (int)$rid, 'sec' => $si, 'boss' => ($si === count($r['sections']) - 1) ? (string)$r['boss'] : ''];
};
echo "== every section\n";
$bad = []; $secs = 0; $bossE = [];
foreach ($all as $rid => $r) {
    $prev = null;
    foreach ($r['sections'] as $si => $_) {
        $secs++; $a = $art((string)$rid, $si); [$m, $t] = trail_map_authored($a);
        $en = $m['entry']; $ex = $m['spots']['9'] ?? null;
        if ($m['w'] !== 30 || $m['h'] !== 18) $bad[] = "$rid#$si size {$m['w']}x{$m['h']}";
        if (!$en || !$ex) { $bad[] = "$rid#$si entry or exit missing"; continue; }
        $edge = fn($p) => $p[0] === 0 || $p[1] === 0 || $p[0] === $m['w'] - 1 || $p[1] === $m['h'] - 1;
        if (!$edge($en) || !$edge($ex)) $bad[] = "$rid#$si entry or exit off the edge";
        if (($si === 0) !== (strpos(implode('', $a['rows']), 'S') !== false)) $bad[] = "$rid#$si S only in section 1";
        $reach = tm_reach($m, $en[0], $en[1]);
        if (!isset($reach[$ex[1] * $m['w'] + $ex[0]])) $bad[] = "$rid#$si exit not reachable";
        foreach ($t as [$x, $y, $k]) { if (!isset($reach[$y * $m['w'] + $x])) $bad[] = "$rid#$si token $x,$y unreachable"; if ($k === 'E') $bossE[] = "$rid#$si"; }
        if ($prev) {   // the join: the exit of the section before, moved across, is this entry
            $side = $prev['ex'][0] === 29 ? 'E' : ($prev['ex'][0] === 0 ? 'W' : ($prev['ex'][1] === 0 ? 'N' : 'S'));
            $eside = $en[0] === 0 ? 'W' : ($en[0] === 29 ? 'E' : ($en[1] === 0 ? 'N' : 'S'));
            $same = in_array($side, ['E', 'W'], true) ? $en[1] === $prev['ex'][1] : $en[0] === $prev['ex'][0];
            if (!$same || ['E' => 'W', 'W' => 'E', 'N' => 'S', 'S' => 'N'][$side] !== $eside) $bad[] = "$rid#$si join";
        }
        $prev = ['ex' => $ex];
    }
}
ok('41 sections', $secs === 41, (string)$secs);
ok('every section: 30 x 18, entry and exit on an edge (any edge), exit and tokens reachable, S only in section 1, joins line up', !$bad, implode('; ', $bad));
sort($bossE);
ok('a fixed fight only on the last section of 313 (miniboss) and 315 (boss)', $bossE === ['313#2', '315#4'], json_encode($bossE));
ok('some section leaves on a north or south edge (a bend off the east-west line)', (function () use ($all, $art) { foreach ($all as $rid => $r) foreach ($r['sections'] as $si => $_) { $m = trail_map_authored($art((string)$rid, $si))[0]; $e = $m['spots']['9']; if ($e[1] === 0 || $e[1] === 17) return true; } return false; })());
ok('a section without an S in its rows gets its entry from "entry" (313 section 2)', trail_map_authored($art('313', 1))[0]['t'][10][0] === 'S');

echo "== validator\n";
$row = fn(string $a) => str_pad($a, 8, '#');
$mk = fn(array $rows, array $extra = []) => ['land' => 'forest', 'sections' => [['rows' => $rows] + $extra]];
$base = ['########', '#S.....9', '########'];
ok('an exit on the east edge is fine (as before)', trail_authored_valid($mk($base)));
ok('an exit on the top edge is fine now', trail_authored_valid($mk(['####9###', '#S.....#', '########'])));
ok('an exit not on an edge is refused', !trail_authored_valid($mk(['########', '#S..9..#', '########'])));
ok('two exits are refused', !trail_authored_valid($mk(['####9###', '#S.....9', '########'])));
ok('two entries are refused', !trail_authored_valid($mk(['########', '#S...S.9', '########'])));
ok('no S and no entry is refused', !trail_authored_valid($mk(['########', '#......9', '########'])));
ok('no S but an entry on the edge is fine', trail_authored_valid($mk(['########', '.......9', '########'], ['entry' => ['side' => 'W', 'x' => 0, 'y' => 1]])));
ok('an entry inside the map is refused', !trail_authored_valid($mk(['########', '#......9', '########'], ['entry' => ['x' => 2, 'y' => 1]])));
ok('an entry on a wall is refused', !trail_authored_valid($mk(['########', '#......9', '########'], ['entry' => ['x' => 0, 'y' => 0]])));
$g = ['tiles' => [[3, 1]], 'tool_type' => 'axe', 'min_tier' => 2, 'kind' => 'lock', 'label' => 'x'];
ok('a valid gate record is accepted', trail_authored_valid($mk($base, ['gates' => [$g]])));
ok('a gate with an unknown tool type is refused', !trail_authored_valid($mk($base, ['gates' => [['tool_type' => 'wand'] + $g]])));
ok('a gate with tier 5 is refused', !trail_authored_valid($mk($base, ['gates' => [['min_tier' => 5] + $g]])));
ok('a gate tile outside the map is refused', !trail_authored_valid($mk($base, ['gates' => [['tiles' => [[9, 9]]] + $g]])));
ok('a gate with an odd kind is refused', !trail_authored_valid($mk($base, ['gates' => [['kind' => 'door'] + $g]])));

echo "== gates\n";
$sc0 = ['st' => ['tokens' => []]];
$gates = 0; $gbad = [];
foreach ($all as $rid => $r) foreach ($r['sections'] as $si => $s) foreach ($s['gates'] ?? [] as $gi => $gt) {
    $gates++; $a = $art((string)$rid, $si); [$m] = trail_map_authored($a); $en = $m['entry']; $ex = $m['spots']['9'];
    $shut = trail_gates_closed($a, fn(string $type): int => 0);
    $open = trail_gates_closed($a, fn(string $type): int => (int)$gt['min_tier']);
    $none = trail_gates_closed($a, fn(string $type): int => $type === $gt['tool_type'] ? (int)$gt['min_tier'] - 1 : 4);
    $pClosed = tm_path($m, $en[0], $en[1], $ex[0], $ex[1], trail_gate($sc0, $ex[0], $ex[1], $shut));
    $pOpen = tm_path($m, $en[0], $en[1], $ex[0], $ex[1], trail_gate($sc0, $ex[0], $ex[1], $open));
    if ($open) $gbad[] = "$rid#$si gate open with the right tool but still listed shut";
    if (!$pOpen) $gbad[] = "$rid#$si no way through with the tool";
    if (!$none) $gbad[] = "$rid#$si a tool one tier too low must not open it";
    if ($gt['kind'] === 'lock' && $pClosed) $gbad[] = "$rid#$si lock can be walked around";
    if ($gt['kind'] === 'shortcut' && (!$pClosed || count($pClosed) < count($pOpen) + 6)) $gbad[] = "$rid#$si shortcut: way round missing or too short";
    if ($gt['kind'] === 'lock' && ($pClosed || !$pOpen)) $gbad[] = "$rid#$si lock paths";
}
ok('4 gates in the Maplewold data (313, 314, 315 x2)', $gates === 4, (string)$gates);
ok('locks stop a walker without the tool and let one with it through; a shortcut leaves the long way round; one tier too low stays shut', !$gbad, implode('; ', $gbad));
ok('a wrong-type tool does not open a gate', (function () use ($art) { $a = $art('313', 2); return count(trail_gates_closed($a, fn(string $t): int => $t === 'lantern' ? 0 : 4)) === 3; })());

$a = $art('313', 2); [$m3] = trail_map_authored($a); $sh = trail_gates_closed($a, fn(string $t): int => 0); $ex3 = $m3['spots']['9'];
$p3 = tm_path($m3, $m3['entry'][0], $m3['entry'][1], $ex3[0], $ex3[1], trail_gate($sc0, $ex3[0], $ex3[1]));
$msg = trail_gate_message($sh, $p3);
ok('the message names the gate and the tool (313 tunnel mouth: Miner’s Lantern)', $msg !== null && str_contains($msg, 'tunnel mouth') && str_contains($msg, 'Miner’s Lantern'), (string)$msg);
ok('a path that crosses no shut gate gets no message', trail_gate_message([], $p3) === null);

echo "== the camera on a 30 x 18 map\n";
foreach ([[0, 10], [29, 10], [20, 0], [20, 17], [0, 0], [15, 9], [29, 17]] as [$cx, $cy]) {
    $wn = tm_window_clamped($cx, $cy, 9, 9, 30, 18); $vx0 = $wn['x0'] + 1; $vy0 = $wn['y0'] + 1;
    ok("camera at $cx,$cy keeps the 7 x 7 inside 30 x 18 and the gnome in it", $vx0 >= 0 && $vy0 >= 0 && $vx0 + 7 <= 30 && $vy0 + 7 <= 18 && $cx >= $vx0 && $cx < $vx0 + 7 && $cy >= $vy0 && $cy < $vy0 + 7, json_encode($wn));
}
$mid = tm_window_clamped(15, 9, 9, 9, 30, 18);
ok('in the middle the gnome is centred in both directions', $mid['x0'] === 11 && $mid['y0'] === 5, json_encode($mid));
ok('the fog of war covers 540 tiles (one bit each)', strlen(tm_seen_new(30, 18)) === 135, (string)strlen(tm_seen_new(30, 18)));
$seen = tm_seen_new(30, 18); tm_reveal($seen, 30, 18, 29, 17, 3);
ok('revealing in the far corner works', tm_seen_get($seen, 30, 18, 29, 17) && tm_seen_get($seen, 30, 18, 27, 16) && !tm_seen_get($seen, 30, 18, 0, 0));
$a = $art('315', 4); [$m, $t] = trail_map_authored($a);
$svg = trail_art_svg($m, ['px' => 3, 'py' => 8, 'x0' => 0, 'y0' => 4, 'cols' => 9, 'rows' => 9, 'tokens' => []]);
ok('a 30 x 18 section draws', str_contains($svg, '<svg') && str_contains($svg, '</svg>'));
echo "== fishing beside water\n";
$w = ['rows' => ['.....', '.....', '.....'], 'wet' => ['00000', '00010', '00000']];
ok('on the water tile', trail_water_near($w, 3, 1));
ok('diagonally beside it', trail_water_near($w, 2, 0) && trail_water_near($w, 4, 2));
ok('two tiles away is too far', !trail_water_near($w, 1, 1) && !trail_water_near($w, 0, 0));
ok('a section without water has no fishing', !trail_water_near(['rows' => ['...']], 1, 0));
ok('stream points count when there is no wet grid', trail_water_near(['water' => [['pts' => [[5, 5], [6, 5]]]]], 7, 6) && !trail_water_near(['water' => [['pts' => [[5, 5]]]]], 7, 5));
ok('a pond given only by its centre gives no tiles', trail_water_tiles(['water' => [['pond' => [4, 4]]]]) === []);
$sc = ['x' => 2, 'y' => 1, 'st' => ['phase' => 'section'], 'map' => ['art' => $w]];
ok('the Fish button shows beside water', trail_fish_here($sc));
ok('not two tiles away', !trail_fish_here(['x' => 0] + $sc));
ok('not on a made-up (unauthored) section', !trail_fish_here(['map' => []] + $sc) && !trail_fish_here(null));
$bake = dirname($game) . '/claude/maplewold-bendy-maps/bake/trail_maps_maplewold_30x18.json';
if (is_file($bake)) {
    $bj = json_decode((string)file_get_contents($bake), true)['routes'];
    $n = 0; $shape = true; $walkBy = 0;
    foreach ($bj as $rid => $r) foreach ($r['sections'] as $s) {
        if (empty($s['wet'])) continue;
        $n++;
        if (count($s['wet']) !== count($s['rows'])) $shape = false;
        foreach ($s['wet'] as $y => $row) if (strlen($row) !== strlen($s['rows'][$y]) || !preg_match('/^[01]+$/', $row)) $shape = false;
        $hit = false;
        foreach ($s['rows'] as $y => $row) for ($x = 0; $x < strlen($row); $x++) if ($row[$x] !== '#' && trail_water_near($s, $x, $y)) $hit = true;
        if ($hit) $walkBy++;
    }
    ok('the bake marks water tiles in some sections, in the shape of the rows', $n > 10 && $shape, "$n sections");
    ok('nearly every section with water has a walkable tile to fish from (a pool shut in by thicket has none)', $walkBy >= $n - 2, "$walkBy of $n");
    ok('228 section 2 (West River): fishing at the ford', trail_water_near($bj['228']['sections'][1], 12, 7));
}
array_map('unlink', glob($tmp . '/trail_maps/*')); @rmdir($tmp . '/trail_maps'); @rmdir($tmp);
echo $fails ? "$fails FAILED\n" : "ok\n";
exit($fails ? 1 : 0);
