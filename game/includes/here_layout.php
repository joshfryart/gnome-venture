<?php
declare(strict_types=1);
/**
 * Graphical navigation, Phase 1: layout helpers for the picture pages (Here, Residential, Door ...).
 * Pure functions (no database) except here_layouts_all(), which merges the shipped JSON with admin edits.
 * The layout JSON (includes/data/here_layouts.json) is the contract with the art: slots never move.
 * Canvas size is read from each layout ('w', 'h'); nothing here hard-codes 480 x 270.
 */

/** Compass anchors and their bearings (0 = north, clockwise). */
const HERE_ANCHORS = ['N' => 0.0, 'NE' => 45.0, 'E' => 90.0, 'SE' => 135.0, 'S' => 180.0, 'SW' => 225.0, 'W' => 270.0, 'NW' => 315.0];

/** Perspective for a 2.5D sprite: feet at y give a scale and a z-order. Lower on screen = nearer = bigger. */
function here_persp(array $L, int $y): array
{
    $h = (int)($L['h'] ?? 270);
    $hz = (int)($L['horizon'] ?? 0);
    $t = max(0.0, min(1.0, ($y - $hz) / max(1, $h - $hz)));
    return ['scale' => round(0.75 + 0.5 * $t, 3), 'z' => $y];   // 0.75x far, 1.25x near
}

/** Compass bearing from one place to another (0 = N, clockwise), from region_layout coordinates ['x'=>, 'y'=>]. Same region only. */
function here_bearing(array $from, array $to): float
{
    return fmod(rad2deg(atan2($to['x'] - $from['x'], -($to['y'] - $from['y']))) + 360.0, 360.0);
}

/**
 * Give each route the nearest free compass anchor. Stable: routes are sorted by (bearing, id), so a place always draws the same.
 * $anchors: ['N' => 0, 'NE' => 45, ...] (the anchors the template has); $routes: [['id' =>, 'bearing' => float], ...].
 * Returns [id => anchor name, ids that did not fit ("More ways")].
 */
function here_assign_exits(array $anchors, array $routes): array
{
    usort($routes, fn($a, $b) => [$a['bearing'], $a['id']] <=> [$b['bearing'], $b['id']]);
    $free = $anchors;
    $out = [];
    $more = [];
    foreach ($routes as $r) {
        if (!$free) { $more[] = $r['id']; continue; }
        $best = null;
        $bd = 999.0;
        foreach ($free as $name => $deg) {
            $d = abs(fmod($r['bearing'] - $deg + 540.0, 360.0) - 180.0);
            if ($d < $bd) { $bd = $d; $best = $name; }
        }
        $out[$r['id']] = $best;
        unset($free[$best]);
    }
    return [$out, $more];
}

/**
 * Put villagers on stand slots. A villager keeps the same slot for an hour (hash), so a refresh does not shuffle the crowd.
 * Returns [[[slot, npc], ...], overflow count].
 */
function here_place_npcs(array $stand, array $npcs, int $hourKey): array
{
    usort($npcs, fn($a, $b) => [crc32($a['slug'] . $hourKey), (string)$a['slug']] <=> [crc32($b['slug'] . $hourKey), (string)$b['slug']]);
    $n = min(count($stand), count($npcs));
    $pairs = [];
    for ($i = 0; $i < $n; $i++) $pairs[] = [$stand[$i], $npcs[$i]];
    return [$pairs, max(0, count($npcs) - $n)];
}

/** Anchors a layout has, as ['N' => 0.0, ...] in the layout's own order. */
function here_layout_anchors(array $L): array
{
    $out = [];
    foreach ($L['exits'] ?? [] as $e) {
        if (isset($e['a'], HERE_ANCHORS[$e['a']])) $out[$e['a']] = HERE_ANCHORS[$e['a']];
    }
    return $out;
}

/**
 * The hit box of a hotspot: its own 'box' [x0, y0, x1, y1] (a whole room, building front or area), else a 56 x 56 square around x, y (never outside the picture).
 * Returns [x0, y0, x1, y1] as ints.
 */
function here_hit_box(array $spot, array $L): array
{
    $b = $spot['box'] ?? null;
    if (is_array($b) && count($b) === 4) {
        $b = array_map('intval', array_values($b));
        if ($b[2] > $b[0] && $b[3] > $b[1]) return $b;
    }
    $x = (int)($spot['x'] ?? 0); $y = (int)($spot['y'] ?? 0);
    $w = (int)($L['w'] ?? 480); $h = (int)($L['h'] ?? 270);
    return [max(0, $x - 28), max(0, $y - 28), min($w, $x + 28), min($h, $y + 28)];
}

/** The corner of a picture kept clear for the compass and the world globe: layout 'compass_clear' [x0, y0, x1, y1], else the bottom-right 100 x 40. */
function here_compass_clear(array $L): array
{
    $c = $L['compass_clear'] ?? null;
    if (is_array($c) && count($c) === 4) return array_map('intval', array_values($c));
    $w = (int)($L['w'] ?? 480); $h = (int)($L['h'] ?? 270);
    return [$w - 100, $h - 40, $w, $h];
}

