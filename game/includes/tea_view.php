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
        . '<span class="tea-pic" aria-hidden="true">' . tea_ing_pic($g['slug'], [$g['slug'] => $have], 'sm') . '</span><span class="nm">' . e($g['name']) . '</span><span class="tg">' . e($tag) . '</span><span class="qt">×' . (int)$have['qty'] . '</span></label>';
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

/** The kettle line: which kettle and how strong, then what the next one needs: "Cast-Iron at 8 teas  5/8" with a bar, or the Buy button for the Copper Kettle. */
function tea_kettle_html(array $u): string
{
    $tier = max(0, (int)($u['kettle'] ?? 0));
    [$name, $K, $cm, $cs] = tea_kettle($tier);
    $h = '<section class="tea-kettle" aria-label="Your kettle"><p class="tea-k">' . tea_kettle_icon($tier) . ' <b>' . e($name) . '</b> <small>· best cup +' . $cm . ' / +' . $cs . '</small></p>';
    $nx = tea_kettle_next($u);
    if (!$nx) return $h . '<p class="tea-next">The finest kettle in the Hollow. Nothing steeps better.</p></section>';
    if ($nx['buy'] > 0) {
        $can = (int)($u['coins'] ?? 0) >= $nx['buy'];
        $h .= '<form method="post" action="' . e(url('hovel.php')) . '" class="tea-buy">' . csrf_field() . '<input type="hidden" name="do" value="kettle_buy">'
            . '<p class="tea-next">Next: <b>' . e($nx['name']) . '</b> · ' . (int)$nx['buy'] . ' Petals' . ($can ? '' : ' (you have ' . (int)($u['coins'] ?? 0) . ')') . '</p>'
            . '<button class="tea-quiet" type="submit"' . ($can ? '' : ' disabled') . '>Buy the ' . e($nx['name']) . ' · ' . (int)$nx['buy'] . ' Petals</button></form>';
    } else {
        $n = min((int)$nx['have'], (int)$nx['need']);
        $h .= '<p class="tea-pg"><b>' . e(TEA_KETTLE_SHORT[$nx['tier']] . ' at ' . (int)$nx['need'] . ' teas') . '</b><span>' . $n . '/' . (int)$nx['need'] . '</span></p>'
            . '<progress class="tea-prog" max="' . (int)$nx['need'] . '" value="' . $n . '" aria-label="' . e('Named teas towards the ' . $nx['name'] . ': ' . $n . ' of ' . (int)$nx['need']) . '"></progress>'
            . '<p class="tea-next">The ' . e($nx['name']) . ' is yours free when your journal holds ' . (int)$nx['need'] . ' named teas.</p>';
    }
    return $h . '</section>';
}

/** An ingredient's picture: the item the gnome holds, else another item that counts as it (real art, flower art or a placeholder);
 *  only when none of them has a picture, the held item's emoji (e.g. the Lavender part has no art: the cut lavender's flower art stands in). */
function tea_ing_pic(string $slug, array $have, string $size = 'sm'): string
{
    static $rows = [];
    $ING = tea_ingredients();
    if (!isset($ING[$slug])) return '';
    $pic = fn(array $i): string => item_pic($i, $size, '', false) ?: (flower_icon($i, $size, '') ?: item_pic($i, $size, ''));
    $held = $have[$slug]['item'] ?? null;
    if ($held && ($p = $pic($held)) !== '') return $p;
    if (!array_key_exists($slug, $rows)) {
        $rows[$slug] = [];
        foreach ($ING[$slug]['items'] as [$s]) if ($r = q_one('SELECT * FROM items WHERE slug = ?', [$s])) $rows[$slug][] = $r;
    }
    foreach ($rows[$slug] as $r) if (($p = $pic($r)) !== '') return $p;
    $any = $held ?? ($rows[$slug][0] ?? null);
    return $any ? item_emoji($any) : '<span aria-hidden="true">🍵</span>';
}

/** Small round icons for a tea's parts (a missing one is dimmed). */
function tea_icons_html(array $parts, array $have, array $miss = []): string
{
    $ING = tea_ingredients();
    $h = '<span class="tea-ics">';
    foreach ($parts as $s) $h .= '<span class="tea-ico' . (in_array($s, $miss, true) ? ' lack' : '') . '" title="' . e(($ING[$s]['name'] ?? $s) . (in_array($s, $miss, true) ? ' (you have none)' : '')) . '">' . tea_ing_pic($s, $have) . '</span>';
    return $h . '</span>';
}

