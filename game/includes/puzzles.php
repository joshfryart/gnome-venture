<?php
declare(strict_types=1);
/**
 * v2.0.68: Puzzles library, uploads and tournaments.
 * Pictures live in puzzle_pics (seeded from PUZZLES; uploads go to uploads/puzzles/{hex}.gif with a {hex}-still.png first frame).
 * Tournaments (setting puzzles_tournaments, only while puzzles_open is on): one picture, fixed pieces and seed, best time counts.
 * Times come from the server clock only (start / finish in puzzles_api.php). Prizes are cosmetic: a trophy or badge.
 */

/** Built-in pictures: slug => [title, file in assets/img/puzzles/, default pieces]. Seeded into puzzle_pics; also the fallback when the table is missing. */
const PUZZLES = [
    'sunflower' => ['Swaying Sunflower', 'sunflower.gif', 54],
    'flower' => ['Spinning Flower', 'flower.gif', 54],
    'balloons' => ['Night Balloons', 'balloons.gif', 54],
    'waves' => ['Sunset Waves', 'waves.gif', 54],
    'balls' => ['Bouncing Balls', 'balls.gif', 54],
    'pig' => ['Mud Bath Pig', 'pig.gif', 96],
    'skeleton' => ['Dancing Skeleton', 'skeleton.gif', 54],
];
const PUZZLE_COUNTS = [24, 54, 96, 150];
const PUZZLE_UP_MAX_BYTES = 1572864;
const PUZZLE_UP_MAX_FRAMES = 150;
const PUZZLE_UP_MAX_WORK = 40000000;
const PUZZLE_DAILY_TRIES = 10;
const PUZZLE_GRACE_S = 600;
const PUZZLE_MIN_MS_PER_PIECE = 400;
const PUZZLE_PLACES = [1 => ['trophy-gold', 'Gold trophy'], 2 => ['badge-silver', 'Silver badge'], 3 => ['badge-bronze', 'Bronze badge'], 0 => ['badge-entered', 'Took part']];

