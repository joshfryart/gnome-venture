<?php
// 2.6.88 (Josh: "the final turn seems to replay the turn before it"): a turn that ends the fight runs no creature turn and no end of round, so what the creature put down (lastfoe -> fnew) and what left (gone) in the round BEFORE stayed in the state and the page replayed them again.
// php tests/pfv1_finalturn.php GAME   (a creature is in front of sprout, see pbox_v1_seed.php fight)
$_SERVER['SCRIPT_NAME'] = '/adventure.php';
require $argv[1] . '/includes/bootstrap.php';
require_once APP_ROOT . '/includes/adventure.php'; require_once APP_ROOT . '/includes/pfight_game.php'; require_once APP_ROOT . '/includes/pfdeck.php'; require_once APP_ROOT . '/includes/puzzle_pals.php';
$u = q_one("SELECT * FROM users WHERE username = 'sprout'"); $uid = (int)$u['id'];
$exp = active_expedition($uid); $enc = json_decode((string)$exp['encounter'], true); $c = encounter_creature($enc);
$enc['pfgo'] = 1; unset($enc['pf']); $exp['encounter'] = json_encode($enc); save_exp($exp);
$enc['pf'] = pfb_new(pfight_me($u, $exp, $enc), pfd_foe_row($c, pfd_exp_region($exp)), 7, ['v1' => true, 'blank' => true, 'can_pluck' => false]); $exp['encounter'] = json_encode($enc); save_exp($exp);
$turn = function () use (&$exp, &$enc, &$u) {
    $exp = active_expedition((int)$u['id']); $enc = json_decode((string)$exp['encounter'], true); $s = $enc['pf']; if ($s['over']) return false;
    $_POST = ['nonce' => $s['nonce'], 'turn' => $s['turn']];
    if (!empty($s['start'])) { $cx = intdiv(pfb_w($s), 2); $cy = intdiv(pfb_h($s), 2); $_POST['moves'] = '0,' . ($cx - 1) . ',' . $cy; pfight_do($u, $exp, 'pfb_play'); save_exp($exp); return true; }
    $best = null; foreach ($s['me']['hand'] as $i => $t) foreach (pfb_cell_preview($s, $i) as $key => $q) { $sc = ($q['dmg'] ?? 0) + ($q['ch'] ?? 0) + ($q['n'] ?? 0); if ($best === null || $sc > $best[0]) $best = [$sc, $i, $key]; }
    if ($best === null) { pfight_do($u, $exp, 'pfb_pass'); save_exp($exp); return true; }
    $_POST['moves'] = $best[1] . ',' . $best[2]; pfight_do($u, $exp, 'pfb_play'); save_exp($exp); return true;
};
for ($i = 0; $i < 3; $i++) $turn();
$exp = active_expedition($uid); $enc = json_decode((string)$exp['encounter'], true); $s = $enc['pf'];
$ck = function ($what, $got, $want) { $g = json_encode($got); $w = json_encode($want); if ($g === $w) echo "ok   $what\n"; else echo "FAIL $what (got $g, want $w)\n"; };
$ck('before the last turn the creature has put pieces down and one has left (the test is meaningful)', [count($s['lastfoe'] ?? []) > 0, count($s['gone'] ?? []) > 0], [true, true]);
// make the next turn a winning one: one charm piece away
$st = $s['me']['stats'] ?? ['level' => 8]; $st['level'] = 8;
$s['bar']['now'] = round($s['bar']['max'] * 0.97, 1); $s['me']['hand'] = [pfb_v1_tile(pf_make_tile('charm', $st), $s['v1'])]; $enc['pf'] = $s; $exp['encounter'] = json_encode($enc); save_exp($exp);
$turn();
$exp = active_expedition($uid); $enc = json_decode((string)$exp['encounter'], true); $s = $enc['pf'];
$v = pfb_view($s); $fnew = array_filter($v['pcs'], fn($p) => $p['fnew']);
$ck('the winning turn ends the fight', $s['over'], 'charmed');
$ck('the winning turn: no piece is marked as put down by the creature this turn', [$s['lastfoe'] ?? null, count($fnew)], [[], 0]);
$ck('the winning turn: nothing is shown as leaving from the round before', count($s['gone'] ?? []), 0);
$ck('the winning turn: the replay holds only your piece', array_map(fn($r) => $r['by'], $enc['replay'] ?? []), ['me']);
