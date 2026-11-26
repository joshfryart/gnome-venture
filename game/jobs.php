<?php
declare(strict_types=1);
require __DIR__ . '/includes/bootstrap.php';
require_once __DIR__ . '/includes/garden_logic.php';
require_once __DIR__ . '/includes/items.php';   // v0.9.8: item_pic
$u = require_login();
$uid = (int)$u['id'];
$jbDockFold = dock_on($u);   // v2.8.10: landscape dock: the long explaining lines fold

settle_player_jobs();
// v1.7.2 tasks: one Tasks page, tabs ?t= jobs | journey | requests. Inside Jobs, ?p= is daily | weekly | monthly | post.
// Old links keep working: ?s=quests, ?t=quests (now Journey), ?t=daily|weekly|monthly|post (the old Job Board sub-tabs), and ?t=orders|errands (T2.2: now one Requests tab).
$T = (string)($_GET['t'] ?? '');
$tab = (string)($_GET['p'] ?? 'daily');
if (in_array($_GET['s'] ?? '', ['quests', 'journey'], true)) $T = 'journey';
if (isset(JOB_PERIODS[$T]) || $T === 'post') { $tab = $T; $T = 'jobs'; }
$hub = !empty($_GET['hub']) || !empty($_POST['hub']);
if (!is_post() && in_array($T, ['orders', 'errands'], true)) redirect('jobs.php?t=requests' . ($hub ? '&hub=1' : ''));   // T2.2: old Orders / Errands tab links
if (!is_post() && $T === 'quests') redirect('jobs.php?t=journey' . ($hub ? '&hub=1' : ''));   // the Quests tab is now Journey
if (!in_array($T, ['jobs', 'journey', 'requests'], true)) $T = 'jobs';
if (!isset(JOB_PERIODS[$tab]) && $tab !== 'post') $tab = 'daily';
if (!is_post() && !isset($_GET['t']) && !isset($_GET['p']) && !isset($_GET['s'])) {   // opens where something is ready; an explicit tab or period is never overridden
    $rdyP = '';
    foreach (array_keys(JOB_PERIODS) as $pk) {
        $cj = current_job($uid, $pk);
        if (!$cj || $cj['status'] !== 'active') continue;
        if ($cj['kind'] === 'rebuild') {
            require_once __DIR__ . '/includes/rebuild.php';
            $rdy = !array_filter(rebuild_stage_status($u, min(4, (int)$cj['progress'] + 1)), fn($x) => $x[2] < $x[1]);
        } elseif ((int)$cj['progress'] >= (int)$cj['qty'] && (int)$cj['stages'] <= 1) $rdy = true;
        elseif ($cj['kind'] === 'deliver_part') $rdy = job_deliver_stock($uid, $cj)['have'] > 0;
        elseif ((str_starts_with((string)$cj['kind'], 'deliver') || $cj['kind'] === 'p_deliver') && $cj['target_item_id'])
            $rdy = (int)q_val('SELECT qty FROM user_items WHERE user_id = ? AND item_id = ?', [$uid, $cj['target_item_id']]) > 0;
        else $rdy = false;
        if ($rdy) { $rdyP = $pk; break; }
    }
    if ($rdyP !== '') { $T = 'jobs'; $tab = $rdyP; }
    else {
        require_once __DIR__ . '/includes/quests_view.php';
        $cn0 = tasks_counts($u, $hub);
        if (!empty($cn0['journey'])) $T = 'journey';   // a chapter or repair ready to hand in
        elseif (!empty($cn0['orders'])) $T = 'requests';   // an order you can already fill (errands in flight do not count as ready)
    }
}

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
        redirect('jobs.php?t=requests' . ($hub ? '&hub=1' : ''));
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
<nav class="tabs tabs4 tabs3 jqtabs">
  <?php foreach (['jobs' => ['📋', 'Jobs'], 'journey' => ['📜', 'Journey'], 'requests' => ['📌', 'Requests']] as $tk => [$ti, $tl]): ?>
    <a class="<?= $T === $tk ? 'on' : '' ?>" href="<?= e(url('jobs.php?t=' . $tk . ($tk === 'requests' ? $tq : ''))) ?>"><span aria-hidden="true"><?= $ti ?></span><?= $tl ?><?= !empty($cnt[$tk]) ? '<small>' . (int)$cnt[$tk] . '</small>' : '' ?></a>
  <?php endforeach; ?>
