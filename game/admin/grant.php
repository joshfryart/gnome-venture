<?php
declare(strict_types=1);
require dirname(__DIR__) . '/includes/bootstrap.php';
require_once dirname(__DIR__) . '/includes/admin_helpers.php';   // v1.6.3
$me = require_admin();

if (is_post()) {
    csrf_check();
    $username = trim((string)($_POST['username'] ?? ''));
    $itemId = (int)($_POST['item_id'] ?? 0);
    $qty = (int)($_POST['qty'] ?? 0);
    $coins = (int)($_POST['coins'] ?? 0);
    $u = q_one('SELECT id, username, coins FROM users WHERE username = ?', [$username]);
    if (!$u) {
        flash('No player called "' . $username . '".', 'err');
    } else {
        $done = [];
        if ($itemId && $qty !== 0) {
            $item = q_one('SELECT id, name FROM items WHERE id = ?', [$itemId]);
            if (!$item) {
                flash('Unknown item.', 'err');
            } elseif (!give_item((int)$u['id'], $itemId, $qty)) {
                flash($u['username'] . ' doesn’t have that many to take.', 'err');
            } else {
                $done[] = ($qty > 0 ? '+' : '') . $qty . ' ' . $item['name'];
            }
        }
        if ($coins !== 0) {
            $newCoins = max(0, (int)$u['coins'] + $coins);
            q('UPDATE users SET coins = ? WHERE id = ?', [$newCoins, $u['id']]);
            $done[] = ($coins > 0 ? '+' : '') . $coins . ' ' . setting('currency_name');
        }
        if ($done) {
            admin_log('grant', 'users#' . $u['id'], implode(', ', $done));
            flash('Done for ' . $u['username'] . ': ' . implode(', ', $done));
        }
    }
    redirect('admin/grant.php?user=' . urlencode($username));
}

$prefill = (string)($_GET['user'] ?? '');
if (!$prefill && isset($_GET['user_id'])) {
    $prefill = (string)q_val('SELECT username FROM users WHERE id = ?', [(int)$_GET['user_id']]);
}

page_header('Give / take items', true);
?>
<?php admin_crumbs('grant.php');   // v1.6.3 ?>
<h1>Give / take items</h1>
<form method="post" class="form box">
  <?= csrf_field() ?>
  <label>Player username <input name="username" value="<?= e($prefill) ?>" required></label>
  <label>Item <select name="item_id"><option value="0">— none —</option>
    <?php foreach (q('SELECT id, name, category FROM items ORDER BY category, name')->fetchAll() as $i): ?>
      <option value="<?= (int)$i['id'] ?>"><?= e($i['category'] . ': ' . $i['name']) ?></option>
    <?php endforeach; ?></select></label>
  <label>Amount (negative to take away) <input type="number" name="qty" value="1"></label>
  <label><?= e(setting('currency_name')) ?> (negative to take away) <input type="number" name="coins" value="0"></label>
  <button class="btn">Apply</button>
</form>
<?php page_footer();
