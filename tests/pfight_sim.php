<?php
// Puzzle Combat bot sim (no DB): php tests/pfight_sim.php [--quiet]. Every creature in creatures.txt x 4 bots x seeds.
// Checks invariants (tile conservation, a legal move always exists, every fight ends within the turn cap) and prints pace/win tables.
require __DIR__ . '/../game/includes/pfight.php';
$quiet = in_array('--quiet', $argv, true);
$rows = [];
$sizeMult = ['small' => 0.8, 'medium' => 1.1, 'large' => 1.6, 'boss' => 2.4]; $die = ['small' => 4, 'medium' => 6, 'large' => 8, 'boss' => 10];
foreach (file(__DIR__ . '/../game/includes/data/creatures.txt', FILE_IGNORE_NEW_LINES) as $l) {
    if ($l === '' || $l[0] === '#') continue;
    $c = explode('|', $l); if (count($c) < 7) continue;
    $lv = max(1, (int)$c[4]);
    $rows[] = ['slug' => $c[0], 'name' => $c[1], 'size' => $c[2], 'level' => $lv, 'dmg_die' => $die[$c[2]] ?? 6, 'dmg_bonus' => intdiv($lv, 4)];
}
function sim_player(int $lv): array
{
    $m = intdiv($lv, 4) + 1;   // a rough stat modifier curve: +1 at level 1, +8 at level 28
    $st = ['grit' => $m, 'nimble' => $m, 'hardiness' => $m, 'charm' => $m, 'lore' => max(0, $m - 1), 'luck' => $m * 2, 'level' => $lv];
    $callings = array_keys(PF_CALLING_TILE);
    $deck = pf_player_deck($st, $callings[$lv % 6], 1 + intdiv($lv, 12));
    $max = 20 + 3 * $lv + 5 * $m;
    return ['hp' => $max, 'max_hp' => $max, 'stats' => $st, 'deck' => $deck, 'luck' => $m * 2];
}
// bots: each returns a hand index list
$bots = [
    'greedy' => function ($s) { $h = $s['me']['hand']; $best = null; $bv = -1;
        $try = function ($chosen, $used) use (&$try, &$best, &$bv, $h, $s) {
            if ($chosen) { $prev = $s['strip'] ? $s['strip'][count($s['strip']) - 1]['tile'] : null; $v = 0;
                foreach ($chosen as $i) { [$x] = pf_value($prev, $h[$i]); $w = in_array($h[$i]['t'], ['hurt', 'charm'], true) ? 1 : 0.3; $v += $x * $w; $prev = $h[$i]; }
                if ($v > $bv) { $bv = $v; $best = $chosen; } }
            if (count($chosen) < 3) foreach (array_keys($h) as $i) if (!in_array($i, $used, true)) $try([...$chosen, $i], [...$used, $i]); };
        $try([], []); return $best ?: [0]; },
    'always4' => fn($s) => array_slice(array_keys($s['me']['hand']), 0, 4),
    'charm' => function ($s) { $h = $s['me']['hand']; $o = []; foreach ($h as $i => $t) if (in_array($t['t'], ['charm', 'soothe', 'heal', 'item'], true)) $o[] = $i; return $o ? array_slice($o, 0, 3) : [0]; },
    'stall' => function ($s) { $h = $s['me']['hand']; foreach ($h as $i => $t) if ($t['t'] === 'guard') return [$i]; return [0]; },
];
$bad = 0; $tbl = [];
foreach ($rows as $c) {
    foreach ($bots as $bn => $bot) {
        foreach ([11, 22, 33] as $seed) {
            $me = sim_player($c['level']);
            $s = pf_new($me, $c, $seed + $c['level']);
            $total = count($me['deck']);
            $t = 0;
            while (!$s['over'] && $t++ < 60) {
                $mv = $bot($s);
                if ($s['me']['hand'] === []) { echo "FAIL no legal move: {$c['slug']} $bn turn {$s['turn']}\n"; $bad++; break; }
                $r = pf_play($s, $mv, $s['turn']);
                if ($r['err']) { echo "FAIL illegal bot move {$c['slug']} $bn: {$r['err']}\n"; $bad++; break; }
                $n = count($s['me']['hand']) + count($s['me']['draw']) + count($s['me']['discard']);
                if ($n !== $total) { echo "FAIL tile conservation {$c['slug']} $bn: $n vs $total\n"; $bad++; break; }
            }
            if (!$s['over']) { echo "FAIL fight did not end: {$c['slug']} $bn\n"; $bad++; }
            $tbl[$c['size']][$bn][] = [$s['over'], $s['turn']];
        }
    }
}
if (!$quiet) foreach ($tbl as $size => $byBot) foreach ($byBot as $bn => $res) {
    $cnt = array_count_values(array_column($res, 0)); ksort($cnt);
    printf("%-7s %-8s n=%-3d avg turns %.1f  %s\n", $size, $bn, count($res), array_sum(array_column($res, 1)) / count($res), json_encode($cnt));
}
// determinism: same seed, same moves, same result
$a = pf_new(sim_player(5), $rows[3], 99); $b = pf_new(sim_player(5), $rows[3], 99);
pf_play($a, [0, 1], 1); pf_play($b, [0, 1], 1);
if (json_encode($a) !== json_encode($b)) { echo "FAIL seeded fight not deterministic\n"; $bad++; }
// stale turn ignored, view hides draw and foe hand
$r = pf_play($a, [0], 1); if ($r['err'] !== 'stale') { echo "FAIL stale turn accepted\n"; $bad++; }
$v = json_encode(pf_view($a)); if (str_contains($v, '"draw"') || !is_int(pf_view($a)['foe']['hand'])) { echo "FAIL view leaks\n"; $bad++; }
echo $bad ? "$bad FAILED\n" : "ok: " . count($rows) . " creatures\n";
exit($bad ? 1 : 0);
