<?php
declare(strict_types=1);
/**
 * 2.7.58 creature parts, phase 0: families. A recipe ingredient `any-<family>` takes any 'part' item of that family
 * (cheapest first, a rare part only when no common one is left); `rare-<family>` takes only rare parts.
 * Only items.category = 'part' count: forage items such as stag-beetle-shell or dragonfly-wing end in the same words but are not parts.
 * Scope: crafts in the untimed categories (tools, garden, potions, building, decor). Cooking, pantry and pal jobs read the ingredient id directly and refuse an id of 0.
 */

/** family => [label, suffixes]; a slug is in a family when its last word is one of the suffixes. */
const PART_FAMILIES = [
    'hide'  => ['Hide',  ['pelt', 'skin', 'hide', 'fur', 'hair', 'wool', 'mane', 'tuft', 'fluff', 'whisker', 'fleece', 'bristle', 'ear', 'tail']],
    'plate' => ['Plate', ['shell', 'scale', 'scute', 'plate', 'husk', 'claw', 'horn', 'fang', 'tooth', 'pincer', 'spine', 'quill', 'stinger', 'talon', 'tine', 'chitin', 'leg']],
    'wing'  => ['Wing',  ['feather', 'plume', 'wing', 'down']],
    'ooze'  => ['Ooze',  ['slime', 'gland', 'sac', 'ink', 'dust']],
    'silk'  => ['Silk',  ['silk', 'thread', 'ball']],
    'gem'   => ['Gem',   ['pearl', 'bead']],
];
/** 2.7.58: the picture for an any-/rare- ingredient (no single item to show): one emoji per family. */
const PART_FAMILY_ICONS = ['hide' => '🐾', 'plate' => '🐚', 'wing' => '🪶', 'ooze' => '💧', 'silk' => '🕸️', 'gem' => '🦪'];
/** Part items that end in a family word but are a currency, not a creature part. */
const PART_FAMILY_DENY = ['tailors-thread'];
/** items.rarity at or above this is a rare part (the R tier, items.php). */
const PART_RARE_AT = 45;

/** The family key ('hide', 'plate', ...) of an item, or null. Only category 'part' matches. */
function part_family(string $slug, string $category): ?string
{
    if ($category !== 'part' || in_array($slug, PART_FAMILY_DENY, true)) return null;
    $last = substr($slug, ($p = strrpos($slug, '-')) === false ? 0 : $p + 1);
    foreach ([$last, rtrim($last, 's')] as $w) {   // the plural too: flea-legs, aphid-wings
        foreach (PART_FAMILIES as $fam => [, $suffixes]) if (in_array($w, $suffixes, true)) return $fam;
    }
    return null;
}

function part_is_rare(array $item): bool { return (int)($item['rarity'] ?? 0) >= PART_RARE_AT; }

/** Every item of a family (id, slug, name, rarity, base_price), common before rare, then cheapest first. $rareOnly: only the rare ones. */
function part_family_items(string $fam, bool $rareOnly = false): array
{
    if (!isset(PART_FAMILIES[$fam])) return [];
    $out = [];
    foreach (q("SELECT id, slug, name, rarity, base_price FROM items WHERE category = 'part'")->fetchAll() as $it) {
        if (part_family((string)$it['slug'], 'part') !== $fam) continue;
        if ($rareOnly && !part_is_rare($it)) continue;
        $out[] = ['id' => (int)$it['id'], 'slug' => (string)$it['slug'], 'name' => (string)$it['name'], 'rarity' => (int)$it['rarity'], 'base_price' => (int)$it['base_price']];
    }
    usort($out, fn($a, $b) => [part_is_rare($a), $a['base_price'], $a['id']] <=> [part_is_rare($b), $b['base_price'], $b['id']]);
    return $out;
}

/** ['any'|'rare', family] for an ingredient key such as any-hide / rare-plate, or null (a normal item slug, or an unknown family). */
function part_key(string $key): ?array
{
    if (!preg_match('/^(any|rare)-([a-z]+)$/', $key, $m) || !isset(PART_FAMILIES[$m[2]])) return null;
    return [$m[1], $m[2]];
}

/** "any Hide part" / "rare Plate part" for an ingredient key, or null for a normal slug. */
function part_ingredient_label(string $key): ?string
{
    $k = part_key($key);
    return $k ? $k[0] . ' ' . PART_FAMILIES[$k[1]][0] . ' part' : null;
}

/** craft_stock() entry for an any-/rare- key: id 0, have = the sum, any = [[item id, held], ...] cheapest first (only stacks held). Null when $key is not one. */
function part_stock(int $uid, string $key, int $qty): ?array
{
    $k = part_key($key);
    if (!$k) return null;
    $held = [];
    foreach (q('SELECT item_id, qty FROM user_items WHERE user_id = ? AND qty > 0', [$uid])->fetchAll() as $r) $held[(int)$r['item_id']] = (int)$r['qty'];
    $any = [];
    $have = 0;
    foreach (part_family_items($k[1], $k[0] === 'rare') as $it) if (!empty($held[$it['id']])) { $any[] = [$it['id'], $held[$it['id']]]; $have += $held[$it['id']]; }
    return ['id' => 0, 'name' => (string)part_ingredient_label($key), 'qty' => $qty, 'have' => $have, 'any' => $any];
}

/** True when the gnome has met any item of the family (collected_slugs), so an any-/rare- recipe can be discovered. */
function part_family_seen(array $key, array $seen): bool
{
    foreach (part_family_items($key[1], $key[0] === 'rare') as $it) if (isset($seen[$it['slug']])) return true;
    return false;
}

/** The family icon for an ingredient key such as any-hide / rare-plate, or null for a normal slug. */
function part_family_icon(string $key): ?string
{
    $k = part_key($key);
    return $k ? PART_FAMILY_ICONS[$k[1]] : null;
}
