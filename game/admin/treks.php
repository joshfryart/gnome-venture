<?php
declare(strict_types=1);
// v1.8.0: Treks runs. Who is on a trek, where, and a reset (deletes the run, party, pack, flags and recruits; Almanac pages and banked items stay).
// v1.8.9: the trek_ms table (milestone XP paid, one row per player and milestone) is deliberately NOT cleared, so a reset never pays a milestone twice.
require dirname(__DIR__) . '/includes/bootstrap.php';
require_once dirname(__DIR__) . '/includes/admin_helpers.php';
require_once dirname(__DIR__) . '/includes/trek_data.php';
$me = require_admin();

if (is_post()) {
    csrf_check();
    $id = (int)($_POST['run'] ?? 0);
    $run = $id ? q_one('SELECT r.*, u.username FROM trek_runs r JOIN users u ON u.id = r.user_id WHERE r.id = ?', [$id]) : null;
    if (!$run) {
        flash('That run is gone.', 'err');
    } elseif (trim((string)($_POST['confirm'] ?? '')) !== 'RESET') {
        flash('Type RESET in the box to confirm.', 'err');
    } else {
        db()->beginTransaction();
        foreach (['trek_party', 'trek_pack', 'trek_flags', 'trek_recruits'] as $t) q("DELETE FROM $t WHERE run_id = ?", [$id]);
        q('DELETE FROM trek_runs WHERE id = ?', [$id]);
        // v1.9.1: a later chapter's run reset: the gnome is back in the interlude of the chapter before (and goes down again with the party carried over)
        if ((int)$run['chapter'] > 1) q('UPDATE users SET trek_ch = ? WHERE id = ? AND trek_ch >= ?', [(int)$run['chapter'] - 1, (int)$run['user_id'], (int)$run['chapter']]);
        db()->commit();
        admin_log('trek_reset', (string)$run['username'], 'run ' . $id . ' chapter ' . (int)$run['chapter']);
        flash('Reset Chapter ' . trek_roman((int)$run['chapter']) . ' of ' . $run['username'] . '.');
    }
    redirect('admin/treks.php');
}

$runs = q('SELECT r.*, u.username, u.level, u.trek_ch, u.trek_pet_day, u.trek_pet_today FROM trek_runs r JOIN users u ON u.id = r.user_id ORDER BY r.user_id, r.chapter LIMIT 400')->fetchAll();
page_header('Treks', true);
admin_crumbs('treks.php');
?>
<h1>🥾 Treks</h1>
<p class="help">Treks are <b><?= setting('trek_open') === '1' ? 'open to everyone' : 'admins only' ?></b> (Game settings → Treks). Story text: <a href="<?= e(url('admin/trek_text.php')) ?>">Trek story text</a>.</p>
<?php if (!$runs): ?><div class="box"><p>No runs yet.</p></div><?php endif; ?>
<?php foreach ($runs as $r): $zone = trek_zone_at((int)$r['chapter'], (int)$r['x'], (int)$r['y']); $cdef = trek_chapter((int)$r['chapter']); $isDone = (bool)q_val('SELECT 1 FROM trek_flags WHERE run_id = ? AND flag = ?', [$r['id'], 'ch' . (int)$r['chapter'] . '_done']); ?>
  <div class="box">
    <h3><?= e($r['username']) ?> <small class="muted">level <?= (int)$r['level'] ?> · <?= e($r['trek_key']) ?> · <?= e($r['mode']) ?></small></h3>
    <p><b>Chapter <?= e($cdef['roman']) ?></b> <?= $isDone ? '✅ finished' : '⏳ in progress' ?><?= (int)$r['trek_ch'] === (int)$r['chapter'] ? ' · <b>current</b>' : '' ?> · Petals found today <?= (string)$r['trek_pet_day'] === hollow_date('Y-m-d') ? (int)$r['trek_pet_today'] : 0 ?>/<?= (int)setting('trek_petals_daily') ?> (all chapters)<br>
      <?= e((trek_zone_info((int)$r['chapter'], $zone) ?? ['zone ?'])[0]) ?> (<?= (int)$r['x'] ?>,<?= (int)$r['y'] ?>) · fatigue <?= (int)$r['fatigue'] ?> · camp <?= e((string)($r['camp'] ?? 'none')) ?>
      · <?= (int)$r['inside'] ? '<b>inside</b>' : 'outside' ?><?= $r['fight'] ? ' · in a fight' : '' ?></p>
    <?php $rst = json_decode((string)($r['state'] ?? ''), true) ?: []; $tl = array_map(fn($k, $v) => $k . ' ' . (int)($v[0] ?? 1), array_keys((array)($rst['tl'] ?? [])), array_values((array)($rst['tl'] ?? []))); ?>
    <?php if ($tl): ?><p class="help">Trek levels: <?= e(implode(' · ', $tl)) ?> · milestones paid: <?= e(implode(', ', array_keys((array)($rst['ms'] ?? []))) ?: 'none') ?></p><?php endif; ?>
    <p class="help">Started <?= e((string)$r['started']) ?> UTC · <?= $r['finished'] ? 'finished ' . e((string)$r['finished']) : 'not finished' ?></p>
    <form method="post" class="form inline"><?= csrf_field() ?><input type="hidden" name="run" value="<?= (int)$r['id'] ?>">
      <small class="muted">Resetting this chapter lets them earn its rewards again (Chapter I: 400 Petals, chest, items). Milestone XP already paid (v1.8.9) is never paid twice. Resetting a later chapter puts them back in the interlude before it.</small> <label>Type RESET to confirm <input name="confirm" size="8" autocomplete="off"></label>
      <button class="btn small red">Reset run</button></form>
  </div>
<?php endforeach; ?>
<?php page_footer();
