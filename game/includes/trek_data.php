<?php
declare(strict_types=1);

/**
 * v1.8.0 Treks: data side. Settings, tables, the data-file readers (map, spots, crew, pools), the importers and trek_text().
 * Files live in includes/data/trek_*.txt. Importers only add what is missing, so admin edits are never overwritten
 * (trek_texts: a brief is Claude-owned and may be refreshed from the file, a body and status are Joshua's and never are).
 * Never call a trek an "expedition": that word is the road-walk table.
 */

require_once __DIR__ . '/trek_levels.php';   // v1.8.9: trek levels + milestone XP (schema for trek_ms is read from here)

const TREK_KEY = 'withering';

/** Admin settings, merged into settings_schema(). */
function trek_settings(): array
{
    $s = trek_settings_base();
    foreach (trek_chapters() as $n => $c) {   // v1.9.1: a milestone of a later chapter makes its own setting (Chapter I's are above)
        foreach ($c['ms'] as $key => [$label, $setting, , $xp]) {
            if (!isset($s[$setting])) $s[$setting] = ['label' => 'Treks: milestone XP, ' . $label, 'type' => 'int', 'default' => (string)$xp, 'min' => 0, 'max' => 1000000];
        }
    }
    return $s;
}

function trek_settings_base(): array
{
    return [
        'trek_open'           => ['label' => 'Treks: open to every player (off = admins only)', 'type' => 'select', 'default' => '0', 'options' => ['0' => 'Off (admins only)', '1' => 'On']],
        'trek_base_level'     => ['label' => 'Treks: the level every party member fights at before trek levels (gnome level no longer counts) (v1.9.5)', 'type' => 'int', 'default' => '15', 'min' => 1, 'max' => 100],
        'trek_level'          => ['label' => 'Treks: gnome level needed', 'type' => 'int', 'default' => '15', 'min' => 1, 'max' => 100],
        'trek_entry_energy'   => ['label' => 'Treks: energy to go in (each time)', 'type' => 'int', 'default' => '10', 'min' => 0, 'max' => 1000],
        'trek_enc_percent'    => ['label' => 'Treks: chance of a fight on each step when hunting (%)', 'type' => 'int', 'default' => '9', 'min' => 0, 'max' => 100],
        'trek_sneak_mult_pct' => ['label' => 'Treks: sneaking leaves this % of the fight chance', 'type' => 'int', 'default' => '25', 'min' => 0, 'max' => 100],
        'trek_xp_daily'       => ['label' => 'Treks: (not used since v1.8.9: fights give trek XP, gnome XP comes from milestones)', 'type' => 'int', 'default' => '300', 'min' => 0, 'max' => 1000000],
        'trek_ms_burdock'     => ['label' => 'Treks: milestone XP, Burdock found (v1.8.9)', 'type' => 'int', 'default' => '150', 'min' => 0, 'max' => 1000000],
        'trek_ms_zinnia'      => ['label' => 'Treks: milestone XP, Zinnia found', 'type' => 'int', 'default' => '250', 'min' => 0, 'max' => 1000000],
        'trek_ms_bracken'     => ['label' => 'Treks: milestone XP, Bracken found', 'type' => 'int', 'default' => '350', 'min' => 0, 'max' => 1000000],
        'trek_ms_mother'      => ['label' => 'Treks: milestone XP, Blight Mother down', 'type' => 'int', 'default' => '500', 'min' => 0, 'max' => 1000000],
        'trek_ms_gloomtooth'  => ['label' => 'Treks: milestone XP, Gloomtooth down', 'type' => 'int', 'default' => '600', 'min' => 0, 'max' => 1000000],
        'trek_ms_chapter'     => ['label' => 'Treks: milestone XP, Chapter I complete (each pays 50-100% by its checks)', 'type' => 'int', 'default' => '350', 'min' => 0, 'max' => 1000000],
        'trek_petals_daily'   => ['label' => 'Treks: most Petals found in fights in one Hollow day (v1.8.1)', 'type' => 'int', 'default' => '150', 'min' => 0, 'max' => 1000000],
        'trek_campkit_price'  => ['label' => 'Treks: Camp Kit price (Petals)', 'type' => 'int', 'default' => '60', 'min' => 0, 'max' => 100000],
        'trek_campkit_max'    => ['label' => 'Treks: most Camp Kits carried', 'type' => 'int', 'default' => '3', 'min' => 0, 'max' => 99],
        'trek_ko_loss_pct'    => ['label' => 'Treks: share of unbanked finds lost when the party is knocked out (%)', 'type' => 'int', 'default' => '45', 'min' => 0, 'max' => 100],
        'trek_ch1_petals'     => ['label' => 'Treks: Petals for finishing Chapter I', 'type' => 'int', 'default' => '400', 'min' => 0, 'max' => 1000000],
        'trek_event_pct'      => ['label' => 'Treks: chance of a trail event on a plain tile (%) (v1.8.8)', 'type' => 'int', 'default' => '6', 'min' => 0, 'max' => 100],
        'trek_event_gap'      => ['label' => 'Treks: fewest plain steps between two trail events (v1.8.8)', 'type' => 'int', 'default' => '15', 'min' => 1, 'max' => 100],
        'trek_ambush_pct'     => ['label' => 'Treks: chance of an ambush when you make camp without a kit (%)', 'type' => 'int', 'default' => '30', 'min' => 0, 'max' => 100],
        'trek_ch2_petals'     => ['label' => 'Treks: Petals for finishing Chapter II (v1.9.4)', 'type' => 'int', 'default' => '500', 'min' => 0, 'max' => 1000000],
        'trek_cold_rest_fatigue' => ['label' => 'Treks: fatigue removed by a cold rest without a kit (v1.9.4)', 'type' => 'int', 'default' => '25', 'min' => 0, 'max' => 100],
    ];
}

