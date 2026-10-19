<?php
declare(strict_types=1);

/**
 * v1.0.0 wave 3: Hollow Goals (a shared weekly jar) and the Hollow Pulse (who is about).
 *
 * Every week one jar is made for the whole Hollow ("Harvest 120 carrots", "Cook 40 meals", "Visit 60 stops"). It is sized for the
 * number of gnomes who were about in the last week (never fewer than the goal_per_gnome setting), so a small world can still fill it.
 * What gnomes already do fills it: hollow_goal_event() is called from calling_event(), which job_event() and the other hooks feed.
 * The townsfolk add a share (goal_townsfolk_pct of the jar, spread evenly over the week) so it never stalls.
 * Four tiers (25, 50, 75, 100 %): every gnome who put something in gets each tier's reward once. Nothing is lost by missing a day.
 * Festivals add their own jar the same way (festival.php); the weekly jar carries on beside it.
 */

/** [kind, filter, title ("{n}" = target), icon, per-gnome amount, noun for the meter]. A crop filter is a plant slug; kind "any" counts whatever gnomes do. */
const HOLLOW_GOAL_POOL = [
    ['harvest', 'carrot', 'Harvest {n} carrots', '🥕', 30, 'carrots'],
    ['harvest', 'radish', 'Harvest {n} radishes', '🌱', 30, 'radishes'],
    ['harvest', 'lettuce', 'Harvest {n} heads of lettuce', '🥬', 30, 'lettuces'],
    ['harvest', 'tomato', 'Harvest {n} tomatoes', '🍅', 30, 'tomatoes'],
    ['harvest', 'potato', 'Harvest {n} potatoes', '🥔', 30, 'potatoes'],
    ['harvest', 'pumpkin', 'Harvest {n} pumpkins', '🎃', 12, 'pumpkins'],
    ['harvest', '', 'Harvest {n} crops of any kind', '🧺', 50, 'crops'],
    ['water', '', 'Water {n} thirsty plants', '💧', 80, 'waterings'],
    ['cook', '', 'Cook {n} meals', '🍲', 10, 'meals'],
    ['arrive', '', 'Walk to {n} stops', '🥾', 12, 'stops'],
    ['gather', '', 'Gather {n} wild finds', '🌿', 35, 'finds'],
    ['craft', '', 'Make {n} things in the workshop and kitchen', '🔨', 12, 'things'],
    ['townact', '', 'Enjoy {n} outings in town squares', '🏘️', 18, 'outings'],
    ['defeat', '', 'Meet {n} creatures on the roads', '🐞', 12, 'creatures'],
];

/** Tier fractions and the items that come with each tier (coins come from the goal_tier_coins setting). */
const HOLLOW_GOAL_TIERS = [25, 50, 75, 100];
const HOLLOW_GOAL_TIER_ITEMS = ['', 'plain-compost:3', 'worm-castings:2', 'rich-loam:2'];
const HOLLOW_GOAL_TIER_XP = [5, 10, 15, 25];

function hollow_goals_on(): bool
{
    return setting('goals_on') === '1';
}

/** [key, startTs, endTs] of the job-board week we are in (v1.2.2: weeks run Monday midnight to Monday midnight, Hollow time). */
function hollow_goal_week(?int $at = null): array
{
    $at ??= time();
    $start = (new DateTimeImmutable('@' . $at))->setTimezone(hollow_tz())->setTime(0, 0)->modify('monday this week');
    return [hollow_date('o-\WW', $at), $start->getTimestamp(), $start->modify('+7 days')->getTimestamp()];
}

/** How many gnomes the jar is sized for: those seen in the last week, never fewer than goal_per_gnome. */
function hollow_goal_gnomes(): int
{
    $n = (int)q_val('SELECT COUNT(*) FROM users u WHERE u.onboarded = 1 AND u.deleted_at IS NULL AND u.last_seen > ? AND ' . gnome_in_play_sql('u'), [gmdate('Y-m-d H:i:s', time() - 7 * 86400)]);
    return max(1, (int)setting('goal_per_gnome'), $n);
}

