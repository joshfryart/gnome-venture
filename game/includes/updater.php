<?php
declare(strict_types=1);

/**
 * Updating the game from the admin panel (v0.7.40).
 *
 * Upload an update zip → it's checked (a real Gnome Venture build, its version, safe file names and types) → on
 * "Install", the database and the current program files are backed up into data/backups/, then each file is
 * written over the old one (to a temporary name first, then swapped in). The next page load upgrades the database
 * as usual. Never touched: config.php, install.php, data/ and uploads/. Older builds can be restored from the
 * file backups.
 */

const UPDATE_MAX_BYTES = 60 * 1024 * 1024;
const UPDATE_KEEP_BACKUPS = 5;   // database dumps kept
const UPDATE_KEEP_FILE_BACKUPS = 2;   // program zips are big, so fewer
/** Files from older versions that are gone now; an update removes them (v0.7.50). Fixed list, never from the zip. */
const UPDATE_OBSOLETE = ['npc.php', 'mod.php'];
const UPDATE_EXT = ['php', 'css', 'js', 'txt', 'md', 'png', 'jpg', 'jpeg', 'gif', 'webp', 'svg', 'ico', 'json', 'woff', 'woff2'];

function update_dir(string $sub = ''): string
{
    $d = APP_ROOT . '/data/' . $sub;
    if (!is_dir($d)) @mkdir($d, 0755, true);
    if ($sub !== '' && !is_file($d . '/.htaccess')) @file_put_contents($d . '/.htaccess', "Require all denied\nDeny from all\n");
    return $d;
}

/** Is this path (relative to the game folder) something an update may write? */
function update_path_ok(string $rel): bool
{
    if ($rel === '' || str_contains($rel, "\0") || str_contains($rel, '\\') || str_contains($rel, '..') || $rel[0] === '/' || preg_match('~(^|/)\.(?!htaccess$)~', $rel)) return false;
    if (in_array($rel, ['config.php', 'install.php'], true)) return false;
    if (str_starts_with($rel, 'data/') || str_starts_with($rel, 'uploads/')) return false;
    $base = basename($rel);
    if ($base === '.htaccess') return true;
    // v0.7.50: program code only where the game keeps it (never in assets/ or other folders)
    if (strtolower(pathinfo($base, PATHINFO_EXTENSION)) === 'php' && !preg_match('~^(admin/|includes/(data/)?)?[a-z0-9_-]+\.php$~', $rel)) return false;
    return in_array(strtolower(pathinfo($base, PATHINFO_EXTENSION)), UPDATE_EXT, true);
}

/** The version written in a bootstrap.php. */
function update_version_of(string $php): ?string
{
    return preg_match("/define\\('APP_VERSION', '([0-9.]+)'\\)/", $php, $m) ? $m[1] : null;
}

