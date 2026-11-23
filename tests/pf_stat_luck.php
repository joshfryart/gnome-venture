<?php
// Stat pieces, LUCK slice: Loaded Die (tier 0), Hedge Rummage (10), Long Shot (15), Magpie's Pinch (20), Turn of the Coin (25), Lucky Streak (30).
// New engine parts: the refire action 'again' (a piece fires once more through pfb_fire, its links not run again), Pluck mode 'roll' (the Luck roll, halved on a boss),
// the creature's next-Hurt bonus 'fup', 'pinch' (a creature hand piece into your next hand, yours, rescaled), 'coin' (a creature hand piece back to its draw pile, re-plan),
// 'streak' (rolls until a miss, each hit refires a random piece of yours). Each fight is seeded; outcomes are read from the events (hit / miss) and checked both ways.
// php tests/pf_stat_luck.php
$GLOBALS['TEST_SETTINGS'] = [];
if (!function_exists('setting')) { function setting(string $k): string { return (string)($GLOBALS['TEST_SETTINGS'][$k] ?? ''); } }
require __DIR__ . '/../game/includes/pfdeck.php';
$bad = 0; $n = 0;
function chk(string $name, bool $ok, $got = ''): void { global $bad, $n; $n++; if (!$ok) { $bad++; echo 'FAIL ' . $name . ' (got ' . (is_string($got) ? $got : json_encode($got)) . ")\n"; } }

const WILD = ['L' => ['wild', null], 'R' => ['wild', null], 'T' => ['wild', null], 'B' => ['wild', null]];
/** A stat piece tile as a packed deck gives it (fx S:KEY when live), with wild edges so it links to whatever it touches. */
function luckTile(string $key, int $a = 3, int $b = 2): array
{
    $p = pfd_stat_pieces()[$key];
    $t = pf_make_tile($key, ['level' => 10], 0, ['n' => $p['n'], 't' => $p['t'], 'v' => $p['v'], 'r' => $p['r'], 'tag' => $p['tag'], 'src' => 'stat', 'st' => 'luck']) + ['fxa' => $a, 'fxb' => $b, 'ed' => WILD];
    if ($p['live'] && $p['fx'] !== '') $t['fx'] = 'S:' . $key;
    return $t;
}
/** A plain piece of yours (wild edges). */
function plain(string $k, int $v = 5): array { $t = pf_make_tile($k, ['level' => 10]); $t['v'] = $v; $t['ed'] = WILD; $t['src'] = 'basic'; return $t; }
/** A v1 fight against a medium (or boss) creature, Luck points $lp, an empty board (no terrain), Pluck allowed; $luck = the luck pieces in the deck. */
function luckFight(int $lp, int $seed, array $luck, string $size = 'medium'): array
{
    $deck = []; foreach (range(1, 10) as $i) $deck[] = plain(['swing', 'dodge', 'rest', 'charm'][$i % 4], 4 + $i % 3);
    foreach ($luck as $k) $deck[] = luckTile($k);
    $foe = ['slug' => 'tst', 'name' => 'Test', 'size' => $size, 'level' => 10, 'dmg_die' => 6, 'dmg_bonus' => 1];
    $s = pfb_new(['hp' => 60, 'max_hp' => 60, 'deck' => $deck, 'luck' => 2, 'lpts' => $lp], $foe, $seed, ['v1' => true, 'can_pluck' => true]);
    $s['pcs'] = []; $s['cell'] = []; $s['ter'] = []; $s['envs'] = [];
    return $s;
}
/** Put a tile on the board directly (no firing). Returns its id. */
function put(array &$s, string $who, array $tile, int $x, int $y): int
{
    $id = ++$s['pid']; $s['seq']++;
    $s['pcs'][$id] = ['id' => $id, 'by' => $who, 'tile' => $tile, 'x' => $x, 'y' => $y, 'born' => $s['round'], 'seq' => $s['seq']];
    $s['cell']["$x,$y"] = $id;
    return $id;
}
/** Place $tile from your hand at (x, y): it goes in as hand piece 0. Returns the events (null = illegal). */
function playAt(array &$s, array $tile, int $x, int $y): ?array { array_unshift($s['me']['hand'], $tile); return pfb_place($s, 'me', 0, $x, $y); }
/** The firing events of one board piece. */
function firings(array $ev, int $id): array { return array_values(array_filter($ev, fn($e) => isset($e['barnow']) && ($e['id'] ?? null) === $id)); }
/** The event of the piece placed now (the first one with a roll field, or the root). */
function rootEv(array $ev, int $id): ?array { foreach ($ev as $e) if (($e['id'] ?? null) === $id && empty($e['re'])) return $e; return null; }

