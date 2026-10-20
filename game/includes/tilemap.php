<?php
declare(strict_types=1);

/**
 * v2.0.6 Tile maps: the generic core. No game rules and no Trek code in here (the Treks keep their own map engine).
 * A map is ['w','h','t' => rows of characters, 'entry' => [x, y] or null, 'spots' => [code => [x, y]]].
 *   '#' wall   '.' floor   ',' rough floor (same, looks different)   'S' entry   '1'..'9' spot tiles   ' ' nothing (off the map)
 * Pure functions on arrays, so they test without a database. tm_render_svg() draws a window of the map as ONE inline svg
 * (cave style, coloured by the palette of a landscape). The page puts a grid of buttons over it (see includes/delve_map.php)
 * and assets/tilemap.js walks the token. Fog of war is a hex bitset string: one bit per tile (tm_seen_*).
 */

const TM_UNIT = 42;   // one tile = 42 svg units (css scales it); the page tells assets/tilemap.js through data-tile

/** Turn ASCII rows (or one text with line breaks) into a map. Rows are padded to the widest. */
function tm_parse($rows): array
{
    if (is_string($rows)) $rows = preg_split('/\r\n|\n|\r/', $rows);
    $rows = array_values(array_filter(array_map(fn($r) => rtrim((string)$r, "\r\n"), $rows), fn($r) => $r !== ''));
    $w = $rows ? max(array_map('strlen', $rows)) : 0;
    $t = [];
    $entry = null;
    $spots = [];
    foreach ($rows as $y => $r) {
        $r = str_pad($r, $w, '#');
        $t[] = $r;
        for ($x = 0; $x < $w; $x++) {
            $c = $r[$x];
            if ($c === 'S') $entry = [$x, $y];
            elseif (ctype_digit($c) && $c !== '0') $spots[$c] = [$x, $y];
        }
    }
    ksort($spots);
    return ['w' => $w, 'h' => count($t), 't' => $t, 'entry' => $entry, 'spots' => $spots];
}

/** The character at a tile (' ' outside the map). */
function tm_tile(array $map, int $x, int $y): string
{
    return ($x < 0 || $y < 0 || $x >= $map['w'] || $y >= $map['h']) ? ' ' : $map['t'][$y][$x];
}

/** Spot tiles of a map: [code => [x, y]]. */
function tm_spots(array $map): array
{
    return $map['spots'];
}

/** Can a walker stand here? $gate = fn(int $x, int $y, string $tile): bool may close tiles (locked doors, rooms not yet open). */
function tm_walkable(array $map, int $x, int $y, ?callable $gate = null): bool
{
    $c = tm_tile($map, $x, $y);
    if ($c === '#' || $c === ' ') return false;
    return $gate === null || (bool)$gate($x, $y, $c);
}

/** Shortest walk (4 directions) from (sx,sy) to (tx,ty): the tiles to step on, start left out. [] = no way, or already there. */
function tm_path(array $map, int $sx, int $sy, int $tx, int $ty, ?callable $gate = null): array
{
    if (($sx === $tx && $sy === $ty) || !tm_walkable($map, $tx, $ty, $gate)) return [];
    $w = $map['w'];
    $prev = [$sy * $w + $sx => -1];
    $queue = [$sy * $w + $sx];
    $goal = $ty * $w + $tx;
    for ($qi = 0; $qi < count($queue); $qi++) {
        $cur = $queue[$qi];
        if ($cur === $goal) break;
        $cx = $cur % $w;
        $cy = intdiv($cur, $w);
        foreach ([[1, 0], [-1, 0], [0, 1], [0, -1]] as [$dx, $dy]) {
            $nx = $cx + $dx;
            $ny = $cy + $dy;
            $k = $ny * $w + $nx;
            if ($nx < 0 || $ny < 0 || $nx >= $w || $ny >= $map['h'] || isset($prev[$k]) || !tm_walkable($map, $nx, $ny, $gate)) continue;
            $prev[$k] = $cur;
            $queue[] = $k;
        }
    }
    if (!isset($prev[$goal])) return [];
    $path = [];
    for ($k = $goal; $k !== -1 && $k !== $sy * $w + $sx; $k = $prev[$k]) array_unshift($path, [$k % $w, intdiv($k, $w)]);
    return $path;
}

