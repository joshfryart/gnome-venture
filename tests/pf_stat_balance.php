<?php
// Stat pieces balance pass (no DB, deterministic; a tool, not a CI suite): the same gnome (level 20, the tuner's std deck, every stat at its own points) fights the same creatures with the same seeds
// with and without ONE stat piece packed; the difference is what that piece is worth. Equal stat points: each piece is tested at its own tier's points in its stat (others 10), baseline has the same stats.
//   php tests/pf_stat_balance.php [SEEDS=2] [SHARD/NSHARDS=0/1] [json]     env BOT=chain|look  KEYS=k1,k2  LV=20  STEP=8 (every STEP-th creature within 4 levels of LV)
$GLOBALS['TEST_SETTINGS'] = ['pfight_statpieces' => '1'];
if (!function_exists('setting')) { function setting(string $k): string { return (string)($GLOBALS['TEST_SETTINGS'][$k] ?? ''); } }
require_once __DIR__ . '/pf_bots.php';
function sb_player(int $lv, array $pts, ?string $key): array
{
    $m = max(0, intdiv($lv + 3, 14));
    $st = ['grit' => $m, 'nimble' => $m, 'hardiness' => $m, 'charm' => $m, 'lore' => $m, 'luck' => $m, 'level' => $lv];
    $src = tv_sources($lv); $max = 20 + 3 * $lv + 5 * $m;
    $src['statp'] = true; $src['sbase'] = $pts; $src['spts'] = $pts; $src['state'] = $src['state'] ?? [];
    if ($key) $src['state'][$key] = true;
    $ent = pfd_fight_entries($src);
    $has = false; foreach ($ent as $e) if (($e['k'] ?? '') === $key) $has = true;
    $deck = pfd_tiles($ent, $st, [], $src['calling'], $src['ctier']);
    return ['hp' => $max, 'max_hp' => $max, 'stats' => $st, 'deck' => $deck, 'luck' => $pts['luck'] ?? 10, 'lpts' => $pts['luck'] ?? 10, 'has' => $has];
}
if (PHP_SAPI !== 'cli' || realpath($argv[0]) !== __FILE__) return;
$seeds = max(1, (int)($argv[1] ?? 2)); [$sh, $nsh] = array_map('intval', explode('/', $argv[2] ?? '0/1')); $json = ($argv[3] ?? '') === 'json';
$lv = (int)(getenv('LV') ?: 20); $step = (int)(getenv('STEP') ?: 8); $bot = getenv('BOT') ?: 'chain';
$cs = array_values(array_filter(tv_creatures(), fn($c) => abs($c['level'] - $lv) <= 4)); $cs = array_values(array_filter($cs, fn($c, $i) => $i % $step === 0, ARRAY_FILTER_USE_BOTH));
$keys = array_keys(pfd_stat_pieces()); if (getenv('KEYS')) $keys = array_values(array_intersect($keys, explode(',', getenv('KEYS')))); $ci = 0;
$runs = [];   // [pts-map => list of keys] baseline per distinct pts map
foreach ($keys as $key) {
    if ($ci++ % $nsh !== $sh) continue;
    $p = pfd_stat_pieces()[$key]; $pts = ['nimble' => 10, 'lore' => 10, 'luck' => 10, 'sense' => 10]; $pts[$p['stat']] = max(10, $p['tier']);
    $bk = json_encode($pts);
    $agg = ['b' => ['w' => 0, 'n' => 0, 't' => 0, 'h' => 0], 'p' => ['w' => 0, 'n' => 0, 't' => 0, 'h' => 0]]; $has = true;
    foreach ($cs as $c) for ($k = 0; $k < $seeds; $k++) {
        $seed = 700 + 13 * $k + $c['level'] + 1000 * (crc32($c['slug']) % 97);
        foreach (['b' => null, 'p' => $key] as $side => $kk) {
            $pl = sb_player($lv, $pts, $kk); if ($side === 'p') $has = $has && $pl['has']; unset($pl['has']);
            $r = pb_fight($c, $lv, $bot, 'std', $seed, [], $pl);
            $agg[$side]['w'] += $r['win']; $agg[$side]['n']++; $agg[$side]['t'] += $r['turns']; $agg[$side]['h'] += $r['hp'];
        }
    }
    $o = ['key' => $key, 'stat' => $p['stat'], 'tier' => $p['tier'], 'pts' => $pts[$p['stat']], 'packed' => $has, 'n' => $agg['b']['n']];
    foreach (['b', 'p'] as $s) { $n = max(1, $agg[$s]['n']); $o[$s] = ['win' => $agg[$s]['w'] / $n, 'turns' => $agg[$s]['t'] / $n, 'hp' => $agg[$s]['h'] / $n]; }
    echo json_encode($o), "\n";
}
