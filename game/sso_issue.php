<?php
declare(strict_types=1);
/**
 * Main site (gnomeventure.ca): "Sign in with gnomeventure.ca" for the private test site (includes/lockdown.php).
 * A logged-in admin gets a signed token that lives 60 seconds and is sent on to https://<target>/sso.php?t=<token>.
 * Off (a 404) until Game settings sso_secret is set. ?to= must be one of Game settings sso_targets (never an open redirect).
 */
define('ALLOW_DURING_MAINTENANCE', true);   // admins still get through while the main site is closed for tending
require __DIR__ . '/includes/bootstrap.php';
require_once __DIR__ . '/includes/lockdown.php';

header('Cache-Control: no-store');
$secret = (string)setting('sso_secret');
if (!sso_secret_ok($secret)) {
    http_response_code(404);
    exit('Not found.');
}
$u = current_user();
if (!$u || ($u['role'] ?? '') !== 'admin') {
    http_response_code(403);
    exit('Not available.');
}
$target = sso_pick_target((string)($_GET['to'] ?? ''), sso_targets());
if ($target === null) {
    http_response_code(400);
    exit('Not available.');
}
header('Location: https://' . $target . '/sso.php?t=' . sso_sign(sso_payload($u, $target), $secret), true, 302);
exit;
