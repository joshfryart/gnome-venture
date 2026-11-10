<?php
// v2.6.06 crafted satchels: items and recipes exist, ensure is idempotent, the Gather scene skin follows what the gnome owns.
// Run: php tests/satchel.php GAME_DIR  (an installed copy of game/, player "sprout").
$_SERVER['SCRIPT_NAME'] = '/gnome.php';
require $argv[1] . '/includes/bootstrap.php';
require_once $argv[1] . '/includes/crafting.php';
require_once $argv[1] . '/includes/gathering.php';
$fails = 0;
set_exception_handler(function (Throwable $e) { echo '  EXCEPTION ' . get_class($e) . ': ' . $e->getMessage() . ' @ ' . basename($e->getFile()) . ':' . $e->getLine() . "\n"; exit(1); });
function ok(string $what, bool $cond, string $extra = ''): void { global $fails; echo ($cond ? '  ok   ' : '  FAIL ') . $what . ($cond ? '' : "  $extra") . "\n"; if (!$cond) $fails++; }
ensure_crafts(); ensure_crafts();
foreach (['canvas-satchel', 'patchwork-satchel'] as $slug) {
    ok("$slug item exists once", (int)q_val('SELECT COUNT(*) FROM items WHERE slug = ?', [$slug]) === 1);
    ok("$slug recipe exists once", (int)q_val('SELECT COUNT(*) FROM recipes WHERE slug = ?', [$slug]) === 1);
    $ing = json_decode((string)q_val('SELECT ingredients FROM recipes WHERE slug = ?', [$slug]), true) ?: [];
    $miss = array_filter(array_keys($ing), fn($s) => !q_val('SELECT 1 FROM items WHERE slug = ?', [$s]));
    ok("$slug ingredients are all real items", $ing && !$miss, implode(',', $miss));
}
$uid = (int)q_val("SELECT id FROM users WHERE username = 'sprout'");
$give = function (string $slug, int $n) use ($uid) { $iid = item_id_by_slug($slug); q('DELETE FROM user_items WHERE user_id = ? AND item_id = ?', [$uid, $iid]); if ($n) db_insert('user_items', ['user_id' => $uid, 'item_id' => $iid, 'qty' => $n]); };
$u = ['id' => $uid];
function urow_for(int $uid): array { return q_one('SELECT * FROM users WHERE id = ?', [$uid]) ?: []; }
$give('canvas-satchel', 0); $give('patchwork-satchel', 0);
ok('nothing owned: leather', gather_satchel_key($u) === 'leather');
$give('canvas-satchel', 1);
ok('canvas owned: canvas', gather_satchel_key($u) === 'canvas');
$give('patchwork-satchel', 1);
ok('both owned: patchwork wins', gather_satchel_key($u) === 'patchwork');
ok('a saved satchel_skin column value still wins', gather_satchel_key(['id' => $uid, 'satchel_skin' => 'canvas']) === 'canvas');
ok('no user id: leather', gather_satchel_key([]) === 'leather');
$give('patchwork-satchel', 0); $give('canvas-satchel', 1);
ok('picking leather is always allowed', gather_set_satchel_skin($uid, 'leather')[0] === true && (string)q_val('SELECT satchel_skin FROM users WHERE id = ?', [$uid]) === 'leather');
ok('leather picked wins over a canvas satchel in the pack', gather_satchel_key(urow_for($uid)) === 'leather');
ok('canvas owned: pick it', gather_set_satchel_skin($uid, 'canvas')[0] === true && gather_satchel_key(urow_for($uid)) === 'canvas');
ok('patchwork not owned: refused, skin unchanged', gather_set_satchel_skin($uid, 'patchwork')[0] === false && (string)q_val('SELECT satchel_skin FROM users WHERE id = ?', [$uid]) === 'canvas');
ok('nonsense refused', gather_set_satchel_skin($uid, 'gold')[0] === false);
ok('empty picks the best owned again', gather_set_satchel_skin($uid, '')[0] === true && q_val('SELECT satchel_skin FROM users WHERE id = ?', [$uid]) === null && gather_satchel_key(urow_for($uid)) === 'canvas');
$give('canvas-satchel', 0); $give('patchwork-satchel', 0);
$_SESSION['uid'] = $uid;
ok('picker: only leather owned, no picker', gather_satchel_picker_html(['id' => $uid], '/gather.php', '') === '');
$give('canvas-satchel', 1);
$pk = gather_satchel_picker_html(urow_for($uid), '/gather.php', '<input type="hidden" name="back" value="world.php?tab=gather">');
ok('picker: leather + canvas offered, no patchwork', str_contains($pk, 'value="leather"') && str_contains($pk, 'value="canvas"') && !str_contains($pk, 'value="patchwork"'));
ok('picker: posts do=satchel_skin and keeps the back field', str_contains($pk, 'name="do" value="satchel_skin"') && str_contains($pk, 'name="back"'));
ok('picker: no inline styles (CSP)', !str_contains($pk, 'style='));
ok('picker: automatic choice marks canvas and says best', str_contains($pk, 'Canvas satchel ✔') && str_contains($pk, 'Carrying the best satchel') && !str_contains($pk, 'Use my best'));
gather_set_satchel_skin($uid, 'leather');
$pk = gather_satchel_picker_html(urow_for($uid), '/gather.php', '');
ok('picker: manual leather marks leather and offers Use my best', str_contains($pk, 'Leather satchel ✔') && str_contains($pk, 'Use my best'));
$give('canvas-satchel', 0); q('UPDATE users SET satchel_skin = NULL WHERE id = ?', [$uid]);
echo $fails ? "$fails FAILED\n" : "all ok\n";
exit($fails ? 1 : 0);
