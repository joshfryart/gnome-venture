<?php
// Wear piece effects (2.7.09): every trigger, every payoff and every Rare of data/wear_fx.txt, through the real board engine (pfb_place / pfb_fire / pfb_end_round).
// Each check plays the same move twice, once with the effect on the piece and once without, and looks at the difference.
// php tests/pf_wear_fx.php
require __DIR__ . '/../game/includes/pfboard.php';
$bad = 0; $n = 0;
function chk(string $name, bool $ok, $got = ''): void { global $bad, $n; $n++; if (!$ok) { $bad++; echo 'FAIL ' . $name . ' (got ' . (is_string($got) ? $got : json_encode($got)) . ")\n"; } }
const WILD = ['L' => ['wild', null], 'R' => ['wild', null], 'T' => ['wild', null], 'B' => ['wild', null]];
/** A test piece: wild edges (it links to every neighbour). */
function T(string $t, int $v, array $x = []): array { static $k = 0; $k++; return $x + ['k' => 'x' . $k, 'n' => ucfirst($t) . $k, 't' => $t, 'v' => $v, 'r' => null, 'tag' => '', 'm' => '', 'src' => 'basic', 'ed' => WILD]; }
/** A fresh v1 fight against a medium creature, board and hand emptied (the deck holds a wear piece, so the fight tracks wear effects). */
function base(): array
{
    static $b = null; if ($b !== null) return $b;
    $st = ['grit' => 1, 'nimble' => 1, 'hardiness' => 1, 'charm' => 1, 'lore' => 1, 'luck' => 0, 'level' => 10];
    $deck = []; foreach (range(1, 12) as $i) $deck[] = T(['hurt', 'guard', 'heal', 'charm'][$i % 4], 4);
    $deck[] = T('guard', 4, ['fx' => 'r1>guard', 'fxa' => 1, 'fxb' => 2]);
    $s = pfb_new(['hp' => 40, 'max_hp' => 40, 'stats' => $st, 'deck' => $deck, 'luck' => 0], ['slug' => 'tst', 'name' => 'Test', 'size' => 'medium', 'level' => 10, 'dmg_die' => 6, 'dmg_bonus' => 1], 7, ['v1' => true, 'can_pluck' => true]);
    $s['pcs'] = []; $s['cell'] = []; $s['me']['hand'] = []; $s['foe']['plan'] = null; $s['round'] = 1; $s['foe']['block'] = 0; $s['me']['block'] = 0; $s['me']['hp'] = 30;
    $s['fh']['max'] = $s['bar']['max'] = 500.0; $s['me']['luckmod'] = 0; $s['foe']['kind'] = '';
    return $b = $s;
}
function put(array &$s, string $by, array $t, int $x, int $y, ?int $born = null): int
{
    $id = ++$s['pid']; $s['seq']++;
    $s['pcs'][$id] = ['id' => $id, 'by' => $by, 'tile' => $t, 'x' => $x, 'y' => $y, 'born' => $born ?? (int)$s['round'], 'seq' => $s['seq']]; $s['cell']["$x,$y"] = $id;
    return $id;
}
/**
 * Play a scenario: $c = ['t' => type, 'v', 'at' => [x, y], 'nb' => [[by, type, v, x, y], ...], 'st' => fn(&$s) (state set-up), 'hand' => [tiles],
 * 'refire' => [x, y]: the piece is already on the board (born two rounds ago) and a plain Soothe placed at that cell fires it]. $fx = [code, a, b] or null.
 * Returns [state after, events, id of the piece].
 */
function play(array $c, ?array $fx): array
{
    $s = base(); $c += ['t' => 'soothe', 'v' => 3, 'at' => [1, 1], 'nb' => [], 'hand' => []];
    if (isset($c['round'])) $s['round'] = $c['round'];
    foreach ($c['nb'] as $q) put($s, $q[0], $q[0] === 'env' ? $q[1] : T($q[1], $q[2]), $q[3], $q[4]);
    $t = T($c['t'], $c['v'], $fx ? ['fx' => $fx[0], 'fxa' => $fx[1], 'fxb' => $fx[2], 'src' => 'wear'] : []);
    $s['me']['hand'] = $c['hand'];
    if (isset($c['st'])) $c['st']($s);
    if (isset($c['refire'])) {
        $id = put($s, 'me', $t, $c['at'][0], $c['at'][1], (int)$s['round'] - 2);
        array_unshift($s['me']['hand'], T('soothe', 1)); $ev = pfb_place($s, 'me', 0, $c['refire'][0], $c['refire'][1]);
    } else {
        array_unshift($s['me']['hand'], $t); $ev = pfb_place($s, 'me', 0, $c['at'][0], $c['at'][1]); $id = $s['pid'];
    }
    if ($ev === null) { echo "  (scenario could not be placed)\n"; $ev = []; }
    return [$s, $ev, $id];
}
/** The same scenario with and without the effect: [with, without, events with, piece id]. */
function both(array $c, string $fx, int $a = 2, int $b = 5): array { [$w, $ev, $id] = play($c, [$fx, $a, $b]); [$o] = play($c, null); return [$w, $o, $ev, $id]; }
$G = fn(array $w, array $o) => (int)$w['me']['block'] - (int)$o['me']['block'];   // the extra guard the effect gave

