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
$do = (string)($_POST['do'] ?? '');
$free = in_array($do, ['pstart', 'pfinish'], true);   // v2.0.87: Jigsaw free play (timed on the server for personal bests, pays nothing)
require_once __DIR__ . '/includes/jigsaw.php';
if ($free) { if (!jigsaw_open()) $out(['ok' => false, 'error' => 'Jigsaw isn’t open right now.'], 403); }
else {
    // v2.0.87: gate on the tournament's OWN kind (a GIFsaw run needs puzzle tournaments on, a Jigsaw run needs Jigsaw tournaments on; never "either")
    $kind = null; puzzles_ensure();
    if ($do === 'start') $kind = q_val('SELECT kind FROM puzzle_tournaments WHERE id = ?', [(int)($_POST['t'] ?? 0)]);
    elseif ($do === 'finish') { $tk = (string)($_POST['token'] ?? ''); $kind = preg_match('/^[a-f0-9]{32}$/', $tk) ? q_val('SELECT t.kind FROM puzzle_attempts a JOIN puzzle_tournaments t ON t.id = a.tournament_id WHERE a.token = ? AND a.user_id = ?', [$tk, (int)$u['id']]) : null; }
    $on = $kind ? puzzle_kind_tournaments_on((string)$kind) : (puzzle_tournaments_on() || jigsaw_tournaments_on());   // unknown tournament / run: the handler below says "not found"
    if (!$on) $out(['ok' => false, 'error' => ($kind === 'still' ? 'Jigsaw' : 'Puzzle') . ' tournaments aren’t running right now.'], 403);
}
$key = 'pzapi:' . (int)$u['id'];
if (rate_limited($key, 40, 10)) $out(['ok' => false, 'error' => 'Slow down a little, then try again.'], 429);
record_attempt($key);
if ($do === 'pstart') {
    [$ok, $msg, $x] = jigsaw_practice_start($u, (string)($_POST['pic'] ?? ''), (string)($_POST['tier'] ?? ''));
    $out($ok ? ['ok' => true, 'token' => $msg] + $x : ['ok' => false, 'error' => $msg]);
}
if ($do === 'pfinish') {
    [$ok, $msg, $x] = jigsaw_practice_finish($u, (string)($_POST['token'] ?? ''), (int)($_POST['drops'] ?? 0));
    $out(['ok' => $ok, ($ok ? 'message' : 'error') => $msg] + $x);
}
if ($do === 'start') {
    [$ok, $msg, $x] = puzzle_attempt_start($u, (int)($_POST['t'] ?? 0));
    $out($ok ? ['ok' => true, 'token' => $msg] + $x : ['ok' => false, 'error' => $msg]);
}
if ($do === 'finish') {
    [$ok, $msg, $x] = puzzle_attempt_finish($u, (string)($_POST['token'] ?? ''), (int)($_POST['drops'] ?? 0));
    $out(['ok' => $ok, ($ok ? 'message' : 'error') => $msg] + $x);
}
$out(['ok' => false, 'error' => 'Unknown request.'], 400);
