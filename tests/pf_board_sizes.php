<?php
// 2.7.55 board sizes by creature size (claude/proposal-board-sizes-2.7.55.md): board dims per size, the environment's field caps (small one at a time and it comes back,
// medium at most 3), Tremor and Spring only in large / boss decks and what they do, every boss's AOE (telegraphed, then it lands), 3x3 env placement fallback, old-state compat.
// php tests/pf_board_sizes.php   (no DB, no server). The JS twin of all of this is checked by tests/pfengine_js.sh (1188 fights).
require_once __DIR__ . '/pfboard_tune_v1.php';   // tv_player, tv_places, tv_choose, pt_load_creatures
$fails = 0;
function ck(string $what, bool $ok, $got = null): void { global $fails; if ($ok) echo "ok   $what\n"; else { $fails++; echo "FAIL $what" . ($got !== null ? ' (got ' . substr(json_encode($got), 0, 300) . ')' : '') . "\n"; } }
$ALL = pt_load_creatures();
function bs_fight(string $slug, int $seed, array $v1 = [], string $region = 'OC'): array
{
    global $ALL; $c = $ALL[$slug]; $cr = pfd_foe_row($c, $region);
    $s = pfb_new(tv_player($c['level']), $cr, $seed, ['blank' => true, 'v1' => $v1 ?: true]); pfb_start($s, 0, 'L');
    return $s;
}
function bs_env_n(array $s): int { return count(array_filter($s['pcs'], fn($p) => $p['by'] === 'env' && empty($p['tile']['own']))); }
$bySize = []; foreach ($ALL as $slug => $c) $bySize[$c['size']][] = $slug;

echo "== 1. board dims by size\n";
foreach (['small' => [3, 3], 'medium' => [4, 4], 'large' => [5, 5], 'boss' => [5, 5]] as $sz => $wh) {
    $cfg = pfb_v1_cfg($sz); ck("cfg $sz is {$wh[0]}x{$wh[1]}", [$cfg['w'], $cfg['h']] === $wh, [$cfg['w'], $cfg['h']]);
    $s = bs_fight($bySize[$sz][0], 11); ck("a new $sz fight ({$bySize[$sz][0]}) plays on {$wh[0]}x{$wh[1]}", [$s['w'], $s['h']] === $wh, [$s['w'], $s['h']]);
    ck("$sz: field cap " . PFB_ENV_MAX[$sz] . ', ' . PFB_ENV_N[$sz] . ' placed a round', (int)$s['v1']['envmax'] === PFB_ENV_MAX[$sz] && (int)$s['v1']['envn'] === PFB_ENV_N[$sz], [$s['v1']['envmax'], $s['v1']['envn']]);
}

echo "== 2. small: one environment piece at a time, and a new one comes in after it goes\n";
$max = 0; $places = 0; $gone = 0; $caps = 0; $fights = 0;
foreach (array_slice($bySize['small'], 0, 12) as $i => $slug) for ($sd = 1; $sd <= 3; $sd++) {
    $s = bs_fight($slug, 100 * $i + $sd); $fights++;
    for ($t = 0; $t < 30 && !$s['over']; $t++) {
        $r = pfb_pass($s, $s['turn']);   // passing keeps the board quiet, so the environment's own life cycle shows
        foreach ($r['ev'] as $e) { if (($e['env'] ?? '') === 'place') $places++; if (($e['env'] ?? '') === 'expire') $gone++; if (($e['env'] ?? '') === 'pass' && !empty($e['cap'])) $caps++; }
        $max = max($max, bs_env_n($s));
    }
}
ck("small: never more than 1 environment piece on the board ($fights fights)", $max === 1, $max);
ck("small: the field cap kept a piece waiting ($caps times)", $caps > 0, $caps);
ck("small: pieces left ($gone) and new ones came in ($places placed)", $gone > 0 && $places > $fights, [$gone, $places]);
$s = bs_fight($bySize['small'][0], 5); $p = ['by' => 'env', 'tile' => ['t' => 'env', 'env' => 'sun']];
ck('small: an environment piece fires once (fire limit 1)', pfb_fire_lim($s, $p) === 1);
$s = bs_fight($bySize['medium'][0], 5); ck('medium: environment pieces have no fire limit', pfb_fire_lim($s, $p) === 0);

