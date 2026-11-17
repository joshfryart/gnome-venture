<?php
// 2.7.01 creature abilities (claude/creature-pass/SPEC.md sec 2): the 8 new engine effects (drain, plated, enrage, wary, toughhide, ambush, stagger, regrow), the class-rule variants (E ids), the compat key `abil`,
// the loader of data/pf_creatures.txt (tests/pf_creatures_fixture.txt) and the region filter of pick_creature. Every effect check fails on the 2.7.00 engine (it ignores the row's `ab`). No DB, no server.
// php tests/pfboard_v1_abil.php
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
    $s = pfb_new(ab_me(), ab_foe($size, $row), $seed, ['v1' => $over + ['order' => 0, 'spawn' => 1, 'cset' => 0, 'envopen' => 0]]);
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
function ab_turn(array &$s, array $tiles, int $x, int $y): array
{
    $s['foe']['hand'] = $tiles; $h = $tiles[0]; $s['foe']['plan'] = ['k' => $h['k'], 'n' => $h['n'], 't' => $h['t'], 'v' => $h['v'], 'tag' => $h['tag'], 'x' => $x, 'y' => $y];
    return pfb_foe_turn($s, 0);
}
$notes = fn(array $ev, string $k) => array_values(array_filter($ev, fn($e) => ($e['note'] ?? '') === $k));
$near = fn(float $a, float $b) => abs($a - $b) < 1e-9;
$hurtOf = fn(array $ev) => array_values(array_filter($ev, fn($e) => ($e['t'] ?? '') === 'hurt' && ($e['by'] ?? '') === 'foe' && !isset($e['note'])));

echo "== 1. the table, the parser, the compat key\n";
chk('the table: 13 E + 16 N + 12 D = 41 ids', count(PFB_ABIL) === 41 && count(array_filter(PFB_ABIL, fn($a) => $a[0] === 'E')) === 13 && count(array_filter(PFB_ABIL, fn($a) => $a[0] === 'N')) === 16 && count(array_filter(PFB_ABIL, fn($a) => $a[0] === 'D')) === 12);
chk('every card text is at most 80 characters', !array_filter(PFB_ABIL, fn($a) => strlen($a[5]) > 80), array_keys(array_filter(PFB_ABIL, fn($a) => strlen($a[5]) > 80)));
$p = pfb_ab_parse('drain1(pct=0.9)+D1+bogus+drain1');
chk('parse: ids in order, unknown and repeated ids dropped, an override is clamped into its range', $p['ids'] === ['drain1', 'D1'] && $p['p'] === ['drain1' => ['pct' => 0.6]], $p);
$p = pfb_ab_parse('enrage1(at=0.9;mult=1.0;nope=3)');
chk('parse: every number clamped, an unknown name dropped', $p['p'] === ['enrage1' => ['at' => 0.7, 'mult' => 1.1]], $p);
chk('parse: "-" and empty give nothing', pfb_ab_parse('-')['ids'] === [] && pfb_ab_parse('')['ids'] === []);
chk('abil is 0 in PRE (a fight saved before 2.7.01) and 1 in a new fight', PFB_V1_PRE['abil'] === 0 && pfb_v1_cfg('medium')['abil'] === 1 && pfb_v1r(['v1' => ['limit' => 3]], 'abil') === 0);
$s = ab_fight('medium', ['ab' => ['drain1', 'D1']]);
chk('a fight with abilities keeps their ids and resolved numbers', $s['foe']['ab'] === ['drain1', 'D1'] && $s['foe']['abp'] === ['drain1' => ['pct' => 0.25]] && $s['foe']['enr'] === 0 && $s['foe']['turns'] === 0 && $s['me']['tough'] === 0, $s['foe']);
$a = ab_fight('medium'); $b = ab_fight('medium', ['ab' => []]);
chk('no abilities (or an empty list): the state is the same as 2.7.00 gave, key for key', (function () use ($a, $b) { unset($a['nonce'], $b['nonce']); return json_encode($a) === json_encode($b); })() && !isset($a['foe']['ab']) && !isset($a['me']['tough']));
$s = ab_fight('medium', ['ab' => ['drain2']], ['abil' => 0]);
chk('abil 0 (an old fight): the row\'s abilities are ignored', !isset($s['foe']['ab']) && pfb_ab($s, 'drain') === null);
$j = json_decode(json_encode(ab_fight('medium', ['ab' => ['drain2']])), true); unset($j['v1']['abil']);
chk('a saved 2.7.00 state with abilities added by hand: pfb_ab is null without the key', pfb_ab($j, 'drain') === null);

