<?php
// 2.7.01 creature AI (claude/creature-pass/SPEC.md sec 3): one shared scorer, per-species style weights (PFB_AI), the features (dmg bar heal guard strip setup tempo control deny force),
// the compat key `style`, the one-line reason of every creature move, a search that sees the turn it will really play (its guard reset, Ambush live), and the legal-full-fight check of every style.
// Written first: every check fails on the 2.7.00 engine (it has no styles, no reason and no key). No DB, no server.
// php tests/pfboard_v1_ai.php
require __DIR__ . '/../game/includes/pfboard.php';
$GLOBALS['PFB_TEST_SIZES'] = ['small' => [5, 4], 'medium' => [5, 5], 'large' => [7, 5], 'boss' => [7, 6]];
require __DIR__ . '/../game/includes/pfight_game.php';
require __DIR__ . '/../game/includes/pfdeck.php';
$bad = 0; $warn = [];
set_error_handler(function (int $no, string $msg, string $file, int $line) use (&$warn) { $warn[] = "$msg ($file:$line)"; return true; });
function chk(string $name, bool $ok, $got = ''): void { global $bad; echo ($ok ? 'ok   ' : 'FAIL ') . $name . ($ok ? '' : ' (got ' . (is_string($got) ? $got : json_encode($got)) . ')') . "\n"; if (!$ok) $bad++; }
function ai_me(int $lv = 8): array
{
    $m = max(0, intdiv($lv + 3, 14)); $st = ['grit' => $m, 'nimble' => $m, 'hardiness' => $m, 'charm' => $m, 'lore' => $m, 'luck' => $m, 'level' => $lv];
    $max = 20 + 3 * $lv + 5 * $m;
    return ['hp' => $max, 'max_hp' => $max, 'stats' => $st, 'deck' => pf_player_deck($st, 'thornblade', 1, [], pf_unlocks($lv)), 'luck' => $m];
}
function ai_foe(string $size, array $x = []): array { return $x + ['slug' => 'test-thing', 'name' => 'Test Thing', 'size' => $size, 'level' => 8, 'dmg_die' => ['small' => 4, 'medium' => 6, 'large' => 8, 'boss' => 10][$size], 'dmg_bonus' => 2]; }
function ai_tile(array $s, string $k, string $t, int $v, string $tag = '', string $r = 'body'): array
{
    return ['ed' => array_fill_keys(['L', 'R', 'T', 'B'], ['wild', null])] + pfb_v1_tile(['k' => $k, 'n' => ucfirst($k), 't' => $t, 'v' => $v, 'r' => $r, 'tag' => $tag, 'm' => '', 'src' => 'creature'], $s['v1']);   // wild edges: it fits wherever it goes
}
function ai_put(array &$s, string $who, array $tile, int $x, int $y): int
{
    $id = ++$s['pid']; $s['seq']++;
    $s['pcs'][$id] = ['id' => $id, 'by' => $who, 'tile' => $tile, 'x' => $x, 'y' => $y, 'born' => $s['round'], 'seq' => $s['seq']];
    $s['cell']["$x,$y"] = $id;
    return $id;
}
/** An empty-ish v1 fight (4x5 test board): one foe Guard in a corner, no terrain, no events, the creature has the style in its row. */
function ai_fight(string $size = 'medium', array $row = [], array $over = [], int $seed = 7): array
{
    $s = pfb_new(ai_me(), ai_foe($size, $row), $seed, ['v1' => $over + ['order' => 0, 'spawn' => 1]]);
    $s['pcs'] = []; $s['cell'] = []; $s['ter'] = []; $s['envs'] = []; $s['foe']['plan'] = null; $s['spent'] = []; $s['ven'] = []; $s['env'] = ['draw' => [], 'discard' => [], 'next' => []];
    $s['me']['hand'] = []; $s['foe']['hand'] = [];
    ai_put($s, 'foe', ai_tile($s, 'f:base', 'guard', 1), 0, 3);
    return $s;
}
$near = fn(float $a, float $b) => abs($a - $b) < 1e-9;
/** A style as named weights (every style, also balanced, plain). */
function ai_w(string $id): array { $w = ['id' => $id]; foreach (PFB_AI_KEYS as $i => $k) $w[$k] = (float)PFB_AI[$id][$i]; return $w; }
/** The 2.7.00 scorer, written out (the oracle for balanced). */
function old_score(array $b, array $a): float
{
    $barD = ($a['bar']['now'] - $b['bar']['now']) + ($a['fh']['now'] - $b['fh']['now']); $hpD = $a['me']['hp'] - $b['me']['hp']; $tg = 0.0;
    if (!empty($a['v1']['tags'])) {
        $u = 0.05 * $a['me']['max']; $pz = fn(array $z) => (int)($z['me']['poison'] ?? 0) * (int)($z['me']['poison_v'] ?? 0);
        $tg = ($pz($a) - $pz($b)) + $u * (1.0 * ((int)($a['me']['slowdraw'] ?? 0) - (int)($b['me']['slowdraw'] ?? 0)) + 1.5 * ((int)$a['foe']['evade'] - (int)$b['foe']['evade']) + 0.6 * ((int)$a['foe']['thorns'] - (int)$b['foe']['thorns'])
            + 1.0 * ((int)($a['foe']['bashnext'] ?? 0) - (int)($b['foe']['bashnext'] ?? 0)) + 1.5 * ((int)($a['foe']['again'] ?? 0) - (int)($b['foe']['again'] ?? 0)));
    }
    return $tg - 0.8 * $barD - $hpD + 0.4 * ($a['foe']['block'] - $b['foe']['block']) - 0.3 * ($a['me']['block'] - $b['me']['block']) + ($a['over'] === 'defeat' ? 50 : 0);
}