/** A round target: 5s up to 100, 10s up to 500, then 25s. */
function hollow_goal_round(int $n): int
{
    $step = $n <= 100 ? 5 : ($n <= 500 ? 10 : 25);
    return max($step, (int)(round($n / $step) * $step));
}

/** Make this week's jar if it does not exist yet. Returns it. */
function hollow_goal_make_weekly(): ?array
{
    [$key, $start, $end] = hollow_goal_week();
    $pk = 'week:' . $key;
    if ($g = q_one('SELECT * FROM hollow_goals WHERE period_key = ?', [$pk])) return $g;
    // a pool entry whose crop exists (and, for crops, rotate by week so the same one doesn't come twice in a row)
    $pool = [];
    foreach (HOLLOW_GOAL_POOL as $e) {
        if ($e[0] === 'harvest' && $e[1] !== '' && !q_val('SELECT 1 FROM plants WHERE slug = ?', [$e[1]])) continue;
        $pool[] = $e;
    }
    if (!$pool) return null;
    [$kind, $filter, $title, $icon, $per] = $pool[crc32('hollowgoal|' . $key) % count($pool)];
    $target = hollow_goal_round($per * hollow_goal_gnomes());
    try {
        db_insert('hollow_goals', ['period_key' => $pk, 'kind' => $kind, 'filter' => $filter, 'title' => str_replace('{n}', (string)$target, $title), 'icon' => $icon,
            'target' => $target, 'progress' => 0, 'festival' => null, 'starts_at' => gmdate('Y-m-d H:i:s', $start), 'ends_at' => gmdate('Y-m-d H:i:s', $end), 'created_at' => now()]);
    } catch (PDOException $e) {
        // two visitors at once: the other one made it
    }
    return q_one('SELECT * FROM hollow_goals WHERE period_key = ?', [$pk]);
}

/** Jars that are filling right now (this week's, and any festival's). Makes this week's jar the first time anyone asks. */
function hollow_goals_active(): array
{
    static $cache = null;
    if ($cache !== null) return $cache;
    $cache = [];
    if (!hollow_goals_on()) return $cache;
    try {
        hollow_goal_make_weekly();
        if (function_exists('festival_ensure_goals')) festival_ensure_goals();
        hollow_goal_rollup();   // v1.0.1
        $cache = q('SELECT * FROM hollow_goals WHERE starts_at <= ? AND ends_at > ? ORDER BY id', [now(), now()])->fetchAll();
    } catch (Throwable $e) {
        error_log('hollow goals: ' . $e->getMessage());
    }
    return $cache;
}

/**
 * v1.0.1: add up every gnome's share into hollow_goals.progress. At most once a minute for the whole site (a conditional
 * UPDATE on a settings row picks one request), and only for jars still filling or ended in the last two days.
 */
function hollow_goal_rollup(bool $force = false): void
{
    static $ran = false;
    if ($ran && !$force) return;
    $ran = true;
    try {
        $t = time();
        if (!$force) {
            if (!q_val("SELECT COUNT(*) FROM settings WHERE name = 'goal_rollup_at'")) {
                try { db_insert('settings', ['name' => 'goal_rollup_at', 'value' => '0']); } catch (PDOException $e) { /* another request made it */ }
            }
            $last = (int)q_val("SELECT value FROM settings WHERE name = 'goal_rollup_at'");
            if ($last > $t - 60) return;
            if (q("UPDATE settings SET value = ? WHERE name = 'goal_rollup_at' AND value = ?", [(string)$t, (string)$last])->rowCount() !== 1) return;   // someone else is on it
        }
        q('UPDATE hollow_goals SET progress = (SELECT COALESCE(SUM(c.amount), 0) FROM hollow_goal_contrib c WHERE c.goal_id = hollow_goals.id) WHERE ends_at > ? AND starts_at <= ?',
            [gmdate('Y-m-d H:i:s', $t - 2 * 86400), now()]);
    } catch (Throwable $e) {
        error_log('hollow goal rollup: ' . $e->getMessage());
    }
}