</nav>
<?php if ($T === 'journey'): tasks_quests($u); page_footer(); return; endif;
if ($T === 'requests'): tasks_requests($u, $hub); page_footer(); return; endif; ?>
<?php
require_once __DIR__ . '/includes/rebuild.php';
/** v2.7.38: Jobs page redesign (focus + detail). One period at a time, the Community board is its own area. */
$jbPeriodLeft = function (string $p): string {
    return gclock_on() ? 'Changes when you sleep' : 'Resets in ' . nice_time(job_period_left($p));
};
$jbChips = function (string $text): string {
    $out = '';
    foreach (explode(' · ', $text) as $i => $bit) $out .= '<span class="jb-chip ' . ($i === 0 ? 'gold' : (str_ends_with($bit, ' XP') ? 'xp' : 'item')) . '">' . e($bit) . '</span>';
    return $out;
};
$jbPostOk = !pjob_allowed($u);
$jbOpen = [];
if ($jbPostOk) foreach (['daily', 'weekly'] as $jp) foreach (open_player_jobs($u, $jp) as $pj) $jbOpen[] = $pj;
$jbAct = e(url('jobs.php?t=jobs&p=' . $tab));
?>
<div class="jb">
<p class="help jb-streak">✅ Dailies finished: <b><?= (int)$u['job_dailies'] ?></b>. Every <?= (int)setting('job_streak_every') ?> earns <?= money((int)setting('job_streak_bonus_coins')) ?>. Missing a day never resets it.</p>
<nav class="jobtabs jb-periods" aria-label="Job period">
  <?php foreach (JOB_PERIODS as $pk => [$pl, $pi]): $cj = current_job($uid, $pk);
      $st = !$cj ? '' : ($cj['status'] === 'done' ? 'done' : 'act');
      $sline = !$cj ? 'Pick a job' : ($cj['status'] === 'done' ? 'Done' : ($cj['kind'] === 'rebuild' ? 'Stage ' . min(4, (int)$cj['progress'] + 1) . ' of 4' : (int)$cj['progress'] . ' / ' . (int)$cj['qty'])); ?>
    <a class="jb-per<?= $tab === $pk ? ' on' : '' ?>" href="<?= e(url('jobs.php?t=jobs&p=' . $pk)) ?>"<?= $tab === $pk ? ' aria-current="page"' : '' ?>>
      <span class="t"><span class="jb-dot <?= $st ?>" aria-hidden="true"></span><span aria-hidden="true"><?= $pi ?></span><?= e($pl) ?></span>
      <span class="s"><?= e($sline) ?> · <?= e($jbPeriodLeft($pk)) ?></span></a>
  <?php endforeach; ?>
  <a class="jb-per board<?= $tab === 'post' ? ' on' : '' ?>" href="<?= e(url('jobs.php?t=jobs&p=post')) ?>"<?= $tab === 'post' ? ' aria-current="page"' : '' ?>>
    <span class="t"><span aria-hidden="true">📌</span>Community board<?= $jbOpen ? '<span class="n">' . count($jbOpen) . '</span>' : '' ?></span>
    <span class="s"><?= $jbPostOk ? count($jbOpen) . ' open · post your own' : 'Opens at a higher level' ?></span></a>
</nav>
<?php if ($nRep = count(repair_list($uid))): ?>   <?php // v1.1.0: repairs live in Journey; a pointer here ?>
  <p class="help"><a href="<?= e(url('jobs.php?t=journey#repairs')) ?>">🔨 <?= $nRep ?> repair<?= $nRep === 1 ? '' : 's' ?> under way → Journey</a></p>
<?php endif; ?>

<?php foreach (JOB_PERIODS as $period => [$label, $icon, $count]):
    if ($period !== $tab) continue;
    $job = current_job($uid, $period); ?>
