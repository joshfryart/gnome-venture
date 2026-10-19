<?php
declare(strict_types=1);

/**
 * World catalog importer. Reads includes/data/crops.txt, flowers.txt, regions.txt, zones.txt,
 * landmarks.txt and region_crops.txt and creates seeds, produce, plants, flowers, regions, zones,
 * landmarks, gardening guides, regional markets (with staff and stock) and Almanac pages.
 * It only ADDS what's missing, so admin edits are never overwritten.
 */

/** Everyday crops every gardener already knows how to grow, sold at the Mossbottom hub. */
const COMMON_CROPS = ['tomato', 'potato', 'onion', 'garlic', 'carrot', 'cabbage', 'lettuce', 'radish', 'spinach',
    'cucumber', 'pumpkin', 'green-bean', 'pea', 'beet', 'turnip', 'kale', 'basil', 'mint', 'parsley', 'coriander',
    'dill', 'sunflower', 'strawberry', 'white-clover', 'winter-rye', 'crimson-clover',
    'celery', 'cauliflower', 'broccoli', 'fennel', 'horseradish', 'rosemary', 'thyme'];

/** Hungry crops that drain soil fertility faster. */
const HEAVY_FEEDERS = ['corn', 'tomato', 'pumpkin', 'cabbage', 'potato', 'broccoli', 'cauliflower', 'eggplant',
    'bell-pepper', 'sugarcane', 'watermelon', 'melon', 'napa-cabbage', 'celery', 'brussels-sprouts', 'rice', 'cassava'];

function catalog_lines(string $file): array
{
    $out = [];
    foreach (file(__DIR__ . '/data/' . $file, FILE_IGNORE_NEW_LINES) as $line) {
        $line = trim($line);
        if ($line === '' || $line[0] === '#') {
            continue;
        }
        $out[] = array_map('trim', explode('|', $line));
    }
    return $out;
}

function catalog_kind_label(string $kind): string
{
    return [
        'vegetable' => 'Vegetables', 'tuber' => 'Roots & Tubers', 'legume' => 'Beans & Pulses',
        'grain' => 'Grains & Seeds', 'fruit' => 'Fruits & Berries', 'tree' => 'Orchard & Palms',
        'nut' => 'Nuts', 'herb' => 'Herbs', 'spice' => 'Spices', 'cover' => 'Cover Crops', 'flower' => 'Flowers',
    ][$kind] ?? 'Other';
}

function catalog_kind_icon(string $kind): string
{
    return ['vegetable' => '🥬', 'tuber' => '🥔', 'legume' => '🫛', 'grain' => '🌾', 'fruit' => '🍓',
        'tree' => '🌳', 'nut' => '🌰', 'herb' => '🌿', 'spice' => '🌶️', 'cover' => '☘️', 'flower' => '🌸'][$kind] ?? '🌱';
}

function guide_item_slug(string $regionCode): string
{
    return 'guide-' . strtolower($regionCode);
}

