<?php
declare(strict_types=1);
require __DIR__ . '/includes/bootstrap.php';
require_once __DIR__ . '/includes/garden_logic.php';
require_once __DIR__ . '/includes/town.php';
require_once __DIR__ . '/includes/items.php';
require_once __DIR__ . '/includes/shop_tiles.php';
require_once __DIR__ . '/includes/town_social.php';
$u = require_login();
$uid = (int)$u['id'];
$hub = !empty($_GET['hub']) || !empty($_POST['hub']);
$town = town_for($u, $hub);
$self = 'marketday.php' . ($hub ? '?hub=1' : '');

if (is_post()) {   // v1.0.0 wave 2b: the weekly market (stalls, wanted goods, best basket)
    csrf_check();
    $do = (string)($_POST['do'] ?? '');
    [$ok, $msg] = match ($do) {
        'buy' => market_stall_buy($u, $town, (int)($_POST['npc'] ?? 0), (int)($_POST['item'] ?? 0), (int)($_POST['qty'] ?? 1)),
        'sell' => market_sell_wanted($u, $town, (int)($_POST['item'] ?? 0), (int)($_POST['qty'] ?? 1)),
        'basket' => basket_enter($u, $town, (array)($_POST['items'] ?? [])),
        default => [false, 'Unknown action.'],
    };
    if ($msg !== '') flash($msg, $ok ? 'ok' : 'err');
    redirect($self);
}

$on = market_day_on();
$until = market_days_until();
$u = q_one('SELECT * FROM users WHERE id = ?', [$uid]);
$reach = can_reach($u, $town);
page_header('Market day');
?>
<p class="crumbs">🏘️ <a href="<?= e(url('town.php' . ($hub ? '?hub=1' : ''))) ?>"><?= e($town) ?> square</a> › <b>Market day</b></p>
<h1>🧺 Market day in <?= e($town) ?></h1>
<p class="status shopintro"><?= $on ? '🎪 <b>The market is open today.</b>' : ($until > 0 ? '🗓️ Next market day: <b>' . e(MARKET_WEEKDAYS[max(0, min(6, (int)setting('market_day')))]) . '</b>, in ' . $until . ' day' . ($until === 1 ? '' : 's') . '.' : ($until < 0 ? 'The market is switched off.' : '')) ?>
  · You have <b class="mycoins" data-coins="<?= (int)$u['coins'] ?>"><?= money((int)$u['coins']) ?></b></p>
<?php if (!$reach): ?><div class="flash err">🧭 This market is in <b><?= e($town) ?></b>. You need to be there to buy, sell or show a basket. <a href="<?= e(url('world.php')) ?>">Where to next →</a></div><?php endif; ?>

<?php
$wanted = market_wanted();
$wantedRows = [];
if ($wanted) {
    $ids = implode(',', array_map('intval', array_keys($wanted)));
    foreach (q("SELECT i.*, COALESCE(ui.qty, 0) AS have FROM items i LEFT JOIN user_items ui ON ui.item_id = i.id AND ui.user_id = ? WHERE i.id IN ($ids) ORDER BY i.name", [$uid])->fetchAll() as $r) $wantedRows[] = $r;
}
?>
<div class="box marketwanted">
  <h3>⭐ Wanted this week</h3>
  <p class="help">These goods fetch more from every shop all week<?= $on ? ', and a little more again today' : ', and a little more again on market day' ?>. Grow or cook a few ahead of time.</p>
  <?php if (!$wantedRows): ?><p class="muted">Nothing is especially wanted this week.</p><?php else: ?>
  <div class="shopwrap"><div class="itmwrap"><div class="itms">
    <?php foreach ($wantedRows as $r): $each = sell_price($r, $u); $have = (int)$r['have'];
        echo shop_tile(['id' => (int)$r['id'], 'item' => $r, 'price' => $each, 'max' => $have, 'priceHtml' => money($each), 'mini' => shop_mini(market_chip($r)), 'tags' => [market_chip($r)],
            'info' => '<p class="help">👜 You have ' . $have . '.</p><p class="help">About ' . money($each) . ' each: the shop works out the exact price.</p>', 'badge' => (string)$have, 'badgeTitle' => 'You have',
            'mode' => 'sell', 'action' => url($self), 'open' => $on && $reach && $have > 0, 'qtyName' => 'qty', 'each' => 'each, about', 'totalLabel' => 'About',
            'fields' => ['item' => (int)$r['id']] + ($hub ? ['hub' => 1] : [])]);
    endforeach; ?>
  </div></div></div>
  <p class="help">Shops pay the same prices, in every town. The ↑ ↓ marks on a shop’s Sell tab show what is up or down.</p>
  <?php endif; ?>
</div>

