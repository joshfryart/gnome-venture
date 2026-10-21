<?php
declare(strict_types=1);

/**
 * v2.0.22 Treks, Chapter III-b (the Knock Hall): the boss script. Registered through trek_script_register() with the existing hooks only
 * (moves, act, big, round_start, round_end, after_round, win); no engine code knows her name. Included by trek.php after trek_ch3.php.
 *
 * Old Holler, the giant blind cave toad of the Still Mere. She gulps every sound and booms it back wrong. One action a round, shown a round ahead ("Next: ..."):
 *   Hit     a plain attack.
 *   Gulp    she swallows the sound of your tricks: every living friend whose ability is still tired stays tired a round longer (as Thrum's Cling).
 *   Holler  a boom on everyone at once (no roll, TREK_HO_HOLLER_PCT of a blow each). A Guard or Bark Skin halves it: guard before it.
 * Under 35% health the grey flakes off her throat (after_round): no more Gulp, the pattern is Hit, Holler, she takes 15% more damage, and the Holler is softer.
 * From below the Warden knocks: every 2nd round each living friend regains 10% of max health (the spec said every 3rd: the sims needed more, see below).
 * A long fight tires her: from round 4 she takes 40% more damage a round (up to +400%), so a party with little damage is not simply ground down.
 * Party balance (round_start, once): her health follows the party's mending score (Heal, Spore Burst, Bark Skin, Poison): softer for a party of fighters, tougher for menders.
 * Cured, not killed: the win text and the Almanac page say so. It ends Chapter III: the finish row of Chapter III pays ch3_holler and ch3_chapter
 * (this script does NOT call trek_ms_award), and trek_complete_chapter() is called here. The numbers are the constants below plus the "holler" tune row
 * in trek_chapters_ch3b_tune.txt (1050% health, +11 attack, +6 defence, +31 damage). Tuned with tests/trek_audit_ch3b.php: gnome Lv19, mates Lv18, all 35 parties of three,
 * 300 fights each: median about 85%, worst about 74%. The sims showed Holler's all-party boom made a party with no healer or shield a wall, and that the odds swing by
 * about 1.2 for each mender (Heal, Spore Burst, Bark Skin) and -1.3 for each fighter; hence the mending score, the stronger tire and the more frequent knock.
 */

const TREK_HO_MOVES = ['hit', 'gulp', 'holler'];
const TREK_HO_CRACKED = ['hit', 'holler'];
const TREK_HO_HOLLER_PCT = 70;    // a Holler hits every living friend for this % of a normal blow (no roll)
const TREK_HO_HOLLER_CRACK_PCT = 60;   // ... and this % once her throat has cracked
const TREK_HO_CRACK_PCT = 35;     // her throat cracks under this % of her health
const TREK_HO_TAKE_PCT = 115;     // ... and she takes this % of the damage after that
const TREK_HO_KNOCK_EVERY = 2;    // the Warden knocks from below at the end of every Nth round ...
const TREK_HO_KNOCK_PCT = 10;     // ... and each living friend regains this % of max health
const TREK_HO_TIRE_FROM = 3;      // from the round after this one she takes TREK_HO_TIRE_STEP % more damage each round ...
const TREK_HO_TIRE_STEP = 40;
const TREK_HO_TIRE_MAX = 400;     // ... up to this many % more
const TREK_HO_SUP_PCT = 35;       // her health moves this % for each point of the party's mending score above (or below) the average one
const TREK_HO_SUP_WT = ['bloomcaller' => 100, 'seedkeeper' => 100, 'rootwarden' => 70, 'brewroot' => 40];   // ... counted by what the calling does for the party (% of a Heal or Bark Skin; fighters count 0)
const TREK_HO_SUP_REF = 150;       // the score of an average party (1.5): she is softer below it and tougher above it
const TREK_HO_WIN_ORDER = ['wren', 'burdock', 'zinnia', 'bracken', 'sorrel', 'tumble', 'juniper'];   // the first of these in the party speaks after the fall

