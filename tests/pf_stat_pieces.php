<?php
// Stat pieces, PLUMBING (setting pfight_statpieces, data/pf_stat_pieces.txt): the data, ownership by tier, packing, the numbers (value, a, b),
// the shared Luck roll (roll / !roll, once a firing, on the fight's rng) and "setting Off = nothing changes". No piece effect is tested here (each has its own slice).
// php tests/pf_stat_pieces.php
$GLOBALS['TEST_SETTINGS'] = [];
if (!function_exists('setting')) { function setting(string $k): string { return (string)($GLOBALS['TEST_SETTINGS'][$k] ?? ''); } }   // pure: no DB, the setting comes from the test
require __DIR__ . '/../game/includes/pfdeck.php';
$bad = 0; $n = 0;
function chk(string $name, bool $ok, $got = ''): void { global $bad, $n; $n++; if (!$ok) { $bad++; echo 'FAIL ' . $name . ' (got ' . (is_string($got) ? $got : json_encode($got)) . ")\n"; } }
/** The stat piece keys a build lists, in order. */
function statKeys(array $b): array { return array_values(array_map(fn($p) => $p['key'], array_filter($b['pieces'], fn($p) => $p['src'] === 'stat'))); }
/** Sources of a level-10 gnome with the starter box packed, stat pieces on or off, own points per stat. */
function src(bool $on, array $base = [], array $now = [], array $state = []): array
{
    return ['level' => 10, 'starter' => array_merge(PFD_CORE, PFD_STARTER_FIXED), 'statp' => $on, 'sbase' => $base, 'spts' => $now, 'state' => $state] + pfd_sources_blank(10);
}

// ---------------------------------------------------------------- data
$S = pfd_stat_pieces();
chk('data_loads_all_24_pieces', count($S) === 24, count($S));
$per = []; foreach ($S as $p) $per[$p['stat']][] = $p['tier'];
chk('data_each_stat_has_one_piece_per_tier_0_to_30', count($per) === 4 && !array_filter($per, fn($t) => $t !== PFD_STAT_TIERS), $per);
chk('data_only_built_slices_live (Luck; the others come in their own slices)', !array_filter($S, fn($p) => $p['live'] && $p['stat'] !== 'luck'), array_keys(array_filter($S, fn($p) => $p['live'])));
chk('data_engine_side_reads_same_rows', array_keys(pfb_stat_data()) === array_keys($S) && pfb_stat_data()['stat-long-shot'][0] === 'roll again ; !roll next:hurt:1:a');
chk('data_tags_are_engine_tags_or_none', !array_filter($S, fn($p) => $p['tag'] !== '' && !isset(PF_TAGS[$p['tag']]) && !isset(PF_TAGS_V1[$p['tag']])));
chk('clauses_unknown_actions_load_harmlessly (Wrong Turn: no clauses yet)', pfb_wx_clauses('S:stat-wrong-turn') === [] && pfb_wx_clauses('S:nonesuch') === []);
chk('clauses_known_actions_parse (Long Shot: roll again, !roll next)', count(pfb_wx_clauses('S:stat-long-shot')) === 2 && pfb_wx_clauses('S:stat-long-shot')[0]['a'] === 'again' && pfb_wx_clauses('S:stat-long-shot')[1]['c0'] === ['!roll']);
chk('text_fills_numbers', pfb_wx_text('S:stat-soft-spot', 4, 2) === 'Pierce. If the creature has guard up, it loses 4 guard. Your next Hurt this fight gets +2.', pfb_wx_text('S:stat-soft-spot', 4, 2));

// ---------------------------------------------------------------- the setting
$GLOBALS['TEST_SETTINGS']['pfight_statpieces'] = '0';
chk('setting_off_closed_for_admin', !pfd_statpieces_open(['role' => 'admin']));
$GLOBALS['TEST_SETTINGS']['pfight_statpieces'] = 'admin';
chk('setting_admins_only_open_for_admin_only', pfd_statpieces_open(['role' => 'admin']) && !pfd_statpieces_open(['role' => 'player']) && !pfd_statpieces_open(null));
$GLOBALS['TEST_SETTINGS']['pfight_statpieces'] = '1';
chk('setting_everyone_open_for_player', pfd_statpieces_open(['role' => 'player']));

