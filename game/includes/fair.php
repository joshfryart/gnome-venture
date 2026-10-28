<?php
declare(strict_types=1);
/**
 * The Grand Harvest Fair (v0.8.1): a monthly crop-quality contest.
 * Every harvest is judged for quality. Each gnome's best harvest per category this month is kept (fair_best).
 * On fair.php a gnome can enter that best (fair_entries). When the month ends, each category is ranked:
 * the top 3 win ribbons and Petals, and the best entry of all wins Best in Show.
 */

/** key => [icon, label, plant kinds that count for this category] */
const FAIR_CATS = [
    'veg' => ['🥕', 'Vegetables', ['vegetable', 'tuber', 'legume']],
    'fruit' => ['🍎', 'Fruit', ['fruit', 'tree', 'nut']],
    'flower' => ['🌻', 'Flowers', ['flower']],
    'grain' => ['🌾', 'Grains', ['grain']],
    'herb' => ['🌿', 'Herbs & spices', ['herb', 'spice']],
    'preserve' => ['🫙', 'Preserves', []],   // v0.9.8: no plant kinds: the best jar from your Pantry this month (see fair_keep_best, pantry_collect_one)
];
const FAIR_BIS = 'bis';                                  // Best in Show: a ribbon row only, never an entry
const FAIR_XP = [1 => 30, 2 => 20, 3 => 10];              // XP for 1st, 2nd, 3rd (Petals come from settings)
const FAIR_COLOURS = [1 => 'blue', 2 => 'red', 3 => 'yellow'];

/** Which fair category a plant kind is judged in, or null (covers are never judged). */
function fair_cat(string $kind): ?string
{
    foreach (FAIR_CATS as $key => [, , $kinds]) {
        if (in_array($kind, $kinds, true)) return $key;
    }
    return null;
}

function fair_cat_label(string $cat): string
{
    return $cat === FAIR_BIS ? 'Best in Show' : FAIR_CATS[$cat][1];
}

function fair_medal(int $place, string $cat): string
{
    if ($cat === FAIR_BIS) return '🏆';
    return [1 => '🥇', 2 => '🥈', 3 => '🥉'][$place] ?? '🎗️';
}

/** The quality word for a 0–100 score. */
function fair_word(int $score): string
{
    return $score >= 80 ? 'Prize-worthy' : ($score >= 65 ? 'Splendid' : ($score >= 50 ? 'Fine' : ($score >= 30 ? 'Good' : 'Fair')));
}

function fair_prev_month(): string
{
    // v1.2.2: Hollow-time months
    $first = (new DateTimeImmutable('@' . time()))->setTimezone(hollow_tz())->setTime(0, 0)->modify('first day of this month');
    return hollow_date('Y-m', $first->getTimestamp() - 1);
}

/**
 * Quality score 0–100 for one harvest. Called with the tile as it was BEFORE harvest.
 *   base     = 0.35 × fertility + 0.25 × the crop's own nutrient + 0.20 × soil life   (0–80; nutrient 50 if the crop has none)
 *   grade    = soil grade points: the no-till grade index, 0 (F) to 10 (S); tilled: 0.6 per soil care star (0–10)
 *   native   = +5 if the crop is native to this region                                (0 or 5)
 *   luck     = 1 point per Luck modifier, up to 4                                     (0–4)
 *   wobble   = random −3 to +3
 * The total is rounded and kept between 0 and 100.
 */
function fair_quality(array $u, array $t, array $p): int
{
    $fert = clamp100((int)$t['fertility']);
    $life = clamp100((int)$t['soil_life']);
    $need = (string)($p['nutrient'] ?? '');
    $nut = isset(NUTRIENTS[$need]) ? clamp100((int)($t[$need] ?? 50)) : 50;
    $base = 0.35 * $fert + 0.25 * $nut + 0.20 * $life;
    $grade = max(0, grade_index($t), (int)round(care_stars($t) * 0.6));   // v0.8.7: soil care stars on tilled squares count up to 3
    $native = !empty($t['_native']) ? 5 : 0;
    $luck = min(4, max(0, eff_mod($u, 'luck')));
    $wobble = random_int(-3, 3);
    require_once __DIR__ . '/breeding110.php';
    $hybrid = breeding110_fair_bonus($p);   // v1.1.0: a small bonus for hybrid crops
    return (int)max(0, min(100, round($base + $grade + $native + $luck + $wobble + $hybrid)));
}

/** Called from do_harvest once the harvest is claimed. Keeps the gnome's best this month per category. */
function fair_record(array $u, array $t, array $p): void
{
    $cat = fair_cat((string)($p['kind'] ?? ''));
    if ($cat === null) return;
    fair_keep_best((int)$u['id'], $cat, (int)$p['id'], fair_quality($u, $t, $p));
}

