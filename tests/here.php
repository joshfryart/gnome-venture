<?php
// Graphical navigation helpers. php tests/here.php GAMEDIR        (pure helpers + layouts; no database needed)
//                                php tests/here.php GAMEDIR db     (also the DB-backed parts; needs an installed game, player "sprout")
$game = $argv[1] ?? dirname(__DIR__) . '/game';
$withDb = in_array('db', $argv, true) || in_array('cli', $argv, true);
$fails = 0;
function ok(string $what, bool $cond, string $extra = ''): void { global $fails; echo ($cond ? '  ok   ' : '  FAIL ') . $what . ($cond ? '' : "  $extra") . "\n"; if (!$cond) $fails++; }
if ($withDb) { $_SERVER['SCRIPT_NAME'] = '/here.php'; require $game . '/includes/bootstrap.php'; }
else { function e($v): string { return htmlspecialchars((string)$v, ENT_QUOTES, 'UTF-8'); } }
require_once $game . '/includes/here_layout.php';

if ($withDb && ($argv[2] ?? '') === 'cli') {   // (php tests/here.php GAME cli ...)   // helpers for here.sh: cli set KEY VALUE | cli at KIND | cli walk | cli rank
    require_once $game . '/includes/here_view.php';
    $cmd = $argv[3] ?? '';
    if ($cmd === 'set') { set_setting($argv[4], $argv[5]); echo "ok\n"; }
    if ($cmd === 'at') {   // at market | at haven (an open one) | at lockedhaven
        require_once $game . '/includes/journey.php'; require_once $game . '/includes/rebuild.php';
        $uidx = (int)q_val("SELECT id FROM users WHERE username = 'sprout'"); $id = 0;
        if ($argv[4] === 'market') $id = (int)q_val("SELECT id FROM locations WHERE kind = 'market' ORDER BY id LIMIT 1");
        else foreach (q("SELECT m.*, l.slug FROM landmarks m JOIN locations l ON l.id = m.location_id WHERE m.kind = 'haven' ORDER BY m.id")->fetchAll() as $m) {
            $locked = journey_lock($uidx, 'place', (string)$m['slug']) !== null || landmark_in_ruins($m, $uidx);
            if ($locked === ($argv[4] === 'lockedhaven')) { $id = (int)$m['location_id']; break; }
        }
        q("UPDATE expeditions SET status = 'done' WHERE user_id = ?", [$uidx]);
        q("UPDATE users SET location_id = ?, level = 20, energy = 80, start_page = NULL WHERE id = ?", [$id, $uidx]);
        echo (int)q_val('SELECT id FROM landmarks WHERE location_id = ?', [$id]) . "\n";
    }
    if ($cmd === 'walk') {
        $u = q_one("SELECT * FROM users WHERE username = 'sprout'");
        $r = visible_routes($u, (int)player_node($u)['id'])[0];
        [$ok2, $m] = start_expedition($u, (int)$r['id']);
        echo $ok2 ? "ok\n" : "FAIL $m\n";
    }
    exit(0);
}
echo "== perspective\n";
$L = ['h' => 270, 'horizon' => 112];
$prev = -1.0; $mono = true; $zmono = true; $pz = -1;
for ($y = 112; $y <= 270; $y += 6) { $p = here_persp($L, $y); if ($p['scale'] < $prev) $mono = false; if ($p['z'] < $pz) $zmono = false; $prev = $p['scale']; $pz = $p['z']; }
ok('scale never shrinks going down the picture', $mono);
ok('z follows feet y', $zmono);
ok('far end 0.75, near end 1.25', here_persp($L, 112)['scale'] === 0.75 && here_persp($L, 270)['scale'] === 1.25);
ok('above the horizon clamps to far', here_persp($L, 0)['scale'] === 0.75);
ok('works for another canvas size', here_persp(['h' => 540, 'horizon' => 224], 540)['scale'] === 1.25);

