<?php
declare(strict_types=1);
/**
 * Graphical navigation, phase 2d: the Trail as tile sections (setting gnav_tiles, needs gnav_on).
 *
 * The expeditions row stays the source of truth (fights, knock_out, logs, GPS "continue", perks and the double-start guard all keep working);
 * this is a new VIEW of the same walk. A walk that starts with the flag on gets a walk_scene row (map_key 'trail:...'). A walk with no such row
 * stays a timer walk: decided per walk, never in the middle of one. Sections = routes.steps clamped 1..6. Energy is paid ONCE, when stepping onto
 * section 1 (start_expedition, route_enter_cost); the Continue between sections is free. expeditions.step mirrors the finished sections,
 * steps_total = sections, arrive_at = start (time is not used).
 *
 * Flow: walk the section (tap a tile) -> reach the exit tile -> confirm (Continue / Turn back) -> an in-between event is rolled ONCE (saved
 * with a compare-and-swap on the scene state, so a double tap or a second tab cannot skip a section or roll twice) -> next section ... the last
 * confirm is "Head into <place>" (the existing arrive()). Fights, finds, problems and meets are the existing ones (next_step() / pick_creature() /
 * give_find()), shown by the existing encounter cards on adventure.php.
 */
require_once __DIR__ . '/delve_map.php';
require_once __DIR__ . '/tilemap.php';
require_once __DIR__ . '/here_schema.php';
require_once __DIR__ . '/trail_art.php';

const TRAIL_W = 11;
const TRAIL_H = 7;

/** Are tile walks on? (Both flags, and the walk_scene table.) */
function trail_on(): bool
{
    return gnav_on() && setting('gnav_tiles') === '1' && dm_table_ok();
}

/** Sections in a path: its steps, 1..6. */
function trail_sections(array $route): int
{
    return max(1, min(6, (int)($route['steps'] ?? 3)));
}

/** The energy the walk charges at the start when tiles are on, before staff and fireflies (those stay in start_expedition). */
function trail_base_cost(array $u, array $route): int
{
    if (($route['kind'] ?? 'road') === 'road' && calling_perk($u, 'free_walks') > 0) return 0;
    return max(0, (int)setting('gnav_enter_energy'));
}

/**
 * 2.6.41: a route is drawn from its a end to its b end. A walk that starts at the b end (scene state 'rev') goes through the same stretches
 * in the opposite order and enters each one where the a-to-b walk leaves it. $sec is the stretch as walked (0 = the first one you step onto);
 * the result is the stretch as drawn. Finds taken (trail_pickups) are kept by the stretch as drawn, so they stay gone both ways.
 */
function trail_phys_sec(int $routeId, int $sec, array $st): int
{
    if (empty($st['rev'])) return $sec;
    $n = trail_authored_count($routeId);
    if ($n < 1) $n = (int)($st['S'] ?? 1);
    return max(0, $n - 1 - $sec);
}

/** The seed of a stretch of a walk for trail_map_make(): 'route|uid|sx|stretch as drawn', plus '|r' when the walk goes from b to a. */
function trail_seed(int $routeId, int $uid, int $sx, int $sec, array $st): string
{
    return $routeId . '|' . $uid . '|' . $sx . '|' . trail_phys_sec($routeId, $sec, $st) . (empty($st['rev']) ? '' : '|r');
}

/** The same map with its entry (S) and its way on (9) swapped. A map without both is returned as it is. */
function trail_map_flip(array $map): array
{
    $en = $map['entry'] ?? null; $ex = $map['spots']['9'] ?? null;
    if (!$en || !$ex) return $map;
    $map['t'][$en[1]][$en[0]] = '9';
    $map['t'][$ex[1]][$ex[0]] = 'S';
    $map['entry'] = $ex;
    $map['spots']['9'] = $en;
    return $map;
}

/**
 * One section's map and tokens, from a seed (pure: same seed, same section). Entry 'S' on the left edge, exit '9' on the right edge, a winding
 * floor between, a few extra floor cells for width. Tokens: 0-1 finds ('F') on floor (v2.5.51: was 1-3), never next to the entry or exit. Fights are not tokens: they
 * are rolled while walking (trail_encounter_index); only an authored delve/lair route has a fixed 'E' (miniboss/boss) on its last section.
 * A seed 'routeId|uid|expId|section' of an AUTHORED route (includes/data/trail_maps.json) gives that route's hand-made section instead.
 * Returns [map, tokens [[x, y, kind]]].
 */
function trail_map_make(string $seed): array
{
    $sp = explode('|', $seed);
    if (count($sp) === 5 && $sp[4] === 'r') {   // 2.6.41: the stretch walked the other way (from the b end of the route): the same map and tokens, entry and exit swapped
        [$map, $tokens] = trail_map_make(implode('|', array_slice($sp, 0, 4)));
        return [trail_map_flip($map), $tokens];
    }
    if (count($sp) === 4 && ctype_digit($sp[0]) && ctype_digit($sp[3]) && ($art = trail_authored_section((int)$sp[0], (int)$sp[3]))) return trail_map_authored($art);
    $rng = tm_rng($seed);
    $g = array_fill(0, TRAIL_H, array_fill(0, TRAIL_W, '#'));
    $ys = $rng(1, TRAIL_H - 2);
    $ye = $rng(1, TRAIL_H - 2);
    $y = $ys;
    $g[$ys][0] = 'S';
    for ($x = 1; $x <= TRAIL_W - 2; $x++) {
        $g[$y][$x] = '.';
        if ($x < TRAIL_W - 2) {
            $r = $rng(1, 100);
            $toward = $ye <=> $y;
            $ny = $r <= 45 && $toward !== 0 ? $y + $toward : ($r <= 70 ? $y + ($rng(0, 1) ? 1 : -1) : $y);
            $ny = max(1, min(TRAIL_H - 2, $ny));
            while ($y !== $ny) { $y += $ny <=> $y; $g[$y][$x] = '.'; }
        }
    }
    while ($y !== $ye) { $y += $ye <=> $y; $g[$y][TRAIL_W - 2] = '.'; }
    $g[$ye][TRAIL_W - 1] = '9';
    for ($i = 0, $n = $rng(6, 11); $i < $n; $i++) {   // width: floor next to floor
        $x = $rng(1, TRAIL_W - 2);
        $yy = $rng(1, TRAIL_H - 2);
        if ($g[$yy][$x] !== '#') continue;
        foreach ([[1, 0], [-1, 0], [0, 1], [0, -1]] as [$dx, $dy]) {
            if (($g[$yy + $dy][$x + $dx] ?? '#') === '.') { $g[$yy][$x] = $rng(0, 3) === 0 ? ',' : '.'; break; }
        }
    }
    $floor = [];
    for ($yy = 0; $yy < TRAIL_H; $yy++) for ($x = 3; $x <= TRAIL_W - 4; $x++) if ($g[$yy][$x] === '.' || $g[$yy][$x] === ',') $floor[] = [$x, $yy];
    $tokens = [];
    $want = array_fill(0, $rng(0, 1), 'F');
    foreach ($want as $k) {
        if (!$floor) break;
        $i = $rng(0, count($floor) - 1);
        [$tx, $ty] = array_splice($floor, $i, 1)[0];
        $tokens[] = [$tx, $ty, $k];
    }
    return [tm_parse(array_map(fn($r) => implode('', $r), $g)), $tokens];
}

/** v2.5.93: picture URLs of the Puzzle Pals the gnome has taken along (up to 3, in the order taken); [] when take-along is off, a guest, or a pal has no art. */
function trail_pal_urls(array $u): array
{
    if (!empty($u['guest']) || setting('ppal_party') !== '1') return [];
    require_once __DIR__ . '/puzzle_pals.php';
    $o = [];
    foreach (ppal_equipped($u) as $e) {
        $url = ppal_travel_url((string)$e['pal']['key']);
        if ($url !== '' && count($o) < 3) $o[] = $url;
    }
    return $o;
}

