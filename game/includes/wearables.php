<?php
declare(strict_types=1);

/**
 * 2.7.00 WEARABLES: things a gnome wears that are also ONE puzzle piece, switched on in a Keepsake slot (includes/pfdeck.php: PFD_KEEP_SRC has 'wear').
 * Design: claude/proposal-wearables-2.7.00.md, claude/plan-tailor-2.7.00.md, claude/review-tailor-2.7.00.md and Josh's answers in claude/todo.md.
 *
 * Items: every wearable is an item per CUT (a or b: two pieces on the same art, chosen when it is made) and per RANK:
 *   slug         Common (cut a)         slug-b        Common (cut b)
 *   slug-lined   Lined  (+2)            slug-b-lined  slug-fine  slug-b-fine   Fine (+4, counts toward the deck's 3 Rare)
 * Rank comes from the TAILOR (a garden building, includes/gardens.php 'tailor'): the gnome needs one built in at least one garden; the Tailor POWER is the
 * sum of the levels of every Tailor they own; every point adds WEAR_UP_PER_POINT percent to the chance a lining attempt works (cap WEAR_UP_CAP).
 * A failed attempt gives a Thread; WEAR_PITY Threads make the next attempt a sure thing. Power above WEAR_POWER_CAP pays commission Petals instead.
 * Flood Boots are CARRIED: any pair in the satchel halves a flooded road's slowdown (includes/road_kinds.php).
 */

const WEAR_UP_BASE = 30;          // percent: a lining attempt with no Tailor power points
const WEAR_UP_PER_POINT = 8;      // percent for every point of Tailor power
const WEAR_UP_CAP = 78;           // percent
const WEAR_POWER_CAP = 6;         // points that still help the roll; each point above gives WEAR_COMMISSION_PER_POINT percent more commission
const WEAR_COMMISSION_PER_POINT = 5;
const WEAR_PITY = 5;              // Threads that guarantee the next attempt
const WEAR_THREAD = 'tailors-thread';
const WEAR_RANK_NAME = [1 => 'Common', 2 => 'Lined', 3 => 'Fine'];

/**
 * base slug => name, what it is, where a gnome gets it, the materials of the first craft (Tailor), and its cuts.
 * cut => [piece name, type, base value, tag ('' none), knack mod ('' none), what it does in words].
 * Every tag is one pf_apply reads for that type (guard: hold thorns evade mend; hurt: bash and the leech knack; trick: pluck; soothe, charm: none).
 */
const WEAR_DEFS = [
    'flood-boots' => ['name' => 'Flood Boots', 'icon' => '👢', 'get' => 'craft', 'mats' => ['rubber-sap' => 2, 'coir-fibre' => 2, 'cork-bark' => 1], 'energy' => 4,
        'desc' => 'Tall waxed boots that keep the water out. Carry them and flooded roads slow you half as much.',
        'cuts' => ['a' => ['Puddle Hop', 'guard', 3, 'evade', '', 'Its next Hurt misses completely.'], 'b' => ['Sure Foot', 'guard', 3, 'hold', '', 'Some of the guard is still there next turn.']]],
    'wayfarers-hat' => ['name' => 'Wayfarer’s Hat', 'icon' => '🎩', 'get' => 'shop', 'price' => 300, 'level' => 5,
        'desc' => 'A wide brown felt hat with a feather. Pull the brim down and the next thing to hit you gets a prick for its trouble.',
        'cuts' => ['a' => ['Brim Down', 'guard', 2, 'thorns', '', 'A blocked hit pricks the creature back.'], 'b' => ['Tip Back', 'soothe', 3, '', '', 'Its next hits do less damage.']]],
    'work-gloves' => ['name' => 'Work Gloves', 'icon' => '🧤', 'get' => 'craft', 'mats' => ['coir-fibre' => 2, 'pine-resin' => 1, 'stag-beetle-shell' => 1], 'energy' => 4,
        'desc' => 'Thick tan gloves for thorns and stings.',
        'cuts' => ['a' => ['Firm Grip', 'hurt', 3, '', 'leech', 'Heals you a little each time it lands.'], 'b' => ['Knuckle Down', 'hurt', 3, 'bash', '', 'Your guard becomes damage.']]],
    'travel-cloak' => ['name' => 'Travel Cloak', 'icon' => '🧥', 'get' => 'craft', 'mats' => ['cottongrass' => 3, 'sphagnum' => 2], 'energy' => 4,
        'desc' => 'Wool against the wind, moss green with a wooden toggle.',
        'cuts' => ['a' => ['Wrap Up', 'guard', 3, 'mend', '', 'A block that also heals you a little.'], 'b' => ['Hood Up', 'guard', 3, 'thorns', '', 'A blocked hit pricks the creature back.']]],
    'trail-pack' => ['name' => 'Trail Pack', 'icon' => '🎒', 'get' => 'shop', 'price' => 800, 'level' => 15,
        'desc' => 'A small canvas pack with a rolled blanket. There is always something at the bottom.',
        'cuts' => ['a' => ['Rummage', 'trick', 2, 'pluck', '', 'A small chance to lift something the creature carries.'], 'b' => ['Tidy Up', 'trick', 2, '', '', 'A plain set-up piece for combos.']]],
    'yarn-scarf' => ['name' => 'Yarn Scarf', 'icon' => '🧣', 'get' => 'catfish',
        'desc' => 'Knitted from Cat Fish yarn. In a fight it is a plain, dependable Charm.',
        'cuts' => ['a' => ['Yarn Wrap', 'charm', 3, '', '', 'A plain Charm.']]],
];

