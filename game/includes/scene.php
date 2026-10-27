<?php
declare(strict_types=1);
/**
 * v2.0.38: scene art plumbing for the overhaul (stage, banners, miniatures).
 * Every picture is optional: a missing file falls back to a CSS gradient or the old sticker, so the game never breaks waiting for art.
 * Files: assets/img/scenes/{kind}-{key}.png (stage backdrops 480x270, banners 480x120), assets/img/mini/{slug}.png (toy miniatures).
 */

/** A safe key: letters, digits, hyphen, underscore (region codes are upper case). */
function scene_key(string $k): string
{
    return preg_match('/^[A-Za-z0-9][A-Za-z0-9_-]{0,60}$/', $k) ? $k : '';
}

/** Path of a scene picture ('stage', 'banner', 'trek', 'home', 'shop', 'stop', 'map') or ''. */
function scene_path(string $kind, string $key): string
{
    $kind = scene_key($kind);
    $key = scene_key($key);
    if ($kind === '' || $key === '') return '';
    $p = 'assets/img/scenes/' . $kind . '-' . $key . '.png';
    return is_file(APP_ROOT . '/' . $p) ? $p : '';
}

/** Path of a toy miniature for a slug, or ''. */
function mini_path(string $slug): string
{
    $slug = scene_key($slug);
    $p = 'assets/img/mini/' . $slug . '.png';
    return $slug !== '' && is_file(APP_ROOT . '/' . $p) ? $p : '';
}

/** A banner (480x120) as <img>, or a gradient strip when the art is missing. */
function scene_banner(string $key, string $alt = '', string $kind = 'banner'): string
{
    $p = scene_path($kind, $key);
    $cls = 'scene-banner';
    if ($p === '') return '<div class="' . $cls . ' scene-fb scene-fb-' . e(scene_key($key) ?: 'none') . '" role="img" aria-label="' . e($alt) . '"></div>';
    return '<img class="' . $cls . ' pix" src="' . e(url($p)) . '" width="480" height="120" alt="' . e($alt) . '" decoding="async">';
}

/**
 * The fight/visit stage: a 480x270 backdrop with sprites standing on it. assets/stage.js builds it from the JSON.
 * $units: [['id' => 'me', 'side' => 'p'|'f', 'name' => 'Gnome', 'mini' => 'slug', 'img' => 'fallback sticker path', 'html' => 'server-built markup instead of a picture', 'hp' => 10, 'max' => 12, 'ko' => false], ...]
 * $fallback: landscape key for the colour bands when the backdrop file is missing.
 * Backdrop key: kind 'stage' (a landscape, e.g. forest) or 'trek' (e.g. 2-camp); a missing file shows the fallback colours.
 */
function scene_stage(string $kind, string $key, array $units, string $id = 'stage', string $fallback = '', array $look = []): string
{
    $bg = scene_path($kind, $key);
    $out = [];
    foreach ($units as $u) {
        $mini = mini_path((string)($u['mini'] ?? ''));
        $img = $mini !== '' ? $mini : art_path((string)($u['img'] ?? ''));
        $out[] = ['id' => (string)($u['id'] ?? ''), 'side' => ($u['side'] ?? 'p') === 'f' ? 'f' : 'p', 'name' => (string)($u['name'] ?? ''),
            'src' => $img !== '' ? url($img) : '', 'html' => (string)($u['html'] ?? ''), 'mini' => $mini !== '', 'hp' => (int)($u['hp'] ?? 0), 'max' => (int)($u['max'] ?? 0), 'ko' => !empty($u['ko'])];
    }
    $data = json_encode(['bg' => $bg !== '' ? url($bg) : '', 'units' => $out], JSON_UNESCAPED_SLASHES | JSON_HEX_TAG | JSON_HEX_AMP | JSON_HEX_APOS | JSON_HEX_QUOT);
    // v2.0.67: $look = ['dp' => daypart, 'we' => weather, 'baked' => bool] for the time-of-day tint (stage.js adds .gvs-tint; CSS in claude/build/css-stage.css)
    $attrs = '';
    if (isset($look['dp']) && preg_match('/^(dawn|day|dusk|night)$/', (string)$look['dp'])) $attrs .= ' data-dp="' . e((string)$look['dp']) . '"';
    if (isset($look['we']) && scene_key((string)$look['we']) !== '') $attrs .= ' data-we="' . e(scene_key((string)$look['we'])) . '"';
    if (!empty($look['baked'])) $attrs .= ' data-baked="1"';
    return '<div class="gvs scene-fb scene-fb-' . e(scene_key($fallback !== '' ? $fallback : $key) ?: 'none') . '" data-crop="1" id="' . e(scene_key($id) ?: 'stage') . '"' . $attrs . ' data-stage="' . e((string)$data) . '"></div>';
}

