<?php
declare(strict_types=1);
require __DIR__ . '/includes/bootstrap.php';
$u = require_login();

if (is_post()) {
    csrf_check();
    if (($_POST['do'] ?? '') === 'skip') {
        tour_skip((int)$u['id']);
        flash('🐦 Wren tips her cap. “Off you go then! Your Almanac has the basics if you need them.”');
        flash(tour_energy_note((int)$u['id']));   // v1.6.2
    } elseif (in_array($_POST['do'] ?? '', ['start', 'later', 'nextstep'], true)) {
        tour_answer((int)$u['id'], (string)$_POST['do']);   // v2.4.97
    }
}
redirect('garden.php');
