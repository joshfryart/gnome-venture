<?php
// 2.8.99 Sights v2, slice 3 (claude/proposal-sights-rework.md section 4 "Balance"): always-pays raises what the checked Sights pay. This sim prices every Sight row
// at full pay and at half pay (the v2 miss: sights_v2_half_tok + half Petals / XP) and compares the expected value of one use, v1 (setting off: a miss pays nothing
// and may slip energy) against v2 (a miss pays half; a tool Sight without the tool pays half).
// The proposal's bound: "a Sight still pays about one Gather per energy (today's target, sights-reward-tuning-2.7.08.md)"; that note sets one Gather = 15 Petal-value
// (1 XP = 1 Petal) and "no row over 30 goods (2 Gathers)". Asserted here:
//   1. the mean value per net energy of the energy-1 rows at level 1 under v2 is still about one Gather (between 0.75 and 1.5 Gathers);
//   2. no row pays more than 2 Gathers a use under v2 unless it already did under v1;
//   3. no row pays less under v2 than under v1 (always-pays only adds).
// The v2 / v1 ratio per row is printed (rows over 1.5x are listed): the proposal gives no per-row ratio bound.
// Model (the 2.7.08 note's): stat mod 0, no Luck reroll: pass = (21 - dc) x 5% (5 to 95), either / or stats combine, pick:N = 1 in N, a free pick always;
// item value = floor(base x 62.5%) x the rarity sell multiplier; crop / find / fish / seed = 5, gather = 15 (one Gather), take= costs the same; a token with a
// condition counts 1 in 3 (tl= always, tn= and first: not at all: one-offs); @N chances as written (a tool tier list: its first number).
// php tests/sights_v2_sim.php GAME_DIR   (an installed game)
$_SERVER['SCRIPT_NAME'] = '/adventure.php';
require $argv[1] . '/includes/bootstrap.php';
require_once $argv[1] . '/includes/adventure.php';
require_once $argv[1] . '/includes/trail_sights.php';
require_once $argv[1] . '/includes/items.php';
$fails = 0;
function ok(string $what, bool $cond, string $extra = ''): void { global $fails; echo ($cond ? '  ok   ' : '  FAIL ') . $what . ($cond ? '' : "  $extra") . "\n"; if (!$cond) $fails++; }
trail_sights_ensure_items();
const SIM_GATHER = 15.0;
$pct = max(25, (int)setting('sights_reward_pct')) / 100 * max(0, (int)setting('stop_reward_percent')) / 100;
$L = item_lookups();
$mult = ['C' => 100, 'U' => (int)setting('sell_mult_uncommon'), 'R' => (int)setting('sell_mult_rare'), 'L' => (int)setting('sell_mult_legendary')];
$itemVal = function (string $slug) use ($L, $mult): float {
    static $c = [];
    if (isset($c[$slug])) return $c[$slug];
    $it = q_one('SELECT * FROM items WHERE slug = ?', [$slug]);
    if (!$it) return $c[$slug] = 0.0;
    if (preg_match('/^(travel-cloak|flood-boots|wayfarers-hat|trail-pack|work-gloves)$/', $slug)) return $c[$slug] = 0.0;   // wearables drop only with pfight_v1
    [$r] = item_rarity($it, $L);
    return $c[$slug] = floor((int)$it['base_price'] * 0.625) * max(1, $mult[$r] ?? 100) / 100;
};
/** The Petal-value of one token, paid at scale $f (1 full, 0.5 the v2 half). [gain, energy back]. */
$tokVal = function (string $tok, float $f) use (&$tokVal, $pct, $itemVal): array {
    $tok = (string)preg_replace('/@(\d+)(\/\d+)+$/', '@$1', $tok);   // a tool tier list: its first number
    if ($f < 1 && $f > 0) { $dn = $tokVal($tok, -1.0); $up = $tokVal($tok, -2.0); return [($dn[0] + $up[0]) / 2, ($dn[1] + $up[1]) / 2]; }   // an odd @chance halves down or up at random: the average of both
    if ($f < 0) { $tok = sights_v2_half_tok($tok, $f < -1.5); if ($tok === '') return [0.0, 0.0]; $f = 0.5; }
    $ch = 1.0; if (preg_match('/^(.*)@(\d+)$/', $tok, $m)) { $tok = $m[1]; $ch = (int)$m[2] / 100; }
    [$k, $v] = array_pad(explode('=', $tok, 2), 2, ''); $p = explode(':', $v);
    switch ($k) {
        case 'c': case 'xp': return [((int)$p[0] + (int)($p[1] ?? 0)) * $pct * ($f < 1 ? 0.5 : 1) * $ch, 0.0];   // level 1
        case 'item': return [max(1, (int)($p[1] ?? 1)) * $itemVal($p[0]) * $ch, 0.0];
        case 'crop': case 'find': case 'fish': case 'seed': return [max(1, (int)$p[0]) * 5.0 * $ch, 0.0];
        case 'gather': return [SIM_GATHER * $ch * ($f < 1 ? 0.5 : 1), 0.0];
        case 'en': return [0.0, (int)$p[0] * $ch];
        case 'take': return [-max(1, (int)($p[1] ?? 1)) * (str_starts_with($p[0], 'any-') ? 5.0 : $itemVal($p[0])), 0.0];
    }
    return [0.0, 0.0];
};
/** [gain, energy back, take cost] of a row's rewards at scale $f. */
$rowVal = function (array $row, float $f) use ($tokVal): array {
    $g = 0.0; $en = 0.0; $cost = 0.0;
    foreach (trail_sight_tokens((string)$row['rewards']) as $t) {
        if ($t['lose'] || $t['first'] || str_contains($t['cond'], 'tn=')) continue;
        $odds = $t['cond'] === '' || (str_contains($t['cond'], 'tl=') && !preg_match('/(^|,)(?!tl=)[a-z]+=/', $t['cond'])) ? 1.0 : 1 / 3;
        if (str_starts_with($t['tok'], 'take=')) { $cost += -$tokVal($t['tok'], 1.0)[0] * $odds; continue; }
        if (str_starts_with($t['tok'], 'choose=')) { $opts = array_filter(explode(';', substr($t['tok'], 7))); $s = 0.0; foreach ($opts as $o) $s += $tokVal(trim($o), $f)[0]; $g += $odds * $s / max(1, count($opts)); continue; }
        [$a, $b] = $tokVal($t['tok'], $f); $g += $a * $odds; $en += $b * $odds;
    }
    return [$g, $en, $cost];
};
$passOf = function (array $row): float {
    $pk = trail_sight_pick_info($row);
    if ($pk) return trail_sight_free_pick($row) ? 1.0 : 1 / $pk[0];
    if ($row['check'] === '-' || !str_contains($row['check'], ':')) return 1.0;
    $miss = 1.0;
    foreach (explode('+', $row['check']) as $alt) {
        if (str_starts_with($alt, 'item:')) continue;
        $dc = (int)explode('?', explode(':', $alt, 2)[1] ?? '0')[0];
        $miss *= 1 - ($dc <= 0 ? 1.0 : max(5, min(95, (21 - $dc) * 5)) / 100);
    }
    return 1 - $miss;
};

