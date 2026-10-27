<?php
declare(strict_types=1);
/**
 * v0.7.80: gather here at a road stop or a place (not on an expedition). POST only; the box is on the World page.
 * Off the path, the same box is on the adventure page (see explore_gather in includes/explore.php).
 */
require __DIR__ . '/includes/bootstrap.php';
require_once __DIR__ . '/includes/adventure.php';
$u = require_login();
if (!is_post()) redirect('world.php');
csrf_check();
refresh_energy($u);
$uid = (int)$u['id'];
// Back to the page the gnome came from (only our own world and town pages), else the World page
$back = (string)($_POST['back'] ?? '');
$safe = preg_match('#^(world|town)\.php(\?[^\s]*)?$#', $back) && !str_contains($back, '//') ? $back : 'world.php';
if (active_expedition($uid)) {
    flash('Finish your trip first.', 'err');
    redirect($safe);
}
if (ts($u['community_shift_until'] ?? null) > time()) {
    flash('You’re on a tending shift at the community garden. Finish or end it first.', 'err');
    redirect($safe);
}
$here = player_node($u);
$land = (string)($here['landscape'] ?: 'grassland');
$tool = (string)($_POST['tool'] ?? '');
[$ok, $msg] = gather_here($u, $land, $tool);   // v2.0.67: no mini-game; a find goes into the satchel reveal on the Gather tab
flash($msg, $ok ? 'ok' : 'err');
redirect($safe);
