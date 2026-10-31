<?php
declare(strict_types=1);

require_once __DIR__ . '/almanac.php';
require_once __DIR__ . '/world.php';
require_once __DIR__ . '/gnome.php';
require_once __DIR__ . '/gardens.php';
require_once __DIR__ . '/fair.php';   // v0.8.1: every harvest is judged for the Grand Harvest Fair
require_once __DIR__ . '/tools.php';
require_once __DIR__ . '/nutrients.php';
require_once __DIR__ . '/hired_help.php';
require_once __DIR__ . '/jobs.php';
require_once __DIR__ . '/garden_fx.php';   // v1.0.0 wave 2a: crop seasons, weather, pests, companions

/**
 * All gardening rules. Every change is checked on the server, so players can't cheat by editing forms.
 *
 * Soil has three stats per square (0-100):
 *   fertility  -> growth speed (0 = half speed, 50 = normal, 100 = 1.5x)
 *   soil life  -> chance of bigger harvests and saved seeds
 *   moisture   -> how long each watering lasts (up to 2x)
 * Tilling: quick to start, but every till hurts soil life, and tilling a no-till bed wipes it out.
 * No-till: slow sheet-mulch setup, then soil life grows with every harvest.
 */

const ENERGY_COST = ['till' => 1, 'sheet' => 2, 'mulch' => 1, 'broadfork' => 1, 'soil' => 1,
    'plant' => 1, 'water' => 1, 'harvest' => 1, 'dig' => 1, 'weed' => 1];   // v0.7.23 scale (max energy 10 at level 1). Harvest: see harvest_energy_cost()

/** No-till soil grades, lowest to highest. Every GRADE_STEP points is the next grade; S at 900+. */
const SOIL_GRADES = ['F', 'F+', 'D', 'D+', 'C', 'C+', 'B', 'B+', 'A', 'A+', 'S'];
const GRADE_STEP = 90;
const BED_SCORE_MAX = 1000;
const MULCH_MAX_HOURS = 24 * 21;   // mulch can be stacked up to 3 weeks of cover

class UserError extends RuntimeException {}

function ts(?string $dt): int
{
    return $dt ? (int)strtotime($dt . ' UTC') : 0;
}

function clamp100(int $n): int
{
    return max(0, min(100, $n));
}

// ----------------------------------------------------------------- No-till grades & upkeep

/** Grade index 0 (F) .. 10 (S) for a no-till bed, or -1 for anything else. */
function grade_index(array $t): int
{
    return $t['method'] === 'notill' ? min(10, intdiv(max(0, (int)$t['bed_score']), GRADE_STEP)) : -1;
}

function grade_name(int $i): string
{
    return $i < 0 ? '—' : SOIL_GRADES[$i];
}

// ----------------------------------------------------------------- Soil care for tilled squares (v0.8.7)

const CARE_NAMES = ['Rough ground', 'Workable', 'Good tilth', 'Fine tilth', 'Rich loam', 'Garden loam'];

/** Points needed for stars 1..5 (setting care_star_points, e.g. "3,7,14,21,30"). */
function care_steps(): array
{
    $n = array_values(array_filter(array_map('intval', explode(',', (string)setting('care_star_points'))), fn($x) => $x > 0));
    sort($n);
    return count($n) === 5 ? $n : [3, 7, 14, 21, 30];
}

function care_stars_for(int $points): int
{
    $s = 0;
    foreach (care_steps() as $need) if ($points >= $need) $s++;
    return $s;
}

/** A tilled square's points after any decay: wild ground (no till, nothing growing) loses a star every care_decay_days. */
function care_points(array $t): int
{
    $pts = max(0, (int)($t['care'] ?? 0));
    if ($pts === 0 || ($t['method'] ?? '') === 'notill' || (int)$t['tilled'] || !empty($t['plant_id']) || empty($t['care_at'])) return $pts;
    $lost = intdiv(max(0, time() - ts($t['care_at'])), max(1, (int)setting('care_decay_days')) * 86400);
    if ($lost <= 0) return $pts;
    $stars = care_stars_for($pts) - $lost;
    return $stars <= 0 ? 0 : care_steps()[$stars - 1];
}

/** Soil care stars 0..5 for a tilled square (0 for no-till beds: they have grades instead). */
function care_stars(array $t): int
{
    return ($t['method'] ?? '') === 'notill' ? 0 : care_stars_for(care_points($t));
}

function care_star_text(int $stars): string
{
    return str_repeat('★', $stars) . str_repeat('☆', 5 - $stars);
}

/**
 * After a harvest from a tilled square ($t is the square as it was before). Earns 1 point when a soil improver went in since
 * the last harvest and soil life was at least care_min_life, at most once a game day per square. Returns a message when a star is gained.
 */
function care_after_harvest(array $t): string
{
    $day = job_period_key('daily');
    $before = care_points($t);
    $earn = (int)($t['care_fed'] ?? 0) === 1 && (int)$t['soil_life'] >= (int)setting('care_min_life') && ($t['care_day'] ?? '') !== $day;
    if ($earn && q('UPDATE plot_tiles SET care = ?, care_day = ?, care_at = ?, care_fed = 0 WHERE id = ? AND (care_day IS NULL OR care_day <> ?)',
            [$before + 1, $day, now(), $t['id'], $day])->rowCount() === 1) {
        $stars = care_stars_for($before + 1);
        if ($stars > care_stars_for($before)) {
            return '🌾 Soil care rose to ' . care_star_text($stars) . ' ' . CARE_NAMES[$stars] . '! This square grows faster and tilling it does less harm.';
        }
        return '';
    }
    q('UPDATE plot_tiles SET care = ?, care_at = ?, care_fed = 0 WHERE id = ?', [$before, now(), $t['id']]);
    return '';
}

/** How much soil life a till costs: 15, softened by 2 a star (5 at most stars). */
function care_till_damage(array $t): int
{
    return max(5, 15 - 2 * care_stars($t));
}

/** What's wrong with a no-till bed right now. An empty list means it's well kept. Mulch is stored in hours of cover. */
function bed_problems(array $t): array
{
    $p = [];
    if ((int)$t['mulch'] <= 0) $p['mulch'] = 'No mulch left';
    if ((int)$t['weeds'] >= 40) $p['weeds'] = 'Weeds are taking over';
    if ((int)$t['moisture'] < 20) $p['moisture'] = 'Soil is drying out';
    if ((int)$t['fertility'] < 25) $p['fertility'] = 'Soil is hungry';
    return $p;
}

/** Grade checkpoints: once reached, a bed can't fall below them unless tilled or neglected for 14 days straight. */
const GRADE_CHECKPOINTS = [720, 360];   // A, C

function checkpoint_name(int $cp): string
{
    return $cp >= 720 ? 'A' : ($cp >= 360 ? 'C' : '');
}

/**
 * Run the hourly upkeep clock for a no-till bed since it was last checked. Gentle by design:
 * - mulch cover counts down one hour at a time (straw lasts 6 days)
 * - weeds grow slowly under mulch, faster on bare soil
 * - moisture dries slowly under mulch, faster on bare soil
 * - well-kept hours earn points; each problem costs 1 point an hour
 * - checkpoints at C and A hold the grade unless the bed is neglected for 14 days in a row
 * Uses absolute clock hours, so the result doesn't depend on how often the page is loaded.
 */
function bed_tick(array $t, array $owner = []): array   // v0.9.1: takes the garden owner's user row (calling + level) instead of the calling name
{
    if ($t['method'] !== 'notill') return $t;
    $last = ts($t['maint_at']);
    if (!$last) {
        $t['maint_at'] = now();
        return $t;
    }
    $hours = min(24 * 90, intdiv(time() - $last, 3600));   // catch up at most 90 days
    if ($hours < 1) return $t;
    $weedSlow = max(1, calling_perk($owner, 'weed_slow', 1));   // v0.9.1: Thornblade tiers: weeds grow 1/N as fast
    $noWeeds = calling_perk($owner, 'no_weeds') > 0;            // v0.9.1: Thornblade master: weeds never grow
    $mulchForever = calling_perk($owner, 'mulch_forever') > 0;  // v0.9.1: Rootwarden master: mulch never wears down
    $neverSlip = calling_perk($owner, 'never_slip') > 0;        // v0.9.1: Rootwarden master: no points lost from neglect
    $gradePct = calling_perk($owner, 'grade_pct');              // v0.9.1: Rootwarden: faster grades
    if (!empty($t['_hedge'])) $weedSlow *= 2;                // a hedge beside the bed keeps blown seed out (v0.7.34)
    $weedClim = max(0.1, 1 + (int)($t['_clim']['weeds'] ?? 0) / 100);   // v0.8.9: rainy climates grow weeds faster
    $weedMulched = max(1, (int)round(max(1, (int)setting('notill_weed_hours')) * $weedSlow / $weedClim));
    $weedBare = max(1, (int)round(max(1, (int)setting('notill_weed_hours_bare')) * $weedSlow / $weedClim));
    $dryMulched = max(1, (int)setting('notill_dry_hours'));
    $dryBare = max(1, (int)setting('notill_dry_hours_bare'));
    $gain = (int)setting('notill_score_per_hour');
    $graceHours = ((int)setting('notill_checkpoint_days') + calling_perk($owner, 'checkpoint_days')) * 24;   // v0.9.1: tiered
    $hourIndex = intdiv($last, 3600);
    for ($h = 1; $h <= $hours; $h++) {
        $abs = $hourIndex + $h;
        $bare = (int)$t['mulch'] <= 0;
        if (!$mulchForever) $t['mulch'] = max(0, (int)$t['mulch'] - 1);   // v0.9.1
        if (!$noWeeds && $abs % garden_wind_weeds((int)$t['plot_id'], $abs * 3600, $bare ? $weedBare : $weedMulched) === 0) $t['weeds'] = clamp100((int)$t['weeds'] + 1);   // v1.0.0: windy days spread weeds faster
        if ($abs % ($bare ? $dryBare : $dryMulched) === 0) $t['moisture'] = clamp100((int)$t['moisture'] - 1);

        $problems = count(bed_problems($t));
        $score = (int)$t['bed_score'];
        if ($problems === 0) {
            $delta = $gain + ($t['plant_id'] ? $gain : 0);
            $score += $delta;
            if ($gradePct > 0) {   // v0.9.1: Rootwarden tiers: faster grades; the fraction is a dice roll, so 25% is really 25% on average
                $x = $delta * $gradePct;
                $score += intdiv($x, 100) + (random_int(1, 100) <= $x % 100 ? 1 : 0);
            }
            $t['neglect_hours'] = 0;
        } else {
            if (!$neverSlip) $score -= $problems;   // v0.9.1
            $t['neglect_hours'] = $neverSlip ? 0 : (int)$t['neglect_hours'] + 1;   // v0.9.1: masters never lose a checkpoint either
            if ($t['neglect_hours'] >= $graceHours && (int)$t['checkpoint'] > 0) {
                // Two weeks of neglect: the bed loses its checkpoint (A drops to C, C drops to none).
                $t['checkpoint'] = (int)$t['checkpoint'] >= 720 ? 360 : 0;
                $t['neglect_hours'] = 0;
            }
        }
        $score = min(BED_SCORE_MAX, max((int)$t['checkpoint'], $score));
        foreach (GRADE_CHECKPOINTS as $cp) {
            if ($score >= $cp && (int)$t['checkpoint'] < $cp) {
                $t['checkpoint'] = $cp;
                $t['neglect_hours'] = 0;   // a fresh checkpoint gets a fresh 14-day grace period
            }
        }
        $t['bed_score'] = $score;
    }
    $t['maint_at'] = gmdate('Y-m-d H:i:s', $last + $hours * 3600);
    return $t;
}

/**
 * Soil amendments work in slowly. Compost and friends go into a "feeding" pool on the square
 * and release into fertility and soil life a little every minute, evenly, until the pool is empty.
 * Uses whole clock minutes from feed_at, so page loads don't change the result.
 * (feed_hours column now stores minutes; renamed in v0.7.51.)
 */
function feed_tick(array $t): array
{
    $left = (int)($t['feed_hours'] ?? 0);
    if ($left <= 0) return $t;
    $from = ts($t['feed_at']) ?: time();
    $h = min($left, intdiv(time() - $from, 60));
    if ($h < 1) return $t;
    if ($h >= $left) {
        $rf = (int)$t['feed_fert'];
        $rl = (int)$t['feed_life'];
    } else {
        $rf = intdiv((int)$t['feed_fert'] * $h, $left);
        $rl = intdiv((int)$t['feed_life'] * $h, $left);
    }
    foreach (['n', 'p', 'k'] as $nu) {
        $pool = (int)($t['feed_' . $nu] ?? 0);
        $r = $h >= $left ? $pool : intdiv($pool * $h, $left);
        $t[$nu] = clamp100((int)($t[$nu] ?? 50) + $r);
        $t['feed_' . $nu] = $h >= $left ? 0 : $pool - $r;
    }
    $t['fertility'] = clamp100((int)$t['fertility'] + $rf);
    $t['soil_life'] = clamp100((int)$t['soil_life'] + $rl);
    $t['feed_fert'] = (int)$t['feed_fert'] - $rf;
    $t['feed_life'] = (int)$t['feed_life'] - $rl;
    $t['feed_hours'] = $left - $h;
    $t['feed_at'] = $t['feed_hours'] > 0 ? gmdate('Y-m-d H:i:s', $from + $h * 60) : null;
    if ($t['feed_hours'] <= 0) {
        $t['feed_fert'] = 0;
        $t['feed_life'] = 0;
    }
    return $t;
}

