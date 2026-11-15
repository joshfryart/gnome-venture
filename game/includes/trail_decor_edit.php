<?php
declare(strict_types=1);

/**
 * 2.7.00 Admin > Trail decor: edit the dressing of one Trail section (the 'decor' field of the map data: looks / rough / floor zones, props, rough default, tree)
 * as plain lines, check it, and save it to the table trail_decor_edits (the section then uses it instead of the map data; "Back to the data" deletes it).
 * Pure parsing and checking live here so a test can run them without a page.
 */
require_once __DIR__ . '/trail_art.php';

const TDE_RECT_FIELDS = ['looks' => 'Looks: what a wall tile (#) is dressed as', 'rough' => 'Rough: what a rough tile (,) is dressed as', 'floor' => 'Floor zones: what a floor patch is dressed as'];

/** One decor field as the lines of the form (rects: "kind x0 y0 x1 y1", props: "kind x y"). */
function tde_lines(array $decor, string $field): string
{
    $o = [];
    foreach ((array)($decor[$field] ?? []) as $r) if (is_array($r)) $o[] = implode(' ', $r);
    return implode("\n", $o);
}

/** The known kinds (the ones with a colour in the fallback look). */
function tde_kinds(): array { return array_keys(TRAIL_DECOR_TINT); }

/**
 * Parse the form values into a decor array and list the problems. $in = ['looks' => text, 'rough' => text, 'floor' => text, 'props' => text, 'rough_default' => text, 'tree' => text].
 * $rows = the section's rows (for its size). Returns [decor, problems]: decor is null when anything is wrong (nothing is saved then).
 */
function tde_parse(array $in, array $rows): array
{
    $h = count($rows); $w = $h ? strlen((string)$rows[0]) : 0;
    $bad = []; $d = ['v' => 1, 'looks' => [], 'rough' => [], 'floor' => [], 'rough_default' => '', 'props' => [], 'tree' => ''];
    $kind = fn(string $k): bool => preg_match('/^[a-z][a-z0-9]{1,19}$/', $k) === 1;
    foreach (array_keys(TDE_RECT_FIELDS) as $f) {
        foreach (preg_split('/\R/', (string)($in[$f] ?? '')) as $i => $line) {
            $line = trim($line); if ($line === '') continue;
            $p = preg_split('/[\s,]+/', $line);
            if (count($p) !== 5 || !$kind($p[0]) || !ctype_digit($p[1]) || !ctype_digit($p[2]) || !ctype_digit($p[3]) || !ctype_digit($p[4])) { $bad[] = "$f line " . ($i + 1) . ': needs "kind x0 y0 x1 y1"'; continue; }
            [$k, $x0, $y0, $x1, $y1] = [$p[0], (int)$p[1], (int)$p[2], (int)$p[3], (int)$p[4]];
            if ($x0 > $x1 || $y0 > $y1 || $x1 >= $w || $y1 >= $h) { $bad[] = "$f line " . ($i + 1) . ": the corners must be inside the section ($w x $h) with x0 <= x1 and y0 <= y1"; continue; }
            foreach ($d[$f] as $o) if ($x0 <= $o[3] && $x1 >= $o[1] && $y0 <= $o[4] && $y1 >= $o[2]) { $bad[] = "$f line " . ($i + 1) . ': overlaps another rectangle of the same list'; break; }
            $d[$f][] = [$k, $x0, $y0, $x1, $y1];
        }
    }
    foreach (preg_split('/\R/', (string)($in['props'] ?? '')) as $i => $line) {
        $line = trim($line); if ($line === '') continue;
        $p = preg_split('/[\s,]+/', $line);
        if (count($p) !== 3 || !$kind($p[0]) || !ctype_digit($p[1]) || !ctype_digit($p[2])) { $bad[] = 'props line ' . ($i + 1) . ': needs "kind x y"'; continue; }
        if ((int)$p[1] >= $w || (int)$p[2] >= $h) { $bad[] = 'props line ' . ($i + 1) . ": outside the section ($w x $h)"; continue; }
        $d['props'][] = [$p[0], (int)$p[1], (int)$p[2]];
    }
    foreach (['rough_default', 'tree'] as $f) {
        $v = trim((string)($in[$f] ?? ''));
        if ($v !== '' && !$kind($v)) $bad[] = "$f must be one lowercase word (2 to 20 letters or digits)"; else $d[$f] = $v;
    }
    if (count($d['looks']) + count($d['rough']) + count($d['floor']) + count($d['props']) > 400) $bad[] = 'too many entries (400 at most)';
    return [$bad ? null : $d, $bad];
}

/** Save a section's decor (replacing any edit) or, with $decor = null, drop the edit ("Back to the data"). */
function tde_save(int $routeId, int $sec, ?array $decor): void
{
    q('DELETE FROM trail_decor_edits WHERE route_id = ? AND sec = ?', [$routeId, $sec]);
    if ($decor !== null) db_insert('trail_decor_edits', ['route_id' => $routeId, 'sec' => $sec, 'decor' => json_encode($decor), 'updated_at' => now()]);
    $GLOBALS['gv_decor_edits_reload'] = true;
}

/** Make the table if Upgrade database has not yet (the admin page calls this). True when it is there. */
function tde_ensure_table(): bool
{
    try { q('SELECT 1 FROM trail_decor_edits LIMIT 1'); return true; } catch (Throwable $e) {}
    try {
        $sqlite = db()->getAttribute(PDO::ATTR_DRIVER_NAME) === 'sqlite';
        q('CREATE TABLE IF NOT EXISTS trail_decor_edits (id ' . ($sqlite ? 'INTEGER PRIMARY KEY AUTOINCREMENT' : 'INT UNSIGNED AUTO_INCREMENT PRIMARY KEY') . ', route_id ' . ($sqlite ? 'INTEGER' : 'INT UNSIGNED') . ' NOT NULL, sec INT NOT NULL, decor TEXT NOT NULL, updated_at DATETIME NULL, UNIQUE (route_id, sec))' . ($sqlite ? '' : ' ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci'));
        q('SELECT 1 FROM trail_decor_edits LIMIT 1');
        return true;
    } catch (Throwable $e) { return false; }
}