function puzzles_schema(string $PK, string $ID, string $END): array
{
    $t = ["CREATE TABLE IF NOT EXISTS puzzle_pics (
        id $PK,
        slug VARCHAR(64) NOT NULL UNIQUE,
        title VARCHAR(80) NOT NULL,
        file VARCHAR(120) NOT NULL,
        still VARCHAR(120) NOT NULL,
        w INT NOT NULL DEFAULT 0,
        h INT NOT NULL DEFAULT 0,
        frames INT NOT NULL DEFAULT 0,
        bytes INT NOT NULL DEFAULT 0,
        pieces_default INT NOT NULL DEFAULT 54,
        source VARCHAR(8) NOT NULL DEFAULT 'builtin',
        active INT NOT NULL DEFAULT 1,
        sort INT NOT NULL DEFAULT 0,
        kind VARCHAR(8) NOT NULL DEFAULT 'gif',
        cat VARCHAR(24) NULL,
        thumb VARCHAR(120) NULL,
        reserved INT NOT NULL DEFAULT 0,
        unlock_key VARCHAR(100) NULL,
        created_by $ID NULL,
        created_at DATETIME NOT NULL
    )$END", "CREATE TABLE IF NOT EXISTS puzzle_tournaments (
        id $PK,
        title VARCHAR(80) NOT NULL,
        pic_id $ID NOT NULL,
        pieces INT NOT NULL DEFAULT 54,
        starts_at DATETIME NOT NULL,
        ends_at DATETIME NOT NULL,
        status VARCHAR(8) NOT NULL DEFAULT 'draft',
        kind VARCHAR(8) NOT NULL DEFAULT 'gif',
        tier VARCHAR(8) NULL,
        cup_id $ID NULL,
        created_by $ID NULL,
        created_at DATETIME NOT NULL,
        settled_at DATETIME NULL
    )$END", "CREATE TABLE IF NOT EXISTS puzzle_attempts (
        id $PK,
        tournament_id $ID NOT NULL,
        user_id $ID NOT NULL,
        token CHAR(32) NOT NULL UNIQUE,
        seed BIGINT NOT NULL DEFAULT 0,
        started_at DATETIME NOT NULL,
        start_ms BIGINT NOT NULL DEFAULT 0,
        finished_at DATETIME NULL,
        ms INT NULL,
        drops INT NULL,
        status VARCHAR(8) NOT NULL DEFAULT 'open',
        reason VARCHAR(190) NULL,
        place INT NULL
    )$END", "CREATE TABLE IF NOT EXISTS puzzle_runs (
        id $PK,
        token CHAR(32) NOT NULL UNIQUE,
        user_id $ID NOT NULL,
        game VARCHAR(16) NOT NULL,
        day VARCHAR(10) NOT NULL,
        mode VARCHAR(8) NOT NULL,
        size INT NOT NULL DEFAULT 0,
        seed BIGINT NOT NULL DEFAULT 0,
        start_ms BIGINT NOT NULL DEFAULT 0,
        started_at DATETIME NOT NULL,
        ms INT NULL,
        hints INT NOT NULL DEFAULT 0,
        pic_id $ID NULL,
        status VARCHAR(8) NOT NULL DEFAULT 'open'
    )$END", "CREATE TABLE IF NOT EXISTS jigsaw_unlocks (
        id $PK,
        user_id $ID NOT NULL,
        pic_id $ID NOT NULL,
        unlocked_at DATETIME NOT NULL,
        UNIQUE (user_id, pic_id)
    )$END", "CREATE TABLE IF NOT EXISTS puzzle_wins (
        id $PK,
        game VARCHAR(16) NOT NULL,
        day VARCHAR(10) NOT NULL,
        user_id $ID NOT NULL,
        ms INT NOT NULL DEFAULT 0,
        created_at DATETIME NOT NULL,
        UNIQUE (game, day, user_id)
    )$END"];
    $i = ['CREATE INDEX idx_puzzle_runs_user ON puzzle_runs (user_id, game, day, status)',
          'CREATE INDEX idx_puzzle_runs_board ON puzzle_runs (game, day, mode, status)',
          'CREATE INDEX idx_puzzle_att_tu ON puzzle_attempts (tournament_id, user_id, status)',
          'CREATE INDEX idx_puzzle_att_user ON puzzle_attempts (user_id, started_at)',
          'CREATE INDEX idx_puzzle_tour_status ON puzzle_tournaments (status, ends_at)',
          'CREATE INDEX idx_puzzle_tour_kind ON puzzle_tournaments (kind, status, ends_at)'];
    // v2.0.87: Jigsaw (still pictures) shares these tables; existing databases get the new columns here (and puzzles_ensure() adds them if the upgrade has not run)
    $c = [['puzzle_pics', 'kind', "VARCHAR(8) NOT NULL DEFAULT 'gif'"], ['puzzle_pics', 'cat', 'VARCHAR(24) NULL'], ['puzzle_pics', 'thumb', 'VARCHAR(120) NULL'], ['puzzle_pics', 'reserved', 'INT NOT NULL DEFAULT 0'], ['puzzle_pics', 'unlock_key', 'VARCHAR(100) NULL'],
          ['puzzle_tournaments', 'kind', "VARCHAR(8) NOT NULL DEFAULT 'gif'"], ['puzzle_tournaments', 'tier', 'VARCHAR(8) NULL'], ['puzzle_tournaments', 'cup_id', "$ID NULL"],
          ['puzzle_runs', 'pic_id', "$ID NULL"]];
    return [$t, $i, $c];
}