echo "== 3. medium: at most 3 environment pieces at once\n";
$max = 0; $caps = 0;
foreach (array_slice($bySize['medium'], 0, 10) as $i => $slug) for ($sd = 1; $sd <= 3; $sd++) {
    $s = bs_fight($slug, 300 + 10 * $i + $sd);
    for ($t = 0; $t < 24 && !$s['over']; $t++) { $r = pfb_pass($s, $s['turn']); foreach ($r['ev'] as $e) if (($e['env'] ?? '') === 'pass' && !empty($e['cap'])) $caps++; $max = max($max, bs_env_n($s)); }
}
ck('medium: never more than 3 environment pieces', $max <= 3, $max);
ck("medium: the cap was reached ($caps waits)", $caps > 0 && $max === 3, [$caps, $max]);
foreach (['large', 'boss'] as $sz) {
    $max = 0; foreach (array_slice($bySize[$sz], 0, 6) as $i => $slug) { $s = bs_fight($slug, 500 + $i); for ($t = 0; $t < 20 && !$s['over']; $t++) { pfb_pass($s, $s['turn']); $max = max($max, bs_env_n($s)); } }
    ck("$sz: never more than " . PFB_ENV_MAX[$sz] . " environment pieces (most seen $max)", $max <= PFB_ENV_MAX[$sz] && $max > 3, $max);
}

echo "== 4. Tremor and Spring: large and boss decks only\n";
$regions = array_keys(pfb_env_table()['regions']);
foreach (['small', 'medium', 'large', 'boss'] as $sz) {
    $kinds = []; foreach (array_merge([''], $regions) as $rg) foreach (pfb_env_deck($sz, $rg) as $t) $kinds[$t['env']] = 1;
    $big = isset($kinds['quake']) || isset($kinds['spring']);
    ck("$sz decks " . (in_array($sz, PFB_ENV_BIG_SIZES, true) ? 'hold' : 'never hold') . ' Tremor / Spring (every region)', in_array($sz, PFB_ENV_BIG_SIZES, true) ? (isset($kinds['quake']) && isset($kinds['spring'])) : !$big, array_keys($kinds));
}
$cnt = fn(array $d, string $k) => count(array_filter($d, fn($t) => $t['env'] === $k));
ck('region flavour: OC leans Tremor (2 Tremor, 1 Spring in a large deck)', $cnt(pfb_env_deck('large', 'OC'), 'quake') === 2 && $cnt(pfb_env_deck('large', 'OC'), 'spring') === 1);
ck('region flavour: SE leans Spring (1 Tremor, 2 Spring in a boss deck)', $cnt(pfb_env_deck('boss', 'SE'), 'quake') === 1 && $cnt(pfb_env_deck('boss', 'SE'), 'spring') === 2);
$tile = null; foreach (pfb_env_deck('large') as $t) if ($t['env'] === 'quake') $tile = $t;
$s = bs_fight($bySize['large'][0], 21); $s['pcs'] = []; $s['cell'] = [];
$put = function (array &$s, string $by, array $t, int $x, int $y): int { $id = ++$s['pid']; $s['seq']++; $s['pcs'][$id] = ['id' => $id, 'by' => $by, 'tile' => $t, 'x' => $x, 'y' => $y, 'born' => $s['round'], 'seq' => $s['seq']]; $s['cell']["$x,$y"] = $id; return $id; };
$qid = $put($s, 'env', $tile, 2, 2); $f1 = $put($s, 'foe', $s['foe']['hand'][0], 1, 2); $f2 = $put($s, 'foe', $s['foe']['hand'][1], 3, 2); $f3 = $put($s, 'foe', $s['foe']['hand'][2], 2, 1); $m1 = $put($s, 'me', $s['me']['hand'][0], 2, 3);
$e = pfb_env_fire($s, $s['pcs'][$qid], 'me'); pfb_spend($s);
ck('Tremor fired by you: the 2 oldest creature pieces touching it fall, yours stays', !isset($s['pcs'][$f1]) && !isset($s['pcs'][$f2]) && isset($s['pcs'][$f3]) && isset($s['pcs'][$m1]) && count($e['falls']) === 2, $e['falls'] ?? null);
ck('Tremor: the log line names them', str_contains(pfb_env_line($e, 'heron'), 'fall off the board'), pfb_env_line($e, 'heron'));
$sp = null; foreach (pfb_env_deck('large') as $t) if ($t['env'] === 'spring') $sp = $t;
$sid = $put($s, 'env', $sp, 0, 0); $s['me']['hp'] = 10; $e = pfb_env_fire($s, $s['pcs'][$sid], 'me');
ck('Spring fired by you: you recover 10% of max health', $s['me']['hp'] === 10 + (int)pf_round(0.1 * $s['me']['max']) && $e['heal'] > 0, [$s['me']['hp'], $e['heal'] ?? null]);
$s['fh']['now'] = 30.0; $e = pfb_env_fire($s, $s['pcs'][$sid], 'foe');
ck('Spring fired by the creature: its bar empties 10%', abs(30.0 - (float)$s['fh']['now'] - 0.1 * $s['fh']['max']) < 0.01, [$s['fh']['now'], $e['heal']]);

