<?php
declare(strict_types=1);
// v2.0.68: puzzle tournament runs. POST only, CSRF, JSON. do=start (t) gives a single-use token; do=finish (token, drops) times it on the server clock.
require __DIR__ . '/includes/bootstrap.php';
require_once __DIR__ . '/includes/puzzles.php';
header('Content-Type: application/json; charset=utf-8');
header('Cache-Control: no-store');
$out = function (array $a, int $code = 200) { http_response_code($code); echo json_encode($a); exit; };
if (!is_post()) $out(['ok' => false, 'error' => 'POST only.'], 405);
$sent = $_POST['csrf'] ?? '';
if (!is_string($sent) || !hash_equals(csrf_token(), $sent)) $out(['ok' => false, 'error' => 'Your page expired. Refresh and try again.'], 400);
$u = current_user();
if (!$u) $out(['ok' => false, 'error' => 'Please log in first.'], 403);
if (!empty($u['guest'])) $out(['ok' => false, 'error' => 'Guests can’t enter tournaments. Make your own gnome to join in!'], 403);   // v2.0.75
if (!puzzle_tournaments_on()) $out(['ok' => false, 'error' => 'Puzzle tournaments aren’t running right now.'], 403);
$key = 'pzapi:' . (int)$u['id'];
if (rate_limited($key, 40, 10)) $out(['ok' => false, 'error' => 'Slow down a little, then try again.'], 429);
record_attempt($key);
$do = (string)($_POST['do'] ?? '');
if ($do === 'start') {
    [$ok, $msg, $x] = puzzle_attempt_start($u, (int)($_POST['t'] ?? 0));
    $out($ok ? ['ok' => true, 'token' => $msg] + $x : ['ok' => false, 'error' => $msg]);
}
if ($do === 'finish') {
    [$ok, $msg, $x] = puzzle_attempt_finish($u, (string)($_POST['token'] ?? ''), (int)($_POST['drops'] ?? 0));
    $out(['ok' => $ok, ($ok ? 'message' : 'error') => $msg] + $x);
}
$out(['ok' => false, 'error' => 'Unknown request.'], 400);
