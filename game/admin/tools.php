<?php
declare(strict_types=1);
// Admin tools (v0.7.16): database backups and the outgoing mail log.
require dirname(__DIR__) . '/includes/bootstrap.php';
require dirname(__DIR__) . '/includes/admin_helpers.php';
$me = require_admin();
global $CONFIG;
$driver = (string)($CONFIG['db']['driver'] ?? 'mysql');

/** Every table in the database. */
function all_tables(string $driver): array
{
    return $driver === 'sqlite'
        ? q("SELECT name FROM sqlite_master WHERE type = 'table' AND name NOT LIKE 'sqlite_%' ORDER BY name")->fetchAll(PDO::FETCH_COLUMN)
        : q('SHOW TABLES')->fetchAll(PDO::FETCH_COLUMN);
}

if (is_post()) {
    csrf_check();
    $do = (string)($_POST['do'] ?? '');
    if ($do === 'dump') {
        @set_time_limit(300);
        // Build the whole file first, so a failure becomes an error message, not a cut-off download that looks fine.
        $tmp = APP_ROOT . '/data/backup-' . bin2hex(random_bytes(6)) . '.sql';
        try {
            $pdo = db();
            $fh = fopen($tmp, 'wb');
            if (!$fh) throw new RuntimeException('Could not write to the data folder.');
            $w = function (string $s) use ($fh): void { if (fwrite($fh, $s) === false) throw new RuntimeException('Disk write failed (disk full?).'); };
            $w("-- Gnome Venture backup, v" . APP_VERSION . ", " . now() . " UTC\n-- Restore into an EMPTY database after running install, or with phpMyAdmin's Import.\n\n");
            $nt = 0;
            foreach (all_tables($driver) as $t) {
                if (!preg_match('/^[A-Za-z0-9_]+$/', $t)) continue;
                $w("DELETE FROM $t;\n");
                $st = $pdo->query("SELECT * FROM $t");
                while ($row = $st->fetch(PDO::FETCH_ASSOC)) {
                    $vals = array_map(fn($v) => $v === null ? 'NULL' : $pdo->quote((string)$v), array_values($row));
                    $w('INSERT INTO ' . $t . ' (' . implode(', ', array_keys($row)) . ') VALUES (' . implode(', ', $vals) . ");\n");
                }
                $w("\n");
                $nt++;
            }
            if ($nt === 0) throw new RuntimeException('No tables found.');
            $w("-- END OF BACKUP ($nt tables)\n");
            if (!fclose($fh)) throw new RuntimeException('Could not finish writing the backup.');
        } catch (Throwable $e) {
            @unlink($tmp);
            error_log('Backup failed: ' . $e->getMessage());
            flash('Backup FAILED: ' . $e->getMessage() . ' Nothing was downloaded.', 'err');
            redirect('admin/tools.php');
        }
        admin_log('backup', 'sql', '');
        header('Content-Type: application/sql; charset=utf-8');
        header('Content-Disposition: attachment; filename="sproutling-backup-' . gmdate('Y-m-d-His') . '.sql"');
        header('Content-Length: ' . filesize($tmp));
        header('X-Content-Type-Options: nosniff');
        readfile($tmp);
        @unlink($tmp);
        exit;
    }
    if ($do === 'sqlite' && $driver === 'sqlite') {
        $tmp = APP_ROOT . '/data/backup-' . bin2hex(random_bytes(6)) . '.sqlite';
        try {
            db()->exec('VACUUM INTO ' . db()->quote($tmp));   // a clean, consistent copy even while the game is running
            if (!is_file($tmp) || filesize($tmp) < 1) throw new RuntimeException('The copy came out empty.');
        } catch (Throwable $e) {
            @unlink($tmp);
            error_log('SQLite backup failed: ' . $e->getMessage());
            flash('Backup FAILED: ' . $e->getMessage() . ' Nothing was downloaded.', 'err');
            redirect('admin/tools.php');
        }
        admin_log('backup', 'sqlite', '');
        header('Content-Type: application/octet-stream');
        header('Content-Disposition: attachment; filename="sproutling-' . gmdate('Y-m-d-His') . '.sqlite"');
        header('Content-Length: ' . filesize($tmp));
        readfile($tmp);
        @unlink($tmp);
        exit;
    }
    if ($do === 'delete_image') {
        $name = (string)($_POST['name'] ?? '');
        if (preg_match('/^[a-f0-9]{24}\.(png|jpg|gif|webp)$/', $name) && is_file(APP_ROOT . '/uploads/' . $name)) {
            if (@unlink(APP_ROOT . '/uploads/' . $name)) {
                admin_log('delete_upload', $name, '');
                flash('Image deleted. (Any post still using it will just skip it.)');
            } else {
                flash('Could not delete that image (file permissions?).', 'err');
            }
        } else {
            flash('Image not found, nothing deleted.', 'err');
        }
        redirect('admin/tools.php#images');
    }
    if ($do === 'test_event') {
        $_SESSION['event_force'] = 1;   // the next game page you open shows a random event
        flash('Open any game page and a random event will happen.');
        redirect('admin/tools.php');
    }
    if ($do === 'test_ppal') {   // v2.2.4: pals wait on the map: put one on yours (with nothing released it releases the first picture with a roster)
        require_once __DIR__ . '/../includes/puzzle_pals.php';
        $msg = ppal_admin_spawn(current_user() ?: []);
        flash($msg, str_contains($msg, ' now waits at ') ? 'ok' : 'err');
        redirect('admin/tools.php');
    }
    if ($do === 'clear_errors') {
        $okc = @file_put_contents(APP_ROOT . '/data/error-log.txt', '') !== false;
        if (is_file(APP_ROOT . '/data/error-log.txt.1')) $okc = @unlink(APP_ROOT . '/data/error-log.txt.1') && $okc;
        flash($okc ? 'Error log cleared.' : 'Could not clear the error log (file permissions?).', $okc ? 'ok' : 'err');
        redirect('admin/tools.php#errors');
    }
    if ($do === 'clear_mail') {
        $okc = @file_put_contents(APP_ROOT . '/data/mail-log.txt', '') !== false;
        flash($okc ? 'Mail log cleared.' : 'Could not clear the mail log (file permissions?).', $okc ? 'ok' : 'err');
        redirect('admin/tools.php');
    }
}

