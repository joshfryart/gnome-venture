<?php
// Several worn pieces at once (balance.md, "Several worn pieces at once"). Real engine, the bots of tests/pf_bots.php, no DB.
//   php multi_sim.php LEVEL N SET [SHARD/NSHARDS]     json lines on stdout; aggregate: php multi_sim.php agg FILE...
//     SET: none | a comma list of item slugs (rank Common; env WEAR_RANK=2 Lined, 3 Fine for all of them; slug:2 / slug:3 = one piece at Lined / Fine, a mixed set), all worn and all switched on. The Puzzle box decides how many play: pfd_slots (Keepsakes 1 / 2 / 3 / 4
//     at level 1 / 15 / 25 / 40) and the Rare cap. The run stops if a listed piece is not in the deck (so a set is never silently cut).
//   The gnome: the tuner's kit at LEVEL (tv_sources). Creatures: within 3 levels of LEVEL (ws_pool), same creature and seed for every set (k).
//   Sets have different deck sizes, so they are not paired: compare the means, noise about +-2 win points at N = 480 for the careless bot.
require_once __DIR__ . '/wear_sim.php';

if (($argv[1] ?? '') === 'agg') {
    $A = [];
    foreach (array_slice($argv, 2) as $f) foreach (file($f, FILE_IGNORE_NEW_LINES) as $l) { $r = json_decode($l, true); if (!$r) continue; $a = &$A[$r['lv']][$r['set']][$r['bot']]; $a['n'] = ($a['n'] ?? 0) + 1; foreach (['win', 'hp', 'turns', 'pl', 'fx'] as $k) $a[$k] = ($a[$k] ?? 0) + $r[$k]; $a['err'] = ($a['err'] ?? 0) + (isset($r['err']) ? 1 : 0); $a['w'] = $r['wn']; unset($a); }
    foreach ($A as $lv => $sets) foreach ($sets as $set => $bots) {
        $o = [];
        foreach (['look', 'greedy'] as $b) { $a = $bots[$b] ?? null; if (!$a) continue; $base = $A[$lv]['none'][$b] ?? null; $o[] = sprintf('%s n=%d win %.1f%% (%+.1f) health lost %.1f%% (%+.1f) turns %.1f placed %.2f fx %.2f err %d', $b, $a['n'], 100 * $a['win'] / $a['n'], $base ? 100 * ($a['win'] / $a['n'] - $base['win'] / $base['n']) : 0, 100 * $a['hp'] / $a['n'], $base ? 100 * ($a['hp'] / $a['n'] - $base['hp'] / $base['n']) : 0, $a['turns'] / $a['n'], $a['pl'] / $a['n'], $a['fx'] / $a['n'], $a['err']); $w = $a['w']; }
        echo "level $lv | $set | wear pieces in the deck: $w\n   " . implode("\n   ", $o) . "\n";
    }
    exit;
}
[, $lv, $N, $set] = $argv + [null, 40, 48, 'none']; $lv = (int)$lv; $N = (int)$N; [$sh, $nsh] = array_map('intval', explode('/', $argv[4] ?? '0/1'));
$slugs = $set === 'none' ? [] : explode(',', $set);
$m = max(0, intdiv($lv + 3, 14));
$st = ['grit' => $m, 'nimble' => $m, 'hardiness' => $m, 'charm' => $m, 'lore' => $m, 'luck' => $m, 'level' => $lv]; $max = 20 + 3 * $lv + 5 * $m;
$src = tv_sources($lv);
$rank = max(1, min(3, (int)(getenv('WEAR_RANK') ?: 1)));   // env WEAR_RANK 1 Common (default), 2 Lined, 3 Fine: every piece of the set at that rank
foreach ($slugs as $s) { $rk = $rank; if (str_contains($s, ':')) { [$s, $rk] = explode(':', $s); $rk = max(1, min(3, (int)$rk)); } $k = wear_slug($s, 'a', $rk); $src['wears'][$k] = 1; $src['worn'][] = $k; $src['state']['w:' . $s] = true; }   // slug:2 = that piece at Lined, slug:3 = Fine (a mixed set)
$slugs = array_map(fn($s) => explode(':', $s)[0], $slugs);
$b = pfd_build($src);
$out = array_values(array_map(fn($e) => $e['key'] . ':' . $e['out'], array_filter($b['pieces'], fn($e) => $e['src'] === 'wear' && $e['out'] !== '')));
$deck = array_values(pfd_tiles(pfd_fight_entries($src), $st, [], $src['calling'], $src['ctier']));
$wn = count(array_filter($deck, fn($t) => ($t['src'] ?? '') === 'wear'));
if ($out || $wn !== count($slugs)) { fwrite(STDERR, "level $lv (Keepsake slots " . pfd_slots($lv)['keeps'] . "): only $wn of " . count($slugs) . ' worn pieces are in the deck; left out: ' . implode(', ', $out) . "\n"); exit(1); }
$player = ['hp' => $max, 'max_hp' => $max, 'stats' => $st, 'deck' => $deck, 'luck' => $m];
$pool = ws_pool($lv);
foreach (['look', 'greedy'] as $bot) for ($k = 0; $k < $N; $k++) {
    if ($k % $nsh !== $sh) continue;
    $c = $pool[$k % count($pool)]; $r = ws_fight($c, $lv, $bot, 700000 + 13 * $k + $lv, $player);
    echo json_encode(['lv' => $lv, 'set' => $set . ($rank > 1 ? '@' . ['', 'Lined', 'Fine'][$rank - 1] : ''), 'wn' => $wn, 'bot' => $bot, 'k' => $k, 'cr' => $c['slug'], 'win' => $r['win'], 'hp' => round($r['hp'], 4), 'turns' => $r['turns'], 'pl' => $r['pl'], 'fx' => $r['fx']] + (isset($r['err']) ? ['err' => $r['err']] : [])), "\n";
}
