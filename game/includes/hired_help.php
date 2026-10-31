<?php
declare(strict_types=1);
/**
 * Hired help (v0.7.7). A garden with a Tool Shed can hire one NPC helper for 1, 3 or 7 days, paid up front.
 * The helper "visits" every few hours (lazy: worked out when the garden next loads):
 *   water – waters thirsty plants at each visit (growth is replayed visit by visit)
 *   weed  – pulls weeds from no-till beds
 *   harvest – picks ready crops; the owner gets the crop minus the helper's cut, and reduced XP
 */

const HELP_DAYS = [1, 3, 7];
const HELP_SKILLS = ['water' => ['💧', 'waters'], 'weed' => ['🌿', 'weeds'], 'harvest' => ['🧺', 'harvests']];

/** Starting roster: [name, species, icon, skills, wage per day, bio]. Admin can edit or add more. */
const HELPER_ROSTER = [
    ['Pip Dewfoot', 'Snail', '🐌', 'water', 40, 'Slow, steady and never forgets a thirsty plant. Leaves a shiny trail on the path.'],
    ['Hazel Thistledown', 'Hedgehog', '🦔', 'water,weed', 90, 'Snuffles out every weed and eats the slugs while she’s at it.'],
    ['Clover and Moss', 'Wren twins', '🐦', 'water,harvest', 120, 'They argue about everything, but they never drop a tomato.'],
    ['Old Burrow', 'Mole', '🐾', 'water,weed,harvest', 180, 'Has kept gardens since before your grandgnome was a seedling. Takes his pay in crops and stories.'],
];

function ensure_helpers(): int
{
    $added = 0;
    foreach (HELPER_ROSTER as [$name, $species, $icon, $skills, $wage, $bio]) {
        if (q_val('SELECT 1 FROM helpers WHERE name = ?', [$name])) continue;
        db_insert('helpers', ['name' => $name, 'species' => $species, 'icon' => $icon, 'skills' => $skills,
            'wage' => $wage, 'bio' => $bio, 'active' => 1]);
        $added++;
    }
    if (!q_val("SELECT 1 FROM encyclopedia_entries WHERE title = 'Hired help' AND chapter = 'General'")) {
        $eid = db_insert('encyclopedia_entries', ['chapter' => 'General', 'category' => 'Getting started', 'title' => 'Hired help',
            'body' => "Going adventuring? A garden with a [b]Tool Shed[/b] can give a helper somewhere to stay.\n\n"
                . "Hire one on the garden page for 1, 3 or 7 days, paid up front. They visit every few hours and do the jobs they know: "
                . "💧 watering, 🌿 weeding no-till beds, 🧺 harvesting.\n\n"
                . "Helpers keep a share of what they harvest as their pay, and you learn less from a harvest you didn’t pick yourself, "
                . "so you get less XP. Send a helper home early and you get back the whole days you didn’t use.",
            'unlock_key' => 'start', 'hint' => '', 'sort_order' => 3]);
        foreach (q("SELECT DISTINCT ue.user_id FROM user_encyclopedia ue JOIN encyclopedia_entries e ON e.id = ue.entry_id WHERE e.unlock_key = 'start'")->fetchAll(PDO::FETCH_COLUMN) as $uid) {
            db_insert('user_encyclopedia', ['user_id' => $uid, 'entry_id' => $eid, 'unlocked_at' => now()]);
        }
    }
    return $added;
}

function helper_skills(array $h): array
{
    return array_values(array_intersect(array_map('trim', explode(',', (string)$h['skills'])), array_keys(HELP_SKILLS)));
}

function helper_skill_text(array $h): string
{
    return implode(', ', array_map(fn($s) => HELP_SKILLS[$s][0] . ' ' . HELP_SKILLS[$s][1], helper_skills($h)));
}

