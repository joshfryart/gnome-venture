<?php
// php tests/creature_windows.php GAMEDIR : 2.7.08 region windows (claude/balance-2.7.08-notes.md sec 1). Needs an installed game (tests/creature_windows.sh).
//  1. every creature row of data/pf_creatures.txt has a region window (claude/creature-pass/SPEC.md sec 4.1): a row of level Lv fits region R when R holds one of
//     its lands (zones + REGION_EXTRA_LANDS) and Lv-2 <= R <= Lv+6 (bosses: R >= Lv-8); base rows read their level and lands from the world's creatures table.
//     Rows above the top region (they walk at the gnome's level, SPEC 4.1) must list only the top regions SEA, WCA, ESA, OC and one of them must hold a land.
//  2. a fresh world has the CREATURE_WINDOWS_2708 values (data/creatures.txt).
//  3. the boot step creature_windows_2708(): an old world (old level, lands, stats, Almanac text) comes out exactly like a fresh one; a second run changes nothing;
//     a creature an admin has moved away from the old value is left alone.
//  4. 2026-11-19: the four moved base rows' regional drop is gated to a region inside the window (data/pf_creatures.txt), and the boot step
//     creature_window_drops_1119() moves an old world's gate (only a drop still at the old gate; second run and admin edits: nothing).
$_SERVER['SCRIPT_NAME'] = '/adventure.php';
require $argv[1] . '/includes/bootstrap.php';
require_once $argv[1] . '/includes/adventure_data.php';
require_once $argv[1] . '/includes/explore.php';
require_once $argv[1] . '/includes/pfdeck.php';
require_once $argv[1] . '/includes/adventure.php';
$done = false; register_shutdown_function(function () use (&$done) { if (!$done) echo "FAIL the test stopped early (fatal error)\n"; });
$bad = 0; $ck = function (string $name, $got, $want) use (&$bad) { if ($got === $want) echo "ok   $name\n"; else { echo "FAIL $name (got " . json_encode($got) . ", want " . json_encode($want) . ")\n"; $bad++; } };

// ---- 1. every row has a window
$RL = REGION_LEVELS; $top = max($RL);
$LANDS = [];
foreach (q('SELECT id, code FROM regions')->fetchAll() as $r) if (isset($RL[$r['code']])) $LANDS[$r['code']] = array_flip(region_lands((int)$r['id']));
$ck('window: all 14 regions have lands', count(array_filter($LANDS)), 14);
$world = []; foreach (q('SELECT slug, size, level, landscapes FROM creatures')->fetchAll() as $c) $world[$c['slug']] = $c;
$none = []; $rows = 0;
foreach (pfd_creature_rows(true) as $slug => $r) {
    $w = $world[$slug] ?? null;
    if ($r['base'] && !$w) { $none[] = "$slug (base row, not in the world)"; continue; }
    $size = $r['size'] ?? (string)$w['size']; $lv = $r['level'] ?? (int)$w['level']; $lands = $r['lands'] ?? (string)$w['landscapes'];
    $regs = in_array('*', $r['regions'], true) ? array_keys($RL) : $r['regions'];
    $holds = fn(string $R) => $lands === 'any' || (bool)array_filter(explode(',', $lands), fn($l) => isset($LANDS[$R][$l]));
    $fit = array_filter($regs, fn($R) => isset($RL[$R]) && $holds($R) && ($size === 'boss' ? $RL[$R] >= $lv - 8 : ($RL[$R] >= $lv - 2 && $RL[$R] <= $lv + 6)));
    $rows++;
    if ($fit) continue;
    if ($lv >= $top && !array_diff($regs, ['SEA', 'WCA', 'ESA', 'OC']) && array_filter($regs, $holds)) continue;   // L35+: walks at the gnome's level in a top region (SPEC 4.1)
    $none[] = "$slug ($size L$lv $lands in " . implode(',', $regs) . ')';
}
$ck('window: rows checked (319)', $rows >= 300, true);
$ck('window: every creature row has a region window', $none, []);

// ---- 2. a fresh world has the new values
foreach (CREATURE_WINDOWS_2708 as $slug => [$was, $lv, $oldLands, $lands]) $ck("fresh: $slug L$lv $lands", [(int)($world[$slug]['level'] ?? 0), (string)($world[$slug]['landscapes'] ?? '')], [$lv, $lands]);