function import_catalog(): array
{
    $stats = ['items' => 0, 'plants' => 0, 'regions' => 0, 'zones' => 0, 'landmarks' => 0,
        'links' => 0, 'pages' => 0, 'milestones' => 0, 'markets' => 0];

    $crops = catalog_lines('crops.txt');
    $flowers = catalog_lines('flowers.txt');
    $regions = catalog_lines('regions.txt');
    $regionCrops = catalog_lines('region_crops.txt');

    // --- Index: which plants belong to each region, and at what tier
    // regionTiers[regionCode] = ['staple'=>[slug,...], 'uncommon'=>[...], 'treasure'=>[...]]
    $regionTiers = [];
    $plantTier = [];     // plantSlug -> [regionCode => tier]
    foreach ($regionCrops as $row) {
        if (count($row) < 3) continue;
        [$code, $tier, $list] = $row;
        $regionTiers[$code][$tier] = array_map('trim', explode(',', $list));
        foreach ($regionTiers[$code][$tier] as $slug) {
            $plantTier[$slug][$code] = $tier;
        }
    }
    // Flowers belong to a single region
    $regionFlowers = [];
    foreach ($flowers as $f) {
        if (count($f) < 7) continue;
        $regionFlowers[$f[2]][] = $f[0];
    }

    $growByTier = [1 => 15, 2 => 40, 3 => 90, 4 => 180, 5 => 360, 6 => 720];
    $waterByTier = [1 => 360, 2 => 480, 3 => 720, 4 => 1080, 5 => 1440, 6 => 1440];
    $seedNames = [
        'potato' => 'Seed Potatoes', 'sweet-potato' => 'Sweet Potato Slips', 'cassava' => 'Cassava Cuttings',
        'yam' => 'Seed Yams', 'taro' => 'Taro Corms', 'garlic' => 'Garlic Cloves', 'ginger' => 'Ginger Rhizome',
        'turmeric' => 'Turmeric Rhizome', 'saffron' => 'Saffron Corms', 'horseradish' => 'Horseradish Root',
        'sugarcane' => 'Sugarcane Cuttings', 'asparagus' => 'Asparagus Crowns', 'rhubarb' => 'Rhubarb Crown',
        'strawberry' => 'Strawberry Runners', 'mint' => 'Mint Cutting', 'lemongrass' => 'Lemongrass Stalk',
        'banana' => 'Banana Sucker', 'plantain' => 'Plantain Sucker', 'ensete' => 'Enset Sucker',
        'pineapple' => 'Pineapple Crown', 'vanilla' => 'Vanilla Cutting', 'black-pepper' => 'Pepper Vine Cutting',
        'hops' => 'Hop Rhizome', 'wasabi' => 'Wasabi Offset', 'nopal' => 'Cactus Pad', 'bamboo-shoot' => 'Bamboo Rhizome',
        'grape' => 'Grape Vine Cutting', 'kava' => 'Kava Cutting', 'lotus-root' => 'Lotus Rhizome',
        'greigs-tulip' => "Greig's Tulip Bulbs", 'dutch-tulip' => 'Dutch Tulip Bulbs', 'giant-allium' => 'Giant Allium Bulbs',
        'snowdrop' => 'Snowdrop Bulbs', 'bluebell' => 'Bluebell Bulbs', 'crinum-lily' => 'Crinum Lily Bulb',
        'blood-lily' => 'Blood Lily Bulb', 'spider-lily' => 'Spider Lily Bulb', 'dahlia' => 'Dahlia Tuber',
        'cyclamen' => 'Cyclamen Tuber', 'gloriosa-lily' => 'Gloriosa Tuber', 'crown-anemone' => 'Anemone Corms',
        'persian-buttercup' => 'Ranunculus Corms', 'bukhara-iris' => 'Bukhara Iris Bulb', 'florentine-iris' => 'Iris Rhizome',
        'black-iris' => 'Black Iris Rhizome', 'agapanthus' => 'Agapanthus Division', 'blue-lotus' => 'Blue Lotus Tuber',
        'sacred-lotus' => 'Lotus Rhizome', 'lily-of-the-valley' => 'Lily of the Valley Pips', 'foxtail-lily' => 'Foxtail Lily Crown',
    ];
    $produceNames = [
        'date' => 'Dates', 'sago' => 'Sago Starch', 'pandanus' => 'Pandanus Fruit', 'tea' => 'Tea Leaves',
        'coffee' => 'Coffee Cherries', 'cacao' => 'Cacao Pods', 'sugarcane' => 'Sugarcane Stalks',
        'hops' => 'Hop Cones', 'kava' => 'Kava Root', 'yerba-mate' => 'Yerba Mate Leaves',
        'saffron' => 'Saffron Threads', 'nopal' => 'Prickly Pears', 'ensete' => 'Enset Stem',
        'hibiscus' => 'Roselle Calyces', 'sunflower' => 'Sunflower Seeds', 'sesame' => 'Sesame Seeds',
        'olive' => 'Olives', 'grape' => 'Grapes', 'acai' => 'Açaí Berries', 'coconut' => 'Coconut',
        'moringa' => 'Moringa Leaves', 'baobab' => 'Baobab Fruit', 'shea' => 'Shea Nuts', 'cashew' => 'Cashews',
        'almond' => 'Almonds', 'walnut' => 'Walnuts', 'hazelnut' => 'Hazelnuts', 'pistachio' => 'Pistachios',
        'chestnut' => 'Chestnuts', 'macadamia' => 'Macadamias', 'brazil-nut' => 'Brazil Nuts', 'pecan' => 'Pecans',
        'kola' => 'Kola Nuts', 'vanilla' => 'Vanilla Pods', 'black-pepper' => 'Peppercorns', 'cinnamon' => 'Cinnamon Bark',
        'clove' => 'Cloves', 'nutmeg' => 'Nutmeg', 'cardamom' => 'Cardamom Pods', 'caper' => 'Capers',
        'cumin' => 'Cumin Seeds', 'sea-buckthorn' => 'Sea Buckthorn Berries', 'carob' => 'Carob Pods',
    ];
    $notRaw = ['cassava', 'kidney-bean', 'coffee', 'cacao', 'tea', 'hops', 'kava', 'wheat', 'rice', 'barley', 'rye',
        'oats', 'millet', 'sorghum', 'teff', 'fonio', 'quinoa', 'buckwheat', 'corn', 'yam', 'taro', 'potato',
        'ackee', 'sago', 'ensete', 'yerba-mate', 'soybean', 'lentil', 'chickpea', 'fava-bean', 'black-bean',
        'adzuki', 'cowpea', 'pigeon-pea', 'bambara', 'olive', 'shea', 'nutmeg', 'clove', 'cinnamon',
        'black-pepper', 'vanilla', 'cumin', 'saffron', 'ginseng', 'cardamom', 'hibiscus', 'lotus-root',
        'bamboo-shoot', 'egusi', 'wild-rice'];
    $statByKind = ['vegetable' => 'hardiness', 'tuber' => 'grit', 'legume' => 'grit', 'grain' => 'grit',
        'fruit' => 'nimble', 'tree' => 'nimble', 'nut' => 'lore', 'herb' => 'sense', 'spice' => 'charm'];
    $itemId = fn(string $slug): int => (int)q_val('SELECT id FROM items WHERE slug = ?', [$slug]);

    $own = !db()->inTransaction();   // the installer already wraps everything in one transaction
    if ($own) db()->beginTransaction();
    try {
        // ----- Regions
        $regionIds = [];      // code -> id
        $regionById = [];     // id -> row
        foreach ($regions as $i => $row) {
            if (count($row) < 6) continue;
            [$code, $gnomish, $realName, $merged, $climate, $soil] = $row;
            $existing = q_one('SELECT * FROM regions WHERE code = ?', [$code]);
            if (!$existing) {
                $id = db_insert('regions', [
                    'code' => $code, 'gnomish_name' => $gnomish, 'real_name' => $realName,
                    'climate_trait' => $climate, 'soil_type' => $soil,
                    'description' => "Also known as $realName. Merged from: $merged.",
                    'sort_order' => $i,
                ]);
                $stats['regions']++;
            } else {
                $id = (int)$existing['id'];
            }
            $regionIds[$code] = $id;
            $regionById[$id] = ['code' => $code, 'gnomish_name' => $gnomish, 'real_name' => $realName];
        }

        // ----- Crops and flowers share one pipeline
        $all = [];
        foreach ($crops as $row) {
            if (count($row) < 6) continue;
            [$slug, $name, $kind, $tier, $per, $desc] = $row;
            $all[] = compact('slug', 'name', 'kind', 'tier', 'per', 'desc')
                + ['region_code' => null, 'pollinator' => null];
        }
        foreach ($flowers as $row) {
            if (count($row) < 7) continue;
            [$slug, $name, $regionCode, $tier, $per, $poll, $desc] = $row;
            $all[] = ['slug' => $slug, 'name' => $name, 'kind' => 'flower', 'tier' => $tier, 'per' => $per,
                'desc' => $desc . ' Attracts ' . $poll . 's.', 'region_code' => $regionCode, 'pollinator' => $poll];
        }

        foreach ($all as $c) {
            $slug = $c['slug'];
            $name = $c['name'];
            $kind = $c['kind'];
            $tier = max(1, min(6, (int)$c['tier']));
            $perennial = (int)$c['per'];
            $isFlower = $kind === 'flower';
            $common = in_array($slug, COMMON_CROPS, true) ? 1 : 0;

            // Rarity: how many regions it grows in; treasures are rarer
            $regionList = $plantTier[$slug] ?? [];
            $n = count($regionList);
            $isTreasure = !$isFlower && in_array('treasure', $regionList, true);
            $rarity = $isFlower ? min(90, 15 + $tier * 9)
                : ($common ? 2 + $tier
                    : ($isTreasure ? max(60, min(95, 85 + $tier * 2))
                        : ($n > 0 ? max(10, min(75, 50 + $tier * 5 - $n * 5))
                            : 40 + $tier * 5)));
            $seedPrice = (int)round(4 + $tier * 4 + $rarity * 0.6 + ($perennial ? $tier * 6 : 0));
            $producePrice = (int)round(3 + $tier * 3 + $rarity * 0.4 + ($isFlower ? 6 : 0));
            $treeLike = in_array($kind, ['tree', 'nut'], true) || ($perennial && $tier >= 6);

            $seedName = $seedNames[$slug] ?? ($treeLike ? $name . ' Seedling'
                : ($isFlower && $perennial && $tier >= 5 ? $name . ' Cutting' : $name . ' Seeds'));
            $seedId = $itemId($slug . '-seed');
            if (!$seedId) {
                $seedId = db_insert('items', ['name' => $seedName, 'slug' => $slug . '-seed', 'category' => 'seed',
                    'rarity' => $rarity, 'base_price' => $seedPrice, 'description' => 'Plant it to grow ' . $name . '.']);
                $stats['items']++;
            }

            $produceId = null;
            if ($kind !== 'cover') {
                $pslug = $isFlower ? 'cut-' . $slug : $slug;
                $produceId = $itemId($pslug);
                if (!$produceId) {
                    $edible = ($isFlower || in_array($slug, $notRaw, true)) ? 0 : 1;
                    $effects = null;
                    if ($edible) {
                        $stat = $statByKind[$kind] ?? 'hardiness';
                        $temp = [$stat => 1 + intdiv($tier, 3), 'minutes' => 60 + $tier * 30];
                        // Treasure crops: a permanent +1 the first time each gnome eats one.
                        // v0.9.4: raw energy and scraps are added after the import (apply_raw_food_energy)
                        $effects = $isTreasure
                            ? json_encode(['perm' => [in_array($kind, ['fruit', 'tree'], true) ? 'luck' : $stat => 1], 'temp' => $temp])
                            : json_encode(['temp' => $temp]);
                    }
                    $pname = $isFlower ? ($treeLike ? $name . ' Blossoms' : 'Cut ' . $name) : ($produceNames[$slug] ?? $name);
                    $produceId = db_insert('items', ['name' => $pname, 'slug' => $pslug, 'category' => $isFlower ? 'flower' : 'produce',
                        'rarity' => $rarity, 'base_price' => $producePrice, 'description' => $c['desc'],
                        'edible' => $edible, 'effects' => $effects]);
                    $stats['items']++;
                }
            }

            $soilEffect = match (true) {
                $kind === 'cover' => 20,
                $kind === 'legume' => 8,
                $isFlower => -3,
                in_array($slug, HEAVY_FEEDERS, true) => -15,
                $treeLike => -4,
                default => -8,
            };
            $plantId = (int)q_val('SELECT id FROM plants WHERE slug = ?', [$slug]);
            if (!$plantId) {
                $grow = $growByTier[$tier];
                $plantId = db_insert('plants', [
                    'name' => $name, 'slug' => $slug, 'kind' => $kind, 'perennial' => $perennial,
                    'regrow_minutes' => $perennial ? max(30, intdiv($grow, 3)) : 0,
                    'common' => $common, 'region_code' => $c['region_code'], 'pollinator' => $c['pollinator'], 'soil_effect' => $soilEffect,
                    'seed_item_id' => $seedId, 'produce_item_id' => $produceId,
                    'grow_minutes' => $grow, 'water_interval_minutes' => $waterByTier[$tier],
                    'stages' => 4, 'yield_min' => $treeLike ? 2 : 1, 'yield_max' => $treeLike ? 5 : 3,
                    'xp_per_harvest' => $tier * $tier * 2 + intdiv($rarity, 10),
                    'knowledge_max' => 100, 'knowledge_per_harvest' => 8 + $tier * 2,
                    'min_soil' => $tier >= 5 ? 40 : ($tier >= 3 ? 25 : 0),
                    'description' => $c['desc'],
                ]);
                $stats['plants']++;
            }

            // Link to regions. Crops come from region_crops.txt tiers; flowers from flowers.txt region_code.
            if ($isFlower && $c['region_code'] && isset($regionIds[$c['region_code']])) {
                $rid = $regionIds[$c['region_code']];
                if (!q_val('SELECT 1 FROM plant_regions WHERE plant_id = ? AND region_id = ?', [$plantId, $rid])) {
                    db_insert('plant_regions', ['plant_id' => $plantId, 'region_id' => $rid, 'tier' => 'flower']);
                    $stats['links']++;
                }
            } else {
                foreach ($regionList as $rCode => $tierName) {
                    if (!isset($regionIds[$rCode])) continue;
                    $rid = $regionIds[$rCode];
                    if (!q_val('SELECT 1 FROM plant_regions WHERE plant_id = ? AND region_id = ?', [$plantId, $rid])) {
                        db_insert('plant_regions', ['plant_id' => $plantId, 'region_id' => $rid, 'tier' => $tierName]);
                        $stats['links']++;
                    }
                }
            }

            // Almanac page for the plant / flower
            if (!q_val('SELECT 1 FROM encyclopedia_entries WHERE unlock_key = ?', ['plant:' . $slug])) {
                if ($isFlower) {
                    $r = $regionById[$regionIds[$c['region_code']] ?? 0] ?? null;
                    $whereText = $r ? "\n\n[b]Native to:[/b] " . $r['gnomish_name'] . " (" . $r['real_name'] . ")." : '';
                } elseif ($kind === 'cover') {
                    $whereText = "\n\n[b]Cover crop:[/b] dig it in instead of harvesting to feed your soil.";
                } else {
                    $tierParts = [];
                    foreach ($regionList as $rCode => $tierName) {
                        $r = $regionById[$regionIds[$rCode] ?? 0] ?? null;
                        if ($r) $tierParts[$tierName][] = $r['gnomish_name'];
                    }
                    $bits = [];
                    foreach (['staple' => 'A staple of', 'uncommon' => 'Also grown in', 'treasure' => 'A rare treasure of'] as $t => $label) {
                        if (!empty($tierParts[$t])) $bits[] = "[b]$label:[/b] " . implode(', ', $tierParts[$t]);
                    }
                    $whereText = $bits ? "\n\n" . implode("\n", $bits) . '.' : "\n\nGrown in home gardens all over the world.";
                }
                $info = sprintf("\n\n[b]Grows in:[/b] about %s of watered time · [b]Water every:[/b] %d h · [b]Needs fertility:[/b] %d%s",
                    $growByTier[$tier] >= 60 ? round($growByTier[$tier] / 60, 1) . ' h' : $growByTier[$tier] . ' min',
                    intdiv($waterByTier[$tier], 60), $tier >= 5 ? 40 : ($tier >= 3 ? 25 : 0),
                    $perennial ? ' · [b]Perennial:[/b] keeps producing after harvest' : '');
                db_insert('encyclopedia_entries', [
                    'chapter' => $isFlower ? 'Flowers' : 'Plants',
                    'category' => $isFlower ? ($regionById[$regionIds[$c['region_code']] ?? 0]['gnomish_name'] ?? 'Flowers') : catalog_kind_label($kind),
                    'title' => $name, 'body' => $c['desc'] . $whereText . $info, 'unlock_key' => 'plant:' . $slug,
                    'hint' => $isFlower ? 'Grow and cut it once.' : ($kind === 'cover' ? 'Grow it and dig it in once.' : 'Grow and harvest it once.'),
                    'sort_order' => 0,
                ]);
                $stats['pages']++;
            }
        }

        // ----- Region pages (one per region, Gnomish name + flavour)
        foreach ($regions as $row) {
            if (count($row) < 6) continue;
            [$code, $gnomish, $realName, $merged, $climate, $soil] = $row;
            $key = 'region:' . strtolower($code);
            if (q_val('SELECT 1 FROM encyclopedia_entries WHERE unlock_key = ?', [$key])) continue;
            db_insert('encyclopedia_entries', [
                'chapter' => 'Regions', 'category' => 'Regions',
                'title' => $gnomish,
                'body' => "A full region of the Hollow: $gnomish, known in the human world as $realName.\n\n"
                    . "[b]Climate:[/b] $climate\n[b]Soil:[/b] $soil\n[b]Covers:[/b] $merged.",
                'unlock_key' => $key,
                'hint' => 'Reach Gold tier in ' . $gnomish . ' (grow all its staples, uncommons, treasures and flowers).',
                'sort_order' => 0,
            ]);
            $stats['pages']++;
        }

        // ----- Gardening guides (one per region) + regional markets, zones, landmarks
        $stats['markets'] = import_markets($regions, $regionIds, $regionById, $regionTiers, $regionFlowers, $stats);

        // ----- Living soil: Almanac pages and milestones for no-till soil grades
        ensure_soil_content($stats);

        // ----- Villages, routes, landmarks, creatures, problems
        require_once __DIR__ . '/adventure_data.php';
        import_adventure($regions, $regionIds, $regionById, $stats);
        smooth_creatures();   // v0.7.64

        // ----- Recipes and the dishes they make
        $stats['recipes'] = import_recipes($stats);

        // ----- Default milestones (only if none exist yet)
        if (!(int)q_val("SELECT COUNT(*) FROM almanac_milestones WHERE unlock_key IS NULL OR unlock_key NOT LIKE 'soil:%'")) {
            $loam = $itemId('rich-loam') ?: null;
            $m = function (string $name, string $kind, int $th, ?string $key, int $coins, ?int $item, int $qty, ?string $title) use (&$stats) {
                db_insert('almanac_milestones', ['name' => $name, 'kind' => $kind, 'threshold' => $th, 'unlock_key' => $key,
                    'reward_coins' => $coins, 'reward_item_id' => $item, 'reward_qty' => $qty, 'reward_title' => $title]);
                $stats['milestones']++;
            };
            $m('First pages', 'pages', 10, null, 100, $loam, 2, 'Sprout Spotter');
            $m('Budding botanist', 'pages', 25, null, 300, $loam, 4, 'Seedling Scholar');
            $m('Half a shelf', 'pages', 50, null, 750, $loam, 6, 'Garden Scribe');
            $m('Field naturalist', 'pages', 100, null, 2000, $loam, 10, 'Field Naturalist');
            $m('World grower', 'pages', 200, null, 5000, null, 1, 'World Grower');
            $m('Living encyclopedia', 'pages', 400, null, 10000, null, 1, 'Living Encyclopedia');
            $m('A quarter complete', 'percent', 25, null, 1500, null, 1, null);
            $m('Halfway there', 'percent', 50, null, 4000, null, 1, null);
            $m('Three quarters', 'percent', 75, null, 8000, null, 1, null);
            $m('The complete Almanac', 'percent', 100, null, 25000, null, 1, 'Master of the Almanac');
            $m('First region', 'key', 0, 'region:*', 250, $loam, 3, 'Traveller');
            // Bronze / Silver / Gold milestones per region
            foreach ($regions as $row) {
                if (count($row) < 2) continue;
                [$code, $gnomish] = $row;
                $m("$gnomish — Bronze", 'key', 0, 'region:' . strtolower($code) . ':bronze', 200, $loam, 3, 'Visitor of ' . $gnomish);
                $m("$gnomish — Silver", 'key', 0, 'region:' . strtolower($code) . ':silver', 500, $loam, 6, 'Friend of ' . $gnomish);
                $m("$gnomish — Gold",   'key', 0, 'region:' . strtolower($code) . ':gold',   1500, $loam, 12, 'Keeper of ' . $gnomish);
            }
        }
        if ($own) db()->commit();
    } catch (Throwable $e) {
        if ($own) db()->rollBack();
        throw $e;
    }
    return $stats;
}

