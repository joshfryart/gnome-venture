<?php
declare(strict_types=1);

/**
 * 2.8.93 Map v2 (claude/proposal-map-v2-code.md): the "lit floor" region maps and the delve-down world map, behind the setting
 * map_v2_open (off by default). With it off nothing in here is reached and every map is drawn exactly as before.
 *
 * Region maps: a region is either fully v2 (map2-CODE.png, the spread layout of data/region_spread.json, the widget below) or fully old.
 *   The spread moves only the OFF-ROAD places (spread over the cavern floor); towns, stops, exits and roads stay where the v1 layout
 *   (region_layout_build) puts them, which is what the spread and the art were planned on (checked with a fingerprint, rl_stop_sig).
 *   Each off-road place hangs on its stop by a thick root (a quadratic curve, rl_root_ctrl); the Trail map turn of a side trail
 *   (bow / heading / ctrl) stays the v1 one.
 * World map: map2-world.png (640 x 360 art over the same 1000 x 560 unit view box), positions from data/world_v2_layout.json.
 */

require_once __DIR__ . '/scene.php';
require_once __DIR__ . '/world_v2.php';

const MAPV2_UNFOUND_KIND = true;   // unfound places show their kind as a dashed outline (the approved mockup); false = a plain "?"
const MAPV2_KIND_COL = ['village' => '#f4ead0', 'wonder' => '#f0c85a', 'delve' => '#a98ae0', 'lair' => '#e0624a', 'haven' => '#7fc08a'];
const MAPV2_KIND_WORD = ['village' => 'Village', 'wonder' => 'Wonder', 'delve' => 'Delve', 'lair' => 'Lair', 'haven' => 'Haven'];
/** the five small kind glyphs of the mockup, drawn round (0, 0) in a 10 x 10 box */
const MAPV2_GLYPH = [
    'village' => 'M-4 4 V-1 L0-4.5 4-1 V4Z',
    'wonder' => 'M0-5 L1.6-1.6 5-1.2 2.5 1.2 3.1 4.8 0 3 -3.1 4.8 -2.5 1.2 -5-1.2 -1.6-1.6Z',
    'delve' => 'M-4 0 A4 4 0 1 0 4 0 A4 4 0 1 0 -4 0 M-1.8 0 A1.8 1.8 0 1 1 1.8 0 A1.8 1.8 0 1 1 -1.8 0',
    'lair' => 'M-4 4 L-4-1 -2-3 -1.5 0 0-5 1.5 0 2-3 4-1 4 4Z',
    'haven' => 'M0-4.5 L4.5 4 -4.5 4Z M-1.2 4 L0 1.2 1.2 4Z',
];

// ======================= gates =======================

function map_v2_on(): bool
{
    return setting('map_v2_open') === '1';   // not cached: tests flip it
}

/** This region is drawn on the lit floor map: the setting is on, its picture is there and the spread fits this site's layout. */
function map_v2_region_on(string $code): bool
{
    return map_v2_on() && world_v2_on() && scene_path('map2', $code) !== '' && rl_spread_fits($code);
}

/** The world map is the delve-down one: the setting and World v2 are on, the picture and its layout data are there. */
function map_v2_world_on(): bool
{
    return map_v2_on() && world_v2_on() && scene_path('map2', 'world') !== '' && world2_layout() !== null;
}

/** Forget everything read or worked out in this file and the cached region layouts (tests only). */
function map_v2_flush(): void
{
    $GLOBALS['gv_mv2'] = [];
    if (function_exists('region_layout_flush')) region_layout_flush();
}

/** The region map picture for a code: map2 when the region is on v2, else the old one ('' when missing). */
function map_art_path(string $code): string
{
    return map_v2_region_on($code) ? scene_path('map2', $code) : scene_path('map', $code);
}

// ======================= region spread data =======================

/** data/region_spread.json, read once. [] when missing or not valid JSON. ($GLOBALS['gv_mv2_spread_path'] points elsewhere in tests.) */
function rl_spread_all(): array
{
    $c = &$GLOBALS['gv_mv2'];
    if (isset($c['spread'])) return $c['spread'];
    $f = $GLOBALS['gv_mv2_spread_path'] ?? __DIR__ . '/data/region_spread.json';
    $j = is_file($f) ? json_decode((string)file_get_contents($f), true) : null;
    return $c['spread'] = is_array($j) ? $j : [];
}

/** crc32 (8 hex) of every non-off slot, sorted by id ("id:type:x,y;"): the road skeleton the spread and the map2 art are drawn on. */
function rl_stop_sig(array $L): string
{
    $s = $L['slots'] ?? [];
    ksort($s);
    $t = '';
    foreach ($s as $id => $sl) if (($sl['type'] ?? '') !== 'off') $t .= (int)$id . ':' . $sl['type'] . ':' . (int)$sl['x'] . ',' . (int)$sl['y'] . ';';
    return sprintf('%08x', crc32($t));
}

/** The spread of one region resolved against this site's v1 layout: [slot id => [x, y]] (ids remapped by slug where needed), or null when it does not fit. */
function rl_spread_for(string $code): ?array
{
    $c = &$GLOBALS['gv_mv2'];
    if (isset($c['for']) && array_key_exists($code, $c['for'])) return $c['for'][$code];
    $all = rl_spread_all();
    $c['for'][$code] = null;
    $entry = $all[$code] ?? null;
    if (!is_array($entry) || !$entry) return null;
    require_once __DIR__ . '/region_layout.php';
    $L = region_layout($code, false);
    if (!$L || (string)($all['_meta']['sig'][$code] ?? '') !== rl_stop_sig($L)) return null;
    $slugs = (array)($all['_meta']['slugs'][$code] ?? []);
    $offBySlug = [];
    foreach ($L['slots'] as $id => $s) if ($s['type'] === 'off') $offBySlug[(string)$s['loc']['slug']] = (int)$id;
    $out = [];
    foreach ($entry as $id => $p) {
        $id = (int)$id;
        $want = (string)($slugs[(string)$id] ?? '');
        $s = $L['slots'][$id] ?? null;
        $rid = $s && $s['type'] === 'off' && ($want === '' || (string)$s['loc']['slug'] === $want) ? $id : ($want !== '' ? ($offBySlug[$want] ?? 0) : 0);
        if (!$rid || !is_array($p) || count($p) < 2) return null;
        $x = (float)$p[0]; $y = (float)$p[1];
        if ($x < 0 || $y < 0 || $x > (int)$L['w'] || $y > (int)$L['h']) return null;
        $out[$rid] = [(int)round($x), (int)round($y)];
    }
    ksort($out);
    return $c['for'][$code] = $out;
}

function rl_spread_fits(string $code): bool
{
    return rl_spread_for($code) !== null;
}

/** Control point of a root from stop $a to place $b: the chord's middle pushed sideways (to the left of a->b on screen) by min(10, 0.2 x length). Ints. */
function rl_root_ctrl(array $a, array $b): array
{
    $dx = $b[0] - $a[0]; $dy = $b[1] - $a[1]; $len = hypot($dx, $dy) ?: 1.0; $k = min(10.0, 0.2 * $len);
    return [(int)round(($a[0] + $b[0]) / 2 - $dy / $len * $k), (int)round(($a[1] + $b[1]) / 2 + $dx / $len * $k)];
}

/** 8 hex chars: sha1 of region_spread.json + world_v2_layout.json (read once). '0' when neither exists. */
function rl_spread_ver(): string
{
    $c = &$GLOBALS['gv_mv2'];
    if (isset($c['ver'])) return $c['ver'];
    $t = '';
    foreach ([$GLOBALS['gv_mv2_spread_path'] ?? __DIR__ . '/data/region_spread.json', __DIR__ . '/data/world_v2_layout.json'] as $f) if (is_file($f)) $t .= (string)file_get_contents($f);
    return $c['ver'] = $t === '' ? '0' : substr(sha1($t), 0, 8);
}

