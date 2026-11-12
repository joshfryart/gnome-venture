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
// ---- v1 bundle switches (SIM ONLY). Override with env V1='{"limit":4,...}'
const V1_DEFAULTS = ['ground' => 1, 'nsun' => 2, 'nbr' => 2, 'nmud' => 1, 'gmin' => 2, 'gmax' => 3, 'sun' => 2.0, 'bramble' => 0.10,   // ground cells, gmin-gmax steps from the centre; bramble = share of max health per environment turn
    'events' => 1, 'nev' => 1, 'ev' => 1.0, 'ev_unit' => 0.10,   // nev forecast events a round; strength = ev x ev_unit x max health (or creature health) per piece in the zone
    'limit' => 3, 'spend_foe' => 1,   // a chain of `limit` or more fired pieces uses those pieces up (0 = off); spend_foe: also for chains the creature starts
    'aim' => 1, 'foe' => 1.35, 'team' => 1.6,   // aim: shown and committed, no fumble; foe: factor on the creature's piece values; team: Teamwork factor (pal + tool + crop in one chain)
    'blind' => ''];   // sim only: 'g' the creature's search ignores ground, 'e' ignores events (not used in the tables)
function v1(string $k) { static $c = null; if ($c === null) $c = (json_decode(getenv('V1') ?: '{}', true) ?: []) + V1_DEFAULTS; return $c[$k]; }
function pfb_ter(array $s, int $x, int $y): string { return $s['ter']["$x,$y"] ?? ''; }
function pfb_st(array &$s, string $k, float $n = 1): void { $s['st'][$k] = ($s['st'][$k] ?? 0) + $n; }

