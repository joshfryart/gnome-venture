<?php
declare(strict_types=1);
/**
 * 2.6.27: admin-only tracking. (1) the last ACTION_LOG_KEEP actions of each player (every POST they make),
 * (2) where each player is on the game clock (admin/gameclock.php). Nothing here is shown to players.
 * Never stored: passwords, tokens, emails, message text. Only short values of non-secret fields.
 */
const ACTION_LOG_KEEP = 100;

function action_log_schema(string $PK, string $ID, string $END): array
{
    return [[
        "CREATE TABLE IF NOT EXISTS player_actions (
            id $PK,
            user_id $ID NOT NULL,
            at DATETIME NOT NULL,
            page VARCHAR(64) NOT NULL,
            what VARCHAR(255) NOT NULL,
            game_day INT NULL,
            game_minute INT NULL
        )$END",
        "CREATE TABLE IF NOT EXISTS trail_pickups (
            id $PK,
            user_id $ID NOT NULL,
            route_id INT NOT NULL,
            sec INT NOT NULL,
            n INT NOT NULL DEFAULT 1,
            got_at INT NOT NULL,
            got_tick INT NULL
        )$END",
        "CREATE TABLE IF NOT EXISTS trail_sight_rows (
            id $PK,
            slug VARCHAR(80) NOT NULL,
            verb VARCHAR(40) NOT NULL,
            icon VARCHAR(16) NOT NULL,
            energy INT NOT NULL DEFAULT 1,
            cd INT NOT NULL DEFAULT 55,
            uses INT NOT NULL DEFAULT 1,
            cond VARCHAR(80) NOT NULL DEFAULT '-',
            chk VARCHAR(40) NOT NULL DEFAULT '-',
            rewards TEXT NULL,
            win TEXT NULL,
            lose TEXT NULL,
            tool VARCHAR(20) NOT NULL DEFAULT '-',
            fail_en INT NOT NULL DEFAULT 0,
            active INT NOT NULL DEFAULT 1,
            updated_at DATETIME NULL
        )$END",
        "CREATE TABLE IF NOT EXISTS trail_sight_tally (
            id $PK,
            user_id $ID NOT NULL,
            tkey VARCHAR(40) NOT NULL,
            n INT NOT NULL DEFAULT 0
        )$END",
        "CREATE TABLE IF NOT EXISTS user_sight_titles (
            id $PK,
            user_id $ID NOT NULL,
            title VARCHAR(60) NOT NULL
        )$END",
        "CREATE TABLE IF NOT EXISTS user_sight_quests (
            id $PK,
            user_id $ID NOT NULL,
            quest VARCHAR(60) NOT NULL,
            beats TEXT NOT NULL,
            started_at DATETIME NOT NULL,
            done_at DATETIME NULL
        )$END",
        "CREATE TABLE IF NOT EXISTS trail_sight_first (
            id $PK,
            user_id $ID NOT NULL,
            slug VARCHAR(80) NOT NULL
        )$END",
        "CREATE TABLE IF NOT EXISTS trail_sight_uses (
            id $PK,
            user_id $ID NOT NULL,
            route_id INT NOT NULL,
            sec INT NOT NULL,
            slug VARCHAR(80) NOT NULL,
            n INT NOT NULL DEFAULT 1,
            got_at INT NOT NULL,
            got_tick INT NULL
        )$END",
    ], ['CREATE INDEX idx_player_actions_user ON player_actions (user_id, id)', 'CREATE INDEX idx_trail_pickups_user ON trail_pickups (user_id, route_id, sec)', 'CREATE INDEX idx_trail_sight_uses_user ON trail_sight_uses (user_id, route_id, sec)', 'CREATE UNIQUE INDEX idx_trail_sight_rows_slug ON trail_sight_rows (slug)', 'CREATE UNIQUE INDEX idx_trail_sight_first ON trail_sight_first (user_id, slug)', 'CREATE UNIQUE INDEX idx_user_sight_quests ON user_sight_quests (user_id, quest)', 'CREATE UNIQUE INDEX idx_user_sight_titles ON user_sight_titles (user_id, title)', 'CREATE UNIQUE INDEX idx_trail_sight_tally ON trail_sight_tally (user_id, tkey)'], []];
}

/** Pages whose posts are never logged (credentials, account, private text). */
function action_log_skip_page(string $page): bool
{
    return in_array($page, ['login.php', 'register.php', 'forgot.php', 'reset.php', 'account.php', 'install.php', 'logout.php', 'letters.php', 'feedback.php', 'report.php'], true);
}

/** Short, safe description of the POST: key=value for non-secret fields. */
function action_log_describe(array $post): string
{
    $bits = [];
    foreach ($post as $k => $v) {
        $k = (string)$k;
        if (preg_match('/pass|csrf|token|secret|mail|msg|message|body|text|note|comment|reason|name|code|key/i', $k)) continue;
        if (is_array($v)) { $bits[] = $k . '=[' . count($v) . ']'; continue; }
        $bits[] = $k . '=' . mb_substr(preg_replace('/\s+/', ' ', (string)$v), 0, 40);
        if (count($bits) >= 8) break;
    }
    return mb_substr(implode(' ', $bits), 0, 250);
}

/** Call once per request after the user is loaded: logs the POST when the request ends (so the game clock shown is the one after the action). */
function action_log_boot(): void
{
    $u = current_user();
    if (!$u || !is_post() || !empty($u['guest'])) return;
    $page = basename((string)($_SERVER['SCRIPT_NAME'] ?? ''));
    $dir = basename(dirname((string)($_SERVER['SCRIPT_NAME'] ?? '')));
    if ($dir === 'admin' || action_log_skip_page($page)) return;
    $uid = (int)$u['id'];
    $what = action_log_describe($_POST);
    register_shutdown_function(function () use ($uid, $page, $what) {
        try {
            $c = q('SELECT game_day, game_minute FROM users WHERE id = ?', [$uid])->fetch() ?: [];
            db_insert('player_actions', [
                'user_id' => $uid, 'at' => now(), 'page' => mb_substr($page, 0, 64), 'what' => $what,
                'game_day' => isset($c['game_day']) ? (int)$c['game_day'] : null,
                'game_minute' => isset($c['game_minute']) ? (int)$c['game_minute'] : null,
            ]);
            $cut = q_val('SELECT id FROM player_actions WHERE user_id = ? ORDER BY id DESC LIMIT 1 OFFSET ' . (ACTION_LOG_KEEP - 1), [$uid]);
            if ($cut) q('DELETE FROM player_actions WHERE user_id = ? AND id < ?', [$uid, (int)$cut]);
        } catch (Throwable $e) {
            // never break a page over the log (the table may not exist before "Upgrade database")
        }
    });
}

function action_log_hhmm(int $minute): string
{
    return sprintf('%02d:%02d', intdiv($minute, 60) % 24, $minute % 60);
}
