<?php
// Trail Sights engine gaps, fifth pass (game/includes/trail_sights_5.php): an ITEM as a check alternative (nimble:9+item:slug), a villager's own check with a miss line
// (check=stat:dc and `line // miss line`), any-of takes and gives over a category (any-seed, any-produce+flower), shop discounts scoped to an item category
// (disc=shop:20:60:seed), Sight kinds (data/trail_sight_kinds.txt) with nextkind=<kind>:+N|fish=N, a quest time limit of one season (limit column `season`).
// php tests/trail_sights_283.php GAME_DIR   (an installed game, player "sprout"; walk.sh installs one). Model: tests/trail_sights_282.php.
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

echo "== the walk\n";
set_setting('gnav_on', '1'); set_setting('gnav_tiles', '1'); set_setting('game_clock_on', '1'); set_setting('weather_force', 'sun'); set_setting('trail_fog_weather', '0'); setting('__reload__');
$begin = function () use ($uid, $row) {
    q("UPDATE expeditions SET status = 'done' WHERE user_id = ?", [$uid]);
    q("UPDATE routes SET kind = 'road', steps = 5 WHERE id = 240");
    $r = q_one('SELECT * FROM routes WHERE id = 240');
    q("UPDATE users SET location_id = ?, level = 30, energy = 90, coins = 500, ev_quickwalk = 0, game_day = 10, game_minute = 360 WHERE id = ?", [$r['a_id'], $uid]);
    q('DELETE FROM trail_sight_uses WHERE user_id = ?', [$uid]); q('DELETE FROM trail_pickups WHERE user_id = ?', [$uid]);
    [$sok, $sm] = start_expedition($row(), 240);
    return [$sok, active_expedition($uid)];
};
[$sok, $exp] = $begin(); ok('the walk starts (5 stretches)', $sok && $exp);
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
$w = function (string $name, string $text) { $p = sys_get_temp_dir() . '/sg283_' . getmypid() . '_' . $name; file_put_contents($p, $text); return $p; };
$mkItem = function (string $slug, string $cat, string $name) { if (!item_id_by_slug($slug)) db_insert('items', ['name' => $name, 'slug' => $slug, 'category' => $cat, 'rarity' => 1, 'base_price' => 20, 'description' => 't', 'edible' => 0, 'effects' => '{}', 'tradable' => 1]); return (int)item_id_by_slug($slug); };
$seedId = $mkItem('sg5-test-seed', 'seed', 'Test seed'); $flowerId = $mkItem('sg5-test-flower', 'flower', 'Test flower'); $foodId = $mkItem('sg5-test-food', 'food', 'Test food');
$sardine = (int)item_id_by_slug('sardine');
$qty = fn(int $id) => (int)q_val('SELECT qty FROM user_items WHERE user_id = ? AND item_id = ?', [$uid, $id]);
$setqty = function (int $id, int $n) use ($uid, $qty) { $d = $n - $qty($id); if ($d) give_item($uid, $id, $d); };
$clear = fn() => q("DELETE FROM user_items WHERE user_id = ? AND item_id IN (SELECT id FROM items WHERE category IN ('seed', 'flower', 'produce', 'food'))", [$uid]);   // the starter satchel holds seeds: any-seed would take those

echo "== lint\n";
t('check nimble:9+item:sardine is clean; an item alone, an unknown item and a bad qty are refused', fn() => !$lint(['check' => 'nimble:9+item:sardine', 'lose' => 'No.'], 'check') && !$lint(['check' => 'grit:11+item:sardine:2', 'lose' => 'No.'], 'check')
    && (bool)$lint(['check' => 'item:sardine', 'lose' => 'No.'], 'check') && (bool)$lint(['check' => 'nimble:9+item:no-such-thing-x', 'lose' => 'No.'], 'item') && (bool)$lint(['check' => 'nimble:9+item:sardine:0', 'lose' => 'No.'], 'check'));
t('take= / give= any-seed, any-produce+flower are clean; any-seed+ and any-Seed are refused', fn() => !$lint(['rewards' => 'take=any-seed:1,xp=2'], 'take') && !$lint(['rewards' => 'take=any-produce+flower:2'], 'take') && !$lint(['rewards' => 'give=any-seed:1'], 'give')
    && (bool)$lint(['rewards' => 'take=any-seed+:1'], 'take') && (bool)$lint(['rewards' => 'give=any-Seed:1'], 'give'));
