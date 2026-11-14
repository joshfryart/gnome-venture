<?php
// After 2.6.96 (owner: "Enemy is getting random plays it seems ... it makes a piece show up and then the enemy plays it and gets a free activate"): seed a v1 fight (the rules a new fight has now) for tests/pfv1_enemy.js.
// php tests/pfv1_enemy_seed.php GAME CASE [SIZE]
//   CASE = spawn    your next move leads to the board putting out a piece for the creature at the end of the round (it has fewer than 2 out)
//          envfire  the creature's chain fires an environment piece next round, with its aim played as shown
//          quick    the creature's aim is a Quick piece: it plays a second piece this round
//          repick   your move takes the creature's aimed cell: it picks again
//          pass     the environment cannot place its first NEXT piece this round
// Deals fights with seeds 1.., plays the opening and up to 4 greedy turns on the engine, and stops at the first state where a move of yours gives the case.
// Prints one JSON line: {"i": hand index, "x", "y", "seed", "turns", "why"}. The page then plays that move (tests/pfv1_enemy.js).
$_SERVER['SCRIPT_NAME'] = '/adventure.php';
require $argv[1] . '/includes/bootstrap.php';
require_once APP_ROOT . '/includes/adventure.php';
require_once APP_ROOT . '/includes/pfight_game.php';
require_once APP_ROOT . '/includes/pfdeck.php';
$case = $argv[2] ?? 'spawn'; $size = $argv[3] ?? 'medium';
$u = q_one("SELECT * FROM users WHERE username = 'sprout'"); $uid = (int)$u['id'];
if (!active_expedition($uid)) { [$ok, $msg] = explore_start($u); }
$exp = active_expedition($uid);
$c = q_one('SELECT * FROM creatures WHERE size = ? ORDER BY level, id LIMIT 1', [$size]);
$exp['encounter'] = json_encode(['type' => 'creature', 'id' => (int)$c['id'], 'lv' => 0, 'sp' => 100, 'hpp' => 100, 'hp' => (int)$c['hp'], 'max' => (int)$c['hp'], 'bark' => 0, 'poison' => 0, 'used' => false]);
save_exp($exp); q('UPDATE expeditions SET hp = 60, max_hp = 60 WHERE id = ?', [$exp['id']]);
pfd_ensure(); pfd_row($uid);
$exp = active_expedition($uid); $enc = json_decode((string)$exp['encounter'], true); $c = encounter_creature($enc);
/** does this move (hand $i at $x,$y) give the case? returns a short reason or null */
$hit = function (array $s, int $i, int $x, int $y) use ($case): ?string {
    $w = $s; $r = pfb_play($w, [[$i, $x, $y]], $s['turn']); if ($r['err'] || $w['over']) return null;
    $foe = array_values(array_filter($r['ev'], fn($e) => ($e['ta'] ?? '') === 'foe'));
    $roots = array_values(array_filter($foe, fn($e) => isset($e['id']) && $e['by'] === 'foe' && !empty($e['root'])));
    $envf = array_values(array_filter($foe, fn($e) => ($e['env'] ?? '') === 'fire'));
    $quick = array_filter($foe, fn($e) => ($e['note'] ?? '') === 'quick');
    $pass = array_filter($w['envlog'] ?? [], fn($L) => $L['k'] === 'pass' && isset($L['kind']));
    if ($case === 'spawn' && !empty($w['spawn']) && !$w['reaim'] && !$quick) return 'the board puts out ' . $w['pcs'][$w['spawn']]['tile']['n'];
    if ($case === 'envfire' && $envf && !$w['reaim'] && !$quick && count($roots) === 1) return 'its chain fires ' . implode(', ', array_map(fn($e) => $e['n'], $envf));
    if ($case === 'quick' && $quick && count($roots) === 2 && !$w['reaim']) return 'quick: ' . $roots[0]['n'] . ' then ' . $roots[1]['n'];
    if ($case === 'repick' && $w['reaim'] && $roots && ($s['foe']['plan']['x'] ?? -1) === $x && ($s['foe']['plan']['y'] ?? -1) === $y) return 'you take its aimed cell: it plays ' . $roots[0]['n'];
    if ($case === 'pass' && $pass) return 'the environment keeps ' . reset($pass)['n'];
    return null;
};
$found = null;
for ($sd = 1; $sd <= 120 && !$found; $sd++) {
    $s = pfb_new(pfight_me($u, $exp, $enc), pfd_foe_row($c, pfd_exp_region($exp)), $sd, ['v1' => true, 'blank' => true, 'can_pluck' => false]);
    foreach (['L', 'R', 'T', 'B'] as $sdd) { $w = $s; if (pfb_start($w, 0, $sdd) === null) { $s = $w; break; } }
    if ($case === 'quick') { foreach (['hand', 'draw'] as $z) foreach ($s['foe'][$z] as $k => $t) $s['foe'][$z][$k]['tag'] = 'quick'; pfb_intent($s); }
    for ($t = 0; $t <= 4 && !$found && !$s['over']; $t++) {
        foreach ($s['me']['hand'] as $i => $tile) { foreach (pfb_cells($s, $tile, 'me') as [$x, $y]) if ($why = $hit($s, $i, $x, $y)) { $found = ['i' => $i, 'x' => $x, 'y' => $y, 'seed' => $sd, 'turns' => $t, 'why' => $why]; break 2; } }
        if ($found) break;
        $m = pfb_search($s, 'me'); $r = $m ? pfb_play($s, [[$m[0], $m[1], $m[2]]], $s['turn']) : pfb_pass($s, $s['turn']);
        if ($case === 'quick') { foreach (['hand', 'draw'] as $z) foreach ($s['foe'][$z] as $k => $tt) $s['foe'][$z][$k]['tag'] = 'quick'; pfb_intent($s); }
    }
}
if (!$found) { echo json_encode(['err' => 'no seed gives ' . $case]) . "\n"; exit(1); }
$s['nonce'] = $s['nonce'] ?? bin2hex(random_bytes(6));
$enc['pfgo'] = 1; $enc['pf'] = $s; unset($enc['replay'], $enc['prev'], $enc['last'], $enc['replay0']); $enc['hist'] = [];
$exp['encounter'] = json_encode($enc); save_exp($exp);
echo json_encode($found) . "\n";
