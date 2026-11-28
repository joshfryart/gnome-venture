<?php
// 2.8.93 Map v2 (includes/map_v2.php, setting map_v2_open; claude/proposal-map-v2-code.md section 8).
// Off = every map byte-for-byte as before (golden hashes in tests/fixtures/map_v2_off.json, recorded on the code before Map v2);
// on = the spread layout (region_spread.json), the lit floor region widget, the delve-down world map (world_v2_layout.json).
// Run by map_v2.sh on a walk.sh install:   php tests/map_v2.php GAME
//   php tests/map_v2.php GAME --write-golden   (re-record the fixture; boots World v2 on that copy, so use a throwaway install)
//   php tests/map_v2.php GAME --hashes         (internal: prints the hash set for the current settings as JSON, fresh process = fresh statics)
$GAME = rtrim($argv[1] ?? '', '/');
$MODE = $argv[2] ?? '';
$_SERVER['SCRIPT_NAME'] = '/index.php';
require $GAME . '/includes/bootstrap.php';
require_once APP_ROOT . '/includes/maps.php';
require_once APP_ROOT . '/includes/region_layout.php';
require_once APP_ROOT . '/includes/adventure.php';
require_once APP_ROOT . '/includes/world_v2.php';
if (is_file(APP_ROOT . '/includes/map_v2.php')) require_once APP_ROOT . '/includes/map_v2.php';
$FIX = __DIR__ . '/fixtures/map_v2_off.json';
$fails = 0;
function ok(string $what, bool $cond, string $extra = ''): void { global $fails; echo ($cond ? 'ok   ' : 'FAIL ') . $what . ($cond ? '' : "  ($extra)") . "\n"; if (!$cond) $fails++; }
function setg(string $k, string $v): void { set_setting($k, $v); setting('__reload__'); }
/** strip what changes between releases or requests and is not the map: the asset version and the CSRF token */
function mv2_norm(string $s): string
{
    $s = preg_replace('~\?v=[0-9][0-9.]*~', '?v=VER', $s);
    $s = preg_replace('~name="csrf" value="[^"]*"~', 'name="csrf" value=""', $s);
    return preg_replace('~name="_n" value="[^"]*"~', 'name="_n" value=""', $s);
}
/** the probe gnome: level 1, standing at the Maplewold's market, nothing found, no plots, no walk, no destination */
function mv2_probe(): array
{
    $id = (int)q_val("SELECT id FROM users WHERE username = 'mapv2probe'");
    $na = q_one("SELECT id FROM regions WHERE code = 'NA'");
    $town = (int)q_val("SELECT id FROM locations WHERE region_id = ? AND kind = 'market' ORDER BY id LIMIT 1", [(int)$na['id']]);
    if (!$id) {
        q("INSERT INTO users (username, email, password_hash, gnome_name, onboarded, level, region_id, location_id, created_at) VALUES ('mapv2probe', 'mapv2probe@b.local', 'x', 'Probe', 1, 1, ?, ?, '2020-01-01 00:00:00')", [(int)$na['id'], $town]);
        $id = (int)q_val("SELECT id FROM users WHERE username = 'mapv2probe'");
    }
    return q_one('SELECT * FROM users WHERE id = ?', [$id]);
}
function mv2_hashes(array $u): array
{
    $h = [];
    foreach (array_keys(REGION_MAP) as $code) {
        $rid = (int)q_val('SELECT id FROM regions WHERE code = ?', [$code]);
        $h["r:$code"] = sha1(mv2_norm(region_map_svg($u, $rid)));
        $h["rf:$code"] = sha1(mv2_norm(region_map_svg($u, $rid, 0, true)));
        $h["l:$code"] = sha1(json_encode(region_layout($code)));
    }
    $h['world'] = sha1(mv2_norm(world_map_svg($u)));
    $h['pos'] = sha1(json_encode(map_positions()));
    return $h;
}
/** the hash set in a fresh PHP process (fresh statics), for the settings now in the database */
function mv2_hashes_fresh(): array
{
    global $GAME;
    $out = shell_exec('php -d session.save_path=/tmp ' . escapeshellarg(__FILE__) . ' ' . escapeshellarg($GAME) . ' --hashes 2>&1');
    $j = json_decode((string)$out, true);
    if (!is_array($j)) { echo "diag hashes process said: " . substr((string)$out, 0, 600) . "\n"; return []; }
    return $j;
}
/** which keys of $got differ from $want */
function mv2_diff(array $got, array $want, string $prefix = ''): array
{
    $bad = [];
    foreach ($want as $k => $v) if ($prefix === '' || str_starts_with($k, $prefix)) if (($got[$k] ?? '') !== $v) $bad[] = $k;
    return $bad;
}

