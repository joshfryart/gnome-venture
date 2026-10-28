<?php
declare(strict_types=1);
/**
 * v2.0.87: Jigsaw. Classic still-picture jigsaws beside GIFsaw, on the same tables (puzzle_pics.kind = 'still', puzzle_tournaments.kind = 'still') and the same
 * engine (assets/puzzles.js with a "still" mode). The piece count is NOT the player's choice: three fixed tiers, set here. Every picture is 3:2, so the
 * grid is exact (cols x rows). Free play is timed on the server too (puzzle_runs, game 'jigsaw', mode 'practice') for personal bests; it pays nothing.
 * Plan: claude/plan-jigsaw.md.
 */
require_once __DIR__ . '/puzzles.php';

/** tier => [label, cols, rows, timed goes per day in a tournament (setting jigsaw_tries_<tier> overrides), icon]. Pieces = cols x rows. */
const JIGSAW_TIERS = [
    'easy' => ['Easy', 6, 4, 10, '🌱'],
    'advanced' => ['Advanced', 12, 8, 10, '🌿'],
    'expert' => ['Expert', 18, 12, 5, '🌳'],
];
/** Free-play practice goes started per gnome per day (a looser cap than a tournament; stops a token flood). */
const JIGSAW_PRACTICE_STARTS = 120;
/** Built-in pictures: slug => [title, category, file in assets/img/jigsaw/ (thumb = <slug>-thumb.jpg)]. Placeholders until the real art lands (same names). */
const JIGSAWS = [
    'maplewold' => ['Maplewold (placeholder)', 'Regions', 'maplewold.jpg'],
    'maizehollow' => ['Maizehollow (placeholder)', 'Regions', 'maizehollow.jpg'],
    'sunsprinkle' => ['Sunsprinkle Isles (placeholder)', 'Regions', 'sunsprinkle.jpg'],
];
const JIGSAW_CATS = ['Regions', 'Seasons', 'Critters', 'Cosy rooms'];
const JIGSAW_W = 1800;
const JIGSAW_H = 1200;

function jigsaw_pieces(string $tier): int
{
    return isset(JIGSAW_TIERS[$tier]) ? JIGSAW_TIERS[$tier][1] * JIGSAW_TIERS[$tier][2] : 0;
}

/** Tier key for a piece count, or '' (the server only ever accepts a tier, never a free count). */
function jigsaw_tier_for(int $pieces): string
{
    foreach (JIGSAW_TIERS as $k => $t) if ($t[1] * $t[2] === $pieces) return $k;
    return '';
}

function jigsaw_tries(string $tier): int
{
    $d = JIGSAW_TIERS[$tier][3] ?? 10;
    $v = setting('jigsaw_tries_' . $tier);
    return $v === '' ? $d : max(1, min(50, (int)$v));
}

/** Is Jigsaw open to this viewer? (Puzzles open + jigsaw_open; admins always.) */
function jigsaw_open(): bool
{
    return is_admin() || (setting('puzzles_open') === '1' && setting('jigsaw_open') === '1');
}

function jigsaw_tournaments_on(): bool
{
    return setting('puzzles_open') === '1' && setting('jigsaw_open') === '1' && setting('jigsaw_tournaments') === '1';
}

function jigsaw_path(array $p, bool $thumb = false): string
{
    if ($p['source'] === 'place') return 'assets/img/wonders/' . $p['file'];   // the unique-location scene itself (480 x 270), used for the card and the puzzle
    return ($p['source'] === 'upload' ? 'uploads/jigsaw/' : 'assets/img/jigsaw/') . ($thumb ? $p['thumb'] : $p['file']);
}

