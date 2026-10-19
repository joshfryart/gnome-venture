<?php
declare(strict_types=1);

/**
 * v1.0.0 wave 2a, "the garden lives": the shared plumbing for seasons, weather, pests, companions and garden animals.
 * Settings, tables, data seeding, the one-off upgrade, Almanac pages and admin editors live here (loaded early, like social.php).
 * The rules are in
 *   garden_fx.php       crop seasons, weather in the garden, pests and companion planting
 *   garden_critters.php housed animals (Worm Farm, Ladybird Lodge, Frog Pond) and Biddy the neighbour's hen
 * Everything is lazy (worked out when a page is viewed, no cron) and cosy: nothing here ever kills a crop or an animal.
 */

/** Animal homes: building key => critter kinds that can live there. */
const GARDEN_CRITTER_HOMES = ['worm_farm' => ['worm'], 'ladybird_lodge' => ['ladybird'], 'frog_pond' => ['frog', 'tadpole'],
    'quail_coop' => ['quail'], 'silk_shelf' => ['silkworm'], 'tortoise_run' => ['tortoise'],
    'butterfly_bush' => ['butterfly'], 'snail_jar' => ['snail']];   // v1.2.0: more animals (animals120.php); v1.4.0: butterflies and snails (animals140.php)

function garden100_settings(): array
{
    $pct = fn(string $label, int $def, int $min = 0, int $max = 200) => ['label' => $label, 'type' => 'int', 'default' => (string)$def, 'min' => $min, 'max' => $max];
    return [
        'garden_fx_on'       => ['label' => 'Garden: seasons and weather change how crops grow (off = every day is the same)', 'type' => 'bool', 'default' => '1'],
        'season_in_speed'    => $pct('Seasons: crop growth speed in its season (% of normal; blank-season crops are always normal)', 110, 50, 300),
        'season_off_speed'   => $pct('Seasons: crop growth speed out of season (% of normal; never stops, greenhouses ignore it)', 70, 20, 200),
        'season_in_yield'    => $pct('Seasons: harvest bonus in season (% more, a whole extra now and then)', 10, 0, 100),
        'rain_waters'        => ['label' => 'Weather: rain and storms water the beds (counts as watering)', 'type' => 'bool', 'default' => '1'],
        'storm_slow_pct'     => $pct('Weather: storms slow tall crops by this % for the day (never kills; a hedge or greenhouse shelters them)', 30, 0, 90),
        'frost_slow_pct'     => $pct('Weather: frost slows tender crops by this % for the day (mulch or a greenhouse protects them)', 40, 0, 90),
        'frost_yield_pct'    => $pct('Weather: a frost-nipped crop gives this % fewer when harvested', 10, 0, 90),
        'heat_dry_pct'       => $pct('Weather: heat makes a watering last this % shorter (a rain barrel halves it)', 25, 0, 80),
        'wind_weed_pct'      => $pct('Weather: windy hours make weeds grow this % faster', 50, 0, 300),
        'pests_on'           => ['label' => 'Pests: aphids, slugs and snails, gnats and caterpillars visit the beds', 'type' => 'bool', 'default' => '1'],
        'pest_chance'        => $pct('Pests: base chance a growing bed gets a pest on a Hollow day (%, before season, weather and helpers)', 10, 0, 100),
        'pest_slow_pct'      => $pct('Pests: a bed with a pest grows this % slower until it is handled (never kills)', 35, 0, 90),
        'pest_max_pct'       => $pct('Pests: most growing beds that can have a pest at once (%)', 30, 5, 100),
        'pest_min_garden_level' => ['label' => 'Pests: garden level before pests can visit', 'type' => 'int', 'default' => '2', 'min' => 1, 'max' => 100],
        'pest_pick_energy'   => ['label' => 'Pests: energy to pick pests off a bed by hand', 'type' => 'int', 'default' => '1', 'min' => 0, 'max' => 10],
        'pest_clear_hours'   => ['label' => 'Pests: hours a pest stays before ladybirds, frogs and birds can clear it', 'type' => 'int', 'default' => '4', 'min' => 0, 'max' => 72],
        'companion_cut_pct'  => $pct('Companions: each helpful plant beside a bed cuts that pest’s chance by this % (up to two count)', 50, 0, 90),
        'pest_counter_cut_pct' => $pct('Pests: a Ladybird Lodge or Frog Pond with residents cuts its pest’s chance by this %', 80, 0, 100),
        'companion_yield_pct' => $pct('Companions: chance a helped crop gives +1 at harvest (%)', 25, 0, 100),
        'animals_on'         => ['label' => 'Garden animals: the animal homes can be built and the neighbours (Biddy, Clementine, Percy) visit', 'type' => 'bool', 'default' => '1'],
        'critter_meals_cap'  => ['label' => 'Garden animals: meals one animal can store in its feeder', 'type' => 'int', 'default' => '6', 'min' => 1, 'max' => 50],
        'critter_delight_pct' => $pct('Garden animals: chance a delighted animal leaves one extra gift when you collect (%)', 30, 0, 100),
        'critter_sleepy_pct' => $pct('Garden animals: how fast a sulking animal works (% of normal)', 50, 10, 100),
        'tadpole_days'       => ['label' => 'Frog Pond: days a fed tadpole takes to become a frog', 'type' => 'int', 'default' => '3', 'min' => 1, 'max' => 60],
        'biddy_on'           => ['label' => 'Biddy: the neighbour’s hen drops by the fence', 'type' => 'bool', 'default' => '1'],
        'biddy_chance'       => $pct('Biddy: chance she visits a garden on a Hollow day (%; a lovely yard makes her likelier)', 40, 0, 100),
        'biddy_scraps_per_egg' => ['label' => 'Biddy: Food Scraps for one Hen Egg', 'type' => 'int', 'default' => '2', 'min' => 1, 'max' => 20],
        'biddy_max_scraps'   => ['label' => 'Biddy: most Food Scraps she takes in one visit', 'type' => 'int', 'default' => '6', 'min' => 1, 'max' => 50],
        'biddy_feather_pct'  => $pct('Biddy: chance of a Hen Feather as well (%; friendlier after a few visits)', 20, 0, 100),
    ] + (function (): array { require_once __DIR__ . '/breeding110.php'; return breeding110_settings(); })()   // v1.1.0: crop breeding settings
      + (function (): array { require_once __DIR__ . '/animals120.php'; return animals120_settings(); })()   // v1.2.0: more garden animals
      + (function (): array { require_once __DIR__ . '/animals140.php'; return animals140_settings(); })();   // v1.4.0: Butterfly Bush, Snail Jar
}

