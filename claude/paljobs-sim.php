<?php
// Pal jobs balance sim: php claude/paljobs-sim.php GAME_DIR [seeds] [away cap] [runs a day]
// Delves in the world are level 10 to 20 (14 delves, side-road min_level), so the delve table uses 10 / 15 / 20.
// GAME_DIR is an INSTALLED copy (e.g. the one tests/paljobs.sh made). Uses the real pj_roll_trip / pj_roll_delve.
// Value of an item = base_price x 62% (mid of the 45-80% shop drift) x rarity mult (sell_mult_* settings). Coins count 1:1.
// Garden duty pays no loot; it is valued as the hired help it replaces (HELPER_ROSTER wage per day for the same skills).
// Pals: the average stats of each rarity in includes/data/puzzle_pals.txt (common 1/1/1/0, uncommon 1/1/2/2, rare 2/2/1/1 grit/nimble/hardiness/luck).
$_SERVER['SCRIPT_NAME'] = '/index.php';
require rtrim($argv[1] ?? '', '/') . '/includes/bootstrap.php';
require_once APP_ROOT . '/includes/pal_jobs.php';
require_once APP_ROOT . '/includes/hired_help.php';
$N = max(20, (int)($argv[2] ?? 300));
const ARCH = ['common' => [1, 1, 1, 0], 'uncommon' => [1, 1, 2, 2], 'rare' => [2, 2, 1, 1]];
$mult = ['common' => 1.0, 'uncommon' => (int)(setting('sell_mult_uncommon') ?: 130) / 100, 'rare' => (int)(setting('sell_mult_rare') ?: 180) / 100];
$val = [];
foreach (q('SELECT g.item_id, g.rarity, i.base_price FROM gatherables g JOIN items i ON i.id = g.item_id WHERE g.active = 1')->fetchAll() as $r)
    $val[(int)$r['item_id']] = (int)$r['base_price'] * 0.62 * ($mult[$r['rarity']] ?? 1);
function pal(string $rar, int $a, int $hpFrac = 100): array
{
    [$g, $n, $h, $l] = ARCH[$rar];
    $pal = ['grit' => $g, 'nimble' => $n, 'hardiness' => $h, 'luck' => $l];
    $max = pj_max_hp($pal, $a);
    return ['pal' => $pal, 'a' => $a, 'g' => 1, 'hp' => (int)($max * $hpFrac / 100), 'max' => $max, 'name' => $rar];
}
function worth(array $items, array $val): float { $s = 0; foreach ($items as [$id, $q]) $s += ($val[(int)$id] ?? 0) * $q; return $s; }

// lands per tool that have something to find
$lands = [];
foreach (PJ_TOOLS as $t) foreach (array_keys(LANDSCAPES) as $l) if (gather_candidates($l, $t)) $lands[$t][] = $l;

echo "== Trips (value per trip, per hour away; avg over tools x lands x $N seeds)\n";
printf("%-9s %2s %4s %2s %3s | %7s %7s %6s %6s %5s\n", 'pal', 'A', 'tier', 'h', 'pot', 'value', '/hour', 'items', 'faint%', 'potU');
$tripRow = [];
foreach (['common', 'uncommon', 'rare'] as $rar) foreach ([1, 5, 10] as $a) foreach ([1, 2, 3] as $tier) foreach (PJ_TRIP_HOURS as $h) foreach ([0, 2] as $pot) {
    if ($rar !== 'uncommon' && $tier !== 2) continue;           // keep the table short: rarity only at tier 2
    $v = 0; $it = 0; $f = 0; $pu = 0; $hrs = 0; $n = 0;
    foreach ($lands as $tool => $ls) foreach ($ls as $land) for ($s = 0; $s < max(4, intdiv($N, 10)); $s++) {
        $r = pj_roll_trip(pal($rar, $a), $land, $tool, $tier, $h, $pot, "$tool|$land|$s|$a|$h");
        $v += worth($r['items'], $val); foreach ($r['items'] as $x) $it += $x[1];
        $f += $r['fainted'] ? 1 : 0; $pu += $r['potions_used'];
        $hrs += $r['fainted'] ? max(600, $h * 3600 * $r['rounds'] / ($h * 2)) / 3600 : $h; $n++;
    }
    $tripRow["$rar|$a|$tier|$h|$pot"] = [$v / $n, $v / $hrs];
    printf("%-9s %2d %4d %2d %3d | %7.1f %7.1f %6.1f %6.1f %5.2f\n", $rar, $a, $tier, $h, $pot, $v / $n, $v / $hrs, $it / $n, 100 * $f / $n, $pu / $n);
}