/** 2.7.06 escorts: the walking picture of a villager by name ("Name" or "Name@village"): their 2.5D side strip, else their idle sprite. '' when they have none. */
function trail_escort_pic(string $who): string
{
    if ($who === '') return '';
    try {
        require_once __DIR__ . '/trail_sights.php';
        $nm = trail_sight_split_who($who)[0];
        $f = q_one('SELECT * FROM stop_folk WHERE name = ? ORDER BY id LIMIT 1', [$nm]);
        if (!$f) return '';
        if (function_exists('npc25_strip') || is_file(__DIR__ . '/npc25.php')) { require_once __DIR__ . '/npc25.php'; $sp = npc25_strip((string)$f['species'], 'side'); if ($sp) return (string)$sp[0]; }
        $rel = function_exists('stop_folk_art') ? stop_folk_art($f, 'sprite') : '';
        return $rel !== '' ? url($rel) : '';
    } catch (Throwable $e) { return ''; }
}

/**
 * 2.6.30: finds (✨ 'F') you took on a stretch stay gone for a while: trail_pickup_tenths tenths of a game day (default 5.5 days; real days with the
 * game clock off). Tokens [[x, y, kind, done]] come back with the first n finds of that stretch already done. Pure read except the table.
 */
function trail_pickup_apply(int $uid, int $routeId, int $sec, array $tokens): array
{
    try {
        $v = setting('trail_pickup_tenths');
        $tenths = $v === '' ? 55 : max(0, (int)$v);
        if ($tenths <= 0) return $tokens;
        $r = q_one('SELECT * FROM trail_pickups WHERE user_id = ? AND route_id = ? AND sec = ? ORDER BY id DESC LIMIT 1', [$uid, $routeId, $sec]);
        if (!$r) return $tokens;
        $u = q_one('SELECT * FROM users WHERE id = ?', [$uid]);
        $gone = $u && gclock_on() && $r['got_tick'] !== null
            ? gclock_state($u)['tick'] - (int)$r['got_tick'] < (int)round($tenths * 144)
            : time() - (int)$r['got_at'] < (int)round($tenths * 8640);
        if (!$gone) { q('DELETE FROM trail_pickups WHERE user_id = ? AND route_id = ? AND sec = ?', [$uid, $routeId, $sec]); return $tokens; }
        $n = (int)$r['n'];
        foreach ($tokens as $i => $t) if ($t[2] === 'F' && $n > 0) { $tokens[$i][3] = 1; $n--; }
    } catch (Throwable $e) { /* table missing before Upgrade database: finds come back as before */ }
    return $tokens;
}

/** A find was taken on this stretch: remember it (one more for the stretch, clock restarts). */
function trail_pickup_note(int $uid, int $routeId, int $sec): void
{
    try {
        $old = q_one('SELECT n FROM trail_pickups WHERE user_id = ? AND route_id = ? AND sec = ?', [$uid, $routeId, $sec]);
        q('DELETE FROM trail_pickups WHERE user_id = ? AND route_id = ? AND sec = ?', [$uid, $routeId, $sec]);
        $u = q_one('SELECT * FROM users WHERE id = ?', [$uid]);
        db_insert('trail_pickups', ['user_id' => $uid, 'route_id' => $routeId, 'sec' => $sec, 'n' => 1 + (int)($old['n'] ?? 0), 'got_at' => time(),
            'got_tick' => $u && gclock_on() ? gclock_state($u)['tick'] : null]);
    } catch (Throwable $e) {}
}

/** Start the scene of a new walk: section 1, the gnome at the entry. Never breaks the start if it fails. Returns true when made. */
function trail_scene_make(int $uid, int $expId, array $route, bool $rev = false): bool
{
    try {
        dm_scene_purge($uid);
        $S = trail_sections($route);
        $st = ['sec' => 0, 'S' => $S, 'sx' => $expId, 'phase' => 'section'];
        if ($rev) $st['rev'] = 1;   // 2.6.41: the walk starts at the route's b end: last stretch first, each entered at its far end
        [$map, $tokens] = trail_map_make(trail_seed((int)$route['id'], $uid, $expId, 0, $st));   // 'sx' keeps the seed stable if the walk is resumed under a new expedition id
        $seen = tm_seen_new($map['w'], $map['h']);
        tm_reveal($seen, $map['w'], $map['h'], $map['entry'][0], $map['entry'][1], 20);
        $st['tokens'] = trail_pickup_apply($uid, (int)$route['id'], trail_phys_sec((int)$route['id'], 0, $st), array_map(fn($t) => [$t[0], $t[1], $t[2], 0], $tokens));
        require_once __DIR__ . '/trail_sights.php'; [$sec4, $sec4Lines] = sights4_start_apply($uid, $expId, (int)$route['id'], $map, $st);   // Sights fourth pass: a named stretch's find / fog (sec=), the weather's fog
        db_insert('walk_scene', ['user_id' => $uid, 'exp_id' => $expId, 'map_key' => 'trail:' . (int)$route['id'], 'x' => $map['entry'][0], 'y' => $map['entry'][1], 'seen' => $seen, 'state' => json_encode($st), 'updated_at' => now()]);
        sights4_start_done($uid, $expId, $sec4, $sec4Lines);
        return true;
    } catch (Throwable $e) {
        error_log('trail_scene_make: ' . $e->getMessage());
        return false;
    }
}

/** The tile scene of an active walk, or null (a timer walk). */
function trail_scene(array $exp): ?array
{
    if (($exp['kind'] ?? 'walk') !== 'walk' || ($exp['status'] ?? '') !== 'active' || !dm_table_ok()) return null;
    $row = q_one('SELECT * FROM walk_scene WHERE exp_id = ? AND user_id = ?', [(int)$exp['id'], (int)$exp['user_id']]);
    if (!$row || !str_starts_with((string)$row['map_key'], 'trail:')) return null;
    $st = json_decode((string)$row['state'], true);
    if (!is_array($st) || !isset($st['sec'], $st['S'], $st['phase'])) return null;
    [$map] = trail_map_make(trail_seed((int)substr((string)$row['map_key'], 6), (int)$exp['user_id'], (int)($st['sx'] ?? $exp['id']), (int)$st['sec'], $st));
    return ['row' => $row, 'old' => (string)$row['state'], 'map' => $map, 'x' => (int)$row['x'], 'y' => (int)$row['y'], 'seen' => (string)$row['seen'], 'st' => $st];
}

/** Save a scene change only if nobody changed it meanwhile (a double tap, a second tab). True = this call won. */
function trail_save(array $sc): bool
{
    return q('UPDATE walk_scene SET x = ?, y = ?, seen = ?, state = ?, updated_at = ? WHERE id = ? AND state = ?',
        [$sc['x'], $sc['y'], $sc['seen'], json_encode($sc['st']), now(), $sc['row']['id'], $sc['old']])->rowCount() === 1;
}

/** The token on a tile (index) or -1. */
function trail_token_at(array $sc, int $x, int $y): int
{
    foreach ($sc['st']['tokens'] as $i => $t) if ((int)$t[0] === $x && (int)$t[1] === $y) return $i;
    return -1;
}

/** Closes tiles: a token that is not done yet is only walked ONTO as the goal (a fight or find waits there), never through. */
function trail_gate(array $sc, ?int $gx = null, ?int $gy = null, array $shut = []): callable
{
    return function (int $x, int $y, string $t) use ($sc, $gx, $gy, $shut): bool {
        if (isset($shut[$x . ',' . $y])) return false;   // v2.7: a tool gate the gnome cannot pass yet (trail_gates_closed)
        $i = trail_token_at($sc, $x, $y);
        if ($i < 0 || (int)$sc['st']['tokens'][$i][3] === 1) return true;
        return $x === $gx && $y === $gy;
    };
}

/**
 * A fixed boss: the creature for the E spot of a lair (a boss) or delve (a miniboss, a large creature), else any creature that fits.
 * Easy roads never meet one (pick_creature's cap rule).
 */
function trail_pick_fixed(array $scene, int $cap, string $boss): ?array
{
    $land = (string)$scene['land'];
    $level = (int)$scene['level'];
    require_once __DIR__ . '/pfdeck.php';
    $rc = scene_region_code($scene);   // 2.7.01: the variants of a creature turn up only in their regions
    if ($cap > 0 || $boss === '') return pick_creature($land, $level, false, false, $cap, $rc);
    $want = $boss === 'boss' ? 'boss' : 'large';
    $pool = array_values(array_filter(road_rows('creatures'), fn($c) => ($c['landscapes'] === 'any' || in_array($land, array_map('trim', explode(',', (string)$c['landscapes'])), true))
        && $c['size'] === $want && (int)$c['level'] <= $level + ($want === 'boss' ? 8 : 4) && pfd_creature_in_region((string)$c['slug'], $rc)));
    if ($pool) {
        $b = $pool[array_rand($pool)];
        return (int)$b['level'] < $level ? scale_creature($b, $level) : $b;
    }
    return pick_creature($land, $level, $boss === 'boss', false, $cap, $rc);
}