t('disc=shop:20:60:seed is clean; a scope on rest or an unknown scope is refused', fn() => !$lint(['rewards' => 'disc=shop:20:60:seed'], 'disc') && !$lint(['rewards' => 'disc=shop:10:30'], 'disc') && (bool)$lint(['rewards' => 'disc=rest:20:60:seed'], 'disc') && (bool)$lint(['rewards' => 'disc=shop:20:60:nosuch'], 'disc'));
t('nextkind=crossing:+2 and fishing:fish=1 are clean; an unknown kind, a big bonus and a bad effect are refused', fn() => !$lint(['rewards' => 'nextkind=crossing:+2,nextkind=fishing:fish=1@50'], 'nextkind') && (bool)$lint(['rewards' => 'nextkind=flying:+2'], 'nextkind') && (bool)$lint(['rewards' => 'nextkind=crossing:+9'], 'nextkind') && (bool)$lint(['rewards' => 'nextkind=crossing:xp=5'], 'nextkind'));

echo "== an item as a check alternative\n";
t('the card names the item: Nimble or Sardine', fn() => sights5_check_label('nimble:9+item:sardine') === 'Nimble or Sardine' && sights5_check_label('grit:11') === 'Grit');
t('sights5_item_alt reads item:slug[:qty] and nothing else', fn() => sights5_item_alt('grit:11') === null && sights5_item_alt('item:sardine:2') === ['sardine', 2] && sights5_item_alt('item:sardine') === ['sardine', 1]);

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

echo "== item alternative in a real use\n";
$put($std + ['check' => 'nimble:25+item:sardine', 'rewards' => 'xp=2', 'win' => 'WINLINE', 'lose' => 'LOSELINE']);
$setqty($sardine, 0); [$a] = $use();
ok('no sardine and the stat roll fails: the lose line', $a && str_contains($lastLog(), 'LOSELINE') && $qty($sardine) === 0, $lastLog());
$used = false; $line = '';
for ($i = 0; $i < 8 && !$used; $i++) { $setqty($sardine, 2); $put($std + ['check' => 'nimble:25+item:sardine', 'rewards' => 'xp=2', 'win' => 'WINLINE', 'lose' => 'LOSELINE']); [$a] = $use(); $line = $lastLog(); $used = $qty($sardine) === 1; }
ok('a sardine in the satchel wins the Sight and is used up', $used && str_contains($line, 'WINLINE') && stripos($line, 'sardine') !== false, $line . ' qty ' . $qty($sardine));
$setqty($sardine, 2); $put($std + ['check' => 'nimble:0+item:sardine', 'rewards' => 'xp=2', 'win' => 'WINLINE', 'lose' => 'LOSELINE']); [$a] = $use();
ok('when the stat roll passes, the sardine is kept', $a && str_contains($lastLog(), 'WINLINE') && $qty($sardine) === 2, $lastLog() . ' qty ' . $qty($sardine));
$setqty($sardine, 2); $put($std + ['check' => 'nimble:25+item:sardine:3', 'rewards' => 'xp=2', 'win' => 'WINLINE', 'lose' => 'LOSELINE']); [$a] = $use();
ok('two sardines are not three: the item alternative needs its whole quantity', $a && $qty($sardine) === 2 && !str_contains($lastLog(), 'WINLINE'), $lastLog() . ' qty ' . $qty($sardine));
$setqty($sardine, 1); $put($std + ['check' => 'nimble:25+item:sardine', 'rewards' => 'xp=2', 'win' => 'WINLINE', 'lose' => 'LOSELINE']);
$html = trail_sights_cards_html($row(), trail_scene($exp), trail_sights_marks($row(), trail_scene($exp)), $exp);
ok('the Sights card says Nimble or Sardine', str_contains($html, 'Nimble or Sardine'), substr(strip_tags($html), 0, 200));

