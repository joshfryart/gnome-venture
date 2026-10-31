<?php
declare(strict_types=1);

/**
 * v2.3.1 Delve floors (the delve redo, claude/plan-delves.md). Pure functions, no database: parse includes/data/delve_floors.txt, lint a floor, pick a pool.
 * Floor file format: a block starts with "@slug/name" (slug = the delve's landmark slug), then header lines "tier: small|standard|large", "rule: one line",
 * "sig: yes|no" (a signature floor of its delve), "for: fight,treasure,mystery,puzzle,boss" (optional, which route nodes may use it; default = the first four),
 * "title: Shown name" (optional), then the ASCII rows. Lines starting with # followed by a space are comments (a row never has a space).
 * Row characters: # wall, . floor, "," rough floor, S way in, E way down, 1-9 a find (pickup), K key, D locked door, W hazard (costs extra torch),
 * T trap, C chest, B guardian, M shrine, F foe.
 */

require_once __DIR__ . '/tilemap.php';

const DV_TIERS = ['small' => 9, 'standard' => 13, 'large' => 15];
const DV_TORCH = ['small' => 30, 'standard' => 45, 'large' => 50];   // torch fuel (steps) a floor starts with; at 0 the light shrinks, nothing fails. Tuned by claude/delve-torch-sim.php (was 40/55/70: never ran out)
const DV_TORCH_SLACK = 1.3;                                          // a floor must be clearable within fuel x this (lint)
const DV_HAZARD_COST = 2;                                            // a hazard tile costs this many torch steps
const DV_FOR = ['fight', 'treasure', 'mystery', 'puzzle', 'boss'];
const DV_MAX_FINDS = 6;                                              // fewer than 7 finds a floor (the 7 dots are the progress bar)
const DV_ROWCHARS = '#.,SE123456789KDWTCBMF';
/** What the hazard tile W is in each delve: [icon, name, ground tint]. Icons are emoji placeholders until Joshua draws them (proposals in claude/art-delve-hazards/). */
const DV_HAZARD = [
    'beaverdam-tunnels' => ['💧', 'Shallow water', '#3f6f8c'], 'jaguar-root-caves' => ['🌧️', 'Drip pool', '#46705e'],
    'mangrove-root-maze' => ['🌱', 'Tidal mud', '#5b5a3a'], 'salt-mine-galleries' => ['🧂', 'Brine puddle', '#a8a493'],
    'firefly-caves' => ['🫧', 'Spring pool', '#4f8aa3'], 'anaconda-hollows' => ['🌿', 'Reedy creek', '#4c7a52'],
    'sea-cave-smugglers-run' => ['🐚', 'Rock pool', '#4f7f86'], 'pirate-gull-grottoes' => ['🌊', 'Seawater', '#2f6680'],
    'rose-red-canyon-city' => ['🏺', 'Cistern water', '#3c6a7a'], 'the-canopy-bridges' => ['🪵', 'Rotten planks', '#6b4a2b'],
    'fynbos-fire-trails' => ['🔥', 'Embers', '#8a3b1e'], 'snowleopard-ledges' => ['🧊', 'Ice patch', '#9cc7d9'],
    'the-long-wall-walk' => ['🪨', 'Loose stones', '#7a6f62'], 'the-red-rock-songlines' => ['🏜️', 'Soft sand', '#c29a5b'],
];
const DV_HAZARD_ANY = ['💧', 'Water', '#3f6f8c'];

/** Parse floor text. Returns ['floors' => [key => floor], 'errors' => [strings]]. A floor is not linted here (see dv_floor_lint). */
function dv_floor_parse(string $text): array
{
    $floors = [];
    $errors = [];
    $cur = null;
    $flush = function () use (&$cur, &$floors, &$errors) {
        if ($cur === null) return;
        $key = $cur['key'];
        if (isset($floors[$key])) { $errors[] = $key . ': duplicate name'; $cur = null; return; }
        $cur['map'] = tm_parse($cur['rows']);
        $floors[$key] = $cur;
        $cur = null;
    };
    foreach (preg_split('/\r\n|\n|\r/', $text) as $line) {
        $line = rtrim($line);
        if ($line === '' || ($line[0] === '#' && ($line === '#' || $line[1] === ' '))) continue;
        if ($line[0] === '@') {
            $flush();
            $key = trim(substr($line, 1));
            if (!preg_match('~^([a-z0-9-]+)/([a-z0-9_-]+)$~', $key, $m)) { $errors[] = 'bad floor header ' . $line; continue; }
            $cur = ['key' => $key, 'slug' => $m[1], 'name' => $m[2], 'tier' => '', 'rule' => '', 'sig' => false, 'for' => ['fight', 'treasure', 'mystery', 'puzzle'], 'title' => '', 'rows' => []];
            continue;
        }
        if ($cur === null) { $errors[] = 'text outside a floor: ' . $line; continue; }
        if (preg_match('/^(tier|rule|sig|for|title):\s*(.*)$/', $line, $m)) {
            $v = trim($m[2]);
            if ($m[1] === 'sig') $cur['sig'] = in_array(strtolower($v), ['yes', '1', 'true'], true);
            elseif ($m[1] === 'for') $cur['for'] = array_values(array_filter(array_map('trim', explode(',', $v)), fn($x) => $x !== ''));
            else $cur[$m[1]] = $v;
            continue;
        }
        $cur['rows'][] = $line;
    }
    $flush();
    return ['floors' => $floors, 'errors' => $errors];
}

