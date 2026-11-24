<?php
// 2.7.58 creature parts, phase 2: parts onto the compost heap. Excess banks in garden_buildings.scrap_bank, nothing is refused.
// php tests/compost_parts.php GAME_DIR (installed game with player "sprout").
$_SERVER['SCRIPT_NAME'] = '/garden.php';
require $argv[1] . '/includes/bootstrap.php';
require_once $argv[1] . '/includes/garden_logic.php';
$fails = 0;
set_exception_handler(function (Throwable $e) { echo '  EXCEPTION ' . get_class($e) . ': ' . $e->getMessage() . ' @ ' . basename($e->getFile()) . ':' . $e->getLine() . "\n"; exit(1); });
function ok(string $what, bool $cond, string $extra = ''): void { global $fails; echo ($cond ? '  ok   ' : '  FAIL ') . $what . ($cond ? '' : "  $extra") . "\n"; if (!$cond) $fails++; }
mt_srand(2758);
$u = q_one("SELECT * FROM users WHERE username = 'sprout'"); $uid = (int)$u['id'];
$plot = (int)q_val('SELECT id FROM plots WHERE user_id = ? ORDER BY id LIMIT 1', [$uid]);
$iid = fn(string $slug) => (int)q_val('SELECT id FROM items WHERE slug = ?', [$slug]);
$have = fn(string $slug) => (int)q_val('SELECT qty FROM user_items WHERE user_id = ? AND item_id = ?', [$uid, $iid($slug)]);
$row = fn() => q_one("SELECT * FROM garden_buildings WHERE plot_id = ? AND building = 'compost_bin'", [$plot]);
$hide = (string)q_val("SELECT slug FROM items WHERE category = 'part' AND slug LIKE '%-pelt' ORDER BY id LIMIT 1");
$plate = (string)q_val("SELECT slug FROM items WHERE category = 'part' AND slug LIKE '%-shell' ORDER BY id LIMIT 1");
ok('have a hide and a plate part to test with', $hide !== '' && $plate !== '', "$hide / $plate");
q('UPDATE users SET level = 20 WHERE id = ?', [$uid]); $u = q_one('SELECT * FROM users WHERE id = ?', [$uid]);

echo "== settings and column\n";
ok('part_scraps_hide is 3', setting('part_scraps_hide') == 3);
ok('part_scraps_ooze is 4', setting('part_scraps_ooze') == 4);
ok('part_shell_meal_parts is 2', setting('part_shell_meal_parts') == 2);
q("INSERT INTO garden_buildings (plot_id, building, built_at, last_collect, level) VALUES (?, 'compost_bin', ?, ?, 1)", [$plot, now(), now()]);
ok('scrap_bank column exists and starts 0', (int)$row()['scrap_bank'] === 0);

echo "== 100 Hide parts into a full heap\n";
$need = heap_need(1, heap_output($row())); $cap = $need * (int)setting('compost_heap_max');
q('UPDATE garden_buildings SET scraps = ? WHERE id = ?', [$cap, $row()['id']]);
give_item($uid, $iid($hide), 100);
$per = (int)setting('part_scraps_hide');
[$o, $m] = add_parts_to_heap($u, $plot, [$hide => 100]);
ok('accepted (nothing refused)', $o, (string)$m);
ok('all 100 parts taken', $have($hide) === 0, (string)$have($hide));
ok('heap stays at the cap', (int)$row()['scraps'] === $cap);
ok('bank holds the excess', (int)$row()['scrap_bank'] === 100 * $per, (string)$row()['scrap_bank']);

echo "== collect repeatedly\n";
$total = $cap + 100 * $per; $made = 0; $loops = 0;
do {
    $r = $row(); $ready = heap_ready($r);
    if ($ready < 1) break;
    [$co] = collect_building($u, $plot, 'compost_bin');
    ok('collect ' . (++$loops) . ' works', $co);
    $made += $ready;
    $r = $row();
    ok('heap never above cap', (int)$r['scraps'] <= $cap);
    ok('points conserved', (int)$r['scraps'] + (int)$r['scrap_bank'] + $made * $need === $total, ((int)$r['scraps'] + (int)$r['scrap_bank'] + $made * $need) . " vs $total");
} while ($loops < 50);
ok('bank drained into freed room', (int)$row()['scrap_bank'] < $need * (int)setting('compost_heap_max') || heap_ready($row()) >= 1);
ok('at least two collects were needed', $loops >= 2, (string)$loops);
ok('compost made equals points / need', $made === intdiv($total, $need), "$made vs " . intdiv($total, $need));
ok('Plain Compost in the satchel', $have('plain-compost') >= $made);

echo "== Plate parts make Shell Meal\n";
give_item($uid, $iid($plate), 5); $sm0 = $have('shell-meal'); $pp = (int)setting('part_shell_meal_parts');
[$o, $m] = add_parts_to_heap($u, $plot, [$plate => 5]);
ok('ok', $o, (string)$m);
ok('2 meals for 5 plates at 2:1, 1 plate kept', $have('shell-meal') === $sm0 + intdiv(5, $pp) && $have($plate) === 5 % $pp, $have('shell-meal') . '/' . $have($plate));

echo "== no parts, no Compost Bin\n";
[$o] = add_parts_to_heap($u, $plot, [$hide => 1]);
ok('not enough parts is refused', !$o);
q("DELETE FROM garden_buildings WHERE plot_id = ?", [$plot]);
[$o] = add_parts_to_heap($u, $plot, [$hide => 1]);
ok('no bin is refused', !$o);

echo $fails ? "$fails FAILED\n" : "ok\n";
exit($fails ? 1 : 0);