$probe = mv2_probe();
if ($MODE === '--hashes') { echo json_encode(mv2_hashes($probe)); exit(0); }
if ($MODE === '--pos-ids') { echo json_encode(array_keys(map_positions())); exit(0); }
if ($MODE === '--boot-world-v2') { setg('world_v2_open', '1'); world_v2_boot(); echo "booted\n"; exit(0); }
if ($MODE === '--write-golden') {
    if (setting('world_v2_open') === '1') { echo "FAIL write the golden on a fresh install (World v2 is already on here)\n"; exit(1); }
    $g = ['_note' => 'Map v2 golden hashes (tests/map_v2.php --write-golden), recorded on the code before Map v2 with map_v2_open = 0. Re-record only for an intended change to the old maps.'];
    $g['world_v1'] = mv2_hashes_fresh();
    echo shell_exec('php ' . escapeshellarg(__FILE__) . ' ' . escapeshellarg($GAME) . ' --boot-world-v2 2>&1');
    $g['world_v2'] = mv2_hashes_fresh();
    if (count($g['world_v1']) !== 44 || count($g['world_v2']) !== 44) { echo "FAIL hash sets incomplete\n"; exit(1); }
    file_put_contents($FIX, json_encode($g, JSON_PRETTY_PRINT | JSON_UNESCAPED_SLASHES) . "\n");
    echo "wrote $FIX\n";
    exit(0);
}
if ($MODE === '--set') { setg($argv[3], $argv[4]); echo "set {$argv[3]} = {$argv[4]}\n"; exit(0); }

$G = json_decode((string)@file_get_contents($FIX), true);
if (!is_array($G) || !isset($G['world_v1'], $G['world_v2'])) { echo "FAIL fixture $FIX is missing\n"; exit(1); }
$SP = APP_ROOT . '/includes/data/region_spread.json';
$SCN = APP_ROOT . '/assets/img/scenes/';
$codes = array_keys(REGION_MAP);
/** run $fn with a file moved out of the way, then put it back */
function mv2_without(string $file, callable $fn)
{
    $tmp = $file . '.mv2away';
    $had = is_file($file);
    if ($had) rename($file, $tmp);
    try { return $fn(); } finally { if ($had) rename($tmp, $file); map_v2_flush(); }
}

echo "== 8.1 off = unchanged (World v2 off)\n";
ok('map_v2_open defaults to 0 on a fresh install', setting('map_v2_open') === '0');
ok('the setting is in the settings schema with a label', isset(settings_schema()['map_v2_open']['label']) && settings_schema()['map_v2_open']['default'] === '0');
$h = mv2_hashes_fresh();
$bad = mv2_diff($h, $G['world_v1']);
ok('with it 0 every map is byte-for-byte as before (14 regions x region map, focus map, layout; world map; positions)', count($h) === 44 && !$bad, implode(',', $bad));
setg('map_v2_open', '1'); map_v2_flush();
$on = array_filter($codes, fn($c) => map_v2_region_on($c));
ok('with it 1 and World v2 off: no region fits (the spread was planned on the World v2 layout), the world map stays old', !$on && !map_v2_world_on(), implode(',', $on));
$h = mv2_hashes_fresh();
$bad = mv2_diff($h, $G['world_v1']);
ok('... and every map is still the old one', !$bad, implode(',', $bad));
$out = []; exec('php ' . escapeshellarg(dirname(__DIR__) . '/tools/map_layout.php') . ' --check ' . escapeshellarg($GAME) . ' 2>&1', $out, $rc);
ok('tools/map_layout.php --check passes with map_v2_open = 1 (it is pinned to the v1 layouts)', $rc === 0, implode(' ', $out));
setg('map_v2_open', '0');