echo "== 2. Drain\n";
$s = ab_fight('medium', ['ab' => ['drain1']]); $s['fh']['now'] = 20.0; $hp = $s['me']['hp'];
$ev = ab_place($s, 'foe', ab_tile($s, 'f:h', 'hurt', 10), 1, 1);
chk('Drain I: a hit that lands 10 heals it a quarter: 2.5 off its Yield bar', $near($s['fh']['now'], 17.5) && $s['me']['hp'] === $hp - 10, [$s['fh']['now'], $s['me']['hp']]);
chk('Drain: a notice with the amount follows the piece', ($n = $notes($ev, 'drain')) && $n[0]['n'] === '2.5' && $ev[0]['drained'] === 2.5, $ev);
$s = ab_fight('medium', ['ab' => ['drain2']]); $s['fh']['now'] = 20.0; ab_place($s, 'foe', ab_tile($s, 'f:h', 'hurt', 10), 1, 1);
chk('Drain II: half: 5', $near($s['fh']['now'], 15.0), $s['fh']['now']);
$s = ab_fight('medium', ['ab' => ['drain2(pct=0.15)']]);
$s = ab_fight('medium', ['ab' => ['drain2'], 'abp' => ['drain2' => ['pct' => 0.15]]]); $s['fh']['now'] = 20.0; ab_place($s, 'foe', ab_tile($s, 'f:h', 'hurt', 10), 1, 1);
chk('Drain: a row override within the range is used (0.15 of 10)', $near($s['fh']['now'], 18.5), $s['fh']['now']);
$s = ab_fight('medium', ['ab' => ['drain2']]); $s['fh']['now'] = 20.0; $s['me']['block'] = 10; $ev = ab_place($s, 'foe', ab_tile($s, 'f:h', 'hurt', 10), 1, 1);
chk('Drain: a fully blocked hit heals nothing and has no notice', $near($s['fh']['now'], 20.0) && !$notes($ev, 'drain'), $s['fh']['now']);
$s = ab_fight('medium', ['ab' => ['drain2']]); $s['fh']['now'] = 20.0; $s['me']['evade'] = 1; ab_place($s, 'foe', ab_tile($s, 'f:h', 'hurt', 10), 1, 1);
chk('Drain: an Evaded hit heals nothing', $near($s['fh']['now'], 20.0), $s['fh']['now']);
$s = ab_fight('medium', ['ab' => ['drain2']]); $s['fh']['now'] = 20.0; $s['me']['block'] = 6; ab_place($s, 'foe', ab_tile($s, 'f:h', 'hurt', 10), 1, 1);
chk('Drain: only what lands counts (10 into 6 guard = 4: 2 healed)', $near($s['fh']['now'], 18.0), $s['fh']['now']);
$s = ab_fight('medium', ['ab' => ['drain2']]); $s['fh']['now'] = 20.0; $s['foe']['poison'] = 0; $s['me']['poison'] = 2; $s['me']['poison_v'] = 3; $hp = $s['me']['hp']; pfb_end_round($s);
chk('Drain: a poison tick on you does not drain', $near($s['fh']['now'], 20.0) && $s['me']['hp'] === $hp - 3, [$s['fh']['now'], $s['me']['hp']]);
$s = ab_fight('medium'); $s['fh']['now'] = 20.0; ab_place($s, 'foe', ab_tile($s, 'f:h', 'hurt', 10), 1, 1);
chk('(2.7.00 engine: no ability, no heal)', $near($s['fh']['now'], 20.0));
$s = ab_fight('medium', ['ab' => ['drain2']]); $s['bar']['now'] = 4.0; $s['bar']['charm'] = 4.0; $s['fh']['now'] = 1.0; ab_place($s, 'foe', ab_tile($s, 'f:h', 'hurt', 10), 1, 1);
chk('Drain: heals the Hurt part first, then the Charm part (5 healed: 1 hurt, 4 charm)', $near($s['fh']['now'], 0.0) && $near($s['bar']['now'], 0.0) && $near($s['bar']['charm'], 0.0), [$s['fh']['now'], $s['bar']['now']]);

echo "== 3. Plated\n";
$s = ab_fight('medium', ['ab' => ['plated1']]); $s['foe']['hand'] = []; $y = (float)$s['fh']['max']; $ev = pfb_foe_turn($s, 0);
chk('Plated I: it starts its turn with ceil(3% of the Yield bar) guard', $s['foe']['block'] === (int)ceil($y * 0.03) && $s['foe']['block'] >= 1, [$s['foe']['block'], $y]);
chk('Plated: a notice says how much', ($n = $notes($ev, 'plated')) && $n[0]['n'] === (string)$s['foe']['block'], $ev);
$s = ab_fight('medium', ['ab' => ['plated2']]); $s['foe']['hand'] = []; pfb_foe_turn($s, 0);
chk('Plated II: 5%', $s['foe']['block'] === (int)ceil((float)$s['fh']['max'] * 0.05), $s['foe']['block']);
$s = ab_fight('medium', ['ab' => ['plated1']]); $s['foe']['hand'] = []; $s['foe']['block'] = 99; $s['foe']['keep'] = 0; pfb_foe_turn($s, 0);
chk('Plated: guard is recomputed each turn (last turn\'s is gone: it is not Hold)', $s['foe']['block'] === (int)ceil((float)$s['fh']['max'] * 0.03), $s['foe']['block']);
$s = ab_fight('medium', ['ab' => ['plated1']]); $s['foe']['hand'] = []; $s['foe']['keep'] = 50; $s['foe']['block'] = 0; pfb_foe_turn($s, 0);
chk('Plated: never lowers a bigger guard (Hold 50 stays)', $s['foe']['block'] === 50, $s['foe']['block']);
$s = ab_fight('medium', ['ab' => ['plated2']]); $s['foe']['hand'] = []; pfb_foe_turn($s, 0); $g = $s['foe']['block']; $fh = $s['fh']['now'];
$ev = ab_place($s, 'me', ab_tile($s, 'p', 'hurt', $g + 4, 'body', 'knack'), 1, 1);
chk('Plated: your Hurt soaks into it like any guard', $near($s['fh']['now'] - $fh, 4.0 * $s['hm']), [$s['fh']['now'] - $fh, $g]);
$s = ab_fight('medium', ['ab' => ['plated2']]); $s['foe']['hand'] = []; pfb_foe_turn($s, 0); $fh = $s['fh']['now'];
ab_place($s, 'me', ab_tile($s, 'p', 'hurt', 9, 'body', 'knack', 'pierce'), 1, 1);
chk('Plated: Pierce ignores it', $near($s['fh']['now'] - $fh, 9.0 * $s['hm']), $s['fh']['now'] - $fh);
$s = ab_fight('medium'); $s['foe']['hand'] = []; pfb_foe_turn($s, 0);
chk('(2.7.00 engine: no guard at the start of its turn)', $s['foe']['block'] === 0);

echo "== 4. Enrage\n";
$s = ab_fight('medium', ['ab' => ['enrage1']]); $y = (float)$s['fh']['max']; $s['fh']['now'] = $y * 0.49; pf_check_end($s);
chk('Enrage I: below half the Yield bar it is not set', empty($s['foe']['enr']), $s['foe']['enr']);
$s['fh']['now'] = $y * 0.5; pf_check_end($s);
chk('Enrage I: at half the bar it is set', $s['foe']['enr'] === 1);
$ev = ab_place($s, 'foe', ab_tile($s, 'f:h', 'hurt', 10), 1, 1); $hp = $s['me']['hp'];
chk('Enrage I: its Hurt counts x1.15 (10 -> 12 with the rounding) from then on', $ev[0]['v'] === 12, $ev[0]['v']);
$s['fh']['now'] = 0.0; $s['bar']['now'] = 0.0; pf_check_end($s);
chk('Enrage: never cleared (healed back to nothing, still set)', $s['foe']['enr'] === 1);
$s = ab_fight('medium', ['ab' => ['enrage2']]); $y = (float)$s['fh']['max']; $s['bar']['now'] = $y * 0.4; $s['bar']['charm'] = $y * 0.4; pf_check_end($s);
chk('Enrage II: Charm fills the same bar: at 40% it is set', $s['foe']['enr'] === 1);
$ev = ab_place($s, 'foe', ab_tile($s, 'f:h', 'hurt', 10), 1, 1);
chk('Enrage II: x1.25 (12.5 -> 13)', $ev[0]['v'] === 13, $ev[0]['v']);
$s = ab_fight('medium', ['ab' => ['enrage2']]); $s['foe']['enr'] = 1; $s['me']['block'] = 7; $hp = $s['me']['hp']; ab_place($s, 'foe', ab_tile($s, 'f:h', 'hurt', 10), 1, 1);
chk('Enrage: guard works as usual after it (13 into 7 guard)', $s['me']['hp'] === $hp - 6, $s['me']['hp']);
$s = ab_fight('medium'); $s['fh']['now'] = (float)$s['fh']['max'] * 0.9; pf_check_end($s); $ev = ab_place($s, 'foe', ab_tile($s, 'f:h', 'hurt', 10), 1, 1);
chk('(2.7.00 engine: no Enrage)', $ev[0]['v'] === 10 && !isset($s['foe']['enr']));
$s = ab_fight('medium', ['ab' => ['enrage1']]); $s['foe']['enr'] = 1; $ev = ab_place($s, 'me', ab_tile($s, 'p', 'hurt', 10, 'body', 'knack'), 1, 1);
chk('Enrage: only the creature\'s Hurt (yours is as it was)', $ev[0]['v'] === 10, $ev[0]['v']);

