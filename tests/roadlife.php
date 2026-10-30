<?php
// v1.9.3 "road life": anti-repeat ring, hard/soft cond tags, ambient lines, data-file lint, the upgrade step.
// Run on an installed copy (after walk.sh):  php tests/roadlife.php GAME_DIR     (roadlife.sh does the install + this)
$_SERVER['SCRIPT_NAME'] = '/gnome.php';
require $argv[1] . '/includes/bootstrap.php';
require_once $argv[1] . '/includes/adventure.php';
require_once $argv[1] . '/includes/friends.php';
require_once $argv[1] . '/includes/stop_folk.php';
$J = fn(array $x): string => implode(' ', json_decode($x['log'], true) ?: []);   // the journal as text (the stored JSON escapes emoji)
if (session_status() !== PHP_SESSION_ACTIVE) session_start();
$fails = 0;
function ok(string $what, bool $cond, string $extra = ''): void { global $fails; echo ($cond ? '  ok   ' : '  FAIL ') . $what . ($cond ? '' : "  $extra") . "\n"; if (!$cond) $fails++; }
$uid = (int)q_val("SELECT id FROM users WHERE username = 'sprout'");
$set = function (string $k, string $v) { q('UPDATE settings SET value = ? WHERE name = ?', [$v, $k]); if (!q_val('SELECT 1 FROM settings WHERE name = ?', [$k])) q('INSERT INTO settings (name, value) VALUES (?, ?)', [$k, $v]); setting('__reload__'); };
$bindFresh = function () use ($uid) { q('UPDATE users SET road_recent = NULL WHERE id = ?', [$uid]); road_bind(q_one('SELECT * FROM users WHERE id = ?', [$uid])); };

echo "== schema\n";
ok('users.road_recent exists', is_array(q_one('SELECT road_recent FROM users WHERE id = ?', [$uid])));
foreach (['problems', 'creatures', 'gatherables'] as $t) ok("$t.cond exists", is_array(q_one("SELECT cond FROM $t LIMIT 1")));
ok('upgrade flag upg193_road_cond set', setting('upg193_road_cond') === '1');

echo "== ring: no repeat inside 3 picks\n";
foreach ([6, 4] as $n) {
    $rows = []; for ($i = 0; $i < $n; $i++) $rows[] = ['slug' => "row$i"];
    $bindFresh(); $seq = []; $bad = 0;
    for ($i = 0; $i < 400; $i++) { $seq[] = road_pick($rows, 'zz', 'slug')['slug']; for ($b = 1; $b <= 3; $b++) if ($i - $b >= 0 && $seq[$i - $b] === $seq[$i]) $bad++; }
    ok("pool of $n: 400 picks, repeats within 3 = $bad", $bad === 0);
    ok("pool of $n: every row still turns up", count(array_unique($seq)) === $n);
}
$bindFresh(); $two = [['slug' => 'a'], ['slug' => 'b']]; $s = []; for ($i = 0; $i < 20; $i++) $s[] = road_pick($two, 'zz', 'slug')['slug'];
ok('pool of 2 alternates', count(array_filter(array_keys($s), fn($i) => $i > 0 && $s[$i] === $s[$i - 1])) === 0);
$bindFresh(); ok('pool of 1 still answers', road_pick([['slug' => 'only']], 'zz', 'slug')['slug'] === 'only' && road_pick([['slug' => 'only']], 'zz', 'slug')['slug'] === 'only');
ok('empty pool = null', road_pick([], 'zz', 'slug') === null);

echo "== ring: stored tiny, survives a reload, only written by road_flush\n";
$bindFresh(); $rows = []; for ($i = 0; $i < 9; $i++) $rows[] = ['slug' => "row$i"];
foreach (['cr', 'pr', 'fd', 'oc', 'os', 'am'] as $k) for ($i = 0; $i < 12; $i++) road_pick($rows, $k, 'slug');
ok('nothing written before flush', q_val('SELECT road_recent FROM users WHERE id = ?', [$uid]) === null);
road_flush();
$raw = (string)q_val('SELECT road_recent FROM users WHERE id = ?', [$uid]);
ok('stored JSON under 300 bytes (' . strlen($raw) . ')', $raw !== '' && strlen($raw) < 300);
$ring = road_state()['ring'];
road_bind(q_one('SELECT * FROM users WHERE id = ?', [$uid]));
ok('reload gives the same ring', road_state()['ring'] === $ring && count($ring['cr']) === 8);
road_unbind(); $before = $raw; road_pick($rows, 'cr', 'slug'); road_flush();
ok('unbound picks write nothing', (string)q_val('SELECT road_recent FROM users WHERE id = ?', [$uid]) === $before);
$bindFresh();

echo "== hard cond: nightfall only at dusk/night, fog only in fog, heat haze only on a sunny day\n";
$count = function (string $land, int $n) { $c = []; for ($i = 0; $i < $n; $i++) { $p = pick_problem($land); $c[$p['slug']] = ($c[$p['slug']] ?? 0) + 1; } return $c; };
$set('stop_daypart_force', 'day'); $set('weather_force', 'cloud'); road_unbind();
$c = $count('desert', 500);
ok('day + cloud: no nightfall, fog, heat haze', empty($c['nightfall']) && empty($c['thick-fog']) && empty($c['heat-haze']), json_encode($c));
ok('day + cloud: other problems still come', count($c) >= 5);
$set('stop_daypart_force', 'night'); road_unbind(); $c = $count('desert', 600);
ok('night: nightfall turns up', !empty($c['nightfall']));
ok('night: no heat haze', empty($c['heat-haze']));
$set('stop_daypart_force', 'day'); $set('weather_force', 'sun'); road_unbind(); $c = $count('desert', 600);
ok('sunny day: heat haze turns up, nightfall does not', !empty($c['heat-haze']) && empty($c['nightfall']));
$set('weather_force', 'fog'); road_unbind(); $c = $count('coast', 600);
ok('fog: thick fog turns up', !empty($c['thick-fog']));
$set('weather_force', 'frost'); road_unbind(); $c = $count('tundra', 600);
ok('frost: frozen puddle turns up; no storm shelter, no snow drift', !empty($c['frozen-puddle']) && empty($c['storm-shelter']) && empty($c['snow-drift']), json_encode($c));
$set('weather_force', 'storm'); road_unbind(); $c = $count('forest', 600);
ok('storm: storm shelter and windy hat turn up', !empty($c['storm-shelter']) && !empty($c['windy-hat']));
$set('stop_daypart_force', 'day'); $set('weather_force', 'cloud'); road_unbind();
foreach (array_keys(LANDSCAPES) as $land) ok("a problem exists for $land", pick_problem($land) !== null);

echo "== soft cond: x3 when it matches, never excluded\n";
$rows = [['slug' => 'wet', 'cond' => 'we=rain'], ['slug' => 'p1'], ['slug' => 'p2'], ['slug' => 'p3']];
$share = function (array $now) use ($rows) { $n = 0; for ($i = 0; $i < 4000; $i++) if (road_pick($rows, 'zz', 'slug', ['now' => $now])['slug'] === 'wet') $n++; return $n / 4000; };
road_unbind();
$on = $share(['dp' => 'day', 'se' => 'summer', 'we' => 'rain']); $off = $share(['dp' => 'day', 'se' => 'summer', 'we' => 'sun']);
ok('matching: ~50% (got ' . round($on * 100) . '%)', $on > 0.44 && $on < 0.56);
ok('not matching: ~25% and not excluded (got ' . round($off * 100) . '%)', $off > 0.2 && $off < 0.3);
$rows = [['slug' => 'must', 'cond' => '!dp=night'], ['slug' => 'p1']];
$n = 0; for ($i = 0; $i < 200; $i++) if (road_pick($rows, 'zz', 'slug', ['now' => ['dp' => 'day', 'se' => 'summer', 'we' => 'sun']])['slug'] === 'must') $n++;
ok('hard cond that fails is never picked', $n === 0);
ok('all rows hard-failing = null', road_pick([['slug' => 'x', 'cond' => '!dp=night']], 'zz', 'slug', ['now' => ['dp' => 'day', 'se' => 'summer', 'we' => 'sun']]) === null);