echo "== 8.1 off = unchanged (World v2 on)\n";
echo shell_exec('php ' . escapeshellarg(__FILE__) . ' ' . escapeshellarg($GAME) . ' --boot-world-v2 2>&1');
setting('__reload__'); map_v2_flush();
ok('World v2 is on and booted', setting('world_v2_open') === '1' && setting('world_v2_done') === '1');
$h = mv2_hashes_fresh();
$bad = mv2_diff($h, $G['world_v2']);
ok('with map_v2_open 0 every map is byte-for-byte as before', count($h) === 44 && !$bad, implode(',', $bad));
$old = json_decode((string)shell_exec('php ' . escapeshellarg(__FILE__) . ' ' . escapeshellarg($GAME) . ' --pos-ids 2>&1'), true);   // the places the old world map has a position for
setg('map_v2_open', '1'); map_v2_flush();
$h = mv2_without($SP, fn() => mv2_hashes_fresh());
$bad = array_merge(mv2_diff($h, $G['world_v2'], 'r:'), mv2_diff($h, $G['world_v2'], 'rf:'), mv2_diff($h, $G['world_v2'], 'l:'));
ok('with it 1 but region_spread.json gone: every region map and layout is the old one', !$bad, implode(',', $bad));
$artCodes = array_values(array_filter($codes, fn($c) => scene_path('map2', $c) !== ''));
echo "diag regions with a map2 picture: " . (implode(' ', $artCodes) ?: 'none') . "\n";
$one = $artCodes[0] ?? null;
if ($one) {
    $rid1 = (int)q_val('SELECT id FROM regions WHERE code = ?', [$one]);
    [$h, $art, $blk] = mv2_without($SCN . "map2-$one.png", fn() => [mv2_hashes_fresh(), region_art_path($rid1), region_map_block($probe, $rid1)]);
    $bad = array_filter(["r:$one", "rf:$one", "l:$one"], fn($k) => ($h[$k] ?? '') !== $G['world_v2'][$k]);
    ok("with map2-$one.png gone: $one is the old map and layout, region_art_path gives map-$one.png, no widget", !$bad && $art === "assets/img/scenes/map-$one.png" && $blk === '', implode(',', $bad) . " art=$art");
} else echo "diag no map2-<CODE>.png yet: the per-region art fallback is checked once one is drawn\n";
$h = mv2_without($SCN . 'map2-world.png', fn() => mv2_hashes_fresh());
ok('with map2-world.png gone: the world map and positions are the old ones', ($h['world'] ?? '') === $G['world_v2']['world'] && ($h['pos'] ?? '') === $G['world_v2']['pos']);
map_v2_flush();

echo "== 8.2 the spread data (World v2 on, Map v2 on)\n";
$all = json_decode((string)@file_get_contents($SP), true);
$keys = is_array($all) ? array_values(array_diff(array_keys($all), ['_meta'])) : [];
sort($keys); $want = $codes; sort($want);
ok('region_spread.json parses; its regions are exactly the 14 codes; _meta.sig and _meta.slugs have the same 14', $keys === $want && count((array)($all['_meta']['sig'] ?? [])) === 14 && count((array)($all['_meta']['slugs'] ?? [])) === 14, implode(',', $keys));
$sigBad = []; $cov = []; $frame = []; $tot = 0; $probs = []; $mins = ['places' => INF, 'own_stop' => INF, 'stop' => INF, 'road' => INF, 'root_longest' => 0]; $sides = 0; $roots = 0; $noRoot = 0;
foreach ($codes as $c) {
    $L1 = region_layout($c, false);
    if (rl_stop_sig($L1) !== ($all['_meta']['sig'][$c] ?? '') || rl_spread_for($c) === null) $sigBad[] = $c;
    $sp = rl_spread_for($c) ?? [];
    $offIds = []; foreach ($L1['slots'] as $id => $s) if ($s['type'] === 'off') { $offIds[] = (int)$id; if (!$s['anchor']) $noRoot++; }
    $k = array_keys($sp); sort($k); sort($offIds);
    if ($k !== $offIds) $cov[] = $c;
    $tot += count($offIds);
    if ($c === 'NA') echo "diag NA has " . count($offIds) . " places off the road\n";
    foreach ($sp as $id => $p) if ($p[0] < 12 || $p[0] > 468 || $p[1] < 12 || $p[1] > 258) $frame[] = "$c:$id";
    $r = rl_spread_problems($L1, $sp);
    foreach ($r['bad'] as $b) $probs[] = "$c: $b";
    foreach ($r['min'] as $mk => $mv) if ($mv !== null) $mins[$mk] = $mk === 'root_longest' ? max($mins[$mk], $mv) : min($mins[$mk], $mv);
    $sides += count($r['side']); $roots += $r['roots'];
}
ok('every region: the road skeleton fingerprint matches and the spread fits', !$sigBad, implode(',', $sigBad));
ok("coverage: every off-road slot has a spread point and nothing else does ($tot places)", !$cov && $tot > 300, implode(',', $cov));
ok('every spread point is inside 12..468 x 12..258', !$frame, implode(',', array_slice($frame, 0, 6)));
echo 'diag smallest gaps seen: ' . json_encode($mins) . ", $sides of $roots roots change side of their road (bow2 != bow), $noRoot places have no side path (listed, no root)\n";
ok('places >= ' . MAPV2_GAP_PLACES . ' apart, >= ' . MAPV2_GAP_OWN_STOP . ' from their stop, >= ' . MAPV2_GAP_STOP . ' from other stops, >= ' . MAPV2_GAP_ROAD . ' from roads; roots <= ' . MAPV2_ROOT_MAX, !$probs, implode('; ', array_slice($probs, 0, 6)));

