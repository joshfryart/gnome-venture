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
const PFB_SIZE = ['small' => [5, 4], 'medium' => [5, 5], 'large' => [7, 5], 'boss' => [7, 6]];   // the board (w, h) by creature size (the old rules: PFB_W x PFB_H for all)
const PFB_GROUND = ['small' => [2, 2, 1], 'medium' => [3, 2, 1], 'large' => [3, 3, 1], 'boss' => [4, 3, 1]];   // ground cells at the start: sunny, bramble, mud
const PFB_GROUND_DIST = [1, 2];               // ground cells lie this many steps from the centre (min, max)
const PFB_EVENTS = ['small' => 1, 'medium' => 2, 'large' => 2, 'boss' => 2];   // forecast events a round
const PFB_EVENT_KINDS = ['sunbeam', 'creep', 'gust', 'thorn', 'puddle'];   // drawn evenly
const PFB_EVENT_NAME = ['sunbeam' => 'Sunbeam', 'creep' => 'Bramble creep', 'puddle' => 'Puddle', 'gust' => 'Gust', 'thorn' => 'Thorn burst', 'bramble' => 'Bramble', 'poison' => 'Poison', 'place' => 'Environment', 'pass' => 'Environment', 'expire' => 'Environment'];
const PFB_USEUP = 3;                          // a chain that fires this many pieces or more uses up every piece that fired (both sides; 0 = off)
const PFB_SUN_MULT = 2.0;                     // a Hurt or Charm piece on a sunny cell counts this much
const PFB_BRAMBLE = 0.10, PFB_BRAMBLE_FOE = 1.0;   // bramble: share of max health a piece on it costs its owner each terrain turn (x PFB_BRAMBLE_FOE for a creature piece)
const PFB_THORN = 0.10, PFB_EVENT_FOE = 0.5;  // thorn burst: share of max health per piece in the zone; event damage on the creature is halved
const PFB_TEAM2 = 1.3, PFB_TEAM3 = 1.6;       // Teamwork: your pieces in a chain you start come from 2 / 3 of the sources pal, tool, crop
const PFB_TEAM_SRC = ['pal', 'tool', 'crop'];
const PFB_SRC = ['basic', 'knack', 'calling', 'tool', 'crop', 'craft', 'pal', 'region', 'creature', 'env'];   // where a piece comes from (tile field 'src')
const PFB_SRC_FAM = ['pal' => 'body', 'tool' => 'craft', 'crop' => 'mind', 'craft' => 'craft'];   // authored edges: the column family (top and bottom) of a sourced piece; other pieces use their type family
const PFB_UP = ['hurt' => 1, 'charm' => 1, 'trick' => 1];   // these types carry the column knob on top and the hole below; guard, heal, soothe and item the other way round
const PFB_CLASS_LEAN = ['critter' => 'mind', 'insect' => 'mind', 'water' => 'body', 'bird' => 'craft', 'plant' => 'mind', 'fungus' => 'mind', 'reptile' => 'craft', 'amphibian' => 'craft', 'beast' => 'body'];   // a creature class leans to a family: 3 of its pieces in 5 stack in it
const PFB_LIFE_MIN = 2, PFB_LIFE_MAX = 4;     // per-piece life in rounds (tile field 'life'; default PFB_LIFE, Quick pieces 2, Hold pieces 4)
const PFB_TOOL_WEAR = 2;                      // 2.6.74 (deck model): a fight tool loses this much durability each time ITS piece is played (tile field 'tool'; counted in $s['wear'], saved at the end of the fight)
// 2.6.75 ENVIRONMENT PIECES (Josh, after testing 2.6.74): no ground cells and no forecast marks. The environment is a third player: after the creature's turn it puts ONE piece from its own deck
// on the board (data/pf_env.txt), and its next piece lies face up a round ahead. Its pieces link and fire in chains like any piece; the effect goes to the side whose chain fires it.
// A v1 fight started under 2.6.74 has no $s['v1']['env'] and keeps its ground and events to the end.
const PFB_ENV_KINDS = ['sun', 'bramble', 'rain', 'wind', 'mud', 'thorn'];
const PFB_ENV_N = ['small' => 1, 'medium' => 1, 'large' => 1, 'boss' => 1];   // pieces the environment places a round
const PFB_RAIN = 0.15;                        // Rain: guard for the side that fires it, a share of its maximum (your health, the creature's bar)
const PFB_THORN_FOE = 1.0;                    // Thornburst fired by the creature: x this (both sides choose to fire it, so it is not halved like the old thorn burst event)
const PFB_ENV_EDGE = ['h' => 'hole', 'k' => 'knob', 'b' => 'body', 'm' => 'mind', 'c' => 'craft'];
const PFB_V1_FOE_MULT = ['small' => 0.76, 'medium' => 0.56, 'large' => 0.42, 'boss' => 0.53];   // the creature's piece values by size (replaces PFB_FOE_MULT 0.62; boss, blank and fire-budget factors still apply). Stage B retune (2.6.74) with the layered creature decks, creature tags and deck-model decks: tests/pfboard_tune_v1.php, chain bot about 70% at level. Stage A (archetype decks) had 0.72 / 0.54 / 0.56 / 0.62 and bars 1.12 / 1.12 / 1.12 / 0.88. The design demo's JS sim (9 creatures) had 0.72 / 0.53 / 0.41 / 0.46
const PFB_V1_BAR_MULT = ['small' => 1.0, 'medium' => 1.3, 'large' => 1.6, 'boss' => 1.0];   // the creature's bars by size (replaces PFB_BAR_MULT): longer fights