/** The v1 layout with the off-road places moved to their spread points (pure; proposal section 3.5). */
function rl_apply_spread(array $L, array $spread): array
{
    $L['v'] = 2;
    $W = (int)$L['w']; $H = (int)$L['h'];
    $stops = [];
    foreach ($L['slots'] as $id => $s) if ($s['type'] === 'stop' || $s['type'] === 'town') $stops[(int)$id] = $s;
    foreach ($L['slots'] as $id => &$s) {
        $s['role'] = village_role((string)$L['code'], $s);
        if ($s['type'] !== 'off') continue;
        $near = (int)$s['anchor'];
        if (!$near) {
            $bd = INF;
            foreach ($stops as $sid => $t) { $d = ($t['x'] - $s['x']) ** 2 + ($t['y'] - $s['y']) ** 2; if ($d < $bd) { $bd = $d; $near = $sid; } }
        }
        $s['near'] = $near;
        $s['x0'] = $s['x']; $s['y0'] = $s['y'];
        if (isset($spread[$id])) {
            $r = (int)$s['r'];
            $s['x'] = max($r + 6, min($W - $r - 6, (int)$spread[$id][0]));
            $s['y'] = max($r + 6, min($H - $r - 6, (int)$spread[$id][1]));
        }
    }
    unset($s);
    foreach ($L['clear'] as &$c) if (isset($L['slots'][$c['id']]) && $L['slots'][$c['id']]['type'] === 'off') { $c['x'] = $L['slots'][$c['id']]['x']; $c['y'] = $L['slots'][$c['id']]['y']; }
    unset($c);
    foreach ($L['trails'] as &$t) {
        $a = $L['slots'][$t['from']]; $b = $L['slots'][$t['to']];
        $A = [(int)$a['x'], (int)$a['y']]; $B = [(int)$b['x'], (int)$b['y']];
        $t['pts'] = [$A, $B];
        $t['root'] = ['c' => rl_root_ctrl($A, $B), 'len' => round(hypot($B[0] - $A[0], $B[1] - $A[1]), 1)];
        $h = rl_trail_heading($L['roads'], (int)$t['from'], $A, $B);
        $t['bow2'] = $h['bow']; $t['heading2'] = $h['heading']; $t['ctrl2'] = $h['ctrl'];   // bow / heading / ctrl stay the v1 ones (the Trail maps)
    }
    unset($t);
    return $L;
}

// ======================= village roles (master doc 17) =======================

/** data/village_roles.txt: ['NA' => ['Cattailmere' => 'main', ...]], read once. */
function village_roles(): array
{
    $c = &$GLOBALS['gv_mv2'];
    if (isset($c['roles'])) return $c['roles'];
    $out = [];
    $f = __DIR__ . '/data/village_roles.txt';
    foreach (is_file($f) ? file($f, FILE_IGNORE_NEW_LINES) : [] as $ln) {
        $ln = trim($ln);
        if ($ln === '' || $ln[0] === '#') continue;
        $p = array_map('trim', explode('|', $ln));
        if (count($p) >= 3) $out[strtoupper($p[0])][$p[1]] = $p[2];
    }
    return $c['roles'] = $out;
}

/** 'main' = the town, a road stop, or an off-road village listed as main; 'side' = any other off-road village; '' = everything else. */
function village_role(string $code, array $slot): string
{
    $type = (string)($slot['type'] ?? '');
    if ($type === 'town' || $type === 'stop') return 'main';
    if ($type !== 'off' || ($slot['kind'] ?? '') !== 'village') return '';
    return (village_roles()[strtoupper($code)][(string)($slot['loc']['name'] ?? '')] ?? '') === 'main' ? 'main' : 'side';
}

// ======================= world map =======================

/** data/world_v2_layout.json, read once; null unless 640 x 360, every REGION_MAP code and the hub are there. */
function world2_layout(): ?array
{
    $c = &$GLOBALS['gv_mv2'];
    if (is_array($c) && array_key_exists('world', $c)) return $c['world'];
    $f = __DIR__ . '/data/world_v2_layout.json';
    $j = is_file($f) ? json_decode((string)file_get_contents($f), true) : null;
    $okj = is_array($j) && (int)($j['w'] ?? 0) === 640 && (int)($j['h'] ?? 0) === 360 && isset($j['hub']['x'], $j['hub']['y']) && is_array($j['regions'] ?? null);
    if ($okj) foreach (array_keys(REGION_MAP) as $code) if (!isset($j['regions'][$code]['x'], $j['regions'][$code]['y'])) $okj = false;
    return $c['world'] = $okj ? $j : null;
}

/** art pixel -> map unit */
function world2_xy(float $x, float $y): array
{
    return [(int)round($x * 1000 / 640), (int)round($y * 560 / 360)];
}

/** The thread between two regions, cavern centre to cavern centre, in map units (floats); null when the art has none. */
function world2_route(string $a, string $b): ?array
{
    $W = world2_layout();
    if (!$W) return null;
    $set = $W['routes_full'] ?? $W['routes'] ?? [];
    $pts = $set["$a-$b"] ?? null;
    if ($pts === null && isset($set["$b-$a"])) $pts = array_reverse($set["$b-$a"]);
    if (!is_array($pts) || !$pts || !isset($W['regions'][$a], $W['regions'][$b])) return null;
    $out = [[$W['regions'][$a]['x'] * 1000 / 640, $W['regions'][$a]['y'] * 560 / 360]];
    foreach ($pts as $p) $out[] = [$p[0] * 1000 / 640, $p[1] * 560 / 360];
    $out[] = [$W['regions'][$b]['x'] * 1000 / 640, $W['regions'][$b]['y'] * 560 / 360];
    $clean = [];
    foreach ($out as $p) if (!$clean || hypot($p[0] - end($clean)[0], $p[1] - end($clean)[1]) > 0.01) $clean[] = $p;
    return $clean;
}

/** Length of a polyline. */
function map_poly_len(array $poly): float
{
    $L = 0.0;
    for ($i = 1; $i < count($poly); $i++) $L += hypot($poly[$i][0] - $poly[$i - 1][0], $poly[$i][1] - $poly[$i - 1][1]);
    return $L;
}

/** The point at fraction t (0..1) of the polyline's length. */
function map_poly_at(array $poly, float $t): array
{
    $n = count($poly);
    if ($n === 0) return [0.0, 0.0];
    if ($n === 1) return [(float)$poly[0][0], (float)$poly[0][1]];
    $want = max(0.0, min(1.0, $t)) * map_poly_len($poly);
    for ($i = 1; $i < $n; $i++) {
        $seg = hypot($poly[$i][0] - $poly[$i - 1][0], $poly[$i][1] - $poly[$i - 1][1]);
        if ($want <= $seg || $i === $n - 1) {
            $f = $seg > 0 ? min(1.0, $want / $seg) : 0.0;
            return [$poly[$i - 1][0] + ($poly[$i][0] - $poly[$i - 1][0]) * $f, $poly[$i - 1][1] + ($poly[$i][1] - $poly[$i - 1][1]) * $f];
        }
        $want -= $seg;
    }
    return [(float)$poly[$n - 1][0], (float)$poly[$n - 1][1]];
}

/** 'M x y L x y ...' (ints) */
function map_poly_d(array $poly): string
{
    $d = '';
    foreach ($poly as $i => $p) $d .= ($i ? ' L' : 'M') . (int)round($p[0]) . ' ' . (int)round($p[1]);
    return $d;
}

