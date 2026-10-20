<?php
declare(strict_types=1);

/**
 * v1.8.9 Treks: trek levels and milestone XP.
 *
 * TREK LEVELS (inside treks only). Every party member (the gnome and each trailmate) has a trek level (1 up) and trek XP, kept in the run state
 * under st.tl[crew key] = [level, xp toward the next level] (the gnome is "gnome"). Base stats still come from the gnome's main level; a trek level only
 * adds on top of them in trek_party_stats(): +max health, +to hit, +damage (see trek_tl_bonus()). Trek XP is never capped. It comes from won fights
 * (and a little from trail events); it never touches the gnome's main XP.
 *
 * MAIN XP comes only from MILESTONES (Burdock, Zinnia, Bracken, the Blight Mother, Gloomtooth, the end of the chapter): once each, ever, per player.
 * A paid milestone is written to trek_ms (one row per player and milestone), which the admin run reset does not clear, so it is never paid twice.
 * Pay = base x (0.5 + 0.5 x checks done / checks that apply by then). See trek_ms_checks().
 *
 * XP CURVE (tuned with tests/trek_levels.php, which prints the route numbers): a level costs 44 XP, then 16 more for each level
 * (Lv1->2 44, Lv2->3 60, Lv3->4 76 ... Lv9->10 172; Lv5 at 272 XP in all, Lv6 380, Lv7 504, Lv8 644, Lv9 800). Walking the whole chapter in hunting mode
 * is about 19 fights on the main path (a few more with detours): about 410 XP when the Blight Mother is reached (trek Lv6), +160 for her, so about Lv7-8 at
 * Gloomtooth, and Lv8-9 at the end (+160 for him).
 * A fight pays 10 XP for a small foe, 14 medium, 24 large, 160 for a boss (a duel counts as medium); a member who is down at the end gets half;
 * a member below the party's average trek level earns +50% (catch-up). A new trailmate joins at (party average - 2), at least 1.
 * Leveling up heals that member a quarter of their health.
 */

const TREK_TL_MAX = 23;   // v2.0.20: was 20
const TREK_TL_HP_PCT = 6;       // +max health per level gained, % of the base health
const TREK_TL_NEED_BASE = 44;   // XP to go from level 1 to 2
const TREK_TL_NEED_STEP = 16;   // ...and this much more for each level after
const TREK_FOE_XP = ['small' => 10, 'medium' => 14, 'large' => 24, 'boss' => 160];

/** XP needed to go from level $lv to $lv + 1. */
function trek_tl_need(int $lv): int
{
    return TREK_TL_NEED_BASE + TREK_TL_NEED_STEP * (max(1, $lv) - 1);
}

/** [level, xp] of a crew key (the gnome is "gnome"); a member with no entry is level 1. */
function trek_tl_get(array $run, string $key): array
{
    $t = $run['st']['tl'][$key] ?? null;
    if (!is_array($t)) return [1, 0];
    return [max(1, min(TREK_TL_MAX, (int)($t[0] ?? 1))), max(0, (int)($t[1] ?? 0))];
}

/** What a trek level adds: ['hp' (of $baseHp), 'atk', 'dmg']. */
function trek_tl_bonus(int $lv, int $baseHp): array
{
    $lv = max(1, $lv);
    return ['hp' => (int)round($baseHp * TREK_TL_HP_PCT / 100 * ($lv - 1)), 'atk' => intdiv($lv, 2), 'dmg' => intdiv($lv, 3)];
}

/** The party's average trek level (members in the party now). */
function trek_tl_avg(array $run): float
{
    $sum = 0;
    $n = 0;
    foreach ($run['party'] as $p) { $sum += trek_tl_get($run, (string)$p['crew_key'])[0]; $n++; }
    return $n ? $sum / $n : 1.0;
}

/** A trailmate joining for the first time starts here: party average - 2, at least 1. (Someone who was in the party before keeps their level.) */
function trek_tl_join(array &$run, string $key): void
{
    if (isset($run['st']['tl'][$key])) return;
    $run['st']['tl'][$key] = [max(1, (int)round(trek_tl_avg($run)) - 2), 0];
}