echo "== 1. the table, the maker, the compat key\n";
chk('10 styles; each has the 12 weights, a name and a text of at most 80 characters', count(PFB_AI) === 10 && !array_filter(PFB_AI, fn($r) => count($r) !== 14 || strlen($r[13]) > 80 || $r[12] === ''), array_keys(PFB_AI));
chk('the ids of SPEC 3.3', array_keys(PFB_AI) === ['balanced', 'crowd', 'blocker', 'burst', 'stall', 'healer', 'trickster', 'poisoner', 'guardian', 'ambusher']);
chk('balanced is the 2.7.00 scorer: 1.0 -0.8 0 0.4 0.3 1.0 1.0 0 0 0 1 1', array_slice(PFB_AI['balanced'], 0, 12) == [1.0, -0.8, 0, 0.4, 0.3, 1.0, 1.0, 0, 0, 0, 1, 1]);
chk('every weight is inside -2.5..2.5', !array_filter(PFB_AI, fn($r) => array_filter(array_slice($r, 0, 12), fn($x) => $x < -2.5 || $x > 2.5)));
chk('style is 0 in PRE (a fight saved before 2.7.01) and 1 in a new fight', PFB_V1_PRE['style'] === 0 && pfb_v1_cfg('medium')['style'] === 1 && pfb_v1r(['v1' => ['limit' => 3]], 'style') === 0);
chk('make: unknown id and balanced without overrides give null (the 2.7.00 scorer)', pfb_ai_make('nope') === null && pfb_ai_make('balanced') === null && pfb_ai_make('') === null);
$w = pfb_ai_make('burst');
chk('make: a style gives its 12 weights by name, in the order of PFB_AI_KEYS', array_keys($w) === array_merge(['id'], PFB_AI_KEYS) && $w['id'] === 'burst' && $w['dmg'] === 1.5 && $w['late'] === 0.8, $w);
$w = pfb_ai_make('burst', ['dmg' => 9, 'deny' => -9, 'nope' => 1, 'force' => 0.5]);
chk('make: an override is clamped to -2.5..2.5, an unknown name dropped, at most 2 are taken', $w['dmg'] === 2.5 && $w['deny'] === -2.5 && $w['force'] === 1.0, $w);
chk('make: balanced with an override is a style', pfb_ai_make('balanced', ['deny' => 0.5])['deny'] === 0.5);
$s = ai_fight('medium', ['ai' => 'burst', 'aip' => ['deny' => 0.5]]);
chk('pfb_new: the row\'s style and overrides are kept in the state (foe.ai, foe.aid)', $s['foe']['aid'] === 'burst' && $s['foe']['ai']['dmg'] === 1.5 && $s['foe']['ai']['deny'] === 0.5, $s['foe']['ai'] ?? null);
$s = ai_fight('medium', ['ai' => 'balanced']);
chk('pfb_new: balanced gives no weights (foe.ai absent), only the id', !isset($s['foe']['ai']) && $s['foe']['aid'] === 'balanced');
$s = ai_fight('medium', []);
chk('no style on the row: no key at all (the state is the same as 2.7.00 gave)', !isset($s['foe']['ai']) && !isset($s['foe']['aid']));
$s = ai_fight('medium', ['ai' => 'burst'], ['style' => 0]);
chk('style 0 (a fight saved before 2.7.01): the row\'s style is ignored', !isset($s['foe']['ai']) && !isset($s['foe']['aid']));

