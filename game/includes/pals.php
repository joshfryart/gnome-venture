<?php
declare(strict_types=1);

/**
 * v1.0.0 wave 3: gnome friends. (includes/friends.php is the townsfolk friendship; this is player to player.)
 *
 * - Friend requests: send, accept, decline, cancel, remove. A request is a row (user_id asked friend_id). Declined requests
 *   stay as 'declined' for 14 days so nobody can be nagged, and the asker is not told.
 * - Blocks: a block removes any friendship and request both ways, and stops requests, guestbook signs, gifts and trade offers between the two.
 * - Guestbook stamps (the gate stamps): a visitor signs one preset stamp per garden per Hollow day. No free text, so no moderation load.
 *   v1.7.0: the 🌻 👏 🐝 ✨ garden reactions are the first four stamps. (Passport stamps from rest stops are a different thing.)
 * - Seedling gifts: a friend may send a seed or seedling once a day per friend, with a preset note. It goes through send_gift(),
 *   so the level gate, the daily gift cap and the item checks all apply.
 */

const PAL_STAMPS = [
    'sunflower' => ['🌻', 'Sunflower'], 'clap' => ['👏', 'Well done'], 'bee' => ['🐝', 'Bee'], 'sparkle' => ['✨', 'Sparkling'],
    'daisy' => ['🌼', 'Daisy'], 'mushroom' => ['🍄', 'Mushroom'], 'snail' => ['🐌', 'Snail'], 'carrot' => ['🥕', 'Carrot'],
    'leaf' => ['🍂', 'Leaf'], 'star' => ['⭐', 'Star'], 'rainbow' => ['🌈', 'Rainbow'], 'acorn' => ['🌰', 'Acorn'], 'drop' => ['💧', 'Raindrop'],
];
const PAL_GIFT_NOTES = [
    'grow' => 'Grow something lovely!', 'thanks' => 'Thanks for being my friend.', 'try' => 'Try this one, it is fun.',
    'welcome' => 'Welcome to the Hollow!', 'luck' => 'Good luck with your garden!',
];
const PAL_DECLINE_DAYS = 14;
const PAL_CANCEL_HOURS = 48;     // v1.0.0: after taking a request back, the same gnome can't be asked again for a while (no notification spam)
const PAL_REQUESTS_PER_DAY = 10; // v1.0.0: most new requests (notifications) one gnome can receive in a day

/** Stamps a visitor can choose today: the thirteen above, plus any a festival adds. */
function pal_stamp_set(): array
{
    $s = PAL_STAMPS;
    if (function_exists('festival_stamps')) $s = array_merge($s, festival_stamps());
    return $s;
}

function pal_blocked(int $a, int $b): bool
{
    return (bool)q_val('SELECT 1 FROM player_blocks WHERE (blocker_id = ? AND blocked_id = ?) OR (blocker_id = ? AND blocked_id = ?)', [$a, $b, $b, $a]);
}

function pal_i_blocked(int $me, int $other): bool
{
    return (bool)q_val('SELECT 1 FROM player_blocks WHERE blocker_id = ? AND blocked_id = ?', [$me, $other]);
}

/** 'self' | 'blocked' | 'friends' | 'sent' | 'received' | 'none' */
function pal_status(int $me, int $other): string
{
    if ($me === $other) return 'self';
    if (pal_blocked($me, $other)) return 'blocked';
    $r = q_one("SELECT user_id, status FROM player_friends WHERE (user_id = ? AND friend_id = ?) OR (user_id = ? AND friend_id = ?) ORDER BY id DESC LIMIT 1", [$me, $other, $other, $me]);
    if (!$r) return 'none';
    if ($r['status'] === 'accepted') return 'friends';
    if ($r['status'] === 'pending') return (int)$r['user_id'] === $me ? 'sent' : 'received';
    return 'none';
}

function pal_are_friends(int $a, int $b): bool
{
    return pal_status($a, $b) === 'friends';
}

