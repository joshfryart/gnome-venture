<?php
declare(strict_types=1);

/**
 * v2.0.61: the region map's layout on its own: a fixed, landscape 480 × 270 frame (the size of the region map art).
 * Every place in the region gets one slot that never moves: the town, every stop of every road (found or not), every
 * off-road village and landmark (found or not), and each road's exit on the frame edge, on the side its neighbouring
 * region lies. It depends only on the world (regions, places, roads, side paths), never on a player, so a picture can be
 * drawn to match it (tools/map_layout.php dumps it for the art scripts). What a player has found only shows, hides or
 * restyles a slot (region_map_svg in maps.php).
 *
 * region_layout($code) → null, or [
 *   'code', 'w' => 480, 'h' => 270, 'town' => id,
 *   'slots' => [id => ['id', 'type' (town|stop|far|off), 'kind' (town|village|exit|haven|wonder|delve|lair), 'x', 'y', 'r',
 *                      'road' (road index or null), 'idx' (stop number along its road), 'anchor' (off: the stop its side path
 *                      leaves from, or 0), 'side' (far: N/E/S/W edge), 'far' (far: region code), 'farname', 'loc' (id, name, slug,
 *                      kind, landscape, region)]],
 *   'roads' => [['id', 'name', 'far', 'nodes' => [town … exit], 'pts' => [[x, y] …]]],
 *   'trails' => [['from' => anchor id, 'to' => id, 'pts' => [[x, y], [x, y]]]],
 *   'exits' => [['road', 'id', 'to', 'name', 'x', 'y', 'side']],
 *   'pin' => ['x', 'y', 'r'],            (one flat spot: the town square)
 *   'clear' => [['id', 'x', 'y', 'r']]   (keep-clear circles round every marker: the art keeps these flat and plain)
 * ]
 */

const RL_W = 480;
const RL_H = 270;
const RL_R = ['town' => 16, 'stop' => 13, 'far' => 12, 'village' => 12, 'small' => 10];   // marker radius by type

/** A region's layout, keyed by region code (upper case). The same every time for the same world. */
function region_layout(string $code): ?array
{
    static $cache = [];
    if (array_key_exists($code, $cache)) return $cache[$code];
    return $cache[$code] = region_layout_build($code);
}

/** Places on any road (towns and road villages), by id. */
function rl_on_road(): array
{
    static $on = null;
    if ($on !== null) return $on;
    $on = [];
    foreach (q('SELECT nodes FROM roads')->fetchAll() as $rd) foreach (json_decode((string)$rd['nodes'], true) ?: [] as $n) $on[(int)$n] = true;
    return $on;
}

