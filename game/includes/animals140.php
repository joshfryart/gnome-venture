<?php
declare(strict_types=1);

/**
 * v1.4.0, two more garden animals. Self-contained module in the shape of animals120.php; the animals are DATA rows in data/critters.txt.
 *   Butterfly Bush  (yard building, garden level 4) butterflies need no feeding. While one lives there, flowers growing within 2 squares of the bush
 *                   sometimes give +1 stem when harvested (setting butterfly_stem_pct, +5% a bush level), and the butterflies leave Wing Scales.
 *                   A Wing Scale Lantern (Crafting, Yard & decor) is made from Wing Scales and Silk Thread.
 *   Snail Jar       (garden level 3) picking slugs and snails off a bed by hand sometimes rescues one (setting snail_rescue_pct): it moves into the jar
 *                   (up to 3, named, renamed like any critter). Snails eat Food Scraps or lettuce and leave Snail Trail Glaze, used in a Glazed Garden Pot.
 * Cosy: nothing dies, leaves or is lost. Lazy: no cron.
 * Wiring: animals140_settings() is merged by garden100_settings(); items come from animals140_items() (also called from import_recipes());
 * animals140_upgrade() does everything (idempotent) and is called by upgrade_140_run() (upgrade140.php) and by seed.php.
 * Hooks: do_harvest() calls animals140_on_harvest(); pest_pick() calls animals140_on_pest_pick().
 */

require_once __DIR__ . '/garden_world.php';

const ANIMALS140_HOMES = ['butterfly_bush', 'snail_jar'];

function animals140_settings(): array
{
    $pct = fn(string $label, int $def, int $min = 0, int $max = 100) => ['label' => $label, 'type' => 'int', 'default' => (string)$def, 'min' => $min, 'max' => $max];
    return [
        'animals140_on'      => ['label' => 'Garden animals: the Butterfly Bush and Snail Jar can be built', 'type' => 'bool', 'default' => '1'],
        'butterfly_stem_pct' => $pct('Butterfly Bush: chance a flower within 2 squares gives +1 stem at harvest (%; +5 for each bush level above I)', 35),
        'snail_rescue_pct'   => $pct('Snail Jar: chance picking slugs and snails off a bed rescues a snail (%, while the jar has room)', 15),
    ];
}

/** True when a new home is switched off by the admin (the old animals_on switch is checked by the callers). */
function animals140_blocked(string $building): bool
{
    return in_array($building, ANIMALS140_HOMES, true) && setting('animals140_on') === '0';
}

/** Items this module adds: slug => [name, category, description, base price, decor details or null (type, w, h, icon, appeal)]. */
const ANIMALS140_ITEMS = [
    'wing-scale'        => ['Wing Scale', 'part', 'A tiny, shimmering scale, shed by a butterfly. Catches the light like stained glass.', 40, null],
    'snail-trail-glaze' => ['Snail Trail Glaze', 'part', 'A jar of silvery, shining slime from a rescued snail. Potters swear by it.', 32, null],
    'wing-scale-lantern' => ['Wing Scale Lantern', 'decor', 'A little lantern lined with butterfly wing scales. It throws soft, coloured light.', 160, ['light', 1, 1, '🏮', 4]],
    'glazed-garden-pot' => ['Glazed Garden Pot', 'decor', 'A clay pot with a glossy snail-trail glaze that shimmers in the rain.', 150, ['ornament', 1, 1, '🏺', 4]],
];

