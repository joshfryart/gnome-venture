#!/usr/bin/env python3
"""Builds pfboard_v1.php: a SCRATCH copy of game/includes/pfboard.php with the v1 bundle rules behind switches (env V1 = JSON).
Never loaded by the game. Re-run after the real engine changes: python3 tools/pfsim/v1bundle/mkengine.py"""
import os, sys
here = os.path.dirname(os.path.abspath(__file__))
src = open(os.path.join(here, '../../../game/includes/pfboard.php')).read()
def rep(old, new, count=1):
    global src
    assert src.count(old) == count, (src.count(old), old)
    src = src.replace(old, new)

rep("require_once __DIR__ . '/pfight.php';", r"""require_once (getenv('ENG') ?: __DIR__ . '/../../../game/includes') . '/pfight.php';
// ---- v1 bundle switches (SIM ONLY, sim 3). Override with env V1='{"limit":4,...}'. A value may be a map by creature size: {"foe":{"small":1.5,"medium":1.3,"large":1.3,"boss":1.2}}
const V1_SIZES = ['small', 'medium', 'large', 'boss'];
const V1_DEFAULTS = ['dims' => ['small' => [5, 4], 'medium' => [5, 5], 'large' => [7, 5], 'boss' => [7, 6]],   // board width x height by creature size
    'ground' => 1, 'nsun' => ['small' => 2, 'medium' => 3, 'large' => 3, 'boss' => 4], 'nbr' => ['small' => 2, 'medium' => 2, 'large' => 3, 'boss' => 3], 'nmud' => 1, 'gmin' => 1, 'gmax' => 2,   // ground cells, gmin-gmax steps from the centre
    'sun' => 2.0, 'bramble' => 0.10, 'br_foe' => 1.0,   // sunny factor; bramble = share of max health per environment turn (x br_foe for a creature piece)
    'events' => 1, 'nev' => 1, 'evk' => ['sunbeam', 'creep', 'gust', 'thorn', 'puddle'], 'ev_unit' => 0.10, 'ev_foe' => 0.5, 'gextra' => 0,   // nev forecast events a round, kinds drawn evenly from evk; thorn burst = ev_unit x max health per piece (x ev_foe for the creature); gextra: ground cells of a kind allowed above the start count
    'limit' => 3, 'spend_foe' => 1,   // a chain of `limit` or more fired pieces uses those pieces up (0 = off); spend_foe: also for chains the creature starts
    'aim' => 1, 'foe' => 1.3, 'bar' => 1.0, 'team2' => 1.3, 'team' => 1.6,   // aim: shown and committed, no fumble; foe: factor on the creature's piece values; bar: factor on the creature's bars; Teamwork: 2 sources / 3 sources in one chain
    'blind' => ''];   // sim only: 'g' the creature's search ignores ground, 'e' ignores events (not used in the tables)
function v1(string $k) {
    static $c = null; if ($c === null) $c = (json_decode(getenv('V1') ?: '{}', true) ?: []) + V1_DEFAULTS;
    $pick = function ($v) { $sz = $GLOBALS['PFSZ'] ?? 'medium'; return is_array($v) && array_intersect(array_keys($v), V1_SIZES) ? ($v[$sz] ?? null) : $v; };
    return $pick($c[$k]) ?? $pick(V1_DEFAULTS[$k]);
}
function pfb_w(): int { return $GLOBALS['PFBW'] ?? PFB_W; }
function pfb_h(): int { return $GLOBALS['PFBH'] ?? PFB_H; }
function pfb_ter(array $s, int $x, int $y): string { return $s['ter']["$x,$y"] ?? ''; }
function pfb_st(array &$s, string $k, float $n = 1): void { $s['st'][$k] = ($s['st'][$k] ?? 0) + $n; }

/** Ground: nsun sunny, nbr bramble, nmud mud cells, gmin-gmax steps from the centre. */
function pfb_seed_ground(array &$s): void
{
    $s['ter'] = []; if (!v1('ground')) return;
    $cx = intdiv(pfb_w(), 2); $cy = intdiv(pfb_h(), 2); $cand = [];
    for ($y = 0; $y < pfb_h(); $y++) for ($x = 0; $x < pfb_w(); $x++) { $d = abs($x - $cx) + abs($y - $cy); if ($d >= (int)v1('gmin') && $d <= (int)v1('gmax')) $cand[] = "$x,$y"; }
    $cand = pf_shuffle($s, $cand);
    foreach (['sun' => (int)v1('nsun'), 'br' => (int)v1('nbr'), 'mud' => (int)v1('nmud')] as $kind => $n) for ($i = 0; $i < $n && $cand; $i++) $s['ter'][array_pop($cand)] = $kind;
}
/** An event puts ground on a cell (replacing what was there). There are never more cells of a kind than at the start (+ gextra): the oldest one goes. */
function pfb_ground_set(array &$s, int $x, int $y, string $kind): void
{
    unset($s['ter']["$x,$y"]); $s['ter']["$x,$y"] = $kind;
    $cap = max(1, (int)v1(['sun' => 'nsun', 'br' => 'nbr', 'mud' => 'nmud'][$kind]) + (int)v1('gextra')); $have = array_keys($s['ter'], $kind, true);
    while (count($have) > $cap) unset($s['ter'][array_shift($have)]);
}
/** The environment hurts the owner of a piece: you lose health, the creature loses health (both as a share of the maximum). */
function pfb_env_hurt(array &$s, string $who, float $frac, string $tag): void
{
    if ($who === 'me') { $d = max(1, (int)round($frac * $s['me']['max'])); $s['me']['hp'] = max(0, $s['me']['hp'] - $d); pfb_st($s, $tag . '_me', $d / $s['me']['max']); }
    elseif ($who === 'foe') { $frac *= (float)v1($tag === 'thorn' ? 'ev_foe' : 'br_foe'); $s['fh']['now'] += $frac * $s['fh']['max']; pfb_st($s, $tag . '_foe', $frac); }
}
/** The environment turn (after the creature): the announced events land (they move ground, push a piece or burst), then bramble pricks. */
function pfb_env_turn(array &$s): void
{
    if (v1('events')) foreach ($s['envs'] ?? [] as $e) {
        $on = pfb_at($s, $e['x'], $e['y']); $ob = $on && $on['by'] !== 'none' ? $on['by'] : null;
        if ($e['kind'] === 'gust') {
            $id = $s['cell'][$e['x'] . ',' . $e['y']] ?? null; [$dx, $dy] = PFB_SIDE[$e['dir']]; $nx = $e['x'] + $dx; $ny = $e['y'] + $dy;
            if ($id !== null && $ob && $nx >= 0 && $ny >= 0 && $nx < pfb_w() && $ny < pfb_h() && !isset($s['cell']["$nx,$ny"])) {
                unset($s['cell'][$e['x'] . ',' . $e['y']]); $s['cell']["$nx,$ny"] = $id; $s['pcs'][$id]['x'] = $nx; $s['pcs'][$id]['y'] = $ny; pfb_st($s, 'gust_' . $ob);
            }
        } elseif ($e['kind'] === 'thorn') {
            foreach (pfb_zone($e) as [$x, $y]) { $p = pfb_at($s, $x, $y); if ($p && $p['by'] !== 'none') pfb_env_hurt($s, $p['by'], (float)v1('ev_unit'), 'thorn'); }
        } else { $kind = ['sunbeam' => 'sun', 'creep' => 'br', 'puddle' => 'mud'][$e['kind']]; pfb_ground_set($s, $e['x'], $e['y'], $kind); if ($ob) pfb_st($s, $e['kind'] . '_' . $ob); }
        pfb_st($s, 'ev_' . $e['kind']);
    }
    if (v1('ground')) foreach ($s['pcs'] as $p) if (pfb_ter($s, $p['x'], $p['y']) === 'br') pfb_env_hurt($s, $p['by'], (float)v1('bramble'), 'br');
    pf_check_end($s);
}
function pfb_zone(array $e): array { $z = [[$e['x'], $e['y']]]; foreach (PFB_SIDE as [$dx, $dy]) $z[] = [$e['x'] + $dx, $e['y'] + $dy]; return $z; }
/** What the announced events will do to a piece of $who put on (x,y), in the creature's score units. */
function pfb_env_bias(array $s, string $who, int $x, int $y, ?array $tile = null): float
{
    $b = 0.0; $m = $who === 'foe' ? 0.8 * $s['fh']['max'] : 0.7 * $s['me']['max'];
    if (v1('events')) foreach ($s['envs'] ?? [] as $e) {
        if ($e['kind'] === 'thorn') { foreach (pfb_zone($e) as [$zx, $zy]) if ($zx === $x && $zy === $y) $b -= (float)v1('ev_unit') * ($who === 'foe' ? (float)v1('ev_foe') : 1.0) * $m; }
        elseif ($e['x'] === $x && $e['y'] === $y) {
            if ($e['kind'] === 'creep') $b -= (float)v1('bramble') * ($who === 'foe' ? (float)v1('br_foe') : 1.0) * $m;
            elseif ($e['kind'] === 'sunbeam' && $tile && in_array($tile['t'], ['hurt', 'charm'], true)) $b += 0.3 * $tile['v'];
        }
    }
    return $b;
}
/** Announce the next events (shown before you move, they land after the creature's move): each on a cell on or next to a piece. */
function pfb_forecast(array &$s): void
{
    $s['envs'] = []; if (!v1('events')) return;
    $cand = []; $pcs = [];
    foreach ($s['pcs'] as $p) { if ($p['by'] !== 'none') $pcs[] = $p['x'] . ',' . $p['y']; $cand[$p['x'] . ',' . $p['y']] = 1; foreach (PFB_SIDE as [$dx, $dy]) { $x = $p['x'] + $dx; $y = $p['y'] + $dy; if ($x >= 0 && $y >= 0 && $x < pfb_w() && $y < pfb_h()) $cand["$x,$y"] = 1; } }
    $keys = array_keys($cand); $kinds = v1('evk');
    for ($i = 0; $i < (int)v1('nev') && $keys; $i++) {
        $kind = $kinds[pf_rand($s, count($kinds))]; $dir = 'L';
        if ($kind === 'gust') {   // a piece, and a direction that is free now
            if (!$pcs) continue; $j = pf_rand($s, count($pcs)); $key = $pcs[$j]; [$x, $y] = array_map('intval', explode(',', $key)); $dirs = [];
            foreach (PFB_SIDE as $d => [$dx, $dy]) { $nx = $x + $dx; $ny = $y + $dy; if ($nx >= 0 && $ny >= 0 && $nx < pfb_w() && $ny < pfb_h() && !isset($s['cell']["$nx,$ny"])) $dirs[] = $d; }
            if (!$dirs) $dirs = array_keys(PFB_SIDE); $dir = $dirs[pf_rand($s, count($dirs))];
        } else {
            $gk = ['sunbeam' => 'sun', 'creep' => 'br', 'puddle' => 'mud'][$kind] ?? null; $ok = array_values(array_filter($keys, fn($k) => $gk === null || ($s['ter'][$k] ?? '') !== $gk)); if (!$ok) continue;
            $key = $ok[pf_rand($s, count($ok))];
        }
        $keys = array_values(array_diff($keys, [$key])); [$x, $y] = array_map('intval', explode(',', $key));
        $s['envs'][] = ['kind' => $kind, 'x' => $x, 'y' => $y, 'dir' => $dir];
    }
}""")

