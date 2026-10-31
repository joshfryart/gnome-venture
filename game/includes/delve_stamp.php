<?php
declare(strict_types=1);

/**
 * v2.3.1 Delve floors from stamped chambers (no database). Each delve has a small library of hand-made chambers (includes/data/delve_chambers.txt):
 * "@slug/name", "size: 3|5|6", optional "tags:", then size x size rows of # . , W only. A floor is 2 x 2 chambers with a one tile wall between them
 * (small 9 = 3+3, standard 13 = 5+5, large 15 = 6+6), joined by doorways, then the objects of the floor kind are put on floor tiles (see dv2_stamp_floor).
 * A delve with no chambers of its own uses the "any" ones; none at all = the caller falls back to tm_gen.
 */

require_once __DIR__ . '/delve_floors.php';

const DS_CELL = ['small' => 3, 'standard' => 5, 'large' => 6];
const DS_ROWCHARS = '#.,W';

/** Parse chamber text: ['chambers' => [key => [key, slug, name, size, tags, rows]], 'errors' => [..]]. */
function ds_parse(string $text): array
{
    $out = [];
    $errors = [];
    $cur = null;
    $flush = function () use (&$cur, &$out, &$errors) {
        if ($cur === null) return;
        if (isset($out[$cur['key']])) $errors[] = $cur['key'] . ': duplicate name'; else $out[$cur['key']] = $cur;
        $cur = null;
    };
    foreach (preg_split('/\r\n|\n|\r/', $text) as $line) {
        $line = rtrim($line);
        if ($line === '' || ($line[0] === '#' && ($line === '#' || $line[1] === ' '))) continue;
        if ($line[0] === '@') {
            $flush();
            $key = trim(substr($line, 1));
            if (!preg_match('~^([a-z0-9-]+)/([a-z0-9_-]+)$~', $key, $m)) { $errors[] = 'bad chamber header ' . $line; continue; }
            $cur = ['key' => $key, 'slug' => $m[1], 'name' => $m[2], 'size' => 0, 'tags' => [], 'rows' => []];
            continue;
        }
        if ($cur === null) { $errors[] = 'text outside a chamber: ' . $line; continue; }
        if (preg_match('/^size:\s*(\d+)$/', $line, $m)) { $cur['size'] = (int)$m[1]; continue; }
        if (preg_match('/^tags:\s*(.*)$/', $line, $m)) { $cur['tags'] = array_values(array_filter(array_map('trim', explode(',', $m[1])))); continue; }
        $cur['rows'][] = $line;
    }
    $flush();
    return ['chambers' => $out, 'errors' => $errors];
}

/** Lint a chamber: returns problems ([] = fine). */
function ds_lint(array $c): array
{
    $bad = [];
    $n = $c['size'];
    if (!in_array($n, DS_CELL, true)) return ['size must be 3, 5 or 6'];
    if (count($c['rows']) !== $n) return ['needs ' . $n . ' rows, has ' . count($c['rows'])];
    foreach ($c['rows'] as $y => $r) {
        if (strlen($r) !== $n) { $bad[] = 'row ' . ($y + 1) . ' is not ' . $n . ' wide'; continue; }
        for ($x = 0; $x < $n; $x++) if (strpos(DS_ROWCHARS, $r[$x]) === false) $bad[] = 'bad character "' . $r[$x] . '"';
    }
    if ($bad) return array_values(array_unique($bad));
    $floor = [];
    for ($y = 0; $y < $n; $y++) for ($x = 0; $x < $n; $x++) if ($c['rows'][$y][$x] !== '#') $floor[] = [$x, $y];
    if (count($floor) < intdiv($n * $n * 4, 10)) return ['too little floor (under 40%)'];
    $map = tm_parse($c['rows']);
    $reach = tm_reach($map, $floor[0][0], $floor[0][1]);
    if (count($reach) !== count($floor)) $bad[] = 'floor is not all connected';
    $edge = 0;
    foreach ($floor as [$x, $y]) if ($x === 0 || $y === 0 || $x === $n - 1 || $y === $n - 1) $edge++;
    if ($edge < 2) $bad[] = 'needs at least 2 floor tiles on its edge';
    $water = 0;
    foreach ($floor as [$x, $y]) if ($c['rows'][$y][$x] === 'W') $water++;
    if ($water > intdiv(count($floor), 2)) $bad[] = 'more than half water';
    return $bad;
}

/** Chambers that pass the lint: key => chamber. $text null = the data file. */
function ds_chambers(?string $text = null): array
{
    static $cache = null;
    if ($text === null && $cache !== null) return $cache;
    if ($text === null) { $path = __DIR__ . '/data/delve_chambers.txt'; $text = is_file($path) ? (string)file_get_contents($path) : ''; }
    $ok = [];
    foreach (ds_parse($text)['chambers'] as $k => $c) if (!ds_lint($c)) $ok[$k] = $c;
    if (func_num_args() === 0) $cache = $ok;
    return $ok;
}

/** The chambers a delve may use: its own, else the shared "any" ones; of one size. List (stable order). */
function ds_pool(string $slug, int $size, ?array $all = null): array
{
    $all = $all ?? ds_chambers();
    $own = $any = [];
    foreach ($all as $c) {
        if ($c['size'] !== $size) continue;
        if ($c['slug'] === $slug) $own[] = $c; elseif ($c['slug'] === 'any') $any[] = $c;
    }
    return $own ?: $any;
}

/** Put $ch on $rows at $ox,$oy. */
function ds_put(array &$g, array $c, int $ox, int $oy): void
{
    foreach ($c['rows'] as $y => $r) for ($x = 0; $x < $c['size']; $x++) $g[$oy + $y][$ox + $x] = $r[$x];
}

