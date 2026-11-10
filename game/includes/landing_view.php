<?php
declare(strict_types=1);
/**
 * 2.6.41: the logged-out front page: the landing card and "How to play" (index.php requires this, then prints landing_html()).
 * Every picture is art the game itself uses: the 2.5D gnome and villager strips, the grassland stage, the village picture, garden tiles and crop stages,
 * item squares, the 30 x 18 Trail sections with their baked ground and raised sprites, the Maplewold jigsaw and its Puzzle Pals.
 * The moving parts are assets/landing.js (reads the JSON block #lh-data); styles are the lh- block of assets/landing.css. No inline styles (CSP).
 * Anything whose art or feature is missing is left out: a Trail section without its ground picture, the Puzzle card while Jigsaw is closed,
 * the Puzzle Pals card while Puzzle Pals are closed, the walking gnome when the strips cannot be composed.
 */
require_once __DIR__ . '/site_text.php';
require_once __DIR__ . '/tilemap.php';
require_once __DIR__ . '/trail_art.php';
require_once __DIR__ . '/gnome25.php';

/** The Trail sections shown under Explore: [route id, section (0-based), name, item name, item picture]. All three are Maplewold routes. */
const LANDING_TRAILS = [
    [232, 1, 'Log bridge meadow', 'Wild Strawberries', 'wild-strawberries'],
    [312, 1, 'Toadstool woods', 'Chanterelle', 'chanterelle'],
    [309, 0, 'Frozen pond', 'Crowberries', 'crowberries'],
];

/** Steps from $from to every reachable floor tile of an authored section's rows ('#' is wall), ["x,y" => steps]. */
function landing_dist(array $rows, array $from): array
{
    $h = count($rows); $w = strlen((string)$rows[0]);
    $d = [$from[0] . ',' . $from[1] => 0];
    $q = [$from];
    for ($i = 0; $i < count($q); $i++) {
        [$x, $y] = $q[$i];
        foreach ([[1, 0], [0, 1], [0, -1], [-1, 0]] as [$dx, $dy]) {
            $nx = $x + $dx; $ny = $y + $dy; $k = $nx . ',' . $ny;
            if ($nx < 0 || $ny < 0 || $nx >= $w || $ny >= $h || $rows[$ny][$nx] === '#' || isset($d[$k])) continue;
            $d[$k] = $d[$x . ',' . $y] + 1;
            $q[] = [$nx, $ny];
        }
    }
    return $d;
}

/** The shortest walk from $a to $b as tiles (both ends in), or [] when there is none. */
function landing_walk(array $rows, array $a, array $b): array
{
    $d = landing_dist($rows, $b);
    if (!isset($d[$a[0] . ',' . $a[1]])) return [];
    $out = [$a]; $c = $a;
    while ($c !== $b) {
        $here = $d[$c[0] . ',' . $c[1]]; $next = null;
        foreach ([[1, 0], [0, 1], [0, -1], [-1, 0]] as [$dx, $dy]) {
            if (($d[($c[0] + $dx) . ',' . ($c[1] + $dy)] ?? PHP_INT_MAX) === $here - 1) { $next = [$c[0] + $dx, $c[1] + $dy]; break; }
        }
        if (!$next) return [];
        $out[] = $c = $next;
    }
    return $out;
}

