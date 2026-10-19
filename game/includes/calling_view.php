<?php
declare(strict_types=1);
/** v0.9.4: calling mentor views: the chapter panel (mentor.php), the Today line and the My Gnome line. */
require_once __DIR__ . '/calling_quests.php';
require_once __DIR__ . '/journey.php';      // journey_need_status() for the hand-in chips
require_once __DIR__ . '/friends.php';
require_once __DIR__ . '/npc_life.php';

const CALLING_TIER_LABELS = [2 => 'Journeyman', 3 => 'Master'];

/** Where the mentor is right now, as a short phrase ("at The Root Cellar in Birchbramble Steppe"). */
function calling_mentor_where(array $npc): string
{
    $now = npc_now($npc);
    return (string)$now['what'];
}

/** The reward line of a chapter (XP as it is really paid). */
function calling_reward_text(array $ch): string
{
    $bits = [];
    if ((int)$ch['reward_coins'] > 0) $bits[] = money((int)$ch['reward_coins']);
    $xp = (int)round((int)$ch['reward_xp'] * (int)setting('calling_xp_percent') / 100);
    if ($xp > 0) $bits[] = $xp . ' XP';
    if ($ch['reward_item_slug']) $bits[] = max(1, (int)$ch['reward_qty']) . ' × ' . (q_val('SELECT name FROM items WHERE slug = ?', [$ch['reward_item_slug']]) ?: $ch['reward_item_slug']);
    $bits[] = 'the ' . (CALLING_TIER_LABELS[(int)$ch['tier']] ?? '') . ' tier of your calling';
    if ($ch['reward_title']) $bits[] = 'the title “' . $ch['reward_title'] . '”';
    return implode(', ', $bits);
}

/**
 * One chapter on the mentor's page. $here = the mentor is in the gnome's town right now (buttons work only then).
 */
function calling_chapter_box(array $u, array $ch, array $st, ?array $npc, bool $here): void
{
    $row = $st['row'];
    $tier = CALLING_TIER_LABELS[(int)$ch['tier']] ?? '';
    $field = fn(string $do) => csrf_field() . '<input type="hidden" name="do" value="' . $do . '"><input type="hidden" name="ch" value="' . (int)$ch['id'] . '"><input type="hidden" name="m" value="' . e((string)($npc['slug'] ?? '')) . '">';
    ?>
      <div class="box jdetail" id="chapter-<?= (int)$ch['id'] ?>">
        <h3>📜 <?= e((string)$ch['title']) ?> <small class="muted">· <?= e($tier) ?> chapter</small></h3>
        <?php if ($st['state'] === 'locked'): ?>
          <p class="muted">🔒 <?= e((string)$st['why']) ?></p>
        <?php else: ?>
          <?php if ($st['state'] !== 'done'): ?>
            <div class="jintro"><?php if ($npc): ?><a href="<?= e(url('folk.php?id=' . (int)$npc['id'])) ?>"><?= npc_portrait($npc, 'small') ?></a><?php endif; ?>
              <div class="ptext"><?= format_text((string)$ch['intro']) ?></div></div>
          <?php endif; ?>
          <ol class="jtasks">
            <?php foreach ($st['tasks'] as $tk): $t = $tk['task']; $isGive = $t['mode'] === 'give'; $done = $tk['done']; ?>
              <li class="<?= $done ? 'done' : '' ?><?= $isGive ? ' stage' : '' ?>">
                <span class="jtick"><?= $done ? '✅' : ($isGive ? '📦' : '⬜') ?></span>
                <span class="jlabel"><?= e((string)$t['label']) ?><?php if (!$isGive && !$done && $tk['goal'] > 1): ?> <small class="muted">(<?= (int)$tk['now'] ?>/<?= (int)$tk['goal'] ?>)</small><?php endif; ?></span>
                <?php if ($t['mode'] === 'state' && !$done && $st['state'] !== 'done'): ?><small class="jwhy">💡 Counts what you have done already, even before you took the chapter.</small><?php endif; ?>
                <?php if ($isGive && !$done && $st['state'] === 'active'):
                    $needs = journey_need_status($u, (string)$t['spec']); $ok = !array_filter($needs, fn($x) => $x[2] < $x[1]); ?>
                  <span class="jneeds"><?php foreach ($needs as [$label, $need, $have]): ?><span class="chip <?= $have >= $need ? 'good' : 'bad' ?>"><?= $have >= $need ? '✔' : '✖' ?> <?= e($label) ?>: <?= min($have, $need) ?>/<?= $need ?></span> <?php endforeach; ?></span>
                  <?php if (!$st['work_done']): ?><small class="jwhy">🔒 Finish the tasks above first, then bring this to <?= e((string)($npc['name'] ?? 'your mentor')) ?>.</small>
                  <?php elseif ($here): ?>
                    <form method="post" action="<?= e(url('mentor.php')) ?>" class="inline"><?= $field('hand_in') ?>
                      <button class="btn small"<?= $ok ? '' : ' disabled' ?>><?= $ok ? '✋ Hand in' : 'Hand in (missing something)' ?></button></form>
                  <?php else: ?><small class="jwhy">📍 Hand it in when you are with <?= e((string)($npc['name'] ?? 'your mentor')) ?>.</small><?php endif; ?>
                <?php endif; ?>
              </li>
            <?php endforeach; ?>
          </ol>
          <p class="help">🎁 Reward: <?= e(calling_reward_text($ch)) ?>.</p>
          <?php if ($st['state'] === 'available'): ?>
            <?php if ($here): ?>
              <form method="post" action="<?= e(url('mentor.php')) ?>"><?= $field('start') ?><button class="btn gold">📜 Take on this chapter</button></form>
            <?php else: ?><p class="help">📍 Visit <?= e((string)($npc['name'] ?? 'your mentor')) ?> to take it on.</p><?php endif; ?>
            <p class="help">Tasks like harvests and crafts count from the moment you take the chapter. The ones that look at what you have already done tick at once.</p>
          <?php elseif ($st['state'] === 'active' && $st['complete']): ?>
            <?php if ($here): ?>
              <form method="post" action="<?= e(url('mentor.php')) ?>"><?= $field('finish') ?><button class="btn gold">📜 Finish the chapter</button></form>
            <?php else: ?><p class="help">📍 Everything is done! Go back to <?= e((string)($npc['name'] ?? 'your mentor')) ?> to finish the chapter.</p><?php endif; ?>
          <?php elseif ($st['state'] === 'done'): ?>
            <div class="letter"><?= format_text((string)$ch['outro']) ?></div>
          <?php endif; ?>
        <?php endif; ?>
      </div>
<?php
}

