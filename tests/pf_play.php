<?php
// Puzzle fight BOARD playtest harness for agents and bots (no DB, no server, no browser).
//   php tests/pf_play.php new STATE CREATURE_SLUG LEVEL SEED [classic|blank|v1|v1classic|v1old] [REGION] [old]   start a fight (the real layered creature deck and the deck-model player deck; arg 8 `old` = the archetype creature deck and the stage A player deck) (blank = blank wild centre + hidden start; v1 = the v1 board rules with the blank opening and ENVIRONMENT PIECES (2.6.75); v1old = the 2.6.74 ground and events; REGION = a region code, it leans the environment's deck)
//   php tests/pf_play.php flip STATE HANDIDX              (v1 only) flip a hand piece: swap its top and bottom edges. Free, once a turn; flip the same piece again to take it back
//   php tests/pf_play.php show STATE                                           the board, your hand and every legal cell
//   php tests/pf_play.php start STATE HANDIDX SIDE        (blank only) hidden start piece next to the centre: SIDE = L R T B
//   php tests/pf_play.php place STATE HANDIDX X Y         play one hand piece
//   php tests/pf_play.php join STATE A B SIDE              set hand piece B aside joined to hand piece A (B on A's SIDE), no effect
//   php tests/pf_play.php add STATE B ANC SIDE             add hand piece B to the set-aside group, onto group piece ANC's SIDE
//   php tests/pf_play.php group STATE X Y                  play the set-aside group, top-left at X,Y
//   php tests/pf_play.php pass STATE                       only when nothing fits anywhere
//   php tests/pf_play.php list [N]                         creatures (slug, size, level)
// STATE is a json file. Every action is appended to STATE.log (one json line each) for data. The creature's hand and the draw pile are never shown.
require __DIR__ . '/../game/includes/pfboard.php';
require __DIR__ . '/../game/includes/pfdeck.php';
$die = ['small' => 4, 'medium' => 6, 'large' => 8, 'boss' => 10];
function pp_creatures(): array
{
    global $die; $o = [];
    foreach (file(__DIR__ . '/../game/includes/data/creatures.txt', FILE_IGNORE_NEW_LINES) as $l) {
        if ($l === '' || $l[0] === '#') continue; $c = explode('|', $l); if (count($c) < 7) continue;
        $lv = max(1, (int)$c[4]); $o[$c[0]] = ['slug' => $c[0], 'name' => $c[1], 'size' => $c[2], 'level' => $lv, 'dmg_die' => $die[$c[2]] ?? 6, 'dmg_bonus' => intdiv($lv, 4)];
    }
    return $o;
}
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
function pp_show(array $s): string
{
    $o = [];
    $o[] = sprintf('TURN %d | you HP %d/%d guard %d | creature "%s" (%s) DAMAGE %.1f/%.1f (full = it backs off)%s | creature intends: %s', min($s['turn'], PF_TURN_CAP), $s['me']['hp'], $s['me']['max'], $s['me']['block'], $s['foe']['name'], $s['size'], $s['fh']['now'], $s['fh']['max'], $s['cm'] > 0 ? sprintf(' CHARM %.1f/%.1f (full = won over)', $s['bar']['now'], $s['bar']['max']) : ' (no charm bar)', $s['foe']['intent'] ?? '-');
    $o[] = sprintf('Multipliers: your Hurt counts x%s on its damage bar, your Charm x%s on its charm bar. Guard shown is what you hold NOW; it resets when your next turn starts, so after the creature moves it reads 0 (it protected you during that move).', $s['hm'], $s['cm']);
    if ($s['over']) $o[] = 'FIGHT OVER: ' . $s['over'];
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
        $aim = $s['foe']['plan'] ?? null;
        $o[] = 'CREATURE AIM: ' . ($aim ? sprintf('"%s" %s %d at %d,%d. Take the cell and it has to pick again (no penalty for it). The number is the piece value only: a Sun in its chain doubles it, Mud beside it cuts 25%%, and it can fire pieces already linked.', $aim['n'], $aim['t'], $aim['v'], $aim['x'], $aim['y']) : 'none shown (it is tripped, or has no move)') . (!empty($s['reaim']) ? ' Last turn it could NOT play its aim and picked again.' : '');
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
        $marks = array_map(function ($c) use ($pv) {
            $q = $pv[$c[0] . ',' . $c[1]] ?? null; if (!$q) return $c[0] . ',' . $c[1];
            return $c[0] . ',' . $c[1] . '(d' . $q['dmg'] . ' c' . $q['ch'] . ' h-' . $q['hp'] . ' n' . $q['n'] . (isset($q['rp']) ? ' r-' . $q['rp'] : '') . (!empty($q['used']) ? ' USES-UP' : '') . (($q['tw'] ?? 1) > 1 ? ' TEAM x' . $q['tw'] : '') . (!empty($q['sun']) ? ' SUN' : '') . ($q['end'] ? ' END' : '') . ')';
        }, $cells);
        $fl = '';
        if ($v1 && empty($s['start'])) {   // v1: source, life, and the cells with the piece flipped (your own chain numbers)
            $fl = ' | from: ' . ($t['src'] ?? '?') . ', stays ' . (int)($t['life'] ?? PFB_LIFE) . ' rounds' . (!empty($t['flip']) ? ', FLIPPED' : '');
            if (pfb_can_flip($s, $i)) { $fp = pfb_cell_preview($s, $i, true); $fl .= ' | if you flip it: ' . (implode(' ', array_map(fn($k, $q) => $k . '(d' . $q['dmg'] . ' c' . $q['ch'] . ' h-' . $q['hp'] . ' n' . $q['n'] . (!empty($q['used']) ? ' USES-UP' : '') . (($q['tw'] ?? 1) > 1 ? ' TEAM x' . $q['tw'] : '') . (!empty($q['sun']) ? ' SUN' : '') . ($q['end'] ? ' END' : '') . ')', array_keys($fp), $fp)) ?: 'no cells'); }
            elseif (isset($t['ed']) && !$s['over']) $fl .= ' | flip: already used on another piece this turn (flip that one again to take it back)';
        }
        $o[] = sprintf('  [%d] %s | %s %d | %s%s | %s | cells: %s%s', $i, $t['n'], $t['t'], $t['v'], $t['tag'], ($t['m'] ?? '') ? ' [' . $t['m'] . ']' : '', pp_e(pfb_edges($t)), $marks ? implode(' ', $marks) : 'none', $fl);
    }
    if (!empty($s['me']['held'])) { $g = $s['me']['held']; $o[] = 'SET-ASIDE GROUP (' . count($g['pcs']) . ' pieces): ' . implode(' + ', array_map(fn($p) => $p['tile']['n'] . '@' . $p['x'] . ',' . $p['y'], $g['pcs'])) . ' | places at top-left x,y in: ' . (implode(' ', array_map(fn($c) => $c[0] . ',' . $c[1], pfb_group_spots($s, $g))) ?: 'none'); }
    if ($v1) $o[] = 'Per cell (d damage to the creature, c charm gained, h NET health you lose in your own chain (a heal piece or Rain cancels what Thornburst takes, so h-0 can hide a loss), n pieces that fire; USES-UP = the chain fires ' . (int)$s['v1']['limit'] . '+ pieces, so every piece that fired leaves the board; TEAM = Teamwork bonus; SUN = fires on a sunny cell; END = the fight ends). No reply number: read the creature\'s AIM. Rules: one action a turn (a flip is free, once a turn). A piece must make a linked joint (knob into hole of the same family) unless nothing can. Every round: you, the creature, then the terrain (events land, bramble pricks, old pieces expire). Pal, tool and crop pieces of yours in one chain: 2 kinds +30%, all 3 +60%. Draw pile ' . count($s['me']['draw']) . ', discard ' . count($s['me']['discard']) . '.';
    else $o[] = 'Per cell (d damage to the creature, c charm gained, h NET health you lose in your own chain (a heal piece or Rain cancels what Thornburst takes, so h-0 can hide a loss), n pieces that fire, r health the creature reply takes next; END = the fight ends). Rules: one action a turn. A piece must make a linked joint (knob into hole of same family) unless nothing can. Flat edge fits anything but breaks the chain. Pieces expire after ' . PFB_LIFE . ' rounds. Draw pile ' . count($s['me']['draw']) . ', discard ' . count($s['me']['discard']) . '.';
    return implode("\n", $o);
}
function pp_events(array $ev, ?array $before = null): string
{
    $o = []; $dl = []; $pf = $before['fh'] ?? null; $pb = $before['bar'] ?? null; $ph = $before['hp'] ?? null;
    foreach ($ev as $e) { $at = count($o); if ($pf !== null && isset($e['barnow'])) { $d = []; if (abs($e['fhnow'] - $pf) > 0.049) $d[] = sprintf('creature health %+.1f', $e['fhnow'] - $pf); if (abs($e['barnow'] - $pb) > 0.049) $d[] = sprintf('charm %+.1f', $e['barnow'] - $pb); if ($e['hpnow'] != $ph) $d[] = sprintf('your hp %+d', $e['hpnow'] - $ph); $pf = $e['fhnow']; $pb = $e['barnow']; $ph = $e['hpnow']; if ($d) $dl[$at] = ' [real change: ' . implode(', ', $d) . ']'; } if (isset($e['env'])) { $o[] = (($e['env'] ?? '') === 'fire' ? '  ENVIRONMENT PIECE (chain, for ' . ($e['for'] === 'me' ? 'you' : 'the creature') . ') ' : (in_array($e['env'], ['place', 'pass', 'expire'], true) ? '  ENVIRONMENT TURN: ' : '  TERRAIN ')) . preg_replace('/^[^A-Za-z]+/', '', pfb_env_line($e, 'creature')) . sprintf(' -> health %.1f charm %.1f hp %d', $e['fhnow'], $e['barnow'], $e['hpnow']); continue; } if (!empty($e['tick'])) { $o[] = sprintf('  POISON tick on the creature: +%d damage (no piece)', $e['v'] ?? 0); continue; } if (isset($e['note'])) { $nn = (string)($e['n'] ?? ''); $o[] = '  ' . ['fade' => "YOUR GUARD: $nn guard ran out at the start of your turn (it fades unless a Hold keeps it)", 'hold' => "YOUR GUARD: $nn guard held (Hold)", 'quick' => 'CREATURE QUICK: ' . ($nn !== '' ? "plays \"$nn\"" : 'plays') . ' again (an extra play this round)', 'slow' => 'CREATURE SLOW: it loses its play this round', 'trip' => 'TRIP: you draw one fewer piece next turn'][$e['note']] ?? ('NOTE ' . $e['note'] . ' ' . $nn); continue; } if (isset($e['connect'])) { $o[] = '  you set aside: ' . $e['n']; continue; } $o[] = sprintf('  %s %s "%s" %s %d%s%s', ($e['by'] ?? '?') === 'me' ? 'YOU' : 'CREATURE', !empty($e['root']) ? 'PLACED' : 'chain', $e['n'] ?? ($e['tag'] ?? ''), $e['t'] ?? '', $e['v'] ?? 0, (!empty($e['combo']) ? ' COMBO ' . $e['combo'] : '') . (!empty($e['sun']) ? ' SUN x2' : '') . (!empty($e['mud']) ? ' MUD -25%' : '') . (isset($e['tw']) ? ' TEAMWORK x' . $e['tw'] : '') . (!empty($e['used']) ? ' [this chain USES UP ' . count($e['used']) . ' pieces]' : ''), isset($e['barnow']) ? sprintf(' -> health %.1f charm %.1f hp %d', $e['fhnow'], $e['barnow'], $e['hpnow']) : ''); }
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
    $old = ($argv[8] ?? '') === 'old'; $reg = (string)($argv[7] ?? ''); $keys = array_keys(pfd_region_pieces());
    $cr = $old ? $all[$slug] + ['region' => $reg] : pfd_foe_row($all[$slug], $reg !== '' ? $reg : $keys[(crc32($slug) + $seed) % 14]) + ['region' => $reg];
    $s = pfb_new(pp_player($lv, $old), $cr, $seed, ['blank' => in_array($mode, ['blank', 'v1', 'v1old'], true), 'v1' => $mode === 'v1old' ? ['env' => 0, 'ground' => 1, 'events' => 1] : str_starts_with($mode, 'v1')]);
    file_put_contents($f, json_encode($s)); @unlink($f . '.log'); echo pp_show($s) . "\n"; exit;
}
if (!$f || !is_file($f)) { fwrite(STDERR, "no state file\n"); exit(1); }
$s = json_decode(file_get_contents($f), true); $before = ['fh' => $s['fh']['now'] ?? 0, 'bar' => $s['bar']['now'] ?? 0, 'hp' => $s['me']['hp'] ?? 0]; $a = array_slice($argv, 3); $ev = []; $err = null;
switch ($cmd) {
    case 'show': echo pp_show($s) . "\n"; exit;
    case 'start': $err = $s['over'] ? 'The fight is over.' : pfb_start($s, pp_int($a[0] ?? null, 0, 99, 'HANDIDX'), pp_side($a[1] ?? null)); break;
    case 'place': $hi = pp_int($a[0] ?? null, 0, 99, 'HANDIDX'); $px = pp_int($a[1] ?? null, -99, 99, 'X'); $py = pp_int($a[2] ?? null, -99, 99, 'Y');
        if (!$s['over'] && empty($s['start'])) { $pe = !isset($s['me']['hand'][$hi]) ? 'No such piece in your hand.' : ($px < 0 || $py < 0 || $px >= pfb_w($s) || $py >= pfb_h($s) ? 'That cell is off the board (x 0-' . (pfb_w($s) - 1) . ', y 0-' . (pfb_h($s) - 1) . ').' : (pfb_at($s, $px, $py) ? 'That cell is taken by piece #' . pfb_at($s, $px, $py)['id'] . '.' : null)); if ($pe !== null) { pp_save($f, $s, 'place ' . implode(' ', $a), [], $pe); echo "REFUSED: $pe\n(nothing changed)\n"; exit(2); } }
        $r = pfb_play($s, [[pp_int($a[0] ?? null, 0, 99, 'HANDIDX'), pp_int($a[1] ?? null, -99, 99, 'X'), pp_int($a[2] ?? null, -99, 99, 'Y')]], $s['turn']); break;
    case 'join': $r = pfb_play($s, [['j', pp_int($a[0] ?? null, 0, 99, 'A'), pp_int($a[1] ?? null, 0, 99, 'B'), pp_side($a[2] ?? null)]], $s['turn']); break;
    case 'add': $r = pfb_play($s, [['h', pp_int($a[0] ?? null, 0, 99, 'B'), pp_int($a[1] ?? null, 0, 99, 'ANC'), pp_side($a[2] ?? null)]], $s['turn']); break;
    case 'group': $r = pfb_play($s, [['c', pp_int($a[0] ?? null, -99, 99, 'X'), pp_int($a[1] ?? null, -99, 99, 'Y')]], $s['turn']); break;
    case 'pass': $r = pfb_pass($s, $s['turn']); break;
    case 'flip': $err = pfb_flip($s, pp_int($a[0] ?? null, 0, 99, 'HANDIDX'), $s['turn']); if ($err === null) { pp_save($f, $s, 'flip ' . implode(' ', $a), [], null); echo "FLIPPED (free; the turn goes on):\n\n" . pp_show($s) . "\n"; exit; } break;
    default: fwrite(STDERR, "unknown command\n"); exit(1);
}
if (isset($r)) { $ev = $r['ev']; $err = $r['err']; }
if ($err !== null) { pp_save($f, $s, $cmd . ' ' . implode(' ', $a), [], $err); echo "REFUSED: $err\n(nothing changed)\n"; exit(2); }
pp_save($f, $s, $cmd . ' ' . implode(' ', $a), $ev, null);
if ($cmd === 'start') { $cx = intdiv(pfb_w($s), 2); $cy = intdiv(pfb_h($s), 2); $sd = ['-1,0' => 'L', '1,0' => 'R', '0,-1' => 'T', '0,1' => 'B']; $o = [];
    foreach ($s['pcs'] as $p) if ($p['by'] !== 'none') $o[] = ($p['by'] === 'me' ? 'YOU' : 'CREATURE') . ' put "' . $p['tile']['n'] . '" (' . $p['tile']['t'] . ' ' . $p['tile']['v'] . ') on side ' . ($sd[($p['x'] - $cx) . ',' . ($p['y'] - $cy)] ?? '?');
    $ev = []; echo "START (nothing fires; turn 1 is your next action; the blank vanishes at the end of turn 1):\n  " . implode("\n  ", $o) . "\n\n" . pp_show($s) . "\n"; exit; }