/**
 * v2.0.67: baked time-of-day art per land (key = file part between 'stage-' and '.png'), used only for sun/cloud weather.
 * null = no baked picture for that daypart: the weather art is shown with the CSS tint instead. Day and night never have baked art.
 * What the variants are: v2 = grassland/mountain/desert/rainforest/tundra dawn, island sunrise, coast sunset (reads as dawn too),
 * forest autumn afternoon (warm: dusk only), wetland rain (a weather, never a daypart). v3 = wetland/desert/island sunset (dusk);
 * the other v3s are rain/snow/night-snow weather art and stay out of this table.
 */
const DAYPART_STAGE_ART = [
    'grassland'  => ['dawn' => 'grassland-v2',  'dusk' => null],
    'forest'     => ['dawn' => null,            'dusk' => 'forest-v2'],
    'coast'      => ['dawn' => 'coast-v2',      'dusk' => 'coast-v2'],
    'mountain'   => ['dawn' => 'mountain-v2',   'dusk' => null],
    'wetland'    => ['dawn' => null,            'dusk' => 'wetland-v3'],
    'desert'     => ['dawn' => 'desert-v2',     'dusk' => 'desert-v3'],
    'rainforest' => ['dawn' => 'rainforest-v2', 'dusk' => null],
    'tundra'     => ['dawn' => 'tundra-v2',     'dusk' => null],
    'island'     => ['dawn' => 'island-v2',     'dusk' => 'island-v3'],
];

/** A land's weather => stage key map from assets/img/scenes/stage-weather-<land>.json (decoded once per request; bad/missing file = []). */
function scene_stage_weather_map(string $land): array
{
    static $cache = [];
    $land = scene_key($land);
    if ($land === '') return [];
    if (array_key_exists($land, $cache)) return $cache[$land];
    $map = [];
    $f = APP_ROOT . '/assets/img/scenes/stage-weather-' . $land . '.json';
    $j = is_file($f) ? json_decode((string)@file_get_contents($f), true) : null;
    if (is_array($j)) {
        foreach ($j as $w => $k) {
            if (is_string($w) && is_string($k) && scene_key($k) !== '') $map[$w] = $k;
        }
    }
    return $cache[$land] = $map;
}

/** True when a baked dawn/dusk picture is the stage for this land, weather and daypart. */
function scene_stage_baked(string $land, string $weather, string $daypart): bool
{
    $k = DAYPART_STAGE_ART[$land][$daypart] ?? null;
    return $k !== null && in_array($weather, ['sun', 'cloud'], true) && scene_path('stage', $k) !== '';
}

/**
 * v2.0.67: which stage picture a land shows: the key for scene_path('stage', key), never throws, always a drawn file when one exists.
 * Order: baked dawn/dusk art (DAYPART_STAGE_ART, sun/cloud only) -> the land's weather art (stage-weather-<land>.json) -> stage-<land>.
 * $weather null = today's Hollow weather (weather_force respected); $daypart null = hollow_daypart(). Same inputs, same art (no randomness).
 */
