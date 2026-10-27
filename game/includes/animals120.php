<?php
declare(strict_types=1);

/**
 * v1.2.0, "more garden animals". Self-contained module in the shape of breeding110.php.
 * Housed animals reuse the critter core (garden_critters.php) and are mostly DATA rows in data/critters.txt:
 *   Quail Coop      quail eat Food Scraps and leave Quail Eggs
 *   Silkworm Shelf  silkworms eat Mulberry Leaves and leave empty Silk Cocoons (peace silk: the moth has flown)
 *   Tortoise Run    a tortoise grazes leafy greens, very slowly sheds a Tortoise Scute, and makes the yard prettier
 * Neighbour visitors (same pattern as Biddy, one garden_visitors row per garden per kind per Hollow day):
 *   Clementine      the neighbour's goat trades Food Scraps for Goat Milk, sometimes Goat Hair
 *   Percy           the pigeon on the shed trades a few seeds for one seed of a crop from far away
 * Mulberry Leaves: every harvest of a mulberry tree gives a few (setting mulberry_leaves). No other source.
 * Cosy: nothing dies, leaves or is lost. Lazy: no cron.
 * Wiring: animals120_settings() is merged by garden100_settings(); items are made by animals120_items() (also called from import_recipes());
 * animals120_upgrade() does everything (idempotent) and is called by the upgrade step and by seed.php; do_harvest() calls animals120_on_harvest().
 */

require_once __DIR__ . '/garden_world.php';

/** The three new housed-animal buildings. */
const ANIMALS120_HOMES = ['quail_coop', 'silk_shelf', 'tortoise_run'];

function animals120_settings(): array
{
    $pct = fn(string $label, int $def, int $min = 0, int $max = 100) => ['label' => $label, 'type' => 'int', 'default' => (string)$def, 'min' => $min, 'max' => $max];
    return [
        'animals120_on'        => ['label' => 'Garden animals: the Quail Coop, Silkworm Shelf and Tortoise Run can be built', 'type' => 'bool', 'default' => '1'],
        'mulberry_leaves'      => ['label' => 'Silkworms: Mulberry Leaves one mulberry harvest gives', 'type' => 'int', 'default' => '3', 'min' => 0, 'max' => 20],
        'clementine_on'        => ['label' => 'Clementine: the neighbour’s goat leans over the fence', 'type' => 'bool', 'default' => '1'],
        'clementine_chance'    => $pct('Clementine: chance she visits a garden on a Hollow day (%; a lovely yard makes her likelier)', 30),
        'clementine_scraps_per_milk' => ['label' => 'Clementine: Food Scraps for one Goat Milk', 'type' => 'int', 'default' => '3', 'min' => 1, 'max' => 20],
        'clementine_max_scraps' => ['label' => 'Clementine: most Food Scraps she takes in one visit', 'type' => 'int', 'default' => '9', 'min' => 1, 'max' => 60],
        'clementine_hair_pct'  => $pct('Clementine: chance of a tuft of Goat Hair as well (%; friendlier after a few visits)', 20),
        'percy_on'             => ['label' => 'Percy: the pigeon lands on the shed (pigeon post)', 'type' => 'bool', 'default' => '1'],
        'percy_chance'         => $pct('Percy: chance he visits a garden on a Hollow day (%; a lovely yard makes him likelier)', 25),
        'percy_seeds'          => ['label' => 'Percy: seeds of one kind he wants for a parcel', 'type' => 'int', 'default' => '3', 'min' => 1, 'max' => 20],
    ];
}

/** True when a new home is switched off by the admin (the old animals_on switch is checked by the callers). */
function animals120_blocked(string $building): bool
{
    return in_array($building, ANIMALS120_HOMES, true) && setting('animals120_on') === '0';
}

