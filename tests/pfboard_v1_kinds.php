<?php
// 2.6.98 WEEK 2b (T17-T20): one rule per creature class, behind the rule switch `kinds` (section 18 of tests/pfboard_v1.php).
echo "== 19. class rules: Swarm, Grudge, Two aims, Two turns, Current, Grows, Venom trail (switch kinds)\n";
$k19 = function (string $class, string $size = 'medium', array $over = [], int $seed = 7) {
    $s = pfb_new(v1_me(), v1_foe($size) + ['class' => $class], $seed, ['v1' => ['kinds' => 1, 'aim' => 1] + $over]);
    $s['pcs'] = []; $s['cell'] = []; $s['ter'] = []; $s['envs'] = []; $s['foe']['plan'] = null; $s['spent'] = []; $s['ven'] = []; $s['env'] = ['draw' => [], 'discard' => [], 'next' => []];
    $bt = v1_tile($s, 'f:base', 'guard', 1, 'body', 'creature'); $bt['ed'] = array_fill_keys(['L', 'R', 'T', 'B'], ['wild', null]); v1_put($s, 'foe', $bt, 0, 3);   // a far corner piece, so the board is not empty (cells need a neighbour, an aimed cell does not)
    return $s;
};
$ft19 = fn(array $s, string $k, string $t, int $v, string $r = 'body') => ['ed' => array_fill_keys(['L', 'R', 'T', 'B'], ['wild', null])] + v1_tile($s, $k, $t, $v, $r, 'creature');   // wild edges: it fits wherever it is aimed
$plan19 = fn(array $t, int $x, int $y) => ['k' => $t['k'], 'n' => $t['n'], 't' => $t['t'], 'v' => $t['v'], 'tag' => '', 'x' => $x, 'y' => $y];

chk('kinds is ON in a new fight (T22) and the fight carries its kind; kinds 0 gives none', ($a = pfb_new(v1_me(), v1_foe('medium') + ['class' => 'Bird'], 7, ['v1' => true])) && pfb_kind($a) === 'bird' && ($b0 = pfb_new(v1_me(), v1_foe('medium') + ['class' => 'Critter'], 7, ['v1' => ['kinds' => 0]])) && pfb_kind($b0) === '' && pfb_foe_len($b0) === 1);
chk('kind of a creature: the six classes, and the boss whatever its class', array_map(fn($c) => pfb_kind_of(['class' => $c], 'medium'), ['Critter', 'Bird', 'Beast', 'Water', 'Plant / Fungus', 'Reptile / Amphibian', 'Odd']) === ['critter', 'bird', 'beast', 'water', 'plant', 'reptile', ''] && pfb_kind_of(['class' => 'Bird'], 'boss') === 'boss');

// ---- Critter: Swarm
$a = pfb_new(v1_me(), v1_foe('medium') + ['class' => 'Critter'], 7, ['v1' => ['kinds' => 0]]); $b = pfb_new(v1_me(), v1_foe('medium') + ['class' => 'Critter'], 7, ['v1' => ['kinds' => 1]]);
$va = array_sum(array_column($a['foe']['hand'], 'v')); $vb = array_sum(array_column($b['foe']['hand'], 'v'));
chk('Swarm: a Critter plays 2 pieces a turn', pfb_foe_len($b) === 2 && pfb_foe_len($a) === 1, [pfb_foe_len($b), count($b['foe']['hand'])]);
chk('Swarm: its pieces are small (x0.6, at least 1)', $vb < $va && !array_filter($b['foe']['hand'], fn($t) => $t['v'] < 1), [$va, $vb]);
$s = $k19('Critter'); $s['foe']['hand'] = [$ft19($s, 'f:a', 'charm', 2), $ft19($s, 'f:b', 'charm', 2, 'mind')]; $s['foe']['plan'] = null; $ev = pfb_foe_turn($s, 0);
chk('Swarm: a turn puts down two pieces', count($s['lastfoe']) === 2, [count($s['lastfoe']), count($s['pcs']), array_map(fn($p) => [$p['by'], $p['x'], $p['y']], $s['pcs'])]);
$s = $k19('Critter'); $s['foe']['slow'] = 1; chk('Swarm: a slowed Critter still loses its turn', pfb_foe_len($s) === 0);

