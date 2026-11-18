<?php
declare(strict_types=1);
/**
 * Puzzle Combat, BOARD mode: a shared 2D jigsaw board instead of a strip. Pure PHP like pfight.php (which supplies tiles, decks, effects and RNG).
 * Rules (claude/plan-puzzle-board.md):
 *  - The board is one open area (an invisible 7x5 lattice for placement). It starts with one or two of the creature's pieces out. Each turn you place up to 4 pieces, one at a time, each next to a piece already on the board.
 *  - A piece fits where its edge meets the neighbour's: knob into hole of the same family, or a flat edge (fits anything). Every touching edge must fit.
 *  - Placing a piece CONNECTS it, and its chain fires, NEWEST FIRST: the piece you placed plays, then the pieces linked to it, each for its owner, until the chain ends.
 *    A joint is linked only when both edges are knob/hole (a flat side breaks the chain and any combo across it).
 *  - A combo needs the piece before it in the chain to be the same owner's. Pieces expire after PFB_LIFE rounds, so the board turns over.
 */
require_once __DIR__ . '/pfight.php';

const PFB_W = 7, PFB_H = 5, PFB_LIFE = 3, PFB_MAX_PLACE = 1;   // one action a turn: place a piece, place the piece group you set aside, or set pieces aside (connect them in your hand)
const PFB_FOE_MIN = 2;                       // if the creature has fewer than this many pieces on the board after its turn, the board puts one out for it (it grows into place)
const PFB_GROUP_MAX = 3;                      // a set-aside group holds 2 or 3 pieces; a 3-piece group cannot take more
const PFB_GROUP_MULT = [2 => 1.0, 3 => 2.0]; // the values of a placed group's pieces (3 pieces play for maximum effect; 2.6.66: x2.0, was 1.5 in 2.6.63 and 1.25 before, which never paid for the turns it takes)
const PFB_SETASIDE_GUARD = 1.0;               // 2.6.66: setting a piece aside (join/add) braces you: guard equal to this x the value of the piece you just set aside
const PFB_FOE_FIRES = 2;                      // 2.6.63 fire budget: a CREATURE piece falls away after it has fired this many times (its placement is the first; 0 = off). Your own pieces are not limited (they only expire). Tuned with tests/pfboard_tune.php: it removes the creature's re-fire cascades
const PFB_FOE_FIRE_MULT = 1.15;              // 2.6.63: the creature's pieces count this much more once they are limited, so good players find it about as hard as before (weaker players gain a little)
const PFB_BOSS_MULT = 1.2;                    // 2.6.63: a boss's pieces count this much more (bosses cost ~11% HP at their own level, large creatures ~30%)
const PFB_BLANK_FOE_MULT = 1.0;              // 2.6.66: was 1.2 (2.6.63). Agent rounds: blank played harder than classic at 1.2; bots show 1.0 is level (tests/pfboard_tune.php)
const PFB_BAR_MULT = 0.7, PFB_FOE_MULT = 0.62;   // the resolve bar vs strip mode, and a factor on the creature's piece values (one piece a turn each side). Tuned by tests/pfboard_sim.php: small 3.2, medium 4.2, large 4.5, boss 6.6 turns, defeats under 3%
const PFB_SIDE = ['L' => [-1, 0, 'R'], 'R' => [1, 0, 'L'], 'T' => [0, -1, 'B'], 'B' => [0, 1, 'T']];   // side => [dx, dy, the neighbour's side that touches it]

// ---------------------------------------------------------------- v1 board rules (2.6.74; admin setting pfight_v1). A fight started with opt 'v1' carries $s['v1'] (its rule numbers); every other fight plays exactly as before.
const PFB_SIZE = ['small' => [4, 4], 'medium' => [4, 4], 'large' => [4, 4], 'boss' => [4, 4]];   // the board (w, h) by creature size (the old rules: PFB_W x PFB_H for all). 2.6.94 (Josh): 4 x 4 for every size, going forward (it was 5x4, 5x5, 7x5, 7x6); ?pfboard=WxH or the setting pfight_board_test still gives a test board
const PFB_GROUND = ['small' => [2, 2, 1], 'medium' => [3, 2, 1], 'large' => [3, 3, 1], 'boss' => [4, 3, 1]];   // ground cells at the start: sunny, bramble, mud
const PFB_GROUND_DIST = [1, 2];               // ground cells lie this many steps from the centre (min, max)
const PFB_EVENTS = ['small' => 1, 'medium' => 2, 'large' => 2, 'boss' => 2];   // forecast events a round
const PFB_EVENT_KINDS = ['sunbeam', 'creep', 'gust', 'thorn', 'puddle'];   // drawn evenly
const PFB_EVENT_NAME = ['sunbeam' => 'Sunbeam', 'creep' => 'Bramble creep', 'puddle' => 'Puddle', 'gust' => 'Gust', 'thorn' => 'Thorn burst', 'bramble' => 'Bramble', 'poison' => 'Poison', 'place' => 'Environment', 'pass' => 'Environment', 'expire' => 'Environment'];
const PFB_USEUP = 3;                          // a chain that fires this many pieces or more uses up every piece that fired (both sides; 0 = off)
const PFB_SUN_MULT = 2.0;                     // a Hurt or Charm piece on a sunny cell counts this much
const PFB_BRAMBLE = 0.10, PFB_BRAMBLE_FOE = 0.5;   // bramble: share of max health a piece on it costs its owner each terrain turn (x PFB_BRAMBLE_FOE for a creature piece). 2.7.06 (Josh): halved on creatures (was 1.0; it took 14-21% of the creature's bar for free)
const PFB_THORN = 0.10, PFB_EVENT_FOE = 0.7;  // thorn burst: share of max health per piece in the zone; event damage on the creature is halved
const PFB_TEAM2 = 1.3, PFB_TEAM3 = 1.6;       // Teamwork: your pieces in a chain you start come from 2 / 3 of the sources pal, tool, crop
const PFB_TEAM_SRC = ['pal', 'tool', 'crop', 'craft', 'region', 'knack', 'calling'];   // 2.7.06: craft and region pieces count as sources too, so Teamwork can happen (it fired once in 20 turns with three)
const PFB_SRC = ['basic', 'knack', 'calling', 'tool', 'crop', 'craft', 'pal', 'region', 'legend', 'wear', 'creature', 'env'];   // where a piece comes from (tile field 'src')
const PFB_SRC_FAM = ['pal' => 'body', 'tool' => 'craft', 'crop' => 'mind', 'craft' => 'craft', 'legend' => 'mind', 'wear' => 'body'];   // authored edges: the column family (top and bottom) of a sourced piece; other pieces use their type family
const PFB_UP = ['hurt' => 1, 'charm' => 1, 'trick' => 1];   // these types carry the column knob on top and the hole below; guard, heal, soothe and item the other way round
const PFB_CLASS_LEAN = ['critter' => 'mind', 'insect' => 'mind', 'water' => 'body', 'bird' => 'craft', 'plant' => 'mind', 'fungus' => 'mind', 'reptile' => 'craft', 'amphibian' => 'craft', 'beast' => 'body'];   // a creature class leans to a family: 3 of its pieces in 5 stack in it
const PFB_LIFE_MIN = 2, PFB_LIFE_MAX = 4;     // per-piece life in rounds (tile field 'life'; default PFB_LIFE, Quick pieces 2, Hold pieces 4)
const PFB_COUNTER_ADD = 2;                    // 2.7.08 counter pieces: a piece of yours whose tile field 'cnt' names the creature's class (pfb_kind) counts this much more when it fires (claude/engine-2.7.08-notes.md)
const PFB_TOOL_WEAR = 2;                      // 2.6.74 (deck model): a fight tool loses this much durability each time ITS piece is played (tile field 'tool'; counted in $s['wear'], saved at the end of the fight)
// 2.6.75 ENVIRONMENT PIECES (Josh, after testing 2.6.74): no ground cells and no forecast marks. The environment is a third player: after the creature's turn it puts ONE piece from its own deck
// on the board (data/pf_env.txt), and its next piece lies face up a round ahead. Its pieces link and fire in chains like any piece; the effect goes to the side whose chain fires it.
// A v1 fight started under 2.6.74 has no $s['v1']['env'] and keeps its ground and events to the end.
const PFB_ENV_KINDS = ['sun', 'bramble', 'rain', 'wind', 'mud', 'thorn'];
const PFB_ENV_N = ['small' => 2, 'medium' => 2, 'large' => 2, 'boss' => 2];   // 2.7.06 (Josh: long fights got boring, one environment piece a turn was the only place to play): TWO a round again (1 since 2.6.98).   // pieces the environment places a round (Josh 2026-11-14: 1 everywhere; 2.6.75-2.6.97 had 2); as many lie face up a round ahead
const PFB_ENV_CAP = 0.7;                      // the environment places nothing while this share of the board's cells (or more) is taken
const PFB_MUD = 0.25;                         // Mud's teeth: a piece standing next to a Mud counts this much less when it fires (both sides)
const PFB_RAIN = 0.20;                        // 2.7.06 events matter more (Josh): Rain 0.15 -> 0.20, event damage on the creature 0.5 -> 0.7, Sun and Rain stay 3 rounds. Rain: guard for the side that fires it, a share of its maximum (your health, the creature's bar)
const PFB_THORN_FOE = 0.5;                    // Thornburst fired by the creature: x this (Josh, after Sim 5: 5% for the creature, 10% for you)
const PFB_ENV_EDGE = ['h' => 'hole', 'k' => 'knob', 'b' => 'body', 'm' => 'mind', 'c' => 'craft'];
const PFB_V1_FOE_MULT = ['small' => 0.93, 'medium' => 0.735, 'large' => 0.428, 'boss' => 0.60];   // 2.7.01 (policy D, claude/creature-pass/balance-report.md): 2.7.00 values x option A (chain bot about 80% at level for every size; the 2.7.00 values gave 85 / 95 / 93 / 90): was 0.855 / 0.48 / 0.378 / 0.585.   // week-1 retune (T13): was 0.95 / 0.60 / 0.42 / 0.585 (one shared bar, aim total, redraw and free pass made the chain bot too strong: 95 / 92 / 90 / 91%; now 79 / 80 / 82 / 78%). After 2.6.94 (AIMSTICK): boss x1.3 (was 0.45) with its bar x0.8, so a boss hits harder in a shorter fight: chain bot at level 88 -> 88-90% (94% with AIMSTICK alone), 4 under 76 -> 73-75%, 8 under 50%, fights 8.7 -> 7.6 turns. Medium and large also take the level curve PFB_V1_LEVEL.   // 2.6.79 retune for isolated environment pieces (the creature fires them more): was 1.0 / 0.67 / 0.53 / 0.66.   // the creature's piece values by size (replaces PFB_FOE_MULT 0.62; boss, blank and fire-budget factors still apply). 2.6.75 retune for ENVIRONMENT PIECES (no ground, so nothing shortens a fight for free): tests/pfboard_tune_v1.php, chain bot about 70% at level, claude/design-board-strategy.md "Sim 5" (second retune: 2 environment pieces a round, Mud's teeth, Thornburst halved on the creature; with 1 piece a round it was 1.0 / 0.70 / 0.53 / 0.66 and bars 0.75 / 0.92 / 1.05 / 0.66). 2.6.74 (ground and events, stage B) had 0.76 / 0.56 / 0.42 / 0.53 with bars 1.0 / 1.3 / 1.6 / 1.0; a fight started then keeps those numbers in its state
const PFB_V1_BAR_MULT = ['small' => 1.378, 'medium' => 1.7743, 'large' => 1.7193, 'boss' => 0.9158];   // 2.7.01 (policy D): was 1.325 / 1.491 / 1.495 / 0.825.   // week-1 retune (T13): was 0.828 / 0.994 / 1.15 / 0.611, longer bars for 6-8 turn fights, see PFB_V1_FOE_MULT. After 2.6.94: boss x0.8 (was 0.764), see PFB_V1_FOE_MULT.   // 2.6.79: x0.92 (was 0.90 / 1.08 / 1.25 / 0.83)   // the creature's bars by size (replaces PFB_BAR_MULT)

// LEVEL CURVE (after 2.6.94, AIMSTICK retune; claude/design-board-strategy.md targets, sims in tests/pfboard_tune_v1.php): one factor f by the creature's size and level,
// f = clamp(1 + slope x (level - ref), lo, hi), as [slope, ref, lo, hi]. Its piece values are x f; its bar is x min(1, f), so a weak creature is also shorter, a strong one only hits harder.
// Why: the gnome grows faster than the creature (health 20 + 3L, deck and tools step up), so with flat size factors the first creatures of a size were walls (medium lv 5-10 and
// large lv 11-15 about 55-60% for the chain bot at level, sun-lizard / carrion-crow under 30%) and the late ones were free (medium lv 16+ and large lv 26+ about 90-96%).
// Medium: 0.85 at lv 9 or less, 1.0 at 12, 1.35 from 19. Large: 0.85 at lv 16 or less, 1.0 at 22, 1.10 from 26 (a steeper large curve cost too much at 8 under).
// Small (lv 1-5) and bosses (all lv 26-35) are flat: the boss retune is in PFB_V1_FOE_MULT / PFB_V1_BAR_MULT. Reconciles two sim reviews (balance "r4": medium lv 5-9 only;
// difficulty "Proposal A": medium, large and boss by level) into this one curve; chain bot at level is then 76-87% in nearly every size x 5-level band (was 57-96%; left: medium lv 1-5 = orb-spider alone 62%, bosses lv 26-30 92%).
// 2.7.01 (policy D): small creatures now run to level 40 (variants), so small has a curve: x1.0 up to level 6, then +5% a level to x1.8 (a small at level 25 was 100% for the chain bot at level and 4 under).
const PFB_V1_LEVEL = ['small' => [0.05, 6, 1.0, 1.8], 'medium' => [0.05, 12, 0.85, 1.25], 'large' => [0.025, 22, 0.85, 1.10], 'boss' => [0.0, 1, 1.0, 1.0]];
// 2.7.01 (policy D): the Yield bar of a MEDIUM creature is eased at low levels so a gnome 4 levels under it does not fall off a cliff: bar x clamp(floor + (1 - floor) x (L - from) / (to - from), floor, 1).
const PFB_V1_BAR_EASE_MEDIUM = [0.30, 12, 26];   // [floor, level it starts to rise, level it is 1.0]
const PFB_V1_BAR_EASE_SMALL = [0.30, 14, 30];    // 2.7.01 balance pass 2: the same ease for the small creatures (they now run to level 40, so a gnome 4 levels under a lv 6-20 small fell off a cliff)
/** The bar factor of PFB_V1_BAR_EASE_MEDIUM / _SMALL for a size and creature level (1.0 for every other size, and with no level). */
function pfb_bar_ease(string $size, int $lv): float
{
    if (($size !== 'medium' && $size !== 'small') || $lv <= 0) return 1.0;
    [$f, $a, $b] = $size === 'small' ? PFB_V1_BAR_EASE_SMALL : PFB_V1_BAR_EASE_MEDIUM;
    return pf_round(max($f, min(1.0, $f + (1.0 - $f) * ($lv - $a) / ($b - $a))), 4);
}
/** data/pf_creature_tune.txt (slug|foe_x|bar_x): the per-creature multipliers of piece value and bar, [] for a creature with no row. $GLOBALS['PFB_TUNE'] (slug => ['foe_x' =>, 'bar_x' =>]) replaces the file (sims). */
function pfb_v1_tune(string $slug): array
{
    static $T = null;
    if (isset($GLOBALS['PFB_TUNE'])) return $GLOBALS['PFB_TUNE'][$slug] ?? [];
    if ($T === null) {
        $T = [];
        foreach (pf_data_lines('pf_creature_tune.txt') as $r) if (count($r) >= 2 && is_numeric($r[1])) $T[$r[0]] = ['foe_x' => (float)$r[1], 'bar_x' => (isset($r[2]) && is_numeric($r[2])) ? (float)$r[2] : 1.0];
    }
    return $T[$slug] ?? [];
}
/** The sim overrides of pfb_v1_cfg with the creature's tune row folded in (foe_x, bar_x multiply). */
function pfb_v1_over(array $c, array $over = []): array
{
    $t = pfb_v1_tune((string)($c['slug'] ?? ''));
    if ($t) { $over['foe_x'] = (float)($over['foe_x'] ?? 1.0) * $t['foe_x']; $over['bar_x'] = (float)($over['bar_x'] ?? 1.0) * $t['bar_x']; }
    return $over;
}
/** The 2.6.94 rule set for the keys added after it (compat: a saved fight without a key plays as before). Every new rule reads its key through pfb_v1r(), never $s['v1'][k] directly.
 *  aside = the set-aside group may be joined, must = a placed piece must connect, freepass = passing is free, flip1 = one flip a turn, nowm = Wind and Mud out of the environment deck,
 *  redraw = the hand is redrawn each round, onebar = one shared bar, aimtot = the aim shows its total, keepmine = your pieces survive use-up, aimhit = the aimed cell can be struck,
 *  useroot, kinds = class rules (later tasks). A NEW fight takes its defaults from pfb_v1_cfg (each task flips its own default); an old state falls back to this. */
const PFB_V1_ONEBAR_BAR = 1.15;   // 2.6.95: the shared bar is this much longer than the old creature health (rules.md: large 7.7 against 7.8 turns)
const PFB_V1_PRE = ['aside' => 1, 'must' => 1, 'freepass' => 0, 'flip1' => 1, 'nowm' => 0, 'nothorn' => 0, 'redraw' => 0, 'onebar' => 0, 'aimtot' => 0, 'keepmine' => 0, 'aimhit' => 0, 'useroot' => 0, 'kinds' => 0, 'blankrand' => 0, 'order' => 0, 'spawn' => 0, 'abil' => 0, 'style' => 0, 'cset' => 0, 'envopen' => 0, 'tagfx' => 0, 'paltgt' => 0];   // paltgt (2.7.08): a pal piece you place knocks the creature's strongest piece off the board (pfb_pal_target)
/** 2.6.98 class rules (switch kinds): one readable rule per creature class. Swarm: Critter plays 2 pieces a turn at x0.6. Grudge: Beast Hurt +25% per block (max 3). Venom: Reptile leaves venom 2 rounds, poison 2 x 2. */
const PFB_KIND_SWARM_ADD = 1, PFB_KIND_SWARM_MAX = 2, PFB_KIND_GRUDGE = 0.25, PFB_KIND_GRUDGE_MAX = 3, PFB_KIND_VENOM_RNDS = 2, PFB_KIND_VENOM_POISON = 2;
/**
 * 2.7.01 creature abilities (data/pf_creatures.txt column `ability`, claude/creature-pass/SPEC.md sec 2), behind the compat key `abil` (0 for fights saved before 2.7.01, 1 in new fights).
 * id => [group, base kind (E) or effect (N) or '' (D), tier, default params, name, card text (max 80)]. E = a class-rule kind with other numbers, N = a new engine effect, D = a deck signature (no engine work).
 * The creature row carries `ab` (the ids) and `abp` (id => overrides); pfb_new keeps the ids in $s['foe']['ab'] and the resolved numbers in $s['foe']['abp'].
 */
const PFB_ABIL = [
    'swarm' => ['E', 'critter', 0, [], 'Swarm', 'Its Hurt hits +1 for every 2 of its other pieces on board, up to +2'],
    'swarm-dense' => ['E', 'critter', 1, ['smax' => 3], 'Dense Swarm', 'Its Hurt hits +1 for every 2 of its other pieces on board, up to +3'],
    'two-aims' => ['E', 'bird', 0, [], 'Two aims', 'It shows two cells; take the first and it plays the second'],
    'grudge' => ['E', 'beast', 0, [], 'Grudge', 'Each block of its aim makes its Hurt 25% harder, up to 3 times'],
    'grudge-fury' => ['E', 'beast', 1, ['gpct' => 0.35, 'gmax' => 2], 'Fury grudge', 'Each block of its aim makes its Hurt 35% harder, up to 2 times'],
    'grudge-slow' => ['E', 'beast', 1, ['gpct' => 0.15, 'gmax' => 5], 'Slow grudge', 'Each block of its aim makes its Hurt 15% harder, up to 5 times'],
    'current' => ['E', 'water', 0, [], 'Current', 'After its piece lands, one of your touching pieces slides 1 cell'],
    'current-hard' => ['E', 'water', 1, ['slide' => 2], 'Strong current', 'After its piece lands, one of your touching pieces slides up to 2 cells'],
    'grows' => ['E', 'plant', 0, [], 'Grows', 'After its turn a Bramble grows beside its piece (one of its own at a time)'],
    'grows-twin' => ['E', 'plant', 1, ['gcap' => 2], 'Twin growth', 'After its turn a Bramble grows beside its piece (up to 2 of its own)'],
    'venom-trail' => ['E', 'reptile', 0, [], 'Venom trail', 'Where its piece leaves is venom 2 rounds; your piece there poisons you 2 a round'],
    'venom-long' => ['E', 'reptile', 1, ['vrnds' => 3, 'vpoison' => 1], 'Long venom', 'Where its piece leaves is venom 3 rounds; your piece there poisons you 1 a round'],
    'two-turns' => ['E', 'boss', 0, [], 'Two turns', 'It also shows the piece it plays next round; that piece is forced'],
    'drain1' => ['N', 'drain', 1, ['pct' => 0.25], 'Drain', 'A hit that lands heals it by a quarter of the damage'],
    'drain2' => ['N', 'drain', 2, ['pct' => 0.5], 'Drain', 'A hit that lands heals it by half of the damage'],
    'plated1' => ['N', 'plated', 1, ['pct' => 0.03], 'Plated', 'Starts each turn with some guard'],
    'plated2' => ['N', 'plated', 2, ['pct' => 0.05], 'Plated', 'Starts each turn with a good deal of guard'],
    'enrage1' => ['N', 'enrage', 1, ['at' => 0.5, 'mult' => 1.15], 'Enrage', 'Past half its resolve, its Hurt hits 15% harder'],
    'enrage2' => ['N', 'enrage', 2, ['at' => 0.4, 'mult' => 1.25], 'Enrage', 'Past 40% of its resolve, its Hurt hits 25% harder'],
    'wary1' => ['N', 'wary', 1, ['mult' => 0.85], 'Wary', 'Your Charm fills 15% less'],
    'wary2' => ['N', 'wary', 2, ['mult' => 0.75], 'Wary', 'Your Charm fills 25% less'],
    'toughhide1' => ['N', 'toughhide', 1, ['cut' => 2], 'Tough hide', 'Your first Hurt each turn is 2 weaker'],
    'toughhide2' => ['N', 'toughhide', 2, ['cut' => 3], 'Tough hide', 'Your first Hurt each turn is 3 weaker'],
    'ambush1' => ['N', 'ambush', 1, ['mult' => 1.4, 'pierce' => 0], 'Ambush', 'Its first hit of the fight is 40% harder'],
    'ambush2' => ['N', 'ambush', 2, ['mult' => 1.7, 'pierce' => 1], 'Ambush', 'Its first hit of the fight is 70% harder and ignores guard'],
    'stagger1' => ['N', 'stagger', 1, ['pct' => 0.2], 'Stagger', 'A big hit leaves you one piece short next round'],
    'stagger2' => ['N', 'stagger', 2, ['pct' => 0.12], 'Stagger', 'Even a middling hit leaves you one piece short next round'],
    'regrow1' => ['N', 'regrow', 1, ['pct' => 0.02, 'turns' => 5], 'Regrow', 'Heals a little each turn at the start of a fight'],
    'regrow2' => ['N', 'regrow', 2, ['pct' => 0.03, 'turns' => 5], 'Regrow', 'Heals some each turn at the start of a fight'],
    'D1' => ['D', '', 0, [], 'Sharp', 'Its hits go through guard'],
    'D2' => ['D', '', 0, [], 'Venom spit', 'Its hits keep working'],
    'D3' => ['D', '', 0, [], 'Snare', 'It makes you lose pieces'],
    'D4' => ['D', '', 0, [], 'Flurry', 'It often plays twice'],
    'D5' => ['D', '', 0, [], 'Ram', 'Its guard becomes damage'],
    'D6' => ['D', '', 0, [], 'Shell', 'Its guard lasts'],
    'D7' => ['D', '', 0, [], 'Prickles', 'Blocked hits prick you'],
    'D8' => ['D', '', 0, [], 'Slip', 'It dodges your first hits'],
    'D9' => ['D', '', 0, [], 'Mender', 'It heals itself'],
    'D10' => ['D', '', 0, [], 'Bruiser', 'Heavy hits'],
    'D11' => ['D', '', 0, [], 'Wall', 'Lots of guard'],
    'D12' => ['D', '', 0, [], 'Mixed', 'A bit of everything'],
];
/** The allowed range of each overridable number (SPEC sec 2): base kind or effect => name => [lo, hi]. */
const PFB_AB_RANGE = [
    'critter' => ['smax' => [1, 4]], 'beast' => ['gpct' => [0.05, 0.5], 'gmax' => [1, 6]], 'water' => ['slide' => [1, 2]], 'plant' => ['gcap' => [1, 3]], 'reptile' => ['vrnds' => [1, 4], 'vpoison' => [1, 3]],
    'drain' => ['pct' => [0.15, 0.60]], 'plated' => ['pct' => [0.02, 0.07]], 'enrage' => ['at' => [0.35, 0.70], 'mult' => [1.10, 1.35]], 'wary' => ['mult' => [0.65, 0.92]], 'toughhide' => ['cut' => [1, 4]],
    'ambush' => ['mult' => [1.2, 2.0], 'pierce' => [0, 1]], 'stagger' => ['pct' => [0.08, 0.25]], 'regrow' => ['pct' => [0.01, 0.04], 'turns' => [3, 6]],
];
/** 'drain1+D1(a=b)' -> ['ids' => [...], 'p' => [id => [k => v]]] (unknown ids are dropped; an override outside its range is clamped; unknown names are dropped). */
function pfb_ab_parse(string $str): array
{
    $ids = []; $p = [];
    foreach (explode('+', $str) as $part) {
        $part = trim($part); if ($part === '' || $part === '-') continue;
        $o = [];
        if (preg_match('/^([^(]+)\((.*)\)$/', $part, $m)) { $part = trim($m[1]); foreach (explode(';', $m[2]) as $kv) { $kv = explode('=', $kv, 2); if (count($kv) === 2 && is_numeric(trim($kv[1]))) $o[trim($kv[0])] = (float)trim($kv[1]); } }
        if (!isset(PFB_ABIL[$part]) || in_array($part, $ids, true)) continue;
        $ids[] = $part;
        $a = PFB_ABIL[$part]; $rng = PFB_AB_RANGE[$a[1]] ?? [];
        foreach ($o as $k => $v) { if (!isset($a[3][$k])) continue; $r = $rng[$k] ?? null; $p[$part][$k] = $r ? max($r[0], min($r[1], $v)) : $v; }
    }
    return ['ids' => $ids, 'p' => $p];
}
/** The resolved numbers of an ability in this fight ($s['foe']['abp'][id]) for an effect name ('drain' ...), or null. Off unless the fight has the `abil` rule. */
function pfb_ab(array $s, string $fx): ?array
{
    if (empty($s['foe']['ab']) || pfb_v1r($s, 'abil') !== 1) return null;
    foreach ($s['foe']['ab'] as $id) if ((PFB_ABIL[$id][1] ?? '') === $fx && PFB_ABIL[$id][0] === 'N') return $s['foe']['abp'][$id] ?? PFB_ABIL[$id][3];
    return null;
}
/** One number of the class-rule ability (E) of this fight: its override, else $d (the constant the 2.7.00 rule used). */
function pfb_abp(array $s, string $k, $d)
{
    if (empty($s['foe']['ab']) || pfb_v1r($s, 'abil') !== 1) return $d;
    foreach ($s['foe']['ab'] as $id) if ((PFB_ABIL[$id][0] ?? '') === 'E' && isset($s['foe']['abp'][$id][$k])) return $s['foe']['abp'][$id][$k];
    return $d;
}
/** pfb_new: the creature's abilities into the state (ids, resolved numbers; the E id replaces the class rule). Only when the fight has `abil` and the row carries `ab`. */
function pfb_ab_init(array &$s, array $c): void
{
    $ids = []; $abp = []; $po = (array)($c['abp'] ?? []);
    foreach ((array)$c['ab'] as $id) {
        if (!isset(PFB_ABIL[$id]) || in_array($id, $ids, true)) continue;
        $ids[] = $id; $a = PFB_ABIL[$id];
        if ($a[0] === 'D') continue;
        $abp[$id] = $a[3]; foreach ((array)($po[$id] ?? []) as $k => $v) if (isset($a[3][$k])) { $r = PFB_AB_RANGE[$a[1]][$k] ?? null; $abp[$id][$k] = $r ? max($r[0], min($r[1], (float)$v)) : $v; }
        if ($a[0] === 'E' && !empty($s['v1']['kinds'])) $s['foe']['kind'] = $a[1];
    }
    if (!$ids) return;
    $s['foe']['ab'] = $ids; $s['foe']['abp'] = $abp; $s['foe']['enr'] = 0; $s['foe']['amb'] = pfb_ab($s, 'ambush') ? 1 : 0; $s['foe']['turns'] = 0; $s['me']['tough'] = 0;
}
/** A notice for an ability (drain, stagger, regrow, plated): the page shows it as a chip and a log line, with the bars as they stand. */
function pfb_abnote(array $s, string $kind, string $n): array
{
    $e = pfb_note($kind, $n);
    $e['barnow'] = pf_round((float)$s['bar']['now'], 1); $e['fhnow'] = pf_round((float)$s['fh']['now'], 1); $e['hpnow'] = (int)$s['me']['hp']; $e['gnow'] = (int)$s['me']['block'];
    return $e;
}
/** After one of its Hurt pieces landed $dmg on you (pf_apply): Drain heals it, Stagger shortens your next draw. $e gets 'drained' / 'staggered' for the notices. */
function pfb_ab_hit(array &$s, array &$e, int $dmg): void
{
    if ($dmg <= 0) return;
    if ($d = pfb_ab($s, 'drain')) { $h = $dmg * (float)$d['pct']; pf_foe_heal($s, $h); $e['drained'] = pf_round($h, 1); }
    if (($g = pfb_ab($s, 'stagger')) && $dmg >= (float)$g['pct'] * (float)$s['me']['max']) { $s['me']['slowdraw'] = 1; $e['staggered'] = 1; }
}
/** The start of its turn, after the poison tick: its turn count, Regrow, Plated. */
function pfb_ab_turn(array &$s, array &$ev): void
{
    $s['foe']['turns'] = (int)($s['foe']['turns'] ?? 0) + 1;
    $y = (float)$s['fh']['max'];
    if (($r = pfb_ab($s, 'regrow')) && $s['foe']['turns'] <= (int)$r['turns']) {
        $b = (float)$s['fh']['now'] + (float)$s['bar']['now']; pf_foe_heal($s, $y * (float)$r['pct']); $a = (float)$s['fh']['now'] + (float)$s['bar']['now'];
        if ($a < $b) $ev[] = pfb_abnote($s, 'regrow', (string)pf_round($b - $a, 1));
    }
    if ($p = pfb_ab($s, 'plated')) {
        $g = (int)ceil($y * (float)$p['pct']);
        if ($g > (int)$s['foe']['block']) { $s['foe']['block'] = $g; $ev[] = pfb_abnote($s, 'plated', (string)$g); }
    }
}
/** Enrage: set (once, never cleared) the first time the Yield bar is at or past its share of the bar (called from pf_check_end). */
function pfb_ab_enrage(array &$s): void
{
    if (!empty($s['foe']['enr']) || !($en = pfb_ab($s, 'enrage'))) return;
    $prog = !empty($s['v1']['onebar']) ? (float)$s['fh']['now'] + (float)$s['bar']['now'] : (float)$s['fh']['now'];
    if ($prog >= (float)$en['at'] * (float)$s['fh']['max']) $s['foe']['enr'] = 1;
}
/**
 * 2.7.01 creature AI (SPEC sec 3), behind the compat key `style` (0 = fights saved before 2.7.01 and the 2.7.00 scorer; 1 in new fights). One shared scorer (pfb_ai_score) with a weight vector per play style.
 * id => [dmg, bar, heal, guard, strip, setup, tempo, control, deny, force, early, late, name, text]. `early` / `late` multiply the dmg weight on its turns 1-2 / from turn 3 (state round). `balanced` is the 2.7.00 scorer
 * (a creature with it and no override keeps no weights in its state: pfb_score takes the 2.7.00 path, bit for bit). A creature row names its style in `ai` and up to 2 overrides in `aip` (each clamped to -2.5..2.5).
 */