// ---------------------------------------------------------------- ownership by tier
// arrange: Nimble 15, Lore 9, Luck 30, Sense 10 (missing = 10)
$b = pfd_build(src(true, ['nimble' => 15, 'lore' => 9, 'luck' => 30]));
$k = statKeys($b);
chk('owns_tier0_of_every_stat', !array_diff(['stat-sidestep', 'stat-old-saying', 'stat-loaded-die', 'stat-sharp-eye'], $k), $k);
chk('owns_tiers_up_to_points (Nimble 15: 10 and 15, not 20)', in_array('stat-skitter', $k, true) && in_array('stat-wrong-turn', $k, true) && !in_array('stat-pinning-stance', $k, true), $k);
chk('lore_9_owns_only_tier0', !in_array('stat-knot-of-twine', $k, true), $k);
chk('luck_30_owns_all_six', count(array_filter($k, fn($x) => ($S[$x]['stat'] ?? '') === 'luck')) === 6, $k);
chk('missing_points_count_as_10 (Sense: tier 10 yes, 15 no)', in_array('stat-soft-spot', $k, true) && !in_array('stat-not-fooled', $k, true), $k);
chk('owned_pieces_arrive_off_and_new', !array_filter($b['pieces'], fn($p) => $p['src'] === 'stat' && ($p['on'] || empty($p['new']))));
chk('ownership_uses_own_points_not_boosts (Nimble 10, boosted to 30: no tier 15)', !in_array('stat-wrong-turn', statKeys(pfd_build(src(true, ['nimble' => 10], ['nimble' => 30]))), true));

// ---------------------------------------------------------------- packing (by choice, like the knacks)
$b2 = pfd_build(src(true, ['sense' => 20], [], ['stat-saw-it-coming' => true, 'stat-sidestep' => true]));
$dk = array_map(fn($e) => $e['key'], array_filter($b2['deck'], fn($e) => $e['src'] === 'stat'));
chk('packed_pieces_go_in_deck_unpacked_stay_out', array_values($dk) === ['stat-sidestep', 'stat-saw-it-coming'], $dk);
chk('packed_deck_still_legal', $b2['err'] === null, $b2['err']);
$ent = array_values(array_filter(pfd_fight_entries(src(true, ['sense' => 20], [], ['stat-saw-it-coming' => true])), fn($e) => $e['src'] === 'stat'));
chk('fight_entries_carry_packed_stat_piece', count($ent) === 1 && $ent[0]['key'] === 'stat-saw-it-coming');

// ---------------------------------------------------------------- numbers: value = v + points / vd, + own stat modifier + level / 3; a = 1 + points / 5, b = ceil(a / 2)
chk('ab_from_points', pfd_stat_ab(0) === [1, 1] && pfd_stat_ab(10) === [3, 2] && pfd_stat_ab(17) === [4, 2] && pfd_stat_ab(30) === [7, 4], [pfd_stat_ab(10), pfd_stat_ab(17), pfd_stat_ab(30)]);
// arrange: Sense 17 now (own 20): Saw It Coming v 3 + 17/10 = 4, a 4, b 2; Nimble 12: Skitter v 2 + 12/5 = 4
$b3 = pfd_build(src(true, ['sense' => 20, 'nimble' => 12], ['sense' => 17], ['stat-saw-it-coming' => true, 'stat-skitter' => true]));
$E = []; foreach ($b3['deck'] as $e) $E[$e['key']] = $e;
chk('entry_base_value_from_points', $E['stat-saw-it-coming']['v'] === 4 && $E['stat-skitter']['v'] === 4, [$E['stat-saw-it-coming']['v'], $E['stat-skitter']['v']]);
chk('entry_ab_from_points_now', $E['stat-saw-it-coming']['fa'] === 4 && $E['stat-saw-it-coming']['fb'] === 2, [$E['stat-saw-it-coming']['fa'], $E['stat-saw-it-coming']['fb']]);
chk('entry_text_has_numbers', str_contains($E['stat-saw-it-coming']['blurb'], 'loses 4.'), $E['stat-saw-it-coming']['blurb']);
// act: tiles with stats where the guard type's usual stat (Nimble) differs from Sense
$stats = ['grit' => 0, 'nimble' => 5, 'hardiness' => 0, 'charm' => 0, 'lore' => 0, 'luck' => 0, 'sense' => 3, 'level' => 9];
$T = []; foreach (pfd_tiles($b3['deck'], $stats) as $t) $T[$t['k']] = $t;
chk('tile_value_counts_own_stat_not_type_stat (Saw It Coming: 4 + Sense 3 + 9/3)', $T['stat-saw-it-coming']['v'] === 4 + 3 + 3, $T['stat-saw-it-coming']['v']);
chk('tile_value_nimble_guard (Skitter: 4 + Nimble 5 + 3)', $T['stat-skitter']['v'] === 12, $T['stat-skitter']['v']);
chk('tile_without_sense_in_stats_uses_modifier_from_points (17 = +3)', pfd_tiles([$E['stat-saw-it-coming']], ['level' => 9])[0]['v'] === 10, pfd_tiles([$E['stat-saw-it-coming']], ['level' => 9])[0]['v']);
chk('tile_carries_src_stat_and_ab', $T['stat-saw-it-coming']['src'] === 'stat' && $T['stat-saw-it-coming']['st'] === 'sense' && $T['stat-saw-it-coming']['fxa'] === 4 && $T['stat-saw-it-coming']['fxb'] === 2);
chk('tile_not_live_has_no_fx (inert until its slice)', !isset($T['stat-saw-it-coming']['fx']));

