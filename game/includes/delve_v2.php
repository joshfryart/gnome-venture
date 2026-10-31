<?php
declare(strict_types=1);

/**
 * v2.3.1 Delve redo, the engine (claude/plan-delves.md). Behind the setting delve_v2 (dv_on()). A delve is still ONE expeditions row (kind 'delve');
 * expeditions.depth counts stages cleared and steps_total = the stages, so the chest, the clear count and the fight screens work as before.
 * The walk_scene row has map_key 'v2' and its state JSON holds everything: {v:2, rs: route seed, st: stages, at: last picked node or null,
 * pk: [picked node ids], u: [floor keys used], q: pending quick card ('shrine'|'mole') or null,
 * f: null (the route menu) or {k: floor key | 'g', gs: seed (generated), ti: tier, kd: kind, n: node, t: torch, got: ["x,y"], key: 0|1}}.
 * The row's x, y, seen belong to the floor you are on. A floor is a tile map (includes/delve_floors.php characters): finds, foe F, trap T, chest C,
 * key K and door D, shrine M, way down E, guardian B. The torch is the timer: each step costs 1 (hazard W costs 2); at 0 the light shrinks to 1 tile and
 * nothing fails. Everything is checked again on the server; the page is only buttons (name="go" value="x,y").
 */

require_once __DIR__ . '/delve_route.php';
require_once __DIR__ . '/delve_stamp.php';

/** Floor objects by node kind for a generated floor (the last spot is the farthest room: the way down E, or the guardian B). */
const DV2_GEN = [
    'fight' => ['F', '1', 'F', 'E'], 'treasure' => ['1', 'C', 'E'], 'mystery' => ['1', 'T', 'E'], 'puzzle' => ['1', 'T', '1', 'E'], 'boss' => ['C', 'B'],
];
const DV2_BAR = '12345678';   // spot codes handed to tm_gen
const DV2_TORCH_LANTERN = 10;   // extra torch steps per lantern tier

/** The delve's slug for its floor pool: its name, lower case with dashes ("Sea-cave Smugglers' Run" = sea-cave-smugglers-run, like the art file names). */
function dv2_slug(array $lm): string
{
    return trim((string)preg_replace('/[^a-z0-9]+/', '-', strtolower((string)($lm['name'] ?? 'delve'))), '-');
}

function dv2_seed(int $uid, int $lmId): string
{
    return substr(md5('dv2|' . $uid . '|' . $lmId . '|' . landmark_day()), 0, 12);   // one route per gnome, delve and day
}

/** Torch fuel for a floor of a tier. */
function dv2_fuel(int $uid, string $tier): int
{
    return DV_TORCH[$tier] + DV2_TORCH_LANTERN * tool_tier($uid, 'lantern');
}

/** Light radius: the usual, or 1 tile once the torch is out. */
function dv2_light(int $uid, int $torch): int
{
    return $torch > 0 ? dm_reveal_radius($uid) : 1;
}

/** Make the scene of a new v2 delve: the route (from a seed), standing at the route menu. False if it could not be made (the caller falls back to the old delve). */
function dv2_scene_make(int $uid, int $expId, array $lm): bool
{
    try {
        dm_scene_purge($uid);
        $st = ['v' => 2, 'rs' => dv2_seed($uid, (int)$lm['id']), 'st' => dv_stages((int)$lm['level']), 'at' => null, 'pk' => [], 'u' => [], 'q' => null, 'f' => null];
        db_insert('walk_scene', ['user_id' => $uid, 'exp_id' => $expId, 'map_key' => 'v2', 'x' => 0, 'y' => 0, 'seen' => '0', 'state' => json_encode($st), 'updated_at' => now()]);
        return true;
    } catch (Throwable $e) {
        error_log('dv2_scene_make: ' . $e->getMessage());
        return false;
    }
}

