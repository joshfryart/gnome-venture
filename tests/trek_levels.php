<?php
// Treks v1.8.9: trek levels, milestone XP, the migration of old runs and the Chapter I balance sim.
// Run on an installed copy: php tests/trek_levels.php GAME_DIR  (treks.sh does). The sim uses real dice, so its bands are wide (300 fights per row).
$_SERVER['SCRIPT_NAME'] = '/trek.php';
require $argv[1] . '/includes/bootstrap.php';
require_once $argv[1] . '/includes/trek.php';
if (session_status() !== PHP_SESSION_ACTIVE) session_start();
$fails = 0;
set_exception_handler(function (Throwable $e) { if (db()->inTransaction()) db()->rollBack(); echo '  EXCEPTION ' . get_class($e) . ': ' . $e->getMessage() . ' @ ' . basename($e->getFile()) . ':' . $e->getLine() . "\n"; exit(1); });
function ok(string $what, bool $cond, string $extra = ''): void { global $fails; echo ($cond ? '  ok   ' : '  FAIL ') . $what . ($cond ? '' : "  $extra") . "\n"; if (!$cond) $fails++; }
$uid = (int)q_val("SELECT id FROM users WHERE username = 'sprout'");
$tx = fn(callable $f, bool $need = true) => trek_tx($uid, $f, $need);
$run = fn() => trek_load(trek_run_row($uid));
$mainXp = fn() => (int)q_val('SELECT xp FROM users WHERE id = ?', [$uid]);
$msRows = fn() => (int)q_val('SELECT COUNT(*) FROM trek_ms WHERE user_id = ?', [$uid]);
set_setting('trek_open', '1'); set_setting('trek_event_pct', '0'); set_setting('trek_enc_percent', '0'); setting('__reload__');
q('UPDATE creature_drops SET chance = 0 WHERE 1 = 1');
foreach (['trek_ms_burdock' => 150, 'trek_ms_zinnia' => 250, 'trek_ms_bracken' => 350, 'trek_ms_mother' => 500, 'trek_ms_gloomtooth' => 600, 'trek_ms_chapter' => 350] as $k => $v) set_setting($k, (string)$v);
setting('__reload__');

/** A brand-new run, inside, whole map seen, first fight won, at the start. */
$fresh = function () use ($uid, $tx) {
    foreach (['trek_flags', 'trek_pack', 'trek_party', 'trek_recruits'] as $t) q("DELETE FROM $t WHERE run_id IN (SELECT id FROM trek_runs WHERE user_id = ?)", [$uid]);
    q('DELETE FROM trek_runs WHERE user_id = ?', [$uid]);
    q('UPDATE users SET level = 16, energy = 100, coins = 1000, calling = NULL WHERE id = ?', [$uid]);
    $tx(fn(&$run, $u) => trek_enter($run, $u), false);
    $tx(function (&$run, $u) { $run['sn'] = str_repeat("\xff", strlen($run['sn'])); trek_flag_set($run, 'won_fight'); $run['fatigue'] = 0; $run['x'] = 4; $run['y'] = 15; return [true, '']; });
};
$lvOf = fn(string $k) => trek_tl_get($run(), $k)[0];
$easyFight = function (string $zone = 'g') use ($tx) {   // one rigged, certain win (the real win code runs)
    $tx(function (&$run, $u) use ($zone) {
        trek_start_random_fight($run, $u, $zone);
        foreach ($run['fi']['foes'] as $i => $f) { $run['fi']['foes'][$i]['hp'] = 1; $run['fi']['foes'][$i]['def'] = -50; $run['fi']['foes'][$i]['atk'] = -60; }
        trek_fight_auto($run, $u, 60);
        return [true, ''];
    });
};