/** [tables, indexes, columns] for schema_statements(). */
function garden100_schema(string $PK, string $ID, string $END): array
{
    $t = [];
    $t[] = "CREATE TABLE IF NOT EXISTS pest_kinds (
        id $PK,
        slug VARCHAR(30) NOT NULL UNIQUE,
        name VARCHAR(60) NOT NULL,
        icon VARCHAR(16) NOT NULL DEFAULT '🐛',
        season_w VARCHAR(40) NOT NULL DEFAULT '1,1,1,1',
        weather_w VARCHAR(200) NULL,
        kinds VARCHAR(200) NULL,
        counter VARCHAR(12) NULL,
        hint VARCHAR(255) NULL,
        about VARCHAR(255) NULL,
        active INT NOT NULL DEFAULT 1
    )$END";
    $t[] = "CREATE TABLE IF NOT EXISTS companion_plants (
        id $PK,
        plant_slug VARCHAR(60) NOT NULL UNIQUE,
        pests VARCHAR(120) NULL,
        helps VARCHAR(255) NULL,
        about VARCHAR(255) NULL
    )$END";
    $t[] = "CREATE TABLE IF NOT EXISTS critter_kinds (
        id $PK,
        slug VARCHAR(30) NOT NULL UNIQUE,
        name VARCHAR(60) NOT NULL,
        icon VARCHAR(16) NOT NULL DEFAULT '🐛',
        building VARCHAR(30) NOT NULL,
        foods VARCHAR(200) NULL,
        gift_slug VARCHAR(60) NULL,
        gift_hours INT NOT NULL DEFAULT 24,
        gift_cap INT NOT NULL DEFAULT 4,
        meals_per INT NOT NULL DEFAULT 0,
        homes VARCHAR(20) NOT NULL DEFAULT '2,3,4',
        likes VARCHAR(100) NULL,
        welcome_cost INT NOT NULL DEFAULT 100,
        names VARCHAR(255) NULL,
        about VARCHAR(500) NULL,
        quirk VARCHAR(255) NULL,
        active INT NOT NULL DEFAULT 1
    )$END";
    $t[] = "CREATE TABLE IF NOT EXISTS garden_critters (
        id $PK,
        plot_id $ID NOT NULL,
        building VARCHAR(30) NOT NULL,
        kind VARCHAR(30) NOT NULL,
        name VARCHAR(30) NOT NULL,
        mood INT NOT NULL DEFAULT 50,
        meals INT NOT NULL DEFAULT 0,
        fed_at DATETIME NULL,
        gift_at DATETIME NULL,
        held INT NOT NULL DEFAULT 0,
        born_at DATETIME NOT NULL,
        grows_at DATETIME NULL,
        gifts_made INT NOT NULL DEFAULT 0
    )$END";
    $t[] = "CREATE TABLE IF NOT EXISTS garden_visitors (
        id $PK,
        plot_id $ID NOT NULL,
        kind VARCHAR(20) NOT NULL,
        day VARCHAR(10) NOT NULL,
        traded INT NOT NULL DEFAULT 0,
        scraps INT NOT NULL DEFAULT 0,
        UNIQUE (plot_id, kind, day)
    )$END";
    $i = [
        'CREATE INDEX idx_critters_plot ON garden_critters (plot_id)',
    ];
    $c = [
        ['garden_critters', 'held', 'INT NOT NULL DEFAULT 0'],      // v1.0.0: gifts waiting (was `stored` in an early dev build; STORED is reserved in MySQL 8)
        ['plants', 'traits', 'VARCHAR(40) NULL'],                  // v1.0.0: tender (frost nips it), tall (storms lean it over)
        ['plot_tiles', 'pest', 'VARCHAR(30) NULL'],                // v1.0.0: the pest on this bed (pest_kinds.slug)
        ['plot_tiles', 'pest_at', 'DATETIME NULL'],
        ['plot_tiles', 'pest_check', 'VARCHAR(10) NULL'],          // the last Hollow day pests were rolled for this bed
        ['plot_tiles', 'nipped', 'INT NOT NULL DEFAULT 0'],        // v1.0.0: a frost nipped this crop (small yield dip)
    ];
    return [$t, $i, $c];
}