/** Tables, indexes, columns: [tables, indexes, columns]. Called from schema_statements(). */
function trek_schema(string $PK, string $ID, string $END): array
{
    $t = [];
    $t[] = "CREATE TABLE IF NOT EXISTS trek_runs (
        id $PK,
        user_id $ID NOT NULL,
        trek_key VARCHAR(20) NOT NULL,
        mode VARCHAR(10) NOT NULL DEFAULT 'gentle',
        chapter INT NOT NULL DEFAULT 1,
        x INT NOT NULL DEFAULT 0,
        y INT NOT NULL DEFAULT 0,
        camp VARCHAR(40) NULL,
        inside INT NOT NULL DEFAULT 0,
        fatigue INT NOT NULL DEFAULT 0,
        sneak INT NOT NULL DEFAULT 0,
        petals_found INT NOT NULL DEFAULT 0,
        campkits INT NOT NULL DEFAULT 0,
        fight TEXT NULL,
        log TEXT NULL,
        state TEXT NULL,
        xp_day VARCHAR(10) NULL,
        xp_today INT NOT NULL DEFAULT 0,
        started DATETIME NOT NULL,
        finished DATETIME NULL,
        UNIQUE (user_id, trek_key, mode, chapter)
    )$END";
    $t[] = "CREATE TABLE IF NOT EXISTS trek_party (
        id $PK,
        run_id $ID NOT NULL,
        slot INT NOT NULL,
        crew_key VARCHAR(40) NOT NULL,
        hp INT NOT NULL DEFAULT 1,
        UNIQUE (run_id, slot)
    )$END";
    $t[] = "CREATE TABLE IF NOT EXISTS trek_recruits (
        id $PK,
        run_id $ID NOT NULL,
        crew_key VARCHAR(40) NOT NULL,
        UNIQUE (run_id, crew_key)
    )$END";
    $t[] = "CREATE TABLE IF NOT EXISTS trek_pack (
        id $PK,
        run_id $ID NOT NULL,
        item_id $ID NOT NULL,
        qty INT NOT NULL DEFAULT 0,
        banked INT NOT NULL DEFAULT 0,
        UNIQUE (run_id, item_id, banked)
    )$END";
    $t[] = "CREATE TABLE IF NOT EXISTS trek_flags (
        id $PK,
        run_id $ID NOT NULL,
        flag VARCHAR(60) NOT NULL,
        UNIQUE (run_id, flag)
    )$END";
    $t[] = "CREATE TABLE IF NOT EXISTS trek_texts (
        id $PK,
        text_key VARCHAR(80) NOT NULL UNIQUE,
        trek_key VARCHAR(20) NOT NULL DEFAULT 'withering',
        chapter INT NOT NULL DEFAULT 1,
        kind VARCHAR(12) NOT NULL DEFAULT 'narration',
        speaker VARCHAR(80) NULL,
        brief TEXT NULL,
        body TEXT NULL,
        status VARCHAR(8) NOT NULL DEFAULT 'todo',
        sort_order INT NOT NULL DEFAULT 0,
        updated_at DATETIME NULL
    )$END";
    $t = array_merge($t, trek_ms_schema($ID, $END));   // v1.8.9: milestones paid, once per player (a run reset keeps them)
    // trek_seen is not a table: the fog of war is a small hex string in trek_runs.state (see trek_seen_*)
    $i = [
        'CREATE INDEX idx_trek_runs_user ON trek_runs (user_id)',
        'CREATE INDEX idx_trek_party_run ON trek_party (run_id)',
        'CREATE INDEX idx_trek_pack_run ON trek_pack (run_id)',
        'CREATE INDEX idx_trek_texts_ch ON trek_texts (chapter, kind)',
    ];
    // v1.9.1: the chapter the gnome is in (their run, or the interlude after it) and the daily trek Petal count, shared by every chapter
    $c = [
        ['users', 'trek_ch', 'INT NOT NULL DEFAULT 1'],
        ['users', 'trek_pet_day', 'VARCHAR(10) NULL'],
        ['users', 'trek_pet_today', 'INT NOT NULL DEFAULT 0'],
    ];
    return [$t, $i, $c];
}

/**
 * v1.9.1: bring an older database up to per-chapter runs. Idempotent, safe to call on every request of trek.php (the checks are cheap).
 *  1. the users columns (db_migrate adds them on a version change; this covers a copy whose version was set by hand)
 *  2. trek_runs was UNIQUE (user_id, trek_key, mode): one row per player. Now UNIQUE (user_id, trek_key, mode, chapter).
 *     MySQL: drop the old unique index (found by its columns) and add the new one. SQLite cannot drop an inline UNIQUE, so the table is rebuilt (same ids).
 *  3. the daily Petal count moves from each run's state (pet_day/pet_today) to the users row (done lazily in trek_petals_capped too).
 */
function trek_ch_ensure(): void
{
    static $done = false;
    if ($done) return;
    $done = true;
    $sqlite = db()->getAttribute(PDO::ATTR_DRIVER_NAME) === 'sqlite';
    try {
        q('SELECT trek_ch, trek_pet_day, trek_pet_today FROM users LIMIT 1');
    } catch (Throwable $e) {
        foreach (trek_schema('', '', '')[2] as [$tb, $col, $def]) {
            try { db()->query("SELECT $col FROM $tb LIMIT 1"); } catch (Throwable $e2) { db()->exec("ALTER TABLE $tb ADD COLUMN $col $def"); }   // DDL from the constant column list above (cannot be a bound parameter)
        }
    }
    try {
        trek_runs_unique_fix($sqlite);
    } catch (Throwable $e) {
        if (db()->inTransaction()) db()->rollBack();
        error_log('trek_runs unique fix: ' . $e->getMessage());
        if (function_exists('game_error_log')) game_error_log('Treks: per-chapter unique index not made: ' . $e->getMessage());
    }
}

