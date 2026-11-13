<?php
// 2.6.75 ENVIRONMENT PIECES (section 13 of tests/pfboard_v1.php, which includes this file: it uses that file's helpers chk, v1_bare, v1_tile, v1_put, v1_place, v1_env, v1_me, v1_foe).
// Each check: arrange a small board, act through the engine, assert exact numbers. Data lint of game/includes/data/pf_env.txt first.

echo "== 13. environment pieces (2.6.75)\n";
$T = pfb_env_table(); $P = $T['pieces']; $fam3 = ['body', 'mind', 'craft'];
chk('data: six pieces, one of each kind (sun, bramble, rain, wind, mud, thorn)', count($P) === 6 && array_values(array_map(fn($p) => $p['env'], $P)) === PFB_ENV_KINDS, array_keys($P));
$okE = true; $okL = true; $okW = true;
foreach ($P as $k => $p) {
    $kinds = array_column($p['ed'], 0); $fams = array_unique(array_filter(array_column($p['ed'], 1)));
    if ($p['env'] === 'mud') { if ($kinds !== ['flat', 'flat', 'flat', 'flat']) $okE = false; }
    elseif (array_diff($kinds, ['knob', 'hole']) || count(array_keys($kinds, 'knob')) !== 2 || count($fams) !== 3 || array_diff($fams, $fam3)) $okE = false;   // two knobs, two holes, all three families: it links from several sides
    if ($p['life'] < 2 || $p['life'] > 3 || $p['n'] === '' || strlen($p['blurb']) < 10 || $p['k'] !== 'e:' . $k) $okL = false;
    if (array_keys($p['w']) !== array_keys(PFB_SIZE) || min($p['w']) < 0 || max($p['w']) > 4) $okW = false;
}
chk('data: Mud is flat on every side; every other piece has two knobs, two holes and all three families (no flat, no wild)', $okE);
chk('data: life 2-3 rounds, a name, a blurb, key e:KEY', $okL);
chk('data: copies by size for the four sizes, 0-4 each; every deck has 8-12 pieces', $okW && !array_filter(array_keys(PFB_SIZE), fn($z) => count(pfb_env_deck($z)) < 8 || count(pfb_env_deck($z)) > 12), array_map(fn($z) => count(pfb_env_deck($z)), array_keys(PFB_SIZE)));
$codes = []; foreach (pf_data_lines('pf_region_pieces.txt') as $r) $codes[$r[0]] = 1; ksort($codes); $rk = $T['regions']; ksort($rk);
chk('data: every region (the 14 of pf_region_pieces.txt) leans the deck, by 1 or 2 pieces of known kinds', array_keys($rk) === array_keys($codes) && !array_filter($rk, fn($b) => !$b || array_diff(array_keys($b), PFB_ENV_KINDS) || array_sum(array_map('abs', $b)) > 2), array_keys($rk));
$cnt = fn(array $d) => array_count_values(array_column($d, 'env'));
chk('deck: a medium creature with no region gets the copies of the file', $cnt(pfb_env_deck('medium')) === array_filter(array_combine(array_column($P, 'env'), array_map(fn($p) => $p['w']['medium'], $P))), $cnt(pfb_env_deck('medium')));
$base = $cnt(pfb_env_deck('large')); $sea = $cnt(pfb_env_deck('large', 'SEA'));
chk('deck: region SEA adds one Rain and one Mud; an unknown region or size changes nothing', $sea['rain'] === $base['rain'] + 1 && $sea['mud'] === $base['mud'] + 1 && $sea['sun'] === $base['sun'] && pfb_env_deck('large', 'XX') === pfb_env_deck('large') && pfb_env_deck('odd') === pfb_env_deck('medium'), $sea);
$d0 = pfb_env_deck('small')[0];
chk('deck: a piece is a real tile (type env, source env, value 0, its life and four edges)', $d0['t'] === 'env' && $d0['src'] === 'env' && $d0['v'] === 0 && $d0['k'] === 'e:sun' && $d0['life'] === 2 && count($d0['ed']) === 4 && pfb_edges($d0) === $d0['ed'], $d0);
$any = 0; $stats = ['level' => 1];
foreach ($P as $p) { if ($p['env'] === 'mud') continue; $s0 = v1_bare(); $e0 = ['k' => $p['k'], 'n' => $p['n'], 't' => 'env', 'v' => 0, 'r' => null, 'tag' => '', 'src' => 'env', 'env' => $p['env'], 'life' => $p['life'], 'ed' => $p['ed']]; v1_put($s0, 'env', $e0, 2, 2);
    $sides = [];
    foreach (['swing', 'dodge', 'rest', 'charm'] as $bk) foreach ([false, true] as $fl) { $bt = pfb_v1_tile(pf_make_tile($bk, $stats), $s0['v1']); if ($fl) $bt['flip'] = true; foreach ([[1, 2], [3, 2], [2, 1], [2, 3]] as $ci => [$x, $y]) if (pfb_has_link(pfb_check($s0, $bt, $x, $y))) $sides[$ci] = 1; }
    if (count($sides) >= 2) $any++; }
chk('edges: the four core pieces (Swing, Dodge, Rest, Charm; flipped or not) link to every firing environment piece from 2 sides or more', $any === 5, $any);

