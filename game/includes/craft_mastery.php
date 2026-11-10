<?php
declare(strict_types=1);

// Craft mastery (sleep-days decisions 19, 35-39; built 2026-11-10).
// Per recipe: user_recipes.made counts every make. Tiers at mastery_tiers (default 10,50,200): materials -10 / -25 / -50% (mastery_material_cuts),
// each ingredient never below 1 and never below 50% of the base.
// Per category: all makes of every recipe in the category. Tiers at category_mastery_tiers (default 100,500,2000), each tier:
// +5% yield (mastery_yield_pct), -5% energy (mastery_energy_pct), and on food and potions +5% buff time (mastery_buff_pct, see buff_minutes()).
// Bonuses are fixed by these caps (materials -50%, energy -15%, yield +15% at the defaults), so they cannot stack past the cap with calling_perk boons.

function craft_mastery_list(string $setting, array $default): array
{
    $m = array_values(array_filter(array_map('intval', explode(',', (string)setting($setting))), fn($n) => $n > 0));
    return $m ?: $default;
}

/** How many tiers a count reaches against a list of marks. */
function craft_mastery_tier_of(int $count, array $marks): int
{
    $t = 0;
    foreach ($marks as $i => $mark) if ($count >= $mark) $t = $i + 1;
    return $t;
}

function craft_mastery_recipe_tier(int $uid, int $recipeId): int
{
    if ($recipeId < 1) return 0;
    return craft_mastery_tier_of((int)q_val('SELECT made FROM user_recipes WHERE user_id = ? AND recipe_id = ?', [$uid, $recipeId]), craft_mastery_list('mastery_tiers', [10, 50, 200]));
}

function craft_mastery_category_count(int $uid, string $cat): int
{
    return (int)q_val('SELECT COALESCE(SUM(ur.made), 0) FROM user_recipes ur JOIN recipes r ON r.id = ur.recipe_id WHERE ur.user_id = ? AND r.category = ?', [$uid, $cat]);
}

function craft_mastery_category_tier(int $uid, string $cat): int
{
    return craft_mastery_tier_of(craft_mastery_category_count($uid, $cat), craft_mastery_list('category_mastery_tiers', [100, 500, 2000]));
}

/** Material cut in percent for this recipe tier (0 for tier 0). */
function craft_mastery_cut_pct(int $tier): int
{
    if ($tier < 1) return 0;
    $cuts = craft_mastery_list('mastery_material_cuts', [10, 25, 50]);
    return min(50, $cuts[min($tier, count($cuts)) - 1]);
}

/** The ingredient quantity per make after the recipe's mastery cut: never below 1, never below half the base. */
function craft_mastery_qty(int $base, int $tier): int
{
    $cut = craft_mastery_cut_pct($tier);
    if ($cut <= 0) return $base;
    return max(1, (int)ceil($base * (100 - $cut) / 100));
}

/** Energy for one make after the category tier (-5% a tier). A cost of 0 stays 0, anything else stays at least 1. */
function craft_mastery_energy(int $uid, string $cat, int $energy): int
{
    if ($energy <= 0 || $uid < 1) return $energy;
    $t = craft_mastery_category_tier($uid, $cat);
    if ($t < 1) return $energy;
    $per = max(0, (int)(setting('mastery_energy_pct') !== '' ? setting('mastery_energy_pct') : 5));
    return max(1, (int)round($energy * (100 - min(50, $per * $t)) / 100));
}

/** Units made for $made base units with the category's yield bonus (+5% a tier; the fraction is a chance of one more unit). */
function craft_mastery_yield(int $uid, string $cat, int $made): int
{
    $t = craft_mastery_category_tier($uid, $cat);
    if ($t < 1 || $made < 1) return $made;
    $per = max(0, (int)(setting('mastery_yield_pct') !== '' ? setting('mastery_yield_pct') : 5));
    $x = $made * $per * $t;   // percent of a unit
    return $made + intdiv($x, 100) + (mt_rand(1, 100) <= $x % 100 ? 1 : 0);
}

/** A card line: "Mastery: 7 / 10 for lighter materials" style progress for one recipe. */
function craft_mastery_line(int $uid, array $r): string
{
    $made = (int)q_val('SELECT made FROM user_recipes WHERE user_id = ? AND recipe_id = ?', [$uid, (int)$r['id']]);
    $marks = craft_mastery_list('mastery_tiers', [10, 50, 200]);
    $t = craft_mastery_tier_of($made, $marks);
    $next = $marks[$t] ?? null;
    $cut = craft_mastery_cut_pct($t);
    return 'Made ' . $made . ' times' . ($cut > 0 ? ' · materials −' . $cut . '%' : '') . ($next !== null ? ' · next lighter materials at ' . $next : ' · fully mastered');
}

/** The mastery category of a food or potion item (the recipe that makes it): cooking, pantry or potions; '' for anything else. */
function craft_mastery_item_category(int $itemId): string
{
    static $cache = [];
    if ($itemId < 1) return '';
    if (!array_key_exists($itemId, $cache)) {
        $c = q_val("SELECT category FROM recipes WHERE output_item_id = ? AND category IN ('cooking', 'pantry', 'potions') ORDER BY id LIMIT 1", [$itemId]);
        $cache[$itemId] = $c === false || $c === null ? '' : (string)$c;
    }
    return $cache[$itemId];
}

/** Percent added to a meal or potion buff's time from category mastery (+5% a tier, food and potions only). */
function craft_mastery_buff_pct(int $uid, int $itemId): int
{
    $cat = craft_mastery_item_category($itemId);
    if ($cat === '' || $uid < 1) return 0;
    $per = max(0, (int)(setting('mastery_buff_pct') !== '' ? setting('mastery_buff_pct') : 5));
    return min(50, $per * craft_mastery_category_tier($uid, $cat));
}
