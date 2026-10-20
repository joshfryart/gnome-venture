<?php
declare(strict_types=1);

/**
 * v1.8.0 Treks: party fights. Each living member picks Attack / Ability / Snack (the gnome only) / Guard; foes act after the party.
 * The dice and sums (d20 to hit, damage die + bonus, crits, foe attacks, flee, creature scaling) are shared with the road fights: includes/combat_math.php.
 * What is trek-only lives here: the party, abilities, tactics, TREK_TUNE and the boss scripts at the bottom.
 */

require_once __DIR__ . '/combat_math.php';

/** Calling abilities in a party fight: calling => [name, what it does, target kind (foe|ally|none), cooldown in rounds]. */
const TREK_ABILITIES = [
    'rootwarden' => ['Bark Skin', 'Halves the damage you or a friend take for 3 rounds.', 'ally', 4],
    'bloomcaller' => ['Heal', 'Heals you or a friend for about a quarter of their health.', 'ally', 2],
    'thornblade' => ['Power Strike', 'A heavy blow: extra damage and a wider crit range. A hit on a boss that is holding a friend makes it let go.', 'foe', 2],
    'seedkeeper' => ['Spore Burst', 'Spores hit every foe for half damage, mend every friend a little and make a holding boss let go.', 'none', 3],
    'wayfinder' => ['Sling', 'A ranged shot with +5 to hit and +5 damage. A hit on a boss that is holding a friend makes it let go.', 'foe', 2],
    'brewroot' => ['Poison', 'A vial: 2d6, then 3 damage a round for 3 rounds. A poisoned foe hits 5% softer.', 'foe', 3],
    '' => ['Gnome Pluck', 'A determined swing: +3 to hit and +3 damage.', 'foe', 2],
];

/** Gloomtooth's round pattern, shown a round ahead. After Burrow comes the Burst. */
const TREK_GT_MOVES = ['claw', 'burrow', 'burst', 'quake'];
const TREK_MOVE_NAMES = ['claw' => 'Claw', 'burrow' => 'Burrow', 'burst' => 'Burst', 'quake' => 'Quake', 'hit' => 'Hit', 'sweep' => 'Sweep', 'mend' => 'Mend',
    'grab' => 'Grab', 'squeeze' => 'Squeeze', 'drum' => 'Drum', 'harden' => 'Harden', 'crack' => 'Crack', 'stunned' => 'Stunned'];   // v1.9.4: Old Pinch and Old Thrum
/** v1.9.2: Silverfin's round pattern (Chapter II-a), shown a round ahead: hit, sweep (half damage to all), mend (+8% health). */
const TREK_SF_MOVES = ['hit', 'sweep', 'mend'];
/** v1.9.2: the Claybound: ordinary underground creatures caked in weeping clay (the Almanac page unlocks with the first one beaten). */
const TREK_CLAYBOUND = ['clay-crawler', 'page-silverfish', 'mud-crayfish', 'spadefoot-toad', 'silverfin', 'dimwing-moth', 'cistern-newt', 'drumming-cricket'];   // v1.9.4: II-b's three
/** v1.9.4: Old Pinch's round pattern (Chapter II-b): hit, grab one of you, squeeze the one she holds (a hit if she holds nobody). Bark Skin on the held one breaks the grab. */
const TREK_PI_MOVES = ['hit', 'grab', 'squeeze'];
/** v1.9.4: Old Thrum's patterns: hit, drum (a little to all), harden (he takes half), crack (he takes +50% and is stunned for a round); after the molt (under 30%): hit, crack, drum. Still one action a round. */
const TREK_TH_MOVES = ['hit', 'drum', 'harden', 'crack'];
const TREK_TH_MOLT = ['hit', 'crack', 'drum'];
const TREK_SPORE_MEND_PCT = 7;   // v2.0.1: Spore Burst mends every living friend this % of their max health
const TREK_SICK_PCT = 5;   // v2.0.1: a poisoned foe's hits do this % less damage
const TREK_PARTY_HP_PCT = 60;   // foes get this % more health for each trailmate beyond the gnome (tune with the fight tests)

// ------------------------------------------------------------------ foes

function trek_creature(string $slug): ?array
{
    static $cache = [];
    if (!array_key_exists($slug, $cache)) $cache[$slug] = q_one('SELECT * FROM creatures WHERE slug = ?', [$slug]);
    return $cache[$slug];
}

/**
 * v1.8.9 RETUNE for trek levels. Foes were tuned for a flat party; now the party grows (trek level: +6% health, +1 to hit per 2 levels, +1 damage per
 * 3 levels), so foes grow with the story instead. key (a zone letter, or a script name) => [health %, +attack, +defence, +damage bonus].
 * v1.9.1: the numbers are data, "tune" rows of trek_chapters*.txt, per chapter (Chapter I's rows are the old TREK_TUNE, unchanged).
 * Tuned with the balance sim in tests/trek_levels.php (Auto, no snacks, gnome level 15 with +1 in Grit, Nimble and Hardiness, full health):
 *   early fights at trek Lv1-3 win about 90% or more; the Blight Mother is a fair fight at trek Lv5-6 (about 75-85%) and a loss at Lv3;
 *   Gloomtooth is fair at Lv8 (about 75-85%) and a loss at Lv5; ordinary fights in the later zones stay about 85-95% at the level you reach them.
 * v1.9.5: the gnome's MAIN level no longer counts anywhere in treks (everyone fights at the setting trek_base_level, default 15, plus trek levels), so these
 * numbers hold at any gnome level. Chapter II was retuned at base 15 (sims in tests/trek_ch2.php and trek_ch2b.php, at gnome 15, 20 and 30).
 * Zones g, w, c, f are the early ones and are left as they were. Change a number, rerun tests/trek_levels.php, read the printed win rates.
 */

/** The tune for a fight: its script (a boss) first, else its zone; [100, 0, 0, 0] = as the creature file says. */
function trek_foe_tune(array $meta, int $chapter = 1): array
{
    $t = trek_chapter($chapter)['tune'];
    return $t[(string)($meta['script'] ?? '')] ?? $t[(string)($meta['zone'] ?? '')] ?? [100, 0, 0, 0];
}

/** Build a foe for a fight: grown toward the base level (a little; never the gnome's level), eased like road creatures, tougher with a bigger party, tuned by zone (v1.8.9). */
function trek_make_foe(array $c, array $u, int $partySize, bool $add = false, array $tune = [100, 0, 0, 0], int $chapter = 1): array
{
    // v1.9.5: foes never look at the gnome's main level. Chapter I grows them toward the fixed trek base level; later chapters come from their data
    // (creature file + tune rows). The old "lift" rows (foes +1 per gnome level) are ignored.
    $lv = ($chapter > 1 || $add) ? (int)$c['level'] : max((int)$c['level'], min(trek_base_level() - 1, (int)$c['level'] + 4));
    if ($lv > (int)$c['level']) $c = scale_creature($c, $lv, (int)setting('creature_scale_percent'), (int)setting('creature_scaled_hp_percent'));
    $hp = combat_pct((int)$c['hp'], creature_hp_percent($c));   // the road's late-game easing, then the party's growth (trek only), then the chapter tune (trek only)
    $hp = combat_pct($hp, 100 + TREK_PARTY_HP_PCT * max(0, $partySize - 1));
    $hp = combat_pct($hp, $tune[0]);
    return ['slug' => (string)$c['slug'], 'name' => (string)$c['name'], 'size' => (string)$c['size'], 'lv' => (int)$c['level'], 'hp' => $hp, 'max' => $hp,
        'atk' => (int)$c['attack'] + $tune[1], 'def' => (int)$c['defense'] + $tune[2], 'die' => (int)$c['dmg_die'], 'bonus' => (int)$c['dmg_bonus'] + $tune[3], 'xp' => $add ? 0 : (int)$c['xp'],
        'cid' => (int)$c['id'], 'pz' => 0, 'under' => 0, 'add' => $add ? 1 : 0,
        'blight' => in_array($c['slug'], ['withered-aphid', 'rot-snail', 'ashen-ant'], true) ? 1 : 0,
        'icon' => creature_icon((string)$c['name'], (string)$c['size'])];
}

/** Pick 1-3 foes for a zone (large ones count double; a few zones are always single). */
function trek_pick_foes(string $zone, int $chapter = 1): array
{
    $pool = trek_zone_pool($zone, $chapter);
    if (!$pool || !$pool['list']) return [];
    $roll = random_int(1, 100);
    $n = !empty(trek_chapter($chapter)['zones'][$zone]['single']) ? 1 : ($roll <= 45 ? 1 : ($roll <= 85 ? 2 : 3));
    $slots = 0;
    $out = [];
    for ($i = 0; $i < $n; $i++) {
        $pick = null;
        $total = array_sum($pool['list']);
        $r = random_int(1, max(1, $total));
        foreach ($pool['list'] as $slug => $w) { $r -= $w; if ($r <= 0) { $pick = $slug; break; } }
        $c = $pick ? trek_creature($pick) : null;
        if (!$c) continue;
        $cost = in_array($c['size'], ['large', 'boss'], true) ? 2 : 1;
        if ($slots + $cost > 3) break;
        $slots += $cost;
        $out[] = $c;
    }
    return $out;
}

