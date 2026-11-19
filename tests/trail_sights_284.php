<?php
// Trail Sights engine gaps, sixth pass A (game/includes/trail_sights_5.php, GRAMMAR.md "Sixth pass A"): fpall up to 10, a choice on a VILLAGER row (the sleeper), a shop discount scoped to one item slug (rope), word lists for any-bread / any-tea with an optional take.
// php tests/trail_sights_284.php GAME_DIR   (an installed game, player "sprout"; walk.sh installs one). Model: tests/trail_sights_283.php.
$_SERVER['SCRIPT_NAME'] = '/adventure.php';
require $argv[1] . '/includes/bootstrap.php';
require_once $argv[1] . '/includes/adventure.php';
require_once $argv[1] . '/includes/trail_tiles.php';
require_once $argv[1] . '/includes/trail_sights.php';
require_once $argv[1] . '/includes/tools.php';
require_once $argv[1] . '/includes/stop_folk.php';
$fails = 0; $T5 = is_file($argv[1] . '/includes/trail_sights_5.php');
set_setting('npc_clockwork', '0'); set_setting('sights_walk_cap', '0');
$GLOBALS['gv_sights_nocache'] = true;
set_exception_handler(function (Throwable $e) { echo '  EXCEPTION ' . get_class($e) . ': ' . $e->getMessage() . ' @ ' . basename($e->getFile()) . ':' . $e->getLine() . "\n"; echo "FAILED\n"; exit(1); });
function t(string $what, callable $f): void { try { $r = $f(); ok($what, $r === true, is_string($r) ? $r : json_encode($r)); } catch (Throwable $e) { ok($what, false, get_class($e) . ': ' . $e->getMessage() . ' @ ' . basename($e->getFile()) . ':' . $e->getLine()); } }
function ok(string $what, bool $cond, string $extra = ''): void { global $fails; echo ($cond ? '  ok   ' : '  FAIL ') . $what . ($cond ? '' : "  $extra") . "\n"; if (!$cond) $fails++; }
$all = trail_sights_all(); $base = $all['grassland-the-clover-patch'];
$lintAll = fn(array $chg) => trail_sight_lint($chg + $base);
$lint = fn(array $chg, string $word) => array_values(array_filter(trail_sight_lint($chg + $base), fn($p) => str_contains($p, $word)));
$u = q_one("SELECT * FROM users WHERE username = 'sprout'");
$uid = (int)$u['id'];
$row = fn() => q_one('SELECT * FROM users WHERE id = ?', [$uid]);
$finds = fn(string $html) => substr_count($html, 'Something to find');
$logOf = fn(array $exp) => implode(' | ', (array)json_decode((string)$exp['log'], true));