// ---- Beast: Grudge
$s = $k19('Beast', 'medium', ['aimhit' => 0]); $mine = v1_put($s, 'me', v1_tile($s, 'p1', 'charm', 3, 'body'), 2, 2); $h = $ft19($s, 'f:claw', 'charm', 6);
$s['foe']['hand'] = [$h]; $s['foe']['plan'] = $plan19($h, 2, 2); pfb_foe_turn($s, 0);
chk('Grudge: you took its cell: stack 1 (and it picks again)', ($s['foe']['grudge'] ?? 0) === 1 && $s['reaim'] === 1, $s['foe']['grudge'] ?? null);
$s = $k19('Beast'); $s['foe']['grudge'] = 2; $h = $ft19($s, 'f:claw', 'hurt', 10); $hp = $s['me']['hp']; $ev = v1_place($s, 'foe', $h, 1, 3);
chk('Grudge: two stacks: its Hurt 10 counts 15', $ev && $ev[0]['v'] === 15 && $s['me']['hp'] < $hp, $ev);
$s = $k19('Beast'); $s['foe']['grudge'] = 3; $h = $ft19($s, 'f:claw', 'hurt', 10); $s['foe']['hand'] = [$h]; $s['foe']['plan'] = $plan19($h, 1, 1); pfb_foe_turn($s, 0);
chk('Grudge: a hit that lands clears the stacks', $s['foe']['grudge'] === 0 && $s['me']['hp'] < $s['me']['max'], $s['foe']['grudge']);
$s = $k19('Beast', 'medium', ['aimhit' => 1]); v1_put($s, 'me', v1_tile($s, 'p1', 'hurt', 5, 'body'), 2, 2); $h = $ft19($s, 'f:claw', 'hurt', 6); $s['foe']['hand'] = [$h]; $s['foe']['plan'] = $plan19($h, 2, 2); pfb_foe_turn($s, 0);
chk('Grudge: a strike on your piece counts as a block', $s['foe']['grudge'] === 1, $s['foe']['grudge']);
$s = $k19('Bird'); $s['foe']['grudge'] = 2; $h = $ft19($s, 'f:p', 'hurt', 10); $ev = v1_place($s, 'foe', $h, 1, 3);
chk('Grudge is the Beast\'s only: a Bird with stacks set hits for the plain value', $ev && $ev[0]['v'] === 10, $ev[0]['v'] ?? null);

// ---- Bird: Two aims
$s = $k19('Bird'); $h1 = $ft19($s, 'f:p', 'hurt', 4); $h2 = $ft19($s, 'f:t', 'hurt', 5, 'mind'); $s['foe']['hand'] = [$h1, $h2]; pfb_intent($s);
chk('Two aims: the plan carries a second aim on ANOTHER cell', !empty($s['foe']['plan']['alt']) && ($s['foe']['plan']['alt']['x'] !== $s['foe']['plan']['x'] || $s['foe']['plan']['alt']['y'] !== $s['foe']['plan']['y']), $s['foe']['plan'] ?? null);
$s = $k19('Bird'); $h1 = $ft19($s, 'f:p', 'charm', 2); $s['foe']['hand'] = [$h1]; $s['foe']['plan'] = $plan19($h1, 0, 0) + ['alt' => $plan19($h1, 3, 3)]; v1_put($s, 'me', v1_tile($s, 'p1', 'charm', 3, 'body'), 0, 0); pfb_foe_turn($s, 0);
chk('Two aims: the first cell taken: it plays the second, no re-pick', $s['reaim'] === 0 && isset($s['cell']['3,3']) && $s['pcs'][$s['cell']['3,3']]['by'] === 'foe', [$s['reaim'], array_keys($s['cell'])]);
$s = $k19('Bird'); $h1 = $ft19($s, 'f:p', 'charm', 2); $s['foe']['hand'] = [$h1]; $s['foe']['plan'] = $plan19($h1, 0, 0) + ['alt' => $plan19($h1, 3, 3)]; v1_put($s, 'me', v1_tile($s, 'p1', 'charm', 3, 'body'), 0, 0); v1_put($s, 'me', v1_tile($s, 'p2', 'charm', 3, 'body'), 3, 3); pfb_foe_turn($s, 0);
chk('Two aims: both cells taken: it picks again', $s['reaim'] === 1, $s['reaim']);
$s = $k19('Bird'); $h1 = $ft19($s, 'f:p', 'charm', 2); $s['foe']['hand'] = [$h1]; $s['foe']['plan'] = $plan19($h1, 0, 0) + ['alt' => $plan19($h1, 3, 3)]; pfb_foe_turn($s, 0);
chk('Two aims: its first aim open: it plays the first', isset($s['cell']['0,0']) && !isset($s['cell']['3,3']), [$s['cell'], $s['reaim']]);

