<?php
// Stat pieces, UI: the Puzzle box shelf (owned pieces with a tier plate, locked pieces with what they need, nothing at all while the setting is Off for the gnome)
// and the board script (Snare Field rings, Sharp Eye / Eyes of the Wood chips, a stolen creature piece). Pure: no DB; the board script is read as text.
// php tests/pf_stat_ui.php
$GLOBALS['TEST_SETTINGS'] = [];
if (!function_exists('setting')) { function setting(string $k): string { return (string)($GLOBALS['TEST_SETTINGS'][$k] ?? ''); } }
if (!function_exists('e')) { function e($s): string { return htmlspecialchars((string)$s, ENT_QUOTES); } }
if (!function_exists('csrf_field')) { function csrf_field(): string { return ''; } }
if (!function_exists('url')) { function url(string $p = ''): string { return '/' . $p; } }
require __DIR__ . '/../game/includes/pfdeck_view.php';
$bad = 0; $n = 0;
function chk(string $name, bool $ok, $got = ''): void { global $bad, $n; $n++; if (!$ok) { $bad++; echo 'FAIL ' . $name . ' (got ' . (is_string($got) ? $got : json_encode($got)) . ")\n"; } }
$C0 = ['larder' => 0, 'larder_max' => 4, 'keeps' => 0, 'keeps_max' => 2, 'rare' => 0, 'mw' => 0];
$u = ['id' => 1, 'role' => 'player', 'level' => 10, 'stat_nimble' => 15, 'stat_lore' => 9, 'stat_luck' => 30, 'stat_sense' => 10];

// ---------------------------------------------------------------- the setting gates the locked list
$GLOBALS['TEST_SETTINGS']['pfight_statpieces'] = '0';
chk('locked_list_empty_while_setting_off', pfv_stat_locked($u) === []);
$GLOBALS['TEST_SETTINGS']['pfight_statpieces'] = 'admin';
chk('locked_list_empty_for_player_while_admins_only', pfv_stat_locked($u) === []);
chk('locked_list_open_for_admin_while_admins_only', pfv_stat_locked(['role' => 'admin'] + $u) !== []);
$GLOBALS['TEST_SETTINGS']['pfight_statpieces'] = '1';

// ---------------------------------------------------------------- which pieces are locked, and what they say
$L = pfv_stat_locked($u);
// arrange: Nimble 15 (owns tiers 0, 10, 15), Lore 9 (tier 0), Luck 30 (all six), Sense 10 (tiers 0, 10) => locked 3 + 5 + 0 + 4 = 12 of 24
chk('locked_count_is_24_minus_owned', count($L) === 12, array_keys($L));
chk('locked_nimble_are_tiers_20_25_30_only', array_map(fn($e) => $e['need'], array_values(array_filter($L, fn($e) => $e['st'] === 'nimble'))) === [20, 25, 30]);
chk('locked_luck_30_nothing_locked', !array_filter($L, fn($e) => $e['st'] === 'luck'));
chk('locked_entries_carry_need_have_and_edges', !array_filter($L, fn($e) => !isset($e['need'], $e['have'], $e['e']) || $e['need'] <= $e['have']));
chk('locked_entries_are_not_in_a_built_deck', !array_intersect(array_keys($L), array_map(fn($p) => $p['key'], pfd_build(['level' => 10, 'statp' => true, 'sbase' => ['nimble' => 15, 'lore' => 9, 'luck' => 30, 'sense' => 10]] + pfd_sources_blank(10))['pieces'])));
$lk = array_values($L)[0];
$html = pfv_box_pc($u, $lk, $C0, ['a' => 'tog', 'g' => 'stat']);
chk('locked_card_says_what_it_needs', str_contains($html, 'Locked: ') && str_contains($html, ' ' . $lk['need']), $html);
chk('locked_card_is_info_only_never_a_pack_toggle', str_contains($html, 'data-a="info"') && !str_contains($html, 'data-a="tog"') && !str_contains($html, 'pfd_toggle'));
chk('locked_card_is_greyed_not_blocked_like_a_full_limit', str_contains($html, 'locked') && !preg_match('/class="pc[^"]*\bblk\b/', $html));
chk('locked_sheet_data_says_points_to_go', str_contains($html, 'more to go'), $html);