// ---------------------------------------------------------------- data: the six Luck pieces are live
$S = pfd_stat_pieces();
foreach (['stat-loaded-die', 'stat-hedge-rummage', 'stat-long-shot', 'stat-magpie-s-pinch', 'stat-turn-of-the-coin', 'stat-lucky-streak'] as $k)
    chk("data_{$k}_is_live_with_clauses", $S[$k]['live'] && pfb_wx_clauses('S:' . $k) !== [], [$S[$k]['live'], $S[$k]['fx']]);
chk('data_other_stats_still_inert_here (Sidestep)', !$S['stat-sidestep']['live']);
chk('data_luck_tile_from_a_packed_deck_carries_fx', (pfd_stat_entry($S['stat-long-shot'], 20)['fx'] ?? '') === 'S:stat-long-shot');

// ---------------------------------------------------------------- Loaded Die: hit = the piece it links to fires twice, miss = once
$seenH = 0; $seenM = 0; $okH = true; $okM = true; $okLinks = true;
for ($seed = 1; $seed <= 40; $seed++) {
    $s = luckFight(10, $seed, ['stat-loaded-die']);
    $sw = put($s, 'me', plain('swing', 6), 2, 2);   // arrange: your Hurt in the middle
    $ev = playAt($s, luckTile('stat-loaded-die'), 3, 2);   // act: the Die next to it
    $die = $s['pid']; $r = rootEv($ev, $die); $f = firings($ev, $sw);
    if (($r['roll'] ?? '') === 'hit') { $seenH++; if (count($f) !== 2 || empty($f[1]['re']) || !empty($f[0]['re'])) $okH = false; }
    elseif (($r['roll'] ?? '') === 'miss') { $seenM++; if (count($f) !== 1) $okM = false; }
    if (count(firings($ev, $die)) !== 1) $okLinks = false;   // the refire does not run the chain again (the Die itself fires once)
}
chk('loaded_die_both_outcomes_seen', $seenH > 0 && $seenM > 0, [$seenH, $seenM]);
chk('loaded_die_hit_linked_piece_fires_twice (second firing marked re)', $okH);
chk('loaded_die_miss_linked_piece_fires_once', $okM);
chk('loaded_die_refire_does_not_rerun_links', $okLinks);
// a refire deals its damage again: the creature's health goes up by the second firing's value
$s = luckFight(20, 3, ['stat-loaded-die']); $sw = put($s, 'me', plain('swing', 6), 2, 2);
for ($seed = 1; $seed < 200; $seed++) { $w = $s; $w['rng'] = $seed; $fh0 = (float)$w['fh']['now']; $ev = playAt($w, luckTile('stat-loaded-die'), 3, 2); $f = firings($ev, $sw); if (count($f) === 2) break; }
chk('loaded_die_refire_hits_the_creature_again', count($f) === 2 && $f[1]['fhnow'] > $f[0]['fhnow'], array_map(fn($e) => $e['fhnow'], $f));

// ---------------------------------------------------------------- Long Shot: hit = it fires twice, miss = your next Hurt placed gets +a
$seenH = 0; $seenM = 0; $okH = true; $okM = true;
for ($seed = 1; $seed <= 40; $seed++) {
    $s = luckFight(10, $seed, ['stat-long-shot']);
    put($s, 'me', plain('rest', 3), 2, 2);
    $ev = playAt($s, luckTile('stat-long-shot', 4, 2), 3, 2); $ls = $s['pid']; $f = firings($ev, $ls);
    if (($f[0]['roll'] ?? '') === 'hit') { $seenH++; if (count($f) !== 2 || empty($f[1]['re']) || isset($f[1]['roll']) || $s['me']['wx']['nx'] !== []) $okH = false; }
    else { $seenM++; if (count($f) !== 1 || $s['me']['wx']['nx'] !== [['hurt', 1, 4, 0]]) $okM = false; }
}
chk('long_shot_both_outcomes_seen', $seenH > 0 && $seenM > 0, [$seenH, $seenM]);
chk('long_shot_hit_fires_itself_twice_refire_rolls_no_more', $okH);
chk('long_shot_miss_banks_plus_a_for_next_hurt', $okM);

