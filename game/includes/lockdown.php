<?php
declare(strict_types=1);
/**
 * Private test site (test.gnomeventure.ca): lockdown + single sign-on from the main site.
 *
 * The same code runs on both sites. What a copy does is set in two places:
 *  - main site (gnomeventure.ca): Game settings sso_secret (blank = off: sso_issue.php is a 404) and sso_targets (allowed test hosts).
 *    sso_issue.php gives a logged-in admin a short-lived signed token and sends the browser to https://<target>/mainlogin.php?t=<token>.
 *  - test site: config.php keys written by install.php: 'lockdown' => 'sso' | 'admin', 'lockdown_email', 'sso_secret', 'sso_main'.
 *    lockdown_gate() (called from bootstrap right after the current user is loaded, never on the command line) lets nobody but the
 *    admin with lockdown_email past login.php / mainlogin.php / logout.php. mainlogin.php checks the token and logs that admin in.
 *
 * Token: base64url(JSON payload) . '.' . base64url(HMAC-SHA256(base64url(JSON payload), secret)).
 * Payload: {v:1, email, username, nonce (16 random bytes, hex), iat, exp = iat + 60, aud = the target host}.
 */

const SSO_TTL = 60;           // seconds a token lives
const SSO_SKEW = 30;          // clock difference allowed between the two servers
const SSO_MIN_SECRET = 32;    // a shorter secret counts as not set
const LOCKDOWN_OPEN_PAGES = ['mainlogin.php', 'login.php', 'logout.php'];
const LOCKDOWN_404_PAGES = ['register.php', 'guest.php', 'forgot.php', 'reset.php', 'verify.php'];
const LOCKDOWN_ROBOTS = "# Private test site: nothing here is for search engines.\nUser-agent: *\nDisallow: /\n";

/** config.php as loaded by bootstrap (or the given array in tests). */
function lockdown_conf(?array $conf = null): array
{
    return $conf ?? (is_array($GLOBALS['CONFIG'] ?? null) ? $GLOBALS['CONFIG'] : []);
}

/** 'sso', 'admin' or '' (no lockdown: a normal site). */
function lockdown_mode(?array $conf = null): string
{
    $m = (string)(lockdown_conf($conf)['lockdown'] ?? '');
    return in_array($m, ['sso', 'admin'], true) ? $m : '';
}

function lockdown_email(?array $conf = null): string
{
    return strtolower(trim((string)(lockdown_conf($conf)['lockdown_email'] ?? '')));
}

/** The one account allowed on a locked-down site: an admin whose email is lockdown_email. */
function lockdown_user_ok(?array $u, ?array $conf = null): bool
{
    $want = lockdown_email($conf);
    return $u !== null && $want !== '' && ($u['role'] ?? '') === 'admin' && strtolower(trim((string)($u['email'] ?? ''))) === $want;
}

/** The request host, lower case, without a port ('' when it does not look like a host name). */
function sso_host(?string $h = null): string
{
    $h = strtolower(trim((string)($h ?? ($_SERVER['HTTP_HOST'] ?? ''))));
    $h = (string)preg_replace('/:\d+$/', '', $h);
    return preg_match('/^[a-z0-9.\-]{1,253}$/', $h) ? $h : '';
}

/** The page this request runs, relative to the game folder ('login.php', 'admin/index.php'). */
function lockdown_page(): string
{
    $s = str_replace('\\', '/', (string)($_SERVER['SCRIPT_NAME'] ?? ''));
    $bp = function_exists('app_base_path') ? app_base_path() : '';
    if ($bp !== '' && str_starts_with($s, $bp . '/')) $s = substr($s, strlen($bp));
    return ltrim($s, '/');
}

/**
 * Called from bootstrap after load_current_user(). No lockdown in config.php (the live site): returns at once, nothing changes.
 * With lockdown: noindex header on every response, robots.txt kept at "Disallow: /", the sign-up/guest/password pages are a 404,
 * and anyone but the lockdown admin is signed out and sent to login.php (GET) or given a 403 (POST, ajax).
 */
