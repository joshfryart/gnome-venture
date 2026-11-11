<?php
// php opening.php BOT OFFS : every start choice (hand idx x side) per fight; how much the opening matters
putenv('ENG=' . __DIR__ . '/eng'); require __DIR__ . '/common.php';
$bot = $argv[1] ?? 'greedy'; $offs = array_map('intval', explode(',', $argv[2] ?? '0,-8'));
$rows = array_values(pp_creatures()); $R = [];
foreach ($offs as $d) foreach ($rows as $c) {
    $lv = max(1, $c['level'] + $d); $seed = 900 + $c['level']; $s0 = pfb_new(pp_player($lv), $c, $seed, ['blank' => true]);
    $res = [];
    foreach ($s0['me']['hand'] as $hi => $ht) foreach (['L', 'R', 'T', 'B'] as $sd) {
        $s = $s0; pfb_start($s, $hi, $sd); mt_srand($seed); $t = 0;
        while (!$s['over'] && $t++ < 40) {
            if ($bot === 'noisy' && mt_rand(0, 99) < 35) { $l = legal_places($s); if ($l) { pfb_play($s, [$l[mt_rand(0, count($l) - 1)]], $s['turn']); continue; } }
            $m = pfb_search($s, 'me'); $r = $m ? pfb_play($s, [[$m[0], $m[1], $m[2]]], $s['turn']) : pfb_pass($s, $s['turn']); if ($r['err']) break; }
        $win = in_array($s['over'], ['seen_off', 'charmed'], true);
        $res[] = ['win' => $win ? 1 : 0, 'sc' => $win ? 1 + $s['me']['hp'] / $s['me']['max'] : max($s['fh']['now'], $s['bar']['now']) / $s['fh']['max'], 'turns' => $s['turn'], 'hurt' => $ht['t'] === 'hurt', 'v' => $ht['v'], 'hi' => $hi, 'sd' => $sd];
    }
    $bk = 0; $bsc = -1e9; $k = 0; foreach ($s0['me']['hand'] as $hi => $ht) foreach (['L', 'R', 'T', 'B'] as $sd) { $w = $s0; pfb_start($w, $hi, $sd); $m = pfb_search($w, 'me'); $x = $w; if ($m) pfb_play($x, [[$m[0], $m[1], $m[2]]], $x['turn']); $sc = pfb_score($w, $x, 'me'); if ($sc > $bsc) { $bsc = $sc; $bk = $k; } $k++; }
    $res[0]['look'] = $res[$bk]['win'];
    $R[] = $res;
}
$n = count($R); $flip = 0; $spread = 0; $or = 0; $rand = 0; $bh = 0; $tsp = 0;
foreach ($R as $res) { $w = array_column($res, 'win'); $sc = array_column($res, 'sc'); $tu = array_column($res, 'turns');
    if (max($w) !== min($w)) $flip++; $spread += max($sc) - min($sc); $or += max($w); $rand += array_sum($w) / count($w); $tsp += max($tu) - min($tu);
    $best = null; foreach ($res as $r) if ($r['hurt'] && ($best === null || $r['v'] > $best['v'])) $best = $r; $bh += $best ? $best['win'] : $res[0]['win']; }
$lk = array_sum(array_map(fn($r) => $r[0]["look"], $R)); printf("look1-start %.0f%% | ", 100 * $lk / $n); printf("fights=%d flip=%.0f%% score_spread=%.2f turn_spread=%.1f | win: oracle %.0f%% random-start %.0f%% best-hurt %.0f%% (oracle-random %.0f pts)\n", $n, 100 * $flip / $n, $spread / $n, $tsp / $n, 100 * $or / $n, 100 * $rand / $n, 100 * $bh / $n, 100 * ($or - $rand) / $n);