/** Items this module adds: slug => [name, category, description, base price, decor details or null (type, w, h, icon, appeal)]. */
const ANIMALS120_ITEMS = [
    'mulberry-leaf'  => ['Mulberry Leaf', 'produce', 'A broad, soft leaf from a mulberry tree. Silkworms can eat nothing else.', 2, null],
    'quail-egg'      => ['Quail Egg', 'produce', 'A tiny speckled egg from a Quail Coop. Cooks into small, rich dishes.', 9, null],
    'silk-cocoon'    => ['Silk Cocoon', 'part', 'An empty cocoon, left behind once the moth has flown away. Peace silk: no worm harmed. Spin it into thread.', 18, null],
    'silk-thread'    => ['Silk Thread', 'part', 'Fine, glossy thread spun from empty cocoons. Crafters love it.', 30, null],
    'tortoise-scute' => ['Tortoise Scute', 'part', 'A plate of shell, shed by the tortoise as it grows. Hard, patterned and lucky.', 45, null],
    'goat-milk'      => ['Goat Milk', 'produce', 'A jug of creamy milk from Clementine the goat. Good in porridge, better as cheese.', 20, null],
    'goat-hair'      => ['Goat Hair', 'part', 'A tuft of long, coarse hair. Twists into strong rope.', 14, null],
    'silk-bunting'   => ['Silk Bunting', 'decor', 'A string of tiny silk flags in soft colours.', 140, ['ornament', 1, 1, '🎏', 4]],
    'scute-wind-chime' => ['Scute Wind Chime', 'decor', 'Shed tortoise scutes on silk thread. They click softly together in the breeze.', 220, ['ornament', 1, 1, '🎐', 5]],
];

/** Make the items (only the missing ones; admins can edit them afterwards). Safe to call any time, even inside a transaction. */
function animals120_items(): void
{
    foreach (ANIMALS120_ITEMS as $slug => [$name, $cat, $desc, $price, $decor]) {
        if (q_val('SELECT 1 FROM items WHERE slug = ?', [$slug])) continue;
        $img = pixel_has('assets/img/animals/item-' . $slug . '.png') ? 'assets/img/animals/item-' . $slug . '.png' : (is_file(APP_ROOT . '/assets/img/animals/item-' . $slug . '.svg') ? 'assets/img/animals/item-' . $slug . '.svg' : null);
        $fx = null;
        if ($decor) {
            [$type, $w, $h, $icon, $appeal] = $decor;
            $fx = json_encode(['decor' => ['type' => $type, 'w' => $w, 'h' => $h, 'icon' => $icon, 'appeal' => $appeal, 'bonus' => '']], JSON_UNESCAPED_UNICODE);
            $desc .= ' Place it in your yard with the yard designer.';
        }
        db_insert('items', ['name' => $name, 'slug' => $slug, 'category' => $cat, 'description' => $desc, 'rarity' => $decor ? 5 : 1,
            'base_price' => $price, 'image' => $img, 'edible' => 0, 'effects' => $fx, 'tradable' => 1]);
    }
}

