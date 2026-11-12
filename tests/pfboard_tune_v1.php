<?php
// Balance table for the v1 board rules (pfight_v1) on the REAL engine and the 88 real creatures: win % / health lost % / turns by creature size.
// php tests/pfboard_tune_v1.php [BOT=chain] [OFFSETS=0] [MULT=1] [SHARD/NSHARDS=0/1] [json]
//   BOT: chain (always the longest chain; never looks at its health or the creature) | look (best state after the whole round: its chain, the shown aim, the terrain turn)
//        | smart (two turns: top 6 by look, then its best own chain next turn; uses set-aside). All may flip (one flip a turn).
//   OFFSETS: gnome level minus creature level, e.g. 0,-4,-8.   MULT 1 = about 200 fights per size and offset (0.25 for a quick look).
//   env V1='{"foe_x":1.1,"limit":4}' (pfb_v1_cfg overrides; a value may be a map by size: {"foe":{"small":0.7,"medium":0.5,"large":0.4,"boss":0.45}}), SRC=mixed|built|thirds|none (made-up sources for Teamwork).
// Targets (claude/design-board-strategy.md): chain about 70% at level, smart 90% or more, fights 6-8 turns (small 4-5). The bots are tools/pfsim/v1bundle/run.php's, plus the flip.
require_once __DIR__ . '/../game/includes/pfboard.php';
require_once __DIR__ . '/../game/includes/pfdeck.php';
const TV_SEEDS = ['small' => 21, 'medium' => 8, 'large' => 5, 'boss' => 23];   // 10 small, 26 medium, 43 large, 9 boss creatures -> 210 / 208 / 215 / 207 fights
function tv_creatures(): array
{
    $die = ['small' => 4, 'medium' => 6, 'large' => 8, 'boss' => 10]; $o = [];
    foreach (file(__DIR__ . '/../game/includes/data/creatures.txt', FILE_IGNORE_NEW_LINES) as $l) {
        if ($l === '' || $l[0] === '#') continue; $c = explode('|', $l); if (count($c) < 7) continue;
        $lv = max(1, (int)$c[4]); $o[] = ['slug' => $c[0], 'name' => $c[1], 'size' => $c[2], 'level' => $lv, 'dmg_die' => $die[$c[2]] ?? 6, 'dmg_bonus' => intdiv($lv, 4)];
    }
    return $o;
}
/** Stage B: a typical gnome's sources at a level for the v1 deck model: a one-tap starter kit, a belt that grows (2 tools, 3 from level 10, 4 from 20; tiers rise with level),
 *  1 pal from level 3 and 2 from 8, crops, crafts and regions as the game is played, and up to 3 knacks switched on. Deck: 14 pieces at level 1, about 22 at level 30. */
