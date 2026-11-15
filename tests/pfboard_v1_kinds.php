<?php
// 2.6.98 WEEK 2b (T17-T20): one rule per creature class, behind the rule switch `kinds` (section 18 of tests/pfboard_v1.php).
echo "== 19. class rules: Swarm, Grudge, Two aims, Two turns, Current, Grows, Venom trail (switch kinds)\n";
$k19 = function (string $class, string $size = 'medium', array $over = [], int $seed = 7) {
    $s = pfb_new(v1_me(), v1_foe($size) + ['class' => $class], $seed, ['v1' => ['kinds' => 1, 'aim' => 1, 'order' => 0, 'spawn' => 1] + $over]);
    $s['pcs'] = []; $s['cell'] = []; $s['ter'] = []; $s['envs'] = []; $s['foe']['plan'] = null; $s['spent'] = []; $s['ven'] = []; $s['env'] = ['draw' => [], 'discard' => [], 'next' => []];
    $bt = v1_tile($s, 'f:base', 'guard', 1, 'body', 'creature'); $bt['ed'] = array_fill_keys(['L', 'R', 'T', 'B'], ['wild', null]); v1_put($s, 'foe', $bt, 0, 3);   // a far corner piece, so the board is not empty (cells need a neighbour, an aimed cell does not)
    return $s;
};
$ft19 = fn(array $s, string $k, string $t, int $v, string $r = 'body') => ['ed' => array_fill_keys(['L', 'R', 'T', 'B'], ['wild', null])] + v1_tile($s, $k, $t, $v, $r, 'creature');   // wild edges: it fits wherever it is aimed
$plan19 = fn(array $t, int $x, int $y) => ['k' => $t['k'], 'n' => $t['n'], 't' => $t['t'], 'v' => $t['v'], 'tag' => '', 'x' => $x, 'y' => $y];

chk('kinds is ON in a new fight (T22) and the fight carries its kind; kinds 0 gives none', ($a = pfb_new(v1_me(), v1_foe('medium') + ['class' => 'Bird'], 7, ['v1' => true])) && pfb_kind($a) === 'bird' && ($b0 = pfb_new(v1_me(), v1_foe('medium') + ['class' => 'Critter'], 7, ['v1' => ['kinds' => 0]])) && pfb_kind($b0) === '' && pfb_foe_len($b0) === 1);
chk('kind of a creature: the six classes, and the boss whatever its class', array_map(fn($c) => pfb_kind_of(['class' => $c], 'medium'), ['Critter', 'Bird', 'Beast', 'Water', 'Plant / Fungus', 'Reptile / Amphibian', 'Odd']) === ['critter', 'bird', 'beast', 'water', 'plant', 'reptile', ''] && pfb_kind_of(['class' => 'Bird'], 'boss') === 'boss');

// ---- Critter: Swarm
$s = $k19('Critter'); $s['foe']['slow'] = 1; chk('a slowed Critter loses its turn', pfb_foe_len($s) === 0);

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

// ---- a piece the creature put down this turn and used up in the same turn must not show before its step (2.6.986)
$s = $k19('Critter'); $s['lastfoe'] = [7, 8]; $pp = fn($id) => ['id' => $id, 'by' => 'foe', 'x' => 1, 'y' => 1, 'tile' => v1_tile($s, 'f:z', 'charm', 2, 'body', 'creature'), 'born' => $s['round']];
chk('gone entry: a creature piece put down this turn is marked fnew (the page keeps it hidden until its step)', !empty(pfb_gone_entry($s, $pp(7), true)['fnew']) && !empty(pfb_gone_entry($s, $pp(8), true)['fnew']) && empty(pfb_gone_entry($s, $pp(9), true)['fnew']) && empty(pfb_gone_entry($s, ['by' => 'me'] + $pp(7), true)['fnew']));
// a whole Swarm turn: every foe piece that is gone at the end of the turn but was placed in it carries fnew
$ok = true; $seen = 0;
for ($sd = 1; $sd <= 30; $sd++) { $s = pfb_new(v1_me(), v1_foe('medium') + ['class' => 'Critter'], $sd, ['v1' => true]); for ($t = 0; $t < 4 && !$s['over']; $t++) { $m = pfb_search($s, 'me'); $r = $m ? pfb_play($s, [[$m[0], $m[1], $m[2]]], $s['turn']) : pfb_pass($s, $s['turn']); foreach ($s['gone'] ?? [] as $g) if ($g['by'] === 'foe' && in_array($g['id'], $s['lastfoe'] ?? [], true)) { $seen++; if (empty($g['fnew'])) $ok = false; } } }
chk('Critter fights: every gone piece the creature placed this turn carries fnew (' . $seen . ' seen)', $ok && $seen > 0, $seen);

