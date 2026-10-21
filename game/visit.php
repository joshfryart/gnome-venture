<?php
declare(strict_types=1);
/** Visit another gnome's garden: look only (v0.7.35). */
require __DIR__ . '/includes/bootstrap.php';
require_once __DIR__ . '/includes/garden_logic.php';
require_once __DIR__ . '/includes/yard.php';
require_once __DIR__ . '/includes/catalog.php';
require_once __DIR__ . '/includes/pals.php';   // v1.0.0: guestbook stamps
require_once __DIR__ . '/includes/social169.php';   // v1.6.9: friend watering, guestbook counts
$u = require_login();
$plotId = (int)($_GET['g'] ?? $_POST['g'] ?? 0);
$plot = q_one('SELECT * FROM plots WHERE id = ?', [$plotId]);
if (!$plot || !garden_visible($plot, $u)) {
    http_response_code(404);
    page_header('Garden not found');
    echo '<h1>Garden not found</h1><p class="muted">That garden doesn’t exist, or its gardener keeps it private.</p>';
    page_footer();
    exit;
}
if (is_post()) {
    csrf_check();
    $do = (string)($_POST['do'] ?? '');
    if ($do === 'admire') {
        [$ok, $msg] = admire_garden($u, $plotId);
        flash($msg, $ok ? 'ok' : 'err');
    } elseif ($do === 'turn_compost') {   // v0.7.99
        [$ok, $msg] = turn_compost($u, $plotId);
        flash($msg, $ok ? 'ok' : 'err');
        redirect('visit.php?g=' . $plotId . '&bld=compost_bin#bldpeek');
    } elseif ($do === 'vote') {
        [$ok, $msg] = gotm_vote($u, (int)($_POST['entry'] ?? 0));
        flash($msg, $ok ? 'ok' : 'err');
    } elseif ($do === 'stamp') {   // v1.0.0: one guestbook stamp per garden per day
        [$ok, $msg] = pal_stamp($u, $plotId, (string)($_POST['stamp'] ?? ''));
        flash($msg, $ok ? 'ok' : 'err');
    } elseif ($do === 'water_friend') {   // v1.6.9
        [$ok, $msg] = social169_water($u, $plotId);
        flash($msg, $ok ? 'ok' : 'err');
    } elseif ($do === 'stamp_clear') {
        [$ok, $msg] = pal_stamp_remove($u, (int)($_POST['stamp_id'] ?? 0));
        flash($msg, $ok ? 'ok' : 'err');
    }
    redirect('visit.php?g=' . $plotId);
}
$owner = q_one('SELECT * FROM users WHERE id = ?', [$plot['user_id']]);
$mine = (int)$owner['id'] === (int)$u['id'];
[$plot, $tiles, $plants] = load_plot((int)$owner['id'], true, $plotId);   // brings growth up to date (and the yard)
$objs = yard_objects($plotId);
$appeal = yard_appeal($plotId, $objs);
$region = q_one('SELECT r.gnomish_name, l.name AS village FROM plots p LEFT JOIN regions r ON r.id = p.region_id LEFT JOIN locations l ON l.id = p.village_id WHERE p.id = ?', [$plotId]);
$entry = gotm_entry($plotId);
$admiredToday = (bool)q_val('SELECT 1 FROM garden_admires WHERE plot_id = ? AND user_id = ? LIMIT 1', [$plotId, $u['id']]);   // v0.9.0: once per garden
$growing = [];
foreach ($tiles as $row) foreach ($row as $t) if ($t['plant_id'] && isset($plants[(int)$t['plant_id']])) {
    $n = $plants[(int)$t['plant_id']]['name'];
    $growing[$n] = ($growing[$n] ?? 0) + 1;
}
arsort($growing);
page_header($plot['garden_name'] ?: 'A garden');
?>
<h1>🏡 <?= eu($plot['garden_name'] ?: gnome_name($owner) . '’s Garden') ?> <?= report_link((int)$owner['id'], 'garden', $plotId) ?></h1>
<p class="help">Tended by <?= profile_link($owner) ?><?= $region && $region['gnomish_name'] ? ' · ' . e(($region['village'] ? $region['village'] . ', ' : '') . $region['gnomish_name']) : '' ?>
  · garden level <?= (int)$plot['garden_level'] ?> · <?= (int)q_val('SELECT COUNT(*) FROM plot_tiles WHERE plot_id = ?', [$plot['id']]) ?> beds
  <?= $mine ? ' · <b>This is how visitors see your garden.</b> <a href="' . e(url('garden.php')) . '">Back to tending</a>' : '' ?></p>

