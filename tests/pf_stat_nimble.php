<?php
// Stat pieces, NIMBLE slice: Sidestep (tier 0), Skitter (10), Wrong Turn (15), Pinning Stance (20), Shadow Step (25), Phantom Footing (30).
// New engine parts: 'shove' (the creature's aim moves to a free neighbour cell, farthest from its pieces; a piece that does not fit there picks again, not on its old cell),
// 'stance' (while it stands, a creature re-pick may only use cells touching it; none = it loses that move), 'shadow' (when the creature places its aimed piece,
// the Keeper jumps from your hand onto the fitting cell touching it with most of your links and fires alone; once a fight), 'phantom:N' (for the next N rounds
// you pick, as a free move ['p', x, y], the cell next to its aim where its aimed piece lands; once a fight), and Skitter's '@miss kill' on a boss (one firing, not the piece).
// Every fight is seeded and the board is laid out by hand. php tests/pf_stat_nimble.php
$GLOBALS['TEST_SETTINGS'] = [];
if (!function_exists('setting')) { function setting(string $k): string { return (string)($GLOBALS['TEST_SETTINGS'][$k] ?? ''); } }
require __DIR__ . '/../game/includes/pfdeck.php';
$bad = 0; $n = 0;
function chk(string $name, bool $ok, $got = ''): void { global $bad, $n; $n++; if (!$ok) { $bad++; echo 'FAIL ' . $name . ' (got ' . (is_string($got) ? $got : json_encode($got)) . ")\n"; } }

const WILD = ['L' => ['wild', null], 'R' => ['wild', null], 'T' => ['wild', null], 'B' => ['wild', null]];
const KNOB = ['L' => ['knob', 'body'], 'R' => ['knob', 'body'], 'T' => ['knob', 'body'], 'B' => ['knob', 'body']];
/** A Nimble stat piece tile as a packed deck gives it (fx S:KEY when live), wild edges. */
function nimTile(string $key, int $a = 3, int $b = 2): array
{
    $p = pfd_stat_pieces()[$key];
    $t = pf_make_tile($key, ['level' => 10], 0, ['n' => $p['n'], 't' => $p['t'], 'v' => $p['v'], 'r' => $p['r'], 'tag' => $p['tag'], 'src' => 'stat', 'st' => 'nimble']) + ['fxa' => $a, 'fxb' => $b, 'ed' => WILD];
    if ($p['live'] && $p['fx'] !== '') $t['fx'] = 'S:' . $key;
    return $t;
}
function plain(string $k, int $v = 5): array { $t = pf_make_tile($k, ['level' => 10]); $t['v'] = $v; $t['ed'] = WILD; $t['src'] = 'basic'; return $t; }
function foeT(string $k, string $t, int $v, array $ed = WILD): array { return ['k' => $k, 'n' => ucfirst(substr($k, 2)), 't' => $t, 'v' => $v, 'r' => 'body', 'tag' => '', 'ed' => $ed]; }
/** A v1 fight (4x4 medium board, 5x5 boss), the board emptied, no use-up of 3-chains, the creature's hand set; $extra = Nimble pieces in your deck (so the fight carries the effect state). */
function nimFight(int $seed, array $extra, string $size = 'medium', ?array $hand = null): array
{
    $deck = []; foreach (range(1, 10) as $i) $deck[] = plain(['swing', 'dodge', 'rest', 'charm'][$i % 4], 4 + $i % 3);
    foreach ($extra as $k) $deck[] = nimTile($k);
    $foe = ['slug' => 'tst', 'name' => 'Test', 'size' => $size, 'level' => 10, 'dmg_die' => 6, 'dmg_bonus' => 1];
    $s = pfb_new(['hp' => 60, 'max_hp' => 60, 'deck' => $deck, 'luck' => 2, 'lpts' => 10], $foe, $seed, ['v1' => true]);
    $s['pcs'] = []; $s['cell'] = []; $s['ter'] = []; $s['envs'] = []; $s['foe']['slow'] = 0; $s['v1']['limit'] = 0;   // no use-up: the laid-out boards stay as they are
    $s['foe']['hand'] = $hand ?? [foeT('f:bite', 'hurt', 5)];
    return $s;
}
function put(array &$s, string $who, array $tile, int $x, int $y): int
{
    $id = ++$s['pid']; $s['seq']++;
    $s['pcs'][$id] = ['id' => $id, 'by' => $who, 'tile' => $tile, 'x' => $x, 'y' => $y, 'born' => $s['round'], 'seq' => $s['seq']];
    $s['cell']["$x,$y"] = $id;
    return $id;
}
/** The creature's committed aim: its hand piece $hi on (x, y), as pfb_aim shows it. */
function aimAt(array &$s, int $x, int $y, int $hi = 0): void { $h = $s['foe']['hand'][$hi]; $s['foe']['plan'] = ['k' => $h['k'], 'n' => $h['n'], 't' => $h['t'], 'v' => $h['v'], 'tag' => $h['tag'], 'x' => $x, 'y' => $y]; }
function playAt(array &$s, array $tile, int $x, int $y): ?array { array_unshift($s['me']['hand'], $tile); return pfb_place($s, 'me', 0, $x, $y); }
function foeAt(array $s, int $x, int $y): bool { $id = $s['cell']["$x,$y"] ?? null; return $id !== null && $s['pcs'][$id]['by'] === 'foe'; }
function foeCells(array $s): array { $o = []; foreach ($s['pcs'] as $p) if ($p['by'] === 'foe') $o[] = [$p['x'], $p['y']]; return $o; }
function touches(array $c, int $x, int $y): bool { return abs($c[0] - $x) + abs($c[1] - $y) === 1; }

