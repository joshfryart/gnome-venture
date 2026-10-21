<?php
// Honey Hive Harvest: logic tests. Run by honey.sh on a fresh install (temp copy, SQLite): php tests/honey.php GAME_DIR
$_SERVER['SCRIPT_NAME'] = '/index.php';
require $argv[1] . '/includes/bootstrap.php';
require_once $argv[1] . '/includes/garden_logic.php';
require_once $argv[1] . '/includes/games.php';
require_once $argv[1] . '/includes/hive.php';
$fails = 0;
function ok(string $what, bool $cond, string $extra = ''): void { global $fails; echo ($cond ? '  ok   ' : '  FAIL ') . $what . ($cond ? '' : "  $extra") . "\n"; if (!$cond) $fails++; }
function mk(string $name, array $over = []): array {
    $r = q_one("SELECT * FROM users WHERE username = 'sprout'");
    unset($r['id']);
    $r['username'] = $name; $r['email'] = $name . '@b.local'; $r['gnome_name'] = $name; $r['active_plot_id'] = null; $r['last_seen'] = now(); $r['level'] = 20; $r['coins'] = 0;
    foreach ($over as $k => $v) $r[$k] = $v;
    $id = db_insert('users', $r);
    return q_one('SELECT * FROM users WHERE id = ?', [$id]);
}
function coins(int $uid): int { return (int)q_val('SELECT coins FROM users WHERE id = ?', [$uid]); }
function fresh_state(array $frames, array $hum, array $extra = []): array {
    return $extra + ['v' => 1, 'frames' => $frames, 'hum' => $hum, 'lifted' => [], 'peeked' => [], 'puffs' => 1, 'mode' => 'lift', 'basket' => 0, 'combs' => 0, 'season' => 'spring',
        'swarms' => count(array_keys($frames, 'swarm', true)), 't0' => time()];
}
$F = ['swarm', 'clear', 'golden', 'amber', 'heather', 'drowsy', 'swarm', 'clear'];   // fixed layout
$H = [3, 1, 2, 3, 3, 1, 3, 2];

echo "== layouts (500 rolls per season)\n";
$bad = [];
foreach (['spring', 'summer', 'autumn', 'winter'] as $season) foreach ([false, true] as $hardy) for ($n = 0; $n < 125; $n++) {
    [$f, $h] = hive_layout($season, $hardy);
    $sw = count(array_keys($f, 'swarm', true));
    if (count($f) !== 8 || count($h) !== 8) $bad[] = "$season size";
    if ($sw !== ($hardy ? 1 : 2)) $bad[] = "$season swarms=$sw hardy=" . (int)$hardy;
    foreach ($f as $i => $k) {
        if ($k === 'swarm' && $h[$i] !== 3) $bad[] = 'swarm not loud';
        if ($h[$i] < 3 && $k === 'swarm') $bad[] = 'quiet swarm';
        if ($k === 'heather' && $h[$i] !== 3) $bad[] = 'heather not loud';
        if ($k === 'golden' && $h[$i] !== 2) $bad[] = 'golden hum';
        if ($k === 'drowsy' && $h[$i] !== 1) $bad[] = 'drowsy hum';
    }
    $max = array_sum(array_map(fn($k) => HIVE_VALUE[$k], $f));
    $want = ['spring' => 74, 'autumn' => 74, 'summer' => 86, 'winter' => 56][$season];
    if ($max !== $want) $bad[] = "$season max $max";
}
ok('8 frames, swarm count, hum invariants, season mixes', !$bad, implode(',', array_slice(array_unique($bad), 0, 5)));

