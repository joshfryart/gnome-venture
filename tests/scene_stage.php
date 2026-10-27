<?php
// v2.0.67: the stage chooser (scene_stage_key in includes/scene.php).
//   php tests/scene_stage.php             every land x weather x daypart resolves to a drawn file; the json maps are valid; baked dawn/dusk rules; fallbacks
//   php tests/scene_stage.php GAME_DIR    on an INSTALLED copy (scenes.sh runs it): weather_force picks the art, adventure_stage_html carries it
//   (internal) php tests/scene_stage.php --fake DIR   fallback checks against a scenes folder with a broken / missing json
$bad = 0;
$t = function (bool $ok, string $m) use (&$bad) { echo ($ok ? 'ok   ' : 'FAIL ') . $m . "\n"; if (!$ok) $bad++; };
const LANDS = ['grassland', 'forest', 'coast', 'mountain', 'wetland', 'desert', 'rainforest', 'tundra', 'island'];
const WEATHERS = ['sun', 'cloud', 'rain', 'storm', 'frost', 'heat', 'wind', 'fog', 'snow'];
const DAYPARTS = ['dawn', 'day', 'dusk', 'night'];

$mode = $argv[1] ?? '';
if ($mode !== '' && $mode !== '--fake') {
    // ---- installed copy: real settings and clock
    $_SERVER['SCRIPT_NAME'] = '/adventure.php';
    require $mode . '/includes/bootstrap.php';
    require_once $mode . '/includes/scene.php';
    set_setting('weather_force', 'storm'); setting('__reload__');
    $t(hollow_weather('NA') === 'storm', 'weather_force storm holds');
    $t(scene_stage_key('forest') === 'forest-storm', 'forced storm: forest -> forest-storm (any daypart)');
    $t(scene_stage_key('coast', 'storm', 'dawn') === 'coast-storm', 'storm at dawn: weather art, no baked dawn');
    $u = q_one("SELECT * FROM users WHERE username = 'sprout'") ?: ['id' => 0, 'gnome_name' => 'Bramble'];
    $rid = (int)q_val("SELECT id FROM regions WHERE code = 'NA'");
    $h = adventure_stage_html($u, ['hp' => 10, 'max_hp' => 10], ['land' => 'forest', 'region_id' => $rid], null);
    $t(str_contains($h, 'stage-forest-storm.png'), 'adventure stage shows the forced weather art');
    $t(str_contains($h, 'scene-fb-forest"'), 'fallback colours stay the plain land');
    $t(str_contains($h, 'data-we="storm"') && preg_match('/data-dp="(dawn|day|dusk|night)"/', $h) === 1, 'stage carries data-dp and data-we');
    set_setting('weather_force', 'sun'); setting('__reload__');
    $h = adventure_stage_html($u, ['hp' => 10, 'max_hp' => 10], ['land' => 'grassland', 'region_id' => $rid], null);
    $want = 'stage-' . scene_stage_key('grassland', 'sun', hollow_daypart()) . '.png';
    $t(str_contains($h, $want), 'forced sun: grassland stage is ' . $want);
    set_setting('weather_force', ''); setting('__reload__');
    $t(scene_stage_key('desert') === scene_stage_key('desert'), 'same request, same art (deterministic)');
    exit($bad ? 1 : 0);
}

// ---- standalone: stubs like scene_smoke.php
define('APP_ROOT', $mode === '--fake' ? $argv[2] : dirname(__DIR__) . '/game');
if (!function_exists('e')) {   // inside a block so they are not hoisted over the installed-copy run's real ones
    function e($s) { return htmlspecialchars((string)$s, ENT_QUOTES); }
    function url($p) { return $p; }
    function art_path($p) { return is_file(APP_ROOT . '/' . $p) ? $p : ''; }
}
require dirname(__DIR__) . '/game/includes/scene.php';
$dir = APP_ROOT . '/assets/img/scenes';

if ($mode === '--fake') {
    $t(scene_stage_key('grassland', 'storm', 'day') === 'grassland', 'invalid json -> stage-grassland');
    $t(scene_stage_key('forest', 'rain', 'day') === 'forest', 'missing json -> stage-forest');
    $t(scene_stage_key('coast', 'storm', 'day') === 'coast', 'json names a missing file -> stage-coast');
    $t(scene_stage_key('coast', 'sun', 'dawn') === 'coast', 'baked dawn file missing -> plain land');
    $t(scene_stage_key('coast', 'fog', 'day') === 'coast-fog', 'valid entry still used');
    exit($bad ? 1 : 0);
}

