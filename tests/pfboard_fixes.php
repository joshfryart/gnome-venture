<?php
// Regression tests for the 2.6.61 board fixes (no DB): php tests/pfboard_fixes.php [path/to/pfboard.php]. Each check names its scenario and expected result.
// The optional path runs the same checks against another copy of the engine (used to watch them FAIL on the pre-fix code).
require ($argv[1] ?? __DIR__ . '/../game/includes/pfboard.php');
$bad = 0;
function chk(string $name, bool $ok, string $got = ''): void { global $bad; echo ($ok ? 'ok   ' : 'FAIL ') . $name . ($ok ? '' : " (got $got)") . "\n"; if (!$ok) $bad++; }
function fx_me(int $lv = 1): array   // the same gnome the playtest harness builds (calling by level, 5 Hurt / 3 Charm / 3 Guard box), so seeds match tests/pf_play.php
{
    $m = max(0, intdiv($lv + 3, 14)); $st = ['grit' => $m, 'nimble' => $m, 'hardiness' => $m, 'charm' => $m, 'lore' => $m, 'luck' => $m, 'level' => $lv];
    $cals = array_keys(PF_CALLING_TILE); $cal = $cals[$lv % 6]; $own = pf_collection($lv, $cal); $cap = pf_box_capacity($lv);
    $want = ['hurt' => 5, 'charm' => 3, 'guard' => 3, 'heal' => 1, 'trick' => 1, 'item' => 1, 'soothe' => 0]; $box = []; $n = [];
    foreach ($own as $k) { $t = pf_tiles()[$k]['t']; if (($n[$t] ?? 0) < ($want[$t] ?? 0) && count($box) < $cap) { $box[] = $k; $n[$t] = ($n[$t] ?? 0) + 1; } }
    foreach ($own as $k) if (!in_array($k, $box, true) && count($box) < $cap) $box[] = $k;
    $max = 20 + 3 * $lv + 5 * $m;
    return ['hp' => $max, 'max_hp' => $max, 'stats' => $st, 'deck' => pf_player_deck($st, $cal, 1 + intdiv($lv, 12), [], [], [], true, $box), 'luck' => $m];
}
$owl = ['slug' => 'tawny-owl', 'name' => 'Tawny Owl', 'size' => 'large', 'level' => 17, 'dmg_die' => 8, 'dmg_bonus' => 4];
$ants = ['slug' => 'ant-scouts', 'name' => 'Ant Scouts', 'size' => 'small', 'level' => 2, 'dmg_die' => 4, 'dmg_bonus' => 0];
$boss = ['slug' => 'ancient-snapper', 'name' => 'Ancient Snapper', 'size' => 'boss', 'level' => 30, 'dmg_die' => 10, 'dmg_bonus' => 7];

// 1. a creature whose whole hand is Hurt starts with a non-Hurt piece (tawny-owl seed 1088, level 1: its hand is all Hurt; it used to put out a Lunge)
$hurtStarts = 0; $hurtStartsBlank = 0; $badHand = 0;
for ($seed = 1081; $seed <= 1140; $seed++) {   // includes 1088 (the haiku-found case)   // the owl's whole 3-piece hand is Hurt for some seeds (rng shifts with the player's deck): sweep them
    $s = pfb_new(fx_me(1), $owl, $seed);
    foreach ($s['pcs'] as $p) if ($p['by'] === 'foe' && $p['tile']['t'] === 'hurt') $hurtStarts++;
    if (count($s['foe']['hand']) !== $s['foe']['hsize']) $badHand++;
    $sb = pfb_new(fx_me(1), $owl, $seed, ['blank' => true]); pfb_start($sb, 0, 'L');
    foreach ($sb['pcs'] as $p) if ($p['by'] === 'foe' && $p['tile']['t'] === 'hurt') $hurtStartsBlank++;
}
chk('creature start piece is never Hurt (tawny-owl, seeds 1081-1140, classic)', $hurtStarts === 0, "$hurtStarts hurt starts");
chk('creature start piece is never Hurt (tawny-owl, seeds 1081-1140, blank)', $hurtStartsBlank === 0, "$hurtStartsBlank hurt starts");
chk('creature hand is back to full size after its start (seeds 1081-1140)', $badHand === 0, "$badHand short hands");

