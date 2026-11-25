<?php
declare(strict_types=1);
/**
 * Puzzle combat, the v1 DECK MODEL (2.6.74, behind the admin setting pfight_v1; design: claude/design-deckbuilder-combat.md, handover: claude/handover-v1-stageB.md).
 *
 * Part 1 (pure, no DB: also used by the tests and the balance sims): the data files, the layered creature deck, the player's deck built from a "sources" array.
 *   Data: data/pf_pieces.txt (player pieces), pf_class_base.txt (class base 4 + size extras), pf_creature_class.txt (slug=Class), pf_creature_pieces.txt (3 unique each), pf_region_pieces.txt.
 *   Creature deck = 4 base (class) + region pieces (small / medium 1, large / boss 2) + size extras (large 1, boss 2) + 3 unique.
 *   Player deck = kit (starter 10 + what the gnome switched on) + fight-belt tool pieces + active party pals' pieces. No maximum; at most 3 Rare and 1 Masterwork.
 * Part 2 (DB): tables pf_decks, pf_deck_pieces, pf_belts, pf_tool_wear; pfd_sources / pfd_deck; starter, toggle, belt, wear and repair; the fight hookup; the POST actions (pfd_post).
 */
require_once __DIR__ . '/pfboard.php';

const PFD_FAM = ['body', 'mind', 'craft'];
const PFD_PLAYER_SRC = ['basic', 'knack', 'calling', 'tool', 'crop', 'craft', 'region', 'legend', 'wear'];
const PFD_LEGEND_HARVESTS = 3;                // 2.6.990: a legendary crop's piece is yours after you have harvested that crop this many times
const PFD_RANK_NAME = ['', 'Common', 'Uncommon', 'Rare', 'Masterwork'];
const PFD_RANK_BONUS = [0, 0, 2, 4, 5];       // value added by rank (I Common .. IV Masterwork)
const PFD_LARDER_SRC = ['crop', 'legend', 'food'];        // 2.6.989: the Larder holds crop (and, later, food) pieces ...
const PFD_KEEP_SRC = ['friend', 'gourmand', 'trophy', 'wear'];   // 2.7.00: wearables (includes/wearables.php) are Keepsakes too; 2.7.14: only a WORN wearable offers its piece   // ... the Keepsakes the friend, Gourmand and lair-trophy pieces (none exist yet)
/** Slots by gnome level: the Larder 3 (4 from level 10, 5 from level 20), the Keepsakes 1 (2 from level 15, 3 from level 25, 4 from level 40; Josh 2026-11-15). */
function pfd_slots(int $level): array { return ['larder' => $level >= 20 ? 5 : ($level >= 10 ? 4 : 3), 'keeps' => $level >= 40 ? 4 : ($level >= 25 ? 3 : ($level >= 15 ? 2 : 1))]; }
const PFD_RARE_CAP = 3, PFD_MW_CAP = 1;       // a deck holds at most 3 Rare and 1 Masterwork pieces (kit + gear)
const PFD_KIT_MIN = 8;                        // kit pieces (not counting gear) a deck needs
const PFD_CORE = ['swing', 'dodge', 'rest', 'charm'];   // the 4 fixed starter pieces
const PFD_PICKS = 6;                          // the starter: 4 core + 6 of the 12 offered
/** The 12 starter pieces offered (CALLING = the gnome's calling piece, Taunt without a calling; HOME = the home region's piece). A picked piece is owned from then on. */
const PFD_OFFER = ['CALLING', 'jab', 'snack', 'hide', 'brace', 'soothe', 'hum', 'pierce', 'swing#2', 'c:grain', 'c:herb', 'r:HOME'];
/** The one-tap kits (each 6 of the offer; with the core Swing every kit holds 4 Hurt: the offer has exactly 4, so a pick of 4 would leave no choice). */
const PFD_KITS = ['bold' => ['CALLING', 'jab', 'swing#2', 'pierce', 'snack', 'c:grain'], 'steady' => ['CALLING', 'jab', 'swing#2', 'pierce', 'brace', 'r:HOME'], 'kind' => ['CALLING', 'jab', 'swing#2', 'pierce', 'hum', 'soothe']];
/** 2.7.01: the starter box is the same for every gnome: the 4 core pieces + these 6 (no calling or home piece; 4 Hurt with the core Swing). Packed on the first visit; an admin reset packs it again. */
const PFD_STARTER_FIXED = ['jab', 'swing#2', 'pierce', 'snack', 'brace', 'soothe'];
const PFD_KIT_DEFAULT = 'bold';               // played while no starter is chosen yet (nothing is saved)
/** The fight belt: tier => [tool slots, item slug (null = every gnome has it), gnome level needed, price]. Bought only (Twigg's); the best belt the gnome owns and is old enough for counts. */
const PFD_BELTS = [1 => [2, null, 1, 0], 2 => [3, 'stitched-fight-belt', 8, 600], 3 => [4, 'masterwork-fight-belt', 18, 2500]];
const PFD_BELT_ITEMS = [
    'stitched-fight-belt' => ['Stitched Fight Belt', 600, 12, 'A wide belt with three loops. Three of your tools add their piece to your Puzzle box deck (two without it). Needs gnome level 8. It works from your satchel.'],
    'masterwork-fight-belt' => ['Masterwork Fight Belt', 2500, 30, 'Four loops, double stitched. Four of your tools add their piece to your Puzzle box deck. Needs gnome level 18. It works from your satchel.'],
];
const PFD_DUR_BASE = 20, PFD_DUR_RANK = 4;    // a fight tool's durability: 20, +4 per rank above Worn; its piece costs PFB_TOOL_WEAR (2) each time it is played
const PFD_REPAIR = 'tool-repair-kit';         // the crafted item that fixes a fight tool (recipe in data/crafts.txt)
const PFD_REPAIR_ITEM = ['Tool Repair Kit', 30, 6, 'Flint, resin and a twist of fibre. Fixes one fight tool on your Puzzle box belt: its piece is worn out by fights (2 each time it is played) and comes back at full strength. It also mends garden and gathering tools: a Tool Shed mend is free and used first, then kits, then Petals.'];
/** 2.7.08 counter pieces (claude/engine-2.7.08-notes.md "Counter piece per type"): one knack per creature class rule, data rows in pf_pieces.txt with ref LEVEL:CLASS. The class key (pfb_kind_of) => the words the Puzzle box uses. */
const PFD_COUNTER_CLASSES = ['critter' => 'Critters', 'bird' => 'Birds', 'beast' => 'Beasts', 'water' => 'Water creatures', 'plant' => 'Plants and Fungi', 'reptile' => 'Reptiles and Amphibians'];
/** Stat pieces (setting pfight_statpieces, data/pf_stat_pieces.txt): the stats that have pieces, and the point tiers a gnome's stat score unlocks them at (0 = every gnome). */
const PFD_STAT_STATS = ['nimble' => 'Nimble', 'lore' => 'Lore', 'luck' => 'Luck', 'sense' => 'Sense'];
const PFD_STAT_TIERS = [0, 10, 15, 20, 25, 30];
const PFD_PAL_KNOB = ['round' => 'body', 'tri' => 'body', 'keyhole' => 'mind', 'double' => 'mind', 'peg' => 'craft', 'hook' => 'craft'];
const PFD_FOE_TAGS = ['hurt' => ['pierce', 'poison', 'quick', 'trip', 'bash'], 'guard' => ['hold', 'thorns', 'evade'], 'trick' => ['quick', 'evade', 'bash', 'thorns', 'poison', 'trip', 'heal'], 'heal' => []];
const PFD_LAYERS = ['base' => 'Base (class)', 'reg' => 'Region', 'rar' => 'Size or boss', 'uni' => 'Unique'];

// ================================================================= Part 1: data (pure)

/** Every player piece of data/pf_pieces.txt: key => ['k', 'n', 'src', 'ref', 't', 'v', 'r' (knob family or null), 'col' / 'up' (only when authored), 'tag', 'life' (0 = default), 'rar' ('src' or 0-4), 'blurb']. */
function pfd_catalog(): array
{
    static $C = null;
    if ($C !== null) return $C;
    $C = [];
    foreach (pf_data_lines('pf_pieces.txt') as $r) {
        if (count($r) < 10) continue;
        $e = explode('/', $r[6]);
        $p = ['k' => $r[0], 'n' => $r[1], 'src' => $r[2], 'ref' => $r[3] === '-' ? '' : $r[3], 't' => $r[4], 'v' => (int)$r[5], 'r' => in_array($e[0], PFD_FAM, true) ? $e[0] : null,
            'tag' => $r[7] === '-' ? '' : $r[7], 'life' => $r[8] === '-' ? 0 : (int)$r[8], 'rar' => $r[9] === 'src' ? 'src' : (int)$r[9], 'blurb' => (string)($r[10] ?? '')];
        if (!empty($r[11]) && $r[11] !== '-') $p['mod'] = (string)$r[11];   // a built-in knack (PF_MODS)
        if (!empty($r[12]) && $r[12] !== '-') { $p['fx'] = (string)$r[12]; $p['fa'] = (int)($r[13] ?? 0); $p['fb'] = (int)($r[14] ?? 0); }   // 2.7.09 a wear piece's effect in a catalog row (fx|a|b, data/wear_fx.txt)
        if ($r[2] === 'knack' && str_contains($r[3], ':')) $p['cnt'] = explode(':', $r[3], 2)[1];   // 2.7.08 a counter knack: its creature class (pfb_kind)
        if (isset($e[1]) && in_array($e[1], PFD_FAM, true)) $p['col'] = $e[1];
        if (isset($e[2])) $p['up'] = $e[2] === 'up' ? 1 : 0;
        $C[$r[0]] = $p;
    }
    if (!$C) foreach (PF_TILES_BUILTIN as $k => $t) $C[$k] = ['k' => $k, 'n' => $t['n'], 'src' => in_array($k, PF_BASE_KEYS, true) || $k === 'breather' ? 'basic' : (in_array($k, PF_CALLING_TILE, true) ? 'calling' : 'knack'), 'ref' => '',
        't' => $t['t'], 'v' => $t['v'], 'r' => $t['r'], 'tag' => (string)($t['tag'] ?? ''), 'life' => 0, 'rar' => 0, 'blurb' => ''];   // no file: the old library, nothing else
    return $C;
}

