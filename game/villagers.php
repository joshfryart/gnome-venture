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
require_once __DIR__ . '/includes/npc_life.php';
$visit = $open !== '' && isset($_GET['home']) && str_contains($open, 'id="homestage"');   // v2.0.68: Knock = a visit, the home is the page
$hn = $visit ? q_one('SELECT * FROM npcs WHERE id = ?', [(int)$_GET['id']]) : null;
$hm = $hn ? npc_home($hn) : null;
page_header($visit ? 'Visiting ' . $hn['name'] : 'Villagers');
?>
<h1><?= $visit ? '🏡 ' . e($hm['name'] ?? ($hn['name'] . '’s home')) : '👥 Villagers' ?></h1>
<div id="vshell" data-csrf="<?= e(csrf_token()) ?>" data-url="<?= e(url('villagers.php')) ?>">
  <div id="vpanel" aria-live="polite"><?= $open ?></div>
  <?php if ($visit): ?><p class="gx-actions"><a class="gbtn alt" href="<?= e(url('town.php?view=villagers' . ($hm && $hm['region'] === HUB_REGION ? '&hub=1' : ''))) ?>">← Back to town</a> <a class="gbtn alt" href="<?= e(url('villagers.php')) ?>">All villagers</a></p>
  <?php else: ?><div id="vlist"><?= villagers_grid($u, villagers_all($u), $_GET) ?></div><?php endif; ?>
</div>
<script src="<?= e(url('assets/villagers.js?v=' . APP_VERSION)) ?>" defer></script>
<?php page_footer();
