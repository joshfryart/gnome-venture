<?php
declare(strict_types=1);

/**
 * v2.0.4 road text: the owner tunes road ambience, road/wild scenes, wonder text and delve rooms from Admin -> Road text, without a release.
 * The data files stay the defaults. A row in road_texts (status draft or done, body set) overrides ONE text; status todo (or an empty body) = the file text.
 * Only wording is overridden: cond, lands, region, stats, dc, effects and weights are never read from here.
 *
 * Stable ids (document): road_texts.text_key = a content hash of the ORIGINAL file text, so adding or moving rows in a data file never shifts an override.
 *   road.line.<h>                 road_lines.txt row (h = first 10 hex of sha1 of the lower-cased, whitespace-squeezed original text)
 *   road.delve.<h>                delve_rooms.txt row (same hash)
 *   road.event.<id>               road_events.txt E row scene text (id = the file's own id)
 *   road.event.<id>.<h>.label|win|lose   an O row of that event (h = hash of the original option label); win/lose = win text / lose text
 *   road.sight.<id>               road_events.txt S row text
 *   road.wonder.<slug>.intro|success|fail   wonder_text.txt (slug = slugify of the wonder name)
 *   road.wonder.mood.<h>          a "*easy/*plain/*hard" mood line
 * Editing the ORIGINAL text of a row in the data file changes its hash: the old override is then listed under "No longer in the file" in the editor.
 * Loaders call road_text_apply($key, $default); a missing table or a DB error just gives the file text.
 */

const ROAD_TEXT_KINDS = ['line' => 'Road lines', 'event' => 'Scenes', 'wonder' => 'Wonders', 'delve' => 'Delve rooms'];
const ROAD_TEXT_MAX = ['line' => 200, 'delve' => 200, 'wonder' => 200, 'event' => 300, 'label' => 60, 'outcome' => 240];

function road_text_schema(string $PK, string $ID, string $END): array
{
    $t = ["CREATE TABLE IF NOT EXISTS road_texts (
        id $PK,
        text_key VARCHAR(120) NOT NULL UNIQUE,
        kind VARCHAR(12) NOT NULL DEFAULT 'line',
        part VARCHAR(12) NOT NULL DEFAULT 'text',
        orig TEXT NULL,
        body TEXT NULL,
        status VARCHAR(8) NOT NULL DEFAULT 'todo',
        updated_at DATETIME NULL
    )$END"];
    return [$t, ['CREATE INDEX idx_road_texts_kind ON road_texts (kind, status)'], []];
}

/** Create the table if the upgrade has not run yet (the editor calls this; the loaders never do). */
function road_text_ensure_table(): bool
{
    try { q('SELECT 1 FROM road_texts LIMIT 1'); return true; } catch (Throwable $e) {}
    try {
        require_once __DIR__ . '/schema.php';
        $driver = (string)(db()->getAttribute(PDO::ATTR_DRIVER_NAME) === 'sqlite' ? 'sqlite' : 'mysql');
        [$t, $i] = road_text_schema(...(function (string $d): array {
            $s = $d === 'sqlite';
            return [$s ? 'INTEGER PRIMARY KEY AUTOINCREMENT' : 'INT UNSIGNED AUTO_INCREMENT PRIMARY KEY', $s ? 'INTEGER' : 'INT UNSIGNED', $s ? '' : ' ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci'];
        })($driver));
        foreach ($t as $sql) db()->exec($sql);
        foreach ($i as $sql) { try { db()->exec($sql); } catch (Throwable $e) {} }
        return true;
    } catch (Throwable $e) {
        error_log('road_text_ensure_table: ' . $e->getMessage());
        return false;
    }
}

/** Content hash of an original text: stable when rows are added, moved or re-spaced; changes only when the words change. */
function road_text_hash(string $s): string
{
    return substr(sha1(mb_strtolower(trim((string)preg_replace('/\s+/u', ' ', $s)))), 0, 10);
}

/** key => body for every live override (status draft/done, body set). Read once per request; [] on any error. */
function road_text_overrides(bool $reload = false): array
{
    static $map = null;
    if ($map !== null && !$reload) return $map;
    $map = [];
    try {
        foreach (q("SELECT text_key, body FROM road_texts WHERE status <> 'todo' AND body IS NOT NULL AND body <> ''")->fetchAll() as $r) $map[(string)$r['text_key']] = (string)$r['body'];
    } catch (Throwable $e) {
        $map = [];
    }
    return $map;
}