const PFB_AI_KEYS = ['dmg', 'bar', 'heal', 'guard', 'strip', 'setup', 'tempo', 'control', 'deny', 'force', 'early', 'late'];
const PFB_AI = [
    'balanced'  => [1.0, -0.8, 0.0, 0.4, 0.3, 1.0, 1.0, 0.0, 0.0, 0.0, 1.0, 1.0, 'Balanced', 'Plays the best trade each turn'],
    'crowd'     => [0.8, -0.6, 0.0, 0.2, 0.2, 0.6, 0.8, 1.2, 1.0, 0.8, 1.0, 1.0, 'Crowd', 'Fills the board and shrinks your cells'],
    'blocker'   => [0.6, -0.8, 0.0, 1.0, 0.6, 0.8, 0.6, 0.3, 1.2, 0.2, 1.0, 1.0, 'Blocker', 'Sits where you want to play and strips your guard'],
    'burst'     => [1.5, -0.5, 0.0, 0.1, 0.1, 0.3, 0.5, 0.0, 0.0, 1.0, 1.6, 0.8, 'Burst', 'Biggest hit now, and pushes you into its pieces'],
    'stall'     => [0.5, -1.0, 0.3, 0.8, 0.5, 1.0, 2.0, 0.2, 0.6, 0.0, 0.6, 1.0, 'Stall', 'Delays you: a short draw, an extra piece, guard'],
    'healer'    => [0.7, -1.0, 1.2, 0.5, 0.3, 0.6, 0.6, 0.0, 0.0, 0.0, 1.0, 1.0, 'Healer', 'Prefers to recover and trades slowly'],
    'trickster' => [0.8, -0.8, 0.0, 0.3, 0.3, 1.8, 1.8, 0.2, 0.4, 0.2, 1.0, 1.0, 'Trickster', 'Trips, dodges and bashes before it hurts'],
    'poisoner'  => [0.9, -0.8, 0.0, 0.3, 0.2, 2.0, 1.0, 0.3, 0.0, 0.3, 1.0, 1.0, 'Poisoner', 'Poison and long set-ups first'],
    'guardian'  => [0.5, -0.9, 0.4, 1.5, 0.8, 0.8, 0.5, 0.1, 0.6, 0.0, 1.0, 1.0, 'Guardian', 'Big guard, Thorns and Hold, slow trades'],
    'ambusher'  => [0.9, -0.7, 0.0, 0.2, 0.1, 0.8, 0.6, 0.4, 0.2, 1.2, 0.4, 1.6, 'Ambusher', 'Quiet first turns, then hits hard'],
];
/** A style as weights by name (['id' => id, 'dmg' => ..., 'late' => ...]), with up to 2 overrides clamped to -2.5..2.5; null for an unknown id and for plain `balanced` (the 2.7.00 scorer). */
function pfb_ai_make(string $id, array $o = []): ?array
{
    if (!isset(PFB_AI[$id])) return null;
    $w = ['id' => $id]; foreach (PFB_AI_KEYS as $i => $k) $w[$k] = (float)PFB_AI[$id][$i];
    $n = 0;
    foreach ($o as $k => $v) { if ($n >= 2) break; if (!in_array($k, PFB_AI_KEYS, true) || !is_numeric($v)) continue; $w[$k] = max(-2.5, min(2.5, (float)$v)); $n++; }
    return ($id === 'balanced' && $n === 0) ? null : $w;
}
/** Every legal (hand piece, cell) of yours: [handIdx, x, y, joints] (the same cells as pfb_cells; the must-link test is made once). */
function pfb_my_moves(array $s): array
{
    $o = []; $must = pfb_must_link($s, 'me');
    foreach ($s['me']['hand'] as $i => $t) for ($y = 0; $y < pfb_h($s); $y++) for ($x = 0; $x < pfb_w($s); $x++) { $j = pfb_check($s, $t, $x, $y); if ($j !== null && (!$must || pfb_has_link($j))) $o[] = [$i, $x, $y, $j]; }
    return $o;
}
/** The distinct cells where one of your hand pieces may go. */
function pfb_reach(array $s): int { $c = []; foreach (pfb_my_moves($s) as $m) $c[$m[1] . ',' . $m[2]] = 1; return count($c); }
/** The features of one creature placement, after ($a) minus before ($b) (SPEC 3.2). $ctx caches the before-side numbers across one search. deny / force are computed only when the weight in $ctx['w'] is not 0 (else 0.0). Keys x_* are for the reason line. */
function pfb_feat(array $b, array $a, array &$ctx): array
{
    $w = $ctx['w'] ?? null;
    $barD = ($a['bar']['now'] - $b['bar']['now']) + ($a['fh']['now'] - $b['fh']['now']);
    $u = 0.05 * $a['me']['max']; $setup = 0.0; $tempo = 0.0; $dPz = 0; $dEv = 0; $dTh = 0; $dBa = 0; $dSl = 0; $dAg = 0;
    if (!empty($a['v1']['tags'])) {
        $pz = fn(array $z) => (int)($z['me']['poison'] ?? 0) * (int)($z['me']['poison_v'] ?? 0);
        $dPz = $pz($a) - $pz($b); $dEv = (int)$a['foe']['evade'] - (int)$b['foe']['evade']; $dTh = (int)$a['foe']['thorns'] - (int)$b['foe']['thorns'];
        $dBa = (int)($a['foe']['bashnext'] ?? 0) - (int)($b['foe']['bashnext'] ?? 0); $dSl = (int)($a['me']['slowdraw'] ?? 0) - (int)($b['me']['slowdraw'] ?? 0); $dAg = (int)($a['foe']['again'] ?? 0) - (int)($b['foe']['again'] ?? 0);
        $setup = $dPz + $u * (1.5 * $dEv + 0.6 * $dTh + $dBa * max(1.0, (float)$a['foe']['block'] / max(1.0, $u))); $tempo = $u * (1.0 * $dSl + 1.5 * $dAg);   // 2.7.06: a lent guard is worth the guard it will turn into damage (Barge planning)
    }
    $nf = fn(array $z) => min(4, count(array_filter($z['pcs'], fn($p) => $p['by'] === 'foe')));
    $deny = 0.0; $force = 0.0; $dReach = 0;
    if ($w !== null && (($w['deny'] ?? 0) != 0)) {
        $ctx['rb'] ??= pfb_reach($b); $dReach = $ctx['rb'] - pfb_reach($a); $deny = 0.1 * $a['me']['max'] * $dReach / max(1, $ctx['rb']);
    }
    if ($w !== null && (($w['force'] ?? 0) != 0)) {
        $mv = pfb_my_moves($a); $k = 0;
        foreach ($mv as $m) foreach ($m[3] as $j) if ($j[2] && ($a['pcs'][$j[1]]['by'] ?? '') === 'foe' && ($a['pcs'][$j[1]]['tile']['t'] ?? '') === 'hurt') { $k++; break; }
        $force = 0.1 * $a['me']['max'] * $k / max(1, count($mv));
    }
    return ['dmg' => (float)($b['me']['hp'] - $a['me']['hp']), 'bar' => (float)$barD, 'heal' => max(0.0, -$barD), 'guard' => (float)($a['foe']['block'] - $b['foe']['block']), 'strip' => (float)-($a['me']['block'] - $b['me']['block']),
        'setup' => (float)$setup, 'tempo' => (float)$tempo, 'control' => $u * ($nf($a) - $nf($b)), 'deny' => $deny, 'force' => $force,
        'x_pz' => $dPz, 'x_ev' => $dEv, 'x_th' => $dTh, 'x_ba' => $dBa, 'x_sl' => $dSl, 'x_ag' => $dAg, 'x_reach' => $dReach, 'x_n' => $nf($a)];
}
/** The dot product of the features with a weight vector (12 numbers by name); the dmg weight is x early on its turns 1-2 and x late from turn 3 (the state's round); a defeat is worth 50. */
function pfb_ai_score(array $b, array $a, array $w, array &$ctx): float
{
    $ctx['w'] = $w; $f = pfb_feat($b, $a, $ctx);
    $ramp = (int)$b['round'] <= 2 ? $w['early'] : $w['late'];
    return $w['dmg'] * $ramp * $f['dmg'] + $w['bar'] * $f['bar'] + $w['heal'] * $f['heal'] + $w['guard'] * $f['guard'] + $w['strip'] * $f['strip'] + $w['setup'] * $f['setup'] + $w['tempo'] * $f['tempo']
        + $w['control'] * $f['control'] + $w['deny'] * $f['deny'] + $w['force'] * $f['force'] + ($a['over'] === 'defeat' ? 50 : 0);
}
/** The state its next search starts from. With a style (foe.ai) the turn it will really play: its guard, Thorns and Evade are reset as its turn begins (a stale guard no longer counts for a Bash) and Plated and Regrow have run. Without: the state as it is (2.7.00). */
function pfb_foe_base(array $s): array
{
    if (empty($s['foe']['ai'])) return $s;
    pfb_begin($s, 'foe');
    if (!empty($s['foe']['ab'])) { $tmp = []; pfb_ab_turn($s, $tmp); }
    return $s;
}
/** The reason of a creature move, one line: 'Burst: hits you for 6, takes ground'. $m = [handIdx, x, y, ...] on the state $s as pfb_search saw it. */
function pfb_why(array $s, array $m): string
{
    $name = PFB_AI[(string)($s['foe']['aid'] ?? 'balanced')][12] ?? 'Balanced'; $w = $s['foe']['ai'] ?? null;
    if (!$w) { $w = ['id' => 'balanced']; foreach (PFB_AI_KEYS as $i => $k) $w[$k] = (float)PFB_AI['balanced'][$i]; }
    $b = pfb_foe_base($s); $a = $b; if (!empty($b['foe']['ab'])) $a['infoe'] = 1;
    if (pfb_place($a, 'foe', (int)$m[0], (int)$m[1], (int)$m[2]) === null) return $name . ': no move';
    if ($a['over'] === 'defeat') return $name . ': finishes you';
    $ctx = ['w' => $w]; $f = pfb_feat($b, $a, $ctx); $ramp = (int)$b['round'] <= 2 ? $w['early'] : $w['late'];
    $c = []; foreach (['dmg', 'heal', 'guard', 'strip', 'setup', 'tempo', 'control', 'deny', 'force'] as $k) { $v = $w[$k] * $f[$k] * ($k === 'dmg' ? $ramp : 1.0); if ($v > 1e-9) $c[$k] = $v; }
    $tx = [
        'dmg' => 'hits you for ' . (int)pf_round($f['dmg']), 'heal' => 'recovers ' . (int)pf_round($f['heal']), 'guard' => 'builds ' . (int)pf_round($f['guard']) . ' guard', 'strip' => 'strips ' . (int)pf_round($f['strip']) . ' of your guard',
        'setup' => $f['x_pz'] > 0 ? 'poisons you' : ($f['x_ev'] > 0 ? 'readies a dodge' : ($f['x_th'] > 0 ? 'raises thorns' : ($f['x_ba'] > 0 ? 'lends its guard to a bash' : 'sets up a lasting effect'))),
        'tempo' => $f['x_sl'] > 0 ? 'leaves you a piece short' : 'plays again', 'control' => 'takes ground, ' . (int)$f['x_n'] . ' out', 'deny' => 'fills ' . (int)$f['x_reach'] . ' of your cells', 'force' => 'pushes you into its Hurt pieces'];
    if (!$c) return $name . ': ' . ($f['bar'] > 0.05 ? 'the safest play, it gives ' . (int)pf_round($f['bar']) : 'the safest play');
    $k1 = null; foreach ($c as $k => $v) if ($k1 === null || $v > $c[$k1]) $k1 = $k;   // the largest contribution (the first on a tie), then the next if it is at least half as large
    $k2 = null; foreach ($c as $k => $v) if ($k !== $k1 && ($k2 === null || $v > $c[$k2])) $k2 = $k;
    return $name . ': ' . $tx[$k1] . ($k2 !== null && $c[$k2] >= 0.5 * $c[$k1] ? ', ' . $tx[$k2] : '');
}
/** The class rule a creature plays by: critter | bird | beast | water | plant | reptile, or boss (a boss plays the boss rule whatever its class); '' = none. */
function pfb_kind_of(array $c, string $size): string
{
    if ($size === 'boss') return 'boss';
    $cl = strtolower((string)($c['class'] ?? ''));
    foreach (['critter', 'bird', 'beast', 'water', 'plant', 'reptile'] as $k) if (str_starts_with($cl, $k)) return $k;
    return '';
}
/** The class rules in words (name, one sentence): the creature card and the page's chip say the same. */
const PFB_KIND_TEXT = [
    'critter' => ['Swarm', 'Its Hurt hits +1 for every 2 of its other pieces on the board (up to +2). Use up or outlast its pieces to shrink it.'],
    'bird' => ['Two aims', 'It shows two moves on different cells. Take the first cell and it plays the second; take both and it picks again.'],
    'beast' => ['Grudge', 'Each time you block its aim, its Hurt hits 25% harder (up to 3 times). A hit that lands on you clears it.'],
    'water' => ['Current', 'After its piece lands, one of your pieces touching it slides a cell away, if that cell is free.'],
    'plant' => ['Grows', 'After its turn it grows a Bramble beside its piece (one of its own at a time). Whoever chains the Bramble fires it.'],
    'reptile' => ['Venom trail', 'When one of its pieces leaves the board, that cell is venom for 2 turns. A piece of yours put there poisons you (2 a round, 2 rounds).'],
    'boss' => ['Two turns', 'It also shows the piece it will play next round. That piece is forced; its cell is chosen then.'],
];
/** The class rule of THIS fight ('' when the switch is off or an old state has none). */
function pfb_kind(array $s): string { return pfb_v1r($s, 'kinds') === 1 ? (string)($s['foe']['kind'] ?? '') : ''; }
/** The creature's bar in a NEW-rule fight (one shared bar, Hurt and Charm both fill it) is called its Yield: it yields when the bar is full (backed off by hurting, won over by charm).
 *  The one place for the word: 'Yield 23/40' as the label, 'Yield bar' in sentences. A 2.6.94 fight (V1.onebar 0) keeps "Creature health" and the Charm bar. The browser reads it from the page data (`yieldw`). */
const PF_YIELD = 'Yield';
/** The Yield bar a fight against this creature starts with (size and level only, as pf_new and pfb_new size it for a new fight): what the almanac and any map preview can honestly show instead of the old HP. */
function pfb_yield_max(array $c): int
{
    $size = (string)($c['size'] ?? 'small'); $boss = $size === 'boss'; $lv = max(1, (int)($c['level'] ?? 1));
    $base = max(6.0, pf_round(pf_pace($size) * ($boss ? PF_BAR_BOSS : PF_BAR_K) * (PF_BAR_BASE + PF_BAR_SLOPE * $lv), 1));
    $cfg = pfb_v1_cfg($size, pfb_v1_over($c), $lv);   // the same rule numbers pfb_new gives a new fight (the level curve shortens the bar of a weak creature)
    return (int)pf_round(pf_round(pf_round($base * $cfg['bar'], 1) * PFB_V1_ONEBAR_BAR, 1));
}
/** 'Yield bar 52': the almanac's words for a creature that is not in a fight. */
function pf_yield_phrase(array $c): string { return PF_YIELD . ' bar ' . pfb_yield_max($c); }
/** The almanac's numbers line for a creature: under the new rules (puzzle fights v1) its Yield bar, never its old HP; else the old words (health). */
function pf_foe_numbers(array $c, bool $newRules): string
{
    return ($newRules ? pf_yield_phrase($c) : 'health ' . (int)$c['hp']) . ', attack +' . (int)$c['attack'] . ', defence ' . (int)$c['defense'] . '.';
}

/** One compat rule of a fight: its own value, or the 2.6.94 value when the state has none (an older save, or no v1 rules at all). */
function pfb_v1r(array $s, string $k): int { return (int)($s['v1'][$k] ?? PFB_V1_PRE[$k] ?? 0); }

/** The level factor of a curve [slope, ref, lo, hi] at a creature level (see PFB_V1_LEVEL). */
function pfb_v1_lvx(array $c, int $lv): float { return pf_round(max((float)$c[2], min((float)$c[3], 1 + (float)$c[0] * ($lv - (int)$c[1]))), 4); }

/** The rule numbers of a v1 fight for a creature size and level; $over replaces single values (tests and sims: ['events' => 0] switches a rule off, 'foe_x' / 'bar_x' scale the creature,
 *  'lv' => [slope, ref, lo, hi] replaces the level curve). $level 0 = no level factor (lvx 1). */
function pfb_v1_cfg(string $size, array $over = [], int $level = 0): array
{
    if (!isset(PFB_SIZE[$size])) $size = 'medium';
    $g = PFB_GROUND[$size];
    $dims = (!empty($GLOBALS['PFB_TEST_SIZES'][$size]) ? $GLOBALS['PFB_TEST_SIZES'][$size] : PFB_SIZE[$size]);   // the tests of the board engine keep the old geometry (5x4 to 7x6) through this global; the game never sets it
    $cfg = ['w' => $dims[0], 'h' => $dims[1], 'ground' => 0, 'nsun' => $g[0], 'nbr' => $g[1], 'nmud' => $g[2], 'sun' => PFB_SUN_MULT, 'bramble' => PFB_BRAMBLE, 'br_foe' => PFB_BRAMBLE_FOE,
        'events' => 0, 'nev' => PFB_EVENTS[$size], 'thorn' => PFB_THORN, 'ev_foe' => PFB_EVENT_FOE, 'limit' => PFB_USEUP, 'aim' => 1, 'team2' => PFB_TEAM2, 'team3' => PFB_TEAM3,   // 2.7.06 (Josh): Teamwork is back on for new fights, +30% / +60% (2.6.95 had it off; fights under way keep their saved numbers)
        'edges' => 1, 'flip' => 1, 'life' => 0, 'tags' => 1, 'foe' => PFB_V1_FOE_MULT[$size], 'bar' => PFB_V1_BAR_MULT[$size],
        'env' => 1, 'envn' => PFB_ENV_N[$size], 'rain' => PFB_RAIN, 'th_foe' => PFB_THORN_FOE, 'mud' => PFB_MUD, 'envcap' => PFB_ENV_CAP, 'nowm' => 0, 'nothorn' => 0, 'aside' => 0, 'must' => 0, 'freepass' => 1, 'flip1' => 0, 'onebar' => 1, 'redraw' => 1, 'aimtot' => 1, 'aimhit' => 0, 'kinds' => 1, 'blankrand' => 1, 'order' => 1, 'spawn' => 0, 'abil' => 1, 'style' => 1, 'cset' => 1, 'envopen' => 0, 'tagfx' => 1, 'paltgt' => 1] + PFB_V1_PRE;   // paltgt 1 (2.7.08, Josh): pal targeting   // cset 1 (2.7.06, Josh): combos read the whole chain   // aimhit 0 (2.6.984, owner: a piece on its planned spot must not be removed: it picks somewhere else)   // aimhit 1 (2.6.98, T15 bake-off: keepmine / useroot stay off, see CHANGELOG)   // nowm 1 (2.6.95): no Wind or Mud in the deck; aside 0, must 0, freepass 1 (2.6.95): no set-aside, a piece need not link (you), passing is free; flip1 0 (2.6.95): flip any piece, any number of times; onebar 1 (2.6.95): one shared bar, Hurt + Charm; redraw 1 (2.6.95): the whole hand is redrawn each round; aimtot 1 (2.6.95): the aim carries its total   // 2.6.75: environment pieces (env); 'env' => 0 with 'ground' => 1, 'events' => 1 gives the 2.6.74 terrain
    foreach ($over as $k => $v) if (array_key_exists($k, $cfg) && is_numeric($v)) $cfg[$k] = is_int($cfg[$k]) ? (int)$v : (float)$v;
    if (isset($over['foe_x'])) $cfg['foe'] = pf_round($cfg['foe'] * (float)$over['foe_x'], 4);
    if (isset($over['bar_x'])) $cfg['bar'] = pf_round($cfg['bar'] * (float)$over['bar_x'], 4);
    $cfg['lvx'] = $level > 0 ? pfb_v1_lvx(is_array($over['lv'] ?? null) ? $over['lv'] : PFB_V1_LEVEL[$size], $level) : 1.0;   // the level curve: piece values x f, bar x min(1, f)
    $cfg['foe'] = pf_round($cfg['foe'] * $cfg['lvx'], 4); $cfg['bar'] = pf_round($cfg['bar'] * min(1.0, $cfg['lvx']), 4);
    if (!isset($over['ease']) || $over['ease']) $cfg['bar'] = pf_round($cfg['bar'] * pfb_bar_ease($size, $level), 4);   // 2.7.01: the medium low-level bar ease (sims: 'ease' => 0 switches it off)
    // 2.6.93 (Josh: "give me a version with a 4x4 board to test"): a test board. adventure.php?pfboard=4x4 (the session) or the setting pfight_board_test = 4x4 gives every fight that STARTS from then on that board, whatever the creature's size; ?pfboard=off clears it. Rules that name cells (ground, environment pieces) keep working on the smaller board.
    $bt = (string)($_SESSION['pfb_test'] ?? '') !== '' ? (string)$_SESSION['pfb_test'] : (function_exists('setting') ? (string)setting('pfight_board_test') : '');
    if ($bt !== '' && !isset($over['w']) && !isset($over['h']) && preg_match('/^([3-9])x([3-9])$/', $bt, $bm)) { $cfg['w'] = (int)$bm[1]; $cfg['h'] = (int)$bm[2]; }
    if (!$cfg['edges']) $cfg['flip'] = 0;   // only authored edges flip
    return $cfg;
}

// ---------------------------------------------------------------- 2.6.75 environment pieces

/** One edge of an environment piece from its data cell: hb / km / kc ... = hole or knob of body, mind, craft; f = flat (fits anything, never links); w = wild (fits and links with anything). */
function pfb_env_edge(string $c): array
{
    if ($c === 'w') return ['wild', null];
    if (strlen($c) === 2 && isset(PFB_ENV_EDGE[$c[0]], PFB_ENV_EDGE[$c[1]]) && ($c[0] === 'h' || $c[0] === 'k') && $c[1] !== 'h' && $c[1] !== 'k') return [PFB_ENV_EDGE[$c[0]], PFB_ENV_EDGE[$c[1]]];
    return ['flat', null];
}

/**
 * The environment's pieces and decks (data/pf_env.txt, cached): ['pieces' => [key => ['k' => 'e:KEY', 'n', 'env' => kind, 'ed' => the four edges, 'life', 'w' => copies by size, 'blurb']],
 * 'regions' => [code => [kind => copies more or fewer]]]. No file: no environment pieces (the environment passes every round).
 */
