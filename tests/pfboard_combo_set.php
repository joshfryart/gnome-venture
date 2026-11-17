<?php
// 2.7.06 (Josh) set combos: a piece's combo comes from the pieces of its own side in the SAME chain, not only the piece it linked to or the order they were played in. No DB, no server.
require __DIR__ . '/../game/includes/pfboard.php';
$GLOBALS['PFB_TEST_SIZES'] = ['small' => [5, 4], 'medium' => [5, 5], 'large' => [7, 5], 'boss' => [7, 6]];
require __DIR__ . '/../game/includes/pfight_game.php';
require __DIR__ . '/../game/includes/pfdeck.php';
$bad = 0; $warn = [];
set_error_handler(function (int $no, string $msg, string $file, int $line) use (&$warn) { $warn[] = "$msg ($file:$line)"; return true; });
function chk(string $name, bool $ok, $got = ''): void { global $bad; echo ($ok ? 'ok   ' : 'FAIL ') . $name . ($ok ? '' : ' (got ' . (is_string($got) ? $got : json_encode($got)) . ')') . "\n"; if (!$ok) $bad++; }
function ab_me(int $lv = 8): array
{
    $m = max(0, intdiv($lv + 3, 14)); $st = ['grit' => $m, 'nimble' => $m, 'hardiness' => $m, 'charm' => $m, 'lore' => $m, 'luck' => $m, 'level' => $lv];
    $max = 20 + 3 * $lv + 5 * $m;
    return ['hp' => $max, 'max_hp' => $max, 'stats' => $st, 'deck' => pf_player_deck($st, 'thornblade', 1, [], pf_unlocks($lv)), 'luck' => $m];
}
function ab_foe(string $size, array $x = []): array { return $x + ['slug' => 'test-thing', 'name' => 'Test Thing', 'size' => $size, 'level' => 8, 'dmg_die' => ['small' => 4, 'medium' => 6, 'large' => 8, 'boss' => 10][$size], 'dmg_bonus' => 2]; }
/** A v1 fight with an empty board and the creature's abilities in; $row adds to the creature row (class, ab, abp), $over to the rule numbers. */
function ab_fight(string $size = 'medium', array $row = [], array $over = [], int $seed = 7): array
{
    $s = pfb_new(ab_me(), ab_foe($size, $row), $seed, ['v1' => $over + ['order' => 0, 'spawn' => 1]]);
    $s['pcs'] = []; $s['cell'] = []; $s['ter'] = []; $s['envs'] = []; $s['foe']['plan'] = null; $s['spent'] = []; $s['ven'] = []; $s['env'] = ['draw' => [], 'discard' => [], 'next' => []];
    ab_put($s, 'foe', ab_tile($s, 'f:base', 'guard', 1), 0, 3);   // a far corner piece, so the board is not empty (a cell needs a neighbour; an aimed cell does not)
    return $s;
}
function ab_tile(array $s, string $k, string $t, int $v, string $r = 'body', string $src = 'creature', string $tag = ''): array
{
    return ['ed' => array_fill_keys(['L', 'R', 'T', 'B'], ['wild', null])] + pfb_v1_tile(['k' => $k, 'n' => ucfirst($k), 't' => $t, 'v' => $v, 'r' => $r, 'tag' => $tag, 'm' => '', 'src' => $src], $s['v1']);   // wild edges: it fits wherever it goes
}
function ab_put(array &$s, string $who, array $tile, int $x, int $y): int
{
    $id = ++$s['pid']; $s['seq']++;
    $s['pcs'][$id] = ['id' => $id, 'by' => $who, 'tile' => $tile, 'x' => $x, 'y' => $y, 'born' => $s['round'], 'seq' => $s['seq']];
    $s['cell']["$x,$y"] = $id;
    return $id;
}
function ab_place(array &$s, string $who, array $tile, int $x, int $y): ?array { $s[$who]['hand'] = [$tile]; $s['aimforce'] = true; $r = pfb_place($s, $who, 0, $x, $y); unset($s['aimforce']); return $r; }   // aimforce: the cell need not touch anything
/** The creature's turn with one piece in its hand and its aim on (x, y): returns the events. */
function combo_of(array $ev, string $n): ?string { foreach ($ev as $e) if (($e['n'] ?? '') === $n && isset($e['id'])) return $e['combo'] ?? null; return '(not fired)'; }
function chain3(int $cset, array $order): array
{   // Trick (0,0), Guard (1,0), Hurt (2,0) in a row; the pieces are put down in $order, the last one is the one placed (the chain root)
    $s = ab_fight('medium', [], ['cset' => $cset]); $s['me']['hp'] = $s['me']['max'];
    $t = ['T' => ab_tile($s, 'T', 'trick', 4, 'body', 'basic'), 'G' => ab_tile($s, 'G', 'guard', 4, 'body', 'basic'), 'H' => ab_tile($s, 'H', 'hurt', 6, 'body', 'basic')]; $x = ['T' => 0, 'G' => 1, 'H' => 2];
    $last = array_pop($order);
    foreach ($order as $k) ab_put($s, 'me', $t[$k], $x[$k], 0);
    return [$s, ab_place($s, 'me', $t[$last], $x[$last], 0)];
}
echo "== set combos\n";
[$s, $ev] = chain3(1, ['T', 'G', 'H']);
chk('Hurt linked to the Guard but with a Trick in the chain: the best combo is Ambush (trick x1.5 + the trick), not only Riposte', combo_of($ev, 'H') === 'trick>hurt' || stripos((string)combo_of($ev, 'H'), 'Ambush') !== false, combo_of($ev, 'H'));
[$s, $ev] = chain3(0, ['T', 'G', 'H']);
chk('(old rule, cset 0) the placed Hurt is the chain root, so it has no parent and no combo at all', combo_of($ev, 'H') === null, combo_of($ev, 'H'));
foreach ([['T', 'G', 'H'], ['H', 'G', 'T'], ['G', 'H', 'T'], ['H', 'T', 'G']] as $o) {
    [$s, $ev] = chain3(1, $o);
    chk('played order ' . implode('', $o) . ': the Hurt still has Ambush', stripos((string)combo_of($ev, 'H'), 'Ambush') !== false, combo_of($ev, 'H'));
}
[$s, $ev] = chain3(1, ['T', 'G', 'H']);
chk('Guard with a Trick in the chain: Bait (any order)', stripos((string)combo_of($ev, 'G'), 'Bait') !== false, combo_of($ev, 'G'));
chk('the Trick itself has no combo', combo_of($ev, 'T') === null, combo_of($ev, 'T'));
// Double Swing: the first Hurt of the chain has none, the later one does
$s = ab_fight('medium', [], ['cset' => 1]); $h1 = ab_tile($s, 'H1', 'hurt', 5, 'body', 'basic'); $h2 = ab_tile($s, 'H2', 'hurt', 5, 'body', 'basic');
ab_put($s, 'me', $h1, 0, 0); $ev = ab_place($s, 'me', $h2, 1, 0);
$fired = array_values(array_filter($ev, fn($e) => ($e['t'] ?? '') === 'hurt' && isset($e['id']))); $cb = array_map(fn($e) => $e['combo'] ?? null, $fired);
chk('two Hurts in one chain: exactly one gets Double Swing (the one that fires second)', count($fired) === 2 && count(array_filter($cb)) === 1 && stripos((string)$cb[1], 'Double') !== false, $cb);
// only your own pieces count
$s = ab_fight('medium', [], ['cset' => 1]); $ft = ab_tile($s, 'FT', 'trick', 4); $h = ab_tile($s, 'H', 'hurt', 6, 'body', 'basic');
ab_put($s, 'foe', $ft, 0, 0); $ev = ab_place($s, 'me', $h, 1, 0);
chk('the creature\'s Trick in your chain gives you no combo', combo_of($ev, 'H') === null, combo_of($ev, 'H'));
echo $bad ? "$bad FAILED\n" : "all ok\n"; exit($bad ? 1 : 0);
