<?php
declare(strict_types=1);
/** v2.6.37: messages between a player and the people who run the game.
 *  A thread is one `feedback` row (the player's first note, or an empty body when an admin wrote first) plus its `feedback_replies`.
 *  feedback.status: 'new' = waiting for an admin, 'done' = dealt with. feedback.user_unread = 1: an admin reply the player has not opened. */

const MSG_MAX = 1000;   // letters in one message (the feedback note limit)

/** Make sure the tables are there (an update that has not had "Upgrade database" pressed yet). Safe to call on every page. */
function msg_boot(): void
{
    static $ok = false;
    if ($ok) return;
    try {
        q('SELECT user_unread, last_at FROM feedback LIMIT 1');
        q('SELECT id FROM feedback_replies LIMIT 1');
    } catch (Throwable $e) {
        global $CONFIG;
        db_migrate(db(), (string)$CONFIG['db']['driver']);
    }
    $ok = true;
}

/** Threads with an admin reply this player has not opened. 0 on any trouble: a badge is never worth a broken page. */
function msg_unread(int $uid): int
{
    static $memo = [];   // asked by the header button, the menu tile and the phone bar on one page: one query
    if (isset($memo[$uid]) && empty($GLOBALS['msg_unread_stale'])) return $memo[$uid];
    unset($GLOBALS['msg_unread_stale']);
    try { return $memo[$uid] = (int)q_val('SELECT COUNT(*) FROM feedback WHERE user_id = ? AND user_unread = 1', [$uid]); } catch (Throwable $e) { return $memo[$uid] = 0; }   // tables not upgraded yet
}

/** Threads waiting for an admin. */
function msg_admin_new(): int
{
    try { return (int)q_val("SELECT COUNT(*) FROM feedback WHERE status = 'new'"); } catch (Throwable $e) { return 0; }
}

/** The yellow "!" shown on the menu tile and the tab. */
function msg_bang(string $label = 'New message'): string
{
    return '<b class="bang" role="img" aria-label="' . e($label) . '">!</b>';
}

/** Clean one typed message; returns [text, error]. */
function msg_clean(string $raw): array
{
    $body = trim(str_replace("\r", '', $raw));
    if (mb_strlen($body) < 2) return ['', 'Write a little more so we know what you mean.'];
    if (mb_strlen($body) > MSG_MAX) return ['', 'Please keep it under ' . number_format(MSG_MAX) . ' letters.'];
    return [$body, ''];
}