/** Where every place sits on the delve-down world map: [location id => [x, y]] in units. Fills gv_side_of and gv_road_curves (with 'poly'). */
function map_positions_v2(): array
{
    $c = &$GLOBALS['gv_mv2'];
    if (isset($c['pos'])) { $GLOBALS['gv_side_of'] = $c['side']; $GLOBALS['gv_road_curves'] = $c['curves']; return $c['pos']; }
    $W = world2_layout();
    $pos = []; $side = []; $curves = [];
    $codeOf = [];
    foreach (q('SELECT id, code FROM regions')->fetchAll() as $r) $codeOf[(int)$r['id']] = (string)$r['code'];
    $centre = [];
    foreach (array_keys(REGION_MAP) as $code) $centre[$code] = world2_xy((float)$W['regions'][$code]['x'], (float)$W['regions'][$code]['y']);
    $regOf = []; $kindOf = [];
    foreach (q('SELECT id, kind, region_id FROM locations ORDER BY id')->fetchAll() as $l) {
        $id = (int)$l['id'];
        $regOf[$id] = $codeOf[(int)$l['region_id']] ?? ''; $kindOf[$id] = (string)$l['kind'];
        if ($l['kind'] === 'hub') $pos[$id] = world2_xy((float)$W['hub']['x'], (float)$W['hub']['y']);
        elseif ($l['kind'] === 'market' && isset($centre[$regOf[$id]])) $pos[$id] = $centre[$regOf[$id]];
    }
    $onRoad = [];
    foreach (q('SELECT id, nodes FROM roads ORDER BY id')->fetchAll() as $rd) {
        $nodes = array_map('intval', json_decode((string)$rd['nodes'], true) ?: []);
        $n = count($nodes);
        if ($n < 2) continue;
        $ca = $regOf[$nodes[0]] ?? ''; $cb = $regOf[$nodes[$n - 1]] ?? '';
        if (!isset($centre[$ca], $centre[$cb])) continue;
        $poly = $ca !== $cb ? world2_route($ca, $cb) : null;
        if ($poly === null) $poly = [$pos[$nodes[0]] ?? $centre[$ca], $pos[$nodes[$n - 1]] ?? $centre[$cb]];
        if (($kindOf[$nodes[$n - 1]] ?? '') !== 'market') {   // a dead-end road: it ends where it first comes within 0.85 of the far cavern's floor
            $e = $W['regions'][$cb]; $ex = $e['x'] * 1000 / 640; $ey = $e['y'] * 560 / 360; $erx = max(1.0, $e['rx'] * 1000 / 640); $ery = max(1.0, $e['ry'] * 560 / 360);
            $in = fn(array $p): bool => (($p[0] - $ex) / $erx) ** 2 + (($p[1] - $ey) / $ery) ** 2 <= 0.85 ** 2;
            $cut = [$poly[0]];
            for ($i = 1; $i < count($poly); $i++) {
                $p = $poly[$i - 1]; $q = $poly[$i]; $hit = null;
                for ($k = 1; $k <= 20; $k++) { $m = [$p[0] + ($q[0] - $p[0]) * $k / 20, $p[1] + ($q[1] - $p[1]) * $k / 20]; if ($in($m)) { $hit = $m; break; } }
                if ($hit) { $cut[] = $hit; break; }
                $cut[] = $q;
            }
            $poly = $cut;
        }
        $len = max(1.0, map_poly_len($poly));
        $t = [];
        for ($i = 0; $i < $n; $i++) {
            $ti = $n > 1 ? $i / ($n - 1) : 0.0;
            $nid = $nodes[$i];
            if (($kindOf[$nid] ?? '') !== 'market') {
                if ($i > 0) {   // at least 12 units from the stop before it (one forward pass along the thread)
                    $prev = map_poly_at($poly, $t[$nodes[$i - 1]]);
                    while ($ti < 1.0) { $p = map_poly_at($poly, $ti); if (hypot($p[0] - $prev[0], $p[1] - $prev[1]) >= 12) break; $ti = min(1.0, $ti + 0.5 / $len); }
                }
                $p = map_poly_at($poly, $ti);
                $pos[$nid] ??= [(int)round($p[0]), (int)round($p[1])];   // a stop on two roads keeps its first place
            }
            $t[$nid] = $ti;
            $onRoad[$nid] = true;
        }
        $curves[] = ['road' => (int)$rd['id'], 'poly' => $poly, 't' => $t];
    }
    // off-road places are not drawn on this map; they sit by their side path's stop (6 units towards the region centre), else at the region centre
    foreach (q("SELECT a_id, b_id FROM routes WHERE kind = 'side' ORDER BY id")->fetchAll() as $rt) {
        [$a, $b] = [(int)$rt['a_id'], (int)$rt['b_id']];
        if (isset($onRoad[$a]) && !isset($onRoad[$b]) && !isset($side[$b])) $side[$b] = $a;
        elseif (isset($onRoad[$b]) && !isset($onRoad[$a]) && !isset($side[$a])) $side[$a] = $b;
    }
    foreach ($regOf as $id => $code) {
        if (isset($pos[$id]) || !isset($centre[$code])) continue;
        [$cx, $cy] = $centre[$code];
        if (isset($side[$id], $pos[$side[$id]])) {
            [$sx, $sy] = $pos[$side[$id]]; $d = hypot($cx - $sx, $cy - $sy);
            $pos[$id] = $d > 0 ? [(int)round($sx + ($cx - $sx) / $d * min(6.0, $d)), (int)round($sy + ($cy - $sy) / $d * min(6.0, $d))] : [$sx, $sy];
        } else $pos[$id] = [$cx, $cy];
    }
    foreach ($pos as $id => $p) $pos[$id] = [max(0, min(1000, (int)$p[0])), max(0, min(560, (int)$p[1]))];
    $c['pos'] = $pos; $c['side'] = $side; $c['curves'] = $curves;
    $GLOBALS['gv_side_of'] = $side; $GLOBALS['gv_road_curves'] = $curves;
    return $pos;
}

/** A name plate: dark rounded rect with cream text, centred on (x, y = baseline). */
function map2_plate(float $x, float $y, string $txt, float $fs, string $fill = '#f4ead0', string $cls = 'plate'): string
{
    $w = mb_strlen($txt) * $fs * 0.59 + 8;
    return '<g class="' . $cls . '"><rect x="' . round($x - $w / 2, 1) . '" y="' . round($y - $fs * 0.96, 1) . '" width="' . round($w, 1) . '" height="' . round($fs * 1.44, 1) . '" rx="2" fill="#0e0f09" fill-opacity="0.88"/>'
        . '<text x="' . round($x, 1) . '" y="' . round($y, 1) . '" text-anchor="middle" font-size="' . $fs . '" font-weight="700" fill="' . $fill . '">' . e($txt) . '</text></g>';
}