/** The tag under a slot: "Lore 2", "sweet, +1", "creamy, +2". */
function tea_tag(array $g): string
{
    return $g['role'] === 'sweet' ? 'sweet, +1' : ($g['role'] === 'milk' ? 'creamy, +2' : TEA_STATS[$g['stat']] . ' ' . $g['power']);
}

/** The four cup slots (the base first, bigger and marked; an empty slot shows a faint +). assets/tea.js draws the same markup. */
function tea_slots_html(array $sel, array $have): string
{
    $ING = tea_ingredients();
    $h = '<div class="tea-slots" data-tea-slots>';
    for ($i = 0; $i < TEA_MAX_PARTS; $i++) {
        $s = $sel[$i] ?? ''; $g = $ING[$s] ?? null;
        $h .= '<div class="tea-slot' . ($i === 0 ? ' base' : '') . '">';
        $h .= $g ? '<button type="button" class="tea-sl full" data-tea-take="' . e($s) . '" aria-label="' . e($g['name'] . ($i === 0 ? ', the base' : '') . '. Tap to take it out') . '"><span class="tea-ic">' . tea_ing_pic($s, $have, 'md') . '</span></button>'
            : '<span class="tea-sl empty" aria-hidden="true">+</span>';
        if ($i === 0) $h .= '<span class="tea-cap">Base ×2</span>';
        elseif ($g && $g['role'] === 'steep') $h .= '<button type="button" class="tea-mkb" data-tea-base="' . e($s) . '">Make base</button>';
        else $h .= '<span class="tea-cap">' . e($g ? tea_tag($g) : 'extra') . '</span>';
        $h .= '</div>';
    }
    return $h . '</div>';
}

/** The result line beside the Brew button: the tea's name (a named tea gets a stamp) and its boosts, or a hint. assets/tea.js draws the same. */
function tea_result_html(?array $cup): string
{
    if (!$cup) return '<span class="nm">Your cup</span><span class="sub">Pick a tea, or blend your own</span>';
    if (!$cup['ok']) return '<span class="nm">Your cup</span><span class="sub">' . e($cup['error']) . '</span>';
    $bt = str_replace(', ', ' · ', tea_buff_text($cup['buff']));
    return '<span class="nm">' . e($cup['name']) . ($cup['named'] ? ' <span class="tea-stamp" title="A named tea: +1 steep">+1</span>' : '') . '</span><span class="sub ok">' . e($bt !== '' ? $bt : 'Too weak for a boost') . '</span>';
}

/** One ingredient tile in the drawer (a tap puts it in the cup, or takes it out). */
function tea_tile_html(array $g, array $x, bool $on, bool $base): string
{
    $it = $x['item'];
    $title = $g['name'] . ' · ' . tea_tag($g) . ((string)$it['slug'] !== $g['slug'] ? ' · uses your ' . $it['name'] : '');
    return '<button type="button" class="tea-gt' . ($on ? ' on' : '') . ($base ? ' isbase' : '') . '" data-tea-add="' . e($g['slug']) . '" aria-pressed="' . ($on ? 'true' : 'false') . '" title="' . e($title) . '">'
        . '<span class="mk" aria-hidden="true"></span><span class="ct">×' . (int)$x['qty'] . '</span><span class="tea-ic" aria-hidden="true">' . tea_ing_pic($g['slug'], [$g['slug'] => $x], 'md') . '</span><span class="nm">' . e($g['name']) . '</span></button>';
}

/** The Tea Journal: the kettle (with Buy / progress), found teas with their parts and note, the others as "???" with a hint from their kinds.
 *  With script it is an in-page modal over the popover (the stamp row opens it); without, it is drawn under the cup. */
