<?php
// The logged-out front page (2.6.41): the landing card and How to play (includes/landing_view.php).
// php tests/landing_home.php GAME_DIR      (an installed game; walk.sh installs one)
$_SERVER['SCRIPT_NAME'] = '/index.php';
require $argv[1] . '/includes/bootstrap.php';
require_once $argv[1] . '/includes/landing_view.php';
$fails = 0;
function ok(string $what, bool $cond, string $extra = ''): void { global $fails; echo ($cond ? '  ok   ' : '  FAIL ') . $what . ($cond ? '' : "  $extra") . "\n"; if (!$cond) $fails++; }
$json = function (string $h): array { return preg_match('~<script type="application/json" id="lh-data">(.*?)</script>~s', $h, $m) ? (json_decode($m[1], true) ?: []) : []; };

foreach (['puzzles_open', 'jigsaw_open', 'ppal_open', 'guest_open'] as $k) set_setting($k, '0'); setting('__reload__');
$h = landing_html();
ok('landing card: site name, sign-up and log-in links, no guest button while guests are off', str_contains($h, 'class="lh-hero"') && str_contains($h, 'register.php') && str_contains($h, 'login.php') && !str_contains($h, 'guest.php'));
ok('How to play heading with the #howto anchor', str_contains($h, 'id="howto"'));
ok('5 cards while Jigsaw and Puzzle Pals are closed (no Puzzle step in the loop)', substr_count($h, '<article class="lh-card') === 5 && !str_contains($h, 'id="lh-jig"') && !str_contains($h, 'lh-roster') && !str_contains($h, '>Puzzle</li>'), (string)substr_count($h, '<article class="lh-card'));
ok('CSP safe: no style attribute, no event attribute, the only script is the JSON block', !preg_match('/\sstyle=|\son[a-z]+=/i', $h) && substr_count($h, '<script') === 1);
$d = $json($h);
ok('data block parses; no pal or jigsaw pictures while those are closed', isset($d['trails'], $d['objBase']) && $d['pals'] === [] && $d['jigsaw'] === '');
ok('the three Trail sections are there (their ground pictures ship in the repo)', count($d['trails']) === 3, (string)count($d['trails']));
foreach ($d['trails'] as $t) {
    [$r, $s] = array_values(array_filter(LANDING_TRAILS, fn($x) => $x[2] === $t['name']))[0];
    [$map] = trail_map_authored(trail_authored_section($r, $s));
    $p = $t['path']; $bad = '';
    if ($p[0] !== $map['entry']) $bad = 'does not start at the entry';
    if ($p[count($p) - 1] !== $map['spots']['9']) $bad = 'does not end at the way on';
    for ($i = 0; $i < count($p); $i++) {
        if (tm_tile($map, $p[$i][0], $p[$i][1]) === '#') { $bad = 'walks through a wall at step ' . $i; break; }
        if ($i && abs($p[$i][0] - $p[$i - 1][0]) + abs($p[$i][1] - $p[$i - 1][1]) !== 1) { $bad = 'jumps at step ' . $i; break; }
    }
    ok($t['name'] . ': the walk goes entry to way on, tile by tile, on floor', $bad === '', $bad);
    $miss = array_filter($t['objs'], fn($o) => !is_file(APP_ROOT . '/assets/img/trail/obj/' . $o[2] . '.png') || !isset($t['sizes'][$o[2]]));
    ok($t['name'] . ': every raised sprite has its picture and size', !$miss && count($t['objs']) > 50, count($miss) . ' missing of ' . count($t['objs']));
    ok($t['name'] . ': every find it lists is on the walk or left alone', !array_filter($t['finds'], fn($f) => tm_tile($map, $f[0], $f[1]) === '#'));
}
ok('a gated section is never used', landing_trail(315, 2, 'x', 'y', 'z') === null);
ok('a section that does not exist is left out', landing_trail(99999, 0, 'x', 'y', 'z') === null);

foreach (['puzzles_open', 'jigsaw_open', 'ppal_open', 'guest_open'] as $k) set_setting($k, '1'); setting('__reload__');
$h2 = landing_html(); $d2 = $json($h2);
ok('with Jigsaw and Puzzle Pals open: 7 cards, the canvas, the roster of six, the Puzzle step, the guest button', substr_count($h2, '<article class="lh-card') === 7 && str_contains($h2, 'id="lh-jig"') && substr_count($h2, '<li') >= 6 && preg_match_all('~puzzles/pals/mw-[a-z-]+\.png~', $h2) >= 7 && str_contains($h2, '>Puzzle</li>') && str_contains($h2, 'guest.php'));
ok('pal and jigsaw pictures are in the data then', count($d2['pals']) === 2 && str_contains($d2['jigsaw'], 'maplewold.jpg'));
ok('every picture the page names is on disk', (function () use ($h2) {
    preg_match_all('~assets/img/([A-Za-z0-9_./-]+\.(?:png|jpg))~', $h2, $m);
    foreach (array_unique($m[1]) as $f) if (!is_file(APP_ROOT . '/assets/img/' . $f) && !str_contains($f, 'trail/ground/')) { echo "     missing: $f\n"; return false; }
    return count($m[1]) > 20;
})());
ok('every picture the styles name is on disk', (function () {
    $css = (string)file_get_contents(APP_ROOT . '/assets/landing.css');
    preg_match_all('~url\("(img/[^"]+)"\)~', substr($css, (int)strpos($css, '2.6.41')), $m);
    foreach (array_unique($m[1]) as $f) if (!is_file(APP_ROOT . '/assets/' . $f)) { echo "     missing: $f\n"; return false; }
    return count($m[1]) > 15;
})());
foreach (['home.sub', 'home.htp.lede', 'home.htp.grow', 'home.htp.cook', 'home.htp.explore', 'home.htp.meet', 'home.htp.collect', 'home.htp.puzzle', 'home.htp.pals'] as $k) if (stext($k) === '') { ok("page text $k has a default", false); }
ok('card texts are "Title, new line, text"', landing_pair('home.htp.grow')[0] === 'Grow' && strlen(landing_pair('home.htp.grow')[1]) > 20);
foreach (['puzzles_open', 'jigsaw_open', 'ppal_open', 'guest_open'] as $k) set_setting($k, '0');
echo $fails ? "$fails FAILED\n" : "ok\n";
exit($fails ? 1 : 0);