/** Rows of an includes/data/*.txt file: lines starting with # skipped, split on |. */
function garden_data_rows(string $file): array
{
    $out = [];
    $path = __DIR__ . '/data/' . $file;
    if (!is_file($path)) return $out;
    foreach (file($path, FILE_IGNORE_NEW_LINES) ?: [] as $line) {
        $line = trim($line);
        if ($line === '' || $line[0] === '#') continue;
        $out[] = array_map('trim', explode('|', $line));
    }
    return $out;
}

/** Item definitions this wave adds: slug => [name, category, description, base price]. */
const GARDEN_ITEMS = [
    'ladybird-charm' => ['Ladybird Charm', 'produce', 'A tiny enamelled-looking ladybird shell, left behind as a thank-you. Lucky to keep, lovely to give.', 70],
    'frogspawn'      => ['Frogspawn', 'produce', 'A jelly-clear clump of frog eggs. Pop it in a Frog Pond with a free home and it hatches into a tadpole.', 22],
    'hen-egg'        => ['Hen Egg', 'produce', 'A warm brown egg from Biddy, the neighbour’s hen. Cooks into all sorts of good things.', 14],
    'hen-feather'    => ['Hen Feather', 'part', 'A soft speckled feather. Crafters and decorators like them.', 12],
];

