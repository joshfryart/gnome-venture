<?php
declare(strict_types=1);
/**
 * Sleep-days: the hovel. Your own game clock, a nap and a night's sleep. Only open while the setting game_clock_on is 1.
 * Design: claude/plan-sleep-days.md (decisions 1-54). Inns, town beds and camping come later; this is sleeping at home.
 */
require __DIR__ . '/includes/bootstrap.php';
$u = require_login();
$uid = (int)$u['id'];
if (!gclock_on()) { flash('The hovel is still being built. (Admin > Settings > Sleep-days: ON reads as "' . setting('game_clock_on') . '"; it needs 1.)', 'err'); redirect('gnome.php'); }
require_once __DIR__ . '/includes/home_slim.php';
$slimHome = (int)($u['onboarded'] ?? 1) === 1 && home_slim_on();   // slim home: the hovel is the banner and tabs of gnome.php; this page only does the sleeping
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
    if ($slimHome) { $back = (string)($_POST['back'] ?? 'today'); redirect('gnome.php?tab=' . (in_array($back, ['furnish', 'gnome'], true) && !($ok && $kind === 'sleep') ? $back : 'today')); }   // after a sleep: TODAY, what changed overnight
    redirect('hovel.php' . ($ok && $kind !== 'nap' && $kind !== '' ? '?t=today' : ''));   // after sleeping: what changed overnight
}
if ($slimHome) redirect('gnome.php?tab=' . (($_GET['t'] ?? '') === 'furnish' ? 'furnish' : 'today'));   // old links (menu, daily, the clock pill) land on the home page
$s = gclock_state($u);
require_once __DIR__ . '/includes/pal_crew.php';
require_once __DIR__ . '/includes/today.php';
$lastRep = pcrew_latest_report($uid);
$T = (string)($_GET['t'] ?? ($lastRep && (int)$lastRep[0] === (int)$s['day'] ? 'today' : 'sleep'));   // just slept: open on Today
if (!in_array($T, ['today', 'sleep', 'tasks', 'pals', 'costs'], true)) $T = 'sleep';
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
$crewN = pcrew_count($uid);
$today = today_data($u);
$todayN = count($today['need']);
$tabs = ['today' => ['🌅', 'Today'], 'sleep' => ['🛏️', 'Sleep'], 'tasks' => ['📋', 'Tasks'], 'pals' => ['🧩', 'Pals'], 'costs' => ['🕐', 'Costs']];
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
    <a class="<?= $T === $k ? 'on' : '' ?>" href="<?= e(url('hovel.php' . ($k === 'sleep' ? '' : '?t=' . $k))) ?>"><span aria-hidden="true"><?= $ic ?></span> <?= $lb ?><?= $k === 'today' && $todayN > 0 ? ' <small>' . $todayN . '</small>' : '' ?><?= $k === 'tasks' && $todo > 0 ? ' <small>' . $todo . '</small>' : '' ?><?= $k === 'pals' && $crewN > 0 ? ' <small>' . $crewN . '</small>' : '' ?></a>
  <?php endforeach; ?>
</nav>
<?php if ($T === 'today'):
    $groups = ['need' => ['Needs you', true], 'night' => ['Overnight', false], 'village' => ['In the village', false]]; ?>
<section class="box hov hov-today">
  <?php foreach ($groups as $gk => [$gl, $bang]): if (!$today[$gk]) continue; ?>
    <h2 class="hov-sec"><?= $gl ?><?= $bang ? ' <span class="bang" aria-label="needs you">!</span>' : '' ?></h2>
    <ul class="hov-tl">
    <?php foreach ($today[$gk] as [$ic, $tt, $sm, $href]): ?>
      <li class="hov-t<?= $bang ? ' need' : '' ?>"><?= $href !== '' ? '<a href="' . e($href) . '">' : '<div class="hov-tiv">' ?><span class="hov-ti" aria-hidden="true"><?= $ic ?></span><span class="hov-tb"><b><?= e($tt) ?></b><?= $sm !== '' ? '<small class="muted">' . e($sm) . '</small>' : '' ?></span><?= $href !== '' ? '<span class="hov-tr">→</span></a>' : '</div>' ?></li>
    <?php endforeach; ?>
    </ul>
  <?php endforeach; ?>
  <?php if (!$today['need']): ?><p class="muted sm">Nothing needs you right now.</p><?php endif; ?>
  <?php
    $earlier = [];
    try { foreach (q('SELECT game_day, body FROM sleep_report WHERE user_id = ? AND game_day < ? ORDER BY game_day DESC LIMIT 2', [$uid, (int)$s['day']])->fetchAll() as $er) { $b = json_decode((string)$er['body'], true) ?: []; $bits = []; foreach (($b['crew'] ?? []) as $c) if (!empty($c['text'])) $bits[] = $c['text']; $earlier[] = [(int)$er['game_day'], $bits]; } } catch (Throwable $e) {}
    if ($earlier): ?>
    <details class="hov-earlier"><summary>Earlier reports</summary>
      <?php foreach ($earlier as [$ed, $eb]): ?><p class="help"><b>Day <?= $ed ?></b>: <?= $eb ? e(implode(' · ', $eb)) : 'a quiet night' ?></p><?php endforeach; ?></details>
  <?php endif; ?>
  <p><a class="btn alt" href="<?= e(url('hovel.php?t=sleep')) ?>">Go to sleep 🌙</a></p>