/** Make the tables if the upgrade has not run yet, and add any missing built-in picture. False = no table (callers fall back to PUZZLES). */
function puzzles_ensure(): bool
{
    static $ok = null;
    if ($ok !== null) return $ok;
    try { q('SELECT 1 FROM puzzle_pics LIMIT 1'); q('SELECT 1 FROM puzzle_attempts LIMIT 1'); $ok = true; } catch (Throwable $e) { $ok = false; }
    if (!$ok) {
        try {
            $s = db()->getAttribute(PDO::ATTR_DRIVER_NAME) === 'sqlite';
            [$t, $i] = puzzles_schema($s ? 'INTEGER PRIMARY KEY AUTOINCREMENT' : 'INT UNSIGNED AUTO_INCREMENT PRIMARY KEY', $s ? 'INTEGER' : 'INT UNSIGNED', $s ? '' : ' ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci');
            foreach ($t as $sql) db()->exec($sql);
            foreach ($i as $sql) { try { db()->exec($sql); } catch (Throwable $e) {} }
            $ok = true;
        } catch (Throwable $e) {
            error_log('puzzles_ensure: ' . $e->getMessage());
            return $ok = false;
        }
    }
    puzzles_add_columns();
    try {
        $have = array_flip(q("SELECT slug FROM puzzle_pics WHERE source = 'builtin'")->fetchAll(PDO::FETCH_COLUMN));
        $n = 0;
        foreach (PUZZLES as $slug => [$title, $file, $pieces]) {
            $n++;
            if (isset($have[$slug])) continue;
            $info = @getimagesize(APP_ROOT . '/assets/img/puzzles/' . $file) ?: [0, 0];
            db_insert('puzzle_pics', ['slug' => $slug, 'title' => $title, 'file' => $file, 'still' => preg_replace('/\.gif$/', '-still.png', $file),
                'w' => (int)$info[0], 'h' => (int)$info[1], 'frames' => 0, 'bytes' => (int)@filesize(APP_ROOT . '/assets/img/puzzles/' . $file),
                'pieces_default' => $pieces, 'source' => 'builtin', 'active' => 1, 'sort' => $n * 10, 'created_by' => null, 'created_at' => now()]);
        }
    } catch (Throwable $e) {
        error_log('puzzles_ensure seed: ' . $e->getMessage());
    }
    return $ok;
}

/** v2.0.87: add the Jigsaw columns to tables made before 2.0.87 (the upgrade does the same; this covers a request that comes first). One probe query when nothing is missing. */
function puzzles_add_columns(): void
{
    static $done = false;
    if ($done) return;
    $done = true;
    try {
        $s = db()->getAttribute(PDO::ATTR_DRIVER_NAME) === 'sqlite';
        try { q('SELECT 1 FROM jigsaw_unlocks LIMIT 1'); } catch (Throwable $e) {   // the Places unlock table (2.0.87)
            [$t] = puzzles_schema($s ? 'INTEGER PRIMARY KEY AUTOINCREMENT' : 'INT UNSIGNED AUTO_INCREMENT PRIMARY KEY', $s ? 'INTEGER' : 'INT UNSIGNED', $s ? '' : ' ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci');
            foreach ($t as $sql) if (str_contains($sql, 'jigsaw_unlocks')) db()->exec($sql);
        }
        foreach (puzzles_schema('', $s ? 'INTEGER' : 'INT UNSIGNED', '')[2] as [$tb, $col, $def]) {
            try { q("SELECT $col FROM $tb LIMIT 1"); } catch (Throwable $e) { db()->exec("ALTER TABLE $tb ADD COLUMN $col $def"); }
        }
        try { db()->exec('CREATE INDEX idx_puzzle_tour_kind ON puzzle_tournaments (kind, status, ends_at)'); } catch (Throwable $e) {}
    } catch (Throwable $e) {
        error_log('puzzles_add_columns: ' . $e->getMessage());
    }
}

function puzzle_pic_path(array $p, bool $still = false): string
{
    return ($p['source'] === 'upload' ? 'uploads/puzzles/' : 'assets/img/puzzles/') . ($still ? $p['still'] : $p['file']);
}