// ---- 3. the boot step on an old world
$cols = 'level, landscapes, hp, attack, defense, dmg_die, dmg_bonus, xp';
$snap = function () use ($cols): array {
    $o = [];
    foreach (array_keys(CREATURE_WINDOWS_2708) as $s) $o[$s] = q_one("SELECT $cols FROM creatures WHERE slug = ?", [$s]) + ['page' => q_one('SELECT body, sort_order FROM encyclopedia_entries WHERE unlock_key = ?', ['creature:' . $s])];
    return $o;
};
$fresh = $snap();
$sizeMult = ['small' => 0.8, 'medium' => 1.1, 'large' => 1.6, 'boss' => 2.4]; $sizeAtk = ['large' => 2, 'boss' => 2]; $sizeDef = ['medium' => 1, 'large' => 2, 'boss' => 3];
foreach (CREATURE_WINDOWS_2708 as $slug => [$was, $lv, $oldLands, $lands]) {   // back to how a 2.7.07 world has it (import_creatures_txt at the old level)
    $size = (string)$world[$slug]['size']; $m = $sizeMult[$size];
    q('UPDATE creatures SET level = ?, landscapes = ?, hp = ?, attack = ?, defense = ?, dmg_bonus = ?, xp = ? WHERE slug = ?',
      [$was, $oldLands, (int)round((5 + $was * 3) * $m), 1 + intdiv($was, 3) + ($sizeAtk[$size] ?? 0), 9 + intdiv($was, 3) + ($sizeDef[$size] ?? 0), intdiv($was, 4), (int)round($was * 6 * $m), $slug]);
    q('UPDATE encyclopedia_entries SET body = REPLACE(REPLACE(body, ?, ?), ?, ?), sort_order = ? WHERE unlock_key = ?',
      ['[b]Level:[/b] ' . $lv, '[b]Level:[/b] ' . $was, '[b]Found in:[/b] ' . str_replace(',', ', ', $lands) . ' ·', '[b]Found in:[/b] ' . str_replace(',', ', ', $oldLands) . ' ·', $was, 'creature:' . $slug]);
}
$old = $snap();
$ck('boot: the old world differs from the fresh one', $old !== $fresh, true);
$ck('boot: old Almanac text (glacier-bear)', str_contains((string)$old['glacier-bear']['page']['body'], '[b]Found in:[/b] tundra · [b]Level:[/b] 26'), true);
$ck('boot: first run changes all 8', creature_windows_2708(), 8);
$after = $snap();
foreach (array_keys(CREATURE_WINDOWS_2708) as $s) $ck("boot: $s is exactly as in a fresh world", $after[$s], $fresh[$s]);
$ck('boot: second run changes nothing (count)', creature_windows_2708(), 0);
$ck('boot: second run changes nothing (rows)', $snap(), $fresh);
// an admin's own edit (not the old value) stays
q('UPDATE creatures SET level = 19, landscapes = ? WHERE slug = ?', ['rainforest,forest', 'mischief-monkey']);
q('UPDATE creatures SET level = 15 WHERE slug = ?', ['leafcutter-column']);   // not leafcutter's old 17
$ck('boot: admin-edited rows are left alone', creature_windows_2708(), 0);
$ck('boot: admin edit kept', q_one('SELECT level, landscapes FROM creatures WHERE slug = ?', ['mischief-monkey']), ['level' => 19, 'landscapes' => 'rainforest,forest']);
// the step is wired into the upgrade chain
$ck('boot: bootstrap runs creature_windows_2708', (bool)preg_match("/boot_step\\('creature_windows_2708'.*?creature_windows_2708\\(\\)/s", (string)file_get_contents($argv[1] . '/includes/bootstrap.php')), true);

