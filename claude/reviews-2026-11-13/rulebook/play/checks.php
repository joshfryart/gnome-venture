<?php
// Rule book 2.6.990: small checks that call the real engine functions on set-up positions (not whole fights). Each line says what was asked and what the engine answered.
//   php checks.php
require __DIR__ . '/../../../../game/includes/pfboard.php'; require __DIR__ . '/../../../../game/includes/pfdeck.php';
function line(string $q, $a): void { echo str_pad($q, 92) . ' => ' . (is_string($a) ? $a : json_encode($a)) . "\n"; }
// ---- 1. legendary pieces and the Larder
$C = pfd_catalog(); $leg = array_filter($C, fn($p) => $p['src'] === 'legend');
line('legendary pieces in pf_pieces.txt', count($leg));
line('  by type', array_count_values(array_column($leg, 't')));
line('  by tag', array_count_values(array_map(fn($p) => $p['tag'] ?: '-', $leg)));
line('  by built-in knack (mod)', array_count_values(array_map(fn($p) => $p['mod'] ?? '-', $leg)));
line('  by right knob', array_count_values(array_map(fn($p) => $p['r'] ?? 'flat', $leg)));
$treasure = []; foreach (file(__DIR__ . '/../../../../game/includes/data/region_crops.txt', FILE_IGNORE_NEW_LINES) as $l) { if ($l === '' || $l[0] === '#') continue; $c = explode('|', $l); foreach ($c as $cell) if (stripos($cell, 'treasure') !== false) { $treasure[] = $l; break; } }
line('region_crops.txt lines that say "treasure"', count($treasure));
foreach ([[4, 'steady kit, no crop piece in it'], [9, 'bold kit: Oat Cake is a crop piece'], [10, 'level 10'], [14, ''], [15, ''], [20, 'level 20'], [28, '']] as [$lv, $note]) line("pfd_slots($lv) $note", pfd_slots($lv));
$mk = function (int $lv, array $legs, array $crops = [], array $state = []) {
    $cals = array_keys(PF_CALLING_TILE); $src = pfd_sources_blank($lv, $cals[$lv % 6], 'NA');
    $src['starter'] = array_merge(PFD_CORE, pfd_offer_keys($src['calling'], $src['home'], PFD_KITS[['bold', 'steady', 'kind'][$lv % 3]]));
    foreach ($legs as $g) $src['legends'][$g] = 1; foreach ($crops as $k) $src['crops'][$k] = 1; $src['state'] = $state; return pfd_build($src); };
