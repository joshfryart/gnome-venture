<?php
// Puzzle fight BOARD playtest harness for agents and bots (no DB, no server, no browser).
//   php tests/pf_play.php new STATE CREATURE_SLUG LEVEL SEED [classic|blank|v1|v1classic|v1old] [REGION] [old|BUILD]   start a fight (the real layered creature deck and the deck-model player deck; arg 8 `old` = the archetype creature deck and the stage A player deck) (blank = blank wild centre + hidden start; v1 = the v1 board rules with the blank opening and ENVIRONMENT PIECES (2.6.75); v1old = the 2.6.74 ground and events; REGION = a region code, it leans the environment's deck)
//   php tests/pf_play.php flip STATE HANDIDX              (v1 only) flip a hand piece: swap its top and bottom edges. Free, once a turn; flip the same piece again to take it back
//   php tests/pf_play.php show STATE                                           the board, your hand and every legal cell
//   php tests/pf_play.php start STATE HANDIDX SIDE        (blank only) hidden start piece next to the centre: SIDE = L R T B
//   php tests/pf_play.php place STATE HANDIDX X Y         play one hand piece
//   php tests/pf_play.php join STATE A B SIDE              set hand piece B aside joined to hand piece A (B on A's SIDE), no effect
//   php tests/pf_play.php add STATE B ANC SIDE             add hand piece B to the set-aside group, onto group piece ANC's SIDE
//   php tests/pf_play.php group STATE X Y                  play the set-aside group, top-left at X,Y
//   php tests/pf_play.php pass STATE                       skip your turn (allowed any time in a v1 fight: a free pass, 2.6.95; classic fights only when nothing fits)
//   php tests/pf_play.php list [N]                         creatures (slug, size, level)
// STATE is a json file. Every action is appended to STATE.log (one json line each) for data. The creature's hand and the draw pile are never shown.
require __DIR__ . '/../game/includes/pfboard.php';
require __DIR__ . '/../game/includes/pfdeck.php';
require_once __DIR__ . '/pf_creatures_load.php';
require_once __DIR__ . '/pf_bots.php';   // pb_player() for the BUILD arg (guarded: runs nothing when required)
$die = ['small' => 4, 'medium' => 6, 'large' => 8, 'boss' => 10];
function pp_creatures(): array { return pt_load_creatures(); }   // all 319 (tests/pf_creatures_load.php)
/** The player's sources at a level (the deck model's, as tests/pfboard_tune_v1.php tv_sources): a kit, a belt of tools, pals, crops, crafts, regions and knacks. */
function pp_sources(int $lv): array
{
    $cals = array_keys(PF_CALLING_TILE); $src = pfd_sources_blank($lv, $cals[$lv % 6], ['NA', 'NWE', 'SE', 'EA'][$lv % 4]);
    $src['ctier'] = min(3, 1 + intdiv($lv, 12));
    $src['starter'] = array_merge(PFD_CORE, pfd_offer_keys($src['calling'], $src['home'], PFD_KITS[['bold', 'steady', 'kind'][$lv % 3]]));
    $tier = min(3, 1 + intdiv($lv, 10)); $src['slots'] = $lv >= 20 ? 4 : ($lv >= 10 ? 3 : 2);
    foreach (array_slice(['axe', 'till', 'staff', 'lantern'], 0, $src['slots']) as $i => $t) $src['tools'][$t] = max(1, $tier - ($i > 1 ? 1 : 0));
    $src['belt'] = array_keys($src['tools']);
    if ($lv >= 3) $src['pals'][] = ['n' => 'Bark Badger', 't' => 'guard', 'v' => 5 + ($lv >= 12 ? 2 : 0), 'r' => 'craft', 'rank' => $lv >= 12 ? 2 : 1];
    if ($lv >= 8) $src['pals'][] = ['n' => 'Samara Spin', 't' => 'hurt', 'v' => 5 + ($lv >= 20 ? 2 : 0), 'r' => 'body', 'rank' => $lv >= 20 ? 2 : 1];
    foreach (['vegetable' => 2, 'spice' => 10, 'fruit' => 14, 'nut' => 22] as $k => $at) if ($lv >= $at) $src['crops'][$k] = min(3, 1 + intdiv($lv - $at, 12));
    foreach (['garden' => 6, 'potions' => 12, 'tools' => 18] as $k => $at) if ($lv >= $at) $src['crafts'][$k] = 1;
    if ($lv >= 5) $src['regions'][$src['home']] = 1; if ($lv >= 16) $src['regions']['MENA'] = 2;
    $on = 0; foreach (['smash', 'sting', 'lull', 'pierce', 'hum', 'brace'] as $k) if ($on < 3 && $lv >= (int)pfd_catalog()[$k]['ref'] && !in_array($k, $src['starter'], true)) { $src['state'][$k] = true; $on++; }
    return $src;
}
function pp_player(int $lv, bool $old = false): array
{
    $m = max(0, intdiv($lv + 3, 14)); $st = ['grit' => $m, 'nimble' => $m, 'hardiness' => $m, 'charm' => $m, 'lore' => $m, 'luck' => $m, 'level' => $lv];
    if (!$old) {   // the deck model's deck, as the live game and the tuner deal it
        $max = 20 + 3 * $lv + 5 * $m; $src = pp_sources($lv);
        return ['hp' => $max, 'max_hp' => $max, 'stats' => $st, 'deck' => pfd_tiles(pfd_fight_entries($src), $st, [], $src['calling'], $src['ctier']), 'luck' => $m];
    }
    $cals = array_keys(PF_CALLING_TILE); $cal = $cals[$lv % 6]; $own = pf_collection($lv, $cal); $cap = pf_box_capacity($lv);
    $want = ['hurt' => 5, 'charm' => 3, 'guard' => 3, 'heal' => 1, 'trick' => 1, 'item' => 1, 'soothe' => 0]; $box = []; $n = [];
    foreach ($own as $k) { $t = pf_tiles()[$k]['t']; if (($n[$t] ?? 0) < ($want[$t] ?? 0) && count($box) < $cap) { $box[] = $k; $n[$t] = ($n[$t] ?? 0) + 1; } }
    foreach ($own as $k) if (!in_array($k, $box, true) && count($box) < $cap) $box[] = $k;
    $max = 20 + 3 * $lv + 5 * $m;
    return ['hp' => $max, 'max_hp' => $max, 'stats' => $st, 'deck' => pf_player_deck($st, $cal, 1 + intdiv($lv, 12), [], [], [], true, $box), 'luck' => $m, 'calling' => $cal];
}
function pp_e(array $e): string { $o = []; foreach (['L', 'R', 'T', 'B'] as $k) $o[] = $k . ':' . ($e[$k][0] === 'flat' ? 'flat' : ($e[$k][0] === 'wild' ? 'WILD' : $e[$k][0] . '-' . $e[$k][1])); return implode(' ', $o); }
/** 2.7.08 (P7): does your move fire a creature Hurt piece in YOUR chain (before the creature's own turn)? A dry run on a copy. */
function pp_fires_foe_hurt(array $s, array $mv): bool
{
    $r = pfb_play($s, [$mv], $s['turn']); if ($r['err'] !== null) return false; $mine = null;
    foreach ($r['ev'] as $e) { if (!isset($e['id'])) continue; if (!empty($e['root'])) { if ($mine !== null && ($e['by'] ?? '') === 'foe') break; $mine = true; continue; } if (($e['by'] ?? '') === 'foe' && ($e['t'] ?? '') === 'hurt') return true; }
    return false;
}
/** 2.7.08 (P7): the legal set-aside moves as commands: 'JOIN ...' => ['join A B SIDE', ...] while no group is held, 'ADD ...' => ['add B ANC SIDE', ...] while one is (empty when setting aside is out of this fight). */
function pp_aside_moves(array $s): array
{
    $h = $s['me']['hand']; $g = $s['me']['held'] ?? null;
    if (!$g) {
        if (!pfb_v1r($s, 'aside')) return [];
        $l = []; foreach ($h as $a => $ta) foreach ($h as $b => $tb) if ($a !== $b) foreach (PFB_SIDE as $side => [$dx, $dy]) if (pfb_group_fit(['pcs' => [['tile' => $ta, 'x' => 0, 'y' => 0]]], $tb, $dx, $dy) === true) $l[] = "join $a $b $side";
        return ['JOIN (set two hand pieces aside, joined): A = the hand piece that stays, B = the one that joins on SIDE of it' => $l];
    }
    $l = []; foreach ($h as $b => $tb) foreach (pfb_group_options($g, $tb) as [$anc, $side]) $l[] = "add $b $anc $side";
    return ['ADD (put one more hand piece on the group): B = hand index, ANC = the group piece number (#) in the SET-ASIDE line, SIDE = the side of that piece' => $l];
}
/** 2.7.51: the numbers a lit cell cannot show from your own chain alone, each from the real turn played on a copy: 'a' = health you lose from the creature's reply, the poison and the terrain after THIS move (exact: it is the same turn the game plays; a taken aim cell re-aims at full value inside it),
 *  'w' = how an ending move ends: win (it backs off / is won over) or loss (you are out of health), 'dead' = the creature's reply then defeats you, 'miss' = your piece its Evade dodges (from pfb_cell_preview). $hi = hand index or 'c'. */