echo "== 2. balanced scores exactly as 2.7.00 (the oracle), on real positions\n";
$n = 0; $worst = 0.0; $diff = 0;
foreach ([['small', 'Critter'], ['medium', 'Beast'], ['large', 'Water'], ['boss', 'Plant / Fungus']] as $zi => [$size, $cls]) {
    mt_srand(40 + $zi);
    $s = pfb_new(ai_me(10 + 3 * $zi), ai_foe($size, ['class' => $cls, 'level' => 10 + 3 * $zi]), 9 + $zi, ['v1' => true, 'blank' => true]);
    $s['start'] && pfb_start($s, 0, 'L');
    for ($t = 0; $t < 7 && !$s['over']; $t++) {
        foreach ($s['foe']['hand'] as $hi => $ft) foreach (pfb_cells($s, $ft, 'foe') as [$x, $y]) {
            $w2 = $s; if (pfb_place($w2, 'foe', $hi, $x, $y) === null) continue;
            $a = pfb_score($s, $w2, 'foe'); $o = old_score($s, $w2); $ctx = []; $b2 = pfb_ai_score($s, $w2, ai_w('balanced'), $ctx);
            $n++; $worst = max($worst, abs($a - $o), abs($b2 - $o)); if ($a !== $o) $diff++;
        }
        $m = pfb_search($s, 'me'); $r = $m ? pfb_play($s, [[$m[0], $m[1], $m[2]]], $s['turn']) : pfb_pass($s, $s['turn']);
    }
}
chk("pfb_score on a creature without a style equals the 2.7.00 formula bit for bit ($n placements)", $n > 100 && $diff === 0, [$n, $diff]);
chk('pfb_ai_score with the balanced weights equals it to 1e-9', $worst < 1e-9, $worst);

echo "== 3. the features, one by one (positions built by hand)\n";
$s = ai_fight('medium', ['ai' => 'burst']);
$s['fh']['now'] = 10.0; $s['fh']['max'] = 40.0; $s['bar']['now'] = 0.0;
$u = 0.05 * $s['me']['max'];
$a = $s; $a['fh']['now'] = 4.0;                                                      // it recovered 6
$ctx = []; $f = pfb_feat($s, $a, $ctx);
chk('bar: the rise of the Yield bar (negative = it recovered); heal: the recovery as a positive number', $near($f['bar'], -6.0) && $near($f['heal'], 6.0), [$f['bar'], $f['heal']]);
$a = $s; $a['me']['hp'] -= 5; $ctx = []; $f = pfb_feat($s, $a, $ctx);
chk('dmg: the health you lose', $near($f['dmg'], 5.0), $f['dmg']);
$a = $s; $a['foe']['block'] = $s['foe']['block'] + 4; $a['me']['block'] = 3; $s['me']['block'] = 7; $ctx = []; $f = pfb_feat($s, $a, $ctx);
chk('guard: its own guard gained; strip: your guard removed (positive when it falls)', $near($f['guard'], 4.0) && $near($f['strip'], 4.0), [$f['guard'], $f['strip']]);
$s['me']['block'] = 0;
$a = $s; $a['me']['poison'] = 2; $a['me']['poison_v'] = 3; $a['foe']['evade'] = 1; $a['foe']['thorns'] = true; $a['foe']['bashnext'] = 1; $ctx = []; $f = pfb_feat($s, $a, $ctx);
chk('setup: poison waiting on you (rounds x number) + u x (1.5 evade + 0.6 thorns + 1.0 bash lent)', $near($f['setup'], 6 + $u * (1.5 + 0.6 + 1.0)), $f['setup']);
$a = $s; $a['me']['slowdraw'] = 1; $a['foe']['again'] = 1; $ctx = []; $f = pfb_feat($s, $a, $ctx);
chk('tempo: u x (1.0 for your short draw + 1.5 for its extra piece)', $near($f['tempo'], $u * 2.5), $f['tempo']);
chk('setup and tempo split the old tg term exactly', $near($f['setup'] + $f['tempo'], $u * 2.5));
$s2 = $s; foreach ([[1, 3], [2, 3], [3, 3]] as [$x, $y]) ai_put($s2, 'foe', ai_tile($s2, "f:p$x", 'guard', 1), $x, $y);   // 4 pieces out already
$a = $s2; ai_put($a, 'foe', ai_tile($a, 'f:new', 'hurt', 3), 4, 3); $ctx = []; $f = pfb_feat($s2, $a, $ctx);
chk('control: u x its pieces out after minus before, counted to at most 4 (already 4: nothing)', $near($f['control'], 0.0), $f['control']);
$a = $s; ai_put($a, 'foe', ai_tile($a, 'f:new', 'hurt', 3), 1, 3); $ctx = []; $f = pfb_feat($s, $a, $ctx);
chk('control: one more piece out (1 -> 2) = u', $near($f['control'], $u), $f['control']);
// deny and force on a board where the count is easy: wild pieces fit anywhere that touches a piece
$s3 = ai_fight('medium', ['ai' => 'blocker']);
$s3['me']['hand'] = [ai_tile($s3, 'm:a', 'hurt', 3), ai_tile($s3, 'm:b', 'guard', 2)];
$mv = pfb_my_moves($s3); $cells = []; foreach ($mv as $q) $cells[$q[1] . ',' . $q[2]] = 1;
chk('reach: your legal cells (distinct), as pfb_cells gives them', count($cells) === count(array_unique(array_merge(array_map(fn($c) => $c[0] . ',' . $c[1], pfb_cells($s3, $s3['me']['hand'][0], 'me')), array_map(fn($c) => $c[0] . ',' . $c[1], pfb_cells($s3, $s3['me']['hand'][1], 'me'))))), count($cells));
$a = $s3; ai_put($a, 'foe', ai_tile($a, 'f:blk', 'guard', 2), 1, 3);                // a piece beside the corner piece: your cells change
$rb = count($cells); $ra = count(array_unique(array_map(fn($q) => $q[1] . ',' . $q[2], pfb_my_moves($a))));
$ctx = ['w' => ai_w('blocker')]; $f = pfb_feat($s3, $a, $ctx);
chk('deny: 0.1 x your max health x (reach before - reach after) / reach before', $near($f['deny'], 0.1 * $s3['me']['max'] * ($rb - $ra) / max(1, $rb)), [$f['deny'], $rb, $ra]);
$s4 = ai_fight('medium', ['ai' => 'burst']); ai_put($s4, 'foe', ai_tile($s4, 'f:h', 'hurt', 4), 1, 3);
$s4['me']['hand'] = [ai_tile($s4, 'm:a', 'hurt', 3)];
$pairs = pfb_my_moves($s4); $link = 0; foreach ($pairs as $q) foreach ($q[3] as $j) if ($j[2] && $s4['pcs'][$j[1]]['by'] === 'foe' && $s4['pcs'][$j[1]]['tile']['t'] === 'hurt') { $link++; break; }
$ctx = ['w' => ai_w('burst')]; $f = pfb_feat($s4, $s4, $ctx);
chk('force: 0.1 x your max health x the share of your legal (piece, cell) pairs that link to one of its Hurt pieces', $near($f['force'], 0.1 * $s4['me']['max'] * $link / max(1, count($pairs))) && $link > 0 && $link < count($pairs), [$f['force'], $link, count($pairs)]);
$ctx = ['w' => ai_w('balanced')]; $f1 = pfb_feat($s4, $s4, $ctx);
chk('deny and force are not computed when their weight is 0 (the cost: keys are 0)', $f1['deny'] === 0.0 && $f1['force'] === 0.0, $f1);