/** The stat pieces of data/pf_stat_pieces.txt (file order): key => ['k', 'n', 'stat', 'tier', 't', 'v', 'vd', 'r' (knob family), 'col', 'tag', 'ab', 'live', 'fx', 'text']. Rows with an unknown stat, tier or type are left out. */
function pfd_stat_pieces(): array
{
    static $S = null;
    if ($S !== null) return $S;
    $S = [];
    foreach (pf_data_lines('pf_stat_pieces.txt') as $r) {
        if (count($r) < 13 || !isset(PFD_STAT_STATS[$r[2]]) || !in_array((int)$r[3], PFD_STAT_TIERS, true) || !isset(PF_HOLE[$r[4]])) continue;
        $e = explode('/', $r[7]);
        $S[$r[0]] = ['k' => $r[0], 'n' => $r[1], 'stat' => $r[2], 'tier' => (int)$r[3], 't' => $r[4], 'v' => (int)$r[5], 'vd' => max(0, (int)$r[6]),
            'r' => in_array($e[0], PFD_FAM, true) ? $e[0] : null, 'col' => in_array($e[1] ?? '', PFD_FAM, true) ? $e[1] : null, 'tag' => $r[8] === '-' ? '' : $r[8],
            'ab' => $r[9] === '-' ? '' : $r[9], 'live' => $r[10] === '1', 'fx' => $r[11] === '-' ? '' : $r[11], 'text' => $r[12]];
        if ($r[7] === 'any') $S[$r[0]]['edges'] = ['L' => ['any', null], 'R' => ['any', null], 'T' => ['any', null], 'B' => ['any', null]];   // Knot of Twine: four sides of the edge kind any (pfb_joint)
    }
    return $S;
}

/** A stat piece's numbers from the gnome's points in its stat: a = 1 + points / 5, b = ceil(a / 2). */
function pfd_stat_ab(int $pts): array
{
    $a = 1 + intdiv(max(0, $pts), 5);
    return [$a, intdiv($a + 1, 2)];
}

/** The stat modifier of a stat score (stat_mod in gnome.php, kept here so the deck model stays pure). */
function pfd_stat_mod(int $v): int { return intdiv($v - 10 - ($v < 10 ? 1 : 0), 2); }

/** The deck entry fields of a stat piece for a gnome with $pts points in its stat: the base number (v + points / vd), a, b, the rules text with them put in, its fx code (only when live). */
function pfd_stat_entry(array $p, int $pts): array
{
    [$a, $b] = pfd_stat_ab($pts);
    $x = ['k' => $p['k'], 'n' => $p['n'], 'src' => 'stat', 'ref' => $p['stat'] . ':' . $p['tier'], 't' => $p['t'], 'v' => $p['v'] + ($p['vd'] > 0 ? intdiv(max(0, $pts), $p['vd']) : 0), 'r' => $p['r'],
        'tag' => $p['tag'], 'life' => 0, 'rar' => 0, 'blurb' => strtr($p['text'], ['{a}' => (string)$a, '{b}' => (string)$b]), 'st' => $p['stat'], 'sm' => pfd_stat_mod($pts), 'fa' => $a, 'fb' => $b, 'ik' => $p['k']];   // ik: the key of its drawn icon (assets/img/pfight/pieces/ico-<k>[-s].png)
    if ($p['col'] !== null) $x['col'] = $p['col'];
    if (isset($p['edges'])) $x['edges'] = $p['edges'];   // authored edges (Knot of Twine: any)
    if ($p['live'] && $p['fx'] !== '') $x['fx'] = 'S:' . $p['k'];
    return $x;
}

/** A creature piece row of a data file: [name, type, v_mult, knob, tag, life]. */
function pfd_foe_cells(array $c): array
{
    return ['n' => (string)$c[0], 't' => (string)$c[1], 'm' => (float)$c[2], 'r' => in_array($c[3] ?? '', PFD_FAM, true) ? $c[3] : null, 'tag' => ($c[4] ?? '-') === '-' ? '' : (string)$c[4], 'life' => max(PFB_LIFE_MIN, min(PFB_LIFE_MAX, (int)($c[5] ?? 3) ?: 3))];
}

/** data/pf_class_base.txt: ['classes' => [Class => ['lean' => family, 'P' => [piece, x4]]], 'extra' => ['large' => [...], 'boss' => [...]]]. */
function pfd_classes(): array
{
    static $C = null;
    if ($C !== null) return $C;
    $C = ['classes' => [], 'extra' => ['small' => [], 'medium' => [], 'large' => [], 'boss' => []]];
    foreach (pf_data_lines('pf_class_base.txt') as $r) {
        if ($r[0] !== '' && $r[0][0] === '=') { $C['classes'][substr($r[0], 1)]['lean'] = (string)($r[1] ?? ''); continue; }
        if (count($r) < 7) continue;
        if ($r[0][0] === '@') $C['extra'][substr($r[0], 1)][] = pfd_foe_cells(array_slice($r, 1));
        else $C['classes'][$r[0]]['P'][] = pfd_foe_cells(array_slice($r, 1));
    }
    foreach ($C['classes'] as $k => $c) $C['classes'][$k] += ['lean' => pfb_lean(['class' => $k]), 'P' => []];
    return $C;
}

/** data/pf_creature_class.txt: slug => Class. 2.7.01: a variant of data/pf_creatures.txt has the class of its family's base. */
function pfd_class_map(bool $reload = false): array
{
    static $M = null;
    if ($M !== null && !$reload) return $M;
    $M = [];
    foreach (pf_data_lines('pf_creature_class.txt') as $r) { $p = explode('=', $r[0], 2); if (count($p) === 2) $M[trim($p[0])] = trim($p[1]); }
    foreach (pfd_creature_rows($reload) as $slug => $r) if (!isset($M[$slug]) && isset($M[$r['family']])) $M[$slug] = $M[$r['family']];
    return $M;
}

/** The file of the creature pass (tests point $GLOBALS['PF_CREATURES_FILE'] at a fixture). */
function pfd_creature_path(): string { return (string)($GLOBALS['PF_CREATURES_FILE'] ?? (__DIR__ . '/data/pf_creatures.txt')); }

/**
 * data/pf_creatures.txt (2.7.01, claude/creature-pass/SPEC.md sec 1): slug => the row's cells, parsed. The old data/creatures.txt rows are never touched; this file adds the variants and gives every row
 * (base too) its ability, ai style, regions, petals and exp. Keys: slug, family, base (bool: a base row), name, size, lands, regions (list; ['*'] = every region), level, cond, ab (ability ids), abp (id => overrides),
 * ai (style id), aip (style overrides), deck (null = the base's own), lean (''), drops, petals [min, max], expm, art, desc, new_items (list). A line with fewer than 17 cells is skipped.
 */
function pfd_creature_rows(bool $reload = false): array
{
    static $R = null, $path = null;
    $now = pfd_creature_path();
    if ($R !== null && !$reload && $path === $now) return $R;
    $R = []; $path = $now;
    if (!is_file($now)) return $R;
    foreach (file($now, FILE_IGNORE_NEW_LINES) as $line) {
        $line = trim($line);
        if ($line === '' || $line[0] === '#') continue;
        $c = array_map('trim', explode('|', $line));
        if (count($c) < 17 || $c[0] === '') continue;
        $ab = pfb_ab_parse($c[8]);
        $ai = $c[9]; $aip = [];
        if (preg_match('/^([^(]+)\((.*)\)$/', $ai, $m)) { $ai = trim($m[1]); foreach (explode(';', $m[2]) as $kv) { $kv = explode('=', $kv, 2); if (count($kv) === 2 && is_numeric(trim($kv[1]))) $aip[trim($kv[0])] = (float)trim($kv[1]); } }
        $deck = null; $lean = '';
        if ($c[10] !== '=' && $c[10] !== '' && $c[10] !== '-') {
            $dp = explode('/', $c[10], 3);
            if (count($dp) === 3) {
                $lean = in_array($dp[1], PFD_FAM, true) ? $dp[1] : '';
                $deck = [];
                foreach (explode(';', $dp[2]) as $pc) { $pc = trim($pc); if ($pc === '') continue; $q = explode(':', $pc); if (count($q) >= 6) $deck[] = pfd_foe_cells(array_map('trim', $q)); }
            }
        }
        $pt = array_map('intval', explode('-', $c[12] . '-' . $c[12]));
        $R[$c[0]] = ['slug' => $c[0], 'family' => $c[1] !== '' ? $c[1] : $c[0], 'base' => $c[2] === '=', 'name' => $c[2] === '=' ? null : $c[2], 'size' => $c[3] === '=' ? null : $c[3], 'lands' => $c[4] === '=' ? null : $c[4],
            'regions' => ($c[5] === '*' || $c[5] === '') ? ['*'] : array_values(array_filter(array_map('trim', explode(',', $c[5])))), 'level' => $c[6] === '=' ? null : (int)$c[6], 'cond' => $c[7],
            'ab' => $ab['ids'], 'abp' => $ab['p'], 'ai' => $ai, 'aip' => $aip, 'deck' => $deck, 'lean' => $lean, 'drops' => $c[11], 'petals' => [$pt[0], max($pt[0], $pt[1])],
            'expm' => is_numeric($c[13]) ? (float)$c[13] : 1.0, 'art' => $c[14], 'desc' => $c[15] === '=' ? null : $c[15], 'new_items' => $c[16] === '-' || $c[16] === '' ? [] : array_values(array_filter(array_map('trim', explode(',', $c[16]))))];
    }
    return $R;
}

/** The creature row with what data/pf_creatures.txt adds: family, regions, ab / abp (abilities), ai / aip (style), petals, expm, and a cond when the row has none. A creature the file does not list is returned as it is. */
function pfd_creature_overlay(array $c): array
{
    $r = pfd_creature_rows()[(string)($c['slug'] ?? '')] ?? null;
    if (!$r) return $c;
    if (empty($c['cond']) && $r['cond'] !== '' && $r['cond'] !== '-' && $r['cond'] !== '=') $c['cond'] = $r['cond'];
    return ['family' => $r['family'], 'regions' => $r['regions'], 'ab' => $r['ab'], 'abp' => $r['abp'], 'ai' => $r['ai'], 'aip' => $r['aip'], 'petals' => $r['petals'], 'expm' => $r['expm']] + $c;
}

/** Does this creature turn up in this region? '' = no region given (everything fits); a creature the file does not list, or with regions '*', fits everywhere. */
function pfd_creature_in_region(string $slug, string $region): bool
{
    if ($region === '') return true;
    $r = pfd_creature_rows()[$slug] ?? null;
    return !$r || in_array('*', $r['regions'], true) || in_array($region, $r['regions'], true);
}

/** The class of a creature (its row's 'class', else the class file, else Beast). */
function pfd_class(array $c): string
{
    $cl = (string)($c['class'] ?? pfd_class_map()[(string)($c['slug'] ?? '')] ?? '');
    return isset(pfd_classes()['classes'][$cl]) ? $cl : 'Beast';
}