# mud blocks links
rep("$joints[] = [$side, (int)$n['id'], $linked];", "$joints[] = [$side, (int)$n['id'], $linked && pfb_ter($s, $x, $y) !== 'mud' && pfb_ter($s, $x + $dx, $y + $dy) !== 'mud'];")
rep("if ($n && $n['by'] !== 'none' && pfb_joint($e[$side], pfb_edges($n['tile'])[$opp])[1]) $o[] = $n;", "if ($n && $n['by'] !== 'none' && pfb_joint($e[$side], pfb_edges($n['tile'])[$opp])[1] && pfb_ter($s, $p['x'], $p['y']) !== 'mud' && pfb_ter($s, $n['x'], $n['y']) !== 'mud') $o[] = $n;")
rep("$touch = true; if ($jt[1]) $linked = true;", "$touch = true; if ($jt[1] && pfb_ter($s, $x, $y) !== 'mud' && pfb_ter($s, $nx, $ny) !== 'mud') $linked = true;")

# fire: teamwork, sunny, record what fired
rep("    $chain = pfb_chain($s, $root);\n    foreach", r"""    $chain = pfb_chain($s, $root);
    $rb = $s['pcs'][$root]['by']; $tw = 1.0; $s['fired'] = []; $s['firedby'] = $rb;
    if (v1('team') > 1) { $srcs = []; foreach ($chain as [$cid]) { $cp = $s['pcs'][$cid]; if ($cp['by'] === $rb && !empty($cp['tile']['src'])) $srcs[$cp['tile']['src']] = 1; }
        $ns = count(array_intersect_key($srcs, ['pal' => 1, 'tool' => 1, 'crop' => 1]));
        if ($ns >= 3) { $tw = (float)v1('team'); pfb_st($s, 'team3'); } elseif ($ns === 2 && v1('team2') > 1) { $tw = (float)v1('team2'); pfb_st($s, 'team2'); } }
    foreach""")