/** Almanac pages: title => [sort, category, unlock key, body, hint]. */
const ANIMALS120_ALMANAC = [
    'Quail Coop' => [45, 'Garden animals', 'critter:quail_coop', "🐦 A snug little coop for quail.\n\nWelcome a [b]quail[/b], name it, and keep its feeder topped up with [b]Food Scraps[/b]. A fed quail leaves a tiny speckled [b]Quail Egg[/b] about once a day. Eggs wait for you, a few at a time.\n\nQuail like [b]herbs and flowers[/b] to scuttle under, and are [b]delighted[/b] when there are plenty. A sulky one just works slower. Nothing ever dies or leaves.\n\nQuail eggs cook into toast, rice bowls, Scotch eggs and pickles (see Recipes).", 'Build a Quail Coop in your garden.'],
    'Silkworm Shelf' => [46, 'Garden animals', 'critter:silk_shelf', "🐛 A shelf of leafy trays for silkworms.\n\nSilkworms eat [b]Mulberry Leaves[/b] and nothing else. You get leaves by [b]harvesting a mulberry tree[/b] (a few leaves each time), or buy them at [b]Twigg's Seed Emporium[/b]. Fed silkworms spin cocoons, and you collect the [b]empty Silk Cocoons[/b] once the moth has flown away: peace silk, no worm harmed.\n\nCraft 3 cocoons into [b]Silk Thread[/b], and thread into a [b]Silk Bunting[/b] for the yard.\n\nSilkworms like herbs and a damp, shady corner.", 'Build a Silkworm Shelf in your garden.'],
    'Tortoise Run' => [47, 'Garden animals', 'critter:tortoise_run', "🐢 A grassy run with a sunny rock and a sheltered nook.\n\nWelcome a [b]tortoise[/b] and feed it leafy greens: lettuce, spinach, kale or bok choy. It is slow. Very slow. Every week or so it sheds a [b]Tortoise Scute[/b], a plate of shell, which is a real thing tortoises do and is quite lucky.\n\nScutes and silk thread make a [b]Scute Wind Chime[/b]. A tortoise also adds curb appeal: the yard looks lovelier just for having one ambling about.", 'Build a Tortoise Run in your garden.'],
    'Clementine the Goat' => [48, 'Garden animals', 'critter:clementine', "🐐 Clementine belongs to the neighbours, and is, to a gnome, [b]enormous[/b]. On some days she leans over the fence to see what you are doing, more often if your yard looks lovely.\n\nWhen she is there, offer her [b]Food Scraps[/b]: she trades them for jugs of [b]Goat Milk[/b] and, now and then, a tuft of [b]Goat Hair[/b] (good for rope). She is friendlier after a few visits. She trades once a day.\n\nMilk makes porridge, and cheese in a Pantry jar.", 'Watch the fence: Clementine visits on some days.'],
    'Percy the Pigeon' => [49, 'Garden animals', 'critter:percy', "🕊️ Percy delivers post for the whole Hollow, and on some days he lands on your shed for a rest.\n\nGive him a few [b]seeds[/b] (all of one kind) and he flies off and comes back with a little parcel: [b]one seed of a crop from far away[/b], something your gnome does not usually get to grow. He does one run a day.\n\nThe seeds you give are kept by the post, so spare ones are best.", 'Watch the shed: Percy visits on some days.'],
    // Item pages: give_item() opens "item:<slug>" the first time one arrives, and recipe discovery counts these as collected even after the item is used up.
    'Quail Eggs' => [50, 'Garden animals', 'item:quail-egg', "Tiny speckled eggs from your Quail Coop. Four make a good snack and eight make a good jar of pickles. Look in [b]Recipes[/b] once you have one.\n\nOnce you have held a quail egg, every quail egg dish counts it as found, even after you have cooked it.", 'Welcome a quail to a Quail Coop.'],
    'Goat Milk' => [51, 'Garden animals', 'item:goat-milk', "A jug of creamy milk from Clementine. It cooks into porridge and, set in a Pantry jar, becomes goat cheese. Look in [b]Recipes[/b].\n\nOnce you have held milk, every milk dish counts it as found.", 'Trade Clementine Food Scraps at the fence.'],
    'Goat Cheese' => [52, 'Garden animals', 'item:goat-cheese', "Soft, tangy rounds of cheese, made from goat milk in a Pantry jar. It goes into salads, stuffed peppers and tarts.", 'Set goat milk in a Pantry jar.'],
    'Goat Hair' => [53, 'Garden animals', 'item:goat-hair', "A tuft of coarse goat hair. Three twist into two lengths of rope (see Crafting, Building).", 'Clementine sometimes leaves a tuft.'],
    'Silk Cocoons' => [54, 'Garden animals', 'item:silk-cocoon', "An empty cocoon, left behind once the moth has flown. Three spin into Silk Thread (see Crafting, Yard & decor).", 'Silkworms leave them on the shelf.'],
    'Silk Thread' => [55, 'Garden animals', 'item:silk-thread', "Glossy thread spun from empty cocoons. Hang it as bunting, or tie scutes together into a wind chime.", 'Spin Silk Cocoons into thread.'],
    'Tortoise Scutes' => [56, 'Garden animals', 'item:tortoise-scute', "A plate of shell, shed by your tortoise as it grows. Three plus a length of silk thread make a Scute Wind Chime.", 'A tortoise sheds one now and then.'],
    'Mulberry Leaves' => [57, 'Garden animals', 'item:mulberry-leaf', "Silkworm food. Every harvest from a mulberry tree gives a few leaves along with the berries. Twigg's Seed Emporium sells them too.", 'Harvest a mulberry tree, or buy some at Twigg\'s.'],
];