// ---- Boss: Two turns
$s = $k19('Bird', 'boss'); $hs = [$ft19($s, 'f:a', 'hurt', 4), $ft19($s, 'f:b', 'hurt', 6, 'mind'), $ft19($s, 'f:c', 'guard', 3, 'craft')]; $s['foe']['hand'] = $hs; pfb_intent($s);
$nx = $s['foe']['plan']['next'] ?? null;
chk('Two turns: the aim also shows the piece after it (a different hand piece)', $nx && $nx['k'] !== $s['foe']['plan']['k'] && $s['foe']['nextk'] === $nx['k'] && empty($s['foe']['plan']['alt']), $s['foe']['plan'] ?? null);
$s = $k19('Bird', 'boss'); $s['foe']['hand'] = [$ft19($s, 'f:a', 'hurt', 9), $ft19($s, 'f:b', 'guard', 2, 'mind'), $ft19($s, 'f:c', 'charm', 3, 'craft')]; $s['foe']['nextk'] = 'f:b'; pfb_intent($s);
chk('Two turns: the committed piece is forced next round, whatever scores best (cell chosen then)', $s['foe']['plan']['k'] === 'f:b' && $s['foe']['nextk'] !== 'f:b' && isset($s['foe']['plan']['x']), $s['foe']['plan'] ?? null);
$s = $k19('Bird', 'boss'); $s['foe']['hand'] = [$ft19($s, 'f:a', 'hurt', 9)]; $s['foe']['nextk'] = 'f:gone'; pfb_intent($s);
chk('Two turns: if the committed piece is gone it picks as usual', ($s['foe']['plan']['k'] ?? '') === 'f:a');
$s = $k19('Bird', 'medium'); $s['foe']['hand'] = $hs; pfb_intent($s); chk('a non-boss has no next piece', empty($s['foe']['plan']['next']) && empty($s['foe']['nextk']));

// ---- Water: Current
$s = $k19('Water'); v1_put($s, 'me', v1_tile($s, 'p1', 'charm', 3, 'body'), 2, 1); $h = $ft19($s, 'f:w', 'charm', 2); $s['foe']['hand'] = [$h]; $s['foe']['plan'] = $plan19($h, 1, 1); $ev = pfb_foe_turn($s, 0);
$cur = array_values(array_filter($ev, fn($e) => ($e['note'] ?? '') === 'current'))[0] ?? null;
chk('Current: your piece next to its new piece slides one cell away from it', $cur && $cur['moved']['x'] === 3 && $cur['moved']['y'] === 1 && isset($s['cell']['3,1']) && !isset($s['cell']['2,1']), [$cur, array_keys($s['cell'])]);
$s = $k19('Water'); $ex = pfb_w($s) - 1; v1_put($s, 'me', v1_tile($s, 'p1', 'charm', 3, 'body'), $ex, 1); $h = $ft19($s, 'f:w', 'charm', 2); $s['foe']['hand'] = [$h]; $s['foe']['plan'] = $plan19($h, $ex - 1, 1); $ev = pfb_foe_turn($s, 0);
chk('Current: at the edge nothing moves (no note)', !array_filter($ev, fn($e) => ($e['note'] ?? '') === 'current') && isset($s['cell']['' . $ex . ',1']));
$s = $k19('Water', 'medium', ['limit' => 0]); v1_put($s, 'me', v1_tile($s, 'p1', 'charm', 3, 'body'), 2, 1); v1_put($s, 'me', v1_tile($s, 'p2', 'charm', 3, 'body'), 1, 2); $h = $ft19($s, 'f:w', 'charm', 2); $s['foe']['hand'] = [$h]; $s['foe']['plan'] = $plan19($h, 1, 1); $ev = pfb_foe_turn($s, 0);
chk('Current: only ONE piece moves', count(array_filter($ev, fn($e) => ($e['note'] ?? '') === 'current')) === 1, array_map(fn($e) => $e['note'] ?? $e['n'] ?? '', $ev));

