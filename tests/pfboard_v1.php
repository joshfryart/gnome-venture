<?php
// The v1 board rules (2.6.74, admin setting pfight_v1): one block of checks per rule, flag-off parity, and whole fights with invariants. No DB, no server.
// php tests/pfboard_v1.php      Every check names its scenario and prints what it got when it fails.
require __DIR__ . '/../game/includes/pfboard.php';
$GLOBALS['PFB_TEST_SIZES'] = ['small' => [5, 4], 'medium' => [5, 5], 'large' => [7, 5], 'boss' => [7, 6]];   // 2.6.94: the game's boards are 4x4 now; this file tests the engine on the old geometry
require __DIR__ . '/../game/includes/pfight_game.php';
$bad = 0; $warn = [];
set_error_handler(function (int $no, string $msg, string $file, int $line) use (&$warn) { $warn[] = "$msg ($file:$line)"; return true; });   // any PHP warning or notice in the engine fails the run (the last check)
const V1_OLD = ['env' => 0, 'ground' => 1, 'events' => 1];   // the 2.6.74 terrain (ground cells, forecast events): what a fight started before 2.6.75 carries
function chk(string $name, bool $ok, $got = ''): void { global $bad; echo ($ok ? 'ok   ' : 'FAIL ') . $name . ($ok ? '' : ' (got ' . (is_string($got) ? $got : json_encode($got)) . ')') . "\n"; if (!$ok) $bad++; }
function v1_me(int $lv = 8): array
{
    $m = max(0, intdiv($lv + 3, 14)); $st = ['grit' => $m, 'nimble' => $m, 'hardiness' => $m, 'charm' => $m, 'lore' => $m, 'luck' => $m, 'level' => $lv];
    $max = 20 + 3 * $lv + 5 * $m;
    return ['hp' => $max, 'max_hp' => $max, 'stats' => $st, 'deck' => pf_player_deck($st, 'thornblade', 1, [['swap' => 'dodge', 'n' => 'Wolf', 't' => 'guard', 'v' => 5, 'r' => 'mind']], pf_unlocks($lv)), 'luck' => $m];
}
function v1_foe(string $size, int $lv = 8, string $slug = 'test-thing'): array { return ['slug' => $slug, 'name' => 'Test Thing', 'size' => $size, 'level' => $lv, 'dmg_die' => ['small' => 4, 'medium' => 6, 'large' => 8, 'boss' => 10][$size], 'dmg_bonus' => intdiv($lv, 4)]; }
/** A v1 fight with an empty board, no ground, no forecast and no aim: the checks put down exactly what they need. */
function v1_bare(string $size = 'medium', array $over = [], int $seed = 7): array
{
    $s = pfb_new(v1_me(), v1_foe($size), $seed, ['v1' => $over ?: true]);
    $s['pcs'] = []; $s['cell'] = []; $s['ter'] = []; $s['envs'] = []; $s['foe']['plan'] = null; $s['spent'] = [];
    return $s;
}
/** A piece as the v1 rules make it (source, life, authored edges). */
function v1_tile(array $s, string $k, string $t, int $v, ?string $r, string $src = 'knack', array $extra = []): array
{
    return pfb_v1_tile(['k' => $k, 'n' => ucfirst($k), 't' => $t, 'v' => $v, 'r' => $r, 'tag' => '', 'm' => '', 'src' => $src] + $extra, $s['v1']);
}
function v1_put(array &$s, string $who, array $tile, int $x, int $y): int
{
    $id = ++$s['pid']; $s['seq']++;
    $s['pcs'][$id] = ['id' => $id, 'by' => $who, 'tile' => $tile, 'x' => $x, 'y' => $y, 'born' => $s['round'], 'seq' => $s['seq']];
    $s['cell']["$x,$y"] = $id;
    return $id;
}
/** Place a tile for $who through the engine (its chain fires, use-up applies). */
function v1_place(array &$s, string $who, array $tile, int $x, int $y): ?array { $s[$who]['hand'] = [$tile]; return pfb_place($s, $who, 0, $x, $y); }
/** An environment piece as the deck makes it; $wild = every edge wild, so it links whatever stands next to it (the checks then need no matching families). */
function v1_env(string $kind, ?string $dir = null, bool $wild = true): array
{
    foreach (pfb_env_deck('boss') as $t) if ($t['env'] === $kind) {
        if ($wild) $t['ed'] = ['L' => ['wild', null], 'R' => ['wild', null], 'T' => ['wild', null], 'B' => ['wild', null]];
        if ($dir !== null) $t['dir'] = $dir;
        return $t;
    }
    throw new RuntimeException("no environment piece of kind $kind");
}
function v1_strip(array $s): array { unset($s['nonce']); return $s; }
$rows = []; $die = ['small' => 4, 'medium' => 6, 'large' => 8, 'boss' => 10];
foreach (file(__DIR__ . '/../game/includes/data/creatures.txt', FILE_IGNORE_NEW_LINES) as $l) {
    if ($l === '' || $l[0] === '#') continue; $c = explode('|', $l); if (count($c) < 7) continue;
    $lv = max(1, (int)$c[4]); $rows[] = ['slug' => $c[0], 'name' => $c[1], 'size' => $c[2], 'level' => $lv, 'dmg_die' => $die[$c[2]] ?? 6, 'dmg_bonus' => intdiv($lv, 4)];
}

echo "== 0. flag off: exactly the old rules\n";
$a = pfb_new(v1_me(), v1_foe('large'), 41, ['blank' => true]); $b = pfb_new(v1_me(), v1_foe('large'), 41, ['blank' => true, 'v1' => false]);
chk('opt v1 = false starts the same fight as no opt', v1_strip($a) === v1_strip($b));
chk('an old fight has no v1 state (v1, w, h, ter, envs, envlog, reaim, env)', !array_intersect(array_keys($a), ['v1', 'w', 'h', 'ter', 'envs', 'envlog', 'reaim', 'env']) && !isset($a['me']['flipt']) && !array_key_exists('plan', $a['foe']), array_keys($a));
chk('an old fight is 7x5 for a large creature and for a boss', pfb_w($a) === 7 && pfb_h($a) === 5 && pfb_view(pfb_new(v1_me(), v1_foe('boss'), 3))['h'] === 5);
chk('old tiles carry no source, life or authored edges', !array_filter(array_merge($a['me']['hand'], $a['me']['draw'], $a['foe']['hand'], $a['foe']['draw']), fn($t) => isset($t['src']) || isset($t['ed']) || isset($t['life'])));
$v = pfb_view($a); chk('the old view has no v1 keys', !isset($v['v1']) && !isset($v['env']) && !isset($v['ter']) && !isset($v['aim']) && !isset($v['hand'][0]['life']));
pfb_start($a, 0, 'L'); pfb_start($b, 0, 'L'); $same = true; $noEnv = true; $rp = false; $t = 0;
while (!$a['over'] && $t++ < 40) {
    if ($t <= 3) foreach (array_keys($a['me']['hand']) as $hi) foreach (pfb_cell_preview($a, $hi) as $cell) if (array_key_exists('rp', $cell)) $rp = true;
    $m = pfb_search($a, 'me'); $ra = $m ? pfb_play($a, [[$m[0], $m[1], $m[2]]], $a['turn']) : pfb_pass($a, $a['turn']);
    if ($t === 3) $b = json_decode(json_encode($b), true);   // a saved fight comes back from JSON
    $rb = $m ? pfb_play($b, [[$m[0], $m[1], $m[2]]], $b['turn']) : pfb_pass($b, $b['turn']);
    foreach ($ra['ev'] as $e) if (($e['by'] ?? '') === 'env' || isset($e['used']) || isset($e['sun']) || isset($e['tw'])) $noEnv = false;
    if (json_encode($ra) !== json_encode($rb) || $a['over'] !== $b['over']) $same = false;
}
chk('a whole old fight: the same events with opt v1 = false, also after a save and load mid-fight', $same && $a['over'] !== null, (string)$a['over']);
chk('an old fight has no terrain events, no use-up, no sunny or Teamwork marks', $noEnv);
chk('the old lit-cell numbers still carry the reply number (rp)', $rp);
$o = pfb_new(v1_me(), v1_foe('medium'), 5);
chk('flip is refused in an old fight (engine and action)', pfb_flip($o, 0, $o['turn']) !== null && pfb_play($o, [['f', 0]], $o['turn'])['err'] === 'Those moves are not valid.' && !pfb_can_flip($o, 0));
chk('old creature values and bars use PFB_FOE_MULT / PFB_BAR_MULT', $o['bar']['max'] === round(pf_new(v1_me(), v1_foe('medium'), 5)['bar']['max'] * PFB_BAR_MULT, 1));

