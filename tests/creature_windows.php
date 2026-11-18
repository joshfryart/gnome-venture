<?php
// php tests/creature_windows.php GAMEDIR : 2.7.08 region windows (claude/balance-2.7.08-notes.md sec 1). Needs an installed game (tests/creature_windows.sh).
//  1. every creature row of data/pf_creatures.txt has a region window (claude/creature-pass/SPEC.md sec 4.1): a row of level Lv fits region R when R holds one of
//     its lands (zones + REGION_EXTRA_LANDS) and Lv-2 <= R <= Lv+6 (bosses: R >= Lv-8); base rows read their level and lands from the world's creatures table.
//     Rows above the top region (they walk at the gnome's level, SPEC 4.1) must list only the top regions SEA, WCA, ESA, OC and one of them must hold a land.
//  2. a fresh world has the CREATURE_WINDOWS_2708 values (data/creatures.txt).
//  3. the boot step creature_windows_2708(): an old world (old level, lands, stats, Almanac text) comes out exactly like a fresh one; a second run changes nothing;
//     a creature an admin has moved away from the old value is left alone.
$_SERVER['SCRIPT_NAME'] = '/adventure.php';
require $argv[1] . '/includes/bootstrap.php';
require_once $argv[1] . '/includes/adventure_data.php';
require_once $argv[1] . '/includes/explore.php';
require_once $argv[1] . '/includes/pfdeck.php';
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

$done = true;
echo $bad ? "$bad FAILED\n" : "ok\n";
exit($bad ? 1 : 0);