// ---- the start of a fight, the face-up pieces, the environment's turn
$s = pfb_new(v1_me(), v1_foe('medium') + ['region' => 'SE'], 21, ['v1' => true, 'blank' => true]); $deckN = count(pfb_env_deck('medium', 'SE'));
chk('new fight: the environment has its deck, TWO pieces face up (a list), no ground cells and no forecast', !empty($s['v1']['env']) && $s['v1']['envn'] === 2 && count($s['env']['next']) === 2 && array_is_list($s['env']['next']) && count($s['env']['draw']) === $deckN - 2 && $s['env']['discard'] === [] && $s['ter'] === [] && $s['envs'] === [], [count($s['env']['draw']), $deckN]);
$v = pfb_view($s); $nx = $s['env']['next'];
chk('view: env.next lists the face-up pieces in the order they will be placed (name, kind, life, edges), how many wait and how many it places a round; v1.env is on, ground and events off', $v['env']['next'] === array_map(fn($t) => ['k' => $t['k'], 'n' => $t['n'], 'kind' => $t['env'], 'life' => $t['life'], 'e' => $t['ed']], $nx) && $v['env']['deck'] === $deckN - 2 && $v['env']['used'] === 0 && $v['env']['n'] === 2 && $v['v1']['env'] === true && $v['v1']['envn'] === 2 && $v['v1']['mud'] === PFB_MUD && $v['v1']['th_foe'] === PFB_THORN_FOE && $v['v1']['ground'] === false && $v['v1']['events'] === false, $v['env']);
chk('the same seed gives the same environment deck', pfb_new(v1_me(), v1_foe('medium') + ['region' => 'SE'], 21, ['v1' => true, 'blank' => true])['env'] === $s['env']);
$found = null;   // a seed where both face-up pieces find a cell in round 1
for ($seed = 21; $seed < 60 && !$found; $seed++) {
    $s = pfb_new(v1_me(), v1_foe('medium') + ['region' => 'SE'], $seed, ['v1' => true, 'blank' => true]); $nx = $s['env']['next']; pfb_start($s, 0, 'L'); $m = pfb_search($s, 'me'); if (!$m) continue;
    $r = pfb_play($s, [[$m[0], $m[1], $m[2]]], $s['turn']); $pl = array_values(array_filter($r['ev'], fn($e) => ($e['env'] ?? '') === 'place')); if (count($pl) === 2 && !$s['over']) $found = [$s, $nx, $r, $pl];
}
[$s, $nx, $r, $pl] = $found; $tas = array_column($r['ev'], 'ta'); $envp = array_values(array_filter($s['pcs'], fn($p) => $p['by'] === 'env')); $last = $pl[1];
chk('round 1: you, the creature, then the environment: its turn comes last (by env, ta env, env place) and puts down exactly the two pieces that lay face up, in their order', count($envp) === 2 && [$pl[0]['kind'], $pl[1]['kind']] === [$nx[0]['env'], $nx[1]['env']] && [$pl[0]['n'], $pl[1]['n']] === [$nx[0]['n'], $nx[1]['n']] && [$pl[0]['id'], $pl[1]['id']] === [$envp[0]['id'], $envp[1]['id']] && [$last['x'], $last['y']] === [$envp[1]['x'], $envp[1]['y']] && $last['ta'] === 'env' && $last['by'] === 'env' && !array_filter(array_slice($tas, array_search('env', $tas, true)), fn($t) => $t !== 'env') && array_search('env', $tas, true) > (int)array_search('foe', $tas, true), $pl);
$prevE = array_values(array_filter($r['ev'], fn($e) => $e['ta'] !== 'env')); $prevE = end($prevE);
chk('the environment\'s turn fires nothing: the bars and your health stand as after the creature\'s last piece', [$last['barnow'], $last['fhnow'], $last['hpnow']] === [$prevE['barnow'], $prevE['fhnow'], $prevE['hpnow']] && $last['me'] === 0 && $last['foe'] === 0.0);
chk('after its turn two new pieces lie face up and the deck is two shorter', count($s['env']['next']) === 2 && count($s['env']['draw']) === $deckN - 4);
$vp = array_column(pfb_view($s)['pcs'], null, 'id')[$envp[0]['id']];
chk('view: the placed piece is by env, carries its kind, and has its whole life left (its life counts from the next round)', $vp['by'] === 'env' && $vp['kind'] === $nx[0]['env'] && $vp['left'] === $nx[0]['life'] && $vp['life'] === $nx[0]['life'] && $vp['age'] === 0 && $vp['src'] === 'env' && $vp['t'] === 'env', $vp);
$ln = pfight_line($pl[0], 'Owl'); chk('the place line names the piece', str_contains($ln, 'places ' . $nx[0]['n']), $ln);