function pp_cellx(array $s, $hi, bool $flip = false): array
{
    if ($s['over'] || !empty($s['start'])) return [];
    if ($hi === 'c') { if (empty($s['me']['held'])) return []; $cells = pfb_group_spots($s, $s['me']['held']); }
    else {
        if ($flip) { if (!pfb_can_flip($s, (int)$hi)) return []; $t = $s['me']['hand'][(int)$hi]; if (!empty($t['flip'])) unset($t['flip']); else $t['flip'] = true; $s['me']['hand'][(int)$hi] = $t; }
        $tile = $s['me']['hand'][(int)$hi] ?? null; if (!$tile) return []; $cells = pfb_cells($s, $tile, 'me');
    }
    $o = [];
    foreach ($cells as $c) {
        $mv = [$hi === 'c' ? 'c' : (int)$hi, $c[0], $c[1]]; $d = $s; $r = pfb_play($d, [$mv], $s['turn'], null, true); if ($r['err']) continue;
        $f = $s; $fr = pfb_play($f, [$mv], $s['turn']); if ($fr['err']) continue;
        $o[$c[0] . ',' . $c[1]] = ['a' => max(0, (int)$r['hp'] - (int)$f['me']['hp']), 'w' => $r['over'] === 'defeat' ? 'loss' : 'win', 'dead' => !$r['over'] && $f['over'] === 'defeat'];
    }
    return $o;
}
/** The extra marks after a cell's numbers: the exact reply (v1), the Evade miss, how an ending move ends. */
function pp_mx(?array $q, ?array $x, bool $v1): string
{
    if (!$q) return '';
    return ($v1 && $x ? ' a-' . $x['a'] : '') . (!empty($q['miss']) ? ' MISS: Evade dodges ' . $q['miss'] : '') . ($q['end'] ? ' END(' . ($x['w'] ?? 'win') . ')' : '') . (!empty($x['dead']) ? ' YOU-DIE-AFTER' : '');
}
function pp_show(array $s): string
{
    $o = [];
    if (!empty($s['v1']['onebar'])) $o[] = sprintf('BAR %.1f/%.1f (damage %.1f, charm %.1f); fill it to win; the larger share decides: charmed or seen off (bosses are always seen off)', $s['fh']['now'] + $s['bar']['now'], $s['fh']['max'], $s['fh']['now'], $s['bar']['now']);   // 2.6.95: one shared bar
    if (!empty($s['v1']['redraw'])) $o[] = 'Your hand is redrawn every round (what you do not play goes to the discard).';   // 2.6.95
    $o[] = sprintf('TURN %d | you HP %d/%d guard %d | creature guard %d (your Hurt loses this much first) | creature "%s" (%s) %s%s | creature intends: %s%s', min($s['turn'], PF_TURN_CAP), $s['me']['hp'], $s['me']['max'], $s['me']['block'], (int)($s['foe']['block'] ?? 0), $s['foe']['name'], $s['size'],
        !empty($s['v1']['onebar']) ? sprintf('BAR %.1f/%.1f (damage %.1f + charm %.1f; full = it ends: the larger share decides)', $s['fh']['now'] + $s['bar']['now'], $s['fh']['max'], $s['fh']['now'], $s['bar']['now']) : sprintf('DAMAGE %.1f/%.1f (full = it backs off)', $s['fh']['now'], $s['fh']['max']),
        !empty($s['v1']['onebar']) ? '' : ($s['cm'] > 0 ? sprintf(' CHARM %.1f/%.1f (full = won over)', $s['bar']['now'], $s['bar']['max']) : ' (no charm bar)'), $s['foe']['intent'] ?? '-',
        (int)($s['foe']['evade'] ?? 0) > 0 ? ' | CREATURE EVADE is up: the first Hurt you fire this turn MISSES (it lasts until its next turn, even if the piece that gave it is used up or gone)' : '');
    $o[] = sprintf('Multipliers: your Hurt counts x%s on its damage bar, your Charm x%s on its charm bar. Guard shown is what you hold NOW; it resets when your next turn starts, so after the creature moves it reads 0 (it protected you during that move).', $s['hm'], $s['cm']);
    if ($s['over']) $o[] = 'FIGHT OVER: ' . $s['over'] . ($s['over'] === 'defeat' ? ' (LOSS: you are out of health)' : (in_array($s['over'], ['seen_off', 'charmed'], true) ? ' (WIN)' : ''));
    $v1 = !empty($s['v1']); $envm = !empty($s['v1']['env']); $W = pfb_w($s); $H = pfb_h($s); $tm = ['sun' => '*', 'br' => '#', 'mud' => '~', '' => ' '];
    $o[] = 'BOARD (x right, y down; x 0-' . ($W - 1) . ', y 0-' . ($H - 1) . '). Y=your piece, C=creature piece, ?=blank centre' . ($envm ? '. E=environment piece. AIM = where the creature\'s next piece goes' : '') . ($v1 && !$envm ? '. GROUND after a cell: * sunny (Hurt and Charm count double), # bramble (a piece here costs its owner ' . (int)round(100 * $s['v1']['bramble']) . '% health each round), ~ mud (no links). AIM = where the creature\'s next piece goes' : '');
    for ($y = 0; $y < $H; $y++) { $r = ''; for ($x = 0; $x < $W; $x++) { $p = pfb_at($s, $x, $y); $aim = $v1 && ($s['foe']['plan']['x'] ?? -1) === $x && ($s['foe']['plan']['y'] ?? -1) === $y; $r .= ($p ? ($p['by'] === 'me' ? ' Y' : ($p['by'] === 'foe' ? ' C' : ($p['by'] === 'env' ? ' E' : ' ?'))) . $p['id'] : ($aim ? ' AIM' : ' . ')) . ($v1 ? $tm[pfb_ter($s, $x, $y)] : ''); } $o[] = '  ' . $r; }
    if ($v1) {
        if ($envm) {
            $nx = $s['env']['next'] ?? []; $pc = (int)round(100 * $s['v1']['bramble']); $tc = (int)round(100 * $s['v1']['thorn']);
            $o[] = 'ENVIRONMENT (a third player: after the creature\'s move it places its NEXT pieces, in this order, each on a free cell where it fits; nothing fires then; it places nothing while the board is ' . (int)round(100 * ($s['v1']['envcap'] ?? 1)) . '% full). NEXT: ' . ($nx ? implode(', then ', array_map(fn($t) => '"' . $t['n'] . '" (stays ' . $t['life'] . ' rounds; ' . pp_e(pfb_edges($t)) . ')', $nx)) : 'nothing (all its pieces are out)') . ' | ' . count($s['env']['draw']) . ' more in its deck';
            $o[] = 'ENVIRONMENT PIECES link and fire in chains like any piece, count for the chain length and are used up by a chain of ' . (int)$s['v1']['limit'] . '+. The effect goes to the side whose chain fires it: Sun = that side\'s pieces in the chain count x' . $s['v1']['sun'] . '; Bramble = the OTHER side loses ' . $pc . '% of its health; Rain = guard for the firing side (' . (int)round(100 * $s['v1']['rain']) . '% of its health); Wind = the piece its arrow points at slides one cell along the arrow (if that cell is free); Thornburst = you lose ' . $tc . '% if your chain fires it, the creature ' . (int)round($tc * ($s['v1']['th_foe'] ?? 1)) . '% if its chain does; Mud = flat on every side: nothing links to it, it never fires, and a piece standing NEXT TO a Mud counts ' . (int)round(100 * ($s['v1']['mud'] ?? 0)) . '% less when it fires.';
        }
        if (!$envm) $o[] = 'GROUND: ' . (implode(' ', array_map(fn($k, $g) => $k . '=' . ['sun' => 'sunny', 'br' => 'bramble', 'mud' => 'mud'][$g], array_keys($s['ter']), $s['ter'])) ?: 'none');
        if (($kd = pfb_kind($s)) !== '' && isset(PFB_KIND_TEXT[$kd])) $o[] = 'CLASS RULE: ' . PFB_KIND_TEXT[$kd][0] . ': ' . PFB_KIND_TEXT[$kd][1];   // 2.7.01: the creature's class rule, as the page's chip says it
        $aim = $s['foe']['plan'] ?? null; $tot = $aim['tot'] ?? null;
        $o[] = 'CREATURE AIM: ' . ($aim ? sprintf('"%s" %s %d at %d,%d. Taking that cell does NOT stop it: it picks another move at full value (no fumble; it still plays a piece and can still hit; a beast also hits harder for every block: Grudge), so blocking only reroutes the hit. ', $aim['n'], $aim['t'], $aim['v'], $aim['x'], $aim['y'])
            . (is_array($tot) && isset($tot['hp']) ? sprintf('FORECAST on the board as it stands BEFORE your move (%s): if it played this aim right now it would hit you for %d%s%s%s%s. NOT in that number: what YOUR placement changes (a new piece of yours can be fired by its chain, take or block its cell, add guard or Evade), the move it picks instead if you take its cell (Grudge), poison ticking at the end of the round, the terrain. The exact figure for each cell is the a-N mark on it.', 'Quick second piece, Sun, Mud and combos are in', $tot['hp'], $tot['g'] > 0 ? ' (your guard takes ' . $tot['g'] . ' more)' : '', $tot['why'] ? ' (why: ' . implode(', ', $tot['why']) . ')' : '', (float)$tot['bait'] > 0 ? '; your pieces already on the board that its chain fires would raise the damage bar by ' . rtrim(rtrim(number_format((float)$tot['bait'], 1, '.', ''), '0'), '.') : '; none of your pieces on the board are in its chain now (a piece you place this turn can still be fired by it)', $tot['heal'] > 0 ? '; it heals ' . $tot['heal'] : '')
                : 'The number is the piece value only: a Sun in its chain doubles it, Mud beside it cuts 25%, and it can fire pieces already linked.') : 'none shown (it is tripped, or has no move)') . (!empty($s['reaim']) ? ' Last turn it could NOT play its aim and picked again.' : '');
        $what = ['sunbeam' => 'the cell turns sunny (the oldest sunny cell fades)', 'creep' => 'the cell turns to bramble and pricks at once (the oldest bramble withers)', 'puddle' => 'the cell turns to mud (the old mud dries)', 'gust' => 'the piece there is pushed one cell', 'thorn' => 'every piece on it and next to it costs its owner ' . (int)round(100 * $s['v1']['thorn']) . '% health (the creature half)'];
        if (!$envm) $o[] = 'TERRAIN FORECAST (lands at the end of this round, after the creature\'s move): ' . (implode('; ', array_map(fn($e) => PFB_EVENT_NAME[$e['kind']] . ' at ' . $e['x'] . ',' . $e['y'] . ($e['kind'] === 'gust' ? ' toward ' . ['L' => 'left', 'R' => 'right', 'T' => 'up', 'B' => 'down'][$e['dir']] : '') . ': ' . $what[$e['kind']], $s['envs'] ?? [])) ?: 'nothing');
    }
    foreach ($s['pcs'] as $p) if (!($s['over'] && $p['by'] === 'none')) $o[] = sprintf('  piece #%d %s @%d,%d %s "%s" %s %d%s age %d%s (%s)', $p['id'], $p['by'] === 'me' ? 'YOURS' : ($p['by'] === 'foe' ? 'CREATURE' : ($p['by'] === 'env' ? 'ENVIRONMENT' . (isset($p['tile']['dir']) ? ' arrow ' . ['L' => 'left', 'R' => 'right', 'T' => 'up', 'B' => 'down'][$p['tile']['dir']] : '') : 'BLANK')), $p['x'], $p['y'], $p['by'] === 'none' ? '-' : $p['tile']['t'], $p['tile']['n'], $p['tile']['tag'], $p['tile']['v'], ($p['tile']['m'] ?? '') ? ' [' . $p['tile']['m'] . ']' : '', $s['round'] - $p['born'], (pfb_fire_limit($p) > 0 ? ' fires left ' . max(0, pfb_fire_limit($p) - (int)($p['f'] ?? 0)) : '') . ($v1 && $p['by'] !== 'none' ? ' | stays ' . ($p['born'] + pfb_life($s, $p) - $s['round']) . ' round(s), this one included | from: ' . ($p['tile']['src'] ?? '?') . (($p['tile']['layer'] ?? '') !== '' ? ' | layer: ' . $p['tile']['layer'] : '') . (!empty($p['tile']['flip']) ? ' | FLIPPED' : '') : ''), pp_e(pfb_edges($p['tile'])));
    if (!empty($s['start'])) $o[] = 'START PHASE: choose a hand piece and a side of the blank centre (L R T B) with `start`. The creature has already chosen without seeing you.';
    $o[] = 'YOUR HAND (index: name, type, value, tag, edges; legal cells x,y that CONNECT)';
    foreach ($s['me']['hand'] as $i => $t) {
        $cells = !empty($s['start']) ? [] : pfb_cells($s, $t, 'me');
        if ($s['over']) { $o[] = sprintf('  [%d] %s | %s %d | (fight over)', $i, $t['n'], $t['t'], $t['v']); continue; }
        $pv = !empty($s['start']) ? [] : pfb_cell_preview($s, $i);   // 2.6.66: numbers per cell: dmg to creature, charm, health you lose in your own chain, pieces that fire, the creature's reply
        $ax = pp_cellx($s, $i);
        $marks = array_map(function ($c) use ($pv, $ax, $v1) {
            $q = $pv[$c[0] . ',' . $c[1]] ?? null; if (!$q) return $c[0] . ',' . $c[1];
            return $c[0] . ',' . $c[1] . '(d' . $q['dmg'] . ' c' . $q['ch'] . ' h-' . $q['hp'] . ' n' . $q['n'] . (isset($q['rp']) ? ' r-' . $q['rp'] : '') . (!empty($q['used']) ? ' USES-UP' : '') . (($q['tw'] ?? 1) > 1 ? ' TEAM x' . $q['tw'] : '') . (!empty($q['sun']) ? ' SUN' : '') . pp_mx($q, $ax[$c[0] . ',' . $c[1]] ?? null, $v1) . ')';
        }, $cells);
        $fl = '';
        if ($v1 && empty($s['start'])) {   // v1: source, life, and the cells with the piece flipped (your own chain numbers)
            $fl = ' | from: ' . ($t['src'] ?? '?') . ', stays ' . (int)($t['life'] ?? PFB_LIFE) . ' rounds' . (!empty($t['flip']) ? ', FLIPPED' : '');
            if (pfb_can_flip($s, $i)) { $fp = pfb_cell_preview($s, $i, true); $fx = pp_cellx($s, $i, true); $fl .= ' | if you flip it: ' . (implode(' ', array_map(fn($k, $q) => $k . '(d' . $q['dmg'] . ' c' . $q['ch'] . ' h-' . $q['hp'] . ' n' . $q['n'] . (!empty($q['used']) ? ' USES-UP' : '') . (($q['tw'] ?? 1) > 1 ? ' TEAM x' . $q['tw'] : '') . (!empty($q['sun']) ? ' SUN' : '') . pp_mx($q, $fx[$k] ?? null, true) . ')', array_keys($fp), $fp)) ?: 'no cells'); }
            elseif (isset($t['ed']) && !$s['over']) $fl .= ' | flip: already used on another piece this turn (flip that one again to take it back)';
        }
        $o[] = sprintf('  [%d] %s | %s %d | %s%s | %s | cells: %s%s', $i, $t['n'], $t['t'], $t['v'], $t['tag'], ($t['m'] ?? '') ? ' [' . $t['m'] . ']' : '', pp_e(pfb_edges($t)), $marks ? implode(' ', $marks) : 'none', $fl);
    }
    if (!empty($s['me']['held'])) {   // 2.7.08 (P7): numbered group pieces (ANC for `add`), numbers per spot as for a hand piece, ! = your chain there fires a creature Hurt piece
        $g = $s['me']['held']; $pv = $s['over'] ? [] : pfb_cell_preview($s, 'c'); $gx = pp_cellx($s, 'c');
        $o[] = 'SET-ASIDE GROUP (' . count($g['pcs']) . ' pieces): ' . implode(' + ', array_map(fn($i, $p) => '#' . $i . ' ' . $p['tile']['n'] . '@' . $p['x'] . ',' . $p['y'], array_keys($g['pcs']), $g['pcs'])) . ' | places at top-left x,y in: '
            . (implode(' ', array_map(function ($c) use ($s, $pv, $gx) { $k = $c[0] . ',' . $c[1]; $q = $pv[$k] ?? null; return $k . ($q ? '(d' . $q['dmg'] . ' c' . $q['ch'] . ' h-' . $q['hp'] . ' n' . $q['n'] . (isset($q['rp']) ? ' r-' . $q['rp'] : '') . (pp_fires_foe_hurt($s, ['c', $c[0], $c[1]]) ? ' !' : '') . pp_mx($q, $gx[$k] ?? null, !empty($s['v1'])) . ')' : ''); }, pfb_group_spots($s, $g))) ?: 'none') . ' (! = your chain there fires a creature Hurt piece)';
    }
    if (!$s['over'] && empty($s['start'])) foreach (pp_aside_moves($s) as $k => $l) $o[] = $k . ': ' . ($l ? implode(', ', $l) : 'none');
    if ($v1) $o[] = 'Per cell (d damage to the creature, c charm gained, h NET health you lose in your own chain (a heal piece or Rain cancels what Thornburst takes, so h-0 can hide a loss), n pieces that fire; USES-UP = the chain fires ' . (int)$s['v1']['limit'] . '+ pieces, so every piece that fired leaves the board; TEAM = Teamwork bonus; SUN = fires on a sunny cell; a-N = EXACT health you lose from the creature\'s reply, poison and terrain after that move (the same turn the game plays, on a copy); MISS: Evade = that placed or chained piece of yours is dodged and the numbers already leave it out; END(win) / END(loss) = the fight ends that way; YOU-DIE-AFTER = the creature\'s reply then defeats you). Rules: one action a turn (a flip is free, once a turn). A piece must make a linked joint (knob into hole of the same family) unless nothing can. Every round: you, the creature, then the terrain (events land, bramble pricks, old pieces expire). Pal, tool and crop pieces of yours in one chain: 2 kinds +30%, all 3 +60%. Draw pile ' . count($s['me']['draw']) . ', discard ' . count($s['me']['discard']) . '.';
    else $o[] = 'Per cell (d damage to the creature, c charm gained, h NET health you lose in your own chain (a heal piece or Rain cancels what Thornburst takes, so h-0 can hide a loss), n pieces that fire, r health the creature reply takes next; END = the fight ends). Rules: one action a turn. A piece must make a linked joint (knob into hole of same family) unless nothing can. Flat edge fits anything but breaks the chain. Pieces expire after ' . PFB_LIFE . ' rounds. Draw pile ' . count($s['me']['draw']) . ', discard ' . count($s['me']['discard']) . '.';
    return implode("\n", $o);
}
/** 2.7.51: a replacement for the generic env line in the harness: in the one-bar fights a hit on the creature raises the damage bar, it does not lower anything. */
function pp_envtxt(string $l): string { return preg_replace('/the creature loses (\d+)/', 'the damage bar rises by $1', $l); }
/** 2.7.51: what the event line cannot say alone: the class rule (Grudge, Swarm) that raised a creature Hurt, the guard / Evade / Soothe that cut it, and the effect of Lull, Trip, Hum, Soothe pieces of yours. */
function pp_ann(array $e): string
{
    $o = ''; $foe = ($e['by'] ?? '') === 'foe'; $t = $e['t'] ?? ''; $tag = $e['tag'] ?? '';
    if ($foe && $t === 'hurt') {
        if (!empty($e['gr'])) $o .= ' GRUDGE x' . (int)$e['gr'] . ' (class rule: you blocked its aim ' . (int)$e['gr'] . ' time(s), so this Hurt is harder)';
        if (!empty($e['sw'])) $o .= ' SWARM +' . (int)$e['sw'] . ' (class rule: its other pieces on the board)';
        if (!empty($e['amb'])) $o .= ' AMBUSH';
        if ($tag === 'pierce') $o .= ' PIERCE (ignores your guard)';
        if ((int)($e['soothed'] ?? 0) > 0) $o .= ' (SOOTHED -' . (int)$e['soothed'] . ': a Soothe / Hum / Lull of yours cut this Hurt)';
        if (isset($e['evaded']) && (int)$e['evaded'] > 0) $o .= ' (MISSED: your Evade dodged it, no damage)';
        elseif ((int)($e['blocked'] ?? 0) > 0) $o .= ' (' . (int)$e['blocked'] . ' blocked by your guard)';
        if (isset($e['dmg'])) $o .= ' => you take ' . (int)$e['dmg'];
    }
    if (!$foe && ($e['by'] ?? '') === 'me' && empty($e['tick'])) {
        if ($t === 'soothe') $o .= ' (SOOTHE: cuts its next Hurt(s) this turn by up to ' . (int)($e['v'] ?? 0) . ' in all)';
        if ($tag === 'lull') $o .= ' (LULL: it loses its next play)';
        if ($tag === 'hum') $o .= ' (HUM: its next Hurt is cut by 2)';
        if ($tag === 'trip' && $t === 'hurt') $o .= ' (TRIP: it loses its next play)';
    }
    return $o;
}
function pp_events(array $ev, ?array $before = null): string
{
    $slowSrc = []; foreach ($ev as $e0) if (($e0['by'] ?? '') === 'me' && empty($e0['tick']) && !isset($e0['note']) && (($e0['tag'] ?? '') === 'lull' || ($e0['tag'] ?? '') === 'trip')) $slowSrc[] = ($e0['tag'] === 'lull' ? 'Lull "' : 'Trip "') . $e0['n'] . '"';
    $o = []; $dl = []; $pf = $before['fh'] ?? null; $pb = $before['bar'] ?? null; $ph = $before['hp'] ?? null;
    foreach ($ev as $e) { $at = count($o); if ($pf !== null && isset($e['barnow'])) { $d = []; if (abs($e['fhnow'] - $pf) > 0.049) $d[] = sprintf('damage bar %+.1f', $e['fhnow'] - $pf); if (abs($e['barnow'] - $pb) > 0.049) $d[] = sprintf('charm bar %+.1f', $e['barnow'] - $pb); if ($e['hpnow'] != $ph) $d[] = sprintf('your hp %+d', $e['hpnow'] - $ph); $pf = $e['fhnow']; $pb = $e['barnow']; $ph = $e['hpnow']; if ($d) $dl[$at] = ' [real change: ' . implode(', ', $d) . ']'; } if (isset($e['env'])) { $o[] = (($e['env'] ?? '') === 'fire' ? '  ENVIRONMENT PIECE (chain, for ' . ($e['for'] === 'me' ? 'you' : 'the creature') . ') ' : (in_array($e['env'], ['place', 'pass', 'expire'], true) ? '  ENVIRONMENT TURN: ' : '  TERRAIN ')) . preg_replace('/^[^A-Za-z]+/', '', pp_envtxt(pfb_env_line($e, 'creature'))) . sprintf(' -> damage bar %.1f, charm bar %.1f, your hp %d', $e['fhnow'], $e['barnow'], $e['hpnow']); continue; } if (!empty($e['tick'])) { $o[] = sprintf('  POISON tick on the creature: +%d damage (no piece)', $e['v'] ?? 0); continue; } if (isset($e['note'])) { $nn = (string)($e['n'] ?? ''); $o[] = '  ' . (['fade' => "YOUR GUARD: $nn guard ran out at the start of your turn (it fades unless a Hold keeps it)", 'hold' => "YOUR GUARD: $nn guard held (Hold)", 'quick' => 'CREATURE QUICK: ' . ($nn !== '' ? "plays \"$nn\"" : 'plays') . ' again (an extra play this round)', 'slow' => 'CREATURE SLOW: it loses its play this round' . ($slowSrc ? ' (from your ' . implode(' and your ', $slowSrc) . ')' : ' (no Lull or Trip of yours fired this turn: it comes from an effect already on it)'), 'venom' => 'CLASS RULE Venom trail: your "' . $nn . '" was put on a venom cell: you are poisoned (2 a round, 2 rounds)', 'current' => 'CLASS RULE Current: one of your pieces next to its new piece "' . $nn . '" slides a cell away', 'grows' => 'CLASS RULE Grows: a Bramble grows beside its "' . $nn . '"', 'trip' => 'TRIP: you draw one fewer piece next turn', 'palaim' => 'PAL AIM: your pal knocks the creature\'s piece "' . $nn . '" off the board'][$e['note']] ?? ('NOTE ' . $e['note'] . ' ' . $nn)); continue; } if (isset($e['connect'])) { $o[] = '  you set aside: ' . $e['n']; continue; } $o[] = sprintf('  %s %s "%s" %s %d%s%s', ($e['by'] ?? '?') === 'me' ? 'YOU' : 'CREATURE', !empty($e['root']) ? 'PLACED' : 'chain', $e['n'] ?? ($e['tag'] ?? ''), $e['t'] ?? '', $e['v'] ?? 0, (!empty($e['combo']) ? ' COMBO ' . $e['combo'] : '') . (!empty($e['sun']) ? ' SUN x2' : '') . (!empty($e['mud']) ? ' MUD -25%' : '') . (isset($e['tw']) ? ' TEAMWORK x' . $e['tw'] : '') . (($e['by'] ?? '') === 'me' && ($e['t'] ?? '') === 'hurt' && (int)($e['blocked'] ?? 0) > 0 ? ' (' . (int)$e['blocked'] . ' blocked by its guard)' : '') . (($e['by'] ?? '') === 'me' && ($e['t'] ?? '') === 'hurt' && (int)($e['evaded'] ?? 0) > 0 ? ' (MISSED: its Evade dodged this Hurt, no damage)' : '') . pp_ann($e) . (!empty($e['used']) ? ' [this chain USES UP ' . count($e['used']) . ' pieces]' : ''), isset($e['barnow']) ? sprintf(' -> damage bar %.1f, charm bar %.1f, your hp %d', $e['fhnow'], $e['barnow'], $e['hpnow']) : ''); }
    foreach ($dl as $i => $t) if (isset($o[$i])) $o[$i] .= $t;
    return implode("\n", $o);
}
function pp_save(string $f, array $s, string $act, array $ev, ?string $err): void
{
    if ($err === null) file_put_contents($f, json_encode($s));
    $line = ['t' => time(), 'act' => $act, 'err' => $err, 'turn' => $s['turn'], 'hp' => $s['me']['hp'], 'fh' => round($s['fh']['now'], 1), 'bar' => round($s['bar']['now'], 1), 'over' => $s['over'],
        'chain' => count(array_filter($ev, fn($e) => isset($e['id']))), 'combos' => array_values(array_filter(array_map(fn($e) => $e['combo'] ?? null, $ev))), 'mode' => !empty($s['start']) ? 'start' : 'play'];
    file_put_contents($f . '.log', json_encode($line) . "\n", FILE_APPEND);
}
function pp_int($v, int $min, int $max, string $what): int
{
    if ($v === null || !preg_match('/^-?\d+$/', (string)$v)) { echo "REFUSED: need a whole number for $what\n(nothing changed)\n"; exit(2); }
    $n = (int)$v; if ($n < $min || $n > $max) { echo "REFUSED: $what must be $min..$max\n(nothing changed)\n"; exit(2); }
    return $n;
}
function pp_side($v): string { $v = strtoupper((string)$v); if (!in_array($v, ['L', 'R', 'T', 'B'], true)) { fwrite(STDERR, "side must be L, R, T or B\n"); exit(1); } return $v; }
[, $cmd, $f] = $argv + [null, null, null];
if ($cmd === 'list') { $n = (int)($f ?? 200); foreach (array_slice(pp_creatures(), 0, $n) as $c) echo "{$c['slug']} {$c['size']} L{$c['level']}\n"; exit; }
if ($cmd === 'new') {
    $slug = $argv[3] ?? ''; $lv = pp_int($argv[4] ?? null, 1, 100, 'LEVEL'); $seed = pp_int($argv[5] ?? null, 0, PHP_INT_MAX, 'SEED'); $mode = $argv[6] ?? 'classic'; $all = pp_creatures();
    if (!in_array($mode, ['classic', 'blank', 'v1', 'v1classic', 'v1old'], true)) { fwrite(STDERR, "mode must be classic, blank, v1, v1classic or v1old\n"); exit(1); }
    if (!isset($all[$slug])) { fwrite(STDERR, "unknown creature (use list)\n"); exit(1); }
    $old = in_array('old', [$argv[8] ?? '', $argv[9] ?? ''], true); $build = 'std'; foreach ([$argv[8] ?? '', $argv[9] ?? ''] as $x) { if (in_array($x, PB_BUILDS, true)) $build = $x; elseif ($x !== '' && $x !== 'old') { fwrite(STDERR, "arg 8/9 must be old or a BUILD (std, pals, norare)\n"); exit(1); } }
    if ($old && $build !== 'std') { fwrite(STDERR, "BUILD (std|pals|norare) does not combine with old\n"); exit(1); } $reg = (string)($argv[7] ?? ''); $keys = array_keys(pfd_region_pieces());
    $cr = $old ? $all[$slug] + ['region' => $reg] : pfd_foe_row($all[$slug], $reg !== '' ? $reg : $keys[(crc32($slug) + $seed) % 14]) + ['region' => $reg];
    $s = pfb_new($build !== 'std' ? pb_player($lv, $build) : pp_player($lv, $old), $cr, $seed, ['blank' => in_array($mode, ['blank', 'v1', 'v1old'], true), 'v1' => $mode === 'v1old' ? ['env' => 0, 'ground' => 1, 'events' => 1] : str_starts_with($mode, 'v1')]);
    file_put_contents($f, json_encode($s)); @unlink($f . '.log'); echo ($old ? '' : 'REGION: ' . ($reg !== '' ? $reg : $keys[(crc32($slug) + $seed) % 14]) . " (it leans the environment's deck)\n") . pp_show($s) . "\n"; exit;
}
if (!$f || !is_file($f)) { fwrite(STDERR, "no state file\n"); exit(1); }
$s = json_decode(file_get_contents($f), true); $before = ['fh' => $s['fh']['now'] ?? 0, 'bar' => $s['bar']['now'] ?? 0, 'hp' => $s['me']['hp'] ?? 0]; $a = array_slice($argv, 3); $ev = []; $err = null;
switch ($cmd) {
    case 'show': echo pp_show($s) . "\n"; exit;
    case 'start': $err = $s['over'] ? 'The fight is over.' : pfb_start($s, pp_int($a[0] ?? null, 0, 99, 'HANDIDX'), pp_side($a[1] ?? null)); break;
    case 'place': $hi = pp_int($a[0] ?? null, 0, 99, 'HANDIDX'); $px = pp_int($a[1] ?? null, -99, 99, 'X'); $py = pp_int($a[2] ?? null, -99, 99, 'Y');
        if (!$s['over'] && empty($s['start'])) { $pe = !isset($s['me']['hand'][$hi]) ? 'No such piece in your hand.' : ($px < 0 || $py < 0 || $px >= pfb_w($s) || $py >= pfb_h($s) ? 'That cell is off the board (x 0-' . (pfb_w($s) - 1) . ', y 0-' . (pfb_h($s) - 1) . ').' : (pfb_at($s, $px, $py) ? 'That cell is taken by piece #' . pfb_at($s, $px, $py)['id'] . '.' : null)); if ($pe !== null) { pp_save($f, $s, 'place ' . implode(' ', $a), [], $pe); echo "REFUSED: $pe\n(nothing changed)\n"; exit(2); } }
        $r = pfb_play($s, [[pp_int($a[0] ?? null, 0, 99, 'HANDIDX'), pp_int($a[1] ?? null, -99, 99, 'X'), pp_int($a[2] ?? null, -99, 99, 'Y')]], $s['turn']); break;
    case 'join': case 'add': case 'group':   // 2.6.95: setting aside is out of a new fight (a group already held can still be added to and played)
        if (!pfb_v1r($s, 'aside') && empty($s['me']['held'])) { echo "REFUSED: Not in this fight.\n(nothing changed)\n"; exit(2); }
        if ($cmd === 'join') $r = pfb_play($s, [['j', pp_int($a[0] ?? null, 0, 99, 'A'), pp_int($a[1] ?? null, 0, 99, 'B'), pp_side($a[2] ?? null)]], $s['turn']);
        elseif ($cmd === 'add') $r = pfb_play($s, [['h', pp_int($a[0] ?? null, 0, 99, 'B'), pp_int($a[1] ?? null, 0, 99, 'ANC'), pp_side($a[2] ?? null)]], $s['turn']);
        else $r = pfb_play($s, [['c', pp_int($a[0] ?? null, -99, 99, 'X'), pp_int($a[1] ?? null, -99, 99, 'Y')]], $s['turn']); break;
    case 'pass': $r = pfb_pass($s, $s['turn']); break;
    case 'flip': $err = pfb_flip($s, pp_int($a[0] ?? null, 0, 99, 'HANDIDX'), $s['turn']); if ($err === null) { pp_save($f, $s, 'flip ' . implode(' ', $a), [], null); echo "FLIPPED (free; the turn goes on):\n\n" . pp_show($s) . "\n"; exit; } break;
    default: fwrite(STDERR, "unknown command\n"); exit(1);
}
if (isset($r)) { $ev = $r['ev']; $err = $r['err']; }
if ($err !== null) { pp_save($f, $s, $cmd . ' ' . implode(' ', $a), [], $err); $help = ['join' => 'join A B SIDE: A and B are hand indexes, B joins on SIDE (L R T B) of A. ', 'add' => 'add B ANC SIDE: B is a hand index, ANC = the group piece number (#) in the SET-ASIDE line, SIDE = the side (L R T B) of that piece. '][$cmd] ?? null;
    if ($help !== null) { $l = pp_aside_moves($s); $help .= 'Legal now: ' . (($l ? implode(', ', reset($l)) : '') ?: 'none'); }
    echo "REFUSED: $err\n" . ($help !== null ? "HELP: $help\n" : '') . "(nothing changed)\n"; exit(2); }