/** GIFsaw pictures for the library (kind 'gif'; Jigsaw stills are jigsaw_pics()): rows from puzzle_pics, or the PUZZLES constant when the table is missing. */
function puzzle_pics(bool $activeOnly = true): array
{
    if (puzzles_ensure()) {
        try { return q("SELECT * FROM puzzle_pics WHERE kind = 'gif'" . ($activeOnly ? ' AND active = 1' : '') . ' ORDER BY sort, id')->fetchAll(); } catch (Throwable $e) {}
    }
    $out = [];
    foreach (PUZZLES as $slug => [$title, $file, $n]) $out[] = ['id' => 0, 'slug' => $slug, 'title' => $title, 'file' => $file, 'still' => preg_replace('/\.gif$/', '-still.png', $file), 'pieces_default' => $n, 'source' => 'builtin', 'active' => 1, 'w' => 0, 'h' => 0];
    return $out;
}

/** The JSON row puzzles.js reads. */
function puzzle_js_row(array $p): array
{
    return ['id' => (string)$p['slug'], 'title' => (string)$p['title'], 'pieces' => (int)$p['pieces_default'], 'gif' => url(puzzle_pic_path($p)), 'still' => url(puzzle_pic_path($p, true))];
}

// ---------------- the cast (Jeff hosts, Ffej makes mischief, the Old Wizard gives hints) ----------------

/** A cast picture from assets/img/puzzles/cast/; with a -dark.png twin, both are printed and CSS shows one. Missing art = ''. */
function puzzle_cast(string $name, string $alt = '', string $class = ''): string
{
    $dir = APP_ROOT . '/assets/img/puzzles/cast/';
    if (!is_file($dir . $name . '.png')) return '';
    $c = trim('pzcast ' . $class);
    $lt = '<img class="lt" src="' . e(url('assets/img/puzzles/cast/' . $name . '.png')) . '" alt="' . e($alt) . '" loading="lazy">';
    if (!is_file($dir . $name . '-dark.png')) return '<span class="' . e($c) . '">' . $lt . '</span>';
    return '<span class="' . e($c . ' pz2') . '">' . $lt . '<img class="dk" src="' . e(url('assets/img/puzzles/cast/' . $name . '-dark.png')) . '" alt="' . e($alt) . '" loading="lazy"></span>';
}

// ---------------- uploads ----------------

/** Frames in a GIF (image descriptors), or -1 if the block structure is broken. */
function gif_frame_count(string $bin): int
{
    $n = strlen($bin);
    if ($n < 13 || !in_array(substr($bin, 0, 6), ['GIF87a', 'GIF89a'], true)) return -1;
    $pos = 13;
    $f = ord($bin[10]);
    if ($f & 0x80) $pos += 3 * (2 << ($f & 7));
    $frames = 0;
    $skip = function () use ($bin, $n, &$pos): bool {
        while ($pos < $n) {
            $len = ord($bin[$pos++]);
            if ($len === 0) return true;
            $pos += $len;
        }
        return false;
    };
    while ($pos < $n) {
        $b = ord($bin[$pos++]);
        if ($b === 0x3B) return $frames;
        if ($b === 0x21) {
            $pos++;
            if (!$skip()) return -1;
        } elseif ($b === 0x2C) {
            if ($pos + 9 > $n) return -1;
            $lf = ord($bin[$pos + 8]);
            $pos += 9;
            if ($lf & 0x80) $pos += 3 * (2 << ($lf & 7));
            $pos++;
            if (!$skip()) return -1;
            $frames++;
            if ($frames > 10000) return -1;
        } else {
            return -1;
        }
    }
    return $frames > 0 ? $frames : -1;
}

