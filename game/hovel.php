<?php
declare(strict_types=1);
/**
 * Sleep-days: the hovel. Your own game clock, a nap and a night's sleep. Only open while the setting game_clock_on is 1.
 * Design: claude/plan-sleep-days.md (decisions 1-54). Inns, town beds and camping come later; this is sleeping at home.
 */
require __DIR__ . '/includes/bootstrap.php';
$u = require_login();
$uid = (int)$u['id'];
if (!gclock_on()) { flash('The hovel is still being built.', 'err'); redirect('gnome.php'); }
if (is_post()) {
    csrf_check();
    $do = (string)($_POST['do'] ?? '');
    [$ok, $msg] = gclock_rest($uid, (string)($_POST['do'] ?? ''));
    gclock_plot_day(0, true);
    flash($msg, $ok ? 'ok' : 'err');
    redirect('hovel.php');
}
$s = gclock_state($u);
$clock = sprintf('%02d:%02d', intdiv($s['minute'], 60) % 24, $s['minute'] % 60);
$opts = gclock_rest_options($u);
$now = hollow_now(hollow_user_region($u), null, $s);
page_header('Hovel');
?>
<section class="box">
  <h1>🛏️ Rest</h1>
  <p><b>Day <?= (int)$s['day'] + 1 ?></b> · <?= e($now['season_emoji'] . ' ' . $now['season_label']) ?> day <?= (int)$now['season_day'] ?> · <?= e($now['weather_emoji'] . ' ' . $now['weather_label']) ?> · <b><?= e($clock) ?></b><?= $s['tired'] ? ' 😴 tired' : '' ?></p>
  <p>Energy <b><?= (int)$u['energy'] ?></b> / <?= max_energy($u) ?></p>
  <?php if ($s['tired']): ?><p class="help">After 22:00 everything costs more energy (+<?= game_surcharge_pct($u) ?>% right now). Sleep to start fresh at 06:00.</p><?php endif; ?>
  <form method="post">
    <?= csrf_field() ?>
    <?php foreach ($opts as $o): ?>
    <p><button class="btn<?= $o['kind'] === 'nap' ? ' ghost' : '' ?>" name="do" value="<?= e($o['key']) ?>" type="submit"<?= $o['ok'] ? '' : ' disabled' ?>><?= e($o['label']) ?></button>
      <small class="muted"><?= e($o['cost']) ?><?= $o['ok'] ? '' : ' · ' . e($o['why']) ?></small></p>
    <?php endforeach; ?>
  </form>
  <p class="help">Sleep jumps to 06:00, fills your energy and starts the next day. Your garden, jars and pots move on with your days.</p>
</section>
<?php page_footer();