/** data/pf_creature_pieces.txt: slug => ['lean' => family, 'P' => [piece, x3]]. */
function pfd_uniques(bool $reload = false): array
{
    static $U = null;
    if ($U !== null && !$reload) return $U;
    $U = [];
    foreach (pf_data_lines('pf_creature_pieces.txt') as $r) {
        if (count($r) < 8) continue;
        $U[$r[0]]['lean'] = $r[1]; $U[$r[0]]['P'][] = pfd_foe_cells(array_slice($r, 2));
    }
    foreach (pfd_creature_rows($reload) as $slug => $r) if ($r['deck'] && !isset($U[$slug])) $U[$slug] = ['lean' => $r['lean'], 'P' => $r['deck']];   // 2.7.01: the unique 3 of a variant (a base row's deck is `=`: its pieces stay in pf_creature_pieces.txt)
    return $U;
}

/**
 * The unique 3 of a creature (its own row), or, for a lair guardian (slug `boss-...`, made by ensure_lair_bosses, so it has none), those of a boss that has them:
 * a boss of the same landscape if there is one, picked by the guardian's slug so it is always the same. Null for any other creature without. (2.7.05)
 */
function pfd_unique_of(array $c): ?array
{
    $slug = (string)($c['slug'] ?? ''); $U = pfd_uniques();
    if (isset($U[$slug])) return $U[$slug];
    if (!str_starts_with($slug, 'boss-')) return null;
    static $pool = null;
    if ($pool === null) {
        $pool = [];
        try { foreach (q("SELECT slug, landscapes FROM creatures WHERE size = 'boss' AND slug NOT LIKE 'boss-%' ORDER BY slug")->fetchAll() as $r) if (isset($U[$r['slug']])) $pool[] = [(string)$r['slug'], (string)$r['landscapes']]; } catch (Throwable $e) { $pool = []; }
    }
    if (!$pool) return null;
    $ls = array_map('trim', explode(',', (string)($c['landscapes'] ?? '')));
    $near = array_values(array_filter($pool, fn($x) => array_intersect($ls, array_map('trim', explode(',', $x[1])))));
    $pick = $near ?: $pool;
    return $U[$pick[crc32($slug) % count($pick)][0]] ?? null;
}

/** data/pf_region_pieces.txt: region code => ['hurt' => piece, 'other' => piece]. */
function pfd_region_pieces(): array
{
    static $R = null;
    if ($R !== null) return $R;
    $R = [];
    foreach (pf_data_lines('pf_region_pieces.txt') as $r) if (count($r) >= 8 && in_array($r[1], ['hurt', 'other'], true)) $R[$r[0]][$r[1]] = pfd_foe_cells(array_slice($r, 2));
    return $R;
}

/** data/pf_creature_names.txt (slug|class or size piece name|this creature's name for it): slug => [generic name => own name]. A creature the file does not list keeps the generic names. */
function pfd_creature_names(): array
{
    static $N = null;
    if ($N !== null) return $N;
    $N = [];
    foreach (pf_data_lines('pf_creature_names.txt') as $r) if (count($r) >= 3 && $r[0] !== '' && $r[1] !== '' && $r[2] !== '') $N[$r[0]][$r[1]] = $r[2];
    return $N;
}

// ----------------------------------------------------------------- the creature's layered deck

/** The archetype value of a creature ($v in pf_foe_deck): its piece values are multiples of this. */
function pfd_foe_v(array $c): int
{
    return max(1, (int)pf_round((((int)($c['dmg_die'] ?? 4) + 1) / 2 + (int)($c['dmg_bonus'] ?? 0)) * (($c['size'] ?? '') === 'boss' ? PF_FOE_BOSS : PF_FOE_DMG)));
}

/** 2.7.44: the key of a creature piece's hand-drawn icon (assets/img/pfight/pieces/ico-<key>.png and -s.png), or '' when that piece has none (the type emoji stays). */
function pfd_piece_icon_key(string $slug, string $name): string
{
    static $c = [];
    $k = trim((string)preg_replace('/[^a-z0-9]+/', '-', strtolower($slug . ' ' . $name)), '-');
    if (!isset($c[$k])) $c[$k] = $k !== '' && is_file(__DIR__ . '/../assets/img/pfight/pieces/ico-' . $k . '-s.png') ? $k : '';
    return $c[$k];
}

/**
 * The creature's pieces by layer, in layer order: [['k', 'n', 't', 'v', 'r', 'tag', 'life', 'col', 'layer'], ...] (values before the board factors).
 * $region = the region code the fight is in ('' or unknown: no region piece). The class lean is the column family of 3 pieces in 5 (in this order); the others stack in their type family.
 */
function pfd_foe_pieces(array $c, string $region = ''): array
{
    $size = (string)($c['size'] ?? 'small'); $big = $size === 'large' || $size === 'boss'; $v = pfd_foe_v($c);
    $cl = pfd_class($c); $K = pfd_classes(); $slug = (string)($c['slug'] ?? ''); $u = pfd_unique_of($c);
    $lean = in_array($u['lean'] ?? '', PFD_FAM, true) ? $u['lean'] : $K['classes'][$cl]['lean'];
    $out = []; $n = [];
    $ikSlug = isset(pfd_uniques()[$slug]) ? $slug : '';   // 2.7.44: a creature's own 3 pieces carry the key of their hand-drawn icon (assets/img/pfight/pieces/ico-<ik>[-s].png); a lair guardian borrowing a boss's pieces keeps the type emoji
    $add = function (string $layer, array $q) use (&$out, &$n, $v, $lean, $ikSlug) {
        $i = count($out); $n[$layer] = ($n[$layer] ?? -1) + 1;
        $out[] = ['k' => 'f:' . ['base' => 'b', 'reg' => 'g', 'rar' => 'x', 'uni' => 'u'][$layer] . $n[$layer], 'n' => $q['n'], 't' => $q['t'], 'v' => max(1, (int)pf_round($q['m'] * $v)), 'r' => $q['r'], 'tag' => $q['tag'], 'life' => $q['life'],
            'ik' => $layer === 'uni' && $ikSlug !== '' ? pfd_piece_icon_key($ikSlug, (string)$q['n']) : '',
            'col' => $i % 5 < 3 ? $lean : (PF_HOLE[$q['t']] ?? 'body'), 'layer' => $layer];
    };
    $own = pfd_creature_names()[$slug] ?? [];   // this creature's own names for the class and size pieces (type, value, knob and tag stay)
    foreach ($K['classes'][$cl]['P'] as $q) $add('base', isset($own[$q['n']]) ? ['n' => $own[$q['n']]] + $q : $q);
    $rg = pfd_region_pieces()[$region] ?? null;
    if ($rg) { if ($big && isset($rg['hurt'])) $add('reg', $rg['hurt']); if (isset($rg['other'])) $add('reg', $rg['other']); }
    foreach ($K['extra'][$size] ?? [] as $q) $add('rar', isset($own[$q['n']]) ? ['n' => $own[$q['n']]] + $q : $q);
    foreach ($u['P'] ?? [] as $q) $add('uni', $q);
    return $out;
}

/** The creature row with its layered deck ('deck', read by pf_foe_deck), its class and lean. A boss plays in a set order: one set-up piece (trick, guard, heal), then two Hurt pieces, and again. */
function pfd_foe_row(array $c, string $region = ''): array
{
    $c = pfd_creature_overlay($c);   // 2.7.01: abilities, style, regions, petals from data/pf_creatures.txt
    $deck = pfd_foe_pieces($c, $region);
    if (($c['size'] ?? '') === 'boss') {
        $soft = array_values(array_filter($deck, fn($x) => $x['t'] !== 'hurt')); $hard = array_values(array_filter($deck, fn($x) => $x['t'] === 'hurt')); $deck = [];
        while ($soft || $hard) { if ($soft) $deck[] = array_shift($soft); if ($hard) $deck[] = array_shift($hard); if ($hard) $deck[] = array_shift($hard); }
    }
    $cl = pfd_class($c);
    return ['deck' => $deck, 'class' => $cl, 'lean' => $deck ? pfd_foe_lean($c) : pfb_lean($c), 'region' => $region] + $c;
}

function pfd_foe_lean(array $c): string
{
    $u = pfd_unique_of($c);
    return in_array($u['lean'] ?? '', PFD_FAM, true) ? $u['lean'] : pfd_classes()['classes'][pfd_class($c)]['lean'];
}

// ----------------------------------------------------------------- the player's deck (pure: from a sources array)

/** The catalogue row of a deck key ('swing#2' = a second copy of a basic), or null. */
function pfd_piece(string $key): ?array
{
    return pfd_catalog()[explode('#', $key)[0]] ?? null;
}

/** 2.7.08: the creature class a counter piece answers ('bird' ...), or null for any other piece. */
function pfd_counter_of(?array $p): ?string
{
    if (!$p || ($p['src'] ?? '') !== 'knack' || !str_contains((string)($p['ref'] ?? ''), ':')) return null;
    $c = explode(':', (string)$p['ref'], 2)[1];
    return isset(PFD_COUNTER_CLASSES[$c]) ? $c : null;
}

/** The starter offer (12 keys) and kits for a gnome: CALLING and HOME filled in. */
function pfd_offer_keys(string $calling, string $home, ?array $list = null): array
{
    $cal = PF_CALLING_TILE[$calling] ?? 'taunt'; $reg = isset(pfd_catalog()['r:' . $home]) ? 'r:' . $home : 'r:NA';
    return array_map(fn($k) => $k === 'CALLING' ? $cal : ($k === 'r:HOME' ? $reg : $k), $list ?? PFD_OFFER);
}

/** null when the 6 picks make a legal starter (each from the offer, no repeats, 3 or more Hurt pieces with the core), else why not. */
function pfd_starter_check(array $picks, string $calling, string $home): ?string
{
    $offer = pfd_offer_keys($calling, $home);
    if (count($picks) !== PFD_PICKS || count(array_unique($picks)) !== PFD_PICKS) return 'Pick exactly ' . PFD_PICKS . ' pieces.';
    foreach ($picks as $k) if (!is_string($k) || !in_array($k, $offer, true)) return 'Pick from the pieces on offer.';
    $hurt = 0; foreach (array_merge(PFD_CORE, $picks) as $k) if ((pfd_piece($k)['t'] ?? '') === 'hurt') $hurt++;
    if ($hurt < 3) return 'Bring at least three Hurt pieces.';
    return null;
}

