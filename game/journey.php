<?php
declare(strict_types=1);
// v0.7.65: Wren's Journey actions (the page itself is Almanac → Journey).
require __DIR__ . '/includes/bootstrap.php';
require_once __DIR__ . '/includes/garden_logic.php';
require_once __DIR__ . '/includes/journey.php';
$u = require_login();
$ch = (int)($_POST['ch'] ?? $_GET['j'] ?? 0);
if (is_post()) {
    csrf_check();
    unset($_SESSION['nav_badges']);   // v1.7.5: recount the Tasks badge
    [$ok, $msg] = match ((string)($_POST['do'] ?? '')) {
        'hand_in' => journey_hand_in($u, $ch),
        'finish' => journey_finish($u, $ch),
        'crate' => journey_crate($u, $ch),
        default => [false, 'Unknown action.'],
    };
    if ($msg !== '') flash($msg, $ok ? 'ok' : 'err');
}
$back = (string)($_POST['back'] ?? '');
if (preg_match('/^(town\.php|jobs\.php)\?[a-z0-9=&_]*$/', $back)) redirect($back);   // v0.7.66: from the town square's Quests tab
redirect('book.php?ch=Journey' . ($ch ? '&j=' . $ch : ''));
