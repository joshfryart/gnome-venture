<?php
declare(strict_types=1);
/**
 * v2.0.87 C: Admin > Jigsaw. Library (all still pictures; Places read-only except on/off), Upload (3:2 stills, GD re-encode), Tournaments (one picture + one tier each,
 * "Make all three tiers" = a cup), and a Settings card. Pieces ALWAYS come from the tier (JIGSAW_TIERS), never from the form. The weekly Schedule tab is 2.0.88.
 * Shares the tournament markup with admin/puzzles.php through includes/admin_puzzle_ui.php. Plan: claude/plan-jigsaw.md section 6.
 */
require dirname(__DIR__) . '/includes/bootstrap.php';
require_once dirname(__DIR__) . '/includes/admin_helpers.php';
$me = require_admin();
require_once dirname(__DIR__) . '/includes/jigsaw.php';
require_once dirname(__DIR__) . '/includes/admin_puzzle_ui.php';
require_once dirname(__DIR__) . '/includes/trade.php';
jigsaw_ensure();
settle_puzzle_tournaments();
jigsaw_release_reserved();
const JIGSAW_UP_MAX_BYTES = 3145728;   // 3 MB
const JIGSAW_UP_MAX_FILES = 25;
$tab = in_array($_GET['tab'] ?? '', ['upload', 'tournaments', 'settings'], true) ? (string)$_GET['tab'] : 'library';
$back = fn(string $t, string $extra = '') => 'admin/jigsaw.php?tab=' . $t . $extra;

/** The tier radio's value, or '' when it is not one of the three tiers. */
$tierOf = fn($v) => is_string($v) && isset(JIGSAW_TIERS[$v]) ? $v : '';
/** A gallery (non-Places) still picture row, or null. */
$galleryPic = fn(int $id) => q_one("SELECT * FROM puzzle_pics WHERE id = ? AND kind = 'still' AND source <> 'place'", [$id]);

/** Check and re-encode one uploaded picture. Returns [error or '', row fields]. */
function jigsaw_admin_ingest(string $tmp, int $size, string $name): array
{
    if ($size <= 0 || $size > JIGSAW_UP_MAX_BYTES) return [$name . ': pictures can be up to 3 MB (this one is ' . round($size / 1048576, 1) . ' MB).', []];
    $mime = (string)(new finfo(FILEINFO_MIME_TYPE))->file($tmp);
    $info = @getimagesize($tmp);
    if (!in_array($mime, ['image/jpeg', 'image/png', 'image/webp'], true) || !$info || $info['mime'] !== $mime) return [$name . ': that isn’t a JPEG, PNG or WEBP picture.', []];
    [$w, $h] = [(int)$info[0], (int)$info[1]];
    if ($w < 1500 || $h < 1000) return [$name . ': too small, ' . $w . ' × ' . $h . ' (at least 1500 × 1000).', []];
    if ($w > 3000 || $h > 2000) return [$name . ': too big, ' . $w . ' × ' . $h . ' (at most 3000 × 2000).', []];
    if (abs($w / $h - 1.5) / 1.5 > 0.01) return [$name . ': must be 3:2 (within 1%). This one is ' . $w . ' × ' . $h . ' (' . round($w / $h, 3) . ':1, needs 1.5:1).', []];
    $fn = ['image/jpeg' => 'imagecreatefromjpeg', 'image/png' => 'imagecreatefrompng', 'image/webp' => 'imagecreatefromwebp'][$mime];
    if (!function_exists($fn)) return [$name . ': this server’s GD can’t read ' . $mime . '.', []];
    $src = @$fn($tmp);
    if (!$src) return [$name . ': the picture couldn’t be read.', []];
    $dir = APP_ROOT . '/uploads/jigsaw';
    if (!is_dir($dir) && !@mkdir($dir, 0755, true)) { imagedestroy($src); return ['The uploads/jigsaw folder is missing and couldn’t be made.', []]; }
    $hex = bin2hex(random_bytes(12));
    $big = imagecreatetruecolor(JIGSAW_W, JIGSAW_H);
    imagecopyresampled($big, $src, 0, 0, 0, 0, JIGSAW_W, JIGSAW_H, $w, $h);   // a fresh canvas: no EXIF, no metadata, exact 1800 x 1200
    $th = imagecreatetruecolor(450, 300);
    imagecopyresampled($th, $big, 0, 0, 0, 0, 450, 300, JIGSAW_W, JIGSAW_H);
    $ok = @imagejpeg($big, $dir . '/' . $hex . '.jpg', 85) && @imagejpeg($th, $dir . '/' . $hex . '-thumb.jpg', 85);
    imagedestroy($src); imagedestroy($big); imagedestroy($th);
    if (!$ok) { @unlink($dir . '/' . $hex . '.jpg'); @unlink($dir . '/' . $hex . '-thumb.jpg'); return [$name . ': couldn’t save it. Is the uploads folder writable?', []]; }
    @chmod($dir . '/' . $hex . '.jpg', 0644); @chmod($dir . '/' . $hex . '-thumb.jpg', 0644);
    return ['', ['hex' => $hex, 'bytes' => (int)@filesize($dir . '/' . $hex . '.jpg'), 'from' => $w . 'x' . $h]];
}

