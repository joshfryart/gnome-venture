<?php
declare(strict_types=1);

/**
 * v2.0.20 Treks, Chapter III-a (deep rock): the mini-boss script. Registered through trek_script_register() with the existing hooks only
 * (moves, act, big, after_round, win); no engine code knows his name. Included by trek.php after trek_fight.php.
 *
 * Old Gneiss, the rockshell beetle of the Echo Hollow. One action a round, shown a round ahead ("Next: ..."):
 *   Hit    a plain attack.
 *   Brace  he pulls into his shell: he takes HALF damage from the party's next round (so: guard, heal, save the big hits).
 *   Slam   a heavy blow on one of you (double damage, no roll). A Guard halves it. He knocks as he does it, and something far below knocks back.
 * Under 35% health his shell cracks (after_round): no more Brace, the pattern is Hit, Slam, and he takes 20% more damage.
 * A long fight tires him: after round 5 he takes 8% more damage a round (up to +64%), so a party with little damage is not simply ground down.
 * Cured, not killed: the win text and the Almanac page say so. It pays the milestone ch3_gneiss; it does NOT end the chapter (III-b).
 */

const TREK_GN_MOVES = ['hit', 'brace', 'slam'];
const TREK_GN_CRACKED = ['hit', 'slam'];
const TREK_GN_SLAM_PCT = 200;   // a Slam hits for this % of a normal blow
const TREK_GN_HUM_PCT = 4;       // the deep hum soothes: every living friend regains this % of max health at the end of each round (evens out parties with and without a healer)
const TREK_GN_SUP_PCT = 30;       // he is that % tougher for each healer or Bark Skin giver in the party (a party with one outlasts him; one without hits harder than it can heal)
const TREK_GN_CRACK_PCT = 35;   // his shell cracks under this % of his health
const TREK_GN_TAKE_PCT = 120;   // ... and he takes this % of the damage after that
const TREK_GN_TIRE_FROM = 3;    // knocking wears him out: from the round after this one he takes TREK_GN_TIRE_STEP % more damage each round (a catch-up for slow parties)
const TREK_GN_TIRE_STEP = 12;
const TREK_GN_TIRE_MAX = 120;    // ... up to this many % more

trek_script_register('gneiss', [
    'big' => ['slam'],
    'moves' => function (array $fi): array {
        $seq = !empty($fi['meta']['crack']) ? TREK_GN_CRACKED : TREK_GN_MOVES;
        $gp = (int)($fi['meta']['gp'] ?? 0);
        return [$seq[$gp % count($seq)], $seq[($gp + 1) % count($seq)]];
    },
    'act' => function (array &$run, array $stats): void {
        $fi = &$run['fi'];
        $n = (int)$run['chapter'];
        $boss = $fi['foes'][0];
        unset($fi['foes'][0]['dm']);   // Brace (and the cracked shell) last for the party's moves of ONE round
        [$move] = trek_boss_moves($fi);
        trek_say_text($run, 'ch' . $n . '.spot.gneiss.' . $move);
        $fi['meta']['gp'] = (int)($fi['meta']['gp'] ?? 0) + 1;
        if ($move === 'hit') {
            trek_foe_attack($run, $stats, 0);
        } elseif ($move === 'brace') {   // he takes half from the party's next round
            $fi['foes'][0]['dm'] = 50;
            trek_say($run, '🛡️ ' . $boss['name'] . ' pulls into his shell: he will take half damage next round.');
        } else {   // slam: a heavy blow on one living member, no roll
            $live = trek_live_members($run);
            if ($live) {
                $slot = $live[array_rand($live)];
                trek_hurt_member($run, $slot, (int)round(TREK_GN_SLAM_PCT * foe_damage((int)$boss['die'], (int)$boss['bonus']) / 100), $stats, $boss['name'] . '’s Slam');
            }
        }
        $tire = min(TREK_GN_TIRE_MAX, max(0, (int)$fi['round'] - TREK_GN_TIRE_FROM) * TREK_GN_TIRE_STEP);   // v2.0.20: he tires the longer the fight goes
        if ($tire > 0 && empty($fi['meta']['tired'])) { $fi['meta']['tired'] = 1; trek_say($run, '😮‍💨 ' . $boss['name'] . ' is tiring: he takes a little more damage every round now.'); }
        if ($move !== 'brace') {
            $pct = (!empty($fi['meta']['crack']) ? TREK_GN_TAKE_PCT : 100) + $tire;
            if ($pct !== 100) $fi['foes'][0]['dm'] = $pct;
        }
    },
    'round_start' => function (array &$run, array $stats): void {
        $fi = &$run['fi'];
        if (!empty($fi['meta']['sized']) || TREK_GN_SUP_PCT <= 0) return;
        $fi['meta']['sized'] = 1;
        $n = 0;
        foreach (trek_live_members($run) as $sl) if (in_array($stats[$sl]['calling'], ['bloomcaller', 'seedkeeper', 'rootwarden', 'brewroot'], true)) $n++;
        if ($n < 2) return;
        $f = (100 + ($n - 1) * TREK_GN_SUP_PCT) / 100;
        $fi['foes'][0]['max'] = (int)round($fi['foes'][0]['max'] * $f);
        $fi['foes'][0]['hp'] = (int)round($fi['foes'][0]['hp'] * $f);
    },
    'round_end' => function (array &$run, array $stats): void {
        if (TREK_GN_HUM_PCT <= 0) return;
        foreach (trek_live_members($run) as $sl) {
            $max = (int)$stats[$sl]['max'];
            $run['party'][$sl]['hp'] = min($max, (int)$run['party'][$sl]['hp'] + max(1, (int)round($max * TREK_GN_HUM_PCT / 100)));
        }
    },
    'after_round' => function (array &$run, array $stats): void {
        $fi = &$run['fi'];
        $b = $fi['foes'][0];
        if (!empty($fi['meta']['crack']) || (int)$b['hp'] <= 0 || (int)$b['hp'] * 100 >= (int)$b['max'] * TREK_GN_CRACK_PCT) return;
        $fi['meta']['crack'] = 1;
        $fi['meta']['gp'] = 0;
        $fi['foes'][0]['dm'] = TREK_GN_TAKE_PCT + min(TREK_GN_TIRE_MAX, max(0, (int)$fi['round'] - 1 - TREK_GN_TIRE_FROM) * TREK_GN_TIRE_STEP);
        trek_say_text($run, 'ch' . (int)$run['chapter'] . '.spot.gneiss.crumble');
    },
    'win' => function (array &$run, array $u, array $spot, int $n): void {
        trek_flag_set($run, (string)$spot['data']['flag']);
        trek_say_text($run, 'ch' . $n . '.spot.gneiss.defeat');
        unlock_entries((int)$u['id'], 'trek:gneiss');
        trek_ms_award($run, $u, 'ch3_gneiss');
    },
]);