/** Compare to the files on disk. Returns everything the admin page needs to show, or ['error' => …]. */
function update_inspect(string $zipPath): array
{
    if (!class_exists('ZipArchive')) return ['error' => 'This server’s PHP can’t open zip files (the "zip" extension is off). Ask your host to turn it on, or update by hand.'];
    $z = new ZipArchive();
    if ($z->open($zipPath) !== true) return ['error' => 'That isn’t a zip file, or it’s damaged.'];
    // Find the game folder inside the zip: the one holding includes/bootstrap.php (works for the web-update and Windows zips)
    $root = null;
    for ($i = 0; $i < $z->numFiles; $i++) {
        $n = (string)$z->getNameIndex($i);
        if (preg_match('~^((?:[^/]+/){0,3})includes/bootstrap\.php$~', $n, $m)) {
            if ($root === null || strlen($m[1]) < strlen($root)) $root = $m[1];
        }
    }
    if ($root === null) { $z->close(); return ['error' => 'This doesn’t look like a Gnome Venture update: there’s no includes/bootstrap.php inside.']; }
    $version = update_version_of((string)$z->getFromName($root . 'includes/bootstrap.php'));
    if (!$version) { $z->close(); return ['error' => 'Couldn’t find the version number in that update.']; }
    $files = [];
    $skipped = [];
    $new = $changed = $same = 0;
    $total = 0;
    $needs = null;
    for ($i = 0; $i < $z->numFiles; $i++) {
        $st = $z->statIndex($i);
        $n = (string)$st['name'];
        if (!str_starts_with($n, $root) || str_ends_with($n, '/')) continue;
        $rel = substr($n, strlen($root));
        if ($rel === 'UPDATE-BASE.txt') {   // v0.7.82: a slim update names the oldest installed version it can go on top of (never written to the site)
            $needs = trim((string)$z->getFromIndex($i));
            continue;
        }
        if (!update_path_ok($rel)) {
            if (!preg_match('~^(data|uploads)/~', $rel) && !in_array($rel, ['config.php', 'install.php'], true)) $skipped[] = $rel;
            continue;
        }
        $total += (int)$st['size'];
        if ($total > 200 * 1024 * 1024) { $z->close(); return ['error' => 'That update is far too big once unpacked.']; }
        $files[$rel] = $i;
        $disk = APP_ROOT . '/' . $rel;
        if (!is_file($disk)) $new++;
        elseif (filesize($disk) !== (int)$st['size'] || hash_file('crc32b', $disk) !== sprintf('%08x', $st['crc'] & 0xFFFFFFFF)) $changed++;
        else $same++;
    }
    $z->close();
    if (!isset($files['includes/bootstrap.php'], $files['index.php'])) return ['error' => 'That update is missing some of the game’s main files.'];
    if ($needs !== null && !preg_match('/^\d+\.\d+\.\d+$/', $needs)) $needs = null;
    return ['version' => $version, 'root' => $root, 'files' => $files, 'new' => $new, 'changed' => $changed, 'same' => $same, 'skipped' => $skipped,
        'needs' => $needs];   // v0.7.82: null = a full update
}

/** Can PHP write the game's files here? Returns a list of folders it can't write to. */
function update_unwritable(): array
{
    $bad = [];
    foreach (['', 'includes', 'includes/data', 'assets', 'admin', 'data'] as $d) {
        $p = APP_ROOT . ($d === '' ? '' : '/' . $d);
        if (is_dir($p) && !is_writable($p)) $bad[] = $d === '' ? '(the main game folder)' : $d;
    }
    return $bad;
}

/** Write the whole database as SQL to a file (same format as Admin → Tools → backup). */
function update_backup_db(string $path): void
{
    global $CONFIG;
    $driver = (string)($CONFIG['db']['driver'] ?? 'mysql');
    $pdo = db();
    $fh = fopen($path, 'wb');
    if (!$fh) throw new RuntimeException('Couldn’t write the database backup.');
    fwrite($fh, '-- Gnome Venture backup, v' . APP_VERSION . ', ' . now() . " UTC (made automatically before an update)\n\n");
    $tables = $driver === 'sqlite'
        ? $pdo->query("SELECT name FROM sqlite_master WHERE type = 'table' AND name NOT LIKE 'sqlite_%' ORDER BY name")->fetchAll(PDO::FETCH_COLUMN)
        : $pdo->query('SHOW TABLES')->fetchAll(PDO::FETCH_COLUMN);
    foreach ($tables as $t) {
        if (!preg_match('/^[A-Za-z0-9_]+$/', (string)$t)) continue;
        fwrite($fh, "DELETE FROM $t;\n");
        $st = $pdo->query("SELECT * FROM $t");
        while ($row = $st->fetch(PDO::FETCH_ASSOC)) {
            $vals = array_map(fn($v) => $v === null ? 'NULL' : $pdo->quote((string)$v), array_values($row));
            fwrite($fh, 'INSERT INTO ' . $t . ' (' . implode(', ', array_keys($row)) . ') VALUES (' . implode(', ', $vals) . ");\n");
        }
        fwrite($fh, "\n");
    }
    fclose($fh);
}

