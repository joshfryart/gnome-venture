<?php
declare(strict_types=1);
require dirname(__DIR__) . '/includes/bootstrap.php';
require_once dirname(__DIR__) . '/includes/admin_helpers.php';   // v1.6.3
$me = require_admin();
$schema = settings_schema();
$errors = [];

if (is_post()) {
    csrf_check();
    $new = [];
    foreach ($schema as $k => $def) {
        $raw = $_POST['s'][$k] ?? '';
        $raw = is_string($raw) ? trim($raw) : '';
        if ($def['type'] === 'bool') {
            $new[$k] = isset($_POST['s'][$k]) ? '1' : '0';
        } elseif ($def['type'] === 'select') {   // v0.9.0
            if (!array_key_exists($raw, $def['options'])) { $errors[] = 'Pick a valid ' . $def['label'] . '.'; continue; }
            $new[$k] = (string)$raw;
        } elseif ($def['type'] === 'int') {
            if (!preg_match('/^-?\d{1,10}$/', $raw)) { $errors[] = $def['label'] . ' must be a whole number.'; continue; }
            $n = (int)$raw;
            if (isset($def['min']) && $n < $def['min']) { $errors[] = $def['label'] . " must be at least {$def['min']}."; continue; }
            if (isset($def['max']) && $n > $def['max']) { $errors[] = $def['label'] . " must be at most {$def['max']}."; continue; }
            $new[$k] = (string)$n;
        } else {
            if (mb_strlen($raw) > 5000) { $errors[] = $def['label'] . ' is too long.'; continue; }
            $new[$k] = $raw;
        }
    }
    if (!$errors && (int)$new['starting_plot_size'] > (int)$new['max_plot_size']) {
        $errors[] = 'Starting plot size can’t be bigger than the max plot size.';
    }
    if (!$errors) {
        $changes = [];
        foreach ($new as $k => $v) {
            if (setting($k) !== $v) {
                $changes[$k] = [setting($k), $v];
                set_setting($k, $v);
            }
        }
        if ($changes) admin_log('settings', '', json_encode($changes, JSON_UNESCAPED_UNICODE));
        if (isset($changes['guide_price'])) { setting('__reload__'); require_once __DIR__ . '/../includes/journey.php'; ensure_guide_price(); }   // v0.7.65: reprice the guides in every shop
        flash('Settings saved.');
        redirect('admin/settings.php');
    }
}

page_header('Game settings', true);
?>
<?php admin_crumbs('settings.php');   // v1.6.3 ?>
<h1>Game settings</h1>
<?php foreach ($errors as $err): ?><div class="flash err"><?= e($err) ?></div><?php endforeach; ?>
<?php
// Sections, picked from each setting's name, so a long page is easy to jump around (v0.7.17)
$sectionOf = function (string $k): string {
    foreach (['site_' => 'Site', 'motd' => 'Site', 'registration' => 'Site', 'maintenance' => 'Site', 'mail_' => 'Site', 'trusted_' => 'Site', 'blocked_' => 'Site',
              'job_' => 'Job Board', 'player_job' => 'Job Board', 'player_tend' => 'Job Board',
              'worm_' => 'Games & contests', 'memory_' => 'Games & contests', 'race_' => 'Games & contests', 'spit_' => 'Games & contests', 'marrow_' => 'Games & contests', 'carving' => 'Games & contests', 'gotm_' => 'Games & contests', 'yard_' => 'Yard & designer',
              'community_' => 'Community garden', 'trade' => 'Trading', 'gifts' => 'Trading', 'stall_' => 'Trading', 'sapling' => 'Trading',
              'helper_' => 'Hired help', 'notill_' => 'Soil & no-till', 'amend_' => 'Soil & no-till', 'broadfork' => 'Soil & no-till',
              'stat_' => 'Gnomes', 'food_' => 'Gnomes', 'calling' => 'Gnomes', 'max_energy' => 'Gnomes', 'energy_' => 'Gnomes', 'tour_' => 'Gnomes',
              'trek_' => 'Treks', 'stop_' => 'Rest stops', 'season' => 'Seasons & weather', 'weather_' => 'Seasons & weather', 'daypart_' => 'Seasons & weather', 'travel' => 'World', 'game_timezone' => 'World', 'town_' => 'World', 'orders_' => 'Market & orders', 'market_' => 'Market & orders', 'price_' => 'Market & orders', 'basket_' => 'Market & orders'] as $pre => $sec) {
        if (str_starts_with($k, $pre)) return $sec;
    }
    return 'Gardens & economy';
};
$sections = [];
foreach ($schema as $k => $def) $sections[$sectionOf($k)][$k] = $def;
// v1.7.1: inside a section, settings are grouped under a small heading by the "Feature:" prefix of their label
$prefixOf = fn(array $def): string => preg_match('/^([^:]{2,40}): /u', (string)$def['label'], $m) ? $m[1] : 'Other';
foreach ($sections as $sec => $defs) {
    $groups = [];
    foreach ($defs as $k => $def) $groups[$prefixOf($def)][$k] = $def;
    $sections[$sec] = $groups;
}
?>
<nav class="chips jump"><?php foreach (array_keys($sections) as $sec): ?><a href="#s-<?= e(slugify($sec)) ?>"><?= e($sec) ?></a><?php endforeach; ?></nav>
<form method="post" class="form">
  <?= csrf_field() ?>
  <?php foreach ($sections as $sec => $defs): ?>
  <fieldset class="box setsec" id="s-<?= e(slugify($sec)) ?>"><legend><?= e($sec) ?></legend>
  <?php foreach ($defs as $pre => $group): ?><?php if (count($group) > 1): ?><h3 class="setpre"><?= e($pre) ?></h3><?php endif; ?>
  <?php foreach ($group as $k => $def): $val = $_POST['s'][$k] ?? setting($k); ?>
    <?php if ($def['type'] === 'bool'): ?>
      <label class="check"><input type="checkbox" name="s[<?= e($k) ?>]" value="1" <?= $val === '1' ? 'checked' : '' ?>> <?= e($def['label']) ?></label>
    <?php elseif ($def['type'] === 'select'): ?>
      <label><?= e($def['label']) ?><select name="s[<?= e($k) ?>]"><?php foreach ($def['options'] as $ov => $ol): ?><option value="<?= e((string)$ov) ?>"<?= (string)$ov === (string)$val ? ' selected' : '' ?>><?= e($ol) ?></option><?php endforeach; ?></select></label>
    <?php elseif ($def['type'] === 'textarea'): ?>
      <label><?= e($def['label']) ?><textarea name="s[<?= e($k) ?>]" rows="3"><?= e($val) ?></textarea></label>
    <?php else: ?>
      <label><?= e($def['label']) ?><input name="s[<?= e($k) ?>]" value="<?= e($val) ?>" <?= $def['type'] === 'int' ? 'type="number"' : '' ?>></label>
    <?php endif; ?>
  <?php endforeach; endforeach; ?>
  </fieldset>
  <?php endforeach; ?>
  <div class="savebar"><button class="btn">Save settings</button></div>
</form>
<?php page_footer();