// ---- 4. 2026-11-19: the regional drops of the moved base rows sit inside their window (creature_window_drops_1119)
$dropReg = fn(string $slug, string $item) => q_val('SELECT cd.reg FROM creature_drops cd JOIN items i ON i.id = cd.item_id JOIN creatures c ON c.id = cd.creature_id WHERE c.slug = ? AND i.name = ?', [$slug, $item]);
$snapD = function () use ($dropReg): array { $o = []; foreach (CREATURE_WINDOW_DROPS_1119 as $s => [$item]) $o[$s] = $dropReg($s, $item); return $o; };
$winOf = function (string $slug) use ($RL, $LANDS): array {   // the SPEC 4.1 window regions of a base row, from the world's creatures table (as in 1.)
    $c = q_one('SELECT size, level, landscapes FROM creatures WHERE slug = ?', [$slug]); $lv = (int)$c['level'];
    return array_values(array_filter(array_keys($RL), fn($R) => array_filter(explode(',', (string)$c['landscapes']), fn($l) => isset($LANDS[$R][$l])) && ($c['size'] === 'boss' ? $RL[$R] >= $lv - 8 : ($RL[$R] >= $lv - 2 && $RL[$R] <= $lv + 6))));
};
q('UPDATE creatures SET level = 14, landscapes = ? WHERE slug = ?', ['rainforest', 'mischief-monkey']); q('UPDATE creatures SET level = 14 WHERE slug = ?', ['leafcutter-column']);   // undo the admin edits of 3.
$freshD = $snapD();
foreach (CREATURE_WINDOW_DROPS_1119 as $slug => [$item, $oldReg, $newReg]) {
    $ck("drops: fresh $slug $item is gated to $newReg", $freshD[$slug], $newReg);
    $ck("drops: $slug gate $newReg lies inside its window", array_values(array_diff(explode('/', $newReg), $winOf($slug))), []);
    $ck("drops: $slug old gate $oldReg lay outside its window", array_values(array_intersect(explode('/', $oldReg), $winOf($slug))), []);
    $ck("drops: $slug $item may roll in its window, not in the old regions", [creature_drop_open(['reg' => $freshD[$slug]], explode('/', $newReg)[0], 20), creature_drop_open(['reg' => $freshD[$slug]], explode('/', $oldReg)[0], 20)], [true, false]);
}
$deadGate = [];   // every base row: a region-gated drop names at least one region of the row's window
foreach (pfd_creature_rows(true) as $slug => $r) {
    if (!$r['base'] || !isset($world[$slug])) continue;
    $win = $winOf($slug);
    foreach (pfc_parse_drops($r['drops']) as $e) if ($e['reg'] !== null && $win && !array_intersect(explode('/', (string)$e['reg']), $win)) $deadGate[] = "$slug {$e['name']}@reg={$e['reg']} (window " . implode(',', $win) . ')';
}
$ck('drops: no base row has a regional drop gated outside its window', $deadGate, []);
foreach (CREATURE_WINDOW_DROPS_1119 as $slug => [$item, $oldReg, $newReg])   // back to how a 2.7.08 world has it
    q('UPDATE creature_drops SET reg = ? WHERE creature_id = (SELECT id FROM creatures WHERE slug = ?) AND item_id = (SELECT id FROM items WHERE name = ?)', [$oldReg, $slug, $item]);
$ck('drops: the old world has the old gates', $snapD(), array_map(fn($x) => $x[1], CREATURE_WINDOW_DROPS_1119));
$others = fn() => q("SELECT cd.id, cd.creature_id, cd.item_id, cd.chance, cd.reg FROM creature_drops cd WHERE cd.creature_id NOT IN (SELECT id FROM creatures WHERE slug IN ('arctic-fox', 'desert-tortoise', 'glacier-bear', 'lichen-reindeer')) ORDER BY cd.id")->fetchAll();
$restBefore = $others(); $nAll = (int)q_val('SELECT COUNT(*) FROM creature_drops');
$ck('drops: first run changes the 4 drop rows', creature_window_drops_1119(), 4);
$ck('drops: the old world comes out as a fresh one', $snapD(), $freshD);
$ck('drops: no other creature\'s drop row changed, none added or removed', [$others() === $restBefore, (int)q_val('SELECT COUNT(*) FROM creature_drops')], [true, $nAll]);
$ck('drops: second run changes nothing', [creature_window_drops_1119(), $snapD()], [0, $freshD]);
q('UPDATE creature_drops SET reg = ? WHERE creature_id = (SELECT id FROM creatures WHERE slug = ?) AND item_id = (SELECT id FROM items WHERE name = ?)', ['EE/EA', 'arctic-fox', 'Lemming Fluff']);   // an admin's own gate (not the old value) stays
$ck('drops: an admin-edited gate is left alone', [creature_window_drops_1119(), $dropReg('arctic-fox', 'Lemming Fluff')], [0, 'EE/EA']);
$ck('drops: bootstrap runs creature_window_drops_1119 after creature_windows_2708', (bool)preg_match("/boot_step\\('creature_windows_2708'.*?boot_step\\('creature_window_drops_1119'.*?creature_window_drops_1119\\(\\)/s", (string)file_get_contents($argv[1] . '/includes/bootstrap.php')), true);

$done = true;
echo $bad ? "$bad FAILED\n" : "ok\n";
exit($bad ? 1 : 0);
