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
require_once __DIR__ . '/includes/trail_tiles.php';
$u = require_login();
$uid = (int)$u['id'];
if (!gnav_on() && !is_admin()) redirect('town.php');
refresh_energy($u);
if (active_expedition($uid)) redirect('adventure.php');   // the walk is the Here page now (Here tab lit): no message
$node = player_node($u);
$open = preg_match('/^[A-Za-z0-9_-]{1,40}$/', (string)($_GET['o'] ?? '')) ? (string)$_GET['o'] : '';
$debug = is_admin() && !empty($_GET['debug']);
page_header($node['name']);
$kindIcons = ['village' => '🏡', 'haven' => '🏕️', 'wonder' => '✨', 'lair' => '🐉', 'delve' => '🕳️', 'market' => '🏘️', 'hub' => '🏛️'];
?>
<?php if (!gnav_on()): ?><p class="box notice">👀 Preview for admins: picture navigation is switched off for players (Admin → Settings → gnav_on).</p><?php endif; ?>
<div class="herepage"><div class="crumbs">🌍 <a href="<?= e(url('world.php')) ?>">World</a> › <?= e((string)$node['region']) ?> › <b><?= e($node['name']) ?></b></div>
<h1><?= $kindIcons[loc_real_kind($node)] ?? '📍' ?> <?= e($node['name']) ?></h1>
<p class="hereinfo"><span class="muted">🕰️ It’s <?= e(hour_label(gclock_my_hour())) ?> in the Hollow, <?= e(gclock_my_weekday()) ?></span></p>
<?php require_once __DIR__ . '/includes/explore.php'; ?>
<?= wander_step_once('road') /* v2.5.49: the gnome stepping back onto the road, once (art optional) */ ?>
<?= trail_resume_html($u) /* a walk put away by Wander off the Trail */ ?>
<?= dest_resume_html($u) ?>
<?php $hv = here_view($u, $node, $debug, $open); $gate = !empty($GLOBALS['gnav_gate']); ?>
<?= $hv ?>
<?= gnav_tools_html($u, 'here.php', !$gate) ?>
<?php if (!$gate): ?><p class="heretools">
  <a class="btn alt" href="<?= e(url('town.php')) ?>"><?= in_array($node['kind'], ['market', 'hub'], true) ? '🏘️ Town square' : '🪧 This place (list)' ?></a>
  <a class="btn alt" href="<?= e(url('world.php')) ?>">🌍 World map</a>
  <a class="btn alt" href="<?= e(url('villagers.php')) ?>">👥 Villagers</a>
</p><?php endif; ?>
</div>
<?php page_footer();
