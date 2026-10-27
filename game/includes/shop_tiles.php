<?php
declare(strict_types=1);
/* v2.0.5: ONE tile renderer + ONE sheet (dialog) for every pure buy/sell item list (shop.php, market.php, marketday.php).
   JS lives in site.js ("shop tiles"), CSS at the end of style.css. */

const SHOP_CATS = ['seed' => '🌱 Seeds', 'produce' => '🥕 Crops', 'flower' => '🌸 Flowers', 'food' => '🍲 Food', 'soil' => '🪱 Soil', 'mulch' => '🍂 Mulch',
    'supply' => '🧪 Supplies', 'tool' => '🧰 Tools', 'guide' => '📗 Guides', 'forage' => '🍄 Finds', 'part' => '🦴 Parts', 'decor' => '🏡 Decor', 'arrangement' => '💐 Arrangements', 'packet' => '📦 Seed packets'];

function shop_cat_of(string $c): string { return isset(SHOP_CATS[$c]) ? $c : 'other'; }
function shop_cat_rank(array $r): int { return (int)array_search(shop_cat_of((string)$r['category']), array_keys(SHOP_CATS + ['other' => 1]), true); }

/** Category chips that only hide and show tiles inside the nearest .shopwrap. */
function shop_chips(array $rows): string
{
    $n = [];
    foreach ($rows as $r) { $k = shop_cat_of((string)$r['category']); $n[$k] = ($n[$k] ?? 0) + 1; }
    if (count($n) < 2) return '';
    $h = '<nav class="chips shopcats" aria-label="Show"><button type="button" class="on" data-cat="all">All <small>' . count($rows) . '</small></button>';
    foreach (SHOP_CATS + ['other' => '📦 Other'] as $k => $label) if (!empty($n[$k])) $h .= '<button type="button" data-cat="' . $k . '">' . $label . ' <small>' . $n[$k] . '</small></button>';
    return $h . '</nav>';
}

/** v2.0.67: the basket bar. Sheets add to it (site.js "shop basket"); one post buys or sells everything in it. */
function shop_basket_html(string $mode, string $action): string
{
    return '<form method="post" class="basket" data-mode="' . $mode . '" action="' . e($action) . '" hidden>' . csrf_field()
        . '<input type="hidden" name="do" value="' . $mode . '"><div class="blist"></div><p class="sbad" hidden></p>'
        . '<div class="bfoot"><b class="btotal" data-lbl="' . ($mode === 'buy' ? 'Total' : 'You get') . '"></b>'
        . '<button type="button" class="btn ghost bclear">Empty</button><button class="btn bgo">🧺 ' . ($mode === 'buy' ? 'Buy' : 'Sell') . ' all</button></div></form>';
}

/** A short marker for the tile: season and price direction only. */
function shop_mini(string $html): string
{
    $o = '';
    if (str_contains($html, '⭐')) $o .= '⭐';
    if (str_contains($html, '🌿') || str_contains($html, '🌱')) $o .= '🌿';
    elseif (str_contains($html, '🍂')) $o .= '🍂';
    if (str_contains($html, '↑')) $o .= '<span class="up">↑</span>';
    elseif (str_contains($html, '↓')) $o .= '<span class="down">↓</span>';
    return $o;
}

/**
 * One tile + its sheet. Options:
 *  id (int, form key), item (row with name/category/description/id), price (int each), max (int), priceHtml, mini (html), tags (html[]), info (html),
 *  dim (bool), badge (string), mode ('buy'|'sell'), action (form URL), open (bool: show the form), qtyName ('qty[ID]' default or 'qty'),
 *  fields (name => value hidden inputs, in order), totalLabel (override "Total"/"You get"), each (text after the price, default 'each'), counts (title for the badge), basket (bool: offer "Add to basket"; needs a .basket form in the .shopwrap).
 */