function tea_journal_html(array $u, array $have): string
{
    $uid = (int)$u['id'];
    $j = tea_journal($uid);
    $h = '<section class="tea-jm" id="htea-jr" data-tea-jm aria-labelledby="htea-jh"><button type="button" class="tea-veil" data-tea-jclose tabindex="-1" aria-label="Close the journal"></button>'
        . '<div class="tea-jbox" data-tea-jbox><div class="tea-jhd"><h3 id="htea-jh">Tea Journal · ' . $j['n'] . ' of ' . $j['total'] . ' found</h3>'
        . '<button type="button" class="tea-x" data-tea-jclose aria-label="Close the journal">×</button></div><div class="tea-jb">' . tea_kettle_html($u) . '<ul class="tea-jl">';
    $unk = '';
    foreach (tea_named() as $slug => $t) {
        if (!isset($j['found'][$slug])) { $unk .= '<li class="unk"><span class="tea-ics"><span class="tea-ico q" aria-hidden="true">?</span></span><span class="tx"><b>???</b><span>' . e(tea_hint($t)) . '</span></span></li>'; continue; }
        $f = $j['found'][$slug];
        $h .= '<li class="got">' . tea_icons_html(tea_recipe($t), $have, tea_lacks($t, array_keys($have))) . '<span class="tx"><b>' . e($t['name']) . '</b>'
            . ($t['note'] !== '' ? '<span>' . e($t['note']) . '</span>' : '') . '<small>brewed ' . $f['times'] . ($f['times'] === 1 ? ' time' : ' times') . '</small></span></li>';
    }
    $left = $j['total'] - $j['n'];
    $h .= $unk . '</ul><p class="tea-jn">' . ($left > 0 ? e($left . ' named tea' . ($left === 1 ? '' : 's') . ' still to find. A real recipe gets its name, a stamp here and a slightly stronger cup. ') : 'Every tea found. ')
        . e('Any other mix is a ' . TEA_HOUSE . ' and still works.') . '</p></div></div></section>';
    return $h;
}

/** The stamp row under the header: one tiny round stamp per named tea (found = coloured), and n/total. Opens the journal. */
function tea_stamps_html(int $uid): string
{
    $j = tea_journal($uid);
    $h = '<a class="tea-stamps" href="#htea-jr" data-tea-jopen aria-label="' . e('Tea Journal: ' . $j['n'] . ' of ' . $j['total'] . ' found. Open') . '"><span class="tea-dots" aria-hidden="true">';
    foreach (tea_stamps($j['found']) as $f) $h .= '<span class="tea-dot' . ($f ? ' f' : '') . '"></span>';
    return $h . '</span><span class="lb">' . $j['n'] . '/' . $j['total'] . ' ›</span></a>';
}

/** The drawer: Recipes | Leaves | Extras (tabs switch by tap and by swipe). */
function tea_drawer_html(array $u, array $have, array $sel): string
{
    $ING = tea_ingredients();
    $tier = max(0, (int)($u['kettle'] ?? 0));
    $j = tea_journal((int)$u['id']);
    $R = '';
    foreach (tea_recipe_rows(array_keys($have), $j['found'], $tier) as $r) {
        if (!$r['known']) { $R .= '<div class="tea-rrow unk"><span class="tea-ics"><span class="tea-ico q" aria-hidden="true">?</span></span><span class="tx"><b>???</b><span class="hint">' . e($r['hint']) . '</span></span></div>'; continue; }
        $R .= '<div class="tea-rrow" data-tea-row="' . e($r['slug']) . '">' . tea_icons_html($r['parts'], $have, $r['miss']) . '<span class="tx"><b>' . e($r['name']) . '</b>'
            . ($r['can'] ? '<span class="bf">' . e($r['buff']) . '</span>' : '<span class="need">' . e($r['need']) . '</span>') . '</span>'
            . ($r['can'] ? '<button type="button" class="tea-fill" data-tea-fill="' . e($r['slug']) . '" data-tea-parts="' . e(implode(',', $r['parts'])) . '" aria-pressed="false">Fill</button>' : '') . '</div>';
    }
    $grid = function (array $groups) use ($ING, $have, $sel): string {
        $H = '';
        foreach ($groups as [$kinds, $label]) {
            $t = '';
            foreach ($have as $s => $x) if (in_array($ING[$s]['kind'], $kinds, true)) $t .= tea_tile_html($ING[$s], $x, in_array($s, $sel, true), ($sel[0] ?? '') === $s);
            if ($t !== '') $H .= '<h4 class="tea-gl">' . e($label) . '</h4><div class="tea-grid">' . $t . '</div>';
        }
        return $H !== '' ? $H : '<p class="tea-none">None in your satchel.</p>';
    };
    $tabs = ['Recipes', 'Leaves', 'Extras'];
    $panes = [$R, $grid([[['leaf'], 'Leaves'], [['herb'], 'Herbs and roots']]), $grid([[['sweet', 'milk'], 'Sweet and milk'], [['spice'], 'Spices'], [['flower'], 'Flowers'], [['fruit'], 'Fruit']])];
    $h = '<div class="tea-drawer"><div class="tea-tabs" role="tablist" aria-label="Teas and ingredients">';
    foreach ($tabs as $i => $t) $h .= '<button type="button" class="tea-tab" role="tab" id="htea-t' . $i . '" aria-controls="htea-p' . $i . '" aria-selected="' . ($i === 0 ? 'true' : 'false') . '" tabindex="' . ($i === 0 ? '0' : '-1') . '" data-tea-tab="' . $i . '">' . $t . '</button>';
    $h .= '</div><div class="tea-panes" data-tea-panes>';
    foreach ($panes as $i => $p) $h .= '<div class="tea-pane" role="tabpanel" id="htea-p' . $i . '" aria-labelledby="htea-t' . $i . '" data-tea-pane="' . $i . '">' . $p . '</div>';
    return $h . '</div></div>';
}

