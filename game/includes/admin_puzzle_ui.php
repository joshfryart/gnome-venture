<?php
declare(strict_types=1);
/**
 * v2.0.87: the tournament markup and the void handler that admin/puzzles.php (GIFsaw) and admin/jigsaw.php (Jigsaw) share: tournament list, form shell,
 * live leaderboard and recent runs. Moved here from admin/puzzles.php unchanged (GIFsaw output must stay identical; tests/puzzles_tourney.sh covers it).
 * Needs includes/puzzles.php and bootstrap (e(), eu(), csrf_field()).
 */

/**
 * The tournament list table. $page is the admin page ('admin/puzzles.php'); $still adds a Tier column and shows pieces from the tier.
 * @param array $all rows from puzzle_tournaments t JOIN puzzle_pics p (with pic_title and players)
 */
function admin_puzzle_ui_tour_list(array $all, int $tid, string $page, bool $still = false): void
{ ?>
<table class="grid">
  <tr><th>Tournament</th><th>Picture</th><th><?= $still ? 'Tier' : 'Pieces' ?></th><th>When (Hollow time)</th><th>Status</th><th>Players</th></tr>
  <?php foreach ($all as $r): ?>
  <tr<?= (int)$r['id'] === $tid ? ' class="on"' : '' ?>><td><a href="<?= e(url($page . '?tab=tournaments&id=' . (int)$r['id'])) ?>"><?= e($r['title']) ?></a><?= $still && (int)($r['cup_id'] ?? 0) ? ' <small class="muted">cup ' . (int)$r['cup_id'] . '</small>' : '' ?></td><td><?= e($r['pic_title']) ?></td>
    <td><?php if ($still): $tt = JIGSAW_TIERS[(string)$r['tier']] ?? null; ?><?= $tt ? $tt[4] . ' ' . e($tt[0]) . ' · ' . ($tt[1] * $tt[2]) : '–' ?><?php else: ?><?= (int)$r['pieces'] ?><?php endif; ?></td>
    <td><small><?= e(puzzle_local($r['starts_at'])) ?> to <?= e(puzzle_local($r['ends_at'])) ?></small></td><td><?= e($r['status']) ?> <small class="muted">(<?= e(puzzle_tourney_phase($r)) ?>)</small></td><td><?= (int)$r['players'] ?></td></tr>
  <?php endforeach; ?>
</table>
<?php if (!$all): ?><p>No tournaments yet.</p><?php endif; ?>
<p><a class="btn small" href="<?= e(url($page . '?tab=tournaments')) ?>">＋ New tournament</a></p>
<?php }

/**
 * The create / edit box. $fieldsAfterPic = the page's own field(s) (piece count select, or the tier radio) printed between Picture and Starts;
 * $hidden = hidden inputs (do, id); $buttons = the submit button(s); $help = the paragraph under the form. $picNote(pic row) = text after a picture's title.
 * @param array $pics picture rows for the Picture select
 */
function admin_puzzle_ui_tour_form(array $f, ?array $cur, array $pics, string $fieldsAfterPic, string $hidden, string $buttons, string $help, ?callable $picNote = null): void
{
    $local = fn(?string $utc) => $utc ? puzzle_local($utc, 'Y-m-d\TH:i') : '';
    $picNote ??= fn(array $p) => (int)$p['active'] ? '' : ' (off in the library)'; ?>
<div class="box">
  <h2><?= $cur ? 'Edit: ' . e($cur['title']) : 'New tournament' ?></h2>
  <?php if ($cur && $cur['status'] === 'settled'): ?><p class="help">Settled <?= e(puzzle_local((string)$cur['settled_at'])) ?>. Places and badges have been given out.</p>
  <?php else: ?>
  <form method="post" class="stack"><?= csrf_field() ?><?= $hidden ?>
    <label>Title <input type="text" name="title" maxlength="80" value="<?= e($f['title']) ?>" required></label>
    <label>Picture <select name="pic_id"><?php foreach ($pics as $p): ?><option value="<?= (int)$p['id'] ?>"<?= (int)$p['id'] === (int)$f['pic_id'] ? ' selected' : '' ?>><?= e($p['title']) ?><?= e($picNote($p)) ?></option><?php endforeach; ?></select></label>
    <?= $fieldsAfterPic ?>
    <label>Starts (Hollow time) <input type="datetime-local" name="starts_at" value="<?= e($local($f['starts_at'])) ?>" required></label>
    <label>Ends (Hollow time) <input type="datetime-local" name="ends_at" value="<?= e($local($f['ends_at'])) ?>" required></label>
    <label>Status <select name="status"><option value="draft"<?= $f['status'] === 'draft' ? ' selected' : '' ?>>Draft (hidden)</option><option value="live"<?= $f['status'] === 'live' ? ' selected' : '' ?>>Live</option></select></label>
    <?= $help ?>
    <?= $buttons ?>
  </form>
  <?php endif; ?>
</div>
<?php }