/** A unique 'jig-' slug for a title. */
function jigsaw_admin_slug(string $title): string
{
    $base = 'jig-' . substr(trim((string)preg_replace('/[^a-z0-9]+/', '-', strtolower($title)), '-') ?: 'picture', 0, 44);
    $slug = $base;
    for ($k = 2; q_val('SELECT 1 FROM puzzle_pics WHERE slug = ?', [$slug]); $k++) $slug = $base . '-' . $k;
    return $slug;
}

/** Validate the tournament form (title, picture, tier, times, status). Returns [error, fields]. Pieces come from the tier. */
function jigsaw_admin_tour_fields(callable $galleryPic, callable $tierOf): array
{
    $title = mb_substr(trim((string)($_POST['title'] ?? '')), 0, 80);
    $pic = (int)($_POST['pic_id'] ?? 0);
    $tier = $tierOf($_POST['tier'] ?? '');
    $s = puzzle_to_utc((string)($_POST['starts_at'] ?? ''));
    $e = puzzle_to_utc((string)($_POST['ends_at'] ?? ''));
    $st = ($_POST['status'] ?? '') === 'live' ? 'live' : 'draft';
    $err = $title === '' ? 'Give it a title.' : (!$galleryPic($pic) ? 'Pick a gallery picture (a Places picture can’t be a tournament).' : ($tier === '' ? 'Pick Easy, Advanced or Expert.'
         : (!$s || !$e ? 'Fill in both times.' : ($e <= $s ? 'It must end after it starts.' : (strtotime($e . ' UTC') - strtotime($s . ' UTC') > 60 * 86400 ? 'Keep it to 60 days at most.' : '')))));
    return [$err, ['title' => $title, 'pic_id' => $pic, 'tier' => $tier, 'pieces' => $tier !== '' ? jigsaw_pieces($tier) : 0, 'starts_at' => $s, 'ends_at' => $e, 'status' => $st, 'kind' => 'still']];
}

if (!empty($_GET['csv']) && $tab === 'tournaments') {   // results of one tournament as CSV (read only)
    $tid = (int)($_GET['id'] ?? 0);
    $cur = $tid ? q_one("SELECT * FROM puzzle_tournaments WHERE id = ? AND kind = 'still'", [$tid]) : null;
    if (!$cur) { flash('Unknown tournament.', 'err'); redirect($back('tournaments')); }
    $cell = fn($v) => preg_match('/^[=+\-@\t\r]/', (string)$v) ? "'" . $v : (string)$v;   // no spreadsheet formulas from a gnome name
    header('Content-Type: text/csv; charset=utf-8');
    header('Content-Disposition: attachment; filename="jigsaw-tournament-' . $tid . '.csv"');
    $o = fopen('php://output', 'w');
    fputcsv($o, ['rank', 'gnome', 'best_ms', 'best_time', 'finished_goes', 'place', 'tier', 'tournament'], ',', '"', '\\');
    foreach (puzzle_board($tid, 100000) as $k => $r) {
        $pl = q_val('SELECT place FROM puzzle_attempts WHERE tournament_id = ? AND user_id = ? AND place IS NOT NULL', [$tid, (int)$r['user_id']]);
        fputcsv($o, [$k + 1, $cell($r['name']), (int)$r['best'], puzzle_ms_text((int)$r['best']), (int)$r['runs'], $pl ?: '', $cur['tier'], $cell($cur['title'])], ',', '"', '\\');
    }
    admin_log('jigsaw_csv', 'puzzle_tournaments#' . $tid, 'results downloaded');
    exit;
}

