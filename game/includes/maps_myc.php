<?php
declare(strict_types=1);

/**
 * v1.6.0: mycelium maps. The world and every region drawn as a cross-section of the soil: regions sit at their true depth
 * (by level: topsoil, clay, deep rock, bedrock), each region is a lit chamber with its town, road villages, sites and exits
 * joined by glowing mycelium threads. Overlays (folk you know, quest targets, gathering spots) sit on top and are toggled by
 * the filter chips (site.js, data-f on .mycbox). Everything is laid out from the real data (roads, routes, places found), nothing
 * is hand-placed. The old drawn maps (world_map_svg / region_map_svg in maps.php) stay behind the admin setting map_style = classic.
 * No inline styles or scripts: colours are classes (style.css) or SVG attributes.
 */

const MYC_VER = '160b';   // bump this whenever the strata, scenery or glyph drawing changes (it is part of every cache file's name)
const MYC_STRATA = [['Topsoil', 0, 28], ['Clay', 28, 45], ['Deep rock', 45, 62], ['Bedrock', 62, 9999]];
const MYC_PXR = 24;   // map units per root of depth

/** v1.6.0: is the mycelium style on? (admin → Settings → map_style) */
function myc_on(): bool
{
    return setting('map_style') !== 'classic';
}

function myc_f(float $v): string
{
    $s = number_format($v, 1, '.', '');
    return str_contains($s, '.') ? rtrim(rtrim($s, '0'), '.') : $s;
}

/** How deep (in roots) a region's chamber sits, from its level. */
function myc_depth(int $minLevel): int
{
    return (int)round(8 + (max(1, $minLevel) - 1) * 1.75);
}

function myc_band(int $depth): array
{
    foreach (MYC_STRATA as $i => $b) if ($depth < $b[2]) return [$i, $b[0]];
    return [3, 'Bedrock'];
}

/** A tiny seeded random source so the scenery is the same every time (and never touches PHP's own generator). */
final class MycRng
{
    private int $s;
    public function __construct(string $seed) { $this->s = (crc32($seed) & 0x7fffffff) ?: 1; }
    public function next(): float
    {
        $x = $this->s;
        $x ^= ($x << 13) & 0xffffffff; $x ^= $x >> 17; $x ^= ($x << 5) & 0xffffffff;
        $this->s = $x & 0xffffffff ?: 1;
        return $this->s / 4294967296.0;
    }
    public function range(float $a, float $b): float { return $a + ($b - $a) * $this->next(); }
    public function int(int $a, int $b): int { return $a + (int)floor($this->next() * ($b - $a + 1)); }
}

/** Static scenery cache: the same pictures for a region and size every time, so keep them (memory, then data/cache). */
function myc_cached(string $key, callable $fn): string
{
    static $mem = [];
    $key = MYC_VER . '-' . $key;
    if (isset($mem[$key])) return $mem[$key];
    $file = APP_ROOT . '/data/cache/myc-' . preg_replace('/[^A-Za-z0-9_.-]/', '', $key) . '.txt';
    if (is_file($file) && ($s = @file_get_contents($file)) !== false && $s !== '') return $mem[$key] = $s;
    $s = $fn();
    $dir = dirname($file);
    if (!is_dir($dir)) @mkdir($dir, 0775, true);
    if (!is_file($dir . '/.htaccess')) @file_put_contents($dir . '/.htaccess', "Require all denied\nDeny from all\n");   // as updater.php does
    $tmp = $file . '.' . bin2hex(random_bytes(4)) . '.tmp';
    if (@file_put_contents($tmp, $s) !== false && !@rename($tmp, $file)) @unlink($tmp);   // write aside, then rename: never a half-written picture
    if (random_int(1, 25) === 1) {   // now and then: tidy pictures nobody has asked for in a few days (a region's height changes as places are found)
        foreach (glob(dirname($file) . '/myc-*.txt') ?: [] as $f) if (@filemtime($f) < time() - 3 * 86400) @unlink($f);
    }
    return $mem[$key] = $s;
}

function myc_wavy(float $y, float $W, string $seed, float $amp): string
{
    $r = new MycRng('w' . $seed);
    $d = 'M0 ' . myc_f($y);
    $x = 0.0;
    while ($x < $W) {
        $w = $r->range(50, 110);
        $d .= 'Q' . myc_f($x + $w / 2) . ' ' . myc_f($y + $r->range(-$amp, $amp)) . ' ' . myc_f($x + $w) . ' ' . myc_f($y);
        $x += $w;
    }
    return $d;
}

/** A rounded, slightly lumpy cave outline. */
function myc_cavern_path(float $x0, float $y0, float $x1, float $y1, string $seed): string
{
    $n = 36; $p = 6.0; $jit = 6.0;
    $cx = ($x0 + $x1) / 2; $cy = ($y0 + $y1) / 2; $a = ($x1 - $x0) / 2; $b = ($y1 - $y0) / 2;
    $r = new MycRng('c' . $seed);
    $ph = [$r->range(0, 6.28), $r->range(0, 6.28), $r->range(0, 6.28), $r->range(0, 6.28)];
    $pts = [];
    for ($i = 0; $i < $n; $i++) {
        $t = 2 * M_PI * $i / $n; $c = cos($t); $s = sin($t);
        $rr = (abs($c) ** $p + abs($s) ** $p) ** (-1 / $p);
        $nz = (sin(3 * $t + $ph[0]) + 0.8 * sin(5 * $t + $ph[1]) + 0.6 * sin(8 * $t + $ph[2]) + 0.4 * sin(13 * $t + $ph[3])) / 2.8;
        $pts[] = [$cx + $a * $rr * $c + $jit * $nz * $c, $cy + $b * $rr * $s + $jit * $nz * $s];
    }
    $d = 'M' . myc_f(($pts[0][0] + $pts[$n - 1][0]) / 2) . ' ' . myc_f(($pts[0][1] + $pts[$n - 1][1]) / 2);
    for ($i = 0; $i < $n; $i++) {
        $pp = $pts[$i]; $q = $pts[($i + 1) % $n];
        $d .= 'Q' . myc_f($pp[0]) . ' ' . myc_f($pp[1]) . ' ' . myc_f(($pp[0] + $q[0]) / 2) . ' ' . myc_f(($pp[1] + $q[1]) / 2);
    }
    return $d . 'Z';
}

/** Rough text width in map units. */
function myc_tw(string $t, float $fs): float
{
    $w = 0.0;
    foreach (mb_str_split($t) as $ch) $w += mb_ord($ch) > 0x2000 ? $fs * 1.15 : (ctype_upper($ch) ? $fs * 0.76 : $fs * 0.62);
    return $w + 6;
}

function myc_wrap(string $t, int $lim): array
{
    if (mb_strlen($t) <= $lim || !str_contains($t, ' ')) return [$t];
    $best = 0; $bd = PHP_INT_MAX;
    foreach (mb_str_split($t) as $i => $c) if ($c === ' ' && abs($i - mb_strlen($t) / 2) < $bd) { $bd = (int)abs($i - mb_strlen($t) / 2); $best = $i; }
    return [trim(mb_substr($t, 0, $best)), trim(mb_substr($t, $best))];
}

/** Do two boxes [x0,y0,x1,y1] overlap (with a margin)? */
function myc_hit(array $a, array $b, float $m = 0): bool
{
    return $a[0] < $b[2] + $m && $a[2] > $b[0] - $m && $a[1] < $b[3] + $m && $a[3] > $b[1] - $m;
}

/** Does the curve a→b (control c) pass through any of these boxes? Counts the samples inside. */
function myc_curve_hits(array $a, array $c, array $b, array $boxes): int
{
    $n = 0;
    for ($i = 1; $i < 12; $i++) {
        [$x, $y] = map_bez($a, $c, $b, $i / 12);
        foreach ($boxes as $bx) if ($x > $bx[0] && $x < $bx[2] && $y > $bx[1] && $y < $bx[3]) { $n++; break; }
    }
    return $n;
}

/** The bend of a thread: tries a few and keeps the one that passes through the fewest markers. */
function myc_thread_ctrl(array $a, array $b, array $boxes, int $salt): array
{
    $dx = $b[0] - $a[0]; $dy = $b[1] - $a[1]; $len = max(1.0, hypot($dx, $dy));
    $nx = -$dy / $len; $ny = $dx / $len; $best = null;
    foreach ([0.0, 0.14, -0.14, 0.28, -0.28, 0.42, -0.42] as $i => $o) {
        if ($o === 0.0) $o = (($salt & 1) ? 0.07 : -0.07);   // never dead straight
        $c = [($a[0] + $b[0]) / 2 + $nx * $o * $len, ($a[1] + $b[1]) / 2 + $ny * $o * $len];
        $s = myc_curve_hits($a, $c, $b, $boxes) * 10 + abs($o) * 6;
        if ($best === null || $s < $best[0]) $best = [$s, $c];
    }
    return $best[1];
}

// ---------------------------------------------------------------------------------------------------------------------
// Glyphs (drawn round 0,0)
// ---------------------------------------------------------------------------------------------------------------------

function myc_cottage(float $s = 1.0): string
{
    return '<g transform="scale(' . myc_f($s) . ')"><rect x="-10" y="-7" width="20" height="14" rx="2" fill="#f2e4c4"/><path d="M-13-6q13-13 26 0z" fill="#c9573f"/>'
        . '<path d="M-3 7v-6q3-4 6 0v6z" fill="#7a4a24"/><path d="M-1.8 7v-4q1.8-2.4 3.6 0v4z" class="mglow"/><rect x="5" y="-4" width="3" height="3" rx=".5" class="mglow"/><rect x="6" y="-16" width="4" height="6" fill="#8a5a3a"/></g>';
}

function myc_glyph(string $k, int $seed = 0): string
{
    switch ($k) {
        case 'town':
            return '<g transform="translate(-27 4) scale(.85)"><rect x="-9" y="-2" width="18" height="10" rx="1" fill="#9a6a3a"/><path d="M-11-2l2-8h18l2 8z" fill="#fff3d8"/>'
                . '<path d="M-9-10h4.5l-1 8h-3zM0-10h4.5l-.5 8h-3zM-4.5-10H0l-.5 8H-3.5zM4.5-10H9l1 8H5z" fill="#d9573f"/><circle cx="-4" cy="3" r="2" fill="#e2b13c"/><circle cx="1" cy="3.5" r="2" fill="#d9573f"/><circle cx="5.5" cy="3" r="2" fill="#7fb24a"/></g>'
                . '<g transform="translate(0 3) scale(.85)"><path d="M-8 6v-8h16v8z" fill="#9a9c98"/><ellipse cy="-2" rx="8" ry="3" fill="#5f7a8a"/><path d="M-8-2v-9M8-2v-9" stroke="#7a4e2c" stroke-width="2"/><path d="M-10-11h20l-3-5h-14z" fill="#b05a3a"/></g>'
                . '<g transform="translate(27 4)">' . myc_cottage(0.85) . '</g>';
        case 'village': return myc_cottage(1.0);
        case 'haven':
            return '<path d="M-11 7q-1-12 11-13t11 13z" fill="#7a4a24"/><path d="M-8 7q0-9 8-10t8 10z" fill="#ffe29a"/><rect x="-1.5" y="-3" width="3" height="9" rx="1.5" fill="#d98a3a"/>'
                . '<path d="M0-4q-3-2-3-5 3 1 3 5 0-4 3-5 0 3-3 5z" fill="#ffd25a"/><path d="M-6 7h12" stroke="#5a3a22" stroke-width="2"/>';
        case 'wonder':
            return '<circle r="14" class="mwonder"/><path d="M-8 7l3-13 3 13zM-2 7l4-18 4 18zM5 7l3-11 3 11z" fill="#c9a4ff"/><path d="M-4 7l2-9 2 9z" fill="#a9d8ff"/><path d="M-1-9l1-3 1 3z" fill="#fff"/>';
        case 'lair':
            return '<path d="M-13 8q-3-14 13-15t13 15z" fill="#241a22"/><path d="M-9 8q0-9 9-9t9 9z" fill="#120c14"/><circle cx="-4" cy="2" r="2.8" fill="#ffd25a"/><circle cx="4" cy="2" r="2.8" fill="#ffd25a"/>'
                . '<circle cx="-4" cy="2" r="1.1" fill="#2a1a10"/><circle cx="4" cy="2" r="1.1" fill="#2a1a10"/><path d="M-12 9l4-4M10 9l3-3" stroke="#d8cbb0" stroke-width="1.6" stroke-linecap="round"/>';
        case 'delve':
            return '<path d="M-9 4q0-11 9-11t9 11z" fill="#4a3a30"/><ellipse cy="4" rx="7" ry="4" fill="#1a1016"/><path d="M-4 4v-9M4 4v-9M-4-1h8M-4-4h8" stroke="#8a6a4a" stroke-width="1.3" fill="none"/><circle cx="-2" cy="6" r="1.2" fill="#ffd25a"/>';
        case 'ruins':
            return '<path d="M-13 8h26" stroke="#8c8478" stroke-width="3" stroke-linecap="round"/><path d="M-11 8V-4l3-3v10M-3 8V-9h4V8M7 8V0l3-2v10" fill="#a39b8d"/><path d="M-3-9h4v3h-4z" fill="#c9c1b2"/>';
        case 'exit':
            return '<path d="M-11-11h10a11 11 0 0 1 0 22h-10z" class="mdoor"/><path d="M-8-8h8a8 8 0 0 1 0 16h-8z" fill="#fff1b8"/><path d="M-3-4l6 4-6 4" fill="none" class="mdoorarrow"/>';
    }
    return '';
}

