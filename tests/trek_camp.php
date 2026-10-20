<?php
// Treks v2.0.2 (code comments say 2.0.11): the camp pop-over (includes/trek_camp_ui.php). Checks: what the dialog shows at a camp tile and away from one (rest choice by state, kit shop,
// trailmate swap forms), the Talk lines, the one-shot open note (run id, 30 s, arrive vs again), that camp actions leave the note and other actions do not,
// that the old actions still behave (rest, makecamp, kit, party), escaping, and that the page, script and layout are wired.
// Run by treks.sh: php tests/trek_camp.php GAME_DIR  (clones of the test player "t211_*").
$_SERVER['SCRIPT_NAME'] = '/trek.php';
require $argv[1] . '/includes/bootstrap.php';
require_once $argv[1] . '/includes/trek.php';
if (session_status() !== PHP_SESSION_ACTIVE) session_start();
$GAME = $argv[1];
$fails = 0;
set_exception_handler(function (Throwable $e) { if (db()->inTransaction()) db()->rollBack(); echo '  EXCEPTION ' . get_class($e) . ': ' . $e->getMessage() . ' @ ' . basename($e->getFile()) . ':' . $e->getLine() . "\n"; exit(1); });
function ok(string $what, bool $cond, string $extra = ''): void { global $fails; echo ($cond ? '  ok   ' : '  FAIL ') . $what . ($cond ? '' : "  $extra") . "\n"; if (!$cond) $fails++; }
set_setting('trek_open', '1'); set_setting('trek_event_pct', '0'); set_setting('trek_enc_percent', '0'); set_setting('trek_ambush_pct', '0'); set_setting('trek_petals_daily', '5000'); set_setting('trek_entry_energy', '0');
setting('__reload__');
$n = 0;
function mkuser(string $gname): int
{
    global $n;
    $r = q_one("SELECT * FROM users WHERE username = 'sprout'");
    unset($r['id']);
    $n++;
    $r['username'] = 't211_' . $n . '_' . substr(md5((string)microtime(true)), 0, 5); $r['email'] = $r['username'] . '@b.local'; $r['gnome_name'] = $gname;
    $r['last_seen'] = now(); $r['level'] = 16; $r['coins'] = 5000; $r['energy'] = 500; $r['calling'] = null; $r['trek_ch'] = 1; $r['trek_pet_day'] = null; $r['trek_pet_today'] = 0; $r['role'] = 'player';
    return db_insert('users', $r);
}
$html = function (int $uid, string $auto = '') {
    $u = q_one('SELECT * FROM users WHERE id = ?', [$uid]);
    $run = trek_load(trek_run_row($uid));
    $party = trek_party_stats($run, $u);
    return trek_camp_dialog_html($run, $u, $party, $auto);
};

$uid = mkuser('Tess <b>Fern</b>');
$tx = fn(callable $f, bool $need = true) => trek_tx($uid, $f, $need);
$tx(fn(&$run, $u) => trek_enter($run, $u), false);
$camp = trek_spots(1)['camp'];

echo "== away from a camp: one rest choice by state, no shop, no swap\n";
$tx(function (&$run, $u) { $run['x'] = 2; $run['y'] = 2; $run['fatigue'] = 0; $run['campkits'] = 2; $run['fi'] = null; return [true, '']; });
$h = $html($uid);
ok('a rested party, away from camp: "Everyone is rested", no rest form', str_contains($h, 'Everyone is rested already') && !str_contains($h, 'value="makecamp"') && !str_contains($h, 'value="rest"'));
ok('no kit shop and no trailmate list away from a camp', !str_contains($h, 'value="buy_kit"') && !str_contains($h, 'value="party"') && !str_contains($h, 'Trailmates</b>'));
ok('title is "Make camp"', str_contains($h, '🏕️ Make camp'));
$tx(function (&$run, $u) { $run['fatigue'] = 40; return [true, '']; });
$h = $html($uid);
ok('tired with a kit: "Use a Camp Kit" posts makecamp', str_contains($h, 'Use a Camp Kit') && str_contains($h, 'value="makecamp"') && !str_contains($h, 'Cold rest'));
$tx(function (&$run, $u) { $run['campkits'] = 0; return [true, '']; });
$h = $html($uid);
ok('tired, no kit: "Cold rest" with the ambush odds', str_contains($h, 'Cold rest') && str_contains($h, 'chance of an ambush') && !str_contains($h, 'Use a Camp Kit'));
$tx(function (&$run, $u) { $run['fatigue'] = 0; $run['party'][0]['hp'] = 1; return [true, '']; });
ok('hurt but not tired also offers a rest', str_contains($html($uid), 'value="makecamp"'));

