<?php
// 2.7.58 creature parts, phase 3: villagers who ask for parts (includes/data/trail_sight_folk_parts.txt, give=any-<suffix>). php tests/sight_parts.php GAME_DIR (installed game, player "sprout").
$_SERVER['SCRIPT_NAME'] = '/adventure.php';
require $argv[1] . '/includes/bootstrap.php';
require_once $argv[1] . '/includes/tools.php';
require_once $argv[1] . '/includes/gathering.php';
require_once $argv[1] . '/includes/trail_sights.php';
require_once $argv[1] . '/includes/gourmand.php';
$fails = 0;
set_exception_handler(function (Throwable $e) { echo '  FAIL exception ' . get_class($e) . ': ' . $e->getMessage() . ' @ ' . basename($e->getFile()) . ':' . $e->getLine() . "\n"; exit(1); });
function ok(string $what, bool $cond, string $extra = ''): void { global $fails; echo ($cond ? '  ok   ' : '  FAIL ') . $what . ($cond ? '' : "  $extra") . "\n"; if (!$cond) $fails++; }
$uid = (int)q_val("SELECT id FROM users WHERE username = 'sprout'");

echo "== the rows\n";
$rows = trail_sight_folk(__DIR__ . '/../game/includes/data/trail_sight_folk_parts.txt');
$flat = []; foreach ($rows as $slug => $l) foreach ($l as $f) $flat[] = $f;
ok('five part rows load (hide, plate, wing, silk, ooze)', count($flat) === 5, (string)count($flat));
$gives = []; foreach ($flat as $f) foreach (trail_sight_tokens($f['rewards']) as $t) if (str_starts_with($t['tok'], 'give=')) $gives[] = $t['tok'];
ok('each row asks for any-<suffix> parts, 2 of them', count($gives) === 5 && !array_filter($gives, fn($g) => !preg_match('/^give=any-[a-z]+(\+[a-z]+)*:2$/', $g)), json_encode($gives));
ok('the loader picks the file up on its own (glob trail_sight_folk_*.txt)', isset(trail_sight_folk()['coast-the-kelp-line']) && count(array_filter(trail_sight_folk()['coast-the-kelp-line'], fn($f) => str_contains($f['rewards'], 'give=any-slime'))) === 1);
$ooze = array_values(array_filter($flat, fn($f) => str_starts_with($f['who'], 'Pomeroy')));
ok('the Ooze request is Pomeroy\'s', count($ooze) === 1 && str_contains($ooze[0]['rewards'], 'slime'));

echo "== the parts count\n";
require_once $argv[1] . '/includes/trail_sights_5.php';
$spec = 'slime+gland+sac+ink';
$parts = q("SELECT id FROM items WHERE category = 'part' AND (slug LIKE '%-slime' OR slug LIKE '%-gland') ORDER BY id LIMIT 2")->fetchAll(PDO::FETCH_COLUMN);
ok('have two ooze parts to test with', count($parts) === 2);
foreach ($parts as $pid) q('DELETE FROM user_items WHERE user_id = ? AND item_id = ?', [$uid, $pid]);
ok('none held: have 0, the gift is refused', sights5_any_have($uid, $spec)[1] === 0 && !sights5_any_use($uid, $spec, 2));
give_item($uid, (int)$parts[0], 1);
ok('one part is short of 2 and nothing is taken', !sights5_any_use($uid, $spec, 2) && sights5_any_have($uid, $spec)[1] === 1);
give_item($uid, (int)$parts[1], 2);
ok('three parts of two kinds: 2 are taken across the stacks', sights5_any_use($uid, $spec, 2) && sights5_any_have($uid, $spec)[1] === 1);

echo "== Pomeroy only while the Gourmand is open\n";
set_setting('gourmand_open', '0'); setting('__reload__'); gourmand_sync_active();
ok('Gourmand off: Pomeroy is not about, so his row never shows', !trail_sight_folk_available('Pomeroy Crumbworth'));
set_setting('gourmand_open', '1'); setting('__reload__'); gourmand_sync_active();
ok('Gourmand open: his npcs row is active again', (int)q_val("SELECT active FROM npcs WHERE traveller = 'gourmand'") === 1);
set_setting('gourmand_open', '0'); setting('__reload__'); gourmand_sync_active();
echo $fails ? "$fails FAILED\n" : "ok\n";
exit($fails ? 1 : 0);
