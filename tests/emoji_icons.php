<?php
// v2.0.23 emoji -> icon swap. Usage: php tests/emoji_icons.php path/to/game   (needs no install: bootstrap pieces are stubbed)
$game = $argv[1] ?? __DIR__ . '/../game';
define('APP_ROOT', realpath($game));
define('APP_VERSION', 'T1');
$CONFIG = ['base_url' => ''];
require APP_ROOT . '/includes/functions.php';
$tmp = sys_get_temp_dir() . '/ico_t_' . getmypid(); @mkdir($tmp);
foreach (['seedling', 'energy', 'sparkle', 'herb'] as $s) file_put_contents("$tmp/$s.svg", '<svg xmlns="http://www.w3.org/2000/svg"/>');
// 🍄 mushroom has NO file here: it must stay an emoji. 🌿 herb has a file; add a longer ZWJ row to test longest-match.
file_put_contents("$tmp/map.php", "<?php return ['🌱' => ['seedling', true], '⚡' => ['energy', false, 'Energy'], '✨' => ['sparkle', true], '🌿' => ['herb', true], '🍄' => ['mushroom', true], '🌱‍🌿' => ['herb', false, 'Seedling herb']];");
define('ICO_DIR', $tmp); define('ICO_MAP_FILE', "$tmp/map.php");
require APP_ROOT . '/includes/emoji_icons.php';
$fails = 0;
function ok(string $w, bool $c, string $x = ''): void { global $fails; echo ($c ? '  ok   ' : '  FAIL ') . $w . ($c ? '' : "  $x") . "\n"; if (!$c) $fails++; }
$img = fn($slug) => 'assets/img/ico/' . $slug . '.svg?v=T1';

