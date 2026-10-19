<?php
declare(strict_types=1);

/** Gardens: several per gnome, each in a region, with its own level and buildings. */

require_once __DIR__ . '/yard.php';
require_once __DIR__ . '/garden_critters.php';   // v1.0.0 wave 2a: garden animals

// key => [name, icon, garden level needed, cost, what it does]
const BUILDINGS = [
    'kitchen' => ['Kitchen', '🍳', 2, 200, 'Lets you cook snacks and meals on the Crafting page. Dishes cook in pots, and you have two, so a quick snack and a slow meal can cook together.'],
    'rain_barrel' => ['Rain Barrel', '🛢️', 3, 800, 'Each watering lasts 25% longer in this garden.'],
    'tool_shed' => ['Tool Shed', '🧰', 4, 1200, 'Lets you craft tools (even Masterwork ones) and gives a hired helper somewhere to stay. Sheet mulching costs 1 less energy here, and tilling has a 25% chance to cost none. Its first mend of each day is free for any worn or broken tool.'],
    'compost_bin' => ['Compost Bin', '♻️', 5, 1500, 'Makes 1 Plain Compost a day (holds 5). Every harvest, dug-up plant and weeding adds a scrap to its heap, and you can add Food Scraps (left from eating raw crops) by hand: every 8 scraps make another Plain Compost (the heap holds 10).'],
    'beehive' => ['Beehive', '🐝', 6, 2500, 'Crops here get a 25% chance of a pollinator bonus, and the bees make 1 Garden Honey a day (holds 5).'],
    'greenhouse' => ['Greenhouse', '🏠', 8, 4000, 'Every crop grows at native speed here, wherever it comes from.'],
    'root_cellar' => ['Root Cellar', '🚪', 3, 900, 'Keeps up to 5 perennials safe while you need their beds: dig one up into the cellar (costs a few Petals), and replant it later in any empty, tilled square of this garden, just as grown as it was.'],   // v0.7.56    // v1.0.0 wave 2a: garden animals (their rules are in garden_critters.php)
    'worm_farm' => ['Worm Farm', '🪱', 4, 900, 'A tray of worm colonies. Feed them Food Scraps and they leave Worm Castings for your beds. Two homes.'],
    'ladybird_lodge' => ['Ladybird Lodge', '🐞', 5, 1200, 'A bug hotel. Its ladybirds keep aphids off beds within 2 squares and leave lucky Ladybird Charms. Two homes.'],
    'frog_pond' => ['Frog Pond', '🐸', 6, 1800, 'A little pond. Its frogs keep slugs, snails and gnats off beds within 3 squares, make the yard prettier, and lay frogspawn that hatches into tadpoles. Two homes.'],
    'quail_coop' => ['Quail Coop', '🐦', 5, 1400, 'A snug coop. Its quail eat Food Scraps and leave tiny Quail Eggs. Two homes.'],   // v1.2.0: more animals
    'silk_shelf' => ['Silkworm Shelf', '🐛', 7, 2000, 'Leafy trays for silkworms. They eat Mulberry Leaves (from a mulberry tree or Twigg’s shop) and leave empty Silk Cocoons: peace silk. Two homes.'],
    'tortoise_run' => ['Tortoise Run', '🐢', 8, 2800, 'A grassy run for a slow tortoise. It grazes leafy greens, sheds a Tortoise Scute now and then, and makes the yard prettier. One home.'],
    'snail_jar' => ['Snail Jar', '🐌', 3, 300, 'A glass jar of damp soil for rescued snails. Pick slugs and snails off your beds and one may ask to stay. They eat Food Scraps or lettuce and leave Snail Trail Glaze. Three homes.'],   // v1.4.0: more animals
    'butterfly_bush' => ['Butterfly Bush', '🦋', 4, 1100, 'A purple-flowered bush for butterflies. No feeding. Flowers within 2 squares sometimes give an extra stem, and butterflies leave shimmering Wing Scales. Two homes.'],
];

// Buildings that produce something every day: building => item slug
const BUILDING_PRODUCE = ['compost_bin' => 'plain-compost', 'beehive' => 'garden-honey'];

/**
 * v0.7.95: building upgrades. building => [level => what it adds]. Level 1 is the building as built.
 * Costs: setting upgrade_cost_percent (of the build cost) and upgrade_materials_N; garden level: build level + upgrade_level_gap.
 */
const BUILDING_UPGRADES = [
    'compost_bin' => [2 => 'The heap needs only 6 scraps for each Plain Compost, and can make Leaf Mould (12 scraps) or Worm Castings (20 scraps) instead. You choose what the heap makes.',
                      3 => 'A worm bin: the heap can also make Rich Loam (40 scraps).'],
    'beehive'     => [2 => 'Pollinator chance 35% (from 25%), and the hive holds 10 honey.',
                      3 => 'Pollinator chance 45%, and the bees also make 1 Beeswax a day (for candles).'],
    // v0.7.96 (update B)
    'rain_barrel' => [2 => 'Each watering lasts 40% longer (from 25%).',
                      3 => 'Each watering lasts 55% longer, and once a day 💧 Water all is free here.'],
    'tool_shed'   => [2 => 'Room for a 2nd hired helper, and garden tools used here wear 15% slower.',
                      3 => 'Room for a 3rd hired helper, garden tools used here wear 30% slower, and you get 2 free mends a day.'],
    'greenhouse'  => [2 => 'Crops here grow 10% faster, on top of native speed.',
                      3 => 'Perennials here live 25% longer.'],
    'root_cellar' => [2 => 'Holds 10 perennials.',
                      3 => 'Holds 15 perennials, and storing one is free.'],
    'worm_farm'   => [2 => 'Room for a 3rd colony, and the worms work 15% faster.',
                      3 => 'Room for a 4th colony, and the worms work 30% faster.'],
    'ladybird_lodge' => [2 => 'Room for a 3rd ladybird, and they leave charms 15% faster.',
                         3 => 'Room for a 4th ladybird, and they leave charms 30% faster.'],
    'frog_pond'   => [2 => 'Room for a 3rd frog or tadpole, and the frogs lay spawn 15% faster.',
                      3 => 'Room for a 4th frog or tadpole, and the frogs lay spawn 30% faster.'],
    'quail_coop'  => [2 => 'Room for a 3rd quail, and the eggs come 15% faster.',
                      3 => 'Room for a 4th quail, and the eggs come 30% faster.'],
    'silk_shelf'  => [2 => 'Room for a 3rd silkworm tray, and cocoons come 15% faster.',
                      3 => 'Room for a 4th silkworm tray, and cocoons come 30% faster.'],
    'tortoise_run' => [2 => 'Room for a 2nd tortoise, and scutes come 15% faster.',
                       3 => 'Room for a 3rd tortoise, and scutes come 30% faster.'],
    'snail_jar'   => [2 => 'Snail Trail Glaze comes 15% faster.',
                      3 => 'Snail Trail Glaze comes 30% faster.'],   // v1.4.0
    'butterfly_bush' => [2 => 'Room for a 3rd butterfly, Wing Scales come 15% faster, and flowers nearby give +1 stem 5% more often.',
                         3 => 'Room for a 4th butterfly, Wing Scales come 30% faster, and flowers nearby give +1 stem 10% more often.'],
    'kitchen'     => [2 => 'A third pot, and meal buffs from anything you eat last 25% longer.',
                      3 => 'A fourth pot, meal buffs last 50% longer, cooking gives 50% more XP, and you can cook 🍳 feasts (big meals with long, strong buffs; the firewood and spices cost Petals).'],
];

