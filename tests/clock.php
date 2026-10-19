<?php
// v1.0.0 backbone: the Hollow clock (includes/hollow_clock.php). Run by clock.sh on a fresh install.
$_SERVER['SCRIPT_NAME'] = '/index.php';
require $argv[1] . '/includes/bootstrap.php';
$fails = 0;
function ok(string $what, bool $cond, string $extra = ''): void { global $fails; echo ($cond ? '  ok   ' : '  FAIL ') . $what . ($cond ? '' : "  $extra") . "\n"; if (!$cond) $fails++; }
function cfg(array $kv): void { foreach ($kv as $k => $v) set_setting($k, (string)$v); setting('__reload__'); }
function sd(string $d): string { return hollow_season($d) . ' d' . hollow_season_day($d); }

echo "== migration\n";
ok('season_epoch stored by upgrade_100_clock', (bool)q_val("SELECT 1 FROM settings WHERE name='season_epoch'"));
ok('Almanac page made', (bool)q_val("SELECT 1 FROM encyclopedia_entries WHERE title='Seasons & weather'"));
$e1 = setting('season_epoch'); upgrade_100_clock();
ok('upgrade is idempotent', setting('season_epoch') === $e1 && q_val("SELECT COUNT(*) FROM encyclopedia_entries WHERE title='Seasons & weather'") == 1);

echo "== game seasons (epoch 2026-01-01, 14 days each)\n";
cfg(['season_mode' => 'game', 'season_days' => 14, 'season_epoch' => '2026-01-01', 'season_force' => '', 'weather_force' => '']);
foreach (['2026-01-01' => 'spring d1', '2026-01-14' => 'spring d14', '2026-01-15' => 'summer d1', '2026-01-29' => 'autumn d1', '2026-02-12' => 'winter d1', '2026-02-25' => 'winter d14',
          '2026-02-26' => 'spring d1', '2025-12-31' => 'winter d14', '2026-10-16' => 'spring d9'] as $d => $want) ok("$d = $want", sd($d) === $want, 'got ' . sd($d));
cfg(['season_days' => 10]);
ok('season_days=10: 2026-01-11 summer d1', sd('2026-01-11') === 'summer d1', sd('2026-01-11'));
ok('season length reported', hollow_season_days_total('2026-01-11') === 10);
cfg(['season_days' => 14, 'season_epoch' => 'junk']);
ok('bad epoch falls back to 2026-01-01', sd('2026-01-15') === 'summer d1');
cfg(['season_epoch' => '2026-01-01']);
ok('season_code', hollow_season_code('autumn') === 'au' && hollow_season_code('winter') === 'wi');
ok('hollow_in_season', hollow_in_season('', '2026-01-01') && hollow_in_season('spring,summer', '2026-01-15') && !hollow_in_season('spring,summer', '2026-01-29'));
$nx = hollow_next_season();
ok('next season', in_array($nx['season'], array_keys(HOLLOW_SEASONS)) && $nx['in_days'] >= 1 && $nx['in_days'] <= 14);

echo "== real seasons (northern hemisphere)\n";
cfg(['season_mode' => 'real']);
foreach (['2026-03-01' => 'spring d1', '2026-02-28' => 'winter d90', '2026-12-01' => 'winter d1', '2026-01-15' => 'winter d46', '2026-06-01' => 'summer d1', '2026-11-30' => 'autumn d91', '2026-09-01' => 'autumn d1', '2026-05-31' => 'spring d92'] as $d => $want) ok("$d = $want", sd($d) === $want, 'got ' . sd($d));
ok('total days winter 2025-26 = 90', hollow_season_days_total('2026-02-01') === 90);
cfg(['season_mode' => 'game']);

echo "== overrides\n";
cfg(['season_force' => 'autumn']);
ok('season_force wins on any date', hollow_season('2026-01-01') === 'autumn' && hollow_season() === 'autumn' && hollow_now()['season_forced']);
cfg(['season_force' => 'nonsense']);
ok('bad season_force ignored', hollow_season('2026-01-01') === 'spring');
cfg(['season_force' => '']);
$today = hollow_today(); $tom = hollow_date_add($today, 1);
$natT = hollow_weather(null, $tom);
cfg(['weather_force' => 'fog']);
ok('weather_force changes today everywhere', hollow_weather() === 'fog' && hollow_weather('MENA') === 'fog' && hollow_now()['weather_forced']);
ok('weather_force leaves tomorrow alone', hollow_weather(null, $tom) === $natT);
cfg(['weather_force' => '']);

