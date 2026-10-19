<?php
declare(strict_types=1);

/**
 * v1.0.0 wave 3, "players together and coming back": the shared plumbing.
 * Settings, tables and the one-off upgrade live here; the features are in
 *   townsfolk.php     NPC entries on every contest board
 *   hollow_goals.php  weekly shared jar, Hollow Pulse
 *   pals.php          player friends, blocks, guestbook (gate stamps), seedling gifts
 *   first_week.php    Wren's First Week
 *   welcome_back.php  welcome back + the gentle daily card
 *   festival.php      seasonal festival framework (Opening Day is the first)
 * Nothing here is loaded until a page needs it, except this file (settings, schema).
 */

/** The festivals the game knows about: slug => [name, icon, blurb, default length in days]. Dates are settings: fest_<slug>_start / fest_<slug>_end. */
const SOCIAL_FESTIVAL_SLUGS = ['opening_day'];

function social100_settings(): array
{
    $s = [
        'townsfolk_entries'  => ['label' => 'Townsfolk: NPCs enter the Show, Fair, Garden of the Month, Arrangements show, Snail Race and Carving (marked 🏡; they never take a prize from a gnome)', 'type' => 'bool', 'default' => '1'],
        'goals_on'           => ['label' => 'Hollow Goals: a shared jar everyone fills each week', 'type' => 'bool', 'default' => '1'],
        'goal_per_gnome'     => ['label' => 'Hollow Goals: fewest gnomes the jar is sized for (small worlds still get a reachable jar)', 'type' => 'int', 'default' => '4', 'min' => 1, 'max' => 1000],
        'goal_townsfolk_pct' => ['label' => 'Hollow Goals: % of the jar the townsfolk fill by the end of the week (so it never stalls)', 'type' => 'int', 'default' => '20', 'min' => 0, 'max' => 60],
        'goal_tier_coins'    => ['label' => 'Hollow Goals: Petals for each tier (25%, 50%, 75%, 100%), comma separated', 'type' => 'text', 'default' => '100,200,300,500'],
        'goal_min_share'     => ['label' => 'Hollow Goals: smallest contribution that counts as helping (so every helper is rewarded)', 'type' => 'int', 'default' => '1', 'min' => 1, 'max' => 1000],
        'friends_max'        => ['label' => 'Gnome friends: most friends one gnome can have', 'type' => 'int', 'default' => '40', 'min' => 1, 'max' => 1000],
        'friends_pending_max' => ['label' => 'Gnome friends: most open friend requests one gnome can have waiting', 'type' => 'int', 'default' => '15', 'min' => 1, 'max' => 200],
        'friend_gifts_on'    => ['label' => 'Gnome friends: friends may send each other a seed or seedling once a day', 'type' => 'bool', 'default' => '1'],
        'first_week_on'      => ['label' => 'Wren’s First Week: a seven-day checklist after the tour', 'type' => 'bool', 'default' => '1'],
        'welcome_back_days'  => ['label' => 'Welcome back: show the summary page after this many days away', 'type' => 'int', 'default' => '3', 'min' => 1, 'max' => 365],
        'welcome_back_coins' => ['label' => 'Welcome back: Petals in the welcome-back basket (never shrinks with time away)', 'type' => 'int', 'default' => '50', 'min' => 0, 'max' => 100000],
        'daily_card_on'      => ['label' => 'Today page: the gentle daily card (one small suggestion, no streaks)', 'type' => 'bool', 'default' => '1'],
        'festivals_on'       => ['label' => 'Festivals: seasonal festivals are switched on', 'type' => 'bool', 'default' => '1'],
    ];
    foreach (SOCIAL_FESTIVAL_SLUGS as $slug) {
        $nm = ucwords(str_replace('_', ' ', $slug));
        $s['fest_' . $slug . '_start'] = ['label' => "Festival “{$nm}”: first day (YYYY-MM-DD, Hollow date; empty = not scheduled)", 'type' => 'text', 'default' => ''];
        $s['fest_' . $slug . '_end'] = ['label' => "Festival “{$nm}”: last day (YYYY-MM-DD)", 'type' => 'text', 'default' => ''];
    }
    return $s;
}

