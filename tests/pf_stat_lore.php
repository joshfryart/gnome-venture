<?php
// Stat pieces, LORE slice: Old Saying (tier 0), Knot of Twine (10), Lantern Chain (15), Weather Lore (20), Copybook (25), Turn of the Tale (30).
// New engine parts: the edge kind 'any' (pfb_joint: fits and links any knob or hole of any family, fits but never links a flat side or a Mud; Knot of Twine's
// four sides, authored on the tile, and it is never a combo partner), 'boostall:N' (your other pieces in the chain not yet fired get +N, at most +a per piece a chain),
// 'weather' (the environment's next piece becomes a Sun, a Spring on large boards, and comes in on a free cell beside it; once a round; the field cap still applies),
// 'teach' (the piece it links to learns the tag of another piece of yours in its chain, for the fight; one taught tag a piece, never over a tag, at most b a fight),
// 'retell' (the creature piece it links to, its strongest, becomes yours where it stands, keeps the creature's fire budget and goes back to the creature's discard; once a fight, bosses too).
// Every fight is seeded and the board is laid out by hand. php tests/pf_stat_lore.php
$GLOBALS['TEST_SETTINGS'] = [];
if (!function_exists('setting')) { function setting(string $k): string { return (string)($GLOBALS['TEST_SETTINGS'][$k] ?? ''); } }
require __DIR__ . '/../game/includes/pfdeck.php';
$bad = 0; $n = 0;
function chk(string $name, bool $ok, $got = ''): void { global $bad, $n; $n++; if (!$ok) { $bad++; echo 'FAIL ' . $name . ' (got ' . (is_string($got) ? $got : json_encode($got)) . ")\n"; } }

