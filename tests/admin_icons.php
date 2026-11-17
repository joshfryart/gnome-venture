<?php
// 2.7.06 (Josh): every Admin data editor (r:<table>) has its own glyph, not its section's. php tests/admin_icons.php GAME_DIR (installed game).
$_SERVER['SCRIPT_NAME'] = '/admin/index.php';
require $argv[1] . '/includes/bootstrap.php';
require_once $argv[1] . '/includes/admin_menu.php';
$bad = 0;
function chk(string $name, bool $ok, string $got = ''): void { global $bad; echo ($ok ? 'ok   ' : 'FAIL ') . $name . ($ok ? '' : ' (got ' . $got . ')') . "\n"; if (!$ok) $bad++; }
$info = admin_icon('nope');
$seen = []; $n = 0; $miss = [];
foreach (admin_menu_def() as [$sid, , , $entries]) foreach ($entries as $e) {
    if (!str_starts_with($e[0], 'r:')) continue;
    $n++;
    $ic = admin_entry_icon($e[0], $sid);
    if ($ic === $info) $miss[] = $e[0];
    $seen[$ic] = true;
}
chk('there are data editors in the menu', $n > 40, (string)$n);
chk('none of them falls back to the generic info glyph', !$miss, implode(',', $miss));
chk('they use many different glyphs (not one per section)', count($seen) >= 20, (string)count($seen));
chk('the creatures editor and the items editor look different', admin_entry_icon('r:creatures', 'world') !== admin_entry_icon('r:items', 'items'));
chk('a page entry keeps its own glyph', admin_entry_icon('update.php', 'system') === admin_icon('update'));
echo $bad ? "$bad FAILED\n" : "all ok\n"; exit($bad ? 1 : 0);