/** Seconds until the square's current feeding is fully worked in (0 = ready for more). */
function feed_seconds_left(array $t): int
{
    $left = (int)($t['feed_hours'] ?? 0);
    if ($left <= 0) return 0;
    return max(30, ts($t['feed_at']) + $left * 60 - time());
}

/** How many minutes an amendment takes to work in: from the item's effects, or the game setting. */
function amendment_minutes(array $item): int
{
    $fx = json_decode((string)$item['effects'], true) ?: [];
    $cap = max(1, (int)setting('amend_max_minutes'));   // v0.7.54: nothing takes longer than this (an old "hours" value just means "slow")
    return max(1, min($cap, (int)($fx['minutes'] ?? (isset($fx['hours']) ? $cap : setting('amend_minutes')))));
}

function mulch_text(int $hours): string
{
    if ($hours <= 0) return 'none — bare soil!';
    return $hours >= 48 ? (int)floor($hours / 24) . ' days left' : $hours . ' hours left';
}

/** Almanac pages & milestones for reaching soil grades C, B, A and S for the first time. */
function soil_grade_unlocks(int $uid, int $gradeIndex): array
{
    $msgs = [];
    foreach (['c' => 4, 'b' => 6, 'a' => 8, 's' => 10] as $letter => $need) {
        if ($gradeIndex >= $need && unlock_entries($uid, 'soil:' . $letter)) {
            $msgs[] = '🪱 A no-till bed reached soil grade ' . strtoupper($letter) . '! New Almanac page.';
        }
    }
    return $msgs ? array_merge($msgs, check_milestones($uid)) : [];
}

function refresh_energy(array &$u): void
{
    $max = max_energy($u);
    [$amt, $per] = energy_tick();   // v0.9.0: N energy every so many seconds
    $last = ts($u['energy_updated_at']);
    if ((int)$u['energy'] >= $max || !$last) {
        q('UPDATE users SET energy_updated_at = ? WHERE id = ?', [now(), $u['id']]);
        $u['energy_updated_at'] = now();
        return;
    }
    $ticks = intdiv(time() - $last, $per);
    if ($ticks > 0) {
        $new = min($max, (int)$u['energy'] + $ticks * $amt);
        $stamp = $new >= $max ? time() : $last + $ticks * $per;
        q('UPDATE users SET energy = ?, energy_updated_at = ? WHERE id = ?', [$new, gmdate('Y-m-d H:i:s', $stamp), $u['id']]);
        $u['energy'] = $new;
        $u['energy_updated_at'] = gmdate('Y-m-d H:i:s', $stamp);
    }
}

function spend_energy(int $uid, int $n): bool
{
    return q('UPDATE users SET energy = energy - ? WHERE id = ? AND energy >= ?', [$n, $uid, $n])->rowCount() === 1;
}

/** Best power of a tool type the player owns (0 = none). Tools: {"tool":"till","power":2} */
function tool_power(int $uid, string $tool): int
{
    return tool_tier($uid, $tool);   // kept for older code: the best tier of that tool type
}

/**
 * v0.7.86: energy for harvesting one square of this crop, by how rare it is: everyday and staple crops, uncommon
 * crops and flowers, treasure crops. The three numbers are the setting harvest_energy_tiers (default 1,2,3).
 * The tier is worked out the same way item_rarity() does: the best tier the crop has in any region.
 */
function harvest_energy_cost(int $plantId): int
{
    static $cache = [];
    if (isset($cache[$plantId])) return $cache[$plantId];
    $costs = array_map(fn($s) => max(0, (int)trim($s)), explode(',', (string)setting('harvest_energy_tiers')));
    if (count($costs) < 3) $costs = [1, 2, 3];
    $p = q_one('SELECT kind, common FROM plants WHERE id = ?', [$plantId]);
    $band = 0;   // 0 everyday or staple, 1 uncommon or flower, 2 treasure
    if ($p && !(int)$p['common'] && $p['kind'] !== 'flower') {
        $rank = ['staple' => 0, 'flower' => 1, 'uncommon' => 1, 'treasure' => 2];
        $tiers = q('SELECT tier FROM plant_regions WHERE plant_id = ?', [$plantId])->fetchAll(PDO::FETCH_COLUMN);
        if ($tiers) $band = min(array_map(fn($t) => $rank[$t] ?? 0, $tiers));
    } elseif ($p && $p['kind'] === 'flower') {
        $band = 1;
    }
    return $cache[$plantId] = $costs[$band];
}

/** Energy one action costs. v0.7.86: a harvest costs by the crop's tier when $plantId is given (harvest_energy_cost). */
function action_cost(int $uid, string $action, int $plantId = 0): int
{
    if ($action === 'harvest' && $plantId) return harvest_energy_cost($plantId);
    $base = ENERGY_COST[$action] ?? 1;
    $cost = isset(ACTION_TOOL[$action]) ? tool_energy($base, tool_tier($uid, ACTION_TOOL[$action])) : $base;
    if ($action === 'weed' || $action === 'sheet') {   // v0.9.1: Thornblade weeds free; Rootwarden sheet mulching costs less (own garden only)
        $me = q_one('SELECT id, calling, level, calling_qt FROM users WHERE id = ?', [$uid]) ?: [];
        if ($action === 'weed' && calling_perk($me, 'free_weeding') > 0) return 0;
        if ($action === 'sheet') $cost = max(0, $cost - calling_perk($me, 'sheet_discount'));
    }
    return $cost;
}

/**
 * Do an action on several squares at once with a tool that reaches further: 'three' = this square and its
 * row neighbours, 'row' = the whole row. Squares the action doesn't suit are skipped quietly.
 * Stops when the gnome runs out of energy or of the seed/compost/mulch being used. Returns [ok, messages].
 */
function garden_area_action(int $uid, string $action, int $x, int $y, int $itemId, string $reach): array
{
    $type = ACTION_TOOL[$action] ?? null;
    $max = $type ? tool_reach(tool_tier($uid, $type)) : 1;
    $want = $reach === 'row' ? 99 : ($reach === 'three' ? 3 : 1);
    if ($want > $max) return [false, ['Your tool doesn’t reach that far. A better ' . strtolower(TOOL_TYPES[$type][0] ?? 'garden') . ' tool would.']];
    if ($want === 1) return garden_action($uid, $action, $x, $y, $itemId);
    // Squares along the same yard row (beds can be moved about the yard since v0.7.34)
    $plotId = active_plot_id($uid);
    $me = q_one('SELECT yx, yy FROM plot_tiles WHERE plot_id = ? AND x = ? AND y = ?', [$plotId, $x, $y]);
    if (!$me) return [false, ['That square isn’t part of your plot.']];
    $row = q('SELECT x, y, yx, yy FROM plot_tiles WHERE plot_id = ? AND yy = ? ORDER BY yx', [$plotId, (int)$me['yy']])->fetchAll();
    if ($want < 99) $row = array_filter($row, fn($r) => abs((int)$r['yx'] - (int)$me['yx']) <= 1);
    usort($row, fn($a, $b) => abs((int)$a['yx'] - (int)$me['yx']) <=> abs((int)$b['yx'] - (int)$me['yx']));   // the chosen square first
    $done = 0;
    $free = 0;
    $msgs = [];
    $firstErr = null;
    foreach ($row as $sq) {
        $before = (int)q_val('SELECT energy FROM users WHERE id = ?', [$uid]);
        [$ok, $m] = garden_action($uid, $action, (int)$sq['x'], (int)$sq['y'], $itemId);
        if ($ok) {
            $done++;
            $msgs = array_merge($msgs, $m);
            // A path beside the square: easy to reach, sometimes no energy (v0.7.34)
            if ($done > 1 && !empty(yard_tile_bonuses(['plot_id' => $plotId, 'yx' => $sq['yx'], 'yy' => $sq['yy']])['path'])
                && ($spent = $before - (int)q_val('SELECT energy FROM users WHERE id = ?', [$uid])) > 0
                && random_int(1, 100) <= (int)setting('yard_path_free_percent')) {
                q('UPDATE users SET energy = energy + ? WHERE id = ?', [$spent, $uid]);
                $free++;
            }
            continue;
        }
        $err = (string)end($m);
        $firstErr ??= $err;
        if (str_contains($err, 'too tired') || str_contains($err, 'don’t have') || str_contains($err, 'missing materials')) {
            $msgs[] = $err;
            break;
        }
    }
    if (!$done) return [false, [$firstErr ?? 'Nothing to do on that row.']];
    $verb = ['till' => 'Tilled', 'water' => 'Watered', 'plant' => 'Planted', 'soil' => 'Worked compost into',
        'mulch' => 'Mulched', 'weed' => 'Weeded', 'harvest' => 'Harvested'][$action] ?? 'Tended';
    if ($action === 'harvest') return [true, harvest_summary($msgs, $done)];   // v0.7.61
    // Repeated per-square lines ("You till the soil.") are folded into one summary
    $msgs = array_values(array_unique(array_filter($msgs, fn($m) => !preg_match('/^(You till the soil|You plant |You water |You work |You spread |You pile |🌿 You pull)/u', $m))));
    array_unshift($msgs, (TOOL_TYPES[$type][1] ?? '') . ' ' . $verb . ' ' . $done . ' square' . ($done === 1 ? '' : 's') . '.'
        . ($free ? ' 🪨 The path made ' . $free . ' of them cost no energy.' : ''));
    return [true, $msgs];
}

/**
 * v0.7.54: do one action on a set of squares the gnome picked (select mode on the garden page).
 * $squares: [[x, y], …]. $queue: [[item id, how many (0 = as many as it takes)], …]: seeds are used in order,
 * moving to the next kind when one is used up; amendments and mulch use one item. Stops when out of energy;
 * squares that can't take it are skipped and counted by reason. Returns [ok, messages].
 */
function garden_batch_action(int $uid, string $action, array $squares, array $queue): array
{
    if (!in_array($action, ['plant', 'soil', 'mulch', 'till', 'water', 'harvest', 'weed', 'dig', 'sheet'], true)) return [false, ['Unknown action.']];
    $needsItem = in_array($action, ['plant', 'soil', 'mulch', 'sheet'], true);   // v0.7.63: sheet mulch too
    if ($needsItem && !$queue) return [false, ['Pick something to use first.']];
    $done = 0;
    $used = [];      // item id => how many used
    $skipped = [];   // reason => count
    $other = [];
    $stop = null;
    $qi = 0;
    foreach ($squares as [$x, $y]) {
        // v0.7.85: a group never tills a no-till bed (strict: it loses its soil life and grade). Single squares still ask.
        if ($action === 'till' && q_val('SELECT method FROM plot_tiles WHERE plot_id = ? AND user_id = ? AND x = ? AND y = ?', [active_plot_id($uid), $uid, (int)$x, (int)$y]) === 'notill') {
            $skipped['a no-till bed, which tilling would ruin'] = ($skipped['a no-till bed, which tilling would ruin'] ?? 0) + 1;
            continue;
        }
        while (true) {
            if ($needsItem) {
                while ($qi < count($queue) && $queue[$qi][1] > 0 && ($used[$queue[$qi][0]] ?? 0) >= $queue[$qi][1]) $qi++;
                if ($qi >= count($queue)) break 2;   // everything picked has been used
            }
            $item = $needsItem ? (int)$queue[$qi][0] : 0;
            [$ok, $m] = garden_action($uid, $action, (int)$x, (int)$y, $item);
            if ($ok) {
                $done++;
                if ($item) $used[$item] = ($used[$item] ?? 0) + 1;
                foreach ($m as $line) if (!preg_match('/^(You till the soil|You plant |You water |You work |You spread |You pile |🌿 You pull|You dig up |🍂 You lay cardboard)/u', $line)) $other[] = $line;
                break;
            }
            $err = (string)end($m);
            if (str_contains($err, 'too tired')) { $stop = $err; break 2; }
            if (str_contains($err, 'Cardboard Sheet')) { $stop = 'You ran out of Cardboard Sheets.'; break 2; }   // v0.7.63
            if ($needsItem && str_contains($err, 'don’t have')) {   // that one ran out: try the next kind
                $qi++;
                if ($qi >= count($queue)) { $stop = 'You ran out of ' . (string)q_val('SELECT name FROM items WHERE id = ?', [$item]) . '.'; break 2; }
                continue;
            }
            $skipped[$err] = ($skipped[$err] ?? 0) + 1;
            break;
        }
    }
    $verb = ['till' => 'Tilled', 'water' => 'Watered', 'plant' => 'Planted', 'soil' => 'Worked soil improvers into',
        'mulch' => 'Mulched', 'weed' => 'Weeded', 'harvest' => 'Harvested', 'dig' => 'Dug up the plants on', 'sheet' => 'Sheet mulched'][$action];
    $msgs = [];
    if ($done && $action === 'harvest') {   // v0.7.61: one tidy summary
        $msgs = harvest_summary($other, $done);
        $other = [];
    } elseif ($done) {
        $what = [];
        foreach ($used as $id => $n) $what[] = $n . ' × ' . (string)q_val('SELECT name FROM items WHERE id = ?', [$id]);
        if ($action === 'sheet') $other[] = '🍂 The new beds will be ready to plant in ' . nice_time((int)setting('notill_settle_minutes') * 60) . '.';
        $msgs[] = '☑️ ' . $verb . ' ' . $done . ' square' . ($done === 1 ? '' : 's') . ($what ? ' (' . implode(', ', $what) . ')' : '') . '.';
    }
    foreach (array_values(array_unique($other)) as $line) $msgs[] = $line;
    foreach ($skipped as $why => $n) $msgs[] = 'Skipped ' . $n . ' square' . ($n === 1 ? '' : 's') . ': ' . $why;
    if ($stop) $msgs[] = $stop;
    if (!$done && !$msgs) $msgs[] = 'Nothing to do on those squares.';
    return [$done > 0, $msgs];
}

