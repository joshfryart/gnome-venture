<?php
declare(strict_types=1);
require __DIR__ . '/includes/bootstrap.php';
require_once __DIR__ . '/includes/account.php';
$u = require_login();

if (is_post()) {
    csrf_check();
    if (rate_limited('account:' . $u['id'], 10, 15)) {
        flash('Too many tries. Please wait a few minutes.', 'err');
        redirect('account.php');
    }
    $do = (string)($_POST['do'] ?? '');
    [$ok, $msg] = match ($do) {
        'email' => change_email($u, (string)($_POST['current'] ?? ''), (string)($_POST['email'] ?? '')),
        'password' => change_password($u, (string)($_POST['current'] ?? ''), (string)($_POST['password'] ?? ''), (string)($_POST['password2'] ?? '')),
        'privacy' => (function () use ($u) {
            q('UPDATE users SET town_hidden = ?, garden_public = ? WHERE id = ?', [empty($_POST['town_hidden']) ? 0 : 1, empty($_POST['garden_private']) ? 1 : 0, $u['id']]);
            return [true, 'Saved.'];
        })(),
        'nudges' => (function () use ($u) {
            q('UPDATE users SET email_nudges = ? WHERE id = ?', [empty($_POST['email_nudges']) ? 0 : 1, $u['id']]);
            return [true, 'Saved.'];
        })(),
        'resend' => (function () use ($u) {
            if (!empty($u['email_verified_at'])) return [true, 'Your email is already confirmed.'];
            if (rate_limited('verify:' . $u['id'], 3, 60)) return [false, 'Too many emails. Try again in an hour.'];
            record_attempt('verify:' . $u['id']);
            send_verify_email($u);
            return [true, 'Sent. Check your inbox.'];
        })(),
        'delete' => delete_account($u, (string)($_POST['current'] ?? ''), (string)($_POST['confirm'] ?? '')),
        default => [false, 'Unknown action.'],
    };
    if (!$ok) record_attempt('account:' . $u['id']);
    if ($ok && $do === 'delete') {
        $_SESSION = [];
        session_destroy();
        session_start();
        flash($msg);
        redirect('index.php');
    }
    flash($msg, $ok ? 'ok' : 'err');
    redirect('account.php');
}
page_header('Account');
?>
<h1>⚙️ Account</h1>
<p class="help">Logged in as <b><?= e($u['username']) ?></b> (your log-in name, which only you see). See our <a href="<?= e(url('page.php?p=privacy')) ?>">privacy policy</a>.</p>
<?php if (empty($u['email_verified_at'])): ?>
<form method="post" class="form"><?= csrf_field() ?><input type="hidden" name="do" value="resend">
  <p class="help">Your email is not confirmed yet. <button class="btn small">Resend</button></p></form>
<?php endif; ?>
<div class="box narrow">
  <h2>Email</h2>
  <form method="post" class="form"><?= csrf_field() ?><input type="hidden" name="do" value="email">
    <label>New email <input type="email" name="email" value="<?= e((string)$u['email']) ?>" required autocomplete="email"></label>
    <label>Current password <input type="password" name="current" required autocomplete="current-password"></label>
    <button class="btn small">Change email</button></form>
</div>
<div class="box narrow">
  <h2>Password</h2>
  <form method="post" class="form"><?= csrf_field() ?><input type="hidden" name="do" value="password">
    <label>Current password <input type="password" name="current" required autocomplete="current-password"></label>
    <label>New password (10+ characters) <input type="password" name="password" required minlength="10" autocomplete="new-password"></label>
    <label>New password again <input type="password" name="password2" required minlength="10" autocomplete="new-password"></label>
    <button class="btn small">Change password</button></form>
</div>
<div class="box narrow">
  <h2>Look</h2>
  <?= theme_choice() /* v1.6.5 */ ?>
  <p class="help">Dark is the default. “Match my phone” follows your phone’s own setting.</p>
</div>
<div class="box narrow">
  <h2>Being seen</h2>
  <form method="post" class="form"><?= csrf_field() ?><input type="hidden" name="do" value="privacy">
    <label class="check"><input type="checkbox" name="town_hidden" value="1" <?= (int)$u['town_hidden'] ? 'checked' : '' ?>> Hide me from the “Gnomes here” lists in town squares</label>
    <p class="help">Hidden gnomes can still do everything in town, but others won’t see them or be able to wave, share or challenge them.</p>
    <label class="check"><input type="checkbox" name="garden_private" value="1" <?= (int)$u['garden_public'] === 1 ? '' : 'checked' ?>> Keep my gardens private (no visitors, no Garden of the Month)</label>
    <p class="help">Visitors can only look, never touch. Your <a href="<?= e(url('profile.php')) ?>">profile</a> shows your name, level and ribbons either way.</p>
    <button class="btn small">Save</button></form>
</div>
<div class="box narrow">
  <h2>Reminders</h2>
  <form method="post" class="form"><?= csrf_field() ?><input type="hidden" name="do" value="nudges">
    <label class="check"><input type="checkbox" name="email_nudges" value="1" <?= (int)($u['email_nudges'] ?? 0) === 1 ? 'checked' : '' ?>> <span>Email me when my harvest is ready or I have been away a while</span></label>
    <p class="help"><?= empty($u['email_verified_at']) ? 'Needs a confirmed email. ' : '' ?>At most one email every few days. Every email has a one-click stop link.</p>
    <button class="btn small">Save</button></form>
</div>
<div class="box narrow danger">
  <h2>Delete my account</h2>
  <p class="help">This removes your name, email and anything that identifies you, and you won’t be able to log in again. Anything you’re holding for other players
    (trade offers, wages for jobs) goes back to them. Your items and gardens are not returned. This can’t be undone.</p>
  <form method="post" class="form" data-confirm="Really delete your account forever?"><?= csrf_field() ?><input type="hidden" name="do" value="delete">
    <label>Password <input type="password" name="current" required autocomplete="current-password"></label>
    <label>Type DELETE to confirm <input name="confirm" required autocomplete="off"></label>
    <button class="btn small alt">Delete my account</button></form>
</div>
<?php page_footer();
