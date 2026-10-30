<?php
declare(strict_types=1);

// Inventory domain: items, the Almanac unlocks that follow them, and the starter / home-region gifts.
// Extracted from functions.php (loaded by bootstrap.php right after it); signatures unchanged.

/**
 * Add (or remove, with a negative qty) items. Returns false if the player doesn't have enough.
 * Each change is a single atomic UPDATE, so two requests at the same moment can't duplicate items.
 */
function give_item(int $userId, int $itemId, int $qty): bool
{
    if ($qty === 0) return true;
    if ($qty < 0) {
        $ok = q('UPDATE user_items SET qty = qty + ? WHERE user_id = ? AND item_id = ? AND qty >= ?',
            [$qty, $userId, $itemId, -$qty])->rowCount() === 1;
        if ($ok) {
            q('DELETE FROM user_items WHERE user_id = ? AND item_id = ? AND qty <= 0', [$userId, $itemId]);
            // The tracked-quality count shrinks with the stack, so what is bought or traded later can't inherit a harvest's quality
            $n = (int)q_val('SELECT n FROM item_quality WHERE user_id = ? AND item_id = ?', [$userId, $itemId]);
            if ($n > 0) {
                $after = (int)q_val('SELECT qty FROM user_items WHERE user_id = ? AND item_id = ?', [$userId, $itemId]);
                $before = $after - $qty;
                q('UPDATE item_quality SET n = ? WHERE user_id = ? AND item_id = ?', [intdiv(min($n, $before) * $after, $before), $userId, $itemId]);
            }
        }
        return $ok;
    }
    if (q('UPDATE user_items SET qty = qty + ?, got_at = ? WHERE user_id = ? AND item_id = ?', [$qty, now(), $userId, $itemId])->rowCount() === 1) {
        return true;
    }
    try {
        db_insert('user_items', ['user_id' => $userId, 'item_id' => $itemId, 'qty' => $qty, 'got_at' => now()]);
    } catch (PDOException $e) {
        // Only a duplicate-key race is expected (SQLSTATE 23000, MySQL 1062, SQLite 19 UNIQUE); rethrow the rest
        $dup = ($e->errorInfo[1] ?? 0) === 1062 || stripos($e->getMessage(), 'UNIQUE constraint') !== false;
        if (!$dup) throw $e;
        // Someone else inserted the row a moment ago: add to it instead
        return q('UPDATE user_items SET qty = qty + ?, got_at = ? WHERE user_id = ? AND item_id = ?', [$qty, now(), $userId, $itemId])->rowCount() === 1;
    }
    unlock_entries($userId, 'item:' . q_val('SELECT slug FROM items WHERE id = ?', [$itemId]));
    return true;
}


/** A few words on why an Almanac page just opened, from its unlock key. */
function unlock_reason(string $key): string
{
    [$kind, $rest] = array_pad(explode(':', $key, 2), 2, '');
    $name = fn(string $table, string $slug) => (string)(q_val("SELECT name FROM $table WHERE slug = ?", [$slug]) ?: '');
    return match ($kind) {
        'item' => ($n = $name('items', $rest)) !== '' ? 'your first ' . $n : 'a new find',
        'plant' => 'your first harvest of it',
        'village' => 'you visited',
        'landmark' => 'you found it',
        'npc' => 'you met them',
        'creature' => 'you met one',
        'recipe' => 'you made it',
        'lore' => 'you read the local history',
        'region' => 'your progress in that region',
        'gather' => 'you gathered it',
        'soil' => 'your soil grade',
        'yard', 'gotm' => 'your yard',
        'pots' => 'you collected a pot',
        'pantry' => 'you added a Pantry',
        default => '',
    };
}

/** Unlock every encyclopedia entry with this key for a player (e.g. "start", "item:sunsprout-seed"). */
function unlock_entries(int $userId, string $key): int
{
    $n = 0;
    foreach (q('SELECT id FROM encyclopedia_entries WHERE unlock_key = ?', [$key])->fetchAll() as $r) {
        if (!q_val('SELECT 1 FROM user_encyclopedia WHERE user_id = ? AND entry_id = ?', [$userId, $r['id']])) {
            db_insert('user_encyclopedia', ['user_id' => $userId, 'entry_id' => $r['id'], 'unlocked_at' => now()]);
            $n++;
            // v0.7.27: tell the gnome on their next page, with a link straight to the new page
            // v0.7.42: and why, so a page turning up after a harvest or a find doesn't feel random
            if (session_status() === PHP_SESSION_ACTIVE && (int)($_SESSION['uid'] ?? 0) === $userId) $_SESSION['new_pages'][] = [(int)$r['id'], unlock_reason($key)];
        }
    }
    if ($n > 0 && function_exists('calling_event')) calling_event($userId, 'page', $key, 1);   // v0.9.4 N0: a new Almanac page (key prefix creature: gather: recipe: item: plant: village: landmark: npc: region:)
    return $n;
}


/** Everyday starter kit from the "starter_items" setting: [[item_id, name, qty], ...] */
function starter_item_list(): array
{
    $out = [];
    foreach (explode(',', setting('starter_items')) as $pair) {
        $parts = array_map('trim', explode(':', $pair));
        if (count($parts) !== 2 || (int)$parts[1] <= 0) continue;
        $row = q_one('SELECT id, name FROM items WHERE slug = ?', [$parts[0]]);
        if ($row) $out[] = [(int)$row['id'], (string)$row['name'], (int)$parts[1]];
    }
    return $out;
}


/**
 * The seeds a gnome gets for choosing this home region: every staple crop and two of its flowers.
 * Used both to preview the gift in the welcome flow and to give it. [[item_id, name, qty, kind, plant_name], ...]
 */
function home_seed_list(int $regionId): array
{
    $n = (int)setting('home_seed_qty');
    if ($n <= 0) return [];
    $out = [];
    foreach (q("SELECT p.seed_item_id, i.name, p.kind, p.name AS plant FROM plant_regions pr JOIN plants p ON p.id = pr.plant_id
                JOIN items i ON i.id = p.seed_item_id WHERE pr.region_id = ? AND pr.tier = 'staple' ORDER BY p.name", [$regionId])->fetchAll() as $r) {
        $out[] = [(int)$r['seed_item_id'], (string)$r['name'], $n, (string)$r['kind'], (string)$r['plant']];
    }
    foreach (q("SELECT p.seed_item_id, i.name, p.kind, p.name AS plant FROM plant_regions pr JOIN plants p ON p.id = pr.plant_id
                JOIN items i ON i.id = p.seed_item_id WHERE pr.region_id = ? AND pr.tier = 'flower' ORDER BY p.id LIMIT 2", [$regionId])->fetchAll() as $r) {
        $out[] = [(int)$r['seed_item_id'], (string)$r['name'], 1, 'flower', (string)$r['plant']];
    }
    return $out;
}
