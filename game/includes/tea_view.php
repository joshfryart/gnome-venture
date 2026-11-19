<?php
declare(strict_types=1);
/**
 * The Hovel tea kettle: what the player sees (the engine is includes/tea.php, the live preview assets/tea.js).
 * The kettle in the room picture (hovel_room_svg) is a link that opens the popover <dialog id="htea"> on the Today tab of the slim home;
 * without script the same link loads gnome.php?tea=1, where the dialog is drawn open in the page. Brewing and buying post to hovel.php.
 * Without the slim home the same panel is the page hovel.php?t=tea. No inline styles (CSP style-src 'self').
 */
require_once __DIR__ . '/tea.php';
require_once __DIR__ . '/items.php';

/** Where the kettle link goes for this viewer (slim home: the Today tab with the popover open; else the Hovel's tea page). */
function tea_url(bool $slim, array $x = []): string
{
    return $slim ? url('gnome.php?' . http_build_query(['tea' => 1] + $x)) . '#htea' : url('hovel.php?' . http_build_query(['t' => 'tea'] + $x));
}

/** "until you sleep" / "until tomorrow". */
function tea_ends(): string
{
    return function_exists('gclock_on') && gclock_on() ? 'until you sleep' : 'until tomorrow';
}

/** The cup before it is brewed: name, boosts, the sum. The same structure assets/tea.js draws. $cup = tea_cup()'s array, or null (nothing picked). */
function tea_preview_html(?array $cup): string
{
    if (!$cup || !$cup['ok']) return '<div class="tea-out bad" data-tea-out aria-live="polite"><p class="tea-name">' . e($cup ? $cup['error'] : 'Pick a base to steep, then up to three extras.') . '</p></div>';
    $h = '<div class="tea-out" data-tea-out aria-live="polite"><p class="tea-name"><b>' . e($cup['name']) . '</b>' . ($cup['named'] ? ' <span class="tea-stamp">named tea · +1 steep</span>' : '') . '</p><p class="tea-buffs">';
    if (!$cup['buff']) $h .= '<span class="tea-buff none">Too weak for a boost</span>';
    foreach ($cup['buff'] as $st => $n) $h .= '<span class="tea-buff">' . e(TEA_STATS[$st] . ' +' . $n) . '</span>';
    $h .= '<span class="tea-buff none">' . e(tea_ends()) . '</span></p><p class="tea-math">';
    $line = fn(array $r, int $K): string => e(TEA_STATS[$r['stat']] . ': steep ' . $r['steep'] . ' × ' . $K . ' ÷ 8 = ' . $r['raw'] . ', cap ' . $r['cap']);
    $h .= $line($cup['steep']['main'], $cup['steep']['K']) . ($cup['steep']['side'] ? '<br>' . $line($cup['steep']['side'], $cup['steep']['K']) : '');
    return $h . '</p></div>';
}

/** One ingredient card: a tick box (in the cup), and for a thing that can steep a "Base" choice. */
function tea_card_html(array $g, array $have, bool $on, bool $base): string
{
    $tag = $g['role'] === 'sweet' ? 'sweet · +1 steep' : ($g['role'] === 'milk' ? 'creamy · +2 steep' : TEA_STATS[$g['stat']] . ' ' . $g['power']);
    $it = $have['item'];
    $uses = (string)$it['slug'] !== $g['slug'] ? ' title="' . e('Uses your ' . $it['name']) . '"' : '';
    $h = '<div class="tea-card' . ($on ? ' on' : '') . ($base ? ' base' : '') . '" data-tea-ing="' . e($g['slug']) . '"' . $uses . '>'
        . '<label class="tea-in"><input type="checkbox" name="c[]" value="' . e($g['slug']) . '"' . ($on ? ' checked' : '') . '>'
        . '<span class="tea-pic" aria-hidden="true">' . item_icon($it, 'sm', '') . '</span><span class="nm">' . e($g['name']) . '</span><span class="tg">' . e($tag) . '</span><span class="qt">×' . (int)$have['qty'] . '</span></label>';
    if ($g['role'] === 'steep') $h .= '<label class="tea-base"><input type="radio" name="base" value="' . e($g['slug']) . '"' . ($base ? ' checked' : '') . '> Base</label>';
    return $h . '</div>';
}

/** 2.7.20: the kettle's 20 px pixel icon (assets/img/ico/ico-kettle-<tin|copper|castiron|samovar>.png) for a tier, or the 🫖 emoji when the file is missing. */
function tea_kettle_icon(int $tier): string
{
    $f = 'assets/img/ico/ico-kettle-' . (['tin', 'copper', 'castiron', 'samovar'][max(0, min(3, $tier))]) . '.png';
    if (!is_file(APP_ROOT . '/' . $f)) return '<span class="tea-ki tea-k' . $tier . '" aria-hidden="true">🫖</span>';
    return '<img class="tea-ki tea-k' . $tier . ' pix" src="' . e(url($f)) . '" alt="" width="20" height="20">';
}