echo "\n== Delve re-runs (1 h; value per run incl. coins; $N seeds)\n";
printf("%-9s %2s %4s %3s | %7s %6s %6s %6s %5s\n", 'pal', 'A', 'dlvl', 'pot', 'value', 'coins', 'items', 'faint%', 'potU');
foreach (['common', 'uncommon', 'rare'] as $rar) foreach ([1, 5, 10] as $a) foreach ([10, 15, 20] as $lvl) foreach ([0, 2] as $pot) {
    if ($rar !== 'uncommon' && $pot) continue;
    $v = 0; $c = 0; $it = 0; $f = 0; $pu = 0;
    for ($s = 0; $s < $N; $s++) {
        $r = pj_roll_delve(pal($rar, $a), ['level' => $lvl, 'name' => 'x'], $pot, "d$s|$a|$lvl");
        $c += $r['coins']; $v += $r['coins'] + worth($r['items'], $val); foreach ($r['items'] as $x) $it += $x[1];
        $f += $r['fainted'] ? 1 : 0; $pu += $r['potions_used'];
    }
    printf("%-9s %2d %4d %3d | %7.1f %6.1f %6.2f %6.1f %5.2f\n", $rar, $a, $lvl, $pot, $v / $N, $c / $N, $it / $N, 100 * $f / $N, $pu / $N);
}

echo "\n== Real delve chest for comparison (gnome, per clear)\n";
foreach ([10, 15, 20] as $lvl) {
    $unc = []; $rare = [];
    foreach ($val as $id => $x) { $rr = q_val('SELECT rarity FROM gatherables WHERE item_id = ?', [$id]); if ($rr === 'rare') $rare[] = $x; elseif ($rr === 'uncommon') $unc[] = $x; }
    $avgU = $unc ? array_sum($unc) / count($unc) : 0; $avgR = $rare ? array_sum($rare) / count($rare) : 0;
    $pr = min(1, (30 + $lvl) / 100);
    printf("level %2d: coins %.0f + 2 items %.1f = %.1f (pal re-run cap is 60%% coins, 1.5 items, rare %d%%)\n", $lvl, 30 + 7.5 * $lvl, 2 * ($pr * $avgR + (1 - $pr) * $avgU), 30 + 7.5 * $lvl + 2 * ($pr * $avgR + (1 - $pr) * $avgU), 20 + $lvl);
}

echo "\n== Garden duty (no loot; worth the hired help it replaces)\n";
$wage = []; foreach (HELPER_ROSTER as $hr) $wage[$hr[3]] = $hr[4];
foreach ([1, 3, 4, 8, 9, 10] as $g) {
    $sk = implode(',', pj_garden_skills($g));
    $w = $wage[$sk] ?? ($wage['water,weed,harvest'] ?? 0);
    printf("Gardening %2d: %-19s visit every %d h, worth %3d a day = %.1f an hour\n", $g, $sk, pj_garden_step($g), $w, $w / 24);
}

$away = (int)($argv[3] ?? 3); $cap = (int)($argv[4] ?? 6);   // the defaults of pj_max_away / pj_runs_per_day (a test copy may hold other values)
echo "\n== A day with the caps (away $away, runs $cap), uncommon pal, tier 2, no potions\n";
foreach ([1, 5, 10] as $a) {
    $best = 0;
    foreach (PJ_TRIP_HOURS as $h) {
        $slots = $away;
        $runs = min($cap, $slots * intdiv(16, $h));   // a 16 h waking day, sends as soon as a pal is back
        $day = $runs * $tripRow["uncommon|$a|2|$h|0"][0];
        printf("A%-2d %dh trips: %2d runs = %6.1f a day\n", $a, $h, $runs, $day);
    }
}
