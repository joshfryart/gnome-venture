<?php
declare(strict_types=1);

/**
 * Imports zones, landmarks, villages, routes, creatures (with drop tables), problems
 * and landscape finds from includes/data. Like the crop catalog it only ADDS what's missing.
 *
 * Each region has 4 zones (easy/medium/medium/hard). Each zone holds 2–3 villages
 * threaded along the mycelium. Landmarks (havens, wonders, delves, lairs) hang off
 * specific zones. The region's seed market is the gateway to zone 1.
 */

const LANDSCAPES = [
    'coast' => ['🌊', 'Coast', 'Salt wind, tide pools and gull cries.', ['Tide', 'Shell', 'Salt', 'Kelp', 'Gull', 'Drift', 'Pebble', 'Foam', 'Brine', 'Sandpiper', 'Cockle', 'Spray']],
    'mountain' => ['⛰️', 'Mountain', 'Thin air, steep paths and stone that remembers everything.', ['Crag', 'Stone', 'Pine', 'Echo', 'Cliff', 'Granite', 'Eagle', 'Flint', 'High', 'Scree', 'Cairn', 'Summit']],
    'forest' => ['🌲', 'Forest', 'Green shade, deep moss and something rustling just out of sight.', ['Moss', 'Fern', 'Acorn', 'Oak', 'Bramble', 'Hollow', 'Thicket', 'Toadstool', 'Birch', 'Leaf', 'Hazel', 'Rowan']],
    'desert' => ['🏜️', 'Desert', 'Shimmering heat by day, a sky full of stars by night.', ['Dune', 'Sun', 'Cactus', 'Ember', 'Mirage', 'Amber', 'Sand', 'Scorch', 'Dust', 'Saffron', 'Oasis', 'Copper']],
    'rainforest' => ['🌴', 'Rainforest', 'Dripping leaves, wild calls and flowers bigger than a gnome.', ['Vine', 'Orchid', 'Canopy', 'Mist', 'Liana', 'Monsoon', 'Jade', 'Fig', 'Frond', 'Parrot', 'Bromeliad', 'Drizzle']],
    'grassland' => ['🌾', 'Grassland', 'Rolling grass taller than any gnome, and sky in every direction.', ['Meadow', 'Clover', 'Barley', 'Hay', 'Thistle', 'Lark', 'Prairie', 'Wind', 'Honey', 'Poppy', 'Sorrel', 'Tussock']],
    'wetland' => ['🪷', 'Wetland', 'Reeds, mist and the plop of things you can’t quite see.', ['Reed', 'Bog', 'Lily', 'Mire', 'Heron', 'Cattail', 'Puddle', 'Marsh', 'Sedge', 'Newt', 'Rush', 'Fen']],
    'tundra' => ['❄️', 'Tundra', 'Wide white quiet, lichen underfoot and auroras overhead.', ['Frost', 'Snow', 'Lichen', 'Icicle', 'Aurora', 'Hoarfrost', 'Ptarmigan', 'Glacier', 'Rime', 'Northwind', 'Sleet', 'Willow']],
    'island' => ['🏝️', 'Island', 'Warm sand, coral shallows and coconut palms swaying overhead.', ['Coral', 'Lagoon', 'Palm', 'Reef', 'Conch', 'Atoll', 'Shore', 'Turtle', 'Spindrift', 'Islet', 'Mango', 'Breeze']],
];

const VILLAGE_ENDINGS = ['bottom', 'hollow', 'burrow', 'nook', 'dell', 'by', 'wick', 'stead', 'knoll', 'combe', 'ford',
    'mere', 'holt', 'den', 'glen', 'cove', 'crest', 'thorpe', 'well', 'brook', 'mead', 'gate'];

