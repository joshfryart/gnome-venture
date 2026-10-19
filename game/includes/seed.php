<?php
declare(strict_types=1);

require_once __DIR__ . '/catalog.php';
require_once __DIR__ . '/world.php';
require_once __DIR__ . '/tools.php';
require_once __DIR__ . '/gathering.php';

/** Starter content so the world isn't empty on day one. Everything here is editable in the admin panel. */
function seed_starter_content(): void
{
    set_setting('energy_scale', '2');   // a new world starts on the v0.7.23 energy scale
    $item = function (string $name, string $cat, int $price, int $rarity, string $desc, int $edible = 0, ?string $effects = null) {
        return db_insert('items', [
            'name' => $name, 'slug' => slugify($name), 'category' => $cat, 'base_price' => $price,
            'rarity' => $rarity, 'description' => $desc, 'edible' => $edible, 'effects' => $effects,
        ]);
    };

    // Tools, soil and mulch.
    $item('Broadfork', 'tool', 400, 15, 'Loosens no-till beds deeply without turning the soil over, so soil life survives.', 0, '{"tool":"broadfork"}');
    $item('Soil Test Kit', 'tool', 150, 5, 'Shows the exact fertility, soil life and moisture of every square.', 0, '{"tool":"soiltest"}');
    $item('Cardboard Sheet', 'supply', 5, 1, 'Smothers weeds and grass to start a no-till bed. Worms love it.');
    $item('Plain Compost', 'soil', 12, 1, 'Works into the soil over a day: fertility +15, soil life +3.', 0, '{"fertility":15,"life":3,"hours":24}');
    $item('Rich Loam', 'soil', 60, 12, 'Works into the soil over two days: fertility +30, soil life +5.', 0, '{"fertility":30,"life":5,"hours":48}');
    $item('Worm Castings', 'soil', 45, 10, 'Works into the soil over a day: fertility +10, soil life +12. Pure worm magic.', 0, '{"fertility":10,"life":12,"hours":24}');
    $item('Straw Mulch', 'mulch', 10, 1, 'Covers a bed for 6 days. Moisture +15, soil life +2.', 0, '{"mulch":144,"moisture":15,"life":2}');
    $item('Leaf Mould', 'mulch', 18, 4, 'Covers a bed for 5 days. Moisture +12, soil life +6, fertility +3. Crumbly rotted leaves.', 0, '{"mulch":120,"moisture":12,"life":6,"fertility":3}');
    $item('Garden Honey', 'food', 40, 8, 'Golden honey from your own beehive.', 1, '{"temp":{"luck":1,"charm":1,"minutes":180},"energy":2}');
    $item('Wood Chips', 'mulch', 30, 6, 'Covers a bed for 10 days. Moisture +25, soil life +8. Feeds the fungi in no-till beds.', 0, '{"mulch":240,"moisture":25,"life":8}');

    ensure_tools();   // garden tools (stocked at Twigg's once the shop exists, below)

    // All real-world regions, zones, crops and their Almanac pages
    import_catalog();
    $id = fn(string $slug) => (int)q_val('SELECT id FROM items WHERE slug = ?', [$slug]);

    $soup = $id('garden-vegetable-soup');

    // Mossbottom hub: a central market reachable from anywhere
    $loc = function (string $name, string $region, string $desc) {
        return db_insert('locations', ['name' => $name, 'slug' => slugify($name), 'region' => $region, 'description' => $desc]);
    };
    $market = $loc('Mossbottom Market', HUB_REGION, 'A bustling market under a canopy of giant ferns.');
    q("UPDATE locations SET kind = 'hub' WHERE id = ?", [$market]);
    $meadow = $loc('Whispering Meadow', 'Mossbottom', 'Tall grass that gossips when the wind blows.');
    $burrows = $loc('Rootling Burrows', 'Mossbottom', 'Cozy homes dug beneath an ancient oak.');

    $shop = function (string $name, int $locId, string $type, string $desc, int $restock) {
        return db_insert('shops', ['name' => $name, 'slug' => slugify($name), 'location_id' => $locId,
            'shop_type' => $type, 'description' => $desc, 'restock_minutes' => $restock]);
    };
    $seedShop = $shop("Twigg's Seed Emporium", $market, 'seeds', 'Everyday seeds, tools, compost and mulch. Reachable from anywhere in the world.', 20);
    $kitchen  = $shop('The Dewdrop Kitchen', $market, 'food', 'Warm meals, open all hours for hungry adventurers.', 30);

    // The hub sells supplies plus every everyday crop. Regional seeds are sold in regional markets.
    $hubItems = q('SELECT i.slug FROM plants p JOIN items i ON i.id = p.seed_item_id WHERE p.common = 1')->fetchAll(PDO::FETCH_COLUMN);
    $supplies = ['plain-compost', 'rich-loam', 'worm-castings', 'straw-mulch', 'leaf-mould', 'wood-chips', 'cardboard-sheet',
        'broadfork', 'soil-test-kit'];
    foreach (array_merge($supplies, $hubItems) as $s) {
        $iid = $id($s);
        if (!$iid) continue;
        $price = (int)q_val('SELECT base_price FROM items WHERE id = ?', [$iid]);
        db_insert('shop_stock', ['shop_id' => $seedShop, 'item_id' => $iid, 'price_min' => max(1, (int)floor($price * 0.9)),
            'price_max' => (int)ceil($price * 1.2), 'max_stock' => 20, 'restock_chance' => 90, 'current_stock' => 0, 'current_price' => $price]);
    }
    ensure_tools();   // now Twigg's exists: stock every tool there
    ensure_gatherables();
    require_once __DIR__ . '/nutrients.php';
    ensure_nutrients();   // NPK items, crop nutrients, NPK Almanac page
    require_once __DIR__ . '/games.php';
    ensure_games();       // earthworm item, worm bin recipe, Games page
    ensure_amend_minutes();   // v0.7.54: amendment times in minutes
    require_once __DIR__ . '/friends.php';
    ensure_friends();
    require_once __DIR__ . '/community.php';
    ensure_community();
    require_once __DIR__ . '/contests.php';
    ensure_contests();
    require_once __DIR__ . '/account.php';
    ensure_launch();      // privacy page
    require_once __DIR__ . '/events.php';
    ensure_events();      // random events
    require_once __DIR__ . '/crafting.php';
    ensure_crafts();
    require_once __DIR__ . '/hired_help.php';
    ensure_helpers();     // NPC helpers for hire
    require_once __DIR__ . '/jobs.php';
    ensure_jobs();        // Job Board templates
    require_once __DIR__ . '/trade.php';
    ensure_trade_content();      // cooking, tool and garden recipes + their Almanac pages
    require_once __DIR__ . '/town.php';
    ensure_towns();       // town squares, their places and local lore
    if ($soup) {
        db_insert('shop_stock', ['shop_id' => $kitchen, 'item_id' => $soup, 'price_min' => 40, 'price_max' => 55,
            'max_stock' => 8, 'restock_chance' => 70, 'current_stock' => 8, 'current_price' => 45]);
    }

    // NPCs: three shifts per shop so both are staffed 24 hours.
    $npc = function (string $name, string $species, string $pers, string $bio) use ($burrows) {
        return db_insert('npcs', ['name' => $name, 'slug' => slugify($name), 'species' => $species,
            'personality' => $pers, 'bio' => $bio, 'home_location_id' => $burrows]);
    };
    $sched = function (int $npcId, ?int $locId, ?int $shopId, string $act, int $start, int $end) {
        db_insert('npc_schedules', ['npc_id' => $npcId, 'location_id' => $locId, 'shop_id' => $shopId,
            'activity' => $act, 'start_hour' => $start, 'end_hour' => $end]);
    };
    $staff = [
        [$seedShop, 'Old Twigg', 'Stick insect', 'Grumpy', 'Founded the Emporium. Claims to have planted the first fern.'],
        [$seedShop, 'Pip Burrowell', 'Shrew', 'Eager', 'Twigg\'s apprentice. Talks fast, sorts slow.'],
        [$seedShop, 'Nocturna', 'Moth', 'Dreamy', 'Works the night shift. Knows which seeds glow in the dark.'],
        [$kitchen, 'Marigold Puddleby', 'Toad', 'Warm', 'Head cook. Has never once burned the soup.'],
        [$kitchen, 'Bram', 'Beetle', 'Shy', 'Washes dishes and secretly invents recipes.'],
        [$kitchen, 'Lantern Lou', 'Firefly', 'Chatty', 'Lights the kitchen at night and never stops talking.'],
    ];
    $shifts = [[6, 14], [14, 22], [22, 6]];
    foreach ($staff as $k => [$shopId, $name, $species, $pers, $bio]) {
        $nid = $npc($name, $species, $pers, $bio);
        [$s, $eh] = $shifts[$k % 3];
        $sched($nid, $market, $shopId, 'working', $s, $eh);
        $sched($nid, $meadow, null, 'wandering', $eh, ($eh + 3) % 24);
        $sched($nid, $burrows, null, 'resting', ($eh + 3) % 24, $s);
    }
    $wren = $npc('Wren Thimblewick', 'Wren', 'Curious', 'A travelling naturalist who trades stories for seeds from every corner of the world.');
    $sched($wren, $meadow, null, 'wandering', 8, 18);
    $sched($wren, $market, null, 'shopping', 18, 21);
    $sched($wren, $burrows, null, 'resting', 21, 8);

    // The Almanac's opening pages
    $entry = function (string $chapter, string $cat, string $title, string $body, string $key, string $hint, int $sort = 0) {
        db_insert('encyclopedia_entries', ['chapter' => $chapter, 'category' => $cat, 'title' => $title, 'body' => $body,
            'unlock_key' => $key, 'hint' => $hint, 'sort_order' => $sort]);
    };
    $entry('General', 'Getting started', 'Welcome to your Almanac',
        "Every gardener in the Hollow carries one of these.\nIt fills itself in as you grow crops, visit the fourteen regions of the Hollow, meet their creatures and find their landmarks.\n\n[b]Plants[/b] fill in the first time you harvest each crop.\n[b]Flowers[/b] fill in when you cut one.\n[b]Villages & landmarks[/b] fill in on your first visit.\n[b]Regions[/b] earn Bronze, Silver and Gold tiers as you grow their staples, uncommons and treasures.", 'start', '', 0);
    $entry('General', 'Getting started', 'Tending your plot',
        "1. Till a square with your trowel.\n2. Work in some compost. It feeds the soil slowly over about a day, and a square takes one batch at a time. Better soil = faster growth, and some crops need it.\n3. Plant a seed.\n4. Water it. Plants only grow while watered.\n5. Harvest when ready. You might save some seeds too.\n\n[b]Perennials[/b] (trees, bushes and some herbs) keep producing after each harvest.", 'start', '', 1);
    $entry('General', 'Getting started', 'Soil: till or no-till?',
        "Every square has [b]fertility[/b] (growth speed), [b]soil life[/b] (bigger harvests, more saved seeds) and [b]moisture[/b] (how long watering lasts).\n\n[b]Tilling[/b] is quick: till and plant the same day. But each till harms soil life, and you must till again after every harvest. Look after a tilled square and it earns soil care stars.\n[b]No-till[/b] takes longer to set up: cardboard, then mulch, then a wait. After that, soil life grows with every harvest. Tilling a no-till bed destroys everything it built.\n\nBeans add fertility. Hungry crops like corn and tomatoes use it up. Cover crops like clover are dug back in to feed the soil. Flowers next to crops bring pollinators.", 'start', '', 2);
    $entry('General', 'Getting started', 'Caring for a no-till bed',
        "No-till beds earn a [b]soil grade[/b] from F up through F+, D, D+, C, C+, B, B+, A, A+ to S. Higher grades grow faster, give bigger harvests and more seeds, hold water longer, and at A+ and S even turn up worm castings and rich loam.\n\nA bed climbs while it's well kept:\n• [b]Mulch[/b] slowly wears away. Straw lasts about 6 days, wood chips about 10. Top it up.\n• [b]Weeds[/b] creep in slowly, faster on bare soil. Pull them. Never till!\n• [b]Moisture[/b] dries out over days. Water the bed now and then, even when it's empty.\n• [b]Fertility[/b] gets used up by harvests. Top-dress with compost.\nLiving roots (anything growing) and digging in cover crops earn extra points. Neglect makes the grade slip slowly.\n\n[b]Checkpoints:[/b] once a bed reaches C, and again at A, it can't fall below that grade, unless you till it or leave it neglected for 14 days straight.", 'start', '', 3);
    $entry('General', 'Getting started', 'Knowing your plants',
        "You start knowing everyday garden crops plus the staple crops of your home region and its flowers. Gardening guides teach a whole region at once. Find them as rare stock in regional markets, and later on adventures and in the mines.", 'start', '', 3);
    $entry('General', 'Getting started', 'Knowledge & mastery',
        "Each harvest teaches you more about a plant. Reach full knowledge to master it. Masters will be able to raise saplings for other players.", 'start', '', 2);
    $entry('General', 'Getting started', 'Zones & landmarks',
        "Each of the fourteen regions has four [b]zones[/b]: a gentle starter zone next to the market, two medium zones, and a hard outer zone. Each zone holds a handful of villages and [b]landmarks[/b]: 🏕️ havens (safe rests and buffs), ✨ wonders (puzzles and events), 🕳️ delves (hard side paths) and 🐉 lairs (bosses with set levels).", 'start', '', 4);
    $entry('General', 'Places', 'Mossbottom Market', 'The heart of Mossbottom. Shops never close here.', 'start', '', 5);
    $entry('General', 'People', 'Old Twigg', 'Runs the Seed Emporium in the mornings. Do not mention pinecones.', 'npc:old-twigg', 'Visit the Seed Emporium in the morning.');

    // Site content
    db_insert('news', ['title' => 'The garden gates are open!', 'body' => "Welcome to the very first day of the Hollow.\nClaim your plot, plant your first seeds and start filling your Almanac with crops from the fourteen regions of the world.", 'published' => 1, 'created_at' => now()]);
    db_insert('pages', ['slug' => 'rules', 'title' => 'Rules', 'body' => "[h]Be kind[/h]\nNo harassment, no cheating, one account per person.\nBreaking rules can get you banned.\n\n[h]Seen something wrong?[/h]\nTap the 🚩 next to a name or note to report it. Reports are private, and a moderator will deal with it.", 'published' => 1, 'show_in_nav' => 1, 'updated_at' => now()]);

    require_once __DIR__ . '/yard.php';
    ensure_yards();       // yard decor and its shop (v0.7.32)
    upgrade_097_sinks();  // v0.9.7: Curio Cabinet, Dye Pot, Almanac page
    require_once __DIR__ . '/flowers.php';
    upgrade_099_flowers();   // v0.9.9: florists and the flower Almanac pages
    require_once __DIR__ . '/upgrade100.php';   // v1.0.0: the steps set their done-flags, so a fresh world shows nothing pending
    upgrade_100_run_step('social', true) or throw new RuntimeException('Install: upgrade step social failed (see data/error-log.txt)');    // v1.0.0 wave 3: Almanac pages, Opening Day dates, festival decor
    upgrade_100_run_step('clock', true) or throw new RuntimeException('Install: upgrade step clock failed (see data/error-log.txt)');     // v1.0.0: the Hollow clock's Almanac page and calendar start
    require_once __DIR__ . '/garden_world.php';
    upgrade_100_run_step('garden', true) or throw new RuntimeException('Install: upgrade step garden failed (see data/error-log.txt)');    // v1.0.0 wave 2a: crop seasons, pests, companions, garden animals, Almanac pages
    require_once __DIR__ . '/upgrade110.php';
    require_once __DIR__ . '/breeding110.php'; breeding110_import();   // v1.1.0: hybrids (needs the crops above)
    upgrade_110_run();    // v1.1.0: sets its done-flags on a fresh world (egg Almanac page; the cook setting has no row yet)
    require_once __DIR__ . '/upgrade120.php';
    upgrade_120_run();    // v1.2.0: more garden animals, player mentors (sets its done-flags on a fresh world)
    require_once __DIR__ . '/upgrade140.php';
    upgrade_140_run();    // v1.4.0: sets its done-flags on a fresh world
    require_once __DIR__ . '/upgrade163.php';
    upgrade_163_run();    // v1.6.3: sets its done-flags on a fresh world
    require_once __DIR__ . '/upgrade170.php'; upgrade_170_run();   // v1.7.0: garden reactions become guestbook stamps
    require_once __DIR__ . '/upgrade193.php'; upgrade_193_run();   // v1.9.3: sets its done-flag on a fresh world (the data files already carry the cond tags)
    // NPCs' daily routines around their towns, and the travellers (needs the NPCs above and the town places)
    require_once __DIR__ . '/npc_life.php';
    ensure_npc_lives();
    require_once __DIR__ . '/town_social.php';
    ensure_town_social();
    require_once __DIR__ . '/roads.php';
    ensure_roads();
    require_once __DIR__ . '/stops.php';
    upgrade_100_run_step('stops', true) or throw new RuntimeException('Install: upgrade step stops failed (see data/error-log.txt)');   // v1.0.0 wave 1: rest stop types, activities, villagers, passport sets
    require_once __DIR__ . '/landmarks.php';
    ensure_lair_bosses();
    require_once __DIR__ . '/progression.php';
    ensure_progression();   // region levels (v0.7.43)
    require_once __DIR__ . '/journey.php';
    ensure_journey();       // v0.7.65
    ensure_guide_price();
    require_once __DIR__ . '/calling_quests.php';
    ensure_calling_quests();   // v0.9.4
    require_once __DIR__ . '/trek_data.php';
    trek_import();   // v1.8.0: Treks
    require_once __DIR__ . '/almanac_notes.php';
    ensure_almanac_howto(true);   // v0.7.72
    ensure_shop_food();
    strip_raw_food_energy();   // v0.9.4: now flowers only (raw food gives energy again)
    ensure_food_scrap();       // v0.9.4
    apply_raw_food_energy();   // v0.9.4: raw crops and forage energy (1 everyday, 2 filling) and heavy scraps
    require_once __DIR__ . '/rebuild.php';
    require_once __DIR__ . '/climate.php';
    ensure_climates();         // v0.8.9: region climates
    ensure_ruins(true);        // v0.7.87: about 1 in 3 havens, wonders and delves start in ruins
    ensure_grow_times();
}
