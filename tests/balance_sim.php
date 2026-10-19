<?php
// Balance simulation (v0.7.63 numbers; v0.7.94: harvest energy by tier, cooking energy loop). Run from game/: php -d ... sim.php
$_SERVER['REQUEST_METHOD']='GET'; $_SERVER['HTTP_HOST']='x'; $_SERVER['REQUEST_URI']='/';
require 'includes/bootstrap.php'; require 'includes/garden_logic.php'; require_once 'includes/items.php';
$IL = item_lookups();
$S = fn($k) => (int)setting($k);
echo "settings: bed_add_cost=", $S('bed_add_cost'), " land_deed_cost=", $S('land_deed_cost'), " start_plot=", $S('starting_plot_size'), " max_plot=", $S('max_plot_size'), " seed_save=", $S('seed_save_chance'), "\n";
$rows = [];
foreach (q('SELECT p.*, si.base_price AS seedp, pi.id AS pid, pi.name AS pname, pi.slug AS pslug, pi.base_price AS prodbase, pi.category AS pcat, pi.effects, pi.rarity FROM plants p JOIN items si ON si.id = p.seed_item_id JOIN items pi ON pi.id = p.produce_item_id')->fetchAll() as $p) {
    if ($p['kind'] === 'cover') continue;
    $item = ['id' => $p['pid'], 'name' => $p['pname'], 'base_price' => $p['prodbase'], 'category' => $p['pcat'], 'effects' => $p['effects'], 'rarity' => $p['rarity']];
    [$r] = item_rarity($item, $IL);
    $price = sell_price($item);
    $per = (int)$p['perennial'];
    $cycle = $per ? max(1, (int)$p['regrow_minutes']) : (int)$p['grow_minutes'];
    $wint = max(1, (int)$p['water_interval_minutes']) * 1.3;     // moisture ~30
    $waters = max(1, (int)ceil($cycle / $wint));
    $yield = ((int)$p['yield_min'] + (int)$p['yield_max']) / 2 + 0.5;  // ~luck/soil/companion bonuses
    if ($per) {
        $lifeDays = in_array($p['kind'], ['tree','nut'], true) ? $S('life_tree_days') : ($p['kind'] === 'fruit' ? $S('life_fruit_days') : $S('life_other_days'));
        $yield *= (100 + $S('life_end_yield')) / 200;
        $hE = harvest_energy_cost((int)$p['id']);   // v0.7.86: 1/2/3 by tier
        $energy = $hE + $waters;  // harvest + water
        $harvestsLife = ($lifeDays * 1440 - (int)$p['grow_minutes']) / $cycle;
        $seedCost = $p['seedp'] / max(1, $harvestsLife) + $waters * 0; // seed spread over the life (if harvested every time)
        $firstWait = (int)$p['grow_minutes'];
    } else {
        $energy = 2 + harvest_energy_cost((int)$p['id']) + $waters;  // till, plant, harvest (by tier) + waters
        $seedCost = $p['seedp'] * max(0, 1 - min(1, $S('seed_save_chance')/100 * 1.5));
        $firstWait = $cycle;
    }
    $rev = $yield * $price - $seedCost;
    $rows[] = ['pslug' => $p['pslug'], 'name' => $p['name'], 'kind' => $p['kind'], 'r' => $r, 'per' => $per, 'cyc' => $cycle, 'first' => $firstWait, 'E' => $energy, 'price' => $price,
        'seed' => (int)$p['seedp'], 'yield' => round($yield, 1), 'rev' => round($rev), 'pe' => round($rev / $energy, 1), 'psqh' => round($rev / ($cycle / 60), 1),
        'xp' => (int)$p['xp_per_harvest'], 'xpe' => round((int)$p['xp_per_harvest'] / $energy, 1)];
}
// summary by rarity × perennial
$g = [];
foreach ($rows as $x) $g[$x['r'] . ($x['per'] ? '-per' : '-ann')][] = $x;
ksort($g);
printf("%-7s %4s %6s %6s %6s %6s %6s %6s %6s %6s\n", 'group', 'n', 'cycle', 'price', 'seed', 'P/cyc', 'P/E', 'P/sq·h', 'xp', 'xp/E');
$med = function ($a) { sort($a); return $a[intdiv(count($a), 2)]; };
foreach ($g as $k => $list) {
    printf("%-7s %4d %6d %6d %6d %6d %6.1f %6.1f %6d %6.1f\n", $k, count($list), $med(array_column($list, 'cyc')), $med(array_column($list, 'price')), $med(array_column($list, 'seed')),
        $med(array_column($list, 'rev')), $med(array_column($list, 'pe')), $med(array_column($list, 'psqh')), $med(array_column($list, 'xp')), $med(array_column($list, 'xpe')));
}
usort($rows, fn($a, $b) => $b['pe'] <=> $a['pe']);
echo "\nTop 8 Petals per energy:\n"; foreach (array_slice($rows, 0, 8) as $x) printf("  %-22s %s %s cyc=%dm E=%d price=%d seed=%d P/E=%.1f P/sq·h=%.1f\n", $x['name'], $x['r'], $x['per'] ? 'per' : 'ann', $x['cyc'], $x['E'], $x['price'], $x['seed'], $x['pe'], $x['psqh']);
echo "Bottom 5:\n"; foreach (array_slice($rows, -5) as $x) printf("  %-22s %s %s cyc=%dm E=%d price=%d seed=%d P/E=%.1f\n", $x['name'], $x['r'], $x['per'] ? 'per' : 'ann', $x['cyc'], $x['E'], $x['price'], $x['seed'], $x['pe']);
usort($rows, fn($a, $b) => $b['xpe'] <=> $a['xpe']);
echo "Top 5 XP per energy:\n"; foreach (array_slice($rows, 0, 5) as $x) printf("  %-22s %s %s xp=%d E=%d xp/E=%.1f\n", $x['name'], $x['r'], $x['per'] ? 'per' : 'ann', $x['xp'], $x['E'], $x['xpe']);
@file_put_contents(sys_get_temp_dir() . '/gv-crops.json', json_encode($rows));