function pfb_env_table(): array
{
    static $T = null;
    if ($T !== null) return $T;
    $T = ['pieces' => [], 'regions' => []];
    foreach (pf_data_lines('pf_env.txt') as $r) {
        if ($r[0] !== '' && $r[0][0] === '=') {   // =REGION|kind+1,kind-1
            foreach (explode(',', $r[1] ?? '') as $b) if (preg_match('/^([a-z]+)([+-]\d+)$/', trim($b), $m) && in_array($m[1], PFB_ENV_KINDS, true)) $T['regions'][substr($r[0], 1)][$m[1]] = (int)$m[2];
            continue;
        }
        if (count($r) < 7 || !in_array($r[2], PFB_ENV_KINDS, true)) continue;
        $ed = array_map('trim', explode(',', $r[3])); $w = array_map('intval', explode('/', $r[5])); if (count($ed) !== 4 || count($w) !== 4) continue;
        $T['pieces'][$r[0]] = ['k' => 'e:' . $r[0], 'n' => $r[1], 'env' => $r[2], 'ed' => ['L' => pfb_env_edge($ed[0]), 'R' => pfb_env_edge($ed[1]), 'T' => pfb_env_edge($ed[2]), 'B' => pfb_env_edge($ed[3])],
            'life' => max(PFB_LIFE_MIN, min(PFB_LIFE_MAX, (int)$r[4])), 'w' => array_combine(array_keys(PFB_SIZE), $w), 'blurb' => $r[6]];
    }
    return $T;
}

/** The environment's deck for a creature size in a region, in file order (pfb_new shuffles it): each piece as often as its weight for the size, plus the region's lean by kind. */
function pfb_env_deck(string $size, string $region = '', bool $nowm = false, bool $nothorn = false): array
{
    if (!isset(PFB_SIZE[$size])) $size = 'medium';
    $T = pfb_env_table(); $bias = $T['regions'][$region] ?? []; $deck = [];
    foreach ($T['pieces'] as $p) {
        if ($nothorn && $p['env'] === 'thorn') continue;   // 2.7.01 learner rules: no Thornburst in a gnome's first fights
        if ($nowm && ($p['env'] === 'wind' || $p['env'] === 'mud')) continue;   // 2.6.95: the lean comes first in the table, then these two kinds go
        $n = max(0, (int)$p['w'][$size] + (int)($bias[$p['env']] ?? 0));
        for ($i = 0; $i < $n; $i++) $deck[] = ['k' => $p['k'], 'n' => $p['n'], 't' => 'env', 'v' => 0, 'r' => null, 'tag' => '', 'm' => '', 'src' => 'env', 'env' => $p['env'], 'life' => $p['life'], 'ed' => $p['ed']];
    }
    return $deck;
}

/** The environment turns pieces face up until as many lie open as it places a round ($s['env']['next'], a list; its discard is shuffled back in when the deck is empty; fewer when its pieces are on the board). */
function pfb_env_draw(array &$s): void
{
    while (count($s['env']['next']) < (int)$s['v1']['envn']) {
        if (!$s['env']['draw'] && $s['env']['discard']) { $s['env']['draw'] = pf_shuffle($s, $s['env']['discard']); $s['env']['discard'] = []; }
        if (!$s['env']['draw']) break;
        $s['env']['next'][] = array_pop($s['env']['draw']);
    }
}

/** Does a Mud stand next to the cell? (Mud's teeth: a piece next to a Mud counts less when it fires.) */
function pfb_mud_near(array $s, int $x, int $y): bool
{
    foreach (PFB_SIDE as [$dx, $dy]) { $n = pfb_at($s, $x + $dx, $y + $dy); if ($n && $n['by'] === 'env' && $n['tile']['env'] === 'mud') return true; }
    return false;
}

/**
 * Where the environment may put a piece. 2.6.79 (Josh: "Environment should try playing on two spaces that don't have anything connecting"; 2.6.78 only avoided LINKS, which still put its pieces next to the action):
 * an ISOLATED empty cell, with no piece on any of its 4 sides, so nothing connects to it. Of those, the 3 that lie FARTHEST (Manhattan distance) from every piece on the board (this turn's earlier environment piece
 * included) come back, farthest first, and the seeded draw picks one of them. Anyone may link to it later by placing next to it (the normal edge rule). Only when no isolated cell exists: a cell where the piece fits but links
 * to nothing, then any fitting cell (the 2.6.78 rules). Empty list = nothing fits.
 */
function pfb_env_cells(array $s, array $tile): array
{
    $iso = [];
    if ($s['pcs']) for ($y = 0; $y < pfb_h($s); $y++) for ($x = 0; $x < pfb_w($s); $x++) {
        if (isset($s['cell']["$x,$y"])) continue;
        foreach (PFB_SIDE as [$dx, $dy]) if (pfb_at($s, $x + $dx, $y + $dy)) continue 2;
        $d = 99; foreach ($s['pcs'] as $p) $d = min($d, abs($p['x'] - $x) + abs($p['y'] - $y));
        $iso[] = [$d, $y, $x];
    }
    if ($iso) { usort($iso, fn($a, $b) => [$b[0], $a[1], $a[2]] <=> [$a[0], $b[1], $b[2]]); return array_map(fn($o) => [$o[2], $o[1]], array_slice($iso, 0, 3)); }
    $fit = []; $link = [];
    for ($y = 0; $y < pfb_h($s); $y++) for ($x = 0; $x < pfb_w($s); $x++) { $j = pfb_check($s, $tile, $x, $y); if ($j === null) continue; $fit[] = [$x, $y]; if (pfb_has_link($j)) $link[] = [$x, $y]; }
    return array_values(array_filter($fit, fn($c) => !in_array($c, $link, true))) ?: $fit;
}

/** Wind: the arrow it gets when it is placed. A side where a piece stands with a free cell behind it, if there is one (L, R, T, B order, one drawn by the seeded roll); else any side. */
function pfb_env_wind_dir(array &$s, int $x, int $y): string
{
    $ok = [];
    foreach (PFB_SIDE as $d => [$dx, $dy]) {
        $n = pfb_at($s, $x + $dx, $y + $dy); $bx = $x + 2 * $dx; $by = $y + 2 * $dy;
        if ($n && $n['by'] !== 'none' && $bx >= 0 && $by >= 0 && $bx < pfb_w($s) && $by < pfb_h($s) && !isset($s['cell']["$bx,$by"])) $ok[] = $d;
    }
    if (!$ok) $ok = array_keys(PFB_SIDE);
    return $ok[pf_rand($s, count($ok))];
}

/**
 * The ENVIRONMENT'S TURN (after the creature's): it puts its face-up pieces on the board, one after the other in the order they lie, each on a cell drawn from pfb_env_cells, then turns new ones face up. Nothing fires.
 * A piece that fits nowhere is kept face up (a pass for that piece; the next one is still tried). While the board is PFB_ENV_CAP full or more it places nothing ('full').
 * A piece's life starts with the next round (born = this round + 1), so "2 rounds" are two of your turns. $s['envlog'] gets one note per piece.
 */
function pfb_env_place(array &$s): void
{
    $s['envlog'] = []; $keep = []; $P = ['x' => null, 'y' => null, 'me' => 0, 'foe' => 0.0];
    if (!$s['env']['next']) $s['envlog'][] = ['k' => 'pass'] + $P;
    foreach ($s['env']['next'] as $tile) {
        $full = count($s['cell']) >= (float)($s['v1']['envcap'] ?? 1) * pfb_w($s) * pfb_h($s);
        $cells = $full ? [] : pfb_env_cells($s, $tile);
        if (!$cells) { $s['envlog'][] = ['k' => 'pass'] + $P + ['kind' => $tile['env'], 'n' => $tile['n']] + ($full ? ['full' => 1] : []); $keep[] = $tile; continue; }
        [$x, $y] = $cells[pf_rand($s, count($cells))];
        if ($tile['env'] === 'wind') $tile['dir'] = pfb_env_wind_dir($s, $x, $y);
        $id = ++$s['pid']; $s['seq']++;
        $s['pcs'][$id] = ['id' => $id, 'by' => 'env', 'tile' => $tile, 'x' => $x, 'y' => $y, 'born' => $s['round'] + 1, 'seq' => $s['seq']];
        $s['cell']["$x,$y"] = $id;
        $L = ['k' => 'place', 'x' => $x, 'y' => $y, 'me' => 0, 'foe' => 0.0, 'id' => $id, 'kind' => $tile['env'], 'n' => $tile['n']];
        if (isset($tile['dir'])) $L['dir'] = $tile['dir'];
        $s['envlog'][] = $L;
    }
    $s['env']['next'] = $keep;
    pfb_env_draw($s);
}

/** An environment piece's effect costs a side a share of its maximum (your health, the creature's bar; guard does not help). Returns what it cost. */
function pfb_env_cost(array &$s, string $who, float $frac): float
{
    if ($frac <= 0) return 0.0;
    if ($who === 'me') { $d = max(1, (int)pf_round($frac * $s['me']['max'])); $s['me']['hp'] = max(0, $s['me']['hp'] - $d); return (float)$d; }
    $a = $frac * $s['fh']['max']; $s['fh']['now'] += $a; return $a;
}

/**
 * An environment piece fires in a chain started by $rb ('me' or 'foe'): its effect goes to that side. Returns its event (by 'env', env 'fire', kind, for = $rb, me / foe = what it cost each side,
 * guard = Rain's guard, moved = the piece Wind pushed). Sun does nothing here: pfb_fire doubles the firing side's pieces of the chain.
 */
function pfb_env_fire(array &$s, array $p, string $rb): array
{
    $t = $p['tile']; $kind = (string)$t['env']; $ot = $rb === 'me' ? 'foe' : 'me'; $v1 = $s['v1'];
    $e = ['by' => 'env', 'id' => $p['id'], 'root' => false, 'tag' => '', 'mod' => '', 'k' => $t['k'], 'n' => $t['n'], 't' => 'env', 'v' => 0, 'fit' => false, 'combo' => null,
        'env' => 'fire', 'kind' => $kind, 'for' => $rb, 'x' => $p['x'], 'y' => $p['y'], 'me' => 0, 'foe' => 0.0];
    if ($kind === 'bramble') $e[$ot] = pfb_env_cost($s, $ot, (float)$v1['bramble'] * ($ot === 'foe' ? (float)$v1['br_foe'] : 1.0));
    elseif ($kind === 'thorn') $e[$rb] = pfb_env_cost($s, $rb, (float)$v1['thorn'] * ($rb === 'foe' ? (float)$v1['th_foe'] : 1.0));
    elseif ($kind === 'rain') { $g = max(1, (int)pf_round((float)$v1['rain'] * ($rb === 'me' ? $s['me']['max'] : $s['fh']['max']))); $s[$rb]['block'] += $g; $e['guard'] = $g; $e['v'] = $g; }
    elseif ($kind === 'wind') {   // the piece next to it on the arrow's side slides one cell further along the arrow, if that cell is on the board and free (the blank never moves)
        $d = (string)($t['dir'] ?? 'R'); [$dx, $dy] = PFB_SIDE[$d]; $e['dir'] = $d;
        $x = $p['x'] + $dx; $y = $p['y'] + $dy; $nx = $x + $dx; $ny = $y + $dy; $q = pfb_at($s, $x, $y);
        if (empty($v1['nowind']) && $q && $q['by'] !== 'none' && $nx >= 0 && $ny >= 0 && $nx < pfb_w($s) && $ny < pfb_h($s) && !isset($s['cell']["$nx,$ny"])) {
            unset($s['cell']["$x,$y"]); $s['cell']["$nx,$ny"] = $q['id']; $s['pcs'][$q['id']]['x'] = $nx; $s['pcs'][$q['id']]['y'] = $ny;
            $e['moved'] = ['id' => $q['id'], 'by' => $q['by'], 'n' => $q['tile']['n'], 'x' => $nx, 'y' => $ny];
        }
    }
    $e['me'] = (int)$e['me']; $e['foe'] = pf_round((float)$e['foe'], 1);
    return $e;
}
function pfb_w(array $s): int { return $s['w'] ?? PFB_W; }
function pfb_h(array $s): int { return $s['h'] ?? PFB_H; }
/** The ground on a cell: 'sun', 'br', 'mud' or ''. */
function pfb_ter(array $s, int $x, int $y): string { return $s['ter']["$x,$y"] ?? ''; }

/** Where a piece comes from when its tile does not say: the base six are basic, the calling piece calling, pal: pieces pal, f: pieces creature, the rest knacks. */
function pfb_src(array $t): string
{
    if (isset($t['src']) && in_array($t['src'], PFB_SRC, true)) return $t['src'];
    $k = (string)($t['k'] ?? '');
    if (str_starts_with($k, 'pal:')) return 'pal';
    if (str_starts_with($k, 'f:')) return 'creature';
    if (in_array($k, PF_BASE_KEYS, true) || $k === 'breather') return 'basic';
    if (in_array($k, PF_CALLING_TILE, true)) return 'calling';
    return 'knack';
}

/** Authored edges: left = hole of the type family, right = knob of the family the piece leads into, top and bottom = one knob and one hole of the column family. No flat edges. */
function pfb_author_edges(array $t, string $col, ?bool $up = null): array
{
    $up ??= isset(PFB_UP[$t['t']]); $fam = PF_HOLE[$t['t']] ?? 'body';
    return ['L' => ['hole', $fam], 'R' => ['knob', $t['r'] ?? $fam], 'T' => [$up ? 'knob' : 'hole', $col], 'B' => [$up ? 'hole' : 'knob', $col]];
}

/** The family a creature leans to: its row's 'lean', else its class (PFB_CLASS_LEAN), else fixed by its slug. */
function pfb_lean(array $c): string
{
    $fam = ['body', 'mind', 'craft'];
    if (in_array($c['lean'] ?? '', $fam, true)) return $c['lean'];
    $cl = strtolower((string)($c['class'] ?? ''));
    foreach (PFB_CLASS_LEAN as $k => $f) if ($cl !== '' && str_contains($cl, $k)) return $f;
    return $fam[crc32((string)($c['slug'] ?? $c['name'] ?? '')) % 3];
}

/**
 * v1: give a tile its source, its life and its authored edges (tile fields 'src', 'life', 'ed'). What the tile already carries wins (authored per piece, see pf_make_tile):
 * 'src', 'life', 'edges' = all four edges, or 'col' = column family and 'up' = knob on top; 'edges' => false keeps the old hashed edges. $col = the column family for a piece without its own.
 */
function pfb_v1_tile(array $t, array $cfg, ?string $col = null): array
{
    $t['src'] = pfb_src($t);
    if ($cfg['life']) $t['life'] = max(PFB_LIFE_MIN, min(PFB_LIFE_MAX, (int)($t['life'] ?? ($t['tag'] === 'quick' ? 2 : ($t['tag'] === 'hold' ? 4 : PFB_LIFE)))));
    else unset($t['life']);
    unset($t['ed']);
    if (!$cfg['edges'] || (array_key_exists('edges', $t) && $t['edges'] === false)) return $t;
    $t['ed'] = is_array($t['edges'] ?? null) ? $t['edges'] : pfb_author_edges($t, (string)($t['col'] ?? PFB_SRC_FAM[$t['src']] ?? $col ?? PF_HOLE[$t['t']] ?? 'body'), isset($t['up']) ? (bool)$t['up'] : null);
    return $t;
}

/** v1: every tile of both decks gets its source, life and authored edges. The creature: 3 pieces in 5 (in deck order) stack in its lean family, the others in their type family. */
function pfb_v1_tiles(array &$s, array $c): void
{
    $order = array_flip(array_column(pf_foe_deck($c), 'k')); $lean = pfb_lean($c);
    foreach (['hand', 'draw', 'discard'] as $z) {
        foreach ($s['me'][$z] as $i => $t) $s['me'][$z][$i] = pfb_v1_tile($t, $s['v1']);
        foreach ($s['foe'][$z] as $i => $t) $s['foe'][$z][$i] = pfb_v1_tile($t, $s['v1'], ($order[$t['k']] ?? 0) % 5 < 3 ? $lean : null);
    }
}

/** How many rounds a piece stays out. */
function pfb_life(array $s, array $p): int
{
    if ($p['by'] === 'none') return 1;
    $base = !empty($s['v1']['life']) ? (int)($p['tile']['life'] ?? PFB_LIFE) : PFB_LIFE;
    return $base + (pfb_v1r($s, 'tagfx') === 1 && $p['by'] === 'me' && ($p['tile']['m'] ?? '') === 'sticky' ? 1 : 0) + (int)($p['xl'] ?? 0);   // 2.7.06: Sticky stays one round longer; 2.7.09 wear 'life'
}

/** A piece's tile goes back to its owner's discard (a flipped piece comes back the right way up). */
function pfb_discard(array &$s, array $p): void
{
    if ($p['by'] === 'none') return;
    $t = $p['tile']; unset($t['flip'], $t['ft'], $t['dir'], $t['kr']);   // kr: rounds a wear piece waited in your hand
    $s[$p['by']]['discard'][] = $t;
}

/** v1 ground: sunny, bramble and mud cells 1-2 steps from the centre (the counts by creature size). */
function pfb_seed_ground(array &$s): void
{
    $s['ter'] = []; if (!$s['v1']['ground']) return;
    $cx = intdiv(pfb_w($s), 2); $cy = intdiv(pfb_h($s), 2); $cand = [];
    for ($y = 0; $y < pfb_h($s); $y++) for ($x = 0; $x < pfb_w($s); $x++) { $d = abs($x - $cx) + abs($y - $cy); if ($d >= PFB_GROUND_DIST[0] && $d <= PFB_GROUND_DIST[1]) $cand[] = "$x,$y"; }
    $cand = pf_shuffle($s, $cand);
    foreach (['sun' => $s['v1']['nsun'], 'br' => $s['v1']['nbr'], 'mud' => $s['v1']['nmud']] as $kind => $n) for ($i = 0; $i < $n && $cand; $i++) $s['ter'][array_pop($cand)] = $kind;
}

/** An event puts ground on a cell (replacing what was there). There are never more cells of a kind than at the start: the oldest one goes. */
function pfb_ground_set(array &$s, int $x, int $y, string $kind): ?string
{
    unset($s['ter']["$x,$y"]); $s['ter']["$x,$y"] = $kind;
    $cap = max(1, (int)$s['v1'][['sun' => 'nsun', 'br' => 'nbr', 'mud' => 'nmud'][$kind]]); $have = array_keys($s['ter'], $kind, true);
    $dropped = null;
    while (count($have) > $cap) { $dropped = (string)array_shift($have); unset($s['ter'][$dropped]); }
    return $dropped;   // 2.7.05: the cell whose oldest patch faded (the replay shows it fade at this step, not at the end)
}

/** The terrain hurts the owner of a piece, a share of the maximum (guard does not help). Returns what it cost: health points for you, bar points for the creature ($tag 'thorn' is halved on the creature). */
function pfb_env_hurt(array &$s, string $who, float $frac, string $tag): float
{
    if ($frac <= 0) return 0.0;
    if ($who === 'me') { $d = max(1, (int)pf_round($frac * $s['me']['max'])); $s['me']['hp'] = max(0, $s['me']['hp'] - $d); return (float)$d; }
    if ($who === 'foe') { $a = $frac * (float)$s['v1'][$tag === 'thorn' ? 'ev_foe' : 'br_foe'] * $s['fh']['max']; $s['fh']['now'] += $a; return $a; }
    return 0.0;
}

/** A cell and its 4 neighbours. */
function pfb_zone(array $e): array
{
    $z = [[$e['x'], $e['y']]];
    foreach (PFB_SIDE as [$dx, $dy]) $z[] = [$e['x'] + $dx, $e['y'] + $dy];
    return $z;
}

/**
 * v1: the terrain turn (after the creature's turn): the announced events land in order (they move ground, push a piece or burst), then bramble pricks.
 * $s['envlog'] lists what happened, one note per event: ['k' => kind, 'x', 'y', 'me' => health you lost, 'foe' => bar points the creature lost, 'moved' / 'on' => the piece it touched].
 */
function pfb_env_turn(array &$s): void
{
    $s['envlog'] = [];
    if ($s['v1']['events']) foreach ($s['envs'] ?? [] as $e) {
        $on = pfb_at($s, $e['x'], $e['y']); $ob = $on && $on['by'] !== 'none' ? $on['by'] : null; $L = ['k' => $e['kind'], 'x' => $e['x'], 'y' => $e['y'], 'me' => 0, 'foe' => 0.0];
        if ($e['kind'] === 'gust') {
            $id = $s['cell'][$e['x'] . ',' . $e['y']] ?? null; [$dx, $dy] = PFB_SIDE[$e['dir']]; $nx = $e['x'] + $dx; $ny = $e['y'] + $dy; $L['dir'] = $e['dir'];
            if ($id !== null && $ob && $nx >= 0 && $ny >= 0 && $nx < pfb_w($s) && $ny < pfb_h($s) && !isset($s['cell']["$nx,$ny"])) {
                unset($s['cell'][$e['x'] . ',' . $e['y']]); $s['cell']["$nx,$ny"] = $id; $s['pcs'][$id]['x'] = $nx; $s['pcs'][$id]['y'] = $ny;
                $L['moved'] = ['id' => $id, 'by' => $ob, 'n' => $on['tile']['n'], 'x' => $nx, 'y' => $ny];
            }
        } elseif ($e['kind'] === 'thorn') {
            foreach (pfb_zone($e) as [$x, $y]) { $p = pfb_at($s, $x, $y); if ($p && $p['by'] !== 'none') $L[$p['by']] += pfb_env_hurt($s, $p['by'], (float)$s['v1']['thorn'], 'thorn'); }
        } else {
            if (($gone = pfb_ground_set($s, $e['x'], $e['y'], ['sunbeam' => 'sun', 'creep' => 'br', 'puddle' => 'mud'][$e['kind']])) !== null) $L['drop'] = $gone;
            if ($ob) $L['on'] = ['id' => $on['id'], 'by' => $ob, 'n' => $on['tile']['n']];
        }
        $L['me'] = (int)$L['me']; $L['foe'] = pf_round($L['foe'], 1);
        $s['envlog'][] = $L;
    }
    if ($s['v1']['ground']) {
        $B = ['k' => 'bramble', 'x' => null, 'y' => null, 'me' => 0, 'foe' => 0.0, 'ids' => []];
        foreach ($s['pcs'] as $p) if ($p['by'] !== 'none' && pfb_ter($s, $p['x'], $p['y']) === 'br') { $B[$p['by']] += pfb_env_hurt($s, $p['by'], (float)$s['v1']['bramble'], 'br'); $B['ids'][] = $p['id']; }
        $B['me'] = (int)$B['me']; $B['foe'] = pf_round($B['foe'], 1);
        if ($B['ids']) $s['envlog'][] = $B;
    }
    pf_check_end($s);
}

/** The terrain turn as events for the replay (after the creature's): by and ta 'env', env = the kind, the bars as they stand after the whole terrain turn. */
function pfb_env_events(array $s): array
{
    $ev = [];
    foreach ($s['envlog'] ?? [] as $L) {
        $e = ['by' => 'env', 'ta' => 'env', 'env' => $L['k'], 'tag' => '', 'k' => 'env:' . $L['k'], 'n' => PFB_EVENT_NAME[$L['k']] ?? 'Terrain', 't' => 'env', 'v' => 0, 'fit' => false, 'combo' => null,
            'x' => $L['x'], 'y' => $L['y'], 'me' => $L['me'], 'foe' => $L['foe']];
        foreach (['dir', 'moved', 'on', 'ids', 'id', 'kind', 'full', 'drop'] as $k) if (isset($L[$k])) $e[$k] = $L[$k];
        if (isset($L['n'])) $e['n'] = $L['n'];   // 2.6.75: an environment piece placed (or kept back): its name
        $e['barnow'] = pf_round((float)$s['bar']['now'], 1); $e['fhnow'] = pf_round((float)$s['fh']['now'], 1); $e['hpnow'] = (int)$s['me']['hp']; $e['gnow'] = (int)$s['me']['block'];
        $ev[] = $e;
    }
    return $ev;
}

/** One line of text for a terrain event (the fight log). */
function pfb_env_line(array $e, string $foe): string
{
    $cost = [];
    if (!empty($e['me'])) $cost[] = 'you lose ' . (int)$e['me'] . ' health';
    if (!empty($e['foe'])) $cost[] = 'the ' . $foe . ' loses ' . (int)pf_round((float)$e['foe']);
    $c = $cost ? ': ' . implode(', ', $cost) : '';
    $whose = fn(array $p) => ($p['by'] === 'me' ? 'your ' : 'the ' . $foe . '’s ') . $p['n'];
    switch ($e['env']) {
        case 'fire':   // 2.6.75: an environment piece fired in a chain; its effect went to the side that started the chain ('for')
            $me = ($e['for'] ?? 'me') === 'me';
            switch ($e['kind'] ?? '') {
                case 'sun': return '☀️ Sun: ' . ($me ? 'your pieces in this chain count double.' : 'the ' . $foe . '’s pieces in this chain count double.');
                case 'bramble': return '🌿 Bramble' . ($c !== '' ? $c : ': nothing happens') . '.';
                case 'thorn': return '🌵 Thornburst' . ($c !== '' ? $c : ': nothing happens') . '.';
                case 'rain': return '🌧️ Rain: ' . ($me ? 'you get ' : 'the ' . $foe . ' gets ') . (int)($e['guard'] ?? 0) . ' guard.';
                case 'wind': return isset($e['moved']) ? '💨 Wind: ' . $whose($e['moved']) . ' is pushed one cell.' : '💨 Wind: nothing moves.';
                default: return '🟫 ' . (string)$e['n'] . '.';
            }
        case 'place': return '🍃 The environment places ' . (string)$e['n'] . '.';
        case 'pass': return isset($e['kind']) ? (!empty($e['full']) ? '🍃 The board is full: the environment keeps ' . (string)$e['n'] . '.' : '🍃 The environment finds no place for ' . (string)$e['n'] . '.') : '🍃 The environment has no piece to place.';
        case 'expire': return '🍂 ' . (count((array)($e['ids'] ?? [])) === 1 ? 'An environment piece fades.' : count((array)($e['ids'] ?? [])) . ' environment pieces fade.');
        case 'sunbeam': return '☀️ Sunbeam: a cell turns sunny' . (isset($e['on']) ? ' under ' . $whose($e['on']) : '') . '.';
        case 'creep': return '🌿 Bramble creep: a cell turns to bramble' . (isset($e['on']) ? ' under ' . $whose($e['on']) : '') . '.';
        case 'puddle': return '💧 Puddle: a cell turns to mud' . (isset($e['on']) ? ', and ' . $whose($e['on']) . ' no longer links' : '') . '.';
        case 'gust': return isset($e['moved']) ? '💨 Gust: ' . $whose($e['moved']) . ' is pushed one cell.' : '💨 Gust: nothing moves.';
        case 'thorn': return '🌵 Thorn burst' . ($c !== '' ? $c : ': nothing in reach') . '.';
        case 'poison': return '🧪 The poison works on you' . $c . '.';
        default: return '🌿 Bramble pricks' . $c . '.';
    }
}

