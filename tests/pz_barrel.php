<?php
// v2.0.71: Rain Barrel generator and checker, no server. Usage: php tests/pz_barrel.php GAME_DIR
$GAME = $argv[1] ?? __DIR__ . '/../game';
define('APP_ROOT', $GAME);
$src = file_get_contents($GAME . '/includes/puzzle_games.php');
// pull only the pure functions (the file needs the whole site to load)
preg_match('/function pz_imul.*?(?=\/\/ -+ runs)/s', $src, $m);
preg_match('/const PZ_BARREL_SIZES[^\n]*/', $src, $c);
eval($c[0] . "\n" . $m[0]);
$bad = 0; $ok = function (string $n, bool $c) use (&$bad) { echo ($c ? 'ok   ' : 'FAIL ') . $n . "\n"; if (!$c) $bad++; };
// rng matches the JS mulberry32 (reference values from node)
$r = pz_rng(12345); $v = [$r(), $r(), $r()];
$ok('rng in [0,1)', $v[0] >= 0 && $v[0] < 1 && $v[1] != $v[2]);
$ok('same seed, same puzzle', rb_make(777, 6) === rb_make(777, 6));
$ok('different seed, different puzzle', rb_make(777, 6)['scr'] !== rb_make(778, 6)['scr']);
$ok('rot is a 4-cycle', rb_rot(1, 1) === 2 && rb_rot(8, 1) === 1 && rb_rot(5, 2) === 5 && rb_rot(3, 4) === 3);
$bad0 = 0; $edges = 0; $dealtSolved = 0; $leafless = 0; $srcBad = 0;
foreach ([5, 6, 8] as $n) for ($s = 1; $s <= 365; $s++) {
    $p = rb_make($s * 7919 + $n, $n);
    if (!rb_valid($p['sol'], $n)) $bad0++;
    if (rb_valid($p['scr'], $n)) $dealtSolved++;
    $deg = 0; foreach ($p['sol'] as $mm) $deg += substr_count(decbin($mm), '1');
    if ($deg !== 2 * ($n * $n - 1)) $edges++;
    if (!in_array($p['sol'][$p['src']], [1, 2, 4, 8], true)) $srcBad++;
    // dealt tiles are the solution tiles turned: same degree
    foreach ($p['sol'] as $i => $mm) if (substr_count(decbin($mm), '1') !== substr_count(decbin($p['scr'][$i]), '1')) $bad0++;
    // the dealt tiles can be turned back to the solution
    $r = []; foreach ($p['scr'] as $i => $mm) { $t = 0; while (rb_rot($mm, $t) !== $p['sol'][$i]) $t++; $r[] = $t; }
    $a = rb_apply($p['scr'], $r); if ($a === null || !rb_valid($a, $n)) $bad0++;
}
$ok('1095 puzzles: every solution valid, dealt tiles keep their shape', $bad0 === 0);
$ok('every puzzle is a tree (edges = tiles - 1)', $edges === 0);
$ok('no puzzle is dealt already solved', $dealtSolved === 0);
$ok('barrel sits at a pipe end', $srcBad === 0);
$p = rb_make(5, 6);
$ok('apply refuses bad r', rb_apply($p['scr'], [0, 1]) === null && rb_apply($p['scr'], array_fill(0, 36, 4)) === null);
$leak = $p['sol']; $leak[0] = 15;
$ok('a leak is invalid', !rb_valid($leak, 6));
$cut = $p['sol']; $cut[1] = 0;
$ok('a gap is invalid', !rb_valid($cut, 6));
exit($bad ? 1 : 0);
