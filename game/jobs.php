<?php
declare(strict_types=1);
require __DIR__ . '/includes/bootstrap.php';
require_once __DIR__ . '/includes/garden_logic.php';
require_once __DIR__ . '/includes/items.php';   // v0.9.8: item_pic
$u = require_login();
$uid = (int)$u['id'];

settle_player_jobs();
// v1.7.2 tasks: one Tasks page, tabs ?t= jobs | quests | orders | errands. Inside Jobs, ?p= is daily | weekly | monthly | post.
// Old links keep working: ?s=quests, and ?t=daily|weekly|monthly|post (the old Job Board sub-tabs).
$T = (string)($_GET['t'] ?? '');
$tab = (string)($_GET['p'] ?? 'daily');
if (($_GET['s'] ?? '') === 'quests') $T = 'quests';
if (isset(JOB_PERIODS[$T]) || $T === 'post') { $tab = $T; $T = 'jobs'; }
if (!in_array($T, ['jobs', 'quests', 'orders', 'errands'], true)) $T = 'jobs';
if (!isset(JOB_PERIODS[$tab]) && $tab !== 'post') $tab = 'daily';
$hub = !empty($_GET['hub']) || !empty($_POST['hub']);

if (is_post()) {
    csrf_check();
    unset($_SESSION['nav_badges']);   // v1.7.5: the Tasks badge is recounted after any job/order action
    $do = (string)($_POST['do'] ?? '');
    if (in_array($do, ['post', 'cancel', 'take_player'], true)) {
        [$ok, $msg] = match ($do) {
            'post' => post_player_job($u, $_POST),
            'cancel' => cancel_player_job($u, (int)($_POST['id'] ?? 0)),
            'take_player' => take_player_job($u, (int)($_POST['id'] ?? 0)),
        };
        flash($msg, $ok ? 'ok' : 'err');
        redirect('jobs.php?t=jobs&p=' . $tab);
    }
    if (in_array($do, ['order', 'favour'], true)) {   // v1.7.2 tasks: the order board lives here now
        require_once __DIR__ . '/includes/quests_view.php';
        [$ok, $msg] = tasks_order_post($u, $do, (int)($_POST['npc'] ?? 0), $hub);
        flash($msg, $ok ? 'ok' : 'err');
        redirect('jobs.php?t=orders' . ($hub ? '&hub=1' : ''));
    }
    $period = (string)($_POST['period'] ?? '');
    if (!isset(JOB_PERIODS[$period])) redirect('jobs.php?t=jobs&p=' . $tab);
    [$ok, $msg] = match ($do) {
        'take' => take_job($u, $period, (int)($_POST['tpl'] ?? 0), (string)($_POST['target'] ?? '')),
        'deliver' => deliver_job($uid, $period),
        'build' => (function () use ($u, $uid, $period) {
            require_once __DIR__ . '/includes/rebuild.php';
            $job = current_job($uid, $period);
            return $job && $job['kind'] === 'rebuild' && $job['status'] === 'active' ? rebuild_hand_in($u, $job) : [false, 'Nothing to build.'];
        })(),
        'abandon' => abandon_job($uid, $period),
        'reroll' => reroll_jobs($uid, $period),
        default => [false, 'Unknown action.'],
    };
    flash($msg, $ok ? 'ok' : 'err');
    redirect('jobs.php?t=jobs&p=' . $period);
}

const JOB_REWARD_LABELS = ['@treasure-seed' => 'a rare treasure seed', '@guide' => 'a gardening guide', '@rare-gather' => 'a rare find', '@rare-material' => 'a rare crafting material'];

function job_reward_text(array $j): string
{
    $bits = [money((int)$j['reward_coins']), job_xp_paid($j) . ' XP'];   // v0.9.1: monthly jobs pay less XP
    if (!empty($j['reward_item_id'])) {
        $bits[] = (int)$j['reward_qty'] . ' × ' . q_val('SELECT name FROM items WHERE id = ?', [$j['reward_item_id']]);
    } elseif (!empty($j['reward_item'])) {
        [$slug, $qty] = array_map('trim', explode(':', (string)$j['reward_item']) + [1 => 1]);
        $bits[] = (int)$qty . ' × ' . (JOB_REWARD_LABELS[$slug] ?? (q_val('SELECT name FROM items WHERE slug = ?', [$slug]) ?: $slug));
    }
    return implode(' · ', $bits);
}

