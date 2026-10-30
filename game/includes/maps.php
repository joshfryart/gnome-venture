<?php
declare(strict_types=1);

/**
 * Maps (v0.7.38): a drawn world map of the 14 regions with their roads, a region panel listing its town, roads and
 * the places you've found, and a journey map for walks and exploring. All inline SVG (no images, no inline styles:
 * colours are SVG attributes, which the security policy allows).
 */

require_once __DIR__ . '/roads.php';
require_once __DIR__ . '/items.php';   // v1.5.2: ph_img (placeholders)
require_once __DIR__ . '/adventure.php';
require_once __DIR__ . '/world.php';
require_once __DIR__ . '/climate.php';   // v0.8.9
require_once __DIR__ . '/maps_myc.php';   // v1.6.0: mycelium maps (admin setting map_style; 'classic' keeps the functions below)

// Region code => [x, y, land colour, blob radius] on a 1000 × 560 map, roughly where they sit on Earth.
const REGION_MAP = [
    'NA'   => [215, 140, '#8fbf6a', 70], 'CA'  => [190, 262, '#cdb65c', 38], 'CB'  => [318, 238, '#74c6b4', 30, 't'],
    'SA'   => [305, 390, '#4f9a4a', 62], 'NWE' => [462, 112, '#9cc58a', 42], 'SE'  => [505, 195, '#d8c27a', 36],
    'EE'   => [612, 105, '#b8c98a', 48], 'MENA' => [560, 245, '#e2c48a', 52], 'WCA' => [490, 315, '#5f9e48', 44],
    'ESA'  => [590, 395, '#c8b062', 50], 'CSA' => [700, 225, '#c79a62', 58], 'EA'  => [830, 170, '#e8a9bb', 55],
    'SEA'  => [800, 300, '#57a07a', 44], 'OC'  => [885, 440, '#e6c27a', 52],
];
const HUB_MAP = [395, 470];   // Mossbottom: a little mushroom island, reachable from anywhere

/** A soft, blobby island for a region: a few overlapping circles, the same shape every time. */
function map_blob(string $code, int $x, int $y, int $r, string $fill): string
{
    $seed = crc32($code);
    $out = '<circle cx="' . $x . '" cy="' . $y . '" r="' . $r . '" fill="' . $fill . '"/>';
    for ($i = 0; $i < 4; $i++) {
        $a = (($seed >> ($i * 6)) & 63) / 63 * 6.283;
        $d = $r * (0.45 + (($seed >> ($i * 3 + 7)) & 7) / 20);
        $rr = (int)round($r * (0.5 + (($seed >> ($i * 5 + 2)) & 7) / 25));
        $out .= '<circle cx="' . (int)round($x + cos($a) * $d) . '" cy="' . (int)round($y + sin($a) * $d * 0.8) . '" r="' . $rr . '" fill="' . $fill . '"/>';
    }
    return $out;
}

/** The bend of a road between two map points: the control point of its curve (the same for drawing and placing stops). */
function road_ctrl(array $a, array $b): array
{
    return [($a[0] + $b[0]) / 2 + ($b[1] - $a[1]) * 0.15, ($a[1] + $b[1]) / 2 - ($b[0] - $a[0]) * 0.15];
}

/**
 * v0.7.52: where every place sits on the world map. Towns at their region's centre, road villages spaced along the
 * road's curve, off-road places scattered round their region (the same spot every time). [location id => [x, y]]
 */
function map_positions(): array
{
    static $pos = null;
    if ($pos !== null) return $pos;
    $pos = [];
    $roadDir = [];
    $GLOBALS['gv_side_of'] = [];
    $codeOf = [];
    foreach (q('SELECT id, code FROM regions')->fetchAll() as $r) $codeOf[(int)$r['id']] = $r['code'];
    foreach (q('SELECT id, kind, region_id, slug FROM locations')->fetchAll() as $l) {
        $id = (int)$l['id'];
        if ($l['kind'] === 'hub') { $pos[$id] = HUB_MAP; continue; }
        $code = $codeOf[(int)$l['region_id']] ?? '';
        if (!isset(REGION_MAP[$code])) continue;
        [$x, $y, , $r] = REGION_MAP[$code];
        if ($l['kind'] === 'market') { $pos[$id] = [$x, $y]; continue; }
        $h = crc32((string)$l['slug']);
        $a = ($h & 1023) / 1023 * 6.283;
        $d = $r * (0.4 + (($h >> 10) & 255) / 255 * 0.5);
        $pos[$id] = [(int)round($x + cos($a) * $d), (int)round($y + sin($a) * $d * 0.8)];
    }
    foreach (q('SELECT nodes FROM roads')->fetchAll() as $rd) {
        $nodes = array_map('intval', json_decode((string)$rd['nodes'], true) ?: []);
        $n = count($nodes);
        if ($n < 3 || !isset($pos[$nodes[0]], $pos[$nodes[$n - 1]])) continue;
        $a = $pos[$nodes[0]];
        $b = $pos[$nodes[$n - 1]];
        [$mx, $my] = road_ctrl($a, $b);
        for ($i = 1; $i < $n - 1; $i++) {
            $t = $i / ($n - 1);
            $pos[$nodes[$i]] = [(int)round((1 - $t) ** 2 * $a[0] + 2 * (1 - $t) * $t * $mx + $t * $t * $b[0]),
                                (int)round((1 - $t) ** 2 * $a[1] + 2 * (1 - $t) * $t * $my + $t * $t * $b[1])];
        }
        for ($i = 1; $i < $n - 1; $i++) {   // which way the road runs at each stop (for placing side paths)
            $roadDir[$nodes[$i]] = [$pos[$nodes[$i + 1]][0] - $pos[$nodes[$i - 1]][0], $pos[$nodes[$i + 1]][1] - $pos[$nodes[$i - 1]][1]];
        }
    }
    // v0.7.53: off-road places sit beside the road stop their side path leaves from, fanned out either side of the road
    $kids = [];
    foreach (q("SELECT a_id, b_id FROM routes WHERE kind = 'side' ORDER BY id")->fetchAll() as $rt) {
        [$a, $b] = [(int)$rt['a_id'], (int)$rt['b_id']];
        if (isset($roadDir[$a]) && !isset($roadDir[$b])) $kids[$a][] = $b;
        elseif (isset($roadDir[$b]) && !isset($roadDir[$a])) $kids[$b][] = $a;
    }
    foreach ($kids as $anchor => $list) {
        if (!isset($pos[$anchor])) continue;
        [$dx, $dy] = $roadDir[$anchor];
        $len = max(1.0, sqrt($dx * $dx + $dy * $dy));
        $base = atan2($dx / $len, -$dy / $len);   // straight out from the road
        foreach ($list as $k => $id) {
            $ring = intdiv($k, 2);
            $ang = $base + ($k % 2 ? M_PI : 0) + ($ring ? ($ring % 2 ? 0.55 : -0.55) * ceil($ring / 2) : 0);
            $d = 17 + $ring * 6;
            $pos[$id] = [(int)round($pos[$anchor][0] + cos($ang) * $d), (int)round($pos[$anchor][1] + sin($ang) * $d)];
            $GLOBALS['gv_side_of'][$id] = $anchor;
        }
    }
    return $pos;
}

/** Compass direction from one place to another, by where they sit on the map ('' if unknown or the same spot). */
function compass_between(int $fromId, int $toId): string
{
    $pos = map_positions();
    if (!isset($pos[$fromId], $pos[$toId])) return '';
    $dx = $pos[$toId][0] - $pos[$fromId][0];   // east-positive
    $dy = $pos[$fromId][1] - $pos[$toId][1];   // north-positive (screen y is flipped)
    if ($dx === 0 && $dy === 0) return '';
    $deg = rad2deg(atan2($dx, $dy));
    if ($deg < 0) $deg += 360;
    return ['N', 'NE', 'E', 'SE', 'S', 'SW', 'W', 'NW'][(int)round($deg / 45) % 8];
}

/** Where the gnome is on the map right now: their place, or part way along the stretch they're walking. */
function player_map_pos(array $u): ?array
{
    $pos = map_positions();
    $exp = active_expedition((int)$u['id']);
    if ($exp && ($exp['kind'] ?? 'walk') === 'walk' && isset($pos[(int)$exp['from_id']], $pos[(int)$exp['to_id']])) {
        $a = $pos[(int)$exp['from_id']];
        $b = $pos[(int)$exp['to_id']];
        $t = min((int)$exp['step'], (int)$exp['steps_total']) / (max(1, (int)$exp['steps_total']) + 1);
        return [(int)round($a[0] + ($b[0] - $a[0]) * $t), (int)round($a[1] + ($b[1] - $a[1]) * $t)];
    }
    $id = $exp ? (int)$exp['from_id'] : (int)player_node($u)['id'];
    return $pos[$id] ?? null;
}

