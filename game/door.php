<?php
declare(strict_types=1);
/** Graphical navigation, phase 3: one villager's door. door.php?npc=<id>&page=<street page>. Knock (only when home), Leave gift (any time), Back. */
require __DIR__ . '/includes/bootstrap.php';
require_once __DIR__ . '/includes/garden_logic.php';
require_once __DIR__ . '/includes/here_view.php';
require_once __DIR__ . '/includes/residential.php';
$u = require_login();
if (!gnav_on() && !is_admin()) redirect('town.php');
$nid = (int)($_POST['npc'] ?? $_GET['npc'] ?? 0);
$page = max(1, (int)($_POST['page'] ?? $_GET['page'] ?? 1));
$npc = q_one('SELECT * FROM npcs WHERE id = ? AND active = 1', [$nid]);
if (!$npc || !door_allowed($u, $npc)) {   // gone, moved house, or you are not at their home place
    if ($npc && !active_expedition((int)$u['id'])) { flash('That door is not here.', 'err'); redirect('here.php'); }
    redirect('villagers.php');
}
if (is_post()) {
    csrf_check();
    if ((string)($_POST['do'] ?? '') === 'gift') {
        [$ok, $msg] = npc_gift_door($u, $nid, (int)($_POST['item_id'] ?? 0));
        flash($msg, $ok ? 'ok' : 'err');
    }
    redirect('door.php?npc=' . $nid . '&page=' . $page);   // back to the same door, so Back always lands in the right street
}
$open = preg_match('/^[a-z]{3,8}$/', (string)($_GET['o'] ?? '')) ? (string)$_GET['o'] : '';
page_header('Door');
$met = resid_met((int)$u['id'], $nid);
?>
<p class="crumbs">🌍 <a href="<?= e(url('world.php')) ?>">World</a> › <a href="<?= e(url('here.php')) ?>"><?= e((string)player_node($u)['name']) ?></a> › <a href="<?= e(url('residential.php?page=' . $page)) ?>">Homes</a> › <b><?= e($met ? (string)$npc['name'] : 'A door') ?></b></p>
<h1>🚪 <?= e($met ? $npc['name'] . '’s door' : 'A door') ?></h1>
<?= door_view($u, $npc, $page, $open) ?>
<p class="heretools"><a class="btn alt" href="<?= e(url('residential.php?page=' . $page)) ?>">⬅️ Back to the street</a></p>
<?php page_footer();
