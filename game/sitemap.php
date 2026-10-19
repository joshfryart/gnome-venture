<?php
declare(strict_types=1);
// v0.8.8: the list of public pages for search engines (linked from robots.txt). Submit it in Google Search Console.
define('ALLOW_DURING_MAINTENANCE', true);
require __DIR__ . '/includes/bootstrap.php';

$day = fn(?string $t) => $t ? gmdate('Y-m-d', strtotime($t . ' UTC')) : null;
$news = $day((string)q_val('SELECT MAX(created_at) FROM news WHERE published = 1'));
$urls = [['', $news, '1.0'], ['guide.php', $news, '0.8'], ['register.php', null, '0.6']];
foreach (q('SELECT slug, updated_at FROM pages WHERE published = 1 ORDER BY id')->fetchAll() as $p) {
    $urls[] = ['page.php?p=' . rawurlencode((string)$p['slug']), $day($p['updated_at']), '0.3'];
}
header('Content-Type: application/xml; charset=utf-8');
echo '<?xml version="1.0" encoding="UTF-8"?>' . "\n" . '<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">' . "\n";
foreach ($urls as [$path, $mod, $pri]) {
    echo '  <url><loc>' . e(seo_abs($path)) . '</loc>' . ($mod ? '<lastmod>' . $mod . '</lastmod>' : '') . '<priority>' . $pri . "</priority></url>\n";
}
echo "</urlset>\n";