/** The rule numbers of a v1 fight for a creature size; $over replaces single values (tests and sims: ['events' => 0] switches a rule off, 'foe_x' / 'bar_x' scale the creature). */
function pfb_v1_cfg(string $size, array $over = []): array
{
    if (!isset(PFB_SIZE[$size])) $size = 'medium';
    $g = PFB_GROUND[$size];
    $cfg = ['w' => PFB_SIZE[$size][0], 'h' => PFB_SIZE[$size][1], 'ground' => 0, 'nsun' => $g[0], 'nbr' => $g[1], 'nmud' => $g[2], 'sun' => PFB_SUN_MULT, 'bramble' => PFB_BRAMBLE, 'br_foe' => PFB_BRAMBLE_FOE,
        'events' => 0, 'nev' => PFB_EVENTS[$size], 'thorn' => PFB_THORN, 'ev_foe' => PFB_EVENT_FOE, 'limit' => PFB_USEUP, 'aim' => 1, 'team2' => PFB_TEAM2, 'team3' => PFB_TEAM3,
        'edges' => 1, 'flip' => 1, 'life' => 1, 'tags' => 1, 'foe' => PFB_V1_FOE_MULT[$size], 'bar' => PFB_V1_BAR_MULT[$size],
        'env' => 1, 'envn' => PFB_ENV_N[$size], 'rain' => PFB_RAIN, 'th_foe' => PFB_THORN_FOE];   // 2.6.75: environment pieces (env); 'env' => 0 with 'ground' => 1, 'events' => 1 gives the 2.6.74 terrain
    foreach ($over as $k => $v) if (array_key_exists($k, $cfg) && is_numeric($v)) $cfg[$k] = is_int($cfg[$k]) ? (int)$v : (float)$v;
    if (isset($over['foe_x'])) $cfg['foe'] = round($cfg['foe'] * (float)$over['foe_x'], 4);
    if (isset($over['bar_x'])) $cfg['bar'] = round($cfg['bar'] * (float)$over['bar_x'], 4);
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
function pfb_env_deck(string $size, string $region = ''): array
{
    if (!isset(PFB_SIZE[$size])) $size = 'medium';
    $T = pfb_env_table(); $bias = $T['regions'][$region] ?? []; $deck = [];
    foreach ($T['pieces'] as $p) {
        $n = max(0, (int)$p['w'][$size] + (int)($bias[$p['env']] ?? 0));
        for ($i = 0; $i < $n; $i++) $deck[] = ['k' => $p['k'], 'n' => $p['n'], 't' => 'env', 'v' => 0, 'r' => null, 'tag' => '', 'm' => '', 'src' => 'env', 'env' => $p['env'], 'life' => $p['life'], 'ed' => $p['ed']];
    }
    return $deck;
}

/** The environment turns its next piece face up (its discard is shuffled back in when the deck is empty; null when every piece is on the board). */
function pfb_env_draw(array &$s): void
{
    if (!$s['env']['draw'] && $s['env']['discard']) { $s['env']['draw'] = pf_shuffle($s, $s['env']['discard']); $s['env']['discard'] = []; }
    $s['env']['next'] = $s['env']['draw'] ? array_pop($s['env']['draw']) : null;
}

/** Where the environment may put a piece: every free cell where its edges fit a neighbour; when some of those link (knob in a matching hole), only those. */
function pfb_env_cells(array $s, array $tile): array
{
    $fit = []; $link = [];
    for ($y = 0; $y < pfb_h($s); $y++) for ($x = 0; $x < pfb_w($s); $x++) { $j = pfb_check($s, $tile, $x, $y); if ($j === null) continue; $fit[] = [$x, $y]; if (pfb_has_link($j)) $link[] = [$x, $y]; }
    return $link ?: $fit;
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
 * The ENVIRONMENT'S TURN (after the creature's): it puts its face-up piece on the board, on a cell drawn from pfb_env_cells, and turns the next one face up. Nothing fires.
 * No cell fits: it passes and keeps the piece. The piece's life starts with the next round (born = this round + 1), so "2 rounds" are two of your turns. $s['envlog'] gets one note per piece.
 */
function pfb_env_place(array &$s): void
{
    $s['envlog'] = [];
    for ($i = 0; $i < (int)$s['v1']['envn']; $i++) {
        $tile = $s['env']['next'] ?? null;
        if (!$tile) { $s['envlog'][] = ['k' => 'pass', 'x' => null, 'y' => null, 'me' => 0, 'foe' => 0.0]; break; }
        $cells = pfb_env_cells($s, $tile);
        if (!$cells) { $s['envlog'][] = ['k' => 'pass', 'x' => null, 'y' => null, 'me' => 0, 'foe' => 0.0, 'kind' => $tile['env'], 'n' => $tile['n']]; break; }
        [$x, $y] = $cells[pf_rand($s, count($cells))];
        if ($tile['env'] === 'wind') $tile['dir'] = pfb_env_wind_dir($s, $x, $y);
        $id = ++$s['pid']; $s['seq']++;
        $s['pcs'][$id] = ['id' => $id, 'by' => 'env', 'tile' => $tile, 'x' => $x, 'y' => $y, 'born' => $s['round'] + 1, 'seq' => $s['seq']];
        $s['cell']["$x,$y"] = $id;
        $L = ['k' => 'place', 'x' => $x, 'y' => $y, 'me' => 0, 'foe' => 0.0, 'id' => $id, 'kind' => $tile['env'], 'n' => $tile['n']];
        if (isset($tile['dir'])) $L['dir'] = $tile['dir'];
        $s['envlog'][] = $L;
        pfb_env_draw($s);
    }
}

/** An environment piece's effect costs a side a share of its maximum (your health, the creature's bar; guard does not help). Returns what it cost. */
function pfb_env_cost(array &$s, string $who, float $frac): float
{
    if ($frac <= 0) return 0.0;
    if ($who === 'me') { $d = max(1, (int)round($frac * $s['me']['max'])); $s['me']['hp'] = max(0, $s['me']['hp'] - $d); return (float)$d; }
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
    elseif ($kind === 'rain') { $g = max(1, (int)round((float)$v1['rain'] * ($rb === 'me' ? $s['me']['max'] : $s['fh']['max']))); $s[$rb]['block'] += $g; $e['guard'] = $g; $e['v'] = $g; }
    elseif ($kind === 'wind') {   // the piece next to it on the arrow's side slides one cell further along the arrow, if that cell is on the board and free (the blank never moves)
        $d = (string)($t['dir'] ?? 'R'); [$dx, $dy] = PFB_SIDE[$d]; $e['dir'] = $d;
        $x = $p['x'] + $dx; $y = $p['y'] + $dy; $nx = $x + $dx; $ny = $y + $dy; $q = pfb_at($s, $x, $y);
        if ($q && $q['by'] !== 'none' && $nx >= 0 && $ny >= 0 && $nx < pfb_w($s) && $ny < pfb_h($s) && !isset($s['cell']["$nx,$ny"])) {
            unset($s['cell']["$x,$y"]); $s['cell']["$nx,$ny"] = $q['id']; $s['pcs'][$q['id']]['x'] = $nx; $s['pcs'][$q['id']]['y'] = $ny;
            $e['moved'] = ['id' => $q['id'], 'by' => $q['by'], 'n' => $q['tile']['n'], 'x' => $nx, 'y' => $ny];
        }
    }
    $e['me'] = (int)$e['me']; $e['foe'] = round((float)$e['foe'], 1);
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
    return !empty($s['v1']['life']) ? (int)($p['tile']['life'] ?? PFB_LIFE) : PFB_LIFE;
}

/** A piece's tile goes back to its owner's discard (a flipped piece comes back the right way up). */
function pfb_discard(array &$s, array $p): void
{
    if ($p['by'] === 'none') return;
    $t = $p['tile']; unset($t['flip'], $t['ft'], $t['dir']);
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
function pfb_ground_set(array &$s, int $x, int $y, string $kind): void
{
    unset($s['ter']["$x,$y"]); $s['ter']["$x,$y"] = $kind;
    $cap = max(1, (int)$s['v1'][['sun' => 'nsun', 'br' => 'nbr', 'mud' => 'nmud'][$kind]]); $have = array_keys($s['ter'], $kind, true);
    while (count($have) > $cap) unset($s['ter'][array_shift($have)]);
}

/** The terrain hurts the owner of a piece, a share of the maximum (guard does not help). Returns what it cost: health points for you, bar points for the creature ($tag 'thorn' is halved on the creature). */
function pfb_env_hurt(array &$s, string $who, float $frac, string $tag): float
{
    if ($frac <= 0) return 0.0;
    if ($who === 'me') { $d = max(1, (int)round($frac * $s['me']['max'])); $s['me']['hp'] = max(0, $s['me']['hp'] - $d); return (float)$d; }
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
            pfb_ground_set($s, $e['x'], $e['y'], ['sunbeam' => 'sun', 'creep' => 'br', 'puddle' => 'mud'][$e['kind']]);
            if ($ob) $L['on'] = ['id' => $on['id'], 'by' => $ob, 'n' => $on['tile']['n']];
        }
        $L['me'] = (int)$L['me']; $L['foe'] = round($L['foe'], 1);
        $s['envlog'][] = $L;
    }
    if ($s['v1']['ground']) {
        $B = ['k' => 'bramble', 'x' => null, 'y' => null, 'me' => 0, 'foe' => 0.0, 'ids' => []];
        foreach ($s['pcs'] as $p) if ($p['by'] !== 'none' && pfb_ter($s, $p['x'], $p['y']) === 'br') { $B[$p['by']] += pfb_env_hurt($s, $p['by'], (float)$s['v1']['bramble'], 'br'); $B['ids'][] = $p['id']; }
        $B['me'] = (int)$B['me']; $B['foe'] = round($B['foe'], 1);
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
        foreach (['dir', 'moved', 'on', 'ids', 'id', 'kind'] as $k) if (isset($L[$k])) $e[$k] = $L[$k];
        if (isset($L['n'])) $e['n'] = $L['n'];   // 2.6.75: an environment piece placed (or kept back): its name
        $e['barnow'] = round((float)$s['bar']['now'], 1); $e['fhnow'] = round((float)$s['fh']['now'], 1); $e['hpnow'] = (int)$s['me']['hp']; $e['gnow'] = (int)$s['me']['block'];
        $ev[] = $e;
    }
    return $ev;
}