/** The v2 scene of an active delve: row, state, route, and (on a floor) the map. Null = not a v2 delve. */
function dv2_scene(array $exp): ?array
{
    if (($exp['kind'] ?? '') !== 'delve' || !dm_table_ok()) return null;
    $row = q_one('SELECT * FROM walk_scene WHERE exp_id = ? AND user_id = ?', [(int)$exp['id'], (int)$exp['user_id']]);
    if (!$row || (string)$row['map_key'] !== 'v2') return null;
    $st = json_decode((string)$row['state'], true);
    if (!is_array($st) || ($st['v'] ?? 0) !== 2) return null;
    $lm = landmark_at((int)$exp['from_id']);
    $route = dv_route((string)$st['rs'], dv2_slug((array)$lm), (int)$st['st']);
    $sc = ['row' => $row, 'st' => $st, 'route' => $route, 'map' => null, 'x' => (int)$row['x'], 'y' => (int)$row['y'], 'seen' => (string)$row['seen'], 'kind' => 'delve', 'lm' => $lm];
    if (!empty($st['f'])) {
        $sc['map'] = dv2_floor_map($st['f']);
        if (!$sc['map'] || !$sc['map']['entry']) return null;
    }
    return $sc;
}

function dv2_save(array $sc): void
{
    q('UPDATE walk_scene SET x = ?, y = ?, seen = ?, state = ?, updated_at = ? WHERE id = ?', [$sc['x'], $sc['y'], $sc['seen'], json_encode($sc['st']), now(), $sc['row']['id']]);
}

/** A floor made from a seed (no authored floor for it): stamped from the delve's chambers when it has them, else a cave from tm_gen. The objects of the node kind are put on it. */
function dv2_gen_floor(string $seed, string $tier, string $kind, string $slug = ''): array
{
    $objs = DV2_GEN[$kind] ?? DV2_GEN['fight'];
    if ($slug !== '' && ($st = ds_floor($seed, $slug, $tier, $objs))) return $st;
    $codes = array_map('strval', range(1, count($objs)));
    $m = tm_gen($seed, DV_TIERS[$tier], $codes, 1);
    $rows = [];
    foreach ($m['t'] as $r) {
        $o = '';
        for ($i = 0, $n = strlen($r); $i < $n; $i++) $o .= ctype_digit($r[$i]) ? ($objs[(int)$r[$i] - 1] ?? '.') : $r[$i];
        $rows[] = $o;
    }
    return tm_parse($rows);
}

/** The map of a floor state: an authored floor from the pool, or a generated one. */
function dv2_floor_map(array $f): ?array
{
    if (($f['k'] ?? '') === 'g') return dv2_gen_floor((string)$f['gs'], (string)$f['ti'], (string)$f['kd'], (string)($f['sl'] ?? ''));
    $all = dv_floors();
    return isset($all[$f['k']]) ? $all[$f['k']]['map'] : null;
}

/** Stage level: the delve's level, plus the stages cleared; the guardian two more. */
function dv2_level(array $sc, array $exp, bool $boss = false): int
{
    return (int)($sc['lm']['level'] ?? 5) + (int)$exp['depth'] + ($boss ? 2 : 0);
}

/** Is a tile an object (something that happens when you stand on it) that has not happened yet? */
function dv2_live(array $sc, int $x, int $y): bool
{
    $t = tm_tile($sc['map'], $x, $y);
    if (!(ctype_digit($t) || strpos('FTCKMEB', $t) !== false)) return false;
    return !in_array($x . ',' . $y, $sc['st']['f']['got'] ?? [], true);
}

/** Walking gate: a live object closes the way (you only stop ON it as the goal), a locked door is shut, a boss floor's chest waits for the guardian. */
function dv2_gate(array $sc, ?int $gx = null, ?int $gy = null): callable
{
    $key = !empty($sc['st']['f']['key']);
    return function (int $x, int $y, string $t) use ($sc, $key, $gx, $gy): bool {
        if ($t === 'D') return $key;
        if (!dv2_live($sc, $x, $y)) return true;
        if ($t === 'C' && dv2_boss_floor($sc) && !dv2_boss_down($sc)) return false;
        return $x === $gx && $y === $gy;
    };
}

function dv2_boss_floor(array $sc): bool
{
    return ($sc['st']['f']['kd'] ?? '') === 'boss';
}

function dv2_boss_down(array $sc): bool
{
    foreach (dv_find_all($sc['map'], 'B') as [$x, $y]) if (in_array($x . ',' . $y, $sc['st']['f']['got'] ?? [], true)) return true;
    return false;
}