// ---------------------------------------------------------------- data: the six Nimble pieces are live
$S = pfd_stat_pieces();
foreach (['stat-sidestep', 'stat-skitter', 'stat-wrong-turn', 'stat-pinning-stance', 'stat-shadow-step', 'stat-phantom-footing'] as $k)
    chk("data_{$k}_is_live_with_clauses", $S[$k]['live'] && pfb_wx_clauses('S:' . $k) !== [], [$S[$k]['live'], $S[$k]['fx']]);
chk('data_nimble_tile_from_a_packed_deck_carries_fx', (pfd_stat_entry($S['stat-wrong-turn'], 20)['fx'] ?? '') === 'S:stat-wrong-turn');

// ---------------------------------------------------------------- Sidestep: next to its aim = Evade, on its aim = it skips its turn, elsewhere = nothing
$s = nimFight(1, ['stat-sidestep']); put($s, 'me', plain('rest', 3), 1, 1); put($s, 'me', plain('rest', 3), 1, 2); aimAt($s, 2, 1);
$w = $s; playAt($w, nimTile('stat-sidestep'), 2, 2);
chk('sidestep_next_to_aim_gives_evade_not_skip', (int)$w['me']['evade'] === 1 && (int)$w['foe']['slow'] === 0, [$w['me']['evade'], $w['foe']['slow']]);
$w = $s; playAt($w, nimTile('stat-sidestep'), 2, 1);
chk('sidestep_on_aim_makes_it_skip', (int)$w['foe']['slow'] === 1);
$fe = pfb_foe_turn($w, 0);
chk('sidestep_on_aim_creature_places_nothing', foeCells($w) === [] && count($w['foe']['hand']) === 1);
$w = $s; playAt($w, nimTile('stat-sidestep'), 0, 1);
chk('sidestep_elsewhere_does_nothing', (int)$w['me']['evade'] === 0 && (int)$w['foe']['slow'] === 0);
$w = $s; playAt($w, nimTile('stat-sidestep'), 2, 2); $fe = pfb_foe_turn($w, 0);
$hit = array_values(array_filter($fe, fn($e) => ($e['by'] ?? '') === 'foe' && ($e['t'] ?? '') === 'hurt' && isset($e['barnow'])));
chk('sidestep_evade_makes_its_next_hurt_miss', $hit && isset($hit[0]['evaded']) && (int)$w['me']['hp'] === 60, [$hit[0]['evaded'] ?? null, $w['me']['hp']]);

