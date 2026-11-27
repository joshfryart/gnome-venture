<?php
declare(strict_types=1);

/** 2026-11-15 (Josh): lairs at region level + 4 (route = level - 2 .. level + 2), as Condor's Crag (SA, region Lv 12, lair 16) sits.
 *  Medium-zone lairs of the late regions were Lv 16: CSA 23 -> 27, SEA 26 -> 30, ESA 32 -> 36, OC 35 -> 39 -> 37 (Josh: no creature in the data is above Lv 37).
 *  Hard-zone lairs of the early regions were Lv 30: CA 4 -> 8, NWE 6 -> 10, CB 8 -> 12, SE 10 -> 14, EE 14 -> 18, MENA 17 -> 21, EA 20 -> 24.
 *  Kept: Den of the Great White Owl Lv 10, Hollow of the Silverback Spider Lv 20 (boot step silverback_lair_level_1114).
 *  Existing worlds: boot step medium_lair_levels_1115 (every lair takes the new level, fought or charmed ones too). */
const LAIR_LEVEL_1115 = ['Temple of the Tiger Moth' => 27, 'Dragonlizard Den' => 30, 'Snowcrown Peak' => 36, 'Reef of the Box Jelly Queen' => 37,
    'Smokecap Caldera' => 8, 'Barrow of the Frost Toad' => 10, 'Lair of the Hurricane Crab' => 12, 'Forge of the Cinder Wyrm' => 14,
    'Lair of the Grey Wolf King' => 18, 'Tomb of the Sand Scarab' => 21, 'Lair of the Jade Dragon-fly' => 24];
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
// Roads that stop at their last village instead of reaching the far town (2.6.32: Clovercove is the end of the Maplewold road to Blossomreach).
const ROAD_DEAD_ENDS = [['NA', 'EA']];
const ROAD_STEPS = 3;   // spaces on each stretch of road