echo "== start, view, meter\n";
$a = mk('honeya');
$uid = (int)$a['id'];
[$o, $m] = hive_start($a);
ok('start ok', $o, $m);
$s = game_state($uid, 'hive');
ok('state has 8 frames and 1 puff', count($s['frames']) === 8 && $s['puffs'] === 1);
ok('a live round counts as a play', game_plays_left($uid, 'hive') === 2);
$view = hive_view($s);
ok('view has no kind for closed frames', count(array_filter(array_column($view['cells'], 'kind'))) === 0);
ok('view json has no frames key', strpos(json_encode($view), 'frames') === false);
game_save($uid, 'hive', fresh_state($F, $H));
$s = game_state($uid, 'hive');
ok('meter = 4 loud, 2 swarms', hive_meter($s) === [4, 2]);
[$o, $m] = hive_smoke($a, 4);
$s = game_state($uid, 'hive');
ok('smoke peeks heather and uses the puff', $o && $s['puffs'] === 0 && $s['peeked'] === [4], $m);
ok('meter drops the peeked frame', hive_meter($s) === [3, 2]);
[$o] = hive_smoke($a, 3); ok('no smoke left refused', !$o);
[$o] = hive_lift($a, 99); ok('lift out of range refused', !$o);
[$o] = hive_lift($a, -1); ok('lift negative refused', !$o);
[$o] = hive_lift($a, 1); ok('lift clear ok', $o);
[$o] = hive_lift($a, 1); ok('re-lift refused', !$o);
$s = game_state($uid, 'hive');
ok('basket unchanged after re-lift = 6', $s['basket'] === 6 && $s['combs'] === 1);
ok('meter after lifts', hive_meter($s) === [3, 2]);
[$o] = hive_smoke($a, 1); ok('smoke on lifted refused', !$o);
$s['puffs'] = 2; game_save($uid, 'hive', $s);
[$o] = hive_smoke($a, 4); ok('smoke on peeked refused', !$o);
[$o] = hive_smoke($a, 0);
[$o, $m] = hive_lift($a, 0); ok('lift peeked swarm refused', !$o);
ok('state kept after refused swarm lift', (bool)game_state($uid, 'hive'));

echo "== bank pays once\n";
$c0 = coins($uid);
[$o] = hive_lift($a, 3);   // amber +20 => 26
[$o, $m] = hive_bank($a);
$s26 = 26;
ok('bank ok', $o, $m);
ok('paid game_petals(26)', coins($uid) - $c0 === game_petals($s26), (string)(coins($uid) - $c0));
ok('state gone', !game_state($uid, 'hive'));
[$o, $m] = hive_bank($a);
ok('second bank refused', !$o && coins($uid) - $c0 === game_petals($s26), $m);
ok('score row = basket', (int)q_val("SELECT score FROM game_scores WHERE user_id = ? AND game = 'hive' ORDER BY id DESC LIMIT 1", [$uid]) === 26);
[$o] = hive_bank($a); ok('bank with no round refused', !$o);

echo "== bank needs a lift\n";
game_save($uid, 'hive', fresh_state($F, $H));
[$o, $m] = hive_bank($a);
ok('bank before first lift refused', !$o && (bool)game_state($uid, 'hive'), $m);

echo "== swarm ends the round\n";
$c0 = coins($uid);
[$o] = hive_lift($a, 2);   // golden +12
[$o] = hive_lift($a, 6);   // swarm
ok('swarm lift ok', $o);
ok('swarm pays only the flat consolation', coins($uid) - $c0 === game_petals(4), (string)(coins($uid) - $c0));
ok('swarm score 0', (int)q_val("SELECT score FROM game_scores WHERE user_id = ? AND game = 'hive' ORDER BY id DESC LIMIT 1", [$uid]) === 0);
ok('state gone after swarm', !game_state($uid, 'hive'));
ok('plays now: 2 used, 1 left', game_plays_left($uid, 'hive') === 1);
game_score($uid, 'hive', 0);   // a third round
ok('plays now: none left', game_plays_left($uid, 'hive') === 0);
[$o, $m] = hive_start($a);
ok('start refused with no plays', !$o && !game_state($uid, 'hive'), $m);