/** Make the tables/columns (puzzles_ensure) and add any missing built-in still picture. */
function jigsaw_ensure(): bool
{
    static $ok = null;
    if ($ok !== null) return $ok;
    if (!puzzles_ensure()) return $ok = false;
    try {
        $have = array_flip(q("SELECT slug FROM puzzle_pics WHERE kind = 'still' AND source = 'builtin'")->fetchAll(PDO::FETCH_COLUMN));
        $n = 0;
        foreach (JIGSAWS as $slug => [$title, $cat, $file]) {
            $n++;
            if (isset($have[$slug])) continue;
            $info = @getimagesize(APP_ROOT . '/assets/img/jigsaw/' . $file) ?: [0, 0];
            db_insert('puzzle_pics', ['slug' => 'jig-' . $slug, 'title' => $title, 'file' => $file, 'still' => $file, 'thumb' => preg_replace('/\.jpg$/', '-thumb.jpg', $file),
                'cat' => $cat, 'kind' => 'still', 'reserved' => 0, 'w' => (int)$info[0], 'h' => (int)$info[1], 'frames' => 0, 'bytes' => (int)@filesize(APP_ROOT . '/assets/img/jigsaw/' . $file),
                'pieces_default' => 96, 'source' => 'builtin', 'active' => 1, 'sort' => $n * 10, 'created_by' => null, 'created_at' => now()]);
        }
    } catch (Throwable $e) {
        error_log('jigsaw_ensure seed: ' . $e->getMessage());
    }
    jigsaw_seed_places();
    return $ok = true;
}

const JIGSAW_PLACE_KINDS = ['haven', 'wonder', 'delve', 'lair'];

/** A picture for every unique location that has scene art (assets/img/wonders/<kind>-<name>.png, v2.0.86). Source 'place': hidden from a gnome until they first visit (jigsaw_unlock_place). */
function jigsaw_seed_places(): void
{
    try {
        require_once __DIR__ . '/landmarks.php';
        $have = array_flip(q("SELECT unlock_key FROM puzzle_pics WHERE source = 'place'")->fetchAll(PDO::FETCH_COLUMN));
        $n = 0;
        foreach (q("SELECT kind, name FROM landmarks WHERE kind IN ('haven','wonder','delve','lair') ORDER BY region_id, sort_order, id")->fetchAll() as $lm) {
            $n++;
            $key = landmark_scene_slug((string)$lm['kind'], (string)$lm['name']);
            if (isset($have[$key]) || !is_file(APP_ROOT . '/assets/img/wonders/' . $key . '.png')) continue;
            $have[$key] = 1;
            db_insert('puzzle_pics', ['slug' => 'pl-' . substr($key, 0, 44) . '-' . substr(md5($key), 0, 6), 'title' => mb_substr((string)$lm['name'], 0, 80), 'file' => $key . '.png', 'still' => $key . '.png', 'thumb' => $key . '.png',
                'cat' => 'Places', 'kind' => 'still', 'reserved' => 0, 'unlock_key' => $key, 'w' => 480, 'h' => 270, 'frames' => 0, 'bytes' => (int)@filesize(APP_ROOT . '/assets/img/wonders/' . $key . '.png'),
                'pieces_default' => 96, 'source' => 'place', 'active' => 1, 'sort' => 1000 + $n, 'created_by' => null, 'created_at' => now()]);
        }
    } catch (Throwable $e) {
        error_log('jigsaw_seed_places: ' . $e->getMessage());
    }
}

/** A gnome first stands at a unique location: its picture joins their puzzle room. Returns the picture's title when it is NEW, else null. Quiet if the gnome already has it. */
function jigsaw_unlock_place(int $uid, array $lm): ?string
{
    if (!in_array((string)($lm['kind'] ?? ''), JIGSAW_PLACE_KINDS, true) || !jigsaw_ensure()) return null;
    try {
        $p = q_one("SELECT id, title FROM puzzle_pics WHERE source = 'place' AND unlock_key = ? AND active = 1", [landmark_scene_slug((string)$lm['kind'], (string)$lm['name'])]);
        if (!$p || q_val('SELECT 1 FROM jigsaw_unlocks WHERE user_id = ? AND pic_id = ?', [$uid, (int)$p['id']])) return null;
        db_insert('jigsaw_unlocks', ['user_id' => $uid, 'pic_id' => (int)$p['id'], 'unlocked_at' => now()]);
        require_once __DIR__ . '/trade.php';
        if (jigsaw_open()) notify($uid, '🧩 New jigsaw in your puzzle room: ' . $p['title'] . '.');
        return (string)$p['title'];
    } catch (Throwable $e) {   // a second request won the race (UNIQUE), or no table yet: nothing to do
        return null;
    }
}