/** Little things gnomes pick up along the way, by landscape. */
const LANDSCAPE_FINDS = [
    'coast' => [['Kelp Frond', 'A ribbon of seaweed. Gardeners say it’s good for the soil.'], ['Sea Glass', 'Frosted glass worn smooth by the waves.'], ['Blue Mussels', 'Shiny blue shells, still cool from the tide.'], ['Bladderwrack', 'Popping seaweed with little air bladders.']],
    'mountain' => [['Shiny Quartz', 'A clear crystal that catches the light.'], ['Eagle Down', 'A wisp of feather from far above.'], ['Slate Shard', 'A flat grey chip that rings when tapped.'], ['Bilberries', 'Tiny dark berries that stain your fingers.']],
    'forest' => [['Acorn Cap', 'Makes a perfect gnome teacup.'], ['Leaf Mould Clump', 'Dark, crumbly and full of life.'], ['Chanterelle', 'Golden mushrooms that smell faintly of apricots.'], ['Pine Resin', 'A sticky amber bead from a pine trunk.']],
    'desert' => [['Desert Rose Stone', 'Sand crystals grown into a rose.'], ['Old Campfire Ash', 'Ash from a long-cold fire. Rich in potash.'], ['Desert Sage', 'Silvery leaves with a sharp, clean scent.'], ['Red Ochre', 'Soft red rock that leaves a mark on everything.']],
    'rainforest' => [['Giant Seed Pod', 'Rattles when shaken.'], ['Bright Feather', 'Every colour at once.'], ['Laterite Clay', 'Rusty red clay, heavy and damp.'], ['Bromeliad Seeds', 'Tiny seeds from a plant that holds its own pond.']],
    'grassland' => [['Four-leaf Clover', 'Lucky, or so they say.'], ['Wild Honeycomb', 'Sticky and sweet.'], ['Wild Strawberries', 'Small, fragrant and gone in one bite.'], ['Meadowsweet', 'Frothy cream flowers with a honey-almond scent.']],
    'wetland' => [['Cattail Fluff', 'Soft as a cloud.'], ['Bog Peat', 'Dark, damp and ancient.'], ['Cattail Root', 'A starchy root, good for a hungry gnome.'], ['River Clay', 'Smooth grey clay from the bank.']],
    'tundra' => [['Reindeer Lichen', 'A frosty grey lichen.'], ['Frost Crystal', 'Never quite melts.'], ['Crowberries', 'Black berries that last under the snow.'], ['Cottongrass', 'White tufts that nod over the bog.']],
    'island' => [['Cowrie Shell', 'Smooth and glossy, once used as money.'], ['Coconut Husk', 'Hairy, tough and useful.'], ['Sea Grapes', 'Green beads on a string, salty and crisp.'], ['Coir Fibre', 'Tough golden fibre, good for rope.']],
];

/** v2.5.71: only for a village that is not in zones.txt (admin-made); generated villages get a fixed, clash-free pair (tests/village_desc.php). */
if (!defined('VILLAGE_BLURB_SALT')) define('VILLAGE_BLURB_SALT', 'a0');

/**
 * v1.9.4: how a generated village is described. The old text (one sentence per landscape, shared by all 146 villages) is still
 * what is stored; this shows it, or one of the extra sentences in data/village_blurbs.txt, picked from the village's slug so it never changes.
 * A description an admin has written (anything other than the stored landscape sentence) is shown as written.
 */
function village_blurb(array $loc): string
{
    static $pools = null, $quirks = null;
    $desc = (string)($loc['description'] ?? '');
    $land = (string)($loc['landscape'] ?? '');
    if (($loc['kind'] ?? '') !== 'village' || !isset(LANDSCAPES[$land]) || $desc !== LANDSCAPES[$land][2]) return $desc;
    if ($pools === null) {
        $read = function (string $file): array {
            $out = [];
            $path = __DIR__ . '/data/' . $file;
            foreach (is_file($path) ? file($path, FILE_IGNORE_NEW_LINES) : [] as $line) {
                $line = trim($line);
                if ($line === '' || $line[0] === '#') continue;
                $f = array_map('trim', explode('|', $line, 2));
                if (count($f) === 2 && $f[1] !== '') $out[strtolower($f[0])][] = $f[1];
            }
            return $out;
        };
        $pools = $read('village_blurbs.txt');
        $quirks = $read('village_quirks.txt');   // v2.5.71: a second sentence, so the pairs outnumber the villages
    }
    $pool = array_merge([$desc], $pools[$land] ?? []);
    $q = $quirks[$land] ?? [];
    $slug = (string)($loc['slug'] ?? $loc['name'] ?? '');
    $rank = village_land_rank($slug, $land);   // the village's place among its landscape's villages: distinct pairs, no clashes
    if ($rank === null) $rank = crc32(VILLAGE_BLURB_SALT . $slug);   // a village that is not in zones.txt (admin-made): by name
    else $rank = ($rank * 7 + 3) % max(1, count($pool) * max(1, count($q)));   // 7 is coprime with 50 = 5 blurbs x 10 lines: a shuffle, not a sequence
    $one = $pool[$rank % count($pool)];
    return $q ? $one . ' ' . $q[intdiv($rank, count($pool)) % count($q)] : $one;
}

/**
 * A village's Almanac page text (2026-11-14): icon, "A <land> village in <zone>." and its own blurb (village_blurb: no two of the 146 read the same).
 * $own = false gives the old text (the landscape line only, the same for every village of a zone), which ensure_almanac_fixes_1114 replaces.
 */
function village_page_body(array $v, string $zoneName, bool $own = true): string
{
    $L = LANDSCAPES[$v['landscape'] ?? ''] ?? ['', ucfirst((string)($v['landscape'] ?? '')), ''];
    $head = $L[0] . (preg_match('/^[aeiou]/i', (string)$L[1]) ? ' An ' : ' A ') . strtolower((string)$L[1]) . ' village in ' . ($zoneName ?: 'the wilds') . '. ';
    if (!$own) return $head . $L[2];
    $blurb = village_blurb(['kind' => 'village'] + $v + ['description' => $L[2]]);   // an admin-written description is kept as it is
    return $head . ($blurb !== '' ? $blurb : $L[2]);
}