/** The live leaderboard (with the under-a-third-of-the-median flag) and the recent runs (with Void + reason) of tournament $cur. */
function admin_puzzle_ui_detail(array $cur): void
{
    $tid = (int)$cur['id'];
    $board = puzzle_board($tid, 100);
    $flags = puzzle_flags($tid);
    $runs = q('SELECT a.*, COALESCE(u.gnome_name, u.username) AS name FROM puzzle_attempts a JOIN users u ON u.id = a.user_id WHERE a.tournament_id = ? ORDER BY a.id DESC LIMIT 60', [$tid])->fetchAll(); ?>
<div class="box">
  <h2>Leaderboard</h2>
  <?php if ($board): ?>
  <table class="grid"><tr><th>#</th><th>Gnome</th><th>Best</th><th>Finished goes</th><th></th></tr>
    <?php foreach ($board as $k => $r): ?><tr><td><?= $k + 1 ?></td><td><?= eu((string)$r['name']) ?></td><td><?= e(puzzle_ms_text((int)$r['best'])) ?></td><td><?= (int)$r['runs'] ?></td>
      <td><?= isset($flags[(int)$r['user_id']]) ? '<b class="bad">⚠ under a third of the median: check</b>' : '' ?></td></tr><?php endforeach; ?>
  </table>
  <?php else: ?><p class="muted">No finished runs yet.</p><?php endif; ?>
</div>
<div class="box">
  <h2>Recent runs</h2>
  <?php if ($runs): ?>
  <table class="grid"><tr><th>Gnome</th><th>Started</th><th>Time</th><th>Drops</th><th>Status</th><th>Void</th></tr>
    <?php foreach ($runs as $r): ?><tr><td><?= eu((string)$r['name']) ?></td><td><small><?= e(puzzle_local($r['started_at'])) ?></small></td><td><?= $r['ms'] !== null ? e(puzzle_ms_text((int)$r['ms'])) : '–' ?></td><td><?= $r['drops'] !== null ? (int)$r['drops'] : '–' ?></td>
      <td><?= e($r['status']) ?><?= $r['reason'] ? '<br><small class="muted">' . e($r['reason']) . '</small>' : '' ?></td>
      <td><?php if (in_array($r['status'], ['done', 'open'], true) && $cur['status'] !== 'settled'): ?><form method="post" class="inline"><?= csrf_field() ?><input type="hidden" name="do" value="void"><input type="hidden" name="attempt" value="<?= (int)$r['id'] ?>"><input type="text" name="reason" maxlength="150" placeholder="Reason" required> <button class="btn small danger">Void</button></form><?php endif; ?></td></tr><?php endforeach; ?>
  </table>
  <?php else: ?><p class="muted">No runs yet.</p><?php endif; ?>
</div>
<?php }

/** POST do=void: void one run with a reason (admin_log). $back(extra) gives the redirect for the page; $kind limits it to that kind of tournament. Ends the request. */
function admin_puzzle_ui_void(callable $back, string $kind): void
{
    $aid = (int)($_POST['attempt'] ?? 0);
    $reason = mb_substr(trim((string)($_POST['reason'] ?? '')), 0, 150);
    $a = q_one('SELECT a.*, t.status AS tstatus, t.kind AS tkind FROM puzzle_attempts a JOIN puzzle_tournaments t ON t.id = a.tournament_id WHERE a.id = ?', [$aid]);
    if ($a && $a['tkind'] !== $kind) $a = null;
    $ret = $back($a ? '&id=' . (int)$a['tournament_id'] : '');
    if (!$a || $reason === '') { flash('Give a reason to void a run.', 'err'); redirect($ret); }
    if ($a['tstatus'] === 'settled') { flash('That tournament is already settled.', 'err'); redirect($ret); }
    q("UPDATE puzzle_attempts SET status = 'void', reason = ? WHERE id = ?", ['admin: ' . $reason, $aid]);
    admin_log('puzzle_void', 'puzzle_attempts#' . $aid, 'user ' . (int)$a['user_id'] . ': ' . $reason);
    flash('Run voided.');
    redirect($ret);
}