/** The active hire for a garden, joined with its helper, or null. */
function current_hire(int $plotId): ?array
{
    return q_one('SELECT g.*, h.name, h.species, h.icon, h.skills, h.wage, h.bio FROM garden_hires g JOIN helpers h ON h.id = g.helper_id
                  WHERE g.plot_id = ? AND g.active = 1 ORDER BY g.id DESC LIMIT 1', [$plotId]) ?: null;
}

/** v0.7.99: every helper staying in this garden (a Tool Shed holds 1, 2 or 3 by its level). */
function current_hires(int $plotId): array
{
    return q('SELECT g.*, h.name, h.species, h.icon, h.skills, h.wage, h.bio FROM garden_hires g JOIN helpers h ON h.id = g.helper_id
              WHERE g.plot_id = ? AND g.active = 1 ORDER BY g.id', [$plotId])->fetchAll();
}

/** v0.7.99: how many helpers this garden's Tool Shed can house: one per shed level. */
function helper_slots(int $plotId): int
{
    return building_level($plotId, 'tool_shed');
}

/** Visit times due since the last visit, up to now and the end of the contract. */
function hire_visits(array $hire): array
{
    $step = max(1, (int)($hire['step_hours'] ?? setting('helper_visit_hours'))) * 3600;   // v2.3.0: a pal on garden duty brings its own step
    $end = min(time(), ts($hire['ends_at']));
    $out = [];
    for ($v = ts($hire['last_visit']) + $step; $v <= $end && count($out) < 200; $v += $step) $out[] = $v;
    return $out;
}

function hire_helper(array $u, int $plotId, int $helperId, int $days): array
{
    $uid = (int)$u['id'];
    if (!in_array($days, HELP_DAYS, true)) return [false, 'Pick 1, 3 or 7 days.'];
    if (!q_val('SELECT 1 FROM plots WHERE id = ? AND user_id = ?', [$plotId, $uid])) return [false, 'That isn’t your garden.'];
    if (!has_building($plotId, 'tool_shed')) return [false, 'A helper needs a Tool Shed in this garden to stay in.'];
    $h = q_one('SELECT * FROM helpers WHERE id = ? AND active = 1', [$helperId]);
    if (!$h) return [false, 'That helper isn’t available.'];
    $cost = (int)$h['wage'] * $days;
    db()->beginTransaction();
    $n = count(current_hires($plotId));
    if ($n >= helper_slots($plotId)) {
        db()->rollBack();
        return [false, $n === 1 && helper_slots($plotId) < 3 ? 'This garden already has a helper. Upgrade the Tool Shed to house another.' : 'The Tool Shed is full.'];
    }
    if (q_val('SELECT 1 FROM garden_hires WHERE plot_id = ? AND helper_id = ? AND active = 1', [$plotId, $helperId])) {
        db()->rollBack();
        return [false, $h['name'] . ' is already working here.'];
    }
    if (q('UPDATE users SET coins = coins - ? WHERE id = ? AND coins >= ?', [$cost, $uid, $cost])->rowCount() !== 1) {
        db()->rollBack();
        return [false, $h['name'] . ' asks ' . number_format($cost) . ' ' . setting('currency_name') . ' for ' . $days . ' day' . ($days > 1 ? 's' : '') . '.'];
    }
    db_insert('garden_hires', ['plot_id' => $plotId, 'user_id' => $uid, 'helper_id' => $helperId, 'started_at' => now(),
        'ends_at' => gmdate('Y-m-d H:i:s', time() + $days * 86400), 'last_visit' => now(), 'paid' => $cost, 'active' => 1]);
    db()->commit();
    return [true, $h['icon'] . ' ' . $h['name'] . ' moves into your Tool Shed for ' . $days . ' day' . ($days > 1 ? 's' : '') . '. They’ll visit every '
        . (int)setting('helper_visit_hours') . ' hours.'];
}

/** Send a helper home early. Unused whole days are refunded. */
function dismiss_helper(array $u, int $plotId, int $hireId = 0): array
{
    $hire = null;
    foreach (current_hires($plotId) as $hh) if (!$hireId || (int)$hh['id'] === $hireId) $hire = $hh;   // v0.7.99: a chosen helper
    if (!$hire || (int)$hire['user_id'] !== (int)$u['id']) return [false, 'No helper to send home.'];
    $days = max(0, intdiv(ts($hire['ends_at']) - time(), 86400));
    $refund = min((int)$hire['paid'], $days * (int)$hire['wage']);
    db()->beginTransaction();
    if (q('UPDATE garden_hires SET active = 0, ends_at = ? WHERE id = ? AND active = 1', [now(), $hire['id']])->rowCount() === 1 && $refund > 0) {
        q('UPDATE users SET coins = coins + ? WHERE id = ?', [$refund, $u['id']]);
    }
    db()->commit();
    return [true, $hire['name'] . ' heads home.' . ($refund ? ' You get ' . money($refund) . ' back for the unused days.' : '')];
}

/**
 * Called from load_plot for each tile, before normal growth: replay the helper's watering visits.
 * Returns the tile, and counts waterings in $stats.
 */
function helper_water_tile(array $t, ?array $p, array $visits, array &$stats): array
{
    if (!$p || !$visits) return $t;
    foreach ($visits as $v) {
        if ($v <= (ts($t['growth_updated_at']) ?: ts($t['planted_at']))) continue;   // before planting, or before you last tended it
        $t = tile_grow($t, $p, $v);
        if ((int)$t['growth_seconds'] >= (int)$p['grow_minutes'] * 60) break;   // ready: nothing more to water
        $wetUntil = $t['last_watered'] ? ts($t['last_watered']) + water_seconds($t, $p) : 0;
        if ($wetUntil <= $v) {
            $t['last_watered'] = gmdate('Y-m-d H:i:s', $v);
            $t['growth_updated_at'] = gmdate('Y-m-d H:i:s', $v);
            $stats['water']++;
        }
    }
    q('UPDATE plot_tiles SET last_watered = ?, growth_seconds = ?, growth_updated_at = ? WHERE id = ?',
        [$t['last_watered'], $t['growth_seconds'], $t['growth_updated_at'], $t['id']]);
    return $t;
}

/** Finish a helper's visits: record them, close an ended contract, and return a "while you were out" line. */
function helper_finish(array $hire, array $visits, array $stats): ?string
{
    if (isset($hire['pj_job'])) return pj_garden_finish($hire, $visits, $stats);   // v2.3.0: a pal tending the garden (pal_jobs.php)
    $last = $visits ? gmdate('Y-m-d H:i:s', end($visits)) : $hire['last_visit'];
    $ended = ts($hire['ends_at']) <= time();
    q('UPDATE garden_hires SET last_visit = ?, visits = visits + ?, waterings = waterings + ?, weedings = weedings + ?, harvests = harvests + ?, active = ? WHERE id = ?',
        [$last, count($visits), $stats['water'], $stats['weed'], $stats['harvest'], $ended ? 0 : 1, $hire['id']]);
    $did = [];
    if ($stats['water']) $did[] = 'watered ' . $stats['water'] . ' time' . ($stats['water'] > 1 ? 's' : '');
    if ($stats['weed']) $did[] = 'weeded ' . $stats['weed'] . ' bed' . ($stats['weed'] > 1 ? 's' : '');
    if ($stats['harvest']) $did[] = 'harvested ' . $stats['harvest'] . ' crop' . ($stats['harvest'] > 1 ? 's' : '');
    if (!$did && !$ended) return null;
    return $hire['icon'] . ' ' . $hire['name'] . ($did ? ' ' . implode(', ', $did) . ' while you were out.' : '')
        . ($ended ? ($did ? ' Their stay is over and they’ve gone home.' : ' has finished their stay and gone home.') : '');
}