/** [tables, indexes, columns] for schema_statements(). */
function social100_schema(string $PK, string $ID, string $END): array
{
    $t = [];
    $t[] = "CREATE TABLE IF NOT EXISTS hollow_goals (
        id $PK,
        period_key VARCHAR(40) NOT NULL UNIQUE,
        kind VARCHAR(20) NOT NULL,
        filter VARCHAR(60) NOT NULL DEFAULT '',
        title VARCHAR(120) NOT NULL,
        icon VARCHAR(12) NOT NULL DEFAULT '🫙',
        target INT NOT NULL DEFAULT 100,
        progress INT NOT NULL DEFAULT 0,
        festival VARCHAR(40) NULL,
        starts_at DATETIME NOT NULL,
        ends_at DATETIME NOT NULL,
        created_at DATETIME NOT NULL
    )$END";
    $t[] = "CREATE TABLE IF NOT EXISTS hollow_goal_contrib (
        goal_id $ID NOT NULL,
        user_id $ID NOT NULL,
        amount INT NOT NULL DEFAULT 0,
        PRIMARY KEY (goal_id, user_id)
    )$END";
    $t[] = "CREATE TABLE IF NOT EXISTS hollow_goal_claims (
        goal_id $ID NOT NULL,
        user_id $ID NOT NULL,
        tier INT NOT NULL,
        claimed_at DATETIME NOT NULL,
        PRIMARY KEY (goal_id, user_id, tier)
    )$END";
    $t[] = "CREATE TABLE IF NOT EXISTS player_friends (
        id $PK,
        user_id $ID NOT NULL,
        friend_id $ID NOT NULL,
        status VARCHAR(10) NOT NULL DEFAULT 'pending',
        created_at DATETIME NOT NULL,
        answered_at DATETIME NULL,
        UNIQUE (user_id, friend_id)
    )$END";
    $t[] = "CREATE TABLE IF NOT EXISTS player_blocks (
        blocker_id $ID NOT NULL,
        blocked_id $ID NOT NULL,
        created_at DATETIME NOT NULL,
        PRIMARY KEY (blocker_id, blocked_id)
    )$END";
    $t[] = "CREATE TABLE IF NOT EXISTS garden_stamps (
        id $PK,
        plot_id $ID NOT NULL,
        user_id $ID NOT NULL,
        day VARCHAR(10) NOT NULL,
        stamp VARCHAR(20) NOT NULL,
        stamped_at DATETIME NOT NULL,
        UNIQUE (plot_id, user_id, day)
    )$END";
    $t[] = "CREATE TABLE IF NOT EXISTS pal_gift_days (
        from_id $ID NOT NULL,
        to_id $ID NOT NULL,
        day VARCHAR(10) NOT NULL,
        PRIMARY KEY (from_id, to_id, day)
    )$END";   // v1.0.0: the once-a-day-per-friend seedling gift is claimed here first, so two tabs/devices can't both send
    $t[] = "CREATE TABLE IF NOT EXISTS first_week_claims (
        user_id $ID NOT NULL,
        day INT NOT NULL,
        claimed_at DATETIME NOT NULL,
        PRIMARY KEY (user_id, day)
    )$END";
    $t[] = "CREATE TABLE IF NOT EXISTS daily_ticks (
        user_id $ID NOT NULL,
        day VARCHAR(10) NOT NULL,
        PRIMARY KEY (user_id, day)
    )$END";
    $t[] = "CREATE TABLE IF NOT EXISTS festival_flags (
        festival VARCHAR(40) NOT NULL,
        user_id $ID NOT NULL,
        day VARCHAR(10) NOT NULL,
        at DATETIME NOT NULL,
        PRIMARY KEY (festival, user_id, day)
    )$END";
    $t[] = "CREATE TABLE IF NOT EXISTS festival_buys (
        festival VARCHAR(40) NOT NULL,
        user_id $ID NOT NULL,
        stall VARCHAR(40) NOT NULL,
        qty INT NOT NULL DEFAULT 0,
        PRIMARY KEY (festival, user_id, stall)
    )$END";
    $t[] = "CREATE TABLE IF NOT EXISTS festival_claims (
        festival VARCHAR(40) NOT NULL,
        user_id $ID NOT NULL,
        reward VARCHAR(30) NOT NULL,
        at DATETIME NOT NULL,
        PRIMARY KEY (festival, user_id, reward)
    )$END";
    $i = [
        'CREATE INDEX idx_pfriends_friend ON player_friends (friend_id, status)',
        'CREATE INDEX idx_pfriends_user ON player_friends (user_id, status)',
        'CREATE INDEX idx_stamps_plot ON garden_stamps (plot_id, stamped_at)',
        'CREATE INDEX idx_stamps_user ON garden_stamps (user_id)',
        'CREATE INDEX idx_hgoals_ends ON hollow_goals (ends_at)',
        'CREATE INDEX idx_hgc_user ON hollow_goal_contrib (user_id)',
    ];
    $c = [
        ['users', 'fw_start', 'VARCHAR(10) NULL'],      // v1.0.0: the Hollow date Wren's First Week began
        ['users', 'pulse_show', 'INT NOT NULL DEFAULT 1'],  // v1.0.0: 1 = may be named in the Hollow Pulse "About now" line (still needs an open garden)
        ['users', 'away_from', 'DATETIME NULL'],        // v1.0.0: when the gnome was last seen before a long absence (cleared by the welcome-back page)
    ];
    return [$t, $i, $c];
}

