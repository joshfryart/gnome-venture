<?php
// 2.7.08 Trail Sights: the per-walk cap (setting sights_walk_cap), destination conditions (to=), market day (mk=), {cond} line variants,
// hint=tide / hint=moon, a take= with a ?condition, the to= lint, and the weak rows upgraded in the data (streak / tally / title / {cond} lines).
// php tests/trail_sights_278.php GAME_DIR   (an installed game, player "sprout"; walk.sh installs one). Route 240 section 1 has the clover patch (as trail_sights_270.php).
$_SERVER['SCRIPT_NAME'] = '/adventure.php';
require $argv[1] . '/includes/bootstrap.php';
require_once $argv[1] . '/includes/adventure.php';
require_once $argv[1] . '/includes/trail_tiles.php';
require_once $argv[1] . '/includes/trail_sights.php';
require_once $argv[1] . '/includes/tools.php';
$fails = 0;
set_setting('npc_clockwork', '0');
$GLOBALS['gv_sights_nocache'] = true;
set_exception_handler(function (Throwable $e) { echo '  EXCEPTION ' . get_class($e) . ': ' . $e->getMessage() . ' @ ' . basename($e->getFile()) . ':' . $e->getLine() . "\n"; exit(1); });
function ok(string $what, bool $cond, string $extra = ''): void { global $fails; echo ($cond ? '  ok   ' : '  FAIL ') . $what . ($cond ? '' : "  $extra") . "\n"; if (!$cond) $fails++; }
$all = trail_sights_all(); $base = $all['grassland-the-clover-patch'];

echo "== settings\n";
ok('sights_walk_cap is a setting next to sights_reward_pct, default 6', isset(settings_schema()['sights_walk_cap']) && settings_schema()['sights_walk_cap']['default'] === '6' && (string)setting('sights_walk_cap') === '6', json_encode(settings_schema()['sights_walk_cap'] ?? null));

echo "== conditions: to= (where the walk leads) and mk= (market day)\n";
$now = ['to' => ['lm-ca-1-haven-market-of-a-thousand-chilies', 'haven', 'grassland'], 'mk' => 'no'];
ok('to= matches the destination slug, kind or land; any one value', trail_sight_cond_ok('to=haven', $now) && trail_sight_cond_ok('to=lair,grassland', $now) && trail_sight_cond_ok('to=lm-ca-1-haven-market-of-a-thousand-chilies', $now));
ok('to= fails for another place and with no walk', !trail_sight_cond_ok('to=lair', $now) && !trail_sight_cond_ok('to=haven', ['to' => []]) && !trail_sight_cond_ok('to=haven', []));
ok('mk=yes only on market day, mk=no otherwise', trail_sight_cond_ok('mk=no', $now) && !trail_sight_cond_ok('mk=yes', $now) && trail_sight_cond_ok('mk=yes', ['mk' => 'yes']));
ok('the card text says them', str_contains(trail_sight_cond_text('to=haven'), 'on the way to haven') && trail_sight_cond_text('mk=yes') === 'on market day', trail_sight_cond_text('to=haven') . ' / ' . trail_sight_cond_text('mk=yes'));
ok('trail_sight_now fills mk', in_array(trail_sight_now([], null, null)['mk'] ?? '', ['yes', 'no'], true));