echo "== creatures and gatherables carry tags\n";
$tagged = fn(string $t) => (int)q_val("SELECT COUNT(*) FROM $t WHERE cond IS NOT NULL AND cond <> ''");
ok('creatures tagged (' . $tagged('creatures') . ')', $tagged('creatures') >= 20);
ok('gatherables tagged (' . $tagged('gatherables') . ')', $tagged('gatherables') >= 15);
ok('problems tagged (' . $tagged('problems') . ')', $tagged('problems') >= 14);
$news = ['frozen-puddle', 'mud-after-rain', 'falling-leaves', 'snow-drift', 'storm-shelter', 'dew-web', 'windy-hat', 'heat-shimmer'];
ok('8 new weather/season problems in the world', (int)q_val("SELECT COUNT(*) FROM problems WHERE slug IN ('" . implode("','", $news) . "')") === 8);
ok('they have 3 approaches each', (int)q_val("SELECT COUNT(*) FROM problems WHERE slug IN ('" . implode("','", $news) . "') AND options LIKE '%\"stat\"%'") === 8);
$set('weather_force', 'rain'); $set('stop_daypart_force', 'day'); road_unbind();
$sn = 0; $base = 0; $forestPool = array_values(array_filter(road_rows('creatures'), fn($c) => $c['size'] !== 'boss' && (int)$c['level'] <= 3 && in_array('forest', explode(',', $c['landscapes']), true) || ($c['landscapes'] === 'any' && (int)$c['level'] <= 3)));
for ($i = 0; $i < 2000; $i++) if (pick_creature('forest', 3, false)['slug'] === 'garden-snail') $sn++;
$set('weather_force', 'sun'); road_unbind();
for ($i = 0; $i < 2000; $i++) if (pick_creature('forest', 3, false)['slug'] === 'garden-snail') $base++;
ok("snails likelier in rain ($sn vs $base in 2000)", $sn > $base * 1.5);
$set('weather_force', ''); $set('stop_daypart_force', '');

echo "== a backfill keeps what an admin typed\n";
q("UPDATE creatures SET cond = 'we=fog' WHERE slug = 'tawny-owl'"); q("UPDATE creatures SET cond = NULL WHERE slug = 'barn-rat'");
$n = road_cond_backfill();
ok('owl keeps the admin tag', q_val("SELECT cond FROM creatures WHERE slug = 'tawny-owl'") === 'we=fog');
ok('rat got its tag back', q_val("SELECT cond FROM creatures WHERE slug = 'barn-rat'") === 'dp=night' && $n === 1, (string)$n);
ok('a second run changes nothing', road_cond_backfill() === 0);
q("UPDATE creatures SET cond = 'dp=night,dusk' WHERE slug = 'tawny-owl'");

echo "== ambient lines\n";
$loc = q_one("SELECT * FROM locations WHERE kind = 'village' ORDER BY id LIMIT 1");
$scene = ['land' => 'forest', 'to' => $loc, 'from' => $loc];
$set('stop_daypart_force', 'night'); $set('weather_force', 'rain'); road_unbind();
$seen = []; for ($i = 0; $i < 300; $i++) $seen[road_line($scene)] = 1;
$lines = road_lines();
$okNight = true; foreach ($lines as $r) if (isset($seen[$r['text']]) && trim($r['cond']) !== '-' && !stop_cond_ok($r['cond'], road_now())) $okNight = false;
ok('night + rain: only lines whose cond holds (' . count($seen) . ' different)', $okNight && count($seen) >= 3);
ok('night + rain: dawn line never', !isset($seen['Dew beads on every blade, and the first birds are testing their voices.']));
$a = road_line($scene, ['seed' => 'x|1', 'record' => false]); $b = road_line($scene, ['seed' => 'x|1', 'record' => false]);
ok('a seed gives the same line twice', $a === $b && $a !== null);
$bindFresh(); $seq = []; $bad = 0; for ($i = 0; $i < 60; $i++) { $seq[] = road_line($scene); for ($k = 1; $k <= 3; $k++) if ($i >= $k && $seq[$i - $k] === $seq[$i]) $bad++; }
ok("lines: no repeat within 3 (repeats $bad)", $bad === 0);
$set('stop_daypart_force', ''); $set('weather_force', ''); road_unbind();

echo "== arrival line is the stop type's own ambience\n";
$set('stop_daypart_force', 'dusk'); road_unbind();
$al = road_arrival_line($loc);
ok('a village gives its dusk line (' . mb_substr($al, 0, 50) . ')', $al !== '' && str_starts_with($al, '🌇'));
ok('a hub gives none', road_arrival_line(['kind' => 'hub']) === '');
$set('stop_daypart_force', '');

echo "== data lint: road_lines.txt\n";
$codes = array_map(fn($r) => $r[0], catalog_lines('regions.txt'));
$validK = ['dp' => ['dawn', 'day', 'dusk', 'night'], 'se' => ['spring', 'summer', 'autumn', 'winter'], 'we' => ['sun', 'cloud', 'rain', 'storm', 'frost', 'heat', 'wind', 'fog', 'snow']];
$lintCond = function (string $cond) use ($validK): string {
    if ($cond === '-' || $cond === '') return '';
    $c = $cond[0] === '!' ? substr($cond, 1) : $cond;
    foreach (explode('/', $c) as $part) {
        [$k, $v] = array_pad(explode('=', $part, 2), 2, '');
        if (!isset($validK[$k])) return "unknown key '$k' in '$cond'";
        foreach (explode(',', $v) as $x) if (!in_array($x, $validK[$k], true)) return "bad value '$x' in '$cond'";
    }
    return '';
};
$n = 0; $errs = [];
foreach (file($argv[1] . '/includes/data/road_lines.txt', FILE_IGNORE_NEW_LINES) as $i => $line) {
    $line = trim($line); if ($line === '' || $line[0] === '#') continue; $n++;
    $f = explode('|', $line);
    if (count($f) !== 4) { $errs[] = "line " . ($i + 1) . ": " . count($f) . " fields"; continue; }
    if (($e = $lintCond(trim($f[0])))) $errs[] = "line " . ($i + 1) . ": $e";
    foreach (array_filter(array_map('trim', explode(',', $f[1]))) as $l) if ($l !== 'any' && !isset(LANDSCAPES[$l])) $errs[] = "line " . ($i + 1) . ": land '$l'";
    foreach (array_filter(array_map('trim', explode(',', $f[2]))) as $r) if ($r !== 'any' && !in_array($r, $codes, true)) $errs[] = "line " . ($i + 1) . ": region '$r'";
    if (trim($f[3]) === '' || mb_strlen(trim($f[3])) > 140) $errs[] = "line " . ($i + 1) . ": text length " . mb_strlen(trim($f[3]));
}
ok("road_lines.txt: $n lines, 4 fields, valid cond/lands/region, text 1-140 chars" . ($errs ? ' [' . implode('; ', array_slice($errs, 0, 5)) . ']' : ''), !$errs && $n >= 12);
ok('the loader reads all of them', count($lines) === $n, count($lines) . " vs $n");