/** Item slug of a wearable: base, cut 'a' or 'b', rank 1 to 3. */
function wear_slug(string $base, string $cut = 'a', int $rank = 1): string
{
    return $base . ($cut === 'b' ? '-b' : '') . ($rank === 2 ? '-lined' : ($rank === 3 ? '-fine' : ''));
}

/** [base, cut, rank] of a wearable item slug, or null. */
function wear_parse(string $slug): ?array
{
    $rank = 1;
    if (str_ends_with($slug, '-lined')) { $rank = 2; $slug = substr($slug, 0, -6); }
    elseif (str_ends_with($slug, '-fine')) { $rank = 3; $slug = substr($slug, 0, -5); }
    $cut = 'a';
    if (!isset(WEAR_DEFS[$slug]) && str_ends_with($slug, '-b') && isset(WEAR_DEFS[substr($slug, 0, -2)])) { $cut = 'b'; $slug = substr($slug, 0, -2); }
    if (!isset(WEAR_DEFS[$slug]) || !isset(WEAR_DEFS[$slug]['cuts'][$cut])) return null;
    return [$slug, $cut, $rank];
}

/** Every wearable item: slug => [name, description, base, cut, rank, rarity, price]. 6 wearables, 11 cuts, 3 ranks = 33 items. */
function wear_items(): array
{
    $o = [];
    foreach (WEAR_DEFS as $base => $d) foreach ($d['cuts'] as $cut => $c) foreach ([1, 2, 3] as $rank) {
        $slug = wear_slug($base, $cut, $rank);
        $nm = $d['name'] . ($cut === 'b' ? ' (' . $c[0] . ')' : '') . ($rank > 1 ? ', ' . WEAR_RANK_NAME[$rank] : '');
        $o[$slug] = ['name' => $nm, 'desc' => $d['desc'] . ' Piece: ' . $c[0] . ', ' . ucfirst($c[1]) . ' ' . $c[2] . '. ' . $c[5], 'base' => $base, 'cut' => $cut, 'rank' => $rank,
            'rarity' => 6 + 6 * $rank, 'price' => (int)($d['price'] ?? 120) * $rank];
    }
    return $o;
}

/**
 * The piece rows of the wearables a gnome owns: $owned = [item slug => qty] (any wearable item). One row per wearable BASE (their best rank of that cut is worn:
 * two copies of the same cut are one piece; the two cuts are two pieces). Row: key w:<base>[-b] (the same at every rank), k, n, src 'wear', ref = the item slug, t, v, r 'body', tag, mod, rank.
 */