/** Step onto a route node: start its floor (or its card). $nodeId must be one of the current choices. */
function dv2_pick(array $u, array &$exp, array &$sc, string $nodeId): array
{
    if ($exp['status'] !== 'active' || $exp['encounter']) return [false, 'Deal with what is in front of you first.'];
    if (!empty($sc['st']['f']) || !empty($sc['st']['q'])) return [false, 'Finish where you are first.'];
    if (!in_array($nodeId, dv_route_choices($sc['route'], $sc['st']['at']), true)) return [false, 'You can’t go that way from here.'];
    $node = dv_route_node($sc['route'], $nodeId);
    $uid = (int)$u['id'];
    $sc['st']['pk'][] = $nodeId;
    if (!dv_node_has_floor($node)) {
        $sc['st']['q'] = $node['kind'];
        $sc['st']['at'] = $nodeId;
        exp_log($exp, $node['kind'] === 'shrine' ? '🕯️ A small shrine glows in a side chamber.' : '⛏️ A mole in a miner’s cap waves from a side tunnel.');
        dv2_save($sc);
        return [true, ''];
    }
    $first = !q_one('SELECT id FROM landmark_clears WHERE user_id = ? AND landmark_id = ?', [$uid, (int)$sc['lm']['id']]);
    $pickFloor = dv_floor_pick($sc['route'], $nodeId, $sc['st']['u'], $first);
    $tier = (string)($node['tier'] ?? 'standard');
    if ($pickFloor['src'] === 'pool') {
        $f = ['k' => $pickFloor['key'], 'ti' => dv_floors()[$pickFloor['key']]['tier'], 'kd' => $node['kind']];
        $sc['st']['u'][] = $pickFloor['key'];
    } else {
        $f = ['k' => 'g', 'gs' => $sc['st']['rs'] . '|' . $nodeId, 'ti' => $tier, 'kd' => $node['kind'], 'sl' => dv2_slug((array)$sc['lm'])];
    }
    $f += ['n' => $nodeId, 't' => dv2_fuel($uid, $f['ti']), 'got' => [], 'key' => 0];
    $sc['st']['f'] = $f;
    $sc['st']['at'] = $nodeId;
    $sc['map'] = dv2_floor_map($f);
    if (!$sc['map'] || !$sc['map']['entry']) { $sc['st']['f'] = null; return [false, 'That way is blocked. Try another.']; }
    [$sc['x'], $sc['y']] = $sc['map']['entry'];
    $sc['seen'] = tm_seen_new($sc['map']['w'], $sc['map']['h']);
    tm_reveal($sc['seen'], $sc['map']['w'], $sc['map']['h'], $sc['x'], $sc['y'], dv2_light($uid, $f['t']) + 1);
    $exp['level'] = dv2_level($sc, $exp, $node['kind'] === 'boss');
    exp_log($exp, ($node['kind'] === 'boss' ? '🛡️ The guardian’s hall. ' : '🔦 You step into the next chamber. ') . 'Danger level ' . (int)$exp['level'] . '.');
    dv2_save($sc);
    return [true, ''];
}

/** Resolve a quick card (shrine: heal; mole: a small find). Counts as a cleared stage. */
function dv2_quick(array $u, array &$exp, array &$sc): array
{
    $q = $sc['st']['q'] ?? null;
    if (!$q || $exp['encounter'] || $exp['status'] !== 'active') return [false, 'Nothing to do here.'];
    if ($q === 'shrine') {
        $exp['hp'] = (int)$exp['max_hp'];
        exp_log($exp, '🕯️ You rest by the shrine. Your hurts mend.');
    } else {
        exp_log($exp, '⛏️ Mo digs and hands you something: ' . give_find($u, exp_scene($exp)));
    }
    $sc['st']['q'] = null;
    $exp['depth'] = (int)$exp['depth'] + 1;
    $exp['step'] = (int)$exp['depth'];
    dv2_save($sc);
    return [true, ''];
}

