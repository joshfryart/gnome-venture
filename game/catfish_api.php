<?php
declare(strict_types=1);
// Cat Fish: POST only, CSRF, JSON. do=tick pays out the kibble earned so far and returns the fresh view (optional play=n and seq=batch id: taps on the dangling fish, paid by catfish_play); do=buy (key) buys one upgrade level.
require __DIR__ . '/includes/bootstrap.php';
require_once __DIR__ . '/includes/catfish.php';
header('Content-Type: application/json; charset=utf-8');
header('Cache-Control: no-store');
$out = function (array $a, int $code = 200) { http_response_code($code); echo json_encode($a); exit; };
if (!is_post()) $out(['ok' => false, 'error' => 'POST only.'], 405);
$sent = $_POST['csrf'] ?? '';
if (!is_string($sent) || !hash_equals(csrf_token(), $sent)) $out(['ok' => false, 'error' => 'Your page expired. Refresh and try again.'], 400);
$u = current_user();
if (!$u) $out(['ok' => false, 'error' => 'Please log in first.'], 403);
if (!empty($u['guest'])) $out(['ok' => false, 'error' => 'Guests can’t keep a cat. Make your own gnome to adopt one!'], 403);
if (!catfish_open() || !catfish_ensure()) $out(['ok' => false, 'error' => 'Cat Fish isn’t open right now.'], 403);
$uid = (int)$u['id'];
if (rate_limited('cfapi:' . $uid, 60, 10)) $out(['ok' => false, 'error' => 'Slow down a little, then try again.'], 429);
record_attempt('cfapi:' . $uid);
$do = (string)($_POST['do'] ?? '');
if ($do === 'tick') {
    $got = 0; $paid = 0;
    if (array_key_exists('play', $_POST)) [$got, $paid] = catfish_play($uid, $_POST['play'], $_POST['seq'] ?? 0);   // taps batched since the last tick (see catfish_play)
    $out(['ok' => true, 'view' => catfish_view($uid, $got, $paid)]);
}
if ($do === 'buy') { [$ok, $msg] = catfish_buy($uid, (string)($_POST['key'] ?? '')); $out(['ok' => $ok, 'message' => $msg, 'view' => catfish_view($uid)], $ok ? 200 : 400); }
$out(['ok' => false, 'error' => 'Unknown action.'], 400);