const WILD = ['L' => ['wild', null], 'R' => ['wild', null], 'T' => ['wild', null], 'B' => ['wild', null]];
const FLAT = ['L' => ['flat', null], 'R' => ['flat', null], 'T' => ['flat', null], 'B' => ['flat', null]];
const ANY = ['L' => ['any', null], 'R' => ['any', null], 'T' => ['any', null], 'B' => ['any', null]];
/** A Lore stat piece tile as a packed deck gives it (fx S:KEY when live); wild edges unless given. */
function loreTile(string $key, int $a = 3, int $b = 2, ?array $ed = WILD): array
{
    $p = pfd_stat_pieces()[$key];
    $t = pf_make_tile($key, ['level' => 10], 0, ['n' => $p['n'], 't' => $p['t'], 'v' => $p['v'], 'r' => $p['r'], 'tag' => $p['tag'], 'src' => 'stat', 'st' => 'lore']) + ['fxa' => $a, 'fxb' => $b, 'ed' => $ed];
    if ($p['live'] && $p['fx'] !== '') $t['fx'] = 'S:' . $key;
    return $t;
}
function plain(string $k, int $v = 5, array $ed = WILD, string $tag = ''): array { $t = pf_make_tile($k, ['level' => 10]); $t['v'] = $v; $t['ed'] = $ed; $t['src'] = 'basic'; $t['tag'] = $tag; return $t; }
function foeT(string $k, string $t, int $v, array $ed = WILD): array { return ['k' => $k, 'n' => ucfirst(substr($k, 2)), 't' => $t, 'v' => $v, 'r' => 'body', 'tag' => '', 'ed' => $ed]; }
function envT(string $kind, array $ed = WILD): array { return ['k' => 'e:' . $kind, 'n' => ucfirst($kind), 't' => 'env', 'v' => 0, 'r' => null, 'tag' => '', 'm' => '', 'src' => 'env', 'env' => $kind, 'life' => 3, 'ed' => $ed]; }
/** A v1 fight (4x4 medium, 5x5 large / boss), the board emptied, no use-up of 3-chains, the creature's hand set; $extra = Lore pieces in your deck (so the fight carries the effect state). */
function loreFight(int $seed, array $extra, string $size = 'medium', ?array $hand = null): array
{
    $deck = []; foreach (range(1, 10) as $i) $deck[] = plain(['swing', 'dodge', 'rest', 'charm'][$i % 4], 4 + $i % 3);
    foreach ($extra as $k) $deck[] = loreTile($k);
    $foe = ['slug' => 'tst', 'name' => 'Test', 'size' => $size, 'level' => 10, 'dmg_die' => 6, 'dmg_bonus' => 1];
    $s = pfb_new(['hp' => 60, 'max_hp' => 60, 'deck' => $deck, 'luck' => 2, 'lpts' => 10], $foe, $seed, ['v1' => true]);
    $s['pcs'] = []; $s['cell'] = []; $s['ter'] = []; $s['envs'] = []; $s['foe']['slow'] = 0; $s['v1']['limit'] = 0;
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
function aimAt(array &$s, int $x, int $y, int $hi = 0): void { $h = $s['foe']['hand'][$hi]; $s['foe']['plan'] = ['k' => $h['k'], 'n' => $h['n'], 't' => $h['t'], 'v' => $h['v'], 'tag' => $h['tag'], 'x' => $x, 'y' => $y]; }
function playAt(array &$s, array $tile, int $x, int $y): ?array { array_unshift($s['me']['hand'], $tile); return pfb_place($s, 'me', 0, $x, $y); }
/** The firing event of a board piece in a list of events (the first one). */
function evOf(?array $ev, int $id): ?array { foreach ($ev ?? [] as $e) if (($e['id'] ?? null) === $id && isset($e['barnow'])) return $e; return null; }
function wfxHas(?array $ev, string $a): bool { foreach ($ev ?? [] as $e) foreach ($e['wfx'] ?? [] as $w) if (explode(' ', $w)[0] === $a) return true; return false; }
function touches(array $c, int $x, int $y): bool { return abs($c[0] - $x) + abs($c[1] - $y) === 1; }
function envAt(array $s, string $kind): ?array { foreach ($s['pcs'] as $p) if ($p['by'] === 'env' && $p['tile']['env'] === $kind) return [$p['x'], $p['y']]; return null; }

// ---------------------------------------------------------------- data: the six Lore pieces are live
$S = pfd_stat_pieces();
foreach (['stat-old-saying', 'stat-knot-of-twine', 'stat-lantern-chain', 'stat-weather-lore', 'stat-copybook', 'stat-turn-of-the-tale'] as $k)
    chk("data_{$k}_is_live_with_clauses", $S[$k]['live'] && pfb_wx_clauses('S:' . $k) !== [], [$S[$k]['live'], $S[$k]['fx']]);
$ke = pfd_stat_entry($S['stat-knot-of-twine'], 20);
chk('data_knot_entry_authors_four_any_edges', ($ke['edges'] ?? null) === ANY, $ke['edges'] ?? null);
chk('data_knot_deck_view_shows_any_edges', pfd_edges($ke) === ANY, pfd_edges($ke));
$kt = pfd_tiles([$ke + ['key' => 'stat-knot-of-twine', 'rank' => 0, 'tool' => '']], ['level' => 10, 'lore' => 20]);
chk('data_knot_tile_carries_edges_to_the_board', pfb_v1_tile($kt[0], pfb_v1_cfg('medium'))['ed'] === ANY, $kt[0]['edges'] ?? null);
$oe = pfd_stat_entry($S['stat-old-saying'], 20);
chk('data_other_lore_pieces_keep_authored_edges', !isset($oe['edges']));

// ---------------------------------------------------------------- the 'any' edge: links any knob or hole of any family; flat and Mud still do not link
chk('any_edge_links_a_knob_of_any_family', pfb_joint(['any', null], ['knob', 'body']) === [true, true] && pfb_joint(['knob', 'craft'], ['any', null]) === [true, true]);
chk('any_edge_links_a_hole_of_any_family', pfb_joint(['any', null], ['hole', 'mind']) === [true, true]);
chk('any_edge_fits_a_flat_side_without_linking', pfb_joint(['any', null], ['flat', null]) === [true, false] && pfb_joint(['flat', null], ['any', null]) === [true, false]);
chk('any_edge_with_wild_or_any_links', pfb_joint(['any', null], ['wild', null]) === [true, true] && pfb_joint(['any', null], ['any', null]) === [true, true]);
chk('any_edge_control_family_mismatch_still_does_not_fit', pfb_joint(['knob', 'body'], ['hole', 'mind']) === [false, false]);

// ---------------------------------------------------------------- Knot of Twine: one hub across families; the piece it links to +b; never a combo partner
$KB = ['L' => ['flat', null], 'R' => ['knob', 'body'], 'T' => ['flat', null], 'B' => ['flat', null]];
$HM = ['L' => ['hole', 'mind'], 'R' => ['flat', null], 'T' => ['flat', null], 'B' => ['flat', null]];
$s = loreFight(11, ['stat-knot-of-twine']);
$sw = put($s, 'me', plain('swing', 5, $KB), 1, 1); $fg = put($s, 'foe', foeT('f:shell', 'guard', 2, $HM), 3, 1);
$md = put($s, 'env', envT('mud', FLAT), 2, 2); $fl = put($s, 'me', plain('dodge', 3, FLAT), 2, 0);
chk('knot_control_a_craft_trick_does_not_fit_there', pfb_check($s, plain('charm', 3, ['L' => ['hole', 'craft'], 'R' => ['knob', 'craft'], 'T' => ['flat', null], 'B' => ['flat', null]]), 2, 1) === null);
$w = $s; $ev = playAt($w, loreTile('stat-knot-of-twine', 3, 2, ANY), 2, 1); $kid = $w['pid'];
$ln = pfb_links($w, $kid);
chk('knot_links_a_body_knob_and_a_mind_hole', in_array($sw, $ln, true) && in_array($fg, $ln, true), $ln);
chk('knot_does_not_link_flat_side_or_mud', !in_array($md, $ln, true) && !in_array($fl, $ln, true), $ln);
chk('knot_chain_fires_both_families', evOf($ev, $sw) !== null && evOf($ev, $fg) !== null);
chk('knot_boosts_its_linked_piece_by_b (5 + 2)', (int)(evOf($ev, $sw)['v'] ?? 0) === 7, evOf($ev, $sw));
$ke2 = evOf($ev, $sw); chk('knot_is_never_a_combo_partner (no Ambush)', $ke2 !== null && array_key_exists('combo', $ke2) && $ke2['combo'] === null, $ke2);
$w = $s; $w['pcs'][$sw]['tile']['ed'] = WILD; $ev = playAt($w, loreTile('stat-old-saying', 3, 2), 2, 1);
chk('knot_control_another_trick_gives_ambush', (evOf($ev, $sw)['combo'] ?? null) === 'Ambush', evOf($ev, $sw)['combo'] ?? null);

// ---------------------------------------------------------------- Old Saying: +a to your linked piece that fires next, +b more with an environment piece in the chain
$s = loreFight(12, ['stat-old-saying']); $r = put($s, 'me', plain('rest', 4), 1, 1);
$w = $s; $ev = playAt($w, loreTile('stat-old-saying', 3, 2), 2, 1);
chk('old_saying_gives_a_to_linked_piece (4 + 3)', (int)(evOf($ev, $r)['v'] ?? 0) === 7, evOf($ev, $r));
$w = $s; put($w, 'env', envT('rain'), 1, 2); $ev = playAt($w, loreTile('stat-old-saying', 3, 2), 2, 1);
chk('old_saying_env_in_chain_gives_b_more (4 + 3 + 2)', (int)(evOf($ev, $r)['v'] ?? 0) === 9, evOf($ev, $r));

// ---------------------------------------------------------------- Lantern Chain: your other pieces in its chain not yet fired +b, +a in a chain of 4+, at most +a a piece a chain
$s = loreFight(13, ['stat-lantern-chain']); $ra = put($s, 'me', plain('rest', 4), 1, 1); $rb = put($s, 'me', plain('rest', 4), 3, 1); $dg = put($s, 'me', plain('dodge', 3), 2, 0);
$w = $s; unset($w['pcs'][$dg], $w['cell']['2,0']); $ev = playAt($w, loreTile('stat-lantern-chain', 3, 2), 2, 1); $lid = $w['pid'];
chk('lantern_chain_of_3_gives_b_to_each_other_piece', (int)(evOf($ev, $ra)['v'] ?? 0) === 6 && (int)(evOf($ev, $rb)['v'] ?? 0) === 6, [evOf($ev, $ra)['v'] ?? null, evOf($ev, $rb)['v'] ?? null]);
chk('lantern_does_not_boost_itself', !isset($w['pcs'][$lid]['wv']));
$w = $s; $fh = put($w, 'foe', foeT('f:bite', 'hurt', 3), 2, 2); $ev = playAt($w, loreTile('stat-lantern-chain', 3, 2), 2, 1);
chk('lantern_chain_of_4_plus_gives_a (4 + 3)', (int)(evOf($ev, $ra)['v'] ?? 0) === 7 && (int)(evOf($ev, $rb)['v'] ?? 0) === 7, [evOf($ev, $ra)['v'] ?? null, evOf($ev, $rb)['v'] ?? null]);
chk('lantern_skips_your_piece_that_already_fired (guard before trick)', !isset($w['pcs'][$dg]['wv']), $w['pcs'][$dg]['wv'] ?? null);
chk('lantern_never_boosts_creature_pieces', !isset($w['pcs'][$fh]['wv']));
$w = $s; unset($w['pcs'][$dg], $w['cell']['2,0']); unset($w['pcs'][$ra], $w['cell']['1,1']); put($w, 'me', loreTile('stat-lantern-chain', 3, 2), 1, 1);
$ev = playAt($w, loreTile('stat-lantern-chain', 3, 2), 2, 1);
chk('lantern_two_in_a_chain_cap_at_a_per_piece (2 + 2 capped to 3)', (int)($w['pcs'][$rb]['wv'] ?? 0) === 3 && (int)(evOf($ev, $rb)['v'] ?? 0) === 7, [$w['pcs'][$rb]['wv'] ?? null]);

// ---------------------------------------------------------------- Weather Lore: the environment's next piece becomes a Sun (Spring on large), landing beside it; once a round; the field cap holds
$s = loreFight(14, ['stat-weather-lore']); put($s, 'me', plain('rest', 3), 0, 1);
$s['env']['next'] = [envT('bramble', ['L' => ['hole', 'body'], 'R' => ['knob', 'mind'], 'T' => ['knob', 'craft'], 'B' => ['hole', 'craft']]), envT('rain')]; $d0 = count($s['env']['draw']);
$w = $s; $ev = playAt($w, loreTile('stat-weather-lore', 3, 2), 1, 1);
chk('weather_lore_next_env_piece_becomes_sun', ($w['env']['next'][0]['env'] ?? '') === 'sun' && ($w['env']['next'][1]['env'] ?? '') === 'rain', array_column($w['env']['next'], 'env'));
chk('weather_lore_old_piece_goes_back_on_top_of_env_draw', count($w['env']['draw']) === $d0 + 1 && end($w['env']['draw'])['env'] === 'bramble');
$w2 = $w; pfb_env_place($w2); $sun = envAt($w2, 'sun');
chk('weather_lore_sun_lands_beside_it (L R T B, most links: 2,1)', $sun === [2, 1], $sun);
$c = $s; $c['env']['next'][0] = $w['env']['next'][0]; unset($c['env']['next'][0]['wpref']); put($c, 'me', plain('charm', 3), 1, 1); pfb_env_place($c); $csun = envAt($c, 'sun');
chk('weather_lore_control_without_it_sun_goes_far_away', $csun !== null && !touches($csun, 1, 1), $csun);
$w2 = $w; $ev2 = playAt($w2, loreTile('stat-weather-lore', 3, 2), 1, 2);
chk('weather_lore_once_a_round', !wfxHas($ev2, 'weather') && wfxHas($ev, 'weather') && count($w2['env']['draw']) === $d0 + 1);
$w2 = $w; $w2['v1']['envmax'] = 1; put($w2, 'env', envT('rain'), 3, 3); pfb_env_place($w2);
chk('weather_lore_field_cap_makes_the_sun_wait', envAt($w2, 'sun') === null && ($w2['env']['next'][0]['env'] ?? '') === 'sun');
$q = loreFight(15, ['stat-weather-lore'], 'large'); put($q, 'me', plain('rest', 3), 1, 2); $ev = playAt($q, loreTile('stat-weather-lore', 3, 2), 2, 2);
chk('weather_lore_large_board_calls_a_spring', ($q['env']['next'][0]['env'] ?? '') === 'spring', array_column($q['env']['next'], 'env'));

// ---------------------------------------------------------------- Copybook: the piece it links to learns another of your chain pieces' tag, for the fight; rails
$s = loreFight(16, ['stat-copybook']); $pz = put($s, 'me', plain('swing', 4, WILD, 'pierce'), 1, 1); $pl = put($s, 'me', plain('swing', 4), 3, 1);
$w = $s; $ev = playAt($w, loreTile('stat-copybook', 3, 1), 2, 1);
chk('copybook_linked_piece_learns_the_tag', $w['pcs'][$pl]['tile']['tag'] === 'pierce' && !empty($w['pcs'][$pl]['tile']['tt']), $w['pcs'][$pl]['tile']['tag']);
chk('copybook_taught_tag_works_in_this_chain', (evOf($ev, $pl)['tag'] ?? '') === 'pierce', evOf($ev, $pl)['tag'] ?? null);
chk('copybook_source_keeps_its_own_tag', $w['pcs'][$pz]['tile']['tag'] === 'pierce');
$w2 = $w; pfb_discard($w2, $w2['pcs'][$pl]);
chk('copybook_tag_stays_on_the_piece_in_the_discard', end($w2['me']['discard'])['tag'] === 'pierce');
$w2 = $w; put($w2, 'me', plain('swing', 4), 2, 2); $ev2 = playAt($w2, loreTile('stat-copybook', 3, 1), 3, 2);
chk('copybook_at_most_b_pieces_a_fight (b = 1)', $w2['pcs'][$w2['cell']['2,2']]['tile']['tag'] === '' && (int)$w2['me']['wcb'] === 1);
$w2 = $s; $w2['pcs'][$pl]['tile']['tag'] = 'poison'; $ev2 = playAt($w2, loreTile('stat-copybook', 3, 1), 2, 1);
chk('copybook_never_replaces_a_tag', $w2['pcs'][$pl]['tile']['tag'] === 'poison' && $w2['pcs'][$pz]['tile']['tag'] === 'pierce' && !wfxHas($ev2, 'teach'));
$w2 = $s; $w2['pcs'][$pz]['tile']['tag'] = ''; $ev2 = playAt($w2, loreTile('stat-copybook', 3, 1), 2, 1);
chk('copybook_no_tagged_piece_in_chain_teaches_nothing', $w2['pcs'][$pl]['tile']['tag'] === '' && !wfxHas($ev2, 'teach'));

// ---------------------------------------------------------------- Turn of the Tale: its linked creature piece (the strongest) becomes yours; once a fight; bosses too; budget and discard stay the creature's
$s = loreFight(17, ['stat-turn-of-the-tale'], 'medium', [foeT('f:bite', 'hurt', 5), foeT('f:nip', 'hurt', 3)]);
put($s, 'me', plain('rest', 3), 1, 1); $fh = put($s, 'foe', foeT('f:claw', 'hurt', 6), 3, 1); $fg = put($s, 'foe', foeT('f:shell', 'guard', 2), 2, 0);
$c = $s; $evc = playAt($c, loreTile('stat-old-saying', 3, 2), 2, 1);
chk('tale_control_creature_hurt_fires_for_it', (evOf($evc, $fh)['by'] ?? '') === 'foe' && (int)$c['me']['hp'] < 60);
$w = $s; aimAt($w, 1, 2); $ev = playAt($w, loreTile('stat-turn-of-the-tale', 3, 2), 2, 1);
chk('tale_strongest_linked_creature_piece_becomes_yours', $w['pcs'][$fh]['by'] === 'me' && !empty($w['pcs'][$fh]['ws']) && $w['pcs'][$fh]['x'] === 3, $w['pcs'][$fh]);
chk('tale_weaker_one_stays_the_creatures', $w['pcs'][$fg]['by'] === 'foe');
chk('tale_stolen_piece_fires_for_you_in_this_chain', (evOf($ev, $fh)['by'] ?? '') === 'me' && (int)$w['me']['hp'] === 60, [evOf($ev, $fh)['by'] ?? null, $w['me']['hp']]);
chk('tale_keeps_number_and_edges', (int)$w['pcs'][$fh]['tile']['v'] === 6 && $w['pcs'][$fh]['tile']['ed'] === WILD);
chk('tale_aim_total_recomputed', isset($w['foe']['plan']['tot']) && $w['foe']['plan']['tot'] === pfb_aim_total($w));
chk('tale_creature_picks_ignore_it', pfb_wx_foe_pick($w, true) === $fg);
chk('tale_keeps_the_creature_fire_budget', pfb_fire_lim($w, $w['pcs'][$fh]) === pfb_fire_lim($w, ['by' => 'foe'] + $w['pcs'][$fh]) && pfb_fire_lim($w, $w['pcs'][$fh]) > 0);
$w2 = $w; $fd = count($w2['foe']['discard']); $md0 = count($w2['me']['discard']); $w2['pcs'][$fh]['f'] = 9; pfb_spend($w2);
chk('tale_spent_stolen_piece_goes_to_creature_discard', !isset($w2['pcs'][$fh]) && count($w2['foe']['discard']) === $fd + 1 && count($w2['me']['discard']) === $md0);
$w2 = $w; $f2 = put($w2, 'foe', foeT('f:fang', 'hurt', 7), 0, 2); $ev2 = playAt($w2, loreTile('stat-turn-of-the-tale', 3, 2), 0, 1);
chk('tale_once_a_fight', $w2['pcs'][$f2]['by'] === 'foe' && !wfxHas($ev2, 'retell'));
$q = loreFight(18, ['stat-turn-of-the-tale'], 'boss'); put($q, 'me', plain('rest', 3), 1, 1); $bh = put($q, 'foe', foeT('f:maw', 'hurt', 8), 3, 1);
playAt($q, loreTile('stat-turn-of-the-tale', 3, 2), 2, 1);
chk('tale_works_on_a_boss', $q['pcs'][$bh]['by'] === 'me');

echo $bad ? "$bad FAILED of $n\n" : "ok: $n Lore stat piece checks\n";
exit($bad ? 1 : 0);