// Player pace: energy regen 1 per energy_regen_minutes; per level
echo "\nPace per hour of steady play (energy-limited):\n";
$regen = 60 / max(1, $S('energy_regen_minutes'));
$byR = []; foreach ($rows as $x) $byR[$x['r'] . ($x['per'] ? 'p' : 'a')][] = $x;
foreach ([1, 5, 10, 20, 30] as $L) {
    $pool = $S('max_energy') + $S('energy_per_level') * ($L - 1);
    $need = xp_for_level($L + 1) - xp_for_level($L);
    // typical player: grows the median common annual (early), uncommon from 5, legendary perennials from 10
    $mix = $L < 5 ? 'Ca' : ($L < 10 ? 'Ua' : 'Lp');
    $c = $byR[$mix] ?? $byR['Ca'];
    $pe = $med(array_column($c, 'pe')); $xpe = $med(array_column($c, 'xpe'));
    printf("  L%-2d pool %3dE  regen %2dE/h  crop %s: %4d Petals/h, %4d XP/h, next level needs %5d XP (~%.1f h); a full pool = %4d Petals\n",
        $L, $pool, $regen, $mix, $regen * $pe, $regen * $xpe, $need, $need / max(1, $regen * $xpe), $pool * $pe);
}

// v0.7.94: cooking. Only home-cooked food gives energy, so check a meal never gives back more energy than its crops cost to grow.
echo "\nCooking: energy in vs out (ingredient energy = growing energy per unit; wild finds ~1 per unit)\n";
$perUnit = [];
foreach ($rows as $x) $perUnit[$x['pslug']] = min($perUnit[$x['pslug']] ?? 99, $x['E'] / max(0.5, $x['yield']));
$loops = 0; $list = [];
foreach (q("SELECT r.name, r.ingredients, r.energy, r.output_qty, i.effects, i.base_price FROM recipes r JOIN items i ON i.id = r.output_item_id WHERE r.category = 'cooking'")->fetchAll() as $r) {
    $fx = json_decode((string)$r['effects'], true) ?: [];
    $out = (int)($fx['energy'] ?? 0) * max(1, (int)$r['output_qty']);
    $in = (int)$r['energy'];
    $value = 0;
    foreach ((json_decode((string)$r['ingredients'], true) ?: []) as $slug => $n) {
        $in += $n * ($perUnit[$slug] ?? 1.0);
        $value += $n * sell_price(q_one('SELECT * FROM items WHERE slug = ?', [$slug]) ?: ['base_price' => 0, 'category' => 'misc']);
    }
    $list[] = [$r['name'], round($in, 1), $out, $value];
    if ($out > $in) $loops++;
}
usort($list, fn($a, $b) => ($b[2] - $b[1]) <=> ($a[2] - $a[1]));
foreach (array_slice($list, 0, 6) as [$n, $in, $out, $v]) printf("  %-28s in ~%5.1fE  out %3dE  net %+5.1fE  (ingredients sell for %d)\n", $n, $in, $out, $out - $in, $v);
printf("  %d of %d meals give back more energy than they cost%s\n", $loops, count($list), $loops ? ' (an energy loop: check those)' : ' (no energy loop)');

