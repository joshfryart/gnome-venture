<?php
declare(strict_types=1);
require __DIR__ . '/includes/bootstrap.php';
require_once __DIR__ . '/includes/garden_logic.php';
require_once __DIR__ . '/includes/adventure.php';
require_once __DIR__ . '/includes/items.php';
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
<h1><?= e($shop['name']) ?></h1>
<p class="shopintro"><?= e($shop['description']) ?></p>
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

<?php
/** One tile in the basket grid. $tags: small notes; $info: escaped HTML for the details box. */
// v0.7.83: shelves grouped by type, with chips that filter in place (the basket keeps what you picked)
const SHOP_CATS = ['seed' => '🌱 Seeds', 'produce' => '🥕 Crops', 'flower' => '🌸 Flowers', 'food' => '🍲 Food', 'soil' => '🪱 Soil', 'mulch' => '🍂 Mulch',
    'supply' => '🧪 Supplies', 'tool' => '🧰 Tools', 'guide' => '📗 Guides', 'forage' => '🍄 Finds', 'part' => '🦴 Parts', 'decor' => '🏡 Decor', 'arrangement' => '💐 Arrangements', 'packet' => '📦 Seed packets'];
$catOf = fn(string $c): string => isset(SHOP_CATS[$c]) ? $c : 'other';
$catRank = fn(array $r): int => (int)array_search($catOf((string)$r['category']), array_keys(SHOP_CATS + ['other' => 1]), true);
$chips = function (array $rows) use ($catOf): string {
    $n = [];
    foreach ($rows as $r) { $k = $catOf((string)$r['category']); $n[$k] = ($n[$k] ?? 0) + 1; }
    if (count($n) < 2) return '';
    $h = '<nav class="chips shopcats" aria-label="Show"><button type="button" class="on" data-cat="all">All <small>' . count($rows) . '</small></button>';
    foreach (SHOP_CATS + ['other' => '📦 Other'] as $k => $label) if (!empty($n[$k])) $h .= '<button type="button" data-cat="' . $k . '">' . $label . ' <small>' . $n[$k] . '</small></button>';
    return $h . '</nav>';
};
// v1.9.8: tiles like the Satchel (picture, name, small price, count badge). Tap one: a sheet (<dialog>) with the details and the Buy/Sell form.
$tile = function (int $id, array $i, int $price, int $max, string $priceHtml, string $mini, array $tags, string $info, bool $dim = false, string $badge = '', string $mode = 'buy', string $action = '') use ($IL, $open, $catOf): string {
    [$rl, $rw] = item_rarity($i, $IL);
    $desc = (string)($i['description'] ?? '');
    $descH = $desc === '' ? '' : (mb_strlen($desc) > 90
        ? '<details class="helpfold sdesc"><summary>About it</summary><p>' . desc_html($desc) . '</p></details>'
        : '<p class="sdesc">' . desc_html($desc) . '</p>');
    $verb = $mode === 'buy' ? 'Buy' : 'Sell';
    $form = !$open ? '' : '<form method="post" class="sheetform" data-mode="' . $mode . '" data-price="' . $price . '" data-max="' . $max . '" action="' . e($action) . '">' . csrf_field()
        . '<input type="hidden" name="do" value="' . $mode . '">'
        . '<div class="qctl"><button type="button" class="qbtn" data-q="-1" aria-label="One less">−</button>'
        . '<input type="number" class="qin" name="qty[' . $id . ']" value="1" min="1" max="' . $max . '" inputmode="numeric" aria-label="How many">'
        . '<button type="button" class="qbtn" data-q="1" aria-label="One more">+</button>'
        . '<button type="button" class="qbtn qmax" data-q="max">All</button></div>'
        . '<p class="sline"><span>' . $priceHtml . ' each</span> · <b class="stot" data-lbl="' . ($mode === 'buy' ? 'Total' : 'You get') . '"></b></p>'
        . '<p class="sbad" hidden></p>'
        . '<button class="btn sgo">' . $verb . '</button></form>';
    return '<div class="btile stile' . ($dim ? ' dim' : '') . '" data-cat="' . $catOf((string)($i['category'] ?? '')) . '" data-id="' . $id . '" data-price="' . $price . '" data-max="' . $max . '" data-name="' . e($i['name']) . '">'
        . '<button type="button" class="spick" data-sheet aria-haspopup="dialog"><i class="rar r' . $rl . '" role="img" aria-label="' . e($rw) . '" title="' . e($rw) . '">' . $rl . '</i>'
        . '<span class="iicon" aria-hidden="true">' . item_icon($i) . '</span><span class="iname">' . e($i['name']) . '</span>'
        . '<span class="sprice">' . $priceHtml . '</span>' . ($mini !== '' ? '<span class="smini">' . $mini . '</span>' : '')
        . ($badge !== '' ? '<b class="iqty" title="' . e($mode === 'buy' ? 'On the shelf' : 'You have') . '">' . e($badge) . '</b>' : '') . '</button>'
        . '<dialog class="isheet" aria-label="' . e($i['name']) . '"><button type="button" class="sheetx" data-sheetx aria-label="Close">✕</button>'
        . '<div class="shead"><span class="sico" aria-hidden="true">' . item_icon($i) . '</span><b class="sname">' . e($i['name']) . '</b> <span class="rarword r' . $rl . '">' . e($rw) . '</span></div>'
        . ($tags ? '<p class="stags">' . implode(' ', $tags) . '</p>' : '') . $descH . $info . $form . '</dialog></div>';
};
/** A short marker for the tile: season and price direction only. */
$miniOf = function (string $html): string {
    $o = '';
    if (str_contains($html, '⭐')) $o .= '⭐';
    if (str_contains($html, '🌿') || str_contains($html, '🌱')) $o .= '🌿';
    elseif (str_contains($html, '🍂')) $o .= '🍂';
    if (str_contains($html, '↑')) $o .= '<span class="up">↑</span>';
    elseif (str_contains($html, '↓')) $o .= '<span class="down">↓</span>';
    return $o;
};
?>