/** The position of an anchor in a layout, or null. */
function here_exit_pos(array $L, string $anchor): ?array
{
    foreach ($L['exits'] ?? [] as $e) if (($e['a'] ?? '') === $anchor) return ['x' => (int)$e['x'], 'y' => (int)$e['y']];
    return null;
}

/** The position of a named spot in a layout, or null. */
function here_spot_pos(array $L, string $k): ?array
{
    foreach ($L['spots'] ?? [] as $s) if (($s['k'] ?? '') === $k) return ['x' => (int)$s['x'], 'y' => (int)$s['y']];
    return null;
}

/**
 * Which template a place uses. Order: slug:<slug> -> (town) town-<region code> -> (stop) stop-<type>-<landscape>_<style>, a look of the same
 * type + landscape picked by the slug, stop-<type>-<landscape>, stop-<type> -> <kind>-<landscape> -> <kind> -> generic.
 * $all is the full layout map (key => layout). $ctx: ['region' => region code or 'hub', 'type' => stop type slug, 'style' => look style from
 * data/stop_looks.php]. Returns [key, layout] or null when even 'generic' is missing.
 */
function here_layout_find(array $all, string $kind, string $landscape = '', string $slug = '', array $ctx = []): ?array
{
    $tries = [];
    if ($slug !== '') $tries[] = 'slug:' . $slug;
    $region = strtolower((string)($ctx['region'] ?? ''));
    if ($kind === 'town' && preg_match('/^[a-z0-9]+$/', $region)) $tries[] = 'town-' . $region;
    $type = strtolower((string)($ctx['type'] ?? ''));
    $style = strtolower((string)($ctx['style'] ?? ''));
    if ($kind === 'stop' && preg_match('/^[a-z0-9_-]+$/', $type) && $landscape !== '') {
        if ($style !== '') $tries[] = 'stop-' . $type . '-' . $landscape . '_' . $style;
        $looks = [];   // any look of this type + landscape (another region's style) beats a plain template: stable pick by the slug
        foreach (array_keys($all) as $k) if (str_starts_with((string)$k, 'stop-' . $type . '-' . $landscape . '_')) $looks[] = (string)$k;
        sort($looks);
        if ($looks) $tries[] = $looks[crc32($slug . '|' . $type) % count($looks)];
        $tries[] = 'stop-' . $type . '-' . $landscape;
    }
    if ($kind === 'stop' && preg_match('/^[a-z0-9_-]+$/', $type)) $tries[] = 'stop-' . $type;
    if ($kind !== '' && $landscape !== '') $tries[] = $kind . '-' . $landscape;
    if ($kind !== '') $tries[] = $kind;
    $tries[] = 'generic';
    foreach ($tries as $k) {
        if (isset($all[$k]) && is_array($all[$k])) return [$k, $all[$k]];
    }
    return null;
}

/** Shipped layouts (includes/data/here_layouts.json), read once. Keys starting with '_' are comments. */
function here_layouts_shipped(): array
{
    static $all = null;
    if ($all !== null) return $all;
    $all = [];
    $f = __DIR__ . '/data/here_layouts.json';
    $j = is_file($f) ? json_decode((string)file_get_contents($f), true) : null;
    foreach (is_array($j) ? $j : [] as $k => $L) if (is_string($k) && $k !== '' && $k[0] !== '_' && is_array($L)) $all[$k] = $L;
    return $all;
}

/** Shipped layouts with admin edits (table here_layouts) on top. A missing table is not an error. */
function here_layouts_all(): array
{
    $all = here_layouts_shipped();
    try {
        foreach (q('SELECT layout_key, json FROM here_layouts')->fetchAll() as $r) {
            $L = json_decode((string)$r['json'], true);
            if (is_array($L)) $all[(string)$r['layout_key']] = $L;
        }
    } catch (Throwable $e) {}
    return $all;
}

/** The scene picture file (under assets/img/scenes) a layout key is drawn on. Mirrored in tools/gen_here_placeholders.py. */
function here_layout_file(string $key): string
{
    if (str_starts_with($key, 'resid-')) return $key . '.png';
    return match ($key) {
        'door' => 'door-cottage.png', 'workshop' => 'craft-workshop.png', 'treehouse' => 'tree-house.png', 'yard' => 'yard-pals.png',
        default => 'here-' . str_replace(':', '-', $key) . '.png',
    };
}

/**
 * Lint one layout. Returns a list of problems ([] = fine). Rules (plan 6): every slot inside 0..w / 0..h, stand slots at least 28 units
 * from every exit and spot, exits at least 40 apart, horizon above every stand slot, at least 4 stand slots (when the layout has a 'stand'
 * list at all: door and street layouts have none), house slots inside the picture.
 */