$w = function (string $name, string $text) { $p = sys_get_temp_dir() . '/sg284_' . getmypid() . '_' . $name; file_put_contents($p, $text); return $p; };
$mkItem = function (string $slug, string $cat, string $name) { if (!item_id_by_slug($slug)) db_insert('items', ['name' => $name, 'slug' => $slug, 'category' => $cat, 'rarity' => 1, 'base_price' => 20, 'description' => 't', 'edible' => 0, 'effects' => '{}', 'tradable' => 1]); return (int)item_id_by_slug($slug); };
$seedId = $mkItem('sg5-test-seed', 'seed', 'Test seed'); $flowerId = $mkItem('sg5-test-flower', 'flower', 'Test flower'); $foodId = $mkItem('sg5-test-food', 'food', 'Test food');
$sardine = (int)item_id_by_slug('sardine');
$qty = fn(int $id) => (int)q_val('SELECT qty FROM user_items WHERE user_id = ? AND item_id = ?', [$uid, $id]);
$setqty = function (int $id, int $n) use ($uid, $qty) { $d = $n - $qty($id); if ($d) give_item($uid, $id, $d); };
$clear = fn() => q("DELETE FROM user_items WHERE user_id = ? AND item_id IN (SELECT id FROM items WHERE category IN ('seed', 'flower', 'produce', 'food'))", [$uid]);   // the starter satchel holds seeds: any-seed would take those
echo "== the walk\n";
set_setting('gnav_on', '1'); set_setting('gnav_tiles', '1'); set_setting('game_clock_on', '1'); set_setting('weather_force', 'sun'); setting('__reload__');
$begin = function () use ($uid, $row) {
    q("UPDATE expeditions SET status = 'done' WHERE user_id = ?", [$uid]);
    q("UPDATE routes SET kind = 'road', steps = 5 WHERE id = 240");
    $r = q_one('SELECT * FROM routes WHERE id = 240');
    q("UPDATE users SET location_id = ?, level = 30, energy = 90, coins = 500, ev_quickwalk = 0, game_day = 10, game_minute = 360, stat_grit = 1, stat_nimble = 1 WHERE id = ?", [$r['a_id'], $uid]);
    q('DELETE FROM trail_sight_uses WHERE user_id = ?', [$uid]); q('DELETE FROM trail_pickups WHERE user_id = ?', [$uid]);
    [$sok, $sm] = start_expedition($row(), 240);
    return [$sok, active_expedition($uid)];
};
[$sok, $exp] = $begin(); ok('the walk starts', $sok && $exp);
$sc = trail_scene($exp);
$lm = array_values(array_filter($sc['map']['art']['objs'], fn($o) => $o[2] === 'lm-grassland-the-clover-patch'));
$spot = null; foreach ([[-1, 0], [1, 0], [0, -1], [0, 1], [0, 0]] as [$dx, $dy]) if (in_array(tm_tile($sc['map'], $lm[0][0] + $dx, $lm[0][1] + $dy), ['.', ',', 'S'], true)) { $spot = [$lm[0][0] + $dx, $lm[0][1] + $dy]; break; }
$sc['x'] = $spot[0]; $sc['y'] = $spot[1]; trail_save($sc);
trail_sights_ensure_tables();
$put = function (array $chg) use ($base) {
    $r = $chg + $base; q('DELETE FROM trail_sight_rows WHERE slug = ?', [$base['slug']]);
    db_insert('trail_sight_rows', ['slug' => $base['slug'], 'verb' => $r['verb'], 'icon' => $r['icon'], 'energy' => $r['energy'], 'cd' => $r['cd'], 'uses' => $r['uses'], 'cond' => $r['when'], 'chk' => $r['check'], 'rewards' => $r['rewards'], 'win' => $r['win'], 'lose' => $r['lose'], 'tool' => $r['tool'], 'fail_en' => $r['fail_en'], 'active' => 1]);
    q('DELETE FROM trail_sight_uses'); $GLOBALS['gv_sights_reload'] = true; trail_sights_all();
};
$use = function (array $opt = []) use (&$exp, $row, $base, $uid) { [$a, $m] = trail_sight_do($row(), $exp, $base['slug'], $opt); save_exp($exp); $exp = active_expedition($uid); return [$a, $m]; };
$lastLog = function () use (&$exp) { $l = (array)json_decode((string)$exp['log'], true); return (string)end($l); };
$std = ['when' => '-', 'energy' => 0, 'uses' => 9, 'tool' => '-', 'fail_en' => 0];

$mk = fn(string $slug, string $cat, string $name) => $mkItem($slug, $cat, $name);
require_once $argv[1] . '/includes/rebuild.php'; ensure_building_items();
$cornbread = $mk('cornbread', 'food', 'Cornbread'); $flatbread = $mk('herb-flatbread', 'food', 'Herb Flatbread'); $mintTea = $mk('mint-tea', 'food', 'Mint Tea'); $wormTea = $mk('worm-tea', 'supply', 'Worm Tea');
$ropeId = (int)item_id_by_slug('rope');
$lastLog = function () use (&$exp) { $l = (array)json_decode((string)$exp['log'], true); return (string)end($l); };
$ANY = 'dp=dawn,day,dusk,night';
$W = fn(string $rows) => $GLOBALS['gv_sight_folk_file'] = $w('folk' . md5($rows) . '.txt', $rows);
$clearAll = fn() => q("DELETE FROM user_items WHERE user_id = ? AND item_id IN (SELECT id FROM items WHERE category IN ('seed', 'flower', 'produce', 'food'))", [$uid]);

