<?php
declare(strict_types=1);
/** Graphical navigation, phase 3: the street of homes of the place the gnome stands in. residential.php?loc=<id>&page=<n>. Behind gnav_on (admin preview). */
require __DIR__ . '/includes/bootstrap.php';
require_once __DIR__ . '/includes/garden_logic.php';
require_once __DIR__ . '/includes/here_view.php';
require_once __DIR__ . '/includes/residential.php';
$u = require_login();
if (!gnav_on() && !is_admin()) redirect('town.php');
refresh_energy($u);
if (active_expedition((int)$u['id'])) { flash('You’re still on the road.', 'err'); redirect('adventure.php'); }
$node = player_node($u);
if ((int)($_GET['loc'] ?? $node['id']) !== (int)$node['id'] || !npcs_homed_at((int)$node['id'])) redirect('here.php');   // you must be there; no homes, no street
[$html, $pages] = resid_view($u, $node, (int)($_GET['page'] ?? 1));
page_header('Homes of ' . $node['name']);
?>
<p class="crumbs">🌍 <a href="<?= e(url('world.php')) ?>">World</a> › <a href="<?= e(url('here.php')) ?>"><?= e($node['name']) ?></a> › <b>Homes</b></p>
<h1>🏠 Homes of <?= e($node['name']) ?></h1>
<p class="help">Tap a house to go to its door. A lit window means someone is home.</p>
<?= $html ?>
<p class="heretools"><a class="btn alt" href="<?= e(url('here.php')) ?>">⬅️ Back to the square</a></p>
<?php page_footer();
