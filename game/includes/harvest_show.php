<?php
/* Harvest show: a row of plants is picked into a basket, then the numbers (assets/harvest.js).
   do_harvest() notes what it picked (hv_note_add / hv_note_info); the next page renders a hidden block (hv_stage, from event_box_html,
   so it rides every page and every in-place swap) and harvest.js plays it. Plays after the Harvest buttons ('self') and on wake from sleep
   when a garden pal picked overnight ('pal'). The server has already paid everything out; this is presentation only. No JS: block stays hidden. */

const HV_MAX_CARDS = 8;

/** One plant picked. $src: 'self' | 'pal' (a hired helper's visit is not shown). */
function hv_note_add(string $src, array $p, int $itemId, int $qty, string $palName = ''): void
{
    if (session_status() !== PHP_SESSION_ACTIVE || !in_array($src, ['self', 'pal'], true) || $qty < 1) return;
    $n = $_SESSION['hv_note'] ?? null;
    if (!is_array($n) || ($n['src'] ?? '') !== $src || time() - (int)($n['t'] ?? 0) > 60) $n = ['src' => $src, 'rows' => [], 'xp' => 0, 'seeds' => [], 'notes' => [], 'pals' => []];
    $n['t'] = time();
    $n['rows'][] = [$itemId, $qty, (string)$p['name'], (string)($p['kind'] ?? '')];
    if ($palName !== '' && !in_array($palName, $n['pals'], true)) $n['pals'][] = $palName;
    $_SESSION['hv_note'] = $n;
}

/** The rest of that harvest: XP and the interesting lines do_harvest made (bonuses, saved seeds, level-ups). */
function hv_note_info(string $src, array $msgs, int $xp): void
{
    $n = $_SESSION['hv_note'] ?? null;
    if (session_status() !== PHP_SESSION_ACTIVE || !is_array($n) || ($n['src'] ?? '') !== $src) return;
    $n['xp'] = (int)$n['xp'] + $xp;
    foreach ($msgs as $m) {
        $m = (string)$m;
        if (preg_match('/^You saved (\d+) × (.+)\.$/u', $m, $mm)) { $n['seeds'][$mm[2]] = ($n['seeds'][$mm[2]] ?? 0) + (int)$mm[1]; continue; }
        if (preg_match('/^(🍀|💪|🐝|🪱|🏅|🌽|🐦|🍄|✂️|✨|⭐|🎉|🏡|🎩|📈|🌱 Green)/u', $m) && !in_array($m, $n['notes'], true) && count($n['notes']) < 5) $n['notes'][] = $m;
    }
    $_SESSION['hv_note'] = $n;
}

/** The hidden block for the page, once. */
function hv_stage(): string
{
    $n = $_SESSION['hv_note'] ?? null;
    unset($_SESSION['hv_note']);
    if (!is_array($n) || empty($n['rows']) || time() - (int)($n['t'] ?? 0) > 60) return '';
    $GLOBALS['hv_shown'] = true;
    require_once __DIR__ . '/items.php';
    $total = 0; $lis = ''; $shown = 0; $more = 0; $icons = []; $names = [];
    foreach ($n['rows'] as [$id, $qty, $pname, $kind]) {
        $total += (int)$qty;
        $names[$pname] = ($names[$pname] ?? 0) + (int)$qty;
        if ($shown >= HV_MAX_CARDS) { $more++; continue; }
        $icons[$id] ??= (($it = q_one('SELECT * FROM items WHERE id = ?', [(int)$id])) ? item_icon($it, 'md') : '');
        $lis .= '<li class="hv-card" data-qty="' . (int)$qty . '" data-kind="' . e($kind) . '"><span class="hv-ico" aria-hidden="true">' . $icons[$id] . '</span><span class="hv-name">' . e($pname) . '</span></li>';
        $shown++;
    }
    $parts = [];
    foreach ($names as $nm => $q) $parts[] = $q . ' × ' . $nm;
    $pal = $n['src'] === 'pal';
    $who = $n['pals'] ? implode(' and ', array_slice($n['pals'], 0, 2)) : 'Your pal';
    $sum = ($pal ? $who . ' picked ' : 'You harvested ') . implode(', ', $parts) . ((int)$n['xp'] > 0 ? '. +' . (int)$n['xp'] . ' XP' : '') . '.';
    $notes = ''; foreach ($n['notes'] as $m) $notes .= '<li>' . e($m) . '</li>';
    $seeds = []; foreach ($n['seeds'] as $nm => $q) $seeds[] = $q . ' × ' . $nm;
    $art = '';   // pixel art (assets/img/harvest-*.png): all present = harvest.js uses it, else emoji and CSS blobs
    $pngs = ['basket-back', 'basket-heap', 'basket-front', 'soil-planted', 'soil-pulled', 'tuft-leafy', 'tuft-vine', 'tuft-stalk', 'puff', 'spark'];
    if (count(array_filter($pngs, fn($f) => pixel_has('assets/img/harvest-' . $f . '.png'))) === count($pngs)) $art = ' data-art="' . e(url('assets/img/harvest-')) . '"';
    return '<div class="hvdata" hidden' . $art . ' data-src="' . e($n['src']) . '" data-who="' . e($who) . '" data-total="' . $total . '" data-more="' . $more . '" data-xp="' . (int)$n['xp'] . '" data-seeds="' . e(implode(', ', $seeds)) . '" data-summary="' . e($sum) . '"><ul>' . $lis . '</ul><ol>' . $notes . '</ol></div>';
}