require_once __DIR__ . '/includes/quests_view.php';
page_header('Tasks');
$cnt = tasks_counts($u, $hub);
$tq = $hub ? '&hub=1' : '';
?>
<h1>📋 Tasks</h1>
<nav class="tabs tabs4 jqtabs">
  <?php foreach (['jobs' => ['📋', 'Jobs'], 'quests' => ['📜', 'Quests'], 'orders' => ['📌', 'Orders'], 'errands' => ['🧺', 'Errands']] as $tk => [$ti, $tl]): ?>
    <a class="<?= $T === $tk ? 'on' : '' ?>" href="<?= e(url('jobs.php?t=' . $tk . ($tk === 'orders' ? $tq : ''))) ?>"><span aria-hidden="true"><?= $ti ?></span><?= $tl ?><?= !empty($cnt[$tk]) ? '<small>' . (int)$cnt[$tk] . '</small>' : '' ?></a>
  <?php endforeach; ?>
</nav>
<?php if ($T === 'quests'): tasks_quests($u); page_footer(); return; endif;
if ($T === 'orders'): tasks_orders($u, $hub); page_footer(); return; endif;
if ($T === 'errands'): tasks_errands($u); page_footer(); return; endif; ?>
<p class="help">Hold one daily, one weekly and one monthly job at a time. Dailies finished: <b><?= (int)$u['job_dailies'] ?></b>
  (every <?= (int)setting('job_streak_every') ?> earns a <?= money((int)setting('job_streak_bonus_coins')) ?> bonus; missing a day never resets it).</p>
<nav class="tabs jobtabs">
  <?php foreach (JOB_PERIODS as $pk => [$pl, $pi]): $cj = current_job($uid, $pk); ?>
    <a class="<?= $tab === $pk ? 'on' : '' ?>" href="<?= e(url('jobs.php?t=jobs&p=' . $pk)) ?>"><?= $pi ?> <?= e($pl) ?><?= $cj ? ($cj['status'] === 'done' ? ' ✅' : ' ⏳') : '' ?></a>
  <?php endforeach; ?>
  <a class="<?= $tab === 'post' ? 'on' : '' ?>" href="<?= e(url('jobs.php?t=jobs&p=post')) ?>">📌 Post a job</a>
</nav>
<?php require_once __DIR__ . '/includes/rebuild.php';   // v1.1.0: repairs moved to the Quests section; a pointer here
if ($nRep = count(repair_list($uid))): ?>
  <p class="help"><a href="<?= e(url('jobs.php?t=quests#repairs')) ?>">🔨 <?= $nRep ?> repair<?= $nRep === 1 ? '' : 's' ?> under way → Quests</a></p>
<?php endif; ?>

