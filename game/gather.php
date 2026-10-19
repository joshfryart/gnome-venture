<?php
declare(strict_types=1);
/**
 * v0.7.80: gather here at a road stop or a place (not on an expedition). POST only; the box is on the World page.
 * Off the path, the same box is on the adventure page (see explore_gather in includes/explore.php).
 */
require __DIR__ . '/includes/bootstrap.php';
require_once __DIR__ . '/includes/adventure.php';
$u = require_login();
if (!is_post()) redirect('world.php');
csrf_check();
refresh_energy($u);
$uid = (int)$u['id'];
// v0.9.9: the mini-game asks for a round here (JSON); the taps come back with the normal gather form below
if (($_POST['do'] ?? '') === 'round') {
    header('Content-Type: application/json; charset=utf-8');
    $t = (string)($_POST['tool'] ?? '');
    if (($_POST['practice'] ?? '') === '1') {   // v1.5.0: a practice round: no tool, no energy, never paid
        echo json_encode(setting('gather_games_on') === '1' ? (gather_round_new($u, $t, ($_POST['rm'] ?? '') === '1', true) ?: ['error' => 'No game for that right now.']) : ['error' => 'The tool games are switched off.']);
        exit;
    }
    $round = setting('gather_games_on') === '1' && tool_tier($uid, $t) >= 1 ? gather_round_new($u, $t, ($_POST['rm'] ?? '') === '1') : null;
    echo json_encode($round ?: ['error' => 'No game for that right now.']);
    exit;
}
if (($_POST['do'] ?? '') === 'practice') {   // v1.5.0: how a practice round went (nothing is paid, nothing changes)
    header('Content-Type: application/json; charset=utf-8');
    echo json_encode(gather_practice_result((string)($_POST['tool'] ?? '')));
    exit;
}
// Back to the page the gnome came from (only our own world and town pages), else the World page
$back = (string)($_POST['back'] ?? '');
$safe = preg_match('#^(world|town)\.php(\?[^\s]*)?$#', $back) && !str_contains($back, '//') ? $back : 'world.php';
if (active_expedition($uid)) {
    flash('Finish your trip first.', 'err');
    redirect($safe);
}
if (ts($u['community_shift_until'] ?? null) > time()) {
    flash('You’re on a tending shift at the community garden. Finish or end it first.', 'err');
    redirect($safe);
}
$here = player_node($u);
$land = (string)($here['landscape'] ?: 'grassland');
$tool = (string)($_POST['tool'] ?? '');
$skill = gather_game_result($tool);   // v0.9.9 mini-game (or Quick gather)
[$ok, $msg] = gather_here($u, $land, $tool, $skill);
flash($msg, $ok ? 'ok' : 'err');
redirect($safe);