// Fights: Monte Carlo, attack only, gnome with base stats 10 and 1 point/level split grit/nimble/hardiness
echo "\nFights (attack only, 4000 sims each). Gnome spends level points evenly on grit, nimble, hardiness.\n";
$cre = q("SELECT * FROM creatures WHERE active = 1 AND size <> 'boss'")->fetchAll();
function gnome_at(int $L): array {
    $pts = $L - 1; $g = 10 + intdiv($pts + 2, 3); $n = 10 + intdiv($pts + 1, 3); $h = 10 + intdiv($pts, 3);
    $m = fn($v) => intdiv($v - 10, 2);
    return ['max_hp' => max(10, 20 + 3 * $L + 5 * $m($h)), 'ac' => 10 + $m($n) + intdiv($L, 4), 'atk' => 2 + intdiv($L, 2) + max($m($g), $m($n)),
        'dmg_bonus' => max(0, $m($g)) + intdiv($L, 4)];
}
function fight(array $g, array $c, int $n = 4000): array {
    $wins = 0; $lost = 0; $rounds = 0;
    for ($i = 0; $i < $n; $i++) {
        $hp = $g['max_hp']; $ch = (int)$c['hp']; $r = 0;
        while ($hp > 0 && $ch > 0 && $r < 60) {
            $r++; $d = random_int(1, 20);
            if ($d + $g['atk'] >= (int)$c['defense']) { $ch -= random_int(1, 8) + $g['dmg_bonus'] + ($d === 20 ? random_int(1, 8) : 0); }
            if ($ch <= 0) break;
            if (random_int(1, 20) + (int)$c['attack'] >= $g['ac']) $hp -= max(1, random_int(1, max(1, (int)$c['dmg_die'])) + (int)$c['dmg_bonus']);
        }
        if ($ch <= 0) { $wins++; $lost += $g['max_hp'] - $hp; $rounds += $r; }
    }
    return [$wins / $n, $wins ? $lost / $wins : 0, $wins ? $rounds / $wins : 0];
}
$at = function (int $lvl) use ($cre) { $best = null; foreach ($cre as $c) if ((int)$c['level'] === $lvl) return $c; foreach ($cre as $c) if (!$best || abs((int)$c['level'] - $lvl) < abs((int)$best['level'] - $lvl)) $best = $c; return $best; };
foreach ([1, 3, 5, 8, 10, 14, 17, 20, 23, 26, 30, 35] as $L) {
    $g = gnome_at($L);
    $line = sprintf("  gnome L%-2d hp %3d ac %2d atk +%-2d dmg d8+%d |", $L, $g['max_hp'], $g['ac'], $g['atk'], $g['dmg_bonus']);
    foreach ([0, 2, 5] as $d) { $c = $at($L + $d); [$w, $lost, $rd] = fight($g, $c); $line .= sprintf(" vs lv%-2d(%s): win %3d%%, -%2d hp, %.1f rnd |", $L + $d, (int)$c['level'] === $L + $d ? 'ok' : 'had ' . $c['level'], $w * 100, $lost, $rd); }
    echo $line, "\n";
}
// Which creature levels can a road at region level X actually produce (land ignored)?
echo "\nCreatures available per encounter level (pool rule level-6..level+2, any landscape):\n";
foreach ([10, 17, 20, 23, 26, 29, 32, 35] as $lv) {
    $pool = array_filter($cre, fn($c) => (int)$c['level'] <= $lv + 2 && (int)$c['level'] >= $lv - 6);
    $lvls = array_count_values(array_map(fn($c) => (int)$c['level'], $pool)); ksort($lvls);
    echo "  lv$lv: ", $pool ? count($pool) . ' creatures, levels ' . implode(',', array_keys($lvls)) : 'NONE → falls back to any creature up to lv' . ($lv + 2) . ' (including level 1s)', "\n";
}