// json maps
foreach (LANDS as $l) {
    $f = "$dir/stage-weather-$l.json";
    $j = is_file($f) ? json_decode((string)file_get_contents($f), true) : null;
    $okKeys = is_array($j) && count(array_diff(WEATHERS, array_keys($j))) === 0;
    $missing = [];
    foreach (is_array($j) ? $j : [] as $w => $k) if (!is_string($k) || !is_file("$dir/stage-$k.png")) $missing[] = "$w=>" . json_encode($k);
    $t($okKeys && !$missing, "json $l: all 9 weathers, every file drawn" . ($missing ? ' (missing ' . implode(', ', $missing) . ')' : ''));
    $t(is_file("$dir/stage-$l.png"), "stage-$l.png drawn");
}
// every land x weather x daypart
$n = 0; $miss = [];
foreach (LANDS as $l) foreach (WEATHERS as $w) foreach (DAYPARTS as $d) {
    $k = scene_stage_key($l, $w, $d);
    $n++;
    if ($k === '' || !is_file("$dir/stage-$k.png")) $miss[] = "$l/$w/$d=>$k";
}
$t(!$miss, "$n land x weather x daypart picks resolve to a drawn file" . ($miss ? ': ' . implode(' ', array_slice($miss, 0, 8)) : ''));
// the rules
$t(scene_stage_key('grassland', 'sun', 'day') === 'grassland', 'sun + day = plain land');
$t(scene_stage_key('grassland', 'rain', 'day') === 'grassland-v3', 'rain follows the json');
$t(scene_stage_key('wetland', 'rain', 'dawn') === 'wetland-v2', 'wetland v2 is rain art, not dawn');
$t(scene_stage_key('grassland', 'sun', 'dawn') === 'grassland-v2' && scene_stage_key('grassland', 'cloud', 'dawn') === 'grassland-v2', 'dawn + sun/cloud = baked dawn');
$t(scene_stage_key('grassland', 'rain', 'dawn') === 'grassland-v3', 'dawn + rain = weather art (no baked dawn)');
$t(scene_stage_key('forest', 'sun', 'dawn') === 'forest', 'forest has no dawn art (v2 is autumn afternoon)');
$t(scene_stage_key('forest', 'sun', 'dusk') === 'forest-v2' && scene_stage_key('coast', 'sun', 'dusk') === 'coast-v2', 'dusk + sun = warm v2 (forest, coast)');
$t(scene_stage_key('grassland', 'sun', 'dusk') === 'grassland', 'grassland dusk = day art (+ CSS tint)');
$t(scene_stage_key('mountain', 'sun', 'night') === 'mountain' && scene_stage_key('tundra', 'snow', 'night') === 'tundra-v3', 'night = weather art (+ CSS tint)');
$t(scene_stage_baked('coast', 'sun', 'dusk') && !scene_stage_baked('coast', 'rain', 'dusk') && !scene_stage_baked('coast', 'sun', 'night'), 'scene_stage_baked');
foreach (DAYPART_STAGE_ART as $l => $row) foreach ($row as $d => $k) {
    if ($k !== null) $t(is_file("$dir/stage-$k.png") && str_starts_with($k, $l . '-'), "baked $l/$d = $k drawn");
}
$t(scene_stage_key('nowhere', 'sun', 'day') === 'nowhere', 'unknown land: the land key, no error');
$t(scene_stage_key('../x', 'sun', 'day') === '', 'bad land key rejected');
$t(scene_stage_key('forest', 'blizzard', 'day') === 'forest', 'unknown weather -> plain land');
$t(scene_stage_key('forest') !== '', 'null weather/daypart without the clock loaded: no error');
$h = scene_stage('stage', scene_stage_key('coast', 'sun', 'dusk'), [], 'advstage', 'coast', ['dp' => 'dusk', 'we' => 'sun', 'baked' => true]);
$t(str_contains($h, 'stage-coast-v2.png') && str_contains($h, 'scene-fb-coast"') && str_contains($h, 'data-baked="1"') && str_contains($h, 'data-dp="dusk"'), 'stage markup: baked art, plain-land fallback, look attrs');
$h = scene_stage('stage', 'forest', [], 'advstage', 'forest', ['dp' => '"><x', 'we' => '<b>']);
$t(!str_contains($h, 'data-dp') && !str_contains($h, 'data-we') && !str_contains($h, '<b>'), 'bad look values dropped');

// fallbacks: a scenes folder with a broken json, a missing json and a json naming a missing file
$tmp = sys_get_temp_dir() . '/gv_stage_' . getmypid();
@mkdir("$tmp/assets/img/scenes", 0777, true);
foreach (['grassland', 'grassland-storm', 'forest', 'forest-v3', 'coast', 'coast-fog'] as $k) copy("$dir/stage-$k.png", "$tmp/assets/img/scenes/stage-$k.png");
file_put_contents("$tmp/assets/img/scenes/stage-weather-grassland.json", '{"storm": "grassland-storm",');
file_put_contents("$tmp/assets/img/scenes/stage-weather-coast.json", json_encode(['storm' => 'coast-storm', 'fog' => 'coast-fog']));
passthru(escapeshellarg(PHP_BINARY) . ' ' . escapeshellarg(__FILE__) . ' --fake ' . escapeshellarg($tmp), $rc);
$t($rc === 0, 'fallback run');
array_map('unlink', glob("$tmp/assets/img/scenes/*"));
@rmdir("$tmp/assets/img/scenes"); @rmdir("$tmp/assets/img"); @rmdir("$tmp/assets"); @rmdir($tmp);
exit($bad ? 1 : 0);