$notes = [];
if (!empty($s['cut'])) $notes[] = 'CHAIN STOPPED: the fight ended mid-chain; ' . $s['cut'] . ' linked piece(s) did not fire.';
$usedUp = array_filter($s['gone'] ?? [], fn($g) => isset($g['used'])); if ($usedUp) $notes[] = 'USED UP (a chain of 3 or more spends every piece that fired; they go to the discard): ' . implode(', ', array_map(fn($g) => ($g['by'] === 'me' ? 'yours ' : ($g['by'] === 'env' ? 'environment ' : 'creature ')) . '"' . $g['tile']['n'] . '" (by ' . ($g['used'] === 'me' ? 'your' : "the creature's") . ' chain)', $usedUp)) . '.';
$fell = array_filter($s['gone'] ?? [], fn($g) => !empty($g['fell']) && !isset($g['used'])); $exp = array_filter($s['gone'] ?? [], fn($g) => empty($g['fell']) && $g['by'] !== 'none');
if ($fell) $notes[] = 'FELL AWAY (the creature\'s fire budget: a creature piece goes after it has fired twice): ' . implode(', ', array_map(fn($g) => 'creature "' . $g['tile']['n'] . '"', $fell)) . '.';
if ($exp) $notes[] = 'EXPIRED at the end of the round (' . (!empty($s['v1']) ? 'its rounds are up' : '3 rounds old') . '): ' . implode(', ', array_map(fn($g) => ($g['by'] === 'me' ? 'yours ' : ($g['by'] === 'env' ? 'environment ' : 'creature ')) . '"' . $g['tile']['n'] . '"', $exp)) . '.';
if (!empty($s['reshuf'])) $notes[] = 'RESHUFFLE: ' . implode(' and ', array_unique(array_map(fn($w) => $w === 'me' ? 'your' : "the creature's", $s['reshuf']))) . ' draw pile was refilled from its discard.';
echo "WHAT HAPPENED:\n" . pp_events($ev, $before) . ($notes ? "\n" . implode("\n", array_map(fn($n) => '  ' . $n, $notes)) : '') . "\n\n" . pp_show($s) . "\n";