$log = is_file(APP_ROOT . '/data/mail-log.txt') ? (string)file_get_contents(APP_ROOT . '/data/mail-log.txt', false, null, max(0, filesize(APP_ROOT . '/data/mail-log.txt') - 20000)) : '';
// v1.6.x: the rotated file (error-log.txt.1) too, read only; both read from the end (last ~200 KB)
$tailOf = function (string $f): string { return is_file($f) ? (string)file_get_contents($f, false, null, max(0, (int)filesize($f) - 200000)) : ''; };
$errLog = $tailOf(APP_ROOT . '/data/error-log.txt');
$errLogOld = $tailOf(APP_ROOT . '/data/error-log.txt.1');
page_header('Tools', true);
?>
<?php admin_crumbs('tools.php');   // v1.6.3 ?>
<h1>🧰 Tools</h1>
<div class="box">
  <h2>Backups</h2>
  <p>Download a copy of the whole game database. Keep backups somewhere safe (not on the web host). Many hosts also offer automatic backups in their control panel; turn those on too.</p>
  <form method="post" class="inline"><?= csrf_field() ?><input type="hidden" name="do" value="dump"><button class="btn small">Download SQL backup</button></form>
  <?php if ($driver === 'sqlite'): ?>
    <form method="post" class="inline"><?= csrf_field() ?><input type="hidden" name="do" value="sqlite"><button class="btn small">Download the SQLite world file</button></form>
    <p class="help">On your PC, the world file is the simplest backup: put it back as <code>game/data/game.sqlite</code> to restore.</p>
  <?php else: ?>
    <p class="help">To restore: in phpMyAdmin, choose the game’s database and use Import with the .sql file.</p>
  <?php endif; ?>
</div>
<div class="box">
  <h2>Random events</h2>
  <p class="help">Events happen about once every <?= (int)setting('event_chance') ?> page views, at least <?= (int)setting('event_cooldown_minutes') ?> minutes apart,
    at most <?= (int)setting('event_daily_max') ?> a day (change these in Game settings). Edit the events themselves in <a href="<?= e(url('admin/crud.php?r=random_events')) ?>">Random events</a>.</p>
  <form method="post"><?= csrf_field() ?><input type="hidden" name="do" value="test_event"><button class="btn small">🎲 Show me one on my next page</button></form>
  <form method="post"><?= csrf_field() ?><input type="hidden" name="do" value="test_ppal"><button class="btn small">🧩 Test a pal find</button> <small class="muted">Puzzle Pals: puts one pal on your map now.</small></form>
