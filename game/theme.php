<?php
declare(strict_types=1);
// v1.6.5: saves the dark/light choice (users.theme, or a cookie when logged out), then goes back. POST + CSRF.
define('ALLOW_DURING_MAINTENANCE', true);
require __DIR__ . '/includes/bootstrap.php';
require_once __DIR__ . '/includes/theme.php';

if (!is_post()) redirect('index.php');
csrf_check();
$t = theme_clean((string)($_POST['theme'] ?? ''));
if ($t === '') {
    http_response_code(400);
    exit('Unknown theme.');
}
theme_save($t);
if (($_POST['ajax'] ?? '') === '1') {   // the page already flipped itself
    http_response_code(204);
    exit;
}
redirect(theme_clean_back((string)($_POST['back'] ?? '')));