/** Make the items (only the ones that are missing). */
function garden100_items(): void
{
    foreach (GARDEN_ITEMS as $slug => [$name, $cat, $desc, $price]) {
        if (q_val('SELECT 1 FROM items WHERE slug = ?', [$slug])) continue;
        $img = is_file(APP_ROOT . '/assets/img/animals/item-' . $slug . '.svg') ? 'assets/img/animals/item-' . $slug . '.svg' : null;
        db_insert('items', ['name' => $name, 'slug' => $slug, 'category' => $cat, 'description' => $desc, 'rarity' => 1,
            'base_price' => $price, 'image' => $img, 'edible' => 0, 'effects' => null, 'tradable' => 1]);
    }
}

/** Fill the data tables from the data files (adds what is missing; never touches rows an admin edited). */
function garden100_seed_tables(): void
{
    foreach (garden_data_rows('pests.txt') as $r) {
        if (count($r) < 9 || q_val('SELECT 1 FROM pest_kinds WHERE slug = ?', [$r[0]])) continue;
        db_insert('pest_kinds', ['slug' => $r[0], 'name' => $r[1], 'icon' => $r[2], 'season_w' => $r[3], 'weather_w' => $r[4], 'kinds' => $r[5],
            'counter' => $r[6], 'hint' => $r[7], 'about' => $r[8], 'active' => 1]);
    }
    foreach (garden_data_rows('companions.txt') as $r) {
        if (count($r) < 4 || q_val('SELECT 1 FROM companion_plants WHERE plant_slug = ?', [$r[0]])) continue;
        db_insert('companion_plants', ['plant_slug' => $r[0], 'pests' => $r[1], 'helps' => $r[2], 'about' => $r[3]]);
    }
    foreach (garden_data_rows('critters.txt') as $r) {
        if (count($r) < 15 || q_val('SELECT 1 FROM critter_kinds WHERE slug = ?', [$r[0]])) continue;
        db_insert('critter_kinds', ['slug' => $r[0], 'name' => $r[1], 'icon' => $r[2], 'building' => $r[3], 'foods' => $r[4], 'gift_slug' => $r[5],
            'gift_hours' => max(1, (int)$r[6]), 'gift_cap' => max(0, (int)$r[7]), 'meals_per' => max(0, (int)$r[8]), 'homes' => $r[9], 'likes' => $r[10],
            'welcome_cost' => max(0, (int)$r[11]), 'names' => $r[12], 'about' => $r[13], 'quirk' => $r[14], 'active' => 1]);
    }
}

/** plants.seasons and plants.traits for every crop and flower that has none yet (a blank season = grows all year). */
function garden100_fill_seasons(): void
{
    $words = ['sp' => 'spring', 'su' => 'summer', 'au' => 'autumn', 'wi' => 'winter'];
    foreach (garden_data_rows('crop_seasons.txt') as $r) {
        if (count($r) < 3) continue;
        $p = q_one('SELECT id, seasons, traits FROM plants WHERE slug = ?', [$r[0]]);
        if (!$p) continue;
        if (trim((string)$p['seasons']) === '' && $r[1] !== '') q('UPDATE plants SET seasons = ? WHERE id = ?', [$r[1], $p['id']]);
        if ($p['traits'] === null) q('UPDATE plants SET traits = ? WHERE id = ?', [$r[2], $p['id']]);
    }
    foreach (garden_data_rows('flower_looks.txt') as $r) {   // flowers: they bloom when the looks file says; summer-only ones are tender
        if (count($r) < 4) continue;
        $p = q_one("SELECT id, seasons, traits FROM plants WHERE slug = ? AND kind = 'flower'", [$r[0]]);
        if (!$p) continue;
        $codes = array_filter(array_map('trim', explode(',', strtolower($r[3]))), fn($c) => isset($words[$c]));
        if (trim((string)$p['seasons']) === '' && $r[3] !== '*' && $codes) q('UPDATE plants SET seasons = ? WHERE id = ?', [implode(',', array_map(fn($c) => $words[$c], $codes)), $p['id']]);
        if ($p['traits'] === null) q('UPDATE plants SET traits = ? WHERE id = ?', [(in_array('su', $codes, true) && !array_intersect(['sp', 'wi', 'au'], $codes)) ? 'tender' : '', $p['id']]);
    }
}