if (is_post()) {
    csrf_check();
    $do = (string)($_POST['do'] ?? '');
    if ($do === 'pic_save') {
        $id = (int)($_POST['id'] ?? 0);
        $title = mb_substr(trim((string)($_POST['title'] ?? '')), 0, 80);
        $cat = mb_substr(trim((string)($_POST['cat'] ?? '')), 0, 24);
        if (!$galleryPic($id) || $title === '' || ($cat !== '' && !in_array($cat, JIGSAW_CATS, true))) { flash('Check the title and category.', 'err'); redirect($back('library')); }
        $act = !empty($_POST['active']) ? 1 : 0;
        $res = !empty($_POST['reserved']) ? 1 : 0;
        q('UPDATE puzzle_pics SET title = ?, cat = ?, sort = ?, active = ?, reserved = ? WHERE id = ?', [$title, $cat === '' ? null : $cat, max(-9999, min(9999, (int)($_POST['sort'] ?? 0))), $act, $res, $id]);
        admin_log('jigsaw_pic', 'puzzle_pics#' . $id, "active=$act reserved=$res cat=$cat");
        flash('Saved.');
        redirect($back('library'));
    }
    if ($do === 'place_active') {   // a Places picture: only on / off
        $id = (int)($_POST['id'] ?? 0);
        if (!q_val("SELECT 1 FROM puzzle_pics WHERE id = ? AND kind = 'still' AND source = 'place'", [$id])) { flash('Unknown picture.', 'err'); redirect($back('library')); }
        $act = !empty($_POST['active']) ? 1 : 0;
        q('UPDATE puzzle_pics SET active = ? WHERE id = ?', [$act, $id]);
        admin_log('jigsaw_pic', 'puzzle_pics#' . $id, "place active=$act");
        flash('Saved.');
        redirect($back('library') . '#places');
    }
    if ($do === 'upload') {
        $fail = function (string $msg) use ($back) { flash($msg, 'err'); redirect($back('upload')); };
        if (!function_exists('imagecreatefromjpeg') || !function_exists('imagejpeg') || !function_exists('imagecopyresampled')) $fail('This server has no GD image library, so pictures can’t be resized and checked. Ask your host to turn on PHP GD.');
        $F = $_FILES['pics'] ?? null;
        $names = $F && is_array($F['name'] ?? null) ? array_values($F['name']) : [];
        $files = [];
        foreach ($names as $i => $nm) {
            if (($F['error'][$i] ?? UPLOAD_ERR_NO_FILE) === UPLOAD_ERR_NO_FILE) continue;
            $files[] = ['name' => (string)$nm, 'tmp' => (string)$F['tmp_name'][$i], 'size' => (int)$F['size'][$i], 'err' => (int)$F['error'][$i]];
        }
        if (!$files) $fail('Pick at least one picture.');
        if (count($files) > JIGSAW_UP_MAX_FILES) $fail('Up to ' . JIGSAW_UP_MAX_FILES . ' pictures at a time (you picked ' . count($files) . ').');
        $cat = mb_substr(trim((string)($_POST['cat'] ?? '')), 0, 24);
        if ($cat !== '' && !in_array($cat, JIGSAW_CATS, true)) $fail('Pick a category from the list.');
        $reserve = !empty($_POST['reserved']) ? 1 : 0;
        $oneTitle = mb_substr(trim((string)($_POST['title'] ?? '')), 0, 80);
        $made = 0;
        foreach ($files as $f) {
            if ($f['err'] !== UPLOAD_ERR_OK || !is_uploaded_file($f['tmp'])) {
                flash($f['name'] . (in_array($f['err'], [UPLOAD_ERR_INI_SIZE, UPLOAD_ERR_FORM_SIZE], true) ? ': too big. Pictures can be up to 3 MB, and this server’s upload limit is ' . ini_get('upload_max_filesize') . '.' : ': the upload failed (interrupted or not saved).'), 'err');
                continue;
            }
            [$err, $info] = jigsaw_admin_ingest($f['tmp'], $f['size'], $f['name']);
            if ($err !== '') { flash($err, 'err'); continue; }
            $title = count($files) === 1 && $oneTitle !== '' ? $oneTitle : mb_substr(trim(ucwords(str_replace(['-', '_'], ' ', pathinfo($f['name'], PATHINFO_FILENAME)))) ?: 'Picture', 0, 80);
            $slug = jigsaw_admin_slug($title);
            $id = db_insert('puzzle_pics', ['slug' => $slug, 'title' => $title, 'file' => $info['hex'] . '.jpg', 'still' => $info['hex'] . '.jpg', 'thumb' => $info['hex'] . '-thumb.jpg', 'cat' => $cat === '' ? null : $cat,
                'kind' => 'still', 'reserved' => $reserve, 'w' => JIGSAW_W, 'h' => JIGSAW_H, 'frames' => 0, 'bytes' => $info['bytes'], 'pieces_default' => 96, 'source' => 'upload', 'active' => 0,
                'sort' => 2000 + (int)q_val('SELECT COUNT(*) FROM puzzle_pics'), 'created_by' => (int)$me['id'], 'created_at' => now()]);
            admin_log('jigsaw_upload', 'puzzle_pics#' . $id, $slug . ' from ' . $info['from'] . ($reserve ? ' reserved' : ''));
            $made++;
        }
        if ($made) flash('Uploaded ' . $made . ' picture' . ($made === 1 ? '' : 's') . '. ' . ($made === 1 ? 'It starts' : 'They start') . ' switched off: check ' . ($made === 1 ? 'it' : 'them') . ' in the Library, then turn on.');
        redirect($back($made ? 'library' : 'upload'));
    }
    if ($do === 'tour_save') {
        $id = (int)($_POST['id'] ?? 0);
        $old = $id ? q_one("SELECT * FROM puzzle_tournaments WHERE id = ? AND kind = 'still'", [$id]) : null;
        $ret = $back('tournaments', $id ? '&id=' . $id : '');
        if ($id && !$old) { flash('Unknown tournament.', 'err'); redirect($back('tournaments')); }
        if ($old && $old['status'] === 'settled') { flash('That tournament is settled and can’t be changed.', 'err'); redirect($ret); }
        [$err, $row] = jigsaw_admin_tour_fields($galleryPic, $tierOf);
        $runs = $old ? (int)q_val('SELECT COUNT(*) FROM puzzle_attempts WHERE tournament_id = ?', [$id]) : 0;
        if ($err === '' && $runs && ((int)$old['pic_id'] !== $row['pic_id'] || (string)$old['tier'] !== $row['tier'])) $err = 'Players have already had goes: the picture and tier can’t change now.';
        if ($err !== '') { flash($err, 'err'); redirect($ret); }
        if ($old) db_update('puzzle_tournaments', $row, 'id = ?', [$id]);
        else $id = db_insert('puzzle_tournaments', $row + ['created_by' => (int)$me['id'], 'created_at' => now()]);
        admin_log('jigsaw_tourney', 'puzzle_tournaments#' . $id, $row['status'] . ' ' . $row['starts_at'] . ' to ' . $row['ends_at'] . ', pic ' . $row['pic_id'] . ', ' . $row['tier'] . ' ' . $row['pieces'] . ' pieces');
        flash('Saved' . ($row['status'] === 'live' && !jigsaw_tournaments_on() ? '. Players won’t see it until Jigsaw tournaments are on in Game settings' : '') . '.');
        redirect($back('tournaments', '&id=' . $id));
    }
    if ($do === 'tour_cup') {   // three tiers of one picture, sharing a cup_id, times and a title with a tier suffix
        [$err, $row] = jigsaw_admin_tour_fields(fn(int $i) => $galleryPic($i), fn($v) => 'easy');   // the tier is set per row below
        if ($err !== '') { flash($err, 'err'); redirect($back('tournaments')); }
        $cup = 1 + (int)q_val('SELECT COALESCE(MAX(cup_id), 0) FROM puzzle_tournaments');
        $ids = [];
        foreach (JIGSAW_TIERS as $k => $tt) {
            $r = $row;
            $suffix = ' - ' . $tt[0];
            $r['title'] = mb_substr($row['title'], 0, 80 - mb_strlen($suffix)) . $suffix;
            $r['tier'] = $k; $r['pieces'] = jigsaw_pieces($k);
            $ids[] = db_insert('puzzle_tournaments', $r + ['cup_id' => $cup, 'created_by' => (int)$me['id'], 'created_at' => now()]);
        }
        admin_log('jigsaw_cup', 'puzzle_tournaments#' . $ids[0], 'cup ' . $cup . ': ' . implode(',', $ids) . ' ' . $row['status'] . ' ' . $row['starts_at'] . ' to ' . $row['ends_at'] . ', pic ' . $row['pic_id']);
        flash('Made a cup: Easy, Advanced and Expert' . ($row['status'] === 'live' && !jigsaw_tournaments_on() ? '. Players won’t see it until Jigsaw tournaments are on in Game settings' : '') . '.');
        redirect($back('tournaments', '&id=' . $ids[0]));
    }
    if ($do === 'tour_dup') {   // a draft copy (same picture and tier), same length, starting in an hour
        $id = (int)($_POST['id'] ?? 0);
        $old = q_one("SELECT * FROM puzzle_tournaments WHERE id = ? AND kind = 'still'", [$id]);
        if (!$old) { flash('Unknown tournament.', 'err'); redirect($back('tournaments')); }
        $len = max(3600, strtotime($old['ends_at'] . ' UTC') - strtotime($old['starts_at'] . ' UTC'));
        $s = gmdate('Y-m-d H:00:00', time() + 3600);
        $nid = db_insert('puzzle_tournaments', ['title' => mb_substr($old['title'], 0, 73) . ' (copy)', 'pic_id' => (int)$old['pic_id'], 'pieces' => jigsaw_pieces((string)$old['tier']), 'tier' => $old['tier'], 'kind' => 'still',
            'starts_at' => $s, 'ends_at' => gmdate('Y-m-d H:i:s', strtotime($s . ' UTC') + $len), 'status' => 'draft', 'created_by' => (int)$me['id'], 'created_at' => now()]);
        admin_log('jigsaw_tourney', 'puzzle_tournaments#' . $nid, 'duplicate of #' . $id);
        flash('Duplicated as a draft. Set its times and go live when ready.');
        redirect($back('tournaments', '&id=' . $nid));
    }
    if ($do === 'tour_cancel') {   // void every run, close it: no places, no notes
        $id = (int)($_POST['id'] ?? 0);
        $old = q_one("SELECT * FROM puzzle_tournaments WHERE id = ? AND kind = 'still'", [$id]);
        $ret = $back('tournaments', $id ? '&id=' . $id : '');
        if (!$old || $old['status'] === 'settled') { flash('That tournament can’t be cancelled (unknown, or already settled).', 'err'); redirect($ret); }
        q("UPDATE puzzle_attempts SET status = 'void', reason = 'admin: tournament cancelled', place = NULL WHERE tournament_id = ?", [$id]);
        q("UPDATE puzzle_tournaments SET status = 'settled', settled_at = ? WHERE id = ?", [now(), $id]);
        jigsaw_release_reserved([(int)$old['pic_id']]);
        admin_log('jigsaw_cancel', 'puzzle_tournaments#' . $id, 'cancelled; all runs voided, no places');
        flash('Cancelled. All runs are void and nobody got a place.');
        redirect($ret);
    }
    if ($do === 'tour_settle') {   // end it now and hand out the places
        $id = (int)($_POST['id'] ?? 0);
        $old = q_one("SELECT * FROM puzzle_tournaments WHERE id = ? AND kind = 'still'", [$id]);
        $ret = $back('tournaments', $id ? '&id=' . $id : '');
        if (!$old || $old['status'] !== 'live') { flash('Only a live tournament can be settled.', 'err'); redirect($ret); }
        if (strtotime($old['ends_at'] . ' UTC') > time()) { q('UPDATE puzzle_tournaments SET ends_at = ? WHERE id = ?', [now(), $id]); $old['ends_at'] = now(); }
        $done = puzzle_settle_one($old);
        admin_log('jigsaw_settle', 'puzzle_tournaments#' . $id, 'settled now');
        flash($done ? 'Settled. Places and badges are out.' : 'It was already settled.');
        redirect($ret);
    }
    if ($do === 'void') admin_puzzle_ui_void(fn(string $extra) => $back('tournaments', $extra), 'still');
    redirect($back($tab));
}

