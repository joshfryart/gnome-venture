<?php
declare(strict_types=1);
/**
 * The stamp passport (v1.0.0 wave 1): one stamp for every rest stop you have visited, drawn from the stop's type.
 * Sets (stop_sets: total / per stop type / per region) pay out on their own when completed, and some give a title.
 */

require_once __DIR__ . '/stops.php';

/** Inline SVG for a stop type: kind 'icon' or 'stamp'. currentColor, so CSS tints it (and dark mode works). */
function stop_svg(string $type, string $kind = 'icon', string $class = ''): string
{
    static $cache = [];
    $type = preg_replace('/[^a-z0-9_-]/', '', $type) ?: 'camp';
    $base = 'assets/img/stops/' . ($kind === 'stamp' ? 'stamp-' : '') . $type;
    if (is_file(APP_ROOT . '/' . $base . '.png')) {   // v2.0.31: pixel art as an <img> (no currentColor tint)
        return '<img class="' . e(trim($class . ' pix')) . '" src="' . e(url($base . '.png')) . '" alt="" aria-hidden="true" loading="lazy" decoding="async">';
    }
    $file = dirname(__DIR__) . '/' . $base . '.svg';
    if (!isset($cache[$file])) $cache[$file] = is_file($file) ? (string)file_get_contents($file) : '';
    $svg = $cache[$file];
    if ($svg === '') return '';
    return preg_replace('/^<svg /', '<svg class="' . e($class) . '" aria-hidden="true" focusable="false" ', trim($svg), 1);
}

/** All road villages: id => row with ['type']. Cached for the request. */
function stop_road_stops(): array
{
    static $cache = null;
    if ($cache === null) {
        $road = array_fill_keys(array_map('intval', q("SELECT a_id FROM routes WHERE kind = 'road' UNION SELECT b_id FROM routes WHERE kind = 'road'")->fetchAll(PDO::FETCH_COLUMN)), true);
        $cache = [];
        foreach (q("SELECT l.*, r.code AS region_code, r.gnomish_name AS region_name FROM locations l LEFT JOIN regions r ON r.id = l.region_id WHERE l.kind = 'village' ORDER BY r.sort_order, r.id, l.zone_id, l.sort_order, l.id")->fetchAll() as $v) {
            $v['type'] = stop_type_of($v);
            $v['on_road'] = isset($road[(int)$v['id']]);
            $cache[(int)$v['id']] = $v;
        }
    }
    return $cache;
}

/** The stops this gnome has stamped: location_id => stamp row. */
function stop_stamps_of(int $uid): array
{
    $out = [];
    foreach (q('SELECT * FROM stop_stamps WHERE user_id = ?', [$uid])->fetchAll() as $r) $out[(int)$r['location_id']] = $r;
    return $out;
}

/** [have, need] for a set. */
function stop_set_progress(int $uid, array $set, ?array $stamps = null): array
{
    $stamps ??= stop_stamps_of($uid);
    $stops = stop_road_stops();
    $have = 0;
    $total = 0;
    foreach ($stops as $id => $s) {
        $in = match ($set['scope']) {
            'type' => $s['type'] === $set['target'],
            'region' => $s['region_code'] === $set['target'],
            default => true,
        };
        if (!$in) continue;
        if ($s['on_road']) $total++;
        if (isset($stamps[$id])) $have++;
    }
    $need = (int)$set['need'] > 0 ? (int)$set['need'] : $total;
    return [min($have, $need), $need];
}

/** Give a set reward ("c=100,xp=20,item=rope:2"). Returns the lines. */
function stop_grant(int $uid, string $spec): array
{
    $lines = [];
    foreach (array_filter(array_map('trim', explode(',', $spec))) as $tok) {
        [$k, $v] = array_pad(explode('=', $tok, 2), 2, '');
        $p = explode(':', $v);
        if ($k === 'c' && (int)$p[0] > 0) { q('UPDATE users SET coins = coins + ? WHERE id = ?', [(int)$p[0], $uid]); $lines[] = (int)$p[0] . ' ' . setting('currency_name'); }
        elseif ($k === 'xp' && (int)$p[0] > 0) { add_xp($uid, (int)$p[0], 'rest_stop'); $lines[] = (int)$p[0] . ' XP'; }
        elseif ($k === 'item') {
            $id = (int)q_val('SELECT id FROM items WHERE slug = ?', [$p[0] ?? '']);
            $n = max(1, (int)($p[1] ?? 1));
            if ($id && give_item($uid, $id, $n)) $lines[] = $n . ' × ' . q_val('SELECT name FROM items WHERE id = ?', [$id]);
        }
    }
    return $lines;
}

