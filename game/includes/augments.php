<?php
declare(strict_types=1);
/**
 * 2.7.58 creature parts, phase 1: tool augments and kit mending.
 * An augment is a potions-table item (alchemy.php ALCHEMY_ITEMS, recipes in data/crafts.txt) fitted to a tool from the Satchel (tool_fit_aug).
 * It lives on the tool's user_items row (aug = slug, aug_left = uses or mends left, 0 with a permanent one), so two copies of a tool share one.
 * A broken tool's last copy hands it to the Broken row (tool_break) and the mend hands it back (mend_tool). One slot: fitting replaces.
 * Uses are spent only when the augment did something (a swap, a bonus item, a cheaper mend), so a miss costs nothing.
 */

/** slug => [label, family of the part a tier 3-4 tool also takes, uses (0 = permanent), gear it fits ('wear' any tool that wears, 'gather' a gathering tool), effect line] */
const AUG_DEFS = [
    'aug-hide-binding'   => ['Hide Binding', 'hide', 0, 'wear', 'Wear limit +25%.'],
    'aug-hide-binding-2' => ['Hide Binding II', 'hide', 0, 'wear', 'Wear limit +50%.'],
    'aug-plate-edge'     => ['Plate Edge', 'plate', 40, 'gather', '25% of finds are one rarity higher, even above what the tool could gather alone.'],
    'aug-wing-fletch'    => ['Wing Fletch', 'wing', 25, 'gather', '35% chance of one extra item per find.'],
    'aug-gem-charm'      => ['Gem Charm', 'gem', 30, 'gather', 'Luck +4 when the find is picked.'],
    'aug-ooze-salve'     => ['Ooze Salve', 'ooze', 3, 'wear', 'The next 3 mends that would cost Petals are free.'],
    'aug-silk-lashing'   => ['Silk Lashing', 'silk', 40, 'wear', 'A kit mend takes 1 fewer Tool Repair Kit (at least 1).'],
];
require_once __DIR__ . '/parts.php';

const AUG_GATHER_TYPES = ['forage', 'pick', 'net', 'bucket', 'axe', 'rod'];

/** A random whole number; tests that set $GLOBALS['aug_seeded'] get the seeded mt_rand instead. */
function aug_rand(int $a, int $b): int
{
    return !empty($GLOBALS['aug_seeded']) ? mt_rand($a, $b) : random_int($a, $b);
}

/** [label, part family, uses, gear, effect] for an augment slug, or null. */
function aug_def(?string $slug): ?array
{
    return $slug !== null && isset(AUG_DEFS[$slug]) ? AUG_DEFS[$slug] : null;
}

/** The augment on a tool item row of this gnome that still works: ['slug', 'left', 'def'], or null. */
function aug_on_item(int $uid, int $itemId): ?array
{
    $r = q_one('SELECT aug, aug_left FROM user_items WHERE user_id = ? AND item_id = ? AND qty > 0', [$uid, $itemId]);
    $def = $r ? aug_def((string)($r['aug'] ?? '')) : null;
    if (!$def || ($def[2] > 0 && (int)$r['aug_left'] < 1)) return null;
    return ['slug' => (string)$r['aug'], 'left' => (int)$r['aug_left'], 'def' => $def];
}

/** The augment on the gnome's best tool of a type, with 'item_id' of that tool; null when none or not the augment asked for ($only). */
function tool_aug(int $uid, string $type, ?string $only = null): ?array
{
    $best = best_tool($uid, $type);
    $a = $best ? aug_on_item($uid, (int)$best['id']) : null;
    if (!$a || ($only !== null && $a['slug'] !== $only)) return null;
    return $a + ['item_id' => (int)$best['id']];
}

/** Spend one use of the augment on a tool row. Gone at 0. Returns a short note when it wore out, else ''. */
function aug_spend(int $uid, int $itemId): string
{
    $a = aug_on_item($uid, $itemId);
    if (!$a || $a['def'][2] < 1) return '';
    q('UPDATE user_items SET aug_left = aug_left - 1 WHERE user_id = ? AND item_id = ? AND aug_left > 0', [$uid, $itemId]);
    if ($a['left'] > 1) return '';
    q('UPDATE user_items SET aug = NULL, aug_left = 0 WHERE user_id = ? AND item_id = ?', [$uid, $itemId]);
    return '🔩 Your ' . $a['def'][0] . ' wore out.';
}