/** Make the items (only the missing ones; admins can edit them afterwards). Safe to call any time, even inside a transaction. */
function animals140_items(): void
{
    foreach (ANIMALS140_ITEMS as $slug => [$name, $cat, $desc, $price, $decor]) {
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
const ANIMALS140_ALMANAC = [
    'Butterfly Bush' => [58, 'Garden animals', 'critter:butterfly_bush', "🦋 A tall, purple-flowered bush that butterflies cannot resist.\n\nWelcome a [b]butterfly[/b] and give it a name. It needs [b]no feeding[/b]: it sips from the flowers in your garden and is [b]delighted[/b] when there are plenty. Nothing ever dies or leaves.\n\nWhile a butterfly lives there, [b]flowers growing within two squares of the bush[/b] sometimes give an [b]extra stem[/b] when you harvest them (a little more often at levels II and III). Place the bush near your flower beds in the yard designer.\n\nNow and then a pleased butterfly leaves a shimmering [b]Wing Scale[/b]. Three scales and a length of silk thread make a [b]Wing Scale Lantern[/b] (see Crafting, Yard & decor).", 'Build a Butterfly Bush in your garden.'],
    'Snail Jar' => [59, 'Garden animals', 'critter:snail_jar', "🐌 A big glass jar with damp soil, a few leaves and a very slow view.\n\nSnails are not bought. When you [b]pick slugs and snails off a bed by hand[/b], now and then one is [b]rescued[/b] and moves into the jar instead (up to three). Give it a name if you like.\n\nSnails nibble [b]Food Scraps or lettuce[/b] and leave a silvery [b]Snail Trail Glaze[/b] about every two days. Two glazes and some river clay make a [b]Glazed Garden Pot[/b] (see Crafting, Yard & decor).\n\nThey like damp weather and herbs. Nothing ever dies or leaves, and nobody is sent back to the beds.", 'Build a Snail Jar, then pick slugs and snails off your beds.'],
    'Wing Scales' => [60, 'Garden animals', 'item:wing-scale', "A tiny shimmering scale left by a butterfly. Three of them and a length of Silk Thread make a Wing Scale Lantern (see Crafting, Yard & decor).", 'A butterfly leaves one now and then.'],
    'Snail Trail Glaze' => [61, 'Garden animals', 'item:snail-trail-glaze', "A jar of silvery glaze from a rescued snail. Two glazes and two River Clay make a Glazed Garden Pot (see Crafting, Yard & decor).", 'Rescued snails leave it in the jar.'],
];

/** Almanac pages (adds the missing ones; existing players who already hold an item or the building get its page now). */
function animals140_pages(): void
{
    foreach (ANIMALS140_ALMANAC as $title => [$sort, $cat, $key, $body, $hint]) {
        if (q_val('SELECT 1 FROM encyclopedia_entries WHERE unlock_key = ?', [$key])) continue;
        $eid = db_insert('encyclopedia_entries', ['chapter' => 'General', 'category' => $cat, 'title' => $title, 'body' => $body, 'unlock_key' => $key, 'hint' => $hint, 'sort_order' => $sort]);
        if (str_starts_with($key, 'item:')) {
            $iid = (int)q_val('SELECT id FROM items WHERE slug = ?', [substr($key, 5)]);
            if ($iid) foreach (q('SELECT user_id FROM user_items WHERE item_id = ?', [$iid])->fetchAll(PDO::FETCH_COLUMN) as $uid) {
                try { db_insert('user_encyclopedia', ['user_id' => $uid, 'entry_id' => $eid, 'unlocked_at' => now()]); } catch (PDOException $e) {}
            }
        } elseif (str_starts_with($key, 'critter:') && in_array(substr($key, 8), ANIMALS140_HOMES, true)) {
            foreach (q('SELECT DISTINCT p.user_id FROM garden_buildings gb JOIN plots p ON p.id = gb.plot_id WHERE gb.building = ?', [substr($key, 8)])->fetchAll(PDO::FETCH_COLUMN) as $uid) {
                try { db_insert('user_encyclopedia', ['user_id' => $uid, 'entry_id' => $eid, 'unlocked_at' => now()]); } catch (PDOException $e) {}
            }
        }
    }
}

/**
 * Everything 1.4.0 adds for the garden animals, idempotent (adds only what is missing, never touches rows an admin edited):
 * items, critter kinds, the two crafts (+ their Almanac pages) and the Almanac pages. Settings need no rows (defaults come from the list).
 * Call from upgrade_140_run() and from seed.php; do not call inside a failing transaction you cannot roll back.
 */
function animals140_upgrade(): void
{
    require_once __DIR__ . '/garden_critters.php';
    animals140_items();
    garden100_seed_tables();   // critter kinds from data/critters.txt
    critter_kinds(true);
    require_once __DIR__ . '/crafting.php';
    ensure_crafts();           // recipes from recipes.txt + crafts.txt, and a page for each
    animals140_pages();
    setting('__reload__');
}

// ----------------------------------------------------------------- Butterfly Bush: flowers nearby

/** Chance (percent) a flower bed beside a lived-in Butterfly Bush gives +1 stem: base setting, +5 a bush level above I. 0 = no effect for this bed. */
function animals140_stem_chance(array $t): int
{
    $plotId = (int)($t['plot_id'] ?? 0);
    if (!$plotId || setting('animals_on') === '0' || setting('animals140_on') === '0') return 0;
    if (!building_level($plotId, 'butterfly_bush') || (int)q_val("SELECT COUNT(*) FROM garden_critters WHERE plot_id = ? AND building = 'butterfly_bush'", [$plotId]) < 1) return 0;
    require_once __DIR__ . '/yard.php';
    if (!isset(yard_tile_bonuses($t)['bush'])) return 0;
    return min(100, max(0, (int)setting('butterfly_stem_pct')) + 5 * (building_level($plotId, 'butterfly_bush') - 1));
}

/** Called from do_harvest() once the crop is given: a flower within 2 squares of a lived-in Butterfly Bush may give one more stem. Returns messages. */
function animals140_on_harvest(array $u, array $t, array $p): array
{
    if ((string)($p['kind'] ?? '') !== 'flower' || empty($p['produce_item_id'])) return [];
    $chance = animals140_stem_chance($t);
    if ($chance < 1 || random_int(1, 100) > $chance) return [];
    give_item((int)$u['id'], (int)$p['produce_item_id'], 1);
    return ['🦋 A butterfly flutters over the ' . strtolower((string)$p['name']) . ': +1 stem.'];
}

// ----------------------------------------------------------------- Snail Jar: rescued snails

/** Called from pest_pick() after the pest is taken off a bed by hand. Slugs and snails may mean a rescue. Returns an extra message ('' = none). */
function animals140_on_pest_pick(int $uid, int $plotId, string $pest): string
{
    if ($pest !== 'slugs' || setting('animals_on') === '0' || setting('animals140_on') === '0') return '';
    if (!$plotId || !building_level($plotId, 'snail_jar')) return '';
    $k = critter_kinds()['snail'] ?? null;
    if (!$k) return '';
    $pct = max(0, (int)setting('snail_rescue_pct'));
    if ($pct < 1 || random_int(1, 100) > $pct) return '';
    $homes = critter_homes($plotId, 'snail_jar');
    if ((int)q_val("SELECT COUNT(*) FROM garden_critters WHERE plot_id = ? AND building = 'snail_jar'", [$plotId]) >= $homes) {
        return ' 🐌 One little snail looks up hopefully, but the Snail Jar is full. It trundles off to the hedge.';
    }
    $name = critter_default_name($k, $plotId);
    $id = db_insert('garden_critters', ['plot_id' => $plotId, 'building' => 'snail_jar', 'kind' => 'snail', 'name' => $name, 'mood' => 50, 'meals' => 0,
        'fed_at' => null, 'gift_at' => now(), 'held' => 0, 'born_at' => now(), 'grows_at' => null, 'gifts_made' => 0]);
    if ((int)q_val("SELECT COUNT(*) FROM garden_critters WHERE plot_id = ? AND building = 'snail_jar'", [$plotId]) > $homes) {   // two quick picks: keep to the homes
        q('DELETE FROM garden_critters WHERE id = ?', [$id]);
        critter_forget();
        return '';
    }
    critter_forget();
    unlock_entries($uid, 'critter:snail_jar');
    return ' 🐌 One snail is so charming you rescue it: ' . $name . ' moves into the Snail Jar!';
}
