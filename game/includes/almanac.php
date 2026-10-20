<?php
declare(strict_types=1);

/** Almanac progress: plant, flower, village, landmark and region pages, plus milestone rewards. */

function almanac_counts(int $uid): array
{
    $total = (int)q_val('SELECT COUNT(*) FROM encyclopedia_entries');
    $have = (int)q_val('SELECT COUNT(*) FROM user_encyclopedia WHERE user_id = ?', [$uid]);
    return [$have, $total];
}

/**
 * Each region earns Bronze → Silver → Gold tiers:
 * - Bronze: grown every staple of the region.
 * - Silver: Bronze + grown every uncommon.
 * - Gold:   Silver + grown every treasure + cut every flower.
 */
function region_tier_progress(int $uid, int $regionId): array
{
    $tally = fn(string $tier) => (int)q_val(
        "SELECT COUNT(*) FROM plant_regions pr WHERE pr.region_id = ? AND pr.tier = ?",
        [$regionId, $tier]);
    $done = fn(string $tier) => (int)q_val(
        "SELECT COUNT(*) FROM plant_regions pr
         JOIN user_plant_knowledge k ON k.plant_id = pr.plant_id AND k.user_id = ? AND k.knowledge > 0
         WHERE pr.region_id = ? AND pr.tier = ?",
        [$uid, $regionId, $tier]);
    $staples = ['have' => $done('staple'), 'need' => $tally('staple')];
    $uncommons = ['have' => $done('uncommon'), 'need' => $tally('uncommon')];
    $treasures = ['have' => $done('treasure'), 'need' => $tally('treasure')];
    $flowers = ['have' => $done('flower'), 'need' => $tally('flower')];
    return [
        'staple' => $staples, 'uncommon' => $uncommons, 'treasure' => $treasures, 'flower' => $flowers,
        'bronze' => $staples['need'] > 0 && $staples['have'] >= $staples['need'],
        'silver' => $staples['need'] > 0 && $uncommons['need'] >= 0
            && $staples['have'] >= $staples['need']
            && $uncommons['have'] >= $uncommons['need'],
        'gold'   => $staples['need'] > 0
            && $staples['have'] >= $staples['need']
            && $uncommons['have'] >= $uncommons['need']
            && $treasures['have'] >= max(1, $treasures['need'])
            && $flowers['have'] >= max(1, $flowers['need']),
    ];
}