/** v2.6.40: the 'extra_minibosses' entry of an authored section standing on this tile, or null. */
function trail_extra_mini(array $art, int $x, int $y): ?array
{
    foreach ((array)($art['extra_minibosses'] ?? []) as $mb) if (is_array($mb) && (int)($mb['x'] ?? -1) === $x && (int)($mb['y'] ?? -1) === $y && !empty($mb['creature'])) return $mb;
    return null;
}

/** v2.6.40: the creature row of an extra mini-boss ($mb['creature'] = slug, $mb['level']), raised to its level, or null when the creature is missing. */
function trail_extra_mini_creature(array $mb): ?array
{
    foreach (road_rows('creatures') as $c) if ((string)($c['slug'] ?? '') === (string)$mb['creature']) {
        return (int)$c['level'] < (int)($mb['level'] ?? 0) ? scale_creature($c, (int)$mb['level']) : $c;
    }
    return null;
}

/**
 * What waits on a tile: a fight (a random encounter 'R' rolled on the walk, or the fixed boss spot 'E'; a find when no creature fits here)
 * or a find ('F'). Random fights never bring a boss.
 */
function trail_token_event(array $u, array &$exp, string $kind, string $boss = '', ?array $mini = null): void
{
    $scene = exp_scene($exp);
    if ($kind === 'E' || $kind === 'R' || $kind === 'M') {
        $cap = exp_easy_cap($u, $exp);
        $c = $kind === 'E' ? trail_pick_fixed($scene, $cap, $boss)
            : ($kind === 'M' ? ($cap > 0 || !$mini ? null : trail_extra_mini_creature($mini))   // an easy road never meets it: a find instead
            : learner_creature($u, pick_creature($scene['land'], $scene['level'], false, false, $cap, scene_region_code($scene)), (string)$scene['land'], (int)$scene['level'], scene_region_code($scene)));   // 2.7.01: a learner's creature (random fights only)
        if ($c) {
            $exp['encounter'] = json_encode(['type' => 'creature', 'id' => (int)$c['id'], 'lv' => !empty($c['_scaled']) ? (int)$c['level'] : 0, 'sp' => (int)($c['_pct'] ?? 100), 'hpp' => (int)($c['_hpp'] ?? 100),
                'hp' => (int)$c['hp'], 'max' => (int)$c['hp'], 'bark' => 0, 'poison' => 0, 'used' => false]);
            exp_log($exp, '⚔️ ' . (preg_match('/^[AEIOU]/i', $c['name']) ? 'An ' : 'A ') . $c['name'] . ' blocks your way!');
            return;
        }
    }
    $exp['encounter'] = null;
    exp_log($exp, find_popup(give_find($u, $scene)));
    rest_heal($exp);
}

/**
 * The event between two sections, rolled once: 40% nothing but the view, otherwise whatever a space of the old walk could bring
 * (a fight, a problem, a choice card, somebody on the road, a find). Reuses next_step() so every card, reward and rule is the existing one.
 */
function trail_roll_event(array $u, array &$exp): void
{
    if (random_int(1, 100) <= 40) {
        $scene = exp_scene($exp);
        if ($line = road_line($scene, ['seed' => road_line_seed($exp, (int)$exp['step'] + 1)])) exp_log($exp, '🍃 ' . $line);
        return;
    }
    $keep = (int)$exp['step'];
    next_step($u, $exp);
    $exp['step'] = $keep;
}

/** What to tell a gnome whose walk crosses a shut tool gate: the first shut gate on the path, or null when the path crosses none. Pure. */
function trail_gate_message(array $shut, array $path): ?string
{
    foreach ($path as [$x, $y]) if (isset($shut[$x . ',' . $y])) {
        $g = $shut[$x . ',' . $y];
        return 'Blocked: ' . $g['label'] . '. Bring a ' . ($g['tool_name'] ?? 'better tool') . ' or a better one.';
    }
    return null;
}

/** A tap on a tile of the section. [ok, message]. The scene is saved with a compare-and-swap, so a second tab cannot repeat it. */
function trail_go(array $u, array &$exp, int $tx, int $ty): array
{
    $sc = trail_scene($exp);
    if (!$sc) return [false, 'There is no tile map for this walk.'];
    if ($exp['encounter']) return [false, 'Deal with what is in front of you first.'];
    if ($sc['st']['phase'] !== 'section') return [false, 'Choose Continue or Turn back first.'];
    require_once __DIR__ . '/road_kinds.php';
    if (rk_toll_open((int)substr((string)$sc['row']['map_key'], 6), $sc['st'])) return [false, '🪙 A toll road: pay the toll or take the old road first.'];   // 2.7.00
    $map = $sc['map'];
    $t = tm_tile($map, $tx, $ty);
    if ($t === '#' || $t === ' ') return [false, 'That is solid rock.'];
    if ($sc['x'] === $tx && $sc['y'] === $ty) {
        if ($t !== '9') return [false, 'You are already here.'];
        $sc['st']['phase'] = 'confirm';   // tapping the exit you stand on asks about going on again (after "Not yet" or a walk back)
        return trail_save($sc) ? [true, ''] : [false, 'That already happened. Look again.'];
    }
    $shut = function_exists('tool_tier') && !empty($map['art']['gates']) ? trail_gates_closed($map['art'], fn(string $type): int => tool_tier((int)$u['id'], $type)) : [];
    $path = tm_path($map, $sc['x'], $sc['y'], $tx, $ty, trail_gate($sc, $tx, $ty, $shut));
    if (!$path && $shut && ($open = tm_path($map, $sc['x'], $sc['y'], $tx, $ty, trail_gate($sc, $tx, $ty))) && ($why = trail_gate_message($shut, $open)) !== null) return [false, $why];   // only a tool gate is in the way: say which
    if (!$path) {   // v2.6.40: a fixed fight (E, M) sits in the only way: say so instead of 'no way'
        $easyMini = exp_easy_cap($u, $exp) > 0;   // an easy road turns an extra mini-boss into a find, so it blocks nothing
        $sc2 = $sc; foreach ($sc2['st']['tokens'] as $ti => $tk) if ($tk[2] === 'E' || ($tk[2] === 'M' && !$easyMini)) $sc2['st']['tokens'][$ti][3] = 1;
        if (tm_path($map, $sc['x'], $sc['y'], $tx, $ty, trail_gate($sc2, $tx, $ty, $shut))) return [false, '⚔️ A fight waits in the way. Walk to the ⚔️ spot first.'];
        return [false, 'There is no way there from here.'];
    }
    [$stop, $sc['st']['quiet'], $sc['st']['fights']] = trail_encounter_index($map, $path, (int)($sc['st']['quiet'] ?? 0), (int)($sc['st']['fights'] ?? 0), null, (string)($sc['st']['stance'] ?? ''), rk_enc_base($sc['st']));   // 2.7.00: a paid toll road halves the chance
    if ($stop !== null) {   // something rustles: the walk stops on that tile and a random fight starts
        $path = array_slice($path, 0, $stop + 1);
        [$tx, $ty] = end($path);
        $t = tm_tile($map, $tx, $ty);
    }
    $walked = array_merge([[$sc['x'], $sc['y']]], $path);
    $sc['x'] = $tx;
    $sc['y'] = $ty;
    $i = trail_token_at($sc, $tx, $ty);
    $fire = $stop !== null ? 'R' : null;
    if ($stop === null && $i >= 0 && (int)$sc['st']['tokens'][$i][3] === 0) { $sc['st']['tokens'][$i][3] = 1; $fire = (string)$sc['st']['tokens'][$i][2]; }
    if ($t === '9') $sc['st']['phase'] = 'confirm';
    if (!trail_save($sc)) return [false, 'That already happened. Look again.'];
    if ($fire === 'F') trail_pickup_note((int)$u['id'], (int)substr((string)$sc['row']['map_key'], 6), trail_phys_sec((int)substr((string)$sc['row']['map_key'], 6), (int)$sc['st']['sec'], $sc['st']));
    if ($fire !== null) trail_token_event($u, $exp, $fire, (string)($map['art']['boss'] ?? ''), $fire === 'M' ? trail_extra_mini($map['art'] ?? [], $tx, $ty) : null);
    $_SESSION['dm_walk'] = ['e' => (int)$exp['id'], 't' => time(), 'p' => $walked];
    return [true, ''];
}