/**
 * v1.2.2 (was inline in garden.php since v0.7.96 / v0.9.1): claim today's free "Water all" for the active garden.
 * Rain barrel level 3 first (once a Hollow day), else the Bloomcaller perk (free_water_all uses a day).
 * Sets $GLOBALS['gv_free_water'] so garden_action waters for free. Returns [free, fromPerk]; the caller
 * gives a perk use back (free_water_n - 1) if nothing got watered.
 */
function garden_claim_free_water(array $u, int $uid, array $tiles, array $plants): array
{
    $thirsty = 0;
    foreach ($tiles as $row) foreach ($row as $t) if ($t['plant_id'] && isset($plants[(int)$t['plant_id']]) && tile_info($t, $plants[(int)$t['plant_id']])['thirsty']) $thirsty++;
    if (!$thirsty) return [false, false];
    $pid = active_plot_id($uid);
    $today = hollow_date('Y-m-d');
    $free = building_level($pid, 'rain_barrel') >= 3
        && q("UPDATE garden_buildings SET free_day = ? WHERE plot_id = ? AND building = 'rain_barrel' AND (free_day IS NULL OR free_day <> ?)", [$today, $pid, $today])->rowCount() === 1;
    $perk = false;
    $freeN = (int)calling_perk($u, 'free_water_all');
    if (!$free && $freeN > 0) {
        $perk = q('UPDATE plots SET free_water_day = ?, free_water_n = 1 WHERE id = ? AND user_id = ? AND (free_water_day IS NULL OR free_water_day <> ?)', [$today, $pid, $uid, $today])->rowCount() === 1
            || q('UPDATE plots SET free_water_n = free_water_n + 1 WHERE id = ? AND user_id = ? AND free_water_day = ? AND free_water_n < ' . $freeN, [$pid, $uid, $today])->rowCount() === 1;
        $free = $perk;
    }
    $GLOBALS['gv_free_water'] = $free;
    return [$free, $perk];
}

/**
 * v0.7.61: fold the messages from harvesting several squares into a few lines:
 * "🧺 Harvested 5 plants: 12 × Radish, 3 × Carrot. +40 XP", seeds saved added up, repeated bonuses counted.
 */
function harvest_summary(array $lines, int $plants): array
{
    $got = []; $seeds = []; $xp = 0; $count = []; $order = [];
    foreach ($lines as $l) {
        $l = (string)$l;
        if (preg_match('/^You harvest (\d+) × (.+)\.$/u', $l, $m)) { $got[$m[2]] = ($got[$m[2]] ?? 0) + (int)$m[1]; continue; }
        if (preg_match('/^You saved (\d+) × (.+)\.$/u', $l, $m)) { $seeds[$m[2]] = ($seeds[$m[2]] ?? 0) + (int)$m[1]; continue; }
        if (preg_match('/^\+(\d+) XP$/', $l, $m)) { $xp += (int)$m[1]; continue; }
        if (!isset($count[$l])) $order[] = $l;
        $count[$l] = ($count[$l] ?? 0) + 1;
    }
    $parts = [];
    foreach ($got as $name => $n) $parts[] = $n . ' × ' . $name;
    $out = ['🧺 Harvested ' . $plants . ' plant' . ($plants === 1 ? '' : 's') . ($parts ? ': ' . implode(', ', $parts) : '') . '.' . ($xp ? ' +' . $xp . ' XP' : '')];
    if ($seeds) {
        $sp = [];
        foreach ($seeds as $name => $n) $sp[] = $n . ' × ' . $name;
        $out[] = '🌱 Seeds saved: ' . implode(', ', $sp) . '.';
    }
    foreach ($order as $l) $out[] = $l . ($count[$l] > 1 ? ' (×' . $count[$l] . ')' : '');
    return $out;
}

/** v0.7.54: what an amendment or mulch does, short: "Fertility +15 · Life +3 · N+3 · 10 min". */
function amend_summary(array $i): string
{
    $fx = json_decode((string)($i['effects'] ?? ''), true) ?: [];
    $bits = [];
    if (!empty($fx['mulch'])) $bits[] = 'Covers for ' . ((int)$fx['mulch'] >= 48 ? intdiv((int)$fx['mulch'], 24) . ' days' : (int)$fx['mulch'] . ' h');
    if (!empty($fx['fertility'])) $bits[] = 'Fertility +' . (int)$fx['fertility'];
    if (!empty($fx['life'])) $bits[] = 'Life +' . (int)$fx['life'];
    if (!empty($fx['moisture'])) $bits[] = 'Water-holding +' . (int)$fx['moisture'];
    foreach (['n' => 'N', 'p' => 'P', 'k' => 'K'] as $k => $l) if (!empty($fx[$k])) $bits[] = $l . '+' . (int)$fx[$k];
    if (empty($fx['mulch']) || !empty($fx['minutes'])) $bits[] = '⏱ ' . amendment_minutes($i) . ' min';
    return implode(' · ', $bits);
}

/** v0.7.56: the perennials resting in this garden's root cellar. */
function cellar_plants(int $plotId): array
{
    return q('SELECT c.*, p.name, p.kind, p.grow_minutes FROM cellar_plants c JOIN plants p ON p.id = c.plant_id WHERE c.plot_id = ? ORDER BY c.id', [$plotId])->fetchAll();
}

/** Dig a perennial up into the root cellar, keeping how grown it is. Costs Petals (setting cellar_store_cost). */
function cellar_store(int $uid, int $x, int $y): array
{
    $plotId = active_plot_id($uid);
    if (!has_building($plotId, 'root_cellar')) return [false, 'This garden has no Root Cellar yet.'];
    $t = q_one('SELECT * FROM plot_tiles WHERE plot_id = ? AND user_id = ? AND x = ? AND y = ?', [$plotId, $uid, $x, $y]);
    if (!$t || !$t['plant_id']) return [false, 'Nothing growing there to store.'];
    $p = q_one('SELECT * FROM plants WHERE id = ?', [$t['plant_id']]);
    if (!$p || !(int)$p['perennial'] || $p['kind'] === 'cover') return [false, 'Only perennials (🔄) can go in the root cellar.'];
    if (count(cellar_plants($plotId)) >= cellar_slots($plotId)) return [false, 'The root cellar is full (' . cellar_slots($plotId) . '). Replant one first.'];
    $cost = building_level($plotId, 'root_cellar') >= 3 ? 0 : (int)setting('cellar_store_cost');   // v0.7.96: free at level 3
    $grown = tile_grow(annotate_tile($t, $p), $p);
    $secs = min((int)$p['grow_minutes'] * 60, (int)$grown['growth_seconds']);
    db()->beginTransaction();
    if ($cost > 0 && !take_petals((int)$uid, (int)$cost)) {
        db()->rollBack();
        return [false, 'Storing it costs ' . number_format($cost) . ' ' . setting('currency_name') . '.'];
    }
    if (q('UPDATE plot_tiles SET plant_id = NULL, planted_at = NULL, growth_seconds = 0, last_watered = NULL, nipped = 0, pest = NULL, pest_at = NULL WHERE id = ? AND plant_id = ?', [$t['id'], $p['id']])->rowCount() !== 1) {
        db()->rollBack();
        return [false, 'Something changed there. Try again.'];
    }
    db_insert('cellar_plants', ['plot_id' => $plotId, 'user_id' => $uid, 'plant_id' => (int)$p['id'], 'growth_seconds' => $secs, 'stored_at' => now(),
        'age_seconds' => $t['planted_at'] ? max(0, time() - ts($t['planted_at'])) : 0, 'harvests' => (int)($t['harvests'] ?? 0)]);   // v0.7.61: its age waits in the cellar
    db()->commit();
    return [true, '🚪 You carefully lift the ' . $p['name'] . ' and tuck it into the root cellar' . ($cost ? ' (' . number_format($cost) . ' ' . setting('currency_name') . ')' : '') . '.'];
}

/** Replant a perennial from the root cellar into an empty, tilled square; it carries on from where it was. */
function cellar_replant(int $uid, int $cellarId, int $x, int $y): array
{
    $plotId = active_plot_id($uid);
    $c = q_one('SELECT c.*, p.name FROM cellar_plants c JOIN plants p ON p.id = c.plant_id WHERE c.id = ? AND c.plot_id = ? AND c.user_id = ?', [$cellarId, $plotId, $uid]);
    if (!$c) return [false, 'That isn’t in this garden’s root cellar.'];
    $t = q_one('SELECT * FROM plot_tiles WHERE plot_id = ? AND user_id = ? AND x = ? AND y = ?', [$plotId, $uid, $x, $y]);
    if (!$t || !tile_plantable($t)) return [false, 'Pick an empty, tilled square that’s ready to plant.'];
    db()->beginTransaction();
    if (q('DELETE FROM cellar_plants WHERE id = ?', [$c['id']])->rowCount() !== 1) { db()->rollBack(); return [false, 'Already replanted.']; }
    if (q('UPDATE plot_tiles SET plant_id = ?, planted_at = ?, growth_seconds = ?, growth_updated_at = ?, last_watered = NULL, harvests = ?, nipped = 0, pest = NULL, pest_at = NULL, pest_check = NULL WHERE id = ? AND plant_id IS NULL',
          [$c['plant_id'], gmdate('Y-m-d H:i:s', time() - (int)($c['age_seconds'] ?? 0)), (int)$c['growth_seconds'], now(), (int)($c['harvests'] ?? 0), $t['id']])->rowCount() !== 1) {
        db()->rollBack();
        return [false, 'Something is already growing there.'];
    }
    db()->commit();
    return [true, '🌿 You replant the ' . $c['name'] . ' from the root cellar. Give it a drink!'];
}

/**
 * v0.7.61: perennials live for a while, then give a last harvest. Age counts from planted_at
 * (paused in the root cellar). Harvests shrink slowly to life_end_yield % by the end.
 * Returns null for annuals and cover crops, else [age days, life days, yield %, days left, old (bool)].
 */
function perennial_life(array $t, array $p): ?array
{
    if (!(int)$p['perennial'] || $p['kind'] === 'cover' || empty($t['planted_at'])) return null;
    $life = (int)setting(in_array($p['kind'], ['tree', 'nut'], true) ? 'life_tree_days' : ($p['kind'] === 'fruit' ? 'life_fruit_days' : 'life_other_days'));
    if (!empty($t['plot_id']) && garden_mods((int)$t['plot_id'])['greenhouse'] >= 3) $life = (int)round($life * 1.25);   // v0.7.96: greenhouse level 3
    $life = max(1, $life);
    $age = max(0, time() - ts($t['planted_at'])) / 86400;
    $frac = min(1, $age / $life);
    $pct = (int)round(100 - (100 - (int)setting('life_end_yield')) * $frac);
    return [(int)floor($age), $life, $pct, max(0, (int)ceil($life - $age)), $age >= $life];
}