echo "== 4. the score is the dot product; the ramp moves the dmg weight; a defeat is worth 50\n";
$s = ai_fight('medium', []);
$a = $s; $a['me']['hp'] -= 4; $a['fh']['now'] += 2.0;
$w = ai_w('burst'); $ctx = [];
$sc = pfb_ai_score($s, $a, $w, $ctx);
chk('burst on round 1: dmg weight 1.5 x early 1.6, bar -0.5', $near($sc, 1.5 * 1.6 * 4 - 0.5 * 2.0), $sc);
$s['round'] = 5; $a['round'] = 5; $ctx = [];
chk('burst on round 5: dmg weight 1.5 x late 0.8', $near(pfb_ai_score($s, $a, $w, $ctx), 1.5 * 0.8 * 4 - 0.5 * 2.0));
$s['round'] = 2; $ctx = [];
chk('round 2 is still early, round 3 is late', $near(pfb_ai_score($s, $a, $w, $ctx), 1.5 * 1.6 * 4 - 0.5 * 2.0) && (function () use ($s, $a, $w) { $s['round'] = 3; $a['round'] = 3; $c = []; return abs(pfb_ai_score($s, $a, $w, $c) - (1.5 * 0.8 * 4 - 0.5 * 2.0)) < 1e-9; })());
$a2 = $a; $a2['over'] = 'defeat'; $s['round'] = 5; $a2['round'] = 5; $ctx = [];
chk('a defeat adds 50', $near(pfb_ai_score($s, $a2, $w, $ctx) - pfb_ai_score($s, $a, $w, $ctx), 50.0));
$s = ai_fight('medium', ['ai' => 'burst']); $a = $s; $a['me']['hp'] -= 4;
chk('pfb_score reads foe.ai (burst) and is not the balanced number', abs(pfb_score($s, $a, 'foe') - old_score($s, $a)) > 0.5 && (($c0 = []) || true) && $near(pfb_score($s, $a, 'foe'), pfb_ai_score($s, $a, ai_w('burst'), $c0)), pfb_score($s, $a, 'foe'));
chk('the player side (who = me) ignores foe.ai', (function () use ($s, $a) { $s2 = $s; unset($s2['foe']['ai']); $a2 = $a; unset($a2['foe']['ai']); return pfb_score($s, $a, 'me') === pfb_score($s2, $a2, 'me'); })());

