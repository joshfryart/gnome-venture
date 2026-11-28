<?php
declare(strict_types=1);
/**
 * World v2 (2026-11-28, claude/PROPOSAL-HOLLOW-MASTER.md sections 2 and 11 steps 4, 9, 13). Behind the setting `world_v2_open` (default 0):
 * while it is 0 nothing here runs and the world is as before.
 *
 * Once it is on, world_v2_boot() runs once (bootstrap.php; setting world_v2_done) and:
 *  1. raises every region to its band floor (REGION_LEVELS_V2, progression.php); a level is never lowered
 *  2. lays the two new roads (ROAD_PAIRS_V2, roads.php) with the usual town, three villages, town shape
 *  3. adds the Maplewold's Beaverdam Fens and Cairnback Ridge (zones.txt rows marked world_v2), their villages Cattailmere and
 *     Granitegate, their landmarks and the named routes (data/world_v2_places.txt)
 *  4. ladders the fixed side paths from the road to wonders, delves and lairs inside each band (zones climb, lairs and their guardian at the band top)
 * On every request: route_danger() lets fixed routes reach WORLD_V2_ROUTE_CAP; explore_discover() also finds places along a path
 * from an off-road village the gnome knows; the three doors in WORLD_V2_DOORS.
 */

/** Fixed routes may reach this level once world v2 is on (a band-top lair is 55, its path 53-57). Before: 40. */
const WORLD_V2_ROUTE_CAP = 57;

/** Maplewold zone ladder (master doc 2.3), zone number => [min, max]. Zones 5 and 6 are new; the North stays zone 4. */
const WORLD_V2_NA_ZONES = [1 => [1, 4], 2 => [4, 7], 3 => [7, 10], 4 => [11, 13], 5 => [8, 11], 6 => [12, 15]];

/** Walking from one of these places into another region has its own door: 'seal' = the Maplewold Seal, 'owl' = the Owl beaten or charmed, 'tide' = the tier 3 door. */
const WORLD_V2_DOORS = ['Granitegate' => 'seal', 'Den of the Great White Owl' => 'owl', 'Ferry Landing' => 'tide'];

function world_v2_on(): bool
{
    return setting('world_v2_open') === '1';
}

/** [floor, top] of a region's band: the floor from REGION_LEVELS_V2, the top 10 above it (the Maplewold 1-15). */
function world_v2_band(string $code): array
{
    $lo = REGION_LEVELS_V2[$code] ?? 1;
    return [$lo, $lo === 1 ? 15 : $lo + 10];
}

/** [min, max] of a zone in its region's band. Maplewold: WORLD_V2_NA_ZONES; elsewhere four steps of three (tier 2: 15-17, 18-20, 21-23, 24-25). */
function world_v2_zone_levels(string $code, int $zoneNum): array
{
    if ($code === 'NA') return WORLD_V2_NA_ZONES[$zoneNum] ?? WORLD_V2_NA_ZONES[1];
    [$lo, $hi] = world_v2_band($code);
    $z = max(1, min(4, $zoneNum));
    $min = $lo + 3 * ($z - 1);
    return [$min, $z === 4 ? $hi : $min + 2];
}

/** Bootstrap hook: run the world v2 steps once the setting is on. One request at a time (upgrade_lock); all or nothing. */
function world_v2_boot(): void
{
    if (!world_v2_on() || setting('world_v2_done') === '1' || (int)setting('world_v2_retry_after') > time()) return;
    if (!upgrade_lock(5000)) return;
    setting('__reload__');
    if (setting('world_v2_done') === '1') return;
    if (!q_val("SELECT 1 FROM locations WHERE kind = 'market'")) return;   // world not imported yet
    require_once __DIR__ . '/roads.php';
    $db = db();
    $db->beginTransaction();
    try {
        world_v2_levels();
        foreach (ROAD_PAIRS_V2 as [$a, $b]) world_v2_lay_road($a, $b);
        world_v2_maplewold();
        world_v2_ladder();   // after the move of Beaverdam Tunnels to the Fens
        $db->commit();
    } catch (Throwable $e) {
        $db->rollBack();
        set_setting('world_v2_retry_after', (string)(time() + 60));
        throw $e;
    }
    set_setting('world_v2_done', '1');
    setting('__reload__');
}

