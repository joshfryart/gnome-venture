<?php
// Next release: the ORDER a chain's pieces take effect in (Josh's vote: environment, defence, augments, Hurt/Charm, healing) and no free creature piece (rule 'spawn' 0).
// Section 18b of tests/pfboard_v1.php, which includes this file and its helpers (chk, v1_bare, v1_tile, v1_put, v1_place, v1_env).

echo "== 18b. activation order and no free creature piece\n";
$wild18 = ['ed' => array_fill_keys(['L', 'R', 'T', 'B'], ['wild', null])];
/** a row: heal (1,2), guard (3,2), trick (2,3), sun (2,1) around the cell (2,2) where a hurt piece is placed; every edge wild so they all link */
$row18 = function (array $over) use ($wild18) {
    $s = v1_bare('medium', $over);
    foreach ([['h18', 'heal', 3, 1, 2], ['g18', 'guard', 3, 3, 2], ['t18', 'trick', 2, 2, 3]] as [$k, $t, $v, $x, $y]) v1_put($s, 'me', $wild18 + v1_tile($s, $k, $t, $v, 'mind'), $x, $y);
    v1_put($s, 'env', v1_env('sun'), 2, 1);
    return $s;
};
$s = $row18(['order' => 1]); $ev = v1_place($s, 'me', $wild18 + v1_tile($s, 'x18', 'hurt', 5, 'body'), 2, 2);
$ts = array_map(fn($e) => ($e['by'] === 'env' ? 'env' : $e['t']), array_values(array_filter($ev, fn($e) => isset($e['id']))));
chk('order 1: environment, then guard, then trick, then hurt (the placed piece), then heal', $ts === ['env', 'guard', 'trick', 'hurt', 'heal'], $ts);
chk('order 1: the first event opens the chain (cs) and names the placed piece (rid); snap and linked ride on it', !empty($ev[0]['cs']) && isset($ev[0]['rid']) && ($rootE = array_values(array_filter($ev, fn($e) => !empty($e['root']))))  && $rootE[0]['id'] === $ev[0]['rid'] && $ev[0]['id'] !== $ev[0]['rid'] && isset($ev[0]['snap'], $ev[0]['linked']), array_keys($ev[0]));
chk('order 1: Sun still doubles the Hurt and the root flag stays on the placed piece', (function () use ($ev) { foreach ($ev as $e) if (($e['t'] ?? '') === 'hurt') return !empty($e['root']) && !empty($e['sun']); return false; })());
$s = $row18(['order' => 0]); $ev0 = v1_place($s, 'me', $wild18 + v1_tile($s, 'x18', 'hurt', 5, 'body'), 2, 2);
$t0 = array_map(fn($e) => ($e['by'] === 'env' ? 'env' : $e['t']), array_values(array_filter($ev0, fn($e) => isset($e['id']))));
chk('order 0 (a fight started before): the placed piece first, then the link order as before', $t0[0] === 'hurt' && count($t0) === 5, $t0);
chk('a new fight has order 1 and spawn 0; a state without the keys reads order 0, spawn 1', ($n = pfb_new(v1_me(), v1_foe('medium'), 5, ['v1' => true])) && pfb_v1r($n, 'order') === 1 && pfb_v1r($n, 'spawn') === 0 && ($o = $n) && (function () use ($o) { unset($o['v1']['order'], $o['v1']['spawn']); return pfb_v1r($o, 'order') === 0 && pfb_v1r($o, 'spawn') === 1; })());
// spawn: a board short of creature pieces
$mk18 = function (int $spawn) use ($wild18) {
    $s = v1_bare('medium', ['spawn' => $spawn]); v1_put($s, 'me', $wild18 + v1_tile($s, 'm18', 'charm', 3, 'body'), 1, 2);
    $s['foe']['draw'] = [$wild18 + v1_tile($s, 'f:x', 'charm', 2, 'body', 'creature'), $wild18 + v1_tile($s, 'f:y', 'charm', 2, 'mind', 'creature')]; $s['foe']['hand'] = []; $s['env'] = ['draw' => [], 'discard' => [], 'next' => []];
    pfb_end_round($s); return $s;
};
$s = $mk18(0); chk('spawn 0: the board puts out no free creature piece, however short the creature is', ($s['spawn'] ?? null) === null && !array_filter($s['pcs'], fn($p) => $p['by'] === 'foe'), [$s['spawn'] ?? 'unset']);
$s = $mk18(1); chk('spawn 1 (a fight started before): the free piece still comes', ($s['spawn'] ?? null) !== null);