echo "== 5. every boss: its AOE is telegraphed a turn ahead, then lands\n";
$SIZE = ['sq2' => 4, 'pincer' => 4, 'diag' => 5, 'plus' => 5, 'row' => 5, 'ring' => 8, 'x' => 5, 'corners' => 4, 'diamond' => 4, 'col' => 5, 'ell' => 5];
$shapes = [];
foreach ($bySize['boss'] as $bi => $slug) {
    $def = PFB_AOE[$slug] ?? null; ck("$slug has its own AOE row", $def !== null); if (!$def) continue;
    [$shape, $fx, $pct, $name] = $def; $shapes[$shape] = ($shapes[$shape] ?? 0) + 1;
    $s = bs_fight($slug, 700 + $bi);
    ck("$slug: no AOE marked in round 1", empty($s['aoe']));
    $r = pfb_pass($s, $s['turn']);
    ck("$slug: round 2 shows $name marked ({$SIZE[$shape]} cells, $shape)", !empty($s['aoe']) && count($s['aoe']['cells']) === $SIZE[$shape] && (int)$s['round'] === 2, $s['aoe'] ?? null);
    $v = pfb_view($s); ck("$slug: the view carries the marks", ($v['aoe']['cells'] ?? null) === $s['aoe']['cells'] && $v['aoe']['in'] === 0 && $v['aoe']['n'] === $name);
    // put one of YOUR pieces (not a Guard) on a marked cell, then let the boss move: the AOE lands at the end of its turn
    $cell = null; foreach ($s['aoe']['cells'] as [$x, $y]) if (!isset($s['cell']["$x,$y"])) { $cell = [$x, $y]; break; }
    $ht = null; foreach ($s['me']['hand'] as $t) if ($t['t'] !== 'guard') { $ht = $t; break; }
    $mid = $put($s, 'me', $ht, $cell[0], $cell[1]); $hp0 = (int)$s['me']['hp']; $s['me']['block'] = 0; $s['fh']['now'] = max(30.0, (float)$s['fh']['now']); $fh0 = (float)$s['fh']['now'] + (float)$s['bar']['now'];
    $w = $s; $ev = []; pfb_aoe_land($w, $ev); $e = end($ev);
    $hitIds = array_column($e['hit'] ?? [], 'id');
    $okFx = match ($fx) { 'break' => !isset($w['pcs'][$mid]) && in_array($mid, $hitIds, true), 'hurt' => (int)$w['me']['hp'] < $hp0 && in_array($mid, $hitIds, true), default => (float)$w['fh']['now'] + (float)$w['bar']['now'] < $fh0 && in_array($mid, $hitIds, true) };
    ck("$slug: $name lands ($fx) on your piece in the marks: " . pfb_aoe_line($e, 'boss'), ($e['note'] ?? '') === 'aoe' && $okFx && empty($w['aoe']), $e);
    $r = pfb_pass($s, $s['turn']); $notes = array_values(array_filter($r['ev'], fn($e) => ($e['note'] ?? '') === 'aoe'));
    ck("$slug: in play it lands in the boss's turn of that round, once", count($notes) === 1 && ($notes[0]['ta'] ?? '') === 'foe', count($notes));
    ck("$slug: next marked in round 5 (in 2 rounds now)", pfb_aoe_in($s) === 2 && empty($s['aoe']), [pfb_aoe_in($s), $s['round']]);
}
ck('the 11 bosses use 11 different shapes', count($shapes) === 11 && count($bySize['boss']) === 11, $shapes);
$s = bs_fight('coconut-crab-titan', 9); $pass = 0;
for ($t = 0; $t < 4 && !$s['over']; $t++) { $mk = !empty($s['aoe']); $r = pfb_pass($s, $s['turn']); $n = count(array_filter($r['ev'], fn($e) => ($e['note'] ?? '') === 'aoe')); if ($n === ($mk ? 1 : 0)) $pass++; }
ck('it only lands in a round it was marked in (4 rounds)', $pass === 4, $pass);
$s = bs_fight('coconut-crab-titan', 9); pfb_pass($s, $s['turn']); [$x, $y] = $s['aoe']['cells'][0];
if (!isset($s['cell']["$x,$y"])) { $g = null; foreach (array_merge($s['me']['hand'], $s['me']['draw']) as $t) if ($t['t'] === 'guard') { $g = $t; break; }
    if ($g) { $gid = $put($s, 'me', $g, $x, $y); $ev = []; $w = $s; pfb_aoe_land($w, $ev); ck('break: a Guard piece of yours in the marks holds', isset($w['pcs'][$gid]) && in_array($gid, end($ev)['held'], true)); } }
