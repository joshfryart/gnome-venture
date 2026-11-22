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
    $s = pfb_new(ab_me(), ab_foe($size, $row), $seed, ['v1' => $over + ['order' => 0, 'spawn' => 1, 'cset' => 0, 'envopen' => 0, 'tagfx' => 0]]);
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
    $s = ab_fight('medium', [], ['cset' => $cset, 'envopen' => 0]); $s['me']['hp'] = $s['me']['max'];
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
echo "== Quick, Heavy and Sticky do something on the board (2.7.06)\n";
$order = function (int $tagfx, string $tagA, string $tagB) {   // Hurt A (placed first) and Hurt B in one chain: which fires first?
    $s = ab_fight('medium', [], ['cset' => 0, 'envopen' => 0, 'order' => 1, 'tagfx' => $tagfx]);
    $a = ab_tile($s, 'A', 'hurt', 5, 'body', 'basic', $tagA); $b = ab_tile($s, 'B', 'hurt', 5, 'body', 'basic', $tagB);
    ab_put($s, 'me', $a, 0, 0); $ev = ab_place($s, 'me', $b, 1, 0);
    return array_values(array_map(fn($e) => $e['n'], array_filter($ev, fn($e) => ($e['t'] ?? '') === 'hurt' && isset($e['id']))));
};
chk('Quick fires first in its chain even though it was put down first and a plain piece was placed (old rule: the placed piece first)', $order(1, 'quick', '') === ['A', 'B'] && $order(0, 'quick', '') === ['B', 'A'], [$order(1, 'quick', ''), $order(0, 'quick', '')]);
chk('Heavy fires last in its chain even when it is the piece you placed (old rule: the placed piece first)', $order(1, '', 'heavy') === ['A', 'B'] && $order(0, '', 'heavy') === ['B', 'A'], [$order(1, '', 'heavy'), $order(0, '', 'heavy')]);
foreach ([1, 0] as $fx) { $s = ab_fight('medium', [], ['cset' => 0, 'envopen' => 0, 'tagfx' => $fx]); $hv = ab_tile($s, 'H', 'hurt', 6, 'body', 'basic', 'heavy');
    $ev = ab_place($s, 'me', $hv, 1, 1); $fired = count(array_filter($ev, fn($e) => ($e['n'] ?? '') === 'H' && isset($e['id']))); $left = count(array_filter($s['pcs'], fn($p) => $p['by'] === 'me'));
    $res[$fx] = [$fired, $left]; }
chk('Heavy swings once and falls away (fired once and gone at once; the old rule leaves it on the board)', $res[1] === [1, 0] && $res[0] === [1, 1], $res);
$s = ab_fight('medium', [], ['cset' => 0, 'envopen' => 0, 'tagfx' => 1]); $st = ab_tile($s, 'S', 'guard', 3, 'body', 'basic'); $st['m'] = 'sticky'; $pl = ab_tile($s, 'P', 'guard', 3, 'body', 'basic');
ab_put($s, 'me', $st, 0, 0); ab_put($s, 'me', $pl, 3, 3); $s['round']++; $s['round']++; pfb_expire($s);
$alive = array_values(array_map(fn($p) => $p['tile']['n'], array_filter($s['pcs'], fn($p) => $p['by'] === 'me')));
chk('Sticky stays one round longer than a plain piece (born the same round: the plain one is gone first)', in_array('S', $alive, true) && !in_array('P', $alive, true), $alive);
echo "== events matter more (2.7.06)\n";
foreach (['small', 'medium', 'large', 'boss'] as $sz) {
    $a = pfb_new(ab_me(), ab_foe($sz), 7, ['v1' => true]); $b = pfb_new(ab_me(), ab_foe($sz), 7, ['v1' => ['envopen' => 1]]);
    $en = PFB_ENV_N[$sz];   // 2.7.55: small places ONE a round (one environment piece on its 3x3 board at a time)
    chk("$sz: the environment puts down " . ($en === 1 ? 'ONE piece a round (2.7.55: small, one at a time)' : 'TWO pieces a round (Josh 2026-11-17)') . ", so as many lie face up (envopen 1 adds one more for the first round)", (int)$a['v1']['envn'] === $en && count($a['env']['next']) === $en && count($b['env']['next']) === $en + 1, [$a['v1']['envn'], count($a['env']['next']), count($b['env']['next'])]);
}
chk('Rain guards 20% (was 15%), event damage on the creature 70% (was 50%)', PFB_RAIN === 0.20 && PFB_EVENT_FOE === 0.7, [PFB_RAIN, PFB_EVENT_FOE]);
echo $bad ? "$bad FAILED\n" : "all ok\n"; exit($bad ? 1 : 0);