echo "== the curve and the bonuses\n";
ok('XP to level: 44, 60, 76 ... (+16 each)', trek_tl_need(1) === 44 && trek_tl_need(2) === 60 && trek_tl_need(3) === 76 && trek_tl_need(9) === 172);
$cum = fn(int $lv) => array_sum(array_map('trek_tl_need', $lv > 1 ? range(1, $lv - 1) : []));
ok('cumulative XP: Lv5 272, Lv8 644', $cum(5) === 272 && $cum(8) === 644, $cum(5) . '/' . $cum(8));
ok('Lv1 adds nothing', trek_tl_bonus(1, 100) === ['hp' => 0, 'atk' => 0, 'dmg' => 0]);
ok('Lv2: +6% health, +1 to hit', trek_tl_bonus(2, 100) === ['hp' => 6, 'atk' => 1, 'dmg' => 0]);
ok('Lv3: +1 damage starts', trek_tl_bonus(3, 100)['dmg'] === 1 && trek_tl_bonus(3, 100)['atk'] === 1);
ok('Lv8: +42% health, +4 to hit, +2 damage', trek_tl_bonus(8, 100) === ['hp' => 42, 'atk' => 4, 'dmg' => 2], json_encode(trek_tl_bonus(8, 100)));
ok('health rounds (6% of 78 per level, Lv4)', trek_tl_bonus(4, 78)['hp'] === (int)round(78 * 0.06 * 3));
$fresh();
$R = $run();
ok('a new run starts everyone at trek level 1, 0 XP', $R['st']['tl'] === ['gnome' => [1, 0]]);
$base = $tx(function (&$run, $u) { $s = trek_party_stats($run, $u)[0]; return [$s['max'], $s['gc']['atk'], $s['gc']['dmg_bonus'], $s['tl']]; });
$tx(function (&$run, $u) { $run['st']['tl']['gnome'] = [7, 0]; return [true, '']; });
$up = $tx(function (&$run, $u) { $s = trek_party_stats($run, $u)[0]; return [$s['max'], $s['gc']['atk'], $s['gc']['dmg_bonus'], $s['tl']]; });
ok('trek_party_stats adds the bonuses (Lv7: +' . trek_tl_bonus(7, $base[0])['hp'] . ' health, +3 hit, +2 damage)',
    $up[0] === $base[0] + trek_tl_bonus(7, $base[0])['hp'] && $up[1] === $base[1] + 3 && $up[2] === $base[2] + 2 && $up[3] === 7, json_encode([$base, $up]));
$tx(function (&$run, $u) { $run['st']['tl']['gnome'] = [1, 0]; $run['fatigue'] = 60; return [true, '']; });
$tired = $tx(function (&$run, $u) { return trek_party_stats($run, $u)[0]['gc']['atk']; });
ok('fatigue still takes its point off the attack', $tired === $base[1] - 1, "$tired vs {$base[1]}");
$tx(function (&$run, $u) { $run['fatigue'] = 0; return [true, '']; });
ok('base stats are unchanged by a trek level (they come from the trek BASE level, v1.9.5, not the gnome level 16)', $tx(fn(&$run, $u) => trek_party_stats($run, $u)[0]['level']) === trek_base_level() && trek_base_level() === 15);
echo "== v1.9.5: the gnome's main level does not count in treks\n";
{
    $mk = function (int $gl) use ($uid) {
        $su = q_one('SELECT * FROM users WHERE id = ?', [$uid]); $su['level'] = $gl; $su['calling'] = null;
        foreach (['grit', 'nimble', 'hardiness'] as $st) $su['stat_' . $st] = 12;
        $run = ['id' => 0, 'chapter' => 1, 'fatigue' => 0, 'st' => ['tl' => ['gnome' => [4, 0], 'burdock' => [3, 0]]], 'party' => [0 => ['crew_key' => 'gnome', 'hp' => 999], 1 => ['crew_key' => 'burdock', 'hp' => 999]], 'flags' => []];
        $st = trek_party_stats($run, $su);
        $c = trek_creature('withered-aphid'); $t = trek_foe_tune(['zone' => 'f']);
        $foe = fn($ch) => array_map(fn($k) => $k, trek_make_foe(trek_creature($ch), $su, 2, false, $t, 1));
        return ['gc' => [$st[0]['gc'], $st[1]['gc']], 'max' => [$st[0]['max'], $st[1]['max']], 'foe1' => $foe('withered-aphid'), 'foe2' => trek_make_foe(trek_creature('clay-crawler'), $su, 2, false, [100, 0, 0, 0], 2),
            'duel' => trek_scripts()['duel_bracken']['duel']($su, []), 'out' => outlevel_percent(trek_gnome_user($su), 3)];
    };
    $a = $mk(15); $b = $mk(20); $c30 = $mk(30);
    ok('gnome 15 and 30: identical combat numbers (HP, attack, armour, damage) for the gnome and a trailmate', $a['gc'] === $c30['gc'] && $a['max'] === $c30['max'], json_encode([$a['gc'][0], $c30['gc'][0]]));
    ok('gnome 15, 20 and 30: identical foes (Chapter I and II) and the same Bracken duel', $a['foe1'] === $b['foe1'] && $a['foe1'] === $c30['foe1'] && $a['foe2'] === $c30['foe2'] && $a['duel'] === $c30['duel']);
    ok('gnome 30 gets no outlevel cut against Lv3 foes inside a trek', $c30['out'] === $a['out']);
    ok('the gnome at 30 fights as a calling tier of the base level (no Master perks)', calling_tier(['calling' => 'rootwarden', 'level' => 30, 'calling_qt' => 2]) === 3 && trek_gnome_user(['calling' => 'rootwarden', 'level' => 30, 'calling_qt' => 2])['level'] === 15 && calling_tier(trek_gnome_user(['calling' => 'rootwarden', 'level' => 30, 'calling_qt' => 2])) === 2);
}