/** Hollow date (Y-m-d) of a UTC 'Y-m-d H:i:s' string. */
function social_hollow_day(?string $utc): string
{
    return $utc ? hollow_date('Y-m-d', (int)strtotime($utc . ' UTC')) : '';
}

/** A gnome's name for other gnomes, or null if they are gone or in a time-out. */
function social_name(int $uid): ?string
{
    $r = q_one('SELECT id, username, gnome_name FROM users WHERE id = ? AND deleted_at IS NULL AND ' . gnome_in_play_sql('users'), [$uid]);
    return $r ? (string)($r['gnome_name'] ?: $r['username']) : null;
}

/**
 * Called when a gnome logs in or loads a page, with the row as it was BEFORE last_seen is bumped.
 * If they have been away long enough, remember when they were last here so the welcome-back page can say what happened since.
 */
function social_note_return(array $u): void
{
    if (empty($u['last_seen']) || !empty($u['away_from']) || (int)($u['onboarded'] ?? 1) !== 1) return;
    $days = max(1, (int)setting('welcome_back_days'));
    if (strtotime($u['last_seen'] . ' UTC') < time() - $days * 86400) {
        q('UPDATE users SET away_from = ? WHERE id = ? AND away_from IS NULL', [$u['last_seen'], $u['id']]);
    }
}

/** Remove a gnome's social rows (used by Admin → Fresh start). Call inside the caller's transaction. */
function social_fresh_start(int $uid): void
{
    foreach (['first_week_claims', 'daily_ticks', 'hollow_goal_contrib', 'hollow_goal_claims', 'festival_flags', 'festival_buys', 'festival_claims', 'garden_stamps'] as $t) {
        q("DELETE FROM $t WHERE user_id = ?", [$uid]);
    }
    q('DELETE FROM garden_stamps WHERE plot_id IN (SELECT id FROM plots WHERE user_id = ?)', [$uid]);
    foreach (['DELETE FROM garden_waterings WHERE helper_id = ? OR plot_id IN (SELECT id FROM plots WHERE user_id = ?)',   // v1.6.9
              'DELETE FROM garden_reacts WHERE user_id = ? OR plot_id IN (SELECT id FROM plots WHERE user_id = ?)'] as $sql) q($sql, [$uid, $uid]);
    q('DELETE FROM player_friends WHERE user_id = ? OR friend_id = ?', [$uid, $uid]);
    q('DELETE FROM player_blocks WHERE blocker_id = ? OR blocked_id = ?', [$uid, $uid]);
    q('DELETE FROM pal_gift_days WHERE from_id = ? OR to_id = ?', [$uid, $uid]);
}

