<?php
// Stat pieces, SENSE slice: Sharp Eye (tier 0), Soft Spot (10), Not Fooled (15), Saw It Coming (20), Snare Field (25), Eyes of the Wood (30).
// Engine parts: pfb_view shows the piece the creature plays after its aim while Sharp Eye is held ('sight') and its whole hand and draw top while Eyes of the Wood is held ('eyes');
// Eyes of the Wood also makes every piece it places lose {a}; 'nocombo' (Not Fooled) = the creature's next turn gets no combos (the flag ends with that turn); 'snare' (Snare Field) = marks
// up to {b} free cells next to it ('snr', 2 rounds, nearest its aim first), a creature piece placed on one plays at half value (the mark is used up), the creature's search does not see them.
// Soft Spot and Saw It Coming use clauses that already exist. Every fight is seeded and the board is laid out by hand. php tests/pf_stat_sense.php
$GLOBALS['TEST_SETTINGS'] = [];
if (!function_exists('setting')) { function setting(string $k): string { return (string)($GLOBALS['TEST_SETTINGS'][$k] ?? ''); } }
require __DIR__ . '/../game/includes/pfdeck.php';
$bad = 0; $n = 0;
function chk(string $name, bool $ok, $got = ''): void { global $bad, $n; $n++; if (!$ok) { $bad++; echo 'FAIL ' . $name . ' (got ' . (is_string($got) ? $got : json_encode($got)) . ")\n"; } }

const WILD = ['L' => ['wild', null], 'R' => ['wild', null], 'T' => ['wild', null], 'B' => ['wild', null]];
/** A Sense stat piece tile as a packed deck gives it (fx S:KEY when live), wild edges. */
function senTile(string $key, int $a = 3, int $b = 2): array
{
    $p = pfd_stat_pieces()[$key];
    $t = pf_make_tile($key, ['level' => 10], 0, ['n' => $p['n'], 't' => $p['t'], 'v' => $p['v'], 'r' => $p['r'], 'tag' => $p['tag'], 'src' => 'stat', 'st' => 'sense']) + ['fxa' => $a, 'fxb' => $b, 'ed' => WILD];
    if ($p['live'] && $p['fx'] !== '') $t['fx'] = 'S:' . $key;
    return $t;
}
function plain(string $k, int $v = 5): array { $t = pf_make_tile($k, ['level' => 10]); $t['v'] = $v; $t['ed'] = WILD; $t['src'] = 'basic'; return $t; }
function foeT(string $k, string $t, int $v, array $ed = WILD): array { return ['k' => $k, 'n' => ucfirst(substr($k, 2)), 't' => $t, 'v' => $v, 'r' => 'body', 'tag' => '', 'ed' => $ed]; }
/** A v1 fight (4x4 medium board, 5x5 boss), the board emptied, no use-up, the creature's hand set; $extra = Sense pieces in your deck (so the fight carries the effect state). */
function senFight(int $seed, array $extra, string $size = 'medium', ?array $hand = null): array
{
    $deck = []; foreach (range(1, 10) as $i) $deck[] = plain(['swing', 'dodge', 'rest', 'charm'][$i % 4], 4 + $i % 3);
    foreach ($extra as $k) $deck[] = senTile($k);
    $foe = ['slug' => 'tst', 'name' => 'Test', 'size' => $size, 'level' => 10, 'dmg_die' => 6, 'dmg_bonus' => 1];
    $s = pfb_new(['hp' => 60, 'max_hp' => 60, 'deck' => $deck, 'luck' => 2, 'lpts' => 10], $foe, $seed, ['v1' => true]);
    $s['pcs'] = []; $s['cell'] = []; $s['ter'] = []; $s['envs'] = []; $s['foe']['slow'] = 0; $s['v1']['limit'] = 0;
    $s['foe']['hand'] = $hand ?? [foeT('f:bite', 'hurt', 5)]; $s['foe']['plan'] = null; $s['me']['hand'] = [];
    return $s;
}
function put(array &$s, string $who, array $tile, int $x, int $y): int
{
    $id = ++$s['pid']; $s['seq']++;
    $s['pcs'][$id] = ['id' => $id, 'by' => $who, 'tile' => $tile, 'x' => $x, 'y' => $y, 'born' => $s['round'], 'seq' => $s['seq']];
    $s['cell']["$x,$y"] = $id;
    return $id;
}
function aimAt(array &$s, int $x, int $y, int $hi = 0): void { $h = $s['foe']['hand'][$hi]; $s['foe']['plan'] = ['k' => $h['k'], 'n' => $h['n'], 't' => $h['t'], 'v' => $h['v'], 'tag' => $h['tag'], 'x' => $x, 'y' => $y]; }
function playAt(array &$s, array $tile, int $x, int $y): ?array { array_unshift($s['me']['hand'], $tile); return pfb_place($s, 'me', 0, $x, $y); }
function firstFoe(?array $ev): ?array { foreach ($ev ?? [] as $e) if (($e['by'] ?? '') === 'foe' && ($e['t'] ?? '') === 'hurt' && isset($e['barnow'])) return $e; return null; }   // the creature Hurt's firing