const GARDEN100_ALMANAC = [
    'Seasons in the garden' => [36, 'Garden life', 'start', "🌱 Every crop has the seasons it likes best.\n\n[b]In season[/b] a crop grows a little faster and gives a little more. [b]Out of season[/b] it grows slower, but it [b]never stops[/b] and nothing is lost, so you can always plant what you like. Crops with no season (potatoes, onions, carrots, radishes, many tropical crops) grow the same all year.\n\nA [b]greenhouse[/b] ignores the seasons completely.\n\nLook for the small [b]in season[/b] and [b]off season[/b] chips on seed shelves and on your seed picker. Each season in the Hollow lasts a few real days (see the Seasons & weather page), so a quick radish now and a slow pumpkin later is a fine plan.\n\nGardeners say: plant lettuce, peas and spinach in spring and autumn; tomatoes, squash and corn for summer; garlic and kale to carry you through the cold."],
    'Weather in the garden' => [37, 'Garden life', 'start', "🌦️ The weather of your garden's own region touches your beds, gently.\n\n[b]Rain[/b] waters every bed for you (it counts as watering, so skip the can). [b]Storms[/b] do the same, but may flatten [b]tall crops[/b] (corn, sunflowers, hops...) so they grow slower that day. [b]Frost[/b] nips [b]tender crops[/b] (tomatoes, peppers, bananas...): they slow down and give a little less, unless the bed is [b]mulched[/b] or you have a [b]greenhouse[/b]. [b]Heat[/b] dries beds faster, so a watering lasts less time; a [b]rain barrel[/b] halves that. [b]Wind[/b] spreads weeds a bit. [b]Fog[/b] does very little, except that slugs love it.\n\nNothing here ever kills a crop. The worst case is a slow day. The garden page shows a one-line note about what today's weather is doing."],
    'Pests & companions' => [38, 'Garden life', 'start', "🐛 Four kinds of small visitors turn up on beds that are growing something: [b]aphids[/b], [b]slugs & snails[/b], [b]gnats[/b] and [b]caterpillars[/b]. They come with the right season and weather (slugs love rain and fog, aphids love a warm dry spell) and they slow a bed's growth until handled. They never destroy a harvest.\n\nHow to deal with them:\n- [b]Pick them off by hand[/b] (costs a little energy). Always works.\n- [b]Companion plants[/b] beside a bed keep pests away before they come: marigold, nasturtium, basil, garlic, onion, mint, thyme, rosemary, lavender, dill and coriander each help against certain pests. Some also help a neighbouring crop give an extra one.\n- [b]Helpers[/b]: ladybirds (Ladybird Lodge) eat aphids, frogs (Frog Pond) eat slugs, snails and gnats, and a birdbath brings birds that eat caterpillars. A hedge beside a bed helps a little too.\n- A hired helper who weeds will pick pests off as well.\n\nPests only visit beds you have been looking after: if you are away more than a day they pause."],
    'Worm Farm' => [39, 'Garden animals', 'critter:worm_farm', "🪱 A tray of red wigglers living in your garden.\n\nWelcome a [b]worm colony[/b], name it, and keep its feeder topped up with [b]Food Scraps[/b] (from eating raw crops). Every day or so a fed colony turns a few scraps into [b]Worm Castings[/b], rich stuff for your beds and the key to the best soil. Collect them whenever you like: they wait for you, up to a few at a time.\n\nA happy colony (fed lately, somewhere damp, herbs nearby) is [b]delighted[/b] and sometimes leaves an extra. A neglected one gets [b]sulky[/b] and works at half speed. Nothing ever dies or leaves.\n\nBuild it with the garden buildings panel. Upgrades add more homes and faster work."],
    'Ladybird Lodge' => [40, 'Garden animals', 'critter:ladybird_lodge', "🐞 A bug hotel for ladybirds.\n\nWelcome a ladybird, give it a name and it will patrol the beds within two squares: [b]aphids there are far less likely to come, and any that do get eaten[/b] a few hours later. Ladybirds find their own food but are happiest with [b]flowers and herbs[/b] growing in the garden. Now and then a pleased ladybird leaves a [b]Ladybird Charm[/b].\n\nThey never leave, even if the flowers do."],
    'Frog Pond' => [41, 'Garden animals', 'critter:frog_pond', "🐸 A small pond with a lily pad and a croak.\n\nWelcome a [b]frog[/b]. Frogs eat [b]slugs, snails and gnats[/b] on beds within three squares of the pond, keep it tidy, and make the yard prettier (curb appeal). They like [b]rain[/b], and in good weather they lay [b]Frogspawn[/b].\n\nThe tadpole chain: pop Frogspawn into the pond when you have a free home and it hatches into a [b]tadpole[/b]. Feed it a few Food Scraps and after a few days it grows into a frog. In the evening you might hear them sing."],
    'Biddy the Hen' => [42, 'Garden animals', 'critter:biddy', "🐔 Biddy lives next door and is, to a gnome, a [b]giant[/b]. She does not belong to anyone, but she does drop by the fence on some days, more often if your yard looks lovely.\n\nWhen she is there, offer her [b]Food Scraps[/b]: she trades them for fresh [b]Hen Eggs[/b] and, sometimes, a [b]Hen Feather[/b]. Come back often and she gets friendlier (more feathers). She trades once a day and is gone by evening.\n\nEggs are good in the kitchen; feathers are good for crafting and decorating."],
];

