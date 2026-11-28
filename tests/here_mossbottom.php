<?php
// 2.8.99b: Mossbottom's Here picture from anywhere (here.php?hub=1): the town-hub layout on scenes/here-town-hub.png, every spot links somewhere real,
// the gateway leads back to where the gnome stands, the drawn fallback when the art is missing, and a main town's picture is unchanged.
// php tests/here_mossbottom.php GAME_DIR   (an installed game, player "sprout")
$_SERVER['SCRIPT_NAME'] = '/here.php';
require $argv[1] . '/includes/bootstrap.php';
require_once $argv[1] . '/includes/adventure.php';
require_once $argv[1] . '/includes/here_view.php';
require_once $argv[1] . '/includes/place_ui.php';
$fails = 0;
function ok(string $what, bool $cond, string $extra = ''): void { global $fails; echo ($cond ? '  ok   ' : '  FAIL ') . $what . ($cond ? '' : "  $extra") . "\n"; if (!$cond) $fails++; }
/** The picture's hotspots: id => href. */
function spots_of(string $h): array { preg_match_all('/id="hs-(s-[a-z0-9-]+)" href="([^"]*)"/', $h, $m); return array_combine($m[1], array_map('html_entity_decode', $m[2])); }
/** The inside of one hotspot's card (its dialog). */
function card_of(string $h, string $id): string { return preg_match('~<dialog[^>]*id="hubpop-' . preg_quote($id, '~') . '".*?</dialog>~s', $h, $m) ? html_entity_decode($m[0]) : ''; }

// Arrange: sprout stands in a main town (not the hub)
$u = q_one("SELECT * FROM users WHERE username = 'sprout'");
$town = q_one("SELECT * FROM locations WHERE kind = 'market' ORDER BY id LIMIT 1");
q('UPDATE users SET location_id = ? WHERE id = ?', [(int)$town['id'], (int)$u['id']]);
$u = q_one('SELECT * FROM users WHERE id = ?', [(int)$u['id']]);
$hub = here_hub_node();
ok('the hub location exists', $hub && $hub['kind'] === 'hub', json_encode($hub));
$L = here_layouts_all()['town-hub'] ?? null;
ok('the town-hub layout ships with spots', $L && count($L['spots'] ?? []) >= 6);
ok('Mossbottom\'s picture is on disk at the main-town size', ($sz = @getimagesize(APP_ROOT . '/assets/img/scenes/here-town-hub.png')) && $sz[0] === 480 && $sz[1] === 270, json_encode($sz ?? null));

// Act: the Mossbottom picture from anywhere
$GLOBALS['gnav_gate'] = false;
$h = here_hub_view($u);
$spots = spots_of($h);

// Assert: the picture, gate view, one hotspot per layout spot
ok('the hub picture renders on its art', str_contains($h, 'data-hub="town-hub"') && str_contains($h, 'assets/img/scenes/here-town-hub.png'), substr($h, 0, 200));
ok('a gate-view picture (compass + globe bar)', !empty($GLOBALS['gnav_gate']) && str_contains($h, 'hs-routes'));
ok('one hotspot for every spot in the layout', count($spots) === count($L['spots']), count($spots) . ' of ' . count($L['spots']) . ': ' . implode(',', array_keys($spots)));
$hubSpots = array_map('intval', array_column(q("SELECT id FROM town_spots WHERE region = ? AND active = 1", [HUB_REGION])->fetchAll(), 'id'));
$hubShops = array_map('intval', array_column(q("SELECT s.id FROM shops s JOIN locations l ON l.id = s.location_id WHERE l.region = ? AND s.open = 1", [HUB_REGION])->fetchAll(), 'id'));
foreach ($spots as $id => $href) {
    if ($id === 's-wild') { ok("$id leads back to where the gnome stands", str_ends_with($href, 'here.php') && str_contains($h, 'Back to ' . e($town['name'])), $href); continue; }
    ok("$id opens its card on the hub picture (no-script link)", str_contains($href, 'here.php?hub=1&o=' . $id), $href);
    $c = card_of($h, $id);
    if ($id === 's-shops') {
        preg_match_all('/shop\.php\?id=(\d+)/', $c, $m);
        $ids = array_map('intval', array_unique($m[1]));
        ok("$id lists every open Mossbottom shop and nothing else", $ids && !array_diff($ids, $hubShops) && !array_diff($hubShops, $ids), json_encode($ids) . ' vs ' . json_encode($hubShops));
    } else {
        ok("$id card loads a real Mossbottom spot", preg_match('/town\.php\?hub=1&spot=(\d+)&frag=1/', $c, $m) === 1 && in_array((int)$m[1], $hubSpots, true), substr($c, 0, 200));
    }
}
ok('the compass leads back, not along the hub\'s roads', str_contains(card_of($h, 'routes'), 'Back to ' . e($town['name'])) && !str_contains($h, 'id="hs-wander"'));
ok('the switcher\'s Mossbottom tab opens the picture', str_contains(place_switcher_html($town, 'here'), 'here.php?hub=1'));

// the fallback: no art = the drawn sky and ground with the same hotspots
$png = APP_ROOT . '/assets/img/scenes/here-town-hub.png';
rename($png, $png . '.off'); clearstatcache();
$hf = here_hub_view($u);
rename($png . '.off', $png); clearstatcache();
ok('without the art: the drawn fallback, same hotspots', str_contains($hf, 'hubsvg chrome noart') && !str_contains($hf, 'here-town-hub.png') && array_keys(spots_of($hf)) === array_keys($spots));

// another town is unchanged: its own picture, its own links, no Mossbottom peek bits
$GLOBALS['gnav_gate'] = false;
$ht = here_view($u, $town);
$ts = spots_of($ht);
ok('a main town keeps its own picture', str_contains($ht, 'data-hub="town-') && !str_contains($ht, 'data-hub="town-hub"'));
ok('a main town\'s card links stay on here.php (no hub=1)', $ts && !array_filter($ts, fn($x) => str_contains($x, 'hub=1')), json_encode($ts));
ok('a main town has no "Back to" gateway', !str_contains($ht, 'Back to '));
ok('a main town\'s compass is its routes list', !str_contains(card_of($ht, 'routes'), 'reachable from anywhere'));
echo $fails ? "$fails FAILED\n" : "ok\n";
exit($fails ? 1 : 0);