/** What the announced events will do to a piece of $who put on (x,y), in the search's score units (the creature knows the forecast). */
function pfb_env_bias(array $s, string $who, int $x, int $y, ?array $tile = null): float
{
    $b = 0.0; $m = $who === 'foe' ? 0.8 * $s['fh']['max'] : 0.7 * $s['me']['max'];
    foreach ($s['envs'] ?? [] as $e) {
        if ($e['kind'] === 'thorn') { foreach (pfb_zone($e) as [$zx, $zy]) if ($zx === $x && $zy === $y) $b -= (float)$s['v1']['thorn'] * ($who === 'foe' ? (float)$s['v1']['ev_foe'] : 1.0) * $m; }
        elseif ($e['x'] === $x && $e['y'] === $y) {
            if ($e['kind'] === 'creep') $b -= (float)$s['v1']['bramble'] * ($who === 'foe' ? (float)$s['v1']['br_foe'] : 1.0) * $m;
            elseif ($e['kind'] === 'sunbeam' && $tile && in_array($tile['t'], ['hurt', 'charm'], true)) $b += 0.3 * $tile['v'];
        }
    }
    return $b;
}

/** v1: announce the next events (shown before you move, they land after the creature's move): each on a cell on or next to a piece; a gust on a piece, with a direction that is free now. */
function pfb_forecast(array &$s): void
{
    $s['envs'] = []; if (!$s['v1']['events']) return;
    $cand = []; $pcs = [];
    foreach ($s['pcs'] as $p) {
        if ($p['by'] !== 'none') $pcs[] = $p['x'] . ',' . $p['y'];
        $cand[$p['x'] . ',' . $p['y']] = 1;
        foreach (PFB_SIDE as [$dx, $dy]) { $x = $p['x'] + $dx; $y = $p['y'] + $dy; if ($x >= 0 && $y >= 0 && $x < pfb_w($s) && $y < pfb_h($s)) $cand["$x,$y"] = 1; }
    }
    $keys = array_keys($cand);
    for ($i = 0; $i < (int)$s['v1']['nev'] && $keys; $i++) {
        $kind = PFB_EVENT_KINDS[pf_rand($s, count(PFB_EVENT_KINDS))]; $dir = null;
        if ($kind === 'gust') {
            if (!$pcs) continue;
            $key = $pcs[pf_rand($s, count($pcs))]; [$x, $y] = array_map('intval', explode(',', $key)); $dirs = [];
            foreach (PFB_SIDE as $d => [$dx, $dy]) { $nx = $x + $dx; $ny = $y + $dy; if ($nx >= 0 && $ny >= 0 && $nx < pfb_w($s) && $ny < pfb_h($s) && !isset($s['cell']["$nx,$ny"])) $dirs[] = $d; }
            if (!$dirs) $dirs = array_keys(PFB_SIDE);
            $dir = $dirs[pf_rand($s, count($dirs))];
            if (!in_array($key, $keys, true)) continue;   // that piece's cell already has an event
        } else {
            $gk = ['sunbeam' => 'sun', 'creep' => 'br', 'puddle' => 'mud'][$kind] ?? null;
            $ok = array_values(array_filter($keys, fn($k) => $gk === null || ($s['ter'][$k] ?? '') !== $gk)); if (!$ok) continue;
            $key = $ok[pf_rand($s, count($ok))];
        }
        $keys = array_values(array_diff($keys, [$key])); [$x, $y] = array_map('intval', explode(',', $key));
        $s['envs'][] = ['kind' => $kind, 'x' => $x, 'y' => $y, 'dir' => $dir];
    }
}

/** May the hand piece be flipped now? One flip a turn (2.6.94 fights: v1 flip1) or, from 2.6.95, any number; the piece flipped this turn may be flipped back (that gives the flip back). Only authored edges flip. */
function pfb_can_flip(array $s, int $handIdx): bool
{
    $t = $s['me']['hand'][$handIdx] ?? null;
    if (empty($s['v1']['flip']) || $s['over'] || !$t || !isset($t['ed'])) return false;
    if (!pfb_v1r($s, 'flip1')) return true;   // 2.6.95: no limit, any piece with edges, any number of times
    return (int)($s['me']['flipt'] ?? 0) !== (int)$s['turn'] || (int)($t['ft'] ?? 0) === (int)$s['turn'];
}

/** v1 FLIP: swap the top and bottom edges of a hand piece before placing it. Free, once a turn; it stays flipped while it is in your hand or on the board. Returns an error or null. */
function pfb_flip(array &$s, int $handIdx, int $turn): ?string
{
    if ($s['over']) return 'The fight is over.';
    if ($turn !== $s['turn']) return 'stale';
    if (empty($s['v1']['flip'])) return 'Pieces cannot be flipped in this fight.';
    $t = $s['me']['hand'][$handIdx] ?? null; if (!$t) return 'No such piece in your hand.';
    if (!isset($t['ed'])) return 'That piece cannot be flipped.';
    if (!pfb_can_flip($s, $handIdx)) return 'You have already flipped a piece this turn.';
    if (!pfb_v1r($s, 'flip1')) { /* 2.6.95: unlimited, nothing to remember */ }
    elseif ((int)($t['ft'] ?? 0) === (int)$s['turn']) { unset($t['ft']); $s['me']['flipt'] = 0; }   // flipped back: the flip is free again
    else { $t['ft'] = (int)$s['turn']; $s['me']['flipt'] = (int)$s['turn']; }
    if (!empty($t['flip'])) unset($t['flip']); else $t['flip'] = true;
    $s['me']['hand'][$handIdx] = $t;
    return null;
}

/** The four edges of a tile: L = hole of its type's family, R = its knob (or flat), T and B fixed per tile from its key (about a quarter flat). */
function pfb_edges(array $t): array
{
    if (($t['k'] ?? '') === 'blank') return ['L' => ['wild', null], 'R' => ['wild', null], 'T' => ['wild', null], 'B' => ['wild', null]];   // the blank centre piece (opt blank): fits and links with everything
    if (isset($t['ed'])) return empty($t['flip']) ? $t['ed'] : ['L' => $t['ed']['L'], 'R' => $t['ed']['R'], 'T' => $t['ed']['B'], 'B' => $t['ed']['T']];   // v1: authored edges (a flipped piece swaps top and bottom)
    static $cache = [];
    $key = $t['k'] . '|' . $t['t'] . '|' . ($t['r'] ?? '');
    if (isset($cache[$key])) return $cache[$key];
    $fam = ['body', 'mind', 'craft'];
    $mk = function (string $salt) use ($t, $fam): array {
        $h = crc32($t['k'] . $salt);
        if ($h % 4 === 0) return ['flat', null];
        return [intdiv($h, 4) % 2 ? 'knob' : 'hole', $fam[intdiv($h, 8) % 3]];
    };
    return $cache[$key] = ['L' => ['hole', PF_HOLE[$t['t']] ?? 'body'], 'R' => ($t['r'] ?? null) ? ['knob', $t['r']] : ['flat', null], 'T' => $mk('|T'), 'B' => $mk('|B')];
}

/** Do two touching edges fit? [fits, linked]: linked = both are knob/hole (so the chain runs through the joint). */
function pfb_joint(array $a, array $b): array
{
    if ($a[0] === 'wild' || $b[0] === 'wild') return [true, true];
    if ($a[0] === 'flat' || $b[0] === 'flat') return [true, false];
    return [$a[0] !== $b[0] && $a[1] === $b[1], $a[0] !== $b[0] && $a[1] === $b[1]];
}

function pfb_at(array $s, int $x, int $y): ?array
{
    $id = $s['cell']["$x,$y"] ?? null;
    return $id === null ? null : $s['pcs'][$id];
}

/** Can $tile go at (x,y)? Returns the joints [[side, pieceId, linked], ...] or null when illegal. */
function pfb_check(array $s, array $tile, int $x, int $y): ?array
{
    if ($x < 0 || $y < 0 || $x >= pfb_w($s) || $y >= pfb_h($s) || isset($s['cell']["$x,$y"])) return null;
    if (!$s['pcs']) return ($x === intdiv(pfb_w($s), 2) && $y === intdiv(pfb_h($s), 2)) ? [] : null;   // an empty board: the centre
    $e = pfb_edges($tile); $joints = [];
    foreach (PFB_SIDE as $side => [$dx, $dy, $opp]) {
        $n = pfb_at($s, $x + $dx, $y + $dy);
        if (!$n) continue;
        [$fits, $linked] = pfb_joint($e[$side], pfb_edges($n['tile'])[$opp]);
        if (!$fits) return null;
        $joints[] = [$side, (int)$n['id'], $linked && (empty($s['ter']) || (pfb_ter($s, $x, $y) !== 'mud' && pfb_ter($s, $x + $dx, $y + $dy) !== 'mud'))];   // v1: mud blocks links
    }
    if (!$joints && !empty($s['aimforce'])) return [];   // AIMSTICK (v1 aim): the creature's shown aim lands even when a use-up chain has left its cell touching nothing; only your piece on the cell, or an edge of yours that does not fit, breaks it
    return $joints ?: null;   // it has to touch something
}

/** Does a joint list contain a LINKED joint (a knob in a matching hole, so the chain runs)? */
function pfb_has_link(?array $joints): bool
{
    if ($joints) foreach ($joints as $j) if ($j[2]) return true;
    return false;
}

/**
 * The board's rule for where a side may play: a piece has to connect (make at least one linked joint) with a piece already out. Only when NOTHING in the side's hand
 * (or its set-aside group) can connect anywhere may it be put down somewhere else that fits. On an empty board the centre is the only spot (no connecting is possible).
 */
function pfb_must_link(array $s, string $who): bool
{
    if (!$s['pcs'] || ($who === 'me' && !pfb_v1r($s, 'must'))) return false;   // 2.6.95: v1 'must' 0 = the player may put a piece on any cell where it fits (the creature always links)
    foreach ($s[$who]['hand'] as $t) for ($y = 0; $y < pfb_h($s); $y++) for ($x = 0; $x < pfb_w($s); $x++) if (pfb_has_link(pfb_check($s, $t, $x, $y))) return true;
    $g = $s[$who]['held'] ?? null;
    if ($g) foreach (pfb_group_cells_all($s, $g) as $o) if ($o[2]) return true;
    return false;
}

/** Every legal [x, y] for a tile. With $who: only the spots that connect, when the side has any connecting move at all (see pfb_must_link). */
function pfb_cells(array $s, array $tile, ?string $who = null): array
{
    $o = []; $must = $who !== null && pfb_must_link($s, $who);
    for ($y = 0; $y < pfb_h($s); $y++) for ($x = 0; $x < pfb_w($s); $x++) { $j = pfb_check($s, $tile, $x, $y); if ($j !== null && (!$must || pfb_has_link($j))) $o[] = [$x, $y]; }
    return $o;
}

/** The pieces linked to one piece, newest first. */
function pfb_links(array $s, int $id): array
{
    $p = $s['pcs'][$id]; $e = pfb_edges($p['tile']); $o = [];
    foreach (PFB_SIDE as $side => [$dx, $dy, $opp]) {
        $n = pfb_at($s, $p['x'] + $dx, $p['y'] + $dy);
        if ($n && $n['by'] !== 'none' && pfb_joint($e[$side], pfb_edges($n['tile'])[$opp])[1] && (empty($s['ter']) || (pfb_ter($s, $p['x'], $p['y']) !== 'mud' && pfb_ter($s, $n['x'], $n['y']) !== 'mud'))) $o[] = $n;   // the blank centre piece lets a piece connect (placement) but a chain never runs through it
    }
    usort($o, fn($a, $b) => $b['seq'] <=> $a['seq']);
    return array_map(fn($n) => (int)$n['id'], $o);
}

/** The chain a piece starts: [[id, parentId|null], ...] in firing order (the piece itself, then what it links to, newest first, depth first). */
function pfb_chain(array $s, int $root): array
{
    $order = []; $seen = [];
    $walk = function (int $id, ?int $par) use (&$walk, &$order, &$seen, $s) {
        $seen[$id] = true; $order[] = [$id, $par];
        foreach (pfb_links($s, $id) as $n) if (!isset($seen[$n])) $walk($n, $id);
    };
    $walk($root, null);
    return $order;
}

/** Next release (Josh's vote): the order a chain's pieces take effect in. Environment pieces first, then defence (Guard, Soothe), then augments (Tricks), then Hurt / Charm, then healing. Same rank keeps the link order. */
function pfb_rank(array $p, bool $tagfx = false): int
{
    if ($p['by'] === 'env') return 1;
    if ($tagfx && ($p['by'] ?? '') === 'me') { $tg = $p['tile']['tag'] ?? ''; if ($tg === 'quick') return 0; if ($tg === 'heavy') return 6; }   // 2.7.06: Quick fires first in its chain, Heavy last
    return match ($p['tile']['t'] ?? '') { 'guard', 'soothe' => 2, 'trick' => 3, 'heal', 'item' => 5, default => 4 };   // hurt, charm and anything else = 4
}

/** The chain in the order it fires: [[id, parentId|null], ...]. The parent stays the piece it linked to (combos read it), only the firing order changes. Fights from before 2.6.991 keep the link order. */
function pfb_fire_order(array $s, int $root): array
{
    $chain = pfb_chain($s, $root);
    if (pfb_v1r($s, 'order') !== 1) return $chain;
    $idx = array_keys($chain);
    $tfx = pfb_v1r($s, 'tagfx') === 1;
    usort($idx, fn($a, $b) => [pfb_rank($s['pcs'][$chain[$a][0]], $tfx), $a] <=> [pfb_rank($s['pcs'][$chain[$b][0]], $tfx), $b]);
    return array_map(fn($i) => $chain[$i], $idx);
}

/**
 * 2.7.06 (Josh) set combos: a piece's combo comes from the pieces of its own side in the SAME chain, wherever they sit and whenever they were played (no longer only the piece it linked to).
 * PF_COMBOS keys read "partner>piece": the piece gets the combo when the chain holds a partner of that type. Same type (Double Swing): the partner must fire BEFORE it, so the first Hurt of a
 * chain has none and the later ones do. Several combos can fit one piece: the best resulting value wins (ties: the table's order). Returns [value, comboKey|null].
 */
function pfb_set_combo(array $s, array $chain, int $ci, string $who, array $tile): array
{
    $v = (float)$tile['v']; $best = null; $bk = null;
    foreach (PF_COMBOS as $key => $cb) {
        [$a, $b] = explode('>', $key);
        if ($b !== $tile['t']) continue;
        $pv = null;
        foreach ($chain as $cj => [$cid]) {
            $q = $s['pcs'][$cid] ?? null;
            if (!$q || $q['by'] !== $who || ($q['tile']['t'] ?? '') !== $a) continue;
            if ($a === $b && $cj >= $ci) continue;
            $pv = max($pv ?? 0, (int)$q['tile']['v']);
        }
        if ($pv === null) continue;
        $r = $v * $cb['mul'] / 100 + ($cb['flat'] === 'prev' ? $pv : (int)$cb['flat']);
        if ($best === null || $r > $best + 1e-9) { $best = $r; $bk = $key; }
    }
    return [(int)pf_round($best ?? $v), $bk];
}

/** Fire a chain. Events like the strip engine's, plus 'id' and 'root'. */
function pfb_fire(array &$s, int $root): array
{
    $ev = [];
    $chain = pfb_fire_order($s, $root);
    $v1 = $s['v1'] ?? null; $rb = $s['pcs'][$root]['by']; $tw = 1.0;
    if ($v1) {   // v1: what fired (for use-up) and Teamwork: the starter's pieces in this chain come from 2 or 3 of the sources pal, tool, crop
        $s['fired'] = []; $s['firedby'] = $rb; $s['firedroot'] = $root; $srcs = [];
        foreach ($chain as [$cid]) { $cp = $s['pcs'][$cid]; if ($cp['by'] === $rb && in_array($cp['tile']['src'] ?? '', PFB_TEAM_SRC, true)) $srcs[$cp['tile']['src']] = 1; }
        if ($rb === 'me' && count($srcs) >= 3) $tw = (float)$v1['team3']; elseif ($rb === 'me' && count($srcs) === 2) $tw = (float)$v1['team2'];
    }
    $cset = $v1 && pfb_v1r($s, 'cset') === 1;
    $esun = 1.0;   // 2.6.75: a Sun piece in the chain: every piece of the side that started the chain counts x sun in it (once, however many Suns)
    if ($v1 && !empty($v1['env'])) foreach ($chain as [$cid]) if ($s['pcs'][$cid]['by'] === 'env' && $s['pcs'][$cid]['tile']['env'] === 'sun') $esun = (float)$v1['sun'];
    foreach ($chain as $ci => [$id, $par]) {
        if ($s['over']) { $s['cut'] = ($s['cut'] ?? 0) + count($chain) - $ci; break; }   // the fight ended mid-chain: how many linked pieces did not fire (for the harness and replay)
        $p = $s['pcs'][$id]; $who = $p['by']; $tile = $p['tile'];
        if ($who === 'none') continue;   // the blank centre piece does nothing itself; the chain runs through it
        if ($who === 'env') {   // 2.6.75: an environment piece: its effect goes to the side whose chain this is; it counts for the chain's length and is used up like any piece
            $e = pfb_env_fire($s, $p, $rb); $s['fired'][] = $id;
            $s['pcs'][$id]['f'] = (int)($s['pcs'][$id]['f'] ?? 0) + 1;
            $e['barnow'] = pf_round((float)$s['bar']['now'], 1); $e['fhnow'] = pf_round((float)$s['fh']['now'], 1); $e['hpnow'] = (int)$s['me']['hp']; $e['gnow'] = (int)$s['me']['block'];
            $ev[] = $e; pf_check_end($s); continue;
        }
        $pt = $par !== null ? $s['pcs'][$par] : null;
        if ($pt && ($pt['by'] === 'none' || $pt['by'] === 'env')) $pt = null;   // and a piece after it (or after an environment piece) has no combo parent
        [$val, , $ck] = pf_value($pt['tile'] ?? null, $tile, $pt !== null && $pt['by'] === $who, false);   // combos only off your own piece; no fit bonus (every link fits)
        if ($cset) [$val, $ck] = pfb_set_combo($s, $chain, $ci, $who, $tile);   // 2.7.06 (Josh): a combo needs the partner anywhere in the same chain (your pieces), not the piece it linked to
        $val = (int)pf_round($val * (float)($p['cm'] ?? 1.0));   // a placed 3-piece group plays for more
        if (isset($p['wv'])) $val = max(1, $val + (int)$p['wv']);   // 2.7.09 wear effects: a boost (+) or a shrink (-) on this board piece
        if ($who === 'foe' && $tile['t'] === 'hurt' && ($gr = (int)($s['foe']['grudge'] ?? 0)) > 0 && pfb_kind($s) === 'beast') $val = (int)pf_round($val * (1 + (float)pfb_abp($s, 'gpct', PFB_KIND_GRUDGE) * $gr));   // 2.6.98 Grudge (2.7.01: Fury / Slow grudge change the number)
        if ($who === 'foe' && $tile['t'] === 'hurt' && pfb_kind($s) === 'critter') { $others = 0; foreach ($s['pcs'] as $q) if ($q['by'] === 'foe' && (int)$q['id'] !== $id) $others++; $val += min((int)pfb_abp($s, 'smax', PFB_KIND_SWARM_MAX), intdiv($others, 2)) * PFB_KIND_SWARM_ADD; }   // 2.6.988 Swarm grows: +1 Hurt for each other creature piece out
        $ambp = false; $ambd = false;
        if ($who === 'foe' && $tile['t'] === 'hurt' && !empty($s['foe']['ab'])) {   // 2.7.01 Enrage (past its share of the bar) and Ambush (its first Hurt in its first turn)
            if (!empty($s['foe']['enr']) && ($en = pfb_ab($s, 'enrage'))) $val = (int)pf_round($val * (float)$en['mult']);
            if (!empty($s['foe']['amb']) && !empty($s['infoe']) && ($am = pfb_ab($s, 'ambush'))) { $val = (int)pf_round($val * (float)$am['mult']); $s['foe']['amb'] = 0; $ambd = true; $ambp = !empty($am['pierce']); }
        }
        $sunny = $v1 && in_array($tile['t'], ['hurt', 'charm'], true) && pfb_ter($s, $p['x'], $p['y']) === 'sun';
        if ($sunny) $val = (int)pf_round($val * (float)$v1['sun']);
        if ($esun > 1 && $who === $rb) { $val = (int)pf_round($val * $esun); $sunny = true; }
        $muddy = $v1 && !empty($v1['env']) && (float)($v1['mud'] ?? 0) > 0 && pfb_mud_near($s, $p['x'], $p['y']);   // Mud's teeth: a piece next to a Mud counts less (where it stands when it fires)
        if ($muddy) $val = (int)pf_round($val * (1 - (float)$v1['mud']));
        if ($tw > 1 && $who === $rb) $val = (int)pf_round($val * $tw);
        $cntr = $who === 'me' && !empty($tile['cnt']) && $tile['cnt'] === pfb_kind($s);   // 2.7.08 counter piece against its own class
        if ($cntr) $val += PFB_COUNTER_ADD;
        $toughed = false;
        if ($who === 'me' && $rb === 'me' && $tile['t'] === 'hurt' && empty($s['me']['tough']) && ($th = pfb_ab($s, 'toughhide'))) { $val = max(1, $val - (int)$th['cut']); $s['me']['tough'] = 1; $toughed = true; }   // 2.7.01 Tough hide: your first Hurt of the turn counts less
        $isRoot = $id === $root; $wcl = null; $whalf = false;
        if ($who === 'me' && !empty($s['wfx']) && !empty($tile['fx'])) {   // 2.7.09 wear effects: the conditions are checked as it fires, before its own effect; dmg and pierce change its own hit
            $wcx = ['id' => $id, 't' => $tile, 'ch' => $chain, 'ph' => 'fire', 'g' => 0]; $wcl = pfb_wx_fire($s, $wcx, $isRoot && $rb === 'me');
            foreach ($wcl as $o) { if ($o['a'] === 'dmg') $val += pfb_wx_n($s, $o, $wcx); if ($o['a'] === 'pierce') $tile['tag'] = 'pierce'; }
        }
        if ($who === 'foe' && $tile['t'] === 'hurt' && (int)($s['foe']['whf'] ?? 0) > 0) { $val = (int)pf_round($val / 2); $s['foe']['whf']--; $whalf = true; }   // 2.7.09: its next Hurts do half damage
        if ($v1) $s['fired'][] = $id;
        $e = ['by' => $who, 'id' => $id, 'root' => $isRoot, 'tag' => $tile['tag'], 'mod' => (string)($tile['m'] ?? ''), 'k' => $tile['k'], 'n' => $tile['n'], 't' => $tile['t'], 'v' => $val, 'fit' => false, 'combo' => $ck ? PF_COMBOS[$ck]['name'] : null];
        if ($sunny) $e['sun'] = 1;
        if ($muddy) $e['mud'] = 1;
        if ($tw > 1 && $who === $rb) $e['tw'] = $tw;
        if ($ambd) $e['amb'] = 1;
        if ($ambp) $e['ambp'] = 1;
        if ($toughed) $e['tough'] = 1;
        if ($cntr) $e['cntr'] = 1;
        if ($whalf) $e['whalf'] = 1;
        pf_apply($s, $who, $tile, $val, $isRoot && pfb_links($s, $id) !== [], $ck, $pt['tile'] ?? null, $pt['by'] ?? null, $e, $isRoot, false);
        if ($wcl !== null) { $wcx['g'] = $tile['t'] === 'guard' ? $val : 0; foreach ($wcl as $o) if ($o['st'] === 'post' && pfb_wx_conds($s, array_filter($o['c0'], fn($c) => str_starts_with(ltrim($c, '!'), 'tgt:')), $wcx)) pfb_wx_act($s, $o, $wcx, $e); }   // 2.7.09 wear effects (the tgt conditions after the boost)
        if ($who === 'foe' && $tile['t'] === 'hurt' && !empty($s['wfx'])) pfb_wx_guard($s, $e, $id);   // 2.7.09: your guard blocked it or your Evade made it miss
        $s['pcs'][$id]['f'] = (int)($s['pcs'][$id]['f'] ?? 0) + 1;   // fire budget: one more firing used (the placement counts as the first)
        $e['barnow'] = pf_round((float)$s['bar']['now'], 1); $e['fhnow'] = pf_round((float)$s['fh']['now'], 1); $e['hpnow'] = (int)$s['me']['hp']; $e['gnow'] = (int)$s['me']['block'];   // for the replay: how the bar and health stand after this piece
        $ev[] = $e;
        foreach (['drained' => 'drain', 'staggered' => 'stagger'] as $ek => $nk) if (!empty($e[$ek])) $ev[] = pfb_abnote($s, $nk, $nk === 'drain' ? (string)$e[$ek] : '');   // 2.7.01 notices
        pf_check_end($s);
    }
    return $ev;
}

/** How many times may this piece fire before it falls away? 0 = no limit (your pieces, the blank, and everything when PFB_FOE_FIRES is 0). */
function pfb_fire_limit(array $p, bool $tagfx = false): int
{
    if ($tagfx && $p['by'] === 'me' && ($p['tile']['tag'] ?? '') === 'heavy') return 1;   // 2.7.06: Heavy swings once, then falls away
    return $p['by'] === 'foe' ? max(0, PFB_FOE_FIRES) : 0;
}

/** A piece leaving the board, as the replay and the page want it. */
function pfb_gone_entry(array $s, array $p, bool $fell): array
{
    $e = ['id' => $p['id'], 'by' => $p['by'], 'x' => $p['x'], 'y' => $p['y'], 'tile' => $p['tile'], 'age' => $s['round'] - 1 - $p['born']];
    if ($fell) $e['fell'] = true;
    if (isset($p['used'])) $e['used'] = $p['used'];   // v1: used up by a chain of 3+ (whose chain it was)
    if (!empty($s['v1']) && $p['by'] === 'foe' && in_array($p['id'], $s['lastfoe'] ?? [], true)) $e['fnew'] = true;   // 2.6.986: the creature put it down this turn: the replay shows it at its own step, not from the first frame
    return $e;
}

/** Fire budget: after a chain has finished, creature pieces that have fired their limit fall away (to their discard). Never mid-chain, so a chain keeps its shape. Returns nothing; $s['spent'] lists them for the replay. */
function pfb_spend(array &$s): array
{
    $fired = $s['fired'] ?? []; $by = $s['firedby'] ?? 'me'; $froot = $s['firedroot'] ?? null; unset($s['fired'], $s['firedby'], $s['firedroot']); $used = [];
    $wst = $s['wstay'] ?? []; $wkn = $s['wkn'] ?? []; if (!empty($s['wfx'])) { $s['wstay'] = []; $s['wkn'] = []; }   // 2.7.09 wear effects: pieces that stay out of this use-up, creature pieces to knock off
    if ($s['over']) return $used;
    $lim3 = (int)($s['v1']['limit'] ?? 0);
    if ($lim3 > 0 && count($fired) >= $lim3) {   // v1 USE-UP: a chain of 3 or more uses up every piece that fired, whoever started it and whoever owns them
        $keepMine = pfb_v1r($s, 'keepmine') === 1; $onlyRoot = pfb_v1r($s, 'useroot') === 1;   // 2.6.98: keepmine = your pieces are never used up; useroot = only the piece that was placed
        foreach ($fired as $id) {
            if (!isset($s['pcs'][$id])) continue; $p = $s['pcs'][$id];
            if ($keepMine && $p['by'] === 'me') continue;
            if ($onlyRoot && $froot !== null && $id !== $froot) continue;
            if (in_array($id, $wst, true)) continue;   // 2.7.09 wear 'stay'
            pfb_discard($s, $p); $p['used'] = $by; $s['spent'][] = $p; $used[] = $id; pfb_venom($s, $p);
            unset($s['cell'][$p['x'] . ',' . $p['y']], $s['pcs'][$id]);
        }
    }
    foreach ($s['pcs'] as $id => $p) {
        $lim = pfb_fire_limit($p, pfb_v1r($s, 'tagfx') === 1);
        if ($lim > 0 && (int)($p['f'] ?? 0) >= $lim) {
            pfb_discard($s, $p); $s['spent'][] = $p; pfb_venom($s, $p);
            unset($s['cell'][$p['x'] . ',' . $p['y']], $s['pcs'][$id]);
        }
    }
    foreach ($wkn as $kid) {   // 2.7.09 wear 'knock' (0 = its weakest piece now) and 'kill' (that piece): after the chain, like a use-up by you
        if ($kid === 0) $kid = pfb_wx_foe_pick($s, false);
        if ($kid === null || !isset($s['pcs'][$kid])) continue;
        $p = $s['pcs'][$kid]; pfb_discard($s, $p); $p['used'] = 'me'; $s['spent'][] = $p; pfb_venom($s, $p); $used[] = $kid;
        unset($s['cell'][$p['x'] . ',' . $p['y']], $s['pcs'][$kid]);
    }
    return $used;
}

