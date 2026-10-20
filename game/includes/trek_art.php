<?php
declare(strict_types=1);
// v1.8.10: the Treks map art. ONE inline SVG for the visible window (colours only from assets/img/ph/palette.json).
// Open zones: "Hedge Knit, Black Rows" (grey hedge bands that join their neighbours, inset beds). Underground zones: "Root Knot".
// Every layer is a single <path> per colour (rounded blocks and bars of the same winding, so they merge into one smooth shape).
// The tile buttons sit on top of it as a transparent grid (see trek_map_html in trek.php).

const TK_C = 42;                          // one tile = 42 SVG units
// v1.9.1: which zones are underground (style u) and which have pools in their mud (flag pool) is data: the zone rows of trek_chapters*.txt
const TK_P = [
    'soil900' => '#3d2a1c', 'soil700' => '#7a4a1f', 'soil500' => '#9a6b3f', 'soil300' => '#c9a96e',
    'moss600' => '#4f9a45', 'moss800' => '#2f5a2a', 'gold700' => '#b07a10', 'gold500' => '#e8a317', 'gold300' => '#f5cf6a',
    'ember700' => '#a8241f', 'ember500' => '#d6322b', 'ember400' => '#e0501f', 'ember300' => '#f08a24',
    'water700' => '#25637d', 'water500' => '#3f8fb0', 'water300' => '#a9d6ea', 'dusk700' => '#4e3a8a', 'dusk500' => '#7a5cc0',
    'stone700' => '#5b6470', 'stone500' => '#8b8f96', 'ink' => '#2b2b2b', 'cream' => '#f4f0e0',
];

/** Deterministic little number from a tile (so the details do not jump when the window moves). */
function tk_h(int $x, int $y, int $k = 0): int
{
    return (($x * 73856093) ^ ($y * 19349663) ^ ($k * 83492791)) & 0xffff;
}

function tk_n(float $v): string
{
    return rtrim(rtrim(number_format($v, 1, '.', ''), '0'), '.');
}

/** A clockwise rounded rectangle as path data (all pieces share the winding, so overlapping pieces merge). */
function tk_rr(float $x, float $y, float $w, float $h, float $r): string
{
    $r = min($r, $w / 2, $h / 2);
    if ($r <= 0.01) return 'M' . tk_n($x) . ' ' . tk_n($y) . 'h' . tk_n($w) . 'v' . tk_n($h) . 'h' . tk_n(-$w) . 'z';
    $a = 'A' . tk_n($r) . ' ' . tk_n($r) . ' 0 0 1 ';
    return 'M' . tk_n($x + $r) . ' ' . tk_n($y) . 'H' . tk_n($x + $w - $r) . $a . tk_n($x + $w) . ' ' . tk_n($y + $r) . 'V' . tk_n($y + $h - $r)
        . $a . tk_n($x + $w - $r) . ' ' . tk_n($y + $h) . 'H' . tk_n($x + $r) . $a . tk_n($x) . ' ' . tk_n($y + $h - $r) . 'V' . tk_n($y + $r) . $a . tk_n($x + $r) . ' ' . tk_n($y) . 'z';
}

/** A rounded block inset by $in, bridged to the right/down neighbours (and the inner corner when the 2x2 is all joined): the smooth auto-tile join. */
function tk_joined(float $X, float $Y, float $in, bool $right, bool $down, bool $diag, float $r = -1): string
{
    $C = TK_C;
    $w = $C - 2 * $in;
    $d = tk_rr($X + $in, $Y + $in, $w, $w, $r < 0 ? $w / 2 : $r);
    if ($right) $d .= tk_rr($X + $C / 2, $Y + $in, $C, $w, 0);
    if ($down) $d .= tk_rr($X + $in, $Y + $C / 2, $w, $C, 0);
    if ($right && $down && $diag) $d .= tk_rr($X + $C / 2, $Y + $C / 2, $C, $C, 0);
    return $d;
}