/** Every tile a walker can reach from (sx,sy): [y * w + x => steps]. Used for the lit "you can walk here" tiles and for the tests. */
function tm_reach(array $map, int $sx, int $sy, ?callable $gate = null): array
{
    $w = $map['w'];
    $dist = [$sy * $w + $sx => 0];
    $queue = [$sy * $w + $sx];
    for ($qi = 0; $qi < count($queue); $qi++) {
        $cur = $queue[$qi];
        $cx = $cur % $w;
        $cy = intdiv($cur, $w);
        foreach ([[1, 0], [-1, 0], [0, 1], [0, -1]] as [$dx, $dy]) {
            $nx = $cx + $dx;
            $ny = $cy + $dy;
            $k = $ny * $w + $nx;
            if ($nx < 0 || $ny < 0 || $nx >= $w || $ny >= $map['h'] || isset($dist[$k]) || !tm_walkable($map, $nx, $ny, $gate)) continue;
            $dist[$k] = $dist[$cur] + 1;
            $queue[] = $k;
        }
    }
    return $dist;
}

// ------------------------------------------------------------------ fog of war

/** An empty fog: a hex string of one bit per tile (nothing seen). */
function tm_seen_new(int $w, int $h): string
{
    return str_repeat('0', intdiv($w * $h + 3, 4));
}

function tm_seen_get(string $seen, int $w, int $h, int $x, int $y): bool
{
    if ($x < 0 || $y < 0 || $x >= $w || $y >= $h) return false;
    $i = $y * $w + $x;
    $c = $seen[$i >> 2] ?? '0';
    return ((int)hexdec($c) & (1 << ($i & 3))) !== 0;
}

/** Light up every tile within $r of (x,y) (a square, so a corridor corner is seen too). */
function tm_reveal(string &$seen, int $w, int $h, int $x, int $y, int $r = 2): void
{
    $need = intdiv($w * $h + 3, 4);
    if (strlen($seen) < $need) $seen = str_pad($seen, $need, '0');
    for ($yy = max(0, $y - $r); $yy <= min($h - 1, $y + $r); $yy++) {
        for ($xx = max(0, $x - $r); $xx <= min($w - 1, $x + $r); $xx++) {
            $i = $yy * $w + $xx;
            $seen[$i >> 2] = dechex(((int)hexdec($seen[$i >> 2])) | (1 << ($i & 3)));
        }
    }
}

/** The viewport: a $cols x $rows window centred on (x,y). It is NOT clamped to the map: past the edge you see solid rock, so you are always in the middle. */
function tm_window(int $x, int $y, int $cols, int $rows): array
{
    return ['x0' => $x - intdiv($cols, 2), 'y0' => $y - intdiv($rows, 2), 'cols' => $cols, 'rows' => $rows];
}

// ------------------------------------------------------------------ the generator

/** A small seeded random number source (xorshift32 on a crc of the seed), so a map is the same every time for the same seed. */
function tm_rng(string $seed): callable
{
    $s = crc32($seed) ?: 0x9e3779b9;
    return function (int $lo, int $hi) use (&$s): int {
        $s ^= ($s << 13) & 0xffffffff;
        $s ^= $s >> 17;
        $s ^= ($s << 5) & 0xffffffff;
        $s &= 0xffffffff;
        return $hi <= $lo ? $lo : $lo + $s % ($hi - $lo + 1);
    };
}

/**
 * Check a map for play: an entry, every wanted spot once, all floor joined when the spot tiles are treated as closed, and every spot touching
 * that floor. That is what makes the spots reachable in ANY order (a spot never sits in the only doorway). Returns a list of problems ([] = fine).
 */