/** Begin a fight from a list of creature rows. $meta: kind, zone, spot, script, duel, after. */
function trek_start_fight(array &$run, array $u, array $creatures, array $meta, ?array $foes = null): void
{
    $stats = trek_party_stats($run, $u);
    $size = count(array_filter($stats, fn($m) => $m['hp'] > 0));
    $tune = trek_foe_tune($meta, (int)$run['chapter']);
    $foes ??= array_map(fn($c) => trek_make_foe($c, $u, $size, false, $tune, (int)$run['chapter']), $creatures);
    foreach ($foes as $i => $f) $foes[$i]['i'] = $i;
    $mem = [];
    foreach ($stats as $slot => $m) $mem[$slot] = ['bark' => 0, 'cd' => 0, 'guard' => 0, 'pz' => 0];
    $run['st']['flog'] = [];   // v1.8.8: record this fight's lines from the very first one
    $run['st']['flog_on'] = 1;
    $run['fi'] = ['round' => 1, 'foes' => array_values($foes), 'mem' => $mem, 'snacks' => 0, 'meta' => $meta + ['kind' => 'random', 'zone' => '', 'spot' => null, 'script' => '', 'duel' => 0, 'after' => '']];
    $names = array_map(fn($f) => $f['name'], $foes);
    trek_say($run, '⚔️ ' . implode(', ', $names) . (count($names) > 1 ? ' block' : ' blocks') . ' the way!');
    $n = (int)$run['chapter'];
    // v2.0.4: the lessons are Chapter I's (a run starts without the flags, so Chapter II would replay them); the party lesson names Burdock, so it waits until he is in the party
    if ($n === 1 && count($stats) > 1 && trek_in_party($run, 'burdock') && !trek_flag($run, 'tut_party')) { trek_flag_set($run, 'tut_party'); trek_say_text($run, 'ch' . $n . '.tut.party'); }
}

function trek_start_random_fight(array &$run, array $u, string $zone, string $after = ''): void
{
    $cs = trek_pick_foes($zone, (int)$run['chapter']);
    if (!$cs) return;
    trek_start_fight($run, $u, $cs, ['kind' => 'random', 'zone' => $zone, 'after' => $after]);
}

/** Start the scripted fight of the spot the party stands on (duel, mini-boss, boss). [ok, message] */
function trek_act_challenge(array &$run, array $u): array
{
    $s = trek_here($run, $u);
    if (!$s || !in_array($s['type'], ['duel', 'miniboss', 'boss'], true) || $run['fi'] || trek_spot_done($run, $s)) return [false, 'Nothing to face here.'];
    $script = (string)($s['data']['script'] ?? '');
    $meta = ['kind' => 'spot', 'spot' => $s['code'], 'script' => $script, 'zone' => $s['zone']];
    $def = trek_script_def($script);
    if ($def && isset($def['duel'])) {   // a duel: the registry builds the foe
        $meta['duel'] = 1;
        trek_start_fight($run, $u, [], $meta, [$def['duel']($u, $s)]);
        return [true, ''];
    }
    $c = trek_creature((string)($s['data']['creature'] ?? ''));
    if (!$c) return [false, 'Nothing to face here.'];
    trek_start_fight($run, $u, [$c], $meta);
    $weak = (string)($s['data']['weak'] ?? '');   // v1.9.4: a boss weakened by a flag starts at weak_pct % of its health (Old Pinch, once the cistern is drained)
    if ($weak !== '' && trek_flag($run, $weak) && $run['fi']) {
        $pct = max(1, min(100, (int)($s['data']['weak_pct'] ?? 80)));
        $run['fi']['foes'][0]['hp'] = max(1, (int)round((int)$run['fi']['foes'][0]['max'] * $pct / 100));
        $run['fi']['meta']['weak'] = $pct;
        trek_say($run, '💧 With the water gone she is already worn: she starts at ' . $pct . '% health.');
    }
    return [true, ''];
}

// ------------------------------------------------------------------ a round

function trek_live_members(array $run): array
{
    return array_keys(array_filter($run['party'], fn($p) => (int)$p['hp'] > 0));
}

/** Foes that can be hit now: alive and not burrowed (a duel foe counts as alive above 1 health). */
function trek_targetable_foes(array $fi): array
{
    $floor = !empty($fi['meta']['duel']) ? 1 : 0;
    return array_keys(array_filter($fi['foes'], fn($f) => (int)$f['hp'] > $floor && empty($f['under'])));
}

function trek_foes_alive(array $fi): bool
{
    $floor = !empty($fi['meta']['duel']) ? 1 : 0;
    foreach ($fi['foes'] as $f) if (empty($f['add']) && (int)$f['hp'] > $floor) return true;
    return false;
}

/**
 * v1.9.1: BOSS SCRIPTS BY DATA. A spot row says script=<name>; this registry maps the name to what the fight does. Add a boss = add an entry here
 * (or trek_script_register() at run time, as the tests do); no other code names a boss. An entry may have:
 *   'code'        text-key piece for its lines (default: the script name), e.g. ch1.spot.<code>.<move>
 *   'moves'       fn(array $fi): ?array   [this round's move, next round's move] for the "Next:" line and the Auto AI
 *   'big'         moves the Auto AI treats as a big hit (it guards / shields before them)
 *   'duel'        fn(array $u, array $spot): array   builds the one foe of a duel (the fight ends at 1 health)
 *   'round_start' fn(array &$run, array $stats): void   before the party acts
 *   'act'         fn(array &$run, array $stats): void   the foes' turn (instead of every foe attacking)
 *   'round_end'   fn(array &$run, array $stats): void   end of the round, before the round counter moves on
 *   'after_round' fn(array &$run, array $stats): void   end of the round, after it moved on
 *   'win'         fn(array &$run, array $u, array $spot, int $chapter): void   the fight is won (flags, texts, milestones, the chapter end)
 */
function trek_scripts(?string $add = null, ?array $def = null): array
{
    static $reg = null;
    if ($reg === null) $reg = trek_scripts_builtin();
    if ($add !== null) { if ($def === null) unset($reg[$add]); else $reg[$add] = $def; }
    return $reg;
}

function trek_script_register(string $script, ?array $def): void
{
    trek_scripts($script, $def);
}

function trek_script_def(string $script): ?array
{
    return $script === '' ? null : (trek_scripts()[$script] ?? null);
}

/** The text-key piece of a fight's script (ch1.spot.<code>.<part>). */
function trek_script_code(string $script): string
{
    return (string)(trek_script_def($script)['code'] ?? $script);
}