$b = $mk(4, ['cranberry', 'pecan'], ['vegetable']);
line('a gnome who just earned 2 legendary pieces and a crop piece: on / new', array_map(fn($e) => $e['n'] . ':' . ($e['on'] ? 'on' : 'off') . (!empty($e['new']) ? ',NEW' : ''), array_values(array_filter($b['pieces'], fn($e) => in_array($e['src'], ['legend', 'crop'], true)))));
$b = $mk(4, ['cranberry', 'pecan', 'tea', 'quince'], [], ['g:cranberry' => true, 'g:pecan' => true, 'g:tea' => true, 'g:quince' => true]);
line('level 4, four legendary pieces switched on: larder count / max / error', [$b['counts']['larder'], $b['counts']['larder_max'], $b['err']]);
line('  which are left out', array_map(fn($e) => $e['n'] . ':' . $e['out'], array_values(array_filter($b['pieces'], fn($e) => $e['out'] !== ''))));
$b = $mk(9, ['cranberry', 'pecan', 'tea'], [], ['g:cranberry' => true, 'g:pecan' => true, 'g:tea' => true]);
line('level 9 (bold kit with Oat Cake) + three legendary on: larder / max / error', [$b['counts']['larder'], $b['counts']['larder_max'], $b['err']]);
$b = $mk(9, ['cranberry', 'pecan'], [], ['g:cranberry' => true, 'g:pecan' => true]);
line('level 9 (bold kit with Oat Cake) + two legendary on: larder / max / error', [$b['counts']['larder'], $b['counts']['larder_max'], $b['err']]);
$st = ['grit' => 1, 'nimble' => 1, 'hardiness' => 1, 'charm' => 1, 'lore' => 1, 'luck' => 1, 'level' => 9];
foreach (pfd_tiles(array_values(array_filter($mk(9, ['cranberry', 'kola', 'sugarcane'], [], ['g:cranberry' => true, 'g:kola' => true, 'g:sugarcane' => true])['pieces'], fn($e) => $e['src'] === 'legend')), $st) as $t) line('  tile ' . $t['n'], ['t' => $t['t'], 'v' => $t['v'], 'tag' => $t['tag'], 'm' => $t['m'] ?? '', 'rank' => $t['rank'] ?? null]);
// ---- a fight to set positions in
$all = []; foreach (file(__DIR__ . '/../../../../game/includes/data/creatures.txt', FILE_IGNORE_NEW_LINES) as $l) { if ($l === '' || $l[0] === '#') continue; $c = explode('|', $l); if (count($c) < 7) continue; $lv = max(1, (int)$c[4]); $all[$c[0]] = ['slug' => $c[0], 'name' => $c[1], 'size' => $c[2], 'level' => $lv, 'dmg_die' => ['small' => 4, 'medium' => 6, 'large' => 8, 'boss' => 10][$c[2]] ?? 6, 'dmg_bonus' => intdiv($lv, 4)]; }
$new = function (string $slug, int $seed = 1) use ($all) { $c = $all[$slug]; $lv = $c['level']; $src = pfd_sources_blank($lv, 'wayfinder', 'NA'); $st = ['grit' => 0, 'nimble' => 0, 'hardiness' => 0, 'charm' => 0, 'lore' => 0, 'luck' => 0, 'level' => $lv];
    $max = 20 + 3 * $lv; return pfb_new(['hp' => $max, 'max_hp' => $max, 'stats' => $st, 'deck' => pfd_tiles(pfd_fight_entries($src), $st), 'luck' => 0], pfd_foe_row($c, 'NA') + ['region' => ''], $seed, ['blank' => true, 'v1' => true]); };