function wear_pieces(array $owned, array $lined = []): array
{
    $best = [];   // "base|cut" => [rank, slug]
    foreach ($owned as $slug => $qty) {
        if ((int)$qty < 1 || ($p = wear_parse((string)$slug)) === null) continue;
        [$base, $cut, $rank] = $p; $k = $base . '|' . $cut;
        if (!isset($best[$k]) || $rank > $best[$k][0]) $best[$k] = [$rank, (string)$slug];
    }
    foreach ($best as $k => [$rank, $slug]) {   // worn as Lined on purpose: a Fine piece counts as Lined (not a Rare piece)
        if ($rank === 3 && in_array($k, $lined, true)) { [$b, $c] = explode('|', $k); $best[$k] = [2, wear_slug($b, $c, 2)]; }
    }
    $out = [];
    foreach ($best as $k => [$rank, $slug]) {
        [$base, $cut] = explode('|', $k); $c = WEAR_DEFS[$base]['cuts'][$cut];
        $key = 'w:' . $base . ($cut === 'b' ? '-b' : '');   // the piece keeps its key when the wearable is lined or finished (its switch stays as the gnome set it)
        $out[] = ['key' => $key, 'k' => $key, 'n' => $c[0], 'src' => 'wear', 'ref' => $slug, 't' => $c[1], 'v' => $c[2], 'r' => 'body', 'tag' => $c[3], 'mod' => $c[4], 'rank' => $rank,
            'life' => 0, 'blurb' => WEAR_DEFS[$base]['name'] . ': ' . $c[5]];
        if ($c[4] === '') unset($out[count($out) - 1]['mod']);   // no knack: no 'mod' field at all
    }
    return $out;
}

// ---------------------------------------------------------------- the Tailor (a garden building)

/** Wearables are behind the same admin setting as the v1 Puzzle combat (pfight_v1: Off / Admins only): live for this gnome? $u null = the setting alone (is it on for anyone). */
function wear_live(?array $u = null): bool
{
    $v = (string)setting('pfight_v1');
    if ($v === '1') return true;
    return $v === 'admin' && ($u === null || ($u['role'] ?? '') === 'admin');
}

/** Tailor power of a list of Tailor levels (one per garden that has one): the sum. */
function tailor_power_of(array $levels): int { return (int)array_sum(array_map(fn($l) => max(0, min(3, (int)$l)), $levels)); }

/** The levels of every Tailor a gnome owns (one entry per garden with one). */
function tailor_levels(int $uid): array
{
    $o = [];
    foreach (q("SELECT gb.level FROM garden_buildings gb JOIN plots p ON p.id = gb.plot_id WHERE p.user_id = ? AND gb.building = 'tailor' ORDER BY gb.level DESC", [$uid])->fetchAll(PDO::FETCH_COLUMN) as $l) $o[] = max(1, min(3, (int)$l));
    return $o;
}

function tailor_power(int $uid): int { return tailor_power_of(tailor_levels($uid)); }

/** Percent chance one lining attempt works at this power. */
function tailor_chance(int $power): int { return min(WEAR_UP_CAP, WEAR_UP_BASE + WEAR_UP_PER_POINT * max(0, min(WEAR_POWER_CAP, $power))); }

/** Extra commission percent from the points above WEAR_POWER_CAP. */
function tailor_commission_pct(int $power): int { return max(0, $power - WEAR_POWER_CAP) * WEAR_COMMISSION_PER_POINT; }

/** Is a level 3 Tailor's free first craft of the game day still there? */
function tailor_free_ready(int $uid): bool
{
    require_once __DIR__ . '/games.php';
    return max(0, ...tailor_levels($uid)) >= 3 && !q_val("SELECT 1 FROM festival_flags WHERE festival = 'tailor-free' AND user_id = ? AND day = ?", [$uid, game_day()]);
}

/** Use up today's free craft (true only for the one request that gets it). */
function tailor_free_take(int $uid): bool
{
    if (!tailor_free_ready($uid)) return false;
    try { db_insert('festival_flags', ['festival' => 'tailor-free', 'user_id' => $uid, 'day' => game_day(), 'at' => date('Y-m-d H:i:s')]); return true; }
    catch (Throwable $e) { return false; }
}