/** The unique indexes of trek_runs as [index name => [columns in order]]. */
function trek_runs_uniques(bool $sqlite): array
{
    $out = [];
    if ($sqlite) {
        foreach (q('PRAGMA index_list(trek_runs)')->fetchAll() as $ix) {
            if (!(int)$ix['unique']) continue;
            $cols = [];
            foreach (db()->query('PRAGMA index_info(' . $ix['name'] . ')')->fetchAll() as $c) $cols[(int)$c['seqno']] = $c['name'];
            ksort($cols);
            $out[$ix['name']] = array_values($cols);
        }
        return $out;
    }
    foreach (q('SHOW INDEX FROM trek_runs')->fetchAll() as $r) {
        if ((int)$r['Non_unique'] !== 0 || $r['Key_name'] === 'PRIMARY') continue;
        $out[$r['Key_name']][(int)$r['Seq_in_index']] = $r['Column_name'];
    }
    foreach ($out as $k => $cols) { ksort($cols); $out[$k] = array_values($cols); }
    return $out;
}

function trek_runs_unique_fix(bool $sqlite): void
{
    $old = ['user_id', 'trek_key', 'mode'];
    $new = ['user_id', 'trek_key', 'mode', 'chapter'];
    $have = trek_runs_uniques($sqlite);
    $hasOld = in_array($old, $have, true);
    $hasNew = in_array($new, $have, true);
    if (!$hasOld && $hasNew) return;
    if (!$sqlite) {
        if (!$hasNew) q('ALTER TABLE trek_runs ADD UNIQUE INDEX uq_trek_runs_ch (user_id, trek_key, mode, chapter)');
        foreach ($have as $name => $cols) if ($cols === $old) db()->exec('ALTER TABLE trek_runs DROP INDEX `' . $name . '`');
        return;
    }
    // SQLite: rebuild the table with the new constraint, keeping every row and id
    $cols = array_column(q('PRAGMA table_info(trek_runs)')->fetchAll(), 'name');
    $list = implode(', ', $cols);
    db()->beginTransaction();
    try {
        q('ALTER TABLE trek_runs RENAME TO trek_runs_old');
        q('DROP INDEX IF EXISTS idx_trek_runs_user');
        foreach (trek_schema('INTEGER PRIMARY KEY AUTOINCREMENT', 'INTEGER', '')[0] as $sql) {
            if (str_contains($sql, 'trek_runs (')) { q($sql); break; }
        }
        db()->exec("INSERT INTO trek_runs ($list) SELECT $list FROM trek_runs_old");   // $list = the table's own column names
        q('DROP TABLE trek_runs_old');
        q('CREATE INDEX IF NOT EXISTS idx_trek_runs_user ON trek_runs (user_id)');
        db()->commit();
    } catch (Throwable $e) {
        if (db()->inTransaction()) db()->rollBack();
        throw $e;
    }
}

/** Once, for a player whose Petal count for today still lives in a run's state: copy it to the users row (the newest day, the highest count that day). */
function trek_pet_migrate(): void
{
    foreach (q('SELECT r.user_id, r.state FROM trek_runs r JOIN users u ON u.id = r.user_id WHERE u.trek_pet_day IS NULL')->fetchAll() as $r) {
        $st = json_decode((string)$r['state'], true) ?: [];
        $day = (string)($st['pet_day'] ?? '');
        if ($day === '') continue;
        $n = (int)($st['pet_today'] ?? 0);
        $cur = q_one('SELECT trek_pet_day, trek_pet_today FROM users WHERE id = ?', [$r['user_id']]);
        if ($cur['trek_pet_day'] === null || $day > $cur['trek_pet_day'] || ($day === $cur['trek_pet_day'] && $n > (int)$cur['trek_pet_today'])) {
            q('UPDATE users SET trek_pet_day = ?, trek_pet_today = ? WHERE id = ?', [$day, $n, $r['user_id']]);
        }
    }
}

// ------------------------------------------------------------------ data files

/** The lines of a trek data file, as raw strings (comments and blank lines dropped). */
function trek_lines(string $file): array
{
    $path = __DIR__ . '/data/' . $file;
    if (!is_file($path)) return [];
    $out = [];
    foreach (file($path, FILE_IGNORE_NEW_LINES) as $line) {
        $line = rtrim($line, "\r");
        if (trim($line) === '' || ltrim($line)[0] === '#') continue;
        $out[] = $line;
    }
    return $out;
}

/**
 * A chapter's map: ['w','h','t' => tile rows, 'z' => zone-letter rows]. The file has a tile layer, a line "---", and a zone layer.
 * Any width and height work (rows are padded to the widest). v1.9.1: comments are explicit. A line starting with ";" is a comment, and so is a
 * line starting with "# " (hash and a space) or a lone "#". A wall row is "#" followed by a tile, so it is never a comment: a map row must
 * not start with "# " (wall then empty space); begin it with "#." or put the gap elsewhere. (It used to be "starts with # and is not 40 long".)
 */
function trek_map(int $chapter = 1): array
{
    static $cache = [];
    if (isset($cache[$chapter])) return $cache[$chapter];
    $path = __DIR__ . '/data/trek_map_ch' . $chapter . '.txt';
    $layers = [[], []];
    $at = 0;
    if (is_file($path)) {
        foreach (file($path, FILE_IGNORE_NEW_LINES) as $line) {
            $line = rtrim($line, "\r");
            if (trim($line) === '---') { $at = 1; continue; }
            if (trek_map_comment($line)) continue;
            $layers[$at][] = $line;
        }
    }
    $w = $layers[0] ? max(array_map('strlen', $layers[0])) : 0;
    $pad = fn(array $rows) => array_map(fn($r) => str_pad($r, $w), $rows);
    return $cache[$chapter] = ['w' => $w, 'h' => count($layers[0]), 't' => $pad($layers[0]), 'z' => $pad($layers[1])];
}