/** Trek XP a fight is worth: by foe size (adds give none). */
function trek_fight_xp(array $foes): int
{
    $xp = 0;
    foreach ($foes as $f) if (empty($f['add'])) $xp += TREK_FOE_XP[(string)($f['size'] ?? 'small')] ?? 10;
    return $xp;
}

/**
 * Give trek XP to the party. Each member gets $xp (half if down and $halfDown, nothing if down and not $halfDown), +50% below the party average.
 * Level-ups are logged and heal that member a quarter. Returns the lines' count of level-ups.
 */
function trek_tl_give(array &$run, array $u, int $xp, bool $halfDown = false): int
{
    if ($xp <= 0 || !$run['party']) return 0;
    $avg = trek_tl_avg($run);
    $ups = [];
    foreach ($run['party'] as $slot => $p) {
        $down = (int)$p['hp'] <= 0;
        if ($down && !$halfDown) continue;
        $key = (string)$p['crew_key'];
        [$lv, $have] = trek_tl_get($run, $key);
        $gain = $xp * ($down ? 0.5 : 1) * ($lv < $avg - 0.0001 ? 1.5 : 1);
        $have += max(1, (int)round($gain));
        $from = $lv;
        while ($lv < TREK_TL_MAX && $have >= trek_tl_need($lv)) { $have -= trek_tl_need($lv); $lv++; }
        if ($lv >= TREK_TL_MAX) $have = 0;
        $run['st']['tl'][$key] = [$lv, $have];
        if ($lv > $from) $ups[(int)$slot] = $lv;
    }
    if ($ups) {
        if ((int)$run['chapter'] === 1 && !trek_flag($run, 'tut_tl')) { trek_flag_set($run, 'tut_tl'); trek_say_text($run, 'ch1.tut.treklevel'); }   // v2.0.4: Chapter I's lesson only
        $stats = trek_party_stats($run, $u);   // the new maximum health
        foreach ($ups as $slot => $lv) {
            if ((int)$run['party'][$slot]['hp'] > 0) $run['party'][$slot]['hp'] = min($stats[$slot]['max'], (int)$run['party'][$slot]['hp'] + (int)ceil($stats[$slot]['max'] * 0.25));
            trek_say($run, '⬆️ ' . trek_first_name_of((string)$stats[$slot]['name']) . ' reaches trek level ' . $lv . '!');
        }
    }
    return count($ups);
}

// ------------------------------------------------------------------ milestones

// v1.9.1: the milestones of each chapter are data (trek_chapters*.txt, trek_milestones($chapter)); Chapter I's keys are burdock, zinnia, bracken, mother,
// gloomtooth, chapter. A later chapter's keys are unique too (ch2_sorrel ...), since a paid milestone is one trek_ms row per player and key.

/** Make sure the once-only table exists (an upgrade that has not run yet). Call it outside a transaction. */
function trek_ms_ensure(): void
{
    static $ok = false;
    if ($ok) return;
    try {
        q('SELECT 1 FROM trek_ms LIMIT 1');
    } catch (Throwable $e) {
        $sqlite = db()->getAttribute(PDO::ATTR_DRIVER_NAME) === 'sqlite';
        foreach (trek_ms_schema($sqlite ? 'INTEGER' : 'INT UNSIGNED', $sqlite ? '' : ' ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci') as $sql) q($sql);
    }
    $ok = true;
}

/** The statements for the once-only table: one row per player and milestone, never deleted by a run reset. */
function trek_ms_schema(string $ID, string $END): array
{
    return ["CREATE TABLE IF NOT EXISTS trek_ms (
        user_id $ID NOT NULL,
        ms_key VARCHAR(60) NOT NULL,
        xp INT NOT NULL DEFAULT 0,
        done INT NOT NULL DEFAULT 0,
        total INT NOT NULL DEFAULT 0,
        paid_at DATETIME NOT NULL,
        PRIMARY KEY (user_id, ms_key)
    )$END"];
}