$s = v1_bare(); v1_put($s, 'foe', v1_tile($s, 'f:c', 'charm', 3, 'body', 'creature'), 2, 2);
$sun = v1_env('sun', null, false); $s9 = $s; v1_put($s9, 'env', ['ed' => array_fill_keys(['L', 'R', 'T', 'B'], ['flat', null])] + v1_env('rain'), 0, 0); $cells = pfb_env_cells($s9, $sun);
chk('where it may go (2.6.78, Josh): it TRIES cells where the piece links to nothing (the cells that only touch a flat piece)', $cells && pfb_check($s9, $sun, 1, 0) !== null && pfb_check($s9, $sun, 0, 1) !== null && count($cells) === count(array_filter($cells, fn($c) => !pfb_has_link(pfb_check($s9, $sun, $c[0], $c[1])))) && in_array([1, 0], $cells, true), $cells);
$sL = v1_bare(); $kb = ['knob', 'body']; $hb = ['hole', 'body']; v1_put($sL, 'foe', ['ed' => ['L' => $kb, 'R' => $kb, 'T' => $kb, 'B' => $kb]] + v1_tile($sL, 'f:c', 'charm', 3, 'body', 'creature'), 2, 2);
$allh = ['ed' => ['L' => $hb, 'R' => $hb, 'T' => $hb, 'B' => $hb]] + v1_env('sun', null, false); $cl = pfb_env_cells($sL, $allh);
chk('fallback: when every fitting cell would link, any fitting cell is allowed (linking allowed)', count($cl) === 4 && count(array_filter($cl, fn($c) => pfb_has_link(pfb_check($sL, $allh, $c[0], $c[1])))) === 4, $cl);
$sL['env'] = ['draw' => [], 'discard' => [], 'next' => [$allh]]; pfb_env_place($sL);
chk('fallback: the piece is placed on a linking cell rather than passing', count(array_filter($sL['pcs'], fn($p) => $p['by'] === 'env')) === 1, $sL['envlog']);
$cells = pfb_env_cells($s, $sun);
$mud = v1_env('mud', null, false); $mc = pfb_env_cells($s, $mud);
chk('Mud links nowhere, so it may go on any free cell next to a piece', count($mc) === 4 && !array_filter($mc, fn($c) => abs($c[0] - 2) + abs($c[1] - 2) !== 1), $mc);
$s['env'] = ['draw' => [v1_env('rain', null, false), v1_env('thorn', null, false)], 'discard' => [], 'next' => [$sun]]; $pid0 = $s['pid']; pfb_env_place($s); $np = $s['pcs'][$s['pid']];
chk('the environment places its piece on one of those cells, born for the next round, and logs it (place, id, kind, name, cell); then it turns pieces face up until two lie open', $s['pid'] === $pid0 + 1 && $np['by'] === 'env' && in_array([$np['x'], $np['y']], $cells, true) && $np['born'] === $s['round'] + 1 && $s['envlog'] === [['k' => 'place', 'x' => $np['x'], 'y' => $np['y'], 'me' => 0, 'foe' => 0.0, 'id' => $np['id'], 'kind' => 'sun', 'n' => 'Sun']] && array_column($s['env']['next'], 'env') === ['thorn', 'rain'] && $s['env']['draw'] === [], $s['envlog']);
$s = v1_bare(); v1_put($s, 'foe', v1_tile($s, 'f:c', 'charm', 3, 'body', 'creature'), 2, 2); $s['env'] = ['draw' => [v1_env('thorn')], 'discard' => [], 'next' => [v1_env('rain'), v1_env('sun')]]; pfb_env_place($s); $ep = array_values(array_filter($s['pcs'], fn($p) => $p['by'] === 'env'));
chk('two pieces a turn: both face-up pieces go down in their order (two place notes), the second may link to the first', count($ep) === 2 && [$ep[0]['tile']['env'], $ep[1]['tile']['env']] === ['rain', 'sun'] && array_column($s['envlog'], 'k') === ['place', 'place'] && array_column($s['envlog'], 'kind') === ['rain', 'sun'] && array_column($s['env']['next'], 'env') === ['thorn'], $s['envlog']);
$s = v1_bare(); $kb = ['knob', 'body']; $allk = ['L' => $kb, 'R' => $kb, 'T' => $kb, 'B' => $kb]; v1_put($s, 'foe', ['ed' => $allk] + v1_tile($s, 'f:c', 'charm', 3, 'body', 'creature'), 2, 2);
$odd = ['ed' => $allk] + v1_env('sun'); $s['env'] = ['draw' => [v1_env('thorn')], 'discard' => [], 'next' => [$odd, v1_env('rain')]]; $n0 = count($s['pcs']); pfb_env_place($s);
chk('a piece that fits nowhere: the environment passes for THAT piece, keeps it face up (first in line) and says which; the other piece is still placed and one new piece is turned up', count($s['pcs']) === $n0 + 1 && $s['env']['next'][0] === $odd && array_column($s['env']['next'], 'env') === ['sun', 'thorn'] && $s['env']['draw'] === [] && $s['envlog'][0] === ['k' => 'pass', 'x' => null, 'y' => null, 'me' => 0, 'foe' => 0.0, 'kind' => 'sun', 'n' => 'Sun'] && $s['envlog'][1]['k'] === 'place' && $s['envlog'][1]['kind'] === 'rain', $s['envlog']);
$ev = pfb_env_events($s); chk('a pass is an event too (by env, ta env, env pass) with a line', count($ev) === 2 && $ev[0]['env'] === 'pass' && $ev[0]['ta'] === 'env' && str_contains(pfight_line($ev[0], 'Owl'), 'no place for Sun'), $ev);
$s = v1_bare(); v1_put($s, 'foe', v1_tile($s, 'f:c', 'charm', 3, 'body', 'creature'), 2, 2); $s['env'] = ['draw' => [], 'discard' => [], 'next' => []]; pfb_env_place($s);
chk('every piece is out: it passes with nothing to place', $s['envlog'] === [['k' => 'pass', 'x' => null, 'y' => null, 'me' => 0, 'foe' => 0.0]] && str_contains(pfb_env_line(pfb_env_events($s)[0], 'Owl'), 'no piece to place'), $s['envlog']);
$s['env'] = ['draw' => [], 'discard' => [v1_env('rain'), v1_env('sun'), v1_env('wind')], 'next' => []]; pfb_env_draw($s);
chk('the deck is empty: the discard is shuffled back in and two pieces are turned face up', count($s['env']['next']) === 2 && count($s['env']['draw']) === 1 && $s['env']['discard'] === []);
$s['env'] = ['draw' => [v1_env('rain')], 'discard' => [], 'next' => []]; pfb_env_draw($s);
chk('one piece left in all: only one lies face up', count($s['env']['next']) === 1 && $s['env']['draw'] === []);
$s = v1_bare('medium', ['envn' => 1]); v1_put($s, 'foe', v1_tile($s, 'f:c', 'charm', 3, 'body', 'creature'), 2, 2); $s['env'] = ['draw' => [v1_env('rain'), v1_env('mud')], 'discard' => [], 'next' => [v1_env('sun')]]; pfb_env_place($s);
chk('rule value envn = 1: one piece a turn, one face up', count(array_filter($s['pcs'], fn($p) => $p['by'] === 'env')) === 1 && count($s['envlog']) === 1 && array_column($s['env']['next'], 'env') === ['mud']);
$full = function (int $n) { $s = v1_bare(); $flat = ['ed' => array_fill_keys(['L', 'R', 'T', 'B'], ['flat', null])]; for ($i = 0; $i < $n; $i++) v1_put($s, 'foe', $flat + v1_tile($s, "f:x$i", 'guard', 1, 'body', 'creature'), $i % 5, intdiv($i, 5)); $s['env'] = ['draw' => [], 'discard' => [], 'next' => [v1_env('mud', null, false), v1_env('mud', null, false)]]; pfb_env_place($s); return $s; };
$s = $full(18); $s2 = $full(16);
chk('a full board: with 70% of the cells taken (18 of 25) the environment places nothing and says the board is too full; with 16 taken it places one, then stops at 17 (still under 70%: it places the second too)', array_column($s['envlog'], 'k') === ['pass', 'pass'] && ($s['envlog'][0]['full'] ?? 0) === 1 && count($s['env']['next']) === 2 && str_contains(pfb_env_line(pfb_env_events($s)[0], 'Owl'), 'too full') && array_column($s2['envlog'], 'k') === ['place', 'place'] && count($s2['cell']) === 18, [array_column($s['envlog'], 'k'), array_column($s2['envlog'], 'k')]);
$s3 = $full(17);
chk('the cap is checked before each piece: with 17 taken the first is placed (18 = 72%), the second is kept', array_column($s3['envlog'], 'k') === ['place', 'pass'] && ($s3['envlog'][1]['full'] ?? 0) === 1 && count($s3['env']['next']) === 1, array_column($s3['envlog'], 'k'));
$s = pfb_new(v1_me(), v1_foe('medium'), 3, ['v1' => ['env' => 0]]);
chk('rule switch env = 0: no environment at all (no deck, no ground, no events), and the view has no env', !isset($s['env']) && $s['ter'] === [] && $s['envs'] === [] && !isset(pfb_view($s)['env']) && pfb_view($s)['v1']['env'] === false);

