<?php
declare(strict_types=1);
/** v0.7.65: the Almanac's Journey tab. Expects $u. Buttons post to journey.php. */
require_once __DIR__ . '/journey.php';
require_once __DIR__ . '/friends.php';
require_once __DIR__ . '/npc_life.php';
require_once __DIR__ . '/garden_logic.php';   // nice_time()

function journey_view(array $u): void
{
    $uid = (int)$u['id'];
    $chapters = journey_chapters();
    $states = [];
    foreach ($chapters as $ch) $states[(int)$ch['id']] = journey_status($u, $ch);
    $doneN = count(array_filter($states, fn($s) => $s['row'] && $s['row']['done_at']));
    $sel = (int)($_GET['j'] ?? 0);
    if (!$sel) foreach ($chapters as $ch) if (($r = $states[(int)$ch['id']]['row']) && !$r['done_at']) { $sel = (int)$ch['id']; break; }
    if (!$sel && $chapters) $sel = (int)$chapters[0]['id'];
    $u = q_one('SELECT * FROM users WHERE id = ?', [$uid]);
    ?>
  <div class="bookwide journey">
    <h2>🧭 Wren’s Journey <small><?= $doneN ?> of <?= count($chapters) ?> chapters</small></h2>
    <details class="helpfold"<?= $doneN ? '' : ' open' ?>><summary>📜 The story so far</summary><div class="ptext"><?= format_text(JOURNEY_PROLOGUE) ?></div>
      <p class="help">Each region has its own chapter. It starts the first time you reach the region: get to know the place, then help build its project.
        Finishing a chapter gives you the region’s gardening guide (studied at once), rewards, and a lasting benefit there.</p></details>
    <?php $ready = [];
    foreach ($chapters as $ch) if ($r = journey_ready($u, $states[(int)$ch['id']])) $ready[] = [$ch, $r];
    if ($ready): ?>
      <div class="box notice jready">✋ <b>Ready to turn in:</b>
        <?php foreach ($ready as [$ch, $r]): ?><a class="chip" href="<?= e(url('book.php?ch=Journey&j=' . (int)$ch['id'])) ?>"><?= e((string)$ch['project_icon']) ?> <?= e($ch['region']) ?>: <?= $r === 'finish' ? 'finish the chapter' : 'hand in the next stage' ?></a> <?php endforeach; ?>
      </div>
    <?php endif; ?>
    <div class="jchapters">
      <?php foreach ($chapters as $ch): $st = $states[(int)$ch['id']]; $row = $st['row'];
          $n = count(array_filter($st['tasks'], fn($t) => $t[3])); $m = count($st['tasks']);
          $state = !$row ? 'locked' : ($row['done_at'] ? 'done' : 'open'); ?>
        <a class="jcard <?= $state ?><?= (int)$ch['id'] === $sel ? ' sel' : '' ?>" href="<?= e(url('book.php?ch=Journey&j=' . (int)$ch['id'])) ?>">
          <span class="jicon"><?= $state === 'locked' ? '🔒' : e((string)$ch['project_icon']) ?></span>
          <b><?= e($ch['region']) ?></b>
          <small><?= $state === 'done' ? '✔ ' . e($ch['title']) : ($state === 'open' ? e($ch['title']) . ' · ' . $n . '/' . $m : 'Level ' . (int)$ch['min_level'] . ' · reach it to start') ?></small>
        </a>
      <?php endforeach; ?>
    </div>

    <?php foreach ($chapters as $ch) if ((int)$ch['id'] === $sel) journey_chapter_box($u, $ch, $states[(int)$ch['id']]); ?>
  </div>
<?php
}


