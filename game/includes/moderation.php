<?php
declare(strict_types=1);
/**
 * Moderation (v0.7.28).
 * Players report things with the 🚩 button (a gnome's name, a garden name, notes on gifts, trades and jobs, a carving title).
 * Moderators (role "mod") and admins work the queue on modtools.php: dismiss, clear the text, mute (no writing) or a timed ban.
 * Only admins can ban for good. Every action goes in the admin log and the player is told why.
 * A blocked-words list (setting blocked_words) stops the worst before anyone has to report it.
 */

const REPORT_KINDS = [
    'name' => 'Gnome name', 'garden' => 'Garden name', 'gift' => 'Gift note', 'offer' => 'Trade note',
    'job' => 'Job note', 'carving' => 'Carving title', 'yard' => 'Garden design', 'other' => 'Behaviour',
];
const REPORT_REASONS = ['rude' => 'Rude or hurtful', 'personal' => 'Shares personal information', 'spam' => 'Spam or advertising',
    'cheat' => 'Cheating or scamming', 'other' => 'Something else'];
const REPORTS_PER_DAY = 10;

/** Is this gnome muted (can't write names or notes)? */
function user_muted(array $u): bool
{
    return !empty($u['muted_until']) && strtotime($u['muted_until'] . ' UTC') > time();
}

/** Can this gnome write this text? Returns an error, or null if it's fine. */
function text_problem(array $u, string $text): ?string
{
    if (trim($text) === '') return null;
    if (user_muted($u)) return 'A moderator has paused your writing until ' . gmdate('M j, H:i', (int)strtotime($u['muted_until'] . ' UTC')) . ' UTC. You can still play.';
    if (blocked_word($text)) return 'Please keep it friendly. That has a word we don’t allow.';
    return null;
}

/** Common leetspeak swaps (v0.7.85). Applied before words are split, so "b1tch" reads as "bitch". */
const LEET_SWAPS = ['0' => 'o', '1' => 'i', '3' => 'e', '4' => 'a', '5' => 's', '@' => 'a', '$' => 's'];

/** Collapse runs of the same letter: "bitttch" → "bitch". Only used for words of 4+ letters, so short words don't collide. */
function squeeze_letters(string $s): string
{
    return preg_replace('/(\p{L})\1+/u', '$1', $s) ?? $s;
}

/**
 * Does the text contain a blocked word? (setting blocked_words: comma-separated, case-insensitive.)
 * v0.7.85: word-based. Each word is lower-cased and de-leeted, then compared with the blocked words as whole words,
 * so "Who really knows" and "a bit chilly" pass. Letters spelled out with spaces ("b i t c h") are joined and checked.
 * A single token with no spaces at all ("B1tch", "b.i.t.c.h") is checked with its punctuation removed.
 * Longer blocked words (5+ letters) also count inside a longer run, as before, so "f.u.l.l" style dodges still hit.
 */
function blocked_word(string $text): bool
{
    $words = array_filter(array_map(fn($w) => strtr(trim(mb_strtolower($w)), LEET_SWAPS), explode(',', setting('blocked_words'))));
    if (!$words) return false;
    $tokens = preg_split('/\P{L}+/u', strtr(mb_strtolower($text), LEET_SWAPS), -1, PREG_SPLIT_NO_EMPTY) ?: [];
    $haystacks = [];
    $run = '';
    foreach ($tokens as $tok) {   // one-letter words in a row are one spelled-out word
        if (mb_strlen($tok) === 1) { $run .= $tok; continue; }
        if (mb_strlen($run) > 1) $haystacks[] = $run;
        $run = '';
    }
    if (mb_strlen($run) > 1) $haystacks[] = $run;
    if ($tokens && !preg_match('/\s/u', trim($text))) $haystacks[] = implode('', $tokens);   // no spaces at all
    foreach ($words as $w) {
        $sq = squeeze_letters($w);
        foreach ($tokens as $tok) {
            if ($tok === $w) return true;
            if (mb_strlen($w) >= 4 && squeeze_letters($tok) === $sq) return true;   // "whoore" → "whore"
        }
        if (mb_strlen($w) < 5) continue;   // short words only match a whole word, never inside another
        foreach ($haystacks as $h) {
            if (str_contains($h, $w) || str_contains(squeeze_letters($h), $sq)) return true;
        }
    }
    return false;
}

