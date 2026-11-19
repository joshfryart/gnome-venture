<?php
declare(strict_types=1);
/**
 * Slim Home (mockup B3 "Slim home, three tabs"). Flag: home_slim (bool, default 0; admins always preview, like the gnav flags).
 * Off = the home page (gnome.php) and the Hovel (hovel.php) are exactly as before.
 * On: gnome.php is one page: a slim hovel banner (a 480x120 crop, y104-224, of the 480x270 room picture) with Go to sleep and Nap,
 * then three tabs, plain links: TODAY (one "Needs you" list + the news row), FURNISH (the room's decor slots) and GNOME (level,
 * health, pals along, the six sub-page tiles). hovel.php still does the sleeping (POST, CSRF) and sends a GET to the right tab.
 * TODAY (the interactive room): the banner is the WHOLE room with tappable things (bed, door, kettle, window, lamp, gnome; boxes in
 * includes/data/hovel_things.php, like the Crafting scenes), a one-line greeting and a row of small rest buttons. Every thing is a
 * real link; assets/hovelroom.js only adds the lamp switch and the gnome's speech bubble, the dialogs open through site.js (data-hdlg).
 *
 * Picture rules (DESIGN.md "Here, door and treehouse pictures"): one inline SVG, positions are SVG attributes, state is classes,
 * every image pixelated, art optional (a drawn wall and floor when scenes/hovel-room.png is missing; a missing layer is a soft box).
 * Decor catalogue: includes/data/hovel_decor.json. Choices: table user_hovel_decor (user_id, slot, item).
 */
require_once __DIR__ . '/here_schema.php';   // hub_seen_get/set: the per-gnome "last saw the news" time (scene 'news')
require_once __DIR__ . '/tea.php';   // the kettle in the room picture brews tea (setting tea_open)

/** Is the slim home on for this viewer? Players need the setting; admins always preview. */
function home_slim_on(): bool
{
    return is_admin() || setting('home_slim') === '1';
}