echo "== 5. Wary\n";
$s = ab_fight('medium'); $cm = $s['cm']; $ev = ab_place($s, 'me', ab_tile($s, 'p', 'charm', 10, 'body', 'knack'), 1, 1); $base = $s['bar']['now'];
$s = ab_fight('medium', ['ab' => ['wary1']]); $ev = ab_place($s, 'me', ab_tile($s, 'p', 'charm', 10, 'body', 'knack'), 1, 1);
chk('Wary I: your Charm fills x0.85', $cm > 0 && $near($s['bar']['now'], $base * 0.85) && $near($s['bar']['charm'], $base * 0.85), [$s['bar']['now'], $base]);
$s = ab_fight('medium', ['ab' => ['wary2']]); ab_place($s, 'me', ab_tile($s, 'p', 'charm', 10, 'body', 'knack'), 1, 1);
chk('Wary II: x0.75', $near($s['bar']['now'], $base * 0.75), $s['bar']['now']);
$s = ab_fight('medium', ['ab' => ['wary2']]); $s['bond'] = 0; $s['cm'] = min(1.0, $s['cm'] + 0.1); $b0 = 10 * $s['cm']; ab_place($s, 'me', ab_tile($s, 'p', 'charm', 10, 'body', 'knack'), 1, 1);
chk('Wary: Bond\'s higher Charm factor cannot undo it (applied on top)', $near($s['bar']['now'], $b0 * 0.75), [$s['bar']['now'], $b0]);
$s = ab_fight('medium', ['ab' => ['wary2']]); $fh = $s['fh']['now']; ab_place($s, 'me', ab_tile($s, 'p', 'hurt', 10, 'body', 'knack'), 1, 1);
chk('Wary: Hurt is not touched', $near($s['fh']['now'] - $fh, 10.0 * $s['hm']), $s['fh']['now']);
$s = ab_fight('boss', ['ab' => ['wary1']]); $b = ab_fight('boss'); ab_place($s, 'me', ab_tile($s, 'p', 'charm', 10, 'body', 'knack'), 1, 1); ab_place($b, 'me', ab_tile($b, 'p', 'charm', 10, 'body', 'knack'), 1, 1);
chk('Wary: on a boss it stacks with the boss\'s own cut Charm', $b['bar']['now'] > 0 && $near($s['bar']['now'], $b['bar']['now'] * 0.85), [$s['bar']['now'], $b['bar']['now']]);

echo "== 6. Tough hide\n";
$two = function (array $ab) {
    $s = ab_fight('medium', ['ab' => $ab]); ab_put($s, 'me', ab_tile($s, 'p1', 'hurt', 10, 'body', 'knack'), 1, 1); $fh = $s['fh']['now'];
    $ev = ab_place($s, 'me', ab_tile($s, 'p2', 'hurt', 10, 'body', 'knack'), 2, 1);
    return [$s, $ev, $s['fh']['now'] - $fh];
};
[$s0, $ev0, $d0] = $two([]);   // the same chain without the ability (its second piece also gets the combo bonus)
[$s, $ev, $d] = $two(['toughhide1']);
chk('Tough hide I: the first Hurt that fires counts 2 less (10 -> 8), the second as it was', ($ev[0]['v'] ?? 0) === 8 && ($ev0[0]['v'] ?? 0) === 10 && $near($d0 - $d, 2.0 * $s['hm']), [$ev[0]['v'] ?? null, $d0, $d]);
[$s, $ev, $d] = $two(['toughhide2']);
chk('Tough hide II: 3 less', $near($d0 - $d, 3.0 * $s['hm']), [$d0, $d]);
chk('Tough hide: the flag is set for the turn and reset when your next turn starts', $s['me']['tough'] === 1 && (function () use ($s) { pfb_begin($s, 'me'); return $s['me']['tough'] === 0; })());
$s = ab_fight('medium', ['ab' => ['toughhide2']]); $ev = ab_place($s, 'me', ab_tile($s, 'p', 'hurt', 2, 'body', 'knack'), 1, 1);
chk('Tough hide: never below 1', $ev[0]['v'] === 1, $ev[0]['v']);
$s = ab_fight('medium', ['ab' => ['toughhide2']]); ab_put($s, 'me', ab_tile($s, 'p1', 'hurt', 10, 'body', 'knack'), 1, 1); $fh = $s['fh']['now'];
$ev = ab_place($s, 'foe', ab_tile($s, 'f1', 'hurt', 3), 2, 1);
chk('Tough hide: your Hurt fired in the CREATURE\'s chain is not cut', $near($s['fh']['now'] - $fh, 10.0 * $s['hm']) && empty($s['me']['tough']), $s['fh']['now'] - $fh);
$s = ab_fight('medium', ['ab' => ['toughhide2']]); $fh = $s['fh']['now']; ab_place($s, 'me', ab_tile($s, 'p', 'hurt', 10, 'body', 'knack', 'poison'), 1, 1); $s['foe']['poison'] = 2; $fh2 = $s['fh']['now']; $s['foe']['poison_v'] = 5; $s['foe']['hand'] = []; pfb_foe_turn($s, 0);
chk('Tough hide: a poison tick is not cut', $near($s['fh']['now'] - $fh2, 5.0 * $s['hm']), $s['fh']['now'] - $fh2);

