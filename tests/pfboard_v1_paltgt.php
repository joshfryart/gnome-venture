<?php
// 31: 2.7.08 PAL TARGETING (required by pfboard_v1.php; claude/engine-2.7.08-notes.md "Pal targeting"). A pal piece you PLACE knocks the creature's strongest piece off the board after its chain:
// the highest value no stronger than the pal piece itself, ties by the fewest steps from the pal piece, then the oldest. New fights only (rule key paltgt); a fight saved before keeps PRE 0. Mirrored in tools/pfengine.js (palTarget / palNip).
echo "== 31. pal targeting: a pal piece you place knocks off the creature's strongest piece (2.7.08)\n";
$pt = function (array $over = []) { $s = v1_bare('medium', $over + ['paltgt' => 1]); $s['foe']['hand'] = []; v1_put($s, 'me', v1_tile($s, 'dodge', 'guard', 2, 'body'), 1, 2); return $s; };   // an anchor of yours at (1,2): pieces must go next to one
$palT = function (array $s, int $v = 6) { $t = v1_tile($s, 'pal:Wolf', 'hurt', $v, 'body', 'pal'); $t['n'] = 'Wolf'; return $t; };
$first = fn(array $s, array $t) => pfb_cells($s, $t, 'me')[0] ?? [-1, -1];
$nips = fn(?array $r) => array_values(array_filter($r ?? [], fn($e) => ($e['note'] ?? '') === 'palaim'));
chk('a new fight has pal targeting on; a fight saved without the key resolves it to 0 (PRE)', pfb_v1r(pfb_new(v1_me(), v1_foe('medium'), 5, ['v1' => true]), 'paltgt') === 1 && PFB_V1_PRE['paltgt'] === 0);

// the rule itself (no placement): value first, then steps, then the oldest
$s = $pt(); $weak = v1_put($s, 'foe', v1_tile($s, 'c1', 'hurt', 3, 'body', 'creature'), 0, 4); $far = v1_put($s, 'foe', v1_tile($s, 'c2', 'guard', 6, 'mind', 'creature'), 4, 0); $near = v1_put($s, 'foe', v1_tile($s, 'c3', 'hurt', 6, 'craft', 'creature'), 4, 4);
chk('the strongest piece wins over a weaker one even when the weaker is next to the pal', pfb_pal_target($s, 0, 3) !== $weak);
chk('of two 6s, the one fewer steps from the pal (from (3,4): (4,4) is 1 step, (4,0) is 5)', pfb_pal_target($s, 3, 4) === $near && pfb_pal_target($s, 4, 1) === $far, [pfb_pal_target($s, 3, 4), pfb_pal_target($s, 4, 1)]);
$s2 = $pt(); $a = v1_put($s2, 'foe', v1_tile($s2, 'c1', 'hurt', 5, 'body', 'creature'), 4, 0); $b = v1_put($s2, 'foe', v1_tile($s2, 'c2', 'hurt', 5, 'body', 'creature'), 0, 4);
chk('a full tie (value and steps) takes the oldest piece', pfb_pal_target($s2, 2, 2) === $a && pfb_pal_target($s2, 0, 3) === $b, [pfb_pal_target($s2, 2, 2), pfb_pal_target($s2, 0, 3)]);
chk('a piece stronger than the pal is left alone: a pal of 5 takes the 3, a pal of 2 takes nothing', pfb_pal_target($s, 4, 1, 5) === $weak && pfb_pal_target($s, 4, 1, 2) === null && pfb_pal_target($s, 4, 1, 6) === $far);
$s2 = $pt(); v1_put($s2, 'env', v1_env('rain'), 4, 4); chk('no creature piece out (only yours and the environment): no target', pfb_pal_target($s2, 2, 2) === null);