/** Chapter I's scripts: Bracken's duel, the Blight Mother, Gloomtooth. */
function trek_scripts_builtin(): array
{
    return [
        'duel_bracken' => ['duel' => function (array $u, array $spot): array {
            $crew = trek_crew_user('bracken', $u);
            $crew['level'] = trek_base_level();   // the duel is against a thornblade of the base level (v1.9.5: not the gnome's main level)
            $gc = gnome_combat($crew);
            $npc = trek_crew_npc('bracken');
            return ['slug' => 'bracken', 'name' => (string)$npc['name'], 'size' => 'medium', 'lv' => trek_base_level(), 'hp' => $gc['max_hp'], 'max' => $gc['max_hp'], 'atk' => $gc['atk'],
                'def' => $gc['ac'], 'die' => $gc['dmg_die'], 'bonus' => $gc['dmg_bonus'], 'xp' => 0, 'cid' => 0, 'pz' => 0, 'under' => 0, 'add' => 0, 'blight' => 0, 'icon' => '🪲'];
        }],
        'blight-mother' => [
            'code' => 'mother',
            // v1.8.6: calmer Blight Mother: one aphid every 4 rounds, at most 3 foes alive, at most 4 aphids a fight (adds never block the win)
            'round_end' => function (array &$run, array $stats): void {
                $fi = &$run['fi'];
                if ((int)$fi['round'] % 4 !== 0 || (int)$fi['foes'][0]['hp'] <= 0) return;
                $c = trek_creature('withered-aphid');
                $spawned = 0;
                while ($c && count(array_filter($fi['foes'], fn($f) => (int)$f['hp'] > 0)) < 3 && $spawned < 1 && (int)($fi['meta']['adds'] ?? 0) < 4) {
                    $f = trek_make_foe($c, ['level' => 1], 1, true);
                    $f['i'] = count($fi['foes']);
                    $fi['foes'][] = $f;
                    $fi['meta']['adds'] = (int)($fi['meta']['adds'] ?? 0) + 1;
                    $spawned++;
                }
                if ($spawned) trek_say_text($run, 'ch' . $run['chapter'] . '.spot.mother.spawn');
            },
            'win' => function (array &$run, array $u, array $spot, int $n): void {
                trek_flag_set($run, (string)$spot['data']['flag']);
                trek_say_text($run, 'ch' . $n . '.spot.mother.defeat');
                trek_ms_award($run, $u, 'mother');
            },
        ],
        'silverfin' => [   // v1.9.2: the Drowned Library's page-eater. A pattern of three, shown a round ahead; page silverfish drift in (they never block the win).
            'big' => ['sweep'],
            'moves' => function (array $fi): array {
                $r = (int)$fi['round'] - 1;
                return [TREK_SF_MOVES[$r % 3], TREK_SF_MOVES[($r + 1) % 3]];
            },
            'act' => function (array &$run, array $stats): void {
                $fi = &$run['fi'];
                $n = (int)$run['chapter'];
                $boss = $fi['foes'][0];
                [$move] = trek_boss_moves($fi);
                trek_say_text($run, 'ch' . $n . '.spot.silverfin.' . $move);
                if ($move === 'hit') {
                    trek_foe_attack($run, $stats, 0);
                } elseif ($move === 'sweep') {   // everyone, at half
                    $base = foe_damage((int)$boss['die'], (int)$boss['bonus']);
                    foreach (trek_live_members($run) as $slot) trek_hurt_member($run, $slot, max(1, intdiv($base, 2)), $stats, $boss['name'] . '’s Sweep');
                } else {   // mend: +8% of her health
                    $heal = max(1, (int)ceil((int)$boss['max'] * 0.08));
                    $fi['foes'][0]['hp'] = min((int)$boss['max'], (int)$boss['hp'] + $heal);
                    trek_say($run, '📖 ' . $boss['name'] . ' mends her pages: +' . ($fi['foes'][0]['hp'] - (int)$boss['hp']) . ' health.');
                }
                foreach ($fi['foes'] as $i => $f) {   // the little silverfish nibble too
                    if ($i === 0 || (int)$f['hp'] <= 0 || !trek_live_members($run)) continue;
                    trek_foe_attack($run, $stats, $i);
                }
                if ((int)$fi['foes'][0]['hp'] * 100 < (int)$fi['foes'][0]['max'] * 30 && (int)$fi['foes'][0]['hp'] > 0 && trek_live_members($run)) {   // enraged: one more hit each round
                    if (empty($fi['meta']['enraged'])) { $fi['meta']['enraged'] = 1; trek_say_text($run, 'ch' . $n . '.spot.silverfin.enrage'); }
                    trek_foe_attack($run, $stats, 0);
                }
            },
            'round_end' => function (array &$run, array $stats): void {   // a page silverfish every 4th round, two a fight at most
                $fi = &$run['fi'];
                if ((int)$fi['round'] % 4 !== 0 || (int)$fi['foes'][0]['hp'] <= 0 || (int)($fi['meta']['adds'] ?? 0) >= 2) return;
                $c = trek_creature('page-silverfish');
                if (!$c) return;
                $f = trek_make_foe($c, ['level' => 1], 1, true, [100, 0, 0, 0], (int)$run['chapter']);
                $f['i'] = count($fi['foes']);
                $fi['foes'][] = $f;
                $fi['meta']['adds'] = (int)($fi['meta']['adds'] ?? 0) + 1;
                trek_say_text($run, 'ch' . $run['chapter'] . '.spot.silverfin.spawn');
            },
            'win' => function (array &$run, array $u, array $spot, int $n): void {
                trek_flag_set($run, (string)$spot['data']['flag']);
                trek_say_text($run, 'ch' . $n . '.spot.silverfin.defeat');
                unlock_entries((int)$u['id'], 'trek:silverfin');
                trek_ms_award($run, $u, 'ch2_silverfin');
            },
        ],
        'pinch' => [   // v1.9.4: the Sour Cistern's crab. Hit, grab one of you for a round, squeeze the one she holds. Bark Skin on the held one breaks the grab.
            'big' => ['squeeze'],
            'moves' => function (array $fi): array {
                $r = (int)$fi['round'] - 1;
                $held = isset($fi['meta']['held']);
                $cur = TREK_PI_MOVES[$r % 3];
                $next = TREK_PI_MOVES[($r + 1) % 3];
                if ($cur === 'squeeze' && !$held) $cur = 'hit';           // squeeze only if she is holding someone
                if ($next === 'squeeze' && !$held && $cur !== 'grab') $next = 'hit';
                return [$cur, $next];
            },
            'act' => function (array &$run, array $stats): void {
                $fi = &$run['fi'];
                $n = (int)$run['chapter'];
                $boss = $fi['foes'][0];
                if (isset($fi['meta']['held']) && (int)$run['party'][(int)$fi['meta']['held']]['hp'] <= 0) unset($fi['meta']['held']);   // the one she held fell
                [$move] = trek_boss_moves($fi);
                trek_say_text($run, 'ch' . $n . '.spot.pinch.' . $move);
                if ($move === 'hit') {
                    trek_foe_attack($run, $stats, 0);
                } elseif ($move === 'grab') {   // no roll: one of you is seized and held until the squeeze (or until Bark Skin lands on them)
                    $live = trek_live_members($run);
                    if ($live) {
                        $slot = $live[array_rand($live)];
                        $fi['meta']['held'] = $slot;
                        trek_say($run, '🦀 ' . $boss['name'] . ' seizes ' . $stats[$slot]['name'] . ' in her claw!');
                    }
                } else {   // squeeze: a big hit on the one she holds, no roll
                    $slot = (int)$fi['meta']['held'];
                    unset($fi['meta']['held']);
                    trek_hurt_member($run, $slot, 2 * foe_damage((int)$boss['die'], (int)$boss['bonus']), $stats, $boss['name'] . '’s Squeeze');
                }
            },
            'win' => function (array &$run, array $u, array $spot, int $n): void {
                trek_flag_set($run, (string)$spot['data']['flag']);
                trek_say_text($run, 'ch' . $n . '.spot.pinch.defeat');
                $pearl = trek_item_id('cistern-pearl');
                if ($pearl) { trek_pack_add((int)$run['id'], $pearl, 1); trek_say($run, '🎁 You receive 1 × ' . trek_item_name($pearl) . ' (carried).'); }
                unlock_entries((int)$u['id'], 'trek:pinch');
                trek_ms_award($run, $u, 'ch2_pinch');
            },
        ],
        'thrum' => [   // v1.9.4: the Drum Chamber's cricket and the end of Chapter II. One action a round, in a pattern shown a round ahead (see TREK_TH_MOVES).
            'big' => ['hit'],
            'moves' => function (array $fi): array {
                $seq = !empty($fi['meta']['molt']) ? TREK_TH_MOLT : TREK_TH_MOVES;
                $tp = (int)($fi['meta']['tp'] ?? 0);
                $cur = !empty($fi['meta']['stun']) ? 'stunned' : $seq[$tp % count($seq)];
                $next = $cur === 'stunned' ? $seq[$tp % count($seq)] : ($cur === 'crack' ? 'stunned' : $seq[($tp + 1) % count($seq)]);
                return [$cur, $next];
            },
            'act' => function (array &$run, array $stats): void {
                $fi = &$run['fi'];
                $n = (int)$run['chapter'];
                $boss = $fi['foes'][0];
                unset($fi['foes'][0]['dm']);   // Harden and Crack last for the party's moves of ONE round, then they are over
                [$move] = trek_boss_moves($fi);
                trek_say_text($run, 'ch' . $n . '.spot.thrum.' . $move);
                if ($move === 'stunned') {
                    unset($fi['meta']['stun']);
                    return;
                }
                $fi['meta']['tp'] = (int)($fi['meta']['tp'] ?? 0) + 1;
                if ($move === 'hit') {
                    trek_foe_attack($run, $stats, 0);
                } elseif ($move === 'drum') {   // a little to everyone, at a third; Cling (round_end) makes tired abilities a round slower
                    $base = foe_damage((int)$boss['die'], (int)$boss['bonus']);
                    foreach (trek_live_members($run) as $slot) trek_hurt_member($run, $slot, max(1, intdiv($base, 3)), $stats, $boss['name'] . '’s Drum');
                    $fi['meta']['cling'] = 1;
                } elseif ($move === 'harden') {   // he takes half from the party's next round
                    $fi['foes'][0]['dm'] = 50;
                    trek_say($run, '🛡️ ' . $boss['name'] . ' hardens: he will take half damage next round.');
                } else {   // crack: he takes +50% from the party's next round and is stunned for it
                    $fi['foes'][0]['dm'] = 150;
                    $fi['meta']['stun'] = 1;
                    trek_say($run, '💥 ' . $boss['name'] . ' cracks open: he will take +50% damage next round, and he is stunned.');
                }
            },
            'round_end' => function (array &$run, array $stats): void {   // Cling: after a Drum, an ability that is still tired stays tired a round longer
                $fi = &$run['fi'];
                if (empty($fi['meta']['cling'])) return;
                unset($fi['meta']['cling']);
                $n = 0;
                foreach ($fi['mem'] as $slot => $mm) {
                    if ((int)($mm['cd'] ?? 0) > 0 && (int)$run['party'][$slot]['hp'] > 0) { $fi['mem'][$slot]['cd'] = (int)$mm['cd'] + 1; $n++; }
                }
                if ($n) trek_say($run, '🥁 The drumbeat gets into your bones: tired abilities take a round longer.');
            },
            'after_round' => function (array &$run, array $stats): void {   // the molt: under 30% he sheds his shell and the pattern changes (still one action a round)
                $fi = &$run['fi'];
                $b = $fi['foes'][0];
                if (!empty($fi['meta']['molt']) || (int)$b['hp'] <= 0 || (int)$b['hp'] * 100 >= (int)$b['max'] * 30) return;
                $fi['meta']['molt'] = 1;
                $fi['meta']['tp'] = 0;
                unset($fi['meta']['stun'], $fi['foes'][0]['dm']);
                trek_say_text($run, 'ch' . (int)$run['chapter'] . '.spot.thrum.molt');
            },
            'win' => function (array &$run, array $u, array $spot, int $n): void {
                trek_flag_set($run, (string)$spot['data']['flag']);
                trek_say_text($run, 'ch' . $n . '.spot.thrum.defeat');
                trek_complete_chapter($run, $u);
            },
        ],
        'gloomtooth' => [
            'big' => ['burst', 'quake'],
            'moves' => function (array $fi): array {
                $r = (int)$fi['round'] - 1;
                return [TREK_GT_MOVES[$r % 4], TREK_GT_MOVES[($r + 1) % 4]];
            },
            'round_start' => function (array &$run, array $stats): void {
                if ((int)$run['fi']['round'] === 1) $run['fi']['foes'][0]['under'] = 0;
            },
            'act' => function (array &$run, array $stats): void {
                $fi = &$run['fi'];
                $n = (int)$run['chapter'];
                $boss = $fi['foes'][0];
                [$move] = trek_boss_moves($fi);
                trek_say_text($run, 'ch' . $n . '.spot.gloomtooth.' . $move);
                if ($move === 'claw') trek_foe_attack($run, $stats, 0);
                elseif ($move === 'burst') {   // big damage to one random member (no roll to hit: it comes from underneath)
                    $live = trek_live_members($run);
                    if ($live) {
                        $slot = $live[array_rand($live)];
                        trek_hurt_member($run, $slot, 2 * foe_damage((int)$boss['die'], (int)$boss['bonus']), $stats, $boss['name'] . '’s Burst');
                    }
                } elseif ($move === 'quake') {   // everyone, at half
                    $base = foe_damage((int)$boss['die'], (int)$boss['bonus']);
                    foreach (trek_live_members($run) as $slot) trek_hurt_member($run, $slot, max(1, intdiv($base, 2)), $stats, $boss['name'] . '’s Quake');
                }
                $fi['foes'][0]['under'] = 0;
                if ((int)$fi['foes'][0]['hp'] * 100 < (int)$fi['foes'][0]['max'] * 30 && (int)$fi['foes'][0]['hp'] > 0) {   // enraged: a second action
                    if (empty($fi['meta']['enraged'])) { $fi['meta']['enraged'] = 1; trek_say_text($run, 'ch' . $n . '.spot.gloomtooth.enrage'); }
                    if ($move !== 'burrow') trek_foe_attack($run, $stats, 0);
                }
            },
            'after_round' => function (array &$run, array $stats): void {   // burrowed this round? mark it now so the party cannot target him
                [$move] = trek_boss_moves($run['fi']);
                $run['fi']['foes'][0]['under'] = $move === 'burrow' ? 1 : 0;
            },
            'win' => function (array &$run, array $u, array $spot, int $n): void {
                trek_say_text($run, 'ch' . $n . '.spot.gloomtooth.defeat');
                $bd = (bool)array_filter($run['party'], fn($p) => $p['crew_key'] === 'burdock');
                if ($bd) trek_say_text($run, 'ch' . $n . '.spot.gloomtooth.burdock', ['trailmate' => trek_crew_npc('burdock')['name']]);
                trek_say_text($run, 'ch' . $n . '.scene.gloomtooth.me');   // v2.0.8: the gnome’s reply, then the pop-over (defeat as narration, Burdock, the gnome)
                trek_scene_queue($run, $u, array_merge([['npc', null, 'ch' . $n . '.spot.gloomtooth.defeat', []]], $bd ? [['npc2', 'burdock', 'ch' . $n . '.spot.gloomtooth.burdock', ['trailmate' => trek_crew_npc('burdock')['name']]]] : [], [['me', null, 'ch' . $n . '.scene.gloomtooth.me', []]]));
                trek_complete_chapter($run, $u);
            },
        ],
    ];
}

