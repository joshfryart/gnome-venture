<?php
declare(strict_types=1);
/**
 * Accounts (v0.7.16): email, password resets, changing email/password, deleting an account, the privacy page.
 */

/** Strip CR/LF and control characters so a value can never add mail headers. */
function mail_clean(string $v): string
{
    return trim((string)preg_replace('/[\x00-\x1F\x7F]+/', ' ', $v));
}

/**
 * Send an email. Uses SMTP when config.php has smtp_host (plus smtp_port, smtp_user, smtp_pass, smtp_from), otherwise mail().
 * If sending fails (or on a PC) it's written to data/mail-log.txt instead, readable in Admin → Tools.
 * $extra: more header lines as [name => value] (e.g. List-Unsubscribe). Newlines are stripped from every header.
 */
function send_mail(string $to, string $subject, string $body, array $extra = []): bool
{
    $to = mail_clean($to); $subject = mail_clean($subject);
    $cfg = $GLOBALS['CONFIG'] ?? [];
    $smtp = !empty($cfg['smtp_host']);
    $from = mail_clean($smtp && !empty($cfg['smtp_from']) ? (string)$cfg['smtp_from'] : (setting('mail_from') ?: 'no-reply@' . preg_replace('/[^a-z0-9.-]/i', '', (string)parse_url(site_url(), PHP_URL_HOST) ?: 'localhost')));
    $from = preg_replace('/[<>"\s]/', '', $from);
    if (!filter_var($to, FILTER_VALIDATE_EMAIL)) return false;
    $h = ['From' => mail_clean(setting('site_name')) . ' <' . $from . '>', 'MIME-Version' => '1.0', 'Content-Type' => 'text/plain; charset=UTF-8'];
    foreach ($extra as $k => $v) $h[mail_clean((string)$k)] = mail_clean((string)$v);
    $subj = '=?UTF-8?B?' . base64_encode($subject) . '?=';
    $sent = false;
    if (setting('mail_mode') !== 'log') {
        if ($smtp) {
            $hdr = 'Date: ' . gmdate('r') . "\r\nTo: $to\r\nSubject: $subj\r\n";
            foreach ($h as $k => $v) $hdr .= "$k: $v\r\n";
            $sent = smtp_deliver($cfg, $from, $to, $hdr . "\r\n" . $body);
        }
        if (!$sent) {
            $hdr = '';
            foreach ($h as $k => $v) $hdr .= "$k: $v\r\n";
            $sent = @mail($to, $subj, $body, $hdr);
        }
    }
    if (!$sent) {
        @file_put_contents(APP_ROOT . '/data/mail-log.txt', '[' . now() . " UTC] To: $to\nSubject: $subject\n\n$body\n" . str_repeat('-', 60) . "\n", FILE_APPEND | LOCK_EX);
    }
    return $sent;
}

/** Minimal SMTP client: STARTTLS (port 587) or implicit TLS (port 465), AUTH LOGIN. Returns false on any problem. */
function smtp_deliver(array $cfg, string $from, string $to, string $message): bool
{
    $host = mail_clean((string)$cfg['smtp_host']); $port = (int)($cfg['smtp_port'] ?? 587) ?: 587;
    $fp = @stream_socket_client(($port === 465 ? 'ssl://' : 'tcp://') . $host . ':' . $port, $en, $es, 10);
    if (!$fp) return false;
    stream_set_timeout($fp, 10);
    $read = function () use ($fp): array {
        $code = 0; $all = '';
        while (($l = fgets($fp, 1024)) !== false) { $all .= $l; $code = (int)substr($l, 0, 3); if (strlen($l) < 4 || $l[3] !== '-') break; }
        return [$code, $all];
    };
    $cmd = function (string $c, array $ok) use ($fp, $read): bool {
        fwrite($fp, $c . "\r\n");
        return in_array($read()[0], $ok, true);
    };
    try {
        if ($read()[0] !== 220) return false;
        $ehlo = 'EHLO ' . (preg_replace('/[^a-z0-9.-]/i', '', (string)parse_url(site_url(), PHP_URL_HOST)) ?: 'localhost');
        if (!$cmd($ehlo, [250])) return false;
        if ($port !== 465) {
            if (!$cmd('STARTTLS', [220]) || !@stream_socket_enable_crypto($fp, true, STREAM_CRYPTO_METHOD_TLS_CLIENT)) return false;
            if (!$cmd($ehlo, [250])) return false;
        }
        if (!empty($cfg['smtp_user'])) {
            if (!$cmd('AUTH LOGIN', [334]) || !$cmd(base64_encode((string)$cfg['smtp_user']), [334]) || !$cmd(base64_encode((string)($cfg['smtp_pass'] ?? '')), [235])) return false;
        }
        if (!$cmd('MAIL FROM:<' . $from . '>', [250]) || !$cmd('RCPT TO:<' . $to . '>', [250, 251]) || !$cmd('DATA', [354])) return false;
        $msg = preg_replace('/\r\n|\r|\n/', "\r\n", $message);
        $msg = preg_replace('/^\./m', '..', $msg);
        fwrite($fp, $msg . "\r\n.\r\n");
        $ok = $read()[0] === 250;
        @fwrite($fp, "QUIT\r\n");
        return $ok;
    } finally {
        @fclose($fp);
    }
}