/** The reported text as it is right now. */
function report_snapshot(string $kind, int $targetId, int $refId): ?string
{
    return match ($kind) {
        'name' => q_val('SELECT gnome_name FROM users WHERE id = ?', [$targetId]) ?: null,
        'garden' => q_val('SELECT garden_name FROM plots WHERE id = ? AND user_id = ?', [$refId, $targetId]) ?: null,
        'gift' => q_val('SELECT note FROM gifts WHERE id = ? AND from_id = ?', [$refId, $targetId]) ?: null,
        'offer' => q_val('SELECT note FROM trade_offers WHERE id = ? AND from_id = ?', [$refId, $targetId]) ?: null,
        'job' => q_val('SELECT note FROM player_jobs WHERE id = ? AND poster_id = ?', [$refId, $targetId]) ?: null,
        'carving' => q_val('SELECT title FROM carvings WHERE id = ? AND user_id = ?', [$refId, $targetId]) ?: null,
        'yard' => ($g = q_one('SELECT garden_name, appeal FROM plots WHERE id = ? AND user_id = ?', [$refId, $targetId]))
            ? 'The yard of “' . ($g['garden_name'] ?: 'Garden') . '” (garden #' . $refId . ')' : null,
        'other' => '',
        default => null,
    };
}

function file_report(array $u, int $targetId, string $kind, int $refId, string $reason, string $details): array
{
    $uid = (int)$u['id'];
    if (!isset(REPORT_KINDS[$kind]) || !isset(REPORT_REASONS[$reason])) return [false, 'Pick what’s wrong.'];
    if ($targetId === $uid) return [false, 'You can’t report yourself.'];
    $target = q_one('SELECT id, role FROM users WHERE id = ?', [$targetId]);
    if (!$target) return [false, 'That gnome doesn’t exist.'];
    $snap = report_snapshot($kind, $targetId, $refId);
    if ($snap === null) return [false, 'That’s already gone.'];
    if ((int)q_val('SELECT COUNT(*) FROM reports WHERE reporter_id = ? AND created_at > ?', [$uid, gmdate('Y-m-d H:i:s', time() - 86400)]) >= REPORTS_PER_DAY) {
        return [false, 'You’ve sent a lot of reports today. Thank you! The moderators will catch up.'];
    }
    // (whole number written into the SQL: SQLite compares an expression with a bound value as text)
    if (q_val("SELECT 1 FROM reports WHERE reporter_id = ? AND target_id = ? AND kind = ? AND COALESCE(ref_id, 0) = " . (int)$refId . " AND status = 'open'", [$uid, $targetId, $kind])) {
        return [false, 'You’ve already reported that. A moderator will look soon.'];
    }
    db_insert('reports', ['reporter_id' => $uid, 'target_id' => $targetId, 'kind' => $kind, 'ref_id' => $refId ?: null, 'snapshot' => mb_substr($snap, 0, 500),
        'reason' => $reason, 'details' => mb_substr(trim($details), 0, 255) ?: null, 'status' => 'open', 'created_at' => now()]);
    return [true, '🚩 Thanks. A moderator will take a look. You won’t hear back, but it will be dealt with.'];
}

