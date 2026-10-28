<?php
declare(strict_types=1);

// v1.4.0 upgrade steps. Same idea as upgrade120.php: each step runs once (flag setting upg140_<step>), inside try/catch, and is safe to call again.

const UPGRADE_140_STEPS = [
    'animals' => 'More garden animals: Butterfly Bush and Snail Jar (items, critter kinds, crafts, Almanac pages)',
    'crafts' => 'Soil amendment crafts make more (only recipes still at their old shipped amounts)',
    'stopsoft' => 'Rest stops: the daily total becomes a soft limit of 100 (only if it was still the old 15)',   // v1.4.9
    'stopcap8' => 'Rest stops: most things per day at one stop becomes 8 (only if it was still the old 6)',   // v2.0.80: visits are 4 things now
    'gamesnolimit' => 'Games: no daily cap on the energy from playing (only if it was still the old 10)',   // v1.6.2: games_energy_cap 100 = no limit
];

/** Run every v1.4.0 step that has not been done yet. Returns the names of the steps that are done afterwards. */
function upgrade_140_run(): array
{
    $done = [];
    foreach (array_keys(UPGRADE_140_STEPS) as $name) {
        $flag = 'upg140_' . $name;
        if (setting($flag) === '1') { $done[] = $name; continue; }
        try {
            upgrade_tx(function () use ($name) {
                if ($name === 'animals') { require_once __DIR__ . '/animals140.php'; animals140_upgrade(); }
                if ($name === 'crafts') upgrade_140_crafts();
                if ($name === 'stopsoft') q("UPDATE settings SET value = '100' WHERE name = 'stop_daily_total' AND value = '15'");
                if ($name === 'stopcap8') q("UPDATE settings SET value = '8' WHERE name = 'stop_daily_cap' AND value = '6'");
                if ($name === 'gamesnolimit') q("UPDATE settings SET value = '100' WHERE name = 'games_energy_cap' AND value = '10'");   // v1.6.2:
            });
            set_setting($flag, '1');
            setting('__reload__');
            $done[] = $name;
        } catch (Throwable $e) {
            $msg = get_class($e) . ': ' . $e->getMessage() . ' in ' . basename($e->getFile()) . ':' . $e->getLine();
            error_log('upgrade 1.4.0 step ' . $name . ' failed: ' . $msg);
            if (function_exists('game_error_log')) game_error_log('Upgrade 1.4.0 step "' . $name . '" failed: ' . $msg);
        }
    }
    return $done;
}

/** v1.4.0: soil amendment crafts give more. Only touches a recipe still holding the old shipped amounts (admin edits survive). */
function upgrade_140_crafts(): void
{
    require_once __DIR__ . '/crafting.php';
    $rows = [   // slug, old qty, old ingredients, new qty, new ingredients
        ['seaweed-compost', 2, '{"bladderwrack":3}', 3, '{"bladderwrack":3}'],
        ['bog-compost', 2, '{"sphagnum":3}', 3, '{"sphagnum":3}'],
        ['clay-loam', 1, '{"river-clay":2,"plain-compost":1}', 2, '{"river-clay":3,"plain-compost":2}'],
        ['laterite-loam', 1, '{"laterite-clay":2,"plain-compost":1}', 2, '{"laterite-clay":3,"plain-compost":2}'],
        ['worm-bedding', 1, '{"plain-compost":2,"leaf-mould":1}', 2, '{"plain-compost":2,"leaf-mould":1}'],
        ['mushroom-leaf-mould', 2, '{"straw-mulch":2,"chanterelle":1}', 3, '{"straw-mulch":2,"chanterelle":1}'],
        ['shell-meal-mussel', 1, '{"blue-mussels":2}', 2, '{"blue-mussels":3}'],
        ['shell-meal-spiral', 1, '{"spiral-shell":3}', 2, '{"spiral-shell":4}'],
        ['worm-tea', 2, '{"worm-castings":1}', 3, '{"worm-castings":1}'],
        ['wood-ash', 2, '{"wood-chips":2}', 4, '{"wood-chips":2}'],
    ];
    foreach ($rows as [$slug, $oq, $oi, $nq, $ni]) {
        $r = q_one('SELECT id, output_qty, ingredients FROM recipes WHERE slug = ?', [$slug]);
        if (!$r || (int)$r['output_qty'] !== $oq || json_decode((string)$r['ingredients'], true) != json_decode($oi, true)) continue;
        q('UPDATE recipes SET output_qty = ?, ingredients = ? WHERE id = ?', [$nq, $ni, (int)$r['id']]);
        $e = q_one('SELECT id, body FROM encyclopedia_entries WHERE unlock_key = ?', ['recipe:' . $slug]);
        if ($e) q('UPDATE encyclopedia_entries SET body = ? WHERE id = ?', [preg_replace(['/\[b\]Makes:\[\/b\] \d+ ×/u', '/\[b\]Needs:\[\/b\] .*/u'],
            ['[b]Makes:[/b] ' . $nq . ' ×', '[b]Needs:[/b] ' . recipe_ingredient_text($ni)], (string)$e['body']), (int)$e['id']]);
    }
}