/** Does this event fill this jar? Returns how much it adds (0 = nothing). */
function hollow_goal_adds(array $g, string $kind, string $target, int $n, array $ctx): int
{
    if ($n <= 0) return 0;
    if ($kind === 'cook' && !in_array($ctx['tier'] ?? 'meal', ['meal', 'feast'], true)) return 0;   // snacks and preserves are crafts
    if ($g['kind'] === 'any') return in_array($kind, ['harvest', 'water', 'gather', 'cook', 'craft', 'arrive', 'townact', 'defeat'], true) ? min($n, 3) : 0;
    if ($g['kind'] !== $kind) return 0;
    if ($g['kind'] === 'harvest' && (string)$g['filter'] !== '' && $target !== (string)$g['filter']) return 0;
    return $n;
}

/** Called from calling_event(): something happened for this gnome. Never breaks the game. */
function hollow_goal_event(int $uid, string $kind, string $target = '', int $n = 1, array $ctx = []): void
{
    if ($n <= 0 || !hollow_goals_on()) return;
    try {
        foreach (hollow_goals_active() as $g) {
            $add = hollow_goal_adds($g, $kind, $target, $n, $ctx);
            if ($add <= 0) continue;
            // v1.0.1: only the gnome's own row is written here; the jar total is summed from these rows (hollow_goal_rollup), so busy jars don't queue on one row
            if (q('UPDATE hollow_goal_contrib SET amount = amount + ? WHERE goal_id = ? AND user_id = ?', [$add, $g['id'], $uid])->rowCount() === 0) {
                try {
                    db_insert('hollow_goal_contrib', ['goal_id' => $g['id'], 'user_id' => $uid, 'amount' => $add]);
                } catch (PDOException $e) {
                    q('UPDATE hollow_goal_contrib SET amount = amount + ? WHERE goal_id = ? AND user_id = ?', [$add, $g['id'], $uid]);
                }
            }
        }
    } catch (Throwable $e) {
        error_log('hollow goal event: ' . $e->getMessage());
    }
}

/** What the townsfolk have put in so far: their share of the jar, spread evenly over its window (a finished jar has all of it). */
function hollow_goal_townsfolk(array $g, ?int $at = null): int
{
    $pct = max(0, min(60, (int)setting('goal_townsfolk_pct')));
    if ($pct === 0 || !townsfolk_enabled_for_goals()) return 0;
    $s = (int)strtotime($g['starts_at'] . ' UTC');
    $e = (int)strtotime($g['ends_at'] . ' UTC');
    $t = min($at ?? time(), $e);
    $frac = $e > $s ? max(0.0, min(1.0, ($t - $s) / ($e - $s))) : 1.0;
    return (int)floor((int)$g['target'] * $pct / 100 * $frac);
}

function townsfolk_enabled_for_goals(): bool
{
    return setting('townsfolk_entries') === '1';
}

/** The jar as the page shows it: total, percent, tier reached (0-4), next tier. */
function hollow_goal_state(array $g): array
{
    $target = max(1, (int)$g['target']);
    $folk = hollow_goal_townsfolk($g);
    $total = min($target, (int)$g['progress'] + $folk);
    $pct = (int)floor($total * 100 / $target);
    $tier = 0;
    foreach (HOLLOW_GOAL_TIERS as $i => $p) if ($pct >= $p) $tier = $i + 1;
    return ['gnomes' => (int)$g['progress'], 'folk' => $folk, 'total' => $total, 'pct' => $pct, 'tier' => $tier, 'target' => $target,
        'next' => $tier < 4 ? (int)ceil($target * HOLLOW_GOAL_TIERS[$tier] / 100) : null, 'left' => max(0, (int)strtotime($g['ends_at'] . ' UTC') - time())];
}

function hollow_goal_tier_coins(int $tier): int
{
    $c = array_map('intval', explode(',', setting('goal_tier_coins')));
    return max(0, $c[$tier - 1] ?? 0);
}

