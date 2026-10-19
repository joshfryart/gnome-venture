<?php
declare(strict_types=1);
// v1.0.0 wave 1: the stamp passport (one stamp for every rest stop you visit, sets and titles)
require __DIR__ . '/includes/bootstrap.php';
require_once __DIR__ . '/includes/stop_pass.php';
$u = require_login();
$uid = (int)$u['id'];
if (is_post()) {   // the title picker lives in the Almanac; this page only reads
    redirect('passport.php');
}
foreach (stop_sets_check($uid) as $m) flash($m);   // a set can be complete after an admin changed the numbers
page_header('Stamp passport');
?>
<p class="crumbs">🌍 <a href="<?= e(url('world.php')) ?>">World</a> › <b>Passport</b></p>
<h1>🛂 Stamp passport</h1>
<p class="muted">Every rest stop gives you a stamp on your first visit. Fill the sets for rewards and titles. Hidden villages you find count too.</p>
<?php $titles = stop_titles($uid); if ($titles): ?><p>Titles earned: <?php foreach ($titles as $t) echo '<span class="tag">“' . e($t) . '”</span> '; ?> <a href="<?= e(url('book.php?ch=Milestones')) ?>">Choose yours in the Almanac →</a></p><?php endif; ?>
<?= stop_passport_html($u) ?>
<?php page_footer();