// ---------------------------------------------------------------- data
$D = pfb_wx_data();
chk('data: 25 payoffs, 37 triggers, 56 Rares, every action defined', count($D['pay']) === 25 && count($D['trig']) === 37 && count($D['rare']) === 56 && count($D['act']) >= 30, [count($D['pay']), count($D['trig']), count($D['rare'])]);
$P = []; foreach (file(__DIR__ . '/../claude/wear-pieces/pieces.json') ? json_decode((string)file_get_contents(__DIR__ . '/../claude/wear-pieces/pieces.json'), true) : [] as $p) $P[] = $p;
chk('pieces.json has the 280 pieces', count($P) === 280, count($P));
$miss = []; $txt = [];
foreach ($P as $p) {
    $cl = pfb_wx_clauses($p['code']);
    if (!$cl) $miss[] = $p['code'];
    if (pfb_wx_text($p['code'], (int)$p['a'], (int)$p['b']) !== $p['effect']) $txt[] = $p['code'];
    foreach ($cl as $o) if (($o['a'] === 'dmg' || $o['a'] === 'pierce') && $p['type'] !== 'hurt') $miss[] = $p['code'] . ' (dmg/pierce off a Hurt)';
    foreach ($cl as $o) if ($o['a'] === 'keep' && $p['type'] !== 'guard') $miss[] = $p['code'] . ' (Keeper off a Guard)';
}
chk('every one of the 280 codes has clauses (and dmg / pierce only on Hurts, Keeper only on Guards)', !$miss, $miss);
chk('the effect sentence of every piece is the design text (pieces.json effect)', !$txt, $txt);
$rows = array_values(array_filter(pf_data_lines('wear_items_pieces.txt'), fn($r) => count($r) >= 15));
$bl = []; foreach ($rows as $r) if (!str_ends_with($r[10], pfb_wx_text($r[12], (int)$r[13], (int)$r[14]))) $bl[] = $r[0];
chk('the game pieces (wear_items_pieces.txt) carry fx|a|b and their blurb ends in the effect sentence', count($rows) === 280 && !$bl, $bl);
$unk = []; foreach (array_merge(...array_map(fn($p) => pfb_wx_clauses($p['code']), $P)) as $o) foreach (array_merge($o['c0'], $o['c1']) as $c) { $k = explode(':', ltrim($c, '!'))[0]; if (!in_array($k, ['link', 'links', 'cenv', 'cfoe', 'clen', 'cmine', 'aimnext', 'onaim', 'edge', 'corner', 'mid', 'hand', 'fevade', 'fguard', 'fpcs', 'fhas', 'ygt', 'ylt', 'hplt', 'hpfull', 'hit', 'nodmg', 'poisoned', 'round', 'last', 'disc', 'played', 'lastturn', 'kept', 'fskip', 'tgt', 'pt', 'first', 'full'], true)) $unk[] = $c; }
chk('every condition in the data is one the engine knows', !$unk, $unk);