/** Places a gnome has clearly been to before 2.0.87 (cleared, used, or repaired): unlock them quietly the first time they open Jigsaw. */
function jigsaw_backfill_places(int $uid): void
{
    if (!jigsaw_ensure()) return;
    try {
        require_once __DIR__ . '/landmarks.php';
        $ids = array_unique(array_merge(
            q('SELECT landmark_id FROM landmark_clears WHERE user_id = ?', [$uid])->fetchAll(PDO::FETCH_COLUMN),
            q('SELECT landmark_id FROM landmark_uses WHERE user_id = ?', [$uid])->fetchAll(PDO::FETCH_COLUMN),
            q('SELECT landmark_id FROM landmark_repairs WHERE user_id = ?', [$uid])->fetchAll(PDO::FETCH_COLUMN)));
        foreach ($ids as $id) {
            if ($lm = q_one('SELECT kind, name FROM landmarks WHERE id = ?', [(int)$id])) jigsaw_unlock_place($uid, $lm);
        }
    } catch (Throwable $e) {}
}

/** Pictures this gnome may play: the gallery plus the Places they have unlocked (an admin sees every place). */
function jigsaw_can_play(int $uid, array $p): bool
{
    if ((string)$p['source'] !== 'place' || is_admin()) return true;
    return (bool)q_val('SELECT 1 FROM jigsaw_unlocks WHERE user_id = ? AND pic_id = ?', [$uid, (int)$p['id']]);
}

/** [found, total] Places for the library line. */
function jigsaw_places_count(int $uid): array
{
    $tot = (int)q_val("SELECT COUNT(*) FROM puzzle_pics WHERE source = 'place' AND active = 1");
    $got = is_admin() ? $tot : (int)q_val("SELECT COUNT(*) FROM jigsaw_unlocks u JOIN puzzle_pics p ON p.id = u.pic_id WHERE u.user_id = ? AND p.source = 'place' AND p.active = 1", [$uid]);
    return [$got, $tot];
}

/** The slugs in the table are 'jig-<slug>' for built-ins so they can never clash with a GIFsaw slug (puzzle_pics.slug is UNIQUE). */
function jigsaw_pics(bool $activeOnly = true, ?int $uid = null): array
{
    if (!jigsaw_ensure()) return [];
    try {
        $w = "kind = 'still'" . ($activeOnly ? ' AND active = 1 AND reserved = 0' : '');
        $a = [];
        if ($uid !== null && !is_admin()) { $w .= " AND (source <> 'place' OR id IN (SELECT pic_id FROM jigsaw_unlocks WHERE user_id = ?))"; $a[] = $uid; }   // Places only once visited
        return q("SELECT * FROM puzzle_pics WHERE $w ORDER BY sort, id", $a)->fetchAll();
    } catch (Throwable $e) { return []; }
}

/** The JSON row puzzles.js reads (gif = still = the full picture; thumb for the library card). */
function jigsaw_js_row(array $p): array
{
    $u = url(jigsaw_path($p));
    $row = ['id' => (string)$p['slug'], 'title' => (string)$p['title'], 'cat' => (string)($p['cat'] ?? ''), 'pieces' => 96, 'gif' => $u, 'still' => $u, 'thumb' => url(jigsaw_path($p, true))];
    if ($p['source'] === 'place') $row += ['crop' => 1, 'px' => 1];   // 16:9 pixel scene: the puzzle is its centre 3:2, drawn with hard pixels
    return $row;
}

/** The tier table puzzles.js needs: [{k, label, n, cols, rows}], and pieces => index. */
function jigsaw_js_tiers(): array
{
    $o = [];
    foreach (JIGSAW_TIERS as $k => $t) $o[] = ['k' => $k, 'label' => $t[0], 'n' => $t[1] * $t[2], 'cols' => $t[1], 'rows' => $t[2], 'icon' => $t[4]];
    return $o;
}