echo "== trek XP: uncapped, and the gnome's main XP is untouched\n";
$fresh();
$m0 = $mainXp();
for ($i = 0; $i < 40; $i++) $easyFight('g');
$R = $run();
$total = 0; foreach ($R['st']['tl'] as $v) { for ($l = 1; $l < $v[0]; $l++) $total += trek_tl_need($l); $total += $v[1]; }
ok('40 won fights: main XP untouched', $mainXp() === $m0, $m0 . ' -> ' . $mainXp());
ok('40 won fights: far more trek XP than the old daily cap (300)', $total >= 40 * 10 && $total > 300, (string)$total);
ok('the old daily counter is never used', (int)$R['xp_today'] === 0);
ok('the gnome climbed (Lv ' . $lvOf('gnome') . ')', $lvOf('gnome') >= 6);
$lines = implode(' ', array_map(fn($l) => $l['s'] ?? '', $R['lg']));
ok('the win line says trek XP (not gnome XP)', str_contains(implode(' ', array_map(fn($l) => $l['s'] ?? '', $run()['lg'])), 'trek XP'));
ok('a level-up line is in the log', (bool)array_filter($R['lg'], fn($l) => isset($l['s']) && str_contains($l['s'], 'reaches trek level')) || str_contains(json_encode($R['st']['flog'] ?? []), 'reaches trek level'));
// a lost fight gives nothing
$fresh();
$tx(function (&$run, $u) { trek_start_random_fight($run, $u, 'g'); foreach ($run['fi']['foes'] as $i => $f) { $run['fi']['foes'][$i]['hp'] = $run['fi']['foes'][$i]['max'] = 99999; $run['fi']['foes'][$i]['atk'] = 100; $run['fi']['foes'][$i]['die'] = 200; } for ($i = 0; $i < 30 && $run['fi']; $i++) trek_fight_round($run, $u, [0 => ['a' => 'guard']]); return [true, '']; });
ok('a knock-out gives no trek XP', $run()['st']['tl'] === ['gnome' => [1, 0]] && (int)$run()['st']['kos'] === 1);

echo "== level-ups: threshold, carry-over, heal a quarter, half for the fallen\n";
$fresh();
$tx(function (&$run, $u) { trek_tl_give($run, $u, 43); return [true, '']; });
ok('43 XP: still level 1', trek_tl_get($run(), 'gnome') === [1, 43]);
$tx(function (&$run, $u) { $run['party'][0]['hp'] = 10; trek_tl_give($run, $u, 1); return [true, '']; });
$R = $run();
ok('44 XP: level 2, nothing left over', trek_tl_get($R, 'gnome') === [2, 0]);
$max = $tx(fn(&$run, $u) => trek_party_stats($run, $u)[0]['max']);
ok('level-up heals a quarter of the new maximum', $R['party'][0]['hp'] === min($max, 10 + (int)ceil($max * 0.25)), $R['party'][0]['hp'] . ' of ' . $max);
ok('the level-up line names the member and the level', (bool)array_filter($R['lg'], fn($l) => isset($l['s']) && preg_match('/^⬆️ \S+ reaches trek level 2!$/u', $l['s'])), json_encode(array_slice($R['lg'], -3)));
$tx(function (&$run, $u) { $run['st']['tl']['gnome'] = [1, 0]; trek_tl_give($run, $u, 44 + 60 + 5); return [true, '']; });
ok('a big gain climbs several levels and keeps the rest', trek_tl_get($run(), 'gnome') === [3, 5], json_encode(trek_tl_get($run(), 'gnome')));
$tx(function (&$run, $u) { $run['party'][0]['hp'] = 0; $run['st']['tl']['gnome'] = [1, 0]; trek_tl_give($run, $u, 20, true); return [true, '']; });
ok('a fallen member gets half', trek_tl_get($run(), 'gnome') === [1, 10]);
$tx(function (&$run, $u) { $run['party'][0]['hp'] = 0; $run['st']['tl']['gnome'] = [1, 0]; trek_tl_give($run, $u, 20, false); return [true, '']; });
ok('events give nothing to a fallen member', trek_tl_get($run(), 'gnome') === [1, 0]);
$tx(function (&$run, $u) { $run['st']['tl']['gnome'] = [TREK_TL_MAX, 0]; trek_tl_give($run, $u, 5000); return [true, '']; });
ok('the top level stops there', trek_tl_get($run(), 'gnome') === [TREK_TL_MAX, 0]);

