<?php
// Treks v2.0.20: the Whole map fold (includes/trek_minimap.php). Run on an installed copy: php tests/trek_minimap.php GAME_DIR [PORT]  (treks.sh does).
// A fresh run shows only the start area; unseen and hidden spots never leak (no names or codes); Ch I and Ch II fully seen stay under 12 KB; no style=;
// the real map page has the fold (closed), the fight screen does not.
$GAME = $argv[1];
$PORT = (int)($argv[2] ?? 8842);
$_SERVER['SCRIPT_NAME'] = '/trek.php';
require $GAME . '/includes/bootstrap.php';
require_once $GAME . '/includes/trek.php';
require_once $GAME . '/includes/trek_fight.php';
require_once $GAME . '/includes/trek_minimap.php';
if (session_status() !== PHP_SESSION_ACTIVE) session_start();
$fails = 0;
set_exception_handler(function (Throwable $e) { if (db()->inTransaction()) db()->rollBack(); echo '  EXCEPTION ' . get_class($e) . ': ' . $e->getMessage() . ' @ ' . basename($e->getFile()) . ':' . $e->getLine() . "\n"; exit(1); });
function ok(string $what, bool $cond, string $extra = ''): void { global $fails; echo ($cond ? '  ok   ' : '  FAIL ') . $what . ($cond ? '' : "  $extra") . "\n"; if (!$cond) $fails++; }
$uid = (int)q_val("SELECT id FROM users WHERE username = 'sprout'");
set_setting('trek_open', '1'); set_setting('trek_event_pct', '0'); set_setting('trek_enc_percent', '0'); set_setting('trek_petals_daily', '150'); set_setting('trek_entry_energy', '10');
setting('__reload__');
foreach (['trek_flags', 'trek_pack', 'trek_party', 'trek_recruits'] as $t) q("DELETE FROM $t WHERE run_id IN (SELECT id FROM trek_runs WHERE user_id = ?)", [$uid]);
q('DELETE FROM trek_runs WHERE user_id = ?', [$uid]);
q('UPDATE users SET level = 16, energy = 100, coins = 1000, calling = NULL, trek_ch = 1, trek_pet_day = NULL, trek_pet_today = 0 WHERE id = ?', [$uid]);
$u = q_one('SELECT * FROM users WHERE id = ?', [$uid]);

echo "== a fresh run: only the start area\n";
$r1 = trek_new_run($u, 1);
$h1 = trek_minimap_html($r1, $u);
ok('there is an svg, no style= attribute, no link, no form', str_starts_with($h1, '<svg') && !str_contains($h1, 'style=') && !str_contains($h1, '<a ') && !str_contains($h1, 'href') && !str_contains($h1, 'onclick'), substr($h1, 0, 200));
preg_match('~viewBox="(\d+) (\d+) (\d+) (\d+)"~', $h1, $vb);
ok('the view is only the start area (a few tiles wide), not the whole 40x40', $vb && (int)$vb[3] <= 12 && (int)$vb[4] <= 12, json_encode($vb));
ok('a fresh run is tiny', strlen($h1) < 1500, (string)strlen($h1));
ok('"you" is drawn', str_contains($h1, 'class="tmme"'));
$allSpots = trek_spots(1);
$leak = false;
foreach ($allSpots as $s) if (stripos($h1, $s['name']) !== false || stripos($h1, '"' . $s['code'] . '"') !== false) $leak = true;
ok('no spot name or code anywhere in the markup', !$leak);
$seenSpots = 0; foreach ($allSpots as $s) if (trek_seen_get($r1, $s['x'], $s['y'])) $seenSpots++;
$drawn = substr_count($h1, '<circle') + substr_count($h1, '<rect') - 1 /* bg */ - 1 /* you */ + substr_count($h1, 'class="tmob"');
ok('only seen spots are drawn (' . $seenSpots . ' seen)', $drawn <= $seenSpots, "drawn $drawn");
$none = $r1; $none['sn'] = str_repeat("\0", strlen($r1['sn']));
ok('nothing seen: nothing drawn (empty string)', trek_minimap_html($none, $u) === '');

echo "== hidden spots need a Wayfinder\n";
$hid = array_values(array_filter(trek_spots(1), fn($s) => $s['type'] === 'hidden' && !empty($s['data']['wayfinder'])));
ok('Chapter I has a Wayfinder-only hidden spot to test with', count($hid) > 0);
$full1 = $r1; $full1['sn'] = str_repeat("\xff", strlen($r1['sn']));
$mapNo = trek_minimap_html($full1, $u);
$uw = $u; $uw['calling'] = 'wayfinder';
$mapYes = trek_minimap_html($full1, $uw);
$cnt = fn(string $s) => substr_count($s, '<circle') + substr_count($s, '<rect') + substr_count($s, 'class="tmob"');
ok('with a Wayfinder the map shows more spots than without', trek_has_wayfinder($full1, $uw) && !trek_has_wayfinder($full1, $u) && $cnt($mapYes) > $cnt($mapNo), $cnt($mapNo) . ' vs ' . $cnt($mapYes));
ok('...exactly the Wayfinder-only hidden spots are the difference', $cnt($mapYes) - $cnt($mapNo) === count($hid), $cnt($mapNo) . ' vs ' . $cnt($mapYes) . ' / ' . count($hid));

