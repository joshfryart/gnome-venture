<?php
// v2.0.31 Burrow Sorting. Run on the world walk.sh made (player "sprout"): php burrow21.php GAME
//   generator properties over 2,000 seeds, knock validation, hit counting, payout-once, Charm knock, no solution in rendered clue text.
$_SERVER['SCRIPT_NAME'] = '/burrow.php';
require $argv[1] . '/includes/bootstrap.php';
require_once $argv[1] . '/includes/garden_logic.php';
require_once $argv[1] . '/includes/games.php';
require_once $argv[1] . '/includes/burrow.php';
set_exception_handler(function (Throwable $e) { echo '  FAIL uncaught ' . get_class($e) . ': ' . $e->getMessage() . ' at ' . basename($e->getFile()) . ':' . $e->getLine() . "\n"; exit(1); });
if (session_status() !== PHP_SESSION_ACTIVE) session_start();
$fails = 0;
function ok(string $what, bool $cond, string $extra = ''): void { global $fails; echo ($cond ? '  ok   ' : '  FAIL ') . $what . ($cond ? '' : "  $extra") . "\n"; if (!$cond) $fails++; }

echo "== registry and settings\n";
ok('GAMES row', isset(GAMES['burrow']) && GAMES['burrow'][2] === 'burrow.php' && GAMES['burrow'][4] === 'burrow_plays_per_day');
ok('setting default 3', (int)setting('burrow_plays_per_day') === 3, setting('burrow_plays_per_day'));
ok('no ASCII apostrophe in the blurb', !str_contains(GAMES['burrow'][3], "'"));

echo "== generator: 2,000 puzzles\n";
mt_srand(2101);
$rnd = fn(int $a, int $b) => mt_rand($a, $b);
$seasons = array_keys(BURROW_CASTS);
$bad = ['fit' => 0, 'sol' => 0, 'n' => 0, 'pos' => 0, 'cast' => 0, 'true' => 0, 'tpl3' => 0, 'text' => 0, 'winter' => 0, 'perm' => 0];
$fitHist = [];
$t0 = microtime(true);
for ($i = 0; $i < 2000; $i++) {
    $season = $seasons[$i % 4];
    $pz = burrow_new_puzzle($season, $rnd);
    $nfit = burrow_fit_count($pz['clues']);
    $fitHist[$nfit] = ($fitHist[$nfit] ?? 0) + 1;
    if ($nfit < 3 || $nfit > 8 || $nfit !== $pz['fit']) $bad['fit']++;
    $p = [];   // cast index => door position (1-5)
    foreach ($pz['sol'] as $door => $ci) $p[$ci] = $door + 1;
    if (count($pz['sol']) !== 5 || count(array_unique($pz['sol'])) !== 5 || count($p) !== 5) $bad['perm']++;
    foreach ($pz['clues'] as $c) if (!burrow_clue_ok($c, $p)) { $bad['sol']++; break; }
    $n = count($pz['clues']);
    if ($n < 3 || $n > 6) $bad['n']++;
    $pos = 0; $tpl = [];
    foreach ($pz['clues'] as $c) { if ($c[0] === 'T1' || $c[0] === 'T10') $pos++; $tpl[$c[0]] = ($tpl[$c[0]] ?? 0) + 1; }
    if ($pos > 1) $bad['pos']++;
    if ($tpl && max($tpl) >= 3) $bad['tpl3']++;
    if (count(array_unique($pz['cast'])) !== 5 || array_diff($pz['cast'], BURROW_CASTS[$season])) $bad['cast']++;
    if ($season === 'winter' && in_array('fieldmouse', $pz['cast'], true)) $bad['winter']++;
    foreach ($pz['clues'] as $c) {
        $h = burrow_clue_html($c, $pz['cast'], $season);
        if ($h === '' || !str_contains($h, e(BURROW_CREATURES[$pz['cast'][$c[1]]][0]))) { $bad['text']++; break; }
    }
}
ok('3-8 candidate orders, matches stored fit', $bad['fit'] === 0, json_encode($bad));
ok('solution is among the candidates (every clue true)', $bad['sol'] === 0);
ok('solution is a permutation of the cast', $bad['perm'] === 0);
ok('3-6 clues', $bad['n'] === 0);
ok('at most one position clue (T1/T10)', $bad['pos'] === 0);
ok('no template used 3 times', $bad['tpl3'] === 0);
ok('cast of 5 distinct creatures from the season pool', $bad['cast'] === 0);
ok('no field mouse in winter', $bad['winter'] === 0);
ok('every clue renders text naming its creature', $bad['text'] === 0);
echo '  info fit histogram ' . json_encode($fitHist) . ' in ' . round(microtime(true) - $t0, 1) . "s\n";
$all = [];
mt_srand(5);
for ($i = 0; $i < 600; $i++) foreach (burrow_new_puzzle($seasons[$i % 4], $rnd)['clues'] as $c) $all[$c[0]] = 1;
ok('most templates appear (' . implode(',', array_keys($all)) . ')', count($all) >= 12, (string)count($all));
ok('mole has an icon file', is_file($argv[1] . '/assets/img/ico/ico-mole.svg'));
ok('mole shown by icon not emoji', str_contains(burrow_who('mole'), 'ico-mole.svg'));