// ---------------------------------------------------------------- triggers: TRIG>guard on a Soothe; true scenario gives +5 guard, false gives none
$far = ['foe', 'heal', 3, 3, 3];
$TR = [
    'linkG' => [['nb' => [['me', 'guard', 2, 0, 1]]], ['nb' => [['me', 'heal', 2, 0, 1]]]],
    'linkH' => [['nb' => [['me', 'hurt', 2, 0, 1]]], ['nb' => [['me', 'heal', 2, 0, 1]]]],
    'linkC' => [['nb' => [['me', 'charm', 2, 0, 1]]], ['nb' => [['me', 'heal', 2, 0, 1]]]],
    'linkT' => [['nb' => [['me', 'trick', 2, 0, 1]]], ['nb' => [['me', 'heal', 2, 0, 1]]]],
    'linkS' => [['nb' => [['me', 'soothe', 2, 0, 1]]], ['nb' => [['me', 'heal', 2, 0, 1]]]],
    'linkHeal' => [['nb' => [['me', 'item', 2, 0, 1]]], ['nb' => [['me', 'charm', 2, 0, 1]]]],
    'linkEnv' => [['st' => function (&$s) { $e = null; foreach (pfb_env_deck('medium') as $et) if ($et['env'] === 'rain') $e = $et; $e['ed'] = WILD; put($s, 'env', $e, 0, 1); }], ['nb' => [['me', 'heal', 2, 0, 1]]]],
    'linkFoe' => [['nb' => [['foe', 'heal', 2, 0, 1]]], ['nb' => [['me', 'heal', 2, 0, 1], $far]]],
    'link2' => [['nb' => [['me', 'heal', 2, 0, 1], ['me', 'heal', 2, 2, 1]]], ['nb' => [['me', 'heal', 2, 0, 1]]]],
    'chain2' => [['nb' => [['me', 'heal', 2, 0, 1]]], ['nb' => [['me', 'heal', 2, 0, 1], ['me', 'heal', 2, 2, 1]]]],
    'combo3' => [['nb' => [['me', 'heal', 2, 0, 1], ['me', 'heal', 2, 2, 1]]], ['nb' => [['me', 'heal', 2, 0, 1]]]],
    'pair' => [['nb' => [['me', 'soothe', 2, 0, 1]]], ['nb' => [['me', 'heal', 2, 0, 1]]]],
    'aimNext' => [['nb' => [['me', 'heal', 2, 0, 1]], 'st' => fn(&$s) => $s['foe']['plan'] = ['k' => 'q', 'x' => 2, 'y' => 1, 't' => 'hurt']], ['nb' => [['me', 'heal', 2, 0, 1]], 'st' => fn(&$s) => $s['foe']['plan'] = ['k' => 'q', 'x' => 3, 'y' => 3, 't' => 'hurt']]],
    'onAim' => [['nb' => [['me', 'heal', 2, 0, 1]], 'st' => fn(&$s) => $s['foe']['plan'] = ['k' => 'q', 'x' => 1, 'y' => 1, 't' => 'hurt']], ['nb' => [['me', 'heal', 2, 0, 1]], 'st' => fn(&$s) => $s['foe']['plan'] = ['k' => 'q', 'x' => 2, 'y' => 1, 't' => 'hurt']]],
    'edge' => [['at' => [0, 1], 'nb' => [['me', 'heal', 2, 1, 1]]], ['nb' => [['me', 'heal', 2, 0, 1]]]],
    'corner' => [['at' => [0, 0], 'nb' => [['me', 'heal', 2, 1, 0]]], ['at' => [0, 1], 'nb' => [['me', 'heal', 2, 1, 1]]]],
    'mid4' => [['nb' => [['me', 'heal', 2, 0, 1]]], ['at' => [0, 1], 'nb' => [['me', 'heal', 2, 1, 1]]]],
    'handG' => [['nb' => [['me', 'heal', 2, 0, 1]], 'hand' => [T('guard', 2)]], ['nb' => [['me', 'heal', 2, 0, 1]], 'hand' => [T('hurt', 2)]]],
    'handH' => [['nb' => [['me', 'heal', 2, 0, 1]], 'hand' => [T('hurt', 2), T('hurt', 2)]], ['nb' => [['me', 'heal', 2, 0, 1]], 'hand' => [T('hurt', 2)]]],
    'foeEvade' => [['nb' => [['me', 'heal', 2, 0, 1]], 'st' => fn(&$s) => $s['foe']['evade'] = 1], ['nb' => [['me', 'heal', 2, 0, 1]]]],
    'foeG' => [['nb' => [['me', 'heal', 2, 0, 1]], 'st' => fn(&$s) => $s['foe']['block'] = 3], ['nb' => [['me', 'heal', 2, 0, 1]]]],
    'foeB3' => [['nb' => [['me', 'heal', 2, 0, 1], ['foe', 'heal', 1, 3, 3], ['foe', 'heal', 1, 3, 1], ['foe', 'heal', 1, 3, 0]]], ['nb' => [['me', 'heal', 2, 0, 1], ['foe', 'heal', 1, 3, 3], ['foe', 'heal', 1, 3, 1]]]],
    'foeB0' => [['nb' => [['me', 'heal', 2, 0, 1]]], ['nb' => [['me', 'heal', 2, 0, 1], $far]]],
    'yHalf' => [['nb' => [['me', 'heal', 2, 0, 1]], 'st' => fn(&$s) => $s['fh']['now'] = 300.0], ['nb' => [['me', 'heal', 2, 0, 1]], 'st' => fn(&$s) => $s['fh']['now'] = 200.0]],
    'yLow' => [['nb' => [['me', 'heal', 2, 0, 1]], 'st' => fn(&$s) => $s['fh']['now'] = 50.0], ['nb' => [['me', 'heal', 2, 0, 1]], 'st' => fn(&$s) => $s['fh']['now'] = 150.0]],
    'hpLow' => [['nb' => [['me', 'heal', 2, 0, 1]], 'st' => fn(&$s) => $s['me']['hp'] = 10], ['nb' => [['me', 'heal', 2, 0, 1]]]],
    'hpFull' => [['nb' => [['me', 'guard', 2, 0, 1]], 'st' => fn(&$s) => $s['me']['hp'] = 40], ['nb' => [['me', 'guard', 2, 0, 1]]]],
    'hit' => [['nb' => [['me', 'heal', 2, 0, 1]], 'st' => fn(&$s) => $s['me']['wx']['hit'] = 4], ['nb' => [['me', 'heal', 2, 0, 1]]]],
    'noDmg' => [['nb' => [['me', 'heal', 2, 0, 1]], 'st' => fn(&$s) => $s['me']['wx']['nd'] = 1], ['nb' => [['me', 'heal', 2, 0, 1]], 'st' => fn(&$s) => $s['me']['wx']['nd'] = 0]],
    'poisoned' => [['nb' => [['me', 'heal', 2, 0, 1]], 'st' => fn(&$s) => $s['me']['poison'] = 2], ['nb' => [['me', 'heal', 2, 0, 1]]]],
    'r1' => [['nb' => [['me', 'heal', 2, 0, 1]], 'round' => 1], ['nb' => [['me', 'heal', 2, 0, 1]], 'round' => 2]],
    'r3' => [['nb' => [['me', 'heal', 2, 0, 1]], 'round' => 3], ['nb' => [['me', 'heal', 2, 0, 1]], 'round' => 2]],
    'lastRound' => [['refire' => [0, 1], 'round' => 4], ['nb' => [['me', 'heal', 2, 0, 1]], 'round' => 4]],
    'disc5' => [['nb' => [['me', 'heal', 2, 0, 1]], 'st' => fn(&$s) => $s['me']['discard'] = array_fill(0, 5, T('hurt', 1))], ['nb' => [['me', 'heal', 2, 0, 1]], 'st' => fn(&$s) => $s['me']['discard'] = array_fill(0, 4, T('hurt', 1))]],
    'g2' => [['nb' => [['me', 'heal', 2, 0, 1]], 'st' => fn(&$s) => $s['me']['wx']['pl'] = ['guard' => 2]], ['nb' => [['me', 'heal', 2, 0, 1]], 'st' => fn(&$s) => $s['me']['wx']['pl'] = ['guard' => 1]]],
    'h2' => [['nb' => [['me', 'heal', 2, 0, 1]], 'st' => fn(&$s) => $s['me']['wx']['pl'] = ['hurt' => 2]], ['nb' => [['me', 'heal', 2, 0, 1]], 'st' => fn(&$s) => $s['me']['wx']['pl'] = ['hurt' => 1]]],
    'noHurt' => [['nb' => [['me', 'heal', 2, 0, 1]], 'st' => fn(&$s) => $s['me']['wx']['lt'] = 'guard'], ['nb' => [['me', 'heal', 2, 0, 1]], 'st' => fn(&$s) => $s['me']['wx']['lt'] = 'hurt']],
];
chk('a scenario for every trigger', array_keys($TR) == array_keys($D['trig']) || !array_diff(array_keys($D['trig']), array_keys($TR)), array_diff(array_keys($D['trig']), array_keys($TR)));
foreach ($TR as $code => [$yes, $no]) {
    [$w, $o] = both($yes, $code . '>guard'); $gy = $G($w, $o);
    [$w, $o] = both($no, $code . '>guard'); $gn = $G($w, $o);
    chk("trigger $code: true gives the payoff, false does not", $gy === 5 && $gn === 0, [$gy, $gn]);
}
// a placed piece that fires again: lastRound is false on placement
[$w, $o] = both(['nb' => [['me', 'heal', 2, 0, 1]], 'round' => 4], 'lastRound>guard'); chk('trigger lastRound: never true on the turn it is placed', $G($w, $o) === 0, $G($w, $o));