echo "== a late trailmate: starts at the party average - 2, and catches up\n";
$fresh();
$tx(function (&$run, $u) { $run['st']['tl']['gnome'] = [6, 0]; trek_flag_set($run, 'freed_zinnia'); trek_recruit_crew($run, $u, 'zinnia'); return [true, '']; });
ok('Zinnia joins at 6 - 2 = 4', $lvOf('zinnia') === 4, json_encode($run()['st']['tl']));
$R = $run();
ok('her health is full at her new level', $R['party'][1]['hp'] === $tx(fn(&$run, $u) => trek_party_stats($run, $u)[1]['max']));
$tx(function (&$run, $u) { $run['st']['tl']['gnome'] = [6, 0]; $run['st']['tl']['zinnia'] = [4, 0]; trek_tl_give($run, $u, 20, true); return [true, '']; });
$R = $run();
ok('below the average she earns +50% (30 vs 20)', trek_tl_get($R, 'zinnia') === [4, 30] && trek_tl_get($R, 'gnome') === [6, 20], json_encode($R['st']['tl']));
$tx(function (&$run, $u) { $run['flags']['freed_burdock'] = 1; trek_recruit_crew($run, $u, 'burdock'); return [true, '']; });
ok('a second joiner uses the new average ((6+4)/2 - 2 = 3)', $lvOf('burdock') === 3, json_encode($run()['st']['tl']));
$fresh();
$tx(function (&$run, $u) { trek_recruit_crew($run, $u, 'burdock'); return [true, '']; });
ok('never under level 1', $lvOf('burdock') === 1);
$tx(function (&$run, $u) { $run['st']['tl']['burdock'] = [5, 7]; return [true, '']; });
$spots = trek_spots(1);
$tx(function (&$run, $u) use ($spots) { $run['x'] = $spots['camp']['x']; $run['y'] = $spots['camp']['y']; return [true, '']; });
$tx(fn(&$run, $u) => trek_set_party($run, $u, [1 => '']));
$tx(fn(&$run, $u) => trek_set_party($run, $u, [1 => 'burdock']));
ok('swapping a trailmate out and back keeps their level and XP', trek_tl_get($run(), 'burdock') === [5, 7]);

echo "== milestones: base x (0.5 + 0.5 x checks done / checks that apply)\n";
$bases = ['burdock' => 150, 'zinnia' => 250, 'bracken' => 350, 'mother' => 500, 'gloomtooth' => 600, 'chapter' => 350];
ok('bases add up to 2200 at full checks and 1100 at none', array_sum($bases) === 2200 && (int)round(array_sum($bases) / 2) === 1100);
ok('the formula', trek_ms_xp('mother', 5, 5) === 500 && trek_ms_xp('mother', 0, 5) === 250 && trek_ms_xp('mother', 3, 5) === 400 && trek_ms_xp('burdock', 1, 1) === 150);
$fresh();
q('DELETE FROM trek_ms WHERE user_id = ?', [$uid]);   // earlier test files paid some
$R = $run();
[$d, $t] = trek_ms_checks($R, q_one('SELECT * FROM users WHERE id = ?', [$uid]), 'burdock');
ok('at Burdock only the knock-out check applies (1/1)', [$d, $t] === [1, 1], "$d/$t");
$R['st']['kos'] = 1;
[$d, $t] = trek_ms_checks($R, q_one('SELECT * FROM users WHERE id = ?', [$uid]), 'burdock');
ok('a knock-out fails it (0/1)', [$d, $t] === [0, 1]);
$u1 = q_one('SELECT * FROM users WHERE id = ?', [$uid]);
$R = $run();
[$d, $t] = trek_ms_checks($R, $u1, 'mother');
ok('by the Blight Mother 4 checks apply and one passes (no knock-out)', [$d, $t] === [1, 4], "$d/$t");
$R['flags'] += ['seen_cart' => true, 'mush_done' => true, 'seen_bridgestone' => true, 'choir_solved' => true, 'stone_solved' => true]; $R['st']['evn'] = 3; $R['flags']['cm_burdock'] = true; $R['flags']['cmt_burdock'] = true;
[$d, $t, $list] = trek_ms_checks($R, $u1, 'mother');
ok('every check done is 5/5 (side stops, events, riddles, crew moments, no knock-out)', [$d, $t] === [5, 5], "$d/$t " . json_encode($list));
$R['st']['evn'] = 2; unset($R['flags']['cmt_burdock']);
[$d, $t] = trek_ms_checks($R, $u1, 'mother');
ok('2 events and an untaken crew moment fail two checks (3/5)', [$d, $t] === [3, 5], "$d/$t");