/** Wear limit of a tool for this gnome: the tier's limit, longer with a Hide Binding. 0 = never wears. */
function tool_wear_limit_for(int $uid, array $tool): int
{
    $fx = json_decode((string)($tool['effects'] ?? ''), true) ?: [];
    $limit = tool_wear_limit((string)($fx['tool'] ?? ''), (int)($fx['tier'] ?? $fx['power'] ?? 1));
    if ($limit < 1 || $uid < 1) return $limit;
    $a = aug_on_item($uid, (int)($tool['id'] ?? 0));
    $pct = ['aug-hide-binding' => 25, 'aug-hide-binding-2' => 50][$a['slug'] ?? ''] ?? 0;
    return $pct ? (int)ceil($limit * (100 + $pct) / 100) : $limit;
}

/** Plate Edge: 25% of the time the find is one rarity higher (from the same tool's finds here; the tool's gate does not stop it, one step only). Spends a use only on a swap. Returns the pick (a swapped one, or the same); notes get a line to show. */
function aug_plate_edge(int $uid, array $pick, array $here, mixed $now, array &$notes): array
{
    $a = tool_aug($uid, (string)$pick['tool'], 'aug-plate-edge');
    $next = ['common' => 'uncommon', 'uncommon' => 'rare'][(string)$pick['rarity']] ?? null;
    if (!$a || $next === null || aug_rand(1, 100) > 25) return $pick;
    $up = array_values(array_filter($here, fn($g) => $g['tool'] === $pick['tool'] && $g['rarity'] === $next && road_cond_weight($g, $now) > 0));
    if (!$up) return $pick;
    $notes[] = '🔩 Plate Edge: a better find!';
    if ($w = aug_spend($uid, $a['item_id'])) $notes[] = $w;
    return $up[aug_rand(0, count($up) - 1)];
}

/** Gem Charm: Luck +4 for a gathering tool's finds, while it lasts. */
function aug_gem_luck(int $uid, string $type): int
{
    return tool_aug($uid, $type, 'aug-gem-charm') ? 4 : 0;
}

/** Wing Fletch: 35% chance of +1 item for this find; spends a use when it happens. */
function aug_wing_bonus(int $uid, string $type, array &$notes): int
{
    $a = tool_aug($uid, $type, 'aug-wing-fletch');
    if (!$a || aug_rand(1, 100) > 35) return 0;
    $notes[] = '🪶 Wing Fletch: +1';
    if ($w = aug_spend($uid, $a['item_id'])) $notes[] = $w;
    return 1;
}

/** Augment items the gnome holds that fit this tool: [[id, name, slug, qty], ...]. */
function aug_fits_owned(int $uid, array $tool): array
{
    $fx = json_decode((string)($tool['effects'] ?? ''), true) ?: [];
    $type = (string)($fx['tool'] ?? '');
    if (($tool['category'] ?? '') !== 'tool' || $type === '' || tool_wear_limit_for($uid, $tool) < 1) return [];
    $out = [];
    $ph = implode(',', array_fill(0, count(AUG_DEFS), '?'));
    foreach (q("SELECT i.id, i.name, i.slug, ui.qty FROM user_items ui JOIN items i ON i.id = ui.item_id WHERE ui.user_id = ? AND ui.qty > 0 AND i.slug IN ($ph) ORDER BY i.name",
        array_merge([$uid], array_keys(AUG_DEFS)))->fetchAll() as $r) {
        $gear = AUG_DEFS[$r['slug']][3];
        if ($gear === 'gather' && !in_array($type, AUG_GATHER_TYPES, true)) continue;
        $out[] = [(int)$r['id'], (string)$r['name'], (string)$r['slug'], (int)$r['qty']];
    }
    return $out;
}

/** The cheapest part of any family the gnome holds (a common one first; $rareOnly: only rare ones), as an item id, or 0. */
function aug_part_id(int $uid, bool $rareOnly): int
{
    $best = null;
    foreach (q("SELECT i.id, i.slug, i.rarity, i.base_price FROM user_items ui JOIN items i ON i.id = ui.item_id WHERE ui.user_id = ? AND ui.qty > 0 AND i.category = 'part'", [$uid])->fetchAll() as $r) {
        if (part_family((string)$r['slug'], 'part') === null) continue;
        $rare = part_is_rare($r);
        if ($rareOnly && !$rare) continue;
        $key = [$rare, (int)$r['base_price'], (int)$r['id']];
        if ($best === null || $key < $best[0]) $best = [$key, (int)$r['id']];
    }
    return $best ? $best[1] : 0;
}