/** Keep the better of this month's score in a class for a gnome. v0.9.8: $label names a Preserves entry (plant_id 0). */
function fair_keep_best(int $uid, string $cat, int $plantId, int $score, ?string $label = null): void
{
    if (is_guest_uid($uid)) return;   // v2.0.75: guests don't enter contests
    $month = job_period_key('monthly');
    $best = q_one('SELECT id, score FROM fair_best WHERE user_id = ? AND month = ? AND cat = ?', [$uid, $month, $cat]);
    if (!$best) {
        try {
            db_insert('fair_best', ['user_id' => $uid, 'month' => $month, 'cat' => $cat, 'plant_id' => $plantId, 'score' => $score, 'at' => now(), 'label' => $label]);
            return;
        } catch (PDOException $e) {   // two harvests at once: the other one got there first, so update instead
            $best = q_one('SELECT id, score FROM fair_best WHERE user_id = ? AND month = ? AND cat = ?', [$uid, $month, $cat]);
            if (!$best) return;
        }
    }
    if ($score > (int)$best['score']) {
        q('UPDATE fair_best SET plant_id = ?, score = ?, at = ?, label = ? WHERE id = ?', [$plantId, $score, now(), $label, $best['id']]);
    }
}

function fair_in_play(int $uid): bool
{
    return (bool)q_val('SELECT COUNT(*) FROM users u WHERE u.id = ? AND ' . gnome_in_play_sql('u'), [$uid]);
}

