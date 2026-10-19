<?php
declare(strict_types=1);

/**
 * v1.1.0, crop breeding (hybrids). Self-contained module, same shape as garden_world.php / social.php:
 * settings, schema, a data-file import that adds missing rows only, the harvest hook, the garden note and the Almanac "Breeding notes" page.
 * Rules: two parent plants on orthogonally neighbouring squares of one garden; when one is fully harvested and the gnome has MASTERED both
 * (and is level hybrid_min_level), there is a small chance of 1 hybrid seed. Hybrids never give hybrid seeds back (HARD mode): re-cross or trade.
 * Wiring: breeding110_settings() is merged by garden100_settings(); breeding110_schema() by schema.php; do_harvest() calls
 * breeding110_on_harvest() and breeding110_seed_item(); import runs from breeding110_boot() (lazy, once) and seed.php.
 */

function breeding110_settings(): array
{
    $pct = fn(string $label, int $def, int $min, int $max) => ['label' => $label, 'type' => 'int', 'default' => (string)$def, 'min' => $min, 'max' => $max];
    return [
        'hybrid_on'            => ['label' => 'Breeding: neighbouring mastered crops can cross into hybrids', 'type' => 'bool', 'default' => '1'],
        'hybrid_min_level'     => $pct('Breeding: gnome level needed before crops can cross', 10, 1, 100),
        'hybrid_chance_pct'    => $pct('Breeding: base chance (%) a full harvest of a parent gives a hybrid seed (both parents beside each other and mastered)', 6, 0, 100),
        'hybrid_beehive_pct'   => $pct('Breeding: extra chance (%) for each beehive level in the garden', 2, 0, 50),
        'hybrid_chance_max_pct' => $pct('Breeding: the chance never goes above this (%)', 20, 0, 100),
        'hybrid_fair_bonus'    => $pct('Breeding: Harvest Fair quality bonus for a hybrid crop (points)', 3, 0, 20),
    ];
}

/** [tables, indexes, columns] for schema_statements(). */
function breeding110_schema(string $PK, string $ID, string $END): array
{
    $t = [];
    $t[] = "CREATE TABLE IF NOT EXISTS hybrids (
        id $PK,
        slug VARCHAR(80) NOT NULL UNIQUE,
        plant_id $ID NOT NULL,
        parent_a_plant_id $ID NOT NULL,
        parent_b_plant_id $ID NOT NULL,
        trait VARCHAR(200) NULL,
        hint VARCHAR(255) NULL,
        icon VARCHAR(16) NOT NULL DEFAULT '🧬',
        enabled INT NOT NULL DEFAULT 1,
        chance_bonus INT NOT NULL DEFAULT 0
    )$END";
    $t[] = "CREATE TABLE IF NOT EXISTS user_hybrids (
        user_id $ID NOT NULL,
        hybrid_id $ID NOT NULL,
        first_at DATETIME NOT NULL,
        count INT NOT NULL DEFAULT 1,
        PRIMARY KEY (user_id, hybrid_id)
    )$END";
    $i = [
        'CREATE INDEX idx_hybrids_a ON hybrids (parent_a_plant_id)',
        'CREATE INDEX idx_hybrids_b ON hybrids (parent_b_plant_id)',
        'CREATE INDEX idx_hybrids_plant ON hybrids (plant_id)',
    ];
    return [$t, $i, []];
}

const BREEDING110_PAGE = 'Breeding notes';

/** Is this plant a hybrid? Returns its hybrids row or null. */
function breeding110_row(int $plantId): ?array
{
    static $cache = [];
    if (array_key_exists($plantId, $cache)) return $cache[$plantId];
    try { $r = q_one('SELECT * FROM hybrids WHERE plant_id = ?', [$plantId]); } catch (Throwable $e) { $r = null; }
    return $cache[$plantId] = ($r ?: null);
}

/** HARD mode: a hybrid plant gives one of its PARENTS' seeds back, never its own. Other plants: their own seed. */
function breeding110_seed_item(array $p): int
{
    $h = breeding110_row((int)$p['id']);
    if (!$h) return (int)$p['seed_item_id'];
    $parent = random_int(0, 1) ? (int)$h['parent_a_plant_id'] : (int)$h['parent_b_plant_id'];
    return (int)q_val('SELECT seed_item_id FROM plants WHERE id = ?', [$parent]) ?: (int)$p['seed_item_id'];
}