// ---------------------------------------------------------------- Hedge Rummage: Pluck with the Luck roll; a miss gives the creature's next Hurt +b
$seenH = 0; $seenM = 0; $okH = true; $okM = true;
for ($seed = 1; $seed <= 40; $seed++) {
    $s = luckFight(10, $seed, ['stat-hedge-rummage']); put($s, 'me', plain('rest', 3), 2, 2);
    $ev = playAt($s, luckTile('stat-hedge-rummage', 3, 2), 3, 2); $r = rootEv($ev, $s['pid']);
    if (($r['roll'] ?? '') === 'hit') { $seenH++; if ($r['pluck'] !== 'got' || $s['plucked'] !== 1 || !empty($s['foe']['wup'])) $okH = false; }
    else { $seenM++; if (($r['pluck'] ?? '') !== 'missed' || $s['plucked'] || (int)($s['foe']['wup'] ?? 0) !== 2) $okM = false; }
}
chk('hedge_both_outcomes_seen', $seenH > 0 && $seenM > 0, [$seenH, $seenM]);
chk('hedge_hit_plucks', $okH);
chk('hedge_miss_no_pluck_creature_next_hurt_plus_b', $okM);
// the rate follows the Luck roll (90% at 20 points, not Pluck's 35% cap), halved against a boss
$rate = function (string $size) { $h = 0; for ($seed = 1; $seed <= 400; $seed++) { $s = luckFight(20, $seed, ['stat-hedge-rummage'], $size); put($s, 'me', plain('rest', 3), 2, 2); $ev = playAt($s, luckTile('stat-hedge-rummage'), 3, 2); if ((rootEv($ev, $s['pid'])['pluck'] ?? '') === 'got') $h++; } return $h; };
$rm = $rate('medium'); $rb = $rate('boss');
chk('hedge_pluck_rate_is_the_luck_roll (~90% at 20 points)', $rm > 330 && $rm < 390, $rm);
chk('hedge_pluck_rate_halved_on_boss (~45%)', $rb > 145 && $rb < 215, $rb);
// a second Rummage after a Pluck: no second item (once a fight), the roll still rules the +b
$s = luckFight(20, 7, ['stat-hedge-rummage']); $s['plucked'] = 1; put($s, 'me', plain('rest', 3), 2, 2);
$ev = playAt($s, luckTile('stat-hedge-rummage'), 3, 2); $r = rootEv($ev, $s['pid']);
chk('hedge_after_pluck_used_no_second_item', !isset($r['pluck']) && $s['plucked'] === 1, $r['pluck'] ?? null);
// the creature's next Hurt placed gets +b (a non-Hurt placed first keeps it waiting)
$s = luckFight(10, 2, ['stat-hedge-rummage']); $s['foe']['wup'] = 3; put($s, 'me', plain('rest', 3), 2, 2);
$s['foe']['hand'] = [['k' => 'f:g', 'n' => 'Shell', 't' => 'guard', 'v' => 4, 'r' => 'body', 'tag' => '', 'ed' => WILD], ['k' => 'f:h', 'n' => 'Bite', 't' => 'hurt', 'v' => 5, 'r' => 'body', 'tag' => '', 'ed' => WILD]];
put($s, 'me', plain('rest', 3), 0, 0); pfb_place($s, 'foe', 0, 1, 0); $g = $s['pid'];   // (chains of 2: nothing is used up)
chk('fup_waits_for_a_hurt (guard placed: no bonus)', !isset($s['pcs'][$g]['wv']) && (int)$s['foe']['wup'] === 3);
pfb_place($s, 'foe', 0, 2, 1); $h = $s['pid'];
chk('fup_next_creature_hurt_gets_plus (and is spent)', (int)($s['pcs'][$h]['wv'] ?? 0) === 3 && (int)$s['foe']['wup'] === 0, [$s['pcs'][$h]['wv'] ?? null, $s['foe']['wup']]);

