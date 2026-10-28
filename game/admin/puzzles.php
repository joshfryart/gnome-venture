<?php
declare(strict_types=1);
// v2.0.68: Puzzles. Library (titles, piece counts, on/off), GIF upload, tournaments (create, edit, live leaderboard, void a run).
require dirname(__DIR__) . '/includes/bootstrap.php';
require_once dirname(__DIR__) . '/includes/admin_helpers.php';
$me = require_admin();
require_once dirname(__DIR__) . '/includes/puzzles.php';
puzzles_ensure();
settle_puzzle_tournaments();
$tab = in_array($_GET['tab'] ?? '', ['upload', 'tournaments'], true) ? (string)$_GET['tab'] : 'library';
$back = fn(string $t, string $extra = '') => 'admin/puzzles.php?tab=' . $t . $extra;

if (is_post()) {
    csrf_check();
    $do = (string)($_POST['do'] ?? '');
    if ($do === 'pic_save') {
        $id = (int)($_POST['id'] ?? 0);
        $title = mb_substr(trim((string)($_POST['title'] ?? '')), 0, 80);
        $n = (int)($_POST['pieces_default'] ?? 54);
        if (!q_val('SELECT 1 FROM puzzle_pics WHERE id = ?', [$id]) || $title === '' || !in_array($n, PUZZLE_COUNTS, true)) { flash('Check the title and piece count.', 'err'); redirect($back('library')); }
        $act = !empty($_POST['active']) ? 1 : 0;
        q('UPDATE puzzle_pics SET title = ?, pieces_default = ?, sort = ?, active = ? WHERE id = ?', [$title, $n, max(-9999, min(9999, (int)($_POST['sort'] ?? 0))), $act, $id]);
        admin_log('puzzle_pic', 'puzzle_pics#' . $id, "active=$act pieces=$n");
        flash('Saved.');
        redirect($back('library'));
    }
    if ($do === 'upload') {
        $fail = function (string $msg) use ($back) { flash($msg, 'err'); redirect($back('upload')); };
        if (!function_exists('imagecreatefromgif') || !function_exists('imagepng')) $fail('This server has no GD image library, so the still picture can’t be made. Ask your host to turn on PHP GD.');
        $f = $_FILES['gif'] ?? null;
        if (!$f || !is_array($f) || ($f['error'] ?? UPLOAD_ERR_NO_FILE) !== UPLOAD_ERR_OK || !is_uploaded_file((string)$f['tmp_name'])) $fail('Pick a GIF to upload.');
        $title = mb_substr(trim((string)($_POST['title'] ?? '')), 0, 80);
        $n = (int)($_POST['pieces_default'] ?? 54);
        if ($title === '') $fail('Give the picture a title.');
        if (!in_array($n, PUZZLE_COUNTS, true)) $n = 54;
        [$err, $info] = puzzle_check_gif((string)$f['tmp_name'], (int)$f['size']);
        if ($err !== '') $fail($err);
        $dir = APP_ROOT . '/uploads/puzzles';
        if (!is_dir($dir) && !@mkdir($dir, 0755, true)) $fail('The uploads/puzzles folder is missing and couldn’t be made.');
        $hex = bin2hex(random_bytes(12));
        if (!move_uploaded_file((string)$f['tmp_name'], $dir . '/' . $hex . '.gif')) $fail('Couldn’t save the GIF. Is the uploads folder writable?');
        @chmod($dir . '/' . $hex . '.gif', 0644);
        $im = @imagecreatefromgif($dir . '/' . $hex . '.gif');
        if (!$im || !@imagepng($im, $dir . '/' . $hex . '-still.png')) { @unlink($dir . '/' . $hex . '.gif'); $fail('Couldn’t read the GIF’s first frame.'); }
        imagedestroy($im);
        @chmod($dir . '/' . $hex . '-still.png', 0644);
        $slug = puzzle_slug($title);
        $id = db_insert('puzzle_pics', ['slug' => $slug, 'title' => $title, 'file' => $hex . '.gif', 'still' => $hex . '-still.png', 'w' => $info['w'], 'h' => $info['h'], 'frames' => $info['frames'], 'bytes' => $info['bytes'],
            'pieces_default' => $n, 'source' => 'upload', 'active' => 0, 'sort' => 1000 + (int)q_val('SELECT COUNT(*) FROM puzzle_pics'), 'created_by' => (int)$me['id'], 'created_at' => now()]);
        admin_log('puzzle_upload', 'puzzle_pics#' . $id, $slug . ' ' . $info['w'] . 'x' . $info['h'] . ' ' . $info['frames'] . ' frames ' . $info['bytes'] . ' B');
        flash('Uploaded “' . $title . '”. It starts switched off: check it in the Library, then turn it on.');
        redirect($back('library'));
    }
    if ($do === 'tour_save') {
        $id = (int)($_POST['id'] ?? 0);
        $old = $id ? q_one('SELECT * FROM puzzle_tournaments WHERE id = ?', [$id]) : null;
        $ret = $back('tournaments', $id ? '&id=' . $id : '');
        if ($id && !$old) { flash('Unknown tournament.', 'err'); redirect($back('tournaments')); }
        if ($old && $old['status'] === 'settled') { flash('That tournament is settled and can’t be changed.', 'err'); redirect($ret); }
        $title = mb_substr(trim((string)($_POST['title'] ?? '')), 0, 80);
        $pic = (int)($_POST['pic_id'] ?? 0);
        $n = (int)($_POST['pieces'] ?? 54);
        $s = puzzle_to_utc((string)($_POST['starts_at'] ?? ''));
        $e = puzzle_to_utc((string)($_POST['ends_at'] ?? ''));
        $st = ($_POST['status'] ?? '') === 'live' ? 'live' : 'draft';
        $err = $title === '' ? 'Give it a title.' : (!q_val('SELECT 1 FROM puzzle_pics WHERE id = ?', [$pic]) ? 'Pick a picture.' : (!in_array($n, PUZZLE_COUNTS, true) ? 'Pick a piece count.'
             : (!$s || !$e ? 'Fill in both times.' : ($e <= $s ? 'It must end after it starts.' : (strtotime($e . ' UTC') - strtotime($s . ' UTC') > 60 * 86400 ? 'Keep it to 60 days at most.' : '')))));
        $runs = $old ? (int)q_val('SELECT COUNT(*) FROM puzzle_attempts WHERE tournament_id = ?', [$id]) : 0;
        if ($err === '' && $runs && ((int)$old['pic_id'] !== $pic || (int)$old['pieces'] !== $n)) $err = 'Players have already had goes: the picture and piece count can’t change now.';
        if ($err !== '') { flash($err, 'err'); redirect($ret); }
        $row = ['title' => $title, 'pic_id' => $pic, 'pieces' => $n, 'starts_at' => $s, 'ends_at' => $e, 'status' => $st];
        if ($old) db_update('puzzle_tournaments', $row, 'id = ?', [$id]);
        else $id = db_insert('puzzle_tournaments', $row + ['created_by' => (int)$me['id'], 'created_at' => now()]);
        admin_log('puzzle_tourney', 'puzzle_tournaments#' . $id, "$st $s to $e, pic $pic, $n pieces");
        flash('Saved' . ($st === 'live' && setting('puzzles_tournaments') !== '1' ? '. Players won’t see it until Puzzle tournaments are on in Game settings' : '') . '.');
        redirect($back('tournaments', '&id=' . $id));
    }
    if ($do === 'void') {
        $aid = (int)($_POST['attempt'] ?? 0);
        $reason = mb_substr(trim((string)($_POST['reason'] ?? '')), 0, 150);
        $a = q_one('SELECT a.*, t.status AS tstatus FROM puzzle_attempts a JOIN puzzle_tournaments t ON t.id = a.tournament_id WHERE a.id = ?', [$aid]);
        $ret = $back('tournaments', $a ? '&id=' . (int)$a['tournament_id'] : '');
        if (!$a || $reason === '') { flash('Give a reason to void a run.', 'err'); redirect($ret); }
        if ($a['tstatus'] === 'settled') { flash('That tournament is already settled.', 'err'); redirect($ret); }
        q("UPDATE puzzle_attempts SET status = 'void', reason = ? WHERE id = ?", ['admin: ' . $reason, $aid]);
        admin_log('puzzle_void', 'puzzle_attempts#' . $aid, 'user ' . (int)$a['user_id'] . ': ' . $reason);
        flash('Run voided.');
        redirect($ret);
    }
    redirect($back($tab));
}