</section>
<?php elseif ($T === 'sleep'): ?>
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
<?php elseif ($T === 'pals'):
    $rep = pcrew_latest_report($uid);
    $slotsNow = q('SELECT s.*, pl.garden_name AS plot_name FROM garden_pal_slots s LEFT JOIN plots pl ON pl.id = s.plot_id WHERE s.user_id = ? ORDER BY s.plot_id, s.id', [$uid])->fetchAll(); ?>
<section class="box hov hov-pals">
  <?php if (!$slotsNow && !$rep): ?>
    <p>No pals are working your garden.</p><p class="muted sm">Put a pal on Water, Weed, Pests or Harvest. They work every night while you sleep.</p>
    <p><a class="btn" href="<?= e(url('garden.php?t=help')) ?>">Set up the crew →</a></p>
  <?php else: ?>
    <?php if ($rep && !empty($rep[1]['crew'])): ?>
      <h2>While you slept <small class="muted">(day <?= (int)$rep[0] ?>)</small></h2>
      <ul class="hov-tl">
      <?php foreach ($rep[1]['crew'] as $c): ?>
        <li class="hov-t"><a href="<?= e(url('garden.php?t=help')) ?>"><span class="hov-ti" aria-hidden="true"><?= PCREW_ROLES[$c['role']][0] ?? '🧩' ?></span>
          <span class="hov-tb"><b><?= e($c['pal']) ?> · <?= e(PCREW_ROLES[$c['role']][1] ?? $c['role']) ?></b><small class="muted"><?= e($c['plot']) ?>: <?= e((string)$c['text']) ?><?= !empty($c['ended']) ? ' · finished, resting' : '' ?></small></span>
          <span class="hov-tr"><?= (int)$c['n'] ?></span></a></li>
      <?php endforeach; ?>
      </ul>
    <?php endif; ?>
    <?php if ($slotsNow): ?>
      <h2>Working now</h2>
      <ul class="hov-tl">
      <?php foreach ($slotsNow as $s): $sp = pj_pal($uid, (string)$s['pal_uid']); ?>
        <li class="hov-t active"><a href="<?= e(url('garden.php?t=help')) ?>"><span class="hov-ti" aria-hidden="true"><?= PCREW_ROLES[$s['role']][0] ?? '🧩' ?><?= pcrew_tired($s) ? '<span class="bang">!</span>' : '' ?></span>
          <span class="hov-tb"><b><?= e($sp['name'] ?? 'A pal') ?> · <?= e(PCREW_ROLES[$s['role']][1] ?? $s['role']) ?></b><small class="muted"><?= e((string)($s['plot_name'] ?? 'Garden')) ?><?= pcrew_tired($s) ? ' · tired of this job (' . round(pcrew_eff((int)$s['done'] + 1) * 100) . '%)' : '' ?> · <?= $s['mode'] === 'full' ? 'full time · night ' . ((int)$s['done'] + 1) : 'sleep ' . min((int)$s['nights'], (int)$s['done'] + 1) . ' of ' . (int)$s['nights'] ?></small></span></a></li>
      <?php endforeach; ?>
      </ul>
    <?php endif; ?>
    <p><a class="btn alt" href="<?= e(url('garden.php?t=help')) ?>">Open Garden crew →</a></p>
  <?php endif; ?>
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