// ---- Sun
$mk = function (string $kind, string $left = 'me', array $over = [], ?string $dir = null) {   // [left piece (charm 3) at 1,2] [env piece at 2,2]; the checks place at 3,2
    $s = v1_bare('medium', $over); $a = v1_put($s, $left, v1_tile($s, $left === 'me' ? 'c1' : 'f:c1', 'charm', 3, 'body', $left === 'me' ? 'knack' : 'creature'), 1, 2); $e = v1_put($s, 'env', v1_env($kind, $dir), 2, 2);
    return [$s, $a, $e];
};
$swing = v1_tile(v1_bare(), 'h1', 'hurt', 5, 'mind');
[$s, $a, $e] = $mk('sun'); $b0 = $s['bar']['now']; $fh0 = $s['fh']['now']; $ev = v1_place($s, 'me', $swing, 3, 2);
chk('Sun: your pieces in the chain count double, the Sun piece fires between them (by env, env fire, kind sun, for me)', $ev && count($ev) === 3 && [$ev[0]['v'], $ev[2]['v']] === [10, 6] && ($ev[0]['sun'] ?? 0) === 1 && ($ev[2]['sun'] ?? 0) === 1 && $ev[1]['by'] === 'env' && $ev[1]['env'] === 'fire' && $ev[1]['kind'] === 'sun' && $ev[1]['for'] === 'me' && $ev[1]['id'] === $e && $ev[1]['t'] === 'env' && abs($s['fh']['now'] - $fh0 - 10 * $s['hm']) < 1e-9, array_map(fn($x) => [$x['by'], $x['v']], $ev ?? []));
chk('Sun: it counts for the chain\'s length, so this chain of 3 uses up all three pieces, and the Sun goes back to the environment\'s discard', ($ev[0]['used'] ?? []) === [$s['pid'], $e, $a] && $s['pcs'] === [] && count($s['env']['discard']) === 1 && $s['env']['discard'][0]['env'] === 'sun' && count($s['spent']) === 3 && $s['spent'][1]['used'] === 'me', [$ev[0]['used'] ?? null, array_keys($s['pcs'])]);
[$s, $a, $e] = $mk('sun', 'foe'); $ev = v1_place($s, 'me', $swing, 3, 2);
chk('Sun: only the side whose chain it is: the creature\'s piece in your chain is not doubled', $ev && $ev[0]['v'] === 10 && $ev[2]['by'] === 'foe' && $ev[2]['v'] === 3 && !isset($ev[2]['sun']), array_map(fn($x) => [$x['by'], $x['v']], $ev ?? []));
[$s, $a, $e] = $mk('sun', 'me'); $hp0 = $s['me']['hp']; $ev = v1_place($s, 'foe', v1_tile($s, 'f:h', 'hurt', 4, 'mind', 'creature'), 3, 2);
chk('Sun: the creature\'s chain: its Hurt piece hits you for double, your piece in it is not doubled, the event says for foe', $ev && $ev[0]['v'] === 8 && $hp0 - $s['me']['hp'] === 8 && $ev[1]['for'] === 'foe' && $ev[2]['by'] === 'me' && $ev[2]['v'] === 3, array_map(fn($x) => [$x['by'], $x['v']], $ev ?? []));
[$s, $a, $e] = $mk('sun', 'me', ['limit' => 0]); v1_put($s, 'env', v1_env('sun'), 3, 1); $ev = v1_place($s, 'me', $swing, 3, 2);
chk('Sun: two Suns in one chain still double once', $ev && count($ev) === 4 && $ev[0]['v'] === 10, array_map(fn($x) => [$x['by'], $x['v']], $ev ?? []));
[$s, $a, $e] = $mk('sun', 'me', ['sun' => 3, 'limit' => 0]); $ev = v1_place($s, 'me', $swing, 3, 2);
chk('Sun: rule value sun = 3 triples; with limit = 0 nothing is used up and the Sun stays', $ev && $ev[0]['v'] === 15 && isset($s['pcs'][$e]) && !isset($ev[0]['used']), $ev[0]['v'] ?? null);
$s = v1_bare(); $e = v1_put($s, 'env', v1_env('sun'), 2, 2); $ev = v1_place($s, 'me', $swing, 3, 2); $stays = isset($s['pcs'][$e]) && $s['pcs'][$e]['f'] === 1; $ev2 = v1_place($s, 'me', v1_tile($s, 'h2', 'hurt', 4, 'body'), 2, 1);
chk('a chain of 2 (your piece and the Sun) uses nothing up: the Sun stays and fires again in your next chain', $ev && count($ev) === 2 && !isset($ev[0]['used']) && $stays && $ev2 && $ev2[0]['v'] === 8 && $ev2[1]['kind'] === 'sun', [count($ev ?? []), $stays, $ev2[0]['v'] ?? null]);
$s = v1_bare('medium', ['limit' => 0]); v1_put($s, 'me', v1_tile($s, 'h0', 'hurt', 4, 'body'), 1, 2); v1_put($s, 'env', v1_env('rain'), 2, 2); $ev = v1_place($s, 'me', $swing, 3, 2);
$s2 = v1_bare('medium', ['limit' => 0]); v1_put($s2, 'me', v1_tile($s2, 'h0', 'hurt', 4, 'body'), 2, 2); $ev2 = v1_place($s2, 'me', $swing, 3, 2);
chk('no combo runs through an environment piece (Hurt, Rain, Hurt: no Double Swing; Hurt next to Hurt: Double Swing)', $ev && $ev[2]['combo'] === null && $ev[2]['v'] === 4 && $ev2 && $ev2[1]['combo'] !== null, [$ev[2]['combo'] ?? null, $ev2[1]['combo'] ?? null]);
$s = v1_bare('medium', ['limit' => 0]); v1_put($s, 'me', v1_tile($s, 'c1', 'charm', 3, 'body', 'tool'), 1, 2); v1_put($s, 'env', v1_env('rain'), 2, 2); $ev = v1_place($s, 'me', v1_tile($s, 'h1', 'hurt', 5, 'mind', 'pal'), 3, 2);
chk('Teamwork: an environment piece is no source, and it does not break Teamwork either (pal + tool through Rain: +30%)', $ev && ($ev[0]['tw'] ?? 0) === PFB_TEAM2 && !isset($ev[1]['tw']), $ev[0]['tw'] ?? null);

