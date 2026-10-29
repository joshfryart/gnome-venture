<?php
declare(strict_types=1);
// v0.9.4: a calling mentor's lodge. Talk to them, take on a chapter, hand in what they ask for, finish it.
require __DIR__ . '/includes/bootstrap.php';
require_once __DIR__ . '/includes/garden_logic.php';
require_once __DIR__ . '/includes/calling_view.php';
$u = require_login();
$uid = (int)$u['id'];

// Which mentor: ?m=slug, or the one for this gnome's calling
$slug = (string)($_POST['m'] ?? $_GET['m'] ?? '');
$calling = '';
foreach (CALLING_MENTORS as $key => $m) {
    if ($m[1] === $slug || ($slug === '' && $key === ($u['calling'] ?? ''))) { $calling = $key; $slug = $m[1]; break; }
}
$npc = $calling !== '' ? calling_mentor($calling) : null;
if (!$npc) {
    flash($slug === '' ? 'Choose a calling first (My Gnome → Calling) and your mentor will be waiting.' : 'Nobody by that name teaches here.', 'err');
    redirect($slug === '' ? 'gnome.php?tab=calling' : 'world.php');
}
$nid = (int)$npc['id'];

if (is_post()) {
    csrf_check();
    $ch = (int)($_POST['ch'] ?? 0);
    $do = (string)($_POST['do'] ?? '');
    $chRow = $ch ? calling_chapter($ch) : null;
    if ($do !== 'talk' && (!$chRow || $chRow['calling'] !== $calling || ($u['calling'] ?? '') !== $calling)) {
        [$ok, $msg] = [false, $npc['name'] . ' only teaches their own calling’s chapters, and only to gnomes of that calling.'];
    } elseif (!npc_here($u, $nid)) {
        [$ok, $msg] = [false, $npc['name'] . ' isn’t here. Walk to ' . (calling_mentor_where($npc)) . '.'];
    } else {
        [$ok, $msg] = match ($do) {
            'talk' => npc_talk($u, $nid),
            'start' => calling_start($u, $ch),
            'hand_in' => calling_hand_in($u, $ch),
            'finish' => calling_finish($u, $ch),
            default => [false, 'Unknown action.'],
        };
    }
    if ($msg !== '') flash($msg, $ok ? 'ok' : 'err');
    redirect('mentor.php?m=' . urlencode($slug) . ($ch ? '#chapter-' . $ch : ''));
}

$u = q_one('SELECT * FROM users WHERE id = ?', [$uid]);
$here = npc_here($u, $nid);
if ($here) { require_once __DIR__ . '/includes/folk_list.php'; npc_meet($uid, [$nid]); }
$f = friendship($uid, $nid);
$lvl = friend_level((int)$f['points']);
$today = hollow_date('Y-m-d');
$mine = ($u['calling'] ?? '') === $calling;
$chapters = calling_chapters_for($calling);
$name = CALLINGS[$calling][0] ?? $calling;
page_header($npc['name']);
?>
<p class="crumbs">📜 <a href="<?= e(url('gnome.php?tab=calling')) ?>">My calling</a> › Calling mentor › <b><?= e($npc['name']) ?></b></p>
<div class="box npchead">
  <div class="jintro"><a href="<?= e(url('folk.php?id=' . $nid)) ?>"><?= npc_portrait($npc, 'small') ?></a>
    <div>
      <h1><?= npc_icon($npc['species']) ?> <?= e($npc['name']) ?></h1>
      <p class="muted"><?= e(strtolower(trim((string)$npc['personality'] . ' ' . (string)$npc['species']))) ?> · calling mentor of the <?= e($name) ?>s</p>
      <p><?= e((string)$npc['bio']) ?></p>
      <p class="help">📍 <?= e(calling_mentor_where($npc)) ?><?= $here ? ' · <b class="good">here now</b>' : '' ?> · 💛 <?= e($lvl['name'] ?? 'Stranger') ?></p>
      <?php if ($here): ?>
        <?php if ($f['last_talk'] === $today): ?><p class="help">You have already chatted today.</p>
        <?php else: ?><form method="post" class="inline"><?= csrf_field() ?><input type="hidden" name="do" value="talk"><input type="hidden" name="m" value="<?= e($slug) ?>"><button class="btn small">💬 Talk</button></form><?php endif; ?>
      <?php else: ?><p class="help">You need to be in their town to talk or hand things in.</p><?php endif; ?>
    </div>
  </div>
</div>

<?php if (!$mine): ?>
  <div class="box notice"><p><?= e($npc['name']) ?> only teaches the <b><?= e($name) ?></b> calling.<?= !empty($u['calling']) ? ' Yours is ' . e(CALLINGS[$u['calling']][0] ?? '') . '.' : ' You have not chosen a calling yet (My Gnome → Calling).' ?></p></div>
<?php elseif (setting('calling_quests') !== '1'): ?>
  <div class="box notice"><p>Calling chapters are switched off for now.</p></div>
<?php else: ?>
  <?php
  $nextTier = 2 + (int)($u['calling_qt'] ?? 0);
  $past = [];
  foreach ($chapters as $ch) {
      $st = calling_status($u, $ch);
      if ($st['state'] === 'done' || (int)$ch['tier'] < $nextTier) { $past[] = [$ch, $st]; continue; }
      calling_chapter_box($u, $ch, $st, $npc, $here);
  }
  if ($past): ?>
    <details class="fold box"><summary>✔ Finished chapters (<?= count($past) ?>)</summary>
      <?php foreach ($past as [$ch, $st]) calling_chapter_box($u, $ch, $st, $npc, $here); ?>
    </details>
  <?php endif; ?>
  <p class="help">Journeyman needs gnome level <?= calling_level_for_tier(2) ?> and this mentor's first chapter. Master needs level <?= calling_level_for_tier(3) ?> and the second. You keep each tier's perks once you have earned them.</p>
<?php endif; ?>
<?php page_footer();