<div class="jb-cols" id="<?= $period ?>">
<?php if ($job): $pct = $job['kind'] === 'grade' ? ((int)$job['progress'] >= (int)$job['qty'] ? 100 : max(0, (int)$job['progress']) * 100 / max(1, (int)$job['qty'])) : (int)$job['progress'] * 100 / max(1, (int)$job['qty']);
      $isDone = $job['status'] === 'done'; ?>
  <section class="jb-card jb-hero">
    <span class="jb-tag <?= $isDone ? 'done' : 'act' ?>"><?= $isDone ? '✅ Done' : '⏳ In progress' ?></span>
    <h2><?= e($job['title']) ?></h2>
    <p class="jb-txt"><?= str_starts_with((string)$job['kind'], 'p_') ? eu($job['text']) : e($job['text']) ?></p>
    <div class="jb-prog"><div class="row"><span><?= e(job_progress_text($job)) ?></span><span><?= (int)$pct ?>%</span></div>
      <progress class="jb-bar" max="100" value="<?= (int)$pct ?>"><?= (int)$pct ?>%</progress></div>
    <?php if ($job['kind'] === 'rebuild' && !$isDone): $stage = (int)$job['progress'] + 1; ?>
      <ol class="jb-steps"><?php foreach (REBUILD_STAGES as $n => [$sname]): ?><li class="<?= $n < $stage ? 'done' : ($n === $stage ? 'now' : '') ?>"><b><?= $n < $stage ? '✅ ' : '' ?>Stage <?= (int)$n ?></b><?= e($sname) ?></li><?php endforeach; ?></ol>
    <?php endif; ?>
    <div class="jb-reward"><span class="lbl"><?= $isDone ? 'Paid' : 'Reward' ?></span><?= $jbChips(job_reward_text($job)) ?></div>
    <?php if ((int)$job['stages'] > 1 && !$isDone): ?><p class="jb-sub">Part is paid at each stage.</p><?php endif; ?>
    <?php if (!$isDone): ?>
      <details class="jb-fold"><summary>Give up this job</summary>
        <p>You keep anything already paid, but lose the rest. Progress does not carry over.</p>
        <form method="post" class="inline" action="<?= $jbAct ?>" data-confirm="Give up this job? You keep anything already paid, but lose the rest."><?= csrf_field() ?><input type="hidden" name="period" value="<?= $period ?>"><input type="hidden" name="do" value="abandon">
          <button class="btn small alt">Give up</button></form></details>
    <?php endif; ?>
  </section>
  <section class="jb-card jb-side">
  <?php if ($isDone): ?>
    <h3>Next <?= e(strtolower($label)) ?> job</h3>
    <p class="jb-txt">Come back after the reset for a new <?= e(strtolower($label)) ?> job.</p>
    <p class="jb-reset">⏳ <?= e($jbPeriodLeft($period)) ?></p>
  <?php elseif ($job['kind'] === 'rebuild'): $st = rebuild_stage_status($u, $stage); $ready = !array_filter($st, fn($x) => $x[2] < $x[1]); ?>
    <h3>Stage <?= $stage ?>: <?= e(REBUILD_STAGES[$stage][0]) ?> needs</h3>
    <p class="jb-sub"><?= $ready ? 'You have everything. Hand it in to move on.' : 'Craft or gather what is short, then hand it in.' ?></p>
    <ul class="jb-needs"><?php foreach ($st as [$lbl, $need, $have]): ?><li class="<?= $have >= $need ? 'good' : 'bad' ?>"><span class="nm"><?= (int)$need ?> <?= e($lbl) ?><small>you have <?= number_format($have) ?></small></span><span class="state"><?= $have >= $need ? '✅ Ready' : '⚠️ Short by ' . number_format($need - $have) ?></span></li><?php endforeach; ?></ul>
    <div class="jb-actions">
      <form method="post" class="inline" action="<?= $jbAct ?>"><?= csrf_field() ?><input type="hidden" name="period" value="<?= $period ?>"><input type="hidden" name="do" value="build">
        <button class="btn" <?= $ready ? '' : 'disabled' ?>>🧱 Hand in stage <?= $stage ?></button></form>
      <a class="btn alt" href="<?= e(craft_url('building')) ?>">Craft materials →</a></div>
  <?php elseif (str_starts_with((string)$job['kind'], 'deliver') || $job['kind'] === 'p_deliver'):
      $have = job_deliver_stock($uid, $job)['have']; ?>
    <h3>Hand in</h3>
    <p class="jb-sub">You have <b><?= $have ?></b> <?= e((string)$job['target_name']) ?> in your satchel.</p>
    <div class="jb-actions"><form method="post" class="inline" action="<?= $jbAct ?>"><?= csrf_field() ?><input type="hidden" name="period" value="<?= $period ?>"><input type="hidden" name="do" value="deliver">
      <button class="btn" <?= $have ? '' : 'disabled' ?>>Hand in <?= $job['kind'] === 'deliver_part' ? '🦴 ' : item_pic(['id' => $job['target_item_id'], 'name' => (string)$job['target_name']], 'sm') ?><?= e((string)$job['target_name']) ?></button></form></div>
  <?php elseif ($job['kind'] === 'p_tend'): ?>
    <h3>Go tend</h3>
    <p class="jb-sub">Water, weed and harvest in <?= e((string)$job['npc']) ?>’s garden.</p>
    <div class="jb-actions"><a class="btn" href="<?= e(url('tend.php')) ?>">Go to <?= e((string)$job['npc']) ?>’s garden →</a></div>
  <?php else: ?>
    <h3>How to finish it</h3>
    <p class="jb-txt"><?= e(job_hint($job) ?: 'Do the work and it counts on its own. Progress shows on the left.') ?></p>
    <p class="jb-reset">⏳ <?= e($jbPeriodLeft($period)) ?></p>
  <?php endif; ?>
  </section>