echo "== data lint: cond columns\n";
$errs = [];
foreach (['problems.txt' => [0, 4], 'creatures.txt' => [0, 7], 'gatherables.txt' => [0, 8]] as $file => [$si, $ci]) {
    foreach (catalog_lines($file) as $f) if (isset($f[$ci]) && ($e = $lintCond($f[$ci]))) $errs[] = "$file {$f[$si]}: $e";
}
ok('every cond in problems/creatures/gatherables parses' . ($errs ? ' [' . implode('; ', $errs) . ']' : ''), !$errs);


// ======================================================================= v1.9.4: choice cards, meetings, wonders, blurbs
echo "== v1.9.4 data: road_events.txt\n";
$ev = road_events(true);
$E = $ev['ev']; $SI = $ev['sights'];
$generic = array_filter($E, fn($e) => $e['region'] === ['any']);
ok('events load: ' . count($E) . ' scenes (' . count($generic) . ' generic)', count($generic) >= 30);
ok('region pack NWE has 8 old scenes + 25 of the v2.0.80 kinds', count(array_filter($E, fn($e) => $e['region'] === ['NWE'])) === 33);
foreach (['MENA' => 31, 'EA' => 33, 'CB' => 31, 'SA' => 31, 'SE' => 31, 'EE' => 31, 'WCA' => 31, 'ESA' => 31, 'CSA' => 31, 'SEA' => 31, 'OC' => 31] as $rc => $n) ok("region pack $rc has its old scenes + 25 of the v2.0.80 kinds", count(array_filter($E, fn($e) => $e['region'] === [$rc])) === $n, (string)count(array_filter($E, fn($e) => $e['region'] === [$rc])));
foreach (['NA', 'CA'] as $rc) ok("region pack $rc has 8 old scenes + 24 of the v2.0.79 kinds", count(array_filter($E, fn($e) => $e['region'] === [$rc])) === ($rc === 'NA' ? 32 : 30), (string)count(array_filter($E, fn($e) => $e['region'] === [$rc])));
ok('12 sights, all wild-only', count($SI) === 12 && count(array_filter($SI, fn($x) => $x['where'] === 'wild')) === 12);
ok('first 14 keep the old numbers (bee-log first, carved-boulder 14th)', array_keys($E)[0] === 'bee-log' && array_keys($E)[13] === 'carved-boulder');
$errs = [];
$statOk = array_keys(GNOME_STATS);
$fxKinds = ['xp', 'coins', 'item', 'rand', 'energy', 'buff', 'heal', 'hp', 'pay', 'landmark', 'tip', 'take', 'next', 'skip', 'journal'];   // v2.0.79: take next skip journal
$randOk = ['forage', 'uncommon', 'food', 'soil', 'seed', 'flowerseed', 'treeseed'];
$newRandOk = ['forage', 'uncommon', 'food'];
$lintFx = function (string $fx, bool $legacy, string $where) use ($fxKinds, $randOk, $newRandOk): array {
    $e = [];
    if ($fx === '') return $e;
    $hasPay = false; foreach (explode('+', $fx) as $p) if (str_starts_with($p, 'pay:') || str_starts_with($p, 'take:')) $hasPay = true;   // v2.0.79: handing over goods is a trade too
    foreach (explode('+', $fx) as $part) {
        $chance = null;
        if (preg_match('/^(.*)@(\d{1,3})$/', $part, $m)) { $part = $m[1]; $chance = (int)$m[2]; }
        $p = explode(':', $part);
        if (!in_array($p[0], $fxKinds, true)) { $e[] = "unknown effect '{$p[0]}'"; continue; }
        if ($p[0] === 'item' && (!isset($p[1]) || !q_val('SELECT 1 FROM items WHERE slug = ?', [$p[1]]))) $e[] = "no such item '" . ($p[1] ?? '') . "'";
        if ($p[0] === 'rand' && !in_array($p[1] ?? '', $legacy ? $randOk : $newRandOk, true)) $e[] = "rand kind '" . ($p[1] ?? '') . "'";
        if ($p[0] === 'buff' && !isset(GNOME_STATS[$p[1] ?? ''])) $e[] = "buff stat";
        if (in_array($p[0], ['item', 'rand'], true) && !$legacy && !$hasPay && ($chance === null || $chance > 20)) $e[] = "item/find without @<=20 ($part)";
        if ($p[0] === 'landmark' && $where !== 'wild') $e[] = 'landmark outside the wilds';
        if ($p[0] === 'rand' && ($p[1] ?? '') === 'rare') $e[] = 'rare find';
    }
    return $e;
};
$n = 0;
foreach ($E as $id => $e) {
    $legacy = $e['n'] < ROAD_LEGACY_EVENTS; $n++;
    if (($m = $lintCond($e['cond']))) $errs[] = "$id: $m";
    if (!preg_match('/^[a-z0-9-]+$/', $id)) $errs[] = "$id: id";
    if (mb_strlen($e['text']) > 300 || mb_strlen($e['text']) < 20) $errs[] = "$id: scene length " . mb_strlen($e['text']);
    foreach ($e['lands'] as $l) if ($l !== 'any' && !isset(LANDSCAPES[$l])) $errs[] = "$id: land $l";
    foreach ($e['region'] as $r) if ($r !== 'any' && !in_array($r, $codes, true)) $errs[] = "$id: region $r";
    if (count($e['opts']) < (($e['kind'] ?? '') === 'sketch' ? 1 : 2) || count($e['opts']) > 3) $errs[] = "$id: " . count($e['opts']) . ' options';   // v2.0.79: a sketch has one
    foreach ($e['opts'] as $o) {
        if ($o['stat'] !== '' && $o['stat'] !== '!' && !in_array($o['stat'], $statOk, true)) $errs[] = "$id: stat {$o['stat']}";
        if ($o['stat'] !== '' && $o['stat'] !== '!' && ($o['dc'] < 9 || $o['dc'] > 14)) $errs[] = "$id: dc {$o['dc']}";
        if ($o['stat'] === '' && $o['win'] === '' && $o['wintext'] === '' && ($e['kind'] ?? '') !== 'trade') $errs[] = "$id: empty option";
        if (($o['wintext'] === '' && $o['stat'] !== '!') || mb_strlen($o['wintext']) > 150 || mb_strlen($o['losetext']) > 150 || mb_strlen($o['label']) > 45) $errs[] = "$id: text length ({$o['label']})";
        if ($o['stat'] !== '' && $o['losetext'] === '') $errs[] = "$id: no lose text";
        foreach ($lintFx($o['win'], $legacy, $e['where']) as $m) $errs[] = "$id win: $m";
        foreach ($lintFx($o['lose'], $legacy, $e['where']) as $m) $errs[] = "$id lose: $m";
        if (str_contains($o['wintext'] . $o['losetext'] . $o['label'], '\'')) $errs[] = "$id: straight apostrophe";
    }
    if (str_contains($e['text'], '\'')) $errs[] = "$id: straight apostrophe in scene";
}
foreach ($SI as $id => $x) { if (($m = $lintCond($x['cond']))) $errs[] = "sight $id: $m"; foreach ($lintFx($x['fx'], true, 'wild') as $m) $errs[] = "sight $id: $m"; }
ok("events + sights lint ($n scenes)" . ($errs ? ' [' . implode('; ', array_slice($errs, 0, 6)) . ']' : ''), !$errs);
$raw = file(__DIR__ . '/../game/includes/data/road_events.txt', FILE_IGNORE_NEW_LINES) ?: file($argv[1] . '/includes/data/road_events.txt', FILE_IGNORE_NEW_LINES);
$bad = 0; $rows = 0; foreach (file($argv[1] . '/includes/data/road_events.txt', FILE_IGNORE_NEW_LINES) as $l) { $l = trim($l); if ($l === '' || $l[0] === '#') continue; $rows++; $c = count(explode('|', $l)); if (($l[0] === 'O' && $c !== 8) || ($l[0] === 'E' && !in_array($c, [8, 10], true)) || $l[0] === 'S' && $c !== 9 || !in_array($l[0], ['E', 'O', 'S'], true)) $bad++; }
ok("every row of road_events.txt has the right number of columns ($rows rows)", $bad === 0, "$bad bad");