echo "== 1. board size by creature size (the production sizes: 4 x 4 for every size since 2.6.94)\n";
$tsz = $GLOBALS['PFB_TEST_SIZES']; unset($GLOBALS['PFB_TEST_SIZES']);   // this section runs on the game's own sizes, the others on the old geometry
chk('every creature size has a 4 x 4 board', array_values(array_unique(array_map(fn($d) => $d[0] . 'x' . $d[1], PFB_SIZE))) === ['4x4']);
foreach (PFB_SIZE as $size => [$w, $h]) {
    $s = pfb_new(v1_me(), v1_foe($size), 9, ['v1' => true, 'blank' => true]); $bl = $s['pcs'][1];
    chk("$size: board {$w}x{$h}, the blank in the centre, the view says so", $s['w'] === $w && $s['h'] === $h && $bl['x'] === intdiv($w, 2) && $bl['y'] === intdiv($h, 2) && pfb_view($s)['w'] === $w && pfb_view($s)['h'] === $h, [$s['w'], $s['h'], $bl['x'], $bl['y']]);
    pfb_start($s, 0, 'R'); $t = $s['me']['hand'][0];
    chk("$size: no cell outside the board is legal", pfb_check($s, $t, $w, 0) === null && pfb_check($s, $t, 0, $h) === null && !array_filter(pfb_cells($s, $t), fn($c) => $c[0] >= $w || $c[1] >= $h));
}
$s = pfb_new(v1_me(), v1_foe('small'), 9, ['v1' => true]);
chk('classic opening (no blank): the creature starts in the centre of its own board', isset($s['cell']['2,2']) && count($s['pcs']) === 1, array_keys($s['cell']));

$GLOBALS['PFB_TEST_SIZES'] = $tsz;
echo "== 2. ground: sunny, bramble, mud (a fight started under 2.6.74: v1 without env; new fights have environment pieces, section 13)\n";
foreach (PFB_GROUND as $size => [$ns, $nb, $nm]) {
    $ok = true; $got = null;
    for ($seed = 1; $seed <= 30; $seed++) {
        $s = pfb_new(v1_me(), v1_foe($size), $seed, ['v1' => V1_OLD, 'blank' => true]); $n = array_count_values($s['ter']); $cx = intdiv($s['w'], 2); $cy = intdiv($s['h'], 2);
        if (($n['sun'] ?? 0) !== $ns || ($n['br'] ?? 0) !== $nb || ($n['mud'] ?? 0) !== $nm) { $ok = false; $got = $n; }
        foreach ($s['ter'] as $k => $kind) { [$x, $y] = array_map('intval', explode(',', $k)); $d = abs($x - $cx) + abs($y - $cy); if ($d < 1 || $d > 2 || $x < 0 || $y < 0 || $x >= $s['w'] || $y >= $s['h']) { $ok = false; $got = $k; } }
    }
    chk("$size: $ns sunny, $nb bramble, $nm mud, all 1-2 steps from the centre (30 seeds)", $ok, $got);
}
$s = v1_bare('medium', V1_OLD); $guard = v1_tile($s, 'g1', 'guard', 3, 'body'); $swing = v1_tile($s, 'h1', 'hurt', 5, 'mind');
$s = v1_bare('medium', V1_OLD); v1_put($s, 'foe', v1_tile($s, 'c1', 'charm', 3, 'body'), 2, 2); $plain = v1_place($s, 'me', $swing, 3, 2);
$s2 = v1_bare('medium', V1_OLD); v1_put($s2, 'foe', v1_tile($s2, 'c1', 'charm', 3, 'body'), 2, 2); $s2['ter']['3,2'] = 'sun'; $sunny = v1_place($s2, 'me', $swing, 3, 2);
chk('sunny: a Hurt piece on a sunny cell counts double (and says so)', $plain && $sunny && $sunny[0]['v'] === 2 * $plain[0]['v'] && ($sunny[0]['sun'] ?? 0) === 1 && !isset($plain[0]['sun']), [$plain[0]['v'] ?? null, $sunny[0]['v'] ?? null]);
$s3 = v1_bare('medium', V1_OLD); v1_put($s3, 'foe', v1_tile($s3, 'c1', 'charm', 3, 'body'), 2, 2); $s3['ter']['3,2'] = 'sun'; $g = v1_place($s3, 'me', v1_tile($s3, 'g2', 'guard', 4, 'body'), 3, 2);
chk('sunny: a Guard piece does not count double', $g && $g[0]['v'] === 4 && !isset($g[0]['sun']), $g[0]['v'] ?? null);
$s4 = v1_bare('medium', V1_OLD); v1_put($s4, 'me', v1_tile($s4, 'c1', 'charm', 3, 'body'), 2, 2); $s4['ter']['3,2'] = 'sun'; $hp0 = $s4['me']['hp']; $f = v1_place($s4, 'foe', v1_tile($s4, 'f:x', 'hurt', 4, 'mind', 'creature'), 3, 2);
chk('sunny works for the creature too: its Hurt piece hits for double', $f && $f[0]['v'] === 8 && $hp0 - $s4['me']['hp'] === 8, [$f[0]['v'] ?? null, $hp0 - $s4['me']['hp']]);
$s5 = v1_bare('medium', V1_OLD); v1_put($s5, 'foe', v1_tile($s5, 'c1', 'charm', 3, 'body'), 2, 2); $s5['ter']['3,2'] = 'mud';
$j = pfb_check($s5, $swing, 3, 2); $j0 = pfb_check($s2, v1_tile($s2, 'h9', 'hurt', 5, 'mind'), 1, 2);
chk('mud: a piece on mud fits but does not link (the same joint links on other ground)', $j !== null && !pfb_has_link($j) && pfb_has_link($j0), [$j, $j0]);
chk('mud: while another spot links, the mud spot is not offered', !in_array([3, 2], pfb_cells($s5, $swing, 'me'), true) && in_array([3, 2], pfb_cells($s5, $swing), true));
$s6 = v1_bare('medium', V1_OLD); v1_put($s6, 'foe', v1_tile($s6, 'c1', 'charm', 3, 'body'), 2, 2); $s6['ter']['2,2'] = 'mud'; $j = pfb_check($s6, $swing, 3, 2); $m = v1_place($s6, 'me', $swing, 3, 2);
chk('mud: no link INTO a piece on mud either, so no chain runs through it (only your piece fires)', $j !== null && !pfb_has_link($j) && $m && count($m) === 1 && ($m[0]['linked'] ?? -1) === 0, [$j, count($m ?? [])]);
$s7 = v1_bare('medium', V1_OLD); $s7['ter']['3,2'] = 'br'; $s7['ter']['1,1'] = 'br'; v1_put($s7, 'me', $swing, 3, 2); v1_put($s7, 'foe', $guard, 1, 1); $hp0 = $s7['me']['hp']; $fh0 = $s7['fh']['now'];
pfb_env_turn($s7); $want = max(1, (int)round(PFB_BRAMBLE * $s7['me']['max']));
chk('bramble: at the end of the round a piece on bramble costs its owner 10% of max health (you and the creature)', $hp0 - $s7['me']['hp'] === $want && abs($s7['fh']['now'] - $fh0 - PFB_BRAMBLE * $s7['fh']['max']) < 1e-9, [$hp0 - $s7['me']['hp'], $s7['fh']['now'] - $fh0]);
$ev = pfb_env_events($s7);
chk('bramble: the terrain turn reports it as an event note (by env, ta env, what each side lost, the pieces)', count($ev) === 1 && $ev[0]['by'] === 'env' && $ev[0]['ta'] === 'env' && $ev[0]['env'] === 'bramble' && $ev[0]['me'] === $want && count($ev[0]['ids']) === 2 && str_contains(pfight_line($ev[0], 'Test Thing'), 'Bramble'), $ev);
$s8 = v1_bare('medium', ['ground' => 0] + V1_OLD); chk('rule switch ground = 0: no ground cells', pfb_new(v1_me(), v1_foe('medium'), 3, ['v1' => ['ground' => 0] + V1_OLD])['ter'] === []);

