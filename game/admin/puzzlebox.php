<?php
declare(strict_types=1);
// 2.7.01: reset a player's Puzzle box to its first state (the fixed starter box). Unlocks, upgrades and tool wear stay.
require dirname(__DIR__) . '/includes/bootstrap.php';
require_once dirname(__DIR__) . '/includes/admin_helpers.php';
require_once dirname(__DIR__) . '/includes/pfdeck.php';
$me = require_admin();

if (is_post()) {
    csrf_check();
    $username = trim((string)($_POST['username'] ?? ''));
    $u = q_one('SELECT id, username FROM users WHERE username = ?', [$username]);
    if (!$u) flash('No player called "' . $username . '".', 'err');
    elseif (empty($_POST['confirm'])) flash('Tick the box to confirm the reset.', 'err');
    else {
        $why = pfd_admin_reset((int)$u['id']);
        if ($why !== null) flash($why, 'err');
        else { admin_log('pbox_reset', 'users#' . $u['id'], 'Puzzle box reset to the starter box'); flash($u['username'] . '’s Puzzle box is back to the starter box. Their unlocks are kept.'); }
    }
    redirect('admin/puzzlebox.php?user=' . urlencode($username));
}
$prefill = (string)($_GET['user'] ?? '');

page_header('Reset Puzzle box', true);
?>
<?php admin_crumbs('puzzlebox.php'); ?>
<h1>Reset a Puzzle box</h1>
<form method="post" class="form box">
  <?= csrf_field() ?>
  <label>Player username <input name="username" value="<?= e($prefill) ?>" required></label>
  <p class="help"><b>Reset:</b> the kit goes back to the starter box (<?= count(PFD_CORE) + count(PFD_STARTER_FIXED) ?> pieces, the same for everyone), pieces they switched on are switched off, the fight belt goes back to its default (their best usable tools, like a new gnome’s) and auto-use is turned off.<br>
  <b>Kept:</b> every unlock (crops, crafts, regions, wearables, tools, pals), earned puzzle upgrades, tool wear and repair kits. They can switch pieces back on in the Puzzle box.<br>
  Refused while the player is in a fight.</p>
  <label><input type="checkbox" name="confirm" value="1"> Yes, reset this player’s Puzzle box</label>
  <button class="btn">Reset Puzzle box</button>
</form>