/**
 * The checks that apply when a milestone is reached, over the chapter so far: [done, total, [label => bool]]. A check with nothing to judge yet is left out.
 * Chapter I is coded below. A later chapter lists its checks in trek_chapters*.txt ("check" rows: any-flag checks and the trail-event count) plus "No knock-out".
 *  - no knock-out so far (always)
 *  - side stops visited: the Stuck Cart and Mushroom Camp (from Zinnia on), the Riddle Stone (from Bracken on), the Glowworm Grotto (a Wayfinder only)
 *  - trail events resolved: 3 or more (from Zinnia on)
 *  - riddles solved: the Worm Choir (from Zinnia on), the Riddle Stone (from Bracken on)
 *  - crew moments taken: every trailmate whose moment came up has taken it
 */
function trek_ms_checks(array $run, array $u, string $name): array
{
    $ch = (int)$run['chapter'];
    $order = array_keys(trek_milestones($ch));
    $at = (int)array_search($name, $order, true);   // Chapter I: 0 burdock ... 5 chapter
    $c = ['No knock-out' => empty($run['st']['kos'])];
    if ($ch !== 1) {
        foreach (trek_chapter($ch)['checks'] as [$label, $type, $arg, $from]) {
            if ($at < $from) continue;
            if ($type === 'evn') { $c[$label] = (int)($run['st']['evn'] ?? 0) >= (int)$arg; continue; }
            if ($type === 'crew') {   // v1.9.2: every trailmate whose moment came up has taken it (nothing came up: not judged)
                $fired = [];
                foreach (array_keys(TREK_CREW_BEATS) as $k) if (trek_flag($run, 'cm_' . $k)) $fired[] = $k;
                if ($fired) $c[$label] = !array_filter($fired, fn($k) => !trek_flag($run, 'cmt_' . $k));
                continue;
            }
            $flags = array_filter(array_map('trim', explode(',', $arg)));
            if ($type === 'all') { $c[$label] = !array_filter($flags, fn($f) => !trek_flag($run, $f)); continue; }   // v1.9.2: every flag
            $any = false;
            foreach ($flags as $f) if (trek_flag($run, $f)) $any = true;
            $c[$label] = $any;
        }
        return [count(array_filter($c)), count($c), $c];
    }
    if ($at >= 1) {
        $stops = [['cart_done', 'seen_cart'], ['mush_done', 'seen_mushcamp']];
        if ($at >= 2) $stops[] = ['stone_solved', 'seen_bridgestone'];
        if ($at >= 3 && (trek_flag($run, 'grotto_found') || trek_has_wayfinder($run, $u))) $stops[] = ['grotto_found'];
        $ok = true;
        foreach ($stops as $fl) {
            $any = false;
            foreach ($fl as $f) if (trek_flag($run, $f)) $any = true;
            if (!$any) $ok = false;
        }
        $c['Side stops visited'] = $ok;
        $c['Trail events resolved'] = (int)($run['st']['evn'] ?? 0) >= 3;
        $c['Riddles solved'] = trek_flag($run, 'choir_solved') && ($at < 2 || trek_flag($run, 'stone_solved'));
    }
    $fired = [];
    foreach (array_keys(TREK_CREW_BEATS) as $k) if (trek_flag($run, 'cm_' . $k)) $fired[] = $k;
    if ($fired) $c['Crew moments taken'] = !array_filter($fired, fn($k) => !trek_flag($run, 'cmt_' . $k));
    return [count(array_filter($c)), count($c), $c];
}

/** XP a milestone pays with $done of $total checks. */
function trek_ms_xp(string $name, int $done, int $total, int $ch = 1): int
{
    $base = max(0, (int)setting(trek_milestones($ch)[$name][1]));
    return (int)round($base * (0.5 + 0.5 * ($total > 0 ? $done / $total : 1)));
}

/**
 * A milestone is reached: pay its main XP once (ever, per player), log it, and queue the card for the map. Safe to call again: nothing happens twice.
 * The once-only guard is the trek_ms row (primary key user + milestone), so a second run, or a run reset, never pays it again.
 */