$rootBad = []; $keepBad = []; $offBad = []; $n2 = 0;
foreach ($codes as $c) {
    $L1 = region_layout($c, false); $L2 = region_layout($c, true);
    $v1t = []; foreach ($L1['trails'] as $t) $v1t[$t['from'] . '>' . $t['to']] = $t;
    foreach ($L2['trails'] as $t) {
        $n2++; $s = $L2['slots'][$t['to']]; $o = $v1t[$t['from'] . '>' . $t['to']] ?? null;
        if (count($t['pts']) !== 2 || $t['pts'][1] !== [(int)$s['x'], (int)$s['y']] || $t['root']['c'] !== rl_root_ctrl($t['pts'][0], $t['pts'][1]) || $t['root']['len'] > MAPV2_ROOT_MAX
            || !$o || $t['bow'] !== $o['bow'] || $t['heading'] !== $o['heading'] || $t['ctrl'] !== $o['ctrl'] || !in_array($t['bow2'], ['L', 'R'], true) || !in_array($t['heading2'], RL_HEADINGS, true)) $rootBad[] = "$c:{$t['from']}>{$t['to']}";
    }
    if ($L1['roads'] !== $L2['roads'] || $L1['exits'] !== $L2['exits'] || $L1['pin'] !== $L2['pin'] || count($L1['trails']) !== count($L2['trails'])) $keepBad[] = $c;
    foreach ($L2['slots'] as $id => $s) {
        if ($s['type'] !== 'off') { $a = $s; unset($a['role']); if ($a !== $L1['slots'][$id]) $keepBad[] = "$c:$id"; continue; }
        if (!isset($s['x0'], $s['y0'], $s['near'], $s['role']) || !isset($L2['slots'][$s['near']])) $offBad[] = "$c:$id";
    }
}
ok("roots: all $n2 trails keep two points ending on the place, root.c = rl_root_ctrl, bow/heading/ctrl copied from v1, bow2/heading2 valid", $n2 > 100 && !$rootBad, implode(',', array_slice($rootBad, 0, 6)));
ok('roads, exits, pin and every non-off slot are the v1 ones', !$keepBad, implode(',', array_slice($keepBad, 0, 6)));
ok('off slots carry x0, y0, near (a slot of the layout) and role', !$offBad, implode(',', array_slice($offBad, 0, 6)));

// slug remap and a wrong fingerprint, on copies of the data
$tmpf = tempnam(sys_get_temp_dir(), 'mv2sp');
$na = $all['NA']; $oldId = (string)array_key_first($na); $newId = '987654';
$cp = $all; $cp['NA'] = [$newId => $na[$oldId]] + array_diff_key($na, [$oldId => 1]);
$cp['_meta']['slugs']['NA'][$newId] = $all['_meta']['slugs']['NA'][$oldId]; unset($cp['_meta']['slugs']['NA'][$oldId]);
file_put_contents($tmpf, json_encode($cp));
$GLOBALS['gv_mv2_spread_path'] = $tmpf; map_v2_flush();
$r = rl_spread_for('NA');
ok('slug remap: an id the site does not have finds its place by slug', $r !== null && isset($r[(int)$oldId]) && $r[(int)$oldId] === array_map('intval', $na[$oldId]));
$cp = $all; $cp['_meta']['sig']['NA'] = '00000000';
file_put_contents($tmpf, json_encode($cp)); map_v2_flush();
ok('a wrong fingerprint: the region does not fit', rl_spread_for('NA') === null && !map_v2_region_on('NA'));
unset($GLOBALS['gv_mv2_spread_path']); @unlink($tmpf); map_v2_flush();

