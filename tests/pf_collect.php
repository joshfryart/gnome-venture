<?php
// Playtest DATA COLLECTION for the v1 puzzle-fight board (Josh 2026-11-22: the 10-creature test). No DB, the REAL engine, ground truth from the engine state and events.
//   php tests/pf_collect.php OUTDIR [SHARD/NSHARDS=0/1] [SLUGS=the 10] [SEEDS=3]       one shard: writes OUTDIR/<table>.<shard>.csv
//   GRID=cp php tests/pf_collect.php OUTDIR SHARD/N all 3   creature-piece run: all creatures x chain, look x Balanced, Grit x offsets 0, -4 (lean; fights, pieces, creature_pieces)
//   php tests/pf_collect.php profiles OUTDIR                                            the Gnome profiles table (stats, HP and unlocks by level per profile)
//   Tables: fights, turns, options (one row per legal option per turn: CSV only, too big for a sheet), regret, pieces. tests/pf_collect_agg.py merges the shards,
//   builds the runs row, the Sonnet findings and the sheet-sized summaries.
// The grid: 10 creatures x bots chain, look, newbie, charm (tests/pf_bots.php pb_choose) x 8 stat profiles x level offsets 0 and -4 x 3 seeds (the pf_bots seed formula), build std,
//   plus CONTROL fights: profile Balanced, offset 0, the same creature, seed and deck sources with ONE stat moved by +2 or -2 raw points (ctrl = 'grit+2' ...).
// STAT RULES (game/includes/gnome.php, functions.php settings, schema.php): every stat starts at 10, a new gnome has 4 stat points, +stat_points_per_level (default 1) per level
//   after 1, so (level + 3) points; each stat at most stat_max (default 30); the fight uses stat_mod = floor((v - 10) / 2) (pfight_calc: eff_mod for grit nimble hardiness charm lore luck);
//   a piece is base + max(0, mod of PF_STAT[type]) + level / 3 + bonuses (pf_make_tile); max HP = 20 + 3 x level + 5 x Hardiness mod (gnome_combat; calling hp_bonus left out as the tuner does);
//   luck mod = the fight's luckmod. ASSUMED: points go in pairs (a lone point does nothing), Balanced spreads pairs over all 7 stats incl. Sense (that is the tuner's model gnome,
//   m = (level + 3) / 14), a one-stat profile fills its stat to 30 then spreads the rest like Balanced, Grit+Hardiness alternates pairs; no food, meal, tea, pal road or calling perks.
// FULL RUN (Josh 2026-11-22: all creatures, different scenarios): GRID=full php tests/pf_collect.php OUTDIR SHARD/N all 3   runs the pc_jobs_full() grid (all creatures x profiles x level offsets -8..+4 x builds std/pals/norare
//   x bots chain, look, newbie, charm, random, greedy, defensive x 3 seeds, plus one-stat controls on every 5th creature). That mode is LEAN: it plays every fight but only prices the chosen option (forecast error stays), so it writes
//   the fights table (and pieces for chain, seed 0, offset 0); the per-turn, option and regret tables come from a second FULL pass over a sample: ONLY=file_of_fight_ids php tests/pf_collect.php OUTDIR SHARD/N all 3 (GRID=full) plays just
//   those fights with everything logged. tests/pf_collect_full_agg.py builds the sheet aggregates.
// Unlocks by level (tools, pals, crops, crafts, regions, calling tier, knacks) are tests/pfboard_tune_v1.php tv_sources().
require_once __DIR__ . '/pf_bots.php';

const PC_SLUGS = ['cloud-leopard', 'frost-hare', 'gnat-cloud', 'aphid-swarm', 'garden-snail', 'honey-badger-brute', 'great-hawk', 'snow-owl-monarch', 'fly-swarm', 'tide-crab-paladin'];
const PC_BOTS = ['chain', 'look', 'newbie', 'charm'];
const PC_STATS7 = ['grit', 'hardiness', 'nimble', 'charm', 'lore', 'luck', 'sense'];
const PC_FIGHT6 = ['grit', 'nimble', 'hardiness', 'charm', 'lore', 'luck'];
const PC_PROFILES = ['Balanced' => [], 'Grit' => ['grit'], 'Nimble' => ['nimble'], 'Hardiness' => ['hardiness'], 'Charm' => ['charm'], 'Lore' => ['lore'], 'Luck' => ['luck'], 'Grit+Hardiness' => ['grit', 'hardiness']];
const PC_OFFSETS = [0, -4];

/** Raw stats at a level for a profile: [stats, points spent]. */
function pc_alloc(int $lv, string $prof): array
{
    $max = 30; $pts = 4 + max(0, $lv - 1) * 1; $st = array_fill_keys(PC_STATS7, 10); $focus = PC_PROFILES[$prof];
    $spent = 0; $fi = 0; $bi = 0;
    while ($pts - $spent > 0) {
        $put = min(2, $pts - $spent); $k = null;
        foreach ($focus as $_) { $c = $focus[$fi++ % count($focus)]; if ($st[$c] + $put <= $max) { $k = $c; break; } }
        if ($k === null) for ($j = 0; $j < 7; $j++) { $c = PC_STATS7[$bi++ % 7]; if ($st[$c] + $put <= $max) { $k = $c; break; } }
        if ($k === null) break;
        $st[$k] += $put; $spent += $put;
    }
    return [$st, $spent];
}
function pc_mods(array $raw, int $lv): array { $m = ['level' => $lv]; foreach (PC_FIGHT6 as $k) $m[$k] = pc_stat_mod((int)$raw[$k]); return $m; }
function pc_stat_mod(int $v): int { return intdiv($v - 10 - ($v < 10 ? 1 : 0), 2); }   // = stat_mod() in game/includes/gnome.php (not loaded here: it needs the DB layer)

