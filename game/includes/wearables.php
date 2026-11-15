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
 * two copies of the same cut are one piece; the two cuts are two pieces). Row: key w:<slug>, k, n, src 'wear', ref = the item slug, t, v, r 'body', tag, mod, rank.
 */
function wear_pieces(array $owned): array
{
    $best = [];   // "base|cut" => [rank, slug]
    foreach ($owned as $slug => $qty) {
        if ((int)$qty < 1 || ($p = wear_parse((string)$slug)) === null) continue;
        [$base, $cut, $rank] = $p; $k = $base . '|' . $cut;
        if (!isset($best[$k]) || $rank > $best[$k][0]) $best[$k] = [$rank, (string)$slug];
    }
    $out = [];
    foreach ($best as $k => [$rank, $slug]) {
        [$base, $cut] = explode('|', $k); $c = WEAR_DEFS[$base]['cuts'][$cut];
        $out[] = ['key' => 'w:' . $slug, 'k' => 'w:' . $slug, 'n' => $c[0], 'src' => 'wear', 'ref' => $slug, 't' => $c[1], 'v' => $c[2], 'r' => 'body', 'tag' => $c[3], 'mod' => $c[4], 'rank' => $rank,
            'life' => 0, 'blurb' => WEAR_DEFS[$base]['name'] . ': ' . $c[5]];
    }
    return $out;
}

// ---------------------------------------------------------------- the Tailor (a garden building)

/** Tailor power of a list of Tailor levels (one per garden that has one): the sum. */
function tailor_power_of(array $levels): int { return (int)array_sum(array_map(fn($l) => max(0, min(3, (int)$l)), $levels)); }

/** The levels of every Tailor a gnome owns (one entry per garden with one). */
function tailor_levels(int $uid): array
{
    require_once __DIR__ . '/gardens.php';
    $o = [];
    foreach (q('SELECT p.id FROM plots p WHERE p.user_id = ?', [$uid])->fetchAll(PDO::FETCH_COLUMN) as $pid) if (($l = building_level((int)$pid, 'tailor')) > 0) $o[] = $l;
    return $o;
}

function tailor_power(int $uid): int { return tailor_power_of(tailor_levels($uid)); }

/** Percent chance one lining attempt works at this power. */
function tailor_chance(int $power): int { return min(WEAR_UP_CAP, WEAR_UP_BASE + WEAR_UP_PER_POINT * max(0, min(WEAR_POWER_CAP, $power))); }

/** Extra commission percent from the points above WEAR_POWER_CAP. */
function tailor_commission_pct(int $power): int { return max(0, $power - WEAR_POWER_CAP) * WEAR_COMMISSION_PER_POINT; }

/** Does the gnome have a Tailor in at least one garden? */
function tailor_has(int $uid): bool { return tailor_levels($uid) !== []; }
