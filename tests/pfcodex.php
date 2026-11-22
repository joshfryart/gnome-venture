<?php
// 2.7.55 Creature Codex on an installed copy (player sprout): php tests/pfcodex.php GAMEDIR set|check
// 2.7.57: a 2.7.55 table (no pd column) gets the column; a piece's look (t, v, tag, ik, edges) is kept at first sight; seen pieces are drawn (data-p for assets/pfcodex.js),
// a region piece outside the standard deck too; unseen pieces are dashed blanks; a pre-2.7.57 row gets its look the next time; after a win: what it does.
$G = $argv[1]; $mode = $argv[2];
$_SERVER['SCRIPT_NAME'] = '/puzzlebox.php'; require $G . '/includes/bootstrap.php'; require_once $G . '/includes/adventure.php'; require_once $G . '/includes/pfight_game.php'; require_once $G . '/includes/pfdeck.php'; require_once $G . '/includes/pfdeck_view.php'; require_once $G . '/includes/pfcodex.php';
$u = q_one("SELECT * FROM users WHERE username = 'sprout'");
$bad = 0; function chk(string $n, bool $ok, $got = ''): void { global $bad; echo ($ok ? 'ok   ' : 'FAIL ') . $n . ($ok ? '' : ' (got ' . json_encode($got) . ')') . "\n"; if (!$ok) $bad++; }
$L = pfcx_creatures(); $slugs = array_keys($L);
chk('the codex lists every creature of pf_creatures.txt', count($L) === count(pfd_creature_rows()) && count($L) >= 300, count($L));
$a = $slugs[0]; $b = $slugs[1];
$ovA = pfd_creature_overlay(['slug' => $a, 'size' => $L[$a]['size'], 'name' => $L[$a]['name'], 'level' => $L[$a]['level']]);
$deckA = pfd_foe_row($ovA, '')['deck'];
$p0 = $deckA[0];
$E = ['L' => ['hole', 'body'], 'R' => ['knob', 'mind'], 'T' => ['flat', null], 'B' => ['knob', 'craft']];
$s = ['pcs' => [1 => ['by' => 'foe', 'tile' => ['n' => 'Test Nip', 't' => 'hurt', 'v' => 7, 'tag' => '', 'e' => $E]], 2 => ['by' => 'me', 'tile' => ['n' => 'My Swing']], 3 => ['by' => 'foe', 'tile' => ['n' => 'Test Nip']],
    4 => ['by' => 'foe', 'tile' => ['n' => (string)$p0['n'], 't' => $p0['t'], 'v' => 99, 'tag' => (string)$p0['tag'], 'e' => $E]]]];