/**
 * v1.0.0 wave 2a migration (idempotent): the items, data tables, crop seasons and the Almanac pages.
 * Tables and columns come from schema.php. Settings need no rows (defaults come from the settings list).
 */
function upgrade_100_garden(): void
{
    try { q('SELECT `stored` FROM garden_critters LIMIT 1'); q('UPDATE garden_critters SET held = `stored` WHERE held = 0 AND `stored` > 0'); }
    catch (PDOException $e) { /* no old `stored` column: nothing to carry over (always so on MySQL 8) */ }
    garden100_items();
    garden100_seed_tables();
    garden100_fill_seasons();
    foreach (GARDEN100_ALMANAC as $title => [$sort, $cat, $key, $body]) {
        if (q_val("SELECT 1 FROM encyclopedia_entries WHERE chapter = 'General' AND title = ?", [$title])) continue;
        $hint = $key === 'start' ? '' : ($key === 'critter:biddy' ? 'Wait at the fence: Biddy visits on some days.' : 'Build it in your garden.');
        $eid = db_insert('encyclopedia_entries', ['chapter' => 'General', 'category' => $cat, 'title' => $title, 'body' => $body, 'unlock_key' => $key, 'hint' => $hint, 'sort_order' => $sort]);
        if ($key !== 'start') continue;
        foreach (q("SELECT DISTINCT ue.user_id FROM user_encyclopedia ue JOIN encyclopedia_entries e ON e.id = ue.entry_id WHERE e.unlock_key = 'start'")->fetchAll(PDO::FETCH_COLUMN) as $uid) {
            try { db_insert('user_encyclopedia', ['user_id' => $uid, 'entry_id' => $eid, 'unlocked_at' => now()]); } catch (PDOException $e) {}
        }
    }
    setting('__reload__');
}

