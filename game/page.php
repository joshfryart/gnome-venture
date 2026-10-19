<?php
declare(strict_types=1);
require __DIR__ . '/includes/bootstrap.php';

$slug = (string)($_GET['p'] ?? '');
$page = q_one('SELECT * FROM pages WHERE slug = ? AND published = 1', [$slug]);
if (!$page && is_admin()) {
    $page = q_one('SELECT * FROM pages WHERE slug = ?', [$slug]);   // admins can preview drafts
}
if (!$page) {
    http_response_code(404);
    page_header('Not found');
    echo '<div class="box"><h2>Page not found</h2><p>This path leads only to weeds.</p></div>';
    page_footer();
    exit;
}
seo_set(['desc' => seo_plain($page['body']) ?: null, 'canonical' => 'page.php?p=' . rawurlencode((string)$page['slug']), 'index' => (bool)(int)$page['published']]);   // v0.8.8
page_header($page['title']);
?>
<article class="box">
  <h1><?= e($page['title']) ?><?= (int)$page['published'] ? '' : ' <small class="muted">(draft)</small>' ?></h1>
  <div><?= format_text($page['body']) ?></div>
</article>
<?php page_footer();