<?php foreach (JOB_PERIODS as $period => [$label, $icon, $count]):
    if ($period !== $tab) continue;
    $job = current_job($uid, $period); ?>
  <section class="box jobs" id="<?= $period ?>">
    <h2><?= $icon ?> <?= e($label) ?> <small class="muted">resets in <?= nice_time(job_period_left($period)) ?></small></h2>
    <?php if ($job): $pct = $job['kind'] === 'grade' ? ((int)$job['progress'] >= (int)$job['qty'] ? 100 : max(0, (int)$job['progress']) * 100 / max(1, (int)$job['qty'])) : (int)$job['progress'] * 100 / max(1, (int)$job['qty']); ?>
      <div class="job taken<?= $job['status'] === 'done' ? ' done' : '' ?>">
        <h3><?= e($job['title']) ?> <?= $job['status'] === 'done' ? '<span class="tag">✅ done</span>' : '' ?></h3>
        <p><?= str_starts_with((string)$job['kind'], 'p_') ? eu($job['text']) : e($job['text']) ?></p>
        <progress max="100" value="<?= (int)$pct ?>"></progress> <span class="help"><?= e(job_progress_text($job)) ?></span>
        <p class="help">Reward: <?= e(job_reward_text($job)) ?><?= (int)$job['stages'] > 1 ? ' (part paid at each stage)' : '' ?></p>
        <?php if ($job['status'] === 'done'): ?>
          <p class="muted">Come back after the reset for a new <?= strtolower($label) ?> job.</p>
        <?php else: ?>
          <?php if ($job['kind'] === 'p_tend'): ?>
            <a class="btn small" href="<?= e(url('tend.php')) ?>">Go to <?= e((string)$job['npc']) ?>’s garden →</a>
          <?php endif; ?>
          <?php if ($job['kind'] === 'rebuild'): require_once __DIR__ . '/includes/rebuild.php';
              $stage = (int)$job['progress'] + 1; $st = rebuild_stage_status($u, $stage); $ready = !array_filter($st, fn($x) => $x[2] < $x[1]); ?>
            <div class="rebuild">
              <ol class="stages"><?php foreach (REBUILD_STAGES as $n => [$sname]): ?><li class="<?= $n < $stage ? 'done' : ($n === $stage ? 'now' : '') ?>"><?= $n < $stage ? '✅ ' : '' ?><?= e($sname) ?></li><?php endforeach; ?></ol>
              <p><b>Stage <?= $stage ?>: <?= e(REBUILD_STAGES[$stage][0]) ?></b> needs:</p>
              <ul><?php foreach ($st as [$lbl, $need, $have]): ?><li class="<?= $have >= $need ? 'good' : 'bad' ?>"><?= $need ?> <?= e($lbl) ?> <small class="muted">(you have <?= number_format($have) ?>)</small></li><?php endforeach; ?></ul>
              <form method="post" class="inline" action="<?= e(url('jobs.php?t=jobs&p=' . $tab)) ?>"><?= csrf_field() ?><input type="hidden" name="period" value="<?= $period ?>"><input type="hidden" name="do" value="build">
                <button class="btn small" <?= $ready ? '' : 'disabled' ?>>🧱 Hand in stage <?= $stage ?></button></form>
              <a class="btn small alt" href="<?= e(url('inventory.php?tab=craft&c=building')) ?>">Craft materials →</a>
            </div>
          <?php endif; ?>
          <?php if (str_starts_with((string)$job['kind'], 'deliver') || $job['kind'] === 'p_deliver'):
              $have = (int)q_val('SELECT qty FROM user_items WHERE user_id = ? AND item_id = ?', [$uid, $job['target_item_id']]); ?>
            <form method="post" class="inline" action="<?= e(url('jobs.php?t=jobs&p=' . $tab)) ?>"><?= csrf_field() ?><input type="hidden" name="period" value="<?= $period ?>"><input type="hidden" name="do" value="deliver">
              <button class="btn small" <?= $have ? '' : 'disabled' ?>>Hand in <?= item_pic(['id' => $job['target_item_id'], 'name' => (string)$job['target_name']], 'sm') ?><?= e((string)$job['target_name']) ?> (you have <?= $have ?>)</button></form>
          <?php endif; ?>
          <form method="post" class="inline" action="<?= e(url('jobs.php?t=jobs&p=' . $tab)) ?>" data-confirm="Give up this job? You keep anything already paid, but lose the rest."><?= csrf_field() ?><input type="hidden" name="period" value="<?= $period ?>"><input type="hidden" name="do" value="abandon">
            <button class="btn small alt">Give up</button></form>
        <?php endif; ?>
      </div>
    <?php else: $offers = job_offers($u, $period); ?>
      <?php if (!$offers): ?><p class="muted">No jobs you can do yet. Grow a few crops and come back!</p><?php endif; ?>
      <div class="joblist">
      <?php foreach ($offers as $o): ?>
        <div class="job">
          <h3><?= e($o['title']) ?></h3>
          <p><?= e($o['text']) ?></p>
          <?php $rb = explode(' · ', job_reward_text($o)); $rcoin = array_shift($rb); ?>
          <?php if (($hint = job_hint($o)) !== ''): ?><p class="help jobhint"><?= e($hint) ?></p><?php endif; ?>
          <form method="post" class="choiceform" action="<?= e(url('jobs.php?t=jobs&p=' . $tab)) ?>"><?= csrf_field() ?><input type="hidden" name="period" value="<?= $period ?>"><input type="hidden" name="do" value="take"><input type="hidden" name="tpl" value="<?= (int)$o['template_id'] ?>"><input type="hidden" name="target" value="<?= e((string)$o['target']) ?>">
            <?= choice_row('📋', 'Take this job', 'Reward: ' . implode(' · ', $rb) . ($o['stages'] > 1 ? ' · ' . (int)$o['stages'] . ' stages' : ''), [$rcoin, 'cost'], 'primary') ?></form>   <?php // v1.6.3: .choice row with the Petals as its badge ?>
        </div>
      <?php endforeach; ?>
      </div>
      <?php $pjobs = $period !== 'monthly' && !pjob_allowed($u) ? open_player_jobs($u, $period) : [];
      if ($pjobs): ?>
        <h3 class="pjhead">📌 Posted by other gnomes</h3>
        <div class="joblist">
        <?php foreach ($pjobs as $pj): ?>
          <div class="job pjob">
            <h3><?= e(pjob_title($pj)) ?></h3>
            <p><?= eu(pjob_text($pj)) ?><?= $pj['note'] ? report_link((int)$pj['poster_id'], 'job', (int)$pj['id']) : '' ?></p>
            <form method="post" class="choiceform" action="<?= e(url('jobs.php?t=jobs&p=' . $tab)) ?>"><?= csrf_field() ?><input type="hidden" name="do" value="take_player"><input type="hidden" name="id" value="<?= (int)$pj['id'] ?>">
              <?= choice_row('📌', 'Take this job', 'Wage held safely until the work is done', [money_txt((int)$pj['wage']), 'cost'], 'primary') ?></form>
          </div>
        <?php endforeach; ?>
        </div>
      <?php endif; ?>
      <?php if ($period !== 'monthly' && $offers): ?>
        <form method="post" action="<?= e(url('jobs.php?t=jobs&p=' . $tab)) ?>" class="reroll"><?= csrf_field() ?><input type="hidden" name="period" value="<?= $period ?>"><input type="hidden" name="do" value="reroll">
          <button class="btn small alt" <?= job_rerolled($uid, $period) ? 'disabled' : '' ?>>🎲 Re-roll offers<?= job_rerolled($uid, $period) ? ' (used)' : ' (once a ' . job_period_word($period) . ')' ?></button></form>
      <?php endif; ?>
    <?php endif; ?>
  </section>