/** The delve-down world map (same outer markup as world_map_svg, so site.js gvMaps() binds it). */
function world_map2_svg(array $u, ?int $sel = null): string
{
    $W = world2_layout();
    $regions = [];
    foreach (q('SELECT * FROM regions')->fetchAll() as $r) $regions[$r['code']] = $r;
    $uid = (int)$u['id'];
    $pos = map_positions();
    $curves = $GLOBALS['gv_road_curves'] ?? [];
    $guides = guide_regions($uid);
    $prc = [];
    if (setting('ppal_open') === '1' || is_admin()) { require_once __DIR__ . '/puzzle_pals.php'; $prc = ppal_region_counts($u); }
    $been = visited_regions($uid);
    $lvl = (int)$u['level'];
    $walking = (bool)active_expedition($uid);
    $here = player_node($u);
    $go = [];
    if (!$walking) foreach (visible_routes($u, (int)$here['id']) as $r) $go[(int)$r['to']['id']] = [(int)$r['id'], (int)$r['steps']];
    $sx = 1000 / 640; $sy = 560 / 360;
    $svg = '<svg class="worldmap art v2" viewBox="0 0 1000 560" role="img" aria-label="Map of the Hollow">'
        . '<rect x="-2000" y="-2000" width="5000" height="4560" fill="#0e0f09"/>'
        . pixel_image(scene_path('map2', 'world') . '?v=' . rl_spread_ver(), 0, 0, 1000, 560, '', '', 'none', 'mapart');
    // the level ruler on the left edge
    $ru = '<g class="w2ruler" aria-hidden="true">';
    foreach ((array)($W['ruler']['bands'] ?? []) as $b) {
        $y0 = $b['y0'] * $sy; $y1 = $b['y1'] * $sy; $ym = ($y0 + $y1) / 2;
        $ru .= '<rect x="4" y="' . round($y0 + 2, 1) . '" width="7" height="' . round($y1 - $y0 - 4, 1) . '" rx="2" fill="' . e((string)$b['colour']) . '"/>'
            . '<rect x="14" y="' . round($ym - 10, 1) . '" width="46" height="18" rx="3" fill="#0e0f09" fill-opacity="0.85"/>'
            . '<text x="37" y="' . round($ym + 3.5, 1) . '" text-anchor="middle" font-size="11" font-weight="700" fill="' . e((string)$b['colour']) . '">Lv ' . e((string)$b['lv']) . '</text>';
    }
    $svg .= $ru . '</g>';
    // roads: along the painted threads
    $roads = q('SELECT id, name, nodes FROM roads ORDER BY id')->fetchAll();
    foreach ($roads as $rd) {
        $poly = null;
        foreach ($curves as $cv) if (($cv['road'] ?? 0) === (int)$rd['id']) { $poly = $cv['poly']; break; }
        if (!$poly || count($poly) < 2) continue;
        $d = map_poly_d($poly);
        $svg .= '<path class="roadcase" d="' . $d . '" stroke="#14110a" stroke-width="5" fill="none" stroke-linecap="round" stroke-linejoin="round" vector-effect="non-scaling-stroke"/>'
            . '<path class="road" d="' . $d . '" stroke="#f4ead0" stroke-width="3" stroke-dasharray="7 6" fill="none" stroke-linecap="round" stroke-linejoin="round" vector-effect="non-scaling-stroke"><title>' . e($rd['name']) . '</title></path>';
    }
    // which places you have found
    $keys = array_fill_keys(q('SELECT e.unlock_key FROM user_encyclopedia ue JOIN encyclopedia_entries e ON e.id = ue.entry_id WHERE ue.user_id = ?', [$uid])->fetchAll(PDO::FETCH_COLUMN), true);
    $plotV = array_fill_keys(array_map('intval', q('SELECT village_id FROM plots WHERE user_id = ? AND village_id IS NOT NULL', [$uid])->fetchAll(PDO::FETCH_COLUMN)), true);
    $onRoad = [];
    foreach ($roads as $rd) foreach (array_slice(json_decode((string)$rd['nodes'], true) ?: [], 1, -1) as $id) $onRoad[(int)$id] = true;
    $places = [];
    foreach (q("SELECT l.id, l.name, l.slug, l.kind, l.region, l.landscape, (SELECT kind FROM landmarks WHERE location_id = l.id ORDER BY id LIMIT 1) AS lmkind,
        (SELECT COUNT(*) FROM landmarks m WHERE m.location_id = l.id AND m.kind IN ('haven', 'wonder', 'delve') AND m.ruined = 1
           AND NOT EXISTS (SELECT 1 FROM landmark_rebuilds b WHERE b.landmark_id = m.id AND b.user_id = ?)) AS ruin
        FROM locations l WHERE l.kind NOT IN ('market', 'hub')", [$uid])->fetchAll() as $l) {
        $id = (int)$l['id'];
        if (!isset($pos[$id], $onRoad[$id])) continue;   // v2: road stops only (off-road places live on the region maps)
        $l['known'] = isset($plotV[$id]) || isset($keys[($l['kind'] === 'village' ? 'village:' : 'landmark:') . $l['slug']]);
        $places[$id] = $l;
    }
    // regions: the cavern floor is the tap target
    foreach (REGION_MAP as $code => $p) {
        if (!isset($regions[$code], $W['regions'][$code])) continue;
        $g = $W['regions'][$code]; $reg = $regions[$code];
        [$x, $y] = world2_xy((float)$g['x'], (float)$g['y']);
        $rx = (int)round(($g['rx'] ?? 30) * $sx); $ry = (int)round(($g['ry'] ?? 12) * $sy);
        $rid = (int)$reg['id'];
        $isSel = $sel === $rid;
        $open = can_fast_travel($u, $rid) || in_array($rid, $been, true);
        $min = max(1, (int)$reg['min_level']);
        $lb = $g['label'] ?? [$g['x'] - 30, $g['y'] + $g['ry'] + 2, $g['x'] + 30, $g['y'] + $g['ry'] + 14];
        $lx = (int)round(($lb[0] + $lb[2]) / 2 * $sx) - $x; $ly = (int)round(($lb[1] + $lb[3]) / 2 * $sy) - $y;
        $lvTxt = !$open && $min <= $lvl ? '🥾 not yet visited' : ($open ? '' : '🔒 ') . 'Lv ' . $min;
        $svg .= '<a class="region" href="' . e(url('world.php?tab=map&r=' . $rid . '#regionmap')) . '" aria-label="' . e($reg['gnomish_name']) . '">'
            . '<title>' . e($reg['gnomish_name'] . ' (' . $reg['real_name'] . ')') . '</title>'
            . '<ellipse class="hit" cx="' . $x . '" cy="' . $y . '" rx="' . ($rx + 14) . '" ry="' . ($ry + 14) . '" fill="#ffffff" fill-opacity="0"/>'
            . ($isSel ? '<ellipse cx="' . $x . '" cy="' . $y . '" rx="' . ($rx + 6) . '" ry="' . ($ry + 6) . '" fill="none" stroke="#f0c85a" stroke-width="4" vector-effect="non-scaling-stroke"/>' : '')
            . (isset($GLOBALS['gv_seek_regions'][$rid]) ? '<ellipse class="seekglow" cx="' . $x . '" cy="' . $y . '" rx="' . ($rx + 12) . '" ry="' . ($ry + 12) . '" fill="#7bc96f" fill-opacity="0.18" stroke="#3f9a35" stroke-width="3" stroke-dasharray="6 4" vector-effect="non-scaling-stroke"/>' : '')
            . map_mark($x, $y, '<text y="7" text-anchor="middle" font-size="18"' . ($open ? '' : ' opacity="0.45"') . '>🏘️</text>'
                . map2_plate($lx, $ly + 4, (string)$reg['gnomish_name'], 12)
                . map2_plate($lx, $ly + 22, $lvTxt, 10, $min > $lvl ? '#f0a08a' : '#cfe8a8')
                . (in_array($rid, $guides, true) ? '<text x="-22" y="-12" text-anchor="middle" font-size="14">📗</text>' : '')
                . (isset($prc[$rid]) ? ppal_region_badge($prc[$rid], '22 -12') : ''))
            . '</a>';
    }
    // every stop on the roads (layer 2)
    $kindIcon = ['village' => '🏡', 'haven' => '🏕️', 'wonder' => '✨', 'lair' => '🐉', 'delve' => '🕳️'];
    $kindFill = ['village' => '#f3e3b0', 'haven' => '#cfe7c4', 'wonder' => '#e9d4f2', 'lair' => '#f0b9a8', 'delve' => '#c9c0b0'];
    $mending = array_fill_keys(array_map('intval', q('SELECT m.location_id FROM landmark_repairs r JOIN landmarks m ON m.id = r.landmark_id WHERE r.user_id = ? AND r.done_at IS NULL AND r.dropped_at IS NULL', [$uid])->fetchAll(PDO::FETCH_COLUMN)), true);
    $dots = '';
    foreach ($places as $id => $l) {
        [$x, $y] = $pos[$id];
        $k = $l['kind'] === 'village' ? 'village' : (string)($l['lmkind'] ?: $l['kind']);
        $known = $l['known'];
        $ruin = $known && (int)$l['ruin'] > 0 ? (isset($mending[$id]) ? '🔨' : '🏚️') : '';
        $what = $known ? (MAPV2_KIND_WORD[$k] ?? 'Place') . ' on the road · ' . $l['region']
            . ($ruin === '🔨' ? ' · you’re repairing it' : ($ruin ? ' · in ruins: go there to take on the repair' : '')) : 'A stop on the road you haven’t visited yet';
        $attrs = ' data-place="' . $id . '" data-name="' . e($known ? $l['name'] : '???') . '" data-what="' . e($what) . '" data-go="' . e(url('world.php?go=' . $id . '#gopanel')) . '"'
            . (isset($go[$id]) ? ' data-route="' . $go[$id][0] . '" data-steps="' . $go[$id][1] . '"' : '')
            . ((int)$here['id'] === $id ? ' data-here="1"' : '');
        $dots .= map_mark($x, $y,
            '<circle r="' . ($known ? 6 : 4) . '" fill="' . ($known ? ($kindFill[$k] ?? '#fffaf0') : '#b8ab90') . '" stroke="#14110a" stroke-width="' . ($known ? 2 : 1) . '"/>'
            . ($ruin ? '<text x="7" y="-5" text-anchor="middle" font-size="9">' . $ruin . '</text>' : '')
            . '<title>' . e($known ? $l['name'] . ' (' . $l['region'] . ')' . ($ruin ? ' · in ruins' : '') : 'A stop on the road, not visited yet') . '</title>'
            . '<g class="lod3">' . ($known ? '<text y="4" text-anchor="middle" font-size="8">' . ($kindIcon[$k] ?? '📍') . '</text>' . map2_plate(0, (int)$here['id'] === $id ? 27 : 17, mb_strimwidth($l['name'], 0, 22, '…'), 8)
                : '<text y="3" text-anchor="middle" font-size="6">❔</text>') . '</g>', 'place', $attrs);
    }
    $svg .= '<g class="lod2">' . $dots . '</g>';
    // your gardens
    $homeV = (int)($u['home_village_id'] ?? 0);
    foreach (q('SELECT village_id, garden_name FROM plots WHERE user_id = ? AND village_id IS NOT NULL', [$uid])->fetchAll() as $g) {
        $vid = (int)$g['village_id'];
        if (!isset($pos[$vid])) continue;
        $svg .= map_mark($pos[$vid][0], $pos[$vid][1], '<text x="9" y="-7" text-anchor="middle" font-size="15"><title>' . e($g['garden_name'] ?: 'Your garden') . '</title>' . ($vid === $homeV ? '🏡' : '🌱') . '</text>'
            . '<g class="lod2">' . map2_plate(9, -20, (string)($g['garden_name'] ?: 'Your garden'), 9) . '</g>', 'garden');
    }
    foreach (array_keys($GLOBALS['gv_seek_stops'] ?? []) as $sid) {
        if (!isset($pos[$sid])) continue;
        $svg .= map_mark($pos[$sid][0], $pos[$sid][1], '<text x="-9" y="-7" text-anchor="middle" font-size="15"><title>A place to find what you’re seeking</title>🎯</text>', 'seek');
    }
    // folk you know
    $byPlace = [];
    foreach (known_npcs($uid) as $n) {
        $town = $n['now']['town'] ?? null;
        if (!$town) continue;
        $lid = (int)q_val("SELECT id FROM locations WHERE kind IN ('market', 'hub') AND region = ? ORDER BY kind LIMIT 1", [$town]);
        if (isset($pos[$lid])) $byPlace[$lid][] = $n['name'];
    }
    foreach ($byPlace as $lid => $names) {
        $list = '';
        foreach (array_slice($names, 0, 6) as $i => $nm) $list .= map_text('👤 ' . e($nm), -4 + $i * 11, 9, ['anchor' => 'start', 'bold' => false]);
        if (count($names) > 6) $list .= map_text('+' . (count($names) - 6) . ' more', -4 + 6 * 11, 9, ['anchor' => 'start']);
        $svg .= '<a href="' . e(url('town.php?view=villagers')) . '">' . map_mark($pos[$lid][0], $pos[$lid][1],
            '<title>' . e(implode(', ', $names)) . '</title>'
            . '<g class="lodf"><circle cx="24" cy="-20" r="11" fill="#fff3b0" stroke="#b08a2a" stroke-width="2"/><text x="24" y="-15" text-anchor="middle" font-size="13">👤</text>'
            . (count($names) > 1 ? map_text((string)count($names), -26, 11, ['x' => 37, 'anchor' => 'start']) : '') . '</g>'
            . '<g class="lod3" transform="translate(20 -14)">' . $list . '</g>', 'folk') . '</a>';
    }
    // the hub
    [$hx, $hy] = world2_xy((float)$W['hub']['x'], (float)$W['hub']['y']);
    $hly = (int)round(((float)($W['hub']['label_y'] ?? $W['hub']['y'] + 30)) * $sy) - $hy;
    $svg .= '<a href="' . e(url('town.php?hub=1')) . '" aria-label="Mossbottom hub"><title>Mossbottom: the hub, reachable from anywhere</title>'
        . map_mark($hx, $hy, '<text y="8" text-anchor="middle" font-size="28">🍄</text>' . map2_plate(0, $hly, 'Mossbottom', 13)) . '</a>';
    $me = player_map_pos($u);
    if ($me) {
        $svg .= map_mark($me[0], $me[1], '<circle r="15" fill="#ffe66b" fill-opacity="0.55" stroke="#d9a520" stroke-width="3"><title>You are here</title></circle>'
            . '<text y="7" text-anchor="middle" font-size="20">🎩</text>', 'me');
    }
    $svg .= '</svg>';
    return '<div class="mapzoom" data-me="' . ($me ? $me[0] . ',' . $me[1] : '500,280') . '">'
        . '<div class="mapctl" hidden><button type="button" class="btn small" data-z="in" aria-label="Zoom in">＋</button><button type="button" class="btn small" data-z="out" aria-label="Zoom out">−</button>'
        . '<button type="button" class="btn small alt" data-z="me" aria-label="Find me">🎩</button><button type="button" class="btn small alt" data-z="all" aria-label="Whole world">🌍</button></div>'
        . $svg
        . '<div class="mapcard box" hidden></div>'
        . '<form class="mapgo" method="post" action="' . e(url('adventure.php')) . '" hidden>' . csrf_field() . '<input type="hidden" name="do" value="start"><input type="hidden" name="route_id" value=""></form>'
        . '</div>';
}

// ======================= region map widget =======================

/** A kind glyph as SVG (found: filled in its colour; not found: a dashed grey outline, or a "?" when MAPV2_UNFOUND_KIND is off). */
function map2_glyph(string $kind, bool $found, float $scale = 1.2): string
{
    if (!$found && !MAPV2_UNFOUND_KIND) return '<text y="3.5" text-anchor="middle" font-size="10" font-weight="700" fill="#a39f8f">?</text>';
    $d = MAPV2_GLYPH[$kind] ?? MAPV2_GLYPH['village'];
    return '<path class="gl" transform="scale(' . $scale . ')" d="' . $d . '" fill-rule="evenodd"'
        . ($found ? ' fill="' . (MAPV2_KIND_COL[$kind] ?? '#f4ead0') . '" stroke="#14110a" stroke-width="1"' : ' fill="none" stroke="#a39f8f" stroke-width="0.9" stroke-dasharray="1.4 1.4"') . '/>';
}

/** The small icon at the start of a sheet row. */
function map2_row_icon(string $kind, bool $found): string
{
    return '<svg class="mv2-ico" viewBox="-7 -7 14 14" aria-hidden="true">' . map2_glyph($kind, $found, 1.25) . '</svg>';
}

/** What the widget needs about one region for one gnome (layout, what is found, groups by stop, the selection). null when not on v2. */
function map2_model(array $u, int $regionId, int $selId, int $nearId, int $atId): ?array
{
    require_once __DIR__ . '/region_layout.php';
    $reg = q_one('SELECT * FROM regions WHERE id = ?', [$regionId]);
    if (!$reg || !isset(REGION_MAP[$reg['code']]) || !map_v2_region_on((string)$reg['code'])) return null;
    $code = (string)$reg['code'];
    $L = region_layout($code);
    if (!$L || (int)($L['v'] ?? 1) !== 2) return null;
    $uid = (int)$u['id'];
    $keys = array_fill_keys(q('SELECT e.unlock_key FROM user_encyclopedia ue JOIN encyclopedia_entries e ON e.id = ue.entry_id WHERE ue.user_id = ?', [$uid])->fetchAll(PDO::FETCH_COLUMN), true);
    $plots = array_fill_keys(array_map('intval', q('SELECT village_id FROM plots WHERE user_id = ? AND village_id IS NOT NULL', [$uid])->fetchAll(PDO::FETCH_COLUMN)), true);
    $known = function (array $loc) use ($keys, $plots): bool {
        if (in_array($loc['kind'], ['market', 'hub'], true) || isset($plots[(int)$loc['id']])) return true;
        return isset($keys[($loc['kind'] === 'village' ? 'village:' : 'landmark:') . $loc['slug']]);
    };
    $seen = [];
    foreach ($L['slots'] as $id => $s) $seen[$id] = $s['type'] === 'far' || $s['type'] === 'town' || $known($s['loc']);
    $groups = [];
    foreach ($L['slots'] as $id => $s) if ($s['type'] === 'off' && isset($L['slots'][$s['near'] ?? 0])) $groups[(int)$s['near']][] = (int)$id;
    foreach ($groups as $sid => &$list) usort($list, fn($a, $b) => [$seen[$b], (string)$L['slots'][$a]['loc']['name']] <=> [$seen[$a], (string)$L['slots'][$b]['loc']['name']]);
    unset($list);
    $hereId = (int)(player_node($u)['id'] ?? 0);
    // the stop to open on: ?near, the stop of ?at, the stop of the place being looked at, the stop you stand at or near
    $stopOf = function (int $id) use ($L, $groups): int {
        $s = $L['slots'][$id] ?? null;
        if (!$s) return 0;
        if ($s['type'] === 'off') return (int)($s['near'] ?? 0);
        return ($s['type'] === 'stop' || $s['type'] === 'town') && isset($groups[$id]) ? $id : 0;
    };
    $sel = 0;
    if ($nearId && isset($L['slots'][$nearId], $groups[$nearId]) && in_array($L['slots'][$nearId]['type'], ['stop', 'town'], true)) $sel = $nearId;
    if (!$sel && $atId && ($L['slots'][$atId]['type'] ?? '') === 'off') $sel = $stopOf($atId);
    if (!$sel && $selId) $sel = $stopOf($selId);
    if (!$sel && $hereId) $sel = $stopOf($hereId);
    if ($atId && (($L['slots'][$atId]['type'] ?? '') !== 'off' || (int)($L['slots'][$atId]['near'] ?? 0) !== $sel)) $atId = 0;
    $ruins = array_fill_keys(array_map('intval', q("SELECT DISTINCT m.location_id FROM landmarks m WHERE m.kind IN ('haven', 'wonder', 'delve') AND m.ruined = 1
        AND NOT EXISTS (SELECT 1 FROM landmark_rebuilds b WHERE b.landmark_id = m.id AND b.user_id = ?)", [$uid])->fetchAll(PDO::FETCH_COLUMN)), true);
    $pp = [];
    if (setting('ppal_open') === '1' || is_admin()) { require_once __DIR__ . '/puzzle_pals.php'; $pp = ppal_map_spawns($u); }
    return ['reg' => $reg, 'code' => $code, 'L' => $L, 'seen' => $seen, 'groups' => $groups, 'sel' => $sel, 'at' => $atId, 'here' => $hereId,
        'plots' => $plots, 'home' => (int)($u['home_village_id'] ?? 0), 'ruins' => $ruins, 'pp' => $pp, 'rid' => $regionId, 'u' => $u,
        'tags' => setting('journey_v2_open') === '1'];
}

/** Link that selects a stop (and optionally marks a place) on this region's map. */
function map2_near_url(int $rid, int $near, int $at = 0): string
{
    return url('world.php?tab=map&r=' . $rid . '&near=' . $near . ($at ? '&at=' . $at : '') . '#regionmap');
}

/** The name a stop shows (unvisited stops have none). */
function map2_stop_name(array $M, int $id): string
{
    $s = $M['L']['slots'][$id] ?? null;
    if (!$s) return '';
    return $M['seen'][$id] ? (string)$s['loc']['name'] : '';
}

/** The lit floor region map SVG (no controls, no sheet). */
function region_map2_svg(array $M): string
{
    $L = $M['L']; $S = $L['slots']; $W = (int)$L['w']; $H = (int)$L['h'];
    $reg = $M['reg']; $rid = (int)$M['rid']; $sel = (int)$M['sel']; $here = (int)$M['here'];
    $art = scene_path('map2', $M['code']);
    $svg = '<svg class="regionmap art mv2-svg' . ($sel ? ' sel' : '') . '" viewBox="0 0 ' . $W . ' ' . $H . '" preserveAspectRatio="xMidYMid meet" role="group" aria-label="Map of ' . e($reg['gnomish_name']) . '">'
        . '<rect class="rock" x="-2000" y="-2000" width="' . ($W + 4000) . '" height="' . ($H + 4000) . '" fill="#0e0f09"/>'
        . '<image class="mapart" href="' . e(url($art . '?v=' . rl_spread_ver())) . '" x="0" y="0" width="' . $W . '" height="' . $H . '" preserveAspectRatio="none" image-rendering="pixelated"/>'
        . '<rect class="mv2-dim" x="0" y="0" width="' . $W . '" height="' . $H . '" fill="#0e0f09" opacity="0.34"/>';
    // roads: lines, as on the old map
    $line = fn(array $a, array $b): string => 'M' . (int)$a['x'] . ' ' . (int)$a['y'] . ' L' . (int)$b['x'] . ' ' . (int)$b['y'];
    $case = ''; $lines = '';
    foreach ($L['roads'] as $rd) {
        for ($i = 1; $i < count($rd['nodes']); $i++) {
            $a = $S[$rd['nodes'][$i - 1]] ?? null; $b = $S[$rd['nodes'][$i]] ?? null;
            if (!$a || !$b) continue;
            $walked = $M['seen'][$rd['nodes'][$i - 1]] && $M['seen'][$rd['nodes'][$i]];
            $d = $line($a, $b);
            $case .= '<path class="rcase" d="' . $d . '" stroke="#14110a" stroke-width="9" stroke-linecap="round" fill="none"/>';
            $lines .= '<path class="road' . ($walked ? '' : ' unwalked') . '" d="' . $d . '" stroke="#f4ead0" stroke-width="5"'
                . ($walked ? '' : ' stroke-dasharray="7 7" stroke-opacity="0.75"') . ' stroke-linecap="round" fill="none"><title>' . e($rd['name']) . '</title></path>';
        }
    }
    $svg .= $case . $lines;
    // roots: every trail, found or not
    $rootD = [];
    foreach ($L['trails'] as $t) {
        $to = (int)$t['to']; $s = $S[$to]; $near = (int)($s['near'] ?? $t['from']);
        [$A, $B] = $t['pts']; $c = $t['root']['c'];
        $d = 'M' . $A[0] . ' ' . $A[1] . ' Q' . $c[0] . ' ' . $c[1] . ' ' . $B[0] . ' ' . $B[1];
        $rootD[(int)$t['from'] . '>' . $to] = $d;
        $f = $M['seen'][$to];
        $svg .= '<g class="mv2-root ' . ($f ? 'found' : 'unfound') . ($near === $sel && $sel ? ' on' : '') . '" data-stop="' . $near . '" data-id="' . $to . '">'
            . ($f ? '<path class="rc" d="' . $d . '" fill="none" stroke="#14110a" stroke-width="8" stroke-linecap="round"/><path class="rl" d="' . $d . '" fill="none" stroke="#f0c85a" stroke-width="4.2" stroke-linecap="round"/>'
                : '<path class="rc" d="' . $d . '" fill="none" stroke="#14110a" stroke-width="6" stroke-linecap="round"/><path class="rl" d="' . $d . '" fill="none" stroke="#a39f8f" stroke-width="3.2" stroke-dasharray="1 6" stroke-linecap="round"/>')
            . '</g>';
    }
    // the route being followed
    require_once __DIR__ . '/destination.php';
    $routeIds = dest_route_ids($M['u']);
    $onRoute = array_fill_keys($routeIds, true);
    for ($i = 1; $i < count($routeIds); $i++) {
        $a = $routeIds[$i - 1]; $b = $routeIds[$i];
        if (!isset($S[$a], $S[$b])) continue;
        $d = $rootD["$a>$b"] ?? null;
        if ($d === null && isset($rootD["$b>$a"])) { $t = null; foreach ($L['trails'] as $tt) if ((int)$tt['from'] === $b && (int)$tt['to'] === $a) $t = $tt; $d = 'M' . $t['pts'][1][0] . ' ' . $t['pts'][1][1] . ' Q' . $t['root']['c'][0] . ' ' . $t['root']['c'][1] . ' ' . $t['pts'][0][0] . ' ' . $t['pts'][0][1]; }
        $svg .= '<path class="gps" d="' . ($d ?? $line($S[$a], $S[$b])) . '" stroke="#e8a317" stroke-width="7" stroke-linecap="round" fill="none" opacity="0.85"/>';
    }
    $hat = '<circle r="15" fill="#ffe66b" fill-opacity="0.45" stroke="#d9a520" stroke-width="3"/><text y="6" text-anchor="middle" font-size="15">🎩</text>';
    $top = '';
    // places off the road
    foreach ($S as $id => $s) {
        if ($s['type'] !== 'off') continue;
        $f = $M['seen'][$id]; $near = (int)($s['near'] ?? 0); $k = isset(MAPV2_GLYPH[$s['kind']]) ? (string)$s['kind'] : 'village';
        $nm = (string)$s['loc']['name'];
        $isMe = $id === $here;
        $inner = '<circle class="hit" r="24" fill="#ffffff" fill-opacity="0"/>'
            . ($f ? '<circle r="10.5" fill="#0e0f09" stroke="' . MAPV2_KIND_COL[$k] . '" stroke-width="2"/>' : '<circle r="9" fill="#0e0f09" stroke="#a39f8f" stroke-width="2" stroke-dasharray="2.4 2.4"/>')
            . map2_glyph($k, $f, $f ? 1.2 : 1.05);
        if ($f) {
            $inner .= map2_plate(0, 19.8, mb_strlen($nm) > 15 ? mb_substr($nm, 0, 14) . '…' : $nm, 7.3);
            if (isset($M['plots'][$id])) $inner .= '<text x="9" y="-6" text-anchor="middle" font-size="9">' . ($id === $M['home'] ? '🏡' : '🌱') . '</text>';
            if (isset($M['ruins'][$id])) $inner .= '<text x="-9" y="-6" text-anchor="middle" font-size="8">🏚️</text>';
        }
        if (isset($M['pp'][$id]) && !$isMe) $inner .= '<text x="9" y="9" text-anchor="middle" font-size="9"><title>A Puzzle Pal waits here</title>🧩</text>';
        if ($isMe) $inner .= $hat;
        $label = $f ? $nm . ', ' . (MAPV2_KIND_WORD[$k] ?? 'Place') . ' off the road' : 'A place not found yet';
        $cls = 'rmp mv2-p k-' . $k . ($f ? ' found' : ' unfound') . ($near === $sel && $sel ? ' on' : '') . ($isMe ? ' here' : '') . (isset($onRoute[$id]) ? ' onroute' : '') . ($id === (int)$M['at'] ? ' at' : '');
        $g = '<g class="' . $cls . '" data-stop="' . $near . '" data-id="' . $id . '" transform="translate(' . (int)$s['x'] . ' ' . (int)$s['y'] . ')">'
            . ($isMe ? '<g aria-current="location"><g class="ms"><title>' . e($label) . ' (you are here)</title>' . $inner . '</g></g>'
                : '<a href="' . e(map2_near_url($rid, $near, $id)) . '" aria-label="' . e($label) . '"><g class="ms">' . $inner . '</g></a>')
            . '</g>';
        if ($isMe) $top .= $g; else $svg .= $g;
    }
    // stops, the town and the exits (over the places)
    $sideRot = ['E' => 0, 'S' => 90, 'W' => 180, 'N' => 270];
    foreach ($S as $id => $s) {
        if ($s['type'] === 'off') continue;
        $x = (int)$s['x']; $y = (int)$s['y']; $isMe = $id === $here; $isSel = $id === $sel;
        if ($s['type'] === 'far') {
            $nm = (string)$s['farname'];
            [$lx, $ly, $anc] = ['E' => [-14, 4, 'end'], 'W' => [14, 4, 'start'], 'N' => [0, 22, 'middle'], 'S' => [0, -14, 'middle']][$s['side']] ?? [0, 22, 'middle'];
            $w = mb_strlen($nm) * 7.8 * 0.59 + 8; $rx = $anc === 'end' ? $lx - $w : ($anc === 'start' ? $lx : $lx - $w / 2);
            $inner = '<circle class="hit" r="24" fill="#ffffff" fill-opacity="0"/><circle r="9" fill="#0e0f09" stroke="#f0c85a" stroke-width="2"/>'
                . '<text y="4.5" text-anchor="middle" font-size="12" font-weight="700" fill="#f0c85a" transform="rotate(' . ($sideRot[$s['side']] ?? 0) . ')">➜</text>'
                . '<g class="plate"><rect x="' . round($rx, 1) . '" y="' . ($ly - 7.5) . '" width="' . round($w, 1) . '" height="11" rx="2" fill="#0e0f09" fill-opacity="0.88"/>'
                . '<text x="' . $lx . '" y="' . $ly . '" text-anchor="' . $anc . '" font-size="7.8" font-weight="700" fill="#f4ead0">' . e($nm) . '</text></g>';
            $svg .= '<g class="rmp mv2-exit" transform="translate(' . $x . ' ' . $y . ')"><a href="' . e(url('world.php?go=' . $id . '#gopanel')) . '" aria-label="' . e('Road on to ' . $nm) . '"><g class="ms">' . $inner . '</g></a></g>';
            continue;
        }
        $isTown = $s['type'] === 'town';
        $seen = $M['seen'][$id];
        $list = $M['groups'][$id] ?? [];
        $nf = 0; foreach ($list as $pid) if ($M['seen'][$pid]) $nf++;
        $nm = $seen ? (string)$s['loc']['name'] : '';
        $inner = '<circle class="hit" r="24" fill="#ffffff" fill-opacity="0"/>'
            . ($isSel ? '<circle r="' . ($isTown ? 12 : 10.5) . '" fill="none" stroke="#ffe38a" stroke-width="2.4"/>' : '')
            . (isset($onRoute[$id]) && !$isMe ? '<circle class="onroute" r="' . ($isTown ? 12 : 10) . '" fill="none" stroke="#e8a317" stroke-width="3"/>' : '')
            . '<circle class="dot" r="' . ($isTown ? 8.4 : 6.6) . '" fill="' . ($isTown ? '#f0c85a' : ($seen ? '#f4ead0' : '#4a3626')) . '" stroke="' . ($isSel ? '#ffe38a' : '#14110a') . '" stroke-width="' . ($isSel ? 2.4 : 1.6) . '"/>'
            . (!$seen ? '<text y="2.6" text-anchor="middle" font-size="7">❔</text>' : '')
            . (isset($M['plots'][$id]) ? '<text x="8" y="-5" text-anchor="middle" font-size="9">' . ($id === $M['home'] ? '🏡' : '🌱') . '</text>' : '')
            . (isset($M['pp'][$id]) && !$isMe ? '<text x="8" y="9" text-anchor="middle" font-size="9"><title>A Puzzle Pal waits here</title>🧩</text>' : '')
            . ($nm !== '' && ($isTown || $list || $isSel) ? map2_plate(max(38 - $x, min($W - 38 - $x, 0)), -12.6, $nm, 7.8, $isSel ? '#ffe38a' : '#f4ead0') : '')
            . ($isMe ? $hat : '');
        $label = $nm !== '' ? $nm : 'A stop on the road you have not visited yet';
        if ($list) $label .= ', ' . count($list) . ' ' . (count($list) === 1 ? 'place' : 'places') . ' off the road, ' . $nf . ' found';
        $cls = 'rmp mv2-stop' . ($isTown ? ' k-town' : '') . ($seen ? '' : ' new') . ($isSel ? ' on' : '') . ($isMe ? ' here' : '');
        $href = $list ? map2_near_url($rid, $id) : url('world.php?go=' . $id . '#gopanel');
        $g = '<g class="' . $cls . '"' . ($list ? ' data-stop="' . $id . '"' : '') . ' transform="translate(' . $x . ' ' . $y . ')">'
            . ($isMe && !$list ? '<g aria-current="location"><g class="ms"><title>' . e($label) . ' (you are here)</title>' . $inner . '</g></g>'
                : '<a href="' . e($href) . '" aria-label="' . e($label . ($isMe ? ' (you are here)' : '')) . '"' . ($isMe ? ' aria-current="location"' : '') . '><g class="ms">' . $inner . '</g></a>')
            . '</g>';
        if ($isMe) $top .= $g; else $svg .= $g;
    }
    return $svg . $top . '</svg>';
}

/** One role tag ('' when tags are off, the place is not found, or it has no role). */
function map2_role_tag(array $M, int $id): string
{
    $role = (string)($M['L']['slots'][$id]['role'] ?? '');
    if (!$M['tags'] || !$M['seen'][$id] || $role === '') return '';
    return $role === 'main' ? ' <span class="tag">Main line</span>' : ' <span class="tag alt">Side quest</span>';
}

/** The bottom sheet: one group of rows per stop with places, all hidden but the selected one. */
function map2_sheet_html(array $M): string
{
    $L = $M['L']; $S = $L['slots']; $sel = (int)$M['sel']; $code = e($M['code']);
    $rows = '';
    $t1 = 'Places off the road'; $t2 = 'Tap a stop or a place';
    foreach ($M['groups'] as $sid => $list) {
        $stop = $S[$sid];
        $snm = map2_stop_name($M, $sid);
        $nf = 0; foreach ($list as $pid) if ($M['seen'][$pid]) $nf++;
        $g1 = $snm !== '' ? 'Near ' . $snm : 'Near a stop you have not visited';
        $g2 = $nf . ' found, ' . (count($list) - $nf) . ' not found yet';
        if ($sid === $sel) { $t1 = $g1; $t2 = $g2; }
        $isHere = $sid === (int)$M['here'];
        $r = '<li class="mv2-row stop" id="mv2-r-' . $sid . '"><span class="mv2-ico mv2-dot' . ($stop['type'] === 'town' ? ' town' : '') . '" aria-hidden="true"></span>'
            . '<span class="mv2-rt"><b>' . e($snm !== '' ? $snm : 'A stop you have not visited yet') . '</b><small>' . ($stop['type'] === 'town' ? 'Town' : 'Stop on the road') . map2_role_tag($M, $sid) . '</small></span>'
            . ($isHere ? '<span class="chip">You are here</span>' : '<a class="btn small mv2-go" href="' . e(url('world.php?go=' . $sid . '#gopanel')) . '" aria-label="' . e('Go to ' . ($snm !== '' ? $snm : 'this stop')) . '">Go</a>') . '</li>';
        foreach ($list as $pid) {
            $p = $S[$pid]; $f = $M['seen'][$pid]; $k = isset(MAPV2_GLYPH[$p['kind']]) ? (string)$p['kind'] : 'village';
            $at = $pid === (int)$M['at'] ? ' at' : '';
            $where = $snm !== '' ? $snm : 'the stop';
            if ($f) {
                $nm = (string)$p['loc']['name'];
                $r .= '<li class="mv2-row found' . $at . '" id="mv2-r-' . $pid . '">' . map2_row_icon($k, true)
                    . '<span class="mv2-rt"><b>' . e($nm) . '</b><small>' . e((MAPV2_KIND_WORD[$k] ?? 'Place') . ' · off the road from ' . $where) . map2_role_tag($M, $pid) . (isset($M['ruins'][$pid]) ? ' 🏚️' : '') . '</small></span>'
                    . ($pid === (int)$M['here'] ? '<span class="chip">You are here</span>' : '<a class="btn small mv2-go" href="' . e(url('world.php?go=' . $pid . '#gopanel')) . '" aria-label="' . e('Go to ' . $nm) . '">Go</a>') . '</li>';
            } else {
                $r .= '<li class="mv2-row unfound' . $at . '" id="mv2-r-' . $pid . '">' . map2_row_icon($k, false)
                    . '<span class="mv2-rt"><b>A place not found yet</b><small>' . e('Wander off the road near ' . $where . ' to find it') . '</small></span><span class="chip">?</span></li>';
            }
        }
        $rows .= '<ul class="mv2-grp" data-stop="' . $sid . '" data-t1="' . e($g1) . '" data-t2="' . e($g2) . '"' . ($sid === $sel ? '' : ' hidden') . '>' . $r . '</ul>';
    }
    return '<section class="mv2-sheet open" aria-label="Places near the chosen stop">'
        . '<button type="button" class="mv2-hd" aria-expanded="true" aria-controls="mv2-rows-' . $code . '"><span><b class="mv2-t1" aria-live="polite">' . e($t1) . '</b><small class="mv2-t2">' . e($t2) . '</small></span><span class="mv2-ch">Hide</span></button>'
        . '<div class="mv2-rows" id="mv2-rows-' . $code . '">' . $rows . '</div></section>';
}

/** The list of stops with places, most places first. */
function map2_stops_html(array $M): string
{
    $g = $M['groups'];
    uksort($g, fn($a, $b) => [count($M['groups'][$b]), $a] <=> [count($M['groups'][$a]), $b]);
    $h = '';
    foreach ($g as $sid => $list) {
        $nf = 0; foreach ($list as $pid) if ($M['seen'][$pid]) $nf++;
        $nm = map2_stop_name($M, $sid);
        $h .= '<a class="mv2-stopl" href="' . e(map2_near_url((int)$M['rid'], $sid)) . '" data-stop="' . $sid . '"' . ($sid === (int)$M['sel'] ? ' aria-current="true"' : '') . '>'
            . '<span>' . e($nm !== '' ? $nm : 'A stop you have not visited yet') . '</span><span class="chip">' . $nf . '/' . count($list) . ' found</span></a>';
    }
    return $h === '' ? '' : '<nav class="mv2-stops" aria-label="Stops with places off the road"><h4>Stops with places off the road</h4>' . $h . '</nav>';
}

/** The v2 region map widget (map, controls, bottom sheet, stop list), or '' when this region is not on v2. */
function region_map_block(array $u, int $regionId, int $selId = 0, bool $focus = false, int $nearId = 0, int $atId = 0): string
{
    if (!map_v2_on()) return '';
    $M = map2_model($u, $regionId, $selId, $nearId, $atId);
    if (!$M) return '';
    $S = $M['L']['slots'];
    $h = $S[$M['here']] ?? $S[$M['L']['town']];
    $legend = '';
    foreach (MAPV2_KIND_WORD as $k => $w) $legend .= '<li>' . map2_row_icon($k, true) . ' ' . $w . '</li>';
    $legend .= '<li><span class="mv2-key root" aria-hidden="true"></span> root to a place you have found</li><li><span class="mv2-key root un" aria-hidden="true"></span> not found yet</li><li>❔ not visited</li><li>🎩 you</li>';
    return '<div class="mv2" data-region="' . e($M['code']) . '" data-lv="' . e(rl_spread_ver()) . '" data-sel="' . (int)$M['sel'] . '" data-here="' . (int)$h['x'] . ' ' . (int)$h['y'] . '"' . ($focus ? ' data-focus="1"' : '') . '>'
        . '<div class="mv2-vp" tabindex="0" role="group" aria-label="' . e('Map of ' . $M['reg']['gnomish_name'] . '. Drag to look around, plus and minus to zoom.') . '">'
        . region_map2_svg($M)
        . '<div class="mv2-ctl" hidden><button type="button" class="btn small" data-z="in" aria-label="Zoom in">＋</button><button type="button" class="btn small" data-z="out" aria-label="Zoom out">−</button><button type="button" class="btn small alt" data-z="fit" aria-label="Fit the whole map">Fit</button></div>'
        . map2_sheet_html($M)
        . '</div>'
        . map2_stops_html($M)
        . '<ul class="maplegend mv2-legend" aria-label="Map key">' . $legend . '</ul>'
        . '</div>';
}

// ======================= checks of the spread (tools/map_v2/spread_build.php, tests/map_v2.php) =======================

const MAPV2_GAP_PLACES = 32;     // two off-road places (44 px tap targets at 1.4 px per unit)
const MAPV2_GAP_OWN_STOP = 20;   // a place and its own stop
const MAPV2_GAP_STOP = 24;       // a place and any other stop, town or exit
const MAPV2_GAP_ROAD = 10;       // a place and a road segment it does not end on
const MAPV2_ROOT_MAX = 170;      // the longest root (chord). The plan said 140; the planners' floors need 162 (NA Poppyburrow root), so the cap sits just above what ships

/** Distance from a point to a segment. */
function map2_seg_dist(array $p, array $a, array $b): float
{
    $vx = $b[0] - $a[0]; $vy = $b[1] - $a[1]; $l2 = $vx * $vx + $vy * $vy;
    $t = $l2 > 0 ? max(0.0, min(1.0, (($p[0] - $a[0]) * $vx + ($p[1] - $a[1]) * $vy) / $l2)) : 0.0;
    return hypot($p[0] - ($a[0] + $vx * $t), $p[1] - ($a[1] + $vy * $t));
}

/**
 * The rules of the shipped spread (proposal 8.2) for one region: $spread = [id => [x, y]] against the v1 layout $L1.
 * → ['bad' => [problem text ...], 'min' => [rule => smallest value seen], 'side' => [ids whose root changes side], 'roots' => n, 'off' => n]
 */
function rl_spread_problems(array $L1, array $spread): array
{
    $bad = []; $min = ['places' => INF, 'own_stop' => INF, 'stop' => INF, 'road' => INF]; $longest = 0.0;
    $off = []; foreach ($L1['slots'] as $id => $s) if ($s['type'] === 'off') $off[(int)$id] = $s;
    foreach ($spread as $id => $p) if (!isset($off[(int)$id])) $bad[] = "$id is not an off-road slot";
    foreach ($off as $id => $s) if (!isset($spread[$id])) $bad[] = "$id ({$s['loc']['name']}) has no spread point";
    foreach ($spread as $id => $p) if ($p[0] < 12 || $p[0] > (int)$L1['w'] - 12 || $p[1] < 12 || $p[1] > (int)$L1['h'] - 12) $bad[] = "$id is outside the frame (" . implode(',', $p) . ')';
    $L2 = rl_apply_spread($L1, $spread);
    $S = $L2['slots'];
    $ids = array_keys($off);
    foreach ($ids as $i => $a) {
        $pa = [$S[$a]['x'], $S[$a]['y']];
        foreach (array_slice($ids, $i + 1) as $b) {
            $d = hypot($S[$b]['x'] - $pa[0], $S[$b]['y'] - $pa[1]); $min['places'] = min($min['places'], $d);
            if ($d < MAPV2_GAP_PLACES) $bad[] = "$a and $b are " . round($d, 1) . ' apart (< ' . MAPV2_GAP_PLACES . ')';
        }
        foreach ($S as $sid => $t) {
            if ($t['type'] === 'off') continue;
            $d = hypot($t['x'] - $pa[0], $t['y'] - $pa[1]);
            if ((int)$sid === (int)$S[$a]['near']) { $min['own_stop'] = min($min['own_stop'], $d); if ($d < MAPV2_GAP_OWN_STOP) $bad[] = "$a is " . round($d, 1) . " from its stop $sid"; }
            else { $min['stop'] = min($min['stop'], $d); if ($d < MAPV2_GAP_STOP) $bad[] = "$a is " . round($d, 1) . " from stop $sid"; }
        }
        foreach ($L2['roads'] as $rd) for ($k = 1; $k < count($rd['nodes']); $k++) {
            $d = map2_seg_dist($pa, $rd['pts'][$k - 1], $rd['pts'][$k]);
            $min['road'] = min($min['road'], $d);
            if ($d < MAPV2_GAP_ROAD) $bad[] = "$a sits " . round($d, 1) . " from road {$rd['name']} ({$rd['nodes'][$k - 1]}-{$rd['nodes'][$k]})";
        }
    }
    $side = [];
    foreach ($L2['trails'] as $t) {
        $longest = max($longest, (float)$t['root']['len']);
        if ($t['root']['len'] > MAPV2_ROOT_MAX) $bad[] = "root {$t['from']}->{$t['to']} is {$t['root']['len']} long (> " . MAPV2_ROOT_MAX . ')';
        if ($t['bow2'] !== $t['bow']) $side[] = (int)$t['to'];
    }
    $min['root_longest'] = $longest;
    return ['bad' => $bad, 'min' => array_map(fn($v) => is_infinite($v) ? null : round($v, 1), $min), 'side' => $side, 'roots' => count($L2['trails']), 'off' => count($off)];
}

/** 2.8.96: why Map v2 is (or is not) showing on this site, as plain lines for Admin > Settings. */
function map_v2_report(): array
{
    require_once __DIR__ . '/scene.php';
    $o = [];
    $o[] = 'Site version ' . APP_VERSION . '. Map v2 setting: ' . (map_v2_on() ? 'on' : 'OFF') . '. World v2 setting: ' . (world_v2_on() ? 'on' : 'OFF') . '.';
    $wp = scene_path('map2', 'world') !== '';
    $o[] = 'World map: picture map2-world.png ' . ($wp ? 'found' : 'MISSING') . ', layout world_v2_layout.json ' . (world2_layout() ? 'ok' : 'MISSING or bad') . ' -> ' . (map_v2_world_on() ? 'new map ON' : 'old map');
    $all = rl_spread_all();
    $o[] = 'Region data region_spread.json: ' . (isset($all['_meta']) ? 'found (' . rl_spread_ver() . ')' : 'MISSING');
    foreach (array_keys(REGION_MAP) as $code) {
        $L = function_exists('region_layout') ? region_layout($code, false) : null;
        $pic = scene_path('map2', $code) !== '';
        $sig = $L && ($all['_meta']['sig'][$code] ?? '') === rl_stop_sig($L);
        $o[] = $code . ': picture ' . ($pic ? 'found' : 'MISSING') . ', roads ' . ($sig ? 'match' : 'DO NOT match') . ' -> ' . (map_v2_region_on($code) ? 'new map ON' : 'old map');
    }
    return $o;
}