$pics = puzzle_pics(false);
$local = fn(?string $utc) => $utc ? puzzle_local($utc, 'Y-m-d\TH:i') : '';
page_header('Puzzles', true);
admin_crumbs('puzzles.php');
?>
<h1>🧩 Puzzles</h1>
<p class="help">Puzzles for players: <b><?= setting('puzzles_open') === '1' ? 'open' : 'admins only' ?></b> · tournaments: <b><?= setting('puzzles_tournaments') === '1' ? 'on' : 'off' ?></b>
  (change both in <a href="<?= e(url('admin/settings.php')) ?>">Game settings</a>; tournaments only show while Puzzles are open). <a href="<?= e(url('gifsaw.php')) ?>">Open GIFsaw</a> · <a href="<?= e(url('puzzles.php')) ?>">Puzzles hub</a>.</p>
<nav class="tabs">
  <a class="tab<?= $tab === 'library' ? ' on' : '' ?>" href="<?= e(url('admin/puzzles.php')) ?>">🖼️ Library</a>
  <a class="tab<?= $tab === 'upload' ? ' on' : '' ?>" href="<?= e(url('admin/puzzles.php?tab=upload')) ?>">⬆️ Upload</a>
  <a class="tab<?= $tab === 'tournaments' ? ' on' : '' ?>" href="<?= e(url('admin/puzzles.php?tab=tournaments')) ?>">🏆 Tournaments</a>