echo "== 7. Ambush\n";
$s = ab_fight('medium', ['ab' => ['ambush1']]);
chk('Ambush: armed at the start (not yet used)', $s['foe']['amb'] === 1);
$ev = ab_place($s, 'foe', ab_tile($s, 'f:h', 'hurt', 10), 1, 1);
chk('Ambush: a creature piece that fires in YOUR turn (before its first turn) is not boosted', $ev[0]['v'] === 10 && $s['foe']['amb'] === 1, $ev[0]['v']);
$s = ab_fight('medium', ['ab' => ['ambush1']]); $ev = ab_turn($s, [ab_tile($s, 'f:h', 'hurt', 10)], 1, 1); $h = $hurtOf($ev);
chk('Ambush I: its first Hurt of its first turn counts x1.4 (14)', $h && $h[0]['v'] === 14 && !empty($h[0]['amb']), $h);
chk('Ambush: used up after that turn', $s['foe']['amb'] === 0);
$ev = ab_turn($s, [ab_tile($s, 'f:h2', 'hurt', 10)], 2, 2); $h = $hurtOf($ev);
chk('Ambush: its second turn is plain', $h && $h[0]['v'] === 10, $h);
$s = ab_fight('medium', ['ab' => ['ambush1']]); $s['me']['block'] = 14; $hp = $s['me']['hp']; ab_turn($s, [ab_tile($s, 'f:h', 'hurt', 10)], 1, 1);
chk('Ambush I: a guard that holds still works (14 into 14 guard: nothing lands)', $s['me']['hp'] === $hp, $s['me']['hp']);
$s = ab_fight('medium', ['ab' => ['ambush2']]); $s['me']['block'] = 30; $hp = $s['me']['hp']; $ev = ab_turn($s, [ab_tile($s, 'f:h', 'hurt', 10)], 1, 1); $h = $hurtOf($ev);
chk('Ambush II: x1.7 (17) and it ignores your guard', $h && $h[0]['v'] === 17 && $s['me']['hp'] === $hp - 17 && $s['me']['block'] === 30, [$h[0]['v'] ?? null, $s['me']['hp'] - $hp]);
$s = ab_fight('medium', ['ab' => ['ambush2']]); $s['me']['evade'] = 1; $hp = $s['me']['hp']; ab_turn($s, [ab_tile($s, 'f:h', 'hurt', 10)], 1, 1);
chk('Ambush: Evade makes it miss (and the Ambush is used up)', $s['me']['hp'] === $hp && $s['foe']['amb'] === 0, $s['me']['hp']);
$s = ab_fight('medium', ['ab' => ['ambush1']]); $s['foe']['hand'] = [$t = ab_tile($s, 'f:h', 'hurt', 10)]; $s['foe']['plan'] = ['k' => 'f:h', 'n' => 'F:h', 't' => 'hurt', 'v' => 10, 'tag' => '', 'x' => 1, 'y' => 1];
$tot = pfb_aim_total($s); $b = ab_fight('medium'); $b['foe']['hand'] = [ab_tile($b, 'f:h', 'hurt', 10)]; $b['foe']['plan'] = $s['foe']['plan']; $tb = pfb_aim_total($b);
chk('Ambush: the aim total shows the boosted number (14 against 10)', $tot['hp'] === 14 && $tb['hp'] === 10, [$tot['hp'] ?? null, $tb['hp'] ?? null]);
$s = ab_fight('medium', ['ab' => ['ambush1']]); $ev = ab_turn($s, [ab_tile($s, 'f:g', 'guard', 4), ab_tile($s, 'f:h', 'hurt', 10), ab_tile($s, 'f:i', 'hurt', 10)], 1, 1); $s['foe']['again'] = 0;
chk('Ambush: only its FIRST Hurt piece (a guard first does not use it)', ($h = $hurtOf(ab_turn($s, [ab_tile($s, 'f:h', 'hurt', 10)], 2, 2))) && $h[0]['v'] === 10, $h);

echo "== 7a. Creature healing on the yield bar (2.7.06)\n";
$s = ab_fight('medium'); $s['fh']['now'] = 3.0; $s['bar']['now'] = 5.0; $s['bar']['charm'] = 5.0; $tot0 = $s['fh']['now'] + $s['bar']['now'];
$ev = ab_place($s, 'foe', ab_tile($s, 'f:hl', 'heal', 6), 1, 1); $he = array_values(array_filter($ev, fn($e) => ($e['t'] ?? '') === 'heal'));
chk('a creature Heal of 6 takes back 3 damage first, then 3 charm: the yield bar loses 6 in all', abs(($s['fh']['now'] + $s['bar']['now']) - ($tot0 - 6)) < 1e-9 && abs($s['fh']['now']) < 1e-9 && abs($s['bar']['now'] - 2.0) < 1e-9 && abs($s['bar']['charm'] - 2.0) < 1e-9, [$s['fh']['now'], $s['bar']['now'], $s['bar']['charm']]);
chk('the event says how much it really took back (healed 6)', $he && abs(($he[0]['healed'] ?? -1) - 6.0) < 1e-9, $he[0] ?? null);
$s = ab_fight('medium'); $s['fh']['now'] = 1.0; $s['bar']['now'] = 2.0; $s['bar']['charm'] = 2.0;
$ev = ab_place($s, 'foe', ab_tile($s, 'f:hl', 'heal', 20), 1, 1); $he = array_values(array_filter($ev, fn($e) => ($e['t'] ?? '') === 'heal'));
chk('a Heal bigger than the bar holds takes back only what is there (3) and leaves nothing negative', $he && abs(($he[0]['healed'] ?? -1) - 3.0) < 1e-9 && $s['fh']['now'] >= 0 && $s['bar']['now'] >= 0 && $s['bar']['charm'] >= 0, [$he[0]['healed'] ?? null, $s['fh']['now'], $s['bar']['now']]);
chk('its line says the yield bar, not "+N health"', $he && str_contains(pfight_line($he[0], 'Owl'), 'yield bar back 3'), $he ? pfight_line($he[0], 'Owl') : null);
echo "== 7b. Barge planning (2.7.06)\n";
$s = ab_fight('medium', [], ['tags' => 1]); $s['foe']['block'] = 8; $a0 = $s; $a1 = $s; $a1['foe']['bashnext'] = 1; $u = 0.05 * $s['me']['max'];
$d = pfb_score($s, $a1, 'foe') - pfb_score($s, $a0, 'foe');
chk('Barge planning: a lent guard of 8 is worth that guard (about 8 health), not a flat 1 unit (' . round($u, 2) . ')', $d > 0.9 * 8 && $d > 2 * $u, [round($d, 2), $u]);
$a1['foe']['block'] = 0; $a0['foe']['block'] = 0; $d0 = pfb_score($s, $a1, 'foe') - pfb_score($s, $a0, 'foe');
chk('Barge with no guard standing: still the flat unit (never worth less than before)', abs($d0 - $u) < 1e-6, [round($d0, 3), $u]);