function tm_validate(array $map, array $codes): array
{
    $bad = [];
    if (!$map['entry']) return ['no entry'];
    foreach ($codes as $c) if (!isset($map['spots'][(string)$c])) $bad[] = 'missing spot ' . $c;
    if (count($map['spots']) !== count($codes)) $bad[] = 'wrong number of spots';
    if ($bad) return $bad;
    $closed = fn(int $x, int $y, string $t) => !ctype_digit($t);
    $reach = tm_reach($map, $map['entry'][0], $map['entry'][1], $closed);
    $floors = 0;
    for ($y = 0; $y < $map['h']; $y++) {
        for ($x = 0; $x < $map['w']; $x++) {
            $c = $map['t'][$y][$x];
            if ($c !== '#' && $c !== ' ' && !ctype_digit($c)) {
                $floors++;
                if (!isset($reach[$y * $map['w'] + $x])) $bad[] = 'floor cut off at ' . $x . ',' . $y;
            }
        }
    }
    foreach ($map['spots'] as $code => [$sx, $sy]) {
        $ok = false;
        foreach ([[1, 0], [-1, 0], [0, 1], [0, -1]] as [$dx, $dy]) {
            $nx = $sx + $dx;
            $ny = $sy + $dy;
            if ($nx >= 0 && $ny >= 0 && $nx < $map['w'] && $ny < $map['h'] && isset($reach[$ny * $map['w'] + $nx])) $ok = true;
        }
        if (!$ok) $bad[] = 'spot ' . $code . ' not reachable';
    }
    return $bad;
}

/**
 * Make a cave of rooms and corridors from a seed: $size x $size tiles, a 3 x 3 lattice of possible rooms, $codes = the spot codes to place
 * (the LAST code is put in the room farthest from the entry: the guardian / boss). $nooks = how many extra rooms with nothing in them.
 * Always connected, entry marked S, never fails (a plain fallback is used after many tries; $info['tries'] tells how many it took).
 */