/** The gnome: player array for pfb_new, plus the meta for the tables. $ctrl = ['grit', +2] moves one raw stat (the deck sources stay the same). */
function pc_player(int $lv, string $prof, ?array $ctrl = null, string $build = 'std'): array
{
    [$raw, $spent] = pc_alloc($lv, $prof);
    if ($ctrl) $raw[$ctrl[0]] = max(3, min(30, $raw[$ctrl[0]] + $ctrl[1]));
    $mods = pc_mods($raw, $lv); $src = tv_sources($lv);
    if ($build === 'pals') {   // as pb_player: four pals and no belt tools
        $src['tools'] = []; $src['belt'] = [];
        $src['pals'] = []; foreach ([['Bark Badger', 'guard', 'craft'], ['Samara Spin', 'hurt', 'body'], ['Moss Mole', 'charm', 'body'], ['Dew Wren', 'hurt', 'craft']] as [$n, $t, $r]) $src['pals'][] = ['n' => $n, 't' => $t, 'v' => 5 + intdiv($lv, 6), 'r' => $r, 'rank' => min(3, 1 + intdiv($lv, 12))];
    }
    $ent = array_values(pfd_fight_entries($src));
    if ($build === 'norare') $ent = array_values(array_filter($ent, fn($e) => (int)($e['rank'] ?? 0) <= 2));   // nothing above Uncommon
    $deck = pfd_tiles($ent, $mods, [], $src['calling'], $src['ctier']);
    foreach ($deck as $i => $t) $deck[$i]['uid'] = $i;   // our tracking id: rides on the tile through hand, board, discard
    $max = max(10, 20 + 3 * $lv + 5 * $mods['hardiness']);
    return [['hp' => $max, 'max_hp' => $max, 'stats' => $mods, 'deck' => $deck, 'luck' => max(0, $mods['luck'])], ['raw' => $raw, 'spent' => $spent, 'mods' => $mods, 'src' => $src, 'ent' => $ent, 'max' => $max]];
}

function pc_e(array $t): string { $o = ''; foreach (pfb_edges($t) as $k => $e) $o .= $k . ':' . ($e[0] === 'flat' ? 'flat' : ($e[0] === 'wild' ? 'wild' : $e[0] . ($e[1] ? '+' : '-'))) . ' '; return rtrim($o); }
function pc_board(array $s): string
{
    $r = [];
    for ($y = 0; $y < pfb_h($s); $y++) { $l = []; for ($x = 0; $x < pfb_w($s); $x++) { $p = pfb_at($s, $x, $y); $tr = ['sun' => '*', 'br' => '#', 'mud' => '~', '' => ''][pfb_ter($s, $x, $y)] ?? '';
        $l[] = $p ? (['me' => 'Y', 'foe' => 'C', 'env' => 'E', 'none' => 'B'][$p['by']] ?? '?') . ($p['by'] === 'env' ? substr((string)($p['tile']['env'] ?? $p['tile']['n']), 0, 3) : ($p['by'] === 'none' ? '' : substr($p['tile']['t'], 0, 2) . $p['tile']['v'])) . $tr : '.' . $tr; }
        $r[] = implode(' ', $l); }
    return implode(' / ', $r);
}
function pc_hand(array $s): string
{
    return implode(' ; ', array_map(fn($i, $t) => $i . ':' . $t['n'] . '|' . $t['t'] . '|' . $t['v'] . '|' . pc_e($t) . '|' . ($t['src'] ?? '') . '|r' . (int)($t['rank'] ?? 0) . '|' . ($t['tag'] ?? '') . (($t['m'] ?? '') ? '+' . $t['m'] : '') . (!empty($t['flip']) ? '|FLIP' : '') . '|u' . ($t['uid'] ?? '-'), array_keys($s['me']['hand']), $s['me']['hand']));
}
function pc_act_s(array $s, array $a): string
{
    if ($a[0] === 'pass') return 'pass';
    $t = is_int($a[0]) ? ($s['me']['hand'][$a[0]] ?? null) : null;
    return ($a[0] === 'c' ? 'group' : ($t['n'] ?? '?')) . '@' . $a[1] . ',' . $a[2] . (!empty($a[3]) ? ' flip' : '');
}

/** Everything about one legal option: the preview numbers (as pfb_cell_preview: a dry pfb_play), the aim after it, the whole turn played on a copy, and each bot's score. */
function pc_option(array $s, array $a): ?array
{
    $hp0 = (int)$s['me']['hp']; $fh0 = (float)$s['fh']['now']; $b0 = (float)$s['bar']['now']; $g0 = (int)$s['me']['block'];
    $w = $s; if (!empty($a[3])) pfb_flip($w, $a[0], $w['turn']);
    $dr = pfb_play($w, [[$a[0] === 'c' ? 'c' : (int)$a[0], $a[1], $a[2]]], $w['turn'], null, true, true); if ($dr['err']) return null;
    $n = 0; $tw = 1.0; $sun = 0; $miss = ''; $pal = ''; $team = 0;
    foreach ($dr['ev'] as $e) { if (isset($e['barnow'])) $n++; if (isset($e['tw'])) $tw = (float)$e['tw']; if (!empty($e['sun']) && ($e['by'] ?? '') === 'me') $sun++; if (($e['by'] ?? '') === 'me' && ($e['t'] ?? '') === 'hurt' && isset($e['evaded']) && $miss === '') $miss = (string)$e['n']; if (($e['note'] ?? '') === 'palaim') $pal = (string)$e['n']; }
    $aim = $dr['aim'] ?? null;
    $f = $s; $r = tv_act($f, $a); if ($r['err']) return null;
    [$w2, $nf] = tv_dry($s, $a);
    $dmg = ($w2['fh']['now'] - $fh0) + ($w2['bar']['now'] - $b0); $win2 = $w2['over'] && $w2['over'] !== 'defeat';
    $o = ['d' => (int)pf_round($dr['fh'] - $fh0), 'c' => (int)pf_round($dr['bar'] - $b0), 'h' => max(0, $hp0 - (int)$dr['hp']), 'n' => $n, 'used' => !empty($dr['ev'][0]['used']) ? 1 : 0, 'tw' => $tw, 'sun' => $sun, 'miss' => $miss, 'pal' => $pal,
        'end' => $dr['over'] ? ($dr['over'] === 'defeat' ? 'loss' : 'win') : '', 'guard' => (int)$dr['block'] - $g0,
        'fc_hp' => is_array($aim) && isset($aim['hp']) ? (int)$aim['hp'] : '', 'fc_broken' => is_array($aim) ? (string)($aim['broken'] ?? (isset($aim['strike']) ? 'strike' : '')) : 'none',
        't_hplost' => $hp0 - (int)$f['me']['hp'], 't_dmg' => round($f['fh']['now'] - $fh0, 1), 't_ch' => round($f['bar']['now'] - $b0, 1), 't_over' => (string)$f['over'], 'die_after' => (!$dr['over'] && $f['over'] === 'defeat') ? 1 : 0,
        'evade_risk' => (int)($s['foe']['evade'] ?? 0) > 0 ? 1 : 0,
        's_chain' => $nf * 1000 + ($w2['fh']['now'] + $w2['bar']['now']) + ($win2 ? 1e6 : 0), 's_look' => round(tv_value($f), 4),
        's_greedy' => round($dmg + ($win2 ? 1e6 : 0), 3), 's_defensive' => round(($w2['me']['hp'] - $hp0) * 2 + ($w2['me']['block'] - $g0) + 0.2 * $dmg, 3), 's_charm' => round(($w2['bar']['charm'] ?? 0) - ($s['bar']['charm'] ?? 0) + 0.05 * $dmg, 3)];
    $o['s_newbie'] = empty($a[3]) ? $o['s_chain'] : '';
    $o['useful'] = ($o['guard'] > 0 || $f['fh']['now'] + $f['bar']['now'] - $fh0 - $b0 > 1e-9 || $f['me']['block'] + $f['me']['keep'] - $g0 > 1e-9 || $f['me']['hp'] > $hp0 || in_array($f['over'], ['seen_off', 'charmed'], true)) ? 1 : 0;
    return $o;
}

