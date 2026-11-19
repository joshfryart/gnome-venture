<?php
declare(strict_types=1);
// Sights sixth pass B: the POST target of the shared Sights forms (send a note, report a note or mark, put a note away). Logic: includes/trail_sights_6.php.
require __DIR__ . '/includes/bootstrap.php';
require_once __DIR__ . '/includes/items.php';
require_once __DIR__ . '/includes/trail_sights_6.php';
$u = require_login();
if (!is_post()) redirect('inventory.php');
csrf_check();
[$ok, $msg] = sights6_post($u, $_POST);
flash($msg, $ok ? 'ok' : 'err');
$back = is_scalar($_POST['back'] ?? null) ? (string)$_POST['back'] : '';
redirect(in_array($back, ['inventory.php', 'adventure.php'], true) ? $back : 'inventory.php');
