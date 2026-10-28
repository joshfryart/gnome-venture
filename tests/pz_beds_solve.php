<?php
// v2.0.72 test helper: print the answer (JSON columns per row) for Gnome Beds SEED SIZE. Usage: php pz_beds_solve.php GAME_DIR SEED SIZE
$src = file_get_contents($argv[1] . '/includes/puzzle_games.php');
preg_match('/function pz_imul.*?(?=\/\/ -+ runs)/s', $src, $m);
eval($m[0]);
echo json_encode(gb_make((int)$argv[2], (int)$argv[3])['sol']);