/** Almanac pages (adds the missing ones; existing players who already hold an item get its page now). */
function animals120_pages(): void
{
    foreach (ANIMALS120_ALMANAC as $title => [$sort, $cat, $key, $body, $hint]) {
        if (q_val('SELECT 1 FROM encyclopedia_entries WHERE unlock_key = ?', [$key])) continue;
        $eid = db_insert('encyclopedia_entries', ['chapter' => 'General', 'category' => $cat, 'title' => $title, 'body' => $body, 'unlock_key' => $key, 'hint' => $hint, 'sort_order' => $sort]);
        if (str_starts_with($key, 'item:')) {   // anyone who already holds the item
            $iid = (int)q_val('SELECT id FROM items WHERE slug = ?', [substr($key, 5)]);
            if ($iid) foreach (q('SELECT user_id FROM user_items WHERE item_id = ?', [$iid])->fetchAll(PDO::FETCH_COLUMN) as $uid) {
                try { db_insert('user_encyclopedia', ['user_id' => $uid, 'entry_id' => $eid, 'unlocked_at' => now()]); } catch (PDOException $e) {}
            }
        } elseif (str_starts_with($key, 'critter:') && in_array(substr($key, 8), ANIMALS120_HOMES, true)) {   // anyone who already has the building (cannot yet, but be safe)
            foreach (q('SELECT DISTINCT p.user_id FROM garden_buildings gb JOIN plots p ON p.id = gb.plot_id WHERE gb.building = ?', [substr($key, 8)])->fetchAll(PDO::FETCH_COLUMN) as $uid) {
                try { db_insert('user_encyclopedia', ['user_id' => $uid, 'entry_id' => $eid, 'unlocked_at' => now()]); } catch (PDOException $e) {}
            }
        }
    }
}

/**
 * Everything 1.2.0 adds, idempotent (adds only what is missing, never touches rows an admin edited):
 * items, critter kinds, recipes (+ their Almanac pages) and the Almanac pages. Settings need no rows (defaults come from the list).
 * Call from the upgrade step and from seed.php; do not call inside a failing transaction you cannot roll back.
 */
function animals120_upgrade(): void
{
    require_once __DIR__ . '/garden_critters.php';
    animals120_items();
    garden100_seed_tables();   // critter kinds from data/critters.txt
    critter_kinds(true);
    require_once __DIR__ . '/crafting.php';
    ensure_crafts();           // recipes from recipes.txt + crafts.txt, and a page for each
    animals120_pages();
    animals120_shop();
    setting('__reload__');
}

/** v1.2.0: Twigg's Seed Emporium sells Mulberry Leaves, so a Silkworm Shelf works without a mulberry tree (harvesting one is still cheaper). Adds only. */
function animals120_shop(): void
{
    $shop = (int)q_val("SELECT id FROM shops WHERE slug = 'twigg-s-seed-emporium'");
    $iid = (int)q_val("SELECT id FROM items WHERE slug = 'mulberry-leaf'");
    if (!$shop || !$iid || q_val('SELECT 1 FROM shop_stock WHERE shop_id = ? AND item_id = ?', [$shop, $iid])) return;
    db_insert('shop_stock', ['shop_id' => $shop, 'item_id' => $iid, 'price_min' => 5, 'price_max' => 8,
        'max_stock' => 20, 'restock_chance' => 70, 'current_stock' => 0, 'current_price' => 6]);
}

// ----------------------------------------------------------------- Mulberry Leaves

