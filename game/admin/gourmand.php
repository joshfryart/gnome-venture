<?php
declare(strict_types=1);
// The Gourmand (Pomeroy Crumbworth): a read-only preview for admins. The camp schedule and menus of any month, and what gnomes have served.
// The switch and the force date live in Game settings ("World"). Nothing here changes the game.
require dirname(__DIR__) . '/includes/bootstrap.php';
require_once dirname(__DIR__) . '/includes/gourmand.php';
require_once dirname(__DIR__) . '/includes/admin_helpers.php';
$me = require_admin();

$tour = (string)($_GET['tour'] ?? '');
if (!preg_match('/^\d{4}-(0[1-9]|1[0-2])$/', $tour)) $tour = hollow_date('Y-m', gourmand_now());
$prev = (new DateTimeImmutable($tour . '-01', hollow_tz()))->modify('-1 month')->format('Y-m');
$next = (new DateTimeImmutable($tour . '-01', hollow_tz()))->modify('+1 month')->format('Y-m');
$on = setting('gourmand_open') === '1';
$force = trim((string)setting('gourmand_force_date'));
$stop = gourmand_stop();
$ledger = [];
foreach (q("SELECT region, course, COUNT(*) AS gnomes, SUM(served) AS served FROM gourmand_ledger WHERE course IN ('plate', 'pot', 'jar', 'grand', 'home') GROUP BY region, course")->fetchAll() as $r) $ledger[$r['region']][$r['course']] = $r;
$claims = q("SELECT course, COUNT(*) AS n FROM gourmand_ledger WHERE course IN ('table', 'gold', 'grandpay', 'finale') GROUP BY course")->fetchAll(PDO::FETCH_KEY_PAIR);
$players = (int)q_val('SELECT COUNT(DISTINCT user_id) FROM gourmand_ledger');
$itemName = fn(string $slug) => (string)(q_val('SELECT name FROM items WHERE slug = ?', [$slug]) ?: $slug);
page_header('The Gourmand', true);
?>
<?php admin_crumbs('gourmand.php'); ?>
<h1>🥄 The Gourmand</h1>
<p><b><?= $on ? 'On' : 'Off' ?></b> for players<?= $on ? '' : ' (admins still see him)' ?>. Change it in <a href="<?= e(url('admin/settings.php')) ?>">Game settings</a>, “World”.
  <?= $force !== '' ? 'Date forced to <code>' . e($force) . '</code> for every player.' : 'Following the real clock.' ?></p>
<p class="help">Now: camp in <b><?= e($stop['town']) ?></b> (<?= e($stop['code']) ?>)<?= $stop['festival'] ? ', festival day' : '' ?>. <?= $players ?> gnome<?= $players === 1 ? ' has' : 's have' ?> a ledger. Tastes <?= (int)($claims['table'] ?? 0) ?>, golden tables <?= (int)($claims['gold'] ?? 0) ?>, feasts <?= (int)($claims['grandpay'] ?? 0) ?>, finales <?= (int)($claims['finale'] ?? 0) ?>.</p>
<p><a class="btn small ghost" href="?tour=<?= e($prev) ?>">« <?= e($prev) ?></a> <b><?= e($tour) ?></b> <a class="btn small ghost" href="?tour=<?= e($next) ?>"><?= e($next) ?> »</a></p>
<table class="grid">
  <tr><th>Days</th><th>Region</th><th>Camp</th><th>Plate</th><th>Pot</th><th>Jar</th><th>Grand</th></tr>
  <?php foreach (gourmand_itinerary($tour) as $w): $menu = gourmand_menu($w['code'], $tour); ?>
    <tr><td><?= (int)$w['from'] ?>–<?= (int)$w['to'] ?></td>
      <td><?= e($w['town']) ?> <small class="help"><?= e($w['code']) ?></small></td>
      <td><small><?= e($w['camp']) ?></small></td>
      <?php foreach (['plate', 'pot', 'jar', 'grand'] as $c): $m = $menu[$c] ?? null; $l = $ledger[$w['code']][$c] ?? null; ?>
        <td><?php if ($m): ?><small><?= (int)$m['qty'] ?> × <?= e($itemName($m['item'])) ?><br><span class="help"><?= $l ? (int)$l['gnomes'] . ' gnome' . ((int)$l['gnomes'] === 1 ? '' : 's') . ', ' . (int)$l['served'] . ' served' : 'none served' ?></span></small><?php else: ?>–<?php endif; ?></td>
      <?php endforeach; ?></tr>
  <?php endforeach; ?>
</table>
<?php page_footer();
