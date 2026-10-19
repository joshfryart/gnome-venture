<?php
declare(strict_types=1);

/**
 * Garden tools. No equipping: the best tool of each type in the satchel is used.
 *
 * Tiers: 1 Worn, 2 Sturdy, 3 Fine, 4 Masterwork.
 *  - Reach: tier 1 = one square, tier 2 = three squares in a row, tier 3+ = the whole row.
 *  - Energy: no tier lowers the cost. Each use has a 20/30/50% chance (Sturdy/Fine/Masterwork) to cost no energy (tool_free_chance). v0.7.85
 *  - Wear (v0.7.86): tools wear out with use and break. Gathering tools, the walking staff and the lantern wear by uses
 *    (gather_tool_uses); garden tools by days of use, one day per Hollow day they are used (garden_tool_days). A broken
 *    tool becomes a Broken copy that is mended in the Satchel (tool_mend_cost), or at a Tool Shed once a day for free.
 *    The Glowcap Lantern and Worn garden tools never wear out. See tool_use(), mend_tool() and tool_trade_block().
 * Some jobs can be done by hand (tier 0, one square). Tilling and watering need a tool.
 */

const TOOL_TIERS = [1 => 'Worn', 2 => 'Sturdy', 3 => 'Fine', 4 => 'Masterwork'];

/** type => [label, icon, what it's for, can be done by hand, reaches several squares] */
const TOOL_TYPES = [
    'till'      => ['Tilling', '⛏️', 'Breaks up wild ground so you can plant.', false, true],
    'water'     => ['Watering', '💧', 'Waters plants and no-till beds.', false, true],
    'plant'     => ['Planting', '🌱', 'Sows seeds.', true, true],
    'spread'    => ['Spreading', '🪣', 'Works in compost and spreads mulch.', true, true],
    'weed'      => ['Weeding', '🌿', 'Pulls weeds from no-till beds.', true, true],
    'harvest'   => ['Harvesting', '🧺', 'Gathers ripe crops.', true, true],
    'prune'     => ['Pruning', '✂️', 'Coaxes extra harvest from perennials and flowers.', true, false],
    'broadfork' => ['Broadfork', '🔱', 'Loosens no-till beds without hurting soil life.', false, false],
    'soiltest'  => ['Soil testing', '🧪', 'Shows exact soil numbers.', false, false],
    // Gathering tools: used on adventures. Tier 1 finds common things, 2 uncommon, 3 rare.
    'forage'    => ['Foraging', '🔪', 'Gathers mushrooms, berries, herbs and sap on adventures.', false, false],
    'pick'      => ['Rock picking', '🪨', 'Gathers stones, clay and crystals on adventures.', false, false],
    'net'       => ['Bug catching', '🦋', 'Gathers shed shells, wings and scales on adventures.', false, false],
    'bucket'    => ['Tide pooling', '🐚', 'Gathers shells, seaweed and salt on coasts and islands.', false, false],
    'axe'       => ['Logging', '🪓', 'Chops logs and gathers bark and wood on adventures.', false, false],   // v0.7.81
    'rod'       => ['Fishing', '🎣', 'Catches fish in coasts, wetlands, lakes and rivers on adventures.', false, false],   // v0.7.81
    'basket'    => ['Carrying', '👜', 'Lets you carry home more of each find.', false, false],
    // Adventure gear (v0.7.30)
    'staff'     => ['Walking', '🦯', 'Makes walks along the mycelium lighter on your feet.', false, false],
    'lantern'   => ['Lantern', '🏮', 'Lights the way in delves.', false, false],
];

/** Gathering tool types (adventures), as opposed to garden tools. */
const GATHER_TOOLS = ['forage', 'pick', 'net', 'bucket', 'axe', 'rod', 'basket', 'staff', 'lantern'];   // axe, rod: v0.7.81

/** Which tool type each garden action uses. */
const ACTION_TOOL = ['till' => 'till', 'water' => 'water', 'plant' => 'plant', 'soil' => 'spread', 'mulch' => 'spread',
    'weed' => 'weed', 'harvest' => 'harvest'];