echo "== 8. Stagger\n";
$s = ab_fight('medium', ['ab' => ['stagger1']]); $max = $s['me']['max']; $big = (int)ceil(0.2 * $max);
$ev = ab_place($s, 'foe', ab_tile($s, 'f:h', 'hurt', $big), 1, 1);
chk('Stagger I: a hit of 20% of your max HP leaves you one piece short next round (and a notice)', $s['me']['slowdraw'] === 1 && $notes($ev, 'stagger') && !empty($ev[0]['staggered']), [$big, $s['me']['slowdraw']]);
$s = ab_fight('medium', ['ab' => ['stagger1']]); ab_place($s, 'foe', ab_tile($s, 'f:h', 'hurt', $big - 1), 1, 1);
chk('Stagger I: just under the threshold does nothing', empty($s['me']['slowdraw']), $s['me']['slowdraw']);
$s = ab_fight('medium', ['ab' => ['stagger1']]); $s['me']['block'] = 5; ab_place($s, 'foe', ab_tile($s, 'f:h', 'hurt', $big + 4), 1, 1);
chk('Stagger: a hit blocked below the threshold does nothing (what lands counts)', empty($s['me']['slowdraw']), $s['me']['slowdraw']);
$s = ab_fight('medium', ['ab' => ['stagger2']]); ab_place($s, 'foe', ab_tile($s, 'f:h', 'hurt', (int)ceil(0.12 * $max)), 1, 1);
chk('Stagger II: 12%', $s['me']['slowdraw'] === 1, $s['me']['slowdraw']);
$s = ab_fight('medium', ['ab' => ['stagger1']]); $s['me']['evade'] = 1; ab_place($s, 'foe', ab_tile($s, 'f:h', 'hurt', $big + 5), 1, 1);
chk('Stagger: an Evaded hit does nothing', empty($s['me']['slowdraw']));
$s = ab_fight('medium', ['ab' => ['stagger1']]); ab_place($s, 'foe', ab_tile($s, 'f:h', 'hurt', $big), 1, 1); $hand0 = count($s['me']['hand']); pfb_end_round($s);
chk('Stagger: next round you draw one fewer (4 pieces, as after a Trip)', count($s['me']['hand']) === 4 && empty($s['me']['slowdraw']), count($s['me']['hand']));
$s = ab_fight('medium', ['ab' => ['stagger1']], ['tags' => 0, 'nothorn' => 1]); ab_place($s, 'foe', ab_tile($s, 'f:h', 'hurt', $big), 1, 1); pfb_end_round($s);
chk('Stagger (2.7.06): works in a learner fight (tags 0) too: 4 pieces next round, flag cleared, tripped shown', count($s['me']['hand']) === 4 && empty($s['me']['slowdraw']) && (int)$s['me']['tripped'] === 1, [count($s['me']['hand']), $s['me']['tripped'] ?? null]);
$s = ab_fight('medium'); ab_place($s, 'foe', ab_tile($s, 'f:h', 'hurt', $big + 5), 1, 1);
chk('(2.7.00 engine: no Stagger)', empty($s['me']['slowdraw']));

echo "== 9. Regrow\n";
$s = ab_fight('medium', ['ab' => ['regrow1']]); $s['foe']['hand'] = []; $y = (float)$s['fh']['max']; $s['fh']['now'] = 30.0; $ev = pfb_foe_turn($s, 0);
chk('Regrow I: turn 1 it recovers 2% of the Yield bar', $near($s['fh']['now'], 30.0 - 0.02 * $y) && $s['foe']['turns'] === 1, [$s['fh']['now'], $y]);
chk('Regrow: a notice says how much', ($n = $notes($ev, 'regrow')) && $n[0]['n'] === (string)round(0.02 * $y, 1), $ev);
for ($i = 0; $i < 4; $i++) pfb_foe_turn($s, 0);
chk('Regrow I: five turns in all: 10% of Y', $near($s['fh']['now'], 30.0 - 0.10 * $y) && $s['foe']['turns'] === 5, $s['fh']['now']);
$n0 = $s['fh']['now']; $ev = pfb_foe_turn($s, 0);
chk('Regrow: after its 5th turn it stops (no notice)', $near($s['fh']['now'], $n0) && !$notes($ev, 'regrow'), $s['fh']['now']);
$s = ab_fight('medium', ['ab' => ['regrow2']]); $s['foe']['hand'] = []; $s['fh']['now'] = 30.0; $s['foe']['slow'] = 1; pfb_foe_turn($s, 0);
chk('Regrow II: 3% a turn, and a skipped turn (Trip, Lull) still regrows', $near($s['fh']['now'], 30.0 - 0.03 * (float)$s['fh']['max']), $s['fh']['now']);
$s = ab_fight('medium', ['ab' => ['regrow1']]); $s['foe']['hand'] = []; $s['fh']['now'] = 0.0; $ev = pfb_foe_turn($s, 0);
chk('Regrow: nothing to heal, no notice', !$notes($ev, 'regrow') && $near($s['fh']['now'], 0.0));
$s = ab_fight('medium', ['ab' => ['regrow1']]); $s['foe']['hand'] = []; $s['fh']['now'] = 10.0; $s['bar']['now'] = 4.0; $s['bar']['charm'] = 4.0; $s['foe']['poison'] = 0; $y = (float)$s['fh']['max']; $s['fh']['now'] = 0.5; pfb_foe_turn($s, 0);
chk('Regrow: Hurt part first, then the Charm part', $near($s['fh']['now'], 0.0) && $near($s['bar']['now'], 4.0 - (0.02 * $y - 0.5)), [$s['fh']['now'], $s['bar']['now']]);
$s = ab_fight('medium'); $s['foe']['hand'] = []; $s['fh']['now'] = 30.0; pfb_foe_turn($s, 0);
chk('(2.7.00 engine: no Regrow)', $near($s['fh']['now'], 30.0));