/**
 * The one-off 1.0.0 upgrade (also run for fresh installs): Almanac pages for the new things, the Opening Day dates
 * (the week the upgrade is applied, unless an admin already set them), the festival decoration item.
 * Idempotent; guarded by the social100 setting.
 */
function upgrade_100_social(): void
{
    if (setting('social100') === '1') return;
    require_once __DIR__ . '/festival.php';
    festival_ensure_items();
    foreach (SOCIAL_FESTIVAL_SLUGS as $slug) {
        if (trim(setting('fest_' . $slug . '_start')) === '') {
            $start = hollow_date('Y-m-d');
            set_setting('fest_' . $slug . '_start', $start);
            set_setting('fest_' . $slug . '_end', gmdate('Y-m-d', strtotime($start . ' UTC') + 6 * 86400));
        }
    }
    $pages = [
        ['Hollow Goals and the Pulse', 'Every week the whole Hollow fills one jar together: harvest carrots, cook meals, walk to new stops. Whatever you already do counts, '
            . "and the townsfolk add a little too, so it never stalls. Reach a tier (a quarter, half, three quarters, full) and [b]everyone who helped[/b] gets a reward.\n\n"
            . 'The [b]Pulse[/b] on the Hollow page shows who is about and what has been happening: only public things, never anything from a private garden.', 3],
        ['Gnome friends and the guestbook', "Send a friend request from a gnome's profile. Once they accept you can see each other's gardens first, and send a seed or seedling once a day. "
            . "Sign the [b]guestbook[/b] of any open garden (one a day) to say you were there.\n\nYou can [b]block[/b] a gnome from their profile: they can't send you requests, guestbook signs or gifts, and you're removed from each other's lists.", 4],
        ['Wren’s First Week', "After Wren's tour you get seven small cards, one a day. Do them in any order, any time: they never run out, and nothing is lost if you skip a day. "
            . 'Each card pays a small reward, and the last one gives you a keepsake.', 5],
        ['Festivals', "A few times a year the Hollow throws a festival: a page with its dates, a shared goal, stalls run by the townsfolk and a few things you can only get then. "
            . "[b]Opening Day[/b] is the first. Cosmetics come back next time, so there's nothing to miss.", 6],
    ];
    foreach ($pages as [$title, $body, $sort]) {
        if (q_val("SELECT 1 FROM encyclopedia_entries WHERE chapter = 'General' AND title = ?", [$title])) continue;
        $eid = db_insert('encyclopedia_entries', ['chapter' => 'General', 'category' => 'Getting started', 'title' => $title, 'body' => $body,
            'unlock_key' => 'start', 'hint' => '', 'sort_order' => $sort + 10]);
        foreach (q("SELECT DISTINCT ue.user_id FROM user_encyclopedia ue JOIN encyclopedia_entries e ON e.id = ue.entry_id WHERE e.unlock_key = 'start'")->fetchAll(PDO::FETCH_COLUMN) as $uid) {
            try { db_insert('user_encyclopedia', ['user_id' => $uid, 'entry_id' => $eid, 'unlocked_at' => now()]); } catch (PDOException $e) { /* already there */ }
        }
    }
    set_setting('social100', '1');
    setting('__reload__');
}

/** For pages: make sure the 1.0.0 content exists even if db_version was set without the upgrade running (a dev copy). */
function social_boot(): void
{
    static $done = false;
    if ($done) return;
    $done = true;
    if (setting('social100') !== '1') {
        require_once __DIR__ . '/upgrade100.php';
        upgrade_100_run_step('social');
    }
}
