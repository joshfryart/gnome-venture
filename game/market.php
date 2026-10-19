<?php
declare(strict_types=1);
require __DIR__ . '/includes/bootstrap.php';
require_once __DIR__ . '/includes/garden_logic.php';
require_once __DIR__ . '/includes/trade.php';
require_once __DIR__ . '/includes/items.php';   // v0.9.1a: item_origin_html on the stalls
$u = require_login();
$uid = (int)$u['id'];
expire_offers();

const MARKET_TABS = ['buy' => '🛒 Market', 'stall' => '🏷️ My stall', 'trades' => '🤝 Trades', 'gifts' => '🎁 Gifts', 'saplings' => '🌱 Saplings'];
$tab = (string)($_GET['t'] ?? 'buy');
if (!isset(MARKET_TABS[$tab])) $tab = 'buy';

if (is_post()) {
    csrf_check();
    refresh_energy($u);
    $do = (string)($_POST['do'] ?? '');
    $back = 'market.php?t=' . $tab;
    $res = match ($do) {
        'buy' => buy_listing($u, (int)($_POST['id'] ?? 0), (int)($_POST['qty'] ?? 1)),
        'list' => list_for_sale($u, (int)($_POST['item_id'] ?? 0), (int)($_POST['qty'] ?? 0), (int)($_POST['price'] ?? 0)),
        'unlist' => unlist($u, (int)($_POST['id'] ?? 0)),
        'gift' => send_gift($u, (string)($_POST['to'] ?? ''), (int)($_POST['item_id'] ?? 0), (int)($_POST['qty'] ?? 0), (int)($_POST['coins'] ?? 0), (string)($_POST['note'] ?? '')),
        'offer' => make_offer($u, (int)($_POST['to_id'] ?? 0),
            trade_lines((array)($_POST['give_id'] ?? []), (array)($_POST['give_qty'] ?? [])), (int)($_POST['give_coins'] ?? 0),
            trade_lines((array)($_POST['want_id'] ?? []), (array)($_POST['want_qty'] ?? [])), (int)($_POST['want_coins'] ?? 0), (string)($_POST['note'] ?? '')),
        'answer' => answer_offer($u, (int)($_POST['id'] ?? 0), (string)($_POST['answer'] ?? '')),
        'sapling' => raise_sapling($u, (int)($_POST['plant_id'] ?? 0)),
        default => [false, 'Unknown action.'],
    };
    flash($res[1], $res[0] ? 'ok' : 'err');
    redirect($back);
}