/** Email verification: mail a fresh 48-hour link (stored hashed). */
function send_verify_email(array $u): bool
{
    $token = bin2hex(random_bytes(32));
    q('UPDATE users SET verify_hash = ?, verify_expires = ? WHERE id = ?', [hash('sha256', $token), gmdate('Y-m-d H:i:s', time() + 48 * 3600), $u['id']]);
    $link = site_url() . url('verify.php?t=' . $token);
    return send_mail((string)$u['email'], 'Confirm your ' . setting('site_name') . ' email',
        "Hello " . $u['username'] . ",\n\nPlease confirm your email by opening this link within 48 hours:\n\n$link\n\n"
        . "If you did not sign up, ignore this email.\n\n" . setting('site_name'));
}

/** Confirm a verify token. Returns true if it matched an unexpired link. */
function verify_email_token(string $token): bool
{
    if (!preg_match('/^[a-f0-9]{64}$/', $token)) return false;
    $n = q('UPDATE users SET email_verified_at = ?, verify_hash = NULL, verify_expires = NULL WHERE verify_hash = ? AND verify_expires > ? AND deleted_at IS NULL',
        [now(), hash('sha256', $token), now()])->rowCount();
    return $n === 1;
}

/** The site's full address for links in emails. Set in Game settings; never taken from the visitor's request. */
function site_url(): string
{
    return rtrim(setting('site_url'), '/');
}

function request_password_reset(string $email): void
{
    $email = strtolower(trim($email));
    $u = q_one('SELECT id, username, email FROM users WHERE email = ? AND banned = 0', [$email]);
    if (!$u) {   // v1.2.2: an unknown email takes about as long as a known one (hash + a mail-sized pause)
        password_hash(bin2hex(random_bytes(8)), PASSWORD_DEFAULT);
        usleep(random_int(40000, 160000));
        return;   // same answer either way, so nobody can test which emails have accounts
    }
    $token = bin2hex(random_bytes(32));
    q('UPDATE password_resets SET used = 1 WHERE user_id = ? AND used = 0', [$u['id']]);
    db_insert('password_resets', ['user_id' => $u['id'], 'token_hash' => hash('sha256', $token),
        'expires_at' => gmdate('Y-m-d H:i:s', time() + 3600), 'used' => 0, 'created_at' => now()]);
    $link = (site_url() ?: '') . url('reset.php?token=' . $token);
    send_mail($u['email'], 'Reset your ' . setting('site_name') . ' password',
        "Hello " . $u['username'] . ",\n\nSomeone (hopefully you) asked to reset your password. Use this link within an hour:\n\n$link\n\n"
        . "If it wasn't you, ignore this email and nothing will change.\n");
}

/** The reset row for a token, if it's valid. */
function reset_lookup(string $token): ?array
{
    if (!preg_match('/^[a-f0-9]{64}$/', $token)) return null;
    $r = q_one('SELECT * FROM password_resets WHERE token_hash = ? AND used = 0 AND expires_at > ?', [hash('sha256', $token), now()]);
    return $r ?: null;
}

function do_password_reset(string $token, string $pass, string $pass2): array
{
    $r = reset_lookup($token);
    if (!$r) return [false, 'That link has expired or been used. Ask for a new one.'];
    if (strlen($pass) < 10) return [false, 'Your new password needs at least 10 characters.'];
    if ($pass !== $pass2) return [false, 'The passwords don’t match.'];
    db()->beginTransaction();
    if (q('UPDATE password_resets SET used = 1 WHERE id = ? AND used = 0', [$r['id']])->rowCount() !== 1) {
        db()->rollBack();
        return [false, 'That link has already been used.'];
    }
    q('UPDATE users SET password_hash = ?, sess_ver = sess_ver + 1 WHERE id = ?', [password_hash($pass, PASSWORD_DEFAULT), $r['user_id']]);   // v1.2.2: signs out every session
    db()->commit();
    return [true, 'Password changed. You can log in now.'];
}