$s = bs_fight('storm-eagle', 4); pfb_pass($s, $s['turn']); [$x, $y] = $s['aoe']['cells'][0];
if (!isset($s['cell']["$x,$y"])) { $put($s, 'me', $s['me']['hand'][0], $x, $y); $s['me']['block'] = 100; $hp0 = $s['me']['hp']; $ev = []; pfb_aoe_land($s, $ev); ck('hurt: your guard takes it first', $s['me']['hp'] === $hp0 && end($ev)['blocked'] > 0, end($ev)); }
foreach (['sq2', 'ring', 'diag', 'ell', 'plus', 'corners', 'pincer'] as $sh) {   // on a 3x3 board every shape still fits (a boss on a test board)
    $an = pfb_aoe_anchors($sh, 3, 3); $okc = $an !== [];
    foreach ($an as [$ax, $ay]) foreach (pfb_aoe_cells($sh, $ax, $ay, 3, 3) as [$x, $y]) $okc = $okc && $x >= 0 && $y >= 0 && $x < 3 && $y < 3;
    ck("shape $sh has anchors on a 3x3 board and stays on it", $okc);
}

echo "== 6. 3x3: the environment still finds a cell when no cell is isolated\n";
$s = bs_fight($bySize['small'][0], 31); $s['pcs'] = []; $s['cell'] = []; $env = $s['env']['next'][0];
foreach ([[1, 1], [1, 0], [0, 1], [2, 1], [1, 2]] as $k => [$x, $y]) $put($s, $k % 2 ? 'foe' : 'me', ($k % 2 ? $s['foe']['hand'] : $s['me']['hand'])[0], $x, $y);
$iso = []; for ($y = 0; $y < 3; $y++) for ($x = 0; $x < 3; $x++) { if (isset($s['cell']["$x,$y"])) continue; $n = 0; foreach (PFB_SIDE as [$dx, $dy]) if (pfb_at($s, $x + $dx, $y + $dy)) $n++; if (!$n) $iso[] = "$x,$y"; }
$cells = pfb_env_cells($s, $env);
ck('no isolated cell on this 3x3 board and the piece fits nowhere, yet the fallback gives the free cells with the fewest neighbours', !$iso && $cells !== [], [$iso, $cells]);
foreach ($cells as [$x, $y]) ck("fallback cell $x,$y is free and fits once its misfit sides are flat", !isset($s['cell']["$x,$y"]) && pfb_check($s, pfb_env_fit($s, $env, $x, $y), $x, $y) !== null);
$placed = 0; foreach (array_slice($bySize['small'], 0, 12) as $i => $slug) { $s = bs_fight($slug, 40 + $i); pfb_pass($s, $s['turn']); if (bs_env_n($s) === 1) $placed++; }
ck("3x3: the first environment piece is placed in round 1 ($placed of 12 fights)", $placed >= 10, $placed);

echo "== 7. a fight saved before 2.7.55 plays as before\n";
$s = bs_fight('coconut-crab-titan', 3, ['aoe' => 0]);
ck('rule aoe 0: no AOE in the state or the view', !isset($s['aoed']) && !isset(pfb_view($s)['aoe']));
ck('compat keys default off', PFB_V1_PRE['aoe'] === 0 && PFB_V1_PRE['envmax'] === 0 && PFB_V1_PRE['envonce'] === 0);
$s = bs_fight($bySize['medium'][0], 3); unset($s['v1']['envmax'], $s['v1']['envonce']); $max = 0;
for ($t = 0; $t < 20 && !$s['over']; $t++) { pfb_pass($s, $s['turn']); $max = max($max, bs_env_n($s)); }
ck("an old medium state (no envmax) has no field cap (most seen $max)", $max >= 3, $max);

echo $fails ? "$fails FAILED\n" : "all ok\n";
exit($fails ? 1 : 0);
