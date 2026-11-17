<?php
// 2.7.06: a pal piece shaped by a Boon carries the 'boon' tag (its own words), not the plain 'pal' tag. php tests/pf_boon_tag.php GAME_DIR (installed game).
$_SERVER['SCRIPT_NAME'] = '/puzzlebox.php';
require $argv[1] . '/includes/bootstrap.php';
require_once $argv[1] . '/includes/pfight.php';
require_once $argv[1] . '/includes/pfdeck.php';
require_once $argv[1] . '/includes/pfdeck_view.php';
$bad = 0;
function chk(string $name, bool $ok, string $got = ''): void { global $bad; echo ($ok ? 'ok   ' : 'FAIL ') . $name . ($ok ? '' : ' (got ' . $got . ')') . "\n"; if (!$ok) $bad++; }
chk('PF_SPECIAL explains the boon tag', isset(PF_SPECIAL['boon']) && str_contains(PF_SPECIAL['boon'], 'Boon'));
$t = pfv_tag_text(['tag' => 'boon']);
chk('the piece page reads the boon tag as words', is_array($t) && str_contains((string)$t[1], 'Boon'), json_encode($t));
chk('the plain pal tag still reads', is_array(pfv_tag_text(['tag' => 'pal'])));
// deck build: a source pal with boon true gets the boon tag, one without keeps pal
$src = pfd_sources_blank(20, '');
$src['pals'] = [['n' => 'Boony', 't' => 'hurt', 'v' => 6, 'r' => 'mind', 'rank' => 2, 'ref' => '', 'boon' => true], ['n' => 'Plain', 't' => 'guard', 'v' => 5, 'r' => 'craft', 'rank' => 1, 'ref' => '', 'boon' => false]];
$d = pfd_build($src);
$by = []; foreach ($d['pieces'] ?? $d as $p) if (is_array($p) && isset($p['k']) && str_starts_with((string)$p['k'], 'pal:')) $by[$p['k']] = $p['tag'] ?? '';
chk('a Boon pal piece is tagged boon, a plain pal piece pal', ($by['pal:Boony'] ?? '') === 'boon' && ($by['pal:Plain'] ?? '') === 'pal', json_encode($by));
echo $bad ? "$bad FAILED\n" : "all ok\n"; exit($bad ? 1 : 0);
