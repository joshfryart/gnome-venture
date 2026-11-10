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

/** Adventure tool types a gate can ask for (the gathering tools of includes/tools.php). */
const TRAIL_GATE_TOOLS = ['forage', 'pick', 'net', 'bucket', 'axe', 'rod', 'basket', 'staff', 'lantern'];

/** Where a section's entry tile is, when it is not marked S in the rows: the section's 'entry' ({x, y, side} or [x, y]), or null. */
function trail_section_entry($s): ?array
{
    $e = is_array($s) ? ($s['entry'] ?? null) : null;
    if (!is_array($e)) return null;
    $x = $e['x'] ?? ($e[0] ?? null);
    $y = $e['y'] ?? ($e[1] ?? null);
    return is_int($x) && is_int($y) ? [$x, $y] : null;
}

/** Is this a usable gate record? tiles [[x, y], ...] inside the map, tool_type a gathering tool, min_tier 1..4 (Worn..Masterwork), kind lock or shortcut. */
function trail_gate_valid($g, int $w, int $h): bool
{
    if (!is_array($g) || !is_array($g['tiles'] ?? null) || !$g['tiles'] || !in_array($g['tool_type'] ?? '', TRAIL_GATE_TOOLS, true)) return false;
    if (!is_int($g['min_tier'] ?? null) || $g['min_tier'] < 1 || $g['min_tier'] > 4 || !in_array($g['kind'] ?? '', ['lock', 'shortcut'], true)) return false;
    foreach ($g['tiles'] as $t) if (!is_array($t) || count($t) !== 2 || !is_int($t[0]) || !is_int($t[1]) || $t[0] < 0 || $t[1] < 0 || $t[0] >= $w || $t[1] >= $h) return false;
    return true;
}

/**
 * Is this authored route usable? Every section needs rows: all the same width (at least 5), all the same height (at least 3), only the characters
 * # . , S 9 E F, exactly one exit '9' on an edge of the map (any edge: v2.7 bendy maps leave on any side), and at most one S. A section without an S
 * needs an 'entry' ({x, y}) on an edge, on floor. Optional 'gates' must be valid records (trail_gate_valid). Anything else is dropped here, so a bad
 * hand-made map falls back to the random generator instead of breaking a walk. (The path from the entry to the exit is checked by
 * tools/bake_trail_art.py --check and tests/trail_authored.php.)
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
        $nine = $nS = 0;
        $edge = fn(int $x, int $y): bool => $x === 0 || $y === 0 || $x === $w - 1 || $y === $h - 1;
        foreach ($rows as $y => $row) {
            if (!is_string($row) || strlen($row) !== $w || !preg_match('/^[#.,S9EF]+$/', $row)) return false;
            if (($x = strpos($row, '9')) !== false) { $nine += substr_count($row, '9'); if (!$edge($x, $y)) return false; }
            $nS += substr_count($row, 'S');
        }
        if ($nine !== 1 || $nS > 1) return false;
        if ($nS === 0) {
            $e = trail_section_entry($s);
            if (!$e || $e[0] < 0 || $e[1] < 0 || $e[0] >= $w || $e[1] >= $h || !$edge($e[0], $e[1]) || $rows[$e[1]][$e[0]] === '#') return false;
        }
        if (isset($s['gates'])) {
            if (!is_array($s['gates'])) return false;
            foreach ($s['gates'] as $g) if (!trail_gate_valid($g, $w, $h)) return false;
        }
    }
    return true;
}

/**
 * v2.7: the water tiles of an authored section, ["x,y" => true]: 'wet' (rows of 0/1 written by tools/bake_trail_rich.py: streams, fords, ponds, sea, ice)
 * or, without it, the stream tiles of 'water' (pts). Empty for a section without water.
 */
function trail_water_tiles(array $art): array
{
    $out = [];
    if (!empty($art['wet']) && is_array($art['wet'])) {
        foreach ($art['wet'] as $y => $row) {
            if (!is_string($row)) continue;
            for ($x = 0, $n = strlen($row); $x < $n; $x++) if ($row[$x] === '1') $out[$x . ',' . (int)$y] = true;
        }
        return $out;
    }
    foreach ((array)($art['water'] ?? []) as $wv) foreach ((array)($wv['pts'] ?? []) as $pt) if (is_array($pt) && count($pt) >= 2) $out[(int)$pt[0] . ',' . (int)$pt[1]] = true;
    return $out;
}

/** Is tile x, y water or right beside water (the 8 tiles round it)? This is where the gnome can fish. */
function trail_water_near(array $art, int $x, int $y): bool
{
    $wet = trail_water_tiles($art);
    if (!$wet) return false;
    for ($dy = -1; $dy <= 1; $dy++) for ($dx = -1; $dx <= 1; $dx++) if (isset($wet[($x + $dx) . ',' . ($y + $dy)])) return true;
    return false;
}