function scene_stage_key(string $land, ?string $weather = null, ?string $daypart = null): string
{
    $land = scene_key($land);
    if ($land === '') return '';
    try {
        if ($weather === null) $weather = function_exists('hollow_weather') ? hollow_weather() : 'sun';
        if ($daypart === null) $daypart = function_exists('hollow_daypart') ? hollow_daypart() : 'day';
        if (scene_stage_baked($land, $weather, $daypart)) return (string)DAYPART_STAGE_ART[$land][$daypart];
        $k = scene_stage_weather_map($land)[$weather] ?? '';
        if ($k !== '' && scene_path('stage', $k) !== '') return $k;
    } catch (Throwable $e) {
        // a picture is never worth a broken page
    }
    return $land;
}

/** Today's weather where an adventure is (its region, else the player's), for the stage. 'sun' if nothing is known. */
function scene_stage_weather(array $u, array $scene): string
{
    if (!function_exists('hollow_weather')) return 'sun';
    try {
        $code = '';
        if (!empty($scene['region_id']) && function_exists('q_val')) $code = (string)q_val('SELECT code FROM regions WHERE id = ?', [(int)$scene['region_id']]);
        if ($code === '' && function_exists('hollow_user_region')) $code = (string)hollow_user_region($u);
        return hollow_weather($code !== '' ? $code : null);
    } catch (Throwable $e) {
        return 'sun';
    }
}

/** The player's own gnome as stage markup (the drawing without its size, so the stage can scale it). Falls back to an emoji. */
function gnome_stage_ico(array $u): string
{
    if (!function_exists('gnome_avatar') || !preg_match('~<svg[^>]*>(.*)</svg>\s*$~s', gnome_avatar($u, 24), $m)) return '🧙';
    return '<svg class="meico" viewBox="0 0 80 100" aria-hidden="true" focusable="false">' . $m[1] . '</svg>';
}

/** v2.0.43: the Adventure stage: your gnome on the land's scene, and the creature opposite in a fight. */
function adventure_stage_html(array $u, array $exp, array $scene, ?array $enc): string
{
    require_once __DIR__ . '/items.php';
    $land = (string)($scene['land'] ?? 'grassland');
    $fight = $enc && ($enc['type'] ?? '') === 'creature';
    $units = [['id' => 'me', 'side' => 'p', 'name' => gnome_name($u), 'html' => gnome_stage_ico($u),
        'hp' => $fight ? max(0, (int)$exp['hp']) : 0, 'max' => $fight ? (int)$exp['max_hp'] : 0, 'ko' => $fight && (int)$exp['hp'] <= 0]];
    if ($fight && ($c = encounter_creature($enc))) {
        $rel = creature_image((string)($c['slug'] ?? ''), true);
        $units[] = ['id' => 'foe', 'side' => 'f', 'name' => (string)$c['name'], 'mini' => 'mini-' . (string)($c['slug'] ?? ''), 'img' => $rel,
            'html' => $rel === '' ? '<span class="gvs-emo">' . emoji_swap(e((string)($c['icon'] ?? '🐾'))) . '</span>' : '',
            'hp' => max(0, (int)$enc['hp']), 'max' => (int)$enc['max']];
    }
    // someone or something in front of you who is not a fight: they stand opposite (a villager met on the road, a scene, a puzzle)
    $other = null;
    if ($enc && ($enc['type'] ?? '') === 'meet') $other = [(string)($enc['ic'] ?? '🧑'), (string)($enc['n'] ?? '')];
    elseif ($enc && ($enc['type'] ?? '') === 'choice') { $ch = road_event_get($enc); $other = [(string)($ch['icon'] ?? '❓'), '']; }
    elseif ($enc && ($enc['type'] ?? '') === 'problem') $other = ['❓', ''];
    if ($other) $units[] = ['id' => 'other', 'side' => 'f', 'name' => $other[1], 'html' => '<span class="gvs-emo">' . emoji_swap(e($other[0])) . '</span>'];
    // v2.0.67: the picture follows today's weather and the time of day (scene_stage_key); the fallback colours stay the plain land
    $we = scene_stage_weather($u, $scene);
    $dp = function_exists('hollow_daypart') ? hollow_daypart() : 'day';
    return scene_stage('stage', scene_stage_key($land, $we, $dp), $units, 'advstage', $land, ['dp' => $dp, 'we' => $we, 'baked' => scene_stage_baked($land, $we, $dp)]);
}

