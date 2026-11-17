<?php
// 15: 2.6.77 your guard fades when your turn starts (required by pfboard_v1.php), unless a Hold guard is still standing (once). Josh: "my block should drain at the start of my turn unless a special effect".
// The engine resets it in pfb_end_round; since 2.6.77 a Hold guard that the hits already used up no longer comes back (keep = min(keep, what is left)), and notices say what happened (note fade | hold).
echo "== 15. guard fades at the start of your turn, Hold keeps what is left (2.6.77)\n";
$g = function (array $over, int $block, int $keep) { $s = v1_bare('medium', $over ?: []); $s['me']['hand'] = []; $s['foe']['hand'] = []; $s['me']['block'] = $block; $s['me']['keep'] = $keep; $r = pfb_pass($s, $s['turn']); return [$s, $r, array_values(array_filter($r['ev'], fn($e) => in_array($e['note'] ?? '', ['fade', 'hold'], true)))]; };
foreach (['env fight' => [], '2.6.74 terrain fight' => V1_OLD] as $nm => $o) {
    [$s, $r, $nt] = $g($o, 6, 0);
    chk("$nm: a plain guard of 6 is gone when your turn starts", $r['err'] === null && $s['me']['block'] === 0 && $s['me']['kept'] === 0 && $s['me']['faded'] === 6, [$s['me']['block'], $s['me']['faded']]);
    chk("$nm: a note says 'guard fades (-6)', by you, with the shield at 0 from there on", count($nt) === 1 && $nt[0]['note'] === 'fade' && $nt[0]['n'] === '6' && $nt[0]['by'] === 'me' && $nt[0]['gnow'] === 0 && str_contains(pfight_line($nt[0], 'Owl'), 'guard fades (-6)'), $nt);
    [$s, $r, $nt] = $g($o, 8, 8);
    chk("$nm: a Hold guard of 8 that nothing hit carries over once, a note says Hold kept 8", $s['me']['block'] === 8 && $s['me']['keep'] === 0 && $s['me']['faded'] === 0 && count($nt) === 1 && $nt[0]['note'] === 'hold' && $nt[0]['n'] === '8' && $nt[0]['gnow'] === 8, [$s['me']['block'], $nt]);
    [$s, $r, $nt] = $g($o, 3, 8);
    chk("$nm: a Hold guard that the hits used up to 3 carries 3, not 8 (the cause of 'my block stayed up')", $s['me']['block'] === 3 && $s['me']['kept'] === 3, [$s['me']['block'], $s['me']['kept']]);
    [$s, $r, $nt] = $g($o, 10, 4);
    chk("$nm: a plain 6 on top of a Hold 4 fades, the 4 stays: fade -6 and hold 4 notes", $s['me']['block'] === 4 && $s['me']['faded'] === 6 && implode(',', array_column($nt, 'note')) === 'fade,hold', [$s['me']['block'], array_column($nt, 'note')]);
    [$s, $r, $nt] = $g($o, 4, 4); [$s2, $r2, $nt2] = [$s, null, null]; $s2['me']['hand'] = []; $r2 = pfb_pass($s2, $s2['turn']);
    chk("$nm: the Hold guard carries once: the turn after it fades (block 0, no more Hold note)", $s2['me']['block'] === 0 && !array_filter($r2['ev'], fn($e) => ($e['note'] ?? '') === 'hold'), $s2['me']['block']);
}
$s = v1_bare('medium'); $s['me']['hand'] = []; $s['foe']['hand'] = []; $id = v1_put($s, 'me', v1_env('rain'), 2, 2); $e = pfb_env_fire($s, $s['pcs'][$id], 'me'); $rain = $s['me']['block'];
$r = pfb_pass($s, $s['turn']);
chk('Rain fired by you gives guard that fades at the start of your next turn', $rain > 0 && $s['me']['block'] === 0 && $s['me']['faded'] === $rain, [$rain, $s['me']['block']]);
$s = v1_bare('medium'); $s['me']['hand'] = []; $s['me']['block'] = 4; $s['over'] = 'seen_off'; $ev = []; pfb_guard_notes($s, $ev);
chk('no guard notices once the fight is over', $ev === []);
$s = v1_bare('medium'); $s['me']['hand'] = []; $s['me']['block'] = 5; $s['foe']['hand'] = []; $c = json_decode(json_encode($s), true); $r = pfb_pass($c, $c['turn']);
chk('a saved and loaded fight fades the same way', $c['me']['block'] === 0 && $c['me']['faded'] === 5);
$l = pfight_chip_event(['by' => 'me', 'note' => 'fade', 'n' => '6', 't' => 'note', 'k' => 'note'], null); chk('the history chip for the fade is yours and says so', $l['by'] === 'me' && $l['types'] === ['note'] && str_contains($l['txt'], 'fades -6'), $l);
// 2.7.08 puzzle clarity (docs/puzzle-board-proposals.md P7 "creature guard readout"): your Hurt that its guard soaks says how much was blocked, in the history chip and the log line (PHP and tools/pfengine.js chipEvent / line).
$s = v1_bare('medium', V1_OLD); $s['foe']['block'] = 4; v1_put($s, 'foe', v1_tile($s, 'c1', 'charm', 3, 'body'), 2, 2); $r = v1_place($s, 'me', v1_tile($s, 'jab', 'hurt', 9, 'body'), 3, 2); $he = array_values(array_filter($r ?? [], fn($e) => ($e['by'] ?? '') === 'me' && ($e['t'] ?? '') === 'hurt'))[0] ?? [];
chk('your Hurt into its guard of 4 records 4 blocked (engine)', (int)($he['blocked'] ?? 0) === 4, $he);
$l = pfight_chip_event($he, null); chk('the history chip of that Hurt says "4 blocked"', str_contains($l['txt'], '4 blocked'), $l['txt']);
chk('the log line of that Hurt says "4 blocked by its guard"', str_contains(pfight_line($he, 'Owl'), '4 blocked by its guard'), pfight_line($he, 'Owl'));
$he0 = $he; $he0['blocked'] = 0; chk('a Hurt with nothing blocked says nothing about guard', !str_contains(pfight_chip_event($he0, null)['txt'], 'blocked') && !str_contains(pfight_line($he0, 'Owl'), 'blocked'));