/** One chapter: intro, tasks with hand-ins, rewards, finish button or Wren's letter. $back = page to return to after a button (v0.7.66). */
function journey_chapter_box(array $u, array $ch, array $st, string $back = ''): void
{
    $row = $st['row'];
    $npc = $ch['npc_slug'] ? q_one('SELECT * FROM npcs WHERE slug = ?', [$ch['npc_slug']]) : null;
    ?>
      <div class="box jdetail">
        <h3><?= e((string)$ch['project_icon']) ?> <?= e($ch['region']) ?>: <?= e($ch['title']) ?></h3>
        <?php if ($row && !$row['done_at'] && ($hint = journey_next_hint($u, $ch, $st))): ?>
          <p class="jnext">👉 <b>Next:</b> <?= e($hint[0]) ?></p>
        <?php endif; ?>
        <?php if (!$row): ?>
          <p class="muted">🔒 This chapter starts when you first reach <?= e($ch['region']) ?> (recommended gnome level <?= (int)$ch['min_level'] ?>). Walk the roads there from a neighbouring region.</p>
        <?php else: ?>
          <div class="jintro"><?php if ($npc): ?><a href="<?= e(url('folk.php?id=' . (int)$npc['id'])) ?>"><?= npc_portrait($npc, 'small') ?></a><?php endif; ?>
            <div class="ptext"><?= format_text((string)$ch['intro']) ?></div></div>
          <?php if (!$row['done_at'] && trim((string)($ch['locks'] ?? '')) !== ''):   // v0.7.66: what stays closed until it's done
              $names = [];
              foreach (array_filter(array_map('trim', explode(',', (string)$ch['locks']))) as $l) {
                  [$lt, $ls] = explode(':', $l, 2) + [1 => ''];
                  $nm = $lt === 'spot' ? q_val('SELECT name FROM town_spots WHERE slug = ?', [$ls]) : q_val('SELECT name FROM locations WHERE slug = ?', [$ls]);
                  if ($nm) $names[] = ($lt === 'spot' ? 'the ' . preg_replace('/^The /', '', $nm) . ' in the town square' : $nm . ' (off the road)');
              }
              if ($names): ?><p class="help">🚧 Closed until this chapter is finished: <?= e(implode(', ', array_unique($names))) ?>.</p><?php endif; ?>
          <?php endif; ?>
          <ol class="jtasks">
            <?php $stageNo = 0; foreach ($st['tasks'] as [$t, $now, $goal, $done]):
                $isStage = $t['kind'] === 'stage'; if ($isStage) $stageNo++;
                $isNext = $isStage && $st['next_stage'] && (int)$st['next_stage']['id'] === (int)$t['id']; ?>
              <li class="<?= $done ? 'done' : '' ?><?= $isStage ? ' stage' : '' ?>">
                <span class="jtick"><?= $done ? '✅' : ($isStage ? '🧱' : '⬜') ?></span>
                <span class="jlabel"><?= e((string)$t['label']) ?><?php if (!$isStage && !$done && $goal > 1): ?> <small class="muted">(<?= $now ?>/<?= $goal ?>)</small><?php endif; ?></span>
                <?php if (!$isStage && !$done): $how = [   // v0.7.70: how to do it
                    'visit' => 'Walk the roads there from a neighbouring region.',
                    'grow' => 'Plant them in any garden and harvest them. Their seeds are sold at this region’s market.',
                    'friend' => 'Chat with them once a day and give them gifts (their page has the buttons). The first level takes a day or two. Townsfolk hang about the town square: try 👥 Villagers.',
                    'find' => 'Stand at a road stop in this region and choose 🌿 Wander off the path. Hidden places turn up as you explore.',
                ][$t['kind']] ?? ''; if ($how): ?><small class="jwhy">💡 <?= e($how) ?></small><?php endif; endif; ?>
                <?php if ($isStage && !$done && !$row['done_at']):   // v0.7.70: every stage shows what it needs and what you have, and why it can't be handed in yet
                    $needs = journey_need_status($u, (string)$t['spec']); $ok = !array_filter($needs, fn($x) => $x[2] < $x[1]);
                    $left = array_values(array_filter($st['tasks'], fn($x) => $x[0]['kind'] !== 'stage' && !$x[3])); ?>
                  <span class="jneeds"><?php foreach ($needs as [$label, $need, $have]): ?><span class="chip <?= $have >= $need ? 'good' : 'bad' ?>"><?= $have >= $need ? '✔' : '✖' ?> <?= e($label) ?>: <?= min($have, $need) ?>/<?= $need ?></span> <?php endforeach; ?></span>
                  <?php if (!$st['explore_done']): ?>
                    <small class="jwhy">🔒 First finish the task<?= count($left) === 1 ? '' : 's' ?> above: <?= e(implode(' · ', array_map(fn($x) => preg_replace('/\s*\(.*\)$/', '', (string)$x[0]['label']) . ($x[2] > 1 ? ' (' . $x[1] . '/' . $x[2] . ')' : ''), $left))) ?>. Then you can hand stages in, one at a time.</small>
                  <?php elseif (!$isNext): ?>
                    <small class="jwhy">⏳ Hand in the stage above first. You can gather these now.</small>
                  <?php else: ?>
                    <form method="post" action="<?= e(url('journey.php')) ?>" class="inline"><?= csrf_field() ?><input type="hidden" name="do" value="hand_in"><input type="hidden" name="ch" value="<?= (int)$ch['id'] ?>"><input type="hidden" name="back" value="<?= e($back) ?>">
                      <button class="btn small"<?= $ok ? '' : ' disabled' ?>><?= $ok ? '✋ Hand in' : 'Hand in (missing something)' ?></button></form>
                  <?php endif; ?>
                <?php endif; ?>
              </li>
            <?php endforeach; ?>
          </ol>
          <p class="help">🎁 Reward: <?= money((int)$ch['reward_coins']) ?>, <?php /* v0.9.1: the paid XP, not the listed XP */ ?><?= (int)round((int)$ch['reward_xp'] * (int)setting('journey_xp_percent') / 100) ?> XP<?= $ch['reward_item_slug'] ? ', ' . (int)$ch['reward_qty'] . ' × ' . e((string)q_val('SELECT name FROM items WHERE slug = ?', [$ch['reward_item_slug']])) : '' ?>,
            📗 <?= e($ch['region']) ?> studied<?= $ch['reward_title'] ? ', the title “' . e($ch['reward_title']) . '”' : '' ?>.
            <br><?= e((string)$ch['project_icon']) ?> <b>Lasting benefit:</b> <?= e((string)$ch['benefit_text']) ?></p>
          <p class="help">🧱 How it works: finish the ⬜ tasks first, then hand in the 🧱 project stages in order with the ✋ Hand in button (here or on the town square’s 📜 Quests tab). Dressed Stone, Timber Planks and Rope are made in Satchel → Crafting → Building from things you gather. Home-cooked meals need a Kitchen.</p>
          <?php if (!$row['done_at'] && $st['complete']): ?>
            <form method="post" action="<?= e(url('journey.php')) ?>"><?= csrf_field() ?><input type="hidden" name="do" value="finish"><input type="hidden" name="ch" value="<?= (int)$ch['id'] ?>"><input type="hidden" name="back" value="<?= e($back) ?>">
              <button class="btn gold">📜 Finish the chapter</button></form>
          <?php elseif ($row['done_at']): ?>
            <div class="letter"><?= format_text((string)$ch['outro']) ?></div>
            <?php if ($ch['benefit'] === 'weekly_crate'):
                $next = $row['crate_at'] ? ts($row['crate_at']) + 7 * 86400 : 0; $end = journey_crates_end($row); ?>
              <?php if ($end <= time()): ?><p class="muted">📦 The supply crates have stopped coming. Thank you for everything you built.</p>
              <?php elseif ($next >= $end): ?><p class="muted">📦 That was the last supply crate. Thank you for everything you built.</p>
              <?php elseif ($next > time()): ?><p class="muted">📦 The next supply crate arrives in <?= e(nice_time($next - time())) ?>.</p>
              <?php else: ?><form method="post" action="<?= e(url('journey.php')) ?>"><?= csrf_field() ?><input type="hidden" name="do" value="crate"><input type="hidden" name="ch" value="<?= (int)$ch['id'] ?>"><input type="hidden" name="back" value="<?= e($back) ?>">
                <button class="btn">📦 Collect this week’s supply crate</button></form><?php endif; ?>
              <?php if ($end > time() && $end < PHP_INT_MAX && $next < $end): ?><p class="help">Crates keep coming for <?= e(nice_time($end - time())) ?> more.</p><?php endif; ?>
            <?php endif; ?>
          <?php endif; ?>
        <?php endif; ?>
      </div>
<?php
}