$PC_H = [
 'fights' => ['run_id', 'version', 'git_sha', 'fight_id', 'ctrl', 'creature', 'family', 'size', 'creature_level', 'region', 'class_rule', 'class_rule_text', 'ai_type', 'abilities', 'tune_foe_x', 'tune_bar_x', 'bar_max', 'charm_mult_cm', 'hurt_mult_hm',
   'gnome_level', 'offset', 'profile', 'stat_points_spent', 'grit', 'nimble', 'hardiness', 'charm', 'lore', 'luck', 'sense', 'mod_grit', 'mod_nimble', 'mod_hardiness', 'mod_charm', 'mod_lore', 'mod_luck', 'max_hp',
   'deck_size', 'deck_by_source', 'deck_by_type', 'tool_tiers', 'pals', 'crops', 'crafts', 'calling', 'calling_tier', 'build', 'bot', 'seed',
   'result', 'win', 'end_reason', 'turns', 'hp_lost', 'hp_left', 'hp_lost_pct', 'damage_end', 'charm_end', 'bar_fill_pct', 'passes', 'refused', 'flips', 'longest_chain', 'chain_count', 'combos', 'teamwork_fires', 'env_pieces_fired_mine', 'turn_cap_hit',
   'forecast_n', 'forecast_abs_err_mean', 'regret_look_mean', 'dead_hand_turns', 'secs',
   'cr_pieces_total', 'cr_pieces_placed', 'cr_pieces_fired', 'cr_dmg_total', 'cr_blocked_total'],
 'turns' => ['fight_id', 'turn', 'bot', 'profile', 'creature', 'offset', 'hp_start', 'hp_end', 'max_hp', 'dmg_start', 'dmg_end', 'charm_start', 'charm_end', 'bar_max', 'my_guard', 'creature_guard', 'draw_n', 'discard_n', 'board', 'env_next', 'hazards',
   'hand', 'legal_n', 'chosen', 'chosen_piece', 'chosen_cell', 'chosen_flip', 'pv_d', 'pv_c', 'pv_h', 'pv_n', 'pv_flags', 'aim_cell', 'aim_piece', 'aim_forecast_before', 'aim_forecast_after',
   'my_chain_len', 'my_pieces_fired', 'used_up', 'act_dmg', 'act_charm', 'act_hp_lost_my_chain', 'pred_d_err', 'pred_c_err', 'pred_h_err',
   'cr_pieces', 'cr_dmg_dealt', 'cr_blocked_by_guard', 'cr_evade_misses_mine', 'my_evade_dodged_it', 'cr_quick', 'cr_slow', 'cr_grudge', 'cr_riposte', 'poison_on_me', 'poison_on_it', 'cr_fired_my_pieces', 'cr_bait_dmg', 'env_hp_lost',
   'hp_lost_turn', 'forecast_err', 'reaim', 'over', 'my_guard_end', 'creature_guard_end', 'actual_first_chain_hp'],
 'options' => ['fight_id', 'turn', 'opt', 'piece', 'hand_idx', 'cell', 'flip', 'd', 'c', 'h', 'n', 'used_up', 'teamwork', 'sun', 'evade_miss', 'pal_knock', 'end', 'guard_gain', 'evade_risk', 'aim_forecast_hp', 'aim_broken',
   'turn_hp_lost', 'turn_dmg', 'turn_charm', 'turn_over', 'die_after', 's_chain', 's_look', 's_newbie', 's_charm', 's_greedy', 's_defensive', 'useful', 'chosen'],
 'regret' => ['fight_id', 'turn', 'bot', 'profile', 'creature', 'offset', 'chosen', 'best_look', 'same', 'gap_look_value', 'gap_dmg', 'gap_charm', 'gap_hp_lost', 'dead_hand', 'legal_n'],
 'creature_pieces' => ['fight_id', 'creature', 'size', 'creature_level', 'class_rule', 'bot', 'profile', 'offset', 'uid', 'key', 'name', 'type', 'tag', 'mod', 'base', 'value', 'edges', 'drawn', 'placed', 'placed_turns', 'fired', 'fired_own', 'fired_mine',
   'fired_val', 'dmg', 'blocked', 'evaded', 'evaded_dmg', 'guard_gain', 'healed', 'riposte', 'quick', 'poisoned', 'tripped', 'grudge_fires', 'swarm_fires', 'swarm_bonus', 'ambush', 'bait_dmg', 'struck', 'struck_broke', 'used_up', 'used_by_me', 'fell', 'expired', 'fight_win', 'fight_turns'],
 'pieces' => ['fight_id', 'uid', 'key', 'name', 'type', 'base', 'stat', 'stat_contrib', 'level_contrib', 'bonus', 'value', 'source', 'rank', 'tag', 'edges', 'drawn', 'played', 'fired', 'flipped', 'expired', 'used_up', 'fell', 'dmg', 'charm', 'hp'],
];

function pc_csv($fh, array $row): void { fputcsv($fh, array_map(fn($v) => is_bool($v) ? (int)$v : (is_float($v) ? round($v, 3) + 0.0 : $v), $row), ',', '"', ''); }