echo "== 10. class-rule variants (E ids): the id replaces the class rule, its numbers come from the data\n";
$s = ab_fight('medium', ['class' => 'Bird', 'ab' => ['grudge-fury']]);
chk('an E id replaces the class rule (a Bird with grudge-fury plays Grudge)', pfb_kind($s) === 'beast' && pfb_kind(ab_fight('medium', ['class' => 'Bird'])) === 'bird');
$s = ab_fight('medium', ['class' => 'Beast', 'ab' => ['grudge-fury']]); $s['foe']['grudge'] = 1; $ev = ab_place($s, 'foe', ab_tile($s, 'f:h', 'hurt', 10), 1, 1);
chk('Fury grudge: +35% a block (10 -> 13.5 -> 14)', $ev[0]['v'] === 14, $ev[0]['v']);
$s = ab_fight('medium', ['class' => 'Beast', 'ab' => ['grudge-slow']]); $s['foe']['grudge'] = 4; $ev = ab_place($s, 'foe', ab_tile($s, 'f:h', 'hurt', 10), 1, 1);
chk('Slow grudge: +15% a block, up to 5 (4 stacks: 16)', $ev[0]['v'] === 16, $ev[0]['v']);
$s = ab_fight('medium', ['class' => 'Beast', 'ab' => ['grudge-fury'], 'v1' => 0], ['aimhit' => 0]);
for ($i = 0; $i < 4; $i++) { ab_put($s, 'me', ab_tile($s, "m$i", 'charm', 3, 'body', 'knack'), 1, $i); ab_turn($s, [ab_tile($s, "f$i", 'charm', 1)], 1, $i); }
chk('Fury grudge: at most 2 stacks (the plain rule goes to 3)', $s['foe']['grudge'] === 2, $s['foe']['grudge']);
$s = ab_fight('medium', ['class' => 'Beast', 'ab' => ['swarm-dense']]); for ($i = 0; $i < 4; $i++) ab_put($s, 'foe', ab_tile($s, "o$i", 'guard', 1), 3, $i); ab_put($s, 'foe', ab_tile($s, 'o4', 'guard', 1), 4, 4); ab_put($s, 'foe', ab_tile($s, 'o5', 'guard', 1), 4, 3);
$ev = ab_place($s, 'foe', ab_tile($s, 'f:h', 'hurt', 10), 2, 2); $b = ab_fight('medium', ['class' => 'Critter']); for ($i = 0; $i < 4; $i++) ab_put($b, 'foe', ab_tile($b, "o$i", 'guard', 1), 3, $i); ab_put($b, 'foe', ab_tile($b, 'o4', 'guard', 1), 4, 4); ab_put($b, 'foe', ab_tile($b, 'o5', 'guard', 1), 4, 3);
$eb = ab_place($b, 'foe', ab_tile($b, 'f:h', 'hurt', 10), 2, 2);
chk('Dense swarm: six other pieces: +3 (the plain Swarm stops at +2)', $ev[0]['v'] === 13 && $eb[0]['v'] === 12, [$ev[0]['v'], $eb[0]['v']]);
$s = ab_fight('medium', ['class' => 'Water', 'ab' => ['current-hard']]); ab_put($s, 'me', ab_tile($s, 'p1', 'charm', 3, 'body', 'knack'), 2, 1);
$ev = ab_turn($s, [ab_tile($s, 'f:w', 'charm', 2)], 1, 1); $c = $notes($ev, 'current');
chk('Strong current: the slide is 2 cells when the second is free', $c && $c[0]['moved']['x'] === 4 && $c[0]['moved']['fx'] === 2 && isset($s['cell']['4,1']) && !isset($s['cell']['2,1']), $c);
$s = ab_fight('medium', ['class' => 'Water', 'ab' => ['current-hard']]); ab_put($s, 'me', ab_tile($s, 'p1', 'charm', 3, 'body', 'knack'), 2, 1); ab_put($s, 'me', ab_tile($s, 'p2', 'charm', 3, 'body', 'knack'), 4, 1);
$ev = ab_turn($s, [ab_tile($s, 'f:w', 'charm', 2)], 1, 1); $c = $notes($ev, 'current');
chk('Strong current: the second cell taken: it slides only 1', $c && $c[0]['moved']['x'] === 3, $c);
$s = ab_fight('medium', ['class' => 'Water']); ab_put($s, 'me', ab_tile($s, 'p1', 'charm', 3, 'body', 'knack'), 2, 1); $ev = ab_turn($s, [ab_tile($s, 'f:w', 'charm', 2)], 1, 1);
chk('(plain Current slides 1)', ($c = $notes($ev, 'current')) && $c[0]['moved']['x'] === 3, $c);
$s = ab_fight('medium', ['class' => 'Plant', 'ab' => ['grows-twin']], ['env' => 1]);
$own = fn($s) => count(array_filter($s['pcs'], fn($q) => $q['by'] === 'env' && !empty($q['tile']['own'])));
ab_turn($s, [ab_tile($s, 'f1', 'charm', 2)], 1, 1); $o1 = $own($s); ab_turn($s, [ab_tile($s, 'f2', 'charm', 2)], 3, 3); $o2 = $own($s); ab_turn($s, [ab_tile($s, 'f3', 'charm', 2)], 4, 0); $o3 = $own($s);
chk('Twin growth: up to 2 of its own Brambles at a time (1, 2, then no more)', [$o1, $o2, $o3] === [1, 2, 2], [$o1, $o2, $o3]);
$s = ab_fight('medium', ['class' => 'Plant'], ['env' => 1]); ab_turn($s, [ab_tile($s, 'f1', 'charm', 2)], 1, 1); ab_turn($s, [ab_tile($s, 'f2', 'charm', 2)], 3, 3);
chk('(plain Grows keeps one)', $own($s) === 1, $own($s));
$s = ab_fight('medium', ['class' => 'Critter', 'ab' => ['venom-long']]); $pc = ab_tile($s, 'f:v', 'guard', 2); pfb_venom($s, ['by' => 'foe', 'x' => 2, 'y' => 2]);
chk('Long venom: the cell is venom 3 rounds (the plain trail 2)', ($s['ven']['2,2'] ?? 0) === 4, $s['ven']);
$ev = ab_place($s, 'me', ab_tile($s, 'p', 'charm', 3, 'body', 'knack'), 2, 2); $vn = $notes($ev, 'venom');
chk('Long venom: your piece there poisons you 1 a round for 3 rounds (the notice carries the numbers)', $s['me']['poison'] === 3 && $s['me']['poison_v'] === 1 && $vn && $vn[0]['pv'] === 1 && $vn[0]['pr'] === 3, [$s['me']['poison'], $s['me']['poison_v'], $vn]);
$s = ab_fight('medium', ['class' => 'Reptile / Amphibian']); pfb_venom($s, ['by' => 'foe', 'x' => 2, 'y' => 2]); $ev = ab_place($s, 'me', ab_tile($s, 'p', 'charm', 3, 'body', 'knack'), 2, 2);
chk('(plain Venom trail: 2 rounds, 2 a round, no extra fields on the notice)', $s['me']['poison'] === 2 && $s['me']['poison_v'] === 2 && !isset($notes($ev, 'venom')[0]['pv']));
$s = ab_fight('medium', ['class' => 'Critter', 'ab' => ['two-aims']]); $h1 = ab_tile($s, 'f:p', 'hurt', 4); $h2 = ab_tile($s, 'f:t', 'hurt', 5, 'mind'); $s['foe']['hand'] = [$h1, $h2]; pfb_intent($s);
chk('two-aims on a Critter: its aim carries a second cell', !empty($s['foe']['plan']['alt']), $s['foe']['plan'] ?? null);
$s = ab_fight('large', ['class' => 'Beast', 'ab' => ['two-turns']]);
chk('two-turns on a non-boss row: it is the Boss rule', pfb_kind($s) === 'boss');
$s = ab_fight('boss', ['class' => 'Bird', 'ab' => ['grudge']]);
chk('a boss row with a Grudge E id plays Grudge, not Two turns', pfb_kind($s) === 'beast');
$s = ab_fight('medium', ['class' => 'Bird', 'ab' => ['grudge']], ['kinds' => 0]);
chk('kinds 0 (class rules off): an E id does not switch a rule on', pfb_kind($s) === '' && ($s['foe']['kind'] ?? '') === '');

