<?php
declare(strict_types=1);
/** The player's gnome as the fight engine's rig sheet (see includes/gnome_rig.php): ?p=sheet&h=hat&b=beard&s=scarf (6-digit hex, no #). The sheet of a colour set is cut once and cached under data/gnome25/parts/. */
require __DIR__ . '/includes/bootstrap.php';
require_once __DIR__ . '/includes/gnome_rig.php';
if ((string)($_GET['p'] ?? '') !== 'sheet') { http_response_code(400); exit; }
$cols = [];
foreach (['h' => 'hat', 'b' => 'beard', 's' => 'scarf'] as $k => $role) {
    $v = (string)($_GET[$k] ?? '');
    if ($v !== '') {
        if (!preg_match('/^[0-9a-fA-F]{6}$/', $v)) { http_response_code(400); exit; }
        $cols[$role] = '#' . strtolower($v);
    }
}
$dir = APP_ROOT . '/data/gnome25/parts/' . implode('-', array_map(fn($r) => ltrim($cols[$r] ?? 'x', '#'), ['hat', 'beard', 'scarf']));
$file = $dir . '/sheet2.png';   // sheet2: the layout with head, beard, scarf and elbows (bump when GNOME_RIG_PARTS changes)
$png = is_file($file) ? (string)file_get_contents($file) : '';
if ($png === '') {
    if (!is_file(APP_ROOT . '/assets/img/gnome25/side-hat.png')) { http_response_code(404); exit; }   // art missing: the caller falls back to the default sheet
    if (!sprite_miss_ok()) { http_response_code(429); exit; }   // too many new colour sets from this address
    $png = gnome_rig_sheet($cols);
    if (sprite_cache_room(dirname($dir))) {
        if (!is_dir($dir)) @mkdir($dir, 0775, true);
        if (is_dir($dir) && is_writable($dir)) @file_put_contents($file, $png);
    }
}
header('Content-Type: image/png');
header('Cache-Control: public, max-age=31536000, immutable');
echo $png;