function tm_gen(string $seed, int $size, array $codes, int $nooks = 1, ?array &$info = null): array
{
    $interior = $size - 2;
    $cell = intdiv($interior - 2, 3);          // room cell size: 2 for 11, 3 for 13 (with a wall between cells)
    $pitch = $cell + 1;
    $need = count($codes) + 1;                 // the entry room plus one per spot
    for ($try = 0; $try < 80; $try++) {
        $rng = tm_rng($seed . '#' . $try);
        $g = array_fill(0, $size, str_repeat('#', $size));
        $set = function (int $x, int $y, string $c) use (&$g): void { $g[$y][$x] = $c; };
        // which of the nine lattice cells hold a room
        $cells = [0, 1, 2, 3, 4, 5, 6, 7, 8];
        for ($i = 8; $i > 0; $i--) { $j = $rng(0, $i); [$cells[$i], $cells[$j]] = [$cells[$j], $cells[$i]]; }
        $k = min(9, $need + $nooks);
        $use = array_slice($cells, 0, $k);
        $rooms = [];   // [x0, y0, w, h]
        foreach ($use as $ci) {
            $cx = $ci % 3;
            $cy = intdiv($ci, 3);
            $w = $cell >= 3 ? $rng(2, $cell) : $rng(1, $cell);
            $h = $cell >= 3 ? $rng(2, $cell) : $rng(1, $cell);
            if (count($rooms) < $need) { $w = max($w, 2); $h = max($h, 2); }   // rooms that hold something are at least 2 x 2
            $x0 = 1 + $cx * $pitch + $rng(0, $cell - $w);
            $y0 = 1 + $cy * $pitch + $rng(0, $cell - $h);
            $rooms[] = [$x0, $y0, $w, $h];
            for ($yy = $y0; $yy < $y0 + $h; $yy++) for ($xx = $x0; $xx < $x0 + $w; $xx++) $set($xx, $yy, '.');
        }
        // join the rooms: a spanning tree (nearest first) plus one loop, corridors with a single bend
        $anchor = fn(array $r) => [$r[0] + $rng(0, $r[2] - 1), $r[1] + $rng(0, $r[3] - 1)];
        $link = function (array $a, array $b) use ($rng, $set, $anchor): void {
            [$ax, $ay] = $anchor($a);
            [$bx, $by] = $anchor($b);
            $horizFirst = $rng(0, 1) === 1;
            $x = $ax;
            $y = $ay;
            $stepX = function () use (&$x, $bx, $set, &$y): void { while ($x !== $bx) { $x += $bx <=> $x; $set($x, $y, '.'); } };
            $stepY = function () use (&$y, $by, $set, &$x): void { while ($y !== $by) { $y += $by <=> $y; $set($x, $y, '.'); } };
            if ($horizFirst) { $stepX(); $stepY(); } else { $stepY(); $stepX(); }
        };
        $in = [0];
        $out = range(1, count($rooms) - 1);
        while ($out) {
            $best = null;
            foreach ($in as $a) foreach ($out as $b) {
                $d = abs($rooms[$a][0] - $rooms[$b][0]) + abs($rooms[$a][1] - $rooms[$b][1]);
                if ($best === null || $d < $best[0]) $best = [$d, $a, $b];
            }
            $link($rooms[$best[1]], $rooms[$best[2]]);
            $in[] = $best[2];
            $out = array_values(array_diff($out, [$best[2]]));
        }
        if (count($rooms) > 3) $link($rooms[$rng(0, count($rooms) - 1)], $rooms[$rng(0, count($rooms) - 1)]);
        // the entry is in room 0; distances (steps) from it say which room is farthest
        $map0 = tm_parse($g);
        [$ex, $ey] = [$rooms[0][0], $rooms[0][1]];
        $dist = tm_reach($map0, $ex, $ey);
        $rank = [];
        foreach ($rooms as $ri => $r) if ($ri > 0 && $ri < $need) $rank[$ri] = $dist[$r[1] * $size + $r[0]] ?? 0;
        arsort($rank);
        $order = array_keys($rank);   // farthest first
        // spots: the last code in the farthest room, the others in the remaining spot rooms in random order
        $spotRooms = $order;
        $last = array_shift($spotRooms);
        for ($i = count($spotRooms) - 1; $i > 0; $i--) { $j = $rng(0, $i); [$spotRooms[$i], $spotRooms[$j]] = [$spotRooms[$j], $spotRooms[$i]]; }
        $assign = [];
        $codesCopy = array_values($codes);
        $guard = array_pop($codesCopy);
        $assign[$guard] = $last;
        foreach ($codesCopy as $ci => $code) $assign[$code] = $spotRooms[$ci] ?? $last;
        $g2 = $g;
        $set2 = function (int $x, int $y, string $c) use (&$g2): void { $g2[$y][$x] = $c; };
        $set2($ex, $ey, 'S');
        $placed = [];
        foreach ($assign as $code => $ri) {
            $r = $rooms[$ri];
            $opts = [];
            for ($yy = $r[1]; $yy < $r[1] + $r[3]; $yy++) for ($xx = $r[0]; $xx < $r[0] + $r[2]; $xx++) if ($g2[$yy][$xx] === '.' ) $opts[] = [$xx, $yy];
            if (!$opts) continue 2;
            $pick = $opts[$rng(0, count($opts) - 1)];
            $set2($pick[0], $pick[1], (string)$code);
        }
        $map = tm_parse($g2);
        if (!tm_validate($map, $codes)) {
            $info = ['tries' => $try + 1, 'rooms' => count($rooms)];
            return $map;
        }
    }
    // never expected: a plain ring corridor with the spots along it (still valid), so play can never break
    $g = array_fill(0, $size, str_repeat('#', $size));
    for ($i = 1; $i < $size - 1; $i++) { foreach ([[$i, 1], [$i, $size - 2], [1, $i], [$size - 2, $i]] as [$x, $y]) $g[$y][$x] = '.'; }
    for ($i = 1; $i < $size - 1; $i++) { foreach ([[$i, 2], [$i, $size - 3]] as [$x, $y]) $g[$y][$x] = '.'; }
    $g[1][1] = 'S';
    $n = count($codes);
    foreach (array_values($codes) as $i => $code) $g[$size - 2][1 + intdiv(($size - 3) * ($i + 1), $n)] = (string)$code;
    $info = ['tries' => 81, 'rooms' => 0, 'fallback' => true];
    return tm_parse($g);
}

