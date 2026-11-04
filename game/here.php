<?php
declare(strict_types=1);
/**
 * Graphical navigation (plan-graphical-nav.md), phase 2a/2b: the Here page, a picture of where the gnome stands.
 * Read-only: hotspots are links, cards hold the POST forms of existing actions. Setting gnav_on (off = this page sends you to the town page;
 * an admin can preview it). ?o=<id> opens that card without script; ?debug=1 (admin) draws every slot as a numbered dot.
 */
require __DIR__ . '/includes/bootstrap.php';
require_once __DIR__ . '/includes/garden_logic.php';
require_once __DIR__ . '/includes/here_view.php';
require_once __DIR__ . '/includes/place_ui.php';
$u = require_login();
$uid = (int)$u['id'];
if (!gnav_on() && !is_admin()) redirect('town.php');
refresh_energy($u);
if (active_expedition($uid)) { flash('You’re still on the road.', 'err'); redirect('adventure.php'); }
$node = player_node($u);
$open = preg_match('/^[A-Za-z0-9_-]{1,40}$/', (string)($_GET['o'] ?? '')) ? (string)$_GET['o'] : '';
$debug = is_admin() && !empty($_GET['debug']);
page_header($node['name']);
$kindIcons = ['village' => '🏡', 'haven' => '🏕️', 'wonder' => '✨', 'lair' => '🐉', 'delve' => '🕳️', 'market' => '🏘️', 'hub' => '🏛️'];
?>
<?php if (!gnav_on()): ?><p class="box notice">👀 Preview for admins: picture navigation is switched off for players (Admin → Settings → gnav_on).</p><?php endif; ?>
<p class="crumbs">🌍 <a href="<?= e(url('world.php')) ?>">World</a> › <?= e((string)$node['region']) ?> › <b><?= e($node['name']) ?></b></p>
<h1><?= $kindIcons[loc_real_kind($node)] ?? '📍' ?> <?= e($node['name']) ?></h1>
<p class="hereinfo"><span class="muted">🕰️ It’s <?= e(hour_label(hollow_hour())) ?> in the Hollow, <?= e(hollow_date('l')) ?></span></p>
<?= dest_resume_html($u) ?>
<?= here_view($u, $node, $debug, $open) ?>
<?= gnav_tools_html($u, 'here.php') ?>
<p class="heretools">
  <a class="btn alt" href="<?= e(url('town.php')) ?>"><?= in_array($node['kind'], ['market', 'hub'], true) ? '🏘️ Town square' : '🪧 This place (list)' ?></a>
  <a class="btn alt" href="<?= e(url('world.php')) ?>">🌍 World map</a>
  <a class="btn alt" href="<?= e(url('villagers.php')) ?>">👥 Villagers</a>
</p>
<?php page_footer();