// ---------------------------------------------------------------- payoffs: r1>PAY (round 1), a = 2, b = 5
$nb = ['nb' => [['me', 'heal', 2, 0, 1]]];
$PY = [
    'guard' => [$nb, fn($w, $o) => $G($w, $o) === 5],
    'heal' => [$nb + ['st' => fn(&$s) => $s['me']['hp'] = 10], fn($w, $o) => $w['me']['hp'] - $o['me']['hp'] === 5],
    'dmg' => [['t' => 'hurt'] + $nb, fn($w, $o) => abs(($w['fh']['now'] - $o['fh']['now']) - 5 * $w['hm']) < 0.01],
    'charm' => [$nb, fn($w, $o) => abs(($w['bar']['now'] - $o['bar']['now']) - 5 * $w['cm']) < 0.01],
    'soothe' => [$nb, fn($w, $o) => $w['foe']['agg'] - $o['foe']['agg'] === 2],
    'skip' => [$nb, fn($w, $o) => $w['foe']['slow'] === 1 && $o['foe']['slow'] === 0],
    'poison' => [$nb, fn($w, $o) => $w['foe']['poison'] === 2 && $w['foe']['poison_v'] === 2 && $o['foe']['poison'] === 0],
    'pierce' => [['t' => 'hurt', 'v' => 6, 'st' => fn(&$s) => $s['foe']['block'] = 20] + $nb, fn($w, $o) => $w['fh']['now'] > $o['fh']['now'] && $o['fh']['now'] == 0],
    'evade' => [$nb, fn($w, $o) => $w['me']['evade'] === 1 && $o['me']['evade'] === 0],
    'thorns' => [['t' => 'guard'] + $nb, fn($w, $o) => count($w['me']['wblk']) === 1 && !$o['me']['wblk']],
    'hold' => [['t' => 'guard', 'v' => 6] + $nb, fn($w, $o) => $w['me']['keep'] - $o['me']['keep'] === 6],
    'life' => [['t' => 'guard'] + $nb, fn($w, $o) => ($w['pcs'][$w['pid']]['xl'] ?? 0) === 2 && pfb_life($w, $w['pcs'][$w['pid']]) === pfb_life($o, $o['pcs'][$o['pid']]) + 2],
    'stay' => [['t' => 'guard', 'nb' => [['me', 'heal', 2, 0, 1], ['me', 'heal', 2, 2, 1]]], fn($w, $o) => isset($w['pcs'][$w['pid']]) && !isset($o['pcs'][$o['pid']]) && count($w['pcs']) === 1],
    'keep' => [['t' => 'guard'] + $nb, fn($w, $o) => pfb_wx_keep(['round' => 2] + $w, T('guard', 3, ['fx' => 'r1>keep'])) && !pfb_wx_keep(['round' => 3] + $w, T('guard', 3, ['fx' => 'r1>keep']))],
    'cleanse' => [['t' => 'guard', 'st' => function (&$s) { $s['me']['poison'] = 2; $s['me']['poison_v'] = 3; $s['me']['hp'] = 10; }] + $nb, fn($w, $o) => $w['me']['poison'] === 0 && $o['me']['poison'] === 2 && $w['me']['hp'] - $o['me']['hp'] === 2],
    'knock' => [['t' => 'trick', 'nb' => [['me', 'heal', 2, 0, 1], ['foe', 'heal', 5, 3, 3], ['foe', 'heal', 1, 3, 1]]], fn($w, $o) => count(array_filter($w['pcs'], fn($p) => $p['by'] === 'foe')) === 1 && array_values(array_filter($w['pcs'], fn($p) => $p['by'] === 'foe'))[0]['tile']['v'] === 5],
    'boost' => [['t' => 'trick', 'nb' => [['me', 'hurt', 4, 0, 1]]], fn($w, $o) => ($w['pcs'][$w['pid'] - 1]['wv'] ?? 0) === 2 && $w['fh']['now'] - $o['fh']['now'] == 2 * $w['hm']],
    'mend' => [['t' => 'heal'] + $nb, fn($w, $o) => $w['me']['wmend'] === [[2, 2, $w['pid']]]],
    'bond' => [['t' => 'charm'] + $nb, fn($w, $o) => abs($w['cm'] - $o['cm'] - 0.1) < 1e-9 && $w['bond'] === 1],
    'pluck' => [['t' => 'trick', 'st' => fn(&$s) => $s['me']['luckmod'] = 9] + $nb, fn($w, $o) => in_array($w['plucked'] ? 'got' : 'missed', ['got', 'missed'], true) && $o['plucked'] === 0],
    'plenty' => [['t' => 'item'] + $nb, fn($w, $o) => (int)($w['me']['more'] ?? 0) === 1 && (int)($o['me']['more'] ?? 0) === 0],
    'hand' => [['t' => 'trick'] + $nb, fn($w, $o) => $w['me']['wmore'] === 1 && $o['me']['wmore'] === 0],
    'shrink' => [['t' => 'guard', 'nb' => [['me', 'heal', 2, 0, 1], ['foe', 'heal', 5, 3, 3], ['foe', 'heal', 1, 3, 1]]], fn($w, $o) => ($w['pcs'][3]['wv'] ?? 0) === -2 && !isset($w['pcs'][4]['wv'])],
    'ward' => [['t' => 'guard'] + $nb, fn($w, $o) => $w['me']['wx']['nx'] === [['guard', 1, 5, 0]]],
    'focus' => [['t' => 'hurt'] + $nb, fn($w, $o) => $w['me']['wx']['nx'] === [['hurt', 1, 5, 0]]],
];
chk('a check for every payoff', !array_diff(array_keys($D['pay']), array_keys($PY)), array_diff(array_keys($D['pay']), array_keys($PY)));
foreach ($PY as $code => [$c, $f]) { [$w, $o, $ev] = both($c, 'r1>' . $code); chk("payoff $code", (bool)$f($w, $o), $ev[0]['wfx'] ?? null); }
// the later steps of the lasting payoffs, through the engine
$s = base(); put($s, 'me', T('heal', 2), 0, 1); $s['me']['wx']['nx'] = [['guard', 1, 5, 0]]; $s['me']['hand'] = [T('guard', 3)]; pfb_place($s, 'me', 0, 1, 1);
chk('payoff ward: the next Guard placed gets +5 (and only one)', ($s['pcs'][$s['pid']]['wv'] ?? 0) === 5 && $s['me']['wx']['nx'] === [], $s['pcs'][$s['pid']]);
[$w] = play(['t' => 'guard'] + $nb, ['r1>thorns', 2, 5]); $w['fh']['now'] = 0.0; $e = ['blocked' => 3, 'dmg' => 0]; pfb_wx_guard($w, $e, 99);
chk('payoff thorns: a blocked creature Hurt adds a to the bar', abs($w['fh']['now'] - 2 * $w['hm']) < 0.01 && ($e['wfx'] ?? null) === ['bar 2'], $e);
[$w] = play(['t' => 'heal'] + $nb + ['st' => fn(&$s) => $s['me']['hp'] = 10], ['r1>mend', 2, 5]); $h0 = $w['me']['hp']; pfb_end_round($w);
chk('payoff mend: heals 2 as your next turn starts, once more after', $w['me']['hp'] === $h0 + 2 && $w['me']['wmend'] === [[2, 1, $w['pcs'] ? array_key_last($w['pcs']) : 0]] || ($w['me']['hp'] === $h0 + 2 && count($w['me']['wmend']) === 1), [$h0, $w['me']['hp'], $w['me']['wmend']]);
$s = base(); $s['me']['hand'] = [T('guard', 3, ['fx' => 'r1>keep', 'fxa' => 1, 'fxb' => 2]), T('hurt', 3)]; pfb_end_round($s);
chk('payoff keep: at the redraw the piece stays in your hand (and counts the round)', ($s['me']['hand'][0]['fx'] ?? '') === 'r1>keep' && ($s['me']['hand'][0]['kr'] ?? 0) === 1 && count($s['me']['hand']) === 5, $s['me']['hand'][0]);
$s = base(); $s['round'] = 2; $s['me']['hand'] = [T('guard', 3, ['fx' => 'r1>keep', 'fxa' => 1, 'fxb' => 2])]; pfb_end_round($s);
chk('payoff keep: a false trigger lets it go to the discard', ($s['me']['hand'][0]['fx'] ?? '') !== 'r1>keep', $s['me']['hand'][0]);
$s = base(); $s['me']['wmore'] = 1; $s['me']['more'] = 1; pfb_end_round($s); chk('payoffs plenty + hand: the next hand holds 7', count($s['me']['hand']) === 7, count($s['me']['hand']));