$s = v1_bare('medium', ['limit' => 0]); $s['me']['hp'] = 5; v1_put($s, 'me', v1_tile($s, 'r1', 'heal', 3, 'body'), 1, 2); v1_put($s, 'env', v1_env('sun'), 2, 2); $ev = v1_place($s, 'me', v1_tile($s, 'g1', 'guard', 4, 'mind'), 3, 2);
chk('Sun doubles EVERY type: a Guard piece gives double guard and a Heal piece heals double', $ev && $ev[0]['v'] === 8 && $s['me']['block'] === 8 && $ev[2]['v'] === 6 && $s['me']['hp'] === 11 && ($ev[0]['sun'] ?? 0) === 1 && ($ev[2]['sun'] ?? 0) === 1, [$ev[0]['v'] ?? null, $s['me']['block'], $s['me']['hp']]);

// ---- Mud's teeth
$mt = function (array $over = [], ?array $mudAt = [3, 1], string $who = 'me') {   // [charm 4 at 1,2] [your Hurt 8 placed at 2,2], a Mud next to the placed piece only
    $s = v1_bare('medium', $over + ['limit' => 0]); $a = v1_put($s, $who, v1_tile($s, $who === 'me' ? 'c1' : 'f:c1', 'charm', 4, 'body', $who === 'me' ? 'knack' : 'creature'), 1, 2);
    if ($mudAt) v1_put($s, 'env', v1_env('mud', null, false), $mudAt[0], $mudAt[1]);
    return [$s, $a];
};
$h8 = v1_tile(v1_bare(), 'h8', 'hurt', 8, 'mind');
[$s, $a] = $mt([], [2, 1]); $fh0 = $s['fh']['now']; $ev = v1_place($s, 'me', $h8, 2, 2);
chk('Mud\'s teeth: your piece standing next to a Mud counts 25% less (8 -> 6, flagged mud); the piece of the chain that is not next to it counts in full', $ev && count($ev) === 2 && $ev[0]['v'] === 6 && ($ev[0]['mud'] ?? 0) === 1 && $ev[1]['v'] === 4 && !isset($ev[1]['mud']) && abs($s['fh']['now'] - $fh0 - 6 * $s['hm']) < 1e-9, array_map(fn($x) => [$x['v'], $x['mud'] ?? 0], $ev ?? []));
[$s, $a] = $mt([], null); $ev = v1_place($s, 'me', $h8, 2, 2);
chk('no Mud next to it: full value, no flag', $ev && $ev[0]['v'] === 8 && !isset($ev[0]['mud']));
[$s, $a] = $mt([], [3, 1]); $ev = v1_place($s, 'me', $h8, 2, 2);
chk('a Mud that only touches a corner does not count (next to = the four sides)', $ev && $ev[0]['v'] === 8 && !isset($ev[0]['mud']));
[$s, $a] = $mt([], [1, 1]); $ev = v1_place($s, 'me', $h8, 2, 2);
chk('the linked piece next to the Mud is the one that is weakened (charm 4 -> 3)', $ev && $ev[0]['v'] === 8 && $ev[1]['v'] === 3 && ($ev[1]['mud'] ?? 0) === 1, array_map(fn($x) => $x['v'], $ev ?? []));
[$s, $a] = $mt([], [2, 1], 'me'); $hp0 = $s['me']['hp']; $ev = v1_place($s, 'foe', v1_tile($s, 'f:h', 'hurt', 8, 'mind', 'creature'), 2, 2);
chk('the same for the creature: its Hurt 8 next to a Mud hits for 6', $ev && $ev[0]['v'] === 6 && $hp0 - $s['me']['hp'] === 6 && ($ev[0]['mud'] ?? 0) === 1, $ev[0]['v'] ?? null);
[$s, $a] = $mt(['mud' => 0.5], [2, 1]); $ev = v1_place($s, 'me', $h8, 2, 2); [$s2] = $mt(['mud' => 0], [2, 1]); $ev2 = v1_place($s2, 'me', $h8, 2, 2);
chk('rule value mud: 0.5 halves, 0 switches the teeth off', $ev && $ev[0]['v'] === 4 && $ev2 && $ev2[0]['v'] === 8 && !isset($ev2[0]['mud']), [$ev[0]['v'] ?? null, $ev2[0]['v'] ?? null]);
[$s, $a] = $mt([], [2, 1]); v1_put($s, 'env', v1_env('sun'), 2, 3); $ev = v1_place($s, 'me', $h8, 2, 2);
chk('Sun and Mud together: doubled, then a quarter off (8 -> 16 -> 12)', $ev && $ev[0]['v'] === 12 && ($ev[0]['sun'] ?? 0) === 1 && ($ev[0]['mud'] ?? 0) === 1, $ev[0]['v'] ?? null);
[$s, $a] = $mt([], [2, 1]); $s['me']['hand'] = [$h8]; $s['turn'] = 1; $pv = pfb_cell_preview($s, 0)['2,2'] ?? null;
chk('lit-cell numbers: the weakened damage and how many of your pieces a Mud weakens', $pv && $pv['dmg'] === 6 && $pv['mud'] === 1, $pv);
$s = v1_bare('medium', ['limit' => 0]); v1_put($s, 'env', v1_env('mud', null, false), 3, 1); v1_put($s, 'env', v1_env('rain'), 2, 2); v1_put($s, 'env', v1_env('bramble'), 2, 1); $fh0 = $s['fh']['now']; $ev = v1_place($s, 'me', v1_tile($s, 'g1', 'guard', 1, 'mind'), 1, 2);
chk('environment pieces next to a Mud keep their full effect (Bramble still takes a tenth)', $ev && abs($s['fh']['now'] - $fh0 - PFB_BRAMBLE * $s['fh']['max']) < 1e-9 && !array_filter($ev, fn($x) => isset($x['mud'])), $s['fh']['now'] - $fh0);

