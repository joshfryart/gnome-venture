<?php
declare(strict_types=1);

/**
 * v2.0.5 Shared combat maths. The road fights (adventure.php combat_turn) and the Trek party fights (trek_fight.php) both roll their dice
 * and do their sums here. Pure: inputs in, numbers out; no database, no settings, no globals. The only outside call is random_int() (through d()).
 * The ORDER of the random calls in each function is part of the contract (tests/combat_math_golden.php replays seeded fights and compares them
 * with tests/combat_golden.json), so do not reorder a roll or skip one that used to happen.
 * What differs on purpose stays in the engines: the road is one gnome against one creature, a trek is a party against several foes with chapter
 * tuning (TREK_TUNE rows), party health growth, abilities and boss scripts. Those pass their numbers in as parameters.
 */

/** One die: 1..$sides. */
function d(int $sides): int
{
    return random_int(1, max(1, $sides));
}

/**
 * A d20 attack: [natural roll, roll + attack + bonus, crit?]. $gc = a combat block (atk, crit_from, luck_crit). Advantage rolls twice and keeps the best.
 * A crit is a natural roll of crit_from or more, or a luck crit (luck_crit % of any attack; the luck roll is only made when the natural roll was no crit).
 */
function attack_roll(array $gc, int $bonus, bool $advantage = false): array
{
    $r = d(20);
    if ($advantage) $r = max($r, d(20));
    $crit = $r >= $gc['crit_from'] || random_int(1, 1000000) <= (int)round((float)($gc['luck_crit'] ?? 0) * 10000);
    return [$r, $r + $gc['atk'] + $bonus, $crit];
}

/** The damage of a hit: one damage die + bonus + $extra, and a second die on a crit; never under 1. */
function damage(array $gc, bool $crit, int $extra = 0): int
{
    $dmg = d($gc['dmg_die']) + $gc['dmg_bonus'] + $extra;
    if ($crit) $dmg += d($gc['dmg_die']);
    return max(1, $dmg);
}

/** A foe's attack roll against an armour class: d20 + its attack reaches the armour (nobody auto-hits or auto-misses). */
function foe_hits(int $attack, int $ac): bool
{
    return d(20) + $attack >= $ac;
}

/** A foe's damage on a hit: its damage die + bonus, never under 1. (Bark Skin, Guard, boss moves and the like are the engine's own business.) */
function foe_damage(int $die, int $bonus): int
{
    return max(1, d($die) + $bonus);
}

/** Can the runner get away? d20 + the best Nimble modifier must reach 8 + a third of the foe's level (the top foe level, in a party fight). */
function flee_roll(int $nimble, int $foeLevel): bool
{
    return d(20) + $nimble >= 8 + intdiv($foeLevel, 3);
}

/** $n scaled by a percent (rounded, never under 1): a creature's eased health, a bigger party's extra health, a chapter's tune. */
function combat_pct(int $n, int|float $pct): int
{
    return max(1, (int)round($n * $pct / 100));
}

/**
 * v0.7.64: a creature grown stronger to fit a higher level (there are no ordinary creatures above level 22).
 * Follows the curve of the existing ones: about +5.5 health, +0.4 attack and defence, +0.25 damage and +10 XP a level.
 */
function scale_creature(array $c, int $toLevel, int $pct = 100, int $hpPct = 100): array
{
    $d = $toLevel - (int)$c['level'];
    if ($d <= 0) return $c;
    // v0.7.74: $pct eases the per-level growth, $hpPct eases health on top (bosses and the wild stay at 100)
    $f = $pct / 100;
    $c['hp'] = (int)$c['hp'] + (int)round(5.5 * $d * $f);
    $c['attack'] = (int)$c['attack'] + (int)round(0.4 * $d * $f);
    $c['defense'] = (int)$c['defense'] + (int)round(0.4 * $d * $f);
    $c['dmg_bonus'] = (int)$c['dmg_bonus'] + (int)round(0.25 * $d * $f);
    if ($hpPct < 100) $c['hp'] = max(1, (int)round($c['hp'] * $hpPct / 100));
    $c['xp'] = (int)$c['xp'] + 10 * $d;
    $c['level'] = $toLevel;
    $c['_scaled'] = true;
    $c['_pct'] = $pct;
    $c['_hpp'] = $hpPct;
    return $c;
}
