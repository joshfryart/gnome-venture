<?php
// 2.7.00 the worn wearables on the 2.5D gnome rig (includes/gnome25.php): which wearables are worn (2.7.14: the equipped items), the layers drawn for them, and nothing changing without art.
// php tests/gnome_wear.php GAME_DIR   (an installed game, player "sprout"; walk.sh installs one)
$_SERVER['SCRIPT_NAME'] = '/adventure.php';
require $argv[1] . '/includes/bootstrap.php';
require_once $argv[1] . '/includes/gnome25.php';
require_once $argv[1] . '/includes/pfdeck.php';
$fails = 0;
set_exception_handler(function (Throwable $e) { echo '  EXCEPTION ' . get_class($e) . ': ' . $e->getMessage() . ' @ ' . basename($e->getFile()) . ':' . $e->getLine() . "\n"; exit(1); });
function ok(string $what, bool $cond, string $extra = ''): void { global $fails; echo ($cond ? '  ok   ' : '  FAIL ') . $what . ($cond ? '' : "  $extra") . "\n"; if (!$cond) $fails++; }
$u = q_one("SELECT * FROM users WHERE username = 'sprout'"); $uid = (int)$u['id'];
$dir = $argv[1] . '/assets/img/gnome25/';
echo "== which wearables are worn\n";
ok('the codes and layers are the ones the art uses', GNOME25_WEAR === ['b' => 'wboots', 'g' => 'gloves', 'c' => 'cape', 'h' => 'brim', 'p' => 'pack']);
require_once $argv[1] . '/includes/wearables.php';
set_setting('wear_open', '1'); setting('__reload__'); wear_ensure_items(); wear_slots_ensure();
pfd_ensure(); q('DELETE FROM pf_deck_pieces WHERE user_id = ?', [$uid]); q('DELETE FROM user_wear_slots WHERE user_id = ?', [$uid]);
ok('nothing worn: no codes', gnome25_worn($u) === '');
// 2.7.14: worn = the EQUIPPED items (user_wear_slots), whatever is switched on in the Puzzle box
foreach (['travel-cloak', 'flood-boots-b', 'wayfarers-hat'] as $s) give_item($uid, item_id_by_slug($s), 1);
$wear = fn(string $slot, string $slug) => q('INSERT INTO user_wear_slots (user_id, slot, item_slug, worn_at) VALUES (?, ?, ?, ?)', [$uid, $slot, $slug, now()]);
$wear('cloak', 'travel-cloak'); $wear('footwear', 'flood-boots-b');
q('INSERT INTO pf_deck_pieces (user_id, piece_key, starter, active, pos) VALUES (?, ?, 0, 1, 100)', [$uid, 'w:wayfarers-hat']);   // switched on but NOT worn
// gnome25_worn caches per request: ask in a fresh process for each state
$ask = function () use ($argv, $uid): string { return trim((string)shell_exec('php -d error_reporting=0 -r \'$_SERVER["SCRIPT_NAME"]="/adventure.php"; require "' . $argv[1] . '/includes/bootstrap.php"; require_once "' . $argv[1] . '/includes/gnome25.php"; echo gnome25_worn(["id" => ' . $uid . ']);\' 2>/dev/null')); };
ok('two items worn (the cloak and the boots, cut b): the codes bc, sorted; the Hat switched on in the box but not worn is not drawn', $ask() === 'bc', $ask());
$wear('hat', 'wayfarers-hat');
ok('put the Hat on: bch', $ask() === 'bch', $ask());
echo "== the url\n";
$url = trim((string)shell_exec('php -d error_reporting=0 -r \'$_SERVER["SCRIPT_NAME"]="/adventure.php"; require "' . $argv[1] . '/includes/bootstrap.php"; require_once "' . $argv[1] . '/includes/gnome25.php"; echo gnome25_url(q_one("SELECT * FROM users WHERE id = ' . $uid . '"), "front");\' 2>/dev/null'));
ok('gnome25_url carries the worn codes as w=', str_contains($url, 'w=bch'), $url);

echo "== the layers (the real art)\n";
$npx = function (string $png): int { $im = imagecreatefromstring($png); $n = 0; for ($x = 0; $x < 512; $x++) for ($y = 0; $y < 80; $y++) if (((imagecolorat($im, $x, $y) >> 24) & 127) === 0) $n++; return $n; };
$plain = gnome25_compose('front', []);
ok('no wearables: the strip is a PNG', $plain !== '' && str_starts_with($plain, "\x89PNG"));
foreach (['front', 'back', 'side'] as $v) {
    $p0 = gnome25_compose($v, []);
    foreach (GNOME25_WEAR as $code => $layer) {
        ok("$v-$layer.png exists, 512x80", is_file($dir . "$v-$layer.png") && getimagesize($dir . "$v-$layer.png")[0] === 512 && getimagesize($dir . "$v-$layer.png")[1] === 80);
        ok("$v: wearing '$code' ($layer) changes the strip", gnome25_compose($v, [], [], $code) !== $p0);
    }
}
ok('wear codes in any order give the same strip', gnome25_compose('front', [], [], 'ch') === gnome25_compose('front', [], [], 'hc'));
ok('all five worn: more pixels than the plain strip', $npx(gnome25_compose('front', [], [], 'bcghp')) > $npx($plain));
q('DELETE FROM pf_deck_pieces WHERE user_id = ?', [$uid]); q('DELETE FROM user_wear_slots WHERE user_id = ?', [$uid]);
echo $fails ? "$fails FAILED\n" : "ok\n";
exit($fails ? 1 : 0);