/** A small filled circle as path data. */
function tk_dot(float $cx, float $cy, float $r): string
{
    return 'M' . tk_n($cx - $r) . ' ' . tk_n($cy) . 'a' . tk_n($r) . ' ' . tk_n($r) . ' 0 1 0 ' . tk_n(2 * $r) . ' 0a' . tk_n($r) . ' ' . tk_n($r) . ' 0 1 0 ' . tk_n(-2 * $r) . ' 0z';
}

/**
 * The SVG backdrop for a window of $cols x $rows tiles from ($x0,$y0).
 * $tokens = [[x, y, icon, ring ('gold'|'ember'), done]]; $walk = ['p' => [[x,y],...], 'd' => [x,y]] or null.
 * Returns the <svg> markup. Each layer is one path; $stats (by reference) counts them.
 */
function trek_art_svg(int $ch, array $run, int $x0, int $y0, int $cols, int $rows, array $tokens, ?array $walk, string $me = '', string $sfx = ''): string
{
    $C = TK_C;
    $P = TK_P;
    $px = (int)$run['x'];
    $py = (int)$run['y'];
    // --- what is each tile? '' void (fog / off the map), W wall, C chasm, F floor, M mud, R roots, B blight, = bridge, P pool (mud in the Dew Pools)
    $kc = [];
    $zc = [];
    $zone = function (int $x, int $y) use (&$zc, $ch): string {
        $k = $x . ',' . $y;
        return $zc[$k] ??= trek_zone_at($ch, $x, $y);
    };
    $kind = function (int $x, int $y) use (&$kc, $ch, $run, $zone): string {
        $k = $x . ',' . $y;
        if (isset($kc[$k])) return $kc[$k];
        $t = trek_tile($ch, $x, $y);
        if ($t === ' ' || !trek_seen_get($run, $x, $y)) return $kc[$k] = '';
        $r = match (true) {
            $t === '#' => 'W', $t === '^' => 'C', $t === ':' => 'K', $t === '*' => 'G', $t === '+' => 'L',
            $t === 'w' => (trek_flag($run, 'drained_' . $zone($x, $y)) ? 'D' : 'H'),   // v1.9.2: high water, wet clay, glow crystal; a drained pool is wet mud
            $t === '~' => (!empty(trek_chapter($ch)['zones'][$zone($x, $y)]['pool']) ? 'P' : 'M'), $t === '%' => 'R', $t === '=' => '=', $t === ',' => 'B', default => 'F',
        };
        return $kc[$k] = $r;
    };
    // --- open (o) or underground (u): the zone of the tile; walls and unlettered tiles take the most common zone of the walkable tiles around them
    $sc = [];
    $style = function (int $x, int $y) use (&$sc, $zone, $kind, $ch): string {
        $k = $x . ',' . $y;
        if (isset($sc[$k])) return $sc[$k];
        $own = $zone($x, $y);
        $isWall = $kind($x, $y) === 'W' || $kind($x, $y) === '';
        $z = $isWall ? '' : $own;
        if ($z === '') {
            $cnt = [];
            for ($dy = -2; $dy <= 2; $dy++) {
                for ($dx = -2; $dx <= 2; $dx++) {
                    $zz = $zone($x + $dx, $y + $dy);
                    if ($zz === '' || trek_tile($ch, $x + $dx, $y + $dy) === '#') continue;
                    $cnt[$zz] = ($cnt[$zz] ?? 0) + 1;
                }
            }
            if ($cnt) { arsort($cnt); $z = (string)array_key_first($cnt); } else $z = $own;
        }
        return $sc[$k] = (($z !== '' && in_array((trek_chapter($ch)['zones'][$z]['style'] ?? 'o'), ['u', 'd'], true)) ? 'u' : 'o');   // v1.9.4: a dark zone (d) is underground too, with a heavier vignette
    };
    $isW = fn(int $x, int $y, string $s) => $kind($x, $y) === 'W' && $style($x, $y) === $s;
    $isWall = fn(int $x, int $y) => $kind($x, $y) === 'W';   // v1.9.0
    $isPool = fn(int $x, int $y) => $kind($x, $y) === 'P';
    $isHigh = fn(int $x, int $y) => $kind($x, $y) === 'H';

    $L = [];   // layer => path data
    $add = function (string $layer, string $d) use (&$L): void { $L[$layer] = ($L[$layer] ?? '') . $d; };
    $x1 = $x0 + $cols;
    $y1 = $y0 + $rows;
    for ($y = $y0; $y < $y1; $y++) {
        for ($x = $x0; $x < $x1; $x++) {
            $k = $kind($x, $y);
            if ($k === '') continue;
            $X = ($x - $x0) * $C;
            $Y = ($y - $y0) * $C;
            $s = $style($x, $y);
            $sq = tk_rr($X, $Y, $C, $C, 0);
            $h = tk_h($x, $y);
            switch ($k) {
                case 'W':
                    // v1.9.0: bands join their wall neighbours across styles too (a mossy cap covers the seam); the deep middle of an open wall is the darker stone with speckles
                    $r = $isWall($x + 1, $y);
                    $d = $isWall($x, $y + 1);
                    $dg = $isWall($x + 1, $y + 1);
                    $deep = $r && $d && $dg && $isW($x - 1, $y, $s) && $isW($x, $y - 1, $s) && $isW($x - 1, $y - 1, $s) && $isW($x + 1, $y - 1, $s) && $isW($x - 1, $y + 1, $s) && $isW($x + 1, $y, $s) && $isW($x, $y + 1, $s);
                    $add('base', $sq);
                    if ($s === 'o') {
                        if ($deep) $add('wo_deep', $sq);
                        else { $add('wo_out', tk_joined($X, $Y, 5, $r, $d, $dg)); $add('wo_in', tk_joined($X, $Y, 11, $r, $d, $dg)); }
                        $ox = $X + 8 + $h % 24;
                        $oy = $Y + 8 + ($h >> 4) % 24;
                        $add($deep ? 'wo_lit' : 'wo_spk', tk_dot($ox, $oy, $deep ? 2.2 : 1.8));
                        if ($h % 2 === 0) $add('wo_spk', tk_dot($X + 8 + ($h >> 3) % 24, $Y + 8 + ($h >> 7) % 24, 2));
                        if ($h % 3 === 0) $add('wo_moss', tk_dot($X + 9 + ($h >> 2) % 22, $Y + 9 + ($h >> 6) % 22, 2.4));
                        if (($h >> 5) % 4 === 0) $add('wo_crack', 'M' . ($X + 10 + $h % 12) . ' ' . ($Y + 9 + ($h >> 3) % 10) . 'l5 6l-3 5M' . ($X + 15 + $h % 12) . ' ' . ($Y + 15 + ($h >> 3) % 10) . 'l5 1');
                        if (($x * 7 + $y * 3) % 4 === 0) $add('thorn', tk_dot($X + 12 + $h % 19, $Y + 12 + ($h >> 5) % 19, 2));
                        if (($h >> 9) % 5 === 0) $add('wo_thorn', 'M' . ($X + 12 + $h % 16) . ' ' . ($Y + 30) . 'l-2-6M' . ($X + 12 + $h % 16) . ' ' . ($Y + 30) . 'l3-5');
                    } else {
                        if ($deep) $add('wu_in', $sq);
                        else { $add('wu_out', tk_joined($X, $Y, 6, $r, $d, $dg)); $add('wu_in', tk_joined($X, $Y, 13, $r, $d, $dg)); }
                        if ($ch >= 2 && $h % 3 !== 1) $add('slump', 'M' . ($X + 6) . ' ' . ($Y + 12 + $h % 16) . 'q8 3 15 0t15 0');   // v1.9.2: Chapter II's clay walls are banded
                        if (($x + $y) % 3 === 0) $add('hair', 'M' . ($X + 8) . ' ' . ($Y + 36) . 'q4-6 10-4M' . ($X + 30) . ' ' . ($Y + 10) . 'q5 3 4 9');
                    }
                    // the seam between a root wall and a hedge wall: a short mossy cap along the shared edge (both tiles draw their half)
                    foreach ([[0, -1, 6, 0, $C - 12, 5], [0, 1, 6, $C - 5, $C - 12, 5], [-1, 0, 0, 6, 5, $C - 12], [1, 0, $C - 5, 6, 5, $C - 12]] as [$sx, $sy, $cx0, $cy0, $cw, $ch0]) {
                        if ($kind($x + $sx, $y + $sy) === 'W' && $style($x + $sx, $y + $sy) !== $s) {
                            $add('wo_cap', tk_rr($X + $cx0, $Y + $cy0, $cw, $ch0, 2.5));
                            $add('wo_capdot', tk_dot($X + ($sx ? ($sx < 0 ? 2.5 : $C - 2.5) : 12 + $h % 18), $Y + ($sy ? ($sy < 0 ? 2.5 : $C - 2.5) : 12 + $h % 18), 1.6));
                        }
                    }
                    break;
                case 'C':
                    $add('chasm', $sq);
                    if ($h % 2 === 0) $add('chasm_rip', 'M' . ($X + 8) . ' ' . ($Y + 22) . 'q6-4 12 0');
                    break;
                case '=':
                    $add('base', $sq);
                    $vert = $kind($x - 1, $y) === 'C' || $kind($x + 1, $y) === 'C';   // chasm at the sides: the planks run across
                    for ($i = 0; $i < 4; $i++) {
                        $a = $vert ? tk_rr($X + 1, $Y + 2 + $i * 10, $C - 2, 8, 2) : tk_rr($X + 2 + $i * 10, $Y + 1, 8, $C - 2, 2);
                        $add($i % 2 ? 'plank5' : 'plank3', $a);
                    }
                    foreach ([[0, -1, 0, 0, $C, 4], [0, 1, 0, $C - 4, $C, 4], [-1, 0, 0, 0, 4, $C], [1, 0, $C - 4, 0, 4, $C]] as [$ddx, $ddy, $ox, $oy, $w, $hh]) {
                        if ($kind($x + $ddx, $y + $ddy) === 'C') $add('rail', tk_rr($X + $ox, $Y + $oy, $w, $hh, 0));
                    }
                    break;
                case 'P':
                    $add('base', $sq);
                    $add('pool7', tk_joined($X, $Y, 2, $isPool($x + 1, $y), $isPool($x, $y + 1), $isPool($x + 1, $y + 1), 14));
                    $add('pool5', tk_joined($X, $Y, 5, $isPool($x + 1, $y), $isPool($x, $y + 1), $isPool($x + 1, $y + 1), 12));
                    $add('ripple', 'M' . ($X + 10) . ' ' . ($Y + 24) . 'q6-4 12 0M' . ($X + 22) . ' ' . ($Y + 13) . 'q5-3 10 0');
                    break;
                case 'H':   // v1.9.2: high water (the ripples are its sign)
                    $add('base', $sq);
                    $add('pool7', tk_joined($X, $Y, 2, $isHigh($x + 1, $y), $isHigh($x, $y + 1), $isHigh($x + 1, $y + 1), 14));
                    $add('pool5', tk_joined($X, $Y, 5, $isHigh($x + 1, $y), $isHigh($x, $y + 1), $isHigh($x + 1, $y + 1), 12));
                    $add('ripple', 'M' . ($X + 8) . ' ' . ($Y + 17) . 'q6-4 12 0q6 4 12 0M' . ($X + 14) . ' ' . ($Y + 29) . 'q5-3 10 0q5 3 10 0');
                    break;
                case 'D':   // a drained pool: wet mud with a last sheen of water
                    $add('u_dark', $sq);
                    $add('dsheen', tk_rr($X + 4, $Y + 5, $C - 8, $C - 10, 10));
                    $add('dripple', 'M' . ($X + 10) . ' ' . ($Y + 24) . 'q6-4 12 0');
                    $add('mdot', tk_dot($X + 12, $Y + 12, 2.6) . tk_dot($X + 30, $Y + 30, 2.2));
                    break;
                case 'K':   // wet clay: slumped warm bands and a colon of two dots (the map's own ':')
                    $add('u_clay', $sq);
                    $add('clay_sheen', tk_rr($X + 3, $Y + 3, $C - 6, $C - 6, 10));
                    $add('slump', 'M' . ($X + 5) . ' ' . ($Y + 9) . 'q8 4 16 0t16 0M' . ($X + 5) . ' ' . ($Y + 33) . 'q8 4 16 0t16 0');
                    $add('cdot', tk_dot($X + 21, $Y + 15, 3.2) . tk_dot($X + 21, $Y + 27, 3.2));
                    break;
                case 'L':   // v1.9.4: loose clay tiles: cracked, crumbling, a Wayfinder can push through
                    $add('u_clay', $sq);
                    $add('wo_crack', 'M' . ($X + 8) . ' ' . ($Y + 10) . 'l8 7l-3 8l9 6M' . ($X + 30) . ' ' . ($Y + 8) . 'l-6 9l5 7');
                    $add('cdot', tk_dot($X + 12, $Y + 31, 2.4) . tk_dot($X + 31, $Y + 29, 2) . tk_dot($X + 24, $Y + 12, 1.8));
                    break;
                case 'G':   // glow crystal: a lump in the way, it lights the fog around it
                    $add($s === 'o' ? 'base' : 'u_floor', $sq);
                    if ($s === 'o') $add('bed_f', tk_rr($X + 2, $Y + 2, $C - 4, $C - 4, 8));
                    $add('halo', tk_dot($X + 21, $Y + 21, 18));
                    $add('crys', 'M' . ($X + 21) . ' ' . ($Y + 5) . 'L' . ($X + 31) . ' ' . ($Y + 21) . 'L' . ($X + 21) . ' ' . ($Y + 37) . 'L' . ($X + 11) . ' ' . ($Y + 21) . 'Z');
                    $add('crys2', 'M' . ($X + 21) . ' ' . ($Y + 12) . 'L' . ($X + 26) . ' ' . ($Y + 21) . 'L' . ($X + 21) . ' ' . ($Y + 30) . 'L' . ($X + 16) . ' ' . ($Y + 21) . 'Z');
                    $add('crysline', 'M' . ($X + 21) . ' ' . ($Y + 5) . 'L' . ($X + 21) . ' ' . ($Y + 37) . 'M' . ($X + 11) . ' ' . ($Y + 21) . 'L' . ($X + 31) . ' ' . ($Y + 21));
                    break;
                default:   // walkable ground: F floor, M mud, R roots, B blight
                    if ($s === 'o') {
                        $add('base', $sq);
                        $bed = tk_rr($X + 2, $Y + 2, $C - 4, $C - 4, 8);
                        $layer = match ($k) { 'R' => 'bed_r', 'B' => 'bed_b', 'M' => 'bed_m', default => 'bed_f' };
                        $add($layer, $bed);
                        if ($k === 'F' && $h % 3 === 0) $add('arc', 'M' . ($X + 10 + $h % 8) . ' ' . ($Y + 28) . 'q6-5 12 0');
                        if ($k === 'R') $add('tuft', 'M' . ($X + 12) . ' ' . ($Y + 30) . 'l-2-6M' . ($X + 12) . ' ' . ($Y + 30) . 'l2-7M' . ($X + 28) . ' ' . ($Y + 17) . 'l-2-5M' . ($X + 28) . ' ' . ($Y + 17) . 'l2-6');
                        if ($k === 'B') $add('bdot', tk_dot($X + 13, $Y + 15, 2.4) . tk_dot($X + 28, $Y + 27, 2.4));
                        if ($k === 'M') $add('mdot', tk_dot($X + 14, $Y + 14, 3) . tk_dot($X + 29, $Y + 25, 2.4) . tk_dot($X + 15, $Y + 31, 2));
                    } else {
                        $layer = match ($k) { 'R', 'M' => 'u_dark', 'B' => 'u_blight', default => 'u_floor' };
                        $add($layer, $sq);
                        if ($k === 'F' && $h % 2 === 0) $add('peb', 'M' . ($X + 8 + $h % 20) . ' ' . ($Y + 12 + ($h >> 4) % 18) . 'a3 2 0 1 0 6 0a3 2 0 1 0-6 0M' . ($X + 24 + $h % 12) . ' ' . ($Y + 30 - ($h >> 5) % 8) . 'a2.6 1.8 0 1 0 5.2 0a2.6 1.8 0 1 0-5.2 0');
                        if ($k === 'R') $add('utuft', 'M' . ($X + 12) . ' ' . ($Y + 30) . 'l-2-6M' . ($X + 12) . ' ' . ($Y + 30) . 'l2-7M' . ($X + 28) . ' ' . ($Y + 17) . 'l-2-5M' . ($X + 28) . ' ' . ($Y + 17) . 'l2-6');
                        if ($k === 'M') $add('mdot', tk_dot($X + 14, $Y + 14, 3) . tk_dot($X + 29, $Y + 25, 2.4));
                        if ($k === 'B') $add('bdot', tk_dot($X + 13, $Y + 15, 2.4) . tk_dot($X + 28, $Y + 27, 2.4));
                    }
            }
        }
    }

    // --- the player's tile decides the light: strong underground, a hint outdoors
    $under = $style($px, $py) === 'u';
    $dark = $under && (trek_chapter($ch)['zones'][trek_zone_at($ch, $px, $py)]['style'] ?? '') === 'd';   // v1.9.4: the Dim: a small pool of light, black beyond
    $lx = ($px - $x0) * $C + $C / 2;
    $ly = ($py - $y0) * $C + $C / 2;
    $W = $cols * $C;
    $H = $rows * $C;
    $o = '<svg class="tkbg' . ($sfx !== '' ? ' tkx' : '') . '" viewBox="0 0 ' . $W . ' ' . $H . '" preserveAspectRatio="none" aria-hidden="true" focusable="false">';
    $o .= '<defs><radialGradient id="tklan' . $sfx . '" cx="' . tk_n($lx) . '" cy="' . tk_n($ly) . '" r="' . ($dark ? 120 : ($under ? 215 : 300)) . '" gradientUnits="userSpaceOnUse">'
        . ($under
            ? '<stop offset="0" stop-color="' . $P['gold300'] . '" stop-opacity=".34"/><stop offset=".3" stop-color="' . $P['ember300'] . '" stop-opacity=".12"/><stop offset=".62" stop-color="' . $P['ember300'] . '" stop-opacity="0"/><stop offset="1" stop-color="#000" stop-opacity="' . ($dark ? '.82' : '.3') . '"/>'
            : '<stop offset="0" stop-color="' . $P['gold300'] . '" stop-opacity=".16"/><stop offset=".55" stop-color="' . $P['ember300'] . '" stop-opacity="0"/><stop offset="1" stop-color="#000" stop-opacity=".16"/>')
        . '</radialGradient></defs>';
    $o .= '<rect width="' . $W . '" height="' . $H . '" fill="#000"/><rect width="' . $W . '" height="' . $H . '" fill="' . $P['ink'] . '" opacity=".5"/>';
    $fills = [
        'base' => $P['soil900'], 'u_floor' => $P['soil500'], 'u_dark' => $P['soil700'], 'u_blight' => $P['dusk700'],
        'u_clay' => $P['soil700'], 'bed_f' => $P['soil500'], 'bed_m' => $P['soil700'], 'bed_r' => $P['stone500'], 'bed_b' => $P['dusk700'],
        'chasm' => $P['water700'], 'plank3' => $P['soil300'], 'plank5' => $P['soil500'], 'rail' => $P['soil700'],
        'pool7' => $P['water700'], 'pool5' => $P['water500'],
        'wo_out' => $P['stone700'], 'wo_in' => $P['stone500'], 'wo_deep' => $P['stone700'], 'wu_out' => $P['soil500'], 'wu_in' => $P['soil300'],
    ];
    foreach ($fills as $layer => $col) if (isset($L[$layer])) $o .= '<path fill="' . $col . '" d="' . $L[$layer] . '"/>';
    if (isset($L['chasm'])) $o .= '<path fill="#000" opacity=".45" d="' . $L['chasm'] . '"/>';
    $dots = ['wo_lit' => [$P['stone500'], '.8'], 'wo_spk' => [$P['ink'], '.5'], 'wo_moss' => [$P['moss800'], '.9'], 'wo_cap' => [$P['moss800'], '.95'], 'wo_capdot' => [$P['moss600'], ''], 'thorn' => [$P['ember400'], ''], 'bdot' => [$P['dusk500'], ''], 'mdot' => [$P['soil900'], '.5'], 'peb' => [$P['soil700'], '.55'],
        'clay_sheen' => [$P['ember400'], '.26'], 'cdot' => [$P['soil300'], '.9'], 'dsheen' => [$P['water500'], '.28'], 'halo' => [$P['gold300'], '.3'], 'crys' => [$P['gold300'], ''], 'crys2' => [$P['gold500'], '']];
    foreach ($dots as $layer => [$col, $op]) if (isset($L[$layer])) $o .= '<path fill="' . $col . '"' . ($op ? ' opacity="' . $op . '"' : '') . ' d="' . $L[$layer] . '"/>';
    $strokes = ['arc' => [$P['soil700'], '1.5', '.6'], 'chasm_rip' => [$P['water500'], '1.6', '.6'], 'ripple' => [$P['water300'], '1.8', '.8'], 'wo_crack' => [$P['ink'], '1.3', '.6'], 'wo_thorn' => [$P['ember700'], '1.5', '.8'], 'tuft' => [$P['moss600'], '1.5', ''], 'utuft' => [$P['moss600'], '1.5', ''], 'hair' => [$P['soil300'], '1.6', '.7'],
        'dripple' => [$P['water300'], '1.6', '.5'], 'slump' => [$P['ember400'], '1.6', '.38'], 'crysline' => [$P['ink'], '1.1', '.45']];
    foreach ($strokes as $layer => [$col, $sw, $op]) if (isset($L[$layer])) $o .= '<path fill="none" stroke="' . $col . '" stroke-width="' . $sw . '" stroke-linecap="round"' . ($op ? ' opacity="' . $op . '"' : '') . ' d="' . $L[$layer] . '"/>';
    $o .= '<rect width="' . $W . '" height="' . $H . '" fill="url(#tklan' . $sfx . ')"/>';

    // --- footprints of the walk just taken (shown as they are walked by assets/trekmap.js; plain without script)
    if ($walk && count($walk['p']) > 1) {
        $p = $walk['p'];
        $n = count($p);
        $o .= '<g class="tkfeet">';
        for ($i = 0; $i < $n - 1; $i++) {
            [$fx, $fy] = $p[$i];
            if ($fx < $x0 || $fx >= $x1 || $fy < $y0 || $fy >= $y1) continue;
            $dx = $p[$i + 1][0] - $fx;
            $dy = $p[$i + 1][1] - $fy;
            $cx = ($fx - $x0) * $C + $C / 2;
            $cy = ($fy - $y0) * $C + $C / 2;
            $hz = abs($dx) > abs($dy);
            $op = tk_n(max(.2, .8 - ($n - 2 - $i) * .12));
            $f = fn(float $ox, float $oy) => '<ellipse cx="' . tk_n($cx + $ox) . '" cy="' . tk_n($cy + $oy) . '" rx="' . ($hz ? '4.5' : '3') . '" ry="' . ($hz ? '3' : '4.5') . '"/>';
            $o .= '<g class="tkft" data-i="' . $i . '" fill="' . $P['gold300'] . '" opacity="' . $op . '">' . $f($hz ? -4 : -5, $hz ? -5 : -4) . $f($hz ? 4 : 5, $hz ? 5 : 4) . '</g>';
        }
        $o .= '</g>';
        [$dx2, $dy2] = $walk['d'];
        if ($dx2 >= $x0 && $dx2 < $x1 && $dy2 >= $y0 && $dy2 < $y1) {
            $o .= '<text class="tkflag" x="' . (($dx2 - $x0) * $C + $C / 2) . '" y="' . (($dy2 - $y0) * $C + $C / 2 + 7) . '" font-size="19" text-anchor="middle">🚩</text>';
        }
    }
    // --- spot tokens
    foreach ($tokens as [$tx, $ty, $icon, $ring, $done]) {
        $cx = ($tx - $x0) * $C + $C / 2;
        $cy = ($ty - $y0) * $C + $C / 2;
        $o .= '<g' . ($done ? ' opacity=".55"' : '') . '><circle cx="' . $cx . '" cy="' . $cy . '" r="15" fill="' . $P['cream'] . '" stroke="' . ($ring === 'ember' ? $P['ember500'] : $P['gold700']) . '" stroke-width="2.5"/>'
            . '<text x="' . $cx . '" y="' . tk_n($cy + 5.8) . '" font-size="16" text-anchor="middle">' . htmlspecialchars($icon, ENT_QUOTES, 'UTF-8') . '</text></g>';
    }
    // --- the player
    $o .= '<g class="tkme" transform="translate(' . tk_n($lx) . ' ' . tk_n($ly) . ')"><ellipse cy="14" rx="12" ry="4" fill="#000" opacity=".3"/><circle r="17" fill="' . $P['cream'] . '" stroke="' . $P['gold500'] . '" stroke-width="3"/>' . ($me !== '' ? $me : '<text y="7" font-size="20" text-anchor="middle">🧙</text>') . '</g>';   // v1.9.0: the player's own gnome
    return $o . '</svg>';
}