// ---------------------------------------------------------------- Skitter: Evade, and the creature Hurt that missed tumbles off the board
$s = nimFight(2, ['stat-skitter']); put($s, 'me', plain('rest', 3), 1, 1);
playAt($s, nimTile('stat-skitter'), 1, 2);
chk('skitter_gives_evade_and_registers_miss_effect', (int)$s['me']['evade'] === 1 && count($s['me']['wmiss'] ?? []) === 1);
$d0 = count($s['foe']['discard']); $ev = pfb_place($s, 'foe', 0, 2, 1); $fid = $s['pid'];
chk('skitter_missed_hurt_knocked_off_board', !isset($s['pcs'][$fid]) && count($s['foe']['discard']) === $d0 + 1 && (int)$s['me']['hp'] === 60, [isset($s['pcs'][$fid]), $s['me']['hp']]);
// the control: without Skitter the same Hurt stays on the board
$s = nimFight(2, ['stat-sidestep']); put($s, 'me', plain('rest', 3), 1, 1); put($s, 'me', plain('dodge', 3), 1, 2);
pfb_place($s, 'foe', 0, 2, 1); $fid = $s['pid'];
chk('skitter_control_without_it_the_hurt_stays', isset($s['pcs'][$fid]));
// a boss: its piece loses one firing instead of falling
$s = nimFight(3, ['stat-skitter'], 'boss'); put($s, 'me', plain('rest', 3), 1, 1);
playAt($s, nimTile('stat-skitter'), 1, 2); pfb_place($s, 'foe', 0, 2, 1); $fid = $s['pid'];
chk('skitter_boss_piece_stays_but_loses_a_firing', isset($s['pcs'][$fid]) && (int)$s['pcs'][$fid]['f'] === 2, [isset($s['pcs'][$fid]), $s['pcs'][$fid]['f'] ?? null]);

// ---------------------------------------------------------------- Wrong Turn: the aim moves one cell, to the free neighbour farthest from its pieces
$s = nimFight(4, ['stat-wrong-turn'], 'medium', [foeT('f:bite', 'hurt', 5), foeT('f:nip', 'hurt', 3)]);
put($s, 'foe', foeT('f:old', 'guard', 2), 0, 0); put($s, 'me', plain('rest', 3), 3, 2); aimAt($s, 1, 1);
$w = $s; $ev = playAt($w, nimTile('stat-wrong-turn'), 3, 3);
$pl = $w['foe']['plan'];
chk('wrong_turn_moves_aim_farthest_from_its_pieces (1,1 -> 2,1)', [$pl['x'], $pl['y']] === [2, 1] && ($pl['from'] ?? null) === [1, 1], [$pl['x'], $pl['y'], $pl['from'] ?? null]);
chk('wrong_turn_aim_chip_recomputed_for_new_cell', isset($pl['tot']) && $pl['tot'] === pfb_aim_total($w), $pl['tot'] ?? null);
$w2 = $w; $ev2 = playAt($w2, nimTile('stat-wrong-turn'), 2, 3);
chk('wrong_turn_once_a_round (a second one does not move it again)', $ev2 !== null && [$w2['foe']['plan']['x'], $w2['foe']['plan']['y']] === [2, 1]);
$w3 = $w; pfb_foe_turn($w3, 0);
chk('wrong_turn_creature_plays_on_moved_cell_when_it_fits', foeAt($w3, 2, 1) && !foeAt($w3, 1, 1));
// its piece does not fit on the new cell: it picks again, never its old cell
$s = nimFight(5, ['stat-wrong-turn'], 'medium', [foeT('f:bite', 'hurt', 5, KNOB)]);
put($s, 'foe', foeT('f:old', 'guard', 2), 0, 0); put($s, 'me', ['ed' => KNOB] + plain('rest', 3), 3, 1); put($s, 'me', plain('rest', 3), 3, 2); put($s, 'me', plain('rest', 3), 1, 2); aimAt($s, 1, 1);
playAt($s, nimTile('stat-wrong-turn'), 3, 3); $pl = $s['foe']['plan'];
pfb_foe_turn($s, 0); $fc = foeCells($s);
chk('wrong_turn_no_fit_picks_again_not_old_cell', [$pl['x'], $pl['y']] === [2, 1] && count($fc) === 2 && !foeAt($s, 2, 1) && !foeAt($s, 1, 1) && (int)$s['reaim'] === 1, [$fc, $s['reaim']]);

