<?php
declare(strict_types=1);
/** v2.6.37: Admin → Page code. See the code of a game file and, with the admin password, change it.
 *  Only code files inside the game folder; never config.php, data/ or uploads/. Every save keeps the old file in data/code-backups/. */

const CODE_EXTS = ['php', 'css', 'js', 'txt', 'json'];
const CODE_MAX_BYTES = 1500000;
const CODE_KEEP_BACKUPS = 10;

/** Every file that may be opened, grouped for the picker: ['Group' => ['rel/path.php', ...]]. */
function code_files(): array
{
    $groups = ['Game pages' => '', 'Admin pages' => 'admin', 'Includes' => 'includes', 'Data files' => 'includes/data', 'Styles and scripts' => 'assets'];
    $out = [];
    foreach ($groups as $name => $dir) {
        $abs = APP_ROOT . ($dir !== '' ? '/' . $dir : '');
        $list = [];
        foreach (is_dir($abs) ? (scandir($abs) ?: []) : [] as $f) {
            $rel = ($dir !== '' ? $dir . '/' : '') . $f;
            if (is_file($abs . '/' . $f) && code_path_ok($rel)) $list[] = $rel;
        }
        sort($list, SORT_NATURAL | SORT_FLAG_CASE);
        if ($list) $out[$name] = $list;
    }
    return $out;
}

/** Is this relative path a code file the editor may touch? (shape only; code_resolve() checks the disk) */
function code_path_ok(string $rel): bool
{
    if (!preg_match('~^(?:(?:admin|includes|includes/data|assets)/)?[A-Za-z0-9_.\-]+\.([a-z]+)$~', $rel, $m)) return false;
    if (!in_array($m[1], CODE_EXTS, true)) return false;
    if (str_contains($rel, '..') || in_array($rel, ['config.php'], true)) return false;
    return true;
}

/** Absolute path of an allowed, existing file, or null. Follows no link out of the game folder. */
function code_resolve(string $rel): ?string
{
    if (!code_path_ok($rel)) return null;
    $root = realpath(APP_ROOT);
    $abs = realpath(APP_ROOT . '/' . $rel);
    if ($root === false || $abs === false || !is_file($abs)) return null;
    if ($abs !== $root . DIRECTORY_SEPARATOR . str_replace('/', DIRECTORY_SEPARATOR, $rel)) return null;
    return $abs;
}

/** PHP syntax check without running anything. '' when fine, else the parser's message. */
function code_php_error(string $src): string
{
    try {
        token_get_all($src, TOKEN_PARSE);
        return '';
    } catch (Throwable $e) {
        return $e->getMessage() . ' on line ' . $e->getLine();
    }
}

function code_backup_dir(): string
{
    return APP_ROOT . '/data/code-backups';
}

/** Backups of one file, newest first: [['name' => file, 'at' => unix time, 'size' => bytes], ...]. */
function code_backups(string $rel): array
{
    $pre = str_replace('/', '__', $rel) . '.';
    $out = [];
    foreach (is_dir(code_backup_dir()) ? (scandir(code_backup_dir()) ?: []) : [] as $f) {
        if (!str_starts_with($f, $pre) || !preg_match('/\.(\d{8}-\d{6})\.bak$/', $f, $m)) continue;
        $out[] = ['name' => $f, 'at' => (int)strtotime(substr($m[1], 0, 8) . 'T' . substr($m[1], 9) . ' UTC'), 'size' => (int)filesize(code_backup_dir() . '/' . $f)];
    }
    usort($out, fn($a, $b) => strcmp($b['name'], $a['name']));
    return $out;
}

/** Keep a copy of the file as it is now. Throws when it cannot. */
function code_backup(string $rel, string $abs): void
{
    $dir = code_backup_dir();
    if (!is_dir($dir) && !@mkdir($dir, 0775, true)) throw new RuntimeException('Could not make the backup folder (data/code-backups).');
    $to = $dir . '/' . str_replace('/', '__', $rel) . '.' . gmdate('Ymd-His') . '.bak';
    if (!@copy($abs, $to)) throw new RuntimeException('Could not keep a backup of the old file, so nothing was changed.');
    foreach (array_slice(code_backups($rel), CODE_KEEP_BACKUPS) as $old) @unlink($dir . '/' . $old['name']);
}

/** Write new contents: syntax check, backup, then swap the file in one step. Returns [ok, message]. */
function code_save(string $rel, string $src, string $wasHash): array
{
    $abs = code_resolve($rel);
    if ($abs === null) return [false, 'That file cannot be edited here.'];
    $old = (string)file_get_contents($abs);
    if (!hash_equals(sha1($old), $wasHash)) return [false, 'The file changed on the server since you opened it. Open it again and redo your change.'];
    if (!str_contains($old, "\r")) $src = str_replace("\r\n", "\n", $src);   // browsers send CRLF; keep the file's own line ends
    if ($src === $old) return [true, 'Nothing changed.'];
    if (strlen($src) > CODE_MAX_BYTES) return [false, 'That is too big to save here.'];
    if (trim($src) === '') return [false, 'An empty file would break the game. Nothing was changed.'];
    if (str_ends_with($rel, '.php') && ($err = code_php_error($src)) !== '') return [false, 'Not saved, the PHP has a mistake: ' . $err . '.'];
    if (str_ends_with($rel, '.json') && json_decode($src) === null && json_last_error() !== JSON_ERROR_NONE) return [false, 'Not saved, the JSON does not read: ' . json_last_error_msg() . '.'];
    try { code_backup($rel, $abs); } catch (Throwable $e) { return [false, $e->getMessage()]; }
    $tmp = $abs . '.tmp-' . bin2hex(random_bytes(4));
    if (@file_put_contents($tmp, $src, LOCK_EX) !== strlen($src)) { @unlink($tmp); return [false, 'Could not write the file (file permissions or disk full?). Nothing was changed.']; }
    @chmod($tmp, fileperms($abs) & 0777);
    if (!@rename($tmp, $abs)) { @unlink($tmp); return [false, 'Could not replace the file (file permissions?). Nothing was changed.']; }
    if (function_exists('opcache_invalidate')) @opcache_invalidate($abs, true);
    clearstatcache(true, $abs);
    return [true, '✅ Saved ' . $rel . '. The old version is kept under Earlier versions.'];
}

/** Put a backup back (the current file is backed up first). Returns [ok, message]. */
function code_restore(string $rel, string $backupName): array
{
    $abs = code_resolve($rel);
    $names = array_column(code_backups($rel), 'name');
    if ($abs === null || !in_array($backupName, $names, true)) return [false, 'That earlier version is not there.'];
    $src = (string)file_get_contents(code_backup_dir() . '/' . $backupName);
    return code_save($rel, $src, sha1((string)file_get_contents($abs)));
}