/** v1.8.10: the path walked by the last tap (one-shot, from the session), or null. Fresh for 30 s, this run only. Always cleared. */
function trek_walk_take(array $run): ?array
{
    $w = $_SESSION['trek_walk'] ?? null;
    unset($_SESSION['trek_walk']);
    if (!is_array($w) || (int)($w['run'] ?? 0) !== (int)$run['id'] || time() - (int)($w['t'] ?? 0) > 30 || !is_array($w['p'] ?? null) || count($w['p']) < 2) return null;
    $p = [];
    foreach ($w['p'] as $pt) $p[] = [(int)($pt[0] ?? 0), (int)($pt[1] ?? 0)];
    $last = end($p);
    if ($last[0] !== (int)$run['x'] || $last[1] !== (int)$run['y']) return null;   // the party has moved on since
    return ['p' => $p, 'd' => [(int)($w['d'][0] ?? $last[0]), (int)($w['d'][1] ?? $last[1])]];
}

/** v1.9.0: the player's gnome (gnome_avatar) as a small nested SVG for the map token: inner drawing only, scaled into the cream disc. */
function trek_art_me(array $u): string
{
    if (!function_exists('gnome_avatar')) return '';
    $svg = gnome_avatar($u, 24);
    if (!preg_match('~<svg[^>]*>(.*)</svg>\s*$~s', $svg, $m)) return '';
    return '<svg x="-13" y="-16" width="26" height="32" viewBox="0 0 80 100" aria-hidden="true">' . $m[1] . '</svg>';
}