</div>
<div class="box" id="images">
  <h2>Images</h2>
  <p class="help">Upload pictures for news and pages (PNG, JPEG, GIF or WebP, up to 2 MB). The 🖼 button in the news editor does this too.
    Then put the code shown under a picture into a post.</p>
  <form method="post" action="<?= e(url('admin/upload.php')) ?>" enctype="multipart/form-data" class="inline"><?= csrf_field() ?>
    <input type="file" name="image" accept="image/png,image/jpeg,image/gif,image/webp" required> <button class="btn small">Upload</button></form>
  <?php // scandir, not glob braces: works the same on every host
  $imgs = is_dir(APP_ROOT . '/uploads') ? array_values(array_filter(scandir(APP_ROOT . '/uploads') ?: [], fn($f) => preg_match('/^[a-f0-9]{24}\.(png|jpg|gif|webp)$/', $f))) : [];
  usort($imgs, fn($a, $b) => filemtime(APP_ROOT . '/uploads/' . $b) <=> filemtime(APP_ROOT . '/uploads/' . $a)); ?>
  <?php if ($imgs): ?>
    <div class="imggrid">
      <?php foreach (array_slice($imgs, 0, 60) as $b): ?>
        <figure><img src="<?= e(url('uploads/' . $b)) ?>" alt="" loading="lazy">
          <figcaption><code>[img]uploads/<?= e($b) ?>[/img]</code>
            <form method="post" data-confirm="Delete this image?"><?= csrf_field() ?><input type="hidden" name="do" value="delete_image"><input type="hidden" name="name" value="<?= e($b) ?>"><button class="linkbtn">Delete</button></form></figcaption></figure>
      <?php endforeach; ?>
    </div>
  <?php else: ?><p class="muted">No images yet.</p><?php endif; ?>
</div>
<div class="box" id="trailmaps">
  <h2>Trail maps check</h2>
  <?php
  require_once APP_ROOT . '/includes/trail_art.php';
  $tmFile = APP_ROOT . '/includes/data/trail_maps.json';
  $tmJson = is_file($tmFile) ? json_decode((string)file_get_contents($tmFile), true) : null;
  $tmAll = trail_authored_all();
  $tmGround = glob(APP_ROOT . '/assets/img/trail/ground/*.png') ?: [];
  ?>
  <p class="help">Version <b><?= e(APP_VERSION) ?></b>. Tile walks: gnav_on <b><?= e((string)setting('gnav_on')) ?></b>, gnav_tiles <b><?= e((string)setting('gnav_tiles')) ?></b>.
    trail_maps.json: <?= is_file($tmFile) ? e(number_format((int)filesize($tmFile))) . ' bytes, saved ' . e(gmdate('Y-m-d H:i', (int)filemtime($tmFile))) . ' UTC, ' . (is_array($tmJson) ? 'reads fine' : '<b>does NOT read (' . e(json_last_error_msg()) . ')</b>') : '<b>missing</b>' ?>.
    Authored routes the game loads: <b><?= count($tmAll) ?></b> (a full 2.5.90 has 246). Ground pictures on disk: <b><?= count($tmGround) ?></b> (a full 2.5.90 has 666 or more).</p>
  <table class="list"><tr><th>Route</th><th>Authored?</th><th>Sections</th><th>Ground pictures present</th></tr>
  <?php foreach ([228 => 'Maplewold Market to Poppyburrow', 256 => 'Mistmoor Market to Larkden', 238 => 'Honeythorpe to Clovercove', 444 => 'Clovercove to The Thousand Gates'] as $rid => $nm): $r = $tmAll[(string)$rid] ?? null; $n = $r ? count($r['sections']) : 0; $have = 0; for ($i = 1; $i <= $n; $i++) if (is_file(APP_ROOT . '/assets/img/trail/ground/' . $rid . '-' . $i . '.png')) $have++; ?>
    <tr><td><?= $rid ?> <?= e($nm) ?></td><td><?= $r ? 'yes' : '<b>NO</b>' ?></td><td><?= $n ?></td><td><?= $have ?> of <?= $n ?></td></tr>
  <?php endforeach; ?></table>
</div>
<div class="box" id="errors">
  <h2>Error log</h2>
  <p class="help">When a page breaks, the details land here (newest at the bottom). Copy the last entry and send it to whoever is fixing the game.</p>
  <?php if ($errLog !== ''): ?>
    <p><button type="button" class="btn small" data-copy-from="errlog">📋 Copy all</button></p>
    <pre class="maillog" id="errlog"><?= e($errLog) ?></pre>
    <form method="post"><?= csrf_field() ?><input type="hidden" name="do" value="clear_errors"><button class="btn small alt">Clear the log</button></form>
  <?php else: ?><p class="muted">No errors. 🌿</p><?php endif; ?>
  <?php if ($errLogOld !== ''): ?>
    <details><summary class="btn small alt">Older log (error-log.txt.1)</summary>
      <pre class="maillog"><?= e($errLogOld) ?></pre></details>
  <?php endif; ?>
</div>
<div class="box">
  <h2>Mail log</h2>
  <p class="help">Emails that couldn’t be sent (or all of them, when “mail_mode” is “log”) are written here. Handy on your PC for password-reset links.
    Links use the address in Game settings → site_url: <code><?= e(setting('site_url') ?: '(not set!)') ?></code></p>
  <?php if ($log !== ''): ?>
    <pre class="maillog"><?= e($log) ?></pre>
    <form method="post"><?= csrf_field() ?><input type="hidden" name="do" value="clear_mail"><button class="btn small alt">Clear the log</button></form>
  <?php else: ?><p class="muted">Empty.</p><?php endif; ?>
</div>
<?php page_footer();