echo "== 3. the terrain turn and forecast events\n";
$okN = true; $okNear = true; $kinds = [];
foreach (['small', 'medium', 'large', 'boss'] as $size) for ($seed = 1; $seed <= 25; $seed++) {
    $s = pfb_new(v1_me(), v1_foe($size), $seed, ['v1' => V1_OLD, 'blank' => true]); pfb_start($s, 0, 'LRTB'[$seed % 4]);
    for ($t = 0; $t < 4 && !$s['over']; $t++) {
        if (count($s['envs']) > PFB_EVENTS[$size]) $okN = false;
        foreach ($s['envs'] as $e) {
            $kinds[$e['kind']] = 1; $near = false;
            foreach ($s['pcs'] as $p) if (abs($p['x'] - $e['x']) + abs($p['y'] - $e['y']) <= 1) $near = true;
            if (!$near || $e['x'] < 0 || $e['y'] < 0 || $e['x'] >= $s['w'] || $e['y'] >= $s['h']) $okNear = false;
            if ($e['kind'] === 'gust' && (!isset(PFB_SIDE[$e['dir']]) || !isset($s['cell'][$e['x'] . ',' . $e['y']]))) $okNear = false;
        }
        $m = pfb_search($s, 'me'); if (!$m) break; pfb_play($s, [[$m[0], $m[1], $m[2]]], $s['turn']);
    }
}
chk('forecast: at most 1 event a round on a small board, 2 on the others', $okN);
chk('forecast: every mark is on or next to a piece and on the board; a gust marks a piece and has a direction', $okNear);
chk('forecast: all five kinds turn up (sunbeam, creep, puddle, gust, thorn)', count($kinds) === 5, array_keys($kinds));
$s = v1_bare('medium', V1_OLD); $s['ter'] = ['1,1' => 'sun', '3,3' => 'sun', '1,3' => 'sun']; $s['envs'] = [['kind' => 'sunbeam', 'x' => 3, 'y' => 2, 'dir' => null]]; pfb_env_turn($s);
chk('sunbeam: the cell turns sunny and the OLDEST sunny cell fades (the count stays)', $s['ter'] === ['3,3' => 'sun', '1,3' => 'sun', '3,2' => 'sun'], $s['ter']);
$s = v1_bare('medium', V1_OLD); $s['ter'] = ['1,1' => 'br', '3,3' => 'br']; v1_put($s, 'me', $swing, 3, 2); $hp0 = $s['me']['hp']; $s['envs'] = [['kind' => 'creep', 'x' => 3, 'y' => 2, 'dir' => null]]; pfb_env_turn($s);
chk('bramble creep: the cell turns to bramble and pricks at once; the oldest bramble withers', $s['ter'] === ['3,3' => 'br', '3,2' => 'br'] && $hp0 - $s['me']['hp'] === max(1, (int)round(PFB_BRAMBLE * $s['me']['max'])), [$s['ter'], $hp0 - $s['me']['hp']]);
$s = v1_bare('medium', V1_OLD); $s['ter'] = ['1,1' => 'mud']; v1_put($s, 'foe', v1_tile($s, 'c1', 'charm', 3, 'body'), 2, 2); $s['envs'] = [['kind' => 'puddle', 'x' => 3, 'y' => 2, 'dir' => null]]; pfb_env_turn($s);
chk('puddle: the cell turns to mud (links there are cut) and the old mud dries', $s['ter'] === ['3,2' => 'mud'] && !pfb_has_link(pfb_check($s, $swing, 3, 2)), $s['ter']);
$s = v1_bare('medium', V1_OLD); $id = v1_put($s, 'me', $swing, 2, 2); $s['envs'] = [['kind' => 'gust', 'x' => 2, 'y' => 2, 'dir' => 'R']]; pfb_env_turn($s);
chk('gust: the piece moves one cell along the arrow', $s['pcs'][$id]['x'] === 3 && $s['pcs'][$id]['y'] === 2 && ($s['cell']['3,2'] ?? 0) === $id && !isset($s['cell']['2,2']) && ($s['envlog'][0]['moved']['id'] ?? 0) === $id, $s['cell']);
$s = v1_bare('medium', V1_OLD); $id = v1_put($s, 'me', $swing, 2, 2); v1_put($s, 'foe', $guard, 3, 2); $s['envs'] = [['kind' => 'gust', 'x' => 2, 'y' => 2, 'dir' => 'R']]; pfb_env_turn($s);
chk('gust: it does not move when the cell is taken', $s['pcs'][$id]['x'] === 2 && !isset($s['envlog'][0]['moved']));
$s = v1_bare('medium', V1_OLD); $id = v1_put($s, 'me', $swing, 0, 2); $s['envs'] = [['kind' => 'gust', 'x' => 0, 'y' => 2, 'dir' => 'L']]; pfb_env_turn($s);
chk('gust: it does not push a piece off the board', $s['pcs'][$id]['x'] === 0);
$s = v1_bare('medium', V1_OLD); v1_put($s, 'me', $swing, 2, 2); v1_put($s, 'foe', $guard, 3, 2); v1_put($s, 'foe', $guard, 2, 1); v1_put($s, 'me', $swing, 4, 4); $hp0 = $s['me']['hp']; $fh0 = $s['fh']['now'];
$s['envs'] = [['kind' => 'thorn', 'x' => 2, 'y' => 2, 'dir' => null]]; pfb_env_turn($s);
chk('thorn burst: each of your pieces on the cell or next to it costs 10% of your health; pieces further away are safe', $hp0 - $s['me']['hp'] === max(1, (int)round(PFB_THORN * $s['me']['max'])), $hp0 - $s['me']['hp']);
chk('thorn burst: event damage on the creature is halved (5% of its health for each of its pieces)', abs($s['fh']['now'] - $fh0 - 2 * PFB_THORN * PFB_EVENT_FOE * $s['fh']['max']) < 1e-9, $s['fh']['now'] - $fh0);
$s = v1_bare('medium', V1_OLD); $s['ter'] = ['2,2' => 'br']; v1_put($s, 'me', $swing, 2, 2); $s['me']['hp'] = 1; pfb_env_turn($s);
chk('the terrain can end the fight (bramble takes your last health: defeat)', $s['over'] === 'defeat');
// in a real turn: the events come after the creature's, in the order announced, then bramble
$found = null;
for ($seed = 1; $seed <= 40 && !$found; $seed++) {
    $s = pfb_new(v1_me(), v1_foe('large'), $seed, ['v1' => V1_OLD, 'blank' => true]); pfb_start($s, 0, 'L');
    for ($t = 0; $t < 5 && !$s['over']; $t++) {
        $ann = $s['envs']; $m = pfb_search($s, 'me'); if (!$m) break; $r = pfb_play($s, [[$m[0], $m[1], $m[2]]], $s['turn']);
        $env = array_values(array_filter($r['ev'], fn($e) => ($e['by'] ?? '') === 'env' && $e['env'] !== 'bramble'));
        if (count($ann) === 2 && !$s['over']) { $found = [$ann, $env, $r['ev']]; break; }
    }
}
$tas = array_map(fn($e) => $e['ta'], $found[2]); $lastFoe = max(array_keys($tas, 'foe') ?: [-1]); $firstEnv = min(array_keys($tas, 'env') ?: [999]);
chk('a real turn: both announced events land, in order, as event notes after the creature\'s move', $found && array_column($found[1], 'env') === array_column($found[0], 'kind') && array_column($found[1], 'x') === array_column($found[0], 'x') && $firstEnv > $lastFoe, [$tas]);
chk('a real turn: every event carries ta (me, foe or env) and the bars after it', !array_filter($found[2], fn($e) => !in_array($e['ta'] ?? '', ['me', 'foe', 'env'], true)) && !array_filter($found[2], fn($e) => $e['ta'] === 'env' && !isset($e['hpnow'], $e['fhnow'], $e['barnow'])));
chk('terrain events have a log line and a history chip, and stay out of the chain chips', !array_filter($found[2], fn($e) => $e['ta'] === 'env' && (pfight_line($e, 'X') === '' || pfight_chip_event($e)['by'] !== 'env')) && !array_filter(pfight_chips_board($found[2]), fn($c) => $c['by'] === 'env'));
chk('rule switch events = 0: nothing is forecast', pfb_new(v1_me(), v1_foe('large'), 4, ['v1' => ['events' => 0] + V1_OLD])['envs'] === []);