/**
 * "Walk to the way on": one tap walks the rest of this stretch toward the exit (the way on) using the same trail_go() a tap on the exit tile uses, so every
 * rule stays: a random fight or a fixed fight (E, M) stops the walk on its tile and starts it, a toll road still asks first, a tool gate or solid rock still blocks.
 * When a fixed fight sits in the only way, the walk goes to that fight (nearest first); finds and sights off the path are never visited (the map stays optional). Free.
 * Needs a tile walk (trail_scene), so it is inside the gnav_tiles gating like everything here. [ok, message]
 */
function trail_walk_on(array $u, array &$exp): array
{
    $sc = trail_scene($exp);
    if (!$sc) return [false, 'There is no tile map for this walk.'];
    if ($exp['encounter']) return [false, 'Deal with what is in front of you first.'];
    if (($sc['st']['phase'] ?? '') !== 'section') return [false, 'Choose Continue or Turn back first.'];
    $ex = $sc['map']['spots']['9'] ?? null;
    if (!$ex) return [false, 'The way on is not on this map.'];
    [$ok, $msg] = trail_go($u, $exp, (int)$ex[0], (int)$ex[1]);
    if ($ok) return [true, ''];
    if (!str_contains($msg, 'A fight waits')) return [false, $msg];
    $fights = [];
    foreach ($sc['st']['tokens'] as [$tx, $ty, $k, $done]) if (in_array($k, ['E', 'M'], true) && (int)$done === 0) $fights[] = [abs($tx - $sc['x']) + abs($ty - $sc['y']), (int)$tx, (int)$ty];
    sort($fights);
    foreach ($fights as [, $fx, $fy]) {
        [$ok2] = trail_go($u, $exp, $fx, $fy);
        if ($ok2) return [true, ''];
    }
    return [false, $msg];
}

/** 2.7.00: the toll road's question at the first stretch: pay (safer, faster) or take the old road. Free of energy. [ok, message] */
function trail_toll(array $u, array &$exp, bool $pay): array
{
    $sc = trail_scene($exp);
    if (!$sc) return [false, 'Not on a tile walk.'];
    if ($exp['encounter']) return [false, 'Deal with what is in front of you first.'];
    require_once __DIR__ . '/road_kinds.php';
    [$ok, $msg] = rk_toll_set($u, $sc, $pay);
    if (!$ok) return [false, $msg];
    if (!trail_save($sc)) return [false, 'That already happened. Look again.'];   // the compare-and-swap: a double tap or a second tab lands here and pays nothing
    return [true, rk_toll_apply($u, $pay, (int)$sc['st']['S'])];
}

/** Sneak or Hunt (or back to a normal walk): the stance for the rest of this walk. Free. [ok, message] */
function trail_stance(array $u, array &$exp, string $mode): array
{
    $sc = trail_scene($exp);
    if (!$sc) return [false, 'Not on a tile walk.'];
    if ($exp['encounter']) return [false, 'Deal with what is in front of you first.'];
    if (!in_array($mode, ['sneak', 'hunt', ''], true)) return [false, 'Unknown way of walking.'];
    if ((string)($sc['st']['stance'] ?? '') === $mode) $mode = '';   // tapping it again goes back to a normal walk
    $sc['st']['stance'] = $mode;
    if (!trail_save($sc)) return [false, 'That already happened. Look again.'];
    return [true, ['' => 'You walk as usual.', 'sneak' => '🤫 You sneak: fewer fights.', 'hunt' => '🏹 You hunt: more fights.'][$mode]];
}

/** Continue past the exit tile (free): the event is rolled once, the next section starts. [ok, message] */
function trail_next(array $u, array &$exp): array
{
    $sc = trail_scene($exp);
    if (!$sc || $sc['st']['phase'] !== 'confirm') return [false, 'Nothing to continue from.'];
    if ($exp['encounter']) return [false, 'Deal with what is in front of you first.'];
    $sec = (int)$sc['st']['sec'];
    if ($sec + 1 >= (int)$sc['st']['S']) return [false, 'That was the last section. Head into the place.'];
    $nsec = $sec + 1;
    $rid = (int)substr((string)$sc['row']['map_key'], 6);
    [$map, $tokens] = trail_map_make(trail_seed($rid, (int)$exp['user_id'], (int)($sc['st']['sx'] ?? $exp['id']), $nsec, $sc['st']));
    $seen = tm_seen_new($map['w'], $map['h']);
    tm_reveal($seen, $map['w'], $map['h'], $map['entry'][0], $map['entry'][1], 20);
    $new = $sc;
    $hist = (array)($sc['st']['hist'] ?? []); $hist[$sec] = $sc['st']['tokens'];   // what was found and fought in the stretch you leave stays so if you walk back
    $revisit = isset($hist[$nsec]);
    $new['st'] = ['sec' => $nsec, 'S' => (int)$sc['st']['S'], 'sx' => (int)($sc['st']['sx'] ?? $exp['id']), 'phase' => 'section', 'stance' => (string)($sc['st']['stance'] ?? ''), 'hist' => $hist,
        'tokens' => $revisit ? $hist[$nsec] : trail_pickup_apply((int)$exp['user_id'], $rid, trail_phys_sec($rid, $nsec, $sc['st']), array_map(fn($t) => [$t[0], $t[1], $t[2], 0], $tokens))];
    if (!empty($sc['st']['rev'])) $new['st']['rev'] = 1;
    if (isset($sc['st']['toll'])) $new['st']['toll'] = $sc['st']['toll'];   // 2.7.00: the toll answer stays for the whole walk
    $new['x'] = $map['entry'][0];
    $new['y'] = $map['entry'][1];
    $new['seen'] = $seen;
    require_once __DIR__ . '/trail_sights.php';
    $sec4 = $revisit ? [] : sights4_sec_pending((int)$exp['user_id'], $rid, trail_phys_sec($rid, $nsec, $sc['st']));   // Sights fourth pass: effects aimed at this named stretch (sec=) join the pending nxt= ones
    if ($sec4) $sc['st']['nxt'] = array_values(array_merge((array)($sc['st']['nxt'] ?? []), array_column($sec4, 1)));
    $nxt = sights3a_nxt_prepare($sc, $new, $map, $revisit);   // 2.7.08 third pass A: a Sight's nxt= effects are used up on this stretch (and the escort walks on)
    if (!$revisit && !in_array('fog', $nxt, true) && sights4_weather_fog($exp) && sights4_fog_set($new['st'])) $nxt[] = 'fog';   // fourth pass: foggy weather (setting trail_fog_weather)
    if (!trail_save($new)) return [false, 'You already went on.'];   // the other tab won: no second event
    sights4_sec_clear((int)$exp['user_id'], $sec4);
    $exp['step'] = $nsec;
    $calm = sights3a_nxt_finish($u, $exp, $nxt);   // nxt=calm: no surprise at this stretch's door
    if (!$revisit && !$calm) trail_roll_event($u, $exp);   // a stretch you have walked before has no new surprise at its door
    $exp['step'] = $nsec;
    return [true, ''];
}