echo "== fully seen: size and content\n";
foreach ([1, 2] as $ch) {
    $r = $ch === 1 ? $r1 : trek_new_run($u, 2);
    $r['sn'] = str_repeat("\xff", strlen($r['sn']));
    $h = trek_minimap_html($r, $uw);
    $kb = round(strlen($h) / 1024, 1);
    ok("Chapter $ch fully seen is under 12 KB ($kb KB, " . strlen($h) . ' bytes)', strlen($h) < 12288, (string)strlen($h));
    ok("Chapter $ch: no style=, and one path per class at most", !str_contains($h, 'style=') && substr_count($h, '<path') <= 3);
    ok("Chapter $ch: a camp and the objective are marked", str_contains($h, '<g class="tmcp">') && str_contains($h, 'class="tmob"'));
    $leak = false;
    foreach (trek_spots($ch) as $s) if (stripos($h, $s['name']) !== false) $leak = true;
    ok("Chapter $ch: no spot names", !$leak);
    // a done spot is dimmed
    $d = $r; foreach (trek_spots($ch) as $s) if (!in_array($s['type'], ['gate', 'start', 'exit', 'camp', 'npc', 'sign', 'oldcamp', 'hidden'], true)) { trek_flag_set($d, (string)($s['data']['flag'] ?? 'seen_' . $s['code'])); break; }
    ok("Chapter $ch: a done spot goes to the dimmed group", str_contains(trek_minimap_html($d, $uw), 'class="tmdn"'));
}
ok('the fold wrapper is a closed details with the summary', ($f = trek_minimap_fold($r1, $u)) !== '' && str_starts_with($f, '<details class="tkmini"><summary>') && !str_contains($f, ' open'));
ok('a chapter with no map draws nothing (any chapter number is safe)', trek_minimap_html(['chapter' => 99, 'sn' => '', 'x' => 0, 'y' => 0], $u) === '');

echo "== over HTTP: map page has the fold, the fight screen does not\n";
$rn = null;
$tx = fn(callable $f) => trek_tx($uid, $f, false);
q('DELETE FROM trek_runs WHERE user_id = ?', [$uid]);
$er = trek_tx($uid, fn(&$run, $uu) => trek_enter($run, $uu), false);
ok('entered the trek for the page test', trek_run_row($uid) !== null, json_encode($er));
$LOG = tempnam(sys_get_temp_dir(), 'mm');
$srv = proc_open(['php', '-d', 'session.save_path=/tmp', '-S', '127.0.0.1:' . $PORT, '-t', $GAME, __DIR__ . '/router.php'], [1 => ['file', $LOG, 'w'], 2 => ['file', $LOG, 'w']], $pipes);
usleep(1200000);
$jar = tempnam(sys_get_temp_dir(), 'mj');
$base = 'http://127.0.0.1:' . $PORT . '/';
$get = function (string $p, array $post = []) use ($jar, $base): string {
    $c = curl_init($base . $p);
    curl_setopt_array($c, [CURLOPT_RETURNTRANSFER => true, CURLOPT_COOKIEJAR => $jar, CURLOPT_COOKIEFILE => $jar, CURLOPT_FOLLOWLOCATION => true, CURLOPT_TIMEOUT => 20]);
    if ($post) { curl_setopt($c, CURLOPT_POST, true); curl_setopt($c, CURLOPT_POSTFIELDS, http_build_query($post)); }
    $b = (string)curl_exec($c); curl_close($c); return $b;
};
$csrf = fn(string $h) => preg_match('~name="csrf" value="([^"]*)"~', $h, $m) ? $m[1] : '';
$h = $get('login.php');
$get('login.php', ['csrf' => $csrf($h), 'username' => 'sprout', 'password' => 'TestPass123!']);
$page = $get('trek.php?t=map');
ok('the map page loads the trek', str_contains($page, 'trekmapcol'), substr(strip_tags($page), 0, 200));
ok('...and has the Whole map fold, closed, with the svg', preg_match('~<details class="tkmini"><summary>(?:🗺️|<img class="ico[^"]*"[^>]*>) Whole map</summary><svg class="tkminimap"~u', $page) === 1 && !str_contains($page, '<details class="tkmini" open'));
ok('...after the Map key position (legend then fold, or fold alone)', preg_match('~tkmini~', $page) === 1);
ok('...and nothing in it has a style= attribute', !preg_match('~<svg class="tkminimap"[^>]*style=|<details class="tkmini"[^>]*style=~', $page));
$tx(function (&$run, $uu) { $c = trek_creature('spadefoot-toad'); trek_start_fight($run, $uu, [$c], ['kind' => 'random', 'zone' => 'm'], [trek_make_foe($c, $uu, 1)]); return [true, '']; });
$fp = $get('trek.php?t=map');
ok('the fight screen loads', str_contains($fp, 'trekfightcol'));
ok('...and has no Whole map fold', !str_contains($fp, 'tkmini'));
$tx(function (&$run, $uu) { $run['fi'] = null; return [true, '']; });
proc_terminate($srv); @unlink($jar); @unlink($LOG);
echo $fails ? "== $fails FAILED\n" : "== all passed\n";
exit($fails ? 1 : 0);