echo "== 4. use-up: a chain of 3+ spends the pieces that fired (both sides)\n";
// a row: charm (R knob body) -> hurt (L hole body, R knob mind) -> charm (L hole mind)
$mkRow = function (array $over = []) use ($swing) { $s = v1_bare('medium', $over); $a = v1_put($s, 'me', v1_tile($s, 'c1', 'charm', 3, 'body'), 1, 2); $b = v1_put($s, 'foe', v1_tile($s, 'f:c2', 'charm', 3, 'craft', 'creature'), 3, 2); return [$s, $a, $b]; };
[$s, $a, $b] = $mkRow(); $d0 = [count($s['me']['discard']), count($s['foe']['discard'])]; $ev = v1_place($s, 'me', $swing, 2, 2);
chk('a chain of 3 fired pieces uses all 3 up: the board is empty, each piece is in its owner\'s discard', $ev && count($ev) === 3 && $s['pcs'] === [] && $s['cell'] === [] && count($s['me']['discard']) === $d0[0] + 2 && count($s['foe']['discard']) === $d0[1] + 1, [count($ev ?? []), array_keys($s['pcs'])]);
chk('the first event of the chain lists the ids it used up, and they are reported as gone (used by me)', count($ev[0]['used'] ?? []) === 3 && count($s['spent']) === 3 && !array_filter($s['spent'], fn($p) => ($p['used'] ?? '') !== 'me'), $ev[0]['used'] ?? null);
$s = v1_bare(); $a = v1_put($s, 'me', v1_tile($s, 'c1', 'charm', 3, 'body'), 1, 2); $ev = v1_place($s, 'me', $swing, 2, 2);
chk('a chain of 2 uses nothing up', $ev && count($ev) === 2 && count($s['pcs']) === 2 && !isset($ev[0]['used']), count($s['pcs']));
[$s, $a, $b] = $mkRow(); $s['pcs'][$a]['by'] = 'foe'; $s['pcs'][$a]['tile']['k'] = 'f:c1'; $s['pcs'][$b]['by'] = 'me'; $ev = v1_place($s, 'foe', v1_tile($s, 'f:h', 'hurt', 2, 'mind', 'creature'), 2, 2);
chk('the creature\'s chain of 3 uses pieces up too (yours included)', $ev && count($ev) === 3 && $s['pcs'] === [] && !array_filter($s['spent'], fn($p) => ($p['used'] ?? '') !== 'foe'), array_keys($s['pcs']));
[$s, $a, $b] = $mkRow(['limit' => 0]); $ev = v1_place($s, 'me', $swing, 2, 2);
chk('rule switch limit = 0: your pieces stay (only the creature\'s fire budget applies)', $ev && count($ev) === 3 && isset($s['pcs'][$a]) && !isset($ev[0]['used']), array_keys($s['pcs']));
[$s, $a, $b] = $mkRow(['limit' => 4]); $ev = v1_place($s, 'me', $swing, 2, 2);
chk('rule switch limit = 4: a chain of 3 uses nothing up', $ev && count($s['pcs']) === 3);

echo "== 5. aim: the creature shows its next piece and cell\n";
$played = 0; $re = 0; $wrong = 0; $noAim = 0; $taken = 0; $takenFull = 0; $rpKey = 0; $pvOk = 0; $pvN = 0;
foreach (['small', 'medium', 'large', 'boss'] as $size) for ($seed = 1; $seed <= 12; $seed++) {
    $s = pfb_new(v1_me(), v1_foe($size), $seed, ['v1' => true, 'blank' => true]); pfb_start($s, $seed % 3, 'LRTB'[$seed % 4]);
    for ($t = 0; $t < 6 && !$s['over']; $t++) {
        $aim = $s['foe']['plan']; if (!$aim) { $noAim++; }
        if ($aim && pfb_view($s)['aim'] !== $aim) $wrong++;
        if ($t === 1) foreach (pfb_cell_preview($s, 0) as $key => $cell) { $pvN++; if (array_key_exists('rp', $cell)) $rpKey++; if (isset($cell['dmg'], $cell['ch'], $cell['hp'], $cell['n'], $cell['used'], $cell['tw'], $cell['sun'], $cell['end'])) $pvOk++; }
        // take its cell when a piece of yours fits there (every third turn), else play the best move
        $mv = null; if ($aim && $t % 3 === 2) foreach ($s['me']['hand'] as $i => $ht) if (pfb_check($s, $ht, $aim['x'], $aim['y']) !== null) { $mv = [$i, $aim['x'], $aim['y']]; break; }
        $block = $mv !== null; if (!$mv) { $m = pfb_search($s, 'me'); if (!$m) break; $mv = [$m[0], $m[1], $m[2]]; }
        $r = pfb_play($s, [$mv], $s['turn']); if ($r['err']) { if ($block) continue; break; }
        $foeRoot = null; foreach ($r['ev'] as $e) if (($e['ta'] ?? '') === 'foe' && !empty($e['root'])) $foeRoot = $e;
        if (!$aim || !$foeRoot) continue;
        if ($block && isset($s['cell']) && ($mv[1] === $aim['x'] && $mv[2] === $aim['y'])) { $taken++; $at = pfb_at($s, $aim['x'], $aim['y']); if (!empty($s['reaim']) || $s['over'] || !$at || $at['by'] === 'foe') $takenFull++; continue; }   // (your piece may have been used up by its own chain: then the cell is free again and the aim plays)
        if (!empty($s['reaim'])) $re++;
        else { $played++; $p = null; foreach ($r['ev'] as $e) if (isset($e['snap'], $e['id']) && ($e['ta'] ?? '') === 'foe') foreach ($e['snap'] as $q) if ($q['id'] === $e['id'] && $p === null) $p = $q; /* the FIRST piece it placed (a Quick piece may add a second) */ if ($foeRoot['k'] !== $aim['k'] || ($p && !array_filter($r['ev'], fn($e) => isset($e['moved'])) && ($p['x'] !== $aim['x'] || $p['y'] !== $aim['y']))) $wrong++;   /* (a Wind in the chain may push the piece off its cell afterwards: that is the Wind, not a wrong aim) */ }
    }
}
chk('the aim is in the state and the view; when the creature plays its aim it is that piece on that cell', $played > 40 && $wrong === 0, compact('played', 're', 'wrong', 'noAim'));
chk('take its cell and it picks again (reaim), it does not fumble or skip', $taken > 5 && $takenFull === $taken, compact('taken', 'takenFull'));
chk('the lit-cell numbers have no reply number, and carry your own chain: dmg, ch, hp, n, used, tw, sun, end', $pvN > 20 && $rpKey === 0 && $pvOk === $pvN, compact('pvN', 'rpKey', 'pvOk'));
$s = pfb_new(v1_me(), v1_foe('medium'), 3, ['v1' => ['aim' => 0], 'blank' => true]); pfb_start($s, 0, 'L');
chk('rule switch aim = 0: no aim is stored or shown', !isset($s['foe']['plan']) && pfb_view($s)['aim'] === null);
$s = v1_bare(); v1_put($s, 'me', v1_tile($s, 'c1', 'charm', 3, 'body'), 2, 2); $s['foe']['hand'] = [v1_tile($s, 'f:h', 'hurt', 3, 'mind', 'creature')]; $s['foe']['slow'] = 1; pfb_intent($s);
chk('a tripped creature shows no aim', $s['foe']['plan'] === null);