echo "== 11. the view: the card text\n";
$s = ab_fight('medium', ['ab' => ['drain1', 'D1']]); $v = pfb_view($s);
chk('the view lists the abilities (id, name, text)', ($v['abil'][0]['id'] ?? '') === 'drain1' && $v['abil'][0]['n'] === 'Drain' && $v['abil'][1]['n'] === 'Sharp' && $v['v1']['abil'] === 1, $v['abil'] ?? null);
chk('no abilities: no key in the view', !isset(pfb_view(ab_fight('medium'))['abil']));

echo "== 12. whole fights with every ability: no warning, they end, the bars stay sane, replay lines exist\n";
$ids = array_keys(array_filter(PFB_ABIL, fn($a) => $a[0] !== 'D')); $played = 0; $ended = 0;
foreach ($ids as $i => $id) foreach (['small', 'medium', 'boss'] as $size) {
    mt_srand(100 + $i);
    $cls = ['Critter', 'Bird', 'Beast', 'Water', 'Plant / Fungus', 'Reptile / Amphibian'][$i % 6];
    $s = pfb_new(ab_me(12), ab_foe($size, ['class' => $cls, 'level' => 12, 'ab' => [$id, 'D4']]), 11 + $i, ['v1' => true]);
    $t = 0; $okbars = true;
    while (!$s['over'] && $t++ < 45) {
        if (!empty($s['start'])) { pfb_start($s, 0, 'L'); continue; }
        $m = pfb_search($s, 'me');
        $r = $m ? pfb_play($s, [[$m[0], $m[1], $m[2]]], $s['turn']) : pfb_pass($s, $s['turn']);
        if ($r['err']) $r = pfb_pass($s, $s['turn']);
        foreach ($r['ev'] ?? [] as $e) { pfight_line($e, 'Thing'); pfight_chip_event($e, 0); if (isset($e['barnow']) && (!is_numeric($e['barnow']) || $e['barnow'] < -0.001)) $okbars = false; }
        $played++;
    }
    if ($s['over']) $ended++;
    if (!$okbars || $s['fh']['now'] < -0.001) chk("$id on a $size: bars sane", false, [$s['fh'], $s['bar']]);
}
chk('every effect and variant played ' . count($ids) . ' x 3 fights without a stall in the engine', $ended > 0.7 * count($ids) * 3 && $played > 0, [$ended, count($ids) * 3]);

