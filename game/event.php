<?php
declare(strict_types=1);
// Finishes a random event that needed a click or a choice (v0.7.19).
require __DIR__ . '/includes/bootstrap.php';
require_once __DIR__ . '/includes/garden_logic.php';
require_once __DIR__ . '/includes/events.php';
$u = require_login();
if (!is_post()) redirect('index.php');
csrf_check();
[$ok, $msg] = finish_event($u, (string)($_POST['token'] ?? ''), (string)($_POST['choice'] ?? ''));
if (!$ok) flash($msg, 'err');
redirect(safe_back('index.php'));
