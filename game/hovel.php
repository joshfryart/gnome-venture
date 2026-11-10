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
    $kind = ''; foreach (gclock_rest_options($u) as $o0) if ($o0['key'] === $do) $kind = (string)$o0['kind'];   // read before acting (options change after a sleep)
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
    redirect('hovel.php' . ($ok && $kind !== 'nap' && $kind !== '' ? '?t=tasks' : ''));   // after sleeping the jobs have changed: open the Tasks tab
}
$s = gclock_state($u);
$T = (string)($_GET['t'] ?? 'sleep');
if (!in_array($T, ['sleep', 'tasks', 'costs'], true)) $T = 'sleep';
$clock = sprintf('%02d:%02d', intdiv($s['minute'], 60) % 24, $s['minute'] % 60);
$opts = gclock_rest_options($u);
$now = hollow_now(hollow_user_region($u), null, $s);
page_header('Hovel');
$maxE = max_energy($u);
$sleepOpts = array_values(array_filter($opts, fn($o) => $o['kind'] !== 'nap'));
$napOpts = array_values(array_filter($opts, fn($o) => $o['kind'] === 'nap'));
$optHtml = function (array $o) use ($u): string {
    return '<div class="hov-opt' . ($o['ok'] ? '' : ' off') . '"><button class="btn' . ($o['kind'] === 'nap' ? ' ghost' : '') . '" name="do" value="' . e($o['key']) . '" type="submit"' . ($o['ok'] ? '' : ' disabled') . '>' . e($o['label']) . '</button>'
        . '<small class="muted">' . e($o['cost']) . ($o['ok'] ? ' · ' . e(gclock_option_effect($u, $o)) : ' · ' . e($o['why'])) . '</small></div>';
};
require_once __DIR__ . '/includes/quests_view.php';
$cnt = tasks_counts($u, false);
$todo = (int)($cnt['jobs'] ?? 0) + (int)($cnt['journey'] ?? 0) + (int)($cnt['requests'] ?? 0);
$tabs = ['sleep' => ['🛏️', 'Sleep'], 'tasks' => ['📋', 'Tasks'], 'costs' => ['🕐', 'Costs']];
?>
<h1>🛏️ Hovel</h1>
<div class="hov-hero<?= $s['tired'] ? ' tired' : '' ?>">
  <div class="hov-time" aria-label="Game time"><?= e($clock) ?></div>
  <div class="hov-mid">
    <div class="hov-day">Day <b><?= (int)$s['day'] ?></b><?= $s['tired'] ? ' · 😴 tired' : '' ?></div>
    <div class="hov-sub"><?= e($now['season_emoji'] . ' ' . $now['season_label']) ?> <?= (int)$now['season_day'] ?> · <?= e($now['weather_emoji'] . ' ' . $now['weather_label']) ?></div>
  </div>
  <div class="hov-energy" title="Energy">⚡ <progress class="ebar" max="<?= $maxE ?>" value="<?= (int)$u['energy'] ?>" aria-label="Energy"></progress> <b><?= (int)$u['energy'] ?></b>/<?= $maxE ?></div>
</div>
<nav class="tabs hov-tabs" aria-label="Hovel">
  <?php foreach ($tabs as $k => [$ic, $lb]): ?>
    <a class="<?= $T === $k ? 'on' : '' ?>" href="<?= e(url('hovel.php' . ($k === 'sleep' ? '' : '?t=' . $k))) ?>"><span aria-hidden="true"><?= $ic ?></span> <?= $lb ?><?= $k === 'tasks' && $todo > 0 ? ' <small>' . $todo . '</small>' : '' ?></a>
  <?php endforeach; ?>
</nav>
<?php if ($T === 'sleep'): ?>
<section class="box hov">
  <?php if (($busy = gclock_busy_minutes($uid)) > 0): ?><p class="help hov-note">🔨 <?= round($busy / 60, 1) ?> h of work still to finish. Sleep, and it is done first thing in the morning.</p><?php endif; ?>
  <?php if ($s['tired']): ?><p class="help hov-note">After 22:00 everything costs +<?= game_surcharge_pct($u) ?>% energy. Sleep to start fresh at 06:00.</p><?php endif; ?>
  <form method="post" class="hov-form">
    <?= csrf_field() ?>
    <?php if (in_array('camp_sleep', array_column($opts, 'key'), true)): require_once __DIR__ . '/includes/crafting.php'; $meals = array_filter(craft_recipes($uid, 'cooking'), fn($r) => $r['known'] && $r['can']); ?>
    <p class="hov-camp"><label>🏕️ Camp meal, ready when you wake: <select name="camp_recipe"><option value="0">none</option><?php foreach ($meals as $m): ?><option value="<?= (int)$m['id'] ?>"><?= e($m['name']) ?></option><?php endforeach; ?></select></label></p>
    <?php endif; ?>
    <div class="hov-cols">
      <div class="hov-col"><h2>🌙 Sleep</h2><?php foreach ($sleepOpts as $o) echo $optHtml($o); ?></div>
      <?php if ($napOpts): ?><div class="hov-col"><h2>💤 Nap</h2><?php foreach ($napOpts as $o) echo $optHtml($o); ?></div><?php endif; ?>
    </div>
  </form>
  <p class="help hov-note">Sleep jumps to 06:00, fills your energy and starts the next day. Crops, jars, pots and pal jobs move on with your days.</p>