/** Called from do_harvest() once a harvest is claimed: a mulberry gives silkworm food. Returns messages. */
function animals120_on_harvest(array $u, array $p): array
{
    if ((string)($p['slug'] ?? '') !== 'mulberry') return [];
    $n = max(0, (int)setting('mulberry_leaves'));
    $iid = (int)q_val("SELECT id FROM items WHERE slug = 'mulberry-leaf'");
    if ($n < 1 || !$iid) return [];
    give_item((int)$u['id'], $iid, $n);
    return ['🍃 The mulberry also gives ' . $n . ' × Mulberry Leaf' . ($n === 1 ? '' : 's') . ' (silkworm food).'];
}

// ----------------------------------------------------------------- Curb appeal

/** A tortoise ambling about makes a yard lovelier (a little more than its one point as a resident). */
function animals120_appeal(int $plotId): int
{
    return building_level($plotId, 'tortoise_run') > 0 && (int)q_val("SELECT COUNT(*) FROM garden_critters WHERE plot_id = ? AND building = 'tortoise_run'", [$plotId]) > 0 ? 2 : 0;
}

// ----------------------------------------------------------------- Neighbours: Clementine and Percy

/** kind => [name, icon, svg, the setting prefix]. Biddy (garden_critters.php) is the original of this pattern. */
const ANIMALS120_NEIGHBOURS = [
    'clementine' => ['Clementine', '🐐', 'goat.svg'],
    'percy'      => ['Percy', '🕊️', 'pigeon.svg'],
];

function neighbour120_here(array $plot, string $kind, ?string $date = null): bool
{
    if (!isset(ANIMALS120_NEIGHBOURS[$kind]) || setting($kind . '_on') === '0' || setting('animals_on') === '0') return false;
    $date ??= hollow_today();
    $chance = max(0, (int)setting($kind . '_chance')) + min(20, intdiv((int)($plot['appeal'] ?? 0), 5));
    return hollow_unit($kind . '|' . $plot['id'] . '|' . $date) * 100 < min(100, $chance);
}

function neighbour120_friendship(int $plotId, string $kind): int
{
    return (int)q_val('SELECT COUNT(*) FROM garden_visitors WHERE plot_id = ? AND kind = ? AND traded = 1', [$plotId, $kind]);
}

function neighbour120_traded_today(int $plotId, string $kind): bool
{
    return (bool)q_val('SELECT 1 FROM garden_visitors WHERE plot_id = ? AND kind = ? AND day = ? AND traded = 1', [$plotId, $kind, hollow_today()]);
}

/** Offer Food Scraps to Clementine at the fence: Goat Milk for each few scraps, and sometimes goat hair. Once a Hollow day. */
function clementine_trade(array $u, int $plotId, int $scraps): array
{
    $uid = (int)$u['id'];
    $plot = q_one('SELECT * FROM plots WHERE id = ? AND user_id = ?', [$plotId, $uid]);
    if (!$plot) return [false, 'That isn’t your garden.'];
    if (!neighbour120_here($plot, 'clementine')) return [false, 'Clementine isn’t at the fence today.'];
    $per = max(1, (int)setting('clementine_scraps_per_milk'));
    $scraps = max(0, min($scraps, max(1, (int)setting('clementine_max_scraps'))));
    $milk = intdiv($scraps, $per);
    if ($milk < 1) return [false, 'Clementine wants at least ' . $per . ' Food Scraps for a jug of milk.'];
    $take = $milk * $per;
    $scrapId = (int)q_val("SELECT id FROM items WHERE slug = 'food-scrap'");
    $milkId = (int)q_val("SELECT id FROM items WHERE slug = 'goat-milk'");
    $hairId = (int)q_val("SELECT id FROM items WHERE slug = 'goat-hair'");
    if (!$scrapId || !$milkId) return [false, 'Clementine looks confused.'];
    db()->beginTransaction();
    try {
        db_insert('garden_visitors', ['plot_id' => $plotId, 'kind' => 'clementine', 'day' => hollow_today(), 'traded' => 1, 'scraps' => $take]);
    } catch (PDOException $e) {
        db()->rollBack();
        return [false, 'Clementine has had her fill today. She’ll be back another day.'];
    }
    if (!give_item($uid, $scrapId, -$take)) { db()->rollBack(); return [false, 'You don’t have that many Food Scraps. Eating raw crops leaves them.']; }
    give_item($uid, $milkId, $milk);
    $friend = neighbour120_friendship($plotId, 'clementine');
    $msg = '🐐 Clementine munches happily and trades you ' . $milk . ' × Goat Milk for ' . $take . ' Food Scraps.';
    $hairBase = min(100, max(0, (int)setting('clementine_hair_pct')));
    // friendship raises the chance up to 80%, but never lowers a base the admin set higher (100 = always)
    if ($hairId && random_int(1, 100) <= min(max(80, $hairBase), $hairBase + 5 * max(0, $friend - 1))) {
        give_item($uid, $hairId, 1);
        $msg .= ' She leaves a tuft of hair on the fence too.';
    }
    db()->commit();
    unlock_entries($uid, 'critter:clementine');
    add_xp($uid, 2);
    return [true, $msg . ' +2 XP.'];
}