// ---- Bramble, Thornburst, Rain
[$s, $a, $e] = $mk('bramble'); $hp0 = $s['me']['hp']; $fh0 = $s['fh']['now']; $ev = v1_place($s, 'me', $swing, 3, 2); $want = PFB_BRAMBLE * $s['fh']['max'];
chk('Bramble in your chain: the creature loses a tenth of its bar, you lose nothing (event: foe = that, me = 0, for me)', $ev && abs($s['fh']['now'] - $fh0 - $want - 5 * $s['hm']) < 1e-9 && $s['me']['hp'] === $hp0 && $ev[1]['kind'] === 'bramble' && $ev[1]['foe'] === round($want, 1) && $ev[1]['me'] === 0 && $ev[1]['for'] === 'me', [$s['fh']['now'] - $fh0, $want]);
[$s, $a, $e] = $mk('bramble'); $s['me']['block'] = 50; $hp0 = $s['me']['hp']; $fh0 = $s['fh']['now']; $ev = v1_place($s, 'foe', v1_tile($s, 'f:g', 'guard', 2, 'mind', 'creature'), 3, 2); $want = max(1, (int)round(PFB_BRAMBLE * $s['me']['max']));
chk('Bramble in the creature\'s chain: you lose a tenth of your health (guard does not help), the creature nothing', $ev && $hp0 - $s['me']['hp'] === $want && $s['fh']['now'] === $fh0 && $ev[1]['me'] === $want && $ev[1]['foe'] === 0.0 && $ev[1]['for'] === 'foe' && $s['me']['block'] === 50, [$hp0 - $s['me']['hp'], $want]);
[$s, $a, $e] = $mk('thorn'); $hp0 = $s['me']['hp']; $fh0 = $s['fh']['now']; $ev = v1_place($s, 'me', v1_tile($s, 'g1', 'guard', 2, 'mind'), 3, 2); $want = max(1, (int)round(PFB_THORN * $s['me']['max']));
chk('Thornburst in your chain: YOU lose a tenth of your health, the creature nothing', $ev && $hp0 - $s['me']['hp'] === $want && $s['fh']['now'] === $fh0 && $ev[1]['kind'] === 'thorn' && $ev[1]['me'] === $want && $ev[1]['foe'] === 0.0, [$hp0 - $s['me']['hp'], $want]);
[$s, $a, $e] = $mk('thorn'); $hp0 = $s['me']['hp']; $fh0 = $s['fh']['now']; $ev = v1_place($s, 'foe', v1_tile($s, 'f:g', 'guard', 2, 'mind', 'creature'), 3, 2);
chk('Thornburst in the creature\'s chain: the creature loses HALF as much (5% of its bar), you nothing', $ev && PFB_THORN_FOE === 0.5 && abs($s['fh']['now'] - $fh0 - 0.05 * $s['fh']['max']) < 1e-9 && $s['me']['hp'] === $hp0 && $ev[1]['for'] === 'foe' && $ev[1]['me'] === 0, $s['fh']['now'] - $fh0);
[$s, $a, $e] = $mk('thorn', 'me', ['th_foe' => 1, 'thorn' => 0.2]); $fh0 = $s['fh']['now']; v1_place($s, 'foe', v1_tile($s, 'f:g', 'guard', 2, 'mind', 'creature'), 3, 2);
chk('rule values thorn and th_foe scale it (0.2 x 1 for the creature)', abs($s['fh']['now'] - $fh0 - 0.2 * $s['fh']['max']) < 1e-9, $s['fh']['now'] - $fh0);
[$s, $a, $e] = $mk('rain'); $g0 = $s['me']['block']; $ev = v1_place($s, 'me', $swing, 3, 2); $want = max(1, (int)round(PFB_RAIN * $s['me']['max']));
chk('Rain in your chain: you get guard worth 15% of your health (event guard and v)', $ev && $s['me']['block'] - $g0 === $want && $ev[1]['kind'] === 'rain' && $ev[1]['guard'] === $want && $ev[1]['v'] === $want && $s['foe']['block'] === 0, [$s['me']['block'] - $g0, $want]);
[$s, $a, $e] = $mk('rain'); $ev = v1_place($s, 'foe', v1_tile($s, 'f:h', 'hurt', 1, 'mind', 'creature'), 3, 2); $want = max(1, (int)round(PFB_RAIN * $s['fh']['max']));
chk('Rain in the creature\'s chain: the creature gets guard worth 15% of its bar, you none', $ev && $s['foe']['block'] === $want && $s['me']['block'] === 0 && $ev[1]['for'] === 'foe', [$s['foe']['block'], $want]);
[$s, $a, $e] = $mk('bramble'); $s['fh']['now'] = $s['fh']['max'] * 0.95; $s['hm'] = 0.0; $ev = v1_place($s, 'me', $swing, 3, 2);
chk('Bramble can end the fight (the creature backs off mid-chain; the pieces after it do not fire)', $s['over'] === 'seen_off' && count($ev) === 2, [$s['over'], count($ev ?? [])]);
[$s, $a, $e] = $mk('thorn'); $s['me']['hp'] = 2; $ev = v1_place($s, 'me', $swing, 3, 2);
chk('Thornburst can end the fight (your last health: defeat)', $s['over'] === 'defeat' && $s['me']['hp'] === 0, [$s['over'], $s['me']['hp']]);
[$s, $a, $e] = $mk('thorn'); $s['me']['hand'] = [$swing]; $s['turn'] = 1; $pv = pfb_cell_preview($s, 0)['3,2'] ?? null;
chk('lit-cell numbers count the environment piece in the chain (n 3, uses up) and show the health Thornburst costs you', $pv && $pv['n'] === 3 && $pv['used'] === true && $pv['hp'] === max(1, (int)round(PFB_THORN * $s['me']['max'])) && $pv['dmg'] === 5, $pv);
[$s, $a, $e] = $mk('sun'); $s['me']['hand'] = [$swing]; $pv = pfb_cell_preview($s, 0)['3,2'] ?? null;
chk('lit-cell numbers: a Sun chain shows the doubled damage and how many of your pieces it doubles', $pv && $pv['dmg'] === 10 && $pv['sun'] === 2, $pv);