/** Tables. Returns [tables, indexes, columns] like the other *_schema() functions (wired in schema.php). */
function home_slim_schema(string $PK, string $ID, string $END): array
{
    return [["CREATE TABLE IF NOT EXISTS user_hovel_decor (
        user_id INT NOT NULL,
        slot VARCHAR(16) NOT NULL,
        item VARCHAR(24) NOT NULL,
        updated_at DATETIME NULL,
        PRIMARY KEY (user_id, slot)
    )$END"], [], []];
}

/** Make user_hovel_decor if the upgrade has not yet (the days between uploading files and running the upgrade). Never fatal. */
function hovel_decor_ensure(): bool
{
    static $ok = null;
    if ($ok !== null) return $ok;
    try { q('SELECT 1 FROM user_hovel_decor LIMIT 1'); return $ok = true; } catch (Throwable $e) {}
    try {
        $sqlite = db()->getAttribute(PDO::ATTR_DRIVER_NAME) === 'sqlite';
        [$t] = home_slim_schema('', '', $sqlite ? '' : ' ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci');
        foreach ($t as $sql) db()->exec($sql);
        return $ok = true;
    } catch (Throwable $e) {
        error_log('hovel_decor_ensure: ' . $e->getMessage());
        return $ok = false;
    }
}

/** The decor catalogue, slots and items keyed by their keys: ['canvas' => [...], 'gnome' => [...], 'slots' => [k => [..., 'items' => [k => item]]]]. */
function hovel_decor_catalog(): array
{
    static $c = null;
    if ($c !== null) return $c;
    $j = json_decode((string)@file_get_contents(__DIR__ . '/data/hovel_decor.json'), true);
    $c = ['canvas' => ['w' => 480, 'h' => 270, 'crop' => [104, 224], 'floor' => 220], 'gnome' => ['x' => 202, 'y' => 150, 'w' => 48, 'h' => 72, 'small' => ['x' => 214, 'y' => 172, 'w' => 32, 'h' => 48]], 'slots' => []];
    if (!is_array($j)) return $c;
    $c['canvas'] = (array)($j['canvas'] ?? []) + $c['canvas'];
    $c['gnome'] = (array)($j['gnome'] ?? []) + $c['gnome'];
    foreach ((array)($j['slots'] ?? []) as $s) {
        $k = (string)($s['k'] ?? '');
        if (!preg_match('/^[a-z]{1,16}$/', $k) || empty($s['items'])) continue;
        $items = [];
        foreach ((array)$s['items'] as $it) {
            $ik = (string)($it['k'] ?? '');
            if (!preg_match('/^[a-z]{1,24}$/', $ik)) continue;
            $items[$ik] = ['k' => $ik, 'name' => (string)($it['name'] ?? $ik), 'cosy' => max(0, min(2, (int)($it['cosy'] ?? 0))), 'own' => !empty($it['own']), 'where' => (string)($it['where'] ?? '')];
        }
        if (!$items) continue;
        $c['slots'][$k] = ['k' => $k, 'name' => (string)($s['name'] ?? $k), 'x' => (int)$s['x'], 'y' => (int)$s['y'], 'w' => max(1, (int)$s['w']), 'h' => max(1, (int)$s['h']), 'items' => $items];
    }
    return $c;
}

/**
 * Which items this gnome owns: [slot => [item => true]]. v1: the defaults ('own' in the catalogue) and nothing else.
 * This is the one place to add new sources (a market stall, a Journey step, a festival prize): add the item key to its slot here.
 */
function hovel_decor_owned(int $uid): array
{
    $o = [];
    foreach (hovel_decor_catalog()['slots'] as $sk => $s) foreach ($s['items'] as $ik => $it) if ($it['own']) $o[$sk][$ik] = true;
    return $o;
}

/** What is in each slot now: [slot => item]. A slot never chosen (or holding something no longer owned) shows its first owned item. */
function hovel_decor_chosen(int $uid): array
{
    $cat = hovel_decor_catalog();
    $own = hovel_decor_owned($uid);
    $rows = [];
    try { foreach (q('SELECT slot, item FROM user_hovel_decor WHERE user_id = ?', [$uid])->fetchAll() as $r) $rows[(string)$r['slot']] = (string)$r['item']; } catch (Throwable $e) {}
    $out = [];
    foreach ($cat['slots'] as $sk => $s) {
        $pick = $rows[$sk] ?? '';
        if (!isset($own[$sk][$pick])) $pick = (string)array_key_first($own[$sk] ?? []) ?: (string)array_key_first($s['items']);
        $out[$sk] = $pick;
    }
    return $out;
}

/** Put an owned item in a slot. Returns [ok, message, the item that was there before]. */
function hovel_decor_set(int $uid, string $slot, string $item): array
{
    $cat = hovel_decor_catalog();
    $s = $cat['slots'][$slot] ?? null;
    if (!$s) return [false, 'There is no such spot in your hovel.', ''];
    $it = $s['items'][$item] ?? null;
    if (!$it) return [false, 'That does not go there.', ''];
    if (empty(hovel_decor_owned($uid)[$slot][$item])) return [false, $it['name'] . ' is locked' . ($it['where'] !== '' ? ': ' . $it['where'] . '.' : '.'), ''];
    $prev = hovel_decor_chosen($uid)[$slot] ?? '';
    if (!hovel_decor_ensure()) return [false, 'Your hovel cannot be changed just now. Try again soon.', ''];
    if (q('UPDATE user_hovel_decor SET item = ?, updated_at = ? WHERE user_id = ? AND slot = ?', [$item, now(), $uid, $slot])->rowCount() < 1) {
        try { q('INSERT INTO user_hovel_decor (user_id, slot, item, updated_at) VALUES (?, ?, ?, ?)', [$uid, $slot, $item, now()]); }
        catch (Throwable $e) { q('UPDATE user_hovel_decor SET item = ?, updated_at = ? WHERE user_id = ? AND slot = ?', [$item, now(), $uid, $slot]); }   // a second tab got there first
    }
    return [true, $it['name'] . ' is in place.', $prev];
}

/** [cosiness now, the most there can be] = the chosen items' cosy points, and the sum of each slot's best item. */
function hovel_cosy(array $chosen): array
{
    $n = 0; $max = 0;
    foreach (hovel_decor_catalog()['slots'] as $sk => $s) {
        $n += (int)($s['items'][$chosen[$sk] ?? '']['cosy'] ?? 0);
        $max += max(array_map(fn($i) => (int)$i['cosy'], $s['items']));
    }
    return [$n, max(1, $max)];
}

/** The kettle's tap area in the 480 x 270 room picture: [x, y, w, h]. 64 units each way: 44 px or more on a 390 px phone, where the banner is about 350 px wide. */
const HOVEL_KETTLE_HIT = [312, 142, 64, 64];
/** 2.7.20: the kettle overlays scenes/hovel-kettle-<name>.png (users.kettle 1..3) cover the painted tin kettle: their box [x, y, w, h] in room units. */
const HOVEL_KETTLE_ART = [312, 140, 40, 47];
const HOVEL_KETTLE_FILES = [1 => 'copper', 2 => 'castiron', 3 => 'samovar'];
/** Where the steam leaves each kettle's spout (room units, the puff's bottom left): tin (painted), copper, cast-iron, samovar (the little teapot on top). */
const HOVEL_KETTLE_STEAM = [0 => [316, 157], 1 => [315, 157], 2 => [315, 160], 3 => [321, 140]];

/** Picture file (under assets/img/) as a URL, or '' when it is not drawn yet. */
function hovel_art(string $rel): string
{
    return is_file(APP_ROOT . '/assets/img/' . $rel) ? url('assets/img/' . $rel) : '';
}

/** The furnish address for a slot (the no-script picker). */
function hovel_slot_url(string $slot, array $x = []): string
{
    return url('gnome.php?' . http_build_query(['tab' => 'furnish'] + ($slot !== '' ? ['slot' => $slot] : []) + $x));
}

/**
 * The tappable things of the room on Today, from includes/data/hovel_things.php: [id => ['id', 'label', 'x', 'y', 'w', 'h', 'act', 'out' => [x, y, w, h]]].
 * A row with a bad id or a box outside the picture is dropped.
 */
function hovel_things(): array
{
    static $t = null;
    if ($t !== null) return $t;
    $t = [];
    $rows = @include __DIR__ . '/data/hovel_things.php';
    $cv = hovel_decor_catalog()['canvas'];
    foreach (is_array($rows) ? $rows : [] as $r) {
        $id = (string)($r['id'] ?? '');
        if (!preg_match('/^[a-z]{1,12}$/', $id)) continue;
        $x = (int)($r['x'] ?? -1); $y = (int)($r['y'] ?? -1); $w = (int)($r['w'] ?? 0); $h = (int)($r['h'] ?? 0);
        if ($x < 0 || $y < 0 || $w < 1 || $h < 1 || $x + $w > (int)$cv['w'] || $y + $h > (int)$cv['h']) continue;
        $out = array_map('intval', array_slice((array)($r['out'] ?? []), 0, 4));
        $t[$id] = ['id' => $id, 'label' => (string)($r['label'] ?? $id), 'x' => $x, 'y' => $y, 'w' => $w, 'h' => $h, 'act' => (string)($r['act'] ?? 'go'), 'out' => count($out) === 4 ? $out : [$x, $y, $w, $h]];
    }
    return $t;
}

/** One thing's link in the room picture: the dotted outline (shown on hover and focus, pulsing on the bed) and the tap box. $t: a hovel_things() row; $a: ['href', 'label', 'attr' => more attributes, 'cls']. */
function hovel_thing_svg(array $t, array $a): string
{
    [$ox, $oy, $ow, $oh] = $t['out'];
    return '<a class="ht ht-' . e($t['id']) . (($a['cls'] ?? '') !== '' ? ' ' . e($a['cls']) : '') . '" href="' . e($a['href']) . '"' . ($a['attr'] ?? '') . ' aria-label="' . e($a['label']) . '"><title>' . e($a['label']) . '</title>'
        . '<rect class="ht-out" x="' . $ox . '" y="' . $oy . '" width="' . $ow . '" height="' . $oh . '" rx="5"/>'
        . '<rect class="ht-hit" x="' . $t['x'] . '" y="' . $t['y'] . '" width="' . $t['w'] . '" height="' . $t['h'] . '"/></a>';
}

/**
 * The gnome standing at home. 2.7.20: sprite/gnome-home-big.png (48 x 72) in the catalogue's gnome box, its grey -hat / -beard layers tinted;
 * without it the old sprite/gnome-home.png (32 x 48) in the 'small' box (feet on the same spot, optional gnome-home-hat / -beard layers); else the layered avatar.
 */
function hovel_gnome_svg(array $u, array $g): string
{
    $x = (int)$g['x']; $y = (int)$g['y']; $w = (int)$g['w']; $h = (int)$g['h'];
    $name = 'gnome-home-big';
    $src = hovel_art('sprite/gnome-home-big.png');
    if ($src === '') {   // the old, small sprite: its own box, bottom-centred on the big one when the catalogue has no 'small'
        $name = 'gnome-home';
        $src = hovel_art('sprite/gnome-home.png');
        $sm = (array)($g['small'] ?? []);
        $sw = (int)($sm['w'] ?? 32); $sh = (int)($sm['h'] ?? 48);
        $x = isset($sm['x']) ? (int)$sm['x'] : $x + intdiv($w - $sw, 2); $y = isset($sm['y']) ? (int)$sm['y'] : $y + $h - $sh; $w = $sw; $h = $sh;
    }
    if ($src !== '') {
        require_once __DIR__ . '/pixel_art.php';
        $uid = '-h' . bin2hex(random_bytes(3));
        $hat = pixel_hex(gnome_hat_color($u));
        $bc = (string)($u['beard_color'] ?? '');
        $beard = pixel_hex(isset(BEARD_COLORS[$bc]) || dye_valid('beard', $bc) ? $bc : '#f4f1ea');
        $layers = '';
        $defs = '';
        foreach (['hat' => $hat, 'beard' => $beard] as $part => $hex) {
            $lsrc = hovel_art('sprite/' . $name . '-' . $part . '.png');
            if ($lsrc === '' || $hex === '') continue;
            if (!str_contains($defs, 'tint-' . $hex . $uid)) $defs .= pixel_tint_filter($hex, 1.25, $uid);
            $layers .= '<image href="' . e($lsrc) . '" x="' . $x . '" y="' . $y . '" width="' . $w . '" height="' . $h . '" image-rendering="pixelated" filter="url(#tint-' . $hex . $uid . ')"/>';
        }
        return ($defs !== '' ? '<defs>' . $defs . '</defs>' : '') . '<g class="hr-gnome"><image href="' . e($src) . '" x="' . $x . '" y="' . $y . '" width="' . $w . '" height="' . $h . '" image-rendering="pixelated"/>' . $layers . '</g>';
    }
    $x = (int)$g['x']; $y = (int)$g['y']; $w = (int)$g['w']; $h = (int)$g['h'];
    $av = gnome_avatar($u, $w);   // no sprite yet: the same layered (tinted) gnome as the avatar, standing in the gnome's box, feet on the floor
    return '<g class="hr-gnome">' . (string)preg_replace('/^<svg class="gnomeart" width="\d+" height="\d+"/', '<svg class="gnomeart" x="' . $x . '" y="' . $y . '" width="' . $w . '" height="' . $h . '" preserveAspectRatio="xMidYMax meet"', $av, 1) . '</g>';
}

/** The kettle overlay for this gnome's tier (users.kettle 1..3) while tea is open for them: ['src' => url or '', 'tier' => 0..3]. A missing file = the painted tin kettle. */
function hovel_kettle_art(array $u, bool $tea): array
{
    $tier = $tea ? max(0, min(3, (int)($u['kettle'] ?? 0))) : 0;
    $src = isset(HOVEL_KETTLE_FILES[$tier]) ? hovel_art('scenes/hovel-kettle-' . HOVEL_KETTLE_FILES[$tier] . '.png') : '';
    return ['src' => $src, 'tier' => $src !== '' ? $tier : 0];
}

/** The decor layer's file: scenes/hovel-<slot>-<item>.png; at dusk and night the window's -night twin when it is drawn (2.7.20), else the day picture. */
function hovel_slot_art(string $sk, string $ik, string $dp): string
{
    if ($sk === 'window' && in_array($dp, ['dusk', 'night'], true) && ($n = hovel_art('scenes/hovel-window-' . $ik . '-night.png')) !== '') return $n;
    return hovel_art('scenes/hovel-' . $sk . '-' . $ik . '.png');
}

/** One fx sprite (assets/img/fx/<f>.png) as an <image> with class $cls, or '' when the file is missing. */
function hovel_fx_img(string $f, string $cls, int $x, int $y, int $w, int $h): string
{
    $s = hovel_art('fx/' . $f . '.png');
    return $s !== '' ? '<image class="' . $cls . '" href="' . e($s) . '" x="' . $x . '" y="' . $y . '" width="' . $w . '" height="' . $h . '" image-rendering="pixelated"/>' : '';
}

/** The kettle's steam: two pixel puffs (fx/fx-steam-a 10 x 10, -b 8 x 8; 2.7.20) at this kettle tier's spout, animated by .hr-steam .a / .b; drawn circles when a file is missing. */
function hovel_steam_svg(int $tier): string
{
    [$sx, $sy] = HOVEL_KETTLE_STEAM[$tier] ?? HOVEL_KETTLE_STEAM[0];
    $a = hovel_fx_img('fx-steam-a', 'a', $sx, $sy, 10, 10);
    $b = hovel_fx_img('fx-steam-b', 'b', $sx + 5, $sy - 4, 8, 8);
    return '<g class="hr-steam" aria-hidden="true">' . ($a !== '' ? $a : '<circle class="a" cx="' . ($sx + 4) . '" cy="' . ($sy + 8) . '" r="2"/>')
        . ($b !== '' ? $b : '<circle class="b" cx="' . ($sx + 7) . '" cy="' . ($sy + 5) . '" r="1.6"/>') . '</g>';
}

/** The z's over the bed: pixel z's (fx/fx-z-a 8 x 8, -b 6 x 6; 2.7.20) animated by .hr-zz .a / .b; text letters when a file is missing. */
function hovel_zz_svg(): string
{
    $a = hovel_fx_img('fx-z-a', 'a', 96, 166, 8, 8);
    $b = hovel_fx_img('fx-z-b', 'b', 106, 159, 6, 6);
    return '<g class="hr-zz" aria-hidden="true">' . ($a !== '' ? $a : '<text class="a" x="98" y="176">z</text>') . ($b !== '' ? $b : '<text class="b" x="106" y="168">z</text>') . '</g>';
}

/**
 * The room as one SVG. $mode 'crop' = the banner (y104-224, 480x120), 'full' = the whole 480x270 room.
 * $o: 'taps' => true makes each slot a link that opens its picker (dialog with script, ?slot= without), 'sel' => slot key to mark.
 * 'things' => [id => ['href', 'label', 'attr', 'cls']] (full room, Today): the things of includes/data/hovel_things.php named here are links
 * (the decor slots are plain art then), with kettle steam, z's over the bed and the lamp's glow ('lamp' => true = lit).
 */
function hovel_room_svg(array $u, array $chosen, string $mode = 'crop', array $o = []): string
{
    $cat = hovel_decor_catalog();
    $W = (int)$cat['canvas']['w']; $H = (int)$cat['canvas']['h']; $fl = (int)$cat['canvas']['floor'];
    [$c0, $c1] = array_map('intval', $cat['canvas']['crop']);
    $full = $mode === 'full';
    $vb = $full ? '0 0 ' . $W . ' ' . $H : '0 ' . $c0 . ' ' . $W . ' ' . max(1, $c1 - $c0);
    $things = $full && isset($o['things']) && is_array($o['things']) ? $o['things'] : null;
    $taps = $full && !empty($o['taps']) && $things === null;
    $sel = (string)($o['sel'] ?? '');
    $names = [];
    foreach ($cat['slots'] as $sk => $s) $names[] = $s['name'] . ': ' . ($s['items'][$chosen[$sk] ?? '']['name'] ?? '');
    $dp = (string)($o['daypart'] ?? '');
    $tea = tea_open_for($u);   // the kettle on the side table is a link (the tea popover); closed for this viewer = plain art, no hit box
    $svg = '<svg class="hroom hroom-' . ($full ? 'full' : 'crop') . ($things !== null ? ' hroom-things' . (!empty($o['lamp']) ? ' lamp-on' : '') : '') . ($dp !== '' ? ' dp-' . e(preg_replace('/[^a-z]/', '', $dp)) : '') . '" viewBox="' . $vb . '"'
        . ($taps ? ' role="group" aria-label="' . e('Your room. ' . implode(', ', $names) . '. Tap a thing to change it.') . '"'
            : ($things !== null ? ' role="group" aria-label="' . e('Your hovel. ' . implode(', ', $names) . '. Tap a thing to use it.') . '"' : ($tea ? ' role="group" aria-label="' . e('Your hovel. ' . implode(', ', $names) . '. Tap the kettle to brew tea.') . '"' : ' role="img" aria-label="' . e('Your hovel. ' . implode(', ', $names)) . '"'))) . ' focusable="false">';
    $back = hovel_art('scenes/hovel-room.png');
    $kart = ['src' => '', 'tier' => 0];
    if ($back !== '') {
        $svg .= '<image class="hr-back" href="' . e($back) . '" x="0" y="0" width="' . $W . '" height="' . $H . '" image-rendering="pixelated"/>';
        $kart = hovel_kettle_art($u, $tea);   // the Copper / Cast-Iron / Samovar over the painted tin kettle (only on the real picture: it is painted to match it)
        if ($kart['src'] !== '') {
            [$kx, $ky, $kw, $kh] = HOVEL_KETTLE_ART;
            $svg .= '<image class="hr-kettle hr-kettle-' . HOVEL_KETTLE_FILES[$kart['tier']] . '" href="' . e($kart['src']) . '" x="' . $kx . '" y="' . $ky . '" width="' . $kw . '" height="' . $kh . '" image-rendering="pixelated"/>';
        }
    } else {   // no picture yet: a drawn wall, floor, skirting and bed, so the room still reads and the slots still line up
        $svg .= '<rect class="hr-wall" x="0" y="0" width="' . $W . '" height="' . $fl . '"/><rect class="hr-floor" x="0" y="' . $fl . '" width="' . $W . '" height="' . max(1, $H - $fl) . '"/>'
            . '<rect class="hr-beam" x="0" y="40" width="' . $W . '" height="8"/><rect class="hr-bed" x="384" y="176" width="88" height="44"/><rect class="hr-pillow" x="444" y="168" width="24" height="12"/>'
            . '<line class="hr-skirt" x1="0" y1="' . $fl . '" x2="' . $W . '" y2="' . $fl . '"/>';
    }
    foreach ($cat['slots'] as $sk => $s) {
        $ik = $chosen[$sk] ?? '';
        $src = hovel_slot_art($sk, $ik, $dp);
        $box = 'x="' . $s['x'] . '" y="' . $s['y'] . '" width="' . $s['w'] . '" height="' . $s['h'] . '"';
        $lay = $src !== '' ? '<image href="' . e($src) . '" ' . $box . ' image-rendering="pixelated"/>' : '<rect class="hd-ph" ' . $box . '/>';
        $cls = 'hd hd-' . $sk . ($sk === $sel ? ' sel' : '');
        if ($taps) {   // the tap area is the slot's box, at least 56 units each way (44 px at 412 wide), centred on it
            $hw = max(56, $s['w']); $hh = max(56, $s['h']);
            $hx = max(0, min($W - $hw, $s['x'] - intdiv($hw - $s['w'], 2))); $hy = max(0, min($H - $hh, $s['y'] - intdiv($hh - $s['h'], 2)));
            if ($sk === 'floor') { $hy = $s['y']; $hh = $s['h']; }
            $label = $s['name'] . ': ' . ($s['items'][$ik]['name'] ?? '') . '. Change';
            $svg .= '<a class="' . $cls . '" href="' . e(hovel_slot_url($sk)) . '" data-hdlg="hpick-' . e($sk) . '" aria-label="' . e($label) . '"><title>' . e($label) . '</title>' . $lay
                . '<rect class="hd-hit" x="' . $hx . '" y="' . $hy . '" width="' . $hw . '" height="' . $hh . '"/></a>';
        } else {
            $svg .= '<g class="' . $cls . '">' . $lay . '</g>';
        }
    }
    if ($things !== null) {   // Today: the room's things are the links. Order: the cute bits, the gnome, the night tint, the lamp's glow, then every tap box on top
        $T = hovel_things();
        $lamp = $cat['slots']['lamp'] ?? ['x' => 276, 'y' => 180, 'w' => 16];
        $lx = (int)$lamp['x'] + intdiv((int)$lamp['w'], 2); $ly = (int)$lamp['y'] + 6;
        $svg .= '<defs><radialGradient id="hr-lampg"><stop offset="0" stop-color="#fff3b0" stop-opacity=".85"/><stop offset=".45" stop-color="#ffd98a" stop-opacity=".4"/><stop offset="1" stop-color="#ffd98a" stop-opacity="0"/></radialGradient></defs>'
            . hovel_steam_svg($kart['tier'])
            . hovel_gnome_svg($u, $cat['gnome'])
            . '<rect class="hr-tint" x="0" y="0" width="' . $W . '" height="' . $H . '" aria-hidden="true"/>'
            . '<circle class="hr-lampglow" cx="' . $lx . '" cy="' . $ly . '" r="34" fill="url(#hr-lampg)" aria-hidden="true"/>'
            . (isset($things['bed']) ? hovel_zz_svg() : '');
        foreach ($T as $id => $t) {
            if ($id === 'kettle') {   // the tea kettle keeps its own link and dialog (includes/tea_view.php); closed for this viewer = plain art
                if (!$tea) continue;
                [$ox, $oy, $ow, $oh] = $t['out'];
                $svg .= '<a class="hd hd-kettle" href="' . e(url('gnome.php?tea=1') . '#htea') . '" data-hdlg="htea" aria-label="The kettle. Brew a cup of tea"><title>The kettle. Brew a cup of tea</title>'
                    . '<rect class="ht-out" x="' . $ox . '" y="' . $oy . '" width="' . $ow . '" height="' . $oh . '" rx="5"/>'
                    . '<rect class="hd-hit" x="' . $t['x'] . '" y="' . $t['y'] . '" width="' . $t['w'] . '" height="' . $t['h'] . '"/></a>';
                continue;
            }
            if (isset($things[$id])) $svg .= hovel_thing_svg($t, $things[$id]);
        }
        return $svg . '</svg>';
    }
    if ($tea) {   // the kettle is painted into scenes/hovel-room.png at about x 320-350, y 163-185: a 64 x 64 tap area around it, inside the banner crop and clear of the lamp's and the shelf's
        [$kx, $ky, $kw, $kh] = HOVEL_KETTLE_HIT;
        $svg .= '<a class="hd hd-kettle" href="' . e(url('gnome.php?tea=1') . '#htea') . '" data-hdlg="htea" aria-label="The kettle. Brew a cup of tea"><title>The kettle. Brew a cup of tea</title>'
            . '<rect class="hd-hit" x="' . $kx . '" y="' . $ky . '" width="' . $kw . '" height="' . $kh . '"/></a>';
    }
    $svg .= hovel_gnome_svg($u, $cat['gnome']);
    $svg .= '<rect class="hr-tint" x="0" y="0" width="' . $W . '" height="' . $H . '" aria-hidden="true"/>';
    return $svg . '</svg>';
}

/** The latest post (News or Release notes) and whether this gnome has seen it: ['post' => row|null, 'unread' => bool]. */
function home_slim_news(int $uid): array
{
    static $memo = [];
    if (isset($memo[$uid])) return $memo[$uid];
    $p = null;
    try { $p = q_one('SELECT title, kind, created_at FROM news WHERE published = 1 ORDER BY created_at DESC, id DESC LIMIT 1'); } catch (Throwable $e) {}
    $unread = false;
    if ($p) {
        $at = (int)strtotime($p['created_at'] . ' UTC');
        $seen = hub_seen_get($uid, 'news');
        $unread = $seen === null ? $at > time() - 14 * 86400 : $at > (int)strtotime($seen . ' UTC');   // never opened the news: only a post from the last two weeks counts as new
    }
    return $memo[$uid] = ['post' => $p, 'unread' => $unread];
}

/** The address of the news list (the latest post's tab). */
function home_slim_news_url(?array $p): string
{
    return url('index.php?news=all' . ($p && ($p['kind'] ?? '') === 'notes' ? '&tab=notes' : '') . '#news');
}

/** A short "where it goes" word for a Needs you row, from its link. */
function home_slim_go(string $href): string
{
    $p = (string)parse_url($href, PHP_URL_PATH);
    $qs = (string)parse_url($href, PHP_URL_QUERY);
    return match (basename($p)) {
        'garden.php' => str_contains($qs, 't=help') ? 'Crew' : 'Garden', 'jobs.php' => 'Tasks', 'community.php' => 'Read', 'paljobs.php' => 'Collect',
        'inventory.php' => str_contains($qs, 'pantry') ? 'Pantry' : 'Kitchen', 'villagers.php' => 'Visit', 'market.php' => 'Market', 'festival.php' => 'Festival',
        'firstweek.php' => 'First Week', 'back.php' => 'Look', 'book.php' => 'Almanac', default => 'Open',
    };
}

/**
 * The TODAY tab's one list: the home cards' helper (welcome back, First Week, the daily card, a festival), the Hovel's "needs you",
 * what finished overnight (pots, jars) and friends' birthdays. Returns ['need' => [[icon, title, small, href]], 'quiet' => [text]]:
 * the crew report and who is away go in the quiet line under the list.
 */
function home_slim_needs(array $u): array
{
    require_once __DIR__ . '/today.php';
    $need = []; $quiet = [];
    try {
        require_once __DIR__ . '/tour.php';
        $slot = helper_slot($u);
        if ($slot === 'back') $need[] = ['👋', 'Welcome back!', 'See what grew while you were away.', url('back.php')];
        elseif ($slot === 'fw' && ($fw = first_week_today_card((int)$u['id']))) {
            $nDone = count(array_filter($fw['tasks'], fn($t) => $t[4]));
            $need[] = ['🐦', 'First Week', 'Day ' . (int)$fw['day'] . ': ' . $nDone . ' of ' . count($fw['tasks']) . ' done' . ($fw['done'] ? ' · a gift is ready' : ''), url('firstweek.php')];
        } elseif ($slot === 'daily' && ($dc = daily_card($u)) && empty($dc['done'])) $need[] = [(string)$dc['icon'], 'Today', (string)$dc['text'], url((string)$dc['link'])];
        elseif ($slot === 'fest' && ($fe = festival_active())) $need[] = [(string)$fe['icon'], (string)$fe['name'], 'Day ' . (int)$fe['day'] . ' of ' . (int)$fe['days'] . '. The Hollow is celebrating.', url('festival.php')];
    } catch (Throwable $e) {}
    $d = ['need' => [], 'night' => [], 'village' => []];
    try { $d = today_data($u); } catch (Throwable $e) {}
    $beds = 0; $why = []; $bedPlot = [];
    foreach ($d['need'] as $n) {
        if (str_contains((string)$n[1], ' is tired of ')) continue;   // 2.7.17: tired pals show as a tag in the Your pals box
        if (str_starts_with((string)$n[1], 'Plant: ')) {   // 2.7.17: the crew's empty-bed warnings become one row: how many beds, and why
            if (preg_match('/(\d+) beds? left empty: (.+)$/', (string)$n[1], $m)) { $beds += (int)$m[1]; $why[] = $m[1] . ' ' . $m[2]; }
            else { $beds++; $why[] = substr((string)$n[1], 7); }
            if ($n[2] !== '') $bedPlot[(string)$n[2]] = 1;
            continue;
        }
        $need[] = $n;
    }
    if ($beds > 0) $need[] = ['🌰', $beds . ' bed' . ($beds === 1 ? '' : 's') . ' empty', implode(' · ', $bedPlot ? array_keys($bedPlot) : []) . ($bedPlot && $why ? ': ' : '') . implode(', ', $why), url('garden.php?t=help')];
    foreach ($d['night'] as $n) {
        if ($n[3] === '') continue;   // the weather: it is on the banner's tag
        if (str_contains($n[3], 'hovel.php')) continue;   // the garden crew has its own Overnight list (home_slim_overnight)
        $need[] = $n;
    }
    foreach ($d['village'] as $n) {
        if (str_contains($n[1], 'birthday')) { $need[] = [$n[0], $n[1], $n[2], url('villagers.php')]; continue; }
        $quiet[] = rtrim($n[1], '.') . ($n[2] !== '' ? ' · ' . $n[2] : '') . '.';
    }
    return ['need' => $need, 'quiet' => $quiet];
}

/**
 * 2.7.17: the "Your pals" box on the Today tab, three groups: the garden crew (one summary of last night + a chip per pal, two to a row),
 * pals at a station (Kitchen, Pantry, Workshop...: made so far, time left or full time) and pals out on a trip or delve (back in).
 * Returns ['crew' => ['sum' => '', 'sub' => '', 'chips' => [[icon, name, working %, job finished]], 'href' => ''] | null, 'stations' => [[icon, title, small, href]], 'out' => [[icon, title, small, href, pct]], 'n' => pals].
 * Never throws.
 */
function home_slim_overnight(array $u): array
{
    $o = ['crew' => null, 'stations' => [], 'out' => [], 'n' => 0];
    $uid = (int)$u['id'];
    try {
        require_once __DIR__ . '/pal_crew.php';
        $rep = pcrew_latest_report($uid);
        if ($rep && (int)$rep[0] === (int)$u['game_day'] && !empty($rep[1]['crew'])) {
            $tot = ['harvest' => 0, 'water' => 0, 'plant' => 0, 'weed' => 0, 'pests' => 0]; $chips = [];
            foreach ($rep[1]['crew'] as $c) {
                $role = (string)($c['role'] ?? '');
                if (isset($tot[$role])) $tot[$role] += (int)($c['n'] ?? 0);
                $pct = isset($c['eff']) ? (int)$c['eff'] : 100;
                $chips[] = [PCREW_ROLES[$role][0] ?? '🧩', (string)($c['pal'] ?? 'A pal'), $pct, !empty($c['ended'])];   // [icon, name, working %, job finished]
            }
            $words = ['harvest' => '%d crops picked', 'water' => '%d beds watered', 'plant' => '%d planted', 'weed' => '%d beds weeded', 'pests' => 'pests cleared from %d beds'];
            $bits = [];
            foreach ($tot as $r => $n) if ($n > 0) $bits[] = sprintf($words[$r], $n);
            $o['crew'] = ['sum' => $bits ? implode(' · ', array_slice($bits, 0, 2)) : 'Nothing to do last night', 'sub' => implode(' · ', array_slice($bits, 2)), 'chips' => $chips, 'href' => url('garden.php?t=help')];
            $o['n'] += count($chips);
        }
    } catch (Throwable $e) {}
    try {
        require_once __DIR__ . '/pal_jobs.php';
        if (pj_open($u)) {
            $list = function_exists('pj_station_list') ? pj_station_list() : [];
            $left = function (string $ends): string {
                $t = strtotime($ends);
                if (!$t || $t - time() > 86400 * 365) return 'full time';
                return $t <= time() ? 'time is up' : pj_ago($t - time()) . ' left';
            };
            foreach (q("SELECT * FROM ppal_jobs WHERE user_id = ? AND state = 'active' AND kind IN ('station','trip','delve') ORDER BY id", [$uid])->fetchAll() as $j) {
                $pal = pj_pal($uid, (string)$j['pal_uid']);
                $name = (string)($pal['name'] ?? 'A pal');
                $n = (int)$j['tasks'];
                $o['n']++;
                if ($j['kind'] === 'station') {
                    $isJars = ($j['tool'] ?? '') === 'jars';
                    $cook = str_starts_with((string)$j['target'], 'cooking');
                    $lab = $list[$j['target']] ?? null;
                    $area = $isJars ? 'Pantry' : ($lab ? ($lab[1] === 'Whole station' ? $lab[0] : $lab[0] . ': ' . $lab[1]) : 'Station');
                    $o['stations'][] = [$isJars ? '🫙' : ($cook ? '🍳' : '🛠️'), $name . ' · ' . $area, ($n > 0 ? $n . ($isJars ? ' jars' : '') . ' made' : 'Nothing made yet') . ' · ' . $left((string)$j['ends_at']),
                        $isJars ? url('inventory.php?tab=craft&c=pantry') : ($cook ? url('inventory.php?tab=craft&c=cooking') : url('paljobs.php'))];
                } else {
                    $t = strtotime((string)$j['ends_at']); $t0 = strtotime((string)$j['started_at']);
                    $pct = $t && $t0 && $t > $t0 ? (int)max(0, min(100, round((time() - $t0) * 100 / ($t - $t0)))) : 0;
                    $o['out'][] = [$j['kind'] === 'delve' ? '⛏️' : '🌲', $name . ' · ' . ($j['kind'] === 'delve' ? 'delve' : 'trip'), $t && $t > time() ? 'Back in ' . pj_ago($t - time()) : 'Back any moment', url('paljobs.php'), $pct];
                }
            }
        }
    } catch (Throwable $e) {}
    return $o;
}

/** 2.7.16: is the Closet tab there (wearables open to everyone, not a guest)? */
function home_slim_closet_on(array $u): bool
{
    require_once __DIR__ . '/wearables.php';
    if (is_guest($u) || !wear_live($u)) return false;
    require_once __DIR__ . '/wear_view.php';
    return true;
}

/** Badges for the three tabs: ['today' => needs count, 'news' => unread, 'furnish' => new items, 'gnome' => stat points + a calling to choose]. */
function home_slim_badges(array $u, int $needN): array
{
    $g = (int)$u['stat_points'] + (!$u['calling'] && (int)$u['level'] >= (int)setting('calling_level') ? 1 : 0);
    $cl = home_slim_closet_on($u);   // 2.7.16: the Closet tab (the Wearing panel moved here from the Gnome tab)
    return ['today' => $needN, 'news' => home_slim_news((int)$u['id'])['unread'], 'furnish' => 0, 'gnome' => $g, 'closet_on' => $cl, 'closet' => $cl ? wear_closet_badge($u) : 0];
}

/** A gold count badge, or '' for none. */
function home_slim_bang(int|string $n, string $label): string
{
    if ($n === 0 || $n === '') return '';
    return '<b class="hs-bang" role="img" aria-label="' . e($label) . '">' . e((string)$n) . '</b>';
}

/**
 * The ways to rest right now, sorted for the banner and the bed's card (gclock_rest_options() decides what is on offer, its price and
 * whether it can be done): ['main' => the first sleep that can be done (else the first), 'nap' => the nap, 'others' => the other sleeps,
 * 'notes' => [lines under the buttons], 'plain' => true when 'main' is a free night in your own bed and nothing needs saying].
 */
function home_slim_rest(array $u, array $s): array
{
    $opts = gclock_rest_options($u);
    $sleep = array_values(array_filter($opts, fn($o) => $o['kind'] !== 'nap'));
    $nap = array_values(array_filter($opts, fn($o) => $o['kind'] === 'nap'));
    $main = null; foreach ($sleep as $o) if ($o['ok']) { $main = $o; break; }
    $main ??= $sleep[0] ?? null;
    $notes = []; $plain = false;
    if ($main) {
        $note = $main['key'] === 'home_sleep' ? 'Sleep: fresh start at 06:00' : $main['label'] . ' · ' . $main['cost'];
        $plain = $main['key'] === 'home_sleep' && $main['ok'] && !$s['tired'];
        if (!$main['ok']) $note = $main['label'] . ': ' . $main['why'];
        if ($s['tired']) $note = 'After 22:00 everything costs +' . game_surcharge_pct($u) . '% energy. Sleep to start fresh at 06:00.';
        $notes[] = $note;
        if (($busy = gclock_busy_minutes((int)$u['id'])) > 0) $notes[] = round($busy / 60, 1) . ' h of work still to finish. Sleep, and it is done first thing in the morning.';
    }
    return ['main' => $main, 'nap' => $nap[0] ?? null, 'others' => array_values(array_filter($sleep, fn($o) => $o !== $main)), 'notes' => $notes, 'plain' => $plain];
}

/** What a rest button says when you hover it: its full name, the price, and why not. */
function home_slim_rest_title(array $o): string
{
    return $o['label'] . ' · ' . $o['cost'] . ($o['ok'] ? '' : ' · ' . $o['why']);
}

/** Where the room's door leads: [address, label]. The Here page (the town page without the picture pages), named after where the gnome is. */
function hovel_door(array $u): array
{
    $name = '';
    try {
        $lid = (int)($u['location_id'] ?? 0) ?: (int)($u['home_village_id'] ?? 0);
        $loc = $lid > 0 ? q_one('SELECT * FROM locations WHERE id = ?', [$lid]) : null;
        if ($loc) { require_once __DIR__ . '/destination.php'; $name = dest_name((int)$u['id'], $loc); }
    } catch (Throwable $e) {}
    if ($name === '???') $name = '';
    return [url(gnav_on() ? 'here.php' : 'town.php'), 'The door. Step out' . ($name !== '' ? ' to ' . $name : '')];
}

/** What the gnome says when tapped: the greeting, then a short mood line from energy and the hour. */
function hovel_gnome_lines(array $u, string $hello, ?array $s): array
{
    $max = max(1, max_energy($u)); $e = (int)($u['energy'] ?? 0);
    if ($s && $s['tired']) $mood = 'Sleepy... bed soon?';
    elseif ($e * 10 >= $max * 7) $mood = 'Rested and ready!';
    elseif ($e * 10 <= $max * 3) $mood = 'Tired: a nap?';
    else $mood = 'A fine day for a wander.';
    return [$hello . '!', $mood];
}

/** Is the lamp lit? By itself at dusk and at night; ?lamp=on / ?lamp=off is the no-script switch (a look only, nothing is saved). */
function hovel_lamp_on(string $dp): bool
{
    $g = (string)($_GET['lamp'] ?? '');
    return $g === 'on' || ($g !== 'off' && in_array($dp, ['dusk', 'night'], true));
}

/**
 * The slim banner. TODAY: the whole room with its tappable things, the time tag, a one-line greeting and the row of small rest buttons.
 * The other tabs: the room crop (on FURNISH also the whole room with the decor slots, shown on a phone), the greeting, Go to sleep and Nap.
 */
function home_slim_banner_html(array $u, array $chosen, string $tab, string $hello): string
{
    $s = gclock_on() ? gclock_state($u) : null;
    $now = hollow_now(hollow_user_region($u), null, $s);
    $tag = ($s ? sprintf('%02d:%02d', intdiv($s['minute'], 60) % 24, $s['minute'] % 60) : (string)$now['daypart_label'])
        . ' · ' . $now['season_label'] . ' ' . (int)$now['season_day'] . ' · ' . $now['weather_label'];
    $dp = (string)$now['daypart'];
    $tagHtml = '<span class="hs-tag">' . e($tag) . '</span>';
    $rest = $s ? home_slim_rest($u, $s) : null;
    if ($tab === 'today') {
        $lamp = hovel_lamp_on($dp);
        [$doorHref, $doorLabel] = hovel_door($u);
        $things = [
            'window' => ['href' => url('gnome.php?thing=window') . '#hp-window', 'label' => 'The window. Today’s weather: ' . $now['weather_label'], 'attr' => ' data-hdlg="hp-window"'],
            'gnome' => ['href' => url('gnome.php?tab=gnome'), 'label' => 'Your gnome. Say hello', 'attr' => ' data-hsay="' . e((string)json_encode(hovel_gnome_lines($u, $hello, $s), JSON_UNESCAPED_UNICODE)) . '"'],
            'lamp' => ['href' => url('gnome.php?lamp=' . ($lamp ? 'off' : 'on')), 'label' => 'The lamp. Switch the light', 'attr' => ' data-hlamp role="button" aria-pressed="' . ($lamp ? 'true' : 'false') . '"'],
            'door' => ['href' => $doorHref, 'label' => $doorLabel],
        ];
        if ($rest && $rest['main']) $things['bed'] = ['href' => url('gnome.php?thing=bed') . '#hp-bed', 'label' => 'Your bed. Sleep or nap', 'attr' => ' data-hdlg="hp-bed"', 'cls' => 'pulse'];
        $h = '<section class="hs-banner" aria-label="Your hovel">'
            . '<div class="hs-pic hs-room">' . hovel_room_svg($u, $chosen, 'full', ['things' => $things, 'lamp' => $lamp, 'daypart' => $dp]) . $tagHtml
            . '<span class="hs-say" role="status" hidden></span></div>'
            . '<div class="hs-side"><h1 class="hs-hi">' . e($hello) . ', ' . e((string)strtok(gnome_name($u), ' ')) . '!</h1>';
        if ($rest && $rest['main']) {   // the row of small buttons: the same rest options as the big buttons had (same keys, prices and disabled states)
            $sb = fn(array $o, string $label, string $cls): string => '<button class="btn small hs-sb' . $cls . '" type="submit" name="do" value="' . e($o['key']) . '" title="' . e(home_slim_rest_title($o)) . '"' . ($o['ok'] ? '' : ' disabled') . '>' . e($label) . '</button>';
            $inn = fn(array $o): string => '🛏️ Inn · ' . (int)$o['cost'];
            $m = $rest['main'];
            $h .= '<form method="post" action="' . e(url('hovel.php')) . '" class="hs-rest">' . csrf_field() . '<input type="hidden" name="back" value="today"><div class="hs-btns">'
                . $sb($m, $m['key'] === 'inn_pay' ? $inn($m) : '🌙 Sleep', '') . ($rest['nap'] ? $sb($rest['nap'], '💤 Nap', ' ghost') : '');
            $more = 0;
            foreach ($rest['others'] as $o) { if ($o['key'] === 'inn_pay') $h .= $sb($o, $inn($o), ' ghost'); else $more++; }
            if ($more > 0) $h .= '<a class="btn small ghost hs-sb" href="' . e(url('gnome.php?thing=bed') . '#hp-bed') . '" data-hdlg="hp-bed">Other beds</a>';
            $h .= '</div>';
            foreach (array_slice($rest['notes'], $rest['plain'] ? 1 : 0) as $note) $h .= '<p class="hs-note">' . e($note) . '</p>';   // a plain night at home needs no line (the bed's card has it)
            $h .= '</form>';
        }
        return $h . '</div></section>';
    }
    $h = '<section class="hs-banner" aria-label="Your hovel">'
        . '<div class="hs-pic hs-crop">' . hovel_room_svg($u, $chosen, 'crop', ['daypart' => $dp]) . $tagHtml . '</div>';
    if ($tab === 'furnish') $h .= '<div class="hs-pic hs-full">' . hovel_room_svg($u, $chosen, 'full', ['taps' => true, 'sel' => (string)($_GET['slot'] ?? ''), 'daypart' => $dp]) . $tagHtml . '</div>';
    $h .= '<div class="hs-side"><h1>' . e($hello) . ', ' . e(gnome_name($u)) . '!</h1>';
    if ($rest) {
        $main = $rest['main']; $n0 = $rest['nap'];
        $back = in_array($tab, ['today', 'furnish', 'gnome'], true) ? $tab : 'today';
        $btn = fn(array $o, string $label, string $cls) => '<button class="btn big' . $cls . '" type="submit" name="do" value="' . e($o['key']) . '" title="' . e(home_slim_rest_title($o)) . '"' . ($o['ok'] ? '' : ' disabled') . '>' . e($label) . '</button>';
        $h .= '<form method="post" action="' . e(url('hovel.php')) . '" class="hs-rest">' . csrf_field() . '<input type="hidden" name="back" value="' . e($back) . '">'
            . '<div class="hs-acts">' . ($main ? $btn($main, 'Go to sleep', '') : '') . ($n0 ? $btn($n0, 'Nap', ' ghost') : '') . '</div>';
        foreach ($rest['notes'] as $note) $h .= '<p class="hs-note">' . e($note) . '</p>';
        if ($rest['others']) {
            $h .= '<details class="hs-more"><summary>Other beds</summary>';
            foreach ($rest['others'] as $o) $h .= '<p><button class="btn small ghost" type="submit" name="do" value="' . e($o['key']) . '"' . ($o['ok'] ? '' : ' disabled') . '>' . e($o['label']) . '</button> <small>' . e($o['cost'] . ($o['ok'] ? '' : ' · ' . $o['why'])) . '</small></p>';
            $h .= '</details>';
        }
        $h .= '</form>';
    }
    return $h . '</div></section>';
}

/**
 * The cards behind the room's things on TODAY: the bed (every way to rest, as the big buttons and "Other beds" had them) and the window
 * (today's and tomorrow's weather). Each is a <dialog> opened by its thing in the picture (site.js, data-hdlg); with ?thing=bed or
 * ?thing=window in the address it is drawn open in the page (no script).
 */
function home_slim_things_html(array $u): string
{
    $open = (string)($_GET['thing'] ?? '');
    $s = gclock_on() ? gclock_state($u) : null;
    $close = '<a class="btn alt" href="' . e(url('gnome.php')) . '" data-hdlg-close>Close</a>';
    $h = '';
    $rest = $s ? home_slim_rest($u, $s) : null;
    if ($rest && $rest['main']) {
        $m = $rest['main']; $n0 = $rest['nap'];
        $btn = fn(array $o, string $label, string $cls): string => '<button class="btn' . $cls . '" type="submit" name="do" value="' . e($o['key']) . '" title="' . e(home_slim_rest_title($o)) . '"' . ($o['ok'] ? '' : ' disabled') . '>' . e($label) . '</button>';
        $h .= '<dialog class="hpick hpop" id="hp-bed" aria-labelledby="hp-bed-h"' . ($open === 'bed' ? ' open' : '') . '>'
            . '<form method="post" action="' . e(url('hovel.php')) . '">' . csrf_field() . '<input type="hidden" name="back" value="today">'
            . '<div class="hpick-h"><h3 id="hp-bed-h"><span aria-hidden="true">🛏️</span> Your bed</h3>';
        foreach ($rest['notes'] as $note) $h .= '<small>' . e($note) . '</small>';
        $h .= '</div><div class="hpop-acts">' . $btn($m, 'Go to sleep', '') . ($n0 ? $btn($n0, 'Nap', ' ghost') : '') . '</div>';
        $h .= '<small class="hpop-sm">' . e(home_slim_rest_title($m)) . ($n0 ? '<br>' . e(home_slim_rest_title($n0)) : '') . '</small>';
        if ($rest['others']) {
            $h .= '<h4 class="hpop-sub">Other beds</h4><ul class="hpop-beds">';
            foreach ($rest['others'] as $o) $h .= '<li><button class="btn small ghost" type="submit" name="do" value="' . e($o['key']) . '"' . ($o['ok'] ? '' : ' disabled') . '>' . e($o['label']) . '</button> <small>' . e($o['cost'] . ($o['ok'] ? '' : ' · ' . $o['why'])) . '</small></li>';
            $h .= '</ul>';
        }
        $h .= '<div class="hpick-act">' . $close . '</div></form></dialog>';
    }
    $now = hollow_now(hollow_user_region($u), null, $s);
    $tom = null;
    try { $tom = hollow_forecast(hollow_user_region($u), 2)[1] ?? null; } catch (Throwable $e) {}
    $h .= '<dialog class="hpick hpop" id="hp-window" aria-labelledby="hp-window-h"' . ($open === 'window' ? ' open' : '') . '><div class="hpop-in">'
        . '<div class="hpick-h"><h3 id="hp-window-h">Out the window</h3><small>' . e($now['season_label'] . ', day ' . (int)$now['season_day']) . '</small></div>'
        . '<ul class="hpop-wx"><li><small>Today</small><b><span aria-hidden="true">' . e((string)$now['weather_emoji']) . '</span> ' . e((string)$now['weather_label']) . '</b></li>'
        . ($tom ? '<li><small>Tomorrow</small><b><span aria-hidden="true">' . e((string)$tom['emoji']) . '</span> ' . e((string)$tom['wlabel']) . '</b></li>' : '') . '</ul>'
        . '<div class="hpick-act"><a class="btn ghost" href="' . e(url('seasons.php')) . '">Seasons →</a>' . $close . '</div></div></dialog>';
    return $h;
}

/** The three tabs (plain links, so they load in place with AJAX_PAGES and work without script). $cur: 'today', 'furnish', 'gnome' or a Gnome sub-page. */
function home_slim_tabs_html(string $cur, array $b): string
{
    $T = ['today' => 'Today', 'furnish' => 'Furnish', 'gnome' => 'Gnome'] + (!empty($b['closet_on']) ? ['closet' => 'Closet'] : []);
    $on = isset($T[$cur]) ? $cur : 'gnome';
    $h = '<nav class="tabs hometabs hstabs' . (isset($T['closet']) ? ' hs4' : '') . '" aria-label="Home">';
    foreach ($T as $k => $l) {
        $href = url($k === 'today' ? 'gnome.php' : 'gnome.php?tab=' . $k);
        $bang = home_slim_bang((int)($b[$k] ?? 0), ($b[$k] ?? 0) . ' new')
            . ($k === 'today' && !empty($b['news']) ? '<b class="hs-bang" role="img" aria-label="Unread news">!</b>' : '');
        $h .= '<a href="' . e($href) . '"' . ($k === $on ? ' class="on"' . ($k === $cur ? ' aria-current="page"' : '') : '') . '>' . e($l) . $bang . '</a>';
    }
    return $h . '</nav>';
}

/** The news row on TODAY: unread = paper with a gold "!", read = quiet felt. */
function home_slim_news_html(int $uid): string
{
    $n = home_slim_news($uid);
    $p = $n['post'];
    if (!$p) return '<p class="hs-newsl"><a href="' . e(url('index.php?news=all#news')) . '">News &amp; release notes →</a></p>';
    $when = gmdate('M j', (int)strtotime($p['created_at'] . ' UTC')) . ' · ' . ($p['kind'] === 'notes' ? 'release notes' : 'news');
    if ($n['unread']) {
        $h = '<a class="box hs-news unread" href="' . e(home_slim_news_url($p)) . '"><span class="hs-ni" aria-hidden="true">📰<b class="hs-bang">!</b></span>'
            . '<span class="hs-tx"><b>New: ' . e($p['title']) . '</b><small>' . e($when) . '</small></span><span class="hs-go">Read →</span></a>';
    } else {
        $h = '<a class="hs-news read" href="' . e(home_slim_news_url($p)) . '"><span class="hs-tx"><small>Latest news, read</small><b>' . e($p['title']) . '</b></span><span class="hs-go">All news →</span></a>';
    }
    return $h . '<p class="hs-newsl"><a href="' . e(url('index.php?news=all#news')) . '">News &amp; release notes →</a></p>';
}

/** The TODAY tab: Needs you, the news row; the Hollow line on the side. */
function home_slim_today_html(array $u, array $needs): string
{
    $uid = (int)$u['id'];
    $h = '<div class="hs-cols"><div class="hs-main">';
    $teaOn = tea_open_for($u);
    $h .= home_slim_things_html($u);   // the bed's and the window's cards (opened by the things in the room picture)
    if ($teaOn) { require_once __DIR__ . '/tea_view.php'; $h .= tea_dialog_html($u, isset($_GET['tea'])); }   // the kettle's popover (opened by the kettle in the banner; ?tea=1 draws it open here)
    require_once __DIR__ . '/puzzle_pals.php';
    if (ppal_open() && !is_guest($u)) { require_once __DIR__ . '/pal_jobs.php'; $h .= pj_home_notice_html($u); }   // pals back from a trip or delve
    $n = count($needs['need']);
    $h .= '<section class="box hs-needs" aria-labelledby="hs-needs-h"><h2 id="hs-needs-h">Needs you' . home_slim_bang($n, $n . ' thing' . ($n === 1 ? '' : 's')) . '</h2>';
    if ($needs['need']) {   // 2.7.17: things that pile up (N crops ripe, N pots done, N jars ready, N beds empty...) are big-number tiles; the rest are slim rows under them
        $tiles = []; $cards = [];   // C (Josh): things you collect (N crops ripe, N pots done, N jars ready, N pal trips ready) sit three across; everything else is a wide card under them
        foreach ($needs['need'] as $r) {
            if (preg_match('/^(\d+) (.+)$/', (string)$r[1], $m) && !str_contains((string)$r[3], 't=help')) $tiles[] = [$r, $m[1], $m[2]]; else $cards[] = $r;
        }
        if ($tiles) {
            $h .= '<div class="hs-t3">';
            foreach ($tiles as [$r, $num, $lab]) $h .= '<a class="hs-tile hot" href="' . e($r[3]) . '"><span class="hs-ti" aria-hidden="true">' . e($r[0]) . '</span><span class="hs-tn">' . e($num) . '</span><b>' . e($lab) . '</b></a>';
            $h .= '</div>';
        }
        foreach ($cards as [$ic, $tt, $sm, $href]) {
            $in = '<span class="hs-ni" aria-hidden="true">' . e($ic) . '</span><span class="hs-tx"><b>' . e($tt) . '</b>' . ($sm !== '' ? '<small>' . e($sm) . '</small>' : '') . '</span>';
            $h .= $href !== '' ? '<a class="hs-wide" href="' . e($href) . '">' . $in . '<span class="hs-go">' . e(home_slim_go($href)) . ' →</span></a>' : '<div class="hs-wide">' . $in . '</div>';
        }
    } else {
        $h .= '<p class="hs-empty">Nothing needs you right now. A good day to wander.</p>';
    }
    if ($needs['quiet']) $h .= '<p class="hs-quiet">' . e(implode(' ', $needs['quiet'])) . '</p>';
    $h .= '</section>';
    $night = home_slim_overnight($u);
    if ($night['n'] > 0) {   // 2.7.17: every pal job in one box (garden crew, stations, trips and delves)
        $grp = fn(string $ic, string $lab, string $href, string $go): string => '<div class="hs-grp"><span><span aria-hidden="true">' . $ic . '</span> ' . e($lab) . '</span><a href="' . e($href) . '">' . e($go) . ' →</a></div>';
        $row = function (array $r): string {
            $in = '<span class="hs-ni" aria-hidden="true">' . e($r[0]) . '</span><span class="hs-tx"><b>' . e($r[1]) . '</b><small>' . e($r[2]) . '</small>'
                . (isset($r[4]) ? '<span class="hs-bar" aria-hidden="true"><i style="width:' . (int)$r[4] . '%"></i></span>' : '') . '</span>';
            return '<li><a href="' . e($r[3]) . '">' . $in . '</a></li>';
        };
        $h .= '<section class="box hs-needs hs-night" aria-labelledby="hs-night-h"><h2 id="hs-night-h">Your pals' . home_slim_bang($night['n'], $night['n'] . ' pal' . ($night['n'] === 1 ? '' : 's')) . '</h2>';
        if ($c = $night['crew']) {
            $h .= $grp('🌱', 'Garden crew · last night', $c['href'], 'Crew') . '<p class="hs-sum"><b>' . e($c['sum']) . '</b>' . ($c['sub'] !== '' ? '<small>' . e($c['sub']) . '</small>' : '') . '</p><ul class="hs-chips">';
            foreach ($c['chips'] as [$ic, $nm, $pct, $done]) {
                $cls = $pct >= 70 ? 'g' : ($pct >= 50 ? 'y' : ($pct >= 5 ? 'r' : 'k'));   // green 70+, yellow 50-69, red 5-49, black under 5 (with a red !)
                $pill = $done ? '<em class="hs-pill d">done</em>' : '<em class="hs-pill ' . $cls . '" title="Working at ' . $pct . '%">' . ($cls === 'k' ? '<i aria-hidden="true">!</i>' : '') . $pct . '%</em>';
                $h .= '<li><a href="' . e($c['href']) . '"><span aria-hidden="true">' . e($ic) . '</span> <span class="hs-cn">' . e($nm) . '</span>' . $pill . '</a></li>';
            }
            $h .= '</ul>';
        }
        if ($night['stations']) $h .= $grp('🏠', 'At their stations', $night['stations'][0][3], home_slim_go($night['stations'][0][3])) . '<ul class="hs-nlist">' . implode('', array_map($row, $night['stations'])) . '</ul>';
        if ($night['out']) $h .= $grp('🌲', 'Out and about', url('paljobs.php'), 'Pals') . '<ul class="hs-nlist">' . implode('', array_map($row, $night['out'])) . '</ul>';
        $h .= '</section>';
    }
    if ($teaOn) {   // the plain link to the kettle (the same popover), with today's cup
        $cup = tea_today($u);
        $h .= '<p class="hs-newsl hs-teal"><a href="' . e(tea_url(true)) . '" data-hdlg="htea"><span aria-hidden="true">🫖</span> '
            . e($cup ? 'Today’s cup: ' . $cup['name'] . (($bt = tea_buff_text($cup['buff'])) !== '' ? ' · ' . $bt : '') : 'The kettle is warm: brew today’s cup of tea') . ' →</a></p>';
    }
    $h .= home_slim_news_html($uid) . '</div>';
    require_once __DIR__ . '/today_social.php';
    return $h . '<aside class="hs-rail" aria-label="The Hollow">' . today_social_html($u, 'line') . '</aside></div>';
}

/** The Cosiness meter: n of max as pips. */
function home_slim_cosy_html(array $chosen): string
{
    [$n, $max] = hovel_cosy($chosen);
    $p = '';
    for ($i = 0; $i < $max; $i++) $p .= '<i' . ($i < $n ? ' class="on"' : '') . '></i>';
    return '<section class="box hs-cosy" aria-label="Cosiness ' . $n . ' of ' . $max . '"><p class="hs-ctop"><b>Cosiness</b> <span>' . $n . '/' . $max . '</span></p>'
        . '<div class="hs-pips" aria-hidden="true">' . $p . '</div><small>Each item adds 0 to 2. Locked items lift it to ' . $max . '.</small></section>';
}

/** One slot's picker: a <dialog> (opened by script; with ?slot= in the address it is drawn open, in the page, for no-script and after a change). */
function home_slim_picker_html(int $uid, array $s, string $cur, bool $open, string $prev): string
{
    $own = hovel_decor_owned($uid)[$s['k']] ?? [];
    $sk = $s['k'];
    $tw = 84; $th = 52; $sc = min($tw / $s['w'], $th / $s['h'], 3);
    $iw = max(8, (int)round($s['w'] * $sc)); $ih = max(8, (int)round($s['h'] * $sc));
    $h = '<dialog class="hpick" id="hpick-' . e($sk) . '" aria-labelledby="hpick-h-' . e($sk) . '"' . ($open ? ' open' : '') . '>'
        . '<form method="post" action="' . e(url('gnome.php?tab=furnish')) . '">' . csrf_field() . '<input type="hidden" name="do" value="decor"><input type="hidden" name="slot" value="' . e($sk) . '">'
        . '<div class="hpick-h"><h3 id="hpick-h-' . e($sk) . '">' . e($s['name']) . '</h3><small>You own ' . count($own) . ' · tap one to put it in place</small></div><div class="hpick-tray">';
    foreach ($s['items'] as $ik => $it) {
        $src = hovel_art('scenes/hovel-' . $sk . '-' . $ik . '.png');
        $thumb = '<svg class="hpick-th" viewBox="0 0 ' . $s['w'] . ' ' . $s['h'] . '" width="' . $iw . '" height="' . $ih . '" aria-hidden="true" focusable="false">'
            . ($src !== '' ? '<image href="' . e($src) . '" x="0" y="0" width="' . $s['w'] . '" height="' . $s['h'] . '" image-rendering="pixelated"/>' : '<rect class="hd-ph" x="1" y="1" width="' . max(1, $s['w'] - 2) . '" height="' . max(1, $s['h'] - 2) . '"/>') . '</svg>';
        if (empty($own[$ik])) {
            $h .= '<div class="hpick-it lock" aria-disabled="true">' . $thumb . '<span class="nm">' . e($it['name']) . '</span><span class="wh">Locked: ' . e($it['where']) . '</span></div>';
            continue;
        }
        $on = $ik === $cur;
        $h .= '<button class="hpick-it" type="submit" name="item" value="' . e($ik) . '" aria-pressed="' . ($on ? 'true' : 'false') . '">' . $thumb . '<span class="nm">' . e($it['name']) . '</span>'
            . '<span class="cz">' . ($on ? '<span class="in">In place</span> · ' : '') . '+' . (int)$it['cosy'] . ' cosy</span></button>';
    }
    $h .= '</div><div class="hpick-act">';
    if ($prev !== '' && $prev !== $cur && !empty($own[$prev])) $h .= '<button class="btn ghost" type="submit" name="item" value="' . e($prev) . '">Undo</button>';
    $h .= '<a class="btn" href="' . e(hovel_slot_url('')) . '" data-hdlg-close>Done</a></div></form></dialog>';
    return $h;
}

/** The FURNISH tab: the slot tiles and their pickers; the live room and the Cosiness meter on the side. */
function home_slim_furnish_html(array $u, array $chosen): string
{
    $uid = (int)$u['id'];
    $cat = hovel_decor_catalog();
    $sel = (string)($_GET['slot'] ?? '');
    if (!isset($cat['slots'][$sel])) $sel = '';
    $prev = (string)($_GET['prev'] ?? '');
    $tiles = '<div class="hs-slots">';
    foreach ($cat['slots'] as $sk => $s) {
        $it = $s['items'][$chosen[$sk]] ?? reset($s['items']);
        $tiles .= '<a class="hs-slot' . ($sk === $sel ? ' on' : '') . '" href="' . e(hovel_slot_url($sk)) . '" data-hdlg="hpick-' . e($sk) . '"' . ($sk === $sel ? ' aria-current="true"' : '') . '>'
            . '<span class="sn">' . e($s['name']) . '</span><span class="cur">' . e($it['name']) . '</span><span class="ch">change</span></a>';
    }
    $tiles .= '<a class="hs-slot more" href="' . e(url('market.php')) . '"><span class="sn">More</span><span class="cur">Find decor</span><span class="ch">Market →</span></a></div>';
    $picks = '';
    foreach ($cat['slots'] as $sk => $s) $picks .= home_slim_picker_html($uid, $s, $chosen[$sk], $sk === $sel, $sk === $sel ? $prev : '');
    return '<div class="hs-cols hs-furnish"><div class="hs-main"><h2 class="hs-h">Furnish your hovel</h2>' . $tiles . $picks . '</div>'
        . '<aside class="hs-rail" aria-label="Your room"><section class="box hs-preview"><h3>Your room</h3><div class="hs-pic">' . hovel_room_svg($u, $chosen, 'full', ['taps' => true, 'sel' => $sel]) . '</div><small>Tap a thing in the room to change it.</small></section>'
        . home_slim_cosy_html($chosen) . '</aside></div>';
}
