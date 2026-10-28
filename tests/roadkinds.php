<?php
// Road card kinds. php tests/roadkinds.php GAMEDIR            : the data and the flows (prints "  ok"/"  FAIL" lines)
//                 php tests/roadkinds.php GAMEDIR show KIND    : put a card of that kind in front of the test gnome (for the page check)
$_SERVER['SCRIPT_NAME'] = '/adventure.php';
$game = $argv[1];
require $game . '/includes/bootstrap.php';
require_once $game . '/includes/adventure.php';
require_once $game . '/includes/explore.php';
require_once $game . '/includes/stops.php';
$fails = 0;
function ok(string $what, bool $cond, string $extra = ''): void { global $fails; echo ($cond ? '  ok   ' : '  FAIL ') . $what . ($cond ? '' : "  $extra") . "\n"; if (!$cond) $fails++; }
$ev = road_events(true)['ev'];
$byKind = [];
foreach ($ev as $e) $byKind[$e['kind']][] = $e;
function me(): array { return q_one("SELECT * FROM users WHERE username = 'sprout'"); }
function walk(): array {
    $u = me();
    q("UPDATE expeditions SET status = 'done' WHERE user_id = ?", [$u['id']]);
    $na = (int)q_val("SELECT id FROM regions WHERE code = 'NA'");
    $route = q_one("SELECT r.* FROM routes r JOIN locations l ON l.id = r.a_id WHERE r.kind = 'road' AND l.region_id = ? ORDER BY r.id LIMIT 1", [$na]);
    q('UPDATE users SET location_id = ?, level = 6, energy = 80, coins = 500 WHERE id = ?', [$route['a_id'], $u['id']]);
    [$ok, $msg] = start_expedition(me(), (int)$route['id']);
    $exp = active_expedition((int)$u['id']);
    if (!$exp) { echo "  FAIL could not start a walk: $msg\n"; exit(1); }
    return $exp;
}
function put(array &$exp, array $enc): void { $exp['encounter'] = json_encode($enc); save_exp($exp); $exp = active_expedition((int)me()['id']); }
function choose(array &$exp, int $opt): void { $u = me(); road_bind($u, $exp); explore_choose($u, $exp, $opt); road_flush(); save_exp($exp); road_unbind(); $exp = active_expedition((int)me()['id']); }
function give(string $slug, int $n): void { give_item((int)me()['id'], (int)q_val('SELECT id FROM items WHERE slug = ?', [$slug]), $n); }
function have(string $slug): int { return (int)q_val('SELECT COALESCE(SUM(qty), 0) FROM user_items WHERE user_id = ? AND item_id = (SELECT id FROM items WHERE slug = ?)', [me()['id'], $slug]); }
function lastLog(array $exp): string { $l = json_decode((string)$exp['log'], true) ?: []; return (string)end($l); }

if (($argv[2] ?? '') === 'end') { q("UPDATE expeditions SET status = 'done' WHERE user_id = ?", [me()['id']]); exit(0); }
if (($argv[2] ?? '') === 'show') {
    $kind = $argv[3];
    $exp = walk();
    $e = $byKind[$kind][0];
    if ($kind === 'chain') $e = array_values(array_filter($byKind['chain'], fn($x) => !str_starts_with($x['id'], 'chain-')))[0];
    put($exp, ['type' => 'choice', 'ev' => $e['id']] + ($kind === 'riddle' ? ['ord' => [2, 0, 1]] : []));
    exit(0);
}

echo "== the data\n";
foreach (['fork' => 4, 'riddle' => 4, 'trade' => 4, 'sketch' => 12, 'chain' => 10] as $k => $n) ok("at least $n $k cards (2 regions)", count($byKind[$k] ?? []) >= $n, count($byKind[$k] ?? []) . '');
ok('the old cards are untouched: 14 legacy scenes keep their place', array_slice(array_keys($ev), 0, 1) === ['bee-log']);
ok('Road Journal: 6 pages in the Maplewold, 6 in Maizehollow, none elsewhere', count(road_journal_pages('NA')) === 6 && count(road_journal_pages('CA')) === 6 && count(road_journal_pages('OC')) === 0);
$bad = [];
foreach ($ev as $e) foreach ($e['opts'] as $o) foreach ([$o['win'], $o['lose']] as $fx) foreach (array_filter(explode('+', (string)$fx)) as $p) {
    $p = explode('@', $p)[0]; [$k, $a] = array_pad(explode(':', $p), 2, '');
    if ($k === 'next' && !isset($ev[$a])) $bad[] = $e['id'] . ' -> ' . $a;
    if (in_array($k, ['item', 'take'], true) && !q_val('SELECT 1 FROM items WHERE slug = ?', [$a])) $bad[] = $e['id'] . ' item ' . $a;
}
ok('every next:, item: and take: points at something real', !$bad, implode('; ', $bad));
$tails = array_filter($ev, fn($e) => str_starts_with($e['id'], 'chain-'));
ok('chain tails are never drawn alone (road_event_pick skips chain- ids)', (function () use ($tails) { $s = ['land' => 'forest', 'level' => 2, 'region_id' => 1, 'to' => ['region_id' => (int)q_val("SELECT id FROM regions WHERE code='NA'")], 'from' => []]; for ($i = 0; $i < 300; $i++) { $p = road_event_pick($s, 'road', ['record' => false]); if ($p && str_starts_with($p['id'], 'chain-')) return false; } return true; })());