echo "== choice cards: fit, region packs, anti-repeat\n";
$mk = function (string $kind = 'walk') {
    $r = q_one("SELECT * FROM routes WHERE kind = 'road' ORDER BY id LIMIT 1");
    return ['id' => 0, 'kind' => $kind, 'from_id' => (int)$r['a_id'], 'to_id' => (int)$r['b_id'], 'route_id' => (int)$r['id'], 'level' => 4, 'scaled' => 0, 'step' => 0, 'steps_total' => 3,
        'depth' => $kind === 'explore' ? 2 : 0, 'hp' => 30, 'max_hp' => 30, 'encounter' => null, 'log' => '[]', 'status' => 'active'];
};
$exp = $mk(); $sc = exp_scene($exp);
ok('sanity: the first road starts in the Maplewold', stop_region_code($sc['to']) === 'NA', stop_region_code($sc['to']));
$set('stop_daypart_force', 'day'); $set('weather_force', 'cloud'); road_unbind();
$seen = []; for ($i = 0; $i < 600; $i++) { $e = road_event_pick($sc, 'road'); $seen[$e['id']] = ($seen[$e['id']] ?? 0) + 1; }
ok('NA road: its own pack turns up (' . count(array_filter($seen, null, ARRAY_FILTER_USE_KEY)) . ' scenes seen)', count(array_filter(array_keys($seen), fn($k) => str_starts_with($k, 'na-'))) >= 5);
ok('NA road: no NWE/EA scenes, no wild-only scenes', !array_filter(array_keys($seen), fn($k) => str_starts_with($k, 'nwe-') || str_starts_with($k, 'ea-')) && empty($seen['lost-hedgehog']) && empty($seen['round-door']));
ok('NA road in cloud+day: no downpour, no lamp-moths (hard conds)', empty($seen['downpour']) && empty($seen['lamp-moths']));
ok('NA road: generic scenes still turn up', count(array_filter(array_keys($seen), fn($k) => !preg_match('/^(na|nwe|ea)-/', $k))) >= 8);
$set('weather_force', 'rain'); road_unbind(); $seen = []; for ($i = 0; $i < 400; $i++) { $e = road_event_pick($sc, 'wild'); $seen[$e['id']] = 1; }
ok('rain: the downpour turns up in the wilds, and wild-only scenes do too', isset($seen['downpour']) && isset($seen['lost-hedgehog']));
$set('stop_daypart_force', 'night'); $set('weather_force', 'cloud'); road_unbind(); $seen = []; for ($i = 0; $i < 400; $i++) { $e = road_event_pick($sc, 'road'); $seen[$e['id']] = 1; }
ok('night: lamp-moths turn up', isset($seen['lamp-moths']));
$set('stop_daypart_force', 'day'); road_unbind();
// another region
$nwe = q_one("SELECT l.* FROM locations l JOIN regions r ON r.id = l.region_id WHERE r.code = 'NWE' AND l.kind = 'village' ORDER BY l.id LIMIT 1");
$scN = ['land' => 'forest', 'to' => $nwe, 'from' => $nwe]; $seen = []; for ($i = 0; $i < 400; $i++) { $e = road_event_pick($scN, 'road'); $seen[$e['id']] = 1; }
ok('Mistmoor road: nwe- scenes, no na- scenes', count(array_filter(array_keys($seen), fn($k) => str_starts_with($k, 'nwe-'))) >= 4 && !array_filter(array_keys($seen), fn($k) => str_starts_with($k, 'na-')));
$bindFresh(); $seq = []; $bad = 0; for ($i = 0; $i < 200; $i++) { $seq[] = road_event_pick($sc, 'road')['id']; for ($k = 1; $k <= 3; $k++) if ($i >= $k && $seq[$i - $k] === $seq[$i]) $bad++; }
ok("choice cards: no repeat within 3 (repeats $bad)", $bad === 0);

echo "== choice cards resolve (every option of every scene; road and wilds)\n";
$bindFresh();
$gu = q_one('SELECT * FROM users WHERE id = ?', [$uid]);
$bad = []; $logs = 0;
foreach (['walk', 'explore'] as $kind) foreach ($E as $id => $e) foreach (array_keys($e['opts']) as $oi) for ($rep = 0; $rep < 6; $rep++) {
    $x = $mk($kind); $x['encounter'] = json_encode(['type' => 'choice', 'ev' => $id]);
    try { explore_choose($gu, $x, $oi); } catch (Throwable $t) { $bad[] = "$kind $id/$oi: " . $t->getMessage(); break; }
    $lg = json_decode($x['log'], true);
    if ($x['encounter'] !== null || count($lg) !== 1 || !preg_match('/^(✅|❌|👉|👛|🎒)/u', $lg[0])) { $bad[] = "$kind $id/$oi: " . json_encode($lg); break; }
    $logs++;
}
ok("$logs resolutions, encounter cleared, one journal line each" . ($bad ? ' [' . implode('; ', array_slice($bad, 0, 3)) . ']' : ''), !$bad);
$x = $mk(); $x['encounter'] = json_encode(['type' => 'choice', 'i' => 0]); explore_choose($gu, $x, 2);
ok('a walk saved before v1.9.4 (choice i=0) still resolves', $x['encounter'] === null && str_contains($J($x), 'tiptoe'));
$x = $mk(); $x['encounter'] = json_encode(['type' => 'choice', 'ev' => 'no-such-scene']); explore_choose($gu, $x, 0);
ok('an unknown scene id does nothing (no crash)', $x['encounter'] !== null && $x['log'] === '[]');

echo "== items from events: capped at 20% on a road, not in the wilds\n";
$gotItem = function (string $kind, string $id, int $opt, int $n) use ($mk, $gu) {
    $hits = 0; $gid = (int)q_val("SELECT id FROM items WHERE slug = 'garden-honey'");
    for ($i = 0; $i < $n; $i++) {
        $x = $mk($kind); $x['encounter'] = json_encode(['type' => 'choice', 'ev' => $id]);
        $before = (int)q_val('SELECT COALESCE(SUM(qty),0) FROM user_items WHERE user_id = ? AND item_id = ?', [$gu['id'], $gid]);
        $gu2 = q_one('SELECT * FROM users WHERE id = ?', [$gu['id']]);
        explore_choose($gu2, $x, $opt);
        if ((int)q_val('SELECT COALESCE(SUM(qty),0) FROM user_items WHERE user_id = ? AND item_id = ?', [$gu['id'], $gid]) > $before) $hits++;
    }
    return $hits;
};
q('UPDATE users SET stat_nimble = 40 WHERE id = ?', [$uid]);   // a sure win: the stat check always passes
$gu = q_one('SELECT * FROM users WHERE id = ?', [$uid]);
$wild = $gotItem('explore', 'bee-log', 0, 200); $road = $gotItem('walk', 'bee-log', 0, 600);
ok("bee-log honey: wilds $wild/200 (always), road $road/600 (<= ~26%)", $wild >= 195 && $road <= 600 * 0.26 && $road >= 600 * 0.12, "$road");
q_one('SELECT 1'); q('UPDATE users SET stat_nimble = 10 WHERE id = ?', [$uid]);
ok('road_fx_resolve: rare finds and seeds become common ones on a road; landmark dropped', (function () {
    for ($i = 0; $i < 300; $i++) { $r = road_fx_resolve('rand:rare@100+rand:seed@100+landmark+xp:3', true); foreach (explode('+', $r) as $p) if (!in_array($p, ['xp:3', 'rand:forage'], true)) return false; }
    return road_fx_resolve('landmark+xp:3', false) === 'landmark+xp:3';
})());
ok('road_fx_resolve: a purchase keeps its item (pay:15+rand:uncommon)', road_fx_resolve('pay:15+rand:uncommon', true) === 'pay:15+rand:uncommon');
ok('road_fx_resolve: @0 never, @100 always', road_fx_resolve('xp:1@0', false) === '' && road_fx_resolve('xp:1@100', false) === 'xp:1');

