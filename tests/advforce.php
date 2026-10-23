<?php
// php tests/advforce.php GAMEDIR [fight] : starts an off-the-path walk for the test gnome (and, with "fight", a creature in front of it), for screenshots
$_SERVER['SCRIPT_NAME'] = '/adventure.php';
require $argv[1] . '/includes/bootstrap.php';
require_once $argv[1] . '/includes/adventure.php';
$u = q_one("SELECT * FROM users WHERE username='sprout'");
if (!active_expedition((int)$u['id'])) { [$ok, $msg] = explore_start($u); echo $msg . "\n"; }
$exp = active_expedition((int)$u['id']);
if (($argv[2] ?? '') === 'fight' && $exp) {
    $c = q_one("SELECT * FROM creatures WHERE level <= 3 ORDER BY id LIMIT 1");
    $exp['encounter'] = json_encode(['type' => 'creature', 'id' => (int)$c['id'], 'lv' => 0, 'sp' => 100, 'hpp' => 100, 'hp' => (int)$c['hp'], 'max' => (int)$c['hp'], 'bark' => 0, 'poison' => 0, 'used' => false]);
    save_exp($exp);
    echo "fight with {$c['name']}\n";
}