</nav>

<?php if ($tab === 'library'): ?>
<table class="grid">
  <tr><th>Picture</th><th>Title</th><th>Size</th><th>Pieces</th><th>Order</th><th>On</th><th></th></tr>
  <?php foreach ($pics as $p): ?>
  <tr><form method="post"><?= csrf_field() ?><input type="hidden" name="do" value="pic_save"><input type="hidden" name="id" value="<?= (int)$p['id'] ?>">
    <td><img src="<?= e(url(puzzle_pic_path($p, true))) ?>" alt="" width="64" loading="lazy"></td>
    <td><input type="text" name="title" maxlength="80" value="<?= e($p['title']) ?>" required><br><small class="help"><?= e($p['slug']) ?> · <?= $p['source'] === 'upload' ? 'uploaded' : 'built in' ?></small></td>
    <td><small><?= (int)$p['w'] ?> × <?= (int)$p['h'] ?><?= (int)$p['frames'] ? ', ' . (int)$p['frames'] . ' frames' : '' ?><?= (int)$p['bytes'] ? ', ' . round((int)$p['bytes'] / 1024) . ' KB' : '' ?></small></td>
    <td><select name="pieces_default"><?php foreach (PUZZLE_COUNTS as $n): ?><option value="<?= $n ?>"<?= (int)$p['pieces_default'] === $n ? ' selected' : '' ?>><?= $n ?></option><?php endforeach; ?></select></td>
    <td><input type="number" name="sort" value="<?= (int)$p['sort'] ?>" class="qty"></td>
    <td><input type="checkbox" name="active" value="1"<?= (int)$p['active'] ? ' checked' : '' ?>></td>
    <td><button class="btn small">Save</button></td></form></tr>
  <?php endforeach; ?>
</table>
<?php if (!$pics): ?><p>No pictures yet.</p><?php endif; ?>

<?php elseif ($tab === 'upload'): ?>
<div class="box">
  <p class="help"><b>Simple GIFs; ideally drawn through the Aseprite process (Stitched Toy style).</b></p>
  <p class="help">An animated GIF up to 1.5 MB, each side 64 to 640 pixels, no longer than 2:1 either way, up to <?= PUZZLE_UP_MAX_FRAMES ?> frames (and width × height × frames under 40 million).
    The first frame becomes the still picture. New pictures start switched off.<?= function_exists('imagecreatefromgif') ? '' : ' <b>This server has no GD, so uploads are refused.</b>' ?></p>
  <form method="post" enctype="multipart/form-data" class="stack"><?= csrf_field() ?><input type="hidden" name="do" value="upload">
    <label>Title <input type="text" name="title" maxlength="80" required></label>
    <label>Pieces (default) <select name="pieces_default"><?php foreach (PUZZLE_COUNTS as $n): ?><option value="<?= $n ?>"<?= $n === 54 ? ' selected' : '' ?>><?= $n ?></option><?php endforeach; ?></select></label>
    <label>GIF <input type="file" name="gif" accept="image/gif" required></label>
    <button class="btn">Upload</button>
  </form>
</div>

