<?php
declare(strict_types=1);
define('ALLOW_DURING_MAINTENANCE', true);
require __DIR__ . '/includes/bootstrap.php';

// Logout is POST + CSRF so other sites can't log players out with a hidden link.
if (is_post()) {
    csrf_check();
    $_SESSION = [];
    session_regenerate_id(true);
    session_destroy();
}
redirect('index.php');