echo "== next_step: shares of the road\n";
$bindFresh();
$set('stop_daypart_force', 'day'); $set('weather_force', 'cloud');
$tally = ['creature' => 0, 'problem' => 0, 'choice' => 0, 'meet' => 0, 'find' => 0];
$N = 2400; $ring = [];
for ($i = 0; $i < $N; $i++) {
    $x = $mk(); q('UPDATE users SET energy = 50 WHERE id = ?', [$uid]);
    road_state()['ts'] = 0 ? 1 : null;
    next_step($gu, $x);
    $e = $x['encounter'] ? json_decode($x['encounter'], true) : null;
    $tally[$e ? $e['type'] : 'find']++;
    if ($e && $e['type'] === 'choice') $ring[$e['ev']] = 1;
}
$pc = fn($k) => round($tally[$k] * 100 / $N);
ok("shares: creature {$pc('creature')}% (40), problem {$pc('problem')}% (22), choice {$pc('choice')}% (14), meet {$pc('meet')}%, find {$pc('find')}%",
    abs($pc('creature') - 40) <= 4 && abs($pc('problem') - 22) <= 4 && abs($pc('choice') - 14) <= 3 && $pc('find') + $pc('meet') >= 20 && $pc('find') + $pc('meet') <= 28);
ok('fights stay 40% (not raised)', abs($pc('creature') - 40) <= 4);
ok('choice cards on a road come from many different scenes (' . count($ring) . ')', count($ring) >= 20);

echo "== villagers and travellers met on the road\n";
$a = (int)q_val("SELECT a_id FROM routes WHERE kind = 'road' ORDER BY id LIMIT 1 OFFSET 1"); $b = (int)q_val("SELECT b_id FROM routes WHERE kind = 'road' ORDER BY id LIMIT 1 OFFSET 1");
$la = q_one('SELECT * FROM locations WHERE id = ?', [$a]); $lb = q_one('SELECT * FROM locations WHERE id = ?', [$b]);
$scM = ['land' => 'grassland', 'from' => $la, 'to' => $lb, 'level' => 3, 'scaled' => false, 'region_id' => $la['region_id'], 'region' => $la['region']];
ok('both ends of the test leg are villages', $la['kind'] === 'village' && $lb['kind'] === 'village');
$t0 = gmmktime(12, 0, 0, 3, 3, 2030); $folkSeen = []; $cnt = [];
for ($k = 0; $k < 40; $k++) { $c = road_meet_candidates($scM, $t0 + $k * 3 * 3600); $cnt[] = count($c); foreach ($c as $x) if ($x['w'] === 'f') $folkSeen[$x['folk']['id']] = $x['home']['id']; }
ok('villagers are out some of the time and not all of it (counts ' . implode('', array_slice($cnt, 0, 20)) . ')', min($cnt) === 0 && max($cnt) >= 1 && array_sum($cnt) > 8);
ok('both ends supply villagers', count(array_unique($folkSeen)) === 2);
ok('the same clock gives the same people', json_encode(array_map('road_meet_key', road_meet_candidates($scM, $t0))) === json_encode(array_map('road_meet_key', road_meet_candidates($scM, $t0))));
$tsHit = null; for ($k = 0; $k < 60 && !$tsHit; $k++) if (road_meet_candidates($scM, $t0 + $k * 3 * 3600)) $tsHit = $t0 + $k * 3 * 3600;
ok('a moment with somebody about exists', $tsHit !== null);
// force a meeting through next_step
$folkBefore = (int)q_val('SELECT COUNT(*) FROM stop_friend WHERE user_id = ?', [$uid]);
$bindFresh(); $got = null;
for ($i = 0; $i < 900 && !$got; $i++) {
    $x = $mk(); $x['from_id'] = $a; $x['to_id'] = $b; $x['route_id'] = (int)q_val("SELECT id FROM routes WHERE kind = 'road' AND a_id = ? AND b_id = ?", [$a, $b]);
    road_state()['ts'] = $tsHit;
    next_step($gu, $x);
    $e = $x['encounter'] ? json_decode($x['encounter'], true) : null;
    if ($e && $e['type'] === 'meet') $got = [$x, $e];
}
ok('a meeting card appears on a road space', $got !== null);
if ($got) {
    [$x, $e] = $got;
    ok('the card has name, icon, intro, a chat line, no left-over {placeholders}', $e['n'] !== '' && $e['ic'] !== '' && mb_strlen($e['t']) > 20 && mb_strlen($e['l']) > 10 && !preg_match('/\{[a-z]+\}/', $e['t'] . $e['l'] . $e['s']), json_encode($e));
    ok('the intro is in the journal', str_contains($J($x), mb_substr($e['t'], 0, 30)));
    $folkId = (int)$e['id']; $pts0 = stop_friend_points($uid, $folkId);
    q('UPDATE stop_friend SET last_talk = NULL WHERE user_id = ? AND folk_id = ?', [$uid, $folkId]);
    $x2 = $x; road_meet_resolve($gu, $x2, 0);
    $pts1 = stop_friend_points($uid, $folkId);
    ok('chatting pays the usual friendship (' . $pts0 . ' -> ' . $pts1 . ') and clears the card', $pts1 > $pts0 && $x2['encounter'] === null && str_contains($J($x2), '💛'));
    $x3 = $x; road_meet_resolve($gu, $x3, 0);
    ok('a second chat the same day pays nothing (same claim)', stop_friend_points($uid, $folkId) === $pts1 && str_contains($J($x3), 'already had your chat today'));
    $loc = q_one('SELECT * FROM locations WHERE id = ?', [(int)$e['loc']]);
    [, $m] = stop_chat($gu, $loc, $folkId);
    ok('and the chat at the stop itself is then used up too', str_contains($m, 'already had your chat today'));
    $x4 = $x; $pts2 = stop_friend_points($uid, $folkId); road_meet_resolve($gu, $x4, 1);
    ok('waving walks on for free', $x4['encounter'] === null && str_contains($J($x4), '👋') && stop_friend_points($uid, $folkId) === $pts2);
    $x5 = $x; road_meet_resolve($gu, $x5, 7);
    ok('a bad option does nothing', $x5['encounter'] !== null);
}
// travellers: find the moment one is about at a market end
$mk0 = q_one("SELECT * FROM locations WHERE kind = 'market' ORDER BY id LIMIT 1");
$rt = q_one("SELECT * FROM routes WHERE kind = 'road' AND (a_id = ? OR b_id = ?) ORDER BY id LIMIT 1", [$mk0['id'], $mk0['id']]);
$oth = q_one('SELECT * FROM locations WHERE id = ?', [(int)$rt['a_id'] === (int)$mk0['id'] ? (int)$rt['b_id'] : (int)$rt['a_id']]);
$scT = ['land' => 'grassland', 'from' => $mk0, 'to' => $oth, 'level' => 3, 'scaled' => false, 'region_id' => $mk0['region_id'], 'region' => $mk0['region']];
$tt = null; $dirs = [];
for ($k = 0; $k < 400; $k++) { $ts = $t0 + $k * 1800; foreach (road_meet_candidates($scT, $ts) as $c) if ($c['w'] === 't') { $tt ??= [$ts, $c]; $dirs[$c['dir']] = 1; } }
ok('a travelling NPC is on the road at a market end at some moments (in and out)', $tt !== null && count($dirs) === 2);
if ($tt) {
    [$tts, $tc] = $tt;
    $x = $mk(); $x['from_id'] = (int)$mk0['id']; $x['to_id'] = (int)$oth['id'];
    $bindFresh(); road_meet_start($gu, $x, $tc);
    $e = json_decode($x['encounter'], true);
    ok('traveller card: name, a role line, no placeholders', $e['w'] === 't' && $e['n'] === $tc['npc']['name'] && str_starts_with($e['s'], 'Travelling') && !preg_match('/\{[a-z]+\}/', $e['t'] . $e['l']), json_encode($e));
    $nid = (int)$e['id']; q('UPDATE npc_friends SET last_talk = NULL WHERE user_id = ? AND npc_id = ?', [$uid, $nid]);
    $p0 = (int)friendship($uid, $nid)['points']; $x2 = $x; road_meet_resolve($gu, $x2, 0); $p1 = (int)friendship($uid, $nid)['points'];
    ok("traveller chat pays friendship ($p0 -> $p1)", $p1 > $p0 && $x2['encounter'] === null);
    $x3 = $x; road_meet_resolve($gu, $x3, 0);
    ok('and only once a day', (int)friendship($uid, $nid)['points'] === $p1 && str_contains($J($x3), 'already had your chat today'));
    $pTown = null; [$okTalk, $mTalk] = npc_talk($gu, $nid);
    ok('npc_talk (in town) is then used up too (same claim)', !$okTalk || str_contains($mTalk, 'already'), $mTalk);
}
ok('explore never meets anyone (walks only)', (function () use ($mk, $gu, $tsHit) { for ($i = 0; $i < 200; $i++) { $x = $mk('explore'); $x['hp'] = 30; explore_deeper($gu, $x); $e = $x['encounter'] ? json_decode($x['encounter'], true) : null; if ($e && $e['type'] === 'meet') return false; } return true; })());