$local = fn(?string $utc) => $utc ? puzzle_local($utc, 'Y-m-d\TH:i') : '';
page_header('Jigsaw', true);
admin_crumbs('jigsaw.php');
?>
<h1>🧩 Jigsaw</h1>
<p class="help">Jigsaw for players: <b><?= jigsaw_open() && setting('jigsaw_open') === '1' ? 'open' : 'admins only' ?></b> · tournaments: <b><?= setting('jigsaw_tournaments') === '1' ? 'on' : 'off' ?></b>
  (see <a href="<?= e(url('admin/jigsaw.php?tab=settings')) ?>">Settings</a>). <a href="<?= e(url('jigsaw.php')) ?>">Open Jigsaw</a> · <a href="<?= e(url('puzzles.php')) ?>">Puzzles hub</a>.</p>
<nav class="tabs">
  <a class="tab<?= $tab === 'library' ? ' on' : '' ?>" href="<?= e(url('admin/jigsaw.php')) ?>">🖼️ Library</a>
  <a class="tab<?= $tab === 'upload' ? ' on' : '' ?>" href="<?= e(url('admin/jigsaw.php?tab=upload')) ?>">⬆️ Upload</a>
  <a class="tab<?= $tab === 'tournaments' ? ' on' : '' ?>" href="<?= e(url('admin/jigsaw.php?tab=tournaments')) ?>">🏆 Tournaments</a>
  <a class="tab<?= $tab === 'settings' ? ' on' : '' ?>" href="<?= e(url('admin/jigsaw.php?tab=settings')) ?>">⚙️ Settings</a>