echo "== {cond} line variants\n";
$line = 'Plain one. // {to=haven}Haven line. // {to=lair}Lair line.';
$seen = []; for ($i = 0; $i < 40; $i++) $seen[trail_sight_line($line, ['to' => ['haven']])] = 1;
ok('a matching {cond} variant wins over the plain ones', array_keys($seen) === ['Haven line.'], json_encode(array_keys($seen)));
$seen = []; for ($i = 0; $i < 40; $i++) $seen[trail_sight_line($line, ['to' => ['wonder']])] = 1;
ok('none matching: the plain variant shows', array_keys($seen) === ['Plain one.'], json_encode(array_keys($seen)));
$seen = []; for ($i = 0; $i < 40; $i++) $seen[trail_sight_line($line)] = 1;
ok('no conditions known: the plain variant shows, never a {cond} one', array_keys($seen) === ['Plain one.'], json_encode(array_keys($seen)));
ok('only {cond} variants and none hold: the first, without its braces', trail_sight_line('{to=lair}Lair line.', ['to' => ['haven']]) === 'Lair line.');
$lb = fn(array $chg) => array_values(array_filter(trail_sight_lint($chg + $base), fn($p) => str_contains($p, 'line') || str_contains($p, 'to=')));
ok('lint: a good {cond} line is clean, a bad condition or stray braces are refused', !$lb(['win' => 'A. // {dp=night}B.']) && (bool)$lb(['win' => 'A. // {bogus=1}B.']) && (bool)$lb(['win' => 'A {x} B.']), json_encode([$lb(['win' => 'A. // {bogus=1}B.']), $lb(['win' => 'A {x} B.'])]));
ok('lint: to= must name a real place slug, kind or land', !$lb(['win' => 'A. // {to=haven}B.']) && !$lb(['win' => 'A. // {to=lm-ca-1-haven-market-of-a-thousand-chilies}B.']) && (bool)$lb(['win' => 'A. // {to=no-such-place}B.']) && (bool)array_filter(trail_sight_lint(['when' => 'to=nowhere-at-all'] + $base), fn($p) => str_contains($p, 'to=')));

echo "== hints: tide and moon\n";
$ht = trail_sight_hint([], [], 'tide'); $hm = trail_sight_hint([], [], 'moon');
ok('hint=tide says the true tide (moon_tide text)', str_contains($ht, 'tide') && str_starts_with($ht, '🌊'), $ht);
ok('hint=moon names the phase', (bool)preg_match('/The moon is a (new moon|waxing crescent|first quarter|waxing gibbous|full moon|waning gibbous|last quarter|waning crescent) tonight/', $hm), $hm);
ok('lint takes hint=tide and hint=moon, refuses an unknown kind', !array_filter(trail_sight_lint(['rewards' => 'hint=tide,hint=moon'] + $base), fn($p) => str_contains($p, 'hint')) && (bool)array_filter(trail_sight_lint(['rewards' => 'hint=snores'] + $base), fn($p) => str_contains($p, 'hint')));
ok('lint takes take= with a ?condition but not with first: or a chance', !array_filter(trail_sight_lint(['rewards' => 'take=garden-honey:1?dp=night,xp=1:1'] + $base), fn($p) => str_contains($p, 'take=')) && (bool)array_filter(trail_sight_lint(['rewards' => 'first:take=garden-honey:1'] + $base), fn($p) => str_contains($p, 'take=')));