/** The kettle line: which kettle, how strong, what the next one needs (and the Buy button for the Copper Kettle). */
function tea_kettle_html(array $u): string
{
    $tier = max(0, (int)($u['kettle'] ?? 0));
    [$name, $K, $cm, $cs] = tea_kettle($tier);
    $h = '<section class="tea-kettle" aria-label="Your kettle"><p class="tea-k">' . tea_kettle_icon($tier) . ' <b>' . e($name) . '</b> <small>strength ' . $K . ' of 7 · best cup +' . $cm . ' and +' . $cs . '</small></p>';
    $nx = tea_kettle_next($u);
    if (!$nx) return $h . '<p class="tea-next">The finest kettle in the Hollow. Nothing steeps better.</p></section>';
    if ($nx['buy'] > 0) {
        $can = (int)($u['coins'] ?? 0) >= $nx['buy'];
        $h .= '<form method="post" action="' . e(url('hovel.php')) . '" class="tea-buy">' . csrf_field() . '<input type="hidden" name="do" value="kettle_buy">'
            . '<p class="tea-next">Next: <b>' . e($nx['name']) . '</b> · ' . (int)$nx['buy'] . ' Petals' . ($can ? '' : ' (you have ' . (int)($u['coins'] ?? 0) . ')') . '</p>'
            . '<button class="btn small" type="submit"' . ($can ? '' : ' disabled') . '>Buy the ' . e($nx['name']) . '</button></form>';
    } else {
        $h .= '<p class="tea-next">Next: <b>' . e($nx['name']) . '</b> · yours free at ' . (int)$nx['need'] . ' named teas in your journal (' . min((int)$nx['have'], (int)$nx['need']) . ' of ' . (int)$nx['need'] . ')</p>'
            . '<progress class="tea-prog" max="' . (int)$nx['need'] . '" value="' . min((int)$nx['have'], (int)$nx['need']) . '" aria-label="' . e('Named teas towards the ' . $nx['name']) . '"></progress>';
    }
    return $h . '</section>';
}

/** The Tea Journal: found teas with their parts, the others as "???" (names hidden), and how many remain. */
function tea_journal_html(int $uid, bool $open = false): string
{
    $j = tea_journal($uid);
    $ING = tea_ingredients();
    $left = $j['total'] - $j['n'];
    $h = '<details class="tea-journal"' . ($open ? ' open' : '') . '><summary>Tea Journal · ' . $j['n'] . ' of ' . $j['total'] . ' found</summary><ul class="tea-jl">';
    $unk = '';
    foreach (tea_named() as $slug => $t) {
        if (!isset($j['found'][$slug])) { $unk .= '<li class="unk" aria-label="A tea you have not found yet">???</li>'; continue; }
        $f = $j['found'][$slug];
        $h .= '<li class="got"><b>' . e($t['name']) . '</b> <small>' . e(implode(', ', array_map(fn($s) => $ING[$s]['name'] ?? $s, $t['parts'])) . ' · brewed ' . $f['times'] . ($f['times'] === 1 ? ' time' : ' times')) . '</small>'
            . ($t['note'] !== '' ? '<small class="nt">' . e($t['note']) . '</small>' : '') . '</li>';
    }
    $h .= $unk . '</ul><p class="tea-jn">' . ($left > 0 ? e($left . ' named tea' . ($left === 1 ? '' : 's') . ' still to find. A real recipe gets its name, a stamp here and a slightly stronger cup. ') : 'Every tea found. ')
        . e('Any other mix is a ' . TEA_HOUSE . ' and still works.') . '</p></details>';
    return $h;
}

/**
 * The whole kettle panel: today's cup, the cup builder with its preview, the kettle, the journal.
 * $sel = the picked slugs (base first; from tea_pick() on ?base=&c=), $slim = posts come back to the slim home.
 */
