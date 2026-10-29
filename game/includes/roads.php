<?php
declare(strict_types=1);
/**
 * Roads (v0.7.24).
 * The mycelium network is laid out as roads: town → three villages → a neighbouring region's town.
 * Roads are always easy: matched to your level, and no bosses. Every other village and landmark is off the road,
 * reached by a side path from a road village, and only shows once you've found it (or have a garden there).
 * Exploring off the path (v0.7.25) is how hidden places are found.
 */

require_once __DIR__ . '/world.php';

/** Neighbouring regions, by code. Each pair is one road. */
const ROAD_PAIRS = [
    ['NA', 'CA'], ['NA', 'NWE'], ['NA', 'EA'], ['CA', 'CB'], ['CA', 'SA'], ['CB', 'SA'], ['SA', 'OC'],
    ['NWE', 'SE'], ['NWE', 'EE'], ['SE', 'MENA'], ['EE', 'CSA'], ['MENA', 'WCA'], ['MENA', 'CSA'],
    ['WCA', 'ESA'], ['ESA', 'CSA'], ['CSA', 'EA'], ['CSA', 'SEA'], ['EA', 'SEA'], ['SEA', 'OC'],
];
const ROAD_STEPS = 3;   // spaces on each stretch of road

const ROADS_ALMANAC = "🛣️ [b]Roads[/b] run between the towns of neighbouring regions. Each road passes three villages, "
    . "and roads are gentle. Next to home (a town, a haven, a village with your garden) what you meet matches your own level; "
    . "further along it sits at the level of the region the road leads into, and nothing too big.\n\n"
    . "🌱 [b]Easy roads[/b] (in Account, on for new gnomes) keep everything next to home a few levels below you, with no legendary creatures. Switch it off whenever you want a real fight.\n\n"
    . "💨 A road that is far below your level is a [b]quick walk[/b]: it takes half the time.\n\n"
    . "🌿 [b]Off the path[/b]: from any town or road village you can wander off into the wild mycelium. "
    . "Each step out costs 1 energy and gets harder: [b]medium[/b] for the first two steps, [b]hard[/b] for the next two, then [b]wild[/b], "
    . "where bosses roam. The further you go, the better the finds. Turning back to the road is always free, and if you’re knocked out "
    . "you wake up on the road with all your things.\n\n"
    . "🗺️ Out there you may spot [b]hidden villages and landmarks[/b]: havens, wonders, delves and lairs. Once found, a side path to them "
    . "appears on the road for good.\n\n"
    . "🏕️ [b]Havens[/b] are safe stops: rest by the fire, stay the night for a boost, and browse a little pantry. "
    . "✨ [b]Wonders[/b] can be investigated once a day; each has its own skill that works best. "
    . "🕳️ [b]Delves[/b] are five rooms of creatures, traps and treasure with a guarded chest at the bottom. "
    . "🐉 [b]Lairs[/b] are home to the Hollow’s legendary creatures. Beat one for a hoard, and the first time for a ribbon and a treasure seed.";

/** Lay the roads (once per world; Admin can edit routes afterwards). */
function ensure_roads(): void
{
    if (!q_val("SELECT 1 FROM locations WHERE kind = 'market'")) return;   // world not imported yet
    if (setting('world_layout') !== 'roads') lay_roads();
    link_hidden_places();
    // The Almanac's travel page: the old "Zones & landmarks" page becomes "Roads and the wilds"
    $old = q_val("SELECT id FROM encyclopedia_entries WHERE chapter = 'General' AND title IN ('Zones & landmarks', 'Roads and the wilds') ORDER BY id LIMIT 1");
    if ($old) {
        q('UPDATE encyclopedia_entries SET title = ?, body = ? WHERE id = ?', ['Roads and the wilds', ROADS_ALMANAC, $old]);
    }
}

