<?php
declare(strict_types=1);
// v2.0.86: every landmark in data/landmarks.txt has a scene PNG, and the slug rule matches the files. Run: php tests/landmark_scene.php
define('APP_ROOT', dirname(__DIR__) . '/game');
function slugify(string $s): string { $s = strtolower(trim($s)); $s = preg_replace('/[^a-z0-9]+/', '-', $s); return trim($s, '-') ?: 'item'; }
$src = file_get_contents(APP_ROOT . '/includes/landmarks.php');
preg_match('/function landmark_scene_slug\(.*?\n}\n/s', $src, $m) or exit("landmark_scene_slug not found\n");
eval($m[0]);
$bad = 0; $n = 0;
foreach (file(APP_ROOT . '/includes/data/landmarks.txt', FILE_IGNORE_NEW_LINES) as $l) {
    if ($l === '' || $l[0] === '#' || substr_count($l, '|') < 4) continue;
    [, , $kind, $name] = explode('|', $l);
    $n++;
    $f = APP_ROOT . '/assets/img/wonders/' . landmark_scene_slug($kind, $name) . '.png';
    $sz = is_file($f) ? getimagesize($f) : false;
    if (!$sz || $sz[0] !== 480 || $sz[1] !== 270) { echo "MISSING/BAD: $kind $name -> " . basename($f) . "\n"; $bad++; }
}
echo $bad ? "FAIL: $bad of $n\n" : "OK: $n landmarks have a 480x270 scene\n";
exit($bad ? 1 : 0);