// ---------------------------------------------------------------- Magpie's Pinch: hit = its strongest hand piece, miss = its weakest; it is in your next hand as yours
$fh = [['k' => 'f:a', 'n' => 'Nip', 't' => 'hurt', 'v' => 5, 'r' => 'body', 'tag' => '', 'ed' => WILD], ['k' => 'f:b', 'n' => 'Maul', 't' => 'hurt', 'v' => 12, 'r' => 'body', 'tag' => '', 'ed' => WILD], ['k' => 'f:c', 'n' => 'Fluff', 't' => 'guard', 'v' => 2, 'r' => 'body', 'tag' => '', 'ed' => WILD]];
$seenH = 0; $seenM = 0; $okH = true; $okM = true; $okHand = true; $okGone = true; $okScale = true;
for ($seed = 1; $seed <= 40; $seed++) {
    $s = luckFight(10, $seed, ['stat-magpie-s-pinch']); $s['foe']['hand'] = $fh; put($s, 'me', plain('rest', 3), 2, 2);
    $sm = 0; $cm = 0; $sf = 0; $cf = 0; foreach (['hand', 'draw', 'discard'] as $z) { foreach ($s['me'][$z] as $t) { $sm += (int)$t['v']; $cm++; } foreach ($s['foe'][$z] as $t) { $sf += (int)$t['v']; $cf++; } }
    $ev = playAt($s, luckTile('stat-magpie-s-pinch'), 3, 2); $r = rootEv($ev, $s['pid']);
    $hit = ($r['roll'] ?? '') === 'hit'; $want = $hit ? 'Maul' : 'Fluff'; $hit ? $seenH++ : $seenM++;
    $pin = $s['me']['wpin'] ?? [];
    $ok = count($pin) === 1 && $pin[0]['n'] === $want && !in_array($want, array_column($s['foe']['hand'], 'n'), true) && ($r['pinch'] ?? '') === $want && !empty($pin[0]['pin']);
    if ($hit && !$ok) $okH = false; if (!$hit && !$ok) $okM = false;
    $fv = $hit ? 12 : 2; $exp = max(1, intdiv(2 * $fv * $sm * $cf + $sf * $cm, 2 * $sf * $cm));
    if (!$pin || (int)$pin[0]['v'] !== $exp) $okScale = false;
    pfb_end_round($s);   // act: the redraw
    $mine = array_values(array_filter($s['me']['hand'], fn($t) => !empty($t['pin'])));
    if (count($s['me']['hand']) !== PF_HAND_CAP || count($mine) !== 1 || $mine[0]['n'] !== $want || !empty($s['me']['wpin'])) $okHand = false;
    // it is gone after use: played and used up, it does not go to your discard; unplayed at the next redraw it is gone too
    $w = $s; $pi = array_search($want, array_column($w['me']['hand'], 'n'), true); $t = $w['me']['hand'][$pi]; array_splice($w['me']['hand'], $pi, 1);
    $pid = put($w, 'me', $t, 0, 0); $d0 = count($w['me']['discard']); pfb_discard($w, $w['pcs'][$pid]);
    $w2 = $s; pfb_end_round($w2);
    if (count($w['me']['discard']) !== $d0 || in_array($want, array_column(array_merge($w2['me']['hand'], $w2['me']['discard'], $w2['me']['draw']), 'n'), true)) $okGone = false;
}
chk('pinch_both_outcomes_seen', $seenH > 0 && $seenM > 0, [$seenH, $seenM]);
chk('pinch_hit_takes_strongest', $okH);
chk('pinch_miss_takes_weakest', $okM);
chk('pinch_value_rescaled_to_your_deck (its value x your average / its average)', $okScale);
chk('pinch_piece_is_one_of_your_next_hand_of_5', $okHand);
chk('pinch_piece_gone_after_use', $okGone);
// a boss needs two hits for its strongest piece: the strongest is taken less often than the roll's chance
$hb = 0; $hm = 0;
for ($seed = 1; $seed <= 300; $seed++) foreach (['medium', 'boss'] as $sz) {
    $s = luckFight(10, $seed, ['stat-magpie-s-pinch'], $sz); $s['foe']['hand'] = $fh; put($s, 'me', plain('rest', 3), 2, 2);
    playAt($s, luckTile('stat-magpie-s-pinch'), 3, 2); if (($s['me']['wpin'][0]['n'] ?? '') === 'Maul') { if ($sz === 'boss') $hb++; else $hm++; }
}
chk('pinch_boss_needs_two_hits (~49% vs ~70%)', $hm > 185 && $hm < 235 && $hb > 120 && $hb < 175, [$hm, $hb]);
// the creature's aim is made again after a piece leaves its hand
$s = luckFight(20, 4, ['stat-magpie-s-pinch']); $s['foe']['hand'] = $fh; put($s, 'me', plain('rest', 3), 2, 2); pfb_intent($s);
playAt($s, luckTile('stat-magpie-s-pinch'), 3, 2);
chk('pinch_creature_replans_from_its_hand_now', !empty($s['foe']['plan']) && in_array($s['foe']['plan']['k'], array_column($s['foe']['hand'], 'k'), true), $s['foe']['plan']['k'] ?? null);