/** Zip up the current program files (the same kinds of file an update writes). */
function update_backup_files(string $path): int
{
    $z = new ZipArchive();
    if ($z->open($path, ZipArchive::CREATE | ZipArchive::OVERWRITE) !== true) throw new RuntimeException('Couldn’t write the files backup.');
    $n = 0;
    $it = new RecursiveIteratorIterator(new RecursiveDirectoryIterator(APP_ROOT, FilesystemIterator::SKIP_DOTS));
    foreach ($it as $f) {
        if (!$f->isFile()) continue;
        $rel = str_replace('\\', '/', substr($f->getPathname(), strlen(APP_ROOT) + 1));
        if (!update_path_ok($rel)) continue;
        $z->addFile($f->getPathname(), $rel);
        $n++;
    }
    $z->close();
    return $n;
}

/** Write the files from a zip over the game. Returns how many were written. */
function update_write_files(string $zipPath, string $root, array $files): int
{
    $z = new ZipArchive();
    if ($z->open($zipPath) !== true) throw new RuntimeException('Couldn’t open the update.');
    $n = 0;
    // bootstrap.php last, so the version only changes once everything else is in place
    uksort($files, fn($a, $b) => ($a === 'includes/bootstrap.php') <=> ($b === 'includes/bootstrap.php') ?: strcmp($a, $b));
    foreach ($files as $rel => $idx) {
        if (!update_path_ok($rel)) continue;
        $data = $z->getFromIndex($idx);
        if ($data === false) throw new RuntimeException('Couldn’t read ' . $rel . ' from the update.');
        $dest = APP_ROOT . '/' . $rel;
        $dir = dirname($dest);
        if (!is_dir($dir) && !@mkdir($dir, 0755, true)) throw new RuntimeException('Couldn’t make the folder for ' . $rel . '.');
        $tmp = $dest . '.upd-' . bin2hex(random_bytes(4));
        if (@file_put_contents($tmp, $data) !== strlen($data)) { @unlink($tmp); throw new RuntimeException('Couldn’t write ' . $rel . '. Is the folder writable?'); }
        if (!@rename($tmp, $dest)) { @unlink($tmp); throw new RuntimeException('Couldn’t replace ' . $rel . '.'); }
        $n++;
    }
    $z->close();
    if (function_exists('opcache_reset')) @opcache_reset();   // make PHP load the new code straight away
    return $n;
}

/** Back everything up, then install the pending update. Returns [ok, message]. */
function update_install(array $admin, string $password, bool $allowOlder): array
{
    if (!password_verify($password, (string)q_val('SELECT password_hash FROM users WHERE id = ?', [$admin['id']]))) return [false, 'That password isn’t right.'];
    $zip = update_dir('update') . '/pending.zip';
    if (!is_file($zip)) return [false, 'There’s no update waiting. Upload one first.'];
    $info = update_inspect($zip);
    if (isset($info['error'])) return [false, $info['error']];
    if (version_compare($info['version'], APP_VERSION, '<') && !$allowOlder) return [false, 'That update is older than the game you’re running. Tick “install an older version” if you really mean to.'];
    if (!empty($info['needs']) && version_compare(APP_VERSION, $info['needs'], '<')) {   // v0.7.82: slim updates only go on top of a recent enough version
        return [false, 'This is a slim update with only the latest changes. It needs v' . $info['needs'] . ' or newer installed first (you have v' . APP_VERSION . '). Install the updates in between in order, or ask for a full update.'];
    }
    if ($bad = update_unwritable()) return [false, 'PHP can’t write to: ' . implode(', ', $bad) . '. Update by hand this time, or ask your host about file permissions.'];
    @set_time_limit(600);
    @ignore_user_abort(true);
    $stamp = gmdate('Ymd-His');
    $bdir = update_dir('backups');
    try {
        update_backup_db($bdir . '/db-v' . APP_VERSION . '-' . $stamp . '.sql');
        update_backup_files($bdir . '/files-v' . APP_VERSION . '-' . $stamp . '.zip');
    } catch (Throwable $e) {
        return [false, 'The backup failed, so nothing was changed: ' . $e->getMessage()];
    }
    try {
        $n = update_write_files($zip, $info['root'], $info['files']);
    } catch (Throwable $e) {
        admin_log('update_failed', $info['version'], $e->getMessage());
        return [false, 'The update stopped part-way: ' . $e->getMessage() . ' Use “Restore” below with the backup from just now to put the old files back.'];
    }
    @unlink($zip);
    foreach (UPDATE_OBSOLETE as $old) if (is_file(APP_ROOT . '/' . $old)) @unlink(APP_ROOT . '/' . $old);   // the backup above still has them
    update_prune();
    admin_log('update', APP_VERSION . ' → ' . $info['version'], $n . ' files');
    return [true, '⬆️ Updated to v' . $info['version'] . ' (' . $n . ' files). The database is being upgraded on this page load.'];
}

