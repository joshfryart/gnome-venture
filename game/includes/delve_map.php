<?php
declare(strict_types=1);

/**
 * v2.0.6 Delve and lair maps: the optional map view of a delve (kind 'delve') or a lair (kind 'lair'). The rules do not live here:
 * stepping onto a room tile calls the existing delve_next() (landmarks.php), the boss tile calls lair_engage(), the chest button is the old
 * delve_chest(). This file only makes the map, keeps where you stand and what you have seen (table walk_scene), checks a walk and draws it.
 * The five rooms keep today's rules: the same odds, rewards and danger levels, in the order you go in. Room 5 (the guardian, then the chest)
 * opens only once the other four are done. Walking costs nothing; going into a room costs what it always did (1 energy, free with a lantern).
 * One row per expedition (UNIQUE user_id + exp_id); it is removed whenever the expedition ends (save_exp), and State changes happen inside the
 * adventure.php transaction after the users-row lock (v1.2.2), like every other step.
 */

require_once __DIR__ . '/tilemap.php';
require_once __DIR__ . '/delve_floors.php';   // v2.3.1: the floor pool of the delve redo (pure functions)
require_once __DIR__ . '/delve_route.php';    // v2.3.1: the route graph of the delve redo (pure functions)

const DM_DELVE_SIZE = 11;
const DM_LAIR_SIZE = 13;
const DM_VIEW = 9;   // the window on the screen: 9 x 9 tiles (css shows the middle 7 x 7 on a narrow phone, so every tile stays 44px or more)

/** Admin settings, merged into settings_schema(). */
function dm_settings(): array
{
    return [
        'delve_map' => ['label' => 'Delves: map view', 'type' => 'bool', 'default' => '1'],   // v2.0.6: off = delves and lairs show only the simple list
        'delve_v2' => ['label' => 'Delves: route menu and tile floors (the redo)', 'type' => 'bool', 'default' => '0'],   // v2.3.1: off = today's five rooms; running delves finish on their own rules
    ];
}

function walk_scene_schema(string $PK, string $ID, string $END): array
{
    $t = ["CREATE TABLE IF NOT EXISTS walk_scene (
        id $PK,
        user_id $ID NOT NULL,
        exp_id $ID NOT NULL,
        map_key VARCHAR(60) NOT NULL,
        x INT NOT NULL DEFAULT 0,
        y INT NOT NULL DEFAULT 0,
        seen VARCHAR(500) NOT NULL,
        state VARCHAR(2000) NULL,
        updated_at DATETIME NOT NULL,
        UNIQUE (user_id, exp_id)
    )$END"];
    return [$t, ['CREATE INDEX idx_walk_scene_exp ON walk_scene (exp_id)'], []];
}

/** Is the walk_scene table there? (It is made by the upgrade; if the files are new but the upgrade has not run, make it now.) */
function dm_table_ok(): bool
{
    static $ok = null;
    if ($ok !== null) return $ok;
    try { q('SELECT 1 FROM walk_scene LIMIT 1'); return $ok = true; } catch (Throwable $e) {}
    try {
        $sqlite = db()->getAttribute(PDO::ATTR_DRIVER_NAME) === 'sqlite';
        [$t, $i] = walk_scene_schema($sqlite ? 'INTEGER PRIMARY KEY AUTOINCREMENT' : 'INT UNSIGNED AUTO_INCREMENT PRIMARY KEY', $sqlite ? 'INTEGER' : 'INT UNSIGNED',
            $sqlite ? '' : ' ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci');
        foreach ($t as $sql) db()->exec($sql);
        foreach ($i as $sql) { try { db()->exec($sql); } catch (Throwable $e) {} }
        return $ok = true;
    } catch (Throwable $e) {
        error_log('dm_table_ok: ' . $e->getMessage());
        return $ok = false;
    }
}

/** Is the map view switched on (setting) and usable? */
function dm_on(): bool
{
    $v = setting('delve_map');
    return ($v === '' || $v === '1') && dm_table_ok();
}

/** Are the new route menu and floors switched on? (Needs the map view. A delve already running keeps the rules it started with: see the map_key prefix.) */
function dv_on(): bool
{
    return setting('delve_v2') === '1' && dm_on();
}