/** The default sources of a gnome with nothing but a level and a calling (tests, sims, and the shape pfd_sources fills in). */
function pfd_sources_blank(int $level = 1, string $calling = '', string $home = 'NA'): array
{
    return ['level' => max(1, $level), 'calling' => $calling, 'ctier' => 1, 'home' => $home,
        'starter' => null,          // the 10 starter keys once chosen, else null
        'state' => [],              // piece key => bool: switched on or off by the gnome
        'tools' => [],              // tool type => tier 1-4 (the best usable tool of the type in the satchel)
        'belt' => null,             // the tool types on the belt in slot order; null = never set (the best tools fill it)
        'slots' => PFD_BELTS[1][0], // belt slots
        'wear' => [],               // tool type => fight wear so far
        'pals' => [],               // active party pals: [['n', 't', 'v', 'r', 'rank' 1-3], ...]
        'wears' => [],              // wearable item slug => qty (includes/wearables.php): what the gnome owns
        'worn' => [],               // 2.7.14: slot => wearable item slug the gnome WEARS: each makes a Keepsake piece (only worn items do)
        'crops' => [], 'crafts' => [], 'regions' => [], 'legends' => [],   // crop kind / recipe category / region code / legendary crop slug => rank 1-4
        'auto' => false,
        'statp' => false,           // stat pieces on for this gnome (setting pfight_statpieces)
        'sbase' => [],              // stat => the gnome's own points (stat_<stat>, no boosts): which stat pieces it owns (missing = 10, a new gnome's)
        'spts' => []];              // stat => points as they are now (with boosts): the pieces' numbers (missing = sbase)
}

function pfd_dur_max(int $tier): int { return PFD_DUR_BASE + PFD_DUR_RANK * (max(1, min(4, $tier)) - 1); }

/** The belt as it stands: [['type', 'tier', 'max', 'wear', 'left', 'state' => ok | broken | none (tool gone) | over (no slot)], ...] in slot order. */
function pfd_belt(array $src): array
{
    $belt = $src['belt'];
    if ($belt === null) {   // never set: the best tools the gnome has, as many as the belt holds
        $t = $src['tools']; $order = array_flip(array_keys($t)); uksort($t, fn($a, $b) => ($t[$b] <=> $t[$a]) ?: ($order[$a] <=> $order[$b]));
        $belt = array_slice(array_keys(array_filter($t, fn($tier, $type) => pfd_dur_max($tier) > (int)($src['wear'][$type] ?? 0), ARRAY_FILTER_USE_BOTH)), 0, (int)$src['slots']);
    }
    $out = [];
    foreach (array_values($belt) as $i => $type) {
        $tier = (int)($src['tools'][$type] ?? 0); $max = pfd_dur_max(max(1, $tier)); $wear = min($max, max(0, (int)($src['wear'][$type] ?? 0)));
        $out[] = ['type' => $type, 'tier' => $tier, 'max' => $max, 'wear' => $wear, 'left' => $max - $wear, 'state' => $tier < 1 ? 'none' : ($wear >= $max ? 'broken' : ($i >= (int)$src['slots'] ? 'over' : 'ok'))];
    }
    return $out;
}

/**
 * Build the deck from sources. Returns:
 *  'pieces'  every piece the gnome could bring, kit first then gear: ['key', 'k' (engine key), 'n', 't', 'v', 'r', 'tag', 'src', 'ref', 'rank' 0-4, 'life', 'col'?, 'up'?, 'blurb',
 *            'gear' (tool / pal: not switched), 'tool' (type), 'starter', 'core', 'on', 'out' ('' or 'cap': left out because the deck is over a rarity cap)]
 *  'deck'    the pieces that go into a fight (on, not out)
 *  'counts'  n, kit, belt, pals, hurt, rare, mw, src (pal / tool / crop), team (0-3)
 *  'err'     why the deck may not be used as switched (null = fine); a fight then plays the default kit
 *  'starter' chosen or not, 'offer' the 12 keys, 'kits', 'belt' (pfd_belt), 'slots', 'auto'
 */
function pfd_build(array $src): array
{
    $src += pfd_sources_blank();
    $C = pfd_catalog(); $lvl = (int)$src['level']; $cal = (string)$src['calling'];
    $chosen = is_array($src['starter']);
    $starter = $chosen ? array_values($src['starter']) : array_merge(PFD_CORE, PFD_STARTER_FIXED);
    $rankOf = function (array $p) use ($src): int {   // the rank of a piece: fixed in the file, or the rank of the gnome's source (at least Common)
        if ($p['rar'] !== 'src') return (int)$p['rar'];
        $have = ['crop' => $src['crops'], 'craft' => $src['crafts'], 'region' => $src['regions'], 'tool' => $src['tools'], 'legend' => $src['legends'] ?? []][$p['src']] ?? [];
        return max(1, min(4, (int)($have[$p['ref']] ?? 1)));
    };
    $owned = function (array $p) use ($src, $lvl, $cal): bool {
        switch ($p['src']) {
            case 'basic': return $p['k'] !== 'breather';
            case 'knack': return $lvl >= (int)$p['ref'];
            case 'calling': [$rc, $rt] = explode(':', $p['ref'] . ':1'); return $rc !== '' && $rc === $cal && (int)($src['ctier'] ?? 1) >= max(1, (int)$rt);   // 2.7.08: ref `calling:3` = the tier III second piece
            case 'crop': return isset($src['crops'][$p['ref']]);
            case 'craft': return isset($src['crafts'][$p['ref']]);
            case 'region': return isset($src['regions'][$p['ref']]);
            case 'legend': return isset($src['legends'][$p['ref']]);
        }
        return false;   // tool pieces come from the belt
    };
    $entry = function (string $key, array $p, int $rank, array $x = []): array {
        $e = ['key' => $key, 'k' => $p['k'], 'n' => $p['n'], 't' => $p['t'], 'v' => (int)$p['v'], 'r' => $p['r'], 'tag' => (string)$p['tag'], 'src' => $p['src'], 'ref' => (string)($p['ref'] ?? ''), 'rank' => $rank,
            'life' => (int)($p['life'] ?? 0) ?: ($rank >= 4 ? 4 : ($p['tag'] === 'quick' ? 2 : ($p['tag'] === 'hold' ? 4 : PFB_LIFE))), 'blurb' => (string)($p['blurb'] ?? ''),
            'gear' => false, 'tool' => '', 'starter' => false, 'core' => false, 'on' => false, 'out' => ''];
        foreach (['col', 'up', 'mod', 'cnt', 'fx', 'fa', 'fb', 'st', 'sm', 'edges', 'ik'] as $f) if (isset($p[$f])) $e[$f] = $p[$f];   // edges: a stat piece's own four edges (Knot of Twine); fx fa fb: a Tailor wearable's effect code and numbers (includes/wearables.php); st sm: a stat piece's stat and its modifier
        return $x + $e;
    };
    $pieces = []; $seen = [];
    foreach ($starter as $key) {   // the starter first, in the order it was packed
        $p = pfd_piece((string)$key); if (!$p || isset($seen[$key]) || $p['src'] === 'tool') continue; $seen[$key] = 1;
        $pieces[] = $entry((string)$key, $p, $rankOf($p), ['starter' => true, 'core' => in_array($key, PFD_CORE, true), 'on' => (bool)($src['state'][$key] ?? true)]);
    }
    foreach ($C as $key => $p) {   // then everything else the gnome owns: crop, craft and region pieces are on unless switched off; knacks and the rest are off unless switched on
        if (isset($seen[$key]) || !in_array($p['src'], PFD_PLAYER_SRC, true) || !$owned($p)) continue;
        $pieces[] = $entry($key, $p, $rankOf($p), ['on' => (bool)($src['state'][$key] ?? false), 'new' => !isset($src['state'][$key])]);   // 2.6.989: a piece the gnome has just earned arrives switched off, marked New, until they switch it
    }
    if (!empty($src['worn'])) {   // 2.7.00 wearables: each WORN item (2.7.14) is a Keepsake piece (key w:<wearable>[-b]), off until switched on; its rank is the worn item's rank
        require_once __DIR__ . '/wearables.php';
        foreach (wear_pieces(array_fill_keys(array_map('strval', array_values((array)$src['worn'])), 1), (array)($src['wears_lined'] ?? [])) as $wp) {
            if (isset($seen[$wp['key']])) continue; $seen[$wp['key']] = 1;
            $pieces[] = $entry($wp['key'], $wp, (int)$wp['rank'], ['on' => (bool)($src['state'][$wp['key']] ?? false), 'new' => !isset($src['state'][$wp['key']])]);
        }
    }
    if (!empty($src['statp'])) foreach (pfd_stat_pieces() as $key => $sp) {   // stat pieces: owned from the gnome's points in the stat (tier 0 = everyone), off until switched on, like the knacks
        $own = (int)($src['sbase'][$sp['stat']] ?? 10);
        if ($own < $sp['tier'] || isset($seen[$key])) continue; $seen[$key] = 1;
        $pieces[] = $entry($key, pfd_stat_entry($sp, (int)($src['spts'][$sp['stat']] ?? $own)), 0, ['on' => (bool)($src['state'][$key] ?? false), 'new' => !isset($src['state'][$key])]);
    }
    $belt = pfd_belt($src);
    foreach ($belt as $b) {   // gear: the tools on the belt that work
        $p = $C['t:' . $b['type']] ?? null; if (!$p || $b['state'] !== 'ok') continue;
        $pieces[] = $entry('t:' . $b['type'], $p, $rankOf($p), ['gear' => true, 'tool' => $b['type'], 'on' => true]);
    }
    foreach ($src['pals'] as $q) {   // gear: the active party's pals (generated, not authored: the value already carries the rarity)
        $nm = (string)($q['n'] ?? 'Pal'); $key = 'pal:' . $nm; if (isset($seen[$key])) continue; $seen[$key] = 1;
        $pieces[] = $entry($key, ['k' => $key, 'n' => $nm, 't' => (string)$q['t'], 'v' => (int)$q['v'], 'r' => $q['r'] ?? null, 'tag' => !empty($q['boon']) ? 'boon' : 'pal', 'src' => 'pal', 'ref' => (string)($q['ref'] ?? ''), 'life' => 0], max(1, min(3, (int)($q['rank'] ?? 1))), ['gear' => true, 'on' => true]);
    }
    $sl = pfd_slots($lvl); $cnt = ['n' => 0, 'kit' => 0, 'belt' => 0, 'pals' => 0, 'hurt' => 0, 'rare' => 0, 'mw' => 0, 'larder' => 0, 'larder_max' => $sl['larder'], 'keeps' => 0, 'keeps_max' => $sl['keeps'], 'src' => ['pal' => 0, 'tool' => 0, 'crop' => 0]];
    $capOut = pfd_cap_out($pieces);
    foreach ($pieces as $i => $e) {
        if (!$e['on']) continue;
        if (in_array($e['src'], PFD_LARDER_SRC, true) && ++$cnt['larder'] > $sl['larder']) $pieces[$i]['out'] = 'slots';   // 2.6.989: more crop pieces on than the Larder holds: the extra ones stay out
        if (in_array($e['src'], PFD_KEEP_SRC, true) && ++$cnt['keeps'] > $sl['keeps']) $pieces[$i]['out'] = 'slots';
        if ($e['rank'] === 3) $cnt['rare']++;
        if ($e['rank'] === 4) $cnt['mw']++;
        if (!empty($capOut[$i])) $pieces[$i]['out'] = 'cap';
        $cnt['n']++; if (!$e['gear']) $cnt['kit']++; if ($e['t'] === 'hurt') $cnt['hurt']++;
        if ($e['src'] === 'tool') $cnt['belt']++; if ($e['src'] === 'pal') $cnt['pals']++;
        if (isset($cnt['src'][$e['src']])) $cnt['src'][$e['src']]++;
    }
    $cnt['team'] = count(array_filter($cnt['src']));
    $err = pfd_validate($cnt);
    return ['pieces' => $pieces, 'deck' => array_values(array_filter($pieces, fn($e) => $e['on'] && $e['out'] === '')), 'counts' => $cnt, 'err' => $err,
        'starter' => $chosen, 'offer' => pfd_offer_keys($cal, (string)$src['home']), 'kits' => array_map(fn($k) => pfd_offer_keys($cal, (string)$src['home'], $k), PFD_KITS),
        'belt' => $belt, 'slots' => (int)$src['slots'], 'auto' => !empty($src['auto'])];
}