/** The NPCs this gnome knows (Acquaintance or better), with where they are right now. */
function known_npcs(int $uid): array
{
    require_once __DIR__ . '/friends.php';
    require_once __DIR__ . '/npc_life.php';
    $out = [];
    $rows = q('SELECT n.*, f.points FROM npc_friends f JOIN npcs n ON n.id = f.npc_id
               WHERE f.user_id = ? AND f.points >= ' . (int)FRIEND_LEVELS[1][0] . ' AND n.active = 1 ORDER BY f.points DESC, n.name', [$uid])->fetchAll();
    foreach ($rows as $n) {
        $n['now'] = npc_now($n);
        $n['home'] = $n['home_location_id'] ? q_one('SELECT l.name, l.region FROM locations l WHERE l.id = ?', [$n['home_location_id']]) : null;
        $out[] = $n;
    }
    return $out;
}

/** One map marker: drawn round (0,0), moved to (x,y), and kept a readable size when zoomed (class ms). */
function map_mark(int $x, int $y, string $inner, string $cls = '', string $attrs = ''): string
{
    return '<g class="mk ' . $cls . '" transform="translate(' . $x . ' ' . $y . ')"' . $attrs . '><g class="ms">' . $inner . '</g></g>';
}

/** Text for the map (white halo so it reads over land and sea). $o: anchor, bold, fill, x. */
function map_text(string $t, int $y, int $size, array $o = []): string
{
    return '<text' . (isset($o['x']) ? ' x="' . (int)$o['x'] . '"' : '') . ' y="' . $y . '" text-anchor="' . ($o['anchor'] ?? 'middle') . '" font-size="' . $size . '"'
        . (($o['bold'] ?? true) ? ' font-weight="bold"' : '') . ' fill="' . ($o['fill'] ?? '#2f2a1f') . '" stroke="#fffaf0" stroke-width="3" paint-order="stroke">' . $t . '</text>';
}

/** The underground world picture (assets/img/scenes/map-world.png, its tunnels drawn along the real roads), or '' if missing. */
function world_art_path(): string
{
    require_once __DIR__ . '/scene.php';
    return scene_path('map', 'world');
}

/** A region's map picture (assets/img/scenes/map-CODE.png, drawn to its fixed layout), or '' if missing or unknown. */
function region_art_path(int $regionId): string
{
    require_once __DIR__ . '/scene.php';
    $code = (string)(q_one('SELECT code FROM regions WHERE id = ?', [$regionId])['code'] ?? '');
    return $code === '' ? '' : scene_path('map', $code);
}

/**
 * The world map (v0.7.53: zoomable). Everything is sent at once in three layers of detail: lod1 (whole world),
 * lod2 (road stops and found places), lod3 (names up close); site.js zooms the view and shows/hides the layers.
 * $sel = the region id being looked at (highlighted).
 */
function world_map_svg(array $u, ?int $sel = null): string
{
    $art = world_art_path();   // the underground pixel-art world: the default world map whenever the picture is there
    if ($art === '' && myc_on()) return myc_world_svg($u, $sel);   // v1.6.0: mycelium style (map_style = classic keeps the drawing below)
    $regions = [];
    foreach (q('SELECT * FROM regions')->fetchAll() as $r) $regions[$r['code']] = $r;
    $uid = (int)$u['id'];
    $pos = map_positions();
    $sideOf = $GLOBALS['gv_side_of'] ?? [];
    $guides = guide_regions($uid);
    $been = visited_regions($uid);
    $lvl = (int)$u['level'];
    $walking = (bool)active_expedition($uid);
    $here = player_node($u);
    $go = [];   // places you can set off to from where you stand: id => [route id, steps]
    if (!$walking) foreach (visible_routes($u, (int)$here['id']) as $r) $go[(int)$r['to']['id']] = [(int)$r['id'], (int)$r['steps']];
    [$hx, $hy] = HUB_MAP;
    if ($art !== '') {   // the cavern picture (640x360 = 1000x560 units): its caverns, tunnels and Mossbottom replace the drawn sea and islands
        $svg = '<svg class="worldmap art" viewBox="0 0 1000 560" role="img" aria-label="Map of the Hollow">'
            . '<rect x="-2000" y="-2000" width="5000" height="4560" fill="#2a1a10"/>'
            . pixel_image($art, 0, 0, 1000, 560, '', '', 'none', 'mapart');
    } else {
        $svg = '<svg class="worldmap" viewBox="0 0 1000 560" role="img" aria-label="Map of the Hollow">'
            . '<rect x="-2000" y="-2000" width="5000" height="4560" fill="#a9d3e3"/>';
        for ($i = 1; $i < 7; $i++) $svg .= '<path d="M0 ' . ($i * 80) . ' Q250 ' . ($i * 80 - 12) . ' 500 ' . ($i * 80) . ' T1000 ' . ($i * 80) . '" stroke="#bfe0ec" stroke-width="2" fill="none"/>';
        foreach (REGION_MAP as $code => [$x, $y, $fill, $r]) {
            if (isset($regions[$code])) $svg .= map_blob($code, $x, $y, $r, $fill);
        }
        $svg .= map_blob('HUB', $hx, $hy, 26, '#9b8a6a');
    }
    // Roads, drawn from the roads themselves so the stops sit right on them
    $roads = q('SELECT name, nodes FROM roads')->fetchAll();
    foreach ($roads as $rd) {
        $nodes = array_map('intval', json_decode((string)$rd['nodes'], true) ?: []);
        if (count($nodes) < 2 || !isset($pos[$nodes[0]], $pos[end($nodes)])) continue;
        $a = $pos[$nodes[0]];
        $b = $pos[end($nodes)];
        [$mx, $my] = road_ctrl($a, $b);
        $d = 'M' . $a[0] . ' ' . $a[1] . ' Q' . (int)$mx . ' ' . (int)$my . ' ' . $b[0] . ' ' . $b[1];
        if ($art !== '') $svg .= '<path class="roadcase" d="' . $d . '" stroke="#2a1a10" stroke-width="5" fill="none" stroke-linecap="round" vector-effect="non-scaling-stroke"/>';   // dark casing under the cream road
        $svg .= '<path class="road" d="' . $d . '" stroke="#8a6a46" stroke-width="3" stroke-dasharray="7 6" fill="none" stroke-linecap="round" vector-effect="non-scaling-stroke"><title>' . e($rd['name']) . '</title></path>';
    }
    // Which places you've found (same as place_known(), in two queries)
    $keys = array_fill_keys(q('SELECT e.unlock_key FROM user_encyclopedia ue JOIN encyclopedia_entries e ON e.id = ue.entry_id WHERE ue.user_id = ?', [$uid])->fetchAll(PDO::FETCH_COLUMN), true);
    $plotV = array_fill_keys(array_map('intval', q('SELECT village_id FROM plots WHERE user_id = ? AND village_id IS NOT NULL', [$uid])->fetchAll(PDO::FETCH_COLUMN)), true);
    $onRoad = [];
    foreach ($roads as $rd) foreach (array_slice(json_decode((string)$rd['nodes'], true) ?: [], 1, -1) as $id) $onRoad[(int)$id] = true;
    $places = [];
    foreach (q("SELECT l.id, l.name, l.slug, l.kind, l.region, l.landscape, (SELECT kind FROM landmarks WHERE location_id = l.id ORDER BY id LIMIT 1) AS lmkind,
        (SELECT COUNT(*) FROM landmarks m WHERE m.location_id = l.id AND m.kind IN ('haven', 'wonder', 'delve') AND m.ruined = 1
           AND NOT EXISTS (SELECT 1 FROM landmark_rebuilds b WHERE b.landmark_id = m.id AND b.user_id = ?)) AS ruin
        FROM locations l WHERE l.kind NOT IN ('market', 'hub')", [$uid])->fetchAll() as $l) {   // v0.7.78: ruin = a haven, wonder or delve still in ruins for this gnome (v0.7.88)
        $id = (int)$l['id'];
        if (!isset($pos[$id])) continue;
        $l['known'] = isset($plotV[$id]) || isset($keys[($l['kind'] === 'village' ? 'village:' : 'landmark:') . $l['slug']]);
        if (!$l['known'] && !isset($onRoad[$id])) continue;   // hidden off-road places stay hidden
        $places[$id] = $l;
    }
    // Side trails to the places you've found (layer 2)
    $trails = '';
    foreach ($places as $id => $l) {
        if (!isset($onRoad[$id]) && isset($sideOf[$id], $pos[$sideOf[$id]])) {
            $trails .= '<path d="M' . $pos[$sideOf[$id]][0] . ' ' . $pos[$sideOf[$id]][1] . ' L' . $pos[$id][0] . ' ' . $pos[$id][1] . '" stroke="#8a6a46" stroke-width="1.5" stroke-dasharray="2 3" fill="none" vector-effect="non-scaling-stroke"/>';
        }
    }
    $svg .= '<g class="lod2">' . $trails . '</g>';
    // Regions: tap for the panel
    foreach (REGION_MAP as $code => $p) {
        [$x, $y, , $r] = $p;
        if (!isset($regions[$code])) continue;
        $reg = $regions[$code];
        $top = ($p[4] ?? 'b') === 't';
        $rid = (int)$reg['id'];
        $isSel = $sel === $rid;
        $open = can_fast_travel($u, $rid) || in_array($rid, $been, true);
        $min = max(1, (int)$reg['min_level']);   // v0.7.43: recommended level, and a lock until you've walked there
        $town = q_one("SELECT name FROM locations WHERE region_id = ? AND kind = 'market' ORDER BY id LIMIT 1", [$rid]);
        $ny = $top ? -$r - 10 : 26;
        $lv = map_text(!$open && $min <= $lvl ? '🥾 not yet visited' : ($open ? '' : '🔒 ') . 'Lv ' . $min, $top ? $ny - 17 : $ny + 17, 12, ['fill' => $min > $lvl ? '#9b2c1f' : '#3c5a2a']);
        $svg .= '<a class="region" href="' . e(url('world.php?tab=map&r=' . $rid . '#regionmap')) . '" aria-label="' . e($reg['gnomish_name']) . '">'   // v0.9.3: opens the region's own zoom map
            . '<title>' . e($reg['gnomish_name'] . ' (' . $reg['real_name'] . ')') . '</title>'
            . '<circle class="hit" cx="' . $x . '" cy="' . $y . '" r="' . ($r + 14) . '" fill="#ffffff" fill-opacity="0"/>'
            . '<circle cx="' . $x . '" cy="' . $y . '" r="' . ($r + 6) . '" fill="#ffffff" fill-opacity="' . ($isSel ? '0.35' : '0') . '" stroke="' . ($isSel ? '#d9a520' : 'none') . '" stroke-width="4" vector-effect="non-scaling-stroke"/>'
            . (isset($GLOBALS['gv_seek_regions'][$rid]) ? '<circle class="seekglow" cx="' . $x . '" cy="' . $y . '" r="' . ($r + 12) . '" fill="#7bc96f" fill-opacity="0.18" stroke="#3f9a35" stroke-width="3" stroke-dasharray="6 4" vector-effect="non-scaling-stroke"/>' : '')   // v0.7.97: seeking
            . map_mark($x, $y, '<text y="8" text-anchor="middle" font-size="24"' . ($open ? '' : ' opacity="0.45"') . '>🏘️</text>'
                . map_text(e($reg['gnomish_name']), $ny, 15) . $lv
                . ($town ? '<g class="lod3">' . map_text(e($town['name']), $top ? $ny - 34 : $ny + 34, 11, ['bold' => false]) . '</g>' : '')
                . (in_array($rid, $guides, true) ? '<text x="-22" y="-14" text-anchor="middle" font-size="15">📗</text>' : ''))
            . '</a>';
    }
    // Every stop on the roads, and the off-road places you've found (layer 2, names in layer 3)
    $kindIcon = ['village' => '🏡', 'haven' => '🏕️', 'wonder' => '✨', 'lair' => '🐉', 'delve' => '🕳️'];
    $kindWord = ['village' => 'Village', 'haven' => 'Haven', 'wonder' => 'Wonder', 'lair' => 'Lair', 'delve' => 'Delve'];
    $kindFill = ['village' => '#f3e3b0', 'haven' => '#cfe7c4', 'wonder' => '#e9d4f2', 'lair' => '#f0b9a8', 'delve' => '#c9c0b0'];
    $dots = '';
    // v0.7.78: ruins you've found show 🏚️ (🔨 when you're repairing one)
    $mending = array_fill_keys(array_map('intval', q('SELECT m.location_id FROM landmark_repairs r JOIN landmarks m ON m.id = r.landmark_id WHERE r.user_id = ? AND r.done_at IS NULL AND r.dropped_at IS NULL', [$uid])->fetchAll(PDO::FETCH_COLUMN)), true);
    foreach ($places as $id => $l) {
        [$x, $y] = $pos[$id];
        $k = $l['kind'] === 'village' ? 'village' : (string)($l['lmkind'] ?: $l['kind']);
        $known = $l['known'];
        $ruin = $known && (int)$l['ruin'] > 0 ? (isset($mending[$id]) ? '🔨' : '🏚️') : '';   // v0.7.78
        $what = $known ? ($kindWord[$k] ?? 'Place') . (isset($onRoad[$id]) ? ' on the road' : ' off the road') . ' · ' . $l['region']
            . ($ruin === '🔨' ? ' · you’re repairing it' : ($ruin ? ' · in ruins: go there to take on the repair' : '')) : 'A stop on the road you haven’t visited yet';
        $attrs = ' data-place="' . $id . '" data-name="' . e($known ? $l['name'] : '???') . '" data-what="' . e($what) . '" data-go="' . e(url('world.php?go=' . $id . '#gopanel')) . '"'
            . (isset($go[$id]) ? ' data-route="' . $go[$id][0] . '" data-steps="' . $go[$id][1] . '"' : '')
            . ((int)$here['id'] === $id ? ' data-here="1"' : '');
        $dots .= map_mark($x, $y,
            '<circle r="' . ($known ? 6 : 4) . '" fill="' . ($known ? ($kindFill[$k] ?? '#fffaf0') : '#b8ab90') . '" stroke="#6b5232" stroke-width="' . ($known ? 2 : 1) . '"/>'
            . ($ruin ? '<text x="7" y="-5" text-anchor="middle" font-size="9">' . $ruin . '</text>' : '')
            . '<title>' . e($known ? $l['name'] . ' (' . $l['region'] . ')' . ($ruin ? ' · in ruins' : '') : 'A stop on the road, not visited yet') . '</title>'
            . '<g class="lod3">' . ($known ? '<text y="4" text-anchor="middle" font-size="8">' . ($kindIcon[$k] ?? '📍') . '</text>' . map_text(e(mb_strimwidth($l['name'], 0, 22, '…')), (int)$here['id'] === $id ? 27 : 17, 8, ['bold' => false])   // v1.4.2: clear of the 🎩 ring
                : '<text y="3" text-anchor="middle" font-size="6">❔</text>') . '</g>', 'place', $attrs);
    }
    $svg .= '<g class="lod2">' . $dots . '</g>';
    // Your gardens
    $homeV = (int)($u['home_village_id'] ?? 0);
    foreach (q('SELECT village_id, garden_name FROM plots WHERE user_id = ? AND village_id IS NOT NULL', [$uid])->fetchAll() as $g) {
        $vid = (int)$g['village_id'];
        if (!isset($pos[$vid])) continue;
        $svg .= map_mark($pos[$vid][0], $pos[$vid][1], '<text x="9" y="-7" text-anchor="middle" font-size="15"><title>' . e($g['garden_name'] ?: 'Your garden') . '</title>' . ($vid === $homeV ? '🏡' : '🌱') . '</text>'
            . '<g class="lod2">' . map_text(e($g['garden_name'] ?: 'Your garden'), -24, 9, ['x' => 9]) . '</g>', 'garden');
    }
    // v0.7.97: the nearest places for what you're seeking
    foreach (array_keys($GLOBALS['gv_seek_stops'] ?? []) as $sid) {
        if (!isset($pos[$sid])) continue;
        $svg .= map_mark($pos[$sid][0], $pos[$sid][1], '<text x="-9" y="-7" text-anchor="middle" font-size="15"><title>A place to find what you’re seeking</title>🎯</text>', 'seek');
    }
    // Folk you know, wherever they are right now
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
    // The hub
    $svg .= '<a href="' . e(url('town.php?hub=1')) . '" aria-label="Mossbottom hub"><title>Mossbottom: the hub, reachable from anywhere</title>'
        . map_mark($hx, $hy, '<text y="8" text-anchor="middle" font-size="28">🍄</text>' . map_text('Mossbottom', 46, 14)) . '</a>';
    // You, on top of everything
    $me = player_map_pos($u);
    if ($me) {
        $svg .= map_mark($me[0], $me[1], '<circle r="15" fill="#ffe66b" fill-opacity="0.55" stroke="#d9a520" stroke-width="3"><title>You are here</title></circle>'
            . '<text y="7" text-anchor="middle" font-size="20">🎩</text>', 'me');
    }
    $svg .= '</svg>';
    // Zoom buttons, the tap card and a hidden "set off" form (all used by site.js; without JavaScript the map works as before)
    return '<div class="mapzoom" data-me="' . ($me ? $me[0] . ',' . $me[1] : '500,280') . '">'
        . '<div class="mapctl" hidden><button type="button" class="btn small" data-z="in" aria-label="Zoom in">＋</button><button type="button" class="btn small" data-z="out" aria-label="Zoom out">−</button>'
        . '<button type="button" class="btn small alt" data-z="me" aria-label="Find me">🎩</button><button type="button" class="btn small alt" data-z="all" aria-label="Whole world">🌍</button></div>'
        . $svg
        . '<div class="mapcard box" hidden></div>'
        . '<form class="mapgo" method="post" action="' . e(url('adventure.php')) . '" hidden>' . csrf_field() . '<input type="hidden" name="do" value="start"><input type="hidden" name="route_id" value=""></form>'
        . '</div>';
}

/** v0.9.3: a point on a road's curve (the same curve the world map draws). */
function map_bez(array $a, array $c, array $b, float $t): array
{
    $m = 1 - $t;
    return [$m * $m * $a[0] + 2 * $m * $t * $c[0] + $t * $t * $b[0], $m * $m * $a[1] + 2 * $m * $t * $c[1] + $t * $t * $b[1]];
}

/**
 * v0.9.3: one region on its own, big enough for fingers. Its town, each road running out to the edge (where the
 * neighbouring region is named) with its villages along it, and the off-road places you've found.
 * Every place is a link (world.php?go=ID) with a 44px-ish tap target. No JavaScript needed.
 * v2.0.61: a fixed landscape 480 × 270 layout (region_layout(), region_layout.php): every place has one slot that never
 * moves, whoever is looking, so the region's map picture (assets/img/scenes/map-CODE.png, drawn from tools/map_layout.php)
 * lies under it. What you've found only shows / hides / restyles a slot. Labels are placed where they fit (below / above /
 * right / left), else shown when zoomed; small sites (haven, wonder, delve, lair) are icons, named when zoomed.
 * Markers sit in a .ms group that site.js scales (--zs) so they stay a readable size as the map zooms.
 * $selId = the place being looked at (world.php?go=ID), always named.
 */
function region_map_svg(array $u, int $regionId, int $selId = 0, bool $focus = false): string
{
    require_once __DIR__ . '/region_layout.php';
    require_once __DIR__ . '/scene.php';
    $reg = q_one('SELECT * FROM regions WHERE id = ?', [$regionId]);
    if (!$reg || !isset(REGION_MAP[$reg['code']])) return '';
    $L = region_layout((string)$reg['code']);
    if (!$L) return '';
    $uid = (int)$u['id'];
    $tid = (int)$L['town'];
    $hereId = (int)(player_node($u)['id'] ?? 0);
    $fill = REGION_MAP[$reg['code']][2];
    $homeV = (int)($u['home_village_id'] ?? 0);
    $plots = array_fill_keys(array_map('intval', q('SELECT village_id FROM plots WHERE user_id = ? AND village_id IS NOT NULL', [$uid])->fetchAll(PDO::FETCH_COLUMN)), true);
    $kindIcon = ['village' => '🏡', 'haven' => '🏕️', 'wonder' => '✨', 'lair' => '🐉', 'delve' => '🕳️'];
    // v1.4.2: one colour per kind of place: [fill, ring]
    $kindCol = ['town' => ['#f1e2c0', '#8a5a2b'], 'far' => ['#fff3c4', '#b08a2a'], 'village' => ['#fdf0c8', '#c9922e'], 'haven' => ['#d9efcf', '#3f8f3f'],
        'wonder' => ['#eadcf7', '#8456c4'], 'lair' => ['#f7d0c6', '#c0463a'], 'delve' => ['#e2dbcf', '#6e6253'], 'new' => ['#e7e3d8', '#8f8470']];
    // ruins, for this gnome (v0.7.88)
    $ruins = array_fill_keys(array_map('intval', q("SELECT DISTINCT m.location_id FROM landmarks m JOIN locations l ON l.id = m.location_id WHERE l.region_id = ? AND m.kind IN ('haven', 'wonder', 'delve') AND m.ruined = 1
        AND NOT EXISTS (SELECT 1 FROM landmark_rebuilds b WHERE b.landmark_id = m.id AND b.user_id = ?)", [$regionId, $uid])->fetchAll(PDO::FETCH_COLUMN)), true);
    // The slots this gnome sees: the town, every road stop (❔ until visited), the exits, and the off-road places they've found
    $items = [];
    foreach ($L['slots'] as $id => $s) {
        $seen = $s['type'] === 'far' || $s['type'] === 'town' || place_known($uid, $s['loc']);
        if ($s['type'] === 'off' && !$seen) continue;
        $items[$id] = ['x' => (float)$s['x'], 'y' => (float)$s['y'], 'r' => $s['r'], 'loc' => $s['loc'], 'type' => $s['type'], 'k' => $s['type'] === 'off' ? $s['kind'] : 'village',
            'side' => $s['side'], 'farname' => $s['farname'], 'seen' => $seen, 'anchor' => $s['anchor'], 'ruin' => isset($ruins[$id])];
    }
    $W = (int)$L['w']; $H = (int)$L['h'];
    $art = scene_path('map', (string)$reg['code']);

    $hereIt = $items[$hereId] ?? null;   // v2.0.84: $focus opens zoomed in on where you stand (site.js reads data-focus: x y zoom)
    $svg = '<svg class="regionmap' . ($art !== '' ? ' art' : '') . '" viewBox="0 0 ' . $W . ' ' . $H . '"' . ($focus && $hereIt ? ' data-focus="' . (int)$hereIt['x'] . ' ' . (int)$hereIt['y'] . ' 2.2"' : '') . ' role="group" aria-label="Map of ' . e($reg['gnomish_name']) . '">';
    if ($art !== '') {   // v2.0.61: the region's picture, drawn to this layout
        $svg .= '<rect class="rock" width="' . $W . '" height="' . $H . '" fill="#2a1a10"/>'
            . '<image class="mapart" href="' . e(url($art)) . '" x="0" y="0" width="' . $W . '" height="' . $H . '" preserveAspectRatio="none" image-rendering="pixelated"/>';
    } else {   // no picture yet: the drawn island round the fixed slots (convex hull, pushed out, corners rounded)
        $pts = [];
        foreach ($L['slots'] as $s) $pts[] = [(float)$s['x'], (float)$s['y']];
        usort($pts, fn($p, $q) => $p[0] <=> $q[0] ?: $p[1] <=> $q[1]);
        $cross = fn($o, $p, $q) => ($p[0] - $o[0]) * ($q[1] - $o[1]) - ($p[1] - $o[1]) * ($q[0] - $o[0]);
        $lower = []; $upper = [];
        foreach ($pts as $p) { while (count($lower) >= 2 && $cross($lower[count($lower) - 2], $lower[count($lower) - 1], $p) <= 0) array_pop($lower); $lower[] = $p; }
        foreach (array_reverse($pts) as $p) { while (count($upper) >= 2 && $cross($upper[count($upper) - 2], $upper[count($upper) - 1], $p) <= 0) array_pop($upper); $upper[] = $p; }
        $hull = array_merge(array_slice($lower, 0, -1), array_slice($upper, 0, -1));
        $cx = array_sum(array_column($hull, 0)) / max(1, count($hull)); $cy = array_sum(array_column($hull, 1)) / max(1, count($hull));
        $seed = crc32($reg['code']);
        $blob = function (float $grow) use ($hull, $cx, $cy, $seed): string {
            $v = [];
            foreach ($hull as $i => $p) {
                $dx = $p[0] - $cx; $dy = $p[1] - $cy; $d = max(1.0, hypot($dx, $dy));
                $g = $grow + (($seed >> ($i % 10 * 3)) & 7) * 2.0;
                $v[] = [$p[0] + $dx / $d * $g, $p[1] + $dy / $d * $g];
            }
            $n = count($v);
            if ($n < 3) return '';
            $m = fn($a, $b) => [($a[0] + $b[0]) / 2, ($a[1] + $b[1]) / 2];
            $d = 'M' . implode(' ', array_map('intval', $m($v[0], $v[1])));
            for ($i = 1; $i <= $n; $i++) {
                $p = $v[$i % $n]; $q = $v[($i + 1) % $n];
                $d .= ' Q' . (int)$p[0] . ' ' . (int)$p[1] . ' ' . implode(' ', array_map('intval', $m($p, $q)));
            }
            return $d . ' Z';
        };
        $svg .= '<rect class="sea" width="' . $W . '" height="' . $H . '" fill="#a9d3e3"/>'
            . '<path class="shoal" d="' . $blob(34.0) . '" fill="#cfe6e0" fill-opacity="0.7"/>'
            . '<path class="land" d="' . $blob(20.0) . '" fill="' . $fill . '" stroke="#ffffff" stroke-opacity="0.45" stroke-width="2"/>';
    }
    // Side trails to the places you've found, then roads: solid where you've walked (both ends visited), dashed where you haven't.
    // On the picture each line gets a dark casing under it so it reads over the rock.
    $line = fn(array $a, array $b): string => 'M' . (int)$a['x'] . ' ' . (int)$a['y'] . ' L' . (int)$b['x'] . ' ' . (int)$b['y'];
    $case = '';
    $lines = '';
    foreach ($items as $it) {
        if ($it['type'] !== 'off' || empty($it['anchor']) || !isset($items[$it['anchor']])) continue;
        $d = $line($items[$it['anchor']], $it);
        if ($art !== '') $case .= '<path class="tcase" d="' . $d . '" stroke="#2a1a10" stroke-width="5" stroke-linecap="round" fill="none"/>';
        $lines .= '<path class="trail" d="' . $d . '" stroke="#7a5a3a" stroke-width="2" stroke-dasharray="2 4" stroke-linecap="round" fill="none"/>';
    }
    foreach ($L['roads'] as $rd) {
        $list = $rd['nodes'];
        for ($i = 1; $i < count($list); $i++) {
            $a = $items[$list[$i - 1]] ?? null; $b = $items[$list[$i]] ?? null;
            if (!$a || !$b) continue;
            $walked = $a['seen'] && $b['seen'];
            $d = $line($a, $b);
            if ($art !== '') $case .= '<path class="rcase" d="' . $d . '" stroke="#2a1a10" stroke-width="9" stroke-linecap="round" fill="none"/>';
            $lines .= '<path class="road' . ($walked ? '' : ' unwalked') . '" d="' . $d . '" stroke="#7a5a3a" stroke-width="5"'
                . ($walked ? '' : ' stroke-dasharray="7 7" stroke-opacity="0.75"') . ' stroke-linecap="round" fill="none"><title>' . e($rd['name']) . '</title></path>';
        }
    }
    $svg .= $case . $lines;
    // v0.9.5: the route being followed (where the gnome is, on to the destination) lit up along the roads of this region
    require_once __DIR__ . '/destination.php';
    $routeIds = dest_route_ids($u);
    $onRoute = array_fill_keys($routeIds, true);
    for ($i = 1; $i < count($routeIds); $i++) {
        $a = $items[$routeIds[$i - 1]] ?? null;
        $b = $items[$routeIds[$i]] ?? null;
        if (!$a || !$b) continue;
        $svg .= '<path class="gps" d="' . $line($a, $b) . '" stroke="#e8a317" stroke-width="7" stroke-linecap="round" fill="none" opacity="0.85"/>';
    }

    // v1.4.2: labels. Each is tried below, above, right, left of its marker (exits: inwards first) and takes the first
    // spot clear of every marker, every label placed so far and the frame. v2.0.61: one that finds no room is still
    // drawn below its marker, shown only when zoomed in (markers and labels shrink on the map as it zooms).
    $FS = 10;
    $lw = function (string $t) use ($FS): float {
        $w = 0.0;
        foreach (mb_str_split($t) as $ch) $w += mb_ord($ch) > 0x2000 ? $FS * 1.15 : (ctype_upper($ch) ? $FS * 0.72 : $FS * 0.58);
        return $w + 4;
    };
    $boxes = [];
    foreach ($items as $it) $boxes[] = [$it['x'] - $it['r'] - 1, $it['y'] - $it['r'] - 1, $it['x'] + $it['r'] + 1, $it['y'] + $it['r'] + 1];
    $lboxes = [];   // labels placed so far; $gap = the breathing room kept round them (less on the second, lenient pass)
    $gap = 3;
    $free = function (array $b) use (&$boxes, &$lboxes, &$gap, $W, $H): bool {
        if ($b[0] < 2 || $b[1] < 2 || $b[2] > $W - 2 || $b[3] > $H - 2) return false;
        foreach ($boxes as $o) if ($b[0] < $o[2] && $b[2] > $o[0] && $b[1] < $o[3] && $b[3] > $o[1]) return false;
        foreach ($lboxes as $o) if ($b[0] < $o[2] + $gap && $b[2] > $o[0] - $gap && $b[1] < $o[3] + $gap && $b[3] > $o[1] - $gap) return false;
        return true;
    };
    $wrap = function (string $t): array {   // long names go on two lines, split at the space nearest the middle
        if (mb_strlen($t) <= 13 || !str_contains($t, ' ')) return [$t];
        $best = null; $bd = PHP_INT_MAX;
        foreach (array_keys(array_filter(mb_str_split($t), fn($c) => $c === ' ')) as $i) if (abs($i - mb_strlen($t) / 2) < $bd) { $bd = (int)abs($i - mb_strlen($t) / 2); $best = $i; }
        return [trim(mb_substr($t, 0, $best)), trim(mb_substr($t, $best))];
    };
    // → [x, y, anchor] or null. Sides tried in order; the diagonals tuck a label into a corner between markers
    $place = function (array $it, array $lines, array $order) use (&$lboxes, $free, $lw, $FS, $W): ?array {
        $w = max(array_map($lw, $lines)); $h = ($FS + 2) * count($lines); $x = $it['x']; $y = $it['y']; $r = $it['r'];
        foreach ($order as $side) {
            if (in_array($side, ['below', 'above', 'below+', 'below-', 'above+', 'above-'], true)) {
                $top = $side[0] === 'b' ? $y + $r + 2 : $y - $r - 3 - $h;
                $shift = ['+' => 1, '-' => -1][substr($side, -1)] ?? 0;   // centred, or hung off to the right / left of the marker
                $lx = max(3 + $w / 2, min($W - 3 - $w / 2, $x + $shift * max(0, $w / 2 - $r * 0.5)));
                $b = [$lx - $w / 2, $top, $lx + $w / 2, $top + $h];
                if ($free($b)) { $lboxes[] = $b; return [$lx, $top + $FS, 'middle']; }
            } elseif ($side === 'right' || $side === 'left') {
                $left = $side === 'right' ? $x + $r + 4 : $x - $r - 4 - $w;
                $b = [$left, $y - $h / 2, $left + $w, $y + $h / 2];
                if ($free($b)) { $lboxes[] = $b; return [$side === 'right' ? $left : $left + $w, $y - $h / 2 + $FS, $side === 'right' ? 'start' : 'end']; }
            } else {   // 'ne', 'nw', 'se', 'sw'
                $east = $side[1] === 'e';
                $left = $east ? $x + $r * 0.6 + 2 : $x - $r * 0.6 - 2 - $w;
                $top = $side[0] === 's' ? $y + $r * 0.6 + 2 : $y - $r * 0.6 - 2 - $h;
                $b = [$left, $top, $left + $w, $top + $h];
                if ($free($b)) { $lboxes[] = $b; return [$east ? $left : $left + $w, $top + $FS, $east ? 'start' : 'end']; }
            }
        }
        return null;
    };
    // name the important places first so they get the best spots: you, the town, the place you're heading to, exits, villages, then small sites
    $rank = function (int $id) use ($items, $hereId, $selId): int {
        $it = $items[$id];
        if ($id === $hereId) return 0;
        if ($it['type'] === 'town') return 1;
        if ($id === $selId) return 2;
        if ($it['type'] === 'far') return 3;
        if ($it['type'] === 'stop') return $it['seen'] ? 4 : 7;
        return $it['k'] === 'village' ? 5 : 6;
    };
    $ids = array_keys($items);
    $order = $ids;
    usort($order, fn($a, $b) => $rank($a) <=> $rank($b) ?: $a <=> $b);
    $labels = [];
    $caption = null;
    foreach (array_merge($order, [0], $order) as $id) {   // second time round: what didn't fit gets another go with less breathing room
        if ($id === 0) { $gap = 0; continue; }
        if (isset($labels[$id])) continue;
        $it = $items[$id];
        if ($it['type'] === 'stop' && !$it['seen']) continue;   // ❔ says it all
        if ($gap === 0 && $it['type'] === 'town') continue;   // the town has its corner caption
        $txt = $it['type'] === 'far' ? $it['farname'] : mb_strimwidth((string)$it['loc']['name'], 0, 28, '…');
        $try = ['below', 'above', 'right', 'left', 'below+', 'below-', 'above+', 'above-', 'se', 'sw', 'ne', 'nw'];
        if ($it['type'] === 'far') $try = ['E' => ['left', 'below', 'above', 'below-', 'above-', 'sw', 'nw'], 'W' => ['right', 'below', 'above', 'below+', 'above+', 'se', 'ne'],
            'N' => ['below', 'left', 'right', 'below-', 'below+', 'sw', 'se'], 'S' => ['above', 'left', 'right', 'above-', 'above+', 'nw', 'ne']][$it['side']] ?? $try;
        if ($p = $place($it, $wrap($txt), $try)) $labels[$id] = [$wrap($txt), $p, false];
        elseif ($it['type'] === 'town') {   // no room by the town itself: name it in a free corner of the frame instead
            $w = $lw('🏘️ ' . $txt);
            foreach ([[4, 4], [4, $H - $FS - 6], [$W - 4 - $w, $H - $FS - 6], [$W - 4 - $w, 4]] as [$cx0, $cy0]) {
                $b = [$cx0, $cy0, $cx0 + $w, $cy0 + $FS + 2];
                if ($free($b)) { $lboxes[] = $b; $caption = ['🏘️ ' . $txt, [$cx0 + $w / 2, $cy0 + $FS, 'middle']]; break; }
            }
        }
    }
    foreach ($order as $id) {   // v2.0.61: no room at this size: named below the marker once zoomed in
        $it = $items[$id];
        if (isset($labels[$id]) || $it['type'] === 'town' || ($it['type'] === 'stop' && !$it['seen'])) continue;
        $txt = $it['type'] === 'far' ? $it['farname'] : mb_strimwidth((string)$it['loc']['name'], 0, 28, '…');
        $labels[$id] = [$wrap($txt), [$it['x'], $it['y'] + $it['r'] + 2 + $FS, 'middle'], true];
    }

    // Markers
    $sideRot = ['E' => 0, 'S' => 90, 'W' => 180, 'N' => 270];
    $top = '';
    $pp = [];   // v2.0.92: Puzzle Pals waiting at places: the sticker takes the place's icon (a small badge keeps the kind)
    if (setting('ppal_open') === '1' || is_admin()) { require_once __DIR__ . '/puzzle_pals.php'; $pp = ppal_map_spawns($u); }
    foreach ($items as $id => $it) {
        $l = $it['loc'];
        $type = $it['type'];
        $isTown = $type === 'town';
        $isFar = $type === 'far';
        $isMe = $id === $hereId;
        $seen = $it['seen'];
        $x = (int)$it['x']; $y = (int)$it['y']; $r = (int)$it['r'];
        $name = $seen ? (string)$l['name'] : '???';
        $k = $isTown ? 'town' : ($isFar ? 'far' : ($seen ? $it['k'] : 'new'));
        [$fillC, $strokeC] = $kindCol[$k] ?? $kindCol['village'];
        $icon = $isTown ? '🏘️' : ($isFar ? '➜' : ($seen ? ($kindIcon[$it['k']] ?? '📍') : '❔'));
        $small = $type === 'off' && $it['k'] !== 'village';   // small sites: icon only until zoomed (or tapped / heading there)
        $ring = $isMe ? '<circle r="' . ($r + 6) . '" fill="#ffe66b" fill-opacity="0.45" stroke="#d9a520" stroke-width="3"/>'
            : (isset($onRoute[$id]) ? '<circle class="onroute" r="' . ($r + 4) . '" fill="none" stroke="#e8a317" stroke-width="4"/>' : ($id === $selId ? '<circle r="' . ($r + 4) . '" fill="none" stroke="#2a6fa5" stroke-width="3" stroke-dasharray="4 3"/>' : ''));
        $badge = isset($plots[$id]) ? '<text x="' . ($r - 2) . '" y="' . (-$r + 5) . '" text-anchor="middle" font-size="10">' . ($id === $homeV ? '🏡' : '🌱') . '</text>' : '';
        $ruin = !empty($it['ruin']) ? '<text x="' . (-$r + 2) . '" y="' . (-$r + 5) . '" text-anchor="middle" font-size="9">🏚️</text>' : '';
        $lab = '';
        if (isset($labels[$id])) {
            [$lines, [$lx, $ly, $anc], $late] = $labels[$id];
            $zl = $late ? ' zl2' : ($small && $id !== $selId && !$isMe ? ' zl' : '');
            $lab = '<text class="lbl' . $zl . '" x="' . (int)round($lx - $x) . '" y="' . (int)round($ly - $y) . '" text-anchor="' . $anc . '" font-size="' . $FS . '" font-weight="700"'
                . ' fill="#1f2a1c" stroke="#f6f4ec" stroke-width="3" stroke-linejoin="round" paint-order="stroke">';
            foreach ($lines as $li => $ln) $lab .= $li ? '<tspan x="' . (int)round($lx - $x) . '" dy="' . ($FS + 2) . '">' . e($ln) . '</tspan>' : e($ln);
            $lab .= '</text>';
        }
        $palMark = isset($pp[$id]) && !$isFar && !$isMe ? ppal_marker_svg($pp[$id], $seen ? '<circle cx="' . ($r - 1) . '" cy="' . ($r - 1) . '" r="8" fill="' . $fillC . '" stroke="' . $strokeC . '" stroke-width="1.5"/><text x="' . ($r - 1) . '" y="' . ($r + 3) . '" text-anchor="middle" font-size="10">' . $icon . '</text>' : '', max(18, $r + 6)) : '';
        $inner = '<title>' . e(($isFar ? 'Road on to ' . $it['farname'] . ': ' : '') . $name . ($isMe ? ' (you are here)' : '') . (isset($pp[$id]) ? ' · 🧩 ' . $pp[$id]['pal']['name'] . ' waits here (' . $pp[$id]['pal']['rarity'] . ', level ' . $pp[$id]['level'] . ')' : '')) . '</title>'
            . '<circle class="hit" r="' . max(22, $r + 8) . '" fill="#ffffff" fill-opacity="0"/>' . $ring
            . ($art !== '' ? '<circle class="halo" r="' . ($r + 2) . '" fill="#f2e4c0"/>' : '')
            . '<circle class="dot' . ($seen ? '' : ' new') . '" r="' . $r . '" fill="' . $fillC . '" stroke="' . $strokeC . '" stroke-width="2.5"' . ($seen ? '' : ' stroke-dasharray="4 3"') . '/>'
            . ($isFar ? '<text y="5" text-anchor="middle" font-size="14" font-weight="700" fill="#6b4a00" transform="rotate(' . ($sideRot[$it['side']] ?? 0) . ')">➜</text>'
                : '<text y="' . ($isTown ? 6 : 5) . '" text-anchor="middle" font-size="' . ($isTown ? 16 : ($small ? 11 : 13)) . '"' . ($seen || $art !== '' ? '' : ' opacity="0.7"') . '>' . ($isMe ? '🎩' : $icon) . '</text>')
            . $badge . $ruin . $palMark . $lab;
        $inner = '<g class="ms">' . $inner . '</g>';
        $g = '<g class="rmp k-' . $k . ($isMe ? ' here' : '') . (isset($onRoute[$id]) && !$isMe ? ' onroute' : '') . ($seen ? '' : ' new') . '" transform="translate(' . $x . ' ' . $y . ')">';
        $g .= $isMe ? '<g aria-current="location">' . $inner . '</g>'
            : '<a href="' . e(url('world.php?go=' . $id . '#gopanel')) . '" aria-label="' . e(($isFar ? 'Road on to ' . $it['farname'] . ': ' : '') . $name) . '">' . $inner . '</a>';
        $g .= '</g>';
        if ($isMe) $top .= $g; else $svg .= $g;   // you, on top
    }
    if ($caption) {
        [$txt, [$lx, $ly]] = $caption;
        $svg .= '<text class="lbl" x="' . (int)round($lx) . '" y="' . (int)round($ly) . '" text-anchor="middle" font-size="' . $FS . '" font-weight="700" fill="#1f2a1c" stroke="#f6f4ec" stroke-width="3" stroke-linejoin="round" paint-order="stroke">' . e($txt) . '</text>';
    }
    return $svg . $top . '</svg>';
}

/** v0.9.3: previous / next region and a row of every region, all plain links (no JavaScript). */
function region_nav(array $u, int $sel): string
{
    $list = all_regions();
    $ids = array_map(fn($r) => (int)$r['id'], $list);
    $at = array_search($sel, $ids, true);
    if ($at === false || !$list) return '';
    $hereRegion = (int)(player_node($u)['region_id'] ?? 0);
    $href = fn(int $rid): string => e(url('world.php?tab=map&r=' . $rid . '#regionmap'));
    $prev = $list[($at + count($list) - 1) % count($list)];
    $next = $list[($at + 1) % count($list)];
    $h = '<div class="regnav"><a class="btn small alt" href="' . $href((int)$prev['id']) . '" aria-label="Previous region: ' . e($prev['gnomish_name']) . '">◀ ' . e($prev['gnomish_name']) . '</a>'
        . '<a class="btn small alt" href="' . e(url('world.php?tab=map&w=1#worldmap')) . '">🌍 All regions</a>'
        . '<a class="btn small alt" href="' . $href((int)$next['id']) . '" aria-label="Next region: ' . e($next['gnomish_name']) . '">' . e($next['gnomish_name']) . ' ▶</a></div>'
        . '<nav class="regchips" aria-label="Choose a region">';
    foreach ($list as $r) {
        $rid = (int)$r['id'];
        $h .= '<a class="regchip' . ($rid === $sel ? ' on' : '') . '" href="' . $href($rid) . '"' . ($rid === $sel ? ' aria-current="true"' : '') . '>'
            . ($rid === $hereRegion ? '🎩 ' : '') . e($r['gnomish_name']) . '</a>';
    }
    return $h . '</nav>';
}

/**
 * v0.9.3: a road as a "metro line": a coloured track with a big round stop for every place on it, town to town.
 * Every stop is a link to its "Head to" panel; the stop you're at is filled (🎩), visited stops are solid, new ones hollow (❔).
 */
function road_board(array $u, array $stops, int $hereId = 0, string $name = ''): string
{
    if (!$stops) return '';
    $uid = (int)$u['id'];
    $n = count($stops);
    if ($name === '') $name = (string)(road_of((int)$stops[min(1, $n - 1)]['id'])['name'] ?? 'The road');
    $mine = array_fill_keys(array_map('intval', q('SELECT village_id FROM plots WHERE user_id = ? AND village_id IS NOT NULL', [$uid])->fetchAll(PDO::FETCH_COLUMN)), true);
    $li = '';
    foreach ($stops as $i => $st) {
        $id = (int)$st['id'];
        $isTown = $st['kind'] === 'market';
        $isMe = $id === $hereId;
        $seen = $isTown || place_known($uid, $st);
        $vL = LANDSCAPES[$st['landscape'] ?? ''] ?? ['📍'];
        $cls = 'mstop' . ($isTown ? ' town' : '') . ($isMe ? ' here' : '') . ($seen ? ' seen' : ' new') . (isset($mine[$id]) ? ' safe' : '') . ($i === 0 ? ' first' : '') . ($i === $n - 1 ? ' last' : '');
        $tag = $isMe ? 'span' : 'a';
        $sub = $isTown && !str_contains((string)$st['name'], (string)$st['region']) ? '<small>' . e((string)$st['region']) . '</small>' : '';
        $li .= '<li class="' . $cls . '"><' . $tag . ' class="mpill"' . ($isMe ? ' aria-current="location"' : ' href="' . e(url('world.php?go=' . $id . '#gopanel')) . '"')
            . ' title="' . e($seen ? (string)$st['name'] : 'Not visited yet') . '">'
            . '<span class="mdot">' . ($isMe ? '🎩' : ($isTown ? '🏘️' : ($seen ? $vL[0] : '❔'))) . (isset($mine[$id]) ? '<i>🏡</i>' : '') . '</span>'
            . '<span class="mname">' . e($seen ? (string)$st['name'] : '???') . $sub . '</span></' . $tag . '></li>';
    }
    return '<div class="metro l' . (crc32($name) % 6) . '" role="group" aria-label="Road: ' . e($name) . '">'
        . '<div class="metrohead">🛣️ <b>' . e($name) . '</b> <small class="muted">' . e((string)$stops[0]['name']) . ' ⇄ ' . e((string)$stops[$n - 1]['name']) . '</small></div>'
        . '<ol class="metroline">' . $li . '</ol></div>';
}

/** Everything about one region, for the panel under the map. */
function region_panel(array $u, int $regionId): string
{
    $reg = q_one('SELECT * FROM regions WHERE id = ?', [$regionId]);
    if (!$reg) return '';
    $uid = (int)$u['id'];
    $here = player_node($u);
    $isHere = (int)($here['region_id'] ?? 0) === $regionId && ($here['kind'] ?? '') !== 'hub';
    $isHome = (int)($u['region_id'] ?? 0) === $regionId;
    $town = q_one("SELECT * FROM locations WHERE region_id = ? AND kind = 'market' ORDER BY id LIMIT 1", [$regionId]);
    $h = '<div class="box regionpanel" id="region">' . ph_img('banner-' . strtolower((string)$reg['code']), 64, '', 'phbanner') . '<h2>' . e($reg['gnomish_name']) . ' <small class="muted">' . e($reg['real_name']) . '</small></h2>'
        . '<p class="help">🌦️ ' . e(climate_text($reg)) . '</p><p>'
        . ($isHere ? '🎩 <b>You are here.</b> ' : '')
        . ($isHome ? '🏡 Your home region. ' : '');
    $min = max(1, (int)$reg['min_level']);
    $h .= '<span class="tag' . ($min > (int)$u['level'] ? ' warn' : '') . '">Recommended level ' . $min . '</span> ';
    if (!$isHere && !can_fast_travel($u, $regionId)) {   // v0.7.43: walk there once before you can travel straight there
        $h .= '<span class="muted">🔒 You haven’t been here yet. Walk the roads from a neighbouring region to reach it'
            . ($min > (int)$u['level'] ? ' (you’re level ' . (int)$u['level'] . ', so go carefully)' : '') . '.</span>';
    } elseif (!$isHere) {
        require_once __DIR__ . '/journey.php';
        $freeJ = !$isHome && journey_benefit((int)$u['id'], 'free_travel', $regionId);   // v0.7.65
        $cost = $isHome || $freeJ ? 0 : (int)setting('travel_cost');
        $h .= '<form method="post" class="inline"' . ($cost ? ' data-confirm="Travel to ' . e($reg['gnomish_name']) . ' for ' . number_format($cost) . '?"' : '') . '>' . csrf_field()
            . '<input type="hidden" name="do" value="travel"><input type="hidden" name="region_id" value="' . $regionId . '">'
            . '<button class="btn small">🧭 Travel here' . ($cost ? ' · ' . money($cost) . ' · ⚡' . (int)setting('travel_energy') : ($freeJ ? ' (free: your Journey project)' : ' (free: home)')) . '</button></form>';
    }
    $h .= '</p>';
    if ($town) {
        $h .= '<h3>🏘️ <a href="' . e(url('world.php?go=' . (int)$town['id'] . '#gopanel')) . '">' . e($town['name']) . '</a></h3>';   // v0.7.98
        $roads = q('SELECT * FROM roads WHERE a_town = ? OR b_town = ? ORDER BY id', [$town['id'], $town['id']])->fetchAll();
        if ($roads) $h .= '<p class="help">Tap a stop on a road to see how to get there.</p>';
        foreach ($roads as $rd) {
            $stops = [];
            foreach (json_decode((string)$rd['nodes'], true) ?: [] as $id) {
                if ($st = q_one('SELECT id, name, slug, kind, landscape, region FROM locations WHERE id = ?', [$id])) $stops[] = $st;
            }
            if ($stops && (int)$stops[0]['id'] !== (int)$town['id']) $stops = array_reverse($stops);   // start from this region's town
            $h .= road_board($u, $stops, (int)$here['id'], (string)$rd['name']);
        }
    }
    // Off-road places: found ones by name, the rest as a count
    $kindIcon = ['village' => '🏡', 'haven' => '🏕️', 'wonder' => '✨', 'lair' => '🐉', 'delve' => '🕳️'];
    $found = [];
    $hidden = 0;
    $onRoad = [];
    foreach (q("SELECT a_id, b_id FROM routes WHERE kind = 'road'")->fetchAll() as $rt) $onRoad[(int)$rt['a_id']] = $onRoad[(int)$rt['b_id']] = true;
    foreach (q("SELECT * FROM locations WHERE region_id = ? AND kind NOT IN ('market', 'hub') ORDER BY kind, name", [$regionId])->fetchAll() as $l) {
        if (isset($onRoad[(int)$l['id']])) continue;
        $lk = $l['kind'] === 'village' ? 'village' : ((string)q_val('SELECT kind FROM landmarks WHERE location_id = ?', [$l['id']]) ?: $l['kind']);
        if (place_known($uid, $l)) $found[] = ($kindIcon[$lk] ?? '📍') . ' ' . e($l['name'])
            . (in_array($lk, ['haven', 'wonder', 'delve'], true) && q_val('SELECT 1 FROM landmarks m WHERE m.location_id = ? AND m.ruined = 1 AND NOT EXISTS (SELECT 1 FROM landmark_rebuilds b WHERE b.landmark_id = m.id AND b.user_id = ?)', [$l['id'], $uid]) ? ' 🏚️' : '');   // v0.7.78 in ruins (v0.7.88: for this gnome)
        else $hidden++;
    }
    // v0.7.80: which land is where off the road, by steps out (zones 2–4; zone 1 is the road's own land)
    require_once __DIR__ . '/explore.php';
    $lands = [];
    foreach (q('SELECT zone_num, landscape FROM zones WHERE region_id = ? AND zone_num >= 2 ORDER BY zone_num', [$regionId])->fetchAll() as $zr) {
        $label = explore_zone_steps((int)$zr['zone_num']);
        $L = LANDSCAPES[(string)$zr['landscape']] ?? null;
        if ($label !== '' && $L) $lands[] = e($label) . ' ' . $L[0] . ' ' . e($L[1]);
    }
    // v0.7.84: step 2 is each stop's neighbouring land; list them by stop
    $near = [];
    foreach (q("SELECT DISTINCT l.* FROM locations l JOIN routes r ON (r.a_id = l.id OR r.b_id = l.id) AND r.kind = 'road' WHERE l.region_id = ? AND l.kind = 'village' ORDER BY l.name", [$regionId])->fetchAll() as $st) {
        $N = LANDSCAPES[stop_near_land($st)] ?? null;
        if ($N) $near[] = e($st['name']) . ' ' . $N[0] . ' ' . e($N[1]);
    }
    $h .= '<p>🗺️ <b>Lands off the road:</b> step 1: each stop’s own land' . ($near ? ' · step 2: ' . implode(', ', $near) : '') . ($lands ? ' · ' . implode(' · ', $lands) : '') . '</p>';
    $h .= '<h3>🌿 Off the road</h3>'
        . ($found ? '<p>' . implode(' · ', $found) . '</p>' : '<p class="muted">Nothing found yet.</p>')
        . ($hidden ? '<p class="help">❔ ' . $hidden . ' more hidden village' . ($hidden === 1 ? '' : 's') . ' and landmark' . ($hidden === 1 ? '' : 's') . ' to find. Wander off the road to look.</p>' : '<p class="help">✔️ You’ve found everything here!</p>');
    return $h . '</div>';
}

/** The journey map for a walk or a wander: the whole road with you on it, or rings going out into the wild. */
function journey_map_svg(array $u, array $exp): string
{
    $kind = $exp['kind'] ?? 'walk';
    if (in_array($kind, ['delve', 'lair'], true)) return '';
    $enc = $exp['encounter'] ? json_decode((string)$exp['encounter'], true) : null;
    $mark = $enc ? ($enc['type'] === 'creature' ? '⚔️' : '❓') : '';
    $active = ($exp['status'] ?? '') === 'active';
    if ($kind === 'explore') return hoop_map_html($exp, $mark, $active);   // v2.0.44: the embroidery hoop
    return '';   // v2.0.51: a walk on the road is shown by route_ribbon_html() and route_fold_html() instead
}

/** v2.0.51: the stops of the road being walked, in road order, plus where the leg from/to sit in that list. */
function journey_stops(array $exp): array
{
    $cols = 'id, name, slug, kind, landscape, region';
    $from = q_one("SELECT $cols FROM locations WHERE id = ?", [$exp['from_id']]);
    $to = q_one("SELECT $cols FROM locations WHERE id = ?", [$exp['to_id']]);
    if (!$from || !$to) return ['stops' => [], 'fi' => null, 'ti' => null];
    $road = null;
    $route = q_one('SELECT * FROM routes WHERE id = ?', [$exp['route_id']]);
    if ($route && ($route['kind'] ?? '') === 'road' && !empty($route['road_id'])) $road = q_one('SELECT * FROM roads WHERE id = ?', [$route['road_id']]);
    $stops = [];
    if ($road) foreach (json_decode((string)$road['nodes'], true) ?: [] as $id) {
        if ($l = q_one("SELECT $cols FROM locations WHERE id = ?", [$id])) $stops[] = $l;
    }
    if (!$stops) $stops = [$from, $to];
    $fi = $ti = null;
    foreach ($stops as $i => $st) {
        if ((int)$st['id'] === (int)$from['id']) $fi = $i;
        if ((int)$st['id'] === (int)$to['id']) $ti = $i;
    }
    return ['stops' => $stops, 'fi' => $fi, 'ti' => $ti, 'from' => $from, 'to' => $to];
}

/** Small route picture for a place (the rest-stop art; towns get the market, villages the inn). */
function route_stop_img(array $loc, string $class): string
{
    $pic = ($loc['kind'] ?? '') === 'market' ? 'market' : (($loc['kind'] ?? '') === 'village' ? 'inn' : 'camp');
    return '<img class="' . $class . '" src="' . e(url('assets/img/stops/' . $pic . '.png')) . '" alt="" aria-hidden="true">';
}

function route_img(string $file, string $class, string $alt = ''): string
{
    return '<img class="' . $class . '" src="' . e(url('assets/img/route/' . $file)) . '" alt="' . e($alt) . '"' . ($alt === '' ? ' aria-hidden="true"' : '') . '>';
}

/** v2.0.51: the one-line route ribbon: the leg being walked as a felt strip (a pin per space), the goal, stops left, danger. */
function route_ribbon_html(array $u, array $exp, ?array $wi, int $level): string
{
    $j = journey_stops($exp);
    if (empty($j['from'])) return '';
    $enc = $exp['encounter'] ? json_decode((string)$exp['encounter'], true) : null;
    $fight = $enc && ($enc['type'] ?? '') === 'creature';
    $active = ($exp['status'] ?? '') === 'active';
    $total = max(1, (int)$exp['steps_total']);
    $step = $active ? min((int)$exp['step'], $total) : $total + 1;   // finished: the token stands at the far end
    $uid = (int)$u['id'];
    $items = [route_stop_img($j['from'], 'stop')];
    if ($step === 0) $items[] = 'tok';
    for ($k = 1; $k <= $total; $k++) {
        $pin = $k <= $step ? 'a-pin-done.png' : 'a-pin-todo.png';
        if ($fight && $k === $step + 1) $pin = 'a-pin-danger.png';   // the thorn pin: a fight waits on the next space
        $items[] = route_img($pin, 'pin');
        if ($k === $step || ($k === $total && $step > $total)) $items[] = 'tok';
    }
    $items[] = route_stop_img($j['to'], 'stop');
    $tokAt = (int)array_search('tok', $items, true);
    $band = '';
    foreach ($items as $i => $it) {
        $band .= $it === 'tok' ? route_img('gnome-token.png', 'tok', 'You') : $it;
        if ($i < count($items) - 1) $band .= '<span class="t' . ($i < $tokAt ? '' : ' todo') . '"></span>';
    }
    $on = max(1, min(5, (int)ceil($level / 2)));
    $pips = '';
    for ($i = 1; $i <= 5; $i++) $pips .= route_img($i <= $on ? 'danger-on.png' : 'danger-off.png', '');
    $goal = $wi ? '<span>' . route_img('goal-flag.png', 'flag') . ' <b>' . e(dest_name($uid, $wi['loc'])) . '</b></span><span class="sep">·</span><span>' . (int)$wi['left'] . ' stop' . ((int)$wi['left'] === 1 ? '' : 's') . ' left</span><span class="sep">·</span>' : '';
    return '<section class="routebox" aria-label="Route">'
        . '<h1 class="legname"><span>' . e($j['from']['name']) . '</span><span class="arrow" aria-hidden="true">→</span><span>' . e($j['to']['name']) . '</span></h1>'
        . '<div class="strip" role="img" aria-label="Space ' . min((int)$exp['step'], $total) . ' of ' . $total . '"><span class="capl"></span><div class="band">' . $band . '</div><span class="capr"></span></div>'
        . '<div class="meta">' . $goal . '<span>danger ' . $level . ' <span class="pips" aria-hidden="true">' . $pips . '</span></span></div>'
        . '</section>';
}

/** v2.0.51: the closed Route fold: every stop on the road (visited / next / goal) plus the travel options. */
function route_fold_html(array $u, array $exp, ?array $wi): string
{
    $j = journey_stops($exp);
    if (empty($j['from'])) return '';
    $uid = (int)$u['id'];
    $dir = ($j['ti'] !== null && $j['fi'] !== null && $j['ti'] < $j['fi']) ? -1 : 1;
    $goalId = $wi ? (int)$wi['loc']['id'] : (int)$j['to']['id'];
    $li = '';
    foreach ($j['stops'] as $i => $st) {
        $behind = $j['fi'] !== null && ($i - $j['fi']) * $dir <= 0;
        $next = (int)$st['id'] === (int)$j['to']['id'];
        $isGoal = (int)$st['id'] === $goalId;
        $seen = $behind || $next || $isGoal || ($st['kind'] === 'market') || place_known($uid, $st);
        $note = $behind ? ((int)$st['id'] === (int)$j['from']['id'] ? 'you left here' : 'visited') : ($next ? 'next stop' : ($isGoal ? 'goal' : ''));
        $pin = $isGoal ? 'a-pin-stop.png' : ($behind ? 'a-pin-done.png' : 'a-pin-todo.png');
        $li .= '<li class="' . ($behind ? '' : 'todo') . '">' . route_img($pin, 'pinv') . route_stop_img($st, 'st')
            . '<span><b>' . e($seen ? (string)$st['name'] : '???') . '</b>' . ($note !== '' ? '<small>' . e($note) . '</small>' : '') . '</span></li>';
    }
    $opts = $wi ? '<form method="post" class="inline routeopts">' . csrf_field() . '<input type="hidden" name="do" value="dest_opts"><input type="hidden" name="back" value="adventure.php">' . dest_opts_html($u) . ' <button class="btn ghost">Save</button></form>' : '';
    return '<details class="routefold"><summary>Route <small>' . count($j['stops']) . ' stops</small></summary><div class="in"><ol class="routelist">' . $li . '</ol>' . $opts . '</div></details>';
}
/** v2.0.44: tier colours for the hoop (felt rings), light to deep. Palette: moss, gold, ember, dusk (art style guide Part A). */
const HOOP_FELT = ['gentle' => ['#a4b86a', '#7ab55c'], 'medium' => ['#7ab55c', '#4f9a45'], 'hard' => ['#f5cf6a', '#e8a317'], 'wild' => ['#f08a24', '#d6322b'], 'deep' => ['#7a5cc0', '#4e3a8a']];

/** A tiny pixel landmark for the first ring of a tier, built from squares; assets/img/map/landmark-{tier}.png replaces it when drawn. */
function hoop_landmark(string $tier, int $x, int $y): string
{
    require_once __DIR__ . '/scene.php';
    if (is_file(APP_ROOT . '/assets/img/map/landmark-' . $tier . '.png')) {
        return '<image href="' . e(url('assets/img/map/landmark-' . $tier . '.png')) . '" x="' . ($x - 8) . '" y="' . ($y - 16) . '" width="16" height="16" image-rendering="pixelated"/>';
    }
    $u = '#2a1a10';
    return match ($tier) {
        'medium' => '<g transform="translate(' . ($x - 4) . ',' . ($y - 12) . ')"><rect x="3" y="3" width="2" height="9" fill="' . $u . '"/><rect x="0" y="0" width="8" height="4" fill="#c9a96e" stroke="' . $u . '" stroke-width="1"/></g>',
        'hard' => '<g transform="translate(' . ($x - 5) . ',' . ($y - 8) . ')"><rect x="1" y="4" width="8" height="4" fill="#8b8f96" stroke="' . $u . '" stroke-width="1"/><rect x="3" y="0" width="4" height="4" fill="#c9c5bc" stroke="' . $u . '" stroke-width="1"/></g>',
        'wild' => '<g transform="translate(' . ($x - 4) . ',' . ($y - 13) . ')"><rect x="1" y="0" width="2" height="13" fill="' . $u . '"/><rect x="3" y="1" width="6" height="5" fill="#d6322b" stroke="' . $u . '" stroke-width="1"/><rect x="5" y="2" width="1" height="1" fill="#f2e4c0"/><rect x="7" y="2" width="1" height="1" fill="#f2e4c0"/></g>',
        'deep' => '<g transform="translate(' . ($x - 5) . ',' . ($y - 10) . ')"><rect x="4" y="4" width="2" height="6" fill="#f2e4c0" stroke="' . $u . '" stroke-width="1"/><rect x="0" y="0" width="10" height="5" fill="#a894dc" stroke="' . $u . '" stroke-width="1"/><rect x="3" y="1" width="2" height="2" fill="#f2e4c0"/></g>',
        default => '',
    };
}

/** v2.0.44: the wild as an embroidery hoop: felt rings, thread-gold seams, a thread trail of your steps, a button for you, a landmark at each tier. */
function hoop_map_html(array $exp, string $mark, bool $active): string
{
    require_once __DIR__ . '/explore.php';
    $depth = (int)$exp['depth'];
    $rings = max(min(10, (int)setting('explore_deep_from')), $depth + 1);
    $cx = 120;
    $cy = 120;
    $r0 = 16;
    $step = (104 - $r0) / $rings;
    $ink = '#2a1a10';
    $warnFrom = (int)setting('explore_warn_from');
    $wildFrom = (int)setting('explore_wild_from');
    $deepFrom = (int)setting('explore_deep_from');
    $span = fn(int $lo, int $hi): string => $lo === $hi ? 'step ' . $lo : 'steps ' . $lo . '–' . $hi;
    $tiers = [['gentle', 'Gentle', $span(1, 2), 'Safe to learn the ropes.']];
    if (min($warnFrom, $wildFrom) - 1 >= 3) $tiers[] = ['medium', 'Medium', $span(3, min($warnFrom, $wildFrom) - 1), 'A little tougher.'];
    if ($wildFrom - 1 >= max($warnFrom, 3)) $tiers[] = ['hard', 'Hard', $span(max($warnFrom, 3), $wildFrom - 1), 'Only if you feel strong.'];
    $tiers[] = ['wild', 'Wild', $deepFrom > $wildFrom ? $span($wildFrom, $deepFrom - 1) . ' · bosses roam' : 'step ' . $wildFrom . '+ · bosses roam', 'Dangerous. Great finds.'];
    $tiers[] = ['deep', 'Deep wilds', 'step ' . $deepFrom . '+ · matched to your level', 'The far edge of the cloth.'];
    $lab = [];
    foreach ($tiers as [$t, $name, $sp, $note]) $lab[$t] = $name . ' · ' . $sp . '. ' . $note;
    $svg = '<svg class="journeymap rings hoopmap" viewBox="0 0 240 240" shape-rendering="crispEdges" role="img" aria-label="' . $depth . ' steps off the road">'
        . '<circle cx="' . $cx . '" cy="' . $cy . '" r="117" fill="#9a6b3f" stroke="' . $ink . '" stroke-width="2"/>'      // the wooden hoop
        . '<circle cx="' . $cx . '" cy="' . $cy . '" r="112" fill="none" stroke="#c9a96e" stroke-width="2"/>'
        . '<circle cx="' . $cx . '" cy="' . $cy . '" r="106" fill="#f1ece0" stroke="' . $ink . '" stroke-width="1"/>';        // the cloth
    $seen = [];
    $lm = '';
    for ($i = $rings; $i >= 1; $i--) {
        $t = explore_tier($i)[1];
        $col = HOOP_FELT[$t] ?? ['#ddd', '#bbb'];
        $r = (int)round($r0 + $i * $step);
        $svg .= '<g class="hr" data-t="' . e($t) . '" data-lab="' . e($lab[$t] ?? '') . '" tabindex="0">'
            . '<circle cx="' . $cx . '" cy="' . $cy . '" r="' . $r . '" fill="' . $col[0] . '"/>'
            . '<path d="M' . ($cx - $r) . ' ' . $cy . 'A' . $r . ' ' . $r . ' 0 0 0 ' . ($cx + $r) . ' ' . $cy . '" fill="' . $col[1] . '" opacity="0"/>'      // (kept for art overrides)
            . '<circle cx="' . $cx . '" cy="' . $cy . '" r="' . $r . '" fill="none" stroke="#f5cf6a" stroke-width="1" stroke-dasharray="2 1"/></g>';
    }
    for ($i = 1; $i <= $rings; $i++) {   // the first ring of each tier gets its landmark, along the top
        $t = explore_tier($i)[1];
        if ($t === 'gentle' || isset($seen[$t])) continue;
        $seen[$t] = true;
        $r = $r0 + ($i - 0.5) * $step;
        $lm .= hoop_landmark($t, (int)round($cx + cos(deg2rad(-95)) * $r), (int)round($cy + sin(deg2rad(-95)) * $r));
    }
    $svg .= $lm . '<circle cx="' . $cx . '" cy="' . $cy . '" r="' . $r0 . '" fill="#c9a96e" stroke="' . $ink . '" stroke-width="1"/>'
        . '<rect x="' . ($cx - 6) . '" y="' . ($cy - 1) . '" width="12" height="3" fill="#9a6b3f"/>';   // the road, a patch at the middle
    // the thread: a stitched trail from the road out to you, one stitch per step
    $pts = [[$cx, $cy]];
    $trail = json_decode((string)($exp['trail'] ?? ''), true);
    if (!is_array($trail) || !$trail) $trail = $depth > 0 ? range(1, $depth) : [];   // a walk from before the history was kept: one step per ring
    foreach ($trail as $n => $d) {
        $d = max(1, (int)$d);
        $ang = deg2rad(55 + 28 * sin(($n + 1) * 1.25));   // a gentle meander down and to the right, so the thread reads as a path
        $r = $r0 + ($d - 0.5) * $step;
        $pts[] = [(int)round($cx + cos($ang) * $r), (int)round($cy + sin($ang) * $r)];
    }
    if (count($pts) > 1) {
        $svg .= '<polyline points="' . implode(' ', array_map(fn($p) => $p[0] . ',' . $p[1], $pts)) . '" fill="none" stroke="' . $ink . '" stroke-width="3" stroke-linejoin="round"/>'
            . '<polyline points="' . implode(' ', array_map(fn($p) => $p[0] . ',' . $p[1], $pts)) . '" fill="none" stroke="#f5cf6a" stroke-width="1" stroke-dasharray="3 2" stroke-linejoin="round"/>';
        foreach (array_slice($pts, 1, -1) as $p) $svg .= '<rect x="' . ($p[0] - 1) . '" y="' . ($p[1] - 1) . '" width="3" height="3" fill="#f5cf6a" stroke="' . $ink . '" stroke-width="1"/>';
    }
    // you: a gold button on the thread (or by the road before the first step)
    $me = count($pts) > 1 ? end($pts) : [$cx + 26, $cy + 2];
    if ($active) {
        $mx = $me[0]; $my = $me[1];
        $svg .= '<g class="hoopme"><circle cx="' . $mx . '" cy="' . $my . '" r="6" fill="' . $ink . '"/><circle cx="' . $mx . '" cy="' . $my . '" r="5" fill="#f5cf6a"/>'
            . '<circle cx="' . ($mx + 1) . '" cy="' . ($my + 1) . '" r="3" fill="#e8a317"/><rect x="' . ($mx - 2) . '" y="' . ($my - 2) . '" width="1" height="1" fill="#8a4a1c"/><rect x="' . ($mx + 1) . '" y="' . ($my + 1) . '" width="1" height="1" fill="#8a4a1c"/>'
            . ($mark !== '' ? '<text x="' . ($mx + 8) . '" y="' . ($my - 4) . '" font-size="12">' . $mark . '</text>' : '') . '</g>';
    }
    $svg .= '</svg>';
    $cur = explore_tier(max(1, $depth));
    $caption = '<p class="hoopcap" aria-live="polite" data-def="' . e('Step ' . $depth . ' · ' . $cur[0] . ' country. Tap a ring to see what it means.') . '">Step ' . $depth . ' · ' . e($cur[0]) . ' country.<span class="hoopcap-tip"> Tap a ring to see what it means.</span></p>';
    return $svg . $caption;
}