</nav>

<?php if ($tab === 'library'):
    $pics = jigsaw_pics(false);
    $solves = []; $used = [];
    foreach (q("SELECT pic_id, size, COUNT(*) AS n FROM puzzle_runs WHERE game = 'jigsaw' AND status = 'done' AND pic_id IS NOT NULL GROUP BY pic_id, size")->fetchAll() as $r) $solves[(int)$r['pic_id']][jigsaw_tier_for((int)$r['size'])] = (int)$r['n'];
    foreach (q('SELECT pic_id, COUNT(*) AS n FROM puzzle_tournaments GROUP BY pic_id')->fetchAll() as $r) $used[(int)$r['pic_id']] = (int)$r['n'];
    $gallery = array_filter($pics, fn($p) => $p['source'] !== 'place');
    $places = array_filter($pics, fn($p) => $p['source'] === 'place');
    $counts = function (array $p) use ($solves, $used): string {
        $s = $solves[(int)$p['id']] ?? [];
        $h = '';
        foreach (JIGSAW_TIERS as $k => $tt) $h .= $tt[4] . ' ' . (int)($s[$k] ?? 0) . ' ';
        return trim($h) . ' · ' . (int)($used[(int)$p['id']] ?? 0) . ' tournament' . ((int)($used[(int)$p['id']] ?? 0) === 1 ? '' : 's');
    }; ?>