// ---------------------------------------------------------------- the shared Luck roll
$foe = ['slug' => 'tst', 'name' => 'Test', 'size' => 'medium', 'level' => 10, 'dmg_die' => 6, 'dmg_bonus' => 1];
/** A v1 fight whose deck holds a Long Shot with its fx code, Luck points $lp. */
function rollFight(int $lp, int $seed): array
{
    global $foe;
    $deck = []; foreach (range(1, 10) as $i) $deck[] = pf_make_tile(['swing', 'dodge', 'rest', 'charm'][$i % 4], ['level' => 10]);
    $deck[] = pf_make_tile('stat-long-shot', ['level' => 10], 0, ['n' => 'Long Shot', 't' => 'hurt', 'v' => 2, 'r' => 'body', 'tag' => '', 'src' => 'stat', 'st' => 'luck']) + ['fx' => 'S:stat-long-shot', 'fxa' => 3, 'fxb' => 2];
    return pfb_new(['hp' => 40, 'max_hp' => 40, 'deck' => $deck, 'luck' => 0, 'lpts' => $lp], $foe, $seed, ['v1' => true]);
}
$s0 = rollFight(10, 5);
chk('roll_luck_points_kept_in_state', ($s0['me']['wx']['lp'] ?? null) === 10, $s0['me']['wx'] ?? null);
chk('roll_chance_50_plus_2_per_point_max_90', pfb_wx_chance(['me' => ['wx' => ['lp' => 0]]]) === 50 && pfb_wx_chance(['me' => ['wx' => ['lp' => 10]]]) === 70 && pfb_wx_chance(['me' => ['wx' => ['lp' => 20]]]) === 90 && pfb_wx_chance(['me' => ['wx' => ['lp' => 28]]]) === 90 && pfb_wx_chance($s0) === 70);
// act: roll and !roll clauses of one firing
$oHit = ['c0' => ['roll'], 'c1' => []]; $oMiss = ['c0' => ['!roll'], 'c1' => []]; $agree = true; $once = true; $hits = 0;
for ($seed = 1; $seed <= 2000; $seed++) {
    $s = $s0; $s['rng'] = $seed; $cx = [];
    pfb_wx_roll($s, $oHit, $cx); pfb_wx_roll($s, $oMiss, $cx);
    $r1 = $s0; $r1['rng'] = $seed; pf_rand($r1, 100);
    if ($s['rng'] !== $r1['rng']) $once = false;   // exactly one draw from the fight's rng for the two clauses
    if (pfb_wx_cond($s, 'roll', $cx) === pfb_wx_cond($s, '!roll', $cx)) $agree = false;
    $hits += pfb_wx_cond($s, 'roll', $cx) ? 1 : 0;
}
chk('roll_once_per_firing (one rng draw for two clauses)', $once);
chk('roll_and_not_roll_agree', $agree);
chk('roll_hit_rate_near_chance (70% at 10 points)', $hits > 1320 && $hits < 1480, $hits);
$cx = []; $s = $s0; pfb_wx_roll($s, ['c0' => ['fguard'], 'c1' => []], $cx);
chk('roll_only_when_a_clause_tests_it (no rng draw otherwise)', !isset($cx['roll']) && $s['rng'] === $s0['rng']);
// act: the same firing of Long Shot through pfb_wx_fire on the same state, twice
$s = $s0; $s['pcs'] = []; $s['cell'] = [];
$tile = $s['me']['draw'][0]; foreach (['hand', 'draw', 'discard'] as $z) foreach ($s['me'][$z] as $t) if (($t['fx'] ?? '') === 'S:stat-long-shot') $tile = $t;
$sa = $s; $ca = ['t' => $tile, 'ph' => 'fire']; $la = pfb_wx_fire($sa, $ca, true);
$sb = $s; $cb = ['t' => $tile, 'ph' => 'fire']; $lb = pfb_wx_fire($sb, $cb, true);
chk('roll_deterministic_on_same_state', $ca['roll'] === $cb['roll'] && $sa['rng'] === $sb['rng'] && count($la) === count($lb));
chk('roll_hit_runs_roll_clause_miss_runs_not_roll_clause', count($la) === 1 && $la[0]['a'] === ($ca['roll'] ? 'again' : 'next'), [$ca['roll'], count($la)]);
$seen = [0 => 0, 1 => 0]; for ($seed = 1; $seed <= 60; $seed++) { $x = $s; $x['rng'] = $seed; $c = ['t' => $tile, 'ph' => 'fire']; $l = pfb_wx_fire($x, $c, true); $seen[$c['roll']]++; if (count($l) !== 1 || $l[0]['a'] !== ($c['roll'] ? 'again' : 'next')) $agree = false; }
chk('roll_fire_both_outcomes_seen_and_consistent', $seen[0] > 0 && $seen[1] > 0 && $agree, $seen);
// act: '@place cond act' conditions after the phase are checked (Hedge Rummage form: '@place !roll ...'); a clause with no condition after @place runs
$hd = ['t' => ['fx' => 'S:stat-hedge-rummage', 'fxa' => 3, 'fxb' => 2], 'ph' => 'fire'];
$x = $s; $l = pfb_wx_fire($x, $hd, true);
chk('place_clause_runs_when_placed (pluck always, fup on a miss of the one roll)', isset($hd['roll']) && count($l) === ($hd['roll'] ? 1 : 2) && $l[0]['a'] === 'pluck', [count($l), $hd['roll'] ?? null]);
$o = ['ph' => 'place', 'c0' => [], 'c1' => ['!roll'], 'a' => 'skip', 'x' => [], 'per' => null, 'cap' => null, 'st' => 'post'];
$hits = 0; $runs = 0; for ($seed = 1; $seed <= 200; $seed++) { $x = $s; $x['rng'] = $seed; $c = []; pfb_wx_roll($x, $o, $c); $hits += $c['roll']; $runs += pfb_wx_conds($x, $o['c1'], $c) ? 1 : 0; }
chk('place_condition_after_phase_tests_roll', $hits + $runs === 200 && $hits > 0 && $runs > 0, [$hits, $runs]);
$hd2 = ['t' => $hd['t'], 'ph' => 'fire']; $x = $s; $l = pfb_wx_fire($x, $hd2, false);
chk('place_clause_skipped_when_refired', $l === [] && !isset($hd2['roll']));

