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
 *
 * The 280 TAILOR wearables (design: claude/wear-pieces/, data: data/wear_items.txt + data/wear_items_pieces.txt, built by tools/build_wear_items.py):
 * 14 regions x footwear / backpack / coat / cloak x 5. Each is ONE piece (no cuts: only cut 'a'), ranks Common / Lined / Fine as above.
 * How a gnome gets one: made at the Tailor only (no shop), and only once the gnome has reached the item's region level (REGION_LEVELS) and owns a Tailor of
 * at least the item's Tailor level. A craft costs the Petal fee (the Common price), the energy and the region's two local materials (data/region_locals.txt).
 * Lining one also costs Petals: the step up to Lined x1.5 and to Fine x2.5 of the fee (0.5x and 1x more), paid on every attempt like the materials.
 * The piece row keeps the design's fx|a|b (the effect code and its numbers) as 'fx', 'fa', 'fb' for the engine. All wearable data: wear_defs().
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
 * 2.7.01 (Tailor sims, claude/sims-tailor-2.7.01.md): every Guard cut carries the Spiky knack (2 on the creature's bar when played). Plain Guard wearables were
 * played about 0.2 times a fight by the careless bot (no bar gain) and their value did not change that (base 3 -> 5 moved nothing); with Spiky 0.35, wins +0 to +0.8.
 */
const WEAR_DEFS = [
    'flood-boots' => ['name' => 'Flood Boots', 'icon' => '👢', 'get' => 'craft', 'mats' => ['rubber-sap' => 2, 'coir-fibre' => 2, 'cork-bark' => 1], 'energy' => 4,
        'desc' => 'Tall waxed boots that keep the water out. Carry them and flooded roads slow you half as much.',
        'cuts' => ['a' => ['Puddle Hop', 'guard', 3, 'evade', 'spiky', 'Its next Hurt misses and poison does nothing this round. Pricks the creature for 2.'], 'b' => ['Sure Foot', 'guard', 3, 'hold', 'spiky', 'Some of the guard is still there next turn. Pricks the creature for 2.']]],
    'wayfarers-hat' => ['name' => 'Wayfarer’s Hat', 'icon' => '🎩', 'get' => 'shop', 'price' => 300, 'level' => 5,
        'desc' => 'A wide brown felt hat with a feather. Pull the brim down and the next thing to hit you gets a prick for its trouble.',
        'cuts' => ['a' => ['Brim Down', 'guard', 2, 'thorns', 'spiky', 'Pricks the creature for 2, and a blocked hit pricks it back.'], 'b' => ['Tip Back', 'soothe', 3, '', '', 'Its next hits do less damage.']]],
    'work-gloves' => ['name' => 'Work Gloves', 'icon' => '🧤', 'get' => 'craft', 'mats' => ['coir-fibre' => 2, 'pine-resin' => 1, 'stag-beetle-shell' => 1], 'energy' => 4,
        'desc' => 'Thick tan gloves for thorns and stings.',
        'cuts' => ['a' => ['Firm Grip', 'hurt', 3, '', 'leech', 'Heals you a little each time it lands.'], 'b' => ['Knuckle Down', 'hurt', 3, 'bash', '', 'Your guard becomes damage.']]],
    'travel-cloak' => ['name' => 'Travel Cloak', 'icon' => '🧥', 'get' => 'craft', 'mats' => ['cottongrass' => 3, 'sphagnum' => 2], 'energy' => 4,
        'desc' => 'Wool against the wind, moss green with a wooden toggle.',
        'cuts' => ['a' => ['Wrap Up', 'guard', 3, 'mend', 'spiky', 'A block that also heals you a little. Pricks the creature for 2.'], 'b' => ['Hood Up', 'guard', 3, 'thorns', 'spiky', 'Pricks the creature for 2, and a blocked hit pricks it back.']]],
    'trail-pack' => ['name' => 'Trail Pack', 'icon' => '🎒', 'get' => 'shop', 'price' => 800, 'level' => 15,
        'desc' => 'A small canvas pack with a rolled blanket. There is always something at the bottom.',
        'cuts' => ['a' => ['Rummage', 'trick', 2, 'pluck', '', 'A small chance to lift something the creature carries.'], 'b' => ['Tidy Up', 'trick', 2, '', '', 'A plain set-up piece for combos.']]],
    'yarn-scarf' => ['name' => 'Yarn Scarf', 'icon' => '🧣', 'get' => 'catfish',
        'desc' => 'Knitted from Cat Fish yarn. In a fight it is a plain, dependable Charm.',
        'cuts' => ['a' => ['Yarn Wrap', 'charm', 3, '', '', 'A plain Charm.']]],
];

const WEAR_FEE_MULT = [1 => 1.0, 2 => 1.5, 3 => 2.5];   // Tailor wearables: the Petal price of each rank, times the Common fee
const WEAR_CAT_ICON = ['footwear' => '🥾', 'backpack' => '🎒', 'coat' => '🧥', 'cloak' => '🧣'];
const WEAR_CAT_NAME = ['footwear' => 'Footwear', 'backpack' => 'Backpack', 'coat' => 'Coat', 'cloak' => 'Cloak'];

/** Rows of a data file (data/<file>): cells of every line that is not empty or a # comment. */
function wear_data_lines(string $file): array
{
    $path = __DIR__ . '/data/' . $file; $out = [];
    if (!is_file($path)) return $out;
    foreach (file($path, FILE_IGNORE_NEW_LINES) as $line) {
        $line = trim($line);
        if ($line !== '' && $line[0] !== '#') $out[] = array_map('trim', explode('|', $line));
    }
    return $out;
}

/**
 * The 280 Tailor wearables: slug => a WEAR_DEFS-like entry with 'get' => 'tailor', one cut 'a' => [piece, type, v, tag, knack, words], and
 * 'region', 'cat', 'n', 'rarity' (the design's Common / Uncommon / Rare), 'petals' (Common fee), 'tailor' (Tailor level), 'energy', 'mats', 'knob', 'fx', 'fa', 'fb'.
 * A row with no piece row (or a bad one) is left out.
 */
function wear_tailor_defs(): array
{
    static $D = null;
    if ($D !== null) return $D;
    $P = [];
    foreach (wear_data_lines('wear_items_pieces.txt') as $r) if (count($r) >= 15 && $r[2] === 'wear') $P[$r[3]] = $r;
    $D = [];
    foreach (wear_data_lines('wear_items.txt') as $r) {
        if (count($r) < 11 || !isset($P[$r[0]])) continue;
        $p = $P[$r[0]]; $mats = [];
        foreach (explode(',', $r[9]) as $m) { $m = explode(':', trim($m)); if (count($m) === 2 && (int)$m[1] > 0) $mats[$m[0]] = (int)$m[1]; }
        $words = str_starts_with($p[10], $r[5] . ': ') ? substr($p[10], strlen($r[5]) + 2) : $p[10];
        $D[$r[0]] = ['name' => $r[5], 'icon' => WEAR_CAT_ICON[$r[2]] ?? '🧵', 'get' => 'tailor', 'desc' => $r[10], 'region' => $r[1], 'cat' => $r[2], 'n' => (int)$r[3], 'rarity' => $r[4],
            'petals' => (int)$r[6], 'tailor' => max(1, min(3, (int)$r[7])), 'energy' => (int)$r[8], 'mats' => $mats, 'knob' => explode('/', $p[6])[0],
            'fx' => $p[12], 'fa' => (int)$p[13], 'fb' => (int)$p[14],
            'cuts' => ['a' => [$p[1], $p[4], (int)$p[5], $p[7] === '-' ? '' : $p[7], $p[11] === '-' ? '' : $p[11], $words]]];
    }
    return $D;
}

/** Every wearable: the 6 of WEAR_DEFS and the 280 Tailor ones. */
function wear_defs(): array
{
    static $all = null;
    return $all ??= WEAR_DEFS + wear_tailor_defs();
}

/** The Petal price of a Tailor wearable at a rank (the Common fee x1, x1.5, x2.5). */
function wear_fee(array $d, int $rank): int { return (int)round((int)($d['petals'] ?? 0) * (WEAR_FEE_MULT[$rank] ?? 1)); }

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
    $D = wear_defs();
    if (!isset($D[$slug]) && str_ends_with($slug, '-b') && isset($D[substr($slug, 0, -2)])) { $cut = 'b'; $slug = substr($slug, 0, -2); }
    if (!isset($D[$slug]) || !isset($D[$slug]['cuts'][$cut])) return null;
    return [$slug, $cut, $rank];
}