/** The move a scripted boss makes in this round and the one after it (for the "Next:" line), or null for other fights. */
function trek_boss_moves(array $fi): ?array
{
    $def = trek_script_def((string)($fi['meta']['script'] ?? ''));
    return $def && isset($def['moves']) ? $def['moves']($fi) : null;
}

/** The target a member chose, kept if still valid, else a fallback: the weakest foe you can hit. Returns a foe index or null. */
function trek_foe_target(array $fi, string $t): ?int
{
    $ok = trek_targetable_foes($fi);
    if (!$ok) return null;
    if (str_starts_with($t, 'f:') && in_array((int)substr($t, 2), $ok, true)) return (int)substr($t, 2);
    usort($ok, fn($a, $b) => $fi['foes'][$a]['hp'] <=> $fi['foes'][$b]['hp']);
    return $ok[0];
}

function trek_ally_target(array $run, string $t, int $self, bool $livingOnly = true): int
{
    if (str_starts_with($t, 'a:')) {
        $s = (int)substr($t, 2);
        if (isset($run['party'][$s]) && (!$livingOnly || (int)$run['party'][$s]['hp'] > 0)) return $s;
    }
    return $self;
}

/** Damage to a party member: Bark Skin and Guard each halve it (never under 1). In a duel nobody drops under 1 health. */
function trek_hurt_member(array &$run, int $slot, int $dmg, array $stats, string $from): void
{
    $fi = &$run['fi'];
    if (!empty($fi['meta']['sick'])) $dmg = max(1, (int)round($dmg * (100 - TREK_SICK_PCT) / 100));   // v2.0.1: a poisoned foe hits softer
    if (($fi['mem'][$slot]['bark'] ?? 0) > 0) $dmg = max(1, intdiv($dmg, 2));
    if (($fi['mem'][$slot]['guard'] ?? 0) > 0) $dmg = max(1, intdiv($dmg, 2));
    $hp = (int)$run['party'][$slot]['hp'] - $dmg;
    $run['party'][$slot]['hp'] = !empty($fi['meta']['duel']) ? max(1, $hp) : max(0, $hp);
    trek_say($run, '💥 ' . $from . ' hits ' . $stats[$slot]['name'] . ' for ' . $dmg . '.' . ($hp <= 0 && empty($fi['meta']['duel']) ? ' ' . $stats[$slot]['name'] . ' falls!' : ''));
}

function trek_hurt_foe(array &$fi, int $i, int $dmg): void
{
    if (!empty($fi['foes'][$i]['dm'])) $dmg = max(1, (int)round($dmg * (int)$fi['foes'][$i]['dm'] / 100));   // v1.9.4: Old Thrum's Harden (50) and Crack (150): a percent of the damage he takes
    $floor = !empty($fi['meta']['duel']) ? 1 : -999;
    $fi['foes'][$i]['hp'] = max($floor, (int)$fi['foes'][$i]['hp'] - $dmg);
}

/** v2.0.1: a Sling or Power Strike that lands, or a Spore Burst, also makes a boss let go of the friend it is holding (Bark Skin is no longer the only answer to Old Pinch). */
function trek_break_hold_by(array &$run, string $line): void
{
    $fi = &$run['fi'];
    if (!isset($fi['meta']['held'])) return;
    unset($fi['meta']['held']);
    trek_say($run, $line);
}

/** v1.9.4: Bark Skin on the member a boss is holding (fight meta "held" = slot) breaks the hold. */
function trek_break_hold(array &$run, int $slot): void
{
    $fi = &$run['fi'];
    if (!isset($fi['meta']['held']) || (int)$fi['meta']['held'] !== $slot) return;
    unset($fi['meta']['held']);
    trek_say_text($run, 'ch' . (int)$run['chapter'] . '.spot.' . trek_script_code((string)($fi['meta']['script'] ?? '')) . '.break');
    trek_say($run, '🌳 The bark is too rough to hold: the grab is broken!');
}