/** The start of a side's turn: its guard from last turn is spent (a Hold guard carries over once). */
function pfb_begin(array &$s, string $who): void
{
    if ($who === 'me') {
        if (!empty($s['foe']['ab'])) $s['me']['tough'] = 0;   // 2.7.01 Tough hide: a new turn of yours (the flag is reset on the copy of a played turn)
        if (!empty($s['wfx'])) { $w = &$s['me']['wx']; $w['lt'] = $w['ct']; $w['ct'] = ''; $w['nd'] = (int)$s['me']['hp'] >= (int)$w['hps'] ? 1 : 0; $w['hps'] = (int)$s['me']['hp']; unset($w); }   // 2.7.09: last turn's piece type, no health lost since your last turn
        return;
    }   // 2.7.01 Tough hide: a new turn of yours (the flag is reset on the copy of a played turn)
    // your guard is reset when your turn starts (pfb_end_round), so it stays up through the creature's turn
    $s[$who]['block'] = $s[$who]['keep']; $s[$who]['keep'] = 0; $s[$who]['thorns'] = false; $s[$who]['evade'] = 0;
}

/** Put a tile from $who's hand on the board at (x,y) and fire its chain. Returns the events, or null when it is illegal (nothing changed). */
function pfb_place(array &$s, string $who, int $handIdx, int $x, int $y): ?array
{
    $tile = $s[$who]['hand'][$handIdx] ?? null;
    if (!$tile) return null;
    $jt = pfb_check($s, $tile, $x, $y);
    if ($jt === null || (!pfb_has_link($jt) && empty($s['aimforce']) && pfb_must_link($s, $who))) return null;   // it has to connect unless nothing can (v1: the creature's committed aim plays on its cell even when its link has gone)
    array_splice($s[$who]['hand'], $handIdx, 1);
    $id = ++$s['pid']; $s['seq']++;
    $s['pcs'][$id] = ['id' => $id, 'by' => $who, 'tile' => $tile, 'x' => $x, 'y' => $y, 'born' => $s['round'], 'seq' => $s['seq']];
    $s['cell']["$x,$y"] = $id;
    if ($who === 'me' && isset($tile['tool'])) $s['wear'][$tile['tool']] = (int)($s['wear'][$tile['tool']] ?? 0) + PFB_TOOL_WEAR;   // tool wear: its piece was played
    if (!empty($s['wfx'])) {   // 2.7.09 wear effects
        if ($who === 'me') pfb_wx_placed($s, $id, $tile);
        elseif ($who === 'foe' && (int)$s['foe']['wnx'] > 0) { $s['pcs'][$id]['wv'] = -(int)$s['foe']['wnx']; $s['foe']['wnx'] = 0; }   // its next piece loses N
    }
    $joints = pfb_check_after($s, $id);
    $ev = pfb_fire($s, $id);
    if ($ev) { $ev[0]['linked'] = $joints; $ev[0]['snap'] = pfb_snap($s); $ev[0]['cs'] = 1; $ev[0]['rid'] = $id; }   // cs / rid: this event opens the chain and the placed piece is rid (after the firing order changed the placed piece is not always the first to fire); linked: how many linked joints the new piece made; snap: the board for the history rewind
    $used = pfb_spend($s);
    if ($used && $ev) $ev[0]['used'] = $used;   // v1: the ids this chain used up
    if ($ev && $who === 'me' && !$s['over'] && empty($s['boss']) && pfb_v1r($s, 'paltgt') === 1 && pfb_src($tile) === 'pal' && ($tid = pfb_pal_target($s, $x, $y, (int)$tile['v'])) !== null) $ev[] = pfb_pal_nip($s, $tid, (string)$tile['n']);   // 2.7.08 pal targeting: after its chain, the pal knocks the creature's strongest piece off (a boss shrugs it off, as it cannot be charmed)
    if ($ev && $who === 'me' && isset($s['ven']["$x,$y"]) && pfb_kind($s) === 'reptile' && !empty($s['v1']['tags'])) {   // 2.6.98 Venom trail: you stepped on it
        $vr = (int)pfb_abp($s, 'vrnds', PFB_KIND_VENOM_RNDS); $vp = (int)pfb_abp($s, 'vpoison', PFB_KIND_VENOM_POISON);
        $s['me']['poison'] = min(PF_POISON_CAP, (int)$s['me']['poison'] + $vr); $s['me']['poison_v'] = max((int)$s['me']['poison_v'], $vp);
        $vn = pfb_note('venom', (string)$tile['n']); $vn['by'] = 'me'; if ($vr !== PFB_KIND_VENOM_RNDS || $vp !== PFB_KIND_VENOM_POISON) { $vn['pr'] = $vr; $vn['pv'] = $vp; } $ev[] = $vn;
    }
    return $ev;
}

// ---------------------------------------------------------------- set-aside groups (pre-connected pieces)

/** The edge of a group piece on a side, and the neighbour in the group on that side (or null). */
function pfb_group_at(array $g, int $dx, int $dy): ?int
{
    foreach ($g['pcs'] as $i => $p) if ($p['x'] === $dx && $p['y'] === $dy) return $i;
    return null;
}

/** Can $tile join group $g at the cell (dx,dy)? Every touching edge must fit and at least one joint must be linked (so the group's chain runs). Returns true or a reason. */
function pfb_group_fit(array $g, array $tile, int $dx, int $dy)
{
    if (count($g['pcs']) >= PFB_GROUP_MAX) return 'A group of three cannot take another piece.';
    if (pfb_group_at($g, $dx, $dy) !== null) return 'That spot is taken.';
    $e = pfb_edges($tile); $touch = 0; $linked = 0;
    foreach (PFB_SIDE as $side => [$ddx, $ddy, $opp]) {
        $ni = pfb_group_at($g, $dx + $ddx, $dy + $ddy); if ($ni === null) continue;
        [$fits, $lk] = pfb_joint($e[$side], pfb_edges($g['pcs'][$ni]['tile'])[$opp]);
        if (!$fits) return 'Those edges do not fit.';
        $touch++; if ($lk) $linked++;
    }
    if (!$touch) return 'It has to touch the group.';
    if (!$linked) return 'The pieces have to link (a knob in a matching hole), or their chain would not run.';
    return true;
}

/** Every way $tile can join group $g: [[anchorIdx, side, dx, dy], ...]. */
function pfb_group_options(array $g, array $tile): array
{
    $o = []; $seen = [];
    foreach ($g['pcs'] as $ai => $a) foreach (PFB_SIDE as $side => [$ddx, $ddy]) {
        $dx = $a['x'] + $ddx; $dy = $a['y'] + $ddy; if (isset($seen["$dx,$dy"])) continue; $seen["$dx,$dy"] = true;
        if (pfb_group_fit($g, $tile, $dx, $dy) === true) $o[] = [$ai, $side, $dx, $dy];
    }
    return $o;
}

/** Set pieces aside, joined. Two hand pieces ($a anchor, $b joins on $side of it), or one hand piece onto the group already set aside ($anc = the group piece it joins, on $side). Returns an error or null. */
function pfb_connect(array &$s, string $who, ?int $a, int $b, string $side, ?int $anc = null): ?string
{
    if (!isset(PFB_SIDE[$side])) return 'Those moves are not valid.';
    $hand = $s[$who]['hand'];
    if (!isset($hand[$b])) return 'Those moves are not valid.';
    if ($anc !== null) {   // add to the group
        $g = $s[$who]['held'] ?? null;
        if (!$g) return 'There is no set-aside group to add to.';
        if (!isset($g['pcs'][$anc])) return 'Those moves are not valid.';
        [$ddx, $ddy] = PFB_SIDE[$side]; $dx = $g['pcs'][$anc]['x'] + $ddx; $dy = $g['pcs'][$anc]['y'] + $ddy;
        $r = pfb_group_fit($g, $hand[$b], $dx, $dy); if ($r !== true) return $r;
        $g['pcs'][] = ['tile' => $hand[$b], 'x' => $dx, 'y' => $dy];
        array_splice($s[$who]['hand'], $b, 1); $s[$who]['held'] = $g; return null;
    }
    if (!empty($s[$who]['held'])) return 'You already have a group set aside. Add to it or play it.';
    if ($a === null || $a === $b || !isset($hand[$a])) return 'Those moves are not valid.';
    $g = ['pcs' => [['tile' => $hand[$a], 'x' => 0, 'y' => 0]]];
    [$ddx, $ddy] = PFB_SIDE[$side];
    $r = pfb_group_fit($g, $hand[$b], $ddx, $ddy); if ($r !== true) return $r;
    $g['pcs'][] = ['tile' => $hand[$b], 'x' => $ddx, 'y' => $ddy];
    foreach ([max($a, $b), min($a, $b)] as $i) array_splice($s[$who]['hand'], $i, 1);
    $s[$who]['held'] = $g; return null;
}

/** The cells a group would fill with its top-left at (ox,oy), or null if it does not fit there. Returns [[x, y, groupIdx], ...]. */
function pfb_group_cells(array $s, array $g, int $ox, int $oy): ?array
{
    $r = pfb_group_cells_l($s, $g, $ox, $oy);
    return $r === null ? null : $r[0];
}

/** [cells, linked]: the cells the group would fill and whether any joint with the board is linked, or null if it does not fit there. */
function pfb_group_cells_l(array $s, array $g, int $ox, int $oy): ?array
{
    $mx = min(array_column($g['pcs'], 'x')); $my = min(array_column($g['pcs'], 'y'));
    $cells = []; $mine = [];
    foreach ($g['pcs'] as $i => $p) { $x = $ox + $p['x'] - $mx; $y = $oy + $p['y'] - $my; $cells[] = [$x, $y, $i]; $mine["$x,$y"] = $i; }
    $touch = false; $linked = false;
    foreach ($cells as [$x, $y, $i]) {
        if ($x < 0 || $y < 0 || $x >= pfb_w($s) || $y >= pfb_h($s) || isset($s['cell']["$x,$y"])) return null;
        $e = pfb_edges($g['pcs'][$i]['tile']);
        foreach (PFB_SIDE as $side => [$dx, $dy, $opp]) {
            $nx = $x + $dx; $ny = $y + $dy; if (isset($mine["$nx,$ny"])) continue;   // inside the group: already checked when it was joined
            $n = pfb_at($s, $nx, $ny); if (!$n) continue;
            $jt = pfb_joint($e[$side], pfb_edges($n['tile'])[$opp]);
            if (!$jt[0]) return null;
            $touch = true; if ($jt[1] && (empty($s['ter']) || (pfb_ter($s, $x, $y) !== 'mud' && pfb_ter($s, $nx, $ny) !== 'mud'))) $linked = true;
        }
    }
    if (!$s['pcs']) { $c = [intdiv(pfb_w($s), 2), intdiv(pfb_h($s), 2)]; foreach ($cells as [$x, $y]) if ($x === $c[0] && $y === $c[1]) return [$cells, false]; return null; }
    return $touch ? [$cells, $linked] : null;
}

/** Every spot [ox, oy, linked] where the group fits (before the connect rule). */
function pfb_group_cells_all(array $s, array $g): array
{
    $o = [];
    for ($y = 0; $y < pfb_h($s); $y++) for ($x = 0; $x < pfb_w($s); $x++) { $r = pfb_group_cells_l($s, $g, $x, $y); if ($r !== null) $o[] = [$x, $y, $r[1]]; }
    return $o;
}

/** Every top-left spot where the group can go. */
function pfb_group_spots(array $s, array $g, string $who = 'me'): array
{
    $o = []; $must = pfb_must_link($s, $who);
    foreach (pfb_group_cells_all($s, $g) as [$x, $y, $lk]) if (!$must || $lk) $o[] = [$x, $y];
    return $o;
}

/** Put the set-aside group on the board with its top-left at (ox,oy); the NEWEST piece of the group starts the chain. Returns the events or null when illegal. */
function pfb_place_group(array &$s, string $who, int $ox, int $oy): ?array
{
    $g = $s[$who]['held'] ?? null; if (!$g) return null;
    $r = pfb_group_cells_l($s, $g, $ox, $oy); if ($r === null) return null;
    if (!$r[1] && pfb_must_link($s, $who)) return null;   // it has to connect unless nothing can
    $cells = $r[0];
    $cm = PFB_GROUP_MULT[count($g['pcs'])] ?? 1.0; $root = null;
    foreach ($cells as [$x, $y, $i]) {
        $id = ++$s['pid']; $s['seq']++;
        $s['pcs'][$id] = ['id' => $id, 'by' => $who, 'tile' => $g['pcs'][$i]['tile'], 'x' => $x, 'y' => $y, 'born' => $s['round'], 'seq' => $s['seq'], 'cm' => $cm];
        $s['cell']["$x,$y"] = $id; $root = $id;
        $gt = $g['pcs'][$i]['tile']; if ($who === 'me' && isset($gt['tool'])) $s['wear'][$gt['tool']] = (int)($s['wear'][$gt['tool']] ?? 0) + PFB_TOOL_WEAR;
    }
    $s[$who]['held'] = null;
    $ev = pfb_fire($s, $root);
    if ($ev) { $ev[0]['linked'] = pfb_check_after($s, $root); $ev[0]['snap'] = pfb_snap($s); $ev[0]['cs'] = 1; $ev[0]['rid'] = $root; }
    $used = pfb_spend($s);
    if ($used && $ev) $ev[0]['used'] = $used;
    return $ev;
}

/** The board as it stands right now (for rewinding the history): the pieces with everything the page needs to draw and describe them. */
function pfb_snap(array $s): array
{
    return array_values(array_map(fn($p) => ['id' => $p['id'], 'by' => $p['by'], 'x' => $p['x'], 'y' => $p['y'], 'n' => $p['tile']['n'], 't' => $p['tile']['t'], 'v' => $p['tile']['v'], 'tag' => $p['tile']['tag'], 'm' => (string)($p['tile']['m'] ?? ''), 'e' => pfb_edges($p['tile']), 'age' => $s['round'] - $p['born']], $s['pcs']));
}

function pfb_check_after(array $s, int $id): int
{
    return count(pfb_links($s, $id));
}

/** Expire old pieces at the end of a round (after everything has scored): back to their owner's discard. Returns what left, for the replay. */
/** 2.6.98 Venom trail: a Reptile's piece that leaves the board leaves venom on its cell (a piece of yours put there poisons you). Stored as rounds + 1: it decays after the round's expiry. */
function pfb_venom(array &$s, array $p): void
{
    if ($p['by'] === 'foe' && pfb_kind($s) === 'reptile') $s['ven'][$p['x'] . ',' . $p['y']] = (int)pfb_abp($s, 'vrnds', PFB_KIND_VENOM_RNDS) + 1;
}

function pfb_expire(array &$s): array
{
    $gone = [];
    foreach ($s['pcs'] as $id => $p) if ($p['born'] <= $s['round'] - pfb_life($s, $p) + 1) {
        pfb_discard($s, $p); pfb_venom($s, $p);
        $gone[] = $p;
        unset($s['cell'][$p['x'] . ',' . $p['y']], $s['pcs'][$id]);
    }
    return $gone;
}

/** Which creature hand piece starts the board or refills it: its gentlest non-Hurt piece. */
function pfb_anchor_pick(array &$s): ?int
{
    $hand = $s['foe']['hand']; if (!$hand) return null;
    $pick = null;
    foreach ($hand as $i => $t) if ($t['t'] !== 'hurt' && ($pick === null || $t['v'] < $hand[$pick]['v'])) $pick = $i;
    if ($pick !== null) return $pick;
    // 2.6.63: a hand of nothing but Hurt used to put a Hurt out as the "gentlest non-Hurt" piece (3% of starts, 50 creatures; it fires in your first chain). Swap in the top non-Hurt piece of the draw pile instead.
    foreach (array_reverse(array_keys($s['foe']['draw'])) as $di) if ($s['foe']['draw'][$di]['t'] !== 'hurt') { $s['foe']['hand'][] = $s['foe']['draw'][$di]; array_splice($s['foe']['draw'], $di, 1); return count($s['foe']['hand']) - 1; }
    return 0;
}

/** After the creature's turn: if it has fewer than PFB_FOE_MIN pieces out, put one of its gentlest pieces on the board (nothing fires for it). Returns the new piece's id or null. */
function pfb_spawn(array &$s): ?int
{
    if (count(array_filter($s['pcs'], fn($p) => $p['by'] === 'foe')) >= PFB_FOE_MIN) return null;
    $pick = pfb_anchor_pick($s); if ($pick === null) return null;
    $tile = $s['foe']['hand'][$pick];
    $cells = $s['pcs'] ? pfb_cells($s, $tile) : [[intdiv(pfb_w($s), 2), intdiv(pfb_h($s), 2)]];
    if (!$cells) return null;
    [$x, $y] = $cells[pf_rand($s, count($cells))];
    array_splice($s['foe']['hand'], $pick, 1);
    $id = ++$s['pid']; $s['seq']++;
    $s['pcs'][$id] = ['id' => $id, 'by' => 'foe', 'tile' => $tile, 'x' => $x, 'y' => $y, 'born' => $s['round'], 'seq' => $s['seq']];
    $s['cell']["$x,$y"] = $id;
    return $id;
}

// ---------------------------------------------------------------- the creature's play

function pfb_score(array $b, array $a, string $who, ?array &$ctx = null): float
{
    if ($who === 'foe' && !empty($a['foe']['ai'])) { if ($ctx === null) $ctx = []; return pfb_ai_score($b, $a, $a['foe']['ai'], $ctx); }   // 2.7.01: a creature with a play style (none or balanced: the 2.7.00 scorer below, bit for bit)
    $barD = ($a['bar']['now'] - $b['bar']['now']) + ($a['fh']['now'] - $b['fh']['now']);   // charm and damage both move the creature toward losing
    $hpD = $a['me']['hp'] - $b['me']['hp'];
    $tg = 0.0;
    if (!empty($a['v1']['tags'])) {   // creature tags: what the lasting effects are worth to the creature (poison waiting on you, a tripped draw, its evade, thorns, a lent guard, one more piece)
        $u = 0.05 * $a['me']['max']; $pz = fn(array $z) => (int)($z['me']['poison'] ?? 0) * (int)($z['me']['poison_v'] ?? 0);
        $tg = ($pz($a) - $pz($b)) + $u * (1.0 * ((int)($a['me']['slowdraw'] ?? 0) - (int)($b['me']['slowdraw'] ?? 0)) + 1.5 * ((int)$a['foe']['evade'] - (int)$b['foe']['evade']) + 0.6 * ((int)$a['foe']['thorns'] - (int)$b['foe']['thorns'])
            + ((int)($a['foe']['bashnext'] ?? 0) - (int)($b['foe']['bashnext'] ?? 0)) * max(1.0, (float)$a['foe']['block'] / max(1.0, $u)) + 1.5 * ((int)($a['foe']['again'] ?? 0) - (int)($b['foe']['again'] ?? 0)));
    }
    if ($who === 'me') return -0.7 * $tg + $barD + 0.7 * $hpD + 0.3 * ($a['me']['block'] - $b['me']['block']) - 0.3 * ($a['foe']['block'] - $b['foe']['block']) + ($a['over'] && in_array($a['over'], ['seen_off', 'charmed'], true) ? 50 : 0);
    return $tg - 0.8 * $barD - $hpD + 0.4 * ($a['foe']['block'] - $b['foe']['block']) - 0.3 * ($a['me']['block'] - $b['me']['block']) + ($a['over'] === 'defeat' ? 50 : 0);
}

/** The best single placement for $who by trying every tile in every legal cell on a copy. [handIdx, x, y, score] or null. Ties: first found (deterministic). */
function pfb_search(array $s, string $who, bool $allowHeavy = true, ?string $onlyK = null, ?array $avoid = null): ?array
{
    $best = null; $ctx = [];
    if ($who === 'foe') { $s = pfb_foe_base($s); $infoe = !empty($s['foe']['ab']); } else $infoe = false;   // 2.7.01: with a play style it searches the turn it will play; Ambush is live in its first turn
    foreach ($s[$who]['hand'] as $i => $tile) {
        if (!$allowHeavy && $tile['tag'] === 'heavy' && ($tile['m'] ?? '') !== 'steady') continue;
        if ($onlyK !== null && $tile['k'] !== $onlyK) continue;   // 2.6.98: a boss's committed piece
        foreach (pfb_cells($s, $tile, $who) as [$x, $y]) {
            if ($avoid !== null && $x === $avoid[0] && $y === $avoid[1]) continue;   // 2.6.98: a Bird's second aim is on another cell
            $w = $s; if ($infoe) $w['infoe'] = 1;
            if (pfb_place($w, $who, $i, $x, $y) === null) continue;
            unset($w['infoe']);
            $sc = pfb_score($s, $w, $who, $ctx);
            if (!empty($s['v1']) && isset($w['cell']["$x,$y"])) {   // v1: a piece that stays out pays for bramble under it, and for what the announced events will do to it
                if (pfb_ter($s, $x, $y) === 'br') $sc -= 2 * (float)$s['v1']['bramble'] * ($who === 'foe' ? (float)$s['v1']['br_foe'] * 0.8 * $s['fh']['max'] : 0.7 * $s['me']['max']);
                $sc += pfb_env_bias($s, $who, $x, $y, $tile);
            }
            if ($best === null || $sc > $best[3] + 1e-9) $best = [$i, $x, $y, $sc];
        }
    }
    return $best;
}

/** How many pieces the creature puts down this turn: exactly one (so only the chain that piece makes fires; nothing disconnected from it). Trip/Lull make it skip the turn. */
function pfb_foe_len(array $s): int
{
    return max(0, min(count($s['foe']['hand']), 1 - (int)$s['foe']['slow']));
}

/** 2.6.77: the notices for your guard at the start of your turn ('fade' = it ran out, 'hold' = a Hold guard stayed up), as events after the round's others; gnow is what the shield shows from there on. */
function pfb_guard_notes(array &$s, array &$ev): void
{
    if (empty($s['v1']) || $s['over']) return;
    $ta = $ev ? (string)(end($ev)['ta'] ?? 'foe') : 'foe';
    foreach ([['fade', (int)($s['me']['faded'] ?? 0)], ['hold', (int)($s['me']['kept'] ?? 0)], ['simmer', (int)($s['me']['simmer'] ?? 0)]] as [$k, $n]) {
        if ($n <= 0) continue;
        $e = pfb_note($k, (string)$n); $e['by'] = 'me'; $e['ta'] = $ta;
        $e['barnow'] = pf_round((float)$s['bar']['now'], 1); $e['fhnow'] = pf_round((float)$s['fh']['now'], 1); $e['hpnow'] = (int)$s['me']['hp']; $e['gnow'] = (int)$s['me']['block'];
        $ev[] = $e;
    }
}

/** 2.6.76: a notice event (no piece, no numbers): the creature acts more than normal or you lose a play. note = quick | slow | trip. The page shows it as a chip, a log line and in the banner. */
function pfb_note(string $kind, string $n = ''): array
{
    return ['by' => 'foe', 'note' => $kind, 'k' => 'note', 'n' => $n, 't' => 'note', 'tag' => '', 'v' => 0, 'fit' => false, 'combo' => null];
}

/**
 * 2.7.08 PAL TARGETING (claude/engine-2.7.08-notes.md "Pal targeting"): the creature piece a pal piece of value $pv placed at (x, y) goes for: its STRONGEST piece on the board that is
 * no stronger than the pal piece (value <= $pv; null = no cap), ties by the fewest steps from the pal piece (|dx| + |dy|), then the oldest (lowest id). Deterministic: no dice. null when there is none.
 */
function pfb_pal_target(array $s, int $x, int $y, ?int $pv = null): ?int
{
    $best = null; $key = null;
    foreach ($s['pcs'] as $id => $p) {
        if ($p['by'] !== 'foe' || ($pv !== null && (int)$p['tile']['v'] > $pv)) continue;
        $k = [(int)$p['tile']['v'], -(abs((int)$p['x'] - $x) + abs((int)$p['y'] - $y)), -(int)$id];
        if ($key === null || $k > $key) { $key = $k; $best = (int)$id; }
    }
    return $best;
}
/** Pal targeting: the target leaves the board (to the creature's discard, shown as used up by you; a Reptile still leaves venom). Returns the notice (note 'palaim'; tid = the piece, not 'id': no chain glow). */
function pfb_pal_nip(array &$s, int $tid, string $pal): array
{
    $p = $s['pcs'][$tid];
    pfb_discard($s, $p); $p['used'] = 'me'; $s['spent'][] = $p; pfb_venom($s, $p);
    unset($s['cell'][$p['x'] . ',' . $p['y']], $s['pcs'][$tid]);
    $e = pfb_note('palaim', (string)$p['tile']['n']); $e['by'] = 'me'; $e['tid'] = $tid; $e['x'] = (int)$p['x']; $e['y'] = (int)$p['y']; $e['pal'] = $pal; $e['tv'] = (int)$p['tile']['v'];
    return $e;
}

/**
 * 2.6.98 (aimhit): the creature's Hurt piece (hand index $hi) strikes YOUR piece $cid instead of landing on the board. A Guard of yours with value >= the hit holds, anything else breaks (to your discard).
 * The creature's piece is spent (its discard), you take nothing. Returns the event.
 */
function pfb_strike(array &$s, int $hi, int $cid): array
{
    $ft = $s['foe']['hand'][$hi]; array_splice($s['foe']['hand'], $hi, 1); $s['foe']['discard'][] = $ft; $s['nospawn'] = 1;
    $p = $s['pcs'][$cid]; $hit = (int)$ft['v']; $g = ($p['tile']['t'] ?? '') === 'guard' ? (int)$p['tile']['v'] : 0; $broke = $g < $hit;
    if ($broke) { pfb_discard($s, $p); $p['used'] = 'foe'; $s['spent'][] = $p; unset($s['cell'][$p['x'] . ',' . $p['y']], $s['pcs'][$cid]); }
    return ['by' => 'foe', 'strike' => true, 'id' => $cid, 'broke' => $broke, 'guard' => $g, 'x' => (int)$p['x'], 'y' => (int)$p['y'], 'k' => $ft['k'], 'n' => $ft['n'], 't' => 'hurt', 'tag' => '', 'v' => $hit, 'hit' => $hit, 'mine' => (string)($p['tile']['n'] ?? ''), 'fit' => false, 'combo' => null];
}

