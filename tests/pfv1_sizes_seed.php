<?php
// 2.7.55 board sizes: seed a v1 fight against one creature (by slug) for tests/pfv1_sizes.js. php tests/pfv1_sizes_seed.php GAME SLUG [aoe]
// Plays the opening and greedy turns on the engine; with `aoe` it stops at the first turn where the boss's AOE is marked (else after 1 turn). Prints {"w","h","aoe": cells, "seed"}.
$_SERVER['SCRIPT_NAME'] = '/adventure.php';
require $argv[1] . '/includes/bootstrap.php';
require_once APP_ROOT . '/includes/adventure.php';
require_once APP_ROOT . '/includes/pfight_game.php';
require_once APP_ROOT . '/includes/pfdeck.php';
$slug = $argv[2] ?? 'aardvark'; $wantAoe = ($argv[3] ?? '') === 'aoe';
$u = q_one("SELECT * FROM users WHERE username = 'sprout'"); $uid = (int)$u['id'];
if (!active_expedition($uid)) { [$ok, $msg] = explore_start($u); }
$exp = active_expedition($uid);
$c = q_one('SELECT * FROM creatures WHERE slug = ?', [$slug]); if (!$c) { echo json_encode(['err' => 'no creature ' . $slug]) . "\n"; exit(1); }
$exp['encounter'] = json_encode(['type' => 'creature', 'id' => (int)$c['id'], 'lv' => 0, 'sp' => 100, 'hpp' => 100, 'hp' => (int)$c['hp'], 'max' => (int)$c['hp'], 'bark' => 0, 'poison' => 0, 'used' => false]);
save_exp($exp); q('UPDATE expeditions SET hp = 200, max_hp = 200 WHERE id = ?', [$exp['id']]);
pfd_ensure(); pfd_row($uid);
$exp = active_expedition($uid); $enc = json_decode((string)$exp['encounter'], true); $c = encounter_creature($enc);
$found = null;
for ($sd = 1; $sd <= 40 && !$found; $sd++) {
    $s = pfb_new(pfight_me($u, $exp, $enc), pfd_foe_row($c, pfd_exp_region($exp)), $sd, ['v1' => true, 'blank' => true, 'can_pluck' => false]);
    foreach (['L', 'R', 'T', 'B'] as $sdd) { $w = $s; if (pfb_start($w, 0, $sdd) === null) { $s = $w; break; } }
    for ($t = 0; $t < 6 && !$s['over']; $t++) {
        $m = pfb_search($s, 'me'); $m ? pfb_play($s, [[$m[0], $m[1], $m[2]]], $s['turn']) : pfb_pass($s, $s['turn']);
        if ($s['over']) break;
        $mine = count(array_filter($s['pcs'], fn($p) => $p['by'] === 'me'));
        if (!$wantAoe || (!empty($s['aoe']['cells']) && $mine > 0)) { $found = ['w' => $s['w'], 'h' => $s['h'], 'aoe' => $s['aoe']['cells'] ?? [], 'seed' => $sd, 'turns' => $t + 1]; break; }
    }
}
if (!$found) { echo json_encode(['err' => 'no seed']) . "\n"; exit(1); }
$s['nonce'] = $s['nonce'] ?? bin2hex(random_bytes(6));
$enc['pfgo'] = 1; $enc['pf'] = $s; unset($enc['replay'], $enc['prev'], $enc['last'], $enc['replay0']); $enc['hist'] = [];
$exp['encounter'] = json_encode($enc); save_exp($exp);
echo json_encode($found) . "\n";