// through the real actions
$fresh();
$tx(function (&$run, $u) use ($spots) { $run['x'] = $spots['burdock']['x']; $run['y'] = $spots['burdock']['y']; return [true, '']; });
$x0 = $mainXp(); $r0 = $msRows();
$r = $tx(fn(&$run, $u) => trek_act_recruit($run, $u));
$R = $run();
ok('freeing Burdock pays the Burdock milestone: 150 XP (1/1)', $r[0] && $mainXp() === $x0 + 150 && $msRows() === $r0 + 1, ($mainXp() - $x0) . ' xp');
ok('the milestone is recorded in the run, with a card waiting', ($R['st']['ms']['burdock']['xp'] ?? 0) === 150 && ($R['st']['msc'] ?? []) === ['burdock'] && trek_flag($R, 'ms_burdock'));
ok('the log says how it was worked out', (bool)array_filter($R['lg'], fn($l) => ($l['s'] ?? '') === '🏅 Burdock: 1/1 checks → 150 XP.'));
$tx(function (&$run, $u) { trek_ms_award($run, $u, 'burdock'); trek_ms_award($run, $u, 'burdock'); return [true, '']; });
ok('asking again pays nothing', $mainXp() === $x0 + 150);
$tx(function (&$run, $u) { unset($run['st']['msc']); return [true, '']; });
ok('the card goes away when dismissed (msdismiss)', !isset($run()['st']['msc']));
// a knock-out first: half price
$fresh();
$tx(function (&$run, $u) use ($spots) { $run['st']['kos'] = 1; $run['x'] = $spots['burdock']['x']; $run['y'] = $spots['burdock']['y']; return [true, '']; });
q('DELETE FROM trek_ms WHERE user_id = ?', [$uid]);
$x0 = $mainXp();
$tx(fn(&$run, $u) => trek_act_recruit($run, $u));
ok('with a knock-out first it pays half: 75 XP (0/1)', $mainXp() === $x0 + 75, ($mainXp() - $x0) . '');
// no repay after an admin reset (admin/treks.php deletes the run rows only)
$x1 = $mainXp(); $rows = $msRows();
$rid = (int)$run()['id'];
foreach (['trek_party', 'trek_pack', 'trek_flags', 'trek_recruits'] as $t) q("DELETE FROM $t WHERE run_id = ?", [$rid]);
q('DELETE FROM trek_runs WHERE id = ?', [$rid]);
ok('a reset keeps the paid milestones', $msRows() === $rows && $rows >= 1);
$fresh();
$tx(function (&$run, $u) use ($spots) { $run['x'] = $spots['burdock']['x']; $run['y'] = $spots['burdock']['y']; return [true, '']; });
$tx(fn(&$run, $u) => trek_act_recruit($run, $u));
$R = $run();
ok('after a reset, freeing Burdock again pays nothing', $mainXp() === $x1 && !empty($R['st']['ms']['burdock']['old']) && empty($R['st']['msc']), ($mainXp() - $x1) . ' xp');
ok('...but Burdock still joins', count($R['party']) === 2);
ok('...and the Zinnia milestone is still open after a reset', !trek_flag($R, 'ms_zinnia'));
// fights and a boss pay milestones through the real code
$fresh();
q('DELETE FROM trek_ms WHERE user_id = ?', [$uid]);
$tx(function (&$run, $u) use ($spots) { $run['x'] = $spots['mother']['x']; $run['y'] = $spots['mother']['y']; trek_flag_set($run, 'freed_zinnia'); return [true, '']; });
$x0 = $mainXp();
$tx(function (&$run, $u) { trek_act_challenge($run, $u); foreach ($run['fi']['foes'] as $i => $f) { $run['fi']['foes'][$i]['hp'] = 1; $run['fi']['foes'][$i]['def'] = -50; $run['fi']['foes'][$i]['atk'] = -60; } trek_fight_auto($run, $u, 60); return [true, '']; });
$R = $run();
$exp = trek_ms_xp('mother', (int)$R['st']['ms']['mother']['done'], (int)$R['st']['ms']['mother']['total']);
ok('the Blight Mother milestone pays by its checks (' . $R['st']['ms']['mother']['done'] . '/' . $R['st']['ms']['mother']['total'] . ' = ' . $exp . ' XP)', $exp > 0 && $mainXp() === $x0 + $exp && trek_flag($R, 'mother_down'), ($mainXp() - $x0) . " vs $exp");
ok('...and the boss fight gave trek XP, not gnome XP', trek_tl_get($R, 'gnome')[0] >= 3);
// Gloomtooth then the chapter, both at once
$tx(function (&$run, $u) use ($spots) { $run['x'] = $spots['gloomtooth']['x']; $run['y'] = $spots['gloomtooth']['y']; return [true, '']; });
$x0 = $mainXp();
$tx(function (&$run, $u) { trek_act_challenge($run, $u); foreach ($run['fi']['foes'] as $i => $f) { $run['fi']['foes'][$i]['hp'] = 1; $run['fi']['foes'][$i]['def'] = -50; $run['fi']['foes'][$i]['atk'] = -60; } trek_fight_auto($run, $u, 60); return [true, '']; });
$R = $run();
$g = $R['st']['ms']['gloomtooth']; $c = $R['st']['ms']['chapter'];
ok('Gloomtooth and the chapter each pay once', $g['xp'] === trek_ms_xp('gloomtooth', $g['done'], $g['total']) && $c['xp'] === trek_ms_xp('chapter', $c['done'], $c['total']) && $mainXp() === $x0 + $g['xp'] + $c['xp'], json_encode([$g, $c]));
ok('both cards wait on the map', array_slice((array)($R['st']['msc'] ?? []), -2) === ['gloomtooth', 'chapter']);
$x2 = $mainXp();
$tx(function (&$run, $u) { trek_complete_chapter($run, $u); return [true, '']; });
ok('finishing again pays no milestone', $mainXp() === $x2);
ok('the trek_xp_daily setting is retired (still there, nothing reads it)', (string)setting('trek_xp_daily') !== '' && !str_contains(file_get_contents($argv[1] . '/includes/trek_fight.php') . file_get_contents($argv[1] . '/includes/trek_events.php'), "setting('trek_xp_daily')"));
// the full chapter at full checks
ok('a full-checks chapter pays about 1.5x the old cap over five Hollow days (2200 vs 1500)', array_sum($bases) >= 2100 && array_sum($bases) <= 2300);