echo "== auto-bank when every safe frame is lifted\n";
$b = mk('honeyb'); $bid = (int)$b['id'];
$c0 = coins($bid);
game_save($bid, 'hive', fresh_state($F, $H));
foreach ([1, 2, 3, 4, 5] as $i) $r = hive_lift($b, $i);
ok('still running before last safe frame', (bool)game_state($bid, 'hive'));
[$o] = hive_lift($b, 7);
ok('last safe frame banks 6+12+20+30+0+6 = 74', !game_state($bid, 'hive') && coins($bid) - $c0 === game_petals(74), (string)(coins($bid) - $c0));
$hid = (int)q_val("SELECT id FROM items WHERE slug = 'garden-honey'");
$wid = (int)q_val("SELECT id FROM items WHERE slug = 'beeswax'");
$qty = fn(int $u, int $i) => (int)q_val('SELECT qty FROM user_items WHERE user_id = ? AND item_id = ?', [$u, $i]);
ok('honey gift: 1 honey + 1 beeswax (heather)', $qty($bid, $hid) === 1 && $qty($bid, $wid) === 1, $qty($bid, $hid) . '/' . $qty($bid, $wid));
game_save($bid, 'hive', fresh_state($F, $H));
foreach ([1, 2, 3, 4] as $i) hive_lift($b, $i);
hive_bank($b);
ok('second qualifying bank the same day gives no item', $qty($bid, $hid) === 1 && $qty($bid, $wid) === 1);

echo "== few combs: no honey\n";
$d = mk('honeyd'); $did = (int)$d['id'];
game_save($did, 'hive', fresh_state($F, $H));
hive_lift($d, 1); hive_lift($d, 2); hive_bank($d);
ok('2 combs give no honey', $qty($did, $hid) === 0);

echo "== stats read at start\n";
$e = mk('honeye', ['stat_sense' => 14, 'stat_hardiness' => 16]);
hive_start($e);
$s = game_state((int)$e['id'], 'hive');
ok('Sense mod 2 gives 2 puffs', $s['puffs'] === 2);
ok('Hardiness mod 3 leaves 1 swarm', $s['swarms'] === 1 && count(array_keys($s['frames'], 'swarm', true)) === 1);
$g = mk('honeyg', ['stat_sense' => 10, 'stat_hardiness' => 10]);
hive_start($g);
$s = game_state((int)$g['id'], 'hive');
ok('plain gnome: 1 puff and 2 swarms', $s['puffs'] === 1 && $s['swarms'] === 2);

echo "== mode, gifts cap, almanac\n";
[$o] = hive_mode($g, 'smoke'); ok('mode to smoke', $o && game_state((int)$g['id'], 'hive')['mode'] === 'smoke');
[$o] = hive_mode($g, 'x'); ok('bad mode refused', !$o);
ok('GAMES row', isset(GAMES['hive']) && GAMES['hive'][2] === 'hive.php' && GAMES['hive'][4] === 'hive_plays_per_day');
ok('settings defaults', setting('hive_plays_per_day') === '3' && setting('hive_gifts_per_day') === '1');
$body = (string)q_val("SELECT body FROM encyclopedia_entries WHERE title = 'Games' AND chapter = 'General'");
ok('fresh install: almanac has the line', substr_count($body, 'Honey Hive Harvest') === 1);
$old = preg_replace('/\n🍯 \[b\]Honey Hive Harvest:[^\n]*/u', '', GAMES_PAGE);   // an upgrade: the page as it was before
q("UPDATE encyclopedia_entries SET body = ? WHERE title = 'Games' AND chapter = 'General'", [$old]);
hive_almanac(); hive_almanac();
$body = (string)q_val("SELECT body FROM encyclopedia_entries WHERE title = 'Games' AND chapter = 'General'");
ok('upgrade: almanac line added once, same text as a fresh install', $body === GAMES_PAGE, $body);

echo $fails ? "\n$fails FAILED\n" : "\nall ok\n";
exit($fails ? 1 : 0);