/** Ground: nsun sunny, nbr bramble, nmud mud cells, 2-3 steps from the centre. */
function pfb_seed_ground(array &$s): void
{
    $s['ter'] = []; if (!v1('ground')) return;
    $cx = intdiv(PFB_W, 2); $cy = intdiv(PFB_H, 2); $cand = [];
    for ($y = 0; $y < PFB_H; $y++) for ($x = 0; $x < PFB_W; $x++) { $d = abs($x - $cx) + abs($y - $cy); if ($d >= (int)v1('gmin') && $d <= (int)v1('gmax')) $cand[] = "$x,$y"; }
    $cand = pf_shuffle($s, $cand);
    foreach (['sun' => (int)v1('nsun'), 'br' => (int)v1('nbr'), 'mud' => (int)v1('nmud')] as $kind => $n) for ($i = 0; $i < $n && $cand; $i++) $s['ter'][array_pop($cand)] = $kind;
}
/** The environment hurts the owner of a piece: you lose health, the creature loses health (both as a share of the maximum). */
function pfb_env_hurt(array &$s, string $who, float $frac, string $tag): void
{
    if ($who === 'me') { $d = max(1, (int)round($frac * $s['me']['max'])); $s['me']['hp'] = max(0, $s['me']['hp'] - $d); pfb_st($s, $tag . '_me', $d / $s['me']['max']); }
    elseif ($who === 'foe') { $s['fh']['now'] += $frac * $s['fh']['max']; pfb_st($s, $tag . '_foe', $frac); }
}
/** The environment turn (after the creature): bramble pricks, then the announced event lands. */
function pfb_env_turn(array &$s): void
{
    if (v1('ground')) foreach ($s['pcs'] as $p) if (pfb_ter($s, $p['x'], $p['y']) === 'br') pfb_env_hurt($s, $p['by'], (float)v1('bramble'), 'br');
    if (v1('events')) foreach ($s['envs'] ?? [] as $e) {
        $u = (float)v1('ev') * (float)v1('ev_unit');
        if ($e['kind'] === 'wind') {
            $id = $s['cell'][$e['x'] . ',' . $e['y']] ?? null; [$dx, $dy] = PFB_SIDE[$e['dir']]; $nx = $e['x'] + $dx; $ny = $e['y'] + $dy;
            if ($id !== null && $nx >= 0 && $ny >= 0 && $nx < PFB_W && $ny < PFB_H && !isset($s['cell']["$nx,$ny"])) {
                unset($s['cell'][$e['x'] . ',' . $e['y']]); $s['cell']["$nx,$ny"] = $id; $s['pcs'][$id]['x'] = $nx; $s['pcs'][$id]['y'] = $ny; pfb_st($s, 'wind_' . $s['pcs'][$id]['by']);
            }
        } else {
            foreach (pfb_zone($e) as [$x, $y]) { $p = pfb_at($s, $x, $y); if (!$p || $p['by'] === 'none') continue;
                if ($e['kind'] === 'thorn') pfb_env_hurt($s, $p['by'], $u, 'thorn');
                else { $g = max(1, (int)round($u * ($p['by'] === 'me' ? $s['me']['max'] : $s['fh']['max']))); if ($p['by'] === 'me') $s['me']['keep'] += $g; else $s['foe']['block'] += $g; pfb_st($s, 'rain_' . $p['by']); }   // rain: guard for the owner through the next turn
            }
        }
    }
    pf_check_end($s);
}
function pfb_zone(array $e): array { $z = [[$e['x'], $e['y']]]; foreach (PFB_SIDE as [$dx, $dy]) $z[] = [$e['x'] + $dx, $e['y'] + $dy]; return $z; }
/** What the announced events will do to a piece of $who put on (x,y), in the creature's score units (thorn costs, rain guards). */
function pfb_env_bias(array $s, string $who, int $x, int $y): float
{
    $b = 0.0; $u = (float)v1('ev') * (float)v1('ev_unit'); $m = $who === 'foe' ? 0.8 * $s['fh']['max'] : 0.7 * $s['me']['max'];
    if (v1('events')) foreach ($s['envs'] ?? [] as $e) { if ($e['kind'] === 'wind') continue; foreach (pfb_zone($e) as [$zx, $zy]) if ($zx === $x && $zy === $y) $b += $e['kind'] === 'thorn' ? -$u * $m : 0.4 * $u * $m; }
    return $b;
}
/** Announce the next event (shown one round ahead): a cell on or next to a piece, one of rain / wind / thorn burst. */
function pfb_forecast(array &$s): void
{
    $s['envs'] = []; if (!v1('events')) return;
    $cand = [];
    foreach ($s['pcs'] as $p) { $cand[$p['x'] . ',' . $p['y']] = 1; foreach (PFB_SIDE as [$dx, $dy]) { $x = $p['x'] + $dx; $y = $p['y'] + $dy; if ($x >= 0 && $y >= 0 && $x < PFB_W && $y < PFB_H) $cand["$x,$y"] = 1; } }
    $keys = array_keys($cand);
    for ($i = 0; $i < (int)v1('nev') && $keys; $i++) {
        $j = pf_rand($s, count($keys)); [$x, $y] = array_map('intval', explode(',', $keys[$j])); array_splice($keys, $j, 1);
        $s['envs'][] = ['kind' => ['rain', 'wind', 'thorn'][pf_rand($s, 3)], 'x' => $x, 'y' => $y, 'dir' => array_keys(PFB_SIDE)[pf_rand($s, 4)]];
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
        if (isset($srcs['pal'], $srcs['tool'], $srcs['crop'])) { $tw = (float)v1('team'); pfb_st($s, 'team'); } }
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
rep("            $sc = pfb_score($s, $w, $who);\n", "            $sc = pfb_score($s, $w, $who);\n            if (pfb_ter($s, $x, $y) === 'br' && isset($w['cell'][\"$x,$y\"]) && strpos((string)v1('blind'), 'g') === false) $sc -= 2 * (float)v1('bramble') * ($who === 'foe' ? 0.8 * $s['fh']['max'] : 0.7 * $s['me']['max']);\n            if (isset($w['cell'][\"$x,$y\"]) && strpos((string)v1('blind'), 'e') === false) $sc += pfb_env_bias($s, $who, $x, $y);\n")

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
rep("* (PFB_FOE_FIRES > 0 ? PFB_FOE_FIRE_MULT : 1.0);", "* (PFB_FOE_FIRES > 0 ? PFB_FOE_FIRE_MULT : 1.0) * (float)v1('foe');")
rep("$s['pid'] = 0; $s['seq'] = 0; $s['round'] = 1;", "$s['pid'] = 0; $s['seq'] = 0; $s['round'] = 1; $s['st'] = []; pfb_seed_ground($s);")

# environment turn after the creature
rep("{\n    $gone = pfb_expire($s);", "{\n    pfb_env_turn($s); if ($s['over']) return;\n    $gone = pfb_expire($s);")

open(os.path.join(here, 'pfboard_v1.php'), 'w').write(src.replace(" * Puzzle Combat, BOARD mode:", " * SIM-ONLY COPY (generated by mkengine.py; do not edit, do not load from the game). Puzzle Combat, BOARD mode:"))
print('ok')
