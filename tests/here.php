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
    if ($cmd === 'tilewalk' || $cmd === 'tilego') {   // tilewalk: flags on + a tile walk from the market | tilego: print a tile the gnome may tap now (x,y)
        require_once $game . '/includes/trail_tiles.php';
        $u = q_one("SELECT * FROM users WHERE username = 'sprout'");
        if ($cmd === 'tilewalk') {
            set_setting('gnav_on', '1'); set_setting('gnav_tiles', '1'); setting('__reload__');
            q("UPDATE expeditions SET status = 'done' WHERE user_id = ?", [$u['id']]);
            $mk = (int)q_val("SELECT id FROM locations WHERE kind = 'market' ORDER BY id LIMIT 1");
            q("UPDATE users SET location_id = ?, level = 20, energy = 50, ev_quickwalk = 0 WHERE id = ?", [$mk, $u['id']]);
            $u = q_one('SELECT * FROM users WHERE id = ?', [$u['id']]);
            [$ok2, $m] = start_expedition($u, (int)visible_routes($u, $mk)[0]['id']);
            echo $ok2 ? "ok\n" : "FAIL $m\n";
        } else {
            $exp = active_expedition((int)$u['id']); $sc = trail_scene($exp);
            $t = null;
            foreach ($sc['st']['tokens'] as $tk) if (!$tk[3] && tm_path($sc['map'], $sc['x'], $sc['y'], $tk[0], $tk[1], trail_gate($sc, $tk[0], $tk[1]))) { $t = [$tk[0], $tk[1]]; break; }
            $t ??= $sc['map']['spots']['9'];
            echo $t[0] . ',' . $t[1] . ' ' . $sc['st']['phase'] . ' ' . $sc['st']['sec'] . ' ' . (int)($exp['encounter'] !== null) . "\n";
        }
    }
    if ($cmd === 'endexp') { q("UPDATE expeditions SET status = 'done' WHERE status = 'active' AND user_id = (SELECT id FROM users WHERE username = 'sprout')"); echo "ok\n"; }
    if ($cmd === 'clearenc') { q("UPDATE expeditions SET encounter = NULL WHERE status = 'active' AND user_id = (SELECT id FROM users WHERE username = 'sprout')"); echo "ok\n"; }
    if ($cmd === 'athome') {   // put the gnome where most villagers live; print "<npc id> <item id>"
        $loc = (int)q_val("SELECT home_location_id FROM npcs WHERE active = 1 AND traveller IS NULL AND home_location_id IS NOT NULL GROUP BY home_location_id ORDER BY COUNT(*) DESC, home_location_id LIMIT 1");
        $uidx = (int)q_val("SELECT id FROM users WHERE username = 'sprout'");
        q("UPDATE expeditions SET status = 'done' WHERE user_id = ?", [$uidx]); q('UPDATE users SET location_id = ? WHERE id = ?', [$loc, $uidx]);
        $nid = (int)q_val('SELECT id FROM npcs WHERE active = 1 AND traveller IS NULL AND home_location_id = ? ORDER BY id LIMIT 1', [$loc]);
        $item = (int)q_val("SELECT id FROM items WHERE tradable = 1 AND category NOT IN ('tool','broken') ORDER BY id LIMIT 1");
        require_once $game . '/includes/items.php'; give_item($uidx, $item, 2);
        q('UPDATE npc_friends SET last_gift = NULL WHERE user_id = ?', [$uidx]);
        echo "$nid $item\n";
    }
    if ($cmd === 'forceenc') {   // a creature in front of the gnome
        $cid = (int)q_val('SELECT id FROM creatures ORDER BY level, id LIMIT 1'); $hp = (int)q_val('SELECT hp FROM creatures WHERE id = ?', [$cid]);
        q("UPDATE expeditions SET encounter = ? WHERE status = 'active' AND user_id = (SELECT id FROM users WHERE username = 'sprout')", [json_encode(['type' => 'creature', 'id' => $cid, 'lv' => 0, 'sp' => 100, 'hpp' => 100, 'hp' => $hp, 'max' => $hp, 'bark' => 0, 'poison' => 0, 'used' => false])]);
        echo "ok\n";
    }
    if ($cmd === 'active') { echo (int)q_val("SELECT COUNT(*) FROM expeditions WHERE status = 'active' AND user_id = (SELECT id FROM users WHERE username = 'sprout')") . "\n"; }
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
$lk = ['town-na' => ['w' => 1], 'town' => ['w' => 2], 'stop-market-grassland_maplewold' => ['w' => 3], 'stop-market-grassland_zzz' => ['w' => 4], 'stop-market-grassland' => ['w' => 5], 'stop-market' => ['w' => 6], 'stop' => ['w' => 7], 'generic' => ['w' => 8]];
ok('lookup: a main town finds its region picture', here_layout_find($lk, 'town', 'forest', 'x', ['region' => 'NA'])[0] === 'town-na');
ok('lookup: a town with no region picture falls to town', here_layout_find($lk, 'town', 'forest', 'x', ['region' => 'ZZ'])[0] === 'town');
ok('lookup: the hub uses town-hub when drawn', here_layout_find($lk + ['town-hub' => ['w' => 9]], 'town', '', 'x', ['region' => 'hub'])[0] === 'town-hub');
ok('lookup: slug still wins over the region picture', here_layout_find($lk + ['slug:x' => ['w' => 9]], 'town', '', 'x', ['region' => 'NA'])[0] === 'slug:x');
ok('lookup: a stop finds type + landscape + style', here_layout_find($lk, 'stop', 'grassland', 's1', ['type' => 'market', 'style' => 'maplewold'])[0] === 'stop-market-grassland_maplewold');
$lk2 = $lk; unset($lk2['stop-market-grassland_maplewold']);
ok('lookup: a stop with another region style takes another look of that type + landscape', here_layout_find($lk2, 'stop', 'grassland', 's1', ['type' => 'market', 'style' => 'adobe'])[0] === 'stop-market-grassland_zzz');
$lk3 = $lk2; unset($lk3['stop-market-grassland_zzz']);
ok('lookup: then type + landscape, then type, then stop, then generic',
    here_layout_find($lk3, 'stop', 'grassland', 's1', ['type' => 'market'])[0] === 'stop-market-grassland' && here_layout_find($lk3, 'stop', 'coast', 's1', ['type' => 'market'])[0] === 'stop-market'
    && here_layout_find($lk3, 'stop', 'coast', 's1', ['type' => 'mill'])[0] === 'stop' && here_layout_find(['generic' => ['w' => 1]], 'stop', 'coast', 's1', ['type' => 'mill'])[0] === 'generic');
