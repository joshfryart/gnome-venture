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
const PFB_GROUP_MULT = [2 => 1.0, 3 => 1.25]; // the values of a placed group's pieces (3 pieces play for maximum effect)
const PFB_BAR_MULT = 0.7, PFB_FOE_MULT = 0.62;   // the resolve bar vs strip mode, and a factor on the creature's piece values (one piece a turn each side). Tuned by tests/pfboard_sim.php: small 3.2, medium 4.2, large 4.5, boss 6.6 turns, defeats under 3%
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
    foreach ($s[$who]['hand'] as $t) for ($y = 0; $y < PFB_H; $y++) for ($x = 0; $x < PFB_W; $x++) if (pfb_has_link(pfb_check($s, $t, $x, $y))) return true;
    $g = $s[$who]['held'] ?? null;
    if ($g) foreach (pfb_group_cells_all($s, $g) as $o) if ($o[2]) return true;
    return false;
}

/** Every legal [x, y] for a tile. With $who: only the spots that connect, when the side has any connecting move at all (see pfb_must_link). */
function pfb_cells(array $s, array $tile, ?string $who = null): array
{
    $o = []; $must = $who !== null && pfb_must_link($s, $who);
    for ($y = 0; $y < PFB_H; $y++) for ($x = 0; $x < PFB_W; $x++) { $j = pfb_check($s, $tile, $x, $y); if ($j !== null && (!$must || pfb_has_link($j))) $o[] = [$x, $y]; }
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
        $val = (int)round($val * (float)($p['cm'] ?? 1.0));   // a placed 3-piece group plays for more
        $isRoot = $id === $root;
        $e = ['by' => $who, 'id' => $id, 'root' => $isRoot, 'tag' => $tile['tag'], 'mod' => (string)($tile['m'] ?? ''), 'k' => $tile['k'], 'n' => $tile['n'], 't' => $tile['t'], 'v' => $val, 'fit' => false, 'combo' => $ck ? PF_COMBOS[$ck]['name'] : null];
        pf_apply($s, $who, $tile, $val, $isRoot && pfb_links($s, $id) !== [], $ck, $pt['tile'] ?? null, $pt['by'] ?? null, $e, $isRoot, false);
        $e['barnow'] = round((float)$s['bar']['now'], 1); $e['fhnow'] = round((float)$s['fh']['now'], 1); $e['hpnow'] = (int)$s['me']['hp']; $e['gnow'] = (int)$s['me']['block'];   // for the replay: how the bar and health stand after this piece
        $ev[] = $e;
        pf_check_end($s);
    }
    return $ev;
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
    if ($jt === null || (!pfb_has_link($jt) && pfb_must_link($s, $who))) return null;   // it has to connect unless nothing can
    array_splice($s[$who]['hand'], $handIdx, 1);
    $id = ++$s['pid']; $s['seq']++;
    $s['pcs'][$id] = ['id' => $id, 'by' => $who, 'tile' => $tile, 'x' => $x, 'y' => $y, 'born' => $s['round'], 'seq' => $s['seq']];
    $s['cell']["$x,$y"] = $id;
    $joints = pfb_check_after($s, $id);
    $ev = pfb_fire($s, $id);
    if ($ev) { $ev[0]['linked'] = $joints; $ev[0]['snap'] = pfb_snap($s); }   // linked: how many linked joints the new piece made; snap: the board for the history rewind
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
        if ($x < 0 || $y < 0 || $x >= PFB_W || $y >= PFB_H || isset($s['cell']["$x,$y"])) return null;
        $e = pfb_edges($g['pcs'][$i]['tile']);
        foreach (PFB_SIDE as $side => [$dx, $dy, $opp]) {
            $nx = $x + $dx; $ny = $y + $dy; if (isset($mine["$nx,$ny"])) continue;   // inside the group: already checked when it was joined
            $n = pfb_at($s, $nx, $ny); if (!$n) continue;
            $jt = pfb_joint($e[$side], pfb_edges($n['tile'])[$opp]);
            if (!$jt[0]) return null;
            $touch = true; if ($jt[1]) $linked = true;
        }
    }
    if (!$s['pcs']) { $c = [intdiv(PFB_W, 2), intdiv(PFB_H, 2)]; foreach ($cells as [$x, $y]) if ($x === $c[0] && $y === $c[1]) return [$cells, false]; return null; }
    return $touch ? [$cells, $linked] : null;
}