rep("$val = (int)round($val * (float)($p['cm'] ?? 1.0));   // a placed 3-piece group plays for more", r"""$val = (int)round($val * (float)($p['cm'] ?? 1.0));   // a placed 3-piece group plays for more
        if (in_array($tile['t'], ['hurt', 'charm'], true) && pfb_ter($s, $p['x'], $p['y']) === 'sun') { $val = (int)round($val * (float)v1('sun')); pfb_st($s, 'sun_' . $who); }
        if ($tw > 1 && $who === $rb) $val = (int)round($val * $tw);
        $s['fired'][] = $id; $pr0 = $s['fh']['now'] + $s['bar']['now'];""")
rep("$s['pcs'][$id]['f'] = (int)($s['pcs'][$id]['f'] ?? 0) + 1;", "$s['pcs'][$id]['f'] = (int)($s['pcs'][$id]['f'] ?? 0) + 1; if ($rb === 'me' && $who === 'me') { $pd = $s['fh']['now'] + $s['bar']['now'] - $pr0; pfb_st($s, $isRoot ? 'prog_root' : 'prog_refire', $pd); pfb_st($s, 'pk_' . $tile['k'], $pd); if (pfb_ter($s, $p['x'], $p['y']) === 'sun') { pfb_st($s, 'prog_sun', $pd); if (!$isRoot) pfb_st($s, 'sunre_me'); } }")