echo "== migration: a run from before trek levels\n";
$old = function (array $flags, array $recruits) use ($uid, $fresh, $tx) {
    $fresh();
    $tx(function (&$run, $u) use ($flags, $recruits) {
        foreach ($flags as $f) trek_flag_set($run, $f);
        foreach ($recruits as $k) trek_recruit_crew($run, $u, $k);
        unset($run['st']['tl'], $run['st']['ms'], $run['st']['msc']);   // as saved by 1.8.8
        foreach (array_keys($run['flags']) as $f) if (str_starts_with($f, 'ms_')) unset($run['flags'][$f]);
        return [true, ''];
    });
    q("DELETE FROM trek_flags WHERE run_id = ? AND flag LIKE 'ms\\_%' ESCAPE '\\'", [(int)q_val('SELECT id FROM trek_runs WHERE user_id = ?', [$uid])]);
    q('DELETE FROM trek_ms WHERE user_id = ?', [$uid]);
    q('UPDATE trek_runs SET state = ? WHERE user_id = ?', [json_encode(array_diff_key(json_decode((string)q_val('SELECT state FROM trek_runs WHERE user_id = ?', [$uid]), true), ['tl' => 1, 'ms' => 1, 'msc' => 1])), $uid]);
};
$old([], []);
ok('(setup) the old run has no trek levels', !isset($run()['st']['tl']));
$x0 = $mainXp();
$tx(fn(&$run, $u) => [true, '']);
ok('no progress: everyone is level 1, nothing marked paid', $run()['st']['tl'] === ['gnome' => [1, 0]] && $msRows() === 0);
$old(['freed_burdock', 'freed_zinnia'], ['burdock', 'zinnia']);
$x0 = $mainXp();
$tx(fn(&$run, $u) => [true, '']);
$R = $run();
ok('Burdock and Zinnia found: all three start at trek level 5', ($R['st']['tl'] ?? null) === ['gnome' => [5, 0], 'burdock' => [5, 0], 'zinnia' => [5, 0]], json_encode($R['st']['tl'] ?? null));
ok('their milestones are marked paid without paying', trek_flag($R, 'ms_burdock') && trek_flag($R, 'ms_zinnia') && !trek_flag($R, 'ms_bracken') && $mainXp() === $x0 && $msRows() === 2);
ok('the migration is logged once', substr_count(json_encode($R['lg'], JSON_UNESCAPED_UNICODE), 'has grown on the trail') === 1);
$before = json_encode([$R['st']['tl'], $R['st']['ms'], array_keys($R['flags'])]);
$tx(fn(&$run, $u) => [true, '']); $tx(fn(&$run, $u) => [true, '']);
$R2 = $run();
ok('loading again changes nothing (idempotent)', json_encode([$R2['st']['tl'], $R2['st']['ms'], array_keys($R2['flags'])]) === $before && $mainXp() === $x0 && substr_count(json_encode($R2['lg'], JSON_UNESCAPED_UNICODE), 'has grown on the trail') === 1);
$tx(function (&$run, $u) use ($spots) { $run['x'] = $spots['bracken']['x']; $run['y'] = $spots['bracken']['y']; trek_ms_award($run, $u, 'zinnia'); trek_ms_award($run, $u, 'bracken'); return [true, '']; });
ok('...Zinnia is not paid again, Bracken is', $mainXp() > $x0 && $mainXp() <= $x0 + 350 && $msRows() === 3, ($mainXp() - $x0) . ' xp');
$old(['freed_burdock', 'freed_zinnia', 'freed_bracken', 'mother_down'], ['burdock', 'zinnia', 'bracken']);
$tx(fn(&$run, $u) => [true, '']);
ok('four milestones passed: level 7', $lvOf('gnome') === 7 && $lvOf('bracken') === 7);
$old(['freed_burdock', 'freed_zinnia', 'freed_bracken', 'mother_down', 'gloomtooth_cured', 'ch1_done'], ['burdock', 'zinnia', 'bracken']);
$x0 = $mainXp();
$tx(fn(&$run, $u) => [true, '']);
ok('a finished chapter: level 9, six milestones marked, nothing paid', $lvOf('gnome') === 9 && $msRows() === 6 && $mainXp() === $x0);
$tx(function (&$run, $u) { trek_complete_chapter($run, $u); return [true, '']; });
ok('...and finishing again pays no milestone', $mainXp() === $x0);
$old(['freed_burdock'], ['burdock']);
$tx(function (&$run, $u) { $run['party'] = array_slice($run['party'], 0, 1, true); q('DELETE FROM trek_party WHERE run_id = ? AND slot > 0', [$run['id']]); unset($run['st']['tl']); return [true, '']; });
$tx(fn(&$run, $u) => [true, '']);   // the next load migrates
ok('a recruit waiting out of the party also gets the start level', $lvOf('burdock') === 3 && $lvOf('gnome') === 3, json_encode($run()['st']['tl']));

