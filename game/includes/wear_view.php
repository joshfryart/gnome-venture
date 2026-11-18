<?php
declare(strict_types=1);
/**
 * 2.7.14 WEARING: the 7 slots on My Gnome (gnome.php: the full panel with the picker, Wear / Take off) and the small read-only strip on the Puzzle box.
 * The rules are in includes/wearables.php (wear_equip, wear_takeoff, wear_worn). Phone first; no inline styles (CSS: assets/style.css .wearing, assets/pfv1.css .pbx-wear).
 */
require_once __DIR__ . '/wearables.php';
require_once __DIR__ . '/items.php';

/** The picture of a wearable item (assets/img/ph/<slug>.png) or the slot's icon. */
function wear_pic(string $slug, string $slot, int $px, string $alt = ''): string
{
    return ($slug !== '' ? ph_img($slug, $px, $alt, 'wpic') : '') ?: '<span class="wpic wico" aria-hidden="true">' . e(WEAR_SLOTS[$slot][1] ?? '🧵') . '</span>';
}

/** [item name, rank words, piece line] of a wearable item. $lined = wear_lined_set(). */
function wear_item_words(string $slug, array $lined = []): array
{
    $p = wear_parse($slug); $it = wear_items()[$slug] ?? null;
    if (!$p || !$it) return [$slug, '', ''];
    [$base, $cut, $rank] = $p; $d = wear_defs()[$base]; $c = $d['cuts'][$cut];
    $rk = WEAR_RANK_NAME[$rank] . ($rank === 3 && in_array($base . '|' . $cut, $lined, true) ? ', worn as Lined' : '');
    return [$d['name'] . ($cut === 'b' ? ' (' . $c[0] . ')' : ''), $rk, $c[0] . ' · ' . ucfirst((string)$c[1]) . ': ' . rtrim((string)$c[5], '.') . '.'];
}

/** The full Wearing panel of My Gnome. $open = the slot whose picker is open ('' none). $base = the page's URL for this tab (gnome.php?tab=gnome). */
function wear_panel_html(array $u, string $open = '', string $base = 'gnome.php?tab=gnome'): string
{
    $uid = (int)$u['id']; $owned = wear_owned($uid); $worn = wear_worn($uid, $owned); $lined = wear_lined_set($uid);
    $have = [];   // slot => [item slugs], best rank first
    foreach ($owned as $slug => $n) { $p = wear_parse((string)$slug); $s = $p ? wear_slot_of($p[0]) : null; if ($s !== null) $have[$s][] = (string)$slug; }
    foreach ($have as $s => $list) usort($have[$s], fn($a, $b) => strcmp(wear_item_words($a)[0], wear_item_words($b)[0]) ?: (wear_parse($b)[2] <=> wear_parse($a)[2]));
    $sep = str_contains($base, '?') ? '&' : '?';
    $h = '<section class="box wearing" id="wearing" aria-label="Wearing"><div class="palhead"><h2>🧵 Wearing <small class="muted">' . count($worn) . ' of ' . count(WEAR_SLOTS) . '</small></h2></div>'
        . '<p class="help">One item in each spot. A worn item adds its piece to your Puzzle box.</p><ul class="wslots">';
    foreach (WEAR_SLOTS as $slot => [$sn, $ico]) {
        $cur = $worn[$slot] ?? ''; $isOpen = $open === $slot; $n = count($have[$slot] ?? []);
        [$nm, $rk, $pl] = $cur !== '' ? wear_item_words($cur, $lined) : ['', '', ''];
        $h .= '<li class="wslot' . ($cur !== '' ? ' on' : '') . ($isOpen ? ' open' : '') . '"><a class="wsa" href="' . e(url($isOpen ? $base : $base . $sep . 'wear=' . $slot)) . '#wearing" aria-expanded="' . ($isOpen ? 'true' : 'false') . '">'
            . wear_pic($cur, $slot, 48) . '<span class="wst"><b>' . e($sn) . '</b>'
            . ($cur !== '' ? '<span class="wsn">' . e($nm) . ' <small class="wrk">' . e($rk) . '</small></span><small class="wsp">' . e($pl) . '</small>'
                : '<small class="muted">' . ($n ? 'Nothing on · ' . $n . ' to choose' : 'Nothing yet') . '</small>')
            . '</span><span class="wsgo" aria-hidden="true">' . ($isOpen ? '▴' : '▾') . '</span></a>';
        if ($isOpen) {
            $h .= '<ul class="wpick" aria-label="' . e($sn) . ': what you can wear">';
            foreach ($have[$slot] ?? [] as $slug) {
                [$inm, $irk, $ipl] = wear_item_words($slug, $lined); $on = $slug === $cur; $p = wear_parse($slug);
                $h .= '<li' . ($on ? ' class="on"' : '') . '>' . wear_pic($slug, $slot, 40) . '<span class="wst"><span class="wsn">' . e($inm) . ' <small class="wrk">' . e($irk) . '</small></span><small class="wsp">' . e($ipl) . '</small></span><span class="wbtn">'
                    . '<form method="post">' . csrf_field() . '<input type="hidden" name="do" value="' . ($on ? 'wear_off' : 'wear_on') . '"><input type="hidden" name="slot" value="' . e($slot) . '"><input type="hidden" name="item" value="' . e($slug) . '">'
                    . '<button class="btn small' . ($on ? ' ghost' : ' primary') . '">' . ($on ? 'Take off' : 'Wear') . '</button></form>';
                if ($p && $p[2] === 3) $h .= '<form method="post">' . csrf_field() . '<input type="hidden" name="do" value="wear_lined"><input type="hidden" name="slot" value="' . e($slot) . '"><input type="hidden" name="item" value="' . e($slug) . '"><button class="btn small ghost">'
                    . (in_array($p[0] . '|' . $p[1], $lined, true) ? 'As Fine' : 'As Lined') . '</button></form>';
                $h .= '</span></li>';
            }
            if (!($have[$slot] ?? [])) $h .= '<li class="wnone"><small>You have nothing to wear here yet. The outfitters sell clothes; your Tailor makes and lines them.</small></li>';
            $h .= '</ul>';
        }
        $h .= '</li>';
    }
    return $h . '</ul></section>';
}

/** The small read-only strip on the Puzzle box: the worn items' pictures and a link to My Gnome. */
function wear_strip_html(array $u): string
{
    $worn = wear_worn((int)$u['id']); $pics = '';
    foreach (WEAR_SLOTS as $slot => [$sn]) if (isset($worn[$slot])) $pics .= wear_pic($worn[$slot], $slot, 32, $sn . ': ' . wear_item_words($worn[$slot])[0]);
    return '<a class="pbx-wear" id="pbx-wear" href="' . e(url('gnome.php?tab=gnome')) . '#wearing"><b>🧵 Wearing</b><span class="wps">' . ($pics !== '' ? $pics : '<small>Nothing worn</small>') . '</span><small class="wch">Change on My Gnome</small></a>';
}
