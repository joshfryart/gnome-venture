<?php
// php tests/advforce.php GAMEDIR [fight] : starts an off-the-path walk for the test gnome (and, with "fight", a creature in front of it), for screenshots
$_SERVER['SCRIPT_NAME'] = '/adventure.php';
require $argv[1] . '/includes/bootstrap.php';
require_once $argv[1] . '/includes/adventure.php';
$u = q_one("SELECT * FROM users WHERE username='sprout'");
if (!active_expedition((int)$u['id'])) { [$ok, $msg] = explore_start($u); echo $msg . "\n"; }
$exp = active_expedition((int)$u['id']);
if (($argv[2] ?? '') === 'deep' && $exp) { $exp['depth'] = 6; $exp['level'] = 6; $exp['trail'] = json_encode([1, 2, 3, 2, 3, 4, 5, 4, 5, 6]); save_exp($exp); echo "depth 6\n"; }
if (($argv[2] ?? '') === 'fight' && $exp) {
    $c = q_one("SELECT * FROM creatures WHERE level <= 3 ORDER BY id LIMIT 1");
    $exp['encounter'] = json_encode(['type' => 'creature', 'id' => (int)$c['id'], 'lv' => 0, 'sp' => 100, 'hpp' => 100, 'hp' => (int)$c['hp'], 'max' => (int)$c['hp'], 'bark' => 0, 'poison' => 0, 'used' => false]);
    save_exp($exp);
    echo "fight with {$c['name']}\n";
}
if (($argv[2] ?? '') === 'meet' && $exp) {
    $exp['encounter'] = json_encode(['type' => 'meet', 'ic' => '🧑‍🌾', 'n' => 'Pip Thistle', 's' => 'a farmer', 't' => 'Fine day for a walk, is it not?']);
    save_exp($exp);
    echo "meet\n";
}
if (($argv[2] ?? '') === 'wander' && $exp) {   // v2.1.11: a step 7 wander with nothing in front of the gnome (the phone wander layout)
    $exp['depth'] = 7; $exp['level'] = 16; $exp['trail'] = json_encode([1, 2, 3, 4, 5, 6, 7]); $exp['encounter'] = null; save_exp($exp);
    echo "wander\n";
}
if (($argv[2] ?? '') === 'choice' && $exp) {   // v2.1.12: a road-event choice card (the loon, the cart ...)
    $evs = road_events()['ev']; $ev = $evs[array_key_first($evs)];
    $exp['depth'] = 9; $exp['level'] = 18; $exp['trail'] = json_encode([1, 2, 3, 4, 5, 6, 7, 8, 9]); $exp['encounter'] = json_encode(['type' => 'choice', 'ev' => $ev['id']]); save_exp($exp);
    echo "choice\n";
}
