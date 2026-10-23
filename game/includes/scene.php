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
function scene_stage(string $kind, string $key, array $units, string $id = 'stage', string $fallback = ''): string
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
    return '<div class="gvs scene-fb scene-fb-' . e(scene_key($fallback !== '' ? $fallback : $key) ?: 'none') . '" data-crop="1" id="' . e(scene_key($id) ?: 'stage') . '" data-stage="' . e((string)$data) . '"></div>';
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
    return scene_stage('stage', $land, $units, 'advstage', $land);
}