/** What stepping onto an object does. Returns nothing; logs, may start a fight or a trap card, may end the floor. */
function dv2_touch(array $u, array &$exp, array &$sc, string $t, int $x, int $y): void
{
    $uid = (int)$u['id'];
    $land = (string)(exp_scene($exp)['land'] ?? 'forest');
    $sc['st']['f']['got'][] = $x . ',' . $y;
    $boss = dv2_boss_floor($sc);
    if (ctype_digit($t)) {
        exp_log($exp, '✨ ' . give_find($u, exp_scene($exp)));
    } elseif ($t === 'F' || $t === 'B') {
        $lvl = dv2_level($sc, $exp, $t === 'B');
        $exp['level'] = $lvl;
        $c = pick_creature($land, $lvl, false);
        if ($c) {
            $exp['encounter'] = json_encode(['type' => 'creature', 'id' => (int)$c['id'], 'lv' => !empty($c['_scaled']) ? (int)$c['level'] : 0, 'sp' => (int)($c['_pct'] ?? 100), 'hpp' => (int)($c['_hpp'] ?? 100), 'hp' => (int)$c['hp'], 'max' => (int)$c['hp'], 'bark' => 0, 'poison' => 0, 'used' => false]);
            exp_log($exp, ($t === 'B' ? '🛡️ The chest is guarded by ' : '⚔️ ') . (preg_match('/^[AEIOU]/i', $c['name']) ? 'an ' : 'a ') . $c['name'] . '!');
        } else {
            exp_log($exp, '✨ ' . give_find($u, exp_scene($exp)));
        }
        if ($t === 'B') { $exp['depth'] = (int)$exp['depth'] + 1; $exp['step'] = (int)$exp['depth']; }   // the guardian stage is cleared once you face it, like room 5
    } elseif ($t === 'T') {
        if ($p = pick_problem($land)) {
            $lantern = tool_tier($uid, 'lantern');
            $exp['encounter'] = json_encode(['type' => 'problem', 'id' => (int)$p['id'], 'dc_bonus' => 1 + intdiv((int)$exp['depth'] + 1, 2) - [0, 0, 2, 3][min(3, $lantern)]]);
            exp_log($exp, '🪤 ' . $p['text']);
        }
    } elseif ($t === 'C') {
        if ($boss) { delve_chest($u, $exp); return; }
        exp_log($exp, '🎁 A chest! ' . give_find($u, exp_scene($exp)) . ' ' . give_find($u, exp_scene($exp)));
    } elseif ($t === 'K') {
        $sc['st']['f']['key'] = 1;
        exp_log($exp, '🗝️ A rusty key. It might open a door nearby.');
    } elseif ($t === 'M') {
        $exp['hp'] = (int)$exp['max_hp'];
        $sc['st']['f']['t'] = dv2_fuel($uid, (string)$sc['st']['f']['ti']);
        exp_log($exp, '🕯️ A moss shrine. Your hurts mend and your torch burns bright again.');
    } elseif ($t === 'E') {
        $exp['depth'] = (int)$exp['depth'] + 1;
        $exp['step'] = (int)$exp['depth'];
        $sc['st']['f'] = null;
        exp_log($exp, '🕳️ You find the way down. Stage ' . (int)$exp['depth'] . ' of ' . (int)$exp['steps_total'] . ' is done.');
    }
}

/** Walk to a tile on the floor. Server side checks: seen, a way there, not busy. Torch burns per step. Returns [ok, message]. */
function dv2_walk(array $u, array &$exp, array &$sc, int $tx, int $ty): array
{
    if ($exp['status'] !== 'active') return [false, 'This is over.'];
    if ($exp['encounter']) return [false, 'Deal with what is in front of you first.'];
    if (empty($sc['st']['f']) || !$sc['map']) return [false, 'Pick a way on first.'];
    $map = $sc['map'];
    if (!tm_seen_get($sc['seen'], $map['w'], $map['h'], $tx, $ty)) return [false, 'You can’t see that far yet.'];
    $t = tm_tile($map, $tx, $ty);
    if ($t === '#' || $t === ' ') return [false, 'That is solid rock.'];
    if ($t === 'D' && empty($sc['st']['f']['key'])) return [false, 'The door is locked. A key lies somewhere on this floor.'];
    if ($t === 'C' && dv2_boss_floor($sc) && dv2_live($sc, $tx, $ty) && !dv2_boss_down($sc)) return [false, 'The guardian stands between you and the chest.'];
    $here = $sc['x'] === $tx && $sc['y'] === $ty;
    $live = dv2_live($sc, $tx, $ty);
    $path = $here ? [] : tm_path($map, $sc['x'], $sc['y'], $tx, $ty, dv2_gate($sc, $tx, $ty));
    if (!$here && !$path) return [false, 'There’s no way there from here.'];
    if ($here && !$live) return [false, 'You are already here.'];
    $uid = (int)$u['id'];
    $torch = (int)$sc['st']['f']['t'];
    $walked = [[$sc['x'], $sc['y']]];
    foreach ($path as [$px, $py]) {
        $walked[] = [$px, $py];
        $torch = max(0, $torch - dv_step_cost(tm_tile($map, $px, $py)));
        tm_reveal($sc['seen'], $map['w'], $map['h'], $px, $py, dv2_light($uid, $torch));
    }
    $sc['st']['f']['t'] = $torch;
    $sc['x'] = $tx;
    $sc['y'] = $ty;
    if ($live) dv2_touch($u, $exp, $sc, $t, $tx, $ty);
    dv2_save($sc);
    if (count($walked) > 1) $_SESSION['dm_walk'] = ['e' => (int)$exp['id'], 't' => time(), 'p' => $walked];
    return [true, ''];
}

