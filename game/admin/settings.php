<?php
declare(strict_types=1);
require dirname(__DIR__) . '/includes/bootstrap.php';
require_once dirname(__DIR__) . '/includes/admin_helpers.php';   // v1.6.3
$me = require_admin();
$schema = settings_schema();
$errors = [];

/** v2.0.4: rarely-touched tuning (shipped list; prefixes end in _ or are whole keys). Hidden unless "Show advanced" is on or a search finds them. Nothing is deleted or changed. */
function settings_is_adv(string $k): bool
{
    static $exact = ['season_epoch', 'season_force', 'weather_force', 'weather_regions', 'luck_percent_per_2', 'upgrade_cost_percent', 'explore_step_levels', 'explore_warn_from', 'explore_wild_from', 'explore_deep_from',
        'road_fixed_below', 'walk_rest_heal_percent', 'curio_price_pct', 'arrange_value_pct', 'dried_price_pct', 'shop_food_energy_pct', 'price_noise', 'price_season_swing', 'price_buy_season',
        'xp_steep_percent', 'xp_action_scale_percent', 'native_bonus_percent', 'care_growth_percent', 'pest_slow_pct', 'pest_max_pct', 'pest_butterfly_pct', 'pest_charm_pct', 'pest_counter_cut_pct', 'trek_xp_daily', 'trek_base_level'];
    static $prefix = ['weather_weights_', 'price_vol_', 'price_wanted_', 'price_market_', 'low_road_', 'outlevel_', 'creature_', 'trek_event_', 'trek_oldcamp_', 'trek_cold_', 'trek_ms_', 'trek_ambush_', 'trek_enc_', 'trek_sneak_',
        'trek_ko_', 'storm_', 'frost_', 'heat_', 'wind_', 'stack_kitchen_', 'unstudied_', 'companion_', 'critter_', 'hybrid_', 'biddy_', 'clementine_', 'butterfly_', 'snail_', 'pmentor_', 'yard_barrel', 'yard_shade', 'yard_hive', 'yard_birds', 'yard_path_'];
    if (in_array($k, $exact, true)) return true;
    foreach ($prefix as $p) if (str_starts_with($k, $p)) return true;
    return false;
}
// v2.0.4: search (?q= on label or key) and "Show advanced" (?adv=1). A search also finds advanced settings.
$sq = trim((string)($_POST['q'] ?? $_GET['q'] ?? ''));
$showAdv = ($_POST['adv'] ?? $_GET['adv'] ?? '') === '1';
$isVisible = function (string $k, array $def) use ($sq, $showAdv): bool {
    if ($sq !== '') return mb_stripos((string)$def['label'] . ' ' . $k, $sq) !== false;
    return $showAdv || !settings_is_adv($k);
};

if (is_post()) {
    csrf_check();
    $new = [];
    foreach ($schema as $k => $def) {
        if (!$isVisible($k, $def)) continue;   // v2.0.4: a setting that was not on the page keeps its value (an unticked box would otherwise read as off)
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
    if (!$errors && (int)($new['starting_plot_size'] ?? setting('starting_plot_size')) > (int)($new['max_plot_size'] ?? setting('max_plot_size'))) {
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
        redirect('admin/settings.php' . ($sq !== '' || $showAdv ? '?' . http_build_query(array_filter(['q' => $sq, 'adv' => $showAdv ? '1' : ''])) : ''));
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
$advHidden = 0; $shownN = 0;
foreach ($schema as $k => $def) {
    if (!$isVisible($k, $def)) { if ($sq === '' && settings_is_adv($k)) $advHidden++; continue; }
    $sections[$sectionOf($k)][$k] = $def; $shownN++;
}
// v1.7.1: inside a section, settings are grouped under a small heading by the "Feature:" prefix of their label
$prefixOf = fn(array $def): string => preg_match('/^([^:]{2,40}): /u', (string)$def['label'], $m) ? $m[1] : 'Other';
foreach ($sections as $sec => $defs) {
    $groups = [];
    foreach ($defs as $k => $def) $groups[$prefixOf($def)][$k] = $def;
    $sections[$sec] = $groups;
}
?>
<form method="get" class="box setfind">
  <input type="search" name="q" value="<?= e($sq) ?>" placeholder="Search settings…" aria-label="Search settings by name or key">
  <select name="adv" data-autosubmit aria-label="Which settings to show"><option value="">Everyday settings</option><option value="1"<?= $showAdv ? ' selected' : '' ?>>Show advanced too</option></select>
  <button class="btn small">Search</button><?php if ($sq !== '' || $showAdv): ?> <a href="<?= e(url('admin/settings.php')) ?>">Clear</a><?php endif; ?>
  <p class="help"><?= $shownN ?> setting<?= $shownN === 1 ? '' : 's' ?> shown<?= $advHidden ? ', ' . $advHidden . ' advanced hidden (tick “Show advanced too”, or search for one)' : '' ?>. Save before you search: searching reloads the page.</p>
</form>
<?php if (!$sections): ?><div class="box"><p class="muted">No setting matches “<?= e($sq) ?>”.</p></div><?php endif; ?>
<nav class="chips jump"><?php foreach (array_keys($sections) as $sec): ?><a href="#s-<?= e(slugify($sec)) ?>"><?= e($sec) ?></a><?php endforeach; ?></nav>
<?php if ($sections): ?>
<form method="post" class="form">
  <?= csrf_field() ?><input type="hidden" name="q" value="<?= e($sq) ?>"><input type="hidden" name="adv" value="<?= $showAdv ? '1' : '' ?>">
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
<?php endif; ?>
<?php page_footer();