// arrange: the three pieces above; act: place the pal on its first legal cell; assert: the piece pfb_pal_target named is gone
$t = $palT($s); [$cx, $cy] = $first($s, $t); $want = pfb_pal_target($s, $cx, $cy, 6); $d0 = count($s['foe']['discard']);
$r = v1_place($s, 'me', $t, $cx, $cy); $nip = $nips($r);
chk('placing the pal (6) knocks off the strongest piece it can match (a 6), the others stay', $cx >= 0 && count($nip) === 1 && $nip[0]['tid'] === $want && in_array($want, [$near, $far], true) && !isset($s['pcs'][$want]) && isset($s['pcs'][$weak]), [$cx, $cy, $nip, array_keys($s['pcs'])]);
chk('the knocked-off piece goes to the creature\'s discard and the gone list as used by you; its cell is free', count($s['foe']['discard']) === $d0 + 1 && !in_array($want, $s['cell'], true) && (end($s['spent'])['used'] ?? '') === 'me' && (end($s['spent'])['id'] ?? 0) === $want, count($s['foe']['discard']));
chk('the notice names the pal and the piece, is yours, and carries no chain id', ($nip[0]['by'] ?? '') === 'me' && ($nip[0]['pal'] ?? '') === 'Wolf' && in_array($nip[0]['n'] ?? '', ['C2', 'C3'], true) && !isset($nip[0]['id']), $nip[0] ?? null);
$ln = pfight_line($nip[0] ?? ['note' => 'x', 'n' => '', 'by' => 'me'], 'Owl'); $ch = pfight_chip_event($nip[0] ?? ['note' => 'x', 'n' => '', 'by' => 'me'], null)['txt'];
chk('the log line and the history chip say so', str_contains($ln, 'Wolf goes for the Owl’s strongest piece: its C') && str_contains($ch, 'knocks off C'), [$ln, $ch]);

$s = $pt(); v1_put($s, 'env', v1_env('rain'), 4, 4); $t = $palT($s); [$cx, $cy] = $first($s, $t); $r = v1_place($s, 'me', $t, $cx, $cy);
chk('no creature piece out: placing the pal gives no notice', $r !== null && !$nips($r));
$s = $pt(); $c = v1_put($s, 'foe', v1_tile($s, 'c1', 'hurt', 6, 'body', 'creature'), 4, 0); $t = v1_tile($s, 'swing', 'hurt', 4, 'body'); [$cx, $cy] = $first($s, $t); $r = v1_place($s, 'me', $t, $cx, $cy);
chk('a piece that is not a pal\'s knocks nothing off', $r !== null && isset($s['pcs'][$c]) && !$nips($r));
$s = $pt(['paltgt' => 0]); $c = v1_put($s, 'foe', v1_tile($s, 'c1', 'hurt', 6, 'body', 'creature'), 4, 0); $t = $palT($s); [$cx, $cy] = $first($s, $t); $r = v1_place($s, 'me', $t, $cx, $cy);
chk('a fight without the rule (saved before 2.7.08): the pal piece knocks nothing off', $r !== null && isset($s['pcs'][$c]));
$s = $pt(); $c = v1_put($s, 'foe', v1_tile($s, 'c1', 'hurt', 6, 'body', 'creature'), 4, 0); $t = $palT($s); unset($t['src']); [$cx, $cy] = $first($s, $t); $r = v1_place($s, 'me', $t, $cx, $cy);
chk('a pal piece known by its key alone (pal:...) counts as a pal piece', $r !== null && !isset($s['pcs'][$c]));
$s = $pt(); $c = v1_put($s, 'foe', v1_tile($s, 'c1', 'hurt', 6, 'body', 'creature'), 4, 0); $t = $palT($s); [$cx, $cy] = $first($s, $t); $s['foe']['hand'] = [$t]; $r = pfb_place($s, 'foe', 0, $cx, $cy);
chk('the creature placing a pal-sourced piece never triggers it (only yours)', $r !== null && isset($s['pcs'][$c]));

// the preview: each lit cell names the piece the pal would knock off from there
$s = $pt(); $s['me']['hand'] = [$palT($s)]; v1_put($s, 'foe', v1_tile($s, 'c1', 'hurt', 6, 'body', 'creature'), 0, 4); v1_put($s, 'foe', v1_tile($s, 'c2', 'hurt', 6, 'body', 'creature'), 4, 0);
$pv = pfb_cell_preview($s, 0); $okp = $pv !== [];
foreach ($pv as $xy => $q) { [$x, $y] = array_map('intval', explode(',', $xy)); if (($q['pal']['id'] ?? null) !== pfb_pal_target($s, $x, $y, (int)$s['me']['hand'][0]['v'])) $okp = false; }
chk('the cell preview names, on every lit cell, the target pfb_pal_target gives for that cell', $okp, $pv);
$s['me']['hand'] = [v1_tile($s, 'swing', 'hurt', 4, 'body')]; $pv = pfb_cell_preview($s, 0);
chk('a piece that is not a pal\'s has no target in the preview', $pv !== [] && !array_filter($pv, fn($c) => isset($c['pal'])));
$v = pfb_view($pt()); chk('the view carries the rule for the page (v1.paltgt)', (int)($v['v1']['paltgt'] ?? -1) === 1);