// ---- the aim total covers the WHOLE creature turn (2.6.986): a Swarm's second piece and a Quick piece are in the number
$bad = 0; $n = 0; $bads = [];
foreach (['Critter', 'Bird', 'Beast'] as $cl) for ($sd = 1; $sd <= 25; $sd++) {
    $s = pfb_new(v1_me(), v1_foe('medium') + ['class' => $cl], $sd, ['v1' => true]);
    for ($t = 0; $t < 5 && !$s['over']; $t++) {
        $m = pfb_search($s, 'me'); if ($m) pfb_play($s, [[$m[0], $m[1], $m[2]]], $s['turn']); else pfb_pass($s, $s['turn']); if ($s['over']) break;
        $tot = $s['foe']['plan']['tot'] ?? null; if (!$tot || isset($tot['broken'])) continue;
        $w = $s; $hp0 = $w['me']['hp']; pfb_foe_turn($w, 0); $n++; if ($hp0 - $w['me']['hp'] !== $tot['hp']) { $bad++; $bads[$cl] = ($bads[$cl] ?? 0) + 1; }
    }
}
chk('aim total: the health shown equals what the whole creature turn takes (Swarm and Quick pieces included): ' . $n . ' aims', $n > 100 && $bad === 0, [$bad, $bads]);

// ---- 2.6.988: Swarm GROWS (one piece a turn, +1 Hurt for each other creature piece on the board); poison ticks are flat; Evade stops them
$s = $k19('Critter'); $h = $ft19($s, 'f:h', 'hurt', 5); v1_put($s, 'foe', $ft19($s, 'f:a', 'charm', 2), 3, 3); v1_put($s, 'foe', $ft19($s, 'f:b', 'charm', 2), 3, 2); $ev = v1_place($s, 'foe', $h, 1, 3);   // base piece at 0,3 + two more = 3 others
chk('Swarm grows: its Hurt 5 with 3 other creature pieces out counts 6 (+1 for every 2 others)', $ev && $ev[0]['v'] === 6, $ev[0]['v'] ?? null);
$s = $k19('Critter'); foreach ([[3, 3], [3, 2], [3, 1], [2, 3]] as $i => [$gx, $gy]) v1_put($s, 'foe', $ft19($s, 'f:o' . $i, 'charm', 2), $gx, $gy); $ev = v1_place($s, 'foe', $ft19($s, 'f:h', 'hurt', 5), 1, 3);
chk('Swarm grows: 5 other pieces out is +2, and 2 or fewer is +0', $ev && $ev[0]['v'] === 7, $ev[0]['v'] ?? null);
$s = $k19('Beast'); $ev = v1_place($s, 'foe', $ft19($s, 'f:h', 'hurt', 5), 1, 3);
chk('Swarm grows is the Critter\'s only (a Beast with the same board hits for 5)', $ev && $ev[0]['v'] === 5, $ev[0]['v'] ?? null);
$s = $k19('Critter'); $s['foe']['hand'] = [$ft19($s, 'f:a', 'charm', 2), $ft19($s, 'f:b', 'charm', 2, 'mind')]; pfb_foe_turn($s, 0);
chk('Swarm plays ONE piece a turn again (its pieces are not scaled down)', count($s['lastfoe']) === 1 && pfb_foe_len($s) === 1);
$s = $k19('Critter'); $qa = $ft19($s, 'f:a', 'trick', 1, 'mind'); $qa['tag'] = 'quick'; $s['foe']['hand'] = [$qa, $ft19($s, 'f:b', 'charm', 2)]; $s['foe']['plan'] = $plan19($qa, 1, 3); $qe = pfb_foe_turn($s, 0);
chk('Quick still adds a second piece for a Critter (up to 2 with Quick)', count($s['lastfoe']) === 2, [count($s['lastfoe']), array_map(fn($e) => ($e['n'] ?? '') . ($e['note'] ?? '') . (!empty($e['root']) ? '*' : ''), $qe), count($s['foe']['hand'])]);
$s = $k19('Beast'); $s['ter']['1,3'] = 'sun'; $pt = $ft19($s, 'f:p', 'hurt', 8); $pt['tag'] = 'poison'; $ev = v1_place($s, 'foe', $pt, 1, 3);
chk('poison is flat: a Sun does not raise the tick (Hurt 8 under Sun x2 ticks 3, as without the Sun)', $s['me']['poison'] > 0 && $s['me']['poison_v'] === 3, [$s['me']['poison'], $s['me']['poison_v']]);
$s = $k19('Beast'); $s['me']['poison'] = 2; $s['me']['poison_v'] = 3; $s['me']['evade'] = 1; $hp = $s['me']['hp']; $s['env'] = ['draw' => [], 'discard' => [], 'next' => []]; pfb_end_round($s);
chk('Evade stops the poison tick (no health lost, the tick still counts down)', $s['me']['hp'] === $hp && $s['me']['poison'] === 1, [$s['me']['hp'] - $hp, $s['me']['poison']]);
$s = $k19('Beast'); $s['me']['poison'] = 2; $s['me']['poison_v'] = 3; $hp = $s['me']['hp']; $s['env'] = ['draw' => [], 'discard' => [], 'next' => []]; pfb_end_round($s);
chk('without Evade the tick lands as before', $s['me']['hp'] === $hp - 3 && $s['me']['poison'] === 1, $s['me']['hp'] - $hp);
// 2.7.01 (Tailor sim 8): an Evade the creature's Hurt used up in its turn still stops that round's tick (it used to be spent first, so Puddle Hop never cut poison)
$s = $k19('Reptile'); $s['me']['poison'] = 2; $s['me']['poison_v'] = 3; $s['me']['block'] = 0;
$ev1 = v1_place($s, 'me', ['tag' => 'evade', 'ed' => array_fill_keys(['L', 'R', 'T', 'B'], ['wild', null])] + v1_tile($s, 'w:flood-boots', 'guard', 3, 'body', 'wear'), 1, 3); $hp = $s['me']['hp'];
$s['aimforce'] = 1; $ev2 = v1_place($s, 'foe', $ft19($s, 'f:bite', 'hurt', 6), 3, 0); unset($s['aimforce']); $hp2 = $s['me']['hp']; pfb_end_round($s);   // its Hurt lands far from your piece, so its chain does not fire your Evade again
chk('Evade: its Hurt misses AND the poison tick that round does nothing', $ev1 && $ev2 && $hp2 === $hp && $s['me']['hp'] === $hp && $s['me']['poison'] === 1, [$hp - $hp2, $hp2 - $s['me']['hp'], $s['me']['poison']]);
pfb_end_round($s); chk('the next round, with no Evade played, the tick lands again', $s['me']['hp'] === $hp - 3, $hp - $s['me']['hp']);

