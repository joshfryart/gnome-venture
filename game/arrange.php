<?php
declare(strict_types=1);
/**
 * T2.1: Arranging moved. The workshop (arrange, drying rack, seed packets, florists) is the Satchel's Arrange tab
 * (inventory.php?tab=arrange, includes/arrange_view.php) and the weekly Arrangements show is on the Village Show page (show.php).
 * This page only sends old links, bookmarks and open forms on: GET with 302, POST with 307 (the browser re-sends the form there).
 */
require __DIR__ . '/includes/bootstrap.php';
require_login();

$t = (string)($_GET['t'] ?? '');
$post = is_post();
if ($t === 'show' || ($post && ($_POST['do'] ?? '') === 'enter')) {
    $to = $post ? 'show.php' : 'show.php#arrangements';   // show.php takes the old do=enter as well as enter_arr
} else {
    $keep = [];
    if (in_array($t, ['dry', 'packets', 'florists', 'preview'], true)) $keep['t'] = $t;
    foreach (['v', 's', 'made'] as $k) if (isset($_GET[$k]) && is_string($_GET[$k])) $keep[$k] = $_GET[$k];
    $to = 'inventory.php?tab=arrange' . ($keep ? '&' . http_build_query($keep) : '');
}
header('Location: ' . url($to), true, $post ? 307 : 302);
exit;
