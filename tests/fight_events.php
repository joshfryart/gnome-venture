<?php
// Fight events (step 1 of claude/fight-wiring-proposal.md): the recorder must (a) not change the fight at all, (b) describe it truthfully.
//   (a) seeded fights end in exactly the state in tests/fight_events_golden.json (recorded from the code BEFORE the recorder existed): hp, creature hp, status, log, next random number
//   (b) when fight_ev() exists: the events add up to the hp changes, flee/win/KO are marked, every event is well formed.
// Run on an installed copy (walk.sh), random_int switched off so the test can seed it:
//   php -d disable_functions=random_int tests/fight_events.php GAME_DIR [--record]
if (function_exists('random_int') && (new ReflectionFunction('random_int'))->isInternal()) { fwrite(STDERR, "Run with: php -d disable_functions=random_int tests/fight_events.php GAME_DIR [--record]\n"); exit(2); }
function random_int(int $min, int $max): int { return mt_rand($min, $max); }
$_SERVER['SCRIPT_NAME'] = '/adventure.php';
require $argv[1] . '/includes/bootstrap.php';
require_once $argv[1] . '/includes/adventure.php';
require_once $argv[1] . '/includes/puzzle_pals.php';
require_once $argv[1] . '/includes/items.php';
if (session_status() !== PHP_SESSION_ACTIVE) session_start();
$record = in_array('--record', $argv, true);
$file = __DIR__ . '/fight_events_golden.json';
$u = q_one("SELECT * FROM users WHERE username = 'sprout'");
$uid = (int)$u['id'];
// a fixed gnome: walk.sh gives every install a random name and stats, and the golden must not depend on them
$u['level'] = 4; $u['calling_qt'] = 99;
foreach (['grit' => 12, 'nimble' => 11, 'hardiness' => 10, 'luck' => 20, 'charm' => 10, 'lore' => 10, 'cheer' => 10, 'cunning' => 10] as $k => $v) $u['stat_' . $k] = $v;
if (!active_expedition($uid)) explore_start($u);
$base = active_expedition($uid);
if (!$base) { echo "FAIL no expedition\n"; exit(1); }
$creatures = q("SELECT * FROM creatures WHERE level <= 6 ORDER BY id LIMIT 8")->fetchAll();
$out = []; $bad = 0;
$fail = function (string $m) use (&$bad) { $bad++; echo "FAIL $m\n"; };
$callings = ['thornblade', 'rootwarden', 'bloomcaller', 'seedkeeper', 'wayfinder', 'brewroot', ''];
$n = 0;
foreach ($creatures as $ci => $c) foreach (['attack', 'ability', 'flee', 'fighton', 'auto'] as $act) foreach ([0, 1, 2] as $variant) {
    $n++;
    $u['calling'] = $callings[($ci + $variant) % count($callings)];
    $exp = $base;
    $exp["hp"] = $exp["max_hp"] = [3, 16, 24][$variant];   // variant 0/1/2: a gnome that gets knocked out, a sturdy one, a very sturdy one (long fights)
    $exp['status'] = 'active'; $exp['log'] = '[]';
    $mx = (int)$c['hp'];
    $exp['encounter'] = json_encode(['type' => 'creature', 'id' => (int)$c['id'], 'lv' => 0, 'sp' => 100, 'hpp' => 100, 'hp' => $mx, 'max' => $mx, 'bark' => 0, 'poison' => $variant === 2 ? 1 : 0, 'used' => false]);
    $enc0 = json_decode($exp['encounter'], true); $c0 = encounter_creature($enc0); fight_prep($enc0, $c0);
    $foe0 = (int)$enc0['hp']; $me0 = (int)$exp['hp'];
    if (function_exists('fight_ev')) fight_ev();   // drain
    mt_srand(5000 + $n);
    db()->beginTransaction();   // a win pays xp, loot and an Almanac page: roll it all back so every fight starts from the same gnome and the test repeats
    try {
        if ($act === 'fighton') fight_on($u, $exp);
        elseif ($act === 'auto') { if (fight_certainty($u, $exp, $c0, $enc0)) auto_resolve($u, $exp); else combat_turn($u, $exp, 'attack'); }
        else combat_turn($u, $exp, $act);
    } catch (Throwable $e) { db()->rollBack(); $fail("$n $act: " . $e->getMessage()); continue; }
    db()->rollBack();
    $encN = $exp['encounter'] ? json_decode((string)$exp['encounter'], true) : null;
    $key = $c['slug'] . ":$act:$variant";
    $out[$key] = ['hp' => (int)$exp['hp'], 'status' => $exp['status'], 'foe' => $encN ? (int)$encN['hp'] : null, 'log' => array_values(array_filter(json_decode((string)$exp['log'], true), fn($l) => !str_contains((string)$l, 'Milestone:'))), 'next' => mt_rand()];
    if (!function_exists('fight_ev')) continue;
    $ev = fight_ev();
    $dmgFoe = 0; $dmgMe = 0; $heal = 0; $ended = null; $fled = false; $charmed = false;
    foreach ($ev as $i => $e) {
        if (!is_array($e) || !isset($e['from']) && !isset($e['end'])) { $fail("$key: event $i malformed"); continue; }
        if (isset($e['end'])) { $ended = $e['end']; continue; }
        if (!in_array($e['from'], ['me', 'foe'], true)) $fail("$key: event $i bad from");
        foreach (['dmg', 'heal'] as $f) if (isset($e[$f]) && (!is_int($e[$f]) || $e[$f] < 0)) $fail("$key: event $i bad $f");
        if (($e['move'] ?? '') === 'flee') $fled = true;
        if (($e['move'] ?? '') === 'charm' && !empty($e['ok'])) $charmed = true;
        if (isset($e['to']) && empty($e['miss']) && isset($e['dmg'])) { if ($e['to'] === 'foe') $dmgFoe += $e['dmg']; else $dmgMe += $e['dmg']; }
        if (($e['move'] ?? '') === 'hurt') { if ($e['from'] === 'foe') $dmgFoe += (int)$e['dmg']; else $dmgMe += (int)$e['dmg']; }
        if (isset($e['heal'])) $heal += $e['heal'];
    }
    $foeEnd = $encN ? (int)$encN['hp'] : 0;
    if (!$charmed && !$fled && min($foe0, $dmgFoe) !== $foe0 - $foeEnd && !($encN === null && $ended === 'ko')) $fail("$key: foe hp $foe0 -> $foeEnd but events say $dmgFoe");
    if ($ended === null && $encN === null && !$fled) $fail("$key: fight over but no end event");
    if ($ended !== null && $encN !== null) $fail("$key: end event but the fight goes on");
    if ($ended === null && $encN !== null && (int)$exp['hp'] !== $me0 - $dmgMe + $heal) $fail("$key: gnome hp $me0 -> " . $exp['hp'] . " but events say -$dmgMe +$heal");
    if ($fled && !in_array($ended, ['flee'], true)) $fail("$key: flee without end flee");
    if ($act === 'fighton' && count($ev) < 2) $fail("$key: fight on made no events");
    $out[$key]['ev'] = count($ev);
}
// pal skills: the pal does the moving (fight_pal_events); a pal that is not on the stage leaves the old events
if (function_exists('fight_pal_events')) {
    fight_ev();
    fight_pal_events(-1, [['from' => 'foe', 'move' => 'hurt', 'dmg' => 4, 'kind' => 'pal']], null, 4); $e = fight_ev();
    if ($e !== [['from' => 'foe', 'move' => 'hurt', 'dmg' => 4, 'kind' => 'pal']]) $fail('pal strike with no pal on the stage keeps the plain hurt event: ' . json_encode($e));
    fight_pal_events(1, [['from' => 'foe', 'move' => 'hurt', 'dmg' => 4, 'kind' => 'pal']], null, 4); $e = fight_ev();
    if (count($e) !== 1 || $e[0]['from'] !== 'pal1' || $e[0]['to'] !== 'foe' || $e[0]['move'] !== 'hop' || $e[0]['dmg'] !== 4) $fail('pal strike: the pal hops at the foe: ' . json_encode($e));
    fight_pal_events(0, [['from' => 'me', 'move' => 'guard']], [['from' => 'me', 'move' => 'note', 'text' => 'shielded']]); $e = fight_ev();
    if (count($e) !== 2 || $e[0]['from'] !== 'pal0' || $e[0]['move'] !== 'cheer' || $e[1]['move'] !== 'note') $fail('pal shield: the pal cheers, no gnome guard: ' . json_encode($e));
    fight_pal_events(2, [['from' => 'foe', 'move' => 'note', 'kind' => 'daze']]); $e = fight_ev();
    if (count($e) !== 2 || $e[0]['from'] !== 'pal2' || $e[1]['from'] !== 'foe') $fail('pal daze: the pal cheers, then the foe is dazed: ' . json_encode($e));
    if (fight_pal_slot($u, 'no-such-pal') !== -1) $fail('a pal that is not along has no slot');
}
// end scenes for a run and a knock-out (fight_finale_*): a flee is pending on the map, a KO is not (its walk is over); neither has a reward to collect
if (is_file($argv[1] . '/includes/fight_scene.php')) {
    require_once $argv[1] . '/includes/fight_scene.php';
    $rec = fn(string $end) => ['exp' => 777, 't' => time(), 'start' => ['me' => ['hp' => 9, 'max' => 20], 'foe' => ['hp' => 5, 'max' => 5, 'slug' => 'aphid-swarm', 'name' => 'Aphid']],
        'ev' => [['from' => 'me', 'move' => $end === 'ko' ? 'attack' : 'flee'], ['end' => $end]], 'end' => ['me' => ['hp' => $end === 'ko' ? 0 : 9, 'max' => 20], 'foe' => ['hp' => 5]]];
    foreach (['flee' => true, 'ko' => false, 'win' => true] as $end => $pending) {
        $_SESSION['fight_ev'] = $rec($end);
        if (fight_finale_pending(['id' => 777]) !== $pending) $fail("finale pending after $end should be " . ($pending ? 'yes' : 'no'));
    }
    foreach (['flee', 'ko'] as $end) {
        $_SESSION['fight_ev'] = $rec($end);
        $h = fight_finale_html($u, ['id' => 777], $end === 'flee' ? ['cols' => 9, 'rows' => 9, 'mx' => 2, 'my' => 4, 'fx' => 4] : null);
        $d = preg_match('/data-fight="([^"]*)"/', $h, $m) ? json_decode(html_entity_decode($m[1]), true) : null;
        if (!$d || !$d['finale'] || $d['reward'] !== null) $fail("$end end scene: finale with no reward");
        if ($end === 'ko' && str_contains($h, 'fs-over')) $fail('KO end scene with no map must not use the over-the-map layout');
        if ($end === 'flee' && !str_contains($h, 'fs-over')) $fail('flee end scene sits over the map');
        if (isset($_SESSION['fight_ev'])) $fail("$end end scene did not consume the record");
    }
    $_SESSION['fight_ev'] = $rec('win'); fight_finale_html($u, ['id' => 777], ['cols' => 9, 'rows' => 9, 'mx' => 2, 'my' => 4, 'fx' => 4]);
}
if ($record) { file_put_contents($file, json_encode(['n' => $n, 'out' => array_map(fn($o) => array_diff_key($o, ['ev' => 1]), $out)], JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE)); echo "recorded $n fights\n"; exit($bad ? 1 : 0); }
$gold = json_decode((string)file_get_contents($file), true);
foreach ($gold['out'] as $k => $g) { $o = $out[$k] ?? null; if ($o === null) { $fail("$k missing"); continue; } if (array_diff_key($o, ["ev" => 1]) != $g) { $fail("$k: the fight changed"); if (getenv("FEDBG")) { echo json_encode(array_diff_key($o, ["ev" => 1])), "\n", json_encode($g), "\n"; } } }
echo $bad ? "$bad FAILED\n" : "ok $n fights" . (function_exists('fight_ev') ? ' (events checked)' : ' (no recorder yet)') . "\n";
exit($bad ? 1 : 0);
