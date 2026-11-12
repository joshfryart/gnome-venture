<?php
// php agg3.php out/LABEL.jsonl [--sizes] [--d=0] [--bots=chain,smart] [--pieces]   -> sim 3 numbers, one line per bot x level (x size with --sizes). `all` = mean of the four sizes.
// Columns: win% hp-lost% turns | best move changes: ground / events / both (any), both 3+ points, fights where a forecast changed the plan | turn cap%, passes per fight, turns with no legal move%
// | placements that use pieces up%, took a 3+ chain when open%, my pieces out at turn start | progress from sunny%, my sunny fires (re-fires) per fight, creature sunny fires
// | health lost to bramble / thorn burst, creature health lost to bramble / thorn burst | Teamwork 2-source / 3-source chains per fight, fights with any% | top piece share of a fight's progress% | pieces pushed by gusts, pieces that got ground put under them (per fight)
$rows = []; $opt = [];
foreach (array_slice($argv, 1) as $f) { if ($f[0] === '-') { [$k, $v] = explode('=', ltrim($f, '-') . '=1'); $opt[$k] = $v; continue; } foreach (file($f, FILE_IGNORE_NEW_LINES) as $l) { $r = json_decode($l, true); if ($r) $rows[] = $r; } }
$g = []; foreach ($rows as $r) $g[$r['bot']][$r['d']][$r['size']][] = $r;
$order = ['random', 'chain', 'greedy', 'never3', 'look-ge', 'look-g', 'look-e', 'look', 'smartn3', 'smart-ge', 'smart-g', 'smart-e', 'smart'];
$bots = array_values(array_unique(array_merge(array_intersect($order, array_keys($g)), array_keys($g)))); if (isset($opt['bots'])) $bots = array_intersect(explode(',', $opt['bots']), $bots);
$stat = function (array $a): array {
    $n = max(1, count($a)); $S = fn($k) => array_sum(array_map(fn($r) => $r[$k] ?? 0, $a)); $T = fn($k) => array_sum(array_map(fn($r) => $r['st'][$k] ?? 0, $a)); $bn = max(1, $S('bm_n'));
    $top = 0; foreach ($a as $r) { $pk = array_filter($r['st'], fn($v, $k) => strpos($k, 'pk_') === 0, ARRAY_FILTER_USE_BOTH); $top += $pk && array_sum($pk) > 0 ? max($pk) / array_sum($pk) : 0; }
    return [100 * $S('win') / $n, 100 * $S('hp') / $n, $S('turns') / $n,
        100 * $S('bm_g') / $bn, 100 * $S('bm_e') / $bn, 100 * $S('bm_ge') / $bn, 100 * $S('bm3_ge') / $bn, 100 * $S('bm_efight') / $n,
        100 * count(array_filter($a, fn($r) => in_array($r['over'], ['stall', 'cap'], true) || ($r['over'] === 'defeat' && $r['turns'] > 24))) / $n, $S('pass') / $n, 100 * $S('nolegal') / max(1, $S('t')),
        100 * $S('long') / max(1, $S('pl')), 100 * $S('tookopp') / max(1, $S('opp')), $S('board') / max(1, $S('t')),
        100 * $T('prog_sun') / max(1e-9, $T('prog_refire') + $T('prog_root')), $T('sun_me') / $n, $T('sunre_me') / $n, $T('sun_foe') / $n,
        100 * $T('br_me') / $n, 100 * $T('thorn_me') / $n, 100 * $T('br_foe') / $n, 100 * $T('thorn_foe') / $n,
        $T('team2') / $n, $T('team3') / $n, 100 * count(array_filter($a, fn($r) => ($r['st']['team2'] ?? 0) + ($r['st']['team3'] ?? 0) > 0)) / $n, 100 * $top / $n,
        ($T('gust_me') + $T('gust_foe')) / $n, ($T('sunbeam_me') + $T('creep_me') + $T('puddle_me') + $T('sunbeam_foe') + $T('creep_foe') + $T('puddle_foe')) / $n, count($a)];
};
$fmt = '%-9s %3s %-6s n=%-4d %3.0f / %2.0f / %4.1f | bm g %2.0f e %2.0f ge %2.0f ge3 %2.0f efight %2.0f | cap %.1f pass %.2f nolegal %.1f | useup %2.0f took %2.0f out %.1f | sun %2.0f%% %.2f (%.2f) foe %.2f | env me %2.0f/%2.0f foe %2.0f/%2.0f | tw %.2f %.2f %2.0f%% | top %2.0f | gust %.2f grnd %.2f' . "\n";
foreach ($bots as $b) { $ds = array_keys($g[$b]); rsort($ds); foreach ($ds as $d) { if (isset($opt['d']) && (int)$opt['d'] !== (int)$d) continue;
    $per = []; foreach (['small', 'medium', 'large', 'boss'] as $sz) if (!empty($g[$b][$d][$sz])) $per[$sz] = $stat($g[$b][$d][$sz]);
    $all = []; foreach (array_keys(reset($per)) as $i) $all[$i] = array_sum(array_column($per, $i)) / count($per);
    $out = isset($opt['sizes']) ? ['all' => $all] + $per : ['all' => $all];
    foreach ($out as $sz => $v) { $n = array_pop($v); vprintf($fmt, array_merge([$b, $d, $sz, $n], $v)); } } }
if (isset($opt['pieces'])) foreach ($bots as $b) { $pk = []; foreach ($g[$b][0] ?? [] as $a) foreach ($a as $r) foreach ($r['st'] as $k => $v) if (strpos($k, 'pk_') === 0) $pk[substr($k, 3)] = ($pk[substr($k, 3)] ?? 0) + $v; arsort($pk); $t = max(1e-9, array_sum($pk));
    echo "$b, at level, pieces by share of progress: " . implode(', ', array_map(fn($k) => sprintf('%s %.0f%%', $k, 100 * $pk[$k] / $t), array_slice(array_keys($pk), 0, 5))) . "\n"; }