/**
 * v2.0.46: a banner for a place (location row or region name). Picks the most specific picture that is drawn: its kind (village, haven, wonder, delve, lair, market),
 * then its region code, then its landscape. Nothing drawn = '' (the page stays as it was; no placeholder strip).
 */
function scene_place_banner(array $loc, string $alt = ''): string
{
    $keys = [];
    if (!empty($loc['kind'])) $keys[] = (string)$loc['kind'];
    $code = '';
    try {
        if (!empty($loc['region_id'])) $code = (string)q_val('SELECT code FROM regions WHERE id = ?', [(int)$loc['region_id']]);
        elseif (!empty($loc['region'])) $code = (string)q_val('SELECT code FROM regions WHERE gnomish_name = ? OR real_name = ?', [(string)$loc['region'], (string)$loc['region']]);
    } catch (Throwable $e) {
        $code = '';   // a banner is never worth a broken page
    }
    if ($code !== '') $keys[] = $code;
    if (!empty($loc['landscape'])) $keys[] = (string)$loc['landscape'];
    foreach ($keys as $k) {
        if (scene_path('banner', $k) !== '') return '<div class="scene-bannerwrap">' . scene_banner($k, $alt) . '</div>';
    }
    return '';
}

/** Which shop interior a shop uses: its own type's picture, else the closest drawn one, else general. Returns the key or ''. */
function scene_shop_key(array $shop): string
{
    $type = (string)($shop['shop_type'] ?? '');
    $near = ['food' => 'bakery', 'decor' => 'craft', 'florist' => 'herbs'];   // v2.0.65: shop types have no file of their own name
    foreach ([$type, $near[$type] ?? '', 'general'] as $k) {
        if ($k !== '' && scene_path('shop', $k) !== '') return $k;
    }
    return '';
}

/** A shop's banner/interior strip (old 4:1 banner; shop.php now shows the interior in its place header). '' if none is drawn. */
function scene_shop_banner(array $shop): string
{
    $k = scene_shop_key($shop);
    return $k !== '' ? '<div class="scene-bannerwrap">' . scene_banner($k, (string)($shop['name'] ?? ''), 'shop') . '</div>' : '';
}

/** Which of the six home interiors a villager has (stable per villager). */
function npc_home_key(array $npc): string
{
    $homes = ['cottage', 'burrow', 'treehouse', 'hut', 'stone', 'boat'];
    return $homes[abs(crc32((string)($npc['slug'] ?? $npc['id'] ?? '0'))) % count($homes)];
}

/** The villager at home with you, on the home interior; '' unless that picture is drawn and they are at home. */
function npc_home_scene(array $u, array $npc, array $now): string
{
    $key = npc_home_key($npc);
    if (empty($now['home']) || scene_path('home', $key) === '') return '';
    require_once __DIR__ . '/items.php';
    $ph = ph_path('npc-' . (string)($npc['slug'] ?? ''));
    return scene_stage('home', $key, [
        ['id' => 'me', 'side' => 'p', 'name' => gnome_name($u), 'html' => gnome_stage_ico($u)],
        ['id' => 'npc', 'side' => 'f', 'name' => (string)$npc['name'], 'mini' => 'mini-npc-' . (string)($npc['slug'] ?? ''), 'img' => $ph],
    ], 'homestage', 'none');
}