// ---------------------------------------------------------------- setting Off: nothing changes
$off = pfd_build(src(false, ['nimble' => 30, 'lore' => 30, 'luck' => 30, 'sense' => 30]));
$old = pfd_build(['level' => 10, 'starter' => array_merge(PFD_CORE, PFD_STARTER_FIXED)] + array_diff_key(pfd_sources_blank(10), ['statp' => 1, 'sbase' => 1, 'spts' => 1]));
chk('off_no_stat_pieces_listed', statKeys($off) === []);
chk('off_build_identical_to_sources_without_stat_fields', json_encode($off) === json_encode($old));
chk('off_state_switch_on_ignored (a saved stat key does nothing)', statKeys(pfd_build(src(false, [], [], ['stat-sidestep' => true]))) === []);
$plain = $s0; foreach (['hand', 'draw', 'discard'] as $z) $plain['me'][$z] = array_values(array_filter($plain['me'][$z], fn($t) => ($t['src'] ?? '') !== 'stat'));
$f1 = pfb_new(['hp' => 40, 'max_hp' => 40, 'deck' => array_merge($plain['me']['hand'], $plain['me']['draw']), 'luck' => 0], $foe, 9, ['v1' => true]);
$f2 = pfb_new(['hp' => 40, 'max_hp' => 40, 'deck' => array_merge($plain['me']['hand'], $plain['me']['draw']), 'luck' => 0, 'lpts' => 25], $foe, 9, ['v1' => true]);
chk('off_no_fx_in_deck_luck_points_leave_no_trace', !isset($f2['wfx']) && json_encode(array_diff_key($f1, ['nonce' => 1])) === json_encode(array_diff_key($f2, ['nonce' => 1])));
$tl = pf_make_tile('dodge', ['nimble' => 4, 'sense' => 9, 'level' => 6]);
chk('off_plain_tile_value_unchanged (Dodge: 6 + Nimble 4 + 2, no st field)', $tl['v'] === 12 && !isset($tl['st']), $tl);

echo $bad ? "$bad FAILED of $n\n" : "ok: $n stat piece plumbing checks\n";
exit($bad ? 1 : 0);