// ---------------------------------------------------------------- data: the six Sense pieces are live
$S = pfd_stat_pieces();
foreach (['stat-sharp-eye', 'stat-soft-spot', 'stat-not-fooled', 'stat-saw-it-coming', 'stat-snare-field', 'stat-eyes-of-the-wood'] as $k)
    chk("data_{$k}_is_live_with_clauses", $S[$k]['live'] && pfb_wx_clauses('S:' . $k) !== [], [$S[$k]['live'], $S[$k]['fx']]);
chk('data_sense_tile_from_a_packed_deck_carries_fx', (pfd_stat_entry($S['stat-snare-field'], 25)['fx'] ?? '') === 'S:stat-snare-field');

// ---------------------------------------------------------------- Sharp Eye: held, the view names the piece the creature plays after its aim; played: its next piece loses a
$foeH = [foeT('f:bite', 'hurt', 5), foeT('f:nip', 'hurt', 3), foeT('f:wall', 'guard', 4)];
$s = senFight(1, ['stat-sharp-eye'], 'medium', $foeH); put($s, 'me', plain('rest', 3), 1, 1); $s['me']['hand'] = [senTile('stat-sharp-eye')];
pfb_aim($s);
$v = pfb_view($s); $pl = $s['foe']['plan'];
chk('sharp_eye_held_view_has_sight_naming_the_next_piece', isset($v['sight']) && $pl && $v['sight']['k'] !== $pl['k'] && in_array($v['sight']['k'], ['f:nip', 'f:wall'], true), [$v['sight'] ?? null, $pl['k'] ?? null]);
chk('sharp_eye_sight_carries_its_numbers', isset($v['sight']) && $v['sight']['n'] === ucfirst(substr($v['sight']['k'], 2)) && isset($v['sight']['t'], $v['sight']['v'], $v['sight']['tag']), $v['sight'] ?? null);
$s0 = json_encode($s); pfb_view($s);
chk('sharp_eye_view_changes_nothing', json_encode($s) === $s0);
$w = $s; $w['me']['hand'] = []; $v2 = pfb_view($w);
chk('sharp_eye_not_held_no_sight', !array_key_exists('sight', $v2));
$w = $s; $w['foe']['hand'] = [foeT('f:bite', 'hurt', 5)]; pfb_aim($w); $v3 = pfb_view($w);
chk('sharp_eye_held_with_one_foe_piece_left_sight_is_null', array_key_exists('sight', $v3) && $v3['sight'] === null, $v3['sight'] ?? 'absent');
$w = $s; $w['foe']['hand'] = [foeT('f:bite', 'hurt', 5), foeT('f:nip', 'hurt', 3)]; pfb_aim($w); $v4 = pfb_view($w);
chk('sharp_eye_sight_is_the_only_other_piece', ($v4['sight']['k'] ?? '') === 'f:nip' || ($w['foe']['plan']['k'] ?? '') === 'f:nip', [$v4['sight'] ?? null, $w['foe']['plan']['k'] ?? null]);
// boss: the aim's own 'next' and the sight agree
$sb = senFight(2, ['stat-sharp-eye'], 'boss', $foeH); put($sb, 'me', plain('rest', 3), 2, 2); $sb['me']['hand'] = [senTile('stat-sharp-eye')]; $sb['foe']['plan'] = null; pfb_aim($sb); $vb = pfb_view($sb);
chk('sharp_eye_boss_sight_matches_its_two_turns_next', !empty($sb['foe']['plan']['next']) ? (($vb['sight']['k'] ?? '') === $sb['foe']['plan']['next']['k']) : true, [$vb['sight'] ?? null, $sb['foe']['plan']['next'] ?? null]);
// played: its next piece loses a
$s = senFight(3, ['stat-sharp-eye']); put($s, 'me', plain('rest', 3), 1, 1);
playAt($s, senTile('stat-sharp-eye', 3), 1, 2);
chk('sharp_eye_played_sets_its_next_piece_loss', (int)$s['foe']['wnx'] === 3, $s['foe']['wnx'] ?? null);
pfb_place($s, 'foe', 0, 2, 2); $fid = $s['pid'];
chk('sharp_eye_played_its_next_piece_loses_a (wv -3; its chain runs through Sharp Eye, which is why wnx is set again)', (int)($s['pcs'][$fid]['wv'] ?? 0) === -3, [$s['pcs'][$fid]['wv'] ?? null]);