/** Check an uploaded GIF. Returns [error or '', info: w, h, frames, bytes]. */
function puzzle_check_gif(string $tmp, int $size): array
{
    if ($size <= 0 || $size > PUZZLE_UP_MAX_BYTES) return ['GIFs can be up to 1.5 MB.', []];
    $mime = (string)(new finfo(FILEINFO_MIME_TYPE))->file($tmp);
    $info = @getimagesize($tmp);
    if ($mime !== 'image/gif' || !$info || ($info['mime'] ?? '') !== 'image/gif') return ['That isn’t a GIF.', []];
    [$w, $h] = [(int)$info[0], (int)$info[1]];
    if ($w < 64 || $h < 64 || $w > 640 || $h > 640) return ['Each side must be 64 to 640 pixels (this one is ' . $w . ' × ' . $h . ').', []];
    if ($w / $h < 0.5 || $w / $h > 2) return ['The picture is too long and thin (keep it between 1:2 and 2:1).', []];
    $frames = gif_frame_count((string)file_get_contents($tmp));
    if ($frames < 1) return ['That GIF looks broken (its frames could not be read).', []];
    if ($frames > PUZZLE_UP_MAX_FRAMES) return ['Too many frames: ' . $frames . ' (' . PUZZLE_UP_MAX_FRAMES . ' at most).', []];
    if ($w * $h * $frames > PUZZLE_UP_MAX_WORK) return ['Too much animation for its size (width × height × frames must stay under 40 million).', []];
    return ['', ['w' => $w, 'h' => $h, 'frames' => $frames, 'bytes' => $size]];
}

function puzzle_slug(string $title): string
{
    $base = trim((string)preg_replace('/[^a-z0-9]+/', '-', strtolower($title)), '-') ?: 'puzzle';
    $base = substr($base, 0, 50);
    $slug = $base;
    for ($k = 2; q_val('SELECT 1 FROM puzzle_pics WHERE slug = ?', [$slug]); $k++) $slug = $base . '-' . $k;
    return $slug;
}

// ---------------- tournaments ----------------

function puzzle_tournaments_on(): bool
{
    return setting('puzzles_open') === '1' && setting('puzzles_tournaments') === '1';
}

/** Pieces the board really has for a piece count (same rounding as puzzles.js). */
function puzzle_grid_total(int $n, int $w, int $h): int
{
    if ($w <= 0 || $h <= 0) return $n;
    $cols = max(2, (int)round(sqrt($n * $w / $h)));
    $rows = max(2, (int)round($n / $cols));
    return $cols * $rows;
}

function puzzle_tourney_seed(int $tid): int
{
    return (int)(crc32('pzt|' . $tid) & 0x7fffffff);
}

function puzzle_tourney(int $id): ?array
{
    if (!puzzles_ensure()) return null;
    return q_one('SELECT t.*, p.slug, p.title AS pic_title, p.file, p.still, p.source, p.w, p.h, p.pieces_default, p.thumb, p.cat, p.reserved FROM puzzle_tournaments t JOIN puzzle_pics p ON p.id = t.pic_id WHERE t.id = ?', [$id]);
}

/** 'soon' | 'open' | 'closing' (grace for finishing) | 'ended' | 'draft' | 'settled'. */
function puzzle_tourney_phase(array $t, ?int $now = null): string
{
    if ($t['status'] === 'draft' || $t['status'] === 'settled') return (string)$t['status'];
    $now ??= time();
    $s = strtotime($t['starts_at'] . ' UTC');
    $e = strtotime($t['ends_at'] . ' UTC');
    if ($now < $s) return 'soon';
    if ($now < $e) return 'open';
    if ($now <= $e + PUZZLE_GRACE_S) return 'closing';
    return 'ended';
}