// ---- Plant: Grows
$s = $k19('Plant'); $h = $ft19($s, 'f:p', 'charm', 2); $s['foe']['hand'] = [$h]; $s['foe']['plan'] = $plan19($h, 1, 1); $ev = pfb_foe_turn($s, 0);
$br = array_values(array_filter($s['pcs'], fn($p) => $p['by'] === 'env')); $gp = array_values(array_filter($ev, fn($e) => ($e['note'] ?? '') === 'grows'));
chk('Grows: after its turn exactly one Bramble (its own) lies touching its piece', count($br) === 1 && $br[0]['tile']['env'] === 'bramble' && abs($br[0]['x'] - 1) + abs($br[0]['y'] - 1) === 1 && count($gp) === 1 && $br[0]['born'] === $s['round'] + 1, array_map(fn($p) => [$p['x'], $p['y']], $br));
$s['foe']['hand'] = [$ft19($s, 'f:q', 'charm', 2, 'mind')]; $s['foe']['plan'] = $plan19($s['foe']['hand'][0], 3, 3); $n0 = count($s['pcs']); pfb_foe_turn($s, 0);
chk('Grows: at most one of its own Brambles out', count(array_filter($s['pcs'], fn($p) => $p['by'] === 'env')) === 1);
$s = $k19('Beast'); $h = $ft19($s, 'f:p', 'charm', 2); $s['foe']['hand'] = [$h]; $s['foe']['plan'] = $plan19($h, 1, 1); pfb_foe_turn($s, 0);
chk('Grows is the Plant\'s only (a Beast grows nothing)', !array_filter($s['pcs'], fn($p) => $p['by'] === 'env'));

// ---- Reptile: Venom trail
$s = $k19('Reptile'); $id = v1_put($s, 'foe', $ft19($s, 'f:r', 'charm', 2), 1, 1); $s['pcs'][$id]['born'] = $s['round'] - 5; v1_put($s, 'me', $ft19($s, 'p0', 'charm', 3), 1, 2); pfb_expire($s);
chk('Venom: a creature piece that leaves leaves venom on its cell (shown as rounds)', isset($s['ven']['1,1']) && $s['ven']['1,1'] === PFB_KIND_VENOM_RNDS + 1, $s['ven']);
$s['me']['hand'] = [$ft19($s, 'p1', 'charm', 3)]; $ev = pfb_place($s, 'me', 0, 1, 1); $vn = array_values(array_filter($ev ?? [], fn($e) => ($e['note'] ?? '') === 'venom'));
chk('Venom: a piece of yours put there poisons you: 2 rounds of 2', $vn && $s['me']['poison'] === 2 && $s['me']['poison_v'] === 2, [$s['me']['poison'], $s['me']['poison_v']]);
$s = $k19('Reptile'); $s['ven']['2,2'] = 3; $s['round'] = 1; $s['me']['poison'] = 0; $s['me']['poison_v'] = 0; $e0 = $s['ven']; pfb_end_round($s);
chk('Venom fades: one step each round, gone after two of your turns', ($s['ven']['2,2'] ?? 0) === 2); pfb_end_round($s); pfb_end_round($s);
chk('Venom is gone after the third round end', !isset($s['ven']['2,2']), $s['ven']);
$s = $k19('Beast'); $id = v1_put($s, 'foe', $ft19($s, 'f:r', 'charm', 2), 1, 1); $s['pcs'][$id]['born'] = $s['round'] - 5; pfb_expire($s);
chk('Venom is the Reptile\'s only', $s['ven'] === []);
$s = $k19('Reptile'); $s['ven']['1,1'] = 2; $s['me']['hand'] = [v1_tile($s, 'p1', 'charm', 3, 'body')]; $s['v1']['kinds'] = 0; pfb_place($s, 'me', 0, 1, 1);
chk('kinds 0: venom on the cell does nothing', (int)$s['me']['poison'] === 0);

// ---- views and notes
$s = $k19('Bird'); $v = pfb_view($s, 'x'); chk('view: kind, grudge and venom cells for the page', ($v['kind'] ?? '') === 'bird' && array_key_exists('grudge', $v) && ($v['ven'] ?? null) === [], array_keys($v));
$e = pfb_note('current', 'Swing'); chk('lines: the three new notes read, none falls to "Tripped"', str_contains(pfight_line($e, 'Owl'), 'current') && str_contains(pfight_line(pfb_note('grows'), 'Owl'), 'Bramble') && str_contains(pfight_line(pfb_note('venom', 'Swing'), 'Owl'), 'Venom'));