function pfb_foe_turn(array &$s, int $extra): array
{
    $ev = [];
    pfb_begin($s, 'foe');
    if ($s['foe']['poison'] > 0) {   // Sting: the poison works on the creature before it acts
        $add = $s['foe']['poison_v'] * $s['hm'];
        $s['fh']['now'] += $add; $s['foe']['poison']--;
        if ($s['foe']['poison'] === 0) $s['foe']['poison_v'] = 0;
        $ev[] = ['by' => 'me', 'tag' => 'poison', 'k' => 'poison', 'n' => 'Poison', 't' => 'hurt', 'v' => (int)pf_round($add), 'fit' => false, 'combo' => null, 'tick' => true];
        if (pf_check_end($s)) return $ev;
    }
    if (!empty($s['foe']['ab'])) { pfb_ab_turn($s, $ev); $s['infoe'] = 1; }   // 2.7.01: its turn count, Regrow, Plated; Ambush is live for this turn
    if (!empty($s['v1']['tags']) && (int)$s['foe']['slow'] > 0 && $s['foe']['hand']) { $ev[] = pfb_note('slow'); if (!empty($s['wfx'])) $s['foe']['wsk']++; }   // 2.6.76: it loses its turn (2.7.09: counted for wear effects)
    $n = pfb_foe_len($s); $s['lastfoe'] = []; $again = false; $hp0 = (int)$s['me']['hp']; $kind = pfb_kind($s);
    if (!empty($s['v1']['tags'])) $s['foe']['again'] = 0;
    if (!empty($s['v1'])) $s['reaim'] = 0;   // the pieces it puts down this turn (the page holds only these back until the replay reaches them)
    for ($k = 0; $k < $n && !$s['over']; $k++) {
        $r = null; $plan = !empty($s['v1']['aim']) && $k === 0 ? ($s['foe']['plan'] ?? null) : null;
        if ($plan && ($plan['t'] ?? '') === 'hurt' && pfb_v1r($s, 'aimhit') === 1) {   // 2.6.98 AIMHIT: YOUR piece on the cell its Hurt aim wanted is struck instead of the creature picking again
            $cid = $s['cell'][$plan['x'] . ',' . $plan['y']] ?? null;
            if ($cid !== null && ($s['pcs'][$cid]['by'] ?? '') === 'me') {
                foreach ($s['foe']['hand'] as $hi => $ht) if ($ht['k'] === $plan['k']) { $ev[] = pfb_strike($s, $hi, (int)$cid); $r = []; if ($kind === 'beast') $s['foe']['grudge'] = min((int)pfb_abp($s, 'gmax', PFB_KIND_GRUDGE_MAX), (int)($s['foe']['grudge'] ?? 0) + 1); break; }
                if ($r !== null) continue;
            }
        }
        if ($plan && isset($s['cell'][$plan['x'] . ',' . $plan['y']])) {   // its cell is taken
            if ($kind === 'bird' && !empty($plan['alt']) && !isset($s['cell'][$plan['alt']['x'] . ',' . $plan['alt']['y']])) $plan = $plan['alt'];   // 2.6.98 Two aims: it plays the second one
            elseif ($kind === 'beast') $s['foe']['grudge'] = min((int)pfb_abp($s, 'gmax', PFB_KIND_GRUDGE_MAX), (int)($s['foe']['grudge'] ?? 0) + 1);   // 2.6.98 Grudge: you blocked it
        }
        $why = '';
        if ($plan) { foreach ($s['foe']['hand'] as $hi => $ht) if ($ht['k'] === $plan['k']) { $s['aimforce'] = true; $r = pfb_place($s, 'foe', $hi, $plan['x'], $plan['y']); unset($s['aimforce']); $why = (string)($plan['why'] ?? ''); break; } }   // v1 AIM: it plays the piece and the cell it showed
        if ($r === null) {   // no aim, or its cell is taken (or its piece is gone): it picks again at full value (no fumble)
            if ($plan) $s['reaim'] = 1;
            $m = pfb_search($s, 'foe');
            if ($m === null) break;
            if (pfb_v1r($s, 'style') === 1) $why = $plan ? preg_replace('/^([^:]+): /', '$1: re-aim, ', pfb_why($s, $m), 1) : pfb_why($s, $m);   // 2.7.01: the reason of the move it picks
            $r = pfb_place($s, 'foe', $m[0], $m[1], $m[2]);
        }
        if ($r && $why !== '') $r[0]['why'] = $why;
        if ($r) { $ev = array_merge($ev, $r); $s['lastfoe'][] = $s['pid']; if ($kind === 'water') pfb_current($s, (int)$s['pid'], $ev); }
        if (!empty($s['foe']['again'])) { if (!$again) { $again = true; $n++; if (!empty($s['v1']['tags']) && $r) $ev[] = pfb_note('quick', (string)($r[0]['rid'] ?? 0) && isset($s['pcs'][$r[0]['rid']]) ? (string)$s['pcs'][$r[0]['rid']]['tile']['n'] : (string)($r[0]['n'] ?? '')); } $s['foe']['again'] = 0; }   // a Quick piece it placed: one more piece this turn (once)
    }
    if ($kind === 'beast' && (int)$s['me']['hp'] < $hp0) $s['foe']['grudge'] = 0;   // 2.6.98 Grudge: a hit that lands clears it
    if (!empty($s['wfx'])) $s['me']['wx']['hit'] = max(0, $hp0 - (int)$s['me']['hp']);   // 2.7.09: what its turn took from you
    if ($kind === 'plant' && !$s['over']) pfb_grow($s, $ev);
    $s['foe']['agg'] = 0; $s['foe']['slow'] = 0;
    if (!empty($s['foe']['ab'])) { unset($s['infoe']); $s['foe']['amb'] = 0; }   // 2.7.01: Ambush is for its first turn only
    return $ev;
}

/** 2.6.98 Water "Current": after its piece lands, ONE of your pieces touching it slides a cell straight away from it, if that cell is free. */
function pfb_current(array &$s, int $id, array &$ev): void
{
    $p = $s['pcs'][$id] ?? null; if (!$p || $s['over']) return;
    foreach (PFB_SIDE as [$dx, $dy]) {
        $q = pfb_at($s, $p['x'] + $dx, $p['y'] + $dy); if (!$q || $q['by'] !== 'me') continue;
        $nx = $q['x'] + $dx; $ny = $q['y'] + $dy;
        if ($nx < 0 || $ny < 0 || $nx >= pfb_w($s) || $ny >= pfb_h($s) || isset($s['cell']["$nx,$ny"])) continue;
        if ((int)pfb_abp($s, 'slide', 1) >= 2) { $x2 = $nx + $dx; $y2 = $ny + $dy; if ($x2 >= 0 && $y2 >= 0 && $x2 < pfb_w($s) && $y2 < pfb_h($s) && !isset($s['cell']["$x2,$y2"])) { $nx = $x2; $ny = $y2; } }   // 2.7.01 Strong current: a second cell if it is free and on the board
        unset($s['cell'][$q['x'] . ',' . $q['y']]); $s['cell']["$nx,$ny"] = $q['id']; $s['pcs'][$q['id']]['x'] = $nx; $s['pcs'][$q['id']]['y'] = $ny;
        $e = pfb_note('current', (string)$q['tile']['n']); $e['moved'] = ['id' => $q['id'], 'by' => 'me', 'n' => $q['tile']['n'], 'x' => $nx, 'y' => $ny, 'fx' => (int)$q['x'], 'fy' => (int)$q['y']]; $ev[] = $e;
        return;
    }
}

/** 2.6.98 Plant "Grows": after its turn it puts a Bramble (an environment piece that fits anywhere) on a free cell touching its newest piece; at most one of its own Brambles is out. */
function pfb_grow(array &$s, array &$ev): void
{
    if (empty($s['v1']['env'])) return;   // no environment pieces in this fight (a 2.6.74 fight): nothing grows
    $own = 0; foreach ($s['pcs'] as $q) if ($q['by'] === 'env' && !empty($q['tile']['own'])) $own++;
    if ($own >= (int)pfb_abp($s, 'gcap', 1)) return;   // 2.7.01 Twin growth: up to 2 of its own
    $last = end($s['lastfoe']); $p = $last ? ($s['pcs'][$last] ?? null) : null; if (!$p) return;
    $tile = null; foreach (pfb_env_deck('boss') as $et) if ($et['env'] === 'bramble') { $tile = $et; break; } if (!$tile) return;
    $tile['ed'] = ['L' => ['wild', null], 'R' => ['wild', null], 'T' => ['wild', null], 'B' => ['wild', null]]; $tile['own'] = 1;
    foreach (PFB_SIDE as [$dx, $dy]) {
        $x = $p['x'] + $dx; $y = $p['y'] + $dy;
        if ($x < 0 || $y < 0 || $x >= pfb_w($s) || $y >= pfb_h($s) || isset($s['cell']["$x,$y"]) || pfb_check($s, $tile, $x, $y) === null) continue;
        $id = ++$s['pid']; $s['seq']++;
        $s['pcs'][$id] = ['id' => $id, 'by' => 'env', 'tile' => $tile, 'x' => $x, 'y' => $y, 'born' => $s['round'] + 1, 'seq' => $s['seq']];
        $s['cell']["$x,$y"] = $id;
        $e = pfb_note('grows', (string)$tile['n']); $e['id'] = $id; $e['x'] = $x; $e['y'] = $y; $ev[] = $e;
        return;
    }
}

// ---------------------------------------------------------------- 2.7.09 WEAR PIECE EFFECTS (data/wear_fx.txt, written from claude/wear-pieces/design3.py; mirrored in tools/pfengine.js)
// A wear piece tile carries fx (the code), fxa and fxb (its numbers). The meaning of every code lives in the data file; this code only runs its conditions and actions.
// Only fights whose deck has such a piece carry the extra state ($s['wfx'] = 1), so every other fight plays bit for bit as before.

/** The effect data: ['act' => name => [phase, step], 'trig' | 'pay' | 'rare' => code => [clause(s), text]]. */
function pfb_wx_data(): array
{
    static $D = null;
    if ($D !== null) return $D;
    $D = ['act' => [], 'trig' => [], 'pay' => [], 'rare' => []];
    foreach (pf_data_lines('wear_fx.txt') as $r) if (count($r) >= 4 && isset($D[$r[0]])) $D[$r[0]][$r[1]] = [$r[2], $r[3]];
    return $D;
}
/** The clauses of a code (cached), each ['ph' => phase, 'c0' => conditions checked as it fires, 'c1' => conditions checked when its phase comes, 'a' => action, 'x' => args, 'per', 'cap', 'st' => pre | post]. [] = unknown code. */
function pfb_wx_clauses(string $fx): array
{
    static $C = [];
    if (isset($C[$fx])) return $C[$fx];
    $D = pfb_wx_data(); $src = []; $p = explode('>', $fx);
    if (str_starts_with($fx, 'R:')) { if (isset($D['rare'][substr($fx, 2)])) $src = explode(' ; ', $D['rare'][substr($fx, 2)][0]); }
    elseif (count($p) === 2 && isset($D['trig'][$p[0]], $D['pay'][$p[1]])) {   // a Common piece: TRIG PAY; the trigger goes after @hand / @held (it is checked then)
        $pay = $D['pay'][$p[1]][0]; $tr = $D['trig'][$p[0]][0];
        $src = [preg_match('/^@(hand|held) /', $pay, $m) ? '@' . $m[1] . ' ' . $tr . ' ' . substr($pay, strlen($m[0])) : $tr . ' ' . $pay];
    }
    $out = [];
    foreach ($src as $cl) {
        $tk = preg_split('/\s+/', trim($cl)); $last = (string)array_pop($tk); $per = null; $cap = null;
        if (str_contains($last, '^')) [$last, $cap] = explode('^', $last, 2);
        if (str_contains($last, '*')) [$last, $per] = explode('*', $last, 2);
        $x = explode(':', $last); $a = array_shift($x); $def = $D['act'][$a] ?? null;
        if (!$def) continue;
        $o = ['ph' => $def[0], 'c0' => [], 'c1' => [], 'a' => $a, 'x' => $x, 'per' => $per, 'cap' => $cap, 'st' => $def[1]]; $at = false;
        foreach ($tk as $t) { if ($t[0] === '@') { $o['ph'] = substr($t, 1); $at = true; continue; } $o[$at ? 'c1' : 'c0'][] = $t; }
        if (!$at && in_array($o['ph'], ['hand', 'held'], true)) { $o['c1'] = $o['c0']; $o['c0'] = []; }   // a hand / held action checks its conditions then
        $out[] = $o;
    }
    return $C[$fx] = $out;
}
/** The effect sentence of a piece ('' = none): the trigger and payoff texts, or the Rare text, with its numbers put in. */
function pfb_wx_text(string $fx, int $a, int $b): string
{
    $D = pfb_wx_data(); $r = ['{a}' => (string)$a, '{b}' => (string)$b]; $p = explode('>', $fx);
    if (str_starts_with($fx, 'R:')) return isset($D['rare'][substr($fx, 2)]) ? strtr($D['rare'][substr($fx, 2)][1], $r) : '';
    if (count($p) !== 2 || !isset($D['trig'][$p[0]], $D['pay'][$p[1]])) return '';
    return $D['trig'][$p[0]][1] . ', ' . strtr($D['pay'][$p[1]][1], $r) . '.';
}
/** Does this fight's deck hold a wear piece with an effect? */
function pfb_wx_has(array $s): bool
{
    foreach (['hand', 'draw', 'discard'] as $z) foreach ($s['me'][$z] as $t) if (!empty($t['fx'])) return true;
    return false;
}
/** A number argument: a / b = the piece's numbers, else the number itself. */
function pfb_wx_num(string $x, array $t): int { return $x === 'a' ? (int)($t['fxa'] ?? 0) : ($x === 'b' ? (int)($t['fxb'] ?? 0) : (int)$x); }
/** How far the Yield bar is filled (0..1). */
function pfb_wx_yield(array $s): float
{
    $m = max(0.1, (float)$s['fh']['max']);
    return (!empty($s['v1']['onebar']) ? (float)$s['fh']['now'] + (float)$s['bar']['now'] : (float)$s['fh']['now']) / $m;
}
/** n within [lo, hi] (hi null = no top). */
function pfb_wx_in(int $n, array $x, int $i): bool { return $n >= (int)($x[$i] ?? 0) && (!isset($x[$i + 1]) || $n <= (int)$x[$i + 1]); }
/**
 * One condition. $cx: 'id' = the board piece (null in the hand), 't' = its tile, 'ch' = its chain, 'ph' = the phase, 'pt' = the type of the piece being placed (held),
 * 'e' = the creature Hurt's event and 'blk' = the registered entry (block), 'tgt' = the piece a boost went to. '!' = not.
 */
function pfb_wx_cond(array $s, string $c, array $cx): bool
{
    if ($c !== '' && $c[0] === '!') return !pfb_wx_cond($s, substr($c, 1), $cx);
    $x = explode(':', $c); $t = $cx['t'] ?? []; $p = isset($cx['id']) ? ($s['pcs'][$cx['id']] ?? null) : null; $ch = $cx['ch'] ?? [];
    switch ($x[0]) {
        case 'link':   // linked to a piece of these types (self = its own type)
            if (!$p) return false; $ty = $x[1] === 'self' ? [(string)$t['t']] : explode('/', $x[1]);
            foreach (pfb_links($s, (int)$p['id']) as $n) if (in_array((string)($s['pcs'][$n]['tile']['t'] ?? ''), $ty, true)) return true;
            return false;
        case 'links': return $p !== null && count(pfb_links($s, (int)$p['id'])) >= (int)$x[1];
        case 'cenv': case 'cfoe': foreach ($ch as $q) if (($s['pcs'][$q[0]]['by'] ?? '') === ($x[0] === 'cenv' ? 'env' : 'foe')) return true; return false;
        case 'clen': return $ch && pfb_wx_in(count($ch), $x, 1);
        case 'cmine': $n = 0; foreach ($ch as $q) { $r = $s['pcs'][$q[0]] ?? null; if ($r && $r['by'] === 'me' && in_array((string)$r['tile']['t'], explode('/', $x[1]), true)) $n++; } return $ch && pfb_wx_in($n, $x, 2);
        case 'aimnext': case 'onaim':
            $pl = $s['foe']['plan'] ?? null; if (!$p || !$pl) return false;
            $d = abs((int)$pl['x'] - (int)$p['x']) + abs((int)$pl['y'] - (int)$p['y']); return $x[0] === 'onaim' ? $d === 0 : $d === 1;
        case 'edge': case 'corner': case 'mid':
            if (!$p) return false; $ex = (int)$p['x'] === 0 || (int)$p['x'] === pfb_w($s) - 1; $ey = (int)$p['y'] === 0 || (int)$p['y'] === pfb_h($s) - 1;
            return $x[0] === 'edge' ? ($ex || $ey) : ($x[0] === 'corner' ? ($ex && $ey) : (!$ex && !$ey));
        case 'hand': $n = 0; $ty = explode('/', $x[1]); foreach ($s['me']['hand'] as $h) if (in_array((string)($h['t'] ?? ''), $ty, true)) $n++; return $n >= (int)$x[2];   // pieces of these types in your hand
        case 'fevade': return (int)$s['foe']['evade'] > 0;
        case 'fguard': return (int)$s['foe']['block'] > 0;
        case 'fpcs': case 'fhas':
            $n = 0; foreach ($s['pcs'] as $q) if ($q['by'] === 'foe' && ($x[0] === 'fpcs' || $q['tile']['t'] === $x[1])) $n++;
            return $x[0] === 'fhas' ? $n > 0 : pfb_wx_in($n, $x, 1);
        case 'ygt': return pfb_wx_yield($s) > (float)$x[1];
        case 'ylt': return pfb_wx_yield($s) < (float)$x[1];
        case 'hplt': return (int)$s['me']['hp'] < (float)$x[1] * (int)$s['me']['max'];
        case 'hpfull': return (int)$s['me']['hp'] >= (int)$s['me']['max'];
        case 'hit': return (int)($s['me']['wx']['hit'] ?? 0) > 0;
        case 'nodmg': return !empty($s['me']['wx']['nd']);
        case 'poisoned': return (int)($s['me']['poison'] ?? 0) > 0;
        case 'round': return pfb_wx_in((int)$s['round'] - (($cx['ph'] ?? '') === 'hand' ? 1 : 0), $x, 1);   // at the redraw the round that ends
        case 'last': return $p !== null && (int)$p['born'] + pfb_life($s, $p) - (int)$s['round'] === 1;
        case 'disc': return count($s['me']['discard']) >= (int)$x[1];
        case 'played': return (int)($s['me']['wx']['pl'][$x[1]] ?? 0) >= (int)$x[2];
        case 'lastturn': return (string)($s['me']['wx'][($cx['ph'] ?? '') === 'hand' ? 'ct' : 'lt'] ?? '') === $x[1];   // at the redraw "last turn" is the turn just played
        case 'kept': return (int)($t['kr'] ?? 0) >= (int)$x[1];
        case 'fskip': return (int)($s['foe']['wsk'] ?? 0) > 0;
        case 'tgt': return isset($cx['tgt']) && (string)($s['pcs'][$cx['tgt']]['tile']['t'] ?? '') === $x[1];
        case 'pt': return ($cx['pt'] ?? '') === $x[1];
        case 'first': return (int)($cx['blk']['u'] ?? 0) === 0;
        case 'full': return (int)($cx['e']['dmg'] ?? 1) === 0;
    }
    return false;
}
/** All conditions true? $skipTgt: leave out the tgt ones (checked after the boost). */
function pfb_wx_conds(array $s, array $cs, array $cx, bool $skipTgt = false): bool
{
    foreach ($cs as $c) { if ($skipTgt && str_starts_with(ltrim($c, '!'), 'tgt:')) continue; if (!pfb_wx_cond($s, $c, $cx)) return false; }
    return true;
}
/** A '*per' count: chain, ctype:T (your other pieces of type T in the chain), types (other piece types in it), kept, hand, disc2. */
function pfb_wx_per(array $s, string $per, array $cx): int
{
    $x = explode(':', $per); $ch = $cx['ch'] ?? [];
    switch ($x[0]) {
        case 'chain': return count($ch);
        case 'ctype': $n = 0; foreach ($ch as $q) { $r = $s['pcs'][$q[0]] ?? null; if ($r && $r['by'] === 'me' && $q[0] !== ($cx['id'] ?? null) && in_array((string)$r['tile']['t'], explode('/', $x[1]), true)) $n++; } return $n;
        case 'types': $ty = []; foreach ($ch as $q) { $r = $s['pcs'][$q[0]] ?? null; if ($r && ($r['by'] === 'me' || $r['by'] === 'foe') && $r['tile']['t'] !== ($cx['t']['t'] ?? '')) $ty[(string)$r['tile']['t']] = 1; } return count($ty);
        case 'kept': return (int)($cx['t']['kr'] ?? 0);
        case 'hand': return count($s['me']['hand']);
        case 'disc2': return intdiv(count($s['me']['discard']), 2);
    }
    return 0;
}
/** The number of a clause: its first argument, times its per count, at most its cap. */
function pfb_wx_n(array $s, array $o, array $cx, int $i = 0): int
{
    $n = pfb_wx_num((string)($o['x'][$i] ?? '0'), $cx['t'] ?? []);
    if ($o['per'] !== null) $n *= pfb_wx_per($s, (string)$o['per'], $cx);
    if ($o['cap'] !== null) $n = min($n, pfb_wx_num((string)$o['cap'], $cx['t'] ?? []));
    return $n;
}
/** The creature piece a shrink or a knock picks: the strongest (or weakest) by its value now, ties to the oldest. */
function pfb_wx_foe_pick(array $s, bool $strong): ?int
{
    $best = null; $bv = null;
    foreach ($s['pcs'] as $id => $q) {
        if ($q['by'] !== 'foe') continue; $v = (int)$q['tile']['v'] + (int)($q['wv'] ?? 0);
        if ($bv === null || ($strong ? $v > $bv : $v < $bv)) { $bv = $v; $best = (int)$id; }
    }
    return $best;
}
/** The piece a boost goes to: a piece of yours linked to it (of type $ty if given) that has not fired in this chain yet, newest first; else the newest. */
function pfb_wx_target(array $s, int $id, string $ty): ?int
{
    $best = null;
    foreach (pfb_links($s, $id) as $n) {
        $q = $s['pcs'][$n]; if ($q['by'] !== 'me' || ($ty !== '' && $q['tile']['t'] !== $ty)) continue;
        if (!in_array($n, $s['fired'] ?? [], true)) return $n;
        $best ??= $n;
    }
    return $best;
}
/** Your Charm into the Yield bar (as a Charm piece: the charm factor, Wary). */
function pfb_wx_charm(array &$s, int $n): void
{
    $add = $n * $s['cm']; if (!empty($s['foe']['ab']) && ($wy = pfb_ab($s, 'wary'))) $add *= (float)$wy['mult'];
    $s['bar']['now'] += $add; $s['bar']['charm'] += $add;
}
/** Run one action (post step). $cx as pfb_wx_cond, plus 'g' = guard this firing gave (Hold keeps it), 'fid' = the creature Hurt (block). Adds 'name n' to $e['wfx']. */
function pfb_wx_act(array &$s, array $o, array &$cx, array &$e): void
{
    $a = $o['a']; $x = $o['x']; $n = in_array($a, ['next', 'boost', 'poison', 'mend', 'plenty', 'pluck'], true) ? 0 : pfb_wx_n($s, $o, $cx); $id = $cx['id'] ?? null; $did = true;
    switch ($a) {
        case 'guard': $s['me']['block'] += $n; $cx['g'] = (int)($cx['g'] ?? 0) + $n; break;
        case 'heal': $s['me']['hp'] = max((int)$s['me']['hp'], min((int)$s['me']['max'], (int)$s['me']['hp'] + $n)); break;
        case 'charm': pfb_wx_charm($s, $n); break;
        case 'soothe': $s['foe']['agg'] += $n; break;
        case 'skip': $s['foe']['slow'] = 1; break;
        case 'poison': $n = pfb_wx_num($x[0], $cx['t']); $s['foe']['poison'] = max((int)$s['foe']['poison'], (int)($x[1] ?? 2)); $s['foe']['poison_v'] = max((int)$s['foe']['poison_v'], $n); break;
        case 'evade': $s['me']['evade'] = 1; break;
        case 'hold': $n = (int)($cx['g'] ?? 0); $s['me']['keep'] += $n; break;
        case 'life': if ($id !== null && isset($s['pcs'][$id])) $s['pcs'][$id]['xl'] = max((int)($s['pcs'][$id]['xl'] ?? 0), $n); break;
        case 'stay': if ($id !== null && !in_array($id, $s['wstay'], true)) $s['wstay'][] = $id; break;
        case 'cleanse': $s['me']['poison'] = 0; $s['me']['poison_v'] = 0; $s['me']['hp'] = max((int)$s['me']['hp'], min((int)$s['me']['max'], (int)$s['me']['hp'] + $n)); break;
        case 'knock': $s['wkn'][] = 0; break;
        case 'kill': if (isset($cx['fid'])) $s['wkn'][] = (int)$cx['fid']; break;
        case 'boost': $n = pfb_wx_num($x[0], $cx['t']); $tg = $id !== null ? pfb_wx_target($s, $id, (string)($x[1] ?? '')) : null; if ($tg === null) { $did = false; break; } $s['pcs'][$tg]['wv'] = (int)($s['pcs'][$tg]['wv'] ?? 0) + $n; $cx['tgt'] = $tg; break;
        case 'more': if (!isset($cx['tgt'])) { $did = false; break; } $s['pcs'][$cx['tgt']]['wv'] = (int)($s['pcs'][$cx['tgt']]['wv'] ?? 0) + $n; break;
        case 'add': if (isset($cx['pid'])) $s['pcs'][$cx['pid']]['wv'] = (int)($s['pcs'][$cx['pid']]['wv'] ?? 0) + $n; break;
        case 'mend':   // heal n at the start of each of your next T turns; the same piece again sets its count back (like Simmer)
            $n = pfb_wx_num($x[0], $cx['t']); $tn = (int)($x[1] ?? 2); $hit = false;
            foreach ($s['me']['wmend'] as $i => $m) if ($m[2] === $id) { $s['me']['wmend'][$i] = [$n, $tn, $id]; $hit = true; }
            if (!$hit) $s['me']['wmend'][] = [$n, $tn, $id];
            break;
        case 'bond': if ($s['cm'] > 0 && $s['bond'] < 3) { $s['bond']++; $s['cm'] = min(1.0, $s['cm'] + 0.1); } else $did = false; break;
        case 'pluck':   // once a fight; x2 = twice the chance, sure = it works
            if (!$s['can_pluck'] || $s['plucked']) { $did = false; break; }
            $md = (string)($x[0] ?? '');
            if ($md === 'sure') { $s['plucked'] = 1; $e['pluck'] = 'got'; break; }
            $chn = min(35, 8 + 3 * $s['me']['luckmod']) * ($md === 'x2' ? 2 : 1) / ($s['boss'] ? 2 : 1);
            if (pf_rand($s, 1000) < $chn * 10) { $s['plucked'] = 1; $e['pluck'] = 'got'; } else $e['pluck'] = 'missed';
            break;
        case 'shrink': $tg = pfb_wx_foe_pick($s, true); if ($tg === null) { $did = false; break; } $s['pcs'][$tg]['wv'] = (int)($s['pcs'][$tg]['wv'] ?? 0) - $n; break;
        case 'shrinkall': foreach ($s['pcs'] as $qid => $q) if ($q['by'] === 'foe') $s['pcs'][$qid]['wv'] = (int)($q['wv'] ?? 0) - $n; break;
        case 'fstrip': $s['foe']['block'] = max(0, (int)$s['foe']['block'] - $n); break;
        case 'fnext': $s['foe']['wnx'] = max((int)$s['foe']['wnx'], $n); break;
        case 'fhalf': $s['foe']['whf'] = max((int)$s['foe']['whf'], $n); break;
        case 'bar': $s['fh']['now'] += $n * $s['hm']; break;
        case 'plenty': $n = pfb_wx_num($x[0], $cx['t']); $s['me']['more'] = max((int)($s['me']['more'] ?? 0), $n - PF_HAND_CAP); break;
        case 'hand': $s['me']['wmore'] += $n; break;
        case 'next': $n = pfb_wx_num($x[2], $cx['t']); $s['me']['wx']['nx'][] = [(string)$x[0], (int)$x[1], $n, ($x[3] ?? '') === 'r' ? (int)$s['round'] + 1 : 0]; break;
        case 'recycle':
            $k = min($n, count($s['me']['discard']));
            if ($k > 0) { $take = array_splice($s['me']['discard'], count($s['me']['discard']) - $k); $s['me']['draw'] = pf_shuffle($s, array_merge($s['me']['draw'], $take)); }
            $n = $k; break;
        case 'keep1': $s['me']['wk1'] = (int)$s['round'] + 2; break;   // checked at the redraw that ends next round
        default: $did = false;
    }
    if ($did) $e['wfx'][] = $a . ($n ? ' ' . $n : '');
}
/** The clauses of a firing piece of yours whose fire-time conditions hold (place clauses only when you placed it now). Block / miss clauses are registered here. */
function pfb_wx_fire(array &$s, array $cx, bool $placed): array
{
    $on = [];
    if (isset($GLOBALS['PFB_WX_PROBE'])) ($GLOBALS['PFB_WX_PROBE'])($s, $cx, $placed);   // TEMP PROBE
    foreach (pfb_wx_clauses((string)$cx['t']['fx']) as $i => $o) {
        if ($o['ph'] === 'hand' || $o['ph'] === 'held' || ($o['ph'] === 'place' && !$placed)) continue;
        if (!pfb_wx_conds($s, $o['c0'], $cx, true)) continue;
        if ($o['ph'] === 'block' || $o['ph'] === 'miss') { $s['me'][$o['ph'] === 'block' ? 'wblk' : 'wmiss'][] = ['fx' => (string)$cx['t']['fx'], 'i' => $i, 'a' => (int)($cx['t']['fxa'] ?? 0), 'b' => (int)($cx['t']['fxb'] ?? 0), 'u' => 0]; continue; }
        $on[] = $o;
    }
    return $on;
}
/** A creature Hurt your guard blocked or your Evade made miss: the registered block / miss clauses. */
function pfb_wx_guard(array &$s, array &$e, int $fid): void
{
    $k = !empty($e['evaded']) ? 'wmiss' : ((int)($e['blocked'] ?? 0) > 0 ? 'wblk' : null);
    if ($k === null) return;
    foreach ($s['me'][$k] as $i => $r) {
        $o = pfb_wx_clauses($r['fx'])[$r['i']] ?? null; if (!$o) continue;
        $cx = ['t' => ['fxa' => $r['a'], 'fxb' => $r['b']], 'e' => $e, 'blk' => $r, 'fid' => $fid, 'ph' => $k === 'wblk' ? 'block' : 'miss'];
        if (pfb_wx_conds($s, $o['c1'], $cx)) pfb_wx_act($s, $o, $cx, $e);
        $s['me'][$k][$i]['u']++;
    }
}
/** You placed piece $id: the played count and this turn's type, the "next piece" bonuses and the auras of the pieces waiting in your hand. */
function pfb_wx_placed(array &$s, int $id, array $tile): void
{
    $t = (string)$tile['t']; $s['me']['wx']['pl'][$t] = (int)($s['me']['wx']['pl'][$t] ?? 0) + 1; $s['me']['wx']['ct'] = $t;
    $nx = [];
    foreach ($s['me']['wx']['nx'] as $q) {
        if ($q[0] === $t && ($q[3] === 0 || $q[3] === (int)$s['round'])) { $s['pcs'][$id]['wv'] = (int)($s['pcs'][$id]['wv'] ?? 0) + $q[2]; $q[1]--; }
        if ($q[1] > 0 && ($q[3] === 0 || $q[3] >= (int)$s['round'])) $nx[] = $q;
    }
    $s['me']['wx']['nx'] = $nx;
    $e = [];
    foreach ($s['me']['hand'] as $h) if (!empty($h['fx'])) foreach (pfb_wx_clauses((string)$h['fx']) as $o) {
        $cx = ['t' => $h, 'pt' => $t, 'pid' => $id, 'ph' => 'held'];
        if ($o['ph'] === 'held' && pfb_wx_conds($s, $o['c1'], $cx)) pfb_wx_act($s, $o, $cx, $e);
    }
}
/** At the redraw: does this hand piece stay (its hand clauses)? */
function pfb_wx_keep(array $s, array $t): bool
{
    foreach (pfb_wx_clauses((string)$t['fx']) as $o) if ($o['ph'] === 'hand' && $o['a'] === 'keep' && pfb_wx_conds($s, $o['c1'], ['t' => $t, 'ph' => 'hand'])) return true;
    return false;
}