function breeding110_mastered(int $uid, int $plantId): bool
{
    return (bool)q_val('SELECT 1 FROM user_plant_knowledge k JOIN plants p ON p.id = k.plant_id WHERE k.user_id = ? AND k.plant_id = ? AND k.knowledge >= p.knowledge_max', [$uid, $plantId]);
}

/** Plant ids growing on the four squares touching a yard square. */
function breeding110_neighbour_ids(int $plotId, int $x, int $y): array
{
    $ids = [];
    foreach ([[1, 0], [-1, 0], [0, 1], [0, -1]] as [$dx, $dy]) {
        $id = q_val('SELECT plant_id FROM plot_tiles WHERE plot_id = ? AND plant_id IS NOT NULL AND COALESCE(yx, x) = CAST(? AS SIGNED) AND COALESCE(yy, y) = CAST(? AS SIGNED)', [$plotId, $x + $dx, $y + $dy]);
        if ($id) $ids[] = (int)$id;
    }
    return array_values(array_unique($ids));
}

/** Enabled hybrids this plant makes with any of these neighbour plants. */
function breeding110_crosses(int $plantId, array $nbIds): array
{
    if (!$nbIds) return [];
    $in = implode(',', array_map('intval', $nbIds));
    return q("SELECT * FROM hybrids WHERE enabled = 1 AND ((parent_a_plant_id = ? AND parent_b_plant_id IN ($in)) OR (parent_b_plant_id = ? AND parent_a_plant_id IN ($in)))", [$plantId, $plantId])->fetchAll();
}

/** v1.1.0: the chance (%) for a hybrid in this garden. */
function breeding110_chance(int $plotId, array $h): int
{
    $pct = (int)setting('hybrid_chance_pct') + (int)setting('hybrid_beehive_pct') * building_level($plotId, 'beehive') + (int)$h['chance_bonus'];
    return max(0, min((int)setting('hybrid_chance_max_pct'), $pct));
}

/**
 * Called from do_harvest() once the harvest is claimed (that claim is the once-per-harvest guard) and knowledge is updated.
 * Returns messages.
 */
function breeding110_on_harvest(array $u, array $t, array $p): array
{
    if (!(int)setting('hybrid_on') || $p['kind'] === 'cover' || (int)$u['level'] < (int)setting('hybrid_min_level')) return [];
    $uid = (int)$u['id'];
    $plotId = (int)$t['plot_id'];
    $nb = breeding110_neighbour_ids($plotId, (int)($t['yx'] ?? $t['x']), (int)($t['yy'] ?? $t['y']));
    $ok = [];
    foreach (breeding110_crosses((int)$p['id'], $nb) as $h) {
        if (breeding110_mastered($uid, (int)$h['parent_a_plant_id']) && breeding110_mastered($uid, (int)$h['parent_b_plant_id'])) $ok[] = $h;
    }
    if (!$ok) return [];
    $h = $ok[random_int(0, count($ok) - 1)];
    if (random_int(1, 100) > breeding110_chance($plotId, $h)) return [];
    $plant = q_one('SELECT name, seed_item_id FROM plants WHERE id = ?', [$h['plant_id']]);
    if (!$plant) return [];
    give_item($uid, (int)$plant['seed_item_id'], 1);
    $first = false;
    try {
        db_insert('user_hybrids', ['user_id' => $uid, 'hybrid_id' => $h['id'], 'first_at' => now(), 'count' => 1]);
        $first = true;
    } catch (PDOException $e) {
        q('UPDATE user_hybrids SET count = count + 1 WHERE user_id = ? AND hybrid_id = ?', [$uid, $h['id']]);
    }
    $pa = q_val('SELECT name FROM plants WHERE id = ?', [$h['parent_a_plant_id']]);
    $pb = q_val('SELECT name FROM plants WHERE id = ?', [$h['parent_b_plant_id']]);
    $msgs = ['🧬 A hybrid! ' . $pa . ' and ' . $pb . ' crossed: you found 1 × ' . q_val('SELECT name FROM items WHERE id = ?', [$plant['seed_item_id']]) . '.'];
    if ($first) {
        $msgs[] = '🧬 New discovery: ' . $plant['name'] . '! See Breeding notes in your Almanac.';
        if (unlock_entries($uid, 'plant:' . q_val('SELECT slug FROM plants WHERE id = ?', [$h['plant_id']]))) $msgs[] = '📖 New Almanac page: ' . $plant['name'] . '!';
    }
    return $msgs;
}

