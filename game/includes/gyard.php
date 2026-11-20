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

/** What the "!" means for each building (the gold strip on a ready card). */
const GYARD_READY = ['kitchen' => 'A meal is done and waiting.', 'beehive' => 'Honey is ready.', 'compost_bin' => 'Compost is ready.', 'rain_barrel' => 'Free Water all is ready.',
                     'tool_shed' => 'A free mend is ready.', 'greenhouse' => 'Crops are ripe inside.', 'root_cellar' => 'A stored plant is ready to replant.', 'tailor' => 'A finished garment is waiting.'];

/** The art tile of a card: the building cropped to its drawn pixels in a fixed square (classes from assets/gyard.css). $st = e, l1-l3, r1-r3 (ready, with its badge), fence: i or r1. */
function gyard_tile(string $key, string $st, bool $badge): string
{
    return '<span class="gyt"><span class="gyt-' . e($key) . '-' . e($st) . '"></span>' . ($badge ? '<i class="gyt-b">!</i>' : '') . '</span>';
}

/** The header every card shares: art tile, name, chips and the close X. */
function gyard_head(string $id, string $name, string $tile, string $chips): string
{
    return '<div class="gyhd">' . $tile . '<div class="gytt"><b id="' . $id . '-t">' . e($name) . '</b><div class="gychips">' . $chips . '</div></div>'
        . '<a class="gyx" href="' . e(url('garden.php?t=pic')) . '" data-pop-close aria-label="Close">✕</a></div>';
}

