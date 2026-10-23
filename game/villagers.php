<?php
declare(strict_types=1);
require __DIR__ . '/includes/bootstrap.php';
require_once __DIR__ . '/includes/garden_logic.php';
require_once __DIR__ . '/includes/world.php';
require_once __DIR__ . '/includes/villagers.php';
$u = require_login();
$uid = (int)$u['id'];
$ajax = ($_SERVER['HTTP_X_REQUESTED_WITH'] ?? '') === 'fetch';

if (is_post()) {
    csrf_check();
    $nid = (int)($_POST['id'] ?? 0);
    [$ok, $msg] = villagers_act($u, (string)($_POST['do'] ?? ''), $nid, $_POST);
    if ($ajax) {
        header('Content-Type: application/json; charset=utf-8');
        $u = require_login();   // fresh row (coins, energy)
        echo json_encode(['ok' => $ok, 'msg' => $msg, 'html' => villager_panel($u, $nid, $msg, $ok)], JSON_UNESCAPED_SLASHES);
        exit;
    }
    flash($msg, $ok ? 'ok' : 'err');
    redirect('villagers.php?id=' . $nid);
}

if ($ajax && isset($_GET['id'])) {   // the panel on its own, for the in-page open
    header('Content-Type: application/json; charset=utf-8');
    $html = villager_panel($u, (int)$_GET['id']);
    echo json_encode(['ok' => $html !== '', 'msg' => $html === '' ? 'You haven’t met them yet.' : '', 'html' => $html], JSON_UNESCAPED_SLASHES);
    exit;
}

$open = isset($_GET['id']) ? villager_panel($u, (int)$_GET['id']) : '';
$all = villagers_all($u);
page_header('Villagers');
?>
<h1>👥 Villagers</h1>
<div id="vshell" data-csrf="<?= e(csrf_token()) ?>" data-url="<?= e(url('villagers.php')) ?>">
  <div id="vpanel" aria-live="polite"><?= $open ?></div>
  <div id="vlist"><?= villagers_grid($u, $all, $_GET) ?></div>
</div>
<script src="<?= e(url('assets/villagers.js?v=' . APP_VERSION)) ?>" defer></script>
<?php page_footer();