function trek_map_comment(string $line): bool
{
    return $line === '' || $line[0] === ';' || $line === '#' || str_starts_with($line, '# ');
}

function trek_tile(int $chapter, int $x, int $y): string
{
    $m = trek_map($chapter);
    return ($x < 0 || $y < 0 || $x >= $m['w'] || $y >= $m['h']) ? ' ' : $m['t'][$y][$x];
}

/** The zone letter of a tile ('' if none). */
function trek_zone_at(int $chapter, int $x, int $y): string
{
    $m = trek_map($chapter);
    if ($x < 0 || $y < 0 || $x >= $m['w'] || $y >= $m['h']) return '';
    return trim($m['z'][$y][$x] ?? '');
}

// ------------------------------------------------------------------ chapters (v1.9.1)

/** The data files of one kind, e.g. trek_data_files('trek_chapters') = trek_chapters.txt, then trek_chapters_*.txt, sorted. */
function trek_data_files(string $prefix): array
{
    $out = [];
    foreach (glob(__DIR__ . '/data/' . $prefix . '*.txt') ?: [] as $f) $out[] = basename($f);
    sort($out);
    return $out;
}

/**
 * Every chapter's definition from trek_chapters*.txt: n => ['n','roman','title','zones' => [letter => ['name','icon','style','single','first30','pool']],
 * 'ms' => [key => [label, setting, short, default XP]], 'checks' => [[label, type, arg, from]], 'tune' => [key => [health %, atk, def, dmg]], 'lift' => [anchor, per, max] or null, 'finish' => [...] or null].
 */
function trek_chapters(): array
{
    static $cache = null;
    if ($cache !== null) return $cache;
    $cache = [];
    foreach (trek_data_files('trek_chapters') as $file) {
        foreach (trek_lines($file) as $line) {
            $f = array_map('trim', explode('|', $line));
            $n = (int)($f[1] ?? 0);
            if ($n < 1) continue;
            $cache[$n] ??= ['n' => $n, 'roman' => trek_roman($n), 'title' => 'Chapter ' . $n, 'zones' => [], 'ms' => [], 'checks' => [], 'tune' => [], 'lift' => null, 'finish' => null];
            switch ($f[0]) {
                case 'chapter':
                    $cache[$n]['roman'] = $f[2] ?? (string)$n;
                    $cache[$n]['title'] = $f[3] ?? $cache[$n]['title'];
                    break;
                case 'zone':
                    $flags = array_map('trim', explode(',', (string)($f[6] ?? '')));
                    $cache[$n]['zones'][(string)$f[2]] = ['name' => (string)($f[3] ?? ''), 'icon' => (string)($f[4] ?? ''), 'style' => ($f[5] ?? 'o') === 'd' ? 'd' : (($f[5] ?? 'o') === 'u' ? 'u' : 'o'),   // v1.9.4: d = underground and dark (the map art draws a deep vignette)
                        'single' => in_array('single', $flags, true), 'first30' => in_array('first30', $flags, true), 'pool' => in_array('pool', $flags, true),
                        'hint' => in_array('hint', $flags, true)];   // v1.9.4: hint = the zone says ch<N>.zone.<letter>.hint the first time you enter
                    break;
                case 'ms':
                    $cache[$n]['ms'][(string)$f[2]] = [(string)($f[3] ?? $f[2]), (string)($f[4] ?? ''), (string)($f[5] ?? $f[2]), (int)($f[6] ?? 0)];
                    break;
                case 'check':
                    $cache[$n]['checks'][] = [(string)($f[2] ?? ''), (string)($f[3] ?? 'flag'), (string)($f[4] ?? ''), (int)($f[5] ?? 0)];
                    break;
                case 'tune':
                    $cache[$n]['tune'][(string)$f[2]] = [(int)($f[3] ?? 100), (int)($f[4] ?? 0), (int)($f[5] ?? 0), (int)($f[6] ?? 0)];
                    break;
                case 'lift':   // v1.9.2: parsed but IGNORED since v1.9.5 (foes no longer follow the gnome's level): lift|N|anchor level|gnome levels per foe level|most foe levels
                    $cache[$n]['lift'] = [max(1, (int)($f[2] ?? 1)), max(1, (int)($f[3] ?? 2)), max(0, (int)($f[4] ?? 0))];
                    break;
                case 'finish':
                    $cache[$n]['finish'] = ['flag' => (string)($f[2] ?? ''), 'ms' => array_values(array_filter(explode(',', (string)($f[3] ?? '')))), 'petals' => (string)($f[4] ?? ''),
                        'items' => array_values(array_filter(explode(',', (string)($f[5] ?? '')))), 'entries' => array_values(array_filter(explode(',', (string)($f[6] ?? '')))), 'title' => (string)($f[7] ?? 'Chapter ' . $n)];
                    break;
            }
        }
    }
    ksort($cache);
    return $cache;
}

function trek_roman(int $n): string
{
    return ['', 'I', 'II', 'III', 'IV', 'V', 'VI', 'VII', 'VIII', 'IX', 'X'][$n] ?? (string)$n;
}

function trek_chapter(int $n): array
{
    return trek_chapters()[$n] ?? ['n' => $n, 'roman' => trek_roman($n), 'title' => 'Chapter ' . $n, 'zones' => [], 'ms' => [], 'checks' => [], 'tune' => [], 'lift' => null, 'finish' => null];
}

