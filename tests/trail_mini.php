<?php
// Extra mini-bosses on the Trail (v2.6.40): an authored section's `extra_minibosses` entry is an 'M' token; walking onto it starts that fixed fight.
// php tests/trail_mini.php GAME_DIR      (an installed game, player "sprout"; walk.sh installs one). Route 312 section 3 has a Bramble Wolf (level 22).
$_SERVER['SCRIPT_NAME'] = '/adventure.php';
require $argv[1] . '/includes/bootstrap.php';
require_once $argv[1] . '/includes/adventure.php';
require_once $argv[1] . '/includes/trail_tiles.php';
$fails = 0;
function ok(string $what, bool $cond, string $extra = ''): void { global $fails; echo ($cond ? '  ok   ' : '  FAIL ') . $what . ($cond ? '' : "  $extra") . "\n"; if (!$cond) $fails++; }
set_setting('gnav_on', '1'); set_setting('gnav_tiles', '1'); setting('__reload__');
$u = q_one("SELECT * FROM users WHERE username = 'sprout'");
q("UPDATE expeditions SET status = 'done' WHERE user_id = ?", [$u['id']]);
q("UPDATE routes SET kind = 'road' WHERE id = 312");   // a side path leads only to places you have found: make it a plain road for the test
$r = q_one('SELECT * FROM routes WHERE id = 312');
q("UPDATE users SET location_id = ?, level = 30, energy = 90, ev_quickwalk = 0 WHERE id = ?", [$r['a_id'], $u['id']]);
$u = q_one('SELECT * FROM users WHERE id = ?', [$u['id']]);
[$sok, $m] = start_expedition($u, 312);
ok('a tile walk on route 312 starts', $sok, (string)$m);
$exp = active_expedition((int)$u['id']);
for ($i = 0; $i < 2; $i++) {   // on to section 3
    $exp['encounter'] = null; $sc = trail_scene($exp);
    [$ex, $ey] = $sc['map']['spots']['9']; $sc['x'] = $ex; $sc['y'] = $ey; $sc['st']['phase'] = 'confirm'; trail_save($sc);
    [$okn, $mn] = trail_next($u, $exp); ok('Continue to section ' . ($i + 2), $okn, (string)$mn);
}
$exp['encounter'] = null; $sc = trail_scene($exp);
ok('now in section 3', (int)$sc['st']['sec'] === 2);
$ms = array_values(array_filter($sc['st']['tokens'], fn($t) => $t[2] === 'M'));
ok('the section has exactly one M token, not done', count($ms) === 1 && (int)$ms[0][3] === 0, json_encode($sc['st']['tokens']));
$mb = trail_extra_mini($sc['map']['art'], (int)$ms[0][0], (int)$ms[0][1]);
ok('trail_extra_mini finds the entry on that tile (Bramble Wolf, 22)', $mb && $mb['creature'] === 'bramble-wolf' && (int)$mb['level'] === 22, json_encode($mb));
ok('trail_extra_mini says null on another tile', trail_extra_mini($sc['map']['art'], 0, 0) === null);
$c = trail_extra_mini_creature($mb);
ok('the creature row is found by slug, at level 22 or more', $c && $c['slug'] === 'bramble-wolf' && (int)$c['level'] >= 22, json_encode($c['slug'] ?? null));
// walk to the tile before it (road index - 1), then onto it
$line = $sc['map']['art']['line'] ?? null;
$k = (int)$mb['road_index'];
$ok2 = false;
$path = tm_path($sc['map'], (int)$sc['map']['entry'][0], (int)$sc['map']['entry'][1], (int)$ms[0][0], (int)$ms[0][1], trail_gate($sc, (int)$ms[0][0], (int)$ms[0][1]));
ok('there is a way from the entry to the M tile', is_array($path) && count($path) > 4, json_encode($path ? count($path) : null));
$prev = $path[count($path) - 2];
$sc['x'] = (int)$prev[0]; $sc['y'] = (int)$prev[1]; trail_save($sc);
[$g, $gm] = trail_go($u, $exp, (int)$ms[0][0], (int)$ms[0][1]);
$enc = $exp['encounter'] ? json_decode((string)$exp['encounter'], true) : null;
$cid = (int)q_val("SELECT id FROM creatures WHERE slug = 'bramble-wolf'");
ok('stepping onto it starts the fight with that creature', $g && $enc && ($enc['type'] ?? '') === 'creature' && (int)$enc['id'] === $cid, json_encode([$g, $gm, $enc, substr((string)$exp['log'], -200), exp_easy_cap($u, $exp)]));
$sc = trail_scene($exp);
ok('the token is done afterwards', (int)$sc['st']['tokens'][trail_token_at($sc, (int)$ms[0][0], (int)$ms[0][1])][3] === 1);
$html = trail_view_html($u, $exp, trail_scene($exp), false);
ok('the tile map draws the spot as a fight (⚔️) and the legend says a fight waits', str_contains($html, '⚔️'), '');
// route 228 stays free of fights
ok('route 228 has no M token anywhere', (function () { foreach (trail_authored_all()['228']['sections'] as $s) if (!empty($s['extra_minibosses'])) return false; return true; })());
echo $fails ? "$fails FAILED\n" : "ok\n";
exit($fails ? 1 : 0);