/** Commission Petals for a finished job: the power over WEAR_POWER_CAP gives that many percent of the wearable's base price (at least 1). 0 with no extra power. */
function tailor_commission(int $uid, string $slug, ?int $power = null): int
{
    $pct = tailor_commission_pct($power ?? tailor_power($uid));
    if ($pct <= 0) return 0;
    $price = (int)q_val('SELECT base_price FROM items WHERE slug = ?', [$slug]);
    $n = max(1, (int)round($price * $pct / 100));
    return give_petals($uid, $n, 'tailor commission') ? $n : 0;
}

/** The table (schema.php) is there? */
function wear_lined_table(): bool { return true; }

/** ["base|cut", ...] the gnome wears as Lined. */
function wear_lined_set(int $uid): array
{
    if (!wear_lined_table()) return [];
    return q('SELECT wkey FROM wear_lined WHERE user_id = ?', [$uid])->fetchAll(PDO::FETCH_COLUMN) ?: [];
}

/** Switch "wear this Fine piece as Lined" on or off for a wearable you hold. [ok, message] */
function wear_lined_toggle(array $u, string $slug): array
{
    $uid = (int)$u['id']; $p = wear_parse($slug);
    if (!$p || wear_qty($uid, $slug) < 1) return [false, 'You do not have that.'];
    [$base, $cut, $rank] = $p;
    if ($rank !== 3) return [false, 'Only a Fine wearable can be worn as Lined.'];
    if (!wear_lined_table()) return [false, 'Not now.'];
    $k = $base . '|' . $cut;
    if (in_array($k, wear_lined_set($uid), true)) { q('DELETE FROM wear_lined WHERE user_id = ? AND wkey = ?', [$uid, $k]); return [true, '🧵 The ' . WEAR_DEFS[$base]['name'] . ' is worn as Fine again.']; }
    db_insert('wear_lined', ['user_id' => $uid, 'wkey' => $k]);
    return [true, '🧵 The ' . WEAR_DEFS[$base]['name'] . ' is worn as Lined now: not a Rare piece, a little weaker.'];
}

/** Does the gnome have a Tailor in at least one garden? */
function tailor_has(int $uid): bool { return tailor_levels($uid) !== []; }

// ---------------------------------------------------------------- items and the Tailor's work

/** The Tailor's Thread: what a failed lining attempt gives. WEAR_PITY of them make the next attempt a sure thing, and re-cutting a wearable costs one. */
const WEAR_THREAD_ITEM = ['Tailor’s Thread', 'part', 8, 5, 'A length of strong thread, left over from a lining that did not take. Five make the next lining a sure thing.'];

/** Make the wearable items and the Thread if missing. Safe to call often; an item an admin edited is left alone. */
function wear_ensure_items(): void
{
    static $done = false, $stocked = false;
    if ($done && ($stocked || !wear_live())) return;   // the items once; the shelf once the setting is on
    $done = true; $stocked = wear_live();
    try {
        foreach (wear_items() as $slug => $it) {
            if (item_id_by_slug($slug)) continue;
            db_insert('items', ['name' => $it['name'], 'slug' => $slug, 'category' => 'supply', 'rarity' => $it['rarity'], 'base_price' => $it['price'], 'description' => $it['desc'], 'edible' => 0, 'tradable' => 1]);
        }
        $shop = wear_live() ? (int)q_val("SELECT id FROM shops WHERE slug = 'twigg-s-seed-emporium'") : 0;   // the shop stocks them only while the setting is on   // the Hat and the Pack are sold at Twigg's (Common, first cut)
        foreach (WEAR_DEFS as $base => $d) {
            if (($d['get'] ?? '') !== 'shop' || !$shop) continue;
            $id = item_id_by_slug(wear_slug($base, 'a', 1)); $price = (int)$d['price'];
            if ($id && !q_val('SELECT 1 FROM shop_stock WHERE shop_id = ? AND item_id = ?', [$shop, $id])) db_insert('shop_stock', ['shop_id' => $shop, 'item_id' => $id, 'price_min' => $price, 'price_max' => (int)round($price * 1.1), 'max_stock' => 2, 'restock_chance' => 40, 'current_stock' => 1, 'current_price' => $price]);
        }
        if (!item_id_by_slug(WEAR_THREAD)) { [$n, $cat, $rar, $pr, $ds] = WEAR_THREAD_ITEM; db_insert('items', ['name' => $n, 'slug' => WEAR_THREAD, 'category' => $cat, 'rarity' => $rar, 'base_price' => $pr, 'description' => $ds, 'edible' => 0, 'tradable' => 1]); }
    } catch (Throwable $e) { error_log('wear_ensure_items: ' . $e->getMessage()); }
}