const ROADS_ALMANAC = "🛣️ [b]Roads[/b] run between the towns of neighbouring regions. Each road passes three villages, "
    . "and roads are gentle. Next to home (a town, a haven, a village with your garden) what you meet matches your own level; "
    . "further along it sits at the level of the region the road leads into, and nothing too big.\n\n"
    . "🌱 [b]Easy roads[/b] (in Account, on for new gnomes) keep everything next to home a few levels below you, with no legendary creatures. Switch it off whenever you want a real fight.\n\n"
    . "💨 A road that is far below your level is a [b]quick walk[/b]: it takes half the time.\n\n"
    . "🌿 [b]Off the path[/b]: from any town or road village you can wander off into the wild mycelium. "
    . "Each step out costs 1 energy and starts as easy as the road you left, then gets a little harder. [b]Wild country[/b], "
    . "where bosses roam, starts at step 7; past step 9 lie the deep wilds, always a match for your own level. The further you go, the better the finds. Turning back to the road is always free, and if you’re knocked out "
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
    cut_dead_end_roads();
    name_dead_end_roads();
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
        $deadEnd = in_array([$a, $b], ROAD_DEAD_ENDS, true);
        $nodes = array_values(array_filter([$ta, $v1, $v2, $v3, $tb]));
        $far = 0;
        if ($deadEnd) {   // 2.8.74: the road stops at its last village, but the far leg still takes its routes.id and is then deleted, so the id numbering (and all map data keyed by it) stays as laid before 2.8.70
            $far = (int)array_pop($nodes);
            $tb = (int)end($nodes);
        }
        $name = $byCode[$a]['gnomish_name'] . ' – ' . ($deadEnd ? (string)q_val('SELECT name FROM locations WHERE id = ?', [$tb]) : $byCode[$b]['gnomish_name']);   // 2.7.45: a dead-end road is named for the village it stops at, not the far region it never reaches
        $roadId = db_insert('roads', ['name' => $name, 'a_town' => $ta, 'b_town' => $tb, 'nodes' => json_encode($nodes)]);
        for ($i = 1; $i < count($nodes); $i++) {
            db_insert('routes', ['a_id' => $nodes[$i - 1], 'b_id' => $nodes[$i], 'steps' => ROAD_STEPS, 'minutes' => 6, 'level' => 1,
                'min_level' => 1, 'max_level' => 1, 'fixed' => 0, 'kind' => 'road', 'road_id' => $roadId]);
        }
        if ($deadEnd && $far && $tb) {
            $burn = (int)db_insert('routes', ['a_id' => $tb, 'b_id' => $far, 'steps' => ROAD_STEPS, 'minutes' => 6, 'level' => 1,
                'min_level' => 1, 'max_level' => 1, 'fixed' => 0, 'kind' => 'road', 'road_id' => $roadId]);
            if ($burn) q('DELETE FROM routes WHERE id = ?', [$burn]);
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
            if ((string)$h['name'] === 'Den of the Great White Owl') { $lvl = 10; $min = 8; $range = 4; }
            if (isset(LAIR_LEVEL_1115[(string)$h['name']])) { $lvl = LAIR_LEVEL_1115[(string)$h['name']]; $min = $lvl - 2; $range = 4; }   // 2026-11-15 (Josh): medium-zone lairs of the late regions at region level + 4; upgrade step medium_lair_levels_1115
            if ((string)$h['name'] === 'Hollow of the Silverback Spider') { $lvl = 20; $min = 18; $range = 4; }   // 2026-11-14 (Josh): Lv 18-22, its zone's level (the wonders beside it are 20 and 22) instead of the hard-zone lair top 28-32; upgrade step silverback_lair_level_1114   // v2.6.75: a fresh world: Lv 8-12 like the upgrade step den_owl_route_level_2675 (it sat on a hard-zone route of Lv 28-32 next to a Lv 3 village)
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

/** v2.6.73: can you wander off the path from here? A road stop, or a haven, den (lair), delve or wonder (landmark places are off the road but you can still step off from them). */
function can_wander_from(int $locId): bool
{
    if (on_road($locId)) return true;
    return (bool)q_val("SELECT 1 FROM locations l WHERE l.id = ? AND (l.kind IN ('haven','lair','delve','wonder') OR EXISTS (SELECT 1 FROM landmarks m WHERE m.location_id = l.id AND m.kind IN ('haven','lair','delve','wonder')))", [$locId]);
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
        $r['gate'] = '';   // 2.8.85: the Warden's words when a Seal door closes this road (the card still shows; the walk is refused with this text)
        if (setting('seals_open') === '1' && !empty($r['to']['region_id'])) {
            $fromRegion = (int)q_val('SELECT region_id FROM locations WHERE id = ?', [$locId]);
            if ($fromRegion && $fromRegion !== (int)$r['to']['region_id']) { require_once __DIR__ . '/seals.php'; $r['gate'] = seal_warden_message((int)$u['id'], $fromRegion, (int)$r['to']['region_id']); }
        }
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


/** 2.6.32: roads in ROAD_DEAD_ENDS stop at their last village. Drops the final leg into the far town from worlds laid before. Safe to repeat. */
function cut_dead_end_roads(): void
{
    if (setting('road_deadends_cut') === '1') return;
    foreach (ROAD_DEAD_ENDS as [$a, $b]) {
        $ra = (int)q_val('SELECT id FROM regions WHERE code = ?', [$a]);
        $rb = (int)q_val('SELECT id FROM regions WHERE code = ?', [$b]);
        if (!$ra || !$rb) continue;
        foreach (q('SELECT * FROM roads')->fetchAll() as $rd) {
            $nodes = array_map('intval', json_decode((string)$rd['nodes'], true) ?: []);
            if (count($nodes) < 3) continue;
            $first = (int)q_val('SELECT region_id FROM locations WHERE id = ?', [$nodes[0]]);
            $lastLoc = q_one('SELECT region_id, kind FROM locations WHERE id = ?', [end($nodes)]);
            if ($first !== $ra || !$lastLoc || (int)$lastLoc['region_id'] !== $rb || $lastLoc['kind'] !== 'market') continue;
            $far = array_pop($nodes);
            $end = (int)end($nodes);
            q('DELETE FROM routes WHERE kind = ? AND ((a_id = ? AND b_id = ?) OR (a_id = ? AND b_id = ?))', ['road', $end, $far, $far, $end]);
            q('UPDATE roads SET nodes = ?, b_town = ? WHERE id = ?', [json_encode($nodes), $end, $rd['id']]);
        }
    }
    set_setting('road_deadends_cut', '1');
    setting('__reload__');
}

/** 2.7.45: a dead-end road (ROAD_DEAD_ENDS) used to keep the name "The Maplewold – Blossomreach" although it stops at Clovercove, so Clovercove looked like it led on to Blossomreach.
 *  Rename it for the village it ends at ("The Maplewold – Clovercove"). Safe to repeat. */
function name_dead_end_roads(): void
{
    if (setting('road_deadends_named') === '1') return;
    foreach (ROAD_DEAD_ENDS as [$a, $b]) {
        $ra = q_one('SELECT id, gnomish_name FROM regions WHERE code = ?', [$a]);
        $rb = q_one('SELECT id, gnomish_name FROM regions WHERE code = ?', [$b]);
        if (!$ra || !$rb) continue;
        $old = $ra['gnomish_name'] . ' – ' . $rb['gnomish_name'];
        foreach (q('SELECT * FROM roads WHERE name = ?', [$old])->fetchAll() as $rd) {
            $nodes = array_map('intval', json_decode((string)$rd['nodes'], true) ?: []);
            if (count($nodes) < 3) continue;
            $last = q_one('SELECT name, kind FROM locations WHERE id = ?', [end($nodes)]);
            if (!$last || $last['kind'] === 'market') continue;   // it reaches the far town: keep the name
            q('UPDATE roads SET name = ? WHERE id = ?', [$ra['gnomish_name'] . ' – ' . $last['name'], $rd['id']]);
        }
    }
    set_setting('road_deadends_named', '1');
    setting('__reload__');
}