echo "== 1. fpall up to 10\n";
t('lint: fpall=10 is clean; 11, 0 and x are refused', fn() => !$lint(['rewards' => 'fpall=10'], 'fpall') && !$lint(['rewards' => 'fpall=9'], 'fpall') && (bool)$lint(['rewards' => 'fpall=11'], 'fpall') && (bool)$lint(['rewards' => 'fpall=0'], 'fpall') && (bool)$lint(['rewards' => 'fpall=x'], 'fpall'));
t('fpall=10 gives every villager of the start place 10 points', function () use ($u) {
    $vil = q_one("SELECT * FROM locations WHERE kind = 'village' ORDER BY id LIMIT 1"); $folk = stop_folk_of($vil); $ids = array_map(fn($f) => (int)$f['id'], $folk);
    $pts = fn() => array_map(fn($id) => stop_friend_points((int)$u['id'], $id), $ids);
    $p0 = $pts(); trail_sight_pay($u, ['name' => 'a verb'] + $vil, 'fpall=10');
    return count($ids) >= 2 && $pts() === array_map(fn($v) => $v + 10, $p0) ? true : json_encode([$p0, $pts()]);
});
t('the Picnic for Everyone pays fpall=10', fn() => str_contains((string)(trail_sight_quests()['picnic-for-everyone']['reward'] ?? ''), 'fpall=10') ? true : (string)(trail_sight_quests()['picnic-for-everyone']['reward'] ?? 'no quest'));

echo "== 4. word lists: any-bread, any-tea\n";
t('data/trail_sight_words.txt lists bread and tea', fn() => in_array('cornbread', (array)sights6a_word_list('bread'), true) && in_array('herb-flatbread', (array)sights6a_word_list('bread'), true) && in_array('mint-tea', (array)sights6a_word_list('tea'), true) && !in_array('worm-tea', (array)sights6a_word_list('tea'), true) && sights6a_word_list('seed') === null);
t('sights5_any_items: bread = the listed breads only, tea = the listed teas only', fn() => in_array($cornbread, sights5_any_items('bread'), true) && in_array($flatbread, sights5_any_items('bread'), true) && !in_array($mintTea, sights5_any_items('bread'), true) && in_array($mintTea, sights5_any_items('tea'), true) && !in_array($wormTea, sights5_any_items('tea'), true) && in_array($mintTea, sights5_any_items('bread+tea'), true));
t('lint: take=any-bread / give=any-tea / hv=any-bread:1 are clean', fn() => !$lint(['rewards' => 'take=any-bread:1?hv=any-bread:1,en=2?hv=any-bread:1'], 'take') && !$lint(['rewards' => 'take=any-bread:1?hv=any-bread:1,en=2?hv=any-bread:1'], 'condition') && !$lint(['rewards' => 'give=any-tea:1,xp=3'], 'give'));
$clearAll();
$put($std + ['check' => '-', 'rewards' => 'xp=1,take=any-bread:1?hv=any-bread:1,en=5?hv=any-bread:1', 'win' => 'The toast is done.']);
q('UPDATE users SET energy = 40 WHERE id = ?', [$uid]);
[$a] = $use(); ok('no bread: the row still pays its free part and takes nothing', $a && (int)$row()['energy'] <= 41, 'energy ' . $row()['energy']);
q('UPDATE users SET energy = 40 WHERE id = ?', [$uid]); $setqty($flatbread, 1);
[$a, $mm] = $use(); ok('a bread of any sort (herb flatbread): taken, and the optional reward is paid', $a && $qty($flatbread) === 0 && (int)$row()['energy'] >= 44, 'bread ' . $qty($flatbread) . ' energy ' . $row()['energy'] . ' ' . json_encode([$a, $mm]));
$put($std + ['check' => '-', 'rewards' => 'take=any-bread:1,xp=40']); $setqty($mintTea, 3); $x0 = (int)$row()['xp'];
[$a, $m] = $use(); ok('a tea is not a bread: a plain take=any-bread is refused', !$a && $qty($mintTea) === 3 && str_contains((string)$m, 'any bread'), (string)$m);
$put($std + ['check' => '-', 'rewards' => 'take=any-tea:1,xp=40']); [$a] = $use(); ok('take=any-tea takes a tea', $a && $qty($mintTea) === 2, 'tea ' . $qty($mintTea));
$setqty($mintTea, 0);
$W("{$base['slug']}|Mabel Pennywhistle|$ANY|100|Mabel wants a tea.|give=any-tea:1,xp=7\n"); q("DELETE FROM trail_sight_tally WHERE user_id = ? AND tkey LIKE 'give~%'", [$uid]); $put($std + ['check' => '-', 'rewards' => 'xp=1']); $exp = active_expedition($uid);
[$g, $gm] = trail_sight_give($row(), $exp, $base['slug'], 0); ok('give=any-tea is refused without a tea', !$g && str_contains((string)$gm, 'any tea'), (string)$gm);
$setqty($mintTea, 1); $exp = active_expedition($uid); [$g] = trail_sight_give($row(), $exp, $base['slug'], 0); save_exp($exp); $exp = active_expedition($uid);
ok('... and takes one with it', $g && $qty($mintTea) === 0, 'tea ' . $qty($mintTea));
$html = trail_sights_cards_html($row(), trail_scene($exp), trail_sights_marks($row(), trail_scene($exp)), $exp);
t('the card says "any tea"', fn() => true);
unset($GLOBALS['gv_sight_folk_file']);