// ---- 2. a creature heal on the one Yield bar
$s = $new('thistle-beast'); $s['fh']['now'] = 3.0; $s['bar']['now'] = 10.0; $s['bar']['charm'] = 10.0; pf_foe_heal($s, 5.0);
line('Yield bar hurt 3 + charm 10, the creature heals 5: hurt / charm after', [$s['fh']['now'], $s['bar']['now']]);
$s['fh']['now'] = 0.0; $s['bar']['now'] = 2.0; pf_foe_heal($s, 5.0); line('hurt 0 + charm 2, heals 5 (never below 0)', [$s['fh']['now'], $s['bar']['now']]);
// ---- 3. poison on you and Evade
$s = $new('sun-lizard'); pfb_start($s, 0, 'L'); $hp = $s['me']['hp'];
$w = $s; $w['me']['poison'] = 2; $w['me']['poison_v'] = 3; $w['me']['evade'] = 0; pfb_end_round($w); line('poison 2 ticks of 3 on you, no Evade, end of round: health lost / ticks left', [$hp - $w['me']['hp'], $w['me']['poison']]);
$w = $s; $w['me']['poison'] = 2; $w['me']['poison_v'] = 3; $w['me']['evade'] = 1; pfb_end_round($w); line('the same with your Evade still up: health lost / ticks left', [$hp - $w['me']['hp'], $w['me']['poison']]);
// ---- 4. venom cap
$w = $s; $w['me']['poison'] = 2; $w['me']['poison_v'] = 2; $w['ven'] = []; foreach ($w['me']['hand'] as $i => $t) { foreach (pfb_cells($w, $t, 'me') as [$x, $y]) { $w['ven']["$x,$y"] = 3; $r = pfb_place($w, 'me', $i, $x, $y); break 2; } }
line('Reptile, poison 2 waiting, you step on a venom cell: ticks waiting (cap ' . PF_POISON_CAP . ')', $w['me']['poison']);
// ---- 5. Swarm: +1 Hurt per 2 other creature pieces, at most +2
$s = $new('earwig'); pfb_start($s, 0, 'L'); $base = null;
$hurt = null; foreach (array_merge($s['foe']['hand'], $s['foe']['draw']) as $t) if ($t['t'] === 'hurt' && $t['tag'] === '') { $hurt = $t; break; }
foreach ([0, 1, 2, 3, 4, 5, 6] as $others) {
    $w = $s; $w['pcs'] = []; $w['cell'] = []; $w['me']['block'] = 0; $w['me']['hp'] = 30; $id = 100;
    $w['pcs'][$id] = ['id' => $id, 'by' => 'foe', 'tile' => $hurt, 'x' => 0, 'y' => 0, 'born' => 1, 'seq' => 1]; $w['cell']['0,0'] = $id;
    for ($k = 0; $k < $others; $k++) { $q = 200 + $k; $x = 3 - intdiv($k, 3); $y = 1 + $k % 3; $gt = $hurt; $gt['t'] = 'guard'; $gt['ed'] = ['L' => ['flat', null], 'R' => ['flat', null], 'T' => ['flat', null], 'B' => ['flat', null]]; $w['pcs'][$q] = ['id' => $q, 'by' => 'foe', 'tile' => $gt, 'x' => $x, 'y' => $y, 'born' => 1, 'seq' => 2 + $k]; $w['cell']["$x,$y"] = $q; }
    $ev = pfb_fire($w, $id); $o[$others] = $ev[0]['v'];
}
line('Critter Hurt printed ' . $hurt['v'] . ': what it fires for with 0..6 other creature pieces out', $o);
// ---- 6. Finisher reads the HURT part of the bar
$s = $new('earwig'); $t = pf_make_tile('swing', ['grit' => 0, 'level' => 1], 0, ['mod' => 'finisher']); $e = [];
$w = $s; $w['fh']['now'] = 0.0; $w['bar']['now'] = 0.7 * $w['fh']['max']; $w['bar']['charm'] = $w['bar']['now']; $b0 = $w['fh']['now']; pf_apply($w, 'me', $t, (int)$t['v'], false, null, null, null, $e); line('Finisher Hurt ' . $t['v'] . ', bar 70% full by CHARM only: adds', $w['fh']['now'] - $b0);
$w = $s; $w['fh']['now'] = 0.7 * $w['fh']['max']; $b0 = $w['fh']['now']; pf_apply($w, 'me', $t, (int)$t['v'], false, null, null, null, $e); line('Finisher Hurt ' . $t['v'] . ', bar 70% full by HURT: adds', round($w['fh']['now'] - $b0, 1));
// ---- 7. the other built-in knacks
$s = $new('wild-boar');
foreach ([['leech', 'hurt', 12], ['warm', 'hurt', 12], ['spiky', 'guard', 6], ['hardy', 'guard', 6], ['tender', 'heal', 6], ['soft', 'charm', 6]] as [$m, $ty, $v]) {
    $w = $s; $w['me']['hp'] = 50; $t = ['k' => 'x', 'n' => 'x', 't' => $ty, 'v' => $v, 'r' => 'body', 'tag' => '', 'm' => $m]; $e = []; pf_apply($w, 'me', $t, $v, false, null, null, null, $e);
    line("knack $m on a $ty $v (wary creature): hurt added / charm added / my health / my guard / soothe pool", [round($w['fh']['now'], 1), round($w['bar']['now'], 1), $w['me']['hp'] - 50, $w['me']['block'], $w['foe']['agg']]);
}
// ---- 8. poison ticks are flat
foreach ([[10, 10], [10, 46]] as [$pv, $val]) { $w = $s; $t = ['k' => 'x', 'n' => 'x', 't' => 'hurt', 'v' => $pv, 'r' => 'body', 'tag' => 'poison', 'm' => '']; $e = []; pf_apply($w, 'me', $t, $val, false, null, null, null, $e); line("your Poison piece printed $pv fires for $val: tick / ticks", [$w['foe']['poison_v'], $w['foe']['poison']]); }
foreach ([['hurt', 7, 14], ['trick', 4, 4]] as [$ty, $pv, $val]) { $w = $s; $t = ['k' => 'f:x', 'n' => 'x', 't' => $ty, 'v' => $pv, 'r' => 'body', 'tag' => 'poison', 'm' => '']; $e = []; pf_apply($w, 'foe', $t, $val, false, null, null, null, $e); line("a creature Poison $ty printed $pv fires for $val: tick on you / ticks", [$w['me']['poison_v'], $w['me']['poison']]); }
$w = $s; $w['foe']['evade'] = 1; $t = ['k' => 'x', 'n' => 'x', 't' => 'hurt', 'v' => 10, 'r' => 'body', 'tag' => 'poison', 'm' => '']; $e = []; pf_apply($w, 'me', $t, 10, false, null, null, null, $e); line('your Poison Hurt 10 into its Evade: damage / tick set', [$e['dmg'], $w['foe']['poison_v']]);
// ---- 9. Quick on your piece; Plenty and Simmer only when placed
$w = $s; pfb_start($w, 0, 'L'); $n0 = count($w['me']['hand']); $t = ['k' => 'x', 'n' => 'x', 't' => 'hurt', 'v' => 5, 'r' => 'body', 'tag' => 'quick', 'm' => '']; $e = []; pf_apply($w, 'me', $t, 5, false, null, null, null, $e, true); line('your Quick piece placed with ' . $n0 . ' in hand: hand after (it is thrown away at the end of the round)', count($w['me']['hand']));
foreach ([true, false] as $root) { $w = $s; $e = []; pf_apply($w, 'me', ['k' => 'x', 'n' => 'x', 't' => 'heal', 'v' => 5, 'r' => 'body', 'tag' => 'simmer', 'm' => ''], 5, false, null, null, null, $e, $root); pf_apply($w, 'me', ['k' => 'y', 'n' => 'y', 't' => 'heal', 'v' => 5, 'r' => 'body', 'tag' => 'plenty', 'm' => ''], 5, false, null, null, null, $e, $root); line('Simmer and Plenty pieces fire, ' . ($root ? 'placed this turn' : 'fired again by a later chain') . ': regen / more', [$w['me']['regen'] ?? 0, $w['me']['more'] ?? 0]); }
// ---- 10. numbers
foreach (['earwig', 'carrion-crow', 'wild-boar', 'great-hawk'] as $k) { $s = $new($k); line("$k level {$all[$k]['level']}: Yield bar / Rain guard for it / Bramble for you / Thornburst on it", [$s['fh']['max'], max(1, (int)round(0.15 * $s['fh']['max'])), round(0.10 * $s['fh']['max'], 1), round(0.05 * $s['fh']['max'], 1)]); }
line('PFB_LIFE / PFB_FOE_FIRES / PFB_FOE_MIN / PF_TURN_CAP / PF_HAND_CAP / PFB_USEUP', [PFB_LIFE, PFB_FOE_FIRES, PFB_FOE_MIN, PF_TURN_CAP, PF_HAND_CAP, PFB_USEUP]);
line('pfb_v1_cfg(medium) switches', array_intersect_key(pfb_v1_cfg('medium'), array_flip(['aside', 'must', 'freepass', 'flip1', 'nowm', 'redraw', 'onebar', 'aimtot', 'keepmine', 'aimhit', 'useroot', 'kinds', 'blankrand', 'life', 'team2', 'team3', 'envn', 'mud', 'envcap'])));
foreach (['small', 'medium', 'large', 'boss'] as $sz) line("environment deck $sz", array_count_values(array_column(pfb_env_deck($sz, '', true), 'n')));