function tea_panel_html(array $u, array $sel, bool $slim): string
{
    tea_ensure();
    $uid = (int)$u['id'];
    $ING = tea_ingredients();
    $have = tea_satchel($uid);
    $today = tea_today($u);
    $tier = max(0, (int)($u['kettle'] ?? 0));
    $sel = array_values(array_filter($sel, fn($s) => isset($have[$s])));
    $h = '<div class="tea-head"><h3 id="htea-h">' . tea_kettle_icon($tier) . ' The kettle</h3><small>One cup a day. Pick a base to steep, then up to three extras. It is drunk here and lasts ' . e(tea_ends()) . '.</small></div>';
    if ($today) $h .= '<p class="tea-today">' . (is_file(APP_ROOT . '/assets/img/ico/ico-steam-cup.png') ? '<img class="tea-ki pix" src="' . e(url('assets/img/ico/ico-steam-cup.png')) . '" alt="" width="20" height="20"> ' : '') . '<b>Today’s cup: ' . e($today['name']) . '</b> · ' . e(($bt = tea_buff_text($today['buff'])) !== '' ? $bt . ' · ' . tea_ends() : 'no boost') . '</p>';
    $steepable = array_filter($have, fn($x, $s) => $ING[$s]['role'] === 'steep', ARRAY_FILTER_USE_BOTH);
    if (!$steepable) {
        $h .= '<p class="tea-empty">Nothing to steep in your satchel yet. Mint, ginger, chamomile, lavender or Tea Leaves from the garden will do, or foraged meadowsweet and desert sage.</p>';
    } else {
        $pour = $today ? 'This pours out your ' . $today['name'] . '. Brew again?' : '';
        $h .= '<form method="post" action="' . e(url('hovel.php')) . '" class="tea-form" data-tea="' . e((string)json_encode(tea_js_data($tier, null, array_keys($have)), JSON_UNESCAPED_UNICODE)) . '" data-tea-ends="' . e(tea_ends()) . '"' . ($pour !== '' ? ' data-tea-pour="' . e($pour) . '"' : '') . '>'
            . csrf_field() . '<input type="hidden" name="back" value="' . ($slim ? 'slim' : 'hovel') . '">';
        $groups = ['steep' => 'Leaves, herbs, flowers and roots (one is the base)', 'add' => 'Spices and fruit', 'sweet' => 'One sweetener', 'milk' => 'Milk'];
        foreach ($groups as $role => $label) {
            $cards = '';
            foreach ($have as $s => $x) if ($ING[$s]['role'] === $role) $cards .= tea_card_html($ING[$s], $x, in_array($s, $sel, true), ($sel[0] ?? '') === $s);
            if ($cards !== '') $h .= '<fieldset class="tea-grp"><legend>' . e($label) . '</legend><div class="tea-tray">' . $cards . '</div></fieldset>';
        }
        $h .= '<p class="tea-note" data-tea-note role="status"></p>' . tea_preview_html($sel ? tea_cup($sel, $tier) : null);
        if ($today) $h .= '<label class="tea-pour"><input type="checkbox" name="confirm" value="1"> Pour out my ' . e($today['name']) . ' and brew this instead</label>';
        $h .= '<div class="hpick-act"><button class="btn big" type="submit" name="do" value="brew" data-tea-brew>Brew and drink</button>'
            . '<button class="btn ghost tea-nojs" type="submit" name="do" value="tea_preview">Show the cup</button></div></form>';
    }
    return $h . tea_kettle_html($u) . tea_journal_html($uid, !$steepable);
}

/** The popover on the slim home's Today tab. $open: drawn open in the page (?tea=1: no script, or after a brew). */
function tea_dialog_html(array $u, bool $open): string
{
    $sel = $open ? tea_pick(['base' => $_GET['base'] ?? '', 'c' => $_GET['c'] ?? '']) : [];
    return '<dialog class="hpick htea" id="htea" aria-labelledby="htea-h"' . ($open ? ' open' : '') . '><div class="htea-in">' . tea_panel_html($u, $sel, true)
        . '<p class="hpick-act"><a class="btn ghost" href="' . e(url('gnome.php')) . '" data-hdlg-close>Close</a></p></div></dialog>';
}

/** Handle a kettle POST (do = brew, tea_preview, kettle_buy) from hovel.php, then redirect. The caller has checked CSRF. */
function tea_post(array $u, array $post, bool $slim): void
{
    $do = (string)($post['do'] ?? '');
    if (!tea_open_for($u)) { flash('The kettle is not ready yet.', 'err'); redirect('gnome.php'); }
    $back = function (array $x = []) use ($slim): string {
        return $slim ? 'gnome.php?' . http_build_query(['tea' => 1] + $x) . '#htea' : 'hovel.php?' . http_build_query(['t' => 'tea'] + $x);
    };
    $sel = tea_pick($post);
    $keep = $sel ? ['base' => $sel[0], 'c' => implode(',', array_slice($sel, 1))] : [];
    if ($do === 'kettle_buy') {
        [$ok, $msg] = tea_kettle_buy($u);
        flash($msg, $ok ? 'ok' : 'err');
        redirect($back());
    }
    if ($do === 'tea_preview') redirect($back($keep));   // no script: the page draws the cup these make
    [$ok, $msg] = tea_brew($u, $sel, !empty($post['confirm']));
    flash($msg, $ok ? 'ok' : 'err');
    redirect($back($ok ? [] : $keep));
}