<p class="help">Free-play solves are counted per tier (<?= e(implode(' ', array_map(fn($t) => $t[4] . ' ' . $t[0], JIGSAW_TIERS))) ?>). A <b>reserved</b> picture stays out of free play until its tournaments are settled
  (then it joins the library<?= jigsaw_reserve_days() ? ' after ' . jigsaw_reserve_days() . ' day' . (jigsaw_reserve_days() === 1 ? '' : 's') : ' at once' ?>).</p>
<table class="grid">
  <tr><th>Picture</th><th>Title</th><th>Category</th><th>Order</th><th>On</th><th>Reserved</th><th>Solves · used</th><th></th></tr>
  <?php foreach ($gallery as $p): ?>
  <tr><form method="post"><?= csrf_field() ?><input type="hidden" name="do" value="pic_save"><input type="hidden" name="id" value="<?= (int)$p['id'] ?>">
    <td><img src="<?= e(url(jigsaw_path($p, true))) ?>" alt="" width="64" loading="lazy"></td>
    <td><input type="text" name="title" maxlength="80" value="<?= e($p['title']) ?>" required><br><small class="help"><?= e($p['slug']) ?> · <?= $p['source'] === 'upload' ? 'uploaded' : 'built in' ?></small></td>
    <td><select name="cat"><option value="">–</option><?php foreach (JIGSAW_CATS as $c): ?><option<?= (string)$p['cat'] === $c ? ' selected' : '' ?>><?= e($c) ?></option><?php endforeach; ?></select></td>
    <td><input type="number" name="sort" value="<?= (int)$p['sort'] ?>" class="qty"></td>
    <td><input type="checkbox" name="active" value="1"<?= (int)$p['active'] ? ' checked' : '' ?>></td>
    <td><input type="checkbox" name="reserved" value="1"<?= (int)$p['reserved'] ? ' checked' : '' ?>></td>
    <td><small><?= e($counts($p)) ?></small></td>
    <td><button class="btn small">Save</button></td></form></tr>
  <?php endforeach; ?>
</table>
<?php if (!$gallery): ?><p>No pictures yet.</p><?php endif; ?>
<?php if ($places): ?>
<details id="places"><summary><b>🗺️ Places (<?= count($places) ?>)</b> <small class="muted">cut from the unique-location scenes; each unlocks for a gnome on their first visit. Only on / off can change here.</small></summary>
<table class="grid">
  <tr><th>Picture</th><th>Place</th><th>On</th><th>Solves · used</th><th></th></tr>
  <?php foreach ($places as $p): ?>
  <tr><form method="post"><?= csrf_field() ?><input type="hidden" name="do" value="place_active"><input type="hidden" name="id" value="<?= (int)$p['id'] ?>">
    <td><img src="<?= e(url(jigsaw_path($p, true))) ?>" alt="" width="64" loading="lazy"></td>
    <td><?= e($p['title']) ?></td>
    <td><input type="checkbox" name="active" value="1"<?= (int)$p['active'] ? ' checked' : '' ?>></td>
    <td><small><?= e($counts($p)) ?></small></td>
    <td><button class="btn small">Save</button></td></form></tr>
  <?php endforeach; ?>
