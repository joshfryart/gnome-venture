<?php
// Puzzle fight BOARD playtest harness for agents and bots (no DB, no server, no browser).
//   php tests/pf_play.php new STATE CREATURE_SLUG LEVEL SEED [classic|blank]   start a fight (blank = blank wild centre + hidden start)
//   php tests/pf_play.php show STATE                                           the board, your hand and every legal cell
//   php tests/pf_play.php start STATE HANDIDX SIDE        (blank only) hidden start piece next to the centre: SIDE = L R T B
//   php tests/pf_play.php place STATE HANDIDX X Y         play one hand piece
//   php tests/pf_play.php join STATE A B SIDE              set hand piece B aside joined to hand piece A (B on A's SIDE), no effect
//   php tests/pf_play.php add STATE B ANC SIDE             add hand piece B to the set-aside group, onto group piece ANC's SIDE
//   php tests/pf_play.php group STATE X Y                  play the set-aside group, top-left at X,Y
//   php tests/pf_play.php pass STATE                       only when nothing fits anywhere
//   php tests/pf_play.php list [N]                         creatures (slug, size, level)
// STATE is a json file. Every action is appended to STATE.log (one json line each) for data. The creature's hand and the draw pile are never shown.
require __DIR__ . '/../game/includes/pfboard.php';
$die = ['small' => 4, 'medium' => 6, 'large' => 8, 'boss' => 10];
function pp_creatures(): array
{
    global $die; $o = [];
    foreach (file(__DIR__ . '/../game/includes/data/creatures.txt', FILE_IGNORE_NEW_LINES) as $l) {
        if ($l === '' || $l[0] === '#') continue; $c = explode('|', $l); if (count($c) < 7) continue;
        $lv = max(1, (int)$c[4]); $o[$c[0]] = ['slug' => $c[0], 'name' => $c[1], 'size' => $c[2], 'level' => $lv, 'dmg_die' => $die[$c[2]] ?? 6, 'dmg_bonus' => intdiv($lv, 4)];
    }
    return $o;
}
function pp_player(int $lv): array
{
    $m = max(0, intdiv($lv + 3, 14)); $st = ['grit' => $m, 'nimble' => $m, 'hardiness' => $m, 'charm' => $m, 'lore' => $m, 'luck' => $m, 'level' => $lv];
    $cals = array_keys(PF_CALLING_TILE); $cal = $cals[$lv % 6]; $own = pf_collection($lv, $cal); $cap = pf_box_capacity($lv);
    $want = ['hurt' => 5, 'charm' => 3, 'guard' => 3, 'heal' => 1, 'trick' => 1, 'item' => 1, 'soothe' => 0]; $box = []; $n = [];
    foreach ($own as $k) { $t = pf_tiles()[$k]['t']; if (($n[$t] ?? 0) < ($want[$t] ?? 0) && count($box) < $cap) { $box[] = $k; $n[$t] = ($n[$t] ?? 0) + 1; } }
    foreach ($own as $k) if (!in_array($k, $box, true) && count($box) < $cap) $box[] = $k;
    $max = 20 + 3 * $lv + 5 * $m;
    return ['hp' => $max, 'max_hp' => $max, 'stats' => $st, 'deck' => pf_player_deck($st, $cal, 1 + intdiv($lv, 12), [], [], [], true, $box), 'luck' => $m, 'calling' => $cal];
}
function pp_e(array $e): string { $o = []; foreach (['L', 'R', 'T', 'B'] as $k) $o[] = $k . ':' . ($e[$k][0] === 'flat' ? 'flat' : ($e[$k][0] === 'wild' ? 'WILD' : $e[$k][0] . '-' . $e[$k][1])); return implode(' ', $o); }
function pp_show(array $s): string
{
    $o = [];
    $o[] = sprintf('TURN %d | you HP %d/%d guard %d | creature "%s" (%s) DAMAGE %.1f/%.1f (full = it backs off)%s | creature intends: %s', min($s['turn'], PF_TURN_CAP), $s['me']['hp'], $s['me']['max'], $s['me']['block'], $s['foe']['name'], $s['size'], $s['fh']['now'], $s['fh']['max'], $s['cm'] > 0 ? sprintf(' CHARM %.1f/%.1f (full = won over)', $s['bar']['now'], $s['bar']['max']) : ' (no charm bar)', $s['foe']['intent'] ?? '-');
    $o[] = sprintf('Multipliers: your Hurt counts x%s on its damage bar, your Charm x%s on its charm bar. Guard shown is what you hold NOW; it resets when your next turn starts, so after the creature moves it reads 0 (it protected you during that move).', $s['hm'], $s['cm']);
    if ($s['over']) $o[] = 'FIGHT OVER: ' . $s['over'];
    $o[] = 'BOARD (x right, y down; x 0-' . (PFB_W - 1) . ', y 0-' . (PFB_H - 1) . '). Y=your piece, C=creature piece, ?=blank centre';
    for ($y = 0; $y < PFB_H; $y++) { $r = ''; for ($x = 0; $x < PFB_W; $x++) { $p = pfb_at($s, $x, $y); $r .= $p ? ($p['by'] === 'me' ? ' Y' : ($p['by'] === 'foe' ? ' C' : ' ?')) . $p['id'] : ' . '; } $o[] = '  ' . $r; }
    foreach ($s['pcs'] as $p) if (!($s['over'] && $p['by'] === 'none')) $o[] = sprintf('  piece #%d %s @%d,%d %s "%s" %s %d%s age %d (%s)', $p['id'], $p['by'] === 'me' ? 'YOURS' : ($p['by'] === 'foe' ? 'CREATURE' : 'BLANK'), $p['x'], $p['y'], $p['by'] === 'none' ? '-' : $p['tile']['t'], $p['tile']['n'], $p['tile']['tag'], $p['tile']['v'], ($p['tile']['m'] ?? '') ? ' [' . $p['tile']['m'] . ']' : '', $s['round'] - $p['born'], pp_e(pfb_edges($p['tile'])));
    if (!empty($s['start'])) $o[] = 'START PHASE: choose a hand piece and a side of the blank centre (L R T B) with `start`. The creature has already chosen without seeing you.';
    $o[] = 'YOUR HAND (index: name, type, value, tag, edges; legal cells x,y that CONNECT)';
    foreach ($s['me']['hand'] as $i => $t) {
        $cells = !empty($s['start']) ? [] : pfb_cells($s, $t, 'me');
        $marks = array_map(function ($c) use ($s, $i) {   // '!' = that placement's chain fires one of the CREATURE's Hurt pieces (it hurts you); dry run on a copy
            $w = $s; $r = pfb_play($w, [[$i, $c[0], $c[1]]], $s['turn'], null, true);
            $fires = false; foreach ($r['ev'] ?? [] as $e) if (($e['by'] ?? '') === 'foe' && ($e['t'] ?? '') === 'hurt' && isset($e['id'])) $fires = true;
            return $c[0] . ',' . $c[1] . ($fires ? '!' : '');
        }, $cells);
        $o[] = sprintf('  [%d] %s | %s %d | %s%s | %s | cells: %s', $i, $t['n'], $t['t'], $t['v'], $t['tag'], ($t['m'] ?? '') ? ' [' . $t['m'] . ']' : '', pp_e(pfb_edges($t)), $marks ? implode(' ', $marks) : 'none');
    }
    if (!empty($s['me']['held'])) { $g = $s['me']['held']; $o[] = 'SET-ASIDE GROUP (' . count($g['pcs']) . ' pieces): ' . implode(' + ', array_map(fn($p) => $p['tile']['n'] . '@' . $p['x'] . ',' . $p['y'], $g['pcs'])) . ' | places at top-left x,y in: ' . (implode(' ', array_map(fn($c) => $c[0] . ',' . $c[1], pfb_group_spots($s, $g))) ?: 'none'); }
    $o[] = 'A cell marked ! means that placement links into a creature Hurt piece, which fires and hurts you. Rules: one action a turn. A piece must make a linked joint (knob into hole of same family) unless nothing can. Flat edge fits anything but breaks the chain. Pieces expire after ' . PFB_LIFE . ' rounds. Draw pile ' . count($s['me']['draw']) . ', discard ' . count($s['me']['discard']) . '.';
    return implode("\n", $o);
}
function pp_events(array $ev): string
{
    $o = [];
    foreach ($ev as $e) { if (!empty($e['tick'])) { $o[] = sprintf('  POISON tick on the creature: +%d damage (no piece)', $e['v'] ?? 0); continue; } if (isset($e['connect'])) { $o[] = '  you set aside: ' . $e['n']; continue; } $o[] = sprintf('  %s %s "%s" %s %d%s%s', ($e['by'] ?? '?') === 'me' ? 'YOU' : 'CREATURE', !empty($e['root']) ? 'PLACED' : 'chain', $e['n'] ?? ($e['tag'] ?? ''), $e['t'] ?? '', $e['v'] ?? 0, !empty($e['combo']) ? ' COMBO ' . $e['combo'] : '', isset($e['barnow']) ? sprintf(' -> health %.1f charm %.1f hp %d', $e['fhnow'], $e['barnow'], $e['hpnow']) : ''); }
    return implode("\n", $o);
}
function pp_save(string $f, array $s, string $act, array $ev, ?string $err): void
{
    if ($err === null) file_put_contents($f, json_encode($s));
    $line = ['t' => time(), 'act' => $act, 'err' => $err, 'turn' => $s['turn'], 'hp' => $s['me']['hp'], 'fh' => round($s['fh']['now'], 1), 'bar' => round($s['bar']['now'], 1), 'over' => $s['over'],
        'chain' => count(array_filter($ev, fn($e) => isset($e['id']))), 'combos' => array_values(array_filter(array_map(fn($e) => $e['combo'] ?? null, $ev))), 'mode' => !empty($s['start']) ? 'start' : 'play'];
    file_put_contents($f . '.log', json_encode($line) . "\n", FILE_APPEND);
}
function pp_int($v, int $min, int $max, string $what): int
{
    if ($v === null || !preg_match('/^-?\d+$/', (string)$v)) { fwrite(STDERR, "need a whole number for $what\n"); exit(1); }
    $n = (int)$v; if ($n < $min || $n > $max) { fwrite(STDERR, "$what must be $min..$max\n"); exit(1); }
    return $n;
}
function pp_side($v): string { $v = strtoupper((string)$v); if (!in_array($v, ['L', 'R', 'T', 'B'], true)) { fwrite(STDERR, "side must be L, R, T or B\n"); exit(1); } return $v; }
[, $cmd, $f] = $argv + [null, null, null];
if ($cmd === 'list') { $n = (int)($f ?? 200); foreach (array_slice(pp_creatures(), 0, $n) as $c) echo "{$c['slug']} {$c['size']} L{$c['level']}\n"; exit; }
if ($cmd === 'new') {
    $slug = $argv[3] ?? ''; $lv = pp_int($argv[4] ?? null, 1, 100, 'LEVEL'); $seed = pp_int($argv[5] ?? null, 0, PHP_INT_MAX, 'SEED'); $mode = $argv[6] ?? 'classic'; $all = pp_creatures();
    if (!in_array($mode, ['classic', 'blank'], true)) { fwrite(STDERR, "mode must be classic or blank\n"); exit(1); }
    if (!isset($all[$slug])) { fwrite(STDERR, "unknown creature (use list)\n"); exit(1); }
    $s = pfb_new(pp_player($lv), $all[$slug], $seed, $mode === 'blank' ? ['blank' => true] : []);
    file_put_contents($f, json_encode($s)); @unlink($f . '.log'); echo pp_show($s) . "\n"; exit;
}
if (!$f || !is_file($f)) { fwrite(STDERR, "no state file\n"); exit(1); }
$s = json_decode(file_get_contents($f), true); $a = array_slice($argv, 3); $ev = []; $err = null;
switch ($cmd) {
    case 'show': echo pp_show($s) . "\n"; exit;
    case 'start': $err = pfb_start($s, pp_int($a[0] ?? null, 0, 99, 'HANDIDX'), pp_side($a[1] ?? null)); break;
    case 'place': $r = pfb_play($s, [[pp_int($a[0] ?? null, 0, 99, 'HANDIDX'), pp_int($a[1] ?? null, -99, 99, 'X'), pp_int($a[2] ?? null, -99, 99, 'Y')]], $s['turn']); break;
    case 'join': $r = pfb_play($s, [['j', pp_int($a[0] ?? null, 0, 99, 'A'), pp_int($a[1] ?? null, 0, 99, 'B'), pp_side($a[2] ?? null)]], $s['turn']); break;
    case 'add': $r = pfb_play($s, [['h', pp_int($a[0] ?? null, 0, 99, 'B'), pp_int($a[1] ?? null, 0, 99, 'ANC'), pp_side($a[2] ?? null)]], $s['turn']); break;
    case 'group': $r = pfb_play($s, [['c', pp_int($a[0] ?? null, -99, 99, 'X'), pp_int($a[1] ?? null, -99, 99, 'Y')]], $s['turn']); break;
    case 'pass': $r = pfb_pass($s, $s['turn']); break;
    default: fwrite(STDERR, "unknown command\n"); exit(1);
}
if (isset($r)) { $ev = $r['ev']; $err = $r['err']; }
if ($err !== null) { pp_save($f, $s, $cmd . ' ' . implode(' ', $a), [], $err); echo "REFUSED: $err\n(nothing changed)\n"; exit(2); }
pp_save($f, $s, $cmd . ' ' . implode(' ', $a), $ev, null);
if ($cmd === 'start') { $cx = intdiv(PFB_W, 2); $cy = intdiv(PFB_H, 2); $sd = ['-1,0' => 'L', '1,0' => 'R', '0,-1' => 'T', '0,1' => 'B']; $o = [];
    foreach ($s['pcs'] as $p) if ($p['by'] !== 'none') $o[] = ($p['by'] === 'me' ? 'YOU' : 'CREATURE') . ' put "' . $p['tile']['n'] . '" (' . $p['tile']['t'] . ' ' . $p['tile']['v'] . ') on side ' . ($sd[($p['x'] - $cx) . ',' . ($p['y'] - $cy)] ?? '?');
    $ev = []; echo "START (nothing fires; turn 1 is your next action; the blank vanishes at the end of turn 1):\n  " . implode("\n  ", $o) . "\n\n" . pp_show($s) . "\n"; exit; }
$notes = [];
if (!empty($s['cut'])) $notes[] = 'CHAIN STOPPED: the fight ended mid-chain; ' . $s['cut'] . ' linked piece(s) did not fire.';
if (!empty($s['gone'])) $notes[] = 'EXPIRED at the end of the round (3 rounds old): ' . implode(', ', array_map(fn($g) => ($g['by'] === 'me' ? 'yours ' : 'creature ') . '"' . $g['tile']['n'] . '"', $s['gone'])) . '.';
if (!empty($s['reshuf'])) $notes[] = 'RESHUFFLE: ' . implode(' and ', array_unique(array_map(fn($w) => $w === 'me' ? 'your' : "the creature's", $s['reshuf']))) . ' draw pile was refilled from its discard.';
echo "WHAT HAPPENED:\n" . pp_events($ev) . ($notes ? "\n" . implode("\n", array_map(fn($n) => '  ' . $n, $notes)) : '') . "\n\n" . pp_show($s) . "\n";
