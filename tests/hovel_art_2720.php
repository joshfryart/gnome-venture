<?php
// 2.7.20 hovel room art (aseprite-source/extras-pixel/scripts/hovel-room-2720.py) is installed and wired, with a graceful fallback:
// the 48 x 72 home gnome (+ tint layers), the night windows, the steam / z sprites, the Copper / Cast-Iron / Samovar kettle overlays, the 20 px kettle icons.
// Run by hovel_art_2720.sh on an installed copy (player "sprout"; files are moved away and back in that copy only). Usage: php tests/hovel_art_2720.php GAME
$_SERVER['SCRIPT_NAME'] = '/index.php';
require $argv[1] . '/includes/bootstrap.php';
require_once APP_ROOT . '/includes/gnome.php';
require_once APP_ROOT . '/includes/home_slim.php';
require_once APP_ROOT . '/includes/tea_view.php';
$fails = 0;
set_exception_handler(function (Throwable $e) { echo '  EXCEPTION ' . get_class($e) . ': ' . $e->getMessage() . ' @ ' . basename($e->getFile()) . ':' . $e->getLine() . "\n"; exit(1); });
function ok(string $what, bool $cond, string $extra = ''): void { global $fails; echo ($cond ? '  ok   ' : '  FAIL ') . $what . ($cond ? '' : "  $extra") . "\n"; if (!$cond) $fails++; }
function cfg(array $kv): void { foreach ($kv as $k => $v) set_setting($k, (string)$v); setting('__reload__'); }
$img = APP_ROOT . '/assets/img/';
// Moves a file away for the length of $fn (the installed copy only), then puts it back.
function without(array $rels, callable $fn) { global $img; foreach ($rels as $r) rename($img . $r, $img . $r . '.away'); clearstatcache(); try { return $fn(); } finally { foreach ($rels as $r) rename($img . $r . '.away', $img . $r); clearstatcache(); } }

$FILES = [
    'sprite/gnome-home-big.png' => [48, 72], 'sprite/gnome-home-big-hat.png' => [48, 72], 'sprite/gnome-home-big-beard.png' => [48, 72],
    'scenes/hovel-window-curtain-night.png' => [48, 48], 'scenes/hovel-window-plain-night.png' => [48, 48], 'scenes/hovel-window-ivy-night.png' => [48, 48],
    'fx/fx-steam-a.png' => [10, 10], 'fx/fx-steam-b.png' => [8, 8], 'fx/fx-z-a.png' => [8, 8], 'fx/fx-z-b.png' => [6, 6],
    'scenes/hovel-kettle-copper.png' => [40, 47], 'scenes/hovel-kettle-castiron.png' => [40, 47], 'scenes/hovel-kettle-samovar.png' => [40, 47],
    'ico/ico-kettle-tin.png' => [20, 20], 'ico/ico-kettle-copper.png' => [20, 20], 'ico/ico-kettle-castiron.png' => [20, 20], 'ico/ico-kettle-samovar.png' => [20, 20], 'ico/ico-steam-cup.png' => [20, 20],
];

echo "== every new file: there, its size, hard pixels, no pure black or white\n";
foreach ($FILES as $rel => [$w, $h]) {
    $f = $img . $rel;
    if (!is_file($f)) { ok("$rel is installed", false); continue; }
    $sz = getimagesize($f);
    $im = imagecreatefrompng($f);
    $semi = 0; $bw = 0; $solid = 0;
    for ($y = 0; $y < $sz[1]; $y++) for ($x = 0; $x < $sz[0]; $x++) {
        $c = imagecolorsforindex($im, imagecolorat($im, $x, $y));
        if ($c['alpha'] !== 0 && $c['alpha'] !== 127) $semi++;
        if ($c['alpha'] === 0) { $solid++; $rgb = [$c['red'], $c['green'], $c['blue']]; if ($rgb === [0, 0, 0] || $rgb === [255, 255, 255]) $bw++; }
    }
    ok("$rel: {$w}x{$h}, $solid drawn pixels, none semi-transparent, no #000000 / #ffffff", [$sz[0], $sz[1]] === [$w, $h] && $semi === 0 && $bw === 0 && $solid > 0, "{$sz[0]}x{$sz[1]} semi=$semi bw=$bw solid=$solid");
}
$cat = hovel_decor_catalog();
foreach ($cat['slots']['window']['items'] as $ik => $_) ok("window '$ik' has its night twin", is_file($img . "scenes/hovel-window-$ik-night.png"));
ok('the kettle overlay box is the files\' size', array_slice(HOVEL_KETTLE_ART, 2) === [40, 47]);
ok('the gnome box is 48 x 72 with its feet on the floor line (220, plus the 2-row floor shadow)', [(int)$cat['gnome']['w'], (int)$cat['gnome']['h'], (int)$cat['gnome']['y'] + (int)$cat['gnome']['h']] === [48, 72, 222], json_encode($cat['gnome']));

