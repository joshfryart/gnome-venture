<?php
declare(strict_types=1);
/**
 * 2.8.93 Map v2: why a region is (or is not) on the lit floor map on this site.  php tools/map_v2/status.php GAME_DIR   (an installed game)
 * Per region: picture yes/no, road skeleton fingerprint match yes/no, off-road places covered n of m, on/off. Then the same for the world map.
 */
if (PHP_SAPI !== 'cli') exit;
$game = rtrim($argv[1] ?? dirname(__DIR__, 2) . '/game', '/');
if (!is_file($game . '/config.php')) { fwrite(STDERR, "usage: php tools/map_v2/status.php GAME_DIR (an installed game)\n"); exit(2); }
$_SERVER['SCRIPT_NAME'] = '/index.php';
require $game . '/includes/bootstrap.php';
require_once APP_ROOT . '/includes/maps.php';
require_once APP_ROOT . '/includes/region_layout.php';
$all = rl_spread_all();
echo 'map_v2_open = ' . setting('map_v2_open') . ', world_v2_open = ' . setting('world_v2_open') . ', data version ' . rl_spread_ver() . "\n";
foreach (array_keys(REGION_MAP) as $code) {
    $L = region_layout($code, false);
    $pic = scene_path('map2', $code) !== '';
    $sig = $L && ($all['_meta']['sig'][$code] ?? '') === rl_stop_sig($L);
    $off = 0; foreach ($L['slots'] ?? [] as $s) if ($s['type'] === 'off') $off++;
    $sp = rl_spread_for($code);
    printf("%-4s picture %-3s fingerprint %-3s places %2d of %2d  %s\n", $code, $pic ? 'yes' : 'no', $sig ? 'yes' : 'no', $sp ? count($sp) : 0, $off, map_v2_region_on($code) ? 'ON' : 'old map');
}
printf("world picture %s, layout %s, World v2 %s  %s\n", scene_path('map2', 'world') !== '' ? 'yes' : 'no', world2_layout() ? 'yes' : 'no', world_v2_on() ? 'on' : 'off', map_v2_world_on() ? 'ON' : 'old map');