// ---------------------------------------------------------------------------------------------------------------------
// Overlay data: folk you know, quest targets, gathering
// ---------------------------------------------------------------------------------------------------------------------

function myc_species_icon(string $sp): string
{
    $s = strtolower($sp);
    foreach (['hedgehog' => '🦔', 'mouse' => '🐭', 'shrew' => '🐭', 'ladybird' => '🐞', 'bumblebee' => '🐝', 'snail' => '🐌', 'frog' => '🐸', 'toad' => '🐸', 'grasshopper' => '🦗',
        'cricket' => '🦗', 'tortoise' => '🐢', 'beetle' => '🪲', 'wren' => '🐦', 'mole' => '🐾', 'dragonfly' => '🪰', 'hare' => '🐇', 'gecko' => '🦎', 'butterfly' => '🦋',
        'moth' => '🦋', 'firefly' => '✨', 'bat' => '🦇', 'stick' => '🌿'] as $k => $ic) if (str_contains($s, $k)) return $ic;
    return '👤';
}

/** The folk this gnome knows and the place each is at right now: [[name, icon, location id]] (a town, or their home when resting). */
function myc_folk(int $uid): array
{
    static $memo = [];
    if (isset($memo[$uid])) return $memo[$uid];
    $out = [];
    $towns = [];
    foreach (known_npcs($uid) as $n) {
        $loc = 0;
        $now = $n['now'] ?? [];
        if (!empty($now['home']) && !empty($n['home_location_id'])) $loc = (int)$n['home_location_id'];
        elseif (!empty($now['town'])) {
            $t = (string)$now['town'];
            if (!isset($towns[$t])) $towns[$t] = (int)q_val("SELECT id FROM locations WHERE kind IN ('market', 'hub') AND region = ? ORDER BY kind LIMIT 1", [$t]);
            $loc = $towns[$t];
        }
        if ($loc) $out[] = [(string)$n['name'], myc_species_icon((string)($n['species'] ?? '')), $loc, (string)($now['what'] ?? '')];
    }
    return $memo[$uid] = $out;
}

/**
 * Where this gnome has something to do: [[location id (0 = look up by region), region id, text]]. Only things the gnome has
 * already been told about: the chapter they're on (its region's town), jobs they took (where that NPC lives), ruins they
 * are repairing. Today's letter is a riddle, so it is not shown.
 */
function myc_quests(array $u): array
{
    static $memo = [];
    $uid = (int)$u['id'];
    if (isset($memo[$uid])) return $memo[$uid];
    $out = [];
    $townOf = fn(int $rid): int => (int)q_val("SELECT id FROM locations WHERE region_id = ? AND kind = 'market' ORDER BY id LIMIT 1", [$rid]);
    require_once __DIR__ . '/journey.php';
    require_once __DIR__ . '/npc_life.php';
    if ($ch = journey_current($u)) {
        $t = $townOf((int)$ch['region_id']);
        if ($t) $out[] = [$t, (int)$ch['region_id'], 'Journey: ' . (string)$ch['title']];
    }
    foreach (q("SELECT npc, title FROM user_jobs WHERE user_id = ? AND status = 'active'", [$uid])->fetchAll() as $j) {
        if (!$j['npc']) continue;
        $nid = (int)q_val('SELECT id FROM npcs WHERE name = ?', [$j['npc']]);
        if (!$nid) continue;
        $home = npc_home(['id' => $nid]);
        $reg = $home ? (int)q_val('SELECT id FROM regions WHERE gnomish_name = ?', [$home['region']]) : 0;
        $t = $reg ? $townOf($reg) : 0;
        if ($t) $out[] = [$t, $reg, 'Job: ' . (string)$j['title'] . ' (' . (string)$j['npc'] . ')'];
    }
    foreach (q('SELECT m.location_id, m.region_id, m.name FROM landmark_repairs r JOIN landmarks m ON m.id = r.landmark_id WHERE r.user_id = ? AND r.done_at IS NULL AND r.dropped_at IS NULL', [$uid])->fetchAll() as $r) {
        if ($r['location_id']) $out[] = [(int)$r['location_id'], (int)$r['region_id'], 'Repair: ' . (string)$r['name']];
    }
    return $memo[$uid] = $out;
}

/** The gathering tools that find something in a land, as [icon, has-it]. */
function myc_gather_icons(array $u, string $land): array
{
    static $memo = [];
    $k = (int)$u['id'] . '|' . $land;
    if (isset($memo[$k])) return $memo[$k];
    require_once __DIR__ . '/gathering.php';
    $out = [];
    foreach (gather_here_tools($u, $land) as $t) $out[] = [(string)$t['icon'], (bool)$t['has'], (string)$t['label']];
    return $memo[$k] = $out;
}

// ---------------------------------------------------------------------------------------------------------------------
// Region data (same topology as the classic map: town → road villages → exit, side places beside their road stop)
// ---------------------------------------------------------------------------------------------------------------------

function myc_region_data(array $u, int $regionId, int $selId): ?array
{
    $reg = q_one('SELECT * FROM regions WHERE id = ?', [$regionId]);
    if (!$reg || !isset(REGION_MAP[$reg['code']])) return null;
    $town = q_one("SELECT id, name, slug, kind, landscape, region FROM locations WHERE region_id = ? AND kind = 'market' ORDER BY id LIMIT 1", [$regionId]);
    if (!$town) return null;
    $uid = (int)$u['id'];
    $tid = (int)$town['id'];
    [$wx, $wy] = REGION_MAP[$reg['code']];
    $items = [$tid => ['id' => $tid, 'x' => 200.0, 'y' => 150.0, 'loc' => $town, 'type' => 'town', 'k' => 'town', 'seen' => true, 'ang' => 0.0, 'ruin' => false]];
    $onRoad = [$tid => true];
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
        $E = [max(42.0, min(358.0, 200 + cos($ang) * 165)), max(44.0, min(256.0, 150 + sin($ang) * 115))];
        $ctl = road_ctrl([200.0, 150.0], $E);
        $list = [$tid];
        for ($i = 1; $i < $n; $i++) {
            $loc = q_one('SELECT id, name, slug, kind, landscape, region FROM locations WHERE id = ?', [$nodes[$i]]);
            if (!$loc) continue;
            [$px, $py] = map_bez([200.0, 150.0], $ctl, $E, $n > 2 ? 0.3 + 0.7 * ($i - 1) / ($n - 2) : 1.0);
            $onRoad[$nodes[$i]] = true;
            $far_ = $i === $n - 1;
            $items[$nodes[$i]] = ['id' => $nodes[$i], 'x' => $px, 'y' => $py, 'loc' => $loc, 'type' => $far_ ? 'far' : 'stop', 'k' => 'village', 'ang' => $ang,
                'farname' => (string)($far['gnomish_name'] ?? $loc['region']), 'seen' => $far_ || place_known($uid, $loc), 'ruin' => false];
            $list[] = $nodes[$i];
        }
        $roads[] = [(string)$rd['name'], $list];
    }
    $kids = [];
    foreach (q("SELECT a_id, b_id FROM routes WHERE kind = 'side' ORDER BY id")->fetchAll() as $rt) {
        [$a, $b] = [(int)$rt['a_id'], (int)$rt['b_id']];
        if (isset($items[$a]) && !isset($onRoad[$b])) $kids[$a][] = $b;
        elseif (isset($items[$b]) && !isset($onRoad[$a])) $kids[$b][] = $a;
    }
    $kidNo = [];
    foreach ($kids as $anchor => $list) foreach (array_values(array_unique($list)) as $k => $id) $kidNo[$id] = [$anchor, $k];
    foreach (q("SELECT l.id, l.name, l.slug, l.kind, l.landscape, l.region, (SELECT kind FROM landmarks WHERE location_id = l.id ORDER BY id LIMIT 1) AS lmkind,
        (SELECT COUNT(*) FROM landmarks m WHERE m.location_id = l.id AND m.kind IN ('haven', 'wonder', 'delve') AND m.ruined = 1
           AND NOT EXISTS (SELECT 1 FROM landmark_rebuilds b WHERE b.landmark_id = m.id AND b.user_id = ?)) AS ruin
        FROM locations l WHERE l.region_id = ? AND l.kind NOT IN ('market', 'hub') ORDER BY l.id", [$uid, $regionId])->fetchAll() as $l) {
        $id = (int)$l['id'];
        if (isset($onRoad[$id]) || !place_known($uid, $l)) continue;   // hidden places stay hidden
        $h = crc32((string)$l['slug']);
        if (isset($kidNo[$id])) {
            [$anchor, $k] = $kidNo[$id];
            $ring = intdiv($k, 2);
            $base = ($items[$anchor]['ang'] ?? (($h & 1023) / 1023 * 6.283)) + ($k % 2 ? -1 : 1) * M_PI / 2 + ($ring ? ($ring % 2 ? 0.5 : -0.5) : 0);
            $d = 46 + $ring * 12;
            $px = $items[$anchor]['x'] + cos($base) * $d;
            $py = $items[$anchor]['y'] + sin($base) * $d;
        } else {
            $a = ($h & 1023) / 1023 * 6.283;
            $d = 0.55 + (($h >> 10) & 255) / 255 * 0.4;
            $px = 200 + cos($a) * $d * 150;
            $py = 150 + sin($a) * $d * 105;
        }
        $lk = (string)($l['lmkind'] ?: $l['kind']);
        if ($lk === 'place') $lk = 'village';
        $items[$id] = ['id' => $id, 'x' => $px, 'y' => $py, 'loc' => $l, 'type' => 'off', 'k' => $lk === 'village' ? 'village' : $lk, 'ang' => 0.0,
            'ruin' => (int)$l['ruin'] > 0, 'anchor' => $kidNo[$id][0] ?? 0, 'seen' => true];
    }
    return ['reg' => $reg, 'town' => $town, 'items' => $items, 'roads' => $roads, 'wx' => $wx, 'wy' => $wy];
}

// ---------------------------------------------------------------------------------------------------------------------
// Region layout: nodes pushed apart as boxes (marker + its label) until nothing overlaps; the chamber is only as tall as that needs.
// ---------------------------------------------------------------------------------------------------------------------

/** Size of a node's marker: [half width, half height]. */
function myc_node_rr(array $it): array
{
    return match ($it['type']) {
        'town' => [46.0, 26.0],
        'far' => [14.0, 14.0],
        'stop' => $it['seen'] ? [22.0, 18.0] : [15.0, 15.0],
        default => ($it['k'] === 'village' ? [22.0, 18.0] : [16.0, 15.0]),
    };
}

/** The label text for a node, or '' when it goes unnamed (unvisited stops are a ?, small sites are named when there's room). */
function myc_node_label(array $it, bool $wide, bool $force): string
{
    if ($it['type'] === 'town') return (string)$it['loc']['name'];
    if ($it['type'] === 'far') return '→ ' . $it['farname'];
    if (!$it['seen']) return '';
    // v1.6.1: names only on the big places (towns, havens, wonders, delves, lairs, ruins) and where you are / have something to do / tapped;
    // plain villages carry their name in the tap target (aria-label, title) and on the place panel after a tap
    if ($it['k'] === 'village' && !$force) return '';
    return mb_strimwidth((string)$it['loc']['name'], 0, $it['k'] === 'village' ? 30 : 22, '…');
}

/**
 * Lays the items out inside a chamber $W wide: returns [items with x,y,label lines,box, chamber height]. The chamber grows
 * (up to $maxH) until the markers and their names fit without touching; it never grows more than that.
 */