/** Replies for a list of thread rows, grouped by thread id. */
function msg_replies(array $threadIds): array
{
    $out = [];
    if (!$threadIds) return $out;
    $in = implode(',', array_map('intval', $threadIds));
    foreach (q("SELECT r.*, COALESCE(u.gnome_name, u.username) AS gname FROM feedback_replies r LEFT JOIN users u ON u.id = r.user_id
                WHERE r.feedback_id IN ($in) ORDER BY r.id")->fetchAll() as $r) $out[(int)$r['feedback_id']][] = $r;
    return $out;
}

/** The player's own threads, newest activity first. */
function msg_threads_for(int $uid, int $limit = 30): array
{
    return q('SELECT * FROM feedback WHERE user_id = ? ORDER BY COALESCE(last_at, created_at) DESC, id DESC LIMIT ' . (int)$limit, [$uid])->fetchAll();
}

/** The player opened their messages: nothing is unread any more. */
function msg_mark_seen(int $uid): void
{
    q('UPDATE feedback SET user_unread = 0 WHERE user_id = ? AND user_unread = 1', [$uid]);
    $GLOBALS['msg_unread_stale'] = 1;   // the menu "!" goes at once
}

/** How many more replies the player may send today. */
function msg_replies_left(int $uid): int
{
    $n = (int)q_val('SELECT COUNT(*) FROM feedback_replies WHERE user_id = ? AND from_admin = 0 AND created_at >= ?', [$uid, gmdate('Y-m-d H:i:s', time() - 86400)]);
    return max(0, (int)setting('feedback_replies_per_day') - $n);
}

/** A player answers in one of their own threads. Returns [ok, message]. */
function msg_player_reply(array $u, int $threadId, string $raw): array
{
    $uid = (int)$u['id'];
    if (!q_val('SELECT 1 FROM feedback WHERE id = ? AND user_id = ?', [$threadId, $uid])) return [false, 'That message is not there any more.'];
    if (msg_replies_left($uid) <= 0) return [false, 'That’s all the replies for today. Thank you! You can send more tomorrow.'];
    [$body, $err] = msg_clean($raw);
    if ($err !== '') return [false, $err];
    db_insert('feedback_replies', ['feedback_id' => $threadId, 'user_id' => $uid, 'from_admin' => 0, 'body' => $body, 'created_at' => now()]);
    q("UPDATE feedback SET status = 'new', last_at = ? WHERE id = ?", [now(), $threadId]);
    return [true, '💬 Sent. Thank you!'];
}

/** An admin answers a thread: the player gets a "!" and a notice, the thread counts as dealt with. */
function msg_admin_reply(array $admin, int $threadId, string $raw): array
{
    $t = q_one('SELECT id, user_id FROM feedback WHERE id = ?', [$threadId]);
    if (!$t) return [false, 'That message is not there any more.'];
    [$body, $err] = msg_clean($raw);
    if ($err !== '') return [false, $err];
    db_insert('feedback_replies', ['feedback_id' => $threadId, 'user_id' => (int)$admin['id'], 'from_admin' => 1, 'body' => $body, 'created_at' => now()]);
    q("UPDATE feedback SET status = 'done', user_unread = 1, last_at = ? WHERE id = ?", [now(), $threadId]);
    $GLOBALS['msg_unread_stale'] = 1;
    msg_notify((int)$t['user_id']);
    return [true, '✅ Reply sent.'];
}

/** Tell the player in their message list that a reply is waiting. */
function msg_notify(int $uid): void
{
    try { require_once __DIR__ . '/trade.php'; notify($uid, '📬 You have a message from the game keeper. Read it in Together → Messages.'); } catch (Throwable $e) {}
}

/** An admin writes to a player first (no feedback note to answer). Returns [ok, message, thread id]. */
function msg_admin_start(array $admin, string $username, string $raw): array
{
    $to = q_one('SELECT id, guest FROM users WHERE username = ?', [trim($username)]);
    if (!$to) return [false, 'No player has that username.', 0];
    if ((int)($to['guest'] ?? 0) === 1) return [false, 'Guests cannot read messages (the Together page is closed to them).', 0];
    [$body, $err] = msg_clean($raw);
    if ($err !== '') return [false, $err, 0];
    $id = db_insert('feedback', ['user_id' => (int)$to['id'], 'page' => '', 'body' => '', 'status' => 'done', 'created_at' => now()]);
    db_insert('feedback_replies', ['feedback_id' => $id, 'user_id' => (int)$admin['id'], 'from_admin' => 1, 'body' => $body, 'created_at' => now()]);
    q('UPDATE feedback SET user_unread = 1, last_at = ? WHERE id = ?', [now(), $id]);
    $GLOBALS['msg_unread_stale'] = 1;
    msg_notify((int)$to['id']);
    return [true, '✅ Message sent.', $id];
}

/** One thread as HTML bubbles. $adminView: label the player by name; otherwise "You". */
function msg_thread_html(array $t, array $replies, bool $adminView, string $playerName = 'You'): string
{
    $who = fn(bool $fromAdmin) => $fromAdmin ? ($adminView ? 'You (the game)' : '🌱 The game keeper') : ($adminView ? $playerName : 'You');
    $bub = fn(bool $fromAdmin, string $when, string $body) => '<div class="msg ' . ($fromAdmin ? 'them' : 'me') . ($adminView ? ' av' : '') . '"><small class="muted">' . e($who($fromAdmin)) . ' · ' . e(gmdate('M j, H:i', (int)strtotime($when . ' UTC'))) . ' UTC</small><p>' . nl2br(eu($body)) . '</p></div>';
    $h = '';
    if ((string)$t['body'] !== '') $h .= $bub(false, (string)$t['created_at'], (string)$t['body']);
    foreach ($replies as $r) $h .= $bub((int)$r['from_admin'] === 1, (string)$r['created_at'], (string)$r['body']);
    return '<div class="msgs">' . $h . '</div>';
}