// ---------------------------------------------------------------- Pinning Stance: a re-pick may only use a cell touching it; none = it loses that move
$s = nimFight(6, ['stat-pinning-stance']); put($s, 'me', plain('rest', 3), 1, 1); put($s, 'me', plain('dodge', 3), 0, 0);
aimAt($s, 2, 1); put($s, 'me', plain('charm', 3), 2, 1);   // you took its aim cell
$w = $s; put($w, 'me', nimTile('stat-pinning-stance'), 3, 3); pfb_foe_turn($w, 0); $fc = foeCells($w);
chk('pinning_repick_lands_touching_the_stance', count($fc) === 1 && touches($fc[0], 3, 3), $fc);
$w = $s; pfb_foe_turn($w, 0); $fc = foeCells($w);
chk('pinning_control_without_stance_repick_goes_elsewhere', count($fc) === 1 && !touches($fc[0], 3, 3), $fc);
$w = $s; put($w, 'me', nimTile('stat-pinning-stance'), 0, 3); put($w, 'me', plain('rest', 3), 0, 2); put($w, 'me', plain('rest', 3), 1, 3); $h0 = count($w['foe']['hand']);
pfb_foe_turn($w, 0);
chk('pinning_no_cell_touching_it_loses_the_move (piece stays in its hand)', foeCells($w) === [] && count($w['foe']['hand']) === $h0, [foeCells($w), count($w['foe']['hand'])]);
$w = $s; put($w, 'me', nimTile('stat-pinning-stance'), 3, 3); aimAt($w, 2, 2); pfb_foe_turn($w, 0);
chk('pinning_does_not_move_an_aim_that_plays', foeAt($w, 2, 2));

// ---------------------------------------------------------------- Shadow Step: Keeper; when the creature places its aimed piece, it jumps beside it (most of your links) and fires alone
$s = nimFight(7, ['stat-shadow-step']); put($s, 'me', plain('rest', 3), 0, 1); put($s, 'me', plain('rest', 3), 1, 0); put($s, 'me', plain('charm', 3), 3, 1);
aimAt($s, 1, 1); $sh = nimTile('stat-shadow-step'); $s['me']['hand'][] = $sh; $nh = count($s['me']['hand']);
chk('shadow_step_is_a_keeper', pfb_wx_keep($s, $sh));
$w = $s; $fe = pfb_foe_turn($w, 0);
$sid = null; foreach ($w['pcs'] as $p) if ($p['by'] === 'me' && $p['tile']['k'] === 'stat-shadow-step') $sid = $p['id'];
chk('shadow_step_jumps_from_hand_beside_the_aimed_piece', $sid !== null && foeAt($w, 1, 1) && touches([$w['pcs'][$sid]['x'], $w['pcs'][$sid]['y']], 1, 1) && count($w['me']['hand']) === $nh - 1);
chk('shadow_step_picks_cell_with_most_of_your_links (2,1 touches your Charm, 1,2 none)', $sid !== null && [$w['pcs'][$sid]['x'], $w['pcs'][$sid]['y']] === [2, 1], $sid ? [$w['pcs'][$sid]['x'], $w['pcs'][$sid]['y']] : null);
$sf = array_values(array_filter($fe, fn($e) => ($e['id'] ?? null) === $sid && isset($e['barnow'])));
chk('shadow_step_fires_alone_once (not again in the creature chain)', count($sf) === 1 && !empty($sf[0]['shadow']), count($sf));
$hurt = array_values(array_filter($fe, fn($e) => ($e['by'] ?? '') === 'foe' && ($e['t'] ?? '') === 'hurt' && isset($e['barnow'])));
chk('shadow_step_guard_is_up_before_its_hurt', $hurt && (int)($hurt[0]['blocked'] ?? 0) > 0 && array_search($sf[0] ?? null, $fe, true) < array_search($hurt[0], $fe, true), $hurt[0]['blocked'] ?? null);
chk('shadow_step_once_a_fight_flag', !empty($w['me']['wshd']));
$w['me']['hand'][] = nimTile('stat-shadow-step'); $w['foe']['hand'] = [foeT('f:bite', 'hurt', 5)]; $w['foe']['slow'] = 0; aimAt($w, 2, 2); $n0 = count($w['me']['hand']);
pfb_foe_turn($w, 0);
chk('shadow_step_second_time_in_a_fight_does_not_jump', count($w['me']['hand']) === $n0);
$w = $s; $w['me']['hand'] = array_values(array_filter($w['me']['hand'], fn($t) => $t['k'] !== 'stat-shadow-step')); $fe2 = pfb_foe_turn($w, 0);
chk('shadow_step_control_not_in_hand_nothing_jumps', !array_filter($fe2, fn($e) => !empty($e['shadow'])));