echo "== 13. the loader of data/pf_creatures.txt (fixture)\n";
$GLOBALS['PF_CREATURES_FILE'] = '/nonexistent/pf_creatures.txt'; pfd_creature_rows(true); pfd_uniques(true); pfd_class_map(true);
$old = pfd_foe_pieces(['slug' => 'grass-snake', 'size' => 'large', 'dmg_die' => 8, 'dmg_bonus' => 3], 'NA');
chk('no file: nothing is added, old creatures unchanged, every region fits, no abilities on the row', pfd_creature_rows() === [] && pfd_creature_in_region('grass-snake', 'EE') && pfd_creature_overlay(['slug' => 'grass-snake']) === ['slug' => 'grass-snake'] && count($old) === 10, count($old));
$GLOBALS['PF_CREATURES_FILE'] = __DIR__ . '/pf_creatures_fixture.txt'; pfd_creature_rows(true); pfd_uniques(true); pfd_class_map(true);
$R = pfd_creature_rows();
chk('the fixture parses: 4 rows (the short line is skipped)', array_keys($R) === ['grass-snake', 'marsh-adder', 'aphid-swarm', 'fly-swarm'], array_keys($R));
chk('a base row: name = (a base), family itself, regions *, abilities from its column, petals, exp', $R['grass-snake']['base'] && $R['grass-snake']['family'] === 'grass-snake' && $R['grass-snake']['regions'] === ['*'] && $R['grass-snake']['ab'] === ['venom-trail'] && $R['grass-snake']['petals'] === [18, 33], $R['grass-snake']);
chk('an empty regions column is every region (back-compat)', $R['aphid-swarm']['regions'] === ['*'] && pfd_creature_in_region('aphid-swarm', 'OC'));
chk('a variant: family, regions list, cond, ab ids with overrides, ai id and overrides, exp', $R['marsh-adder']['family'] === 'grass-snake' && $R['marsh-adder']['regions'] === ['NA', 'CA'] && $R['marsh-adder']['cond'] === 'dp=night' && $R['marsh-adder']['ab'] === ['venom-long', 'D2'] && $R['marsh-adder']['ai'] === 'stall' && $R['marsh-adder']['aip'] === ['tilt' => 1.0] && $R['marsh-adder']['expm'] === 1.1, $R['marsh-adder']);
chk('a variant\'s ability override is clamped, an unknown id dropped', $R['fly-swarm']['ab'] === ['drain1'] && $R['fly-swarm']['abp'] === ['drain1' => ['pct' => 0.6]], $R['fly-swarm']['abp']);
chk('region test: a variant is in its regions only; an unlisted creature everywhere', pfd_creature_in_region('marsh-adder', 'NA') && pfd_creature_in_region('marsh-adder', 'CA') && !pfd_creature_in_region('marsh-adder', 'EE') && !pfd_creature_in_region('fly-swarm', 'NA') && pfd_creature_in_region('fly-swarm', 'MENA') && pfd_creature_in_region('red-fox', 'SEA') && pfd_creature_in_region('marsh-adder', ''));
chk('class: a variant has its base\'s class (Reptile for a snake, Critter for a swarm)', pfd_class(['slug' => 'marsh-adder']) === 'Reptile/Amphibian' && pfd_class(['slug' => 'fly-swarm']) === 'Critter', [pfd_class(['slug' => 'marsh-adder']), pfd_class(['slug' => 'fly-swarm'])]);
$U = pfd_uniques();
chk('uniques: a variant\'s 3 pieces and lean come from its deck column; a base row (deck =) keeps pf_creature_pieces.txt', count($U['marsh-adder']['P']) === 3 && $U['marsh-adder']['lean'] === 'mind' && $U['marsh-adder']['P'][0]['n'] === 'Fang Flick' && $U['marsh-adder']['P'][0]['tag'] === 'poison' && $U['marsh-adder']['P'][1]['life'] === 4 && count($U['grass-snake']['P']) === 3 && $U['grass-snake']['P'][0]['n'] !== 'Fang Flick', $U['marsh-adder'] ?? null);
$row = pfd_foe_row(['slug' => 'marsh-adder', 'name' => 'Marsh Adder', 'size' => 'large', 'level' => 14, 'dmg_die' => 8, 'dmg_bonus' => 3], 'NA');
$layers = array_count_values(array_column($row['deck'], 'layer'));
chk('a large variant deck: 4 base + 2 region + 1 size + 3 unique = 10, its own pieces last', count($row['deck']) === 10 && $layers === ['base' => 4, 'reg' => 2, 'rar' => 1, 'uni' => 3] && $row['deck'][9]['n'] === 'Hiss' && $row['class'] === 'Reptile/Amphibian', [$layers, $row['class']]);
chk('the foe row carries the data: ab, abp, ai, regions, petals, family', $row['ab'] === ['venom-long', 'D2'] && $row['ai'] === 'stall' && $row['regions'] === ['NA', 'CA'] && $row['petals'] === [18, 33] && $row['family'] === 'grass-snake' && $row['cond'] === 'dp=night');
$s = pfb_new(ab_me(14), $row + ['region' => 'NA'], 5, ['v1' => true]);
chk('and the fight takes them: Long venom plays (Reptile class rule with the variant\'s numbers)', pfb_kind($s) === 'reptile' && $s['foe']['ab'] === ['venom-long', 'D2'] && pfb_abp($s, 'vrnds', 2) === 3, $s['foe']);
$row = pfd_foe_row(['slug' => 'aphid-swarm', 'name' => 'Aphid Swarm', 'size' => 'small', 'level' => 1, 'dmg_die' => 4, 'dmg_bonus' => 0], 'NA');
chk('a base row\'s foe row: ability from the file, deck as before (4 + 1 + 3)', $row['ab'] === ['swarm'] && count($row['deck']) === 8, count($row['deck']));
$GLOBALS['PF_CREATURES_FILE'] = '/nonexistent/pf_creatures.txt'; pfd_creature_rows(true); pfd_uniques(true); pfd_class_map(true);
chk('(back to no file: the same deck for a base creature as before the loader)', count(pfd_foe_pieces(['slug' => 'aphid-swarm', 'size' => 'small', 'dmg_die' => 4, 'dmg_bonus' => 0], 'NA')) === 8);

echo "== 14. pick_creature: the region filter\n";
$_SERVER['SCRIPT_NAME'] = '/gnome.php';
if (!function_exists('setting')) { function setting(string $k, $d = '') { return $d; } }   // no DB: the road picker only reads the clock settings
require_once __DIR__ . '/../game/includes/adventure.php';
$st = &road_state(); $st['now'] = ['dp' => 'day', 'se' => 'summer', 'we' => 'clear']; unset($st);   // the road's clock, fixed (no DB, no settings)
$GLOBALS['PF_CREATURES_FILE'] = __DIR__ . '/pf_creatures_fixture.txt'; pfd_creature_rows(true);
$row = fn(string $slug, int $lv, string $size = 'small', string $land = 'grassland') => ['id' => $lv, 'slug' => $slug, 'name' => $slug, 'size' => $size, 'landscapes' => $land, 'level' => $lv, 'cond' => null];
$rows = [$row('aphid-swarm', 3), $row('fly-swarm', 3)];
$got = ['NA' => [], 'EE' => [], '' => []];
foreach (array_keys($got) as $rg) for ($i = 0; $i < 60; $i++) { $p = pick_creature('grassland', 4, false, false, 0, (string)$rg, $rows); $got[$rg][$p['slug']] = 1; }
chk('region NA: only the base (fly-swarm is EE, MENA)', array_keys($got['NA']) === ['aphid-swarm'], array_keys($got['NA']));
chk('region EE: both turn up', isset($got['EE']['aphid-swarm'], $got['EE']['fly-swarm']), array_keys($got['EE']));
chk('no region given: both (the old behaviour)', isset($got['']['aphid-swarm'], $got['']['fly-swarm']), array_keys($got['']));
$rows = [$row('fly-swarm', 3)]; $p = pick_creature('grassland', 4, false, false, 0, 'NA', $rows);
chk('the region leaves nothing in the band: it picks again without the region (never null)', $p !== null && $p['slug'] === 'fly-swarm', $p);
$rows = [$row('aphid-swarm', 4, 'boss'), $row('fly-swarm', 3)]; $nb = 0; $N = 8000; mt_srand(5);
for ($i = 0; $i < $N; $i++) { $p = pick_creature('grassland', 4, true, false, 0, 'NA', $rows); if ($p && $p['size'] === 'boss') $nb++; }
chk('2.7.06 boss chance is 6% once, not rolled again in the fallback pass (about 6%, not 11-12%): ' . round(100 * $nb / $N, 1) . '%', $nb / $N > 0.04 && $nb / $N < 0.085, $nb / $N);
$rows = [$row('aphid-swarm', 3), $row('fly-swarm', 3), $row('marsh-adder', 14, 'large', 'wetland')]; $p = pick_creature('wetland', 15, false, false, 0, 'NA', $rows);
chk('a variant of the right region and band is picked over a base out of band', $p !== null && $p['slug'] === 'marsh-adder', $p['slug'] ?? null);
$GLOBALS['PF_CREATURES_FILE'] = '/nonexistent/pf_creatures.txt'; pfd_creature_rows(true);

chk('no PHP warning or notice anywhere in this run', !$warn, array_slice($warn, 0, 3));
echo $bad ? "$bad FAILED\n" : "all ok\n";
exit($bad ? 1 : 0);
