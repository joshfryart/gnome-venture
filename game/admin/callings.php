<?php
declare(strict_types=1);
// v0.9.4: calling chapters and their tasks (read-only), with a button that imports new ones from data/calling_quests.txt.
require dirname(__DIR__) . '/includes/bootstrap.php';
require_once dirname(__DIR__) . '/includes/admin_helpers.php';   // v1.6.3
$me = require_admin();
require_once dirname(__DIR__) . '/includes/calling_view.php';

if (is_post()) {
    csrf_check();
    if ((string)($_POST['do'] ?? '') === 'import') {
        $n = ensure_calling_quests();
        admin_log('import', 'calling_quests', (string)$n);
        flash($n > 0 ? 'Imported ' . $n . ' new calling chapter' . ($n === 1 ? '' : 's') . '. (Mentors and lodges checked too.)' : 'Nothing new to import: every chapter in the file is already in the game. (Mentors and lodges checked.)');
    }
    redirect('admin/callings.php');
}

$chapters = q('SELECT c.*, (SELECT COUNT(*) FROM user_calling_chapters uc WHERE uc.chapter_id = c.id AND uc.done_at IS NOT NULL) AS finished,
               (SELECT COUNT(*) FROM user_calling_chapters uc WHERE uc.chapter_id = c.id AND uc.done_at IS NULL) AS open
               FROM calling_chapters c ORDER BY c.calling, c.tier, c.id')->fetchAll();
page_header('Calling chapters', true);
?>
<?php admin_crumbs('callings.php');   // v1.6.3 ?>
<h1>📜 Calling chapters</h1>
<p class="help">Read-only. The chapters come from <code>includes/data/calling_quests.txt</code> and are imported once; ones already in the game are never overwritten. Mentors: <?= count(CALLING_MENTORS) ?> (<?= (int)q_val('SELECT COUNT(*) FROM npcs WHERE slug IN (' . implode(',', array_map(fn($m) => db()->quote($m[1]), CALLING_MENTORS)) . ')') ?> in the game).</p>
<form method="post"><?= csrf_field() ?><input type="hidden" name="do" value="import"><button class="btn">Import calling quests</button></form>
<?php foreach ($chapters as $c): $tasks = calling_tasks((int)$c['id'], true); ?>
  <div class="box">
    <h3><?= e((string)$c['title']) ?> <small class="muted"><?= e((CALLINGS[$c['calling']][0] ?? $c['calling']) . ' · ' . (CALLING_TIER_LABELS[(int)$c['tier']] ?? 'tier ' . $c['tier'])) ?> · <code><?= e((string)$c['slug']) ?></code></small></h3>
    <p class="help">Mentor <code><?= e((string)$c['mentor_slug']) ?></code> · reward <?= e(calling_reward_text($c)) ?> · <?= (int)$c['finished'] ?> finished, <?= (int)$c['open'] ?> in progress<?= (int)$c['active'] ? '' : ' · <b>inactive</b>' ?></p>
    <table class="grid">
      <tr><th>#</th><th>Mode</th><th>Kind</th><th>Spec</th><th>Qty</th><th>Label</th></tr>
      <?php foreach ($tasks as $t): ?>
        <tr><td><?= (int)$t['sort_order'] ?></td><td><?= e((string)$t['mode']) ?></td><td><?= e((string)$t['kind']) ?></td><td><code><?= e((string)$t['spec']) ?></code></td><td><?= (int)$t['qty'] ?></td><td><?= e((string)$t['label']) ?></td></tr>
      <?php endforeach; ?>
    </table>
  </div>
<?php endforeach; ?>
<?php if (!$chapters): ?><p>No chapters yet. Press the import button.</p><?php endif; ?>
<?php page_footer();