<?php endforeach; ?>

<?php if ($tab === 'post'): ?>
<section class="box jobs" id="post">
  <h2>📌 Post a job for other gnomes</h2>
  <?php if ($why = pjob_allowed($u)): ?>
    <p class="muted"><?= e($why) ?></p>
  <?php else:
      $mine = q("SELECT pj.*, i.name AS item_name, pl.garden_name, COALESCE(t.gnome_name, t.username) AS taker FROM player_jobs pj
                 LEFT JOIN items i ON i.id = pj.item_id LEFT JOIN plots pl ON pl.id = pj.plot_id LEFT JOIN users t ON t.id = pj.taker_id
                 WHERE pj.poster_id = ? ORDER BY pj.id DESC LIMIT 6", [$uid])->fetchAll();
      $gardens = q('SELECT id, garden_name FROM plots WHERE user_id = ? ORDER BY id', [$uid])->fetchAll();
      require_once __DIR__ . '/includes/crafting.php';
      $slugs = array_keys(collected_slugs($uid));
      $wantable = $slugs ? q('SELECT id, name FROM items WHERE slug IN (' . implode(',', array_fill(0, count($slugs), '?')) . ")
                             AND category NOT IN ('tool', 'guide') AND tradable = 1 ORDER BY name", $slugs)->fetchAll() : []; ?>
    <p class="help">The wage comes out of your purse now and is held safely. The worker is paid bit by bit as they do the work;
      anything they don’t earn comes back to you. Jobs stay on the board for <?= (int)setting('player_job_listing_days') ?> days.
      A one-day job fills their daily slot, longer ones their weekly slot.</p>
    <div class="postforms">
      <form method="post" class="form job" action="<?= e(url('jobs.php?t=jobs&p=' . $tab)) ?>"><?= csrf_field() ?><input type="hidden" name="do" value="post"><input type="hidden" name="kind" value="tend">
        <h3>🌱 Tend my garden</h3>
        <p class="help">They can only water, weed and harvest. Harvests come to you, less a <?= (int)setting('helper_cut_percent') ?>% share for them.
          Full pay = <?= (int)setting('player_tend_actions_per_day') ?> jobs a day.</p>
        <label>Garden <select name="plot_id"><?php foreach ($gardens as $g): ?><option value="<?= (int)$g['id'] ?>"><?= eu((string)$g['garden_name']) ?></option><?php endforeach; ?></select></label>
        <label>For <select name="days"><?php foreach (PJOB_TEND_DAYS as $d): ?><option value="<?= $d ?>"><?= $d ?> day<?= $d > 1 ? 's' : '' ?></option><?php endforeach; ?></select></label>
        <label>Wage <input type="number" name="wage" min="<?= (int)setting('player_job_min_wage') ?>" value="<?= (int)setting('player_job_min_wage') * 3 ?>"></label>
        <label>Note (optional) <input name="note" maxlength="140" placeholder="The tomatoes are thirsty!"></label>
        <button class="btn small">Post job</button>
      </form>
      <form method="post" class="form job" action="<?= e(url('jobs.php?t=jobs&p=' . $tab)) ?>"><?= csrf_field() ?><input type="hidden" name="do" value="post"><input type="hidden" name="kind" value="deliver">
        <h3>📦 Bring me something</h3>
        <p class="help">Ask for anything you’ve grown, gathered or held. Items arrive in your satchel as they’re handed in.</p>
        <label>Item <select name="item_id"><?php foreach ($wantable as $it): ?><option value="<?= (int)$it['id'] ?>"><?= e($it['name']) ?></option><?php endforeach; ?></select></label>
        <label>How many <input type="number" name="qty" min="1" max="500" value="10"></label>
        <label>Deadline <select name="size"><option value="daily">A day (their daily slot)</option><option value="weekly">A week (their weekly slot)</option></select></label>
        <label>Wage <input type="number" name="wage" min="<?= (int)setting('player_job_min_wage') ?>" value="100"></label>
        <label>Note (optional) <input name="note" maxlength="140"></label>
        <button class="btn small">Post job</button>
      </form>
    </div>
    <?php if ($mine): ?>
      <h3>Your posted jobs</h3>
      <table class="grid">
        <tr><th>Job</th><th>Status</th><th>Progress</th><th>Paid / wage</th><th></th></tr>
        <?php foreach ($mine as $pj): $pj['poster'] = 'You'; ?>
          <tr><td><?= e(pjob_title($pj)) ?></td>
            <td><?= e(['open' => 'Waiting for a taker', 'taken' => 'Taken by ' . $pj['taker'], 'done' => 'Done ✅', 'expired' => 'Ended', 'cancelled' => 'Taken down', 'abandoned' => 'Given up'][$pj['status']] ?? $pj['status']) ?></td>
            <td><?= (int)$pj['progress'] ?> / <?= (int)$pj['qty'] ?></td>
            <td><?= money((int)$pj['paid']) ?> / <?= money((int)$pj['wage']) ?></td>
            <td><?php if ($pj['status'] === 'open'): ?>
              <form method="post" action="<?= e(url('jobs.php?t=jobs&p=' . $tab)) ?>" data-confirm="Take this job down? The wage comes back to you."><?= csrf_field() ?><input type="hidden" name="do" value="cancel"><input type="hidden" name="id" value="<?= (int)$pj['id'] ?>">
                <button class="btn small alt">Take down</button></form><?php endif; ?></td></tr>
        <?php endforeach; ?>
      </table>
    <?php endif; ?>
  <?php endif; ?>
</section>
<?php endif; ?>
<?php page_footer();
