<?php
// php agg.php out/LABEL.jsonl [more.jsonl ...] [--detail]   -> markdown tables: bot x size x level
$rows = []; $detail = in_array('--detail', $argv, true);
foreach (array_slice($argv, 1) as $f) if ($f[0] !== '-') foreach (file($f, FILE_IGNORE_NEW_LINES) as $l) { $r = json_decode($l, true); if ($r) $rows[] = $r; }
$g = [];
foreach ($rows as $r) { $g[$r['bot']][$r['d']][$r['size']][] = $r; $g[$r['bot']][$r['d']]['all'][] = $r; }
$avg = fn($a, $k) => array_sum(array_map(fn($r) => $r[$k], $a)) / max(1, count($a));
$order = ['random', 'chain', 'greedy', 'never3', 'look', 'smartn3', 'smart'];
$bots = array_values(array_unique(array_merge(array_intersect($order, array_keys($g)), array_keys($g))));
$ds = []; foreach ($g as $b) foreach ($b as $d => $_) $ds[$d] = 1; krsort($ds); $ds = array_keys($ds);
// 'all' = mean of the four sizes (each size counts the same; there are 43 large and 9 boss creatures)
$cell = function ($bys) use ($avg) { $o = []; foreach (['small', 'medium', 'large', 'boss'] as $sz) { $a = $bys[$sz] ?? []; $o[$sz] = [100 * $avg($a, 'win'), 100 * $avg($a, 'hp'), $avg($a, 'turns'), count($a)]; }
    $o['all'] = [array_sum(array_column($o, 0)) / 4, array_sum(array_column($o, 1)) / 4, array_sum(array_column($o, 2)) / 4, array_sum(array_column($o, 3))]; return $o; };
echo "Win % / health lost % / turns. `all` = mean of the four sizes.\n\n| Bot | Level | all | small | medium | large | boss | n per size |\n|---|---|---|---|---|---|---|---|\n";
foreach ($bots as $b) foreach ($ds as $d) { if (!isset($g[$b][$d])) continue; $c = $cell($g[$b][$d]);
    echo "| $b | " . ($d == 0 ? 'at level' : (-$d) . ' under') . ' | ' . implode(' | ', array_map(fn($k) => sprintf('%.0f / %.0f / %.1f', $c[$k][0], $c[$k][1], $c[$k][2]), ['all', 'small', 'medium', 'large', 'boss'])) . ' | ' . min($c['small'][3], $c['medium'][3], $c['large'][3], $c['boss'][3]) . "+ |\n"; }
if ($detail) {
    echo "\n| Bot | Level | pieces fired per placement | placements that use pieces up | took a 3+ chain when one was open | played the longest chain | my pieces out (turn start) | hand (turn start) | turns with no legal move | progress from re-fires | Teamwork per fight | creature fumbles per fight | health lost to bramble / thorn | my pieces used up: by my chains / by the creature's | fights that hit the turn cap |\n|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|\n";
    foreach ($bots as $b) foreach ($ds as $d) { $a = $g[$b][$d]['all'] ?? null; if (!$a) continue; $S = fn($k) => array_sum(array_map(fn($r) => $r[$k] ?? 0, $a)); $T = fn($k) => array_sum(array_map(fn($r) => $r['st'][$k] ?? 0, $a)); $n = count($a);
        printf("| %s | %s | %.2f | %.0f%% | %.0f%% | %.0f%% | %.1f | %.1f | %.1f%% | %.0f%% | %.2f | %.2f | %.0f%% / %.0f%% | %.1f / %.1f | %.1f%% |\n", $b, $d == 0 ? 'at level' : (-$d) . ' under', $S('fired') / max(1, $S('pl')), 100 * $S('long') / max(1, $S('pl')), 100 * $S('tookopp') / max(1, $S('opp')), 100 * $S('longest') / max(1, $S('pl')),
            $S('board') / max(1, $S('t')), $S('hand') / max(1, $S('t')), 100 * $S('nolegal') / max(1, $S('t')), 100 * $T('prog_refire') / max(1e-9, $T('prog_refire') + $T('prog_root')), $T('team') / $n, $T('fumble') / $n, 100 * $T('br_me') / $n, 100 * $T('thorn_me') / $n, $T('used_me_by_me') / $n, $T('used_me_by_foe') / $n, 100 * count(array_filter($a, fn($r) => in_array($r['over'], ['stall', 'cap'], true) || ($r['over'] === 'defeat' && $r['turns'] > 24))) / $n); }
}