echo "== at a camp: Rest and bank, kit shop, no makecamp\n";
$tx(function (&$run, $u) use ($camp) { $run['x'] = $camp['x']; $run['y'] = $camp['y']; $run['fatigue'] = 0; $run['campkits'] = 1; $run['party'][0]['hp'] = 1; return [true, '']; });
$h = $html($uid);
ok('title is the camp name', str_contains($h, '🏕️ ' . $camp['name']));
ok('Rest and bank posts rest; makecamp is not offered on a camp tile', str_contains($h, 'Rest and bank') && str_contains($h, 'value="rest"') && !str_contains($h, 'value="makecamp"'));
ok('Buy a Camp Kit shows with the price and what you carry', str_contains($h, 'value="buy_kit"') && str_contains($h, 'you carry 1/' . (int)setting('trek_campkit_max')));
ok('every form has a CSRF field and goes back to the map tab', substr_count($h, '<form') === substr_count($h, 'name="csrf"') && substr_count($h, '<form') === substr_count($h, 'name="t" value="map"'));
$tx(function (&$run, $u) { $run['campkits'] = (int)setting('trek_campkit_max'); return [true, '']; });
ok('at the kit maximum the shop row is gone', !str_contains($html($uid), 'value="buy_kit"'));
ok('no trailmates yet: no Trailmates block', !str_contains($html($uid), 'Trailmates</b>'));

echo "== trailmates: talk lines, swap forms\n";
foreach (['burdock', 'zinnia', 'bracken'] as $crew) $tx(function (&$run, $u) use ($crew) { db_insert('trek_recruits', ['run_id' => (int)$run['id'], 'crew_key' => $crew]); return [true, '']; });
$tx(fn(&$run, $u) => trek_set_party($run, $u, [1 => 'burdock', 2 => '', 3 => '']));
$h = $html($uid);
ok('the party row for Burdock has a Talk button with JSON lines', (bool)preg_match('/data-tkcamp-talk data-who="Burdock" data-lines="([^"]+)"/', $h, $m));
$lines = json_decode(html_entity_decode($m[1] ?? '[]', ENT_QUOTES, 'UTF-8'), true);
ok('...the banter lines and his bio, as plain strings (no open tokens)', is_array($lines) && count($lines) >= 2 && !array_filter($lines, fn($l) => !is_string($l) || $l === '' || str_contains($l, '{')), json_encode($lines));
ok('a gnome name with markup in it stays escaped everywhere in the dialog (the script uses textContent)', !str_contains($h, '<b>Fern</b>') && str_contains($h, '&lt;b&gt;Fern'));
ok('the gnome has no Talk button', substr_count($h, 'data-tkcamp-talk') === 1);
ok('Zinnia and Bracken wait at camp: two "bring along" forms; the first keeps Burdock and adds Zinnia', substr_count($h, 'bring along') === 2 && (bool)preg_match('/name="p1" value="burdock"><input type="hidden" name="p2" value="zinnia"/', $h));
ok('Burdock is in the party: his "rest here" form empties all places', str_contains($h, 'Burdock: rest here') && (bool)preg_match('/name="p1" value=""><input type="hidden" name="p2" value=""><input type="hidden" name="p3" value="">/', $h));
$tx(fn(&$run, $u) => trek_set_party($run, $u, [1 => 'burdock', 2 => 'zinnia', 3 => 'bracken']));
$h = $html($uid);
ok('three trailmates in the party: nobody left to bring along, three "rest here"', substr_count($h, 'bring along') === 0 && substr_count($h, 'rest here') === 3);
$tx(function (&$run, $u) { db_insert('trek_recruits', ['run_id' => (int)$run['id'], 'crew_key' => 'sorrel']); return [true, '']; });
$h = $html($uid);
ok('a 4th recruit while full: a disabled "party full" row, no form for it', str_contains($h, 'Sorrel: waiting') && str_contains($h, 'party full') && str_contains($h, 'disabled'));
q('DELETE FROM trek_recruits WHERE run_id = (SELECT id FROM trek_runs WHERE user_id = ?) AND crew_key = ?', [$uid, 'sorrel']);

echo "== the swap forms really work through the old action\n";
$tx(fn(&$run, $u) => trek_set_party($run, $u, [1 => 'burdock', 2 => '', 3 => '']));
$h = $html($uid);
$i = strpos($h, 'Zinnia: bring along');
$fields = [];
if (preg_match_all('/name="p(\d)" value="([^"]*)"/', substr($h, max(0, $i - 500), 500), $pp, PREG_SET_ORDER)) foreach ($pp as $p) $fields[(int)$p[1]] = $p[2];
ok('the form has p1..p3', count($fields) === 3, json_encode($fields));
$tx(fn(&$run, $u) => trek_set_party($run, $u, $fields + [1 => '', 2 => '', 3 => '']));
$R = trek_load(trek_run_row($uid));
ok('the posted fields put Zinnia next to Burdock', array_values(array_map(fn($p) => $p['crew_key'], array_slice($R['party'], 1))) === ['burdock', 'zinnia'], json_encode(array_column($R['party'], 'crew_key')));