/** One member's action. */
function trek_member_act(array &$run, array $u, array $stats, int $slot, array $act): void
{
    $fi = &$run['fi'];
    $m = $stats[$slot];
    $gc = $m['gc'];
    $name = $m['name'];
    $kind = (string)($act['a'] ?? 'attack');
    $t = (string)($act['t'] ?? '');
    $calling = $m['calling'];
    $ab = TREK_ABILITIES[$calling] ?? TREK_ABILITIES[''];
    if ($kind === 'ability' && (int)$fi['mem'][$slot]['cd'] > 0) $kind = 'attack';   // still recovering
    if ($kind === 'snack') {
        $list = $slot === 0 ? fight_snacks($u) : [];
        $pick = null;
        foreach ($list as $s) if ($s['id'] === (int)($act['item'] ?? 0)) $pick = $s;
        if (!$pick || (int)$fi['snacks'] >= snack_limit($u) || $run['party'][0]['hp'] >= $stats[0]['max'] || !give_item((int)$u['id'], (int)$pick['id'], -1)) {
            $kind = 'attack';   // no snack to eat: swing instead
        } else {
            $heal = min($stats[0]['max'] - (int)$run['party'][0]['hp'], (int)$pick['heal']);
            $run['party'][0]['hp'] = (int)$run['party'][0]['hp'] + $heal;
            $fi['snacks'] = (int)$fi['snacks'] + 1;
            trek_say($run, '🎒 ' . $name . ' gulps down the ' . $pick['name'] . ': +' . $heal . ' health.');
            return;
        }
    }
    if ($kind === 'guard') {
        $fi['mem'][$slot]['guard'] = 1;
        trek_say($run, '🛡️ ' . $name . ' guards.');
        return;
    }
    if ($kind === 'ability') {
        $fi['mem'][$slot]['cd'] = $ab[3];
        switch ($calling) {
            case 'rootwarden':
                $to = trek_ally_target($run, $t, $slot);
                $fi['mem'][$to]['bark'] = 3;
                trek_say($run, '🌳 ' . $name . ' casts Bark Skin on ' . ($to === $slot ? 'themself' : $stats[$to]['name']) . ': damage halved for 3 rounds.');
                trek_break_hold($run, $to);   // v1.9.4: Old Pinch lets go
                return;
            case 'bloomcaller':
                $to = trek_ally_target($run, $t, $slot);
                $amt = max(1, (int)round($stats[$to]['max'] * 0.27));
                $new = min($stats[$to]['max'], (int)$run['party'][$to]['hp'] + $amt);
                trek_say($run, '🌸 ' . $name . ' heals ' . ($to === $slot ? 'themself' : $stats[$to]['name']) . ': +' . ($new - (int)$run['party'][$to]['hp']) . ' health.');
                $run['party'][$to]['hp'] = $new;
                return;
            case 'seedkeeper':
                $hit = 0;
                foreach (trek_targetable_foes($fi) as $i) {
                    $dmg = max(1, intdiv(d(6) + d(6) + eff_mod($m['user'], 'lore'), 2));
                    trek_hurt_foe($fi, $i, $dmg);
                    $hit++;
                }
                trek_break_hold_by($run, '🍄 The spores make her sneeze, and she lets go!');
                $mend = 0;   // v2.0.1: the spores also mend every living friend a share of their health (a niche on one-foe boss fights, where half damage is nothing)
                foreach (trek_live_members($run) as $s2) {
                    $new = min($stats[$s2]['max'], (int)$run['party'][$s2]['hp'] + max(1, (int)round($stats[$s2]['max'] * TREK_SPORE_MEND_PCT / 100)));
                    $mend += $new - (int)$run['party'][$s2]['hp'];
                    $run['party'][$s2]['hp'] = $new;
                }
                trek_say($run, '🍄 ' . $name . '’s Spore Burst engulfs ' . ($hit === 1 ? 'the foe' : 'every foe') . ' and mends the party: +' . $mend . ' health in all.');
                return;
        }
        $i = trek_foe_target($fi, $t);
        if ($i === null) { $fi['mem'][$slot]['cd'] = 0; trek_say($run, '🛡️ ' . $name . ' has nothing to aim at.'); return; }
        $foe = $fi['foes'][$i];
        switch ($calling) {
            case 'thornblade':
                $g2 = $gc;
                $g2['crit_from'] = max(2, (int)$gc['crit_from'] - 3);
                [, $tot, $crit] = attack_roll($g2, 0);
                $extra = 6;
                break;
            case 'wayfinder':
                [, $tot, $crit] = attack_roll($gc, 5);
                $extra = 5;
                break;
            case 'brewroot':
                $dmg = d(6) + d(6);
                trek_hurt_foe($fi, $i, $dmg);
                $fi['foes'][$i]['pz'] = 3;
                trek_say($run, '🧪 ' . $name . '’s vial splashes ' . $foe['name'] . ' for ' . $dmg . ' and keeps burning.');
                return;
            default:   // a gnome with no calling: Gnome Pluck
                [, $tot, $crit] = attack_roll($gc, 3);
                $extra = 3;
        }
        $label = $ab[0];
        if ($tot >= (int)$foe['def']) {
            $dmg = damage($gc, $crit, $extra);
            trek_hurt_foe($fi, $i, $dmg);
            trek_say($run, '✨ ' . $name . '’s ' . $label . ' hits ' . $foe['name'] . ' for ' . $dmg . ($crit ? ' (critical!)' : '') . '.');
            if ($calling === 'wayfinder') trek_break_hold_by($run, '🪃 The shot stings her claw, and she lets go!');
            elseif ($calling === 'thornblade') trek_break_hold_by($run, '💪 The heavy blow pries the claw open: the grab is broken!');
        } else {
            trek_say($run, '✨ ' . $name . '’s ' . $label . ' misses ' . $foe['name'] . '.');
        }
        return;
    }
    // attack
    $i = trek_foe_target($fi, $t);
    if ($i === null) { $fi['mem'][$slot]['guard'] = 1; trek_say($run, '🛡️ ' . $name . ' waits for an opening.'); return; }
    $foe = $fi['foes'][$i];
    [$raw, $tot, $crit] = attack_roll($gc, 0);
    if ($tot >= (int)$foe['def']) {
        $dmg = damage($gc, $crit);
        trek_hurt_foe($fi, $i, $dmg);
        trek_say($run, '⚔️ ' . $name . ' hits ' . $foe['name'] . ' for ' . $dmg . ($crit ? ' (critical!)' : '') . '.');
    } else {
        trek_say($run, '⚔️ ' . $name . ' misses ' . $foe['name'] . ' (rolled ' . $raw . ').');
    }
}

/** A foe attacks a random living member (the same roll and damage as the road's creature turn: combat_math.php). */
function trek_foe_attack(array &$run, array $stats, int $i, bool $always = false): void
{
    $live = trek_live_members($run);
    if (!$live) return;
    $foe = $run['fi']['foes'][$i];
    $slot = $live[array_rand($live)];
    $run['fi']['meta']['sick'] = (int)($foe['pz'] ?? 0) > 0 ? 1 : 0;
    if ($always || foe_hits((int)$foe['atk'], $stats[$slot]['gc']['ac'])) {
        trek_hurt_member($run, $slot, foe_damage((int)$foe['die'], (int)$foe['bonus']), $stats, $foe['name']);
        if (!empty($foe['blight']) && (int)$run['party'][$slot]['hp'] > 0) $run['fi']['mem'][$slot]['pz'] = 2;   // Blightlings poison: 1 a round for 2 rounds
    } else {
        trek_say($run, '🛡️ ' . $foe['name'] . ' misses ' . $stats[$slot]['name'] . '.');
    }
}

/** Foes act. Scripted bosses follow their pattern. */
function trek_foes_act(array &$run, array $stats): void
{
    $fi = &$run['fi'];
    $script = (string)$fi['meta']['script'];
    $round = (int)$fi['round'];
    $n = (int)$run['chapter'];
    $def = trek_script_def($script);
    $fi['meta']['sick'] = (int)($fi['foes'][0]['pz'] ?? 0) > 0 ? 1 : 0;   // v2.0.1: set again per foe in trek_foe_attack
    if ($def && isset($def['act'])) { $def['act']($run, $stats); return; }
    foreach ($fi['foes'] as $i => $f) {
        if ((int)$f['hp'] <= 0) continue;
        if (!trek_live_members($run)) return;
        trek_foe_attack($run, $stats, $i);
    }
}

/** The end of a round: poison ticks, cooldowns, guard drops, blight-mother adds, next round. */
function trek_round_end(array &$run, array $stats): void
{
    $fi = &$run['fi'];
    foreach ($fi['mem'] as $slot => $mm) {
        if (($mm['pz'] ?? 0) > 0 && (int)$run['party'][$slot]['hp'] > 0) {
            $run['party'][$slot]['hp'] = max(!empty($fi['meta']['duel']) ? 1 : 0, (int)$run['party'][$slot]['hp'] - 1);
            trek_say($run, '🧪 Blight poison stings ' . $stats[$slot]['name'] . ' for 1.');
        }
        $fi['mem'][$slot] = ['bark' => max(0, (int)$mm['bark'] - 1), 'cd' => max(0, (int)$mm['cd'] - 1), 'guard' => 0, 'pz' => max(0, (int)($mm['pz'] ?? 0) - 1)];
    }
    $def = trek_script_def((string)($fi['meta']['script'] ?? ''));
    if ($def && isset($def['round_end'])) $def['round_end']($run, $stats);
    $fi['round'] = (int)$fi['round'] + 1;
    if ($def && isset($def['after_round'])) $def['after_round']($run, $stats);
}

/**
 * Play one round. $acts = slot => ['a' => attack|ability|snack|guard, 't' => 'f:2' or 'a:1', 'item' => id]. Returns true if the fight is over.
 * Caller holds the transaction (trek_tx).
 */
function trek_fight_round(array &$run, array $u, array $acts): bool
{
    if (!$run['fi']) return true;
    $stats = trek_party_stats($run, $u);
    $fi = &$run['fi'];
    $fi['mem'] += array_fill_keys(array_keys($stats), ['bark' => 0, 'cd' => 0, 'guard' => 0, 'pz' => 0]);
    $sdef = trek_script_def((string)($fi['meta']['script'] ?? ''));
    if ($sdef && isset($sdef['round_start'])) $sdef['round_start']($run, $stats);
    foreach ($fi['foes'] as $i => $f) {   // poison on foes
        if ((int)$f['pz'] > 0 && (int)$f['hp'] > 0) {
            trek_hurt_foe($fi, $i, 3);
            $fi['foes'][$i]['pz'] = (int)$f['pz'] - 1;
            trek_say($run, '🧪 Poison stings ' . $f['name'] . ' for 3.');
        }
    }
    foreach (array_keys($stats) as $slot) {   // the party acts, in slot order
        if ((int)$run['party'][$slot]['hp'] <= 0) continue;
        if (!trek_foes_alive($fi)) break;
        trek_member_act($run, $u, $stats, $slot, (array)($acts[$slot] ?? ['a' => 'attack']));
    }
    if (!trek_foes_alive($fi)) { trek_fight_end($run, $u, true); return true; }
    trek_foes_act($run, $stats);
    if (!empty($fi['meta']['duel'])) {   // a duel ends when the foe or the whole party is down to 1 health
        if (!trek_foes_alive($fi)) { trek_fight_end($run, $u, true); return true; }
        if (!array_filter($run['party'], fn($p) => (int)$p['hp'] > 1)) { trek_fight_end($run, $u, false); return true; }
    } elseif (!trek_live_members($run)) {
        trek_fight_end($run, $u, false);
        return true;
    }
    trek_round_end($run, $stats);
    return false;
}

/** The whole party tries to get away: one roll with the best Nimble against the top foe level (combat_math.php flee_roll, as on the road). Not in a duel. */
function trek_fight_flee(array &$run, array $u): bool
{
    $fi = &$run['fi'];
    if (!$fi || !empty($fi['meta']['duel'])) return false;
    $stats = trek_party_stats($run, $u);
    $best = -99;
    foreach (trek_live_members($run) as $slot) $best = max($best, eff_mod($stats[$slot]['user'], 'nimble'));
    $level = max(array_map(fn($f) => (int)$f['lv'], $fi['foes']));
    if (flee_roll($best, $level)) {
        trek_say($run, '🏃 The party slips away. No reward.');
        $run['fi'] = null;
        unset($run['st']['bless']);
        return true;
    }
    trek_say($run, '🏃 You try to run, but you are cut off!');
    trek_foes_act($run, $stats);
    if (!trek_live_members($run)) { trek_fight_end($run, $u, false); return true; }
    trek_round_end($run, $stats);
    return false;
}

