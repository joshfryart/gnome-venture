<?php
// 2.7.01 costly cell (claude/reviews-2026-11-13/learn.md, item 1): a lit cell whose chain costs you health names the cause.
// Section 30 of tests/pfboard_v1.php (uses its helpers chk, v1_me, v1_foe). pfb_cell_preview's v1 entry carries 'hw' = [[name, by, health], ...]
// for each piece in your chain that took health from you (a creature piece linked in, Thornburst), only when the cell costs health.

echo "== 30. costly cell: the preview names what costs you health (2.7.01)\n";
$found = 0; $badHw = [];
foreach (['small', 'medium'] as $size) for ($seed = 1; $seed <= 60 && $found < 25; $seed++) {
    $s = pfb_new(v1_me(), v1_foe($size), $seed, ['v1' => true]);
    for ($t = 0; $t < 8 && !$s['over']; $t++) {
        $first = null;
        foreach ($s['me']['hand'] as $i => $tile) {
            foreach (pfb_cell_preview($s, $i) as $k => $q) {
                $first ??= [$i, $k];
                if ($q['hp'] > 0) {
                    $found++; $hw = $q['hw'] ?? null; $sum = 0; $shape = is_array($hw) && $hw;
                    foreach ((array)$hw as $w) { if (!is_array($w) || count($w) !== 3 || !is_string($w[0]) || $w[0] === '' || !in_array($w[1], ['foe', 'env', 'me'], true) || (int)$w[2] <= 0) $shape = false; $sum += (int)($w[2] ?? 0); }
                    if (!$shape || $sum < $q['hp']) $badHw[] = [$size, $seed, $t, $k, $q['hp'], $hw];
                }
            }
        }
        if (!$first) { pfb_pass($s, $s['turn']); continue; }
        [$x, $y] = array_map('intval', explode(',', $first[1]));
        pfb_play($s, [[$first[0], $x, $y]], $s['turn']);
    }
}
chk('arrange: the sweep met costly cells (at least 5)', $found >= 5, $found);
chk('every costly cell names its cause: hw = [[name, by, health > 0], ...], health adds up to at least the cost', !$badHw, array_slice($badHw, 0, 3));
$s = pfb_new(v1_me(), v1_foe('small'), 3, ['v1' => true]);
$free = 0; foreach ($s['me']['hand'] as $i => $tile) foreach (pfb_cell_preview($s, $i) as $q) if ($q['hp'] === 0 && isset($q['hw'])) $free++;
chk('a cell that costs nothing carries no hw (the payload stays small)', $free === 0, $free);