</table>
</details>
<?php endif; ?>

<?php elseif ($tab === 'upload'): ?>
<div class="box">
  <p class="help"><b>Still pictures for Jigsaw, exactly 3:2.</b> JPEG, PNG or WEBP up to 3 MB, at least 1500 × 1000 and at most 3000 × 2000, with a width to height ratio of 3:2 within 1% (no silent cropping: a picture that is off is refused with its numbers).
    Each is re-saved as a 1800 × 1200 JPEG (metadata stripped) with a 450 × 300 thumbnail. The server’s upload limit is <?= e((string)ini_get('upload_max_filesize')) ?> a file. Up to <?= JIGSAW_UP_MAX_FILES ?> at once<?= (int)ini_get('max_file_uploads') && (int)ini_get('max_file_uploads') < JIGSAW_UP_MAX_FILES ? ' (this server allows ' . (int)ini_get('max_file_uploads') . ' per upload)' : '' ?>. New pictures start switched off.
    <?= function_exists('imagecreatefromjpeg') ? '' : ' <b>This server has no GD, so uploads are refused.</b>' ?></p>
  <form method="post" enctype="multipart/form-data" class="stack"><?= csrf_field() ?><input type="hidden" name="do" value="upload">
    <label>Pictures <input type="file" name="pics[]" accept="image/jpeg,image/png,image/webp" multiple required></label>
    <label>Title <small class="muted">(for a single picture; with several, each takes its file name)</small> <input type="text" name="title" maxlength="80"></label>
    <label>Category <select name="cat"><option value="">–</option><?php foreach (JIGSAW_CATS as $c): ?><option><?= e($c) ?></option><?php endforeach; ?></select></label>
    <label><input type="checkbox" name="reserved" value="1"> Reserve for a tournament (hidden from free play until its tournament settles)</label>
    <button class="btn">Upload</button>
  </form>
</div>

<?php elseif ($tab === 'settings'): ?>
<div class="box">
  <h2>Settings</h2>
  <p class="help">These live in <a href="<?= e(url('admin/settings.php')) ?>">Admin &gt; Settings</a> (look for “Jigsaw”). Current values:</p>
  <table class="grid">
    <?php foreach (['jigsaw_open', 'jigsaw_tournaments', 'jigsaw_tries_easy', 'jigsaw_tries_advanced', 'jigsaw_tries_expert', 'jigsaw_reserve_days'] as $k): ?>
    <tr><td><code><?= e($k) ?></code></td><td><b><?= e(setting($k)) ?></b></td></tr>
    <?php endforeach; ?>
  </table>
  <p><a class="btn" href="<?= e(url('admin/settings.php')) ?>">Open Settings</a></p>
</div>

<?php else:
    $tid = (int)($_GET['id'] ?? 0);
    $cur = $tid ? q_one("SELECT * FROM puzzle_tournaments WHERE id = ? AND kind = 'still'", [$tid]) : null;
    $fs = (string)($_GET['status'] ?? '');
    $ft = (string)($_GET['tier'] ?? '');
    $w = "t.kind = 'still'"; $a = [];
    if (in_array($fs, ['draft', 'live', 'settled'], true)) { $w .= ' AND t.status = ?'; $a[] = $fs; }
    if (isset(JIGSAW_TIERS[$ft])) { $w .= ' AND t.tier = ?'; $a[] = $ft; }
    $all = q("SELECT t.*, p.title AS pic_title, (SELECT COUNT(DISTINCT user_id) FROM puzzle_attempts a WHERE a.tournament_id = t.id) AS players FROM puzzle_tournaments t JOIN puzzle_pics p ON p.id = t.pic_id WHERE $w ORDER BY t.starts_at DESC, t.id DESC LIMIT 60", $a)->fetchAll();
    $pics = q("SELECT * FROM puzzle_pics WHERE kind = 'still' AND source <> 'place' ORDER BY sort, id")->fetchAll();
    $f = $cur ?: ['id' => 0, 'title' => '', 'pic_id' => 0, 'tier' => 'easy', 'pieces' => 24, 'starts_at' => gmdate('Y-m-d H:00:00', time() + 3600), 'ends_at' => gmdate('Y-m-d H:00:00', time() + 7 * 86400), 'status' => 'draft']; ?>