/** Replace the old zone threads with roads (once). */
function lay_roads(): void
{
    // Anyone mid-walk finishes where they were heading
    foreach (q("SELECT * FROM expeditions WHERE status = 'active'")->fetchAll() as $x) {
        $to = q_one('SELECT * FROM locations WHERE id = ?', [$x['to_id']]);
        q("UPDATE expeditions SET status = 'done', encounter = NULL WHERE id = ?", [$x['id']]);
        if ($to) q('UPDATE users SET location_id = ?, location = ? WHERE id = ?', [$to['id'], $to['region'], $x['user_id']]);
    }
    q('DELETE FROM routes');
    q('DELETE FROM roads');
    $byCode = [];
    foreach (all_regions() as $r) $byCode[$r['code']] = $r;
    $town = fn(string $code) => (int)q_val("SELECT id FROM locations WHERE region_id = ? AND kind = 'market' ORDER BY id LIMIT 1", [$byCode[$code]['id'] ?? 0]);
    // Each region's villages, starter zone first
    $free = [];
    foreach ($byCode as $code => $r) {
        $free[$code] = array_map('intval', q("SELECT l.id FROM locations l LEFT JOIN zones z ON z.id = l.zone_id
            WHERE l.region_id = ? AND l.kind = 'village' ORDER BY COALESCE(z.zone_num, 9), l.sort_order, l.id", [$r['id']])->fetchAll(PDO::FETCH_COLUMN));
    }
    $roadVillages = [];   // region code => [village ids on roads]
    foreach (ROAD_PAIRS as [$a, $b]) {
        if (!isset($byCode[$a], $byCode[$b])) continue;
        $ta = $town($a);
        $tb = $town($b);
        if (!$ta || !$tb) continue;
        $take = function (string $code) use (&$free, &$roadVillages) {
            $v = array_shift($free[$code]);
            if ($v) $roadVillages[$code][] = $v;
            return $v;
        };
        $v1 = $take($a);
        $v2 = count($free[$a]) >= count($free[$b]) ? $take($a) : $take($b);
        $v3 = $take($b);
        $nodes = array_values(array_filter([$ta, $v1, $v2, $v3, $tb]));
        $name = $byCode[$a]['gnomish_name'] . ' – ' . $byCode[$b]['gnomish_name'];
        $roadId = db_insert('roads', ['name' => $name, 'a_town' => $ta, 'b_town' => $tb, 'nodes' => json_encode($nodes)]);
        for ($i = 1; $i < count($nodes); $i++) {
            db_insert('routes', ['a_id' => $nodes[$i - 1], 'b_id' => $nodes[$i], 'steps' => ROAD_STEPS, 'minutes' => 6, 'level' => 1,
                'min_level' => 1, 'max_level' => 1, 'fixed' => 0, 'kind' => 'road', 'road_id' => $roadId]);
        }
    }
    // Gardens and homes off the road stay reachable: make sure their owners know the way
    foreach (q("SELECT DISTINCT p.user_id, l.slug FROM plots p JOIN locations l ON l.id = p.village_id")->fetchAll() as $g) {
        unlock_entries((int)$g['user_id'], 'village:' . $g['slug']);
    }
    set_setting('world_layout', 'roads');
    setting('__reload__');
}

/** Side paths: every village and landmark that isn't linked yet hangs off a road village of its own region. */
function link_hidden_places(): void
{
    require_once __DIR__ . '/adventure_data.php';
    foreach (all_regions() as $r) {
        $anchors = array_map('intval', q("SELECT DISTINCT l.id FROM locations l JOIN routes rt ON rt.kind = 'road' AND (rt.a_id = l.id OR rt.b_id = l.id)
                                          WHERE l.region_id = ? AND l.kind = 'village' ORDER BY l.id", [$r['id']])->fetchAll(PDO::FETCH_COLUMN));
        if (!$anchors) $anchors = array_map('intval', q("SELECT id FROM locations WHERE region_id = ? AND kind = 'market'", [$r['id']])->fetchAll(PDO::FETCH_COLUMN));
        if (!$anchors) continue;
        $i = (int)q_val("SELECT COUNT(*) FROM routes rt JOIN locations l ON l.id = rt.b_id WHERE rt.kind = 'side' AND l.region_id = ?", [$r['id']]);
        $hidden = q("SELECT l.*, z.difficulty FROM locations l LEFT JOIN zones z ON z.id = l.zone_id
                     WHERE l.region_id = ? AND l.kind IN ('village', 'haven', 'wonder', 'lair') ORDER BY l.sort_order, l.id", [$r['id']])->fetchAll();
        foreach ($hidden as $h) {
            if (in_array((int)$h['id'], $anchors, true) || q_val('SELECT 1 FROM routes WHERE a_id = ? OR b_id = ?', [$h['id'], $h['id']])) continue;
            $anchor = $anchors[$i++ % count($anchors)];
            $lmKind = (string)q_val('SELECT kind FROM landmarks WHERE location_id = ?', [$h['id']]);
            $diff = DIFFICULTY_LEVELS[$h['difficulty'] ?? 'easy'] ?? DIFFICULTY_LEVELS['easy'];
            [$lvl, $range, $fixed] = match ($lmKind) {
                'lair' => [max(8, $diff['base'] + $diff['range']), 4, 1],
                'delve' => [max(5, $diff['base'] + 2), 4, 1],
                'wonder' => [max(3, $diff['base']), 4, 1],
                default => [1, 0, 0],   // villages and havens: matched to your level
            };
            $min = max(1, $lvl - intdiv($range, 2));
            db_insert('routes', ['a_id' => $anchor, 'b_id' => $h['id'], 'steps' => 2 + min(3, intdiv($lvl, 8)), 'minutes' => 4, 'level' => $lvl,
                'min_level' => $min, 'max_level' => $min + $range, 'fixed' => $fixed, 'kind' => 'side', 'road_id' => null]);
        }
    }
}

/** Has this gnome found an off-road place (been there, or has a garden there)? */
function place_known(int $uid, array $loc): bool
{
    if (in_array($loc['kind'], ['market', 'hub'], true)) return true;
    if ((bool)q_val('SELECT 1 FROM plots WHERE user_id = ? AND village_id = ?', [$uid, $loc['id']])) return true;
    $key = ($loc['kind'] === 'village' ? 'village:' : 'landmark:') . $loc['slug'];
    return (bool)q_val('SELECT 1 FROM user_encyclopedia ue JOIN encyclopedia_entries e ON e.id = ue.entry_id WHERE ue.user_id = ? AND e.unlock_key = ?', [$uid, $key]);
}

/** Is this place on a road (a town or a road village)? */
function on_road(int $locId): bool
{
    return (bool)q_val("SELECT 1 FROM routes WHERE kind = 'road' AND (a_id = ? OR b_id = ?)", [$locId, $locId]);
}

/** The road a place is on, with its stops in order, or null. */
function road_of(int $locId): ?array
{
    $rid = q_val("SELECT road_id FROM routes WHERE kind = 'road' AND (a_id = ? OR b_id = ?) ORDER BY id LIMIT 1", [$locId, $locId]);
    if (!$rid) return null;
    $road = q_one('SELECT * FROM roads WHERE id = ?', [$rid]);
    if (!$road) return null;
    $road['stops'] = [];
    foreach (json_decode((string)$road['nodes'], true) ?: [] as $id) {
        if ($l = q_one('SELECT id, name, slug, kind, landscape, region FROM locations WHERE id = ?', [$id])) $road['stops'][] = $l;
    }
    return $road;
}

/** Where to go from here, for this gnome: roads always; side paths only to places they know (or back to the road). */
function visible_routes(array $u, int $locId): array
{
    require_once __DIR__ . '/adventure.php';
    $out = [];
    foreach (routes_from($locId) as $r) {
        if (($r['kind'] ?? 'road') === 'side' && !on_road((int)$r['to']['id']) && !place_known((int)$u['id'], $r['to'])) continue;
        [$r['walk_min'], $r['quick']] = route_walk_minutes($u, $r);   // v0.9.7: minutes for this gnome, and whether it is a quick walk
        $out[] = $r;
    }
    return $out;
}

/**
 * v0.9.7 mid/late game, part A. Idempotent; runs on the upgrade to 0.9.7:
 *  - users.easy_roads (schema.php) defaults to 1; gnomes already at easy_roads_below or higher get it off (they chose nothing yet)
 *  - the 12-14 new creatures for regions 23-35 (creatures.txt; the importer only adds slugs it doesn't have, admin edits stay)
 *  - the Almanac "Roads and the wilds" page is rewritten by the bootstrap on every version change
 */
function upgrade_097_roads(): void
{
    q('UPDATE users SET easy_roads = 0 WHERE level >= ? AND easy_roads = 1', [max(1, (int)setting('easy_roads_below'))]);
    require_once __DIR__ . '/catalog.php';
    require_once __DIR__ . '/adventure_data.php';
    $stats = ['items' => 0, 'pages' => 0];
    import_creatures_txt($stats);
}