/** A one-line Today note about the calling chapter, or ''. */
function calling_today_line(array $u): string
{
    if (empty($u['calling']) || setting('calling_quests') !== '1' || !isset(CALLINGS[$u['calling']])) return '';
    $mentor = calling_mentor((string)$u['calling']);
    $link = url('mentor.php' . ($mentor ? '?m=' . $mentor['slug'] : ''));
    $open = !empty($u['calling_chapter']) ? calling_chapter((int)$u['calling_chapter']) : null;
    if ($open) {
        $st = calling_status($u, $open);
        $n = count(array_filter($st['tasks'], fn($t) => $t['done']));
        $flag = $st['complete'] ? ' · <b>ready to finish</b>' : ($st['work_done'] && $st['give_next'] ? ' · <b>ready to hand in</b>' : '');
        return '<p class="todayfx"><a href="' . e($link) . '">📜 ' . e((string)$open['title']) . ': ' . $n . ' of ' . count($st['tasks']) . ' done' . $flag . '</a></p>';
    }
    $next = calling_next_chapter($u);
    if ($next && (int)$u['level'] >= calling_level_for_tier((int)$next['tier']) && $mentor) {
        return '<p class="todayfx"><a href="' . e($link) . '">📜 ' . e((string)$mentor['name']) . ' has a ' . e(strtolower(CALLING_TIER_LABELS[(int)$next['tier']] ?? '')) . ' chapter for you: ' . e((string)$next['title']) . '</a></p>';
    }
    return '';
}

/** My Gnome → Calling: tier, chapter progress and where the mentor is. */
function calling_gnome_line(array $u): string
{
    if (empty($u['calling']) || setting('calling_quests') !== '1' || !isset(CALLINGS[$u['calling']])) return '';
    $mentor = calling_mentor((string)$u['calling']);
    $qt = (int)($u['calling_qt'] ?? 0);
    $h = '<div class="callingquest"><p>📜 <b>Mentor:</b> ';
    $h .= $mentor ? '<a href="' . e(url('mentor.php?m=' . $mentor['slug'])) . '">' . e((string)$mentor['name']) . '</a> <small class="muted">' . e(calling_mentor_where($mentor)) . '</small>' : 'none yet';
    $h .= '</p>';
    $open = !empty($u['calling_chapter']) ? calling_chapter((int)$u['calling_chapter']) : null;
    if ($open) {
        $st = calling_status($u, $open);
        $n = count(array_filter($st['tasks'], fn($t) => $t['done']));
        $h .= '<p>Chapter on the go: <b>' . e((string)$open['title']) . '</b> · ' . $n . ' of ' . count($st['tasks']) . ' tasks done'
            . ($st['complete'] ? ' · <b>ready to finish</b>' : '') . '.</p>';
    } elseif ($qt >= 2) {
        $h .= '<p>Both chapters are finished. You are a Master.</p>';
    } else {
        $next = calling_next_chapter($u);
        if ($next) {
            $need = calling_level_for_tier((int)$next['tier']);
            $h .= '<p>Next chapter: <b>' . e((string)$next['title']) . '</b> (' . e(CALLING_TIER_LABELS[(int)$next['tier']] ?? '') . ')'
                . ((int)$u['level'] < $need ? ', from gnome level ' . $need . '.' : ': ready to take on.') . '</p>';
        }
    }
    return $h . '</div>';
}