function shop_tile(array $o): string
{
    static $IL = null;
    if ($IL === null) $IL = item_lookups();
    $i = (array)$o['item'];
    $id = (int)$o['id'];
    $price = (int)$o['price'];
    $max = (int)$o['max'];
    $mode = (string)($o['mode'] ?? 'buy');
    $priceHtml = (string)($o['priceHtml'] ?? money($price));
    $mini = (string)($o['mini'] ?? '');
    $tags = (array)($o['tags'] ?? []);
    $info = (string)($o['info'] ?? '');
    $badge = (string)($o['badge'] ?? '');
    $qtyName = (string)($o['qtyName'] ?? 'qty[' . $id . ']');
    [$rl, $rw] = item_rarity($i, $IL);
    $desc = (string)($i['description'] ?? '');
    $descH = $desc === '' ? '' : (mb_strlen($desc) > 90
        ? '<details class="helpfold sdesc"><summary>About it</summary><p>' . desc_html($desc) . '</p></details>'
        : '<p class="sdesc">' . desc_html($desc) . '</p>');
    $verb = $mode === 'buy' ? 'Buy' : 'Sell';
    $lbl = (string)($o['totalLabel'] ?? ($mode === 'buy' ? 'Total' : 'You get'));
    $hidden = '';
    foreach ((array)($o['fields'] ?? []) as $k => $v) $hidden .= '<input type="hidden" name="' . e((string)$k) . '" value="' . e((string)$v) . '">';
    $form = empty($o['open']) || $max < 1 ? '' : '<form method="post" class="sheetform" data-mode="' . $mode . '" data-price="' . $price . '" data-max="' . $max . '" action="' . e((string)$o['action']) . '">' . csrf_field()
        . '<input type="hidden" name="do" value="' . $mode . '">' . $hidden
        . '<div class="qctl"><button type="button" class="qbtn" data-q="-1" aria-label="One less">−</button>'
        . '<input type="number" class="qin" name="' . e($qtyName) . '" value="1" min="1" max="' . $max . '" inputmode="numeric" aria-label="How many">'
        . '<button type="button" class="qbtn" data-q="1" aria-label="One more">+</button>'
        . '<button type="button" class="qbtn qmax" data-q="max">All</button></div>'
        . '<p class="sline"><span>' . $priceHtml . ' ' . e((string)($o['each'] ?? 'each')) . '</span> · <b class="stot" data-lbl="' . e($lbl) . '"></b></p>'
        . '<p class="sbad" hidden></p>'
        . '<button class="btn sgo">' . $verb . '</button>'
        . (!empty($o['basket']) ? '<button type="button" class="btn ghost sadd">🧺 Add to basket</button>' : '') . '</form>';
    return '<div class="btile stile' . (!empty($o['dim']) ? ' dim' : '') . '" data-cat="' . shop_cat_of((string)($i['category'] ?? '')) . '" data-id="' . $id . '" data-price="' . $price . '" data-max="' . $max . '" data-name="' . e((string)$i['name']) . '">'
        . '<button type="button" class="spick" data-sheet aria-haspopup="dialog"><i class="rar r' . $rl . '" role="img" aria-label="' . e($rw) . '" title="' . e($rw) . '">' . $rl . '</i>'
        . '<span class="iicon" aria-hidden="true">' . item_icon($i) . '</span><span class="iname">' . e((string)$i['name']) . '</span>'
        . '<span class="sprice">' . $priceHtml . '</span>' . ($mini !== '' ? '<span class="smini">' . $mini . '</span>' : '')
        . ($badge !== '' ? '<b class="iqty" title="' . e((string)($o['badgeTitle'] ?? ($mode === 'buy' ? 'On the shelf' : 'You have'))) . '">' . e($badge) . '</b>' : '') . '</button>'
        . '<dialog class="isheet" aria-label="' . e((string)$i['name']) . '"><button type="button" class="sheetx" data-sheetx aria-label="Close">✕</button>'
        . '<div class="shead"><span class="sico" aria-hidden="true">' . item_icon($i) . '</span><b class="sname">' . e((string)$i['name']) . '</b> <span class="rarword r' . $rl . '">' . e($rw) . '</span></div>'
        . ($tags ? '<p class="stags">' . implode(' ', $tags) . '</p>' : '') . $descH . $info . $form . '</dialog></div>';
}
