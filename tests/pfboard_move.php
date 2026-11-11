<?php
// php tests/pfboard_move.php GAMEDIR : prints one legal move for the test gnome in its current board fight, as "handIndex,x,y" (or "PASS" when nothing fits, or "NONE" when there is no board fight).
$_SERVER['SCRIPT_NAME'] = '/adventure.php';
require $argv[1] . '/includes/bootstrap.php';
require_once $argv[1] . '/includes/adventure.php';
require_once $argv[1] . '/includes/pfight_game.php';
$u = q_one("SELECT * FROM users WHERE username = 'sprout'");
$exp = active_expedition((int)$u['id']);
$enc = $exp && $exp['encounter'] ? json_decode((string)$exp['encounter'], true) : null;
$s = $enc['pf'] ?? null;
if (!$s || ($s['mode'] ?? '') !== 'board') { echo "NONE\n"; exit; }
$m = pfb_search($s, 'me');
echo $m ? $m[0] . ',' . $m[1] . ',' . $m[2] . "\n" : "PASS\n";