/** Every [x, y] holding a character, from a parsed map. */
function dv_find_all(array $map, string $ch): array
{
    $out = [];
    foreach ($map['t'] as $y => $row) {
        for ($x = 0, $n = strlen($row); $x < $n; $x++) if ($row[$x] === $ch) $out[] = [$x, $y];
    }
    return $out;
}

/** Digits 1-9 as finds: [[x, y], ...]. */
function dv_finds(array $map): array
{
    $out = [];
    foreach ($map['t'] as $y => $row) {
        for ($x = 0, $n = strlen($row); $x < $n; $x++) if ($row[$x] >= '1' && $row[$x] <= '9') $out[] = [$x, $y];
    }
    return $out;
}

/** The hazard of a delve: [icon, name, tint]. */
function dv_hazard(string $slug): array
{
    return DV_HAZARD[$slug] ?? DV_HAZARD_ANY;
}

/** Torch cost of stepping onto a tile. */
function dv_step_cost(string $tile): int
{
    return $tile === 'W' ? DV_HAZARD_COST : 1;
}

/** Cheapest torch cost from (sx,sy) to every reachable tile (Dijkstra, tiny weights). $doorOpen false = D is a wall. Returns [y * w + x => cost]. */
function dv_costs(array $map, int $sx, int $sy, bool $doorOpen): array
{
    $w = $map['w'];
    $gate = fn(int $x, int $y, string $t) => $doorOpen || $t !== 'D';
    $dist = [$sy * $w + $sx => 0];
    $todo = [$sy * $w + $sx => 0];
    while ($todo) {
        asort($todo);
        $cur = array_key_first($todo);
        unset($todo[$cur]);
        $cx = $cur % $w;
        $cy = intdiv($cur, $w);
        foreach ([[1, 0], [-1, 0], [0, 1], [0, -1]] as [$dx, $dy]) {
            $nx = $cx + $dx;
            $ny = $cy + $dy;
            if (!tm_walkable($map, $nx, $ny, $gate)) continue;
            $k = $ny * $w + $nx;
            $c = $dist[$cur] + dv_step_cost($map['t'][$ny][$nx]);
            if (!isset($dist[$k]) || $c < $dist[$k]) { $dist[$k] = $c; $todo[$k] = $c; }
        }
    }
    return $dist;
}

/** A rough walk to take everything: nearest-next tour over the finds, key, door and chest, ending at the exit (E) or, on a boss floor, the guardian then the chest. */
function dv_tour_cost(array $map): int
{
    $stops = [];
    foreach (dv_finds($map) as $p) $stops[] = $p;
    foreach (['K', 'D', 'M', 'C'] as $ch) foreach (dv_find_all($map, $ch) as $p) $stops[] = $p;
    $boss = dv_find_all($map, 'B');
    $end = dv_find_all($map, 'E');
    [$x, $y] = $map['entry'];
    $total = 0;
    $door = dv_find_all($map, 'D');
    $open = !$door;   // the door counts as open once the key is picked up
    while ($stops) {
        $d = dv_costs($map, $x, $y, $open);
        $best = null;
        foreach ($stops as $i => [$sx, $sy]) {
            $k = $sy * $map['w'] + $sx;
            if (!isset($d[$k])) continue;
            if ($best === null || $d[$k] < $best[1]) $best = [$i, $d[$k]];
        }
        if ($best === null) { if (!$open) { $open = true; continue; } break; }
        [$x, $y] = $stops[$best[0]];
        $total += $best[1];
        if ($map['t'][$y][$x] === 'K') $open = true;
        array_splice($stops, $best[0], 1);
    }
    $d = dv_costs($map, $x, $y, true);
    foreach (array_merge($boss, $end) as [$tx, $ty]) { $k = $ty * $map['w'] + $tx; $total += $d[$k] ?? 0; [$x, $y] = [$tx, $ty]; $d = dv_costs($map, $x, $y, true); }
    return $total;
}