echo "== balance sim (real dice; Auto, no snacks, full health, gnome level 15 with +1 in Grit, Nimble and Hardiness)\n";
$GLOBALS['trek_sim'] = true;
$su = q_one("SELECT * FROM users WHERE id = ?", [$uid]);
$su['id'] = 999999; $su['level'] = 15; $su['calling'] = null;
foreach (['grit', 'nimble', 'hardiness'] as $s) $su['stat_' . $s] = 12;
$P1 = [0 => 'gnome']; $P2 = [0 => 'gnome', 1 => 'burdock']; $P3 = [0 => 'gnome', 1 => 'burdock', 2 => 'zinnia']; $P4 = [0 => 'gnome', 1 => 'burdock', 2 => 'zinnia', 3 => 'bracken'];
/** Win % of $N fights. The gnome is at trek level $L, trailmates one lower (they join two under the average and catch up). */
$simWin = function (array $keys, int $L, callable $start, int $N) use ($su): float {
    $won = 0;
    for ($i = 0; $i < $N; $i++) {
        $run = ['id' => 0, 'chapter' => 1, 'fatigue' => 0, 'st' => ['tl' => []], 'party' => [], 'fi' => null, 'lg' => [], 'flags' => ['tut_party' => true], 'petals_found' => 0];
        foreach ($keys as $s => $k) { $run['party'][$s] = ['crew_key' => $k, 'hp' => 9999]; $run['st']['tl'][$k] = [$k === 'gnome' ? $L : max(1, $L - 1), 0]; }
        foreach (trek_party_stats($run, $su) as $s => $m) $run['party'][$s]['hp'] = $m['max'];
        $GLOBALS['trek_sim_won'] = false;
        $start($run, $su, count($keys));
        for ($r = 0; $r < 80 && $run['fi']; $r++) trek_fight_round($run, $su, trek_fight_ai($run, $su));
        if (!empty($GLOBALS['trek_sim_won'])) $won++;
    }
    return round(100 * $won / $N, 1);
};
$randomIn = fn(string $zone) => function (array &$run, array $u, int $size) use ($zone) {
    $cs = trek_pick_foes($zone);
    $t = trek_foe_tune(['zone' => $zone]);
    trek_start_fight($run, $u, $cs, ['kind' => 'random', 'zone' => $zone], array_map(fn($c) => trek_make_foe($c, $u, $size, false, $t), $cs));
};
$bossAt = fn(string $code) => function (array &$run, array $u, int $size) use ($code) {
    $sp = trek_spots(1)[$code]; $c = trek_creature($sp['data']['creature']);
    $meta = ['kind' => 'spot', 'spot' => $code, 'script' => $sp['data']['script'], 'zone' => $sp['zone']];
    trek_start_fight($run, $u, [$c], $meta, [trek_make_foe($c, $u, $size, false, trek_foe_tune($meta))]);
};
$N = 300;
$row = function (string $label, float $w, float $lo, float $hi) {
    printf("  %-34s win %5.1f%%  (want %d-%d%%)\n", $label, $w, $lo, $hi);
    ok($label . ' in band', $w >= $lo && $w <= $hi, "got $w");
};
echo "  -- early fights, trek Lv1-3\n";
$row('zone g, Lv1, the gnome alone', $simWin($P1, 1, $randomIn('g'), $N), 95, 100);
$row('zone w, Lv1, the gnome alone', $simWin($P1, 1, $randomIn('w'), $N), 85, 100);
$row('zone w, Lv2, the gnome alone', $simWin($P1, 2, $randomIn('w'), $N), 85, 100);
$row('zone w, Lv3, the gnome alone', $simWin($P1, 3, $randomIn('w'), $N), 90, 100);
$row('zone f, Lv1, + Burdock', $simWin($P2, 1, $randomIn('f'), $N), 95, 100);
$row('zone f, Lv3, + Burdock', $simWin($P2, 3, $randomIn('f'), $N), 95, 100);
$row('zone d, Lv3, + Burdock', $simWin($P2, 3, $randomIn('d'), $N), 90, 100);
echo "  -- later zones, at the level you reach them\n";
$row('zone h, Lv5, three of you', $simWin($P3, 5, $randomIn('h'), $N), 90, 100);
$row('zone b, Lv5, three of you', $simWin($P3, 5, $randomIn('b'), $N), 90, 100);
$row('zone r, Lv6, four of you', $simWin($P4, 6, $randomIn('r'), $N), 90, 100);
echo "  -- the Blight Mother (four of you): a loss at Lv3, fair at Lv5-6, safe at Lv8\n";
$row('Blight Mother, Lv3', $simWin($P4, 3, $bossAt('mother'), $N), 0, 40);
$row('Blight Mother, Lv5', $simWin($P4, 5, $bossAt('mother'), $N), 55, 90);
$row('Blight Mother, Lv6', $simWin($P4, 6, $bossAt('mother'), $N), 70, 97);
$row('Blight Mother, Lv8', $simWin($P4, 8, $bossAt('mother'), $N), 90, 100);
echo "  -- Gloomtooth (four of you): a loss at Lv5, fair at Lv8, safe at Lv10\n";
$row('Gloomtooth, Lv5', $simWin($P4, 5, $bossAt('gloomtooth'), $N), 0, 35);
$row('Gloomtooth, Lv7', $simWin($P4, 7, $bossAt('gloomtooth'), $N), 45, 88);
$row('Gloomtooth, Lv8', $simWin($P4, 8, $bossAt('gloomtooth'), $N), 65, 95);
$row('Gloomtooth, Lv10', $simWin($P4, 10, $bossAt('gloomtooth'), $N), 90, 100);
unset($GLOBALS['trek_sim'], $GLOBALS['trek_sim_won']);