echo "== any-of takes and gives over a category\n";
$clear();
$put($std + ['check' => '-', 'rewards' => 'take=any-seed:1,xp=40']); $x0 = (int)$row()['xp'];
[$a, $m] = $use(); ok('take=any-seed with no seed is refused', !$a && str_contains((string)$m, 'seed'), (string)$m);
$clear(); $setqty($seedId, 2); $put($std + ['check' => '-', 'rewards' => 'take=any-seed:1,xp=40']); [$a] = $use();
ok('take=any-seed uses one seed of any kind up and pays', $a && $qty($seedId) === 1 && (int)$row()['xp'] > $x0, 'seed ' . $qty($seedId));
$clear(); $setqty($flowerId, 1); $put($std + ['check' => '-', 'rewards' => 'take=any-produce+flower:1,xp=40']); [$a] = $use();
ok('take=any-produce+flower: a flower will do (two kinds in one take)', $a && $qty($flowerId) === 0, 'flower ' . $qty($flowerId));
$clear(); $setqty($foodId, 3); $put($std + ['check' => '-', 'rewards' => 'take=any-produce+flower:1,xp=40']); [$a, $m] = $use();
ok('... and food is not a crop or a flower', !$a && $qty($foodId) === 3, (string)$m);
t('sights5_any_items: seed = the seed category, produce+flower both', fn() => in_array($seedId, sights5_any_items('seed'), true) && !in_array($flowerId, sights5_any_items('seed'), true) && in_array($flowerId, sights5_any_items('produce+flower'), true));
$W = fn(string $rows) => $GLOBALS['gv_sight_folk_file'] = $w('folk' . md5($rows) . '.txt', $rows);
$ANY = 'dp=dawn,day,dusk,night';
$W("{$base['slug']}|Mabel Pennywhistle|$ANY|100|Mabel wants any seed.|give=any-seed:1,xp=7\n");
q("DELETE FROM trail_sight_tally WHERE user_id = ? AND tkey LIKE 'give~%'", [$uid]); $put($std + ['check' => '-', 'rewards' => 'xp=1']); $clear(); $exp = active_expedition($uid);
[$g0, $gm0] = trail_sight_give($row(), $exp, $base['slug'], 0);
ok('give=any-seed: refused without a seed', !$g0 && str_contains((string)$gm0, 'seed'), (string)$gm0);
$clear(); $setqty($seedId, 2); $exp = active_expedition($uid); $x0 = (int)$row()['xp'];
[$g1, $gm1] = trail_sight_give($row(), $exp, $base['slug'], 0); save_exp($exp); $exp = active_expedition($uid);
ok('give=any-seed: any seed is handed over and the villager pays', $g1 && $qty($seedId) === 1 && (int)$row()['xp'] >= $x0 + 7 && str_contains($lastLog(), 'Mabel'), (string)$gm1 . ' ' . $lastLog());
$html = trail_sights_cards_html($row(), trail_scene($exp), trail_sights_marks($row(), trail_scene($exp)), $exp);
ok('the card asks for "any seed"', str_contains($html, 'any seed'), substr(strip_tags($html), 0, 300));

echo "== a villager's own check, with a miss line\n";
t('a folk row `line // miss line` is parsed into line and miss', function () use ($W, $base, $ANY) { $W("{$base['slug']}|Mabel Pennywhistle|$ANY|100|She smiles. // She frowns.|check=grit:9,xp=3\n{$base['slug']}|Bunty Windlass|$ANY|100|Plain.|xp=1\n");
    $f = trail_sight_folk()[$base['slug']]; return $f[0]['line'] === 'She smiles.' && $f[0]['miss'] === 'She frowns.' && $f[1]['miss'] === '' ? true : json_encode($f); });