// ---------------------------------------------------------------- Phantom Footing: Evade; for the next two rounds you pick where its aimed piece lands (a cell next to its aim where it fits); once a fight
$s = nimFight(8, ['stat-phantom-footing']); put($s, 'me', plain('rest', 3), 1, 1); aimAt($s, 2, 1);
$r0 = (int)$s['round']; playAt($s, nimTile('stat-phantom-footing'), 1, 2);
chk('phantom_gives_evade_and_two_rounds', (int)$s['me']['evade'] === 1 && ($s['me']['wph'] ?? null) === [$r0, 2], $s['me']['wph'] ?? null);
$tn = $s['turn'];
$r = pfb_play($s, [['p', 3, 1]], $tn);
chk('phantom_no_pick_in_the_round_it_fired', $r['err'] !== null);
$w = $s; $w['round']++; aimAt($w, 2, 1); $tn = $w['turn'];
$r = pfb_play($w, [['p', 2, 3]], $tn);
chk('phantom_pick_must_be_next_to_its_aim', $r['err'] !== null && $w['foe']['plan']['x'] === 2 && $w['foe']['plan']['y'] === 1);
$r = pfb_play($w, [['p', 3, 1]], $tn, null, true);
chk('phantom_dry_pick_changes_nothing', $r['err'] === null && [$w['foe']['plan']['x'], $w['foe']['plan']['y']] === [2, 1]);
$r = pfb_play($w, [['p', 3, 1]], $tn);
chk('phantom_pick_moves_aim_free_move', $r['err'] === null && !empty($r['free']) && [$w['foe']['plan']['x'], $w['foe']['plan']['y']] === [3, 1] && $w['turn'] === $tn && isset($w['foe']['plan']['tot']), $r);
$r = pfb_play($w, [['p', 2, 0]], $tn);
chk('phantom_pick_can_change_relative_to_its_first_aim', $r['err'] === null && [$w['foe']['plan']['x'], $w['foe']['plan']['y']] === [2, 0]);
$w2 = $w; pfb_foe_turn($w2, 0);
chk('phantom_creature_places_on_picked_cell', foeAt($w2, 2, 0) && !foeAt($w2, 2, 1));
$w2 = $w; put($w2, 'me', plain('dodge', 3), 2, 0); pfb_foe_turn($w2, 0);
chk('phantom_picked_cell_taken_it_plays_its_aim', foeAt($w2, 2, 1));
$w2 = $w; $w2['round'] = $r0 + 3; aimAt($w2, 2, 1); $r = pfb_play($w2, [['p', 3, 1]], $tn);
chk('phantom_no_pick_after_two_rounds', $r['err'] !== null);
$w2 = $w; $w2['round'] = $r0 + 2; aimAt($w2, 2, 1); $r = pfb_play($w2, [['p', 3, 1]], $tn);
chk('phantom_pick_on_second_round', $r['err'] === null);
$w2 = $s; $w2['round']++; playAt($w2, nimTile('stat-phantom-footing'), 0, 1);
chk('phantom_once_a_fight (a second one does not restart it)', ($w2['me']['wph'] ?? null) === [$r0, 2]);
$w2 = $w; $w2['foe']['hand'] = [foeT('f:bite', 'hurt', 5, KNOB)]; aimAt($w2, 2, 1); put($w2, 'me', ['ed' => KNOB] + plain('rest', 3), 3, 0);
$r = pfb_play($w2, [['p', 3, 1]], $tn);
chk('phantom_pick_only_where_its_piece_fits', $r['err'] !== null);
$q = nimFight(9, ['stat-sidestep']); aimAt($q, 1, 1); put($q, 'me', plain('rest', 3), 0, 1);
$r = pfb_play($q, [['p', 2, 1]], $q['turn']);
chk('phantom_no_pick_without_it', $r['err'] !== null);

echo $bad ? "$bad FAILED of $n\n" : "ok: $n Nimble stat piece checks\n";
exit($bad ? 1 : 0);