/** Walk back the way you came: from where a stretch begins (not the first) to the end of the one before it. Free. Fights and finds you did stay done. [ok, message] */
function trail_prev(array $u, array &$exp): array
{
    $sc = trail_scene($exp);
    if (!$sc) return [false, 'There is no tile map for this walk.'];
    if ($exp['encounter']) return [false, 'Deal with what is in front of you first.'];
    $st = $sc['st']; $sec = (int)$st['sec'];
    if ($st['phase'] !== 'section' || $sec < 1) return [false, 'There is no way back from here.'];
    if ($sc['x'] !== (int)$sc['map']['entry'][0] || $sc['y'] !== (int)$sc['map']['entry'][1]) return [false, 'Walk to where this stretch begins first.'];
    $psec = $sec - 1;
    [$map, $tokens] = trail_map_make(trail_seed((int)substr((string)$sc['row']['map_key'], 6), (int)$exp['user_id'], (int)($st['sx'] ?? $exp['id']), $psec, $st));
    $hist = (array)($st['hist'] ?? []); $hist[$sec] = $st['tokens'];
    $ptokens = $hist[$psec] ?? array_map(fn($t) => [$t[0], $t[1], $t[2], 1], $tokens);   // no record (an old walk): treat it as done, no fights again
    [$ex, $ey] = $map['spots']['9'];
    $seen = tm_seen_new($map['w'], $map['h']);
    tm_reveal($seen, $map['w'], $map['h'], $ex, $ey, 20);
    $new = $sc;
    $new['st'] = ['sec' => $psec, 'S' => (int)$st['S'], 'sx' => (int)($st['sx'] ?? $exp['id']), 'phase' => 'section', 'stance' => (string)($st['stance'] ?? ''), 'hist' => $hist, 'tokens' => $ptokens];
    if (!empty($st['rev'])) $new['st']['rev'] = 1;
    if (isset($st['toll'])) $new['st']['toll'] = $st['toll'];
    foreach (['nxt', 'escort', 'fog', 'lit'] as $keep) if (!empty($st[$keep])) $new['st'][$keep] = $st[$keep];   // 2.7.08 third pass A: a pending nxt= effect and the escort stay when you walk back
    $new['st']['phase'] = 'confirm';   // you stand on that stretch's exit: Continue is offered at once (or "Not yet" to look around)
    $new['x'] = $ex; $new['y'] = $ey; $new['seen'] = $seen;
    if (!trail_save($new)) return [false, 'You already moved. Look again.'];
    $exp['step'] = $psec;
    exp_log($exp, '↩️ You walk back along the Trail.');
    return [true, ''];
}

/** "Not yet": from the confirm on an exit tile, stay in this stretch and walk about again. Free. [ok, message] */
function trail_stay(array $u, array &$exp): array
{
    $sc = trail_scene($exp);
    if (!$sc || $sc['st']['phase'] !== 'confirm') return [false, 'Nothing to step back from.'];
    if ($exp['encounter']) return [false, 'Deal with what is in front of you first.'];
    $sc['st']['phase'] = 'section';
    if (!trail_save($sc)) return [false, 'That already happened. Look again.'];
    return [true, ''];
}

/** Turn back: free. The walk ends where it began; everything found stays found. */
function trail_back(array $u, array &$exp): array
{
    $exp['status'] = 'done';
    $exp['encounter'] = null;
    exp_log($exp, '↩️ You turn back along the thread.');
    dm_scene_drop((int)$exp['id']);
    return [true, 'You turned back. No energy lost, nothing lost.'];
}

/** The "arrive" step: only from the confirm of the last section. [ok, message] (the caller then runs arrive()). */
function trail_can_arrive(array $exp): bool
{
    $sc = trail_scene($exp);
    return $sc && $sc['st']['phase'] === 'confirm' && (int)$sc['st']['sec'] + 1 >= (int)$sc['st']['S'] && !$exp['encounter'];
}

/** The slim strip over the tile map: Trail to <place>, Section X of Y, energy chip, HP bar. Centered (class trailui), no inline style. */
function trail_strip_html(array $u, array $exp, array $sc): string
{
    require_once __DIR__ . '/health.php';
    $to = q_one('SELECT name FROM locations WHERE id = ?', [(int)$exp['to_id']]);
    $en = (int)$u['energy'];
    $o = '<div class="trailstrip trailui" role="status"><b>🛣️ Trail to ' . e((string)($to['name'] ?? 'the next place')) . '</b>'
        . '<span class="tsec">Section ' . ((int)$sc['st']['sec'] + 1) . ' of ' . (int)$sc['st']['S'] . '</span>'
        . '<span class="tchip" title="Energy">⚡ ' . $en . '/' . max_energy($u) . '</span>';
    if (hp_on()) {
        [$hp, $max] = hp_display($u);
        $o .= '<span class="thp" title="Health">❤️ ' . hp_bar_html($hp, $max, 'hpbar-s') . ' ' . $hp . '/' . $max . '</span>';
    }
    require_once __DIR__ . '/road_kinds.php';   // 2.7.00 road kinds
    $rid = (int)substr((string)($sc['row']['map_key'] ?? ''), 6); $rk = rk_of($rid);
    if ($rk) $o .= '<span class="tkind" title="' . e(rk_text($rk['kind'], $rk['tier'])) . '">' . e(rk_label($rk)) . '</span>';
    $o .= '</div>';
    if (rk_toll_open($rid, (array)$sc['st']) && empty($exp['encounter'])) {
        $o .= '<div class="trailui tollcard" role="group" aria-label="Toll road"><p>' . e(rk_text('toll')) . '</p>'
            . '<form method="post" class="inline">' . csrf_field() . '<input type="hidden" name="do" value="trail_toll"><input type="hidden" name="pay" value="1"><button class="btn primary">🪙 Pay ' . RK_TOLL_PETALS . ' Petals</button></form>'
            . '<form method="post" class="inline">' . csrf_field() . '<input type="hidden" name="do" value="trail_toll"><input type="hidden" name="pay" value="0"><button class="btn alt">Take the old road</button></form></div>';
    }
    require_once __DIR__ . '/trail_camps.php';
    return $o . tc_card_html($u, $exp, $sc);   // 2.7.00: the camp card while you stand on the camp tile
}

/**
 * 2.7.01: the road-kind marker of this stretch, [x, y, kind], or null (a plain road, or a kind that is not met on this stretch: rk_on_stretch). A side path (routes.kind
 * 'side') with no road kind gets kind 'side' on its first stretch walked: the signpost marker (trail_road_mark_name). It stands on the first floor
 * tile round the way in (nearest first, fixed order) that has no token, camp, gate or way on, so it does not move while the gnome walks. Pure but for the road-kind list.
 */
function trail_road_mark(array $sc): ?array
{
    require_once __DIR__ . '/road_kinds.php';
    $rid = (int)substr((string)($sc['row']['map_key'] ?? ''), 6);
    $rk = rk_of($rid);
    if (!$rk && (int)$sc['st']['sec'] === 0 && (string)q_val('SELECT kind FROM routes WHERE id = ?', [$rid]) === 'side') $rk = ['kind' => 'side'];
    if (!$rk || ($rk['kind'] !== 'side' && !rk_on_stretch($rk['kind'], (int)$sc['st']['sec']))) return null;
    $map = $sc['map'];
    [$enx, $eny] = $map['entry'];
    $taken = [];
    foreach ((array)$sc['st']['tokens'] as $t) $taken[(int)$t[0] . ',' . (int)$t[1]] = true;
    if ($ex = $map['spots']['9'] ?? null) $taken[$ex[0] . ',' . $ex[1]] = true;
    require_once __DIR__ . '/trail_camps.php';
    if ($cs = tc_spot((array)($map['art'] ?? []))) $taken[$cs[0] . ',' . $cs[1]] = true;
    foreach ((array)($map['art']['gates'] ?? []) as $g) foreach ((array)($g['tiles'] ?? []) as $gt) $taken[(int)$gt[0] . ',' . (int)$gt[1]] = true;
    $cand = [];
    for ($dy = -3; $dy <= 3; $dy++) for ($dx = -3; $dx <= 3; $dx++) if ($dx || $dy) $cand[] = [abs($dx) + abs($dy), max(abs($dx), abs($dy)), $dy, $dx];
    sort($cand);
    foreach ($cand as [, , $dy, $dx]) {
        $x = $enx + $dx; $y = $eny + $dy;
        if (!isset($taken[$x . ',' . $y]) && in_array(tm_tile($map, $x, $y), ['.', ','], true)) return [$x, $y, $rk['kind']];
    }
    return null;
}

/** 2.7.01: [marker name, emoji, tile label] of a trail_road_mark() kind: a road kind is its own marker, a side path ('side') the signpost. */
function trail_road_mark_name(string $kind, int $rid): array
{
    if ($kind === 'side') return ['signpost', '🪧', 'A side path, off the road'];
    return [$kind, RK_ICON[$kind] ?? '❔', (string)preg_replace('/^\S+\s/u', '', rk_label(rk_of($rid)))];
}