/** A gnome's best free-play time per picture slug and tier: [slug][tier] => ms. */
function jigsaw_bests(int $uid): array
{
    if (!jigsaw_ensure()) return [];
    $out = [];
    try {
        foreach (q("SELECT p.slug, r.size, MIN(r.ms) AS best FROM puzzle_runs r JOIN puzzle_pics p ON p.id = r.pic_id WHERE r.user_id = ? AND r.game = 'jigsaw' AND r.status = 'done' GROUP BY p.slug, r.size", [$uid])->fetchAll() as $r) {
            $t = jigsaw_tier_for((int)$r['size']);
            if ($t !== '') $out[(string)$r['slug']][$t] = (int)$r['best'];
        }
    } catch (Throwable $e) {}
    return $out;
}

// ---------------- free play: timed on the server, pays nothing ----------------

/** Start a free-play go on a picture at a tier. Returns [ok, message or token, extra]. */
function jigsaw_practice_start(array $u, string $slug, string $tier): array
{
    if (!jigsaw_open()) return [false, 'Jigsaw isn’t open right now.', []];
    if (!isset(JIGSAW_TIERS[$tier])) return [false, 'Pick Easy, Advanced or Expert.', []];
    $p = q_one("SELECT * FROM puzzle_pics WHERE slug = ? AND kind = 'still' AND active = 1 AND reserved = 0", [$slug]);
    $uid = (int)$u['id'];
    if (!$p || !jigsaw_can_play($uid, $p)) return [false, 'That picture wasn’t found.', []];
    $day = gmdate('Y-m-d');
    if ((int)q_val("SELECT COUNT(*) FROM puzzle_runs WHERE user_id = ? AND game = 'jigsaw' AND day = ?", [$uid, $day]) >= JIGSAW_PRACTICE_STARTS) return [false, 'That’s plenty of puzzles for today! Come back tomorrow.', []];
    q("UPDATE puzzle_runs SET status = 'void' WHERE user_id = ? AND game = 'jigsaw' AND status = 'open'", [$uid]);
    $token = bin2hex(random_bytes(16));
    db_insert('puzzle_runs', ['token' => $token, 'user_id' => $uid, 'game' => 'jigsaw', 'day' => $day, 'mode' => 'practice', 'size' => jigsaw_pieces($tier), 'seed' => 0,
        'start_ms' => (int)floor(microtime(true) * 1000), 'started_at' => now(), 'hints' => 0, 'pic_id' => (int)$p['id'], 'status' => 'open']);
    return [true, $token, []];
}

/** Hand in a free-play go. The time is the server's. Rejects what is too fast or too few drops (same rules as a tournament). Returns [ok, message, extra]. */
function jigsaw_practice_finish(array $u, string $token, int $drops): array
{
    if (!preg_match('/^[a-f0-9]{32}$/', $token)) return [false, 'That go wasn’t found.', []];
    $r = q_one("SELECT * FROM puzzle_runs WHERE token = ? AND user_id = ? AND game = 'jigsaw'", [$token, (int)$u['id']]);
    if (!$r || $r['status'] !== 'open') return [false, 'That go was already handed in.', []];
    $ms = (int)floor(microtime(true) * 1000) - (int)$r['start_ms'];
    $total = (int)$r['size'];
    $st = ($ms < $total * PUZZLE_MIN_MS_PER_PIECE || $drops < $total - 1) ? 'rejected' : 'done';
    if (q("UPDATE puzzle_runs SET status = ?, ms = ? WHERE id = ? AND status = 'open'", [$st, $ms, (int)$r['id']])->rowCount() !== 1) return [false, 'That go was already handed in.', []];
    if ($st === 'rejected') return [false, 'That one didn’t count: too quick for a gnome.', ['rejected' => true]];
    $best = (int)q_val("SELECT MIN(ms) FROM puzzle_runs WHERE user_id = ? AND game = 'jigsaw' AND pic_id = ? AND size = ? AND status = 'done'", [(int)$u['id'], (int)$r['pic_id'], $total]);
    $new = $ms <= $best;
    return [true, $new ? 'A new best: ' . puzzle_ms_text($ms) . '!' : puzzle_ms_text($ms) . '. Your best is ' . puzzle_ms_text($best) . '.', ['ms' => $ms, 'best' => $best, 'new' => $new, 'tier' => jigsaw_tier_for($total)]];
}
