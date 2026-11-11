<?php
// Board mode sim (no DB): php tests/pfboard_sim.php [--quiet]. Every creature x bots; invariants, then pace tables.
require __DIR__ . '/../game/includes/pfboard.php';
$quiet = in_array('--quiet', $argv, true);
$rows = [];
$die = ['small' => 4, 'medium' => 6, 'large' => 8, 'boss' => 10];
foreach (file(__DIR__ . '/../game/includes/data/creatures.txt', FILE_IGNORE_NEW_LINES) as $l) {
    if ($l === '' || $l[0] === '#') continue; $c = explode('|', $l); if (count($c) < 7) continue;
    $lv = max(1, (int)$c[4]); $rows[] = ['slug' => $c[0], 'name' => $c[1], 'size' => $c[2], 'level' => $lv, 'dmg_die' => $die[$c[2]] ?? 6, 'dmg_bonus' => intdiv($lv, 4)];
}
function bsim_player(int $lv): array
{
    $m = max(0, intdiv($lv + 3, 14)); $st = ['grit' => $m, 'nimble' => $m, 'hardiness' => $m, 'charm' => $m, 'lore' => $m, 'luck' => $m, 'level' => $lv];
    $cals = array_keys(PF_CALLING_TILE); $cal = $cals[$lv % 6]; $own = pf_collection($lv, $cal); $cap = pf_box_capacity($lv);
    $want = ['hurt' => 5, 'charm' => 3, 'guard' => 3, 'heal' => 1, 'trick' => 1, 'item' => 1, 'soothe' => 0]; $box = []; $n = [];
    foreach ($own as $k) { $t = pf_tiles()[$k]['t']; if (($n[$t] ?? 0) < ($want[$t] ?? 0) && count($box) < $cap) { $box[] = $k; $n[$t] = ($n[$t] ?? 0) + 1; } }
    foreach ($own as $k) if (!in_array($k, $box, true) && count($box) < $cap) $box[] = $k;
    $max = 20 + 3 * $lv + 5 * $m;
    return ['hp' => $max, 'max_hp' => $max, 'stats' => $st, 'deck' => pf_player_deck($st, $cal, 1 + intdiv($lv, 12), [], [], [], true, $box), 'luck' => $m];
}
/** One turn for the greedy bot: place up to $n pieces by pfb_search on a scratch copy; heavy last. Returns moves in hand-index terms of the START hand. */
function bsim_moves(array $s, int $n): array
{
    $moves = []; $w = $s; $orig = $s['me']['hand']; $taken = [];
    for ($k = 0; $k < $n; $k++) {
        $m = pfb_search($w, 'me', $k < $n - 1 || true);
        if ($m === null || ($m[3] <= 0.0001 && $k > 0)) break;   // always place at least one piece (a turn with nothing placed is only for a hand that fits nowhere)
        $tile = $w['me']['hand'][$m[0]];
        $oi = null; foreach ($orig as $i => $t) if (!isset($taken[$i]) && $t === $tile) { $oi = $i; break; }
        if ($oi === null) break;
        $moves[] = [$oi, $m[1], $m[2]]; $taken[$oi] = true;
        pfb_place($w, 'me', $m[0], $m[1], $m[2]);
        if ($tile['tag'] === 'heavy' && ($tile['m'] ?? '') !== 'steady') break;   // a heavy piece ends the turn
        if ($w['over']) break;
    }
    return $moves;
}
$bad = 0; $tbl = [];
foreach ($rows as $c) foreach ([11, 22] as $seed) {
    $me = bsim_player($c['level']); $s = pfb_new($me, $c, $seed + $c['level']); $total = count($me['deck']); $t = 0;
    while (!$s['over'] && $t++ < 40) {
        $mv = bsim_moves($s, [2, 3, 4][$seed % 3]);
        if ($mv) $r = pfb_play($s, $mv, $s['turn']); else $r = pfb_pass($s, $s['turn']);
        if ($r['err']) { echo "FAIL illegal move {$c['slug']}: {$r['err']}\n"; $bad++; break; }
        $cnt = count($s['me']['hand']) + count($s['me']['draw']) + count($s['me']['discard']) + count(array_filter($s['pcs'], fn($p) => $p['by'] === 'me'));
        if ($cnt !== $total) { echo "FAIL tile conservation {$c['slug']}: $cnt vs $total\n"; $bad++; break; }
        if (count($s['pcs']) > PFB_W * PFB_H) { echo "FAIL board overflow\n"; $bad++; break; }
    }
    if (!$s['over']) { echo "FAIL fight did not end: {$c['slug']}\n"; $bad++; }
    $tbl[$c['size']][] = [(string)$s['over'], $s['turn']];
}
if (!$quiet) foreach ($tbl as $size => $res) { $cnt = array_count_values(array_column($res, 0)); ksort($cnt); printf("%-7s n=%-3d avg turns %.1f  %s\n", $size, count($res), array_sum(array_column($res, 1)) / count($res), json_encode($cnt)); }
// ---- rules, one by one
$T = fn(string $k, string $t, int $v, ?string $r, string $tag = '', string $m = '') => ['k' => $k, 'n' => $k, 't' => $t, 'v' => $v, 'r' => $r, 'tag' => $tag, 'm' => $m];
$mkc = ['slug' => 'x', 'size' => 'medium', 'level' => 5, 'dmg_die' => 6, 'dmg_bonus' => 0, 'temper' => 'hostile'];
$stx = ['level' => 1];
$fresh = function () use ($mkc, $stx) { $s = pfb_new(['hp' => 99, 'max_hp' => 99, 'stats' => $stx, 'deck' => pf_player_deck($stx), 'luck' => 0], $mkc, 3); $s['pcs'] = []; $s['cell'] = []; $s['pid'] = 0; $s['seq'] = 0; $s['bar']['max'] = 999.0; return $s; };
$put = function (array &$s, string $by, array $tile, int $x, int $y) { $id = ++$s['pid']; $s['seq']++; $s['pcs'][$id] = ['id' => $id, 'by' => $by, 'tile' => $tile, 'x' => $x, 'y' => $y, 'born' => $s['round'], 'seq' => $s['seq']]; $s['cell']["$x,$y"] = $id; return $id; };
// edges: L is the type's hole, R the knob; a flat edge is wild but not linked
$e = pfb_edges($T('swing', 'hurt', 4, 'mind')); if ($e['L'] !== ['hole', 'body'] || $e['R'] !== ['knob', 'mind']) { echo "FAIL edges\n"; $bad++; }
if (pfb_joint(['knob', 'mind'], ['hole', 'mind']) !== [true, true] || pfb_joint(['knob', 'mind'], ['hole', 'body']) !== [false, false] || pfb_joint(['flat', null], ['hole', 'body']) !== [true, false] || pfb_joint(['knob', 'mind'], ['knob', 'mind'])[0]) { echo "FAIL joints\n"; $bad++; }
// an empty board accepts only the centre; later pieces must touch and fit
$s = $fresh(); $a = $T('a', 'hurt', 4, 'mind');
if (pfb_check($s, $a, 0, 0) !== null || pfb_check($s, $a, intdiv(PFB_W, 2), intdiv(PFB_H, 2)) === null) { echo "FAIL empty board centre rule\n"; $bad++; }
$put($s, 'foe', $T('anchor', 'guard', 3, 'body'), 2, 2);
if (pfb_check($s, $a, 4, 4) !== null) { echo "FAIL a piece must touch the board\n"; $bad++; }
if (pfb_check($s, $a, 2, 2) !== null) { echo "FAIL a piece went on an occupied cell\n"; $bad++; }
// legal cells are exactly those where every touching edge fits
foreach (pfb_cells($s, $a) as [$x, $y]) if (pfb_check($s, $a, $x, $y) === null) { echo "FAIL pfb_cells disagrees with pfb_check\n"; $bad++; }
// newest first, through linked joints only. Three pieces in a row: each R knob meets the next L hole when the types line up.
$s = $fresh();
$p1 = $T('p1', 'trick', 2, 'body'); $p2 = $T('p2', 'hurt', 5, 'mind'); $p3 = $T('p3', 'heal', 2, null);   // trick R body -> hurt L body ok; hurt R mind -> heal L mind ok
$i1 = $put($s, 'me', $p1, 1, 2); $i2 = $put($s, 'me', $p2, 2, 2); $i3 = $put($s, 'me', $p3, 3, 2);
$ch = array_map(fn($x) => $x[0], pfb_chain($s, $i3));
if ($ch !== [$i3, $i2, $i1]) { echo "FAIL chain order from the newest piece: " . json_encode($ch) . "\n"; $bad++; }
// a flat side breaks the chain: make the middle piece's R flat
$s = $fresh(); $q2 = $T('q2', 'hurt', 5, null);
$j1 = $put($s, 'me', $p1, 1, 2); $j2 = $put($s, 'me', $q2, 2, 2); $j3 = $put($s, 'me', $p3, 3, 2);
if (count(pfb_chain($s, $j3)) !== 1) { echo "FAIL a flat side did not break the chain\n"; $bad++; }
// combos: Trick placed on a Hurt (same owner) gives Ambush; across owners it does not
$s = $fresh(); $h = $T('h', 'hurt', 4, 'mind'); $tr = $T('t', 'trick', 2, 'body');
$hid = $put($s, 'me', $h, 2, 2); $s['me']['hand'] = [$tr]; $s['foe']['hand'] = [];
$cells = pfb_cells($s, $tr);
$found = null; foreach ($cells as [$x, $y]) { $j = pfb_check($s, $tr, $x, $y); foreach ($j as $jj) if ($jj[2]) $found = [$x, $y]; }
if ($found) { $b0 = $s['bar']['now']; $ev = pfb_place($s, 'me', 0, $found[0], $found[1]); $names = array_column($ev, 'combo'); if (!in_array('Ambush', $names, true)) { echo "FAIL Trick onto own Hurt gave no Ambush: " . json_encode($names) . "\n"; $bad++; } }
else echo "note: no linked cell for the Ambush test\n";
$s = $fresh(); $hid = $put($s, 'foe', $h, 2, 2); $s['me']['hand'] = [$tr]; $found = null;
foreach (pfb_cells($s, $tr) as [$x, $y]) foreach (pfb_check($s, $tr, $x, $y) as $jj) if ($jj[2]) $found = [$x, $y];
if ($found) { $ev = pfb_place($s, 'me', 0, $found[0], $found[1]); if (in_array('Ambush', array_column($ev, 'combo'), true)) { echo "FAIL a combo crossed owners\n"; $bad++; } if (!in_array('foe', array_column($ev, 'by'), true)) { echo "FAIL the foe piece did not fire when linked to\n"; $bad++; } }
// pieces expire
$s = $fresh(); $id = $put($s, 'me', $h, 2, 2); $s['round'] = 3; pfb_expire($s);
if ($s['pcs'] || count($s['me']['discard']) !== 1) { echo "FAIL expiry\n"; $bad++; }
// stale turn, bad moves, determinism, no leaks
$st = ['level' => 3, 'grit' => 1, 'nimble' => 1, 'hardiness' => 1, 'charm' => 1, 'lore' => 1, 'luck' => 0];
$mk = fn() => pfb_new(['hp' => 40, 'max_hp' => 40, 'stats' => $st, 'deck' => pf_player_deck($st), 'luck' => 0], $mkc, 77);
$a = $mk(); $b = $mk(); unset($a['nonce'], $b['nonce']);
$mv = bsim_moves($mk(), 2); $x1 = $mk(); $x2 = $mk(); pfb_play($x1, $mv, 1); pfb_play($x2, $mv, 1); unset($x1['nonce'], $x2['nonce']);
if (json_encode($a) !== json_encode($b) || json_encode($x1) !== json_encode($x2)) { echo "FAIL board fight not deterministic\n"; $bad++; }
$x = $mk(); if (pfb_play($x, $mv, 9)['err'] !== 'stale') { echo "FAIL stale turn accepted\n"; $bad++; }
$x = $mk(); $before = json_encode($x); foreach ([[[0, 0, 0]], [[0, 2, 2], [0, 2, 2]], [[99, 1, 1]], [['a', 1, 1]], []] as $bm) { $r = pfb_play($x, $bm, 1); if ($r['err'] === null || json_encode($x) !== $before) { echo "FAIL bad move accepted or state changed: " . json_encode($bm) . "\n"; $bad++; } }
$v = pfb_view($mk()); $vj = json_encode($v);
if (str_contains($vj, '"rng"') || str_contains($vj, '"nonce"') || isset($v['draw']) || !is_int($v['foe']['hand'])) { echo "FAIL board view leaks\n"; $bad++; }
echo $bad ? "$bad FAILED\n" : "ok: " . count($rows) . " creatures\n";
exit($bad ? 1 : 0);