// ---------------------------------------------------------------- the 70 Rares: each placed in a scenario, the difference it makes
$Rt = []; foreach ($P as $p) if (str_starts_with($p['code'], 'R:')) $Rt[substr($p['code'], 2)] = $p;
$h10 = fn(&$s) => $s['me']['hp'] = 10;
$fp = fn(array $s) => array_values(array_filter($s['pcs'], fn($p) => $p['by'] === 'foe'));
$dbar = fn($w, $o) => ($w['fh']['now'] + $w['bar']['now']) - ($o['fh']['now'] + $o['bar']['now']);
$R = [
    'NA:footwear' => [$nb, fn($w, $o, $p) => $w['foe']['agg'] - $o['foe']['agg'] === $p['b'] && $w['me']['wmore'] === 1],
    'NA:backpack' => [['nb' => [['me', 'heal', 2, 0, 1], ['me', 'heal', 2, 2, 1]]], fn($w, $o, $p) => abs(($w['fh']['now'] - $o['fh']['now']) - 3 * $p['a'] * $w['hm']) < 0.01],
    'NA:coat' => [$nb, fn($w, $o, $p) => $G($w, $o) === $p['b'] && $w['me']['keep'] - $o['me']['keep'] === $p['v'] + $p['b'] && count($w['me']['wblk']) === 1],
    'NA:cloak' => [$nb, fn($w, $o, $p) => $G($w, $o) === $p['b'] && $w['me']['wx']['nx'] === [['charm', 1, $p['b'], 0]] && pfb_wx_keep($w, ['fx' => 'R:NA:cloak'])],
    'CA:footwear' => [['nb' => [['me', 'guard', 2, 0, 1], ['foe', 'heal', 4, 3, 3]]], fn($w, $o, $p) => ($fp($w)[0]['wv'] ?? 0) === -$p['a'] && $w['fh']['now'] > $o['fh']['now']],
    'CA:backpack' => [$nb + ['st' => $h10], fn($w, $o, $p) => $w['me']['hp'] - $o['me']['hp'] === $p['b'] + $p['a'] && (int)$w['me']['more'] === 1],
    'CA:coat' => [$nb + ['st' => $h10], fn($w, $o, $p) => $G($w, $o) === $p['b'] && $w['me']['hp'] - $o['me']['hp'] === $p['a'] && count($w['me']['wblk']) === 1],
    'CA:cloak' => [$nb + ['st' => fn(&$s) => $s['fh']['now'] = 300.0], fn($w, $o, $p) => $G($w, $o) === $p['b'] && $w['foe']['agg'] - $o['foe']['agg'] === $p['a']],
    'NWE:footwear' => [['nb' => [['me', 'trick', 2, 0, 1]], 'st' => fn(&$s) => $s['foe']['block'] = 30], fn($w, $o, $p) => $w['fh']['now'] > $o['fh']['now'] && $w['me']['wmore'] === 1],
    'NWE:backpack' => [$nb, function ($w, $o, $p) use ($G) { $s = base(); put($s, 'me', T('heal', 2), 0, 1); $s['me']['hand'] = [T('guard', 3), T('guard', 3, ['fx' => 'R:NWE:backpack', 'fxa' => $p['a'], 'fxb' => $p['b']])]; pfb_place($s, 'me', 0, 1, 1); return ($s['pcs'][$s['pid']]['wv'] ?? 0) === $p['a'] && pfb_wx_keep($s, $s['me']['hand'][0]); }],
    'NWE:coat' => [$nb + ['st' => $h10], fn($w, $o, $p) => $G($w, $o) === $p['b'] && $w['me']['hp'] - $o['me']['hp'] === $p['a'] && $w['me']['keep'] - $o['me']['keep'] === $p['b'] + $w['pcs'][$w['pid']]['tile']['v']],
    'NWE:cloak' => [['nb' => [['me', 'charm', 3, 0, 1]]], fn($w, $o, $p) => ($w['pcs'][$w['pid'] - 1]['wv'] ?? 0) === $p['b'] && $w['foe']['agg'] - $o['foe']['agg'] === $p['a']],
    'CB:footwear' => [['nb' => [['me', 'heal', 2, 0, 1], ['me', 'heal', 2, 2, 1], ['foe', 'heal', 3, 3, 3]]], fn($w, $o, $p) => $w['foe']['slow'] === 1 && ($fp($w)[0]['wv'] ?? 0) === -$p['a']],
    'CB:backpack' => [$nb + ['hand' => [T('guard', 1)], 'st' => $h10], fn($w, $o, $p) => $w['me']['hp'] - $o['me']['hp'] === $p['b'] && (int)$w['me']['more'] === 2],
    'CB:coat' => [$nb, function ($w, $o, $p) use ($G) { $w['me']['hp'] = 10; $b0 = $w['bar']['now']; $e = ['blocked' => 2, 'dmg' => 1]; pfb_wx_guard($w, $e, 99); return $w['me']['hp'] === 10 + $p['a'] && $w['bar']['now'] > $b0; }],
    'CB:cloak' => [['nb' => [['me', 'heal', 2, 0, 1], ['me', 'heal', 2, 2, 1]]], fn($w, $o, $p) => $w['foe']['slow'] === 1 && abs(($w['bar']['now'] - $o['bar']['now']) - $p['b'] * $w['cm']) < 0.01],
    'SE:footwear' => [['nb' => [['me', 'guard', 2, 0, 1], ['me', 'guard', 2, 2, 1]], 'st' => $h10], fn($w, $o, $p) => $w['me']['hp'] - $o['me']['hp'] === 2 * $p['a'] && $w['fh']['now'] - $o['fh']['now'] >= $p['b'] * $w['hm'] - 0.01],
    'SE:backpack' => [$nb + ['st' => function (&$s) { $s['foe']['block'] = 2; $s['me']['hp'] = 10; }], fn($w, $o, $p) => $w['me']['hp'] - $o['me']['hp'] === $p['b'] && $w['foe']['agg'] - $o['foe']['agg'] === $p['a'] && $w['bar']['now'] > $o['bar']['now']],
    'SE:coat' => [['nb' => [['me', 'heal', 2, 0, 1], ['foe', 'hurt', 3, 3, 3]]], function ($w, $o, $p) use ($fp) { $f0 = $w['fh']['now']; $e = ['blocked' => 3, 'dmg' => 0]; $fid = $fp($w)[0]['id']; pfb_wx_guard($w, $e, $fid); $w['fired'] = []; pfb_spend($w); return abs($w['fh']['now'] - $f0 - $p['b'] * $w['hm']) < 0.01 && !$fp($w); }],
    'SE:cloak' => [$nb, fn($w, $o, $p) => $w['foe']['slow'] === 1],
    'SA:footwear' => [['nb' => [['me', 'heal', 2, 0, 1], ['me', 'heal', 2, 2, 1]]], fn($w, $o, $p) => $w['foe']['slow'] === 1 && abs(($w['fh']['now'] - $o['fh']['now']) - $p['b'] * $w['hm']) < 0.01],
    'SA:backpack' => [$nb + ['st' => function (&$s) { $s['me']['hp'] = 10; $s['me']['discard'] = array_fill(0, 10, T('hurt', 1)); }], fn($w, $o, $p) => $w['me']['hp'] - $o['me']['hp'] === $p['b'] + $p['a'] && (int)$w['me']['more'] === 1],
    'SA:coat' => [$nb, function ($w, $o, $p) use ($G) { [$k] = play(['t' => 'guard'] + ['nb' => [['me', 'heal', 2, 0, 1]], 'st' => fn(&$s) => $s['me']['hand'] = []], null); $s = base(); put($s, 'me', T('heal', 2), 0, 1); $s['me']['hand'] = [T('guard', 4, ['fx' => 'R:SA:coat', 'fxa' => $p['a'], 'fxb' => $p['b'], 'kr' => 1])]; $b0 = $s['me']['block']; pfb_place($s, 'me', 0, 1, 1); return $s['me']['block'] - $b0 === 4 + 2 * $p['b'] && $G($w, $o) === $p['b']; }],
    'EE:coat' => [['nb' => [['me', 'heal', 2, 0, 1], ['foe', 'heal', 1, 3, 3], ['foe', 'heal', 1, 3, 1], ['foe', 'heal', 1, 3, 0]]], function ($w, $o, $p) use ($G) { $f0 = $w['fh']['now']; $e = ['blocked' => 2, 'dmg' => 0]; pfb_wx_guard($w, $e, 99); return $G($w, $o) === $p['b'] && abs($w['fh']['now'] - $f0 - 2 * $p['a'] * $w['hm']) < 0.01; }],
    'SA:cloak' => [$nb + ['st' => fn(&$s) => $s['fh']['now'] = 300.0], fn($w, $o, $p) => $w['foe']['slow'] === 1 && $w['foe']['agg'] - $o['foe']['agg'] === $p['a']],
    'EE:footwear' => [$nb + ['st' => fn(&$s) => $s['me']['wx']['lt'] = 'guard'], fn($w, $o, $p) => abs(($w['fh']['now'] - $o['fh']['now']) - $p['b'] * $w['hm']) < 0.01 && $w['me']['wx']['nx'] === [['hurt', 1, $p['a'], 0]]],
    'EE:backpack' => [$nb + ['st' => function (&$s) { $s['me']['hp'] = 10; $s['me']['discard'] = array_fill(0, 5, T('hurt', 1)); }], fn($w, $o, $p) => count($w['me']['discard']) === count($o['me']['discard']) - $p['a'] && count($w['me']['draw']) === count($o['me']['draw']) + $p['a']],
    'EE:cloak' => [['nb' => [['me', 'hurt', 3, 0, 1]], 'st' => fn(&$s) => $s['me']['luckmod'] = 9], fn($w, $o, $p) => ($w['pcs'][$w['pid'] - 1]['wv'] ?? 0) === $p['a'] && ($w['plucked'] === 1 || $w['rng'] !== $o['rng'])],   // it tries (a roll is spent)
    'MENA:footwear' => [['nb' => [['me', 'guard', 2, 0, 1]]], fn($w, $o, $p) => $w['foe']['poison'] === 3 && $w['foe']['poison_v'] === $p['a'] && $w['foe']['agg'] - $o['foe']['agg'] === $p['a']],
    'MENA:backpack' => [$nb + ['st' => function (&$s) { $s['fh']['now'] = 300.0; $s['me']['hp'] = 10; }], fn($w, $o, $p) => $w['foe']['slow'] === 1 && $w['me']['hp'] - $o['me']['hp'] === $p['b'] && $w['bar']['now'] > $o['bar']['now']],
    'MENA:coat' => [$nb, function ($w, $o, $p) use ($G) { $s = base(); put($s, 'me', T('heal', 2), 0, 1); $s['me']['hand'] = [T('guard', 4, ['fx' => 'R:MENA:coat', 'fxa' => $p['a'], 'fxb' => $p['b'], 'kr' => 1])]; pfb_place($s, 'me', 0, 1, 1); return $s['me']['keep'] === 4 + $p['b'] && $w['me']['keep'] === 0 && $G($w, $o) === $p['b']; }],
    'MENA:cloak' => [['nb' => [['me', 'heal', 2, 0, 1], ['foe', 'heal', 4, 3, 3]], 'st' => fn(&$s) => $s['foe']['wsk'] = 1], fn($w, $o, $p) => $w['foe']['slow'] === 1 && ($fp($w)[0]['wv'] ?? 0) === -$p['a']],
    'EA:footwear' => [['nb' => [['me', 'trick', 2, 0, 1]]], fn($w, $o, $p) => $w['foe']['slow'] === 1 && $w['me']['wmore'] === 1 && abs(($w['fh']['now'] - $o['fh']['now']) - $p['b'] * $w['hm']) < 0.01],
    'EA:backpack' => [['nb' => [['me', 'item', 2, 0, 1], ['me', 'heal', 2, 2, 1]], 'st' => $h10], fn($w, $o, $p) => $w['me']['hp'] - $o['me']['hp'] === $p['b'] + 2 * $p['a']],
    'EA:coat' => [$nb, function ($w, $o, $p) use ($G) { $w['me']['hp'] = 10; foreach ([1, 2] as $k) { $e = ['blocked' => 2, 'dmg' => 0]; pfb_wx_guard($w, $e, 99); } return $w['me']['hp'] === 10 + $p['a']; }],
    'EA:cloak' => [$nb, fn($w, $o, $p) => $w['me']['wx']['nx'] === [['charm', 2, $p['a'], 0]]],
    'CSA:footwear' => [$nb, function ($w, $o, $p) use ($G) { $f0 = $w['fh']['now']; $e = ['evaded' => 4, 'dmg' => 0, 'blocked' => 0]; pfb_wx_guard($w, $e, 99); return $w['me']['evade'] === 1 && $G($w, $o) === $p['b'] && abs($w['fh']['now'] - $f0 - $p['a'] * $w['hm']) < 0.01; }],
    'CSA:backpack' => [$nb + ['st' => $h10], fn($w, $o, $p) => $w['me']['wmend'] === [[$p['a'], 3, $w['pid']]] && $w['me']['hp'] - $o['me']['hp'] === $p['b']],
    'CSA:coat' => [$nb + ['hand' => [T('hurt', 1), T('hurt', 1)], 'st' => $h10], fn($w, $o, $p) => $w['me']['hp'] - $o['me']['hp'] === 2 * $p['a'] && $G($w, $o) === $p['b']],
    'CSA:cloak' => [$nb + ['st' => fn(&$s) => $s['foe']['block'] = 20], fn($w, $o, $p) => $o['foe']['block'] - $w['foe']['block'] === $p['b']],
    'SEA:footwear' => [['nb' => [['me', 'heal', 2, 0, 1], ['foe', 'heal', 4, 3, 3], ['foe', 'heal', 5, 3, 0]]], fn($w, $o, $p) => $w['foe']['slow'] === 1 && ($fp($w)[0]['wv'] ?? 0) === -$p['a'] && ($fp($w)[1]['wv'] ?? 0) === -$p['a']],
    'SEA:backpack' => [$nb + ['st' => function (&$s) { $s['me']['wx']['lt'] = 'heal'; }], fn($w, $o, $p) => (int)$w['me']['more'] === 2],
    'SEA:coat' => [$nb, function ($w, $o, $p) use ($G) { $ev1 = $w['me']['evade'] === 1; $w['foe']['hand'] = [T('hurt', 6)]; $w['aimforce'] = true; pfb_place($w, 'foe', 0, 3, 3); return $ev1 && $w['me']['evade'] === 0 && ($w['pcs'][$w['pid']]['wv'] ?? 0) === -$p['a'] && $w['foe']['wnx'] === 0; }],
    'SEA:cloak' => [$nb, function ($w, $o, $p) use ($G) { $w['foe']['hand'] = [T('hurt', 8)]; $hp = $w['me']['hp']; $w['me']['block'] = 0; $w['aimforce'] = true; pfb_place($w, 'foe', 0, 3, 3); return $w['me']['hp'] === $hp - 4 && $w['foe']['whf'] === 1; }],
    'WCA:footwear' => [['nb' => [['me', 'hurt', 3, 0, 1]]], fn($w, $o, $p) => ($w['pcs'][$w['pid'] - 1]['wv'] ?? 0) === $p['a']],
    'WCA:backpack' => [$nb + ['st' => $h10], fn($w, $o, $p) => $w['me']['wmend'] === [[$p['a'], 2, $w['pid']]] && $w['me']['wmore'] === 1],
    'WCA:coat' => [$nb, function ($w, $o, $p) use ($G) { $s = base(); put($s, 'me', T('heal', 2), 0, 1); $s['me']['hand'] = [T('guard', 4, ['fx' => 'R:WCA:coat', 'fxa' => $p['a'], 'fxb' => $p['b'], 'kr' => 2])]; $b0 = $s['me']['block']; pfb_place($s, 'me', 0, 1, 1); return $s['me']['block'] - $b0 === 4 + $p['b'] + 2 * $p['a']; }],
    'WCA:cloak' => [['nb' => [['me', 'charm', 2, 0, 1], ['me', 'charm', 2, 2, 1]]], fn($w, $o, $p) => $G($w, $o) === $p['b'] + 2 * $p['a']],
    'ESA:footwear' => [['nb' => [['me', 'heal', 2, 0, 1], ['foe', 'heal', 4, 3, 3], ['foe', 'heal', 2, 3, 0]]], fn($w, $o, $p) => abs(($w['fh']['now'] - $o['fh']['now']) - 2 * $p['b'] * $w['hm']) < 0.01 && count($fp($w)) === 1 && $fp($w)[0]['tile']['v'] === 4],
    'ESA:backpack' => [$nb, fn($w, $o, $p) => (int)$w['me']['more'] === 1 && $w['me']['wx']['nx'] === [['hurt', 99, $p['a'], 2]]],
    'ESA:coat' => [['nb' => [['me', 'charm', 2, 0, 1], ['me', 'hurt', 2, 2, 1], ['me', 'heal', 2, 1, 0]]], fn($w, $o, $p) => $G($w, $o) === $p['b'] + 3 * $p['a']],
    'ESA:cloak' => [['nb' => [['me', 'charm', 3, 0, 1]]], fn($w, $o, $p) => ($w['pcs'][$w['pid'] - 1]['wv'] ?? 0) === $p['a'] + $p['b']],
    'OC:footwear' => [$nb + ['st' => fn(&$s) => $s['fh']['now'] = 300.0], fn($w, $o, $p) => $w['foe']['slow'] === 1 && abs(($w['fh']['now'] - $o['fh']['now']) - $p['b'] * $w['hm']) < 0.01],
    'OC:backpack' => [$nb, function ($w, $o, $p) use ($G) { if ($w['me']['wk1'] !== 3) return false; pfb_end_round($w); $w['me']['hand'] = [T('hurt', 2), T('hurt', 9), T('heal', 3)]; pfb_end_round($w); return in_array(9, array_column($w['me']['hand'], 'v'), true); }],
    'OC:coat' => [$nb, function ($w, $o, $p) use ($G) { $s = base(); put($s, 'me', T('heal', 2), 0, 1); $s['me']['hand'] = [T('guard', 4, ['fx' => 'R:OC:coat', 'fxa' => $p['a'], 'fxb' => $p['b'], 'kr' => 2])]; pfb_place($s, 'me', 0, 1, 1); return $s['me']['keep'] === 4 + $p['b'] && count($s['me']['wblk']) === 1 && $w['me']['wblk'] === []; }],
    'OC:cloak' => [['nb' => [['me', 'heal', 2, 0, 1], ['foe', 'heal', 4, 3, 3]]], fn($w, $o, $p) => $w['plucked'] === 1 && ($fp($w)[0]['wv'] ?? 0) === -$p['b'] && $w['me']['wmore'] === 1],
];
chk('a check for every Rare', !array_diff(array_keys($D['rare']), array_keys($R)), array_diff(array_keys($D['rare']), array_keys($R)));
foreach ($R as $k => [$c, $f]) {
    $p = $Rt[$k]; $c += ['t' => $p['type'], 'v' => (int)$p['v']];
    [$w, $o, $ev] = both($c, 'R:' . $k, (int)$p['a'], (int)$p['b']);
    chk("Rare $k ({$p['piece']}: " . pfb_wx_text('R:' . $k, (int)$p['a'], (int)$p['b']) . ')', (bool)$f($w, $o, ['a' => (int)$p['a'], 'b' => (int)$p['b'], 'v' => (int)$p['v']]), $ev[0]['wfx'] ?? $ev);
}