/** Call after a harvest. Unlocks pages and pays milestone rewards. Returns messages for the player. */
function almanac_after_harvest(int $uid, int $plantId): array
{
    $msgs = [];
    $plant = q_one('SELECT name, slug, kind FROM plants WHERE id = ?', [$plantId]);
    if (!$plant || !$plant['slug']) {
        return $msgs;
    }
    if (unlock_entries($uid, 'plant:' . $plant['slug'])) {
        $msgs[] = '📖 New Almanac page: ' . $plant['name'] . '!';
    }

    // Which regions does this plant touch? Check their tier progress.
    $regions = q('SELECT pr.region_id, r.code, r.gnomish_name FROM plant_regions pr
                  JOIN regions r ON r.id = pr.region_id WHERE pr.plant_id = ?', [$plantId])->fetchAll();
    foreach ($regions as $r) {
        $rid = (int)$r['region_id'];
        $prog = region_tier_progress($uid, $rid);
        $slug = strtolower($r['code']);
        if ($prog['bronze'] && unlock_entries($uid, 'region:' . $slug . ':bronze')) {
            $msgs[] = '🥉 ' . $r['gnomish_name'] . ' — Bronze tier reached!';
        }
        if ($prog['silver'] && unlock_entries($uid, 'region:' . $slug . ':silver')) {
            $msgs[] = '🥈 ' . $r['gnomish_name'] . ' — Silver tier reached!';
        }
        if ($prog['gold'] && unlock_entries($uid, 'region:' . $slug . ':gold')) {
            $msgs[] = '🥇 ' . $r['gnomish_name'] . ' — Gold tier reached!';
            // Full region unlock too (so the "every region" milestone works)
            unlock_entries($uid, 'region:' . $slug);
        }
    }

    return array_merge($msgs, check_milestones($uid));
}

/** Award any milestones the player has newly reached. */
function check_milestones(int $uid): array
{
    $msgs = [];
    [$have, $total] = almanac_counts($uid);
    $rows = q('SELECT m.* FROM almanac_milestones m
               LEFT JOIN user_milestones um ON um.milestone_id = m.id AND um.user_id = ?
               WHERE m.active = 1 AND um.milestone_id IS NULL', [$uid])->fetchAll();
    foreach ($rows as $m) {
        $reached = false;
        if ($m['kind'] === 'pages') {
            $reached = $have >= (int)$m['threshold'];
        } elseif ($m['kind'] === 'percent') {
            $reached = $total > 0 && $have * 100 >= (int)$m['threshold'] * $total;
        } elseif ($m['kind'] === 'key' && $m['unlock_key']) {
            $key = (string)$m['unlock_key'];
            $sql = 'SELECT 1 FROM encyclopedia_entries e JOIN user_encyclopedia ue ON ue.entry_id = e.id AND ue.user_id = ? WHERE e.unlock_key ';
            $reached = str_ends_with($key, '*')
                ? (bool)q_val($sql . 'LIKE ?', [$uid, substr($key, 0, -1) . '%'])
                : (bool)q_val($sql . '= ?', [$uid, $key]);
        }
        if (!$reached) {
            continue;
        }
        try {
            db_insert('user_milestones', ['user_id' => $uid, 'milestone_id' => $m['id'], 'achieved_at' => now()]);
        } catch (PDOException $e) {
            continue;
        }
        $rewards = [];
        if ((int)$m['reward_coins'] > 0) {
            give_petals((int)$uid, (int)$m['reward_coins']);
            $rewards[] = number_format((int)$m['reward_coins']) . ' ' . setting('currency_name');
        }
        if ($m['reward_item_id'] && (int)$m['reward_qty'] > 0) {
            give_item($uid, (int)$m['reward_item_id'], (int)$m['reward_qty']);
            $rewards[] = (int)$m['reward_qty'] . ' × ' . q_val('SELECT name FROM items WHERE id = ?', [$m['reward_item_id']]);
        }
        if ($m['reward_title']) {
            q("UPDATE users SET title = ? WHERE id = ? AND (title IS NULL OR title = '')", [$m['reward_title'], $uid]);
            $rewards[] = 'the title "' . $m['reward_title'] . '" (choose your title in the Almanac)';
        }
        $msgs[] = '🏆 Milestone: ' . $m['name'] . ($rewards ? ' — you earned ' . implode(', ', $rewards) : '') . '!';
    }
    return $msgs;
}

/** v0.7.61: which block of the Milestones page a milestone belongs to. */
function almanac_milestone_group(array $m): string
{
    if ($m['kind'] === 'pages') return 'pages';
    if ($m['kind'] === 'percent') return 'percent';
    $key = (string)($m['unlock_key'] ?? '');
    if (str_starts_with($key, 'soil:')) return 'soil';
    if (str_starts_with($key, 'region:')) return 'regions';
    return 'other';
}

/** v0.7.61: the goal of one milestone in plain words. */
function almanac_goal_text(array $m): string
{
    $key = (string)($m['unlock_key'] ?? '');
    if ($m['kind'] === 'pages') return 'Fill in ' . (int)$m['threshold'] . ' Almanac pages';
    if ($m['kind'] === 'percent') return 'Fill in ' . (int)$m['threshold'] . '% of the whole Almanac';
    if (str_starts_with($key, 'soil:')) return 'Raise a no-till bed to soil grade ' . strtoupper(substr($key, 5));
    if ($key === 'region:*') return 'Earn a region medal in any region';
    if (preg_match('/^region:([a-z]+):(bronze|silver|gold)$/', $key, $mm)) {
        $r = region_by_slug($mm[1]);
        $name = $r ? (string)$r['gnomish_name'] : strtoupper($mm[1]);
        return [
            'bronze' => 'Grow every staple crop in ' . $name,
            'silver' => 'Bronze, plus every uncommon crop in ' . $name,
            'gold'   => 'Silver, plus every treasure crop and cut every flower in ' . $name,
        ][$mm[2]];
    }
    return (string)$m['name'];
}

/**
 * v0.7.61: how far along a milestone is, as ['now' => .., 'goal' => .., 'unit' => ..], or null when
 * it can only be done or not done (soil grades, "any region").
 */
function almanac_milestone_progress(int $uid, array $m, int $have, int $total): ?array
{
    $key = (string)($m['unlock_key'] ?? '');
    if ($m['kind'] === 'pages') {
        return ['now' => min($have, (int)$m['threshold']), 'goal' => max(1, (int)$m['threshold']), 'unit' => ' pages'];
    }
    if ($m['kind'] === 'percent') {
        $pct = $total ? (int)floor($have * 100 / $total) : 0;
        return ['now' => min($pct, (int)$m['threshold']), 'goal' => max(1, (int)$m['threshold']), 'unit' => '%'];
    }
    if (preg_match('/^region:([a-z]+):(bronze|silver|gold)$/', $key, $mm)) {
        $r = region_by_slug($mm[1]);
        if (!$r) return null;
        static $tiers = [];   // one page load can show many region medals: work each region out once
        $p = $tiers[$uid . ':' . $r['id']] ??= region_tier_progress($uid, (int)$r['id']);
        // Same rules as region_tier_progress(): each medal includes the ones before it
        $parts = ['bronze' => ['staple'], 'silver' => ['staple', 'uncommon'],
                  'gold' => ['staple', 'uncommon', 'treasure', 'flower']][$mm[2]];
        $now = 0;
        $goal = 0;
        foreach ($parts as $part) {
            $need = max(1, (int)$p[$part]['need']);
            $now += min((int)$p[$part]['have'], $need);
            $goal += $need;
        }
        return ['now' => $now, 'goal' => max(1, $goal), 'unit' => ' crops'];
    }
    return null;
}
