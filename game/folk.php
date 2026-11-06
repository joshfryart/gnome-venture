<?php
declare(strict_types=1);
// Legacy URL. GET goes to villagers.php; the POST handler stays for old forms and test scripts. (Dead page template removed in the polish pass.)
require __DIR__ . '/includes/bootstrap.php';
require_once __DIR__ . '/includes/garden_logic.php';
require_once __DIR__ . '/includes/world.php';
require_once __DIR__ . '/includes/friends.php';
require_once __DIR__ . '/includes/npc_life.php';
$u = require_login();
$uid = (int)$u['id'];
if (!is_post()) redirect('villagers.php' . (isset($_GET['id']) ? '?' . (isset($_GET['home']) ? 'home=1&' : '') . 'id=' . (int)$_GET['id'] : ''));   // v2.0.39: the Villagers page replaces this one
if (!isset($_GET['id'])) {   // old search/filter links go to the Villagers page
    $keep = array_filter(['q' => (string)($_GET['q'] ?? ''), 'f' => (string)($_GET['f'] ?? ''), 'r' => (string)($_GET['r'] ?? '')], fn($v) => $v !== '');
    redirect('villagers.php' . ($keep ? '?' . http_build_query($keep) : ''));
}
$npc = q_one('SELECT * FROM npcs WHERE id = ? AND active = 1', [(int)($_GET['id'] ?? 0)]);
if (!$npc) {
    flash('Nobody by that name lives here.', 'err');
    redirect('world.php');
}
$nid = (int)$npc['id'];

if (is_post()) {
    csrf_check();
    [$ok, $msg] = match ((string)($_POST['do'] ?? '')) {
        'talk' => npc_talk($u, $nid),
        'gift' => npc_gift($u, $nid, (int)($_POST['item_id'] ?? 0)),
        'deal' => traveller_deal($u, $nid),
        default => [false, 'Unknown action.'],
    };
    flash($msg, $ok ? 'ok' : 'err');
    redirect('villagers.php?id=' . $nid);
}
