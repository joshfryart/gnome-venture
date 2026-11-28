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
// The token goes in a POST body, not the address: some hosts' firewalls reset long query strings. This page posts it on to the test site;
// the Content-Security-Policy is widened to that one host only (form-action) and sso_go.js (same origin) submits the form for you.
$tok = sso_sign(sso_payload($u, $target), $secret);
header("Content-Security-Policy: default-src 'none'; style-src 'unsafe-inline'; script-src 'self'; form-action https://" . $target . "; base-uri 'none'; frame-ancestors 'none'");
header('Referrer-Policy: no-referrer');
?><!doctype html>
<html lang="en"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width, initial-scale=1"><meta name="robots" content="noindex"><title>Signing in</title>
<style>body{font:16px/1.5 system-ui,sans-serif;max-width:30em;margin:3em auto;padding:0 1em}button{font:inherit;padding:.5em 1em}</style></head>
<body><h1>Signing you in</h1>
<form id="sso" method="post" action="https://<?= htmlspecialchars($target, ENT_QUOTES) ?>/sso.php">
<input type="hidden" name="t" value="<?= htmlspecialchars($tok, ENT_QUOTES) ?>">
<p>Taking you to <?= htmlspecialchars($target, ENT_QUOTES) ?>. If nothing happens, press the button.</p>
<button type="submit">Continue to <?= htmlspecialchars($target, ENT_QUOTES) ?></button>
</form>
<script src="sso_go.js"></script>
</body></html>
