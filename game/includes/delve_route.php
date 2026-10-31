<?php
declare(strict_types=1);

/**
 * v2.3.1 Delve route (the delve redo, claude/plan-delves.md). Pure functions, no database. A route is a small graph of nodes in rows, made from a seed
 * (so it is the same for the same gnome, delve and day, and only the seed needs saving). You pick one node per row, top to bottom; the last row is the
 * guardian. A floor node opens a tile floor drawn from the delve's own pool (includes/delve_floors.php); a quick node (shrine, mole) is a card.
 * Route: ['seed', 'slug', 'stages', 'rows' => [[node, ...], ...]]. Node: ['id' => 'r.c', 'row', 'col', 'kind', 'tier' (floor nodes), 'to' => [ids]].
 */

require_once __DIR__ . '/delve_floors.php';

const DV_FLOOR_KINDS = ['fight', 'treasure', 'mystery', 'puzzle'];
const DV_QUICK_KINDS = ['shrine', 'mole'];
const DV_WIDTHS = [3 => [3, 2, 1], 4 => [3, 3, 2, 1], 5 => [3, 3, 3, 2, 1]];

/** Stages (picks, the guardian included) for a delve of a danger level: 3 for the easiest delves, otherwise 4. */
function dv_stages(int $level): int
{
    return $level < 3 ? 3 : 4;
}

/** Make a route. Same seed + slug + stages = same route. */
function dv_route(string $seed, string $slug, int $stages = 4): array
{
    $stages = isset(DV_WIDTHS[$stages]) ? $stages : 4;
    $widths = DV_WIDTHS[$stages];
    $rng = tm_rng('dvroute|' . $seed . '|' . $slug);
    $rows = [];
    foreach ($widths as $r => $w) {
        $row = [];
        $last = $r === $stages - 1;
        $pre = $r === $stages - 2;
        $pool = $last ? ['boss'] : ($pre || $r === 0 ? DV_FLOOR_KINDS : array_merge(DV_FLOOR_KINDS, DV_FLOOR_KINDS, DV_QUICK_KINDS));
        $left = $pool;
        for ($c = 0; $c < $w; $c++) {
            if (!$left) $left = $pool;
            $i = $rng(0, count($left) - 1);
            $kind = $left[$i];
            $left = array_values(array_filter($left, fn($k) => $k !== $kind));   // different kinds across a row while there are any left
            $node = ['id' => $r . '.' . $c, 'row' => $r, 'col' => $c, 'kind' => $kind, 'to' => []];
            if ($kind === 'boss') $node['tier'] = $rng(1, 10) <= 7 ? 'standard' : 'large';
            elseif (in_array($kind, DV_FLOOR_KINDS, true)) {
                $t = $rng(1, 100);
                $node['tier'] = ($kind === 'treasure' && $t <= 15) ? 'large' : ($t <= 50 ? 'small' : 'standard');
            }
            $row[] = $node;
        }
        $rows[] = $row;
    }
    for ($r = 0; $r < $stages - 1; $r++) {   // edges: every node reaches the next row, every node of the next row is reached
        $w = count($rows[$r]);
        $w2 = count($rows[$r + 1]);
        $has = array_fill(0, $w2, false);
        foreach ($rows[$r] as $c => $_) {
            $lo = intdiv($c * $w2, $w);
            $to = [$lo];
            if ($lo + 1 < $w2 && $rng(1, 100) <= 50) $to[] = $lo + 1;
            foreach ($to as $j) { $rows[$r][$c]['to'][] = ($r + 1) . '.' . $j; $has[$j] = true; }
        }
        foreach ($has as $j => $reached) {
            if ($reached) continue;
            $c = min($w - 1, intdiv($j * $w, $w2));
            $rows[$r][$c]['to'][] = ($r + 1) . '.' . $j;
        }
    }
    return ['seed' => $seed, 'slug' => $slug, 'stages' => $stages, 'rows' => $rows];
}

/** One node by id, or null. */
function dv_route_node(array $route, string $id): ?array
{
    if (!preg_match('/^(\d+)\.(\d+)$/', $id, $m)) return null;
    return $route['rows'][(int)$m[1]][(int)$m[2]] ?? null;
}

/** The node ids you may pick from where you stand. $at = null at the start: the whole first row. */
function dv_route_choices(array $route, ?string $at): array
{
    if ($at === null) return array_map(fn($n) => $n['id'], $route['rows'][0]);
    $n = dv_route_node($route, $at);
    return $n ? $n['to'] : [];
}

/** Is it a floor node (opens a tile floor)? Quick nodes are cards. */
function dv_node_has_floor(array $node): bool
{
    return in_array($node['kind'], DV_FLOOR_KINDS, true) || $node['kind'] === 'boss';
}

/**
 * The floor of a floor node: drawn from the delve's own pool when you step in, never one already used on this run ($used = keys). Tier and kind first,
 * then relaxed (any tier, then any floor that fits the kind). On a first clear, the last floor before the guardian is a signature floor when the pool has one.
 * Returns ['key' => floor key, 'src' => 'pool'] or ['key' => null, 'src' => 'gen'] (the pool has nothing: the caller makes a floor from the seed).
 */
function dv_floor_pick(array $route, string $nodeId, array $used, bool $firstClear, ?array $all = null): array
{
    $node = dv_route_node($route, $nodeId);
    if (!$node || !dv_node_has_floor($node)) return ['key' => null, 'src' => 'gen'];
    $all = $all ?? dv_floors();
    $kind = $node['kind'];
    $usedSig = false;
    foreach ($used as $k) if (!empty($all[$k]['sig'])) $usedSig = true;
    $needSig = $firstClear && !$usedSig && $node['row'] === $route['stages'] - 2;
    $steps = [[$node['tier'] ?? null, $kind], [null, $kind]];
    foreach ($steps as [$tier, $k]) {
        $c = array_diff_key(dv_pool($route['slug'], $tier, $k, $all), array_flip($used));
        if (!$c) continue;
        if ($needSig && ($s = array_filter($c, fn($f) => $f['sig']))) $c = $s;
        $keys = array_keys($c);
        foreach ($c as $key => $f) if ($f['sig'] && !$needSig) $keys[] = $key;   // a signature floor counts twice
        $rng = tm_rng('dvfloor|' . $route['seed'] . '|' . $route['slug'] . '|' . $nodeId);
        return ['key' => $keys[$rng(0, count($keys) - 1)], 'src' => 'pool'];
    }
    return ['key' => null, 'src' => 'gen'];
}
