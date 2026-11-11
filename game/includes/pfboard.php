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

const PFB_W = 7, PFB_H = 5, PFB_LIFE = 2, PFB_MAX_PLACE = 4;
const PFB_BAR_MULT = 2.0, PFB_FOE_MULT = 0.8;   // the resolve bar vs strip mode (a chain refires older pieces, so the board is faster); PFB_FOE_MULT scales the creature's piece values. Tuned by tests/pfboard_sim.php
const PFB_SIDE = ['L' => [-1, 0, 'R'], 'R' => [1, 0, 'L'], 'T' => [0, -1, 'B'], 'B' => [0, 1, 'T']];   // side => [dx, dy, the neighbour's side that touches it]

/** The four edges of a tile: L = hole of its type's family, R = its knob (or flat), T and B fixed per tile from its key (about a quarter flat). */
function pfb_edges(array $t): array
{
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
    if ($x < 0 || $y < 0 || $x >= PFB_W || $y >= PFB_H || isset($s['cell']["$x,$y"])) return null;
    if (!$s['pcs']) return ($x === intdiv(PFB_W, 2) && $y === intdiv(PFB_H, 2)) ? [] : null;   // an empty board: the centre
    $e = pfb_edges($tile); $joints = [];
    foreach (PFB_SIDE as $side => [$dx, $dy, $opp]) {
        $n = pfb_at($s, $x + $dx, $y + $dy);
        if (!$n) continue;
        [$fits, $linked] = pfb_joint($e[$side], pfb_edges($n['tile'])[$opp]);
        if (!$fits) return null;
        $joints[] = [$side, (int)$n['id'], $linked];
    }
    return $joints ?: null;   // it has to touch something
}

/** Every legal [x, y] for a tile. */
function pfb_cells(array $s, array $tile): array
{
    $o = [];
    for ($y = 0; $y < PFB_H; $y++) for ($x = 0; $x < PFB_W; $x++) if (pfb_check($s, $tile, $x, $y) !== null) $o[] = [$x, $y];
    return $o;
}