// ------------------------------------------------------------------ tactics + choosing for you (Auto)

/** v1.8.6 tactics: the words a member's tactics may use. Anything else becomes the default (first in each list). */
const TREK_TAC_OPEN = ['auto', 'ability', 'attack', 'guard'];
const TREK_TAC_TARGET = ['weak', 'strong', 'focus'];
const TREK_TAC_PCT = [40, 30, 50, 60];
const TREK_TAC_SNACK = [40, 30, 50];
const TREK_TAC_SHIELD = ['lowest', 'self', 'gnome'];
/** Ability rules by calling; the first is the default. Bloomcaller has only the heal line (pct). Damage callings use the last list. */
const TREK_TAC_RULES = [
    'rootwarden' => ['auto', 'big', 'foes2', 'friendlow', 'ready'],
    'bloomcaller' => ['heal'],
    'seedkeeper' => ['foes2', 'foes3'],
    '_dmg' => ['ready', 'healthy', 'boss'],
];

/** The rule words a calling can pick from ([] when it has no ability). */
function trek_tac_rules(string $calling): array
{
    return TREK_TAC_RULES[$calling] ?? (isset(TREK_ABILITIES[$calling]) ? TREK_TAC_RULES['_dmg'] : []);
}

/** Tactics from anything (saved or posted): every field checked against its whitelist for this calling, the rest default. Always the same shape. */
function trek_tac_clean(string $calling, bool $gnome, $raw): array
{
    $raw = is_array($raw) ? $raw : [];
    $pick = function (string $k, array $list) use ($raw) {
        $v = $raw[$k] ?? null;
        if (!is_scalar($v)) return $list[0];
        foreach ($list as $o) if ((string)$o === (string)$v) return $o;
        return $list[0];
    };
    $rules = trek_tac_rules($calling);
    $rule = $rules ? $pick('rule', $rules) : '';
    return [
        'open' => $pick('open', TREK_TAC_OPEN),
        'rule' => $rule,
        'pct' => $calling === 'bloomcaller' || ($calling === 'rootwarden' && $rule === 'friendlow') ? $pick('pct', TREK_TAC_PCT) : 40,
        'shield' => $calling === 'rootwarden' ? $pick('shield', TREK_TAC_SHIELD) : 'lowest',
        'target' => $pick('target', TREK_TAC_TARGET),
        'snack' => $gnome ? $pick('snack', TREK_TAC_SNACK) : 40,
    ];
}

/** The saved tactics of a party member ($m is a trek_party_stats row), checked and filled with defaults. Stored per run under st.tac[crew key]. */
function trek_tac_for(array $run, array $m): array
{
    return trek_tac_clean((string)$m['calling'], (int)$m['slot'] === 0, $run['st']['tac'][$m['key']] ?? []);
}

/**
 * Choices for every living member (Auto, Auto 1 and the preselected plan). Per member, the first that fits wins:
 * 1 snack (gnome, under its line)  2 heal (a ready Bloomcaller, a friend under the line: heal beats attacking)  3 Bark Skin (its rule)
 * 4 the round-1 opening move  5 the ability by its rule  6 attack the chosen foe (nobody to hit: guard).
 * Conflicts: a move on cooldown or with no valid target falls to the next step; two healers do not heal the same friend; Bark Skin skips a friend who already has it;
 * Poison skips a foe already poisoned; "focus" follows the gnome's foe (else the weakest). Never returns a move the round would refuse.
 */
function trek_fight_ai(array &$run, array $u): array
{
    $stats = trek_party_stats($run, $u);
    ksort($stats);
    $fi = $run['fi'];
    $acts = [];
    $boss = trek_boss_moves($fi);
    $big = $boss && in_array($boss[0], (array)(trek_script_def((string)($fi['meta']['script'] ?? ''))['big'] ?? []), true);
    $bossFight = !empty($fi['meta']['script']);
    $foesOk = trek_targetable_foes($fi);
    $round1 = (int)$fi['round'] === 1;
    $order = [];   // living friends, lowest health share first (a tie keeps the lower slot)
    foreach ($stats as $s => $m) if ((int)$run['party'][$s]['hp'] > 0) $order[$s] = (int)$run['party'][$s]['hp'] / $m['max'];
    asort($order);
    $under = function (int $pct) use ($order, $run, $stats): array {
        return array_values(array_filter(array_keys($order), fn($s) => (int)$run['party'][$s]['hp'] * 100 < $stats[$s]['max'] * $pct));
    };
    $pickFoe = function (string $pref, ?int $focus, bool $skipPoisoned) use ($fi, $foesOk): ?int {
        $pool = $foesOk;
        if ($skipPoisoned) {
            $clean = array_values(array_filter($pool, fn($i) => (int)($fi['foes'][$i]['pz'] ?? 0) <= 0));
            if ($clean) $pool = $clean;
        }
        if (!$pool) return null;
        if ($pref === 'focus' && $focus !== null && in_array($focus, $pool, true)) return $focus;
        usort($pool, fn($a, $b) => $pref === 'strong' ? (int)$fi['foes'][$b]['hp'] <=> (int)$fi['foes'][$a]['hp'] : (int)$fi['foes'][$a]['hp'] <=> (int)$fi['foes'][$b]['hp']);
        return $pool[0];
    };
    $healed = [];
    $barked = [];
    $focus = null;
    foreach ($stats as $slot => $m) {
        if ((int)$run['party'][$slot]['hp'] <= 0) continue;
        $tac = trek_tac_for($run, $m);
        $calling = (string)$m['calling'];
        $ready = isset(TREK_ABILITIES[$calling]) && (int)($fi['mem'][$slot]['cd'] ?? 0) === 0;
        $shieldTo = function (bool $byRule) use ($tac, $slot, $order, $under, $fi, &$barked): ?int {
            if ($tac['shield'] === 'self') $cands = [$slot];
            elseif ($tac['shield'] === 'gnome') $cands = isset($order[0]) ? [0] : [$slot];
            else $cands = $byRule && $tac['rule'] === 'friendlow' ? $under($tac['pct']) : array_keys($order);
            foreach ($cands as $c) if (empty($barked[$c]) && (int)($fi['mem'][$c]['bark'] ?? 0) <= 0) return $c;
            return null;
        };
        $a = null;
        // 1 snack
        if ($slot === 0 && (int)$run['party'][0]['hp'] * 100 < $m['max'] * $tac['snack'] && (int)$fi['snacks'] < snack_limit($u) && ($snacks = fight_snacks($u))) {
            $a = ['a' => 'snack', 'item' => $snacks[0]['id']];
        }
        // 2 heal (always beats attacking)
        if ($a === null && $calling === 'bloomcaller' && $ready) {
            foreach ($under($tac['pct']) as $s2) {
                if (!empty($healed[$s2])) continue;
                $healed[$s2] = 1;
                $a = ['a' => 'ability', 't' => 'a:' . $s2];
                break;
            }
        }
        // 3 Bark Skin: first on the friend a boss is holding (it breaks the hold), then by its rule
        $held = isset($fi['meta']['held']) ? (int)$fi['meta']['held'] : null;
        if ($a === null && $calling === 'rootwarden' && $ready && $held !== null && isset($order[$held]) && empty($barked[$held])) {
            $barked[$held] = 1;
            $a = ['a' => 'ability', 't' => 'a:' . $held];
        }
        if ($a === null && $calling === 'rootwarden' && $ready) {
            $on = match ($tac['rule']) {
                'big' => (bool)$big,
                'foes2' => count($foesOk) >= 2,
                'friendlow' => (bool)$under($tac['pct']),
                'ready' => true,
                default => $big || ($boss === null && count($foesOk) >= 2),
            };
            $to = $on ? $shieldTo(true) : null;
            if ($to !== null) { $barked[$to] = 1; $a = ['a' => 'ability', 't' => 'a:' . $to]; }
        }
        // 4 the round-1 opening move; 5 the ability by its rule
        $ability = function (bool $open) use ($calling, $tac, $foesOk, $order, $under, $run, $stats, $pickFoe, &$focus, &$healed, &$barked, $shieldTo, $bossFight, $fi): ?array {
            switch ($calling) {
                case 'bloomcaller':   // the heal itself is step 2; as an opener it heals the friend most hurt
                    if (!$open) return null;
                    foreach (array_keys($order) as $s2) {
                        if (!empty($healed[$s2]) || (int)$run['party'][$s2]['hp'] >= $stats[$s2]['max']) continue;
                        $healed[$s2] = 1;
                        return ['a' => 'ability', 't' => 'a:' . $s2];
                    }
                    return null;
                case 'rootwarden':
                    if (!$open) return null;
                    $to = $shieldTo(false);
                    if ($to === null) return null;
                    $barked[$to] = 1;
                    return ['a' => 'ability', 't' => 'a:' . $to];
                case 'seedkeeper':
                    if ($foesOk && ($under(75) || isset($fi['meta']['held']))) return ['a' => 'ability'];   // v2.0.1: the spores mend (a hurt friend is reason enough) and make a boss let go
                    return count($foesOk) >= ($open ? 1 : ($tac['rule'] === 'foes3' ? 3 : 2)) ? ['a' => 'ability'] : null;
                case 'thornblade': case 'wayfinder': case 'brewroot': case '':
                    $f = $pickFoe($tac['target'], $focus, $calling === 'brewroot');
                    if ($f === null) return null;
                    if (!$open) {
                        if ($tac['rule'] === 'healthy' && (int)$fi['foes'][$f]['hp'] * 2 <= (int)$fi['foes'][$f]['max']) return null;
                        if ($tac['rule'] === 'boss' && !$bossFight) return null;
                    }
                    return ['a' => 'ability', 't' => 'f:' . $f];
            }
            return null;
        };
        if ($a === null && $round1 && $tac['open'] !== 'auto') {
            if ($tac['open'] === 'guard') $a = ['a' => 'guard'];
            elseif ($tac['open'] === 'attack') {
                $f = $pickFoe($tac['target'], $focus, false);
                if ($f !== null) $a = ['a' => 'attack', 't' => 'f:' . $f];
            } elseif ($ready) $a = $ability(true);
        }
        if ($a === null && $ready) $a = $ability(false);
        // 6 attack
        if ($a === null) {
            $f = $pickFoe($tac['target'], $focus, false);
            $a = $f !== null ? ['a' => 'attack', 't' => 'f:' . $f] : ['a' => 'guard'];
        }
        if ($slot === 0 && in_array($a['a'], ['attack', 'ability'], true) && str_starts_with((string)($a['t'] ?? ''), 'f:')) $focus = (int)substr($a['t'], 2);
        $acts[$slot] = $a;
    }
    return $acts;
}