/** One market per world region: location, seed shop, three shifts of staff, stock incl. a rare guide. */
function import_markets(array $regions, array $regionIds, array $regionById, array $regionTiers, array $regionFlowers, array &$stats): int
{
    $first = ['Bramble', 'Clover', 'Fennick', 'Hazel', 'Juniper', 'Moss', 'Nettle', 'Pebble', 'Quill', 'Rowan', 'Sorrel',
        'Tansy', 'Thistle', 'Willow', 'Yarrow', 'Burdock', 'Cricket', 'Dew', 'Ember', 'Fern', 'Ginger', 'Holly', 'Ivy',
        'Jasper', 'Kestrel', 'Lark', 'Maple', 'Nutmeg', 'Oakley', 'Poppy', 'Reed', 'Sage', 'Tumble'];
    $last = ['Mossfoot', 'Dewberry', 'Thornwhistle', 'Burrowman', 'Leafwhisker', 'Puddlejump', 'Seedwell', 'Barkley',
        'Petalwing', 'Rootstock', 'Hollowell', 'Sunpatch', 'Brambleby', 'Fernsway'];
    $species = ['Hedgehog', 'Ladybird', 'Snail', 'Frog', 'Bumblebee', 'Field mouse', 'Grasshopper', 'Tortoise',
        'Dormouse', 'Beetle', 'Wren', 'Mole', 'Dragonfly', 'Hare', 'Gecko', 'Butterfly'];
    $moods = ['Cheerful', 'Grumpy', 'Dreamy', 'Chatty', 'Shy', 'Curious', 'Fussy', 'Generous', 'Sleepy', 'Proud'];

    $made = 0;
    $i = 0;
    foreach ($regions as $row) {
        if (count($row) < 6) continue;
        [$code, $gnomish, $realName, $merged, $climate, $soil] = $row;
        $rid = $regionIds[$code] ?? null;
        if (!$rid) continue;
        $rslug = strtolower($code);

        // Guide item
        $guideId = (int)q_val('SELECT id FROM items WHERE slug = ?', [guide_item_slug($code)]);
        if (!$guideId) {
            $guideId = db_insert('items', ['name' => 'Gardening Guide: ' . $gnomish, 'slug' => guide_item_slug($code),
                'category' => 'guide', 'rarity' => 85, 'base_price' => 1800, 'tradable' => 1,
                'description' => "Teaches you to grow every crop and flower of $gnomish, and fills in what you've studied in your Almanac. Read it from your satchel.",
                'effects' => json_encode(['guide' => 'region:' . $rslug])]);
            $stats['items']++;
        }

        if (q_val('SELECT 1 FROM shops WHERE slug = ?', [$rslug . '-seed-market'])) {   // v0.7.37: was checking the wrong slug, so a second import crashed
            $i += 3;
            continue;
        }
        $locSlug = 'market-' . $rslug;
        $locId = (int)q_val('SELECT id FROM locations WHERE slug = ?', [$locSlug]);
        if (!$locId) {
            $locId = db_insert('locations', [
                'name' => $gnomish . ' Market', 'slug' => $locSlug,
                'region' => $gnomish, 'region_id' => $rid, 'kind' => 'market',
                'description' => "The seed market at the heart of $gnomish ($realName). $climate.",
            ]);
        }
        $shopId = db_insert('shops', [
            'name' => $gnomish . ' Seed Market', 'slug' => $rslug . '-seed-market', 'location_id' => $locId,
            'shop_type' => 'seeds',
            'description' => "Seeds and flowers from across $gnomish. Stock changes often, and rare finds turn up now and then.",
            'restock_minutes' => 30,
        ]);

        // Stock: this region's uncommons (not commons, not staples), its flowers, and a rare guide.
        $uncommonSlugs = $regionTiers[$code]['uncommon'] ?? [];
        $flowerSlugs = $regionFlowers[$code] ?? [];
        $slugs = array_merge($uncommonSlugs, $flowerSlugs);
        foreach ($slugs as $s) {
            if (in_array($s, COMMON_CROPS, true)) continue;
            $item = q_one('SELECT id, base_price, rarity FROM items WHERE slug = ?', [$s . '-seed']);
            if (!$item) continue;
            $r = (int)$item['rarity'];
            $p = (int)$item['base_price'];
            db_insert('shop_stock', ['shop_id' => $shopId, 'item_id' => $item['id'],
                'price_min' => max(1, (int)floor($p * 0.8)), 'price_max' => (int)ceil($p * 1.3),
                'max_stock' => max(2, 14 - intdiv($r, 8)), 'restock_chance' => max(15, 100 - (int)($r * 0.8)),
                'current_stock' => 0, 'current_price' => $p]);
        }
        db_insert('shop_stock', ['shop_id' => $shopId, 'item_id' => $guideId, 'price_min' => 1500, 'price_max' => 2500,
            'max_stock' => 1, 'restock_chance' => 6, 'current_stock' => 0, 'current_price' => 1800]);

        // Staff: three shifts around the clock; after work they wander the market, then go home.
        $shifts = [[6, 14], [14, 22], [22, 6]];
        foreach ($shifts as [$s, $e]) {
            $name = $first[$i % count($first)] . ' ' . $last[($i * 5) % count($last)];
            $slug = slugify($name);
            if (q_val('SELECT 1 FROM npcs WHERE slug = ?', [$slug])) {
                $slug .= '-' . $rslug;
            }
            $npcId = db_insert('npcs', ['name' => $name, 'slug' => $slug, 'species' => $species[$i % count($species)],
                'personality' => $moods[$i % count($moods)], 'home_location_id' => $locId,
                'bio' => "Works at the $gnomish Seed Market and knows every seed by its first name."]);
            db_insert('npc_schedules', ['npc_id' => $npcId, 'location_id' => $locId, 'shop_id' => $shopId, 'activity' => 'working', 'start_hour' => $s, 'end_hour' => $e]);
            db_insert('npc_schedules', ['npc_id' => $npcId, 'location_id' => $locId, 'shop_id' => null, 'activity' => 'wandering', 'start_hour' => $e, 'end_hour' => ($e + 3) % 24]);
            db_insert('npc_schedules', ['npc_id' => $npcId, 'location_id' => $locId, 'shop_id' => null, 'activity' => 'resting', 'start_hour' => ($e + 3) % 24, 'end_hour' => $s]);
            $i++;
        }
        $made++;
    }
    return $made;
}