// the invariants of region_trails_gates.php and map_fixes.php section 2, with Map v2 on
$bad = []; $n = 0;
foreach ($codes as $c) { $L = region_layout($c); foreach ($L['trails'] as $t) { $n++; if (count($t['pts']) !== 2 || !in_array($t['bow'] ?? '', ['L', 'R'], true) || !in_array($t['heading'] ?? '', RL_HEADINGS, true) || count($t['ctrl'] ?? []) !== 2) $bad[] = "$c:{$t['from']}>{$t['to']}"; } }
ok("region_trails_gates: all $n side trails have two points, a bow, a heading and a control point (Map v2 on)", $n > 100 && !$bad, implode(',', array_slice($bad, 0, 5)));
$heads = []; $bad = [];
foreach ($codes as $c) { $L = region_layout($c); foreach ($L['trails'] as $t) { $a = $L['slots'][$t['from']]; $b = $L['slots'][$t['to']]; $heads[$t['from'] . '>' . $t['to']][] = rl_heading8((float)($b['x'] - $a['x']), (float)($b['y'] - $a['y'])); } }
foreach ($heads as $k => $want) { [$f, $t] = array_map('intval', explode('>', $k)); $got = compass_between($f, $t); if (!in_array($got, $want, true)) $bad[] = "$k $got"; }
ok('map_fixes 2: compass_between = rl_heading8 of the slots on screen for every side path (Map v2 on)', count($heads) > 100 && !$bad, implode(',', array_slice($bad, 0, 5)));

ok('rl_root_ctrl: a 100-unit root bends 10 to one side', rl_root_ctrl([0, 0], [100, 0]) === [50, 10]);
ok('rl_root_ctrl: a 20-unit root bends 4', rl_root_ctrl([0, 0], [20, 0]) === [10, 4]);
ok('rl_root_ctrl: a zero-length root returns the point', rl_root_ctrl([7, 9], [7, 9]) === [7, 9]);

$LNA = region_layout('NA', false);
$byName = []; foreach ($LNA['slots'] as $s) $byName[(string)$s['loc']['name']] = $s;
$stop = null; $wonder = null;
foreach ($LNA['slots'] as $s) {
    if ($s['type'] === 'stop' && !$stop) $stop = $s;
    if ($s['type'] === 'off' && $s['kind'] === 'wonder' && !$wonder) $wonder = $s;
}
ok('village_role: a road stop is main, Cattailmere and Granitegate are main, Acornby is side, a wonder has none',
    $stop && village_role('NA', $stop) === 'main' && isset($byName['Cattailmere'], $byName['Granitegate'], $byName['Acornby']) && village_role('NA', $byName['Cattailmere']) === 'main'
    && village_role('NA', $byName['Granitegate']) === 'main' && village_role('NA', $byName['Acornby']) === 'side' && $wonder && village_role('NA', $wonder) === '');
$mainV = 0; $sideV = 0;
foreach ($LNA['slots'] as $s) {
    if ($s['type'] === 'off' && $s['kind'] === 'village') { if (village_role('NA', $s) === 'main') $mainV++; else $sideV++; }   // every village on the Maplewold's map (its roads run into the neighbours' villages)
    if ($s['type'] === 'stop') $mainV++;
}
echo "diag NA villages: $mainV main line, $sideV side quest\n";
ok('the Maplewold: 11 main-line villages (9 road stops + 2), 17 side-quest villages, 28 in all (master doc 17)', $mainV === 11 && $sideV === 17, "$mainV main, $sideV side");