/** [type, tier, name, price, rarity, flavour]. Tier 4 is rare shop stock, or crafted at a Tool Shed. */
const TOOL_ITEMS = [
    ['till', 1, 'Worn Trowel', 25, 1, 'Has seen better days.'],
    ['till', 2, 'Garden Hoe', 250, 8, 'A long handle saves your back.'],
    ['till', 3, 'Steel Spade', 1200, 25, 'Bites through sod like butter.'],
    ['till', 4, 'Masterwork Wheel Hoe', 6000, 70, 'A gnome-forged wheel hoe that rolls down a whole row.'],
    ['water', 1, 'Tin Watering Can', 30, 1, 'Holds just enough.'],
    ['water', 2, 'Copper Watering Can', 300, 10, 'A wide rose that showers three plants at once.'],
    ['water', 3, 'Sprinkler Can', 1400, 25, 'Long-spouted and generous.'],
    ['water', 4, 'Masterwork Rain Wand', 6500, 70, 'A hollow reed charmed by the mist-gnomes of Mistmoor.'],
    ['plant', 1, 'Wooden Dibber', 40, 2, 'Pokes the perfect seed hole.'],
    ['plant', 2, 'Seed Scoop', 280, 10, 'Drops seeds in neat little threes.'],
    ['plant', 3, 'Seed Drill', 1300, 25, 'Sows a straight row while you walk.'],
    ['plant', 4, 'Masterwork Gnome Seeder', 6000, 70, 'Clicks and whirs and never misses a spot.'],
    ['spread', 1, 'Compost Scoop', 40, 2, 'A dented scoop, just right for a square.'],
    ['spread', 2, 'Garden Fork', 300, 10, 'Tosses compost and mulch across three squares.'],
    ['spread', 3, 'Wheelbarrow', 1500, 25, 'Carries enough for a whole row.'],
    ['spread', 4, 'Masterwork Barrow', 7000, 70, 'Rolls itself, mostly.'],
    ['weed', 1, 'Hand Fork', 35, 2, 'Little tines for little weeds.'],
    ['weed', 2, 'Hori-hori', 260, 10, 'A soil knife that roots out the stubborn ones.'],
    ['weed', 3, 'Stirrup Hoe', 1200, 25, 'Skims weeds off a whole row.'],
    ['weed', 4, 'Masterwork Stirrup Hoe', 5500, 70, 'Weeds seem to leave before it arrives.'],
    ['harvest', 1, 'Woven Basket', 35, 2, 'Smells faintly of strawberries.'],
    ['harvest', 2, 'Harvest Trug', 280, 10, 'A shallow wooden trug for three squares at a time.'],
    ['harvest', 3, 'Harvest Sack', 1200, 25, 'Big enough for a whole row.'],
    ['harvest', 4, 'Masterwork Harvest Cart', 6000, 70, 'Never tips over, even on cobbles.'],
    ['prune', 1, 'Garden Snips', 60, 3, 'Small but sharp.'],
    ['prune', 2, 'Pruning Shears', 350, 10, 'Clean cuts heal fast.'],
    ['prune', 3, 'Fine Secateurs', 1500, 25, 'Balanced like a dancer.'],
    ['prune', 4, 'Masterwork Secateurs', 7000, 70, 'Plants seem to grow back out of gratitude.'],
    ['forage', 1, 'Foraging Knife', 60, 3, 'A small curved blade with a brush on the handle for mushrooms.'],
    ['forage', 2, 'Hooked Forager’s Knife', 420, 12, 'Reaches the high berries and the tricky stems.'],
    ['forage', 3, 'Fine Foraging Knife', 1600, 28, 'Finds the rare things other gnomes walk past.'],
    ['pick', 1, 'Rock Pick', 70, 3, 'A light hammer with a pointed end.'],
    ['pick', 2, 'Prospector’s Pick', 450, 12, 'Splits stones cleanly along their seams.'],
    ['pick', 3, 'Fine Rock Hammer', 1700, 28, 'Rings like a bell when it finds a geode.'],
    ['net', 1, 'Bug Net', 50, 3, 'For collecting what insects leave behind. Bugs are always let go.'],
    ['net', 2, 'Fine-mesh Net', 380, 12, 'Catches even the smallest shed wing.'],
    ['net', 3, 'Silk Net', 1500, 28, 'So soft the moths don’t mind it.'],
    ['bucket', 1, 'Tide Bucket', 45, 3, 'A dented bucket for rock pools.'],
    ['bucket', 2, 'Tide Pail and Scoop', 350, 12, 'Sifts sand and scoops shells.'],
    ['bucket', 3, 'Diver’s Creel', 1500, 28, 'A woven creel for the deeper pools.'],
    // v0.7.81: logging and fishing
    ['axe', 1, 'Hatchet', 70, 3, 'A short axe with a leather grip. Good for fallen branches.'],
    ['axe', 2, 'Woodcutter’s Axe', 450, 12, 'Bites clean through seasoned logs.'],
    ['axe', 3, 'Fine Felling Axe', 1700, 28, 'Finds the heartwood other gnomes miss.'],
    ['rod', 1, 'Willow Fishing Rod', 60, 3, 'A bendy willow stick with a line and a bent pin.'],
    ['rod', 2, 'Cane Fishing Rod', 420, 12, 'A proper reel and a lucky float.'],
    ['rod', 3, 'Fine Fly Rod', 1600, 28, 'Casts like a whisper. The big ones bite.'],
    ['basket', 1, 'Gathering Pouch', 80, 3, 'A pouch on a string.'],
    ['basket', 2, 'Gathering Basket', 500, 12, 'Room for a little extra.'],
    ['basket', 3, 'Forager’s Pack', 2000, 28, 'Pockets inside pockets.'],
    ['staff', 1, 'Walking Stick', 90, 3, 'A good straight stick with a knob on top.'],
    ['staff', 2, 'Hiking Staff', 520, 12, 'Ash wood, a leather grip and a little bell.'],
    ['staff', 3, 'Wayfarer’s Staff', 1800, 28, 'Carved with every road its owners have walked.'],
    ['lantern', 1, 'Tin Lantern', 120, 4, 'A candle in a tin box. It does the job.'],
    ['lantern', 2, 'Miner’s Lantern', 600, 14, 'Bright, steady and hard to blow out.'],
    ['lantern', 3, 'Glowcap Lantern', 2000, 30, 'A jar of glowing mushrooms that never runs out.'],
    ['soiltest', 2, 'Soil Probe', 900, 15, 'A long steel probe with a dial that reads the soil deep down.'],
];