/** How many of an item (by slug) the gnome has. */
function wear_qty(int $uid, string $slug): int
{
    $id = item_id_by_slug($slug);
    return $id > 0 ? (int)q_val('SELECT qty FROM user_items WHERE user_id = ? AND item_id = ?', [$uid, $id]) : 0;
}

/** [item slug => qty] of every wearable item the gnome owns (any cut, any rank). */
function wear_owned(int $uid): array
{
    $o = [];
    foreach (q("SELECT i.slug, ui.qty FROM user_items ui JOIN items i ON i.id = ui.item_id WHERE ui.user_id = ? AND ui.qty > 0 AND i.category = 'supply'", [$uid])->fetchAll() as $r) if (wear_parse((string)$r['slug'])) $o[(string)$r['slug']] = (int)$r['qty'];
    return $o;
}

/** Does the gnome carry ANY Flood Boots (any cut, any rank)? The road effect works from the satchel. */
function wear_has_boots(int $uid): bool
{
    foreach (wear_owned($uid) as $slug => $q) if ((wear_parse($slug)[0] ?? '') === 'flood-boots') return true;
    return false;
}

/** Take the materials ([slug => qty]) if the gnome has all of them; false (nothing taken) if not. */
function wear_take(int $uid, array $mats): bool
{
    foreach ($mats as $slug => $n) if (wear_qty($uid, (string)$slug) < (int)$n) return false;
    foreach ($mats as $slug => $n) give_item($uid, item_id_by_slug((string)$slug), -(int)$n);
    return true;
}

function wear_mats_text(array $mats): string
{
    $o = []; foreach ($mats as $slug => $n) $o[] = $n . ' × ' . ((string)q_val('SELECT name FROM items WHERE slug = ?', [$slug]) ?: $slug);
    return implode(', ', $o);
}

/** The materials of a lining attempt from this rank (1 to Lined, 2 to Fine). */
function wear_line_mats(int $fromRank): array { return $fromRank === 1 ? ['cottongrass' => 2, 'butterfly-scales' => 1] : ['seed-pearl' => 1, 'snow-moth-dust' => 1]; }

/** Make a wearable at the Tailor: Common, cut 'a' or 'b'. Only the 'craft' wearables (boots, gloves, cloak); the Hat and Pack are bought. [ok, message] */
function tailor_craft(array $u, string $base, string $cut = 'a'): array
{
    $uid = (int)$u['id']; $d = WEAR_DEFS[$base] ?? null;
    if (!$d || ($d['get'] ?? '') !== 'craft' || !isset($d['cuts'][$cut])) return [false, 'That is not something the Tailor makes.'];
    if (!tailor_has($uid)) return [false, 'You need a Tailor built in one of your gardens first.'];
    wear_ensure_items();
    $free = tailor_free_take($uid);   // a level 3 Tailor: the first craft of the day costs nothing
    if (!$free) {
        foreach ($d['mats'] as $s => $n) if (wear_qty($uid, $s) < $n) return [false, 'You need ' . wear_mats_text($d['mats']) . '.'];
        if (!spend_energy($uid, (int)$d['energy'], 'craft')) return [false, 'You need ' . (int)$d['energy'] . ' energy for that.'];
        wear_take($uid, $d['mats']);
    }
    give_item($uid, item_id_by_slug(wear_slug($base, $cut, 1)), 1);
    $c = tailor_commission($uid, wear_slug($base, $cut, 1));
    return [true, '🧵 You make ' . $d['name'] . ' (' . $d['cuts'][$cut][0] . ').' . ($free ? ' Your level 3 Tailor made it for nothing today.' : '') . ($c ? ' Commission: ' . $c . ' Petals.' : '')];
}