/** Almanac pages + milestones for reaching soil grades C, B, A and S. Adds only what's missing. */
function ensure_soil_content(array &$stats): void
{
    $pages = [
        'c' => ['Grade C soil', "One of your no-till beds reached grade C. Fungal threads are spreading and worms have moved in. Keep the mulch on!"],
        'b' => ['Grade B soil', "A grade B bed: dark, crumbly and alive. It holds water like a sponge and plants grow noticeably faster."],
        'a' => ['Grade A soil', "Grade A. Your bed is a thriving underground city of fungi, bacteria, worms and beetles."],
        's' => ['Grade S soil', "The rarest soil of all. Years of care in real-world gardens, earned here through steady upkeep. Your S bed sometimes turns up treasure."],
    ];
    foreach ($pages as $letter => [$title, $body]) {
        if (!q_val('SELECT 1 FROM encyclopedia_entries WHERE unlock_key = ?', ['soil:' . $letter])) {
            db_insert('encyclopedia_entries', ['chapter' => 'General', 'category' => 'Living Soil', 'title' => $title, 'body' => $body,
                'unlock_key' => 'soil:' . $letter, 'hint' => 'Raise a no-till bed to soil grade ' . strtoupper($letter) . '.', 'sort_order' => ord($letter)]);
            $stats['pages']++;
        }
    }
    $castings = (int)q_val("SELECT id FROM items WHERE slug = 'worm-castings'") ?: null;
    $loam = (int)q_val("SELECT id FROM items WHERE slug = 'rich-loam'") ?: null;
    $ms = [
        'c' => ['Living soil', 300, $castings, 5, null],
        'b' => ['Rich, crumbly earth', 800, $castings, 10, 'Soil Tender'],
        'a' => ['Underground city', 2000, $loam, 10, 'Soil Steward'],
        's' => ['Perfect soil', 5000, $loam, 20, 'Soil Sage'],
    ];
    foreach ($ms as $letter => [$name, $coins, $item, $qty, $title]) {
        if (!q_val('SELECT 1 FROM almanac_milestones WHERE unlock_key = ?', ['soil:' . $letter])) {
            db_insert('almanac_milestones', ['name' => $name, 'kind' => 'key', 'threshold' => 0, 'unlock_key' => 'soil:' . $letter,
                'reward_coins' => $coins, 'reward_item_id' => $item, 'reward_qty' => $qty, 'reward_title' => $title]);
            $stats['milestones']++;
        }
    }
}

