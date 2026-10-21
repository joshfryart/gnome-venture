<?php
declare(strict_types=1);
// Tending someone else's garden through a player job (v0.7.9). Only water, weed and harvest.
require __DIR__ . '/includes/bootstrap.php';
require_once __DIR__ . '/includes/garden_logic.php';
$u = require_login();
$uid = (int)$u['id'];
settle_player_jobs();
$job = active_tend_job($uid);

if (is_post()) {
    csrf_check();
    refresh_energy($u);
    if (!$job) redirect('jobs.php');
    $do = (string)($_POST['do'] ?? '');
    if (in_array($do, ['water_all', 'weed_all', 'harvest_all'], true)) {
        $action = substr($do, 0, -4);
        [, $tiles, $plants] = load_plot((int)$job['poster_id'], true, (int)$job['plot_id']);
        $done = 0;
        $last = [];
        foreach ($tiles as $row) foreach ($row as $t) {
            $p = $t['plant_id'] ? $plants[(int)$t['plant_id']] : null;
            $need = match ($action) {
                'water' => $p && !tile_info($t, $p)['ready'] && tile_info($t, $p)['thirsty'],
                'weed' => $t['method'] === 'notill' && (int)$t['weeds'] >= 5,
                'harvest' => $p && $p['kind'] !== 'cover' && tile_info($t, $p)['ready'],
            };
            if (!$need) continue;
            [$ok, $m] = tend_action($u, $job, $action, (int)$t['x'], (int)$t['y']);
            if (!$ok) { $last = $m; break; }
            $done++;
            $last = $m;
            $job = active_tend_job($uid);
            if (!$job) break;   // job finished
        }
        flash($done ? ucfirst($action === 'weed' ? 'weeded' : $action . 'ed') . " $done square(s). " . implode(' ', array_slice($last, -1)) : ($last[0] ?? 'Nothing needed doing.'), $done ? 'ok' : 'err');
    } else {
        [$ok, $msgs] = tend_action($u, $job, $do, (int)($_POST['x'] ?? -1), (int)($_POST['y'] ?? -1));
        foreach ($msgs as $m) flash($m, $ok ? 'ok' : 'err');
    }
    redirect(active_tend_job($uid) ? 'tend.php' : 'jobs.php');
}

page_header('Tending');
if (!$job): ?>
  <h1>🌱 Tending</h1>
  <div class="box"><p>You’re not tending anyone’s garden right now. Find a “Tend my garden” job on the <a href="<?= e(url('jobs.php')) ?>">Job Board</a>.</p></div>
<?php page_footer(); exit; endif;

[$plot, $tiles, $plants] = load_plot((int)$job['poster_id'], true, (int)$job['plot_id']);
$pj = q_one('SELECT * FROM player_jobs WHERE id = ?', [$job['pj_id']]);
$work = [];
foreach ($tiles as $row) foreach ($row as $t) {
    $p = $t['plant_id'] ? $plants[(int)$t['plant_id']] : null;
    $info = $p ? tile_info($t, $p) : null;
    $acts = [];
    if ($p && $p['kind'] !== 'cover' && $info['ready']) $acts[] = 'harvest';
    elseif ($p && $info['thirsty']) $acts[] = 'water';
    if ($t['method'] === 'notill' && (int)$t['weeds'] >= 5) $acts[] = 'weed';
    $work[] = ['t' => $t, 'p' => $p, 'info' => $info, 'acts' => $acts];
}
$todo = array_filter($work, fn($w) => $w['acts']);
?>
<h1>🌱 Tending <?= eu((string)$plot['garden_name']) ?></h1>
<p class="help">For <?= e((string)$job['npc']) ?>. You can water, weed and harvest here. Each job pays part of the wage:
  <b><?= (int)$pj['progress'] ?> / <?= (int)$pj['qty'] ?></b> done, <?= money((int)$pj['paid']) ?> of <?= money((int)$pj['wage']) ?> earned.
  Time left: <?= nice_time(max(0, ts($pj['ends_at']) - time())) ?>. Harvests go to <?= e((string)$job['npc']) ?>; you keep a <?= (int)setting('helper_cut_percent') ?>% share.</p>
<div class="box">
  <?php foreach (['water_all' => '💧 Water all thirsty', 'weed_all' => '🌿 Weed all', 'harvest_all' => '🧺 Harvest all ready'] as $do => $label): ?>
    <form method="post" class="inline"><?= csrf_field() ?><input type="hidden" name="do" value="<?= $do ?>"><button class="btn small"><?= $label ?></button></form>
  <?php endforeach; ?>
  <?php if (!$todo): ?>
    <p class="muted">Nothing needs doing right now. Plants get thirsty again after a few hours. Check back later!</p>
  <?php else: ?>
    <table class="grid tendlist">
      <tr><th>Square</th><th>Growing</th><th>Needs</th></tr>
      <?php foreach ($todo as $w): $t = $w['t']; ?>
        <tr><td><?= (int)$t['x'] + 1 ?>, <?= (int)$t['y'] + 1 ?></td>
          <td><?= $w['p'] ? e($w['p']['name']) : '<span class="muted">no-till bed</span>' ?></td>
          <td><?php foreach ($w['acts'] as $a): ?>
            <form method="post"><?= csrf_field() ?><input type="hidden" name="do" value="<?= $a ?>"><input type="hidden" name="x" value="<?= (int)$t['x'] ?>"><input type="hidden" name="y" value="<?= (int)$t['y'] ?>">
              <button class="btn small"><?= ['water' => '💧 Water', 'weed' => '🌿 Weed', 'harvest' => '🧺 Harvest'][$a] ?> ⚡<?= ENERGY_COST[$a] ?></button></form>
          <?php endforeach; ?></td></tr>
      <?php endforeach; ?>
    </table>
  <?php endif; ?>
</div>
<p><a href="<?= e(url('jobs.php')) ?>">← Back to the Job Board</a></p>
<?php page_footer();