/** [name, icon] of a zone letter in a chapter, or null. */
function trek_zone_info(int $chapter, string $zone): ?array
{
    $z = trek_chapter($chapter)['zones'][$zone] ?? null;
    return $z ? [$z['name'], $z['icon']] : null;
}

/** The milestones of a chapter: key => [label shown on the card, setting with the base XP, short name, default XP]. */
function trek_milestones(int $chapter): array
{
    return trek_chapter($chapter)['ms'];
}

/** Does this chapter have a map and a start (so it can be played)? Ch II shows "coming soon" until its files exist. */
function trek_chapter_exists(int $chapter): bool
{
    return isset(trek_chapters()[$chapter]) && trek_map($chapter)['w'] > 0 && isset(trek_spots($chapter)['start']);
}

/** Icons for spot types on the map. */
const TREK_SPOT_ICONS = ['start' => '🚪', 'exit' => '🪜', 'camp' => '🏮', 'recruit' => '🧑', 'npc' => '💬', 'chest' => '🧰', 'riddle' => '🎶', 'gate' => '🚧',
    'miniboss' => '👑', 'boss' => '💀', 'duel' => '⚔️', 'hidden' => '✨', 'fetch' => '💧', 'sign' => '🪧', 'cart' => '🛒', 'mush' => '🍄',
    'switch' => '⚙️', 'trade' => '🏺', 'find' => '📕', 'rest' => '🛋️', 'slide' => '🛝'];   // v1.9.2: Chapter II-a; v1.9.4: slide

/**
 * A chapter's spots, keyed by code: ['code','type','name','zone','data' => [k => v],'x','y','sym']. Positions come from the capital
 * letters on the map. A spot whose letter is not on the map is dropped (the test script reports that).
 */
function trek_spots(int $chapter = 1): array
{
    static $cache = [];
    if (isset($cache[$chapter])) return $cache[$chapter];
    $m = trek_map($chapter);
    $at = [];
    foreach ($m['t'] as $y => $row) {
        foreach (str_split($row) as $x => $ch) if (ctype_upper($ch) || ctype_digit($ch)) $at[$ch] = [$x, $y];
    }
    $out = [];
    $lines = trek_lines('trek_spots.txt');
    if (is_file(__DIR__ . '/data/trek_spots_ch' . $chapter . '.txt')) $lines = array_merge($lines, trek_lines('trek_spots_ch' . $chapter . '.txt'));   // v1.9.1: a chapter may bring its own file
    foreach ($lines as $line) {
        $f = array_map('trim', explode('|', $line));
        if (count($f) < 5 || (int)$f[0] !== $chapter) continue;
        $data = [];
        foreach (explode(';', (string)($f[5] ?? '')) as $kv) {
            if (!str_contains($kv, '=')) continue;
            [$k, $v] = explode('=', $kv, 2);
            $data[trim($k)] = trim($v);
        }
        $sym = (string)($data['sym'] ?? '');
        if ($sym === '' || !isset($at[$sym])) continue;
        $out[$f[1]] = ['code' => $f[1], 'type' => $f[2], 'name' => $f[3], 'zone' => $f[4], 'data' => $data, 'sym' => $sym, 'x' => $at[$sym][0], 'y' => $at[$sym][1]];
    }
    return $cache[$chapter] = $out;
}

/** The spot standing on a tile, or null. */
function trek_spot_at(int $chapter, int $x, int $y): ?array
{
    static $idx = [];
    if (!isset($idx[$chapter])) {
        $idx[$chapter] = [];
        foreach (trek_spots($chapter) as $s) $idx[$chapter][$s['x'] . ',' . $s['y']] = $s;
    }
    return $idx[$chapter][$x . ',' . $y] ?? null;
}

/** v1.9.9: the name a party card, fight row or log line shows: the first word, but not a title ("Captain Bracken Spurwing" is Bracken). One word stays as it is. */
function trek_short_name(string $n): string
{
    $w = preg_split('/\s+/', trim($n)) ?: [];
    if (count($w) > 1 && in_array(strtolower(rtrim($w[0], '.')), ['captain', 'sir', 'dr', 'lady', 'lord'], true)) array_shift($w);
    return ($w[0] ?? '') !== '' ? $w[0] : $n;
}

/** The trailmates: key => ['key','npc_slug','calling','grit','nimble','hardiness','luck','chapter','lore']. */
function trek_crew(): array
{
    static $cache = null;
    if ($cache !== null) return $cache;
    $cache = [];
    foreach (trek_lines('trek_crew.txt') as $line) {
        $f = array_map('trim', explode('|', $line));
        if (count($f) < 8) continue;
        $cache[$f[0]] = ['key' => $f[0], 'npc_slug' => $f[1], 'calling' => $f[2], 'grit' => (int)$f[3], 'nimble' => (int)$f[4],
            'hardiness' => (int)$f[5], 'luck' => (int)$f[6], 'chapter' => (int)$f[7], 'lore' => (int)($f[8] ?? 0)];   // v1.9.1: lore is an optional 9th column (0 = 10, as before)
    }
    return $cache;
}

/**
 * What can jump out: "chapter:zone" => ['mult' => % of the base chance, 'list' => [slug => weight]]. From the @pool lines of trek_creatures*.txt
 * (@pool|zone|mult|slug:weight,...|chapter ; the chapter is the optional 5th field, default 1).
 */