<?php else: $offers = job_offers($u, $period); ?>
  <section class="jb-card jb-pick">
    <h2><?= $icon ?> Choose a <?= e(strtolower($label)) ?> job</h2>
    <p class="jb-sub"><?= e($jbPeriodLeft($period)) ?>. Progress does not carry over.</p>
    <?php if (!$offers): ?><p class="jb-empty">No jobs you can do yet. Grow a few crops and come back!</p><?php endif; ?>
    <div class="jb-offers">
    <?php foreach ($offers as $i => $o): $rb = explode(' · ', job_reward_text($o)); $rcoin = array_shift($rb); ?>
      <details class="jb-offer" name="jb-offer-<?= $period ?>"<?= $i === 0 ? ' open' : '' ?>>
        <summary><div class="ttl"><h3><?= e($o['title']) ?></h3><small><?= e($o['text']) ?></small></div><span class="pay"><?= e($rcoin) ?></span></summary>
        <div class="body">
          <?php if (($hint = job_hint($o)) !== ''): ?><p class="jb-hint jobhint"><?= e($hint) ?></p><?php endif; ?>
          <div class="jb-reward"><span class="lbl">Reward</span><?= $jbChips(job_reward_text($o)) ?></div>
          <?php if ($o['stages'] > 1): ?><p class="jb-sub"><?= (int)$o['stages'] ?> stages, paid as you go.</p><?php endif; ?>
          <form method="post" class="inline" action="<?= $jbAct ?>"><?= csrf_field() ?><input type="hidden" name="period" value="<?= $period ?>"><input type="hidden" name="do" value="take"><input type="hidden" name="tpl" value="<?= (int)$o['template_id'] ?>"><input type="hidden" name="target" value="<?= e((string)$o['target']) ?>">
            <button class="btn">📋 Take this job</button></form>
        </div>
      </details>
    <?php endforeach; ?>
    </div>
  </section>
  <section class="jb-side-col">
    <?php if ($period !== 'monthly' && $offers): ?>
      <form method="post" action="<?= $jbAct ?>" class="reroll jb-foot"><?= csrf_field() ?><input type="hidden" name="period" value="<?= $period ?>"><input type="hidden" name="do" value="reroll">
        <button class="btn small alt" <?= job_rerolled($uid, $period) ? 'disabled' : '' ?>>🎲 Re-roll offers<?= job_rerolled($uid, $period) ? ' (used)' : ' (once a ' . job_period_word($period) . ')' ?></button></form>
    <?php endif; ?>
    <?php $mineP = array_values(array_filter($jbOpen, fn($pj) => pjob_period($pj) === $period && $period !== 'monthly'));
    if ($mineP): ?>
      <section class="jb-card jb-board"><h3>📌 Posted by other gnomes</h3>
        <?php foreach ($mineP as $pj): ?>
          <div class="job pjob jb-pj"><div class="info"><b><?= e(pjob_title($pj)) ?></b><p><?= eu(pjob_text($pj)) ?><?= $pj['note'] ? report_link((int)$pj['poster_id'], 'job', (int)$pj['id']) : '' ?></p></div>
            <form method="post" class="inline" action="<?= $jbAct ?>"><?= csrf_field() ?><input type="hidden" name="do" value="take_player"><input type="hidden" name="id" value="<?= (int)$pj['id'] ?>">
              <b class="wage"><?= money((int)$pj['wage']) ?></b><button class="btn small">Take this job</button></form></div>
        <?php endforeach; ?>
      </section>
    <?php endif; ?>
  </section>
