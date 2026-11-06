<?php
/* v1.4.6: the delve chest treat. delve_chest() notes what it gave (chest_note), the next page renders a hidden block
   (chest_stage, from event_box_html so it rides every page and every in-place swap) and assets/chest.js plays it.
   The server has already paid everything out; this is only presentation. No JS: the block stays hidden. */

function chest_note(int $coins, int $xp, array $items, array $opts = []): void
{
    $_SESSION['chest_loot'] = ['t' => time(), 'coins' => $coins, 'xp' => $xp, 'items' => $items, 'opts' => $opts];   // items: [[item id, qty, rarity], ...]; opts: title, done (heading when finished), quick (short version for small finds)
}

function chest_take(): ?array
{
    $r = $_SESSION['chest_loot'] ?? null;
    if (!is_array($r)) return null;
    unset($_SESSION['chest_loot']);
    return time() - (int)($r['t'] ?? 0) <= 60 ? $r : null;
}

function chest_stage(): string
{
    $r = chest_take();
    if (!$r) return '';
    require_once __DIR__ . '/items.php';
    $lis = '';
    $names = [];
    foreach ($r['items'] as [$id, $qty, $rar]) {
        $it = q_one('SELECT * FROM items WHERE id = ?', [(int)$id]);
        if (!$it) continue;
        $rar = in_array($rar, ['uncommon', 'rare'], true) ? $rar : 'common';
        $names[] = ((int)$qty > 1 ? (int)$qty . ' × ' : '') . $it['name'];
        $lis .= '<li class="cs-card cs-' . $rar . '"><span class="cs-ico" aria-hidden="true">' . item_icon($it, 'md') . '</span>'
            . '<span class="cs-name">' . e($it['name']) . '</span><b class="cs-qty">×' . (int)$qty . '</b></li>';
    }
    $o = (array)($r['opts'] ?? []);
    $extra = (!empty($o['title']) ? ' data-title="' . e((string)$o['title']) . '"' : '') . (!empty($o['done']) ? ' data-done="' . e((string)$o['done']) . '"' : '') . (!empty($o['quick']) ? ' data-quick="1"' : '');
    $parts = array_filter([(int)$r['coins'] > 0 ? number_format((int)$r['coins']) . ' ' . setting('currency_name') : '', (int)$r['xp'] > 0 ? (int)$r['xp'] . ' XP' : '', $names ? implode(', ', $names) : '']);
    $sum = (!empty($o['quick']) ? 'You found ' : 'The chest holds ') . implode(', ', $parts) . '.';
    $art = pixel_has('assets/img/chest-body.png') && pixel_has('assets/img/chest-lid.png')   // v2.0.31: pixel chest layers (chest.js falls back to its vector chest if absent or failing to load)
        ? ' data-body="' . e(url('assets/img/chest-body.png')) . '" data-lid="' . e(url('assets/img/chest-lid.png')) . '"' : '';
    return '<div class="chestdata" hidden' . $art . $extra . ' data-coins="' . (int)$r['coins'] . '" data-xp="' . (int)$r['xp'] . '" data-cur="' . e(setting('currency_name')) . '" data-summary="' . e($sum) . '"><ul>' . $lis . '</ul></div>';
}