pp_save($f, $s, $cmd . ' ' . implode(' ', $a), $ev, null);
if ($cmd === 'start') { $cx = (int)($s['pcs'][1]['x'] ?? intdiv(pfb_w($s), 2)); $cy = (int)($s['pcs'][1]['y'] ?? intdiv(pfb_h($s), 2)); $sd = ['-1,0' => 'L', '1,0' => 'R', '0,-1' => 'T', '0,1' => 'B']; $o = [];
    foreach ($s['pcs'] as $p) if ($p['by'] !== 'none') $o[] = ($p['by'] === 'me' ? 'YOU' : 'CREATURE') . ' put "' . $p['tile']['n'] . '" (' . $p['tile']['t'] . ' ' . $p['tile']['v'] . ') on side ' . ($sd[($p['x'] - $cx) . ',' . ($p['y'] - $cy)] ?? '?');
    $ev = []; echo "START (nothing fires; turn 1 is your next action; the blank vanishes at the end of turn 1):\n  " . implode("\n  ", $o) . "\n\n" . pp_show($s) . "\n"; exit; }
$notes = [];
if (!empty($s['cut'])) $notes[] = 'CHAIN STOPPED: the fight ended mid-chain; ' . $s['cut'] . ' linked piece(s) did not fire.';
$usedUp = array_filter($s['gone'] ?? [], fn($g) => isset($g['used'])); if ($usedUp) $notes[] = 'USED UP (a chain of 3 or more spends every piece that fired; they go to the discard): ' . implode(', ', array_map(fn($g) => ($g['by'] === 'me' ? 'yours ' : ($g['by'] === 'env' ? 'environment ' : 'creature ')) . '"' . $g['tile']['n'] . '" (by ' . ($g['used'] === 'me' ? 'your' : "the creature's") . ' chain)', $usedUp)) . '.';
$fell = array_filter($s['gone'] ?? [], fn($g) => !empty($g['fell']) && !isset($g['used'])); $exp = array_filter($s['gone'] ?? [], fn($g) => empty($g['fell']) && $g['by'] !== 'none');
if ($fell) $notes[] = 'FELL AWAY (a creature piece goes after it has fired twice; your Heavy piece after one swing): ' . implode(', ', array_map(fn($g) => ($g['by'] === 'me' ? 'yours "' : 'creature "') . $g['tile']['n'] . '"', $fell)) . '.';
if (array_filter($s['gone'] ?? [], fn($g) => $g['by'] === 'none')) $notes[] = 'The blank centre is gone (turn 1 is over).';   // 2.7.08 (P7): never listed as a creature piece
if ($exp) $notes[] = 'EXPIRED at the end of the round (' . (!empty($s['v1']) ? 'its rounds are up' : '3 rounds old') . '): ' . implode(', ', array_map(fn($g) => ($g['by'] === 'me' ? 'yours ' : ($g['by'] === 'env' ? 'environment ' : 'creature ')) . '"' . $g['tile']['n'] . '"', $exp)) . '.';
if (!empty($s['reshuf'])) $notes[] = 'RESHUFFLE: ' . implode(' and ', array_unique(array_map(fn($w) => $w === 'me' ? 'your' : "the creature's", $s['reshuf']))) . ' draw pile was refilled from its discard.';
echo "WHAT HAPPENED:\n" . pp_events($ev, $before) . ($notes ? "\n" . implode("\n", array_map(fn($n) => '  ' . $n, $notes)) : '') . "\n\n" . pp_show($s) . "\n";