/** v1.8.5: foe names as the fight screen shows them (two of a kind get a number). */
function trek_foe_names(array $fi): array
{
    $seen = array_count_values(array_map(fn($f) => (string)$f['name'], $fi['foes']));
    $at = [];
    $out = [];
    foreach ($fi['foes'] as $i => $f) {
        $n = (string)$f['name'];
        if (($seen[$n] ?? 0) < 2) { $out[$i] = $n; continue; }
        $at[$n] = ($at[$n] ?? 0) + 1;
        $out[$i] = $n . ' ' . $at[$n];
    }
    return $out;
}

/** v1.8.6: a foe that always has its own row: the boss of a scripted fight, a duel foe, a boss-size creature. */
function trek_foe_own(array $fi, int $i): bool
{
    return ($i === 0 && !empty($fi['meta']['script'])) || !empty($fi['meta']['duel']) || (string)($fi['foes'][$i]['size'] ?? '') === 'boss';
}

/**
 * v1.8.6: living foes as screen rows. Foes of one kind share a row (a boss always has its own). Returns a list of
 * ['gid' (lowest foe index), 'name', 'icon', 'idx' (living), 'ok' (can be hit now), 'weak' (weakest of ok, or null), 'show' (lowest health, living), 'own'].
 */
function trek_foe_groups(array $fi): array
{
    $g = [];
    foreach ($fi['foes'] as $i => $f) {
        if ((int)$f['hp'] <= 0) continue;
        $own = trek_foe_own($fi, (int)$i);
        $k = $own ? 'o' . $i : 'n' . (string)$f['name'];
        $g[$k] ??= ['gid' => (int)$i, 'name' => (string)$f['name'], 'icon' => (string)$f['icon'], 'idx' => [], 'ok' => [], 'weak' => null, 'show' => (int)$i, 'own' => $own];
        $g[$k]['idx'][] = (int)$i;
        if ((int)$f['hp'] < (int)$fi['foes'][$g[$k]['show']]['hp']) $g[$k]['show'] = (int)$i;
    }
    $okAll = trek_targetable_foes($fi);
    foreach ($g as $k => $row) {
        $g[$k]['ok'] = array_values(array_intersect($row['idx'], $okAll));
        foreach ($g[$k]['ok'] as $i) if ($g[$k]['weak'] === null || (int)$fi['foes'][$i]['hp'] < (int)$fi['foes'][$g[$k]['weak']]['hp']) $g[$k]['weak'] = $i;
    }
    return array_values($g);
}

/** v1.8.5: foes and party as [name, icon, hp, max] rows, for the Auto replay. $fi may be the fight as it stood (the run's own is gone once it ends). */
function trek_replay_snap(array &$run, array $u, array $fi, bool $over = false): array
{
    $names = trek_foe_names($fi);
    $f = [];
    foreach ($fi['foes'] as $i => $x) $f[] = [$names[$i], (string)$x['icon'], $over && !empty($GLOBALS['trek_won']) ? 0 : max(0, (int)$x['hp']), (int)$x['max'], trek_foe_own($fi, (int)$i) ? 1 : 0, (string)$x['name']];   // v1.8.6: [4] own row, [5] plain name (the replay groups foes of one kind)
    $p = [];
    foreach (trek_party_stats($run, $u) as $slot => $m) $p[] = [trek_short_name((string)$m['name']), (string)$m['icon'], max(0, (int)$run['party'][$slot]['hp']), (int)$m['max'], (int)$slot === 0 ? 1 : 0];   // v1.9.0: [4] the player's own gnome (its drawing comes from the page)
    return ['f' => $f, 'p' => $p];
}

/** Auto: play rounds with the AI until the fight ends, the party is in trouble (under 30% health overall), or 40 rounds.
 *  v1.8.5: with $rec it also notes each round for assets/trekfight.js to play back (the maths is untouched); see trek_replay_take(). */
function trek_fight_auto(array &$run, array $u, int $rounds = 40, bool $rec = false): void
{
    $rep = null;
    $fi0 = null;
    $mark = 0;
    $cap = function () use (&$rep, &$run, $u, &$fi0, &$mark): void {
        $fi = $run['fi'] ?: ($GLOBALS['trek_last_fi'] ?? $fi0);
        $snap = trek_replay_snap($run, $u, $fi, !$run['fi']);
        $new = max(0, (int)($GLOBALS['trek_said'] ?? 0) - $mark);
        $mark = (int)($GLOBALS['trek_said'] ?? 0);
        $lines = [];
        foreach (array_slice($run['lg'], -min($new, count($run['lg']))) as $l) { $t = trek_line_html($l); if ($t !== '') $lines[] = $t; }
        $r = ['l' => $lines, 'f' => array_column($snap['f'], 2), 'p' => array_column($snap['p'], 2)];
        if (count($snap['f']) > count($rep['s']['f'])) $r['nf'] = array_slice($snap['f'], count($rep['s']['f']));
        if ($r['nf'] ?? null) $rep['s']['f'] = array_merge($rep['s']['f'], $r['nf']);
        $rep['r'][] = $r;
    };
    if ($rec && $run['fi']) {
        $fi0 = $run['fi'];
        $GLOBALS['trek_last_fi'] = null;
        $GLOBALS['trek_won'] = false;
        $mark = (int)($GLOBALS['trek_said'] ?? 0);
        $rep = ['run' => (int)$run['id'], 't' => time(), 's' => trek_replay_snap($run, $u, $fi0) + ['n' => (int)$fi0['round']], 'r' => []];
    } else {
        $rec = false;
    }
    for ($i = 0; $i < $rounds; $i++) {
        if (!$run['fi']) break;
        $over = trek_fight_round($run, $u, trek_fight_ai($run, $u));
        if ($over) { if ($rec) $cap(); break; }
        if ($rounds > 1) {
            $stats = trek_party_stats($run, $u);
            $hp = array_sum(array_map(fn($p) => (int)$p['hp'], $run['party']));
            if ($hp * 100 < array_sum(array_map(fn($m) => $m['max'], $stats)) * 30) {
                trek_say($run, '⏩ Auto stops: the party is in trouble. Choose each move.');
                if ($rec) $cap();
                break;
            }
        }
        if ($i === $rounds - 1 && $rounds > 1 && $run['fi']) trek_say($run, '⏩ Auto pauses after ' . $rounds . ' rounds.');
        if ($rec) $cap();
    }
    if ($rec && $rep['r']) $_SESSION['trek_replay'] = $rep;
}

// ------------------------------------------------------------------ the end of a fight

function trek_fight_end(array &$run, array $u, bool $won): void
{
    $fi = $run['fi'];
    $meta = $fi['meta'];
    $GLOBALS['trek_last_fi'] = $fi;   // v1.8.5: the Auto replay's last picture of the foes
    $GLOBALS['trek_won'] = $won;
    unset($run['st']['bless']);   // v1.8.8: the shrine's thanks lasts one fight
    if (!empty($GLOBALS['trek_sim'])) { $GLOBALS['trek_sim_won'] = $won; $run['fi'] = null; return; }   // tests/trek_levels.php balance sim only: record the result, touch nothing else
    if (!empty($meta['duel'])) { trek_duel_end($run, $u, $won); return; }
    if ($won) trek_fight_win($run, $u); else trek_ko($run, $u);
}

/** A duel stops at 1 health: nothing is lost either way. Winning brings the trailmate in; losing is a free retry. */
function trek_duel_end(array &$run, array $u, bool $won): void
{
    $fi = $run['fi'];
    $spot = trek_spots((int)$run['chapter'])[$fi['meta']['spot']];
    $run['fi'] = null;
    trek_heal_party($run, $u);
    $n = (int)$run['chapter'];
    if ($won) {
        trek_flag_set($run, (string)$spot['data']['flag']);
        $in = trek_recruit_crew($run, $u, (string)$spot['data']['crew']);
        $wname = trek_crew_npc((string)$spot['data']['crew'])['name'];
        trek_say_text($run, 'ch' . $n . '.spot.' . $spot['code'] . '.win', ['trailmate' => $wname]);
        if (!$in) trek_say($run, trek_benched_line((string)$wname));
        trek_scene_recruit($run, $u, (string)$spot['data']['crew'], 'ch' . $n . '.spot.' . $spot['code'] . '.win', 'ch' . $n . '.scene.' . $spot['data']['crew'] . '.me', ['trailmate' => $wname]);   // v2.0.8
        trek_say($run, '🏅 Duel won! The party is back on its feet.');
        trek_tl_give($run, $u, trek_fight_xp($fi['foes']), true);   // v1.8.9: trek XP for a duel too (the foe counts as medium)
        trek_ms_award($run, $u, 'bracken');
    } else {
        trek_say_text($run, 'ch' . $n . '.spot.' . $spot['code'] . '.lose');
        trek_say($run, '🏳️ Duel lost. No harm done: the party is healed and you may try again.');
    }
}