function trek_pools(): array
{
    static $cache = null;
    if ($cache !== null) return $cache;
    $cache = [];
    foreach (trek_data_files('trek_creatures') as $file) {
        foreach (trek_lines($file) as $line) {
            if (!str_starts_with($line, '@pool|')) continue;
            $f = array_map('trim', explode('|', $line));
            if (count($f) < 4) continue;
            $list = [];
            foreach (explode(',', $f[3]) as $pair) {
                [$slug, $w] = array_pad(explode(':', trim($pair), 2), 2, '1');
                if ($slug !== '') $list[$slug] = max(1, (int)$w);
            }
            $cache[max(1, (int)($f[4] ?? 1)) . ':' . $f[1]] = ['mult' => max(0, (int)$f[2]), 'list' => $list];
        }
    }
    return $cache;
}

// ------------------------------------------------------------------ importers

/** The items the trek adds. slug => [name, category, price, rarity, tradable, description]. Quest items never bank or get lost (see trek.php). */
const TREK_ITEMS = [
    'camp-kit' => ['Camp Kit', 'misc', 60, 5, 0, 'A rolled kit of tin and cloth for making camp on a trek.'],
    'clean-dew' => ['Clean Dew', 'misc', 20, 8, 0, 'Water from the unblighted pools.'],
    'cellar-key' => ['Cellar Key', 'misc', 30, 8, 0, 'A small old key, still warm.'],
    'blight-shard' => ['Blight Shard', 'misc', 200, 40, 0, 'A black shard that hums and points down.'],
    'lanternroot-seed' => ['Lanternroot Seed', 'misc', 80, 30, 0, 'A seed that glows faintly. TODO: the Lanternroot crop is not built yet.'],
    'glowing-bead' => ['Glowing Bead', 'part', 40, 40, 1, 'Dropped by the Cave Glowworm.'],
    'singing-pebble' => ['Singing Pebble', 'misc', 25, 12, 1, 'A smooth little pebble that hums when the air moves. The Riddle Stone gave it away.'],
    // v1.9.2 Chapter II-a (all four are quest items: they stay in the trek pack, see TREK_QUEST_ITEMS)
    'wet-clay' => ['Wet Clay', 'misc', 10, 8, 0, 'A cold, sticky lump of clay that never quite dries.'],
    'clay-pot' => ['Clay Pot', 'misc', 30, 15, 0, 'A small, lopsided pot, still faintly warm from the wheel. Someone further down will want it.'],
    'overdue-book' => ['Overdue Book', 'misc', 20, 10, 0, 'A swollen library book, very overdue, with a snail-shaped bookmark.'],
    'kiln-key' => ['Kiln Key', 'misc', 30, 8, 0, 'A heavy clay key, glazed blue.'],
    // v1.9.4 Chapter II-b: the pearl is a quest item (it opens the Drum Door); the other two are the Chapter II finish gifts
    'cistern-pearl' => ['Cistern Pearl', 'misc', 60, 20, 0, 'A cloudy pearl as big as a plum, sour to the nose. Old Pinch kept it for a very long time.'],
    'drum-skin' => ['Drum Skin', 'misc', 120, 35, 1, 'A scrap of old drumhead, taut as a promise. It still hums when the wind is right.'],
    'brewhouse-ladle' => ['Brewhouse Ladle', 'misc', 90, 30, 1, 'A copper ladle, dented and well loved. Juniper says it has never made a bad soup.'],
];

/** v1.9.2: the Almanac slots (book.<slug>) that are not named book.ch<N>, with their chapter. */
const TREK_BOOK_CH = ['claybound' => 2, 'silverfin' => 2, 'crossroads' => 2, 'brewhouse' => 2, 'pinch' => 2, 'thrum' => 2];   // v1.9.4: II-b's four

/** Make the trek's items, creatures, text slots and Almanac pages. Safe to run again. Returns counts. */
function trek_import(): array
{
    require_once __DIR__ . '/adventure_data.php';
    require_once __DIR__ . '/catalog.php';
    $made = ['items' => 0, 'creatures' => 0, 'texts' => 0, 'pages' => 0];
    foreach (TREK_ITEMS as $slug => [$name, $cat, $price, $rar, $trade, $desc]) {
        if (q_val('SELECT 1 FROM items WHERE slug = ?', [$slug])) continue;
        db_insert('items', ['name' => $name, 'slug' => $slug, 'category' => $cat, 'base_price' => $price, 'rarity' => $rar, 'tradable' => $trade, 'description' => $desc]);
        $made['items']++;
    }
    // Creatures: same importer as the road creatures, from our file. Left inactive, so no road, lair or town code ever picks them.
    $before = (int)q_val('SELECT COALESCE(MAX(id), 0) FROM creatures');
    $stats = ['items' => 0, 'pages' => 0, 'creatures' => 0];
    foreach (trek_data_files('trek_creatures') as $file) import_creatures_txt($stats, $file);   // v1.9.1: trek_creatures.txt, then trek_creatures_*.txt
    q("UPDATE creatures SET active = 0 WHERE landscapes = 'trek' AND id > ?", [$before]);
    foreach (q("SELECT slug FROM creatures WHERE landscapes = 'trek'")->fetchAll(PDO::FETCH_COLUMN) as $slug) {
        q("UPDATE encyclopedia_entries SET body = REPLACE(body, '[b]Found in:[/b] trek', '[b]Found in:[/b] the Withering trek') WHERE unlock_key = ?", ['creature:' . $slug]);
    }
    $made['creatures'] = $stats['creatures'];
    $made['items'] += $stats['items'];
    $made['texts'] = trek_import_texts();
    // Almanac pages for the book.* texts (the body is filled in from trek_texts when Joshua saves one)
    $titles = ['ch1' => 'Treks: The Wilting Rows', 'blightlings' => 'Blightlings', 'gloomtooth' => 'Gloomtooth', 'lantern-stump' => 'The Lantern Stump', 'glowworm-grotto' => 'The Glowworm Grotto',
        'ch2' => 'Treks: The Weeping Clay', 'claybound' => 'The Claybound', 'silverfin' => 'Silverfin',   // v1.9.2: Chapter II-a pages
        'crossroads' => 'The Crossroads', 'brewhouse' => 'The Brewhouse', 'pinch' => 'Old Pinch', 'thrum' => 'Old Thrum'];   // v1.9.4: Chapter II-b pages
    $n = 0;
    foreach ($titles as $slug => $title) {
        if (q_val('SELECT 1 FROM encyclopedia_entries WHERE unlock_key = ?', ['trek:' . $slug])) continue;
        db_insert('encyclopedia_entries', ['chapter' => 'Treks', 'category' => 'Treks', 'title' => $title, 'body' => trek_drafts()['book.' . $slug] ?? '✏️ To write',   // v1.9.2: a new page starts with its draft
            'unlock_key' => 'trek:' . $slug, 'hint' => 'Go on the Withering trek.', 'sort_order' => 10 + $n]);
        $n++;
    }
    $made['pages'] = $n + $stats['pages'];
    return $made;
}