</section>
<?php elseif ($T === 'tasks'): ?>
<section class="box hov hov-tasks">
  <p class="help">Jobs change when you sleep. Pick today’s here, then open the full page to take or hand in.</p>
  <ul class="hov-tl">
  <?php foreach (JOB_PERIODS as $pk => [$pl, $pi]): $cj = current_job($uid, $pk);
      $st = !$cj ? 'none' : ($cj['status'] === 'done' ? 'done' : 'active');
      $multi = $cj && (int)$cj['stages'] > 1; ?>
    <li class="hov-t <?= $st ?>">
      <a href="<?= e(url('jobs.php?t=jobs&p=' . $pk)) ?>">
        <span class="hov-ti" aria-hidden="true"><?= $pi ?></span>
        <span class="hov-tb"><b><?= e($pl) ?></b>
          <?php if ($st === 'none'): ?><small class="muted">Nothing taken yet. Pick one →</small>
          <?php elseif ($st === 'done'): ?><small class="muted"><?= e($cj['title']) ?></small>
          <?php else: $d = $multi ? (int)$cj['stages_paid'] : (int)$cj['progress']; $m = max(1, $multi ? (int)$cj['stages'] : (int)$cj['qty']); ?>
            <small class="muted"><?= e($cj['title']) ?></small><progress max="<?= $m ?>" value="<?= min($d, $m) ?>" aria-label="<?= e($cj['title']) ?> progress"></progress><?php endif; ?></span>
        <span class="hov-tr"><?= $st === 'done' ? '✅' : ($st === 'active' ? ($multi ? (int)$cj['stages_paid'] . '/' . (int)$cj['stages'] : (int)$cj['progress'] . '/' . (int)$cj['qty']) : '➕') ?></span>
      </a>
    </li>
  <?php endforeach; ?>
    <li class="hov-t"><a href="<?= e(url('jobs.php?t=journey')) ?>"><span class="hov-ti" aria-hidden="true">📜</span><span class="hov-tb"><b>Journey</b><small class="muted"><?= (int)($cnt['journey'] ?? 0) ? (int)$cnt['journey'] . ' ready to hand in' : 'Your long quests' ?></small></span><span class="hov-tr">→</span></a></li>
    <li class="hov-t"><a href="<?= e(url('jobs.php?t=requests')) ?>"><span class="hov-ti" aria-hidden="true">📌</span><span class="hov-tb"><b>Requests</b><small class="muted"><?= (int)($cnt['requests'] ?? 0) ? (int)$cnt['requests'] . ' to hand in or carry' : 'Orders and errands from villagers' ?></small></span><span class="hov-tr">→</span></a></li>
  </ul>
  <p><a class="btn alt" href="<?= e(url('jobs.php')) ?>">Open the Tasks page →</a></p>
</section>
<?php else: ?>
<section class="box hov-costs" id="costs">
  <p class="help">Energy and game time are two budgets. Each button shows both, and a line after you act says what was spent. After 22:00 every energy cost goes up <?= game_surcharge_pct(['game_day' => 0, 'game_minute' => GAME_TIRED_MINUTE]) ?>% per hour.</p>
  <div class="tblwrap"><table class="tbl">
    <tr><th>Action</th><th>Energy</th><th>Game time</th></tr>
    <?php foreach (gclock_cost_guide($u) as [$what, $en, $tm]): ?>
    <tr><td><?= e($what) ?></td><td><?= e($en) ?></td><td><?= e($tm) ?></td></tr>
    <?php endforeach; ?>
  </table></div>
  <p class="help">Waiting timers only move when you act or sleep. A sleep from <?= e($clock) ?> skips to 06:00: <?= e(gclock_span_text(max(0, 1440 - $s['minute'] + GAME_WAKE_MINUTE))) ?> of game time.</p>
</section>
<?php endif; ?>
<?php page_footer();