echo "== a walk on route 240, standing at the clover patch\n";
set_setting('gnav_on', '1'); set_setting('gnav_tiles', '1'); set_setting('game_clock_on', '1'); setting('__reload__');
$u = q_one("SELECT * FROM users WHERE username = 'sprout'");
q("UPDATE expeditions SET status = 'done' WHERE user_id = ?", [$u['id']]);
q("UPDATE routes SET kind = 'road' WHERE id = 240");
$r = q_one('SELECT * FROM routes WHERE id = 240');
q("UPDATE users SET location_id = ?, level = 30, energy = 90, coins = 500, ev_quickwalk = 0, game_day = 10, game_minute = 360 WHERE id = ?", [$r['a_id'], $u['id']]);
q('DELETE FROM trail_sight_uses WHERE user_id = ?', [$u['id']]);
$u = q_one('SELECT * FROM users WHERE id = ?', [$u['id']]);
[$sok] = start_expedition($u, 240); ok('the walk starts', $sok);
$exp = active_expedition((int)$u['id']); $sc = trail_scene($exp);
$lm = array_values(array_filter($sc['map']['art']['objs'], fn($o) => $o[2] === 'lm-grassland-the-clover-patch'));
$spot = null; foreach ([[-1, 0], [1, 0], [0, -1], [0, 1], [0, 0]] as [$dx, $dy]) if (in_array(tm_tile($sc['map'], $lm[0][0] + $dx, $lm[0][1] + $dy), ['.', ',', 'S'], true)) { $spot = [$lm[0][0] + $dx, $lm[0][1] + $dy]; break; }
$sc['x'] = $spot[0]; $sc['y'] = $spot[1]; trail_save($sc);
trail_sights_ensure_tables();
$put = function (array $chg) use ($base) {
    $r = $chg + $base; q('DELETE FROM trail_sight_rows WHERE slug = ?', [$base['slug']]);
    db_insert('trail_sight_rows', ['slug' => $base['slug'], 'verb' => $r['verb'], 'icon' => $r['icon'], 'energy' => $r['energy'], 'cd' => $r['cd'], 'uses' => $r['uses'], 'cond' => $r['when'], 'chk' => $r['check'], 'rewards' => $r['rewards'], 'win' => $r['win'], 'lose' => $r['lose'], 'tool' => $r['tool'], 'fail_en' => $r['fail_en'], 'active' => 1]);
    q('DELETE FROM trail_sight_uses'); $GLOBALS['gv_sights_reload'] = true; trail_sights_all();
};
$fresh = function () use (&$u, &$exp) { $u = q_one('SELECT * FROM users WHERE id = ?', [$u['id']]); $exp = active_expedition((int)$u['id']); $GLOBALS['gv_sights_reload'] = true; };
$go = function (array $opt = []) use (&$u, &$exp, $base) { $x = trail_sight_do($u, $exp, $base['slug'], $opt); save_exp($exp); return $x; };
$dest = q_one('SELECT slug, kind, landscape FROM locations WHERE id = ?', [(int)$exp['to_id']]);
$now = trail_sight_now(q_one('SELECT * FROM locations WHERE id = ?', [(int)$exp['from_id']]), $sc, $u);
ok('on a walk, to= knows the destination (slug, kind, land)', in_array($dest['slug'], $now['to'], true) && in_array($dest['kind'], $now['to'], true), json_encode([$now['to'], $dest]));

echo "== a destination line in the walk log\n";
q('DELETE FROM trail_sight_tally WHERE user_id = ?', [$u['id']]);
$put(['when' => '-', 'energy' => 0, 'check' => '-', 'rewards' => 'xp=1:1', 'win' => 'Plain words. // {to=' . $dest['slug'] . '}Words for this very place.']); $fresh();
[$a] = $go(); $log = json_decode((string)q_val('SELECT log FROM expeditions WHERE id = ?', [$exp['id']]), true) ?: [];
$last = is_array($log) ? (string)json_encode(array_slice($log, -3)) : '';
ok('the use logs the line for the walk\'s destination', $a && str_contains($last, 'Words for this very place') && !str_contains($last, 'Plain words'), $last);

echo "== take= with a ?condition\n";
$hid = (int)q_val("SELECT id FROM items WHERE slug = 'garden-honey'"); q('DELETE FROM user_items WHERE user_id = ? AND item_id = ?', [$u['id'], $hid]);
$put(['when' => '-', 'energy' => 0, 'check' => '-', 'rewards' => 'take=garden-honey:1?to=no-such-kind,xp=1:1']); $fresh();
[$a, $m] = $go(); ok('a take whose condition does not hold costs nothing and is not needed', $a, (string)$m);
$put(['when' => '-', 'energy' => 0, 'check' => '-', 'rewards' => 'take=garden-honey:1?to=' . $dest['kind'] . ',xp=1:1']); $fresh();
[$a, $m] = $go(); ok('a take whose condition holds is needed', !$a && str_contains((string)$m, 'You need'), (string)$m);
give_item((int)$u['id'], $hid, 2); $put(['when' => '-', 'energy' => 0, 'check' => '-', 'rewards' => 'take=garden-honey:1?to=' . $dest['kind'] . ',xp=1:1']); $fresh();
[$a] = $go(); ok('... and used up on a win', $a && (int)q_val('SELECT qty FROM user_items WHERE user_id = ? AND item_id = ?', [$u['id'], $hid]) === 1);
q('DELETE FROM user_items WHERE user_id = ? AND item_id = ?', [$u['id'], $hid]);