function pc_fight(array $c, int $lv, string $bot, string $prof, int $seed, int $d, ?array $ctrl, array $out, array $meta0, string $build = 'std', bool $full = true, bool $wantPieces = true, ?string $fid = null): void
{
    $t0 = microtime(true); mt_srand($seed); $rng = fn(int $n) => $n > 0 ? mt_rand(0, $n - 1) : 0;
    [$pl, $pm] = pc_player($lv, $prof, $ctrl, $build);
    $region = array_keys(pfd_region_pieces())[(crc32($c['slug']) + $seed) % 14]; $cr = pfd_foe_row($c, $region);
    foreach ($cr['deck'] as $i => $ft0) $cr['deck'][$i]['uid'] = $i;   // our tracking id for creature pieces
    $s = pfb_new($pl, $cr, $seed, ['blank' => true, 'v1' => true]);
    $fid ??= pc_fid($c['slug'], $lv, $bot, $prof, $seed, $ctrl, $build, $d);
    $P = []; foreach ($pl['deck'] as $i => $t) $P[$i] = ['drawn' => 0, 'played' => 0, 'fired' => 0, 'flipped' => 0, 'expired' => 0, 'used_up' => 0, 'fell' => 0, 'dmg' => 0.0, 'charm' => 0.0, 'hp' => 0];
    $idu = []; $prevHand = [];
    $CT = []; $CC = []; $idc = []; $prevFH = [];   // creature pieces: tile by uid, counters by uid, board id -> uid
    foreach (['hand', 'draw', 'discard'] as $z) foreach ($s['foe'][$z] as $ft0) if (isset($ft0['uid'])) { $CT[$ft0['uid']] = $ft0; $CC[$ft0['uid']] = array_fill_keys(['drawn', 'placed', 'fired', 'fired_own', 'fired_mine', 'fired_val', 'dmg', 'blocked', 'evaded', 'evaded_dmg', 'guard_gain', 'healed', 'riposte', 'quick', 'poisoned', 'tripped', 'grudge_fires', 'swarm_fires', 'swarm_bonus', 'ambush', 'bait_dmg', 'struck', 'struck_broke', 'used_up', 'used_by_me', 'fell', 'expired'], 0) + ['turns' => []]; }
    foreach ($s['foe']['hand'] as $ft0) { $CC[$ft0['uid']]['drawn']++; $prevFH[$ft0['uid']] = 1; }
    $cscan = function (int $tn) use (&$s, &$idc, &$CC) { foreach ($s['pcs'] as $q) if ($q['by'] === 'foe' && isset($q['tile']['uid']) && !isset($idc[$q['id']])) { $idc[$q['id']] = $q['tile']['uid']; $CC[$q['tile']['uid']]['placed']++; $CC[$q['tile']['uid']]['turns'][] = $tn; }
        foreach ($s['gone'] ?? [] as $g) if ($g['by'] === 'foe' && isset($g['tile']['uid']) && !isset($idc[$g['id']])) { $idc[$g['id']] = $g['tile']['uid']; $CC[$g['tile']['uid']]['placed']++; $CC[$g['tile']['uid']]['turns'][] = $tn; } };
    $cscan(0);
    $hand = $s['me']['hand'];
    foreach ($hand as $t) { $P[$t['uid']]['drawn']++; $prevHand[$t['uid']] = 1; }
    if ($hand) { $bi = 0; foreach ($hand as $i => $t) if ($t['t'] === 'hurt' && $t['v'] > $hand[$bi]['v']) $bi = $i; $su = $hand[$bi]['uid']; pfb_start($s, $bi, ['L', 'R', 'T', 'B'][$seed % 4]); $P[$su]['played']++; foreach ($s['pcs'] as $p) if ($p['by'] === 'me') $idu[$p['id']] = $p['tile']['uid']; }
    $F = ['passes' => 0, 'refused' => 0, 'flips' => 0, 'longest' => 0, 'chains' => 0, 'combos' => [], 'tw' => 0, 'envmine' => 0, 'fcn' => 0, 'fcerr' => 0.0, 'reg' => 0.0, 'regn' => 0, 'dead' => 0];
    $t = 0;
    while (!$s['over'] && $t++ < 40) {
        if ($t > 1) { $nf = []; foreach ($s['foe']['hand'] as $ft0) { if (isset($ft0['uid']) && !isset($prevFH[$ft0['uid']])) $CC[$ft0['uid']]['drawn']++; if (isset($ft0['uid'])) $nf[$ft0['uid']] = 1; } $prevFH = $nf; }
        if ($t > 1) { $nh = []; foreach ($s['me']['hand'] as $ht) { if (!isset($prevHand[$ht['uid']])) $P[$ht['uid']]['drawn']++; $nh[$ht['uid']] = 1; } $prevHand = $nh; }
        $places = tv_places($s); $a = pb_choose($s, $bot, $places, $rng);
        $hp0 = (int)$s['me']['hp']; $fh0 = (float)$s['fh']['now']; $b0 = (float)$s['bar']['now']; $max = (int)$s['me']['max'];
        $plan = $s['foe']['plan'] ?? null; $fcBefore = is_array($plan['tot'] ?? null) ? ($plan['tot']['hp'] ?? ($plan['tot']['broken'] ?? '')) : '';
        $opts = []; $ci = null; $bestK = null;
        foreach ($places as $k => $op) { if (!$full && $op !== $a) continue; $o = pc_option($s, $op); if (!$o) continue; $opts[$k] = $o; if ($op === $a) $ci = $k; if ($bestK === null || $o['s_look'] > $opts[$bestK]['s_look']) $bestK = $k; }
        if ($full) foreach ($opts as $k => $o) { $op = $places[$k]; $tt = is_int($op[0]) ? $s['me']['hand'][$op[0]] : null;
            pc_csv($out['options'], [$fid, $t, $k, $tt['n'] ?? 'group', $op[0], $op[1] . ',' . $op[2], (int)!empty($op[3]), $o['d'], $o['c'], $o['h'], $o['n'], $o['used'], $o['tw'], $o['sun'], $o['miss'], $o['pal'], $o['end'], $o['guard'], $o['evade_risk'], $o['fc_hp'], $o['fc_broken'],
                $o['t_hplost'], $o['t_dmg'], $o['t_ch'], $o['t_over'], $o['die_after'], $o['s_chain'], $o['s_look'], $o['s_newbie'], $o['s_charm'], $o['s_greedy'], $o['s_defensive'], $o['useful'], (int)($k === $ci)]); }
        $co = $ci !== null ? $opts[$ci] : null;
        $dead = $opts ? (int)!array_filter($opts, fn($o) => $o['useful']) : 1; if ($full) $F['dead'] += $dead;
        if (!$full) { } elseif ($bestK !== null) { $bo = $opts[$bestK]; $ref = $co ?? ['s_look' => null, 't_dmg' => 0, 't_ch' => 0, 't_hplost' => 0];
            if ($co === null) { $w = $s; pfb_pass($w, $w['turn']); $ref = ['s_look' => tv_value($w), 't_dmg' => round($w['fh']['now'] - $fh0, 1), 't_ch' => round($w['bar']['now'] - $b0, 1), 't_hplost' => $hp0 - (int)$w['me']['hp']]; }
            $gap = $bo['s_look'] - $ref['s_look']; $F['reg'] += $gap; $F['regn']++;
            pc_csv($out['regret'], [$fid, $t, $bot, $prof, $c['slug'], $d, pc_act_s($s, $a), pc_act_s($s, $places[$bestK]), (int)($ci === $bestK), round($gap, 4), round($bo['t_dmg'] - $ref['t_dmg'], 1), round($bo['t_ch'] - $ref['t_ch'], 1), $ref['t_hplost'] - $bo['t_hplost'], $dead, count($opts)]);
        } else pc_csv($out['regret'], [$fid, $t, $bot, $prof, $c['slug'], $d, pc_act_s($s, $a), '', '', '', '', '', '', $dead, 0]);
        $pre = ['hand' => pc_hand($s), 'board' => pc_board($s), 'draw' => count($s['me']['draw']), 'disc' => count($s['me']['discard']), 'g' => (int)$s['me']['block'], 'fg' => (int)($s['foe']['block'] ?? 0),
            'env' => implode(', ', array_map(fn($e) => $e['n'], $s['env']['next'] ?? [])),
            'haz' => implode(' ', array_filter(['ter=' . implode(',', array_map(fn($k, $v) => "$k:$v", array_keys($s['ter'] ?? []), $s['ter'] ?? [])), (int)($s['me']['poison'] ?? 0) ? 'poisoned:' . $s['me']['poison'] . 'x' . $s['me']['poison_v'] : '', !empty($s['me']['tripped']) ? 'tripped' : '', (int)($s['foe']['evade'] ?? 0) ? 'foe_evade' : '', !empty($s['foe']['thorns']) ? 'foe_thorns' : '', ($s['ven'] ?? []) ? 'venom:' . implode(',', array_keys($s['ven'])) : '', (int)($s['foe']['grudge'] ?? 0) ? 'grudge' . $s['foe']['grudge'] : ''])),
            'aim' => $plan ? $plan['x'] . ',' . $plan['y'] : '', 'aimp' => $plan ? $plan['n'] . ' ' . $plan['t'] . ' ' . $plan['v'] : ''];
        $chUid = is_int($a[0]) ? ($s['me']['hand'][$a[0]]['uid'] ?? null) : null;
        if ($a[0] === 'pass') $F['passes']++; if (!empty($a[3])) { $F['flips']++; if ($chUid !== null) $P[$chUid]['flipped']++; }
        foreach ($s['pcs'] as $p) if ($p['by'] === 'me' && isset($p['tile']['uid'])) $idu[$p['id']] = $p['tile']['uid'];
        $s0hand = $s['me']['hand']; $fhk = []; foreach ($s['foe']['hand'] as $ft0) if (isset($ft0['uid']) && !isset($fhk[$ft0['k']])) $fhk[$ft0['k']] = $ft0['uid'];
        $r = tv_act($s, $a);
        if ($r['err']) { $F['refused']++; $chUid = null; $r = pfb_pass($s, $s['turn']); if ($r['err']) { if (!$places) break; $r = tv_act($s, $places[0]); if ($r['err']) break; $chUid = is_int($places[0][0]) ? ($s0hand[$places[0][0]]['uid'] ?? null) : null; } }
        if ($chUid !== null) $P[$chUid]['played']++;
        // parse the events: my chain, the creature's reply, the terrain
        $ph = $hp0; $pf = $fh0; $pb = $b0; $myLen = 0; $myN = 0; $usedN = 0; $myD = 0.0; $myC = 0.0; $myH = 0; $X = ['pc' => 0, 'dd' => 0, 'blk' => 0, 'miss' => 0, 'dodge' => 0, 'q' => 0, 'sl' => 0, 'gr' => 0, 'rip' => 0, 'pme' => 0, 'pit' => 0, 'fm' => 0, 'bait' => 0.0, 'env' => 0];
        $rootSeen = false; $foeFirst = null; $hpMid = null; $lastFoe = null; $inFirst = false;
        foreach ($r['ev'] as $e) {
            $ta = $e['ta'] ?? ''; $by = $e['by'] ?? '';
            if (isset($e['rid']) && $ta === 'me' && !$rootSeen && $chUid !== null) { $idu[(int)$e['rid']] = $chUid; $rootSeen = true; }
            if (isset($e['barnow'])) {
                $dd = (float)$e['fhnow'] - $pf; $dc = (float)$e['barnow'] - $pb; $dh = (int)$e['hpnow'] - $ph;
                if (isset($e['id']) && $by === 'me' && isset($idu[$e['id']])) { $u = $idu[$e['id']]; $P[$u]['fired']++; $P[$u]['dmg'] += $dd; $P[$u]['charm'] += $dc; $P[$u]['hp'] += $dh; }
                if ($ta === 'me') { $myD += $dd; $myC += $dc; if ($dh < 0) $myH -= $dh; }
                elseif ($ta === 'foe') { if ($dh < 0) $X['dd'] -= $dh; if (!empty($e['tick'])) $X['pit'] += (int)($e['v'] ?? 0); }
                elseif ($ta === 'env') { if ($dh < 0) $X['env'] -= $dh; if (($e['env'] ?? '') === 'poison') $X['pme'] += (int)$e['me']; }
                $pf = (float)$e['fhnow']; $pb = (float)$e['barnow']; $ph = (int)$e['hpnow'];
            }
            if ($ta === 'me' && isset($e['id'])) { $myN++; if (!empty($e['cs'])) $F['chains']++; if (!empty($e['used'])) $usedN += count($e['used']); if ($by === 'env') $F['envmine']++; if (!empty($e['combo'])) $F['combos'][$e['combo']] = ($F['combos'][$e['combo']] ?? 0) + 1; if ($by === 'me' && ($e['t'] ?? '') === 'hurt' && isset($e['evaded'])) $X['miss']++; }
            if ($ta === 'foe') {
                if (isset($e['id']) && !empty($e['cs'])) { $X['pc']++; if ($foeFirst === null) { $foeFirst = 1; $inFirst = true; } else $inFirst = false; }
                if ($inFirst && isset($e['id']) && isset($e['hpnow'])) $lastFoe = $e;
                if ($by === 'foe' && ($e['t'] ?? '') === 'hurt') { $X['blk'] += (int)($e['blocked'] ?? 0); if (isset($e['evaded'])) $X['dodge']++; $X['gr'] = max($X['gr'], (int)($e['gr'] ?? 0)); }
                if (($e['combo'] ?? '') === 'Riposte') $X['rip']++;
                if (($e['note'] ?? '') === 'quick') $X['q']++; if (($e['note'] ?? '') === 'slow') $X['sl']++;
                if ($by === 'me' && isset($e['id'])) { $X['fm']++; $X['bait'] += (float)($e['fh'] ?? 0); }
            }
        }
        $cscan($t);
        foreach ($r['ev'] as $e) {   // creature pieces: whose piece fired, what it did
            if (($e['by'] ?? '') !== 'foe') continue;
            if (!empty($e['strike'])) { $u = $fhk[$e['k']] ?? null; if ($u !== null) { $CC[$u]['struck']++; $CC[$u]['fired']++; $CC[$u]['fired_val'] += (int)$e['v']; if (!empty($e['broke'])) $CC[$u]['struck_broke']++; } continue; }
            if (!isset($e['id']) || !isset($idc[$e['id']]) || !isset($e['barnow'])) continue;
            $u = $idc[$e['id']]; $C = &$CC[$u]; $C['fired']++; if (($e['ta'] ?? '') === 'me') $C['fired_mine']++; else $C['fired_own']++; $C['fired_val'] += (int)$e['v'];
            if (($e['t'] ?? '') === 'hurt') { $C['dmg'] += (int)($e['dmg'] ?? 0); $C['blocked'] += (int)($e['blocked'] ?? 0); if (isset($e['evaded'])) { $C['evaded']++; $C['evaded_dmg'] += (int)$e['evaded']; } if (($e['ta'] ?? '') === 'me') $C['bait_dmg'] += (int)($e['dmg'] ?? 0); }
            if (($e['t'] ?? '') === 'guard') $C['guard_gain'] += (int)$e['v'];
            if (isset($e['healed'])) $C['healed'] += (float)$e['healed'];
            if (($e['combo'] ?? '') === 'Riposte') { $C['riposte']++; $C['dmg'] += (int)($e['reflect'] ?? 0); }
            if (!empty($e['root']) && ($e['tag'] ?? '') === 'quick') $C['quick']++;
            if (isset($e['poisoned'])) $C['poisoned']++; if (isset($e['tripped'])) $C['tripped']++;
            if (!empty($e['gr'])) $C['grudge_fires']++; if (!empty($e['sw'])) { $C['swarm_fires']++; $C['swarm_bonus'] += (int)$e['sw']; } if (!empty($e['amb'])) $C['ambush']++;
            unset($C);
        }
        foreach ($s['gone'] ?? [] as $g) if ($g['by'] === 'foe' && isset($g['tile']['uid'])) { $u = $g['tile']['uid']; if (isset($g['used'])) { $CC[$u]['used_up']++; if ($g['used'] === 'me') $CC[$u]['used_by_me']++; } elseif (!empty($g['fell'])) $CC[$u]['fell']++; else $CC[$u]['expired']++; }
        // the first creature chain starts after my chain: recompute health at its start
        $hpMid = $hp0;
        foreach ($r['ev'] as $e) if (($e['ta'] ?? '') === 'me' && isset($e['hpnow'])) $hpMid = (int)$e['hpnow'];
        $myLen = $myN;   // one placement a turn: every piece fired in my turn is in its chain (the placed piece is not always the first to fire)
        foreach ($r['ev'] as $e) if (($e['ta'] ?? '') === 'me' && isset($e['tw'])) { $F['tw']++; break; }
        $F['longest'] = max($F['longest'], $myLen);
        foreach ($s['gone'] ?? [] as $g) if ($g['by'] === 'me' && isset($g['tile']['uid'])) { $u = $g['tile']['uid']; if (isset($g['used'])) $P[$u]['used_up']++; elseif (!empty($g['fell'])) $P[$u]['fell']++; else $P[$u]['expired']++; }
        foreach ($s['pcs'] as $p) if ($p['by'] === 'me' && isset($p['tile']['uid'])) $idu[$p['id']] = $p['tile']['uid'];
        $fcAfter = $co['fc_hp'] ?? ''; $fcErr = '';
        if ($fcAfter !== '' && empty($s['reaim']) && $lastFoe !== null) { $fcErr = (int)$fcAfter - ($hpMid - (int)$lastFoe['hpnow']); $F['fcn']++; $F['fcerr'] += abs($fcErr); }
        $flags = $co ? implode(' ', array_filter([$co['used'] ? 'USES-UP' : '', $co['tw'] > 1 ? 'TEAM x' . $co['tw'] : '', $co['sun'] ? 'SUN' : '', $co['miss'] !== '' ? 'MISS' : '', $co['end'] !== '' ? 'END(' . $co['end'] . ')' : '', $co['die_after'] ? 'DIE-AFTER' : '', $co['pal'] !== '' ? 'PAL' : ''])) : '';
        if ($full) pc_csv($out['turns'], [$fid, $t, $bot, $prof, $c['slug'], $d, $hp0, (int)$s['me']['hp'], $max, round($fh0, 1), round($s['fh']['now'], 1), round($b0, 1), round($s['bar']['now'], 1), $s['fh']['max'], $pre['g'], $pre['fg'], $pre['draw'], $pre['disc'], $pre['board'], $pre['env'], $pre['haz'],
            $pre['hand'], count($opts), pc_act_s(['me' => ['hand' => $s0hand]], $a), is_int($a[0]) ? ($s0hand[$a[0]]['n'] ?? '') : $a[0], $a[0] === 'pass' ? '' : $a[1] . ',' . $a[2], (int)!empty($a[3]),
            $co['d'] ?? '', $co['c'] ?? '', $co['h'] ?? '', $co['n'] ?? '', $flags, $pre['aim'], $pre['aimp'], $fcBefore, $fcAfter,
            $myLen, $myN, $usedN, round($myD, 1), round($myC, 1), $myH, $co ? round($myD - $co['d'], 1) : '', $co ? round($myC - $co['c'], 1) : '', $co ? $myH - $co['h'] : '',
            $X['pc'], $X['dd'], $X['blk'], $X['miss'], $X['dodge'], $X['q'], $X['sl'], $X['gr'], $X['rip'], $X['pme'], $X['pit'], $X['fm'], round($X['bait'], 1), $X['env'],
            $hp0 - (int)$s['me']['hp'], $fcErr, (int)!empty($s['reaim']), (string)$s['over'], (int)$s['me']['block'], (int)($s['foe']['block'] ?? 0), $lastFoe !== null ? $hpMid - (int)$lastFoe['hpnow'] : '']);
    }
    // the fight row
    $src = $pm['src']; $bySrc = []; $byType = []; foreach ($pm['ent'] as $e) { $bySrc[$e['src']] = ($bySrc[$e['src']] ?? 0) + 1; $byType[$e['t']] = ($byType[$e['t']] ?? 0) + 1; }
    $kv = fn(array $a) => implode(' ', array_map(fn($k, $v) => "$k:" . (is_array($v) ? json_encode($v) : $v), array_keys($a), $a));
    $tune = pfb_v1_tune($c['slug']); $kind = pfb_kind($s); $win = in_array($s['over'], ['seen_off', 'charmed'], true) ? 1 : 0; $cap = (int)($s['over'] === 'stall' || !$s['over']);
    $ab = implode(',', (array)($cr['ab'] ?? [])) . (($cr['abp'] ?? []) ? ' ' . json_encode($cr['abp']) : '');
    pc_csv($out['fights'], [$meta0['run'], $meta0['ver'], $meta0['sha'], $fid, $ctrl ? $ctrl[0] . sprintf('%+d', $ctrl[1]) : '', $c['slug'], $cr['family'] ?? $c['slug'], $c['size'], $c['level'], $region, $kind, PFB_KIND_TEXT[$kind][0] ?? '', (string)($cr['ai'] ?? ''), $ab,
        $tune['foe_x'] ?? 1.0, $tune['bar_x'] ?? 1.0, $s['fh']['max'], $s['cm'], $s['hm'],
        $lv, $d, $prof, $pm['spent'], $pm['raw']['grit'], $pm['raw']['nimble'], $pm['raw']['hardiness'], $pm['raw']['charm'], $pm['raw']['lore'], $pm['raw']['luck'], $pm['raw']['sense'],
        $pm['mods']['grit'], $pm['mods']['nimble'], $pm['mods']['hardiness'], $pm['mods']['charm'], $pm['mods']['lore'], $pm['mods']['luck'], $pm['max'],
        count($pl['deck']), $kv($bySrc), $kv($byType), $kv($src['tools']), implode(',', array_map(fn($p) => $p['n'] . ' ' . $p['t'] . ' ' . $p['v'], $src['pals'])), $kv($src['crops']), $kv($src['crafts']), $src['calling'], $src['ctier'], $build, $bot, $seed,
        (string)$s['over'], $win, $cap ? 'turn_cap' : ($s['over'] === 'defeat' ? 'out_of_health' : ($s['over'] === 'charmed' ? 'charm_bar' : ($s['over'] === 'seen_off' ? 'damage_bar' : (string)$s['over']))),
        (int)$s['turn'], $pm['max'] - max(0, (int)$s['me']['hp']), max(0, (int)$s['me']['hp']), round(1 - max(0, (int)$s['me']['hp']) / max(1, $pm['max']), 3),
        round($s['fh']['now'], 1), round($s['bar']['now'], 1), round(($s['fh']['now'] + $s['bar']['now']) / max(1, $s['fh']['max']), 3),
        $F['passes'], $F['refused'], $F['flips'], $F['longest'], $F['chains'], $kv($F['combos']), $F['tw'], $F['envmine'], $cap,
        $F['fcn'], $F['fcn'] ? round($F['fcerr'] / $F['fcn'], 2) : '', $full && $F['regn'] ? round($F['reg'] / $F['regn'], 4) : '', $full ? $F['dead'] : '', round(microtime(true) - $t0, 2),
        count($CT), array_sum(array_map(fn($c) => $c['placed'], $CC)), array_sum(array_map(fn($c) => $c['fired'], $CC)), array_sum(array_map(fn($c) => $c['dmg'], $CC)), array_sum(array_map(fn($c) => $c['blocked'], $CC))]);
    if ($wantPieces && isset($out['creature_pieces'])) foreach ($CT as $u => $tl) { $k = $CC[$u]; $q = $k; unset($q['turns']);
        pc_csv($out['creature_pieces'], [$fid, $c['slug'], $c['size'], $c['level'], $kind, $bot, $prof, $d, $u, $tl['k'], $tl['n'], $tl['t'], (string)($tl['tag'] ?? ''), (string)($tl['m'] ?? ''), (int)($cr['deck'][$u]['v'] ?? 0), (int)$tl['v'], pc_e($tl),
            $k['drawn'], $k['placed'], implode(' ', $k['turns']), $k['fired'], $k['fired_own'], $k['fired_mine'], $k['fired_val'], $k['dmg'], $k['blocked'], $k['evaded'], $k['evaded_dmg'], $k['guard_gain'], round($k['healed'], 1), $k['riposte'], $k['quick'], $k['poisoned'], $k['tripped'], $k['grudge_fires'], $k['swarm_fires'], $k['swarm_bonus'], $k['ambush'], $k['bait_dmg'], $k['struck'], $k['struck_broke'], $k['used_up'], $k['used_by_me'], $k['fell'], $k['expired'], $win, (int)$s['turn']]); }
    if ($wantPieces) foreach ($pl['deck'] as $i => $tl) {
        $e = $pm['ent'][$i]; $st = PF_STAT[$tl['t']] ?? ''; $sc = max(0, (int)($pm['mods'][$st] ?? 0)); $lc = intdiv(max(1, $lv), 3);
        pc_csv($out['pieces'], [$fid, $i, $e['k'], $tl['n'], $tl['t'], (int)$e['v'], $st, $sc, $lc, (int)$tl['v'] - (int)$e['v'] - $sc - $lc, (int)$tl['v'], $e['src'], (int)$e['rank'], $tl['tag'] . (($tl['m'] ?? '') ? '+' . $tl['m'] : ''), pc_e(pfb_v1_tile($tl, $s['v1'])),
            $P[$i]['drawn'], $P[$i]['played'], $P[$i]['fired'], $P[$i]['flipped'], $P[$i]['expired'], $P[$i]['used_up'], $P[$i]['fell'], round($P[$i]['dmg'], 1), round($P[$i]['charm'], 1), $P[$i]['hp']]);
    }
}

