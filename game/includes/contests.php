<?php
declare(strict_types=1);
/**
 * Contests (v0.7.15).
 * The Village Show: each week one everyday crop is judged ("Biggest Pumpkin"). Every time you harvest it, the
 * specimen is measured and your best one is entered automatically. Size comes from how well it was grown:
 * fertility, its own nutrient, soil life, soil grade, and a little luck. Top 3 win prizes when the week ends.
 * Pumpkin Carving: every October, carve a face into one of your pumpkins; everyone votes; top 3 win in November.
 */

/** slug => [contest name, unit, base size, decimals] */
const SHOW_CROPS = [
    'pumpkin' => ['Biggest Pumpkin', 'kg', 8.0, 1],
    'cabbage' => ['Heaviest Cabbage', 'kg', 2.0, 2],
    'carrot' => ['Longest Carrot', 'cm', 18.0, 1],
    'sunflower' => ['Tallest Sunflower', 'cm', 180.0, 0],
    'tomato' => ['Heaviest Tomato', 'g', 220.0, 0],
    'green-bean' => ['Longest Bean', 'cm', 15.0, 1],
    'strawberry' => ['Plumpest Strawberry', 'g', 25.0, 1],
    'beet' => ['Biggest Beetroot', 'g', 350.0, 0],
    'potato' => ['Heaviest Potato', 'g', 400.0, 0],
    'radish' => ['Biggest Radish', 'g', 40.0, 1],
];
const SHOW_PRIZES = [1 => [1000, '@treasure-seed:1'], 2 => [500, 'rich-loam:3'], 3 => [250, 'worm-castings:3']];

/** This week's show crop (the same for everyone; rotates weekly). */
function show_crop(?string $week = null): string
{
    $week ??= job_period_key('weekly');
    $keys = array_keys(SHOW_CROPS);
    $available = array_values(array_filter($keys, fn($k) => (bool)q_val('SELECT 1 FROM plants WHERE slug = ?', [$k])));
    $list = $available ?: $keys;
    return $list[crc32('show|' . $week) % count($list)];
}

function show_size_text(string $crop, float $size): string
{
    [, $unit, , $dec] = SHOW_CROPS[$crop];
    return number_format($size, $dec) . ' ' . $unit;
}

/** Measure a harvested specimen from the square it grew in. Returns a message if it was entered. */
function show_measure(int $uid, array $t, array $p, array $u): ?string
{
    $crop = (string)$p['slug'];
    if ($crop !== show_crop()) return null;
    [$name, , $base] = SHOW_CROPS[$crop];
    $need = (string)($p['nutrient'] ?? '');
    $q = 0.55 + 0.30 * clamp100((int)$t['fertility']) / 100
        + 0.25 * (isset(NUTRIENTS[$need]) ? clamp100((int)($t[$need] ?? 50)) : 50) / 100
        + 0.20 * clamp100((int)$t['soil_life']) / 100
        + 0.05 * max(0, grade_index($t), care_stars($t) * 0.6)   // v0.8.7: soil care stars count a little
        + random_int(0, 250) / 1000
        + 0.01 * max(0, eff_mod($u, 'luck'));
    $size = round($base * $q, SHOW_CROPS[$crop][3]);
    $week = job_period_key('weekly');
    $best = q_val('SELECT size FROM show_entries WHERE week = ? AND user_id = ?', [$week, $uid]);
    if ($best === null || $best === false) {
        db_insert('show_entries', ['week' => $week, 'user_id' => $uid, 'crop' => $crop, 'size' => $size, 'entered_at' => now()]);
    } elseif ($size > (float)$best) {
        q('UPDATE show_entries SET size = ?, entered_at = ? WHERE week = ? AND user_id = ?', [$size, now(), $week, $uid]);
    } else {
        return '🏅 Village Show: this one measures ' . show_size_text($crop, $size) . '. Your best is still ' . show_size_text($crop, (float)$best) . '.';
    }
    return '🏅 Village Show (' . $name . '): this one measures ' . show_size_text($crop, $size) . '! Entered as your best.';
}

