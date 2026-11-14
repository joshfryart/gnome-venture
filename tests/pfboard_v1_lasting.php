<?php
// 2.6.98 WEEK 2a, T14: a board that lasts (section 17 of tests/pfboard_v1.php, which includes this file and its helpers).
// keepmine: a chain of 3+ spends only the creature's and the environment's pieces. useroot: it spends only the piece you placed.
// aimhit: the creature's Hurt aim on a cell where YOUR piece stands strikes that piece (a Guard at least as strong holds); a non-Hurt aim still picks again.

echo "== 17. a board that lasts (keepmine, useroot, aimhit)\n";
$swing17 = $swing;   // the row of section 4: charm -> Swing -> charm links
$row17 = function (array $over = []) use ($swing17) { $s = v1_bare('medium', $over); $a = v1_put($s, 'me', v1_tile($s, 'c1', 'charm', 3, 'body'), 1, 2); $b = v1_put($s, 'foe', v1_tile($s, 'f:c2', 'charm', 3, 'craft', 'creature'), 3, 2); return [$s, $a, $b]; };
chk('PRE: the three switches are off in a new fight (default OFF until T15 decides)', array_intersect_key(v1_bare()['v1'], ['keepmine' => 1, 'aimhit' => 1, 'useroot' => 1]) === ['keepmine' => 0, 'aimhit' => 0, 'useroot' => 0]);

// ---- keepmine
[$s, $a, $b] = $row17(['keepmine' => 1]); $ev = v1_place($s, 'me', $swing17, 2, 2);
chk('keepmine: a chain of 3 (two of yours, one the creature\'s) leaves your pieces on the board and removes the creature\'s', $ev && count($ev) === 3 && isset($s['pcs'][$a]) && !isset($s['pcs'][$b]) && count($s['pcs']) === 2 && count($s['spent']) === 1 && ($s['spent'][0]['by'] ?? '') === 'foe', [array_keys($s['pcs']), count($s['spent'])]);
chk('keepmine: the creature\'s piece is in ITS discard; the used list names only it', count($ev[0]['used'] ?? []) === 1 && $ev[0]['used'][0] === $b, $ev[0]['used'] ?? null);
[$s, $a, $b] = $row17(['keepmine' => 1]); $s['pcs'][$a]['by'] = 'foe'; $s['pcs'][$a]['tile']['k'] = 'f:c1'; $s['pcs'][$b]['by'] = 'me'; $ev = v1_place($s, 'foe', v1_tile($s, 'f:h', 'hurt', 2, 'mind', 'creature'), 2, 2);
chk('keepmine: when the creature chains through your piece, yours stays too', $ev && count($ev) === 3 && isset($s['pcs'][$b]) && !isset($s['pcs'][$a]), array_keys($s['pcs']));
[$s, $a, $b] = $row17(['keepmine' => 1]); $s['pcs'][$b]['by'] = 'env'; $s['pcs'][$b]['tile'] = v1_env('sun'); $s['env'] = ['draw' => [], 'discard' => [], 'next' => []]; $ev = v1_place($s, 'me', $swing17, 2, 2);
chk('keepmine: an environment piece that fired is still used up', $ev && !isset($s['pcs'][$b]), array_keys($s['pcs']));
[$s, $a, $b] = $row17(['keepmine' => 0]); $ev = v1_place($s, 'me', $swing17, 2, 2);
chk('keepmine 0: the old use-up (all three go)', $ev && $s['pcs'] === []);

// ---- useroot
[$s, $a, $b] = $row17(['useroot' => 1]); $ev = v1_place($s, 'me', $swing17, 2, 2);
chk('useroot: a chain of 3 spends only the piece you placed; the two others stay', $ev && count($ev) === 3 && isset($s['pcs'][$a]) && isset($s['pcs'][$b]) && count($s['pcs']) === 2 && count($s['spent']) === 1, array_keys($s['pcs']));

