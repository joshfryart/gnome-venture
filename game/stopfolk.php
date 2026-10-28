<?php
declare(strict_types=1);
/** v2.0.77: the villagers of the stop you are standing in, for the overlay (assets/folkoverlay.js). Fetch only: JSON {ok, msg, html}. */
require __DIR__ . '/includes/bootstrap.php';
require_once __DIR__ . '/includes/adventure.php';
require_once __DIR__ . '/includes/local.php';
$u = require_login();
header('Content-Type: application/json; charset=utf-8');
$loc = player_node($u);
if (($_SERVER['HTTP_X_REQUESTED_WITH'] ?? '') !== 'fetch' || !$loc || ($loc['kind'] ?? '') !== 'village' || active_expedition($uid = (int)$u['id'])) {
    echo json_encode(['ok' => false, 'msg' => 'There’s no one to talk to here.', 'html' => '']);
    exit;
}
if (is_post()) {
    csrf_check();
    $fid = (int)($_POST['folk'] ?? 0);
    $do = (string)($_POST['do'] ?? '');
    refresh_energy($u);
    [$ok, $msg] = match ($do) {
        'chat' => local_do($u, $loc, '_chat', $_POST),
        'gift' => stop_gift($u, $loc, $fid, (int)($_POST['item_id'] ?? 0)),
        '_errand', '_deliver' => local_do($u, $loc, $do, $_POST),
        default => [false, 'Unknown action.'],
    };
    $u = require_login();   // fresh row
    echo json_encode(['ok' => $ok, 'msg' => $msg, 'html' => stop_folk_panel($u, $loc, $fid, $msg, $ok), 'changed' => $ok], JSON_UNESCAPED_SLASHES);
    exit;
}
$html = stop_folk_panel($u, $loc, (int)($_GET['folk'] ?? 0));
echo json_encode(['ok' => $html !== '', 'msg' => $html === '' ? 'They’re not here.' : '', 'html' => $html], JSON_UNESCAPED_SLASHES);