$put($std + ['check' => '-', 'rewards' => 'xp=1', 'win' => 'The Sight went fine.']);
$W("{$base['slug']}|Mabel Pennywhistle|$ANY|100|She smiles.  // She frowns and shakes her head.|check=grit:99,xp=40,fp=1\n"); $x0 = (int)$row()['xp'];
$exp = active_expedition($uid); [$a] = $use(); $xpGain = (int)$row()['xp'] - $x0;
ok('a missed check: the miss line, not the line, and no villager reward', $a && str_contains($lastLog(), 'She frowns and shakes her head.') && !str_contains($lastLog(), 'She smiles') && $xpGain < 30, $lastLog() . " xp +$xpGain");
$W("{$base['slug']}|Mabel Pennywhistle|$ANY|100|She smiles. // She frowns.|check=grit:0,xp=40\n"); $x0 = (int)$row()['xp']; $put($std + ['check' => '-', 'rewards' => 'xp=1', 'win' => 'The Sight went fine.']);
[$a] = $use(); ok('a passed check: the line and the reward, rolled once', $a && str_contains($lastLog(), 'She smiles.') && !str_contains($lastLog(), 'She frowns') && (int)$row()['xp'] >= $x0 + 40 && substr_count($lastLog(), 'ask more of you') === 0, $lastLog());
$W("{$base['slug']}|Mabel Pennywhistle|$ANY|100|She smiles.|check=grit:99,xp=40\n"); $put($std + ['check' => '-', 'rewards' => 'xp=1', 'win' => 'The Sight went fine.']); [$a] = $use();
ok('a row with no miss line keeps the old "ask more of you" text', $a && str_contains($lastLog(), 'ask more of you'), $lastLog());
$W("{$base['slug']}|Mabel Pennywhistle|$ANY|100|Mabel wants any seed. // Mabel shakes her head.|check=grit:99,give=any-seed:1,xp=7\n"); $put($std + ['check' => '-', 'rewards' => 'xp=1']);
q("DELETE FROM trail_sight_tally WHERE user_id = ? AND tkey LIKE 'give~%'", [$uid]); $clear(); $setqty($seedId, 2); $exp = active_expedition($uid); [$g] = trail_sight_give($row(), $exp, $base['slug'], 0); save_exp($exp); $exp = active_expedition($uid);
ok('a give row with a check that is missed keeps the gift and says the miss line', $qty($seedId) === 2 && str_contains($lastLog(), 'Mabel shakes her head.'), $lastLog() . ' seeds ' . $qty($seedId));
$GLOBALS['gv_sight_folk_file'] = $w('none.txt', "");
unset($GLOBALS['gv_sight_folk_file']);
t('the shipped data: 14 ask rows have a check and a miss line', function () { $n = 0; $bad = [];
    foreach (trail_sight_folk() as $slug => $rows) foreach ($rows as $f) if (str_contains($f['rewards'], 'check=')) { if ($f['miss'] === '') $bad[] = $slug; else $n++; }
    return $n >= 14 && !$bad ? true : $n . ' rows, no miss: ' . implode(', ', $bad); });

echo "== scoped shop discounts\n";
q('UPDATE users SET ev_disc = NULL WHERE id = ?', [$uid]); $U = $row();
$pS0 = shop_price($U, 100, 1, $seedId); $pF0 = shop_price($U, 100, 1, $foodId);
t('disc=shop:20:60:seed is set and says seeds', fn() => str_contains(trail_sight_disc_set($uid, 'shop', 20, 60, 'seed'), 'seeds') ? true : 'no line');
$U = $row(); $pS1 = shop_price($U, 100, 1, $seedId); $pF1 = shop_price($U, 100, 1, $foodId);
ok('a seed costs about 20% less, food costs what it did', $pS1 < $pS0 && $pS0 - $pS1 >= 15 && $pF1 === $pF0, "seed $pS0 -> $pS1, food $pF0 -> $pF1");
t('a plain "every shop" discount still takes off everything', function () use ($uid, $row, $seedId, $foodId, $pS0, $pF0) { q('UPDATE users SET ev_disc = NULL WHERE id = ?', [$uid]); trail_sight_disc_set($uid, 'shop', 20, 60); $U = $row(); return shop_price($U, 100, 1, $seedId) < $pS0 && shop_price($U, 100, 1, $foodId) < $pF0 ? true : 'no'; });
t('a scoped discount that ran out counts for nothing', function () use ($uid, $row, $seedId, $pS0) { q('UPDATE users SET ev_disc = ? WHERE id = ?', [json_encode(['shop:seed' => [20, time() - 5]]), $uid]); return shop_price($row(), 100, 1, $seedId) === $pS0 ? true : 'still cheaper'; });
t('a Sight row pays the scoped discount', function () use ($put, $std, $use, $uid, $row, $seedId, $pS0) { q('UPDATE users SET ev_disc = NULL WHERE id = ?', [$uid]); $put($std + ['check' => '-', 'rewards' => 'disc=shop:25:60:seed']); [$a] = $use(); return $a && shop_price($row(), 100, 1, $seedId) < $pS0 ? true : 'no'; });
q('UPDATE users SET ev_disc = NULL WHERE id = ?', [$uid]);