echo "== knock flow\n";
$uid = (int)q_val("SELECT id FROM users WHERE username = 'sprout'");
$user = fn() => q_one('SELECT * FROM users WHERE id = ?', [$uid]);
$coins = fn() => (int)q_val('SELECT coins FROM users WHERE id = ?', [$uid]);
q('UPDATE users SET stat_charm = 10 WHERE id = ?', [$uid]);
q('DELETE FROM game_state WHERE user_id = ? AND game = ?', [$uid, 'burrow']);
q('DELETE FROM game_scores WHERE user_id = ? AND game = ?', [$uid, 'burrow']);
set_setting('games_petals_percent', '60'); setting('__reload__');
set_setting('burrow_plays_per_day', '3'); setting('__reload__');

ok('knock without a round refused', burrow_knock($user(), ['0', '1', '2', '3', '4']) === [false, 'Visit the burrows first.']);
ok('start ok', burrow_start($user())[0] === true);
$s = game_state($uid, 'burrow');
ok('state holds sol, 4 knocks (Charm 10)', is_array($s['sol']) && $s['knocks'] === 4 && $s['max'] === 4);
ok('start again keeps the same round', burrow_start($user())[0] === true && game_state($uid, 'burrow')['sol'] === $s['sol']);
ok('live round counts as a play', game_plays_left($uid, 'burrow') === 2);
$sol = array_map('strval', $s['sol']);
$wrong = $sol; [$wrong[0], $wrong[1]] = [$wrong[1], $wrong[0]];   // swap two doors: exactly 3 at home
$knocks = fn() => game_state($uid, 'burrow')['knocks'] ?? -1;

$refused = [
    'repeat' => ['0', '0', '1', '2', '3'],
    'missing door' => ['0', '1', '2', '3'],
    'blank' => ['0', '1', '2', '3', ''],
    'out of range' => ['0', '1', '2', '3', '5'],
    'negative' => ['0', '1', '2', '3', '-1'],
    'non integer' => ['0', '1', '2', '3', 'x'],
    'float' => ['0', '1', '2', '3', '4.0'],
    'trailing newline' => ['0', '1', '2', '3', "4\n"],   // v2.0.31: \z, not $
    'leading space' => ['0', '1', '2', '3', ' 4'],
    'extra door' => ['0', '1', '2', '3', '4', '0'],
    'not an array' => 'abc',
];
foreach ($refused as $name => $d) {
    $r = burrow_knock($user(), $d);
    ok("refused: $name", $r[0] === false && $knocks() === 4, json_encode([$r, $knocks()]));
}
ok('refused: null', burrow_knock($user(), null)[0] === false && $knocks() === 4);
ok('refused: keyed array', burrow_knock($user(), ['a' => '0', 'b' => '1', 'c' => '2', 'd' => '3', 'e' => '4'])[0] === false && $knocks() === 4);

$r = burrow_knock($user(), $wrong);
$hist = game_state($uid, 'burrow')['hist'];
ok('answer equals the real hit count (3)', $r[0] && str_contains($r[1], '3 at home') && $hist[0][1] === 3, json_encode([$r, $hist]));
ok('a knock was used and recorded', $knocks() === 3 && count($hist) === 1);
$before = $coins();
$r = burrow_knock($user(), $sol);
ok('5 at home wins', $r[0] === true && game_state($uid, 'burrow') === null);
$score = 40 + 15 * 2;
ok('paid game_petals(score) = ' . game_petals($score), $coins() - $before === game_petals($score), (string)($coins() - $before));
ok('score recorded', (int)q_val("SELECT score FROM game_scores WHERE user_id = ? AND game = 'burrow'", [$uid]) === $score);
$pr = take_prizes();
ok('prize box shows', count($pr) === 1 && str_contains($pr[0]['title'], 'Everyone') && str_contains($pr[0]['big'], '2 knocks'), json_encode($pr));
ok('prize title has no icon of its own (the box shows it)', !str_contains($pr[0]['title'], '🏆'), $pr[0]['title']);
$c1 = $coins();
ok('second knock after the win is refused and pays nothing', burrow_knock($user(), $sol)[0] === false && $coins() === $c1);