function change_email(array $u, string $pass, string $email): array
{
    $email = strtolower(trim($email));
    if (!password_verify($pass, (string)q_val('SELECT password_hash FROM users WHERE id = ?', [$u['id']]))) return [false, 'Your current password isn’t right.'];
    if (!filter_var($email, FILTER_VALIDATE_EMAIL) || strlen($email) > 190) return [false, 'That email doesn’t look right.'];
    if (q_val('SELECT 1 FROM users WHERE email = ? AND id <> ?', [$email, $u['id']])) return [false, 'Another account uses that email.'];
    $old = (string)$u['email'];
    q('UPDATE users SET email = ?, email_verified_at = NULL, verify_hash = NULL, verify_expires = NULL, email_nudges = 0 WHERE id = ?', [$email, $u['id']]);   // v1.7: a new address must be verified again; reminders stop until re-confirmed
    send_mail($old, 'Your email was changed', 'The email on your ' . setting('site_name') . " account was changed to $email. If that wasn't you, contact the game's admin.");
    return [true, 'Email updated.'];
}

function change_password(array $u, string $current, string $pass, string $pass2): array
{
    if (!password_verify($current, (string)q_val('SELECT password_hash FROM users WHERE id = ?', [$u['id']]))) return [false, 'Your current password isn’t right.'];
    if (strlen($pass) < 10) return [false, 'Your new password needs at least 10 characters.'];
    if ($pass !== $pass2) return [false, 'The new passwords don’t match.'];
    q('UPDATE users SET password_hash = ?, sess_ver = sess_ver + 1 WHERE id = ?', [password_hash($pass, PASSWORD_DEFAULT), $u['id']]);   // v1.2.2: other sessions are signed out
    $_SESSION['sv'] = (int)q_val('SELECT sess_ver FROM users WHERE id = ?', [$u['id']]);   // this one stays
    session_regenerate_id(true);
    return [true, 'Password changed.'];
}

/**
 * Delete an account: everything that identifies the person is removed, open dealings with other players are
 * settled fairly (their held items and Petals go back to them), and the account can never log in again.
 * Game rows that only make sense as history (old harvests, scores) stay, attached to an anonymous gnome.
 */
