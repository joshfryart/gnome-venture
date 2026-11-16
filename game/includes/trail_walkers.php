<?php
declare(strict_types=1);
require_once __DIR__ . '/npc25.php';

/**
 * Walkers on the Trail map (2.7.01): a villager whose weekly clockwork has them on the road between two stops (an errand or a market trip: npc_clockwork.php) is drawn walking on
 * the section of that road the gnome is on, at the place along it that their hour of walking has reached, in their 2.5D walk sprite (assets/img/npc25/<species>-<view>.png, 8 frames of 64 x 80:
 * 1-2 idle, 3-8 walk; see aseprite-source/npc25/PATHWAY.md). A species with no strip yet falls back to its idle folk sprite. Same entries as trail_sights_folk_on_map():
 * [x, y, picture url, name, frames, 's'|'n', id, anim, slug, who, ['cell' => [w, h], 'walk' => bool, 'dir' => 1|-1, 'label' => string]]. Tap = their card (chat, gift), as for a villager at a Sight.
 */

/** The walk the gnome is on: [route row, display direction reversed?, sections, this section (0-based as shown)] or null. */
function trail_walkers_route(array $sc): ?array
{
    $mk = (string)($sc['row']['map_key'] ?? '');
    if (strncmp($mk, 'trail:', 6) !== 0 || ($sc['st']['phase'] ?? '') !== 'section') return null;
    $r = q_one('SELECT * FROM routes WHERE id = ?', [(int)substr($mk, 6)]);
    return $r ? [$r, !empty($sc['st']['rev']), max(1, (int)($sc['st']['S'] ?? $r['steps'])), (int)($sc['st']['sec'] ?? 0)] : null;
}

/** Villagers on this section's stretch of the road right now (see the file comment). */
function trail_walkers_on_map(array $u, array $exp, array $sc): array
{
    require_once __DIR__ . '/npc_clockwork.php';
    if (!npc_cw_on() || !($rt = trail_walkers_route($sc)) || !empty($exp['encounter'])) return [];
    [$r, $rev, $N, $sec] = $rt; $a = (int)$r['a_id']; $b = (int)$r['b_id'];
    $out = []; $map = $sc['map'] ?? null;
    if (!$map) return [];
    foreach (q('SELECT * FROM stop_folk WHERE location_id IN (?, ?) AND active = 1 ORDER BY id', [$a, $b])->fetchAll() as $f) {
        $key = 's' . (int)$f['id'];
        if (function_exists('gclock_npc_away') && gclock_npc_away($key)) continue;
        $s = npc_cw_state($key);
        if (empty($s['moving']) || empty($s['doing']) || ($s['doing']['stops'][0]['t'] ?? '') !== 'loc') continue;
        $home = (int)$f['location_id']; $dest = (int)$s['doing']['stops'][0]['id'];
        if (!(($home === $a && $dest === $b) || ($home === $b && $dest === $a))) continue;   // this road only
        $out_ = ($s['from']['t'] ?? '') === 'home';                 // leaving home (else coming back)
        $S = $out_ ? $home : $dest; $E = $out_ ? $dest : $home;      // from stop S to stop E
        $p = $S === $a ? (float)$s['p'] : 1.0 - (float)$s['p'];    // 0 at the a end .. 1 at the b end
        $t = $rev ? 1.0 - $p : $p;                                  // 0 = where the gnome's walk starts .. 1 = where it ends
        $di = min($N - 1, (int)floor($t * $N));
        if ($di !== $sec) continue;
        $within = $t * $N - $di;
        $dir = (($E === $b) xor $rev) ? 1 : -1;
        $spot = trail_walkers_tile($map, $sc, $within, $key);
        if (!$spot) continue;
        $sp = npc25_strip((string)$f['species'], 'side');
        if ($sp) { $pic = $sp[0]; $frames = 8; $cell = $sp[1]; }
        else { $rel = function_exists('stop_folk_art') ? stop_folk_art($f, 'sprite') : ''; if ($rel === '') continue; $pic = url($rel); $frames = 4; $cell = [64, 96]; }
        $out[] = [$spot[0], $spot[1], $pic, (string)$f['name'], $frames, 's', (int)$f['id'], false, '', (string)$f['name'], ['cell' => $cell, 'walk' => (bool)$sp, 'dir' => $dir, 'label' => $s['doing']['label']]];
    }
    return $out;
}

/** A walkable tile at about this share ($within 0..1) of the way across the section, not the gnome's own tile; stable per villager. */
function trail_walkers_tile(array $map, array $sc, float $within, string $key): ?array
{
    $w = (int)($map['w'] ?? 0); $h = (int)($map['h'] ?? 0);
    if ($w < 2 || $h < 1) return null;
    $x0 = (int)round($within * ($w - 1));
    $order = [0, 1, -1, 2, -2, 3, -3];
    foreach ($order as $dx) {
        $x = max(0, min($w - 1, $x0 + $dx));
        $ys = range(0, $h - 1); usort($ys, fn($p, $q) => abs($p - intdiv($h, 2)) <=> abs($q - intdiv($h, 2)));   // the middle rows first (where the path runs)
        $off = (int)floor(hollow_unit('walk|' . $key) * 3);
        foreach (array_merge(array_slice($ys, $off), array_slice($ys, 0, $off)) as $y) {
            if (!tm_walkable($map, $x, $y) || ($x === (int)$sc['x'] && $y === (int)$sc['y'])) continue;
            if (isset($sc['map']['art']) && function_exists('trail_sight_covered_by_sprite') && trail_sight_covered_by_sprite((array)$sc['map']['art'], $x, $y)) continue;
            return [$x, $y];
        }
    }
    return null;
}