/** One Trail section for the page (map size, ground picture, raised sprites, finds, the walk from its entry to its way on), or null when it cannot be shown. */
function landing_trail(int $route, int $sec, string $name, string $item, string $slug): ?array
{
    $art = trail_authored_section($route, $sec);
    if (!$art || !trail_art_ready($art) || !empty($art['gates'])) return null;
    [$map, $tokens] = trail_map_authored($art);
    $en = $map['entry'] ?? null; $ex = $map['spots']['9'] ?? null;
    if (!$en || !$ex) return null;
    $rows = $map['t'];
    $finds = [];
    foreach ($tokens as $t) if ($t[2] === 'F') $finds[] = [(int)$t[0], (int)$t[1]];
    $toEnd = landing_dist($rows, $ex);
    $path = [$en]; $cur = $en; $left = $finds;
    while ($left) {   // take the finds that are not far off the way, nearest first
        $dc = landing_dist($rows, $cur); $best = null;
        foreach ($left as $i => $f) {
            $k = $f[0] . ',' . $f[1];
            if (!isset($dc[$k], $toEnd[$k])) continue;
            if ($dc[$k] + $toEnd[$k] - $toEnd[$cur[0] . ',' . $cur[1]] <= 18 && ($best === null || $dc[$k] < $dc[$left[$best][0] . ',' . $left[$best][1]])) $best = $i;
        }
        if ($best === null) break;
        $leg = landing_walk($rows, $cur, $left[$best]);
        if (!$leg) break;
        $path = array_merge($path, array_slice($leg, 1)); $cur = $left[$best];
        unset($left[$best]);
    }
    $leg = landing_walk($rows, $cur, $ex);
    if (!$leg) return null;
    $path = array_merge($path, array_slice($leg, 1));
    $fland = (string)($art['art'] ?? $art['land']);
    if (!is_file(APP_ROOT . '/assets/img/trail/find-' . $fland . '.png')) $fland = 'grassland';
    $objs = []; $sizes = [];
    foreach ($art['objs'] as $o) {
        $key = (string)$o[2];
        if (!preg_match('/^[a-z0-9-]+$/', $key) || !is_file(APP_ROOT . '/assets/img/trail/obj/' . $key . '.png')) continue;
        $objs[] = [(int)$o[0], (int)$o[1], $key, (int)$o[3], (int)($o[4] ?? 0)];
        $sizes[$key] ??= trail_art_obj_size($key);
    }
    return ['name' => $name, 'item' => $item, 'itemSrc' => url('assets/img/ph/' . $slug . '.png'), 'w' => (int)$map['w'], 'h' => (int)$map['h'],
        'ground' => trail_ground_url($route, $sec + 1, trail_art_sfx($art)), 'find' => trail_art_url('find-' . $fland . '.png'), 'findDone' => trail_art_url('find-' . $fland . '-done.png'),
        'objs' => $objs, 'sizes' => $sizes, 'finds' => $finds, 'path' => $path];
}

/** What assets/landing.js needs: picture URLs and the Trail sections. */
function landing_data(bool $jigsaw, bool $pals): array
{
    $img = fn(string $rel): string => is_file(APP_ROOT . '/assets/img/' . $rel) ? url('assets/img/' . $rel) : '';
    $gnome = function_exists('imagecreatetruecolor') && is_file(APP_ROOT . '/assets/img/gnome25/front-hat.png')
        ? ['side' => url('gnome_sprite.php?v=side'), 'front' => url('gnome_sprite.php?v=front'), 'back' => url('gnome_sprite.php?v=back')] : null;
    $trails = [];
    foreach (LANDING_TRAILS as [$r, $s, $name, $item, $slug]) {
        try { if ($t = landing_trail($r, $s, $name, $item, $slug)) $trails[] = $t; } catch (Throwable $e) { /* a bad section is left out */ }
    }
    $folk = [];
    foreach (['wren-thimblewick', 'old-twigg', 'lantern-lou'] as $slug) if (($u = $img('sprite/npc-' . $slug . '.png')) !== '') $folk[] = $u;
    $palUrls = [];
    if ($pals) foreach (['mw-acorn-nip', 'mw-leaf-tuck'] as $k) if (($u = $img('puzzles/pals/' . $k . '.png')) !== '') $palUrls[] = $u;
    return ['gnome' => $gnome, 'folk' => $folk, 'pals' => $palUrls, 'trails' => $trails, 'objBase' => url('assets/img/trail/obj/'), 'ver' => APP_VERSION,
        'jigsaw' => $jigsaw ? $img('jigsaw/maplewold.jpg') : '', 'radish' => $img('ph/radish.png')];
}

/** A "Title\ntext" page text as [title, text]. */
function landing_pair(string $key): array
{
    return array_pad(explode("\n", stext($key), 2), 2, '');
}