/** The tile map block for adventure.php: the section picture with its buttons (same markup and script as the delve map), then the confirm card. */
function trail_view_html(array $u, array $exp, array $sc, bool $busy, bool $fightOver = false, ?array $fightExp = null): string
{
    require_once __DIR__ . '/trek_art.php';
    $map = $sc['map'];
    $w = $map['w']; $h = $map['h'];
    $win = tm_window_clamped($sc['x'], $sc['y'], DM_VIEW, DM_VIEW, (int)$w, (int)$h);
    $land = (string)(exp_scene($exp)['land'] ?? 'forest');
    $phase = (string)$sc['st']['phase'];
    require_once __DIR__ . '/trail_sights.php'; $foggy = sights4_fog_on($sc['st']); $sc = sights4_fog_view($sc);   // Sights fourth pass: in fog a find shows only when the gnome is next to it
    $tokens = [];
    $easyMini = exp_easy_cap($u, $exp) > 0;   // an easy road never meets an extra mini-boss (it gives a find), so draw it as a find
    foreach ($sc['st']['tokens'] as [$tx, $ty, $k, $done]) {
        if ($tx === $sc['x'] && $ty === $sc['y']) continue;
        $fight = $k === 'E' || ($k === 'M' && !$easyMini);
        $tokens[] = [$tx, $ty, $fight ? '⚔️' : (!$done && sights5_is_marked($sc['st'], (int)$tx, (int)$ty) ? '📍' : '✨'), $fight ? 'ember' : 'gold', (bool)$done];   // fifth pass: a find a map scrap marked wears a pin
    }
    [$ex, $ey] = $map['spots']['9'];
    $dest = null;   // 2.7.01: the last stretch's way on shows the marker of the place it leads into (haven, wonder, delve, lair, market; a rest stop draws 'rest')
    if ((int)$sc['st']['sec'] + 1 >= (int)$sc['st']['S'] && ($toLoc = q_one('SELECT * FROM locations WHERE id = ?', [(int)($exp['to_id'] ?? 0)]))) {
        require_once __DIR__ . '/destination.php';
        $dk = loc_real_kind($toLoc);
        if (isset(TRAIL_DEST_MARKS[$dk])) $dest = [$dk, (string)$toLoc['name']];
    }
    if ($ex !== $sc['x'] || $ey !== $sc['y']) $tokens[] = $dest ? [$ex, $ey, TRAIL_DEST_MARKS[$dest[0]], 'gold', false, false, trail_dest_mark_name($dest[0])] : [$ex, $ey, '🚪', 'gold', false];
    require_once __DIR__ . '/trail_camps.php';   // 2.7.00: the camp tile of this route (when this is its stretch)
    $campSpot = tc_spot((array)($map['art'] ?? []));
    if ($campSpot && ($campSpot[0] !== $sc['x'] || $campSpot[1] !== $sc['y'])) $tokens[] = [$campSpot[0], $campSpot[1], '🏕️', 'gold', false];
    require_once __DIR__ . '/road_kinds.php';   // 2.7.01: the road kind's marker beside the way in, on the stretch it applies to
    $rkSpot = trail_road_mark($sc);
    $rkMark = $rkSpot ? trail_road_mark_name($rkSpot[2], (int)substr((string)$sc['row']['map_key'], 6)) : null;   // [name, emoji, label]: a road kind, or the signpost of a side path
    if ($rkSpot && ($rkSpot[0] !== $sc['x'] || $rkSpot[1] !== $sc['y'])) $tokens[] = [$rkSpot[0], $rkSpot[1], $rkMark[1], 'gold', false, false, $rkMark[0]];
    // 2026-11-10: a tool gate that is still shut for this gnome gets a 🔒 mark on its middle tile, and every tile of it says what it needs
    $shut = function_exists('tool_tier') && !empty($map['art']['gates']) ? trail_gates_closed($map['art'], fn(string $type): int => tool_tier((int)$u['id'], $type)) : [];
    $shutSeen = [];
    foreach ($shut as $gk => $g) {
        $gid = json_encode($g['tiles']);
        if (isset($shutSeen[$gid])) continue;
        $shutSeen[$gid] = true;
        $mid = $g['tiles'][intdiv(count($g['tiles']), 2)];
        $tokens[] = [(int)$mid[0], (int)$mid[1], '🔒', 'gold', false];
    }
    // a gate the gnome can already open (has the tool tier) gets a small open mark on its middle tile (aria-label "Open: <tool> gate")
    $openMid = [];
    if (function_exists('tool_tier')) foreach ($map['art']['gates'] ?? [] as $g) {
        if (empty($g['tiles']) || isset($shut[$g['tiles'][0][0] . ',' . $g['tiles'][0][1]])) continue;
        $mid = $g['tiles'][intdiv(count($g['tiles']), 2)];
        $openMid[(int)$mid[0] . ',' . (int)$mid[1]] = 'Open: ' . ($g['tool_name'] ?? $g['tool_type'] ?? 'tool') . ' gate';
        if (!empty($map['art']) && trail_art_ready($map['art']) && ($mid[0] !== $sc['x'] || $mid[1] !== $sc['y'])) $tokens[] = [(int)$mid[0], (int)$mid[1], '🔓', 'gold', false];
    }
    $sightMarks = [];   // v2.6.68 Trail Sights: where a Sight is ready (a gold ! over the landmark)
    $sightAll = !$busy ? trail_sights_marks($u, $sc) : [];
    foreach ($sightAll as $sm) $sightMarks[$sm['x'] . ',' . $sm['y']] = $sm['left'] > 0;   // 2.7.01: a used-up Sight keeps a faded spyglass (false)
    $folkMap = !$busy ? trail_sights_folk_on_map($u, $exp, $sc, $sightAll, true) : [];
    $folkTiles = []; foreach ($folkMap as $fi => $fe) $folkTiles[$fe[0] . ',' . $fe[1]] = $fi;   // tap a villager: their card   // villagers out and about at a Sight now
    $gate = trail_gate($sc);
    $reach = tm_reach($map, $sc['x'], $sc['y'], $gate);
    $open = str_repeat('0', $w * $h);
    $lit = [];
    for ($y = 0; $y < $h; $y++) for ($x = 0; $x < $w; $x++) {
        $t = tm_tile($map, $x, $y);
        if ($t === '#') continue;
        $ok = isset($reach[$y * $w + $x]);
        $tk = trail_token_at($sc, $x, $y);
        if (!$ok && $tk >= 0 && !(int)$sc['st']['tokens'][$tk][3]) foreach ([[1, 0], [-1, 0], [0, 1], [0, -1]] as [$dx, $dy]) if (isset($reach[($y + $dy) * $w + $x + $dx]) && $x + $dx >= 0 && $x + $dx < $w) $ok = true;
        if (!$ok && $t === '9') foreach ([[1, 0], [-1, 0], [0, 1], [0, -1]] as [$dx, $dy]) if (isset($reach[($y + $dy) * $w + $x + $dx]) && $x + $dx >= 0 && $x + $dx < $w) $ok = true;
        if ($ok) { $lit[$y * $w + $x] = true; $open[$y * $w + $x] = ($tk >= 0 && !(int)$sc['st']['tokens'][$tk][3]) || $t === '9' ? '2' : '1'; }
    }
    $walk = null;
    $wk = $_SESSION['dm_walk'] ?? null;
    unset($_SESSION['dm_walk']);
    if (is_array($wk) && (int)($wk['e'] ?? 0) === (int)$exp['id'] && time() - (int)($wk['t'] ?? 0) <= 30 && is_array($wk['p'] ?? null) && count($wk['p']) > 1) {
        $p = array_map(fn($pt) => [(int)$pt[0], (int)$pt[1]], $wk['p']);
        $last = end($p);
        if ($last[0] === $sc['x'] && $last[1] === $sc['y']) $walk = ['p' => $p];
    }
    require_once __DIR__ . '/fight_scene.php';
    [$fightOver_html, $fightDock, $fightOver] = fight_map_over($u, $fightExp ?? $exp, $sc, $win, $fightOver);   // the stage over the map (or its end scene) and the fight menu under it
    $art = !empty($map['art']) && trail_art_ready($map['art']);   // an authored section with its baked picture: the Hearth Pop v3 look
    $tints = !$art && !empty($map['art']) ? trail_decor_tints($map['art']) : [];   // 2026-11-14: no ground picture: the fallback look takes the section's decor colours (an empty list draws exactly the old look)
    $svg = $art
        ? trail_art_svg($map, ['px' => $sc['x'], 'py' => $sc['y'], 'x0' => $win['x0'], 'y0' => $win['y0'], 'cols' => DM_VIEW, 'rows' => DM_VIEW, 'tokens' => $tokens, 'sights' => $sightMarks, 'folk' => $folkMap, 'escort' => $fightOver ? '' : trail_escort_pic((string)($sc['st']['escort'] ?? '')), 'walk' => $walk, 'me' => $fightOver ? '' : trek_art_me($u), 'pals' => $fightOver ? [] : trail_pal_urls($u)])
        : tm_render_svg($map, $land, ['px' => $sc['x'], 'py' => $sc['y'], 'seen' => $sc['seen'], 'x0' => $win['x0'], 'y0' => $win['y0'], 'cols' => DM_VIEW, 'rows' => DM_VIEW,
            'light' => 8, 'tints' => $tints, 'tokens' => $tokens, 'sights' => $sightMarks, 'folk' => $folkMap, 'walk' => $walk, 'me' => $fightOver ? '' : trek_art_me($u), 'escort' => trail_escort_pic((string)($sc['st']['escort'] ?? '')), 'pals' => $fightOver ? [] : trail_pal_urls($u)]);   // fight_scene: the fight stage draws the gnome
    // v2.5.51: a wider picture covering the whole walk, shown only while the gnome walks (assets/tilemap.js keeps the camera on the gnome, like the delve maps)
    $extSvg = ''; $extData = '';
    if ($walk && count($walk['p']) > 1) {
        $xs = array_column($walk['p'], 0); $ys = array_column($walk['p'], 1);
        $ex0 = min(min($xs) - 5, $win['x0']); $ey0 = min(min($ys) - 5, $win['y0']);
        $ex1 = max(max($xs) + 6, $win['x0'] + DM_VIEW); $ey1 = max(max($ys) + 6, $win['y0'] + DM_VIEW);
        if (($ex1 - $ex0) * ($ey1 - $ey0) <= 900) {
            $extSvg = $art
                ? trail_art_svg($map, ['px' => $sc['x'], 'py' => $sc['y'], 'x0' => $ex0, 'y0' => $ey0, 'cols' => $ex1 - $ex0, 'rows' => $ey1 - $ey0, 'tokens' => $tokens, 'sights' => $sightMarks, 'folk' => $folkMap, 'walk' => $walk, 'escort' => trail_escort_pic((string)($sc['st']['escort'] ?? '')), 'pals' => trail_pal_urls($u), 'me' => trek_art_me($u), 'sfx' => 'x'])
                : tm_render_svg($map, $land, ['px' => $sc['x'], 'py' => $sc['y'], 'seen' => $sc['seen'], 'x0' => $ex0, 'y0' => $ey0, 'cols' => $ex1 - $ex0, 'rows' => $ey1 - $ey0,
                    'light' => 8, 'dim' => 999, 'tints' => $tints, 'tokens' => $tokens, 'sights' => $sightMarks, 'folk' => $folkMap, 'walk' => $walk, 'escort' => trail_escort_pic((string)($sc['st']['escort'] ?? '')), 'pals' => trail_pal_urls($u), 'me' => trek_art_me($u), 'sfx' => 'x']);
            $extData = ' data-ex0="' . $ex0 . '" data-ey0="' . $ey0 . '" data-ew="' . ($ex1 - $ex0) . '" data-eh="' . ($ey1 - $ey0) . '"';
        }
    }
    $btn = '';
    for ($j = 0; $j < DM_VIEW; $j++) for ($i = 0; $i < DM_VIEW; $i++) {
        $x = $win['x0'] + $i; $y = $win['y0'] + $j;
        $t = tm_tile($map, $x, $y);
        $cls = 'tmt' . (($i === 0 || $j === 0 || $i === DM_VIEW - 1 || $j === DM_VIEW - 1) ? ' ring' : '');
        $me = $x === $sc['x'] && $y === $sc['y'];
        $tap = $x >= 0 && $x < $w && $y >= 0 && $y < $h && isset($lit[$y * $w + $x]) && !$busy && $phase === 'section';
        $label = '';
        if ($t === '#' || $t === ' ') $cls .= $t === ' ' ? ' fog' : ' wall';
        else {
            $cls .= $tap ? ' reach' : '';
            $tk = trail_token_at($sc, $x, $y);
            if ($tk >= 0) { $done = (int)$sc['st']['tokens'][$tk][3]; $cls .= ' spot' . ($done ? ' done' : ''); $label = ($sc['st']['tokens'][$tk][2] === 'E' || ($sc['st']['tokens'][$tk][2] === 'M' && !$easyMini)) ? ($done ? 'Fight, done' : 'A fight waits here') : ($done ? 'Find, done' : (sights5_is_marked($sc['st'], $x, $y) ? 'Something to find (marked on your map)' : 'Something to find')); }
            elseif (isset($shut[$x . ',' . $y])) { $cls .= ' gate'; $label = trail_gate_message($shut, [[$x, $y]]) ?? 'A shut gate'; }
            elseif (isset($openMid[$x . ',' . $y])) $label = $openMid[$x . ',' . $y];
            elseif ($campSpot && $campSpot[0] === $x && $campSpot[1] === $y) { $cls .= ' spot'; $label = 'A camp spot: sleep, nap or wait'; }
            elseif ($rkSpot && $rkSpot[0] === $x && $rkSpot[1] === $y) $label = $rkMark[2];
            elseif ($t === '9') { $cls .= ' spot'; $label = $dest ? 'The way on to ' . $dest[1] : 'The way on'; }
            elseif ($t === 'S') $label = (int)$sc['st']['sec'] > 0 ? 'The way back' : 'Where this stretch begins';
        }
        if ($me) { $cls .= ' here'; $label = 'You are here'; }
        $dis = !$tap;
        $fpop = isset($folkTiles[$x . ',' . $y]) && !$busy && $phase === 'section' ? ' data-pop="hubpop-tfolk-' . $folkTiles[$x . ',' . $y] . '"' : '';
        if ($fpop) $dis = false;   // the villager's tile opens their card even when it is not a tile to walk to
        $btn .= '<button type="submit" class="' . $cls . '" name="go" value="' . $x . ',' . $y . '"' . ($dis ? ' disabled' : '') . $fpop . ($label !== '' ? ' aria-label="' . e($label) . '"' : ($tap ? ' aria-label="Walk here"' : ' tabindex="-1"')) . '></button>';
    }
    $data = ' data-clamp="1" data-tile="' . TM_UNIT . '" data-cols="' . DM_VIEW . '" data-rows="' . DM_VIEW . '" data-x0="' . $win['x0'] . '" data-y0="' . $win['y0'] . '" data-px="' . $sc['x'] . '" data-py="' . $sc['y'] . '" data-mw="' . $w . '" data-mh="' . $h . '" data-open="' . $open . '"';
    if ($walk) $data .= ' data-walk="' . e(implode(';', array_map(fn($p) => $p[0] . ',' . $p[1], $walk['p']))) . '"' . $extData;
    $out = trail_strip_html($u, $exp, $sc) . '<div class="tmwrap tm-' . e($land) . ($busy ? ' busy' : '') . '"><form method="post" class="tmform">' . csrf_field() . '<input type="hidden" name="do" value="trail_go">'
        . '<div class="tilemap tm-cave tm-trail' . ($fightOver ? ' tm-fight' : '') . '" role="group" aria-label="The Trail, section ' . ((int)$sc['st']['sec'] + 1) . ' of ' . (int)$sc['st']['S'] . '"' . $data . '><div class="tmview">' . $extSvg . '<div class="tmstage">' . $svg
        . '<svg class="tmpv" viewBox="0 0 ' . (DM_VIEW * TM_UNIT) . ' ' . (DM_VIEW * TM_UNIT) . '" preserveAspectRatio="none" aria-hidden="true" focusable="false"></svg><span class="tmchip" hidden></span>'
        . '<div class="tmgrid">' . $btn . '</div>' . $fightOver_html . '</div></div></div></form>' . $fightDock
        . ($art && !empty($map['art']['caption']) ? '<p class="tmcap">' . e((string)$map['art']['caption']) . '</p>' : '')
        . '<p class="tmlegend" aria-hidden="true">' . (!empty($map['art']['boss']) || (!empty($map['art']['extra_minibosses']) && !$easyMini) ? '<span>⚔️ A fight waits</span>' : '') . '<span>✨ A find</span><span>🚪 The way on</span>' . ($foggy ? '<span>🌫️ Fog: finds show when you are next to them</span>' : '') . ($shut ? '<span>🔒 Needs a tool</span>' : '') . ($openMid && str_contains(json_encode($tokens, JSON_UNESCAPED_UNICODE), '🔓') ? '<span>🔓 Open gate</span>' : '') . '</p></div>';
    return $out;
}