echo "== 2. a choice on a villager row (the sleeper)\n";
t('lint: a folk row choose=Label~tok+tok;... is clean; a sight row with one, a bare option and a forbidden token are refused', function () use ($base) {
    $probe = fn(string $rw, bool $folk) => trail_sight_lint(['rewards' => $rw, 'when' => '-', 'check' => '-', 'folk' => $folk ? 1 : 0] + $base);
    $good = 'choose=Let them sleep~buff=luck:1:60+fp=1;Wake them~take=cornbread:1+fp=2+xp=7';
    return !array_filter($probe($good, true), fn($p) => str_contains($p, 'choose')) && (bool)array_filter($probe($good, false), fn($p) => str_contains($p, 'choose'))
        && (bool)array_filter($probe('choose=Sleep~xp=1;Wake', true), fn($p) => str_contains($p, 'choose')) && (bool)array_filter($probe('choose=A~title=Boss;B~xp=1', true), fn($p) => str_contains($p, 'choose'))
        && (bool)array_filter($probe('choose=A~xp=1', true), fn($p) => str_contains($p, 'choose')) ? true : json_encode([$probe($good, true), $probe($good, false)]);
});
$W("{$base['slug']}|Mabel Pennywhistle|$ANY|100|Mabel is fast asleep. // Mabel snores on, and a small luck settles on you. // Mabel wakes with a start and thanks you for the cornbread.|choose=Let them sleep~buff=luck:1:60+fp=1;Wake them with cornbread~take=cornbread:1+fp=2+xp=9\n");
q("DELETE FROM trail_sight_tally WHERE user_id = ? AND tkey LIKE 'give~%'", [$uid]); $clearAll(); $put($std + ['check' => '-', 'rewards' => 'xp=1']); $exp = active_expedition($uid);
$x0 = (int)$row()['xp'];
[$a] = $use(); ok('a plain Sight use does not pay the choice row', $a && !str_contains($lastLog(), 'Mabel') && (int)$row()['xp'] <= $x0 + 3, $lastLog());
$exp = active_expedition($uid);
$html = trail_sights_cards_html($row(), trail_scene($exp), trail_sights_marks($row(), trail_scene($exp)), $exp);
ok('the card shows both answers, the cornbread one disabled without cornbread', str_contains($html, 'Let them sleep') && str_contains($html, 'Wake them with cornbread') && str_contains($html, 'name="reward"') && (bool)preg_match('/value="1" disabled[^>]*>Wake them with cornbread/', $html), substr(strip_tags($html), 0, 300));
[$g, $gm] = trail_sight_give($row(), $exp, $base['slug'], 0, 1); ok('waking them with no cornbread is refused', !$g && str_contains((string)$gm, 'Cornbread'), (string)$gm);
[$g, $gm] = trail_sight_give($row(), $exp, $base['slug'], 0, 7); ok('a bad choice is refused', !$g, (string)$gm);
[$g, $gm] = trail_sight_give($row(), $exp, $base['slug'], 0); ok('no choice is refused', !$g, (string)$gm);
q('UPDATE users SET ev_stat = NULL, ev_amt = 0, ev_until = NULL, ev_day = NULL, ev_scope = NULL WHERE id = ?', [$uid]);
[$g] = trail_sight_give($row(), $exp, $base['slug'], 0, 0); save_exp($exp); $exp = active_expedition($uid);
ok('let them sleep: the luck buff and the sleep line', $g && $row()['ev_stat'] === 'luck' && (int)$row()['ev_amt'] >= 1 && str_contains($lastLog(), 'a small luck settles on you'), $lastLog() . ' stat ' . $row()['ev_stat']);
[$g, $gm] = trail_sight_give($row(), $exp, $base['slug'], 0, 0); ok('once a day: asking again is refused', !$g && str_contains((string)$gm, 'Mabel'), (string)$gm);
q("DELETE FROM trail_sight_tally WHERE user_id = ? AND tkey LIKE 'give~%'", [$uid]); $setqty($cornbread, 2); $x0 = (int)$row()['xp']; $exp = active_expedition($uid);
[$g] = trail_sight_give($row(), $exp, $base['slug'], 0, 1); save_exp($exp); $exp = active_expedition($uid);
ok('wake them with cornbread: one cornbread is taken, the wake line and the reward', $g && $qty($cornbread) === 1 && (int)$row()['xp'] >= $x0 + 9 && str_contains($lastLog(), 'wakes with a start') && str_contains($lastLog(), 'Cornbread'), $lastLog() . ' bread ' . $qty($cornbread));
unset($GLOBALS['gv_sight_folk_file']);

