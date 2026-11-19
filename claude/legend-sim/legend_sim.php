<?php
// Legend crop piece sim (claude/balance-legend-sim.md). Real engine, real decks, the bots of tests/pf_bots.php. No DB.
//   php legend_sim.php run LEVELS BOTS N RANK [SHARD/NSHARDS] [ONLY]     json lines on stdout
//     LEVELS: comma list of gnome levels (default 12,24,34).  BOTS: chain,greedy,look.  N: fights per piece, bot and level.  RANK: the gnome's mastery of the crop, 1-4 (default 2).
//     ONLY: a comma list of crop slugs (default: all 42 `g:` pieces of data/pf_pieces.txt, source legend). The baseline (the tuner's gnome with no legend piece) is played with 4 x N fights per bot and level.
// A piece is played on the tuner's gnome of that level (tests/pfboard_tune_v1.php tv_sources: starter, belt, pals, crops, crafts, regions, up to 3 knacks) with ONE legend piece added (the Larder
// has a free slot at these levels; the run stops if the piece is not in the deck). Creatures: every creature within 3 levels of the gnome (widened to 6), at their own level, same creature and seed
// order for every piece. Deck sizes differ by one piece, so a fight is NOT paired with the baseline: the numbers are means over many fights (noise: win about +-2 points, health lost about +-1).
require_once __DIR__ . '/../../tests/pf_bots.php';

function ls_pool(int $L): array
{
    $cr = tv_creatures();
    for ($w = 3; ; $w++) { $p = array_values(array_filter($cr, fn($c) => abs($c['level'] - $L) <= $w)); if (count($p) >= 6) return $p; }
}
/** The legend pieces: [slug => row]. */
function ls_pieces(): array
{
    $o = [];
    foreach (pfd_catalog() as $k => $p) if (($p['src'] ?? '') === 'legend') $o[(string)$p['ref']] = $p;
    ksort($o);
    return $o;
}
/** tv_player($lv) with one legend piece (crop slug, mastery rank) switched on, or none (null = the baseline). */
function ls_player(int $lv, ?string $crop, int $rank): array
{
    $m = max(0, intdiv($lv + 3, 14));
    $st = ['grit' => $m, 'nimble' => $m, 'hardiness' => $m, 'charm' => $m, 'lore' => $m, 'luck' => $m, 'level' => $lv]; $max = 20 + 3 * $lv + 5 * $m;
    $src = tv_sources($lv);
    if ($crop !== null) { $src['legends'] = [$crop => $rank]; $src['state']['g:' . $crop] = true; }
    $deck = pfd_tiles(pfd_fight_entries($src), $st, [], $src['calling'], $src['ctier']);
    if ($crop !== null) {
        $hit = 0; foreach ($deck as $t) if (($t['src'] ?? '') === 'legend') $hit++;
        if ($hit !== 1) throw new RuntimeException("legend piece $crop not in the deck at level $lv ($hit)");
    }
    return ['hp' => $max, 'max_hp' => $max, 'stats' => $st, 'deck' => array_values($deck), 'luck' => $m];
}
/** pb_fight with the player given, plus pl = times you placed the legend piece and fx = times it fired in a chain (event k of the piece, by me). */
function ls_fight(array $c, int $lv, string $bot, int $seed, array $player): array
{
    mt_srand($seed); $rng = fn(int $n) => $n > 0 ? mt_rand(0, $n - 1) : 0;
    try {
        $cr = pfd_foe_row($c, array_keys(pfd_region_pieces())[(crc32($c['slug']) + $seed) % 14]);
        $s = pfb_new($player, $cr, $seed, ['blank' => true, 'v1' => true]);
        $hand = $s['me']['hand'];
        if ($hand) { $bi = 0; foreach ($hand as $i => $t) if ($t['t'] === 'hurt' && $t['v'] > $hand[$bi]['v']) $bi = $i; pfb_start($s, $bi, ['L', 'R', 'T', 'B'][$seed % 4]); }
        $t = 0; $pl = 0; $fx = 0;
        while (!$s['over'] && $t++ < 40) {
            $places = tv_places($s); $a = pb_choose($s, $bot, $places, $rng);
            if (is_int($a[0]) && ($s['me']['hand'][$a[0]]['src'] ?? '') === 'legend') $pl++;
            $r = tv_act($s, $a);
            if ($r['err']) { $r = pfb_pass($s, $s['turn']); if ($r['err']) { if (!$places) break; $r = tv_act($s, $places[0]); if ($r['err']) break; } }
            foreach ($r['ev'] ?? [] as $e) if (isset($e['k']) && ($e['by'] ?? '') === 'me' && str_starts_with((string)$e['k'], 'g:')) $fx++;
        }
        return ['win' => in_array($s['over'], ['seen_off', 'charmed'], true) ? 1 : 0, 'turns' => (int)$s['turn'], 'hp' => 1 - max(0, $s['me']['hp']) / max(1, $s['me']['max']), 'over' => (string)$s['over'], 'pl' => $pl, 'fx' => $fx];
    } catch (Throwable $e) {
        return ['win' => 0, 'turns' => 0, 'hp' => 0, 'over' => 'err', 'pl' => 0, 'fx' => 0, 'err' => get_class($e) . ': ' . $e->getMessage()];
    }
}

if (PHP_SAPI !== 'cli' || realpath($argv[0]) !== __FILE__) return;
[, $cmd, $levels, $bots, $N, $rank] = $argv + [null, 'run', '12,24,34', 'chain,greedy,look', 40, 2];
[$sh, $nsh] = array_map('intval', explode('/', $argv[6] ?? '0/1')); $only = $argv[7] ?? ''; $N = (int)$N; $rank = (int)$rank; $bots = explode(',', $bots); $levels = array_map('intval', explode(',', $levels));
$P = ls_pieces(); if ($only !== '') $P = array_intersect_key($P, array_flip(explode(',', $only)));
$jobs = [];   // [level, crop|null, k0, k1]: the baseline is cut in chunks of N so the shards share it
foreach ($levels as $L) {
    if ($only === '') for ($k0 = 0; $k0 < 4 * $N; $k0 += $N) $jobs[] = [$L, null, $k0, $k0 + $N];
    foreach ($P as $crop => $p) $jobs[] = [$L, $crop, 0, $N];
}
$pls = [];
foreach ($jobs as $ji => [$L, $crop, $k0, $k1]) {
    if ($ji % $nsh !== $sh) continue;
    $pool = ls_pool($L); $pl = $crop === null ? ($pls[$L] ??= ls_player($L, null, $rank)) : ls_player($L, $crop, $rank);
    foreach ($bots as $bot) for ($k = $k0; $k < $k1; $k++) {
        $c = $pool[$k % count($pool)]; $seed = 700000 + 13 * $k + $L;   // the same creatures and seeds for every piece and the baseline
        $r = ls_fight($c, $L, $bot, $seed, $pl);
        echo json_encode(['lv' => $L, 'crop' => $crop ?? 'base', 'type' => $P[$crop]['t'] ?? '', 'v' => $P[$crop]['v'] ?? 0, 'tag' => $P[$crop]['tag'] ?? '', 'rank' => $rank, 'bot' => $bot, 'k' => $k, 'cr' => $c['slug'],
            'win' => $r['win'], 'hp' => round($r['hp'], 4), 'turns' => $r['turns'], 'over' => $r['over'], 'pl' => $r['pl'], 'fx' => $r['fx']] + (isset($r['err']) ? ['err' => $r['err']] : [])), "\n";
    }
}