echo "== data lint: road_meet.txt\n";
$errs = []; $who = []; $n = 0;
$allWho = ['Chatty', 'Cheerful', 'Warm', 'Generous', 'Eager', 'Grumpy', 'Shy', 'Fussy', 'Proud', 'Curious', 'Dreamy', 'Sleepy', 'merchant', 'minstrel', 'naturalist', 'any', 'gourmand', '@folk', '@trav-in', '@trav-out'];
foreach (file($argv[1] . '/includes/data/road_meet.txt', FILE_IGNORE_NEW_LINES) as $i => $line) {
    $line = trim($line); if ($line === '' || $line[0] === '#') continue; $n++;
    $f = explode('|', $line);
    if (count($f) !== 3) { $errs[] = 'line ' . ($i + 1) . ': ' . count($f) . ' fields'; continue; }
    if (($m = $lintCond(trim($f[0])))) $errs[] = 'line ' . ($i + 1) . ": $m";
    foreach (explode(',', $f[1]) as $w) { if (!in_array(trim($w), $allWho, true)) $errs[] = 'line ' . ($i + 1) . ": who '$w'"; $who[trim($w)] = ($who[trim($w)] ?? 0) + 1; }
    if (mb_strlen(trim($f[2])) > 170 || mb_strlen(trim($f[2])) < 20) $errs[] = 'line ' . ($i + 1) . ': length ' . mb_strlen(trim($f[2]));
    if (preg_match_all('/\{(\w+)\}/', $f[2], $mm)) foreach ($mm[1] as $ph) if (!in_array($ph, ['name', 'folk', 'role', 'place', 'dest', 'from'], true)) $errs[] = 'line ' . ($i + 1) . ": {{$ph}}";
    if (str_contains($f[2], '\'')) $errs[] = 'line ' . ($i + 1) . ': straight apostrophe';
}
ok("road_meet.txt: $n lines, 3 fields, valid cond/who/placeholders" . ($errs ? ' [' . implode('; ', array_slice($errs, 0, 5)) . ']' : ''), !$errs && $n >= 30);
$pers = ['Chatty', 'Cheerful', 'Warm', 'Generous', 'Eager', 'Grumpy', 'Shy', 'Fussy', 'Proud', 'Curious', 'Dreamy', 'Sleepy'];
ok('all 12 personalities have 2+ lines, incl. Warm, Eager, Fussy, Dreamy', count(array_filter($pers, fn($p) => ($who[$p] ?? 0) >= 2)) === 12);
ok('each traveller has lines; intros for folk, arriving and leaving travellers', ($who['merchant'] ?? 0) >= 2 && ($who['minstrel'] ?? 0) >= 2 && ($who['naturalist'] ?? 0) >= 2 && ($who['@folk'] ?? 0) >= 3 && ($who['@trav-in'] ?? 0) >= 1 && ($who['@trav-out'] ?? 0) >= 1);
$ctxn = ['dp' => 'day', 'se' => 'summer', 'we' => 'sun']; $miss = 0;
foreach ($pers as $p) { road_unbind(); if (road_meet_text('chat', [$p], ['name' => 'X', 'folk' => 'Y', 'place' => 'P', 'dest' => 'D'], $ctxn) === '') $miss++; }
ok('every personality gets a chat line in the daytime', $miss === 0);
$set('stop_daypart_force', ''); $set('weather_force', '');