function here_lint_layout(array $L): array
{
    $bad = [];
    $w = (int)($L['w'] ?? 0);
    $h = (int)($L['h'] ?? 0);
    if ($w < 64 || $h < 64) { $bad[] = 'w/h missing or too small'; return $bad; }
    $in = function (string $what, $p) use ($w, $h, &$bad) {
        if (!is_array($p) || !isset($p['x'], $p['y']) || $p['x'] < 0 || $p['x'] > $w || $p['y'] < 0 || $p['y'] > $h) $bad[] = $what . ' outside the picture';
    };
    $pts = [];
    foreach (['exits' => 'exit', 'spots' => 'spot', 'stand' => 'stand', 'houses' => 'house', 'pals' => 'perch', 'party' => 'party slot', 'dress' => 'dressing'] as $key => $what) {
        foreach ($L[$key] ?? [] as $i => $p) { $in($what . ' ' . $i, $p); if (is_array($p) && isset($p['x'], $p['y'])) $pts[$key][$i] = $p; }
    }
    $dist = fn($a, $b) => sqrt((($a['x'] - $b['x']) ** 2) + (($a['y'] - $b['y']) ** 2));
    $ex = array_values($pts['exits'] ?? []);
    for ($i = 0; $i < count($ex); $i++) for ($j = $i + 1; $j < count($ex); $j++) {
        if ($dist($ex[$i], $ex[$j]) < 40) $bad[] = 'exits ' . ($ex[$i]['a'] ?? $i) . ' and ' . ($ex[$j]['a'] ?? $j) . ' closer than 40';
    }
    foreach (($pts['stand'] ?? []) as $i => $s) {
        foreach (array_merge($pts['exits'] ?? [], $pts['spots'] ?? []) as $o) {
            if (isset($o['box']) && is_array($o['box']) && count($o['box']) === 4) {   // a spot with a hit box: the stand slot must stay 6 units off the box (the box, not its dot, is the thing)
                $dx = max($o['box'][0] - $s['x'], 0, $s['x'] - $o['box'][2]); $dy = max($o['box'][1] - $s['y'], 0, $s['y'] - $o['box'][3]);
                if (sqrt($dx * $dx + $dy * $dy) < 6) { $bad[] = 'stand ' . $i . ' inside or touching the box of ' . ($o['k'] ?? '?'); break; }
                continue;
            }
            if ($dist($s, $o) < 28) { $bad[] = 'stand ' . $i . ' closer than 28 to ' . ($o['a'] ?? $o['k'] ?? '?'); break; }
        }
        if (isset($L['horizon']) && $s['y'] <= (int)$L['horizon']) $bad[] = 'stand ' . $i . ' above the horizon';
    }
    // hit boxes (spots with a 'box'): inside the picture, never overlapping each other, never over the compass / globe corner
    $clear = here_compass_clear($L);
    $boxes = [];
    foreach ($L['spots'] ?? [] as $s) {
        if (!isset($s['box'])) continue;
        $nm = (string)($s['k'] ?? '?');
        $b = $s['box'];
        if (!is_array($b) || count($b) !== 4 || $b[2] <= $b[0] || $b[3] <= $b[1]) { $bad[] = 'box of ' . $nm . ' is not [x0,y0,x1,y1]'; continue; }
        if ($b[0] < 0 || $b[1] < 0 || $b[2] > $w || $b[3] > $h) $bad[] = 'box of ' . $nm . ' outside the picture';
        if ($b[0] < $clear[2] && $b[2] > $clear[0] && $b[1] < $clear[3] && $b[3] > $clear[1]) $bad[] = 'box of ' . $nm . ' covers the compass corner';
        foreach ($boxes as $o => $ob) if ($b[0] < $ob[2] && $b[2] > $ob[0] && $b[1] < $ob[3] && $b[3] > $ob[1]) $bad[] = 'boxes of ' . $o . ' and ' . $nm . ' overlap';
        $boxes[$nm] = $b;
    }
    foreach (['pals' => 'perch', 'party' => 'party slot'] as $key => $what) foreach ($pts[$key] ?? [] as $i => $p) {
        if ($p['x'] >= $clear[0] && $p['x'] <= $clear[2] && $p['y'] >= $clear[1] && $p['y'] <= $clear[3]) $bad[] = $what . ' ' . $i . ' in the compass corner';
    }
    if (isset($L['stand']) && count($L['stand']) < 4) $bad[] = 'fewer than 4 stand slots';   // door and street layouts have no 'stand'
    $seen = [];
    foreach ($L['exits'] ?? [] as $e) {
        if (!isset($e['a'], HERE_ANCHORS[$e['a']])) $bad[] = 'unknown anchor ' . ($e['a'] ?? '?');
        elseif (isset($seen[$e['a']])) $bad[] = 'anchor ' . $e['a'] . ' twice';
        $seen[$e['a'] ?? ''] = 1;
    }
    return $bad;
}

/** Lint every layout in a map. Returns [key => problems] for the ones with problems. */
function here_lint_all(array $all): array
{
    $out = [];
    foreach ($all as $k => $L) if ($p = here_lint_layout($L)) $out[$k] = $p;
    return $out;
}