/** 2.7.01 (Josh): which pieces (by index) the Rare / Masterwork cap leaves out. Pieces count in list order, except wearables (key w:...) which count LAST, so they never push a belt tool out of the deck. */
function pfd_cap_out(array $pieces): array
{
    $out = []; $rr = 0; $mm = 0;
    $order = array_keys($pieces);
    usort($order, fn($x, $y) => (int)str_starts_with((string)$pieces[$x]['key'], 'w:') <=> (int)str_starts_with((string)$pieces[$y]['key'], 'w:'));
    foreach ($order as $i) {
        if (!$pieces[$i]['on']) continue;
        if ($pieces[$i]['rank'] === 3 && ++$rr > PFD_RARE_CAP) $out[$i] = 1;
        if ($pieces[$i]['rank'] === 4 && ++$mm > PFD_MW_CAP) $out[$i] = 1;
    }
    return $out;
}

/** Why a deck may not be used, or null. $counts = pfd_build()['counts'] (or a whole build). */
function pfd_validate(array $counts): ?string
{
    $c = $counts['counts'] ?? $counts;
    if ((int)$c['kit'] < PFD_KIT_MIN) return 'Pack at least ' . PFD_KIT_MIN . ' kit pieces.';
    if ((int)$c['hurt'] < 1) return 'Bring at least one Hurt piece (the great creatures cannot be charmed).';
    if ((int)$c['rare'] > PFD_RARE_CAP) return 'At most ' . PFD_RARE_CAP . ' Rare pieces a deck. Take one out first.';
    if ((int)$c['mw'] > PFD_MW_CAP) return 'At most ' . PFD_MW_CAP . ' Masterwork piece a deck. Take the other one out first.';
    if ((int)($c['larder'] ?? 0) > (int)($c['larder_max'] ?? 99)) return 'Your Larder holds ' . (int)$c['larder_max'] . ' crop pieces. Take one out first.';
    if ((int)($c['keeps'] ?? 0) > (int)($c['keeps_max'] ?? 99)) return 'You have ' . (int)$c['keeps_max'] . ' Keepsake slots. Take one out first.';
    return null;
}

/** The deck a fight uses: the gnome's own when it is legal, else the default kit with the gear that still fits. */
function pfd_fight_entries(array $src): array
{
    $b = pfd_build($src);
    $kitOk = (int)$b['counts']['kit'] >= PFD_KIT_MIN && (int)$b['counts']['hurt'] >= 1;
    if ($kitOk) return $b['deck'];
    return pfd_build(['starter' => null, 'state' => []] + $src)['deck'];
}

/** Engine tiles from deck entries (as pf_player_deck makes them: base + stat + level / 3 + bonuses; the rank adds PFD_RANK_BONUS). */
function pfd_tiles(array $entries, array $stats, array $typeBonus = [], string $calling = '', int $ctier = 1, bool $snack = true): array
{
    $deck = [];
    foreach ($entries as $e) {
        $k = (string)$e['k']; $t = (string)$e['t'];
        if ($k === 'snack' && !$snack) { $deck[] = pf_make_tile('breather', $stats, (int)($typeBonus['heal'] ?? 0), ['src' => 'basic']); continue; }   // nothing to eat: a weak Breather instead of a dead piece
        $b = (int)($typeBonus[$t] ?? 0) + ($calling === 'bloomcaller' && in_array($t, ['charm', 'soothe'], true) ? 2 : 0);
        if ($e['src'] === 'calling') $b += max(0, $ctier - 1) * 2;
        if ($e['src'] !== 'pal') $b += PFD_RANK_BONUS[(int)$e['rank']] ?? 0;
        $over = ['n' => $e['n'], 't' => $t, 'v' => (int)$e['v'], 'r' => $e['r'], 'tag' => (string)$e['tag'], 'src' => $e['src'], 'life' => (int)$e['life'], 'rank' => (int)$e['rank']];
        foreach (['col', 'up', 'mod', 'cnt', 'fx', 'fa', 'fb', 'st', 'sm', 'edges', 'ik'] as $f) if (isset($e[$f])) $over[$f] = $e[$f];
        if ($e['tool'] !== '') $over['tool'] = $e['tool'];
        $tile = pf_make_tile($k, $stats, $b, $over);
        if (!empty($e['ik'])) $tile['ik'] = (string)$e['ik'];   // 2.8.61: the drawn icon's key rides on the tile (a stat piece's ico-stat-*), so the fight's hand, board and replay draw it as the box does (pf_make_tile keeps no ik)
        if (!empty($e['fx'])) { $tile['fx'] = (string)$e['fx']; $tile['fxa'] = (int)($e['fa'] ?? 0); $tile['fxb'] = (int)($e['fb'] ?? 0); }
        elseif ($e['src'] === 'stat') { $tile['fxa'] = (int)($e['fa'] ?? 0); $tile['fxb'] = (int)($e['fb'] ?? 0); }   // a stat piece not live yet: its numbers ride along, no effect   // 2.7.09: the wear effect rides on the tile as fx, fxa, fxb (pfb_wx_* in pfboard.php)
        $deck[] = $tile;
    }
    return $deck;
}

/** The four authored edges of a deck entry (as the board gives them: pfb_v1_tile). */
function pfd_edges(array $e): array
{
    if (is_array($e['edges'] ?? null)) return $e['edges'];   // its own four edges (Knot of Twine)
    return pfb_author_edges(['t' => $e['t'], 'r' => $e['r']], (string)($e['col'] ?? PFB_SRC_FAM[$e['src']] ?? PF_HOLE[$e['t']] ?? 'body'), isset($e['up']) ? (bool)$e['up'] : null);
}

// ================================================================= Part 2: the game (DB)

/** The four tables (also in schema.php; made here on first use so a copy whose version was not bumped still works). */
function pfd_ensure(): bool
{
    static $ok = null;
    if ($ok !== null) return $ok;
    try { q('SELECT 1 FROM pf_tool_wear LIMIT 1'); q('SELECT 1 FROM pf_belts LIMIT 1'); q('SELECT 1 FROM pf_deck_pieces LIMIT 1'); q('SELECT 1 FROM pf_decks LIMIT 1'); $ok = true; } catch (Throwable $e) {}
    if ($ok === null) {
        try { foreach (pfd_schema() as $sql) db()->exec($sql); $ok = true; }
        catch (Throwable $e) { error_log('pfd_ensure: ' . $e->getMessage()); return $ok = false; }
    }
    pfd_content_once();
    return $ok;
}

/** Stat pieces (setting pfight_statpieces: '0' Off, 'admin' Admins only, '1' Everyone): may this gnome own and pack them? $u = user row or null (the setting alone, Everyone only). */
function pfd_statpieces_open(?array $u = null): bool
{
    $v = (string)setting('pfight_statpieces');
    if ($v === '1') return true;
    return $v === 'admin' && $u !== null && ($u['role'] ?? '') === 'admin';
}

/** Is the v1 setting on for anyone (Admins only or Everyone)? While it is Off the belts and the repair kit are not made, so players see nothing new in the shop or the craft lists. */
function pfd_live(): bool
{
    return !in_array((string)setting('pfight_v1'), ['', '0'], true);
}

/** 2.7.08 (Josh): the fight belts on Twigg's shelf and the Tool Repair Kit recipe are seen by a gnome only when the setting is on for everyone ('1'), or the gnome is an admin (the test with 'admin'). $u = user row or null (the setting alone). */
function pfd_gear_open(?array $u = null): bool
{
    $v = (string)setting('pfight_v1');
    if ($v === '1') return true;
    return $v === 'admin' && $u !== null && ($u['role'] ?? '') === 'admin';
}
/** Is this item slug part of that gear (a belt or the repair kit)? */
function pfd_gear_slug(string $slug): bool { return $slug === PFD_REPAIR || isset(PFD_BELT_ITEMS[$slug]); }

/** The first v1 use after the setting was switched on: make the belts, the repair kit and its recipe (once; marker setting `pfd_content`). */
function pfd_content_once(): void
{
    if (!pfd_live() || setting('pfd_content') === '1') return;
    try {
        require_once __DIR__ . '/crafting.php';
        ensure_crafts();
        if (item_id_by_slug(PFD_REPAIR)) set_setting('pfd_content', '1');
    } catch (Throwable $e) { error_log('pfd_content_once: ' . $e->getMessage()); }
}

/** CREATE TABLE statements (plain SQL that SQLite and MySQL both take). */
function pfd_schema(string $end = ''): array
{
    return [
        "CREATE TABLE IF NOT EXISTS pf_decks (user_id INTEGER NOT NULL PRIMARY KEY, starter INTEGER NOT NULL DEFAULT 0, auto_use INTEGER NOT NULL DEFAULT 0, belt_set INTEGER NOT NULL DEFAULT 0, ver INTEGER NOT NULL DEFAULT 1, made_at VARCHAR(20) NULL)$end",
        "CREATE TABLE IF NOT EXISTS pf_deck_pieces (user_id INTEGER NOT NULL, piece_key VARCHAR(48) NOT NULL, starter INTEGER NOT NULL DEFAULT 0, active INTEGER NOT NULL DEFAULT 1, pos INTEGER NOT NULL DEFAULT 0, PRIMARY KEY (user_id, piece_key))$end",
        "CREATE TABLE IF NOT EXISTS pf_belts (user_id INTEGER NOT NULL, slot INTEGER NOT NULL, tool_type VARCHAR(20) NOT NULL, PRIMARY KEY (user_id, slot))$end",
        "CREATE TABLE IF NOT EXISTS pf_tool_wear (user_id INTEGER NOT NULL, tool_type VARCHAR(20) NOT NULL, wear INTEGER NOT NULL DEFAULT 0, PRIMARY KEY (user_id, tool_type))$end",
    ];
}