echo "== bearing\n";
$o = ['x' => 100, 'y' => 100];
ok('north', abs(here_bearing($o, ['x' => 100, 'y' => 50]) - 0) < 0.01);
ok('east', abs(here_bearing($o, ['x' => 150, 'y' => 100]) - 90) < 0.01);
ok('south', abs(here_bearing($o, ['x' => 100, 'y' => 150]) - 180) < 0.01);
ok('west', abs(here_bearing($o, ['x' => 50, 'y' => 100]) - 270) < 0.01);
ok('north-east', abs(here_bearing($o, ['x' => 150, 'y' => 50]) - 45) < 0.01);

echo "== assign exits\n";
$anchors = HERE_ANCHORS;
$routes = [['id' => 5, 'bearing' => 10.0], ['id' => 2, 'bearing' => 12.0], ['id' => 9, 'bearing' => 200.0], ['id' => 4, 'bearing' => 12.0]];
[$a1, $m1] = here_assign_exits($anchors, $routes);
[$a2, $m2] = here_assign_exits($anchors, array_reverse($routes));
ok('deterministic whatever the input order', $a1 === $a2);
ok('total: every route gets an anchor when there is room', count($a1) === 4 && !$m1);
ok('every exit gets a distinct anchor', count(array_unique($a1)) === count($a1));
ok('lowest bearing takes the nearest anchor, then ties by id', $a1[5] === 'N' && $a1[2] === 'NE' && $a1[4] === 'NW');
$many = []; for ($i = 1; $i <= 11; $i++) $many[] = ['id' => $i, 'bearing' => (float)($i * 7)];
[$a3, $m3] = here_assign_exits($anchors, $many);
ok('more routes than anchors: 8 placed, 3 in More ways', count($a3) === 8 && count($m3) === 3);
ok('no id both placed and in More ways', !array_intersect(array_keys($a3), $m3));
[$a4, $m4] = here_assign_exits($anchors, []);
ok('no routes = no exits', $a4 === [] && $m4 === []);
[$a5, $m5] = here_assign_exits(['N' => 0.0, 'S' => 180.0], [['id' => 1, 'bearing' => 350.0], ['id' => 2, 'bearing' => 355.0], ['id' => 3, 'bearing' => 10.0]]);
ok('a template with 2 anchors takes 2 routes', count($a5) === 2 && count($m5) === 1);
ok('first by (bearing, id) gets north, the rest wait', ($a5[3] ?? '') === 'N' && $m5 === [2]);

echo "== place npcs\n";
$stand = [['x' => 1, 'y' => 1], ['x' => 2, 'y' => 2], ['x' => 3, 'y' => 3]];
$npcs = []; foreach (['ada', 'bo', 'cy', 'di', 'ed'] as $s) $npcs[] = ['slug' => $s, 'id' => $s];
[$p1, $over1] = here_place_npcs($stand, $npcs, 100);
[$p2, $over2] = here_place_npcs($stand, array_reverse($npcs), 100);
ok('3 slots, 5 villagers: 3 placed, 2 over', count($p1) === 3 && $over1 === 2);
ok('same hour, same crowd, same slots (input order does not matter)', $p1 === $p2);
ok('no villager twice', count(array_unique(array_column(array_column($p1, 1), 'slug'))) === 3);
[$p4, $over4] = here_place_npcs($stand, [], 1);
ok('nobody home = nothing placed', $p4 === [] && $over4 === 0);
[$p5, $over5] = here_place_npcs([], $npcs, 1);
ok('no stand slots = all overflow', $p5 === [] && $over5 === 5);