/** Gather on the stretch you are on (the existing gather_here: same tools, same energy). [ok, message] */
function trail_gather(array $u, array &$exp, string $tool): array
{
    if (!trail_scene($exp)) return [false, 'Not on a tile walk.'];
    if ($exp['encounter']) return [false, 'Deal with what is in front of you first.'];
    require_once __DIR__ . '/gathering.php';
    $land = (string)(exp_scene($exp)['land'] ?? 'grassland');
    if ($tool === 'rod' && !gather_candidates($land, 'rod') && trail_fish_here(trail_scene($exp))) $land = 'wetland';   // v2.7: by the water in a land without fish of its own: river fish
    [$ok, $line] = gather_here($u, $land, $tool);
    exp_log($exp, $line);
    return [$ok, ''];
}

/** v2.7: does the gnome stand on or beside water in this section (an authored section with water tiles)? Then the Fish button shows under the map. */
function trail_fish_here(?array $sc): bool
{
    $art = $sc['map']['art'] ?? null;
    return is_array($art) && ($sc['st']['phase'] ?? '') === 'section' && trail_water_near($art, (int)$sc['x'], (int)$sc['y']);
}

/**
 * Wander off the Trail (the existing explore_start: from the place the walk began, 1 energy, only from a place on a road). The walk is put away
 * in the session and ended; when the gnome is back on the road at that place, "Resume" brings the same section back (same map, same tokens).
 * [ok, message]
 */