# spend-on-chain
rep("    if ($s['over']) return;\n    foreach ($s['pcs'] as $id => $p) {\n        $lim = pfb_fire_limit($p);", r"""    if ($s['over']) return;
    $lim3 = (int)v1('limit'); $fired = $s['fired'] ?? []; $s['fired'] = [];
    if ($lim3 > 0 && count($fired) >= $lim3 && (($s['firedby'] ?? 'me') === 'me' || v1('spend_foe'))) {   // v1: a chain of 3+ uses up every piece that fired
        pfb_st($s, 'spend_' . $s['firedby']);
        foreach ($fired as $id) { if (!isset($s['pcs'][$id])) continue; $p = $s['pcs'][$id];
            $s[$p['by']]['discard'][] = $p['tile']; $s['spent'][] = $p; pfb_st($s, 'used_' . $p['by'] . '_by_' . $s['firedby']);
            unset($s['cell'][$p['x'] . ',' . $p['y']], $s['pcs'][$id]); }
    }
    foreach ($s['pcs'] as $id => $p) {
        $lim = pfb_fire_limit($p);""")

# aim: a committed aim plays on its cell even when its link has gone
rep("if ($jt === null || (!pfb_has_link($jt) && pfb_must_link($s, $who))) return null;   // it has to connect unless nothing can", "if ($jt === null || (!pfb_has_link($jt) && empty($s['aimforce']) && pfb_must_link($s, $who))) return null;   // it has to connect unless nothing can (v1: a committed aim plays on its cell even when its link has gone)")

