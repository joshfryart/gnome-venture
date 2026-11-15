<?php
// 2.7.01: why is the "real choice" share 14-20% (target 50%)? Breaks every look-bot turn down by WHY it is or is not a real choice, and measures levers.
// Definition (tests/pfboard_tune_v1.php tv_real): top 6 actions by 1-ply value, each scored 2-ply (tv_v2); a1 = best, a2 = best with ANOTHER hand piece; span = V2(a1) - worst of the six.
// real = span >= 0.02 and V2(a1) - V2(a2) <= 0.10 x span.
// Each turn falls in one bucket: none (no action), one (only one hand piece among the top 6), flat (span < 0.02: nothing matters), dom (another piece exists but is more than 10% of the span behind), real.
// Also: the gap ratio (V2(a1) - V2(a2)) / span, real at 20% and 30% thresholds, legal actions, hand pieces with a legal cell.
//   php tools/sims/realchoice_2701.php TAG [V1_JSON] [MULT] [OFFSET]  -> one json line per fight.   php tools/sims/realchoice_2701.php agg < lines
require_once __DIR__ . '/../../tests/pfboard_tune_v1.php';
if (realpath($argv[0]) !== __FILE__) return;
if (($argv[1] ?? '') === 'agg') {
    $G = []; while (($l = fgets(STDIN)) !== false) { $r = json_decode($l, true); if ($r) $G[$r['tag']][] = $r; }
    printf("%-26s %5s %6s %6s | %5s %5s %5s %5s %5s | %6s %6s | %5s %5s %6s\n", 'variant', 'fights', 'win%', 'turns', 'none', 'one', 'flat', 'dom', 'REAL', 'r@20%', 'r@30%', 'acts', 'pcs', 'gapmed');
    foreach ($G as $tag => $rs) {
        $n = count($rs); $T = array_sum(array_column($rs, 'nt')); $sum = fn($k) => array_sum(array_column($rs, $k)); $gaps = []; foreach ($rs as $r) foreach ($r['gaps'] as $g) $gaps[] = $g; sort($gaps);
        printf("%-26s %5d %6.1f %6.2f | %5.1f %5.1f %5.1f %5.1f %5.1f | %6.1f %6.1f | %5.1f %5.2f %6.2f\n", $tag, $n, 100 * $sum('win') / $n, $sum('turns') / $n,
            100 * $sum('none') / $T, 100 * $sum('one') / $T, 100 * $sum('flat') / $T, 100 * $sum('dom') / $T, 100 * $sum('real') / $T, 100 * $sum('r20') / $T, 100 * $sum('r30') / $T, $sum('acts') / $T, $sum('pcs') / $T, $gaps ? $gaps[intdiv(count($gaps), 2)] : 0);
    }
    exit;
}
$tag = $argv[1] ?? 'base'; $V1 = json_decode($argv[2] ?? '{}', true) ?: []; $mult = (float)($argv[3] ?? 0.25); $off = (int)($argv[4] ?? 0);
foreach (tv_creatures() as $c) {
    $over = []; foreach ($V1 as $k => $v) $over[$k] = is_array($v) ? ($v[$c['size']] ?? null) : $v; $over = array_filter($over, fn($v) => $v !== null);
    $nk = max(1, (int)ceil(TV_SEEDS[$c['size']] * $mult));
    for ($k = 0; $k < $nk; $k++) {
        $lv = max(1, $c['level'] + $off); $seed = 500 + 7 * $k + $c['level'] + 1000 * (crc32($c['slug']) % 97);
        $cr = pfd_foe_row($c, array_keys(pfd_region_pieces())[(crc32($c['slug']) + $k) % 14]);
        $s = pfb_new(tv_player($lv), $cr, $seed, ['blank' => true, 'v1' => $over ?: true]);
        $hand = $s['me']['hand']; $bi = 0; foreach ($hand as $i => $t) if ($t['t'] === 'hurt' && $t['v'] > $hand[$bi]['v']) $bi = $i;
        pfb_start($s, $bi, ['L', 'R', 'T', 'B'][$k % 4]);
        $st = ['nt' => 0, 'none' => 0, 'one' => 0, 'flat' => 0, 'dom' => 0, 'real' => 0, 'r20' => 0, 'r30' => 0, 'acts' => 0, 'pcs' => 0, 'gaps' => []]; $t = 0;
        while (!$s['over'] && $t++ < 40) {
            $pl = tv_places($s); $all = array_merge($pl, tv_joins($s)); $st['nt']++; $st['acts'] += count($all);
            $st['pcs'] += count(array_unique(array_map(fn($a) => tv_key($s, $a), $all)));
            $top = array_slice(tv_ranked($s, $all), 0, 6);
            if (!$top) $st['none']++;
            else {
                $v = []; foreach ($top as $i => [$v1, $a, $w]) $v[$i] = tv_v2($s, $a, $v1, $w);
                $i1 = 0; foreach ($v as $i => $x) if ($x > $v[$i1] + 1e-12) $i1 = $i;
                $k1 = tv_key($s, $top[$i1][1]); $v2 = null; foreach ($v as $i => $x) if (tv_key($s, $top[$i][1]) !== $k1 && ($v2 === null || $x > $v2)) $v2 = $x;
                $span = $v[$i1] - min($v);
                if ($v2 === null) $st['one']++;
                elseif ($span < 0.02) $st['flat']++;
                else { $gap = ($v[$i1] - $v2) / $span; $st['gaps'][] = round($gap, 3);
                    if ($gap <= 0.10 + 1e-9) $st['real']++; else $st['dom']++;
                    if ($gap <= 0.20 + 1e-9) $st['r20']++; if ($gap <= 0.30 + 1e-9) $st['r30']++; }
            }
            $a = tv_choose($s, 'look', $pl); $r = tv_act($s, $a);
            if ($r['err']) { $r = pfb_pass($s, $s['turn']); if ($r['err']) { if (!$pl) break; $r = tv_act($s, $pl[0]); if ($r['err']) break; } }
        }
        echo json_encode(['tag' => $tag, 'size' => $c['size'], 'slug' => $c['slug'], 'win' => in_array($s['over'], ['seen_off', 'charmed'], true) ? 1 : 0, 'turns' => $s['turn']] + $st), "\n";
    }
}