function trail_wander(array $u, array &$exp): array
{
    $sc = trail_scene($exp);
    if (!$sc) return [false, 'Not on a tile walk.'];
    if ($exp['encounter']) return [false, 'Deal with what is in front of you first.'];
    require_once __DIR__ . '/explore.php';
    if (!on_road((int)$exp['from_id'])) return [false, 'You can only wander off from a place on a road.'];
    q("UPDATE expeditions SET status = 'done' WHERE id = ?", [$exp['id']]);   // explore_start refuses while a walk is active
    [$ok, $msg] = explore_start($u);
    if (!$ok) { q("UPDATE expeditions SET status = 'active' WHERE id = ?", [$exp['id']]); return [false, $msg]; }
    $_SESSION['trail_resume'] = ['uid' => (int)$u['id'], 'route' => (int)$exp['route_id'], 'from' => (int)$exp['from_id'], 'to' => (int)$exp['to_id'], 'level' => (int)$exp['level'], 'scaled' => (int)$exp['scaled'],
        'x' => $sc['x'], 'y' => $sc['y'], 'seen' => $sc['seen'], 'state' => json_encode($sc['st']), 'at' => time()];
    $exp['status'] = 'done';
    $exp['encounter'] = null;
    exp_log($exp, '🌿 You step off the Trail. (Come back to the road to pick it up again.)');
    dm_scene_drop((int)$exp['id']);
    return [true, $msg . ' Your walk waits at ' . (string)q_val('SELECT name FROM locations WHERE id = ?', [$exp['from_id']]) . '.'];
}

/** The walk put away by trail_wander, if it can be picked up here and now: null or the snapshot. */
function trail_resume_offer(array $u): ?array
{
    $r = $_SESSION['trail_resume'] ?? null;
    if (!is_array($r) || (int)$r['uid'] !== (int)$u['id'] || time() - (int)$r['at'] > 6 * 3600) return null;
    if ((int)($u['location_id'] ?? 0) !== (int)$r['from'] || active_expedition((int)$u['id'])) return null;
    return $r;
}

/** The put-away walk while the gnome is out wandering (no location or walk check): the snapshot, or null. */
function trail_snapshot(array $u): ?array
{
    $r = $_SESSION['trail_resume'] ?? null;
    return is_array($r) && (int)$r['uid'] === (int)$u['id'] && time() - (int)$r['at'] <= 6 * 3600 ? $r : null;
}

/** A read-only view of the snapshot's section: [ghost walk row, scene] for trail_view_html($u, $ghost, $sc, true) behind the Wander popover. Null if it cannot be built. */
function trail_snapshot_view(array $u, array $r, array $base): ?array
{
    $st = json_decode((string)$r['state'], true);
    if (!is_array($st) || !isset($st['sec'], $st['S'])) return null;
    [$map] = trail_map_make(trail_seed((int)$r['route'], (int)$u['id'], (int)($st['sx'] ?? 0), (int)$st['sec'], $st));
    $ghost = array_merge($base, ['id' => -1, 'kind' => 'walk', 'status' => 'active', 'route_id' => (int)$r['route'], 'from_id' => (int)$r['from'], 'to_id' => (int)$r['to'], 'user_id' => (int)$u['id'], 'encounter' => null]);
    return [$ghost, ['row' => ['id' => 0], 'old' => '', 'map' => $map, 'x' => (int)$r['x'], 'y' => (int)$r['y'], 'seen' => (string)$r['seen'], 'st' => $st]];
}

/** Pick the put-away walk up again at no energy: a new expedition row, the same scene. [ok, message] */
function trail_resume(array $u): array
{
    $r = trail_resume_offer($u);
    if (!$r) return [false, 'There is no walk to resume here.'];
    $st = json_decode((string)$r['state'], true);
    $route = q_one('SELECT * FROM routes WHERE id = ?', [$r['route']]);
    if (!is_array($st) || !$route) { unset($_SESSION['trail_resume']); return [false, 'That walk is gone.'];}
    $gc = gnome_combat($u, true);
    $id = db_insert('expeditions', ['level' => (int)$r['level'], 'scaled' => (int)$r['scaled'], 'user_id' => $u['id'], 'from_id' => $r['from'], 'to_id' => $r['to'], 'route_id' => $r['route'],
        'steps_total' => (int)$st['S'], 'step' => (int)$st['sec'], 'hp' => hp_start($u, (int)$gc['max_hp']), 'max_hp' => $gc['max_hp'],
        'log' => json_encode(['🍄 You pick the Trail up again.']), 'started_at' => now(), 'arrive_at' => now()]);
    db_insert('walk_scene', ['user_id' => $u['id'], 'exp_id' => $id, 'map_key' => 'trail:' . (int)$r['route'], 'x' => (int)$r['x'], 'y' => (int)$r['y'], 'seen' => (string)$r['seen'], 'state' => (string)$r['state'], 'updated_at' => now()]);
    unset($_SESSION['trail_resume']);
    return [true, '🍄 You pick the Trail up where you left it.'];
}

/** A one-tap bar offering the resume (empty when there is nothing to resume). */
function trail_resume_html(array $u): string
{
    $r = trail_resume_offer($u);
    if (!$r) return '';
    $to = (string)q_val('SELECT name FROM locations WHERE id = ?', [$r['to']]);
    $st = json_decode((string)$r['state'], true) ?: [];
    return '<form method="post" action="' . e(url('adventure.php')) . '" class="box destresume trailui">' . csrf_field() . '<input type="hidden" name="do" value="trail_resume">'
        . '<span>🍄 Your walk to <b>' . e($to) . '</b> is waiting (section ' . ((int)($st['sec'] ?? 0) + 1) . ' of ' . (int)($st['S'] ?? 1) . ').</span> <button class="btn small">↩ Resume it</button></form>';
}