function trek_ms_award(array &$run, array $u, string $name): void
{
    $ch = (int)$run['chapter'];
    if (!isset(trek_milestones($ch)[$name]) || trek_flag($run, 'ms_' . $name)) return;
    trek_flag_set($run, 'ms_' . $name);
    [$done, $total, $list] = trek_ms_checks($run, $u, $name);
    $xp = trek_ms_xp($name, $done, $total, $ch);
    $short = trek_milestones($ch)[$name][2];
    try {
        db_insert('trek_ms', ['user_id' => (int)$u['id'], 'ms_key' => TREK_KEY . ':' . $name, 'xp' => $xp, 'done' => $done, 'total' => $total, 'paid_at' => now()]);
    } catch (PDOException $e) {   // paid in an earlier run
        $run['st']['ms'][$name] = ['xp' => 0, 'done' => $done, 'total' => $total, 'old' => 1];
        return;
    }
    $run['st']['ms'][$name] = ['xp' => $xp, 'done' => $done, 'total' => $total, 'miss' => array_keys(array_filter($list, fn($v) => !$v))];
    $lvl = $xp > 0 ? add_xp((int)$u['id'], $xp, 'Trek milestone') : null;
    trek_say_text($run, 'ch' . $ch . '.ms.' . $name);
    trek_say($run, '🏅 ' . $short . ': ' . $done . '/' . $total . ' checks → ' . $xp . ' XP.');
    if ($lvl) trek_say($run, '🎉 Gnome level ' . $lvl . '! New stat points to spend.');
    $run['st']['msc'] = array_values(array_unique(array_merge((array)($run['st']['msc'] ?? []), [$name])));   // cards waiting on the map
}

// ------------------------------------------------------------------ migration (a run that began before trek levels)

/** The starting trek level for a run that has passed $n milestones: 0 -> 1, then 3, 5, 6, 7, 8, 9. */
function trek_tl_start_level(int $passed): int
{
    return [1, 3, 5, 6, 7, 8, 9][max(0, min(6, $passed))];
}

/**
 * Once, on the first load after the upgrade (guard: st.tl is missing): every member of the run starts at a trek level from how far it got, and the
 * milestones already passed are marked paid WITHOUT paying (the gnome earned that XP the old way). Idempotent.
 */
function trek_tl_migrate(array &$run, array $u): void
{
    if (isset($run['st']['tl'])) return;
    $passed = [];
    $have = trek_recruits((int)$run['id']);   // a trailmate in the table counts even if the flag is missing
    if (trek_flag($run, 'freed_burdock') || in_array('burdock', $have, true)) $passed[] = 'burdock';
    if (trek_flag($run, 'freed_zinnia') || in_array('zinnia', $have, true)) $passed[] = 'zinnia';
    if (trek_flag($run, 'freed_bracken') || in_array('bracken', $have, true)) $passed[] = 'bracken';
    if (trek_flag($run, 'mother_down')) $passed[] = 'mother';
    if (trek_flag($run, 'gloomtooth_cured') || trek_flag($run, 'ch1_done')) { $passed[] = 'gloomtooth'; $passed[] = 'chapter'; }
    $lv = trek_tl_start_level(count($passed));
    $run['st']['tl'] = ['gnome' => [$lv, 0]];
    foreach ($have as $k) $run['st']['tl'][$k] = [$lv, 0];
    foreach ($run['party'] as $p) $run['st']['tl'][(string)$p['crew_key']] ??= [$lv, 0];
    foreach ($passed as $name) {
        trek_flag_set($run, 'ms_' . $name);
        $run['st']['ms'][$name] = ['xp' => 0, 'done' => 0, 'total' => 0, 'old' => 1];
        try {
            db_insert('trek_ms', ['user_id' => (int)$u['id'], 'ms_key' => TREK_KEY . ':' . $name, 'xp' => 0, 'done' => 0, 'total' => 0, 'paid_at' => now()]);
        } catch (PDOException $e) { /* already there */ }
    }
    if ($passed && (int)$run['id'] > 0) trek_say($run, '⬆️ The party has grown on the trail: everyone is trek level ' . $lv . ' now.');
}