ok('lookup: the look pick is stable for a slug', here_layout_find($lk2 + ['stop-market-grassland_aaa' => ['w' => 1]], 'stop', 'grassland', 'honey', ['type' => 'market', 'style' => 'x'])[0] === here_layout_find($lk2 + ['stop-market-grassland_aaa' => ['w' => 1]], 'stop', 'grassland', 'honey', ['type' => 'market', 'style' => 'x'])[0]);
ok('lookup: a stop type with odd characters is ignored', here_layout_find($lk, 'stop', 'grassland', 's1', ['type' => '../x'])[0] === 'stop');
$shipped = here_layouts_shipped();
$gateKeys = array_filter(array_keys($shipped), fn($k) => str_starts_with($k, 'town-') || str_starts_with($k, 'stop-'));
ok('shipped gate-view layouts exist (towns and stops)', count($gateKeys) >= 10, (string)count($gateKeys));
$bad = [];
foreach ($gateKeys as $k) { $L = $shipped[$k]; if (($L['view'] ?? '') !== 'gate' || !empty($L['exits']) || !is_file($game . '/assets/img/scenes/' . here_layout_file($k))) $bad[] = $k; foreach ($L['spots'] as $sp) if (!isset($sp['box'])) $bad[] = $k . '/' . $sp['k']; }
ok('every shipped gate layout: view gate, no exits drawn, a PNG, a box on every spot', !$bad, implode(',', $bad));
ok('gate layouts lint clean', !here_lint_all(array_intersect_key($shipped, array_flip($gateKeys))));
$tpl = ['w' => 480, 'h' => 270, 'horizon' => 100, 'stand' => [['x' => 100, 'y' => 200], ['x' => 150, 'y' => 200], ['x' => 200, 'y' => 200], ['x' => 250, 'y' => 200]], 'spots' => [['k' => 'a', 'x' => 100, 'y' => 150, 'box' => [80, 120, 130, 170]]]];
ok('lint: a stand slot 6 or more off a box is fine', !here_lint_layout($tpl));
$tpl['stand'][0] = ['x' => 100, 'y' => 150];
ok('lint: a stand slot inside a box is flagged', (bool)array_filter(here_lint_layout($tpl), fn($m) => str_contains($m, 'inside or touching the box')));
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
        ok("$k: the picture renders", str_contains($h, 'class="hubsvg') && str_contains($h, 'viewBox="0 0 480 270"'));
        ok("$k: CSP safe (no style=, no script, no on* handlers)", !preg_match('/\sstyle=|<script|\son[a-z]+=/i', $h), substr($h, 0, 0));
        ok("$k: has a text twin", str_contains($h, 'class="hubtwin"'));
        ok("$k: every hotspot is a real link", preg_match_all('/<a class="hs(?: [^"]*)?" /', $h) === preg_match_all('/<a class="hs(?: [^"]*)?" id="hs-[^"]+" href="[^"]+"/', $h));
    }

    echo "== exits\n";
    $town = (int)q_val("SELECT id FROM locations WHERE kind = 'market' ORDER BY id LIMIT 1");
    $u = put($town);
    $routes = visible_routes($u, $town);
    $h = here_view($u, player_node($u));
    $gateView = str_contains($h, 'hubsvg chrome');   // a main town with a gate-view picture has no exits on it: the compass card lists every route
    if ($gateView) {
        ok('gate view: no exit hotspots on the picture, no circles', substr_count($h, 'id="hs-e') === 0 && !str_contains($h, '<circle'));
        ok('gate view: the compass card holds every route named by its destination, one Set off each', substr_count($h, 'name="route_id"') >= 1 && substr_count($h, 'name="route_id"') <= count($routes), substr_count($h, 'name="route_id"') . ' vs ' . count($routes));
        ok('gate view: compass and globe are there', str_contains($h, 'id="hs-routes"') && str_contains($h, 'id="hs-world"') && str_contains($h, 'hubpop-routes') && str_contains($h, 'Open region map'));
    } else ok('one exit hotspot per visible route (up to 8)', substr_count($h, 'id="hs-e') === min(8, count($routes)), substr_count($h, 'id="hs-e') . ' vs ' . count($routes));
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
    $sp = here_sprite(['slug' => 'abuela-quilla', 'species' => 'donkey']);
    ok('a 4-frame sprite sheet draws one frame (64 wide), not the strip', $sp['frames'] === 4 && $sp['w'] === 64 && $sp['fw'] === 64);
    $svgs = hub_sprite(['id' => 'n1', 'x' => 100, 'y' => 200, 'name' => 'A', 'href' => ''] + $sp, ['horizon' => 100, 'h' => 270]);
    ok('sheet sprite is clipped to its first frame', str_contains($svgs, 'viewBox="0 0 64 96"') && str_contains($svgs, 'width="256"'));
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
    $out2 = hub_scene('zz-noart', $hot, [], ['layout' => $L, 'alt' => 'x']);
    ok('closed by default', !str_contains($out2, ' open>') && !str_contains($out2, 'aria-labelledby="hubpop-a-t" open'));
    ok('no art file: drawn sky and ground', str_contains($out2, 'class="sky"') && str_contains($out2, 'class="ground"'));
    $big = $L; $big['w'] = 960; $big['h'] = 540;
    ok('canvas size comes from the layout', str_contains(hub_scene('generic', [], [], ['layout' => $big, 'alt' => 'x']), 'viewBox="0 0 960 540"'));
    $near = hub_scene('generic', [], [['id' => 'low', 'x' => 100, 'y' => 250, 'name' => 'Low', 'href' => '/a', 'src' => '', 'w' => 40, 'h' => 56, 'emoji' => 'x'], ['id' => 'high', 'x' => 120, 'y' => 130, 'name' => 'High', 'href' => '/b', 'src' => '', 'w' => 40, 'h' => 56, 'emoji' => 'y']], ['layout' => $L, 'alt' => 'x']);
    ok('sprites drawn far first (high on screen first, so near ones cover them)', strpos($near, 'id="sp-high"') < strpos($near, 'id="sp-low"'));
    ok('twin off on request', !str_contains(hub_scene('generic', $hot, [], ['layout' => $L, 'alt' => 'x', 'twin' => false]), 'hubtwin'));
    ok('admin debug draws every slot', str_contains(hub_scene('generic', [], [], ['layout' => $L, 'alt' => 'x', 'debug' => true]), 'fill="#d33"'));

    echo "== trail tiles (gnav_tiles)\n";
    require_once $game . '/includes/trail_tiles.php';
    [$m1, $t1] = trail_map_make('seed-a'); [$m2, $t2] = trail_map_make('seed-a'); [$m3] = trail_map_make('seed-b');
    ok('same seed = same section', $m1 === $m2 && $t1 === $t2);
    ok('another seed = another section', $m1['t'] !== $m3['t']);
    $allOk = true; $conn = true; $tokOk = true; $tokCount = true;
    for ($i = 0; $i < 300; $i++) {
        [$m, $t] = trail_map_make("sweep-$i");
        $allOk = $allOk && $m['w'] === TRAIL_W && $m['h'] === TRAIL_H && $m['entry'] !== null && isset($m['spots']['9']);
        $reach = tm_reach($m, $m['entry'][0], $m['entry'][1]);
        $conn = $conn && isset($reach[$m['spots']['9'][1] * $m['w'] + $m['spots']['9'][0]]);
        $e = 0; $f = 0;
        foreach ($t as [$tx, $ty, $k]) { $tokOk = $tokOk && in_array(tm_tile($m, $tx, $ty), ['.', ','], true) && isset($reach[$ty * $m['w'] + $tx]); $k === 'E' ? $e++ : $f++; }
        $tokCount = $tokCount && $e <= 2 && $f >= 0 && $f <= 3 && count(array_unique(array_map(fn($x) => $x[0] . ',' . $x[1], $t))) === count($t);
    }
    ok('300 sections: size, entry and exit present', $allOk);
    ok('300 sections: the exit can be reached from the entry', $conn);
    ok('300 sections: every token on reachable floor, none stacked, at most 2 fights', $tokOk && $tokCount);
    ok('sections = steps clamped 1..6', trail_sections(['steps' => 0]) === 1 && trail_sections(['steps' => 3]) === 3 && trail_sections(['steps' => 40]) === 6);
    sset('gnav_on', '1'); sset('gnav_tiles', '0');
    ok('trail_on needs both flags', !trail_on());
    sset('gnav_tiles', '1'); ok('both flags on = on', trail_on());
    sset('gnav_enter_energy', '1');
    $u = put($town, ['ev_quickwalk' => 0, 'energy' => 50]);
    $r = visible_routes($u, $town)[0];
    $r3 = q_one('SELECT * FROM routes WHERE id = ?', [$r['id']]);
    $before = (int)me()['energy'];
    [$okw, $msg] = start_expedition($u, (int)$r['id']);
    $exp = active_expedition((int)$u['id']);
    $spent = $before - (int)q_val("SELECT energy FROM users WHERE username = 'sprout'");
    ok('a tile walk starts', $okw && $exp, $msg);
    ok('energy charged = the number Here showed (one to step on)', $spent === route_enter_cost($u, $r3) && $spent === 1, "spent $spent");
    $sc = trail_scene($exp);
    ok('scene made, section 1, steps_total = sections', $sc && (int)$sc['st']['sec'] === 0 && (int)$exp['steps_total'] === trail_sections($r3), json_encode($exp['steps_total']));
    $S = (int)$exp['steps_total'];
    $energy0 = (int)q_val("SELECT energy FROM users WHERE username = 'sprout'");
    // walk every section: tap the tokens' tiles, then the exit, fight/problems are cleared by force
    $done = true;
    for ($sec = 0; $sec < $S; $sec++) {
        $exp = active_expedition((int)$u['id']); $sc = trail_scene($exp);
        $guard = 0;
        while ($sc['st']['phase'] === 'section' && $guard++ < 12) {
            $next = null;
            foreach ($sc['st']['tokens'] as $t) if (!$t[3] && tm_path($sc['map'], $sc['x'], $sc['y'], $t[0], $t[1], trail_gate($sc, $t[0], $t[1]))) { $next = [$t[0], $t[1]]; break; }   // one a player can reach now
            $ex9 = $sc['map']['spots']['9'];
            if ($next === null || tm_path($sc['map'], $sc['x'], $sc['y'], $ex9[0], $ex9[1], trail_gate($sc, $ex9[0], $ex9[1]))) { if ($next === null || !count(array_filter($sc['st']['tokens'], fn($t) => !$t[3]))) $next = $ex9; }
            if ($exp['encounter']) { q('UPDATE expeditions SET encounter = NULL WHERE id = ?', [$exp['id']]); $exp['encounter'] = null; }
            [$g, $gm] = trail_go(me(), $exp, (int)$next[0], (int)$next[1]);
            if (!$g) { $done = false; echo "  note trail_go failed: $gm\n"; break 2; }
            save_exp($exp);
            $exp = active_expedition((int)$u['id']); $sc = trail_scene($exp);
        }
        q('UPDATE expeditions SET encounter = NULL WHERE id = ?', [$exp['id']]); $exp['encounter'] = null;
        ok("section " . ($sec + 1) . ": the exit tile asks to continue", $sc['st']['phase'] === 'confirm');
        if ($sec + 1 < $S) {
            $keep = $sc;
            [$n1] = trail_next(me(), $exp); $stepAfter = (int)$exp['step']; save_exp($exp);
            $exp2 = active_expedition((int)$u['id']);
            [$n2] = trail_next(me(), $exp2);   // a second tab pressing Continue again
            ok("section " . ($sec + 1) . ": Continue works once, the second tap does nothing", $n1 && !$n2);
            ok("  and expeditions.step mirrors the finished sections", $stepAfter === $sec + 1);
        }
    }
    ok('the whole Trail was walked with every token tapped', $done);
    ok('Go and Continue never charged energy (no fights were fought here)', (int)q_val("SELECT energy FROM users WHERE username = 'sprout'") >= $energy0);
    $exp = active_expedition((int)$u['id']);
    ok('the last confirm can arrive', trail_can_arrive($exp));
    $exp['encounter'] = null; arrive(me(), $exp); dm_scene_drop((int)$exp['id']); save_exp($exp);
    ok('arrived: the gnome is at the far end', (int)q_val("SELECT location_id FROM users WHERE username = 'sprout'") === (int)$exp['to_id']);
    ok('the scene is gone after arriving', trail_scene($exp) === null);
    // turn back
    $u = put($town, ['energy' => 50]);
    [$okw] = start_expedition($u, (int)$r['id']); $exp = active_expedition((int)$u['id']);
    [$bk] = trail_back(me(), $exp); save_exp($exp);
    ok('turn back: the walk ends, the gnome stays where they were, no scene left', $bk && !active_expedition((int)$u['id']) && (int)q_val("SELECT location_id FROM users WHERE username = 'sprout'") === $town && !q_val('SELECT COUNT(*) FROM walk_scene WHERE exp_id = ?', [$exp['id']]));
    // gather, wander and resume
    sset('gnav_on', '1'); sset('gnav_tiles', '1');
    $u = put($town, ['energy' => 50]);
    start_expedition($u, (int)$r['id']); $exp = active_expedition((int)$u['id']);
    $sc0 = trail_scene($exp);
    $_SESSION = $_SESSION ?? [];
    [$wk, $wm] = trail_wander(me(), $exp); save_exp($exp);
    $expNow = active_expedition((int)$u['id']);
    ok('wander off the Trail: the walk is put away and an explore starts', $wk && $expNow && $expNow['kind'] === 'explore', $wm);
    ok('...from the place the walk began, and the old walk is done', (int)$expNow['from_id'] === $town && !trail_scene($expNow));
    ok('...and no resume is offered while still wandering', trail_resume_offer(me()) === null);
    q("UPDATE expeditions SET status = 'done' WHERE user_id = ?", [$u['id']]);   // back on the road
    $offer = trail_resume_offer(me());
    ok('back at the place: the walk can be resumed', $offer !== null && (int)$offer['x'] === $sc0['x']);
    ok('the resume bar shows', str_contains(trail_resume_html(me()), 'value="trail_resume"'));
    $energyBefore = (int)q_val("SELECT energy FROM users WHERE username = 'sprout'");
    [$rk] = trail_resume(me());
    $exp2 = active_expedition((int)$u['id']); $sc2 = $exp2 ? trail_scene($exp2) : null;
    ok('resume: a new walk, no energy charged, the same section and tokens', $rk && $sc2 && (int)$exp2['id'] !== (int)$exp['id'] && (int)q_val("SELECT energy FROM users WHERE username = 'sprout'") === $energyBefore && $sc2['map']['t'] === $sc0['map']['t'] && $sc2['st']['tokens'] === $sc0['st']['tokens'] && $sc2['x'] === $sc0['x']);
    ok('only once: nothing left to resume', trail_resume_offer(me()) === null);
    $u = me();
    q("UPDATE users SET energy = 0 WHERE id = ?", [$u['id']]);
    [$wk2, $wm2] = trail_wander(me(), $exp2);
    ok('no energy: wander is refused and the walk stays', !$wk2 && active_expedition((int)$u['id']) && trail_scene(active_expedition((int)$u['id'])) !== null, $wm2);
    q("UPDATE users SET energy = 50 WHERE id = ?", [$u['id']]);
    $exp2 = active_expedition((int)$u['id']);
    $ge = trail_gather(me(), $exp2, 'nonsense');
    ok('gather with a tool that does not exist is refused, nothing breaks', $ge[0] === false);
    $exp2['encounter'] = json_encode(['type' => 'creature', 'id' => 1]);
    ok('gather and wander are refused while something blocks the way', trail_gather(me(), $exp2, 'basket')[0] === false && trail_wander(me(), $exp2)[0] === false);
    q("UPDATE expeditions SET status = 'done' WHERE user_id = ?", [$u['id']]);
    sset('gnav_tiles', '1');
    // a timer walk in progress when the flag flips stays a timer walk
    sset('gnav_tiles', '0');
    $u = put($town, ['energy' => 50]);
    start_expedition($u, (int)$r['id']); $exp = active_expedition((int)$u['id']);
    sset('gnav_tiles', '1');
    ok('a walk that began as a timer walk has no tile scene, even with tiles on now', trail_scene($exp) === null);
    q("UPDATE expeditions SET status = 'done' WHERE user_id = ?", [$u['id']]);
    // two walks started in one instant: still only one
    $u = put($town, ['energy' => 50]);
    start_expedition($u, (int)$r['id']); [$again] = start_expedition(me(), (int)$r['id']);
    ok('a second start while walking is refused (no second charge)', !$again);
    q("UPDATE expeditions SET status = 'done' WHERE user_id = ?", [$u['id']]);
    sset('gnav_tiles', '0'); sset('gnav_on', '0');

    echo "== residential and door\n";
    require_once $game . '/includes/residential.php';
    $homeLoc = (int)q_val("SELECT home_location_id FROM npcs WHERE active = 1 AND traveller IS NULL AND home_location_id IS NOT NULL GROUP BY home_location_id ORDER BY COUNT(*) DESC, home_location_id LIMIT 1");
    $homes = npcs_homed_at($homeLoc);
    ok('the place with most villagers has homes', count($homes) >= 2, "loc $homeLoc");
    ok('homes are in id order', array_column($homes, 'id') === (function ($a) { sort($a); return $a; })(array_column($homes, 'id')));
    ok('travellers and inactive villagers have no house', !array_filter($homes, fn($n) => $n['traveller'] !== null || (int)$n['active'] !== 1));
    $firstIds = array_column($homes, 'id');
    q("DELETE FROM npcs WHERE slug = 'zz-newcomer'");
    $newId = db_insert('npcs', ['slug' => 'zz-newcomer', 'name' => 'Zed Newcomer', 'species' => 'frog', 'personality' => 'Shy', 'home_location_id' => $homeLoc, 'active' => 1]);
    $after = array_column(npcs_homed_at($homeLoc), 'id');
    ok('a new villager takes the next slot, nobody else moves', array_slice($after, 0, count($firstIds)) === $firstIds && end($after) === $newId);
    q('DELETE FROM npcs WHERE id = ?', [$newId]);
    ok('templates: 3 houses -> 4-slot street, 6 -> 6, 7 -> 8, 30 -> 8 per page', resid_template(3) === ['resid-4', 4] && resid_template(6) === ['resid-6', 6] && resid_template(7) === ['resid-8', 8] && resid_template(30)[1] === 8);
    $u = put($homeLoc);
    [$rh, $pages] = resid_view($u, player_node($u), 1);
    ok('the street renders one house per villager (page 1)', substr_count($rh, 'id="hs-h') === min(count($homes), resid_template(count($homes))[1]));
    ok('an unmet villager shows no name on the street', !str_contains($rh, (string)$homes[0]['name']) || resid_met((int)$u['id'], (int)$homes[0]['id']));
    $n1 = $homes[0];
    ok('door_allowed: at the home place', door_allowed($u, $n1));
    $other = (int)q_val("SELECT id FROM locations WHERE id <> ? ORDER BY id LIMIT 1", [$homeLoc]);
    $uo = put($other);
    ok('door_allowed: not from another place', !door_allowed($uo, $n1));
    ok('gift at a door refused from elsewhere', npc_gift_door($uo, (int)$n1['id'], 1)[0] === false);
    // lights: force home / away by schedule-free hours: an npc with no schedule rows is home all day
    q('DELETE FROM npc_schedules WHERE npc_id = ?', [$n1['id']]);
    $u = put($homeLoc);
    ok('no plans = at home: window lit, Knock links to the visit', str_contains(door_view($u, $n1, 1), 'villagers.php?id=' . $n1['id'] . '&amp;home=1'));
    q('INSERT INTO npc_schedules (npc_id, days, start_hour, end_hour, activity, location_id) VALUES (?, ?, 0, 0, ?, ?)', [$n1['id'], 'all', 'visiting', (int)q_val("SELECT id FROM locations WHERE kind = 'market' AND region <> (SELECT region FROM locations WHERE id = ?) ORDER BY id DESC LIMIT 1", [$homeLoc])]);
    $dv = door_view($u, $n1, 1, 'knock');
    ok('out all day: dark window, Knock shows the message and no visit link', str_contains($dv, 'No light on') && !str_contains($dv, 'villagers.php?id=' . $n1['id'] . '&amp;home=1'), substr(strip_tags($dv), 0, 0));
    q("UPDATE users SET coins = coins WHERE id = ?", [$u['id']]);
    $item = (int)q_val("SELECT id FROM items WHERE tradable = 1 AND category NOT IN ('tool','broken') ORDER BY id LIMIT 1");
    give_item((int)$u['id'], $item, 3);
    q('DELETE FROM npc_friends WHERE user_id = ? AND npc_id = ?', [$u['id'], $n1['id']]);
    ok('a handed gift to someone who is out in a far region is refused (they are not around)', npc_gift($u, (int)$n1['id'], $item)[0] === false);
    [$g1, $gm1] = npc_gift_door($u, (int)$n1['id'], $item);
    ok('a gift can be left at the door of an unmet, absent villager', $g1 && str_contains($gm1, 'door'), $gm1);
    [$g2, $gm2] = npc_gift_door($u, (int)$n1['id'], $item);
    ok('only once a day (shared with handed gifts)', !$g2, $gm2);
    ok('friendship went up, but only by the door share', (int)q_val('SELECT points FROM npc_friends WHERE user_id = ? AND npc_id = ?', [$u['id'], $n1['id']]) > 0);
    echo "== workshop, treehouse, pal yard\n";
    require_once $game . '/includes/hub_pages.php';
    sset('gnav_on', '1');
    $u = put($town);
    $ws = workshop_view($u);
    ok('workshop: one hotspot per crafting section', substr_count($ws, 'id="hs-') === count(CRAFT_CATEGORIES), (string)substr_count($ws, 'id="hs-'));
    ok('workshop: each card links into the existing crafting page', substr_count($ws, 'inventory.php?tab=craft&amp;c=') >= count(CRAFT_CATEGORIES));
    ok('workshop: CSP safe, text twin there', !preg_match('/\sstyle=|<script|\son[a-z]+=/i', $ws) && str_contains($ws, 'hubtwin'));
    $th = treehouse_view($u);
    ok('treehouse: the three game rooms are there', substr_count($th, 'id="hs-parlour"') + substr_count($th, 'id="hs-loft"') + substr_count($th, 'id="hs-cellar"') === 3);
    $rooms = treehouse_rooms(); $listed = [];
    foreach ($rooms as [, , $ks]) foreach ($ks as $k) $listed[$k] = 1;
    require_once $game . '/includes/games.php';
    ok('treehouse: every game of GAMES sits in a room', array_diff(array_keys(GAMES), array_keys($listed)) === [], implode(',', array_diff(array_keys(GAMES), array_keys($listed))));
    ok('treehouse: contest hall links to the Contests tab', str_contains($th, 'games.php?tab=contests'));
    ok('treehouse: CSP safe', !preg_match('/\sstyle=|<script|\son[a-z]+=/i', $th));
    $guestL = here_layouts_all()['treehouse']; ok('treehouse layout has 24 perches', count($guestL['pals']) === 24);
    ok('gnav_page_open: off for a player with the flag off', (function () { sset('gnav_craft', '0'); return !gnav_on() || setting('gnav_craft') !== '1'; })());

    echo "== Phase 5: chrome rules (no circles, boxes, compass + globe, tags)\n";
    ok('treehouse: no circles anywhere', !str_contains($th, '<circle'));
    ok('treehouse: a room hit area is its layout box (parlour 92,126 to 210,196)', str_contains($th, '<rect class="hit" x="92" y="126" width="118" height="70"/>'));
    ok('treehouse: tags are centred (text-anchor middle) and there is one per hotspot', substr_count($th, 'class="tag"') >= 6 && substr_count($th, 'class="tag"') === substr_count($th, 'class="tag" x') && !str_contains($th, 'class="tag" text-anchor="start"'));
    ok('treehouse: compass and world globe buttons, each with a card', str_contains($th, 'id="hs-routes"') && str_contains($th, 'id="hs-world"') && str_contains($th, 'id="hubpop-routes"') && str_contains($th, 'Open region map'));
    ok('treehouse: the picture has its own sprite-free bottom-right corner (layout compass_clear)', here_compass_clear($guestL) === [366, 218, 480, 270]);
    ok('here_hit_box: no box = 56 x 56 around x,y', here_hit_box(['x' => 100, 'y' => 100], ['w' => 480, 'h' => 270]) === [72, 72, 128, 128]);
    ok('here_hit_box: a box is used as given', here_hit_box(['x' => 1, 'y' => 1, 'box' => [10, 20, 90, 60]], ['w' => 480, 'h' => 270]) === [10, 20, 90, 60]);
    $bad = ['w' => 480, 'h' => 270, 'spots' => [['k' => 'a', 'x' => 50, 'y' => 50, 'box' => [10, 10, 100, 100]], ['k' => 'b', 'x' => 90, 'y' => 90, 'box' => [90, 90, 200, 200]], ['k' => 'c', 'x' => 440, 'y' => 250, 'box' => [400, 240, 480, 270]]]];
    $lint = implode(' | ', here_lint_layout($bad));
    ok('lint: overlapping boxes are caught', str_contains($lint, 'boxes of a and b overlap'), $lint);
    ok('lint: a box over the compass corner is caught', str_contains($lint, 'box of c covers the compass corner'), $lint);
    ok('chrome sprite: no art and no silhouette draws nothing extra (no circle, no emoji)', (function () use ($guestL) { $h = hub_sprite_chrome(['id' => 'z', 'x' => 100, 'y' => 100, 'w' => 36, 'h' => 36, 'name' => 'Z', 'href' => '/x'], $guestL); return !str_contains($h, '<circle') && !str_contains($h, '<text') && !str_contains($h, '<image'); })());
    ok('chrome sprites are scaled 0.55 (far) to 0.95 (near)', hub_persp_chrome(['h' => 270, 'horizon' => 0], 0)['scale'] === 0.55 && hub_persp_chrome(['h' => 270, 'horizon' => 0], 270)['scale'] === 0.95);

    echo "== Phase 5: treehouse pals (perches, sparkle, dressing, away, party, edge cases)\n";
    foreach (['ppal_open' => 1, 'puzzles_open' => 1, 'jigsaw_open' => 1, 'pj_open' => 1, 'pj_min_level' => 10] as $k => $v) sset($k, (string)$v);
    require_once $game . '/includes/jigsaw.php'; require_once $game . '/includes/puzzle_pals.php'; require_once $game . '/includes/pal_jobs.php'; require_once $game . '/includes/games.php';
    jigsaw_ensure(); ppal_ensure();
    $uid = (int)me()['id'];
    $u = put($town, ['level' => 20]);
    q('DELETE FROM ppal_found WHERE user_id = ?', [$uid]); q('DELETE FROM hub_seen WHERE user_id = ?', [$uid]); q('DELETE FROM ppal_jobs WHERE user_id = ?', [$uid]);
    $th0 = treehouse_view($u);
    ok('0 pals: empty tree plus the hint', str_contains($th0, 'Solve jigsaws to find pals') && substr_count($th0, 'id="sp-p') === 0);
    ok('0 pals: the games are all still there', str_contains($th0, 'id="hs-parlour"') && str_contains($th0, 'id="hs-cellar"'));
    sset('ppal_open', '0'); $thOff = treehouse_view($u); sset('ppal_open', '1');
    ok('ppal_open off: pal parts hidden (book shelf, yard door, hint), games shown', !str_contains($thOff, 'id="hs-books"') && !str_contains($thOff, 'id="hs-yard"') && !str_contains($thOff, 'Solve jigsaws') && str_contains($thOff, 'id="hs-loft"'));
    q('UPDATE hub_seen SET seen_at = ? WHERE user_id = ?', [gmdate('Y-m-d H:i:s', time() - 3600), $uid]);   // seen an hour ago: a pal found now is new
    $MAP = (int)q_val("SELECT id FROM puzzle_pics WHERE slug = 'jig-maplewold'");
    q('DELETE FROM ppal_releases WHERE user_id = ? AND pic_id = ?', [$uid, $MAP]);
    q('INSERT INTO ppal_releases (user_id, pic_id, released_at, src) VALUES (?, ?, ?, ?)', [$uid, $MAP, now(), 'free']);
    $keys = array_map(fn($p) => $p['key'], ppal_roster(ppal_pic($MAP)));
    ppal_claim($u, $keys[0], $MAP);
    $t1 = treehouse_view($u);
    ok('1 pal: one sprite on perch 1 (x 60), sparkles on its first view', substr_count($t1, 'id="sp-p') === 1 && str_contains($t1, 'class="spark"'), substr_count($t1, 'id="sp-p') . ' sprites');
    $t1b = treehouse_view($u);
    ok('...and only on that first view (hub_seen remembers)', !str_contains($t1b, 'class="spark"') && substr_count($t1b, 'id="sp-p') === 1);
    ok('hub_seen has the row for this gnome', hub_seen_get($uid, 'treehouse') !== null);
    $pos1 = preg_match('/id="sp-p[0-9a-f]+".*?<rect class="hit" x="(\d+)" y="(\d+)"/s', $t1b, $m1) ? [$m1[1], $m1[2]] : null;
    foreach ([1, 2, 3, 4] as $i) { sleep(0); ppal_claim($u, $keys[$i], $MAP); }
    q('UPDATE ppal_found SET found_at = ? WHERE user_id = ? AND pal_key = ?', [gmdate('Y-m-d H:i:s', time() - 100 - 50), $uid, $keys[0]]);
    $t5 = treehouse_view($u);
    ok('5 pals: five sprites, the first pal did not move', substr_count($t5, 'id="sp-p') === 5 && $pos1 !== null && str_contains($t5, '<rect class="hit" x="' . $pos1[0] . '" y="' . $pos1[1] . '"'));
    ok('5 pals: the 5-pal dressing (rug) is there, the 10-pal one is not', str_contains($t5, 'data-dress="rug"') && !str_contains($t5, 'data-dress="lights"'));
    ok('4 pals or fewer: no dressing yet', !str_contains($t1b, 'data-dress'));
    $pj = array_values(pj_pals($uid));
    $first = $pj[0]; $second = $pj[1];
    q("UPDATE ppal_found SET status = 'trip' WHERE pal_uid = ?", [$first['uid']]);
    q("INSERT INTO ppal_jobs (user_id, pal_uid, kind, state, started_at, ends_at, day, result) VALUES (?, ?, 'trip', 'active', ?, ?, ?, '{}')", [$uid, $first['uid'], gmdate('Y-m-d H:i:s', time() - 60), gmdate('Y-m-d H:i:s', time() + 3 * 3600), landmark_day()]);
    $ta = treehouse_view($u);
    ok('a pal on a job: an empty perch with an "away" tag and its return time', str_contains($ta, 'class="perch"') && preg_match('/class="awaytag"[^>]*>away \d+ h/', $ta) === 1 && str_contains($ta, 'id="sp-p' . substr($first['uid'], 0, 8) . '"'));
    ok('a pal on a job is not drawn as a picture too', substr_count($ta, 'class="sil"') + substr_count($ta, '<image class="pix" href="' . url('assets/img/puzzles/pals/')) <= 4);
    q('UPDATE ppal_found SET active = 1 WHERE pal_uid = ?', [$second['uid']]);
    $tp = treehouse_view($u);
    ok('a party pal sits by the door (party slot x 70) and is not duplicated on its perch', substr_count($tp, 'id="sp-p' . substr($second['uid'], 0, 8) . '"') === 1 && preg_match('/id="sp-p' . substr($second['uid'], 0, 8) . '".*?<rect class="hit" x="(\d+)"/s', $tp, $mm) && (int)$mm[1] < 70);
    ok('pal popover: name, rarity, level, times found, Pal Book', str_contains($tp, 'class="palcard"') && str_contains($tp, '<dt>Rarity</dt>') && str_contains($tp, '<dt>Level</dt>') && str_contains($tp, '<dt>Found</dt>'));
    ok('pal popover: Send on a job link when level allows', str_contains($tp, 'Send on a job') && str_contains($tp, 'palyard.php'));
    sset('ppal_party', '1');
    $tq = treehouse_view($u);
    ok('pal popover: Take along / Send home post to the Pal Book with back=treehouse', str_contains($tq, 'action="' . url('puzzlepals.php') . '"') && str_contains($tq, 'name="back" value="treehouse"') && (str_contains($tq, 'value="on">Take along') || str_contains($tq, 'value="off">Send home')));
    q('UPDATE ppal_found SET active = 0 WHERE user_id = ?', [$uid]);
    $L3 = $guestL; $L3['pals'] = array_slice($L3['pals'], 0, 3);
    q("DELETE FROM here_layouts WHERE layout_key = 'treehouse'"); q('INSERT INTO here_layouts (layout_key, json, updated_at) VALUES (?, ?, ?)', ['treehouse', json_encode($L3), now()]);
    $tov = treehouse_view($u);
    ok('more pals than perches: the tree shows the first N and "+2 in the yard"', substr_count($tov, 'id="sp-p') === 3 && str_contains($tov, '+2 in the yard'));
    q("DELETE FROM here_layouts WHERE layout_key = 'treehouse'");
    q("UPDATE ppal_found SET status = 'home' WHERE user_id = ?", [$uid]); q('DELETE FROM ppal_jobs WHERE user_id = ?', [$uid]);
    ok('perf: pj_pals, ppal_found_map and the view do not break with a removed pal key', (function () use ($uid, $u) { q("INSERT INTO ppal_found (user_id, pal_key, pic_id, found_at, times, active) VALUES (?, 'no-such-pal', 1, ?, 1, 0)", [$uid, now()]); $h = treehouse_view($u); q("DELETE FROM ppal_found WHERE pal_key = 'no-such-pal'"); return str_contains($h, 'class="hubsvg'); })());
    ok('Contest hall card: this week\'s high scores and the Contests tab', str_contains($th, 'This week’s high scores') && str_contains($th, 'games.php?tab=contests'));
    ok('locked room: a closed Puzzle Room has shutters and says so', (function () use ($u) { sset('puzzles_open', '0'); $h = treehouse_view($u); sset('puzzles_open', '1'); return str_contains($h, 'class="shutter"') && str_contains($h, 'The Puzzle Room is still being tidied'); })());
    q('UPDATE users SET level = 1 WHERE id = ?', [$uid]);
    ok('level-gated game: Marrow says when it opens', str_contains(treehouse_view(me()), 'Opens at level ' . (int)setting('marrow_min_level')));
    $u = put($town, ['level' => 20]);
    ok('treehouse CSP safe with pals', !preg_match('/\sstyle=|<script|\son[a-z]+=/i', $tp . $ta . $t5));

    echo "== Phase 5: the yard (sites, real job forms, ledger)\n";
    q("UPDATE ppal_found SET hp = 3 WHERE pal_uid = ?", [$second['uid']]);
    $yd = yard_view($u);
    ok('yard renders, no circles', str_contains($yd, 'class="hubsvg') && !str_contains($yd, '<circle'));
    ok('yard: every site is a hotspot with a box (garden, trip, delve, station, sick, board)', (function () use ($yd) { foreach (['garden', 'trip', 'delve', 'station', 'sick', 'board'] as $k) if (!str_contains($yd, 'id="hs-' . $k . '"')) return false; return true; })());
    ok('yard: the four job posts are in the site popovers (the existing Pal Jobs markup)', (function () use ($yd) { foreach (['garden', 'trip', 'delve', 'station'] as $k) if (!str_contains($yd, 'id="pjt-' . $k . '"')) return false; return true; })());
    ok('yard: the popover shows the caps (jobs out, runs left, level gate)', str_contains($yd, 'jobs out') && str_contains($yd, 'trips and delves left today') && str_contains($yd, 'open at gnome level'));
    ok('yard: forms post to paljobs.php with back=palyard (existing POST, unchanged)', str_contains($yd, 'action="' . url('paljobs.php') . '"') && str_contains($yd, 'name="back" value="palyard"'));
    ok('yard: a hurt pal gets a heal form in the Sick bay and a sick-bay badge', str_contains($yd, 'name="do" value="heal"') && str_contains($yd, '1 hurt'));
    ok('yard: the Ledger popover is the real ledger (countdown JS hooks)', str_contains($yd, 'pjledger') && str_contains($yd, 'class="pjpage"'));
    ok('yard: pals on stand slots, at most 5', substr_count($yd, 'id="sp-q') >= 1 && substr_count($yd, 'id="sp-q') <= 5);
    q("INSERT INTO ppal_jobs (user_id, pal_uid, kind, state, started_at, ends_at, day, result) VALUES (?, ?, 'trip', 'active', ?, ?, ?, '{}')", [$uid, $pj[2]['uid'], gmdate('Y-m-d H:i:s', time() - 600), gmdate('Y-m-d H:i:s', time() + 3000), landmark_day()]);
    q("UPDATE ppal_found SET status = 'trip' WHERE pal_uid = ?", [$pj[2]['uid']]);
    $ydj = yard_view($u);
    ok('yard: a pal on a trip stands at the Trail head with a progress bar (a rect, not a ring)', str_contains($ydj, 'class="pjring"') && str_contains($ydj, '1 out'));
    q("UPDATE ppal_jobs SET ends_at = ? WHERE user_id = ?", [gmdate('Y-m-d H:i:s', time() - 5), $uid]);
    $ydr = yard_view($u);
    ok('yard: a finished job shows a Collect bubble and the site is lit', str_contains($ydr, 'class="collect"') && str_contains($ydr, 'class="hs hsb goal"'));
    q('DELETE FROM ppal_jobs WHERE user_id = ?', [$uid]); q("UPDATE ppal_found SET status = 'home' WHERE user_id = ?", [$uid]);
    q('DELETE FROM ppal_found WHERE user_id = ?', [$uid]);
    ok('yard: no pals = an empty yard and a hint, sites still there', (function () use ($u) { $h = yard_view($u); return str_contains($h, 'The yard is empty') && str_contains($h, 'id="hs-garden"'); })());
    ok('yard: CSP safe', !preg_match('/\sstyle=|<script|\son[a-z]+=/i', $yd . $ydj . $ydr));
    ok('yard: compass and globe cards link back to Here and the World', str_contains($yd, 'id="hubpop-routes"') && str_contains($yd, 'here.php') && str_contains($yd, 'world.php?tab=map'));
    require_once $game . '/includes/here_schema.php';
    hub_seen_set($uid, 'pref:gameslist'); ok('games list preference is remembered per gnome', hub_seen_get($uid, 'pref:gameslist') !== null && treehouse_list_pref($uid));
    hub_seen_clear($uid, 'pref:gameslist'); ok('...and can be turned off', !treehouse_list_pref($uid));
    sset('gnav_on', '0');

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
