<?php
declare(strict_types=1);
/** The player's gnome as fight-engine rig parts (see includes/gnome_rig.php): ?p=torso|legB|legF|arm|hat|tip&h=hat&b=beard&s=scarf (6-digit hex, no #). All parts of a colour set are cut once and cached under data/gnome25/parts/. */
require __DIR__ . '/includes/bootstrap.php';
require_once __DIR__ . '/includes/gnome_rig.php';
$part = (string)($_GET['p'] ?? '');
if (!in_array($part, GNOME_RIG_PARTS, true)) { http_response_code(400); exit; }
$cols = [];
foreach (['h' => 'hat', 'b' => 'beard', 's' => 'scarf'] as $k => $role) {
    $v = (string)($_GET[$k] ?? '');
    if ($v !== '') {
        if (!preg_match('/^[0-9a-fA-F]{6}$/', $v)) { http_response_code(400); exit; }
        $cols[$role] = '#' . strtolower($v);
    }
}
$dir = APP_ROOT . '/data/gnome25/parts/' . implode('-', array_map(fn($r) => ltrim($cols[$r] ?? 'x', '#'), ['hat', 'beard', 'scarf']));
$file = $dir . '/' . $part . '.png';
$png = is_file($file) ? (string)file_get_contents($file) : '';
if ($png === '') {
    if (!is_file(APP_ROOT . '/assets/img/gnome25/side-hat.png')) { http_response_code(404); exit; }   // art missing: the caller falls back to the default parts
    $set = gnome_rig_png($cols);
    if (!isset($set[$part])) { http_response_code(404); exit; }
    if (!is_dir($dir)) @mkdir($dir, 0775, true);
    if (is_dir($dir) && is_writable($dir)) foreach ($set as $n => $b) @file_put_contents($dir . '/' . $n . '.png', $b);
    $png = $set[$part];
}
header('Content-Type: image/png');
header('Cache-Control: public, max-age=31536000, immutable');
echo $png;
