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
    if ($do === 'sleep') {
        $r = game_sleep($uid);
        gclock_plot_day(0, true);
        flash($r ? 'You sleep soundly. A new day: energy full.' : 'Something stirred. Try again.', $r ? 'ok' : 'err');
    } elseif ($do === 'nap') {
        $r = game_nap($uid);
        flash($r ? 'You nap for a while and feel a little better.' : 'Something stirred. Try again.', $r ? 'ok' : 'err');
    }
    redirect('hovel.php');
}
$s = gclock_state($u);
$clock = sprintf('%02d:%02d', intdiv($s['minute'], 60) % 24, $s['minute'] % 60);
$nap = setting('nap_minutes') === '' ? 120 : (int)setting('nap_minutes');
$napPct = setting('nap_energy_pct') === '' ? 40 : (int)setting('nap_energy_pct');
$now = hollow_now(hollow_user_region($u), null, $s);
page_header('Hovel');
?>
<section class="box">
  <h1>🛏️ Your hovel</h1>
  <p><b>Day <?= (int)$s['day'] + 1 ?></b> · <?= e($now['season_emoji'] . ' ' . $now['season_label']) ?> day <?= (int)$now['season_day'] ?> · <?= e($now['weather_emoji'] . ' ' . $now['weather_label']) ?> · <b><?= e($clock) ?></b><?= $s['tired'] ? ' 😴 tired' : '' ?></p>
  <p>Energy <b><?= (int)$u['energy'] ?></b> / <?= max_energy($u) ?></p>
  <?php if ($s['tired']): ?><p class="help">After 22:00 everything costs more energy (+<?= game_surcharge_pct($u) ?>% right now). Sleep to start fresh at 06:00.</p><?php endif; ?>
  <form method="post" class="pzrow">
    <?= csrf_field() ?>
    <button class="btn" name="do" value="sleep" type="submit">Sleep until morning</button>
    <button class="btn ghost" name="do" value="nap" type="submit">Nap (<?= $nap / 60 ?> h, +<?= $napPct ?>% energy)</button>
  </form>
  <p class="help">Sleep jumps to 06:00, fills your energy and starts the next day. Your garden, jars and pots move on with your days.</p>
</section>
<?php page_footer();