$uid = (int)q_val("SELECT id FROM users WHERE username = 'sprout'");
cfg(['game_clock_on' => 1, 'home_slim' => 1, 'tea_open' => 'everyone']);
$home = (int)q_val('SELECT home_village_id FROM users WHERE id = ?', [$uid]);
q('UPDATE users SET location_id = ?, game_minute = 600, kettle = 0 WHERE id = ?', [$home, $uid]);
$row = fn(): array => q_one('SELECT * FROM users WHERE id = ?', [$uid]);
$chosen = hovel_decor_chosen($uid);
$win = $chosen['window'];
$_GET = [];
$today = fn(): string => home_slim_banner_html($row(), $chosen, 'today', 'Hello');

echo "== the gnome\n";
$b = $today();
ok('the big gnome and its tinted hat and beard layers, in the catalogue box', preg_match('~assets/img/sprite/gnome-home-big\.png(\?v=[^"]*)?" x="202" y="150" width="48" height="72"~', $b) && str_contains($b, 'gnome-home-big-hat.png') && str_contains($b, 'gnome-home-big-beard.png') && substr_count($b, 'filter="url(#tint-') === 2);
$b0 = without(['sprite/gnome-home-big.png'], $today);
ok('no big file: the old 32 x 48 sprite on the same floor spot', preg_match('~assets/img/sprite/gnome-home\.png(\?v=[^"]*)?" x="214" y="172" width="32" height="48"~', $b0) && !str_contains($b0, 'gnome-home-big'));
$b0 = without(['sprite/gnome-home-big.png', 'sprite/gnome-home.png'], $today);
ok('no sprite at all: the layered avatar in the gnome box', str_contains($b0, '<g class="hr-gnome"><svg class="gnomeart" x="202" y="150" width="48" height="72"'));
$b0 = without(['sprite/gnome-home-big-hat.png'], $today);
ok('no hat layer: the gnome still draws (beard tinted only)', str_contains($b0, 'gnome-home-big.png') && substr_count($b0, 'filter="url(#tint-') === 1);

echo "== the window by day and by night\n";
ok('by day: the day window', str_contains($b, "scenes/hovel-window-$win.png") && !str_contains($b, '-night.png'));
q('UPDATE users SET game_minute = 1380 WHERE id = ?', [$uid]);
$n = $today();
ok('at 23:00 the room is night', (bool)preg_match('/ dp-(night|dusk)"/', $n));
ok('...with the night window', str_contains($n, "scenes/hovel-window-$win-night.png") && !str_contains($n, "scenes/hovel-window-$win.png"));
ok('...on the Furnish crop too', str_contains(home_slim_banner_html($row(), $chosen, 'furnish', 'Hello'), "hovel-window-$win-night.png"));
$n0 = without(["scenes/hovel-window-$win-night.png"], $today);
ok('no night file: the day picture at night', str_contains($n0, "scenes/hovel-window-$win.png") && !str_contains($n0, '-night.png'));
q('UPDATE users SET game_minute = 600 WHERE id = ?', [$uid]);

echo "== steam and z's\n";
ok('pixel steam puffs and z\'s (no drawn circles or letters)', (bool)preg_match('~<g class="hr-steam" aria-hidden="true"><image class="a" href="[^"]*fx/fx-steam-a\.png[^"]*" x="316" y="157" width="10" height="10"[^>]*/><image class="b" href="[^"]*fx-steam-b\.png[^"]*"[^>]*/></g>~', $b)
    && (bool)preg_match('~<g class="hr-zz" aria-hidden="true"><image class="a" href="[^"]*fx/fx-z-a\.png[^"]*"[^>]*/><image class="b" href="[^"]*fx-z-b\.png[^"]*"[^>]*/></g>~', $b) && !str_contains($b, '<circle class="a"') && !str_contains($b, '<text class="a"'));
