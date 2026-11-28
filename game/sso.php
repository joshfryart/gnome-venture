<?php
declare(strict_types=1);
/**
 * Private test site: the end of "Sign in with gnomeventure.ca" (includes/lockdown.php). Checks the token the main site's sso_issue.php
 * signed (signature, 60 s life, this host, the lockdown email, a nonce used only once), then logs in the local admin
 * (made on the first sign-on, with no password). Every failure looks the same and is written to the error log without the token.
 * A site that is not locked down in 'sso' mode answers 404.
 */
define('ALLOW_DURING_MAINTENANCE', true);
require __DIR__ . '/includes/bootstrap.php';
require_once __DIR__ . '/includes/lockdown.php';

header('Cache-Control: no-store');
if (lockdown_mode() !== 'sso' || !sso_secret_ok((string)($CONFIG['sso_secret'] ?? ''))) {
    http_response_code(404);
    exit('Not found.');
}

$why = 'too many tries';
$user = null;
if (!rate_limited('sso', 10, 15) && !rate_limited_all('sso', 60, 15)) {
    $t = $_GET['t'] ?? '';
    [$user, $why] = sso_accept(is_string($t) ? $t : '', sso_host());
}
if ($user) {
    clear_attempts('sso');
    log_in_user($user);
    redirect((int)($user['onboarded'] ?? 1) === 0 ? 'welcome.php' : 'gnome.php');
}

record_attempt('sso');
game_error_log('SSO sign-in refused: ' . $why . ' (from ' . client_ip() . ')');
http_response_code(403);
page_header('Sign-in did not work');
?>
<div class="box narrow">
  <h2>That sign-in did not work</h2>
  <p>The sign-in link may have expired or already been used. Go back to the sign-in page and press the button again.</p>
  <p><a class="btn" href="<?= e(url('login.php')) ?>">Back to sign in</a></p>
</div>
<?php page_footer();
