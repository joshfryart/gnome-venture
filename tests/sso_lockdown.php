<?php
// Private test site lockdown + SSO from the main site (includes/lockdown.php): tokens are built with the same helpers sso_issue.php uses and
// checked with sso_accept() (what mainlogin.php runs) against a test-site config array, so one install plays both sites.
// Valid token logs in (and makes the admin on first sign-on); wrong signature, expired, future, wrong aud, wrong email, replay, tampering,
// non-admin account and open-redirect targets are all refused. Run by sso_lockdown.sh on a walk.sh install: php tests/sso_lockdown.php GAME
$_SERVER['SCRIPT_NAME'] = '/index.php';
require $argv[1] . '/includes/bootstrap.php';
require_once APP_ROOT . '/includes/lockdown.php';
$fails = 0;
function ok(string $what, bool $cond, string $extra = ''): void { global $fails; echo ($cond ? 'ok   ' : 'FAIL ') . $what . ($cond ? '' : "  ($extra)") . "\n"; if (!$cond) $fails++; }

echo "== main site defaults: nothing changes until the secret is set\n";
ok('sso_secret defaults to blank', setting('sso_secret') === '' && (settings_schema()['sso_secret']['type'] ?? '') === 'secret');
ok('sso_targets defaults to test.gnomeventure.ca', sso_targets() === ['test.gnomeventure.ca'], json_encode(sso_targets()));
ok('no lockdown on this (normal) install', lockdown_mode() === '' && empty($CONFIG['lockdown']));
ok('a short secret counts as not set', !sso_secret_ok('short') && !sso_secret_ok('') && sso_secret_ok(str_repeat('a', 32)));
ok('lockdown_gate does nothing on the command line', (function () { lockdown_gate(); return true; })());

echo "== target host: never an open redirect\n";
$T = sso_targets('test.gnomeventure.ca, other-test.example.org');
ok('blank ?to= = the first target', sso_pick_target('', $T) === 'test.gnomeventure.ca');
ok('a listed host (any case, any port)', sso_pick_target('TEST.gnomeventure.ca', $T) === 'test.gnomeventure.ca' && sso_pick_target('other-test.example.org:443', $T) === 'other-test.example.org');
foreach (['evil.com', 'test.gnomeventure.ca.evil.com', 'evil.com/test.gnomeventure.ca', '//evil.com', 'https://test.gnomeventure.ca', 'test.gnomeventure.ca@evil.com', "test.gnomeventure.ca\r\nX: y"] as $bad)
    ok('refused target ' . json_encode($bad), sso_pick_target($bad, $T) === null);
ok('no targets at all = refused', sso_pick_target('', []) === null);

echo "== test site: sso_accept\n";
$S = bin2hex(random_bytes(24));
$admin = q_one("SELECT * FROM users WHERE username = 'admin'");
$sprout = q_one("SELECT * FROM users WHERE username = 'sprout'");
ok('walk.sh made admin and sprout', $admin && $sprout && $admin['role'] === 'admin');
$conf = ['lockdown' => 'sso', 'lockdown_email' => strtoupper((string)$admin['email']), 'sso_secret' => $S, 'sso_main' => 'https://gnomeventure.ca'];
$host = 'test.gnomeventure.ca';
$tok = fn(array $u, array $over = [], ?string $secret = null) => sso_sign(array_merge(sso_payload($u, $host), $over), $secret ?? $S);

$t = $tok($admin);
[$u, $why] = sso_accept($t, $host, $conf);
ok('a valid token logs in the local admin', $u !== null && (int)$u['id'] === (int)$admin['id'], $why);
[$u, $why] = sso_accept($t, $host, $conf);
ok('the same token again (replayed nonce) is refused', $u === null && $why === 'replayed nonce', $why);
$p = json_decode((string)sso_b64u_dec(explode('.', $t)[0]), true);
ok('payload has v, email, username, nonce, iat, exp = iat + 60, aud', $p['v'] === 1 && $p['email'] === strtolower((string)$admin['email']) && $p['username'] === 'admin'
    && preg_match('/^[0-9a-f]{32}$/', $p['nonce']) && $p['exp'] === $p['iat'] + 60 && $p['aud'] === $host, json_encode($p));