/**
 * v1.8.8: draft bodies for NEW slots, key => text, from trek_drafts*.txt (key|body). A line break inside a body is a literal \n, or (v1.9.4) simply the next line(s) of the
 * file: a line that does not start with "<key>|" continues the body above it. (Before 1.9.4 only the first line of a body was read, so some Chapter II-a drafts were cut short.)
 * Used only when a slot is first created.
 */
function trek_drafts(): array
{
    $out = [];
    foreach (trek_data_files('trek_drafts') as $file) {
        $key = null;
        foreach (trek_lines($file) as $line) {
            if (preg_match('/^([A-Za-z][A-Za-z0-9_.\-]*)\|(.*)$/s', $line, $m)) {
                $key = trim($m[1]);
                $out[$key] = $m[2];
            } elseif ($key !== null) {
                $out[$key] .= "\n" . $line;
            }
        }
    }
    foreach ($out as $k => $body) {
        $body = trim(str_replace('\n', "\n", $body));
        if ($body === '') unset($out[$k]); else $out[$k] = $body;
    }
    return $out;
}

/** Add missing trek_texts rows from trek_texts.txt; refresh the brief, kind, speaker and order of existing ones; never touch body or status. */
function trek_import_texts(): int
{
    $added = 0;
    $drafts = trek_drafts();
    $lines = [];
    foreach (trek_data_files('trek_texts') as $file) $lines = array_merge($lines, trek_lines($file));   // v1.9.1: trek_texts.txt, then trek_texts_*.txt
    foreach ($lines as $line) {
        $f = array_map('trim', explode('|', $line, 5));
        if (count($f) < 5 || $f[0] === '') continue;
        [$key, $kind, $speaker, $sort, $brief] = $f;
        $ch = preg_match('/^(?:ch|interlude\.|book\.ch)(\d+)\./', $key, $m) || preg_match('/^book\.ch(\d+)$/', $key, $m) ? (int)$m[1] : (TREK_BOOK_CH[substr($key, 5)] ?? 1);   // v1.9.2: Chapter II's book.* slots are chapter 2
        $brief = str_replace(' • ', "\n• ", '• ' . $brief);
        $row = q_one('SELECT id FROM trek_texts WHERE text_key = ?', [$key]);
        if ($row) {
            q('UPDATE trek_texts SET brief = ?, kind = ?, speaker = ?, sort_order = ?, chapter = ? WHERE id = ?', [$brief, $kind, $speaker !== '' ? $speaker : null, (int)$sort, $ch, $row['id']]);
            continue;
        }
        try {
            db_insert('trek_texts', ['text_key' => $key, 'trek_key' => TREK_KEY, 'chapter' => $ch, 'kind' => $kind, 'speaker' => $speaker !== '' ? $speaker : null,
                'brief' => $brief, 'body' => $drafts[$key] ?? null, 'status' => isset($drafts[$key]) ? 'draft' : 'todo', 'sort_order' => (int)$sort, 'updated_at' => null]);   // v1.8.8: a new slot may ship a draft body
            $added++;
        } catch (PDOException $e) { /* a second request added it first */ }
    }
    return $added;
}

/** v2.0.0 text pass (runs once, setting trek_text_pass = 2): final bodies from trek_final_200.txt.
 *  A row takes the final body when it is empty, or still holds the shipped draft. A body Joshua edited is kept.
 *  Every row in the file, and every Chapter I row with a body, becomes status done. */
function trek_apply_final_texts(): int
{
    $final = [];
    $key = null;
    foreach (trek_lines('trek_final_200.txt') as $line) {
        if (preg_match('/^([A-Za-z][A-Za-z0-9_.\-]*)\|(.*)$/s', $line, $m)) {
            $key = trim($m[1]);
            $final[$key] = $m[2];
        } elseif ($key !== null) {
            $final[$key] .= "\n" . $line;
        }
    }
    foreach ($final as $k => $body) {
        $body = trim(str_replace('\n', "\n", $body));
        if ($body === '') unset($final[$k]); else $final[$k] = $body;
    }
    $old = trek_drafts();   // the shipped drafts, before this pass
    $n = 0;
    foreach (q('SELECT id, text_key, chapter, body, status FROM trek_texts')->fetchAll() as $r) {
        $k = $r['text_key'];
        $cur = trim((string)$r['body']);
        if (isset($final[$k])) {
            if ($cur === '' || $cur === trim((string)($old[$k] ?? '')) || $cur === $final[$k]) {
                q('UPDATE trek_texts SET body = ?, status = ? WHERE id = ?', [$final[$k], 'done', $r['id']]);
            } else {
                q('UPDATE trek_texts SET status = ? WHERE id = ?', ['done', $r['id']]);   // Joshua wrote it: his words stay
            }
            $n++;
        } elseif ((int)$r['chapter'] === 1 && $cur !== '' && $r['status'] !== 'done') {
            q('UPDATE trek_texts SET status = ? WHERE id = ?', ['done', $r['id']]);
        }
    }
    return $n;
}