/**
 * v1.8.8: how many of $want Petals the daily trek Petal limit (trek_petals_daily per Hollow day) still allows; counts them as used. The caller adds them to petals_found.
 * v1.9.1: the count is per PLAYER (users.trek_pet_day / trek_pet_today), shared by every chapter. It used to sit in each run's state, which a new chapter would reset.
 * The caller holds the users row lock (trek_tx). A count still in the run's state (before the upgrade) is taken over once.
 */
function trek_petals_capped(array &$run, int $want): int
{
    $pday = hollow_date('Y-m-d');
    $uid = (int)$run['user_id'];
    $have = 0;
    $stored = true;
    try {
        $r = q_one('SELECT trek_pet_day, trek_pet_today FROM users WHERE id = ?', [$uid]) ?: [];
        $day = $r['trek_pet_day'] ?? null;
        $have = (int)($r['trek_pet_today'] ?? 0);
        if ($day === null && isset($run['st']['pet_day'])) { $day = (string)$run['st']['pet_day']; $have = (int)($run['st']['pet_today'] ?? 0); }   // an old run's count
        if ($day !== $pday) $have = 0;
    } catch (Throwable $e) {   // the column is not there yet: keep it in the run as before
        $stored = false;
        $have = (($run['st']['pet_day'] ?? '') === $pday) ? (int)($run['st']['pet_today'] ?? 0) : 0;
    }
    $paid = max(0, min($want, max(0, (int)setting('trek_petals_daily')) - $have));
    if ($stored) {
        q('UPDATE users SET trek_pet_day = ?, trek_pet_today = ? WHERE id = ?', [$pday, $have + $paid, $uid]);
        unset($run['st']['pet_day'], $run['st']['pet_today']);
    } else {
        $run['st']['pet_day'] = $pday;
        $run['st']['pet_today'] = $have + $paid;
    }
    return $paid;
}

/**
 * v2.0.1: may one more item found in a fight be carried today? Setting trek_items_daily (0 = no limit, nothing counted) per player per Hollow day, shared by every chapter,
 * counted in users.trek_item_day / trek_item_today (the caller holds the users row lock, trek_tx). Quest and key items never go through this. Falls back to the run's state if the columns are missing.
 */
function trek_item_allowed(array &$run): bool
{
    $cap = max(0, (int)setting('trek_items_daily'));
    if ($cap === 0) return true;
    $day = hollow_date('Y-m-d');
    $uid = (int)$run['user_id'];
    $stored = true;
    try {
        $r = q_one('SELECT trek_item_day, trek_item_today FROM users WHERE id = ?', [$uid]) ?: [];
        $have = (($r['trek_item_day'] ?? null) === $day) ? (int)($r['trek_item_today'] ?? 0) : 0;
    } catch (Throwable $e) {
        $stored = false;
        $have = (($run['st']['item_day'] ?? '') === $day) ? (int)($run['st']['item_today'] ?? 0) : 0;
    }
    if ($have >= $cap) return false;
    if ($stored) q('UPDATE users SET trek_item_day = ?, trek_item_today = ? WHERE id = ?', [$day, $have + 1, $uid]);
    else { $run['st']['item_day'] = $day; $run['st']['item_today'] = $have + 1; }
    return true;
}

/** Won: XP, loot into the pack (at risk until banked), maybe Petals, fatigue, and anything the spot's script does. */
function trek_fight_win(array &$run, array $u): void
{
    require_once __DIR__ . '/jobs.php';
    $uid = (int)$u['id'];
    $fi = $run['fi'];
    $meta = $fi['meta'];
    $n = (int)$run['chapter'];
    $stats = trek_party_stats($run, $u);
    $real = array_values(array_filter($fi['foes'], fn($f) => empty($f['add'])));
    $area = max(array_map(fn($f) => (int)$f['lv'], $real));
    $txp = trek_fight_xp($real);   // v1.8.9: trek XP for everyone who fought (uncapped); the gnome's main XP now comes only from milestones
    trek_say($run, '🏆 Defeated ' . implode(', ', array_map(fn($f) => $f['name'], $real)) . '! +' . $txp . ' trek XP.');
    trek_tl_give($run, $u, $txp, true);
    $luckBonus = max(0, luck_mod($u)) * 2;
    $drops = [];
    $capped = false;
    foreach ($real as $f) {
        job_event($uid, 'defeat', $f['slug'], 1, ['size' => $f['size'], 'peaceful' => 0]);
        if ($f['cid'] && unlock_entries($uid, 'creature:' . $f['slug'])) trek_say($run, '📖 New Almanac page: ' . $f['name'] . '!');
        if (in_array($f['slug'], TREK_CLAYBOUND, true) && unlock_entries($uid, 'trek:claybound')) trek_say($run, '📖 New Almanac page: The Claybound!');
        foreach (q('SELECT * FROM creature_drops WHERE creature_id = ?', [$f['cid']])->fetchAll() as $dr) {
            if (!$dr['item_id'] || random_int(1, 100) > min(100, (int)$dr['chance'] + $luckBonus)) continue;
            if (!trek_is_quest_item((int)$dr['item_id']) && !trek_item_allowed($run)) { $capped = true; continue; }   // v2.0.1: daily item cap
            trek_pack_add((int)$run['id'], (int)$dr['item_id'], 1);
            $drops[] = trek_item_name((int)$dr['item_id']);
        }
        $g = TREK_GUARANTEE[$f['slug']] ?? null;   // the key and the dew: a few kills always give one
        $zone = (string)($meta['zone'] ?? '');
        if ($g && $n === (int)($g[4] ?? 1) && $zone === $g[2] && !trek_flag($run, $g[3])) {   // (the key and the dew are Chapter I's; a 5th field names another chapter)
            $iid = trek_item_id($g[0]);
            $want = !in_array($g[0], ['cellar-key', 'kiln-key'], true) || trek_pack_qty((int)$run['id'], $iid) === 0;
            if ($want && $g[0] === 'clean-dew' && trek_pack_qty((int)$run['id'], $iid) >= 3) $want = false;
            if ($want) {
                $run['st']['kills'][$f['slug']] = (int)($run['st']['kills'][$f['slug']] ?? 0) + 1;
                if ($run['st']['kills'][$f['slug']] >= $g[1]) {
                    $run['st']['kills'][$f['slug']] = 0;
                    trek_pack_add((int)$run['id'], $iid, 1);
                    $drops[] = trek_item_name($iid);
                }
            }
        }
    }
    if ($drops) trek_say($run, '🎁 Loot (carried, bank it at a camp): ' . implode(', ', $drops) . '.');
    if ($capped) trek_say($run, '🎒 You have found all you can carry today. Anything else is left on the trail.');
    if (random_int(1, 100) <= 40) {   // like give_find: Petals on the ground, 5-15 plus 2 a level, cut if the area is outgrown
        $coins = outlevel_scale(random_int(5, 15) + 2 * $area, outlevel_percent(trek_gnome_user($u), $area));
        $coins = trek_petals_capped($run, $coins);   // v1.8.1: daily Petal cap (fights cost no energy); v1.8.8: shared with trail events
        if ($coins > 0) {
            $run['petals_found'] = (int)$run['petals_found'] + $coins;
            trek_say($run, '🪙 You find ' . $coins . ' ' . setting('currency_name') . ' (carried).');
        }
    }
    $rounds = max(0, (int)$fi['round'] - 1);
    $run['fatigue'] = min(100, (int)$run['fatigue'] + 3 + 2 * max(0, $rounds - 5));
    foreach ($run['party'] as $slot => $p) {   // fallen friends get back up (a quarter of their health)
        if ((int)$p['hp'] <= 0) $run['party'][$slot]['hp'] = max(1, (int)ceil($stats[$slot]['max'] * 0.25));
    }
    $first = !trek_flag($run, 'won_fight');
    trek_flag_set($run, 'won_fight');
    if ($first && $n === 1) trek_say_text($run, 'ch' . $n . '.tut.firstfight');   // v2.0.4: Chapter I's lesson only (Chapter II runs start without the flag)
    $after = (string)$meta['after'];
    $run['fi'] = null;
    if ($after === 'rest') { trek_apply_rest($run, $u, true); trek_say_text($run, 'ch' . $n . '.camp.makecamp.free'); trek_say($run, '🏕️ A cold rest. Fatigue −' . trek_cold_rest_fatigue() . ', everyone heals a quarter of their health.'); }
    if ($after === 'oldrest') trek_oldcamp_after_fight($run, $u, $n);   // v2.0.1: the rest an old campsite ambush interrupted
    $script = (string)$meta['script'];
    $spot = $meta['spot'] ? (trek_spots($n)[$meta['spot']] ?? null) : null;
    $sdef = trek_script_def($script);
    if ($spot && $sdef && isset($sdef['win'])) $sdef['win']($run, $u, $spot, $n);
    foreach (check_milestones($uid) as $mm) trek_say($run, $mm);
}