/** v2.5.71: the 0-based position of a generated village (slug v-<region>-<zone>-<n>) among the villages of its landscape, in zones.txt order; null if unknown. */
function village_land_rank(string $slug, string $land): ?int
{
    static $rank = null;
    if ($rank === null) {
        require_once __DIR__ . '/catalog.php';
        $rank = [];
        $n = [];
        foreach (catalog_lines('zones.txt') as $f) {
            if (count($f) < 6) continue;
            for ($i = 1; $i <= max(1, min(5, (int)$f[5])); $i++) {
                $n[$f[2]] = ($n[$f[2]] ?? -1) + 1;
                $rank['v-' . strtolower($f[0]) . '-' . (int)$f[1] . '-' . $i] = $n[$f[2]];
            }
        }
    }
    return isset($rank[$slug]) ? $rank[$slug] : null;
}

const LANDMARK_ICONS = ['haven' => '🏕️', 'wonder' => '✨', 'delve' => '🕳️', 'lair' => '🐉'];

/** Difficulty controls base route level and whether paths are fixed. */
const DIFFICULTY_LEVELS = [
    'easy'   => ['base' => 1,  'range' => 0, 'fixed' => 0],   // scales to player level near a market
    'medium' => ['base' => 10, 'range' => 6, 'fixed' => 1],   // level 10–16 fixed range
    'hard'   => ['base' => 20, 'range' => 10, 'fixed' => 1],  // level 20–30
];

