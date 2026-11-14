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
const PFD_PLAYER_SRC = ['basic', 'knack', 'calling', 'tool', 'crop', 'craft', 'region'];
const PFD_RANK_NAME = ['', 'Common', 'Uncommon', 'Rare', 'Masterwork'];
const PFD_RANK_BONUS = [0, 0, 2, 4, 5];       // value added by rank (I Common .. IV Masterwork)
const PFD_RARE_CAP = 3, PFD_MW_CAP = 1;       // a deck holds at most 3 Rare and 1 Masterwork pieces (kit + gear)
const PFD_KIT_MIN = 8;                        // kit pieces (not counting gear) a deck needs
const PFD_CORE = ['swing', 'dodge', 'rest', 'charm'];   // the 4 fixed starter pieces
const PFD_PICKS = 6;                          // the starter: 4 core + 6 of the 12 offered
/** The 12 starter pieces offered (CALLING = the gnome's calling piece, Taunt without a calling; HOME = the home region's piece). A picked piece is owned from then on. */
const PFD_OFFER = ['CALLING', 'jab', 'snack', 'hide', 'brace', 'soothe', 'hum', 'pierce', 'swing#2', 'c:grain', 'c:herb', 'r:HOME'];
/** The one-tap kits (each 6 of the offer; with the core Swing every kit holds 4 Hurt: the offer has exactly 4, so a pick of 4 would leave no choice). */
const PFD_KITS = ['bold' => ['CALLING', 'jab', 'swing#2', 'pierce', 'snack', 'c:grain'], 'steady' => ['CALLING', 'jab', 'swing#2', 'pierce', 'brace', 'r:HOME'], 'kind' => ['CALLING', 'jab', 'swing#2', 'pierce', 'hum', 'soothe']];
const PFD_KIT_DEFAULT = 'bold';               // played while no starter is chosen yet (nothing is saved)
/** The fight belt: tier => [tool slots, item slug (null = every gnome has it), gnome level needed, price]. Bought only (Twigg's); the best belt the gnome owns and is old enough for counts. */
const PFD_BELTS = [1 => [2, null, 1, 0], 2 => [3, 'stitched-fight-belt', 8, 600], 3 => [4, 'masterwork-fight-belt', 18, 2500]];
const PFD_BELT_ITEMS = [
    'stitched-fight-belt' => ['Stitched Fight Belt', 600, 12, 'A wide belt with three loops. Three of your tools add their piece to your Puzzle box deck (two without it). Needs gnome level 8. It works from your satchel.'],
    'masterwork-fight-belt' => ['Masterwork Fight Belt', 2500, 30, 'Four loops, double stitched. Four of your tools add their piece to your Puzzle box deck. Needs gnome level 18. It works from your satchel.'],
];
const PFD_DUR_BASE = 20, PFD_DUR_RANK = 4;    // a fight tool's durability: 20, +4 per rank above Worn; its piece costs PFB_TOOL_WEAR (2) each time it is played
const PFD_REPAIR = 'tool-repair-kit';         // the crafted item that fixes a fight tool (recipe in data/crafts.txt)
const PFD_REPAIR_ITEM = ['Tool Repair Kit', 30, 6, 'Flint, resin and a twist of fibre. Fixes one fight tool on your Puzzle box belt: its piece is worn out by fights (2 each time it is played) and comes back at full strength.'];
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
        if (isset($e[1]) && in_array($e[1], PFD_FAM, true)) $p['col'] = $e[1];
        if (isset($e[2])) $p['up'] = $e[2] === 'up' ? 1 : 0;
        $C[$r[0]] = $p;
    }
    if (!$C) foreach (PF_TILES_BUILTIN as $k => $t) $C[$k] = ['k' => $k, 'n' => $t['n'], 'src' => in_array($k, PF_BASE_KEYS, true) || $k === 'breather' ? 'basic' : (in_array($k, PF_CALLING_TILE, true) ? 'calling' : 'knack'), 'ref' => '',
        't' => $t['t'], 'v' => $t['v'], 'r' => $t['r'], 'tag' => (string)($t['tag'] ?? ''), 'life' => 0, 'rar' => 0, 'blurb' => ''];   // no file: the old library, nothing else
    return $C;
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

/** data/pf_creature_class.txt: slug => Class. */
function pfd_class_map(): array
{
    static $M = null;
    if ($M !== null) return $M;
    $M = [];
    foreach (pf_data_lines('pf_creature_class.txt') as $r) { $p = explode('=', $r[0], 2); if (count($p) === 2) $M[trim($p[0])] = trim($p[1]); }
    return $M;
}

