<?php
declare(strict_types=1);
/**
 * The Job Board (v0.7.8). Daily, weekly and monthly jobs from NPCs.
 * - Each player sees 5 daily, 5 weekly and 3 monthly offers, picked by a seeded random per player and period,
 *   so offers are never stored. Taking one copies it into user_jobs.
 * - One job per period at a time; once a period's job is finished, the next comes after the reset.
 * - Progress comes from job_event() calls in the game (harvest, water, gather, cook, craft, defeat, grade);
 *   delivery jobs are handed in on the board.
 * - Player-posted jobs (v0.7.9) will share the same table and slots.
 */

require_once __DIR__ . '/player_jobs.php';
require_once __DIR__ . '/calling_quests.php';   // v0.9.4: job_event() forwards to calling_event()

const JOB_PERIODS = ['daily' => ['Daily', '☀️', 5], 'weekly' => ['Weekly', '📅', 5], 'monthly' => ['Monthly', '🌕', 3]];
const JOB_KINDS = ['harvest', 'harvest_crop', 'deliver_crop', 'deliver_gather', 'deliver_dish', 'water', 'gather', 'cook', 'craft', 'defeat', 'grade', 'rebuild'];

/** Period key for now. v1.2.2: the day turns over at midnight Hollow time (game_timezone), not a fixed UTC hour. Same key formats as before. */
function job_period_key(string $period, ?int $at = null): string
{
    return match ($period) {
        'daily' => hollow_date('Y-m-d', $at),
        'weekly' => hollow_date('o-\WW', $at),
        default => hollow_date('Y-m', $at),
    };
}

/** v1.2.2: [start, next reset] timestamps of the period we are in; boundaries are local (Hollow) midnights. */
function job_period_span(string $period, ?int $at = null): array
{
    $d = (new DateTimeImmutable('@' . ($at ?? time())))->setTimezone(hollow_tz())->setTime(0, 0);
    $start = match ($period) {
        'daily' => $d,
        'weekly' => $d->modify('monday this week'),
        default => $d->modify('first day of this month'),
    };
    $end = match ($period) {
        'daily' => $start->modify('+1 day'),
        'weekly' => $start->modify('+7 days'),
        default => $start->modify('+1 month'),
    };
    return [$start->getTimestamp(), $end->getTimestamp()];
}

/** Seconds until the period resets. */
function job_period_left(string $period): int
{
    return max(0, job_period_span($period)[1] - time());
}

function ensure_jobs(): int
{
    require_once __DIR__ . '/catalog.php';
    $added = 0;
    foreach (catalog_lines('jobs.txt') as $r) {
        if (count($r) < 10) continue;
        [$period, $kind, $title, $text, $min, $max, $stages, $coins, $xp, $reward] = $r;
        if (!isset(JOB_PERIODS[$period]) || !in_array($kind, JOB_KINDS, true)) continue;
        if (q_val('SELECT 1 FROM job_templates WHERE period = ? AND title = ?', [$period, $title])) continue;
        db_insert('job_templates', ['period' => $period, 'kind' => $kind, 'title' => $title, 'text' => $text,
            'qty_min' => (int)$min, 'qty_max' => max((int)$min, (int)$max), 'stages' => max(1, (int)$stages),
            'reward_coins' => (int)$coins, 'reward_xp' => (int)$xp, 'reward_item' => $reward === '-' ? null : $reward, 'active' => 1]);
        $added++;
    }
    if (!q_val("SELECT 1 FROM encyclopedia_entries WHERE title = 'The Job Board' AND chapter = 'General'")) {
        $eid = db_insert('encyclopedia_entries', ['chapter' => 'General', 'category' => 'Getting started', 'title' => 'The Job Board',
            'body' => "Gnomes all over the Hollow need a hand. The [b]Job Board[/b] has fresh work every day.\n\n"
                . "☀️ [b]Daily:[/b] pick one of five small jobs. A new one after each daily reset.\n"
                . "📅 [b]Weekly:[/b] one of five bigger jobs a week, with better rewards.\n"
                . "🌕 [b]Monthly:[/b] one of three big projects a month. They pay at every stage, with something rare at the end.\n\n"
                . "You can hold one of each at a time. Don’t like the offers? Re-roll the daily and weekly offers once each period. "
                . "Every " . (int)setting('job_streak_every') . " dailies you finish earn a bonus, and missing a day never resets the count.",
            'unlock_key' => 'start', 'hint' => '', 'sort_order' => 4]);
        foreach (q("SELECT DISTINCT ue.user_id FROM user_encyclopedia ue JOIN encyclopedia_entries e ON e.id = ue.entry_id WHERE e.unlock_key = 'start'")->fetchAll(PDO::FETCH_COLUMN) as $uid) {
            db_insert('user_encyclopedia', ['user_id' => $uid, 'entry_id' => $eid, 'unlocked_at' => now()]);
        }
    }
    return $added;
}

