<?php
declare(strict_types=1);
require __DIR__ . '/includes/bootstrap.php';
$u = require_login();
$region = hollow_user_region($u);
$n = hollow_now($region);
$fc = hollow_forecast($region, 3);
$next = hollow_next_season();
$chances = hollow_weather_chances($n['season'], $region);
arsort($chances);
$regions = q('SELECT code, gnomish_name AS name, real_name FROM regions ORDER BY id')->fetchAll();
page_header('Seasons & weather');
?>
<h1>🌦️ Seasons &amp; weather</h1>
<div class="box">
  <p><b><?= e(hollow_line($region)) ?></b></p>
  <p class="muted"><?= e(HOLLOW_SEASONS[$n['season']][3]) ?> <?= e(HOLLOW_WEATHER[$n['weather']][3]) ?>
    <?= $n['mode'] === 'game' ? 'Day ' . $n['season_day'] . ' of ' . $n['season_length'] . '.' : 'Following the real calendar.' ?>
    <?= e(HOLLOW_SEASONS[$next['season']][0] . ' ' . HOLLOW_SEASONS[$next['season']][1]) ?> begins in <?= (int)$next['in_days'] ?> day<?= $next['in_days'] === 1 ? '' : 's' ?>.
    <?= $n['season_forced'] || $n['weather_forced'] ? '<br><small>(An override is on' . ($n['season_forced'] ? ': season' : '') . ($n['weather_forced'] ? ': today’s weather' : '') . '.)</small>' : '' ?></p>
</div>

<h2>Forecast</h2>
<div class="fcgrid">
<?php foreach ($fc as $f): ?>
  <div class="box"><b><?= e($f['label']) ?></b><div style="font-size:2rem" aria-hidden="true"><?= $f['emoji'] ?></div><?= e($f['wlabel']) ?></div>
<?php endforeach; ?>
</div>

<h2>The year</h2>
<div class="seasonrow">
<?php foreach (HOLLOW_SEASONS as $k => $s): ?>
  <div class="box<?= $k === $n['season'] ? ' cur' : '' ?>"><div style="font-size:1.8rem" aria-hidden="true"><?= $s[0] ?></div><b><?= e($s[1]) ?></b><br><small class="muted"><?= $n['mode'] === 'game' ? hollow_season_length() . ' days' : '3 months' ?></small></div>
<?php endforeach; ?>
</div>

<h2>What <?= e(HOLLOW_SEASONS[$n['season']][1]) ?> weather is like</h2>
<table class="wxtable">
<?php foreach ($chances as $k => $pct): if ($pct <= 0) continue; ?>
  <tr><td><?= HOLLOW_WEATHER[$k][0] ?> <?= e(HOLLOW_WEATHER[$k][1]) ?></td><td><?= $pct ?>%</td></tr>
<?php endforeach; ?>
</table>

<h2>Around the world today</h2>
<table class="wxtable">
<?php foreach ($regions as $r): $w = hollow_weather_info(hollow_weather($r['code']), 'day'); ?>
  <tr><td><?= e($r['name']) ?> <small class="muted">(<?= e($r['real_name']) ?>)</small></td><td><?= $w['emoji'] ?> <?= e($w['label']) ?></td></tr>
<?php endforeach; ?>
</table>
<?php if (is_admin()): ?><p class="muted"><a href="<?= e(url('admin/settings.php#s-seasons-weather')) ?>">Admin: seasons &amp; weather settings and overrides</a></p><?php endif; ?>
<?php page_footer();
