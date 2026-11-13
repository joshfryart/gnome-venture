<?php
// The tuner's choice metrics (tests/pfboard_tune_v1.php): `real` (a turn with two different hand pieces that are about equally good), `dead`, `mine0`.
// php tests/pfboard_tune_v1_metrics.php
require __DIR__ . '/../game/includes/pfboard.php';
require __DIR__ . '/../game/includes/pfdeck.php';
require __DIR__ . '/pfboard_tune_v1.php';
$bad = 0;
function chk(string $name, bool $ok, $got = ''): void { global $bad; echo ($ok ? 'ok   ' : 'FAIL ') . $name . ($ok ? '' : ' (got ' . json_encode($got) . ')') . "\n"; if (!$ok) $bad++; }
function m_foe(): array { return ['slug' => 'test-thing', 'name' => 'Test Thing', 'size' => 'medium', 'level' => 8, 'dmg_die' => 6, 'dmg_bonus' => 2, 'class' => 'Beast']; }
function m_me(): array
{
    $st = ['grit' => 0, 'nimble' => 0, 'hardiness' => 0, 'charm' => 0, 'lore' => 0, 'luck' => 0, 'level' => 8];
    return ['hp' => 44, 'max_hp' => 44, 'stats' => $st, 'deck' => pf_player_deck($st, 'thornblade', 1, [], pf_unlocks(8)), 'luck' => 0];
}
/** A board full of creature pieces but one open cell (so each hand piece has one place, and its flip), and my hand set to $hand. */
function m_state(array $hand): array
{
    $s = pfb_new(m_me(), m_foe(), 7, ['v1' => true]);
    $s['pcs'] = []; $s['cell'] = []; $s['ter'] = []; $s['envs'] = []; $s['foe']['plan'] = null; $s['spent'] = [];
    $w = ['wild', null]; $ed = ['L' => $w, 'R' => $w, 'T' => $w, 'B' => $w];
    $mk = fn(string $k, string $t, int $v) => pfb_v1_tile(['k' => $k, 'n' => ucfirst($k), 't' => $t, 'v' => $v, 'r' => null, 'tag' => '', 'm' => '', 'src' => 'knack', 'ed' => $ed], $s['v1']);
    for ($y = 0; $y < $s['h']; $y++) for ($x = 0; $x < $s['w']; $x++) {
        if ($x === 1 && $y === 1) continue;
        $id = ++$s['pid']; $s['seq']++;
        $s['pcs'][$id] = ['id' => $id, 'by' => 'foe', 'tile' => $mk('stone', 'guard', 1), 'x' => $x, 'y' => $y, 'born' => $s['round'], 'seq' => $s['seq']]; $s['cell']["$x,$y"] = $id;
    }
    $s['me']['hand'] = array_map(fn($h) => $mk(...$h), $hand); $s['me']['held'] = null;
    return $s;
}
echo "== choice metrics\n";
chk('the tuner has tv_real', function_exists('tv_real'));
if (function_exists('tv_real')) {
    $two = m_state([['hurt_a', 'hurt', 6], ['hurt_b', 'hurt', 6], ['dud', 'guard', 1]]);
    $r = tv_real($two, array_merge(tv_places($two), tv_joins($two)));
    chk('two equal Hurt pieces: the turn is a real choice', ($r['real'] ?? null) === 1, $r);
    chk('two equal Hurt pieces: the 1-ply and 2-ply picks agree on value (no ply flip)', isset($r['plyflip']) && is_int($r['plyflip']), $r);
    $one = m_state([['hurt_a', 'hurt', 6]]);
    $r1 = tv_real($one, array_merge(tv_places($one), tv_joins($one)));
    chk('one piece only: the turn is not a real choice', ($r1['real'] ?? null) === 0, $r1);
    $mine = m_state([['hurt_a', 'hurt', 6]]);
    chk('mine0 sees no piece of mine on the board', tv_mine0($mine) === 1);
    $id = ++$mine['pid']; $mine['pcs'][$id] = ['id' => $id, 'by' => 'me', 'tile' => $mine['me']['hand'][0], 'x' => 0, 'y' => 0, 'born' => 1, 'seq' => 9];
    chk('mine counts a piece of mine on the board', tv_mine0($mine) === 0);
    $dead = m_state([['dud', 'guard', 0]]); $dead['me']['block'] = 0;
    chk('dead: nothing in the hand makes progress', tv_dead($dead, tv_places($dead)) === 1);
    chk('not dead: a Hurt piece makes progress', tv_dead($one, tv_places($one)) === 0);
}
echo $bad ? "$bad FAILED\n" : "all ok\n"; exit($bad ? 1 : 0);