function lockdown_gate(): void
{
    if (PHP_SAPI === 'cli' || lockdown_mode() === '') return;
    if (!headers_sent()) {
        header('X-Robots-Tag: noindex, nofollow, noarchive');
        header('Cache-Control: private, no-store');
    }
    lockdown_robots();
    $u = current_user();
    if (lockdown_user_ok($u)) return;
    if ($u !== null) {   // a session for any other account (made before the lockdown, or by hand): not here
        unset($_SESSION['uid'], $_SESSION['sv']);
        $GLOBALS['CURRENT_USER'] = null;
    }
    $page = lockdown_page();
    if (in_array($page, LOCKDOWN_OPEN_PAGES, true)) return;
    if (in_array($page, LOCKDOWN_404_PAGES, true)) {
        http_response_code(404);
        exit('Not found.');
    }
    $ajax = (($_SERVER['HTTP_X_REQUESTED_WITH'] ?? '') !== '') || stripos((string)($_SERVER['HTTP_ACCEPT'] ?? ''), 'application/json') !== false;
    if (($_SERVER['REQUEST_METHOD'] ?? 'GET') !== 'GET' || $ajax) {
        http_response_code(403);
        exit('This is a private test site.');
    }
    header('Location: ' . url('login.php'), true, 302);
    exit;
}

/** robots.txt is a plain file, and a web update would put the public one back: keep it at "Disallow: /" while locked down. */
function lockdown_robots(): void
{
    $f = APP_ROOT . '/robots.txt';
    if ((string)@file_get_contents($f) !== LOCKDOWN_ROBOTS) @file_put_contents($f, LOCKDOWN_ROBOTS, LOCK_EX);
}

// ======================= Tokens =======================

function sso_b64u(string $bin): string
{
    return rtrim(strtr(base64_encode($bin), '+/', '-_'), '=');
}

function sso_b64u_dec(string $s): ?string
{
    if ($s === '' || !preg_match('/^[A-Za-z0-9_-]+$/', $s)) return null;
    $d = base64_decode(strtr($s, '-_', '+/'), true);
    return $d === false ? null : $d;
}

function sso_secret_ok(string $secret): bool
{
    return strlen($secret) >= SSO_MIN_SECRET;
}

/** The payload the main site signs for this admin and target host. */
function sso_payload(array $u, string $aud, ?int $now = null): array
{
    $now ??= time();
    return ['v' => 1, 'email' => strtolower(trim((string)$u['email'])), 'username' => (string)$u['username'],
        'nonce' => bin2hex(random_bytes(16)), 'iat' => $now, 'exp' => $now + SSO_TTL, 'aud' => $aud];
}

function sso_sign(array $payload, string $secret): string
{
    $p = sso_b64u(json_encode($payload, JSON_UNESCAPED_SLASHES | JSON_UNESCAPED_UNICODE));
    return $p . '.' . sso_b64u(hash_hmac('sha256', $p, $secret, true));
}

/** Main site: the allowed target hosts (Game settings sso_targets, comma separated). */
function sso_targets(?string $list = null): array
{
    $out = [];
    foreach (explode(',', (string)($list ?? setting('sso_targets'))) as $h) {
        $h = sso_host($h);
        if ($h !== '') $out[] = $h;
    }
    return array_values(array_unique($out));
}

/** Main site: the target host for ?to= (must be on the list; blank = the first). null = refused. */
function sso_pick_target(string $to, array $targets): ?string
{
    if (!$targets) return null;
    if (trim($to) === '') return $targets[0];
    $h = sso_host($to);
    return ($h !== '' && in_array($h, $targets, true)) ? $h : null;
}

/**
 * Test site: check a token. Returns [payload, ''] when good, else [null, reason] (the reason is for the error log only, never shown).
 * Does not use up the nonce: see sso_nonce_claim().
 */
