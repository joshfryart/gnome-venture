<?php
declare(strict_types=1);
require __DIR__ . '/includes/bootstrap.php';
require_once __DIR__ . '/includes/garden_logic.php';
require_once __DIR__ . '/includes/crafting.php';
require_once __DIR__ . '/includes/almanac.php';
$u = require_login();
$uid = (int)$u['id'];

// v0.7.61: Crafting is now a tab of the Satchel page. This file only does the "Make" button and old links.
$tab = (string)($_GET['c'] ?? 'cooking');
if (!isset(CRAFT_CATEGORIES[$tab])) $tab = 'cooking';

if (is_post()) {
    csrf_check();
    refresh_energy($u);
    $act = (string)($_POST['do'] ?? '');
    if ($act === 'collect' || $act === 'collect_all') {   // v0.9.4: take finished dishes out of the pots
        [$ok, $msg] = $act === 'collect_all' ? cook_collect_all($u) : array_slice(cook_collect_one($u, (int)($_POST['pot_id'] ?? 0)), 0, 2);
        flash($msg, $ok ? 'ok' : 'err');
        if ($ok) foreach (check_milestones($uid) as $m) flash($m);
        redirect('inventory.php?tab=craft&c=cooking');
    }
    if ($act === 'cook_again') {   // v2.4.67: cook the last dish again, as many as the free pots, stock and energy allow
        $rid = (int)q_val("SELECT r.id FROM recipes r JOIN users u ON u.last_cooked_id = r.output_item_id WHERE u.id = ? AND r.category = 'cooking'", [$uid]);
        [$ok, $msg] = $rid > 0 ? craft($u, $rid, 'all') : [false, 'Cook something once first.'];
        flash($msg, $ok ? 'ok' : 'err');
        if ($ok) foreach (check_milestones($uid) as $m) flash($m);
        redirect('inventory.php?tab=craft&c=cooking');
    }
    if ($act === 'jar_collect' || $act === 'jar_collect_all') {   // v0.9.8: take finished preserves out of the Pantry jars
        [$ok, $msg] = $act === 'jar_collect_all' ? pantry_collect_all($u) : array_slice(pantry_collect_one($u, (int)($_POST['jar_id'] ?? 0)), 0, 2);
        flash($msg, $ok ? 'ok' : 'err');
        if ($ok) foreach (check_milestones($uid) as $m) flash($m);
        redirect('inventory.php?tab=craft&c=pantry');
    }
    // v0.7.88: qty is 1, 2, 5 or 'all' (as many as fit). craft() clamps it to what the stock and energy allow.
    $qtyIn = $_POST['qty'] ?? '1';
    $want = $qtyIn === 'all' ? 'all' : (is_string($qtyIn) && ctype_digit($qtyIn) && (int)$qtyIn >= 1 ? (int)$qtyIn : 0);
    if ($want === 0) { flash('Pick how many to make: 1 or more.', 'err'); redirect('inventory.php?tab=craft'); }   // v2.3.94: 0, -1 and "abc" no longer craft one by surprise
    [$ok, $msg] = craft($u, (int)($_POST['recipe_id'] ?? 0), $want);
    flash($msg, $ok ? 'ok' : 'err');
    if ($ok) foreach (check_milestones($uid) as $m) flash($m);
}
$rid = (int)($_POST['recipe_id'] ?? 0);   // come back with the same recipe open (shelves open it from ?r=; the Pantry also scrolls to its detail)
redirect('inventory.php?tab=craft&c=' . $tab . ($rid > 0 ? '&r=' . $rid . '#' . ($tab === 'pantry' ? 'p2d' : 'r' . $rid) : ''));