echo "== layouts\n";
$all = here_layouts_shipped();
ok('shipped layouts load', count($all) >= 10, 'got ' . count($all));
ok('generic exists', isset($all['generic']));
ok('all shipped layouts lint clean', here_lint_all($all) === [], json_encode(here_lint_all($all)));
foreach ($all as $k => $Lx) ok("$k has its own w/h", ($Lx['w'] ?? 0) > 0 && ($Lx['h'] ?? 0) > 0);
ok('generic has 8 exits and at least 4 stand slots', count($all['generic']['exits']) === 8 && count($all['generic']['stand']) >= 4);
ok('lookup: slug beats kind-landscape', here_layout_find(['slug:a' => ['w' => 1], 'village-forest' => ['w' => 2], 'generic' => ['w' => 3]], 'village', 'forest', 'a')[0] === 'slug:a');
ok('lookup: kind-landscape beats kind', here_layout_find(['village-forest' => ['w' => 2], 'village' => ['w' => 4], 'generic' => ['w' => 3]], 'village', 'forest', 'x')[0] === 'village-forest');
ok('lookup: kind beats generic', here_layout_find(['village' => ['w' => 4], 'generic' => ['w' => 3]], 'village', 'coast')[0] === 'village');
ok('lookup: falls back to generic', here_layout_find(['generic' => ['w' => 3]], 'delve', 'tundra')[0] === 'generic');
ok('missing template (not even generic) = null', here_layout_find([], 'village', 'forest') === null);
ok('town finds the town template', here_layout_find($all, 'market', '')[0] === 'generic' && here_layout_find($all, 'town', 'desert')[0] === 'town');
$anch = here_layout_anchors($all['generic']);
ok('anchors read from a layout', count($anch) === 8 && $anch['N'] === 0.0);
ok('exit position', here_exit_pos($all['generic'], 'N') === ['x' => 240, 'y' => 118] && here_exit_pos($all['generic'], 'X') === null);
ok('spot position', here_spot_pos($all['town'], 'green') !== null && here_spot_pos($all['town'], 'nope') === null);
$bad = $all['generic']; $bad['stand'][0] = ['x' => 240, 'y' => 130];
ok('lint: stand next to an exit is caught', here_lint_layout($bad) !== []);
$bad = $all['generic']; $bad['exits'][1]['x'] = 250;
ok('lint: exits too close are caught', here_lint_layout($bad) !== []);
$bad = $all['generic']; $bad['spots'][0]['x'] = 600;
ok('lint: a slot outside the picture is caught', here_lint_layout($bad) !== []);
$bad = $all['generic']; $bad['stand'][1]['y'] = 100;
ok('lint: stand above the horizon is caught', here_lint_layout($bad) !== []);
$bad = $all['generic']; $bad['stand'] = array_slice($bad['stand'], 0, 3);
ok('lint: fewer than 4 stand slots is caught', here_lint_layout($bad) !== []);
$big = json_decode(str_replace('"', '"', json_encode($all['generic'])), true); array_walk_recursive($big, function (&$v, $k) { if (in_array($k, ['x', 'y', 'w', 'h', 'horizon'], true)) $v *= 2; });
ok('canvas size is not hard-coded: a 960x540 layout lints by its own size', here_lint_layout($big) === []);

echo "== settings and schema\n";
require_once $game . '/includes/here_schema.php';
$s = here_settings();
ok('four settings with the planned defaults', ($s['gnav_on']['default'] ?? null) === '0' && ($s['gnav_tiles']['default'] ?? null) === '0' && ($s['gnav_enter_energy']['default'] ?? null) === '1' && ($s['gnav_login_here']['default'] ?? null) === '1');
[$t, $i, $c] = here_schema('INTEGER PRIMARY KEY AUTOINCREMENT', 'INTEGER', '');
ok('here_layouts table and users.start_page', str_contains($t[0], 'here_layouts') && $c === [['users', 'start_page', 'VARCHAR(8) NULL']]);
if ($withDb) {
    ok('gnav_on is off by default in a live game', setting('gnav_on') === '0');
    ok('settings reach settings_schema()', isset(settings_schema()['gnav_on']));
    ok('here_layouts table exists', (function () { try { q('SELECT 1 FROM here_layouts LIMIT 1'); return true; } catch (Throwable $e) { return false; } })());
    ok('users.start_page exists', (function () { try { q('SELECT start_page FROM users LIMIT 1'); return true; } catch (Throwable $e) { return false; } })());
    q("INSERT INTO here_layouts (layout_key, json, updated_at) VALUES ('generic', ?, ?)", [json_encode(['w' => 100, 'h' => 100]), gmdate('Y-m-d H:i:s')]);
    ok('admin edit overrides the shipped layout', (here_layouts_all()['generic']['w'] ?? 0) === 100);
    q("DELETE FROM here_layouts WHERE layout_key = 'generic'");
    ok('shipped layout back after the override is removed', (here_layouts_all()['generic']['w'] ?? 0) === 480);
}