/**
 * The whole kettle panel (B2 "Cup and drawer"): header with the kettle line, the journal's stamp row, today's cup, the cup (four slots,
 * the result and Brew) and the drawer (Recipes | Leaves | Extras), the journal modal and the replace sheet. With script (html.js) that is
 * what shows; without script the plain form (tick boxes, a Base radio, Show the cup, Brew) shows instead and the journal sits under it.
 * $sel = the picked slugs (base first; from tea_pick() on ?base=&c=), $slim = posts come back to the slim home, $close = the close control (dialog only).
 */
function tea_panel_html(array $u, array $sel, bool $slim, string $close = ''): string
{
    tea_ensure();
    $uid = (int)$u['id'];
    $ING = tea_ingredients();
    $have = tea_satchel($uid);
    $today = tea_today($u);
    $tier = max(0, (int)($u['kettle'] ?? 0));
    $sel = array_values(array_filter($sel, fn($s) => isset($have[$s])));
    $j = tea_journal($uid);
    $h = '<div class="tea-hd"><div class="tea-tt"><h3 id="htea-h">' . tea_kettle_icon($tier) . ' The kettle</h3><small class="tea-sub">' . e(tea_kettle_sub($tier, $j['n'])) . '</small></div>' . $close . '</div>'
        . tea_stamps_html($uid);
    if ($today) $h .= '<p class="tea-today">' . (is_file(APP_ROOT . '/assets/img/ico/ico-steam-cup.png') ? '<img class="tea-ki pix" src="' . e(url('assets/img/ico/ico-steam-cup.png')) . '" alt="" width="20" height="20"> ' : '') . '<b>Today’s cup: ' . e($today['name']) . '</b> · ' . e(($bt = tea_buff_text($today['buff'])) !== '' ? $bt . ' · ' . tea_ends() : 'no boost') . '</p>';
    $steepable = array_filter($have, fn($x, $s) => $ING[$s]['role'] === 'steep', ARRAY_FILTER_USE_BOTH);
    if (!$steepable) {
        $h .= '<p class="tea-empty">Nothing to steep in your satchel yet. Mint, ginger, chamomile, lavender or Tea Leaves from the garden will do, or foraged meadowsweet and desert sage.</p>';
    } else {
        $pour = $today ? 'This pours out your ' . $today['name'] . '.' : '';
        $cup = $sel ? tea_cup($sel, $tier) : null;
        $ok = $cup && $cup['ok'];
        // B2: the cup and the drawer (shown with script)
        $h .= '<div class="tea-b2"><form method="post" action="' . e(url('hovel.php')) . '" class="tea-cupf" data-tea="' . e((string)json_encode(tea_js_data($tier, null, array_keys($have)), JSON_UNESCAPED_UNICODE)) . '" data-tea-sel="' . e(implode(',', $sel)) . '"'
            . ($pour !== '' ? ' data-tea-pour="' . e($pour) . '" data-tea-today="' . e($today['name']) . '"' : '') . '>'
            . csrf_field() . '<input type="hidden" name="back" value="' . ($slim ? 'slim' : 'hovel') . '"><span data-tea-hid>'
            . ($sel ? '<input type="hidden" name="base" value="' . e($sel[0]) . '">' . implode('', array_map(fn($s) => '<input type="hidden" name="c[]" value="' . e($s) . '">', $sel)) : '') . '</span>'
            . ($today ? '<input type="hidden" name="confirm" value="" data-tea-confirm>' : '')
            . '<div class="tea-cup">' . tea_slots_html($sel, $have) . '<div class="tea-res"><div class="tea-pv' . ($cup && !$ok ? ' bad' : '') . '" data-tea-pv aria-live="polite">' . tea_result_html($cup) . '</div>'
            . '<button class="tea-go" type="submit" name="do" value="brew" data-tea-go' . ($ok ? '' : ' disabled') . '>' . ($today ? 'Brew again' : 'Brew') . '</button></div></div></form>'
            . '<p class="tea-note" data-tea-note role="status"></p>' . tea_drawer_html($u, $have, $sel)
            . ($today ? '<div class="tea-sheet" data-tea-sheet hidden><button type="button" class="tea-veil" data-tea-keep tabindex="-1" aria-label="Keep my cup"></button>'
                . '<div class="tea-sbox" role="alertdialog" aria-labelledby="htea-sq"><p id="htea-sq" data-tea-sq>' . e($pour . ' Brew again?') . '</p><div class="tea-row2"><button type="button" class="tea-quiet" data-tea-keep>Keep my cup</button>'
                . '<button type="button" class="tea-go" data-tea-pourgo>Pour out and brew</button></div></div></div>' : '')
            . '</div>';
        // without script: the plain form (tick boxes, a Base radio)
        $h .= '<div class="tea-plain"><form method="post" action="' . e(url('hovel.php')) . '" class="tea-form">' . csrf_field() . '<input type="hidden" name="back" value="' . ($slim ? 'slim' : 'hovel') . '">';
        $groups = ['steep' => 'Leaves, herbs, flowers and roots (one is the base)', 'add' => 'Spices and fruit', 'sweet' => 'One sweetener', 'milk' => 'Milk'];
        foreach ($groups as $role => $label) {
            $cards = '';
            foreach ($have as $s => $x) if ($ING[$s]['role'] === $role) $cards .= tea_card_html($ING[$s], $x, in_array($s, $sel, true), ($sel[0] ?? '') === $s);
            if ($cards !== '') $h .= '<fieldset class="tea-grp"><legend>' . e($label) . '</legend><div class="tea-tray">' . $cards . '</div></fieldset>';
        }
        $h .= tea_preview_html($cup);
        if ($today) $h .= '<label class="tea-pour"><input type="checkbox" name="confirm" value="1"> Pour out my ' . e($today['name']) . ' and brew this instead</label>';
        $h .= '<div class="hpick-act"><button class="btn big" type="submit" name="do" value="brew" data-tea-brew>Brew and drink</button>'
            . '<button class="btn ghost tea-nojs" type="submit" name="do" value="tea_preview">Show the cup</button></div></form></div>';
    }
    return '<div class="tea-panel" data-tea-panel>' . $h . tea_journal_html($u, $have) . '</div>';
}

/** The popover on the slim home's Today tab. $open: drawn open in the page (?tea=1: no script, or after a brew). */
function tea_dialog_html(array $u, bool $open): string
{
    $sel = $open ? tea_pick(['base' => $_GET['base'] ?? '', 'c' => $_GET['c'] ?? '']) : [];
    $x = '<a class="tea-x" href="' . e(url('gnome.php')) . '" data-hdlg-close aria-label="Close">×</a>';
    return '<dialog class="hpick htea" id="htea" aria-labelledby="htea-h"' . ($open ? ' open' : '') . '><div class="htea-in">' . tea_panel_html($u, $sel, true, $x) . '</div></dialog>';
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