// ---- Wind
$wind = function (string $dir, array $extra = [], string $size = 'medium') use ($swing) {   // Wind at 2,2 with its arrow; the creature's guard piece at 3,2; you place at 1,2
    $s = v1_bare($size, ['limit' => 0]); $w = v1_put($s, 'env', v1_env('wind', $dir), 2, 2); $t = v1_put($s, 'foe', v1_tile($s, 'f:g', 'guard', 2, 'body', 'creature'), 3, 2);
    foreach ($extra as [$x, $y]) v1_put($s, 'foe', ['ed' => array_fill_keys(['L', 'R', 'T', 'B'], ['flat', null])] + v1_tile($s, 'f:x', 'guard', 1, 'body', 'creature'), $x, $y);
    $ev = v1_place($s, 'me', $swing, 1, 2);
    return [$s, $w, $t, $ev];
};
[$s, $w, $t, $ev] = $wind('R'); $we = $ev[1] ?? [];
chk('Wind: the piece its arrow points at slides one cell along the arrow (cell map, piece, event moved and dir)', $ev && $we['kind'] === 'wind' && $we['dir'] === 'R' && ($we['moved'] ?? null) === ['id' => $t, 'by' => 'foe', 'n' => 'F:g', 'x' => 4, 'y' => 2] && [$s['pcs'][$t]['x'], $s['pcs'][$t]['y']] === [4, 2] && ($s['cell']['4,2'] ?? null) === $t && !isset($s['cell']['3,2']), $we);
chk('Wind: the pushed piece was linked when the chain started, so it still fires in this chain; afterwards it no longer touches the Wind', count($ev) === 3 && $ev[2]['by'] === 'foe' && pfb_links($s, $w) === [$s['pid']], [count($ev), pfb_links($s, $w)]);
chk('Wind: the line names the pushed piece', str_contains(pfight_line($we, 'Owl'), 'Owl’s F:g is pushed'), pfight_line($we, 'Owl'));
[$s, $w, $t, $ev] = $wind('R', [[4, 2]]);
chk('Wind: nothing moves when the cell behind is taken', $ev && !isset($ev[1]['moved']) && [$s['pcs'][$t]['x'], $s['pcs'][$t]['y']] === [3, 2] && str_contains(pfight_line($ev[1], 'Owl'), 'nothing moves'), $ev[1] ?? null);
[$s, $w, $t, $ev] = $wind('T');
chk('Wind: nothing moves when no piece stands on the arrow\'s side', $ev && !isset($ev[1]['moved']) && $ev[1]['dir'] === 'T' && count($s['cell']) === 3);
$s = v1_bare('medium', ['limit' => 0]); $w = v1_put($s, 'env', v1_env('wind', 'R'), 3, 2); $t = v1_put($s, 'foe', v1_tile($s, 'f:g', 'guard', 2, 'body', 'creature'), 4, 2); $ev = v1_place($s, 'me', $swing, 2, 2);
chk('Wind: it never pushes a piece off the board', $ev && !isset($ev[1]['moved']) && $s['pcs'][$t]['x'] === 4);
$s = v1_bare('medium', ['limit' => 0]); $w = v1_put($s, 'env', v1_env('wind', 'L'), 2, 2); $own = v1_put($s, 'me', v1_tile($s, 'c1', 'charm', 3, 'body'), 1, 2); $ev = v1_place($s, 'me', $swing, 3, 2);
chk('Wind: it pushes your own piece just the same', $ev && ($ev[1]['moved']['id'] ?? null) === $own && $s['pcs'][$own]['x'] === 0);
$s = v1_bare('medium', ['limit' => 0]); $w = v1_put($s, 'env', v1_env('wind', 'R'), 2, 2); $s['pcs'][++$s['pid']] = ['id' => $s['pid'], 'by' => 'none', 'tile' => ['k' => 'blank', 'n' => 'Blank', 't' => 'blank', 'v' => 0, 'tag' => '', 'r' => null], 'x' => 3, 'y' => 2, 'born' => 1, 'seq' => ++$s['seq']]; $s['cell']['3,2'] = $s['pid']; $bl = $s['pid']; $ev = v1_place($s, 'me', $swing, 1, 2);
chk('Wind: the blank centre piece never moves', $ev && !isset($ev[1]['moved']) && $s['pcs'][$bl]['x'] === 3);
$s = v1_bare(); v1_put($s, 'foe', v1_tile($s, 'f:g', 'guard', 2, 'body', 'creature'), 3, 2); v1_put($s, 'foe', v1_tile($s, 'f:g2', 'guard', 2, 'body', 'creature'), 0, 2); $dirs = [];
for ($i = 0; $i < 12; $i++) $dirs[pfb_env_wind_dir($s, 2, 2)] = 1;
chk('Wind\'s arrow when it is placed: toward a piece that has a free cell behind it (here only the right side; the left piece stands at the edge)', array_keys($dirs) === ['R'], array_keys($dirs));
$s = v1_bare(); $dirs = []; for ($i = 0; $i < 40; $i++) $dirs[pfb_env_wind_dir($s, 2, 2)] = 1; ksort($dirs);
chk('Wind\'s arrow with nothing to push: any of the four sides', array_keys($dirs) === ['B', 'L', 'R', 'T'], array_keys($dirs));
$s = v1_bare(); v1_put($s, 'foe', v1_tile($s, 'f:c', 'charm', 3, 'body', 'creature'), 2, 2); $s['env'] = ['draw' => [v1_env('rain')], 'discard' => [], 'next' => [v1_env('wind', null, false)]]; pfb_env_place($s); $wp = $s['pcs'][$s['pid']];
chk('a placed Wind carries its arrow (piece, log note, view); the arrow is gone when the piece returns to the deck', isset(PFB_SIDE[$wp['tile']['dir'] ?? '']) && $s['envlog'][0]['dir'] === $wp['tile']['dir'] && array_column(pfb_view($s)['pcs'], null, 'id')[$wp['id']]['dir'] === $wp['tile']['dir'] && (function () use ($s, $wp) { $w = $s; pfb_discard($w, $wp); return !isset($w['env']['discard'][0]['dir']) && $w['env']['discard'][0]['env'] === 'wind'; })(), $wp['tile']['dir'] ?? null);

// ---- Mud
$s = v1_bare(); $mid = v1_put($s, 'env', v1_env('mud', null, false), 2, 2); $j = pfb_check($s, $swing, 3, 2);
chk('Mud: a piece fits against it on any side but never links', $j !== null && !pfb_has_link($j) && pfb_check($s, $swing, 1, 2) !== null && pfb_check($s, $swing, 2, 1) !== null && pfb_check($s, $swing, 2, 3) !== null && pfb_links($s, $mid) === []);
$oth = v1_put($s, 'foe', v1_tile($s, 'f:c', 'charm', 3, 'body', 'creature'), 2, 0);
chk('Mud: while a linking spot exists, the spots that only touch Mud are not offered', !in_array([3, 2], pfb_cells($s, $swing, 'me'), true) && in_array([3, 2], pfb_cells($s, $swing), true) && pfb_cells($s, $swing, 'me') !== []);
$s = v1_bare(); $mid = v1_put($s, 'env', v1_env('mud', null, false), 2, 2); $a = v1_put($s, 'me', v1_tile($s, 'c1', 'charm', 3, 'body'), 1, 2); $b = v1_put($s, 'me', v1_tile($s, 'h3', 'hurt', 3, 'body'), 3, 3); $ev = v1_place($s, 'me', $swing, 3, 2);
chk('Mud: chains stop at it: the piece on its far side does not fire, Mud itself never fires and is never used up', $ev && array_column($ev, 'id') === [$s['pid'], $b] && !in_array($a, array_column($ev, 'id'), true) && !in_array($mid, array_column($ev, 'id'), true) && isset($s['pcs'][$mid]) && !array_filter($ev, fn($x) => $x['by'] === 'env'), array_column($ev ?? [], 'id'));

