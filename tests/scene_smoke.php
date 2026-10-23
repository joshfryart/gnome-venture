<?php
// php tests/scene_smoke.php : scene.php helpers fall back cleanly and escape their output
define('APP_ROOT', dirname(__DIR__) . '/game');
function e($s) { return htmlspecialchars((string)$s, ENT_QUOTES); }
function url($p) { return $p; }
function art_path($p) { return is_file(APP_ROOT . '/' . $p) ? $p : ''; }
require APP_ROOT . '/includes/scene.php';
$bad = 0;
$t = function (bool $ok, string $m) use (&$bad) { echo ($ok ? 'ok   ' : 'FAIL ') . $m . "\n"; if (!$ok) $bad++; };
$t(scene_key('../x') === '', 'bad key rejected');
$t(scene_key('NA') === 'NA', 'region code kept');
$t(scene_path('stage', 'nope') === '', 'missing scene is empty');
$t(str_contains(scene_banner('forest', 'A "forest"'), 'scene-fb-forest'), 'banner fallback');
$h = scene_stage('stage', 'forest', [['id' => 'a', 'side' => 'p', 'name' => '<b>x</b>', 'img' => 'assets/img/ph/nav-villagers.png', 'hp' => 5, 'max' => 10]]);
$t(!str_contains($h, '<b>') && str_contains($h, 'data-stage='), 'stage escapes and carries data');
exit($bad ? 1 : 0);
