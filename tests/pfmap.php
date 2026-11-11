<?php
// php tests/pfmap.php GAMEDIR [seed] [maxLevel] : puts the test gnome on a RANDOM route out of where it stands, with a RANDOM creature in front of it (prints "route name | creature name").
$_SERVER['SCRIPT_NAME'] = '/adventure.php';
require $argv[1] . '/includes/bootstrap.php';
require_once $argv[1] . '/includes/adventure.php';
mt_srand((int)($argv[2] ?? time()));
$u = q_one("SELECT * FROM users WHERE username='sprout'");
q('UPDATE expeditions SET status = \'done\' WHERE user_id = ? AND status = \'active\'', [$u['id']]);
q('UPDATE users SET energy = 100 WHERE id = ?', [$u['id']]);
$here = player_node($u);
$routes = q('SELECT id FROM routes WHERE kind = \'road\' AND (a_id = ? OR b_id = ?)', [$here['id'], $here['id']])->fetchAll(PDO::FETCH_ASSOC);
if (!$routes) { echo "NOROUTE\n"; exit(1); }
$rid = (int)$routes[mt_rand(0, count($routes) - 1)]['id'];
if (($argv[4] ?? '') === 'wander') { [$ok, $msg] = explore_start($u); } else [$ok, $msg] = start_expedition($u, $rid);
if (!$ok) { echo "FAILED $msg\n"; exit(1); }
$exp = active_expedition((int)$u['id']);
$all = q('SELECT * FROM creatures WHERE level <= ?', [(int)($argv[3] ?? 999)])->fetchAll(PDO::FETCH_ASSOC); $c = $all[mt_rand(0, count($all) - 1)];
$exp['encounter'] = json_encode(['type' => 'creature', 'id' => (int)$c['id'], 'lv' => 0, 'sp' => 100, 'hpp' => 100, 'hp' => (int)$c['hp'], 'max' => (int)$c['hp'], 'bark' => 0, 'poison' => 0, 'used' => false]);
save_exp($exp);
echo "route $rid | {$c['name']} ({$c['size']}, lv {$c['level']})\n";