echo "== wonders: own text, and it really changes with the days\n";
$wl = array_map(fn($r) => landmark_at((int)$r['location_id']), q("SELECT location_id FROM landmarks WHERE kind = 'wonder' ORDER BY id")->fetchAll());
ok('35 wonders in the world', count($wl) === 35, (string)count($wl));
$miss = []; foreach ($wl as $w) foreach (['intro', 'success', 'fail'] as $k) if (mb_strlen(wonder_text($w, $k)) < 40) $miss[] = $w['name'] . ':' . $k;
ok('every wonder has its own intro, success and fail text' . ($miss ? ' [' . implode(', ', array_slice($miss, 0, 4)) . ']' : ''), !$miss);
$all = []; foreach ($wl as $w) foreach (['intro', 'success', 'fail'] as $k) $all[] = wonder_text($w, $k);
ok('all 105 texts are different', count(array_unique($all)) === 105);
$names = []; foreach (catalog_lines('landmarks.txt') as $r) if (($r[2] ?? '') === 'wonder') $names[] = $r[3];
$fileNames = []; foreach (file($argv[1] . '/includes/data/wonder_text.txt', FILE_IGNORE_NEW_LINES) as $line) { $line = trim($line); if ($line === '' || $line[0] === '#' || $line[0] === '*') continue; $f = explode('|', $line); if (count($f) !== 4) $fileNames[] = 'BAD:' . $f[0]; else { $fileNames[] = $f[0]; foreach ([1, 2, 3] as $c) if (mb_strlen($f[$c]) > 200 || str_contains($f[$c], '\'')) $fileNames[] = 'LEN/APOS:' . $f[0]; } }
ok('wonder_text.txt: one row per wonder in landmarks.txt, 4 columns, texts <= 200 chars', count($names) === 35 && !array_diff($names, $fileNames) && !array_diff($fileNames, $names) && count($fileNames) === 35, implode(',', array_merge(array_diff($names, $fileNames), array_diff($fileNames, $names))));
ok('moods: 3 kinds with 2+ lines each', count(wonder_texts()['*easy'] ?? []) >= 2 && count(wonder_texts()['*plain'] ?? []) >= 2 && count(wonder_texts()['*hard'] ?? []) >= 2);
$w0 = $wl[0]; $combos = []; $deltas = []; $ownSame = true; $firstOwn = null;
for ($d = 0; $d < 40; $d++) {
    $day = gmdate('Y-m-d', 1900000000 + $d * 86400);
    $ap = wonder_approaches($w0, $uid, $day);
    $keys = array_keys($ap); $firstOwn ??= $keys[0]; if ($keys[0] !== $firstOwn) $ownSame = false;
    $combos[implode(',', array_slice($keys, 1))] = 1; $deltas[wonder_mood($w0, $day)[0]] = 1;
    if (count($ap) !== 3 || (array_values($ap)[0][2] >= array_values($ap)[1][2])) { $ownSame = false; }
}
ok('own approach is the same and the easiest every day; 3 approaches always', $ownSame);
ok('the other two vary with the day (' . count($combos) . ' pairings over 40 days)', count($combos) >= 5);
ok('the difficulty varies: easier, plain and harder days all happen', count($deltas) === 3);
ok('the same day gives the same wonder', wonder_approaches($w0, $uid, '2031-05-05') === wonder_approaches($w0, $uid, '2031-05-05') && wonder_mood($w0, '2031-05-05') === wonder_mood($w0, '2031-05-05'));
$dcs = []; foreach ($wl as $w) { $ap = wonder_approaches($w, $uid, '2031-05-05'); $dcs[] = array_values($ap)[1][2] - (10 + intdiv((int)$w['level'], 2) - (landmark_rebuilt_by($w, $uid) ? 1 : 0)) - 1; }
ok('on one day the wonders do not all share the same mood', count(array_unique($dcs)) === 3, json_encode(array_count_values($dcs)));
ok('the old claim "it changes with the days" is true now: today differs from another day for some wonder', (function () use ($wl, $uid) { foreach ($wl as $w) if (wonder_approaches($w, $uid, '2031-05-05') !== wonder_approaches($w, $uid, '2031-05-06')) return true; return false; })());
// wonder_try uses its own words
$lmRow = landmark_at((int)$wl[0]['location_id']);
q('UPDATE users SET location_id = ? WHERE id = ?', [$wl[0]['location_id'], $uid]);
q('DELETE FROM expeditions WHERE user_id = ?', [$uid]);
$gu = q_one('SELECT * FROM users WHERE id = ?', [$uid]);
$ap = array_keys(wonder_approaches(landmark_at((int)$wl[0]['location_id']), $uid));
q('UPDATE users SET stat_lore = 40, stat_sense = 40, stat_charm = 40, stat_nimble = 40, stat_grit = 40, stat_hardiness = 40 WHERE id = ?', [$uid]);
$gu = q_one('SELECT * FROM users WHERE id = ?', [$uid]); unset($_SESSION['prizes']);
[$okW, $mW] = wonder_try($gu, (int)$wl[0]['id'], $ap[0]);
$pz = $_SESSION['prizes'][0] ?? null;
ok('a good roll tells the wonder\'s own success text', $okW && $pz && $pz['big'] === wonder_text($wl[0], 'success'), json_encode($pz));
q('UPDATE users SET stat_lore = -30, stat_sense = -30, stat_charm = -30, stat_nimble = -30, stat_grit = -30, stat_hardiness = -30 WHERE id = ?', [$uid]);
q('DELETE FROM landmark_uses WHERE user_id = ?', [$uid]); unset($_SESSION['prizes']);
$gu = q_one('SELECT * FROM users WHERE id = ?', [$uid]);
[$okW, $mW] = wonder_try($gu, (int)$wl[0]['id'], $ap[0]);
$pz = $_SESSION['prizes'][0] ?? null;
ok('a bad roll tells its own fail text', $okW && $pz && $pz['big'] === wonder_text($wl[0], 'fail'), json_encode($pz));
$panel = landmark_panel($gu, ['id' => $wl[0]['location_id'], 'slug' => (string)q_val('SELECT slug FROM locations WHERE id = ?', [$wl[0]['location_id']])]);
ok('the panel shows the intro and the mood', str_contains($panel, 'wonderintro') && str_contains($panel, 'wondermood'));
ok('the "it changes with the days" message is now true (see the two checks above)', str_contains(file_get_contents($argv[1] . '/includes/landmarks.php'), 'it changes with the days'));
q('UPDATE users SET stat_lore = 10, stat_sense = 10, stat_charm = 10, stat_nimble = 10, stat_grit = 10, stat_hardiness = 10 WHERE id = ?', [$uid]);

echo "== villages: more than 9 descriptions\n";
$vs = q("SELECT * FROM locations WHERE kind = 'village'")->fetchAll();
$d = []; foreach ($vs as $v) $d[village_blurb($v)] = 1;
ok(count($vs) . ' villages show ' . count($d) . ' different descriptions (was 9)', count($d) >= 30);
ok('a village always reads the same', village_blurb($vs[3]) === village_blurb($vs[3]));
ok('an admin-written description is shown as written', village_blurb(['kind' => 'village', 'landscape' => 'forest', 'description' => 'My own words.', 'slug' => 'x']) === 'My own words.');
ok('non-villages untouched', village_blurb(['kind' => 'haven', 'landscape' => 'forest', 'description' => LANDSCAPES['forest'][2], 'slug' => 'x']) === LANDSCAPES['forest'][2]);
$errs = []; $per = [];
foreach (file($argv[1] . '/includes/data/village_blurbs.txt', FILE_IGNORE_NEW_LINES) as $i => $line) { $line = trim($line); if ($line === '' || $line[0] === '#') continue; $f = explode('|', $line); if (count($f) !== 2 || !isset(LANDSCAPES[$f[0]]) || mb_strlen($f[1]) > 130 || str_contains($f[1], '\'')) $errs[] = 'line ' . ($i + 1); else $per[$f[0]] = ($per[$f[0]] ?? 0) + 1; }
ok('village_blurbs.txt lint, 4+ extra sentences for each of the 9 landscapes' . ($errs ? ' [' . implode(',', $errs) . ']' : ''), !$errs && count($per) === 9 && min($per) >= 4);