<?php else:
    $tid = (int)($_GET['id'] ?? 0);
    $cur = $tid ? q_one('SELECT * FROM puzzle_tournaments WHERE id = ?', [$tid]) : null;
    $all = q('SELECT t.*, p.title AS pic_title, (SELECT COUNT(DISTINCT user_id) FROM puzzle_attempts a WHERE a.tournament_id = t.id) AS players FROM puzzle_tournaments t JOIN puzzle_pics p ON p.id = t.pic_id ORDER BY t.starts_at DESC LIMIT 50')->fetchAll();
    $f = $cur ?: ['id' => 0, 'title' => '', 'pic_id' => 0, 'pieces' => 54, 'starts_at' => gmdate('Y-m-d H:00:00', time() + 3600), 'ends_at' => gmdate('Y-m-d H:00:00', time() + 7 * 86400), 'status' => 'draft']; ?>
<table class="grid">
  <tr><th>Tournament</th><th>Picture</th><th>Pieces</th><th>When (Hollow time)</th><th>Status</th><th>Players</th></tr>
  <?php foreach ($all as $r): ?>
  <tr<?= (int)$r['id'] === $tid ? ' class="on"' : '' ?>><td><a href="<?= e(url('admin/puzzles.php?tab=tournaments&id=' . (int)$r['id'])) ?>"><?= e($r['title']) ?></a></td><td><?= e($r['pic_title']) ?></td><td><?= (int)$r['pieces'] ?></td>
    <td><small><?= e(puzzle_local($r['starts_at'])) ?> to <?= e(puzzle_local($r['ends_at'])) ?></small></td><td><?= e($r['status']) ?> <small class="muted">(<?= e(puzzle_tourney_phase($r)) ?>)</small></td><td><?= (int)$r['players'] ?></td></tr>
  <?php endforeach; ?>
</table>
<?php if (!$all): ?><p>No tournaments yet.</p><?php endif; ?>
<p><a class="btn small" href="<?= e(url('admin/puzzles.php?tab=tournaments')) ?>">＋ New tournament</a></p>

<div class="box">
  <h2><?= $cur ? 'Edit: ' . e($cur['title']) : 'New tournament' ?></h2>
  <?php if ($cur && $cur['status'] === 'settled'): ?><p class="help">Settled <?= e(puzzle_local((string)$cur['settled_at'])) ?>. Places and badges have been given out.</p>
  <?php else: ?>
  <form method="post" class="stack"><?= csrf_field() ?><input type="hidden" name="do" value="tour_save"><input type="hidden" name="id" value="<?= (int)$f['id'] ?>">
    <label>Title <input type="text" name="title" maxlength="80" value="<?= e($f['title']) ?>" required></label>
    <label>Picture <select name="pic_id"><?php foreach ($pics as $p): ?><option value="<?= (int)$p['id'] ?>"<?= (int)$p['id'] === (int)$f['pic_id'] ? ' selected' : '' ?>><?= e($p['title']) ?><?= (int)$p['active'] ? '' : ' (off in the library)' ?></option><?php endforeach; ?></select></label>
    <label>Pieces <select name="pieces"><?php foreach (PUZZLE_COUNTS as $n): ?><option value="<?= $n ?>"<?= (int)$f['pieces'] === $n ? ' selected' : '' ?>><?= $n ?></option><?php endforeach; ?></select></label>
    <label>Starts (Hollow time) <input type="datetime-local" name="starts_at" value="<?= e($local($f['starts_at'])) ?>" required></label>
    <label>Ends (Hollow time) <input type="datetime-local" name="ends_at" value="<?= e($local($f['ends_at'])) ?>" required></label>
    <label>Status <select name="status"><option value="draft"<?= $f['status'] === 'draft' ? ' selected' : '' ?>>Draft (hidden)</option><option value="live"<?= $f['status'] === 'live' ? ' selected' : '' ?>>Live</option></select></label>
    <p class="help">Everyone gets the same scramble. Best time counts; up to <?= PUZZLE_DAILY_TRIES ?> goes a day. A run handed in faster than <?= PUZZLE_MIN_MS_PER_PIECE / 1000 ?> s a piece, with fewer drops than pieces − 1, or more than <?= PUZZLE_GRACE_S / 60 ?> minutes after the end is rejected. Results are settled <?= PUZZLE_GRACE_S / 60 ?> minutes after the end: 🏆 gold, silver, bronze and an “entered” badge (cosmetic only).</p>
    <button class="btn">Save</button>
  </form>
  <?php endif; ?>
</div>

<?php if ($cur):
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
<?php endif; ?>
<?php endif; ?>
<?php page_footer();