echo "== 5. styles choose differently on the same position\n";
// hand: a big Hurt, a Guard, a Heal. The board has one foe Guard; your Yield bar position is damaged (it has something to recover).
$mk = function (string $style, array $aip = []) {
    $s = ai_fight('medium', ['ai' => $style, 'aip' => $aip]);
    $s['fh']['now'] = 14.0; $s['fh']['max'] = 40.0; $s['bar']['now'] = 0.0; $s['round'] = 4;
    $s['foe']['hand'] = [ai_tile($s, 'f:hit', 'hurt', 5), ai_tile($s, 'f:wall', 'guard', 6), ai_tile($s, 'f:mend', 'heal', 6)];
    $s['me']['hand'] = [ai_tile($s, 'm:a', 'hurt', 3)];
    return $s;
};
$pick = function (array $s) { $m = pfb_search($s, 'foe'); return $s['foe']['hand'][$m[0]]['k']; };
$byStyle = []; foreach (array_keys(PFB_AI) as $id) $byStyle[$id] = $pick($mk($id));
chk('burst plays the Hurt; guardian the Guard; healer the Heal', $byStyle['burst'] === 'f:hit' && $byStyle['guardian'] === 'f:wall' && $byStyle['healer'] === 'f:mend', $byStyle);
chk('at least 3 different pieces are chosen over the ten styles', count(array_unique($byStyle)) >= 3, $byStyle);
chk('and the same style on the same position is the same move every time (deterministic)', $pick($mk('burst')) === $pick($mk('burst')) && pfb_search($mk('crowd'), 'foe') === pfb_search($mk('crowd'), 'foe'));
$sA = $mk('ambusher'); $m1 = pfb_search($sA, 'foe'); $sA['round'] = 1; $m2 = pfb_search($sA, 'foe');
chk('ambusher: the same Hurt scores lower on round 1 (dmg x 0.4) than on round 4 (dmg x 1.6)', $m1 !== null && $m2 !== null && $m2[3] < $m1[3] - 1.0, [$m1, $m2]);
// deny: a blocker with only the deny weight takes the cell that cuts your reach most
$s7 = ai_fight('medium', ['ai' => 'blocker']); $s7['foe']['ai'] = pfb_ai_make('balanced', ['deny' => 2.5]); foreach (PFB_AI_KEYS as $k) if (!in_array($k, ['deny', 'early', 'late'], true)) $s7['foe']['ai'][$k] = 0.0;
$s7['me']['hand'] = [ai_tile($s7, 'm:a', 'hurt', 3)]; $s7['foe']['hand'] = [ai_tile($s7, 'f:blk', 'guard', 2)];
$m = pfb_search($s7, 'foe'); $best = null; $bestR = 99;
foreach (pfb_cells($s7, $s7['foe']['hand'][0], 'foe') as [$x, $y]) { $w2 = $s7; pfb_place($w2, 'foe', 0, $x, $y); $r = count(array_unique(array_map(fn($q) => $q[1] . ',' . $q[2], pfb_my_moves($w2)))); if ($r < $bestR) { $bestR = $r; $best = [$x, $y]; } }
$w2 = $s7; pfb_place($w2, 'foe', 0, $m[1], $m[2]); $rm = count(array_unique(array_map(fn($q) => $q[1] . ',' . $q[2], pfb_my_moves($w2))));
chk('deny only: the cell it picks leaves you the fewest cells (the minimum over all its cells)', $rm === $bestR, [$rm, $bestR, [$m[1], $m[2]], $best]);

echo "== 6. the search plays the turn it will really play\n";
// Ram: its guard becomes damage. A stale guard from last turn must not count (the turn starts with pfb_begin: guard = keep = 0).
$s = ai_fight('medium', ['ai' => 'burst']); $s['foe']['block'] = 9; $s['foe']['hand'] = [ai_tile($s, 'f:ram', 'hurt', 3, 'bash'), ai_tile($s, 'f:hit', 'hurt', 4)];
$m = pfb_search($s, 'foe'); $s['round'] = 4;
chk('a stale guard of 9 does not make the Bash piece look like a 12-point hit: the plain 4 wins', $s['foe']['hand'][$m[0]]['k'] === 'f:hit', $s['foe']['hand'][$m[0]]['k']);
$s0 = $s; unset($s0['foe']['ai']); $s0['v1']['style'] = 0; $m0 = pfb_search($s0, 'foe');
chk('(2.7.00 engine, style off: the old search is unchanged and still sees the stale guard)', $s0['foe']['hand'][$m0[0]]['k'] === 'f:ram', $s0['foe']['hand'][$m0[0]]['k']);
// Ambush: the first turn's boosted hit is in the search when the creature has it (balanced style, no weights)
$mkA = function (array $ab) { $s = ai_fight('medium', ['ab' => $ab]); $s['foe']['hand'] = [ai_tile($s, 'f:hit', 'hurt', 4), ai_tile($s, 'f:wall', 'guard', 5)]; return $s; };
$sa = $mkA(['ambush1']); $sb = $mkA([]);
$ma = pfb_search($sa, 'foe'); $mb = pfb_search($sb, 'foe');
chk('Ambush is valued in the search of its first turn (the best score is higher than without the ability)', $ma !== null && $mb !== null && $ma[3] > $mb[3] + 0.5 && $sa['foe']['hand'][$ma[0]]['k'] === 'f:hit', [$ma, $mb]);
$sa['foe']['amb'] = 0; $ma2 = pfb_search($sa, 'foe');
chk('and not once the ambush is used up', abs($ma2[3] - $mb[3]) < 1e-9, [$ma2, $mb]);

