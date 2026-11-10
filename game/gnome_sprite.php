<?php
declare(strict_types=1);
/** The player's 2.5D gnome strip (see includes/gnome25.php): ?v=front|back|side&h=hat&b=beard&s=scarf (6-digit hex, no #). Composed once per colour set and cached under data/gnome25/. */
require __DIR__ . '/includes/bootstrap.php';
require_once __DIR__ . '/includes/gnome25.php';
$view = (string)($_GET['v'] ?? 'front');
$cols = [];
foreach (['h' => 'hat', 'b' => 'beard', 's' => 'scarf'] as $k => $role) {
    $v = (string)($_GET[$k] ?? '');
    if ($v !== '') {
        if (!preg_match('/^[0-9a-fA-F]{6}$/', $v)) { http_response_code(400); exit; }
        $cols[$role] = '#' . strtolower($v);
    }
}
$dir = APP_ROOT . '/data/gnome25';
$file = $dir . '/' . $view . '-' . implode('-', array_map(fn($r) => ltrim($cols[$r] ?? 'x', '#'), ['hat', 'beard', 'scarf'])) . '.png';
if (!in_array($view, ['front', 'back', 'side'], true)) { http_response_code(400); exit; }
$png = is_file($file) ? (string)file_get_contents($file) : '';
if ($png === '') {
    if (!sprite_miss_ok()) { http_response_code(429); exit; }   // too many new colour sets from this address
    $png = gnome25_compose($view, $cols);
    if ($png === '') { http_response_code(404); exit; }
    if (!is_dir($dir)) @mkdir($dir, 0775, true);
    if (is_dir($dir) && is_writable($dir) && sprite_cache_room($dir)) @file_put_contents($file, $png);
}
header('Content-Type: image/png');
header('Cache-Control: public, max-age=31536000, immutable');
echo $png;