echo "== 6. Teamwork: pal / tool / crop pieces of yours in one chain\n";
$team = function (array $srcs, array $over = []) {   // a row of your pieces with these sources; the last one is placed and starts the chain. Returns its events.
    $s = v1_bare('medium', $over + ['limit' => 0]); $row = [['c1', 'charm', 3, 'body'], ['h1', 'hurt', 5, 'mind'], ['c2', 'charm', 4, 'body']];
    foreach ($srcs as $i => $src) { $t = v1_tile($s, $row[$i][0], $row[$i][1], $row[$i][2], $row[$i][3], $src, ['col' => 'body']); if ($i < count($srcs) - 1) v1_put($s, 'me', $t, 1 + $i, 2); else $ev = v1_place($s, 'me', $t, 1 + $i, 2); }
    return $ev;
};
$base = $team(['knack', 'knack']); $two = $team(['pal', 'tool']); $one = $team(['pal', 'pal']); $three = $team(['pal', 'tool', 'crop']); $three0 = $team(['knack', 'basic', 'calling']); $mixed = $team(['pal', 'region', 'crop']);
chk('2 of the 3 sources in one chain: +30% on your pieces (and the event says tw 1.3)', $two && $two[0]['v'] === (int)round($base[0]['v'] * PFB_TEAM2) && $two[1]['v'] === (int)round($base[1]['v'] * PFB_TEAM2) && $two[0]['tw'] === PFB_TEAM2, [array_column($base, 'v'), array_column($two, 'v')]);
chk('one source twice: no bonus', $one && array_column($one, 'v') === array_column($base, 'v') && !isset($one[0]['tw']));
chk('all 3 sources: +60%', $three && count($three) === 3 && $three[0]['v'] === (int)round($three0[0]['v'] * PFB_TEAM3) && $three[2]['v'] === (int)round($three0[2]['v'] * PFB_TEAM3) && $three[0]['tw'] === PFB_TEAM3, [array_column($three0, 'v'), array_column($three, 'v')]);
chk('pal + crop with a region piece between: still 2 sources, +30% on all three of your pieces', $mixed && ($mixed[1]['tw'] ?? 0) === PFB_TEAM2);
$s = v1_bare('medium', ['limit' => 0]); v1_put($s, 'foe', v1_tile($s, 'f:c', 'charm', 3, 'body', 'creature'), 1, 2); v1_put($s, 'me', v1_tile($s, 'c2', 'charm', 4, 'craft', 'tool', ['col' => 'body']), 3, 2); $ev = v1_place($s, 'me', v1_tile($s, 'h1', 'hurt', 5, 'mind', 'pal'), 2, 2);
$foeEv = array_values(array_filter($ev, fn($e) => $e['by'] === 'foe'));
chk('the creature\'s piece in your Teamwork chain gets no bonus', count($ev) === 3 && $foeEv && !isset($foeEv[0]['tw']) && $foeEv[0]['v'] === 3, array_column($ev, 'v'));
chk('default sources by origin: base six basic, calling piece calling, pal pieces pal, creature pieces creature, the rest knacks',
    pfb_src(['k' => 'swing']) === 'basic' && pfb_src(['k' => 'thorn']) === 'calling' && pfb_src(['k' => 'pal:Wolf']) === 'pal' && pfb_src(['k' => 'f:hit1']) === 'creature' && pfb_src(['k' => 'jab']) === 'knack' && pfb_src(['k' => 'jab', 'src' => 'tool']) === 'tool' && pfb_src(['k' => 'jab', 'src' => 'nonsense']) === 'knack');
$s = pfb_new(v1_me(), v1_foe('medium'), 3, ['v1' => true]); $all = array_merge($s['me']['hand'], $s['me']['draw'], $s['foe']['hand'], $s['foe']['draw'], array_column($s['pcs'], 'tile'));
chk('every piece of a v1 fight has a source from the list', !array_filter($all, fn($t) => !in_array($t['src'] ?? '', PFB_SRC, true)) && in_array('pal', array_column(array_merge($s['me']['hand'], $s['me']['draw']), 'src'), true) && in_array('creature', array_column($s['foe']['hand'], 'src'), true));
chk('pf_make_tile passes a piece\'s authored source, life and edges through from its definition', pf_make_tile('swing', ['level' => 1], 0, ['src' => 'tool', 'life' => 4, 'col' => 'craft'])['src'] === 'tool' && !isset(pf_make_tile('swing', ['level' => 1])['src']));

echo "== 7. authored edges\n";
$flat = 0; $badL = 0; $badCol = 0;
foreach ($all as $t) { $e = pfb_edges($t); foreach ($e as $side) if ($side[0] === 'flat') $flat++; if ($e['L'] !== ['hole', PF_HOLE[$t['t']]] || $e['R'][0] !== 'knob') $badL++; if ($e['T'][1] !== $e['B'][1] || $e['T'][0] === $e['B'][0] || ($e['T'][0] === 'knob') !== isset(PFB_UP[$t['t']])) $badCol++; }
chk('no flat edges; left = hole of the type family, right = a knob; top and bottom = one knob and one hole of one family; Hurt, Charm and Trick carry the knob on top', $flat === 0 && $badL === 0 && $badCol === 0, compact('flat', 'badL', 'badCol'));
$s = v1_bare(); $col = fn(string $src, string $t = 'hurt') => pfb_edges(v1_tile($s, 'x', $t, 3, 'body', $src))['T'][1];
chk('column family by source: pals body, tools craft, crops mind, crafts craft; other pieces their type family', $col('pal', 'charm') === 'body' && $col('tool') === 'craft' && $col('crop') === 'mind' && $col('craft') === 'craft' && $col('knack') === 'body' && $col('basic', 'charm') === 'mind' && $col('region', 'trick') === 'craft');
$sw = pf_make_tile('swing', ['level' => 1]); $jab = pf_make_tile('jab', ['level' => 1]); $dodge = pf_make_tile('dodge', ['level' => 1]); $brace = pf_make_tile('brace', ['level' => 1]);
[$sw, $jab, $dodge, $brace] = array_map(fn($t) => pfb_v1_tile($t, $s['v1']), [$sw, $jab, $dodge, $brace]);
chk('same type connects by design: Swing stacks on Jab, Dodge on Brace', pfb_joint(pfb_edges($sw)['B'], pfb_edges($jab)['T'])[1] && pfb_joint(pfb_edges($jab)['B'], pfb_edges($sw)['T'])[1] && pfb_joint(pfb_edges($dodge)['B'], pfb_edges($brace)['T'])[1]);
chk('one family, the other way up (Swing on Dodge): no fit as dealt', !pfb_joint(pfb_edges($sw)['B'], pfb_edges($dodge)['T'])[0]);
chk('the doc\'s table: Swing = hole body / knob mind / knob body / hole body', pfb_edges($sw) === ['L' => ['hole', 'body'], 'R' => ['knob', 'mind'], 'T' => ['knob', 'body'], 'B' => ['hole', 'body']], pfb_edges($sw));
chk('a piece with no knob family (Offer) gets a knob of its type family', pfb_edges(pfb_v1_tile(pf_make_tile('offer', ['level' => 1]), $s['v1']))['R'] === ['knob', 'mind']);
$auth = ['L' => ['hole', 'craft'], 'R' => ['knob', 'craft'], 'T' => ['knob', 'mind'], 'B' => ['knob', 'mind']];
chk('per-piece overrides: edges = all four, col + up = the column', pfb_edges(pfb_v1_tile($sw + ['edges' => $auth], $s['v1'])) === $auth && pfb_edges(pfb_v1_tile($sw + ['col' => 'craft', 'up' => false], $s['v1']))['T'] === ['hole', 'craft']);
$hashed = pfb_v1_tile(['edges' => false] + $sw, $s['v1']); $old = pf_make_tile('swing', ['level' => 1]);
chk('fallback: a piece with edges = false keeps the old hashed edges', !isset($hashed['ed']) && pfb_edges($hashed) === pfb_edges($old));
$s0 = pfb_new(v1_me(), v1_foe('medium'), 3, ['v1' => ['edges' => 0]]);
chk('rule switch edges = 0: every piece keeps the hashed edges and nothing flips', !array_filter(array_merge($s0['me']['hand'], $s0['foe']['hand']), fn($t) => isset($t['ed'])) && !pfb_can_flip($s0, 0) && pfb_view($s0)['v1']['flip'] === false);
$lean = []; foreach ([['class' => 'Critter'], ['class' => 'Water'], ['class' => 'Bird'], ['class' => 'Plant / Fungus'], ['class' => 'Reptile / Amphibian'], ['class' => 'Beast'], ['lean' => 'craft', 'class' => 'Beast']] as $cc) $lean[] = pfb_lean($cc + ['slug' => 'x']);
chk('class leans: Critter mind, Water body, Bird craft, Plant mind, Reptile craft, Beast body; a row\'s own lean wins', $lean === ['mind', 'body', 'craft', 'mind', 'craft', 'body', 'craft'], $lean);
$c = v1_foe('boss') + ['class' => 'Bird']; $s = pfb_new(v1_me(), $c, 3, ['v1' => true]); $deck = pf_foe_deck($c); $ft = []; foreach (array_merge($s['foe']['hand'], $s['foe']['draw'], array_column($s['pcs'], 'tile')) as $t) $ft[$t['k']] = $t;
$okLean = true; foreach ($deck as $i => $d) { $want = $i % 5 < 3 ? 'craft' : PF_HOLE[$d['t']]; if (pfb_edges($ft[$d['k']])['T'][1] !== $want) $okLean = false; }
chk('a creature: 3 pieces in 5 (deck order) stack in its lean family, the other 2 in their type family', $okLean && count($ft) === count($deck));
chk('a creature without a class still gets a lean, fixed by its slug', in_array(pfb_lean(['slug' => 'garden-snail']), ['body', 'mind', 'craft'], true) && pfb_lean(['slug' => 'garden-snail']) === pfb_lean(['slug' => 'garden-snail']));