/** The belt and repair items, the belts' shelf at Twigg's (adds only; safe to repeat). The repair kit's recipe is in data/crafts.txt; called from ensure_crafts() before the recipes are read.
 *  Nothing is made while the setting pfight_v1 is Off (the recipe import then skips the kit: its item is missing); pfd_content_once() makes them on the first v1 use. */
function pfd_ensure_content(): void
{
    if (!pfd_live()) return;
    $shop = (int)q_val("SELECT id FROM shops WHERE slug = 'twigg-s-seed-emporium'");
    foreach (PFD_BELT_ITEMS as $slug => [$name, $price, $rarity, $desc]) {
        $id = item_id_by_slug($slug);
        if (!$id) $id = db_insert('items', ['name' => $name, 'slug' => $slug, 'category' => 'supply', 'rarity' => $rarity, 'base_price' => $price, 'description' => $desc, 'edible' => 0, 'effects' => json_encode(['fight_belt' => (int)array_search($slug, array_column(PFD_BELTS, 1), true) + 1]), 'tradable' => 0, 'max_stack' => 1]);
        if ($shop && $id && !q_val('SELECT 1 FROM shop_stock WHERE shop_id = ? AND item_id = ?', [$shop, $id])) {
            db_insert('shop_stock', ['shop_id' => $shop, 'item_id' => $id, 'price_min' => $price, 'price_max' => (int)pf_round($price * 1.1), 'max_stock' => 1, 'restock_chance' => 40, 'current_stock' => 1, 'current_price' => $price]);
        }
    }
    if (!item_id_by_slug(PFD_REPAIR)) {
        [$name, $price, $rarity, $desc] = PFD_REPAIR_ITEM;
        db_insert('items', ['name' => $name, 'slug' => PFD_REPAIR, 'category' => 'supply', 'rarity' => $rarity, 'base_price' => $price, 'description' => $desc, 'edible' => 0, 'effects' => null, 'tradable' => 1]);
    }
}

/** The user row for an id or a row. */
function pfd_user(int|array $u): array
{
    if (is_array($u)) return $u;
    return q_one('SELECT * FROM users WHERE id = ?', [$u]) ?? ['id' => $u, 'level' => 1, 'calling' => ''];
}

/** Belt tier 1-3: the best fight belt in the satchel that the gnome is old enough for. */
function pfd_belt_tier(int|array $u): int
{
    $u = pfd_user($u); $tier = 1;
    foreach (PFD_BELTS as $t => [, $slug, $lv]) {
        if ($slug === null || (int)($u['level'] ?? 1) < $lv) continue;
        if (q_val('SELECT 1 FROM user_items ui JOIN items i ON i.id = ui.item_id WHERE ui.user_id = ? AND i.slug = ? AND ui.qty > 0', [(int)$u['id'], $slug])) $tier = max($tier, $t);
    }
    return $tier;
}

/** The gnome level a fight belt (by item slug) needs, or 0 for any other item. The shop uses it (2.7.05). */
function pfd_belt_level_need(string $slug): int
{
    foreach (PFD_BELTS as [, $s, $lv]) if ($s !== null && $s === $slug) return (int)$lv;
    return 0;
}

/** How many tools the gnome's belt holds (2, 3 or 4). */
function pfd_belt_slots(int|array $u): int
{
    return PFD_BELTS[pfd_belt_tier($u)][0];
}

/** crop slug => kind (data/crops.txt). */
function pfd_crop_kinds(): array
{
    static $K = null;
    if ($K === null) { $K = []; foreach (pf_data_lines('crops.txt') as $r) if (count($r) >= 3) $K[$r[0]] = $r[2]; }
    return $K;
}

/** The pieces of the pals taken along (active party only): type from the pal's skills and Boon, value from them and its rarity, right knob from its jigsaw knob. */
function pfd_pal_pieces(array $u): array
{
    if (setting('ppal_party') !== '1') return [];
    require_once __DIR__ . '/puzzle_pals.php';
    if ((int)($u['level'] ?? 1) < PPAL_PARTY_LEVEL) return [];
    $kindType = ['ward' => 'guard', 'foot' => 'guard', 'guard' => 'guard', 'bulwark' => 'guard', 'slip' => 'guard', 'edge' => 'hurt', 'first' => 'hurt',
        'mend' => 'heal', 'sip' => 'heal', 'feast' => 'heal', 'rally' => 'heal', 'petal' => 'charm', 'kindle' => 'trick', 'tonic' => 'trick'];
    $activeType = ['strike' => 'hurt', 'sap' => 'hurt', 'shield' => 'guard', 'patch' => 'heal', 'snare' => 'trick', 'daze' => 'trick', 'rouse' => 'trick', 'gust' => 'trick'];
    $knob = ['hurt' => 'mind', 'guard' => 'craft', 'heal' => 'body', 'charm' => 'body', 'trick' => 'mind'];
    $out = [];
    foreach ((array)ppal_equipped($u) as $e) {
        $pal = $e['pal'];
        $score = ['hurt' => 0, 'guard' => 0, 'heal' => 0, 'charm' => 0, 'trick' => 0];
        foreach (ppal_pal_skills($pal) as $k => $v) if (isset($kindType[$k])) $score[$kindType[$k]] += (int)$v;
        if (($b = ppal_boon($pal)) && ($b['active'] ?? '') !== '') $score[$activeType[$b['active']] ?? 'trick'] += 3;
        arsort($score);
        $t = (string)array_key_first($score);
        $rar = ['common' => 0, 'uncommon' => 1, 'rare' => 2][$pal['rarity'] ?? 'common'] ?? 0;
        $out[] = ['n' => (string)($pal['name'] ?? 'Pal'), 't' => $t, 'v' => 4 + min(4, (int)pf_round($score[$t] / 2)) + 2 * $rar, 'r' => PFD_PAL_KNOB[(string)($pal['knob'] ?? '')] ?? $knob[$t], 'rank' => $rar + 1, 'ref' => (string)($pal['key'] ?? ''), 'boon' => !empty($b)];
    }
    return $out;
}

/** Everything the deck is built from, read from the database (the shape of pfd_sources_blank). */
function pfd_sources(int|array $u): array
{
    $u = pfd_user($u); $uid = (int)$u['id'];
    $src = pfd_sources_blank((int)($u['level'] ?? 1), (string)($u['calling'] ?? ''));
    $try = function (callable $fn) { try { $fn(); } catch (Throwable $e) { error_log('pfd_sources: ' . $e->getMessage()); } };
    $try(function () use (&$src, $u) { $src['ctier'] = max(1, min(3, (int)calling_tier($u))); });
    $try(function () use (&$src, $u) { if (!empty($u['region_id'])) $src['home'] = (string)(q_val('SELECT code FROM regions WHERE id = ?', [(int)$u['region_id']]) ?: 'NA'); });
    $try(function () use (&$src, $uid) {   // the best usable tool of each type (a Broken copy is another item and does not count)
        foreach (q("SELECT i.effects FROM user_items ui JOIN items i ON i.id = ui.item_id WHERE ui.user_id = ? AND ui.qty > 0 AND i.category = 'tool'", [$uid])->fetchAll(PDO::FETCH_COLUMN) as $fx) {
            $f = json_decode((string)$fx, true) ?: []; $type = (string)($f['tool'] ?? '');
            if ($type !== '' && isset(pfd_catalog()['t:' . $type])) $src['tools'][$type] = max((int)($src['tools'][$type] ?? 0), max(1, min(4, (int)($f['tier'] ?? $f['power'] ?? 1))));
        }
    });
    $try(function () use (&$src, $u) { $src['slots'] = pfd_belt_slots($u); });
    $try(function () use (&$src, $u) {   // stat pieces: owned from the gnome's own stat points, numbered from its points now (boosts count)
        if (!pfd_statpieces_open($u)) return;
        $src['statp'] = true;
        foreach (array_keys(PFD_STAT_STATS) as $k) { $src['sbase'][$k] = (int)($u['stat_' . $k] ?? 10); $src['spts'][$k] = function_exists('eff_stat') ? eff_stat($u, $k) : $src['sbase'][$k]; }
    });
    $try(function () use (&$src, $u) { $src['pals'] = pfd_pal_pieces($u); });
    $try(function () use (&$src, $uid) {   // crops: a kind is owned once a crop of it was grown; its rank is the best food mastery among them
        require_once __DIR__ . '/food_mastery.php'; $kinds = pfd_crop_kinds();
        foreach (q('SELECT i.slug, m.eaten + m.grown AS n FROM user_food_mastery m JOIN items i ON i.id = m.item_id WHERE m.user_id = ? AND m.grown > 0', [$uid])->fetchAll() as $r) {
            $kind = $kinds[(string)$r['slug']] ?? ''; if ($kind === '' || !isset(pfd_catalog()['c:' . $kind])) continue;
            $src['crops'][$kind] = max((int)($src['crops'][$kind] ?? 1), max(1, min(4, food_mastery_tier((int)$r['n']))));
        }
    });
    $try(function () use (&$src, $uid) {   // 2.6.990 legendary crops: the piece of a treasure crop is yours after PFD_LEGEND_HARVESTS harvests; its rank is your mastery of that crop
        require_once __DIR__ . '/food_mastery.php';
        foreach (q('SELECT i.slug, m.eaten + m.grown AS n, m.grown AS g FROM user_food_mastery m JOIN items i ON i.id = m.item_id WHERE m.user_id = ? AND m.grown >= ?', [$uid, PFD_LEGEND_HARVESTS])->fetchAll() as $r) {
            if (!isset(pfd_catalog()['g:' . $r['slug']])) continue;
            $src['legends'][(string)$r['slug']] = max(1, min(4, food_mastery_tier((int)$r['n'])));
        }
    });
    $try(function () use (&$src, $uid) {   // crafts: a category is owned once something in it was made; rank 1 + its category mastery
        require_once __DIR__ . '/craft_mastery.php'; $marks = craft_mastery_list('category_mastery_tiers', [100, 500, 2000]);
        foreach (q('SELECT r.category AS c, SUM(ur.made) AS n FROM user_recipes ur JOIN recipes r ON r.id = ur.recipe_id WHERE ur.user_id = ? AND ur.made > 0 GROUP BY r.category', [$uid])->fetchAll() as $r) {
            if (isset(pfd_catalog()['k:' . $r['c']])) $src['crafts'][(string)$r['c']] = max(1, min(4, 1 + craft_mastery_tier_of((int)$r['n'], $marks)));
        }
    });
    $try(function () use (&$src, $uid) {   // regions: a region is owned once its Gardening Guide was read; the rank grows with the number of guides (1, 3, 7, 12)
        $codes = [];
        foreach (q('SELECT guide_key FROM user_guides WHERE user_id = ?', [$uid])->fetchAll(PDO::FETCH_COLUMN) as $k) if (str_starts_with((string)$k, 'region:')) $codes[] = strtoupper(substr((string)$k, 7));
        $n = count(array_unique($codes)); $rank = $n >= 12 ? 4 : ($n >= 7 ? 3 : ($n >= 3 ? 2 : 1));
        foreach ($codes as $c) if (isset(pfd_catalog()['r:' . $c])) $src['regions'][$c] = $rank;
    });
    $try(function () use (&$src, $uid, $u) { require_once __DIR__ . '/wearables.php'; $src['wears'] = wear_owned($uid); $src['wears_lined'] = wear_lined_set($uid); $src['worn'] = wear_live($u) ? wear_worn($uid, $src['wears']) : []; });   // 2.7.00: the wearables in the satchel; 2.7.14: the ones worn (only they make pieces)
    if (!pfd_ensure()) return $src;
    $row = q_one('SELECT * FROM pf_decks WHERE user_id = ?', [$uid]);
    $src['auto'] = !empty($row['auto_use']);
    $rows = q('SELECT piece_key, starter, active FROM pf_deck_pieces WHERE user_id = ? ORDER BY pos, piece_key', [$uid])->fetchAll();
    if (!empty($row['starter'])) { $src['starter'] = []; foreach ($rows as $r) if ((int)$r['starter'] === 1) $src['starter'][] = (string)$r['piece_key']; }
    foreach ($rows as $r) $src['state'][(string)$r['piece_key']] = (int)$r['active'] === 1;
    if (!empty($row['belt_set'])) $src['belt'] = array_map('strval', q('SELECT tool_type FROM pf_belts WHERE user_id = ? ORDER BY slot', [$uid])->fetchAll(PDO::FETCH_COLUMN));
    foreach (q('SELECT tool_type, wear FROM pf_tool_wear WHERE user_id = ?', [$uid])->fetchAll() as $r) $src['wear'][(string)$r['tool_type']] = (int)$r['wear'];
    return $src;
}