/** Give out prizes for any finished week. Safe to call often. */
function settle_shows(): void
{
    $now = job_period_key('weekly');
    require_once __DIR__ . '/trade.php';
    foreach (q('SELECT DISTINCT week FROM show_entries WHERE week <> ? AND placed IS NULL', [$now])->fetchAll(PDO::FETCH_COLUMN) as $week) {
        $rows = q('SELECT e.*, COALESCE(u.gnome_name, u.username) AS name FROM show_entries e JOIN users u ON u.id = e.user_id
                   WHERE e.week = ? AND ' . gnome_in_play_sql('u') . ' ORDER BY e.size DESC, e.entered_at', [$week])->fetchAll();
        $rank = 0;
        foreach ($rows as $r) {
            $rank++;
            db()->beginTransaction();
            if (q('UPDATE show_entries SET placed = ? WHERE id = ? AND placed IS NULL', [$rank, $r['id']])->rowCount() === 1) {
                [$coins, $spec] = SHOW_PRIZES[$rank] ?? [25, ''];
                q('UPDATE users SET coins = coins + ?' . ($rank <= 3 ? ', ribbons = ribbons + 1' : '') . ' WHERE id = ?', [$coins, $r['user_id']]);
                add_xp((int)$r['user_id'], [1 => 30, 2 => 20, 3 => 10][$rank] ?? 5);   // v0.7.42
                $extra = '';
                if ($spec !== '') {
                    [$itemId, $qty] = resolve_job_reward($spec, 'show|' . $week . '|' . $r['user_id']);
                    if ($itemId) { give_item((int)$r['user_id'], $itemId, $qty); $extra = ' and ' . $qty . ' × ' . q_val('SELECT name FROM items WHERE id = ?', [$itemId]); }
                }
                notify((int)$r['user_id'], $rank <= 3
                    ? ['', '🥇', '🥈', '🥉'][$rank] . ' Your ' . show_size_text($r['crop'], (float)$r['size']) . ' entry placed #' . $rank . ' in the ' . SHOW_CROPS[$r['crop']][0] . ' show! Prize: ' . money($coins) . $extra . '.'
                    : '🏅 Thanks for entering the ' . SHOW_CROPS[$r['crop']][0] . ' show (#' . $rank . '). Here’s ' . money($coins) . ' for taking part.');
            }
            db()->commit();
        }
    }
}

// ---------------- Pumpkin carving ----------------

const CARVE_SIZE = 10;

function carving_open(): bool
{
    return (int)gmdate('n') === (int)setting('carving_month') || setting('carving_always') === '1';
}

function carving_year(): int
{
    return (int)gmdate('Y');
}

function carve_save(array $u, array $cells, string $title): array
{
    $uid = (int)$u['id'];
    if (!carving_open()) return [false, 'The carving contest only runs in ' . date('F', mktime(0, 0, 0, (int)setting('carving_month'), 1)) . '.'];
    $pattern = '';
    for ($i = 0; $i < CARVE_SIZE * CARVE_SIZE; $i++) $pattern .= isset($cells[$i]) ? '1' : '0';
    if (substr_count($pattern, '1') < 3) return [false, 'Carve at least a little face first!'];
    $title = mb_substr(trim(preg_replace('/\s+/u', ' ', $title)), 0, 40) ?: 'Untitled';
    require_once __DIR__ . '/moderation.php';
    if ($bad = text_problem($u, $title)) return [false, $bad];
    $pumpkin = (int)q_val("SELECT i.id FROM items i JOIN plants p ON p.produce_item_id = i.id WHERE p.slug = 'pumpkin'");
    db()->beginTransaction();
    if (!$pumpkin || !give_item($uid, $pumpkin, -1)) {
        db()->rollBack();
        return [false, 'You need a pumpkin to carve. Grow one, buy one at a stall, or ask a friend!'];
    }
    $mine = q_val('SELECT id FROM carvings WHERE user_id = ? AND year = ?', [$uid, carving_year()]);
    if ($mine) {
        q('UPDATE carvings SET pattern = ?, title = ?, votes = 0, carved_at = ? WHERE id = ?', [$pattern, $title, now(), $mine]);
        q('DELETE FROM carving_votes WHERE carving_id = ?', [$mine]);
    } else {
        db_insert('carvings', ['user_id' => $uid, 'year' => carving_year(), 'pattern' => $pattern, 'title' => $title, 'votes' => 0, 'carved_at' => now()]);
    }
    db()->commit();
    if (!$mine) add_xp((int)$u['id'], 5);
    return [true, '🎃 “' . $title . '” is on show! ' . ($mine ? '(Your old carving was replaced, and its votes with it.)' : 'Tell your friends to vote.')];
}

function carve_vote(array $u, int $carvingId): array
{
    $uid = (int)$u['id'];
    if (!carving_open()) return [false, 'Voting is closed.'];
    // v0.7.85: a carving by a gnome in a time-out is not on show
    $c = q_one('SELECT c.* FROM carvings c JOIN users u ON u.id = c.user_id WHERE c.id = ? AND c.year = ? AND ' . gnome_in_play_sql('u'), [$carvingId, carving_year()]);
    if (!$c) return [false, 'That carving isn’t on show.'];
    if ((int)$c['user_id'] === $uid) return [false, 'No voting for your own pumpkin!'];
    try {
        db_insert('carving_votes', ['user_id' => $uid, 'carving_id' => $carvingId, 'voted_at' => now()]);
    } catch (PDOException $e) {
        return [false, 'You’ve already voted for that one.'];
    }
    q('UPDATE carvings SET votes = votes + 1 WHERE id = ?', [$carvingId]);
    return [true, '🗳️ Vote counted for “' . $c['title'] . '”.'];
}

/** After the carving month, pay the top 3 once. */
function settle_carving(): void
{
    $year = carving_year();
    foreach (q('SELECT DISTINCT year FROM carvings WHERE placed IS NULL')->fetchAll(PDO::FETCH_COLUMN) as $y) {
        if ((int)$y === $year && (carving_open() || (int)gmdate('n') < (int)setting('carving_month'))) continue;   // still running
        require_once __DIR__ . '/trade.php';
        $rank = 0;
        // v0.7.85: gnomes in a time-out don't place or get prizes (their carving waits until they're back)
        foreach (q('SELECT c.* FROM carvings c JOIN users u ON u.id = c.user_id WHERE c.year = ? AND c.placed IS NULL AND ' . gnome_in_play_sql('u')
                   . ' ORDER BY c.votes DESC, c.carved_at', [$y])->fetchAll() as $c) {
            $rank++;
            if (q('UPDATE carvings SET placed = ? WHERE id = ? AND placed IS NULL', [$rank, $c['id']])->rowCount() !== 1) continue;
            $coins = [1 => 1500, 2 => 800, 3 => 400][$rank] ?? 50;
            q('UPDATE users SET coins = coins + ?' . ($rank <= 3 ? ', ribbons = ribbons + 1' : '') . ' WHERE id = ?', [$coins, $c['user_id']]);
            add_xp((int)$c['user_id'], [1 => 30, 2 => 20, 3 => 10][$rank] ?? 5);
            notify((int)$c['user_id'], '🎃 Your carving “' . $c['title'] . '” came #' . $rank . ' with ' . (int)$c['votes'] . ' votes. Prize: ' . money($coins) . '.');
        }
    }
}

/** A carving pattern as a little picture. */
function carving_html(string $pattern, string $class = 'small'): string
{
    $h = '<div class="pumpkin ' . $class . '">';
    for ($i = 0; $i < CARVE_SIZE * CARVE_SIZE; $i++) $h .= '<i class="' . ($pattern[$i] === '1' ? 'cut' : '') . '"></i>';
    return $h . '</div>';
}

function ensure_contests(): void
{
    if (q_val("SELECT 1 FROM encyclopedia_entries WHERE title = 'Shows and contests' AND chapter = 'General'")) return;
    $eid = db_insert('encyclopedia_entries', ['chapter' => 'General', 'category' => 'Getting started', 'title' => 'Shows and contests',
        'body' => "🏅 [b]The Village Show[/b] judges one everyday crop each week: the biggest pumpkin, the longest carrot, the tallest sunflower… "
            . "Every time you harvest that week’s crop it’s measured, and your best is entered for you. Size comes from good growing: "
            . "fertility, the crop’s own nutrient, soil life, a good soil grade, and a little luck. The top three win prizes and a ribbon.\n\n"
            . "🎃 [b]Pumpkin Carving[/b] runs every October. Carve a face into one of your pumpkins and put it on show. Everyone votes, "
            . "and the top three win prizes in November.",
        'unlock_key' => 'start', 'hint' => '', 'sort_order' => 9]);
    foreach (q("SELECT DISTINCT ue.user_id FROM user_encyclopedia ue JOIN encyclopedia_entries e ON e.id = ue.entry_id WHERE e.unlock_key = 'start'")->fetchAll(PDO::FETCH_COLUMN) as $uid) {
        db_insert('user_encyclopedia', ['user_id' => $uid, 'entry_id' => $eid, 'unlocked_at' => now()]);
    }
}

/** v1.7.2: the Contests hub. One card per contest: what it is, status, your entry, one button. */
function contests_hub_rows(array $u): array
{
    $uid = (int)$u['id'];
    $rows = [];
    // Village Show (weekly)
    $crop = show_crop();
    $in = (bool)q_val('SELECT 1 FROM show_entries WHERE week = ? AND user_id = ?', [job_period_key('weekly'), $uid]);
    $rows[] = ['🏅', 'Village Show', 'This week: ' . SHOW_CROPS[$crop][0] . '.',
        'Closes in ' . nice_time(job_period_left('weekly')), $in, 'show.php', $in ? 'View' : 'Enter'];
    // Grand Harvest Fair (monthly)
    $n = (int)q_val('SELECT COUNT(*) FROM fair_entries WHERE user_id = ? AND month = ?', [$uid, job_period_key('monthly')]);
    $rows[] = ['🏆', 'Grand Harvest Fair', 'Enter your best crop in each class.',
        'Closes in ' . nice_time(job_period_left('monthly')), $n > 0, 'fair.php', $n > 0 ? 'View' : 'Enter', $n > 0 ? $n . ' class' . ($n === 1 ? '' : 'es') : ''];
    // Garden of the Month
    $in = (bool)q_val('SELECT 1 FROM gotm_entries WHERE user_id = ? AND month = ?', [$uid, hollow_date('Y-m')]);
    $d = (int)hollow_date('t') - (int)hollow_date('j');
    $rows[] = ['🌼', 'Garden of the Month', 'Show off a garden. Vote for others.',
        $d <= 0 ? 'Closes today' : 'Closes in ' . $d . ' day' . ($d === 1 ? '' : 's'), $in, 'gotm.php', $in ? 'View' : 'Enter'];
    // Pumpkin Carving (October)
    $month = date('F', mktime(0, 0, 0, (int)setting('carving_month'), 1));
    if (carving_open()) {
        $in = (bool)q_val('SELECT 1 FROM carvings WHERE user_id = ? AND year = ?', [$uid, carving_year()]);
        $rows[] = ['🎃', 'Pumpkin Carving', 'Carve a pumpkin face. Everyone votes.', 'Open now · ends ' . $month, $in, 'carve.php', $in ? 'View' : 'Enter'];
    } else {
        $done = (bool)q_val('SELECT 1 FROM carvings WHERE placed IS NOT NULL');
        $in = (bool)q_val('SELECT 1 FROM carvings WHERE user_id = ? AND year = ?', [$uid, carving_year()]);
        $rows[] = ['🎃', 'Pumpkin Carving', 'Carve a pumpkin face. Everyone votes.', 'Next opens ' . $month, $in, 'carve.php', $done ? 'See results' : 'View'];
    }
    return $rows;
}

function contests_hub_html(array $u): string
{
    $h = '<div class="ccards">';
    foreach (contests_hub_rows($u) as $r) {
        [$icon, $name, $what, $status, $in, $page, $btn] = $r;
        $extra = $r[7] ?? '';
        $h .= '<div class="box ccard"><h3><span aria-hidden="true">' . e($icon) . '</span> ' . e($name) . '</h3>'
            . '<p class="help">' . e($what) . '</p>'
            . '<p class="cstat"><span class="tag">' . e($status) . '</span> '
            . '<span class="tag ' . ($in ? 'cin' : 'cout') . '">' . ($in ? '✔ Entered' . ($extra !== '' ? ' · ' . e($extra) : '') : 'Not yet') . '</span></p>'
            . '<a class="btn small" href="' . e(url($page)) . '">' . e($btn) . '</a></div>';
    }
    return $h . '</div>';
}
