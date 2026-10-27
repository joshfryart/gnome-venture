<?php
declare(strict_types=1);
/*
 * v2.0.67: the item square (approved mockup 4, claude/art-variants/mockup4). ONE renderer for every item grid: Satchel, trek pack,
 * shop Buy / Sell and every shop_tile() user (market, market day, festival, village stalls, landmarks, Curio Cabinet, Dye Pot).
 * Wave 2 (crafting ingredient chips, the gift picker, garden / town pickers) reuses it as it is. CSS: the .itm block in
 * assets/style.css (source claude/build/css-items.css); art: assets/img/items/ plus img/acts (felt-off, badges) and img/town (star).
 * Classes only, never a style attribute (strict CSP).
 *
 * item_square(array $o): string returns ONE element, the square itself (.itm). The caller wraps it when it needs a cell:
 *   shop tile   <div class="btile stile itmcell" data-...><button class="itm spick" data-sheet ...>...</button><dialog class="isheet">...</dialog></div>
 *   Satchel     <details class="itile itmcell"><summary class="itm">...</summary><div class="ipop">...</div></details>
 *   picker      <button class="itm pcard gcard" data-id=".." aria-pressed="false">...</button>   (wave 2: no wrapper needed)
 * and puts the squares in item_grid(): <div class="itmwrap"><div class="itms">...</div></div> (3 / 4 / 5 / 6 columns by the grid's own width).
 *
 * Options (all optional except item or name):
 *   item        array   an items row (id, slug, name, category, effects, rarity, image): picture, rarity and name come from it
 *   name        string  the full name (default item['name']); 'Seeds', 'Seed packet', 'Cutting', 'Seedling' (end), 'Broken' and 'Gardening Guide:' (start)
 *                       are lifted off the ribbon into the first foot chip; > 13 / > 19 characters left get a smaller face
 *   rarity      string  'C' | 'U' | 'R' | 'L' (default item_rarity(item)); U / R / L print the word, R / L sparkle
 *   icon        string  html for the window instead of item_icon(item, 'lg') (a dye swatch, an emoji, a coin); already escaped
 *   count       ?int    corner count "×N" (null = none)
 *   countLabel  string  words read before the count (screen readers only), default 'You have'
 *   price       ?int    price chip: number, petal mark, "Petals" for screen readers (null = none)
 *   trend       string  'up' | 'down' | '': ↑ / ↓ in the price chip
 *   trendWord   string  screen-reader words after the price for the trend (default ', dearer today' / ', cheaper today')
 *   chips       array   more foot chips after the price, in order: [kind, html] with kind one of
 *                       want (★ Wanted), inb (2 in basket), use (In use), ok (✔ uses 2), short (✖ short 1 / Short 2,120),
 *                       note (plain words: Spare, Mend it, Sold out), taste (💛 Loved); html is already escaped.
 *                       A chip with html '' and 'hidden' => true as a third value renders empty and hidden (filled by JS later).
 *   states      array   any of: sel (picked / sheet open), inbasket (basket badge), want (star badge), use (buckle badge),
 *                       off (stone felt: sold out, too dear, broken, can't use), locked (padlock badge), done (tick badge)
 *   flag        string  corner flag text, top left ('New', 'Rare taste!'); plain text
 *   flagClass   string  'taste' for the gold taste flag
 *   pressed     ?bool   aria-pressed on a button (pickers); null = no attribute
 *   tag         string  'button' (default) | 'summary' | 'div' | 'span' | 'a' (give attrs['href'])
 *   class       string  extra classes on the square (hooks: 'spick', 'pcard gcard' ...)
 *   attrs       array   extra attributes on the square, name => value (escaped here; true = bare attribute): data-sheet, data-id, aria-haspopup ...
 *   vh          string  extra screen-reader html at the end of the foot (already escaped)
 */

require_once __DIR__ . '/items.php';

const ITEM_SQUARE_KINDS = [' Seed Packet' => 'Seed packet', ' Seeds' => 'Seeds', ' Seedling' => 'Seedling', ' Cutting' => 'Cutting'];

/** [ribbon name, kind chip] for a full item name: 'Tomato Seeds' -> ['Tomato', 'Seeds'], 'Broken Garden Hoe' -> ['Garden Hoe', 'Broken']. */
function item_square_name(string $name): array
{
    if (str_starts_with($name, 'Broken ') && mb_strlen($name) > 7) return [mb_substr($name, 7), 'Broken'];
    if (str_starts_with($name, 'Gardening Guide: ') && mb_strlen($name) > 17) return [mb_substr($name, 17), 'Guide'];   // the longest real names
    foreach (ITEM_SQUARE_KINDS as $suf => $kind) {
        if (str_ends_with($name, $suf) && strlen($name) > strlen($suf)) return [substr($name, 0, -strlen($suf)), $kind];
    }
    return [$name, ''];
}

/** The price chip's inside: "1,400" + petal mark + " Petals" for screen readers. */
function item_square_money(int $n): string
{
    return number_format($n) . '<i class="itm__pet" aria-hidden="true"></i><span class="vh"> ' . e(setting('currency_name')) . '</span>';
}

/** A grid of item squares. */
function item_grid(string $squares, string $cls = ''): string
{
    return '<div class="itmwrap"><div class="itms' . ($cls !== '' ? ' ' . e($cls) : '') . '">' . $squares . '</div></div>';
}