/** The gnome's deck: pfd_build of their sources, plus 'locked' (a fight is under way: no changes). */
function pfd_deck(int|array $u): array
{
    $u = pfd_user($u);
    $b = pfd_build(pfd_sources($u));
    $b['locked'] = pfd_locked((int)$u['id']); $b['belt_tier'] = pfd_belt_tier($u);
    return $b;
}

/** Is a puzzle fight under way? The deck is locked from the moment the fight is dealt until it is over. */
function pfd_locked(int $uid): bool
{
    try {
        foreach (q("SELECT encounter FROM expeditions WHERE user_id = ? AND status = 'active' AND encounter IS NOT NULL", [$uid])->fetchAll(PDO::FETCH_COLUMN) as $j) {
            $enc = json_decode((string)$j, true);
            if (is_array($enc) && !empty($enc['pf']) && empty($enc['pf']['over'])) return true;
        }
    } catch (Throwable $e) {}
    return false;
}

function pfd_row(int $uid): void
{
    if (!q_val('SELECT 1 FROM pf_decks WHERE user_id = ?', [$uid])) q('INSERT INTO pf_decks (user_id, made_at) VALUES (?, ?)', [$uid, gmdate('Y-m-d H:i:s')]);
}

function pfd_guard(array $u): ?string
{
    if (!pfd_ensure()) return 'The Puzzle box is not ready yet. Try again in a moment.';
    if (pfd_locked((int)$u['id'])) return 'You are in a fight. The deck is locked until it is over.';
    return null;
}

/** Pack the starter deck: 6 picks from the offer, or the name of a one-tap kit (bold, steady, kind). Once only. Returns an error or null. */
function pfd_set_starter(int|array $u, array|string $picks): ?string
{
    $u = pfd_user($u); $uid = (int)$u['id'];
    if ($why = pfd_guard($u)) return $why;
    $src = pfd_sources($u);
    if (is_array($src['starter'])) return 'You have already packed your first Puzzle box.';
    if ($picks === 'fixed') $picks = PFD_STARTER_FIXED;   // 2.7.01: the same box for everyone
    elseif (is_string($picks)) { if (!isset(PFD_KITS[$picks])) return 'There is no such kit.'; $picks = pfd_offer_keys((string)$src['calling'], (string)$src['home'], PFD_KITS[$picks]); }
    $picks = array_values(array_map('strval', $picks));
    if ($why = pfd_starter_check($picks, (string)$src['calling'], (string)$src['home'])) return $why;
    pfd_row($uid);
    foreach (array_merge(PFD_CORE, $picks) as $i => $k) {
        q('DELETE FROM pf_deck_pieces WHERE user_id = ? AND piece_key = ?', [$uid, $k]);
        q('INSERT INTO pf_deck_pieces (user_id, piece_key, starter, active, pos) VALUES (?, ?, 1, 1, ?)', [$uid, $k, $i]);
    }
    q('UPDATE pf_decks SET starter = 1 WHERE user_id = ?', [$uid]);
    return null;
}

/** 2.7.01: a gnome with no starter box yet gets the fixed one (no pick screen). True when the deck has a starter afterwards. */
function pfd_ensure_starter(int|array $u): bool
{
    $u = pfd_user($u);
    if (!pfd_ensure()) return false;
    if (is_array(pfd_sources($u)['starter'])) return true;
    return pfd_set_starter($u, 'fixed') === null;   // 2.7.05 (decided): a box packed before 2.6.74 (user_pbox) is NOT carried over: the starter is the same fixed box for everyone
}

/** The pieces of an old Puzzle box (user_pbox, before 2.6.74) that the gnome owns and that are not in the deck yet are switched on, as far as the caps allow. Returns how many. Only the starter PICK (pfd_starter, pfv_post) uses it; the fixed starter does not (2.7.05). */
function pfd_carry_old_box(int|array $u): int
{
    $u = pfd_user($u); $n = 0;
    if (!function_exists('pbox_load')) return 0;
    foreach ((array)(pbox_load((int)$u['id']) ?? []) as $k) {
        foreach (pfd_deck($u)['pieces'] as $p) if ($p['key'] === (string)$k && !$p['on'] && !$p['gear'] && pfd_toggle($u, (string)$k, true) === null) $n++;
    }
    return $n;
}

/**
 * Admin: put a gnome's Puzzle box back to its first state: the fixed starter, no switched-on extras, auto-use off, and the belt back to
 * "never set" (no saved slots: like a new gnome's, it shows the best usable tools the gnome owns).
 * Kept: everything the account unlocked (pieces come from crops, crafts, regions, wearables, tools and pals, so they are untouched),
 * earned puzzle upgrades, tool wear and repair kits. Refused while the gnome is in a fight. Returns an error or null.
 */
function pfd_admin_reset(int $uid): ?string
{
    if (!pfd_ensure()) return 'The Puzzle box tables are not ready.';
    if (!q_val('SELECT 1 FROM users WHERE id = ?', [$uid])) return 'There is no such gnome.';   // never make deck rows for an id with no account
    if (pfd_locked($uid)) return 'That gnome is in a fight; the box is locked until it ends.';
    q('DELETE FROM pf_deck_pieces WHERE user_id = ?', [$uid]);
    q('DELETE FROM pf_belts WHERE user_id = ?', [$uid]);
    pfd_row($uid);
    q('UPDATE pf_decks SET starter = 0, auto_use = 0, belt_set = 0 WHERE user_id = ?', [$uid]);
    return pfd_set_starter($uid, 'fixed');
}

/** Switch a kit piece on or off ($on null = the other way). Refused when the deck would not be legal (kit size, a Hurt piece, the rarity caps) or in a fight. Returns an error or null. */
function pfd_toggle(int|array $u, string $key, ?bool $on = null): ?string
{
    $u = pfd_user($u); $uid = (int)$u['id'];
    if ($why = pfd_guard($u)) return $why;
    $src = pfd_sources($u); $b = pfd_build($src); $e = null;
    foreach ($b['pieces'] as $x) if ($x['key'] === $key) $e = $x;
    if (!$e) return str_starts_with($key, 'w:') ? 'Wear it first (My Gnome, Wearing).' : 'You do not own that piece.';
    if ($e['gear']) return $e['src'] === 'tool' ? 'Tool pieces follow your fight belt.' : 'Pal pieces follow your party.';
    $on ??= !$e['on'];
    if ($on === $e['on']) return null;
    $src['state'][$key] = $on; $nb = pfd_build($src);
    if ($nb['err'] !== null && ($b['err'] === null || !$on)) return $nb['err'];   // a deck that was already illegal may still be mended by adding
    pfd_row($uid);
    if (q_val('SELECT 1 FROM pf_deck_pieces WHERE user_id = ? AND piece_key = ?', [$uid, $key])) q('UPDATE pf_deck_pieces SET active = ? WHERE user_id = ? AND piece_key = ?', [$on ? 1 : 0, $uid, $key]);
    else q('INSERT INTO pf_deck_pieces (user_id, piece_key, starter, active, pos) VALUES (?, ?, 0, ?, 100)', [$uid, $key, $on ? 1 : 0]);
    return null;
}

/** 2.7.05: swap one piece for another in ONE request: `$out` comes out of the kit, `$in` goes in. The order that keeps the deck legal wins (out first, then in first); on failure nothing changes. Returns an error or null. */
function pfd_swap(int|array $u, string $out, string $in): ?string
{
    $u = pfd_user($u);
    if ($out === '' || $in === '' || $out === $in) return 'Pick two different pieces to swap.';
    $err = null;
    foreach ([[$out, false, $in, true], [$in, true, $out, false]] as [$k1, $on1, $k2, $on2]) {
        if (($err = pfd_toggle($u, $k1, $on1)) !== null) continue;
        if (($err = pfd_toggle($u, $k2, $on2)) === null) return null;
        pfd_toggle($u, $k1, !$on1);   // the second step was refused: put the first back
    }
    return $err;
}

function pfd_belt_save(int $uid, array $types): void
{
    pfd_row($uid);
    q('DELETE FROM pf_belts WHERE user_id = ?', [$uid]);
    foreach (array_values($types) as $i => $t) q('INSERT INTO pf_belts (user_id, slot, tool_type) VALUES (?, ?, ?)', [$uid, $i, $t]);
    q('UPDATE pf_decks SET belt_set = 1 WHERE user_id = ?', [$uid]);
}

