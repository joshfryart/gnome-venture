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
/** The type weights the bot uses to value a set-aside group (what its pieces would add to the bar or the fight). */
function bsim_val(array $s, array $t): float { $w = ['hurt' => $s['hm'], 'charm' => $s['cm'], 'guard' => 0.5, 'heal' => 0.5, 'soothe' => 0.3, 'trick' => 0.4, 'item' => 0.5]; return $t['v'] * ($w[$t['t']] ?? 0.3); }
/**
 * One action for the bot. 'single': always the best single placement. 'builder': when the best single is weak it sets pieces aside (a joined pair, then a third) and plays the group once it has three,
 * or two after waiting a turn. Returns the move for pfb_play, or null (nothing fits: pass).
 */
function bsim_act(array $s, string $mode): ?array
{
    $one = pfb_search($s, 'me');
    $held = $s['me']['held'] ?? null;
    if ($mode === 'builder') {
        if ($held) {
            $n = count($held['pcs']); $spots = pfb_group_spots($s, $held); $best = null;
            foreach ($spots as [$x, $y]) { $w = $s; if (pfb_place_group($w, 'me', $x, $y) === null) continue; $sc = pfb_score($s, $w, 'me'); if ($best === null || $sc > $best[2]) $best = [$x, $y, $sc]; }
            if ($n === 3 && $best) return ['c', $best[0], $best[1]];
            if ($n === 2) {
                $bo = null;
                foreach ($s['me']['hand'] as $bi => $t) foreach (pfb_group_options($held, $t) as [$ai, $side]) { $v = bsim_val($s, $t); if ($bo === null || $v > $bo[0]) $bo = [$v, $bi, $ai, $side]; }
                if ($bo && (!$one || $one[3] < 5.0)) return ['h', $bo[1], $bo[2], $bo[3]];
                if ($best && (!$one || $best[2] >= $one[3])) return ['c', $best[0], $best[1]];
            }
        } elseif (!$one || $one[3] < 4.0) {
            $bo = null; $hand = $s['me']['hand'];
            foreach ($hand as $ai => $ta) foreach ($hand as $bi => $tb) {
                if ($ai === $bi) continue;
                foreach (PFB_SIDE as $side => [$dx, $dy]) { $g = ['pcs' => [['tile' => $ta, 'x' => 0, 'y' => 0]]]; if (pfb_group_fit($g, $tb, $dx, $dy) !== true) continue; $v = bsim_val($s, $ta) + bsim_val($s, $tb); if ($bo === null || $v > $bo[0]) $bo = [$v, $ai, $bi, $side]; }
            }
            if ($bo) return ['j', $bo[1], $bo[2], $bo[3]];
        }
    }
    return $one ? [$one[0], $one[1], $one[2]] : null;
}
$bad = 0; $tbl = []; $kinds = []; $byMode = [];
foreach ($rows as $c) foreach ([11, 22] as $seed) {
    $me = bsim_player($c['level']); $s = pfb_new($me, $c, $seed + $c['level']); $total = count($me['deck']); $t = 0;
    while (!$s['over'] && $t++ < 40) {
        // the connect rule: when anything can connect, every offered cell links; when nothing can, the fitting cells are offered
        foreach (['me', 'foe'] as $side) {
            $must = pfb_must_link($s, $side);
            foreach ($s[$side]['hand'] as $ht) { $all = pfb_cells($s, $ht); $off = pfb_cells($s, $ht, $side);
                foreach ($off as [$cx, $cy]) if ($must && !pfb_has_link(pfb_check($s, $ht, $cx, $cy))) { echo "FAIL {$c['slug']}: a non-connecting spot was offered although something can connect\n"; $bad++; break 2; }
                if (!$must && $off !== $all) { echo "FAIL {$c['slug']}: with nothing able to connect the fitting spots were not all offered\n"; $bad++; break 2; } }
            if ($must) foreach ($s[$side]['hand'] as $hi => $ht) { $off = array_map('json_encode', pfb_cells($s, $ht, $side)); foreach (pfb_cells($s, $ht) as $cxy) if (!in_array(json_encode($cxy), $off, true)) { $w = $s; if (pfb_place($w, $side, $hi, $cxy[0], $cxy[1]) !== null) { echo "FAIL {$c['slug']}: a non-connecting placement was accepted although something can connect\n"; $bad++; } $refused = ($refused ?? 0) + 1; break 2; } }
            $rules = ($rules ?? 0) + ($must ? 1 : 0); $free = ($free ?? 0) + ($must ? 0 : 1);
        }
        $mv = bsim_act($s, $seed === 11 ? 'single' : 'builder');
        if ($mv) $r = pfb_play($s, [$mv], $s['turn']); else $r = pfb_pass($s, $s['turn']);
        // one chain per side per turn: nothing disconnected from the piece just placed may fire
        foreach (['me', 'foe'] as $side) if (count(array_filter($r['ev'], fn($e) => !empty($e['root']) && $e['by'] === $side)) > 1) { echo "FAIL {$c['slug']}: two separate chains fired for $side in one turn\n"; $bad++; }
        if (isset($mv[0]) && is_string($mv[0])) $kinds[$mv[0]] = ($kinds[$mv[0]] ?? 0) + 1;
        if ($r['err']) { echo "FAIL illegal move {$c['slug']}: {$r['err']}\n"; $bad++; break; }
        $cnt = count($s['me']['hand']) + count($s['me']['draw']) + count($s['me']['discard']) + count(array_filter($s['pcs'], fn($p) => $p['by'] === 'me')) + count($s['me']['held']['pcs'] ?? []);
        if ($cnt !== $total) { echo "FAIL tile conservation {$c['slug']}: $cnt vs $total\n"; $bad++; break; }
        if (count($s['pcs']) > PFB_W * PFB_H) { echo "FAIL board overflow\n"; $bad++; break; }
    }
    if (!$s['over']) { echo "FAIL fight did not end: {$c['slug']}\n"; $bad++; }
    $tbl[$c['size']][] = [(string)$s['over'], $s['turn']]; $byMode[$seed === 11 ? 'single' : 'builder'][] = [(string)$s['over'], $s['turn']];
}
if (!$quiet) foreach ($byMode as $m => $res) { $cnt = array_count_values(array_column($res, 0)); ksort($cnt); printf("mode %-7s n=%-3d avg turns %.1f  %s\n", $m, count($res), array_sum(array_column($res, 1)) / count($res), json_encode($cnt)); }
if (!$quiet) echo 'connect rule in force on ' . ($rules ?? 0) . ' side-turns (' . ($refused ?? 0) . ' non-connecting placements refused), relaxed on ' . ($free ?? 0) . "\n";
if (!$quiet) echo 'actions: ' . json_encode($kinds) . "\n";
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
// set-aside groups: join two pieces (a knob in a matching hole), add a third, never a fourth; play the group newest piece first
$g1 = $T('g1', 'trick', 2, 'body'); $g2 = $T('g2', 'hurt', 5, 'mind'); $g3 = $T('g3', 'heal', 3, 'craft'); $g4 = $T('g4', 'guard', 2, 'body');   // g1 R knob body -> g2 L hole body; g2 R knob mind -> g3 L hole mind
$s = $fresh(); $s['me']['hand'] = [$g1, $g2, $g3, $g4];
if (pfb_connect($s, 'me', 0, 1, 'R') !== null || count($s['me']['held']['pcs']) !== 2 || count($s['me']['hand']) !== 2) { echo "FAIL two pieces did not join\n"; $bad++; }
if (pfb_connect($s, 'me', 0, 1, 'R') === null) { echo "FAIL a second group was started while one was set aside\n"; $bad++; }
if (pfb_connect($s, 'me', null, 0, 'R', 1) !== null || count($s['me']['held']['pcs']) !== 3) { echo "FAIL a third piece did not join the group\n"; $bad++; }
if (pfb_connect($s, 'me', null, 0, 'R', 2) === null) { echo "FAIL a fourth piece was added to a group of three\n"; $bad++; }
// a flat contact does not link, so it cannot be set aside
$f1 = $T('f1', 'hurt', 3, null); $f2 = $T('f2', 'hurt', 3, null); $s2 = $fresh(); $s2['me']['hand'] = [$f1, $f2];
if (pfb_connect($s2, 'me', 0, 1, 'R') === null || !empty($s2['me']['held'])) { echo "FAIL a flat joint was accepted for a group\n"; $bad++; }
// playing the group of three: all three fire, the newest first, values x PFB_GROUP_MULT[3]
$s = $fresh(); $s['me']['hand'] = [$g1, $g2, $g3]; $s['foe']['hand'] = [];
pfb_connect($s, 'me', 0, 1, 'R'); pfb_connect($s, 'me', null, 0, 'R', 1);
$held = $s['me']['held']; $total0 = count($s['me']['hand']) + count($s['me']['draw']) + count($s['me']['discard']) + count($held['pcs']);
$spots = pfb_group_spots($s, $held);
if (!$spots) { echo "FAIL an empty board has no spot for the group\n"; $bad++; }
else {
    [$gx, $gy] = $spots[0]; $b0 = $s['bar']['now']; $ev = pfb_place_group($s, 'me', $gx, $gy);
    $names = array_column($ev ?? [], 'n');
    if (!$ev || $names[0] !== 'g3' || count($names) !== 3) { echo "FAIL group chain order: " . json_encode($names) . "\n"; $bad++; }
    if (!empty($s['me']['held']) || count($s['pcs']) !== 3) { echo "FAIL the group was not put on the board\n"; $bad++; }
    $heal = array_values(array_filter($ev ?? [], fn($e) => $e['n'] === 'g3'))[0] ?? null;
    if ($heal && $heal['v'] !== (int)round(3 * PFB_GROUP_MULT[3])) { echo "FAIL a group of three did not play at x" . PFB_GROUP_MULT[3] . " (got {$heal['v']})\n"; $bad++; }
    $cnt = count($s['me']['hand']) + count($s['me']['draw']) + count($s['me']['discard']) + count(array_filter($s['pcs'], fn($p) => $p['by'] === 'me'));
    if ($cnt !== $total0) { echo "FAIL tiles lost when a group was placed: $cnt vs $total0\n"; $bad++; }
}
// a whole turn: connect (no effect, the creature answers), then play the group; one action only
$st = ['level' => 3, 'grit' => 1, 'nimble' => 1, 'hardiness' => 1, 'charm' => 1, 'lore' => 1, 'luck' => 0];
$x = pfb_new(['hp' => 40, 'max_hp' => 40, 'stats' => $st, 'deck' => pf_player_deck($st), 'luck' => 0], $mkc, 5); $x['me']['hand'] = [$g1, $g2, $g3, $g4];
$r = pfb_play($x, [['j', 0, 1, 'R']], $x['turn']);
if ($r['err'] || empty($x['me']['held']) || !array_filter($r['ev'], fn($e) => !empty($e['connect']))) { echo "FAIL a connect turn: " . json_encode($r['err']) . "\n"; $bad++; }
if (pfb_play($x, [[0, 1, 1], [0, 2, 2]], $x['turn'])['err'] === null) { echo "FAIL two actions in one turn\n"; $bad++; }
$vv = pfb_view($x);
foreach ($vv['pcs'] as $p) if (!empty($p['fnew']) && ($x['pcs'][$p['id']]['seq'] ?? 99) <= 1) { echo "FAIL a piece the creature started with is flagged as new this turn\n"; $bad++; }
$g0 = pfb_new(['hp' => 40, 'max_hp' => 40, 'stats' => $st, 'deck' => pf_player_deck($st), 'luck' => 0], $mkc, 5); $g0['me']['block'] = 7; $g0['me']['keep'] = 2; pfb_end_round($g0);
if ($g0['me']['block'] !== 2 || $g0['me']['keep'] !== 0) { echo "FAIL your guard is not reset at the start of your turn (held guard carries)\n"; $bad++; }
$y = pfb_new(['hp' => 40, 'max_hp' => 40, 'stats' => $st, 'deck' => pf_player_deck($st), 'luck' => 0], $mkc, 5);
if (pfb_play($y, [['c', 3, 2]], $y['turn'])['err'] === null) { echo "FAIL played a group that was never set aside\n"; $bad++; }
// the board keeps the creature supplied: with fewer than two of its pieces out after its turn, one is put out (not fired); pieces that expire are listed for the replay (they scored first)
$s = $fresh(); $s['pcs'] = []; $s['cell'] = []; $s['round'] = 5; pfb_end_round($s);
$foeOut = count(array_filter($s['pcs'], fn($p) => $p['by'] === 'foe'));
if ($s['spawn'] === null || $foeOut !== 1) { echo "FAIL no creature piece was put out when it had none ({$foeOut})\n"; $bad++; }
$s = $fresh(); $s['pcs'] = []; $s['cell'] = []; $put($s, 'foe', $T('a', 'guard', 2, 'body'), 2, 2); $put($s, 'foe', $T('b', 'guard', 2, 'body'), 4, 2); $s['round'] = 1; pfb_end_round($s);
if ($s['spawn'] !== null || count($s['pcs']) !== 2) { echo "FAIL a piece was put out although the creature already had two\n"; $bad++; }
$s = $fresh(); $s['pcs'] = []; $s['cell'] = []; $old = $put($s, 'me', $h, 2, 2); $put($s, 'foe', $T('c', 'guard', 2, 'body'), 4, 2); $put($s, 'foe', $T('d', 'guard', 2, 'body'), 5, 2); $s['pcs'][$old]['born'] = 1; $s['round'] = 3; pfb_end_round($s);
if (!in_array($old, array_column($s['gone'], 'id'), true) || isset($s['pcs'][$old])) { echo "FAIL an expired piece is not listed in gone (or is still on the board)\n"; $bad++; }
// the history rewind: a placement keeps the board as it was (every piece with what the page needs), and a connect keeps it too
$s = $fresh(); $s['pcs'] = []; $s['cell'] = []; $s['me']['hand'] = [$g1]; $evp = pfb_place($s, 'me', 0, intdiv(PFB_W, 2), intdiv(PFB_H, 2));
if (!$evp || count($evp[0]['snap'] ?? []) !== 1 || $evp[0]['snap'][0]['n'] !== 'g1' || !isset($evp[0]['snap'][0]['e']['L'])) { echo "FAIL a placement did not keep a board snapshot\n"; $bad++; }
$x = pfb_new(['hp' => 40, 'max_hp' => 40, 'stats' => $st, 'deck' => pf_player_deck($st), 'luck' => 0], $mkc, 5); $x['me']['hand'] = [$g1, $g2, $g3, $g4];
$rj = pfb_play($x, [['j', 0, 1, 'R']], $x['turn']);
if (!isset($rj['ev'][0]['snap'])) { echo "FAIL a connect did not keep a board snapshot\n"; $bad++; }
// stale turn, bad moves, determinism, no leaks
$st = ['level' => 3, 'grit' => 1, 'nimble' => 1, 'hardiness' => 1, 'charm' => 1, 'lore' => 1, 'luck' => 0];
$mk = fn() => pfb_new(['hp' => 40, 'max_hp' => 40, 'stats' => $st, 'deck' => pf_player_deck($st), 'luck' => 0], $mkc, 77);
$a = $mk(); $b = $mk(); unset($a['nonce'], $b['nonce']);
$mv = [bsim_act($mk(), 'single')]; $x1 = $mk(); $x2 = $mk(); pfb_play($x1, $mv, 1); pfb_play($x2, $mv, 1); unset($x1['nonce'], $x2['nonce']);
if (json_encode($a) !== json_encode($b) || json_encode($x1) !== json_encode($x2)) { echo "FAIL board fight not deterministic\n"; $bad++; }
$x = $mk(); if (pfb_play($x, $mv, 9)['err'] !== 'stale') { echo "FAIL stale turn accepted\n"; $bad++; }
$x = $mk(); $before = json_encode($x); foreach ([[[0, 0, 0]], [[0, 2, 2], [0, 2, 2]], [[99, 1, 1]], [['a', 1, 1]], [], [['c', 1, 1]], [['j', 0, 0, 'R']], [['h', 0, 0, 'R']], [['j', 0, 1, 'Z']]] as $bm) { $r = pfb_play($x, $bm, 1); if ($r['err'] === null || json_encode($x) !== $before) { echo "FAIL bad move accepted or state changed: " . json_encode($bm) . "\n"; $bad++; } }
$v = pfb_view($mk()); $vj = json_encode($v);
if (str_contains($vj, '"rng"') || str_contains($vj, '"nonce"') || isset($v['draw']) || !is_int($v['foe']['hand'])) { echo "FAIL board view leaks\n"; $bad++; }
echo $bad ? "$bad FAILED\n" : "ok: " . count($rows) . " creatures\n";
exit($bad ? 1 : 0);