$b0 = without(['fx/fx-steam-a.png', 'fx/fx-z-b.png'], $today);
ok('a missing sprite: its drawn circle or letter instead', str_contains($b0, '<circle class="a"') && str_contains($b0, '<text class="b" x="106" y="168">z</text>') && str_contains($b0, 'fx-steam-b.png') && str_contains($b0, 'fx-z-a.png'));
$css = (string)file_get_contents(APP_ROOT . '/assets/style.css');
ok('the CSS hides the sprites until their animation and keeps them still under reduced motion', str_contains($css, '.hroom .hr-steam image, .hroom .hr-zz image { opacity: 0;') && str_contains($css, '.hroom .hr-steam image, .hroom .hr-zz image { opacity: .6; }'));

echo "== kettle overlays by tier\n";
ok('the tin kettle (0): no overlay, the painted one', !str_contains($b, 'hr-kettle'));
foreach ([1 => 'copper', 2 => 'castiron', 3 => 'samovar'] as $t => $name) {
    q('UPDATE users SET kettle = ? WHERE id = ?', [$t, $uid]);
    $k = $today();
    $at = strpos($k, 'class="hr-kettle');
    ok("kettle $t: the $name overlay over the painted kettle, under the gnome and the tap boxes", $at !== false && preg_match('~<image class="hr-kettle hr-kettle-' . $name . '" href="/assets/img/scenes/hovel-kettle-' . $name . '\.png(\?v=[^"]*)?" x="312" y="140" width="40" height="47"~', $k) && $at > strpos($k, 'class="hr-back"') && $at < strpos($k, 'class="hr-gnome"') && $at < strpos($k, 'hd-kettle'));
    ok("...the steam leaves its spout", str_contains($k, 'x="' . HOVEL_KETTLE_STEAM[$t][0] . '" y="' . HOVEL_KETTLE_STEAM[$t][1] . '" width="10"'));
    ok("...on the cropped banner too", str_contains(hovel_room_svg($row(), $chosen, 'crop'), 'hovel-kettle-' . $name . '.png'));
}
$k0 = without(['scenes/hovel-kettle-samovar.png'], $today);
ok('no samovar file: no overlay, the tin steam spot', !str_contains($k0, 'hr-kettle') && str_contains($k0, 'x="316" y="157" width="10"'));
cfg(['tea_open' => 'off']);
ok('tea closed for the viewer: no overlay (the tin kettle stays painted)', !str_contains($today(), 'hr-kettle'));
cfg(['tea_open' => 'everyone']);

echo "== the tea popover's kettle icons\n";
foreach ([0 => 'tin', 1 => 'copper', 2 => 'castiron', 3 => 'samovar'] as $t => $name) {
    q('UPDATE users SET kettle = ? WHERE id = ?', [$t, $uid]);
    $k = tea_kettle_html($row());
    ok("kettle $t: the $name icon on the kettle line, no emoji", preg_match('~<img class="tea-ki tea-k' . $t . ' pix" src="/assets/img/ico/ico-kettle-' . $name . '\.png(\?v=[^"]*)?" alt="" width="20" height="20">~', $k) && !str_contains($k, '🫖'));
}
$p = tea_panel_html($row(), [], true);
ok('the popover heading has the kettle icon', str_contains($p, '<h3 id="htea-h"><img class="tea-ki tea-k3 pix" src="/assets/img/ico/ico-kettle-samovar.png'));
ok('no icon file: the emoji is back', without(['ico/ico-kettle-samovar.png'], fn() => str_contains(tea_kettle_html($row()), '<span class="tea-ki tea-k3" aria-hidden="true">🫖</span>')));
q('UPDATE users SET kettle = 0, game_minute = 600 WHERE id = ?', [$uid]);

echo $fails ? "$fails FAILED\n" : "ok\n";
exit($fails ? 1 : 0);