<div class="gardenwrap">
  <div>
    <div class="yardwrap"><?= render_yard($plot, $tiles, $plants, $objs, 'visit') ?></div>
    <p class="yardbar">
      <span>🌼 Curb appeal <b><?= $appeal ?></b> (<?= e(appeal_word($appeal)) ?>)</span>
      <?= social169_garden_counts($plotId) ?>
      <span>💐 Admired <?= (int)$plot['admired'] ?> time<?= (int)$plot['admired'] === 1 ? '' : 's' ?></span>
      <?php if (!$mine): ?><span class="muted">🚩 Something wrong with this garden’s design? <?= report_link((int)$owner['id'], 'yard', $plotId) ?></span><?php endif; ?>
    </p>
  </div>
  <div class="panel box">
    <?php if (($bk = (string)($_GET['bld'] ?? '')) !== '' && ($peek = building_peek($plot, $bk))):   // v0.7.99: a building you tapped ?>
      <div class="bldpeek" id="bldpeek"><h3><?= e($peek[0]) ?></h3>
        <?php foreach ($peek[1] as $line): ?><p><?= e($line) ?></p><?php endforeach; ?>
        <?php if ($bk === 'compost_bin' && !$mine):
            $turned = (bool)q_val('SELECT 1 FROM compost_turns WHERE user_id = ? AND plot_id = ? AND day = ?', [$u['id'], $plotId, hollow_date('Y-m-d')]); ?>
          <?php if ($turned): ?><p class="good">🧑‍🌾 You turned this compost today.</p>
          <?php else: ?><form method="post"><?= csrf_field() ?><input type="hidden" name="g" value="<?= $plotId ?>"><input type="hidden" name="do" value="turn_compost">
            <button class="btn small">🧑‍🌾 Turn the compost (+1 scrap for them, +3 XP for you)</button></form><?php endif; ?>
        <?php endif; ?>
      </div>
    <?php endif; ?>
    <?php if (!$mine): ?>
      <?php if ($admiredToday): ?><p class="good">🌼 You’ve admired this garden.</p>
      <?php else: ?>
        <form method="post"><?= csrf_field() ?><input type="hidden" name="g" value="<?= $plotId ?>"><input type="hidden" name="do" value="admire">
          <button class="btn">🌼 Admire this garden</button></form>
      <?php endif; ?>
    <?php endif; ?>
    <?php if ($entry): ?>
      <p>🏆 Entered in <a href="<?= e(url('gotm.php')) ?>">Garden of the Month</a> with <?= (int)$entry['votes'] ?> vote<?= (int)$entry['votes'] === 1 ? '' : 's' ?>.</p>
      <?php if (!$mine):
          $voted = (bool)q_val('SELECT 1 FROM gotm_votes WHERE entry_id = ? AND user_id = ?', [$entry['id'], $u['id']]);
          $block = gotm_vote_block($u); ?>
        <?php if ($voted): ?><p class="good">🗳️ You voted for this garden.</p>
        <?php elseif ($block): ?><p class="help"><?= e($block) ?></p>
        <?php elseif (gotm_votes_left($u) > 0): ?>
          <form method="post"><?= csrf_field() ?><input type="hidden" name="g" value="<?= $plotId ?>"><input type="hidden" name="do" value="vote"><input type="hidden" name="entry" value="<?= (int)$entry['id'] ?>">
            <button class="btn small">🗳️ Vote for it (<?= gotm_votes_left($u) ?> left)</button></form>
        <?php else: ?><p class="help">You’ve used all your votes this month.</p><?php endif; ?>
      <?php endif; ?>
    <?php endif; ?>
    <?= social169_water_html($u, $plot, $owner, $tiles, $plants) ?>
    <h3>📖 Guestbook</h3>
    <?php $stampedToday = !$mine ? pal_stamped_today((int)$u['id'], $plotId) : null; $stampSet = pal_stamp_set();
    if (!$mine && !pal_blocked((int)$u['id'], (int)$owner['id'])): ?>
      <?php if ($stampedToday): ?><p class="good"><?= e($stampSet[$stampedToday][0] ?? '🌼') ?> You signed the guestbook today. Come back tomorrow!</p>
      <?php else: ?><form method="post" class="stampform"><?= csrf_field() ?><input type="hidden" name="g" value="<?= $plotId ?>"><input type="hidden" name="do" value="stamp">
        <p class="help">Sign the guestbook (one a day):</p><div class="stampbtns"><?php foreach ($stampSet as $sk => [$sic, $snm]): ?><button name="stamp" value="<?= e($sk) ?>" title="<?= e($snm) ?>" aria-label="Sign with <?= e($snm) ?>"><?= $sic ?></button><?php endforeach; ?></div></form><?php endif; ?>
    <?php endif; ?>
    <?= pal_gate_html($plotId, $u, $mine) ?>
    <h3>Growing here</h3>
    <?php require_once __DIR__ . '/includes/breeding110.php'; echo breeding110_visit_note($u, $plotId); /* v1.2.3 */ ?>
    <?php if (!$growing): ?><p class="muted">Nothing just now.</p>
    <?php else: ?><p><?= implode(' · ', array_map(fn($n, $c) => e($n) . ($c > 1 ? ' ×' . $c : ''), array_keys($growing), $growing)) ?></p><?php endif; ?>
    <?php $deco = array_count_values(array_map(fn($o) => trim($o['icon'] . ' ' . $o['name']), array_filter($objs, fn($o) => (int)$o['x'] >= 0))); ?>
    <?php if ($deco): ?><h3>In the yard</h3>
      <p><?= implode(' · ', array_map(fn($n, $c) => e($n) . ($c > 1 ? ' ×' . $c : ''), array_keys($deco), $deco)) ?></p><?php endif; ?>
    <p class="help">You can look but not touch. To help in someone’s garden, take a tending job on the <a href="<?= e(url('jobs.php')) ?>">Job Board</a>.</p>
  </div>
</div>
<?php page_footer();