/** 1. Every region at least its band floor. Never lowers a level (admin-raised levels stay). */
function world_v2_levels(): void
{
    foreach (REGION_LEVELS_V2 as $code => $lvl) q('UPDATE regions SET min_level = ? WHERE code = ? AND min_level < ?', [$lvl, $code, $lvl]);
}

/** 4. Fixed side paths from the road to wonders, delves and lairs: the level of their zone in the band; lairs (and their guardian) at the band top. */
function world_v2_ladder(): void
{
    $rows = q("SELECT rt.id, rt.b_id, l.slug, lm.kind, z.zone_num, g.code FROM routes rt
               JOIN locations l ON l.id = rt.b_id JOIN landmarks lm ON lm.location_id = l.id
               JOIN regions g ON g.id = l.region_id LEFT JOIN zones z ON z.id = l.zone_id
               WHERE rt.kind = 'side' AND rt.fixed = 1 AND lm.kind IN ('wonder', 'delve', 'lair')")->fetchAll();
    foreach ($rows as $r) {
        if (!on_road((int)q_val('SELECT a_id FROM routes WHERE id = ?', [$r['id']]))) continue;   // the named v2 paths keep their own levels
        if ($r['kind'] === 'lair') {
            $top = world_v2_band((string)$r['code'])[1];
            q('UPDATE routes SET level = ?, min_level = ?, max_level = ? WHERE id = ?', [$top, $top - 2, $top + 2, $r['id']]);
            world_v2_lair_boss_level('boss-' . $r['slug'], $top);
            continue;
        }
        [$min, $max] = world_v2_zone_levels((string)$r['code'], (int)($r['zone_num'] ?? 1));
        q('UPDATE routes SET level = ?, min_level = ?, max_level = ? WHERE id = ?', [$min, $min, $max, $r['id']]);
    }
}

/** A lair guardian rebuilt at a new level (the build of ensure_lair_bosses(), as boot step medium_lair_levels_1115 does). */
function world_v2_lair_boss_level(string $slug, int $lv): void
{
    $c = q_one('SELECT level FROM creatures WHERE slug = ?', [$slug]);
    if (!$c || (int)$c['level'] === $lv) return;
    q('UPDATE creatures SET level = ?, hp = ?, attack = ?, defense = ?, dmg_bonus = ?, xp = ? WHERE slug = ?',
      [$lv, (int)round((5 + $lv * 3) * 2.4), 3 + intdiv($lv, 3), 12 + intdiv($lv, 3), intdiv($lv, 4), (int)round($lv * 6 * 2.4), $slug]);
    q('UPDATE encyclopedia_entries SET body = REPLACE(body, ?, ?), sort_order = ? WHERE unlock_key = ?', ['[b]Level:[/b] ' . (int)$c['level'], '[b]Level:[/b] ' . $lv, $lv, 'creature:' . $slug]);
}

/** The region's town (market) id, 0 if none. */
function world_v2_town(int $regionId): int
{
    return (int)q_val("SELECT id FROM locations WHERE region_id = ? AND kind = 'market' ORDER BY id LIMIT 1", [$regionId]);
}

/**
 * 2. One new road between two regions' towns, as lay_roads() lays them: town, a village of A, a village of whichever has more
 * left off the road, a village of B, town. The villages are the first off-road ones (starter zone first); their old side path goes.
 * Nothing happens if the road is already there. Returns the road id or 0.
 */
function world_v2_lay_road(string $a, string $b): int
{
    $ra = q_one('SELECT * FROM regions WHERE code = ?', [$a]);
    $rb = q_one('SELECT * FROM regions WHERE code = ?', [$b]);
    if (!$ra || !$rb) return 0;
    $ta = world_v2_town((int)$ra['id']);
    $tb = world_v2_town((int)$rb['id']);
    if (!$ta || !$tb) return 0;
    $name = $ra['gnomish_name'] . ' – ' . $rb['gnomish_name'];
    if ($id = (int)q_val('SELECT id FROM roads WHERE name = ?', [$name])) return $id;
    $free = fn(int $rid) => array_map('intval', q("SELECT l.id FROM locations l LEFT JOIN zones z ON z.id = l.zone_id
        WHERE l.region_id = ? AND l.kind = 'village' AND NOT EXISTS (SELECT 1 FROM routes rt WHERE rt.kind = 'road' AND (rt.a_id = l.id OR rt.b_id = l.id))
        ORDER BY COALESCE(z.zone_num, 9), l.sort_order, l.id", [$rid])->fetchAll(PDO::FETCH_COLUMN));
    $fa = $free((int)$ra['id']);
    $fb = $free((int)$rb['id']);
    $v1 = array_shift($fa);
    $v2 = count($fa) >= count($fb) ? array_shift($fa) : array_shift($fb);
    $v3 = array_shift($fb);
    $nodes = array_values(array_filter([$ta, $v1, $v2, $v3, $tb]));
    foreach (array_slice($nodes, 1, -1) as $v) q("DELETE FROM routes WHERE kind = 'side' AND b_id = ?", [$v]);   // it is on the road now
    $roadId = (int)db_insert('roads', ['name' => $name, 'a_town' => $ta, 'b_town' => $tb, 'nodes' => json_encode($nodes)]);
    for ($i = 1; $i < count($nodes); $i++) {
        db_insert('routes', ['a_id' => $nodes[$i - 1], 'b_id' => $nodes[$i], 'steps' => ROAD_STEPS, 'minutes' => 6, 'level' => 1,
            'min_level' => 1, 'max_level' => 1, 'fixed' => 0, 'kind' => 'road', 'road_id' => $roadId]);
    }
    return $roadId;
}

/** Rows of data/world_v2_places.txt of one kind (P, M or R), fields after the kind. */
function world_v2_rows(string $kind): array
{
    require_once __DIR__ . '/catalog.php';
    return array_values(array_map(fn($r) => array_slice($r, 1), array_filter(catalog_lines('world_v2_places.txt'), fn($r) => $r[0] === $kind)));
}

/** 3. The two new Maplewold zones, their places and the named routes. Safe to repeat: only what is missing is added. */
function world_v2_maplewold(): void
{
    require_once __DIR__ . '/catalog.php';
    require_once __DIR__ . '/adventure_data.php';
    foreach (catalog_lines('zones.txt') as $z) {
        if (($z[6] ?? '') !== 'world_v2' || count($z) < 6) continue;
        $rid = (int)q_val('SELECT id FROM regions WHERE code = ?', [$z[0]]);
        if ($rid && !q_val('SELECT 1 FROM zones WHERE region_id = ? AND zone_num = ?', [$rid, (int)$z[1]])) {
            db_insert('zones', ['region_id' => $rid, 'zone_num' => (int)$z[1], 'landscape' => $z[2], 'name' => $z[3], 'difficulty' => $z[4], 'villages' => (int)$z[5]]);
        }
    }
    foreach (world_v2_rows('P') as $p) if (count($p) >= 6) world_v2_add_place(...array_slice($p, 0, 6));
    foreach (world_v2_rows('M') as [$code, $zoneNum, $name]) {
        $zone = world_v2_zone($code, (int)$zoneNum);
        if ($zone) {
            q('UPDATE locations SET zone_id = ?, landscape = ? WHERE name = ? AND region_id = ?', [$zone['id'], $zone['landscape'], $name, $zone['region_id']]);
            q('UPDATE landmarks SET zone_id = ?, sort_order = ? WHERE name = ? AND region_id = ?', [$zone['id'], (int)$zoneNum, $name, $zone['region_id']]);
        }
    }
    foreach (world_v2_rows('R') as $r) {
        if (count($r) < 5) continue;
        [, $from, $to, $steps, $lv] = $r;
        $a = world_v2_place_id($from);
        $b = world_v2_place_id($to);
        if (!$a || !$b || q_val('SELECT 1 FROM routes WHERE (a_id = ? AND b_id = ?) OR (a_id = ? AND b_id = ?)', [$a, $b, $b, $a])) continue;
        [$min, $max] = array_map('intval', explode('-', $lv) + [1 => $lv]);
        db_insert('routes', ['a_id' => $a, 'b_id' => $b, 'steps' => max(2, (int)$steps), 'minutes' => 4, 'level' => $min,
            'min_level' => $min, 'max_level' => max($min, $max), 'fixed' => 1, 'kind' => 'side', 'road_id' => null]);
    }
}

function world_v2_zone(string $code, int $zoneNum): ?array
{
    return q_one('SELECT z.* FROM zones z JOIN regions g ON g.id = z.region_id WHERE g.code = ? AND z.zone_num = ?', [$code, $zoneNum]);
}

/** "NA:Honeybrook", "CB:@town", "CA:@zone4" => location id, 0 if not found. */
function world_v2_place_id(string $ref): int
{
    [$code, $what] = array_map('trim', explode(':', $ref, 2) + [1 => '']);
    $rid = (int)q_val('SELECT id FROM regions WHERE code = ?', [$code]);
    if (!$rid) return 0;
    if ($what === '@town') return world_v2_town($rid);
    if (preg_match('/^@zone(\d+)$/', $what, $m)) {
        return (int)q_val("SELECT l.id FROM locations l JOIN zones z ON z.id = l.zone_id WHERE l.region_id = ? AND z.zone_num = ? AND l.kind = 'village' ORDER BY l.sort_order, l.id LIMIT 1", [$rid, (int)$m[1]]);
    }
    return (int)q_val('SELECT id FROM locations WHERE region_id = ? AND name = ? ORDER BY id LIMIT 1', [$rid, $what]);
}

/** One place of the data file: a village (its stop type and own description) or a landmark, with its Almanac page. */
function world_v2_add_place(string $code, string $zoneNum, string $kind, string $name, string $stopType, string $desc): void
{
    $zone = world_v2_zone($code, (int)$zoneNum);
    if (!$zone || q_val('SELECT 1 FROM locations WHERE region_id = ? AND name = ?', [$zone['region_id'], $name])) return;
    $region = q_one('SELECT * FROM regions WHERE id = ?', [$zone['region_id']]);
    $zn = (int)$zoneNum;
    if ($kind === 'village') {
        $slug = 'v-' . strtolower($code) . '-' . $zn . '-' . (1 + (int)q_val("SELECT COUNT(*) FROM locations WHERE zone_id = ? AND kind = 'village'", [$zone['id']]));
        $v = ['name' => $name, 'slug' => $slug, 'region' => $region['gnomish_name'], 'kind' => 'village', 'region_id' => $zone['region_id'],
            'zone_id' => $zone['id'], 'landscape' => $zone['landscape'], 'sort_order' => $zn * 10, 'description' => $desc, 'stop_type' => $stopType !== '-' ? $stopType : null];
        db_insert('locations', $v);
        $L = LANDSCAPES[$zone['landscape']] ?? ['', ucfirst((string)$zone['landscape']), ''];
        db_insert('encyclopedia_entries', ['chapter' => 'Villages', 'category' => substr((string)$region['gnomish_name'], 0, 30), 'title' => $name,
            'body' => village_page_body($v, (string)$zone['name']), 'unlock_key' => 'village:' . $slug,
            'hint' => 'Visit it on your travels (' . strtolower($L[1]) . ').', 'sort_order' => $zn * 10]);
        return;
    }
    if (!in_array($kind, ['haven', 'wonder', 'delve'], true)) return;
    $slug = slugify('lm-' . strtolower($code) . '-' . $zn . '-' . $kind . '-' . $name);
    $locId = db_insert('locations', ['name' => $name, 'slug' => $slug, 'region' => $region['gnomish_name'], 'kind' => $kind === 'haven' ? 'haven' : 'wonder',
        'region_id' => $zone['region_id'], 'zone_id' => $zone['id'], 'landscape' => $zone['landscape'], 'sort_order' => $zn * 100 + 50, 'description' => $desc]);
    db_insert('landmarks', ['region_id' => $zone['region_id'], 'zone_id' => $zone['id'], 'location_id' => $locId, 'kind' => $kind,
        'name' => $name, 'description' => $desc, 'sort_order' => $zn]);
    db_insert('encyclopedia_entries', ['chapter' => 'Landmarks', 'category' => ['haven' => 'Havens', 'wonder' => 'Wonders', 'delve' => 'Delves'][$kind], 'title' => $name,
        'body' => (LANDMARK_ICONS[$kind] ?? '📍') . ' ' . $desc . "\n\n[b]In:[/b] " . $region['gnomish_name'] . ', zone ' . $zn . ' (' . $zone['name'] . ').',
        'unlock_key' => 'landmark:' . $slug, 'hint' => 'Visit it on an adventure.', 'sort_order' => $zn]);
}

// ---------------------------------------------------------------- on every request (only while world_v2_open is on)

/**
 * The door on a v2 path out of its region, for this gnome: '' when open. Only walking from a WORLD_V2_DOORS place into another
 * region is checked, so the way back is never closed.
 */
function world_v2_door_refusal(int $uid, array $from, array $to): string
{
    if (!world_v2_on() || (int)$from['region_id'] === (int)$to['region_id']) return '';
    $door = WORLD_V2_DOORS[(string)$from['name']] ?? '';
    if ($door === '') return '';
    require_once __DIR__ . '/seals.php';
    if ($door === 'owl') {
        $owl = (int)q_val("SELECT id FROM landmarks WHERE kind = 'lair' AND location_id = ?", [$from['id']]);
        return q_val('SELECT 1 FROM landmark_clears WHERE user_id = ? AND landmark_id = ?', [$uid, $owl]) ? ''
            : 'The Northern Rim Pass opens once the Great White Owl has been beaten or charmed.';
    }
    if ($door === 'seal') {
        return seals_on() && seal_held($uid, (int)$from['region_id']) ? ''
            : 'Hobb’s Warden at Granitegate: the high road to ' . (string)($to['region'] ?? 'the next area') . ' opens with the Maplewold Seal.';
    }
    return seals_on() ? ''   // the tier door itself is the Seal gate on the crossing (start_expedition, visible_routes)
        : 'The tide is out: the ferry to ' . (string)($to['region'] ?? 'the far shore') . ' runs once the Seals open the tier ' . region_tier_of(seal_region_code((int)$to['region_id'])) . ' doors.';
}

/** A v2 path out of its region (routes_from() row with 'to', walked from $fromId) is signposted: it shows, and can be walked door allowing, without first finding the far end. */
function world_v2_signposted_from(array $route, int $fromId): bool
{
    if (!world_v2_on() || ($route['kind'] ?? '') !== 'side' || empty($route['to'])) return false;
    $from = q_one('SELECT name, region_id FROM locations WHERE id = ?', [$fromId]);
    return $from && isset(WORLD_V2_DOORS[(string)$from['name']]) && (int)$from['region_id'] !== (int)$route['to']['region_id'];
}

/**
 * Where a wander can find places from: the stops given, plus the off-road villages hanging off them that this gnome knows
 * (Cattailmere, Granitegate), so the places along the Fen Path and the Cairnback Climb can be found by wandering from the road.
 */
function world_v2_discover_near(int $uid, array $near): array
{
    if (!world_v2_on() || !$near) return $near;
    require_once __DIR__ . '/roads.php';
    $in = implode(',', array_map('intval', $near));
    foreach (q("SELECT l.* FROM routes r JOIN locations l ON l.id = r.b_id WHERE r.kind = 'side' AND l.kind = 'village' AND r.a_id IN ($in)")->fetchAll() as $v) {
        if (place_known($uid, $v)) $near[] = (int)$v['id'];
    }
    return array_values(array_unique($near));
}