/** The player's choice for this session: 'map' (default) or 'list' (the old five-room flow). */
function dm_pref(): string
{
    return (($_SESSION['dm_view'] ?? 'map') === 'list') ? 'list' : 'map';
}

function dm_set_pref(string $v): void
{
    $_SESSION['dm_view'] = $v === 'list' ? 'list' : 'map';
}

/** The hand-built layouts of includes/data/delve_maps.txt: name => rows. */
function dm_layouts(): array
{
    static $all = null;
    if ($all !== null) return $all;
    $all = [];
    $path = __DIR__ . '/data/delve_maps.txt';
    $name = null;
    foreach (is_file($path) ? file($path, FILE_IGNORE_NEW_LINES) : [] as $line) {
        $line = rtrim($line, "\r");
        if ($line !== '' && $line[0] === '@') { $name = trim(substr($line, 1)); $all[$name] = []; continue; }
        if ($name !== null && preg_match('/^[#.,S1-9]+$/', $line)) $all[$name][] = $line;
    }
    foreach ($all as $n => $rows) {   // only layouts that are valid delves are ever used
        $m = tm_parse($rows);
        if ($m['w'] !== DM_DELVE_SIZE || $m['h'] !== DM_DELVE_SIZE || tm_validate($m, ['1', '2', '3', '4', '5'])) unset($all[$n]);
    }
    return $all;
}

/** Which map a landmark gets: [map, key]. A fixed share of delves use a hand-built layout (hash of the landmark), the rest are made from the seed. */
function dm_map_for(string $kind, int $lmId, int $expId): array
{
    if ($kind === 'delve') {
        $hand = array_keys(dm_layouts());
        $h = crc32('dmhand|' . $lmId) % 12;
        if ($hand && $h < count($hand)) return [tm_parse(dm_layouts()[$hand[$h]]), 'h:' . $hand[$h]];
        return [tm_gen('lm' . $lmId . '|' . $expId, DM_DELVE_SIZE, ['1', '2', '3', '4', '5'], 1), 'g11:' . $lmId . ':' . $expId];
    }
    return [tm_gen('lm' . $lmId . '|' . $expId, DM_LAIR_SIZE, ['1'], 3), 'g13:' . $lmId . ':' . $expId];
}

function dm_map_from_key(string $key): ?array
{
    if (preg_match('/^h:([a-z0-9_-]+)$/', $key, $m)) {
        $l = dm_layouts();
        return isset($l[$m[1]]) ? tm_parse($l[$m[1]]) : null;
    }
    if (preg_match('/^g(11|13):(\d+):(\d+)$/', $key, $m)) {
        return $m[1] === '11' ? tm_gen('lm' . $m[2] . '|' . $m[3], DM_DELVE_SIZE, ['1', '2', '3', '4', '5'], 1) : tm_gen('lm' . $m[2] . '|' . $m[3], DM_LAIR_SIZE, ['1'], 3);
    }
    return null;
}

/** How far you see: 2 tiles around you, 3 with a lantern. */
function dm_reveal_radius(int $uid): int
{
    return 2 + (tool_tier($uid, 'lantern') > 0 ? 1 : 0);
}

/** Make the scene of a new delve or lair: the map, you at the entry, the entry room lit. Never breaks the start if it fails. */
function dm_scene_make(int $uid, int $expId, array $lm, string $kind): void
{
    try {
        dm_scene_purge($uid);
        [$map, $key] = dm_map_for($kind, (int)$lm['id'], $expId);
        [$ex, $ey] = $map['entry'];
        $seen = tm_seen_new($map['w'], $map['h']);
        tm_reveal($seen, $map['w'], $map['h'], $ex, $ey, 3);
        db_insert('walk_scene', ['user_id' => $uid, 'exp_id' => $expId, 'map_key' => $key, 'x' => $ex, 'y' => $ey, 'seen' => $seen, 'state' => json_encode(['c' => []]), 'updated_at' => now()]);
    } catch (Throwable $e) {
        error_log('dm_scene_make: ' . $e->getMessage());
    }
}