// ------------------------------------------------------------------ view

const DV2_TOKEN = ['F' => ['⚔️', 'ember'], 'B' => ['🛡️', 'ember'], 'T' => ['🪤', 'ember'], 'C' => ['🎁', 'gold'], 'K' => ['🗝️', 'gold'], 'D' => ['🚪', 'gold'], 'M' => ['🕯️', 'gold'], 'E' => ['🕳️', 'gold']];
const DV2_KIND = ['fight' => ['⚔️', 'Creature'], 'treasure' => ['💰', 'Treasure'], 'mystery' => ['❓', 'Mystery'], 'puzzle' => ['🧩', 'Puzzle'], 'shrine' => ['🕯️', 'Shrine'], 'mole' => ['⛏️', 'Mo the mole'], 'boss' => ['🛡️', 'The guardian']];
const DV2_SIZE = ['small' => 'short', 'standard' => 'medium', 'large' => 'long'];

/** The strip under the map: the torch and your party (the gnome and the pals taken along, read only). */
function dv2_party_html(array $u, array $exp, ?array $sc): string
{
    $o = '<div class="dv2strip"><div class="dv2top"><span class="dv2chip">Stage <b>' . min((int)$exp['steps_total'], (int)$exp['depth'] + 1) . '</b>/' . (int)$exp['steps_total'] . ' · danger ' . (int)$exp['level'] . '</span>';
    if ($sc && !empty($sc['st']['f'])) {
        $f = $sc['st']['f'];
        $max = dv2_fuel((int)$u['id'], (string)$f['ti']);
        $pct = $max > 0 ? max(0, min(100, (int)round(100 * (int)$f['t'] / $max))) : 0;
        $o .= '<span class="dv2torch" title="Each step burns the torch. At 0 the light shrinks, nothing else happens.">🔦<span class="dv2bar"><i style="width:' . $pct . '%"></i></span><b>' . (int)$f['t'] . '</b></span>';
    }
    if ($exp['status'] === 'active' && !$exp['encounter']) {
        $o .= '<form method="post" class="inline dv2leave" data-confirm="Climb back out? You keep what you found, but this delve is done for today.">' . csrf_field() . '<input type="hidden" name="do" value="leave"><button class="btn ghost" aria-label="Climb back out">🪜 Leave</button></form>';
    }
    $o .= '</div><div class="dv2party"><span class="dv2m">🧙 <b>You</b> ' . (int)$exp['hp'] . '/' . (int)$exp['max_hp'] . ' ❤️</span>';
    try {
        require_once __DIR__ . '/puzzle_pals.php';
        if (ppal_party_on() && function_exists('ppal_equipped')) {
            $by = [];
            if (function_exists('pj_pals')) foreach (pj_pals((int)$u['id']) as $p) $by[$p['key']] = $p;
            foreach (ppal_equipped($u) as $e) {
                $p = $by[$e['pal']['key']] ?? null;
                $o .= '<span class="dv2m">' . ppal_sticker_html((string)$e['pal']['key'], 28) . ' <b>' . e((string)$e['pal']['name']) . '</b>' . ($p ? ' Lv ' . (int)$p['a'] . ' · ' . (int)$p['hp'] . '/' . (int)$p['max'] . ' ❤️' : '') . '</span>';
            }
        }
    } catch (Throwable $e) { error_log('dv2_party_html: ' . $e->getMessage()); }
    return $o . '</div></div>';
}

