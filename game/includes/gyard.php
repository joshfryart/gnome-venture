<?php
declare(strict_types=1);
/**
 * 2.7.33: the Garden Yard picture. One calm picture of the garden (assets/img/gyard/ground.png) with every garden building drawn on it as its own sprite:
 * an empty plot with a BUILD sign for what is not built yet, level 1, 2 and 3 art for what is, and a looping "!" animation when the building has something
 * to collect. A tap on a building opens its card (a <dialog>, like the picture pages); the card has the Build, Upgrade and Collect buttons and a link to the
 * full details on the Buildings tab, which stays as the list version. Flag gnav_garden (needs gnav_on; admins can always preview).
 * Art: aseprite-source/v3/states2 and scenes/garden-ground.png, turned into assets/img/gyard/*.png and assets/gyard.css by tools/build_gyard_assets.py.
 * No inline styles or scripts (CSP): every position and sprite is a class in assets/gyard.css; assets/gardenyard.js opens the cards.
 */

/** Far row first, so near buildings draw over far ones (same order as the feet rows in the art). */
const GYARD_ORDER = ['greenhouse', 'tailor', 'kitchen', 'tool_shed', 'compost_bin', 'beehive', 'root_cellar', 'worm_farm', 'ladybird_lodge', 'snail_jar', 'rain_barrel',
                     'fence', 'quail_coop', 'silk_shelf', 'tortoise_run', 'butterfly_bush', 'frog_pond'];

/** Is this building one the Buildings tab would list for this garden? (Same filter, so the picture never shows what the list hides.) */
function gyard_listed(array $u, array $plot, array $built, string $key): bool
{
    if (!isset(BUILDINGS[$key])) return false;
    if (isset($built[$key])) return true;
    if (critter_is_home($key) && (setting('animals_on') === '0' || animals120_blocked($key) || animals140_blocked($key))) return false;
    if ($key === 'tailor') { require_once __DIR__ . '/wearables.php'; if (!wear_live($u)) return false; }
    return true;
}

/** Inject a hidden field into every POST form of a snippet, so the action returns to the Yard tab. */
function gyard_stay(string $html): string
{
    return preg_replace('/(<form\b[^>]*method="post"[^>]*>)/i', '$1<input type="hidden" name="t" value="pic">', $html) ?? $html;
}

/** One building's card: what it does now, and its buttons. */
function gyard_card(array $u, array $plot, array $built, string $key, int $ready): string
{
    [$name, , $needLv, $cost, $desc] = BUILDINGS[$key];
    $csrf = csrf_field() . '<input type="hidden" name="t" value="pic"><input type="hidden" name="building" value="' . e($key) . '">';
    $more = '<p class="gy-more"><a class="btn alt small" href="' . e(url('garden.php?t=bld&bld=' . $key . '#b-' . $key)) . '">More options</a></p>';
    if (!isset($built[$key])) {
        $h = '<p>' . e(BUILDING_SHORT[$key] ?? $desc) . '</p>';
        if ((int)$plot['garden_level'] >= $needLv) {
            $h .= '<form method="post" data-confirm="Build a ' . e($name) . ' for ' . number_format($cost) . '?"><input type="hidden" name="do" value="build">' . $csrf
                . '<button class="btn">Build · ' . money($cost) . '</button></form>';
        } else {
            $h .= '<p class="muted">🔒 Opens at garden level ' . (int)$needLv . '. Costs ' . money($cost) . e(garden_xp_hint($plot, $needLv)) . '</p>';
        }
        return $h;
    }
    $lvl = max(1, (int)$built[$key]['level']);
    $max = 1 + count(BUILDING_UPGRADES[$key] ?? []);
    $h = '<p><span class="pips" role="img" aria-label="Level ' . $lvl . ' of ' . $max . '">';
    for ($i = 1; $i <= $max; $i++) $h .= '<i class="' . ($i <= $lvl ? 'on' : '') . '">' . e(trim(BUILDING_LEVEL_MARK[$i] ?? '') ?: 'I') . '</i>';
    $h .= '</span></p><p><b>Now:</b> ' . e(BUILDING_NOW[$key][$lvl] ?? $desc) . '</p>';
    if ($ready > 0) {
        $h .= '<form method="post"><input type="hidden" name="do" value="collect">' . $csrf . '<button class="btn">Collect ' . $ready . '</button></form>';
    }
    if (critter_is_home($key)) $h .= gyard_stay(critter_panel_html($u, $plot, $key));
    $next = BUILDING_UPGRADES[$key][$lvl + 1] ?? null;
    if ($next !== null) {
        [$uc, $um, $ul] = upgrade_cost($key, $lvl + 1);
        $h .= '<p class="btnext"><b>Level ' . ($lvl + 1) . ':</b> ' . e($next) . '<br><span class="muted">Costs ' . money($uc) . ($um ? ' + ' . e(upgrade_mats_text($um)) : '') . '.</span></p>';
        if ((int)$plot['garden_level'] >= $ul) {
            $h .= '<form method="post" data-confirm="Upgrade your ' . e($name) . ' to level ' . ($lvl + 1) . '?"><input type="hidden" name="do" value="upgrade">' . $csrf
                . '<button class="btn alt">⬆️ Level ' . ($lvl + 1) . ' · ' . number_format($uc) . '</button></form>';
        } else {
            $h .= '<p class="muted">🔒 Garden level ' . (int)$ul . '</p>';
        }
    }
    return $h . $more;
}