/**
 * Fit an augment from the Satchel to a tool. One slot: it replaces what was there. A Fine or Masterwork tool (tier 3-4) also takes one rare part of the
 * augment's family. Returns [ok, message].
 */
function tool_fit_aug(int $uid, int $toolItemId, int $augItemId): array
{
    require_once __DIR__ . '/parts.php';
    $tool = q_one("SELECT i.* FROM user_items ui JOIN items i ON i.id = ui.item_id WHERE ui.user_id = ? AND ui.item_id = ? AND ui.qty > 0 AND i.category = 'tool'", [$uid, $toolItemId]);
    $aug = q_one('SELECT i.* FROM user_items ui JOIN items i ON i.id = ui.item_id WHERE ui.user_id = ? AND ui.item_id = ? AND ui.qty > 0', [$uid, $augItemId]);
    if (!$tool) return [false, 'You don’t have that tool.'];
    $def = $aug ? aug_def((string)$aug['slug']) : null;
    if (!$def) return [false, 'That doesn’t fit a tool.'];
    if (!in_array((int)$augItemId, array_column(aug_fits_owned($uid, $tool), 0), true)) return [false, 'A ' . $aug['name'] . ' doesn’t fit a ' . $tool['name'] . '.'];
    $fx = json_decode((string)$tool['effects'], true) ?: [];
    $tier = (int)($fx['tier'] ?? $fx['power'] ?? 1);
    db()->beginTransaction();
    $partId = 0;
    if ($tier >= 3) {
        foreach (part_family_items($def[1], true) as $it) {
            if ((int)q_val('SELECT qty FROM user_items WHERE user_id = ? AND item_id = ?', [$uid, $it['id']]) > 0) { $partId = $it['id']; break; }
        }
        if (!$partId) {
            db()->rollBack();
            return [false, 'A ' . $tool['name'] . ' also takes one rare ' . PART_FAMILIES[$def[1]][0] . ' part to fit a ' . $aug['name'] . '. You have none.'];
        }
        if (!give_item($uid, $partId, -1)) { db()->rollBack(); return [false, 'You don’t have that part.']; }
    }
    if (!give_item($uid, $augItemId, -1)) { db()->rollBack(); return [false, 'You don’t have that.']; }
    q('UPDATE user_items SET aug = ?, aug_left = ? WHERE user_id = ? AND item_id = ?', [$aug['slug'], $def[2], $uid, $toolItemId]);
    db()->commit();
    return [true, '🔩 Fitted ' . $def[0] . ' to your ' . $tool['name'] . '. ' . $def[4] . ($partId ? ' (Used one rare ' . PART_FAMILIES[$def[1]][0] . ' part.)' : '')];
}

/** Kits one mend takes for each tier 1-4 (setting tool_mend_kits). Muddled settings fall back to 1,2,4,8. */
function tool_mend_kit_list(): array
{
    return tool_wear_list('tool_mend_kits', [1, 2, 4, 8]);
}

/**
 * What a kit mend of this tool would take, or null when kits cannot mend it now (switched off for the tier, too few kits, or the part is missing).
 * ['kits' => n, 'part' => item id or 0, 'lashed' => bool (a Silk Lashing saved a kit)]. $augSlug: the augment on the tool, if any.
 */
function tool_mend_kit_plan(int $uid, array $tool, ?string $augSlug = null): ?array
{
    require_once __DIR__ . '/parts.php';
    $fx = json_decode((string)($tool['effects'] ?? ''), true) ?: [];
    $tier = max(1, min(4, (int)($fx['tier'] ?? $fx['power'] ?? 1)));
    $kits = tool_mend_kit_list()[$tier - 1];
    if ($kits < 1) return null;
    $kitId = item_id_by_slug('tool-repair-kit');
    if (!$kitId) return null;
    $lashed = $augSlug === 'aug-silk-lashing' && $kits > 1;
    if ($lashed) $kits--;
    if ((int)q_val('SELECT qty FROM user_items WHERE user_id = ? AND item_id = ?', [$uid, $kitId]) < $kits) return null;
    $part = 0;
    if ($tier >= 3) {
        $part = aug_part_id($uid, $tier >= 4);
        if (!$part) return null;
    }
    return ['kits' => $kits, 'part' => $part, 'lashed' => $lashed, 'kit_id' => $kitId];
}