/** Moderator actions on a report. $hours for mute/timeban. */
function mod_act(array $mod, int $reportId, string $action, int $hours = 24): array
{
    if (!in_array($mod['role'], ['admin', 'mod'], true)) return [false, 'Moderators only.'];
    $r = q_one('SELECT * FROM reports WHERE id = ?', [$reportId]);
    if (!$r) return [false, 'No such report.'];
    $target = q_one('SELECT * FROM users WHERE id = ?', [$r['target_id']]);
    if (!$target) return [false, 'That gnome is gone.'];
    if ((int)$target['id'] === (int)$mod['id']) return [false, 'Another moderator must handle reports about you.'];   // v1.2.2
    if ($target['role'] === 'admin' && $mod['role'] !== 'admin') return [false, 'Only an admin can act on an admin.'];
    require_once __DIR__ . '/trade.php';
    $hours = max(1, min(24 * 30, $hours));
    $until = gmdate('Y-m-d H:i:s', time() + $hours * 3600);
    $what = REPORT_KINDS[$r['kind']] ?? 'something';
    switch ($action) {
        case 'dismiss':
            $msg = 'Report dismissed.';
            break;
        case 'clear':
            mod_clear_text($r);
            notify((int)$target['id'], '🛡️ A moderator removed your ' . strtolower($what) . ' because it broke the rules. Please keep things friendly.');
            $msg = 'Cleared the ' . strtolower($what) . '.';
            break;
        case 'mute':
            mod_clear_text($r);
            q('UPDATE users SET muted_until = ? WHERE id = ?', [$until, $target['id']]);
            notify((int)$target['id'], '🛡️ A moderator removed your ' . strtolower($what) . ' and paused your writing (names and notes) for ' . $hours . ' hours. You can still play.');
            $msg = 'Cleared and muted for ' . $hours . ' hours.';
            break;
        case 'timeban':
            mod_clear_text($r);
            q('UPDATE users SET banned_until = ?, ban_reason = ? WHERE id = ?', [$until, 'Timed out by a moderator (' . REPORT_REASONS[$r['reason']] . ')', $target['id']]);
            $msg = 'Cleared and banned for ' . $hours . ' hours.';
            break;
        case 'ban':
            if ($mod['role'] !== 'admin') return [false, 'Only admins can ban for good. Use a timed ban.'];
            mod_clear_text($r);
            q('UPDATE users SET banned = 1, ban_reason = ? WHERE id = ?', ['Banned (' . REPORT_REASONS[$r['reason']] . ')', $target['id']]);
            $msg = 'Banned for good.';
            break;
        default:
            return [false, 'Unknown action.'];
    }
    // Close this report and any other open ones about the same thing
    q("UPDATE reports SET status = ?, action = ?, handled_by = ?, handled_at = ? WHERE status = 'open' AND target_id = ? AND kind = ? AND COALESCE(ref_id, 0) = " . (int)$r['ref_id'],
        [$action === 'dismiss' ? 'dismissed' : 'resolved', $action, $mod['id'], now(), $r['target_id'], $r['kind']]);
    admin_log('mod_' . $action, 'user #' . $target['id'] . ' ' . ($target['gnome_name'] ?: $target['username']), $what . ': ' . (string)$r['snapshot'] . ($action === 'mute' || $action === 'timeban' ? ' (' . $hours . 'h)' : ''));
    return [true, $msg];
}

/** Remove the reported text, replacing names with something plain. */
function mod_clear_text(array $r): void
{
    $t = (int)$r['target_id'];
    $ref = (int)$r['ref_id'];
    match ($r['kind']) {
        'name' => q('UPDATE users SET gnome_name = ? WHERE id = ?', ['Gnome ' . $t, $t]),
        'garden' => q('UPDATE plots SET garden_name = ? WHERE id = ? AND user_id = ?', ['Garden', $ref, $t]),
        'gift' => q('UPDATE gifts SET note = NULL WHERE id = ? AND from_id = ?', [$ref, $t]),
        'offer' => q('UPDATE trade_offers SET note = NULL WHERE id = ? AND from_id = ?', [$ref, $t]),
        'job' => q('UPDATE player_jobs SET note = NULL WHERE id = ? AND poster_id = ?', [$ref, $t]),
        'carving' => q('UPDATE carvings SET title = ? WHERE id = ? AND user_id = ?', ['Untitled', $ref, $t]),
        'yard' => (function () use ($ref, $t) {
            require_once __DIR__ . '/yard.php';
            if (q_val('SELECT 1 FROM plots WHERE id = ? AND user_id = ?', [$ref, $t])) yard_clear($ref);
        })(),
        default => null,
    };
}

/** Lift a mute or timed ban early. */
function mod_lift(array $mod, int $userId, string $what): array
{
    if (!in_array($mod['role'], ['admin', 'mod'], true)) return [false, 'Moderators only.'];
    if ($userId === (int)$mod['id']) return [false, 'Another moderator must handle reports about you.'];   // v1.2.2
    if ($what === 'mute') q('UPDATE users SET muted_until = NULL WHERE id = ?', [$userId]);
    elseif ($what === 'timeban') q('UPDATE users SET banned_until = NULL WHERE id = ?', [$userId]);
    else return [false, 'Unknown.'];
    admin_log('mod_lift_' . $what, 'user #' . $userId);
    return [true, 'Lifted.'];
}

/** A small 🚩 link to report something. */
function report_link(int $targetId, string $kind, int $refId = 0): string
{
    $me = current_user();
    if (!$me || (int)$me['id'] === $targetId) return '';
    return '<a class="reportlink" href="' . e(url('report.php?u=' . $targetId . '&k=' . $kind . ($refId ? '&r=' . $refId : ''))) . '" title="Report this to a moderator" aria-label="Report this to a moderator">🚩</a>';
}

function open_report_count(): int
{
    return (int)q_val("SELECT COUNT(*) FROM reports WHERE status = 'open'");
}