/**
 * The picture, its legend and its cards. $biddy / $nbr come from garden.php (the fence visitors). $open = building key whose card shows open without script.
 */
function gyard_html(array $u, array $plot, array $built, string $biddy, array $nbr, string $open = ''): string
{
    $pid = (int)$plot['id'];
    $sprites = $hits = $cards = $chips = '';
    $nReady = 0;
    foreach (GYARD_ORDER as $key) {
        if ($key === 'fence') {
            if ($biddy === '' && $nbr['html'] === '') { $fenceOn = false; } else { $fenceOn = true; }
            if (!$fenceOn) continue;
            $ready = str_contains($biddy, 'value="biddy"') || (string)($nbr['hint'] ?? '') !== '' ? 1 : 0;
            $name = 'The fence';
            $st = 'i'; $label = $name . ($ready ? ', someone is waiting' : '');
            $sprites .= $ready ? '<span class="gy-sp gy-a gy-fence gy-bg-fence-r1"></span>' : '<img class="gy-sp gy-fence" src="' . e(url('assets/img/gyard/fence-i.png')) . '" alt="">';
            $body = '<p class="muted">Neighbours drop by the fence to trade.</p>' . gyard_stay($biddy . (string)$nbr['html']);
        } else {
            if (!gyard_listed($u, $plot, $built, $key)) continue;
            [$name, , $needLv] = BUILDINGS[$key];
            $isBuilt = isset($built[$key]);
            $lvl = $isBuilt ? min(3, max(1, (int)$built[$key]['level'])) : 0;
            $ready = !$isBuilt ? 0 : (isset(BUILDING_PRODUCE[$key]) ? building_ready($built[$key]) + heap_ready($built[$key]) : (critter_is_home($key) ? critter_ready($pid, $key) : 0));
            $locked = !$isBuilt && (int)$plot['garden_level'] < $needLv;
            if (!$isBuilt) { $st = 'e'; $sprites .= '<span class="gy-sp gy-a gy-' . $key . ' gy-bg-' . $key . '-e' . ($locked ? ' gy-locked' : '') . '"></span>'; }
            elseif ($ready > 0) { $st = 'l' . $lvl; $sprites .= '<span class="gy-sp gy-a gy-' . $key . ' gy-bg-' . $key . '-r' . $lvl . '"></span>'; }
            else { $st = 'l' . $lvl; $sprites .= '<img class="gy-sp gy-' . $key . '" src="' . e(url('assets/img/gyard/' . $key . '-l' . $lvl . '.png')) . '" alt="">'; }
            $label = $name . ', ' . (!$isBuilt ? ($locked ? 'locked' : 'for sale') : 'level ' . $lvl) . ($ready > 0 ? ', ready' : '');
            $body = gyard_card($u, $plot, $built, $key, $ready);
        }
        $id = 'gypop-' . $key;
        $hits .= '<a class="gy-hit gy-h-' . $key . '-' . $st . '" href="' . e(url('garden.php?t=pic&o=' . $key)) . '" data-pop="' . $id . '" aria-haspopup="dialog" aria-label="' . e($label) . '"></a>';
        $cards .= '<dialog class="picker hubpop gycard" id="' . $id . '" aria-labelledby="' . $id . '-t"' . ($open === $key ? ' open' : '') . '><div class="pickbox">'
            . '<div class="pickhead"><h3 id="' . $id . '-t">' . e($name) . '</h3><a class="pickx" href="' . e(url('garden.php?t=pic')) . '" data-pop-close aria-label="Close">✕</a></div>'
            . '<div class="hubcard">' . $body . '</div></div></dialog>';
        if ($ready > 0) {
            $nReady++;
            if ($nReady <= 6) $chips .= '<li><a class="hubchip" href="' . e(url('garden.php?t=pic&o=' . $key)) . '" data-pop="' . $id . '"><span class="hubchip-t">' . e($name) . '</span> <small class="hubchip-c">ready</small></a></li>';
        }
    }
    return '<link rel="stylesheet" href="' . e(url('assets/gyard.css?v=' . APP_VERSION)) . '">'
        . '<div class="box gtab gyard" id="gyard"><div class="gy-scene"><img class="gy-ground" src="' . e(url('assets/img/gyard/ground.png')) . '" alt="The garden yard">' . $sprites . $hits . '</div>'
        . '<p class="help gy-hint">Tap a building to open it. A gold ! means something is ready.</p>'
        . ($chips !== '' ? '<ul class="hubleg">' . $chips . '</ul>' : '')
        . '<p class="gy-tools"><a class="btn alt" href="' . e(url('garden.php?t=bld')) . '">List version</a></p>'
        . $cards . '</div>'
        . '<script src="' . e(url('assets/gardenyard.js?v=' . APP_VERSION)) . '" defer></script>';
}