echo "== 7. the reason line\n";
$s = ai_fight('medium', ['ai' => 'burst']); $s['round'] = 4; $s['foe']['hand'] = [ai_tile($s, 'f:hit', 'hurt', 5), ai_tile($s, 'f:wall', 'guard', 2)]; $s['me']['hand'] = [ai_tile($s, 'm:a', 'hurt', 3)];
$m = pfb_search($s, 'foe'); $why = pfb_why($s, $m);
chk('a reason is one line of at most 90 characters and starts with the style name', is_string($why) && !str_contains($why, "\n") && strlen($why) <= 90 && str_starts_with($why, 'Burst: '), $why);
$w2 = $s; $hp0 = $w2['me']['hp']; pfb_place($w2, 'foe', $m[0], $m[1], $m[2]); $lost = $hp0 - $w2['me']['hp'];
chk('it names the damage, and the number is the health you really lose', $lost > 0 && str_contains($why, 'hits you for ' . $lost), [$why, $lost]);
$sg = ai_fight('medium', ['ai' => 'guardian']); $sg['round'] = 4; $sg['foe']['hand'] = [ai_tile($sg, 'f:wall', 'guard', 6)]; $sg['me']['hand'] = [ai_tile($sg, 'm:a', 'hurt', 3)];
$mg = pfb_search($sg, 'foe'); $wg = pfb_why($sg, $mg);
chk('a Guard play says it builds guard (the number is the guard it gains)', str_starts_with($wg, 'Guardian: ') && preg_match('/builds (\d+) guard/', $wg, $mm) && (int)$mm[1] > 0, $wg);
$sh = ai_fight('medium', ['ai' => 'healer']); $sh['fh']['now'] = 20.0; $sh['fh']['max'] = 40.0; $sh['round'] = 4; $sh['foe']['hand'] = [ai_tile($sh, 'f:mend', 'heal', 6)]; $sh['me']['hand'] = [ai_tile($sh, 'm:a', 'hurt', 3)];
$mh = pfb_search($sh, 'foe'); $wh = pfb_why($sh, $mh);
chk('a Heal play says it recovers', str_contains($wh, 'recovers '), $wh);
$sd = ai_fight('medium', []); $sd['foe']['hand'] = [ai_tile($sd, 'f:hit', 'hurt', 5)]; $sd['me']['hand'] = [ai_tile($sd, 'm:a', 'hurt', 3)];
chk('a creature with no style is Balanced: it still has a reason', str_starts_with(pfb_why($sd, pfb_search($sd, 'foe')), 'Balanced: '), pfb_why($sd, pfb_search($sd, 'foe')));
$sd['me']['hp'] = 1; $md = pfb_search($sd, 'foe');
chk('a move that ends the fight says so', str_contains(pfb_why($sd, $md), 'finishes you'), pfb_why($sd, $md));
// in a fight: the aim carries the reason, the events carry it for a re-aim
$s = pfb_new(ai_me(12), ai_foe('medium', ['class' => 'Beast', 'level' => 12, 'ai' => 'burst']), 21, ['v1' => true]);
chk('the aim in the state and the view carries `why`; the view names the style', !empty($s['foe']['plan']['why']) && pfb_view($s)['aim']['why'] === $s['foe']['plan']['why'] && pfb_view($s)['ai']['id'] === 'burst' && pfb_view($s)['ai']['n'] === 'Burst' && strlen(pfb_view($s)['ai']['t']) > 10, pfb_view($s)['ai'] ?? null);
$s = pfb_new(ai_me(12), ai_foe('medium', ['class' => 'Beast', 'level' => 12]), 21, ['v1' => true], );
chk('even without a style the aim carries a (Balanced) reason', str_starts_with($s['foe']['plan']['why'] ?? '', 'Balanced: ') && !isset(pfb_view($s)['ai']), $s['foe']['plan']['why'] ?? null);
$s = pfb_new(ai_me(12), ai_foe('medium', ['class' => 'Beast', 'level' => 12, 'ai' => 'burst']), 21, ['v1' => ['style' => 0]]);
chk('style 0: no reason anywhere (a 2.7.00 fight is unchanged)', !isset($s['foe']['plan']['why']) && !isset(pfb_view($s)['ai']));
// every foe turn of a whole fight: the root event has `why`; a re-aim says so, and its damage number matches
$replans = 0; $match = 0; $played = 0;
foreach (['burst', 'crowd', 'blocker', 'stall', 'healer', 'trickster', 'poisoner', 'guardian', 'ambusher'] as $i => $style) {
    mt_srand(300 + $i);
    $s = pfb_new(ai_me(14), ai_foe('large', ['class' => ['Critter', 'Bird', 'Beast', 'Water', 'Plant / Fungus', 'Reptile / Amphibian'][$i % 6], 'level' => 14, 'ai' => $style]), 31 + $i, ['v1' => true, 'blank' => true]);
    pfb_start($s, 0, 'L'); $t = 0;
    while (!$s['over'] && $t++ < 30) {
        $m = pfb_search($s, 'me'); $r = $m ? pfb_play($s, [[$m[0], $m[1], $m[2]]], $s['turn']) : pfb_pass($s, $s['turn']);
        foreach ($r['ev'] ?? [] as $e) if (($e['ta'] ?? '') === 'foe' && !empty($e['cs'])) {
            $played++;
            if (!isset($e['why']) || !is_string($e['why']) || str_contains($e['why'], "\n")) { chk("$style: a foe chain event has a one-line why", false, $e); continue; }
            if (str_contains($e['why'], ': re-aim, ')) $replans++;
        }
    }
}
chk("every placement of the creature in $played chains carried a reason", $played > 20);
chk('a re-aim (its aim could not play) says so in its reason', $replans > 0, $replans);