/** v0.9.4: the tier a recipe slug belongs to when the data has none: feast- prefix = feast, else meal. */
function recipe_tier_default(string $slug): string
{
    return str_starts_with($slug, 'feast-') ? 'feast' : 'meal';
}

/** v0.9.4: the setting list "a,b,c" as three ints in snack, meal, feast order. */
function tier_setting(string $name, array $fallback): array
{
    $v = array_map('intval', array_map('trim', explode(',', (string)setting($name))));
    return ['snack' => $v[0] ?? $fallback[0], 'meal' => $v[1] ?? $fallback[1], 'feast' => $v[2] ?? $fallback[2]];
}

/** Dishes from includes/data/recipes.txt. Adds only recipes whose dish doesn't exist yet. v0.9.4: energy column is the real number; tier and cook minutes columns. */
function import_recipes(array &$stats): int
{
    $made = 0;
    require_once __DIR__ . '/garden_world.php';
    garden100_items();   // v1.1.0: Hen Egg (and the other garden items) must exist before recipes that use it are priced; adds only what is missing
    require_once __DIR__ . '/animals120.php';
    animals120_items();  // v1.2.0: Quail Egg, Goat Milk and the other animal items, for the same reason
    require_once __DIR__ . '/animals140.php';
    animals140_items();  // v1.4.0: Wing Scale, Snail Trail Glaze and the two decor items made from them
    $cookCost = tier_setting('cook_energy_tiers', [0, 1, 2]);
    $snackBatch = max(1, (int)setting('snack_batch_max'));
    foreach (catalog_lines('recipes.txt') as $r) {
        if (count($r) < 7) continue;
        [$slug, $name, $ingr, $buffs, $minutes, $energy, $desc] = $r;
        $tier = in_array($r[7] ?? '', ['snack', 'meal', 'feast', 'preserve'], true) ? $r[7] : recipe_tier_default($slug);
        $pre = $tier === 'preserve';   // v0.9.8: Pantry preserves: cook minutes = real minutes in the jar, column 10 = items per batch
        $cookMin = isset($r[8]) && $r[8] !== '' ? max(0, (int)$r[8]) : ['snack' => 3, 'meal' => 15, 'feast' => 45, 'preserve' => 1440][$tier];
        if (q_val('SELECT 1 FROM items WHERE slug = ?', [$slug])) continue;
        $temp = [];
        foreach (explode(',', $buffs) as $b) {
            [$stat, $n] = array_map('trim', explode(':', $b) + [1 => 0]);
            if ($stat !== '') $temp[$stat] = (int)$n;
        }
        if ($temp) $temp['minutes'] = (int)$minutes;   // v0.9.8: a plain jam has no buff at all
        $ing = [];
        foreach (explode(',', $ingr) as $pair) {
            [$s, $n] = array_map('trim', explode(':', $pair) + [1 => 1]);
            $ing[$s] = (int)$n;
        }
        $outQty = $pre ? max(1, (int)($r[9] ?? 3)) : 1;
        $fx = ['energy' => max(0, (int)$energy)];   // v0.9.4: no /5 any more
        if ($temp) $fx = ['temp' => $temp] + $fx;
        if ($pre) {
            // Needs every crop to exist; sells for more than the crops would, and more the longer it takes (1.3 + 0.5 x sqrt(days)), spread over the jars of a batch
            $value = 0;
            foreach ($ing as $s => $n) {
                $it = q_one('SELECT * FROM items WHERE slug = ?', [$s]);
                if (!$it) continue 2;
                require_once __DIR__ . '/world.php';
                $value += sell_price($it) * $n;
            }
            $mult = 1.3 + 0.5 * sqrt(max(1, $cookMin / 1440));
            $price = max(20, (int)ceil($value * $mult / $outQty / 0.6));
            $fx['preserve'] = 1;   // every townsfolk likes one as a gift (friends.php); it never spoils
        } else {
            $value = 0;
            foreach ($ing as $s => $n) {
                $value += (int)q_val('SELECT base_price FROM items WHERE slug = ?', [$s]) * $n;
            }
            $price = max(20, (int)round($value * 1.4));
        }
        $itemId = db_insert('items', ['name' => $name, 'slug' => $slug, 'category' => 'food', 'rarity' => 10,
            'base_price' => $price, 'description' => $desc, 'edible' => 1, 'effects' => json_encode($fx)]);
        db_insert('recipes', ['name' => $name, 'output_item_id' => $itemId, 'output_qty' => $outQty, 'slug' => $slug,
            'category' => $pre ? 'pantry' : 'cooking', 'energy' => $pre ? max(0, (int)setting('pantry_energy')) : $cookCost[$tier],
            'ingredients' => json_encode($ing), 'cook_minutes' => $cookMin,
            'tier' => $tier, 'batch_max' => $tier === 'snack' ? $snackBatch : 1]);
        $stats['items']++;
        $made++;
    }
    return $made;
}