function myc_region_layout(array $items, float $W, float $x0, float $x1, bool $wide, array $force, float $minH): array
{
    $fs = 13.0;
    $lim = $wide ? 20 : 14;
    $pad = 28.0;
    foreach ($items as $id => &$it) {
        [$rx, $ry] = myc_node_rr($it);
        $txt = myc_node_label($it, $wide, isset($force[$id]));
        $lines = $txt === '' ? [] : myc_wrap($txt, $lim);
        $lw = $lines ? max(array_map(fn($t) => myc_tw($t, $fs), $lines)) : 0.0;
        $lh = $lines ? count($lines) * ($fs + 2) + 5 : 0.0;
        $it['rx'] = $rx; $it['ry'] = $ry; $it['lines'] = $lines; $it['lw'] = $lw; $it['lh'] = $lh;
        $cw = 0;   // gathering chips are an overlay (shown by the Gathering filter) and take no room here
        $it['cw'] = $cw;
        $it['ch'] = $cw ? 28.0 : 0.0;
        $it['bw'] = max($rx * 2 + (!empty($it['rail']) ? 46 : 10), $lw + 6, $cw + 6);   // box = marker + the corners for quest/folk badges + name + chip
        $it['bh'] = $ry * 2 + $lh + $it['ch'] + 8;
        $it['oy'] = ($lh + $it['ch']) / 2;            // box centre sits below the marker centre
        $it['mx'] = $it['my'] = 1.0;
        $it['ox'] = 0.0;
        $it['side'] = '';
    }
    unset($it);
    $ids = array_keys($items);
    $cnt = count($ids);
    $area = 0.0;
    foreach ($items as $it) $area += ($it['bw'] + 8) * ($it['bh'] + 8);
    $H = max($minH, min(1500.0, $area * 1.12 / max(120.0, $x1 - $x0 - 2 * $pad) + 2 * $pad));
    $rough = $items;
    $okAll = false;
    for ($try = 0; $try < 40; $try++) {
        $items = $rough;
        $ax0 = $x0 + $pad; $ax1 = $x1 - $pad; $ay0 = $pad; $ay1 = $H - $pad;
        // 1) stretch the rough geography over the whole chamber (exits snap to the nearest wall)
        $xs = []; $ys = [];
        foreach ($items as $it) { if ($it['type'] !== 'far') { $xs[] = $it['x']; $ys[] = $it['y']; } }
        $minX = min($xs); $maxX = max($xs); $minY = min($ys); $maxY = max($ys);
        $sx = $maxX - $minX > 1 ? 1.0 / ($maxX - $minX) : 0.0;
        $sy = $maxY - $minY > 1 ? 1.0 / ($maxY - $minY) : 0.0;
        foreach ($items as &$it) {
            $mxn = $it['type'] === 'far' ? 40.0 : $it['rx'] + 6; $myn = $it['type'] === 'far' ? 40.0 : $it['ry'] + 6;
            $u_ = $sx ? ($it['x'] - $minX) * $sx : 0.5;
            $v_ = $sy ? ($it['y'] - $minY) * $sy : 0.5;
            $it['x'] = $ax0 + $mxn * 0 + ($ax1 - $ax0) * max(0.0, min(1.0, $u_));
            $it['y'] = $ay0 + ($ay1 - $ay0) * max(0.0, min(1.0, $v_));
            if ($it['type'] === 'far') {
                $best = null; $bd = INF;
                foreach ([[$ax0 - 6, $it['y'], 'W'], [$ax1 + 6, $it['y'], 'E'], [$it['x'], $ay0 - 4, 'N'], [$it['x'], $ay1 + 4, 'S']] as $c) {
                    $d = hypot($c[0] - $it['x'], $c[1] - $it['y']);
                    if ($d < $bd) { $bd = $d; $best = $c; }
                }
                [$it['x'], $it['y'], $it['side']] = $best;
                if ($it['side'] === 'W' || $it['side'] === 'E') $it['mx'] = 0.0; else $it['my'] = 0.0;
                // an exit's name goes inward: its box is shifted off the wall
                $it['oy'] = ($it['side'] === 'S' ? -1 : 1) * $it['lh'] / 2;
                $it['ox'] = $it['side'] === 'W' ? max(0.0, $it['lw'] / 2 - 10) : ($it['side'] === 'E' ? -max(0.0, $it['lw'] / 2 - 10) : 0.0);   // its name slides inward off the wall
            }
        }
        unset($it);
        $clamp = function (array &$it) use ($ax0, $ax1, $ay0, $ay1): void {
            if ($it['mx'] > 0) $it['x'] = max($ax0 + $it['rx'] + 4, min($ax1 - $it['rx'] - 4, $it['x']));
            if ($it['my'] > 0) $it['y'] = max($ay0 + $it['ry'] + 8, min($ay1 - $it['ry'] - $it['lh'] - $it['ch'], $it['y']));
        };
        foreach ($items as &$it) $clamp($it);
        unset($it);
        // 2) push apart (boxes: marker + label)
        $gap = 4.0;
        $overlap = 0;
        for ($pass = 0; $pass < 90; $pass++) {
            $moved = false;
            for ($i = 0; $i < $cnt; $i++) {
                for ($j = $i + 1; $j < $cnt; $j++) {
                    $a = &$items[$ids[$i]]; $b = &$items[$ids[$j]];
                    $dx = ($b['x'] + $b['ox']) - ($a['x'] + $a['ox']); $dy = ($b['y'] + $b['oy']) - ($a['y'] + $a['oy']);
                    $ox = ($a['bw'] + $b['bw']) / 2 + $gap - abs($dx);
                    $oy = ($a['bh'] + $b['bh']) / 2 + $gap - abs($dy);
                    if ($ox <= 0 || $oy <= 0) { unset($a, $b); continue; }
                    $horiz = $ox <= $oy * 0.8;   // slide sideways when that's the smaller move (the chamber is narrow, so lean to up/down)
                    if ($horiz) { $fa = $a['mx']; $fb = $b['mx']; } else { $fa = $a['my']; $fb = $b['my']; }
                    if ($fa + $fb < 0.01) { $horiz = !$horiz; if ($horiz) { $fa = $a['mx']; $fb = $b['mx']; } else { $fa = $a['my']; $fb = $b['my']; } }
                    if ($fa + $fb < 0.01) { unset($a, $b); continue; }
                    $push = ($horiz ? $ox : $oy) * 0.55 + 0.5;
                    $dir = $horiz ? ($dx >= 0 ? 1 : -1) : ($dy >= 0 ? 1 : -1);
                    if ($horiz && abs($dx) < 0.5) $dir = (($i + $j) % 2) ? 1 : -1;
                    if (!$horiz && abs($dy) < 0.5) $dir = (($i + $j) % 2) ? 1 : -1;
                    $ka = $fa / ($fa + $fb); $kb = $fb / ($fa + $fb);
                    if ($horiz) { $a['x'] -= $dir * $push * $ka; $b['x'] += $dir * $push * $kb; }
                    else { $a['y'] -= $dir * $push * $ka; $b['y'] += $dir * $push * $kb; }
                    $clamp($a); $clamp($b);
                    $moved = true;
                    unset($a, $b);
                }
            }
            if (!$moved) break;
        }
        // 3) any pair still touching? then the chamber is too small
        for ($i = 0; $i < $cnt && !$overlap; $i++) {
            for ($j = $i + 1; $j < $cnt; $j++) {
                $a = $items[$ids[$i]]; $b = $items[$ids[$j]];
                if (abs(($b['x'] + $b['ox']) - ($a['x'] + $a['ox'])) < ($a['bw'] + $b['bw']) / 2 - 1 && abs(($b['y'] + $b['oy']) - ($a['y'] + $a['oy'])) < ($a['bh'] + $b['bh']) / 2 - 1) { $overlap++; break; }
            }
        }
        if (!$overlap || $H >= 1500.0) { $okAll = !$overlap; break; }
        $H = min(1500.0, $H * 1.05 + 8);
    }
    // 3b) settle: pack the markers upwards, each taking the highest spot (near where it was) that doesn't touch one already placed,
    // so no band of the chamber is left empty
    $ord = $ids;
    usort($ord, fn($p, $q) => $items[$p]['y'] <=> $items[$q]['y']);
    $done = [];
    foreach ($ord as $id) if ($items[$id]['side'] === 'N') $done[] = $id;   // roof exits are fixed: others pack beneath them
    foreach ($ord as $id) {
        if (in_array($items[$id]['side'], ['N', 'S'], true)) continue;   // exits on the roof and floor stay there
        $a = $items[$id];
        $xs_ = $a['mx'] > 0 ? [] : [$a['x']];   // wall exits keep their x
        $half = max($a['rx'] + 4, min($a['bw'] / 2, 60.0));
        if ($a['mx'] > 0) for ($cx = $ax0 + $half; $cx <= $ax1 - $half + 0.1; $cx += 12) $xs_[] = $cx - $a['ox'];
        if (!$xs_) $xs_[] = $a['x'];
        $best = null;
        foreach ($xs_ as $cx) {
            $ny = $pad + $a['ry'] + 8;
            foreach ($done as $oid) {
                $o = $items[$oid];
                if (abs(($cx + $a['ox']) - ($o['x'] + $o['ox'])) < ($a['bw'] + $o['bw']) / 2 + 3)
                    $ny = max($ny, $o['y'] + $o['oy'] + $o['bh'] / 2 + 3 - $a['oy'] + $a['bh'] / 2);
            }
            $ny = min($ny, $a['y'] + 0.01) === $ny ? $ny : $a['y'];   // never lower than it was
            $sc = $ny + 0.55 * abs($cx - $a['x']);
            if ($best === null || $sc < $best[0]) $best = [$sc, $cx, $ny];
        }
        $items[$id]['x'] = $best[1]; $items[$id]['y'] = $best[2];
        $done[] = $id;
    }
    $lowest = 0.0;
    foreach ($items as $it) if (!in_array($it['side'], ['N', 'S'], true)) $lowest = max($lowest, $it['y'] + $it['ry'] + $it['lh'] + 8);
    foreach ($items as &$it) if ($it['side'] === 'S') $it['y'] = $lowest + 14;   // floor exits sit just under the lowest place
    unset($it);
    // 4) trim: the chamber is as tall as the lowest thing in it (and the highest), plus padding
    $top = INF; $bot = -INF;
    foreach ($items as $it) {
        $top = min($top, $it['y'] - $it['ry'] - 8);
        $bot = max($bot, $it['y'] + $it['ry'] + $it['lh'] + $it['ch'] + 4);
    }
    $shift = $top - $pad;
    if ($shift > 4) foreach ($items as &$it) $it['y'] -= $shift;
    unset($it);
    $H = ceil(max($minH * 0.8, $bot - max(0.0, $shift > 4 ? $shift : 0.0) + $pad) / 16) * 16;   // whole steps of 16, so the cached picture is reused
    foreach ($items as &$it) { $it['x'] = round($it['x'], 1); $it['y'] = round($it['y'], 1); }
    unset($it);
    return [$items, $H];
}

// ---------------------------------------------------------------------------------------------------------------------
// The region map
// ---------------------------------------------------------------------------------------------------------------------