function region_layout_build(string $code): ?array
{
    $reg = q_one('SELECT * FROM regions WHERE code = ?', [$code]);
    if (!$reg || !isset(REGION_MAP[$code])) return null;
    $regionId = (int)$reg['id'];
    $town = q_one("SELECT id, name, slug, kind, landscape, region FROM locations WHERE region_id = ? AND kind = 'market' ORDER BY id LIMIT 1", [$regionId]);
    if (!$town) return null;
    $tid = (int)$town['id'];
    [$wx, $wy] = REGION_MAP[$code];
    $W = RL_W; $H = RL_H;

    // 1) rough geography round the town at (0, 0): each road heads towards its neighbouring region, roads that head the
    //    same way fan out, its stops spaced along a gentle curve
    $C = [0.0, 0.0];
    $items = [$tid => ['type' => 'town', 'kind' => 'town', 'x' => 0.0, 'y' => 0.0, 'road' => null, 'idx' => 0, 'ang' => 0.0, 'loc' => $town]];
    $roads = [];
    $usedAng = [];
    foreach (q('SELECT * FROM roads WHERE a_town = ? OR b_town = ? ORDER BY id', [$tid, $tid])->fetchAll() as $rd) {
        $nodes = array_map('intval', json_decode((string)$rd['nodes'], true) ?: []);
        if (count($nodes) < 2) continue;
        if (end($nodes) === $tid) $nodes = array_reverse($nodes);
        if ($nodes[0] !== $tid) continue;
        $n = count($nodes);
        $far = q_one('SELECT r.code, r.gnomish_name FROM locations l JOIN regions r ON r.id = l.region_id WHERE l.id = ?', [$nodes[$n - 1]]);
        $fp = REGION_MAP[$far['code'] ?? ''] ?? null;
        $ang = $fp ? atan2((float)($fp[1] - $wy), (float)($fp[0] - $wx)) : (crc32((string)$rd['name']) % 628) / 100;
        for ($tries = 0; $tries < 8; $tries++) {
            $clash = false;
            foreach ($usedAng as $ua) if (abs(atan2(sin($ang - $ua), cos($ang - $ua))) < 0.8) $clash = true;
            if (!$clash) break;
            $ang += 0.85;
        }
        $usedAng[] = $ang;
        $E = [cos($ang) * 165, sin($ang) * 115];
        $ctl = road_ctrl($C, $E);
        $ri = count($roads);
        $list = [$tid];
        for ($i = 1; $i < $n; $i++) {
            $loc = q_one('SELECT id, name, slug, kind, landscape, region FROM locations WHERE id = ?', [$nodes[$i]]);
            if (!$loc) continue;
            [$px, $py] = map_bez($C, $ctl, $E, $n > 2 && $i < $n - 1 ? 0.25 + 0.55 * ($i - 1) / max(1, $n - 3) : 1.0);
            $isFar = $i === $n - 1;
            $items[$nodes[$i]] = ['type' => $isFar ? 'far' : 'stop', 'kind' => $isFar ? 'exit' : 'village', 'x' => $px, 'y' => $py, 'road' => $ri, 'idx' => $i, 'ang' => $ang, 'loc' => $loc,
                'far' => $isFar ? (string)($far['code'] ?? '') : '', 'farname' => $isFar ? (string)($far['gnomish_name'] ?? $loc['region']) : ''];
            $list[] = $nodes[$i];
        }
        $roads[] = ['id' => (int)$rd['id'], 'name' => (string)$rd['name'], 'far' => (string)($far['code'] ?? ''), 'nodes' => $list, 'ang' => $ang];
    }

    // 2) every off-road place (found or not) beside the stop its first side path leaves from, fanned either side of the road
    $onRoad = rl_on_road();
    $off = q("SELECT l.id, l.name, l.slug, l.kind, l.landscape, l.region, (SELECT kind FROM landmarks WHERE location_id = l.id ORDER BY id LIMIT 1) AS lmkind
        FROM locations l WHERE l.region_id = ? AND l.kind NOT IN ('market', 'hub') ORDER BY l.id", [$regionId])->fetchAll();
    $offIds = [];
    foreach ($off as $l) if (!isset($onRoad[(int)$l['id']]) && !isset($items[(int)$l['id']])) $offIds[(int)$l['id']] = $l;
    $anchorOf = [];
    $kids = [];
    foreach (q("SELECT a_id, b_id FROM routes WHERE kind = 'side' ORDER BY id")->fetchAll() as $rt) {
        [$a, $b] = [(int)$rt['a_id'], (int)$rt['b_id']];
        foreach ([[$a, $b], [$b, $a]] as [$an, $id]) {
            if (isset($offIds[$id], $items[$an]) && $items[$an]['type'] !== 'far' && !isset($anchorOf[$id])) { $anchorOf[$id] = $an; $kids[$an][] = $id; }
        }
    }
    foreach ($offIds as $id => $l) {
        $h = crc32((string)$l['slug']);
        if (isset($anchorOf[$id])) {
            $an = $anchorOf[$id];
            $k = array_search($id, $kids[$an], true);
            $ring = intdiv($k, 2);
            $base = ($items[$an]['ang'] ?? (($h & 1023) / 1023 * 6.283)) + ($k % 2 ? -1 : 1) * M_PI / 2 + ($ring ? ($ring % 2 ? 0.5 : -0.5) : 0);
            $d = 40 + $ring * 12;
            $px = $items[$an]['x'] + cos($base) * $d;
            $py = $items[$an]['y'] + sin($base) * $d * 0.8;
        } else {
            $a = ($h & 1023) / 1023 * 6.283;
            $d = 0.55 + (($h >> 10) & 255) / 255 * 0.4;
            $px = cos($a) * $d * 150;
            $py = sin($a) * $d * 105;
        }
        $lk = (string)($l['lmkind'] ?: $l['kind']);
        unset($l['lmkind']);
        $items[$id] = ['type' => 'off', 'kind' => $lk, 'x' => $px, 'y' => $py, 'road' => null, 'idx' => 0, 'ang' => 0.0, 'loc' => $l, 'anchor' => $anchorOf[$id] ?? 0];
    }

    // 3) stretch over the frame; exits go to the frame edge where their road's direction meets it (so the edge is the compass side)
    $pad = 26; $epad = 16;
    $xs = array_column($items, 'x'); $ys = array_column($items, 'y');
    $minX = min($xs); $maxX = max($xs); $minY = min($ys); $maxY = max($ys);
    $sx = $maxX - $minX > 1 ? ($W - 2 * $pad) / ($maxX - $minX) : 0.0;
    $sy = $maxY - $minY > 1 ? ($H - 2 * $pad) / ($maxY - $minY) : 0.0;
    foreach ($items as &$it) {
        $it['x'] = $sx ? $pad + ($it['x'] - $minX) * $sx : $W / 2;
        $it['y'] = $sy ? $pad + ($it['y'] - $minY) * $sy : $H / 2;
        $it['r'] = RL_R[$it['type'] === 'off' ? ($it['kind'] === 'village' ? 'village' : 'small') : $it['type']];
        $it['mx'] = $it['my'] = 1.0;   // how free it is to move sideways / up and down
        $it['side'] = '';
    }
    unset($it);
    $T = [$items[$tid]['x'], $items[$tid]['y']];
    foreach ($items as &$it) {
        if ($it['type'] !== 'far') continue;
        $dx = cos($it['ang']) * ($sx ?: 1.0); $dy = sin($it['ang']) * ($sy ?: 1.0);
        $best = INF; $hit = null;
        foreach ([['W', $epad, null], ['E', $W - $epad, null], ['N', null, $epad], ['S', null, $H - $epad]] as [$side, $ex, $ey]) {
            $t = $ex !== null ? ($dx != 0 ? ($ex - $T[0]) / $dx : INF) : ($dy != 0 ? ($ey - $T[1]) / $dy : INF);
            if ($t <= 0 || $t >= $best) continue;
            $best = $t;
            $hit = [$ex ?? $T[0] + $dx * $t, $ey ?? $T[1] + $dy * $t, $side];
        }
        if (!$hit) $hit = [$W - $epad, $T[1], 'E'];
        $it['x'] = max($epad, min($W - $epad, $hit[0]));
        $it['y'] = max($epad, min($H - $epad, $hit[1]));
        $it['side'] = $hit[2];
        if ($hit[2] === 'W' || $hit[2] === 'E') $it['mx'] = 0.0; else $it['my'] = 0.0;   // slides along its edge only
    }
    unset($it);

    // 4) push apart: no two markers closer than both radii plus room for a line of label; off-road places also keep off the
    //    roads they don't belong to. A fixed number of passes in a fixed order, so the same result every time.
    $ids = array_keys($items);
    $cnt = count($ids);
    $clamp = function (array &$it) use ($W, $H, $epad): void {
        $m = $it['r'] + 6;
        if ($it['mx'] > 0) $it['x'] = max($m, min($W - $m, $it['x']));
        if ($it['my'] > 0) $it['y'] = max($m, min($H - $m, $it['y']));
        if ($it['type'] === 'far') { $it['x'] = max($epad, min($W - $epad, $it['x'])); $it['y'] = max($epad, min($H - $epad, $it['y'])); }
    };
    $segs = function () use (&$items, $roads): array {
        $s = [];
        foreach ($roads as $rd) for ($i = 1; $i < count($rd['nodes']); $i++) $s[] = [$rd['nodes'][$i - 1], $rd['nodes'][$i]];
        return $s;
    };
    $roadSegs = $segs();
    for ($pass = 0; $pass < 120; $pass++) {
        $moved = false;
        for ($i = 0; $i < $cnt; $i++) {
            for ($j = $i + 1; $j < $cnt; $j++) {
                $a = &$items[$ids[$i]]; $b = &$items[$ids[$j]];
                $gap = ($a['type'] === 'off' && $b['type'] === 'off') ? 12 : 16;
                $need = $a['r'] + $b['r'] + $gap;
                $dx = $b['x'] - $a['x']; $dy = $b['y'] - $a['y'];
                $d = sqrt($dx * $dx + $dy * $dy);
                if ($d >= $need) { unset($a, $b); continue; }
                if ($d < 0.5) { $dx = 1.0; $dy = 0.4 * (($i + $j) % 3 - 1); $d = sqrt($dx * $dx + $dy * $dy); }
                $ux = $dx / $d; $uy = $dy / $d;
                $fa = $ux * $ux * $a['mx'] + $uy * $uy * $a['my'];
                $fb = $ux * $ux * $b['mx'] + $uy * $uy * $b['my'];
                if ($fa + $fb < 0.01) { unset($a, $b); continue; }
                $push = min(12.0, ($need - $d) * 0.6);
                $a['x'] -= $ux * $push * $fa / ($fa + $fb) * $a['mx']; $a['y'] -= $uy * $push * $fa / ($fa + $fb) * $a['my'];
                $b['x'] += $ux * $push * $fb / ($fa + $fb) * $b['mx']; $b['y'] += $uy * $push * $fb / ($fa + $fb) * $b['my'];
                $clamp($a); $clamp($b);
                if ($need - $d > 0.5) $moved = true;
                unset($a, $b);
            }
        }
        // off the roads: an off-road place (or a stop of another road) sitting on a road's line is nudged off it
        foreach ($roadSegs as [$p, $q]) {
            $A = $items[$p]; $B = $items[$q];
            $vx = $B['x'] - $A['x']; $vy = $B['y'] - $A['y']; $len2 = max(1.0, $vx * $vx + $vy * $vy);
            foreach ($ids as $id) {
                if ($id === $p || $id === $q) continue;
                $it = &$items[$id];
                if ($it['type'] === 'far') { unset($it); continue; }
                $t = max(0.0, min(1.0, (($it['x'] - $A['x']) * $vx + ($it['y'] - $A['y']) * $vy) / $len2));
                $cx = $A['x'] + $vx * $t; $cy = $A['y'] + $vy * $t;
                $ddx = $it['x'] - $cx; $ddy = $it['y'] - $cy; $dd = sqrt($ddx * $ddx + $ddy * $ddy);
                $need = $it['r'] + 7;
                if ($dd < $need && $t > 0.02 && $t < 0.98) {
                    if ($dd < 0.5) { $ddx = -$vy; $ddy = $vx; $dd = sqrt($len2); }
                    $it['x'] += $ddx / $dd * ($need - $dd) * 0.7; $it['y'] += $ddy / $dd * ($need - $dd) * 0.7;
                    $clamp($it);
                    $moved = true;
                }
                unset($it);
            }
        }
        if (!$moved) break;
    }
    foreach ($items as &$it) { $it['x'] = (int)round($it['x']); $it['y'] = (int)round($it['y']); }
    unset($it);

    // 5) the lines and spots the art is drawn round
    $outRoads = [];
    $exits = [];
    foreach ($roads as $ri => $rd) {
        $pts = [];
        foreach ($rd['nodes'] as $nid) $pts[] = [$items[$nid]['x'], $items[$nid]['y']];
        $outRoads[] = ['id' => $rd['id'], 'name' => $rd['name'], 'far' => $rd['far'], 'nodes' => $rd['nodes'], 'pts' => $pts];
        $last = end($rd['nodes']);
        if (($items[$last]['type'] ?? '') === 'far') {
            $e = $items[$last];
            $exits[] = ['road' => $ri, 'id' => $last, 'to' => $e['far'], 'name' => $e['farname'], 'x' => $e['x'], 'y' => $e['y'], 'side' => $e['side']];
        }
    }
    $trails = [];
    $slots = [];
    $clear = [];
    foreach ($items as $id => $it) {
        if ($it['type'] === 'off' && $it['anchor'] && isset($items[$it['anchor']])) {
            $an = $items[$it['anchor']];
            $trails[] = ['from' => $it['anchor'], 'to' => $id, 'pts' => [[$an['x'], $an['y']], [$it['x'], $it['y']]]];
        }
        $slots[$id] = ['id' => $id, 'type' => $it['type'], 'kind' => $it['kind'], 'x' => $it['x'], 'y' => $it['y'], 'r' => $it['r'], 'road' => $it['road'], 'idx' => $it['idx'],
            'anchor' => (int)($it['anchor'] ?? 0), 'side' => $it['side'], 'far' => (string)($it['far'] ?? ''), 'farname' => (string)($it['farname'] ?? ''), 'loc' => $it['loc']];
        $clear[] = ['id' => $id, 'x' => $it['x'], 'y' => $it['y'], 'r' => $it['r'] + 6];
    }
    return ['code' => $code, 'w' => $W, 'h' => $H, 'town' => $tid, 'slots' => $slots, 'roads' => $outRoads, 'trails' => $trails, 'exits' => $exits,
        'pin' => ['x' => $items[$tid]['x'], 'y' => $items[$tid]['y'], 'r' => $items[$tid]['r'] + 6], 'clear' => $clear];
}
