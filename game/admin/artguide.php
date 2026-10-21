<?php
declare(strict_types=1);
// v2.0.23: Art & style guide. Admin downloads the PDF that tests/build_guide.py makes (assets/guides/Gnome-Venture-Style-Guide.pdf).
// The folder is closed to the web by its .htaccess; this page streams the one fixed file. No path ever comes from the request.
require dirname(__DIR__) . '/includes/bootstrap.php';
require_once dirname(__DIR__) . '/includes/admin_helpers.php';
$me = require_admin();

const GUIDE_FILE = 'Gnome-Venture-Style-Guide.pdf';
const GUIDE_META = 'Gnome-Venture-Style-Guide.json';
$pdf = APP_ROOT . '/assets/guides/' . GUIDE_FILE;
$have = is_file($pdf);

$mode = (string)($_GET['get'] ?? '');
if ($mode === 'dl' || $mode === 'view') {
    if (!$have) { http_response_code(404); exit('The guide has not been built yet.'); }
    while (ob_get_level() > 0) ob_end_clean();   // the icon swap buffer must not hold a file
    if ($mode === 'dl') admin_log('artguide_download', GUIDE_FILE, '');
    header('Content-Type: application/pdf');
    header('Content-Disposition: ' . ($mode === 'dl' ? 'attachment' : 'inline') . '; filename="' . GUIDE_FILE . '"');
    header('Content-Length: ' . (string)filesize($pdf));
    header('X-Content-Type-Options: nosniff');
    header('Cache-Control: private, no-store');
    readfile($pdf);
    exit;
}

$meta = [];
$mf = APP_ROOT . '/assets/guides/' . GUIDE_META;
if (is_file($mf)) { $j = json_decode((string)file_get_contents($mf), true); if (is_array($j)) $meta = $j; }
$when = $have ? gmdate('j M Y, H:i', (int)filemtime($pdf)) . ' UTC' : '';
$size = $have ? number_format(filesize($pdf) / 1048576, 1) . ' MB' : '';

page_header('Art & style guide', true);
?>
<?php admin_crumbs('artguide.php'); ?>
<div class="center">
<h1>🎨 Art &amp; style guide</h1>
<?php if ($have): ?>
  <div class="box">
    <p><b>Gnome-Venture-Style-Guide.pdf</b></p>
    <p class="muted">Made <?= e($when) ?> · <?= e($size) ?><?php if (!empty($meta['pages'])): ?> · <?= (int)$meta['pages'] ?> pages<?php endif; ?><?php if (!empty($meta['icons'])): ?> · <?= (int)$meta['icons'] ?> icons<?php endif; ?><?php if (!empty($meta['version'])): ?> · game v<?= e((string)$meta['version']) ?><?php endif; ?></p>
    <p><a class="btn act" href="<?= e(url('admin/artguide.php?get=dl')) ?>">Download PDF</a></p>
    <p><a href="<?= e(url('admin/artguide.php?get=view')) ?>" target="_blank" rel="noopener">Open in a new tab</a></p>
  </div>
<?php else: ?>
  <div class="box notice"><p>No guide yet.</p><p class="muted">Build it: <code>python3 tests/build_guide.py</code>, then upload <code>assets/guides/</code>.</p></div>
<?php endif; ?>
<details class="fold"><summary>What is inside</summary>
  <p>Hearthlight art rules: palette, halo, outline, shade, size caps</p>
  <p>Inline icons (ico): sizes, naming, how to add one</p>
  <p>Every icon, at 16, 24 and 48 px, dark and light</p>
  <p>UI style sheet: colours, type, spacing, components</p>
  <p>Joshua’s UI rules and the do / don’t list</p>
</details>
<details class="fold"><summary>Update it</summary>
  <p class="help">After icons change, run <code>python3 tests/build_guide.py</code> in the project. It rebuilds the PDF from the icon files. Ship <code>assets/guides/</code> with the next release.</p>
</details>
</div>
<?php page_footer();