/** Static backdrop of a region picture: sky/surface, strata, roots/shaft, gauge, chamber shell. Same for everyone, so cached. */
function myc_backdrop(string $key, array $g): string
{
    return myc_cached('rb-' . $key . '-' . (int)$g['Wd'] . 'x' . (int)$g['Ht'] . '-' . $g['depth'] . '-' . (int)$g['pxr'] . '-' . $g['fill'], function () use ($key, $g): string {
        [$W, $Ht, $sy, $surface, $depth, $d0, $y0, $GW, $cx0, $cy0, $cx1, $cy1] = [$g['Wd'], $g['Ht'], $g['sy'], $g['surface'], $g['depth'], $g['d0'], $g['y0'], $g['GW'], $g['cx0'], $g['cy0'], $g['cx1'], $g['cy1']];
        $fill = $g['fill']; $rim = $g['rim'];
        $pxr = (float)$g['pxr'];
        $ay = fn(float $r): float => $y0 + ($r - $d0) * $pxr;
        $s = '<defs><clipPath id="cv' . $key . '"><path d="' . $g['cav'] . '"/></clipPath><clipPath id="rk' . $key . '"><rect x="0" y="' . myc_f($y0) . '" width="' . myc_f($W) . '" height="' . myc_f($Ht - $y0) . '"/></clipPath>'
            . '<linearGradient id="lt' . $key . '" x1="0" y1="0" x2="0" y2="1"><stop offset="0" class="mlt0"/><stop offset="1" class="mlt1"/></linearGradient>'
            . '<radialGradient id="cl' . $key . '" cx=".5" cy=".5" r=".65"><stop offset="0" class="mlight" stop-opacity=".5"/><stop offset="1" class="mlight" stop-opacity="0"/></radialGradient>'
            . '</defs>';
        // sky and surface
        if ($surface) {
            $r = new MycRng('sky' . $key);
            $s .= '<rect width="' . myc_f($W) . '" height="' . myc_f($sy + 4) . '" class="msky"/><g class="mstars">';
            for ($i = 0; $i < (int)($W / 11); $i++) $s .= '<circle cx="' . myc_f($r->range(0, $W)) . '" cy="' . myc_f($r->range(4, $sy - 40)) . '" r="' . myc_f($r->range(0.7, 1.5)) . '" fill="#fff" opacity="' . myc_f($r->range(0.4, 0.95)) . '"/>';
            $s .= '</g><circle cx="' . myc_f($W * 0.2) . '" cy="44" r="30" class="msun" opacity=".25"/><circle cx="' . myc_f($W * 0.2) . '" cy="44" r="16" class="msun"/>';
            foreach ([[0.45, 30, 1.0], [0.72, 54, 0.75]] as [$cx, $cy, $sc]) $s .= '<g transform="translate(' . myc_f($W * $cx) . ' ' . $cy . ') scale(' . $sc . ')" class="mcloud"><ellipse rx="26" ry="8"/><circle cx="-8" cy="-7" r="9"/><circle cx="8" cy="-9" r="11"/></g>';
            $s .= '<path d="M0 ' . myc_f($sy - 26) . 'Q' . myc_f($W * 0.15) . ' ' . myc_f($sy - 48) . ' ' . myc_f($W * 0.32) . ' ' . myc_f($sy - 28) . 'T' . myc_f($W * 0.64) . ' ' . myc_f($sy - 34) . 'T' . myc_f($W) . ' ' . myc_f($sy - 22) . 'V' . myc_f($sy + 4) . 'H0z" class="mhill1"/>'
                . '<path d="M0 ' . myc_f($sy - 12) . 'Q' . myc_f($W * 0.2) . ' ' . myc_f($sy - 28) . ' ' . myc_f($W * 0.4) . ' ' . myc_f($sy - 12) . 'T' . myc_f($W * 0.78) . ' ' . myc_f($sy - 18) . 'T' . myc_f($W) . ' ' . myc_f($sy - 9) . 'V' . myc_f($sy + 4) . 'H0z" class="mhill2"/>';
            // trees tinted by the region's own colour
            $nt = max(5, (int)($W / 60));
            for ($i = 0; $i < $nt; $i++) {
                $tx = $GW + 20 + ($W - $GW - 40) * ($i + $r->range(0.1, 0.9)) / $nt;
                $sc = $r->range(0.8, 1.25);
                $s .= '<g transform="translate(' . myc_f($tx) . ' ' . myc_f($sy + 2) . ') scale(' . myc_f($sc) . ')"><rect x="-2" y="-14" width="4" height="14" rx="1.5" fill="#7a4e2c"/>'
                    . '<circle cy="-24" r="10" fill="' . $fill . '"/><circle cx="-7" cy="-18" r="7" fill="' . $fill . '"/><circle cx="7" cy="-19" r="7.5" fill="' . $fill . '"/><circle cx="-2" cy="-28" r="5" fill="#fff" opacity=".22"/></g>';
            }
        }
        // rock bands (dark, outside the chamber)
        $bands = [];
        foreach (MYC_STRATA as $i => [$nm, $a, $b]) {
            $t = max($ay($a), $y0); $bt = $b < 900 ? min($ay($b), $Ht) : $Ht;
            if ($bt > $t + 2) $bands[] = [$t, $bt, $i, $nm];
        }
        $rock = '';
        foreach ($bands as $i => [$t, $bt, $idx]) $rock .= '<path d="' . myc_wavy($i || !$surface ? $t : $t + 2, $W, $key . $idx, 6) . 'L' . myc_f($W) . ' ' . myc_f($Ht) . 'L0 ' . myc_f($Ht) . 'Z" class="msoil msoil' . $idx . '"/>';
        $r2 = new MycRng('st' . $key);
        foreach ($bands as $i => [$t, $bt, $idx]) {
            if ($i) $rock .= '<path d="' . myc_wavy($t, $W, $key . $idx, 6) . '" class="seam"/>';
            for ($j = 0, $n = (int)(($bt - $t) / 50); $j < $n; $j++) $rock .= '<path d="' . myc_wavy($r2->range($t + 12, $bt - 12), $W, $key . 's' . $i . $j, 5) . '" class="strata"/>';
        }
        $s .= '<g clip-path="url(#rk' . $key . ')">' . $rock . '<rect x="0" y="' . myc_f($y0) . '" width="' . myc_f($W) . '" height="' . myc_f($Ht) . '" class="rockdim"/></g>';
        if ($surface) $s .= '<path d="' . myc_wavy($sy + 1, $W, $key . 'turf', 2) . 'L' . myc_f($W) . ' ' . myc_f($sy + 9) . 'L0 ' . myc_f($sy + 9) . 'Z" class="turf"/>';
        // roots down from the surface into the chamber roof, or the shaft up to the surface
        if ($surface) {
            $rr = new MycRng('rt' . $key);
            for ($i = 0; $i < 6; $i++) {
                $x = $rr->range($cx0 + 30, $cx1 - 30); $pts = 'M' . myc_f($x) . ' ' . myc_f($sy + 6);
                $yy = $sy + 6; $xx = $x; $L = $cy0 - $sy + $rr->range(-6, 22);
                for ($k = 0; $k < (int)($L / 9); $k++) { $xx += $rr->range(-4, 4); $yy += 9; $pts .= 'L' . myc_f($xx) . ' ' . myc_f($yy); }
                $s .= '<path d="' . $pts . '" class="rootl"/>';
            }
        } else {
            $sx = $GW + 34;
            $s .= '<g class="shaft"><path d="M' . ($sx - 13) . ' 0L' . ($sx - 10) . ' ' . myc_f($cy0 + 8) . 'L' . ($sx + 10) . ' ' . myc_f($cy0 + 8) . 'L' . ($sx + 13) . ' 0z" class="shaftbg"/>'
                . '<path d="M' . ($sx - 6) . ' 0q3 ' . myc_f($cy0 * 0.3) . ' -2 ' . myc_f($cy0 * 0.6) . 't1 ' . myc_f($cy0 * 0.4) . '" class="hy on"/><path d="M' . ($sx + 6) . ' 0q-3 ' . myc_f($cy0 * 0.3) . ' 2 ' . myc_f($cy0 * 0.6) . 't-1 ' . myc_f($cy0 * 0.4) . '" class="hy on thin"/>'
                . '<rect x="' . ($sx - 13) . '" y="0" width="26" height="16" class="mbeam"/><path d="M' . ($sx - 4) . ' 11l4-6 4 6" stroke="#fff6dc" stroke-width="2" fill="none" stroke-linecap="round" stroke-linejoin="round"/></g>';
            $lm = 'SURFACE ' . $depth;
            $s .= '<g transform="translate(' . ($sx + 20) . ' 14)"><rect x="0" y="-9" width="' . myc_f(strlen($lm) * 6.4 + 14) . '" height="18" rx="9" class="ltab"/><text x="' . myc_f((strlen($lm) * 6.4 + 14) / 2) . '" y="4" text-anchor="middle" class="layer">' . $lm . '</text></g>';
        }
        // the chamber: lit version of the same strata, the region's colour as a tint, an inner shadow and a rim in its colour
        $lit = '';
        foreach ($bands as $i => [$t, $bt, $idx]) $lit .= '<path d="' . myc_wavy($i || !$surface ? $t : $t + 2, $W, $key . $idx, 6) . 'L' . myc_f($W) . ' ' . myc_f($Ht) . 'L0 ' . myc_f($Ht) . 'Z" class="lit lit' . $idx . '"/>';
        $s .= '<g clip-path="url(#cv' . $key . ')">' . $lit
            . '<rect x="' . myc_f($cx0 - 20) . '" y="' . myc_f($cy0 - 20) . '" width="' . myc_f($cx1 - $cx0 + 40) . '" height="' . myc_f($cy1 - $cy0 + 40) . '" fill="' . $fill . '" opacity=".24"/>'
            . '<rect x="' . myc_f($cx0 - 20) . '" y="' . myc_f($cy0 - 20) . '" width="' . myc_f($cx1 - $cx0 + 40) . '" height="' . myc_f($cy1 - $cy0 + 40) . '" fill="url(#cl' . $key . ')"/>'
            . '<path d="' . $g['cav'] . '" fill="none" stroke="#0b0504" stroke-opacity=".3" stroke-width="30"/></g>'
            . '<path d="' . $g['cav'] . '" fill="none" class="cwall" stroke-width="9"/><path d="' . $g['cav'] . '" fill="none" stroke="' . $rim . '" stroke-width="3.4" stroke-opacity=".95"/>';
        // depth gauge
        $s .= '<rect x="0" y="' . myc_f($y0) . '" width="' . $GW . '" height="' . myc_f($Ht - $y0) . '" class="gauge"/>';
        $dTop = $d0 + (0 - $y0) / $pxr; $dBot = $d0 + ($Ht - $y0) / $pxr;
        for ($r = (int)ceil(max(0.0, $dTop)); $r <= $dBot; $r++) {   // a small tick for every root
            $yy = $ay((float)$r);
            if ($yy > 14 && $yy < $Ht - 6 && $r % 5) $s .= '<path d="M' . ($GW - 5) . ' ' . myc_f($yy) . 'h5" class="gtick minor"/>';
        }
        for ($r = (int)(ceil(max(0.0, $dTop) / 5) * 5); $r <= $dBot; $r += 5) {
            $yy = $ay((float)$r);
            if ($yy < 14 || $yy > $Ht - 6) continue;
            $s .= '<path d="M' . ($GW - 9) . ' ' . myc_f($yy) . 'h9" class="gtick"/><text x="' . ($GW - 11) . '" y="' . myc_f($yy + 4) . '" text-anchor="end" class="mgnum">' . $r . '</text>';
        }
        foreach ($bands as [$t, $bt, $idx, $nm]) {
            $mid = ($t + $bt) / 2;
            if ($bt - $t > 80) $s .= '<text transform="translate(11 ' . myc_f($mid) . ') rotate(-90)" text-anchor="middle" class="gband">' . strtoupper($nm) . '</text>';
        }
        return $s;
    });
}

/**
 * v1.6.1: the places worth showing in the nearby view: everything within two steps (road stops and side paths) of where you
 * stand, the road between you and the town, the town itself, any $keep ids (quest targets, the tapped place) and the exit
 * at the end of a road whose last stop is shown. Returns those items.
 */
function myc_nearby(array $items, array $roads, int $hereId, int $townId, array $keep): array
{
    $adj = [];
    foreach ($roads as [, $list]) for ($i = 1; $i < count($list); $i++) { $adj[$list[$i - 1]][] = $list[$i]; $adj[$list[$i]][] = $list[$i - 1]; }
    foreach ($items as $id => $it) if ($it['type'] === 'off' && !empty($it['anchor'])) { $adj[$id][] = $it['anchor']; $adj[$it['anchor']][] = $id; }
    $dist = [$hereId => 0]; $par = [];
    $queue = [$hereId];
    while ($queue) {
        $c = array_shift($queue);
        foreach ($adj[$c] ?? [] as $n) if (!isset($dist[$n])) { $dist[$n] = $dist[$c] + 1; $par[$n] = $c; $queue[] = $n; }
    }
    $want = [$townId => true, $hereId => true];
    foreach ($dist as $id => $d) if ($d <= 2) $want[$id] = true;
    for ($c = $townId; isset($par[$c]);) { $c = $par[$c]; $want[$c] = true; }   // the way back to the town
    foreach ($keep as $id) $want[$id] = true;
    foreach ($items as $id => $it) {   // a road's exit goes with the last stop before it
        if ($it['type'] !== 'far') continue;
        foreach ($adj[$id] ?? [] as $n) if (isset($want[$n])) $want[$id] = true;
    }
    return array_intersect_key($items, $want);
}

/**
 * One region picture, $W wide ($wide = the desktop version). $key keeps the SVG's internal ids apart ('p' / 'w').
 * Returns the <svg>, or '' when the region has no map.
 */