echo "== 8.3 the world map\n";
$W = world2_layout();
$inside = $W && $W['hub']['x'] >= 0 && $W['hub']['x'] <= 640 && $W['hub']['y'] >= 0 && $W['hub']['y'] <= 360;
foreach ($codes as $c) if (!$W || $W['regions'][$c]['x'] < 0 || $W['regions'][$c]['x'] > 640 || $W['regions'][$c]['y'] < 0 || $W['regions'][$c]['y'] > 360) $inside = false;
ok('world2_layout(): all 14 regions and the hub, inside 640 x 360; world2_xy(640, 360) = [1000, 560]', $W !== null && $inside && world2_xy(640, 360) === [1000, 560]);
ok('map_v2_world_on() with World v2 and Map v2 on', map_v2_world_on());
$roadsDb = q('SELECT id, nodes FROM roads ORDER BY id')->fetchAll();
$codeOf = fn(int $id) => (string)q_val('SELECT r.code FROM locations l JOIN regions r ON r.id = l.region_id WHERE l.id = ?', [$id]);
$noRoute = [];
foreach ($roadsDb as $rd) { $nd = array_map('intval', json_decode((string)$rd['nodes'], true)); $a = $codeOf($nd[0]); $b = $codeOf(end($nd)); if ($a === $b || world2_route($a, $b) === null) $noRoute[] = $rd['id'] . ":$a-$b"; }
ok('every road (' . count($roadsDb) . ') has a painted thread in one direction or the other', !$noRoute, implode(',', $noRoute));
$P = map_positions();
$curves = $GLOBALS['gv_road_curves'];
$pbad = [];
foreach ($codes as $c) {
    $m = (int)q_val("SELECT l.id FROM locations l JOIN regions r ON r.id = l.region_id WHERE r.code = ? AND l.kind = 'market' ORDER BY l.id LIMIT 1", [$c]);
    if (($P[$m] ?? null) !== world2_xy((float)$W['regions'][$c]['x'], (float)$W['regions'][$c]['y'])) $pbad[] = "market $c";
}
$hub = (int)q_val("SELECT id FROM locations WHERE kind = 'hub' LIMIT 1");
if (($P[$hub] ?? null) !== world2_xy((float)$W['hub']['x'], (float)$W['hub']['y'])) $pbad[] = 'hub';
$polyDist = function (array $poly, array $p): float { $b = INF; for ($i = 1; $i < count($poly); $i++) $b = min($b, map2_seg_dist($p, $poly[$i - 1], $poly[$i])); return $b; };
$order = []; $tight = [];
foreach ($curves as $cv) {
    $prevT = -1.0; $prevP = null; $first = true;
    foreach ($cv['t'] as $id => $t) {
        if ($polyDist($cv['poly'], $P[$id]) > 2 && (string)q_val('SELECT kind FROM locations WHERE id = ?', [$id]) !== 'market') $pbad[] = "stop $id off its road {$cv['road']}";
        if ($t < $prevT) $order[] = "{$cv['road']}:$id";
        if (!$first && $prevP && hypot($P[$id][0] - $prevP[0], $P[$id][1] - $prevP[1]) < 12 && $t < 1.0) $tight[] = "{$cv['road']}:$id";
        $prevT = $t; $prevP = $P[$id]; $first = false;
    }
}
foreach ($P as $id => $p) if ($p[0] < 0 || $p[0] > 1000 || $p[1] < 0 || $p[1] > 560) $pbad[] = "outside $id";
ok('markets at their converted cavern centres, the hub at the converted hub, every stop within 2 units of its thread, all inside the frame', !$pbad, implode(',', array_slice($pbad, 0, 6)));
ok('the stops of a road come in road order along its thread', !$order, implode(',', array_slice($order, 0, 6)));
ok('neighbouring stops on a road are at least 12 units apart', !$tight, implode(',', array_slice($tight, 0, 6)));
$missing = is_array($old) ? array_diff(array_map('intval', $old), array_keys($P)) : ['(could not read the old positions)'];
ok('every place with a position on the old world map has one on the new one', !$missing, implode(',', array_slice($missing, 0, 8)));
// the walking hat follows the thread
$cv = null; foreach ($curves as $c2) if (count($c2['t']) >= 3) { $cv = $c2; break; }
$ids = array_keys($cv['t']); [$fa, $fb] = [$ids[1], $ids[2]];
$hatBad = [];
foreach ([0, 2, 4] as $step) {
    q('DELETE FROM expeditions WHERE user_id = ?', [$probe['id']]);
    q("INSERT INTO expeditions (user_id, from_id, to_id, route_id, steps_total, step, hp, max_hp, status, started_at, arrive_at) VALUES (?, ?, ?, 0, 4, ?, 10, 10, 'active', ?, ?)",
        [$probe['id'], $fa, $fb, $step, date('Y-m-d H:i:s'), date('Y-m-d H:i:s', time() + 600)]);
    $me = player_map_pos($probe);
    $d = $polyDist($cv['poly'], $me);
    $between = min($P[$fa][0], $P[$fb][0]) - 2 <= $me[0] && $me[0] <= max($P[$fa][0], $P[$fb][0]) + 2 || min($P[$fa][1], $P[$fb][1]) - 2 <= $me[1] && $me[1] <= max($P[$fa][1], $P[$fb][1]) + 2;
    if ($d > 2 || !$between) $hatBad[] = "step $step at " . implode(',', $me) . ' d ' . round($d, 1);
}
q('DELETE FROM expeditions WHERE user_id = ?', [$probe['id']]);
ok('the walking hat stays on the thread between the two stops (steps 0, half, all)', !$hatBad, implode('; ', $hatBad));
$wm = world_map_svg($probe);
$nRoads = 0; foreach ($roadsDb as $rd) { $nd = array_map('intval', json_decode((string)$rd['nodes'], true)); $a = $codeOf($nd[0]); $b = $codeOf(end($nd)); if ($a !== $b && world2_route($a, $b)) $nRoads++; }
ok('world map v2: map2-world.png, the 1000 x 560 view box, one region link per region, the hub, one road per thread, the ruler, no old side trails',
    str_contains($wm, 'map2-world.png') && str_contains($wm, 'viewBox="0 0 1000 560"') && substr_count($wm, '<a class="region"') === 14 && str_contains($wm, 'here.php?hub=1')
    && substr_count($wm, '<path class="road"') === $nRoads && str_contains($wm, 'class="w2ruler"') && !str_contains($wm, 'stroke-dasharray="2 3"') && str_contains($wm, 'class="mapzoom"'),
    'roads ' . substr_count($wm, '<path class="road"') . "/$nRoads");