function tool_slug(string $name): string
{
    return slugify($name);
}

/** Squares a tier reaches: 1, 3 (the row neighbours) or 99 (the whole row). */
function tool_reach(int $tier): int
{
    return $tier >= 3 ? 99 : ($tier === 2 ? 3 : 1);
}

function reach_label(int $reach): string
{
    return $reach >= 99 ? 'the whole row' : ($reach === 3 ? '3 squares in a row' : 'one square');
}

/** What a tier does, in words, for item descriptions and the toolbelt. */
function tool_tier_text(string $type, int $tier): string
{
    if (in_array($type, ['forage', 'pick', 'net', 'bucket', 'axe', 'rod'], true)) {   // axe, rod: v0.7.81
        return ['', 'Gathers common finds.', 'Gathers common and uncommon finds.', 'Gathers everything, including rare finds.', 'Gathers everything, including rare finds.'][$tier] ?? '';
    }
    if ($type === 'staff') {
        $pct = [1 => 25, 2 => 45, 3 => 65][$tier] ?? 0;
        return $pct ? $pct . '% chance a walk or a step off the path costs no energy.' : '';
    }
    if ($type === 'lantern') {
        return ['', 'Delve rooms cost no energy.', 'Delve rooms cost no energy, and traps are 2 easier to get past.',
            'Delve rooms cost no energy, traps are 3 easier, and delve chests hold an extra find.'][$tier] ?? '';
    }
    if ($type === 'soiltest') {
        return $tier >= 2 ? 'Shows exact soil numbers, what’s still feeding the soil, and the best crops you know for each square.' : 'Shows exact fertility, soil life and water-holding of every square.';
    }
    if ($type === 'basket') {
        return ['', '1 in 3 gathers bring home one extra.', '2 in 3 gathers bring home one extra.', 'Every gather brings home one extra.', 'Every gather brings home one extra.'][$tier] ?? '';
    }
    if ($type === 'prune') {
        return ['', '25% chance of +1 from perennials and flowers.', '50% chance of +1 from perennials and flowers.',
            '75% chance of +1 from perennials and flowers.', 'Always +1, and 50% chance of +2, from perennials and flowers.'][$tier] ?? '';
    }
    $bits = [];
    if (TOOL_TYPES[$type][4] ?? false) $bits[] = 'Works ' . reach_label(tool_reach($tier)) . ' at once';
    if (tool_free_chance($tier)) $bits[] = tool_free_chance($tier) . '% chance it costs no energy';
    return $bits ? ucfirst(implode(', ', $bits)) . '.' : '';
}

