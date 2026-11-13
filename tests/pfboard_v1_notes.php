<?php
// 14: 2.6.76 notices (required by pfboard_v1.php): the creature acts more than normal or you lose a play, and the page says so. Events k 'note' (note = quick | slow | trip); JS parity is in pfengine_js.
echo "== 14. notices: Quick, a lost creature turn, a trip, a chain through the other side's piece (2.6.76)\n";
$s = v1_bare('medium'); $s['foe']['hand'] = [['tag' => 'quick', 'n' => 'Skitter'] + v1_tile($s, 'f:q', 'hurt', 3, 'mind', 'creature'), v1_tile($s, 'f:h', 'guard', 3, 'body', 'creature')];
v1_put($s, 'me', v1_tile($s, 'c1', 'charm', 3, 'body'), 3, 2);
$ev = pfb_foe_turn($s, 0); $notes = array_values(array_filter($ev, fn($e) => isset($e['note'])));
chk('Quick: the creature places a Quick piece and a note names it', count($notes) === 1 && $notes[0]['note'] === 'quick' && $notes[0]['n'] !== '' && $notes[0]['by'] === 'foe', $notes);
chk('Quick: the note line says the creature plays a second piece', str_contains(pfight_line($notes[0], 'Owl'), 'Quick. The Owl plays a second piece') && str_contains(pfight_line($notes[0], 'Owl'), $notes[0]['n']), pfight_line($notes[0], 'Owl'));
$chip = pfight_chip_event($notes[0], null); chk('Quick: it has a history chip (by the creature, no piece art)', $chip['by'] === 'foe' && $chip['types'] === ['note'] && str_contains($chip['txt'], 'Quick'), $chip);
$s = v1_bare('medium', ['tags' => 0]); $s['foe']['hand'] = [['tag' => 'quick'] + v1_tile($s, 'f:q', 'hurt', 3, 'mind', 'creature')]; $s['foe']['again'] = 0;
$ev = pfb_foe_turn($s, 0); chk('creature tags off: no notes', !array_filter($ev, fn($e) => isset($e['note'])));
$s = v1_bare('medium'); $s['foe']['hand'] = [v1_tile($s, 'f:h', 'hurt', 3, 'mind', 'creature')]; v1_put($s, 'me', v1_tile($s, 'c1', 'charm', 3, 'body'), 3, 2); $s['foe']['slow'] = 1; $n0 = count($s['pcs']);
$ev = pfb_foe_turn($s, 0);
chk('lost turn: a slowed creature places nothing and a note says so', count($s['pcs']) === $n0 && count($ev) === 1 && $ev[0]['note'] === 'slow' && str_contains(pfight_line($ev[0], 'Owl'), 'loses its turn'), $ev);
$s = v1_bare('medium'); $s['me']['hand'] = []; $s['me']['slowdraw'] = 1; $h0 = 0;
$r = pfb_pass($s, $s['turn']); $last = end($r['ev']);
chk('trip: you draw one fewer, the last event is a note, your state says tripped', $r['err'] === null && ($last['note'] ?? '') === 'trip' && $s['me']['tripped'] === 1 && count($s['me']['hand']) === PF_DRAW - 1 && str_contains(pfight_line($last, 'Owl'), 'Tripped: you draw 1 fewer'), [$r['err'], $last['note'] ?? null, $s['me']['tripped'], count($s['me']['hand'])]);
$s['me']['hand'] = []; $r = pfb_pass($s, $s['turn']);
chk('trip: the next turn is normal again (no note, not tripped)', $r['err'] === null && !array_filter($r['ev'], fn($e) => isset($e['note'])) && $s['me']['tripped'] === 0 && count($s['me']['hand']) === PF_DRAW);
$l = pfight_line(['by' => 'foe', 'ta' => 'me', 't' => 'hurt', 'n' => 'Bash', 'v' => 3, 'dmg' => 3], 'Owl'); chk('a chain through the creature\'s piece: "Your chain fires the Owl\'s Bash"', str_contains($l, 'Your chain fires the Owl’s Bash'), $l);
$l = pfight_line(['by' => 'me', 'ta' => 'foe', 't' => 'guard', 'n' => 'Dodge', 'v' => 3], 'Owl'); chk('its chain through your piece: "The Owl\'s chain fires your Dodge"', str_contains($l, 'The Owl’s chain fires your Dodge'), $l);
$l = pfight_line(['by' => 'me', 'ta' => 'me', 't' => 'hurt', 'n' => 'Swing', 'v' => 3], 'Owl'); chk('your own chain keeps the old line', str_contains($l, 'You play Swing'), $l);