/** The landing card and the How to play section (html). */
function landing_html(): string
{
    $jigsaw = setting('puzzles_open') === '1' && setting('jigsaw_open') === '1' && is_file(APP_ROOT . '/assets/img/jigsaw/maplewold.jpg');
    $pals = $jigsaw && setting('ppal_open') === '1' && is_file(APP_ROOT . '/assets/img/puzzles/pals/mw-acorn-nip.png');
    $data = landing_data($jigsaw, $pals);
    $pic = fn(string $rel, string $cls = ''): string => '<img' . ($cls !== '' ? ' class="' . $cls . '"' : '') . ' src="' . e(url('assets/img/' . $rel)) . '" alt="" loading="lazy" decoding="async">';
    $guest = setting('guest_open') === '1';
    $edit = is_admin() ? ' <a class="small" href="' . e(url('admin/texts.php?page=' . urlencode('Front page'))) . '">✏️ Edit</a>' : '';

    // ---- the landing card
    $o = '<header class="lh-hero">'
        . '<div class="lh-scene"><svg id="lh-hero" class="lh-svg" viewBox="0 0 480 270" role="img" aria-label="A gnome strolls across a sunny meadow.">'
        . '<image href="' . e(url('assets/img/scenes/stage-grassland.png')) . '" x="0" y="0" width="480" height="270"/></svg></div>'
        . '<div class="lh-words"><h1>' . e(setting('site_name')) . $edit . '</h1>'
        . '<p class="lh-pitch">' . e(stext('home.headline')) . '</p>'
        . '<p class="lh-sub">' . e(stext('home.sub')) . '</p>'
        . '<div class="lh-cta"><a class="btn lh-go" href="' . e(url('register.php')) . '">' . e(stext('home.button')) . '</a>'
        . ($guest ? '<a class="btn ghost lh-alt" href="' . e(url('guest.php')) . '">' . e(stext('home.guestbtn')) . '</a>' : '') . '</div>'
        . '<p class="lh-login"><a href="' . e(url('login.php')) . '">Already a gnome? <b>Log in</b></a> <a href="#howto"><b>How to play</b></a></p>'
        . '<p class="lh-small">' . e(stext('home.small')) . '</p></div></header>';

    // ---- how to play
    $steps = [['ph/nav-garden', 'Grow'], ['ph/nav-crafting', 'Cook'], ['ph/nav-world', 'Explore'], ['ph/nav-villagers', 'Meet']];
    if ($jigsaw) $steps[] = ['puzzles/cast/tile-jigsaw', 'Puzzle'];
    $steps[] = ['ph/nav-almanac', 'Collect'];
    $o .= '<section class="lh-htp" aria-labelledby="howto"><h2 class="lp-h2" id="howto">How to play</h2><p class="lh-lede">' . e(stext('home.htp.lede')) . '</p><ol class="lh-loop" aria-label="The game loop">';
    foreach ($steps as [$ic, $word]) $o .= '<li>' . $pic($ic . '.png') . e($word) . '</li>';
    $o .= '<li class="lh-again">and again</li></ol><div class="lh-cards">';
    $card = function (string $key, string $icon, string $scene, string $cls = '') use ($pic): string {
        [$ttl, $txt] = landing_pair($key);
        return '<article class="lh-card' . ($cls !== '' ? ' ' . $cls : '') . '">' . $scene . '<h3>' . $pic($icon) . e($ttl) . '</h3><p>' . e($txt) . '</p></article>';
    };

    $o .= $card('home.htp.grow', 'ph/nav-garden.png', '<div class="lh-scene lh-fill"><div class="lh-yard" role="img" aria-label="A garden bed. Squares are tilled, planted, watered and harvested in turn.">'
        . '<div class="lh-bed" id="lh-bed">' . str_repeat('<div class="lh-tile"><i></i></div>', 8) . '</div>'
        . '<ul class="lh-verbs" id="lh-verbs" aria-hidden="true"><li>Till</li><li>Plant</li><li>Water</li><li>Harvest</li></ul></div></div>');

    $o .= $card('home.htp.cook', 'ph/nav-crafting.png', '<div class="lh-scene lh-fill"><div class="lh-cook"><div class="lh-recipe" role="img" aria-label="Three apples and two oats make an Apple Crumble.">'
        . '<span class="lh-ing">' . $pic('ph/apple.png') . '<b>×3</b></span><span class="lh-op">+</span><span class="lh-ing">' . $pic('ph/oats.png') . '<b>×2</b></span><span class="lh-op">›</span>'
        . '<span class="lh-ing lh-dish">' . $pic('ph/apple-crumble.png') . '</span></div>'
        . '<span class="lh-chip">' . $pic('ico/ico-lightning.png') . 'Apple Crumble: +9 energy</span></div></div>');

    if ($data['trails']) {
        $o .= $card('home.htp.explore', 'ph/nav-world.png', '<div class="lh-scene lh-trail" id="lh-trail" role="img" aria-label="Your gnome walks a winding trail, picking up wild finds on the way.">'
            . '<svg id="lh-tsvg" class="lh-svg" viewBox="0 0 448 448" preserveAspectRatio="xMinYMin slice"></svg>'
            . '<span class="lh-tchip" aria-hidden="true">' . $pic('ico/ico-boot.png') . '<span id="lh-tsteps">0 / 0</span></span></div>'
            . '<div class="lh-tabs" id="lh-ttabs" role="group" aria-label="Pick a trail"></div>', 'lh-wide');
    } else {
        $o .= $card('home.htp.explore', 'ph/nav-world.png', '<div class="lh-scene"><svg class="lh-svg" viewBox="0 0 480 120" role="img" aria-label="A road through the Maplewold.">'
            . '<image href="' . e(url('assets/img/scenes/banner-NA.png')) . '" x="0" y="0" width="480" height="120"/></svg></div>', 'lh-wide');
    }

    $o .= $card('home.htp.meet', 'ph/nav-villagers.png', '<div class="lh-scene lh-cover"><svg id="lh-meet" class="lh-svg" viewBox="0 0 480 270" preserveAspectRatio="xMidYMid slice" role="img" aria-label="Your gnome in a village with three of the folk who live there.">'
        . '<image href="' . e(url('assets/img/scenes/here-village.png')) . '" x="0" y="0" width="480" height="270"/></svg></div>');

    $shelf = '';
    foreach ([['', 'radish', 'Radish', 'Common'], ['u', 'apple', 'Apple', 'Uncommon'], ['r', 'morel', 'Morel', 'Rare'], ['l', 'saffron', 'Saffron', 'Legendary']] as [$r, $slug, $name, $word]) {
        $shelf .= '<li class="lh-itm' . ($r !== '' ? ' lh-itm--' . $r : '') . '"><span class="lh-itm__win">' . $pic('ph/' . $slug . '.png', 'lh-itm__ic') . '<i class="lh-itm__gem"></i></span><span class="lh-itm__rib">' . e($name) . '</span><span class="lh-itm__rar">' . e($word) . '</span></li>';
    }
    $o .= $card('home.htp.collect', 'ph/nav-almanac.png', '<div class="lh-scene lh-fill"><ul class="lh-shelf" aria-label="Four items, from common to legendary">' . $shelf . '</ul></div>');

    if ($jigsaw) {
        $o .= $card('home.htp.puzzle', 'puzzles/cast/jeff-piece.png', '<div class="lh-scene lh-jig"><canvas id="lh-jig" width="960" height="640" role="img" aria-label="A 24-piece jigsaw of the Maplewold putting itself together."></canvas>'
            . '<span class="lh-tchip" aria-hidden="true">' . $pic('puzzles/cast/tile-jigsaw.png') . '<span id="lh-jn">0 / 24</span></span></div>');
    }
    if ($pals) {
        $roster = '';
        foreach ([['mw-acorn-nip', 'Acorn Nip', ''], ['mw-leaf-tuck', 'Leaf Tuck', ''], ['mw-sap-drip', 'Sap Drip', ''], ['mw-bark-badger', 'Bark Badger', 'u'], ['mw-fourwind-finch', 'Fourwind Finch', 'u'], ['mw-samara-spin', 'Samara Spin', 'r']] as [$k, $name, $r]) {
            if (!is_file(APP_ROOT . '/assets/img/puzzles/pals/' . $k . '.png')) continue;
            $roster .= '<li' . ($r !== '' ? ' class="lh-' . $r . '"' : '') . '>' . $pic('puzzles/pals/' . $k . '.png') . '<b>' . e($name) . '</b><small>' . ['' => 'Common', 'u' => 'Uncommon', 'r' => 'Rare'][$r] . '</small></li>';
        }
        $o .= $card('home.htp.pals', 'puzzles/pals/mw-acorn-nip.png', '<div class="lh-scene lh-fill"><div class="lh-pals"><ul class="lh-roster" aria-label="The six Puzzle Pals of the Maplewold">' . $roster . '</ul>'
            . '<ul class="lh-verbs lh-jobs" aria-label="Jobs a pal does while you sleep"><li>Water</li><li>Weed</li><li>Pests</li><li>Harvest</li><li>Plant</li></ul></div></div>');
    }
    $o .= '</div></section>';
    $o .= '<script type="application/json" id="lh-data">' . json_encode($data, JSON_UNESCAPED_SLASHES | JSON_HEX_TAG | JSON_HEX_AMP | JSON_HEX_APOS | JSON_HEX_QUOT) . '</script>';
    return $o;
}