/** One building's card body: what it does now, one info strip, one row of buttons. Animal homes get a resident row. Everything else is under "More options" (the Buildings tab). */
function gyard_body(array $u, array $plot, array $built, string $key, int $ready): string
{
    [$name, , $needLv, $cost, $desc] = BUILDINGS[$key];
    $post = csrf_field() . '<input type="hidden" name="t" value="pic"><input type="hidden" name="building" value="' . e($key) . '">';
    $more = '<a class="btn alt gymore" href="' . e(url('garden.php?t=bld&bld=' . $key . '#b-' . $key)) . '" title="More options: details, skins and extras">More</a>';
    if (!isset($built[$key])) {
        $up2 = BUILDING_UPGRADES[$key][2] ?? '';
        $h = '<div class="gybd"><p class="gynow">' . e(BUILDING_SHORT[$key] ?? $desc) . '</p>';
        if ((int)$plot['garden_level'] >= $needLv) {
            $h .= '<p class="gystrip">' . ($up2 !== '' ? 'Next: ' . e($up2) : 'Costs ' . money($cost) . '.') . '</p>'
                . '<div class="gyacts"><form method="post" data-confirm="Build a ' . e($name) . ' for ' . number_format($cost) . '?"><input type="hidden" name="do" value="build">' . $post
                . '<button class="btn">Build · ' . money($cost) . '</button></form></div></div>';
        } else {
            $h .= '<p class="gystrip">🔒 Opens at garden level ' . (int)$needLv . '. Costs ' . money($cost) . e(garden_xp_hint($plot, $needLv)) . '</p><div class="gyacts"><span class="gypill">Locked</span></div></div>';
        }
        return $h;
    }
    $lvl = max(1, (int)$built[$key]['level']);
    $next = BUILDING_UPGRADES[$key][$lvl + 1] ?? null;
    $acts = '';
    if ($ready > 0) $acts .= '<form method="post"><input type="hidden" name="do" value="collect">' . $post . '<button class="btn">Collect ' . $ready . '</button></form>';
    $strip = '';
    if ($next !== null) {
        [$uc, $um, $ul] = upgrade_cost($key, $lvl + 1);
        $strip = 'Next: ' . e($next) . ($um ? ' Also needs ' . e(upgrade_mats_text($um)) . '.' : '');
        if ((int)$plot['garden_level'] >= $ul) {
            $acts .= '<form method="post" data-confirm="Upgrade your ' . e($name) . ' to level ' . ($lvl + 1) . '?"><input type="hidden" name="do" value="upgrade">' . $post
                . '<button class="btn alt">⬆️ Level ' . ($lvl + 1) . ' · ' . number_format($uc) . '</button></form>';
        } else {
            $acts .= '<form><button class="btn alt" disabled>🔒 Garden level ' . (int)$ul . '</button></form>';
        }
    } else {
        $strip = 'Fully upgraded. Nothing more to unlock here.';
    }
    if ($ready > 0) $strip = '<i>!</i>' . e(GYARD_READY[$key] ?? ($ready . ' waiting.'));
    if (critter_is_home($key)) {
        $pid = (int)$plot['id'];
        $list = critter_list($pid, $key);
        $homes = critter_homes($pid, $key);
        $main = critter_main_kind($key);
        $slots = '<ul class="gyslots">';
        for ($i = 0; $i < $homes; $i++) {
            if (isset($list[$i])) {
                $c = $list[$i];
                [$word, $face] = critter_mood_word((int)$c['mood']);
                $slots .= '<li class="gyslot">' . critter_img((string)$c['kind']) . '<b>' . eu($c['name']) . '</b><small>' . $face . ' ' . e($word) . '</small></li>';
            } else {
                $slots .= '<li class="gyslot free"><b>+</b><small>Open</small></li>';
            }
        }
        $slots .= '</ul>';
        $food = false; $scraps = 0; $foodSlugs = [];
        foreach ($list as $c) foreach (array_filter(array_map('trim', explode(',', (string)$c['k']['foods']))) as $fs) $foodSlugs[$fs] = true;
        if ($foodSlugs) {
            $food = true;
            $in = implode(',', array_fill(0, count($foodSlugs), '?'));
            $scraps = (int)q_val("SELECT COALESCE(SUM(ui.qty), 0) FROM user_items ui JOIN items i ON i.id = ui.item_id WHERE ui.user_id = ? AND i.slug IN ($in)", array_merge([(int)$u['id']], array_keys($foodSlugs)));
        }
        if ($food) $acts = '<form method="post"><input type="hidden" name="do" value="critter_feed">' . $post . '<button class="btn"' . ($scraps > 0 ? '' : ' disabled') . '>🍽️ Feed' . ($scraps > 0 ? ' (' . $scraps . ')' : '') . '</button></form>' . $acts;
        if ($key === 'frog_pond' && count($list) < $homes) {
            $spawn = (int)q_val("SELECT ui.qty FROM user_items ui JOIN items i ON i.id = ui.item_id WHERE ui.user_id = ? AND i.slug = 'frogspawn'", [(int)$u['id']]);
            if ($spawn > 0) $acts .= '<form method="post"><input type="hidden" name="do" value="critter_hatch">' . $post . '<button class="btn alt">🫧 Hatch (' . $spawn . ')</button></form>';
        }
        $hint = count($list) . ' of ' . $homes . ' homes. ' . ($main['quirk'] ?? '');
        $welcome = '';
        if ($main && count($list) < $homes && $key !== 'snail_jar') {
            $welcome = '<form method="post" class="gywelcome"><input type="hidden" name="do" value="critter_welcome">' . $post
                . '<input name="name" maxlength="20" placeholder="' . e(explode(',', (string)$main['names'])[0] ?? '') . '" aria-label="A name for the new ' . e(strtolower((string)$main['name'])) . '">'
                . '<button class="btn">' . e((string)$main['icon']) . ' Welcome · ' . money((int)$main['welcome_cost']) . '</button></form>';
        }
        if ($ready <= 0) $strip = e($hint);
        return '<div class="gybd home"><p class="gynow">' . e(BUILDING_NOW[$key][$lvl] ?? $desc) . '</p>' . $slots . '<p class="gystrip' . ($ready > 0 ? ' alert' : '') . '">' . $strip . '</p>'
            . $welcome . '<div class="gyacts">' . $acts . $more . '</div></div>';
    }
    return '<div class="gybd"><p class="gynow">' . e(BUILDING_NOW[$key][$lvl] ?? $desc) . '</p><p class="gystrip' . ($ready > 0 ? ' alert' : '') . '">' . $strip . '</p><div class="gyacts">' . $acts . $more . '</div></div>';
}

/**
 * The picture, its legend and its cards. $biddy / $nbr come from garden.php (the fence visitors). $open = building key whose card shows open without script.
 */