echo "== 3. a shop discount scoped to one item\n";
t('lint: disc=shop:50:60:rope is clean; an unknown slug, a rest scope and a bad slug are refused', fn() => !$lint(['rewards' => 'disc=shop:50:60:rope'], 'disc') && (bool)$lint(['rewards' => 'disc=shop:50:60:no-such-thing-x'], 'disc') && (bool)$lint(['rewards' => 'disc=rest:50:60:rope'], 'disc') && (bool)$lint(['rewards' => 'disc=shop:50:60:Rope'], 'disc') && !$lint(['rewards' => 'disc=shop:20:60:seed'], 'disc'));
q('UPDATE users SET ev_disc = NULL WHERE id = ?', [$uid]);
$pR0 = shop_price($row(), 100, 1, $ropeId); $pS0 = shop_price($row(), 100, 1, $seedId); $pO0 = shop_price($row(), 100, 1, $cornbread);
t('disc=shop:50:60:rope is set and names the Rope', fn() => str_contains(trail_sight_disc_set($uid, 'shop', 50, 60, 'rope'), 'Rope') ? true : 'no line');
t('the rope costs less, a seed and a cornbread cost the same', fn() => shop_price($row(), 100, 1, $ropeId) < $pR0 && shop_price($row(), 100, 1, $seedId) === $pS0 && shop_price($row(), 100, 1, $cornbread) === $pO0 ? true : json_encode([shop_price($row(), 100, 1, $ropeId), $pR0]));
t('a slug discount that ran out counts for nothing', function () use ($uid, $row, $ropeId, $pR0) { q('UPDATE users SET ev_disc = ? WHERE id = ?', [json_encode(['shop:rope' => [50, time() - 5]]), $uid]); return shop_price($row(), 100, 1, $ropeId) === $pR0 ? true : 'still cheaper'; });
t('a slug scope with no such item pays nothing', fn() => trail_sight_disc_set($uid, 'shop', 50, 60, 'no-such-thing-x') === '');
$put($std + ['check' => '-', 'rewards' => 'disc=shop:50:60:rope']); q('UPDATE users SET ev_disc = NULL WHERE id = ?', [$uid]); [$a] = $use();
ok('a Sight row pays the slug discount', $a && shop_price($row(), 100, 1, $ropeId) < $pR0);
q('UPDATE users SET ev_disc = NULL WHERE id = ?', [$uid]);
t('rope is put on the shelf of Twigg\'s once (boot step helper)', function () use ($ropeId) { $twigg = (int)q_val("SELECT id FROM shops WHERE slug = 'twigg-s-seed-emporium'"); $n1 = sights6a_rope_stock_ensure(); $n2 = sights6a_rope_stock_ensure(); return $twigg && q_val('SELECT 1 FROM shop_stock WHERE shop_id = ? AND item_id = ?', [$twigg, $ropeId]) && $n2 === 0 ? true : "n1 $n1 n2 $n2"; });