/**
 * A floor from stamped chambers. $objs = the objects of the node kind (DV2_GEN): '1' finds, F, T, C, E, B ... The last one goes in the cell farthest from the way in.
 * Returns a parsed map (tm_parse) or null (no chambers for this size, or no valid layout in 60 tries).
 */
function ds_floor(string $seed, string $slug, string $tier, array $objs, ?array $all = null): ?array
{
    $n = DS_CELL[$tier] ?? 0;
    $pool = ds_pool($slug, $n, $all);
    if (!$n || count($pool) < 2) return null;
    $N = 2 * $n + 3;
    for ($try = 0; $try < 60; $try++) {
        $rng = tm_rng('dsfloor|' . $seed . '|' . $slug . '|' . $try);
        $g = array_fill(0, $N, array_fill(0, $N, '#'));
        $org = [[1, 1], [$n + 2, 1], [1, $n + 2], [$n + 2, $n + 2]];
        $used = [];
        foreach ($org as $i => [$ox, $oy]) {
            $c = $pool[$rng(0, count($pool) - 1)];
            for ($k = 0; $k < 6 && count($pool) > 3 && in_array($c['key'], $used, true); $k++) $c = $pool[$rng(0, count($pool) - 1)];
            $used[] = $c['key'];
            ds_put($g, $c, $ox, $oy);
        }
        // doorways: 3 of the 4 neighbour pairs (a spanning tree of the 2x2 ring), the 4th sometimes
        $edges = [[0, 1], [2, 3], [0, 2], [1, 3]];
        for ($i = 3; $i > 0; $i--) { $j = $rng(0, $i); [$edges[$i], $edges[$j]] = [$edges[$j], $edges[$i]]; }
        $take = $rng(1, 100) <= 40 ? 4 : 3;
        $adj = [0 => [], 1 => [], 2 => [], 3 => []];
        foreach (array_slice($edges, 0, $take) as [$a, $b]) {
            $adj[$a][] = $b; $adj[$b][] = $a;
            $horiz = $org[$a][1] === $org[$b][1];
            $best = [];
            for ($k = 0; $k < $n; $k++) {
                if ($horiz) { $x = $org[$a][0] + $n; $y = $org[$a][1] + $k; $ok = $g[$y][$x] !== '#' && $g[$y][$x + 2] !== '#'; $p = [$x + 1, $y, $x, $x + 2]; }
                else { $y = $org[$a][1] + $n; $x = $org[$a][0] + $k; $ok = $g[$y][$x] !== '#' && $g[$y + 2][$x] !== '#'; $p = [$x, $y + 1, $y, $y + 2]; }
                if ($ok) $best[] = $p;
            }
            if ($best) { $p = $best[$rng(0, count($best) - 1)]; $g[$p[1]][$p[0]] = '.'; continue; }
            $k = $rng(0, $n - 1);   // nothing lines up: carve a doorway through both edge tiles
            if ($horiz) { $y = $org[$a][1] + $k; $x = $org[$a][0] + $n; foreach ([$x, $x + 1, $x + 2] as $xx) if ($g[$y][$xx] === '#') $g[$y][$xx] = '.'; }
            else { $x = $org[$a][0] + $k; $y = $org[$a][1] + $n; foreach ([$y, $y + 1, $y + 2] as $yy) if ($g[$yy][$x] === '#') $g[$yy][$x] = '.'; }
        }
        // cells by distance from the way in
        $start = $rng(0, 3);
        $dist = [$start => 0];
        $q = [$start];
        for ($qi = 0; $qi < count($q); $qi++) foreach ($adj[$q[$qi]] as $nb) if (!isset($dist[$nb])) { $dist[$nb] = $dist[$q[$qi]] + 1; $q[] = $nb; }
        $far = $start;
        foreach ($dist as $cell => $d) if ($d > $dist[$far] || ($d === $dist[$far] && $cell !== $start && $far === $start)) $far = $cell;
        $free = function (int $cell) use (&$g, $org, $n): array {
            $o = [];
            for ($y = 0; $y < $n; $y++) for ($x = 0; $x < $n; $x++) {
                $X = $org[$cell][0] + $x; $Y = $org[$cell][1] + $y;
                if ($g[$Y][$X] === '.' || $g[$Y][$X] === ',') $o[] = [$X, $Y];
            }
            return $o;
        };
        $place = function (string $ch, int $cell) use (&$g, $free, $rng): bool {
            $f = $free($cell);
            if (!$f) return false;
            [$x, $y] = $f[$rng(0, count($f) - 1)];
            $g[$y][$x] = $ch;
            return true;
        };
        $ok = $place('S', $start);
        $last = end($objs);
        $rest = array_slice($objs, 0, -1);
        $ok = $ok && $place($last, $far);
        $cells = array_values(array_diff([0, 1, 2, 3], [$start]));
        foreach ($rest as $i => $ch) {
            $cell = $cells[($i + $rng(0, 2)) % count($cells)];
            if ($ch === 'C' && $last === 'B') $cell = $far;
            $ok = $ok && $place($ch, $cell);
        }
        if (!$ok) continue;
        $rows = array_map(fn($r) => implode('', $r), $g);
        $all = implode('', $rows);
        if (substr_count($all, 'W') * 100 > 18 * (strlen($all) - substr_count($all, '#'))) continue;   // too wet: more than 18% of the floor is water
        $f = ['tier' => $tier, 'rule' => 'x', 'for' => [in_array('B', $objs, true) ? 'boss' : ($tier === 'large' ? 'treasure' : 'fight')], 'rows' => $rows, 'map' => tm_parse($rows)];
        if (!dv_floor_lint($f)) return $f['map'];
    }
    return null;
}
