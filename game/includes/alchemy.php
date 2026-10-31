<?php
declare(strict_types=1);
/**
 * Alchemy Table: the potions after the first Healing Potion (that one lives in pal_jobs.php).
 * Items are made here (adds only, safe to repeat), recipes come from data/crafts.txt (category potions).
 * Icons: assets/img/ph/<slug>.png; until art is installed they show 🧪 (NAME_EMOJI) or the soil emoji.
 *  - Healing tiers: heal a pal at home (pj_heal) and the gnome (My Gnome Health box, hp_use).
 *  - Drinks (edible): a timed buff through eat_item, so they take the meal-buff slot.
 *  - Lucky Draught: drink it, or pack one on a pal's gathering trip (+ALCHEMY_LUCK_PAL luck for that trip).
 *  - Garden Tonic: a soil improver; the garden 'soil' action reads its effects like compost.
 */

/** slug => [name, item category, rarity, price, edible, effects or null, description] */
const ALCHEMY_ITEMS = [
    'strong-healing-potion' => ['Strong Healing Potion', 'supply', 14, 130, 0, null,
        'A deep green tonic that fizzes. A pal drinks it for +24 HP; you get back three quarters of your health.'],
    'grand-healing-elixir' => ['Grand Healing Elixir', 'supply', 22, 400, 0, null,
        'Thick, golden and smells of mountain flowers. Heals a pal or you completely.'],
    'lucky-draught' => ['Lucky Draught', 'supply', 10, 70, 1, ['temp' => ['luck' => 6, 'minutes' => 90]],
        'Sparkly pink and slightly ticklish. Drink it for Luck +6, or pack one for a pal on a gathering trip (Luck +4 for the trip).'],
    'sages-draught' => ['Sage’s Draught', 'supply', 10, 70, 1, ['temp' => ['lore' => 4, 'sense' => 2, 'minutes' => 120]],
        'A bitter blue tea that makes old words easy to read. Lore +4, Sense +2.'],
    'stoneskin-brew' => ['Stoneskin Brew', 'supply', 10, 65, 1, ['temp' => ['hardiness' => 4, 'grit' => 2, 'minutes' => 90]],
        'Muddy, gritty and very good for you. Hardiness +4, Grit +2.'],
    'swiftfoot-elixir' => ['Swiftfoot Elixir', 'supply', 10, 70, 1, ['temp' => ['nimble' => 4, 'sense' => 2, 'minutes' => 90]],
        'Light as dragonfly wings, with a berry bite. Nimble +4, Sense +2.'],
    'garden-tonic' => ['Garden Tonic', 'soil', 6, 30, 0, ['fertility' => 10, 'n' => 10, 'p' => 10, 'k' => 10, 'life' => 4, 'minutes' => 5],
        'A green bottle of seaweed and meadow herbs. Pour it on a square: fertility +10, nitrogen, phosphorus and potassium +10 each, soil life +4, within 5 minutes.'],
];

/** Healing tiers, weakest first: slug => [pal HP (0 = full), gnome % of max (0 = the hp_potion_percent setting)]. */
const ALCHEMY_HEAL = [
    'healing-potion' => [12, 0],
    'strong-healing-potion' => [24, 75],
    'grand-healing-elixir' => [0, 100],
];

const ALCHEMY_LUCK = 'lucky-draught';
const ALCHEMY_LUCK_PAL = 4;

/** Make the potion items. Adds only; never changes one that exists (admin edits stand). Returns how many were added. */
function alchemy_ensure_items(): int
{
    $n = 0;
    foreach (ALCHEMY_ITEMS as $slug => [$name, $cat, $rarity, $price, $edible, $fx, $desc]) {
        if (q_val('SELECT 1 FROM items WHERE slug = ?', [$slug])) continue;
        db_insert('items', ['name' => $name, 'slug' => $slug, 'category' => $cat, 'rarity' => $rarity, 'base_price' => $price,
            'description' => $desc, 'edible' => $edible, 'effects' => $fx ? json_encode($fx) : null, 'tradable' => 1]);
        $n++;
    }
    return $n;
}