/** The window picture: item_icon() at 64 px, marked .itm__ic; no alt text (the name is on the ribbon). */
function item_square_icon(array $i): string
{
    $h = item_icon($i, 'lg', '-');
    if (str_starts_with($h, '<img class="')) return (string)preg_replace(['/^<img class="([^"]*)"/', '/ alt="[^"]*"/'], ['<img class="$1 itm__ic"', ' alt=""'], $h, 1);
    if (str_starts_with($h, '<svg')) return '<span class="itm__svg" aria-hidden="true">' . $h . '</span>';
    return '<span class="itm__emo" aria-hidden="true">' . $h . '</span>';
}

function item_square(array $o): string
{
    static $IL = null;
    $i = (array)($o['item'] ?? []);
    $full = (string)($o['name'] ?? ($i['name'] ?? ''));
    [$base, $kind] = item_square_name($full);
    $rl = strtoupper((string)($o['rarity'] ?? ''));
    if (!isset(RARITY_WORDS[$rl])) {
        if (isset($i['id'], $i['category'])) { if ($IL === null) $IL = item_lookups(); $rl = item_rarity($i, $IL)[0]; }
        else $rl = 'C';
    }
    $len = mb_strlen($base);
    $states = (array)($o['states'] ?? []);
    $cls = ['itm', 'itm--' . strtolower($rl)];
    if ($len > 19) $cls[] = 'itm--xlong'; elseif ($len > 13) $cls[] = 'itm--long';
    foreach ($states as $s) if (in_array($s, ['sel', 'inbasket', 'want', 'use', 'off', 'locked', 'done'], true)) $cls[] = 'is-' . $s;
    if (($o['class'] ?? '') !== '') $cls[] = (string)$o['class'];

    $icon = isset($o['icon']) && $o['icon'] !== '' ? '<span class="itm__emo" aria-hidden="true">' . $o['icon'] . '</span>' : ($i ? item_square_icon($i) : '<span class="itm__emo" aria-hidden="true">🎁</span>');
    $count = isset($o['count']) && $o['count'] !== null
        ? '<b class="itm__n"><span class="vh">' . e((string)($o['countLabel'] ?? 'You have')) . ' </span>×' . number_format((int)$o['count']) . '</b>' : '';

    $foot = $rl !== 'C' ? '<span class="itm__rar">' . e(RARITY_WORDS[$rl]) . '</span>' : '';
    if ($kind !== '') $foot .= '<span class="itm__kind">' . e($kind) . '<span class="vh"> (' . e($full) . ')</span></span>';
    if (isset($o['price']) && $o['price'] !== null) {
        $tr = (string)($o['trend'] ?? '');
        $arrow = $tr === 'up' ? '↑' : ($tr === 'down' ? '↓' : '');
        $foot .= '<span class="itm__price">' . ($arrow !== '' ? '<span class="itm__trend" aria-hidden="true">' . $arrow . '</span>' : '') . item_square_money((int)$o['price'])
            . ($arrow !== '' ? '<span class="vh">' . e((string)($o['trendWord'] ?? ($tr === 'up' ? ', dearer today' : ', cheaper today'))) . '</span>' : '') . '</span>';
    }
    foreach ((array)($o['chips'] ?? []) as $c) {
        $k = (string)($c[0] ?? 'note');
        if (!in_array($k, ['want', 'inb', 'use', 'ok', 'short', 'note', 'taste', 'kind'], true)) $k = 'note';
        $foot .= '<span class="itm__' . $k . '"' . (!empty($c[2]) ? ' hidden' : '') . '>' . (string)($c[1] ?? '') . '</span>';
    }
    if ($rl === 'C') $foot .= '<span class="vh">Common</span>';
    $foot .= (string)($o['vh'] ?? '');

    $flag = (string)($o['flag'] ?? '');
    $inner = '<span class="itm__win">' . $icon . '<i class="itm__gem" aria-hidden="true"></i>' . $count . '</span>'
        . '<span class="itm__rib"><span class="itm__name">' . e($base) . '</span></span>'
        . '<span class="itm__foot">' . $foot . '</span>'
        . ($flag !== '' ? '<span class="itm__flag' . (($o['flagClass'] ?? '') === 'taste' ? ' itm__flag--taste' : '') . '">' . e($flag) . '</span>' : '');

    $tag = in_array($o['tag'] ?? 'button', ['button', 'summary', 'div', 'span', 'a'], true) ? (string)($o['tag'] ?? 'button') : 'button';
    $attrs = $tag === 'button' ? ' type="button"' : '';
    if (array_key_exists('pressed', $o) && $o['pressed'] !== null) $attrs .= ' aria-pressed="' . ($o['pressed'] ? 'true' : 'false') . '"';
    foreach ((array)($o['attrs'] ?? []) as $k => $v) {
        if (!preg_match('/^[a-z][a-z0-9-]*$/', (string)$k) || $v === false || $v === null) continue;
        $attrs .= $v === true ? ' ' . $k : ' ' . $k . '="' . e((string)$v) . '"';
    }
    return '<' . $tag . ' class="' . e(implode(' ', $cls)) . '"' . $attrs . '>' . $inner . '</' . $tag . '>';
}
