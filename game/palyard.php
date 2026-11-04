<?php
declare(strict_types=1);
/** Graphical navigation (phases 4 and 5): The Pal Yard as a picture. Flag gnav_tree (needs gnav_on; admins can preview). Old page: paljobs.php (always there). ?o=<id> opens that card without script. */
require __DIR__ . '/includes/bootstrap.php';
require_once __DIR__ . '/includes/garden_logic.php';
require_once __DIR__ . '/includes/here_view.php';
require_once __DIR__ . '/includes/hub_pages.php';
$u = require_login();
if (!gnav_page_open('gnav_tree')) redirect('paljobs.php');
$open = preg_match('/^[A-Za-z0-9_-]{1,40}$/', (string)($_GET['o'] ?? '')) ? (string)$_GET['o'] : '';
page_header('Pal Yard');
?>
<h1>The Pal Yard</h1>
<?= yard_view($u, $open) ?>
<p class="heretools"><a class="btn alt" href="<?= e(url('treehouse.php')) ?>">🌳 Treehouse</a> <a class="btn alt" href="<?= e(url('paljobs.php')) ?>">List version</a></p>
<?php page_footer();
