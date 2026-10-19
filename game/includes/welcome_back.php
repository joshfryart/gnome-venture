<?php
declare(strict_types=1);

/**
 * v1.0.0 wave 3: coming back.
 * - Welcome back: after welcome_back_days away (remembered in users.away_from by social_note_return) the gnome gets a summary page
 *   (back.php): what grew, pots and jars that are ready, what they missed, how the Hollow's jar is doing, what is new. A small basket
 *   comes with it; it never shrinks with time away and nothing is "lost" by being away.
 * - The gentle daily card on Today: one small suggestion for the day, a tick to say it is done, and a closing line. No streaks, no timers, no FOMO.
 */

function welcome_back_due(?array $u): bool
{
    return $u && !empty($u['away_from']) && (int)($u['onboarded'] ?? 1) === 1;   // v1.7.0: being away already means the first session is over
}

/** Everything the summary page shows. */
function welcome_back_summary(array $u): array
{
    require_once __DIR__ . '/garden_logic.php';
    require_once __DIR__ . '/hollow_goals.php';
    $uid = (int)$u['id'];
    $since = (string)$u['away_from'];
    $away = max(1, (int)floor((time() - (int)strtotime($since . ' UTC')) / 86400));
    [$plot, $tiles, $plants] = load_plot($uid, true);
    $ready = $thirsty = $growing = 0;
    $crops = [];
    foreach ($tiles as $row) foreach ($row as $t) {
        if ($t['plant_id'] && isset($plants[(int)$t['plant_id']])) {
            $ti = tile_info($t, $plants[(int)$t['plant_id']]);
            if ($ti['ready']) { $ready++; $crops[$plants[(int)$t['plant_id']]['name']] = ($crops[$plants[(int)$t['plant_id']]['name']] ?? 0) + 1; }
            elseif ($ti['thirsty']) $thirsty++;
            else $growing++;
        }
    }
    arsort($crops);
    $now = now();
    $potsReady = (int)q_val('SELECT COUNT(*) FROM cook_pots WHERE user_id = ? AND collected_at IS NULL AND ready_at <= ?', [$uid, $now]);
    $jarsReady = (int)q_val('SELECT COUNT(*) FROM pantry_jars WHERE user_id = ? AND collected_at IS NULL AND ready_at <= ?', [$uid, $now]);
    $racksReady = (int)q_val('SELECT COUNT(*) FROM dry_racks WHERE user_id = ? AND collected_at IS NULL AND ready_at <= ?', [$uid, $now]);
    $notices = q('SELECT text, created_at FROM notices WHERE user_id = ? AND created_at > ? ORDER BY id DESC LIMIT 8', [$uid, $since])->fetchAll();
    $noticeN = (int)q_val('SELECT COUNT(*) FROM notices WHERE user_id = ? AND created_at > ?', [$uid, $since]);
    $goal = null;
    if (hollow_goals_on() && ($ag = hollow_goals_active())) {
        $g = $ag[0];
        $goal = ['goal' => $g, 'state' => hollow_goal_state($g), 'mine' => hollow_goal_share((int)$g['id'], $uid)];
    }
    $news = q('SELECT title, created_at FROM news WHERE published = 1 AND created_at > ? ORDER BY created_at DESC, id DESC LIMIT 4', [$since])->fetchAll();
    $newGnomes = (int)q_val('SELECT COUNT(*) FROM users u WHERE u.created_at > ? AND u.onboarded = 1 AND u.deleted_at IS NULL AND ' . gnome_in_play_sql('u'), [$since]);
    require_once __DIR__ . '/pals.php';
    return ['away' => $away, 'since' => $since, 'plot' => $plot, 'ready' => $ready, 'thirsty' => $thirsty, 'growing' => $growing, 'crops' => array_slice($crops, 0, 4, true),
        'pots' => $potsReady, 'jars' => $jarsReady, 'racks' => $racksReady, 'notices' => $notices, 'noticeN' => $noticeN, 'goal' => $goal, 'news' => $news,
        'requests' => count(pal_requests_in($uid)), 'newGnomes' => $newGnomes, 'basket' => (int)setting('welcome_back_coins')];
}

/** Open the basket (or just close the page): clears the note. The basket is paid once per absence. */
function welcome_back_open(array $u, bool $basket): array
{
    $uid = (int)$u['id'];
    if (q('UPDATE users SET away_from = NULL WHERE id = ? AND away_from IS NOT NULL', [$uid])->rowCount() !== 1) return [false, 'You already did that.'];
    $coins = (int)setting('welcome_back_coins');
    if ($basket && $coins > 0) {
        q('UPDATE users SET coins = coins + ? WHERE id = ?', [$coins, $uid]);
        return [true, '🧺 A welcome-back basket: ' . money($coins) . '. The garden kept well while you were away.'];
    }
    return [true, 'Welcome back!'];
}