/** The route menu: the rows of the route, the nodes you can go to now are buttons (kind shown), the rest are "?" (or what you chose). */
function dv2_menu_html(array $u, array $exp, array $sc, bool $busy): string
{
    $route = $sc['route'];
    $at = $sc['st']['at'];
    $choices = $busy || !empty($sc['st']['q']) ? [] : dv_route_choices($route, $at);
    $picked = $sc['st']['pk'];
    $o = '<div class="dv2route"><p class="dv2lead">' . ($at === null ? 'Which way down?' : 'Which way next?') . '</p>';
    $o .= '<form method="post" class="dv2routeform">' . csrf_field() . '<input type="hidden" name="do" value="route">';
    $atRow = $at === null ? -1 : (int)dv_route_node($route, $at)['row'];
    foreach ($route['rows'] as $r => $row) {
        if ($r <= $atRow) continue;   // rows behind you are not shown
        $o .= '<div class="dv2row" data-row="' . $r . '">';
        foreach ($row as $n) {
            $isChoice = in_array($n['id'], $choices, true);
            $was = in_array($n['id'], $picked, true);
            $known = $isChoice || $was || $n['kind'] === 'boss';
            [$ico, $label] = $known ? DV2_KIND[$n['kind']] : ['❔', 'Unknown'];
            $size = $known && isset($n['tier']) && $n['kind'] !== 'boss' ? ' <small>' . DV2_SIZE[$n['tier']] . '</small>' : '';
            $cls = 'dv2node' . ($isChoice ? ' go' : '') . ($was ? ' was' : '') . (!$known ? ' unk' : '') . ($n['kind'] === 'boss' ? ' boss' : '');
            if ($isChoice) $o .= '<button type="submit" class="' . $cls . '" name="pick" value="' . e($n['id']) . '"><span class="dv2ico" aria-hidden="true">' . $ico . '</span>' . e($label) . $size . '</button>';
            else $o .= '<span class="' . $cls . '"' . ($known ? '' : ' role="img" aria-label="Not yet seen"') . '><span class="dv2ico" aria-hidden="true">' . $ico . '</span>' . ($known ? e($label) : '') . $size . '</span>';
        }
        $o .= '</div>';
    }
    return $o . '</form></div>';
}

/** The quick card (shrine / mole). */
function dv2_quick_html(array $sc): string
{
    $q = (string)$sc['st']['q'];
    return '<form method="post" class="dv2quick">' . csrf_field() . '<input type="hidden" name="do" value="quick">'
        . '<h3>' . ($q === 'shrine' ? '🕯️ A small shrine' : '⛏️ Mo the mole') . '</h3><p>' . ($q === 'shrine' ? 'Rest a moment. Your hurts mend.' : 'Mo has dug something up for you.') . '</p>'
        . '<button class="btn primary">' . ($q === 'shrine' ? 'Rest' : 'Take it') . '</button></form>';
}