// ---------------------------------------------------------------- the whole fight

/** Start a board fight: pf_new's hands and bar, then one or two of the creature's gentlest pieces go out (nothing fires for them). */
function pfb_new(array $me, array $c, int $seed, array $opt = []): array
{
    $s = pf_new($me, $c, $seed, $opt);
    $v1 = !empty($opt['v1']) ? pfb_v1_cfg($s['size'], pfb_v1_over($c, is_array($opt['v1']) ? $opt['v1'] : []), max(1, (int)($c['level'] ?? 1))) : null;   // v1 rules (admin setting pfight_v1): this fight's rule numbers, kept in the state
    $fm = ($v1 ? $v1['foe'] : PFB_FOE_MULT) * ($s['size'] === 'boss' ? PFB_BOSS_MULT : 1.0) * (!empty($opt['blank']) ? PFB_BLANK_FOE_MULT : 1.0) * (PFB_FOE_FIRES > 0 ? PFB_FOE_FIRE_MULT : 1.0);
    foreach (['hand', 'draw', 'discard'] as $z) foreach ($s['foe'][$z] as $i => $t) $s['foe'][$z][$i]['v'] = max(1, (int)pf_round($t['v'] * $fm));
    $s['bar']['max'] = pf_round($s['bar']['max'] * ($v1 ? $v1['bar'] : PFB_BAR_MULT), 1);
    if ($v1 && !empty($v1['onebar'])) { $s['bar']['max'] = pf_round($s['bar']['max'] * PFB_V1_ONEBAR_BAR, 1); if ($s['cm'] <= 0 && $s['boss']) $s['cm'] = PF_HOSTILE_CM; }   // 2.6.95 (one shared bar): the bar is 1.15 x as long; a boss takes Charm too (it still ends seen off)
    $s['fh']['max'] = $s['bar']['max'];
    $s['mode'] = 'board'; $s['strip'] = []; $s['pcs'] = []; $s['cell'] = []; $s['pid'] = 0; $s['seq'] = 0; $s['round'] = 1;
    if ($v1) {
        $s['w'] = $v1['w']; $s['h'] = $v1['h']; unset($v1['w'], $v1['h']); $s['v1'] = $v1;
        $s['foe']['kind'] = !empty($v1['kinds']) ? pfb_kind_of($c, $s['size']) : ''; $s['foe']['grudge'] = 0; $s['foe']['nextk'] = null; $s['ven'] = [];   // 2.6.98 class rules
        pfb_v1_tiles($s, $c); pfb_seed_ground($s); $s['envs'] = []; $s['envlog'] = []; $s['reaim'] = 0; $s['me']['flipt'] = 0;
        if ($v1['env']) { $s['env'] = ['draw' => pf_shuffle($s, pfb_env_deck($s['size'], (string)($c['region'] ?? ''), (bool)pfb_v1r($s, 'nowm'), (bool)pfb_v1r($s, 'nothorn'))), 'discard' => [], 'next' => []]; pfb_env_draw($s); if (pfb_v1r($s, 'envopen') === 1) { $s['v1']['envn']++; pfb_env_draw($s); $s['v1']['envn']--; } }   // 2.6.75: the environment's deck; its next pieces lie face up
        $s['me']['slowdraw'] = 0; $s['me']['tripped'] = 0;
        if ($v1['tags']) { $s['me']['poison'] = 0; $s['me']['poison_v'] = 0; $s['foe']['bashnext'] = 0; $s['foe']['again'] = 0; }
        if (pfb_wx_has($s)) {   // 2.7.09 wear piece effects: their state (only in a fight whose deck has one)
            $s['wfx'] = 1; $s['wstay'] = []; $s['wkn'] = [];
            $s['me']['wx'] = ['lt' => '', 'ct' => '', 'nd' => 1, 'hps' => (int)$s['me']['hp'], 'hit' => 0, 'pl' => [], 'nx' => []];
            $s['me'] += ['wblk' => [], 'wmiss' => [], 'wmend' => [], 'wk1' => 0, 'wmore' => 0]; $s['foe'] += ['wnx' => 0, 'whf' => 0, 'wsk' => 0];
        }
        if (!empty($c['ab']) && pfb_v1r($s, 'abil') === 1) pfb_ab_init($s, $c);   // 2.7.01 abilities (an E id replaces the class rule)
        if (pfb_v1r($s, 'style') === 1 && !empty($c['ai']) && isset(PFB_AI[(string)$c['ai']])) { $s['foe']['aid'] = (string)$c['ai']; if ($ai = pfb_ai_make((string)$c['ai'], (array)($c['aip'] ?? []))) $s['foe']['ai'] = $ai; }   // 2.7.01 play style
    }
    if (!empty($opt['blank'])) {   // variant: a blank wild piece in the centre; both sides put a start piece next to it, hidden (see pfb_start)
        $s['pid'] = 1; $s['seq'] = 1; $cx = intdiv(pfb_w($s), 2); $cy = intdiv(pfb_h($s), 2);
        if (pfb_v1r($s, 'blankrand') === 1) { $iw = max(1, pfb_w($s) - 2); $ih = max(1, pfb_h($s) - 2); $k = pf_rand($s, $iw * $ih); $cx = 1 + $k % $iw; $cy = 1 + intdiv($k, $iw); }   // 2.6.98: the inert Blank starts on a random inner cell (all four sides on the board)
        $s['pcs'][1] = ['id' => 1, 'by' => 'none', 'tile' => ['k' => 'blank', 'n' => 'Blank', 't' => 'blank', 'v' => 0, 'tag' => '', 'r' => null], 'x' => $cx, 'y' => $cy, 'born' => 1, 'seq' => 1];
        $s['cell']["$cx,$cy"] = 1; $s['start'] = true;
        pf_draw($s, 'foe', $s['foe']['hsize']); pfb_intent($s);
        return $s;
    }
    $n = $s['size'] === 'boss' ? 2 : 1;
    for ($k = 0; $k < $n; $k++) {
        $pick = pfb_anchor_pick($s); if ($pick === null) continue; $hand = $s['foe']['hand'];
        $cells = $s['pcs'] ? null : [[intdiv(pfb_w($s), 2), intdiv(pfb_h($s), 2)]];
        $tile = $hand[$pick]; $cells ??= pfb_cells($s, $tile);
        if (!$cells) continue;
        [$x, $y] = $cells[pf_rand($s, count($cells))];
        array_splice($s['foe']['hand'], $pick, 1);
        $id = ++$s['pid']; $s['seq']++;
        $s['pcs'][$id] = ['id' => $id, 'by' => 'foe', 'tile' => $tile, 'x' => $x, 'y' => $y, 'born' => 1, 'seq' => $s['seq']];
        $s['cell']["$x,$y"] = $id;
    }
    pf_draw($s, 'foe', $s['foe']['hsize']);
    pfb_intent($s);
    return $s;
}

/** The side of the Blank a clicked cell is on ('L', 'R', 'T', 'B'), or null when it is not next to it. The Blank is where the state says it is (2.6.981: not always the centre). */
function pfb_start_side(array $s, int $x, int $y): ?string
{
    $cx = (int)($s['pcs'][1]['x'] ?? intdiv(pfb_w($s), 2)); $cy = (int)($s['pcs'][1]['y'] ?? intdiv(pfb_h($s), 2)); $dx = $x - $cx; $dy = $y - $cy;
    if (abs($dx) + abs($dy) !== 1) return null;
    return $dx < 0 ? 'L' : ($dx > 0 ? 'R' : ($dy < 0 ? 'T' : 'B'));
}

/**
 * Blank-centre variant: the hidden start. You pick a hand piece and a side of the blank (L, R, T, B). The creature picked its piece and side already, without seeing yours
 * (its gentlest non-Hurt piece, a side by the seeded roll); if you chose the same side, yours stays and its piece takes the next free side. Nothing fires. A boss puts out two.
 * Returns an error string or null. Afterwards turn 1 begins; the blank vanishes at the end of round 1 and its place becomes an open site.
 */
function pfb_start(array &$s, int $handIdx, string $side): ?string
{
    if (empty($s['start'])) return 'The fight has already started.';
    if (!isset(PFB_SIDE[$side])) return 'Pick a side: L, R, T or B.';
    $tile = $s['me']['hand'][$handIdx] ?? null; if (!$tile) return 'No such piece in your hand.';
    $cx = (int)($s['pcs'][1]['x'] ?? intdiv(pfb_w($s), 2)); $cy = (int)($s['pcs'][1]['y'] ?? intdiv(pfb_h($s), 2));   // where the Blank is (2.6.98: not always the centre)
    $sides = array_keys(PFB_SIDE); $fs = $sides[pf_rand($s, 4)];   // the creature's choice is rolled before yours is looked at
    $put = function (string $who, int $idx, string $sd) use (&$s, $cx, $cy): void {
        [$dx, $dy] = PFB_SIDE[$sd]; $x = $cx + $dx; $y = $cy + $dy; $tile = $s[$who]['hand'][$idx];
        array_splice($s[$who]['hand'], $idx, 1);
        $id = ++$s['pid']; $s['seq']++;
        $s['pcs'][$id] = ['id' => $id, 'by' => $who, 'tile' => $tile, 'x' => $x, 'y' => $y, 'born' => 1, 'seq' => $s['seq']];
        $s['cell']["$x,$y"] = $id;
    };
    $put('me', $handIdx, $side);
    $n = $s['size'] === 'boss' ? 2 : 1; $free = array_values(array_diff($sides, [$side]));
    $start = array_search($fs, $free, true); if ($start === false) $start = 0;
    for ($k = 0; $k < $n; $k++) {
        $pick = pfb_anchor_pick($s); if ($pick === null) break;
        $put('foe', $pick, $free[($start + $k) % count($free)]);
    }
    pf_draw($s, 'foe', $s['foe']['hsize']); pfb_intent($s);
    $s['start'] = false;
    return null;
}

function pfb_intent(array &$s): void
{
    if (!empty($s['v1'])) pfb_forecast($s);   // v1: the next terrain events are announced first (the creature's search knows them)
    $kind = pfb_kind($s); $m = null;
    if ($kind === 'boss' && !empty($s['foe']['nextk'])) $m = pfb_search($s, 'foe', true, (string)$s['foe']['nextk']);   // 2.6.98 Two turns: the piece it showed last round is forced now (its cell is chosen now)
    $s['foe']['nextk'] = null;
    if ($m === null) $m = pfb_search($s, 'foe');
    $s['foe']['intent'] = $m ? $s['foe']['hand'][$m[0]]['t'] : null;
    if (!empty($s['v1']['aim'])) { $h = $m ? $s['foe']['hand'][$m[0]] : null; $s['foe']['plan'] = $h && pfb_foe_len($s) > 0 ? ['k' => $h['k'], 'n' => $h['n'], 't' => $h['t'], 'v' => $h['v'], 'tag' => $h['tag'], 'x' => $m[1], 'y' => $m[2]] : null; if ($s['foe']['plan'] && pfb_v1r($s, 'style') === 1) $s['foe']['plan']['why'] = pfb_why($s, $m); }   // v1 AIM: the piece and the cell of its next move, shown to the player and committed (2.7.01: with its reason)
    if ($kind !== '' && !empty($s['foe']['plan'])) {   // 2.6.98 class rules that add to the aim
        if ($kind === 'bird') { $am = pfb_search($s, 'foe', true, null, [(int)$m[1], (int)$m[2]]); if ($am) { $ah = $s['foe']['hand'][$am[0]]; $s['foe']['plan']['alt'] = ['k' => $ah['k'], 'n' => $ah['n'], 't' => $ah['t'], 'v' => $ah['v'], 'tag' => $ah['tag'], 'x' => $am[1], 'y' => $am[2]]; if (pfb_v1r($s, 'style') === 1) $s['foe']['plan']['alt']['why'] = pfb_why($s, $am); } }   // Two aims
        if ($kind === 'boss') {   // Two turns: the piece after this one, chosen on the board as it will stand once the aim has landed
            $w = $s;
            if (pfb_place($w, 'foe', $m[0], (int)$m[1], (int)$m[2]) !== null) { $nm = pfb_search($w, 'foe'); if ($nm) { $nh = $w['foe']['hand'][$nm[0]]; $s['foe']['plan']['next'] = ['k' => $nh['k'], 'n' => $nh['n'], 't' => $nh['t'], 'v' => $nh['v'], 'tag' => $nh['tag']]; $s['foe']['nextk'] = $nh['k']; } }
        }
    }
    if (!empty($s['foe']['plan']) && pfb_v1r($s, 'aimtot')) $s['foe']['plan']['tot'] = pfb_aim_total($s);   // 2.6.95: what its committed move would do now (one dry run; stored with the aim)
}

/**
 * 2.6.95 (aim total): what the creature's committed move would do to you if it played now. A dry run on a copy, exactly as pfb_foe_turn plays it (aimforce, its first piece):
 * ['hp' => health you lose (through your guard), 'ids' => the pieces its chain fires besides the placed one, in order: [id, by 'me'|'foe'|'env', for an environment piece kind and v = Sun's multiplier / Rain's guard / Bramble's cost to you / Thornburst's cost to it], 'g' => guard of yours it eats, 'bait' => damage to the creature from YOUR pieces its chain fires, 'heal' => its own heal, 'n' => pieces fired, 'why' => short reasons].
 * Quick's extra piece, the poison ticks and the terrain turn are not in the numbers (Quick is named in 'why'). Returns null when there is no aim, or ['broken' => 'cell'|'edge'|'slow'] when the aim cannot play
 * ('cell' = something stands on its cell, 'edge' = its edges no longer fit there or its piece is gone, 'slow' = it loses its turn). Never called from pfb_cell_preview.
 */
function pfb_aim_total(array $s): ?array
{
    $plan = $s['foe']['plan'] ?? null;
    if (!$plan || !empty($s['over'])) return null;
    if (pfb_foe_len($s) < 1) return ['broken' => 'slow'];
    $x = (int)$plan['x']; $y = (int)$plan['y'];
    if (isset($s['cell']["$x,$y"])) {
        $cid = $s['cell']["$x,$y"]; $mp = $s['pcs'][$cid] ?? null;   // 2.6.98 (aimhit): your piece on its Hurt cell is struck, so the aim is not broken: it says STRIKE
        if (pfb_v1r($s, 'aimhit') === 1 && ($plan['t'] ?? '') === 'hurt' && $mp && $mp['by'] === 'me') {
            $g = ($mp['tile']['t'] ?? '') === 'guard' ? (int)$mp['tile']['v'] : 0; $hit = (int)($plan['v'] ?? 0);
            return ['hp' => 0, 'g' => 0, 'bait' => 0.0, 'heal' => 0, 'n' => 1, 'why' => [], 'ids' => [], 'strike' => ['id' => (int)$cid, 'n' => (string)($mp['tile']['n'] ?? ''), 'broke' => $g < $hit, 'hit' => $hit, 'guard' => $g]];
        }
        if (pfb_kind($s) === 'bird' && !empty($plan['alt']) && !isset($s['cell'][$plan['alt']['x'] . ',' . $plan['alt']['y']])) { $plan = $plan['alt']; $x = (int)$plan['x']; $y = (int)$plan['y']; $usedAlt = true; }   // 2.6.98 Two aims: the second aim plays
        else return ['broken' => 'cell'];
    }
    $hi = null; foreach ($s['foe']['hand'] as $i => $ht) if ($ht['k'] === $plan['k']) { $hi = $i; break; }
    if ($hi === null) return ['broken' => 'edge'];
    $w = $s; $w['spent'] = []; $w['lastfoe'] = []; $w['gone'] = []; pfb_begin($w, 'foe'); if (!empty($w['foe']['ab'])) { $tmp = []; pfb_ab_turn($w, $tmp); }   // 2.7.01: Plated and Regrow run before it plays (a Plated guard is a Bash's damage)
    $hp0 = (int)$w['me']['hp']; $w['aimforce'] = true; if (!empty($w['foe']['ab'])) $w['infoe'] = 1; $ev = pfb_place($w, 'foe', $hi, $x, $y); unset($w['aimforce'], $w['infoe']);   // 2.7.01: Ambush shows in the number
    if ($ev === null) return ['broken' => 'edge'];
    $g = 0; $bait = 0.0; $heal = 0; $n = 0; $why = []; $sun = false; $mud = false; $combo = []; $fires = []; $quick = !empty($w['foe']['again']); $ids = [];
    foreach ($ev as $e) {
        if (!isset($e['id'])) continue;
        $n++;
        if (empty($e['root'])) { $q = ['id' => (int)$e['id'], 'by' => $e['by'] === 'foe' ? 'foe' : ($e['by'] === 'env' ? 'env' : 'me')];   // after 2.6.96: which pieces fire, in order (the page lights the environment's and yours)
            if ($q['by'] === 'env') { $q['kind'] = (string)($e['kind'] ?? ''); $q['v'] = $q['kind'] === 'sun' ? pf_round((float)$s['v1']['sun'], 2) : ($q['kind'] === 'rain' ? (int)($e['guard'] ?? 0) : ($q['kind'] === 'bramble' ? (int)$e['me'] : ($q['kind'] === 'thorn' ? (int)pf_round((float)$e['foe']) : 0))); }
            $ids[] = $q; }
        if (($e['by'] ?? '') === 'env') { if (($e['kind'] ?? '') !== 'sun') $fires[] = 'fires ' . $e['n']; continue; }   // a Sun says 'Sun x2' instead
        if ($e['by'] === 'foe') {
            if ($e['t'] === 'hurt') $g += (int)($e['blocked'] ?? 0);
            if ($e['t'] === 'heal' || ($e['t'] === 'trick' && $e['tag'] === 'heal')) $heal += (int)pf_round((float)($e['healed'] ?? $e['v']), 0);
            if (!empty($e['sun'])) $sun = true;
            if (!empty($e['mud'])) $mud = true;
            if (!empty($e['combo'])) $combo[$e['combo']] = 1;
        } else { $bait += (float)($e['fh'] ?? 0); $fires[] = 'fires your ' . $e['n']; }
    }
    if ($sun) $why[] = 'Sun x' . rtrim(rtrim(number_format((float)$s['v1']['sun'], 2, '.', ''), '0'), '.');
    foreach (array_keys($combo) as $c) $why[] = 'combo ' . $c;
    foreach ($fires as $f) $why[] = $f;
    if ($quick) $why[] = 'Quick: plays again';
    if ($mud) $why[] = 'Mud -' . (int)pf_round(100 * (float)($s['v1']['mud'] ?? 0)) . '%';
    if (!empty($usedAlt)) array_unshift($why, 'its second aim');
    $hpTot = $hp0 - (int)$w['me']['hp'];
    if ($quick) { $w3 = $s; $h3 = (int)$w3['me']['hp']; pfb_foe_turn($w3, 0); $more = $h3 - (int)$w3['me']['hp']; if ($more !== $hpTot) { $hpTot = $more; $why[] = 'Quick: its second piece is in the number'; } }   // 2.6.986: the whole turn, not just the first piece
    return ['hp' => $hpTot, 'g' => $g, 'bait' => pf_round($bait, 1), 'heal' => $heal, 'n' => $n, 'why' => $why, 'ids' => $ids];
}

/**
 * The player's turn: ONE action. $moves holds one entry:
 *   [handIdx, x, y]        place a hand piece at (x,y)
 *   ['c', x, y]            place the set-aside group with its top-left at (x,y)
 *   ['j', a, b, side]      set aside two hand pieces joined: b on the `side` of a (no effect this turn)
 *   ['h', b, anc, side]    add hand piece b to the set-aside group, onto group piece anc's `side`
 * Returns ['ev' => events, 'err' => ?string]; on an error nothing changed. $dry = true: report what a place would do (a copy; no creature turn). $withAim (dry, aimtot fights): adds 'aim' = the creature's committed move after this placement: pfb_aim_total (null: no aim).
 */