/**
 * Every wearable item: slug => [name, description, base, cut, rank, rarity, price]. The 6 of WEAR_DEFS: 11 cuts x 3 ranks = 33 items; the 280 Tailor ones x 3 ranks = 840.
 * A Tailor wearable's base price (what shops reckon from) is half its Petal price at that rank, so selling one never pays back the fee.
 */
function wear_items(): array
{
    static $o = null;
    if ($o !== null) return $o;
    $o = [];
    foreach (wear_defs() as $base => $d) foreach ($d['cuts'] as $cut => $c) foreach ([1, 2, 3] as $rank) {
        $slug = wear_slug($base, $cut, $rank);
        $nm = $d['name'] . ($cut === 'b' ? ' (' . $c[0] . ')' : '') . ($rank > 1 ? ', ' . WEAR_RANK_NAME[$rank] : '');
        $price = ($d['get'] ?? '') === 'tailor' ? max(1, intdiv(wear_fee($d, $rank), 2)) : (int)($d['price'] ?? 120) * $rank;
        $o[$slug] = ['name' => $nm, 'desc' => $d['desc'] . ' Piece: ' . $c[0] . ', ' . ucfirst($c[1]) . ' ' . $c[2] . '. ' . $c[5], 'base' => $base, 'cut' => $cut, 'rank' => $rank,
            'rarity' => ($d['get'] ?? '') === 'tailor' ? (['Common' => 10, 'Uncommon' => 25, 'Rare' => 50][$d['rarity'] ?? 'Common'] ?? 10) + [1 => 0, 2 => 10, 3 => 20][$rank] : 6 + 6 * $rank,   // 2.7.xx: a Tailor wearable's rarity is its design's (Common / Uncommon / Rare = 10 / 25 / 50, +10 Lined, +20 Fine) so the shelf and the satchel show it; the old ones stay 12 / 18 / 24
            'price' => $price];
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
        [$base, $cut] = explode('|', $k); $d = wear_defs()[$base]; $c = $d['cuts'][$cut];
        $key = 'w:' . $base . ($cut === 'b' ? '-b' : '');   // the piece keeps its key when the wearable is lined or finished (its switch stays as the gnome set it)
        $row = ['key' => $key, 'k' => $key, 'n' => $c[0], 'src' => 'wear', 'ref' => $slug, 't' => $c[1], 'v' => $c[2], 'r' => $d['knob'] ?? 'body', 'tag' => $c[3], 'mod' => $c[4], 'rank' => $rank,
            'life' => 0, 'blurb' => $d['name'] . ': ' . $c[5]];
        if ($c[4] === '') unset($row['mod']);   // no knack: no 'mod' field at all
        if (isset($d['fx'])) { $row['fx'] = $d['fx']; $row['fa'] = $d['fa']; $row['fb'] = $d['fb']; }   // Tailor wearables: the effect code and its {a} {b} (the engine reads them)
        $out[] = $row;
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
    if (in_array($k, wear_lined_set($uid), true)) { q('DELETE FROM wear_lined WHERE user_id = ? AND wkey = ?', [$uid, $k]); return [true, '🧵 The ' . wear_defs()[$base]['name'] . ' is worn as Fine again.']; }
    db_insert('wear_lined', ['user_id' => $uid, 'wkey' => $k]);
    return [true, '🧵 The ' . wear_defs()[$base]['name'] . ' is worn as Lined now: not a Rare piece, a little weaker.'];
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
        $have = q('SELECT slug, rarity FROM items')->fetchAll(PDO::FETCH_KEY_PAIR);   // one query, not one per item (873 of them)
        foreach (wear_items() as $slug => $it) {
            if (isset($have[$slug])) {   // 2.7.xx: items made before the design rarity existed hold 6 + 6 x rank: bring them to the new value (an admin-edited value is left alone)
                if ((int)$have[$slug] !== (int)$it['rarity'] && (int)$have[$slug] === 6 + 6 * (int)$it['rank']) q('UPDATE items SET rarity = ? WHERE slug = ?', [(int)$it['rarity'], $slug]);
                continue;
            }
            db_insert('items', ['name' => $it['name'], 'slug' => $slug, 'category' => 'supply', 'rarity' => $it['rarity'], 'base_price' => $it['price'], 'description' => $it['desc'], 'edible' => 0, 'tradable' => 1]);
        }
        $shop = wear_live() ? (int)q_val("SELECT id FROM shops WHERE slug = 'twigg-s-seed-emporium'") : 0;   // the shop stocks them only while the setting is on   // the Hat and the Pack are sold at Twigg's (Common, first cut)
        foreach (WEAR_DEFS as $base => $d) {
            if (($d['get'] ?? '') !== 'shop' || !$shop) continue;
            $id = item_id_by_slug(wear_slug($base, 'a', 1)); $price = (int)$d['price'];
            if ($id && !q_val('SELECT 1 FROM shop_stock WHERE shop_id = ? AND item_id = ?', [$shop, $id])) db_insert('shop_stock', ['shop_id' => $shop, 'item_id' => $id, 'price_min' => $price, 'price_max' => (int)round($price * 1.1), 'max_stock' => 2, 'restock_chance' => 40, 'current_stock' => 1, 'current_price' => $price]);
        }
        if (wear_live()) wear_ensure_shops();   // 2.7.xx: each region's outfitter (the 20 wearables of that region)
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

/** Why a gnome cannot make this Tailor wearable yet (region level, Tailor level), or null. Not the materials, energy or Petals. */
function tailor_gate(array $u, array $d, ?array $levels = null): ?string
{
    $need = (int)(REGION_LEVELS[$d['region'] ?? ''] ?? 1);
    if ((int)($u['level'] ?? 1) < $need) return 'Reach level ' . $need . ' first (the region of this wearable).';
    $levels ??= tailor_levels((int)$u['id']);
    if ($levels === []) return 'You need a Tailor built in one of your gardens first.';
    if (max($levels) < (int)$d['tailor']) return 'That takes a level ' . (int)$d['tailor'] . ' Tailor.';
    return null;
}

/**
 * Make a wearable at the Tailor: Common, cut 'a' or 'b'. The 'craft' wearables (boots, gloves, cloak; the Hat and Pack are bought) and the 280 'tailor' ones
 * (one cut; tailor_gate; the Petal fee as well). A level 3 Tailor's free craft of the day saves the materials and energy, not a Petal fee. [ok, message]
 */
function tailor_craft(array $u, string $base, string $cut = 'a'): array
{
    $uid = (int)$u['id']; $d = wear_defs()[$base] ?? null;
    if (!$d || !in_array($d['get'] ?? '', ['craft', 'tailor'], true) || !isset($d['cuts'][$cut])) return [false, 'That is not something the Tailor makes.'];
    if (!tailor_has($uid)) return [false, 'You need a Tailor built in one of your gardens first.'];
    if ($d['get'] === 'tailor') return tailor_craft_regional($u, $base, $d);
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

/** A Tailor wearable (tailor_craft did the first checks). Everything is checked before anything is taken; the Petals are the claim. [ok, message] */
function tailor_craft_regional(array $u, string $base, array $d): array
{
    $uid = (int)$u['id'];
    $u = q_one('SELECT * FROM users WHERE id = ?', [$uid]) ?: $u;   // the level as it is now
    if (($why = tailor_gate($u, $d)) !== null) return [false, $why];
    wear_ensure_items();
    $fee = wear_fee($d, 1); $free = tailor_free_ready($uid);
    if (!$free) foreach ($d['mats'] as $s => $n) if (wear_qty($uid, $s) < $n) return [false, 'You need ' . wear_mats_text($d['mats']) . '.'];
    if ((int)q_val('SELECT coins FROM users WHERE id = ?', [$uid]) < $fee) return [false, 'The Tailor asks ' . $fee . ' Petals for that.'];
    if (!take_petals($uid, $fee, 'tailor fee')) return [false, 'The Tailor asks ' . $fee . ' Petals for that.'];
    $free = $free && tailor_free_take($uid);
    if (!$free) {
        if (!spend_energy($uid, (int)$d['energy'], 'craft')) { give_petals($uid, $fee, 'tailor fee back'); return [false, 'You need ' . (int)$d['energy'] . ' energy for that.']; }
        if (!wear_take($uid, $d['mats'])) { give_petals($uid, $fee, 'tailor fee back'); return [false, 'You need ' . wear_mats_text($d['mats']) . '.']; }
    }
    $slug = wear_slug($base, 'a', 1);
    give_item($uid, item_id_by_slug($slug), 1);
    $c = tailor_commission($uid, $slug);
    return [true, '🧵 You make ' . $d['name'] . ' (' . $d['cuts']['a'][0] . ') for ' . $fee . ' Petals.' . ($free ? ' Your level 3 Tailor saved you the materials and energy today.' : '') . ($c ? ' Commission: ' . $c . ' Petals.' : '')];
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
    $d = wear_defs()[$base];
    $fee = ($d['get'] ?? '') === 'tailor' ? wear_fee($d, $rank + 1) - wear_fee($d, $rank) : 0;   // a Tailor wearable: the Petals of the step up, every attempt
    if ($fee > 0 && !take_petals($uid, $fee, 'tailor lining')) return [false, 'The Tailor asks ' . $fee . ' Petals for that.'];
    if (!spend_energy($uid, 2, 'craft')) { if ($fee > 0) give_petals($uid, $fee, 'tailor lining back'); return [false, 'You need 2 energy for that.']; }
    wear_take($uid, $mats);
    $roll ??= fn(int $pct): bool => random_int(1, 100) <= $pct;
    $name = $d['name'];
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
    $d = wear_defs()[$base];
    if (count($d['cuts']) < 2) return [false, 'That has only one cut.'];
    if (!tailor_has($uid)) return [false, 'You need a Tailor built in one of your gardens first.'];
    $free = tailor_power($uid) >= 2 && max(tailor_levels($uid)) >= 2;   // a level 2 Tailor does it for nothing
    wear_ensure_items();
    if (!$free && wear_qty($uid, WEAR_THREAD) < 1) return [false, 'A re-cut takes 1 Tailor’s Thread (a level 2 Tailor needs none).'];
    if (!$free) give_item($uid, item_id_by_slug(WEAR_THREAD), -1);
    $to = $cut === 'a' ? 'b' : 'a';
    give_item($uid, item_id_by_slug($slug), -1);
    give_item($uid, item_id_by_slug(wear_slug($base, $to, $rank)), 1);
    return [true, '🧵 You re-cut the ' . $d['name'] . ': it is now ' . $d['cuts'][$to][0] . '.'];
}


// ---------------------------------------------------------------- the regional outfitters (2.7.xx)

/** Shop name per region (slug = <code>-outfitters), at the region's market place. */
const WEAR_SHOP_NAMES = ['NA' => 'Plaid & Pine Outfitters', 'CA' => 'Hilo & Hoja', 'NWE' => 'The Tweed Peg', 'CB' => 'The Salt Stitch', 'SE' => 'Sun & Thread', 'SA' => 'Llama & Loom Outfitters',
    'EE' => 'The Felted Fox', 'MENA' => 'Dune Drapers', 'EA' => 'The Indigo Needle', 'CSA' => 'Spicepeak Threads', 'SEA' => 'Batik & Bamboo', 'WCA' => 'The Strip-Weave Stall',
    'ESA' => 'Highland Hem', 'OC' => 'Reef & Flax Outfitters'];
const WEAR_SHOP_MARKUP = 1.25;   // the shop sells the Common rank for the Tailor's Petal fee x this (no Tailor, no materials, no energy); Lined and Fine still come from the Tailor
const WEAR_SHOP_STOCK = ['Common' => [3, 50, 2], 'Uncommon' => [2, 30, 1], 'Rare' => [1, 12, 0]];   // rarity => [max on the shelf, restock chance %, on the shelf at the start]

/** Price of a Tailor wearable's Common rank on the outfitter's shelf. */
function wear_shop_price(array $d): int { return max(50, (int)(round((int)$d['petals'] * WEAR_SHOP_MARKUP / 50) * 50)); }

/** Is this shop the wearables' outfitter, and may this gnome see it (the same switch as the wearables: puzzle combat v1)? */
function wear_shop_hidden(array $shop, array $u): bool
{
    return (string)($shop['shop_type'] ?? '') === 'outfitter' && !wear_live($u);
}

/** One outfitter per region: shop, three shifts of staff (like the seed markets), the region's 20 wearables on its shelves. Idempotent; adds missing stock too. */
function wear_ensure_shops(): void
{
    static $done = false;
    if ($done) return;
    $done = true;
    $first = ['Tansy', 'Quill', 'Hazel', 'Rowan', 'Sorrel', 'Thistle', 'Willow', 'Cricket', 'Maple', 'Nutmeg', 'Poppy', 'Reed', 'Sage', 'Tumble', 'Dew', 'Ember', 'Fern', 'Ginger'];
    $last = ['Stitchwell', 'Threadbare', 'Needleby', 'Hemsworth', 'Buttonwood', 'Spindlewick', 'Tuckaway', 'Seamsby', 'Warpfield', 'Weftley', 'Cuffington', 'Patchley', 'Fringeby', 'Loomsby'];
    $species = ['Hedgehog', 'Field mouse', 'Dormouse', 'Hare', 'Wren', 'Tortoise', 'Mole', 'Snail'];
    $moods = ['Cheerful', 'Fussy', 'Chatty', 'Generous', 'Proud', 'Dreamy', 'Curious', 'Shy'];
    $i = 0;
    foreach (WEAR_SHOP_NAMES as $code => $name) {
        $rslug = strtolower($code);
        $loc = (int)q_val('SELECT id FROM locations WHERE slug = ?', ['market-' . $rslug]);
        $i += 3;
        if (!$loc) continue;
        $slug = $rslug . '-outfitters';
        $shopId = (int)q_val('SELECT id FROM shops WHERE slug = ?', [$slug]);
        if (!$shopId) {
            $shopId = db_insert('shops', ['name' => $name, 'slug' => $slug, 'location_id' => $loc, 'shop_type' => 'outfitter', 'restock_minutes' => 60,
                'description' => 'Footwear, packs, coats and cloaks cut and sewn from this region\'s own cloth. Better ranks (Lined, Fine) are made at your Tailor.']);
            foreach ([[6, 14], [14, 22], [22, 6]] as $k => [$st, $en]) {
                $nm = $first[($i + $k * 5) % count($first)] . ' ' . $last[($i * 3 + $k) % count($last)];
                $ns = slugify($nm); if (q_val('SELECT 1 FROM npcs WHERE slug = ?', [$ns])) $ns .= '-' . $rslug;
                $nid = db_insert('npcs', ['name' => $nm, 'slug' => $ns, 'species' => $species[($i + $k) % count($species)], 'personality' => $moods[($i + $k) % count($moods)], 'home_location_id' => $loc,
                    'bio' => 'Works at ' . $name . ' and can tell a good seam from across the street.']);
                db_insert('npc_schedules', ['npc_id' => $nid, 'location_id' => $loc, 'shop_id' => $shopId, 'activity' => 'working', 'start_hour' => $st, 'end_hour' => $en]);
                db_insert('npc_schedules', ['npc_id' => $nid, 'location_id' => $loc, 'shop_id' => null, 'activity' => 'wandering', 'start_hour' => $en, 'end_hour' => ($en + 3) % 24]);
                db_insert('npc_schedules', ['npc_id' => $nid, 'location_id' => $loc, 'shop_id' => null, 'activity' => 'resting', 'start_hour' => ($en + 3) % 24, 'end_hour' => $st]);
            }
        }
        foreach (wear_tailor_defs() as $iSlug => $d) {
            if (($d['region'] ?? '') !== $code) continue;
            $id = item_id_by_slug($iSlug);
            if (!$id || q_val('SELECT 1 FROM shop_stock WHERE shop_id = ? AND item_id = ?', [$shopId, $id])) continue;
            [$max, $chance, $start] = WEAR_SHOP_STOCK[$d['rarity']] ?? [1, 10, 0]; $price = wear_shop_price($d);
            db_insert('shop_stock', ['shop_id' => $shopId, 'item_id' => $id, 'price_min' => $price, 'price_max' => (int)round($price * 1.1), 'max_stock' => $max, 'restock_chance' => $chance, 'current_stock' => $start, 'current_price' => $price]);
        }
    }
}

/** Why this gnome cannot buy this wearable item from a shelf yet (null = fine): the setting, and the level of its region (the Tailor's rule). */
function wear_shop_block(array $u, string $slug): ?string
{
    $p = wear_parse($slug);
    $d = $p ? (wear_defs()[$p[0]] ?? null) : null;
    if (!$d || ($d['get'] ?? '') !== 'tailor') return null;
    if (!wear_live($u)) return 'That is not on the shelf.';
    $need = (int)(REGION_LEVELS[$d['region'] ?? ''] ?? 1);
    return (int)($u['level'] ?? 1) < $need ? 'That needs gnome level ' . $need . ' (the level of its region).' : null;
}
