<?php
declare(strict_types=1);
/** v1.0.0 wave 3: ticks off the gentle daily card on Today. */
require __DIR__ . '/includes/bootstrap.php';
require_once __DIR__ . '/includes/welcome_back.php';
$u = require_login();
if (is_post()) {
    csrf_check();
    daily_tick($u);
}
redirect('index.php');