/** One line of text for a terrain event (the fight log). */
function pfb_env_line(array $e, string $foe): string
{
    $cost = [];
    if (!empty($e['me'])) $cost[] = 'you lose ' . (int)$e['me'] . ' health';
    if (!empty($e['foe'])) $cost[] = 'the ' . $foe . ' loses ' . (int)round((float)$e['foe']);
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
        case 'pass': return isset($e['kind']) ? '🍃 The environment finds no place for ' . (string)$e['n'] . '.' : '🍃 The environment has no piece to place.';
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

/** May the hand piece be flipped now? One flip a turn; the piece flipped this turn may be flipped back (that gives the flip back). Only authored edges flip. */
function pfb_can_flip(array $s, int $handIdx): bool
{
    $t = $s['me']['hand'][$handIdx] ?? null;
    if (empty($s['v1']['flip']) || $s['over'] || !$t || !isset($t['ed'])) return false;
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
    if ((int)($t['ft'] ?? 0) === (int)$s['turn']) { unset($t['ft']); $s['me']['flipt'] = 0; }   // flipped back: the flip is free again
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
    if (!$s['pcs']) return false;
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

/** Fire a chain. Events like the strip engine's, plus 'id' and 'root'. */
function pfb_fire(array &$s, int $root): array
{
    $ev = [];
    $chain = pfb_chain($s, $root);
    $v1 = $s['v1'] ?? null; $rb = $s['pcs'][$root]['by']; $tw = 1.0;
    if ($v1) {   // v1: what fired (for use-up) and Teamwork: the starter's pieces in this chain come from 2 or 3 of the sources pal, tool, crop
        $s['fired'] = []; $s['firedby'] = $rb; $srcs = [];
        foreach ($chain as [$cid]) { $cp = $s['pcs'][$cid]; if ($cp['by'] === $rb && in_array($cp['tile']['src'] ?? '', PFB_TEAM_SRC, true)) $srcs[$cp['tile']['src']] = 1; }
        if ($rb === 'me' && count($srcs) >= 3) $tw = (float)$v1['team3']; elseif ($rb === 'me' && count($srcs) === 2) $tw = (float)$v1['team2'];
    }
    $esun = 1.0;   // 2.6.75: a Sun piece in the chain: every piece of the side that started the chain counts x sun in it (once, however many Suns)
    if ($v1 && !empty($v1['env'])) foreach ($chain as [$cid]) if ($s['pcs'][$cid]['by'] === 'env' && $s['pcs'][$cid]['tile']['env'] === 'sun') $esun = (float)$v1['sun'];
    foreach ($chain as $ci => [$id, $par]) {
        if ($s['over']) { $s['cut'] = ($s['cut'] ?? 0) + count($chain) - $ci; break; }   // the fight ended mid-chain: how many linked pieces did not fire (for the harness and replay)
        $p = $s['pcs'][$id]; $who = $p['by']; $tile = $p['tile'];
        if ($who === 'none') continue;   // the blank centre piece does nothing itself; the chain runs through it
        if ($who === 'env') {   // 2.6.75: an environment piece: its effect goes to the side whose chain this is; it counts for the chain's length and is used up like any piece
            $e = pfb_env_fire($s, $p, $rb); $s['fired'][] = $id;
            $s['pcs'][$id]['f'] = (int)($s['pcs'][$id]['f'] ?? 0) + 1;
            $e['barnow'] = round((float)$s['bar']['now'], 1); $e['fhnow'] = round((float)$s['fh']['now'], 1); $e['hpnow'] = (int)$s['me']['hp']; $e['gnow'] = (int)$s['me']['block'];
            $ev[] = $e; pf_check_end($s); continue;
        }
        $pt = $par !== null ? $s['pcs'][$par] : null;
        if ($pt && ($pt['by'] === 'none' || $pt['by'] === 'env')) $pt = null;   // and a piece after it (or after an environment piece) has no combo parent
        [$val, , $ck] = pf_value($pt['tile'] ?? null, $tile, $pt !== null && $pt['by'] === $who, false);   // combos only off your own piece; no fit bonus (every link fits)
        $val = (int)round($val * (float)($p['cm'] ?? 1.0));   // a placed 3-piece group plays for more
        $sunny = $v1 && in_array($tile['t'], ['hurt', 'charm'], true) && pfb_ter($s, $p['x'], $p['y']) === 'sun';
        if ($sunny) $val = (int)round($val * (float)$v1['sun']);
        if ($esun > 1 && $who === $rb) { $val = (int)round($val * $esun); $sunny = true; }
        if ($tw > 1 && $who === $rb) $val = (int)round($val * $tw);
        if ($v1) $s['fired'][] = $id;
        $isRoot = $id === $root;
        $e = ['by' => $who, 'id' => $id, 'root' => $isRoot, 'tag' => $tile['tag'], 'mod' => (string)($tile['m'] ?? ''), 'k' => $tile['k'], 'n' => $tile['n'], 't' => $tile['t'], 'v' => $val, 'fit' => false, 'combo' => $ck ? PF_COMBOS[$ck]['name'] : null];
        if ($sunny) $e['sun'] = 1;
        if ($tw > 1 && $who === $rb) $e['tw'] = $tw;
        pf_apply($s, $who, $tile, $val, $isRoot && pfb_links($s, $id) !== [], $ck, $pt['tile'] ?? null, $pt['by'] ?? null, $e, $isRoot, false);
        $s['pcs'][$id]['f'] = (int)($s['pcs'][$id]['f'] ?? 0) + 1;   // fire budget: one more firing used (the placement counts as the first)
        $e['barnow'] = round((float)$s['bar']['now'], 1); $e['fhnow'] = round((float)$s['fh']['now'], 1); $e['hpnow'] = (int)$s['me']['hp']; $e['gnow'] = (int)$s['me']['block'];   // for the replay: how the bar and health stand after this piece
        $ev[] = $e;
        pf_check_end($s);
    }
    return $ev;
}

/** How many times may this piece fire before it falls away? 0 = no limit (your pieces, the blank, and everything when PFB_FOE_FIRES is 0). */
function pfb_fire_limit(array $p): int
{
    return $p['by'] === 'foe' ? max(0, PFB_FOE_FIRES) : 0;
}

/** A piece leaving the board, as the replay and the page want it. */
function pfb_gone_entry(array $s, array $p, bool $fell): array
{
    $e = ['id' => $p['id'], 'by' => $p['by'], 'x' => $p['x'], 'y' => $p['y'], 'tile' => $p['tile'], 'age' => $s['round'] - 1 - $p['born']];
    if ($fell) $e['fell'] = true;
    if (isset($p['used'])) $e['used'] = $p['used'];   // v1: used up by a chain of 3+ (whose chain it was)
    return $e;
}

/** Fire budget: after a chain has finished, creature pieces that have fired their limit fall away (to their discard). Never mid-chain, so a chain keeps its shape. Returns nothing; $s['spent'] lists them for the replay. */
function pfb_spend(array &$s): array
{
    $fired = $s['fired'] ?? []; $by = $s['firedby'] ?? 'me'; unset($s['fired'], $s['firedby']); $used = [];
    if ($s['over']) return $used;
    $lim3 = (int)($s['v1']['limit'] ?? 0);
    if ($lim3 > 0 && count($fired) >= $lim3) {   // v1 USE-UP: a chain of 3 or more uses up every piece that fired, whoever started it and whoever owns them
        foreach ($fired as $id) {
            if (!isset($s['pcs'][$id])) continue; $p = $s['pcs'][$id];
            pfb_discard($s, $p); $p['used'] = $by; $s['spent'][] = $p; $used[] = $id;
            unset($s['cell'][$p['x'] . ',' . $p['y']], $s['pcs'][$id]);
        }
    }
    foreach ($s['pcs'] as $id => $p) {
        $lim = pfb_fire_limit($p);
        if ($lim > 0 && (int)($p['f'] ?? 0) >= $lim) {
            pfb_discard($s, $p); $s['spent'][] = $p;
            unset($s['cell'][$p['x'] . ',' . $p['y']], $s['pcs'][$id]);
        }
    }
    return $used;
}

/** The start of a side's turn: its guard from last turn is spent (a Hold guard carries over once). */
function pfb_begin(array &$s, string $who): void
{
    if ($who === 'me') return;   // your guard is reset when your turn starts (pfb_end_round), so it stays up through the creature's turn
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
    $joints = pfb_check_after($s, $id);
    $ev = pfb_fire($s, $id);
    if ($ev) { $ev[0]['linked'] = $joints; $ev[0]['snap'] = pfb_snap($s); }   // linked: how many linked joints the new piece made; snap: the board for the history rewind
    $used = pfb_spend($s);
    if ($used && $ev) $ev[0]['used'] = $used;   // v1: the ids this chain used up
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
    if ($ev) { $ev[0]['linked'] = pfb_check_after($s, $root); $ev[0]['snap'] = pfb_snap($s); }
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
function pfb_expire(array &$s): array
{
    $gone = [];
    foreach ($s['pcs'] as $id => $p) if ($p['born'] <= $s['round'] - pfb_life($s, $p) + 1) {
        pfb_discard($s, $p);
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

function pfb_score(array $b, array $a, string $who): float
{
    $barD = ($a['bar']['now'] - $b['bar']['now']) + ($a['fh']['now'] - $b['fh']['now']);   // charm and damage both move the creature toward losing
    $hpD = $a['me']['hp'] - $b['me']['hp'];
    $tg = 0.0;
    if (!empty($a['v1']['tags'])) {   // creature tags: what the lasting effects are worth to the creature (poison waiting on you, a tripped draw, its evade, thorns, a lent guard, one more piece)
        $u = 0.05 * $a['me']['max']; $pz = fn(array $z) => (int)($z['me']['poison'] ?? 0) * (int)($z['me']['poison_v'] ?? 0);
        $tg = ($pz($a) - $pz($b)) + $u * (1.0 * ((int)($a['me']['slowdraw'] ?? 0) - (int)($b['me']['slowdraw'] ?? 0)) + 1.5 * ((int)$a['foe']['evade'] - (int)$b['foe']['evade']) + 0.6 * ((int)$a['foe']['thorns'] - (int)$b['foe']['thorns'])
            + 1.0 * ((int)($a['foe']['bashnext'] ?? 0) - (int)($b['foe']['bashnext'] ?? 0)) + 1.5 * ((int)($a['foe']['again'] ?? 0) - (int)($b['foe']['again'] ?? 0)));
    }
    if ($who === 'me') return -0.7 * $tg + $barD + 0.7 * $hpD + 0.3 * ($a['me']['block'] - $b['me']['block']) - 0.3 * ($a['foe']['block'] - $b['foe']['block']) + ($a['over'] && in_array($a['over'], ['seen_off', 'charmed'], true) ? 50 : 0);
    return $tg - 0.8 * $barD - $hpD + 0.4 * ($a['foe']['block'] - $b['foe']['block']) - 0.3 * ($a['me']['block'] - $b['me']['block']) + ($a['over'] === 'defeat' ? 50 : 0);
}

/** The best single placement for $who by trying every tile in every legal cell on a copy. [handIdx, x, y, score] or null. Ties: first found (deterministic). */
function pfb_search(array $s, string $who, bool $allowHeavy = true): ?array
{
    $best = null;
    foreach ($s[$who]['hand'] as $i => $tile) {
        if (!$allowHeavy && $tile['tag'] === 'heavy' && ($tile['m'] ?? '') !== 'steady') continue;
        foreach (pfb_cells($s, $tile, $who) as [$x, $y]) {
            $w = $s;
            if (pfb_place($w, $who, $i, $x, $y) === null) continue;
            $sc = pfb_score($s, $w, $who);
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

function pfb_foe_turn(array &$s, int $extra): array
{
    $ev = [];
    pfb_begin($s, 'foe');
    if ($s['foe']['poison'] > 0) {   // Sting: the poison works on the creature before it acts
        $add = $s['foe']['poison_v'] * $s['hm'];
        $s['fh']['now'] += $add; $s['foe']['poison']--;
        if ($s['foe']['poison'] === 0) $s['foe']['poison_v'] = 0;
        $ev[] = ['by' => 'me', 'tag' => 'poison', 'k' => 'poison', 'n' => 'Poison', 't' => 'hurt', 'v' => (int)round($add), 'fit' => false, 'combo' => null, 'tick' => true];
        if (pf_check_end($s)) return $ev;
    }
    $n = pfb_foe_len($s); $s['lastfoe'] = []; $again = false;
    if (!empty($s['v1']['tags'])) $s['foe']['again'] = 0;
    if (!empty($s['v1'])) $s['reaim'] = 0;   // the pieces it puts down this turn (the page holds only these back until the replay reaches them)
    for ($k = 0; $k < $n && !$s['over']; $k++) {
        $r = null; $plan = !empty($s['v1']['aim']) && $k === 0 ? ($s['foe']['plan'] ?? null) : null;
        if ($plan) { foreach ($s['foe']['hand'] as $hi => $ht) if ($ht['k'] === $plan['k']) { $s['aimforce'] = true; $r = pfb_place($s, 'foe', $hi, $plan['x'], $plan['y']); unset($s['aimforce']); break; } }   // v1 AIM: it plays the piece and the cell it showed
        if ($r === null) {   // no aim, or its cell is taken (or its piece is gone): it picks again at full value (no fumble)
            if ($plan) $s['reaim'] = 1;
            $m = pfb_search($s, 'foe');
            if ($m === null) break;
            $r = pfb_place($s, 'foe', $m[0], $m[1], $m[2]);
        }
        if ($r) { $ev = array_merge($ev, $r); $s['lastfoe'][] = $s['pid']; }
        if (!empty($s['foe']['again'])) { if (!$again) { $again = true; $n++; } $s['foe']['again'] = 0; }   // a Quick piece it placed: one more piece this turn (once)
    }
    $s['foe']['agg'] = 0; $s['foe']['slow'] = 0;
    return $ev;
}

// ---------------------------------------------------------------- the whole fight

/** Start a board fight: pf_new's hands and bar, then one or two of the creature's gentlest pieces go out (nothing fires for them). */
function pfb_new(array $me, array $c, int $seed, array $opt = []): array
{
    $s = pf_new($me, $c, $seed, $opt);
    $v1 = !empty($opt['v1']) ? pfb_v1_cfg($s['size'], is_array($opt['v1']) ? $opt['v1'] : []) : null;   // v1 rules (admin setting pfight_v1): this fight's rule numbers, kept in the state
    $fm = ($v1 ? $v1['foe'] : PFB_FOE_MULT) * ($s['size'] === 'boss' ? PFB_BOSS_MULT : 1.0) * (!empty($opt['blank']) ? PFB_BLANK_FOE_MULT : 1.0) * (PFB_FOE_FIRES > 0 ? PFB_FOE_FIRE_MULT : 1.0);
    foreach (['hand', 'draw', 'discard'] as $z) foreach ($s['foe'][$z] as $i => $t) $s['foe'][$z][$i]['v'] = max(1, (int)round($t['v'] * $fm));
    $s['bar']['max'] = round($s['bar']['max'] * ($v1 ? $v1['bar'] : PFB_BAR_MULT), 1); $s['fh']['max'] = $s['bar']['max'];
    $s['mode'] = 'board'; $s['strip'] = []; $s['pcs'] = []; $s['cell'] = []; $s['pid'] = 0; $s['seq'] = 0; $s['round'] = 1;
    if ($v1) {
        $s['w'] = $v1['w']; $s['h'] = $v1['h']; unset($v1['w'], $v1['h']); $s['v1'] = $v1;
        pfb_v1_tiles($s, $c); pfb_seed_ground($s); $s['envs'] = []; $s['envlog'] = []; $s['reaim'] = 0; $s['me']['flipt'] = 0;
        if ($v1['env']) { $s['env'] = ['draw' => pf_shuffle($s, pfb_env_deck($s['size'], (string)($c['region'] ?? ''))), 'discard' => [], 'next' => null]; pfb_env_draw($s); }   // 2.6.75: the environment's deck; its next piece lies face up
        if ($v1['tags']) { $s['me']['poison'] = 0; $s['me']['poison_v'] = 0; $s['me']['slowdraw'] = 0; $s['foe']['bashnext'] = 0; $s['foe']['again'] = 0; }
    }
    if (!empty($opt['blank'])) {   // variant: a blank wild piece in the centre; both sides put a start piece next to it, hidden (see pfb_start)
        $s['pid'] = 1; $s['seq'] = 1; $cx = intdiv(pfb_w($s), 2); $cy = intdiv(pfb_h($s), 2);
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
    $cx = intdiv(pfb_w($s), 2); $cy = intdiv(pfb_h($s), 2);
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
    $m = pfb_search($s, 'foe');
    $s['foe']['intent'] = $m ? $s['foe']['hand'][$m[0]]['t'] : null;
    if (!empty($s['v1']['aim'])) { $h = $m ? $s['foe']['hand'][$m[0]] : null; $s['foe']['plan'] = $h && pfb_foe_len($s) > 0 ? ['k' => $h['k'], 'n' => $h['n'], 't' => $h['t'], 'v' => $h['v'], 'tag' => $h['tag'], 'x' => $m[1], 'y' => $m[2]] : null; }   // v1 AIM: the piece and the cell of its next move, shown to the player and committed
}

/**
 * The player's turn: ONE action. $moves holds one entry:
 *   [handIdx, x, y]        place a hand piece at (x,y)
 *   ['c', x, y]            place the set-aside group with its top-left at (x,y)
 *   ['j', a, b, side]      set aside two hand pieces joined: b on the `side` of a (no effect this turn)
 *   ['h', b, anc, side]    add hand piece b to the set-aside group, onto group piece anc's `side`
 * Returns ['ev' => events, 'err' => ?string]; on an error nothing changed. $dry = true: report what a place would do (a copy; no creature turn).
 */
function pfb_play(array &$s, array $moves, int $turn, ?callable $canPlay = null, bool $dry = false): array
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
        if (empty($w['me']['held'])) return ['ev' => [], 'err' => 'You have no group set aside.'];
        if ($canPlay) foreach ($w['me']['held']['pcs'] as $gp) if (($why = $canPlay($gp['tile'])) !== null) return ['ev' => [], 'err' => $why];
        $r = pfb_place_group($w, 'me', $mv[1], $mv[2]);
        if ($r === null) return ['ev' => [], 'err' => 'The group does not fit there.'];
        $ev = $r;
    } elseif ($mv[0] === 'j' || $mv[0] === 'h') {
        if ($mv[0] === 'j') { if (count($mv) !== 4 || !is_int($mv[1]) || !is_int($mv[2]) || !is_string($mv[3])) return $bad; $err = pfb_connect($w, 'me', $mv[1], $mv[2], $mv[3]); }
        else { if (count($mv) !== 4 || !is_int($mv[1]) || !is_int($mv[2]) || !is_string($mv[3])) return $bad; $err = pfb_connect($w, 'me', null, $mv[1], $mv[3], $mv[2]); }
        if ($err) return ['ev' => [], 'err' => $err];
        $newest = $mv[0] === 'j' ? $w['me']['held']['pcs'][1]['tile'] : end($w['me']['held']['pcs'])['tile'];   // the piece just set aside
        $gd = (int)ceil((int)$newest['v'] * PFB_SETASIDE_GUARD); $w['me']['block'] += $gd;
        $names = array_map(fn($gp) => (string)$gp['tile']['n'], $w['me']['held']['pcs']);
        $ev = [['snap' => pfb_snap($w), 'by' => 'me', 'connect' => true, 'n' => implode(' + ', $names), 'types' => array_map(fn($gp) => (string)$gp['tile']['t'], $w['me']['held']['pcs']), 'size' => count($names)]];
    } else return $bad;
    foreach ($ev as $i => $e0) $ev[$i]['ta'] = 'me';   // whose turn the event happened in (a chain can run through the other side's pieces; the page groups by this)
    if ($dry) return ['ev' => $ev, 'err' => null, 'bar' => round($w['bar']['now'], 1), 'max' => $w['bar']['max'], 'fh' => round($w['fh']['now'], 1), 'fhmax' => $w['fh']['max'], 'hp' => $w['me']['hp'], 'block' => $w['me']['block'], 'over' => $w['over']];
    if (!$w['over']) { $fe = pfb_foe_turn($w, 0); foreach ($fe as $i => $e0) $fe[$i]['ta'] = 'foe'; $ev = array_merge($ev, $fe); }
    if (!$w['over']) pfb_end_round($w);
    if (!empty($w['v1'])) $ev = array_merge($ev, pfb_env_events($w));   // v1: the terrain turn, as events after the creature's (ta 'env')
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
            $n = 0; $tw = 1.0; $sun = 0;
            foreach ($r['ev'] as $e) { if (!isset($e['barnow'])) continue; $n++; if (isset($e['tw'])) $tw = (float)$e['tw']; if (!empty($e['sun']) && $e['by'] === 'me') $sun++; }
            $o[$c[0] . ',' . $c[1]] = ['dmg' => (int)round($r['fh'] - $fh0), 'ch' => (int)round($r['bar'] - $b0), 'hp' => max(0, $hp0 - (int)$r['hp']), 'n' => $n, 'used' => !empty($r['ev'][0]['used']), 'tw' => $tw, 'sun' => $sun, 'end' => (bool)$r['over']];
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
        $o[$c[0] . ',' . $c[1]] = ['dmg' => (int)round($fh - $fh0), 'ch' => (int)round($b - $b0), 'hp' => max(0, $hp0 - $hpMe), 'n' => $n, 'rp' => max(0, $hpMe - $hp), 'end' => (bool)$w['over']];
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
            $pv = max(1, (int)$s['me']['poison_v']); $s['me']['hp'] = max(0, $s['me']['hp'] - $pv); $s['me']['poison']--;
            $s['envlog'][] = ['k' => 'poison', 'x' => null, 'y' => null, 'me' => $pv, 'foe' => 0.0];
            if ($s['me']['poison'] === 0) $s['me']['poison_v'] = 0;
            if (pf_check_end($s)) return;
        }
        $slow = !empty($s['me']['slowdraw']) ? 1 : 0; $s['me']['slowdraw'] = 0;
    }
    $gone = pfb_expire($s);
    if (!empty($s['v1']['env'])) { $eg = array_values(array_map(fn($p) => $p['id'], array_filter($gone, fn($p) => $p['by'] === 'env'))); if ($eg) $s['envlog'][] = ['k' => 'expire', 'x' => null, 'y' => null, 'me' => 0, 'foe' => 0.0, 'ids' => $eg]; }   // 2.6.75: environment pieces whose time is up
    pf_draw($s, 'foe', $s['foe']['hsize']);
    $s['turn']++; $s['round']++;
    $s['me']['block'] = $s['me']['keep']; $s['me']['keep'] = 0; $s['me']['thorns'] = false; $s['me']['evade'] = 0;   // a new turn for you: last turn's guard is gone (a Hold guard carries over once)
    pf_draw($s, 'me', min(PF_HAND_CAP, count($s['me']['hand']) + PF_DRAW - $slow));
    $s['gone'] = array_merge(array_map(fn($p) => pfb_gone_entry($s, $p, true), $s['spent'] ?? []), array_map(fn($p) => pfb_gone_entry($s, $p, false), $gone));   // for the replay: they are shown until everything has scored, then they go
    $s['spawn'] = pfb_spawn($s);
    if ($s['turn'] > PF_TURN_CAP) { $s['over'] = $s['boss'] ? 'defeat' : 'stall'; return; }
    pfb_intent($s);
}

/** Pass the turn with nothing to place (no piece fits anywhere): the creature moves, the round ends. */
function pfb_pass(array &$s, int $turn): array
{
    if ($s['over'] || $turn !== $s['turn']) return ['ev' => [], 'err' => $s['over'] ? 'The fight is over.' : 'stale'];
    if (!empty($s['start'])) return ['ev' => [], 'err' => 'Pick your start piece first.'];
    foreach ($s['me']['hand'] as $i => $t) {
        if (pfb_cells($s, $t)) return ['ev' => [], 'err' => 'You still have a piece that fits somewhere.'];
        if (pfb_can_flip($s, $i)) { $ft = $t; if (!empty($ft['flip'])) unset($ft['flip']); else $ft['flip'] = true; if (pfb_cells($s, $ft)) return ['ev' => [], 'err' => 'You still have a piece that fits somewhere when you flip it.']; }   // v1
    }
    if (!empty($s['me']['held']) && pfb_group_spots($s, $s['me']['held'])) return ['ev' => [], 'err' => 'Your set-aside group still fits somewhere.'];
    $w = $s; $w['reshuf'] = []; $w['cut'] = 0; $w['spent'] = []; pfb_begin($w, 'me');
    if (!empty($w['v1'])) $w['envlog'] = [];
    $ev = pfb_foe_turn($w, 0); foreach ($ev as $i => $e0) $ev[$i]['ta'] = 'foe';
    $w['fx'] = pfb_fx($ev);
    if (!$w['over']) pfb_end_round($w);
    if (!empty($w['v1'])) $ev = array_merge($ev, pfb_env_events($w));
    $s = $w;
    return ['ev' => $ev, 'err' => null];
}

/** What the client may see: the board is public; the draw pile and the foe's hand are not. Each piece carries its edges so the client can show where a piece fits. */
function pfb_view(array $s): array
{
    $v = pf_view($s);
    $v['start'] = !empty($s['start']); $v['mode'] = 'board'; $v['w'] = pfb_w($s); $v['h'] = pfb_h($s); $v['fx'] = $s['fx'] ?? [];
    $g = $s['me']['held'] ?? null;
    $v['held'] = $g ? ['pcs' => array_map(fn($p) => ['n' => $p['tile']['n'], 't' => $p['tile']['t'], 'v' => $p['tile']['v'], 'tag' => $p['tile']['tag'], 'm' => (string)($p['tile']['m'] ?? ''), 'e' => pfb_edges($p['tile']), 'x' => $p['x'], 'y' => $p['y']], $g['pcs']), 'spots' => pfb_group_spots($s, $g), 'link' => (bool)array_filter(pfb_group_cells_all($s, $g), fn($o) => $o[2])] : null;
    $v['pcs'] = array_values(array_map(fn($p) => ['id' => $p['id'], 'by' => $p['by'], 'x' => $p['x'], 'y' => $p['y'], 'n' => $p['tile']['n'], 't' => $p['tile']['t'], 'v' => $p['tile']['v'], 'tag' => $p['tile']['tag'], 'm' => (string)($p['tile']['m'] ?? ''), 'e' => pfb_edges($p['tile']), 'age' => $s['round'] - $p['born'], 'seq' => $p['seq'], 'fl' => pfb_fire_limit($p) > 0 ? max(0, pfb_fire_limit($p) - (int)($p['f'] ?? 0)) : null, 'spawn' => ($s['spawn'] ?? null) === $p['id'], 'fnew' => in_array($p['id'], $s['lastfoe'] ?? [], true)], $s['pcs']));
    $v['gone'] = array_map(fn($g) => ['id' => $g['id'], 'by' => $g['by'], 'x' => $g['x'], 'y' => $g['y'], 'n' => $g['tile']['n'], 't' => $g['tile']['t'], 'v' => $g['tile']['v'], 'tag' => $g['tile']['tag'], 'm' => (string)($g['tile']['m'] ?? ''), 'e' => pfb_edges($g['tile']), 'age' => $g['age'], 'fell' => !empty($g['fell'])], $s['gone'] ?? []);
    foreach ($v['hand'] as $i => $t) $v['hand'][$i]['e'] = pfb_edges($s['me']['hand'][$i]);
    unset($v['strip'], $v['open'], $v['open_t'], $v['open_v'], $v['open_by']);
    if (!empty($s['v1'])) {   // v1: everything the page needs for ground, events, the aim, use-up, Teamwork, flip and piece life
        $c = $s['v1'];
        $v['v1'] = ['limit' => (int)$c['limit'], 'sun' => $c['sun'], 'bramble' => $c['bramble'], 'br_foe' => $c['br_foe'], 'thorn' => $c['thorn'], 'ev_foe' => $c['ev_foe'], 'team2' => $c['team2'], 'team3' => $c['team3'],
            'env' => !empty($c['env']), 'envn' => (int)($c['envn'] ?? 0), 'rain' => (float)($c['rain'] ?? 0), 'th_foe' => (float)($c['th_foe'] ?? 1),
            'ground' => (bool)$c['ground'], 'events' => (bool)$c['events'], 'aim' => (bool)$c['aim'], 'flip' => (bool)$c['flip'], 'life' => (bool)$c['life'], 'edges' => (bool)$c['edges']];
        $v['round'] = (int)$s['round'];
        $v['ter'] = (object)($s['ter'] ?? []);   // "x,y" => 'sun' | 'br' | 'mud' (oldest first)
        $v['envs'] = array_map(fn($e) => $e + ['n' => PFB_EVENT_NAME[$e['kind']], 'on' => ($q = pfb_at($s, $e['x'], $e['y'])) && $q['by'] !== 'none' ? ['id' => $q['id'], 'by' => $q['by'], 'n' => $q['tile']['n']] : null], $s['envs'] ?? []);   // the forecast: lands after the creature's move
        $v['envlog'] = $s['envlog'] ?? [];   // what the last terrain turn did
        if (!empty($c['env'])) {   // 2.6.75: the environment's deck: its next piece (face up a round ahead; null = none left or all on the board), how many wait, how many it places a round
            $nx = $s['env']['next'] ?? null;
            $v['env'] = ['next' => $nx ? ['k' => $nx['k'], 'n' => $nx['n'], 'kind' => $nx['env'], 'life' => (int)$nx['life'], 'e' => pfb_edges($nx)] : null, 'draw' => count($s['env']['draw']), 'discard' => count($s['env']['discard']), 'n' => (int)$c['envn']];
        }
        $v['aim'] = $s['foe']['plan'] ?? null;   // the creature's next piece and cell (null: it shows none, or it is tripped)
        $v['reaim'] = !empty($s['reaim']);   // last turn it could not play its aim and picked again
        $v['flip'] = ['on' => (bool)$c['flip'], 'used' => (int)($s['me']['flipt'] ?? 0) === (int)$s['turn']];
        if (!empty($c['tags'])) $v['status'] = ['poison' => (int)$s['me']['poison'], 'poison_v' => (int)$s['me']['poison_v'], 'slowdraw' => (int)$s['me']['slowdraw'], 'evade' => (int)$s['me']['evade'],
            'foe_evade' => (int)$s['foe']['evade'], 'foe_thorns' => (bool)$s['foe']['thorns'], 'foe_bash' => (int)$s['foe']['bashnext'], 'foe_slow' => (int)$s['foe']['slow'], 'foe_poison' => (int)$s['foe']['poison']];   // 2.6.74: what is waiting on each side (creature tags)
        $v['wear'] = (object)($s['wear'] ?? []);   // tool type => durability its piece has cost so far this fight
        foreach ($v['pcs'] as $i => $q) {
            $p = $s['pcs'][$q['id']]; $life = pfb_life($s, $p);
            $v['pcs'][$i] += ['life' => $life, 'left' => $p['born'] + $life - (int)$s['round'], 'src' => (string)($p['tile']['src'] ?? ''), 'flip' => !empty($p['tile']['flip']), 'ter' => pfb_ter($s, $p['x'], $p['y']), 'rank' => (int)($p['tile']['rank'] ?? 0), 'layer' => (string)($p['tile']['layer'] ?? '')];   // left: rounds it still stays, this one included (1 = it goes at the end of this round)
            if ($p['by'] === 'env') $v['pcs'][$i] += ['env' => (string)$p['tile']['env'], 'dir' => $p['tile']['dir'] ?? null];   // 2.6.75: an environment piece: its kind, Wind's arrow
        }
        foreach ($v['hand'] as $i => $t) { $ht = $s['me']['hand'][$i]; $v['hand'][$i] += ['life' => (int)($ht['life'] ?? PFB_LIFE), 'src' => (string)($ht['src'] ?? ''), 'flip' => !empty($ht['flip']), 'canflip' => pfb_can_flip($s, $i), 'rank' => (int)($ht['rank'] ?? 0), 'tool' => (string)($ht['tool'] ?? '')]; }
        if ($v['held']) foreach ($v['held']['pcs'] as $i => $q) { $ht = $g['pcs'][$i]['tile']; $v['held']['pcs'][$i] += ['life' => (int)($ht['life'] ?? PFB_LIFE), 'src' => (string)($ht['src'] ?? ''), 'flip' => !empty($ht['flip'])]; }
        foreach ($v['gone'] as $i => $q) if (isset($s['gone'][$i]['used'])) $v['gone'][$i]['used'] = $s['gone'][$i]['used'];
    }
    return $v;
}