/** One line: what a tier pays. */
function hollow_goal_tier_text(int $tier): string
{
    $parts = [money(hollow_goal_tier_coins($tier)), HOLLOW_GOAL_TIER_XP[$tier - 1] . ' XP'];
    if ($spec = HOLLOW_GOAL_TIER_ITEMS[$tier - 1] ?? '') {
        [$slug, $qty] = explode(':', $spec) + [1 => '1'];
        $parts[] = $qty . ' × ' . (string)(q_val('SELECT name FROM items WHERE slug = ?', [$slug]) ?: $slug);
    }
    return implode(' + ', $parts);
}

/** A gnome's share of a jar. */
function hollow_goal_share(int $goalId, int $uid): int
{
    return (int)q_val('SELECT amount FROM hollow_goal_contrib WHERE goal_id = ? AND user_id = ?', [$goalId, $uid]);
}

/**
 * Pay every reached tier of every jar this gnome helped fill, once each. Safe to call on any page; cheap when nothing is owed.
 * Returns the lines to show.
 */
function hollow_goal_settle(int $uid): array
{
    if (!hollow_goals_on()) return [];
    hollow_goal_rollup();   // v1.0.1: totals first (at most once a minute)
    $min = max(1, (int)setting('goal_min_share'));
    $lines = [];
    $rows = q('SELECT g.*, c.amount FROM hollow_goals g JOIN hollow_goal_contrib c ON c.goal_id = g.id AND c.user_id = ? WHERE c.amount >= ?
               AND (SELECT COUNT(*) FROM hollow_goal_claims k WHERE k.goal_id = g.id AND k.user_id = ?) < 4 ORDER BY g.id', [$uid, $min, $uid])->fetchAll();
    foreach ($rows as $g) {
        $st = hollow_goal_state($g);
        for ($tier = 1; $tier <= $st['tier']; $tier++) {
            db()->beginTransaction();
            try {
                db_insert('hollow_goal_claims', ['goal_id' => $g['id'], 'user_id' => $uid, 'tier' => $tier, 'claimed_at' => now()]);
            } catch (PDOException $e) {   // already paid (a second tab)
                db()->rollBack();
                continue;
            }
            $coins = hollow_goal_tier_coins($tier);
            if ($coins > 0) q('UPDATE users SET coins = coins + ? WHERE id = ?', [$coins, $uid]);
            if (function_exists('add_xp')) add_xp($uid, HOLLOW_GOAL_TIER_XP[$tier - 1], 'Hollow Goal');
            $got = '';
            if ($spec = HOLLOW_GOAL_TIER_ITEMS[$tier - 1] ?? '') {
                [$slug, $qty] = explode(':', $spec) + [1 => '1'];
                if ($iid = (int)q_val('SELECT id FROM items WHERE slug = ?', [$slug])) { give_item($uid, $iid, max(1, (int)$qty)); $got = ' + ' . (int)$qty . ' × ' . q_val('SELECT name FROM items WHERE id = ?', [$iid]); }
            }
            db()->commit();
            $lines[] = $g['icon'] . ' ' . $g['title'] . ': tier ' . $tier . ' of 4 reached! ' . money($coins) . ' + ' . HOLLOW_GOAL_TIER_XP[$tier - 1] . ' XP' . $got . '.';
        }
    }
    return $lines;
}

/** Settle and show: one prize pop-up listing what was paid. */
function hollow_goal_settle_flash(int $uid): void
{
    if (!($lines = hollow_goal_settle($uid))) return;
    prize('🫙', 'The Hollow filled a tier!', count($lines) === 1 ? '1 reward' : count($lines) . ' rewards', $lines);
}

/** Last jars (not the ones filling now): [goal, state, my share, tier I was paid for]. */
function hollow_goal_history(int $uid, int $limit = 6): array
{
    $out = [];
    foreach (q('SELECT * FROM hollow_goals WHERE ends_at <= ? ORDER BY ends_at DESC, id DESC LIMIT ' . (int)$limit, [now()])->fetchAll() as $g) {
        $out[] = ['goal' => $g, 'state' => hollow_goal_state($g), 'mine' => hollow_goal_share($g['id'], $uid),
            'gnomes' => (int)q_val('SELECT COUNT(*) FROM hollow_goal_contrib WHERE goal_id = ?', [$g['id']])];
    }
    return $out;
}

/** The top helpers of a jar by name (only gnomes with open gardens are named; others are "a quiet gnome"). */
function hollow_goal_helpers(int $goalId, int $limit = 5): array
{
    return q('SELECT c.amount, u.id, u.garden_public, COALESCE(u.gnome_name, u.username) AS name FROM hollow_goal_contrib c JOIN users u ON u.id = c.user_id
              WHERE c.goal_id = ? AND u.deleted_at IS NULL AND ' . gnome_in_play_sql('u') . ' ORDER BY c.amount DESC, u.id LIMIT ' . (int)$limit, [$goalId])->fetchAll();
}

// ---------------- The jar picture ----------------

/** An inline SVG jar filled to $pct percent with the tier lines marked. */
function hollow_jar_svg(int $pct, string $icon = '', string $label = 'The Hollow jar'): string
{
    $pct = max(0, min(100, $pct));
    $top = 44;  $bot = 140;                        // inside of the jar body, y range
    $h = (int)round(($bot - $top) * $pct / 100);
    $y = $bot - $h;
    $lines = '';
    foreach ([25, 50, 75] as $p) {
        $ly = $bot - (int)round(($bot - $top) * $p / 100);
        $lines .= '<line x1="22" y1="' . $ly . '" x2="34" y2="' . $ly . '" class="jt"/><text x="18" y="' . ($ly + 4) . '" class="jtx" text-anchor="end">' . $p . '</text>';
    }
    return '<svg class="jarsvg" viewBox="0 0 150 160" role="img" aria-label="' . e($label . ': ' . $pct . ' percent full') . '">'
        . '<defs><clipPath id="jarclip"><path d="M40 44 Q40 36 48 34 L48 26 L102 26 L102 34 Q110 36 110 44 L112 128 Q112 142 98 142 L52 142 Q38 142 38 128 Z"/></clipPath></defs>'
        . '<g clip-path="url(#jarclip)"><rect x="30" y="26" width="90" height="120" class="jglass"/>'
        . '<rect x="30" y="' . $y . '" width="90" height="' . ($h + 4) . '" class="jfill"/>'
        . '<ellipse cx="75" cy="' . $y . '" rx="45" ry="3" class="jtop"/></g>'
        . '<path d="M40 44 Q40 36 48 34 L48 26 L102 26 L102 34 Q110 36 110 44 L112 128 Q112 142 98 142 L52 142 Q38 142 38 128 Z" class="jline"/>'
        . '<rect x="44" y="14" width="62" height="12" rx="4" class="jlid"/>'
        . $lines
        . ($icon !== '' ? '<text x="75" y="106" text-anchor="middle" class="jicon" font-size="30">' . e($icon) . '</text>' : '')
        . '</svg>';
}

// ---------------- Hollow Pulse ----------------

/** "5 minutes ago" style. */
function pulse_ago(string $utc): string
{
    $s = max(0, time() - (int)strtotime($utc . ' UTC'));
    if ($s < 90) return 'just now';
    if ($s < 3600) return intdiv($s, 60) . ' min ago';
    if ($s < 86400) return intdiv($s, 3600) . ' h ago';
    return intdiv($s, 86400) . ' d ago';
}

/**
 * Who is about and what has been happening. Public things only: nothing from a gnome who keeps their garden private
 * is named (they are counted, never listed), no locations, no trades, no friends. Returns
 * ['about' => ['n' => gnomes seen in the last 15 minutes, 'names' => [[id, name]], 'quiet' => n], 'folk' => [lines], 'news' => [[icon, text, utc]]].
 */
function hollow_pulse(array $viewer): array
{
    // v1.0.1: kept for a minute per gnome (it's seven small queries; "who's about" is counted over 15 minutes anyway)
    $c = $_SESSION['gv_pulse'] ?? null;
    if (is_array($c) && (int)($c['uid'] ?? 0) === (int)$viewer['id'] && ($c['at'] ?? 0) > time() - 60) return $c['p'];
    $p = hollow_pulse_build($viewer);
    $_SESSION['gv_pulse'] = ['uid' => (int)$viewer['id'], 'at' => time(), 'p' => $p];
    return $p;
}

function hollow_pulse_build(array $viewer): array
{
    $vid = (int)$viewer['id'];
    $cut = gmdate('Y-m-d H:i:s', time() - 15 * 60);
    // v1.0.0: a blocked pair never sees each other here; a gnome who turned "show me in the Hollow Pulse" off is only ever counted
    $notBlocked = 'NOT EXISTS (SELECT 1 FROM player_blocks b WHERE (b.blocker_id = u.id AND b.blocked_id = ' . $vid . ') OR (b.blocker_id = ' . $vid . ' AND b.blocked_id = u.id))';
    $rows = q('SELECT u.id, u.garden_public, u.pulse_show, COALESCE(u.gnome_name, u.username) AS name FROM users u WHERE u.last_seen > ? AND u.onboarded = 1 AND u.deleted_at IS NULL AND u.id <> ? AND '
        . gnome_in_play_sql('u') . ' AND ' . $notBlocked . ' ORDER BY u.last_seen DESC LIMIT 40', [$cut, $vid])->fetchAll();
    $names = [];
    $quiet = 0;
    foreach ($rows as $r) {
        if ((int)$r['garden_public'] === 1 && (int)$r['pulse_show'] === 1 && count($names) < 5) $names[] = [(int)$r['id'], (string)$r['name']];
        else $quiet++;
    }
    $since = gmdate('Y-m-d H:i:s', time() - 3 * 86400);
    $news = [];
    $open = 'u.garden_public = 1 AND u.pulse_show = 1 AND u.deleted_at IS NULL AND ' . gnome_in_play_sql('u') . ' AND ' . $notBlocked;
    // v1.0.0: one UNION query instead of seven (each branch is a limited derived table, which MySQL and SQLite both accept)
    $nm = 'COALESCE(u.gnome_name, u.username)';
    $branches = [
        ["SELECT 'show' AS k, $nm AS name, e.entered_at AS ts, '' AS extra FROM show_entries e JOIN users u ON u.id = e.user_id WHERE e.entered_at > ? AND $open ORDER BY e.entered_at DESC LIMIT 4", '🏅'],
        ["SELECT 'fair' AS k, $nm AS name, e.at AS ts, '' AS extra FROM fair_entries e JOIN users u ON u.id = e.user_id WHERE e.at > ? AND $open ORDER BY e.at DESC LIMIT 4", '🏆'],
        ["SELECT 'gotm' AS k, $nm AS name, e.entered_at AS ts, '' AS extra FROM gotm_entries e JOIN users u ON u.id = e.user_id WHERE e.entered_at > ? AND $open ORDER BY e.entered_at DESC LIMIT 3", '🌼'],
        ["SELECT 'arr' AS k, $nm AS name, e.entered_at AS ts, '' AS extra FROM arrangement_entries e JOIN users u ON u.id = e.user_id WHERE e.entered_at > ? AND $open ORDER BY e.entered_at DESC LIMIT 3", '💐'],
        ["SELECT 'mile' AS k, $nm AS name, um.achieved_at AS ts, m.name AS extra FROM user_milestones um JOIN users u ON u.id = um.user_id JOIN almanac_milestones m ON m.id = um.milestone_id WHERE um.achieved_at > ? AND $open ORDER BY um.achieved_at DESC LIMIT 4", '📜'],
        ["SELECT 'new' AS k, $nm AS name, u.created_at AS ts, '' AS extra FROM users u WHERE u.created_at > ? AND u.onboarded = 1 AND u.gnome_name IS NOT NULL AND $open ORDER BY u.created_at DESC LIMIT 3", '👋'],
        ["SELECT 'stamp' AS k, $nm AS name, s.stamped_at AS ts, COALESCE(p.garden_name, '') AS extra FROM garden_stamps s JOIN plots p ON p.id = s.plot_id JOIN users u ON u.id = p.user_id WHERE s.stamped_at > ? AND $open ORDER BY s.stamped_at DESC LIMIT 3", '🌸'],
    ];
    $icons = ['show' => '🏅', 'fair' => '🏆', 'gotm' => '🌼', 'arr' => '💐', 'mile' => '📜', 'new' => '👋', 'stamp' => '🌸'];
    $sql = implode(' UNION ALL ', array_map(fn($i) => 'SELECT * FROM (' . $branches[$i][0] . ') b' . $i, array_keys($branches)));
    foreach (q($sql, array_fill(0, count($branches), $since))->fetchAll() as $r) {
        $text = match ($r['k']) {
            'show' => $r['name'] . ' entered the Village Show.',
            'fair' => $r['name'] . ' entered the Grand Harvest Fair.',
            'gotm' => $r['name'] . ' entered a garden for Garden of the Month.',
            'arr' => $r['name'] . ' put an arrangement in the show.',
            'mile' => $r['name'] . ' earned the milestone “' . $r['extra'] . '”.',
            'new' => 'A new gnome arrived: ' . $r['name'] . '. Say hello!',
            default => 'Someone signed the guestbook at ' . ($r['extra'] !== '' ? $r['extra'] : $r['name'] . '’s garden') . '.',
        };
        $news[] = [$icons[$r['k']] ?? '🌼', $text, (string)$r['ts']];
    }
    usort($news, fn($a, $b) => strcmp($b[2], $a[2]));
    $news = array_slice($news, 0, 6);
    // townsfolk: a few who are out and about right now (where they are is public anyway: their Folk page says so)
    $folk = [];
    if (townsfolk_enabled_for_goals()) {
        require_once __DIR__ . '/npc_life.php';
        require_once __DIR__ . '/townsfolk.php';
        foreach (townsfolk_picks('pulse|' . hollow_date('Y-m-d H'), 3) as $p) {
            $np = q_one('SELECT * FROM npcs WHERE id = ?', [$p['id']]);
            if (!$np) continue;
            $now = npc_now($np);
            $folk[] = $np['name'] . ' is ' . ($now['what'] ?? 'about') . '.';
        }
    }
    return ['about' => ['n' => count($rows), 'names' => $names, 'quiet' => $quiet], 'folk' => $folk, 'news' => $news];
}

/** The strip: HTML for the Today page and the Hollow page. */
function hollow_pulse_html(array $viewer, bool $compact = false): string
{
    $p = hollow_pulse($viewer);
    $a = $p['about'];
    $who = [];
    // v1.2.0: at most 3 names on a phone-width line, the rest as "N more"
    $shown = array_slice($a['names'], 0, 3);
    foreach ($shown as [$id, $name]) $who[] = '<a href="' . e(url('profile.php?id=' . $id)) . '">' . e($name) . '</a>';
    $more = (count($a['names']) - count($shown)) + $a['quiet'];
    if (count($a['names']) > 3) { if ($more > 0) $who[] = $more . ' more'; }
    elseif ($a['quiet'] > 0) $who[] = $a['quiet'] . ' quiet gnome' . ($a['quiet'] === 1 ? '' : 's');
    $h = '<div class="pulse"><p class="pulseabout"><span class="pdot" aria-hidden="true"></span><span class="pulsetxt">';
    $h .= $a['n'] > 0 ? '<b>About now:</b> ' . implode(', ', $who) . ' and you.' : '<b>Just you about right now.</b> The townsfolk keep you company.';
    $h .= '</span></p>';
    $items = [];
    foreach ($p['news'] as [$ic, $tx, $utc]) $items[] = '<li><span>' . $ic . '</span> ' . e($tx) . ' <small class="muted">' . e(pulse_ago($utc)) . '</small></li>';
    foreach ($p['folk'] as $f) $items[] = '<li class="tfl">🏡 ' . e($f) . '</li>';
    if ($compact) $items = array_slice($items, 0, 4);
    if ($items) $h .= '<ul class="pulselist">' . implode('', $items) . '</ul>';
    return $h . '</div>';
}