echo "== the sim: every Sight row at full and at half pay (level 1, sights_reward_pct " . setting('sights_reward_pct') . ")\n";
$rows = trail_sights_all(); $out = [];
foreach ($rows as $slug => $r) {
    [$gF, $enF, $cost] = $rowVal($r, 1.0); [$gH, $enH] = $rowVal($r, 0.5);
    $p = $passOf($r);
    $v1 = $p * ($gF - $cost); $net1 = max(0.0, $r['energy'] + (1 - $p) * $r['fail_en'] - $p * $enF);
    $v2 = $p * ($gF - $cost) + (1 - $p) * ($gH - $cost); $net2 = max(0.0, $r['energy'] - $p * $enF - (1 - $p) * $enH);
    $v2nt = ($gH - $cost);   // a tool Sight without the tool (v1: no use at all)
    $out[$slug] = ['p' => $p, 'full' => $gF - $cost, 'half' => $gH - $cost, 'v1' => $v1, 'v2' => $v2, 'net1' => $net1, 'net2' => $net2, 'tool' => $r['tool'] !== '-', 'v2nt' => $v2nt, 'energy' => (int)$r['energy']];
}
$checked = array_filter($out, fn($o) => $o['p'] < 1);
$e1 = array_filter($out, fn($o) => $o['energy'] >= 1);
$mean = fn(array $a, string $k, string $n) => array_sum(array_map(fn($o) => $o[$n] > 0 ? $o[$k] / $o[$n] : 0, $a)) / max(1, count($a));
$m1 = $mean($e1, 'v1', 'net1'); $m2 = $mean($e1, 'v2', 'net2');
printf("  rows %d, checked (a stat, a pick) %d, tool rows %d\n", count($out), count($checked), count(array_filter($out, fn($o) => $o['tool'])));
printf("  energy-1 rows (%d): mean value per net energy v1 %.1f, v2 %.1f (one Gather = %.0f)\n", count($e1), $m1, $m2, SIM_GATHER);
printf("  checked rows: mean value a use v1 %.1f, v2 %.1f; total over all rows v1 %.0f, v2 %.0f (+%.1f%%)\n", array_sum(array_column($checked, 'v1')) / max(1, count($checked)), array_sum(array_column($checked, 'v2')) / max(1, count($checked)),
    array_sum(array_column($out, 'v1')), array_sum(array_column($out, 'v2')), (array_sum(array_column($out, 'v2')) / max(1, array_sum(array_column($out, 'v1'))) - 1) * 100);