// ---------------------------------------------------------------- Turn of the Coin: hit = its strongest hand piece back into its draw pile, it draws another; miss = that piece loses b
$seenH = 0; $seenM = 0; $okH = true; $okM = true; $okPlan = true;
for ($seed = 1; $seed <= 40; $seed++) {
    $s = luckFight(10, $seed, ['stat-turn-of-the-coin']); $s['foe']['hand'] = $fh; put($s, 'me', plain('rest', 3), 2, 2); pfb_intent($s);
    $nd = count($s['foe']['draw']);
    $ev = playAt($s, luckTile('stat-turn-of-the-coin', 3, 2), 3, 2); $r = rootEv($ev, $s['pid']); $hn = array_column($s['foe']['hand'], 'n');
    if (($r['roll'] ?? '') === 'hit') { $seenH++; if (count($hn) !== 3 || in_array('Maul', $hn, true) || $s['foe']['draw'][0]['n'] !== 'Maul' || count($s['foe']['draw']) !== $nd || ($r['coin'] ?? '') !== 'back') $okH = false; }
    else { $seenM++; $m = $s['foe']['hand'][array_search('Maul', $hn, true)] ?? null; if (!$m || (int)$m['v'] !== 10 || ($r['coin'] ?? '') !== 'cut') $okM = false; }
    if (!empty($s['foe']['plan']) && !in_array($s['foe']['plan']['k'], array_column($s['foe']['hand'], 'k'), true)) $okPlan = false;
    if (!empty($s['foe']['plan']) && $s['foe']['plan']['k'] === 'f:b' && (int)$s['foe']['plan']['v'] !== (int)$s['foe']['hand'][array_search('f:b', array_column($s['foe']['hand'], 'k'), true)]['v']) $okPlan = false;
}
chk('coin_both_outcomes_seen', $seenH > 0 && $seenM > 0, [$seenH, $seenM]);
chk('coin_hit_strongest_back_to_pile_bottom_draws_another', $okH);
chk('coin_miss_strongest_loses_b', $okM);
chk('coin_creature_replans (aim is a piece in its hand now, at its number now)', $okPlan);
// a boss's own pieces (its unique layer) cannot be sent back, only shrunk
$okB = true; $seenBH = 0;
for ($seed = 1; $seed <= 30; $seed++) {
    $s = luckFight(20, $seed, ['stat-turn-of-the-coin'], 'boss'); $bh = $fh; $bh[1]['k'] = 'f:u0'; $bh[1]['layer'] = 'uni'; $s['foe']['hand'] = $bh; put($s, 'me', plain('rest', 3), 2, 2);
    $ev = playAt($s, luckTile('stat-turn-of-the-coin', 3, 2), 3, 2); $r = rootEv($ev, $s['pid']);
    if (($r['roll'] ?? '') === 'hit') $seenBH++;
    $m = $s['foe']['hand'][array_search('Maul', array_column($s['foe']['hand'], 'n'), true)] ?? null;
    if (!$m || (int)$m['v'] !== 10) $okB = false;
}
chk('coin_boss_unique_piece_only_shrunk_even_on_hit', $okB && $seenBH > 0, $seenBH);

// ---------------------------------------------------------------- Lucky Streak: roll until a miss (at most b), each hit refires a random piece of yours; never itself or a Luck piece, each piece once
$okCap = true; $okWho = true; $okCount = true; $mx = 0; $zero = 0;
for ($seed = 1; $seed <= 80; $seed++) {
    $s = luckFight(20, $seed, ['stat-lucky-streak']);
    $mine = [put($s, 'me', plain('swing', 5), 2, 2), put($s, 'me', plain('dodge', 4), 1, 1), put($s, 'me', plain('charm', 4), 3, 3), put($s, 'me', plain('rest', 4), 0, 0)];
    $ls = put($s, 'me', luckTile('stat-long-shot'), 4, 4);
    $ev = playAt($s, luckTile('stat-lucky-streak', 5, 3), 2, 3); $st = $s['pid']; $r = rootEv($ev, $st);
    $re = array_values(array_filter($ev, fn($e) => !empty($e['re'])));
    $ids = array_map(fn($e) => $e['id'], $re);
    if (count($re) > 3) $okCap = false;
    if (array_diff($ids, $mine) || count(array_unique($ids)) !== count($ids)) $okWho = false;
    if (count($re) !== (int)($r['streak'] ?? -1)) $okCount = false;
    $mx = max($mx, count($re)); if (!$re) $zero++;
}
chk('streak_at_most_b_refires', $okCap);
chk('streak_refires_only_your_non_luck_pieces_once_each', $okWho);
chk('streak_refires_match_hits', $okCount);
chk('streak_reaches_b_and_sometimes_misses_first', $mx === 3 && $zero > 0, [$mx, $zero]);

echo $bad ? "$bad FAILED of $n\n" : "ok: $n Luck stat piece checks\n";
exit($bad ? 1 : 0);