/** Every spot [ox, oy, linked] where the group fits (before the connect rule). */
function pfb_group_cells_all(array $s, array $g): array
{
    $o = [];
    for ($y = 0; $y < PFB_H; $y++) for ($x = 0; $x < PFB_W; $x++) { $r = pfb_group_cells_l($s, $g, $x, $y); if ($r !== null) $o[] = [$x, $y, $r[1]]; }
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
    }
    $s[$who]['held'] = null;
    $ev = pfb_fire($s, $root);
    if ($ev) { $ev[0]['linked'] = pfb_check_after($s, $root); $ev[0]['snap'] = pfb_snap($s); }
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
    foreach ($s['pcs'] as $id => $p) if ($p['born'] <= $s['round'] - PFB_LIFE + 1) {
        $s[$p['by']]['discard'][] = $p['tile'];
        $gone[] = $p;
        unset($s['cell'][$p['x'] . ',' . $p['y']], $s['pcs'][$id]);
    }
    return $gone;
}

/** Which creature hand piece starts the board or refills it: its gentlest non-Hurt piece. */
function pfb_anchor_pick(array $s): ?int
{
    $hand = $s['foe']['hand']; if (!$hand) return null;
    $pick = null;
    foreach ($hand as $i => $t) if ($t['t'] !== 'hurt' && ($pick === null || $t['v'] < $hand[$pick]['v'])) $pick = $i;
    return $pick ?? 0;
}