echo "== text nodes\n";
$o = emoji_swap('<p>Hi 🌱 there ⚡ ✨</p>');
ok('seedling swapped', str_contains($o, $img('seedling')) && !str_contains($o, '🌱'), $o);
ok('decorative alt empty', str_contains($o, 'seedling.svg?v=T1" alt=""'), $o);
ok('named alt on non-decorative', str_contains($o, 'alt="Energy"'), $o);
ok('img has size, lazy, no inline style', str_contains($o, 'width="16" height="16" loading="lazy" decoding="async"') && !str_contains($o, 'style='));
ok('VS16 form swapped, selector dropped', !str_contains(emoji_swap("<p>✨\u{FE0F}</p>"), "\u{FE0F}") && str_contains(emoji_swap("<p>✨\u{FE0F}</p>"), 'sparkle'));
echo "== not swapped\n";
ok('attribute untouched', emoji_swap('<a title="🌱 x" data-e="⚡">go</a>') === '<a title="🌱 x" data-e="⚡">go</a>');
ok('attribute with > untouched', str_contains(emoji_swap('<a title="a > 🌱">🌱</a>'), 'title="a > 🌱"'));
foreach (['script', 'style', 'textarea', 'option', 'title', 'select', 'noscript'] as $t) {
    $h = "<$t>🌱 ⚡</$t>";
    ok("inside <$t>", emoji_swap($h) === $h);
}
$h = '<svg><text>🌱</text></svg>';
ok('inside <svg>', emoji_swap($h) === $h);
$h = '<select><option>🌱</option></select><p>🌱</p>';
$o = emoji_swap($h);
ok('select skipped, next paragraph swapped', str_starts_with($o, '<select><option>🌱</option></select>') && str_contains($o, '<p><img'), $o);
ok('comment untouched', emoji_swap('<!-- 🌱 --><b>x</b>') === '<!-- 🌱 --><b>x</b>');
ok('script then text after', str_contains(emoji_swap('<script>var a="🌱";</script><i>🌱</i>'), '<i><img') && str_contains(emoji_swap('<script>var a="🌱";</script><i>🌱</i>'), 'var a="🌱"'));
echo "== longest match, ZWJ, missing file\n";
$o = emoji_swap("<p>🌱‍🌿</p>");
ok('ZWJ row wins over its parts', substr_count($o, '<img') === 1 && str_contains($o, 'alt="Seedling herb"'), $o);
$o = emoji_swap("<p>🌱‍🌾</p>");   // seedling + ZWJ + sheaf: not in the map, must not be torn apart
ok('unknown ZWJ sequence left whole', $o === "<p>🌱‍🌾</p>", $o);
$o = emoji_swap("<p>🌱🏽</p>");
ok('skin tone not torn off', $o === "<p>🌱🏽</p>", $o);
ok('missing svg stays emoji', emoji_swap('<p>🍄</p>') === '<p>🍄</p>');
echo "== player text\n";
$typed = eu('Rosie 🌱 ⚡ & <b>');
ok('eu writes references', str_contains($typed, '&#x1F331;') && str_contains($typed, '&#x26A1;') && str_contains($typed, '&amp;') && str_contains($typed, '&lt;b&gt;'), $typed);
ok('eu keeps letters and quotes', eu('Ann’s "x"') === e('Ann’s "x"'));
ok('eu output survives the swap untouched', emoji_swap('<h1>' . $typed . '</h1>') === '<h1>' . $typed . '</h1>');
ok('eu decodes to the same emoji', html_entity_decode($typed, ENT_QUOTES, 'UTF-8') === 'Rosie 🌱 ⚡ & <b>');
ok('eu: ZWJ/VS16/keycap joiners escaped', !preg_match('/[\x{200D}\x{FE0F}\x{20E3}]/u', eu("👩‍🌾 ❤\u{FE0F} 1\u{FE0F}\u{20E3}")));
echo "== response filter\n";
$sw = fn($b) => emoji_swap_buffer($b);
ok('HTML page swapped', str_contains($sw('<!doctype html><p>🌱</p>'), '<img'));
ok('JSON text untouched', $sw('{"a":"<b>🌱</b>"}') === '{"a":"<b>🌱</b>"}');
ok('array JSON untouched', $sw('["<i>⚡</i>"]') === '["<i>⚡</i>"]');
ok('plain text without markup untouched', $sw("BEGIN:VCALENDAR\nSUMMARY:🌱\nEND:VCALENDAR") === "BEGIN:VCALENDAR\nSUMMARY:🌱\nEND:VCALENDAR");
// header-based skips need a real SAPI (the CLI keeps no header list): a tiny built-in server
$child = <<<'PHP'
<?php
define('APP_ROOT', getenv('T_ROOT')); define('APP_VERSION', 'T1'); $CONFIG = ['base_url' => ''];
require APP_ROOT . '/includes/functions.php'; define('ICO_DIR', getenv('T_ICO')); define('ICO_MAP_FILE', getenv('T_MAP'));
require APP_ROOT . '/includes/emoji_icons.php';
ob_start('emoji_swap_buffer');
if (isset($_GET['ct'])) header('Content-Type: ' . $_GET['ct']);
if (isset($_GET['loc'])) { header('Location: /x'); http_response_code(302); }
if (isset($_GET['dl'])) header('Content-Disposition: attachment; filename=a.html');
echo '<p>🌱</p>';
PHP;
file_put_contents("$tmp/child.php", $child);
$port = 20000 + getmypid() % 20000;
$proc = proc_open(['php', '-S', "127.0.0.1:$port", "$tmp/child.php"], [1 => ['file', '/dev/null', 'w'], 2 => ['file', '/dev/null', 'w']], $pipes, $tmp, ['T_ROOT' => APP_ROOT, 'T_ICO' => $tmp, 'T_MAP' => "$tmp/map.php", 'PATH' => getenv('PATH')]);
usleep(700000);
$get = fn($q) => (string)@file_get_contents("http://127.0.0.1:$port/?$q", false, stream_context_create(['http' => ['follow_location' => 0, 'ignore_errors' => true]]));
foreach (['application/json' => false, 'text/csv; charset=utf-8' => false, 'text/calendar' => false, 'application/xml' => false, 'text/plain' => false, 'text/html; charset=utf-8' => true] as $ct => $swapped) {
    ok("Content-Type $ct " . ($swapped ? 'swapped' : 'untouched'), $swapped === str_contains($get('ct=' . rawurlencode($ct)), '<img'));
}
ok('no Content-Type header = HTML, swapped', str_contains($get('x=1'), '<img'));
ok('download untouched', !str_contains($get('dl=1'), '<img'));
ok('redirect untouched', !str_contains($get('loc=1'), '<img'));
proc_terminate($proc); proc_close($proc);
array_map('unlink', glob("$tmp/*")); rmdir($tmp);
echo $fails ? "\n$fails FAILED\n" : "\nall ok\n";
exit($fails ? 1 : 0);