// ---------------------------------------------------------------- Soft Spot: strips a creature guard (needs guard up), its next Hurt gets +b
$s = senFight(4, ['stat-soft-spot']); put($s, 'me', plain('rest', 3), 1, 1); $s['foe']['block'] = 5;
$ev = playAt($s, senTile('stat-soft-spot', 3, 2), 1, 2);
chk('soft_spot_with_guard_up_strips_a (5 -> 2)', (int)$s['foe']['block'] === 2, $s['foe']['block']);
$ev2 = playAt($s, plain('swing', 4), 2, 2); $hid = $s['pid'];
chk('soft_spot_next_hurt_gets_b', (int)($s['pcs'][$hid]['wv'] ?? 0) === 2, $s['pcs'][$hid]['wv'] ?? null);
$ev3 = playAt($s, plain('swing', 4), 2, 3); $h2 = $s['pid'];
chk('soft_spot_only_the_next_hurt', (int)($s['pcs'][$h2]['wv'] ?? 0) === 0, $s['pcs'][$h2]['wv'] ?? null);
$s = senFight(4, ['stat-soft-spot']); put($s, 'me', plain('rest', 3), 1, 1); $s['foe']['block'] = 0;
playAt($s, senTile('stat-soft-spot', 3, 2), 1, 2); $ev2 = playAt($s, plain('swing', 4), 2, 2); $hid = $s['pid'];
chk('soft_spot_without_guard_no_strip_but_the_next_hurt_bonus_still_comes', (int)$s['foe']['block'] === 0 && (int)($s['pcs'][$hid]['wv'] ?? 0) === 2, [$s['foe']['block'], $s['pcs'][$hid]['wv'] ?? null]);
$s = senFight(4, ['stat-soft-spot']); put($s, 'me', plain('rest', 3), 1, 1); $s['foe']['block'] = 2;
playAt($s, senTile('stat-soft-spot', 4, 2), 1, 2);
chk('soft_spot_strip_never_below_zero', (int)$s['foe']['block'] === 0, $s['foe']['block']);