function gyard_html(array $u, array $plot, array $built, string $biddy, array $nbr, string $open = ''): string
{
    $pid = (int)$plot['id'];
    $sprites = $hits = $cards = $legend = '';
    $nReady = 0;
    foreach (GYARD_ORDER as $key) {
        $id = 'gypop-' . $key;
        if ($key === 'fence') {
            if ($biddy === '' && $nbr['html'] === '') continue;
            $ready = (str_contains($biddy, 'value="biddy"') || (string)($nbr['hint'] ?? '') !== '') ? 1 : 0;
            $name = 'The fence';
            $st = 'i'; $label = $name . ($ready ? ', someone is waiting' : '');
            $sprites .= $ready ? '<span class="gy-sp gy-a gy-fence gy-bg-fence-r1"></span>' : '<img class="gy-sp gy-fence" src="' . e(url('assets/img/gyard/fence-i.png')) . '" alt="">';
            $head = gyard_head($id, $name, gyard_tile('fence', $ready ? 'r1' : 'i', (bool)$ready), '<span class="gypill' . ($ready ? ' g' : '') . '">' . ($ready ? 'Someone is waiting' : 'Quiet today') . '</span>');
            $body = '<div class="gybd"><p class="gynow">Neighbours drop by the fence to trade scraps for eggs, milk and seeds.</p>' . gyard_stay($biddy . (string)$nbr['html']) . '</div>';
        } else {
            if (!gyard_listed($u, $plot, $built, $key)) continue;
            [$name, , $needLv] = BUILDINGS[$key];
            $isBuilt = isset($built[$key]);
            $lvl = $isBuilt ? min(3, max(1, (int)$built[$key]['level'])) : 0;
            $ready = !$isBuilt ? 0 : (isset(BUILDING_PRODUCE[$key]) ? building_ready($built[$key]) + heap_ready($built[$key]) : (critter_is_home($key) ? critter_ready($pid, $key) : 0));
            $locked = !$isBuilt && (int)$plot['garden_level'] < $needLv;
            if (!$isBuilt) { $st = 'e'; $sprites .= '<span class="gy-sp gy-a gy-' . $key . ' gy-bg-' . $key . '-e' . ($locked ? ' gy-locked' : '') . '"></span>'; $tileSt = 'e'; }
            elseif ($ready > 0) { $st = 'l' . $lvl; $tileSt = 'r' . $lvl; $sprites .= '<span class="gy-sp gy-a gy-' . $key . ' gy-bg-' . $key . '-r' . $lvl . '"></span>'; }
            else { $st = 'l' . $lvl; $tileSt = 'l' . $lvl; $sprites .= '<img class="gy-sp gy-' . $key . '" src="' . e(url('assets/img/gyard/' . $key . '-l' . $lvl . '.png')) . '" alt="">'; }
            $label = $name . ', ' . (!$isBuilt ? ($locked ? 'locked' : 'for sale') : 'level ' . $lvl) . ($ready > 0 ? ', ready' : '');
            $max = 1 + count(BUILDING_UPGRADES[$key] ?? []);
            if (!$isBuilt) {
                $chips = '<span class="gypill">' . ($locked ? 'Locked' : 'For sale') . '</span><span class="gypill">Garden lvl ' . (int)$needLv . '</span>';
            } else {
                $chips = '<span class="pips" role="img" aria-label="Level ' . $lvl . ' of ' . $max . '">';
                for ($i = 1; $i <= $max; $i++) $chips .= '<i class="' . ($i <= $lvl ? 'on' : '') . '">' . e(trim(BUILDING_LEVEL_MARK[$i] ?? '') ?: 'I') . '</i>';
                $chips .= '</span><span class="gypill">Level ' . $lvl . ($lvl >= $max ? ' · max' : '') . '</span>' . ($ready > 0 ? '<span class="gypill g">Ready</span>' : '');
            }
            $head = gyard_head($id, $name, gyard_tile($key, $tileSt, $ready > 0), $chips);
            $body = gyard_body($u, $plot, $built, $key, $ready);
            $body = preg_replace('/<p class="gystrip([^"]*)">(<i>.*?<\/i>)?(.*?)<\/p>/s', '<p class="gystrip$1">$2<span class="gyst">$3</span></p>', $body) ?? $body;   // long text stays inside the fixed card (clamped to two lines)
        }
        $hits .= '<a class="gy-hit gy-h-' . $key . '-' . $st . '" href="' . e(url('garden.php?t=pic&o=' . $key)) . '" data-pop="' . $id . '" aria-haspopup="dialog" aria-label="' . e($label) . '"></a>';
        $cards .= '<dialog class="picker hubpop gycard" id="' . $id . '" aria-labelledby="' . $id . '-t"' . ($open === $key ? ' open' : '') . '><div class="pickbox">' . $head . $body . '</div></dialog>';
        if ($ready > 0) {
            $nReady++;
            if ($nReady <= 6) $legend .= '<li><a class="hubchip" href="' . e(url('garden.php?t=pic&o=' . $key)) . '" data-pop="' . $id . '"><span class="hubchip-t">' . e($name) . '</span> <small class="hubchip-c">ready</small></a></li>';
        }
    }
    return '<link rel="stylesheet" href="' . e(url('assets/gyard.css?v=' . APP_VERSION)) . '">'
        . '<div class="box gtab gyard" id="gyard"><div class="gy-scene"><img class="gy-ground" src="' . e(url('assets/img/gyard/ground.png')) . '" alt="The garden yard">' . $sprites . $hits . '</div>'
        . '<p class="help gy-hint">Tap a building to open it. A gold ! means something is ready.</p>'
        . ($legend !== '' ? '<ul class="hubleg">' . $legend . '</ul>' : '')
        . '<p class="gy-tools"><a class="btn alt" href="' . e(url('garden.php?t=bld&list=1')) . '">List version</a></p>'
        . $cards . '</div>'
        . '<script src="' . e(url('assets/gardenyard.js?v=' . APP_VERSION)) . '" defer></script>';
}
