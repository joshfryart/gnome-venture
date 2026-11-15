<?php
// Walkers on the Trail map: a villager on an errand road is drawn on the right section, walking, facing the way they go (2.7.01).
// php tests/trail_walkers.php GAME_DIR
$_SERVER['SCRIPT_NAME'] = '/adventure.php';
require $argv[1] . '/includes/bootstrap.php';
require_once $argv[1] . '/includes/adventure.php';
require_once $argv[1] . '/includes/trail_tiles.php';
require_once $argv[1] . '/includes/trail_sights.php';
require_once $argv[1] . '/includes/stop_folk.php';
require_once $argv[1] . '/includes/npc_clockwork.php';
require_once $argv[1] . '/includes/trail_walkers.php';
$fails = 0;
set_exception_handler(function (Throwable $e) { echo '  EXCEPTION ' . get_class($e) . ': ' . $e->getMessage() . ' @ ' . basename($e->getFile()) . ':' . $e->getLine() . "\n"; exit(1); });
function ok(string $what, bool $cond, string $extra = ''): void { global $fails; echo ($cond ? '  ok   ' : '  FAIL ') . $what . ($cond ? '' : "  $extra") . "\n"; if (!$cond) $fails++; }
set_setting('npc_clockwork', '1'); set_setting('gnav_on', '1'); set_setting('gnav_tiles', '1'); set_setting('game_clock_on', '0'); setting('__reload__');
echo "== names and strips\n";
ok('species keys', npc25_species_key('Field mouse') === 'field-mouse' && npc25_species_key('Mouse') === 'field-mouse' && npc25_species_key('Stag beetle') === 'stag-beetle' && npc25_species_key('Hedgehog') === 'hedgehog');
ok('the hedgehog strip exists', (bool)npc25_strip('Hedgehog', 'side') && npc25_strip('Hedgehog', 'side')[1] === [64, 80]);
ok('an undrawn species has none yet (falls back to the folk sprite)', npc25_strip('Nosuchbeast') === null);
echo "== a walker on route 240\n";
$u = q_one("SELECT * FROM users WHERE username = 'sprout'");
q("UPDATE expeditions SET status = 'done' WHERE user_id = ?", [$u['id']]);
q("UPDATE routes SET kind = 'road' WHERE id = 240");
$r = q_one('SELECT * FROM routes WHERE id = 240');
q("UPDATE users SET location_id = ?, level = 1, energy = 90, coins = 500 WHERE id = ?", [$r['a_id'], $u['id']]);
$u = q_one('SELECT * FROM users WHERE id = ?', [$u['id']]);
[$sok] = start_expedition($u, 240); ok('the walk starts', $sok);
$exp = active_expedition((int)$u['id']); $sc = trail_scene($exp);
foreach ([$r['a_id'], $r['b_id']] as $loc) stop_folk_ensure(q_one('SELECT * FROM locations WHERE id = ?', [$loc]));
// find a stop villager of either end with an away-walking doing to the other end, and the hour they are mid-leg
$pick = null;
foreach (q('SELECT * FROM stop_folk WHERE location_id IN (?, ?) ORDER BY id', [$r['a_id'], $r['b_id']])->fetchAll() as $f) {
    for ($wk = 100; $wk < 140 && !$pick; $wk++) foreach (npc_cw_week('s' . $f['id'], $wk) as $d) {
        $o = $d['stops'][0]['id'] ?? 0;
        if (($d['stops'][0]['t'] ?? '') === 'loc' && $o && (($f['location_id'] == $r['a_id'] && $o == $r['b_id']) || ($f['location_id'] == $r['b_id'] && $o == $r['a_id']))) { $pick = [$f, $d, $wk]; break; }
    }
    if ($pick) break;
}
if (!$pick) { echo "  info: no villager walks this road in the sample weeks (skipping)\n"; }
else {
    [$f, $d, $wk] = $pick;
    $di = $wk * 7 - 4;   // a day index in that game week
    $seen = []; $dirs = [];
    foreach (range(0, 3) as $leg) { foreach ([0.2, 0.5, 0.8] as $fr) {
        $GLOBALS['gv_cw_time'] = [$d['days'][0], $d['start'] + ($leg === 0 ? $fr : 0) + ($leg === 1 ? 1 + $d['dwell'] + $fr : 0), $di];
        if ($leg > 1) continue;
        for ($sec = 0; $sec < (int)$sc['st']['S']; $sec++) { $sc2 = $sc; $sc2['st']['sec'] = $sec; $w = trail_walkers_on_map($u, $exp, $sc2); foreach ($w as $e) if ($e[6] === (int)$f['id']) { $seen[$leg][$sec] = ($seen[$leg][$sec] ?? 0) + 1; $dirs[$leg] = $e[10]['dir']; } }
    } }
    ok('on the way out they show on at least one section of this road', !empty($seen[0]), json_encode($seen));
    ok('on the way back too', !empty($seen[1]), json_encode($seen));
    ok('and walk the other way coming back', isset($dirs[0], $dirs[1]) && $dirs[0] === -$dirs[1], json_encode($dirs));
    $GLOBALS['gv_cw_time'] = [$d['days'][0], $d['start'] + 1.5, $di];
    $any = 0; for ($sec = 0; $sec < (int)$sc['st']['S']; $sec++) { $sc2 = $sc; $sc2['st']['sec'] = $sec; $any += count(array_filter(trail_walkers_on_map($u, $exp, $sc2), fn($e) => $e[6] === (int)$f['id'])); }
    ok('standing at the other stop they are not on the road', $any === 0, (string)$any);
    $GLOBALS['gv_cw_time'] = [$d['days'][0], $d['start'] + 0.5, $di];
    $sc2 = $sc; $w = null; for ($sec = 0; $sec < (int)$sc['st']['S']; $sec++) { $sc2['st']['sec'] = $sec; foreach (trail_walkers_on_map($u, $exp, $sc2) as $e) if ($e[6] === (int)$f['id']) $w = $e; if ($w) break; }
    if ($w) {
        ok('the entry has a walk flag and a label', isset($w[10]['label']) && $w[10]['dir'] !== 0);
        ok('the tile is walkable', tm_walkable($sc2['map'], $w[0], $w[1]));
        $card = trail_sight_folk_card_html($u, $w, $sc2);
        ok('their card says they are walking', str_contains($card, 'is out walking'), substr($card, 0, 300));
        $GLOBALS['gv_sights_nocache'] = true;
        $sc3 = $sc2; $sc3['x'] = $w[0] > 0 ? $w[0] - 1 : $w[0] + 1; $sc3['y'] = $w[1];   // the gnome stands next to them (the map window shows 11 columns around the gnome)
        $svg = trail_view_html($u, $exp, $sc3, false);
        ok('the page draws them (tmfolk with a strip when the species is drawn, or the idle sheet)', str_contains($svg, 'class="tmfolk"'));
    } else ok('found them on a section', false);
    unset($GLOBALS['gv_cw_time']);
}
set_setting('npc_clockwork', '0'); setting('__reload__');
ok('clockwork off: no walkers', trail_walkers_on_map($u, $exp, $sc) === []);
echo $fails ? "$fails FAILED\n" : "ok\n";
exit($fails ? 1 : 0);
