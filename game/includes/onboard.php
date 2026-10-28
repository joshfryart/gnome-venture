<?php
declare(strict_types=1);
/**
 * v2.0.75: the pieces of "make a gnome" that welcome.php (new players) and guest.php (guest gardens) share.
 * onboard_create() is the one transaction that turns a bare account into a gnome with a garden; the WHERE onboarded = 0 claim means a double click makes one garden.
 */
require_once __DIR__ . '/gnome.php';
require_once __DIR__ . '/adventure_data.php';
require_once __DIR__ . '/catalog.php';
require_once __DIR__ . '/world.php';
require_once __DIR__ . '/items.php';

/** Make the gnome, garden and starter basket for an account that has none. Returns true when this call did it. $tourStep 0 = no Wren tour (guests). */
function onboard_create(int $uid, string $name, string $hat, string $beard, int $regionId, int $villageId, string $garden, int $tourStep): bool
{
    $claimed = false;
    db()->beginTransaction();
    try {
        // Only once: the WHERE onboarded = 0 stops a double click making two gardens.
        $claimed = q('UPDATE users SET gnome_name = ?, hat_color = ?, beard_color = ?, region_id = ?, onboarded = 1, tour_step = ?
                      WHERE id = ? AND onboarded = 0', [$name, $hat, $beard, $regionId, $tourStep, $uid])->rowCount() === 1;
        if ($claimed) {
            setup_new_player($uid, $villageId, $garden);
            foreach (village_welcome_pack($villageId) as [$itemId, , $qty]) {
                give_item($uid, $itemId, $qty);
            }
            $vslug = (string)q_val('SELECT slug FROM locations WHERE id = ?', [$villageId]);
            unlock_entries($uid, 'village:' . $vslug);
        }
        db()->commit();
    } catch (Throwable $e) {
        db()->rollBack();
        throw $e;
    }
    return $claimed;
}

/** The villages a new gnome may start in: on a road, and gentle when the region has any gentle one. [id, ...] */
function onboard_start_villages(int $regionId): array
{
    $ids = array_map('intval', q("SELECT l.id FROM locations l WHERE l.region_id = ? AND l.kind = 'village'
        AND EXISTS (SELECT 1 FROM routes r WHERE r.kind = 'road' AND (r.a_id = l.id OR r.b_id = l.id)) ORDER BY l.sort_order, l.id", [$regionId])->fetchAll(PDO::FETCH_COLUMN));
    $gentle = array_values(array_filter($ids, fn($id) => gentle_start_village($id)));
    return $gentle ?: $ids;
}

/**
 * A village's welcome basket: both of its landscape's finds, a seed of one of the region's market crops
 * and a local snack. Picked from the village's name, so it's always the same for a village but
 * villages differ. [[item_id, name, qty, kind, label, icon], ...]
 */
function village_welcome_pack(int $villageId): array
{
    $v = q_one("SELECT id, slug, region_id, landscape FROM locations WHERE id = ? AND kind = 'village'", [$villageId]);
    if (!$v) return [];
    $pick = fn(array $rows, string $salt) => $rows ? $rows[crc32($v['slug'] . $salt) % count($rows)] : null;
    $out = [];
    foreach (LANDSCAPE_FINDS[$v['landscape']] ?? [] as [$name]) {
        $id = (int)q_val('SELECT id FROM items WHERE slug = ?', [slugify($name)]);
        if ($id) $out[] = [$id, $name, 1, 'find', $name, LANDSCAPES[$v['landscape']][0] ?? '✨'];
    }
    $seed = $pick(q("SELECT i.id, i.name, p.kind, p.name AS plant FROM plant_regions pr JOIN plants p ON p.id = pr.plant_id
                     JOIN items i ON i.id = p.seed_item_id WHERE pr.region_id = ? AND pr.tier = 'uncommon' ORDER BY p.id",
                     [$v['region_id']])->fetchAll(), ':seed');
    if ($seed) $out[] = [(int)$seed['id'], (string)$seed['name'], 2, (string)$seed['kind'], (string)$seed['name'], null];
    $snack = $pick(q("SELECT i.id, i.name, p.kind FROM plant_regions pr JOIN plants p ON p.id = pr.plant_id
                      JOIN items i ON i.id = p.produce_item_id WHERE pr.region_id = ? AND pr.tier IN ('staple','uncommon')
                      AND i.edible = 1 ORDER BY p.id", [$v['region_id']])->fetchAll(), ':snack');
    if ($snack) $out[] = [(int)$snack['id'], (string)$snack['name'], 2, (string)$snack['kind'], (string)$snack['name'], '🧺'];
    return $out;
}

function swatch(string $color, int $r = 11): string
{
    return '<svg width="' . ($r * 2) . '" height="' . ($r * 2) . '" viewBox="0 0 ' . ($r * 2) . ' ' . ($r * 2) . '" aria-hidden="true">'
        . '<circle cx="' . $r . '" cy="' . $r . '" r="' . ($r - 1) . '" fill="' . e($color) . '" stroke="#4a2c1a" stroke-width="1"/></svg>';
}