/** v0.7.96: the best level of a building in any of this gnome's gardens (0 = none), for things that aren't tied to one garden. */
function user_building_level(int $uid, string $b): int
{
    return (int)q_val("SELECT MAX(gb.level) FROM garden_buildings gb JOIN plots p ON p.id = gb.plot_id WHERE p.user_id = ? AND gb.building = ?", [$uid, $b]);
}

/**
 * v0.9.5: stacking. What a building that helps YOU gives, summed over all of this gnome's gardens: the best garden's level counts
 * fully, every other garden's level adds a smaller stack_* rate (docs/building-stacking.md). Only the Kitchen helps you; every other
 * building returns just its best level (they are per garden, and the Tool Shed stays per garden too).
 * Returns: best (level), extra (levels in the other gardens), levels (all, high to low), and for the Kitchen
 * buff_pct / xp_pct (percent extra), pots (extra pots from other gardens), feasts (best is level 3).
 */
function user_building_bonus(int $uid, string $b): array
{
    $levels = array_map('intval', q("SELECT gb.level FROM garden_buildings gb JOIN plots p ON p.id = gb.plot_id WHERE p.user_id = ? AND gb.building = ?
                                     ORDER BY gb.level DESC, gb.plot_id", [$uid, $b])->fetchAll(PDO::FETCH_COLUMN));
    $levels = array_map(fn($l) => max(1, $l), $levels);
    $best = $levels[0] ?? 0;
    $others = array_slice($levels, 1);
    $out = ['best' => $best, 'extra' => array_sum($others), 'levels' => $levels, 'buff_pct' => 0, 'xp_pct' => 0, 'pots' => 0, 'feasts' => false, 'jars' => 0, 'pantries' => 0];
    if ($b !== 'kitchen' || $best < 1) return $out;
    $out['feasts'] = $best >= 3;
    $out['buff_pct'] = min(max(0, (int)setting('stack_kitchen_buff_max')), ($best >= 3 ? 50 : ($best >= 2 ? 25 : 0)) + $out['extra'] * max(0, (int)setting('stack_kitchen_buff_pct')));
    $out['xp_pct'] = min(max(0, (int)setting('stack_kitchen_xp_max')), ($best >= 3 ? 50 : 0) + $out['extra'] * max(0, (int)setting('stack_kitchen_xp_pct')));
    $out['pots'] = min(max(0, (int)setting('stack_kitchen_pot_max')), count(array_filter($others, fn($l) => $l >= 3)) * max(0, (int)setting('stack_kitchen_pot_per_iii')));
    // v0.9.8: Pantry jars: pantry_jars to start, +pantry_jars_k3 when a Kitchen with a Pantry is level III, +1 for each other garden's Pantry (up to +3)
    $pl = array_map('intval', q("SELECT gb.level FROM garden_buildings gb JOIN plots p ON p.id = gb.plot_id WHERE p.user_id = ? AND gb.building = 'kitchen' AND gb.pantry = 1
                                 ORDER BY gb.level DESC", [$uid])->fetchAll(PDO::FETCH_COLUMN));
    if ($pl) {
        $out['pantries'] = count($pl);
        $out['jars'] = max(1, (int)setting('pantry_jars')) + (max($pl) >= 3 ? max(0, (int)setting('pantry_jars_k3')) : 0)
            + min(max(0, (int)setting('stack_pantry_jar_max')), (count($pl) - 1) * max(0, (int)setting('stack_pantry_jar_per')));
    }
    return $out;
}

/** v0.7.96: how many perennials this garden's root cellar holds. */
function cellar_slots(int $plotId): int
{
    return (int)setting('cellar_slots') + 5 * max(0, building_level($plotId, 'root_cellar') - 1);
}
const BUILDING_LEVEL_MARK = [1 => '', 2 => ' II', 3 => ' III'];

/** v0.9.6: one-line blurbs for the "buildable" tiles of the garden buildings panel. */
const BUILDING_SHORT = [
    'kitchen' => 'Cook snacks and meals in pots.',
    'rain_barrel' => 'Watering lasts 25% longer here.',
    'tool_shed' => 'Craft tools, house a hired helper.',
    'compost_bin' => 'Turns scraps into Plain Compost.',
    'beehive' => 'Pollinator bonus and daily honey.',
    'greenhouse' => 'Every crop grows at native speed.',
    'root_cellar' => 'Safe storage for up to 5 perennials.',
    'worm_farm' => 'Worms turn Food Scraps into Worm Castings.',
    'ladybird_lodge' => 'Ladybirds keep aphids off nearby beds.',
    'frog_pond' => 'Frogs keep slugs, snails and gnats off nearby beds.',
    'quail_coop' => 'Quail turn Food Scraps into tiny eggs.',
    'silk_shelf' => 'Silkworms turn Mulberry Leaves into silk cocoons.',
    'tortoise_run' => 'A slow tortoise: scutes, and a prettier yard.',
    'snail_jar' => 'Rescued snails leave Snail Trail Glaze.',   // v1.4.0
    'butterfly_bush' => 'Butterflies: extra flower stems nearby, Wing Scales.',
];

/** v0.9.6: what a building does AT each level, in plain words (the details sheet; not the incremental upgrade texts). */
const BUILDING_NOW = [
    'kitchen' => [1 => 'Cook snacks and meals on the Crafting page. You have 2 pots, so a quick snack and a slow meal can cook together.',
                  2 => 'Cook snacks and meals in 3 pots. Meal buffs from anything you eat last 25% longer.',
                  3 => 'Cook in 4 pots, and cook feasts (big meals with long, strong buffs; firewood and spices cost Petals). Meal buffs last 50% longer and cooking gives 50% more XP.'],
    'rain_barrel' => [1 => 'Each watering lasts 25% longer in this garden.',
                      2 => 'Each watering lasts 40% longer in this garden.',
                      3 => 'Each watering lasts 55% longer in this garden, and once a day 💧 Water all is free.'],
    'tool_shed' => [1 => 'Craft tools (even Masterwork ones) and house 1 hired helper. Sheet mulching costs 1 less energy, tilling has a 25% chance to cost none, and the first mend each day is free.',
                    2 => 'As level 1, with room for 2 helpers, and garden tools used here wear 15% slower.',
                    3 => 'As level 1, with room for 3 helpers, tools wear 30% slower, and you get 2 free mends a day.'],
    'compost_bin' => [1 => 'Makes 1 Plain Compost a day (holds 5). Harvests, dug-up plants and weeding add scraps to the heap; every 8 scraps make another Plain Compost (heap holds 10).',
                      2 => 'Makes 1 Plain Compost a day (holds 5). The heap needs only 6 scraps per Plain Compost, or you can have it make Leaf Mould (12) or Worm Castings (20).',
                      3 => 'As level 2, and the heap can also make Rich Loam (40 scraps).'],
    'beehive' => [1 => 'Crops here get a 25% chance of a pollinator bonus. Bees make 1 Garden Honey a day (holds 5).',
                  2 => 'Pollinator chance 35%. Bees make 1 Garden Honey a day (holds 10).',
                  3 => 'Pollinator chance 45%. Bees make 1 Garden Honey (holds 10) and 1 Beeswax a day.'],
    'greenhouse' => [1 => 'Every crop grows at native speed here, wherever it comes from.',
                     2 => 'Native speed for every crop, and crops here grow 10% faster on top.',
                     3 => 'Native speed, 10% faster growth, and perennials here live 25% longer.'],
    'root_cellar' => [1 => 'Keeps up to 5 perennials safe while you need their beds. Dig one up into the cellar (costs a few Petals) and replant it later in any empty, tilled square, just as grown.',
                      2 => 'Holds 10 perennials. Dig up into the cellar (costs a few Petals), replant later just as grown.',
                      3 => 'Holds 15 perennials, and storing one is free. Replant later just as grown.'],
    'worm_farm' => [1 => 'Two homes for worm colonies. Feed them Food Scraps; every few scraps become a Worm Castings (they wait for you, a few at a time).',
                    2 => 'Three homes, and the worms work 15% faster.',
                    3 => 'Four homes, and the worms work 30% faster.'],
    'ladybird_lodge' => [1 => 'Two homes for ladybirds. Aphids rarely visit beds within 2 squares and get eaten when they do. Pleased ladybirds leave a Ladybird Charm now and then.',
                         2 => 'Three homes, and charms 15% faster.',
                         3 => 'Four homes, and charms 30% faster.'],
    'frog_pond' => [1 => 'Two homes for frogs and tadpoles. Slugs, snails and gnats rarely visit beds within 3 squares and get eaten when they do. Frogs lay Frogspawn, which hatches into tadpoles.',
                    2 => 'Three homes, and Frogspawn 15% faster.',
                    3 => 'Four homes, and Frogspawn 30% faster.'],
    'quail_coop' => [1 => 'Two homes for quail. Feed them Food Scraps; they leave tiny Quail Eggs, which wait for you a few at a time. They like herbs and flowers nearby.',
                     2 => 'Three homes, and eggs 15% faster.',
                     3 => 'Four homes, and eggs 30% faster.'],
    'silk_shelf' => [1 => 'Two homes for silkworm trays. Feed them Mulberry Leaves (harvest a mulberry tree for them); they leave empty Silk Cocoons for you to spin into thread.',
                     2 => 'Three homes, and cocoons 15% faster.',
                     3 => 'Four homes, and cocoons 30% faster.'],
    'tortoise_run' => [1 => 'One home for a tortoise. It grazes lettuce, spinach, kale or bok choy, sheds a Tortoise Scute very slowly, and adds curb appeal.',
                       2 => 'Two homes, and scutes 15% faster.',
                       3 => 'Three homes, and scutes 30% faster.'],
    'snail_jar' => [1 => 'Three homes for rescued snails. Pick slugs and snails off your beds by hand and now and then one asks to stay. They eat Food Scraps or lettuce and leave Snail Trail Glaze.',
                    2 => 'Three homes, and glaze 15% faster.',
                    3 => 'Three homes, and glaze 30% faster.'],   // v1.4.0
    'butterfly_bush' => [1 => 'Two homes for butterflies, no feeding. Flowers growing within 2 squares sometimes give +1 stem at harvest. Pleased butterflies leave a Wing Scale now and then.',
                         2 => 'Three homes, +1 stem 5% more often, and Wing Scales 15% faster.',
                         3 => 'Four homes, +1 stem 10% more often, and Wing Scales 30% faster.'],
];


/** The level of a building in a garden (0 = not built). */
function building_level(int $plotId, string $b): int
{
    static $cache = [];
    if (!isset($cache[$plotId])) {
        $cache[$plotId] = [];
        foreach (q('SELECT building, level FROM garden_buildings WHERE plot_id = ?', [$plotId])->fetchAll() as $r) $cache[$plotId][$r['building']] = max(1, (int)$r['level']);
    }
    return $cache[$plotId][$b] ?? 0;
}

/** v0.9.4: what a compost heap can make: output item slug => [name, bin level needed, setting with the scraps each takes (null = the level's Plain Compost rule)]. */
const HEAP_OUTPUTS = [
    'plain-compost' => ['Plain Compost', 1, null],
    'leaf-mould'    => ['Leaf Mould', 2, 'heap_scraps_leaf_mould'],
    'worm-castings' => ['Worm Castings', 2, 'heap_scraps_castings'],
    'rich-loam'     => ['Rich Loam', 3, 'heap_scraps_loam'],
];

/** v0.9.4: the heap output a bin row really makes (what it is set to, if its level allows it; else Plain Compost). */
function heap_output(array $row): string
{
    $out = (string)($row['heap_out'] ?? 'plain-compost');
    return isset(HEAP_OUTPUTS[$out]) && max(1, (int)($row['level'] ?? 1)) >= HEAP_OUTPUTS[$out][1] ? $out : 'plain-compost';
}

/** Scraps the heap needs per output at this bin level (v0.9.4: by output; Plain Compost keeps the old level rule). */
function heap_need(int $level, string $out = 'plain-compost'): int
{
    $set = HEAP_OUTPUTS[$out][2] ?? null;
    if ($set !== null) return max(1, (int)setting($set));
    return max(1, $level >= 2 ? (int)setting('compost_heap_scraps_2') : (int)setting('compost_heap_scraps'));
}

/** v0.7.95: garden waste goes on the compost heap (a harvest, a dug-up plant, a weeding). Quiet; returns a line when a compost is made. v0.9.4: $n heap points; the heap makes whatever it is set to. */
function heap_add(int $plotId, int $n = 1): string
{
    $lv = building_level($plotId, 'compost_bin');
    if ($lv < 1 || $n < 1) return '';
    $row = q_one("SELECT scraps, level, heap_out FROM garden_buildings WHERE plot_id = ? AND building = 'compost_bin'", [$plotId]);
    if (!$row) return '';
    $out = heap_output($row);
    $need = heap_need($lv, $out);
    $cap = $need * max(1, (int)setting('compost_heap_max'));
    $before = (int)$row['scraps'];
    if ($before >= $cap) return '';
    q("UPDATE garden_buildings SET scraps = CASE WHEN scraps + ? > ? THEN ? ELSE scraps + ? END WHERE plot_id = ? AND building = 'compost_bin'", [$n, $cap, $cap, $n, $plotId]);
    return intdiv($before + $n, $need) > intdiv($before, $need) ? '♻️ Your compost heap made another ' . HEAP_OUTPUTS[$out][0] . '.' : '';
}

/** v0.9.4: put Food Scraps from the satchel on this garden's heap by hand ($n = a number, or 'all'). Only what fits is taken. */
function add_food_scraps(array $u, int $plotId, int|string $n = 'all'): array
{
    $uid = (int)$u['id'];
    $row = q_one('SELECT gb.* FROM garden_buildings gb JOIN plots p ON p.id = gb.plot_id
                  WHERE gb.plot_id = ? AND gb.building = ? AND p.user_id = ?', [$plotId, 'compost_bin', $uid]);
    if (!$row) return [false, 'You need a Compost Bin in this garden.'];
    $scrapId = (int)q_val("SELECT id FROM items WHERE slug = 'food-scrap'");
    $have = $scrapId ? (int)q_val('SELECT qty FROM user_items WHERE user_id = ? AND item_id = ?', [$uid, $scrapId]) : 0;
    if ($have < 1) return [false, 'You have no Food Scraps. Eating raw crops leaves them.'];
    $out = heap_output($row);
    $need = heap_need(max(1, (int)$row['level']), $out);
    $room = $need * max(1, (int)setting('compost_heap_max')) - (int)$row['scraps'];
    if ($room < 1) return [false, 'The heap is full. Collect some compost first.'];
    $take = min($have, $room, $n === 'all' ? PHP_INT_MAX : max(1, (int)$n));
    db()->beginTransaction();
    if (!give_item($uid, $scrapId, -$take)) {
        db()->rollBack();
        return [false, 'You don’t have that many Food Scraps.'];
    }
    $line = heap_add($plotId, $take);
    db()->commit();
    $left = (int)q_val("SELECT scraps FROM garden_buildings WHERE plot_id = ? AND building = 'compost_bin'", [$plotId]);
    return [true, '♻️ You add ' . $take . ' Food Scrap' . ($take === 1 ? '' : 's') . ' to the heap (' . ($left % $need) . '/' . $need . ' towards the next ' . HEAP_OUTPUTS[$out][0] . ').' . ($line !== '' ? ' ' . $line : '')];
}

/** v0.9.4: choose what this garden's compost heap makes. Scraps already on the heap carry over. */
function set_heap_output(array $u, int $plotId, string $out): array
{
    $row = q_one('SELECT gb.* FROM garden_buildings gb JOIN plots p ON p.id = gb.plot_id
                  WHERE gb.plot_id = ? AND gb.building = ? AND p.user_id = ?', [$plotId, 'compost_bin', (int)$u['id']]);
    if (!$row) return [false, 'You need a Compost Bin in this garden.'];
    if (!isset(HEAP_OUTPUTS[$out])) return [false, 'The heap can’t make that.'];
    if (max(1, (int)$row['level']) < HEAP_OUTPUTS[$out][1]) return [false, 'Your Compost Bin needs to be level ' . HEAP_OUTPUTS[$out][1] . ' for ' . HEAP_OUTPUTS[$out][0] . '.'];
    q('UPDATE garden_buildings SET heap_out = ? WHERE id = ?', [$out, $row['id']]);
    return [true, '♻️ The heap will now make ' . HEAP_OUTPUTS[$out][0] . ' (' . heap_need(max(1, (int)$row['level']), $out) . ' scraps each).'];
}

/** What an upgrade to $to costs: [petals, [slug => qty], garden level needed]. */
function upgrade_cost(string $b, int $to): array
{
    $pct = array_map('intval', explode(',', (string)setting('upgrade_cost_percent'))) + [0 => 150, 1 => 300];
    $gap = array_map('intval', explode(',', (string)setting('upgrade_level_gap'))) + [0 => 2, 1 => 4];
    $mats = [];
    foreach (explode(',', (string)setting('upgrade_materials_' . $to)) as $pair) {
        [$s, $q] = array_map('trim', explode(':', $pair) + [1 => 0]);
        if ($s !== '' && (int)$q > 0) $mats[$s] = (int)$q;
    }
    $i = $to === 2 ? 0 : 1;
    return [intdiv(BUILDINGS[$b][3] * max(0, $pct[$i]), 100), $mats, BUILDINGS[$b][2] + max(0, $gap[$i])];
}

function upgrade_building(array $u, int $plotId, string $b): array
{
    $uid = (int)$u['id'];
    $plot = q_one('SELECT * FROM plots WHERE id = ? AND user_id = ?', [$plotId, $uid]);
    if (!$plot) return [false, 'That isn’t your garden.'];
    $row = q_one('SELECT * FROM garden_buildings WHERE plot_id = ? AND building = ?', [$plotId, $b]);
    if (!$row) return [false, 'You haven’t built that here.'];
    $to = max(1, (int)$row['level']) + 1;
    if (!isset(BUILDING_UPGRADES[$b][$to])) return [false, 'That can’t be upgraded any further.'];
    [$coins, $mats, $lvl] = upgrade_cost($b, $to);
    if ((int)$plot['garden_level'] < $lvl) return [false, 'That upgrade needs garden level ' . $lvl . '.'];
    db()->beginTransaction();
    if (q('UPDATE garden_buildings SET level = ? WHERE id = ? AND level = ?', [$to, $row['id'], $row['level']])->rowCount() !== 1) {
        db()->rollBack();
        return [false, 'Already upgraded.'];
    }
    if ($coins > 0 && q('UPDATE users SET coins = coins - ? WHERE id = ? AND coins >= ?', [$coins, $uid, $coins])->rowCount() !== 1) {
        db()->rollBack();
        return [false, 'That upgrade costs ' . money($coins) . '.'];
    }
    foreach ($mats as $slug => $qty) {
        $id = (int)q_val('SELECT id FROM items WHERE slug = ?', [$slug]);
        if (!$id || !give_item($uid, $id, -$qty)) {
            db()->rollBack();
            return [false, 'You need ' . upgrade_mats_text($mats) . ' for that.'];
        }
    }
    db()->commit();
    return [true, BUILDINGS[$b][1] . ' Your ' . BUILDINGS[$b][0] . ' is now level ' . $to . '! ' . BUILDING_UPGRADES[$b][$to]];
}

/** "6 × Dressed Stone, 6 × Timber Plank" */
function upgrade_mats_text(array $mats): string
{
    $out = [];
    foreach ($mats as $slug => $qty) $out[] = $qty . ' × ' . (q_val('SELECT name FROM items WHERE slug = ?', [$slug]) ?: $slug);
    return implode(', ', $out);
}

function user_gardens(int $uid): array
{
    return q('SELECT p.*, r.gnomish_name AS region, r.real_name AS region_real
              FROM plots p LEFT JOIN regions r ON r.id = p.region_id
              WHERE p.user_id = ? ORDER BY p.id', [$uid])->fetchAll();
}

/** The garden the gnome is currently tending. */
function active_plot_id(int $uid): int
{
    $id = (int)q_val('SELECT active_plot_id FROM users WHERE id = ?', [$uid]);
    if ($id && q_val('SELECT 1 FROM plots WHERE id = ? AND user_id = ?', [$id, $uid])) return $id;
    $id = (int)q_val('SELECT id FROM plots WHERE user_id = ? ORDER BY id LIMIT 1', [$uid]);
    if ($id) q('UPDATE users SET active_plot_id = ? WHERE id = ?', [$id, $uid]);
    return $id;
}

function max_gardens(array $u): int
{
    $n = 1;
    foreach (explode(',', setting('garden_unlock_levels')) as $lvl) {
        if (trim($lvl) !== '' && (int)$u['level'] >= (int)$lvl) $n++;
    }
    return $n;
}

function next_garden_level(array $u): ?int
{
    foreach (explode(',', setting('garden_unlock_levels')) as $lvl) {
        if (trim($lvl) !== '' && (int)$u['level'] < (int)$lvl) return (int)$lvl;
    }
    return null;
}

function deed_cost(int $uid): int
{
    return (int)setting('land_deed_cost') * max(1, (int)q_val('SELECT COUNT(*) FROM plots WHERE user_id = ?', [$uid]));
}

function has_building(int $plotId, string $b): bool
{
    return building_level($plotId, $b) > 0;
}

/** Region ids where a plant is "native" (any tier). */
function plant_regions_native(int $plantId): array
{
    static $cache = [];
    if (!isset($cache[$plantId])) {
        $cache[$plantId] = array_map('intval',
            q('SELECT DISTINCT region_id FROM plant_regions WHERE plant_id = ?', [$plantId])->fetchAll(PDO::FETCH_COLUMN));
    }
    return $cache[$plantId];
}

/** Garden-wide modifiers for this plot. */
function garden_mods(int $plotId): array
{
    static $cache = [];
    return $cache[$plotId] ??= [
        'region_id' => (int)q_val('SELECT region_id FROM plots WHERE id = ?', [$plotId]),
        'rain' => building_level($plotId, 'rain_barrel'),   // v0.7.96: levels
        'shed' => building_level($plotId, 'tool_shed'),
        'hive' => building_level($plotId, 'beehive'),   // v0.7.95: the hive's level (0 = none)
        'greenhouse' => building_level($plotId, 'greenhouse'),
    ];
}

/** Attach the garden modifiers a tile needs for growth/watering calculations. */
function annotate_tile(array $t, ?array $p): array
{
    $m = garden_mods((int)$t['plot_id']);
    $t['_native'] = $p && ($m['greenhouse']
        || ($m['region_id'] && in_array($m['region_id'], plant_regions_native((int)$p['id']), true)));
    $t['_need'] = $p ? (string)($p['nutrient'] ?? '') : '';
    // v0.7.65: unstudied crops grow slower; a finished Journey project can add to the native bonus
    static $owners = [];
    $oid = (int)($t['user_id'] ?? 0);
    if ($p && $oid) {
        $owners[$oid] ??= q_one('SELECT * FROM users WHERE id = ?', [$oid]) ?: [];
        require_once __DIR__ . '/garden_logic.php';
        $t['_unstudied'] = $owners[$oid] ? plant_unstudied($owners[$oid], $p) : false;
        if ($t['_unstudied']) $t['_unslow'] = unstudied_slow_pct($owners[$oid]);   // v0.9.1: Seedkeeper masters take half the slowdown
        $t['_sgrow'] = calling_perk($owners[$oid], 's_grade_growth');   // v0.9.1: Rootwarden master: S-grade beds grow faster
        if ($t['_native'] && $m['region_id']) {
            require_once __DIR__ . '/journey.php';
            $t['_nativeplus'] = (int)(journey_benefit($oid, 'native_plus', $m['region_id']) ?? 0);
        }
    }
    $t['_rain'] = $m['rain'];
    if (setting('climate_on') === '1') {   // v0.8.9: the region's climate
        require_once __DIR__ . '/climate.php';
        $t['_clim'] = climate_tile((int)$m['region_id'], $p, (bool)$m['greenhouse']);
    }
    $t['_shed'] = $m['shed'];
    $t['_hive'] = $m['hive'];
    // Placement bonuses from what's around the square in the yard (v0.7.34)
    $b = yard_tile_bonuses($t);
    foreach (['barrel', 'shade', 'hedge', 'birds', 'path'] as $k) $t['_' . $k] = isset($b[$k]);
    $t['_hivenear'] = isset($b['hive']);
    return $t;
}

function switch_garden(int $uid, int $plotId): bool
{
    return q('UPDATE users SET active_plot_id = ? WHERE id = ? AND EXISTS (SELECT 1 FROM plots WHERE id = ? AND user_id = ?)',
        [$plotId, $uid, $plotId, $uid])->rowCount() === 1;
}

function rename_garden(int $uid, int $plotId, string $name): array
{
    $name = trim(preg_replace('/\s+/', ' ', $name));
    if ($name === '' || mb_strlen($name) > 40) return [false, 'Garden names need 1–40 characters.'];
    require_once __DIR__ . '/moderation.php';
    if ($bad = text_problem(q_one('SELECT * FROM users WHERE id = ?', [$uid]) ?: [], $name)) return [false, $bad];
    q('UPDATE plots SET garden_name = ? WHERE id = ? AND user_id = ?', [$name, $plotId, $uid]);
    return [true, 'Garden renamed to “' . $name . '”.'];
}

/** Buy land in the village the gnome is standing in. */
function buy_land_deed(array $u, array $village): array
{
    $uid = (int)$u['id'];
    if ($village['kind'] !== 'village' || empty($village['region_id'])) return [false, 'You can only buy land in a village.'];
    $owned = (int)q_val('SELECT COUNT(*) FROM plots WHERE user_id = ?', [$uid]);
    if ($owned >= max_gardens($u)) {
        $next = next_garden_level($u);
        return [false, $next ? "You can tend another garden at gnome level $next." : 'You already tend as many gardens as a gnome can.'];
    }
    if (q_val('SELECT 1 FROM plots WHERE user_id = ? AND region_id = ?', [$uid, $village['region_id']])) {
        return [false, 'You already have a garden in this region.'];
    }
    $cost = deed_cost($uid);
    db()->beginTransaction();
    if (q('UPDATE users SET coins = coins - ? WHERE id = ? AND coins >= ?', [$cost, $uid, $cost])->rowCount() !== 1) {
        db()->rollBack();
        return [false, 'A land deed here costs ' . number_format($cost) . ' ' . setting('currency_name') . '.'];
    }
    $plotId = create_garden($uid, (int)$village['region_id'], (int)$village['id'], $village['name'] . ' Garden');
    q('UPDATE users SET active_plot_id = ? WHERE id = ?', [$plotId, $uid]);
    db()->commit();
    return [true, '📜 You buy a land deed in ' . $village['name'] . '! The local gardeners teach you how to grow their crops.'];
}

function build_building(array $u, int $plotId, string $b): array
{
    if (!isset(BUILDINGS[$b])) return [false, 'Unknown building.'];
    [$name, , $level, $cost] = BUILDINGS[$b];
    $plot = q_one('SELECT * FROM plots WHERE id = ? AND user_id = ?', [$plotId, $u['id']]);
    if (!$plot) return [false, 'That isn’t your garden.'];
    if ((int)$plot['garden_level'] < $level) return [false, "$name needs garden level $level" . garden_xp_hint($plot, $level) . '.'];   // v0.9.1a
    if (has_building($plotId, $b)) return [false, "This garden already has a $name."];
    if (critter_is_home($b) && (setting('animals_on') === '0' || animals120_blocked($b) || animals140_blocked($b))) return [false, 'Garden animals are resting for now.'];
    db()->beginTransaction();
    if (q('UPDATE users SET coins = coins - ? WHERE id = ? AND coins >= ?', [$cost, $u['id'], $cost])->rowCount() !== 1) {
        db()->rollBack();
        return [false, "A $name costs " . number_format($cost) . ' ' . setting('currency_name') . '.'];
    }
    db_insert('garden_buildings', ['plot_id' => $plotId, 'building' => $b, 'built_at' => now(), 'last_collect' => now()]);
    db()->commit();
    if (critter_is_home($b)) unlock_entries((int)$u['id'], 'critter:' . $b);   // v1.0.0: the animal's Almanac page
    return [true, BUILDINGS[$b][1] . " You build a $name!" . (critter_is_home($b) ? ' Now welcome someone to live there.' : '')];
}

/** How many items a producing building has ready (one a day, holds up to 5). */
function building_ready(array $row): int
{
    $since = time() - ts_gnome($row['last_collect'] ?? $row['built_at']);
    $cap = ($row['building'] ?? '') === 'beehive' && (int)($row['level'] ?? 1) >= 2 ? 10 : 5;   // v0.7.95: a level 2 hive holds 10
    return min($cap, intdiv(max(0, $since), 86400));
}

/** v0.7.95: compost the heap has made and not yet collected. */
function heap_ready(array $row): int
{
    if (($row['building'] ?? '') !== 'compost_bin') return 0;
    return min(max(1, (int)setting('compost_heap_max')), intdiv((int)($row['scraps'] ?? 0), heap_need(max(1, (int)($row['level'] ?? 1)), heap_output($row))));
}

function collect_building(array $u, int $plotId, string $b): array
{
    if (critter_is_home($b)) return critter_collect($u, $plotId, $b);   // v1.0.0: gifts from the garden animals
    if (!isset(BUILDING_PRODUCE[$b])) return [false, 'Nothing to collect from that.'];
    $row = q_one('SELECT gb.* FROM garden_buildings gb JOIN plots p ON p.id = gb.plot_id
                  WHERE gb.plot_id = ? AND gb.building = ? AND p.user_id = ?', [$plotId, $b, $u['id']]);
    if (!$row) return [false, 'You haven’t built that here.'];
    $n = building_ready($row);
    $heap = heap_ready($row);   // v0.7.95
    if ($n < 1 && $heap < 1) return [false, 'Nothing ready yet. Check back tomorrow.'];
    $uid = (int)$u['id'];
    $lv = max(1, (int)($row['level'] ?? 1));
    $item = fn(string $slug) => (int)q_val('SELECT id FROM items WHERE slug = ?', [$slug]);
    $name = fn(int $id) => (string)q_val('SELECT name FROM items WHERE id = ?', [$id]);
    db()->beginTransaction();
    $got = [];
    if ($n > 0) {
        $last = ts_gnome($row['last_collect']);
        $newLast = $n >= ($b === 'beehive' && $lv >= 2 ? 10 : 5) ? time() : $last + $n * 86400;
        if (q('UPDATE garden_buildings SET last_collect = ? WHERE id = ? AND last_collect = ?',
                [gmdate('Y-m-d H:i:s', $newLast), $row['id'], $row['last_collect']])->rowCount() !== 1) {
            db()->rollBack();
            return [false, 'Already collected.'];
        }
        $id = $item(BUILDING_PRODUCE[$b]);
        give_item($uid, $id, $n);
        $got[] = $n . ' × ' . $name($id);
        if ($b === 'beehive' && $lv >= 3 && ($wax = $item('beeswax'))) {   // a level 3 hive makes beeswax too
            give_item($uid, $wax, $n);
            $got[] = $n . ' × ' . $name($wax);
        }
    }
    if ($heap > 0) {
        $hout = heap_output($row);
        $need = heap_need($lv, $hout);
        if (q('UPDATE garden_buildings SET scraps = scraps - ?, heap_made = heap_made + ? WHERE id = ? AND scraps >= ?',
                [$heap * $need, $heap, $row['id'], $heap * $need])->rowCount() !== 1) {
            db()->rollBack();
            return [false, 'Already collected.'];
        }
        // v0.9.4: the heap makes whatever it is set to (the old "every 4th is Worm Castings" rule is the Worm Castings recipe now)
        $oid = $item($hout);
        if ($oid) { give_item($uid, $oid, $heap); $got[] = $heap . ' × ' . $name($oid) . ' from the heap'; }
    }
    db()->commit();
    return [true, BUILDINGS[$b][1] . ' You collect ' . implode(', ', $got) . '.'];
}

/**
 * v0.7.99: what a visitor sees when they tap a building in someone else's garden: [title, text lines]. Never anything private
 * (no Petals, no satchel): just the building's state today, with a little fun.
 */
function building_peek(array $plot, string $b): ?array
{
    if (!isset(BUILDINGS[$b])) return null;
    $row = q_one('SELECT * FROM garden_buildings WHERE plot_id = ? AND building = ?', [$plot['id'], $b]);
    if (!$row) return null;
    $lv = max(1, (int)$row['level']);
    $ownerId = (int)$plot['user_id'];
    [$name, $icon] = BUILDINGS[$b];
    $lines = [];
    switch ($b) {
        case 'kitchen':
            $dish = q_val('SELECT i.name FROM users u JOIN items i ON i.id = u.last_cooked_id WHERE u.id = ?', [$ownerId]);
            $cooking = q("SELECT i.name, p.ready_at FROM cook_pots p JOIN recipes r ON r.id = p.recipe_id JOIN items i ON i.id = r.output_item_id
                          WHERE p.user_id = ? AND p.collected_at IS NULL ORDER BY p.ready_at", [$ownerId])->fetchAll();   // v0.9.4: pots
            if ($cooking) {
                $done = count(array_filter($cooking, fn($c) => $c['ready_at'] <= now()));
                $lines[] = 'Something is bubbling away: ' . $cooking[0]['name'] . ($done === count($cooking) ? ', all done and waiting to be collected' : '') . '. '
                    . count($cooking) . ' pot' . (count($cooking) === 1 ? ' is' : 's are') . ' on the stove.';
            } else
            $lines[] = $dish
                ? 'You press your nose to the window… ' . ['', 'it smells of', 'it smells wonderfully of', 'a whole feast’s worth of'][$lv] . ' ' . $dish . '. Someone’s been busy.'
                : 'You press your nose to the window. It smells of… nothing at all. The pots are suspiciously clean.';
            if (!empty($row['pantry'])) $lines[] = '🫙 Through the pantry door: shelves of glass jars, gleaming in rows.';   // v0.9.8
            break;
        case 'beehive':
            $n = building_ready($row);
            $lines[] = $n ? 'The bees eye you suspiciously. ' . $n . ' jar' . ($n === 1 ? '' : 's') . ' of honey wait' . ($n === 1 ? 's' : '') . ' inside (not yours!).'
                : 'A busy, happy hum. The honey’s been collected recently.';
            if ($lv >= 3) $lines[] = 'A golden smell of beeswax drifts out.';
            break;
        case 'compost_bin':
            $need = heap_need($lv, heap_output($row));
            $lines[] = 'It smells… alive. The heap is ' . ((int)$row['scraps'] % $need) . ' of ' . $need . ' scraps along' . (heap_ready($row) ? ', with fresh compost ready to scoop' : '') . '.';
            if ($lv >= 3) $lines[] = 'Something wriggles happily inside. Worms!';
            break;
        case 'rain_barrel':
            $lines[] = ['', 'Half full of rainwater, with a leaf floating on top.', 'Brimming with rainwater.', 'Brimming. A frog lives in it now and won’t be moved.'][$lv];
            break;
        case 'greenhouse':
            $plant = q_val('SELECT p.name FROM plot_tiles t JOIN plants p ON p.id = t.plant_id WHERE t.plot_id = ? ORDER BY t.id LIMIT 1', [$plot['id']]);
            $lines[] = $plant ? 'Fogged-up glass. You can just make out some ' . $plant . ' inside.' : 'Clean glass and empty shelves, waiting for the next sowing.';
            break;
        case 'tool_shed':
            require_once __DIR__ . '/tools.php';
            $best = null;
            foreach (array_diff(array_keys(TOOL_TYPES), ['light', 'lantern', 'staff', 'walk', 'basket', 'soiltest']) as $type) {   // proper tools, not lanterns or staffs
                $t = best_tool($ownerId, $type);
                if ($t && (!$best || (int)$t['base_price'] > (int)$best['base_price'])) $best = $t;
            }
            $lines[] = $best ? 'Their best tool hangs by the door: a ' . $best['name'] . '.' : 'Neat rows of empty hooks.';
            require_once __DIR__ . '/hired_help.php';
            $n = count(current_hires((int)$plot['id']));
            if ($n) $lines[] = $n === 1 ? 'Someone’s staying here: a hired helper’s boots are by the step.' : $n . ' pairs of boots by the step. Busy shed!';
            break;
        case 'worm_farm':
        case 'ladybird_lodge':
        case 'frog_pond':   // v1.0.0: the animals
        case 'quail_coop':   // v1.2.0
        case 'silk_shelf':
        case 'tortoise_run':
        case 'butterfly_bush':   // v1.4.0
        case 'snail_jar':
            foreach (critter_peek_lines((int)$plot['id'], $b) as $cl) $lines[] = $cl;
            break;
        case 'root_cellar':
            require_once __DIR__ . '/garden_logic.php';
            $n = count(cellar_plants((int)$plot['id']));
            $lines[] = $n ? 'Something’s sleeping down there: ' . $n . ' perennial' . ($n === 1 ? ' is' : 's are') . ' tucked in for now.' : 'Cool and dark and empty. Smells of earth.';
            break;
    }
    return [$icon . ' ' . $name . (BUILDING_LEVEL_MARK[$lv] ?? ''), $lines];
}

/** v0.7.99: turn a neighbour's compost (once a Hollow day per garden): a scrap for their heap, a little XP for you. */
function turn_compost(array $u, int $plotId): array
{
    $plot = q_one('SELECT * FROM plots WHERE id = ?', [$plotId]);
    if (!$plot || !garden_visible($plot, $u)) return [false, 'You can’t visit that garden.'];
    if ((int)$plot['user_id'] === (int)$u['id']) return [false, 'That’s your own compost: every harvest turns it already.'];
    if (!building_level($plotId, 'compost_bin')) return [false, 'There’s no Compost Bin here.'];
    try {
        db_insert('compost_turns', ['user_id' => (int)$u['id'], 'plot_id' => $plotId, 'day' => hollow_date('Y-m-d'), 'at' => now()]);
    } catch (PDOException $e) {
        return [false, 'You’ve turned this compost today already. It needs a rest.'];
    }
    heap_add($plotId);
    add_xp((int)$u['id'], 3);
    require_once __DIR__ . '/trade.php';
    notify((int)$plot['user_id'], '🧑‍🌾 ' . gnome_name($u) . ' turned the compost in ' . ($plot['garden_name'] ?: 'your garden') . ' (+1 scrap).');
    return [true, '🧑‍🌾 You give the compost a good turn. It steams gratefully. +3 XP.'];
}

/** v0.7.99: collect every building in this garden that has something ready. */
function collect_all_buildings(array $u, int $plotId): array
{
    $msgs = [];
    foreach (q('SELECT * FROM garden_buildings WHERE plot_id = ?', [$plotId])->fetchAll() as $row) {
        if (critter_is_home((string)$row['building'])) {   // v1.0.0
            if (critter_ready($plotId, (string)$row['building']) < 1) continue;
            [$ok, $m] = critter_collect($u, $plotId, (string)$row['building']);
            if ($ok) $msgs[] = $m;
            continue;
        }
        if (!isset(BUILDING_PRODUCE[$row['building']]) || building_ready($row) + heap_ready($row) < 1) continue;
        [$ok, $m] = collect_building($u, $plotId, (string)$row['building']);
        if ($ok) $msgs[] = $m;
    }
    return $msgs ? [true, implode(' ', $msgs)] : [false, 'Nothing to collect yet.'];
}

require_once __DIR__ . '/pantry.php';   // v0.9.8: the Pantry (a Kitchen add-on)
