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

/**
 * Is this authored route usable? Every section needs rows: all the same width (at least 5), all the same height (at least 3), only the characters
 * # . , S 9 E F, and an exit '9' on the right edge. Anything else is dropped here, so a bad hand-made map falls back to the random generator
 * instead of breaking a walk. (The path from the entry to the exit is checked by tools/bake_trail_art.py --check and tests/trail_authored.php.)
 */
function trail_authored_valid($r): bool
{
    if (!is_array($r) || empty($r['sections']) || !is_array($r['sections'])) return false;
    $w = $h = 0;
    foreach ($r['sections'] as $s) {
        $rows = is_array($s) ? ($s['rows'] ?? null) : null;
        if (!is_array($rows) || count($rows) < 3 || (isset($rows[0]) && !is_string($rows[0]))) return false;
        $w = $w ?: strlen((string)$rows[0]);
        $h = $h ?: count($rows);
        if ($w < 5 || count($rows) !== $h) return false;
        $nine = 0;
        foreach ($rows as $row) {
            if (!is_string($row) || strlen($row) !== $w || !preg_match('/^[#.,S9EF]+$/', $row)) return false;
            if (str_ends_with($row, '9')) $nine++;
        }
        if ($nine !== 1) return false;
    }
    return true;
}

/**
 * The authored routes found under a data directory, [route id string => [land, boss, sections[]]]: data/trail_maps.json (the merged file
 * tools/bake_trail_art.py writes) and then every data/trail_maps/*.json (one file per region, same {"v":1,"routes":{id:{...}}} shape; later
 * names win). Unreadable or invalid entries are skipped. Pure; $dir is only a parameter so the tests can point it at a scratch folder.
 */
function trail_authored_load(string $dir): array
{
    $files = array_merge(is_file($dir . '/trail_maps.json') ? [$dir . '/trail_maps.json'] : [], glob($dir . '/trail_maps/*.json') ?: []);
    $all = [];
    foreach ($files as $f) {
        $j = json_decode((string)@file_get_contents($f), true);
        foreach (is_array($j) && is_array($j['routes'] ?? null) ? $j['routes'] : [] as $id => $r) if (ctype_digit((string)$id) && trail_authored_valid($r)) $all[(string)$id] = $r;
    }
    return $all;
}

/** All authored routes of the game (see trail_authored_load). */
function trail_authored_all(): array
{
    static $all = null;
    return $all ??= trail_authored_load(__DIR__ . '/data');
}