echo "== v1.9.5 content fill\n";
$dd = $argv[1] . '/includes/data/';
$regs = []; foreach (file($dd . 'regions.txt', FILE_IGNORE_NEW_LINES) as $l) { if ($l === '' || $l[0] === '#') continue; $regs[] = explode('|', $l)[0]; }
$evReg = []; $evIds = []; $evBad = [];
foreach (file($dd . 'road_events.txt', FILE_IGNORE_NEW_LINES) as $i => $l) {
    if ($l === '' || $l[0] === '#') continue;
    $f = explode('|', $l);
    if ($f[0] === 'E') { if (!in_array(count($f), [8, 10], true) || isset($evIds[$f[1]])) $evBad[] = $i + 1; $evIds[$f[1]] = 1; $evReg[$f[4]] = ($evReg[$f[4]] ?? 0) + 1; }
    elseif ($f[0] === 'O') { if (count($f) !== 8) $evBad[] = $i + 1; foreach ([$f[4], $f[6]] as $fx) foreach (explode('+', $fx) as $part) if (preg_match('/@(\d+)$/', $part, $m) && (int)$m[1] > 20) $evBad[] = $i + 1; }
    if (str_contains($l, '\'')) $evBad[] = $i + 1;
}
$missing = array_filter($regs, fn($r) => ($evReg[$r] ?? 0) < 6);
ok('road_events.txt: unique ids, field counts, no apostrophes, item chance <= 20' . ($evBad ? ' [' . implode(',', $evBad) . ']' : ''), !$evBad);
ok('every one of the ' . count($regs) . ' regions has a pack of 6+ events' . ($missing ? ' [' . implode(',', $missing) . ']' : ''), !$missing);
$lnReg = []; $lnBad = [];
foreach (file($dd . 'road_lines.txt', FILE_IGNORE_NEW_LINES) as $i => $l) {
    if ($l === '' || $l[0] === '#') continue;
    $f = explode('|', $l, 4);
    if (count($f) < 4 || mb_strlen($f[3]) > 120 || str_contains($l, '\'')) $lnBad[] = $i + 1;
    if (($f[2] ?? 'any') !== 'any') $lnReg[$f[2]] = ($lnReg[$f[2]] ?? 0) + 1;
}
$lnMissing = array_filter($regs, fn($r) => ($lnReg[$r] ?? 0) < (in_array($r, ['NA', 'NWE', 'EA'], true) ? 2 : 6));
ok('road_lines.txt lint (<= 120 chars)' . ($lnBad ? ' [' . implode(',', $lnBad) . ']' : ''), !$lnBad);
ok('every region has region-tagged ambient lines (the 11 filled ones 6+)' . ($lnMissing ? ' [' . implode(',', $lnMissing) . ']' : ''), !$lnMissing);
$pers = []; $scBad = [];
foreach (file($dd . 'stop_chat.txt', FILE_IGNORE_NEW_LINES) as $i => $l) {
    if ($l === '' || $l[0] === '#') continue;
    $f = explode('|', $l);
    if (count($f) !== 3 || str_contains($l, '\'')) $scBad[] = $i + 1;
    $pers[$f[1]] = ($pers[$f[1]] ?? 0) + 1;
}
ok('stop_chat.txt lint' . ($scBad ? ' [' . implode(',', $scBad) . ']' : ''), !$scBad);
ok('Warm, Eager, Fussy and Dreamy each have 6+ own lines', min($pers['Warm'] ?? 0, $pers['Eager'] ?? 0, $pers['Fussy'] ?? 0, $pers['Dreamy'] ?? 0) >= 6, json_encode($pers));
$kinds = ['entry', 'creature', 'problem', 'find', 'chest']; $dv = []; $dvBad = [];
foreach (file($dd . 'delve_rooms.txt', FILE_IGNORE_NEW_LINES) as $i => $l) {
    if ($l === '' || $l[0] === '#') continue;
    $f = explode('|', $l);
    if (count($f) !== 4 || !in_array($f[0], $kinds, true) || mb_strlen($f[3]) > 120 || str_contains($l, '\'')) { $dvBad[] = $i + 1; continue; }
    foreach (explode(',', $f[2]) as $ld) $dv[$f[0]][$ld === 'any' ? 'any' : $ld] = 1;
}
$dvGap = []; foreach (array_keys(LANDSCAPES) as $ld) foreach ($kinds as $k) if (empty($dv[$k][$ld]) && empty($dv[$k]['any'])) $dvGap[] = "$k/$ld";
ok('delve_rooms.txt lint' . ($dvBad ? ' [' . implode(',', $dvBad) . ']' : ''), !$dvBad);
ok('every landscape has a line for every room kind' . ($dvGap ? ' [' . implode(',', $dvGap) . ']' : ''), !$dvGap);
ok('a delve room line is stable for the same seed', delve_room_line('creature', 'forest', 'a|1|2') === delve_room_line('creature', 'forest', 'a|1|2') && delve_room_line('creature', 'forest', 'a|1|2') !== '');
$seen = []; for ($i = 0; $i < 30; $i++) $seen[delve_room_line('problem', 'coast', "s|$i")] = 1;
ok('different rooms get different lines', count($seen) >= 2);
ok('every landscape now has 4 finds, all existing gatherable items', (function () use ($dd) {
    $slugs = []; foreach (file($dd . 'gatherables.txt', FILE_IGNORE_NEW_LINES) as $l) { if ($l === '' || $l[0] === '#') continue; $slugs[explode('|', $l)[0]] = 1; }
    foreach (LANDSCAPE_FINDS as $land => $fs) { if (count($fs) !== 4) return false; foreach (array_slice($fs, 2) as [$n]) if (!isset($slugs[slugify($n)])) return false; }
    return count(LANDSCAPE_FINDS) === 9;
})());
// a delve walk writes a room line
q('DELETE FROM expeditions WHERE user_id = ?', [$uid]);
$dl = q_one("SELECT * FROM landmarks WHERE kind = 'delve' ORDER BY id LIMIT 1");
if ($dl) {
    q('UPDATE users SET location_id = ?, energy = 20 WHERE id = ?', [$dl['location_id'], $uid]);
    q('DELETE FROM landmark_uses WHERE user_id = ?', [$uid]);
    $gu = q_one('SELECT * FROM users WHERE id = ?', [$uid]);
    [$okD] = delve_start($gu, (int)$dl['id']);
    $ex = q_one("SELECT * FROM expeditions WHERE user_id = ? AND kind = 'delve' ORDER BY id DESC LIMIT 1", [$uid]);
    ok('starting a delve logs the way in with a line', $okD && $ex && count(json_decode($ex['log'], true)) === 2, (string)($ex['log'] ?? ''));
    q('DELETE FROM expeditions WHERE user_id = ?', [$uid]);
}

echo "== v2.0.16 road roll settings\n";
$edges = fn() => (function () { $b = road_roll_bands(); return [$b['creature'], $b['problem'], $b['choice'], $b['total']]; })();
foreach (['creature' => '40', 'problem' => '22', 'choice' => '14', 'find' => '24'] as $k => $v) ok("road_roll_$k default $v", setting("road_roll_$k") === $v, setting("road_roll_$k"));
ok('defaults reproduce the old split (40 / 62 / 76 of 100)', $edges() === [40, 62, 76, 100], json_encode($edges()));
foreach (['creature', 'problem', 'choice', 'find'] as $k) $set("road_roll_$k", '0');
ok('all zero falls back to the defaults', $edges() === [40, 62, 76, 100], json_encode($edges()));
$set('road_roll_creature', '500'); $set('road_roll_problem', '-5'); $set('road_roll_choice', 'x'); $set('road_roll_find', '0');
ok('clamped to 0-100, junk = default weight', $edges() === [100, 100, 114, 114], json_encode($edges()));
$set('road_roll_creature', '10'); $set('road_roll_problem', '10'); $set('road_roll_choice', '0'); $set('road_roll_find', '30');
ok('weights need not sum to 100', $edges() === [10, 20, 20, 50], json_encode($edges()));
foreach (['creature', 'problem', 'choice', 'find'] as $k) q('DELETE FROM settings WHERE name = ?', ["road_roll_$k"]);
setting('__reload__');
ok('settings removed = defaults again', $edges() === [40, 62, 76, 100]);
ok('admin lists them as advanced', str_contains(file_get_contents($GLOBALS['argv'][1] . '/admin/settings.php'), "'road_roll_'"));

echo $fails ? "\n$fails FAILED\n" : "\nall passed\n";
exit($fails ? 1 : 0);