/**
 * v0.9.4: the Food Scrap item (left over from eating raw food and, with a Compost Bin, from cooking). Not tradable. Safe to run again.
 */
function ensure_food_scrap(): int
{
    $id = (int)q_val("SELECT id FROM items WHERE slug = 'food-scrap'");
    if ($id) return $id;
    return db_insert('items', ['name' => 'Food Scrap', 'slug' => 'food-scrap', 'category' => 'supply', 'rarity' => 1, 'base_price' => 1,
        'description' => 'Peelings, cores and crumbs. Add them to a Compost Bin\'s heap, or craft 12 of them into Plain Compost.',
        'edible' => 0, 'effects' => null, 'tradable' => 0]);
}

/** v0.9.4: heavy produce leaves more scraps when eaten raw (slug => scraps). Everything else leaves 1. */
const HEAVY_SCRAPS = ['pumpkin' => 3, 'watermelon' => 3, 'jackfruit' => 3, 'breadfruit' => 3, 'melon' => 2, 'pineapple' => 2,
    'coconut' => 2, 'cabbage' => 2, 'cauliflower' => 2];

/**
 * v0.9.4: raw food gives a little energy: setting raw_energy_values "1,2" = everyday, filling (tubers, legumes and grains
 * that are edible raw). Herbs, spices, flowers and inedible things give none. Edible forage finds give the everyday amount.
 * Only touches items with no "energy" key yet (so values an admin set survive), and adds `scrap` for heavy produce.
 * Safe to run more than once. Returns how many items changed.
 */
