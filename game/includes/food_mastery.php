<?php
declare(strict_types=1);

// Food perks (2.6.32).
// 1) Foodie rank: every food_unique_every (10) different foods a gnome has tasted is one rank. Each rank = +food_rank_energy max energy and
//    +food_rank_buff_pct % longer meal buffs.
// 2) Mastery: every food or crop is counted per gnome: each time it is eaten, plus each one harvested of a crop. At food_mastery_marks
//    (500, 1000, 1650, 2000) that item reaches mastery 1..4. When a mastered item is eaten, its meal-buff stats grow food_mastery_stat_pct % per
//    mastery (at least +1), the buff lasts food_mastery_time_pct % longer, and the energy it gives grows food_mastery_energy_pct %.

const FOOD_MASTERY_NAMES = [1 => 'Familiar', 2 => 'Favourite', 3 => 'Beloved', 4 => 'Signature'];

/** The count marks, e.g. [500, 1000, 1650, 2000]. */
function food_marks(): array
{
    $m = array_values(array_filter(array_map('intval', explode(',', (string)setting('food_mastery_marks'))), fn($n) => $n > 0));
    sort($m);
    return $m ?: [500, 1000, 1650, 2000];
}

function food_mastery_tier(int $count): int
{
    $t = 0;
    foreach (food_marks() as $i => $mark) if ($count >= $mark) $t = $i + 1;
    return $t;
}

/** [eaten, grown] for one item. */
function food_mastery_counts(int $uid, int $itemId): array
{
    $r = q_one('SELECT eaten, grown FROM user_food_mastery WHERE user_id = ? AND item_id = ?', [$uid, $itemId]);
    return [(int)($r['eaten'] ?? 0), (int)($r['grown'] ?? 0)];
}

/** Add $n eaten or grown. Returns [tier before, tier now, total]. */
function food_mastery_add(int $uid, int $itemId, string $col, int $n = 1): array
{
    if ($n <= 0 || !in_array($col, ['eaten', 'grown'], true)) return [0, 0, 0];
    [$e, $g] = food_mastery_counts($uid, $itemId);
    $before = food_mastery_tier($e + $g);
    if (q_val('SELECT 1 FROM user_food_mastery WHERE user_id = ? AND item_id = ?', [$uid, $itemId])) {
        q("UPDATE user_food_mastery SET $col = $col + ? WHERE user_id = ? AND item_id = ?", [$n, $uid, $itemId]);
    } else {
        db_insert('user_food_mastery', ['user_id' => $uid, 'item_id' => $itemId, 'eaten' => 0, 'grown' => 0, $col => $n]);
    }
    $total = $e + $g + $n;
    return [$before, food_mastery_tier($total), $total];
}

function food_mastery_name(int $tier): string
{
    return FOOD_MASTERY_NAMES[$tier] ?? '';
}

/** A line for when an item just climbed a mastery step ('' if it did not). */
function food_mastery_up_line(string $itemName, array $res): string
{
    [$before, $now] = $res;
    if ($now <= $before) return '';
    return '🏅 ' . $itemName . ': ' . food_mastery_name($now) . '! ' . str_repeat('★', $now) . ' ' . food_mastery_effect_text($now);
}

function food_mastery_effect_text(int $tier): string
{
    if ($tier < 1) return '';
    return 'Eating it now gives +' . ($tier * (int)setting('food_mastery_stat_pct')) . '% on its boosts, lasting +' . ($tier * (int)setting('food_mastery_time_pct'))
        . '% longer, and +' . ($tier * (int)setting('food_mastery_energy_pct')) . '% energy.';
}

/** Scale an item's effects (temp boost, energy) for its mastery tier. */
function food_mastery_boost(array $fx, int $tier): array
{
    if ($tier < 1) return $fx;
    if (!empty($fx['temp']) && is_array($fx['temp'])) {
        $pct = $tier * (int)setting('food_mastery_stat_pct');
        foreach ($fx['temp'] as $k => $v) {
            if ($k === 'minutes') $fx['temp'][$k] = (int)round((int)$v * (100 + $tier * (int)setting('food_mastery_time_pct')) / 100);
            elseif (isset(GNOME_STATS[$k]) && (int)$v > 0) $fx['temp'][$k] = (int)$v + max(1, (int)round((int)$v * $pct / 100));
        }
    }
    if (!empty($fx['energy'])) {
        $n = (int)$fx['energy'];
        $fx['energy'] = $n + max(1, (int)round($n * $tier * (int)setting('food_mastery_energy_pct') / 100));
    }
    return $fx;
}

/** Foodie rank: different foods tasted / food_unique_every. $refresh after a new taste. */
function food_rank(int $uid, bool $refresh = false): int
{
    static $cache = [];
    if ($uid <= 0) return 0;
    if ($refresh || !isset($cache[$uid])) {
        $every = max(1, (int)setting('food_unique_every'));
        $cache[$uid] = intdiv((int)q_val('SELECT COUNT(*) FROM user_tasted WHERE user_id = ?', [$uid]), $every);
    }
    return $cache[$uid];
}

function food_rank_energy(int $uid): int
{
    return food_rank($uid) * (int)setting('food_rank_energy');
}

function food_rank_buff_pct(int $uid): int
{
    return food_rank($uid) * (int)setting('food_rank_buff_pct');
}
