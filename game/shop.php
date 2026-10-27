<?php
declare(strict_types=1);
require __DIR__ . '/includes/bootstrap.php';
require_once __DIR__ . '/includes/scene.php';   // v2.0.46
require_once __DIR__ . '/includes/garden_logic.php';
require_once __DIR__ . '/includes/adventure.php';
require_once __DIR__ . '/includes/items.php';
require_once __DIR__ . '/includes/shop_tiles.php';
$u = require_login();

$shop = q_one('SELECT * FROM shops WHERE id = ? AND open = 1', [(int)($_GET['id'] ?? 0)]);
if (!$shop) {
    if (active_expedition((int)$u['id'])) {   // v0.9.1a: say why, while walking
        flash('You’re on the road; shops wait until you arrive.', 'err');
        redirect('adventure.php');
    }
    flash('That shop doesn’t exist or is closed.', 'err');
    redirect('world.php');
}
$sid = (int)$shop['id'];
$tab = ($_GET['tab'] ?? '') === 'sell' ? 'sell' : 'buy';   // v0.7.61: Buy and Sell tabs, each with a basket
$shopTown = $shop['location_id'] ? q_one('SELECT id, name, region FROM locations WHERE id = ?', [$shop['location_id']]) : null;
$reachable = shop_reachable($u, $shop);

if (is_post()) {
    csrf_check();
    $do = (string)($_POST['do'] ?? '');
    if (str_starts_with($do, 'flo_')) {   // v0.9.9: volunteering at a florist
        require_once __DIR__ . '/includes/flowers.php';
        refresh_energy($u);
        [$ok, $msg] = florist_post($u, $shop, $do);
        flash($msg, $ok ? 'ok' : 'err');
        redirect('shop.php?id=' . $sid . '#volunteer');
    }
    if (str_starts_with($do, 'sink_')) {   // v0.9.7: the Curio Cabinet and the Dye Pot
        [$ok, $msg] = sink_shop_post($u, $shop, $do, $reachable);
        flash($msg, $ok ? 'ok' : 'err');
        redirect('shop.php?id=' . $sid);
    }
    $want = [];
    foreach ((array)($_POST['qty'] ?? []) as $id => $n) {
        if ((int)$id > 0 && (int)$n > 0) $want[(int)$id] = min(999, (int)$n);
    }
    $want = array_slice($want, 0, 200, true);
    if (!$reachable) {
        flash('You need to be in ' . ($shopTown['name'] ?? 'that town') . ' to shop here.', 'err');
    } elseif (!$want) {
        flash('Your basket is empty. Tap something, then choose how many.', 'err');
    } elseif (!staff_on_duty($sid)) {
        flash('Nobody is at the counter right now.', 'err');
    } elseif ($do === 'buy') {
        $got = []; $spent = 0; $errs = [];
        foreach ($want as $stockId => $n) {
            if ((int)q_val('SELECT shop_id FROM shop_stock WHERE id = ?', [$stockId]) !== $sid) { $errs[] = 'Something in your basket isn’t sold here.'; continue; }
            [$ok, $msg, $cost, $name] = buy_from_shop($u, $stockId, $n) + [2 => 0, 3 => ''];
            if ($ok) { $got[] = $n . ' × ' . $name; $spent += $cost; }
            else { $errs[] = $msg; if (str_contains($msg, 'afford')) break; }
        }
        if ($got) flash('🛒 You buy ' . implode(', ', $got) . ' for ' . number_format($spent) . ' ' . setting('currency_name') . '.');
        foreach (array_unique($errs) as $m) flash($m, 'err');
    } elseif ($do === 'sell') {
        $got = []; $earned = 0; $errs = [];
        foreach ($want as $itemId => $n) {
            [$ok, $msg, $total, $name] = sell_to_shop($u, $itemId, $n, $sid) + [2 => 0, 3 => ''];
            if ($ok) { $got[] = $n . ' × ' . $name; $earned += $total; }
            else $errs[] = $msg;
        }
        if ($got) flash('💰 You sell ' . implode(', ', $got) . ' for ' . number_format($earned) . ' ' . setting('currency_name') . '.');
        foreach (array_unique($errs) as $m) flash($m, 'err');
    }
    redirect('shop.php?id=' . $sid . ($tab === 'sell' || $do === 'sell' ? '&tab=sell' : ''));
}

shop_restock($sid);
$staff = staff_on_duty($sid);
foreach ($staff as $n) {
    unlock_entries((int)$u['id'], 'npc:' . $n['slug']);   // meeting someone can fill in their Almanac page
}
require_once __DIR__ . '/includes/folk_list.php';
npc_meet((int)$u['id'], array_column($staff, 'id'));   // v0.7.69: you've met whoever is at the counter
$known = known_plants($u);
require_once __DIR__ . '/includes/friends.php';
$friendOff = friend_discount((int)$u['id'], $sid);
$readGuides = array_fill_keys(q('SELECT guide_key FROM user_guides WHERE user_id = ?', [$u['id']])->fetchAll(PDO::FETCH_COLUMN), true);
$owned = [];
foreach (q('SELECT item_id, qty FROM user_items WHERE user_id = ? AND qty > 0', [$u['id']])->fetchAll() as $r) $owned[(int)$r['item_id']] = (int)$r['qty'];
$IL = item_lookups();
$fresh = (int)q_val('SELECT coins FROM users WHERE id = ?', [$u['id']]);
$open = $reachable && $staff;