/** The text to show: the override when there is one, else the file's. */
function road_text_apply(string $key, string $default): string
{
    $m = road_text_overrides();
    return isset($m[$key]) && trim($m[$key]) !== '' ? $m[$key] : $default;
}

/** Hook for the wonder loader (landmarks.php wonder_texts): rows = [slug => [intro, success, fail], '*easy' => [lines], ...]. */
function road_text_wonder_apply(array $rows): array
{
    if (!road_text_overrides()) return $rows;
    foreach ($rows as $slug => $r) {
        if ($slug !== '' && $slug[0] === '*') {
            foreach ($r as $i => $line) $rows[$slug][$i] = road_text_apply('road.wonder.mood.' . road_text_hash((string)$line), (string)$line);
            continue;
        }
        foreach (['intro', 'success', 'fail'] as $i => $p) if (isset($r[$i]) && $r[$i] !== '') $rows[$slug][$i] = road_text_apply('road.wonder.' . $slug . '.' . $p, (string)$r[$i]);
    }
    return $rows;
}

/** Hook for the delve loader: rows with a 'text' key (kind|cond|lands|text). Other keys untouched. */
function road_text_delve_apply(array $rows): array
{
    if (!road_text_overrides()) return $rows;
    foreach ($rows as $i => $r) if (isset($r['text']) && $r['text'] !== '') $rows[$i]['text'] = road_text_apply('road.delve.' . road_text_hash((string)$r['text']), (string)$r['text']);
    return $rows;
}

// ---------------------------------------------------------------- the catalog (file defaults), for the editor

function road_text_file_lines(string $file): array
{
    $path = __DIR__ . '/data/' . $file;
    if (!is_file($path)) return [];
    $out = file($path, FILE_IGNORE_NEW_LINES);
    return is_array($out) ? $out : [];
}

/**
 * Every overridable text in the data files: key => [kind, part, group (for the list), where (a short context), orig, max].
 * Reads the files itself (raw), so overrides never leak into the defaults.
 */