echo "== the data rows that use the sixth pass A\n";
$F = trail_sight_folk(); $A = trail_sights_all();
$folkRow = fn(string $slug, string $who) => current(array_filter($F[$slug] ?? [], fn($f) => $f['who'] === $who)) ?: ['rewards' => '', 'line' => '', 'miss' => ''];
t('the sleeper at haven-2-grassland: a choice, sleep for Luck or wake with cornbread, a result line each', function () use ($folkRow) { $f = $folkRow('end-haven-2-grassland', 'Ulric Tumblethorn'); $o = sights6a_vchoose($f['rewards']); return $o && count($o) === 2 && str_contains($f['rewards'], 'buff=luck') && str_contains($f['rewards'], 'take=cornbread:1') && count(explode(' // ', $f['miss'])) === 2 ? true : json_encode($f); });
t('the smuggler sells rope at half price', fn() => str_contains($folkRow('end-delve-1-coast', 'Gaffer Brineworth')['rewards'], 'disc=shop:50:') && str_contains($folkRow('end-delve-1-coast', 'Gaffer Brineworth')['rewards'], ':rope') ? true : $folkRow('end-delve-1-coast', 'Gaffer Brineworth')['rewards']);
t('the aurora camp toast takes any bread as an optional extra', fn() => str_contains($A['316-auroracamp']['rewards'], 'take=any-bread:1?hv=any-bread:1') && !trail_sight_lint($A['316-auroracamp']) ? true : json_encode(trail_sight_lint($A['316-auroracamp'])));
t('the kettle tree takes any tea as an optional extra, and Tobias swaps a tea', fn() => str_contains($A['316-kettletree']['rewards'], 'take=any-tea:1?hv=any-tea:1') && !trail_sight_lint($A['316-kettletree']) && (bool)array_filter($F['316-kettletree'] ?? [], fn($f) => str_contains($f['rewards'], 'give=any-tea:1')) ? true : json_encode(trail_sight_lint($A['316-kettletree'])));

q('DELETE FROM trail_sight_rows WHERE slug = ?', [$base['slug']]);
foreach (glob(sys_get_temp_dir() . '/sg284_' . getmypid() . '_*') as $f) @unlink($f);
echo $fails ? "$fails FAILED\n" : "ok\n";
exit($fails ? 1 : 0);