function pfb_play(array &$s, array $moves, int $turn, ?callable $canPlay = null, bool $dry = false, bool $withAim = false): array
{
    if ($s['over']) return ['ev' => [], 'err' => 'The fight is over.'];
    if (!empty($s['start'])) return ['ev' => [], 'err' => 'Pick your start piece first.'];
    if ($turn !== $s['turn']) return ['ev' => [], 'err' => 'stale'];
    if (count($moves) !== 1) return ['ev' => [], 'err' => 'One action a turn.'];
    $mv = $moves[0]; $bad = ['ev' => [], 'err' => 'Those moves are not valid.'];
    if (!is_array($mv) || !$mv) return $bad;
    if ($mv[0] === 'f' && !empty($s['v1']['flip'])) {   // v1 FLIP: free, the turn goes on (a dry run answers whether it may be flipped; nothing changes)
        if (count($mv) !== 2 || !is_int($mv[1])) return $bad;
        if ($dry) { $w = $s; return ['ev' => [], 'err' => pfb_flip($w, $mv[1], $turn), 'free' => true]; }
        return ['ev' => [], 'err' => pfb_flip($s, $mv[1], $turn), 'free' => true];
    }
    $w = $s;   // work on a copy: anything illegal means nothing happens
    $w['reshuf'] = []; $w['cut'] = 0; $w['spent'] = [];
    $w['lastfoe'] = []; $w['gone'] = [];   // 2.6.88: what the creature put down and what left LAST round is not this turn's news. Without this a turn that ends the fight (no creature turn, no end of round) replayed them again.
    if (!empty($w['v1'])) $w['envlog'] = [];
    pfb_begin($w, 'me');
    $ev = [];
    if (is_int($mv[0])) {
        if (count($mv) !== 3 || !is_int($mv[1]) || !is_int($mv[2]) || !isset($w['me']['hand'][$mv[0]])) return $bad;
        if ($canPlay && ($why = $canPlay($w['me']['hand'][$mv[0]])) !== null) return ['ev' => [], 'err' => $why];
        $r = pfb_place($w, 'me', $mv[0], $mv[1], $mv[2]);
        if ($r === null) return ['ev' => [], 'err' => 'That piece does not fit there.'];
        $ev = $r;
    } elseif ($mv[0] === 'c') {
        if (count($mv) !== 3 || !is_int($mv[1]) || !is_int($mv[2])) return $bad;
        if (empty($w['me']['held']) && !pfb_v1r($w, 'aside')) return $bad;   // 2.6.95: no group set aside and none allowed
        if (empty($w['me']['held'])) return ['ev' => [], 'err' => 'You have no group set aside.'];
        if ($canPlay) foreach ($w['me']['held']['pcs'] as $gp) if (($why = $canPlay($gp['tile'])) !== null) return ['ev' => [], 'err' => $why];
        $r = pfb_place_group($w, 'me', $mv[1], $mv[2]);
        if ($r === null) return ['ev' => [], 'err' => 'The group does not fit there.'];
        $ev = $r;
    } elseif ($mv[0] === 'j' || $mv[0] === 'h') {
        if (!pfb_v1r($w, 'aside') && empty($w['me']['held'])) return $bad;   // 2.6.95: no setting aside in a new fight (a group already held can still be added to and played)
        if ($mv[0] === 'j') { if (count($mv) !== 4 || !is_int($mv[1]) || !is_int($mv[2]) || !is_string($mv[3])) return $bad; $err = pfb_connect($w, 'me', $mv[1], $mv[2], $mv[3]); }
        else { if (count($mv) !== 4 || !is_int($mv[1]) || !is_int($mv[2]) || !is_string($mv[3])) return $bad; $err = pfb_connect($w, 'me', null, $mv[1], $mv[3], $mv[2]); }
        if ($err) return ['ev' => [], 'err' => $err];
        $newest = $mv[0] === 'j' ? $w['me']['held']['pcs'][1]['tile'] : end($w['me']['held']['pcs'])['tile'];   // the piece just set aside
        $gd = (int)ceil((int)$newest['v'] * PFB_SETASIDE_GUARD); $w['me']['block'] += $gd;
        $names = array_map(fn($gp) => (string)$gp['tile']['n'], $w['me']['held']['pcs']);
        $ev = [['snap' => pfb_snap($w), 'by' => 'me', 'connect' => true, 'n' => implode(' + ', $names), 'types' => array_map(fn($gp) => (string)$gp['tile']['t'], $w['me']['held']['pcs']), 'size' => count($names)]];
    } else return $bad;
    foreach ($ev as $i => $e0) $ev[$i]['ta'] = 'me';   // whose turn the event happened in (a chain can run through the other side's pieces; the page groups by this)
    if ($dry) return ['ev' => $ev, 'err' => null, 'bar' => pf_round($w['bar']['now'], 1), 'max' => $w['bar']['max'], 'fh' => pf_round($w['fh']['now'], 1), 'fhmax' => $w['fh']['max'], 'hp' => $w['me']['hp'], 'block' => $w['me']['block'], 'over' => $w['over']] + ($withAim && pfb_v1r($w, 'aimtot') ? ['aim' => pfb_aim_total($w)] : []);
    if (!$w['over']) { $fe = pfb_foe_turn($w, 0); foreach ($fe as $i => $e0) $fe[$i]['ta'] = 'foe'; $ev = array_merge($ev, $fe); }
    $trip = !$w['over'] && !empty($w['v1']) && !empty($w['me']['slowdraw']);
    if (!$w['over']) pfb_end_round($w);
    if (!empty($w['v1'])) $ev = array_merge($ev, pfb_env_events($w));   // v1: the terrain turn, as events after the creature's (ta 'env')
    if ($trip && !$w['over']) { $tn = pfb_note('trip'); $tn['ta'] = $ev ? (string)(end($ev)['ta'] ?? 'foe') : 'foe'; $ev[] = $tn; }   // 2.6.76: you draw one fewer
    pfb_guard_notes($w, $ev);   // 2.6.77
    $w['fx'] = pfb_fx($ev);
    $w['log'][] = ['turn' => $s['turn'], 'n' => 1];
    $s = $w;
    return ['ev' => $ev, 'err' => null];
}

/**
 * 2.6.66: what placing a hand piece (or the set-aside group, $handIdx = 'c') at each of its legal cells would do, for the numbers on the lit cells. Runs the whole turn on a copy per cell
 * (your chain, then the creature's answer; nothing is saved). Returns ["x,y" => ['dmg' => creature health taken, 'ch' => charm gained, 'hp' => health you lose in your own chain
 * (the creature's Hurt pieces it links into), 'n' => pieces that fire, 'rp' => health the creature's answer takes next, 'end' => fight ends]]. Only numbers: nothing about the creature's hand is named.
 */
function pfb_cell_preview(array $s, $handIdx, bool $flip = false): array
{
    if ($s['over'] || !empty($s['start'])) return [];
    if ($flip) {   // v1: the numbers with the hand piece flipped (nothing is saved; empty when it may not be flipped)
        if ($handIdx === 'c' || !pfb_can_flip($s, (int)$handIdx)) return [];
        $t = $s['me']['hand'][(int)$handIdx]; if (!empty($t['flip'])) unset($t['flip']); else $t['flip'] = true; $s['me']['hand'][(int)$handIdx] = $t;
    }
    if ($handIdx === 'c') { if (empty($s['me']['held'])) return []; $cells = pfb_group_spots($s, $s['me']['held']); }
    else { $tile = $s['me']['hand'][(int)$handIdx] ?? null; if (!$tile) return []; $cells = pfb_cells($s, $tile, 'me'); }
    $o = []; $fh0 = (float)$s['fh']['now']; $b0 = (float)$s['bar']['now']; $hp0 = (int)$s['me']['hp'];
    if (!empty($s['v1'])) {   // v1: your own chain only (no reply number: the creature shows its aim instead). 'used' = the chain uses its pieces up, 'tw' = Teamwork factor, 'sun' = your pieces that fire on a sunny cell
        foreach ($cells as $c) {
            $w = $s; $r = pfb_play($w, [[$handIdx === 'c' ? 'c' : (int)$handIdx, $c[0], $c[1]]], $s['turn'], null, true);
            if ($r['err']) continue;
            $n = 0; $tw = 1.0; $sun = 0; $mud = 0; $hw = []; $hpp = $hp0;
            foreach ($r['ev'] as $e) { if (!isset($e['barnow'])) continue; $n++; if (isset($e['tw'])) $tw = (float)$e['tw']; if (!empty($e['sun']) && $e['by'] === 'me') $sun++; if (!empty($e['mud']) && $e['by'] === 'me') $mud++;
                if ((int)$e['hpnow'] < $hpp) $hw[] = [(string)$e['n'], (string)$e['by'], $hpp - (int)$e['hpnow']]; $hpp = (int)$e['hpnow']; }   // 2.7.01 costly cell: each piece of the chain that took your health (name, whose, how much)
            $o[$c[0] . ',' . $c[1]] = ['dmg' => (int)pf_round($r['fh'] - $fh0), 'ch' => (int)pf_round($r['bar'] - $b0), 'hp' => max(0, $hp0 - (int)$r['hp']), 'n' => $n, 'used' => !empty($r['ev'][0]['used']), 'tw' => $tw, 'sun' => $sun, 'end' => (bool)$r['over']] + (!empty($s['v1']['env']) ? ['mud' => $mud] : []) + ($hp0 > (int)$r['hp'] && $hw ? ['hw' => $hw] : []);   // mud: your pieces in the chain that a Mud weakens; hw (2.7.01): only on a cell that costs health
            foreach ($r['ev'] as $e) if (($e['note'] ?? '') === 'palaim') $o[$c[0] . ',' . $c[1]]['pal'] = ['id' => (int)$e['tid'], 'n' => (string)$e['n'], 'x' => (int)$e['x'], 'y' => (int)$e['y']];   // 2.7.08 pal targeting: the creature piece your pal knocks off from here
        }
        return $o;
    }
    foreach ($cells as $c) {
        $w = $s; $r = pfb_play($w, [[$handIdx === 'c' ? 'c' : (int)$handIdx, $c[0], $c[1]]], $s['turn']);
        if ($r['err']) continue;
        $fh = $fh0; $b = $b0; $hp = $hp0; $hpMe = $hp0; $n = 0;
        foreach ($r['ev'] as $e) {
            if (!isset($e['barnow'])) continue;
            $fh = (float)$e['fhnow']; $b = (float)$e['barnow']; $hp = (int)$e['hpnow'];
            if (($e['ta'] ?? '') === 'me') { $hpMe = $hp; $n++; }
        }
        $o[$c[0] . ',' . $c[1]] = ['dmg' => (int)pf_round($fh - $fh0), 'ch' => (int)pf_round($b - $b0), 'hp' => max(0, $hp0 - $hpMe), 'n' => $n, 'rp' => max(0, $hpMe - $hp), 'end' => (bool)$w['over']];
    }
    return $o;
}

/** What to show of the last turn: each chain that fired as [by, ids in firing order] (the client draws a glow on its linked joints and a stamp with its length). */
function pfb_fx(array $ev): array
{
    $o = [];
    foreach ($ev as $e) {
        if (!isset($e['id'])) continue;
        if (!empty($e['root']) || !$o) $o[] = ['by' => $e['by'], 'ids' => []];
        $o[count($o) - 1]['ids'][] = (int)$e['id'];
    }
    return array_values(array_filter($o, fn($c) => count($c['ids']) >= 2));
}

function pfb_end_round(array &$s): void
{
    if (!empty($s['v1'])) { if (!empty($s['v1']['env'])) pfb_env_place($s); else pfb_env_turn($s); if ($s['over']) return; }   // v1: the environment's turn (2.6.75: it places a piece; a 2.6.74 fight: events land, bramble pricks), then old pieces expire
    $slow = 0;
    if (!empty($s['v1']['tags'])) {   // creature tags: its poison works on you (after the terrain), and a trip costs you one draw
        if ((int)$s['me']['poison'] > 0) {
            $pv = max(1, (int)$s['me']['poison_v']); if ((int)$s['me']['evade'] > 0 || !empty($s['me']['evd'])) $pv = 0;   // 2.6.988: Evade stops the poison tick (it still counts down); 2.7.01: also when its Hurt already used the Evade up (evd)
            $s['me']['hp'] = max(0, $s['me']['hp'] - $pv); $s['me']['poison']--;
            $s['envlog'][] = ['k' => 'poison', 'x' => null, 'y' => null, 'me' => $pv, 'foe' => 0.0];
            if ($s['me']['poison'] === 0) $s['me']['poison_v'] = 0;
            if (pf_check_end($s)) return;
        }
        $s['me']['simmer'] = 0;
        if ((int)($s['me']['regen'] ?? 0) > 0) { $hh = min(2, (int)$s['me']['max'] - (int)$s['me']['hp']); $s['me']['hp'] += max(0, $hh); $s['me']['regen']--; $s['me']['simmer'] = max(0, $hh); }   // 2.6.990 Simmer
    }
    if (!empty($s['wfx']) && $s['me']['wmend']) {   // 2.7.09 wear 'mend': heals as your turn starts (shown with Simmer)
        $hh = 0; $ml = [];
        foreach ($s['me']['wmend'] as $m) { $h1 = max(0, min((int)$m[0], (int)$s['me']['max'] - (int)$s['me']['hp'])); $s['me']['hp'] += $h1; $hh += $h1; if ($m[1] > 1) $ml[] = [$m[0], $m[1] - 1, $m[2]]; }
        $s['me']['wmend'] = $ml; $s['me']['simmer'] = (int)($s['me']['simmer'] ?? 0) + $hh;
    }
    $slow = !empty($s['me']['slowdraw']) ? 1 : 0; $s['me']['slowdraw'] = 0; $s['me']['tripped'] = $slow;   // 2.6.76: the hand area says so; 2.7.06: also in learner fights (tags 0), where Stagger set the flag and nothing used it
    $gone = pfb_expire($s);
    foreach ($s['ven'] ?? [] as $vk => $vr) { if ($vr <= 1) unset($s['ven'][$vk]); else $s['ven'][$vk] = $vr - 1; }   // 2.6.98 venom fades
    if (!empty($s['v1']['env'])) { $eg = array_values(array_map(fn($p) => $p['id'], array_filter($gone, fn($p) => $p['by'] === 'env'))); if ($eg) $s['envlog'][] = ['k' => 'expire', 'x' => null, 'y' => null, 'me' => 0, 'foe' => 0.0, 'ids' => $eg]; }   // 2.6.75: environment pieces whose time is up
    pf_draw($s, 'foe', $s['foe']['hsize']);
    $s['turn']++; $s['round']++;
    if (!empty($s['v1'])) {   // 2.6.77: your guard fades when your turn starts; only a Hold guard that is still standing (not used up by the hits) carries over, once
        $kept = min((int)$s['me']['keep'], (int)$s['me']['block']); $s['me']['faded'] = max(0, (int)$s['me']['block'] - $kept); $s['me']['kept'] = $kept;
        $s['me']['block'] = $kept; $s['me']['keep'] = 0;
    } else { $s['me']['block'] = $s['me']['keep']; $s['me']['keep'] = 0; }   // a new turn for you: last turn's guard is gone (a Hold guard carries over once)
    $s['me']['thorns'] = false; $s['me']['evade'] = 0; unset($s['me']['evd']);
    $more = (int)($s['me']['more'] ?? 0); $s['me']['more'] = 0;   // 2.6.990 Plenty: one more piece this round
    $wfx = !empty($s['wfx']);
    if ($wfx) { $more += (int)$s['me']['wmore']; $s['me']['wmore'] = 0; $s['me']['wblk'] = []; $s['me']['wmiss'] = []; }   // 2.7.09 wear: extra pieces; the block / miss effects end with your guard
    if (pfb_v1r($s, 'redraw')) {
        $kept = []; $out = [];
        foreach ($s['me']['hand'] as $ht) {
            $wk = $wfx && !empty($ht['fx']);
            if (($ht['tag'] ?? '') === 'keep' || ($wk && pfb_wx_keep($s, $ht))) { if ($wk) $ht['kr'] = (int)($ht['kr'] ?? 0) + 1; $kept[] = $ht; continue; }   // 2.6.990 Keeper (2.7.09: a wear Keeper, and how many rounds it waited)
            unset($ht['flip'], $ht['ft'], $ht['kr']); $out[] = $ht;
        }
        if ($wfx && (int)$s['me']['wk1'] === (int)$s['round'] && $out) { $bi = 0; foreach ($out as $i => $ht) if ((int)$ht['v'] > (int)$out[$bi]['v']) $bi = $i; $kept[] = $out[$bi]; array_splice($out, $bi, 1); $s['me']['wk1'] = 0; }   // 2.7.09 wear 'keep1': the strongest unplayed piece stays
        foreach ($out as $ht) $s['me']['discard'][] = $ht;
        $s['me']['hand'] = $kept; pf_draw($s, 'me', PF_HAND_CAP - $slow + $more);
    }   // 2.6.990 Keeper: a Keeper piece stays in the hand   // 2.6.95: every unplayed piece goes to the discard (flip cleared), then a fresh hand of 5 (4 when tripped)
    else pf_draw($s, 'me', min(PF_HAND_CAP + $more, count($s['me']['hand']) + PF_DRAW - $slow));
    $s['gone'] = array_merge(array_map(fn($p) => pfb_gone_entry($s, $p, true), $s['spent'] ?? []), array_map(fn($p) => pfb_gone_entry($s, $p, false), $gone));   // for the replay: they are shown until everything has scored, then they go
    $s['spawn'] = (!empty($s['nospawn']) || !pfb_v1r($s, 'spawn')) ? null : pfb_spawn($s); unset($s['nospawn']);   // next release (Josh: an enemy piece popping in at the end of your resolution is a bug): new fights get no free board piece for the creature (rule 'spawn' 0); fights started earlier keep it.   // 2.6.99: a strike spent the creature's turn: no free piece pops in before yours
    if ($s['turn'] > PF_TURN_CAP) { $s['over'] = $s['boss'] ? 'defeat' : 'stall'; return; }
    pfb_intent($s);
}

/** Pass the turn with nothing to place (no piece fits anywhere): the creature moves, the round ends. */
function pfb_pass(array &$s, int $turn): array
{
    if ($s['over'] || $turn !== $s['turn']) return ['ev' => [], 'err' => $s['over'] ? 'The fight is over.' : 'stale'];
    if (!empty($s['start'])) return ['ev' => [], 'err' => 'Pick your start piece first.'];
    if (!pfb_v1r($s, 'freepass')) foreach ($s['me']['hand'] as $i => $t) {   // 2.6.95: passing is free in a new fight
        if (pfb_cells($s, $t)) return ['ev' => [], 'err' => 'You still have a piece that fits somewhere.'];
        if (pfb_can_flip($s, $i)) { $ft = $t; if (!empty($ft['flip'])) unset($ft['flip']); else $ft['flip'] = true; if (pfb_cells($s, $ft)) return ['ev' => [], 'err' => 'You still have a piece that fits somewhere when you flip it.']; }   // v1
    }
    if (!pfb_v1r($s, 'freepass') && !empty($s['me']['held']) && pfb_group_spots($s, $s['me']['held'])) return ['ev' => [], 'err' => 'Your set-aside group still fits somewhere.'];
    $w = $s; $w['reshuf'] = []; $w['cut'] = 0; $w['spent'] = []; $w['lastfoe'] = []; $w['gone'] = []; pfb_begin($w, 'me');   // 2.6.95: a pass is a turn like a play: last round's news is not this turn's (as pfb_play, 2.6.88)
    if (!empty($w['v1'])) $w['envlog'] = [];
    $ev = pfb_foe_turn($w, 0); foreach ($ev as $i => $e0) $ev[$i]['ta'] = 'foe';
    $w['fx'] = pfb_fx($ev);
    $trip = !$w['over'] && !empty($w['v1']) && !empty($w['me']['slowdraw']);
    if (!$w['over']) pfb_end_round($w);
    if (!empty($w['v1'])) $ev = array_merge($ev, pfb_env_events($w));
    if ($trip && !$w['over']) { $tn = pfb_note('trip'); $tn['ta'] = $ev ? (string)(end($ev)['ta'] ?? 'foe') : 'foe'; $ev[] = $tn; }
    pfb_guard_notes($w, $ev);   // 2.6.77
    $s = $w;
    return ['ev' => $ev, 'err' => null];
}

/** What the client may see: the board is public; the draw pile and the foe's hand are not. Each piece carries its edges so the client can show where a piece fits. */
function pfb_view(array $s): array
{
    $v = pf_view($s);
    if (!empty($s['v1']['onebar'])) { $v['onebar'] = 1; $v['charmable'] = $s['cm'] > 0 && empty($s['boss']); }   // 2.6.95: one shared bar
    $v['start'] = !empty($s['start']); $v['mode'] = 'board'; $v['w'] = pfb_w($s); $v['h'] = pfb_h($s); $v['fx'] = $s['fx'] ?? [];
    $g = $s['me']['held'] ?? null;
    $v['held'] = $g ? ['pcs' => array_map(fn($p) => ['n' => $p['tile']['n'], 't' => $p['tile']['t'], 'v' => $p['tile']['v'], 'tag' => $p['tile']['tag'], 'm' => (string)($p['tile']['m'] ?? ''), 'e' => pfb_edges($p['tile']), 'x' => $p['x'], 'y' => $p['y']], $g['pcs']), 'spots' => pfb_group_spots($s, $g), 'link' => (bool)array_filter(pfb_group_cells_all($s, $g), fn($o) => $o[2])] : null;
    $v['pcs'] = array_values(array_map(fn($p) => ['id' => $p['id'], 'by' => $p['by'], 'x' => $p['x'], 'y' => $p['y'], 'n' => $p['tile']['n'], 't' => $p['tile']['t'], 'v' => $p['tile']['v'], 'tag' => $p['tile']['tag'], 'm' => (string)($p['tile']['m'] ?? ''), 'e' => pfb_edges($p['tile']), 'age' => $s['round'] - $p['born'], 'seq' => $p['seq'], 'fl' => pfb_fire_limit($p) > 0 ? max(0, pfb_fire_limit($p) - (int)($p['f'] ?? 0)) : null, 'spawn' => ($s['spawn'] ?? null) === $p['id'], 'fnew' => in_array($p['id'], $s['lastfoe'] ?? [], true)], $s['pcs']));
    $v['gone'] = array_map(fn($g) => ['id' => $g['id'], 'by' => $g['by'], 'x' => $g['x'], 'y' => $g['y'], 'n' => $g['tile']['n'], 't' => $g['tile']['t'], 'v' => $g['tile']['v'], 'tag' => $g['tile']['tag'], 'm' => (string)($g['tile']['m'] ?? ''), 'e' => pfb_edges($g['tile']), 'age' => $g['age'], 'fell' => !empty($g['fell'])] + ($g['by'] === 'env' ? ['kind' => (string)$g['tile']['env'], 'dir' => $g['tile']['dir'] ?? null] : []), $s['gone'] ?? []);   // 2.6.75: a piece of the environment that left: its kind (and Wind's arrow) for the page
    foreach ($v['hand'] as $i => $t) $v['hand'][$i]['e'] = pfb_edges($s['me']['hand'][$i]);
    unset($v['strip'], $v['open'], $v['open_t'], $v['open_v'], $v['open_by']);
    if (!empty($s['v1'])) {   // v1: everything the page needs for ground, events, the aim, use-up, Teamwork, flip and piece life
        $c = $s['v1'];
        $v['v1'] = ['limit' => (int)$c['limit'], 'sun' => $c['sun'], 'bramble' => $c['bramble'], 'br_foe' => $c['br_foe'], 'thorn' => $c['thorn'], 'ev_foe' => $c['ev_foe'], 'team2' => $c['team2'], 'team3' => $c['team3'],
            'env' => !empty($c['env']), 'envn' => (int)($c['envn'] ?? 0), 'rain' => (float)($c['rain'] ?? 0), 'th_foe' => (float)($c['th_foe'] ?? 1), 'mud' => (float)($c['mud'] ?? 0), 'envcap' => (float)($c['envcap'] ?? 1),
            'ground' => (bool)$c['ground'], 'events' => (bool)$c['events'], 'aim' => (bool)$c['aim'], 'flip' => (bool)$c['flip'], 'life' => (bool)$c['life'], 'edges' => (bool)$c['edges']];
        foreach (PFB_V1_PRE as $k => $d) $v['v1'][$k] = pfb_v1r($s, $k);   // the compat rules, resolved
        $v['round'] = (int)$s['round'];
        $v['ter'] = (object)($s['ter'] ?? []);   // "x,y" => 'sun' | 'br' | 'mud' (oldest first)
        $v['envs'] = array_map(fn($e) => $e + ['n' => PFB_EVENT_NAME[$e['kind']], 'on' => ($q = pfb_at($s, $e['x'], $e['y'])) && $q['by'] !== 'none' ? ['id' => $q['id'], 'by' => $q['by'], 'n' => $q['tile']['n']] : null], $s['envs'] ?? []);   // the forecast: lands after the creature's move
        $v['envlog'] = $s['envlog'] ?? [];   // what the last terrain turn did
        if (!empty($c['env'])) {   // 2.6.75: the environment's deck: its next pieces (face up a round ahead, a list; empty = all on the board), how many wait in its deck ('deck') and in its discard ('used'; shuffled back in when the deck is empty), how many it places a round
            $v['env'] = ['next' => array_map(fn($nx) => ['k' => $nx['k'], 'n' => $nx['n'], 'kind' => $nx['env'], 'life' => !empty($s['v1']['life']) ? (int)$nx['life'] : PFB_LIFE, 'e' => pfb_edges($nx)], $s['env']['next']), 'deck' => count($s['env']['draw']), 'used' => count($s['env']['discard']), 'n' => (int)$c['envn']];   // next: a LIST, in the order they will be placed
        }
        $v['aim'] = $s['foe']['plan'] ?? null;   // the creature's next piece and cell (null: it shows none, or it is tripped)
        if (pfb_kind($s) !== '') { $v['kind'] = pfb_kind($s); $v['grudge'] = (int)($s['foe']['grudge'] ?? 0); $v['ven'] = array_map(fn($k, $r) => ['x' => (int)explode(',', $k)[0], 'y' => (int)explode(',', $k)[1], 'r' => $r - 1], array_keys($s['ven'] ?? []), array_values($s['ven'] ?? [])); }   // 2.6.98 class rules
        if (!empty($s['foe']['aid'])) $v['ai'] = ['id' => $s['foe']['aid'], 'n' => PFB_AI[$s['foe']['aid']][12], 't' => PFB_AI[$s['foe']['aid']][13]];   // 2.7.01: its play style for the card
        if (!empty($s['foe']['ab'])) $v['abil'] = array_map(fn($id) => ['id' => $id, 'n' => PFB_ABIL[$id][4], 't' => PFB_ABIL[$id][5]], $s['foe']['ab']);   // 2.7.01: the creature's abilities for its card
        $v['reaim'] = !empty($s['reaim']);   // last turn it could not play its aim and picked again
        $v['flip'] = ['on' => (bool)$c['flip'], 'used' => (int)($s['me']['flipt'] ?? 0) === (int)$s['turn']];
        if (!empty($c['tags'])) $v['status'] = ['poison' => (int)$s['me']['poison'], 'poison_v' => (int)$s['me']['poison_v'], 'slowdraw' => (int)$s['me']['slowdraw'], 'evade' => (int)$s['me']['evade'],
            'foe_evade' => (int)$s['foe']['evade'], 'foe_thorns' => (bool)$s['foe']['thorns'], 'foe_bash' => (int)$s['foe']['bashnext'], 'foe_slow' => (int)$s['foe']['slow'], 'foe_poison' => (int)$s['foe']['poison']] + (pfb_v1r($s, 'aimtot') ? ['foe_block' => (int)$s['foe']['block']] : []);   // 2.6.74: what is waiting on each side (creature tags)
        $v['wear'] = (object)($s['wear'] ?? []);   // tool type => durability its piece has cost so far this fight
        foreach ($v['pcs'] as $i => $q) {
            $p = $s['pcs'][$q['id']]; $life = pfb_life($s, $p);
            $v['pcs'][$i] += ['life' => $life, 'left' => $p['born'] + $life - (int)$s['round'], 'src' => (string)($p['tile']['src'] ?? ''), 'flip' => !empty($p['tile']['flip']), 'ter' => pfb_ter($s, $p['x'], $p['y']), 'rank' => (int)($p['tile']['rank'] ?? 0), 'layer' => (string)($p['tile']['layer'] ?? '')];   // left: rounds it still stays, this one included (1 = it goes at the end of this round)
            if ($p['by'] === 'env') $v['pcs'][$i] += ['kind' => (string)$p['tile']['env'], 'dir' => $p['tile']['dir'] ?? null];   // 2.6.75: an environment piece: its kind, Wind's arrow
        }
        foreach ($v['hand'] as $i => $t) { $ht = $s['me']['hand'][$i]; $v['hand'][$i] += ['life' => (int)($ht['life'] ?? PFB_LIFE), 'src' => (string)($ht['src'] ?? ''), 'flip' => !empty($ht['flip']), 'canflip' => pfb_can_flip($s, $i), 'rank' => (int)($ht['rank'] ?? 0), 'tool' => (string)($ht['tool'] ?? '')]; if (!empty($ht['fx'])) $v['hand'][$i]['fx'] = pfb_wx_text((string)$ht['fx'], (int)($ht['fxa'] ?? 0), (int)($ht['fxb'] ?? 0)); }   // 2.7.09: a wear piece's effect sentence
        foreach ($v['pcs'] as $i => $q) { $pt = $s['pcs'][$q['id']]['tile']; if (!empty($pt['fx'])) $v['pcs'][$i]['fx'] = pfb_wx_text((string)$pt['fx'], (int)($pt['fxa'] ?? 0), (int)($pt['fxb'] ?? 0)); }
        if ($v['held']) foreach ($v['held']['pcs'] as $i => $q) { $ht = $g['pcs'][$i]['tile']; $v['held']['pcs'][$i] += ['life' => (int)($ht['life'] ?? PFB_LIFE), 'src' => (string)($ht['src'] ?? ''), 'flip' => !empty($ht['flip'])]; }
        foreach ($v['gone'] as $i => $q) if (isset($s['gone'][$i]['used'])) $v['gone'][$i]['used'] = $s['gone'][$i]['used'];
    }
    return $v;
}