<form method="get" class="inline"><input type="hidden" name="tab" value="tournaments">
  <label>Status <select name="status"><option value="">All</option><?php foreach (['draft', 'live', 'settled'] as $s): ?><option<?= $fs === $s ? ' selected' : '' ?>><?= $s ?></option><?php endforeach; ?></select></label>
  <label>Tier <select name="tier"><option value="">All</option><?php foreach (JIGSAW_TIERS as $k => $tt): ?><option value="<?= e($k) ?>"<?= $ft === $k ? ' selected' : '' ?>><?= e($tt[0]) ?></option><?php endforeach; ?></select></label>
  <button class="btn small">Filter</button></form>
<?php admin_puzzle_ui_tour_list($all, $tid, 'admin/jigsaw.php', true); ?>

<?php
    ob_start(); ?>
    <fieldset class="pztierpick"><legend>Tier (sets the pieces, never typed in)</legend>
      <?php foreach (JIGSAW_TIERS as $k => $tt): ?><label><input type="radio" name="tier" value="<?= e($k) ?>"<?= (string)$f['tier'] === $k ? ' checked' : '' ?> required> <?= $tt[4] ?> <?= e($tt[0]) ?> · <?= $tt[1] * $tt[2] ?> pieces (<?= $tt[1] ?> × <?= $tt[2] ?>) · <?= jigsaw_tries($k) ?> goes a day</label><br><?php endforeach; ?>
    </fieldset>
<?php $tierField = (string)ob_get_clean();
    ob_start(); ?>
    <p class="help">Everyone gets the same scramble. Best time counts. A run handed in faster than <?= PUZZLE_MIN_MS_PER_PIECE / 1000 ?> s a piece, with fewer drops than pieces − 1, or more than <?= PUZZLE_GRACE_S / 60 ?> minutes after the end is rejected.
      Results are settled <?= PUZZLE_GRACE_S / 60 ?> minutes after the end: 🏆 gold, silver, bronze and an “entered” badge (cosmetic only). Only gallery pictures can be used (never a Places picture). Reserve the picture in the Library first if you don’t want players practising it.</p>
<?php $helpHtml = (string)ob_get_clean();
    $btns = '<button class="btn">Save</button>' . ($cur ? '' : ' <button class="btn" name="do" value="tour_cup" title="Three tournaments (Easy, Advanced, Expert) with the same picture, times and status">Make all three tiers</button>');
    $hid = $cur ? '<input type="hidden" name="do" value="tour_save"><input type="hidden" name="id" value="' . (int)$f['id'] . '">' : '<input type="hidden" name="id" value="0">';
    // a new tournament has no hidden "do": the two buttons carry it (Save = tour_save, the cup button = tour_cup)
    if (!$cur) $btns = '<button class="btn" name="do" value="tour_save">Save</button> <button class="btn" name="do" value="tour_cup" title="Three tournaments (Easy, Advanced, Expert) with the same picture, times and status">Make all three tiers</button>';
    admin_puzzle_ui_tour_form($f, $cur, $pics, $tierField, $hid, $btns, $helpHtml, function (array $p): string {
        return ((int)$p['active'] ? '' : ' (off)') . ((int)$p['reserved'] ? ' (reserved)' : ' (in free play)');
    }); ?>

<?php if ($cur): ?>
<div class="box">
  <h2>Actions</h2>
  <div class="inline">
    <form method="post" class="inline"><?= csrf_field() ?><input type="hidden" name="do" value="tour_dup"><input type="hidden" name="id" value="<?= $tid ?>"><button class="btn small">Duplicate</button></form>
    <?php if ($cur['status'] !== 'settled'): ?>
    <?php if ($cur['status'] === 'live'): ?><form method="post" class="inline"><?= csrf_field() ?><input type="hidden" name="do" value="tour_settle"><input type="hidden" name="id" value="<?= $tid ?>"><button class="btn small">Settle now</button></form><?php endif; ?>
    <form method="post" class="inline"><?= csrf_field() ?><input type="hidden" name="do" value="tour_cancel"><input type="hidden" name="id" value="<?= $tid ?>"><button class="btn small danger">Cancel (void all runs, no places)</button></form>
    <?php endif; ?>
    <a class="btn small" href="<?= e(url('admin/jigsaw.php?tab=tournaments&id=' . $tid . '&csv=1')) ?>">Download results (CSV)</a>
  </div>
</div>
<?php admin_puzzle_ui_detail($cur); ?>
<?php endif; ?>
<?php endif; ?>
<?php page_footer();