/** Small Harvest Fair quality bonus for a hybrid crop. */
function breeding110_fair_bonus(array $p): int
{
    return breeding110_row((int)$p['id']) ? (int)setting('hybrid_fair_bonus') : 0;
}

/** One short line for the garden page about the selected square, or ''. */
function breeding110_garden_note(array $u, array $sel, array $p): string
{
    if (!(int)setting('hybrid_on') || $p['kind'] === 'cover') return '';
    $nb = breeding110_neighbour_ids((int)$sel['plot_id'], (int)($sel['yx'] ?? $sel['x']), (int)($sel['yy'] ?? $sel['y']));
    $cr = breeding110_crosses((int)$p['id'], $nb);
    if (!$cr) return '';
    $min = (int)setting('hybrid_min_level');
    if ((int)$u['level'] < $min) return '<p class="help">🔒 Breeding opens at gnome level ' . $min . '</p>';
    foreach ($cr as $h) {
        if (breeding110_mastered((int)$u['id'], (int)$h['parent_a_plant_id']) && breeding110_mastered((int)$u['id'], (int)$h['parent_b_plant_id'])) return '<p class="help">🧬 These two could cross</p>';
    }
    return '<p class="help">🧬 These two could cross: master both to cross</p>';
}

/**
 * v1.2.3: a small folded line for visit.php: which hybrids the VIEWER has already discovered could cross between side-by-side crops
 * in someone's garden. Same rules as the garden note: off if breeding is off, locked below hybrid_min_level, and hybrids the viewer
 * has not found yet are never named or counted (no spoilers). '' when nothing to show.
 */
function breeding110_visit_note(array $viewer, int $plotId): string
{
    if (!(int)setting('hybrid_on') || (int)$viewer['level'] < (int)setting('hybrid_min_level')) return '';
    $map = [];
    foreach (q('SELECT t.plant_id, COALESCE(t.yx, t.x) AS px, COALESCE(t.yy, t.y) AS py FROM plot_tiles t JOIN plants p ON p.id = t.plant_id
                WHERE t.plot_id = ? AND t.plant_id IS NOT NULL AND p.kind <> \'cover\'', [$plotId])->fetchAll() as $r) {
        $map[(int)$r['px'] . ',' . (int)$r['py']] = (int)$r['plant_id'];
    }
    $pairs = [];
    foreach ($map as $k => $a) {
        [$x, $y] = array_map('intval', explode(',', $k));
        foreach ([[1, 0], [0, 1]] as [$dx, $dy]) {
            $b = $map[($x + $dx) . ',' . ($y + $dy)] ?? null;
            if ($b !== null && $b !== $a) $pairs[min($a, $b) . '-' . max($a, $b)] = [$a, $b];
        }
    }
    $found = [];
    foreach ($pairs as [$a, $b]) {
        foreach (breeding110_crosses($a, [$b]) as $h) {
            if (!q_val('SELECT 1 FROM user_hybrids WHERE user_id = ? AND hybrid_id = ?', [$viewer['id'], $h['id']])) continue;   // not found yet: stay a secret
            $found[(int)$h['id']] = e((string)$h['icon'] . ' ' . q_val('SELECT name FROM plants WHERE id = ?', [$h['plant_id']]))
                . ' (' . e((string)q_val('SELECT name FROM plants WHERE id = ?', [$h['parent_a_plant_id']])) . ' × ' . e((string)q_val('SELECT name FROM plants WHERE id = ?', [$h['parent_b_plant_id']])) . ')';
        }
    }
    if (!$found) return '';
    $n = count($found);
    return '<details class="crosshint"><summary>🧬 ' . $n . ' possible cross' . ($n === 1 ? '' : 'es') . ' here</summary><p class="help">' . implode(' · ', $found) . '</p></details>';
}