function import_adventure(array $regions, array $regionIds, array $regionById, array &$stats): void
{
    // ----- Landscape finds
    foreach (LANDSCAPE_FINDS as $land => $finds) {
        foreach ($finds as [$name, $desc]) {
            if (!q_val('SELECT 1 FROM items WHERE slug = ?', [slugify($name)])) {
                db_insert('items', ['name' => $name, 'slug' => slugify($name), 'category' => 'forage', 'rarity' => 15,
                    'base_price' => 12, 'description' => $desc]);
                $stats['items']++;
            }
        }
    }

    // ----- Zones and villages
    $zoneRows = catalog_lines('zones.txt');
    $zoneIdByCode = [];      // [regionCode][zoneNum] => zoneId
    $zoneInfo = [];          // zoneId => ['region_id','region_code','region_gnomish','zone_num','landscape','name','difficulty','villages']

    foreach ($zoneRows as $row) {
        if (count($row) < 6) continue;
        [$regCode, $zoneNum, $landscape, $zoneName, $difficulty, $villageCount] = $row;
        $zoneNum = (int)$zoneNum;
        $villageCount = max(1, min(5, (int)$villageCount));
        $difficulty = in_array($difficulty, ['easy', 'medium', 'hard'], true) ? $difficulty : 'easy';
        if (!isset($regionIds[$regCode])) continue;
        $rid = $regionIds[$regCode];

        $zoneId = (int)q_val('SELECT id FROM zones WHERE region_id = ? AND zone_num = ?', [$rid, $zoneNum]);
        if (!$zoneId) {
            $zoneId = db_insert('zones', [
                'region_id' => $rid, 'zone_num' => $zoneNum, 'landscape' => $landscape,
                'name' => $zoneName, 'difficulty' => $difficulty, 'villages' => $villageCount,
            ]);
            $stats['zones']++;
        }
        $zoneIdByCode[$regCode][$zoneNum] = $zoneId;
        $zoneInfo[$zoneId] = [
            'region_id' => $rid, 'region_code' => $regCode,
            'region_gnomish' => $regionById[$rid]['gnomish_name'] ?? '',
            'zone_num' => $zoneNum, 'landscape' => $landscape,
            'name' => $zoneName, 'difficulty' => $difficulty, 'villages' => $villageCount,
        ];
    }

    // Deterministic village names per region+zone so repeat installs are stable
    $used = array_fill_keys(q('SELECT LOWER(name) FROM locations')->fetchAll(PDO::FETCH_COLUMN), true);
    $villageByZone = [];     // zoneId => [villageLocId,...]

    foreach ($zoneInfo as $zoneId => $z) {
        // Skip if this zone already has villages
        if (q_val("SELECT 1 FROM locations WHERE zone_id = ? AND kind = 'village'", [$zoneId])) {
            $villageByZone[$zoneId] = q("SELECT id FROM locations WHERE zone_id = ? AND kind = 'village' ORDER BY sort_order", [$zoneId])
                ->fetchAll(PDO::FETCH_COLUMN);
            continue;
        }
        $land = $z['landscape'];
        if (!isset(LANDSCAPES[$land])) continue;
        $landPrefixes = LANDSCAPES[$land][3];
        mt_srand(crc32($z['region_code'] . ':' . $z['zone_num']));
        $ids = [];
        for ($i = 0; $i < $z['villages']; $i++) {
            $name = '';
            for ($try = 0; $try < 200; $try++) {
                $pre = $landPrefixes[mt_rand(0, count($landPrefixes) - 1)];
                $end = VILLAGE_ENDINGS[mt_rand(0, count(VILLAGE_ENDINGS) - 1)];
                $name = $pre . $end;
                if (!isset($used[strtolower($name)])) break;
            }
            if (isset($used[strtolower($name)])) $name .= ' ' . $z['region_code'] . $z['zone_num'];
            $used[strtolower($name)] = true;
            $slug = 'v-' . strtolower($z['region_code']) . '-' . $z['zone_num'] . '-' . ($i + 1);
            $ids[] = db_insert('locations', [
                'name' => $name, 'slug' => $slug, 'region' => $z['region_gnomish'],
                'kind' => 'village', 'region_id' => $z['region_id'], 'zone_id' => $zoneId,
                'landscape' => $land, 'sort_order' => $z['zone_num'] * 10 + $i,
                'description' => LANDSCAPES[$land][2],
            ]);
            $stats['villages'] = ($stats['villages'] ?? 0) + 1;
        }
        $villageByZone[$zoneId] = $ids;
    }

    // ----- Routes: market -> zone 1 -> zone 2 -> zone 3; zone 4 branches off zone 2
    foreach ($regions as $row) {
        if (count($row) < 2) continue;
        $regCode = $row[0];
        $rid = $regionIds[$regCode] ?? null;
        if (!$rid) continue;
        $market = (int)q_val("SELECT id FROM locations WHERE region_id = ? AND kind = 'market' LIMIT 1", [$rid]);
        if (!$market) continue;

        // Zone 1: gateway from market (gentle, scaled)
        if (!empty($zoneIdByCode[$regCode][1])) {
            thread_through_zone($market, $zoneIdByCode[$regCode][1], $zoneInfo, $villageByZone, true);
        }
        // Chain zones 1→2→3 along the main thread
        for ($zn = 1; $zn < 3; $zn++) {
            $here = $zoneIdByCode[$regCode][$zn] ?? null;
            $next = $zoneIdByCode[$regCode][$zn + 1] ?? null;
            if ($here && $next) link_zones($here, $next, $zoneInfo, $villageByZone);
        }
        // Zone 4 branches from the last village of zone 2 (so it isn't on the main path)
        $branchFrom = $zoneIdByCode[$regCode][2] ?? null;
        $z4 = $zoneIdByCode[$regCode][4] ?? null;
        if ($branchFrom && $z4) link_zones($branchFrom, $z4, $zoneInfo, $villageByZone);
    }

    // ----- Landmarks
    foreach (catalog_lines('landmarks.txt') as $row) {
        if (count($row) < 5) continue;
        [$regCode, $zoneNum, $kind, $name, $desc] = $row;
        $zoneNum = (int)$zoneNum;
        if (!in_array($kind, ['haven', 'wonder', 'delve', 'lair'], true)) continue;
        $rid = $regionIds[$regCode] ?? null;
        $zoneId = $zoneIdByCode[$regCode][$zoneNum] ?? null;
        if (!$rid || !$zoneId) continue;
        if (q_val('SELECT 1 FROM landmarks WHERE region_id = ? AND name = ?', [$rid, $name])) continue;

        $z = $zoneInfo[$zoneId];
        $slug = slugify('lm-' . strtolower($regCode) . '-' . $zoneNum . '-' . $kind . '-' . $name);
        $icon = LANDMARK_ICONS[$kind] ?? '📍';

        // The landmark is also a visitable location: havens are safe stops, lairs are boss sites.
        $locId = db_insert('locations', [
            'name' => $name, 'slug' => $slug, 'region' => $z['region_gnomish'],
            'kind' => $kind === 'haven' ? 'haven' : ($kind === 'lair' ? 'lair' : 'wonder'),
            'region_id' => $rid, 'zone_id' => $zoneId, 'landscape' => $z['landscape'],
            'sort_order' => $zoneNum * 100 + 50,
            'description' => $desc,
        ]);
        db_insert('landmarks', [
            'region_id' => $rid, 'zone_id' => $zoneId, 'location_id' => $locId,
            'kind' => $kind, 'name' => $name, 'description' => $desc, 'sort_order' => $zoneNum,
        ]);
        $stats['landmarks']++;

        // Hang the landmark off the gateway village of its zone (if any)
        $villages = $villageByZone[$zoneId] ?? [];
        if ($villages) {
            $base = DIFFICULTY_LEVELS[$z['difficulty']] ?? DIFFICULTY_LEVELS['easy'];
            // Delves and lairs are harder than the zone's base; wonders match it; havens are scaled.
            if ($kind === 'lair') {
                add_route($villages[0], $locId, $base['base'] + ($base['range'] ?? 0), ($base['range'] ?? 0) / 2, 1);
            } elseif ($kind === 'delve') {
                add_route($villages[0], $locId, $base['base'] + 2, max(1, $base['range'] ?? 2), 1);
            } elseif ($kind === 'wonder') {
                add_route($villages[0], $locId, $base['base'], $base['range'] ?? 0, $base['fixed']);
            } else {
                // haven: scaled, no fixed level
                add_route($villages[0], $locId, 1, 0, 0);
            }
        }

        // Almanac page for the landmark
        $lmKey = 'landmark:' . $slug;
        if (!q_val('SELECT 1 FROM encyclopedia_entries WHERE unlock_key = ?', [$lmKey])) {
            $kindLabel = ['haven' => 'Havens', 'wonder' => 'Wonders', 'delve' => 'Delves', 'lair' => 'Lairs'][$kind];
            db_insert('encyclopedia_entries', [
                'chapter' => 'Landmarks', 'category' => $kindLabel, 'title' => $name,
                'body' => $icon . ' ' . $desc . "\n\n[b]In:[/b] " . $z['region_gnomish'] . ', zone ' . $zoneNum . ' (' . $z['name'] . ').',
                'unlock_key' => $lmKey, 'hint' => 'Visit it on an adventure.',
                'sort_order' => $zoneNum,
            ]);
            $stats['pages']++;
        }
    }

    // ----- Creatures and their drop tables (landscape-based; v0.9.7: its own function so an upgrade can add new ones)
    import_creatures_txt($stats);
    import_pf_creatures($stats);   // 2.7.01: the variants and extra drops of the creature pass

    // ----- Problems
    import_problems_txt();

    // ----- Village pages in the Almanac (unlocked on your first visit)
    foreach (q("SELECT l.*, r.gnomish_name AS region_name, z.name AS zone_name
                FROM locations l LEFT JOIN regions r ON r.id = l.region_id
                LEFT JOIN zones z ON z.id = l.zone_id WHERE l.kind = 'village'")->fetchAll() as $v) {
        if (!q_val('SELECT 1 FROM encyclopedia_entries WHERE unlock_key = ?', ['village:' . $v['slug']])) {
            $L = LANDSCAPES[$v['landscape']] ?? ['', ucfirst((string)$v['landscape']), ''];
            db_insert('encyclopedia_entries', [
                'chapter' => 'Villages', 'category' => substr((string)$v['region_name'], 0, 30), 'title' => $v['name'],
                'body' => village_page_body($v, (string)($v['zone_name'] ?? '')),
                'unlock_key' => 'village:' . $v['slug'],
                'hint' => 'Visit it on your travels (' . strtolower($L[1]) . ').',
                'sort_order' => (int)$v['sort_order'],
            ]);
            $stats['pages']++;
        }
    }
}

/**
 * Problems from data/problems.txt. Only slugs the world doesn't have yet are added (safe to run again: an upgrade uses it to add new ones).
 * v1.9.3: its own function; an optional 5th column is the cond tag (time, season, weather; "!" = must hold). Returns how many were added.
 */
function import_problems_txt(): int
{
    $n = 0;
    foreach (catalog_lines('problems.txt') as $p) {
        if (count($p) < 4) continue;
        [$slug, $text, $lands, $opts] = $p;
        if (q_val('SELECT 1 FROM problems WHERE slug = ?', [$slug])) continue;
        $options = [];
        foreach (explode(';', $opts) as $o) {
            $parts = array_map('trim', explode(':', $o, 3));
            if (count($parts) === 3) $options[] = ['stat' => $parts[0], 'dc' => (int)$parts[1], 'label' => $parts[2]];
        }
        $cond = $p[4] ?? '';
        db_insert('problems', ['slug' => $slug, 'text' => $text, 'landscapes' => $lands, 'options' => json_encode($options), 'cond' => $cond !== '' ? $cond : null]);
        $n++;
    }
    return $n;
}

/**
 * Creatures from data/creatures.txt (+ drop tables and Almanac pages). Only slugs the world doesn't have yet are added, so it is safe
 * to run again on an upgrade: existing creatures (and anything an admin changed) are never touched. v0.9.7: split out of import_adventure.
 */
function import_creatures_txt(array &$stats, string $file = 'creatures.txt'): void   // v1.8.0: Treks pass their own file (trek_creatures.txt)
{
    $sizeMult = ['small' => 0.8, 'medium' => 1.1, 'large' => 1.6, 'boss' => 2.4];
    $sizeAtk = ['small' => 0, 'medium' => 0, 'large' => 2, 'boss' => 2];
    $sizeDef = ['small' => 0, 'medium' => 1, 'large' => 2, 'boss' => 3];
    $sizeDie = ['small' => 4, 'medium' => 6, 'large' => 8, 'boss' => 10];
    foreach (catalog_lines($file) as $c) {
        if (count($c) < 7) continue;   // (the @pool lines of trek_creatures.txt are shorter and skipped here)
        [$slug, $name, $size, $lands, $level, $drops, $desc] = $c;
        $cond = $c[7] ?? '';   // v1.9.3: optional 8th column: when it turns up more often (or "!" = only then)
        if (q_val('SELECT 1 FROM creatures WHERE slug = ?', [$slug])) continue;
        $level = max(1, (int)$level);
        $m = $sizeMult[$size] ?? 1.0;
        $cid = db_insert('creatures', [
            'slug' => $slug, 'name' => $name, 'size' => $size, 'landscapes' => $lands, 'level' => $level,
            'hp' => (int)round((5 + $level * 3) * $m), 'attack' => 1 + intdiv($level, 3) + ($sizeAtk[$size] ?? 0),
            'defense' => 9 + intdiv($level, 3) + ($sizeDef[$size] ?? 0),
            'dmg_die' => $sizeDie[$size] ?? 6, 'dmg_bonus' => intdiv($level, 4),
            'xp' => (int)round($level * 6 * $m), 'description' => $desc, 'cond' => $cond !== '' ? $cond : null,
        ]);
        $names = [];
        foreach (explode(',', $drops) as $d) {
            [$dname, $chance] = array_map('trim', explode(':', $d) + [1 => 50]);
            if ($dname === '') continue;
            if ($dname[0] === '*') {
                db_insert('creature_drops', ['creature_id' => $cid, 'special' => substr($dname, 1), 'chance' => (int)$chance]);
                $names[] = $dname === '*seed' ? 'a local seed' : 'a gardening guide';
                continue;
            }
            $iid = pfc_item_for_drop($dname);
            if (!$iid) {
                $iid = db_insert('items', ['name' => $dname, 'slug' => slugify($dname), 'category' => 'part',
                    'rarity' => min(95, max(5, 100 - (int)$chance + $level)), 'base_price' => max(5, (int)round($level * 4 * (110 - (int)$chance) / 60)),
                    'description' => 'Dropped by the ' . $name . '.']);
                $stats['items']++;
            }
            db_insert('creature_drops', ['creature_id' => $cid, 'item_id' => $iid, 'chance' => (int)$chance]);
            $names[] = $dname;
        }
        $sizeLabel = ['small' => 'Small Creatures', 'medium' => 'Medium Creatures', 'large' => 'Large Creatures', 'boss' => 'Legendary Creatures'][$size] ?? 'Creatures';
        if (!q_val('SELECT 1 FROM encyclopedia_entries WHERE unlock_key = ?', ['creature:' . $slug])) {
            db_insert('encyclopedia_entries', ['chapter' => 'Creatures', 'category' => $sizeLabel, 'title' => $name,
                'body' => $desc . "\n\n[b]Found in:[/b] " . ($lands === 'any' ? 'every landscape' : str_replace(',', ', ', $lands))
                    . " · [b]Level:[/b] $level" . ($names ? "\n[b]Can drop:[/b] " . implode(', ', $names) . '.' : ''),
                'unlock_key' => 'creature:' . $slug, 'hint' => 'Defeat or befriend it on an adventure.', 'sort_order' => $level]);
            $stats['pages']++;
        }
        $stats['creatures'] = ($stats['creatures'] ?? 0) + 1;
    }
}

/**
 * 2.7.02: the item a drop name means. An EXISTING item first (slug, then exact name), so a drop never makes a twin of a gatherable, crop, flower or Sight item.
 * The items that ship with other parts of the game (gatherables, Sight items) are made first (adds only), so a fresh install and an upgrade bind the same way
 * whatever order the install runs in. 0 = nothing of that name exists: the caller makes a new 'part' item.
 */
function pfc_item_for_drop(string $name): int
{
    $look = function () use ($name): int {
        $id = item_id_by_slug(slugify($name));
        return $id ?: (int)q_val('SELECT id FROM items WHERE LOWER(name) = LOWER(?) ORDER BY id LIMIT 1', [$name]);
    };
    if ($id = $look()) return $id;
    static $shipped = false;
    if (!$shipped) {
        $shipped = true;
        try {
            require_once __DIR__ . '/tools.php';
            require_once __DIR__ . '/gathering.php';
            ensure_gatherables();
        } catch (Throwable $e) { /* not installed far enough yet: the later boot steps make them */ }
        try {
            require_once __DIR__ . '/trail_sight_extras.php';
            trail_sights_ensure_items();
        } catch (Throwable $e) {}
    }
    return $look();
}

/**
 * 2.7.01: one drop list of data/pf_creatures.txt (SPEC sec 5.1) as entries. `=` and `=+` heads (a base row) are skipped. Entry: `Item Name:chance%` with gates `@reg=EE/MENA`, `@lv>=N`, `@lv<=N`, `@lv>N`, `@lv<N`,
 * or a special `*seed:N` / `*guide:N`. Returns [['name', 'chance', 'special' (''|seed|guide), 'reg' (null|'EE/MENA'), 'lvmin', 'lvmax'], ...].
 */
function pfc_parse_drops(string $drops): array
{
    $out = [];
    $drops = trim($drops);
    if ($drops === '' || $drops === '=' || $drops === '-') return $out;
    if (str_starts_with($drops, '=+')) $drops = substr($drops, 2);
    foreach (explode(',', $drops) as $d) {
        $d = trim($d);
        if ($d === '' || $d === '=') continue;
        $gates = explode('@', $d); $head = trim(array_shift($gates));
        $pos = strrpos($head, ':');
        $name = $pos === false ? $head : trim(substr($head, 0, $pos));
        $chance = $pos === false ? 50 : (int)rtrim(trim(substr($head, $pos + 1)), '%');
        $e = ['name' => $name, 'chance' => max(1, min(100, $chance)), 'special' => '', 'reg' => null, 'lvmin' => null, 'lvmax' => null];
        if ($name !== '' && $name[0] === '*') { $e['special'] = substr($name, 1); $e['name'] = ''; }
        foreach ($gates as $g) {
            $g = trim($g);
            if (preg_match('/^reg=(.+)$/', $g, $m)) $e['reg'] = trim($m[1]);
            elseif (preg_match('/^lv(>=|<=|>|<)(\d+)$/', $g, $m)) {
                $v = (int)$m[2];
                if ($m[1] === '>=') $e['lvmin'] = $v; elseif ($m[1] === '>') $e['lvmin'] = $v + 1;
                elseif ($m[1] === '<=') $e['lvmax'] = $v; else $e['lvmax'] = $v - 1;
            }
        }
        if ($e['name'] === '' && $e['special'] === '') continue;
        $out[] = $e;
    }
    return $out;
}

/**
 * 2.7.01: the creatures of data/pf_creatures.txt (claude/creature-pass/SPEC.md sec 1). A variant row whose slug the world does not have is added (stats from size and level exactly as import_creatures_txt,
 * drops with their gates, Almanac page); an existing slug is never rewritten. A base row (name `=`) adds the `=+` extra drops it lists that the creature does not have yet. Safe to run again. Returns the creatures added.
 */
function import_pf_creatures(array &$stats): int
{
    require_once __DIR__ . '/pfdeck.php';
    $sizeMult = ['small' => 0.8, 'medium' => 1.1, 'large' => 1.6, 'boss' => 2.4];
    $sizeAtk = ['small' => 0, 'medium' => 0, 'large' => 2, 'boss' => 2];
    $sizeDef = ['small' => 0, 'medium' => 1, 'large' => 2, 'boss' => 3];
    $sizeDie = ['small' => 4, 'medium' => 6, 'large' => 8, 'boss' => 10];
    $added = 0;
    $give = function (int $cid, array $e, int $level, string $cname) use (&$stats): void {
        $row = ['creature_id' => $cid, 'chance' => $e['chance'], 'reg' => $e['reg'], 'lvmin' => $e['lvmin'], 'lvmax' => $e['lvmax']];
        if ($e['special'] !== '') {
            if (q_val('SELECT 1 FROM creature_drops WHERE creature_id = ? AND special = ?', [$cid, $e['special']])) return;
            db_insert('creature_drops', $row + ['special' => $e['special']]);
            return;
        }
        $iid = pfc_item_for_drop($e['name']);
        if (!$iid) {
            $iid = db_insert('items', ['name' => $e['name'], 'slug' => slugify($e['name']), 'category' => 'part',
                'rarity' => min(95, max(5, 100 - (int)$e['chance'] + $level)), 'base_price' => max(5, (int)round($level * 4 * (110 - (int)$e['chance']) / 60)),
                'description' => 'Dropped by the ' . $cname . '.']);
            $stats['items'] = ($stats['items'] ?? 0) + 1;
        }
        if (q_val('SELECT 1 FROM creature_drops WHERE creature_id = ? AND item_id = ?', [$cid, $iid])) return;
        db_insert('creature_drops', $row + ['item_id' => $iid]);
    };
    foreach (pfd_creature_rows(true) as $slug => $r) {
        $have = q_one('SELECT id, name, level FROM creatures WHERE slug = ?', [$slug]);
        if ($r['base']) {   // a base row: the old creature stays, only the extra drops are added
            if (!$have) continue;
            foreach (pfc_parse_drops($r['drops']) as $e) $give((int)$have['id'], $e, (int)$have['level'], (string)$have['name']);
            continue;
        }
        if ($have || !$r['name'] || !$r['size'] || !$r['lands']) continue;
        $size = (string)$r['size']; $level = max(1, (int)$r['level']); $m = $sizeMult[$size] ?? 1.0;
        $cond = (string)$r['cond'];
        $cid = db_insert('creatures', [
            'slug' => $slug, 'name' => $r['name'], 'size' => $size, 'landscapes' => $r['lands'], 'level' => $level,
            'hp' => (int)round((5 + $level * 3) * $m), 'attack' => 1 + intdiv($level, 3) + ($sizeAtk[$size] ?? 0),
            'defense' => 9 + intdiv($level, 3) + ($sizeDef[$size] ?? 0),
            'dmg_die' => $sizeDie[$size] ?? 6, 'dmg_bonus' => intdiv($level, 4),
            'xp' => (int)round($level * 6 * $m), 'description' => (string)$r['desc'], 'cond' => ($cond !== '' && $cond !== '-' && $cond !== '=') ? $cond : null,
        ]);
        $names = [];
        foreach (pfc_parse_drops($r['drops']) as $e) {
            $give($cid, $e, $level, (string)$r['name']);
            $names[] = $e['special'] === 'seed' ? 'a local seed' : ($e['special'] === 'guide' ? 'a gardening guide' : $e['name']);
        }
        $sizeLabel = ['small' => 'Small Creatures', 'medium' => 'Medium Creatures', 'large' => 'Large Creatures', 'boss' => 'Legendary Creatures'][$size] ?? 'Creatures';
        if (!q_val('SELECT 1 FROM encyclopedia_entries WHERE unlock_key = ?', ['creature:' . $slug])) {
            db_insert('encyclopedia_entries', ['chapter' => 'Creatures', 'category' => $sizeLabel, 'title' => $r['name'],
                'body' => $r['desc'] . "\n\n[b]Found in:[/b] " . ($r['lands'] === 'any' ? 'every landscape' : str_replace(',', ', ', $r['lands']))
                    . " · [b]Level:[/b] $level" . ($names ? "\n[b]Can drop:[/b] " . implode(', ', array_unique($names)) . '.' : ''),
                'unlock_key' => 'creature:' . $slug, 'hint' => 'Defeat or befriend it on an adventure.', 'sort_order' => $level]);
            $stats['pages'] = ($stats['pages'] ?? 0) + 1;
        }
        $stats['creatures'] = ($stats['creatures'] ?? 0) + 1;
        $added++;
    }
    return $added;
}

/** Thread villages inside a zone together, starting from an outside location (usually the market). */
function thread_through_zone(int $from, int $zoneId, array $zoneInfo, array $villageByZone, bool $gentle = false): void
{
    $villages = $villageByZone[$zoneId] ?? [];
    if (!$villages) return;
    $z = $zoneInfo[$zoneId];
    $diff = DIFFICULTY_LEVELS[$z['difficulty']] ?? DIFFICULTY_LEVELS['easy'];
    // From-outside -> first village: gentle if gateway, otherwise base
    add_route($from, $villages[0], $gentle ? 1 : $diff['base'], $gentle ? 0 : $diff['range'], $gentle ? 0 : $diff['fixed']);
    // Chain the rest inside the zone, danger rising a touch each step
    for ($i = 1; $i < count($villages); $i++) {
        $lvl = $diff['base'] + $i * 2;
        add_route($villages[$i - 1], $villages[$i], $lvl, $diff['range'], $diff['fixed']);
    }
}

/** Link the last village of one zone to the first of the next, then thread through that zone. */
function link_zones(int $fromZoneId, int $toZoneId, array $zoneInfo, array $villageByZone): void
{
    $fromV = $villageByZone[$fromZoneId] ?? [];
    if (!$fromV) return;
    $last = end($fromV);
    thread_through_zone((int)$last, $toZoneId, $zoneInfo, $villageByZone, false);
}

function add_route(int $a, int $b, int $level, int $range = 0, int $fixed = 0): void
{
    if (setting('world_layout') === 'roads') return;   // v0.7.24: roads and side paths are laid by includes/roads.php
    if (q_val('SELECT 1 FROM routes WHERE (a_id = ? AND b_id = ?) OR (a_id = ? AND b_id = ?)', [$a, $b, $b, $a])) return;
    $steps = 3 + min(3, intdiv($level, 8));
    $min = max(1, $level - max(0, intdiv($range, 2)));
    $max = max($min, $level + max(0, intdiv($range, 2)));
    db_insert('routes', ['a_id' => $a, 'b_id' => $b, 'steps' => $steps, 'minutes' => $steps * 3,
        'level' => $level, 'min_level' => $min, 'max_level' => $max, 'fixed' => $fixed]);
}


/**
 * v0.7.64: the first "large" creatures (levels 14–16) jumped far above level 13 (health 48 → 75, d6 → d8 bites).
 * Ease them in. Safe to run again; skips creatures an admin has given different stats since.
 */
function smooth_creatures(): void
{
    // v1.4.0: new wild creatures (creatures.txt) reach existing installs here: this runs on every version change and only adds slugs not yet in the world
    require_once __DIR__ . '/catalog.php';
    $stats = ['items' => 0, 'pages' => 0];
    import_creatures_txt($stats);
    import_pf_creatures($stats);   // 2.7.01
    $fix = ['grass-snake' => [75, 7, 15, 8, 3, 58, 6, 15, 6, 3], 'grey-heron' => [80, 8, 16, 8, 3, 66, 6, 15, 8, 3],
            'mischief-monkey' => [80, 8, 16, 8, 3, 66, 6, 15, 8, 3], 'red-fox' => [85, 8, 16, 8, 4, 76, 7, 16, 8, 3], 'raccoon' => [85, 8, 16, 8, 4, 76, 7, 16, 8, 3]];
    foreach ($fix as $slug => [$h0, $a0, $d0, $die0, $b0, $h, $a, $d, $die, $b]) {
        q('UPDATE creatures SET hp = ?, attack = ?, defense = ?, dmg_die = ?, dmg_bonus = ? WHERE slug = ? AND hp = ? AND attack = ? AND defense = ? AND dmg_die = ? AND dmg_bonus = ?',
            [$h, $a, $d, $die, $b, $slug, $h0, $a0, $d0, $die0, $b0]);
    }
}
