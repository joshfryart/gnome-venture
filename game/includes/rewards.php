<?php
declare(strict_types=1);

/**
 * Reward wrapper: one place for "give/take Petals" and "give XP".
 * Thin on purpose: same single-statement SQL the code always used, no caps, no behaviour change.
 * Everything that wants to count, cap or log rewards later hooks into reward_log() below.
 *
 * Race safety: give_petals is one atomic UPDATE; take_petals is a conditional UPDATE used as the claim
 * (WHERE coins >= ? + rowCount), so it is safe inside or outside an open transaction.
 * Callers that need extra columns in the same UPDATE (ribbons, shift_actions, ...) keep their own statement.
 */

/** Extension point (does nothing yet): kind 'petals_in' | 'petals_out' | 'xp', the user, the amount, a short reason. Future: daily caps, xp_log, audit. */
function reward_log(string $kind, int $uid, int $amount, string $reason = ''): void
{
}

/** Add Petals to one gnome. False (and nothing done) if $amount <= 0. */
function give_petals(int $uid, int $amount, string $reason = ''): bool
{
    if ($amount <= 0) return false;
    $ok = q('UPDATE users SET coins = coins + ? WHERE id = ?', [$amount, $uid])->rowCount() === 1;
    if ($ok) reward_log('petals_in', $uid, $amount, $reason);
    return $ok;
}

/** Take Petals only if the gnome has them (conditional UPDATE = the claim). False if $amount <= 0 or not enough. */
function take_petals(int $uid, int $amount, string $reason = ''): bool
{
    if ($amount <= 0) return false;
    $ok = q('UPDATE users SET coins = coins - ? WHERE id = ? AND coins >= ?', [$amount, $uid, $amount])->rowCount() === 1;
    if ($ok) reward_log('petals_out', $uid, $amount, $reason);
    return $ok;
}

/** Thin alias for add_xp() (unchanged). */
function give_xp(int $uid, int $n, string $source = ''): ?int
{
    return add_xp($uid, $n, $source !== '' ? $source : (string)(debug_backtrace(DEBUG_BACKTRACE_IGNORE_ARGS, 2)[1]['function'] ?? 'other'));
}