/** A short line for the garden panel: "🔄 Age 12 of 60 days · harvests 96% · 48 days left". */
function perennial_life_text(array $t, array $p): string
{
    $l = perennial_life($t, $p);
    if (!$l) return '';
    [$age, $life, $pct, $left, $old] = $l;
    return $old ? '🍂 Old age: ' . $age . ' of ' . $life . ' days. Its next harvest is its last (' . $pct . '% of a young plant’s).'
        : '🔄 Age ' . $age . ' of ' . $life . ' days · harvests at ' . $pct . '% · about ' . $left . ' day' . ($left === 1 ? '' : 's') . ' of life left';
}

/** Growth speed: fertility sets the base, weeds slow it, a good soil grade speeds it up (+3% per grade). */
/** v0.7.65: is this crop unstudied for this gnome (no guide, questline, home or mastery for it)? Cover crops never are. */
function plant_unstudied(array $u, array $p): bool
{
    if (($p['kind'] ?? '') === 'cover' || empty($u['id'])) return false;
    require_once __DIR__ . '/world.php';
    return !isset(known_plants($u)[(int)$p['id']]);
}

/** v0.9.1: the unstudied slowdown % for this gnome (Seedkeeper masters take half). */
function unstudied_slow_pct(array $u): int
{
    $n = (int)setting('unstudied_slow_percent');
    return calling_perk($u, 'unstudied_half') > 0 ? intdiv($n, 2) : $n;
}

/** v0.9.1: what % of the harvest an unstudied crop still gives this gnome (Seedkeeper masters lose half as much). */
function unstudied_yield_pct(array $u): int
{
    $n = (int)setting('unstudied_yield_percent');
    return calling_perk($u, 'unstudied_half') > 0 ? 100 - intdiv(100 - $n, 2) : $n;
}

/** The region a crop comes from, by name (the first one listed). */
function plant_home_name(int $plantId): string
{
    static $c = [];
    return $c[$plantId] ??= (string)q_val('SELECT r.gnomish_name FROM plant_regions pr JOIN regions r ON r.id = pr.region_id WHERE pr.plant_id = ? ORDER BY r.min_level LIMIT 1', [$plantId]);
}

function soil_speed(array $t): float
{
    $speed = (0.5 + clamp100((int)$t['fertility']) / 100) * (1 - clamp100((int)$t['weeds']) / 200);
    if (!empty($t['_native'])) $speed *= 1 + ((int)setting('native_bonus_percent') + (int)($t['_nativeplus'] ?? 0)) / 100;   // crop is in its home region (+ a Journey project's bonus, v0.7.65)
    if (!empty($t['_unstudied'])) $speed /= 1 + (int)($t['_unslow'] ?? setting('unstudied_slow_percent')) / 100;   // v0.7.65: no guide for it yet (v0.9.1: halved for Seedkeeper masters)
    if (grade_index($t) >= 10 && !empty($t['_sgrow'])) $speed *= 1 + (int)$t['_sgrow'] / 100;   // v0.9.1: Rootwarden master: S-grade beds grow faster
    $speed *= nutrient_speed($t);                                                            // the crop's own nutrient (N, P or K)
    if (!empty($t['plot_id']) && garden_mods((int)$t['plot_id'])['greenhouse'] >= 2) $speed *= 1.10;   // v0.7.96: greenhouse level 2+
    $speed *= 1 + (int)setting('care_growth_percent') / 100 * care_stars($t);   // v0.8.7: soil care stars on tilled squares
    if (!empty($t['_clim']['grow'])) $speed *= max(0.1, 1 + $t['_clim']['grow'] / 100);   // v0.8.9: the region's climate
    return $speed * (1 + 0.03 * max(0, grade_index($t)));
}

/** How long one watering lasts: moisture up to 2x, plus 5% per soil grade. */
function water_seconds(array $t, array $p): int
{
    return (int)((int)$p['water_interval_minutes'] * 60 * (1 + clamp100((int)$t['moisture']) / 100) * (1 + 0.05 * max(0, grade_index($t)))
        * (!empty($t['_rain']) ? [1 => 1.25, 2 => 1.40, 3 => 1.55][min(3, (int)$t['_rain'])] : 1)   // v0.7.96: rain barrel levels
        * (!empty($t['_barrel']) ? 1 + (int)setting('yard_barrel_percent') / 100 : 1)     // a rain barrel right beside it (v0.7.34)
        * (!empty($t['_shade']) ? 1 + (int)setting('yard_shade_percent') / 100 : 1)       // a shade tree beside it
        * max(0.2, 1 + ((int)($t['_clim']['water'] ?? 0) + ((int)($t['mulch'] ?? 0) <= 0 ? (int)($t['_clim']['water_bare'] ?? 0) : 0)) / 100)   // v0.8.9: climate
        * garden_water_mult($t));   // v1.0.0: a hot day dries a watering faster
}

/** Bring a square's growth up to date. Plants only grow while watered. */
function tile_grow(array $t, ?array $p, ?int $at = null): array
{
    if (!$t['plant_id'] || !$p) return $t;
    $at ??= time();   // a hired helper replays growth up to each of their visits
    $from = ts($t['growth_updated_at']) ?: ts($t['planted_at']);
    if ($from >= $at) return $t;
    $wetUntil = $t['last_watered'] ? ts($t['last_watered']) + water_seconds($t, $p) : 0;
    $end = min($at, $wetUntil);
    $gs = (int)$t['growth_seconds'];
    if (gfx_on()) {   // v1.0.0: day by day, with the season, the weather (rain waters), frost and pests
        [$gain, $nip] = garden_grow_gain($t, $p, $from, $at, $wetUntil);
        $gs += $gain;
        if ($nip) $t['nipped'] = 1;
    } elseif ($end > $from) {
        $gs += (int)(($end - $from) * soil_speed($t));
    }
    $t['growth_seconds'] = min($gs, (int)$p['grow_minutes'] * 60);
    $t['growth_updated_at'] = gmdate('Y-m-d H:i:s', $at);
    return $t;
}

/** Save growth, the no-till upkeep clock and the soil feeding clock. */
function save_growth(array $t): void
{
    q('UPDATE plot_tiles SET growth_seconds = ?, growth_updated_at = ?, mulch = ?, weeds = ?, moisture = ?, bed_score = ?, maint_at = ?,
       checkpoint = ?, neglect_hours = ?, fertility = ?, soil_life = ?, feed_fert = ?, feed_life = ?, feed_hours = ?, feed_at = ?,
       n = ?, p = ?, k = ?, feed_n = ?, feed_p = ?, feed_k = ?, nipped = ? WHERE id = ?',
        [$t['growth_seconds'], $t['growth_updated_at'], $t['mulch'], $t['weeds'], $t['moisture'], $t['bed_score'], $t['maint_at'],
         $t['checkpoint'], $t['neglect_hours'], $t['fertility'], $t['soil_life'],
         (int)$t['feed_fert'], (int)$t['feed_life'], (int)$t['feed_hours'], $t['feed_at'],
         (int)($t['n'] ?? 50), (int)($t['p'] ?? 50), (int)($t['k'] ?? 50), (int)($t['feed_n'] ?? 0), (int)($t['feed_p'] ?? 0), (int)($t['feed_k'] ?? 0), (int)($t['nipped'] ?? 0), $t['id']]);
}

/**
 * v1.2.2: the values save_growth() would write, as comparable strings (same coercions as save_growth),
 * leaving out growth_updated_at, so load_plot can tell whether a view changed anything worth saving.
 */
function growth_sig(array $t): array
{
    $sig = [];
    foreach (['growth_seconds', 'mulch', 'weeds', 'moisture', 'bed_score', 'maint_at', 'checkpoint', 'neglect_hours', 'fertility', 'soil_life', 'feed_at'] as $c) $sig[$c] = (string)($t[$c] ?? '');
    foreach (['feed_fert', 'feed_life', 'feed_hours', 'feed_n', 'feed_p', 'feed_k', 'nipped'] as $c) $sig[$c] = (string)(int)($t[$c] ?? 0);
    foreach (['n', 'p', 'k'] as $c) $sig[$c] = (string)(int)($t[$c] ?? 50);
    return $sig;
}

function tile_info(array $t, array $p): array
{
    $need = max(1, (int)$p['grow_minutes'] * 60);
    $progress = min(1, (int)$t['growth_seconds'] / $need);
    $wetUntil = $t['last_watered'] ? ts($t['last_watered']) + water_seconds($t, $p) : 0;
    $ready = $progress >= 1;
    $fx = gfx_on() ? garden_day_fx($t, $p, hollow_today()) : ['speed' => 1.0, 'wet' => false];   // v1.0.0: today's season and weather
    $rain = !empty($fx['wet']);
    $wetLeft = max(0, $wetUntil - time());
    if ($rain && !$ready) $wetLeft = max($wetLeft, garden_next_midnight(time()) - time());   // the rain has it covered until midnight
    return [
        'ready' => $ready,
        'progress' => $progress,
        'stage' => $ready ? (int)$p['stages'] : min((int)$p['stages'] - 1, 1 + (int)floor($progress * ((int)$p['stages'] - 1))),
        'thirsty' => !$ready && $wetUntil <= time() && !$rain,
        'wet_left' => $wetLeft,
        'rain' => $rain && !$ready,
        'time_left' => $ready ? 0 : (int)ceil(($need - (int)$t['growth_seconds']) / max(0.05, soil_speed($t) * $fx['speed'] * garden_pest_factor($t))),
    ];
}

/** Can this square take a seed right now? */
function tile_plantable(array $t): bool
{
    return (int)$t['tilled'] === 1 && !$t['plant_id'] && ts($t['settle_until']) <= time();
}

function nice_time(int $s): string
{
    if ($s < 60) return $s . 's';
    if ($s < 3600) return (int)ceil($s / 60) . ' min';
    if ($s >= 172800) return round($s / 86400, 1) . ' days';
    $m = (int)ceil($s / 60);
    return intdiv($m, 60) . 'h ' . ($m % 60) . 'm';
}

/**
 * The Soil Probe's advice (v0.7.30): the crops this gnome knows that would do best in this square right now.
 * Scores: the square's level of the crop's favourite nutrient, native speed here, and whether the soil is rich enough.
 * Returns up to $n of [plant, why].
 */
function probe_best_crops(array $u, array $t, int $n = 3): array
{
    require_once __DIR__ . '/world.php';
    $known = array_keys(known_plants($u));
    if (!$known) return [];
    $mods = garden_mods((int)$t['plot_id']);
    $out = [];
    foreach (q('SELECT * FROM plants WHERE id IN (' . implode(',', array_map('intval', $known)) . ") AND kind NOT IN ('cover')")->fetchAll() as $p) {
        $need = (string)($p['nutrient'] ?? '');
        $nut = isset(NUTRIENTS[$need]) ? (int)($t[$need] ?? 50) : 50;
        $native = $mods['greenhouse'] || ($mods['region_id'] && in_array($mods['region_id'], plant_regions_native((int)$p['id']), true));
        $rich = (int)$t['fertility'] >= (int)$p['min_soil'];
        $score = $nut + ($native ? 25 : 0) + ($rich ? 0 : -100) + min(15, (int)$p['xp_per_harvest']);
        $why = [];
        if (isset(NUTRIENTS[$need])) $why[] = NUTRIENTS[$need][1] . ' ' . $nut;
        if ($native) $why[] = 'native here';
        if (!$rich) $why[] = 'needs fertility ' . (int)$p['min_soil'];
        $out[] = [$score, $p, implode(', ', $why)];
    }
    usort($out, fn($a, $b) => $b[0] <=> $a[0]);
    return array_map(fn($x) => [$x[1], $x[2]], array_slice($out, 0, $n));
}

/** Words for soil stats when the player has no soil test kit. */
function soil_words(array $t): array
{
    $f = (int)$t['fertility'];
    $l = (int)$t['soil_life'];
    $m = (int)$t['moisture'];
    return [
        'fertility' => $f < 20 ? 'exhausted' : ($f < 40 ? 'tired' : ($f < 65 ? 'decent' : ($f < 85 ? 'rich' : 'superb'))),
        'life' => $l < 5 ? 'lifeless' : ($l < 25 ? 'a few worms' : ($l < 50 ? 'lively' : ($l < 80 ? 'teeming' : 'thriving ecosystem'))),
        // v0.7.27: this is how well the soil HOLDS water (how long a watering lasts), not whether it's been watered
        'moisture' => $m < 15 ? 'very poor (dries out fast)' : ($m < 35 ? 'poor' : ($m < 60 ? 'fair' : ($m < 85 ? 'good' : 'excellent'))),
    ];
}

