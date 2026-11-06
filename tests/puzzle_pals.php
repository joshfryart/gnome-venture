<?php
// v2.0.88 Puzzle Pals step 1: data, generator, art gate, schema, guest purge. Run by puzzle_pals.sh on a walk.sh install: php tests/puzzle_pals.php GAME
$_SERVER['SCRIPT_NAME'] = '/index.php';
require $argv[1] . '/includes/bootstrap.php';
require_once APP_ROOT . '/includes/puzzle_pals.php';
require_once APP_ROOT . '/includes/guest.php';
$fails = 0;
function ok(string $what, bool $cond, string $extra = ''): void { global $fails; echo ($cond ? 'ok   ' : 'FAIL ') . $what . ($cond ? '' : "  ($extra)") . "\n"; if (!$cond) $fails++; }
jigsaw_ensure();
ok('ppal_ensure makes the tables', ppal_ensure());
foreach (['ppal_releases', 'ppal_found', 'ppal_trophies'] as $t) ok("table $t", (bool)q("SELECT 1 FROM $t LIMIT 1"));
foreach (['ppal_at', 'ppal_day', 'ppal_count'] as $c) ok("users.$c", (bool)q("SELECT $c FROM users LIMIT 1"));
$tc = array_map(fn($x) => $x[0], array_filter(guest_tables(), fn($x) => $x[1] === 'user_id'));
foreach (['ppal_releases', 'ppal_found', 'ppal_trophies'] as $t) ok("guest purge list holds $t", in_array($t, $tc, true));
ok('no function named pal_* was added by Puzzle Pals', !function_exists('pal_on_solve') && function_exists('ppal_on_solve'));
echo "== authored rosters\n";
$d = ppal_data();
ok('authored pictures (14 gallery + lair + delve), 6 pals each', count($d) >= 42 && array_sum(array_map('count', $d)) === 6 * count($d) && isset($d['maplewold'], $d['maizehollow'], $d['sunsprinkle']), count($d) . ' pictures');
foreach ($d as $slug => $rows) {
    $m = array_count_values(array_column($rows, 'rarity'));
    ok("$slug: 6 pals = 3 common / 2 uncommon / 1 rare", count($rows) === 6 && ($m['common'] ?? 0) === 3 && ($m['uncommon'] ?? 0) === 2 && ($m['rare'] ?? 0) === 1);
}
$map = q_one("SELECT * FROM puzzle_pics WHERE slug = 'jig-maplewold'");
ok('ppal_pic_slug strips jig-', ppal_pic_slug($map) === 'maplewold');
ok('ppal_roster(maplewold) = authored 6', count(ppal_roster($map)) === 6 && ppal_roster($map)[0]['key'] === 'mw-acorn-nip');
ok('perk "-" falls back to the calling', ppal_roster($map)[0]['perk'] === 'tinker');
ok('every built-in gallery picture has an authored roster', (function () use ($d) { $n = 0; foreach (q("SELECT * FROM puzzle_pics WHERE source = 'builtin' AND kind = 'still'")->fetchAll() as $b) { if (!isset($d[ppal_pic_slug($b)])) return false; $n++; } return $n === 14; })());
ok('a built-in picture with no authored row has no roster', ppal_roster(['slug' => 'jig-nowhere', 'source' => 'builtin', 'kind' => 'still']) === []);
ok('a picture with no authored row and source place/upload gets a generated roster', count(ppal_roster(['slug' => 'pl-haven-zzz-abc123', 'source' => 'place', 'kind' => 'still', 'unlock_key' => 'haven-zzz', 'title' => 'Z'])) === 6 && count(ppal_roster(['slug' => 'upload-zzz', 'source' => 'upload', 'kind' => 'still', 'title' => 'Z'])) === 6);
ok('a GIFsaw picture has no roster', ppal_roster(['slug' => 'sunflower', 'source' => 'builtin', 'kind' => 'gif']) === []);
echo "== generator\n";
$kinds = ['haven', 'wonder', 'delve', 'lair'];
$allNames = [];
foreach ($kinds as $k) {
    for ($i = 1; $i <= 12; $i++) {
        $pic = ['slug' => "pl-$k-test$i-abc123", 'source' => 'place', 'kind' => 'still', 'unlock_key' => "$k-test$i", 'title' => "Test $i"];
        $r = ppal_place_roster($pic); $r2 = ppal_place_roster($pic);
        if ($r !== $r2) { ok("$k$i deterministic", false); continue; }
        $m = array_count_values(array_column($r, 'rarity'));
        $bandOk = true;
        foreach ($r as $p) {
            $t = $p['grit'] + $p['nimble'] + $p['hardiness'] + $p['luck']; [$lo, $hi] = PPAL_STATS_TOTAL[$p['rarity']];
            if ($t < $lo || $t > $hi || max($p['grit'], $p['nimble'], $p['hardiness'], $p['luck']) > 3) $bandOk = false;
            if (!preg_match('/^\d+-\d+$/', $p['piece']) || explode('-', $p['piece'])[0] > 11 || explode('-', $p['piece'])[1] > 7) $bandOk = false;
            if (!in_array($p['calling'], PPAL_CALLINGS, true) || !in_array($p['knob'], PPAL_KNOBS, true)) $bandOk = false;
        }
        $sk = array_map(fn($p) => $p['shape'] . '/' . $p['knob'], $r);
        $nm = array_column($r, 'name');
        if (!($r && count($r) === 6 && ($m['common'] ?? 0) === 3 && ($m['uncommon'] ?? 0) === 2 && ($m['rare'] ?? 0) === 1 && $bandOk && count(array_unique($nm)) === 6 && count(array_unique($sk)) === 6 && count(array_unique(array_column($r, 'key'))) === 6)) {
            ok("$k$i roster shape", false, json_encode($r)); continue;
        }
        foreach ($nm as $n) $allNames[$n] = 1;
    }
}
ok('48 generated rosters (pictures with no authored row): 6 each, 3/2/1, stats in band, unique names and shape+knob, same every time', $fails === 0);
ok('different places draw different pals', ppal_place_roster(['slug' => 'pl-a', 'source' => 'place', 'unlock_key' => 'haven-a', 'title' => 'A']) !== ppal_place_roster(['slug' => 'pl-b', 'source' => 'place', 'unlock_key' => 'haven-b', 'title' => 'B']));
ok('names vary across places (not one roster for all)', count($allNames) > 120, (string)count($allNames));
$pic = ['slug' => 'pl-lair-x-abc', 'source' => 'place', 'kind' => 'still', 'unlock_key' => 'lair-x', 'title' => 'X'];
ok('rare is a whimsy piece, others are not', (function () use ($pic) { foreach (ppal_place_roster($pic) as $p) if (($p['rarity'] === 'rare') !== str_starts_with($p['shape'], 'whimsy-')) return false; return true; })());
set_setting('ppal_roster_size', '4'); setting('__reload__');
ok('ppal_roster_size cuts generated and authored rosters', count(ppal_place_roster($pic)) === 4 && count(ppal_roster($map)) === 4);
set_setting('ppal_roster_size', '6'); setting('__reload__');
ok('an authored row for a place slug overrides the generated one', (function () {
    $pic = ['slug' => 'maplewold', 'source' => 'place', 'kind' => 'still', 'unlock_key' => 'haven-maple', 'title' => 'M'];
    return ppal_roster($pic)[0]['key'] === 'mw-acorn-nip';   // data file is keyed by slug whatever the source
})());
echo "== art gate\n";
$ph = APP_ROOT . '/assets/img/puzzles/pals/';
@mkdir($ph, 0777, true);
foreach (ppal_roster($map) as $p) @unlink($ph . $p['key'] . '.png');
ok('no art = not ready', !ppal_art_ready($map));
ok('missing art gives no URL', ppal_art_url('mw-acorn-nip') === '');
foreach (ppal_roster($map) as $p) copy($ph . '_placeholder.png', $ph . $p['key'] . '.png');
ok('placeholder art = not ready', !ppal_art_ready($map) && ppal_is_placeholder($ph . 'mw-acorn-nip.png'));
foreach (ppal_roster($map) as $i => $p) file_put_contents($ph . $p['key'] . '.png', file_get_contents($ph . '_placeholder.png') . str_repeat("x", $i + 1));
ok('real art = ready', ppal_art_ready($map));
ok('art URL when the file is there', str_contains(ppal_art_url('mw-acorn-nip'), 'mw-acorn-nip.png'));
unlink($ph . 'mw-leaf-tuck.png');
ok('one pal missing = not ready', !ppal_art_ready($map));
foreach (ppal_roster($map) as $p) @unlink($ph . $p['key'] . '.png');
echo "== settings\n";
foreach (['ppal_open' => '0', 'ppal_party' => '0', 'ppal_party_max' => '2', 'ppal_roster_size' => '6'] as $k => $v)
    ok("setting $k default $v", setting($k) === $v, setting($k));
echo $fails ? "$fails FAILED\n" : "all ok\n";
exit($fails ? 1 : 0);