/** Put back the program files from one of the backups. */
function update_restore(array $admin, string $password, string $name): array
{
    if (!password_verify($password, (string)q_val('SELECT password_hash FROM users WHERE id = ?', [$admin['id']]))) return [false, 'That password isn’t right.'];
    if (!preg_match('/^files-v[0-9.]+-\d{8}-\d{6}\.zip$/', $name) || !is_file(update_dir('backups') . '/' . $name)) return [false, 'That backup isn’t there.'];
    $path = update_dir('backups') . '/' . $name;
    $info = update_inspect($path);
    if (isset($info['error'])) return [false, $info['error']];
    @set_time_limit(600);
    try {
        $n = update_write_files($path, $info['root'], $info['files']);
    } catch (Throwable $e) {
        return [false, 'The restore stopped part-way: ' . $e->getMessage()];
    }
    admin_log('update_restore', $name, $n . ' files');
    return [true, '↩️ Restored the files of v' . $info['version'] . ' (' . $n . ' files). The database keeps any newer tables and columns; that’s fine for the older code.'];
}

/** Backups on the server, newest first: [name, kind (db|files), version, size, time]. */
function update_backups(): array
{
    $out = [];
    foreach (scandir(update_dir('backups')) ?: [] as $f) {
        if (preg_match('/^(db|files)-v([0-9.]+)-(\d{8}-\d{6})\.(sql|zip)$/', $f, $m)) {
            $out[] = ['name' => $f, 'kind' => $m[1], 'version' => $m[2], 'size' => filesize(update_dir('backups') . '/' . $f), 'when' => $m[3]];
        }
    }
    usort($out, fn($a, $b) => strcmp($b['when'], $a['when']));
    return $out;
}

/** Keep the newest UPDATE_KEEP_BACKUPS database dumps and the newest UPDATE_KEEP_FILE_BACKUPS program zips. */
function update_prune(): void
{
    $seen = ['db' => 0, 'files' => 0];
    foreach (update_backups() as $b) {
        $keep = $b['kind'] === 'files' ? UPDATE_KEEP_FILE_BACKUPS : UPDATE_KEEP_BACKUPS;
        if (++$seen[$b['kind']] > $keep) @unlink(update_dir('backups') . '/' . $b['name']);
    }
}

/** Total size of everything in the backups folder, in bytes. */
function update_backups_size(): int
{
    $n = 0;
    foreach (scandir(update_dir('backups')) ?: [] as $f) { $p = update_dir('backups') . '/' . $f; if (is_file($p)) $n += (int)filesize($p); }
    return $n;
}

/** PHP's upload limit in bytes. */
function update_upload_limit(): int
{
    $parse = function (string $v): int {
        $n = (int)$v;
        return match (strtolower(substr(trim($v), -1))) { 'g' => $n * 1073741824, 'm' => $n * 1048576, 'k' => $n * 1024, default => $n };
    };
    return min($parse((string)ini_get('upload_max_filesize')), $parse((string)ini_get('post_max_size')) ?: PHP_INT_MAX);
}