// ---------------------------------------------------------------- Not Fooled: the creature's next turn gets no combos (Ambush / Bait / Riposte), then it is over
function comboFight(int $seed, bool $notFooled): array
{
    $s = senFight($seed, ['stat-not-fooled'], 'medium', [foeT('f:bite', 'hurt', 4)]);
    put($s, 'foe', foeT('f:trap', 'trick', 2), 2, 1);   // its trick on the board: a Hurt linked to it is an Ambush (x1.5 + 2)
    put($s, 'me', plain('rest', 3), 0, 3);
    if ($notFooled) playAt($s, senTile('stat-not-fooled'), 0, 2);
    return $s;
}
$s = comboFight(5, false); aimAt($s, 3, 1); $fe = pfb_foe_turn($s, 0); $e = firstFoe($fe);
chk('not_fooled_control_without_it_its_hurt_is_an_ambush', $e && ($e['combo'] ?? null) === 'Ambush' && (int)$e['v'] === 8, [$e['combo'] ?? null, $e['v'] ?? null]);
$s = comboFight(5, true);
chk('not_fooled_played_sets_the_flag', !empty($s['foe']['nocombo']), $s['foe']['nocombo'] ?? null);
aimAt($s, 3, 1); $fe = pfb_foe_turn($s, 0); $e = firstFoe($fe);
chk('not_fooled_its_hurt_gets_no_combo_and_plays_at_face_value', $e && ($e['combo'] ?? null) === null && (int)$e['v'] === 4, [$e['combo'] ?? null, $e['v'] ?? null]);
chk('not_fooled_the_flag_ends_with_its_turn', empty($s['foe']['nocombo']), $s['foe']['nocombo'] ?? null);
$s['foe']['hand'] = [foeT('f:bite2', 'hurt', 4)]; put($s, 'foe', foeT('f:trap2', 'trick', 2), 3, 3); aimAt($s, 2, 3); $fe = pfb_foe_turn($s, 0); $e = firstFoe($fe);
chk('not_fooled_one_chain_only_the_next_turn_has_combos_again', $e && ($e['combo'] ?? null) === 'Ambush', [$e['combo'] ?? null]);
$s = comboFight(5, true); $s['me']['block'] = 0; aimAt($s, 3, 1); $tot = pfb_aim_total($s);
chk('not_fooled_the_aim_total_names_no_combo_and_counts_face_value', $tot && !array_filter($tot['why'] ?? [], fn($w) => str_starts_with($w, 'combo ')) && (int)$tot['hp'] === 4, $tot ?? null);

// ---------------------------------------------------------------- Saw It Coming: each creature Hurt the guard blocks is knocked off the board and its next piece loses a
function sawFight(int $seed, string $size = 'medium'): array
{
    $s = senFight($seed, ['stat-saw-it-coming'], $size, [foeT('f:bite', 'hurt', 3), foeT('f:nip', 'hurt', 2)]);
    put($s, 'me', plain('rest', 3), 1, 1);
    playAt($s, senTile('stat-saw-it-coming', 3, 2) + [], 1, 2);
    return $s;
}
$s = sawFight(6); $d0 = count($s['foe']['discard']);
$ev = pfb_place($s, 'foe', 0, 2, 2); $fid = $s['pid'];
chk('saw_it_coming_blocked_hurt_is_knocked_off', !isset($s['pcs'][$fid]) && count($s['foe']['discard']) === $d0 + 1, [isset($s['pcs'][$fid]), count($s['foe']['discard']) - $d0]);
chk('saw_it_coming_its_next_piece_loses_a', (int)$s['foe']['wnx'] === 3, $s['foe']['wnx']);
chk('saw_it_coming_the_hit_was_blocked_you_lose_no_health', (int)$s['me']['hp'] === 60, $s['me']['hp']);
$s = senFight(6, ['stat-saw-it-coming'], 'medium', [foeT('f:bite', 'hurt', 3)]); put($s, 'me', plain('rest', 3), 1, 1);   // control: no guard up
pfb_place($s, 'foe', 0, 2, 2); $fid = $s['pid'];
chk('saw_it_coming_control_without_a_guard_the_hurt_stays_and_no_loss', isset($s['pcs'][$fid]) && (int)$s['foe']['wnx'] === 0, [isset($s['pcs'][$fid]), $s['foe']['wnx']]);
$s = sawFight(6, 'boss'); $ev = pfb_place($s, 'foe', 0, 2, 2); $fid = $s['pid'];
chk('saw_it_coming_boss_piece_stays_but_loses_a_firing', isset($s['pcs'][$fid]) && (int)($s['pcs'][$fid]['f'] ?? 0) === 2 && (int)$s['foe']['wnx'] === 3, [$s['pcs'][$fid]['f'] ?? null, $s['foe']['wnx']]);

