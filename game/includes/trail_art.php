<?php
declare(strict_types=1);
/**
 * Authored Trail maps and their picture (Hearth Pop v3 tiles). Pure helpers, no database.
 *
 * includes/data/trail_maps.json is made by tools/bake_trail_art.py: per route (by routes.id) its land and one entry per section with the
 * ASCII rows (# wall, . floor, , rough floor, S entry, 9 exit, F find, E a FIXED miniboss/boss spot on the last section of a delve/lair route),
 * the caption, and the list of raised things [tile x, tile y, sprite key, jitter px]. A route with an entry uses it instead of the random
 * generator; any section without an entry or without its baked ground picture falls back to the old drawn look.
 * Fights are NOT markers any more: they are rolled while walking (trail_encounter_index), only the E spot is fixed.
 *
 * The picture: one baked ground PNG per section (64 px a tile, 40 px of margin on top, shadows in it), then raised things, finds and the walker
 * as <image>s sorted by their feet row, so the gnome walks behind a tree to the south and in front of one to the north.
 */

const TRAIL_ART_PX = 64;      // pixels a tile has in the PNGs
const TRAIL_ART_PAD = 40;     // px of margin above row 0 in a ground PNG (tree tops reach into it)

/** All authored routes: [route id string => [land, boss, sections[]]]. */
function trail_authored_all(): array
{
    static $all = null;
    if ($all === null) {
        $f = __DIR__ . '/data/trail_maps.json';
        $j = is_file($f) ? json_decode((string)file_get_contents($f), true) : null;
        $all = is_array($j) && is_array($j['routes'] ?? null) ? $j['routes'] : [];
    }
    return $all;
}

/** One authored section (0-based) with 'land', 'route', 'sec' and 'boss' ('' / 'miniboss' / 'boss', only on the last section), or null. */
function trail_authored_section(int $routeId, int $sec): ?array
{
    $r = trail_authored_all()[(string)$routeId] ?? null;
    $s = is_array($r) ? ($r['sections'][$sec] ?? null) : null;
    if (!is_array($s) || empty($s['rows'])) return null;
    $s['land'] = (string)$r['land'];
    $s['route'] = $routeId;
    $s['sec'] = $sec;
    $s['boss'] = ($sec === count($r['sections']) - 1) ? (string)($r['boss'] ?? '') : '';
    return $s;
}

/**
 * The map of an authored section and its tokens, in the shape trail_map_make() returns: [map, [[x, y, 'E'|'F']]].
 * E and F in the rows are floor with a token on it; an E is kept only when the section has a fixed boss/miniboss.
 */
function trail_map_authored(array $art): array
{
    $rows = [];
    $tokens = [];
    foreach ($art['rows'] as $y => $row) {
        $row = (string)$row;
        for ($x = 0, $n = strlen($row); $x < $n; $x++) {
            $c = $row[$x];
            if ($c === 'F' || ($c === 'E' && $art['boss'] !== '')) $tokens[] = [$x, $y, $c];
            if ($c === 'E' || $c === 'F') $row[$x] = '.';
        }
        $rows[] = $row;
    }
    $map = tm_parse($rows);
    $map['art'] = $art;
    return [$map, $tokens];
}

/**
 * Which tile of a walked path (start left out) a random fight stops the walk on, if any. One roll per tile entered, never in the first
 * 3 tiles of the section or within 2 tiles of the exit. Chance: 2% on floor, 8% on rough floor, +1% for every quiet tile since the last
 * fight (the pity counter), and at most 2 random fights a section. $roll(int $percent): bool is the dice (tests pass their own).
 * Returns [index or null, quiet, fights].
 */
function trail_encounter_index(array $map, array $path, int $quiet, int $fights, ?callable $roll = null): array
{
    $roll ??= fn(int $pct): bool => random_int(1, 100) <= $pct;
    $en = $map['entry'] ?? [0, 0];
    $ex = $map['spots']['9'] ?? [-99, -99];
    foreach ($path as $i => [$x, $y]) {
        if ($fights >= 2) break;
        if (abs($x - $en[0]) + abs($y - $en[1]) < 3 || abs($x - $ex[0]) + abs($y - $ex[1]) < 3) continue;
        $pct = (tm_tile($map, $x, $y) === ',' ? 8 : 2) + $quiet;
        if ($roll($pct)) return [$i, 0, $fights + 1];
        $quiet++;
    }
    return [null, $quiet, $fights];
}

function trail_art_url(string $rel): string
{
    $p = 'assets/img/trail/' . $rel;
    return function_exists('url') ? url($p) : $p . '?v=' . (defined('APP_VERSION') ? APP_VERSION : '0');
}

/** Is the baked ground picture of this section on disk? (If not, the section is drawn the old way.) */
function trail_art_ready(array $art): bool
{
    return is_file(dirname(__DIR__) . '/assets/img/trail/ground/' . (int)$art['route'] . '-' . ((int)$art['sec'] + 1) . '.png');
}

/**
 * The section picture for the window. $state: x0 y0 cols rows (window, in tiles), px py (the walker), tokens [[x, y, icon, ring, done]]
 * (icon ✨ = a find, ⚔️ = the fixed fight, 🚪 = the way on), walk (the path just walked, for the footprints the script reveals).
 * Coordinates are the window's own (0,0 = its top-left tile), like tm_render_svg, so assets/tilemap.js moves the walker unchanged.
 */