function myc_region_svg_one(array $u, array $D, int $selId, bool $wide, string $key, bool $near = false): string
{
    $reg = $D['reg'];
    $uid = (int)$u['id'];
    $items = $D['items'];
    $hereId = (int)(player_node($u)['id'] ?? 0);
    $depth = myc_depth((int)$reg['min_level']);
    [$bandIdx, $bandName] = myc_band($depth);
    [, , $fill] = REGION_MAP[$reg['code']] + [2 => '#8fbf6a'];
    $rim = $fill;
    $W = $wide ? 860.0 : 360.0;
    $GW = $wide ? 40.0 : 32.0;
    $cx0 = $GW + 10; $cx1 = $W - 10;
    $surface = $depth <= 16;   // the chamber window is about 24 roots tall: shallow regions show the sky, deep ones a shaft up to it
    $sy = $wide ? 150.0 : 140.0;
    $cy0 = $surface ? $sy + 34 : 50.0;
    $quests = [];
    foreach (myc_quests($u) as [$qloc, $qreg, $qtext]) {
        if ($qloc && isset($items[$qloc]) && $items[$qloc]['type'] !== 'far') $quests[$qloc][] = $qtext;
    }
    if ($near && isset($items[$hereId])) {   // v1.6.1: nearby view: two steps from where you stand, the town, and anything you have something to do at
        $keep = array_keys($quests);
        if ($selId) $keep[] = $selId;
        $items = myc_nearby($items, $D['roads'], $hereId, (int)$D['town']['id'], $keep);
    }
    $force = $quests;
    if ($hereId && isset($items[$hereId])) $force[$hereId] = true;
    if ($selId && isset($items[$selId])) $force[$selId] = true;
    $minH = $near ? 260.0 : 360.0;
    $folkAt = [];
    $townId = (int)$D['town']['id'];
    foreach (myc_folk($uid) as [$nm, $ic, $lid, $what]) {
        // only places the gnome has found: an NPC's home in a "???" stop would give it away, so those folk are shown in the town
        $target = isset($items[$lid]) && $items[$lid]['type'] !== 'far' && $items[$lid]['seen'] ? $lid : ((int)q_val('SELECT region_id FROM locations WHERE id = ?', [$lid]) === (int)$reg['id'] ? $townId : 0);
        if ($target && isset($items[$target])) $folkAt[$target][] = [$nm, $ic, $what];
    }
    foreach ($items as $id => &$it_) {   // gathering icons per place (one chip under each village or site)
        $it_['icons'] = [];
        if ($it_['seen'] && !in_array($it_['type'], ['far', 'town'], true) && !empty($it_['loc']['landscape'])) $it_['icons'] = array_slice(myc_gather_icons($u, (string)$it_['loc']['landscape']), 0, 3);
        $it_['chipn'] = count($it_['icons']);
        $it_['rail'] = isset($folkAt[$id]) || isset($quests[$id]);   // room for the quest pin / folk bubble beside it
    }
    unset($it_);
    [$items, $Hc] = myc_region_layout($items, $W, $cx0, $cx1, $wide, $force, $minH);
    foreach ($items as &$it_) $it_['y'] += $cy0;   // the layout is measured from the chamber's roof
    unset($it_);
    $cy1 = $cy0 + $Hc;
    $Ht = $cy1 + 40;
    // depth window
    $pxr = max(22.0, $Hc / 24.0);   // the same ~24 roots of depth fill every chamber, so its place in the soil is true whatever its height
    $mid = ($cy0 + $cy1) / 2;
    if ($surface) { $y0 = $sy; $d0 = 0.0; } else { $y0 = 0.0; $d0 = $depth - $mid / $pxr; }
    $ymark = max($cy0 + 14, min($cy1 - 14, $y0 + ($depth - $d0) * $pxr));
    $cav = myc_cavern_path($cx0, $cy0, $cx1, $cy1, (string)$reg['code'] . ($wide ? 'w' : 'p'));
    $fillX = ['Wd' => $W, 'Ht' => $Ht, 'sy' => $sy, 'surface' => $surface, 'depth' => $depth, 'pxr' => $pxr, 'd0' => $d0, 'y0' => $y0, 'GW' => $GW, 'cx0' => $cx0, 'cy0' => $cy0, 'cx1' => $cx1, 'cy1' => $cy1, 'fill' => $fill, 'rim' => $rim, 'cav' => $cav];
    $k = $key . strtolower((string)$reg['code']);
    $svg = '<svg class="mycsvg mycreg ' . ($wide ? 'mycw' : 'mycp') . '" viewBox="0 0 ' . myc_f($W) . ' ' . myc_f($Ht) . '" role="group" aria-label="Map of ' . e((string)$reg['gnomish_name']) . ' at about ' . $depth . ' roots down">'
        . myc_backdrop($k, $fillX);
    $svg .= '<g class="mmark"><path d="M0 ' . myc_f($ymark - 10) . 'H' . myc_f($GW) . 'L' . myc_f($GW + 9) . ' ' . myc_f($ymark) . 'L' . myc_f($GW) . ' ' . myc_f($ymark + 10) . 'H0z" class="mgold"/><text x="' . myc_f($GW / 2) . '" y="' . myc_f($ymark + 4) . '" text-anchor="middle" class="mmarkt">' . $depth . '</text></g>';

    // ----- obstacle boxes: markers, then labels, then overlays (placed below, in that order)
    $ids = array_keys($items);
    $nodeBox = [];
    foreach ($items as $id => $it) $nodeBox[$id] = [$it['x'] - $it['rx'], $it['y'] - $it['ry'], $it['x'] + $it['rx'], $it['y'] + $it['ry']];
    $area = [$cx0 + 8, $cy0 + 8, $cx1 - 8, $cy1 - 8];   // names and chips stay this far inside the wall
    $lbox = [];
    $placed = [];
    $inside = fn(array $b): bool => $b[0] >= $area[0] && $b[2] <= $area[2] && $b[1] >= $area[1] && $b[3] <= $area[3];
    $free = function (array $b, ?int $self = null) use (&$placed, $nodeBox, $inside): bool {
        if (!$inside($b)) return false;
        foreach ($nodeBox as $id => $nb) if ($id !== $self && myc_hit($b, $nb, 1)) return false;
        foreach ($placed as $o) if (myc_hit($b, $o, 2)) return false;
        return true;
    };
    // overlays that stay put (quest pin top-left of a marker, folk bubble to its left) are placed first, so names keep clear of them
    $cl = fn(float $v, float $lo, float $hi): float => max($lo, min($hi, $v));
    $ov = ['q' => '', 'f' => '', 'g' => ''];
    foreach ($quests as $id => $texts) {
        $it = $items[$id];
        $cx = $cl($it['x'] - $it['rx'] * 0.7 - 2, $area[0] + 11, $area[2] - 11); $cy = $cl($it['y'] - $it['ry'] - 6, $area[1] + 13, $area[3] - 13);
        $placed[] = [$cx - 11, $cy - 13, $cx + 11, $cy + 13];
        $ov['q'] .= '<g class="ov-q" transform="translate(' . myc_f($cx) . ' ' . myc_f($cy) . ')"><title>' . e(implode(' · ', $texts)) . '</title><path d="M0 12C-12 2 -11 -10 0 -12 11 -10 12 2 0 12z" class="mpin"/><text y="5" text-anchor="middle" class="mpint">!</text></g>';
    }
    foreach ($folkAt as $id => $list) {
        $it = $items[$id];
        $cx = $cl($it['x'] - $it['rx'] - 6, $area[0] + 14, $area[2] - 14); $cy = $cl($it['y'] + 6, $area[1] + 14, $area[3] - 14);
        $placed[] = [$cx - 14, $cy - 18, $cx + 20, $cy + 14];
        $names = implode(', ', array_map(fn($f) => $f[0], $list));
        $ov['f'] .= '<a class="ov-f" href="' . e(url('town.php?view=villagers')) . '" transform="translate(' . myc_f($cx) . ' ' . myc_f($cy) . ')" aria-label="Villagers you know here: ' . e($names) . '"><title>' . e($names) . '</title>'
            . '<circle r="14" class="mbub"/><text y="6" text-anchor="middle" class="mfolk">' . $list[0][1] . '</text>'
            . (count($list) > 1 ? '<circle cx="11" cy="-10" r="8" class="mcnt"/><text x="11" y="-6.5" text-anchor="middle" class="mcntt">' . count($list) . '</text>' : '') . '</a>';
    }
    $placed[] = [0.0, $ymark - 14, $GW + 34, $ymark + 14];   // the gold depth marker in the gauge: no names over it
    // labels: below first, then above / right / left; clamped inside the chamber
    $fs = 13;
    $order = $ids;
    usort($order, fn($a, $b) => (($items[$a]['type'] === 'town') ? 0 : (isset($force[$a]) ? 1 : 2)) <=> (($items[$b]['type'] === 'town') ? 0 : (isset($force[$b]) ? 1 : 2)) ?: $a <=> $b);
    $labels = [];
    foreach ($order as $id) {
        $it = $items[$id];
        if (!$it['lines']) continue;
        $w = $it['lw']; $h = $it['lh']; $x = $it['x']; $y = $it['y']; $rx = $it['rx']; $ry = $it['ry'];
        $below = [$x - $w / 2, $y + $ry + 1, $x + $w / 2, $y + $ry + 1 + $h];
        $above = [$x - $w / 2, $y - $ry - 1 - $h, $x + $w / 2, $y - $ry - 1];
        $right = [$x + $rx + 3, $y - $h / 2, $x + $rx + 3 + $w, $y + $h / 2];
        $left = [$x - $rx - 3 - $w, $y - $h / 2, $x - $rx - 3, $y + $h / 2];
        $cands = $it['side'] === 'W' || $it['side'] === 'E' ? [$below, $above] : ($it['side'] === 'S' ? [$above, $left, $right, $below] : [$below, $above, $right, $left]);
        $pick = null; $first = null;
        foreach ($cands as $b) {   // slide a label that pokes through the wall back inside before testing it
            $dx = 0.0; $dy = 0.0;
            if ($b[0] < $area[0]) $dx = $area[0] - $b[0]; elseif ($b[2] > $area[2]) $dx = $area[2] - $b[2];
            if ($b[1] < $area[1]) $dy = $area[1] - $b[1]; elseif ($b[3] > $area[3]) $dy = $area[3] - $b[3];
            $b2 = [$b[0] + $dx, $b[1] + $dy, $b[2] + $dx, $b[3] + $dy];
            $first ??= $b2;
            if ($free($b2, $id)) { $pick = $b2; break; }
        }
        $pick ??= $first;   // nothing free: the first choice, still slid inside the walls
        $placed[] = $pick;
        $labels[$id] = $pick;
    }
    // v1.6.4: names of the plain villages (hidden unless 🏷️ Names is on or the map is zoomed in): they take no room in the layout, so they are
    // placed here in the gaps left by everything else, trying more spots than the big names; if none is clear, the one that overlaps least
    $small = [];
    $ovl = function (array $b, int $self) use (&$placed, $nodeBox): float {
        $t = 0.0;
        foreach (array_merge(array_diff_key($nodeBox, [$self => 1]), $placed) as $o) {
            $w_ = min($b[2], $o[2]) - max($b[0], $o[0]); $h_ = min($b[3], $o[3]) - max($b[1], $o[1]);
            if ($w_ > 0 && $h_ > 0) $t += $w_ * $h_;
        }
        return $t;
    };
    foreach ($order as $id) {
        $it = $items[$id];
        if ($it['lines'] || !$it['seen'] || in_array($it['type'], ['far', 'town'], true)) continue;
        $sl = myc_wrap(mb_strimwidth((string)$it['loc']['name'], 0, 30, '…'), $wide ? 20 : 14);
        $w = max(array_map(fn($t) => myc_tw($t, $fs), $sl)); $h = count($sl) * ($fs + 2) + 5;
        $x = $it['x']; $y = $it['y']; $rx = $it['rx']; $ry = $it['ry'];
        $cands = [];
        foreach ([0.0, 9.0, 18.0, 30.0] as $g_) {   // closest first: below, above, right, left, then the corners, each a little further out
            $cands[] = [$x - $w / 2, $y + $ry + 1 + $g_, $x + $w / 2, $y + $ry + 1 + $g_ + $h];
            $cands[] = [$x - $w / 2, $y - $ry - 1 - $g_ - $h, $x + $w / 2, $y - $ry - 1 - $g_];
            $cands[] = [$x + $rx + 3 + $g_, $y - $h / 2, $x + $rx + 3 + $g_ + $w, $y + $h / 2];
            $cands[] = [$x - $rx - 3 - $g_ - $w, $y - $h / 2, $x - $rx - 3 - $g_, $y + $h / 2];
            $cands[] = [$x + $rx - 2 + $g_, $y + $ry - 2 + $g_, $x + $rx - 2 + $g_ + $w, $y + $ry - 2 + $g_ + $h];
            $cands[] = [$x - $rx + 2 - $g_ - $w, $y + $ry - 2 + $g_, $x - $rx + 2 - $g_, $y + $ry - 2 + $g_ + $h];
            $cands[] = [$x + $rx - 2 + $g_, $y - $ry + 2 - $g_ - $h, $x + $rx - 2 + $g_ + $w, $y - $ry + 2 - $g_];
            $cands[] = [$x - $rx + 2 - $g_ - $w, $y - $ry + 2 - $g_ - $h, $x - $rx + 2 - $g_, $y - $ry + 2 - $g_];
        }
        $pick = null; $best = INF;
        foreach ($cands as $b) {
            $dx = 0.0; $dy = 0.0;
            if ($b[0] < $area[0]) $dx = $area[0] - $b[0]; elseif ($b[2] > $area[2]) $dx = $area[2] - $b[2];
            if ($b[1] < $area[1]) $dy = $area[1] - $b[1]; elseif ($b[3] > $area[3]) $dy = $area[3] - $b[3];
            $b2 = [$b[0] + $dx, $b[1] + $dy, $b[2] + $dx, $b[3] + $dy];
            $o = $ovl($b2, $id);
            if ($o < $best) { $best = $o; $pick = $b2; }
            if ($o <= 0.0) break;
        }
        $placed[] = $pick;
        $small[$id] = [$pick, $sl];
    }
    // gathering chips only show under the Gathering filter, so they are not part of the layout: each takes the first free spot
    // under its name, else beside the marker (skipped when you could gather none of it: every icon dim)
    foreach ($items as $id => $it) {
        if (!$it['icons']) continue;
        $icons = $it['icons'];
        if (!array_filter($icons, fn($i) => $i[1])) continue;
        $w = (float)($it['chipn'] * 19 + 8);
        $under = isset($labels[$id]) && $labels[$id][1] > $it['y'] ? $labels[$id][3] : $it['y'] + $it['ry'] + 1;
        $spots = [[$it['x'], $under + 14], [$it['x'] + $it['rx'] + $w / 2 + 6, $it['y']], [$it['x'] - $it['rx'] - $w / 2 - 6, $it['y']], [$it['x'], $it['y'] - $it['ry'] - 14], [$it['x'], $under + 40]];
        $pickc = null;
        foreach ($spots as [$sx, $sy_]) {
            $sx = $cl($sx, $area[0] + $w / 2, $area[2] - $w / 2); $sy_ = $cl($sy_, $area[1] + 12, $area[3] - 12);
            if ($free([$sx - $w / 2, $sy_ - 12, $sx + $w / 2, $sy_ + 12], $id)) { $pickc = [$sx, $sy_]; break; }
            $pickc ??= [$sx, $sy_];
        }
        [$cx, $cy] = $pickc;
        $placed[] = [$cx - $w / 2, $cy - 12, $cx + $w / 2, $cy + 12];
        $t = '';
        foreach ($icons as $i => [$ic, $has, $lab]) $t .= '<text x="' . myc_f(-$w / 2 + 4 + 9.5 + $i * 19) . '" y="6" text-anchor="middle" class="mgi' . ($has ? '' : ' miss') . '">' . $ic . '</text>';
        $ov['g'] .= '<g class="ov-g" transform="translate(' . myc_f($cx) . ' ' . myc_f($cy) . ')"><title>Gathering here: ' . e(implode(', ', array_map(fn($i) => $i[2], $icons))) . '</title>'
            . '<rect x="' . myc_f(-$w / 2) . '" y="-12" width="' . myc_f($w) . '" height="24" rx="12" class="mchip"/>' . $t . '</g>';
    }
    $lbox = array_values($labels);   // threads steer round the names too

    // ----- scenery in the open floor
    $dr = new MycRng('dec' . $k);
    $obst = array_merge(array_values($nodeBox), $placed);
    $dec = '';
    $tries = 0; $want = (int)(($cx1 - $cx0) * $Hc / 9000);
    $glyphs = $bandIdx >= 2 ? ['crys', 'crys', 'peb', 'glow'] : ($bandIdx === 1 ? ['peb', 'glow', 'worm', 'peb'] : ['acorn', 'leaf', 'peb', 'worm', 'glow']);
    while ($want > 0 && $tries++ < 400) {
        $x = $dr->range($cx0 + 24, $cx1 - 24); $y = $dr->range($cy0 + 24, $cy1 - 24);
        $b = [$x - 12, $y - 10, $x + 12, $y + 10]; $hit = false;
        foreach ($obst as $o) if (myc_hit($b, $o, 6)) { $hit = true; break; }
        if ($hit) continue;
        $obst[] = $b; $want--;
        $gk = $glyphs[$dr->int(0, count($glyphs) - 1)]; $rot = $dr->int(-60, 60);
        $dec .= '<g transform="translate(' . myc_f($x) . ' ' . myc_f($y) . ') rotate(' . $rot . ')" class="dec dec-' . $gk . '">' . match ($gk) {
            'acorn' => '<ellipse cy="1" rx="3" ry="3.6" fill="#9a6a3a"/><path d="M-3.5-1q3.5-5 7 0z" fill="#6e4a2a"/>',
            'leaf' => '<path d="M-5 0q5-6 10 0-5 6-10 0z" fill="#c9572f" opacity=".7"/>',
            'peb' => '<ellipse rx="6" ry="4" class="mpeb"/>',
            'worm' => '<path d="M-10 2q4-6 8 0t8 0 6-3" fill="none" stroke="#e9a58a" stroke-width="3" stroke-linecap="round" opacity=".7"/>',
            'crys' => '<path d="M-5 5l2-9 3 9zM0 5l3-13 3 13z" fill="#a9c4ff" opacity=".85"/>',
            default => '<circle r="7" class="mglowdot"/><circle r="1.6" class="mhypha"/>',
        } . '</g>';
    }
    $svg .= '<g class="mdecor" clip-path="url(#cv' . $k . ')">' . $dec . '</g>';

    // ----- mycelium threads: roads (lit where both ends are known, dotted where not), side trails, your route
    $routeIds = [];
    require_once __DIR__ . '/destination.php';
    foreach (dest_route_ids($u) as $rid) $routeIds[] = (int)$rid;
    $onRoute = array_fill_keys($routeIds, true);
    $thr = '';
    $edges = [];
    foreach ($D['roads'] as [$rname, $list]) for ($i = 1; $i < count($list); $i++) if (isset($items[$list[$i - 1]], $items[$list[$i]])) $edges[] = [$list[$i - 1], $list[$i], 'road', $rname];
    foreach ($items as $id => $it) if ($it['type'] === 'off' && !empty($it['anchor']) && isset($items[$it['anchor']])) $edges[] = [$it['anchor'], $id, 'side', ''];
    $edgeCtl = [];
    foreach ($edges as $ei => [$a, $b, $kind, $rname]) {
        $A = [$items[$a]['x'], $items[$a]['y']]; $B = [$items[$b]['x'], $items[$b]['y']];
        $skip = array_values(array_filter($nodeBox, fn($bx, $id) => $id !== $a && $id !== $b, ARRAY_FILTER_USE_BOTH));
        $c = myc_thread_ctrl($A, $B, array_merge($skip, array_values($lbox)), $ei);
        $edgeCtl[$ei] = [$A, $c, $B];
        $d = 'M' . myc_f($A[0]) . ' ' . myc_f($A[1]) . 'Q' . myc_f($c[0]) . ' ' . myc_f($c[1]) . ' ' . myc_f($B[0]) . ' ' . myc_f($B[1]);
        $walked = $items[$a]['seen'] && $items[$b]['seen'];
        if (isset($onRoute[$a], $onRoute[$b])) $thr .= '<path d="' . $d . '" class="mroutegl"/><path d="' . $d . '" class="mroute"/>';
        if ($kind === 'side') $thr .= '<path d="' . $d . '" class="hy off thin2"><title>A side path</title></path>';
        elseif ($walked) $thr .= '<path d="' . $d . '" class="hyglow"/><path d="' . $d . '" class="hy on"><title>' . e($rname) . '</title></path>';
        else $thr .= '<path d="' . $d . '" class="hy off"><title>' . e($rname) . ' (not walked yet)</title></path>';
    }
    $svg .= '<g class="mthreads">' . $thr . '</g>';

    // ----- markers
    $homeV = (int)($u['home_village_id'] ?? 0);
    $plots = array_fill_keys(array_map('intval', q('SELECT village_id FROM plots WHERE user_id = ? AND village_id IS NOT NULL', [$uid])->fetchAll(PDO::FETCH_COLUMN)), true);
    $nodes = ''; $top = '';
    foreach ($items as $id => $it) {
        $l = $it['loc'];
        $type = $it['type'];
        $isMe = $id === $hereId;
        $seen = $it['seen'];
        $x = $it['x']; $y = $it['y']; $rx = $it['rx']; $ry = $it['ry'];
        $name = $seen ? (string)$l['name'] : '???';
        $kk = $type === 'town' ? 'town' : ($type === 'far' ? 'exit' : ($seen ? $it['k'] : 'new'));
        $ring = $isMe ? '<ellipse rx="' . myc_f($rx + 8) . '" ry="' . myc_f($ry + 8) . '" class="mhere"/>'
            : (isset($onRoute[$id]) ? '<ellipse rx="' . myc_f($rx + 5) . '" ry="' . myc_f($ry + 5) . '" class="mrouteing"/>' : ($id === $selId ? '<ellipse rx="' . myc_f($rx + 6) . '" ry="' . myc_f($ry + 6) . '" class="mselring"/>' : ''));
        if ($kk === 'exit') {
            $rot = ['E' => 0, 'S' => 90, 'W' => 180, 'N' => 270][$it['side']] ?? 0;
            $body = '<g transform="rotate(' . $rot . ')">' . myc_glyph('exit') . '</g>';
        } elseif ($kk === 'new') {
            $body = '<circle r="14" class="mnew"/><text y="6" text-anchor="middle" class="mq">?</text>';
        } else {
            $body = '<ellipse cy="3" rx="' . myc_f($rx + 3) . '" ry="' . myc_f($ry + 3) . '" class="mwall"/><ellipse rx="' . myc_f($rx) . '" ry="' . myc_f($ry) . '" class="mfloor"/>'
                . '<ellipse cy="' . myc_f(-$ry * 0.45) . '" rx="' . myc_f($rx * 0.7) . '" ry="' . myc_f($ry * 0.32) . '" class="mhl"/>';
            $gs = $type === 'town' ? 1.0 : ($kk === 'village' ? 0.9 : 0.8);
            $body .= '<g transform="translate(0 1) scale(' . myc_f($gs) . ')">' . myc_glyph($it['ruin'] ? 'ruins' : $kk) . '</g>';
            if (isset($plots[$id])) $body .= '<text x="' . myc_f($rx - 4) . '" y="' . myc_f($ry) . '" text-anchor="middle" class="mbadge">' . ($id === $homeV ? '🏡' : '🌱') . '</text>';
            if ($it['ruin']) $body .= '<text x="' . myc_f(-$rx + 4) . '" y="' . myc_f(-$ry + 4) . '" text-anchor="middle" class="mbadge">🏚️</text>';
        }
        $lab = '';
        if (isset($labels[$id])) {
            $b = $labels[$id]; $lines = $it['lines'];
            $lx = ($b[0] + $b[2]) / 2 - $x; $ly = $b[1] + $fs - $y;
            if ($type === 'town') {
                $lab .= '<rect x="' . myc_f($lx - $it['lw'] / 2) . '" y="' . myc_f($b[1] - $y) . '" width="' . myc_f($it['lw']) . '" height="' . myc_f($it['lh'] - 1) . '" rx="6" class="mplaque"/>';
            }
            $lab .= '<text text-anchor="middle" class="mlbl' . ($type === 'town' ? ' mlbl-town' : '') . '" x="' . myc_f($lx) . '" y="' . myc_f($ly) . '">';
            foreach ($lines as $li => $ln) $lab .= $li ? '<tspan x="' . myc_f($lx) . '" dy="' . ($fs + 2) . '">' . e($ln) . '</tspan>' : e($ln);
            $lab .= '</text>';
        } elseif (isset($small[$id])) {   // v1.6.4: a plain village's name: shown by the Names chip or when the map is zoomed in
            [$b, $lines] = $small[$id];
            $lx = ($b[0] + $b[2]) / 2 - $x; $ly = $b[1] + $fs - $y;
            $lab .= '<text text-anchor="middle" class="mlbl mlbl-sm" x="' . myc_f($lx) . '" y="' . myc_f($ly) . '">';
            foreach ($lines as $li => $ln) $lab .= $li ? '<tspan x="' . myc_f($lx) . '" dy="' . ($fs + 2) . '">' . e($ln) . '</tspan>' : e($ln);
            $lab .= '</text>';
        }
        $title = ($type === 'far' ? 'Road on to ' . $it['farname'] . ': ' : '') . $name . ($isMe ? ' (you are here)' : '');
        $hit = '<ellipse rx="' . myc_f(max(24.0, $rx + 6)) . '" ry="' . myc_f(max(24.0, $ry + 6)) . '" class="mhit"/>';
        $inner = '<title>' . e($title) . '</title>' . $hit . $ring . $body . $lab;
        $g = '<g class="mn mk-' . $kk . ($isMe ? ' here' : '') . ($seen ? '' : ' new') . '" transform="translate(' . myc_f($x) . ' ' . myc_f($y) . ')">'
            . ($isMe ? '<g aria-current="location">' . $inner . '</g>' : '<a href="' . e(url('world.php?go=' . $id . '#gopanel')) . '" aria-label="' . e($title) . '">' . $inner . '</a>') . '</g>';
        if ($isMe) $top .= $g; else $nodes .= $g;
    }
    $svg .= $nodes . $top;
    // you
    if (isset($items[$hereId])) {
        $it = $items[$hereId];
        $svg .= '<g transform="translate(' . myc_f($it['x'] + $it['rx'] * 0.55) . ' ' . myc_f($it['y'] - $it['ry'] - 6) . ')" class="mme"><circle r="12" class="mhatbg"/><text y="6" text-anchor="middle" class="mhat">🎩</text></g>';
    }
    $svg .= '<g class="mov">' . $ov['g'] . $ov['f'] . $ov['q'] . '</g>';
    return $svg . '</svg>';
}