/** Remove the scene of an expedition (it ended: out, chest, knocked out, abandoned). */
function dm_scene_drop(int $expId): void
{
    try { if (dm_table_ok()) q('DELETE FROM walk_scene WHERE exp_id = ?', [$expId]); } catch (Throwable $e) { error_log('dm_scene_drop: ' . $e->getMessage()); }
}

/** Remove this player's scenes whose expedition is no longer active (left over by anything that ended a walk another way). */
function dm_scene_purge(int $uid): void
{
    q("DELETE FROM walk_scene WHERE user_id = ? AND exp_id NOT IN (SELECT id FROM expeditions WHERE user_id = ? AND status = 'active')", [$uid, $uid]);
}

/** The scene of an active delve or lair: the row, the map, the decoded state, and the rooms brought in line with the room count (see dm_sync). Null = no map for this one. */
function dm_scene(array $exp): ?array
{
    if (!in_array($exp['kind'] ?? '', ['delve', 'lair'], true) || !dm_table_ok()) return null;
    $row = q_one('SELECT * FROM walk_scene WHERE exp_id = ? AND user_id = ?', [(int)$exp['id'], (int)$exp['user_id']]);
    if (!$row) return null;
    $map = dm_map_from_key((string)$row['map_key']);
    if (!$map || !$map['entry']) return null;
    $st = json_decode((string)$row['state'], true);
    $sc = ['row' => $row, 'map' => $map, 'x' => (int)$row['x'], 'y' => (int)$row['y'], 'seen' => (string)$row['seen'], 'c' => array_values(array_map('strval', (array)($st['c'] ?? []))), 'kind' => (string)$exp['kind'], 'dirty' => false];
    dm_sync($sc, $exp);
    return $sc;
}

/**
 * The list view and the topbar can also go into rooms, so the room count (expeditions.depth) is the truth and the map follows it: any room
 * done without a tile gets the lowest free spot (room 5 last) and you are put on it.
 */
function dm_sync(array &$sc, array $exp): void
{
    $depth = (int)($exp['depth'] ?? 0);
    $want = $sc['kind'] === 'lair' ? min(1, $depth) : min(DELVE_ROOMS, $depth);
    while (count($sc['c']) < $want) {
        $pick = null;
        foreach ($sc['kind'] === 'lair' ? ['1'] : ['1', '2', '3', '4', '5'] as $code) {
            if (in_array($code, $sc['c'], true)) continue;
            if ($code === '5' && count($sc['c']) < 4) continue;
            $pick = $code;
            break;
        }
        if ($pick === null) break;
        $sc['c'][] = $pick;
        [$sc['x'], $sc['y']] = $sc['map']['spots'][$pick];
        $r = dm_reveal_radius((int)$exp['user_id']);
        tm_reveal($sc['seen'], $sc['map']['w'], $sc['map']['h'], $sc['x'], $sc['y'], $r);
        $sc['dirty'] = true;
    }
}

function dm_scene_save(array $sc): void
{
    q('UPDATE walk_scene SET x = ?, y = ?, seen = ?, state = ?, updated_at = ? WHERE id = ?',
        [$sc['x'], $sc['y'], $sc['seen'], json_encode(['c' => array_values($sc['c'])]), now(), $sc['row']['id']]);
}

/** Has this spot code been dealt with (gone into)? */
function dm_done(array $sc, string $code): bool
{
    return in_array($code, $sc['c'], true);
}

/** Is the guardian's door (room 5 of a delve) open yet? */
function dm_guard_open(array $sc): bool
{
    $n = 0;
    foreach ($sc['c'] as $c) if ($c !== '5') $n++;
    return $n >= DELVE_ROOMS - 1;
}

/** The gate for walking: a room that is not done yet closes the way (you only ever stop ON it as the goal), a room still barred is closed to everyone. */
function dm_gate(array $sc, ?int $goalX = null, ?int $goalY = null): callable
{
    return function (int $x, int $y, string $t) use ($sc, $goalX, $goalY): bool {
        if (!ctype_digit($t)) return true;
        if (dm_done($sc, $t)) return true;
        if ($sc['kind'] === 'delve' && $t === '5' && !dm_guard_open($sc)) return false;
        return $x === $goalX && $y === $goalY;
    };
}