/** The pieces linked to one piece, newest first. */
function pfb_links(array $s, int $id): array
{
    $p = $s['pcs'][$id]; $e = pfb_edges($p['tile']); $o = [];
    foreach (PFB_SIDE as $side => [$dx, $dy, $opp]) {
        $n = pfb_at($s, $p['x'] + $dx, $p['y'] + $dy);
        if ($n && pfb_joint($e[$side], pfb_edges($n['tile'])[$opp])[1]) $o[] = $n;
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
    foreach (pfb_chain($s, $root) as [$id, $par]) {
        if ($s['over']) break;
        $p = $s['pcs'][$id]; $who = $p['by']; $tile = $p['tile'];
        $pt = $par !== null ? $s['pcs'][$par] : null;
        [$val, , $ck] = pf_value($pt['tile'] ?? null, $tile, $pt !== null && $pt['by'] === $who, false);   // combos only off your own piece; no fit bonus (every link fits)
        $isRoot = $id === $root;
        $e = ['by' => $who, 'id' => $id, 'root' => $isRoot, 'tag' => $tile['tag'], 'mod' => (string)($tile['m'] ?? ''), 'k' => $tile['k'], 'n' => $tile['n'], 't' => $tile['t'], 'v' => $val, 'fit' => false, 'combo' => $ck ? PF_COMBOS[$ck]['name'] : null];
        pf_apply($s, $who, $tile, $val, $isRoot && pfb_links($s, $id) !== [], $ck, $pt['tile'] ?? null, $pt['by'] ?? null, $e, $isRoot, false);
        $ev[] = $e;
        pf_check_end($s);
    }
    return $ev;
}

/** The start of a side's turn: its guard from last turn is spent (a Hold guard carries over once). */
function pfb_begin(array &$s, string $who): void
{
    $s[$who]['block'] = $s[$who]['keep']; $s[$who]['keep'] = 0; $s[$who]['thorns'] = false; $s[$who]['evade'] = 0;
}

/** Put a tile from $who's hand on the board at (x,y) and fire its chain. Returns the events, or null when it is illegal (nothing changed). */
function pfb_place(array &$s, string $who, int $handIdx, int $x, int $y): ?array
{
    $tile = $s[$who]['hand'][$handIdx] ?? null;
    if (!$tile || pfb_check($s, $tile, $x, $y) === null) return null;
    array_splice($s[$who]['hand'], $handIdx, 1);
    $id = ++$s['pid']; $s['seq']++;
    $s['pcs'][$id] = ['id' => $id, 'by' => $who, 'tile' => $tile, 'x' => $x, 'y' => $y, 'born' => $s['round'], 'seq' => $s['seq']];
    $s['cell']["$x,$y"] = $id;
    $joints = pfb_check_after($s, $id);
    $ev = pfb_fire($s, $id);
    if ($ev) $ev[0]['linked'] = $joints;   // how many linked joints the new piece made
    return $ev;
}

function pfb_check_after(array $s, int $id): int
{
    return count(pfb_links($s, $id));
}

/** Expire old pieces at the end of a round: back to their owner's discard. */
function pfb_expire(array &$s): void
{
    foreach ($s['pcs'] as $id => $p) if ($p['born'] <= $s['round'] - PFB_LIFE + 1) {
        $s[$p['by']]['discard'][] = $p['tile'];
        unset($s['cell'][$p['x'] . ',' . $p['y']], $s['pcs'][$id]);
    }
}

// ---------------------------------------------------------------- the creature's play

function pfb_score(array $b, array $a, string $who): float
{
    $barD = $a['bar']['now'] - $b['bar']['now'];
    $hpD = $a['me']['hp'] - $b['me']['hp'];
    if ($who === 'me') return $barD + 0.7 * $hpD + 0.3 * ($a['me']['block'] - $b['me']['block']) - 0.3 * ($a['foe']['block'] - $b['foe']['block']) + ($a['over'] && in_array($a['over'], ['seen_off', 'charmed'], true) ? 50 : 0);
    return -0.8 * $barD - $hpD + 0.4 * ($a['foe']['block'] - $b['foe']['block']) - 0.3 * ($a['me']['block'] - $b['me']['block']) + ($a['over'] === 'defeat' ? 50 : 0);
}

/** The best single placement for $who by trying every tile in every legal cell on a copy. [handIdx, x, y, score] or null. Ties: first found (deterministic). */
function pfb_search(array $s, string $who, bool $allowHeavy = true): ?array
{
    $best = null;
    foreach ($s[$who]['hand'] as $i => $tile) {
        if (!$allowHeavy && $tile['tag'] === 'heavy' && ($tile['m'] ?? '') !== 'steady') continue;
        foreach (pfb_cells($s, $tile) as [$x, $y]) {
            $w = $s;
            if (pfb_place($w, $who, $i, $x, $y) === null) continue;
            $sc = pfb_score($s, $w, $who);
            if ($best === null || $sc > $best[3] + 1e-9) $best = [$i, $x, $y, $sc];
        }
    }
    return $best;
}

function pfb_foe_turn(array &$s, int $extra): array
{
    $ev = [];
    pfb_begin($s, 'foe');
    if ($s['foe']['poison'] > 0) {   // Sting: the poison works on the creature before it acts
        $add = $s['foe']['poison_v'] * $s['hm'];
        $s['bar']['now'] += $add; $s['bar']['hurt'] += $add; $s['foe']['poison']--;
        if ($s['foe']['poison'] === 0) $s['foe']['poison_v'] = 0;
        $ev[] = ['by' => 'me', 'tag' => 'poison', 'k' => 'poison', 'n' => 'Poison', 't' => 'hurt', 'v' => (int)round($add), 'fit' => false, 'combo' => null, 'tick' => true];
        if (pf_check_end($s)) return $ev;
    }
    $n = pf_foe_len($s, $extra);
    for ($k = 0; $k < $n && !$s['over']; $k++) {
        $m = pfb_search($s, 'foe');
        if ($m === null) break;
        $r = pfb_place($s, 'foe', $m[0], $m[1], $m[2]);
        if ($r) $ev = array_merge($ev, $r);
    }
    $s['foe']['agg'] = 0; $s['foe']['slow'] = 0;
    return $ev;
}

// ---------------------------------------------------------------- the whole fight

/** Start a board fight: pf_new's hands and bar, then one or two of the creature's gentlest pieces go out (nothing fires for them). */
function pfb_new(array $me, array $c, int $seed, array $opt = []): array
{
    $s = pf_new($me, $c, $seed, $opt);
    foreach (['hand', 'draw', 'discard'] as $z) foreach ($s['foe'][$z] as $i => $t) $s['foe'][$z][$i]['v'] = max(1, (int)round($t['v'] * PFB_FOE_MULT));
    $s['bar']['max'] = round($s['bar']['max'] * PFB_BAR_MULT, 1);
    $s['mode'] = 'board'; $s['strip'] = []; $s['pcs'] = []; $s['cell'] = []; $s['pid'] = 0; $s['seq'] = 0; $s['round'] = 1;
    $n = in_array($s['size'], ['large', 'boss'], true) ? 2 : 1;
    for ($k = 0; $k < $n; $k++) {
        $hand = $s['foe']['hand']; $pick = null;
        foreach ($hand as $i => $t) if ($t['t'] !== 'hurt' && ($pick === null || $t['v'] < $hand[$pick]['v'])) $pick = $i;
        $pick ??= 0;
        $cells = $s['pcs'] ? null : [[intdiv(PFB_W, 2), intdiv(PFB_H, 2)]];
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

function pfb_intent(array &$s): void
{
    $m = pfb_search($s, 'foe');
    $s['foe']['intent'] = $m ? $s['foe']['hand'][$m[0]]['t'] : null;
}

/**
 * The player's turn: $moves = [[handIdx, x, y], ...] in play order (indices refer to the hand as it is now), 1 to 4 pieces. One POST per turn, like the strip.
 * Returns ['ev' => events, 'err' => ?string]; on an error nothing changed.
 */
function pfb_play(array &$s, array $moves, int $turn, ?callable $canPlay = null): array
{
    if ($s['over']) return ['ev' => [], 'err' => 'The fight is over.'];
    if ($turn !== $s['turn']) return ['ev' => [], 'err' => 'stale'];
    $n = count($moves);
    if ($n < 1 || $n > PFB_MAX_PLACE) return ['ev' => [], 'err' => 'Place 1 to ' . PFB_MAX_PLACE . ' pieces.'];
    $used = []; $tiles = [];
    foreach ($moves as $mv) {
        if (!is_array($mv) || count($mv) !== 3 || !is_int($mv[0]) || !is_int($mv[1]) || !is_int($mv[2]) || isset($used[$mv[0]]) || !isset($s['me']['hand'][$mv[0]])) return ['ev' => [], 'err' => 'Those moves are not valid.'];
        $used[$mv[0]] = true; $tiles[] = $s['me']['hand'][$mv[0]];
    }
    foreach ($tiles as $i => $t) if ($t['tag'] === 'heavy' && ($t['m'] ?? '') !== 'steady' && $i !== $n - 1) return ['ev' => [], 'err' => 'A heavy piece has to be the last one you place.'];
    if ($canPlay) foreach ($tiles as $t) if (($why = $canPlay($t)) !== null) return ['ev' => [], 'err' => $why];
    $w = $s;   // work on a copy: any illegal placement means nothing happens
    pfb_begin($w, 'me');
    $ev = []; $counted = 0;
    foreach ($moves as $k => [, $x, $y]) {
        $now = array_search($tiles[$k], $w['me']['hand'], true);   // the tile's index in the hand as it is now (earlier placements shifted it)
        if ($now === false) return ['ev' => [], 'err' => 'Those moves are not valid.'];
        if ($w['over']) { $w['me']['discard'][] = $tiles[$k]; array_splice($w['me']['hand'], (int)$now, 1); continue; }   // the fight ended mid-turn: the rest go to the discard
        $r = pfb_place($w, 'me', (int)$now, $x, $y);
        if ($r === null) return ['ev' => [], 'err' => 'That piece does not fit there.'];
        $ev = array_merge($ev, $r);
        if (($tiles[$k]['m'] ?? '') !== 'swift') $counted++;
    }
    if (!$w['over']) $ev = array_merge($ev, pfb_foe_turn($w, $counted === PFB_MAX_PLACE ? 1 : 0));
    if (!$w['over']) pfb_end_round($w);
    $w['log'][] = ['turn' => $s['turn'], 'n' => $n];
    $s = $w;
    return ['ev' => $ev, 'err' => null];
}

function pfb_end_round(array &$s): void
{
    pfb_expire($s);
    pf_draw($s, 'foe', $s['foe']['hsize']);
    $s['turn']++; $s['round']++;
    pf_draw($s, 'me', min(PF_HAND_CAP, count($s['me']['hand']) + PF_DRAW));
    if ($s['turn'] > PF_TURN_CAP) { $s['over'] = $s['boss'] ? 'defeat' : 'stall'; return; }
    pfb_intent($s);
}

/** Pass the turn with nothing to place (no piece fits anywhere): the creature moves, the round ends. */
function pfb_pass(array &$s, int $turn): array
{
    if ($s['over'] || $turn !== $s['turn']) return ['ev' => [], 'err' => $s['over'] ? 'The fight is over.' : 'stale'];
    foreach ($s['me']['hand'] as $t) if (pfb_cells($s, $t)) return ['ev' => [], 'err' => 'You still have a piece that fits somewhere.'];
    $w = $s; pfb_begin($w, 'me');
    $ev = pfb_foe_turn($w, 0);
    if (!$w['over']) pfb_end_round($w);
    $s = $w;
    return ['ev' => $ev, 'err' => null];
}

/** What the client may see: the board is public; the draw pile and the foe's hand are not. Each piece carries its edges so the client can show where a piece fits. */
function pfb_view(array $s): array
{
    $v = pf_view($s);
    $v['mode'] = 'board'; $v['w'] = PFB_W; $v['h'] = PFB_H;
    $v['pcs'] = array_values(array_map(fn($p) => ['id' => $p['id'], 'by' => $p['by'], 'x' => $p['x'], 'y' => $p['y'], 'n' => $p['tile']['n'], 't' => $p['tile']['t'], 'v' => $p['tile']['v'], 'tag' => $p['tile']['tag'], 'm' => (string)($p['tile']['m'] ?? ''), 'e' => pfb_edges($p['tile']), 'age' => $s['round'] - $p['born']], $s['pcs']));
    foreach ($v['hand'] as $i => $t) $v['hand'][$i]['e'] = pfb_edges($s['me']['hand'][$i]);
    unset($v['strip'], $v['open'], $v['open_t'], $v['open_v'], $v['open_by']);
    return $v;
}