if ($withDb) {
    require_once $game . '/includes/here_view.php';
    require_once $game . '/includes/hub_scene.php';
    function sset(string $k, string $v): void { set_setting($k, $v); setting('__reload__'); }   // setting() keeps a per-request cache
    function me(): array { return q_one("SELECT * FROM users WHERE username = 'sprout'"); }
    function put(int $locId, array $set = []): array { q("UPDATE expeditions SET status = 'done' WHERE user_id = ?", [me()['id']]); $set += ['location_id' => $locId, 'level' => 20, 'energy' => 80]; foreach ($set as $k => $v) q("UPDATE users SET $k = ? WHERE username = 'sprout'", [$v]); return me(); }
    $viewOf = function (int $locId) { $u = put($locId); return here_view($u, player_node($u)); };

    echo "== render smoke: every kind of place\n";
    $kinds = ['town' => "SELECT id FROM locations WHERE kind = 'market' ORDER BY id LIMIT 1", 'hub' => "SELECT id FROM locations WHERE kind = 'hub' LIMIT 1",
        'stop' => "SELECT l.id FROM locations l WHERE l.kind = 'village' AND l.id IN (SELECT a_id FROM routes WHERE kind = 'road') ORDER BY l.id LIMIT 1", 'village' => "SELECT id FROM locations WHERE kind = 'village' AND id NOT IN (SELECT a_id FROM routes WHERE kind = 'road' UNION SELECT b_id FROM routes WHERE kind = 'road') ORDER BY id LIMIT 1",
        'haven' => "SELECT location_id FROM landmarks WHERE kind = 'haven' LIMIT 1", 'wonder' => "SELECT location_id FROM landmarks WHERE kind = 'wonder' LIMIT 1",
        'delve' => "SELECT location_id FROM landmarks WHERE kind = 'delve' LIMIT 1", 'lair' => "SELECT location_id FROM landmarks WHERE kind = 'lair' LIMIT 1"];
    foreach ($kinds as $k => $sql) {
        $id = (int)q_val($sql);
        if (!$id) { ok("$k: a place of this kind exists in the test world", false); continue; }
        $h = $viewOf($id);
        ok("$k: the picture renders", str_contains($h, 'class="hubsvg"') && str_contains($h, 'viewBox="0 0 480 270"'));
        ok("$k: CSP safe (no style=, no script, no on* handlers)", !preg_match('/\sstyle=|<script|\son[a-z]+=/i', $h), substr($h, 0, 0));
        ok("$k: has a text twin", str_contains($h, 'class="hubtwin"'));
        ok("$k: every hotspot is a real link", preg_match_all('/<a class="hs(?: [^"]*)?" /', $h) === preg_match_all('/<a class="hs(?: [^"]*)?" id="hs-[^"]+" href="[^"]+"/', $h));
    }

    echo "== exits\n";
    $town = (int)q_val("SELECT id FROM locations WHERE kind = 'market' ORDER BY id LIMIT 1");
    $u = put($town);
    $routes = visible_routes($u, $town);
    $h = here_view($u, player_node($u));
    ok('one exit hotspot per visible route (up to 8)', substr_count($h, 'id="hs-e') === min(8, count($routes)), substr_count($h, 'id="hs-e') . ' vs ' . count($routes));
    // a side path to a place the gnome has not found stays hidden
    $hid = null;
    foreach (q("SELECT r.id, r.a_id, r.b_id FROM routes r WHERE r.kind = 'side' ORDER BY r.id")->fetchAll() as $cand) {
        $loc = q_one('SELECT * FROM locations WHERE id = ?', [$cand['b_id']]);
        if ($loc && !on_road((int)$cand['b_id']) && !place_known((int)$u['id'], $loc)) { $hid = $cand; break; }
    }
    ok('the test world has a side path to an unfound place', $hid !== null);
    if ($hid) {
        $from = (int)$hid['a_id']; $to = (int)$hid['b_id'];
        $uu = put($from);
        $vis = array_column(array_map(fn($r) => ['id' => $r['id']], visible_routes($uu, $from)), 'id');
        $hh = here_view($uu, player_node($uu));
        ok('the World page filter hides it too', !in_array($hid['id'], $vis));
        ok('a side path to an unfound place is not drawn (no leak)', !str_contains($hh, 'id="hs-e' . $hid['id'] . '"'));
        ok('and its name is not in the page', !str_contains($hh, (string)q_val('SELECT name FROM locations WHERE id = ?', [$to])));
    }
    ok('exit anchors are distinct', (function () use ($h) { preg_match_all('/id="hs-e\d+"[^>]*>.*?<circle class="hit" cx="(\d+)" cy="(\d+)"/s', $h, $m); $p = array_map(null, $m[1], $m[2]); return count($p) === count(array_unique(array_map(fn($x) => implode(',', $x), $p))); })());
    $uu = put($town, ['community_shift_until' => gmdate('Y-m-d H:i:s', time() + 600)]);
    ok('on a community shift the exit cards offer no Set off', !str_contains(here_view($uu, player_node($uu)), 'name="do" value="start"'));
    q("UPDATE users SET community_shift_until = NULL WHERE username = 'sprout'");

    echo "== energy preview = energy charged (gnav_tiles off)\n";
    $u = put($town, ['ev_quickwalk' => 0]);
    $r = visible_routes($u, $town)[0];
    ok('route_enter_cost equals route_energy for a plain walk', route_enter_cost($u, $r) === route_energy($u, $r));
    $before = (int)me()['energy'];
    [$okw, $msg] = start_expedition($u, (int)$r['id']);
    $spent = $before - (int)q_val("SELECT energy FROM users WHERE username = 'sprout'");
    ok('start_expedition charged the shown number', $okw && $spent === route_enter_cost($u, $r), "okw=$okw spent=$spent shown=" . route_enter_cost($u, $r) . " $msg");
    $u = put($town, ['ev_quickwalk' => 1]);
    ok('fireflies (quick walk): shown as free', route_enter_cost($u, $r) === 0);
    $u = put($town, ['ev_quickwalk' => 0]);
    $long = $r; $long['steps'] = 9;
    ok('a long walk costs steps/3', route_enter_cost($u, $long) === 3);
    $road = $r; $road['kind'] = 'road'; $side = $r; $side['kind'] = 'side';
    $uw = $u; $uw['calling'] = 'wayfinder';
    $perkTier = calling_tier($uw);
    ok('preview never rolls the staff die (same answer 50 times)', (function () use ($u, $r) { $a = []; for ($i = 0; $i < 50; $i++) $a[route_enter_cost($u, $r)] = 1; return count($a) === 1; })());
    sset('gnav_tiles', '1'); sset('gnav_enter_energy', '1');
    ok('tiles on: one energy to step on, whatever the length', route_enter_cost($u, $long) === 1 && route_enter_cost($u, $r) === 1);
    sset('gnav_enter_energy', '0');
    ok('tiles on, setting 0: free', route_enter_cost($u, $r) === 0);
    sset('gnav_enter_energy', '2');
    $uq = $u; $uq['ev_quickwalk'] = 1;
    ok('tiles on: fireflies still free', route_enter_cost($uq, $r) === 0 && route_enter_cost($u, $r) === 2);
    sset('gnav_tiles', '0'); sset('gnav_enter_energy', '1');

    echo "== villagers\n";
    ok('here_npcs on a plain village does not fail', is_array(here_npcs(put((int)q_val("SELECT id FROM locations WHERE kind = 'village' ORDER BY id LIMIT 1")), player_node(me()), 'village')));
    $npc = ['slug' => 'zz-nosuchvillager', 'species' => 'frog'];
    $sp = here_sprite($npc);
    ok('no file at all: circle + species emoji', $sp['src'] === '' && $sp['emoji'] !== '');
    $dir = $game . '/assets/img/mini'; $f = $dir . '/mini-npc-zz-nosuchvillager.png';
    $png = base64_decode('iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg==');
    if (is_dir($dir) && is_writable($dir)) {
        file_put_contents($f, $png);
        $sp = here_sprite($npc);
        ok('mini fallback is used when there is no sprite', str_contains($sp['src'], 'mini-npc-zz-nosuchvillager.png'));
        $d2 = $game . '/assets/img/sprite'; $made = !is_dir($d2); if ($made) mkdir($d2);
        file_put_contents($d2 . '/npc-zz-nosuchvillager.png', $png);
        $sp = here_sprite($npc);
        ok('a 2.5D sprite beats the mini', str_contains($sp['src'], 'sprite/npc-zz-nosuchvillager.png'));
        unlink($d2 . '/npc-zz-nosuchvillager.png'); if ($made) rmdir($d2);
        unlink($f);
    }
    ok('a missing sprite never breaks the picture (placeholder circle in the svg)', str_contains(hub_scene('generic', [], [['id' => 'n9', 'x' => 200, 'y' => 200, 'name' => 'Zed', 'href' => '/v', 'src' => '', 'w' => 40, 'h' => 56, 'emoji' => '🐸']], ['layout' => here_layouts_shipped()['generic']]), 'class="fb"'));

    echo "== scene engine\n";
    $L = here_layouts_shipped()['generic'];
    $hot = [['id' => 'a', 'x' => 100, 'y' => 150, 'label' => 'Door <b>', 'href' => '/x?o=a', 'emoji' => '🚪', 'card' => '<p>hi</p>', 'chip' => '⚡1']];
    $out = hub_scene('generic', $hot, [], ['layout' => $L, 'alt' => 'x', 'open' => 'a']);
    ok('label is escaped', !str_contains($out, 'Door <b>') && str_contains($out, 'Door &lt;b&gt;'));
    ok('?o=<id> opens that card (no JS)', str_contains($out, 'id="hubpop-a"') && str_contains($out, 'hubpop-a" aria-labelledby="hubpop-a-t" open'));
    $out2 = hub_scene('generic', $hot, [], ['layout' => $L, 'alt' => 'x']);
    ok('closed by default', !str_contains($out2, ' open>') && !str_contains($out2, 'aria-labelledby="hubpop-a-t" open'));
    ok('no art file: drawn sky and ground', str_contains($out2, 'class="sky"') && str_contains($out2, 'class="ground"'));
    $big = $L; $big['w'] = 960; $big['h'] = 540;
    ok('canvas size comes from the layout', str_contains(hub_scene('generic', [], [], ['layout' => $big, 'alt' => 'x']), 'viewBox="0 0 960 540"'));
    $near = hub_scene('generic', [], [['id' => 'low', 'x' => 100, 'y' => 250, 'name' => 'Low', 'href' => '/a', 'src' => '', 'w' => 40, 'h' => 56, 'emoji' => 'x'], ['id' => 'high', 'x' => 120, 'y' => 130, 'name' => 'High', 'href' => '/b', 'src' => '', 'w' => 40, 'h' => 56, 'emoji' => 'y']], ['layout' => $L, 'alt' => 'x']);
    ok('sprites drawn far first (high on screen first, so near ones cover them)', strpos($near, 'id="sp-high"') < strpos($near, 'id="sp-low"'));
    ok('twin off on request', !str_contains(hub_scene('generic', $hot, [], ['layout' => $L, 'alt' => 'x', 'twin' => false]), 'hubtwin'));
    ok('admin debug draws every slot', str_contains(hub_scene('generic', [], [], ['layout' => $L, 'alt' => 'x', 'debug' => true]), 'fill="#d33"'));

    echo "== flag helpers\n";
    ok('gnav_start_here is off with the flag off', !gnav_start_here(me()));
    sset('gnav_on', '1');
    ok('on: starts on Here by default', gnav_start_here(me()));
    ok('on: a gnome who chose Home starts on Home', !gnav_start_here(['start_page' => 'home'] + me()));
    sset('gnav_login_here', '0');
    ok('login_here off: Home for everyone', !gnav_start_here(me()));
    sset('gnav_login_here', '1'); sset('gnav_on', '0');
    ok('here_ensure_schema reports the column', here_ensure_schema());
}
echo $fails ? "$fails FAILED\n" : "all passed\n";
exit($fails ? 1 : 0);