$ratio = []; foreach ($checked as $s => $o) if ($o['v1'] > 0.5) $ratio[$s] = $o['v2'] / $o['v1'];
arsort($ratio);
printf("  v2 / v1 per checked row: median %.2f, max %.2f; over 1.5x: %d rows\n", $ratio ? array_values($ratio)[intdiv(count($ratio), 2)] : 0, $ratio ? max($ratio) : 0, count(array_filter($ratio, fn($x) => $x > 1.5)));
foreach (array_slice($ratio, 0, 8, true) as $s => $x) printf("     %-34s pass %3.0f%%  v1 %5.1f  v2 %5.1f  (%.2fx)\n", $s, $out[$s]['p'] * 100, $out[$s]['v1'], $out[$s]['v2'], $x);

echo "== the bounds\n";
ok(sprintf('energy-1 rows still pay about one Gather per energy under v2 (%.1f, between %.1f and %.1f)', $m2, 0.75 * SIM_GATHER, 1.5 * SIM_GATHER), $m2 >= 0.75 * SIM_GATHER && $m2 <= 1.5 * SIM_GATHER);
$over = array_keys(array_filter($out, fn($o) => $o['v2'] > 2 * SIM_GATHER && $o['v1'] <= 2 * SIM_GATHER));
ok('no row goes over 2 Gathers a use because of v2', !$over, implode(', ', array_map(fn($s) => sprintf('%s %.1f (v1 %.1f)', $s, $out[$s]['v2'], $out[$s]['v1']), $over)));
$less = array_keys(array_filter($out, fn($o) => $o['v2'] < $o['v1'] - 0.01));
ok('no row pays less under v2 than under v1', !$less, implode(', ', $less));
$offHalf = array_keys(array_filter($rows, function ($r) use ($rowVal) { [$f] = $rowVal($r, 1.0); [$h] = $rowVal($r, 0.5); return $f > 0 && ($h <= 0 || abs($h * 2 - $f) > max(0.5, 0.1 * $f)); }));
ok('the half pay of every paying row is above 0 and about half its full pay (an odd @chance halves up or down at random)', !$offHalf, implode(', ', array_slice($offHalf, 0, 10)));
echo $fails ? "$fails FAILED\n" : "ok\n";
exit($fails ? 1 : 0);