# creature search: knows what bramble and the announced events do to a piece that stays out
rep("            $sc = pfb_score($s, $w, $who);\n", "            $sc = pfb_score($s, $w, $who);\n            if (pfb_ter($s, $x, $y) === 'br' && isset($w['cell'][\"$x,$y\"]) && strpos((string)v1('blind'), 'g') === false) $sc -= 2 * (float)v1('bramble') * ($who === 'foe' ? (float)v1('br_foe') * 0.8 * $s['fh']['max'] : 0.7 * $s['me']['max']);\n            if (isset($w['cell'][\"$x,$y\"]) && strpos((string)v1('blind'), 'e') === false) $sc += pfb_env_bias($s, $who, $x, $y, $tile);\n")

# aim: commit (no fumble)
rep("""        $m = pfb_search($s, 'foe');
        if ($m === null) break;
        $r = pfb_place($s, 'foe', $m[0], $m[1], $m[2]);""", r"""        $r = null; $plan = v1('aim') ? ($s['foe']['plan'] ?? null) : null;
        if ($plan) foreach ($s['foe']['hand'] as $hi => $ht) if ($ht['k'] === $plan['k']) { $s['aimforce'] = true; $r = pfb_place($s, 'foe', $hi, $plan['x'], $plan['y']); unset($s['aimforce']); break; }
        if ($r !== null) pfb_st($s, 'aim_ok');
        if ($r === null) {   // no fumble: when its cell is taken (or its piece is gone) it picks again at full value
            if ($plan) pfb_st($s, 'reaim');
            $m = pfb_search($s, 'foe');
            if ($m === null) break;
            $r = pfb_place($s, 'foe', $m[0], $m[1], $m[2]);
        }""")
rep("""    $m = pfb_search($s, 'foe');
    $s['foe']['intent'] = $m ? $s['foe']['hand'][$m[0]]['t'] : null;""", """    pfb_forecast($s);
    $m = pfb_search($s, 'foe');
    $s['foe']['intent'] = $m ? $s['foe']['hand'][$m[0]]['t'] : null;
    $s['foe']['plan'] = $m ? ['k' => $s['foe']['hand'][$m[0]]['k'], 't' => $s['foe']['hand'][$m[0]]['t'], 'v' => $s['foe']['hand'][$m[0]]['v'], 'x' => $m[1], 'y' => $m[2]] : null;   // v1: the aim (piece and cell), shown to the player""")

# new: creature factor, ground
rep("    $s = pf_new($me, $c, $seed, $opt);\n    $fm = PFB_FOE_MULT", "    $GLOBALS['PFSZ'] = $c['size'] ?? 'medium'; [$GLOBALS['PFBW'], $GLOBALS['PFBH']] = v1('dims');   // v1: the board size comes from the creature's size\n    $s = pf_new($me, $c, $seed, $opt);\n    $fm = PFB_FOE_MULT")
rep("$s['bar']['max'] = round($s['bar']['max'] * PFB_BAR_MULT, 1);", "$s['bar']['max'] = round($s['bar']['max'] * PFB_BAR_MULT * (float)v1('bar'), 1);")
rep("* (PFB_FOE_FIRES > 0 ? PFB_FOE_FIRE_MULT : 1.0);", "* (PFB_FOE_FIRES > 0 ? PFB_FOE_FIRE_MULT : 1.0) * (float)v1('foe');")
rep("$s['pid'] = 0; $s['seq'] = 0; $s['round'] = 1;", "$s['pid'] = 0; $s['seq'] = 0; $s['round'] = 1; $s['st'] = []; pfb_seed_ground($s);")

# environment turn after the creature
rep("{\n    $gone = pfb_expire($s);", "{\n    pfb_env_turn($s); if ($s['over']) return;\n    $gone = pfb_expire($s);")

# board size by creature size: every use of the two constants reads the size of this fight
src = src.replace('PFB_W', 'pfb_w()').replace('PFB_H', 'pfb_h()').replace('const pfb_w() = 7, pfb_h() = 5', 'const PFB_W = 7, PFB_H = 5').replace('?? pfb_w(); }', '?? PFB_W; }').replace('?? pfb_h(); }', '?? PFB_H; }')
open(os.path.join(here, 'pfboard_v1.php'), 'w').write(src.replace(" * Puzzle Combat, BOARD mode:", " * SIM-ONLY COPY (generated by mkengine.py; do not edit, do not load from the game). Puzzle Combat, BOARD mode:"))
print('ok')