/** Copy this month's best in a category into the fair. Re-entering with a better best replaces the entry. */
function fair_enter(array $u, string $cat): array
{
    $uid = (int)$u['id'];
    if (!isset(FAIR_CATS[$cat])) return [false, 'That is not a fair category.'];
    $label = FAIR_CATS[$cat][1];
    if (!fair_in_play($uid)) return [false, 'Only gnomes who are out and about can enter the fair.'];
    $month = job_period_key('monthly');
    $best = q_one('SELECT b.score, b.plant_id, b.label, COALESCE(p.name, b.label) AS crop FROM fair_best b LEFT JOIN plants p ON p.id = b.plant_id
                   WHERE b.user_id = ? AND b.month = ? AND b.cat = ?', [$uid, $month, $cat]);
    if (!$best) return [false, $cat === 'preserve' ? 'Collect a jar from your Pantry first. Your best one goes in.' : 'Harvest a ' . strtolower($label) . ' crop first. Your best one goes in.'];
    $crop = (string)($best['crop'] ?? 'crop');
    $entry = q_one('SELECT id, score FROM fair_entries WHERE user_id = ? AND month = ? AND cat = ?', [$uid, $month, $cat]);
    if ($entry) {
        if ((int)$entry['score'] >= (int)$best['score']) {
            return [false, 'Your ' . strtolower($label) . ' entry is already your best. Harvest a better one to swap it in.'];
        }
        q('UPDATE fair_entries SET plant_id = ?, score = ?, at = ?, label = ? WHERE id = ? AND placed IS NULL',
            [(int)$best['plant_id'], (int)$best['score'], now(), $best['label'], $entry['id']]);
    } else {
        try {
            db_insert('fair_entries', ['user_id' => $uid, 'month' => $month, 'cat' => $cat, 'plant_id' => (int)$best['plant_id'],
                'score' => (int)$best['score'], 'at' => now(), 'label' => $best['label']]);
        } catch (PDOException $e) {   // a double click
            return [false, 'You have already entered this category.'];
        }
    }
    return [true, '🏆 Entered in the ' . $label . ' class: ' . $crop . ', ' . fair_word((int)$best['score']) . ' ' . (int)$best['score'] . '.'];
}

/** Rank a finished month, one category at a time. Safe to run again: every entry is paid only once. */
function settle_fair(): void
{
    $now = job_period_key('monthly');
    require_once __DIR__ . '/trade.php';
    foreach (q('SELECT DISTINCT month FROM fair_entries WHERE placed IS NULL AND month <> ?', [$now])->fetchAll(PDO::FETCH_COLUMN) as $month) {
        fair_judge((string)$month);
    }
}

function fair_judge(string $month): void
{
    // Best score first, then the earlier entry (ties go to whoever entered first).
    $rows = q('SELECT e.*, COALESCE(u.gnome_name, u.username) AS gname, u.banned AS banned, u.banned_until AS banned_until,
                      COALESCE(p.name, e.label) AS crop
               FROM fair_entries e JOIN users u ON u.id = e.user_id LEFT JOIN plants p ON p.id = e.plant_id
               WHERE e.month = ? AND e.placed IS NULL ORDER BY e.score DESC, e.at, e.id', [$month])->fetchAll();
    $n = now();
    $inPlay = [];
    $byCat = [];
    foreach ($rows as $r) {
        // A gnome in a time-out sits this month out. Marking the entry 0 stops it being judged twice.
        if ((int)$r['banned'] !== 0 || (!empty($r['banned_until']) && $r['banned_until'] > $n)) {
            q('UPDATE fair_entries SET placed = 0 WHERE id = ? AND placed IS NULL', [$r['id']]);
            continue;
        }
        $inPlay[] = $r;
        $byCat[$r['cat']][] = $r;
    }
    // v0.8.6: a small class (fewer gnomes than fair_min_entries) pays half prizes, and Best in Show needs that many gnomes in the whole fair
    $minEntries = max(1, (int)setting('fair_min_entries'));
    foreach (array_keys(FAIR_CATS) as $cat) {
        $rank = 0;
        $half = count($byCat[$cat] ?? []) < $minEntries;
        foreach ($byCat[$cat] ?? [] as $r) {
            $rank++;
            db()->beginTransaction();
            // Claim the place first. Only the request that claims it pays out.
            if (q('UPDATE fair_entries SET placed = ? WHERE id = ? AND placed IS NULL', [$rank, $r['id']])->rowCount() === 1 && $rank <= 3) {
                fair_pay((int)$r['user_id'], $rank, $cat, $r, $month, $half);
            }
            db()->commit();
        }
    }
    // Best in Show: the top entry of all categories. Only paid once per month.
    $gnomes = count(array_unique(array_map(fn($r) => (int)$r['user_id'], $inPlay)));
    if ($inPlay && $gnomes >= $minEntries && !q_val('SELECT 1 FROM fair_ribbons WHERE month = ? AND cat = ?', [$month, FAIR_BIS])) {
        $top = $inPlay[0];
        $uid = (int)$top['user_id'];
        db()->beginTransaction();
        $coins = (int)setting('fair_best_in_show');
        try {   // the ribbon row is the claim (unique per gnome, month and class), so a second page load can't pay again
            db_insert('fair_ribbons', ['user_id' => $uid, 'month' => $month, 'cat' => FAIR_BIS, 'place' => 1]);
        } catch (PDOException $e) {
            db()->rollBack();
            return;
        }
        q('UPDATE users SET coins = coins + ?, ribbons = ribbons + 1 WHERE id = ?', [$coins, $uid]);
        q("UPDATE users SET title = 'Fair Champion' WHERE id = ? AND (title IS NULL OR title = '')", [$uid]);
        db()->commit();
        notify($uid, '🏆 Best in Show at the Grand Harvest Fair! Your ' . ($top['crop'] ?? 'crop') . ' (' . fair_word((int)$top['score']) . ' ' . (int)$top['score']
            . ') was the best of the whole fair. Prize: ' . money($coins) . ' and the title “Fair Champion”.');
    }
}

function fair_pay(int $uid, int $rank, string $cat, array $entry, string $month, bool $half = false): void
{
    $coins = (int)setting('fair_prize_' . $rank);
    if ($half) $coins = intdiv($coins, 2);
    q('UPDATE users SET coins = coins + ?, ribbons = ribbons + 1 WHERE id = ?', [$coins, $uid]);
    db_insert('fair_ribbons', ['user_id' => $uid, 'month' => $month, 'cat' => $cat, 'place' => $rank]);
    add_xp($uid, FAIR_XP[$rank]);
    notify($uid, fair_medal($rank, $cat) . ' ' . FAIR_COLOURS[$rank] . ' ribbon! Your ' . ($entry['crop'] ?? 'crop') . ' (' . fair_word((int)$entry['score'])
        . ' ' . (int)$entry['score'] . ') took place #' . $rank . ' in the ' . fair_cat_label($cat) . ' class at the Grand Harvest Fair. Prize: '
        . money($coins) . ' and ' . FAIR_XP[$rank] . ' XP.' . ($half ? ' (A small class this month, so half prizes.)' : ''));
}

/** A compact row of ribbon emojis for a gnome's profile. Each one has a title with the class and month. */
function fair_ribbons_html(int $uid): string
{
    $rows = q('SELECT month, cat, place FROM fair_ribbons WHERE user_id = ? ORDER BY month DESC, id DESC LIMIT 12', [$uid])->fetchAll();
    if (!$rows) return '';
    $h = '<div class="fair-ribbons">';
    foreach ($rows as $r) {
        $medal = fair_medal((int)$r['place'], (string)$r['cat']);
        $title = $medal . ' ' . fair_cat_label((string)$r['cat']) . ', ' . $r['month'];
        $h .= '<span class="fair-ribbon" role="img" aria-label="' . e($title) . '" title="' . e($title) . '">' . $medal . '</span>';
    }
    return $h . '</div>';
}