function road_text_catalog(): array
{
    $c = [];
    foreach (road_text_file_lines('road_lines.txt') as $line) {
        $line = trim($line);
        if ($line === '' || $line[0] === '#') continue;
        $f = array_map('trim', explode('|', $line, 4));
        if (count($f) < 4 || $f[3] === '') continue;
        $c['road.line.' . road_text_hash($f[3])] = ['line', 'text', 'Road line', 'when ' . ($f[0] === '' ? '-' : $f[0]) . ' · ' . ($f[1] ?: 'any') . ' · region ' . ($f[2] ?: 'any'), $f[3], ROAD_TEXT_MAX['line']];
    }
    $cur = null;
    foreach (road_text_file_lines('road_events.txt') as $line) {
        $line = trim($line);
        if ($line === '' || $line[0] === '#') continue;
        $f = array_map('trim', explode('|', $line));
        if ($f[0] === 'E' && count($f) >= 8 && $f[1] !== '' && $f[7] !== '') {
            $cur = $f[1];
            $c['road.event.' . $cur] = ['event', 'text', 'Scene ' . $cur, 'scene · ' . ($f[5] ?: 'both') . ' · ' . ($f[3] ?: 'any') . ' · ' . ($f[2] ?: '-'), $f[7], ROAD_TEXT_MAX['event']];
        } elseif ($f[0] === 'O' && $cur !== null && count($f) >= 8) {
            $h = road_text_hash($f[1]);
            foreach ([['label', 1, 'label'], ['win', 5, 'outcome'], ['lose', 7, 'outcome']] as [$p, $at, $lim]) {
                if ($f[$at] === '') continue;
                $c['road.event.' . $cur . '.' . $h . '.' . $p] = ['event', $p, 'Scene ' . $cur, 'option "' . $f[1] . '" · ' . ['label' => 'button', 'win' => 'if it works', 'lose' => 'if it fails'][$p], $f[$at], ROAD_TEXT_MAX[$lim]];
            }
        } elseif ($f[0] === 'S' && count($f) >= 9 && $f[1] !== '' && $f[7] !== '') {
            $cur = null;
            $c['road.sight.' . $f[1]] = ['event', 'text', 'Sight ' . $f[1], 'strange sight · ' . ($f[3] ?: 'any') . ' · ' . ($f[2] ?: '-'), $f[7], ROAD_TEXT_MAX['event']];
        }
    }
    foreach (road_text_file_lines('wonder_text.txt') as $line) {
        $line = trim($line);
        if ($line === '' || $line[0] === '#') continue;
        $f = array_map('trim', explode('|', $line));
        if (count($f) < 2 || $f[0] === '') continue;
        if ($f[0][0] === '*') {
            if ($f[1] !== '') $c['road.wonder.mood.' . road_text_hash($f[1])] = ['wonder', 'mood', 'Wonder mood ' . substr($f[0], 1), 'mood of the day (' . substr($f[0], 1) . ')', $f[1], ROAD_TEXT_MAX['wonder']];
            continue;
        }
        $slug = slugify($f[0]);
        foreach (['intro' => 1, 'success' => 2, 'fail' => 3] as $p => $at) {
            if (($f[$at] ?? '') === '') continue;
            $c['road.wonder.' . $slug . '.' . $p] = ['wonder', $p, 'Wonder ' . $f[0], ['intro' => 'shown above the approaches', 'success' => 'on success', 'fail' => 'on failure'][$p], $f[$at], ROAD_TEXT_MAX['wonder']];
        }
    }
    // delve_rooms.txt (kind|cond|lands|text) may not exist: load defensively
    foreach (road_text_file_lines('delve_rooms.txt') as $line) {
        $line = trim($line);
        if ($line === '' || $line[0] === '#') continue;
        $f = array_map('trim', explode('|', $line, 4));
        if (count($f) < 4 || $f[3] === '') continue;
        $c['road.delve.' . road_text_hash($f[3])] = ['delve', 'text', 'Delve room (' . $f[0] . ')', 'when ' . ($f[1] === '' ? '-' : $f[1]) . ' · ' . ($f[2] ?: 'any'), $f[3], ROAD_TEXT_MAX['delve']];
    }
    return $c;
}

/** Add the missing rows (status todo) and refresh the default text of existing ones. Returns the number added. Editor only. */
function road_text_sync(): int
{
    $cat = road_text_catalog();
    $have = [];
    foreach (q('SELECT text_key, orig FROM road_texts')->fetchAll() as $r) $have[(string)$r['text_key']] = $r['orig'];
    $n = 0;
    $pdo = db();
    $pdo->beginTransaction();
    try {
        foreach ($cat as $key => [$kind, $part, , , $orig]) {
            if (!array_key_exists($key, $have)) {
                q('INSERT INTO road_texts (text_key, kind, part, orig, status) VALUES (?, ?, ?, ?, ?)', [$key, $kind, $part, $orig, 'todo']);
                $n++;
            } elseif ((string)$have[$key] !== $orig) {
                q('UPDATE road_texts SET orig = ? WHERE text_key = ?', [$orig, $key]);
            }
        }
        // a row gone from the files with nothing written in it is just dropped
        foreach (array_diff_key($have, $cat) as $key => $o) q("DELETE FROM road_texts WHERE text_key = ? AND (body IS NULL OR body = '')", [$key]);
        $pdo->commit();
    } catch (Throwable $e) {
        if ($pdo->inTransaction()) $pdo->rollBack();
        throw $e;
    }
    return $n;
}

/** Validate an edited body: [clean text or null, error]. One line (line breaks become spaces), no HTML, no pipe, length by part. */
function road_text_clean(string $raw, int $max): array
{
    $s = trim((string)preg_replace('/\s+/u', ' ', str_replace("\r", ' ', $raw)));
    if ($s === '') return ['', ''];
    if (preg_match('/[<>]/', $s)) return [null, 'No HTML or < > in road text.'];
    if (str_contains($s, '|')) return [null, 'No | in road text.'];
    if (preg_match('/[\x00-\x08\x0B\x0C\x0E-\x1F]/', $s)) return [null, 'Odd control characters.'];
    if (mb_strlen($s) > $max) return [null, 'Too long (' . $max . ' letters at most for this one).'];
    return [$s, ''];
}