/** The filter chips shared by the world and region maps. */
function myc_filter_chips(bool $gather): string
{
    return '<div class="mycfilter" role="group" aria-label="Show on the map">'
        . '<button type="button" class="mychip" data-f="all" aria-pressed="true">All</button>'
        . '<button type="button" class="mychip" data-f="folk" aria-pressed="false">👤 Villagers</button>'
        . '<button type="button" class="mychip" data-f="quests" aria-pressed="false">❗ Quests</button>'
        . ($gather ? '<button type="button" class="mychip" data-f="gather" aria-pressed="false">🧺 Gathering</button>' : '')
        . ($gather ? '<button type="button" class="mychip mynames" data-n="1" aria-pressed="false">🏷️ Names</button>' : '')   /* v1.6.4 */
        . '</div>';
}

function myc_legend(bool $region): string
{
    return '<details class="mycleg"><summary>Map key</summary><ul>'
        . ($region ? '<li>🏘️ town</li><li>🏡 village</li><li>🏕️ haven</li><li>✨ wonder</li><li>🕳️ delve</li><li>🐉 lair</li><li>🏚️ ruins</li><li>? not visited</li><li>➜ road on to the next region</li>'
            . '<li>🎩 you</li><li><b class="mkpin">!</b> a quest target</li><li>🧺 things to gather here (dim: you need the tool)</li><li>🦔 folk you know</li><li>Left edge: how many roots down</li>'
            : '<li>Deeper = higher level</li><li>🎩 you</li><li>🔒 locked until you reach the level</li><li><b class="mkpin">!</b> something to do there</li><li>👤 folk you know</li><li>Lit thread: you have been along it</li>')
        . '</ul></details>';
}