/** The "Breeding notes" Almanac page body (HTML, escaped). */
function breeding110_notes(array $u): string
{
    $uid = (int)$u['id'];
    $min = (int)setting('hybrid_min_level');
    $out = '';
    if (!(int)setting('hybrid_on')) $out .= '<p class="help">🧬 Breeding is switched off right now.</p>';
    elseif ((int)$u['level'] < $min) $out .= '<p class="help"><b>🔒 Breeding opens at gnome level ' . $min . '.</b> You are level ' . (int)$u['level'] . '.</p>';
    $rows = q('SELECT h.*, pa.name AS an, pb.name AS bn, hp.name AS hn, uh.count AS found_count FROM hybrids h
               JOIN plants pa ON pa.id = h.parent_a_plant_id JOIN plants pb ON pb.id = h.parent_b_plant_id JOIN plants hp ON hp.id = h.plant_id
               LEFT JOIN user_hybrids uh ON uh.hybrid_id = h.id AND uh.user_id = ? WHERE h.enabled = 1 ORDER BY hp.name', [$uid])->fetchAll();
    if (!$rows) return $out;
    $got = count(array_filter($rows, fn($r) => $r['found_count'] !== null));
    $out .= '<p><b>🧬 Hybrids found: ' . $got . '/' . count($rows) . '</b></p><ul class="hybridlist">';
    $vague = [];   // undiscovered: the same hint is shown once with a count, to keep the page short
    foreach ($rows as $r) {
        if ($r['found_count'] !== null) {
            $out .= '<li>' . e($r['icon'] . ' ' . $r['hn']) . ': ' . e($r['an']) . ' × ' . e($r['bn']) . '. ' . e((string)$r['trait']) . '. <small>Bred ' . (int)$r['found_count'] . '×</small></li>';
        } else {
            $hint = breeding110_hint($r);
            $vague[$hint] = ($vague[$hint] ?? 0) + 1;
        }
    }
    foreach ($vague as $hint => $n) $out .= '<li class="muted">❓ ' . e($hint) . ($n > 1 ? ' <small>(' . $n . ' to find)</small>' : '') . '</li>';
    return $out . '</ul>';
}

/** A vague hint: the admin's own, or one made from the parents' kinds. */
function breeding110_hint(array $h): string
{
    if (trim((string)($h['hint'] ?? '')) !== '') return (string)$h['hint'];
    $ka = (string)q_val('SELECT kind FROM plants WHERE id = ?', [$h['parent_a_plant_id']]);
    $kb = (string)q_val('SELECT kind FROM plants WHERE id = ?', [$h['parent_b_plant_id']]);
    $word = ['fruit' => 'berries or soft fruits', 'tree' => 'orchard trees', 'nut' => 'nut trees', 'vegetable' => 'garden vegetables', 'grain' => 'grains', 'flower' => 'blooms', 'tuber' => 'root crops', 'legume' => 'beans or peas', 'herb' => 'herbs', 'spice' => 'spices'];
    if ($ka === $kb) return 'Two ' . ($word[$ka] ?? 'crops') . ' of close kin, side by side, might surprise you…';
    return 'Two very different cousins, side by side, might surprise you…';
}

/** Make the data-file hybrids that do not exist yet. Returns [hybrids added, skipped (parent missing)]. */
function breeding110_import(): array
{
    require_once __DIR__ . '/garden_world.php';
    require_once __DIR__ . '/world.php';
    ensure_grow_times();   // parents must be on the final timing scale before the average is taken (idempotent; hybrids are marked done below)
    $added = 0; $skipped = 0;
    $own = !db()->inTransaction();
    if ($own) db()->beginTransaction();
    try {
        foreach (garden_data_rows('hybrids.txt') as $r) {
            if (count($r) < 8) continue;
            [$slug, $name, $sa, $sb, $kind, $trait, $desc, $icon] = $r;
            if (q_val('SELECT 1 FROM hybrids WHERE slug = ?', [$slug])) continue;
            $A = q_one('SELECT * FROM plants WHERE slug = ?', [$sa]);
            $B = q_one('SELECT * FROM plants WHERE slug = ?', [$sb]);
            if (!$A || !$B) { $skipped++; continue; }
            $isFlower = $kind === 'flower';
            $avg = fn(string $k) => ((float)$A[$k] + (float)$B[$k]) / 2;
            $seedA = q_one('SELECT * FROM items WHERE id = ?', [$A['seed_item_id']]);
            $seedB = q_one('SELECT * FROM items WHERE id = ?', [$B['seed_item_id']]);
            $prA = $A['produce_item_id'] ? q_one('SELECT * FROM items WHERE id = ?', [$A['produce_item_id']]) : null;
            $prB = $B['produce_item_id'] ? q_one('SELECT * FROM items WHERE id = ?', [$B['produce_item_id']]) : null;
            $rarity = min(95, max((int)($seedA['rarity'] ?? 1), (int)($seedB['rarity'] ?? 1)) + 10);
            $seedPrice = (int)round(1.5 * max((int)($seedA['base_price'] ?? 10), (int)($seedB['base_price'] ?? 10)));
            $prodPrice = (int)round(1.5 * max((int)($prA['base_price'] ?? 10), (int)($prB['base_price'] ?? 10)));
            $treeLike = in_array($kind, ['tree', 'nut'], true);
            $seedId = (int)q_val('SELECT id FROM items WHERE slug = ?', [$slug . '-seed']);
            if (!$seedId) {
                $seedId = db_insert('items', ['name' => $name . ($treeLike ? ' Seedling' : ($isFlower && (int)$A['perennial'] ? ' Cutting' : ' Seeds')), 'slug' => $slug . '-seed', 'category' => 'seed',
                    'rarity' => $rarity, 'base_price' => $seedPrice, 'description' => 'A hybrid! Plant it to grow ' . $name . '. Hybrids do not make their own seeds: cross the parents again, or trade for more.', 'tradable' => 1]);
            }
            $pslug = $isFlower ? 'cut-' . $slug : $slug;
            $produceId = (int)q_val('SELECT id FROM items WHERE slug = ?', [$pslug]);
            if (!$produceId) {
                $src = ($prA && (!$prB || (int)$prA['base_price'] >= (int)$prB['base_price'])) ? $prA : $prB;
                $edible = $isFlower ? 0 : (int)(($prA['edible'] ?? 0) || ($prB['edible'] ?? 0));
                $fx = $src && $src['effects'] ? json_decode((string)$src['effects'], true) : null;
                if (is_array($fx)) unset($fx['perm']);   // no permanent stat bonus from a hybrid
                $produceId = db_insert('items', ['name' => $isFlower ? 'Cut ' . $name : $name, 'slug' => $pslug, 'category' => $isFlower ? 'flower' : 'produce',
                    'rarity' => $rarity, 'base_price' => $prodPrice, 'description' => $desc, 'edible' => $edible,
                    'effects' => ($edible && is_array($fx)) ? json_encode($fx) : null, 'tradable' => 1]);
            }
            $plantId = (int)q_val('SELECT id FROM plants WHERE slug = ?', [$slug]);
            if (!$plantId) {
                $both = (int)$A['perennial'] && (int)$B['perennial'];
                $grow = max(1, (int)round($avg('grow_minutes') * 0.85));
                $row = [
                    'name' => $name, 'slug' => $slug, 'kind' => $kind, 'perennial' => $both ? 1 : 0,
                    'regrow_minutes' => $both ? max(30, (int)round($avg('regrow_minutes') * 0.85)) : 0,
                    'knowledge_per_harvest' => (int)round($avg('knowledge_per_harvest')), 'common' => 0,
                    'region_code' => $A['region_code'], 'pollinator' => $A['pollinator'] ?: $B['pollinator'],
                    'soil_effect' => (int)round($avg('soil_effect')), 'seed_item_id' => $seedId, 'produce_item_id' => $produceId,
                    'grow_minutes' => $grow, 'water_interval_minutes' => (int)round($avg('water_interval_minutes')), 'stages' => 4,
                    'yield_min' => max((int)$A['yield_min'], (int)$B['yield_min']) , 'yield_max' => max((int)$A['yield_max'], (int)$B['yield_max']) + 1,
                    'xp_per_harvest' => (int)round($avg('xp_per_harvest') * 1.25), 'knowledge_max' => (int)round($avg('knowledge_max')),
                    'min_soil' => max((int)$A['min_soil'], (int)$B['min_soil']), 'description' => $desc,
                    'timing_v' => 1,
                    'seasons' => (trim((string)$A['seasons']) === trim((string)$B['seasons'])) ? $A['seasons'] : '',
                ];
                if (array_key_exists('traits', $A)) $row['traits'] = (string)($A['traits'] ?? '');
                if (array_key_exists('nutrient', $A) && $A['nutrient'] !== null) $row['nutrient'] = $A['nutrient'];
                $plantId = db_insert('plants', $row);
            }
            db_insert('hybrids', ['slug' => $slug, 'plant_id' => $plantId, 'parent_a_plant_id' => $A['id'], 'parent_b_plant_id' => $B['id'],
                'trait' => $trait, 'hint' => null, 'icon' => $icon, 'enabled' => 1, 'chance_bonus' => 0]);
            if (!q_val('SELECT 1 FROM encyclopedia_entries WHERE unlock_key = ?', ['plant:' . $slug])) {
                db_insert('encyclopedia_entries', ['chapter' => $isFlower ? 'Flowers' : 'Plants', 'category' => 'Hybrids', 'title' => $name,
                    'body' => $desc . "\n\n[b]A hybrid of:[/b] " . $A['name'] . ' and ' . $B['name'] . ".\n[b]Trait:[/b] " . $trait . ".\n\nHybrids do not save their own seeds. Cross the parents again, or trade for more.",
                    'unlock_key' => 'plant:' . $slug, 'hint' => 'A hybrid. Find it by breeding two mastered crops that grow side by side.', 'sort_order' => 0]);
            }
            $added++;
        }
        // The Breeding notes page (everyone gets it; the live list is drawn by almanac_notes.php)
        if (!q_val("SELECT 1 FROM encyclopedia_entries WHERE chapter = 'General' AND title = ?", [BREEDING110_PAGE])) {
            $eid = db_insert('encyclopedia_entries', ['chapter' => 'General', 'category' => 'Garden life', 'title' => BREEDING110_PAGE, 'unlock_key' => 'start', 'hint' => '', 'sort_order' => 44,
                'body' => "🧬 Some plants can cross into [b]hybrids[/b].\n\nPlant two crops side by side (not diagonal) in one garden and [b]master both[/b] (full knowledge). Each time you fully harvest one of them there is a small chance of a [b]hybrid seed[/b]. Beehives raise the chance a little.\n\nA hybrid never saves its own seed: it gives its parents' seeds instead. To get more, cross the parents again, or trade for hybrid seeds. Hybrids sell for more and score a little higher at the Harvest Fair.\n\nBelow, found hybrids are written in full. The rest are only hints."]);
            foreach (q("SELECT DISTINCT user_id FROM user_encyclopedia")->fetchAll(PDO::FETCH_COLUMN) as $uid) {
                try { db_insert('user_encyclopedia', ['user_id' => $uid, 'entry_id' => $eid, 'unlocked_at' => now()]); } catch (PDOException $e) {}
            }
        }
        if ($own) db()->commit();
    } catch (Throwable $e) {
        if ($own && db()->inTransaction()) db()->rollBack();
        throw $e;
    }
    set_setting('upg110_hybrids', '1');
    setting('__reload__');
    return [$added, $skipped];
}

/** Lazy one-off import for worlds upgraded from 1.0.0 (cheap check on every call; safe if the tables are missing). */
function breeding110_boot(): void
{
    static $done = false;
    if ($done) return;
    $done = true;
    if (setting('upg110_hybrids') === '1') return;
    try { breeding110_import(); }
    catch (Throwable $e) { if (function_exists('game_error_log')) game_error_log('Breeding import failed: ' . $e->getMessage()); }
}