/** Best done time per player, fastest first. */
function puzzle_board(int $tid, int $limit = 20): array
{
    return q("SELECT a.user_id, MIN(a.ms) AS best, COUNT(*) AS runs, COALESCE(u.gnome_name, u.username) AS name FROM puzzle_attempts a JOIN users u ON u.id = a.user_id
              WHERE a.tournament_id = ? AND a.status = 'done' AND " . gnome_in_play_sql('u') . " GROUP BY a.user_id, u.gnome_name, u.username ORDER BY best, MIN(a.finished_at) LIMIT " . max(1, $limit), [$tid])->fetchAll();
}

/** user_ids among the top 3 whose best is under a third of the median best (for an admin to look at). */
function puzzle_flags(int $tid): array
{
    $all = puzzle_board($tid, 100000);
    if (count($all) < 4) return [];
    $b = array_map(fn($r) => (int)$r['best'], $all);
    $m = count($b);
    $med = $m % 2 ? $b[intdiv($m, 2)] : ($b[$m / 2 - 1] + $b[$m / 2]) / 2;
    $out = [];
    foreach (array_slice($all, 0, 3) as $r) if ((int)$r['best'] < $med / 3) $out[(int)$r['user_id']] = true;
    return $out;
}

function puzzle_ms_text(int $ms): string
{
    $s = intdiv($ms, 1000);
    return intdiv($s, 60) . ':' . str_pad((string)($s % 60), 2, '0', STR_PAD_LEFT) . '.' . str_pad((string)intdiv($ms % 1000, 10), 2, '0', STR_PAD_LEFT);
}

/** Start an attempt. Returns [ok, message or token, extra]. v2.0.87: a Jigsaw ('still') tournament takes its pieces and daily tries from its tier, never from a posted count. */
function puzzle_attempt_start(array $u, int $tid): array
{
    $t = puzzle_tourney($tid);
    if (!$t || $t['status'] !== 'live') return [false, 'That tournament isn’t running.', []];
    if (puzzle_tourney_phase($t) !== 'open') return [false, puzzle_tourney_phase($t) === 'soon' ? 'It hasn’t started yet.' : 'This tournament has closed.', []];
    $still = ($t['kind'] ?? 'gif') === 'still';
    $tries = PUZZLE_DAILY_TRIES;
    $pieces = (int)$t['pieces'];
    if ($still) {
        require_once __DIR__ . '/jigsaw.php';
        if (!isset(JIGSAW_TIERS[(string)$t['tier']]) || $t['source'] === 'place') return [false, 'That tournament isn’t running.', []];   // Places pictures can never be a tournament
        $tries = jigsaw_tries((string)$t['tier']);
        $pieces = jigsaw_pieces((string)$t['tier']);
    }
    $uid = (int)$u['id'];
    $day = gmdate('Y-m-d 00:00:00');
    if ((int)q_val('SELECT COUNT(*) FROM puzzle_attempts WHERE tournament_id = ? AND user_id = ? AND started_at >= ?', [$tid, $uid, $day]) >= $tries)
        return [false, 'That’s ' . $tries . ' tries today. Come back tomorrow for more!', []];
    q("UPDATE puzzle_attempts SET status = 'void', reason = 'restarted' WHERE tournament_id = ? AND user_id = ? AND status = 'open'", [$tid, $uid]);
    $token = bin2hex(random_bytes(16));
    $seed = puzzle_tourney_seed($tid);
    db_insert('puzzle_attempts', ['tournament_id' => $tid, 'user_id' => $uid, 'token' => $token, 'seed' => $seed, 'started_at' => now(), 'start_ms' => (int)floor(microtime(true) * 1000), 'status' => 'open']);
    return [true, $token, ['seed' => $seed, 'pieces' => $pieces]];
}

/** Finish an attempt. Returns [ok, message, extra]. The time is the server's, never the browser's. */
function puzzle_attempt_finish(array $u, string $token, int $drops): array
{
    if (!preg_match('/^[a-f0-9]{32}$/', $token)) return [false, 'That run wasn’t found.', []];
    $a = q_one("SELECT * FROM puzzle_attempts WHERE token = ? AND user_id = ?", [$token, (int)$u['id']]);
    if (!$a || $a['status'] !== 'open') return [false, 'That run was already handed in.', []];
    $t = puzzle_tourney((int)$a['tournament_id']);
    $nowMs = (int)floor(microtime(true) * 1000);
    $ms = $nowMs - (int)$a['start_ms'];
    $reason = '';
    if (!$t || $t['status'] !== 'live' || time() > strtotime($t['ends_at'] . ' UTC') + PUZZLE_GRACE_S) $reason = 'finished after the tournament closed';
    else {
        if (($t['kind'] ?? 'gif') === 'still') { require_once __DIR__ . '/jigsaw.php'; $total = jigsaw_pieces((string)$t['tier']); }   // v2.0.87: the tier's real cols x rows
        else $total = puzzle_grid_total((int)$t['pieces'], (int)$t['w'], (int)$t['h']);
        if ($ms < $total * PUZZLE_MIN_MS_PER_PIECE) $reason = 'faster than a gnome can place pieces';
        elseif ($drops < $total - 1) $reason = 'too few pieces moved';
    }
    $st = $reason === '' ? 'done' : 'rejected';
    $n = q("UPDATE puzzle_attempts SET status = ?, finished_at = ?, ms = ?, drops = ?, reason = ? WHERE id = ? AND status = 'open'", [$st, now(), $ms, max(0, $drops), $reason === '' ? null : $reason, (int)$a['id']])->rowCount();
    if ($n !== 1) return [false, 'That run was already handed in.', []];
    $x = ['tier' => $t ? (string)($t['tier'] ?? '') : '', 'kind' => $t ? (string)($t['kind'] ?? 'gif') : 'gif'];   // v2.0.87: for Puzzle Pals (2.0.88) and the page
    if ($st === 'rejected') return [false, 'That run didn’t count: ' . $reason . '.', ['rejected' => true] + $x];
    $best = (int)q_val("SELECT MIN(ms) FROM puzzle_attempts WHERE tournament_id = ? AND user_id = ? AND status = 'done'", [(int)$a['tournament_id'], (int)$u['id']]);
    $rank = 1 + (int)q_val("SELECT COUNT(*) FROM (SELECT user_id, MIN(ms) AS b FROM puzzle_attempts WHERE tournament_id = ? AND status = 'done' GROUP BY user_id) x WHERE x.b < ? + 0", [(int)$a['tournament_id'], $best]);
    $x += ['ms' => $ms, 'best' => $best, 'rank' => $rank];
    if ($t && $x['kind'] === 'still' && !is_guest($u)) {   // v2.0.88 Puzzle Pals: Advanced releases the picture's pals, Expert earns its trophy (guests skipped)
        require_once __DIR__ . '/puzzle_pals.php';
        if ($pp = ppal_on_solve((int)$u['id'], (int)$t['pic_id'], $x['tier'], 'tourney', (int)$a['id'])) $x['ppal'] = $pp;
    }
    return [true, $ms <= $best ? 'A new best: ' . puzzle_ms_text($ms) . '!' : puzzle_ms_text($ms) . '. Your best is still ' . puzzle_ms_text($best) . '.', $x];
}

/** Settle one tournament row (status 'live'): places, notes, then free the picture of a Jigsaw. Returns false if somebody else settled it first. */
function puzzle_settle_one(array $t): bool
{
    if (q("UPDATE puzzle_tournaments SET status = 'settled', settled_at = ? WHERE id = ? AND status = 'live'", [now(), $t['id']])->rowCount() !== 1) return false;
    q("UPDATE puzzle_attempts SET status = 'void', reason = 'never finished' WHERE tournament_id = ? AND status = 'open'", [$t['id']]);
    $still = ($t['kind'] ?? 'gif') === 'still';
    $lead = '🧩 ';
    if ($still) { require_once __DIR__ . '/jigsaw.php'; $lead = '🧩 Jigsaw '; }
    $tag = $still && isset(JIGSAW_TIERS[(string)$t['tier']]) ? ' (' . JIGSAW_TIERS[(string)$t['tier']][0] . ')' : '';
    $rank = 0;
    foreach (puzzle_board((int)$t['id'], 100000) as $r) {
        $rank++;
        $aid = q_val("SELECT id FROM puzzle_attempts WHERE tournament_id = ? AND user_id = ? AND status = 'done' ORDER BY ms, finished_at LIMIT 1", [$t['id'], $r['user_id']]);
        q('UPDATE puzzle_attempts SET place = ? WHERE id = ?', [$rank, $aid]);
        [, $label] = PUZZLE_PLACES[$rank <= 3 ? $rank : 0];
        notify((int)$r['user_id'], $lead . $t['title'] . $tag . ': you placed #' . $rank . ' with ' . puzzle_ms_text((int)$r['best']) . '. ' . $label . ' for your shelf!');
    }
    if ($still) jigsaw_release_reserved([(int)$t['pic_id']]);
    return true;
}

/** Hand out places for tournaments past their finishing window. Cosmetic only (a trophy or badge and a note). Safe to call often. */
function settle_puzzle_tournaments(): void
{
    if (!puzzles_ensure()) return;
    $cut = gmdate('Y-m-d H:i:s', time() - PUZZLE_GRACE_S);
    require_once __DIR__ . '/trade.php';
    foreach (q("SELECT * FROM puzzle_tournaments WHERE status = 'live' AND ends_at < ?", [$cut])->fetchAll() as $t) puzzle_settle_one($t);
}

/** A gnome's puzzle trophies and badges (profile), '' if none. */
function puzzle_badges_html(int $uid): string
{
    if (!puzzles_ensure()) return '';
    $rows = q("SELECT a.place, a.ms, t.title, t.id, t.kind, t.tier FROM puzzle_attempts a JOIN puzzle_tournaments t ON t.id = a.tournament_id WHERE a.user_id = ? AND a.place IS NOT NULL ORDER BY t.ends_at DESC LIMIT 24", [$uid])->fetchAll();
    if (!$rows) return '';
    $h = '<ul class="pzbadges">';
    foreach ($rows as $r) {
        $tt = null;
        $p = (int)$r['place'];
        [$img, $label] = PUZZLE_PLACES[$p <= 3 ? $p : 0];
        $still = ($r['kind'] ?? 'gif') === 'still';   // v2.0.87: a Jigsaw badge says so and carries a small tier pip (the tier's icon)
        $pip = '';
        if ($still) { require_once __DIR__ . '/jigsaw.php'; $tt = JIGSAW_TIERS[(string)$r['tier']] ?? null; if ($tt) $pip = '<span class="pzpip" title="' . e($tt[0]) . '">' . $tt[4] . '</span>'; }
        $h .= '<li title="' . e($label . ': ' . ($still ? 'Jigsaw ' : '') . $r['title'] . ($still && !empty($tt) ? ' (' . $tt[0] . ')' : '')) . '">' . (puzzle_cast($img, $label) ?: '<span class="pzbem">' . ($p >= 1 && $p <= 3 ? ['', '🏆', '🥈', '🥉'][$p] : '🧩') . '</span>') . $pip
            . '<small>#' . $p . ' ' . e($r['title']) . '</small></li>';
    }
    return $h . '</ul>';
}

/** UTC 'Y-m-d H:i:s' to Hollow time for show, and back (admin form). */
function puzzle_local(string $utc, string $fmt = 'D j M, g:i a'): string
{
    try { return (new DateTimeImmutable($utc, new DateTimeZone('UTC')))->setTimezone(hollow_tz())->format($fmt); } catch (Throwable $e) { return $utc; }
}

function puzzle_to_utc(string $local): ?string
{
    if (!preg_match('/^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}$/', $local)) return null;
    try { return (new DateTimeImmutable($local, hollow_tz()))->setTimezone(new DateTimeZone('UTC'))->format('Y-m-d H:i:s'); } catch (Throwable $e) { return null; }
}