echo "== 8. flip\n";
$s = pfb_new(v1_me(), v1_foe('medium'), 3, ['v1' => true, 'blank' => true]); pfb_start($s, 0, 'L'); $t0 = $s['me']['hand'][0]; $e0 = pfb_edges($t0); $turn = $s['turn'];
$err = pfb_flip($s, 0, $turn); $e1 = pfb_edges($s['me']['hand'][0]);
chk('flip swaps the top and bottom edges of the hand piece (left and right stay)', $err === null && $e1['T'] === $e0['B'] && $e1['B'] === $e0['T'] && $e1['L'] === $e0['L'] && $e1['R'] === $e0['R'], $err);
chk('it is free: the turn has not moved, the creature has not played', $s['turn'] === $turn && pfb_view($s)['flip'] === ['on' => true, 'used' => true] && pfb_view($s)['hand'][0]['flip'] === true);
chk('once a turn: a second piece cannot be flipped', pfb_flip($s, 1, $turn) !== null && !pfb_can_flip($s, 1) && pfb_view($s)['hand'][1]['canflip'] === false && empty($s['me']['hand'][1]['flip']));
chk('flipping the same piece back gives the flip back', pfb_flip($s, 0, $turn) === null && pfb_edges($s['me']['hand'][0]) === $e0 && pfb_can_flip($s, 1) && pfb_flip($s, 1, $turn) === null);
chk('a stale turn, a missing piece and a finished fight are refused', pfb_flip($s, 0, $turn + 1) === 'stale' && pfb_flip($s, 99, $turn) !== null && pfb_flip($s, -1, $turn) !== null);
$r = pfb_play($s, [['f', 1]], $turn); chk('the action [f, handIdx] through pfb_play: free (no creature turn), here it flips piece 1 back', $r['err'] === null && !empty($r['free']) && $r['ev'] === [] && $s['turn'] === $turn && empty($s['me']['hand'][1]['flip']), $r);
chk('a dry run of the flip changes nothing', pfb_play($s, [['f', 1]], $turn, null, true)['err'] === null && empty($s['me']['hand'][1]['flip']) && (int)$s['me']['flipt'] === 0);
// place a flipped piece: it stays flipped on the board, the next turn has a new flip, and it comes back the right way up
$done = false;
for ($seed = 1; $seed <= 60 && !$done; $seed++) {
    $s = pfb_new(v1_me(), v1_foe('medium'), $seed, ['v1' => ['limit' => 0, 'events' => 0, 'ground' => 0], 'blank' => true]); pfb_start($s, 0, 'L');
    foreach ($s['me']['hand'] as $i => $ht) {
        $w = $s; if (pfb_flip($w, $i, $w['turn']) !== null) continue; $cells = pfb_cells($w, $w['me']['hand'][$i], 'me'); if (!$cells) continue;
        $pv = pfb_cell_preview($s, $i, true); $key = $ht['k']; $turn = $w['turn'];
        $r = pfb_play($w, [[$i, $cells[0][0], $cells[0][1]]], $turn); if ($r['err'] || $w['over']) continue;
        $on = null; foreach ($w['pcs'] as $p) if ($p['by'] === 'me' && $p['tile']['k'] === $key) $on = $p;
        if (!$on) continue;
        $vp = null; foreach (pfb_view($w)['pcs'] as $q) if ($q['id'] === $on['id']) $vp = $q;
        chk('a flipped piece stays flipped on the board (state and view)', !empty($on['tile']['flip']) && $vp['flip'] === true && $vp['e']['T'] === pfb_edges($ht)['B']);
        chk('the flipped lit-cell numbers (pfb_cell_preview with flip) cover the flipped piece\'s cells', isset($pv[$cells[0][0] . ',' . $cells[0][1]]) && count($pv) === count($cells), [array_keys($pv), $cells]);
        chk('the next turn has its flip again', pfb_view($w)['flip']['used'] === false && pfb_can_flip($w, 0));
        for ($k = 0; $k < 6 && !$w['over']; $k++) { $m = pfb_search($w, 'me'); if (!$m) break; pfb_play($w, [[$m[0], $m[1], $m[2]]], $w['turn']); }
        foreach ($w['pcs'] as $p) if ($p['by'] === 'me' && $p['tile']['k'] === $key) pfb_discard($w, $p);   // the fight ended with it still out: it leaves the way every piece leaves
        $back = array_filter(array_merge($w['me']['discard'], $w['me']['draw'], $w['me']['hand']), fn($t) => $t['k'] === $key);
        chk('when it leaves the board it goes back the right way up', count($back) === 1 && empty(array_values($back)[0]['flip']) && !isset(array_values($back)[0]['ft']), $back);
        $done = true; break;
    }
}
chk('(a flipped placement was found to test)', $done);
// pass is refused while a flipped piece would fit
$s = v1_bare(); v1_put($s, 'foe', v1_tile($s, 'f:g', 'guard', 3, 'body', 'creature', ['col' => 'body']), 2, 2);   // guard: top = hole body, bottom = knob body, left = hole body, right = knob body
$s['me']['held'] = null;
$s['me']['hand'] = [v1_tile($s, 't1', 'trick', 3, 'craft', 'knack', ['col' => 'body', 'up' => true])]; $s['cell']['2,3'] = 99; $s['pcs'][99] = ['id' => 99, 'by' => 'foe', 'tile' => v1_tile($s, 'f:g2', 'guard', 3, 'body', 'creature', ['col' => 'craft']), 'x' => 2, 'y' => 3, 'born' => 1, 'seq' => 99];
// now: above the top guard my piece needs bottom = knob body (it has hole body as dealt: knob on top) -> only flipped. Left/right of the guards: my right knob craft vs hole body, my left hole craft vs knob body: no fit.
$dealt = pfb_cells($s, $s['me']['hand'][0]); $fl = $s['me']['hand'][0]; $fl['flip'] = true; $flc = pfb_cells($s, $fl);
chk('(scenario: the piece fits nowhere as dealt and somewhere flipped)', $dealt === [] && $flc !== [], [$dealt, $flc]);
chk('pass is refused while a piece fits when flipped', str_contains((string)pfb_pass($s, $s['turn'])['err'], 'flip'), pfb_pass($s, $s['turn'])['err']);

echo "== 9. piece life\n";
$s = v1_bare(); $life = fn(string $k, array $o = []) => pfb_v1_tile(pf_make_tile($k, ['level' => 1], 0, $o), $s['v1'])['life'];
chk('default life 3; Quick pieces (Jab) 2; Hold pieces (Brace) 4', $life('swing') === 3 && $life('jab') === 2 && $life('brace') === 4, [$life('swing'), $life('jab'), $life('brace')]);
chk('a piece\'s own life wins, kept inside 2-4', $life('swing', ['life' => 4]) === 4 && $life('swing', ['life' => 9]) === 4 && $life('jab', ['life' => 1]) === 2);
$s = v1_bare('medium', ['events' => 0, 'ground' => 0]); $s['foe']['hand'] = []; $s['foe']['draw'] = []; $s['foe']['discard'] = [];
$i2 = v1_put($s, 'me', v1_tile($s, 'a', 'guard', 1, 'body', 'knack', ['life' => 2]), 0, 0); $i3 = v1_put($s, 'me', v1_tile($s, 'b', 'guard', 1, 'body'), 2, 0); $i4 = v1_put($s, 'me', v1_tile($s, 'c', 'guard', 1, 'body', 'knack', ['life' => 4]), 4, 0);
$vp = array_column(pfb_view($s)['pcs'], null, 'id');
chk('the view gives each piece its life and the rounds it has left', [$vp[$i2]['life'], $vp[$i2]['left'], $vp[$i3]['life'], $vp[$i3]['left'], $vp[$i4]['life'], $vp[$i4]['left']] === [2, 2, 3, 3, 4, 4] && pfb_view($s)['hand'][0]['life'] >= 2, [$vp[$i2]['left'], $vp[$i3]['left'], $vp[$i4]['left']]);
$alive = [];
for ($r = 1; $r <= 4; $r++) { pfb_end_round($s); $alive[$r] = [isset($s['pcs'][$i2]), isset($s['pcs'][$i3]), isset($s['pcs'][$i4])]; }
chk('a life-2 piece is gone after 2 rounds, life 3 after 3, life 4 after 4', $alive === [1 => [true, true, true], 2 => [false, true, true], 3 => [false, false, true], 4 => [false, false, false]], $alive);
$s0 = v1_bare('medium', ['life' => 0]); chk('rule switch life = 0: every piece lives PFB_LIFE rounds', !isset($s0['me']['hand'][0]['life']) && pfb_life($s0, ['by' => 'me', 'tile' => ['life' => 2]]) === PFB_LIFE);

