<?php
declare(strict_types=1);
/**
 * 2.8.93 Map v2: builds game/includes/data/region_spread.json from the region planners' plan-<CODE>.json files (key 'spread').
 *   php tools/map_v2/spread_build.php PLANS_DIR            validate all 14 regions and write the file (writes nothing when a rule fails)
 *   php tools/map_v2/spread_build.php --check              validate the committed file instead (exit 0 / 1)
 * Seeds a throwaway SQLite world the way tools/map_layout.php does, with World v2 on (the spread is planned on that world's v1 layout).
 * Prints, per region: off slots covered, the smallest distances seen, and how many roots change side of their road (bow2 != bow; a report).
 * 'spread' shapes understood: {"<slot id>": [x, y]} (spread_helper.relax) or a list of {id, x, y}.
 */
if (PHP_SAPI !== 'cli') exit;
$check = in_array('--check', $argv, true);
$args = array_values(array_filter(array_slice($argv, 1), fn($a) => $a !== '--check'));
$plans = rtrim($args[0] ?? '', '/');
if (!$check && ($plans === '' || !is_dir($plans))) { fwrite(STDERR, "usage: php tools/map_v2/spread_build.php PLANS_DIR | --check\n"); exit(2); }
$game = dirname(__DIR__, 2) . '/game';
$out = $game . '/includes/data/region_spread.json';

define('APP_ROOT', $game);
define('APP_VERSION', preg_match("/define\\('APP_VERSION', '([0-9.]+)'\\)/", (string)file_get_contents($game . '/includes/bootstrap.php'), $m) ? $m[1] : '0');
require $game . '/includes/db.php';
require $game . '/includes/functions.php';
require $game . '/includes/pixel_art.php';
require $game . '/includes/seed.php';
require_once $game . '/includes/upgrade100.php';
$tmp = tempnam(sys_get_temp_dir(), 'gvspread');
$GLOBALS['CONFIG'] = ['db' => ['driver' => 'sqlite', 'path' => $tmp], 'base_url' => ''];
ob_start();
db_migrate(db(), 'sqlite');
db()->beginTransaction();
foreach (settings_schema() as $k => $def) set_setting($k, (string)$def['default']);
setting('__reload__');
seed_starter_content();
db()->commit();
require_once $game . '/includes/world_v2.php';
set_setting('world_v2_open', '1'); setting('__reload__');
world_v2_boot();
ob_end_clean();
require_once $game . '/includes/maps.php';
require_once $game . '/includes/region_layout.php';
require_once $game . '/includes/map_v2.php';
if (setting('world_v2_done') !== '1') { fwrite(STDERR, "World v2 did not boot on the throwaway world\n"); exit(1); }

$committed = $check ? json_decode((string)@file_get_contents($out), true) : null;
if ($check && !is_array($committed)) { echo "FAIL $out is missing or not JSON\n"; exit(1); }
$data = ['_meta' => ['v' => 1, 'sig' => [], 'slugs' => []]];
$fail = 0;
foreach (array_keys(REGION_MAP) as $code) {
    $L = region_layout($code, false);
    if ($check) $raw = $committed[$code] ?? null;
    else {
        $plan = json_decode((string)@file_get_contents("$plans/plan-$code.json"), true);
        $raw = $plan['spread'] ?? null;
    }
    if (!is_array($raw) || !$L) { echo "FAIL $code: no spread (or no layout)\n"; $fail++; continue; }
    $spread = [];
    foreach ($raw as $k => $v) {
        if (is_array($v) && isset($v['id'])) $spread[(int)$v['id']] = [(int)round((float)$v['x']), (int)round((float)$v['y'])];
        elseif (is_array($v) && count($v) >= 2) $spread[(int)$k] = [(int)round((float)$v[0]), (int)round((float)$v[1])];
    }
    ksort($spread);
    if ($check && ($committed['_meta']['sig'][$code] ?? '') !== rl_stop_sig($L)) { echo "FAIL $code: the road skeleton changed (sig)\n"; $fail++; }
    $r = rl_spread_problems($L, $spread);
    $mn = $r['min'];
    printf("%-4s %2d/%2d places, roots %2d, min gap places %s, own stop %s, other stop %s, road %s, longest root %s, %d change side%s\n", $code, count($spread), $r['off'], $r['roots'],
        $mn['places'] ?? '-', $mn['own_stop'] ?? '-', $mn['stop'] ?? '-', $mn['road'] ?? '-', $mn['root_longest'] ?? '-', count($r['side']), $r['side'] ? ' (' . implode(',', $r['side']) . ')' : '');
    foreach ($r['bad'] as $b) { echo "  FAIL $code: $b\n"; $fail++; }
    $data[$code] = array_combine(array_map('strval', array_keys($spread)), array_values($spread));
    $data['_meta']['sig'][$code] = rl_stop_sig($L);
    $sl = [];
    foreach (array_keys($spread) as $id) if (isset($L['slots'][$id])) $sl[(string)$id] = (string)$L['slots'][$id]['loc']['slug'];
    $data['_meta']['slugs'][$code] = $sl;
}
@unlink($tmp); @unlink($tmp . '-wal'); @unlink($tmp . '-shm');
if ($fail) { echo "$fail problems: " . ($check ? 'the committed file does not pass' : 'nothing written') . "\n"; exit(1); }
if ($check) { echo "region_spread.json passes\n"; exit(0); }
$json = json_encode($data, JSON_UNESCAPED_SLASHES);
$json = preg_replace('/,"(?=[A-Z_]{2,5}":)/', ",\n\"", $json);   // one region per line, so a diff shows which region moved
file_put_contents($out, $json . "\n");
echo "wrote $out\n";