function pc_fid(string $slug, int $lv, string $bot, string $prof, int $seed, ?array $ctrl, string $build = 'std', int $d = 0): string
{
    return substr(md5(json_encode([$slug, $lv, $bot, $prof, $seed, $ctrl, $build, $d])), 0, 10);
}

/** The FULL grid (GRID=full): [slug, bot, profile, offset, seed index, ctrl, build]; every creature appears in every block's axes (Balanced and Grit at offsets 0 and -4 in every bot and build). */
function pc_jobs_full(array $slugs, int $seeds): array
{
    $P8 = array_keys(PC_PROFILES); $BG = ['Balanced', 'Grit']; $J = []; $i = 0;
    $blocks = [   // [bots, profiles, offsets, builds]
        [['chain', 'look', 'newbie', 'charm'], $P8, [0, -4], ['std']],
        [['random', 'greedy', 'defensive'], $BG, [0, -4], ['std']],
        [['look'], $BG, [0, -4], ['pals', 'norare']],
        [['chain', 'newbie', 'charm'], $P8, [0, -4], ['pals', 'norare']],
        [['chain', 'look'], $P8, [-8, 4], ['std']],
        [['newbie', 'charm'], $P8, [-8, 4], ['std']],
    ];
    foreach ($slugs as $sl) {
        foreach ($blocks as [$bots, $profs, $offs, $builds]) foreach ($builds as $bd) foreach ($bots as $b) foreach ($profs as $p) foreach ($offs as $d) for ($k = 0; $k < $seeds; $k++) $J[] = [$sl, $b, $p, $d, $k, null, $bd];
        if ($i++ % 5 === 0) foreach (['chain', 'look'] as $b) for ($k = 0; $k < $seeds; $k++) foreach (PC_FIGHT6 as $st) foreach ([2, -2] as $dv) $J[] = [$sl, $b, 'Balanced', 0, $k, [$st, $dv], 'std'];
    }
    return $J;
}