// ---------------------------------------------------------------- owned pieces: tier plate (tier 0 has none)
$b = pfd_build(['level' => 10, 'statp' => true, 'sbase' => ['nimble' => 15, 'lore' => 9, 'luck' => 30, 'sense' => 10], 'spts' => ['nimble' => 15, 'lore' => 9, 'luck' => 30, 'sense' => 10]] + pfd_sources_blank(10));
$own = []; foreach ($b['pieces'] as $p) if ($p['src'] === 'stat') $own[$p['key']] = $p;
$e0 = $own['stat-sidestep'] + ['e' => pfd_edges($own['stat-sidestep'])];
$e15 = $own['stat-wrong-turn'] + ['e' => pfd_edges($own['stat-wrong-turn'])];
chk('owned_tier0_has_no_tier_plate', !str_contains(pfv_box_pc($u, $e0, $C0, ['a' => 'tog']), 'pc-tier'));
chk('owned_tier15_has_tier_plate_15', str_contains(pfv_box_pc($u, $e15, $C0, ['a' => 'tog']), '<span class="pc-tier" aria-hidden="true">15</span>'));
chk('owned_piece_sheet_source_line_says_the_points_it_came_from', str_contains(pfv_from($u, $e15), 'yours from 15 Nimble points') && str_contains(pfv_from($u, $e0), 'every gnome has it'));
chk('owned_piece_is_still_a_toggle', str_contains(pfv_box_pc($u, $e15, $C0, ['a' => 'tog']), 'data-a="tog"'));
chk('stat_source_group_has_its_own_filter_and_legend', pfv_src_group('stat') === 'stat' && isset(PFV_SRC_META['stat']));

// ---------------------------------------------------------------- the scripts
$A = __DIR__ . '/../game/assets/';
$js = file_get_contents($A . 'pfboardv1.js'); $css = file_get_contents($A . 'pfv1.css'); $bx = file_get_contents($A . 'pfv1box.js');
chk('board_script_draws_snares_only_from_view_data', str_contains($js, "data.snares) || []") && str_contains($js, "'mk snare'") && str_contains($css, '.mk.snare'));
chk('snares_ride_in_prev_so_the_replay_shows_them_before_the_creature_moves', str_contains($js, "PREV.snares") && str_contains(file_get_contents(__DIR__ . '/../game/includes/pfight_game.php'), "['snares' => pfb_view(\$s)['snares'] ?? []]"));
chk('gone_view_keeps_a_stat_pieces_st_in_php_and_js', str_contains(file_get_contents(__DIR__ . '/../game/includes/pfboard.php'), "\$v['gone'][\$i]['st']") && str_contains(file_get_contents(__DIR__ . '/../tools/pfengine.js'), "q.st = String(nn(s.gone[gi].tile.st"));
chk('board_script_has_sense_chips_for_sight_and_eyes', str_contains($js, 'function senseChips') && str_contains($js, 'data.sight') && str_contains($js, 'data.eyes') && str_contains($js, 'h += senseChips()') && str_contains($css, '.tg.sense'));
chk('board_script_marks_a_stolen_piece', str_contains($js, 'pfb-ws') && str_contains($js, 'pfv-stolen') && str_contains($js, 'Stolen from the creature') && str_contains($css, '.pfb-ws'));
chk('board_script_tells_what_a_copybook_taught_piece_is', str_contains($js, 'Copybook taught it a tag'));
chk('box_script_knows_the_stat_source_icon', str_contains($bx, "stat: 'ico/ico-sparkle.png'"));
chk('box_css_has_tier_plate_and_locked', str_contains($css, '.pc-tier') && str_contains($css, '.pc.locked'));

echo $bad ? "$bad FAILED of $n\n" : "ok: $n stat piece UI checks\n";
exit($bad ? 1 : 0);