<?php if ($on): $stalls = market_stalls($town); ?>
<h2 class="shopintro">🎪 The stalls</h2>
<p class="help shopintro">Townsfolk set up stalls with different goods every market day. Each gnome may buy a few of each thing a day (<?= (int)setting('market_stall_limit') ?>).</p>
<?php if (!$stalls): ?><div class="box"><p class="muted">Nobody has set up a stall in <?= e($town) ?> today.</p></div><?php endif; ?>
<div class="mkstalls">
<?php foreach ($stalls as ['npc' => $n, 'goods' => $goods]): ?>
  <div class="box mkstall">
    <h3><?= npc_icon($n['species']) ?> <a href="<?= e(url('folk.php?id=' . (int)$n['id'])) ?>"><?= e($n['name']) ?></a>’s stall</h3>
    <div class="shopwrap"><div class="itmwrap"><div class="itms">
    <?php foreach ($goods as $g): $it = $g['item']; $had = market_bought_today($uid, (int)$n['id'], (int)$it['id']); $left = max(0, (int)setting('market_stall_limit') - $had);
        $info = ($had ? '<p class="help">You bought ' . $had . ' today.</p>' : '') . ($left < 1 ? '<p class="help">Sold out for you today.</p>' : '<p class="help">You can buy ' . $left . ' more today.</p>');
        echo shop_tile(['id' => (int)$it['id'], 'item' => $it, 'price' => (int)$g['price'], 'max' => $left, 'mini' => market_is_wanted((int)$it['id']) ? '⭐' : '', 'info' => $info,
            'badge' => $left > 0 ? (string)$left : '', 'badgeTitle' => 'You can buy', 'dim' => $left < 1, 'offNote' => 'Sold out today', 'coins' => $reach ? (int)$u['coins'] : null, 'mode' => 'buy', 'action' => url($self), 'open' => $reach && $left > 0, 'qtyName' => 'qty',
            'fields' => ['npc' => (int)$n['id'], 'item' => (int)$it['id']] + ($hub ? ['hub' => 1] : [])]);
    endforeach; ?>
    </div></div></div>
  </div>
<?php endforeach; ?>
</div>

<?php if (setting('basket_on') === '1'): $mine = basket_entry($uid); $rivals = basket_rivals($town); ?>
<h2 class="shopintro">🧺 Best-basket judging</h2>
<div class="box mkbasket">
  <?php if ($mine): $its = json_decode((string)$mine['items'], true) ?: []; ?>
    <p><b>Your basket scored <?= (int)$mine['score'] ?>.</b> <?= e(implode(', ', $its)) ?></p>
    <p>You beat <b><?= (int)$mine['beat'] ?></b> of 3 townsfolk baskets and won <?= money((int)$mine['coins']) ?>.</p>
    <ul class="rlist"><?php foreach ($rivals as $r): ?><li><span><?= npc_icon($r['npc']['species']) ?> <?= e($r['npc']['name']) ?></span> <small class="rtime"><?= (int)$r['score'] > (int)$mine['score'] ? '✖ ' : '✔ ' ?><?= (int)$r['score'] ?></small></li><?php endforeach; ?></ul>
    <p class="help">One basket a gnome a day. Come back next market day.</p>
  <?php else:
      $cand = q("SELECT i.*, ui.qty FROM user_items ui JOIN items i ON i.id = ui.item_id WHERE ui.user_id = ? AND ui.qty > 0 AND i.category IN ('produce','flower','food','forage','arrangement') ORDER BY i.category, i.name", [$uid])->fetchAll(); ?>
    <p>Choose up to <b>5 different things</b> to show. They are judged on quality, a mix of kinds and wanted goods, then compared with three townsfolk baskets. You keep everything. Prize: <?= e(implode(' / ', array_map(fn($i) => number_format(basket_reward($i)), [0, 1, 2, 3]))) ?> <?= e(setting('currency_name')) ?> for beating 0 / 1 / 2 / 3 baskets.</p>
    <?php if (!$cand): ?><p class="muted">Your Satchel has no crops, flowers, dishes, finds or arrangements to show.</p>
    <?php elseif ($reach): ?>
      <form method="post" action="<?= e(url($self)) ?>"><?= csrf_field() ?><input type="hidden" name="do" value="basket"><?php if ($hub): ?><input type="hidden" name="hub" value="1"><?php endif; ?>
        <div class="mkpick">
          <?php foreach ($cand as $c): $q = $c['category'] === 'produce' ? market_stack_q($uid, (int)$c['id'], (int)$c['qty']) : ($c['category'] === 'arrangement' ? (int)basket_item_points($uid, $c) : null); ?>
            <label class="mkopt"><input type="checkbox" name="items[]" value="<?= (int)$c['id'] ?>"> <span class="iicon"><?= item_icon($c) ?></span> <?= e($c['name']) ?><?= $q !== null ? ' <small class="muted">' . ($c['category'] === 'produce' ? 'grade ' . e(market_grade($q)) . ' · ' : '') . $q . '</small>' : '' ?><?= market_is_wanted((int)$c['id']) ? ' ⭐' : '' ?></label>
          <?php endforeach; ?>
        </div>
        <p><button class="btn">Show my basket</button></p>
      </form>
    <?php endif; ?>
  <?php endif; ?>
</div>
<?php endif; ?>
<?php endif; ?>

<p><a class="btn alt" href="<?= e(url('jobs.php?t=orders' . ($hub ? '&hub=1' : '') . '#orders')) ?>">📜 Order board</a>
  <a class="btn alt" href="<?= e(url('world.php?tab=markets')) ?>">🏪 Shops</a></p>
<?php page_footer();