/** The healing tiers this gnome holds: slug => ['id', 'name', 'qty', 'pal' (HP, 0 = full), 'pct' (gnome %)]. Only tiers with qty > 0. */
function alchemy_heals(int $uid): array
{
    $ph = implode(',', array_fill(0, count(ALCHEMY_HEAL), '?'));
    $by = [];
    foreach (q("SELECT i.id, i.slug, i.name, ui.qty FROM user_items ui JOIN items i ON i.id = ui.item_id
                WHERE ui.user_id = ? AND ui.qty > 0 AND i.slug IN ($ph)", array_merge([$uid], array_keys(ALCHEMY_HEAL)))->fetchAll() as $r) $by[(string)$r['slug']] = $r;
    $out = [];
    foreach (ALCHEMY_HEAL as $slug => [$pal, $pct]) {
        if (!isset($by[$slug])) continue;
        $out[$slug] = ['id' => (int)$by[$slug]['id'], 'name' => (string)$by[$slug]['name'], 'qty' => (int)$by[$slug]['qty'], 'pal' => $pal, 'pct' => alchemy_gnome_pct($slug)];
    }
    return $out;
}

/** Percent of the gnome's max health a healing tier gives. */
function alchemy_gnome_pct(string $slug): int
{
    $pct = ALCHEMY_HEAL[$slug][1] ?? 0;
    if ($pct > 0) return $pct;
    require_once __DIR__ . '/health.php';
    return hp_pct('hp_potion_percent', 50);
}

/** HP a healing tier gives a pal with $max HP. */
function alchemy_pal_heal(string $slug, int $max): int
{
    $n = ALCHEMY_HEAL[$slug][0] ?? 0;
    return $n > 0 ? $n : $max;
}

/** "+24 HP" or "Full HP" for a pal button. */
function alchemy_pal_label(string $slug): string
{
    $n = ALCHEMY_HEAL[$slug][0] ?? 0;
    return $n > 0 ? '+' . $n . ' HP' : 'Full HP';
}

function alchemy_item_id(string $slug): int
{
    static $ids = [];
    return $ids[$slug] ??= (int)q_val('SELECT id FROM items WHERE slug = ?', [$slug]);
}

function alchemy_count(int $uid, string $slug): int
{
    $id = alchemy_item_id($slug);
    return $id ? (int)q_val('SELECT qty FROM user_items WHERE user_id = ? AND item_id = ?', [$uid, $id]) : 0;
}

/** Drink a boost potion (an edible ALCHEMY_ITEMS entry) from My Gnome. Returns [ok, message]. */
function alchemy_drink(array $u, int $itemId): array
{
    $slug = (string)q_val('SELECT slug FROM items WHERE id = ?', [$itemId]);
    if (empty(ALCHEMY_ITEMS[$slug][4])) return [false, 'That isn’t a potion you can drink.'];
    require_once __DIR__ . '/gnome.php';
    [$ok, $msgs] = eat_item($u, $itemId);
    return [$ok, implode(' ', $msgs)];
}

/** My Gnome: the boost potions and Garden Tonic this gnome holds, with Drink buttons ('' when none). Healing tiers live in the Health box. */
function alchemy_card_html(array $u): string
{
    require_once __DIR__ . '/crafting.php';   // buff_text
    $uid = (int)$u['id'];
    $slugs = array_keys(ALCHEMY_ITEMS);
    $ph = implode(',', array_fill(0, count($slugs), '?'));
    $rows = q("SELECT i.id, i.slug, i.name, i.effects, ui.qty FROM user_items ui JOIN items i ON i.id = ui.item_id
               WHERE ui.user_id = ? AND ui.qty > 0 AND i.slug IN ($ph) ORDER BY i.name", array_merge([$uid], $slugs))->fetchAll();
    $b = '';
    foreach ($rows as $r) {
        $slug = (string)$r['slug'];
        if (isset(ALCHEMY_HEAL[$slug])) continue;
        if (!empty(ALCHEMY_ITEMS[$slug][4])) {
            $b .= '<form method="post" class="inline">' . csrf_field() . '<input type="hidden" name="do" value="drink"><input type="hidden" name="item" value="' . (int)$r['id'] . '">'
                . '<button class="btn small">🧪 ' . e($r['name']) . ' ×' . (int)$r['qty'] . ' ' . e(buff_text((string)$r['effects'], $u)) . '</button></form> ';
        } elseif ($slug === 'garden-tonic') {
            $b .= '<a class="btn small alt" href="' . e(url('garden.php')) . '">🪴 Garden Tonic ×' . (int)$r['qty'] . ': pour it on a square</a> ';
        }
    }
    if ($b === '') return '';
    return '<section class="box hpcard" aria-label="Potions"><div class="hphead"><b>🧪 Potions</b></div>'
        . '<p class="help">A drink takes the place of your meal buff.</p><div class="hpuse">' . $b . '</div></section>';
}