// ---------------------------------------------------------------- Snare Field: up to b free cells next to it, nearest its aim first, 2 rounds; halves a creature piece on one; the creature does not see them
function snareFight(int $seed, int $a = 3, int $b = 2, string $size = 'medium'): array
{
    $s = senFight($seed, ['stat-snare-field'], $size, [foeT('f:bite', 'hurt', 6)]);
    put($s, 'me', plain('swing', 3), 1, 0);   // (not a heal: its chain runs through your piece)
    aimAt($s, 2, 1);
    playAt($s, senTile('stat-snare-field', $a, $b), 1, 1);
    return $s;
}
$s = snareFight(7); $cells = array_keys($s['snr'] ?? []);
chk('snare_field_marks_b_cells_nearest_its_aim_first (aim 2,1: 2,1 then 0,1)', $cells === ['2,1', '0,1'], $cells);
chk('snare_field_marks_remember_the_round', array_values($s['snr'] ?? []) === [(int)$s['round'], (int)$s['round']], $s['snr'] ?? null);
$s = snareFight(7, 3, 1); chk('snare_field_b_1_marks_one_cell', array_keys($s['snr'] ?? []) === ['2,1'], array_keys($s['snr'] ?? []));
$s = senFight(7, ['stat-snare-field'], 'medium', [foeT('f:bite', 'hurt', 6)]); put($s, 'me', plain('rest', 3), 1, 0); put($s, 'foe', foeT('f:a', 'guard', 2), 0, 1); put($s, 'foe', foeT('f:b', 'guard', 2), 2, 1); put($s, 'foe', foeT('f:c', 'guard', 2), 1, 2);
playAt($s, senTile('stat-snare-field', 3, 2), 1, 1);
chk('snare_field_never_on_occupied_cells_no_free_neighbour_marks_nothing', empty($s['snr']), $s['snr'] ?? null);
$s = snareFight(7); $v = pfb_view($s);
chk('snare_field_view_lists_the_snares_with_rounds_left', isset($v['snares']) && count($v['snares']) === 2 && $v['snares'][0] === ['x' => 2, 'y' => 1, 'left' => 2], $v['snares'] ?? null);
$s = senFight(7, ['stat-snare-field']); chk('snare_field_no_snares_no_view_key', !array_key_exists('snares', pfb_view($s)));
// a creature piece placed on a snare plays at half value, the mark is used up; one off it plays at full value
$s = snareFight(7); $ev = pfb_place($s, 'foe', 0, 2, 1); $e = firstFoe($ev); $fid = $s['pid'];
chk('snare_field_creature_piece_on_a_snare_plays_at_half (6 -> 3)', $e && (int)$e['v'] === 3, $e['v'] ?? null);
chk('snare_field_the_mark_is_used_up', !isset($s['snr']['2,1']) && isset($s['snr']['0,1']), array_keys($s['snr'] ?? []));
$s = snareFight(7); $ev = pfb_place($s, 'foe', 0, 1, 2); $e = firstFoe($ev);
chk('snare_field_creature_piece_off_the_snares_plays_at_full', $e && (int)$e['v'] === 6, $e['v'] ?? null);
$s = snareFight(7); $s['foe']['hand'] = [foeT('f:bite', 'hurt', 1)]; $ev = pfb_place($s, 'foe', 0, 2, 1); $e = firstFoe($ev);
chk('snare_field_half_never_below_1', $e && (int)$e['v'] === 1, $e['v'] ?? null);
// aim still lands on a snared cell
$s = snareFight(7); $fe = pfb_foe_turn($s, 0); $e = firstFoe($fe);
chk('snare_field_its_committed_aim_still_lands_on_a_snared_cell (at half)', $e && (int)$e['v'] === 3 && isset($s['cell']['2,1']) && $s['pcs'][$s['cell']['2,1']]['by'] === 'foe', [$e['v'] ?? null]);
// hidden from its search: same pick with and without the marks
$same = true;
foreach ([8, 9, 10, 11] as $sd) {
    $s = snareFight($sd, 3, 3); $s['foe']['hand'] = [foeT('f:bite', 'hurt', 6), foeT('f:nip', 'hurt', 4)];
    $w = $s; unset($w['snr']);
    if (pfb_search($s, 'foe') !== pfb_search($w, 'foe')) $same = false;
}
chk('snare_field_the_creature_search_ignores_the_snares', $same);
// 2 rounds: still there after round r ends, gone after round r + 1 ends
$s = snareFight(7); $s['foe']['hand'] = [foeT('f:bite', 'hurt', 6)]; $r0 = (int)$s['round'];
pfb_end_round($s);
chk('snare_field_still_there_in_the_next_round', count($s['snr'] ?? []) === 2 && (int)$s['round'] === $r0 + 1, [array_keys($s['snr'] ?? []), $s['round']]);
$v = pfb_view($s); chk('snare_field_one_round_left_in_the_view', ($v['snares'][0]['left'] ?? 0) === 1, $v['snares'] ?? null);
pfb_end_round($s);
chk('snare_field_gone_after_two_rounds', empty($s['snr']), $s['snr'] ?? null);
// boss board: marks work on 5x5 too
$s = snareFight(12, 5, 3, 'boss'); chk('snare_field_boss_board_marks_b_cells', count($s['snr'] ?? []) === 3, array_keys($s['snr'] ?? []));
// a snared piece that a Turn of the Tale style steal makes yours is not halved: only by foe
$s = snareFight(7); pfb_place($s, 'foe', 0, 2, 1); $fid = $s['pid']; $s['pcs'][$fid]['by'] = 'me';
$ev = pfb_fire($s, $fid, true); $e = null; foreach ($ev as $q) if (($q['id'] ?? 0) === $fid) $e = $q;
chk('snare_field_the_halving_is_for_creature_pieces_only', $e && (int)$e['v'] === 6, $e['v'] ?? null);