if ($mode === 'set') {
    q('DROP TABLE IF EXISTS pf_codex');
    db()->exec('CREATE TABLE pf_codex (user_id INTEGER NOT NULL, slug VARCHAR(80) NOT NULL, piece VARCHAR(64) NOT NULL, won INTEGER NOT NULL DEFAULT 0, PRIMARY KEY (user_id, slug, piece))');   // the 2.7.55 table
    q("INSERT INTO pf_codex (user_id, slug, piece, won) VALUES (?, ?, 'Old Region Bite', 0)", [$u['id'], $a]);   // rows from before 2.7.57 (no look kept)
    q("INSERT INTO pf_codex (user_id, slug, piece, won) VALUES (?, ?, 'Old Then Seen', 0)", [$u['id'], $a]);
    pfcx_note($u, ['slug' => $a], $s); pfcx_note($u, ['slug' => $b], ['pcs' => []], true); pfcx_note($u, ['slug' => $a], $s);
    pfcx_note($u, ['slug' => $a], ['pcs' => [['by' => 'foe', 'tile' => ['n' => 'Old Then Seen', 't' => 'guard', 'v' => 4, 'tag' => '', 'e' => $E]]]]);
    echo "$a $b\n"; exit(0);
}
$n = (int)q_val("SELECT COUNT(*) FROM pf_codex WHERE user_id = ?", [$u['id']]);
chk('rows: creature a + 4 pieces (deduped), creature b', $n === 6, $n);
chk('only the foe piece is kept', (int)q_val("SELECT COUNT(*) FROM pf_codex WHERE piece = 'My Swing'") === 0);
chk('b is beaten, a is not', (int)q_val("SELECT won FROM pf_codex WHERE slug = ? AND piece = ''", [$b]) === 1 && (int)q_val("SELECT won FROM pf_codex WHERE slug = ? AND piece = ''", [$a]) === 0);
chk('a 2.7.55 table got the pd column', pfcx_has_pd());
$pd = json_decode((string)q_val("SELECT pd FROM pf_codex WHERE slug = ? AND piece = 'Test Nip'", [$a]), true);
chk('a piece keeps its look at first sight (t, v, edges)', is_array($pd) && $pd['t'] === 'hurt' && $pd['v'] === 7 && ($pd['e']['R'][0] ?? '') === 'knob', $pd);
chk('an old row gets its look when the piece is seen again', q_val("SELECT pd FROM pf_codex WHERE slug = ? AND piece = 'Old Then Seen'", [$a]) !== null);
chk('an old row not seen again keeps pd NULL', q_val("SELECT pd FROM pf_codex WHERE slug = ? AND piece = 'Old Region Bite'", [$a]) === null);
$h = pfcx_html($u, $a);
chk('met creature sheet shows its piece and hides the description', str_contains($h, 'Test Nip') && str_contains($h, 'Win a fight against it'));
chk('a seen piece outside the deck is drawn (data-p with its value and the creature tint)', (bool)preg_match('/<li class="cx-pc f-body" aria-label="Test Nip, Hurt 7[^"]*"><span class="cx-art"><i class="cxp" data-p="[^"]*&quot;v&quot;:7,&quot;tint&quot;:' . (crc32($a) % 360) . '/', $h), substr($h, (int)strpos($h, 'Test Nip') - 200, 600));
$v0 = pfv_foe_v($ovA, (int)$p0['v']);
chk('a standard deck piece shows the deck value (as on the pre-fight card), not the board number', str_contains($h, 'aria-label="' . htmlspecialchars((string)$p0['n'], ENT_QUOTES) . ', ' . PFV_TYPE[$p0['t']] . ' ' . $v0), $v0);
$blanks = substr_count($h, '<li class="cx-pc cx-q"'); $deckN = count(array_unique(array_column($deckA, 'n')));
chk('unseen deck pieces are dashed blanks', $blanks === $deckN - 1, [$blanks, $deckN]);
chk('a piece outside the deck seen before 2.7.57 is named and waits for its look', str_contains($h, 'Old Region Bite') && str_contains($h, 'Drawn after your next meeting'));
chk('the sheet closes back to the tile (anchor) and carries the script', str_contains($h, 'href="' . htmlspecialchars(url('puzzlebox.php?t=codex')) . '#cx-' . $a . '"') && str_contains($h, 'assets/pfcodex.js'));
chk('no "What it does" before a win', !str_contains($h, 'What it does'));
$h = pfcx_html($u, $b);
chk('beaten creature sheet shows About text and level', !str_contains($h, 'Win a fight against it') && str_contains($h, 'Level '));
$ovB = pfd_creature_overlay(['slug' => $b, 'size' => $L[$b]['size']]); $hasRule = pfb_kind_of(['class' => pfd_class($ovB)], $L[$b]['size']) !== '' || !empty($ovB['ab']);
chk('beaten creature sheet says what it does (class rule / abilities) when it has any', !$hasRule || str_contains($h, 'What it does'));
$z = array_values(array_filter($slugs, fn($x) => $x !== $a && $x !== $b))[0]; $h = pfcx_html($u, $z);
chk('an unmet creature stays unknown (no name in the sheet)', !str_contains($h, '>' . htmlspecialchars($L[$z]['name']) . '</h3>') && str_contains($h, 'Unknown creature') && !str_contains($h, 'class="cxp"'));
exit($bad ? 1 : 0);