/** Put a tool (by type: the best one of that type you own) on the fight belt; $slot = the slot to take (its tool comes off), null = the first free one. Returns an error or null. */
function pfd_equip_tool(int|array $u, string $type, ?int $slot = null): ?string
{
    $u = pfd_user($u); $uid = (int)$u['id'];
    if ($why = pfd_guard($u)) return $why;
    $src = pfd_sources($u); $slots = (int)$src['slots'];
    if (!isset(pfd_catalog()['t:' . $type])) return 'That is not a fight tool.';
    if ((int)($src['tools'][$type] ?? 0) < 1) return 'You do not have that tool.';
    if (pfd_dur_max((int)$src['tools'][$type]) <= (int)($src['wear'][$type] ?? 0)) return 'That tool is worn out. Fix it with a Tool Repair Kit first.';
    $belt = array_values(array_slice(array_column(pfd_belt($src), 'type'), 0, $slots));
    if (in_array($type, $belt, true)) return null;
    if ($slot !== null) { if ($slot < 0 || $slot >= $slots) return 'Your belt has ' . $slots . ' slots.'; $belt[min($slot, count($belt))] = $type; }
    elseif (count($belt) >= $slots) return 'Your belt is full (' . $slots . ' tools). Take one off first.';
    else $belt[] = $type;
    $nb = pfd_build(['belt' => $belt] + $src);
    if ($nb['err'] !== null && pfd_build($src)['err'] === null) return $nb['err'];
    pfd_belt_save($uid, $belt);
    return null;
}

/** Take a tool off the fight belt. Returns an error or null. */
function pfd_unequip(int|array $u, string $type): ?string
{
    $u = pfd_user($u); $uid = (int)$u['id'];
    if ($why = pfd_guard($u)) return $why;
    $src = pfd_sources($u); $belt = array_column(pfd_belt($src), 'type');
    if (!in_array($type, $belt, true)) return 'That tool is not on your belt.';
    pfd_belt_save($uid, array_values(array_diff($belt, [$type])));
    return null;
}

/** Take a worn-out (broken) or missing (none) tool off the belt so its slot frees up. Only the belt entry goes: the item stays in the satchel and its wear is kept, so a Tool Repair Kit can still fix it and it can go back on. Returns an error or null. */
function pfd_remove_broken(int|array $u, string $type): ?string
{
    $u = pfd_user($u); $uid = (int)$u['id'];
    if ($why = pfd_guard($u)) return $why;
    $e = null; foreach (pfd_belt(pfd_sources($u)) as $b) if ($b['type'] === $type) { $e = $b; break; }
    if ($e === null) return 'That tool is not on your belt.';
    if (!in_array($e['state'], ['broken', 'none'], true)) return 'Only a worn-out or missing tool can be removed. Use Take off for the others.';
    $belt = array_column(pfd_belt(pfd_sources($u)), 'type');
    pfd_belt_save($uid, array_values(array_diff($belt, [$type])));
    if ($e['state'] === 'none') q('DELETE FROM pf_tool_wear WHERE user_id = ? AND tool_type = ?', [$uid, $type]);   // 2.7.06: the tool is gone, so its wear goes with it (a new tool of this type must not start worn)
    return null;
}

/** "Auto-use my current deck": the pre-fight screen is skipped. Remembered per gnome. */
function pfd_set_auto(int|array $u, bool $on): ?string
{
    $u = pfd_user($u);
    if (!pfd_ensure()) return 'The Puzzle box is not ready yet. Try again in a moment.';
    pfd_row((int)$u['id']);
    q('UPDATE pf_decks SET auto_use = ? WHERE user_id = ?', [$on ? 1 : 0, (int)$u['id']]);
    return null;
}

/** Fight wear of every tool the gnome has or has worn: type => ['tier', 'max', 'wear', 'left', 'broken']. */
function pfd_wear(int|array $u): array
{
    $src = pfd_sources($u); $out = [];
    foreach (array_unique(array_merge(array_keys($src['tools']), array_keys($src['wear']))) as $type) {
        $tier = (int)($src['tools'][$type] ?? 0); $max = pfd_dur_max(max(1, $tier)); $w = min($max, max(0, (int)($src['wear'][$type] ?? 0)));
        $out[$type] = ['tier' => $tier, 'max' => $max, 'wear' => $w, 'left' => $max - $w, 'broken' => $w >= $max];
    }
    return $out;
}

/** Add fight wear (tool type => points; a fight's $s['wear']). Returns the tool types that broke with it. */
function pfd_wear_add(int|array $u, array $wear): array
{
    $u = pfd_user($u); $uid = (int)$u['id']; $broke = [];
    if (!$wear || !pfd_ensure()) return $broke;
    $before = pfd_wear($u);
    foreach ($wear as $type => $n) {
        $type = (string)$type; $n = (int)$n; if ($n <= 0 || !isset(pfd_catalog()['t:' . $type])) continue;
        $max = (int)($before[$type]['max'] ?? pfd_dur_max(1)); $old = (int)($before[$type]['wear'] ?? 0); $new = min($max, $old + $n);
        if (q_val('SELECT 1 FROM pf_tool_wear WHERE user_id = ? AND tool_type = ?', [$uid, $type])) q('UPDATE pf_tool_wear SET wear = ? WHERE user_id = ? AND tool_type = ?', [$new, $uid, $type]);
        else q('INSERT INTO pf_tool_wear (user_id, tool_type, wear) VALUES (?, ?, ?)', [$uid, $type, $new]);
        if ($old < $max && $new >= $max) $broke[] = $type;
    }
    return $broke;
}

/** Fix a fight tool with one Tool Repair Kit (crafted): its wear goes back to 0, so it returns to the belt. Returns an error or null. */
function pfd_fix(int|array $u, string $type): ?string
{
    $u = pfd_user($u); $uid = (int)$u['id'];
    if (!pfd_ensure()) return 'The Puzzle box is not ready yet. Try again in a moment.';
    $w = pfd_wear($u)[$type] ?? null;
    if (!$w || $w['wear'] < 1) return 'That tool needs no fixing.';
    $kit = item_id_by_slug(PFD_REPAIR);
    if (!$kit || (int)q_val('SELECT qty FROM user_items WHERE user_id = ? AND item_id = ?', [$uid, $kit]) < 1) return 'You need a Tool Repair Kit (craft one from flint, pine resin and coir fibre).';
    if (!give_item($uid, $kit, -1)) return 'You need a Tool Repair Kit.';
    q('UPDATE pf_tool_wear SET wear = 0 WHERE user_id = ? AND tool_type = ?', [$uid, $type]);
    return null;
}

/** The region code a fight is in (the expedition's scene), or ''. */
function pfd_exp_region(array $exp): string
{
    try { $rid = (int)(exp_scene($exp)['region_id'] ?? 0); return $rid ? (string)q_val('SELECT code FROM regions WHERE id = ?', [$rid]) : ''; }
    catch (Throwable $e) { return ''; }
}

/** The fight hookup: the player's tiles for a v1 fight (the deck as it stands now; from here on it is locked). */
function pfd_start_fight(array $u, array $stats, array $typeBonus, bool $canSnack): array
{
    $src = pfd_sources($u);
    return pfd_tiles(pfd_fight_entries($src), $stats, $typeBonus, (string)$src['calling'], (int)$src['ctier'], $canSnack);
}

/** 2.7.01 fixed first fight: the default kit's 10 pieces (PFD_CORE + PFD_KIT_DEFAULT), whatever the gnome packed, without gear (tools, pals, wearables); the Snack piece is the Breather and the calling piece is Taunt, so every new gnome gets the same deal. */
function pfd_first_tiles(array $u, array $stats): array
{
    $src = pfd_sources($u);
    $kit = array_values(array_filter(pfd_build(['starter' => array_merge(PFD_CORE, pfd_offer_keys('', (string)$src['home'], PFD_KITS[PFD_KIT_DEFAULT])), 'state' => [], 'calling' => ''] + $src)['pieces'], fn($p) => !empty($p['starter'])));   // no calling: the Taunt piece, as for any gnome without one. 2.7.01: the Bold kit named here, since an unchosen deck is now the fixed starter (the first fight's deal is tuned for the Bold kit)
    return pfd_tiles($kit, $stats, [], '', 1, false);
}

/** A fight is over: its tool wear is saved. Returns a line for the log for each tool that broke. */
function pfd_end_fight(array $u, array $s): array
{
    $lines = [];
    foreach (pfd_wear_add($u, (array)($s['wear'] ?? [])) as $type) {
        $nm = pfd_catalog()['t:' . $type]['n'] ?? $type;
        $lines[] = '🔧 Your ' . strtolower((string)(defined('TOOL_TYPES') ? (TOOL_TYPES[$type][0] ?? $type) : $type)) . ' tool is worn out: ' . $nm . ' leaves your deck until you fix it with a Tool Repair Kit.';
    }
    return $lines;
}

/**
 * The POST actions of the Puzzle box and the pre-fight screen (the UI stage calls this from its pages; puzzlebox.php already does). Returns [ok, message].
 *   do=pfd_starter   kit=bold|steady|kind   or   pick[]=KEY x6
 *   do=pfd_toggle    key=KEY  [on=0|1]
 *   do=pfd_swap      out=KEY  in=KEY   (one piece out of the kit, one in; 2.7.05)
 *   do=pfd_equip     tool=TYPE  [slot=N]
 *   do=pfd_unequip   tool=TYPE
 *   do=pfd_remove    tool=TYPE   (a broken or missing tool: off the belt, the item stays)
 *   do=pfd_auto      on=0|1
 *   do=pfd_fix       tool=TYPE
 */
function pfd_post(array $u, string $do, array $in): array
{
    $err = match ($do) {
        'pfd_starter' => pfd_set_starter($u, isset($in['kit']) && $in['kit'] !== '' ? (string)$in['kit'] : array_map('strval', (array)($in['pick'] ?? []))),
        'pfd_toggle' => pfd_toggle($u, (string)($in['key'] ?? ''), isset($in['on']) ? (string)$in['on'] === '1' : null),
        'pfd_swap' => pfd_swap($u, (string)($in['out'] ?? ''), (string)($in['in'] ?? '')),
        'pfd_equip' => pfd_equip_tool($u, (string)($in['tool'] ?? ''), isset($in['slot']) && ctype_digit((string)$in['slot']) ? (int)$in['slot'] : null),
        'pfd_unequip' => pfd_unequip($u, (string)($in['tool'] ?? '')),
        'pfd_remove' => pfd_remove_broken($u, (string)($in['tool'] ?? '')),
        'pfd_auto' => pfd_set_auto($u, (string)($in['on'] ?? '') === '1'),
        'pfd_fix' => pfd_fix($u, (string)($in['tool'] ?? '')),
        default => 'Unknown action.',
    };
    $ok = ['pfd_starter' => 'Puzzle box packed.', 'pfd_toggle' => 'Deck changed.', 'pfd_swap' => 'Pieces swapped.', 'pfd_equip' => 'Tool on your belt.', 'pfd_unequip' => 'Tool off your belt.', 'pfd_remove' => 'Removed from your belt.', 'pfd_auto' => 'Saved.', 'pfd_fix' => 'Tool fixed.'];
    return [$err === null, $err ?? ($ok[$do] ?? 'Done.')];
}