/** A small seeded random generator, so a player's offers are the same all day. */
final class JobRng
{
    private int $s;
    public function __construct(string $seed) { $this->s = crc32($seed) ?: 1; }
    public function int(int $min, int $max): int
    {
        $this->s = ($this->s * 1103515245 + 12345) & 0x7fffffff;
        return $max <= $min ? $min : $min + $this->s % ($max - $min + 1);
    }
    public function pick(array $a) { return $a ? $a[array_keys($a)[$this->int(0, count($a) - 1)]] : null; }
}

/** What this player could be asked for: crops they can grow, gathers they've found, dishes they know, and so on. */
function job_context(array $u): array
{
    static $cache = [];
    $uid = (int)$u['id'];
    if (isset($cache[$uid])) return $cache[$uid];
    require_once __DIR__ . '/world.php';
    $known = array_keys(known_plants($u));
    // v0.7.48: only crops you could actually grow or hand in now (you hold their seeds or the crop itself)
    $crops = $known ? q('SELECT p.slug, p.name, i.id AS item_id, i.name AS item_name FROM plants p JOIN items i ON i.id = p.produce_item_id
                         WHERE p.id IN (' . implode(',', array_map('intval', $known)) . ") AND p.kind NOT IN ('cover', 'flower') AND p.perennial = 0
                         AND EXISTS (SELECT 1 FROM user_items ui WHERE ui.user_id = ? AND ui.qty > 0 AND ui.item_id IN (p.seed_item_id, p.produce_item_id))", [$uid])->fetchAll() : [];
    $gathers = q("SELECT i.id AS item_id, i.slug, i.name AS item_name FROM user_encyclopedia ue JOIN encyclopedia_entries e ON e.id = ue.entry_id
                  JOIN items i ON i.slug = SUBSTR(e.unlock_key, 8) WHERE ue.user_id = ? AND e.unlock_key LIKE 'gather:%'", [$uid])->fetchAll();
    $dishes = q("SELECT i.id AS item_id, i.slug, i.name AS item_name FROM user_recipes ur JOIN recipes r ON r.id = ur.recipe_id
                 JOIN items i ON i.id = r.output_item_id WHERE ur.user_id = ? AND r.category = 'cooking'", [$uid])->fetchAll();
    $kitchen = (bool)q_val("SELECT 1 FROM garden_buildings gb JOIN plots p ON p.id = gb.plot_id WHERE p.user_id = ? AND gb.building = 'kitchen'", [$uid]);
    $tiles = (int)q_val('SELECT COUNT(*) FROM plot_tiles WHERE user_id = ?', [$uid]);
    $npcs = q('SELECT name FROM npcs WHERE active = 1 ORDER BY id')->fetchAll(PDO::FETCH_COLUMN) ?: ['Wren'];
    require_once __DIR__ . '/rebuild.php';
    return $cache[$uid] = [
        'ruins' => [],   // v0.7.77 repairs replaced the monthly rebuild job: no new offers (an empty pool skips the template)
        'crops' => $crops, 'gathers' => $gathers, 'dishes' => $dishes, 'kitchen' => $kitchen, 'npcs' => $npcs,
        'notill' => (int)$u['level'] >= (int)setting('notill_level'),
        'gather_tool' => (bool)array_filter(['forage', 'pick', 'net', 'bucket', 'axe', 'rod'], fn($t) => tool_tier($uid, $t) > 0),   // axe, rod: v0.7.81
        'scale' => min(2.5, max(1.0, sqrt(max(16, $tiles) / 16))),
        'early' => (int)$u['level'] < 4,   // v0.7.48: smaller jobs for a gnome's first days
    ];
}

/** Build one concrete offer from a template, or null if this player can't do it yet. */
function job_from_template(array $tpl, array $ctx, JobRng $rng): ?array
{
    $item = null;
    switch ($tpl['kind']) {
        case 'harvest_crop':
        case 'deliver_crop':
            $item = $rng->pick($ctx['crops']);
            if (!$item) return null;
            break;
        case 'deliver_gather':
            $item = $rng->pick($ctx['gathers']);
            if (!$item) return null;
            break;
        case 'deliver_dish':
            $item = $rng->pick($ctx['dishes']);
            if (!$item) return null;
            break;
        case 'cook':
            if (!$ctx['kitchen']) return null;
            break;
        case 'gather':
            if (!$ctx['gather_tool']) return null;
            break;
        case 'grade':
            if (!$ctx['notill']) return null;
            break;
        case 'rebuild':   // v0.7.29: a ruined landmark in the home region
            $item = $rng->pick($ctx['ruins']);
            if (!$item) return null;
            $item['slug'] = 'lm:' . $item['id'];
            $item['item_id'] = 0;
            break;
    }
    $qty = $rng->int((int)$tpl['qty_min'], (int)$tpl['qty_max']);
    if (in_array($tpl['kind'], ['harvest', 'harvest_crop', 'deliver_crop'], true)) $qty = (int)round($qty * $ctx['scale']);
    if (!empty($ctx['early']) && in_array($tpl['kind'], ['harvest', 'harvest_crop', 'deliver_crop', 'water', 'gather', 'deliver_gather', 'defeat'], true)) $qty = max(1, (int)ceil($qty / 2));
    $npc = (string)$rng->pick($ctx['npcs']);
    $name = $item['item_name'] ?? '';
    $text = str_replace('{qty} {item}', '{qty} × {item}', (string)$tpl['text']);
    $text = strtr($text, ['{qty}' => (string)$qty, '{item}' => $name, '{npc}' => $npc]);
    if ($qty === 1) $text = preg_replace('/\b1 (thing|meal|crop|creature)s\b/', '1 $1', $text);
    if ($tpl['kind'] === 'grade') $text = strtr($text, ['{qty}' => grade_name($qty)]);
    if ($tpl['kind'] === 'rebuild') $qty = 4;   // the four building stages
    return ['template_id' => (int)$tpl['id'], 'period' => $tpl['period'], 'kind' => $tpl['kind'], 'title' => mb_substr(strtr((string)$tpl['title'], ['{item}' => $name]), 0, 80),
        'text' => $text, 'npc' => $npc, 'target' => $item['slug'] ?? '', 'target_item_id' => (int)($item['item_id'] ?? 0),
        'target_name' => $name, 'qty' => max(1, $qty), 'stages' => max(1, (int)$tpl['stages']),
        'reward_coins' => (int)$tpl['reward_coins'], 'reward_xp' => (int)$tpl['reward_xp'], 'reward_item' => (string)($tpl['reward_item'] ?? '')];
}

/** Rerolls used this period (0 or 1). */
function job_rerolled(int $uid, string $period): bool
{
    return (bool)q_val('SELECT 1 FROM job_rerolls WHERE user_id = ? AND period = ? AND period_key = ?', [$uid, $period, job_period_key($period)]);
}

/** The offers for this player and period: 5 / 5 / 3, all different templates. */
function job_offers(array $u, string $period): array
{
    $uid = (int)$u['id'];
    $ctx = job_context($u);
    $rng = new JobRng($uid . '|' . $period . '|' . job_period_key($period) . '|' . (job_rerolled($uid, $period) ? 'r' : ''));
    $tpls = q('SELECT * FROM job_templates WHERE period = ? AND active = 1 ORDER BY id', [$period])->fetchAll();
    // shuffle with the seeded random
    for ($i = count($tpls) - 1; $i > 0; $i--) {
        $j = $rng->int(0, $i);
        [$tpls[$i], $tpls[$j]] = [$tpls[$j], $tpls[$i]];
    }
    $out = [];
    foreach ($tpls as $tpl) {
        if (count($out) >= JOB_PERIODS[$period][2]) break;
        $job = job_from_template($tpl, $ctx, $rng);
        if ($job) $out[] = $job;
    }
    return $out;
}

/** The player's job for this period (active or finished), or null. Old unfinished jobs expire. */
function current_job(int $uid, string $period): ?array
{
    // NPC jobs end at the reset; player jobs run to their own deadline (settled in player_jobs.php)
    q("UPDATE user_jobs SET status = 'expired' WHERE user_id = ? AND period = ? AND status = 'active' AND period_key <> ? AND player_job_id IS NULL",
        [$uid, $period, job_period_key($period)]);
    return q_one("SELECT * FROM user_jobs WHERE user_id = ? AND period = ?
                  AND ((period_key = ? AND status IN ('active', 'done')) OR (player_job_id IS NOT NULL AND status = 'active'))
                  ORDER BY id DESC LIMIT 1", [$uid, $period, job_period_key($period)]) ?: null;
}

/**
 * Take an offer from the board. The offer is named by its template id and target slug (v0.7.85), not by its position:
 * the board reshuffles with what you hold, so a stale tab must not take a different job from the one it showed.
 */
function take_job(array $u, string $period, int $templateId, string $target = ''): array
{
    $uid = (int)$u['id'];
    if (!isset(JOB_PERIODS[$period])) return [false, 'Unknown job.'];
    if (current_job($uid, $period)) return [false, 'You already have a ' . strtolower(JOB_PERIODS[$period][0]) . ' job ' . job_period_phrase($period) . '.'];
    $job = null;
    foreach (job_offers($u, $period) as $o) {
        if ((int)$o['template_id'] === $templateId && (string)$o['target'] === $target) { $job = $o; break; }
    }
    if (!$job) return [false, 'That job board changed. Here’s the new one.'];
    // v0.7.85: giving a job up keeps its row, so taking the same job again in the same period resumes it.
    // Progress and the stages already paid are carried over: a stage is never paid twice.
    $prev = q_one("SELECT progress, stages_paid FROM user_jobs WHERE user_id = ? AND template_id = ? AND period_key = ?
                   AND status = 'abandoned' AND player_job_id IS NULL ORDER BY id DESC LIMIT 1", [$uid, $templateId, job_period_key($period)]);
    $progress = $prev ? (int)$prev['progress'] : ($job['kind'] === 'grade' ? -1 : 0);
    $paid = $prev ? (int)$prev['stages_paid'] : 0;
    [$rewardItemId, $rewardQty] = resolve_job_reward($job['reward_item'], $uid . '|' . job_period_key($period));
    // v1.2.2: lock this gnome, re-check the slot, then insert (two logins could both pass the check above)
    db()->beginTransaction();
    q('UPDATE users SET id = id WHERE id = ?', [$uid]);
    if (current_job($uid, $period)) {
        db()->rollBack();
        return [false, 'You already have a ' . strtolower(JOB_PERIODS[$period][0]) . ' job ' . job_period_phrase($period) . '.'];
    }
    db_insert('user_jobs', ['user_id' => $uid, 'period' => $period, 'period_key' => job_period_key($period), 'template_id' => $job['template_id'],
        'kind' => $job['kind'], 'title' => $job['title'], 'text' => $job['text'], 'npc' => $job['npc'],
        'target' => $job['target'], 'target_item_id' => $job['target_item_id'] ?: null, 'target_name' => $job['target_name'],
        'qty' => $job['qty'], 'progress' => $progress, 'stages' => $job['stages'], 'stages_paid' => $paid,
        'reward_coins' => $job['reward_coins'], 'reward_xp' => $job['reward_xp'], 'reward_item_id' => $rewardItemId ?: null,
        'reward_qty' => $rewardQty, 'status' => 'active', 'taken_at' => now()]);
    db()->commit();
    if ($job['kind'] === 'grade') job_event($uid, 'grade', '', best_bed_grade($uid));   // may already be done
    if ($prev) return [true, '📋 You pick the job back up: ' . $job['title'] . ', where you left it.'];
    return [true, '📋 You take the job: ' . $job['title'] . '.'];
}

function job_period_phrase(string $period): string
{
    return ['daily' => 'today', 'weekly' => 'this week', 'monthly' => 'this month'][$period] ?? 'now';
}

function job_period_word(string $period): string
{
    return ['daily' => 'day', 'weekly' => 'week', 'monthly' => 'month'][$period] ?? 'period';
}

/** "@treasure-seed:2" style rewards become a real item now, so the board can show it. */
function resolve_job_reward(string $spec, string $seed): array
{
    if ($spec === '') return [0, 0];
    [$slug, $qty] = array_map('trim', explode(':', $spec) + [1 => 1]);
    $rng = new JobRng($seed . $slug);
    $pool = match ($slug) {
        '@treasure-seed' => q("SELECT DISTINCT p.seed_item_id FROM plant_regions pr JOIN plants p ON p.id = pr.plant_id WHERE pr.tier = 'treasure' AND p.seed_item_id IS NOT NULL")->fetchAll(PDO::FETCH_COLUMN),
        '@guide' => q("SELECT id FROM items WHERE category = 'guide'")->fetchAll(PDO::FETCH_COLUMN),
        '@rare-gather' => q("SELECT item_id FROM gatherables WHERE rarity = 'rare' AND active = 1")->fetchAll(PDO::FETCH_COLUMN),
        '@rare-material' => q("SELECT g.item_id FROM gatherables g JOIN items i ON i.id = g.item_id WHERE g.rarity IN ('uncommon', 'rare') AND i.edible = 0 AND g.active = 1")->fetchAll(PDO::FETCH_COLUMN),
        default => [q_val('SELECT id FROM items WHERE slug = ?', [$slug])],
    };
    $pool = array_values(array_filter($pool));
    return $pool ? [(int)$rng->pick($pool), max(1, (int)$qty)] : [0, 0];
}

function abandon_job(int $uid, string $period): array
{
    $job = current_job($uid, $period);
    if (!$job || $job['status'] !== 'active') return [false, 'No job to give up.'];
    if ($job['player_job_id']) {
        $pj = q_one('SELECT * FROM player_jobs WHERE id = ?', [$job['player_job_id']]);
        if ($pj) pjob_close($pj, 'abandoned');   // the unearned wage goes back to the poster
    }
    q("UPDATE user_jobs SET status = 'abandoned' WHERE id = ?", [$job['id']]);
    return [true, 'You give up “' . $job['title'] . '”. You can take another ' . strtolower(JOB_PERIODS[$period][0]) . ' job.'];
}

function reroll_jobs(int $uid, string $period): array
{
    if ($period === 'monthly' || !isset(JOB_PERIODS[$period])) return [false, 'Monthly offers can’t be re-rolled.'];
    if (job_rerolled($uid, $period)) return [false, 'You’ve already re-rolled the offers ' . job_period_phrase($period) . '.'];
    db_insert('job_rerolls', ['user_id' => $uid, 'period' => $period, 'period_key' => job_period_key($period)]);
    return [true, '🎲 New ' . strtolower(JOB_PERIODS[$period][0]) . ' offers are pinned to the board.'];
}

/** Best soil grade among the player's no-till beds (-1 if none). */
function best_bed_grade(int $uid): int
{
    $score = q_val("SELECT MAX(bed_score) FROM plot_tiles WHERE user_id = ? AND method = 'notill'", [$uid]);
    return $score === null || $score === false ? -1 : grade_index(['method' => 'notill', 'bed_score' => (int)$score]);
}

/**
 * Something happened in the game. $kind: harvest (target = crop slug), water, gather (target = item slug),
 * cook, craft, defeat, grade ($n = the best grade reached, not a count).
 */
function job_event(int $uid, string $kind, string $target, int $n, array $ctx = []): void   // v0.9.4: $ctx (eat: homecooked, tier; cook: tier)
{
    calling_event($uid, $kind, $target, $n, $ctx);   // v0.9.4: the calling questline listens to every job event too
    if ($kind === 'cook' && ($ctx['tier'] ?? '') !== 'preserve') unlock_entries($uid, 'pots');   // v0.9.5: the Almanac's Pots page opens when you collect your first pot (one 'cook' event per pot)
    if ($n <= 0 && $kind !== 'grade') return;
    $kinds = match ($kind) {
        'harvest' => ['harvest', 'harvest_crop'],
        'cook' => in_array($ctx['tier'] ?? 'meal', ['snack', 'preserve'], true) ? ['craft'] : ['cook', 'craft'],   // v0.9.4: "cook N meals" counts Meal and Feast makes only; a snack or a Pantry preserve is still a craft
        default => [$kind],
    };
    $in = implode(',', array_fill(0, count($kinds), '?'));
    $jobs = q("SELECT * FROM user_jobs WHERE user_id = ? AND status = 'active' AND kind IN ($in)", array_merge([$uid], $kinds))->fetchAll();
    foreach ($jobs as $job) {
        if ($job['period_key'] !== job_period_key($job['period'])) continue;   // expired; tidied up on the board
        if ($job['kind'] === 'harvest_crop' && $job['target'] !== $target) continue;
        $add = $job['kind'] === 'harvest' ? 1 : $n;   // "harvest N crops" counts plants, not produce
        $progress = $job['kind'] === 'grade' ? max((int)$job['progress'], $n) : min((int)$job['qty'], (int)$job['progress'] + $add);
        if ($progress === (int)$job['progress']) continue;
        q('UPDATE user_jobs SET progress = ? WHERE id = ?', [$progress, $job['id']]);
        $job['progress'] = $progress;
        job_pay($uid, $job);
    }
}

/** Hand in items for a delivery job. */
function deliver_job(int $uid, string $period): array
{
    $job = current_job($uid, $period);
    if ($job && $job['status'] === 'active' && $job['kind'] === 'p_deliver') {
        return pjob_deliver(q_one('SELECT * FROM users WHERE id = ?', [$uid]), $job);
    }
    if (!$job || $job['status'] !== 'active' || !str_starts_with((string)$job['kind'], 'deliver')) return [false, 'Nothing to deliver.'];
    $need = (int)$job['qty'] - (int)$job['progress'];
    $have = (int)q_val('SELECT qty FROM user_items WHERE user_id = ? AND item_id = ?', [$uid, $job['target_item_id']]);
    $give = min($need, $have);
    if ($give <= 0) return [false, 'You don’t have any ' . $job['target_name'] . ' to hand in.'];
    db()->beginTransaction();
    if (!give_item($uid, (int)$job['target_item_id'], -$give)) {
        db()->rollBack();
        return [false, 'You don’t have that many.'];
    }
    // v1.2.2: if the progress didn't move (a second login got there first), roll back so the items aren't spent
    if (q('UPDATE user_jobs SET progress = progress + ? WHERE id = ? AND progress = ? AND progress + ? <= qty AND status = \'active\'', [$give, $job['id'], $job['progress'], $give])->rowCount() !== 1) {
        db()->rollBack();
        return [false, 'That job changed. Have another look.'];
    }
    $job['progress'] = (int)$job['progress'] + $give;
    job_pay($uid, $job);
    db()->commit();
    return [true, '📦 You hand ' . $give . ' × ' . $job['target_name'] . ' to ' . $job['npc'] . '.'];
}

/** v0.9.1: the XP a job pays. Monthly jobs pay job_xp_monthly_percent of the listed XP; daily and weekly pay in full. */
function job_xp_paid(array $job): int
{
    $xp = (int)($job['reward_xp'] ?? 0);
    return ($job['period'] ?? '') === 'monthly' ? (int)round($xp * (int)setting('job_xp_monthly_percent') / 100) : $xp;
}

/**
 * Pay any stages reached. Each stage before the last pays half the coins split evenly;
 * finishing pays the rest, the XP and the item. Uses an atomic update so nothing pays twice.
 */
function job_pay(int $uid, array $job): void
{
    $stages = max(1, (int)$job['stages']);
    $grade = $job['kind'] === 'grade';
    $reached = $grade ? ((int)$job['progress'] >= (int)$job['qty'] ? $stages : 0)
                      : min($stages, intdiv((int)$job['progress'] * $stages, max(1, (int)$job['qty'])));
    $paid = (int)$job['stages_paid'];
    if ($reached <= $paid) return;
    $done = $reached >= $stages;
    if (q('UPDATE user_jobs SET stages_paid = ?, status = ?, done_at = ? WHERE id = ? AND stages_paid = ?',
            [$reached, $done ? 'done' : 'active', $done ? now() : null, $job['id'], $paid])->rowCount() !== 1) return;
    $stageCoins = $stages > 1 ? intdiv((int)$job['reward_coins'], 2 * $stages) : 0;
    $coins = 0;
    for ($s = $paid + 1; $s <= $reached; $s++) {
        $coins += $s < $stages ? $stageCoins : (int)$job['reward_coins'] - $stageCoins * ($stages - 1);
    }
    if ($coins) q('UPDATE users SET coins = coins + ? WHERE id = ?', [$coins, $uid]);
    if (!$done) {
        flash('📋 ' . $job['title'] . ': stage ' . $reached . ' of ' . $stages . ' done! ' . $job['npc'] . ' pays you ' . money($coins) . '.');
        return;
    }
    $bits = [money($coins)];
    $jxp = job_xp_paid($job);   // v0.9.1: monthly jobs pay a share of the listed XP
    if ($jxp > 0) {
        add_xp($uid, $jxp, 'Jobs');
        $bits[] = $jxp . ' XP';
    }
    if ((int)$job['reward_item_id'] && (int)$job['reward_qty']) {
        give_item($uid, (int)$job['reward_item_id'], (int)$job['reward_qty']);
        $bits[] = (int)$job['reward_qty'] . ' × ' . q_val('SELECT name FROM items WHERE id = ?', [$job['reward_item_id']]);
    }
    prize('📋', 'Job done: ' . $job['title'] . '!', '', array_merge([$job['npc'] . ' says thank you!'], $bits));
    if ($job['period'] === 'daily') {
        q('UPDATE users SET job_dailies = job_dailies + 1 WHERE id = ?', [$uid]);
        $count = (int)q_val('SELECT job_dailies FROM users WHERE id = ?', [$uid]);
        $every = max(1, (int)setting('job_streak_every'));
        if ($count % $every === 0) {
            $bonus = (int)setting('job_streak_bonus_coins');
            q('UPDATE users SET coins = coins + ? WHERE id = ?', [$bonus, $uid]);
            flash('🌟 That’s ' . $count . ' daily jobs done! Bonus: ' . money($bonus) . '.');
        }
    }
}

/** Short progress text for a job card. */
function job_progress_text(array $job): string
{
    if ($job['kind'] === 'rebuild') return 'Stage ' . min(4, (int)$job['progress'] + ($job['status'] === 'done' ? 0 : 1)) . ' of 4 · ' . (int)$job['progress'] . ' done';
    if ($job['kind'] === 'grade') {
        return 'Best bed: ' . ((int)$job['progress'] >= 0 ? grade_name((int)$job['progress']) : 'none yet') . ' · goal ' . grade_name((int)$job['qty']);
    }
    return (int)$job['progress'] . ' / ' . (int)$job['qty'] . ((int)$job['stages'] > 1 ? ' · stage ' . min((int)$job['stages'], (int)$job['stages_paid'] + 1) . ' of ' . (int)$job['stages'] : '');
}

/** Where to get what a job asks for (v0.7.48), shown under each offer. */
function job_hint(array $job): string
{
    return match ((string)$job['kind']) {
        'harvest', 'harvest_crop' => '🌱 Grow it in your garden. Seeds are sold at the seed market in town.',
        'deliver_crop' => '🌱 Grow it, or buy it at the Trading Post.',
        'deliver_gather', 'gather' => '🔍 Found while wandering off the road (a foraging tool helps).',
        'deliver_dish' => '🍳 Cook it in Crafting → Cooking (needs a Kitchen in your garden).',
        'cook' => '🍳 Cook meals or feasts in Crafting → Cooking (snacks don’t count). A dish counts when you collect it from the pot.',   // v0.9.4
        'craft' => '🔨 Anything from the Crafting page counts.',
        'water' => '💧 Every square you water counts, in any of your gardens.',
        'defeat' => '⚔️ Creatures wait on the roads and in the wilds.',
        'grade' => '🍂 Raise a no-till bed’s soil grade.',
        'rebuild' => '🧱 Building materials come from Crafting → Building.',
        default => '',
    };
}