echo "== 10. creature values and bars by size\n";
foreach (['small', 'medium', 'large', 'boss'] as $size) {
    $c = v1_foe($size, 12); $base = pf_new(v1_me(12), $c, 5); $s = pfb_new(v1_me(12), $c, 5, ['v1' => true]);
    $fm = PFB_V1_FOE_MULT[$size] * ($size === 'boss' ? PFB_BOSS_MULT : 1.0) * PFB_FOE_FIRE_MULT; $want = []; foreach (pf_foe_deck($c) as $t) $want[$t['k']] = max(1, (int)round($t['v'] * $fm));
    $got = []; foreach (array_merge($s['foe']['hand'], $s['foe']['draw'], array_column($s['pcs'], 'tile')) as $t) $got[$t['k']] = $t['v']; ksort($want); ksort($got);
    chk("$size: bar x" . PFB_V1_BAR_MULT[$size] . ', creature piece values x' . PFB_V1_FOE_MULT[$size], $s['bar']['max'] === round($base['bar']['max'] * PFB_V1_BAR_MULT[$size], 1) && $s['fh']['max'] === $s['bar']['max'] && $got === $want, [$s['bar']['max'], $got, $want]);
}
$s = pfb_new(v1_me(), v1_foe('large'), 5, ['v1' => ['foe_x' => 2, 'bar_x' => 0.5]]);
chk('sim knobs foe_x / bar_x scale the size numbers', abs($s['v1']['foe'] - 2 * PFB_V1_FOE_MULT['large']) < 1e-9 && abs($s['v1']['bar'] - 0.5 * PFB_V1_BAR_MULT['large']) < 1e-9);

echo "== 11. whole fights: invariants, save and load\n";
$n = 0; $fail = []; $over = []; $turns = []; $evs = ['bar full ends' => 0, 'charm win' => 0, 'env' => 0, 'used' => 0, 'tw' => 0, 'sun' => 0, 'flip' => 0, 'reaim' => 0, 'old terrain' => 0, 'place' => 0, 'pass' => 0, 'expire' => 0, 'push' => 0, 'env used up' => 0, 'reshuffle' => 0, 'mud weakens' => 0];
foreach (['sun', 'bramble', 'rain', 'wind', 'thorn'] as $ek) { $evs["me fires $ek"] = 0; $evs["creature fires $ek"] = 0; }
$regs = array_keys(pfb_env_table()['regions']);
foreach ($rows as $ci => $c) foreach ([0, 1, 2] as $k) {
    if ($k === 2 && $ci % 4) continue;   // every fourth creature also plays a fight with the 2.6.74 terrain
    $old = $k === 2; if ($k === 1) $c['region'] = $regs[$ci % count($regs)];
    $me = v1_me($c['level']); foreach ($me['deck'] as $i => $t) if ($k && $i % 2) $me['deck'][$i]['src'] = ['pal', 'tool', 'crop'][($i + $ci) % 3];
    $s = pfb_new($me, $c, 300 + 17 * $ci + $k, ['v1' => $old ? V1_OLD : true, 'blank' => true]); $deckN = count($me['deck']); $tag = $c['slug'] . "#$k";
    $envN = $old ? 0 : count(pfb_env_deck($c['size'], (string)($c['region'] ?? ''))); $ed0 = $old ? 0 : count($s['env']['draw']);
    if ($old) { unset($s['v1']['env'], $s['v1']['envn'], $s['v1']['rain'], $s['v1']['th_foe'], $s['v1']['mud'], $s['v1']['envcap']); $s['v1']['foe'] = 0.56; $s['v1']['bar'] = 1.3; }   // exactly the keys a 2.6.74 save has
    if (pfb_start($s, $ci % count($s['me']['hand']), 'LRTB'[$ci % 4]) !== null) { $fail[] = "$tag start"; continue; }
    $t = 0;
    while (!$s['over'] && $t++ < 40) {
        if ($t === 3) $s = json_decode(json_encode($s), true);   // the fight is saved as JSON in the encounter between turns
        if ($t % 5 === 4 && pfb_can_flip($s, 0)) { pfb_flip($s, 0, $s['turn']); $evs['flip']++; }   // (2.6.79: the environment's pieces stand apart, so a piece that fits only flipped is rarer: flip now and then anyway)
        $m = pfb_search($s, 'me');
        if (!$m) foreach (array_keys($s['me']['hand']) as $i) { if (!pfb_can_flip($s, $i)) continue; pfb_flip($s, $i, $s['turn']); $evs['flip']++; if ($m = pfb_search($s, 'me')) break; pfb_flip($s, $i, $s['turn']); $evs['flip']--; }
        $r = $m ? pfb_play($s, [[$m[0], $m[1], $m[2]]], $s['turn']) : pfb_pass($s, $s['turn']);
        if ($r['err']) { $fail[] = "$tag turn {$s['turn']}: " . $r['err']; break; }
        foreach ($r['ev'] as $e) {
            $en = $e['env'] ?? null;
            if ($old && $en !== null && !in_array($en, ['sunbeam', 'creep', 'puddle', 'gust', 'thorn', 'bramble', 'poison'], true)) $fail[] = "$tag: a 2.6.74 fight with an environment-piece event ($en)";
            if (!$old && $en !== null && !in_array($en, ['fire', 'place', 'pass', 'expire', 'poison'], true)) $fail[] = "$tag: a terrain event in an environment-piece fight ($en)";
            if ($old && $en !== null && $en !== 'poison') $evs['old terrain']++;
            if (in_array($en, ['place', 'pass', 'expire'], true)) { $evs[$en]++; if ($e['ta'] !== 'env' || isset($e['barnow']) === false) $fail[] = "$tag: env turn event shape"; }
            if ($en === 'fire') { $evs[($e['for'] === 'me' ? 'me' : 'creature') . ' fires ' . $e['kind']]++; if (isset($e['moved'])) $evs['push']++; if ($e['by'] !== 'env' || !in_array($e['ta'], ['me', 'foe'], true) || !isset($e['id'])) $fail[] = "$tag: env fire event shape"; }
        }
        // 2.6.78 (Josh: "the charm bar fills but the fight does not end"): the bars as SHOWN (one decimal, the replay's barnow / fhnow) and the engine agree after every action: a full bar, an empty creature or no health left means the fight is over; and no event shows a full bar while the fight goes on
        $fullNow = ($s['cm'] > 0 && round((float)$s['bar']['now'], 1) >= $s['bar']['max']) || round((float)$s['fh']['now'], 1) >= $s['fh']['max'] || $s['me']['hp'] <= 0;
        if ($fullNow && !$s['over']) $fail[] = "$tag turn {$s['turn']}: the bar reads full (or you are out of health) and the fight is not over";
        if (!$s['over']) foreach ($r['ev'] as $e) if (isset($e['barnow']) && (($s['cm'] > 0 && $e['barnow'] >= $s['bar']['max']) || $e['fhnow'] >= $s['fh']['max'] || $e['hpnow'] <= 0)) $fail[] = "$tag turn {$s['turn']}: an event shows a full bar or no health and the fight goes on";
        $evs['bar full ends']++; if ($s['over'] === 'charmed') $evs['charm win']++;
        foreach ($s['gone'] ?? [] as $g) if ($g['by'] === 'env' && isset($g['used'])) $evs['env used up']++;
        if (!$old && $t > 1 && count($s['env']['draw']) > $ed0) $evs['reshuffle']++; if (!$old) $ed0 = count($s['env']['draw']);
        foreach ($r['ev'] as $e) { if (isset($e['env'])) $evs['env']++; if (isset($e['mud'])) $evs['mud weakens']++; if (isset($e['used'])) $evs['used']++; if (isset($e['tw'])) $evs['tw']++; if (isset($e['sun'])) $evs['sun']++; if (!isset($e['ta'])) $fail[] = "$tag: an event without ta"; }
        if (!empty($s['reaim'])) $evs['reaim']++;
        if (!$s['over'] && ((int)$s['me']['block'] !== (int)($s['me']['kept'] ?? 0) || (int)$s['me']['keep'] !== 0)) $fail[] = "$tag turn {$s['turn']}: guard {$s['me']['block']} at the start of your turn, only {$s['me']['kept']} may carry (Hold)";   // 2.6.77: nothing but a Hold guard is up when your turn starts
        $seen = []; $mine = count($s['me']['hand']) + count($s['me']['draw']) + count($s['me']['discard']) + count($s['me']['held']['pcs'] ?? []);
        foreach ($s['pcs'] as $id => $p) {
            $key = $p['x'] . ',' . $p['y']; if ($p['by'] === 'me') $mine++;
            if ($p['x'] < 0 || $p['y'] < 0 || $p['x'] >= $s['w'] || $p['y'] >= $s['h']) $fail[] = "$tag: a piece off the board";
            if (isset($seen[$key]) || ($s['cell'][$key] ?? null) !== $id) $fail[] = "$tag: cell map out of step";
            $seen[$key] = 1;
        }
        if (count($s['cell']) !== count($s['pcs'])) $fail[] = "$tag: cell count";
        if ($mine !== $deckN) $fail[] = "$tag: deck pieces lost or doubled ($mine of $deckN)";
        if ($old) { if (isset($s['env']) || array_filter($s['pcs'], fn($p) => $p['by'] === 'env')) $fail[] = "$tag: a 2.6.74 fight got environment pieces"; }
        else {   // the environment's pieces: none lost or doubled, no ground, no forecast, Wind carries its arrow only on the board
            $en = count($s['env']['draw']) + count($s['env']['discard']) + count($s['env']['next']) + count(array_filter($s['pcs'], fn($p) => $p['by'] === 'env'));
            if ($en !== $envN) $fail[] = "$tag: environment pieces lost or doubled ($en of $envN)";
            if ($s['ter'] !== [] || $s['envs'] !== []) $fail[] = "$tag: ground or forecast in an environment-piece fight";
            if (count($s['env']['next']) > 2) $fail[] = "$tag: more than two pieces face up";
            if (count($s['cell']) > (int)ceil(0.7 * $s['w'] * $s['h']) + 2) $fail[] = "$tag: the board is over the environment's cap (" . count($s['cell']) . ' pieces)';
            foreach ($s['pcs'] as $p) if ($p['by'] === 'env' && (($p['tile']['env'] === 'wind') !== isset($p['tile']['dir']) || $p['tile']['t'] !== 'env')) $fail[] = "$tag: env piece shape";
            foreach (array_merge($s['env']['draw'], $s['env']['discard'], $s['env']['next']) as $et) if (isset($et['dir']) || isset($et['flip'])) $fail[] = "$tag: an arrow left on a piece in the env deck";
            foreach (['me', 'foe'] as $w) foreach (['hand', 'draw', 'discard'] as $z) foreach ($s[$w][$z] as $pt) if (($pt['src'] ?? '') === 'env') $fail[] = "$tag: an environment piece in a player's deck";
        }
        foreach ($s['ter'] as $key => $kind) { [$x, $y] = array_map('intval', explode(',', $key)); if ($x < 0 || $y < 0 || $x >= $s['w'] || $y >= $s['h'] || !in_array($kind, ['sun', 'br', 'mud'], true)) $fail[] = "$tag: bad ground $key"; }
        $cnt = array_count_values($s['ter']); [$gs, $gb, $gm] = PFB_GROUND[$s['size']]; if (($cnt['sun'] ?? 0) > $gs || ($cnt['br'] ?? 0) > $gb || ($cnt['mud'] ?? 0) > $gm) $fail[] = "$tag: more ground than at the start";
        $v = pfb_view($s); if (json_encode($v) === false || isset($v['foe']['hand'][0])) $fail[] = "$tag: view";
        if (count($fail) > 8) break 3;
    }
    if (!$s['over']) $fail[] = "$tag: the fight does not end"; $n++; $over[$s['over'] ?? 'none'] = ($over[$s['over'] ?? 'none'] ?? 0) + 1; $turns[] = $s['turn'];
}
chk("$n whole v1 fights (every creature, two decks, saved and loaded mid-fight): pieces on the board, cell map, deck count, ground, views", !$fail, array_slice($fail, 0, 5));
chk('those fights use every rule (environment pieces placed, kept back, fired by both sides in every kind, pushed, used up, expired, reshuffled; use-up, Teamwork, flips, re-aims; the 2.6.74 terrain in its fights)', !array_filter($evs, fn($x) => $x < 1), $evs);
echo '     ' . json_encode($over) . ' avg turns ' . round(array_sum($turns) / max(1, count($turns)), 1) . ' ' . json_encode($evs) . "\n";

