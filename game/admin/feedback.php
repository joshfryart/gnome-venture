<?php
declare(strict_types=1);
/** v0.8.6: notes players sent from the menu. v2.6.37: a message box: reply to a note, or write to a player first. */
require dirname(__DIR__) . '/includes/bootstrap.php';
require_once dirname(__DIR__) . '/includes/admin_helpers.php';   // v1.6.3
require_once dirname(__DIR__) . '/includes/messages.php';
$me = require_admin();
msg_boot();

$all = isset($_GET['all']) || isset($_POST['all']);
$back = 'admin/feedback.php' . ($all ? '?all=1' : '');
if (is_post()) {
    csrf_check();
    $id = (int)($_POST['id'] ?? 0);
    $do = (string)($_POST['do'] ?? '');
    if ($do === 'done' || $do === 'new') {
        q('UPDATE feedback SET status = ? WHERE id = ?', [$do, $id]);
    } elseif ($do === 'reply') {
        [$ok, $msg] = msg_admin_reply($me, $id, (string)($_POST['body'] ?? ''));
        if ($ok) admin_log('message_reply', '#' . $id);
        flash($msg, $ok ? 'ok' : 'err');
        if (!$ok) redirect($back . '#m' . $id);
    } elseif ($do === 'start') {
        [$ok, $msg, $nid] = msg_admin_start($me, (string)($_POST['username'] ?? ''), (string)($_POST['body'] ?? ''));
        if ($ok) admin_log('message_start', (string)($_POST['username'] ?? ''), '#' . $nid);
        flash($msg, $ok ? 'ok' : 'err');
        redirect('admin/feedback.php?all=1' . ($ok ? '#m' . $nid : ''));
    } elseif ($do === 'delete') {
        q('DELETE FROM feedback_replies WHERE feedback_id = ?', [$id]);
        q('DELETE FROM feedback WHERE id = ?', [$id]);
        admin_log('feedback_delete', '#' . $id);
    }
    redirect($back);
}

$rows = q('SELECT f.*, u.username, COALESCE(u.gnome_name, u.username) AS gname FROM feedback f LEFT JOIN users u ON u.id = f.user_id'
    . ($all ? '' : " WHERE f.status = 'new'") . ' ORDER BY (f.status = \'new\') DESC, COALESCE(f.last_at, f.created_at) DESC, f.id DESC LIMIT 200')->fetchAll();
$replies = msg_replies(array_column($rows, 'id'));
$nNew = msg_admin_new();
$to = preg_match('/^[A-Za-z0-9_.\-]{1,40}$/', (string)($_GET['to'] ?? '')) ? (string)$_GET['to'] : '';
page_header('Messages', true);
?>
<?php admin_crumbs('feedback.php');   // v1.6.3 ?>
<h1>💬 Messages</h1>
<p class="help">Notes players sent with “💬 Send feedback”, and your replies. A reply shows a yellow <b>!</b> on the player’s menu and their Together → Messages tab, and marks the note as dealt with. If the player answers, it comes back here as new.</p>
<nav class="tabs">
  <a class="<?= $all ? '' : 'on' ?>" href="<?= e(url('admin/feedback.php')) ?>">Waiting for you<?= $nNew ? ' (' . $nNew . ')' : '' ?></a>
  <a class="<?= $all ? 'on' : '' ?>" href="<?= e(url('admin/feedback.php?all=1')) ?>">All messages</a>
</nav>
<details class="fold box"<?= $to !== '' ? ' open' : '' ?>><summary>✉️ Write to a player</summary>
  <form method="post" class="form"><?= csrf_field() ?><input type="hidden" name="do" value="start">
    <label>Username <input type="text" name="username" value="<?= e($to) ?>" maxlength="40" required autocomplete="off"></label>
    <label>Message <textarea name="body" rows="4" maxlength="<?= MSG_MAX ?>" required></textarea></label>
    <p><button class="btn small">Send</button></p>
  </form>
</details>
<?php if (!$rows): ?><p class="muted">Nothing <?= $all ? 'yet' : 'waiting. 🌿' ?></p><?php endif; ?>
<?php foreach ($rows as $r): $id = (int)$r['id']; $rs = $replies[$id] ?? []; ?>
  <div class="box" id="m<?= $id ?>">
    <p class="muted"><b><?= e((string)($r['gname'] ?? '?')) ?></b> (<?= e((string)($r['username'] ?? '?')) ?>)<?= $r['page'] !== '' ? ' · from ' . e($r['page']) : '' ?>
      · <?= $r['status'] === 'done' ? '✅ dealt with' : '<span class="tag">new</span>' ?><?= (int)$r['user_unread'] === 1 ? ' · <span class="muted">player has not opened your reply</span>' : '' ?></p>
    <?= msg_thread_html($r, $rs, true, (string)($r['gname'] ?? 'Player')) ?>
    <form method="post" class="form"><?= csrf_field() ?><input type="hidden" name="id" value="<?= $id ?>"><?= $all ? '<input type="hidden" name="all" value="1">' : '' ?>
      <label class="asr" for="rb<?= $id ?>">Reply</label>
      <textarea id="rb<?= $id ?>" name="body" rows="2" maxlength="<?= MSG_MAX ?>" placeholder="Reply to <?= e((string)($r['gname'] ?? 'the player')) ?>…" required></textarea>
      <p><button class="btn small" name="do" value="reply">↩️ Send reply</button></p>
    </form>
    <form method="post" class="inline"><?= csrf_field() ?><input type="hidden" name="id" value="<?= $id ?>"><?= $all ? '<input type="hidden" name="all" value="1">' : '' ?>
      <?php if ($r['status'] === 'done'): ?><button class="btn small alt" name="do" value="new">Mark as new</button>
      <?php else: ?><button class="btn small alt" name="do" value="done">✅ No reply needed</button><?php endif; ?>
    </form>
    <form method="post" class="inline" data-confirm="Delete this whole conversation for good?"><?= csrf_field() ?><input type="hidden" name="id" value="<?= $id ?>"><?= $all ? '<input type="hidden" name="all" value="1">' : '' ?>
      <button class="btn small alt" name="do" value="delete">Delete</button></form>
  </div>
<?php endforeach; ?>
<?php page_footer();