// ---------------- The gentle daily card ----------------

const DAILY_CLOSERS = [
    'Tucked in. The Hollow will be here tomorrow.', 'Lovely. Put your feet up for the day.', 'That’s plenty. The plants are doing the rest.',
    'Done for today. A cup of something warm is in order.', 'Well tended. See you whenever you like.',
];

/** The day's one suggestion for this gnome: [icon, text, link, label], and whether it is ticked. */
function daily_card(array $u): ?array
{
    if (setting('daily_card_on') !== '1' || (int)($u['onboarded'] ?? 1) !== 1 || ((int)($u['tour_step'] ?? 0) > 0 && empty($u['away_from']))) return null;   // quiet during Wren's first-session tour
    $uid = (int)$u['id'];
    $day = hollow_date('Y-m-d');
    $done = (bool)q_val('SELECT 1 FROM daily_ticks WHERE user_id = ? AND day = ?', [$uid, $day]);
    if ($done) {   // v1.0.0: ticked already: only the closing line is shown, so none of the option checks below are needed
        return ['key' => '', 'icon' => '', 'text' => '', 'link' => '', 'label' => '', 'done' => true, 'closer' => DAILY_CLOSERS[crc32($uid . '|closer|' . $day) % count(DAILY_CLOSERS)]];
    }
    $opts = [];   // each option: [key, icon, text, link, label]
    $now = now();
    if (q_val('SELECT 1 FROM cook_pots WHERE user_id = ? AND collected_at IS NULL AND ready_at <= ?', [$uid, $now])) {
        $opts[] = ['pot', '🍲', 'A pot on your stove is ready. Collect it while it’s warm.', 'inventory.php?tab=craft&c=cooking', 'To the kitchen'];
    }
    if (q_val('SELECT 1 FROM pantry_jars WHERE user_id = ? AND collected_at IS NULL AND ready_at <= ?', [$uid, $now])) {
        $opts[] = ['jar', '🫙', 'A jar in your Pantry has finished. Take a look.', 'inventory.php?tab=craft&c=pantry', 'To the Pantry'];
    }
    if (q_val("SELECT 1 FROM player_friends WHERE friend_id = ? AND status = 'pending' LIMIT 1", [$uid])) {
        $opts[] = ['req', '🤝', 'A gnome would like to be your friend.', 'pals.php?tab=requests', 'See who'];
    }
    if (hollow_goals_on()) {
        require_once __DIR__ . '/hollow_goals.php';
        $ag = hollow_goals_active();
        if ($ag && !hollow_goal_share((int)$ag[0]['id'], $uid)) $opts[] = ['jar2', $ag[0]['icon'], 'The Hollow’s jar this week: ' . $ag[0]['title'] . '. Whatever you do anyway counts.', 'community.php?t=jar', 'See the jar'];
    }
    if (!q_val("SELECT 1 FROM user_jobs WHERE user_id = ? AND period = 'daily' AND status = 'active' LIMIT 1", [$uid])) {
        $opts[] = ['job', '📋', 'There’s no daily job on your list. Pick a small one.', 'jobs.php', 'Job Board'];
    }
    if (!q_val('SELECT 1 FROM npc_friends WHERE user_id = ? AND last_talk = ? LIMIT 1', [$uid, $day])) {
        $opts[] = ['talk', '💬', 'Say hello to one of the townsfolk. A chat a day makes friends.', 'folk.php', 'Villagers'];
    }
    $opts[] = ['stamp', '🌸', 'Visit a garden and sign its guestbook.', 'gotm.php', 'Wander the lanes'];
    $opts[] = ['walk', '🥾', 'Take a short walk to a stop you haven’t been to.', 'world.php', 'Out and about'];
    if (function_exists('festival_active') && ($f = festival_active())) {
        $opts[] = ['fest', $f['icon'], $f['name'] . ' is on. Take a look at the stalls.', 'festival.php', 'Festival'];
    }
    $pick = $opts[crc32($uid . '|daily|' . $day) % count($opts)];
    return ['key' => $pick[0], 'icon' => $pick[1], 'text' => $pick[2], 'link' => $pick[3], 'label' => $pick[4], 'done' => $done,
        'closer' => DAILY_CLOSERS[crc32($uid . '|closer|' . $day) % count(DAILY_CLOSERS)]];
}

function daily_tick(array $u): array
{
    try {
        db_insert('daily_ticks', ['user_id' => (int)$u['id'], 'day' => hollow_date('Y-m-d')]);
    } catch (PDOException $e) {
        return [false, ''];
    }
    return [true, ''];
}
