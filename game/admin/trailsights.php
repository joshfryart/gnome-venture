<?php
declare(strict_types=1);
// v2.6.68: Trail Sights editor. Every big set piece on a Trail map can get one thing to do next to it (plan claude/plan-trail-sights.md, ideas claude/sights/ideas-*.md).
// The data file includes/data/trail_sights.txt holds the defaults; a row saved here replaces the file row of that slug (or adds a new one); "Back to the file" removes it; "Off" hides a file row.
require dirname(__DIR__) . '/includes/bootstrap.php';
require_once dirname(__DIR__) . '/includes/admin_helpers.php';
require_once dirname(__DIR__) . '/includes/trail_sights.php';
require_once dirname(__DIR__) . '/includes/tools.php';
require_once dirname(__DIR__) . '/includes/gathering.php';
$me = require_admin();
if (!trail_sights_ensure_tables()) { page_header('Trail sights', true); echo '<p class="flash err">The Sights tables could not be created. Run Admin → Update once, then come back.</p>'; page_footer(); exit; }

$file = trail_sights_file();
$landmarks = [];   // every landmark picture the game has: slug => true
foreach (glob(dirname(__DIR__) . '/assets/img/trail/obj/lm-*.png') ?: [] as $f) $landmarks[substr(basename($f), 3, -4)] = true;

if (is_post()) {
    csrf_check();
    $slug = is_scalar($_POST['slug'] ?? null) ? trim((string)$_POST['slug']) : '';
    $back = 'admin/trailsights.php?edit=' . rawurlencode($slug);
    if (!preg_match('/^[a-z0-9-]{3,80}$/', $slug)) { flash('That is not a landmark name.', 'err'); redirect('admin/trailsights.php'); }
    if (!empty($_POST['restore'])) { q('DELETE FROM trail_sight_rows WHERE slug = ?', [$slug]); admin_log('trail_sight', $slug, 'back to the file row'); flash('↩️ Back to the file row.'); redirect('admin/trailsights.php'); }
    if (!empty($_POST['off'])) {
        q('DELETE FROM trail_sight_rows WHERE slug = ?', [$slug]);
        db_insert('trail_sight_rows', ['slug' => $slug, 'verb' => '-', 'icon' => '-', 'energy' => 0, 'cd' => 0, 'uses' => 1, 'cond' => '-', 'chk' => '-', 'rewards' => '', 'win' => '', 'lose' => '', 'tool' => '-', 'fail_en' => 0, 'active' => 0, 'updated_at' => now()]);
        admin_log('trail_sight', $slug, 'switched off'); flash('Switched off. "Back to the file" turns it on again.'); redirect('admin/trailsights.php');
    }
    $f = fn(string $k, int $max = 400): string => mb_substr(trim(is_scalar($_POST[$k] ?? null) ? (string)$_POST[$k] : ''), 0, $max);
    $row = trail_sight_row([$slug, $f('verb', 24), $f('icon', 16), $f('energy', 2), $f('cd', 4), $f('uses', 2), $f('when', 80), $f('check', 40), $f('rewards', 255), $f('win'), $f('lose'), $f('tool', 20), $f('fail_en', 2)]);
    if (!$row) { flash('Something is missing.', 'err'); redirect($back); }
    $bad = trail_sight_lint($row);
    if ($bad && empty($_POST['force'])) { flash('Not saved: ' . implode('; ', $bad) . '.', 'err'); redirect($back); }
    q('DELETE FROM trail_sight_rows WHERE slug = ?', [$slug]);
    db_insert('trail_sight_rows', ['slug' => $slug, 'verb' => $row['verb'], 'icon' => $row['icon'], 'energy' => $row['energy'], 'cd' => $row['cd'], 'uses' => $row['uses'], 'cond' => $row['when'], 'chk' => $row['check'],
        'rewards' => $row['rewards'], 'win' => $row['win'], 'lose' => $row['lose'], 'tool' => $row['tool'], 'fail_en' => $row['fail_en'], 'active' => 1, 'updated_at' => now()]);
    admin_log('trail_sight', $slug, 'saved'); flash('✅ Saved.'); redirect('admin/trailsights.php');
}