trek_script_register('holler', [
    'big' => ['holler'],
    'moves' => function (array $fi): array {
        $seq = !empty($fi['meta']['crack']) ? TREK_HO_CRACKED : TREK_HO_MOVES;
        $gp = (int)($fi['meta']['gp'] ?? 0);
        return [$seq[$gp % count($seq)], $seq[($gp + 1) % count($seq)]];
    },
    'act' => function (array &$run, array $stats): void {
        $fi = &$run['fi'];
        $n = (int)$run['chapter'];
        $boss = $fi['foes'][0];
        unset($fi['foes'][0]['dm']);   // the cracked throat and the tiring last for the party's moves of ONE round
        [$move] = trek_boss_moves($fi);
        trek_say_text($run, 'ch' . $n . '.spot.holler.' . $move);
        $fi['meta']['gp'] = (int)($fi['meta']['gp'] ?? 0) + 1;
        if ($move === 'hit') {
            trek_foe_attack($run, $stats, 0);
        } elseif ($move === 'gulp') {   // tired abilities stay tired a round longer (as Thrum's Cling)
            $c = 0;
            foreach ($fi['mem'] as $slot => $mm) {
                if ((int)($mm['cd'] ?? 0) > 0 && (int)$run['party'][$slot]['hp'] > 0) { $fi['mem'][$slot]['cd'] = (int)$mm['cd'] + 1; $c++; }
            }
            trek_say($run, '🐸 ' . $boss['name'] . ' gulps the sound out of the air' . ($c ? ': tired abilities take a round longer.' : '.'));
        } else {   // holler: a boom on everyone, no roll
            $pct = !empty($fi['meta']['crack']) ? TREK_HO_HOLLER_CRACK_PCT : TREK_HO_HOLLER_PCT;
            $dmg = max(1, (int)round($pct * foe_damage((int)$boss['die'], (int)$boss['bonus']) / 100));
            foreach (trek_live_members($run) as $slot) trek_hurt_member($run, $slot, $dmg, $stats, $boss['name'] . '’s Holler');
        }
        $tire = min(TREK_HO_TIRE_MAX, max(0, (int)$fi['round'] - TREK_HO_TIRE_FROM) * TREK_HO_TIRE_STEP);
        if ($tire > 0 && empty($fi['meta']['tired'])) { $fi['meta']['tired'] = 1; trek_say($run, '😮‍💨 ' . $boss['name'] . ' is tiring: she takes more damage every round now.'); }
        $pct = (!empty($fi['meta']['crack']) ? TREK_HO_TAKE_PCT : 100) + $tire;
        if ($pct !== 100) $fi['foes'][0]['dm'] = $pct;
    },
    'round_start' => function (array &$run, array $stats): void {
        $fi = &$run['fi'];
        if (!empty($fi['meta']['sized']) || TREK_HO_SUP_PCT <= 0) return;
        $fi['meta']['sized'] = 1;
        $n = 0;   // the party's mending score: a Heal counts 1, Spore Burst less, Bark Skin least; Poison mends nothing (Brewroot is a damage dealer here)
        foreach (trek_live_members($run) as $sl) $n += (TREK_HO_SUP_WT[$stats[$sl]['calling']] ?? 0) / 100;
        $f = max(0.5, 1 + ($n - TREK_HO_SUP_REF / 100) * TREK_HO_SUP_PCT / 100);   // a party of fighters meets a softer Holler, a party of menders a tougher one (the sims showed a mender is worth about 1.2 in the odds, a fighter -1.3)
        if (abs($f - 1) < 0.005) return;
        $fi['foes'][0]['max'] = (int)round($fi['foes'][0]['max'] * $f);
        $fi['foes'][0]['hp'] = (int)round($fi['foes'][0]['hp'] * $f);
    },
    'round_end' => function (array &$run, array $stats): void {   // the Warden knocks from below
        $fi = &$run['fi'];
        if (TREK_HO_KNOCK_PCT <= 0 || (int)$fi['round'] % TREK_HO_KNOCK_EVERY !== 0) return;
        if (empty($fi['meta']['knocked'])) { $fi['meta']['knocked'] = 1; trek_say_text($run, 'ch' . (int)$run['chapter'] . '.spot.holler.knock'); }
        else trek_say($run, '🪨 Knock. Knock. Knock. Everyone steadies.');
        foreach (trek_live_members($run) as $sl) {
            $max = (int)$stats[$sl]['max'];
            $run['party'][$sl]['hp'] = min($max, (int)$run['party'][$sl]['hp'] + max(1, (int)round($max * TREK_HO_KNOCK_PCT / 100)));
        }
    },
    'after_round' => function (array &$run, array $stats): void {   // the throat cracks: no more Gulp, a softer Holler, she takes more
        $fi = &$run['fi'];
        $b = $fi['foes'][0];
        if (!empty($fi['meta']['crack']) || (int)$b['hp'] <= 0 || (int)$b['hp'] * 100 >= (int)$b['max'] * TREK_HO_CRACK_PCT) return;
        $fi['meta']['crack'] = 1;
        $fi['meta']['gp'] = 0;
        $fi['foes'][0]['dm'] = TREK_HO_TAKE_PCT + min(TREK_HO_TIRE_MAX, max(0, (int)$fi['round'] - 1 - TREK_HO_TIRE_FROM) * TREK_HO_TIRE_STEP);
        trek_say_text($run, 'ch' . (int)$run['chapter'] . '.spot.holler.crack');
    },
    'win' => function (array &$run, array $u, array $spot, int $n): void {
        trek_flag_set($run, (string)$spot['data']['flag']);
        trek_say_text($run, 'ch' . $n . '.spot.holler.defeat');
        foreach (TREK_HO_WIN_ORDER as $k) {
            if (!trek_in_party($run, $k)) continue;
            $npc = trek_crew_npc($k);
            trek_say_text($run, 'ch' . $n . '.spot.holler.' . $k, ['trailmate' => $npc ? (string)$npc['name'] : ucfirst($k)]);
            break;
        }
        trek_say_text($run, 'ch' . $n . '.scene.holler.me');
        trek_complete_chapter($run, $u);   // the finish row pays ch3_holler and ch3_chapter, the Petals and the items
    },
]);