// ---- venom never takes the poison above the cap (found by the deck whole-fight test)
$s = $k19('Reptile'); $s['me']['poison'] = PF_POISON_CAP; $s['ven']['1,3'] = 3; $s['me']['hand'] = [$ft19($s, 'p1', 'charm', 3)]; $evv = pfb_place($s, 'me', 0, 1, 3);
chk('venom: a piece of yours on venom while already at the poison cap stays at the cap', $s['me']['poison'] === PF_POISON_CAP, $s['me']['poison']);

// ---- 2.6.989: a creature's heal acts on the shared Yield bar (the Hurt part first, then the Charm part)
$s = $k19('Beast'); $s['bar']['now'] = 10.0; $s['bar']['charm'] = 10.0; $s['fh']['now'] = 0.0; $ev = v1_place($s, 'foe', $ft19($s, 'f:heal', 'heal', 4), 1, 3);
chk('onebar: a heal of 4 on a bar that is all Charm takes 4 off the Yield bar (10 -> 6)', $ev && round($s['bar']['now'], 1) === 6.0 && round($s['bar']['charm'], 1) === 6.0 && round($s['fh']['now'], 1) === 0.0, [$s['bar']['now'], $s['fh']['now']]);
$s = $k19('Beast'); $s['bar']['now'] = 10.0; $s['bar']['charm'] = 10.0; $s['fh']['now'] = 3.0; $ev = v1_place($s, 'foe', $ft19($s, 'f:heal', 'heal', 4), 1, 3);
chk('onebar: the Hurt part goes first (3 Hurt + 10 Charm, heal 4: Hurt 0, Charm 9)', $ev && round($s['fh']['now'], 1) === 0.0 && round($s['bar']['now'], 1) === 9.0, [$s['bar']['now'], $s['fh']['now']]);
$s = $k19('Beast', 'medium', ['onebar' => 0]); $s['bar']['now'] = 10.0; $s['fh']['now'] = 0.0; $ev = v1_place($s, 'foe', $ft19($s, 'f:heal', 'heal', 4), 1, 3);
chk('two bars (a 2.6.94 fight): a heal still only touches the health bar', $ev && round($s['bar']['now'], 1) === 10.0);