/**
 * Walk to a tile. Validates everything again on the server (the page is only buttons): seen, a way there, the room not barred.
 * Stepping onto a room that is not done goes in: delve_next() / lair_engage(). Returns [ok, message].
 */
function dm_walk(array $u, array &$exp, int $tx, int $ty): array
{
    $sc = dm_scene($exp);
    if (!$sc) return [false, 'There is no map here. Use the simple list.'];
    if ($exp['status'] !== 'active') return [false, 'This is over.'];
    if ($exp['encounter']) return [false, 'Deal with what is in front of you first.'];
    $map = $sc['map'];
    if (!tm_seen_get($sc['seen'], $map['w'], $map['h'], $tx, $ty)) return [false, 'You can’t see that far yet.'];
    $t = tm_tile($map, $tx, $ty);
    if ($t === '#' || $t === ' ') return [false, 'That is solid rock.'];
    $code = ctype_digit($t) ? $t : '';
    $room = $code !== '' && !dm_done($sc, $code);
    if ($room && $sc['kind'] === 'delve' && $code === '5' && !dm_guard_open($sc)) return [false, 'The guardian’s door stays barred until the other four rooms are done.'];
    $here = $sc['x'] === $tx && $sc['y'] === $ty;
    $path = $here ? [] : tm_path($map, $sc['x'], $sc['y'], $tx, $ty, dm_gate($sc, $tx, $ty));
    if (!$here && !$path) return [false, 'There’s no way there from here.'];
    if ($here && !$room) return [false, 'You are already here.'];
    $uid = (int)$u['id'];
    if ($room && $sc['kind'] === 'delve' && !tool_tier($uid, 'lantern') && (int)($u['energy'] ?? 0) < 1) return [false, 'You’re too tired to go into another room. Rest, or climb back out.'];
    $r = dm_reveal_radius($uid);
    $walked = [[$sc['x'], $sc['y']]];
    foreach ($path as [$px, $py]) {
        $walked[] = [$px, $py];
        tm_reveal($sc['seen'], $map['w'], $map['h'], $px, $py, $r);
    }
    $sc['x'] = $tx;
    $sc['y'] = $ty;
    if ($room) {
        if ($sc['kind'] === 'delve') {
            $before = (int)$exp['depth'];
            delve_next($u, $exp);
            if ((int)$exp['depth'] > $before) $sc['c'][] = $code;
        } else {
            lair_engage($exp);
            $sc['c'][] = $code;
        }
    }
    dm_scene_save($sc);
    if (count($walked) > 1) $_SESSION['dm_walk'] = ['e' => (int)$exp['id'], 't' => time(), 'p' => $walked];
    return [true, ''];
}

/** The path walked by the last tap (one-shot, from the session), or null. Fresh for 30 s, this expedition only. */
function dm_walk_take(array $exp, array $sc): ?array
{
    $w = $_SESSION['dm_walk'] ?? null;
    unset($_SESSION['dm_walk']);
    if (!is_array($w) || (int)($w['e'] ?? 0) !== (int)$exp['id'] || time() - (int)($w['t'] ?? 0) > 30 || !is_array($w['p'] ?? null) || count($w['p']) < 2) return null;
    $p = [];
    foreach ($w['p'] as $pt) $p[] = [(int)($pt[0] ?? 0), (int)($pt[1] ?? 0)];
    $last = end($p);
    return $last[0] === $sc['x'] && $last[1] === $sc['y'] ? ['p' => $p] : null;
}

/** What the tile under the player is, in words, for the line under the map. */
function dm_here_note(array $sc, array $exp): string
{
    $t = tm_tile($sc['map'], $sc['x'], $sc['y']);
    if ($t === 'S') return 'You are at the entrance.';
    return '';
}

/**
 * The whole map block: the picture, the grid of buttons over it (a form: name="go" value="x,y"), the legend and the link to the list.
 * $busy = something is in front of you (a fight or a trap): the buttons rest.
 */