<?php endif; ?>
</div>
<?php endforeach; ?>

<?php if ($tab === 'post'): ?>
<div id="post">
<?php if ($why = pjob_allowed($u)): ?>
  <p class="jb-empty"><?= e($why) ?></p>
<?php else:
    $mine = q("SELECT pj.*, i.name AS item_name, pl.garden_name, COALESCE(t.gnome_name, t.username) AS taker FROM player_jobs pj
               LEFT JOIN items i ON i.id = pj.item_id LEFT JOIN plots pl ON pl.id = pj.plot_id LEFT JOIN users t ON t.id = pj.taker_id
               WHERE pj.poster_id = ? ORDER BY pj.id DESC LIMIT 6", [$uid])->fetchAll();
    $gardens = q('SELECT id, garden_name FROM plots WHERE user_id = ? ORDER BY id', [$uid])->fetchAll();
    require_once __DIR__ . '/includes/crafting.php';
    $slugs = array_keys(collected_slugs($uid));
    $wantable = $slugs ? q('SELECT id, name FROM items WHERE slug IN (' . implode(',', array_fill(0, count($slugs), '?')) . ")
                           AND category NOT IN ('tool', 'guide') AND tradable = 1 ORDER BY name", $slugs)->fetchAll() : []; ?>
  <div class="jb-cols even">
    <section class="jb-card jb-board"><h2>📌 Posted by other gnomes</h2>
      <?php if (!$jbOpen): ?><p class="jb-empty">Nothing on the board right now.</p><?php endif; ?>
      <?php foreach ($jbOpen as $pj): $pp = pjob_period($pj); $busy = (bool)current_job($uid, $pp); ?>
        <div class="job pjob jb-pj"><div class="info"><b><?= e(pjob_title($pj)) ?></b><p><?= eu(pjob_text($pj)) ?><?= $pj['note'] ? report_link((int)$pj['poster_id'], 'job', (int)$pj['id']) : '' ?></p>
            <small class="who"><?= e((string)$pj['poster']) ?> · <?= $pp === 'daily' ? 'Daily' : 'Weekly' ?> slot<?= $busy ? ' · your slot is full' : '' ?></small></div>
          <form method="post" class="inline" action="<?= $jbAct ?>"><?= csrf_field() ?><input type="hidden" name="do" value="take_player"><input type="hidden" name="id" value="<?= (int)$pj['id'] ?>">
            <b class="wage"><?= money((int)$pj['wage']) ?></b><button class="btn small" <?= $busy ? 'disabled' : '' ?>>Take this job</button></form></div>
      <?php endforeach; ?>
    </section>
    <div class="jb-forms">
      <?php if ($jbDockFold): ?><details class="helpfold jb-info"><summary>ℹ️ How posting works</summary><p class="jb-sub">The wage comes out of your purse now and is held safely. The worker is paid bit by bit as they do the work; anything they don’t earn comes back to you. Jobs stay on the board for <?= (int)setting('player_job_listing_days') ?> days. A one-day job fills their daily slot, longer ones their weekly slot.</p></details><?php else: ?><p class="jb-sub">The wage comes out of your purse now and is held safely. The worker is paid bit by bit as they do the work; anything they don’t earn comes back to you. Jobs stay on the board for <?= (int)setting('player_job_listing_days') ?> days. A one-day job fills their daily slot, longer ones their weekly slot.</p><?php endif; ?>
      <form method="post" class="jb-card jb-form" action="<?= $jbAct ?>"><?= csrf_field() ?><input type="hidden" name="do" value="post"><input type="hidden" name="kind" value="tend">
        <h3>🌱 Tend my garden</h3>
        <?php if ($jbDockFold): ?><details class="helpfold jb-info"><summary>ℹ️ Details</summary><p class="jb-sub">They can only water, weed and harvest. Harvests come to you, less a <?= (int)setting('helper_cut_percent') ?>% share for them. Full pay = <?= (int)setting('player_tend_actions_per_day') ?> jobs a day.</p></details><?php else: ?><p class="jb-sub">They can only water, weed and harvest. Harvests come to you, less a <?= (int)setting('helper_cut_percent') ?>% share for them. Full pay = <?= (int)setting('player_tend_actions_per_day') ?> jobs a day.</p><?php endif; ?>
        <div class="g2">
          <label>Garden <select name="plot_id"><?php foreach ($gardens as $g): ?><option value="<?= (int)$g['id'] ?>"><?= eu((string)$g['garden_name']) ?></option><?php endforeach; ?></select></label>
          <label>For <select name="days"><?php foreach (PJOB_TEND_DAYS as $d): ?><option value="<?= $d ?>"><?= $d ?> day<?= $d > 1 ? 's' : '' ?></option><?php endforeach; ?></select></label>
          <label>Wage <input type="number" name="wage" min="<?= (int)setting('player_job_min_wage') ?>" value="<?= (int)setting('player_job_min_wage') * 3 ?>"></label>
          <label>Note (optional) <input name="note" maxlength="140" placeholder="The tomatoes are thirsty!"></label>
        </div>
        <button class="btn small">Post job</button>
      </form>
      <form method="post" class="jb-card jb-form" action="<?= $jbAct ?>"><?= csrf_field() ?><input type="hidden" name="do" value="post"><input type="hidden" name="kind" value="deliver">
        <h3>📦 Bring me something</h3>
        <?php if ($jbDockFold): ?><details class="helpfold jb-info"><summary>ℹ️ Details</summary><p class="jb-sub">Ask for anything you’ve grown, gathered or held. Items arrive in your satchel as they’re handed in.</p></details><?php else: ?><p class="jb-sub">Ask for anything you’ve grown, gathered or held. Items arrive in your satchel as they’re handed in.</p><?php endif; ?>
        <div class="g2">
          <label>Item <select name="item_id"><?php foreach ($wantable as $it): ?><option value="<?= (int)$it['id'] ?>"><?= e($it['name']) ?></option><?php endforeach; ?></select></label>
          <label>How many <input type="number" name="qty" min="1" max="500" value="10"></label>
          <label>Deadline <select name="size"><option value="daily">A day (their daily slot)</option><option value="weekly">A week (their weekly slot)</option></select></label>
          <label>Wage <input type="number" name="wage" min="<?= (int)setting('player_job_min_wage') ?>" value="100"></label>
          <label class="wide">Note (optional) <input name="note" maxlength="140"></label>
        </div>
        <button class="btn small">Post job</button>
      </form>
    </div>
  </div>
  <?php if ($mine): ?>
    <section class="jb-card jb-mine"><h2>Your posted jobs</h2>
      <?php foreach ($mine as $pj): $pj['poster'] = 'You'; ?>
        <div class="jb-mrow">
          <div><b><?= e(pjob_title($pj)) ?></b></div>
          <div><span class="jb-pill <?= e((string)$pj['status']) ?>"><?= e(['open' => 'Waiting for a taker', 'taken' => 'Taken by ' . $pj['taker'], 'done' => 'Done ✅', 'expired' => 'Ended', 'cancelled' => 'Taken down', 'abandoned' => 'Given up'][$pj['status']] ?? $pj['status']) ?></span></div>
          <div><small><?= (int)$pj['progress'] ?> / <?= (int)$pj['qty'] ?> · paid <?= money((int)$pj['paid']) ?> / <?= money((int)$pj['wage']) ?></small>
            <progress class="jb-bar mini" max="100" value="<?= (int)((int)$pj['progress'] * 100 / max(1, (int)$pj['qty'])) ?>"></progress></div>
          <div><?php if ($pj['status'] === 'open'): ?>
            <form method="post" action="<?= $jbAct ?>" data-confirm="Take this job down? The wage comes back to you."><?= csrf_field() ?><input type="hidden" name="do" value="cancel"><input type="hidden" name="id" value="<?= (int)$pj['id'] ?>">
              <button class="btn small alt">Take down</button></form><?php endif; ?></div>
        </div>
      <?php endforeach; ?>
    </section>
  <?php endif; ?>
<?php endif; ?>
</div>
<?php endif; ?>
</div>
<?php page_footer();