/**
 * The gates of a section that are shut for this walker, ["x,y" => gate]. $tierOf(type) = the tier of the best tool of that type the gnome owns (0 = none).
 * A gate is shut while the best tool of its type is below min_tier. Pure; trail_gate() closes these tiles for the walk.
 */
function trail_gates_closed(array $art, callable $tierOf): array
{
    $out = [];
    foreach ($art['gates'] ?? [] as $g) {
        if ((int)$tierOf((string)$g['tool_type']) >= (int)$g['min_tier']) continue;
        foreach ($g['tiles'] as [$x, $y]) $out[$x . ',' . $y] = $g;
    }
    return $out;
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
    $entry = trail_section_entry($art);   // v2.7: a section without an S in its rows (the later ones of a bendy route) gets its entry from 'entry'
    $hasS = false;
    foreach ($art['rows'] as $row) if (str_contains((string)$row, 'S')) $hasS = true;
    foreach ($art['rows'] as $y => $row) {
        $row = (string)$row;
        if (!$hasS && $entry && $entry[1] === $y) $row[$entry[0]] = 'S';
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
 * 3 tiles of the section or within 2 tiles of the exit. No cap per section: it is a plain chance per tile. Base chance = setting trail_enc_pct
 * (default 3%) on floor, 2.5x that on rough floor. $stance scales the base: 'sneak' to 40%, 'hunt' to 250%.
 * $roll(float $percent): bool is the dice (tests pass their own). $quiet and $fights are only counted (kept for the saved scene). Returns [index or null, quiet, fights].
 */
function trail_encounter_index(array $map, array $path, int $quiet, int $fights, ?callable $roll = null, string $stance = '', ?float $base = null): array
{
    $mult = ['sneak' => 40, 'hunt' => 250][$stance] ?? 100;
    $base ??= function_exists('setting') ? (float)setting('trail_enc_pct') : 3.0;
    $roll ??= fn(float $pct): bool => random_int(1, 1000) <= (int)round($pct * 10);
    $en = $map['entry'] ?? [0, 0];
    $ex = $map['spots']['9'] ?? [-99, -99];
    foreach ($path as $i => [$x, $y]) {
        if (abs($x - $en[0]) + abs($y - $en[1]) < 3 || abs($x - $ex[0]) + abs($y - $ex[1]) < 3) continue;
        $pct = $base * (tm_tile($map, $x, $y) === ',' ? 2.5 : 1) * $mult / 100;
        if ($roll($pct)) return [$i, 0, $fights + 1];
        $quiet++;
    }
    return [null, $quiet, $fights];
}

/** Picture size [w, h] of a raised thing. Landmarks (lm-*) have their own sizes, read from the PNG; everything else is the 64 x 96 frame. */
function trail_art_obj_size(string $key): array
{
    static $cache = [];
    if (!str_starts_with($key, 'lm-')) return [64, 96];
    if (!isset($cache[$key])) {
        $sz = preg_match('/^lm-[a-z0-9-]+$/', $key) ? @getimagesize(dirname(__DIR__) . '/assets/img/trail/obj/' . $key . '.png') : false;
        $cache[$key] = $sz ? [(int)$sz[0], (int)$sz[1]] : [64, 96];
    }
    return $cache[$key];
}

function trail_art_url(string $rel): string
{
    $p = 'assets/img/trail/' . $rel;
    return function_exists('url') ? url($p) : $p . '?v=' . (defined('APP_VERSION') ? APP_VERSION : '0');
}

/**
 * v2.5.92: where a section's baked ground picture is. An Admin > Images upload (uploads/trail/ground/<route>-<section>.png) wins over the one that ships
 * in assets/img/trail/ground/. Returns the file path, or null when neither exists. $root = the game folder (a parameter only for the tests).
 */
function trail_ground_file(int $route, int $sec1, ?string $root = null, string $sfx = ''): ?string
{
    $root ??= dirname(__DIR__);
    $sfx = $sfx === '-r' ? '-r' : '';   // v2.6.38: the 30 x 18 pictures of the rich bake are <route>-<section>-r.png
    foreach (['uploads/trail/ground/', 'assets/img/trail/ground/'] as $d) if (is_file($root . '/' . $d . $route . '-' . $sec1 . $sfx . '.png')) return $root . '/' . $d . $route . '-' . $sec1 . $sfx . '.png';
    return null;
}

/** The URL of that picture (uploaded ones live under uploads/, shipped ones under assets/img/trail/). */
function trail_ground_url(int $route, int $sec1, string $sfx = ''): string
{
    $sfx = $sfx === '-r' ? '-r' : '';
    $f = trail_ground_file($route, $sec1, null, $sfx);
    if ($f !== null && str_contains($f, '/uploads/')) return function_exists('url') ? url('uploads/trail/ground/' . $route . '-' . $sec1 . $sfx . '.png') : 'uploads/trail/ground/' . $route . '-' . $sec1 . $sfx . '.png';
    return trail_art_url('ground/' . $route . '-' . $sec1 . $sfx . '.png');
}

/** v2.6.38: '-r' for a section of the rich 30 x 18 bake (its 'pic' is 'r'), else ''. */
function trail_art_sfx(array $art): string
{
    return ($art['pic'] ?? '') === 'r' ? '-r' : '';
}

/** Is the baked ground picture of this section on disk? (If not, the section is drawn the old way.) */
function trail_art_ready(array $art): bool
{
    return trail_ground_file((int)$art['route'], (int)$art['sec'] + 1, null, trail_art_sfx($art)) !== null;
}

/**
 * v2.5.49: the colour the ground fades into past the bottom edge of a baked section: the average of its last pixel rows, a little darker (shade). Read once
 * from the PNG with GD and kept per picture; '' when GD or the picture is missing (the caller then uses its flat per-land colour).
 */
function trail_art_edge_colour(array $art): string
{
    static $memo = [];
    $f = trail_ground_file((int)$art['route'], (int)$art['sec'] + 1, null, trail_art_sfx($art)) ?? '';
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
    $o .= '<image href="' . e(trail_ground_url((int)$art['route'], (int)$art['sec'] + 1, trail_art_sfx($art))) . '" x="' . $n(-$x0 * $C) . '" y="' . $n(-$y0 * $C - TRAIL_ART_PAD * $k)
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
    foreach ($art['objs'] as $ob) {
        [$ox, $oy, $key, $jit] = $ob;
        $jy = (int)($ob[4] ?? 0);   // v2.7: an optional 5th value = the sprite's shift down in picture pixels (tools/bake_trail_rich.py), also its place in the depth order
        [$bw, $bh] = trail_art_obj_size($key);
        if ($bw === 64 && $bh === 96) {   // trees, hedges, rocks: one 64 x 96 frame, feet near the bottom of the tile
            $X = ($ox - $x0) * $C + $jit * $k;
            $Y = (($oy - $y0) * TRAIL_ART_PX - 29 + $jy) * $k;
        } else {   // v2.5.63: landmarks (lm-*) are any size: centred on their tile, bottom edge = feet, a little above the tile's lower edge
            $X = ($ox - $x0) * $C + (32 - $bw / 2 + $jit) * $k;
            $Y = (($oy - $y0) * TRAIL_ART_PX + 62 - $bh) * $k;
        }
        if (!$in($X, $Y, $bw * $k, $bh * $k)) continue;
        $items[] = [$oy + .5 + $jy / TRAIL_ART_PX, $ox, '<image href="' . e(trail_art_url('obj/' . $key . '.png')) . '" x="' . $n($X) . '" y="' . $n($Y) . '" width="' . $n($bw * $k) . '" height="' . $n($bh * $k) . '"/>'];
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
    $palsSvg = '';   // v2.5.93: the Puzzle Pals taken along stand beside the gnome (state['pals'] = picture URLs); they sit inside the walker's group so they move with it
    foreach (array_slice((array)($state['pals'] ?? []), 0, 3) as $i => $pu) {
        $px = [-50, 20, -38][$i]; $py = [-6, -6, -34][$i]; $sz = $i === 2 ? 24 : 30;
        $palsSvg .= '<image class="tmpal" href="' . e((string)$pu) . '" x="' . $n($px * $k) . '" y="' . $n($py * $k) . '" width="' . $n($sz * $k) . '" height="' . $n($sz * $k) . '" image-rendering="pixelated"/>';
    }
    $items[] = [$state['py'] + .5, $state['px'], '<g class="tmme" transform="translate(' . $n($lx) . ' ' . $n($ly) . ')">' . $palsSvg . ($rig !== '' ? $rig : '<image href="' . e(trail_art_url('gnome.png')) . '" x="' . $n(-32 * $k) . '" y="' . $n(-56 * $k)
        . '" width="' . $n(64 * $k) . '" height="' . $n(80 * $k) . '"/>') . '</g>'];
    usort($items, fn($a, $b) => [$a[0], $a[1]] <=> [$b[0], $b[1]]);
    $o .= $marks;   // flat marks lie on the ground, under the walker and the raised things
    foreach ($items as $it) $o .= $it[2];
    return $o . '</svg>';
}