function apply_raw_food_energy(): int
{
    $vals = array_map('intval', array_map('trim', explode(',', (string)setting('raw_energy_values'))));
    $everyday = max(0, $vals[0] ?? 1);
    $filling = max(0, $vals[1] ?? 2);
    $n = 0;
    $rows = q("SELECT i.id, i.slug, i.category, i.effects, p.kind FROM items i LEFT JOIN plants p ON p.produce_item_id = i.id
               WHERE i.edible = 1 AND i.category IN ('produce', 'forage')")->fetchAll();
    foreach ($rows as $it) {
        $fx = json_decode((string)$it['effects'], true);
        if (!is_array($fx)) $fx = [];
        $changed = false;
        if (!array_key_exists('energy', $fx)) {
            $e = $it['category'] === 'forage' ? $everyday : match ((string)$it['kind']) {
                'vegetable', 'fruit', 'tree', 'nut' => $everyday,
                'tuber', 'legume', 'grain' => $filling,
                default => 0,   // herbs, spices
            };
            if ($e > 0) { $fx['energy'] = $e; $changed = true; }
        }
        if (isset(HEAVY_SCRAPS[$it['slug']]) && !array_key_exists('scrap', $fx)) { $fx['scrap'] = HEAVY_SCRAPS[$it['slug']]; $changed = true; }
        if ($changed) { q('UPDATE items SET effects = ? WHERE id = ?', [json_encode($fx), $it['id']]); $n++; }
    }
    return $n;
}

/** v0.9.4: the dish energy the 46 original recipes had before the cooking rework (recipes.txt value / 5, rounded). A dish still at this number is moved to the new one; one an admin changed is left alone. */
const OLD_DISH_ENERGY = [
    'desert-sage-tea' => 1,
    'meadowsweet-tea' => 1,
    'smoked-trout' => 3,
    'cattail-fritters' => 3,
    'fiddlehead-fry' => 2,
    'grilled-sardines' => 2,
    'mesquite-flatbread' => 3,
    'mint-tea' => 1,
    'mushroom-toast' => 3,
    'wild-berry-jam' => 2,
    'crowberry-cordial' => 2,
    'sea-grape-sorbet' => 2,
    'tropical-fruit-bowl' => 3,
    'cornbread' => 3,
    'hot-cocoa' => 2,
    'peanut-toast' => 3,
    'pickled-radishes' => 1,
    'ramson-pesto' => 2,
    'samphire-salad' => 2,
    'sunflower-snack' => 1,
    'garden-salad' => 2,
    'mackerel-rice' => 3,
    'mussel-broth' => 4,
    'coconut-curry' => 5,
    'morel-risotto' => 5,
    'apple-crumble' => 3,
    'fiery-pickled-cabbage' => 2,
    'fishermans-stew' => 4,
    'green-pea-soup' => 3,
    'herb-flatbread' => 3,
    'potato-leek-soup' => 4,
    'rice-and-beans' => 5,
    'golden-carp-feast' => 6,
    'berry-tart' => 3,
    'carrot-cake' => 3,
    'chickpea-stew' => 4,
    'garden-vegetable-soup' => 4,
    'roasted-roots' => 4,
    'three-sisters-stew' => 5,
    'lentil-dal' => 4,
    'feast-orchard-crumble' => 5,
    'feast-forest-roast' => 6,
    'feast-riverside-bake' => 6,
    'feast-harvest-pie' => 6,
    'feast-berry-honey-cake' => 5,
    'feast-summer-table' => 6,
];

/**
 * v0.9.4 cooking migration (chunk A). Idempotent; admin-edited values survive:
 *  - Food Scrap item; raw food energy and heavy scraps (items with no energy key only)
 *  - each recipes.txt dish: tier, cook minutes, batch size, cook energy (only while cook_minutes is still 0), dish energy
 *    (only while it still equals the old import value), Pickled Radishes radish 4 -> 2 (only while still 4)
 *  - shop-bought copies get shop_food_energy_pct of the dish's energy
 */
function upgrade_094_cooking(): void
{
    ensure_food_scrap();
    apply_raw_food_energy();
    $cookCost = tier_setting('cook_energy_tiers', [0, 1, 2]);
    $snackBatch = max(1, (int)setting('snack_batch_max'));
    foreach (catalog_lines('recipes.txt') as $r) {
        if (count($r) < 7) continue;
        $slug = $r[0];
        $tier = in_array($r[7] ?? '', ['snack', 'meal', 'feast'], true) ? $r[7] : recipe_tier_default($slug);
        $cookMin = isset($r[8]) && $r[8] !== '' ? max(0, (int)$r[8]) : ['snack' => 3, 'meal' => 15, 'feast' => 45][$tier];
        $rec = q_one('SELECT id, output_item_id, cook_minutes, ingredients FROM recipes WHERE slug = ?', [$slug]);
        if (!$rec) continue;
        if ((int)$rec['cook_minutes'] === 0) {   // not upgraded yet (an admin who set minutes keeps the recipe's tier columns)
            q('UPDATE recipes SET tier = ?, cook_minutes = ?, batch_max = ?, energy = ? WHERE id = ?',
                [$tier, $cookMin, $tier === 'snack' ? $snackBatch : 1, $cookCost[$tier], $rec['id']]);
        }
        $item = q_one('SELECT id, effects FROM items WHERE id = ?', [$rec['output_item_id']]);
        $fx = $item ? json_decode((string)$item['effects'], true) : null;
        if (is_array($fx) && isset(OLD_DISH_ENERGY[$slug]) && (int)($fx['energy'] ?? -1) === OLD_DISH_ENERGY[$slug] && (int)$r[5] !== OLD_DISH_ENERGY[$slug]) {
            $fx['energy'] = max(0, (int)$r[5]);
            q('UPDATE items SET effects = ? WHERE id = ?', [json_encode($fx), $item['id']]);
        }
        if ($slug === 'pickled-radishes' && json_decode((string)$rec['ingredients'], true) === ['radish' => 4, 'dill' => 1]) {
            q('UPDATE recipes SET ingredients = ? WHERE id = ?', [json_encode(['radish' => 2, 'dill' => 1]), $rec['id']]);
        }
    }
    q("UPDATE recipes SET tier = 'feast' WHERE category = 'cooking' AND slug LIKE 'feast-%' AND tier = 'meal' AND cook_minutes = 0");
    require_once __DIR__ . '/world.php';
    upgrade_shop_food_energy();
}

/**
 * v0.9.4 cooking part 2 (pots, chunk C): the cook_pots table comes from schema.php (db_migrate); this clears the two dead
 * settings (kitchen_garden_level and town_bench_energy were never read) and makes sure the new defaults are there. Idempotent.
 */
function upgrade_094_pots(): void
{
    q("DELETE FROM settings WHERE name IN ('kitchen_garden_level', 'town_bench_energy')");
    setting('__reload__');
}

/**
 * v0.7.86: raw food gave no energy; v0.9.4: raw crops and forage give a little again (apply_raw_food_energy), so this now
 * only clears "energy" from flowers (which are never food). Effects left empty become NULL. Safe to run more than once.
 */
function strip_raw_food_energy(): void
{
    foreach (q("SELECT id, effects FROM items WHERE effects LIKE '%\"energy\"%'
                AND category = 'flower'")->fetchAll() as $it) {   // v0.9.4: produce and forage keep their raw energy; bought-* food too
        $fx = json_decode((string)$it['effects'], true);
        if (!is_array($fx) || !array_key_exists('energy', $fx)) continue;
        unset($fx['energy']);
        q('UPDATE items SET effects = ? WHERE id = ?', [$fx ? json_encode($fx) : null, $it['id']]);
    }
}