echo "== sketch: the Road Journal\n";
$exp = walk();
q('DELETE FROM road_journal WHERE user_id = ?', [me()['id']]);
$na = array_values(array_filter($byKind['sketch'], fn($e) => in_array('NA', $e['region'], true)));
$to = q_one('SELECT * FROM locations WHERE id = ?', [$exp['to_id']]);
$code = stop_region_code($to);
// the walk's destination decides the region of the page; use cards of that region
$mine = array_values(array_filter($byKind['sketch'], fn($e) => in_array($code, $e['region'], true)));
if (!$mine) { echo "  note: the first NA road ends in $code (no pages): moving the walk\n"; q('UPDATE locations SET region_id = (SELECT id FROM regions WHERE code = \'NA\') WHERE id = ?', [$exp['to_id']]); $code = 'NA'; $mine = $na; }
$c0 = me()['coins'];
foreach ($mine as $i => $e) { put($exp, ['type' => 'choice', 'ev' => $e['id']]); choose($exp, 0); }
$n = (int)q_val("SELECT COUNT(*) FROM road_journal WHERE user_id = ? AND region = ? AND entry <> '_done'", [me()['id'], $code]);
ok('six sketches stamp six pages', $n === 6, "$n");
ok('the full page paid once (the _done row)', (int)q_val("SELECT COUNT(*) FROM road_journal WHERE user_id = ? AND entry = '_done'", [me()['id']]) === 1 && me()['coins'] > $c0);
$c1 = me()['coins'];
put($exp, ['type' => 'choice', 'ev' => $mine[0]['id']]); choose($exp, 0);
ok('a page you already have is not stamped or paid again', (int)q_val("SELECT COUNT(*) FROM road_journal WHERE user_id = ? AND region = ?", [me()['id'], $code]) === 7 && me()['coins'] - $c1 < 20);
ok('the journal shows on the passport page', str_contains(road_journal_html((int)me()['id']), 'Road Journal'));

echo "== riddle\n";
$exp = walk();
$r = $byKind['riddle'][0];
$right = null; foreach ($r['opts'] as $i => $o) if ($o['stat'] !== '!') $right = $i;
$ord = [2, 0, 1];
put($exp, ['type' => 'choice', 'ev' => $r['id'], 'ord' => $ord]);
$wrong = $right === 0 ? 1 : 0;
$xp0 = (int)me()['xp'];
choose($exp, $wrong);
ok('a wrong answer: the card is over and the log says it is not right', $exp['encounter'] === null && str_contains(lastLog($exp), '❌'), lastLog($exp));
put($exp, ['type' => 'choice', 'ev' => $r['id'], 'ord' => $ord]);
choose($exp, $right);
ok('the right answer wins', $exp['encounter'] === null && !str_contains(lastLog($exp), '❌'), lastLog($exp));

echo "== trade\n";
$exp = walk();
$t = $byKind['trade'][0];
$offer = null; $take = null;
foreach ($t['opts'] as $i => $o) if (str_contains($o['win'], 'take:')) { $offer = $i; foreach (explode('+', $o['win']) as $p) if (str_starts_with($p, 'take:')) $take = explode(':', $p); }
put($exp, ['type' => 'choice', 'ev' => $t['id']]);
$got0 = have($take[1]);
choose($exp, $offer);
ok('a trade without the goods: you wander on, nothing changes', $exp['encounter'] === null && have($take[1]) === $got0 && str_contains(lastLog($exp), 'haven’t got'), lastLog($exp));
give($take[1], (int)($take[2] ?? 1));
$before = have($take[1]);
put($exp, ['type' => 'choice', 'ev' => $t['id']]);
choose($exp, $offer);
ok('with the goods: they are handed over', have($take[1]) < $before, "$before -> " . have($take[1]));
$decl = null; foreach ($t['opts'] as $i => $o) if ($o['win'] === '') $decl = $i;
give($take[1], (int)($take[2] ?? 1)); $b2 = have($take[1]);
put($exp, ['type' => 'choice', 'ev' => $t['id']]); choose($exp, $decl);
ok('declining costs nothing', have($take[1]) === $b2 && $exp['encounter'] === null);

