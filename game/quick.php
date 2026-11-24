<?php
declare(strict_types=1);
/** The dock's Quick slot (includes/quick_slot.php): do = set (item_id) | clear | use. POST with the page's CSRF token; the message is flashed and the gnome goes back to the page they were on. */
require __DIR__ . '/includes/bootstrap.php';
require_once __DIR__ . '/includes/garden_logic.php';   // refresh_energy(), as inventory.php
require_once __DIR__ . '/includes/items.php';
require_once __DIR__ . '/includes/crafting.php';
require_once __DIR__ . '/includes/tools.php';
require_once __DIR__ . '/includes/quick_slot.php';
$u = require_login();
$back = safe_back('inventory.php');
if (!is_post()) redirect($back);
csrf_check();
$do = (string)($_POST['do'] ?? '');
[$ok, $msg] = match ($do) {
    'set' => quick_set($u, (int)($_POST['item_id'] ?? 0)),
    'clear' => quick_clear($u),
    'use' => quick_use($u),
    default => [false, 'That is not something the Quick button does.'],
};
if ($msg !== '') flash($msg, $ok ? 'ok' : 'err');
redirect($back);
