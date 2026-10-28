<?php
// v2.0.72: Gnome Beds generator checks, no server. Usage: php tests/pz_beds.php GAME_DIR
$GAME = $argv[1] ?? __DIR__ . '/../game';
$src = file_get_contents($GAME . '/includes/puzzle_games.php');
preg_match('/function pz_imul.*?(?=\/\/ -+ runs)/s', $src, $m);
eval($m[0]);
$bad = 0; $ok = function (string $n, bool $c) use (&$bad) { echo ($c ? 'ok   ' : 'FAIL ') . $n . "\n"; if (!$c) $bad++; };
$ok('same seed, same garden', gb_make(99, 8) === gb_make(99, 8));
$ok('different seed, different garden', gb_make(99, 8)['reg'] !== gb_make(100, 8)['reg']);
$notUnique = $invalid = $badBeds = $disc = 0; $max = 0.0; $N = 0;
foreach ([6, 7, 8, 9] as $n) for ($s = 1; $s <= 60; $s++) {
    $N++;
    $t = microtime(true); $p = gb_make($s * 7919 + $n, $n); $max = max($max, microtime(true) - $t);
    if (count(gb_solutions($p['reg'], $n, 3)) !== 1) $notUnique++;
    if (!gb_valid($p['sol'], $p['reg'], $n)) $invalid++;
    if (count(array_unique($p['reg'])) !== $n || min($p['reg']) < 0) $badBeds++;
    for ($b = 0; $b < $n; $b++) { $first = array_search($b, $p['reg'], true); if ($first === false) { $disc++; continue; } if (gb_connected_without($p['reg'], $n, $b, -1) === false) $disc++; }
}
$ok("$N gardens: exactly one answer each", $notUnique === 0);
$ok('the answer is a legal placement', $invalid === 0);
$ok('n beds, all cells in a bed', $badBeds === 0);
$ok('every bed is one connected piece', $disc === 0);
$ok('slowest garden under 3 s (' . round($max, 2) . ' s)', $max < 3.0);
$p = gb_make(5, 8); $sol = $p['sol'];
$ok('legal answer accepted', gb_valid($sol, $p['reg'], 8));
$touch = $sol; $touch[1] = $sol[0] + ($sol[0] < 7 ? 1 : -1);
$ok('touching gnomes refused', !gb_valid($touch, $p['reg'], 8));
$dup = $sol; $dup[1] = $dup[0];
$ok('two in a column refused', !gb_valid($dup, $p['reg'], 8));
$ok('short or empty placement refused', !gb_valid(array_slice($sol, 0, 7), $p['reg'], 8) && !gb_valid(array_fill(0, 8, -1), $p['reg'], 8));
exit($bad ? 1 : 0);
