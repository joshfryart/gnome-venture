<?php
declare(strict_types=1);
/**
 * World v2 creatures (2026-11-28, claude/PROPOSAL-HOLLOW-MASTER.md section 10, claude/proposal-creatures-38-55.txt). Behind world_v2_open (default 0):
 * while it is 0 none of this exists in the world, and data/pf_creatures_v2.txt is not read (pfd_creature_rows()).
 *
 * Once it is on, creatures_v2_boot() runs once (bootstrap.php; setting creatures_v2_done) and:
 *  1. makes the new regional rare items of CREATURES_V2_ITEMS, so the drops bind to them with their own description
 *  2. imports the 60 creatures of data/creatures_v2.txt (53 ordinary + 7 roaming bosses, levels 38-55; the importer only adds missing slugs)
 *  3. turns the seven tier 4-5 lair guardians (boss-<lair slug>, ensure_lair_bosses()) into the creatures of data/creatures_v2_lairs.txt:
 *     name, level (band top 45 / 55), drops, description, cond. The lair paths themselves are levelled by world_v2_ladder().
 * Their region, ability, style and pieces for the board come from data/pf_creatures_v2.txt.
 */

/**
 * The new regional rare drops: name => [description, rarity, base price]. Two of the proposal's seven already exist and the drops bind to them:
 * Kola Nut (the crop, crops.txt) and Silk Cocoon (the Silkworm Shelf's part, animals120.php).
 */
const CREATURES_V2_ITEMS = [
    'Frankincense Tear' => ['A golden bead of resin from the Dunewhisper. Warm it and the whole burrow smells like a temple.', 88, 320],
    'Saffron Thread' => ['A single red thread of Spicepeak saffron, worth more than its weight in almost anything.', 88, 320],
    'Tanzanite Chip' => ['A violet-blue chip of stone from the foot of Snowcrown Peak. It changes colour when you turn it.', 90, 340],
    'Agarwood Chip' => ['A dark, resin-soaked chip of the Monsoon Tangle’s rarest wood. One splinter scents a room for a week.', 92, 380],
    'Black Opal' => ['A black stone from the Coralscatter with a fire of every colour inside it.', 93, 400],
];

function creatures_v2_on(): bool
{
    return setting('world_v2_open') === '1';
}

/** Bootstrap hook: the steps above, once the setting is on. One request at a time (upgrade_lock); all or nothing. */
function creatures_v2_boot(): void
{
    if (!creatures_v2_on() || setting('creatures_v2_done') === '1') return;
    if (!q_val("SELECT 1 FROM locations WHERE kind = 'market'")) return;   // world not imported yet
    if (!upgrade_lock(5000)) return;
    setting('__reload__');
    if (setting('creatures_v2_done') === '1') return;
    $db = db();
    $db->beginTransaction();
    try {
        creatures_v2_import();
        creatures_v2_lairs();
        $db->commit();
    } catch (Throwable $e) {
        $db->rollBack();
        throw $e;
    }
    set_setting('creatures_v2_done', '1');
    setting('__reload__');
}

/** 1 and 2: the new items, then the creatures of data/creatures_v2.txt. Safe to repeat: only what is missing is added. Returns the creatures added. */
function creatures_v2_import(): int
{
    require_once __DIR__ . '/catalog.php';
    require_once __DIR__ . '/adventure_data.php';
    foreach (CREATURES_V2_ITEMS as $name => [$desc, $rarity, $price]) {
        if (pfc_item_for_drop($name)) continue;
        db_insert('items', ['name' => $name, 'slug' => slugify($name), 'category' => 'part', 'rarity' => $rarity, 'base_price' => $price, 'description' => $desc]);
    }
    $stats = ['items' => 0, 'pages' => 0, 'creatures' => 0];
    import_creatures_txt($stats, 'creatures_v2.txt');
    if (function_exists('road_rows')) road_rows('creatures', true);
    return (int)$stats['creatures'];
}

/** Rows of data/creatures_v2_lairs.txt: lair name => [name, level, drops, description, cond]. */
function creatures_v2_lair_rows(): array
{
    require_once __DIR__ . '/catalog.php';
    $out = [];
    foreach (catalog_lines('creatures_v2_lairs.txt') as $r) if (count($r) >= 5) $out[$r[0]] = [$r[1], (int)$r[2], $r[3], $r[4], $r[5] ?? ''];
    return $out;
}

/** 3. Each listed lair's guardian becomes its creature: level and stats (world_v2_lair_boss_level), name, description, cond, drops and Almanac page. Safe to repeat. */
function creatures_v2_lairs(): int
{
    require_once __DIR__ . '/adventure_data.php';
    require_once __DIR__ . '/world_v2.php';
    $n = 0;
    foreach (creatures_v2_lair_rows() as $lair => [$name, $lv, $drops, $desc, $cond]) {
        $slug = 'boss-' . (string)q_val("SELECT l.slug FROM landmarks lm JOIN locations l ON l.id = lm.location_id WHERE lm.kind = 'lair' AND lm.name = ? LIMIT 1", [$lair]);
        $cid = (int)q_val('SELECT id FROM creatures WHERE slug = ?', [$slug]);
        if (!$cid) continue;
        world_v2_lair_boss_level($slug, $lv);
        q('UPDATE creatures SET name = ?, description = ?, cond = ? WHERE id = ?', [$name, $desc, $cond !== '' ? $cond : null, $cid]);
        q('DELETE FROM creature_drops WHERE creature_id = ?', [$cid]);
        $names = [];
        foreach (pfc_parse_drops($drops) as $e) {
            if ($e['special'] !== '') { db_insert('creature_drops', ['creature_id' => $cid, 'special' => $e['special'], 'chance' => $e['chance']]); continue; }
            $iid = pfc_item_for_drop($e['name']);
            if (!$iid) continue;   // every name is a shipped item or one of CREATURES_V2_ITEMS (tests/creatures_v2.php)
            db_insert('creature_drops', ['creature_id' => $cid, 'item_id' => $iid, 'chance' => $e['chance']]);
            $names[] = $e['name'];
        }
        q('UPDATE encyclopedia_entries SET title = ?, body = ?, sort_order = ? WHERE unlock_key = ?',
          [$name, $desc . "\n\n[b]Found in:[/b] " . $lair . ' only · [b]Level:[/b] ' . $lv . ($names ? "\n[b]Can drop:[/b] " . implode(', ', $names) . '.' : ''), $lv, 'creature:' . $slug]);
        $n++;
    }
    return $n;
}