/**
 * Line (Common to Lined) or finish (Lined to Fine) a wearable you hold: one attempt. The materials are used up either way; it works with the chance of
 * tailor_chance(power). A failed attempt gives a Thread. With $pity and WEAR_PITY Threads the attempt is a sure thing (the Threads are used up). [ok, message]
 */
function tailor_line(array $u, string $slug, bool $pity = false, ?callable $roll = null): array
{
    $uid = (int)$u['id']; $p = wear_parse($slug);
    if (!$p || wear_qty($uid, $slug) < 1) return [false, 'You do not have that.'];
    [$base, $cut, $rank] = $p;
    if ($rank >= 3) return [false, 'That is as fine as it gets.'];
    if (!tailor_has($uid)) return [false, 'You need a Tailor built in one of your gardens first.'];
    wear_ensure_items();
    $mats = wear_line_mats($rank);
    foreach ($mats as $s => $n) if (wear_qty($uid, $s) < $n) return [false, 'You need ' . wear_mats_text($mats) . '.'];
    $sure = $pity && wear_qty($uid, WEAR_THREAD) >= WEAR_PITY;
    if ($pity && !$sure) return [false, 'You need ' . WEAR_PITY . ' Tailor’s Thread for a sure thing.'];
    if (!spend_energy($uid, 2, 'craft')) return [false, 'You need 2 energy for that.'];
    wear_take($uid, $mats);
    $roll ??= fn(int $pct): bool => random_int(1, 100) <= $pct;
    $name = WEAR_DEFS[$base]['name'];
    if ($sure) { give_item($uid, item_id_by_slug(WEAR_THREAD), -WEAR_PITY); }
    if ($sure || $roll(tailor_chance(tailor_power($uid)))) {
        give_item($uid, item_id_by_slug($slug), -1);
        give_item($uid, item_id_by_slug(wear_slug($base, $cut, $rank + 1)), 1);
        $c = tailor_commission($uid, wear_slug($base, $cut, $rank + 1));
        return [true, '🧵 The ' . $name . ' comes out ' . WEAR_RANK_NAME[$rank + 1] . '!' . ($sure ? ' (a sure thing: ' . WEAR_PITY . ' Threads)' : '') . ($c ? ' Commission: ' . $c . ' Petals.' : '')];
    }
    give_item($uid, item_id_by_slug(WEAR_THREAD), 1);
    return [true, '🧵 The lining would not take this time. You keep a length of Tailor’s Thread (' . wear_qty($uid, WEAR_THREAD) . '/' . WEAR_PITY . ' for a sure thing).'];
}

/** Re-cut a wearable to its other cut, same rank (costs 1 Thread; a level 2 Tailor needs none). [ok, message] */
function tailor_recut(array $u, string $slug): array
{
    $uid = (int)$u['id']; $p = wear_parse($slug);
    if (!$p || wear_qty($uid, $slug) < 1) return [false, 'You do not have that.'];
    [$base, $cut, $rank] = $p;
    if (count(WEAR_DEFS[$base]['cuts']) < 2) return [false, 'That has only one cut.'];
    if (!tailor_has($uid)) return [false, 'You need a Tailor built in one of your gardens first.'];
    $free = tailor_power($uid) >= 2 && max(tailor_levels($uid)) >= 2;   // a level 2 Tailor does it for nothing
    wear_ensure_items();
    if (!$free && wear_qty($uid, WEAR_THREAD) < 1) return [false, 'A re-cut takes 1 Tailor’s Thread (a level 2 Tailor needs none).'];
    if (!$free) give_item($uid, item_id_by_slug(WEAR_THREAD), -1);
    $to = $cut === 'a' ? 'b' : 'a';
    give_item($uid, item_id_by_slug($slug), -1);
    give_item($uid, item_id_by_slug(wear_slug($base, $to, $rank)), 1);
    return [true, '🧵 You re-cut the ' . WEAR_DEFS[$base]['name'] . ': it is now ' . WEAR_DEFS[$base]['cuts'][$to][0] . '.'];
}