// ---- 2.6.990: the three new effects: Keeper (stays in hand through the redraw), Plenty (6 pieces next round), Simmer (heals 2 at the start of your next 2 turns)
$mk = function (string $tag, string $t = 'heal', int $v = 3) { $s = v1_bare('medium', ['kinds' => 0]); $s['env'] = ['draw' => [], 'discard' => [], 'next' => []]; $tl = v1_tile($s, 'z:' . $tag, $t, $v, 'body', 'legend'); $tl['tag'] = $tag; $tl['ed'] = array_fill_keys(['L', 'R', 'T', 'B'], ['wild', null]); return [$s, $tl]; };
[$s, $kp] = $mk('keep', 'guard', 4); $oth = array_map(fn($i) => v1_tile($s, 'o' . $i, 'hurt', 2, 'body'), [1, 2, 3, 4]); $s['me']['hand'] = array_merge([$kp], $oth); $s['me']['draw'] = array_map(fn($i) => v1_tile($s, 'd' . $i, 'hurt', 2, 'body'), range(1, 12)); $s['me']['discard'] = [];
$cen = [intdiv(pfb_w($s), 2), intdiv(pfb_h($s), 2)]; $bt = v1_tile($s, 'base', 'guard', 1, 'body'); $bt['ed'] = array_fill_keys(['L', 'R', 'T', 'B'], ['wild', null]); v1_put($s, 'foe', $bt, 0, 3);
$s['me']['hand'] = array_merge([$kp], $oth); pfb_play($s, [[1, 0, 2]], $s['turn']);
chk('Keeper: a Keeper piece you did not play is still in your hand next round, and the hand is back to 5', in_array('z:keep', array_column($s['me']['hand'], 'k'), true) && count($s['me']['hand']) === PF_HAND_CAP, array_column($s['me']['hand'], 'k'));
[$s, $kp] = $mk('keep', 'guard', 4); $s['me']['hand'] = array_merge([$kp], array_map(fn($i) => v1_tile($s, 'o' . $i, 'hurt', 2, 'body'), [1, 2, 3, 4])); $s['me']['draw'] = array_map(fn($i) => v1_tile($s, 'd' . $i, 'hurt', 2, 'body'), range(1, 12)); v1_put($s, 'foe', $bt, 0, 3); pfb_play($s, [[0, 0, 2]], $s['turn']);
chk('Keeper: played, it goes to the discard like any piece (not kept)', !in_array('z:keep', array_column($s['me']['hand'], 'k'), true));
[$s, $pp] = $mk('plenty', 'heal', 4); $s['me']['hand'] = array_merge([$pp], array_map(fn($i) => v1_tile($s, 'o' . $i, 'hurt', 2, 'body'), [1, 2, 3, 4])); $s['me']['draw'] = array_map(fn($i) => v1_tile($s, 'd' . $i, 'hurt', 2, 'body'), range(1, 20)); v1_put($s, 'foe', $bt, 0, 3); pfb_play($s, [[0, 0, 2]], $s['turn']);
chk('Plenty: after you play it, next round you hold 6 pieces', count($s['me']['hand']) === PF_HAND_CAP + 1, count($s['me']['hand']));
$mv = pfb_search($s, 'me'); pfb_play($s, [[$mv[0], $mv[1], $mv[2]]], $s['turn']);
chk('Plenty: it does not stack: the round after you are back to 5', count($s['me']['hand']) === PF_HAND_CAP, count($s['me']['hand']));
[$s, $sm] = $mk('simmer', 'heal', 3); $s['me']['hp'] = $s['me']['max'] - 10; $s['me']['hand'] = array_merge([$sm], array_map(fn($i) => v1_tile($s, 'o' . $i, 'hurt', 2, 'body'), [1, 2, 3, 4])); $s['me']['draw'] = array_map(fn($i) => v1_tile($s, 'd' . $i, 'hurt', 2, 'body'), range(1, 20)); v1_put($s, 'foe', $bt, 0, 3);
$s['foe']['hand'] = []; $s['foe']['draw'] = []; $s['foe']['discard'] = []; $hp0 = $s['me']['hp']; pfb_play($s, [[0, 0, 2]], $s['turn']); $h1 = $s['me']['hp']; $r1 = (int)($s['me']['regen'] ?? 0); $mv = pfb_search($s, 'me'); pfb_play($s, [[$mv[0], $mv[1], $mv[2]]], $s['turn']); $h2 = $s['me']['hp']; $r2 = (int)($s['me']['regen'] ?? 0); $mv = pfb_search($s, 'me'); pfb_play($s, [[$mv[0], $mv[1], $mv[2]]], $s['turn']); $h3 = $s['me']['hp'];
$heal0 = $h1 - $hp0 - 2;   // the piece's own heal, then the first tick of 2 at the start of the next turn
chk('Simmer: the piece heals its value now and 2 more as your next turn starts (1 charge left)', $heal0 >= 1 && $r1 === 1, [$hp0, $h1, $r1]);
chk('Simmer: the second tick uses the last charge, then nothing more (a chain can fire the heal piece again: that is its own heal)', $h2 - $h1 >= 2 && $r2 === 0 && $h3 - $h2 <= $h2 - $h1 - 2, [$h1, $h2, $h3, $r2, array_map(fn($x) => $x['k'], $s['me']['hand'])]);
