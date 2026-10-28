<?php
declare(strict_types=1);
/**
 * v2.0.75: "Play as a guest". GET shows Jeff and the button; POST (CSRF) makes a guest garden (includes/guest.php) and drops the visitor in it.
 * Off unless the setting guest_open is on. A signed-in player or guest just goes to their garden.
 */
require __DIR__ . '/includes/bootstrap.php';
require_once __DIR__ . '/includes/guest.php';
require_once __DIR__ . '/includes/puzzles.php';
if (current_user()) redirect('index.php');
$open = setting('guest_open') === '1';
$err = '';
if ($open && is_post()) {
    csrf_check();
    [$uid, $err] = guest_create();
    if ($uid) { flash('🌱 Welcome, guest! Look around. Jeff will show you where to make your own gnome.'); redirect('garden.php'); }
}
seo_set(['title' => 'Play as a guest · ' . (string)setting('site_name'), 'desc' => 'Look around the game without an account.', 'noindex' => true]);
page_header('Play as a guest');
?>
<div class="box narrow guestcard">
  <?= puzzle_cast('jeff-point', 'Jeff pointing', 'lp-jeffface') ?>
  <?php if (!$open): ?>
    <p class="say"><b>Jeff:</b> “Guest gardens aren’t open yet. You can still take the tour on the front page, or join for free.”</p>
    <p><a class="btn" href="<?= e(url('register.php')) ?>">Join for free</a> <a class="btn ghost" href="<?= e(url('index.php')) ?>">Back to the tour</a></p>
  <?php else: ?>
    <p class="say"><b>Jeff:</b> “Want to look around first? I’ll set you up with a guest garden. You can plant, cook, walk the roads and play the puzzles. Guest gardens are deleted after <?= (int)setting('guest_ttl_hours') ?> hours of nobody visiting, and they can’t trade, post or enter contests. Making your own gnome needs an account, and your guest garden comes with you.”</p>
    <?php if ($err !== ''): ?><div class="flash err"><?= e($err) ?></div><?php endif; ?>
    <form method="post"><?= csrf_field() ?><button class="btn lp-big">Start my guest garden</button></form>
    <p><a class="btn ghost" href="<?= e(url('register.php')) ?>">I’d rather join for free</a></p>
    <p class="help">No email, no password. We keep your connection’s address only until the guest garden is tidied away.</p>
  <?php endif; ?>
</div>
<?php page_footer();
