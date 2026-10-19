<?php
declare(strict_types=1);

/*
 * v0.8.8: search engines and link previews.
 * Public pages (front page, How to play, Join, Rules, Privacy) are indexed with a description, a canonical address,
 * share-card tags (Facebook, Reddit, Discord, X…) and structured data. Every other page asks search engines not to
 * list it (they need a log-in anyway). Pages call seo_set([...]) before page_header() to fill in their own details.
 */

const SEO_INDEXED = ['index.php', 'guide.php', 'register.php', 'page.php'];

/** Pages can set: title (whole <title>), desc, index (bool), canonical (path for url()), jsonld (array of objects). */
function seo_set(array $o): void
{
    $GLOBALS['SEO'] = $o + ($GLOBALS['SEO'] ?? []);
}

/** The site's own address (https://gnomeventure.ca), from Game settings or the request. */
function seo_origin(): string
{
    $s = rtrim((string)setting('site_url'), '/');
    if ($s !== '' && preg_match('~^https?://[A-Za-z0-9.\-]+(:\d+)?$~', $s)) return $s;
    $host = (string)($_SERVER['HTTP_HOST'] ?? '');
    if (!preg_match('/^[A-Za-z0-9.\-]+(:\d+)?$/', $host)) return '';
    return (is_https() ? 'https://' : 'http://') . $host;
}

function seo_abs(string $path): string
{
    return seo_origin() . url($path);
}

/** Plain text from BBCode, cut to about $n characters on a word. */
function seo_plain(?string $s, int $n = 158): string
{
    $s = preg_replace('~\[/?[a-z*]+(=[^\]]*)?\]~i', ' ', (string)$s);
    $s = trim(preg_replace('/\s+/u', ' ', $s));
    if (mb_strlen($s) <= $n) return $s;
    $cut = mb_substr($s, 0, $n);
    $sp = mb_strrpos($cut, ' ');
    return rtrim(mb_substr($cut, 0, $sp ?: $n), ' ,.;:') . '…';
}

/** Everything that goes into <head> besides the stylesheet and script. */
function seo_head(string $title, bool $admin): string
{
    $o = $GLOBALS['SEO'] ?? [];
    $site = (string)setting('site_name');
    $page = basename((string)($_SERVER['SCRIPT_NAME'] ?? ''));
    $index = !$admin && http_response_code() < 400 && ($o['index'] ?? in_array($page, SEO_INDEXED, true));
    $desc = (string)($o['desc'] ?? setting('seo_description'));
    $full = (string)($o['title'] ?? ($title . ' · ' . $site));
    $h = [];
    $h[] = '<meta name="description" content="' . e($desc) . '">';
    $h[] = '<meta name="robots" content="' . ($index ? 'index, follow, max-image-preview:large' : 'noindex') . '">';
    $h[] = '<meta name="theme-color" content="#3f7d2c">';
    $h[] = '<link rel="icon" href="' . e(url('favicon.ico')) . '" sizes="any">';
    $h[] = '<link rel="icon" type="image/png" href="' . e(url('assets/img/icon-192.png')) . '">';
    $h[] = '<link rel="apple-touch-icon" href="' . e(url('assets/img/apple-touch-icon.png')) . '">';
    $h[] = '<link rel="manifest" href="' . e(url('manifest.json')) . '">';
    foreach (['google_site_verification' => 'google-site-verification', 'bing_site_verification' => 'msvalidate.01'] as $k => $name) {
        $v = trim((string)setting($k));
        if ($v !== '' && $page === 'index.php') $h[] = '<meta name="' . $name . '" content="' . e($v) . '">';
    }
    if ($index && seo_origin() !== '') {
        $canon = seo_abs((string)($o['canonical'] ?? $page));
        if (($o['canonical'] ?? $page) === 'index.php') $canon = seo_abs('');
        $img = seo_abs('assets/img/share-card.jpg');
        $h[] = '<link rel="canonical" href="' . e($canon) . '">';
        $h[] = '<meta property="og:type" content="website">';
        $h[] = '<meta property="og:site_name" content="' . e($site) . '">';
        $h[] = '<meta property="og:title" content="' . e($full) . '">';
        $h[] = '<meta property="og:description" content="' . e($desc) . '">';
        $h[] = '<meta property="og:url" content="' . e($canon) . '">';
        $h[] = '<meta property="og:image" content="' . e($img) . '">';
        $h[] = '<meta property="og:image:width" content="1200">';
        $h[] = '<meta property="og:image:height" content="630">';
        $h[] = '<meta property="og:image:alt" content="' . e($site . ': a cosy garden game you play in your browser') . '">';
        $h[] = '<meta property="og:locale" content="en_CA">';
        $h[] = '<meta name="twitter:card" content="summary_large_image">';
        foreach ((array)($o['jsonld'] ?? []) as $j) {
            // A data block, not a script: browsers never run it, so the strict Content-Security-Policy is unaffected.
            $h[] = '<script type="application/ld+json">' . json_encode($j, JSON_UNESCAPED_SLASHES | JSON_UNESCAPED_UNICODE | JSON_HEX_TAG | JSON_HEX_AMP) . '</script>';
        }
    }
    return '<title>' . e($full) . "</title>\n" . implode("\n", $h) . "\n";
}

/** Structured data for the front page: the website and the game itself. */
function seo_game_jsonld(): array
{
    $site = (string)setting('site_name');
    $home = seo_abs('');
    return [
        ['@context' => 'https://schema.org', '@type' => 'WebSite', 'name' => $site, 'url' => $home,
         'description' => (string)setting('seo_description'), 'inLanguage' => 'en'],
        ['@context' => 'https://schema.org', '@type' => 'VideoGame', 'name' => $site, 'url' => $home,
         'description' => (string)setting('seo_description'),
         'image' => seo_abs('assets/img/share-card.jpg'),
         'genre' => ['Simulation', 'Farming', 'Browser game', 'Casual'],
         'gamePlatform' => ['Web browser', 'Mobile web'], 'applicationCategory' => 'Game', 'operatingSystem' => 'Any',
         'playMode' => 'MultiPlayer', 'inLanguage' => 'en', 'isAccessibleForFree' => true,
         'offers' => ['@type' => 'Offer', 'price' => '0', 'priceCurrency' => 'CAD', 'availability' => 'https://schema.org/InStock'],
         'softwareVersion' => APP_VERSION],
    ];
}
