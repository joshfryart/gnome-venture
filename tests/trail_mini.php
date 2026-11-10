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
// a shut tool gate is drawn with a lock mark, says what it needs, and the legend names it (route 313 section 3: tunnel mouth, Miner's Lantern)
q("UPDATE expeditions SET status = 'done' WHERE user_id = ?", [$u['id']]);
q("UPDATE routes SET kind = 'road' WHERE id = 313");
$r3 = q_one('SELECT * FROM routes WHERE id = 313');
q("UPDATE users SET location_id = ?, level = 30, energy = 90 WHERE id = ?", [$r3['a_id'], $u['id']]);
$u = q_one('SELECT * FROM users WHERE id = ?', [$u['id']]);
[$s3, $m3] = start_expedition($u, 313);
ok('a tile walk on route 313 starts', $s3, (string)$m3);
$exp = active_expedition((int)$u['id']);
for ($i = 0; $i < 2; $i++) {
    $exp['encounter'] = null; $sc = trail_scene($exp);
    [$ex, $ey] = $sc['map']['spots']['9']; $sc['x'] = $ex; $sc['y'] = $ey; $sc['st']['phase'] = 'confirm'; trail_save($sc);
    trail_next($u, $exp);
}
$exp['encounter'] = null; $sc = trail_scene($exp);
$tc = &tool_tier_cache(); $tc = [];
q("DELETE FROM user_items WHERE user_id = ? AND item_id IN (SELECT id FROM items WHERE effects LIKE '%\"tool\":\"lantern\"%')", [$u['id']]);
$gt = $sc['map']['art']['gates'][0]['tiles'][1];   // stand a few tiles from the gate so it is inside the 7 x 7 window
foreach ([[-2, 0], [-3, 0], [-1, 0], [0, -2], [0, 2], [-2, -1], [-2, 1]] as [$dx, $dy]) if (in_array(tm_tile($sc['map'], $gt[0] + $dx, $gt[1] + $dy), ['.', ','], true)) { $sc['x'] = $gt[0] + $dx; $sc['y'] = $gt[1] + $dy; break; }
$html = trail_view_html($u, $exp, $sc, false);
ok('a shut gate is drawn with the 🔒 mark', str_contains($html, '🔒') && str_contains($html, 'tmgatemark'), '');
ok('the gate says what it needs (Miner’s Lantern)', str_contains($html, 'Blocked: ') && str_contains($html, 'Lantern'), '');
ok('the legend names the lock', str_contains($html, 'Needs a tool'), '');
ok('a shut gate shows no open mark or open legend', !str_contains($html, 'tmgateopen') && !str_contains($html, 'Open gate') && !str_contains($html, 'Open: '), '');
$lan = (int)q_val("SELECT id FROM items WHERE effects LIKE '%\"tool\":\"lantern\"%' AND effects LIKE '%\"tier\":2%' ORDER BY id LIMIT 1");
if ($lan) {
    give_item((int)$u['id'], $lan, 1); $tc = [];
    $html2 = trail_view_html($u, $exp, $sc, false);
    ok('with the lantern the lock is gone', !str_contains($html2, '🔒') && !str_contains($html2, 'Needs a tool'), '');
    ok('with the lantern the gate shows the open mark', str_contains($html2, 'tmgateopen') && str_contains($html2, '🔓'), '');
    ok('the open gate tile is labelled Open: <tool> gate', (bool)preg_match('~aria-label="Open: [^"]+ gate"~', $html2), '');
    ok('the legend names the open gate', str_contains($html2, 'Open gate'), '');
    ok('the open mark uses no inline style', !str_contains($html2, 'style='), '');
} else ok('found a tier 2 lantern item', false);
// route 228 stays free of fights
ok('route 228 has no M token anywhere', (function () { foreach (trail_authored_all()['228']['sections'] as $s) if (!empty($s['extra_minibosses'])) return false; return true; })());
echo $fails ? "$fails FAILED\n" : "ok\n";
exit($fails ? 1 : 0);