/** Admin editors for the data this wave adds (merged into admin_resources()). */
function garden100_admin_resources(): array
{
    return [
        'pest_kinds' => [
            'table' => 'pest_kinds', 'label' => 'Garden pests', 'title_col' => 'name',
            'list' => ['id', 'icon', 'name', 'season_w', 'counter', 'active'], 'search' => ['name', 'slug'],
            'fields' => [
                'slug' => ['type' => 'slug', 'from' => 'name', 'help' => 'Short code. Don’t change it once players have pests of this kind.'],
                'name' => ['type' => 'text', 'required' => true, 'max' => 60],
                'icon' => ['type' => 'text', 'max' => 16, 'help' => 'An emoji'],
                'season_w' => ['type' => 'text', 'max' => 40, 'required' => true, 'label' => 'Season weights', 'help' => 'Four numbers: spring,summer,autumn,winter (0 = never, 1 = normal, 2 = twice as likely)'],
                'weather_w' => ['type' => 'text', 'max' => 200, 'label' => 'Weather weights', 'help' => 'e.g. rain:2,fog:1.7,sun:0.5 (unlisted weather = 1). Weathers: sun, cloud, rain, storm, frost, heat, wind, fog, snow'],
                'kinds' => ['type' => 'text', 'max' => 200, 'label' => 'Plant kinds it bothers', 'help' => 'Comma list: vegetable, fruit, flower, herb, legume, tuber, grain, tree, nut, spice'],
                'counter' => ['type' => 'select', 'options' => ['' => 'No animal counters it', 'lodge' => 'Ladybird Lodge', 'pond' => 'Frog Pond', 'birds' => 'Birdbath birds']],
                'hint' => ['type' => 'text', 'max' => 255, 'help' => 'What the player is told about handling it'],
                'about' => ['type' => 'text', 'max' => 255],
                'active' => ['type' => 'bool', 'default' => 1],
            ],
        ],
        'companion_plants' => [
            'table' => 'companion_plants', 'label' => 'Companion plants', 'title_col' => 'plant_slug',
            'list' => ['id', 'plant_slug', 'pests', 'helps'], 'search' => ['plant_slug'],
            'fields' => [
                'plant_slug' => ['type' => 'text', 'required' => true, 'max' => 60, 'label' => 'Plant', 'help' => 'The crop or flower slug, e.g. marigold'],
                'pests' => ['type' => 'text', 'max' => 120, 'label' => 'Pests it keeps off', 'help' => 'Comma list of pest codes (aphids, slugs, gnats, caterpillars)'],
                'helps' => ['type' => 'text', 'max' => 255, 'label' => 'Crops it helps', 'help' => 'Comma list of crop slugs that sometimes give +1 when it grows beside them'],
                'about' => ['type' => 'text', 'max' => 255],
            ],
        ],
        'critter_kinds' => [
            'table' => 'critter_kinds', 'label' => 'Garden animals', 'title_col' => 'name',
            'list' => ['id', 'icon', 'name', 'building', 'gift_slug', 'gift_hours', 'welcome_cost', 'active'], 'search' => ['name', 'slug'],
            'fields' => [
                'slug' => ['type' => 'slug', 'from' => 'name'],
                'name' => ['type' => 'text', 'required' => true, 'max' => 60],
                'icon' => ['type' => 'text', 'max' => 16],
                'building' => ['type' => 'select', 'options' => ['worm_farm' => 'Worm Farm', 'ladybird_lodge' => 'Ladybird Lodge', 'frog_pond' => 'Frog Pond', 'quail_coop' => 'Quail Coop', 'silk_shelf' => 'Silkworm Shelf', 'tortoise_run' => 'Tortoise Run', 'butterfly_bush' => 'Butterfly Bush', 'snail_jar' => 'Snail Jar'], 'required' => true],
                'foods' => ['type' => 'text', 'max' => 200, 'help' => 'Item slugs it eats, comma list. Blank = finds its own food.'],
                'gift_slug' => ['type' => 'text', 'max' => 60, 'label' => 'Gift item', 'help' => 'Item slug it leaves for you. Blank = none.'],
                'gift_hours' => ['type' => 'int', 'min' => 1, 'max' => 1000, 'label' => 'Hours per gift'],
                'gift_cap' => ['type' => 'int', 'min' => 0, 'max' => 100, 'label' => 'Most gifts waiting'],
                'meals_per' => ['type' => 'int', 'min' => 0, 'max' => 50, 'label' => 'Meals eaten per gift'],
                'homes' => ['type' => 'text', 'max' => 20, 'help' => 'Homes at building level 1,2,3 (three numbers)'],
                'likes' => ['type' => 'text', 'max' => 100, 'help' => 'Comma list: rain, flowers, herbs, damp, water'],
                'welcome_cost' => ['type' => 'int', 'min' => 0, 'label' => 'Petals to welcome one'],
                'names' => ['type' => 'text', 'max' => 255, 'label' => 'Name ideas', 'help' => 'Comma list'],
                'about' => ['type' => 'textarea'],
                'quirk' => ['type' => 'text', 'max' => 255],
                'active' => ['type' => 'bool', 'default' => 1],
            ],
        ],
    ];
}
