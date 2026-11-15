<?php
// 2.7.00 the worn wearables on the 2.5D gnome rig (includes/gnome25.php): which wearables are worn (switched on in the Puzzle box), the layers drawn for them, and nothing changing without art.
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
pfd_ensure(); q('DELETE FROM pf_deck_pieces WHERE user_id = ?', [$uid]);
ok('nothing switched on: nothing worn', gnome25_worn($u) === '');
$ins = fn(string $k, int $on) => q('INSERT INTO pf_deck_pieces (user_id, piece_key, starter, active, pos) VALUES (?, ?, 0, ?, 100)', [$uid, $k, $on]);
$ins('w:travel-cloak', 1); $ins('w:flood-boots-b', 1); $ins('w:wayfarers-hat', 0); $ins('swing', 1);
$fn = function () use ($u) { $r = new ReflectionFunction('gnome25_worn'); return $r; };
// gnome25_worn caches per request: ask in a fresh process for each state
$ask = function () use ($argv, $uid): string { return trim((string)shell_exec('php -d error_reporting=0 -r \'$_SERVER["SCRIPT_NAME"]="/adventure.php"; require "' . $argv[1] . '/includes/bootstrap.php"; require_once "' . $argv[1] . '/includes/gnome25.php"; echo gnome25_worn(["id" => ' . $uid . ']);\' 2>/dev/null')); };
ok('two wearables on (the cloak and the boots, cut b): the codes bc, sorted; the Hat is off and a non-wearable piece is ignored', $ask() === 'bc', $ask());
q('UPDATE pf_deck_pieces SET active = 1 WHERE user_id = ? AND piece_key = ?', [$uid, 'w:wayfarers-hat']);
ok('switch the Hat on: bch', $ask() === 'bch', $ask());
echo "== the url\n";
$url = trim((string)shell_exec('php -d error_reporting=0 -r \'$_SERVER["SCRIPT_NAME"]="/adventure.php"; require "' . $argv[1] . '/includes/bootstrap.php"; require_once "' . $argv[1] . '/includes/gnome25.php"; echo gnome25_url(q_one("SELECT * FROM users WHERE id = ' . $uid . '"), "front");\' 2>/dev/null'));
ok('gnome25_url carries the worn codes as w=', str_contains($url, 'w=bch'), $url);

echo "== the layers (art made up for the test)\n";
$mk = function (string $file, array $rgb) { $im = imagecreatetruecolor(512, 80); imagealphablending($im, false); imagesavealpha($im, true); imagefill($im, 0, 0, imagecolorallocatealpha($im, 0, 0, 0, 127)); imagefilledrectangle($im, 1, 1, 5, 5, imagecolorallocatealpha($im, $rgb[0], $rgb[1], $rgb[2], 0)); imagepng($im, $file); imagedestroy($im); };
$made = [];
foreach (['front', 'back'] as $v) foreach (['cape' => [255, 0, 0], 'brim' => [0, 255, 0]] as $l => $rgb) { $f = $dir . "$v-$l.png"; if (!is_file($f)) { $mk($f, $rgb); $made[] = $f; } }
$px = function (string $png, int $x, int $y): array { $im = imagecreatefromstring($png); $c = imagecolorat($im, $x, $y); imagedestroy($im); return [($c >> 16) & 255, ($c >> 8) & 255, $c & 255, ($c >> 24) & 127]; };
$plain = gnome25_compose('front', []);
ok('no wearables: the strip is the one it always was (a PNG)', $plain !== '' && str_starts_with($plain, "\x89PNG"));
$withCape = gnome25_compose('front', [], [], 'c');
ok('the cloak layer is drawn (its pixel is there), and the plain strip has no such pixel', $px($withCape, 3, 3)[0] === 255 && $px($withCape, 3, 3)[3] === 0 && $px($plain, 3, 3)[0] !== 255 || $px($plain, 3, 3)[3] === 127, json_encode([$px($withCape, 3, 3), $px($plain, 3, 3)]));
$onlyHat = gnome25_compose('front', [], [], 'h');
ok('the brim layer is drawn over the hat', $px($onlyHat, 3, 3)[1] === 255, json_encode($px($onlyHat, 3, 3)));
ok('a code with no art (the pack, the boots) changes nothing: the strip is byte for byte the plain one', gnome25_compose('front', [], [], 'pb') === $plain);
ok('wear codes in any order give the same strip', gnome25_compose('front', [], [], 'ch') === gnome25_compose('front', [], [], 'hc'));
ok('the back view draws it too', $px(gnome25_compose('back', [], [], 'c'), 3, 3)[0] === 255);
ok('side view has no cape art made for this test: unchanged', gnome25_compose('side', [], [], 'c') === gnome25_compose('side', []));
foreach ($made as $f) @unlink($f);
q('DELETE FROM pf_deck_pieces WHERE user_id = ?', [$uid]);
echo $fails ? "$fails FAILED\n" : "ok\n";
exit($fails ? 1 : 0);