echo "== the per-walk cap (sights_walk_cap)\n";
set_setting('sights_walk_cap', '3'); setting('__reload__');
q('DELETE FROM trail_sight_tally WHERE user_id = ?', [$u['id']]);
$put(['when' => '-', 'energy' => 0, 'check' => '-', 'uses' => 9, 'rewards' => 'xp=1:1']); $fresh();
$res = []; for ($i = 0; $i < 4; $i++) { [$a, $m] = $go(); $res[] = $a; $fresh(); }
ok('cap 3: three uses work on this walk, the fourth is refused', $res === [true, true, true, false], json_encode($res));
[$a, $m] = $go(); ok('the refusal says the walk\'s cap', !$a && str_contains((string)$m, '3 Sights on this walk'), (string)$m);
$sc = trail_scene($exp); $marks = trail_sights_marks_build($u, $sc);
$html = trail_sights_cards_html($u, $sc, array_values(array_filter($marks, fn($mk) => $mk['slug'] === $base['slug'])), $exp);
ok('the Sights card shows it as done for this walk', str_contains($html, 'Sights this walk') && str_contains($html, 'disabled'), substr(strip_tags($html), 0, 300));
ok('the count belongs to this walk only (another walk starts at 0)', trail_sight_walk_uses((int)$u['id'], (int)$exp['id']) === 3 && trail_sight_walk_uses((int)$u['id'], (int)$exp['id'] + 1) === 0);
set_setting('sights_walk_cap', '0'); setting('__reload__'); $fresh();
[$a] = $go(); ok('cap 0 = off: the Sight works again', $a);
set_setting('sights_walk_cap', '6'); setting('__reload__');
trail_sight_tally_set((int)$u['id'], 'walk#id', (int)$exp['id']); trail_sight_tally_set((int)$u['id'], 'walk#n', 2); $fresh();
[$a] = $go(); ok('each use counts toward the walk cap (2 + 1 = 3)', $a && trail_sight_walk_uses((int)$u['id'], (int)$exp['id']) === 3);
q('DELETE FROM trail_sight_rows WHERE slug = ?', [$base['slug']]);

echo "== the weak rows (2.7.08 data pass)\n";
$all = trail_sights_file();
foreach (['forest-the-glow-moss-grotto', 'mountain-the-echo-wall', 'desert-the-mirage-pool', 'end-wonder-2-forest', 'end-haven-2-grassland', 'end-lair-1-mountain', '311-taprow', '236-beanpoles', '316-starstones'] as $sl) {
    $rw = $all[$sl] ?? null;
    $kinds = $rw ? array_unique(array_map(fn($t) => explode('=', $t['tok'])[0], trail_sight_tokens($rw['rewards']))) : [];
    $extras = count(array_intersect($kinds, ['streak', 'tally', 'title', 'hint', 'buff']));
    $condLines = $rw ? preg_match_all('/(^| \/\/ )\{[^}]+\}/', $rw['win']) : 0;
    ok("$sl: at least three of streak / tally / title / hint / buff, and {cond} win lines", $rw && $extras >= 3 && $condLines >= 2 && !trail_sight_lint($rw), json_encode([$kinds, $condLines, $rw ? trail_sight_lint($rw) : 'missing']));
}
foreach (['end-wonder-2-forest' => 5, 'end-haven-2-grassland' => 5, 'end-lair-1-mountain' => 2] as $sl => $n)
    ok("$sl has a line for each of its $n destinations", preg_match_all('/\{to=lm-[a-z0-9-]+\}/', $all[$sl]['win']) >= $n);

echo $fails ? "$fails FAILED\n" : "ok\n";
exit($fails ? 1 : 0);