/** Load the gnome's active garden with growth and upkeep brought up to date. */
/** $visitPlot: another player's garden being tended through a job (no messages meant for the owner). */
function load_plot(int $uid, bool $helperDone = false, ?int $visitPlot = null): array
{
    $plotId = $visitPlot ?? active_plot_id($uid);
    $ownerRow = q_one('SELECT * FROM users WHERE id = ?', [$visitPlot ? (int)q_val('SELECT user_id FROM plots WHERE id = ?', [$visitPlot]) : $uid]) ?: [];   // v0.9.1: perks follow the garden owner
    if ($visitPlot) $helperDone = true;
    if ($plotId) yard_sync((int)$plotId);   // every bed square and building has a spot in the yard (v0.7.32)
    $plot = q_one('SELECT * FROM plots WHERE id = ?', [$plotId]);
    $tiles = [];
    $plants = [];
    $best = -1;
    // A hired helper's visits since the garden last loaded
    // v0.7.99: a Tool Shed can house up to 3 helpers; each keeps its own visits and tally
    $hires = $helperDone ? [] : current_hires((int)$plotId);
    if (!$helperDone && (setting('ppal_open') === '1' || is_admin())) { require_once __DIR__ . '/pal_jobs.php'; }
    if (!$helperDone && function_exists('pj_garden_hires')) $hires = array_merge($hires, pj_garden_hires((int)$plotId));   // v2.3.0: a Puzzle Pal on garden duty visits like a helper (no Tool Shed slot)
    $hv = $hs = $hst = [];
    foreach ($hires as $k => $hh) { $hv[$k] = hire_visits($hh); $hs[$k] = helper_skills($hh); $hst[$k] = ['water' => 0, 'weed' => 0, 'harvest' => 0]; }
    foreach (q('SELECT * FROM plot_tiles WHERE plot_id = ? ORDER BY y, x', [$plotId])->fetchAll() as $t) {
        $p = null;
        if ($t['plant_id']) {
            $pid = (int)$t['plant_id'];
            $p = $plants[$pid] ??= q_one('SELECT * FROM plants WHERE id = ?', [$pid]);
        }
        $t = annotate_tile($t, $p);
        foreach ($hires as $k => $hh) if ($hv[$k] && in_array('water', $hs[$k], true)) $t = helper_water_tile($t, $p, $hv[$k], $hst[$k]);
        if ($p || $t['method'] === 'notill' || (int)$t['feed_hours'] > 0) {
            $origSig = growth_sig($t);   // v1.2.2: what the database holds now (helper_water_tile has already saved its own changes)
            $origClock = (string)$t['growth_updated_at'];
            $t = tile_grow($t, $p);     // growth first, with the bed as it was...
            $t = bed_tick($t, $ownerRow);   // ...then run the upkeep clock forward
            $t = feed_tick($t);            // ...and let any compost work in
            if ($t['method'] === 'notill' && (int)$t['weeds'] >= 5) foreach ($hires as $k => $hh) {
                if ($hv[$k] && in_array('weed', $hs[$k], true)) { $t['weeds'] = 0; $hst[$k]['weed']++; break; }
            }
            if (!empty($t['pest'])) foreach ($hires as $k => $hh) {   // v1.0.0: a helper who weeds picks the pests off too
                if ($hv[$k] && in_array('weed', $hs[$k], true)) {
                    $t['pest'] = null; $t['pest_at'] = null;
                    q('UPDATE plot_tiles SET pest = NULL, pest_at = NULL WHERE id = ?', [$t['id']]);
                    $hst[$k]['weed']++;
                    break;
                }
            }
            // v1.2.2: only write when something changed. growth_updated_at alone moving forward is skipped only when the plant
            // can't grow any more (no plant, or fully grown: growth is capped, so the older clock loses nothing and every
            // writer that restarts growth sets growth_updated_at itself). While a plant is still growing, the clock is saved
            // as before so a later watering can't be counted over time it spent dry.
            // The clock is still saved at least once an hour, so the day-by-day replay (seasons, frost, pests) never has to cover a long gap.
            $capped = !$p || (int)$t['growth_seconds'] >= (int)$p['grow_minutes'] * 60;
            if (growth_sig($t) !== $origSig || ((string)$t['growth_updated_at'] !== $origClock && (!$capped || time() - (ts($origClock) ?: 0) > 3600))) save_growth($t);
        }
        $best = max($best, grade_index($t));
        $tiles[(int)$t['y']][(int)$t['x']] = $t;
    }
    if ($visitPlot) return [$plot, $tiles, $plants];
    if ($plot) foreach (garden_pest_pass($plot, $tiles, $plants) as $m) flash($m);   // v1.0.0: pests come and go with the season and weather
    if ($best >= 0) job_event($uid, 'grade', '', $best);
    foreach (soil_grade_unlocks($uid, $best) as $m) {
        flash($m);
    }
    $harvested = 0;
    $done = [];   // tiles already harvested by an earlier helper this load
    foreach ($hires as $k => $hire) {
        if (!$hv[$k] && ts($hire['ends_at']) > time()) continue;
        if ($hv[$k] && in_array('harvest', $hs[$k], true)) {
            $owner = q_one('SELECT * FROM users WHERE id = ?', [$uid]);
            foreach ($tiles as $row) foreach ($row as $t) {
                $p = $t['plant_id'] ? $plants[(int)$t['plant_id']] : null;
                if (isset($done[$t['id']]) || !$p || $p['kind'] === 'cover' || !tile_info($t, $p)['ready']) continue;
                db()->beginTransaction();
                try {
                    foreach (do_harvest($owner, $t, $p, $hire['name']) as $m) {
                        if (preg_match('/^(📖|⭐|🎉|🏡|🏆|🎩|🐦)/u', $m)) flash($m);   // keep the big news, skip the details
                    }
                    db()->commit();
                    $hst[$k]['harvest']++;
                    if (isset($hire['pj_job'])) $hst[$k]['extra'] = ($hst[$k]['extra'] ?? 0) + pj_garden_extra($uid, $p, $hire);   // v2.3.3: a skilled pal brings an extra crop
                    $done[$t['id']] = true;
                } catch (Throwable $e) {
                    if (db()->inTransaction()) db()->rollBack();
                }
            }
        }
        $harvested += $hst[$k]['harvest'];
        $line = helper_finish($hire, $hv[$k], $hst[$k]);
        if ($line) flash($line);
    }
    if ($harvested) return load_plot($uid, true);   // reload the tiles the helpers changed
    return [$plot, $tiles, $plants];
}

/** Items used for soil: [fertility, life, moisture] boosts from the item's effects. */
function mulch_value(array $item): int
{
    return (int)((json_decode((string)$item['effects'], true) ?: [])['mulch'] ?? 0);
}

function amendment(array $item): array
{
    $fx = json_decode((string)$item['effects'], true) ?: [];
    return [(int)($fx['fertility'] ?? 0), (int)($fx['life'] ?? 0), (int)($fx['moisture'] ?? 0)];
}

/** An item's N, P, K: ['n' => .., 'p' => .., 'k' => ..] (zeros if none). */
function amendment_npk(array $item): array
{
    $fx = json_decode((string)$item['effects'], true) ?: [];
    return ['n' => max(0, (int)($fx['n'] ?? 0)), 'p' => max(0, (int)($fx['p'] ?? 0)), 'k' => max(0, (int)($fx['k'] ?? 0))];
}

/** The pool an amendment adds, capped so nothing goes over 100. */
function npk_pool(array $t, array $npk): array
{
    $out = [];
    foreach ($npk as $nu => $v) $out[$nu] = max(0, min(100 - (int)($t[$nu] ?? 50), $v));
    return $out;
}

function npk_text(array $npk): string
{
    $parts = [];
    foreach ($npk as $nu => $v) if ($v > 0) $parts[] = '+' . $v . ' ' . strtolower(NUTRIENTS[$nu][0]);
    return implode(', ', $parts);
}

/**
 * Do one garden action on one square. Returns [ok, [messages]].
 * $itemId is the seed / soil / mulch item where the action needs one.
 */