page_header($shop['name']);
?>
<p class="crumbs">🌍 <a href="<?= e(url('world.php?tab=markets')) ?>">Shops</a> › <b><?= e($shop['name']) ?></b><?= $shopTown ? ' <span class="muted">in ' . e($shopTown['name']) . '</span>' : '' ?></p>
<?php require_once __DIR__ . '/includes/place_ui.php';   // v2.0.65: the shop gets the same place header as the stops (interior art, kind, name, its line)
$shopKind = ['seeds' => 'Seed shop', 'food' => 'Kitchen', 'decor' => 'Home & curios', 'dyes' => 'Dye shop', 'florist' => 'Florist'][(string)($shop['shop_type'] ?? '')] ?? 'Shop';
$shopArt = scene_shop_key($shop); ?>
<?= place_header_html($shopArt !== '' ? 'shop-' . $shopArt . '.png' : '', 'Inside ' . $shop['name'], $shopKind . ($shopTown ? ' · ' . $shopTown['name'] : ''), (string)$shop['name'], (string)$shop['description']) ?>
<p class="status shopintro">
  <?= $staff ? '🧑‍🌾 At the counter: ' . implode(', ', array_map(fn($n) => '<a href="' . e(url('folk.php?id=' . (int)$n['id'])) . '">' . e($n['name']) . '</a> the ' . e(strtolower($n['personality']) . ' ' . strtolower($n['species'])), $staff)) . ' <span class="muted">(tap a name to chat)</span>' : '🚪 Nobody is on shift. Come back later.' ?>
  · You have <b class="mycoins" data-coins="<?= $fresh ?>"><?= money($fresh) ?></b>
</p>

<?php if (!$reachable): ?>
  <div class="flash err">🧭 This shop is in <b><?= e($shopTown['name'] ?? '?') ?></b> (<?= e((string)($shopTown['region'] ?? '')) ?>). You can look at the shelves, but you need to be there to buy or sell. <a href="<?= e(url('world.php')) ?>">Where to next →</a></div>
<?php endif; ?>

<?php   // v0.9.7: special panels (Curio Cabinet at the Hedge & Hearth; the Dye Pot has only its pots)
echo sink_shop_panel($u, $shop, $open);
if (sink_shop_kind($shop) === 'dye') { page_footer(); exit; }
if (($shop['shop_type'] ?? '') === 'florist') { require_once __DIR__ . '/includes/flowers.php'; echo florist_panel($u, $shop, (bool)$open); }   // v0.9.9
?>
<nav class="tabs">
  <a class="<?= $tab === 'buy' ? 'on' : '' ?>" href="<?= e(url('shop.php?id=' . $sid)) ?>">🛒 Buy</a>
  <a class="<?= $tab === 'sell' ? 'on' : '' ?>" href="<?= e(url('shop.php?id=' . $sid . '&tab=sell')) ?>">💰 Sell</a>
</nav>