echo "== 11b. the charm bar ends the fight the moment it reads full (2.6.78)\n";
$s = v1_bare('small'); $s['bar']['max'] = 20.7; $s['bar']['now'] = 20.66; $s['cm'] = 1.0; $r = pf_check_end($s);
chk('v1: a bar at 20.66 of 20.7 reads 20.7 (full) and the fight is won over', $r && $s['over'] === 'charmed', $s['over']);
$s = v1_bare('small'); $s['bar']['max'] = 20.7; $s['bar']['now'] = 20.6; $s['cm'] = 1.0;
chk('v1: a bar at 20.6 of 20.7 is not full: the fight goes on', !pf_check_end($s) && !$s['over']);
$s = v1_bare('small'); $s['fh']['now'] = $s['fh']['max'] - 0.04;
chk('v1: a creature with 0.04 of its health left reads empty (the shown number) and is seen off', pf_check_end($s) && $s['over'] === 'seen_off', $s['over']);
$s = pfb_new(v1_me(), v1_foe('small'), 5, []); $s['bar']['max'] = 20.7; $s['bar']['now'] = 20.66; $s['cm'] = 1.0;
chk('flag off: the old exact comparison (20.66 of 20.7 is not full)', !pf_check_end($s) && !$s['over']);
$nCh = 0; $okCh = true; $badCh = '';
for ($sd = 1; $sd <= 60; $sd++) {   // a player who plays charm first: after every action, a full bar means the fight is over
    $s = pfb_new(v1_me(10), v1_foe(['small', 'medium'][$sd % 2], 6 + $sd % 5), 900 + $sd, ['v1' => true, 'blank' => true]); pfb_start($s, 0, 'LRTB'[$sd % 4]);
    for ($t = 0; $t < 30 && !$s['over']; $t++) {
        foreach (array_keys($s['me']['hand']) as $i) if ($s['me']['hand'][$i]['t'] !== 'charm' && $i % 2) $s['me']['hand'][$i] = pfb_v1_tile(pf_make_tile('charm', ['level' => 10]), $s['v1']);   // charm in the hand, always
        $best = null; foreach ($s['me']['hand'] as $i => $h) foreach (pfb_cell_preview($s, $i) as $key => $q) { $sc = ($q['ch'] ?? 0) * 10 + ($q['dmg'] ?? 0); if ($best === null || $sc > $best[0]) $best = [$sc, $i, $key]; }
        $r = $best ? pfb_play($s, [[$best[1], ...array_map('intval', explode(',', $best[2]))]], $s['turn']) : pfb_pass($s, $s['turn']); if ($r['err']) break;
        $full = round((float)$s['bar']['now'], 1) >= $s['bar']['max'];
        if ($full && !$s['over']) { $okCh = false; $badCh = "seed $sd turn $t bar {$s['bar']['now']} / {$s['bar']['max']}"; }
        if (!$s['over']) foreach ($r['ev'] as $e) if (isset($e['barnow']) && $e['barnow'] >= $s['bar']['max']) { $okCh = false; $badCh = "seed $sd: event shows a full bar"; }
    }
    if ($s['over'] === 'charmed') $nCh++;
}
chk("60 fights of a charm-first player: never a full bar with the fight still on ($nCh charm wins)", $okCh && $nCh >= 10, $badCh ?: "only $nCh charm wins");

echo "== 12. page wiring (no DB): moves, lines\n";
chk('pfight_parse_moves still reads the four old moves', pfight_parse_moves('1,2,3') === [[1, 2, 3]] && pfight_parse_moves('c,1,2') === [['c', 1, 2]] && pfight_parse_moves('f,1') === null);
$line = pfb_env_line(['env' => 'gust', 'moved' => ['by' => 'me', 'n' => 'Swing'], 'me' => 0, 'foe' => 0], 'Owl'); chk('a gust line names the piece it pushed', str_contains($line, 'your Swing'), $line);
$line = pfb_env_line(['env' => 'thorn', 'me' => 4, 'foe' => 2.4], 'Owl'); chk('a thorn burst line says what each side lost', str_contains($line, 'you lose 4') && str_contains($line, 'Owl loses 2'), $line);

require __DIR__ . '/pfboard_v1_env.php';   // 13: environment pieces (2.6.75)
require __DIR__ . '/pfboard_v1_notes.php';   // 14: notices (2.6.76)
require __DIR__ . '/pfboard_v1_guard.php';   // 15: your guard fades when your turn starts (2.6.77)

chk('no PHP warning or notice anywhere in this run', !$warn, array_slice($warn, 0, 3));
echo $bad ? "$bad FAILED\n" : "all ok\n";
exit($bad ? 1 : 0);