function dm_view_html(array $u, array $exp, array $sc, bool $busy): string
{
    require_once __DIR__ . '/trek_art.php';   // trek_art_me(): the player's own gnome as the token (read only)
    $map = $sc['map'];
    $w = $map['w'];
    $h = $map['h'];
    $win = tm_window($sc['x'], $sc['y'], DM_VIEW, DM_VIEW);
    $land = (string)(exp_scene($exp)['land'] ?? 'forest');
    $lair = $sc['kind'] === 'lair';
    $depth = (int)$exp['depth'];
    $chestReady = !$lair && $depth >= DELVE_ROOMS && dm_done($sc, '5');
    // what each spot looks like
    $tokens = [];
    foreach ($map['spots'] as $code => [$sx, $sy]) {
        if (!tm_seen_get($sc['seen'], $w, $h, $sx, $sy) || ($sx === $sc['x'] && $sy === $sc['y'])) continue;
        $done = dm_done($sc, (string)$code);
        if ($lair) $tokens[] = [$sx, $sy, '🐉', 'ember', $done];
        elseif ((string)$code === '5') $tokens[] = [$sx, $sy, $done ? '💰' : '🛡️', 'ember', false, !$done && !dm_guard_open($sc)];
        else $tokens[] = [$sx, $sy, '🚪', 'gold', $done];
    }
    $gate = dm_gate($sc);
    $reach = tm_reach($map, $sc['x'], $sc['y'], $gate);
    $open = str_repeat('0', $w * $h);
    $lit = [];   // tiles you can tap now: reached floor, and the rooms next to it that are open
    for ($y = 0; $y < $h; $y++) {
        for ($x = 0; $x < $w; $x++) {
            if (!tm_seen_get($sc['seen'], $w, $h, $x, $y)) continue;
            $t = tm_tile($map, $x, $y);
            if ($t === '#' || $t === ' ') continue;
            $ok = isset($reach[$y * $w + $x]);
            if (!$ok && ctype_digit($t) && !dm_done($sc, $t) && !($t === '5' && !$lair && !dm_guard_open($sc))) {
                foreach ([[1, 0], [-1, 0], [0, 1], [0, -1]] as [$dx, $dy]) if (isset($reach[($y + $dy) * $w + $x + $dx]) && $x + $dx >= 0 && $x + $dx < $w) $ok = true;
            }
            if ($ok) { $lit[$y * $w + $x] = true; $open[$y * $w + $x] = ctype_digit($t) && !dm_done($sc, $t) ? '2' : '1'; }   // 1 = floor to walk over, 2 = a room: where a walk can end
        }
    }
    $walk = dm_walk_take($exp, $sc);
    $svg = tm_render_svg($map, $land, [
        'px' => $sc['x'], 'py' => $sc['y'], 'seen' => $sc['seen'], 'x0' => $win['x0'], 'y0' => $win['y0'], 'cols' => DM_VIEW, 'rows' => DM_VIEW,
        'light' => dm_reveal_radius((int)$u['id']) + 1, 'tokens' => $tokens, 'walk' => $walk, 'me' => trek_art_me($u),
    ]);
    // v2.0.10: a wider picture covering the whole walk, shown only while the token walks (assets/tilemap.js keeps the camera on it)
    $extSvg = '';
    $extData = '';
    if ($walk && count($walk['p']) > 1) {
        $xs = array_column($walk['p'], 0);
        $ys = array_column($walk['p'], 1);
        $ex0 = min(min($xs) - 5, $win['x0']);
        $ey0 = min(min($ys) - 5, $win['y0']);
        $ex1 = max(max($xs) + 6, $win['x0'] + DM_VIEW);
        $ey1 = max(max($ys) + 6, $win['y0'] + DM_VIEW);
        if (($ex1 - $ex0) * ($ey1 - $ey0) <= 900) {
            $extSvg = tm_render_svg($map, $land, [
                'px' => $sc['x'], 'py' => $sc['y'], 'seen' => $sc['seen'], 'x0' => $ex0, 'y0' => $ey0, 'cols' => $ex1 - $ex0, 'rows' => $ey1 - $ey0,
                'light' => dm_reveal_radius((int)$u['id']) + 1, 'dim' => 999, 'tokens' => $tokens, 'walk' => $walk, 'me' => trek_art_me($u), 'sfx' => 'x',
            ]);
            $extData = ' data-ex0="' . $ex0 . '" data-ey0="' . $ey0 . '" data-ew="' . ($ex1 - $ex0) . '" data-eh="' . ($ey1 - $ey0) . '"';
        }
    }
    $btn = '';
    for ($j = 0; $j < DM_VIEW; $j++) {
        for ($i = 0; $i < DM_VIEW; $i++) {
            $x = $win['x0'] + $i;
            $y = $win['y0'] + $j;
            $t = tm_tile($map, $x, $y);
            $seenIt = tm_seen_get($sc['seen'], $w, $h, $x, $y);
            $cls = 'tmt' . (($i === 0 || $j === 0 || $i === DM_VIEW - 1 || $j === DM_VIEW - 1) ? ' ring' : '');
            $label = '';
            $me = $x === $sc['x'] && $y === $sc['y'];
            $tap = isset($lit[$y * $w + $x]) && !$busy;
            if (!$seenIt || $t === ' ') $cls .= ' fog';
            elseif ($t === '#') $cls .= ' wall';
            else {
                $cls .= $tap ? ' reach' : '';
                if (ctype_digit($t)) {
                    $done = dm_done($sc, $t);
                    $barred = !$lair && $t === '5' && !$done && !dm_guard_open($sc);
                    $cls .= ' spot' . ($done ? ' done' : '') . ($barred ? ' barred' : '');
                    $label = $lair ? ($done ? 'The lair’s heart' : 'The boss’s lair') : ($t === '5' ? ($done ? 'The chest' : ($barred ? 'The guardian’s door, barred' : 'The guardian’s room')) : ($done ? 'Room, done' : 'Room'));
                    if ($me && !$done) $tap = !$busy;
                } elseif ($t === 'S') {
                    $label = 'The entrance';
                }
            }
            if ($me) { $cls .= ' here'; $label = 'You are here'; }
            $dis = !$tap || ($me && !(ctype_digit($t) && !dm_done($sc, $t)));
            $btn .= '<button type="submit" class="' . $cls . '" name="go" value="' . $x . ',' . $y . '"' . ($dis ? ' disabled' : '') . ($label !== '' ? ' aria-label="' . e($label) . '"' : ($tap ? ' aria-label="Walk here"' : ' tabindex="-1"')) . '></button>';
        }
    }
    $data = ' data-tile="' . TM_UNIT . '" data-cols="' . DM_VIEW . '" data-rows="' . DM_VIEW . '" data-x0="' . $win['x0'] . '" data-y0="' . $win['y0'] . '" data-px="' . $sc['x'] . '" data-py="' . $sc['y'] . '" data-mw="' . $w . '" data-mh="' . $h . '" data-open="' . $open . '"' . $extData;
    if ($walk) $data .= ' data-walk="' . e(implode(';', array_map(fn($p) => $p[0] . ',' . $p[1], $walk['p']))) . '"';
    $legend = $lair ? '<span>🐉 Boss</span><span>🪜 Entrance</span>' : '<span>🚪 Room</span><span>🛡️ Guardian</span><span>💰 Chest</span><span>🪜 Entrance</span>';
    $out = '<div class="tmwrap tm-' . e($land) . ($busy ? ' busy' : '') . '"><form method="post" class="tmform">' . csrf_field() . '<input type="hidden" name="do" value="go">'
        . '<div class="tilemap tm-cave" role="group" aria-label="' . ($lair ? 'Lair map' : 'Delve map') . '"' . $data . '><div class="tmview">' . $extSvg . '<div class="tmstage">' . $svg
        . '<svg class="tmpv" viewBox="0 0 ' . (DM_VIEW * TM_UNIT) . ' ' . (DM_VIEW * TM_UNIT) . '" preserveAspectRatio="none" aria-hidden="true" focusable="false"></svg><span class="tmchip" hidden></span>'
        . '<div class="tmgrid">' . $btn . '</div></div></div></div></form>'
        . '<p class="tmlegend" aria-hidden="true">' . $legend . '</p></div>';
    return $out;
}