// ---- life, expiry, the replay notes
$s = v1_bare('medium'); $s['foe']['hand'] = []; $s['foe']['draw'] = []; $s['foe']['discard'] = []; v1_put($s, 'me', v1_tile($s, 'a', 'guard', 1, 'body', 'knack', ['life' => 4]), 2, 2);
$s['env'] = ['draw' => [], 'discard' => [], 'next' => [v1_env('sun', null, false)]]; $r0 = $s['round']; pfb_end_round($s); $eid = null; foreach ($s['pcs'] as $p) if ($p['by'] === 'env') $eid = $p['id'];
$seen = [$s['round'] => isset($s['pcs'][$eid])]; $s['env']['next'] = []; $s['env']['draw'] = [];
pfb_end_round($s); $seen[$s['round']] = isset($s['pcs'][$eid]); $log2 = $s['envlog']; pfb_end_round($s); $seen[$s['round']] = isset($s['pcs'][$eid]); $log3 = $s['envlog'];
chk('life: a Sun (2 rounds) placed at the end of round 1 is there in rounds 2 and 3 and gone in round 4', $eid !== null && $seen === [$r0 + 1 => true, $r0 + 2 => true, $r0 + 3 => false], $seen);
$exn = array_values(array_filter($log3, fn($L) => $L['k'] === 'expire'));
chk('expiry: the environment\'s turn notes it (expire, the piece ids), the piece is in the gone list by env and back in the environment\'s discard', count($exn) === 1 && $exn[0]['ids'] === [$eid] && !array_filter($log2, fn($L) => $L['k'] === 'expire') && count(array_filter($s['gone'], fn($g) => $g['by'] === 'env' && $g['id'] === $eid)) === 1 && count($s['env']['discard']) === 1, $log3);
$ee = array_values(array_filter(pfb_env_events($s), fn($e) => $e['env'] === 'expire'));
chk('expiry is an event with a line', count($ee) === 1 && $ee[0]['ids'] === [$eid] && $ee[0]['ta'] === 'env' && str_contains(pfight_line($ee[0], 'Owl'), 'fades'), $ee);
[$s, $a, $e] = $mk('bramble'); $ev = v1_place($s, 'me', $swing, 3, 2); $chip = pfight_chip_event($ev[1], 4); $ln = pfight_line($ev[1], 'Owl');
chk('an environment piece that fired: its line and its history chip (by env, the kind as tag, what it cost, who it hit)', str_contains($ln, 'Bramble') && str_contains($ln, 'Owl loses') && $chip['by'] === 'env' && $chip['tags'] === ['bramble'] && $chip['tg'] === 'foe' && $chip['id'] === $e && str_contains($chip['txt'], 'creature -'), [$ln, $chip]);
chk('the chain glow (fx) lists the environment piece among the pieces that fired', pfb_fx($ev) === [['by' => 'me', 'ids' => [$ev[0]['id'], $e, $a]]], pfb_fx($ev));
foreach (['sun' => 'count double', 'rain' => 'guard', 'thorn' => 'you lose'] as $kind => $word) { [$s, $a, $e] = $mk($kind); $ev = v1_place($s, 'me', $swing, 3, 2); chk("line for $kind says \"$word\"", str_contains(pfight_line($ev[1], 'Owl'), $word), pfight_line($ev[1], 'Owl')); }

// ---- the creature and the environment
[$s, $a, $e] = $mk('bramble', 'foe'); $s['foe']['hand'] = [v1_tile($s, 'f:h', 'hurt', 3, 'mind', 'creature')]; $m = pfb_search($s, 'foe');
chk('the creature\'s search may link to an environment piece (it is a legal, linking cell for it)', $m !== null && in_array([$m[1], $m[2]], [[3, 2], [2, 1], [2, 3]], true), $m);
[$s, $a, $e] = $mk('thorn', 'foe'); v1_put($s, 'me', v1_tile($s, 'c9', 'charm', 3, 'body'), 4, 0); $s['foe']['hand'] = [v1_tile($s, 'f:h', 'hurt', 3, 'mind', 'creature')]; $m = pfb_search($s, 'foe');
chk('the creature\'s search avoids Thornburst when another linking cell is as good', $m !== null && !in_array([$m[1], $m[2]], [[3, 2], [2, 1], [2, 3]], true), $m);

// ---- a fight started under 2.6.74
$s = pfb_new(v1_me(), v1_foe('large'), 12, ['v1' => V1_OLD, 'blank' => true]); unset($s['v1']['env'], $s['v1']['envn'], $s['v1']['rain'], $s['v1']['th_foe'], $s['v1']['mud'], $s['v1']['envcap']); $s = json_decode(json_encode($s), true);
$hadTer = $s['ter'] !== []; pfb_start($s, 0, 'L'); $kinds = []; $t = 0; $bad0 = false;
while (!$s['over'] && $t++ < 40) { $m = pfb_search($s, 'me'); $r = $m ? pfb_play($s, [[$m[0], $m[1], $m[2]]], $s['turn']) : pfb_pass($s, $s['turn']); if ($r['err']) { $bad0 = true; break; } foreach ($r['ev'] as $e) if (isset($e['env'])) $kinds[$e['env']] = 1; if (isset($s['env']) || array_filter($s['pcs'], fn($p) => $p['by'] === 'env')) $bad0 = true; }
chk('a fight saved by 2.6.74 (v1 without the env keys) plays on to its end with its ground and forecast events, and never gets an environment piece', $hadTer && !$bad0 && $s['over'] !== null && !array_intersect(array_keys($kinds), ['fire', 'place', 'pass', 'expire']) && count(array_intersect(array_keys($kinds), ['sunbeam', 'creep', 'puddle', 'gust', 'thorn', 'bramble'])) >= 3 && !isset(pfb_view($s)['env']) && pfb_view($s)['v1']['env'] === false, [$s['over'], array_keys($kinds)]);