// 2. an empty draw pile refilled from the discard is reported
$s = pfb_new(fx_me(5), $ants, 3); $s['me']['draw'] = []; $s['me']['discard'] = array_slice($s['me']['hand'], 0, 2); $s['me']['hand'] = array_slice($s['me']['hand'], 2); $s['reshuf'] = [];
pf_draw($s, 'me', 5);
chk('draw pile refilled from discard: it is reported', in_array('me', $s['reshuf'] ?? [], true), json_encode($s['reshuf'] ?? null));

// 3. a fight that ends mid-chain says how many linked pieces did not fire
$s = pfb_new(fx_me(5), $ants, 3); $s['pcs'] = []; $s['cell'] = []; $s['pid'] = 0; $s['seq'] = 0;
$mk = fn(string $k, string $t, int $v, ?string $r) => ['k' => $k, 'n' => $k, 't' => $t, 'v' => $v, 'tag' => '', 'r' => $r];
$put = function (array &$s, string $by, array $tile, int $x, int $y): int { $id = ++$s['pid']; $s['seq']++; $s['pcs'][$id] = ['id' => $id, 'by' => $by, 'tile' => $tile, 'x' => $x, 'y' => $y, 'born' => 1, 'seq' => $s['seq']]; $s['cell']["$x,$y"] = $id; return $id; };
$put($s, 'me', $mk('fx_tail', 'hurt', 3, 'mind'), 2, 2);          // right knob mind: fits the root's left hole (charm = hole mind)
$root = $put($s, 'me', $mk('fx_root', 'charm', 500, null), 3, 2);  // a Charm so big the fight ends on it; one piece is linked behind it
$s['cm'] = 1.0; $s['bar']['now'] = 0.0; $s['bar']['max'] = 5.0; $s['cut'] = 0; $s['over'] = null;
$ev = pfb_fire($s, $root);
chk('fight ends on the root: the linked piece behind it is counted as cut', ($s['over'] ?? null) === 'charmed' && ($s['cut'] ?? 0) === 1, json_encode([$s['over'] ?? null, $s['cut'] ?? null, count($ev)]));

// 4. pass during the start phase is refused with the start message
$s = pfb_new(fx_me(5), $ants, 3, ['blank' => true]);
$r = pfb_pass($s, $s['turn']);
chk('pass before the start piece is picked: refused with the start message', $r['err'] === 'Pick your start piece first.', (string)$r['err']);

// 5. hostile creatures: charm counts PF_HOSTILE_CM (0.6); gentle unchanged
$s = pfb_new(fx_me(5), $ants, 3);
chk('hostile creature: charm multiplier is 0.6', abs($s['cm'] - 0.6) < 1e-9, (string)$s['cm']);
$s = pfb_new(fx_me(5), ['slug' => 'garden-snail', 'name' => 'Snail', 'size' => 'small', 'level' => 1, 'dmg_die' => 4, 'dmg_bonus' => 0], 3);
chk('gentle creature: charm multiplier stays 1.0', abs($s['cm'] - 1.0) < 1e-9, (string)$s['cm']);

// 6. a boss's pieces count x1.2 more; the blank variant x1.2 more again (raw tiles come from pf_new at the same seed)
$allV = fn(array $st) => array_map(fn($t) => $t['v'], array_merge($st['foe']['draw'], $st['foe']['hand'], $st['foe']['discard'], array_map(fn($p) => $p['tile'], array_filter($st['pcs'] ?? [], fn($p) => $p['by'] === 'foe'))));
$raw = pf_new(fx_me(20), $boss, 9); $b = pfb_new(fx_me(20), $boss, 9);
$exp = array_map(fn($v) => max(1, (int)round($v * 0.62 * 1.2)), $allV($raw)); $got = $allV($b); sort($exp); sort($got);
chk('boss foe pieces: values are base x 0.62 x 1.2', $exp === $got, json_encode([array_slice($exp, 0, 6), array_slice($got, 0, 6)]));
$raw = pf_new(fx_me(5), $ants, 4); $bb = pfb_new(fx_me(5), $ants, 4, ['blank' => true]);
$exp = array_map(fn($v) => max(1, (int)round($v * 0.62 * 1.2)), $allV($raw)); $got = $allV($bb); sort($exp); sort($got);
chk('blank variant: every creature piece is base x 0.62 x 1.2', $exp === $got, json_encode([array_slice($exp, 0, 6), array_slice($got, 0, 6)]));

echo $bad ? "$bad FAILED\n" : "all ok\n"; exit($bad ? 1 : 0);
