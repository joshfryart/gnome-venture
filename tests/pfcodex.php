<?php
// 2.7.55 Creature Codex on an installed copy (player sprout): php tests/pfcodex.php GAMEDIR set|check
$G = $argv[1]; $mode = $argv[2];
$_SERVER['SCRIPT_NAME'] = '/puzzlebox.php'; require $G . '/includes/bootstrap.php'; require_once $G . '/includes/adventure.php'; require_once $G . '/includes/pfight_game.php'; require_once $G . '/includes/pfdeck.php'; require_once $G . '/includes/pfcodex.php';
$u = q_one("SELECT * FROM users WHERE username = 'sprout'");
$bad = 0; function chk(string $n, bool $ok, $got = ''): void { global $bad; echo ($ok ? 'ok   ' : 'FAIL ') . $n . ($ok ? '' : ' (got ' . json_encode($got) . ')') . "\n"; if (!$ok) $bad++; }
$L = pfcx_creatures(); $slugs = array_keys($L);
chk('the codex lists every creature of pf_creatures.txt', count($L) === count(pfd_creature_rows()) && count($L) >= 300, count($L));
$a = $slugs[0]; $b = $slugs[1]; $s = ['pcs' => [1 => ['by' => 'foe', 'tile' => ['n' => 'Test Nip']], 2 => ['by' => 'me', 'tile' => ['n' => 'My Swing']], 3 => ['by' => 'foe', 'tile' => ['n' => 'Test Nip']]]];
if ($mode === 'set') {
    pfcx_note($u, ['slug' => $a], $s); pfcx_note($u, ['slug' => $b], ['pcs' => []], true); pfcx_note($u, ['slug' => $a], $s);
    echo "$a $b\n"; exit(0);
}
$n = (int)q_val("SELECT COUNT(*) FROM pf_codex WHERE user_id = ?", [$u['id']]);
chk('rows: creature a + one piece (deduped), creature b', $n === 3, $n);
chk('only the foe piece is kept', (int)q_val("SELECT COUNT(*) FROM pf_codex WHERE piece = 'My Swing'") === 0);
chk('b is beaten, a is not', (int)q_val("SELECT won FROM pf_codex WHERE slug = ? AND piece = ''", [$b]) === 1 && (int)q_val("SELECT won FROM pf_codex WHERE slug = ? AND piece = ''", [$a]) === 0);
$h = pfcx_html($u, $a); chk('met creature sheet shows its piece and hides the description', str_contains($h, 'Test Nip') && str_contains($h, 'Win a fight against it'));
$h = pfcx_html($u, $b); chk('beaten creature sheet shows About text and level', !str_contains($h, 'Win a fight against it') && str_contains($h, 'Level '));
$z = array_values(array_filter($slugs, fn($x) => $x !== $a && $x !== $b))[0]; $h = pfcx_html($u, $z);
chk('an unmet creature stays unknown (no name in the sheet)', !str_contains($h, '<h3>' . htmlspecialchars($L[$z]['name']) . '</h3>') && str_contains($h, 'Unknown creature'));
exit($bad ? 1 : 0);