/** Best tier of a tool type in the gnome's satchel (0 = none). Old items with "power" count as that tier. */
/** Per-request cache of tool tiers. tool_cache_reset() empties it when a tool breaks or is mended (v0.7.86). */
function &tool_tier_cache(): array
{
    static $cache = [];
    return $cache;
}

function tool_cache_reset(): void
{
    $cache = &tool_tier_cache();
    $cache = [];
}

function tool_tier(int $uid, string $type): int
{
    $cache = &tool_tier_cache();
    $key = $uid . ':' . $type;
    if (isset($cache[$key])) return $cache[$key];
    $best = 0;
    foreach (q('SELECT i.effects FROM user_items ui JOIN items i ON i.id = ui.item_id
                WHERE ui.user_id = ? AND ui.qty > 0 AND i.effects LIKE ?', [$uid, '%"tool":"' . $type . '"%'])->fetchAll(PDO::FETCH_COLUMN) as $fx) {
        $f = json_decode((string)$fx, true) ?: [];
        if (($f['tool'] ?? '') !== $type) continue;
        $best = max($best, (int)($f['tier'] ?? $f['power'] ?? 1));
    }
    return $cache[$key] = min(4, $best);
}

/** The best tool item of a type the gnome owns, or null. */
function best_tool(int $uid, string $type): ?array
{
    $tier = tool_tier($uid, $type);
    if ($tier < 1) return null;
    foreach (q('SELECT i.* FROM user_items ui JOIN items i ON i.id = ui.item_id
                WHERE ui.user_id = ? AND ui.qty > 0 AND i.effects LIKE ?', [$uid, '%"tool":"' . $type . '"%'])->fetchAll() as $i) {
        $f = json_decode((string)$i['effects'], true) ?: [];
        if (($f['tool'] ?? '') === $type && (int)($f['tier'] ?? $f['power'] ?? 1) === $tier) return $i;
    }
    return null;
}

/**
 * Energy for one square of an action. v0.7.85: the old tier discount is retired; every garden action costs its base
 * energy here, and tools help through the free-use chance instead (tool_free_chance, applied in garden_logic.php).
 */
function tool_energy(int $base, int $tier): int
{
    return $base;
}

/** Does the walking staff save the energy this time? (v0.7.30) */
function staff_free(int $uid): bool
{
    $chance = [0, 25, 45, 65][min(3, tool_tier($uid, 'staff'))];
    return $chance > 0 && random_int(1, 100) <= $chance;
}

/** % chance a garden action with this tool tier costs no energy (v0.7.23). */
function tool_free_chance(int $tier): int
{
    return [0, 0, 20, 30, 50][max(0, min(4, $tier))];
}

/** Add any missing tool items, refresh their descriptions, and stock tiers 1–3 (and rare tier 4) at Twigg's. */
function ensure_tools(): int
{
    $added = 0;
    $shop = (int)q_val("SELECT id FROM shops WHERE slug = 'twigg-s-seed-emporium'");
    foreach (TOOL_ITEMS as [$type, $tier, $name, $price, $rarity, $flavour]) {
        $slug = tool_slug($name);
        $desc = TOOL_TIERS[$tier] . ' ' . strtolower(TOOL_TYPES[$type][0]) . ' tool' . (in_array($type, GATHER_TOOLS, true) ? ' for adventures' : '')
            . '. ' . $flavour . ' ' . tool_tier_text($type, $tier);
        $fx = json_encode(['tool' => $type, 'tier' => $tier]);
        $id = (int)q_val('SELECT id FROM items WHERE slug = ?', [$slug]);
        if (!$id) {
            $id = db_insert('items', ['name' => $name, 'slug' => $slug, 'category' => 'tool', 'base_price' => $price,
                'rarity' => $rarity, 'description' => $desc, 'effects' => $fx]);
            $added++;
        } else {
            // v0.7.85: an existing tool keeps whatever an admin has edited. Only empty fields are filled in
            // (older installs' starter tools get their tier this way); nothing already set is overwritten.
            q("UPDATE items SET effects = COALESCE(NULLIF(effects, ''), ?), description = COALESCE(NULLIF(description, ''), ?),
                 base_price = COALESCE(base_price, ?) WHERE id = ? AND category = 'tool'", [$fx, $desc, $price, $id]);
        }
        if (!q_val('SELECT 1 FROM items WHERE slug = ?', ['broken-' . $slug])) {   // v0.7.86: the Broken copy every tool leaves behind
            broken_item_id(['slug' => $slug, 'name' => $name, 'base_price' => $price]);
            $added++;
        }
        if ($shop && !q_val('SELECT 1 FROM shop_stock WHERE shop_id = ? AND item_id = ?', [$shop, $id])) {
            $rare = $tier >= 4;
            db_insert('shop_stock', ['shop_id' => $shop, 'item_id' => $id,
                'price_min' => (int)floor($price * 0.9), 'price_max' => (int)ceil($price * 1.2),
                'max_stock' => $rare ? 1 : max(2, 12 - $tier * 3), 'restock_chance' => $rare ? 5 : max(30, 90 - $tier * 15),
                'current_stock' => 0, 'current_price' => $price]);
        }
    }
    return $added;
}

// ----------------------------------------------------------------- Tool wear (v0.7.86)

/** Garden tool types: they wear by days of use. */
const GARDEN_WEAR_TYPES = ['till', 'water', 'plant', 'spread', 'weed', 'harvest', 'prune', 'broadfork'];
/** Gathering tools, the walking staff and the lantern: they wear by uses. The basket and soil probe never wear. */
const GATHER_WEAR_TYPES = ['forage', 'pick', 'net', 'bucket', 'axe', 'rod', 'staff', 'lantern'];
const GATHER_WEAR_DEFAULT = [60, 150, 300, 600];
const GARDEN_WEAR_DEFAULT = [0, 45, 90, 180];

function tool_wear_on(): bool
{
    return setting('tool_wear_on') === '1';
}

/** A wear setting as four whole numbers (Worn to Masterwork). Anything muddled falls back to the default. */
function tool_wear_list(string $name, array $default): array
{
    $parts = array_map('trim', explode(',', setting($name)));
    if (count($parts) < 4) return $default;
    foreach (array_slice($parts, 0, 4) as $p) {
        if (!ctype_digit($p)) return $default;
    }
    return array_map('intval', array_slice($parts, 0, 4));
}

/** Uses (gathering tools, staff, lantern) or days of use (garden tools) before a tool of this tier breaks. 0 = never. */
function tool_wear_limit(string $type, int $tier): int
{
    if ($tier < 1 || ($type === 'lantern' && $tier >= 3)) return 0;   // the Glowcap Lantern never runs out
    if (in_array($type, GARDEN_WEAR_TYPES, true)) return tool_wear_list('garden_tool_days', GARDEN_WEAR_DEFAULT)[min(4, $tier) - 1];
    if (in_array($type, GATHER_WEAR_TYPES, true)) return tool_wear_list('gather_tool_uses', GATHER_WEAR_DEFAULT)[min(4, $tier) - 1];
    return 0;
}

/**
 * How much a tool has left: ['kind' => 'use' or 'day', 'limit' => n, 'left' => n]. A limit of 0 means it never wears out.
 * Null when the item isn't a tool or wear is switched off. $wear is the wear on the gnome's copy.
 */
function tool_wear_info(array $item, int $wear): ?array
{
    $fx = json_decode((string)($item['effects'] ?? ''), true) ?: [];
    $type = (string)($fx['tool'] ?? '');
    if (($item['category'] ?? '') !== 'tool' || $type === '' || !tool_wear_on()) return null;
    $limit = tool_wear_limit($type, (int)($fx['tier'] ?? $fx['power'] ?? 1));
    return ['kind' => in_array($type, GARDEN_WEAR_TYPES, true) ? 'day' : 'use', 'limit' => $limit, 'left' => max(0, $limit - $wear)];
}

/** One line for an item's facts: how a tool wears (plain text; the caller escapes it). */
function tool_wear_fact(array $item): string
{
    $info = tool_wear_info($item, 0);
    if ($info === null) return '';
    if ($info['limit'] < 1) return '🔧 Never wears out.';
    return '🔧 Wears with use: breaks after ' . $info['limit'] . ($info['kind'] === 'day' ? ' days of use' : ' uses')
        . '. Mend it in your Satchel when it’s worn.';
}

/** "42 uses left" or "30 days left" for the gnome's best copy of a tool, or '' if it never wears (or has none). */
function tool_left_text(int $uid, string $type): string
{
    $best = best_tool($uid, $type);
    if (!$best) return '';
    $info = tool_wear_info($best, (int)q_val('SELECT wear FROM user_items WHERE user_id = ? AND item_id = ?', [$uid, (int)$best['id']]));
    if (!$info || $info['limit'] < 1) return '';
    return $info['left'] . ($info['kind'] === 'day' ? ' days left' : ' uses left');
}

/**
 * v0.7.86: a tool did its job (a find gathered, a staff step or lantern room that saved energy, a garden square
 * tended). Only the copy the gnome carries best wears. $kind 'use' adds one use; 'day' adds one day of use, once per
 * Hollow day. At the limit the tool breaks (tool_break). Near the end the gnome is warned, once.
 * Returns a line for the journal or flash, or null.
 */
function tool_use(int $uid, string $type, string $kind = 'use'): ?string
{
    if (!tool_wear_on() || tool_tier($uid, $type) < 1) return null;
    $tool = best_tool($uid, $type);
    if (!$tool) return null;
    $limit = tool_wear_limit($type, tool_tier($uid, $type));
    if ($limit < 1) return null;
    $day = $kind === 'day';
    $iid = (int)$tool['id'];
    if ($day) {
        $today = hollow_date('Y-m-d');
        $n = q('UPDATE user_items SET wear = wear + 1, wear_day = ? WHERE user_id = ? AND item_id = ? AND qty > 0 AND (wear_day IS NULL OR wear_day <> ?)',
            [$today, $uid, $iid, $today])->rowCount();
    } else {
        $n = q('UPDATE user_items SET wear = wear + 1 WHERE user_id = ? AND item_id = ? AND qty > 0', [$uid, $iid])->rowCount();
    }
    if ($n !== 1) return null;   // already counted today, or the gnome has no copy
    $wear = (int)q_val('SELECT wear FROM user_items WHERE user_id = ? AND item_id = ?', [$uid, $iid]);
    $left = $limit - $wear;
    if ($left <= 0) return tool_break($uid, $tool);
    $warnAt = max(3, (int)ceil($limit / 10));
    if ($left <= $warnAt && ($left === $warnAt || $wear === 1)) {
        return '🔧 Your ' . $tool['name'] . ' is wearing thin: ' . $left . ($day ? ' day' : ' use') . ($left === 1 ? '' : 's') . ' left.';
    }
    return null;
}

/** The tool at its limit breaks: one copy goes and a Broken copy takes its place until it is mended. */
function tool_break(int $uid, array $tool): string
{
    $iid = (int)$tool['id'];
    give_item($uid, $iid, -1);   // the row (and its wear) goes if that was the last copy
    q('UPDATE user_items SET wear = 0, wear_day = NULL WHERE user_id = ? AND item_id = ? AND qty > 0', [$uid, $iid]);   // spare copies in the stack start fresh
    give_item($uid, broken_item_id($tool), 1);
    tool_cache_reset();   // the tool is gone from tool_tier for the rest of this request
    return '💥 Your ' . $tool['name'] . ' broke! Mend it in your Satchel for ' . number_format(tool_mend_cost((int)$tool['base_price'])) . ' ' . setting('currency_name') . '.';
}

/** The Broken copy of a tool, made if it isn't there yet. Broken items have no effects, so they never count as tools. */
function broken_item_id(array $tool): int
{
    $slug = 'broken-' . $tool['slug'];
    $id = (int)q_val('SELECT id FROM items WHERE slug = ?', [$slug]);
    if ($id) return $id;
    return db_insert('items', ['name' => 'Broken ' . $tool['name'], 'slug' => $slug, 'category' => 'broken',
        'base_price' => max(1, (int)round((int)$tool['base_price'] * 0.1)), 'rarity' => 1, 'tradable' => 1, 'edible' => 0,
        'description' => 'Broken. Mend it in your Satchel to use it again.', 'effects' => null]);
}

/** What mending a tool costs: tool_mend_percent of its price, and at least 5 Petals. */
function tool_mend_cost(int $basePrice): int
{
    return max(5, (int)round($basePrice * (int)setting('tool_mend_percent') / 100));
}

/** The working tool a Broken copy belongs to, or null. */
function tool_of_broken(array $broken): ?array
{
    if (!str_starts_with((string)$broken['slug'], 'broken-')) return null;
    return q_one("SELECT * FROM items WHERE slug = ? AND category = 'tool'", [substr((string)$broken['slug'], 7)]);
}

/** The Broken copy of a tool type the gnome carries (the highest tier), or null. */
function tool_broken_owned(int $uid, string $type): ?array
{
    foreach (array_reverse(TOOL_ITEMS) as [$t, , $name]) {
        if ($t !== $type) continue;
        $row = q_one('SELECT i.* FROM user_items ui JOIN items i ON i.id = ui.item_id WHERE ui.user_id = ? AND i.slug = ? AND ui.qty > 0',
            [$uid, 'broken-' . tool_slug($name)]);
        if ($row) return $row;
    }
    return null;
}

/** Does the gnome have a Tool Shed in any of their gardens? */
/** v0.7.96: free mends a day: 0 without a Tool Shed, 1 with one, 2 with a level 3 one. */
function tool_free_mends(int $uid): int
{
    require_once __DIR__ . '/gardens.php';
    $lv = user_building_level($uid, 'tool_shed');
    return $lv >= 3 ? 2 : ($lv >= 1 ? 1 : 0);
}

function tool_shed_owned(int $uid): bool
{
    return (bool)q_val("SELECT 1 FROM garden_buildings gb JOIN plots p ON p.id = gb.plot_id WHERE p.user_id = ? AND gb.building = 'tool_shed'", [$uid]);
}

/**
 * v0.7.86: mend a worn tool, or a Broken copy, in the Satchel. Costs tool_mend_cost. A Tool Shed in any of the gnome's
 * gardens makes the first mend of each Hollow day free. Returns [ok, message].
 */
function mend_tool(int $uid, int $itemId): array
{
    $row = q_one('SELECT i.*, ui.wear FROM user_items ui JOIN items i ON i.id = ui.item_id WHERE ui.user_id = ? AND ui.item_id = ? AND ui.qty > 0', [$uid, $itemId]);
    if (!$row) return [false, 'You don’t have that.'];
    $broken = $row['category'] === 'broken';
    $tool = $broken ? tool_of_broken($row) : $row;
    if (!$tool || $tool['category'] !== 'tool') return [false, 'That doesn’t need mending.'];
    if (!$broken && (int)$row['wear'] < 1) return [false, 'Your ' . $tool['name'] . ' is in good order.'];
    $cost = tool_mend_cost((int)$tool['base_price']);
    $today = hollow_date('Y-m-d');
    db()->beginTransaction();
    $allow = tool_free_mends($uid);   // v0.7.96: 1 a day with a Tool Shed, 2 with a level 3 one
    $free = $allow > 0
        && q('UPDATE users SET free_mend_n = CASE WHEN free_mend_day = ? THEN free_mend_n + 1 ELSE 1 END, free_mend_day = ?
              WHERE id = ? AND (free_mend_day IS NULL OR free_mend_day <> ? OR free_mend_n < ?)', [$today, $today, $uid, $today, $allow])->rowCount() === 1;
    if (!$free && q('UPDATE users SET coins = coins - ? WHERE id = ? AND coins >= ?', [$cost, $uid, $cost])->rowCount() !== 1) {
        db()->rollBack();
        return [false, 'Mending it costs ' . number_format($cost) . ' ' . setting('currency_name') . '. You don’t have that many.'];
    }
    if ($broken) {
        if (!give_item($uid, $itemId, -1)) {
            db()->rollBack();
            return [false, 'You don’t have that.'];
        }
        give_item($uid, (int)$tool['id'], 1);
    }
    q('UPDATE user_items SET wear = 0, wear_day = NULL WHERE user_id = ? AND item_id = ?', [$uid, (int)$tool['id']]);
    db()->commit();
    tool_cache_reset();
    return [true, $free ? '🛠️ Your Tool Shed mended it for free today.'
        : '🔧 Mended your ' . $tool['name'] . ' for ' . number_format($cost) . ' ' . setting('currency_name') . '.'];
}

/** A worn tool can't be traded, put on a stall or given away until it is mended. Returns the reason, or null. */
function tool_trade_block(int $uid, int $itemId): ?string
{
    $r = q_one("SELECT i.name, i.category, ui.wear FROM user_items ui JOIN items i ON i.id = ui.item_id WHERE ui.user_id = ? AND ui.item_id = ? AND ui.qty > 0",
        [$uid, $itemId]);
    return $r && $r['category'] === 'tool' && (int)$r['wear'] > 0 ? 'Your ' . $r['name'] . ' is worn. Mend it first.' : null;
}

/**
 * v0.7.86: the Satchel's wear block for a tool or a Broken copy: uses or days left with a bar, and the mend button
 * when it's worn or broken. $hidden is extra hidden form fields. Returns HTML, or '' for anything else.
 */
function tool_wear_html(int $uid, array $item, int $wear, string $hidden = ''): string
{
    $broken = ($item['category'] ?? '') === 'broken';
    $tool = $broken ? tool_of_broken($item) : $item;
    if (!$tool) return '';
    $info = $broken ? null : tool_wear_info($tool, $wear);
    $h = '';
    if ($broken) {
        $h = '<p class="help bad">💥 Broken. Mend it to use it again.</p>';
    } elseif ($info && $info['limit'] < 1) {
        $h = '<p class="help">Never wears out.</p>';
    } elseif ($info) {
        $h = '<p class="help">' . ($info['kind'] === 'day' ? 'Days left: ' : 'Uses left: ') . $info['left'] . ' of ' . $info['limit'] . '</p>'
            . '<progress max="' . $info['limit'] . '" value="' . $info['left'] . '"></progress>';
    }
    if ($broken || $wear > 0) {
        $fm = q_one('SELECT free_mend_day, free_mend_n FROM users WHERE id = ?', [$uid]) ?: [];
        $free = ($allow = tool_free_mends($uid)) > 0 && ((string)($fm['free_mend_day'] ?? '') !== hollow_date('Y-m-d') || (int)($fm['free_mend_n'] ?? 0) < $allow);
        $cost = tool_mend_cost((int)$tool['base_price']);
        $label = $free ? '🛠️ Mend free (Tool Shed)' : '🔧 Mend (' . number_format($cost) . ' ' . setting('currency_name') . ')';
        $h .= '<form method="post">' . csrf_field() . '<input type="hidden" name="do" value="mend"><input type="hidden" name="item_id" value="' . (int)$item['id'] . '">'
            . $hidden . '<button class="btn small">' . $label . '</button></form>';
    }
    return $h === '' ? '' : '<div class="wearbox">' . $h . '</div>';
}

/** v0.7.86: the wear block for a toolbelt job: its best copy, or the Broken copy if that is all the gnome has. */
function tool_belt_wear_html(int $uid, string $type, string $hidden = ''): string
{
    if ($best = best_tool($uid, $type)) {
        return tool_wear_html($uid, $best, (int)q_val('SELECT wear FROM user_items WHERE user_id = ? AND item_id = ?', [$uid, (int)$best['id']]), $hidden);
    }
    $broken = tool_broken_owned($uid, $type);
    return $broken ? tool_wear_html($uid, $broken, 0, $hidden) : '';
}