/** One authored section (0-based) with 'land', 'route', 'sec' and 'boss' ('' / 'miniboss' / 'boss', only on the last section), or null. */
function trail_authored_section(int $routeId, int $sec): ?array
{
    $r = trail_authored_all()[(string)$routeId] ?? null;
    $s = is_array($r) ? ($r['sections'][$sec] ?? null) : null;
    if (!is_array($s) || empty($s['rows'])) return null;
    $s['land'] = (string)$r['land'];
    if (!empty($r['art'])) $s['art'] = (string)$r['art'];
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
            if (($c === 'F' && crc32(((int)($art['route'] ?? 0)) . '/' . ((int)($art['sec'] ?? 0)) . '/' . $x . '/' . $y) % 3 === 0) || ($c === 'E' && $art['boss'] !== '')) $tokens[] = [$x, $y, $c];   // v2.5.51: only about a third of the authored finds are kept (too many)
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
 * v2.5.49: the colour the ground fades into past the bottom edge of a baked section: the average of its last pixel rows, a little darker (shade). Read once
 * from the PNG with GD and kept per picture; '' when GD or the picture is missing (the caller then uses its flat per-land colour).
 */
function trail_art_edge_colour(array $art): string
{
    static $memo = [];
    $f = dirname(__DIR__) . '/assets/img/trail/ground/' . (int)$art['route'] . '-' . ((int)$art['sec'] + 1) . '.png';
    if (isset($memo[$f])) return $memo[$f];
    $c = '';
    if (function_exists('imagecreatefrompng') && is_file($f) && ($im = @imagecreatefrompng($f))) {
        $w = imagesx($im); $h = imagesy($im); $r = $g = $b = $n = 0;
        for ($y = max(0, $h - 6); $y < $h; $y++) for ($x = 0; $x < $w; $x += 4) {
            $p = imagecolorat($im, $x, $y);
            if (!imageistruecolor($im)) { $q = imagecolorsforindex($im, $p); $p = ($q['red'] << 16) | ($q['green'] << 8) | $q['blue']; }
            $r += ($p >> 16) & 255; $g += ($p >> 8) & 255; $b += $p & 255; $n++;
        }
        imagedestroy($im);
        if ($n) $c = sprintf('#%02x%02x%02x', (int)($r / $n * .72), (int)($g / $n * .72), (int)($b / $n * .72));
    }
    return $memo[$f] = $c;
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
    $fland = (string)($art['art'] ?? $land);   // the land whose art stands in (tools/bake_trail_art.py ART_LAND): find sprites are baked per art land
    $C = TM_UNIT;
    $k = $C / TRAIL_ART_PX;
    $x0 = (int)$state['x0'];
    $y0 = (int)$state['y0'];
    $W = (int)$state['cols'] * $C;
    $H = (int)$state['rows'] * $C;
    $n = 'tm_n';
    $under = ['grassland' => '#2a5a3e', 'forest' => '#4a2f2d', 'coast' => '#b78a5c', 'tundra' => '#8fb0d8'][$fland] ?? '#2a3a2e';
    if (($edge = trail_art_edge_colour($art)) !== '') $under = $edge;
    $o = '<svg class="tmbg tpix' . (($state['sfx'] ?? '') !== '' ? ' tmx' : '') . '" viewBox="0 0 ' . $W . ' ' . $H . '" preserveAspectRatio="none" aria-hidden="true" focusable="false">';
    $o .= '<defs><linearGradient id="tmfade" x1="0" y1="0" x2="0" y2="1"><stop offset="0" stop-color="' . $under . '" stop-opacity="0"/><stop offset="1" stop-color="' . $under . '" stop-opacity="1"/></linearGradient>'
        . '<linearGradient id="tmfadex" x1="0" y1="0" x2="1" y2="0"><stop offset="0" stop-color="' . $under . '" stop-opacity="1"/><stop offset="1" stop-color="' . $under . '" stop-opacity="0"/></linearGradient></defs>';
    $o .= '<rect width="' . $W . '" height="' . $H . '" fill="' . $under . '"/>';
    $o .= '<image href="' . e(trail_art_url('ground/' . (int)$art['route'] . '-' . ((int)$art['sec'] + 1) . '.png')) . '" x="' . $n(-$x0 * $C) . '" y="' . $n(-$y0 * $C - TRAIL_ART_PAD * $k)
        . '" width="' . $n($map['w'] * $C) . '" height="' . $n(($map['h'] * TRAIL_ART_PX + TRAIL_ART_PAD) * $k) . '"/>';
    // v2.5.49: the picture stops at the last row with a hard line; the ground fades into shade over the bottom half tile (and the left edge), so the map does not end on a ruler
    $by = ($map['h'] - $y0) * $C;
    if ($by > 0 && $by < $H + $C) $o .= '<rect x="0" y="' . $n($by - .6 * $C) . '" width="' . $W . '" height="' . $n(.6 * $C) . '" fill="url(#tmfade)"/>';
    $lx0 = -$x0 * $C;
    if ($lx0 > 0 && $lx0 < $W) $o .= '<rect x="' . $n($lx0) . '" y="0" width="' . $n(.5 * $C) . '" height="' . $H . '" fill="url(#tmfadex)"/>';
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
            $items[] = [$ty + .45, $tx, '<image href="' . e(trail_art_url('find-' . $fland . ($done ? '-done' : '') . '.png')) . '" x="' . $n($X) . '" y="' . $n($Y) . '" width="' . $C . '" height="' . $C . '"/>'];
        } else {   // the way on and the fixed fight: red-outlined placeholder tiles until their art is drawn
            $marks .= '<g' . ($done ? ' opacity=".5"' : '') . '><rect x="' . ($X + 2) . '" y="' . ($Y + 2) . '" width="' . ($C - 4) . '" height="' . ($C - 4) . '" fill="rgba(255,255,255,.18)" stroke="#e02020" stroke-width="2.5"/>'
                . '<text x="' . ($X + $C / 2) . '" y="' . $n($Y + $C / 2 + 6) . '" font-size="17" text-anchor="middle">' . e($icon) . '</text></g>';
        }
    }
    $lx = ($state['px'] - $x0) * $C + $C / 2;
    $ly = ($state['py'] - $y0) * $C + $C / 2;
    $rig = (string)($state['me'] ?? '');   // v2.5.49: the 2.5D gnome rig (trek_art_me): assets/tilemap.js turns it to face the way it walks and steps its walk frames
    if ($rig !== '' && str_contains($rig, 'tkrig')) {   // same box as the idle gnome.png (64 x 80 picture units), not the 42 px token box
        $rig = preg_replace('~^<svg class="tkrig" x="[^"]*" y="[^"]*" width="[^"]*" height="[^"]*"~', '<svg class="tkrig" x="' . $n(-32 * $k) . '" y="' . $n(-56 * $k) . '" width="' . $n(64 * $k) . '" height="' . $n(80 * $k) . '"', $rig, 1, $cnt);
        if (!$cnt) $rig = '';
    } else $rig = '';
    $items[] = [$state['py'] + .5, $state['px'], '<g class="tmme" transform="translate(' . $n($lx) . ' ' . $n($ly) . ')">' . ($rig !== '' ? $rig : '<image href="' . e(trail_art_url('gnome.png')) . '" x="' . $n(-32 * $k) . '" y="' . $n(-56 * $k)
        . '" width="' . $n(64 * $k) . '" height="' . $n(80 * $k) . '"/>') . '</g>'];
    usort($items, fn($a, $b) => [$a[0], $a[1]] <=> [$b[0], $b[1]]);
    $o .= $marks;   // flat marks lie on the ground, under the walker and the raised things
    foreach ($items as $it) $o .= $it[2];
    return $o . '</svg>';
}