function delete_account(array $u, string $pass, string $confirm): array
{
    $uid = (int)$u['id'];
    if ($u['role'] === 'admin') return [false, 'Admins can’t delete themselves here. Make another admin first, then change your role.'];
    if (!password_verify($pass, (string)q_val('SELECT password_hash FROM users WHERE id = ?', [$uid]))) return [false, 'Your password isn’t right.'];
    if (trim($confirm) !== 'DELETE') return [false, 'Type DELETE in capitals to confirm.'];
    require_once __DIR__ . '/trade.php';
    require_once __DIR__ . '/player_jobs.php';
    // Settle anything involving other players first
    foreach (q("SELECT * FROM trade_offers WHERE (from_id = ? OR to_id = ?) AND status = 'open'", [$uid, $uid])->fetchAll() as $o) {
        db()->beginTransaction();
        if (q("UPDATE trade_offers SET status = 'cancelled', closed_at = ? WHERE id = ? AND status = 'open'", [now(), $o['id']])->rowCount() === 1 && (int)$o['from_id'] !== $uid) {
            offer_refund($o);   // the other gnome gets their offer back
        }
        db()->commit();
    }
    foreach (q("SELECT * FROM player_jobs WHERE (poster_id = ? OR taker_id = ?) AND status IN ('open', 'taken')", [$uid, $uid])->fetchAll() as $pj) {
        if ((int)$pj['taker_id'] === $uid) {
            pjob_close($pj, 'abandoned');   // the poster gets the unearned wage back
        } else {
            q("UPDATE player_jobs SET status = 'cancelled', escrow = 0, closed_at = ? WHERE id = ?", [now(), $pj['id']]);
            if ($pj['user_job_id']) q("UPDATE user_jobs SET status = 'expired' WHERE id = ? AND status = 'active'", [$pj['user_job_id']]);
            if ($pj['taker_id'] && (int)$pj['escrow'] > 0) {
                q('UPDATE users SET coins = coins + ? WHERE id = ?', [(int)$pj['escrow'], $pj['taker_id']]);   // the worker keeps what was held
                notify((int)$pj['taker_id'], 'The gnome you were working for has left the Hollow. You’ve been paid the rest of the wage.');
            }
        }
    }
    db()->beginTransaction();
    q('UPDATE stall_listings SET qty = 0 WHERE seller_id = ?', [$uid]);
    q('DELETE FROM notices WHERE user_id = ?', [$uid]);
    try { q('UPDATE stop_adoptions SET user_id = NULL WHERE user_id = ?', [$uid]); } catch (Throwable $e) {}   // v1.0.0: a deleted gnome lets go of their stop
    foreach (['DELETE FROM player_friends WHERE user_id = ? OR friend_id = ?', 'DELETE FROM player_blocks WHERE blocker_id = ? OR blocked_id = ?',
              'DELETE FROM garden_stamps WHERE user_id = ?', 'DELETE FROM garden_reacts WHERE user_id = ? OR plot_id IN (SELECT id FROM plots WHERE user_id = ?)', 'DELETE FROM garden_waterings WHERE helper_id = ? OR plot_id IN (SELECT id FROM plots WHERE user_id = ?)', 'DELETE FROM pal_gift_days WHERE from_id = ? OR to_id = ?'] as $sql) {   // v1.0.0: no ghost friends, blocks or stamps
        try { q($sql, substr_count($sql, '?') === 2 ? [$uid, $uid] : [$uid]); } catch (Throwable $e) {}
    }
    // v1.2.2: names and text copies that outlive the account
    q('UPDATE plots SET garden_name = NULL WHERE user_id = ?', [$uid]);
    q('UPDATE users SET garden_public = 0 WHERE id = ?', [$uid]);
    try { q('UPDATE garden_critters SET name = kind WHERE plot_id IN (SELECT id FROM plots WHERE user_id = ?)', [$uid]); } catch (Throwable $e) {}
    q("UPDATE reports SET snapshot = '[removed]', details = '[removed]' WHERE target_id = ? OR reporter_id = ?", [$uid, $uid]);
    try { q("UPDATE user_jobs SET npc = 'A gnome', text = '[removed]' WHERE player_job_id IN (SELECT id FROM player_jobs WHERE poster_id = ?)", [$uid]); } catch (Throwable $e) {}
    q('DELETE FROM password_resets WHERE user_id = ?', [$uid]);
    q('DELETE FROM game_state WHERE user_id = ?', [$uid]);
    q('UPDATE gifts SET note = NULL WHERE from_id = ? OR to_id = ?', [$uid, $uid]);
    q('UPDATE trade_offers SET note = NULL WHERE from_id = ?', [$uid]);
    q('UPDATE player_jobs SET note = NULL WHERE poster_id = ?', [$uid]);
    q('UPDATE carvings SET title = ? WHERE user_id = ?', ['Untitled', $uid]);
    q("UPDATE users SET username = ?, email = ?, password_hash = ?, gnome_name = ?, title = NULL, banned = 1, ban_reason = 'Account deleted', town_spot_id = NULL,
       deleted_at = ? WHERE id = ?",
        ['gone_' . $uid, 'deleted-' . $uid . '@invalid', password_hash(bin2hex(random_bytes(16)), PASSWORD_DEFAULT), 'A gnome who moved away', now(), $uid]);
    db()->commit();
    return [true, 'Your account has been deleted. Goodbye, and thank you for gardening with us.'];
}

const PRIVACY_TEXT = "[h]What we keep[/h]\n"
    . "• Your log-in name, email address and a scrambled (hashed) copy of your password. We never see or store your actual password.\n"
    . "• Your game: your gnome, gardens, items, messages to other players and what you do in the game.\n"
    . "• For security, the internet address of recent log-in attempts, kept for about a day.\n\n"
    . "[h]What we use it for[/h]\nRunning the game, keeping it safe and fair, and sending you emails you ask for, like password resets. "
    . "We don’t sell your information, show adverts, or share it with anyone, except where the law requires it.\n\n"
    . "[h]Cookies[/h]\nOne cookie keeps you logged in. No tracking or advertising cookies.\n\n"
    . "[h]Your choices[/h]\nYou can change your email or password, or delete your account, any time from the Account page. "
    . "Deleting removes your name, email and anything that identifies you; old game history stays, attached to an anonymous gnome.\n\n"
    . "[h]Age[/h]\nYou must be 13 or older to play.\n\n"
    . "[h]Questions[/h]\nContact the game’s admin. This policy may change; we’ll post any changes here.";

function ensure_launch(): void
{
    // site_url is never seeded from the request's Host header (spoofable): the admin sets it in Game settings, and the admin page warns while it's empty
    if (!q_val("SELECT 1 FROM pages WHERE slug = 'privacy'")) {
        db_insert('pages', ['slug' => 'privacy', 'title' => 'Privacy', 'body' => PRIVACY_TEXT, 'published' => 1, 'show_in_nav' => 0, 'updated_at' => now()]);
    }
}