echo "== the XP economy along the route (expected values, hunting, +15% for detours)\n";
{
    $sp = trek_spots(1);
    $rr = ['chapter' => 1, 'sneak' => 0, 'fatigue' => 0, 'flags' => ['won_fight' => 1, 'freed_burdock' => 1, 'freed_zinnia' => 1, 'mother_down' => 1], 'x' => $sp['start']['x'], 'y' => $sp['start']['y'], 'sn' => str_repeat("\xff", 300), 'st' => []];
    $ex = [];
    foreach (['g', 'w', 'c', 'f', 'd', 'h', 'b', 'r', 'x'] as $z) {
        $pool = trek_zone_pool($z);
        if (!$pool || !$pool['list'] || $pool['mult'] <= 0) { $ex[$z] = [0, 0]; continue; }
        $s = 0; for ($i = 0; $i < 2500; $i++) $s += trek_fight_xp(array_map(fn($c) => ['size' => $c['size']], trek_pick_foes($z)));
        $ex[$z] = [$s / 2500, 9 * $pool['mult'] / 10000];   // average XP of a fight, chance of one per step (the 9% default)
    }
    $cumXp = 0; $at = [];
    foreach (['rootwall', 'cart', 'burdock', 'boulder', 'camp', 'cellar', 'dewsign', 'mushcamp', 'zinnia', 'elder', 'choir', 'capwall', 'bridgestone', 'bracken', 'mother', 'dengate', 'gloomtooth'] as $c) {
        foreach (trek_path($rr, $sp[$c]['x'], $sp[$c]['y']) as [$x, $y]) { $z = trek_zone_at(1, $x, $y); $cumXp += ($ex[$z][0] ?? 0) * ($ex[$z][1] ?? 0) * 1.15; }
        $rr['x'] = $sp[$c]['x']; $rr['y'] = $sp[$c]['y'];
        $at[$c] = $cumXp;
    }
    $lvAt = function (float $xp) { $l = 1; while ($xp >= trek_tl_need($l)) { $xp -= trek_tl_need($l); $l++; } return $l; };
    $mother = $at['mother']; $den = $at['gloomtooth'] + TREK_FOE_XP['boss']; $end = $den + TREK_FOE_XP['boss'];
    printf("  trek XP on arrival: Burdock %d, camp %d, Zinnia %d, Bracken %d, Blight Mother %d (Lv%d); Gloomtooth %d (Lv%d); end %d (Lv%d)\n", $at['burdock'], $at['camp'], $at['zinnia'], $at['bracken'], $mother, $lvAt($mother), $den, $lvAt($den), $end, $lvAt($end));
    ok('about Lv5-7 on reaching the Blight Mother', $lvAt($mother) >= 5 && $lvAt($mother) <= 7);
    ok('about Lv7-8 on reaching Gloomtooth', $lvAt($den) >= 7 && $lvAt($den) <= 8);
    ok('Chapter I ends at about Lv8-10', $lvAt($end) >= 8 && $lvAt($end) <= 10);
    ok('early pace: 44 XP is about 2-3 fights in the Wormway', 44 / max(1, $ex['w'][0]) >= 2 && 44 / max(1, $ex['w'][0]) <= 3.2, (string)round(44 / max(1, $ex['w'][0]), 1));
}

echo $fails ? "\n$fails FAILED\n" : "\nall ok\n";
exit($fails ? 1 : 0);
