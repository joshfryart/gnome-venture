<?php
declare(strict_types=1);
/**
 * v2.0.23: our own SVG icons instead of emoji, swapped at RENDER time (one output-buffer pass over each HTML response).
 * Map: includes/data/ico_map.php (emoji => [slug, decorative, name]). Files: assets/img/ico/{slug}.svg. A missing file leaves the emoji.
 * Only text nodes are touched: never tag attributes, <script> <style> <textarea> <option> <title> <select> <svg> <noscript>.
 * Player-typed text is printed with eu() (functions.php), which writes emoji as numeric references so this pass skips them.
 * No data-e attribute: the emoji cannot be copied from an <img> with or without it, and it would add ~15 bytes per icon.
 */

const ICO_SKIP_TAGS = ['script', 'style', 'textarea', 'option', 'title', 'select', 'svg', 'noscript'];
const ICO_MAX_BYTES = 3000000;

function ico_settings(): array
{
    return [
        'ico_swap' => ['label' => 'Icons: show our drawn icons instead of emoji (off = plain emoji everywhere)', 'type' => 'bool', 'default' => '1'],
    ];
}

function ico_dir(): string
{
    return defined('ICO_DIR') ? (string)ICO_DIR : APP_ROOT . '/assets/img/ico';
}

/** slug => true for every icon file that exists (the folder is read once per request). */
function ico_have(): array
{
    static $have = null;
    if ($have !== null) return $have;
    $have = [];
    foreach (@scandir(ico_dir()) ?: [] as $f) {
        if (preg_match('/^([a-z0-9][a-z0-9-]*)\.svg$/', $f, $m)) $have[$m[1]] = true;
    }
    return $have;
}

/** The map rows whose file exists, keyed by the emoji without U+FE0F. */
function ico_rows(): array
{
    static $rows = null;
    if ($rows !== null) return $rows;
    $rows = [];
    $map = defined('ICO_MAP_FILE') ? (array)require ICO_MAP_FILE : (array)require __DIR__ . '/data/ico_map.php';
    $have = ico_have();
    foreach ($map as $emoji => $r) {
        $slug = (string)($r[0] ?? '');
        $k = str_replace("\u{FE0F}", '', (string)$emoji);
        if ($k === '' || !isset($have[$slug])) continue;
        $rows[$k] = ['slug' => $slug, 'dec' => !empty($r[1]), 'name' => (string)($r[2] ?? str_replace('-', ' ', $slug))];
    }
    return $rows;
}

/** One regex over all usable emoji, longest first. Not inside a longer ZWJ sequence or before a skin tone. Null when nothing is usable. */
function ico_regex(): ?string
{
    static $re = false;
    if ($re !== false) return $re;
    $keys = array_keys(ico_rows());
    if (!$keys) return $re = null;
    usort($keys, fn($a, $b) => strlen($b) <=> strlen($a));
    $alt = implode('|', array_map(fn($k) => preg_quote((string)$k, '/'), $keys));
    return $re = '/(?<!\x{200D})(' . $alt . ')\x{FE0F}?(?![\x{200D}\x{FE0F}\x{20E3}\x{1F3FB}-\x{1F3FF}])/u';
}

function ico_img(array $row): string
{
    return '<img class="ico pix" src="' . e(art_url('assets/img/ico/' . $row['slug'])) . '" alt="' . ($row['dec'] ? '' : e($row['name'])) . '" width="16" height="16" loading="lazy" decoding="async">';
}

/** Swap emoji in the text nodes of an HTML string. */
function emoji_swap(string $html): string
{
    $re = ico_regex();
    if ($re === null || $html === '' || !preg_match($re, $html)) return $html;
    $rows = ico_rows();
    $parts = preg_split('/(<!--.*?-->|<![^>]*>|<\/?[a-zA-Z][a-zA-Z0-9:-]*(?:"[^"]*"|\'[^\']*\'|[^>"\'])*>)/s', $html, -1, PREG_SPLIT_DELIM_CAPTURE);
    if ($parts === false) return $html;
    $skip = 0;
    $out = '';
    foreach ($parts as $i => $p) {
        if ($i % 2 === 1) {   // a tag or comment: copy it as it is, track the skip tags
            if (preg_match('/^<(\/?)([a-zA-Z][a-zA-Z0-9:-]*)/', $p, $m) && in_array(strtolower($m[2]), ICO_SKIP_TAGS, true) && !str_ends_with($p, '/>')) {
                $skip = $m[1] === '/' ? max(0, $skip - 1) : $skip + 1;
            }
            $out .= $p;
        } elseif ($skip > 0 || $p === '') {
            $out .= $p;
        } else {
            $out .= preg_replace_callback($re, fn($m) => isset($rows[$m[1]]) ? ico_img($rows[$m[1]]) : $m[0], $p) ?? $p;
        }
    }
    return $out;
}

/** The output-buffer callback: only HTML pages (and the in-place fragments, which are full HTML pages). */
function emoji_swap_buffer(string $buf, int $phase = 0): string
{
    if ($buf === '' || strlen($buf) > ICO_MAX_BYTES) return $buf;
    $code = http_response_code();
    if (is_int($code) && ($code === 204 || $code === 304 || ($code >= 300 && $code < 400))) return $buf;
    foreach (headers_list() as $h) {
        if (stripos($h, 'content-type:') === 0 && stripos($h, 'text/html') === false) return $buf;
        if (stripos($h, 'location:') === 0 || stripos($h, 'content-disposition:') === 0) return $buf;
    }
    $t = ltrim($buf);
    if ($t === '' || $t[0] === '{' || $t[0] === '[' || !str_contains($buf, '<')) return $buf;
    try {
        return emoji_swap($buf);
    } catch (Throwable $e) {
        return $buf;
    }
}

/** Called once from bootstrap, before any output. Not for the command line. */
function ico_start(): void
{
    if (PHP_SAPI === 'cli' || setting('ico_swap') !== '1') return;
    ob_start('emoji_swap_buffer');
}
