<?php
declare(strict_types=1);
/**
 * v2.0.75: after a guest registers, their garden is theirs: this one step makes the gnome (name, hat, beard) that welcome.php would have made.
 * Only reachable right after converting (session flag set by guest_convert()).
 */
require __DIR__ . '/includes/bootstrap.php';
require_once __DIR__ . '/includes/gnome.php';
require_once __DIR__ . '/includes/onboard.php';
require_once __DIR__ . '/includes/puzzles.php';
$u = require_login();
if (empty($_SESSION['customise_gnome'])) redirect('garden.php');
$errors = [];
$name = (string)($u['gnome_name'] ?? ''); $hat = (string)($u['hat_color'] ?? array_key_first(HAT_COLORS)); $beard = (string)($u['beard_color'] ?? array_key_first(BEARD_COLORS));
if (is_post()) {
    csrf_check();
    $name = trim(preg_replace('/\s+/u', ' ', (string)($_POST['gnome_name'] ?? '')));
    $hat = (string)($_POST['hat'] ?? ''); $beard = (string)($_POST['beard'] ?? '');
    if (!preg_match("/^\\p{L}[\\p{L} '’.-]{1,23}$/u", $name)) $errors[] = 'Gnome names need 2–24 letters. Spaces, apostrophes and hyphens are fine too.';
    require_once __DIR__ . '/includes/moderation.php';
    if ($name !== '' && blocked_word($name)) $errors[] = 'Please pick a friendlier name.';
    if (!isset(HAT_COLORS[$hat])) $errors[] = 'Pick a hat colour.';
    if (!isset(BEARD_COLORS[$beard])) $errors[] = 'Pick a beard colour.';
    if (!$errors) {
        q('UPDATE users SET gnome_name = ?, hat_color = ?, beard_color = ?, tour_step = 1 WHERE id = ?', [$name, $hat, $beard, (int)$u['id']]);
        unset($_SESSION['customise_gnome']);
        flash('🌱 ' . $name . ' is all yours! Wren is waiting in your garden to show you around.');
        redirect('garden.php');
    }
}
$preview = ['hat_color' => $hat, 'beard_color' => $beard, 'gnome_name' => $name, 'username' => $u['username']];
page_header('Make your gnome');
?>
<div class="welcomeflow">
  <div class="box narrow guestcard">
    <?= puzzle_cast('jeff-trophy', 'Jeff with a trophy', 'lp-jeffface') ?>
    <p class="say"><b>Jeff:</b> “Your garden is yours for keeps! Last thing: who are you? Pick your gnome’s name, hat and beard.”</p>
  </div>
  <?php foreach ($errors as $err): ?><div class="flash err"><?= e($err) ?></div><?php endforeach; ?>
  <form method="post" class="box form gnomemaker" data-gnome-preview>
    <?= csrf_field() ?>
    <div class="avatarcol"><?= gnome_avatar_pals($preview, 120) ?></div>
    <div>
      <label>Your gnome’s name
        <input name="gnome_name" value="<?= e($name) ?>" required maxlength="24" placeholder="e.g. Bramble Puddlefoot" autocomplete="off"></label>
      <p class="help">This is the name other players and NPCs will see. Your log-in name stays private.</p>
      <fieldset class="swatches"><legend>Hat</legend>
        <?php foreach (HAT_COLORS as $c => $label): ?>
          <label title="<?= e($label) ?>"><input type="radio" name="hat" value="<?= e($c) ?>" data-part="hat"<?= $hat === $c ? ' checked' : '' ?>> <?= swatch($c) ?> <span><?= e($label) ?></span></label>
        <?php endforeach; ?>
      </fieldset>
      <fieldset class="swatches"><legend>Beard</legend>
        <?php foreach (BEARD_COLORS as $c => $label): ?>
          <label title="<?= e($label) ?>"><input type="radio" name="beard" value="<?= e($c) ?>" data-part="beard"<?= $beard === $c ? ' checked' : '' ?>> <?= swatch($c) ?> <span><?= e($label) ?></span></label>
        <?php endforeach; ?>
      </fieldset>
      <button class="btn">🌱 This is my gnome</button>
    </div>
  </form>
</div>
<?php page_footer();