/** After the creature's turn: if it has fewer than PFB_FOE_MIN pieces out, put one of its gentlest pieces on the board (nothing fires for it). Returns the new piece's id or null. */
function pfb_spawn(array &$s): ?int
{
    if (count(array_filter($s['pcs'], fn($p) => $p['by'] === 'foe')) >= PFB_FOE_MIN) return null;
    $pick = pfb_anchor_pick($s); if ($pick === null) return null;
    $tile = $s['foe']['hand'][$pick];
    $cells = $s['pcs'] ? pfb_cells($s, $tile) : [[intdiv(PFB_W, 2), intdiv(PFB_H, 2)]];
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
    if ($who === 'me') return $barD + 0.7 * $hpD + 0.3 * ($a['me']['block'] - $b['me']['block']) - 0.3 * ($a['foe']['block'] - $b['foe']['block']) + ($a['over'] && in_array($a['over'], ['seen_off', 'charmed'], true) ? 50 : 0);
    return -0.8 * $barD - $hpD + 0.4 * ($a['foe']['block'] - $b['foe']['block']) - 0.3 * ($a['me']['block'] - $b['me']['block']) + ($a['over'] === 'defeat' ? 50 : 0);
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
    $n = pfb_foe_len($s); $s['lastfoe'] = [];   // the pieces it puts down this turn (the page holds only these back until the replay reaches them)
    for ($k = 0; $k < $n && !$s['over']; $k++) {
        $m = pfb_search($s, 'foe');
        if ($m === null) break;
        $r = pfb_place($s, 'foe', $m[0], $m[1], $m[2]);
        if ($r) { $ev = array_merge($ev, $r); $s['lastfoe'][] = $s['pid']; }
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
    $s['bar']['max'] = round($s['bar']['max'] * PFB_BAR_MULT, 1); $s['fh']['max'] = $s['bar']['max'];
    $s['mode'] = 'board'; $s['strip'] = []; $s['pcs'] = []; $s['cell'] = []; $s['pid'] = 0; $s['seq'] = 0; $s['round'] = 1;
    $n = $s['size'] === 'boss' ? 2 : 1;
    for ($k = 0; $k < $n; $k++) {
        $pick = pfb_anchor_pick($s); if ($pick === null) continue; $hand = $s['foe']['hand'];
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
    if ($turn !== $s['turn']) return ['ev' => [], 'err' => 'stale'];
    if (count($moves) !== 1) return ['ev' => [], 'err' => 'One action a turn.'];
    $mv = $moves[0]; $bad = ['ev' => [], 'err' => 'Those moves are not valid.'];
    if (!is_array($mv) || !$mv) return $bad;
    $w = $s;   // work on a copy: anything illegal means nothing happens
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
        $names = array_map(fn($gp) => (string)$gp['tile']['n'], $w['me']['held']['pcs']);
        $ev = [['snap' => pfb_snap($w), 'by' => 'me', 'connect' => true, 'n' => implode(' + ', $names), 'types' => array_map(fn($gp) => (string)$gp['tile']['t'], $w['me']['held']['pcs']), 'size' => count($names)]];
    } else return $bad;
    if ($dry) return ['ev' => $ev, 'err' => null, 'bar' => round($w['bar']['now'], 1), 'max' => $w['bar']['max'], 'fh' => round($w['fh']['now'], 1), 'fhmax' => $w['fh']['max'], 'hp' => $w['me']['hp'], 'block' => $w['me']['block'], 'over' => $w['over']];
    if (!$w['over']) $ev = array_merge($ev, pfb_foe_turn($w, 0));
    if (!$w['over']) pfb_end_round($w);
    $w['fx'] = pfb_fx($ev);
    $w['log'][] = ['turn' => $s['turn'], 'n' => 1];
    $s = $w;
    return ['ev' => $ev, 'err' => null];
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
    $gone = pfb_expire($s);
    pf_draw($s, 'foe', $s['foe']['hsize']);
    $s['turn']++; $s['round']++;
    $s['me']['block'] = $s['me']['keep']; $s['me']['keep'] = 0; $s['me']['thorns'] = false; $s['me']['evade'] = 0;   // a new turn for you: last turn's guard is gone (a Hold guard carries over once)
    pf_draw($s, 'me', min(PF_HAND_CAP, count($s['me']['hand']) + PF_DRAW));
    $s['gone'] = array_map(fn($p) => ['id' => $p['id'], 'by' => $p['by'], 'x' => $p['x'], 'y' => $p['y'], 'tile' => $p['tile'], 'age' => $s['round'] - 1 - $p['born']], $gone);   // for the replay: they are shown until everything has scored, then they go
    $s['spawn'] = pfb_spawn($s);
    if ($s['turn'] > PF_TURN_CAP) { $s['over'] = $s['boss'] ? 'defeat' : 'stall'; return; }
    pfb_intent($s);
}

/** Pass the turn with nothing to place (no piece fits anywhere): the creature moves, the round ends. */
function pfb_pass(array &$s, int $turn): array
{
    if ($s['over'] || $turn !== $s['turn']) return ['ev' => [], 'err' => $s['over'] ? 'The fight is over.' : 'stale'];
    foreach ($s['me']['hand'] as $t) if (pfb_cells($s, $t)) return ['ev' => [], 'err' => 'You still have a piece that fits somewhere.'];
    if (!empty($s['me']['held']) && pfb_group_spots($s, $s['me']['held'])) return ['ev' => [], 'err' => 'Your set-aside group still fits somewhere.'];
    $w = $s; pfb_begin($w, 'me');
    $ev = pfb_foe_turn($w, 0);
    $w['fx'] = pfb_fx($ev);
    if (!$w['over']) pfb_end_round($w);
    $s = $w;
    return ['ev' => $ev, 'err' => null];
}

/** What the client may see: the board is public; the draw pile and the foe's hand are not. Each piece carries its edges so the client can show where a piece fits. */
function pfb_view(array $s): array
{
    $v = pf_view($s);
    $v['mode'] = 'board'; $v['w'] = PFB_W; $v['h'] = PFB_H; $v['fx'] = $s['fx'] ?? [];
    $g = $s['me']['held'] ?? null;
    $v['held'] = $g ? ['pcs' => array_map(fn($p) => ['n' => $p['tile']['n'], 't' => $p['tile']['t'], 'v' => $p['tile']['v'], 'tag' => $p['tile']['tag'], 'm' => (string)($p['tile']['m'] ?? ''), 'e' => pfb_edges($p['tile']), 'x' => $p['x'], 'y' => $p['y']], $g['pcs']), 'spots' => pfb_group_spots($s, $g), 'link' => (bool)array_filter(pfb_group_cells_all($s, $g), fn($o) => $o[2])] : null;
    $v['pcs'] = array_values(array_map(fn($p) => ['id' => $p['id'], 'by' => $p['by'], 'x' => $p['x'], 'y' => $p['y'], 'n' => $p['tile']['n'], 't' => $p['tile']['t'], 'v' => $p['tile']['v'], 'tag' => $p['tile']['tag'], 'm' => (string)($p['tile']['m'] ?? ''), 'e' => pfb_edges($p['tile']), 'age' => $s['round'] - $p['born'], 'seq' => $p['seq'], 'spawn' => ($s['spawn'] ?? null) === $p['id'], 'fnew' => in_array($p['id'], $s['lastfoe'] ?? [], true)], $s['pcs']));
    $v['gone'] = array_map(fn($g) => ['id' => $g['id'], 'by' => $g['by'], 'x' => $g['x'], 'y' => $g['y'], 'n' => $g['tile']['n'], 't' => $g['tile']['t'], 'v' => $g['tile']['v'], 'tag' => $g['tile']['tag'], 'm' => (string)($g['tile']['m'] ?? ''), 'e' => pfb_edges($g['tile']), 'age' => $g['age']], $s['gone'] ?? []);
    foreach ($v['hand'] as $i => $t) $v['hand'][$i]['e'] = pfb_edges($s['me']['hand'][$i]);
    unset($v['strip'], $v['open'], $v['open_t'], $v['open_v'], $v['open_by']);
    return $v;
}
