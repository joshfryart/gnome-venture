<?php
declare(strict_types=1);
/**
 * The Quick slot (nav dock, phase 2b; plan: claude/plan-nav-dock.md). One food, drink or healing potion a gnome puts on the dock's Quick piece:
 * a tap uses it. Stored as users.quick_item_id (NULL = empty). Using it goes through the same functions as the Satchel's own Eat and Drink buttons
 * (eat_item(), hp_use()), so every rule they have (full energy, first taste, mastery, "heal in town") applies unchanged.
 * Endpoint: quick.php (POST, CSRF): do = set (item_id) | clear | use. Fights are not handled yet: the fight's own Snack is the way to heal there (phase 3).
 */

/** users.quick_item_id for the schema upgrade (same shape as here_schema()). */
function quick_schema(string $PK, string $ID, string $END): array
{
    return [[], [], [['users', 'quick_item_id', 'INT NULL']]];
}

/** Make sure users.quick_item_id exists. The upgrade makes it when the version changes; this covers the days between uploading the files and the upgrade running. */
function quick_ensure_schema(): bool
{
    static $ok = null;
    if ($ok !== null) return $ok;
    try { q('SELECT quick_item_id FROM users LIMIT 1'); return $ok = true; } catch (Throwable $e) {}
    try {
        db()->exec('ALTER TABLE users ADD COLUMN quick_item_id INT NULL');
        return $ok = true;
    } catch (Throwable $e) {
        error_log('quick_ensure_schema: ' . $e->getMessage());
        return $ok = false;
    }
}

/** What a tap on this item would do: 'heal' (a healing potion), 'eat' (food or a drink), or '' (it cannot go on the Quick button). */
function quick_kind(int $itemId): string
{
    require_once __DIR__ . '/alchemy.php';
    foreach (array_keys(ALCHEMY_HEAL) as $slug) if (alchemy_item_id($slug) === $itemId && $itemId > 0) return 'heal';
    return (int)q_val('SELECT edible FROM items WHERE id = ?', [$itemId]) === 1 ? 'eat' : '';
}

/** The gnome's Quick item: ['id', 'name', 'qty', 'kind'] or null. */
function quick_get(array $u): ?array
{
    if (!quick_ensure_schema()) return null;
    $id = (int)($u['quick_item_id'] ?? 0);
    if ($id <= 0) return null;
    $item = q_one('SELECT id, name FROM items WHERE id = ?', [$id]);
    if (!$item) return null;
    return ['id' => (int)$item['id'], 'name' => (string)$item['name'], 'qty' => (int)q_val('SELECT qty FROM user_items WHERE user_id = ? AND item_id = ?', [(int)$u['id'], $id]), 'kind' => quick_kind($id)];
}

/** Put an item on the Quick button. You must have it, and it must be something a tap can use. */
function quick_set(array $u, int $itemId): array
{
    if (!quick_ensure_schema()) return [false, 'The Quick button is not ready yet. Try again in a minute.'];
    $name = (string)q_val('SELECT name FROM items WHERE id = ?', [$itemId]);
    if ($itemId <= 0 || $name === '') return [false, 'Pick an item first.'];
    if ((int)q_val('SELECT qty FROM user_items WHERE user_id = ? AND item_id = ?', [(int)$u['id'], $itemId]) <= 0) return [false, 'You don’t have any ' . $name . '.'];
    if (quick_kind($itemId) === '') return [false, 'Only food, drinks and healing potions can go on the Quick button.'];
    q('UPDATE users SET quick_item_id = ? WHERE id = ?', [$itemId, (int)$u['id']]);
    return [true, '⚡ ' . $name . ' is on your Quick button.'];
}

/** Take the item off the Quick button. */
function quick_clear(array $u): array
{
    if (!quick_ensure_schema()) return [false, 'The Quick button is not ready yet.'];
    q('UPDATE users SET quick_item_id = NULL WHERE id = ?', [(int)$u['id']]);
    return [true, 'Quick button cleared.'];
}

/** Use the Quick item once, exactly as the Satchel's Eat or Drink button would. Returns [ok, message]. */
function quick_use(array $u): array
{
    $qk = quick_get($u);
    if (!$qk) return [false, 'Nothing is on your Quick button. Set one in the Satchel.'];
    if ($qk['qty'] <= 0) return [false, 'You have no ' . $qk['name'] . ' left. Clear the Quick button, or restock.'];
    if ($qk['kind'] === '') return [false, $qk['name'] . ' can’t be used from the Quick button any more. Clear it and pick another.'];
    require_once __DIR__ . '/gnome.php';   // eat_item(), refresh_energy()
    require_once __DIR__ . '/adventure.php';   // active_expedition(); hp_use() reads it too
    $exp = active_expedition((int)$u['id']);
    if ($exp && !empty($exp['encounter'])) return [false, 'You’re in a fight: use the fight’s own Snack button. The Quick button works in fights in a later version.'];
    if ($qk['kind'] === 'heal') {
        require_once __DIR__ . '/health.php';
        return hp_use($u, 'potion', $qk['id']);
    }
    refresh_energy($u);
    [$ok, $msgs] = eat_item($u, $qk['id']);
    return [$ok, implode(' ', $msgs)];
}