echo "== weather\n";
$seen = []; $bad = 0; $stable = true; $diff = 0;
for ($i = 0; $i < 400; $i++) {
    $d = hollow_date_add('2026-01-01', $i);
    $w = hollow_weather(null, $d); $w2 = hollow_weather(null, $d);
    if ($w !== $w2) $stable = false;
    if (!isset(HOLLOW_WEATHER[$w])) $bad++;
    $s = hollow_season($d);
    if (($s === 'summer' && in_array($w, ['snow', 'frost'], true)) || ($s === 'winter' && $w === 'heat') || ($s !== 'winter' && $w === 'snow')) $bad++;
    $seen[$w] = ($seen[$w] ?? 0) + 1;
    if (hollow_weather('MENA', $d) !== $w) $diff++;
}
ok('deterministic', $stable);
ok('only valid weathers, none out of season', $bad === 0, "bad=$bad");
ok('all nine appear over 400 days', count($seen) === 9, json_encode($seen));
ok('regions differ from the Hollow', $diff > 50, "diff=$diff");
$dry = 0; $wet = 0; for ($i = 0; $i < 400; $i++) { $d = hollow_date_add('2026-01-01', $i); $dry += hollow_weather('MENA', $d) === 'rain'; $wet += hollow_weather('SEA', $d) === 'rain'; }
ok('desert dry, jungle wet', $dry < $wet / 3 && $wet > 80, "dry=$dry wet=$wet");
ok('region code is case-insensitive', hollow_weather('mena', '2026-05-05') === hollow_weather('MENA', '2026-05-05'));
cfg(['weather_regions' => '0']);
ok('weather_regions off = same as the Hollow', hollow_weather('MENA', '2026-05-05') === hollow_weather(null, '2026-05-05'));
cfg(['weather_regions' => '1', 'weather_weights_spring' => 'snow:1']);
ok('custom weights: all snow', hollow_weather(null, '2026-01-03') === 'snow' && hollow_weather('MENA', '2026-01-03') === 'snow' || hollow_weather('MENA', '2026-01-03') === 'sun');
cfg(['weather_weights_spring' => 'nonsense, x:y']);
ok('junk weights fall back to defaults', hollow_weather_weights('spring')['rain'] > 0);
cfg(['weather_weights_spring' => 'sun:0, rain:0']);
ok('all-zero weights give a fixed fallback', in_array(hollow_weather(null, '2026-01-03'), ['sun', 'cloud', 'rain', 'storm', 'frost', 'heat', 'wind', 'fog', 'snow'], true));
cfg(['weather_weights_spring' => HOLLOW_WEIGHT_DEFAULTS['spring']]);
ok('chances sum to ~100', abs(array_sum(hollow_weather_chances('winter')) - 100) <= 4);
ok('fixed day, fixed weather (regression)', hollow_weather(null, '2026-03-15') === hollow_weather(null, '2026-03-15'));
echo '  info 2026-03-15: ', hollow_weather(null, '2026-03-15'), ' / NA ', hollow_weather('NA', '2026-03-15'), "\n";

echo "== day parts\n";
cfg(['daypart_dawn' => 5, 'daypart_day' => 7, 'daypart_dusk' => 18, 'daypart_night' => 21]);
foreach ([0 => 'night', 4 => 'night', 5 => 'dawn', 6 => 'dawn', 7 => 'day', 17 => 'day', 18 => 'dusk', 20 => 'dusk', 21 => 'night', 23 => 'night', 25 => 'night', -1 => 'night'] as $h => $want) ok("hour $h = $want", hollow_daypart($h) === $want, hollow_daypart($h));
cfg(['daypart_dawn' => 9, 'daypart_day' => 7]);
ok('bad order falls back to 5/7/18/21', hollow_daypart(6) === 'dawn' && hollow_daypart(12) === 'day');
cfg(['daypart_dawn' => 5, 'daypart_day' => 7]);
ok('daypart() with no hour = now', hollow_daypart() === hollow_daypart(hollow_hour()));

echo "== hollow_now / forecast / chip\n";
$ts = 1760000000;
$n = hollow_now('NA', $ts);
ok('hollow_now fields', isset($n['season'], $n['season_day'], $n['season_length'], $n['weather'], $n['daypart'], $n['season_emoji'], $n['weather_emoji'], $n['daypart_emoji'], $n['date'], $n['hour']));
ok('hollow_now uses the timestamp', $n['date'] === hollow_date('Y-m-d', $ts) && $n['hour'] === (int)hollow_date('G', $ts) && $n['season'] === hollow_season($n['date']));
ok('same timestamp twice = identical', $n === hollow_now('NA', $ts));
$f = hollow_forecast('NA', 3);
ok('forecast has today + 2', count($f) === 3 && $f[0]['label'] === 'Today' && $f[1]['label'] === 'Tomorrow' && $f[0]['date'] === hollow_today());
ok('forecast day 1 matches weather()', $f[1]['weather'] === hollow_weather('NA', $f[1]['date']));
$chip = hollow_chip('NA');
ok('chip has season, weather, daypart', str_contains($chip, 'class="st hollow"') && str_contains($chip, hollow_now('NA')['season_label']) && str_contains($chip, 'seasons.php'));
ok('chip is escaped HTML only', !preg_match('/<script/i', $chip));
ok('line text', (bool)preg_match('/ · day \d+ · .* · /', hollow_line()));
ok('rail section', str_contains(hollow_rail_section(), 'rhollow'));
ok('sun at night reads Clear', hollow_weather_info('sun', 'night')['label'] === 'Clear' && hollow_weather_info('sun', 'day')['label'] === 'Sunny');

echo $fails ? "FAILED: $fails\n" : "all ok\n";
exit($fails ? 1 : 0);