/** The region's chamber, ready to drop into world.php (phone and desktop pictures, filter chips, folding key). */
function myc_region_block(array $u, int $regionId, int $selId = 0, bool $full = false): string
{
    $D = myc_region_data($u, $regionId, $selId);
    if (!$D) return '';
    $hereIn = (int)(player_node($u)['region_id'] ?? 0) === $regionId && isset($D['items'][(int)player_node($u)['id']]);
    $near = $hereIn && !$full;   // v1.6.1: nearby by default when you're in this region, the whole region otherwise
    $reg = $D['reg'];
    $depth = myc_depth((int)$reg['min_level']);
    [, $band] = myc_band($depth);
    return '<div class="mycbox" data-f="all"><div class="mychead"><span class="mybadge">Level ' . max(1, (int)$reg['min_level']) . ' · ' . e($band) . ' · about ' . $depth . ' roots down</span>'
        . '<a class="btn small alt" href="' . e(url('world.php?tab=map&w=1#worldmap')) . '">🌍 World map</a>'
        . ($hereIn ? '<a class="btn small alt" data-inplace href="' . e(url('world.php?tab=map&r=' . $regionId . ($near ? '&full=1' : '') . '#regionmap')) . '" aria-label="' . ($near ? 'Show the whole region' : 'Show only the places near you') . '">' . ($near ? '🗺️ Show whole region' : '📍 Show nearby') . '</a>' : '') . '</div>'
        . myc_filter_chips(true)
        . '<div class="mycwrapr mzoom"><div class="mzctl" hidden><button type="button" class="mychip mzb" data-mz="in" aria-label="Zoom in">＋</button><button type="button" class="mychip mzb" data-mz="out" aria-label="Zoom out">−</button><button type="button" class="mychip mzb" data-mz="fit" aria-label="Show the whole picture">⤢</button></div>'   /* v1.6.4 */
        . myc_region_svg_one($u, $D, $selId, false, 'p', $near) . '</div>'
        . '<p class="mycnote muted">Tap 🏷️ or zoom in to see every place name.</p>'
        . myc_legend(true) . '</div>';
}

// ---------------------------------------------------------------------------------------------------------------------
// The world map
// ---------------------------------------------------------------------------------------------------------------------

/** The 14 regions at their depths: columns found by relaxing towards their road neighbours while the boxes keep apart. */
function myc_world_layout(array $regs, array $edges, float $W, float $x0, float $x1, callable $yf, bool $wide): array
{
    $ids = array_keys($regs);
    $n = count($ids);
    foreach ($ids as $i => $id) {
        $regs[$id]['y'] = $yf((float)$regs[$id]['depth']);
        $regs[$id]['x'] = $x0 + 50 + fmod($i * 0.618034, 1.0) * ($x1 - $x0 - 100);
    }
    $nb = [];
    foreach ($edges as [$a, $b]) { if (isset($regs[$a], $regs[$b])) { $nb[$a][] = $b; $nb[$b][] = $a; } }
    for ($pass = 0; $pass < 160; $pass++) {
        foreach ($ids as $id) {
            if (empty($nb[$id])) continue;
            $mx = array_sum(array_map(fn($o) => $regs[$o]['x'], $nb[$id])) / count($nb[$id]);
            $regs[$id]['x'] += ($mx - $regs[$id]['x']) * 0.025;
        }
        for ($i = 0; $i < $n; $i++) {
            for ($j = $i + 1; $j < $n; $j++) {
                $a = &$regs[$ids[$i]]; $b = &$regs[$ids[$j]];
                $ox = max($a['bw'], 120.0) / 2 + max($b['bw'], 120.0) / 2 - abs($b['x'] - $a['x']);
                $oy = ($a['bh'] + $b['bh']) / 2 + 40 - abs($b['y'] - $a['y']);
                if ($ox > 0 && $oy > 0) {
                    $dir = $b['x'] >= $a['x'] ? 1 : -1;
                    if (abs($b['x'] - $a['x']) < 0.5) $dir = $i % 2 ? 1 : -1;
                    $a['x'] -= $dir * ($ox * 0.5 + 0.5); $b['x'] += $dir * ($ox * 0.5 + 0.5);
                }
                unset($a, $b);
            }
        }
        foreach ($ids as $id) $regs[$id]['x'] = max($x0 + $regs[$id]['bw'] / 2 + 6, min($x1 - $regs[$id]['bw'] / 2 - 6, $regs[$id]['x']));
    }
    $lo = INF; $hi = -INF;   // then stretch the columns over the whole width
    foreach ($ids as $id) { $lo = min($lo, $regs[$id]['x'] - $regs[$id]['bw'] / 2); $hi = max($hi, $regs[$id]['x'] + $regs[$id]['bw'] / 2); }
    $span = $hi - $lo;
    if ($span > 10) foreach ($ids as $id) $regs[$id]['x'] = ($x0 + 6) + ($regs[$id]['x'] - $lo) / $span * ($x1 - $x0 - 12);
    return $regs;
}