// ---- aimhit
$aim17 = function (array $over, string $mt, int $mv, string $at = 'hurt', int $av = 6) {
    $s = v1_bare('medium', $over + ['aim' => 1]); $mine = v1_put($s, 'me', v1_tile($s, 'p1', $mt, $mv, 'body'), 2, 2);
    $ft = v1_tile($s, 'f:claw', $at, $av, 'body', 'creature'); $s['foe']['hand'] = [$ft]; $s['foe']['draw'] = []; $s['foe']['plan'] = ['k' => 'f:claw', 'n' => 'Claw', 't' => $at, 'v' => $av, 'tag' => '', 'x' => 2, 'y' => 2];
    return [$s, $mine];
};
[$s, $mine] = $aim17(['aimhit' => 1], 'hurt', 5); $hp = $s['me']['hp']; $fd = count($s['foe']['discard']); $md = count($s['me']['discard']); $ev = pfb_foe_turn($s, 0);
$st = array_values(array_filter($ev, fn($e) => !empty($e['strike'])))[0] ?? null;
chk('aimhit: its Hurt aim of 6 on your Swing breaks the Swing (strike event, broke true), you lose nothing', $st && $st['id'] === $mine && $st['broke'] === true && !isset($s['pcs'][$mine]) && $s['me']['hp'] === $hp && count($s['me']['discard']) === $md + 1, $ev);
chk('aimhit: the creature\'s piece is spent (its discard grows, its hand empties) and it does NOT pick again (reaim 0, nothing new on the board)', count($s['foe']['discard']) === $fd + 1 && $s['foe']['hand'] === [] && $s['reaim'] === 0 && $s['pcs'] === [], [$s['reaim'], array_keys($s['pcs'])]);
[$s, $mine] = $aim17(['aimhit' => 1], 'guard', 7); $hp = $s['me']['hp']; $ev = pfb_foe_turn($s, 0); $st = array_values(array_filter($ev, fn($e) => !empty($e['strike'])))[0] ?? null;
chk('aimhit: a Guard 7 holds against a hit of 6 (broke false, guard 7), the piece stays, no damage', $st && $st['broke'] === false && $st['guard'] === 7 && isset($s['pcs'][$mine]) && $s['me']['hp'] === $hp, $st);
[$s, $mine] = $aim17(['aimhit' => 1], 'guard', 5); $ev = pfb_foe_turn($s, 0); $st = array_values(array_filter($ev, fn($e) => !empty($e['strike'])))[0] ?? null;
chk('aimhit: a Guard 5 against a hit of 6 breaks', $st && $st['broke'] === true && !isset($s['pcs'][$mine]), $st);
[$s, $mine] = $aim17(['aimhit' => 1], 'hurt', 5, 'charm', 4); $ev = pfb_foe_turn($s, 0);
chk('aimhit: a non-Hurt aim on a taken cell still picks again (reaim 1, no strike, your piece stands)', $s['reaim'] === 1 && !array_filter($ev, fn($e) => !empty($e['strike'])) && isset($s['pcs'][$mine]), $s['reaim']);
[$s, $mine] = $aim17(['aimhit' => 0], 'hurt', 5); $ev = pfb_foe_turn($s, 0);
chk('aimhit 0: the old rule (picks again, no strike)', $s['reaim'] === 1 && !array_filter($ev, fn($e) => !empty($e['strike'])) && isset($s['pcs'][$mine]));
[$s, $mine] = $aim17(['aimhit' => 1], 'hurt', 5); $s['pcs'][$mine]['by'] = 'env'; $s['pcs'][$mine]['tile'] = v1_env('sun'); $s['env'] = ['draw' => [], 'discard' => [], 'next' => []];
chk('aimhit: only YOUR piece is struck (an environment piece on the cell: it picks again)', ($ev = pfb_foe_turn($s, 0)) && !array_filter($ev, fn($e) => !empty($e['strike'])) && $s['reaim'] === 1);