echo "== Sight kinds and nextkind\n";
$GLOBALS['gv_sight_kinds_file'] = $w('kinds.txt', "# kinds\n{$base['slug']}|crossing\nforest-the-bluebell-glade|fishing,rest\n");
t('sights5_kinds reads a slug|kind[,kind] file', fn() => sights5_kinds($base['slug']) === ['crossing'] && sights5_kinds('forest-the-bluebell-glade') === ['fishing', 'rest'] && sights5_kinds('no-such-sight') === []);
t('the shipped kinds file only names real Sights and known kinds', function () use ($w) { $keep = $GLOBALS['gv_sight_kinds_file']; unset($GLOBALS['gv_sight_kinds_file']); $all = trail_sights_all(); $bad = []; $n = 0;
    foreach (trail_sight_data_lines('kinds') as $l) { $n++; [$s, $k] = array_pad(explode('|', $l, 2), 2, ''); if (!isset($all[$s])) $bad[] = $s; foreach (explode(',', $k) as $kk) if (!in_array($kk, SIGHTS5_KINDS, true)) $bad[] = $s . ':' . $kk; }
    $GLOBALS['gv_sight_kinds_file'] = $keep; return !$bad && $n >= 10 ? true : $n . ' lines, bad: ' . implode(', ', $bad); });
t('nextkind adds a waiting effect for THIS walk, one per kind (the later one replaces)', function () use ($row, $uid) { $L = sights5_next_add($row(), 'crossing:+2'); $L2 = sights5_next_add($row(), 'crossing:+3'); return str_contains($L, 'crossing') && str_contains($L2, 'crossing') ? true : $L . ' / ' . $L2; });
t('a Sight of that kind takes the bonus once, it is gone afterwards', function () use ($row, $base) { $a = sights5_kind_take_bonus($row(), $base['slug']); $b = sights5_kind_take_bonus($row(), $base['slug']); return $a === 3 && $b === 0 ? true : "$a / $b"; });
t('a Sight of another kind does not take it', function () use ($row, $base) { sights5_next_add($row(), 'crossing:+2'); $x = sights5_kind_take_bonus($row(), 'forest-the-bluebell-glade'); $y = sights5_kind_take_bonus($row(), $base['slug']); return $x === 0 && $y === 2 ? true : "$x / $y"; });
[$sok, $exp] = $begin(); $sc = trail_scene($exp); $sc['x'] = $spot[0]; $sc['y'] = $spot[1]; trail_save($sc); $exp = active_expedition($uid);
t('a bonus from an earlier walk is stale and ignored', function () use ($row, $base, $uid, $begin, $spot) { sights5_next_add($row(), 'crossing:+2'); [$s2] = $begin(); $x = sights5_kind_take_bonus($row(), $base['slug']); return $x === 0 ? true : "x=$x"; });
[$sok, $exp] = $begin(); $sc = trail_scene($exp); $sc['x'] = $spot[0]; $sc['y'] = $spot[1]; trail_save($sc); $exp = active_expedition($uid);
$put($std + ['check' => 'grit:12', 'lose' => 'LOSELINE', 'rewards' => 'xp=2', 'win' => 'WINLINE']);
sights5_next_add($row(), 'crossing:+3'); [$a] = $use();
ok('the check of a crossing Sight says what the coach gave', $a && str_contains($lastLog(), '+3 from the tip'), $lastLog());
[$a] = $use(); ok('... and the second one does not', $a && !str_contains($lastLog(), '+3 from the tip'), $lastLog());
$GLOBALS['gv_sight_kinds_file'] = $w('kinds2.txt', "{$base['slug']}|fishing\n");
$put($std + ['check' => '-', 'rewards' => 'xp=2', 'win' => 'WINLINE']);
sights5_next_add($row(), 'fishing:fish=2'); [$a] = $use();
ok('the next fishing Sight pays the extra catch on a win', $a && str_contains($lastLog(), '🎣'), $lastLog());
[$a] = $use(); ok('... once', $a && !str_contains($lastLog(), '🎣'), $lastLog());
$put($std + ['check' => '-', 'rewards' => 'nextkind=fishing:fish=1']); [$a] = $use(); [$a] = $use();
ok('the Sight token nextkind= puts it in place (the second use is a fishing Sight)', $a && str_contains($lastLog(), '🎣'), $lastLog());

