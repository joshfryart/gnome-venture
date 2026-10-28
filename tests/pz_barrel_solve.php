<?php
// v2.0.71 test helper: print the turns (JSON) that solve Rain Barrel for SEED SIZE. Usage: php pz_barrel_solve.php GAME_DIR SEED SIZE
$src = file_get_contents($argv[1] . '/includes/puzzle_games.php');
preg_match('/function pz_imul.*?(?=\/\/ -+ runs)/s', $src, $m);
eval($m[0]);
$p = rb_make((int)$argv[2], (int)$argv[3]);
$r = [];
foreach ($p['scr'] as $i => $mm) { $t = 0; while (rb_rot($mm, $t) !== $p['sol'][$i]) $t++; $r[] = $t; }
echo json_encode($r);