function tv_sources(int $lv): array
{
    $cals = array_keys(PF_CALLING_TILE); $src = pfd_sources_blank($lv, $cals[$lv % 6], ['NA', 'NWE', 'SE', 'EA'][$lv % 4]);
    $src['ctier'] = min(3, 1 + intdiv($lv, 12));
    $src['starter'] = array_merge(PFD_CORE, pfd_offer_keys($src['calling'], $src['home'], PFD_KITS[['bold', 'steady', 'kind'][$lv % 3]]));
    $tier = min(3, 1 + intdiv($lv, 10)); $src['slots'] = $lv >= 20 ? 4 : ($lv >= 10 ? 3 : 2);
    foreach (array_slice(['axe', 'till', 'staff', 'lantern'], 0, $src['slots']) as $i => $t) $src['tools'][$t] = max(1, $tier - ($i > 1 ? 1 : 0));
    $src['belt'] = array_keys($src['tools']);
    if ($lv >= 3) $src['pals'][] = ['n' => 'Bark Badger', 't' => 'guard', 'v' => 5 + ($lv >= 12 ? 2 : 0), 'r' => 'craft', 'rank' => $lv >= 12 ? 2 : 1];
    if ($lv >= 8) $src['pals'][] = ['n' => 'Samara Spin', 't' => 'hurt', 'v' => 5 + ($lv >= 20 ? 2 : 0), 'r' => 'body', 'rank' => $lv >= 20 ? 2 : 1];
    foreach (['vegetable' => 2, 'spice' => 10, 'fruit' => 14, 'nut' => 22] as $k => $at) if ($lv >= $at) $src['crops'][$k] = min(3, 1 + intdiv($lv - $at, 12));
    foreach (['garden' => 6, 'potions' => 12, 'tools' => 18] as $k => $at) if ($lv >= $at) $src['crafts'][$k] = 1;
    if ($lv >= 5) $src['regions'][$src['home']] = 1; if ($lv >= 16) $src['regions']['MENA'] = 2;
    $on = 0; foreach (['smash', 'sting', 'lull', 'pierce', 'hum', 'brace'] as $k) if ($on < 3 && $lv >= (int)pfd_catalog()[$k]['ref'] && !in_array($k, $src['starter'], true)) { $src['state'][$k] = true; $on++; }
    return $src;
}
function tv_player(int $lv): array
{
    $m = max(0, intdiv($lv + 3, 14));
    if ((getenv('DECK') ?: 'real') === 'real') {   // stage B: the deck model's deck (DECK=old: the stage A sim deck with made-up sources)
        $st = ['grit' => $m, 'nimble' => $m, 'hardiness' => $m, 'charm' => $m, 'lore' => $m, 'luck' => $m, 'level' => $lv]; $max = 20 + 3 * $lv + 5 * $m; $src = tv_sources($lv);
        return ['hp' => $max, 'max_hp' => $max, 'stats' => $st, 'deck' => pfd_tiles(pfd_fight_entries($src), $st, [], $src['calling'], $src['ctier']), 'luck' => $m];
    } $st = ['grit' => $m, 'nimble' => $m, 'hardiness' => $m, 'charm' => $m, 'lore' => $m, 'luck' => $m, 'level' => $lv];
    $cals = array_keys(PF_CALLING_TILE); $cal = $cals[$lv % 6]; $own = pf_collection($lv, $cal); $cap = pf_box_capacity($lv);
    $want = ['hurt' => 5, 'charm' => 3, 'guard' => 3, 'heal' => 1, 'trick' => 1, 'item' => 1, 'soothe' => 0]; $box = []; $n = [];
    foreach ($own as $k) { $t = pf_tiles()[$k]['t']; if (($n[$t] ?? 0) < ($want[$t] ?? 0) && count($box) < $cap) { $box[] = $k; $n[$t] = ($n[$t] ?? 0) + 1; } }
    foreach ($own as $k) if (!in_array($k, $box, true) && count($box) < $cap) $box[] = $k;
    $max = 20 + 3 * $lv + 5 * $m; $deck = pf_player_deck($st, $cal, 1 + intdiv($lv, 12), [], [], [], true, $box);
    $mode = getenv('SRC') ?: 'mixed'; $n = count($deck);   // made-up sources until the deck model (stage B) gives real ones: mixed = 1 pal, 2 tool, 2 crop
    $plan = $mode === 'built' ? ['pal', 'tool', 'crop', 'tool', 'crop', 'pal', 'tool', 'crop', 'tool', 'crop'] : ['tool', 'crop', 'pal', 'tool', 'crop'];
    $slots = []; for ($i = 0; $i < count($plan); $i++) $slots[(int)floor(($i + 0.5) * $n / count($plan))] = $plan[$i];
    foreach ($deck as $i => $t) { $src = $mode === 'thirds' ? ['pal', 'tool', 'crop'][$i % 3] : ($mode === 'none' ? null : ($slots[$i] ?? null)); if ($src) $deck[$i]['src'] = $src; }
    return ['hp' => $max, 'max_hp' => $max, 'stats' => $st, 'deck' => $deck, 'luck' => $m];
}
/** Every placement: [handIdx | 'c', x, y, flip]. */
function tv_places(array $s): array
{
    $o = [];
    foreach ($s['me']['hand'] as $i => $t) {
        foreach (pfb_cells($s, $t, 'me') as [$x, $y]) $o[] = [$i, $x, $y, 0];
        if (pfb_can_flip($s, $i)) { $w = $s; pfb_flip($w, $i, $w['turn']); foreach (pfb_cells($w, $w['me']['hand'][$i], 'me') as [$x, $y]) $o[] = [$i, $x, $y, 1]; }
    }
    if (!empty($s['me']['held'])) foreach (pfb_group_spots($s, $s['me']['held']) as [$x, $y]) $o[] = ['c', $x, $y, 0];
    return $o;
}
function tv_joins(array $s): array
{
    $o = []; $h = $s['me']['hand']; $g = $s['me']['held'] ?? null;
    if (!$g) { foreach ($h as $a => $_) foreach ($h as $b => $_2) if ($a !== $b) foreach (['L', 'R', 'T', 'B'] as $sd) { $w = $s; if (pfb_connect($w, 'me', $a, $b, $sd) === null) $o[] = ['j', $a, $b, $sd]; } }
    elseif (count($g['pcs']) < PFB_GROUP_MAX) { foreach ($h as $b => $_) foreach ($g['pcs'] as $ai => $_2) foreach (['L', 'R', 'T', 'B'] as $sd) { $w = $s; if (pfb_connect($w, 'me', null, $b, $sd, $ai) === null) $o[] = ['h', $b, $ai, $sd]; } }
    return $o;
}
/** My own chain only: [state after, pieces fired]. */
function tv_dry(array $s, array $a): array
{
    $w = $s; $w['reshuf'] = []; $w['cut'] = 0; $w['spent'] = [];
    if (!empty($a[3])) pfb_flip($w, $a[0], $w['turn']);
    $ev = $a[0] === 'c' ? pfb_place_group($w, 'me', $a[1], $a[2]) : pfb_place($w, 'me', $a[0], $a[1], $a[2]);
    return [$w, count(array_filter($ev ?? [], fn($e) => isset($e['id'])))];
}
function tv_act(array &$s, array $a): array
{
    if ($a[0] === 'pass') return pfb_pass($s, $s['turn']);
    if ($a[0] === 'j' || $a[0] === 'h') return pfb_play($s, [$a], $s['turn']);
    if (!empty($a[3])) pfb_flip($s, $a[0], $s['turn']);
    return pfb_play($s, [[$a[0], $a[1], $a[2]]], $s['turn']);
}
function tv_value(array $s): float
{
    $p = $s['fh']['now'] / $s['fh']['max']; if ($s['cm'] > 0) $p = max($p, $s['bar']['now'] / $s['bar']['max']);
    $v = min(1.0, $p) + 1.2 * $s['me']['hp'] / $s['me']['max'] + 0.3 * min($s['me']['block'] + $s['me']['keep'], 0.3 * $s['me']['max']) / $s['me']['max'] - 0.15 * $s['foe']['block'] / $s['fh']['max'];
    if ($s['over']) $v += $s['over'] === 'defeat' ? -3 : ($s['over'] === 'stall' ? -1 : 3);
    return $v;
}
function tv_ranked(array $s, array $acts): array
{
    $o = [];
    foreach ($acts as $a) { $w = $s; $r = tv_act($w, $a); if ($r['err']) continue; $o[] = [tv_value($w), $a, $w]; }
    usort($o, fn($x, $y) => $y[0] <=> $x[0]);
    return $o;
}
function tv_smart(array $s, array $acts): ?array
{
    $best = null; $bs = -1e9;
    foreach (array_slice(tv_ranked($s, $acts), 0, 6) as [$v1, $a, $w]) {
        $v2 = $v1;
        if (!$w['over']) {
            $keep = count($s['me']['hand']) - ($a[0] === 'j' ? 2 : ($a[0] === 'c' ? 0 : 1)); $v2 = $v1 - 0.02;
            foreach (tv_places($w) as $p) { if (is_int($p[0]) && $p[0] >= $keep) continue; [$w2] = tv_dry($w, $p); $v2 = max($v2, tv_value($w2)); }   // no peeking at what it draws
        }
        $sc = 0.35 * $v1 + 0.65 * $v2; if ($sc > $bs) { $bs = $sc; $best = $a; }
    }
    return $best;
}
function tv_choose(array $s, string $bot, array $pl): array
{
    if ($bot === 'chain') {
        if (!$pl) return ['pass'];
        $b = 0; $bs = -1e9;
        foreach ($pl as $i => $a) { $d = tv_dry($s, $a); $sc = $d[1] * 1000 + ($d[0]['fh']['now'] + $d[0]['bar']['now']) + ($d[0]['over'] && $d[0]['over'] !== 'defeat' ? 1e6 : 0); if ($sc > $bs + 1e-9) { $bs = $sc; $b = $i; } }
        return $pl[$b];
    }
    if ($bot === 'look') return tv_ranked($s, $pl)[0][1] ?? ['pass'];
    $acts = array_merge($pl, tv_joins($s)); if (!$acts) return ['pass'];
    return tv_smart($s, $acts) ?? ['pass'];
}
/** Print the table from rows grouped [offset][size]. */
function tv_print(string $bot, array $g, bool $blind): void
{
foreach ($g as $d => $bySize) foreach (['small', 'medium', 'large', 'boss'] as $sz) {
    $a = $bySize[$sz] ?? []; if (!$a) continue; $n = count($a); $avg = fn(string $k) => array_sum(array_column($a, $k)) / $n;
    printf("%-5s d%+d %-6s n=%3d win=%3.0f%% hp_lost=%2.0f%% turns=%.1f | per fight: used-up chains %.1f, Teamwork %.2f, flips %.1f, re-aims %.1f, passes %.2f, turn cap %.0f%%\n", $bot, $d, $sz, $n, 100 * $avg('win'), 100 * $avg('hp'), $avg('turns'), $avg('used'), $avg('tw'), $avg('flip'), $avg('reaim'), $avg('pass'), 100 * $avg('cap'));
    if ($avg('eplace') > 0) {   // 2.6.75 environment pieces
        $k = fn(string $p) => implode(' ', array_map(fn($ek) => substr($ek, 0, 2) . sprintf('%.2f', $avg($p . $ek)), PFB_ENV_KINDS));
        printf("      env per fight: placed %.1f (pass %.2f), fired by me %.2f [%s], by creature %.2f [%s], pushes %.2f, fires of a piece that had fired before %.2f; env cost: me %.0f%% hp, creature %.0f%% bar; my chain length %.2f; pieces on board %.1f%s\n", $avg('eplace'), $avg('epass'), $avg('efire_me'), $k('me_'), $avg('efire_foe'), $k('foe_'), $avg('push'), $avg('refire'), 100 * $avg('e_hp'), 100 * $avg('e_bar'), array_sum(array_column($a, 'len')) / max(1, array_sum(array_column($a, 'chains'))), array_sum(array_column($a, 'pcs')) / max(1, array_sum(array_column($a, 'turns'))),
            $blind ? sprintf('; best move changes with env hidden: %.0f%% of turns, %.0f%% of fights, cost %.3f a turn', 100 * array_sum(array_column($a, 'echg')) / max(1, array_sum(array_column($a, 'eturns'))), 100 * count(array_filter($a, fn($r) => $r['echg'] > 0)) / $n, array_sum(array_column($a, 'ecost')) / max(1, array_sum(array_column($a, 'echg')))) : '');
    }
}
}
if (PHP_SAPI !== 'cli' || !isset($argv) || realpath($argv[0]) !== __FILE__) return;
if (($argv[1] ?? '') === 'agg') {   // php tests/pfboard_tune_v1.php agg < the json lines of several shards
    $G = []; while (($l = fgets(STDIN)) !== false) { $r = json_decode($l, true); if ($r) $G[$r['bot']][$r['d']][$r['size']][] = $r; }
    foreach ($G as $b => $g) tv_print((string)$b, $g, (bool)getenv('BLIND')); return;
}
$bot = $argv[1] ?? 'chain'; $offs = array_map('intval', explode(',', $argv[2] ?? '0')); $mult = (float)($argv[3] ?? 1); [$shard, $nsh] = array_map('intval', explode('/', $argv[4] ?? '0/1')); $json = ($argv[5] ?? '') === 'json';
$V1 = json_decode(getenv('V1') ?: '{}', true) ?: []; $ci = 0; $g = []; $blind = (bool)getenv('BLIND');
foreach ($offs as $d) foreach (tv_creatures() as $c) {
    if ($ci++ % $nsh !== $shard) continue;
    $over = []; foreach ($V1 as $k => $v) $over[$k] = is_array($v) ? ($v[$c['size']] ?? null) : $v; $over = array_filter($over, fn($v) => $v !== null);
    $nk = max(1, (int)ceil(TV_SEEDS[$c['size']] * $mult));
    for ($k = 0; $k < $nk; $k++) {
        $lv = max(1, $c['level'] + $d); $seed = 500 + 7 * $k + $c['level'] + 1000 * (crc32($c['slug']) % 97);
        $cr = (getenv('FOE') ?: 'layers') === 'layers' ? pfd_foe_row($c, array_keys(pfd_region_pieces())[(crc32($c['slug']) + $k) % 14]) : $c;   // stage B: the layered creature deck, in a region that changes with the seed (FOE=old: the archetype decks)
        $s = pfb_new(tv_player($lv), $cr, $seed, ['blank' => true, 'v1' => $over ?: true]);
        $hand = $s['me']['hand']; $bi = 0; foreach ($hand as $i => $t) if ($t['t'] === 'hurt' && $t['v'] > $hand[$bi]['v']) $bi = $i;
        pfb_start($s, $bi, ['L', 'R', 'T', 'B'][$k % 4]);
        $t = 0; $st = ['used' => 0, 'tw' => 0, 'flip' => 0, 'reaim' => 0, 'pass' => 0, 'eplace' => 0, 'epass' => 0, 'efire_me' => 0, 'efire_foe' => 0, 'push' => 0, 'echg' => 0, 'eturns' => 0, 'ecost' => 0.0, 'e_hp' => 0.0, 'e_bar' => 0.0, 'len' => 0, 'chains' => 0, 'pcs' => 0, 'refire' => 0]; $firedIds = [];
        foreach (PFB_ENV_KINDS as $ek) { $st['me_' . $ek] = 0; $st['foe_' . $ek] = 0; $st['pl_' . $ek] = 0; }
        while (!$s['over'] && $t++ < 40) {
            $pl = tv_places($s); $a = tv_choose($s, $bot, $pl);
            if ($blind && $pl && $bot !== 'chain') {   // "strategy matters": the same bot choosing with the environment pieces' effects hidden; the turn counts when that pick is worse than its real pick
                $b = $s; foreach (['bramble', 'thorn', 'rain'] as $bk) $b['v1'][$bk] = 0; $b['v1']['sun'] = 1; $b['v1']['nowind'] = 1;
                $ab = tv_choose($b, $bot, $pl); $st['eturns']++;
                if ($ab !== $a) { $w1 = $s; tv_act($w1, $a); $w2 = $s; tv_act($w2, $ab); $dv = tv_value($w1) - tv_value($w2); if ($dv > 0.005) { $st['echg']++; $st['ecost'] += $dv; } }
            }
            if ($a[0] === 'pass') $st['pass']++; if (!empty($a[3])) $st['flip']++;
            $r = tv_act($s, $a);
            if ($r['err']) { $r = pfb_pass($s, $s['turn']); if ($r['err']) { if (!$pl) break; $r = tv_act($s, $pl[0]); if ($r['err']) break; } }
            foreach ($r['ev'] as $e) { if (isset($e['used']) && ($e['ta'] ?? '') === 'me') $st['used']++; if (isset($e['tw']) && !empty($e['root'])) $st['tw']++;
                if (($e['env'] ?? '') === 'place') { $st['eplace']++; $st['pl_' . $e['kind']]++; } if (($e['env'] ?? '') === 'pass') $st['epass']++;
                if (($e['env'] ?? '') === 'fire') { $st['efire_' . $e['for']]++; $st[$e['for'] . '_' . $e['kind']]++; if (isset($e['moved'])) $st['push']++; if (isset($firedIds[$e['id']])) $st['refire']++; $firedIds[$e['id']] = 1; $st['e_hp'] += $e['me'] / $s['me']['max']; $st['e_bar'] += $e['foe'] / $s['fh']['max']; }
                if (!empty($e['root']) && ($e['ta'] ?? '') === 'me') $st['chains']++; if (isset($e['id']) && ($e['ta'] ?? '') === 'me') $st['len']++; }
            $st['pcs'] += count($s['pcs']);
            if (!empty($s['reaim'])) $st['reaim']++;
        }
        $row = ['d' => $d, 'size' => $c['size'], 'win' => in_array($s['over'], ['seen_off', 'charmed'], true) ? 1 : 0, 'turns' => $s['turn'], 'hp' => 1 - $s['me']['hp'] / $s['me']['max'], 'cap' => $s['over'] === 'stall' || !$s['over'] ? 1 : 0] + $st;
        if ($json) echo json_encode(['bot' => $bot] + $row), "\n"; else $g[$d][$c['size']][] = $row;
    }
}
if ($json) return;
tv_print($bot, $g, $blind);
