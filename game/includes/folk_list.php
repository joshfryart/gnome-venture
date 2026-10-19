<?php
declare(strict_types=1);
/** v0.7.69: everyone a gnome has met (seen at work, met in a place, chatted with or given a gift to). */
require_once __DIR__ . '/friends.php';
require_once __DIR__ . '/npc_life.php';

/** Remember that this gnome has met these folk (safe to repeat). */
function npc_meet(int $uid, array $npcIds): void
{
    foreach (array_unique(array_map('intval', $npcIds)) as $nid) {
        if ($nid <= 0 || q_val('SELECT 1 FROM user_npc_met WHERE user_id = ? AND npc_id = ?', [$uid, $nid])) continue;
        try {
            db_insert('user_npc_met', ['user_id' => $uid, 'npc_id' => $nid, 'first_at' => now()]);
        } catch (PDOException $e) {
            // met a moment ago
        }
    }
}

/** Everyone met, with friendship points (0 = Stranger), where they are now and their home. */
function met_npcs(int $uid): array
{
    $rows = q('SELECT n.*, COALESCE(f.points, 0) AS points, m.first_at FROM npcs n
               LEFT JOIN npc_friends f ON f.npc_id = n.id AND f.user_id = ?
               LEFT JOIN user_npc_met m ON m.npc_id = n.id AND m.user_id = ?
               WHERE n.active = 1 AND (m.npc_id IS NOT NULL OR f.npc_id IS NOT NULL)
               ORDER BY COALESCE(f.points, 0) DESC, n.name', [$uid, $uid])->fetchAll();
    foreach ($rows as &$n) {
        $n['now'] = npc_now($n);
        $n['home'] = $n['home_location_id'] ? q_one('SELECT l.name, l.region FROM locations l WHERE l.id = ?', [$n['home_location_id']]) : null;
        if (!$n['home'] && $n['fav_spot_id']) $n['home'] = q_one("SELECT name, region FROM town_spots WHERE id = ?", [$n['fav_spot_id']]);
        $n['level'] = friend_level((int)$n['points']);
    }
    return $rows;
}