// ---------------------------------------------------------------- Eyes of the Wood: held, the view gives its whole hand and the piece it draws next; every piece it places loses a
$foeH = [foeT('f:bite', 'hurt', 6), foeT('f:nip', 'hurt', 3)]; $drawT = foeT('f:next', 'guard', 7);
$s = senFight(13, ['stat-eyes-of-the-wood'], 'medium', $foeH); put($s, 'me', plain('rest', 3), 1, 1); $s['me']['hand'] = [senTile('stat-eyes-of-the-wood', 3, 2)]; $s['foe']['draw'] = [foeT('f:deep', 'hurt', 1), $drawT];
$v = pfb_view($s);
chk('eyes_held_view_shows_its_whole_hand', isset($v['eyes']) && array_map(fn($t) => $t['k'], $v['eyes']['hand']) === ['f:bite', 'f:nip'], $v['eyes'] ?? null);
chk('eyes_held_view_shows_the_piece_it_draws_next', ($v['eyes']['top']['k'] ?? '') === 'f:next' && (int)$v['eyes']['top']['v'] === 7, $v['eyes']['top'] ?? null);
chk('eyes_view_carries_the_loss', ($v['eyes']['a'] ?? 0) === 3, $v['eyes']['a'] ?? null);
chk('eyes_view_pieces_carry_numbers_and_edges', isset($v['eyes']['hand'][0]['n'], $v['eyes']['hand'][0]['t'], $v['eyes']['hand'][0]['v'], $v['eyes']['hand'][0]['e']['L']), $v['eyes']['hand'][0] ?? null);
$w = $s; $w['foe']['draw'] = []; $v2 = pfb_view($w);
chk('eyes_empty_draw_pile_top_is_null', array_key_exists('eyes', $v2) && $v2['eyes']['top'] === null, $v2['eyes'] ?? null);
$w = $s; $w['me']['hand'] = []; $v3 = pfb_view($w);
chk('eyes_not_held_shows_nothing', !array_key_exists('eyes', $v3));
$s0 = json_encode($s); pfb_view($s); chk('eyes_view_changes_nothing', json_encode($s) === $s0);
$ev = pfb_place($s, 'foe', 0, 2, 1); $e = firstFoe($ev); $fid = $s['pid'];
chk('eyes_held_a_piece_it_places_loses_a (6 -> 3)', $e && (int)$e['v'] === 3 && (int)($s['pcs'][$fid]['wv'] ?? 0) === -3, [$e['v'] ?? null, $s['pcs'][$fid]['wv'] ?? null]);
$ev = pfb_place($s, 'foe', 0, 3, 1); $e = firstFoe($ev);
chk('eyes_held_every_piece_not_just_the_first (3 -> 1: never below 1)', $e && (int)$e['v'] === 1, $e['v'] ?? null);
$s = senFight(13, ['stat-eyes-of-the-wood'], 'medium', $foeH); put($s, 'me', plain('rest', 3), 1, 1); $s['me']['hand'] = [];
$ev = pfb_place($s, 'foe', 0, 2, 1); $e = firstFoe($ev);
chk('eyes_not_held_no_loss', $e && (int)$e['v'] === 6, $e['v'] ?? null);
$s = senFight(13, ['stat-eyes-of-the-wood'], 'medium', $foeH); put($s, 'me', plain('rest', 3), 1, 1); $s['me']['hand'] = [senTile('stat-eyes-of-the-wood', 3, 2)]; $s['foe']['wnx'] = 2;
$ev = pfb_place($s, 'foe', 0, 2, 1); $e = firstFoe($ev);
chk('eyes_and_a_next_piece_loss_add_up (6 - 3 - 2)', $e && (int)$e['v'] === 1, $e['v'] ?? null);
$s = senFight(13, ['stat-eyes-of-the-wood'], 'medium', $foeH); put($s, 'me', plain('rest', 3), 1, 1); $s['me']['hand'] = [senTile('stat-eyes-of-the-wood', 3, 2)];
$s['pcs'][array_key_first($s['pcs'])]['tile'] = plain('swing', 3); $s['foe']['hand'] = [foeT('f:bite', 'hurt', 6)]; aimAt($s, 2, 1); $tot = pfb_aim_total($s);
chk('eyes_the_aim_total_counts_the_loss (Hurt 6 - 3 = 3 reaches you)', $tot && (int)$tot['hp'] === 3, $tot['hp'] ?? null);
$s = senFight(13, ['stat-eyes-of-the-wood'], 'medium', $foeH); put($s, 'me', plain('rest', 3), 1, 1);
playAt($s, senTile('stat-eyes-of-the-wood', 3, 2), 1, 2);
chk('eyes_played_does_nothing_it_is_a_value_0_item', empty($s['foe']['wnx']) && count($s['me']['hand']) === 0);

echo $bad ? "$bad FAILED of $n\n" : "ok: $n Sense stat piece checks\n";
exit($bad ? 1 : 0);
