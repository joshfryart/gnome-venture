<?php
// 2.8.82 regression: deliver_job() calls craft_take() (includes/crafting.php) but jobs.php never loaded it, so handing in a part-family job on /jobs.php died with
// "Call to undefined function craft_take()". deliver_job() now requires crafting.php itself.
// php tests/jobs_craft_take.php GAME_DIR   (a game copy that is installed, e.g. the dev copy; reads only)
$game = $argv[1] ?? dirname(__DIR__) . '/game';
chdir($game); $_SERVER['REQUEST_URI'] = '/jobs.php'; $_SERVER['SCRIPT_NAME'] = '/jobs.php'; $_SERVER['HTTP_HOST'] = 'localhost';
require $game . '/includes/bootstrap.php';
require_once $game . '/includes/jobs.php';
$before = function_exists('craft_take');
deliver_job(999999, 'daily');   // no such player/job: returns "Nothing to deliver." at once
$after = function_exists('craft_take');
echo ($before ? "note: craft_take was already loaded\n" : ''), ($after ? "ok   deliver_job loads craft_take\n" : "FAIL deliver_job leaves craft_take undefined\n");
exit($after ? 0 : 1);