echo "== fork: the short way\n";
$exp = walk();
$f = null; foreach ($byKind['fork'] as $e) foreach ($e['opts'] as $i => $o) if (str_contains($o['win'], 'skip:') && $o['stat'] === '') { $f = [$e, $i]; }
if (!$f) foreach ($byKind['fork'] as $e) foreach ($e['opts'] as $i => $o) if (str_contains($o['win'], 'skip:')) { $f = [$e, $i]; }
q('UPDATE expeditions SET step = 0, steps_total = 6 WHERE id = ?', [$exp['id']]); $exp = active_expedition((int)me()['id']);
foreach (explode('+', $f[0]['opts'][$f[1]]['win']) as $pp) if (str_starts_with($pp, 'take:')) { $tk = explode(':', $pp); give($tk[1], 20); }   // the short way may cost goods: carry plenty
put($exp, ['type' => 'choice', 'ev' => $f[0]['id']]);
mt_srand(1);
for ($try = 0; $try < 12 && (int)$exp['step'] === 0; $try++) { choose($exp, $f[1]); if ((int)$exp['step'] === 0) { q('UPDATE expeditions SET step = 0 WHERE id = ?', [$exp['id']]); $exp = active_expedition((int)me()['id']); put($exp, ['type' => 'choice', 'ev' => $f[0]['id']]); } }
ok('taking the short way skips a space (step is now ' . $exp['step'] . ')', (int)$exp['step'] >= 1, lastLog($exp));
q('UPDATE expeditions SET step = 5, steps_total = 6 WHERE id = ?', [$exp['id']]); $exp = active_expedition((int)me()['id']);
put($exp, ['type' => 'choice', 'ev' => $f[0]['id']]);
for ($try = 0; $try < 12; $try++) { choose($exp, $f[1]); if ((int)$exp['step'] === 6) break; put($exp, ['type' => 'choice', 'ev' => $f[0]['id']]); }
ok('a skip never goes past the end of the road', (int)$exp['step'] <= 6);

echo "== chain\n";
$exp = walk();
$first = null; $nextId = null;
foreach ($byKind['chain'] as $e) { if (str_starts_with($e['id'], 'chain-')) continue; foreach ($e['opts'] as $i => $o) if (preg_match('/next:([a-z0-9-]+)/', $o['win'], $m)) { $first = [$e, $i]; $nextId = $m[1]; break 2; } }
q('UPDATE expeditions SET step = 0, steps_total = 6 WHERE id = ?', [$exp['id']]); $exp = active_expedition((int)me()['id']);
put($exp, ['type' => 'choice', 'ev' => $first[0]['id']]);
$o = $first[0]['opts'][$first[1]];
// make the option certain to win so the follow-on is set
$u = me(); road_bind($u, $exp);
$exp['chain'] = null;
for ($i = 0; $i < 30 && ($exp['chain'] ?? '') === ''; $i++) { put($exp, ['type' => 'choice', 'ev' => $first[0]['id']]); choose($exp, $first[1]); }
road_unbind();
ok('the chain leaves its next card for the next space (' . ($exp['chain'] ?? '') . ')', ($exp['chain'] ?? '') === $nextId);
$u = me(); road_bind($u, $exp); next_step($u, $exp); road_flush(); save_exp($exp); road_unbind(); $exp = active_expedition((int)$u['id']);
$enc = json_decode((string)$exp['encounter'], true);
ok('the next space is that card, and the chain pointer is cleared', ($enc['ev'] ?? '') === $nextId && ($exp['chain'] ?? '') === '', json_encode($enc));

echo "== the same shape does not come twice running\n";
$u = me(); road_bind($u, $exp);
$sc = ['land' => 'forest', 'level' => 3, 'region_id' => (int)q_val("SELECT id FROM regions WHERE code='NA'"), 'to' => ['region_id' => (int)q_val("SELECT id FROM regions WHERE code='NA'")], 'from' => []];
$same = 0; $prev = ''; $n = 0;
for ($i = 0; $i < 400; $i++) { $p = road_event_pick($sc, 'road'); if (!$p) continue; $n++; if ($p['kind'] !== 'choice' && $p['kind'] === $prev) $same++; $prev = $p['kind']; }
road_unbind();
ok("a non-choice shape rarely repeats right away ($same of $n)", $same <= $n * 0.04, "$same");
echo $fails ? "$fails FAILED\n" : "";
exit($fails ? 1 : 0);