// ------------------------------------------------------------------ looks (cave style)

/** Colours for a landscape's cave. Anything unknown gets the plain cave. */
function tm_palette(string $land): array
{
    $base = ['floor' => '#4a3a2a', 'bed' => '#6b5640', 'rock' => '#2a2622', 'rock2' => '#4a4640', 'rock3' => '#615b52', 'dot' => '#8a7a60', 'glow' => '#f5cf6a', 'moss' => '#4f7a3c', 'ink' => '#14110e', 'cream' => '#f4f0e0', 'gold' => '#e8a317', 'ember' => '#d6322b'];
    $lands = [
        'forest'     => ['floor' => '#4d3f28', 'bed' => '#6f5c3a', 'rock' => '#243322', 'rock2' => '#3d5237', 'rock3' => '#587a4c', 'moss' => '#5f9a45'],
        'grassland'  => ['floor' => '#565230', 'bed' => '#7a7442', 'rock' => '#3a3f2a', 'rock2' => '#566340', 'rock3' => '#7a8a56', 'moss' => '#86a844'],
        'coast'      => ['floor' => '#5e6058', 'bed' => '#8a8d7c', 'rock' => '#23404c', 'rock2' => '#3d6677', 'rock3' => '#6a9bb0', 'moss' => '#3f8f87'],
        'mountain'   => ['floor' => '#4b4c54', 'bed' => '#6e6f7a', 'rock' => '#25272e', 'rock2' => '#40434f', 'rock3' => '#666a7a', 'moss' => '#5a7a5a'],
        'desert'     => ['floor' => '#80623a', 'bed' => '#a98650', 'rock' => '#4e3220', 'rock2' => '#7a5230', 'rock3' => '#a87a48', 'moss' => '#7a8a3a'],
        'rainforest' => ['floor' => '#3d4a2f', 'bed' => '#586e41', 'rock' => '#1f3a2e', 'rock2' => '#2f5a47', 'rock3' => '#4a8a6a', 'moss' => '#7a5cc0'],
        'wetland'    => ['floor' => '#3f4c47', 'bed' => '#587068', 'rock' => '#22352f', 'rock2' => '#385248', 'rock3' => '#578073', 'moss' => '#6a9a58'],
        'tundra'     => ['floor' => '#6a7a8c', 'bed' => '#92a4b8', 'rock' => '#34445a', 'rock2' => '#586f8c', 'rock3' => '#8ca6c2', 'moss' => '#9ac0b0'],
        'island'     => ['floor' => '#76684a', 'bed' => '#9c8a62', 'rock' => '#1f4850', 'rock2' => '#34707a', 'rock3' => '#58a6a8', 'moss' => '#5aa86a'],
    ];
    return ($lands[$land] ?? []) + $base;
}

function tm_n(float $v): string
{
    return rtrim(rtrim(number_format($v, 1, '.', ''), '0'), '.');
}

function tm_h(int $x, int $y, int $k = 0): int
{
    return (($x * 73856093) ^ ($y * 19349663) ^ ($k * 83492791)) & 0xffff;
}