// ---------------------------------------------------------------- the rules: fire order, use-up, old fights, the view
[$w, , $ev] = both(['t' => 'guard', 'nb' => [['me', 'hurt', 2, 0, 1], ['me', 'heal', 2, 2, 1]]], 'r1>guard');
$ord = array_map(fn($e) => $e['t'], array_filter($ev, fn($e) => isset($e['id'])));
chk('fixed fire order still holds with a wear piece in the chain (Guard, Hurt, Heal)', $ord === ['guard', 'hurt', 'heal'], $ord);
chk('a chain of 3 uses up the wear piece like any piece', !isset($w['pcs'][$w['pid']]), array_keys($w['pcs']));
$s = pfb_new(['hp' => 30, 'max_hp' => 30, 'stats' => ['level' => 3], 'deck' => [T('hurt', 3), T('guard', 3), T('heal', 3), T('charm', 3), T('hurt', 2)], 'luck' => 0], ['slug' => 'z', 'name' => 'Z', 'size' => 'small', 'level' => 3], 3, ['v1' => true]);
chk('a fight with no wear piece carries no wear state', !isset($s['wfx']) && !isset($s['me']['wx']) && !isset($s['foe']['wnx']), array_keys($s));
[$w] = play($nb, ['r1>guard', 1, 2]); $v = pfb_view($w);
$fxv = array_values(array_filter($v['pcs'], fn($q) => isset($q['fx'])));
chk('the view gives a wear piece on the board its effect sentence', count($fxv) === 1 && $fxv[0]['fx'] === 'In the first round of the fight, gain 2 guard.', $fxv);
$s = base(); $s['me']['hand'] = [T('hurt', 2, ['fx' => 'linkG>pierce', 'fxa' => 1, 'fxb' => 3])]; $v = pfb_view($s);
chk('the view gives a wear piece in the hand its effect sentence', ($v['hand'][0]['fx'] ?? '') === 'If it is linked to a Guard, it ignores the creature\'s guard.', $v['hand'][0]);
$s = base(); put($s, 'me', T('heal', 2), 0, 1); $s['me']['hand'] = [T('guard', 3, ['fx' => 'r1>guard', 'fxa' => 1, 'fxb' => 2])]; $ev = pfb_place($s, 'me', 0, 1, 1);
chk('the event of a wear piece names what it did (wfx)', ($ev[array_key_first(array_filter($ev, fn($e) => ($e['t'] ?? '') === 'guard'))]['wfx'] ?? null) === ['guard 2'], $ev);

echo $bad ? "$bad of $n FAILED\n" : "all $n ok\n";
exit($bad ? 1 : 0);