function myc_world_svg(array $u, ?int $sel = null): string
{
    $uid = (int)$u['id'];
    $lvl = (int)$u['level'];
    $been = visited_regions($uid);
    $guides = guide_regions($uid);
    $here = player_node($u);
    $hereRegion = (int)($here['region_id'] ?? 0);
    $rows = [];
    foreach (q('SELECT * FROM regions ORDER BY min_level, id')->fetchAll() as $r) if (isset(REGION_MAP[$r['code']])) $rows[(int)$r['id']] = $r;
    if (!$rows) return '';
    $wide = false;
    $out = '';
    $quests = [];
    foreach (myc_quests($u) as [$ql, $qr, $qt]) if ($qr) $quests[$qr][] = $qt;
    $folk = [];
    foreach (myc_folk($uid) as [$nm, $ic, $lid, $what]) {
        $rid = (int)q_val('SELECT region_id FROM locations WHERE id = ?', [$lid]);
        if ($rid) $folk[$rid][] = $nm;
    }
    $edges = [];
    foreach (q('SELECT l1.region_id AS a, l2.region_id AS b FROM roads r JOIN locations l1 ON l1.id = r.a_town JOIN locations l2 ON l2.id = r.b_town')->fetchAll() as $e_) {
        $a = (int)$e_['a']; $b = (int)$e_['b'];
        if ($a && $b && $a !== $b && isset($rows[$a], $rows[$b])) $edges[min($a, $b) . '-' . max($a, $b)] = [min($a, $b), max($a, $b)];
    }
    $edges = array_values($edges);
    foreach ([false] as $wide) {   // v1.6.0: one picture for every screen (a wide variant exists in the code, but the page stays light: the column never gets wider than ~600px)
        $key = $wide ? 'w' : 'p';
        $W = $wide ? 860.0 : 360.0;
        $GW = $wide ? 40.0 : 32.0;
        $fs = 13.0;
        $regs = [];
        foreach ($rows as $id => $r) {
            $name = (string)$r['gnomish_name'];
            $lines = myc_wrap($name, $wide ? 22 : 14);
            $lw = max(array_map(fn($t) => myc_tw($t, $fs), $lines));
            $regs[$id] = ['r' => $r, 'depth' => myc_depth(max(1, (int)$r['min_level'])), 'lines' => $lines, 'lw' => $lw, 'bw' => max(76.0, $lw + 8), 'bh' => 46 + count($lines) * ($fs + 2) + 20];
        }
        $sy = $wide ? 112.0 : 108.0;
        // v1.6.5: piecewise depth scale. The empty soil above the first chamber and the long gaps between chambers are squeezed
        // (every region keeps its order); the depth gauge and the strata use this same mapping, so its numbers stay true.
        $dk = array_values(array_unique(array_map(fn($g) => (float)$g['depth'], $regs)));
        sort($dk);
        $pts = [[0.0, $sy]];
        $py = $sy + 52.0;
        foreach ($dk as $i => $d) {
            if ($i) $py += max(66.0, ($d - $dk[$i - 1]) * 13.0);
            $pts[] = [$d, $py];
        }
        $last = $pts[count($pts) - 1];
        $ay = function (float $r) use ($pts, $last): float {
            if ($r <= 0) return $pts[0][1];
            for ($i = 1, $n_ = count($pts); $i < $n_; $i++) {
                if ($r <= $pts[$i][0]) return $pts[$i - 1][1] + ($r - $pts[$i - 1][0]) / max(0.001, $pts[$i][0] - $pts[$i - 1][0]) * ($pts[$i][1] - $pts[$i - 1][1]);
            }
            return $last[1] + ($r - $last[0]) * 13.0;
        };
        $regs = myc_world_layout($regs, $edges, $W, $GW + 10, $W - 10, $ay, $wide);
        $maxY = 0.0;
        foreach ($regs as $g) $maxY = max($maxY, $g['y'] + $g['bh']);
        $Ht = $maxY + 50;
        $y0 = $sy;
        $s = '<svg class="mycsvg mycworld ' . ($wide ? 'mycw' : 'mycp') . '" viewBox="0 0 ' . myc_f($W) . ' ' . myc_f($Ht) . '" role="group" aria-label="Map of the Hollow, cut through the soil: the deeper, the higher the level">';
        $s .= myc_cached('wb-' . $key . '-' . (int)$Ht, function () use ($W, $Ht, $sy, $y0, $ay, $GW, $wide, $key, $regs): string {
            $o = '<defs><clipPath id="wr' . $key . '"><rect x="0" y="' . myc_f($y0) . '" width="' . myc_f($W) . '" height="' . myc_f($Ht - $y0) . '"/></clipPath></defs>';
            $r = new MycRng('wsky' . $key);
            $o .= '<rect width="' . myc_f($W) . '" height="' . myc_f($sy + 4) . '" class="msky"/><g class="mstars">';
            for ($i = 0; $i < (int)($W / 11); $i++) $o .= '<circle cx="' . myc_f($r->range(0, $W)) . '" cy="' . myc_f($r->range(4, $sy - 40)) . '" r="' . myc_f($r->range(0.7, 1.5)) . '" fill="#fff" opacity="' . myc_f($r->range(0.4, 0.95)) . '"/>';
            $o .= '</g><circle cx="' . myc_f($W * 0.16) . '" cy="46" r="30" class="msun" opacity=".25"/><circle cx="' . myc_f($W * 0.16) . '" cy="46" r="16" class="msun"/>';
            foreach ([[0.4, 30, 1.0], [0.7, 56, 0.75]] as [$cx, $cy, $sc]) $o .= '<g transform="translate(' . myc_f($W * $cx) . ' ' . $cy . ') scale(' . $sc . ')" class="mcloud"><ellipse rx="26" ry="8"/><circle cx="-8" cy="-7" r="9"/><circle cx="8" cy="-9" r="11"/></g>';
            $o .= '<path d="M0 ' . myc_f($sy - 24) . 'Q' . myc_f($W * 0.2) . ' ' . myc_f($sy - 46) . ' ' . myc_f($W * 0.4) . ' ' . myc_f($sy - 26) . 'T' . myc_f($W * 0.75) . ' ' . myc_f($sy - 32) . 'T' . myc_f($W) . ' ' . myc_f($sy - 20) . 'V' . myc_f($sy + 4) . 'H0z" class="mhill1"/>'
                . '<path d="M0 ' . myc_f($sy - 10) . 'Q' . myc_f($W * 0.25) . ' ' . myc_f($sy - 26) . ' ' . myc_f($W * 0.5) . ' ' . myc_f($sy - 10) . 'T' . myc_f($W) . ' ' . myc_f($sy - 8) . 'V' . myc_f($sy + 4) . 'H0z" class="mhill2"/>';
            $bands = '';
            foreach (MYC_STRATA as $i => [$nm, $a, $b]) {
                $t = max($ay((float)$a), $y0); $bt = $b < 900 ? min($ay((float)$b), $Ht) : $Ht;
                if ($bt > $t + 2) $bands .= '<path d="' . myc_wavy($i ? $t : $t + 2, $W, $key . 'w' . $i, 6) . 'L' . myc_f($W) . ' ' . myc_f($Ht) . 'L0 ' . myc_f($Ht) . 'Z" class="msoil msoil' . $i . ' wmsoil"/>';
            }
            $r2 = new MycRng('wst' . $key);
            for ($j = 0; $j < (int)(($Ht - $y0) / 46); $j++) $bands .= '<path d="' . myc_wavy($r2->range($y0 + 20, $Ht - 10), $W, $key . 'z' . $j, 5) . '" class="strata"/>';
            for ($j = 0; $j < (int)($W * ($Ht - $y0) / 14000); $j++) {
                $x = $r2->range($GW + 14, $W - 14); $y = $r2->range($y0 + 30, $Ht - 14);
                $bands .= '<ellipse cx="' . myc_f($x) . '" cy="' . myc_f($y) . '" rx="' . myc_f($r2->range(3, 7)) . '" ry="' . myc_f($r2->range(2, 4.5)) . '" class="mpeb"/>';
            }
            $o .= '<g clip-path="url(#wr' . $key . ')">' . $bands . '<rect x="0" y="' . myc_f($y0) . '" width="' . myc_f($W) . '" height="' . myc_f($Ht) . '" class="rockdim"/></g>';
            $o .= '<path d="' . myc_wavy($sy + 1, $W, $key . 'wt', 2) . 'L' . myc_f($W) . ' ' . myc_f($sy + 9) . 'L0 ' . myc_f($sy + 9) . 'Z" class="turf"/>';
            $o .= '<rect x="0" y="' . myc_f($y0) . '" width="' . $GW . '" height="' . myc_f($Ht - $y0) . '" class="gauge"/>';
            for ($d = 0; $ay((float)$d) <= $Ht - 6; $d += 10) {
                $yy = $ay((float)$d);
                $o .= '<path d="M' . ($GW - 9) . ' ' . myc_f($yy) . 'h9" class="gtick"/><text x="' . ($GW - 11) . '" y="' . myc_f($yy + 4) . '" text-anchor="end" class="mgnum">' . $d . '</text>';
            }
            foreach (MYC_STRATA as [$nm, $a, $b]) {
                $t = max($ay((float)$a), $y0); $bt = $b < 900 ? min($ay((float)$b), $Ht) : $Ht;
                if ($bt - $t > 70) $o .= '<text transform="translate(12 ' . myc_f(($t + $bt) / 2) . ') rotate(-90)" text-anchor="middle" class="gband">' . strtoupper($nm) . '</text>';
            }
            return $o;
        });
        // trees on the surface above each region (its colour), joined to nothing: just a hint of what is below
        $tr = '';
        foreach ($regs as $id => $g) {
            $fill = REGION_MAP[$g['r']['code']][2] ?? '#8fbf6a';
            $tr .= '<g transform="translate(' . myc_f($g['x']) . ' ' . myc_f($sy + 2) . ') scale(.9)"><rect x="-2" y="-12" width="4" height="12" rx="1.5" fill="#7a4e2c"/><circle cy="-21" r="9" fill="' . $fill . '"/><circle cx="-6" cy="-16" r="6.5" fill="' . $fill . '"/><circle cx="6" cy="-17" r="7" fill="' . $fill . '"/></g>';
        }
        $s .= '<g class="msurf">' . $tr . '</g>';
        // threads between regions
        $cy_ = []; $boxes = [];
        foreach ($regs as $id => $g) $boxes[$id] = [$g['x'] - $g['bw'] / 2, $g['y'] - 26, $g['x'] + $g['bw'] / 2, $g['y'] + $g['bh'] - 26];
        $thr = '';
        foreach ($edges as $ei => [$a, $b]) {
            $A = [$regs[$a]['x'], $regs[$a]['y']]; $B = [$regs[$b]['x'], $regs[$b]['y']];
            $skip = array_values(array_filter($boxes, fn($bx, $id) => $id !== $a && $id !== $b, ARRAY_FILTER_USE_BOTH));
            $c = myc_thread_ctrl($A, $B, $skip, $ei);
            $d = 'M' . myc_f($A[0]) . ' ' . myc_f($A[1]) . 'Q' . myc_f($c[0]) . ' ' . myc_f($c[1]) . ' ' . myc_f($B[0]) . ' ' . myc_f($B[1]);
            $walked = in_array($a, $been, true) && in_array($b, $been, true);
            $thr .= $walked ? '<path d="' . $d . '" class="hyglow"/><path d="' . $d . '" class="hy on"/>' : '<path d="' . $d . '" class="hy off"/>';
        }
        $s .= '<g class="mthreads">' . $thr . '</g>';
        // chambers
        $nodes = ''; $ovq = ''; $ovf = '';
        foreach ($regs as $id => $g) {
            $r = $g['r'];
            $code = (string)$r['code'];
            $fill = REGION_MAP[$code][2] ?? '#8fbf6a';
            $min = max(1, (int)$r['min_level']);
            $isHere = $id === $hereRegion;
            $open = can_fast_travel($u, $id) || in_array($id, $been, true);
            $state = $isHere ? 'here' : (in_array($id, $been, true) ? 'vis' : ($min <= $lvl ? 'unl' : 'lock'));
            $x = $g['x']; $y = $g['y'];
            $rx = 30.0; $ry = 22.0;
            $body = ($state === 'here' ? '<ellipse rx="' . ($rx + 9) . '" ry="' . ($ry + 9) . '" class="mhere"/>' : ($sel === $id ? '<ellipse rx="' . ($rx + 7) . '" ry="' . ($ry + 7) . '" class="mselring"/>' : ''))
                . '<ellipse cy="3" rx="' . ($rx + 3) . '" ry="' . ($ry + 3) . '" class="mwall"/><ellipse rx="' . $rx . '" ry="' . $ry . '" class="mfloor ' . $state . '"/>'
                . '<ellipse cy="-9" rx="21" ry="7" class="mhl"/><g class="mrprop"><circle cy="-5" r="10" fill="' . $fill . '"/><circle cx="-8" cy="1" r="7" fill="' . $fill . '"/><circle cx="8" cy="0" r="7.5" fill="' . $fill . '"/>'
                . '<rect x="-2" y="2" width="4" height="9" fill="#7a4e2c"/></g>'
                . ($state === 'lock' ? '<g class="mlockg"><rect x="-22" y="-16" width="44" height="32" rx="14" class="lockplate"/><text y="6" text-anchor="middle" class="mlock">🔒</text></g>' : '');
            $lines = $g['lines'];
            $ly = $ry + 17;
            $lab = '<text text-anchor="middle" class="mlbl" x="0" y="' . myc_f($ly) . '">';
            foreach ($lines as $li => $ln) $lab .= $li ? '<tspan x="0" dy="' . ($fs + 2) . '">' . e($ln) . '</tspan>' : e($ln);
            $lab .= '</text>';
            $ly2 = $ly + (count($lines) - 1) * ($fs + 2) + 17;
            $lv = !$open && $min <= $lvl ? 'not visited yet' : 'Lv ' . $min;
            $lab .= '<g transform="translate(0 ' . myc_f($ly2 - 5) . ')"><rect x="-' . myc_f(strlen($lv) * 3.4 + 8) . '" y="-9" width="' . myc_f(strlen($lv) * 6.8 + 16) . '" height="17" rx="8.5" class="mlv ' . ($min > $lvl ? 'hi' : '') . '"/><text y="4" text-anchor="middle" class="mlvt">' . e($lv) . '</text></g>';
            $gd = in_array($id, $guides, true) ? '<text x="-26" y="-12" text-anchor="middle" class="mbadge">📗</text>' : '';
            $seek = isset($GLOBALS['gv_seek_regions'][$id]) ? '<ellipse rx="' . ($rx + 13) . '" ry="' . ($ry + 13) . '" class="mseek"/>' : '';
            $title = $r['gnomish_name'] . ' (' . $r['real_name'] . '), level ' . $min . ', about ' . $g['depth'] . ' roots down' . ($isHere ? ', you are here' : '');
            $nodes .= '<g class="mn mk-region ' . $state . '" transform="translate(' . myc_f($x) . ' ' . myc_f($y) . ')"><a href="' . e(url('world.php?tab=map&r=' . $id . '#regionmap')) . '" aria-label="' . e($title) . '"><title>' . e($title) . '</title>'
                . '<ellipse rx="' . myc_f(max(40.0, $g['bw'] / 2)) . '" ry="' . myc_f($g['bh'] / 2 - 6) . '" cy="' . myc_f($g['bh'] / 2 - 26) . '" class="mhit"/>' . $seek . $body . $gd . $lab . '</a></g>';
            if ($isHere) $nodes .= '<g transform="translate(' . myc_f($x + 22) . ' ' . myc_f($y - 24) . ')" class="mme"><circle r="12" class="mhatbg"/><text y="6" text-anchor="middle" class="mhat">🎩</text></g>';
            if (!empty($quests[$id])) $ovq .= '<g class="ov-q" transform="translate(' . myc_f($x - 30) . ' ' . myc_f($y - 22) . ')"><title>' . e(implode(' · ', $quests[$id])) . '</title><path d="M0 12C-12 2 -11 -10 0 -12 11 -10 12 2 0 12z" class="mpin"/><text y="5" text-anchor="middle" class="mpint">!</text></g>';
            if (!empty($folk[$id])) {
                $nm = implode(', ', $folk[$id]);
                $ovf .= '<a class="ov-f" href="' . e(url('town.php?view=villagers')) . '" transform="translate(' . myc_f($x + 34) . ' ' . myc_f($y + 6) . ')" aria-label="Villagers you know: ' . e($nm) . '"><title>' . e($nm) . '</title><circle r="14" class="mbub"/><text y="6" text-anchor="middle" class="mfolk">👤</text>'
                    . (count($folk[$id]) > 1 ? '<circle cx="11" cy="-10" r="8" class="mcnt"/><text x="11" y="-6.5" text-anchor="middle" class="mcntt">' . count($folk[$id]) . '</text>' : '') . '</a>';
            }
        }
        // the hub: a mushroom on the surface
        $hx = $W - 52;
        $hub = '<a href="' . e(url('town.php?hub=1')) . '" aria-label="Mossbottom hub: reachable from anywhere"><title>Mossbottom: the hub, reachable from anywhere</title>'
            . '<g transform="translate(' . myc_f($hx) . ' ' . myc_f($sy - 6) . ')"><ellipse rx="34" ry="30" cy="-12" class="mhit"/><path d="M-20 0q0-26 20-26t20 26z" fill="#d9573f"/><rect x="-6" y="-2" width="12" height="14" rx="4" fill="#f4e9d2"/>'
            . '<circle cx="-8" cy="-14" r="3" fill="#fff6e0"/><circle cx="6" cy="-19" r="3.4" fill="#fff6e0"/><circle cx="10" cy="-8" r="2.4" fill="#fff6e0"/>'
            . '<text y="' . 26 . '" text-anchor="middle" class="mlbl mlbl-hub">Mossbottom</text></g></a>';
        $s .= $nodes . $hub . '<g class="mov">' . $ovf . $ovq . '</g></svg>';
        $out .= $s;
    }
    return '<div class="mycbox mycworldbox" data-f="all"><div class="mychead"><span class="mybadge">Level 1 at the top, deeper as you grow</span></div>'
        . myc_filter_chips(false)
        . '<div class="mycwrapr">' . $out . '</div>' . myc_legend(false) . '</div>';
}
