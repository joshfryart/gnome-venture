<?php
// Board mode tuning table (no DB): php tests/pfboard_tune.php [seeds=3]. Greedy bot (pfb_search) over every creature at gnome level = creature level + d,
// classic and blank start: win %, turns, HP lost %, by size. Compare before/after a balance change.
require __DIR__ . '/../game/includes/pfboard.php';
$N = (int)($argv[1] ?? 3); $die = ['small' => 4, 'medium' => 6, 'large' => 8, 'boss' => 10]; $rows = [];
foreach (file(__DIR__ . '/../game/includes/data/creatures.txt', FILE_IGNORE_NEW_LINES) as $l) {
    if ($l === '' || $l[0] === '#') continue; $c = explode('|', $l); if (count($c) < 7) continue;
    $lv = max(1, (int)$c[4]); $rows[] = ['slug' => $c[0], 'name' => $c[1], 'size' => $c[2], 'level' => $lv, 'dmg_die' => $die[$c[2]] ?? 6, 'dmg_bonus' => intdiv($lv, 4)];
}
function tn_player(int $lv): array
{
    $m = max(0, intdiv($lv + 3, 14)); $st = ['grit' => $m, 'nimble' => $m, 'hardiness' => $m, 'charm' => $m, 'lore' => $m, 'luck' => $m, 'level' => $lv];
    $cals = array_keys(PF_CALLING_TILE); $cal = $cals[$lv % 6]; $own = pf_collection($lv, $cal); $cap = pf_box_capacity($lv);
    $want = ['hurt' => 5, 'charm' => 3, 'guard' => 3, 'heal' => 1, 'trick' => 1, 'item' => 1, 'soothe' => 0]; $box = []; $n = [];
    foreach ($own as $k) { $t = pf_tiles()[$k]['t']; if (($n[$t] ?? 0) < ($want[$t] ?? 0) && count($box) < $cap) { $box[] = $k; $n[$t] = ($n[$t] ?? 0) + 1; } }
    foreach ($own as $k) if (!in_array($k, $box, true) && count($box) < $cap) $box[] = $k;
    $max = 20 + 3 * $lv + 5 * $m;
    return ['hp' => $max, 'max_hp' => $max, 'stats' => $st, 'deck' => pf_player_deck($st, $cal, 1 + intdiv($lv, 12), [], [], [], true, $box), 'luck' => $m];
}
$out = [];
foreach ([0, -8] as $d) foreach (['classic', 'blank'] as $mode) {
    $g = [];
    foreach ($rows as $c) for ($k = 0; $k < $N; $k++) {
        $lv = max(1, $c['level'] + $d); $me = tn_player($lv); $seed = 500 + 7 * $k + $c['level'];
        $s = pfb_new($me, $c, $seed, $mode === 'blank' ? ['blank' => true] : []);
        if ($mode === 'blank') { $hand = $s['me']['hand']; $bi = 0; foreach ($hand as $i => $t) if ($t['t'] === 'hurt' && $t['v'] > $hand[$bi]['v']) $bi = $i; pfb_start($s, $bi, ['L', 'R', 'T', 'B'][$k % 4]); }
        $t = 0;
        while (!$s['over'] && $t++ < 40) { $m1 = pfb_search($s, 'me'); $r = $m1 ? pfb_play($s, [[$m1[0], $m1[1], $m1[2]]], $s['turn']) : pfb_pass($s, $s['turn']); if ($r['err']) break; }
        $g[$c['size']][] = [in_array($s['over'], ['seen_off', 'charmed'], true), $s['turn'], 1 - $s['me']['hp'] / max(1, $s['me']['max'])];
    }
    foreach (['small', 'medium', 'large', 'boss'] as $sz) { $a = $g[$sz] ?? []; if (!$a) continue; $n = count($a);
        $out[] = sprintf("d%+d %-7s %-6s n=%3d win=%3d%% turns=%.1f hp_lost=%2d%%", $d, $mode, $sz, $n, 100 * array_sum(array_column($a, 0)) / $n, array_sum(array_column($a, 1)) / $n, 100 * array_sum(array_column($a, 2)) / $n); }
}
echo implode("\n", $out), "\n";
