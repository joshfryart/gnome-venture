<?php
// php tests/trekfight_force.php GAMEDIR : puts the test gnome's trek run into a random fight (for screenshots)
$_SERVER['SCRIPT_NAME'] = '/trek.php';
require $argv[1] . '/includes/bootstrap.php';
require_once $argv[1] . '/includes/trek.php';
$uid = (int)q_val("SELECT id FROM users WHERE username='sprout'");
$r = trek_tx($uid, function (?array &$run, array $u) { trek_start_random_fight($run, $u, trek_zone_at((int)$run['chapter'], (int)$run['x'], (int)$run['y'])); return [true, '']; });
echo $r ? "fight started\n" : "no run\n";