function trail_art_svg(array $map, array $state): string
{
    $art = $map['art'];
    $land = (string)$art['land'];
    $C = TM_UNIT;
    $k = $C / TRAIL_ART_PX;
    $x0 = (int)$state['x0'];
    $y0 = (int)$state['y0'];
    $W = (int)$state['cols'] * $C;
    $H = (int)$state['rows'] * $C;
    $n = 'tm_n';
    $under = ['grassland' => '#2a5a3e', 'forest' => '#4a2f2d', 'coast' => '#b78a5c', 'tundra' => '#8fb0d8'][$land] ?? '#2a3a2e';
    $o = '<svg class="tmbg tpix" viewBox="0 0 ' . $W . ' ' . $H . '" preserveAspectRatio="none" aria-hidden="true" focusable="false">';
    $o .= '<rect width="' . $W . '" height="' . $H . '" fill="' . $under . '"/>';
    $o .= '<image href="' . e(trail_art_url('ground/' . (int)$art['route'] . '-' . ((int)$art['sec'] + 1) . '.png')) . '" x="' . $n(-$x0 * $C) . '" y="' . $n(-$y0 * $C - TRAIL_ART_PAD * $k)
        . '" width="' . $n($map['w'] * $C) . '" height="' . $n(($map['h'] * TRAIL_ART_PX + TRAIL_ART_PAD) * $k) . '"/>';
    $walk = $state['walk'] ?? null;
    if ($walk && count($walk['p']) > 1) {
        $o .= '<g class="tmfeet">';
        foreach (array_slice($walk['p'], 0, -1) as $i => [$fx, $fy]) {
            if ($fx < $x0 || $fx >= $x0 + $state['cols'] || $fy < $y0 || $fy >= $y0 + $state['rows']) continue;
            $o .= '<circle class="tmft" data-i="' . $i . '" cx="' . (($fx - $x0) * $C + $C / 2) . '" cy="' . (($fy - $y0) * $C + $C / 2) . '" r="3.5" fill="#fff4d6" stroke="#2b1c26" stroke-width="1" opacity=".8"/>';
        }
        $o .= '</g>';
    }
    $items = [];   // [feet row, column, markup]
    $in = fn(float $x, float $y, float $w, float $h): bool => $x + $w > 0 && $y + $h > 0 && $x < $W && $y < $H;
    foreach ($art['objs'] as [$ox, $oy, $key, $jit]) {
        $X = ($ox - $x0) * $C + $jit * $k;
        $Y = (($oy - $y0) * TRAIL_ART_PX - 29) * $k;
        if (!$in($X, $Y, 64 * $k, 96 * $k)) continue;
        $items[] = [$oy + .5, $ox, '<image href="' . e(trail_art_url('obj/' . $key . '.png')) . '" x="' . $n($X) . '" y="' . $n($Y) . '" width="' . $n(64 * $k) . '" height="' . $n(96 * $k) . '"/>'];
    }
    $marks = '';
    foreach ($state['tokens'] ?? [] as $tk) {
        [$tx, $ty, $icon, , $done] = $tk;
        $X = ($tx - $x0) * $C;
        $Y = ($ty - $y0) * $C;
        if (!$in($X, $Y, $C, $C)) continue;
        if ($icon === '✨') {
            $items[] = [$ty + .45, $tx, '<image href="' . e(trail_art_url('find-' . $land . ($done ? '-done' : '') . '.png')) . '" x="' . $n($X) . '" y="' . $n($Y) . '" width="' . $C . '" height="' . $C . '"/>'];
        } else {   // the way on and the fixed fight: red-outlined placeholder tiles until their art is drawn
            $marks .= '<g' . ($done ? ' opacity=".5"' : '') . '><rect x="' . ($X + 2) . '" y="' . ($Y + 2) . '" width="' . ($C - 4) . '" height="' . ($C - 4) . '" fill="rgba(255,255,255,.18)" stroke="#e02020" stroke-width="2.5"/>'
                . '<text x="' . ($X + $C / 2) . '" y="' . $n($Y + $C / 2 + 6) . '" font-size="17" text-anchor="middle">' . e($icon) . '</text></g>';
        }
    }
    $lx = ($state['px'] - $x0) * $C + $C / 2;
    $ly = ($state['py'] - $y0) * $C + $C / 2;
    $items[] = [$state['py'] + .5, $state['px'], '<g class="tmme" transform="translate(' . $n($lx) . ' ' . $n($ly) . ')"><image href="' . e(trail_art_url('gnome.png')) . '" x="' . $n(-32 * $k) . '" y="' . $n(-56 * $k)
        . '" width="' . $n(64 * $k) . '" height="' . $n(80 * $k) . '"/></g>'];
    usort($items, fn($a, $b) => [$a[0], $a[1]] <=> [$b[0], $b[1]]);
    $o .= $marks;   // flat marks lie on the ground, under the walker and the raised things
    foreach ($items as $it) $o .= $it[2];
    return $o . '</svg>';
}
