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
    $before = q_one('SELECT energy, game_day, game_minute FROM users WHERE id = ?', [$uid]);
    $hpBefore = function_exists('hp_display') ? hp_display($u)[0] : 0;
    [$ok, $msg] = gclock_rest($uid, (string)($_POST['do'] ?? ''), (int)($_POST['camp_recipe'] ?? 0));
    gclock_plot_day(0, true);
    if ($ok && $before) {   // say exactly what it did to the clock, energy and health
        $a = q_one('SELECT * FROM users WHERE id = ?', [$uid]);
        require_once __DIR__ . '/includes/health.php';
        $hpAfter = hp_display($a)[0];
        $msg .= ' ' . gclock_rest_summary($before, $a, $hpAfter - $hpBefore);
    }
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
  <?php if (($busy = gclock_busy_minutes($uid)) > 0): ?><p class="help">🔨 You still have <?= round($busy / 60, 1) ?> h of work to finish. Sleep, and it is done first thing in the morning. Nothing else timed until then.</p><?php endif; ?>
  <?php if ($s['tired']): ?><p class="help">After 22:00 everything costs more energy (+<?= game_surcharge_pct($u) ?>% right now). Sleep to start fresh at 06:00.</p><?php endif; ?>
  <form method="post">
    <?= csrf_field() ?>
    <?php if (in_array('camp_sleep', array_column($opts, 'key'), true)): require_once __DIR__ . '/includes/crafting.php'; $meals = array_filter(craft_recipes($uid, 'cooking'), fn($r) => $r['known'] && $r['can']); ?>
    <p><label>Camp meal (one pot, ready when you wake): <select name="camp_recipe"><option value="0">none</option><?php foreach ($meals as $m): ?><option value="<?= (int)$m['id'] ?>"><?= e($m['name']) ?></option><?php endforeach; ?></select></label></p>
    <?php endif; ?>
    <?php foreach ($opts as $o): ?>
    <p><button class="btn<?= $o['kind'] === 'nap' ? ' ghost' : '' ?>" name="do" value="<?= e($o['key']) ?>" type="submit"<?= $o['ok'] ? '' : ' disabled' ?>><?= e($o['label']) ?></button>
      <small class="muted"><?= e($o['cost']) ?><?= $o['ok'] ? ' · ' . e(gclock_option_effect($u, $o)) : ' · ' . e($o['why']) ?></small></p>
    <?php endforeach; ?>
  </form>
  <p class="help">Sleep jumps to 06:00, fills your energy and starts the next day. Your garden, jars and pots move on with your days.</p>
</section>
<section class="box" id="costs">
  <h2>🕐 What costs what</h2>
  <p class="help">Energy is one budget and game time is another. Each action tells you both before you click, and after you act a line shows exactly what was spent. After 22:00 every energy cost goes up <?= game_surcharge_pct(['game_day' => 0, 'game_minute' => GAME_TIRED_MINUTE]) ?>% for each hour (you are never locked out). Energy only comes back from sleeping, napping, eating and potions.</p>
  <div class="tblwrap"><table class="tbl">
    <tr><th>Action</th><th>Energy</th><th>Game time</th></tr>
    <?php foreach (gclock_cost_guide($u) as [$what, $en, $tm]): ?>
    <tr><td><?= e($what) ?></td><td><?= e($en) ?></td><td><?= e($tm) ?></td></tr>
    <?php endforeach; ?>
  </table></div>
  <p class="help">Waiting timers (crops, jars, pots, pal jobs, mulch, compost) only move when you act or sleep. A sleep from <?= e($clock) ?> skips to 06:00, which is <?= e(gclock_span_text(max(0, 1440 - $s['minute'] + GAME_WAKE_MINUTE))) ?> of game time.</p>
</section>
<?php page_footer();
