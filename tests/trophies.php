<?php
// 2.7.58 creature parts, phase 3: the hovel trophy wall (slot `trophy` in hovel_decor.json, table user_trophies, hovel_trophy_*() in includes/home_slim.php).
// php tests/trophies.php GAME_DIR (installed game with player "sprout").
$_SERVER['SCRIPT_NAME'] = '/gnome.php';
require $argv[1] . '/includes/bootstrap.php';
require_once $argv[1] . '/includes/home_slim.php';
$fails = 0;
set_exception_handler(function (Throwable $e) { echo '  FAIL exception ' . get_class($e) . ': ' . $e->getMessage() . ' @ ' . basename($e->getFile()) . ':' . $e->getLine() . "\n"; exit(1); });
function ok(string $what, bool $cond, string $extra = ''): void { global $fails; echo ($cond ? '  ok   ' : '  FAIL ') . $what . ($cond ? '' : "  $extra") . "\n"; if (!$cond) $fails++; }
mt_srand(2758);
$uid = (int)q_val("SELECT id FROM users WHERE username = 'sprout'");
$u = q_one('SELECT * FROM users WHERE id = ?', [$uid]);

echo "== the slot\n";
$cat = hovel_decor_catalog(); $s = $cat['slots']['trophy'] ?? null;
ok('catalogue has a trophy slot with bare / one / row, bare owned from the start', $s && array_keys($s['items']) === ['bare', 'one', 'row'] && $s['items']['bare']['own'] && !$s['items']['one']['own'] && !$s['items']['row']['own'], json_encode($s ? array_keys($s['items']) : null));
ok('the slot box sits inside the room', $s && $s['x'] + $s['w'] <= $cat['canvas']['w'] && $s['y'] + $s['h'] <= $cat['canvas']['h']);
ok('the new items carry the "new" label', $s && !empty($s['items']['one']['new']) && !empty($s['items']['row']['new']));
ok('nothing owned yet beyond bare', array_keys(hovel_decor_owned($uid)['trophy'] ?? []) === ['bare']);
[$ok, $m] = hovel_decor_set($uid, 'trophy', 'one');
ok('a trophy item is refused with no trophies', !$ok, $m);

echo "== pinning a part\n";
$rows = q("SELECT DISTINCT c.slug AS cs, i.id AS iid FROM creature_drops cd JOIN creatures c ON c.id = cd.creature_id JOIN items i ON i.id = cd.item_id WHERE i.category = 'part' ORDER BY c.slug, i.id")->fetchAll();
$by = []; foreach ($rows as $r) $by[$r['cs']][] = (int)$r['iid'];
$cs = array_slice(array_keys($by), 0, 4);
ok('have four creatures with part drops to test with', count($cs) === 4);
q('DELETE FROM user_trophies WHERE user_id = ?', [$uid]);
[$ok, $m] = hovel_trophy_add($uid, $cs[0], $by[$cs[0]][0]);
ok('no part held: refused, no row', !$ok && (int)q_val('SELECT COUNT(*) FROM user_trophies WHERE user_id = ?', [$uid]) === 0, $m);
give_item($uid, $by[$cs[0]][0], 2);
[$ok, $m] = hovel_trophy_add($uid, 'no-such-creature', $by[$cs[0]][0]);
ok('a part that creature does not drop is refused', !$ok, $m);
[$ok, $m] = hovel_trophy_add($uid, $cs[0], $by[$cs[0]][0]);
$qty = fn(int $i) => (int)q_val('SELECT COALESCE(SUM(qty),0) FROM user_items WHERE user_id = ? AND item_id = ?', [$uid, $i]);
ok('pinned: one part used up, one row', $ok && $qty($by[$cs[0]][0]) === 1 && (int)q_val('SELECT COUNT(*) FROM user_trophies WHERE user_id = ? AND creature_slug = ?', [$uid, $cs[0]]) === 1, $m);
[$ok, $m] = hovel_trophy_add($uid, $cs[0], $by[$cs[0]][0]);
ok('one trophy per creature: the second is refused and keeps the part', !$ok && $qty($by[$cs[0]][0]) === 1, $m);
ok('one trophy owns the "one" item', !empty(hovel_decor_owned($uid)['trophy']['one']) && empty(hovel_decor_owned($uid)['trophy']['row']));
[$ok, $m] = hovel_decor_set($uid, 'trophy', 'one'); ok('and it can be put in place', $ok, $m);
foreach ([1, 2] as $k) { give_item($uid, $by[$cs[$k]][0], 1); hovel_trophy_add($uid, $cs[$k], $by[$cs[$k]][0]); }
ok('three trophies own the "row" item', !empty(hovel_decor_owned($uid)['trophy']['row']));
give_item($uid, $by[$cs[3]][0], 1);
$opt = hovel_trophy_options($uid);
$oc = array_column($opt, 'creature');
ok('options list a creature whose part is held and not yet pinned, not the pinned ones', in_array($cs[3], $oc, true) && !array_intersect([$cs[0], $cs[1], $cs[2]], $oc), json_encode($oc));
$h = home_slim_furnish_html($u, hovel_decor_chosen($uid));
ok('Furnish shows the trophy slot, a "New" label, and the pin form', str_contains($h, 'hpick-trophy') && str_contains($h, '>New<') && str_contains($h, 'name="do" value="trophy_pin"'));
echo $fails ? "$fails FAILED\n" : "ok\n";
exit($fails ? 1 : 0);
