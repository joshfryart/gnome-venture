<?php
// One shared creature loader for the test tooling (tests/pf_play.php, tests/pfboard_tune_v1.php): all 319 creatures = the 88 base rows of data/creatures.txt
// plus the 231 variants of data/pf_creatures.txt (pfd_creature_rows()). A '=' cell of a pf_creatures row keeps the creatures.txt value (name, size, level).
// Row: slug, name, size, level, dmg_die, dmg_bonus (what pfd_foe_row() and the engine read; the layered fields come from pfd_creature_overlay()).
require_once __DIR__ . '/../game/includes/pfdeck.php';
function pt_load_creatures(): array
{
    $die = ['small' => 4, 'medium' => 6, 'large' => 8, 'boss' => 10]; $base = [];
    foreach (file(__DIR__ . '/../game/includes/data/creatures.txt', FILE_IGNORE_NEW_LINES) as $l) {
        if ($l === '' || $l[0] === '#') continue; $c = explode('|', $l); if (count($c) < 7) continue;
        $base[$c[0]] = ['name' => $c[1], 'size' => $c[2], 'level' => max(1, (int)$c[4])];
    }
    $o = [];
    foreach (pfd_creature_rows() as $slug => $r) {
        $b = $base[$slug] ?? ($base[$r['family']] ?? ['name' => $slug, 'size' => 'medium', 'level' => 1]);
        $name = $r['name'] ?? $b['name']; $size = $r['size'] ?? $b['size']; $lv = max(1, (int)($r['level'] ?? $b['level']));
        $o[$slug] = ['slug' => $slug, 'name' => $name, 'size' => $size, 'level' => $lv, 'dmg_die' => $die[$size] ?? 6, 'dmg_bonus' => intdiv($lv, 4)];
    }
    foreach ($base as $slug => $b) if (!isset($o[$slug])) $o[$slug] = ['slug' => $slug, 'name' => $b['name'], 'size' => $b['size'], 'level' => $b['level'], 'dmg_die' => $die[$b['size']] ?? 6, 'dmg_bonus' => intdiv($b['level'], 4)];
    return $o;
}
