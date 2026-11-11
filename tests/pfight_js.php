<?php
// Emits random fight situations with the totals the PHP engine computes, for tests/pfight_js.js to compare with game/assets/pfight.js (the preview must match the server).
require __DIR__ . '/../game/includes/pfight.php';
mt_srand(5); $T = array_keys(PF_HOLE); $K = ['body', 'mind', 'craft', null]; $cases = [];
for ($n = 0; $n < 3000; $n++) {
    $by = ['me', 'foe'][mt_rand(0, 1)];
    $prev = mt_rand(0, 4) ? ['t' => $T[mt_rand(0, 6)], 'r' => $K[mt_rand(0, 3)], 'v' => mt_rand(1, 9)] : null;
    $hand = []; for ($i = 0; $i < 5; $i++) $hand[] = ['t' => $T[mt_rand(0, 6)], 'v' => mt_rand(1, 40), 'r' => $K[mt_rand(0, 3)]];
    $idx = range(0, 4); shuffle($idx); $idx = array_slice($idx, 0, mt_rand(1, 4));
    $tot = array_fill_keys($T, 0); $p = $prev; $ok = $by === 'me'; $notes = [];
    foreach ($idx as $i) { [$v, , $ck] = pf_value($p, $hand[$i], $ok); $ok = true; $tot[$hand[$i]['t']] += $v; if ($ck) $notes[] = PF_COMBOS[$ck]['name']; $p = $hand[$i]; }
    $cases[] = compact('prev', 'by', 'hand', 'idx', 'tot', 'notes');
}
echo json_encode(['cases' => $cases, 'combos' => PF_COMBOS, 'hole' => PF_HOLE]);