function sso_verify(string $token, string $secret, string $host, string $email, ?int $now = null): array
{
    $now ??= time();
    if (!sso_secret_ok($secret)) return [null, 'no secret'];
    if ($token === '' || strlen($token) > 2048 || substr_count($token, '.') !== 1) return [null, 'malformed'];
    [$p64, $s64] = explode('.', $token);
    $sig = sso_b64u_dec($s64);
    if ($sig === null || !hash_equals(hash_hmac('sha256', $p64, $secret, true), $sig)) return [null, 'bad signature'];
    $json = sso_b64u_dec($p64);
    $p = $json === null ? null : json_decode($json, true);
    if (!is_array($p) || ($p['v'] ?? null) !== 1) return [null, 'bad payload'];
    foreach (['email', 'username', 'nonce', 'aud'] as $k) if (!is_string($p[$k] ?? null)) return [null, 'bad payload'];
    foreach (['iat', 'exp'] as $k) if (!is_int($p[$k] ?? null)) return [null, 'bad payload'];
    if (!preg_match('/^[0-9a-f]{32}$/', $p['nonce'])) return [null, 'bad nonce'];
    if ($p['exp'] <= $p['iat'] || $p['exp'] - $p['iat'] > 2 * SSO_TTL) return [null, 'bad lifetime'];
    if ($p['iat'] > $now + SSO_SKEW) return [null, 'issued in the future'];
    if ($p['exp'] < $now - SSO_SKEW) return [null, 'expired'];
    if ($host === '' || !hash_equals(sso_host($host), sso_host($p['aud']))) return [null, 'wrong audience'];
    $email = strtolower(trim($email));
    if ($email === '' || strtolower(trim($p['email'])) !== $email) return [null, 'wrong email'];
    return [$p, ''];
}

/** Test site: use up a token's nonce. False when it was already used (a replay). Kept as settings rows until well after expiry. */
function sso_nonce_claim(string $nonce, int $exp, ?int $now = null): bool
{
    $now ??= time();
    foreach (q("SELECT name, value FROM settings WHERE name LIKE 'sso!_nonce!_%' ESCAPE '!'")->fetchAll() as $r) {
        if ((int)$r['value'] < $now) q('DELETE FROM settings WHERE name = ?', [$r['name']]);
    }
    try {
        db_insert('settings', ['name' => 'sso_nonce_' . $nonce, 'value' => (string)($exp + SSO_SKEW + 60)]);
    } catch (PDOException $e) {
        return false;   // the primary key says: seen before
    }
    return true;
}

/**
 * Test site: the local admin for a checked payload. The first sign-on makes the account (role admin, a random password nobody knows,
 * email confirmed). An existing account with that email that is not an admin is refused. Returns [user, ''] or [null, reason].
 */
function sso_local_admin(array $p): array
{
    $email = strtolower(trim((string)$p['email']));
    $u = q_one('SELECT * FROM users WHERE LOWER(email) = ? ORDER BY id LIMIT 1', [$email]);
    if ($u) return ($u['role'] ?? '') === 'admin' ? [$u, ''] : [null, 'account with that email is not an admin'];
    $base = preg_match('/^[A-Za-z0-9_]{3,20}$/', (string)$p['username']) ? (string)$p['username'] : 'admin';
    $name = $base;
    for ($i = 2; q_val('SELECT 1 FROM users WHERE LOWER(username) = ?', [strtolower($name)]); $i++) $name = substr($base, 0, 16) . $i;
    $uid = db_insert('users', [
        'username' => $name, 'email' => $email, 'password_hash' => password_hash(bin2hex(random_bytes(32)), PASSWORD_DEFAULT),
        'role' => 'admin', 'coins' => (int)setting('starting_coins'), 'created_at' => now(), 'onboarded' => 0, 'email_verified_at' => now(),
    ]);
    return [q_one('SELECT * FROM users WHERE id = ?', [$uid]), ''];
}

/**
 * Test site: the whole check for mainlogin.php, without sending anything. $conf = config.php. Returns [user, ''] or [null, reason].
 * The caller logs the user in (log_in_user) and redirects.
 */
function sso_accept(string $token, string $host, ?array $conf = null, ?int $now = null): array
{
    $c = lockdown_conf($conf);
    if (lockdown_mode($c) !== 'sso') return [null, 'not an sso site'];
    [$p, $why] = sso_verify($token, (string)($c['sso_secret'] ?? ''), $host, lockdown_email($c), $now);
    if ($p === null) return [null, $why];
    if (!sso_nonce_claim($p['nonce'], $p['exp'], $now)) return [null, 'replayed nonce'];
    [$u, $why] = sso_local_admin($p);
    if ($u === null) return [null, $why];
    if ((int)($u['banned'] ?? 0) === 1) return [null, 'account banned'];
    return [$u, ''];
}