/** The floor: like dm_view_html, with the objects of the floor as tokens, fog by the torch. */
function dv2_floor_html(array $u, array $exp, array $sc, bool $busy): string
{
    require_once __DIR__ . '/trek_art.php';
    $map = $sc['map'];
    $w = $map['w'];
    $h = $map['h'];
    $win = tm_window($sc['x'], $sc['y'], DM_VIEW, DM_VIEW);
    $land = (string)(exp_scene($exp)['land'] ?? 'forest');
    $uid = (int)$u['id'];
    $torch = (int)$sc['st']['f']['t'];
    $got = $sc['st']['f']['got'];
    $tokens = [];
    foreach ($map['t'] as $y => $row) {
        for ($x = 0; $x < $w; $x++) {
            $t = $row[$x];
            if (!tm_seen_get($sc['seen'], $w, $h, $x, $y) || ($x === $sc['x'] && $y === $sc['y'])) continue;
            $done = in_array($x . ',' . $y, $got, true);
            if (ctype_digit($t)) { if (!$done) $tokens[] = [$x, $y, '✨', 'gold', false]; continue; }
            if ($t === 'W') { $tokens[] = [$x, $y, '💧', 'gold', false]; continue; }
            if (!isset(DV2_TOKEN[$t])) continue;
            if ($t === 'D') { $tokens[] = [$x, $y, '🚪', 'gold', !empty($sc['st']['f']['key']), empty($sc['st']['f']['key'])]; continue; }
            if ($t === 'C' && dv2_boss_floor($sc)) { $tokens[] = [$x, $y, '💰', 'ember', $done, !$done && !dv2_boss_down($sc)]; continue; }
            [$ico, $ring] = DV2_TOKEN[$t];
            $tokens[] = [$x, $y, $ico, $ring, $done];
        }
    }
    $gate = dv2_gate($sc);
    $reach = tm_reach($map, $sc['x'], $sc['y'], $gate);
    $open = str_repeat('0', $w * $h);
    $lit = [];
    for ($y = 0; $y < $h; $y++) {
        for ($x = 0; $x < $w; $x++) {
            if (!tm_seen_get($sc['seen'], $w, $h, $x, $y)) continue;
            $t = tm_tile($map, $x, $y);
            if ($t === '#' || $t === ' ') continue;
            $ok = isset($reach[$y * $w + $x]);
            $live = dv2_live($sc, $x, $y);
            if (!$ok && $live && !($t === 'C' && dv2_boss_floor($sc) && !dv2_boss_down($sc))) {
                foreach ([[1, 0], [-1, 0], [0, 1], [0, -1]] as [$dx, $dy]) if (isset($reach[($y + $dy) * $w + $x + $dx]) && $x + $dx >= 0 && $x + $dx < $w) $ok = true;
            }
            if ($ok) { $lit[$y * $w + $x] = true; $open[$y * $w + $x] = $live ? '2' : '1'; }
        }
    }
    $walk = dm_walk_take($exp, $sc);
    $light = dv2_light($uid, $torch) + 1;
    $svg = tm_render_svg($map, $land, ['px' => $sc['x'], 'py' => $sc['y'], 'seen' => $sc['seen'], 'x0' => $win['x0'], 'y0' => $win['y0'], 'cols' => DM_VIEW, 'rows' => DM_VIEW,
        'light' => $light, 'tokens' => $tokens, 'walk' => $walk, 'me' => trek_art_me($u)]);
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
            $live = $seenIt && $t !== ' ' && $t !== '#' && dv2_live($sc, $x, $y);
            if (!$seenIt || $t === ' ') $cls .= ' fog';
            elseif ($t === '#') $cls .= ' wall';
            else {
                $cls .= $tap ? ' reach' : '';
                if ($live || $t === 'D') { $cls .= ' spot'; $label = ctype_digit($t) ? 'Something shiny' : (['F' => 'A creature', 'B' => 'The guardian', 'T' => 'A trap', 'C' => 'A chest', 'K' => 'A key', 'D' => 'A locked door', 'M' => 'A shrine', 'E' => 'The way down'][$t] ?? 'Something'); }
                if ($me && $live) $tap = !$busy;
                if ($t === 'S') $label = 'The way in';
            }
            if ($me) { $cls .= ' here'; $label = 'You are here'; }
            $dis = !$tap || ($me && !$live);
            $btn .= '<button type="submit" class="' . $cls . '" name="go" value="' . $x . ',' . $y . '"' . ($dis ? ' disabled' : '') . ($label !== '' ? ' aria-label="' . e($label) . '"' : ($tap ? ' aria-label="Walk here"' : ' tabindex="-1"')) . '></button>';
        }
    }
    $data = ' data-tile="' . TM_UNIT . '" data-cols="' . DM_VIEW . '" data-rows="' . DM_VIEW . '" data-x0="' . $win['x0'] . '" data-y0="' . $win['y0'] . '" data-px="' . $sc['x'] . '" data-py="' . $sc['y'] . '" data-mw="' . $w . '" data-mh="' . $h . '" data-open="' . $open . '"';
    if ($walk) $data .= ' data-walk="' . e(implode(';', array_map(fn($p) => $p[0] . ',' . $p[1], $walk['p']))) . '"';
    $legend = '<span>✨ Find</span><span>⚔️ Creature</span><span>🪤 Trap</span><span>🎁 Chest</span><span>🕳️ Way down</span>';
    return '<div class="tmwrap dv2wrap tm-' . e($land) . ($busy ? ' busy' : '') . '"><form method="post" class="tmform">' . csrf_field() . '<input type="hidden" name="do" value="go">'
        . '<div class="tilemap tm-cave" role="group" aria-label="Delve floor"' . $data . '><div class="tmview"><div class="tmstage">' . $svg
        . '<svg class="tmpv" viewBox="0 0 ' . (DM_VIEW * TM_UNIT) . ' ' . (DM_VIEW * TM_UNIT) . '" preserveAspectRatio="none" aria-hidden="true" focusable="false"></svg><span class="tmchip" hidden></span>'
        . '<div class="tmgrid">' . $btn . '</div></div></div></div></form><p class="tmlegend" aria-hidden="true">' . $legend . '</p></div>';
}