/** Seeds Percy has not brought this gnome before: staple and uncommon crops the gnome does not usually get. Returns plant rows (id, name, seed_item_id). */
function percy_candidates(array $u): array
{
    require_once __DIR__ . '/world.php';
    $known = known_plants($u, false);
    $rows = q("SELECT DISTINCT p.id, p.name, p.seed_item_id FROM plants p JOIN plant_regions pr ON pr.plant_id = p.id
               JOIN items s ON s.id = p.seed_item_id
               WHERE pr.tier IN ('staple', 'uncommon') AND p.kind <> 'cover' AND p.common = 0 ORDER BY p.id")->fetchAll();
    $far = array_values(array_filter($rows, fn($r) => !isset($known[(int)$r['id']])));
    return $far ?: [];
}

/** Give Percy a few seeds (all of one kind) for a parcel with one far-off seed. Once a Hollow day. */
function percy_trade(array $u, int $plotId, int $seedItemId): array
{
    $uid = (int)$u['id'];
    $plot = q_one('SELECT * FROM plots WHERE id = ? AND user_id = ?', [$plotId, $uid]);
    if (!$plot) return [false, 'That isn’t your garden.'];
    if (!neighbour120_here($plot, 'percy')) return [false, 'Percy isn’t on the shed today.'];
    $need = max(1, (int)setting('percy_seeds'));
    $seed = q_one("SELECT * FROM items WHERE id = ? AND category = 'seed'", [$seedItemId]);
    if (!$seed) return [false, 'Percy only takes seeds.'];
    $cands = percy_candidates($u);
    if (!$cands) return [false, 'Percy has nothing new to bring you. You already grow everything he knows!'];
    $pick = $cands[random_int(0, count($cands) - 1)];
    db()->beginTransaction();
    try {
        db_insert('garden_visitors', ['plot_id' => $plotId, 'kind' => 'percy', 'day' => hollow_today(), 'traded' => 1, 'scraps' => $need]);
    } catch (PDOException $e) {
        db()->rollBack();
        return [false, 'Percy has already made his run today. He’ll be back another day.'];
    }
    if (!give_item($uid, $seedItemId, -$need)) { db()->rollBack(); return [false, 'You need ' . $need . ' ' . $seed['name'] . ' for Percy.']; }
    give_item($uid, (int)$pick['seed_item_id'], 1);
    db()->commit();
    unlock_entries($uid, 'critter:percy');
    add_xp($uid, 2);
    $name = (string)q_val('SELECT name FROM items WHERE id = ?', [$pick['seed_item_id']]);
    return [true, '🕊️ Percy takes ' . $need . ' × ' . $seed['name'] . ', flies off, and returns with a parcel tied in twine: 1 × ' . $name . ', from far away. +2 XP.'];
}

/** The cards for Clementine and Percy under the yard, if they are about. Returns ['html' => ..., 'hint' => summary words, 'trade' => bool]. */
function animals120_neighbours(array $u, array $plot): array
{
    $out = ['html' => '', 'hint' => '', 'trade' => false];
    $plotId = (int)$plot['id'];
    $uid = (int)$u['id'];
    foreach (ANIMALS120_NEIGHBOURS as $kind => [$name, $icon, $svg]) {
        if (!neighbour120_here($plot, $kind)) continue;
        unlock_entries($uid, 'critter:' . $kind);
        $img = is_file(APP_ROOT . '/assets/img/animals/' . $svg) ? '<img class="cimg pix" src="' . e(art_url('assets/img/animals/' . preg_replace('/\.svg$/', '', $svg))) . '" alt="" width="48" height="48" loading="lazy">' : '<span class="oi">' . $icon . '</span>';
        $h = '<div class="biddy box neighbour ' . e($kind) . '">' . $img . '<div><b>' . e($name) . ($kind === 'clementine' ? ' is at the fence' : ' is on the shed') . '</b> <small class="muted">'
            . ($kind === 'clementine' ? 'the neighbour’s goat' : 'the post pigeon') . ' · ' . neighbour120_friendship($plotId, $kind) . ' trades so far</small><br>';
        $trade = false;
        if (neighbour120_traded_today($plotId, $kind)) {
            $h .= '<small>' . ($kind === 'clementine' ? 'She has had her fill today and wanders off, chewing. 🥛' : 'He has made his run for today and ruffles his feathers. 📮') . '</small></div></div>';
        } elseif ($kind === 'clementine') {
            $have = (int)q_val("SELECT ui.qty FROM user_items ui JOIN items i ON i.id = ui.item_id WHERE ui.user_id = ? AND i.slug = 'food-scrap'", [$uid]);
            $per = max(1, (int)setting('clementine_scraps_per_milk'));
            $max = min($have, max(1, (int)setting('clementine_max_scraps')));
            if ($max < $per) {
                $h .= '<small>She eyes your vegetable beds. Bring ' . $per . ' Food Scraps (left from eating raw crops) and she will trade a jug of milk. Milk makes porridge and cheese (see Recipes).</small></div></div>';
            } else {
                $trade = true;
                $h .= '<form method="post" class="inline">' . csrf_field() . '<input type="hidden" name="do" value="clementine"><label>Scraps <select name="scraps">';
                for ($n = $per; $n <= $max; $n += $per) $h .= '<option value="' . $n . '">' . $n . ' → ' . intdiv($n, $per) . ' milk</option>';
                $h .= '</select></label> <button class="btn small">🥛 Trade</button></form></div></div>';
            }
        } else {
            $need = max(1, (int)setting('percy_seeds'));
            $seeds = q("SELECT i.id, i.name, ui.qty FROM user_items ui JOIN items i ON i.id = ui.item_id WHERE ui.user_id = ? AND i.category = 'seed' AND ui.qty >= ? ORDER BY i.name LIMIT 60", [$uid, $need])->fetchAll();
            if (!$seeds) {
                $h .= '<small>He cocks his head. Give him ' . $need . ' seeds of one kind and he will fetch you one from far away.</small></div></div>';
            } else {
                $trade = true;
                $h .= '<form method="post" class="inline">' . csrf_field() . '<input type="hidden" name="do" value="percy"><label>Give ' . $need . ' <select name="seed">';
                foreach ($seeds as $s) $h .= '<option value="' . (int)$s['id'] . '">' . e($s['name']) . ' (' . (int)$s['qty'] . ')</option>';
                $h .= '</select></label> <button class="btn small">📮 Send</button></form></div></div>';
            }
        }
        $out['html'] .= $h;
        $out['hint'] .= ' · ' . $icon . ' ' . $name . ($trade ? ' wants a trade' : ' is here');
        $out['trade'] = $out['trade'] || $trade;
    }
    return $out;
}
