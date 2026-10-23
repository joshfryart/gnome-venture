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

/** Relative path of assets/img/{rel}.png (or .svg when no PNG), or '' when neither exists. $rel has no extension. */
function art_url(string $rel): string
{
    if ($rel === '' || str_contains($rel, '..') || !preg_match('#^[A-Za-z0-9_][A-Za-z0-9_/-]*$#', $rel)) return '';
    foreach (['png', 'svg'] as $ext) {
        if (is_file(APP_ROOT . '/assets/img/' . $rel . '.' . $ext)) return 'assets/img/' . $rel . '.' . $ext;
    }
    return '';
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
 * $units: [['id' => 'me', 'side' => 'p'|'f', 'name' => 'Gnome', 'mini' => 'slug', 'img' => 'fallback sticker path', 'hp' => 10, 'max' => 12], ...]
 * Backdrop key: kind 'stage' (a landscape, e.g. forest) or 'trek' (e.g. 2-camp); a missing file shows the fallback colours.
 */
function scene_stage(string $kind, string $key, array $units, string $id = 'stage'): string
{
    $bg = scene_path($kind, $key);
    $out = [];
    foreach ($units as $u) {
        $mini = mini_path((string)($u['mini'] ?? ''));
        $img = $mini !== '' ? $mini : art_path((string)($u['img'] ?? ''));
        $out[] = ['id' => (string)($u['id'] ?? ''), 'side' => ($u['side'] ?? 'p') === 'f' ? 'f' : 'p', 'name' => (string)($u['name'] ?? ''),
            'src' => $img !== '' ? url($img) : '', 'mini' => $mini !== '', 'hp' => (int)($u['hp'] ?? 0), 'max' => (int)($u['max'] ?? 0), 'ko' => !empty($u['ko'])];
    }
    $data = json_encode(['bg' => $bg !== '' ? url($bg) : '', 'units' => $out], JSON_UNESCAPED_SLASHES | JSON_HEX_TAG | JSON_HEX_AMP | JSON_HEX_APOS | JSON_HEX_QUOT);
    return '<div class="gvs scene-fb scene-fb-' . e(scene_key($key) ?: 'none') . '" id="' . e(scene_key($id) ?: 'stage') . '" data-stage="' . e((string)$data) . '"></div>';
}