echo "== a quest time limit of one season\n";
t('the 11th column `season` = the season length in game days', function () use ($w) { $GLOBALS['gv_sight_quests_file'] = $w('q.txt', "Q|sg5-q|T|Mabel Pennywhistle|x|any|xp=1|intro|outro||season\nB|sg5-q|grassland-the-clover-patch|a|-\nB|sg5-q|grassland-the-clover-patch|b|-\n");
    $q = trail_sight_quests()['sg5-q'] ?? null; unset($GLOBALS['gv_sight_quests_file']); require_once $GLOBALS['argv'][1] . '/includes/hollow_clock.php';
    return $q && $q['limit'] === hollow_season_length() && !array_filter(trail_sight_quest_lint($q, trail_sights_all()), fn($p) => str_contains($p, 'limit')) ? true : json_encode($q); });
t('Lamplighter\'s Round has the season limit in the shipped data', function () { $q = trail_sight_quests()['lamplighters-round'] ?? null; return $q && $q['limit'] > 0 ? true : 'limit ' . json_encode($q['limit'] ?? null); });

echo "== the data rows that use the fifth pass\n";
q('DELETE FROM trail_sight_rows WHERE slug = ?', [$base['slug']]); $GLOBALS['gv_sights_reload'] = true; $A = trail_sights_all(); $F = trail_sight_folk();
$folkRow = fn(string $slug, string $who) => current(array_filter($F[$slug] ?? [], fn($f) => $f['who'] === $who)) ?: ['rewards' => '', 'line' => '', 'miss' => ''];
ok('the boardwalk gap: Nimble 9 or a timber plank', $A['wetland-the-boardwalk-gap']['check'] === 'nimble:9+item:timber-plank', $A['wetland-the-boardwalk-gap']['check']);
ok('the gulls of end-delve-2-island: Grit 11 or a sardine', $A['end-delve-2-island']['check'] === 'grit:11+item:sardine', $A['end-delve-2-island']['check']);
ok('the caravan at end-wonder-2-grassland swaps figs for any seed', str_contains($folkRow('end-wonder-2-grassland', 'Orla Cobblefield')['rewards'], 'give=any-seed:1'));
ok('the scarecrow takes any crop or flower, the hay wagon any seed', str_contains($A['scarecrow']['rewards'], 'take=any-produce+flower:1') && str_contains($A['236-haywagon']['rewards'], 'take=any-seed:1') && !str_contains($A['scarecrow']['win'], 'carrot'));
ok('Tobias\'s discounts are for seeds only (crossroads, kettle tree, switchback)', str_contains($folkRow('232-crossroads', 'Tobias Trundle')['rewards'], 'disc=shop:20:60:seed') && str_contains($folkRow('316-kettletree', 'Tobias Trundle')['rewards'], ':seed') && str_contains($folkRow('mountain-the-switchback-bend', 'Tobias Trundle')['rewards'], 'disc=shop:20:60:seed'));
ok('Keeper Loamwick tips the next fishing Sight, the lily-pad frog the next crossing', (bool)array_filter($F['coast-the-lighthouse-shadow'] ?? [], fn($f) => $f['who'] === 'Keeper Loamwick' && str_contains($f['rewards'], 'nextkind=fishing:fish=1')) && str_contains($folkRow('wetland-the-lily-pad-ford', 'Wick Rushworth')['rewards'], 'nextkind=crossing:+2'));
ok('the new data lints clean', !sights5_lint_kinds($A));

q('DELETE FROM trail_sight_rows WHERE slug = ?', [$base['slug']]);
foreach (glob(sys_get_temp_dir() . '/sg283_' . getmypid() . '_*') as $f) @unlink($f);
echo $fails ? "$fails FAILED\n" : "ok\n";
exit($fails ? 1 : 0);