/** GRID=cp (creature pieces): every creature x bots chain and look x profiles Balanced and Grit x offsets 0 and -4 x seeds, build std. LEAN (chosen option priced only), the fights, pieces and creature_pieces tables only. */
function pc_jobs_cp(array $slugs, int $seeds): array
{
    $J = []; foreach ($slugs as $sl) foreach (['chain', 'look'] as $b) foreach (['Balanced', 'Grit'] as $p) foreach ([0, -4] as $d) for ($k = 0; $k < $seeds; $k++) $J[] = [$sl, $b, $p, $d, $k, null, 'std'];
    return $J;
}

/** The job list: [slug, bot, profile, offset, seed index, ctrl]. */
function pc_jobs(array $slugs, int $seeds): array
{
    $J = [];
    foreach ($slugs as $sl) foreach (PC_BOTS as $b) for ($k = 0; $k < $seeds; $k++) {
        foreach (PC_OFFSETS as $d) foreach (array_keys(PC_PROFILES) as $p) $J[] = [$sl, $b, $p, $d, $k, null];
        foreach (PC_FIGHT6 as $st) foreach ([2, -2] as $dv) $J[] = [$sl, $b, 'Balanced', 0, $k, [$st, $dv]];
    }
    return $J;
}

if (PHP_SAPI !== 'cli' || realpath($argv[0]) !== __FILE__) return;
if (($argv[1] ?? '') === 'profiles') {
    $f = fopen(($argv[2] ?? '.') . '/profiles.csv', 'w');
    pc_csv($f, ['profile', 'level', 'stat_points', 'stat_points_spent', 'grit', 'nimble', 'hardiness', 'charm', 'lore', 'luck', 'sense', 'mod_grit', 'mod_nimble', 'mod_hardiness', 'mod_charm', 'mod_lore', 'mod_luck', 'max_hp', 'hurt_bonus_lv3', 'belt_slots', 'tool_tiers', 'pals', 'crops', 'crafts', 'regions', 'calling_tier', 'knacks_on', 'deck_size']);
    foreach (array_keys(PC_PROFILES) as $p) for ($lv = 1; $lv <= 40; $lv++) {
        [$raw, $sp] = pc_alloc($lv, $p); $m = pc_mods($raw, $lv); $src = tv_sources($lv); $kv = fn(array $a) => implode(' ', array_map(fn($k, $v) => "$k:$v", array_keys($a), $a));
        pc_csv($f, [$p, $lv, $lv + 3, $sp, $raw['grit'], $raw['nimble'], $raw['hardiness'], $raw['charm'], $raw['lore'], $raw['luck'], $raw['sense'], $m['grit'], $m['nimble'], $m['hardiness'], $m['charm'], $m['lore'], $m['luck'], max(10, 20 + 3 * $lv + 5 * $m['hardiness']), intdiv($lv, 3),
            $src['slots'], $kv($src['tools']), implode(',', array_map(fn($q) => $q['n'], $src['pals'])), $kv($src['crops']), $kv($src['crafts']), $kv($src['regions']), $src['ctier'], implode(',', array_keys(array_filter($src['state']))), count(pfd_fight_entries($src))]);
    }
    exit;
}
$dir = $argv[1] ?? '.'; [$shard, $nsh] = array_map('intval', explode('/', $argv[2] ?? '0/1')); $slugs = isset($argv[3]) && $argv[3] !== 'all' ? explode(',', $argv[3]) : PC_SLUGS; $seeds = (int)($argv[4] ?? 3);
$lim = (int)(getenv('LIMIT') ?: 0);
$all = pt_load_creatures(); $out = [];
foreach ($PC_H as $tb => $h) { $out[$tb] = fopen("$dir/$tb.$shard.csv", 'w'); if ($shard === 0) pc_csv($out[$tb], $h); }
$meta0 = ['run' => getenv('RUN_ID') ?: 'pfc-' . date('Ymd'), 'ver' => '2.7.48', 'sha' => trim((string)shell_exec('git -C ' . escapeshellarg(__DIR__) . ' rev-parse --short HEAD'))];
if (preg_match("/define\('APP_VERSION', '([^']+)'/", (string)@file_get_contents(__DIR__ . '/../game/includes/bootstrap.php'), $mm)) $meta0['ver'] = $mm[1];
$n = 0;
$fullGrid = getenv('GRID') === 'full'; $only = ($f = getenv('ONLY')) ? array_flip(array_filter(array_map('trim', file($f)))) : null;
$cpGrid = getenv('GRID') === 'cp';
if ($slugs === PC_SLUGS && ($fullGrid || $cpGrid)) $slugs = array_keys($all);
foreach (($cpGrid ? pc_jobs_cp($slugs, $seeds) : ($fullGrid ? pc_jobs_full($slugs, $seeds) : pc_jobs($slugs, $seeds))) as $ji => $job) {
    [$sl, $b, $p, $d, $k, $ctrl] = $job; $bd = $job[6] ?? 'std';
    if ($ji % $nsh !== $shard) continue; if ($lim && $n >= $lim) break;
    $c = $all[$sl]; $lv = max(1, $c['level'] + $d); $seed = 500 + 13 * $k + $c['level'] + 1000 * (crc32($sl) % 97);
    $fid = pc_fid($sl, $lv, $b, $p, $seed, $ctrl, $bd, $d);
    if ($only !== null && !isset($only[$fid])) continue;
    $n++;
    // lean: only the chosen option priced; pieces kept for chain, seed 0, offset 0 (+ every full-pass fight)
    pc_fight($c, $lv, $b, $p, $seed, $d, $ctrl, $out, $meta0, $bd, $only !== null || (!$fullGrid && !$cpGrid), $cpGrid || $only !== null || !$fullGrid || ($b === 'chain' && $k === 0 && $d === 0 && !$ctrl), $fid);
}
fwrite(STDERR, "shard $shard: $n fights\n");