// ------------------------------------------------------------------ trek_text()

/** Every text row once per request: key => [body, brief, status, kind]. */
function trek_text_rows(bool $forget = false): array
{
    static $rows = null;
    if ($forget) { $rows = null; return []; }
    if ($rows === null) {
        $rows = [];
        foreach (q('SELECT text_key, body, brief, status, kind FROM trek_texts')->fetchAll() as $r) $rows[$r['text_key']] = $r;
    }
    return $rows;
}

/** Tokens every text may use ({gnome}, {calling}, {currency}); trek.php sets them once per request from the player. */
function trek_text_vars(?array $set = null): array
{
    static $vars = [];
    if ($set !== null) $vars = $set + $vars;
    return $vars;
}

/**
 * v1.9.2: the row a key reads from. A later chapter's generic slots (hints, camp, knock-out, trail events, banter) fall back to Chapter I's when the
 * later chapter has no written body of its own, so a new chapter only writes what is new. Returns the row with 'text_key' set to the slot really used.
 */
function trek_text_row(string $key): ?array
{
    $rows = trek_text_rows();
    $row = $rows[$key] ?? null;
    if ((!$row || trim((string)$row['body']) === '') && preg_match('/^ch([2-9])\.((?:tut|ui|ko|camp|ev|banter)\..+)$/', $key, $m)) {
        $fb = $rows['ch1.' . $m[2]] ?? null;
        if ($fb && (!$row || trim((string)$fb['body']) !== '')) return $fb + ['text_key' => 'ch1.' . $m[2]];
    }
    return $row ? $row + ['text_key' => $key] : null;
}

/** v1.9.2: for admins only, a small pencil after a text that is still a draft: tap it for the brief and a link to the slot in the editor. */
function trek_draft_marker(string $key, array $row): string
{
    $bullets = array_filter(array_map(fn($l) => trim(ltrim(trim($l), '•')), explode("\n", (string)($row['brief'] ?? ''))), 'strlen');
    $link = function_exists('url') ? url('admin/trek_text.php?open=' . rawurlencode($key) . '#t-' . str_replace('.', '-', $key)) : 'admin/trek_text.php?open=' . rawurlencode($key);
    return ' <details class="trekdraft"><summary aria-label="Draft text, tap for the editor link" title="Draft text">✏️</summary><span class="trekdraftbox"><code>' . e($key) . '</code>'
        . ($bullets ? '<ul>' . implode('', array_map(fn($b) => '<li>' . e($b) . '</li>', $bullets)) . '</ul>' : '')
        . '<a href="' . e($link) . '">Edit this slot</a></span></details>';
}

/**
 * The story text for a slot, as safe HTML. Body written: escaped, line breaks kept, {tokens} filled in (v1.9.2: an admin also sees a pencil after a draft).
 * Body empty: admins see a dashed "TO WRITE" box with Claude's brief, players see nothing (v1.8.3: empty string, CSS hides the empty box).
 */
function trek_text(string $key, array $vars = []): string
{
    $row = trek_text_row($key);
    $body = trim((string)($row['body'] ?? ''));
    if ($body !== '') {
        $out = e($body);
        foreach ($vars + trek_text_vars() as $k => $v) $out = str_replace('{' . $k . '}', e((string)$v), $out);
        $out = nl2br($out, false);
        if (($row['status'] ?? '') === 'draft' && function_exists('is_admin') && is_admin()) $out .= trek_draft_marker((string)$row['text_key'], $row);
        return $out;
    }
    if (!is_admin()) return '';   // v1.8.3: was '…'; an empty .trektext is hidden by CSS
    if (!$row) return '<div class="trek-todo">✏️ NO SLOT <code>' . e($key) . '</code> (add it to trek_texts.txt)</div>';
    $key = (string)$row['text_key'];
    $bullets = array_filter(array_map(fn($l) => trim(ltrim(trim($l), '•')), explode("\n", (string)$row['brief'])), 'strlen');
    return '<div class="trek-todo">✏️ TO WRITE <code>' . e($key) . '</code><ul>' . implode('', array_map(fn($b) => '<li>' . e($b) . '</li>', $bullets)) . '</ul></div>';
}

/** Is this text written (body not empty)? For code that wants to skip an empty line. */
function trek_text_written(string $key): bool
{
    return trim((string)(trek_text_row($key)['body'] ?? '')) !== '';
}

/** After Joshua saves a book.* text, keep the matching Almanac page in step. */
function trek_text_sync_book(string $key, string $body): void
{
    if (!str_starts_with($key, 'book.')) return;
    q('UPDATE encyclopedia_entries SET body = ? WHERE unlock_key = ?', [$body !== '' ? $body : '✏️ To write', 'trek:' . substr($key, 5)]);
}

/** Is this gnome inside a trek right now (so a road walk or explore must wait)? Lives here so adventure.php can ask without loading the engine. */
function trek_inside(int $uid): bool
{
    try {
        // audit 1.9.8: while Treks are closed to this gnome (Treks: open turned off, or the level needed raised) the trek page cannot be used to leave, so it must not hold them
        $g = q_one('SELECT level, role FROM users WHERE id = ?', [$uid]);
        if (!$g || (int)$g['level'] < (int)setting('trek_level') || (setting('trek_open') !== '1' && (string)$g['role'] !== 'admin')) return false;
        return (bool)q_val('SELECT 1 FROM trek_runs WHERE user_id = ? AND inside = 1', [$uid]);
    } catch (Throwable $e) {
        return false;
    }
}