ok('world map v2: no inline style, no script (CSP)', !str_contains($wm, 'style="') && !str_contains($wm, '<script'));

echo "== 8.4 the region widget\n";
$rNA = (int)q_val("SELECT id FROM regions WHERE code = 'NA'");
if (!map_v2_region_on('NA')) { ok('the Maplewold is on Map v2 (map2-NA.png and the spread are there)', false); }
else {
    $LNA2 = region_layout('NA');
    $blk = region_map_block($probe, $rNA);
    $nTr = count($LNA2['trails']);
    ok("the widget: map2-NA.png?v=, class mv2, one root per trail ($nTr), all unfound for a gnome who found nothing",
        str_contains($blk, 'map2-NA.png?v=' . rl_spread_ver()) && str_contains($blk, 'class="mv2"') && substr_count($blk, 'class="mv2-root ') === $nTr && substr_count($blk, 'class="mv2-root unfound') === $nTr);
    $leak = [];
    foreach ($LNA2['slots'] as $s) if ($s['type'] === 'off' && !place_known((int)$probe['id'], $s['loc']) && str_contains($blk, e((string)$s['loc']['name']))) $leak[] = $s['loc']['name'];
    ok('no name of a place not found yet appears anywhere in the widget', !$leak, implode(', ', $leak));
    // mark two places found under one stop
    $grp = []; foreach ($LNA2['slots'] as $id => $s) if ($s['type'] === 'off' && $s['anchor']) $grp[(int)$s['near']][] = (int)$id;
    uasort($grp, fn($a, $b) => count($b) <=> count($a));
    $st = (int)array_key_first($grp); [$p1, $p2] = $grp[$st];
    foreach ([$p1, $p2] as $pid) {
        $loc = $LNA2['slots'][$pid]['loc'];
        $key = ($loc['kind'] === 'village' ? 'village:' : 'landmark:') . $loc['slug'];
        $eid = (int)q_val('SELECT id FROM encyclopedia_entries WHERE unlock_key = ?', [$key]);
        if (!$eid) { db_insert('encyclopedia_entries', ['title' => (string)$loc['name'], 'category' => 'places', 'body' => 'x', 'unlock_key' => $key]); $eid = (int)db()->lastInsertId(); }
        q('INSERT INTO user_encyclopedia (user_id, entry_id, unlocked_at) VALUES (?, ?, ?)', [$probe['id'], $eid, now()]);
    }
    $blk = region_map_block($probe, $rNA);
    $n1 = (string)$LNA2['slots'][$p1]['loc']['name']; $n2 = (string)$LNA2['slots'][$p2]['loc']['name'];
    $foundRoots = preg_match_all('~<g class="mv2-root found[^"]*" data-stop="\d+" data-id="(' . $p1 . '|' . $p2 . ')"><path class="rc"[^>]*/><path class="rl"[^>]*stroke="#f0c85a" stroke-width="4.2"~', $blk);
    ok('two places found: their roots are gold 4.2, their names show, each row has Go', $foundRoots === 2 && str_contains($blk, e(mb_substr($n1, 0, 14))) && str_contains($blk, e(mb_substr($n2, 0, 14)))
        && str_contains($blk, 'href="' . e(url('world.php?go=' . $p1 . '#gopanel')) . '"') && str_contains($blk, 'href="' . e(url('world.php?go=' . $p2 . '#gopanel')) . '"'), "roots $foundRoots");
    ok('the sheet header of their stop says 2 found', str_contains($blk, 'data-stop="' . $st . '" data-t1="') && preg_match('~data-stop="' . $st . '" data-t1="[^"]*" data-t2="2 found, ~', $blk) === 1);
    $blk = region_map_block($probe, $rNA, 0, false, $st);
    $open = preg_match_all('~<ul class="mv2-grp" data-stop="(\d+)"[^>]*?(hidden)?>~', $blk, $mm);
    $visible = []; foreach ($mm[1] as $i => $sid) if ($mm[2][$i] === '') $visible[] = (int)$sid;
    ok('?near=<stop>: only its group is open, the svg has class sel, its places and roots are on',
        $visible === [$st] && str_contains($blk, 'mv2-svg sel') && preg_match('~class="mv2-root found on" data-stop="' . $st . '"~', $blk) === 1 && preg_match('~class="rmp mv2-p k-\w+ found on[^"]*" data-stop="' . $st . '" data-id="' . $p1 . '"~', $blk) === 1, json_encode($visible));
    $selOf = fn(string $b) => preg_match('~data-sel="(\d+)"~', $b, $m) ? (int)$m[1] : -1;
    $dflt = $selOf(region_map_block($probe, $rNA));   // with no ?near: the stop the gnome stands at (the town)
    ok('?near=999999 and a near that is an off-road place are ignored (the selection stays the default one)', $dflt !== $st && $selOf(region_map_block($probe, $rNA, 0, false, 999999)) === $dflt && $selOf(region_map_block($probe, $rNA, 0, false, $p1)) === $dflt, "default $dflt");
    $blk = region_map_block($probe, $rNA, 0, false, 0, $p2);
    ok('?at=<place> selects its stop and marks its row', str_contains($blk, 'data-sel="' . $st . '"') && str_contains($blk, 'class="mv2-row found at" id="mv2-r-' . $p2 . '"'));
    preg_match_all('~<circle class="hit" r="([\d.]+)"~', $blk, $hm);
    ok('every tap target is r >= 22 (' . count($hm[1]) . ')', $hm[1] && min(array_map('floatval', $hm[1])) >= 22);
    ok('no style attribute and no script in the widget (CSP)', !str_contains($blk, 'style="') && !str_contains($blk, '<script'));
    q('DELETE FROM user_encyclopedia WHERE user_id = ?', [$probe['id']]);
    ok('region_map_svg() with Map v2 on draws the lit floor map (here_routes_map and the Go tab follow the same gate)', str_contains(region_map_svg($probe, $rNA), 'mv2-svg') && map_art_path('NA') === 'assets/img/scenes/map2-NA.png');
}
setg('map_v2_open', '0'); map_v2_flush();
ok('switched off again: region_map_block is empty', region_map_block($probe, $rNA) === '');
echo $fails ? "$fails FAILED\n" : "all ok\n";
exit($fails ? 1 : 0);