/** Lint one parsed floor. Returns a list of problems ([] = fine). */
function dv_floor_lint(array $f): array
{
    $bad = [];
    if (!isset(DV_TIERS[$f['tier']])) return ['tier must be small, standard or large'];
    $size = DV_TIERS[$f['tier']];
    $map = $f['map'];
    if (trim($f['rule']) === '') $bad[] = 'no rule line';
    if (strlen($f['rule']) > 140) $bad[] = 'rule line over 140 characters';
    if (strpos($f['rule'], '—') !== false || strpos($f['rule'], '–') !== false) $bad[] = 'rule line has a dash (use commas or periods)';
    foreach ($f['for'] as $k) if (!in_array($k, DV_FOR, true)) $bad[] = 'unknown node kind ' . $k;
    if (!$f['for']) $bad[] = 'for: is empty';
    $boss = in_array('boss', $f['for'], true);
    if ($boss && count($f['for']) > 1) $bad[] = 'a boss floor is for boss only';
    if ($f['tier'] === 'large' && array_diff($f['for'], ['treasure', 'boss'])) $bad[] = 'large floors are for treasure and boss only';
    if ($map['w'] !== $size || $map['h'] !== $size) return array_merge($bad, ['must be ' . $size . 'x' . $size . ' for ' . $f['tier'] . ', is ' . $map['w'] . 'x' . $map['h']]);
    foreach ($map['t'] as $y => $row) {
        if (strlen($f['rows'][$y] ?? '') !== $size) { $bad[] = 'row ' . ($y + 1) . ' is not ' . $size . ' wide'; continue; }
        for ($x = 0; $x < $size; $x++) {
            $c = $row[$x];
            if (strpos(DV_ROWCHARS, $c) === false) $bad[] = 'bad character "' . $c . '" at ' . $x . ',' . $y;
            if (($x === 0 || $y === 0 || $x === $size - 1 || $y === $size - 1) && $c !== '#') $bad[] = 'edge must be wall at ' . $x . ',' . $y;
        }
    }
    if ($bad) return array_values(array_unique($bad));
    $count = fn(string $ch) => count(dv_find_all($map, $ch));
    if ($count('S') !== 1) $bad[] = 'need exactly one S';
    if ($boss) {
        if ($count('B') !== 1) $bad[] = 'a boss floor needs exactly one B';
        if ($count('C') !== 1) $bad[] = 'a boss floor needs exactly one C';
        if ($count('E') !== 0) $bad[] = 'a boss floor has no E';
    } else {
        if ($count('E') !== 1) $bad[] = 'need exactly one E';
        if ($count('B') !== 0) $bad[] = 'B is for boss floors';
    }
    if ($count('K') > 1 || $count('D') > 1) $bad[] = 'at most one key and one door';
    if (($count('K') > 0) !== ($count('D') > 0)) $bad[] = 'key and door come together';
    if ($count('M') > 1) $bad[] = 'at most one shrine';
    if (count(dv_finds($map)) > DV_MAX_FINDS) $bad[] = 'more than ' . DV_MAX_FINDS . ' finds';
    if (in_array('treasure', $f['for'], true) && $count('C') + count(dv_finds($map)) < 2) $bad[] = 'a treasure floor needs at least 2 chests or finds';
    if ($bad || !$map['entry']) return $bad ?: ['no S'];
    [$sx, $sy] = $map['entry'];
    $w = $map['w'];
    $shut = dv_costs($map, $sx, $sy, false);
    foreach (dv_find_all($map, 'K') as [$kx, $ky]) if (!isset($shut[$ky * $w + $kx])) $bad[] = 'key is behind the door (or cut off)';
    $open = dv_costs($map, $sx, $sy, true);
    for ($y = 0; $y < $size; $y++) {
        for ($x = 0; $x < $size; $x++) {
            if ($map['t'][$y][$x] !== '#' && !isset($open[$y * $w + $x])) { $bad[] = 'floor cut off at ' . $x . ',' . $y; break 2; }
        }
    }
    if ($bad) return $bad;
    $tour = dv_tour_cost($map);
    $limit = (int)floor(DV_TORCH[$f['tier']] * DV_TORCH_SLACK);
    if ($tour > $limit) $bad[] = 'takes about ' . $tour . ' torch steps, over ' . $limit;
    return $bad;
}

/** Parse + lint a text. Returns ['floors' => valid ones, 'problems' => [key => [..]]]. */
function dv_floors_from_text(string $text): array
{
    $p = dv_floor_parse($text);
    $problems = [];
    foreach ($p['errors'] as $e) $problems['(file)'][] = $e;
    $ok = [];
    foreach ($p['floors'] as $key => $f) {
        $b = dv_floor_lint($f);
        if ($b) $problems[$key] = $b; else $ok[$key] = $f;
    }
    return ['floors' => $ok, 'problems' => $problems];
}

/** The floors of includes/data/delve_floors.txt that pass the lint: key => floor. A broken floor is left out (the generator takes over). */
function dv_floors(): array
{
    static $all = null;
    if ($all !== null) return $all;
    $path = __DIR__ . '/data/delve_floors.txt';
    return $all = is_file($path) ? dv_floors_from_text((string)file_get_contents($path))['floors'] : [];
}

/** The pool of a delve, optionally one tier and one node kind: key => floor, sorted by key (stable). */
function dv_pool(string $slug, ?string $tier = null, ?string $kind = null, ?array $all = null): array
{
    $all = $all ?? dv_floors();
    $out = [];
    foreach ($all as $key => $f) {
        if ($f['slug'] !== $slug) continue;
        if ($tier !== null && $f['tier'] !== $tier) continue;
        if ($kind !== null && !in_array($kind, $f['for'], true)) continue;
        $out[$key] = $f;
    }
    ksort($out);
    return $out;
}