/** The class of a creature (its row's 'class', else the class file, else Beast). */
function pfd_class(array $c): string
{
    $cl = (string)($c['class'] ?? pfd_class_map()[(string)($c['slug'] ?? '')] ?? '');
    return isset(pfd_classes()['classes'][$cl]) ? $cl : 'Beast';
}

/** data/pf_creature_pieces.txt: slug => ['lean' => family, 'P' => [piece, x3]]. */
function pfd_uniques(): array
{
    static $U = null;
    if ($U !== null) return $U;
    $U = [];
    foreach (pf_data_lines('pf_creature_pieces.txt') as $r) {
        if (count($r) < 8) continue;
        $U[$r[0]]['lean'] = $r[1]; $U[$r[0]]['P'][] = pfd_foe_cells(array_slice($r, 2));
    }
    return $U;
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

// ----------------------------------------------------------------- the creature's layered deck

/** The archetype value of a creature ($v in pf_foe_deck): its piece values are multiples of this. */
function pfd_foe_v(array $c): int
{
    return max(1, (int)round((((int)($c['dmg_die'] ?? 4) + 1) / 2 + (int)($c['dmg_bonus'] ?? 0)) * (($c['size'] ?? '') === 'boss' ? PF_FOE_BOSS : PF_FOE_DMG)));
}

/**
 * The creature's pieces by layer, in layer order: [['k', 'n', 't', 'v', 'r', 'tag', 'life', 'col', 'layer'], ...] (values before the board factors).
 * $region = the region code the fight is in ('' or unknown: no region piece). The class lean is the column family of 3 pieces in 5 (in this order); the others stack in their type family.
 */
function pfd_foe_pieces(array $c, string $region = ''): array
{
    $size = (string)($c['size'] ?? 'small'); $big = $size === 'large' || $size === 'boss'; $v = pfd_foe_v($c);
    $cl = pfd_class($c); $K = pfd_classes(); $slug = (string)($c['slug'] ?? ''); $u = pfd_uniques()[$slug] ?? null;
    $lean = in_array($u['lean'] ?? '', PFD_FAM, true) ? $u['lean'] : $K['classes'][$cl]['lean'];
    $out = []; $n = [];
    $add = function (string $layer, array $q) use (&$out, &$n, $v, $lean) {
        $i = count($out); $n[$layer] = ($n[$layer] ?? -1) + 1;
        $out[] = ['k' => 'f:' . ['base' => 'b', 'reg' => 'g', 'rar' => 'x', 'uni' => 'u'][$layer] . $n[$layer], 'n' => $q['n'], 't' => $q['t'], 'v' => max(1, (int)round($q['m'] * $v)), 'r' => $q['r'], 'tag' => $q['tag'], 'life' => $q['life'],
            'col' => $i % 5 < 3 ? $lean : (PF_HOLE[$q['t']] ?? 'body'), 'layer' => $layer];
    };
    foreach ($K['classes'][$cl]['P'] as $q) $add('base', $q);
    $rg = pfd_region_pieces()[$region] ?? null;
    if ($rg) { if ($big && isset($rg['hurt'])) $add('reg', $rg['hurt']); if (isset($rg['other'])) $add('reg', $rg['other']); }
    foreach ($K['extra'][$size] ?? [] as $q) $add('rar', $q);
    foreach ($u['P'] ?? [] as $q) $add('uni', $q);
    return $out;
}

/** The creature row with its layered deck ('deck', read by pf_foe_deck), its class and lean. A boss plays in a set order: one set-up piece (trick, guard, heal), then two Hurt pieces, and again. */
function pfd_foe_row(array $c, string $region = ''): array
{
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
    $u = pfd_uniques()[(string)($c['slug'] ?? '')] ?? null;
    return in_array($u['lean'] ?? '', PFD_FAM, true) ? $u['lean'] : pfd_classes()['classes'][pfd_class($c)]['lean'];
}

// ----------------------------------------------------------------- the player's deck (pure: from a sources array)

/** The catalogue row of a deck key ('swing#2' = a second copy of a basic), or null. */
function pfd_piece(string $key): ?array
{
    return pfd_catalog()[explode('#', $key)[0]] ?? null;
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
        'crops' => [], 'crafts' => [], 'regions' => [],   // crop kind / recipe category / region code => rank 1-4
        'auto' => false];
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
    $starter = $chosen ? array_values($src['starter']) : array_merge(PFD_CORE, pfd_offer_keys($cal, (string)$src['home'], PFD_KITS[PFD_KIT_DEFAULT]));
    $rankOf = function (array $p) use ($src): int {   // the rank of a piece: fixed in the file, or the rank of the gnome's source (at least Common)
        if ($p['rar'] !== 'src') return (int)$p['rar'];
        $have = ['crop' => $src['crops'], 'craft' => $src['crafts'], 'region' => $src['regions'], 'tool' => $src['tools']][$p['src']] ?? [];
        return max(1, min(4, (int)($have[$p['ref']] ?? 1)));
    };
    $owned = function (array $p) use ($src, $lvl, $cal): bool {
        switch ($p['src']) {
            case 'basic': return $p['k'] !== 'breather';
            case 'knack': return $lvl >= (int)$p['ref'];
            case 'calling': return $p['ref'] !== '' && $p['ref'] === $cal;
            case 'crop': return isset($src['crops'][$p['ref']]);
            case 'craft': return isset($src['crafts'][$p['ref']]);
            case 'region': return isset($src['regions'][$p['ref']]);
        }
        return false;   // tool pieces come from the belt
    };
    $entry = function (string $key, array $p, int $rank, array $x = []): array {
        $e = ['key' => $key, 'k' => $p['k'], 'n' => $p['n'], 't' => $p['t'], 'v' => (int)$p['v'], 'r' => $p['r'], 'tag' => (string)$p['tag'], 'src' => $p['src'], 'ref' => (string)($p['ref'] ?? ''), 'rank' => $rank,
            'life' => (int)($p['life'] ?? 0) ?: ($rank >= 4 ? 4 : ($p['tag'] === 'quick' ? 2 : ($p['tag'] === 'hold' ? 4 : PFB_LIFE))), 'blurb' => (string)($p['blurb'] ?? ''),
            'gear' => false, 'tool' => '', 'starter' => false, 'core' => false, 'on' => false, 'out' => ''];
        foreach (['col', 'up'] as $f) if (isset($p[$f])) $e[$f] = $p[$f];
        return $x + $e;
    };
    $pieces = []; $seen = [];
    foreach ($starter as $key) {   // the starter first, in the order it was packed
        $p = pfd_piece((string)$key); if (!$p || isset($seen[$key]) || $p['src'] === 'tool') continue; $seen[$key] = 1;
        $pieces[] = $entry((string)$key, $p, $rankOf($p), ['starter' => true, 'core' => in_array($key, PFD_CORE, true), 'on' => (bool)($src['state'][$key] ?? true)]);
    }
    foreach ($C as $key => $p) {   // then everything else the gnome owns: crop, craft and region pieces are on unless switched off; knacks and the rest are off unless switched on
        if (isset($seen[$key]) || !in_array($p['src'], PFD_PLAYER_SRC, true) || !$owned($p)) continue;
        $pieces[] = $entry($key, $p, $rankOf($p), ['on' => (bool)($src['state'][$key] ?? in_array($p['src'], ['crop', 'craft', 'region'], true))]);
    }
    $belt = pfd_belt($src);
    foreach ($belt as $b) {   // gear: the tools on the belt that work
        $p = $C['t:' . $b['type']] ?? null; if (!$p || $b['state'] !== 'ok') continue;
        $pieces[] = $entry('t:' . $b['type'], $p, $rankOf($p), ['gear' => true, 'tool' => $b['type'], 'on' => true]);
    }
    foreach ($src['pals'] as $q) {   // gear: the active party's pals (generated, not authored: the value already carries the rarity)
        $nm = (string)($q['n'] ?? 'Pal'); $key = 'pal:' . $nm; if (isset($seen[$key])) continue; $seen[$key] = 1;
        $pieces[] = $entry($key, ['k' => $key, 'n' => $nm, 't' => (string)$q['t'], 'v' => (int)$q['v'], 'r' => $q['r'] ?? null, 'tag' => 'pal', 'src' => 'pal', 'ref' => (string)($q['ref'] ?? ''), 'life' => 0], max(1, min(3, (int)($q['rank'] ?? 1))), ['gear' => true, 'on' => true]);
    }
    $cnt = ['n' => 0, 'kit' => 0, 'belt' => 0, 'pals' => 0, 'hurt' => 0, 'rare' => 0, 'mw' => 0, 'src' => ['pal' => 0, 'tool' => 0, 'crop' => 0]];
    foreach ($pieces as $i => $e) {
        if (!$e['on']) continue;
        if ($e['rank'] === 3 && ++$cnt['rare'] > PFD_RARE_CAP) $pieces[$i]['out'] = 'cap';
        if ($e['rank'] === 4 && ++$cnt['mw'] > PFD_MW_CAP) $pieces[$i]['out'] = 'cap';
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

/** Why a deck may not be used, or null. $counts = pfd_build()['counts'] (or a whole build). */
function pfd_validate(array $counts): ?string
{
    $c = $counts['counts'] ?? $counts;
    if ((int)$c['kit'] < PFD_KIT_MIN) return 'Pack at least ' . PFD_KIT_MIN . ' kit pieces.';
    if ((int)$c['hurt'] < 1) return 'Bring at least one Hurt piece (the great creatures cannot be charmed).';
    if ((int)$c['rare'] > PFD_RARE_CAP) return 'At most ' . PFD_RARE_CAP . ' Rare pieces a deck. Take one out first.';
    if ((int)$c['mw'] > PFD_MW_CAP) return 'At most ' . PFD_MW_CAP . ' Masterwork piece a deck. Take the other one out first.';
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
        foreach (['col', 'up'] as $f) if (isset($e[$f])) $over[$f] = $e[$f];
        if ($e['tool'] !== '') $over['tool'] = $e['tool'];
        $deck[] = pf_make_tile($k, $stats, $b, $over);
    }
    return $deck;
}

/** The four authored edges of a deck entry (as the board gives them: pfb_v1_tile). */
function pfd_edges(array $e): array
{
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

/** Is the v1 setting on for anyone (Admins only or Everyone)? While it is Off the belts and the repair kit are not made, so players see nothing new in the shop or the craft lists. */
function pfd_live(): bool
{
    return !in_array((string)setting('pfight_v1'), ['', '0'], true);
}

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
            db_insert('shop_stock', ['shop_id' => $shop, 'item_id' => $id, 'price_min' => $price, 'price_max' => (int)round($price * 1.1), 'max_stock' => 1, 'restock_chance' => 40, 'current_stock' => 1, 'current_price' => $price]);
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
        $out[] = ['n' => (string)($pal['name'] ?? 'Pal'), 't' => $t, 'v' => 4 + min(4, (int)round($score[$t] / 2)) + 2 * $rar, 'r' => PFD_PAL_KNOB[(string)($pal['knob'] ?? '')] ?? $knob[$t], 'rank' => $rar + 1, 'ref' => (string)($pal['key'] ?? '')];
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
    $try(function () use (&$src, $u) { $src['pals'] = pfd_pal_pieces($u); });
    $try(function () use (&$src, $uid) {   // crops: a kind is owned once a crop of it was grown; its rank is the best food mastery among them
        require_once __DIR__ . '/food_mastery.php'; $kinds = pfd_crop_kinds();
        foreach (q('SELECT i.slug, m.eaten + m.grown AS n FROM user_food_mastery m JOIN items i ON i.id = m.item_id WHERE m.user_id = ? AND m.grown > 0', [$uid])->fetchAll() as $r) {
            $kind = $kinds[(string)$r['slug']] ?? ''; if ($kind === '' || !isset(pfd_catalog()['c:' . $kind])) continue;
            $src['crops'][$kind] = max((int)($src['crops'][$kind] ?? 1), max(1, min(4, food_mastery_tier((int)$r['n']))));
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
    if (is_string($picks)) { if (!isset(PFD_KITS[$picks])) return 'There is no such kit.'; $picks = pfd_offer_keys((string)$src['calling'], (string)$src['home'], PFD_KITS[$picks]); }
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

/** Switch a kit piece on or off ($on null = the other way). Refused when the deck would not be legal (kit size, a Hurt piece, the rarity caps) or in a fight. Returns an error or null. */
function pfd_toggle(int|array $u, string $key, ?bool $on = null): ?string
{
    $u = pfd_user($u); $uid = (int)$u['id'];
    if ($why = pfd_guard($u)) return $why;
    $src = pfd_sources($u); $b = pfd_build($src); $e = null;
    foreach ($b['pieces'] as $x) if ($x['key'] === $key) $e = $x;
    if (!$e) return 'You do not own that piece.';
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
        'pfd_equip' => pfd_equip_tool($u, (string)($in['tool'] ?? ''), isset($in['slot']) && ctype_digit((string)$in['slot']) ? (int)$in['slot'] : null),
        'pfd_unequip' => pfd_unequip($u, (string)($in['tool'] ?? '')),
        'pfd_remove' => pfd_remove_broken($u, (string)($in['tool'] ?? '')),
        'pfd_auto' => pfd_set_auto($u, (string)($in['on'] ?? '') === '1'),
        'pfd_fix' => pfd_fix($u, (string)($in['tool'] ?? '')),
        default => 'Unknown action.',
    };
    $ok = ['pfd_starter' => 'Puzzle box packed.', 'pfd_toggle' => 'Deck changed.', 'pfd_equip' => 'Tool on your belt.', 'pfd_unequip' => 'Tool off your belt.', 'pfd_remove' => 'Removed from your belt.', 'pfd_auto' => 'Saved.', 'pfd_fix' => 'Tool fixed.'];
    return [$err === null, $err ?? ($ok[$do] ?? 'Done.')];
}