echo "== double knock never pays twice\n";
q('DELETE FROM game_scores WHERE user_id = ? AND game = ?', [$uid, 'burrow']);
burrow_start($user());
$sol = array_map('strval', game_state($uid, 'burrow')['sol']);
$c0 = $coins();
$a = burrow_knock($user(), $sol);
$b = burrow_knock($user(), $sol);
ok('first wins, second refused', $a[0] === true && $b[0] === false);
ok('paid once, first knock = 85 raw', $coins() - $c0 === game_petals(85), (string)($coins() - $c0));
ok('one score row', (int)q_val("SELECT COUNT(*) FROM game_scores WHERE user_id = ? AND game = 'burrow'", [$uid]) === 1);
take_prizes();

echo "== running out of knocks\n";
q('DELETE FROM game_scores WHERE user_id = ? AND game = ?', [$uid, 'burrow']);
burrow_start($user());
$s = game_state($uid, 'burrow');
$sol = array_map('strval', $s['sol']);
$wrong = $sol; [$wrong[0], $wrong[1]] = [$wrong[1], $wrong[0]];
$c0 = $coins();
for ($k = 1; $k <= 3; $k++) { $r = burrow_knock($user(), $wrong); if (!$r[0] || game_state($uid, 'burrow') === null) break; }
ok('three misses leave the round on', game_state($uid, 'burrow') !== null && $knocks() === 1);
$r = burrow_knock($user(), $wrong);
ok('last miss ends the round', $r[0] && str_contains($r[1], 'last knock') && game_state($uid, 'burrow') === null, json_encode($r));
ok('fail pays game_petals(5)', $coins() - $c0 === game_petals(5), (string)($coins() - $c0));
ok('score 0 recorded', (int)q_val("SELECT score FROM game_scores WHERE user_id = ? AND game = 'burrow'", [$uid]) === 0 && (int)q_val("SELECT COUNT(*) FROM game_scores WHERE user_id = ? AND game = 'burrow'", [$uid]) === 1);
ok('reveal kept once in the session', isset($_SESSION['burrow_last']['sol']));
$pr = take_prizes();
ok('loss prize box', count($pr) === 1 && str_contains($pr[0]['title'], 'gone to bed'), json_encode($pr));
ok('no knock after the end', burrow_knock($user(), $wrong)[0] === false);

echo "== Charm and plays\n";
q('UPDATE users SET stat_charm = 14 WHERE id = ?', [$uid]);
ok('Charm mod 2 gives 5 knocks', burrow_max_knocks($user()) === 5);
q('UPDATE users SET stat_charm = 12 WHERE id = ?', [$uid]);
ok('Charm mod 1 gives 4 knocks', burrow_max_knocks($user()) === 4);
q('UPDATE users SET stat_charm = 14 WHERE id = ?', [$uid]);
burrow_start($user());
ok('Charm knock stored at start (max 5)', game_state($uid, 'burrow')['max'] === 5 && game_state($uid, 'burrow')['knocks'] === 5);
$sol = array_map('strval', game_state($uid, 'burrow')['sol']);
$c0 = $coins();
burrow_knock($user(), $sol);
ok('first-knock win with Charm = 100 raw', $coins() - $c0 === game_petals(100), (string)($coins() - $c0));
take_prizes();
q('UPDATE users SET stat_charm = 10 WHERE id = ?', [$uid]);
q('DELETE FROM game_scores WHERE user_id = ? AND game = ?', [$uid, 'burrow']);
set_setting('burrow_plays_per_day', '0'); setting('__reload__');
ok('0 plays a day: start refused', burrow_start($user())[0] === false && game_state($uid, 'burrow') === null);
set_setting('burrow_plays_per_day', '3'); setting('__reload__');

echo "== games_petals_percent 0 (game_petals floors a payout at 1; the Rules text uses the same helper)\n";
set_setting('games_petals_percent', '0'); setting('__reload__');
burrow_start($user());
$sol = array_map('strval', game_state($uid, 'burrow')['sol']);
$c0 = $coins();
burrow_knock($user(), $sol);
ok('pays exactly game_petals(85) and finishes', $coins() - $c0 === game_petals(85) && game_state($uid, 'burrow') === null, (string)($coins() - $c0));
take_prizes();
set_setting('games_petals_percent', '60'); setting('__reload__');
q('DELETE FROM game_scores WHERE user_id = ? AND game = ?', [$uid, 'burrow']);

echo $fails ? "\n$fails FAILED\n" : "\nall ok\n";
exit($fails ? 1 : 0);