function garden_action(int $uid, string $action, int $x, int $y, int $itemId = 0): array
{
    if (!isset(ENERGY_COST[$action])) return [false, ['Unknown action.']];
    $t = q_one('SELECT * FROM plot_tiles WHERE plot_id = ? AND user_id = ? AND x = ? AND y = ?', [active_plot_id($uid), $uid, $x, $y]);
    if (!$t) return [false, ['That square isn’t part of your plot.']];
    $u = q_one('SELECT * FROM users WHERE id = ?', [$uid]);
    $p = $t['plant_id'] ? q_one('SELECT * FROM plants WHERE id = ?', [$t['plant_id']]) : null;
    $t = annotate_tile($t, $p);
    $t = feed_tick(bed_tick(tile_grow($t, $p), $u));
    $msgs = [];
    $item = $itemId ? q_one('SELECT * FROM items WHERE id = ?', [$itemId]) : null;
    $owns = fn(int $id) => (int)q_val('SELECT qty FROM user_items WHERE user_id = ? AND item_id = ?', [$uid, $id]) > 0;
    // v0.7.86: the garden tools this action uses (they wear by days, charged after it succeeds: see tool_use)
    $wearTools = [];
    if (isset(ACTION_TOOL[$action]) && tool_tier($uid, ACTION_TOOL[$action]) > 0) $wearTools[] = ACTION_TOOL[$action];
    if ($action === 'broadfork' && tool_tier($uid, 'broadfork') > 0) $wearTools[] = 'broadfork';
    if ($action === 'harvest' && $p && $p['kind'] !== 'cover' && ((int)$p['perennial'] || $p['kind'] === 'flower') && tool_tier($uid, 'prune') > 0) {
        $wearTools[] = 'prune';   // do_harvest() prunes with it
    }

    db()->beginTransaction();
    try {
        // 1. Check the rules
        switch ($action) {
            case 'till':
                if ($p) throw new UserError('Something is growing here.');
                if ((int)$t['tilled'] && $t['method'] === 'till') throw new UserError('Already tilled.');
                if (!tool_tier($uid, 'till')) throw new UserError('You need a tilling tool, like a trowel. Twigg’s Seed Emporium sells them.');
                break;
            case 'sheet':
                if ((int)$u['level'] < (int)setting('notill_level')) {
                    throw new UserError('Wren the naturalist will teach you no-till gardening at level ' . (int)setting('notill_level') . '.');
                }
                if ($p) throw new UserError('Clear the square first.');
                if ($t['method'] === 'notill') throw new UserError('This is already a no-till bed.');
                $cardboard = (int)q_val("SELECT id FROM items WHERE slug = 'cardboard-sheet'");
                if (!$cardboard || !$owns($cardboard)) throw new UserError('You need a Cardboard Sheet to smother the ground.');
                if (!$item || $item['category'] !== 'mulch' || !$owns($itemId)) throw new UserError('Pick a mulch to spread on top.');
                break;
            case 'mulch':
            case 'soil':
                if (!(int)$t['tilled']) throw new UserError('Prepare the square first (till it or sheet mulch it).');
                $want = $action === 'mulch' ? 'mulch' : 'soil';
                if (!$item || $item['category'] !== $want) throw new UserError('Pick a ' . $want . ' item.');
                if ($action === 'soil') {
                    // One amendment at a time: the last one has to finish working in first.
                    if ((int)$t['feed_hours'] > 0) {
                        throw new UserError('The last soil improver is still working into this soil. You can add more in '
                            . nice_time(feed_seconds_left($t)) . '.');
                    }
                    // Refused only if everything the item adds is already at the cap
                    $cap = (int)setting('amend_max_fertility');
                    [$af0, $al0] = amendment($item);
                    $useful = $af0 > 0 && (int)$t['fertility'] < $cap;
                    foreach (amendment_npk($item) as $nu => $v) $useful = $useful || ($v > 0 && (int)($t[$nu] ?? 50) < $cap);
                    if (!$useful && ($af0 > 0 || array_sum(amendment_npk($item)) > 0)) {
                        throw new UserError('This soil already has plenty of what ' . $item['name'] . ' adds. Let a harvest use some up first.');
                    }
                }
                if ($action === 'mulch' && (int)$t['mulch'] >= MULCH_MAX_HOURS - 24) {
                    throw new UserError('This bed already has as much mulch as it can hold.');
                }
                break;
            case 'broadfork':
                if ($t['method'] !== 'notill') throw new UserError('The broadfork is for no-till beds.');
                if ($p) throw new UserError('Use it before planting.');
                if (!tool_tier($uid, 'broadfork')) throw new UserError('You need a broadfork.');
                $forkDays = max(0, (int)setting('broadfork_days'));
                if ($t['fork_at'] && time() - ts($t['fork_at']) < $forkDays * 86400) {
                    throw new UserError('This bed was loosened recently. The broadfork can go in again in '
                        . nice_time($forkDays * 86400 - (time() - ts($t['fork_at']))) . '.');
                }
                break;
            case 'plant':
                if (!(int)$t['tilled']) throw new UserError('Prepare the square first.');
                if ($p) throw new UserError('Something is already growing here.');
                if (ts($t['settle_until']) > time()) throw new UserError('This bed is still settling. Ready in ' . nice_time(ts($t['settle_until']) - time()) . '.');
                $np = q_one('SELECT * FROM plants WHERE seed_item_id = ?', [$itemId]);
                $sapling = false;
                if (!$np && $item && $item['category'] === 'sapling') {   // anyone can plant a sapling, known crop or not
                    $np = q_one('SELECT * FROM plants WHERE id = ?', [(int)((json_decode((string)$item['effects'], true) ?: [])['sapling'] ?? 0)]);
                    $sapling = (bool)$np;
                }
                if (!$np) throw new UserError('That isn’t something you can plant.');
                // v0.7.65: anything can be planted; unstudied crops just grow slower and give less (see plant_unstudied())
                if ((int)$t['fertility'] < (int)$np['min_soil']) {
                    throw new UserError($np['name'] . ' needs richer soil (fertility ' . (int)$np['min_soil'] . '). Add compost first.');
                }
                break;
            case 'water':
                if (!$p && $t['method'] !== 'notill') throw new UserError('Nothing to water here.');
                if (!tool_tier($uid, 'water')) throw new UserError('You need a watering can. Twigg’s Seed Emporium sells them.');
                if ($t['last_watered'] && time() - ts($t['last_watered']) < 300) throw new UserError('Already well watered.');
                if ($p && $t['last_watered'] && !tile_info($t, $p)['thirsty'] && tile_info($t, $p)['wet_left'] > water_seconds($t, $p) / 2) {
                    throw new UserError('Still well watered: it won’t need more for about ' . nice_time(tile_info($t, $p)['wet_left'] - (int)(water_seconds($t, $p) / 2)) . '.');
                }
                if (!$p && (int)$t['moisture'] >= 90) throw new UserError('The bed is already moist.');
                if ($p && tile_info($t, $p)['ready']) throw new UserError('It’s ready to harvest!');
                break;
            case 'weed':
                if ($t['method'] !== 'notill') throw new UserError('Weeding is for no-till beds. Tilling clears weeds on tilled ground.');
                if ((int)$t['weeds'] < 5) throw new UserError('No weeds worth pulling.');
                break;
            case 'harvest':
                if (!$p) throw new UserError('Nothing to harvest here.');
                if (!tile_info($t, $p)['ready']) throw new UserError('Not ready yet.');
                break;
            case 'dig':
                if (!$p) throw new UserError('Nothing to dig up.');
                break;
        }
        $cost = action_cost($uid, $action, $p ? (int)$p['id'] : 0);   // v0.7.86: a harvest costs by the crop's tier
        if ($action === 'weed' && calling_perk($u, 'free_weeding') > 0) $cost = 0;   // v0.9.1: tiered (also in action_cost)
        if ($action === 'water' && !empty($GLOBALS['gv_free_water'])) $cost = 0;   // v0.7.96: the rain barrel's free Water all
        if (!empty($t['_shed']) && $action === 'sheet') $cost = max(min(1, $cost), $cost - 1);   // v0.9.1: keep a Rootwarden's 0
        if (!empty($t['_shed']) && $action === 'till' && random_int(1, 100) <= 25) $cost = 0;
        if ($cost > 0 && random_int(1, 100) <= 3 * max(0, eff_mod($u, 'nimble'))) {
            $cost = 0;
            $msgs[] = '🤸 Nimble hands! That took no energy.';
        } elseif ($cost > 0 && isset(ACTION_TOOL[$action]) && random_int(1, 100) <= tool_free_chance(tool_tier($uid, ACTION_TOOL[$action]))) {
            $cost = 0;
            $msgs[] = '🧰 Good tools! That took no energy.';
        }
        if ($cost > 0 && function_exists('tour_action_is_free') && tour_action_is_free($uid, $action)) {   // v0.9.4: the action that finishes a tour step is free
            $cost = 0;
            $msgs[] = '🐦 Wren’s tour: that one was on the house (no energy).';
        }
        if ($cost > 0 && !spend_energy($uid, $cost)) {
            throw new UserError('You’re too tired. Rest a bit and your energy will come back.' . tired_hint($uid));
        }
        save_growth($t);   // lock in the upkeep and feeding clocks before changing anything

        // 2. Make the change
        $f = (int)$t['fertility'];
        $l = (int)$t['soil_life'];
        $m = (int)$t['moisture'];
        switch ($action) {
            case 'weed':
                save_growth($t);
                q('UPDATE plot_tiles SET weeds = 0 WHERE id = ?', [$t['id']]);
                $msgs[] = '🌿 You pull the weeds by hand. The soil stays undisturbed.';
                if ($hl = heap_add((int)$t['plot_id'])) $msgs[] = $hl;   // v0.7.95: weeds go on the compost heap
                break;
            case 'till':
                if ($t['method'] === 'notill') {
                    $l = 0;                           // strict: tilling a no-till bed destroys its soil life
                    $m = clamp100($m - 30);
                    $msgs[] = '💔 You till your no-till bed. The fungi, worms, soil structure and its grade (with any checkpoint) are gone.';
                    $care = 0;
                } else {
                    $l = clamp100($l - care_till_damage($t));   // v0.8.7: soil care stars soften the damage (15 down to 5)
                    $m = clamp100($m - 10);
                    $care = care_points($t);                     // any stars lost while it lay wild are settled now
                }
                $f = clamp100($f + 5);               // tilling releases a quick burst of nutrients
                q('UPDATE plot_tiles SET tilled = 1, method = ?, settle_until = NULL, fertility = ?, soil_life = ?, moisture = ?,
                   mulch = 0, weeds = 0, bed_score = 0, maint_at = NULL, checkpoint = 0, neglect_hours = 0, care = ?, care_at = ? WHERE id = ?', ['till', $f, $l, $m, $care, now(), $t['id']]);
                $msgs[] = 'You till the soil. Quick and ready to plant.';
                break;
            case 'sheet':
                $cardboard = (int)q_val("SELECT id FROM items WHERE slug = 'cardboard-sheet'");
                if (!give_item($uid, $cardboard, -1) || !give_item($uid, $itemId, -1)) throw new UserError('You’re missing materials.');
                [$af, $al, $am] = amendment($item);
                $settle = gmdate('Y-m-d H:i:s', time() + (int)setting('notill_settle_minutes') * 60);
                $head = $t['method'] === 'notill' ? 0 : intdiv(care_stars($t), 2);   // v0.8.7: a cared-for square starts a grade up per 2 stars
                q('UPDATE plot_tiles SET tilled = 1, method = ?, settle_until = ?, fertility = ?, soil_life = ?, moisture = ?,
                   mulch = ?, weeds = 0, bed_score = ?, maint_at = ?, checkpoint = 0, neglect_hours = 0, care = 0, care_fed = 0 WHERE id = ?',
                    ['notill', $settle, clamp100($f + 5 + $af), clamp100($l + 10 + $al), clamp100($m + 20 + $am),
                     min(MULCH_MAX_HOURS, 48 + mulch_value($item)), $head * GRADE_STEP, now(), $t['id']]);
                $msgs[] = '🍂 You lay cardboard and ' . $item['name'] . '. The bed will be ready to plant in ' . nice_time((int)setting('notill_settle_minutes') * 60) . '.'
                    . ($head ? ' Your soil care gives it a head start: it begins at grade ' . grade_name($head) . '.' : '');
                break;
            case 'soil':
                if (!give_item($uid, $itemId, -1)) throw new UserError('You don’t have any of that.');
                [$af, $al, $am] = amendment($item);
                $mins = amendment_minutes($item);
                // Nutrients go into the slow-release pool; any moisture soaks in right away.
                $pool = npk_pool($t, amendment_npk($item));
                q('UPDATE plot_tiles SET moisture = ?, feed_fert = ?, feed_life = ?, feed_hours = ?, feed_at = ?, feed_n = ?, feed_p = ?, feed_k = ?, care_fed = 1 WHERE id = ?',
                    [clamp100($m + $am), max(0, min(100 - $f, $af)), max(0, $al), $mins, now(), $pool['n'], $pool['p'], $pool['k'], $t['id']]);
                $adds = array_filter([$af ? '+' . min(100 - $f, $af) . ' fertility' : '', $al ? '+' . $al . ' soil life' : '', npk_text($pool)]);
                $msgs[] = 'You work ' . $item['name'] . ' into the soil. Over the next ' . nice_time($mins * 60)
                    . ' it will add ' . ($adds ? implode(', ', $adds) : 'a little goodness') . '.';
                break;
            case 'mulch':
                if (!give_item($uid, $itemId, -1)) throw new UserError('You don’t have any of that.');
                [$af, $al, $am] = amendment($item);
                $newMulch = min(MULCH_MAX_HOURS, (int)$t['mulch'] + mulch_value($item));
                // Fresh mulch on a nearly bare bed soaks it and slowly feeds it. Piling more onto a
                // thick layer only adds cover (so you can mulch up before a long trip).
                if ((int)$t['mulch'] < 24) {
                    $pool = npk_pool($t, amendment_npk($item));
                    $feed = (int)$t['feed_hours'] <= 0 && ($af > 0 || $al > 0 || array_sum($pool) > 0);
                    q('UPDATE plot_tiles SET mulch = ?, moisture = ?' . ($feed ? ', feed_fert = ?, feed_life = ?, feed_hours = ?, feed_at = ?, feed_n = ?, feed_p = ?, feed_k = ?' : '') . ' WHERE id = ?',
                        $feed ? [$newMulch, clamp100($m + $am), max(0, min(100 - $f, $af)), $al, amendment_minutes($item), now(), $pool['n'], $pool['p'], $pool['k'], $t['id']]
                              : [$newMulch, clamp100($m + $am), $t['id']]);
                    $msgs[] = 'You spread ' . $item['name'] . ' over the bed. It holds in moisture' . ($feed ? ' and will slowly feed the soil' : '') . '.';
                } else {
                    q('UPDATE plot_tiles SET mulch = ? WHERE id = ?', [$newMulch, $t['id']]);
                    $msgs[] = 'You pile ' . $item['name'] . ' on top. The bed now has ' . mulch_text($newMulch) . ' of cover.';
                }
                break;
            case 'broadfork':
                q('UPDATE plot_tiles SET fertility = ?, moisture = ?, fork_at = ? WHERE id = ?', [clamp100($f + 5), clamp100($m + 8), now(), $t['id']]);
                $msgs[] = 'You loosen the bed with the broadfork without disturbing its soil life.';
                break;
            case 'plant':
                if (!give_item($uid, $itemId, -1)) throw new UserError('You don’t have that seed.');
                $head = $sapling ? intdiv((int)$np['grow_minutes'] * 60 * (int)setting('sapling_head_start'), 100) : 0;
                if (q('UPDATE plot_tiles SET plant_id = ?, planted_at = ?, growth_seconds = ?, growth_updated_at = ?, last_watered = NULL, harvests = 0, nipped = 0, pest = NULL, pest_at = NULL, pest_check = ?
                       WHERE id = ? AND plant_id IS NULL', [$np['id'], now(), $head, now(), hollow_today(), $t['id']])->rowCount() !== 1) {
                    throw new UserError('Something is already growing here.');
                }
                $msgs[] = 'You plant ' . $np['name'] . '. Don’t forget to water it!';
                if (plant_unstudied($u, $np)) $msgs[] = '📕 Unstudied: ' . $np['name'] . ' grows ' . unstudied_slow_pct($u) . '% slower and gives ' . (100 - unstudied_yield_pct($u)) . '% less until you study ' . (plant_home_name((int)$np['id']) ?: 'its region') . ' (its gardening guide or questline) or master it.';
                break;
            case 'water':
                save_growth($t);
                // Watering also tops up a no-till bed's moisture.
                // v0.7.27: tilled ground holds a little more water after each drink too (it used to never change)
                $newM = $t['method'] === 'notill' ? clamp100(max((int)$t['moisture'], 20) + 10) : min(60, (int)$t['moisture'] + 4);
                q('UPDATE plot_tiles SET last_watered = ?, growth_updated_at = ?, moisture = ? WHERE id = ?', [$p ? now() : null, now(), $newM, $t['id']]);
                $msgs[] = $p ? 'You water the ' . $p['name'] . '.' : 'You water the bed to keep its soil life happy.';
                if ($p) job_event($uid, 'water', '', 1);
                break;
            case 'dig':
                q('UPDATE plot_tiles SET plant_id = NULL, planted_at = NULL, growth_seconds = 0, last_watered = NULL, nipped = 0, pest = NULL, pest_at = NULL WHERE id = ?', [$t['id']]);
                $msgs[] = 'You dig up the ' . $p['name'] . '.';
                if ($hl = heap_add((int)$t['plot_id'])) $msgs[] = $hl;   // v0.7.95
                break;
            case 'harvest':
                save_growth($t);
                $msgs = array_merge($msgs, do_harvest($u, $t, $p));
                break;
        }
        $after = q_one('SELECT method, bed_score FROM plot_tiles WHERE id = ?', [$t['id']]);
        $msgs = array_merge($msgs, soil_grade_unlocks($uid, grade_index($after)));
        db()->commit();
        $tp = $action === 'plant' ? ($np ?? null) : $p; calling_event($uid, 'tend', $action, 1, ['kind' => (string)($tp['kind'] ?? ''), 'plant' => (string)($tp['slug'] ?? '')]);   // v0.9.4 N8: own garden only
        $shedLv = building_level(active_plot_id($uid), 'tool_shed');   // v0.7.96: an upgraded shed slows wear (15% / 30%)
        foreach (array_unique($wearTools) as $wt) {   // v0.7.86: a garden tool wears one day per Hollow day it is used
            if ($shedLv >= 2 && random_int(1, 100) <= ($shedLv >= 3 ? 30 : 15)) continue;
            if ($wear = tool_use($uid, $wt, 'day')) $msgs[] = $wear;
        }
        if (function_exists('tour_event')) {   // Wren's welcome tour
            tour_event($uid, $action);
            $msgs = array_merge($msgs, tour_messages());
        }
        return [true, $msgs];
    } catch (UserError $e) {
        db()->rollBack();
        return [false, [$e->getMessage()]];
    } catch (Throwable $e) {
        db()->rollBack();
        throw $e;
    }
}

/** Plants on neighbouring squares: [[x, y, slug, kind], ...] */
/** Growing plants around a yard square ($x, $y are yard positions since v0.7.34, when beds can be moved). */
function neighbours(int $plotId, int $x, int $y): array
{
    return q('SELECT t.yx AS x, t.yy AS y, p.slug, p.kind FROM plot_tiles t JOIN plants p ON p.id = t.plant_id
              WHERE t.plot_id = ? AND t.yx BETWEEN ? AND ? AND t.yy BETWEEN ? AND ? AND NOT (t.yx = ? AND t.yy = ?)',
        [$plotId, $x - 1, $x + 1, $y - 1, $y + 1, $x, $y])->fetchAll();
}

/** $helper = the hired helper's name when they pick it: they keep a share, and the owner gets less XP. */
function do_harvest(array $u, array $t, array $p, ?string $helper = null, int $cutTo = 0): array
{
    $uid = (int)$u['id'];
    $msgs = [];
    $isCover = $p['kind'] === 'cover';
    $notill = $t['method'] === 'notill';
    $f = (int)$t['fertility'];
    $l = (int)$t['soil_life'];
    $m = (int)$t['moisture'];
    $effect = (int)$p['soil_effect'];
    $g = max(0, grade_index($t));
    $healthy = $notill && !bed_problems($t);
    // No-till beds earn grade points for a harvest from a well-kept bed.
    $score = $notill ? min(BED_SCORE_MAX, (int)$t['bed_score'] + ($healthy ? ($isCover ? 30 : 15) : ($isCover ? 10 : 0))) : 0;

    // Claim the harvest atomically, so double-clicking can't harvest twice.
    $life = perennial_life($t, $p);   // v0.7.61
    $regrown = (int)$p['perennial'] && $p['kind'] !== 'cover' && (int)($t['harvests'] ?? 0) > 0;   // v0.7.64: not its first harvest
    $lastHarvest = $life && $life[4];
    if ((int)$p['perennial'] && !$isCover && !$lastHarvest) {
        $left = max(0, ((int)$p['grow_minutes'] - (int)$p['regrow_minutes']) * 60);
        $claimed = q('UPDATE plot_tiles SET growth_seconds = ?, growth_updated_at = ?, fertility = ?, soil_life = ?, bed_score = ?, harvests = harvests + 1, nipped = 0, pest = NULL, pest_at = NULL WHERE id = ? AND growth_seconds >= ?',
            [$left, now(), clamp100($f + intdiv($effect, 2)), clamp100($l + ($notill ? 2 : 0)), $score, $t['id'], (int)$p['grow_minutes'] * 60])->rowCount();
    } else {
        if ($lastHarvest) {
            $f += intdiv($effect, 2); $l += 3;   // an old perennial's roots feed the soil as they go
        } elseif ($isCover) {
            $f += $effect; $l += 10; $m += 5;
        } else {
            $f += $effect; $m -= 5;
            $l += $notill ? 5 : 0;
        }
        // Tilled squares need tilling again after an annual harvest. No-till beds stay ready.
        $claimed = q('UPDATE plot_tiles SET plant_id = NULL, planted_at = NULL, growth_seconds = 0, last_watered = NULL, nipped = 0, pest = NULL, pest_at = NULL,
                      tilled = ?, fertility = ?, soil_life = ?, moisture = ?, bed_score = ? WHERE id = ? AND plant_id = ?',
            [$notill ? 1 : 0, clamp100($f), clamp100($l), clamp100($m), $score, $t['id'], $p['id']])->rowCount();
    }
    if (!$claimed) throw new UserError('Not ready yet.');
    if ($t['method'] !== 'notill' && ($cm = care_after_harvest($t))) $msgs[] = $cm;   // v0.8.7: soil care on tilled squares
    fair_record($u, $t, $p);   // v0.8.1: the Grand Harvest Fair keeps your best of the month (tile as it was before harvest)
    if (!$isCover && ($hl = heap_add((int)$t['plot_id']))) $msgs[] = $hl;   // v0.7.95: the trimmings go on the compost heap (cover crops already feed the soil)
    // Nutrients: the crop uses some of its own; legumes and cover crops give back
    $dn = harvest_nutrients($p, (int)$p['perennial'] && !$isCover);
    q('UPDATE plot_tiles SET n = ?, p = ?, k = ? WHERE id = ?',
        [clamp100((int)($t['n'] ?? 50) + $dn['n']), clamp100((int)($t['p'] ?? 50) + $dn['p']), clamp100((int)($t['k'] ?? 50) + $dn['k']), $t['id']]);

    if ($isCover) {
        $msgs[] = '☘️ You dig the ' . $p['name'] . ' back into the soil. Fertility and soil life go up!';
    } else {
        $qty = random_int((int)$p['yield_min'], max((int)$p['yield_min'], (int)$p['yield_max']));
        $palBloom = false;
        if (setting('ppal_party') === '1') { require_once __DIR__ . '/puzzle_pals.php'; $palBloom = ppal_bloom_roll($u); }   // v2.0.88: the Puzzle Pals bloom perk
        if (luck_roll($u) || $palBloom) {
            $qty++;
            $msgs[] = '🍀 Lucky! An extra one.';
        }
        if (random_int(1, 100) <= 3 * max(0, eff_mod($u, 'grit'))) {
            $qty++;
            $msgs[] = '💪 Your Grit hauled in a heavier harvest.';
        }
        if ($p['kind'] === 'flower') $qty += calling_perk($u, 'flower_extra');   // v0.9.1: Bloomcaller
        if ((int)($t['bonus_yield'] ?? 0) > 0) {   // a bee visited (v0.7.31)
            $qty += (int)$t['bonus_yield'];
            $msgs[] = '🐝 The bee’s pollen paid off: +' . (int)$t['bonus_yield'] . '.';
            q('UPDATE plot_tiles SET bonus_yield = 0 WHERE id = ?', [$t['id']]);
        }
        if (!$helper && (int)q_val('SELECT ev_harvest_bonus FROM users WHERE id = ?', [$u['id']]) > 0
            && q('UPDATE users SET ev_harvest_bonus = 0 WHERE id = ? AND ev_harvest_bonus > 0', [$u['id']])->rowCount() === 1) {   // a fairy ring (v0.7.31)
            $qty += 2;
            $msgs[] = '🍄 The fairy ring’s magic: +2!';
        }
        $prune = ((int)$p['perennial'] || $p['kind'] === 'flower') ? tool_tier((int)$u['id'], 'prune') : 0;
        if ($prune > 0) {
            $extra = $prune >= 4 ? 1 + (random_int(1, 2) === 1 ? 1 : 0) : (random_int(1, 100) <= $prune * 25 ? 1 : 0);
            if ($extra) {
                $qty += $extra;
                $msgs[] = '✂️ Careful pruning gave ' . ($extra > 1 ? $extra . ' extra' : 'an extra one') . '.';
            }
        }
        if (random_int(1, 100) <= (int)$t['soil_life']) {
            $qty++;
            $msgs[] = '🪱 Healthy soil gave you a bigger harvest.';
        }
        if ($g > 0 && random_int(1, 100) <= $g * 5) {
            $qty++;
            $msgs[] = '🏅 Your grade ' . grade_name($g) . ' bed gave a bonus harvest.';
        }
        // Companions & pollinators
        $tx = (int)($t['yx'] ?? $t['x']);
        $ty = (int)($t['yy'] ?? $t['y']);
        $nb = neighbours((int)$t['plot_id'], $tx, $ty);
        $sisters = ['corn' => 'corn', 'kidney-bean' => 'bean', 'black-bean' => 'bean', 'green-bean' => 'bean', 'pumpkin' => 'squash'];
        if (isset($sisters[$p['slug']])) {
            $groups = [$sisters[$p['slug']] => true];
            foreach ($nb as $n) {
                if (abs($n['x'] - $tx) + abs($n['y'] - $ty) === 1 && isset($sisters[$n['slug']])) $groups[$sisters[$n['slug']]] = true;
            }
            if (count($groups) === 3) {
                $qty++;
                $msgs[] = '🌽 Three Sisters bonus! Corn, beans and squash help each other.';
            }
        }
        if (in_array($p['kind'], ['fruit', 'tree', 'vegetable', 'nut', 'legume'], true)
            && ((array_filter($nb, fn($n) => $n['kind'] === 'flower') && random_int(1, 100) <= min(100, 50 + calling_perk($u, 'pollinator_bonus')))   // v0.9.1: Bloomcaller tiers (no calling = the usual 50%)
                || (!empty($t['_hive']) && random_int(1, 100) <= (!empty($t['_hivenear']) ? (int)setting('yard_hive_percent') : 25) + 10 * (max(1, (int)$t['_hive']) - 1)))) {   // v0.7.95: +10% a hive level
            $qty++;
            $msgs[] = '🐝 Busy pollinators boosted this harvest.';
        }
        if (!empty($t['_birds']) && random_int(1, 100) <= (int)setting('yard_birds_percent')) {
            $qty++;
            $msgs[] = '🐦 Birds from the birdbath kept the slugs off: +1.';
        }
        if ($cm = garden_companion_yield($t, $p, $nb, $qty)) $msgs[] = $cm;   // v1.0.0: a companion beside it helps
        $qty = garden_yield_adjust($qty, $t, $p, $msgs);   // v1.0.0: in season gives a bit more; a frost-nipped crop a bit less
        if ($life && $life[2] < 100) $qty = max(1, (int)round($qty * $life[2] / 100));   // v0.7.61: older perennials give a little less
        if ($regrown) $qty = max(1, (int)round($qty * ((int)setting('regrow_yield_percent') + (int)($t['_clim']['regrow_yield'] ?? 0)) / 100));   // v0.8.9: + climate
        if (plant_unstudied($u, $p)) {   // v0.7.65: unstudied crops give less
            $full = $qty;
            $qty = max(1, (int)round($qty * unstudied_yield_pct($u) / 100));   // v0.9.1: Seedkeeper masters take half the penalty
            if ($full > $qty) $msgs[] = '📕 Unstudied: you’d have harvested ' . $full . ' with ' . (plant_home_name((int)$p['id']) ?: 'its region') . ' studied.';
        }   // v0.7.64: regrowths give a bit less than the first crop
        if ($p['produce_item_id'] && $qty > 0) {
            $kept = $helper !== null ? max(1, (int)floor($qty * (100 - (int)setting('helper_cut_percent')) / 100)) : $qty;
            give_item($uid, (int)$p['produce_item_id'], $kept);
            market_note_harvest($u, $t, $p, $kept);   // v1.0.0 wave 2b: the crop's quality (its Harvest Fair score) joins the stack, for orders
            if ($cutTo && $qty > $kept) give_item($cutTo, (int)$p['produce_item_id'], $qty - $kept);   // a player helper's share
            $pname = q_val('SELECT name FROM items WHERE id = ?', [$p['produce_item_id']]);
            array_unshift($msgs, $helper !== null ? "$helper harvests $qty × $pname and keeps " . ($qty - $kept) . ' as pay.'
                                                  : 'You harvest ' . $qty . ' × ' . $pname . '.');
            job_event($uid, 'harvest', (string)$p['slug'], $kept, ['kind' => (string)$p['kind'], 'plant' => (string)$p['slug'], 'bedgrade' => $notill ? $g : -1, 'helper' => $helper !== null]);   // v0.9.4 N8: plant kind and bed grade (a hired or player helper's harvest doesn't count)
            require_once __DIR__ . '/contests.php';
            if ($show = show_measure($uid, $t, $p, $u)) $msgs[] = $show;   // the Village Show
        }
    }

    if ($lastHarvest) $msgs[] = '🍂 The ' . $p['name'] . ' has reached the end of its life (' . $life[0] . ' days). That was its last harvest, and its roots go back into the soil.';
    // A+ and S beds sometimes turn up treasure in the soil.
    if ($g >= 9 && random_int(1, 100) <= ($g === 10 ? 20 : 10)) {
        $find = random_int(1, 3) === 1 ? 'rich-loam' : 'worm-castings';
        $fid = (int)q_val('SELECT id FROM items WHERE slug = ?', [$find]);
        if ($fid) {
            give_item($uid, $fid, 1);
            $msgs[] = '✨ Your thriving soil turned up ' . q_val('SELECT name FROM items WHERE id = ?', [$fid]) . '!';
        }
    }
    if ($notill && grade_index(['method' => 'notill', 'bed_score' => $score]) > $g) {
        $msgs[] = '📈 This bed rose to soil grade ' . grade_name(grade_index(['method' => 'notill', 'bed_score' => $score])) . '!';
    }

    $chance = (int)setting('seed_save_chance') + intdiv((int)$t['soil_life'], 4) + $g * 2
        + 3 * eff_mod($u, 'sense');   // v0.9.1: the flat +20 for Seedkeepers is replaced by the tier perks below
    if ((int)$p['perennial'] && !calling_perk($u, 'perennial_seed_full')) $chance = intdiv($chance, 3);   // v0.9.1
    $seedRoll = random_int(1, 100) <= $chance;
    if ($seedRoll || calling_perk($u, 'seed_always') > 0) {   // v0.9.1: Seedkeeper masters always save one
        $seeds = $seedRoll ? random_int(1, (int)$p['perennial'] ? 1 : 2) : 1;
        if (calling_perk($u, 'seed_pairs') > 0) $seeds *= 2;   // v0.9.1: saved seeds doubled
        require_once __DIR__ . '/breeding110.php';
        $seedItem = breeding110_seed_item($p);   // v1.1.0: a hybrid never gives its own seed back (a parent's instead)
        give_item($uid, $seedItem, $seeds);
        calling_event($uid, 'seed_saved', (string)$p['slug'], $seeds, ['kind' => (string)$p['kind'], 'helper' => $helper !== null]);   // v0.9.4 N8
        $msgs[] = 'You saved ' . $seeds . ' × ' . q_val('SELECT name FROM items WHERE id = ?', [$seedItem]) . '.';
    }

    $k = q_one('SELECT knowledge FROM user_plant_knowledge WHERE user_id = ? AND plant_id = ?', [$uid, $p['id']]);
    $before = $k ? (int)$k['knowledge'] : 0;
    $learn = (int)$p['knowledge_per_harvest'] * (1 + 0.08 * eff_mod($u, 'lore')) * (1 + calling_perk($u, 'knowledge_pct') / 100);   // v0.9.1: Seedkeeper tiers
    $after = min((int)$p['knowledge_max'], $before + max(1, (int)round($learn)));
    if ($k) {
        q('UPDATE user_plant_knowledge SET knowledge = ? WHERE user_id = ? AND plant_id = ?', [$after, $uid, $p['id']]);
    } else {
        db_insert('user_plant_knowledge', ['user_id' => $uid, 'plant_id' => $p['id'], 'knowledge' => $after]);
    }
    if ($before < (int)$p['knowledge_max'] && $after >= (int)$p['knowledge_max']) {
        $msgs[] = '⭐ You have mastered ' . $p['name'] . '! You know it by heart now: it grows at full speed and harvest, guide or not.';
    }
    if (!$isCover) { require_once __DIR__ . '/breeding110.php'; foreach (breeding110_on_harvest($u, $t, $p) as $bm) $msgs[] = $bm; }   // v1.1.0: crop breeding (after knowledge, so a harvest that masters it counts)
    require_once __DIR__ . '/animals140.php'; foreach (animals140_on_harvest($u, $t, $p) as $am) $msgs[] = $am;   // v1.4.0: a butterfly bush gives a flower nearby +1 stem
    require_once __DIR__ . '/animals120.php'; foreach (animals120_on_harvest($u, $p) as $am) $msgs[] = $am;   // v1.2.0: a mulberry gives Mulberry Leaves for silkworms

    $xp = $helper !== null ? (int)round((int)$p['xp_per_harvest'] * (int)setting('helper_xp_percent') / 100) : (int)$p['xp_per_harvest'];
    if ($regrown) $xp = (int)round($xp * (int)setting('regrow_xp_percent') / 100);   // v0.7.64
    $gxp = $xp;   // garden XP keeps its own curve
    [$xp, $lvl] = add_action_xp($uid, $xp, 'Harvesting', (int)$u['level']);   // v0.9.7: action XP grows with the gnome's level
    $glvl = add_garden_xp((int)$t['plot_id'], $gxp);
    $msgs[] = '+' . $xp . ' XP';
    if ($glvl) {
        $msgs[] = '🏡 Your garden reached garden level ' . $glvl . '!';
    }
    if ($lvl) {
        $msgs[] = '🎉 You reached gnome level ' . $lvl . '! You have new stat points to spend on your gnome.';
        if ($lvl >= (int)setting('calling_level') && (int)$u['level'] < (int)setting('calling_level')) {
            $msgs[] = '🎩 You can now choose your calling! Visit My Gnome.';
        }
        if ($lvl >= (int)setting('notill_level') && (int)$u['level'] < (int)setting('notill_level')) {
            $msgs[] = '🐦 Wren the naturalist has taught you no-till gardening! Sheet mulch a square with cardboard and mulch.';
        }
    }
    return array_merge($msgs, almanac_after_harvest($uid, (int)$p['id']));
}

/**
 * v0.9.5: "Add 4 beds". The yard already holds every bed square as a free-standing piece (plot_tiles.yx/yy, movable in the
 * designer like decor), so new beds are just 4 more tiles with the next free identity x/y and a free 2 × 2 spot in the yard
 * (or single spots, via yard_sync, when there is no 2 × 2 gap). The plot's width/height stay as the bounding box of the identities.
 * Cost climbs by bed_add_growth_pct each purchase (Petals and items); the total is capped by garden_max_side()².
 */

/** Add-4-beds purchases so far. Old gardens (NULL) count whatever they grew past the starting square, in sets of 4. */
function bed_adds(array $plot): int
{
    if ($plot['bed_adds'] ?? null) return (int)$plot['bed_adds'];
    if (($plot['bed_adds'] ?? null) !== null) return 0;
    $start = max(2, (int)setting('starting_plot_size'));
    $beds = (int)q_val('SELECT COUNT(*) FROM plot_tiles WHERE plot_id = ?', [$plot['id']]);
    return max(0, (int)ceil(($beds - $start * $start) / 4));
}

/** Beds this garden may still add under its garden-level cap (never negative). */
function bed_room(array $plot): int
{
    $max = garden_max_side($plot);
    return max(0, $max * $max - (int)q_val('SELECT COUNT(*) FROM plot_tiles WHERE plot_id = ?', [$plot['id']]));
}

/** What the next purchase costs: [petals, [slug => qty]]. Both climb by bed_add_growth_pct per purchase made. */
function bed_add_cost(array $plot): array
{
    $mult = (1 + max(0, (int)setting('bed_add_growth_pct')) / 100) ** bed_adds($plot);
    $items = [];
    foreach (explode(',', (string)setting('bed_add_items')) as $pair) {
        [$s, $n] = array_map('trim', explode(':', $pair) + [1 => 0]);
        if ($s !== '' && (int)$n > 0) $items[$s] = (int)ceil((int)$n * $mult - 1e-9);
    }
    return [(int)round((int)setting('bed_add_cost') * $mult), $items];
}

function expand_plot(int $uid): array
{
    $plotId = active_plot_id($uid);
    $plot = $plotId ? q_one('SELECT * FROM plots WHERE id = ? AND user_id = ?', [$plotId, $uid]) : null;
    if (!$plot) return [false, 'That isn’t your garden.'];
    yard_sync($plotId);
    $room = bed_room($plot);
    if ($room < 1) {
        return [false, garden_max_side($plot) >= (int)setting('max_plot_size')
            ? 'This garden has as many beds as it can ever hold.'
            : 'Your garden needs a higher garden level before it can hold more beds. Harvests raise it.'];
    }
    $n = min(4, $room);
    [$cost, $items] = bed_add_cost($plot);
    $adds = bed_adds($plot) + 1;   // (counted before the new beds go in)
    db()->beginTransaction();
    if ($cost > 0 && !take_petals((int)$uid, (int)$cost)) {
        db()->rollBack();
        return [false, 'Adding beds costs ' . number_format($cost) . ' ' . setting('currency_name') . ($items ? ' and ' . upgrade_mats_text($items) : '') . '.'];
    }
    foreach ($items as $slug => $qty) {
        $id = (int)q_val('SELECT id FROM items WHERE slug = ?', [$slug]);
        if (!$id || !give_item($uid, $id, -$qty)) {
            db()->rollBack();
            return [false, 'You need ' . upgrade_mats_text($items) . ' for that.'];
        }
    }
    // The next free identity squares, row by row, in a grid about as wide as it is tall
    $taken = [];
    foreach (q('SELECT x, y FROM plot_tiles WHERE plot_id = ?', [$plotId])->fetchAll() as $t) $taken[$t['x'] . ',' . $t['y']] = true;
    $cols = max((int)$plot['width'], (int)ceil(sqrt(count($taken) + $n)));
    $new = [];
    for ($y = 0; count($new) < $n; $y++) {
        for ($x = 0; $x < $cols && count($new) < $n; $x++) if (!isset($taken[$x . ',' . $y])) $new[] = [$x, $y];
    }
    // A free 2 × 2 patch of yard next to the beds, if there is one
    $spot = null;
    if ($n === 4) {
        [$yw, $yh] = yard_size($plot);
        $grid = [];
        foreach (q('SELECT yx, yy FROM plot_tiles WHERE plot_id = ? AND yx IS NOT NULL', [$plotId])->fetchAll() as $t) yard_mark($grid, (int)$t['yx'], (int)$t['yy'], 1, 1);
        foreach (q('SELECT x, y, w, h FROM garden_objects WHERE plot_id = ? AND x >= 0', [$plotId])->fetchAll() as $o) yard_mark($grid, (int)$o['x'], (int)$o['y'], (int)$o['w'], (int)$o['h']);
        $c = q('SELECT AVG(yx) AS cx, AVG(yy) AS cy FROM plot_tiles WHERE plot_id = ? AND yx IS NOT NULL', [$plotId])->fetch();
        $spot = yard_free_spot($grid, $yw, $yh, 2, 2, $c && $c['cx'] !== null ? [(int)round((float)$c['cx']), (int)round((float)$c['cy'])] : null);
    }
    foreach ($new as $i => [$x, $y]) {
        db_insert('plot_tiles', ['plot_id' => $plotId, 'user_id' => $uid, 'x' => $x, 'y' => $y,
            'yx' => $spot ? $spot[0] + $i % 2 : null, 'yy' => $spot ? $spot[1] + intdiv($i, 2) : null]);
    }
    q('UPDATE plots SET bed_adds = ?, width = ?, height = ? WHERE id = ?', [$adds, max((int)$plot['width'], ...array_map(fn($p) => $p[0] + 1, $new)),
        max((int)$plot['height'], ...array_map(fn($p) => $p[1] + 1, $new)), $plotId]);
    db()->commit();
    return [true, '🌱 ' . $n . ' new beds! They’re in your yard' . ($spot ? '' : ' (wherever there was room)') . ': move them with ✏️ Design yard. (−' . number_format($cost) . ' ' . setting('currency_name')
        . ($items ? ', ' . upgrade_mats_text($items) : '') . ')'];
}

/**
 * v0.9.5 migration. Idempotent. Every garden keeps all its beds (nothing is moved or removed); each gets its Add-4-beds count
 * from the squares it already grew past the starting square, so the next purchase costs what it would have had they been bought
 * this way. The old plot_expand_cost setting goes.
 */
function upgrade_095_beds(): void
{
    $start = max(2, (int)setting('starting_plot_size'));
    foreach (q('SELECT p.id, COUNT(t.id) AS n FROM plots p LEFT JOIN plot_tiles t ON t.plot_id = p.id WHERE p.bed_adds IS NULL GROUP BY p.id')->fetchAll() as $r) {
        q('UPDATE plots SET bed_adds = ? WHERE id = ?', [max(0, (int)ceil(((int)$r['n'] - $start * $start) / 4)), $r['id']]);
    }
    q("DELETE FROM settings WHERE name = 'plot_expand_cost'");
    setting('__reload__');
}