$GLOBALS['gv_sights_reload'] = true;
$all = trail_sights_all();
$off = [];
try { foreach (q('SELECT slug FROM trail_sight_rows WHERE active = 0')->fetchAll() as $r) $off[$r['slug']] = true; } catch (Throwable $e) {}
$edit = is_scalar($_GET['edit'] ?? null) ? (string)$_GET['edit'] : '';
$cur = $edit !== '' ? ($all[$edit] ?? ($file[$edit] ?? ['slug' => $edit, 'verb' => '', 'icon' => '', 'energy' => 1, 'cd' => 55, 'uses' => 1, 'when' => '-', 'check' => '-', 'rewards' => '', 'win' => '', 'lose' => '', 'tool' => '-', 'fail_en' => 0, 'src' => 'new'])) : null;
$problems = 0; foreach ($all as $r) if (trail_sight_lint($r)) $problems++;
page_header('Trail sights', true);
?>
<h1>🔎 Trail sights</h1>
<p class="help">What a gnome can do next to a big set piece on a Trail map. <b><?= count($all) ?></b> Sights, <b><?= count($landmarks) ?></b> landmark pictures, <b><?= $problems ?></b> with problems. Costs: setting <code>time_sight</code> (game minutes) and the energy in the row. Conditions use the rest-stop words (<code>dp=dusk</code>, <code>se=winter</code>, <code>we=rain</code>); check = <code>stat:difficulty</code>; tool = <code>type:tier</code>; rewards = <code>xp=3:1,item=slug:1@20,gather=rod</code>.</p>
<?php if ($cur !== null): ?>
  <h2><?= $edit !== '' ? e($edit) : '' ?></h2>
  <?php if (!isset($landmarks[$edit])): ?><p class="flash err">There is no landmark picture <code>lm-<?= e($edit) ?>.png</code>.</p><?php endif; ?>
  <form method="post" class="form"><?= csrf_field() ?><input type="hidden" name="slug" value="<?= e($edit) ?>">
    <?php foreach ([['verb', 'Verb (the button)', 24], ['icon', 'Icon', 16], ['energy', 'Energy', 2], ['cd', 'Cooldown (tenths of a game day, 55 = 5.5)', 4], ['uses', 'Uses per cooldown', 2], ['when', 'When (- or dp=…/se=…/we=…)', 80], ['check', 'Check (- or stat:difficulty)', 40], ['tool', 'Tool (- or type:tier)', 20], ['fail_en', 'Energy a failed check costs', 2]] as [$k, $lab, $mx]): ?>
      <label><?= e($lab) ?> <input name="<?= e($k) ?>" maxlength="<?= $mx ?>" value="<?= e((string)$cur[$k]) ?>"></label>
    <?php endforeach; ?>
    <label>Rewards <input name="rewards" maxlength="255" value="<?= e((string)$cur['rewards']) ?>" style="width:100%"></label>
    <label>Win line <textarea name="win" rows="3" maxlength="400" style="width:100%"><?= e((string)$cur['win']) ?></textarea></label>
    <label>Lose line (only with a check) <textarea name="lose" rows="2" maxlength="400" style="width:100%"><?= e((string)$cur['lose']) ?></textarea></label>
    <?php $pr = trail_sight_lint($cur); if ($pr): ?><p class="flash err">Problems now: <?= e(implode('; ', $pr)) ?></p><?php endif; ?>
    <button class="btn">💾 Save</button> <a class="btn ghost" href="<?= e(url('admin/trailsights.php')) ?>">Cancel</a>
    <?php if (isset($file[$edit]) || ($cur['src'] ?? '') !== 'new'): ?><button class="btn ghost" name="restore" value="1">↩️ Back to the file</button><button class="btn ghost" name="off" value="1">⏸️ Off</button><?php endif; ?>
  </form>
<?php else: ?>
  <form method="get" class="form"><label>Add a Sight for a landmark <input name="edit" list="lmlist" placeholder="grassland-the-daisy-ring"></label><datalist id="lmlist"><?php foreach (array_keys($landmarks) as $s) if (!isset($all[$s])) echo '<option value="' . e($s) . '">'; ?></datalist> <button class="btn">Add</button></form>
  <table class="tbl"><tr><th>Landmark</th><th></th><th>Does</th><th>⚡</th><th>Where</th><th>Problems</th></tr>
  <?php foreach ($all as $r): $pr = trail_sight_lint($r); ?>
    <tr><td><a href="<?= e(url('admin/trailsights.php?edit=' . rawurlencode($r['slug']))) ?>"><?= e($r['slug']) ?></a></td><td><?= e($r['icon']) ?></td><td><?= e($r['verb']) ?><?= $r['check'] !== '-' ? ' <small>(' . e($r['check']) . ')</small>' : '' ?></td><td><?= (int)$r['energy'] ?></td><td><?= e($r['src']) ?></td><td><?= $pr ? '<span class="flash err">' . e(implode('; ', $pr)) . '</span>' : '✓' ?></td></tr>
  <?php endforeach; ?>
  </table>
  <?php if ($off): ?><p class="help">Switched off: <?php foreach (array_keys($off) as $s) echo '<a href="' . e(url('admin/trailsights.php?edit=' . rawurlencode($s))) . '">' . e($s) . '</a> '; ?></p><?php endif; ?>
  <?php $nr = array_diff(array_keys($landmarks), array_keys($all)); ?>
  <p class="help"><?= count($nr) ?> landmarks have no Sight yet.</p>
<?php endif; ?>
<?php page_footer();
