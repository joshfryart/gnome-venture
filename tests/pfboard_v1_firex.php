<?php
// 33: 2.7.31 FIRE-BUDGET EXTRAS (required by pfboard_v1.php; docs/puzzle-board-proposals.md P9). Rule key firex: a creature piece falls away after PFB_FOE_FIRES (2) firings; with firex a boss's pieces fire
// one more time, and so does a creature Guard piece or any Hold piece (a boss Guard: two more). Your pieces are never limited. A fight saved without the key keeps 2. Mirrored in tools/pfengine.js (fireLimit / fireLim).
echo "== 33. fire-budget extras: a boss and the creature's Guard / Hold pieces fire longer (2.7.31)\n";
$fx = function (string $size, array $over = [], array $s0 = []) { $s = v1_bare($size, $over + ['firex' => 1]); if ($size === 'boss') $s['boss'] = true; return $s; };
$spent = function (array &$s, string $who, array $tile, int $f) { $id = v1_put($s, $who, $tile, 2, 2); $s['pcs'][$id]['f'] = $f; pfb_spend($s); return isset($s['pcs'][$id]); };
chk('a new fight has firex on; a fight saved without the key resolves it to 0 (PRE)', pfb_v1r(pfb_new(v1_me(), v1_foe('medium'), 5, ['v1' => true]), 'firex') === 1 && PFB_V1_PRE['firex'] === 0);

// the limits themselves
$s = $fx('medium'); $hurt = v1_tile($s, 'c1', 'hurt', 5, 'body', 'creature'); $guard = v1_tile($s, 'c2', 'guard', 5, 'body', 'creature'); $hold = v1_tile($s, 'c3', 'guard', 5, 'body', 'creature', ['tag' => 'hold']);
$lim = fn(array $s, string $by, array $t) => pfb_fire_lim($s, ['by' => $by, 'tile' => $t]);
chk('plain creature (not a boss): Hurt 2, Guard 3, a Hold Guard 3 (the two do not add up)', $lim($s, 'foe', $hurt) === 2 && $lim($s, 'foe', $guard) === 3 && $lim($s, 'foe', $hold) === 3, [$lim($s, 'foe', $hurt), $lim($s, 'foe', $guard), $lim($s, 'foe', $hold)]);
$b = $fx('boss'); chk('boss: Hurt 3, Guard 4, your pieces unlimited (0)', $lim($b, 'foe', $hurt) === 3 && $lim($b, 'foe', $guard) === 4 && $lim($b, 'me', $guard) === 0 && $lim($b, 'me', $hurt) === 0, [$lim($b, 'foe', $hurt), $lim($b, 'foe', $guard)]);
$o = $fx('medium', ['firex' => 0]); chk('rule off (a fight saved before 2.7.31): every creature piece 2, boss too', $lim($o, 'foe', $hurt) === 2 && $lim($o, 'foe', $guard) === 2 && $lim($o, 'foe', $hold) === 2, [$lim($o, 'foe', $guard)]);
$ob = $fx('boss', ['firex' => 0]); chk('rule off: a boss Hurt is still 2', $lim($ob, 'foe', $hurt) === 2);

// the fall-away itself (after the chain, in pfb_spend)
$s = $fx('medium'); $stay = $spent($s, 'foe', $guard, 2); $s2 = $fx('medium'); $gone = $spent($s2, 'foe', $guard, 3);
chk('rule on: a creature Guard that has fired twice stays, at three it falls away', $stay === true && $gone === false, [$stay, $gone]);
$s = $fx('medium', ['firex' => 0]); chk('rule off: the same Guard falls away after two', $spent($s, 'foe', $guard, 2) === false);
$s = $fx('medium'); chk('rule on: a plain creature Hurt still falls away after two', $spent($s, 'foe', $hurt, 2) === false);
$s = $fx('boss'); $st = $spent($s, 'foe', $hurt, 2); $s2 = $fx('boss'); $gn = $spent($s2, 'foe', $hurt, 3);
chk('rule on, boss: a Hurt that has fired twice stays, at three it falls away', $st === true && $gn === false, [$st, $gn]);
$s = $fx('boss', ['firex' => 0]); chk('rule off, boss: it falls away after two (as before)', $spent($s, 'foe', $hurt, 2) === false);
$s = $fx('boss'); chk('rule on, boss Guard: still there at three, gone at four', $spent($s, 'foe', $guard, 3) === true && ($s2 = $fx('boss')) && $spent($s2, 'foe', $guard, 4) === false);
$s = $fx('boss'); chk('your piece is never limited, however often it fired', $spent($s, 'me', $hurt, 9) === true);

// a piece the creature really places counts its firings and the view says how many are left
$s = $fx('medium'); $s['foe']['hand'] = []; $a = v1_put($s, 'me', v1_tile($s, 'dodge', 'guard', 2, 'body'), 1, 2); $s['foe']['hand'] = [$guard]; $cells = pfb_cells($s, $guard, 'foe');
if ($cells) { pfb_place($s, 'foe', 0, $cells[0][0], $cells[0][1]); $ids = array_keys(array_filter($s['pcs'], fn($p) => $p['by'] === 'foe')); $fl = null; foreach (pfb_view($s)['pcs'] as $p) if ($p['by'] === 'foe') $fl = $p['fl']; }
chk('the view shows firings left from the fight\'s own rules: a creature Guard just placed has 2 left (3 - 1), a Hurt 1 (2 - 1)', $cells && $fl === 2, $fl ?? 'no cell');
$s = $fx('medium'); $s['foe']['hand'] = []; v1_put($s, 'me', v1_tile($s, 'dodge', 'guard', 2, 'body'), 1, 2); $s['foe']['hand'] = [$hurt]; $cells = pfb_cells($s, $hurt, 'foe'); $fl = null;
if ($cells) { pfb_place($s, 'foe', 0, $cells[0][0], $cells[0][1]); foreach (pfb_view($s)['pcs'] as $p) if ($p['by'] === 'foe') $fl = $p['fl']; }
chk('a Hurt of the creature just placed has 1 firing left', $cells && $fl === 1, $fl ?? 'no cell');
$v = pfb_view($fx('medium')); chk('the view carries the rule for the page (v1.firex)', (int)($v['v1']['firex'] ?? -1) === 1);