echo "== the open note: one shot, run id, 30 s, arrive vs again\n";
unset($_SESSION['trek_camp_open']);
ok('nothing noted: empty', trek_camp_open_take($R) === '');
trek_camp_open_note($R, 'again');
ok('an "again" note comes out as again, once', trek_camp_open_take($R) === 'again' && trek_camp_open_take($R) === '');
trek_camp_open_note($R, 'arrive');
ok('an "arrive" note comes out as arrive', trek_camp_open_take($R) === 'arrive');
trek_camp_open_note($R, 'again'); $_SESSION['trek_camp_open']['t'] = time() - 31;
ok('older than 30 s: dropped (and cleared)', trek_camp_open_take($R) === '' && !isset($_SESSION['trek_camp_open']));
trek_camp_open_note(['id' => 99999] + $R, 'again');
ok('another run: dropped (and cleared)', trek_camp_open_take($R) === '' && !isset($_SESSION['trek_camp_open']));
ok('the dialog carries data-auto only when asked', str_contains($html($uid, 'arrive'), 'data-auto="arrive"') && !str_contains($html($uid, ''), 'data-auto'));

echo "== the old actions still behave\n";
$tx(function (&$run, $u) { $run['x'] = 2; $run['y'] = 2; $run['fatigue'] = 60; $run['campkits'] = 2; $run['party'][0]['hp'] = 5; return [true, '']; });
$r = $tx(fn(&$run, $u) => trek_make_camp($run, $u));
$R = trek_load(trek_run_row($uid));
ok('makecamp with a kit: kit spent, fatigue 10', $r[0] === true && (int)$R['campkits'] === 1 && (int)$R['fatigue'] === 10, json_encode([$r, $R['campkits'], $R['fatigue']]));
$tx(function (&$run, $u) use ($camp) { $run['x'] = $camp['x']; $run['y'] = $camp['y']; $run['fatigue'] = 30; return [true, '']; });
$r = $tx(fn(&$run, $u) => trek_camp_rest($run, $u));
$R = trek_load(trek_run_row($uid));
ok('rest at the camp: fatigue 0', $r[0] === true && (int)$R['fatigue'] === 0, json_encode($r));
$coins = (int)q_val('SELECT coins FROM users WHERE id = ?', [$uid]);
$r = $tx(fn(&$run, $u) => trek_buy_kit($run, $u));
ok('buy_kit: the price is taken', $r[0] === true && (int)q_val('SELECT coins FROM users WHERE id = ?', [$uid]) < $coins, json_encode($r));
$tx(function (&$run, $u) { $run['x'] = 2; $run['y'] = 2; return [true, '']; });
$r = $tx(fn(&$run, $u) => trek_camp_rest($run, $u));
ok('rest away from a camp is refused', $r[0] === false);

echo "== wiring: the page, the script, the layout, the styles\n";
$src = (string)file_get_contents($GAME . '/trek.php');
ok('trek.php: Camp button opens the pop-over (no-JS form kept in <noscript>), dialog printed once, flag taken once per render',
    str_contains($src, 'data-tkcamp-open') && str_contains($src, '<noscript>') && substr_count($src, 'trek_camp_dialog_html(') === 1 && substr_count($src, 'trek_camp_open_take(') === 1);
ok('trek.php: the note is set only for rest / makecamp / buy_kit / party and a walk onto a camp', str_contains($src, "['rest', 'makecamp', 'buy_kit', 'party']") && str_contains($src, "trek_camp_open_note(\$run, 'arrive')"));
ok('assets/trekcamp.js exists and layout.php loads it on trek.php only', is_file($GAME . '/assets/trekcamp.js') && (bool)preg_match("/page === 'trek.php'\): \?><script src=\"<\?= e\(url\('assets\/trekcamp\.js/", (string)file_get_contents($GAME . '/includes/layout.php')));
ok('the script never writes HTML (textContent only)', !preg_match('/innerHTML|insertAdjacentHTML|document\.write/', (string)file_get_contents($GAME . '/assets/trekcamp.js')));
$css = (string)file_get_contents($GAME . '/assets/style.css');
ok('CSS block present with a dark rule', str_contains($css, '/* v2.0.11 trek camp pop-over */') && str_contains($css, ':root[data-theme="dark"] .tkccard'));
exit($fails ? 1 : 0);