<?php if ($tab === 'buy'):
    $stock = q('SELECT st.*, i.id AS iid, i.name, i.slug, i.category, i.description, i.rarity, i.effects, i.base_price, p.id AS plant_id, p.seasons AS plant_seasons FROM shop_stock st
                JOIN items i ON i.id = st.item_id LEFT JOIN plants p ON p.seed_item_id = i.id
                WHERE st.shop_id = ? AND st.current_stock > 0 ORDER BY i.category, i.name', [$sid])->fetchAll();
    usort($stock, fn($a, $b) => [$catRank($a), $a['name']] <=> [$catRank($b), $b['name']]);   // v0.7.83: grouped in chip order ?>
  <div class="shopwrap">
  <?= $chips($stock) ?>
  <div class="satchel shopgrid">
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
      echo $tile((int)$s['id'], $item, $myPrice, (int)$s['current_stock'], $priceHtml, $miniOf(implode(' ', $tags)), $tags, $info, $read, (string)(int)$s['current_stock'], 'buy', url('shop.php?id=' . $sid));
  endforeach; ?>
  </div>
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
  <?= $chips($sellable) ?>
  <div class="satchel shopgrid">
  <?php foreach ($sellable as $i):
      $p = sell_price_with_bonus($i, $u, $sellBonus);
      $mc = market_chip($i);   // v1.0.0: ↑/↓ and ⭐ wanted
      $info = item_origin_html($i, $IL) . '<p class="help">👜 You have ' . (int)$i['qty'] . '</p>';
      echo $tile((int)$i['id'], $i, $p, (int)$i['qty'], money($p), $miniOf($mc), $mc !== '' ? [$mc] : [], $info, false, (string)(int)$i['qty'], 'sell', url('shop.php?id=' . $sid . '&tab=sell'));
  endforeach; ?>
  </div>
  </div>
  <?php if (!$sellable): ?><p class="muted">Nothing in your satchel this shop would buy.</p><?php endif; ?>
<?php endif; ?>
<?php page_footer();
