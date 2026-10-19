<?php
declare(strict_types=1);
/**
 * Opt-in reminder emails (v1.7, CASL): only verified, opted-in, not-banned players. Every email names the sender and has a one-click unsubscribe.
 * mail_nudge_tick() is cheap to call on any page: at most once an hour site-wide it sends a few emails.
 */

/** Admin settings for the reminders (add to settings_schema()). */
require_once __DIR__ . '/account.php';

function nudge_settings(): array
{
    return [
        'nudges_on'         => ['label' => 'Reminder emails: master switch (players only get them if they opted in)', 'type' => 'bool', 'default' => '1'],
        'nudge_per_tick'    => ['label' => 'Reminder emails: most sent per hour, whole site', 'type' => 'int', 'default' => '20', 'min' => 0, 'max' => 500],
        'nudge_gap_days'    => ['label' => 'Reminder emails: days between emails to the same player', 'type' => 'int', 'default' => '3', 'min' => 1, 'max' => 60],
        'nudge_ready_hours' => ['label' => 'Reminder emails: hours away before a crops-ready email', 'type' => 'int', 'default' => '12', 'min' => 1, 'max' => 720],
        'nudge_away_days'   => ['label' => 'Reminder emails: days away before the we-miss-you email', 'type' => 'int', 'default' => '3', 'min' => 1, 'max' => 365],
        'mail_address'      => ['label' => 'Reminder emails: postal address shown in them (CASL needs a mailing address)', 'type' => 'text', 'default' => ''],
    ];
}

/** A setting with its default, even if settings_schema() has not been given nudge_settings() yet. */
function nudge_set(string $k): string
{
    $v = setting($k);
    return $v !== '' ? $v : (string)(nudge_settings()[$k]['default'] ?? '');
}

/** Secret for unsubscribe links: made once, kept in the settings table (not shown in Game settings). */
function nudge_secret(): string
{
    $s = (string)q_val("SELECT value FROM settings WHERE name = 'nudge_secret'");
    if ($s === '') {
        try { q('INSERT INTO settings (name, value) VALUES (?, ?)', ['nudge_secret', bin2hex(random_bytes(24))]); } catch (Throwable $e) {}
        $s = (string)q_val("SELECT value FROM settings WHERE name = 'nudge_secret'");
    }
    return $s;
}

function nudge_token(int $uid): string
{
    return hash_hmac('sha256', 'unsub|' . $uid, nudge_secret());
}

function nudge_unsub_url(int $uid): string
{
    return site_url() . url('unsub.php?u=' . $uid . '&t=' . nudge_token($uid));
}

/** Is any crop on the player's active garden ready now (counting growth since the last save)? */
function nudge_crops_ready(int $uid, int $plotId): bool
{
    if ($plotId <= 0) return false;
    if (!function_exists('tile_grow')) require_once __DIR__ . '/garden_logic.php';
    $rows = q('SELECT t.*, p.grow_minutes AS p_grow, p.id AS p_id FROM plot_tiles t JOIN plants p ON p.id = t.plant_id WHERE t.plot_id = ? AND p.kind <> \'cover\'', [$plotId])->fetchAll();
    foreach ($rows as $t) {
        if ((int)$t['growth_seconds'] >= (int)$t['p_grow'] * 60) return true;
        try {
            $p = q_one('SELECT * FROM plants WHERE id = ?', [(int)$t['p_id']]);
            if ($p && (int)tile_grow($t, $p)['growth_seconds'] >= (int)$p['grow_minutes'] * 60) return true;
        } catch (Throwable $e) {}
    }
    return false;
}

function nudge_send(array $u, string $kind): bool
{
    $site = setting('site_name');
    $unsub = nudge_unsub_url((int)$u['id']);
    $name = (string)($u['gnome_name'] ?: $u['username']);
    $what = $kind === 'ready'
        ? "Some of the crops in your garden are ready to harvest."
        : "Your garden misses you. Come back whenever you like.";
    $body = "Hello $name,\n\n$what\n\n" . site_url() . url('garden.php') . "\n\n--\n"
        . "You get this because you asked for reminders from $site (" . site_url() . "). "
        . (nudge_set('mail_address') !== '' ? "Sent by $site, " . mail_clean(nudge_set('mail_address')) . ".\n" : "Sent by $site.\n")
        . "Stop these emails with one click: $unsub\n";
    return send_mail((string)$u['email'], $kind === 'ready' ? 'Your crops are ready' : 'Your garden misses you', $body, [
        'List-Unsubscribe' => '<' . $unsub . '>', 'List-Unsubscribe-Post' => 'List-Unsubscribe=One-Click',
    ]);
}

function mail_nudge_tick(): void
{
    try {
        if (nudge_set('nudges_on') !== '1') return;
        if (trim((string)nudge_set('mail_address')) === '') return;   // v1.6.8: CASL needs a mailing address in every reminder; none set = no reminders
        // Claim the hour: a conditional UPDATE only one request can win.
        $stamp = gmdate('Y-m-d H:i:s');
        $old = gmdate('Y-m-d H:i:s', time() - 3600);
        if (!q_val("SELECT 1 FROM settings WHERE name = 'nudge_last_tick'")) {
            try { q('INSERT INTO settings (name, value) VALUES (?, ?)', ['nudge_last_tick', '2000-01-01 00:00:00']); } catch (Throwable $e) {}
        }
        if (q("UPDATE settings SET value = ? WHERE name = 'nudge_last_tick' AND value < ?", [$stamp, $old])->rowCount() !== 1) return;

        $max = max(0, (int)nudge_set('nudge_per_tick'));
        if ($max === 0) return;
        $gap = gmdate('Y-m-d H:i:s', time() - max(1, (int)nudge_set('nudge_gap_days')) * 86400);
        $readyCut = gmdate('Y-m-d H:i:s', time() - max(1, (int)nudge_set('nudge_ready_hours')) * 3600);
        $awayCut = gmdate('Y-m-d H:i:s', time() - max(1, (int)nudge_set('nudge_away_days')) * 86400);
        $sent = 0;
        $rows = q('SELECT * FROM users WHERE email_nudges = 1 AND email_verified_at IS NOT NULL AND banned = 0 AND deleted_at IS NULL AND onboarded = 1
                   AND last_seen IS NOT NULL AND last_seen < ? AND (last_nudge_at IS NULL OR last_nudge_at < ?) ORDER BY last_nudge_at LIMIT 200',
            [$readyCut, $gap])->fetchAll();
        foreach ($rows as $u) {
            if ($sent >= $max) break;
            $kind = '';
            if (nudge_crops_ready((int)$u['id'], (int)($u['active_plot_id'] ?? 0))) $kind = 'ready';
            elseif ($u['last_seen'] < $awayCut && (string)$u['nudge_away_seen'] !== (string)$u['last_seen']) $kind = 'away';
            if ($kind === '') continue;
            // Claim this player first so a second request can not email them too.
            if (q('UPDATE users SET last_nudge_at = ?, nudge_away_seen = ? WHERE id = ? AND (last_nudge_at IS NULL OR last_nudge_at < ?) AND email_nudges = 1',
                [$stamp, $kind === 'away' ? $u['last_seen'] : $u['nudge_away_seen'], $u['id'], $gap])->rowCount() !== 1) continue;
            nudge_send($u, $kind);
            $sent++;
        }
    } catch (Throwable $e) {
        error_log('mail_nudge_tick: ' . $e->getMessage());
    }
}
