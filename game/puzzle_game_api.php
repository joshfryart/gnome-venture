<?php
declare(strict_types=1);
// v2.0.71: puzzle game runs (Rain Barrel; v2.0.72 Gnome Beds). POST only, CSRF, JSON. g=barrel|beds; do=start (mode, size) / hint (token, r) / finish (token, r).
// The server deals the puzzle from a seed and never sends the answer; the time is the server's clock; the daily reward is paid once a day.
require __DIR__ . '/includes/bootstrap.php';
require_once __DIR__ . '/includes/puzzle_games.php';
header('Content-Type: application/json; charset=utf-8');
header('Cache-Control: no-store');
$out = function (array $a, int $code = 200) { http_response_code($code); echo json_encode($a); exit; };
if (!is_post()) $out(['ok' => false, 'error' => 'POST only.'], 405);
$sent = $_POST['csrf'] ?? '';
if (!is_string($sent) || !hash_equals(csrf_token(), $sent)) $out(['ok' => false, 'error' => 'Your page expired. Refresh and try again.'], 400);
$u = current_user();
if (!$u) $out(['ok' => false, 'error' => 'Please log in first.'], 403);
$g = (string)($_POST['g'] ?? '');
if (!isset(PUZZLE_GAMES[$g]) || !puzzle_game_open($g)) $out(['ok' => false, 'error' => 'That puzzle isn’t open right now.'], 403);
$key = 'pzgapi:' . (int)$u['id'];
if (rate_limited($key, 60, 10)) $out(['ok' => false, 'error' => 'Slow down a little, then try again.'], 429);
record_attempt($key);
$do = (string)($_POST['do'] ?? '');
$token = (string)($_POST['token'] ?? '');
$r = json_decode((string)($_POST['r'] ?? '[]'), true);
if (!is_array($r) || count($r) > 400) $r = [];
foreach ($r as $v) if (!is_int($v)) { $r = []; break; }
$fn = ['barrel' => ['pz_barrel_start', 'pz_barrel_hint', 'pz_barrel_finish'], 'beds' => ['pz_beds_start', 'pz_beds_hint', 'pz_beds_finish']][$g];
if ($do === 'start') {
    [$ok, $msg, $x] = $fn[0]($u, (string)($_POST['mode'] ?? 'daily'), (int)($_POST['size'] ?? 0));
    $out($ok ? ['ok' => true, 'token' => $msg] + $x : ['ok' => false, 'error' => $msg]);
}
if ($do === 'hint') {
    [$ok, $msg, $x] = $fn[1]($u, $token, $r);
    $out(['ok' => $ok, ($ok ? 'message' : 'error') => $msg] + $x);
}
if ($do === 'finish') {
    [$ok, $msg, $x] = $fn[2]($u, $token, $r);
    $out(['ok' => $ok, ($ok ? 'message' : 'error') => $msg] + $x);
}
$out(['ok' => false, 'error' => 'Unknown request.'], 400);