/** Pay out every set that is now complete. Returns messages. */
function stop_sets_check(int $uid): array
{
    $msgs = [];
    $stamps = stop_stamps_of($uid);
    $claimed = array_fill_keys(array_map('intval', q('SELECT set_id FROM stop_set_claims WHERE user_id = ?', [$uid])->fetchAll(PDO::FETCH_COLUMN)), true);
    foreach (q('SELECT * FROM stop_sets WHERE active = 1 ORDER BY CASE WHEN need = 0 THEN 1 ELSE 0 END, need, id')->fetchAll() as $set) {
        if (isset($claimed[(int)$set['id']])) continue;
        [$have, $need] = stop_set_progress($uid, $set, $stamps);
        if ($need < 1 || $have < $need) continue;
        try {
            db_insert('stop_set_claims', ['user_id' => $uid, 'set_id' => (int)$set['id'], 'at' => now()]);
        } catch (PDOException $e) { continue; }
        $lines = stop_grant($uid, (string)$set['reward']);
        if (!empty($set['title'])) {
            q("UPDATE users SET title = ? WHERE id = ? AND (title IS NULL OR title = '')", [$set['title'], $uid]);
            $lines[] = 'the title “' . $set['title'] . '”';
        }
        $msgs[] = '🛂 Passport set complete: ' . $set['label'] . '! You earn ' . ($lines ? implode(', ', $lines) : 'bragging rights') . '.';
    }
    return $msgs;
}

/** Titles earned from passport sets (for the Almanac title picker). */
function stop_titles(int $uid): array
{
    return q("SELECT s.title FROM stop_set_claims c JOIN stop_sets s ON s.id = c.set_id WHERE c.user_id = ? AND s.title IS NOT NULL AND s.title <> '' ORDER BY s.title", [$uid])->fetchAll(PDO::FETCH_COLUMN);
}

/** Stamp this stop. Returns [isNew, messages]. Also counts repeat visits. */
function stop_stamp(int $uid, array $loc): array
{
    if (($loc['kind'] ?? '') !== 'village') return [false, []];
    $visit = (string)q_val('SELECT arrived_at FROM users WHERE id = ?', [$uid]);
    $new = false;
    if (!q_val('SELECT 1 FROM stop_stamps WHERE user_id = ? AND location_id = ?', [$uid, (int)$loc['id']])) {
        try {
            db_insert('stop_stamps', ['user_id' => $uid, 'location_id' => (int)$loc['id'], 'first_at' => now(), 'visits' => 1]);
            $new = true;
        } catch (PDOException $e) { /* a second request got there first */ }
    }
    if (!$new) {
        if (!isset($_SESSION['stop_seen'][(int)$loc['id']]) || $_SESSION['stop_seen'][(int)$loc['id']] !== $visit) {
            q('UPDATE stop_stamps SET visits = visits + 1 WHERE user_id = ? AND location_id = ?', [$uid, (int)$loc['id']]);
        }
    }
    $_SESSION['stop_seen'][(int)$loc['id']] = $visit;
    $msgs = [];
    if ($new) {
        $msgs[] = '🛂 New stamp for your passport!';
        foreach (stop_sets_check($uid) as $m) $msgs[] = $m;
        if (function_exists('calling_event')) calling_event($uid, 'page', 'stop:' . $loc['slug'], 1);
    }
    return [$new, $msgs];
}

/** One stamp tile. */
function stop_stamp_tile(array $s, ?array $stamp): string
{
    $types = stop_types();
    $t = $types[$s['type']] ?? null;
    if ($stamp) {
        return '<div class="st-stamp has" data-sh="' . (int)($t['hue'] ?? 100) . '" title="' . e($s['name']) . ' · stamped ' . e(substr((string)$stamp['first_at'], 0, 10)) . '">'
            . stop_svg($s['type'], 'stamp', 'st-stamp-art') . '<b>' . e($s['name']) . '</b><small>' . e((string)($t['name'] ?? '')) . '</small></div>';
    }
    return '<div class="st-stamp"><span class="st-stamp-ghost">?</span><b>' . e($s['name']) . '</b><small>not yet visited</small></div>';
}