echo "== 8. aim total and play agree (unbroken aims, whole fights, every style)\n";
$gaps = 0; $nn = 0; $tot = 0.0;
foreach (['burst', 'crowd', 'blocker', 'stall', 'healer', 'trickster', 'poisoner', 'guardian', 'ambusher', 'balanced'] as $i => $style) {
    mt_srand(500 + $i);
    $s = pfb_new(ai_me(12), ai_foe($i % 2 ? 'large' : 'medium', ['class' => ['Beast', 'Critter', 'Reptile / Amphibian', 'Plant / Fungus'][$i % 4], 'level' => 12, 'ai' => $style, 'ab' => $i % 3 === 0 ? ['ambush2'] : ($i % 3 === 1 ? ['plated1'] : [])]), 50 + $i, ['v1' => true, 'blank' => true]);
    pfb_start($s, 0, 'R'); $t = 0;
    while (!$s['over'] && $t++ < 30) {
        $m = pfb_search($s, 'me'); if (!$m) break; $mv = [[$m[0], $m[1], $m[2]]];
        $dr = pfb_play($s, $mv, $s['turn'], null, true, true); if ($dr['err']) break;
        $shown = $dr['aim'] ?? null; $hpMid = (int)$dr['hp'];
        $r = pfb_play($s, $mv, $s['turn']); if ($r['err']) break;
        if (!$shown || !isset($shown['hp']) || !empty($s['reaim']) || !empty($shown['broken'])) continue;
        $act = null; $last = null;
        foreach ($r['ev'] as $e) { if (($e['ta'] ?? '') !== 'foe') continue; if (!empty($e['root']) && ($e['by'] ?? '') === 'foe') { if ($act !== null) break; $act = 1; } if ($act !== null) { if (!isset($e['id'])) break; $last = $e; } }
        if ($last === null || !isset($last['hpnow'])) continue;
        $nn++; $g = abs($shown['hp'] - ($hpMid - $last['hpnow'])); $tot += $g; if ($g > 0) $gaps++;
    }
}
chk("the shown total equals the health its first piece then takes ($nn unbroken aims; $gaps differ)", $nn > 15 && $gaps === 0, [$nn, $gaps, $tot]);

echo "== 9. whole fights, every style: they end, nothing warns, the same seed is the same fight\n";
$ended = 0; $fights = 0; $ok = true;
foreach (array_keys(PFB_AI) as $si => $style) foreach ([['small', 'Critter', 3], ['medium', 'Bird', 9], ['large', 'Reptile / Amphibian', 16], ['boss', 'Beast', 30]] as $zi => [$size, $cls, $lv]) {
    $run = function () use ($style, $size, $cls, $lv, $si, $zi) {
        mt_srand(700 + 10 * $si + $zi);
        $s = pfb_new(ai_me($lv), ai_foe($size, ['class' => $cls, 'level' => $lv, 'ai' => $style, 'aip' => $si % 3 === 1 ? ['control' => 0.9, 'force' => 0.4] : []]), 70 + $si + $zi, ['v1' => true, 'blank' => true]);
        pfb_start($s, 0, ['L', 'R', 'T', 'B'][($si + $zi) % 4]); $t = 0; $ok = true;
        while (!$s['over'] && $t++ < 45) {
            $m = pfb_search($s, 'me'); $r = $m ? pfb_play($s, [[$m[0], $m[1], $m[2]]], $s['turn']) : pfb_pass($s, $s['turn']);
            if ($r['err']) $r = pfb_pass($s, $s['turn']);
            foreach ($r['ev'] ?? [] as $e) { pfight_line($e, 'Thing'); pfight_chip_event($e, 0); if (isset($e['barnow']) && $e['barnow'] < -0.001) $ok = false; }
            if ($s['fh']['now'] < -0.001) $ok = false;
        }
        unset($s['nonce']);
        return [$s, $ok];
    };
    [$s1, $o1] = $run(); [$s2] = $run(); $fights++;
    if ($s1['over']) $ended++;
    if (!$o1 || json_encode($s1) !== json_encode($s2)) { $ok = false; chk("$style on a $size: bars sane and the fight repeats", false, [$o1, $s1['turn']]); }
}
chk("all $fights fights (10 styles x 4 sizes) are deterministic with sane bars", $ok);
chk('and nearly all of them reach an end inside the turn cap', $ended >= $fights - 4, [$ended, $fights]);