<?php if ($tab === 'buy'):
    $stock = q('SELECT st.*, i.id AS iid, i.name, i.slug, i.category, i.description, i.rarity, i.effects, i.base_price, p.id AS plant_id, p.seasons AS plant_seasons FROM shop_stock st
                JOIN items i ON i.id = st.item_id LEFT JOIN plants p ON p.seed_item_id = i.id
                WHERE st.shop_id = ? AND st.current_stock > 0 ORDER BY i.category, i.name', [$sid])->fetchAll();
    usort($stock, fn($a, $b) => [shop_cat_rank($a), $a['name']] <=> [shop_cat_rank($b), $b['name']]);   // v0.7.83: grouped in chip order ?>
  <div class="shopwrap">
  <?= $open ? shop_basket_html('buy', url('shop.php?id=' . $sid)) : '' ?>
  <?= shop_chips($stock) ?>
  <div class="itmwrap"><div class="itms">
  <?php foreach ($stock as $s):
      $item = ['id' => $s['iid']] + $s;
      $unknown = $s['plant_id'] && !isset($known[(int)$s['plant_id']]);
      $gkey = $s['category'] === 'guide' ? (string)((json_decode((string)$s['effects'], true) ?: [])['guide'] ?? '') : '';
      $read = $gkey !== '' && isset($readGuides[$gkey]);
      $myPrice = shop_price($u, (int)$s['current_price'], $sid, (int)$s['iid']);   // v1.0.0: seasonal seeds and crops follow the season a little
      $tags = [];
      $bc = market_buy_chip((int)$s['iid']);
      $sc = $s['plant_id'] ? season_chip(['seasons' => (string)$s['plant_seasons']]) : '';   // v1.0.0: in season / off season
      if ($bc !== '' && $sc !== '') {   // v1.7.5: one tag per row: the crop season plus what it does to the price
          $arrow = str_contains($bc, '↓') ? '↓' : '↑';
          $tags[] = '<span class="tag ' . ($arrow === '↓' ? 'down' : 'up') . '" title="' . (str_contains($sc, 'chip-in') ? 'In season: grows faster and gives a little more, and shops charge a little less' : 'Off season: grows slower, and shops charge a little more') . '">'
              . (str_contains($sc, 'chip-in') ? '🌿 in season' : '🍂 off season') . ' · price ' . $arrow . '</span>';
      } elseif ($bc !== '') $tags[] = $bc;
      elseif ($sc !== '') $tags[] = $sc;
      if ($read) $tags[] = '<span class="tag good">✔ read</span>';
      elseif ($gkey !== '' && !empty($owned[(int)$s['iid']])) $tags[] = '<span class="tag">in satchel</span>';
      if ($unknown) $tags[] = '<span class="tag" title="Unstudied: grows slower and gives less until you study its region">📕 unstudied <small class="muted">grows slower</small></span>';
      $info = item_origin_html($item, $IL)   // v0.9.0: Staple: Region
          . ($read ? '<p class="good">✔ You’ve already read this guide. No need to buy it again.</p>' : '')
          . ($unknown ? '<p class="help">📕 Unstudied: you can plant it, but it grows ' . unstudied_slow_pct($u) . '% slower and gives ' . (100 - unstudied_yield_pct($u)) . '% less until you study its region (this guide, or the region’s questline in Almanac → Journey) or master the crop.</p>' : '')
          . (!empty($owned[(int)$s['iid']]) ? '<p class="help">👜 You have ' . (int)$owned[(int)$s['iid']] . '.</p>' : '')
          . '<p class="help">' . (int)$s['current_stock'] . ' on the shelf</p>';
      $priceHtml = money($myPrice) . ($myPrice < (int)$s['current_price'] ? ' <s class="muted">' . number_format((int)$s['current_price']) . '</s>' : '');
      echo shop_tile(['id' => (int)$s['id'], 'item' => $item, 'price' => $myPrice, 'max' => (int)$s['current_stock'], 'priceHtml' => $priceHtml, 'mini' => shop_mini(implode(' ', $tags)),
          'tags' => $tags, 'info' => $info, 'dim' => $read, 'offNote' => $read ? '✔ Read' : '', 'badge' => (string)(int)$s['current_stock'], 'mode' => 'buy', 'action' => url('shop.php?id=' . $sid), 'open' => (bool)$open, 'basket' => true,
          'coins' => $open ? $fresh : null]);
  endforeach; ?>
  </div></div>
  </div>
  <?php if ($stock && $friendOff): ?><p class="help">💛 Prices include your friends discount.</p><?php endif; ?>
  <?php if (!$stock): ?><p class="muted">The shelves are bare. New stock arrives every <?= (int)$shop['restock_minutes'] ?> minutes or so.</p><?php endif; ?>

<?php else:
    $sellable = q("SELECT i.id, i.name, i.slug, i.base_price, i.category, i.description, i.rarity, i.effects, ui.qty FROM user_items ui JOIN items i ON i.id = ui.item_id
                   WHERE ui.user_id = ? AND ui.qty > 0 AND i.category IN ('produce','flower','food','part','forage','arrangement','packet') ORDER BY i.category, i.name", [$u['id']])->fetchAll(); ?>
  <?php $sellBonus = shop_sell_bonus((int)$u['id'], $sid); ?>
  <details class="helpfold shophelp"><summary>ℹ️ What sells here</summary><p class="help">Shopkeepers buy crops, flowers, arrangements, food, creature parts and finds. Rarer things fetch much more. Prices drift: ↑ pays more than usual (wanted, out of season), ↓ pays less (in season, or lots sold lately).</p></details>
  <?= $sellBonus ? '<p class="help">🧭 Your Journey project here: ' . $sellBonus . '% extra.</p>' : '' ?>
  <div class="shopwrap">
  <?= $open ? shop_basket_html('sell', url('shop.php?id=' . $sid . '&tab=sell')) : '' ?>
  <?= shop_chips($sellable) ?>
  <div class="itmwrap"><div class="itms">
  <?php foreach ($sellable as $i):
      $p = sell_price_with_bonus($i, $u, $sellBonus);
      $mc = market_chip($i);   // v1.0.0: ↑/↓ and ⭐ wanted
      $info = item_origin_html($i, $IL) . '<p class="help">👜 You have ' . (int)$i['qty'] . '</p>';
      echo shop_tile(['id' => (int)$i['id'], 'item' => $i, 'price' => $p, 'max' => (int)$i['qty'], 'priceHtml' => money($p), 'mini' => shop_mini($mc), 'tags' => $mc !== '' ? [$mc] : [],
          'info' => $info, 'badge' => (string)(int)$i['qty'], 'mode' => 'sell', 'action' => url('shop.php?id=' . $sid . '&tab=sell'), 'open' => (bool)$open, 'basket' => true]);
  endforeach; ?>
  </div></div>
  </div>
  <?php if (!$sellable): ?><p class="muted">Nothing in your satchel this shop would buy.</p><?php endif; ?>
<?php endif; ?>
<?php page_footer();