/** A clockwise rounded rectangle as path data (pieces share the winding, so overlapping pieces merge into one shape). */
function tm_rr(float $x, float $y, float $w, float $h, float $r): string
{
    $r = min($r, $w / 2, $h / 2);
    if ($r <= 0.01) return 'M' . tm_n($x) . ' ' . tm_n($y) . 'h' . tm_n($w) . 'v' . tm_n($h) . 'h' . tm_n(-$w) . 'z';
    $a = 'A' . tm_n($r) . ' ' . tm_n($r) . ' 0 0 1 ';
    return 'M' . tm_n($x + $r) . ' ' . tm_n($y) . 'H' . tm_n($x + $w - $r) . $a . tm_n($x + $w) . ' ' . tm_n($y + $r) . 'V' . tm_n($y + $h - $r)
        . $a . tm_n($x + $w - $r) . ' ' . tm_n($y + $h) . 'H' . tm_n($x + $r) . $a . tm_n($x) . ' ' . tm_n($y + $h - $r) . 'V' . tm_n($y + $r) . $a . tm_n($x + $r) . ' ' . tm_n($y) . 'z';
}

/** A block inset by $in, bridged to its right / lower neighbours: the smooth join of the walls. */
function tm_joined(float $X, float $Y, float $in, bool $right, bool $down, bool $diag, float $r = -1, float $C = TM_UNIT): string
{
    $w = $C - 2 * $in;
    $d = tm_rr($X + $in, $Y + $in, $w, $w, $r < 0 ? $w / 2 : $r);
    if ($right) $d .= tm_rr($X + $C / 2, $Y + $in, $C, $w, 0);
    if ($down) $d .= tm_rr($X + $in, $Y + $C / 2, $w, $C, 0);
    if ($right && $down && $diag) $d .= tm_rr($X + $C / 2, $Y + $C / 2, $C, $C, 0);
    return $d;
}

function tm_dot(float $cx, float $cy, float $r): string
{
    return 'M' . tm_n($cx - $r) . ' ' . tm_n($cy) . 'a' . tm_n($r) . ' ' . tm_n($r) . ' 0 1 0 ' . tm_n(2 * $r) . ' 0a' . tm_n($r) . ' ' . tm_n($r) . ' 0 1 0 ' . tm_n(-2 * $r) . ' 0z';
}

/**
 * The picture of a window of the map: ONE svg. $theme = a landscape name (or 'cave'). $state:
 *   px, py   the walker (the lantern is centred on it)      seen   the fog bitset
 *   x0, y0, cols, rows   the window (see tm_window)          light  radius in tiles that is lit now (the rest of what was seen is dimmer)
 *   tokens   [[x, y, icon, ring ('gold'|'ember'), done, locked]]    walk   ['p' => [[x,y], ...]] the path just walked, or null
 *   me       inner svg of the walker's picture ('' = a plain gnome emoji)
 * Never draws a tile that has not been seen.
 */