echo "== 10. every creature row x every style plays a legal fight (the 88 real creatures)\n";
$die = ['small' => 4, 'medium' => 6, 'large' => 8, 'boss' => 10]; $rows = [];
foreach (file(__DIR__ . '/../game/includes/data/creatures.txt', FILE_IGNORE_NEW_LINES) as $l) {
    if ($l === '' || $l[0] === '#') continue; $c = explode('|', $l); if (count($c) < 7) continue;
    $lv = max(1, (int)$c[4]); $rows[] = ['slug' => $c[0], 'name' => $c[1], 'size' => $c[2], 'level' => $lv, 'dmg_die' => $die[$c[2]] ?? 6, 'dmg_bonus' => intdiv($lv, 4)];
}
$styles = array_keys(PFB_AI); $n = 0; $bad2 = [];
$full = (bool)getenv('AI_FULL');   // AI_FULL=1: every style on every creature (880 fights, about a minute); else one style each, rotating
$jobs = []; foreach ($rows as $ri => $c) { if ($full) foreach ($styles as $sty) $jobs[] = [$ri, $c, $sty]; else $jobs[] = [$ri, $c, $styles[$ri % count($styles)]]; }
foreach ($jobs as [$ri, $c, $style]) {
    mt_srand(900 + $ri);
    $row = pfd_foe_row($c, array_keys(pfd_region_pieces())[$ri % 14]) + ['ai' => $style];
    $s = pfb_new(ai_me(max(1, $c['level'])), $row, 90 + $ri, ['v1' => true, 'blank' => true]);
    pfb_start($s, 0, ['L', 'R', 'T', 'B'][$ri % 4]); $t = 0;
    while (!$s['over'] && $t++ < 12) {
        $m = pfb_search($s, 'me'); $r = $m ? pfb_play($s, [[$m[0], $m[1], $m[2]]], $s['turn']) : pfb_pass($s, $s['turn']);
        if ($r['err']) { $r = pfb_pass($s, $s['turn']); if ($r['err']) { $bad2[] = $c['slug'] . ': ' . $r['err']; break; } }
        if (!empty($s['foe']['plan']) && !str_contains((string)($s['foe']['plan']['why'] ?? ''), ': ')) $bad2[] = $c['slug'] . ' no why';
    }
    $n++;
}
chk("$n fights over " . count($rows) . " creatures" . ($full ? ' x 10 styles' : '') . ", 12 turns each: no engine error, every aim explained", $n === count($jobs) && !$bad2, array_slice($bad2, 0, 3));

echo "== 11. balanced (or no style) plays the 2.7.00 fight exactly: the same events, bars and end as style 0\n";
$strip = function ($x) use (&$strip) { if (!is_array($x)) return $x; unset($x['why'], $x['aid'], $x['nonce']); return array_map($strip, $x); };
$same = 0; $total = 0;
foreach ([['small', 'Critter', 4], ['medium', 'Beast', 10], ['large', 'Water', 17], ['boss', 'Plant / Fungus', 30], ['medium', 'Bird', 12], ['large', 'Reptile / Amphibian', 20]] as $zi => [$size, $cls, $lv]) foreach ([null, 'balanced'] as $style) {
    $run = function ($over) use ($size, $cls, $lv, $zi, $style) {
        mt_srand(1100 + $zi);
        $row = ai_foe($size, ['class' => $cls, 'level' => $lv] + ($style ? ['ai' => $style] : []));
        $s = pfb_new(ai_me($lv), $row, 110 + $zi, ['v1' => $over, 'blank' => true]); pfb_start($s, 0, 'L'); $log = []; $t = 0;
        while (!$s['over'] && $t++ < 40) { $m = pfb_search($s, 'me'); $r = $m ? pfb_play($s, [[$m[0], $m[1], $m[2]]], $s['turn']) : pfb_pass($s, $s['turn']); $log[] = $r['ev'] ?? []; }
        return [$s, $log];
    };
    [$sa, $la] = $run(true); [$sb, $lb] = $run(['style' => 0]); $total++;
    $A = json_encode($strip($la)) === json_encode($strip($lb)) && $sa['over'] === $sb['over'] && $sa['turn'] === $sb['turn'] && $sa['me']['hp'] === $sb['me']['hp'];
    if ($A) $same++; else echo "   differs: $size $cls " . ($style ?? 'none') . "\n";
}
chk("$total fights (6 creatures x no style / balanced): the events (reasons aside), hp, end and turn are those of style 0", $same === $total, [$same, $total]);

chk('no PHP warning or notice anywhere in this run', !$warn, array_slice($warn, 0, 3));
echo $bad ? "$bad FAILED\n" : "all ok\n";
exit($bad ? 1 : 0);
