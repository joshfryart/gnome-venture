<?php
// v0.9.7 XP/hour at gnome levels 10, 15 and 28, before and after the mid/late-game changes (SQLite-friendly; reads the installed world).
// Usage (from a temp copy that walk.sh / roads097.sh installed): php tests/balance_xp097.php GAME_DIR
// Model: spend all regenerated energy (energy_regen_amount per energy_regen_seconds) in a fixed mix of activities:
//   garden 40% (annual crops: harvest XP per energy of tilling, planting, watering and harvesting), fights on roads 30%
//   (a 3-step road leg costs 1 energy; 40% of steps meet a creature; every fight is won), cooking 20% (meal pot: cook_xp_tiers[1] XP, 1 energy),
//   crafting 10% (5 XP, 1 energy).
// "Before" = the 0.9.6 rules: no action scaling, and near-home roads at the region's own level (2 in the Maplewold).
// "After" = xp_action_scale_percent on, near-home roads at the gnome's level (easy roads off) or 3 under it (easy roads on).
$_SERVER['SCRIPT_NAME'] = '/gnome.php';
require $argv[1] . '/includes/bootstrap.php';
require_once $argv[1] . '/includes/adventure.php';
require_once $argv[1] . '/includes/garden_logic.php';
mt_srand(97);

$gardenXpE = [];
foreach (q('SELECT * FROM plants')->fetchAll() as $p) {
    if ($p['kind'] === 'cover' || (int)$p['perennial']) continue;
    $waters = max(1, (int)ceil((int)$p['grow_minutes'] / (max(1, (int)$p['water_interval_minutes']) * 1.3)));
    $gardenXpE[] = (int)$p['xp_per_harvest'] / (2 + harvest_energy_cost((int)$p['id']) + $waters);
}
sort($gardenXpE);
$gardenBase = $gardenXpE[intdiv(count($gardenXpE), 2)];   // median annual crop: XP per energy
$mealXp = (int)(array_map('intval', explode(',', setting('cook_xp_tiers')))[1] ?? 5);
[$amt, $secs] = [max(1, (int)setting('energy_regen_amount')), max(30, (int)setting('energy_regen_seconds'))];
$energyHr = 3600 / $secs * $amt;

function fight_xp_per_fight(int $gnomeLevel, int $areaLevel, int $n = 1500): float
{
    $sum = 0;
    for ($i = 0; $i < $n; $i++) {
        $c = pick_creature(['grassland', 'forest', 'wetland', 'coast'][$i % 4], $areaLevel, false);
        if (!$c) continue;
        $sum += outlevel_scale((int)$c['xp'], outlevel_percent(['level' => $gnomeLevel], $areaLevel));
    }
    return $sum / $n;
}
function row(int $L, string $label, float $scalePct, int $areaLevel, float $gardenBase, int $mealXp, float $energyHr): array
{
    $f = 1 + max(0, $L - (int)setting('xp_steep_from')) * $scalePct / 100;
    $fight = fight_xp_per_fight($L, $areaLevel) * $f * 1.2;   // per energy: 3 steps * 40%
    $mix = 0.4 * $gardenBase * $f + 0.3 * $fight + 0.2 * $mealXp * $f + 0.1 * 5 * $f;
    return ['L' => $L, 'label' => $label, 'factor' => $f, 'area' => $areaLevel, 'garden' => $gardenBase * $f, 'fight' => $fight, 'mix' => $mix, 'hr' => $mix * $energyHr];
}
$pct = (float)setting('xp_action_scale_percent');
$gap = (int)setting('easy_roads_gap');
printf("energy %.0f/hour; median annual crop %.2f XP/energy; meal %d XP; action scale %.0f%%\n\n", $energyHr, $gardenBase, $mealXp, $pct);
printf("%-4s %-22s %6s %5s %9s %9s %9s %9s\n", 'Lvl', 'rules', 'xp x', 'road', 'garden/E', 'fight/E', 'mix/E', 'XP/hour');
$out = [];
foreach ([10, 15, 28] as $L) {
    foreach ([['0.9.6 (before)', 0.0, max(2, 1)], ['0.9.7 easy roads off', $pct, $L], ['0.9.7 easy roads on', $pct, max(1, $L - $gap)]] as [$label, $sp, $area]) {
        $r = row($L, $label, $sp, $area, $gardenBase, $mealXp, $energyHr); $out[] = $r;
        printf("%-4d %-22s %6.2f %5d %9.2f %9.2f %9.2f %9.0f\n", $r['L'], $r['label'], $r['factor'], $r['area'], $r['garden'], $r['fight'], $r['mix'], $r['hr']);
    }
}
// Days to level 15 and 28 (total XP from level 1), at 500 / 750 / 1000 base XP a day. Base XP = what the day's actions paid in 0.9.6;
// in 0.9.7 80% of it is action XP and is multiplied by the factor of the level the gnome is at that day (quests and chapters, 20%, are not).
function days_to(int $target, int $base, float $pct, float $actionShare = 0.8): int
{
    $need = xp_for_level($target); $xp = 0; $d = 0;
    while ($xp < $need && $d < 5000) {
        $L = 1; while ($xp >= xp_for_level($L + 1)) $L++;
        $f = 1 + max(0, $L - (int)setting('xp_steep_from')) * $pct / 100;
        $xp += $base * ((1 - $actionShare) + $actionShare * $f); $d++;
    }
    return $d;
}
printf("\nXP needed: level 15 = %d, level 28 = %d\n", xp_for_level(15), xp_for_level(28));
printf("%-12s %12s %12s %12s %12s\n", 'XP/day (0.9.6)', 'L15 before', 'L15 after', 'L28 before', 'L28 after');
foreach ([500, 750, 1000] as $b) printf("%-12d %12d %12d %12d %12d\n", $b, days_to(15, $b, 0), days_to(15, $b, $pct), days_to(28, $b, 0), days_to(28, $b, $pct));
