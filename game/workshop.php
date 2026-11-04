<?php
declare(strict_types=1);
/** Graphical navigation (phases 4 and 5): The workshop as a picture. Flag gnav_craft (needs gnav_on; admins can preview). Old page: inventory.php?tab=craft (always there). ?o=<id> opens that card without script. */
require __DIR__ . '/includes/bootstrap.php';
require_once __DIR__ . '/includes/garden_logic.php';
require_once __DIR__ . '/includes/here_view.php';
require_once __DIR__ . '/includes/hub_pages.php';
$u = require_login();
if (!gnav_page_open('gnav_craft')) redirect('inventory.php?tab=craft');
$open = preg_match('/^[A-Za-z0-9_-]{1,40}$/', (string)($_GET['o'] ?? '')) ? (string)$_GET['o'] : '';
page_header('Crafting');
?>
<h1>The workshop</h1>
<?= workshop_view($u, $open) ?>
<p class="heretools"><a class="btn alt" href="<?= e(url('inventory.php?tab=craft')) ?>">List version</a></p>
<?php page_footer();