/** The player's tradable items for a select box. */
function my_tradables(int $uid): array
{
    return q("SELECT i.id, i.name, ui.qty FROM user_items ui JOIN items i ON i.id = ui.item_id
              WHERE ui.user_id = ? AND ui.qty > 0 AND i.tradable = 1 ORDER BY i.name", [$uid])->fetchAll();
}

function item_options(array $rows, bool $blank = false): string
{
    $o = $blank ? '<option value="0">—</option>' : '';
    foreach ($rows as $r) $o .= '<option value="' . (int)$r['id'] . '">' . e($r['name']) . ' (' . (int)$r['qty'] . ')</option>';
    return $o;
}

page_header('Trading Post');
?>
<h1>🏪 Trading Post</h1>
<nav class="tabs crafttabs">
  <?php foreach (MARKET_TABS as $k => $label): ?><a class="<?= $k === $tab ? 'on' : '' ?>" href="<?= e(url('market.php?t=' . $k)) ?>"><?= $label ?></a><?php endforeach; ?>
</nav>
<?php if (($why = trade_allowed($u) ?: fresh_hold($u)) && $tab !== 'saplings'): ?>   <?php /* v1.0.1: fresh gnome hold shows here instead of the forms */ ?>
  <div class="box notice"><?= e($why) ?> Until then you can still raise saplings once you’ve mastered a plant.</div>
<?php endif; ?>

<?php if ($tab === 'buy'):
    $search = mb_substr(trim((string)($_GET['q'] ?? '')), 0, 40);
    $rows = q("SELECT l.*, i.name, i.category, COALESCE(s.gnome_name, s.username) AS seller FROM stall_listings l
               JOIN items i ON i.id = l.item_id JOIN users s ON s.id = l.seller_id
               WHERE l.qty > 0 AND " . gnome_in_play_sql('s') . ($search !== '' ? ' AND LOWER(i.name) LIKE ?' : '') . ' ORDER BY i.name, l.price LIMIT 60',
        $search !== '' ? ['%' . mb_strtolower($search) . '%'] : [])->fetchAll();
    $IL = item_lookups(); ?>
  <form method="get" class="inline search"><input type="hidden" name="t" value="buy">
    <input name="q" value="<?= e($search) ?>" placeholder="Search: radish, sapling, geode…"> <button class="btn small">Search</button></form>
  <?php if (!$rows): ?><p class="muted">Nothing for sale<?= $search !== '' ? ' matching “' . e($search) . '”' : '' ?> yet. Be the first: put something on your stall!</p>
  <?php else: ?>
    <table class="grid market">
      <tr><th>Item</th><th>Seller</th><th>Each</th><th>Available</th><th></th></tr>
      <?php foreach ($rows as $r): ?>
        <tr><td><?= item_pic(['id' => $r['item_id']], 'sm') ?><?= e($r['name']) ?> <span class="muted">(<?= e($r['category']) ?>)</span><?= item_origin_html(['id' => $r['item_id'], 'category' => $r['category']], $IL) ?></td><td><?= profile_link(['id' => $r['seller_id']], (string)$r['seller']) ?></td>
          <td><?= money((int)$r['price']) ?></td><td><?= (int)$r['qty'] ?></td>
          <td><?php if ((int)$r['seller_id'] !== $uid && !$why): ?>
            <form method="post" class="inline" action="<?= e(url('market.php?t=buy')) ?>"><?= csrf_field() ?><input type="hidden" name="do" value="buy"><input type="hidden" name="id" value="<?= (int)$r['id'] ?>">
              <input type="number" name="qty" value="1" min="1" max="<?= (int)$r['qty'] ?>" class="qty"> <button class="btn small">Buy</button></form>
          <?php elseif ((int)$r['seller_id'] === $uid): ?><span class="muted">yours</span><?php endif; ?></td></tr>
      <?php endforeach; ?>
    </table>
  <?php endif; ?>

<?php elseif ($tab === 'stall'):
    $mine = q('SELECT l.*, i.name FROM stall_listings l JOIN items i ON i.id = l.item_id WHERE l.seller_id = ? AND (l.qty > 0 OR l.sold > 0) ORDER BY l.qty = 0, l.id DESC LIMIT 30', [$uid])->fetchAll(); ?>
  <div class="box">
    <p class="help">Put things on your stall at your own price. Other gnomes buy them any time, even while you’re away, and the money comes straight to you
      (less a <?= (int)setting('stall_tax_percent') ?>% market fee). Up to <?= (int)setting('stall_slots') ?> listings.</p>
    <?php if (!$why): ?>
    <form method="post" class="form inline" action="<?= e(url('market.php?t=stall')) ?>"><?= csrf_field() ?><input type="hidden" name="do" value="list">
      <label>Item <select name="item_id"><?= item_options(my_tradables($uid)) ?></select></label>
      <label>How many <input type="number" name="qty" value="1" min="1" class="qty"></label>
      <label>Price each <input type="number" name="price" value="10" min="1" class="qty"></label>
      <button class="btn small">Put on stall</button></form>
    <?php endif; ?>
  </div>
  <?php if ($mine): ?>
    <table class="grid">
      <tr><th>Item</th><th>Price each</th><th>Left</th><th>Sold</th><th></th></tr>
      <?php foreach ($mine as $l): ?>
        <tr><td><?= item_pic(['id' => $l['item_id'] ?? 0, 'name' => $l['name']], 'sm') ?><?= e($l['name']) ?></td><td><?= money((int)$l['price']) ?></td><td><?= (int)$l['qty'] ?></td><td><?= (int)$l['sold'] ?></td>
          <td><?php if ((int)$l['qty'] > 0): ?><form method="post" action="<?= e(url('market.php?t=stall')) ?>"><?= csrf_field() ?><input type="hidden" name="do" value="unlist"><input type="hidden" name="id" value="<?= (int)$l['id'] ?>">
            <button class="btn small alt">Take down</button></form><?php else: ?><span class="muted">sold out</span><?php endif; ?></td></tr>
      <?php endforeach; ?>
    </table>
  <?php endif; ?>

<?php elseif ($tab === 'trades'):
    $to = isset($_GET['to']) ? find_player((string)$_GET['to'], $uid) : null;
    $offers = q("SELECT o.*, COALESCE(f.gnome_name, f.username) AS from_name, COALESCE(t.gnome_name, t.username) AS to_name FROM trade_offers o
                 JOIN users f ON f.id = o.from_id JOIN users t ON t.id = o.to_id
                 WHERE (o.from_id = ? OR o.to_id = ?) AND (o.status = 'open' OR o.closed_at > ?) ORDER BY o.status = 'open' DESC, o.id DESC LIMIT 20",
        [$uid, $uid, gmdate('Y-m-d H:i:s', time() - 7 * 86400)])->fetchAll(); ?>
  <?php foreach ($offers as $o):
      $in = (int)$o['to_id'] === $uid;
      $gives = json_decode((string)$o['give_items'], true) ?: [];
      $wants = json_decode((string)$o['want_items'], true) ?: []; ?>
    <div class="box offer <?= $o['status'] ?>">
      <?= implode('', array_map(fn($id) => item_pic(['id' => (int)$id], 'sm'), array_keys($gives + $wants))) ?><b><?= $in ? e($o['from_name']) . ' offers you' : 'You offer ' . e($o['to_name']) ?></b> <?= e(trade_text($gives, (int)$o['give_coins'])) ?>
      <b>for</b> <?= e(trade_text($wants, (int)$o['want_coins'])) ?>.
      <?= $o['note'] ? '<span class="muted">“' . e($o['note']) . '”</span>' . ($in ? report_link((int)$o['from_id'], 'offer', (int)$o['id']) : '') : '' ?>
      <?php if ($o['status'] === 'open'): ?>
        <form method="post" class="inline" action="<?= e(url('market.php?t=trades')) ?>"><?= csrf_field() ?><input type="hidden" name="do" value="answer"><input type="hidden" name="id" value="<?= (int)$o['id'] ?>">
          <?php if ($in): ?><button class="btn small" name="answer" value="accept">Accept</button> <button class="btn small alt" name="answer" value="decline">Decline</button>
          <?php else: ?><button class="btn small alt" name="answer" value="cancel">Cancel offer</button><?php endif; ?></form>
      <?php else: ?><span class="tag"><?= e($o['status']) ?></span><?php endif; ?>
    </div>
  <?php endforeach; ?>
  <div class="box">
    <h3>Make a trade offer</h3>
    <?php if ($why): ?><p class="muted"><?= e($why) ?></p>
    <?php elseif (!$to): ?>
      <form method="get" class="inline"><input type="hidden" name="t" value="trades">
        <label>Trade with (gnome name) <input name="to" value="<?= e((string)($_GET['to'] ?? '')) ?>" required maxlength="30"></label> <button class="btn small">Next</button></form>
      <?php if (isset($_GET['to'])): ?><p class="flash err">No gnome by that name.</p><?php endif; ?>
    <?php else: $theirs = q("SELECT i.id, i.name, ui.qty FROM user_items ui JOIN items i ON i.id = ui.item_id WHERE ui.user_id = ? AND ui.qty > 0 AND i.tradable = 1 ORDER BY i.name", [$to['id']])->fetchAll(); ?>
      <form method="post" class="form tradeform" action="<?= e(url('market.php?t=trades')) ?>"><?= csrf_field() ?><input type="hidden" name="do" value="offer"><input type="hidden" name="to_id" value="<?= (int)$to['id'] ?>">
        <p>Trading with <b><?= e(pname($to)) ?></b>. What you offer is held until they answer (or <?= (int)setting('trade_offer_days') ?> days pass).</p>
        <div class="tradecols">
          <div><h4>You give</h4>
            <?php for ($k = 0; $k < 3; $k++): ?><div><select name="give_id[]"><?= item_options(my_tradables($uid), true) ?></select> × <input type="number" name="give_qty[]" value="1" min="1" class="qty"></div><?php endfor; ?>
            <label>Petals <input type="number" name="give_coins" value="0" min="0" class="qty"></label></div>
          <div><h4>You want</h4>
            <?php for ($k = 0; $k < 3; $k++): ?><div><select name="want_id[]"><?= item_options($theirs, true) ?></select> × <input type="number" name="want_qty[]" value="1" min="1" class="qty"></div><?php endfor; ?>
            <label>Petals <input type="number" name="want_coins" value="0" min="0" class="qty"></label></div>
        </div>
        <label>Note (optional) <input name="note" maxlength="140"></label>
        <button class="btn small">Send offer</button></form>
    <?php endif; ?>
  </div>

<?php elseif ($tab === 'gifts'):
    $recent = q("SELECT g.*, i.name AS item_name, COALESCE(f.gnome_name, f.username) AS from_name, COALESCE(t.gnome_name, t.username) AS to_name
                 FROM gifts g LEFT JOIN items i ON i.id = g.item_id JOIN users f ON f.id = g.from_id JOIN users t ON t.id = g.to_id
                 WHERE g.from_id = ? OR g.to_id = ? ORDER BY g.id DESC LIMIT 15", [$uid, $uid])->fetchAll(); ?>
  <div class="box">
    <h3>Send a gift</h3>
    <?php if ($why): ?><p class="muted"><?= e($why) ?></p><?php else: ?>
    <form method="post" class="form" action="<?= e(url('market.php?t=gifts')) ?>"><?= csrf_field() ?><input type="hidden" name="do" value="gift">
      <label>To (gnome name) <input name="to" required maxlength="30"></label>
      <label>Item <select name="item_id"><?= item_options(my_tradables($uid), true) ?></select> × <input type="number" name="qty" value="1" min="1" class="qty"></label>
      <label>Petals <input type="number" name="coins" value="0" min="0" class="qty"></label>
      <label>Note (optional) <input name="note" maxlength="140"></label>
      <button class="btn small">Send gift</button></form>
    <p class="help">Up to <?= (int)setting('gifts_per_day') ?> gifts a day.</p>
    <?php endif; ?>
  </div>
  <?php if ($recent): ?>
    <table class="grid"><tr><th></th><th>Gift</th><th>When</th></tr>
      <?php foreach ($recent as $g): $out = (int)$g['from_id'] === $uid; ?>
        <tr><td><?= $out ? 'To ' . e($g['to_name']) : 'From ' . e($g['from_name']) ?></td>
          <td><?= item_pic(['id' => $g['item_id'] ?? 0, 'name' => (string)$g['item_name']], 'sm') ?><?= e(trim(($g['item_name'] ? (int)$g['qty'] . ' × ' . $g['item_name'] : '') . ((int)$g['coins'] ? ' ' . money((int)$g['coins']) : ''))) ?><?= $g['note'] ? ' <span class="muted">“' . e($g['note']) . '”</span>' . (!$out ? report_link((int)$g['from_id'], 'gift', (int)$g['id']) : '') : '' ?></td>
          <td><?= e(substr((string)$g['sent_at'], 0, 10)) ?></td></tr>
      <?php endforeach; ?></table>
  <?php endif; ?>

<?php else: $mastered = mastered_plants($uid); $left = saplings_left_today($u); ?>
  <div class="box">
    <p class="help">Master a plant (full knowledge from harvesting it) and you can raise saplings from its seeds: 1 seed and ⚡<?= (int)setting('sapling_energy') ?> each,
      up to <?= (int)setting('saplings_per_day') ?> a day (<?= $left ?> left today). Anyone can plant a sapling, even a crop they don’t know yet, and it starts
      <?= (int)setting('sapling_head_start') ?>% grown. Sell them on your stall, trade them, or give them to friends.</p>
    <?php if (!$mastered): ?><p class="muted">You haven’t mastered any plants yet. Keep harvesting the same crop and watch its knowledge in your Almanac.</p>
    <?php else: ?>
      <table class="grid"><tr><th>Plant</th><th>Seeds you have</th><th></th></tr>
        <?php foreach ($mastered as $m): ?>
          <tr><td>⭐ <?= e($m['name']) ?></td><td><?= (int)$m['seeds'] ?></td>
            <td><form method="post" action="<?= e(url('market.php?t=saplings')) ?>"><?= csrf_field() ?><input type="hidden" name="do" value="sapling"><input type="hidden" name="plant_id" value="<?= (int)$m['id'] ?>">
              <button class="btn small" <?= (int)$m['seeds'] > 0 && $left > 0 ? '' : 'disabled' ?>>Raise a sapling</button></form></td></tr>
        <?php endforeach; ?></table>
    <?php endif; ?>
  </div>
<?php endif; ?>
<?php page_footer();