$cases = [
    'wrong signature (other secret)' => [$tok($admin, [], bin2hex(random_bytes(24))), 'bad signature'],
    'expired (issued 5 minutes ago)' => [$tok($admin, ['iat' => time() - 300, 'exp' => time() - 240]), 'expired'],
    'issued in the future' => [$tok($admin, ['iat' => time() + 600, 'exp' => time() + 660]), 'issued in the future'],
    'a lifetime longer than allowed' => [$tok($admin, ['exp' => time() + 86400]), 'bad lifetime'],
    'wrong aud (another host)' => [$tok($admin, ['aud' => 'gnomeventure.ca']), 'wrong audience'],
    'wrong email (another admin)' => [$tok(['email' => 'someone@else.local', 'username' => 'admin'] + $admin), 'wrong email'],
    'bad nonce' => [$tok($admin, ['nonce' => 'xyz']), 'bad nonce'],
    'version 2' => [$tok($admin, ['v' => 2]), 'bad payload'],
    'malformed' => ['not-a-token', 'malformed'],
    'empty' => ['', 'malformed'],
];
foreach ($cases as $what => [$tk, $want]) {
    [$u, $why] = sso_accept($tk, $host, $conf);
    ok("refused: $what", $u === null && $why === $want, $why);
}
// tampered payload: change the email but keep the old signature
[$p64, $s64] = explode('.', $tok($admin));
$pl = json_decode((string)sso_b64u_dec($p64), true); $pl['email'] = 'x@evil.local';
[$u, $why] = sso_accept(sso_b64u(json_encode($pl)) . '.' . $s64, $host, $conf);
ok('refused: payload changed after signing', $u === null && $why === 'bad signature', $why);
// clock skew of 30 s is allowed
[$u, $why] = sso_accept($tok($admin, ['iat' => time() - 80, 'exp' => time() - 20]), $host, $conf);
ok('a token 20 s past exp is still taken (30 s clock skew)', $u !== null, $why);
[$u, $why] = sso_accept($tok($admin), 'TEST.gnomeventure.ca:443', $conf);
ok('aud check ignores case and port of the request host', $u !== null, $why);
[$u, $why] = sso_accept($tok($admin), $host, ['lockdown' => 'admin'] + $conf);
ok('refused on a site in admin (password) lockdown', $u === null, $why);
[$u, $why] = sso_accept($tok($admin), $host, ['sso_secret' => 'short'] + $conf);
ok('refused with a short secret on the test site', $u === null, $why);

echo "== first sign-on makes the admin; a non-admin account is refused\n";
$fresh = ['email' => 'Boss@Main.Local', 'username' => 'sprout'];   // username taken locally: a free one is picked
$confB = ['lockdown_email' => 'boss@main.local'] + $conf;
ok('no local account with that email yet', !q_val('SELECT 1 FROM users WHERE LOWER(email) = ?', ['boss@main.local']));
[$u, $why] = sso_accept(sso_sign(sso_payload($fresh, $host), $S), $host, $confB);
ok('first SSO makes the local admin', $u !== null && $u['role'] === 'admin' && $u['email'] === 'boss@main.local' && (int)$u['onboarded'] === 0 && !empty($u['email_verified_at']), $why . ' ' . json_encode($u ? array_intersect_key($u, array_flip(['username', 'role', 'email'])) : null));
ok('...with a free username (sprout was taken)', $u && $u['username'] !== 'sprout' && str_starts_with((string)$u['username'], 'sprout'), (string)($u['username'] ?? ''));
ok('...and an unusable random password', $u && !password_verify('', (string)$u['password_hash']) && !password_verify('admin', (string)$u['password_hash']));
ok('the new admin passes lockdown_user_ok', $u && lockdown_user_ok($u, $confB) && !lockdown_user_ok($admin, $confB));
[$u2, $why] = sso_accept(sso_sign(sso_payload($fresh, $host), $S), $host, $confB);
ok('a second SSO logs in the same account (no duplicate)', $u2 && (int)$u2['id'] === (int)$u['id'] && (int)q_val('SELECT COUNT(*) FROM users WHERE LOWER(email) = ?', ['boss@main.local']) === 1, $why);
q('DELETE FROM users WHERE id = ?', [(int)$u['id']]);
$confS = ['lockdown_email' => (string)$sprout['email']] + $conf;
[$u, $why] = sso_accept(sso_sign(sso_payload($sprout, $host), $S), $host, $confS);
ok('a token for a local player (not admin) is refused', $u === null && $why === 'account with that email is not an admin', $why);
ok('lockdown_user_ok: player, anonymous and a blank email are refused', !lockdown_user_ok($sprout, $confS) && !lockdown_user_ok(null, $conf) && !lockdown_user_ok($admin, ['lockdown_email' => ''] + $conf));

echo "== nonces are tidied away\n";
db_insert('settings', ['name' => 'sso_nonce_' . str_repeat('0', 32), 'value' => (string)(time() - 10)]);
sso_nonce_claim(bin2hex(random_bytes(16)), time() + 60);
ok('expired nonce rows are deleted', !q_val('SELECT 1 FROM settings WHERE name = ?', ['sso_nonce_' . str_repeat('0', 32)]));

echo $fails ? "$fails FAILED\n" : "all ok\n";
exit($fails ? 1 : 0);
