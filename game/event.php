<?php
declare(strict_types=1);
// Finishes a random event that needed a click or a choice (v0.7.19).
require __DIR__ . '/includes/bootstrap.php';
require_once __DIR__ . '/includes/garden_logic.php';
require_once __DIR__ . '/includes/events.php';
$u = require_login();
if (!is_post()) redirect('index.php');
csrf_check();
if (($_SESSION['event_pending']['slug'] ?? '') === 'ppal') {   // v2.0.88: a Puzzle Pal find needs the feature open and a real gnome (not a guest)
    require_once __DIR__ . '/includes/puzzle_pals.php';
    if (!ppal_open() || is_guest($u)) { unset($_SESSION['event_pending']); http_response_code(403); exit('Puzzle Pals are not open.'); }
}
[$ok, $msg] = finish_event($u, (string)($_POST['token'] ?? ''), (string)($_POST['choice'] ?? ''));
if (!$ok) flash($msg, 'err');
redirect(safe_back('index.php'));
