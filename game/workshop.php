<?php
declare(strict_types=1);
/** Graphical navigation (phases 4 and 5): The workshop as a picture. Flag gnav_craft (needs gnav_on; admins can preview). Old page: inventory.php?tab=craft (always there). ?o=<id> opens that card without script. */
require __DIR__ . '/includes/bootstrap.php';
require_once __DIR__ . '/includes/garden_logic.php';
require_once __DIR__ . '/includes/here_view.php';
require_once __DIR__ . '/includes/hub_pages.php';
$u = require_login();
if (!gnav_page_open('gnav_craft')) redirect('inventory.php?tab=craft');
if (isset($_GET['frag'])) {   // one crafting section as html for the popover (assets/workshop.js): the same view the Satchel's Crafting tab shows
    require_once __DIR__ . '/includes/items.php';
    require_once __DIR__ . '/includes/crafting.php';
    require_once __DIR__ . '/includes/tools.php';
    require_once __DIR__ . '/includes/craft_view.php';
    header('Content-Type: application/json; charset=utf-8');
    $key = (string)$_GET['frag'];
    if (!isset(CRAFT_CATEGORIES[$key])) { http_response_code(404); echo json_encode(['ok' => false, 'html' => '']); exit; }
    $_GET['tab'] = 'craft';
    $_GET['c'] = $key;
    refresh_energy($u);
    $u = q_one('SELECT * FROM users WHERE id = ?', [$u['id']]);
    $msgs = '';
    foreach (take_flashes() as $f) $msgs .= '<p class="flash ' . ($f['type'] === 'err' ? 'err' : 'ok') . '" role="status">' . e((string)$f['msg']) . '</p>';
    ob_start();
    craft_view($u, $key);
    echo json_encode(['ok' => true, 'html' => $msgs . ob_get_clean()], JSON_UNESCAPED_SLASHES);
    exit;
}
$open = preg_match('/^[A-Za-z0-9_-]{1,40}$/', (string)($_GET['o'] ?? '')) ? (string)$_GET['o'] : '';
page_header('Crafting');
?>
<h1>The workshop</h1>
<?= workshop_view($u, $open) ?>
<p class="heretools"><a class="btn alt" href="<?= e(url('inventory.php?tab=craft')) ?>">List version</a></p>
<?php page_footer();