/** The whole passport page body (HTML). */
function stop_passport_html(array $u): string
{
    $uid = (int)$u['id'];
    $stamps = stop_stamps_of($uid);
    $stops = stop_road_stops();
    $types = stop_types();
    $roadTotal = count(array_filter($stops, fn($s) => $s['on_road']));
    $have = count(array_filter($stamps, fn($x, $id) => isset($stops[$id]), ARRAY_FILTER_USE_BOTH));
    $h = '<div class="st-pass"><p class="st-sum"><b>' . $have . '</b> of ' . $roadTotal . ' road stops stamped <small class="muted">(hidden villages you find count too)</small></p>'
        . '<progress max="' . max(1, $roadTotal) . '" value="' . min($have, $roadTotal) . '"></progress>';
    // by type
    $h .= '<h2>Stops by kind</h2><div class="st-kinds">';
    foreach ($types as $slug => $t) {
        $all = count(array_filter($stops, fn($s) => $s['type'] === $slug && $s['on_road']));
        $mine = count(array_filter($stops, fn($s, $id) => $s['type'] === $slug && isset($stamps[$id]), ARRAY_FILTER_USE_BOTH));
        $h .= '<div class="st-kind' . ($mine ? ' has' : '') . '" data-sh="' . (int)$t['hue'] . '">' . stop_svg($slug, 'icon', 'st-ico') . '<b>' . e((string)$t['name']) . '</b><small>' . $mine . ' / ' . $all . '</small></div>';
    }
    $h .= '</div>';
    // sets
    $h .= '<h2>Sets and rewards</h2><ul class="st-sets">';
    $claimed = array_fill_keys(array_map('intval', q('SELECT set_id FROM stop_set_claims WHERE user_id = ?', [$uid])->fetchAll(PDO::FETCH_COLUMN)), true);
    foreach (['total' => 'Anywhere', 'type' => 'By kind of stop', 'region' => 'By region'] as $scope => $label) {
        $rows = q('SELECT * FROM stop_sets WHERE active = 1 AND scope = ? ORDER BY need, id', [$scope])->fetchAll();
        if (!$rows) continue;
        $h .= '<li class="st-setgroup"><b>' . $label . '</b></li>';
        foreach ($rows as $set) {
            [$got, $need] = stop_set_progress($uid, $set, $stamps);
            $isDone = isset($claimed[(int)$set['id']]);
            $h .= '<li class="' . ($isDone ? 'done' : '') . '"><span>' . ($isDone ? '✅ ' : '') . e((string)$set['label']) . ($set['title'] ? ' <small class="tag">“' . e((string)$set['title']) . '”</small>' : '') . '</span>'
                . '<span class="muted">' . $got . '/' . max(1, $need) . '</span><progress max="' . max(1, $need) . '" value="' . $got . '"></progress></li>';
        }
    }
    $h .= '</ul>';
    // stamps by region
    $here = (int)($u['region_id'] ?? 0);
    $byRegion = [];
    foreach ($stops as $id => $s) {
        if (!$s['on_road'] && !isset($stamps[$id])) continue;
        $byRegion[(string)$s['region_name']][] = $s;
    }
    $h .= '<h2>Your stamps</h2>';
    foreach ($byRegion as $region => $list) {
        $n = count(array_filter($list, fn($s) => isset($stamps[(int)$s['id']])));
        $open = $n > 0 && $list[0]['region_id'] == $here;
        $h .= '<details class="box st-region"' . ($open ? ' open' : '') . '><summary><b>' . e($region) . '</b> <small class="muted">' . $n . ' / ' . count($list) . '</small></summary><div class="st-stamps">';
        foreach ($list as $s) $h .= stop_stamp_tile($s, $stamps[(int)$s['id']] ?? null);
        $h .= '</div></details>';
    }
    return $h . '</div>';
}