/** Ids of a gnome's friends (accepted, both ways). */
function pal_friend_ids(int $uid): array
{
    // v1.0.0: gnomes whose account is gone are left out (a ghost friend could never be removed)
    return array_map('intval', q("SELECT u.id FROM player_friends f JOIN users u ON u.id = CASE WHEN f.user_id = ? THEN f.friend_id ELSE f.user_id END
                                  WHERE f.status = 'accepted' AND (f.user_id = ? OR f.friend_id = ?) AND u.deleted_at IS NULL", [$uid, $uid, $uid])->fetchAll(PDO::FETCH_COLUMN));
}

function pal_count(int $uid): int
{
    // v1.0.0: counts only friends who are still here (the same set pal_list shows)
    return (int)q_val("SELECT COUNT(*) FROM player_friends f JOIN users u ON u.id = CASE WHEN f.user_id = ? THEN f.friend_id ELSE f.user_id END
                       WHERE f.status = 'accepted' AND (f.user_id = ? OR f.friend_id = ?) AND u.deleted_at IS NULL AND " . gnome_in_play_sql('u'), [$uid, $uid, $uid]);
}

/** Friends with what is safe to show: name, level, a coarse "last about", and the active garden if it is open to visitors. */
function pal_list(int $uid): array
{
    $ids = pal_friend_ids($uid);
    if (!$ids) return [];
    $out = [];
    foreach (q('SELECT u.id, u.username, u.gnome_name, u.level, u.last_seen, u.garden_public, u.pulse_show, u.active_plot_id FROM users u WHERE u.id IN (' . implode(',', array_map('intval', $ids)) . ') AND u.deleted_at IS NULL AND '
        . gnome_in_play_sql('u') . ' ORDER BY u.last_seen DESC')->fetchAll() as $f) {
        $f['name'] = (string)($f['gnome_name'] ?: $f['username']);
        $f['about'] = (int)$f['pulse_show'] === 1 ? pal_about_text($f['last_seen']) : 'a while ago';   // v1.0.0: someone hiding from the Pulse isn't shown as online either
        $f['plot_id'] = (int)$f['garden_public'] === 1 && $f['active_plot_id'] ? (int)$f['active_plot_id'] : 0;
        $out[] = $f;
    }
    return $out;
}

/** How recently a gnome was about, in words that do not give a time away. */
function pal_about_text(?string $lastSeen): string
{
    if (!$lastSeen) return 'a while ago';
    $s = time() - (int)strtotime($lastSeen . ' UTC');
    return $s < 15 * 60 ? 'about now' : ($s < 86400 ? 'today' : ($s < 7 * 86400 ? 'this week' : 'a while ago'));
}

/** Incoming requests waiting for this gnome: [{id, from_id, name, created_at}]. */
function pal_requests_in(int $uid): array
{
    return q("SELECT f.id, f.user_id AS from_id, COALESCE(u.gnome_name, u.username) AS name, u.level, f.created_at FROM player_friends f JOIN users u ON u.id = f.user_id
              WHERE f.friend_id = ? AND f.status = 'pending' AND u.deleted_at IS NULL AND " . gnome_in_play_sql('u') . ' ORDER BY f.id', [$uid])->fetchAll();
}

function pal_requests_out(int $uid): array
{
    return q("SELECT f.id, f.friend_id AS to_id, COALESCE(u.gnome_name, u.username) AS name, f.created_at FROM player_friends f JOIN users u ON u.id = f.friend_id
              WHERE f.user_id = ? AND f.status = 'pending' AND u.deleted_at IS NULL ORDER BY f.id", [$uid])->fetchAll();
}

function pal_request(array $u, int $toId): array
{
    $me = (int)$u['id'];
    if ($toId === $me) return [false, 'You can’t be your own friend (though you are good company).'];
    $to = q_one('SELECT id, username, gnome_name FROM users u WHERE u.id = ? AND u.deleted_at IS NULL AND u.onboarded = 1 AND ' . gnome_in_play_sql('u'), [$toId]);
    if (!$to || pal_blocked($me, $toId)) return [false, 'No gnome by that name.'];
    if (user_muted($u)) return [false, 'A moderator has paused your writing for now, which includes requests. You can still play.'];
    $st = pal_status($me, $toId);
    if ($st === 'friends') return [false, 'You are already friends.'];
    if ($st === 'sent') return [false, 'Your request is already waiting.'];
    if ($st === 'received') return pal_answer($u, $toId, 'accept');   // they asked first: just say yes
    $name = (string)($to['gnome_name'] ?: $to['username']);
    if (pal_count($me) >= (int)setting('friends_max')) return [false, 'Your friends list is full (' . (int)setting('friends_max') . ').'];
    if (pal_count($toId) >= (int)setting('friends_max')) return [false, $name . '’s friends list is full.'];
    if ((int)q_val("SELECT COUNT(*) FROM player_friends WHERE user_id = ? AND status = 'pending'", [$me]) >= (int)setting('friends_pending_max')) return [false, 'You have a lot of requests waiting. Let some be answered first.'];
    if ((int)q_val("SELECT COUNT(*) FROM player_friends WHERE friend_id = ? AND status = 'pending'", [$toId]) >= 30) return [false, $name . ' has a lot of requests waiting. Try again later.'];
    if ((int)q_val("SELECT COUNT(*) FROM player_friends WHERE friend_id = ? AND created_at > ? AND status <> 'cancelled'", [$toId, gmdate('Y-m-d H:i:s', time() - 86400)]) >= PAL_REQUESTS_PER_DAY) return [false, $name . ' has had a lot of requests today. Try again tomorrow.'];
    $old = q_one('SELECT id, status, answered_at FROM player_friends WHERE user_id = ? AND friend_id = ?', [$me, $toId]);
    if ($old) {   // an old declined request: not again for a while
        if ($old['status'] === 'declined' && strtotime((string)$old['answered_at'] . ' UTC') > time() - PAL_DECLINE_DAYS * 86400) return [true, '🤝 Request sent to ' . $name . '.'];   // looks sent; nothing goes out
        if ($old['status'] === 'cancelled' && strtotime((string)$old['answered_at'] . ' UTC') > time() - PAL_CANCEL_HOURS * 3600) return [false, 'You took that request back a moment ago. Give it a couple of days before asking again.'];
        if (q("UPDATE player_friends SET status = 'pending', created_at = ?, answered_at = NULL WHERE id = ? AND status <> 'pending' AND status <> 'accepted'", [now(), $old['id']])->rowCount() !== 1) return [false, 'Your request is already waiting.'];
    } else {
        try {
            db_insert('player_friends', ['user_id' => $me, 'friend_id' => $toId, 'status' => 'pending', 'created_at' => now()]);
        } catch (PDOException $e) {
            return [false, 'Your request is already waiting.'];
        }
    }
    require_once __DIR__ . '/trade.php';
    notify($toId, '🤝 ' . gnome_name($u) . ' would like to be gnome friends. Answer on the Friends page.');
    return [true, '🤝 Request sent to ' . $name . '.'];
}

/** $answer: accept | decline. */
function pal_answer(array $u, int $fromId, string $answer): array
{
    $me = (int)$u['id'];
    $row = q_one("SELECT id FROM player_friends WHERE user_id = ? AND friend_id = ? AND status = 'pending'", [$fromId, $me]);
    if (!$row) return [false, 'That request is no longer there.'];
    if (pal_blocked($me, $fromId)) {
        q('DELETE FROM player_friends WHERE id = ?', [$row['id']]);
        return [false, 'That request is no longer there.'];
    }
    $name = social_name($fromId) ?? 'that gnome';
    if ($answer === 'decline') {
        q("UPDATE player_friends SET status = 'declined', answered_at = ? WHERE id = ? AND status = 'pending'", [now(), $row['id']]);
        return [true, 'Request declined. They won’t be told.'];
    }
    if (pal_count($me) >= (int)setting('friends_max') || pal_count($fromId) >= (int)setting('friends_max')) return [false, 'A friends list is full.'];
    if (q("UPDATE player_friends SET status = 'accepted', answered_at = ? WHERE id = ? AND status = 'pending'", [now(), $row['id']])->rowCount() !== 1) return [false, 'That request is no longer there.'];
    require_once __DIR__ . '/trade.php';
    notify($fromId, '🤝 ' . gnome_name($u) . ' accepted your friend request!');
    return [true, '🤝 You and ' . $name . ' are friends now.'];
}

function pal_cancel(array $u, int $toId): array
{
    // v1.0.0: kept as 'cancelled' (with the time) so a cancel-and-resend loop can't keep notifying the other gnome
    $n = q("UPDATE player_friends SET status = 'cancelled', answered_at = ? WHERE user_id = ? AND friend_id = ? AND status = 'pending'", [now(), (int)$u['id'], $toId])->rowCount();
    return $n ? [true, 'Request taken back.'] : [false, 'There was no waiting request.'];
}

function pal_remove(array $u, int $otherId): array
{
    $me = (int)$u['id'];
    $n = q("DELETE FROM player_friends WHERE status = 'accepted' AND ((user_id = ? AND friend_id = ?) OR (user_id = ? AND friend_id = ?))", [$me, $otherId, $otherId, $me])->rowCount();
    return $n ? [true, 'Removed from your friends. They won’t be told.'] : [false, 'You weren’t friends.'];
}

function pal_block(array $u, int $otherId): array
{
    $me = (int)$u['id'];
    unset($_SESSION['gv_pulse']);   // v1.0.1: the Pulse is kept a minute; a block shows at once
    if ($otherId === $me) return [false, 'You can’t block yourself.'];
    if (!q_val('SELECT 1 FROM users WHERE id = ?', [$otherId])) return [false, 'No such gnome.'];
    if (!pal_i_blocked($me, $otherId)) {
        try { db_insert('player_blocks', ['blocker_id' => $me, 'blocked_id' => $otherId, 'created_at' => now()]); } catch (PDOException $e) { /* already */ }
    }
    q('DELETE FROM player_friends WHERE (user_id = ? AND friend_id = ?) OR (user_id = ? AND friend_id = ?)', [$me, $otherId, $otherId, $me]);
    require_once __DIR__ . '/mentors120.php'; mentors120_on_block($me, $otherId);   // v1.2.0: a block ends mentoring too
    q('DELETE FROM garden_stamps WHERE user_id = ? AND plot_id IN (SELECT id FROM plots WHERE user_id = ?)', [$otherId, $me]);   // v1.0.0: their guestbook signs come off your garden
    return [true, '🚫 Blocked. They can’t send you requests, guestbook signs, gifts or offers, and you are off each other’s lists. They won’t be told.'];
}

function pal_unblock(array $u, int $otherId): array
{
    $n = q('DELETE FROM player_blocks WHERE blocker_id = ? AND blocked_id = ?', [(int)$u['id'], $otherId])->rowCount();
    return $n ? [true, 'Unblocked.'] : [false, 'They weren’t blocked.'];
}

function pal_blocked_list(int $uid): array
{
    return q('SELECT b.blocked_id AS id, COALESCE(u.gnome_name, u.username) AS name FROM player_blocks b JOIN users u ON u.id = b.blocked_id WHERE b.blocker_id = ? ORDER BY b.created_at DESC', [$uid])->fetchAll();
}

// ---------------- Guestbook stamps ----------------

/** Sign a garden's guestbook (a gate stamp): once per visitor per garden per Hollow day. */
function pal_stamp(array $u, int $plotId, string $stamp): array
{
    $me = (int)$u['id'];
    $set = pal_stamp_set();
    if (!isset($set[$stamp])) return [false, 'Pick one of the stamps.'];
    $plot = q_one('SELECT * FROM plots WHERE id = ?', [$plotId]);
    require_once __DIR__ . '/yard.php';
    if (!$plot || !garden_visible($plot, $u)) return [false, 'You can’t visit that garden.'];
    $owner = q_one('SELECT * FROM users WHERE id = ?', [$plot['user_id']]);
    require_once __DIR__ . '/social169.php';
    if (!$owner) return [false, 'You can’t visit that garden.'];
    if (($why = gate_can_interact($u, $owner)) !== '') return [false, $why === 'Your own garden.' ? 'The guestbook is for other gardens.' : 'You can’t visit that garden.'];
    if (user_muted($u)) return [false, 'A moderator has paused your writing for now. You can still play.'];
    $day = hollow_date('Y-m-d');
    try {
        db_insert('garden_stamps', ['plot_id' => $plotId, 'user_id' => $me, 'day' => $day, 'stamp' => $stamp, 'stamped_at' => now()]);
    } catch (PDOException $e) {
        return [false, 'You’ve signed this guestbook today. Come back tomorrow!'];
    }
    require_once __DIR__ . '/trade.php';
    social169_notify_owner((int)$owner['id'], $plot, $day);   // v1.7.0: one rolled-up notice a day
    return [true, $set[$stamp][0] . ' You sign the guestbook.'];
}

function pal_stamped_today(int $uid, int $plotId): ?string
{
    $s = q_val('SELECT stamp FROM garden_stamps WHERE plot_id = ? AND user_id = ? AND day = ?', [$plotId, $uid, hollow_date('Y-m-d')]);
    return $s ? (string)$s : null;
}

/** The newest stamps at a gate, with names of the visitors (visitors in a time-out or gone are left out). */
function pal_stamps_at(int $plotId, int $limit = 14): array
{
    return q('SELECT s.id, s.stamp, s.day, s.user_id, COALESCE(u.gnome_name, u.username) AS name FROM garden_stamps s JOIN users u ON u.id = s.user_id
              WHERE s.plot_id = ? AND u.deleted_at IS NULL AND ' . gnome_in_play_sql('u') . ' ORDER BY s.id DESC LIMIT ' . (int)$limit, [$plotId])->fetchAll();
}

function pal_stamp_count(int $plotId): int
{
    return (int)q_val('SELECT COUNT(*) FROM garden_stamps WHERE plot_id = ?', [$plotId]);
}

/** The owner tidies a stamp off their guestbook. */
function pal_stamp_remove(array $u, int $stampId): array
{
    $n = q('DELETE FROM garden_stamps WHERE id = ? AND plot_id IN (SELECT id FROM plots WHERE user_id = ?)', [$stampId, (int)$u['id']])->rowCount();
    return $n ? [true, 'Cleared from your guestbook.'] : [false, 'That isn’t in your guestbook.'];
}

/** The guestbook as HTML (the stamps in a row, newest first). */
function pal_gate_html(int $plotId, array $viewer, bool $mine): string
{
    $set = pal_stamp_set();
    $rows = pal_stamps_at($plotId);
    if (!$rows) return '<p class="muted">No stamps yet.</p>';
    $h = '<ul class="stamps">';
    foreach ($rows as $r) {
        $s = $set[$r['stamp']] ?? ['🌼', 'Stamp'];
        $h .= '<li title="' . e($s[1] . ' from ' . $r['name'] . ', ' . $r['day']) . '"><span class="stampi" aria-hidden="true">' . $s[0] . '</span><span class="stampn">' . e($r['name']) . '</span>';
        if ($mine) {
            $h .= '<form method="post" class="inline" action="' . e(url('visit.php')) . '">' . csrf_field() . '<input type="hidden" name="g" value="' . $plotId . '"><input type="hidden" name="do" value="stamp_clear"><input type="hidden" name="stamp_id" value="' . (int)$r['id'] . '">'
                . '<button class="linkbtn" aria-label="Clear this stamp from the guestbook">✕</button></form>';
        }
        $h .= '</li>';
    }
    return $h . '</ul>';
}

// ---------------- Seedling gifts between friends ----------------

/** Seeds and saplings a gnome holds that can be given away: [{id, name, qty, category}]. */
function pal_giftable(int $uid): array
{
    return q("SELECT i.id, i.name, i.category, ui.qty FROM user_items ui JOIN items i ON i.id = ui.item_id WHERE ui.user_id = ? AND ui.qty > 0 AND i.tradable = 1 AND i.category IN ('seed', 'sapling')
              ORDER BY i.category DESC, i.name", [$uid])->fetchAll();
}

/** Has this gnome already sent this friend something today (Hollow day)? */
function pal_gift_sent_today(int $from, int $to): bool
{
    $mid = (new DateTime(hollow_date('Y-m-d') . ' 00:00:00', hollow_tz()))->getTimestamp();
    return (bool)q_val('SELECT 1 FROM gifts WHERE from_id = ? AND to_id = ? AND sent_at >= ?', [$from, $to, gmdate('Y-m-d H:i:s', $mid)]);
}

function pal_gift(array $u, int $toId, int $itemId, int $qty, string $noteKey): array
{
    $me = (int)$u['id'];
    if (setting('friend_gifts_on') !== '1') return [false, 'Gifts between friends are switched off.'];
    if (!pal_are_friends($me, $toId)) return [false, 'You can send seedlings to your friends. Ask them to be friends first.'];
    $to = q_one('SELECT id, username, gnome_name FROM users u WHERE u.id = ? AND ' . gnome_in_play_sql('u') . ' AND u.deleted_at IS NULL', [$toId]);
    if (!$to) return [false, 'They can’t take gifts just now.'];
    if (pal_gift_sent_today($me, $toId)) return [false, 'You’ve already sent ' . ($to['gnome_name'] ?: $to['username']) . ' something today. Tomorrow!'];
    $item = q_one("SELECT * FROM items WHERE id = ? AND category IN ('seed', 'sapling') AND tradable = 1", [$itemId]);
    if (!$item) return [false, 'Friends can send seeds and seedlings.'];
    $qty = max(1, min(3, $qty));
    $note = PAL_GIFT_NOTES[$noteKey] ?? PAL_GIFT_NOTES['grow'];
    require_once __DIR__ . '/trade.php';
    // v1.0.0: claim today's slot first (a unique row), so two devices can't both send; given back if the gift doesn't go
    $day = hollow_date('Y-m-d');
    try { db_insert('pal_gift_days', ['from_id' => $me, 'to_id' => $toId, 'day' => $day]); }
    catch (PDOException $e) { return [false, 'You’ve already sent ' . ($to['gnome_name'] ?: $to['username']) . ' something today. Tomorrow!']; }
    try {
        $res = send_gift($u, (string)($to['gnome_name'] ?: $to['username']), $itemId, $qty, 0, $note, (int)$toId);   // by id: never re-looked-up by name
    } catch (Throwable $e) {
        q('DELETE FROM pal_gift_days WHERE from_id = ? AND to_id = ? AND day = ?', [$me, $toId, $day]);
        throw $e;
    }
    if (!$res[0]) q('DELETE FROM pal_gift_days WHERE from_id = ? AND to_id = ? AND day = ?', [$me, $toId, $day]);
    return $res;
}

/** The buttons on a profile: add, accept, requested, friends, block. */
function pal_profile_actions(array $me, array $g): string
{
    $mid = (int)$me['id'];
    $gid = (int)$g['id'];
    if ($mid === $gid) return '<a class="btn small" href="' . e(url('pals.php')) . '">🤝 My friends (' . pal_count($mid) . ')</a>';
    $st = pal_status($mid, $gid);
    $form = fn(string $do, string $label, string $cls = 'btn small', string $confirm = '') => '<form method="post" action="' . e(url('pals.php')) . '" class="inline"' . ($confirm !== '' ? ' data-confirm="' . e($confirm) . '"' : '') . '>'
        . csrf_field() . '<input type="hidden" name="do" value="' . $do . '"><input type="hidden" name="id" value="' . $gid . '"><input type="hidden" name="back" value="profile.php?id=' . $gid . '"><button class="' . $cls . '">' . $label . '</button></form>';
    $h = '';
    if ($st === 'blocked') {
        return pal_i_blocked($mid, $gid) ? $form('unblock', '🚫 Blocked · unblock', 'btn small ghost') : '';
    }
    $h .= match ($st) {
        'friends' => '<span class="tag">🤝 Friends</span> ' . $form('remove', 'Remove', 'btn small ghost', 'Remove ' . gnome_name($g) . ' from your friends?'),
        'sent' => '<span class="tag">⏳ Request sent</span> ' . $form('cancel', 'Take it back', 'btn small ghost'),
        'received' => $form('accept', '✔ Accept friend request') . ' ' . $form('decline', 'Not now', 'btn small ghost'),
        default => $form('request', '🤝 Add friend'),
    };
    return $h . ' ' . $form('block', '🚫 Block', 'linkbtn', 'Block ' . gnome_name($g) . '? They won’t be told, and they can’t send you requests, guestbook signs, gifts or offers.');
}

/** Friends shown on a profile: names only, linked. Open profiles list them; a private one shows a count (and the owner always sees the list). */
function pal_profile_list(array $g, bool $mine, bool $staff): string
{
    $n = pal_count((int)$g['id']);
    if ($n === 0) return '<p class="muted">No gnome friends yet.</p>';
    if (!$mine && !$staff && (int)$g['garden_public'] !== 1) return '<p class="muted">🤝 ' . $n . ' gnome friend' . ($n === 1 ? '' : 's') . '. The list is private.</p>';
    $names = [];
    foreach (pal_list((int)$g['id']) as $f) {
        if (!$mine && !$staff && !$f['plot_id']) continue;   // v1.0.0: a friend with a private garden isn't named to visitors
        $names[] = '<li><a class="chip" href="' . e(url('profile.php?id=' . (int)$f['id'])) . '">' . e($f['name']) . '</a></li>';
    }
    if (!$names) return '<p class="muted">🤝 ' . $n . ' gnome friend' . ($n === 1 ? '' : 's') . '.</p>';
    $h = '<ul class="chips">' . implode('', $names);
    return $h . '</ul>';
}

/** v1.0.0: may this gnome be named in the Hollow Pulse "About now" line? (Also needs an open garden.) */
function pal_set_pulse(int $uid, bool $on): array
{
    q('UPDATE users SET pulse_show = ? WHERE id = ?', [$on ? 1 : 0, $uid]);
    unset($_SESSION['gv_pulse']);   // v1.0.1
    return [true, $on ? 'You may be named in the Hollow Pulse when you are about (if your garden is open).' : 'You are now counted as a quiet gnome in the Hollow Pulse, never named.'];
}