function tm_render_svg(array $map, string $theme, array $state): string
{
    $C = TM_UNIT;
    $P = tm_palette($theme);
    $w = $map['w'];
    $h = $map['h'];
    $seen = (string)($state['seen'] ?? '');
    $x0 = (int)$state['x0'];
    $y0 = (int)$state['y0'];
    $cols = (int)$state['cols'];
    $rows = (int)$state['rows'];
    $px = (int)$state['px'];
    $py = (int)$state['py'];
    $light = (int)($state['light'] ?? 3);
    $vis = fn(int $x, int $y): bool => tm_tile($map, $x, $y) !== ' ' && tm_seen_get($seen, $w, $h, $x, $y);
    $isWall = fn(int $x, int $y): bool => $vis($x, $y) && tm_tile($map, $x, $y) === '#';
    $L = [];
    $add = function (string $layer, string $d) use (&$L): void { $L[$layer] = ($L[$layer] ?? '') . $d; };
    for ($y = $y0; $y < $y0 + $rows; $y++) {
        for ($x = $x0; $x < $x0 + $cols; $x++) {
            if (!$vis($x, $y)) continue;
            $X = ($x - $x0) * $C;
            $Y = ($y - $y0) * $C;
            $sq = tm_rr($X, $Y, $C, $C, 0);
            $hh = tm_h($x, $y);
            $t = tm_tile($map, $x, $y);
            if ($t === '#') {
                $r = $isWall($x + 1, $y);
                $d = $isWall($x, $y + 1);
                $dg = $isWall($x + 1, $y + 1);
                $deep = $r && $d && $dg && $isWall($x - 1, $y) && $isWall($x, $y - 1) && $isWall($x - 1, $y - 1) && $isWall($x + 1, $y - 1) && $isWall($x - 1, $y + 1);
                $add('rock', $sq);
                if ($deep) {
                    $add('rock2', $sq);
                } else {
                    $add('rock2', tm_joined($X, $Y, 4, $r, $d, $dg));
                    $add('rock3', tm_joined($X, $Y, 10, $r, $d, $dg));
                }
                $add($deep ? 'speck_lit' : 'speck', tm_dot($X + 8 + $hh % 24, $Y + 8 + ($hh >> 4) % 24, $deep ? 2 : 1.7));
                if ($hh % 3 === 0) $add('moss', tm_dot($X + 9 + ($hh >> 2) % 22, $Y + 9 + ($hh >> 6) % 22, 2.4));
                if (($hh >> 5) % 4 === 0) $add('crack', 'M' . ($X + 10 + $hh % 12) . ' ' . ($Y + 9 + ($hh >> 3) % 10) . 'l5 6l-3 5');
                continue;
            }
            // floor, entry and spot tiles: dark ground with a lighter rounded bed on it
            $add('floor', $sq);
            $add('bed', tm_rr($X + 2, $Y + 2, $C - 4, $C - 4, 8));
            if ($hh % 3 === 0) $add('arc', 'M' . ($X + 10 + $hh % 8) . ' ' . ($Y + 28) . 'q6-5 12 0');
            if ($t === ',' || $hh % 5 === 0) $add('peb', 'M' . ($X + 8 + $hh % 20) . ' ' . ($Y + 12 + ($hh >> 4) % 18) . 'a3 2 0 1 0 6 0a3 2 0 1 0-6 0M' . ($X + 24 + $hh % 12) . ' ' . ($Y + 30 - ($hh >> 5) % 8) . 'a2.6 1.8 0 1 0 5.2 0a2.6 1.8 0 1 0-5.2 0');
            if ($t === 'S') $add('stair', 'M' . ($X + 12) . ' ' . ($Y + 8) . 'h18M' . ($X + 12) . ' ' . ($Y + 16) . 'h18M' . ($X + 12) . ' ' . ($Y + 24) . 'h18M' . ($X + 12) . ' ' . ($Y + 32) . 'h18');
            if (max(abs($x - $px), abs($y - $py)) > $light) $add('dim', $sq);
        }
    }
    $lx = ($px - $x0) * $C + $C / 2;
    $ly = ($py - $y0) * $C + $C / 2;
    $W = $cols * $C;
    $H = $rows * $C;
    $o = '<svg class="tmbg" viewBox="0 0 ' . $W . ' ' . $H . '" preserveAspectRatio="none" aria-hidden="true" focusable="false">';
    $o .= '<defs><radialGradient id="tmlan" cx="' . tm_n($lx) . '" cy="' . tm_n($ly) . '" r="' . (($light + 1) * $C + 40) . '" gradientUnits="userSpaceOnUse">'
        . '<stop offset="0" stop-color="' . $P['glow'] . '" stop-opacity=".30"/><stop offset=".35" stop-color="' . $P['glow'] . '" stop-opacity=".08"/><stop offset=".7" stop-color="#000" stop-opacity="0"/><stop offset="1" stop-color="#000" stop-opacity=".45"/></radialGradient></defs>';
    $o .= '<rect width="' . $W . '" height="' . $H . '" fill="#05040a"/>';
    $fills = ['rock' => $P['rock'], 'floor' => $P['floor'], 'bed' => $P['bed'], 'rock2' => $P['rock2'], 'rock3' => $P['rock3']];
    foreach ($fills as $layer => $col) if (isset($L[$layer])) $o .= '<path fill="' . $col . '" d="' . $L[$layer] . '"/>';
    $dots = ['speck_lit' => [$P['rock3'], '.8'], 'speck' => [$P['ink'], '.5'], 'moss' => [$P['moss'], '.9'], 'peb' => [$P['dot'], '.45']];
    foreach ($dots as $layer => [$col, $op]) if (isset($L[$layer])) $o .= '<path fill="' . $col . '" opacity="' . $op . '" d="' . $L[$layer] . '"/>';
    $strokes = ['crack' => [$P['ink'], '1.3', '.6'], 'arc' => [$P['rock3'], '1.5', '.35'], 'stair' => [$P['cream'], '2.4', '.8']];
    foreach ($strokes as $layer => [$col, $sw, $op]) if (isset($L[$layer])) $o .= '<path fill="none" stroke="' . $col . '" stroke-width="' . $sw . '" stroke-linecap="round" opacity="' . $op . '" d="' . $L[$layer] . '"/>';
    if (isset($L['dim'])) $o .= '<path fill="#000" opacity=".4" d="' . $L['dim'] . '"/>';
    $o .= '<rect width="' . $W . '" height="' . $H . '" fill="url(#tmlan)"/>';
    // footprints of the walk just taken (the script reveals them as the token passes; plain without script)
    $walk = $state['walk'] ?? null;
    if ($walk && count($walk['p']) > 1) {
        $p = $walk['p'];
        $n = count($p);
        $o .= '<g class="tmfeet">';
        for ($i = 0; $i < $n - 1; $i++) {
            [$fx, $fy] = $p[$i];
            if ($fx < $x0 || $fx >= $x0 + $cols || $fy < $y0 || $fy >= $y0 + $rows) continue;
            $o .= '<circle class="tmft" data-i="' . $i . '" cx="' . (($fx - $x0) * $C + $C / 2) . '" cy="' . (($fy - $y0) * $C + $C / 2) . '" r="4" fill="' . $P['glow'] . '" opacity=".75"/>';
        }
        $o .= '</g>';
    }
    // spot tokens
    foreach ($state['tokens'] ?? [] as $tk) {
        [$tx, $ty, $icon, $ring, $done] = $tk;
        $locked = !empty($tk[5]);
        if ($tx < $x0 || $tx >= $x0 + $cols || $ty < $y0 || $ty >= $y0 + $rows) continue;
        $cx = ($tx - $x0) * $C + $C / 2;
        $cy = ($ty - $y0) * $C + $C / 2;
        $o .= '<g class="tmtok' . ($done ? ' done' : '') . ($locked ? ' locked' : '') . '"' . ($done ? ' opacity=".55"' : '') . '><circle cx="' . $cx . '" cy="' . $cy . '" r="16" fill="' . ($locked ? '#9a8f80' : $P['cream']) . '" stroke="' . ($ring === 'ember' ? $P['ember'] : $P['gold']) . '" stroke-width="2.5"/>'
            . '<text x="' . $cx . '" y="' . tm_n($cy + 6) . '" font-size="17" text-anchor="middle">' . htmlspecialchars($icon, ENT_QUOTES, 'UTF-8') . '</text></g>';
    }
    // the walker
    $o .= '<g class="tmme" transform="translate(' . tm_n($lx) . ' ' . tm_n($ly) . ')"><ellipse cy="14" rx="12" ry="4" fill="#000" opacity=".3"/><circle r="17" fill="' . $P['cream'] . '" stroke="' . $P['gold'] . '" stroke-width="3"/>'
        . (($state['me'] ?? '') !== '' ? $state['me'] : '<text y="7" font-size="20" text-anchor="middle">🧙</text>') . '</g>';
    return $o . '</svg>';
}
