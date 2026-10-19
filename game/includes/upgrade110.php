<?php
declare(strict_types=1);

// v1.1.0 upgrade steps. Same idea as upgrade100.php: each step runs once (flag setting upg110_<step>), inside try/catch, and is safe to call again.

const UPGRADE_110_STEPS = [
    'cook'  => 'Home-cooked dishes give 115% energy (only where the setting was still the old 150)',
    'eggs'  => 'Egg dishes (Hen Egg item first, then the recipes and their Almanac pages)',
    'hybrids' => 'Crop breeding: hybrid plants, seeds and produce from data/hybrids.txt (adds missing only)',
    'orders' => 'At most 3 townsfolk orders per town (only where the setting was still the old 5)',
];

/** Run every v1.1.0 step that has not been done yet. Returns the names of the steps that are done afterwards. */
function upgrade_110_run(): array
{
    $done = [];
    foreach (array_keys(UPGRADE_110_STEPS) as $name) {
        $flag = 'upg110_' . $name;
        if (setting($flag) === '1') { $done[] = $name; continue; }
        try {
            upgrade_tx(function () use ($name) {
                switch ($name) {
                    case 'cook':
                        // v1.1.0: 150 -> 115, but only a row that still says exactly 150; any other value was chosen by an admin
                        q("UPDATE settings SET value = '115' WHERE name = 'cook_energy_percent' AND value = '150'");
                        break;
                    case 'hybrids':
                        require_once __DIR__ . '/breeding110.php';
                        breeding110_import();
                        break;
                    case 'orders':
                        q("UPDATE settings SET value = '3' WHERE name = 'orders_board_max' AND value = '5'");
                        break;
                    case 'eggs':
                        require_once __DIR__ . '/garden_world.php';
                        garden100_items();                 // the Hen Egg item must exist before egg recipes are priced and imported
                        require_once __DIR__ . '/crafting.php';
                        ensure_crafts();                   // imports any missing recipes (+ their Almanac pages); never changes existing ones
                        garden110_egg_page();
                        break;
                }
            });
            set_setting($flag, '1');
            setting('__reload__');
            $done[] = $name;
        } catch (Throwable $e) {
            $msg = get_class($e) . ': ' . $e->getMessage() . ' in ' . basename($e->getFile()) . ':' . $e->getLine();
            error_log('upgrade 1.1.0 step ' . $name . ' failed: ' . $msg);
            if (function_exists('game_error_log')) game_error_log('Upgrade 1.1.0 step "' . $name . '" failed: ' . $msg);
        }
    }
    return $done;
}

/** The Hen Eggs Almanac page. give_item() opens it the first time an egg arrives, and collected_slugs() counts item: pages as "collected" for recipe discovery, even after the eggs are used up. */
function garden110_egg_page(): void
{
    if (q_val("SELECT 1 FROM encyclopedia_entries WHERE unlock_key = 'item:hen-egg'")) return;
    db_insert('encyclopedia_entries', ['chapter' => 'General', 'category' => 'Garden animals', 'title' => 'Hen Eggs', 'sort_order' => 43,
        'body' => "Biddy's eggs are warm, brown and good in the kitchen. Eggs cook into scrambled eggs, pancakes, tortillas, quiche and more: look in [b]Recipes[/b] once you have one.\n\nOnce you have held an egg, every egg dish counts it as found, even after you have cooked it.",
        'unlock_key' => 'item:hen-egg', 'hint' => 'Trade Biddy Food Scraps at the garden fence.']);
    // Everyone who already holds or has held an egg gets the page now
    $eggId = (int)q_val("SELECT id FROM items WHERE slug = 'hen-egg'");
    $entry = (int)q_val("SELECT id FROM encyclopedia_entries WHERE unlock_key = 'item:hen-egg'");
    if ($eggId && $entry) {
        foreach (q('SELECT user_id FROM user_items WHERE item_id = ?', [$eggId])->fetchAll(PDO::FETCH_COLUMN) as $uid) {
            try { db_insert('user_encyclopedia', ['user_id' => $uid, 'entry_id' => $entry, 'unlocked_at' => now()]); } catch (PDOException $e) {}
        }
    }
}
